%%%%%%%%%%%%%%%%%%%%%
% Cantilever-Part I %
%%%%%%%%%%%%%%%%%%%%%
%INFO:
%ENG- This program generates a grid model for a cantilever
%   (pillar+horizontal beam) and stores the data in an Excel file
%ESP- Programa que genera un pilar unido a una barra horizontal en 3D
%   y guarda los datos en un excel

%1. GENERACIÓN DE NODOS Y BARRAS
[nodosV,barrasV]=Pilar3D(1,1,9,9);
[nodosH,barrasH]=VigaHorizontal3D(1,1,5,5);
%corrección de las coordenadas de los nodos en la viga horizontal
nodosH(:,3)=nodosH(:,3)+10; 

%2. UNION DE LA ESTRUCTURA

%Rutina que une la estructura y elimina los nodos y barras repetidos
%correctamente reordenados
[nodos,barras]=Union(nodosV,barrasV,nodosH,barrasH);
x=nodos(:,1); y=nodos(:,2); z=nodos(:,3);


%3.RECOPILACION DE DATOS

    %3.1 NODOS

    Nn=length(nodos(:,1)); NumNodo=(1:1:Nn);
    %Matriz fijos: nodos fijos 1,2,3,4
    fijos=false(Nn,3); %3 grados de libertad por cada nodo
        fijos(1,1)=true; fijos(1,2)=true; fijos(1,3)=true; %nodo 1
        fijos(2,1)=true; fijos(2,2)=true; fijos(2,3)=true; %nodo 2
        fijos(3,1)=true; fijos(3,2)=true; fijos(3,3)=true; %nodo 3
        fijos(4,1)=true; fijos(4,2)=true; fijos(4,3)=true; %nodo 4

    mn=zeros(Nn,1);%masa de los nodos
    fx0=zeros(Nn,1); fy0=zeros(Nn,1); fz0=zeros(Nn,1); %fuerzas estáticas
    Fx=zeros(Nn,1); Fy=zeros(Nn,1); Fz=zeros(Nn,1); %fuerzas dinámicas
    w=zeros(Nn,1); %Frecuencia rad/s
    %condiciones iniciales
    x0=zeros(Nn,1); y0=zeros(Nn,1); z0=zeros(Nn,1); %desplazamientos iniciales
    vx0=zeros(Nn,1); vy0=zeros(Nn,1); vz0=zeros(Nn,1);%velocidades iniciales

    %3.2 BARRAS

    Nb=length(barras(:,1)); NumBarras=(1:1:Nb);
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
    k=E*S./loo;   %constante elástica en N/m

