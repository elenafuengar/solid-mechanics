%CALCULO DE LA DEFORMADA DE UNA VIGA VERTICAL +
%CALCULO DE TENSIONES A PARTIR DEL PUNTO 5, l�nea 99% 

%1. GENERACI�N DE LOS NODOS Y BARRAS DE LA ESTRUCTURA. 
    %se utiliza la funci�n de anteriores entregas: VigaVertical_X
    [x,y,barras] = VigaVertical_X(1,4,4);
    nodos=[x y];
    
    %Se eliminan los nodos y barras repetidos con la funcion ElementosRepetidos
    [nodos,barras]=ElementosRepetidos(nodos, barras);
    x=nodos(:,1); y=nodos(:,2);
    %Dibujo de la estructura sin deformar: se utiliza la funci�n Representa2D
    Representa2D(x,y,barras,'c');
    
%2. DATOS
    Nn=length(x); %numero de nodos
    Nb=length(barras(:,1));
    Fx=zeros(Nn,1);
    Fy=zeros(Nn,1); Fy(9)=-500; %valor de la fuerza vertical en el nodo 9, -500N
    k=zeros(Nb,1); k=k+10.^6; %valor de la rigidez de las barras

    %Nodos fijos 1 y 2 con 2 gdl cada uno-->4
    fijos=false(Nn,2);
    fijos(1,1)=true;
    fijos(1,2)=true;
    fijos(2,1)=true;
    fijos(2,2)=true;

    %C�lculo de la longitud natural de las barras y su �ngulo
    loo=NaN(Nb,1);
    theta=NaN(Nb,1);
    for i=1:Nb
        a=barras(i,1);
        b=barras(i,2);
        AB=[x(b)-x(a) y(b)-y(a)];
        loo(i)=norm(AB); %calcula el modulo de AB
        theta(i)=atan2(AB(2), AB(1)); %calcula el angulo como la arcotg de cateto op y cateto cont
    end

%3. COMIENZO DEL ENSAMBLAJE
    gdl=2*Nn; %los nodos tienen 2 grados de libertad, mov en x e y
    K=zeros(gdl,gdl); %matriz de rigidez
    f=zeros(gdl,1); %vector de fuerzas nodales

    %Ensamblado de las barras
    for i=1:Nb
        a=barras(i,1);
        b=barras(i,2);
        %Matriz de rigidez elemental
        c=cos(theta(i)); s=sin(theta(i));
        SC=[c^2 s*c; s*c s^2];
        Ke=k(i)*[+SC, -SC; -SC, +SC]; %matriz de rigidez elemental
        ii=[2*(a-1)+1, 2*(a-1)+2, 2*(b-1)+1, 2*(b-1)+2]; %notaci�n local a global
        K(ii,ii)=K(ii,ii)+Ke; %se completa la matriz de rigidez global
    end

    %Correcci�n de la constante de rigidez en los apoyos
    Kmax=max(K(:));
    Kinf=1000*Kmax; %Kinf:una rigidez muy alta para los nodos fijos
    for i=1:Nn
        if fijos(i,1) %gdl en x
            ii=2*(i-1)+1;
            K(ii,ii)=K(ii,ii)+Kinf;
        end
        if fijos(i,2) %gdl en y
            ii=2*(i-1)+2;
            K(ii,ii)=K(ii,ii)+Kinf;
        end
    end

    %Ensamblaje de los nodos
    for i=1:Nn
        %Fuerzas aplicadas
        fe=[Fx(i); Fy(i)];
        %Ensamblaje
        ii=[2*(i-1)+1, 2*(i-1)+2]; %notaci�n local a global
        f(ii)=f(ii)+fe;
    end

%4. RESOLUCI�N DEL PROBLEMA

    q=K\f; %vector desplazamientos

    %obtenci�n de desplazamientos
    dx=NaN(Nn,1);
    dy=NaN(Nn,1);
    for i=1:Nn 
        dx(i)=q(2*(i-1)+1); %notaci�n global a local
        dy(i)=q(2*(i-1)+2);
    end
    AMP=1000; %factor de amplificacion
    dxamp=AMP*dx; 
    dyamp=AMP*dy;

    %Representacion gr�fica de la estructura deformada
    figure
    Representa2D(x+dxamp, y+dyamp, barras, 'c');
    
    
%5. CALCULO DE TENSIONES DE LAS BARRAS tras la deformaci�n

     T=NaN(Nb,1);
 for i=1:Nb
     a=barras(i,1);
     b=barras(i,2);
     AB=[(x(b)+dx(b))-(x(a)+dx(a)), (y(b)+dy(b))-(y(a)+dy(a))]; %Longitud de la barra deformada
     dl=norm(AB)-loo(i); %enlongaci�n que sufre la barra
     T(i)=k(i)*dl;
 end
     %Salida por pantalla de las tensiones
     
     disp(' '); %permite mostrar en pantalla
      fprintf('Barra n�   Tensi�n\n\n'); %cabecera
     for i=1:Nb
      fprintf('%2.0f    %+6.1f N \n\n', i,T(i) );
     end
     
%6. REPRESENTACI�N GR�FICA DE LAS TENSIONES

    %Se representar�n en color azul las barras a tracci�n (tensi�n positiva)
    %en color rojo las barras a compresi�n (tensi�n negativa) y en color verde
    %las barras con tensi�n cercana a cero. Cuanto m�s oscuro sea el color
    %m�s intensa es la tensi�n. 
     
    figure; cmap=jet; %se utiliza como mapa de color el JET 
    Tmax=max(T); % se calcula la T m�xima y la T minima para tomar como referencia
    Tmin=min(T); % a la hora de la asignaci�n de colores
    for i=1:Nb
        a=barras(i,1);
        b=barras(i,2); 
     c=ColorT(Tmin, Tmax, T(i), cmap); %se calcula el color de cada barra mediante la rutina colorT
     plot([x(a)+dxamp(a) x(b)+dxamp(b)], [y(a)+dyamp(a) y(b)+dyamp(b)] , 'color', c); %se representa la barra con ese color
     hold on
    end
     xlabel('X(m)'); ylabel('Y(m)'); grid on; axis equal

%7. REACCIONES EN LOS APOYOS

    Rx=NaN(Nn,1); Ry=NaN(Nn,1); %Se inicializan los vectores de reacciones
    for i=1:Nn
        if fijos(i,1) %gdl en x   %La reacci�n se obtiene multiplicando Kinf por el desplazamiento del nodo.
            Rx(i)=-Kinf*dx(i);    %Solo tendr�n reacciones
        end                       %los nodos que est�n fijos
        if fijos(i,2) %gdl en y   %por lo que se usa la matriz l�gica fijos
            Ry(i)=-Kinf*dy(i);    %para saber qu� nodos son apoyos.
        end
    end
    Reacc=[[1:Nn]' Rx Ry];
