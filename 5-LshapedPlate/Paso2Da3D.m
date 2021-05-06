function [nodos,elem]=Paso2Da3D(nodos2D,elem2D,H,N);
% Paso2Da3D construye una malla tridimensional
% con ladrillos de 8 nodos a partir de los datos (nodos2D,elem2D)
% de una secci�n bidimensional formada por pseudo-rect�ngulos de 4 nodos
%
% Variables de entrada:
%     nodos2D:   Matriz (de dos columnas) con las coordenadas x,y
%                de los nodos de la malla 2D
%     elem2D:    Matriz de conectividad (de cuatro columnas) de la malla 2D
%     H:         Altura total seg�n Z de la malla 3D
%     N:         N�mero de elementos de la malla 3D seg�n Z
%
% Variables de salida
%     nodos:     Matriz Nnx3 con las coordenadas de los nodos
%     elem:      Matriz Nex8, matriz de conectividad
%
% Sintaxis:
%     [nodos,elem]=Paso2Da3D(nodos2D,elem2D,H,N);

nodos=[]; elem=[];

Nn=length(nodos2D); % N�mero de nodos en la secci�n bidimensional
Ne=length(elem2D);  % N�mero de elementos en la secci�n bidimensional

dZ=H/N;
nodos=[ nodos2D zeros(Nn,1) ]; % Nodos de la cara inferior (cota Z=0)
elem=[];  % Inicializaci�n de la matriz de conectividad
for i=1:N % Bucle a lo largo de las N capas de Elementos Finitos
    nodos = [ nodos; nodos2D dZ*i*ones(Nn,1) ];
    elem  = [ elem;  elem2D+(i-1)*Nn  elem2D+i*Nn  ];
end

    
 
