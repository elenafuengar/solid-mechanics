%TRABAJO FINAL DE LA ASIGNATURA%

% Se desea estudiar el comportamiento estático y dinámico de una placa cuadrada (lado de longitud
% L = 10 m ) de poliuretano, situada en posición horizontal, que posee un agujero cilíndrico central de
% diámetro D = 6 m en el cual se ha embutido un cilindro de aluminio de diámetro interior
% d = 5,6 m , . El perímetro de la placa se encuentra empotrado (es decir, los puntos de las caras
% laterales de la placa no pueden moverse).
% El espesor de la placa es H=0,5 m.
% Sobre la placa, además de su propio peso, actúa una fuerza vertical descendente de valor
% F = 50 kN aplicada en el punto de coordenadas ( +d/2,0,+H ).

disp(' '); disp('PARTE I: MALLADO'); disp(' ');

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% PARTE I: MALLADO %%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%

% A)GENERAR LA MALLA DE LA PLACA

    %Datos de la geometría:
    L=10; D=6; d=5.6; H=0.5;
    Nnod=60;  %numero de nodos por cuadrante
    Ncapas=6; %numero de capas entre borde interior y exterior
    Nfilas=4; %numero de filas en el mallado 3D

    %Mallado de la placa cuadrada
    [xL,yL]=Poligono( 4, Nnod, pi/4 );    %Devuelve un cuadrado de lado unidad
    xL=xL*L*sqrt(2)/2; yL=yL*L*sqrt(2)/2; %Ajuste a coordenadas de la placa
    [xD,yD]=Poligono( Nnod , Nnod , 0 );        %Devuelve un circulo de radio unidad
    xD=xD*D/2;  yD=yD*D/2;                %Ajuste al circulo ext de la placa
    [NodPlaca2D, ElePlaca2D]=Corona2D( [xD yD] , [xL yL] , Ncapas ); %mallado 2D
    [Nodos1,Elem1]=Paso2Da3D(NodPlaca2D, ElePlaca2D,H, Nfilas);      %Paso a 3D

    %Mallado del agujero
    [xd,yd]=Poligono( Nnod , Nnod , 0 );  %Devuelve un circulo de radio unidad
    xd=xd*d/2;  yd=yd*d/2;                %Ajuste al circulo int de la placa
    [NodAgu2D, EleAgu2D]=Corona2D( [xd yd] , [xD yD] , 1 ); %mallado 2D
    [Nodos2,Elem2]=Paso2Da3D(NodAgu2D, EleAgu2D, H, Nfilas);  %Paso a 3D
    
    %Union de la malla
    [Nodos,Elem]=UnirLadrillos(Nodos1,Elem1,Nodos2,Elem2);
    x=Nodos(:,1); y=Nodos(:,2); z=Nodos(:,3); %coordenadas
    [Nn,nada]=size(Nodos); %nº nodos
    [Ne,nada]=size(Elem);  %nº barras
      
% B)DATOS DE NODOS Y ELEMENTOS

    %Fuerza estática en el nodo ( +d/2,0,+H )
    F=50e+3; Fe=zeros(Nn,3);       %inicialización de la matriz y la fuerza
    ii=find(x==d/2 & y==0 & z==H); %se busca el nodo
    Fe(ii,3)=-F;                   %se asigna la fuerza, vertical descendente

    %Datos de los materiales
    ro=ones(Ne,1); E=ones(Ne,1); nu=ones(Ne,1);
    %1. Placa de poliuretano
    E1 = 100e6;        % Modulo de Young (unidades SI, Pa)
    nu1= 0.30;         % Coeficiente de Poisson
    ro1= 35;           % Densidad, en kg/m3
    [Ne1,nada]=size(Elem1); %nº elem de la placa
    ro(1:Ne1,:)=ro1*ro(1:Ne1,:); 
    E(1:Ne1,:)=E1*E(1:Ne1,:); 
    nu(1:Ne1,:)=nu1*nu(1:Ne1,:);

    %2.Agujero de aluminio
    E2 = 70e9;         % Modulo de Young (unidades SI, Pa)
    nu2= 0.33;         % Coeficiente de Poisson
    ro2= 2700;         % Densidad, en kg/m3
    [Ne2,nada]=size(Elem2); %nº elem del agujero
    ro(Ne1+1:(Ne1+Ne2),:)=ro2*ro(Ne1+1:(Ne1+Ne2),:); 
    E(Ne1+1:(Ne1+Ne2),:)=E2*E(Ne1+1:(Ne1+Ne2),:); 
    nu(Ne1+1:(Ne1+Ne2),:)=nu2*nu(Ne1+1:(Ne1+Ne2),:);
    
