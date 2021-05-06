function Representa3D(nodos,barras);
% Representa la estructura en 3D
% con nodos en (x,y,z)
% y barras descritas por el nodo
% final e inicial
%
% Variables de entrada:
%     nodos:  matriz Nx3 con las coordenadas de los nodos
%     barras: matriz de conectividad de la estructura


figure; % Se crea una nueva figura

% Coordenadas cartesianas de los nodos
x=nodos(:,1); y=nodos(:,2); z=nodos(:,3);

nb=length(barras(:,1)); % Número de barras

for i=1:nb % Dibujo de las barras de la estructura
    ii=barras(i,:);
    plot3(x(ii),y(ii),z(ii),'b','LineWidth',2); hold on
end

% Dibujo de los nodos de la estructura
plot3(x,y,z,'go');

axis equal, axis on, grid on
xlabel('X(m)'); ylabel('Y(m)'); zlabel('Z(m)');

