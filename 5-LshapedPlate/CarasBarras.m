function [CarasExt,BarrasExt,NodosExt,Caras,Barras,TN]=CarasBarras(Elem);
% CarasBarras devuelve las matrices de conectividad de:
%    - la caras exteriores, en la matriz CarasExt
%    - las aristas exteriores, en la matriz BarrasExt
%    - los nodos exteriores, en el vector NodosExt
%    - todas las caras (interiores y exteriores), en la matriz Caras
%    - todas las caras (interiores y exteriores), en la matriz Barras
%
% En la variable de entrada Elem se le pasa la matriz de conectividad
% de los elementos tipo LADRILLO
%
% Nota: esta rutina solo es v�lida para elementos tipo LADRILLO
%
% Sintaxis:
%    [CarasExt,BarrasExt,NodosExt,Caras,Barras,TN]=CarasBarras(Elem);


Caras  = [];          % Inicializaci�n de la matriz Caras
Barras = [];          % Inicializaci�n de la matriz Barras  
[Ne,nada]=size(Elem); % N�mero de elementos
for e=1:Ne
    % Nodos
    a1 = Elem(e,1);
    b1 = Elem(e,2);
    c1 = Elem(e,3);
    d1 = Elem(e,4);
    a2 = Elem(e,5);
    b2 = Elem(e,6);
    c2 = Elem(e,7);
    d2 = Elem(e,8);
    % Barras
    bar = [ b1 a1 ; a1 d1 ; d1 c1 ; c1 b1 ;  ... % Cara inferior
            b2 a2 ; a2 d2 ; d2 c2 ; c2 b2 ;  ... % Cara superior
            a1 a2 ; b1 b2 ; c1 c2 ; d1 d2 ];     % Aristas laterales
    Barras = [ Barras ; bar ];
    % Caras
    Caras = [ Caras; b1 a1 d1 c1 ;  ... Cara inferior
                     b2 a2 d2 c2 ;  ... Cara superior
                     b1 b2 a2 a1 ;  ... Caras laterales
                     a1 a2 d2 d1 ;  ...
                     d1 d2 c2 c1 ;  ...
                     c1 c2 b2 b1 ] ;
end

% Caras  = unique(Caras,'rows');  % Se eliminan las caras repetidas

% Detecci�n de las caras externas (que se marcan con signo negativo);
caras=sort(Caras,2);
for i=1:size(Caras,1)
    c=caras(i,1);
    ii=find(ismember(caras,c));
    if length(ii)>1
        Caras(i,:)=-Caras(i,:);
    end
end

clear caras; % Esta variable ya no se utiliza mas

Caras = unique(Caras,'rows');   % Se eliminan las caras repetidas
ii=find(Caras(:,1)<0);   % las caras con nodos negativos son externas
CarasExt = -Caras(ii,:); % Caras externas
Caras    = abs(Caras);   % Todas las caras (ya con nodos positivos)

Barras = unique(Barras,'rows'); % Se eliminan las barras repetidas

% En la variable TN se guarda el tipo de nodo: exterior (1) o interior (0)
Nn=max(Elem(:));          % N�mero de nodos
TN=NaN*zeros(Nn,1);       % Tipo de nodo
for i=1:Nn
    ii=find(CarasExt(:)==i); % Aparciones del nodo i en las caras exteriores
    if length(ii)>0
        TN(i)=1;
    else
        TN(i)=0;
    end
end



BarrasExt=[]; % Inicializaci�n de la matriz de barras exteriores
for i=1:length(Barras(:,1))
    % Si todos los nodos son exteriores, sus TNs ser�n todos 1
    % y, por tanto, su producto ser� 1
    %
    % En el caso de que alg�n nodo no sea exterior su TN ser� cero
    % y el producto de todos los TNs ser� cero.
    %
    % Basta con que un nodo sea interior para que la barra sea interior.
    
    Ext=prod( TN(Barras(i,:)) );
    if Ext==1 % Si la cara es exterior se a�ade a CarasExt
        BarrasExt=[BarrasExt ; Barras(i,:) ];
    end
end
 
NodosExt=find(TN==1); % Nodos exteriores