% C)CONDICIONES DE CONTORNO
    %Nodos Fijos: el perímetro de la placa--> 4 caras
    fijos=0*Nodos; 
    cara1= Nodos(:,1)<=-5; fijos(cara1,:)=1;
    cara2= Nodos(:,1)>=4.99; fijos(cara2,:)=1;
    cara3= Nodos(:,2)<=-5; fijos(cara3,:)=1;
    cara4= Nodos(:,2)>=5; fijos(cara4,:)=1;
fprintf('La malla usada tiene %.0f nodos y %.0f elementos\n',Nn,Ne); 
    
% D)ESCRITURA EN EL EXCEL
tic;
    arc_xls='Output.xlsx';
    dos( ['copy Plantilla.xlsx ' arc_xls] );

    % Pestaña nodos
    data= [ [1:Nn]' Nodos fijos zeros(Nn,1) Fe zeros(Nn,10)];
    xlswrite(arc_xls,data,'nodos','A4');

    % Pestaña elem
    data=[ [1:Ne]' Elem ro E nu ];
    xlswrite(arc_xls,data,'elem','A2');
time=toc; fprintf('La escritura en el excel tarda %.2f segundos\n',time); 

%E)REPRESENTACIÓN GRÁFICA
% tic;
%     RepresentaLadrillos(Nodos,Elem);
%     ii=find( prod(fijos,2)==1 );
%     hold on
%     plot3(Nodos(ii,1),Nodos(ii,2),Nodos(ii,3),'ro'); hold off;
%     title('Mallado 60x6x4');
% time=toc; disp(sprintf('La representación gráfica tarda %.2f segundos',time));   

%  RepresentaLadrillos(Nodos2,Elem2);        %Representación gráfica del agujero
%  Representa2DCuad(NodAgu2D, EleAgu2D);     %Malla del agujero en 2D
%  Representa2DCuad(NodPlaca2D, ElePlaca2D); %Malla de la placa en 2D
%  RepresentaLadrillos(Nodos1,Elem1);        %Representación gráfica de la placa

disp(' '); disp('PARTE II: ESTÁTICA'); disp(' ');

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PARTE II: ESTÁTICA %%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%

% F) MASA DE LA PLACA 

    %Datos para el ensamblado
    g=9.8; % Aceleración de la gravedad
    mn    = zeros(Nn,1);    % Masas nodales puntuales (cero siempre): Nn
    Fno   = Fe;             % Fuerzas nodales estáticas:              Nnx3
    Fnd   = zeros(Nn,3);    % Fuerzas nodales dinámicas:              Nnx3
    wd    = zeros(Nn,1);    % Frecuencias de las fuerzas dinámicas:   Nn
    dRo   = zeros(Nn,3);    % Desplazamientos nodales iniciales:      Nnx3
    Vo    = zeros(Nn,1);    % Velocidades iniciales iniciales:        Nnx3
    %Inicialización de matrices
    N  = 3*Nn;       % Número de grados de libertad
    K = zeros(N,N); % Inicialización de la matriz de rigidez global 
    M = zeros(N,N); % Inicialización de la matriz de masa global 
    fo = zeros(N,1); % Vector de fuerzas nodales estáticas
    fd = zeros(N,1); % Vector de fuerzas nodales dinámicas

    for e=1:Ne % Bucle a lo largo de todos los elementos
               % Se ensamblan las matrices elementales de rigidez y masa

        % Coordenadas de los nodos del elemento
        ne=Nodos(Elem(e,:),:);

        % Matrices de Rigidez (Ke) y Masa (Me) elementales 
        % junto con las fuerzas gravitatorias
        [Ke,Me,Fge]=Ladrillo8(ne,ro(e),E(e),nu(e));

        % Numeración global de grados de libertad del elemento
        ii=[];
        for k=1:length(Elem(e,:))
            ii=[ ii    3*(Elem(e,k)-1)+[1 2 3] ];
        end

        % Ensamblaje de la matriz de rigidez (suma)
        K(ii,ii) = K(ii,ii) + Ke;
        % Ensamblaje de la matriz de masa (suma)
        M(ii,ii) = M(ii,ii) + Me;
        % Ensamblaje del vector de fuerzas estaticas (suma)
        fo(ii) = fo(ii) + Fge ;

    end % Fin del bucle a lo largo de las barras

    for i=1:Nn % Bucle a lo largo de todos los nodos
               % Se ensamblan las fuerzas nodales estáticas y dinámicas
        ii=(i-1)*3+[1 2 3];
        Fgn=[0 0 -mn(i)*g]';
        fo(ii)=fo(ii)+Fno(i,:)'+Fgn;
        fd(ii)=fd(ii)+Fnd(i,:)';
    end

    %Aplicación de las condiciones de contorno a los nodos fijos. Se va a
    %suponer que poseen una constante elástica muy grande (kinf), pero no infinita
    kmax=max(abs(K(:)));
    kinf=1000*kmax;
    for i=1:Nn % Bucle a lo largo de todos los nodos
        % ¿ Está fijo el nodo según eje X ?
        if fijos(i,1)==1
            j=3*(i-1)+1;         % Idenficador del grado de libertad
                                 % en numeración globlal
            K(j,j)=K(j,j)+kinf;  % Se ensambla el apoyo "elástico"
        end
        % ¿ Está fijo el nodo según eje Y ?
        if fijos(i,2)==1
            j=3*(i-1)+2;         % Idenficador del grado de libertad
                                 % en numeración globlal
            K(j,j)=K(j,j)+kinf;  % Se ensambla el apoyo "elástico"
        end
        % ¿ Está fijo el nodo según eje Z ?
        if fijos(i,3)==1
            j=3*(i-1)+3;         % Idenficador del grado de libertad
                                 % en numeración globlal
            K(j,j)=K(j,j)+kinf;  % Se ensambla el apoyo "elástico"
        end
    end
    
    %Calculo de la masa y el error
    MasaPlaca=sum(diag(M))/3;
    MasaReal=(10*10-pi*D^2/4)*0.5*ro1+pi/4*(D^2-d^2)*0.5*ro2;
    Error=abs((MasaReal-MasaPlaca)/MasaReal)*100;
    fprintf('La masa de la placa es %.4f kg\n', MasaPlaca);
    fprintf('El error cometido es %.4f%%\n', Error);
    
