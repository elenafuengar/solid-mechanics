function [nodos,elem]=UnirLadrillos(n1,e1,n2,e2);
% Une las estructuras de Ladrillos (8 nodos) {n1,e1} y {n2,e2}
% guardando el resultado en {nodos,elem}

% Se unen las dos esctructuras renumerando los nodos de {n2,e2}
[no,nada]=size(n1);  % Número de nodos en la estructura {n1,e1}
n3=[ n1 ; n2    ];
e3=[ e1 ; e2+no ];

% Se buscan nodos repetidos, se eliminan y se renumeran.

% Se determina la tolerancia por debajo de la cual dos nodos se consideran
% el mismo
dmax=max(n3)-min(n3); dmax=norm(dmax); dmax=dmax/length(e3(:,1))^(1/3);
tol=dmax*1e-5;

no=length(n3(:,1)); % Número de nodos
for i=1:no
    for j=(i+1):no
        if norm(n3(i,:)-n3(j,:))<tol
            % El nodo está repetido
            ii=find(e3(:)==j);
            e3(ii)=i;  % Se renombra
            % Se elimina
            n3(j,:)=NaN;
        end
    end
end


% Se se construye una nueva matriz de nodos donde las dos primeras
% son el número nuevo y el número antiguo
ii=find(isfinite(n3(:,1)));
N=[ [1:no]' n3 ];
N=N(ii,:);
no=length(N(:,1));
N=[ [1:no]' N ];

% Se renumeran los nodos en e3
for i=1:no
    if not(N(i,1)==N(i,2))
        ii=find(e3(:)==N(i,2));
        e3(ii)=N(i,1);
    end
end

nodos=N(:,3:end);
elem=e3;


