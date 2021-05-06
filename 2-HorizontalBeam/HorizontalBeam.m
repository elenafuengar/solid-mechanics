%DEFORMADA DE UNA BARRA HORIZONTAL SOMETIDA A SU PESO

%1. GENERACI�N DE LOS NODOS Y BARRAS DE LA ESTRUCTURA. 
    %se utiliza la funci�n de anteriores entregas: VigaHorizontal_X
    
    [x,y,barras] = VigaHorizontal_X(1,10,10); %Viga 10x1 con 10 cuadrados
    nodos=[x y];
    
    %Se eliminan los nodos y barras repetidos con la funcion ElementosRepetidos
    [nodos,barras]=ElementosRepetidos(nodos, barras);
    x=nodos(:,1); y=nodos(:,2);
    %Dibujo de la estructura sin deformar: se utiliza la funci�n Representa2D
    Representa2D(x,y,barras,'g');
    
%2. DATOS
    g=9.8; %aceleraci�n de la gravedad
    Nn=length(x); %numero de nodos
    Nb=length(barras(:,1));
    Fx=zeros(Nn,1);
    Fy=zeros(Nn,1); %No sufre ninguna fuerza externa
    k=zeros(Nb,1); k=k+10.^6; %valor de la rigidez de las barras
    mb=zeros(Nb); mb=mb+100; %Cada barra pesa 100kg 

    %Nodos fijos 1, 2, 21 y 22 con 2 gdl cada uno-->8
    fijos=false(Nn,2);
    fijos(1,1)=true; fijos(1,2)=true;
    fijos(2,1)=true; fijos(2,2)=true;
    fijos(21,1)=true; fijos(21,2)=true;
    fijos(22,1)=true; fijos(22,2)=true;

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
    M=zeros(gdl,gdl); %matriz de masa
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
        %Matriz de masa
            Me=mb(i)/2*eye(4);
            M(ii,ii)=M(ii,ii)+Me;
        %fuerzas gravitatorias
            fe=[0; -mb(i)*g/2; 0; -mb(i)*g/2]; %aproximamos que cada nodo tiene la mitad
            f(ii)=f(ii)+fe;                    %de la masa de la barra mb
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
        %Fuerzas aplicadas: en este caso ninguna, y no actua la
        %gravitatoria ya que los nodos se consideran sin masa
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
    AMP=5; %factor de amplificacion
    dxamp=AMP*dx; 
    dyamp=AMP*dy;

    %Representacion gr�fica de la estructura deformada
    figure
    Representa2D(x+dxamp, y+dyamp, barras, 'r');
    
    
%5. CALCULO DE TENSIONES DE LAS BARRAS tras la deformaci�n

     T=NaN(Nb,1);
 for i=1:Nb
     a=barras(i,1);
     b=barras(i,2);
     AB=[(x(b)+dx(b))-(x(a)+dx(a)), (y(b)+dy(b))-(y(a)+dy(a))]; %Longitud de la barra deformada
     dl=norm(AB)-loo(i); %enlongaci�n que sufre la barra
     T(i)=k(i)*dl; %Tension de la barra
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
        end                       %los nodos que est�n fijos (1,2,21,22)
        if fijos(i,2) %gdl en y   %por lo que se usa la matriz l�gica fijos
            Ry(i)=-Kinf*dy(i);    %para saber qu� nodos lo est�n
        end
    end
    Reacc=[[1:Nn]' Rx Ry];
    
 %8. SALIDA POR PANTALLA 
     
     %8.1. Desplazamientos
     fid=fopen('Output.txt', 'w'); %genera un archivo txt
    for i=1:Nn %El bucle va escribiendo los datos de los desplazamientos en el txt
        fprintf(fid, 'Nodo %1.0f : dX = %.3f mm dY = %.3f mm\n', i, dx(i)*1000, dy(i)*1000); 
    end
     
     %8.2. Tensiones
     disp(' '); %permite mostrar en pantalla
      fprintf('Barra n�   Tensi�n\n\n'); %cabecera
     for i=1:Nb
      fprintf('%2.0f    %+6.1f N \n\n', i,T(i) );
     end