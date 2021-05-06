%ENTREGA 12 VOLUNTARIA, EJERCICIO 2%
%En este programa se lee el archivo malla.xls generado en el Ej1
%se ensambla la estructura y se aplican las condiciones de contorno,
%se determina la primera frecuencia de resonancia y representa el primer
%modo normal de vibraci�n

close all, clear all, fclose all;

%1. LECTURA DEL ARCHIVO malla.xls
NombreArchivo='malla.xlsx';
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

%2. ENSAMBLADO
[Nn,nada]=size(nodos); %n� nodos
[Ne,nada]=size(elem);  %n� barras
N  = 3*Nn;       % N�mero de grados de libertad
              
K = sparse(N,N); % Inicializaci�n de la matriz de rigidez global
                     % como matriz dispersa
M = sparse(N,N); % Inicializaci�n de la matriz de masa global 
                     % como matriz dispersa
fo = zeros(N,1); % Vector de fuerzas nodales est�ticas

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

%3. CONDICIONES DE CONTORNO

%Fijaci�n de Kinf para los nodos fijos
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

%4. 1� FRECUENCIA DE RESONANCIA

%La frecuencia de resonancia se obtiene hallando los valores propios de A=K/M
[V,D]=eigs(K,M, 5,'sm'); %se han tomado 5 frecuencias
%Las frecuencias propias w son las raices de los valores propios
w=sqrt(diag(D)); f=w/2/pi;
[fmin,imin]=min(f);%se halla la frecuencia m�nima
disp(sprintf('Primera Frecuencia Natural = %4.2f Hz',fmin));

%5. PRIMER MODO NORMAL 
%representaci�n est�tica
[CarasExt,BarrasExt,NodosExt,Caras,Barras,TN]=CarasBarras(elem);
%RepresentaLadrillos(nodos,CarasExt,BarrasExt,NodosExt,V(:,imin) )
%Representaci�n en gif
RepresentaLadrillosModo(nodos,CarasExt,V(:,imin),'Primer-Modo');