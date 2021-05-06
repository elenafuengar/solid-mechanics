function RepresentaLadrillosModo(nodos,CarasExt,v,gif)
%
% Representa el modo normal de vibraci�n 
% de una malla de E.F. tipo LADRILLO de 8 nodos
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

cte=0.2;       % Amplitud m�xima del modo ya amplificada en tanto por uno
                % respecto al tama�o de la estructura
Amp=cte*D/qmax; % Factor de amplificaci�n

% Puntos l�mite
x1=xmin-Amp*qmax; x2=xmax+Amp*qmax;
y1=ymin-Amp*qmax; y2=ymax+Amp*qmax;
z1=zmin-Amp*qmax; z2=zmax+Amp*qmax;

xlim=[ x1 x2 x2 x1   x1 x2 x2 x1 ];
ylim=[ y1 y1 y2 y2   y1 y1 y2 y2 ];
zlim=[ z1 z1 z1 z1   z2 z2 z2 z2 ];

    
% Representaci�n del modo a lo largo de dos ciclos completos de oscilaci�n
if IsMatlab
  ni=50; % Numero total de fotogramas
  nc=2;  % Numero de ciclos
else
  ni=20; % Numero total de fotogramas
  nc=2;  % Numero de ciclos
end
 
  
for fase=nc*2*pi*[0:1/ni:1]
   
    clf       % Borra la figura
    plot3(xlim,ylim,zlim,'w.','MarkerSize',0.1); hold on, % Puntos l�mite
    x_des = x+abs(dx)*Amp.*cos(fase+angle(dx))  ;
    y_des = y+abs(dy)*Amp.*cos(fase+angle(dy))  ;
    z_des = z+abs(dz)*Amp.*cos(fase+angle(dz))  ;
    
    % Representaci�n de la malla deformada
    co=[1.0000    0.7812    0.4975]; % Color cobre
    for i=1:length(CarasExt(:,1)) % Bucle a lo largo de todas las caras
          ii=CarasExt(i,:);
          patch( x_des(ii),y_des(ii),z_des(ii),co);
    end
    grid on, axis equal, view(3)
    if fase==0
        % Obtiene la posici�n en la primera figura
        CamPos=get(gca,'CameraPosition');
        maximize; % Maximiza la ventana donde est� la figura
    else
        set(gca,'CameraPosition',CamPos);
    end
    camlight
    lighting phong

    % Fijaci�n de la escala de los ejes y leyendas de �stos
    xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)');
    if gif_exists
        title(sprintf('%s - Amplificaci�n x%1.0f',titulo,Amp));
    else
        title(sprintf('Factor de Amplificaci�n x%1.0f',Amp));
    end
    
    drawnow  % Se termina de dibujar la figura
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


function maximize(fig)
% MAXIMIZE Size a window to fill the entire screen.
%
% maximize(HANDLE fig)
%  Will size the window with handle fig such that it fills the entire screen.
%

% Modification History
% ??/??/2001  WHF  Created.
% 04/17/2003  WHF  Found 'outerposition' undocumented feature.
%

% Original author: Bill Finger, Creare Inc.
% Free for redistribution as long as credit comments are preserved.
%

if nargin==0, fig=gcf; end

units=get(fig,'units');
set(fig,'units','normalized','outerposition',[0 0 1 1]);
set(fig,'units',units);

% Old way:	
% These are magic numbers which are probably system dependent.
%dim=get(0,'ScreenSize')-[0 -5 0 72];

%set(fig,'Position',dim); 
