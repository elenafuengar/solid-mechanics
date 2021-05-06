%función para generar una viga vertical a partir de su longitud, altura y
%número de cuadrados elementales

function [x,y,barras] = VigaVertical_X(a,L,n)
 
 alto=L/n; %alto de los cuadrados
 %a es el ancho de los cuadrados
 
 nodos_elemental=[ -0.5 0; -0.5+a 0; -0.5 alto; -0.5+a alto]; %4 nodos por cuadrado  elemental
 xe=nodos_elemental(:,1);
 ye=nodos_elemental(:,2);
 barras_elemental=[1 2; 1 3; 3 4; 2 4; 1 4; 2 3 ]; %6 barras por cuadrado
 
 nodos=[]; %inicialización de las matrices
 barras=[];
 

 for i=1:n %n es el número de cuadrados
    nodos_altura=[xe , ye + (i-1)*alto]; %corrijo la coordenada y de los cuadrados
    nodos=[nodos; nodos_altura]; %añado cuadrados elementales a la matriz nodos
    
    barras=[ barras; barras_elemental + 4*(i-1)]; %se construye la matriz barras
    
 end
 
x=nodos(:,1);
y=nodos(:,2);
 
 end
 
 
