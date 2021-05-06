function [nod2d,ele2d]=Corona2D(BordeInt,BordeExt,N);
% Corona2D genera una malla de romboides (4 nodos)
% en forma de corona entre el borde interior (BoreInt) 
% y el borde exterior (BordeExt), siendo ambos bordes contornos cerrados
%
%
% Variables de entrada:
%
%    BordeInt:  Matriz de dimensión nx2 conteniendo en cada fila las
%               coordenadas (x,y) de cada punto del BORDE INTERIOR cerrado
%
%    BordeExt:  Matriz de dimensión nx2 conteniendo en cada fila las
%               coordenadas (x,y) de cada punto del BORDE INTERIOR cerrado
%
%    En número n de puntos en el borde exterior e interior debe ser el
%    mismo
%
%    N:        Número de filas de elementos entre el borde interior y el
%              exterior
%
% Variables de salida:
%   
%   nod2d:     Matriz de dimensiones Nnx2 con las coordenadas x,y de los
%              nodos de la malla 2D
%   ele2d:     Matriz de conectividad (dimensiones Nex4) de los elementos


Ni=length(BordeInt(:,1)); % Nº de nodos en la dirección tangencial (i)
Nj=N+1;                   % Nº de nodos en la dirección radial (j)
Nn=Ni*Nj;                 % Número total de nodos
Ne=N*Ni;                  % Número total de elementos

% Coordenadas de los nodos
nod2d=NaN*zeros(Nn,2);
for i=1:Ni, for j=0:N
    n=(i-1)*Nj+j+1;
    nod2d(n,:)=BordeInt(i,:)*(N-j)/N+BordeExt(i,:)*j/N;
end, end

% Elementos
ele2d=NaN*zeros(Ne,4);
for i=1:Ni, for j=1:N
   n1=(i-1)*Nj+j;
   n2=(i-1)*Nj+j+1;
   if i<Ni
       n3=i*Nj+j+1;
       n4=i*Nj+j;
   else
       n3=j+1;
       n4=j;
   end
   ele2d( (i-1)*N+j , : ) = [n1 n2 n3 n4];
end, end





