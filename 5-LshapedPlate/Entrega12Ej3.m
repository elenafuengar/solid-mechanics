%ENTREGA 12 EJERCICIO 3: Parte 1%
%En este ejercicio se repite lo calculado en el Ejercicio 1 y 2, con un
%número creciente de elementos por malla, para tabular como varía la
%frecuencia al afinar la malla.
%Se ha creado una función para que devuelva la frecuencia en funcion del
%factor de afine, F, escogido.
%Aumentando el factor de afine se aumenta el numero de elementos en F^3

function [fmin]=Entrega12Ej3(F)

%1. GENERACION DE LA MALLA

Nx=F*5; Ny=F*4; Nz=F*2; %numero de elementos de la submalla
[nodos1,elem1]=Malla3D(Nx,Ny,Nz);%submalla
nodos1(:,1)=nodos1(:,1)-1; nodos1(:,2)=nodos1(:,2)-1;  %para que empiece en (0,0,0)
nodos1=nodos1/F; %ajusta la submalla
elem2=elem1; nodos2=nodos1; nodos2(:,2)=nodos2(:,2)+4; %trasladado de malla 2
elem3=elem1; nodos3=nodos1; nodos3(:,1)=nodos3(:,1)+5; %trasladado de malla 3

%2. UNION DE LA MALLA
[nodos,elem]=UnirLadrillos(nodos1,elem1,nodos2,elem2);
[nodos,elem]=UnirLadrillos(nodos,elem,nodos3,elem3);

nodos(:,3)=nodos(:,3)/2; %ajusta la altura de la figura
[Nn,nada]=size(nodos); %nº nodos
[Ne,nada]=size(elem);  %nº barras

%3. CONDICIONES DE CONTORNO E INICIALES

%Datos del material
ro=35*ones(Ne,1);   %densidad en kg/m3
E=100e6*ones(Ne,1); %módulo elástico en Pa
nu=0.30*ones(Ne,1); %coeficiente de poisson

%Nodos Fijos: los de las caras laterales
Fijos=0*nodos;    
%El vector NodosExt nos da los indices de los nodos que estan en las caras
%exteriores de la figura. Los nodos fijos son los de las caras
%perpendiculares al plano XY-->6 caras
[CarasExt,BarrasExt,NodosExt,Caras,Barras,TN]=CarasBarras(elem);
ii=NodosExt;
cara1= nodos(ii,1)==0; Fijos(cara1,:)=1;
cara2= nodos(ii,2)==0; Fijos(cara2,:)=1;
cara3= nodos(ii,2)==4 & nodos(ii,1)>=5; Fijos(cara3,:)=1;
cara4= nodos(ii,1)==5 & nodos(ii,2)>=4; Fijos(cara4,:)=1;
cara5= nodos(ii,2)==8; Fijos(cara5,:)=1;
cara6= nodos(ii,1)==10; Fijos(cara6,:)=1;

%5. REPRESENTACIÓN GRÁFICA
RepresentaLadrillos(nodos,CarasExt,BarrasExt,NodosExt);
hold on
%Representación de los nodos fijos
ii=find( prod(Fijos,2)==1 );
plot3(nodos(ii,1),nodos(ii,2),nodos(ii,3),'ro');
title(sprintf('Mallado de la figura - Afine %1.0f',F));
hold off

%6.ENSAMBLADO 
N  = 3*Nn;       % Número de grados de libertad
              
K = sparse(N,N); % Inicialización de la matriz de rigidez global
                     % como matriz dispersa
M = sparse(N,N); % Inicialización de la matriz de masa global 
                     % como matriz dispersa
fo = zeros(N,1); % Vector de fuerzas nodales estáticas

for e=1:Ne % Bucle a lo largo de todos los elementos
           % Se ensamblan las matrices elementales de rigidez y masa
   
    % Coordenadas de los nodos del elemento
    ne=nodos(elem(e,:),:);
    
    % Matrices de Rigidez (Ke) y Masa (Me) elementales 
    % junto con las fuerzas gravitatorias
    [Ke,Me,Fge]=Ladrillo8(ne,ro(e),E(e),nu(e));
        
    % Numeración global de grados de libertad del elemento
    ii=[];
    for k=1:length(elem(e,:))
        ii=[ ii    3*(elem(e,k)-1)+[1 2 3] ];
    end
    
    % Ensamblaje de la matriz de rigidez (suma)
    K(ii,ii) = K(ii,ii) + Ke;
    % Ensamblaje de la matriz de masa (suma)
    M(ii,ii) = M(ii,ii) + Me;
    % Ensamblaje del vector de fuerzas estaticas (suma)
    fo(ii) = fo(ii) + Fge ;
    
end % Fin del bucle a lo largo de las barras

%CONDICIONES DE CONTORNO

%Fijación de Kinf para los nodos fijos
kmax=max(abs(K(:)));
kinf=1000*kmax;

for i=1:Nn % Bucle a lo largo de todos los nodos
    % ¿ Está fijo el nodo según eje X ?
    if Fijos(i,1)==1
        j=3*(i-1)+1;         % Idenficador del grado de libertad
                             % en numeración globlal
        K(j,j)=K(j,j)+kinf;  % Se ensambla el apoyo "elástico"
    end
    % ¿ Está fijo el nodo según eje Y ?
    if Fijos(i,2)==1
        j=3*(i-1)+2;         % Idenficador del grado de libertad
                             % en numeración globlal
        K(j,j)=K(j,j)+kinf;  % Se ensambla el apoyo "elástico"
    end
    % ¿ Está fijo el nodo según eje Z ?
    if Fijos(i,3)==1
        j=3*(i-1)+3;         % Idenficador del grado de libertad
                             % en numeración globlal
        K(j,j)=K(j,j)+kinf;  % Se ensambla el apoyo "elástico"
    end
end

%7. 1ª FRECUENCIA DE RESONANCIA

%La frecuencia de resonancia se obtiene hallando los valores propios de A=K/M
[V,D]=eigs(K,M, 5,'sm');
%Las frecuencias propias w son las raices de los valores propios
w=sqrt(diag(D)); f=w/2/pi;
[fmin,imin]=min(f);%primera frecuencia
disp(sprintf('Primera Frecuencia Natural = %4.2f Hz',fmin));

%8. PRIMER MODO NORMAL 
%Representación en gif
% titulo=sprintf('Primer-Modo-F%1.0f',F); %en el título se añade el factor de afine
% RepresentaLadrillosModo(nodos,CarasExt,V(:,imin),titulo);

end
