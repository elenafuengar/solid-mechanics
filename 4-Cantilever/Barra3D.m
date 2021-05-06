function [K,M,Fg,Fk]=Barra3D(Ra,Rb,k,m,loo);
% BARRA3D calcula las matrices de Masa M, Rigidez K y
% los vectores de fuerzas Fg (gravitatorias) y Fk (elásticas)
% de una barra articulada en 3D
%
% Variables de entrada:
%     Ra:  vector posición del nodo A de la barra , Ra=[Xa Ya Za]'
%     Rb:  vector posición del nodo B de la barra , Ra=[Xa Ya Za]'
%     k:   constante elástica de la barra
%     m:   masa de la barra
%     loo: longitud natural nula de la barra
%
% Variables de salida
%     K:   Matriz de rigidez
%     M:   Matriz de masa
%     Fg:  Vector de fuerzas gravitatorias
%     Fk:  Vector de fuerzas elásticas



g=9.8; % Aceleración de la Gravedad

Ra=Ra(:); Rb=Rb(:);
AB=Rb-Ra;       % Vector del nodo A al B
lo=norm(AB);    % Distancia entre nodos
c=AB/lo;        % Vector de cosenos directores


% Matriz de Masa
M11=eye(3); M12=1/2*eye(3);
M=m/3*[ M11 M12 ; M12 M11 ];

% Matriz de Rigidez
C = c*c';
I = eye(3); 
e = (lo-loo)/lo;

K = (1-e)*[ C -C ; -C C] +e*[I -I;-I I];
K = k*K;

% Vectores de fuerzas nodales
Fg = -m*g*[ 0 0 1/2 0 0 1/2]';
Fk = -k*(lo-loo)*[ -c ; c];

