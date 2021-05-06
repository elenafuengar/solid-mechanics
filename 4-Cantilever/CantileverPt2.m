%%%%%%%%%%%%%%%%%%%%%%
% Cantilever-Part II %
%%%%%%%%%%%%%%%%%%%%%%
%INFO:
%ENG- This program calculates the stiffness matrix & displacements on the
%   Cantilever generated in Pt1, when a vertical forze of 4840N is appled in
%   node 57 (coords (5,0,10)
%ESP- sobre la estructura del ejercicio 1, actua una fuerza vertical descendente
%   de módulo 4840 sobre las coordenadas (5,0,10)--> nodo 57. Este programa
%   obtiene y representa la deformada ante esa fuerza.

%1. DATOS DEL PROBLEMA

%Generacion de nodos y barras
[nodosV,barrasV]=Pilar3D(1,1,9,9);
[nodosH,barrasH]=VigaHorizontal3D(1,1,5,5);
%corrección de las coordenadas de los nodos en la viga horizontal
nodosH(:,3)=nodosH(:,3)+10; 
%union de la estructura
[nodos,barras]=Union(nodosV,barrasV,nodosH,barrasH);
x=nodos(:,1); y=nodos(:,2); z=nodos(:,3);

    %1.1 NODOS

    Nn=length(nodos(:,1)); 
    %Matriz fijos: nodos fijos 1,2,3,4
    fijos=false(Nn,3); %3 grados de libertad por cada nodo
        fijos(1,1)=true; fijos(1,2)=true; fijos(1,3)=true; %nodo 1
        fijos(2,1)=true; fijos(2,2)=true; fijos(2,3)=true; %nodo 2
        fijos(3,1)=true; fijos(3,2)=true; fijos(3,3)=true; %nodo 3
        fijos(4,1)=true; fijos(4,2)=true; fijos(4,3)=true; %nodo 4

    mn=zeros(Nn,1);%masa de los nodos
    fx0=zeros(Nn,1); fy0=zeros(Nn,1); fz0=zeros(Nn,1); %fuerzas estáticas
    fz0(57)=-4840; %En el nodo 57 actúa la fuerza vertical descendente

    %1.2 BARRAS

    Nb=length(barras(:,1)); 
    E=210e+9; %modulo elastico en pascales
    S=200e-6; %area en m
    ro=7.8; %kg/m3
    %Calculo de longitud de las barras
    loo=NaN(Nb,1); 
    for i=1:Nb
        a=barras(i,1); b=barras(i,2); %numero de nodos de inicio y fin
        AB=[x(b)-x(a) y(b)-y(a) z(b)-z(a)];   %vector entre nodos
        loo(i)=norm(AB);            %distancia entre nodos
    end
    mb=S*ro*loo; %masa de las barras en Kg
    k=E*S./loo;  %constante elástica en N/m

%2. ENSAMBLAJE

    %Inicializacion
    g = 9.7995;
    N = 3*Nn;       % Número de grados de libertad
    K = zeros(N,N); % Inicialización de la matriz de rigidez global
    M = zeros(N,N); % Inicialización de la matriz de masa global
    fo= zeros(N,1); % Iniciacilización del vector de fuerzas estaticas

    % Paso de información en formato matriz Nnx3 a vector de dimensión 3Nn
    fno = q2xyz(fx0,fy0,fz0);

    %Ensamblaje

    for i=1:Nb % Bucle a lo largo de todas las barras
               % Se ensamblan las matrices elementales de rigidez y masa
               % y los vectores elementales de fuerzas

        a   = barras(i,1);  % Nodo A
        b   = barras(i,2);  % Nodo B

        Ra  = nodos(a,:);   % Coordenadas del nodo A de la barra 
        Rb  = nodos(b,:);   % Coordenadas del nodo B de la barra 

        %esta es la linea que llama al elemento finito que utilizamos
        [Ke,Me,Fge,Fke]=Barra3D(Ra,Rb,k(i),mb(i),loo(i));

        % Numeración global de grados de libertad de la barra
        ii = [ 3*(a-1)+[1 2 3]    3*(b-1)+[1 2 3] ];

        % Ensamblaje de la matriz de rigidez (suma)
        K(ii,ii) = K(ii,ii) + Ke;
        % Ensamblaje de la matriz de masa (suma)
        M(ii,ii) = M(ii,ii) + Me;
        % Ensamblaje del vector de fuerzas estaticas (suma)
        fo(ii) = fo(ii) + Fge + Fke;

    end % Fin del bucle a lo largo de las barras


    for i=1:Nn % Bucle a lo largo de los nodos
               % Se ensamblan las fuerzas aplicadas en los nodos
               % y las matrices de masa nodales

        % Numeración global de grados de libertad del nodo
        ii = 3*(i-1)+[1 2 3];
        % Ensamblaje de matriz nodal de masa
        Mn = mn(i)*eye(3); 
        M(ii,ii) = M(ii,ii) + Mn;
        % Ensamblaje de las fuerzas nodales estaticas
        fo(ii) = fo(ii) + fno(ii) + [ 0 ; 0 ; -mn(i)*g ];


    end        % Fin del bucle sobre los nodos

    %Condiciones de contorno
    kmax=max(abs(K(:)));
    kinf=1000*kmax;

    for i=1:Nn % Bucle a lo largo de todos los nodos
        % ¿ Está fijo el nodo según eje X ?
        if fijos(i,1)
            j=3*(i-1)+1;         % Idenficador del grado de libertad
                                 % en numeración globlal
            K(j,j)=K(j,j)+kinf;  % Se ensambla el apoyo "elástico"
        end
        % ¿ Está fijo el nodo según eje Y ?
        if fijos(i,2)
            j=3*(i-1)+2;         % Idenficador del grado de libertad
                                 % en numeración globlal
            K(j,j)=K(j,j)+kinf;  % Se ensambla el apoyo "elástico"
        end
        % ¿ Está fijo el nodo según eje Z ?
        if fijos(i,3)
            j=3*(i-1)+3;         % Idenficador del grado de libertad
                                 % en numeración globlal
            K(j,j)=K(j,j)+kinf;  % Se ensambla el apoyo "elástico"
        end
    end
    
%3. RESOLUCION DEL PROBLEMA

q=K\fo; %vector desplazamientos
[dx,dy,dz]=q2xyz(q); %paso de q a dx, dy, dz
AMP=50; %factor de amplificacion

%4. REPRESENTACION GRÁFICA DE LA DEFORMADA

dnodos=NaN(Nn,3); %matriz de nodos de la deformada
dnodos(:,1)=x+AMP*dx; dnodos(:,2)=y+AMP*dy; dnodos(:,3)=z+AMP*dz;
Representa3D(dnodos, barras); title('Deformada - Amp x50');

%5. CALCULO DE TENSIONES DE LAS BARRAS 

     T=NaN(Nb,1);
     %Se le quita la amplificacion para el calculo de tensiones
     dnodos(:,1)=x+dx; dnodos(:,2)=y+dy; dnodos(:,3)=z+dz;
 for i=1:Nb
     a=barras(i,1); b=barras(i,2);
     Ra  = dnodos(a,:);   % Coordenadas del nodo A de la barra deformada 
     Rb  = dnodos(b,:);   % Coordenadas del nodo B de la barra deformada
     AB=Rb-Ra;       % Vector del nodo A al B
     lo=norm(AB);    % Distancia entre nodos
     dl=lo-loo(i);   %alargamiento de la barra
     T(i)=k(i)*dl;
 end

%Representacion gráfica
Representa3DT(nodos,barras,T); title('Representacion de las tensiones');