%4. ESCRITURA EN EL EXCEL
    Arc='Structure';

    %4.1 EXCRITURA DE LOS NODOS

    %Numeracion
    tNumNodo={'Numeracion'}; xlswrite(Arc,tNumNodo, 'Nodos', 'A1');
    xlswrite(Arc,NumNodo', 'Nodos', 'A2');
    %Coordenadas
    tx={'x (m)'}; ty={'y (m)'}; tz={'z (m)'};
    xlswrite(Arc,tx, 'Nodos', 'B1'); xlswrite(Arc,ty, 'Nodos', 'C1'); xlswrite(Arc,tz, 'Nodos', 'D1');
    xlswrite(Arc,x, 'Nodos', 'B2'); xlswrite(Arc,y, 'Nodos', 'C2'); xlswrite(Arc,z, 'Nodos', 'D2');
    %Matriz fijos
    tfijosx={'¿Fijo x?'}; tfijosy={'¿Fijo y?'}; tfijosz={'¿Fijo z?'};
    xlswrite(Arc,tfijosx, 'Nodos', 'E1'); xlswrite(Arc,tfijosy, 'Nodos', 'F1'); xlswrite(Arc,tfijosz, 'Nodos', 'G1');
    xlswrite(Arc, fijos(:,1) , 'Nodos', 'E2'); xlswrite(Arc, fijos(:,2) , 'Nodos', 'F2'); xlswrite(Arc, fijos(:,3),'Nodos', 'G2');
    %masa
    tmn={'Masa (Kg)'};
    xlswrite(Arc,tmn, 'Nodos', 'H1');
    xlswrite(Arc,mn, 'Nodos', 'H2');
    %Fuerzas estaticas
    tfx0={'Fx,e (N)'}; tfy0={'Fy,e (N)'}; tfz0={'Fz,e (N)'};
    xlswrite(Arc,tfx0, 'Nodos', 'I1'); xlswrite(Arc,tfy0, 'Nodos', 'J1'); xlswrite(Arc,tfz0, 'Nodos', 'K1');
    xlswrite(Arc,fx0, 'Nodos', 'I2'); xlswrite(Arc,fy0, 'Nodos', 'J2'); xlswrite(Arc,fz0, 'Nodos', 'K2');
    %Fuerzas dinámicas
    tFx={'Fx,d (N)'}; tFy={'Fy,d (N)'}; tFz={'Fz,d (N)'};
    xlswrite(Arc,tFx, 'Nodos', 'L1'); xlswrite(Arc,tFy, 'Nodos', 'M1'); xlswrite(Arc,tFz, 'Nodos', 'N1');
    xlswrite(Arc,Fx, 'Nodos', 'L2'); xlswrite(Arc,Fy, 'Nodos', 'M2'); xlswrite(Arc,Fz, 'Nodos', 'N2');
    %Frecuencia
    tw={'Frecuencia (rad/s)'};
    xlswrite(Arc,tw, 'Nodos','O1'); xlswrite(Arc,w, 'Nodos','O2');
    %Condiciones iniciales
    tx0={'dx0 (m)'}; ty0={'dy0 (m)'}; tz0={'dz0 (m)'};
    xlswrite(Arc,tx0, 'Nodos', 'P1'); xlswrite(Arc,ty0, 'Nodos', 'Q1'); xlswrite(Arc,tz0, 'Nodos', 'R1');
    xlswrite(Arc,x0, 'Nodos', 'P2'); xlswrite(Arc,y0, 'Nodos', 'Q2'); xlswrite(Arc,z0, 'Nodos', 'R2');
    tvx0={'Vx0 (m/s)'}; tvy0={'Vy0 (m/s)'}; tvz0={'Vz0 (m/s)'};
    xlswrite(Arc,tvx0, 'Nodos', 'S1'); xlswrite(Arc,tvy0, 'Nodos', 'T1'); xlswrite(Arc,tvz0, 'Nodos', 'U1');
    xlswrite(Arc,vx0, 'Nodos', 'S2'); xlswrite(Arc,vy0, 'Nodos', 'T2'); xlswrite(Arc,vz0, 'Nodos', 'U2');

    %4.2 ESCRITURA DE LAS BARRAS

    %Numeracion 
    tNumBarras={'Nº Barra'};
    xlswrite(Arc,tNumBarras, 'Barras', 'A1');
    xlswrite(Arc,NumBarras', 'Barras', 'A2');
    %Nodos inicial y final
    tbarra1={'Nodo inicial'}; tbarra2={'Nodo final'}; 
    xlswrite(Arc,tbarra1, 'Barras', 'B1'); xlswrite(Arc,tbarra2, 'Barras', 'C1');
    xlswrite(Arc, barras(:,1), 'Barras', 'B1'); xlswrite(Arc, barras(:,2), 'Barras', 'C1');
    %Masa
    tmb={'Masa (Kg)'};
    xlswrite(Arc,tmb, 'Barras', 'D1'); xlswrite(Arc,mb, 'Barras', 'D2');
    %Constante elástica
    tk={'k (N/m)'};
    xlswrite(Arc,tk, 'Barras', 'E1'); xlswrite(Arc,k, 'Barras', 'E2');
    %Longitud de la barra
    tloo={'loo (m)'};
    xlswrite(Arc,tloo, 'Barras', 'F1'); xlswrite(Arc,loo, 'Barras', 'F2');


