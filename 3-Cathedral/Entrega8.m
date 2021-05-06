%EJERCICIO TAREA 8: REGIMEN TRANSITORIO DE CATEDRAL.XLS

%1. LECTURA DEL EXCEL

    arc='Catedral.xls';
    TablaNodos  = xlsread(arc,'nodos');  
    TablaBarras = xlsread(arc,'barras');

    %1.1 Datos de los nodos
    x     = TablaNodos(:,2);    % Coordenadas X (en metros) de los nodos
    y     = TablaNodos(:,3);    % Coordenadas Y (en metros) de los nodos
    nodos=[x y];
    Fijos = TablaNodos(:,8:9);  % Nodos fijos
    Nn    = length(x);      % Número de nodos

    w     = TablaNodos(1,12);   % Frecuencia angular de las fuerzas dinámicas, en rad/s
    fxd   = TablaNodos(:,10);   % Fuerza dinámica horizontal (según X) aplicada en el nodo (en N)
    fyd   = TablaNodos(:,11);   % Fuerza dinámica vertical   (según Y) aplicada en el nodo (en N)

    %1.1.1. Condiciones inciales
    dxo   = TablaNodos(:,13);   % Desplazamientos horizontales de los nodos en t=0 (en m)
    dyo   = TablaNodos(:,14);   % Desplazamientos verticales de los nodos en t=0 (en m)
    Vxo   = TablaNodos(:,15);   % Velocidades horizontales de los nodos en t=0 (en m/s)
    Vyo   = TablaNodos(:,16);   % Velocidades verticales de los nodos en t=0 (en m/s)

    %1.2 Datos de las barras
    barras = TablaBarras(:,2:3); % Matriz de conectividad de las barras
    mb     = TablaBarras(:,5);   % Masa de la baras (en kg)
    k      = TablaBarras(:,6);   % Constante elástica de las barras, en N/m
    loo    = TablaBarras(:,7);   % Longitud natural de las barras, en m
    Tmax   = TablaBarras(:,8);   % Tensión máxima admisible de las barras;
    Nb     = length(k);      % Número de barras

    g=9.7995; %Constante gravitatoria segun el CEM
    
%2. ENSAMBLAJE
    N=2*Nn; %Grados de libertad, dos por cada nodo
    K = zeros(N,N); % Inicialización de la matriz de rigidez global
    M = zeros(N,N); % Inicialización de la matriz de masa global
    f = zeros(N,1); % Iniciacilización del vector de fuerzas global

    for i=1:Nb % Bucle a lo largo de todas las barras
               % Se ensamblan las matrices elementales de rigidez
               % y los vectores elementales de fuerzas
        a  = barras(i,1); % Nodo A de la barra 
        b  = barras(i,2); % Nodo B de la barra 
        AB = [ x(b)-x(a) ; y(b)-y(a) ];     % Vector AB
        lo = norm(AB);    % Longitud de la barra en la posición del dibujo
        t  = atan2(AB(2),AB(1));            % Angulo de la barra con la horizontal
        s  = sin(t); c  = cos(t);           % Seno y coseno

        A  = [ c^2 s*c ; s*c s^2 ] ;        % Submatriz A Ke = k*[ A -A; - A A]
        Ke = k(i)*[ A -A ; -A A ];          % Matriz de rigidez elemental

        A  = eye(2)/3;                      % Submatriz A Me = m*[ A A/2 ; A/2 A ]
        Me = mb(i)*[ A A/2 ; A/2 A ];       % Matriz de masa elemental

        fe = 0.5*mb(i)*g*[ 0 -1 0 -1 ]';    % Vector elemental de fuerzas gravitatorias

        % Numeración global de grados de libertad de la barra
        ii = [ 2*(a-1)+1 2*(a-1)+2 2*(b-1)+1 2*(b-1)+2 ];

        % Ensamblaje de la matriz de rigidez (suma)
        K(ii,ii) = K(ii,ii) + Ke;
        % Ensamblaje de la matriz de masa (suma)
        M(ii,ii) = M(ii,ii) + Me;
        % Ensamblaje del vector de fuerzas (suma)
        f(ii) = f(ii) + fe;
    end % Fin del bucle a lo largo de las barras

    %No es necesario realizar el ensamblaje de los nodos puesto que las masas 
    %y las fuerzas estaticas sobre los nodos son nulas. 

