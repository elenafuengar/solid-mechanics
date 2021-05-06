% Lectura y Ensamblaje (datos en archivos .XLS)

close all, fclose all; % clear all

g=9.8; % Aceleraci�n de la gravedad

if not(exist('NombreArchivo'));
    NombreArchivo='PlacaAgujero.xlsx';
end

% Lectura de la pesta�a "nodos"
data=xlsread(NombreArchivo,'nodos');

nodos = data(:, 2: 4);      % Coordenadas de los nodos:               Nnx3
Fijos = data(:, 5: 7);      % Nodos fijos (=1):                       Nnx3
mn    = data(:,  8  );      % Masas nodales puntuales (cero siempre): Nn
Fno   = data(:, 9:11);      % Fuerzas nodales est�ticas:              Nnx3
Fnd   = data(:,12:14);      % Fuerzas nodales din�micas:              Nnx3
wd    = data(:, 15  )*2*pi; % Frecuencias de las fuerzas din�micas:   Nn
dRo   = data(:,16:18);      % Desplazamientos nodales iniciales:      Nnx3
Vo    = data(:,19:21);      % Velocidades iniciales iniciales:        Nnx3

% Lectura de la pesta�a "elem"
data=xlsread(NombreArchivo,'elem');

elem=data(:,2:9); % Matriz de conectividad de los ladrillos: Nex8 
ro  =data(:,10);  % Densidades de los elementos:             Ne
E   =data(:,11);  % M�dulos de elasticidad:                  Ne
nu  =data(:,12);  % Coeficientes de Poisson:                 Ne

% Se obtiene las caras, barras y nodos externos
[CarasExt,BarrasExt,NodosExt,Caras,Barras]=CarasBarras(elem);

% Representaci�n gr�fica de la estructura sin deformar
RepresentaLadrillos(nodos,CarasExt,BarrasExt,NodosExt )

% Representaci�n de los nodos fijos
ii=find( prod(Fijos,2)==1 );
figure(1), hold on
plot3(nodos(ii,1),nodos(ii,2),nodos(ii,3),'ro');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                                                                    %%%
%%% ENSAMBLAJE                                                         %%%
%%%                                                                    %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[Nn,nada] = size(nodos);  % Numero de nodos
[Ne,nada] = size(elem);   % Numero de elementos

N  = 3*Nn;       % N�mero de grados de libertad
    
                          %%%%%%%%%%%%%%
MatricesDispersas=true;   %%% OPCION %%%
                          %%%%%%%%%%%%%%
if MatricesDispersas
    K = sparse(N,N); % Inicializaci�n de la matriz de rigidez global
                     % como matriz dispersa
    M = sparse(N,N); % Inicializaci�n de la matriz de masa global 
                     % como matriz dispersa
else
    K  = zeros(N,N); % Inicializaci�n de la matriz de rigidez global
    M  = zeros(N,N); % Inicializaci�n de la matriz de masa global
end
fo = zeros(N,1); % Vector de fuerzas nodales est�ticas
fd = zeros(N,1); % Vector de fuerzas nodales din�micas

for e=1:Ne % Bucle a lo largo de todos los elementos
           % Se ensamblan las matrices elementales de rigidez y masa
   
    % Coordenadas de los nodos del elemento
    ne=nodos(elem(e,:),:);
    
    % Matrices de Rigidez (Ke) y Masa (Me) elementales 
    % junto con las fuerzas gravitatorias
    [Ke,Me,Fge]=Ladrillo8(ne,ro(e),E(e),nu(e));
        
    % Numeraci�n global de grados de libertad del elemento
    ii=[];
    for k=1:length(elem(e,:))
        ii=[ ii    3*(elem(e,k)-1)+[1 2 3] ];
    end
    
    % Ensamblaje de la matriz de rigidez (suma)
    K(ii,ii) = K(ii,ii) + Ke;
    % Ensamblaje de la matriz de masa (suma)
    M(ii,ii) = M(ii,ii) + Me;
    % Ensamblaje del vector de fuerzas estaticas (suma)
    fo(ii) = fo(ii) + Fge ;
    
end % Fin del bucle a lo largo de las barras

for i=1:Nn % Bucle a lo largo de todos los nodos
           % Se ensamblan las fuerzas nodales est�ticas y din�micas
    ii=(i-1)*3+[1 2 3];
    Fgn=[0 0 -mn(i)*g]';
    fo(ii)=fo(ii)+Fno(i,:)'+Fgn;
    fd(ii)=fd(ii)+Fnd(i,:)';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                                                                    %%%
%%% APLICACI�N DE LAS CONDICIONES DE CONTORNO                          %%%
%%%                                                                    %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Para la aplicaci�n de las condiciones de contorno se va a suponer
% que los cimientos poseen una constante el�stica muy grande (kinf),
% pero no infinita.
%
% � Como se fija el valor de kinf ?
% Se busca el mayor valor absoluto de las componentes Kij de la matriz
% de rigidez y se multiplica ese valor por un n�mero grande (1000 en este
% caso)
kmax=max(abs(K(:)));
kinf=1000*kmax;

for i=1:Nn % Bucle a lo largo de todos los nodos
    % � Est� fijo el nodo seg�n eje X ?
    if Fijos(i,1)==1
        j=3*(i-1)+1;         % Idenficador del grado de libertad
                             % en numeraci�n globlal
        K(j,j)=K(j,j)+kinf;  % Se ensambla el apoyo "el�stico"
    end
    % � Est� fijo el nodo seg�n eje Y ?
    if Fijos(i,2)==1
        j=3*(i-1)+2;         % Idenficador del grado de libertad
                             % en numeraci�n globlal
        K(j,j)=K(j,j)+kinf;  % Se ensambla el apoyo "el�stico"
    end
    % � Est� fijo el nodo seg�n eje Z ?
    if Fijos(i,3)==1
        j=3*(i-1)+3;         % Idenficador del grado de libertad
                             % en numeraci�n globlal
        K(j,j)=K(j,j)+kinf;  % Se ensambla el apoyo "el�stico"
    end
end