% G)DEFORMADA DE LA PLACA
    q=K\fo; %vector desplazamientos
    %Representación gráfica de la deformada
    %RepresentaLadrillos(nodos,CarasExt,BarrasExt,NodosExt,q ) 
    
% H) DESPLAZAMIENTOS EN EL NODO DONDE SE APLICA LA FUERZA
    [dx,dy,dz]=q2xyz(q); %Obtención de desplazamientos en cada cordenada
    ii=find(x==d/2 & y==0 & z==H); %se busca el nodo
    Ax=dx*1000; Ay=dy*1000; Az=dz*1000; %se pasan a milímetros
    fprintf('Desplazamientos del nodo %.0f: dx=%+.4f mm, dy=%+.4f mm, dz=%+.4f mm\n', ii,Ax(ii),Ay(ii),Az(ii));

% I)MÁXIMO DESPLAZAMIENTO VERTICAL dz
    [dz_max,ii]=max(abs(dz)); %Se obtiene el desplazamiento maximo y su índice
    fprintf('El máximo desplazamiento vertical: Nodo %.0f, dz=-%.4f mm\n', ii, dz_max*1000);
    
disp(' '); disp('PARTE III: DINÁMICA'); disp(' ');

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PARTE III: DINÁMICA %%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% J)10 PRIMEROS MODOS NORMALES DE VRIBRACIÓN Y SUS FRECUENCIAS
    %La frecuencia de resonancia se obtiene hallando los valores propios de A=K/M
    [V,D]=eigs(K,M, 10,'SM'); %se han tomado las 10 primeras frecuencias
    %Las frecuencias propias w son las raices de los valores propios
    w=sqrt(diag(D)); 
    %Ordenacion de resultados en frecuencias crecientes
    [w,ii]=sort(w); %en ii se guardan las posiciones de w sin ordenar
    V=V(:,ii);      %Se reordena la matriz V de la misma manera que w
    f=w/2/pi;       %Se pasa a Hz

% K)SALIDA POR PANTALLA
disp('Las frecuencias de resonancia son:');
    for i=1:10
        fprintf('Frecuencia %.0f = %.1f Hz\n',i,f(i));
    end

% % L)REPRESENTACIÓN DE LOS MODOS DE VIBRACIÓN 1,4,5,6,10
%     [CarasExt,BarrasExt,NodosExt,Caras,Barras,TN]=CarasBarras(Elem);
%     tic;
%     %MODO 1
%     i=1;
%     RepresentaLadrillosModo(Nodos,CarasExt,V(:,i),'ModoNormal-1');
%     %MODO 4
%     i=4;
%     RepresentaLadrillosModo(Nodos,CarasExt,V(:,i),'ModoNormal-4');
%     %MODO 5
%     i=5;
%     RepresentaLadrillosModo(Nodos,CarasExt,V(:,i),'ModoNormal-5');
%     %MODO 6
%     i=6;
%     RepresentaLadrillosModo(Nodos,CarasExt,V(:,i),'ModoNormal-6');
%     %MODO 10
%     i=10;
%     RepresentaLadrillosModo(Nodos,CarasExt,V(:,i),'ModoNormal-10');
% 
%     time=toc; disp(sprintf('La representación de los modos ha tardado %.3f segundos',time));
