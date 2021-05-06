%CALCULO DE LA DEFORMADA DE UNA VIGA VERTICAL%

%1. GENERACIÓN DE LOS NODOS Y BARRAS DE LA ESTRUCTURA. 
    %se utiliza la función de anteriores entregas: VigaVertical_X
    [x,y,barras] = VigaVertical_X(1,4,4);
    nodos=[x y];
    
    %Se eliminan los nodos y barras repetidos con la funcion ElementosRepetidos
    [nodos,barras]=ElementosRepetidos(nodos, barras);
    x=nodos(:,1); y=nodos(:,2);
    
    %Dibujo de la estructura sin deformar: se utiliza la función Representa2D
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

    %Cálculo de la longitud natural de las barras y su ángulo
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
        ii=[2*(a-1)+1, 2*(a-1)+2, 2*(b-1)+1, 2*(b-1)+2]; %notación local a global
        K(ii,ii)=K(ii,ii)+Ke; %se completa la matriz de rigidez global
    end

    %Corrección de la constante de rigidez en los apoyos
    Kmax=max(K(:));
    Kinf=1000*Kmax; %rigidez muy alta para los nodos fijos
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
        ii=[2*(i-1)+1, 2*(i-1)+2]; %notación local a global
        f(ii)=f(ii)+fe;
    end

%4. RESOLUCIÓN DEL PROBLEMA

    q=K\f; %vector desplazamientos

    %obtención de desplazamientos
    dx=NaN(Nn,1);
    dy=NaN(Nn,1);
    for i=1:Nn 
        dx(i)=q(2*(i-1)+1); %notación global a local
        dy(i)=q(2*(i-1)+2);
    end
    AMP=1000; %factor de amplificacion
    dxamp=AMP*dx; 
    dyamp=AMP*dy;

    %Representacion gráfica 
    figure
    Representa2D(x+dxamp, y+dyamp, barras, 'c');

%5. SALIDA POR PANTALLA
    fid=fopen('Output.txt', 'w'); %genera un archivo txt llamado salida
    for i=1:Nn %El bucle va escribiendo los datos de los desplazamientos en el txt
        fprintf(fid, 'Nodo %1.0f : dX = %.3f mm dY = %.3f mm\n', i, dxamp(i), dyamp(i)); 
    end


