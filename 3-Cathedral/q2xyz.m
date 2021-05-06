function [o1,o2,o3]=q2xyz(i1,i2,i3) 
% PASA DE q=(x1,y1,x2,t2...) a dx=(x1,x2...) y dy=(y1,y2...) 

% La función q2xyz permite pasar de desplazamientos en x,y,z
% a desplazamientos en q (coordenadas generalizadas) o viceversa
%
% Igualmente permite pasar de fuerzas en x,y,z a fuerzas generelizadas
% o viceversa
%
% USO:
%
% Paso de xyz a q  en desplazamientos en 3D:   q=q2xyz(dx,dy,dz)
% Paso de xyz a q  en desplazamientos en 2D:   q=q2xyz(dx,dy)
%
% Paso de xyz a f  en fuerzas en 3D:           f=q2xyz(fx,fy,fz)
% Paso de xyz a f  en fuerzas en 2D:           f=q2xyz(fx,fy)
%
% Paso de q a xyz  en desplazamientos en 3D:   [dx,dy,dz]=q2xyz(q)
% Paso de q a xyz  en desplazamientos en 2D:   [dx,dy]=q2xyz(q)
%
% Paso de f a xyz  en fuerzas en 3D:           [fx,fy,fz]=q2xyz(f)
% Paso de f a xyz  en fuerzas en 2D:           [fx,fy]=q2xyz(f)

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

