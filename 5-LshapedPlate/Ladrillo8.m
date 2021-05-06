function [K,M,Fg]=Ladrillo8(nodos,ro,E,nu);
% LADRILLO8 calcula las matrices de masa M y rigidez K junto con el 
%     vector Fg de fuerzas gravitorias (suponiendo el eje z vertical 
%     ascendente), correspondiente a un ELEMENTO FINITO de tipo
%     "ladrillo" con 8 nodos (situados en sus vértices).
%     
%     El elemento finito es un prisma recto de bases trapezoidales
% 
% Datos de entrada: nodos: Matriz de dimension 8x3 que contiene las
%                          coordenadas de los nodos (en metros)
%                   ro:    Densidad (en kg/m3)
%                   E:     Módulo de Elasticidad (Pa)
%                   nu:    Coef. de Poisson (adimensional)

% Calculo de la matriz de rigidez utilizando soli83 de CALFEM 3.4
D  = hooke(4,E,nu);  
[K,nada,JacobDetZero]  = soli8e(nodos(:,1)',nodos(:,2)',nodos(:,3)',3,D);

% Calculo de la matriz de masa, utilizando soli8m (escrita por JVO)
M  = soli8m(nodos(:,1),nodos(:,2),nodos(:,3),ro); 

% Calculo de las fuerzas gravitatorias apoyandose en la 
% matriz de masa
Fg = zeros(3,8); Fg(3,:)=-9.81;
Fg = M*Fg(:);


% Se representa el elemento
Representar=JacobDetZero;
if Representar
    figure
    a =1; b =2; c =3; d =4;
    a1=5; b1=6; c1=7; d1=8;
    
    car=NaN(6,4);
    car(1,:)=[ a1 b1 c1 d1 ];
    car(2,:)=[ a  b  c  d  ];
    car(3,:)=[ a1 a  d  d1 ];
    car(4,:)=[ d1 d  c  c1 ];
    car(5,:)=[ c1 c  b  b1 ];
    car(6,:)=[ a1 a  b  b1 ];
    
    color=[0.9921 0.6200 0.3948]; % Color cobre claro
    Representa3D(nodos,car,true,color);
end


end

function M=soli8m(ex,ey,ez,ro);
% Calcula una "lumped mass matrix", una matriz de masa
% con la masa concentrada en la diagonal de la matriz

% Se lleva el origen al centro de masas de los nodos
% (esto no cambia la matriz de masa)
ex=ex-mean(ex);
ey=ey-mean(ey);
ez=ez-mean(ez);

% vertices de las caras superior e inferior
a1=[ ex(1) ey(1) ez(1) ]';
b1=[ ex(2) ey(2) ez(2) ]';
c1=[ ex(3) ey(3) ez(3) ]';
d1=[ ex(4) ey(4) ez(4) ]';
a2=[ ex(5) ey(5) ez(5) ]';
b2=[ ex(6) ey(6) ez(6) ]';
c2=[ ex(7) ey(7) ez(7) ]';
d2=[ ex(8) ey(8) ez(8) ]';

% Calculo de "altura media"
% Se ajustan dos planos paralelos:
%    a*x+b*y+c*z+1=0 a la cara superior
%    a*x+b*y+c*z-1=0 a la cara inferior
A=[ ex ey ez ]; b=[ -ones(4,1) ; ones(4,1) ];
p=A\b; h=2/norm(p);

% Cálculo de la sección media
a=(a1+a2)/2; b=(b1+b2)/2; c=(c1+c2)/2; d=(d1+d2)/2;

% Cáculo del area
A=1/2*norm(cross(b-a,d-a))+1/2*norm(cross(b-c,d-c));

V = A*h  ; % Volumen
M = ro*V ; % Masa total

% Vólumenes que "cubriría" cada nodo
Va1=abs(det([ d1-a1 b1-a1 a2-a1 ]));
Vb1=abs(det([ c1-b1 a1-b1 b2-b1 ]));
Vc1=abs(det([ b1-c1 d1-c1 c2-c1 ]));
Vd1=abs(det([ a1-d1 c1-d1 d2-d1 ]));
Va2=abs(det([ d2-a2 b2-a2 a2-a1 ]));
Vb2=abs(det([ c2-b2 a2-b2 b2-b1 ]));
Vc2=abs(det([ b2-c2 d2-c2 c2-c1 ]));
Vd2=abs(det([ a2-d2 c2-d2 d2-d1 ]));

Vsum=Va1+Vb1+Vc1+Vd1+Va2+Vb2+Vc2+Vd2;

ma1=M*Va1/Vsum;
mb1=M*Vb1/Vsum;
mc1=M*Vc1/Vsum;
md1=M*Vd1/Vsum;
ma2=M*Va2/Vsum;
mb2=M*Vb2/Vsum;
mc2=M*Vc2/Vsum;
md2=M*Vd2/Vsum;

% Matriz de masa
u=[1 1 1];
M=diag([ ma1*u mb1*u mc1*u md1*u ma2*u mb2*u mc2*u md2*u ]);

end






% La función soli8e ha sido tomada de CALFEM 3.4

function [Ke,fe,JacobDetZero]=soli8e(ex,ey,ez,ep,D,eq)
% Ke=soli8e(ex,ey,ez,ep,D)
% [Ke,fe]=soli8e(ex,ey,ez,ep,D,eq)
%-------------------------------------------------------------
% PURPOSE
%  Calculate the stiffness matrix for a 8 node (brick)
%  isoparametric element.
%
% INPUT:   ex = [x1 x2 x3 ... x8]
%          ey = [y1 y2 y3 ... y8]  element coordinates
%          ez = [z1 z2 z3 ... z8]
%
%          ep = [ir]               ir integration rule
%
%          D                       constitutive matrix
%
%          eq = [bx; by; bz]       bx: body force in x direction
%                                  by: body force in y direction
%                                  bz: body force in z direction
%
% OUTPUT: Ke : element stiffness matrix
%         fe : equivalent nodal forces 
%-------------------------------------------------------------

% LAST MODIFIED: M Ristinmaa   1995-10-25
% Copyright (c)  Division of Structural Mechanics and
%                Department of Solid Mechanics.
%                Lund Institute of Technology
%-------------------------------------------------------------
  ir=ep(1);  ngp=ir*ir*ir;
  if nargin==5   eq=zeros(3,1);  end 

%--------- gauss points --------------------------------------
  if ir==1
    g1=0.0; w1=2.0;
    gp=[ g1 g1 ];  w=[ w1 w1 ];
  elseif ir==2
    g1=0.577350269189626; w1=1;
    gp(:,1)=[-1; 1; 1;-1;-1; 1; 1;-1]*g1; w(:,1)=[ 1; 1; 1; 1; 1; 1; 1; 1]*w1;
    gp(:,2)=[-1;-1; 1; 1;-1;-1; 1; 1]*g1; w(:,2)=[ 1; 1; 1; 1; 1; 1; 1; 1]*w1;
    gp(:,3)=[-1;-1;-1;-1; 1; 1; 1; 1]*g1; w(:,3)=[ 1; 1; 1; 1; 1; 1; 1; 1]*w1;
  elseif ir==3
    g1=0.774596669241483; g2=0.;
    w1=0.555555555555555; w2=0.888888888888888;

    I1=[-1; 0; 1;-1; 0; 1;-1; 0; 1]'; I2=[ 0;-1; 0; 0; 1; 0; 0; 1; 0]';
    gp(:,1)=[I1 I1 I1]'*g1;           gp(:,1)=[I2 I2 I2]'*g2+gp(:,1);
    I1=abs(I1); I2=abs(I2);
    w(:,1)=[I1 I1 I1]'*w1;
    w(:,1)=[I2 I2 I2]'*w2+w(:,1);
    I1=[-1;-1;-1; 0; 0; 0; 1; 1; 1]'; I2=[ 0; 0; 0; 1; 1; 1; 0; 0; 0]';
    gp(:,2)=[I1 I1 I1]'*g1;           gp(:,2)=[I2 I2 I2]'*g2+gp(:,2);
    I1=abs(I1); I2=abs(I2);
    w(:,2)=[I1 I1 I1]'*w1;
    w(:,2)=[I2 I2 I2]'*w2+w(:,2);
    I1=[-1;-1;-1;-1;-1;-1;-1;-1;-1]'; I2=[ 0; 0; 0; 0; 0; 0; 0; 0; 0]';
    I3=abs(I1);
    gp(:,3)=[I1 I2 I3]'*g1;           gp(:,3)=[I2 I3 I2]'*g2+gp(:,3);
    w(:,3)=[I3 I2 I3]'*w1;
    w(:,3)=[I2 I3 I2]'*w2+w(:,3);
  else
    disp('Used number of integration points not implemented');
    return
  end;

  wp=w(:,1).*w(:,2).*w(:,3);
  xsi=gp(:,1);  eta=gp(:,2); zet=gp(:,3);  r2=ngp*3;

%--------- shape functions -----------------------------------
  N(:,1)=(1-xsi).*(1-eta).*(1-zet)/8;  N(:,5)=(1-xsi).*(1-eta).*(1+zet)/8;
  N(:,2)=(1+xsi).*(1-eta).*(1-zet)/8;  N(:,6)=(1+xsi).*(1-eta).*(1+zet)/8;
  N(:,3)=(1+xsi).*(1+eta).*(1-zet)/8;  N(:,7)=(1+xsi).*(1+eta).*(1+zet)/8;
  N(:,4)=(1-xsi).*(1+eta).*(1-zet)/8;  N(:,8)=(1-xsi).*(1+eta).*(1+zet)/8;

  dNr(1:3:r2,1)=-(1-eta).*(1-zet);    dNr(1:3:r2,2)= (1-eta).*(1-zet);
  dNr(1:3:r2,3)= (1+eta).*(1-zet);    dNr(1:3:r2,4)=-(1+eta).*(1-zet);
  dNr(1:3:r2,5)=-(1-eta).*(1+zet);    dNr(1:3:r2,6)= (1-eta).*(1+zet);
  dNr(1:3:r2,7)= (1+eta).*(1+zet);    dNr(1:3:r2,8)=-(1+eta).*(1+zet);
  dNr(2:3:r2+1,1)=-(1-xsi).*(1-zet);  dNr(2:3:r2+1,2)=-(1+xsi).*(1-zet);
  dNr(2:3:r2+1,3)= (1+xsi).*(1-zet);  dNr(2:3:r2+1,4)= (1-xsi).*(1-zet);
  dNr(2:3:r2+1,5)=-(1-xsi).*(1+zet);  dNr(2:3:r2+1,6)=-(1+xsi).*(1+zet);
  dNr(2:3:r2+1,7)= (1+xsi).*(1+zet);  dNr(2:3:r2+1,8)= (1-xsi).*(1+zet);
  dNr(3:3:r2+2,1)=-(1-xsi).*(1-eta);  dNr(3:3:r2+2,2)=-(1+xsi).*(1-eta);
  dNr(3:3:r2+2,3)=-(1+xsi).*(1+eta);  dNr(3:3:r2+2,4)=-(1-xsi).*(1+eta);
  dNr(3:3:r2+2,5)= (1-xsi).*(1-eta);  dNr(3:3:r2+2,6)= (1+xsi).*(1-eta);
  dNr(3:3:r2+2,7)= (1+xsi).*(1+eta);  dNr(3:3:r2+2,8)= (1-xsi).*(1+eta);
  dNr=dNr/8.;


  Ke=zeros(24,24);  
  fe=zeros(24,1);
  JT=dNr*[ex;ey;ez]';

%--------- three dimensional case ----------------------------
JacobDetZero=false;
  for i=1:ngp
    indx=[ 3*i-2; 3*i-1; 3*i ];
    detJ=det(JT(indx,:));
    detJ=abs(detJ);
    if detJ<10*eps
      disp(sprintf('Jacobideterminant equal or less than zero!   detJ=%g',detJ))
      JacobDetZero=true;
    end
    JTinv=inv(JT(indx,:));
    dNx=JTinv*dNr(indx,:);

    B(1,1:3:24-2)=dNx(1,:);
    B(2,2:3:24-1)=dNx(2,:);
    B(3,3:3:24)  =dNx(3,:);
    B(4,1:3:24-2)=dNx(2,:);
    B(4,2:3:24-1)=dNx(1,:);
    B(5,1:3:24-2)=dNx(3,:);
    B(5,3:3:24)  =dNx(1,:);
    B(6,2:3:24-1)=dNx(3,:);
    B(6,3:3:24)  =dNx(2,:);

    N2(1,1:3:24-2)=N(i,:);
    N2(2,2:3:24-1)=N(i,:);
    N2(3,3:3:24)  =N(i,:);

    Ke=Ke+B'*D*B*detJ*wp(i);
    fe=fe+N2'*eq*detJ*wp(i);
  end
end%--------------------------end--------------------------------

% función hooke tomada de CALFEM 3.4

  function [D]=hooke(ptype,E,v)
% D=hooke(ptype,E,v)
%-------------------------------------------------------------
%  PURPOSE
%   Calculate the material matrix for a linear
%   elastic and isotropic material.
%
% INPUT:  ptype=1:  plane stress
%               2:  plane strain
%               3:  axisymmetry
%               4:  three dimensional
%
%          E : Young's modulus
%          v : Poissons const.
%
% OUTPUT: D : material matrix
%-------------------------------------------------------------

% LAST MODIFIED: M Ristinmaa 1995-10-25
% Copyright (c)  Division of Structural Mechanics and
%                Department of Solid Mechanics.
%                Lund Institute of Technology
%-------------------------------------------------------------
 if ptype==1
        Dm=E/(1-v^2)*[1  v   0;
                      v  1   0;
                      0  0 (1-v)/2];
 elseif ptype==2
        Dm=E/(1+v)/(1-2*v)*[1-v  v    v        0;
                             v  1-v   v        0;
                             v   v   1-v       0;
                             0   0    0   (1-2*v)/2];;
 elseif ptype==3
        Dm=E/(1+v)/(1-2*v)*[1-v  v    v        0;
                             v  1-v   v        0;
                             v   v   1-v       0;
                             0   0    0   (1-2*v)/2];;
 elseif ptype==4
        Dm=E/(1+v)/(1-2*v)*[1-v  v    v    0    0    0;
                             v  1-v   v    0    0    0;
                             v   v   1-v   0    0    0;
                             0   0    0 (1-2*v)/2    0    0;
                             0   0    0    0 (1-2*v)/2    0;
                             0   0    0    0    0  (1-2*v)/2];
 else
   error('Error ! Check first argument, ptype=1,2,3 or 4 allowed')
   return
 end
 D=Dm;
end%--------------------------end--------------------------------

