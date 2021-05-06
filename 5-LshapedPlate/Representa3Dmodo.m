function Representa3Dmodo(nodos,barras,v,gif)
%
% Representa el modo normal de vibraci�n 
% de una estructura tridimensional
% formada por barras articuladas
% generando una animaci�n que puede almacenarse en disco (solo MATLAB)
%
%      v:   coordenadas generalizadas del modo normal de vibraci�n
%           ( estas coordenadas tambi�n pueden tener parte compleja )
%           v = vr + vi*j = Amplitud*exp(j*fase)
%
%      gif: (opcional) nombre del archivo gif donde se guardar�a la
%           animaci�n
%
%     Nn y Nb son, respectivamente, el n�mero de nodos y el de barras

% Se determina si se trabaja con MATLAB u Octave
clone=matlab_clone;
switch clone
    case 'MATLAB', IsMatlab=true;
    case 'OCTAVE', IsMatlab=false;
end

h=figure; % Se crea una nueva figura

if nargin>3
    gif_exists=true;   % Se marca como existente el archivo GIF
    titulo=gif;        % Se usa el nombre como t�tulo
    gif=[gif '.GIF'];  % Se a�ade .GIF al nombre del archivo
else
    gif_exists=false;
    titulo=[];
end

x=nodos(:,1);
y=nodos(:,2);
z=nodos(:,3);
[dx,dy,dz]=q2xyz(v);  % Se pasa vector 3Nn a matriz desplazamientos en x y z    

% Selecci�n de la amplificaci�n para el modo
%
% 1ro. Tama�o de la estructura
xmax=max(x); xmin=min(x); ymax=max(y); ymin=min(y);  zmax=max(z); zmin=min(z);
D = sqrt( (xmax-xmin)^2 + (ymax-ymin)^2 + (zmax-zmin)^2 );

% M�ximo desplazamiento del modo
qmax=max(abs(v));

cte=0.1;        % Amplitud m�xima del modo ya amplificada en tanto por uno
                % respecto al tama�o de la estructura
Amp=cte*D/qmax; % Factor de amplificaci�n


% Representaci�n de la estructura sin deformar (en gris)
gris=[0.8 0.8 0.8];      % Color de la estructura sin deformar
[Nb,nada]=size(barras);  % N�mero de barras
[ xl, yl, zl]=LineasBarras(  nodos   ,barras); % La estructura sin deformar como una sola l�nea
[dxl,dyl,dzl]=LineasBarras([dx dy dz],barras); % Las deformaciones como una sola l�nea

    
% Representaci�n del modo a lo largo de dos ciclos completos de oscilaci�n
if IsMatlab
  ni=50; % Numero total de fotogramas
  nc=2;  % Numero de ciclos
else
  ni=20; % Numero total de fotogramas
  nc=2;  % Numero de ciclos
end
 
  
for fase=nc*2*pi*[0:1/ni:1]
    % Representaci�n de la estructura sin deformar (en gris)
    hold off
    plot3(xl,yl,zl,'color',gris); hold on
    
    % Representaci�n de la estructura deformada
    plot3(  xl+abs(dxl)*Amp.*cos(fase+angle(dxl))  ,  ...
            yl+abs(dyl)*Amp.*cos(fase+angle(dyl))  ,  ...
            zl+abs(dzl)*Amp.*cos(fase+angle(dzl))  ,  ...
            'b' , 'LineWidth',2 ); 

    % Fijaci�n de la escala de los ejes y leyendas de �stos
    grid on, axis equal
    xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)');
    if gif_exists
        title(sprintf('%s - Amplificaci�n x%1.0f',titulo,Amp));
    else
        title(sprintf('Factor de Amplificaci�n x%1.0f',Amp));
    end
    
    drawnow              % Se termina de dibujar la figura
    if gif_exists & IsMatlab
        im=getframe(h);         % Se capta un fotograma
        im=frame2im(im);        % El fotograma se pasa a formato imagen
        
        [im,colmap]=rgb2ind(im,256);  % La imagen se pasa color indexado
                                      % guardandose el mapa de color en
                                      % colmap
                                     
        % Se escribe imagen a imagen en el archivo GIF
        if fase==0
            imwrite(im,colmap,gif,'gif','Loopcount',inf,'DelayTime',1/12);
        else
            imwrite(im,colmap,gif,'gif','WriteMode','append','DelayTime',1/12);
        end
    end
end



function [xl,yl,zl]=LineasBarras(nodos,barras);
% Representa la totalidad de la estructura como una sola linea
% con sus coordenadas almacenadas en xl,yl,zl
%
% El paso de una barra a otra se marca con un NaN

Nb=length(barras(:,1)); % N�mero de barras
xl=NaN*zeros(1,3*Nb);
yl=xl;
zl=xl;
for i=1:Nb
    xl( 3*(i-1)+[1 2] ) = nodos(barras(i,1:2),1);
    yl( 3*(i-1)+[1 2] ) = nodos(barras(i,1:2),2);
    zl( 3*(i-1)+[1 2] ) = nodos(barras(i,1:2),3);
end


