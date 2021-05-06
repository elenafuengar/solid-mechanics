function [ x,y,barras ] = Cuadrado_Unidad;
%CUADRADO_UNIDAD Genera un cuadrado unidad de una estructura
%   formada por barras articuladas, incluyendo barras
%   segun las diagonales
%
% Los vértices del cuadrado son (0,0)-(0,1)-(1,0)-(1,1)
%
% Variables de salida
%   x,y:    Coordenadas de los nodos
%   barras: Matriz de conectividad

% figure

x = [ 0 ; 0 ; 1 ; 1 ] ;
y = [ 0 ; 1 ; 1 ; 0 ] ;

barras = [ 1 3 ; 2 4 ; 1 2 ; 2 3; 3 4 ; 4 1 ];