%3. CONDICIONES DE CONTORNO

    % Para la aplicación de las condiciones de contorno se va a suponer
    % que los cimientos poseen una constante elástica muy grande (kinf),
    % pero no infinita.
    Kmax=max(K(:));
    Kinf=1000*Kmax; 

    for i=1:Nn % Bucle a lo largo de todos los nodos
        % ¿ Está fijo el nodo según la horizontal (eje X) ?
        if Fijos(i,1)==1
            j=2*(i-1)+1;         % Idenficador del grado de libertad
                                 % en numeración globlal
            K(j,j)=K(j,j)+Kinf;  % Se ensambla el apoyo "elástico"
        end
        % ¿ Está fijo el nodo según la horizontal (eje Y) ?
        if Fijos(i,2)==1
            j=2*(i-1)+2;         % Idenficador del grado de libertad
                                 % en numeración globlal
            K(j,j)=K(j,j)+Kinf;  % Se ensambla el apoyo "elástico"
        end
    end


%4. ANALISIS REGIMEN TRANSITORIO

    %4.1. Valores y vectores propios
    
        A=M\K;         %Mediante la funcion eig, se obtiene la matriz D diagonal
        [V,D]=eig(A);  %con los valores propios y V matriz de vectores propios

        w=sqrt(diag(D)); %Las frecuencias propias w son las raices de 
                         %los valores propios, en rad/s

        %Ordenacion de resultados en frecuencias crecientes
        [w,ii]=sort(w); %en ii se guardan las posiciones de w sin ordenar
        V=V(:,ii);      %Se reordena la matriz V de la misma manera que w
        freq=w/2/pi;    %frecuencias propias en Hz
        %Las 3 frecuencias de vibración más bajas serán las de índices 1,2 y 3
        %tras la ordenación.

    %4.2 REPRESENTACION DE LOS 3 PRIMEROS NODOS NORMALES, en Hz

        %Primer modo: i=1
            i=1;
            freq_i=freq(i); %frecuencia normal 1 en Hz
            vi=V(:,i);      %frecuencia normal 1 en rad/s
            Representa2Dmodo(x,y,barras,vi,'ModoNormal-1');
            title(sprintf('Modo de Vibracion i=%1.0f  fi=%6.2f Hz',i,freq_i));

        %Segundo modo: i=2  
            i=2;
            freq_i=freq(i); %frecuencia normal 2 en Hz
            vi=V(:,i);      %frecuencia normal 2 en rad/s
            Representa2Dmodo(x,y,barras,vi,'ModoNormal-2');
            title(sprintf('Modo de Vibracion i=%1.0f  fi=%6.2f Hz',i,freq_i));

        %Tercer modo: i=3  
            i=3;
            freq_i=freq(i); %frecuencia normal 3 en Hz
            vi=V(:,i);      %frecuencia normal 3 en rad/s
            Representa2Dmodo(x,y,barras,vi,'ModoNormal-3');
            title(sprintf('Modo de Vibracion i=%1.0f  fi=%6.2f Hz',i,freq_i));    

    %4.3.DESPLAZAMIENTOS EN RÉGIMEN TRANSITORIO

        %Aplicacion de las condiciones iniciales

        %Desplazamientos en t=0
        dqo=NaN(2*Nn,1); %se pasa a notacion condensada
        dqo(1:2:(2*Nn-1))=dxo; %desplazamientos en x, impares
        dqo(2:2:(2*Nn))=dyo;   %desplazamientos en y, pares

        %Velocidades en t=0
        vqo=NaN(2*Nn,1); %Se pasa a notacion condensada
        vqo(1:2:(2*Nn-1))=Vxo; %Velocidades en x, impares
        vqo(2:2:(2*Nn))=Vyo;   %Velocidades en y, pares

        % Se busca una solución del tipo: qi(t) = vi*( ci*cos(wi*t) + si*sin(wi*t))
        c=V\dqo;         %consante de coswt: amplitudes del coswt
        d=V\vqo; s=d./w; %constante de senwt: amplitudes del senwt

        %Calculo de la matriz de desplazamientos Q

        t=[0:0.001:1]; %tiempo con resolucion de milisegundos
        Q=zeros(N, length(t)); %Inicializacion de la matriz de desplazamientos
        for i=1:N
            vi=V(:,i); %frecuencia normal i
            Q= Q + vi*c(i)*cos(w(i)*t) + vi*s(i)*sin(w(i)*t); %Matriz desplazamientos
        end
