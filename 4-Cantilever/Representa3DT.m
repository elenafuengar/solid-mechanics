function Representa3DT(nodos,barras,T)
% Representa las tensiones de una estructura en 3D 
% a traves del color de dichas barras
%
% Variables de entrada:
%     nodos:  matriz Nnx3 con las coordenadas de los nodos
%     barras: matriz Nbx2 de conectividad de la estructura
%     T       vector Nbx1 con las tensiones de las barras
%
% Nn, Nb son, respectivamente, el número de nodos y barras


figure; % Se crea una nueva figura

% Coordenadas cartesianas de los nodos
x=nodos(:,1); y=nodos(:,2); z=nodos(:,3);

% Mapa de color para las tensiones
nc1 =32;        % Número de colores (en positivo y negativo)
nc2=2*nc1+1;    % Número total de colores
ncmax  = 1;     % Color correspondiente a Tmax
nczero = nc1+1; % Color correspondiente a T=0
ncmin  = nc2;   % Color correspondiente a Tmin

cm=jet(nc2);    % Escala de colores (JET)

Tmax  = max(T);
Tmin  = min(T);

% Representación de las barras con la tensión a través del color
[Nb,nada]=size(barras);
for i=1:Nb
    
    % Elección del color en función de la tensión
    % Nota: se distingue entre tensiones negativas y positivas
    if T(i)>0
        e=T(i)/Tmax;
        ic=round(nczero*(1-e)+ncmax*e);
        c=cm(ic,:);
    else
        e=T(i)/Tmin;
        ic=round(nczero*(1-e)+ncmin*e);
        c=cm(ic,:);
    end
    
    % Dibujo de la barra en color
    plot3( x(barras(i,:)) , y(barras(i,:)) , z(barras(i,:)) , 'color',c ,'LineWidth',2 ); hold on

end

axis equal, axis on, grid on
xlabel('X(m)'); ylabel('Y(m)'); zlabel('Z(m)');

