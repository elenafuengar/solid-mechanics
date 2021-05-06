function Representa2Dmodo(x,y,barras,v,gif)
%
% Representa un modo normal de vibración
% de una estructura bidimensional
% formada por barras articuladas
%
% Variables de entrada:
%
%      x,y: vectores de dimensión Nnx1 conteniendo las coordenadas de los
%           nodos de la estructura
%      barras: Matriz de dimensión Nbx2 conteniendo los números de los
%           nodos en los que comienza y finaliza cada una de las barras
%      v:   coordenadas generalizadas del modo normal de vibración
%
%      gif: (opcional) nombre del archivo gif donde se guardaría la
%           animación
%
%     Nn y Nb son, respectivamente, el número de nodos y el de barras

% Se determina si se trabaja con MATLAB u Octave
clone=matlab_clone;
switch clone
    case 'MATLAB', IsMatlab=true;
    case 'OCTAVE', IsMatlab=false;
end

h=figure; % Se crea una nueva figura

if nargin>4
    gif_exists=true;   % Se marca como existente el archivo GIF
    titulo=gif;        % Se usa el nombre como título
    gif=[gif '.GIF'];  % Se añade .GIF al nombre del archivo
else
    gif_exists=false;
    titulo=[];
end

% Selección de la amplificación para el modo
%
% 1ro. Tamaño de la estructura
xmax=max(x); xmin=min(x); ymax=max(y); ymin=min(y);
D = sqrt( (xmax-xmin)^2 + (ymax-ymin)^2 );

% Máximo desplazamiento del modo
qmax=max(abs(v));

cte=0.1;        % Amplitud máxima del modo ya amplificada en tanto por uno
                % respecto al tamaño de la estructura
Amp=cte*D/qmax; % Factor de amplificación


% Representación de la estructura sin deformar (en gris)
gris=[0.8 0.8 0.8];      % Color de la estructura sin deformar
[Nb,nada]=size(barras);  % Número de barras
for i=1:Nb
    plot( x(barras(i,:)) , y(barras(i,:)) , 'color', gris ); hold on
end

% Fijación de unas escalas constantes para los ejes de la figura
axis equal
a=axis; Dx=a(2)-a(1); Dy=a(4)-a(3); Aspecto=Dx/Dy;
newa = [ a(1)-cte*D*Aspecto a(2)+cte*D*Aspecto a(3)-cte*D a(4)+cte*D ];
axis(newa);


[dx,dy]=q2xyz(v);  % Se pasa el modo de vibración a coordenadas xy


% Representación del modo a lo largo de tres ciclos completos de oscilación
if IsMatlab
  ni=50; % Numero total de fotogramas
  nc=3;  % Numero de ciclos
else
  ni=20; % Numero total de fotogramas
  nc=2;  % Numero de ciclos
end
 
  
for fase=nc*2*pi*[0:1/ni:1]
    % Representación de la estructura sin deformar (en gris)
    hold off
    for i=1:Nb
        plot( x(barras(i,:)) , y(barras(i,:)) , 'color', gris ); hold on
    end
    
    if fase==0
        % Fijación de unas escalas constantes para los ejes de la figura
        axis equal
        a=axis; Dx=a(2)-a(1); Dy=a(4)-a(3); Aspecto=Dx/Dy;
        newa = [ a(1)-cte*Dx a(2)+cte*Dx a(3)-cte*Dy a(4)+cte*Dy ];
    end
    
    % Representación de la estructura deformada
    for i=1:Nb
        plot( x(barras(i,:))+Amp*dx(barras(i,:))*cos(fase) , ...
              y(barras(i,:))+Amp*dy(barras(i,:))*cos(fase) , ...
              'g' , 'LineWidth',2 ); 
        hold on
    end

    % Fijación de la escala de los ejes y leyendas de éstos
    grid on, axis(newa)
    xlabel('X (m)');
    ylabel('Y (m)');
    if gif_exists
        title(sprintf('%s - Amplificación x%1.0f',titulo,Amp));
    else
        title(sprintf('Factor de Amplificación x%1.0f',Amp));
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

end








function [clone,version]=matlab_clone;
    % detecta si se esta ejecutando Matlab u Octave
    try
       version=OCTAVE_VERSION;
       clone='OCTAVE';
    catch
       clone='MATLAB';
       a=ver('matlab');
       version=a.Version;
    end
end






function [o1,o2,o3]=q2xyz(i1,i2,i3)
% La función q2xyz permite pasar de desplazamientos en x,y,z
% a desplazamientos en q (coordenadas generalizadas) o viceversa
%
% Igualmente permite pasar de fuerzas en x,y,z a fuerzas generelizadas
% o viceversa
%
% USO:
%
% Paso de xyz a q  en desplazamientos en 3D:   q=q2xyz(dx,dy,dz)
% Paso de xy  a q  en desplazamientos en 2D:   q=q2xyz(dx,dy)
%
% Paso de xyz a f  en fuerzas en 3D:           f=q2xyz(fx,fy,fz)
% Paso de xy  a f  en fuerzas en 2D:           f=q2xyz(fx,fy)
%
% Paso de q a xyz  en desplazamientos en 3D:   [dx,dy,dz]=q2xyz(q)
% Paso de q a xy   en desplazamientos en 2D:   [dx,dy]=q2xyz(q)
%
% Paso de f a xyz  en fuerzas en 3D:           [fx,fy,fz]=q2xyz(f)
% Paso de f a xy   en fuerzas en 2D:           [fx,fy]=q2xyz(f)

if nargin==1        % Paso de coordenadadas generalizadas a xyz
    
    q  = i1;        % coordenadas generalizadas
    d  = nargout ;  % dimension del problema (2D ó 3D)
    R  = NaN*zeros(d,round(length(q)/d)); 
    R(:) = q;
    o1=R(1,:)';     % Desplazamientos según x (dx)
    o2=R(2,:)';     % Desplazamientos según y (dy)
    if d==3
        o3=R(3,:)'; % Desplazamientos según z (dz)
    end
    
else                % Paso de xyz a coordenadas generalizadas
   
    d = nargin;     % Dimension del problema (2D ó 3D)
    R = [ i1(:)' ; i2(:)' ];
    if d==3
        R = [ R ; i3(:)' ];
    end
    o1=R(:);
    
end

end




