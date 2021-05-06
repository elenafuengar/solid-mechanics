function [nodos,elem]=Malla3D(Nx,Ny,Nz);
    % Genera una malla 3D de elementos 3D de ocho nodos (ladrillos)
    % 
    % Nx : Número de elementos según la dirección x
    % Ny : Número de elementos según la dirección y
    % Nz : Número de elementos según la dirección z
    %
    % El tamaño de todos los elementos es 1 m x 1 m x 1 m
    
    % Se genera inicialmente una malla 2D
    [nodos2D,elem2D]=Malla2D(Nx,Ny);
    
    % Se pasa a 3D
    [nodos,elem]=Paso2Da3D(nodos2D,elem2D,Nz,Nz);
end