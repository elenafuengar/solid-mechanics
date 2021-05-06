function [nodos2D,elem2D]=Malla2D(Nx,Ny);
    % Genera una malla 2D de elementos 2D de cuatro nodos (rectangulares)
    % 
    % Nx : N�mero de elementos seg�n la direcci�n x
    % Ny : N�mero de elementos seg�n la direcci�n y
    %
    % El tama�o de todos los elementos es 1 m x 1 m
    
    nodos2D=NaN( (Ny+1)*(Nx+1) , 2 );
    elem2D =NaN( Ny*Nx         , 4 );

    % Posiciones de los nodos
    for i=1:(Ny+1), for j=1:(Nx+1)
        nodos2D( Nodo(i,j,Nx) , : )=[ j  i ] ;
    end, end

    % Elementos 
    for i=1:Ny, for j=1:Nx
        elem2D( (i-1)*Nx+j , : )=Nodo( [i i+1 i+1 i],[j j j+1 j+1] , Nx );    
    end, end

end


function k=Nodo(i,j,Nx)
    % Determina el n�mero de nodo k en funci�n de su posci�n (i,j)
    k = (i-1)*(Nx+1)+j ;
end