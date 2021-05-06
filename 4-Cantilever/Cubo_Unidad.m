function [ x,y,z,barras ] = Cubo_Unidad;
%CUADRADO_UNIDAD Genera un cubo unidad de una estructura
%   formada por barras articuladas.
%   El cubo está formado por 6 cuadrados unidad como caras.
%   No posee barras según las diagonales tridimensionales
%
% Los vértices del cubo son:
%    (0,0,0) - (0,1,0) - (1,1,0) -(1,0,0)
%    (0,0,1) - (0,1,1) - (1,1,1) -(1,0,1)
%
% Variables de salida
%   x,y,z:  Coordenadas de los nodos
%   barras: Matriz de conectividad

% El cubo se construye uniendo cuadrados unidad
[ xo,yo,bo ] = Cuadrado_Unidad;


% Cuadrado de la base en el plano XY
x1=xo; y1=yo; z1=0*xo; b1=bo;

% Cuadrado de la base en el plano z=1
x2=x1; y2=y1; z2=1+z1; b2=bo;

% Cuadrado en el plano YZ
x3=0*xo; y3=xo; z3=yo; b3=bo;

% Cuadrado en el plano x=1;
x4=1+x3; y4=y3; z4=z3; b4=bo;

% Cuadrado en el plano XZ
x5=xo; y5=0*xo; z5=yo; b5=bo;

% Cuadrado en el plano y=1;
x6=x5; y6=1+y5; z6=z5; b6=bo;

% Se unen las estructuras
nodos=[ x1,y1,z1 ]; barras=b1;
[ nodos,barras ] = Union( nodos,barras , [x2,y2,z2],b2 );
[ nodos,barras ] = Union( nodos,barras , [x3,y3,z3],b3 );
[ nodos,barras ] = Union( nodos,barras , [x4,y4,z4],b4 );
[ nodos,barras ] = Union( nodos,barras , [x5,y5,z5],b5 );
[ nodos,barras ] = Union( nodos,barras , [x6,y6,z6],b6 );

x=nodos(:,1);
y=nodos(:,2);
z=nodos(:,3);

