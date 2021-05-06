function Representa2D(x,y,barras,c)
%
% Representa una estructura bidimensional
% formada por barras articuladas
%
% Variables de entrada:
%
%      x,y: vectores de dimensi?n Nnx1 conteniendo las coordenadas de los
%           nodos de la estructura
%      barras: Matriz de dimensi?n Nbx2 conteniendo los n?meros de los
%           nodos en los que comienza y finaliza cada una de las barras
%     c:    color de las barras. Por omisi?n es verde
%
%     Nn y Nb son, respectivamente, el n?mero de nodos y el de barras

if nargin<4, c='g'; end

% Representaci?n de las barras
[Nb,nada]=size(barras);
for i=1:Nb
    plot( x(barras(i,:)) , y(barras(i,:)) ,c ); hold on
end

% Representaci?n de los nodos
plot( x,y ,'bo' );

axis equal, grid on, xlabel('X (m)'); ylabel('Y (m)');
     
for i=1:length(x)
    Opc=1+floor(7.99*rand);
    switch Opc
        case 1, text(x(i),y(i),sprintf('   %1.0f   ',i),'VerticalAlignment','top','HorizontalAlignment','left','color','b');
        case 2, text(x(i),y(i),sprintf('   %1.0f   ',i),'VerticalAlignment','top','HorizontalAlignment','center','color','b');
        case 3, text(x(i),y(i),sprintf('   %1.0f   ',i),'VerticalAlignment','top','HorizontalAlignment','right','color','b');
        case 4, text(x(i),y(i),sprintf('   %1.0f   ',i),'VerticalAlignment','middle','HorizontalAlignment','right','color','b');
        case 5, text(x(i),y(i),sprintf('   %1.0f   ',i),'VerticalAlignment','bottom','HorizontalAlignment','right','color','b');
        case 6, text(x(i),y(i),sprintf('   %1.0f   ',i),'VerticalAlignment','bottom','HorizontalAlignment','center','color','b');
        case 7, text(x(i),y(i),sprintf('   %1.0f   ',i),'VerticalAlignment','bottom','HorizontalAlignment','left','color','b');
        case 8, text(x(i),y(i),sprintf('   %1.0f   ',i),'VerticalAlignment','middle','HorizontalAlignment','left','color','b');
    end
end

for i=1:Nb
    e=0.3+0.4*rand;
    xc=e*x(barras(i,1))+(1-e)*x(barras(i,2));
    yc=e*y(barras(i,1))+(1-e)*y(barras(i,2));
    text(xc,yc,sprintf('%1.0f',i),'VerticalAlignment','middle','HorizontalAlignment','center','color',c);
end
