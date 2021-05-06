function [ x,y,t ] = Poligono( Nlad , Nnod , rot )
%Poligono devuelve las coordenadas x,y de
%   los nodos de un pol�gono regular de radio unidad de Nlad lados
%   y Nnod nodos en total
%
%   Tambi�n devuelve la coordenada angular t de los puntos en radianes
%
%   Si Nnod no es m�ltiplo de Nlad, se fuerza a que lo sea
%
%   Si se pasa el par�metro rot, el pol�gono se rota rot radianes en
%   sentido antihorario

if nargin<3
    rot=0;
end

if Nnod<Nlad
    Nnod=Nlad;
end

n=round(Nnod/Nlad); % N�mero de tramos por cada lado
x=[]; y=[];
e=([1:n]'-1)/n;
for i=1:Nlad
    % Puntos inicial y final del lado del pol�gono
    ta=(i-1)*2*pi/Nlad;
    tb=  i  *2*pi/Nlad;
    xa=cos(ta); ya=sin(ta);
    xb=cos(tb); yb=sin(tb);
    xi = xa + e*(xb-xa);
    yi = ya + e*(yb-ya);
    % Coordenadas de los n nodos a lo largo del lado 
    x=[x;xi];
    y=[y;yi];
end


% Aplicaci�n del giro
G = [cos(rot) -sin(rot) ;
     sin(rot)  cos(rot) ];
R = G*[x';y'];
x = R(1,:)';
y = R(2,:)';

t=atan2(y,x);

[tmin,imin]=min(abs(t)); % Punto mas cercano al eje X
ii=circshift([1:length(t)]',-(imin-1));



% Se ordenan en sentido creciente de t
t=t(ii);
x=x(ii);
y=y(ii);

