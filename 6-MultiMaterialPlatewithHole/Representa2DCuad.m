function Representa2DCuad(nod2d,ele2d);
% Representa2DCuad representa una malla 2D de romboides (4 nodos)
%
% Variables de entrada:
%   
%   nod2d:     Matriz de dimensiones Nnx2 con las coordenadas x,y de los
%              nodos de la malla 2D
%   ele2d:     Matriz de conectividad (dimensiones Nex4) de los elementos

figure
for e=1:length(ele2d(:,1));
    ii=ele2d(e,:); ii=[ii ii(1)];
    plot(nod2d(ii,1),nod2d(ii,2),'o-'); hold on
end

axis equal, grid on
xlabel('X(m)'); ylabel('Y(m)');