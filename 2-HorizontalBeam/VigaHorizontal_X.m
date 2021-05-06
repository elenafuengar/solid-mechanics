%función para generar una viga horizontal a partir de su longitud, altura y
%número de cuadrados elementales

function [x,y,barras] = VigaHorizontal_X(a,L,n)
 
 Le=L/n; %largo de los cuadrados
 ancho=a;  %ancho de los cuadrados
 
 nodos_elemental=[0 0; 0 a; Le 0; Le a]; %4 nodos por cuadrado  elemental
 xe=nodos_elemental(:,1);
 ye=nodos_elemental(:,2);
 barras_elemental=[1 2; 1 3; 3 4; 2 4; 1 4; 2 3 ]; %6 barras por cuadrado
 
 nodos=[]; %inicialización de las matrices
 barras=[];
 
 for i=1:n %n es el número de cuadrados 
    nodos_largo=[xe+(i-1)*Le, ye]; %corrijo la coordenada x de los cuadrados
    nodos=[nodos; nodos_largo]; %añado cuadrados elementales a la matriz nodos
    barras=[ barras; barras_elemental+4*(i-1)]; %se construye la matriz barras
 end
 
x=nodos(:,1);
y=nodos(:,2);
 
 end