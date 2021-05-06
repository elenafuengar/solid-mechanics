function [nodos,barras]=Pilar3D(a,b,h,N);
% Construye un pilar vertical, de sección axb y altura h
% formado por n cubos

[ xo,yo,zo,bo ] = Cubo_Unidad;

c=h/N; % Altura de cada cubo
no=[ a*xo b*yo c*zo ];

nodos=no; barras=bo;
for i=2:N
    ni=no; bi=bo;
    ni(:,3)=ni(:,3)+(i-1)*c; % Desplazamiento vertical
    [nodos,barras] = Union( nodos,barras  ,  ni,bi );
end
        