%         figure %Representacion gráfica
%         Representa2Dmov(x,y,barras,Q,'Desplazamientos Reg.Transitorio');

    % 4.4. DESPLAZAMIENTOS DEL NODO 299 Y DEL NODO 793

        % Nodo 299, vertice de la catedral
        i=299; %Desplazamientos del nodo 299, se extraen de Q
        qix=Q(2*(i-1)+1,:); %notacion global a local
        qiy=Q(2*(i-1)+2,:);
        figure
        plot(t,qix, 'c', t, qiy, 'm'); grid on; xlabel('Tempo (s)'); 
        ylabel('Desplazamiento qi (m)'); title('Desplazamiento del nodo 299');
        legend('qx', 'qy');

        % Nodo 793, punto de impacto
        i=793; %Desplazamientos del nodo 793, se extraen de Q
        qix=Q(2*(i-1)+1,:); %notacion global a local
        qiy=Q(2*(i-1)+2,:);
        figure
        plot(t,qix, 'b', t, qiy, 'r'); grid on; xlabel('Tempo (s)'); 
        ylabel('Desplazamiento qi (m)'); title('Desplazamiento del nodo 793');
        legend('qx', 'qy');
        
    %4.5. TRAYECTORIAS DE LOS NODOS 299 y 793
    
        % Nodo 299, vertice de la catedral
        i=299; figure;
        qix=Q(2*(i-1)+1,:); %Desplazamientos de x e y extraidos de Q
        qiy=Q(2*(i-1)+2,:); %Se pasa de notación global a local
        for j=1:(length(t)-1)
        plot( [x(i)+qix(j) x(i)+qix(j+1)],[y(i)+qiy(j) y(i)+qiy(j+1)], 'm'); 
        hold on
        end
        plot(x(i),y(i),'ko'); %nodo inicial en negro
        grid on; xlabel('x + qx (m)'); ylabel('y + qy (m)');
        title('Trayectoria del nodo 299');
        
        
        % Nodo 793, punto de impacto
        i=793; figure;
        qix=Q(2*(i-1)+1,:); %Desplazamientos de x e y extraidos de Q
        qiy=Q(2*(i-1)+2,:); %Se pasa de notación global a local
        for j=1:(length(t)-1)
        plot( [x(i)+qix(j) x(i)+qix(j+1)],[y(i)+qiy(j) y(i)+qiy(j+1)], 'r'); 
        hold on
        end
        plot(x(i),y(i),'ko'); %nodo inicial en negro
        grid on; xlabel('x + qx (m)'); ylabel('y + qy (m)');
        title('Trayectoria del nodo 793');
        
    %4.6 DEFORMADA EN ti=1s (i=1000)
    
        i=1000; q=Q(:,i);  
        dx=q(1:2:(2*Nn-1)); 
        dy=q(2:2:(2*Nn));
        Amp=5000;
        figure
        % Representacion de las barras
        [Nb,nada]=size(barras);
        for i=1:Nb
            j=barras(i,:);
            plot( x(j)+Amp*dx(j) , y(j)+Amp*dy(j) ,'g' );grid on; xlabel('Tempo (s)'); 
            ylabel('Desplazamiento qi(m)'); title('Deformada en t=1, Amp x5000');
            hold on
        end
        % Representacion de los nodos
        plot( x+Amp*dx,y+Amp*dy ,'g.' );
        
          
        