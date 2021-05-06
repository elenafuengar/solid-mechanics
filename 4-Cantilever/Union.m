function [nodos,barras]=Union(n1,b1,n2,b2);
% Une las estructuras {n1,b1} y {n2,b2}
% devolviendo el resultado en {nodos,barras}
%
% Notas:
%   - Se renombran adecuadamente los nodos
%   - Se eliminan barras y nodos repetidos

% Uni�n de las estructuras renumerando los nodos de la segunda
% (falta por elminar nodos y barras repetidas)
nodos  = [ n1;n2 ];
barras = [ b1 ; length(n1(:,1))+b2 ];

% Tolerancia por debajo de la cual dos nodos se consideran el mismo
% En una estructura de 10 m, una variaci�n de 1 mm se considerada
% despreciable, es decir, en t�rminos relativos T = 1E-4
Tol=1e-4;

MaxL = norm( max(nodos)-min(nodos) ); % Diagonal del volumen donde 
                                      % se encuentra la estructura
T=Tol*MaxL;

% Eliminaci�n de nodos repetidos
Nn=length(nodos(:,1));
nodos = [ [1:Nn]' nodos ];  % Se a�ade una columna a la matriz nodos
                            % con el n�mero de nodo inicial
for i=1:Nn
    for j=(i+1):Nn
        d=norm( nodos(i,2:end)-nodos(j,2:end) );
        if d<T % Detecci�n de nodos repetidos
            ii = find( barras==j );   
            barras(ii)=i;   % Se renombran los nodos en la matriz barras
            nodos(j,:)=NaN; % Se vac�a el nodo j en la matriz nodos
        end
    end
end

% Ordenaci�n de los nodos de las barras de modo que el nodo A
% posea un �ndice inferior al nodo B
barras=sort(barras,2);

% Eliminaci�n de las barras repetidas
barras=unique(barras,'rows');


% Se crea una nueva matriz NODOS que contiene la siguiente informaci�n 
% (por columnas):
% Nuevo N�mero del Nodo   -  Antiguo Numero del Nodo - X - Y  ( - Z )

ii=find(isfinite(nodos(:,1)));
Nn=length(ii);
nodos=[ [1:Nn]' nodos(ii,:) ];


% Renombrado de los nodos
for i=1:Nn
    new=nodos(i,1);
    old=nodos(i,2);
    if not( new==old )
        ii = find( barras==old );
        barras(ii)=new; % Se renombran los nodos en la matriz barras
    end
end

% Se eliminan las dos primeras columnas de nodos
nodos=nodos(:,3:end);

