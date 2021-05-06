%ENTREGA 12 VOLUNTARIA EJ 1%
%Este programa genera una estructura en L, guarda los datos 
%de sus nodos y elementos en un excel, aplica las condiciones de contorno 
%y representa la figura

%1. GENERACION DE LA MALLA
[nodos1,elem1]=Malla3D(5,4,2);%submalla
nodos1(:,1)=nodos1(:,1)-1; nodos1(:,2)=nodos1(:,2)-1;  %para que empiece en (0,0,0)
elem2=elem1; nodos2=nodos1; nodos2(:,2)=nodos2(:,2)+4; %trasladado de malla 2
elem3=elem1; nodos3=nodos1; nodos3(:,1)=nodos3(:,1)+5; %trasladado de malla 3

%2. UNION DE LA MALLA
[nodos,elem]=UnirLadrillos(nodos1,elem1,nodos2,elem2);
[nodos,elem]=UnirLadrillos(nodos,elem,nodos3,elem3);
nodos(:,3)=nodos(:,3)/2; %ajusta la altura de la figura
x=nodos(:,1); y=nodos(:,2); z=nodos(:,3); %coordenadas
[Nn,nada]=size(nodos); %nº nodos
[Ne,nada]=size(elem);  %nº barras

%3. CONDICIONES DE CONTORNO E INICIALES

%Datos del material
ro=35 ; %densidad en kg/m3
E=100e6; %módulo elástico en Pa
nu=0.30; %coeficiente de poisson

%Nodos Fijos: los de las caras laterales
Fijos=0*nodos;    
[CarasExt,BarrasExt,NodosExt,Caras,Barras,TN]=CarasBarras(elem);
%El vector NodosExt nos da los indices de los nodos que estan en las caras
%exteriores de la figura. Los nodos fijos son los de las caras
%perpendiculares al plano XY-->6 caras
ii=NodosExt;
cara1=find(nodos(ii,1)==0); Fijos(cara1,:)=1;
cara2=find(nodos(ii,2)==0); Fijos(cara2,:)=1;
for i=5:10;
cara3=find(nodos(ii,2)==4 & nodos(ii,1)==i); Fijos(cara3,:)=1;
end
for i=4:8;
cara4=find(nodos(ii,1)==5 & nodos(ii,2)==i); Fijos(cara4,:)=1;
end
cara5=find(nodos(ii,2)==8); Fijos(cara5,:)=1;
cara6=find(nodos(ii,1)==10); Fijos(cara6,:)=1;

%Velocidad inicial, en el nodo (2,2,1): vz=1m/s
ii=find(nodos(:,1)==2 & nodos(:,2)==2 & nodos(:,3)==1);
Vo=zeros(Nn,3); Vo(ii,3)=1; %se escirbe la velociad en el nodo

%4. ESCRITURA EN EL EXCEL

arc_xls='malla.xlsx';
dos( ['copy Plantilla.xlsx ' arc_xls] );

% Pestaña nodos
data= [ [1:Nn]' nodos Fijos zeros(Nn,11) Vo ];
xlswrite(arc_xls,data,'nodos','A4');

% Pestaña elem
data=[ [1:Ne]' elem ro*ones(Ne,1) E*ones(Ne,1) nu*ones(Ne,1) ];
xlswrite(arc_xls,data,'elem','A2');

%5. REPRESENTACIÓN GRÁFICA
RepresentaLadrillos(nodos,CarasExt,BarrasExt,NodosExt)
% Representación de los nodos fijos
ii=find( prod(Fijos,2)==1 );
figure(1), hold on
plot3(nodos(ii,1),nodos(ii,2),nodos(ii,3),'ro');
