function RepresentaLadrillos(nodos,CarasExt,BarrasExt,NodosExt,q )
% Representa una estructura formada por ladrillos
%
% Variables de entrada:
%    - nodos:    matriz de dimensiones Nnx3 con las coordenadas X,Y,Z
%                de todos los nodos
%    - CarasExt: matriz de conectividad de las caras exteriores
%    - BarrasExt: matriz de conectividad de las aristas exteriores
%    - NodosExt: vector con los nodos exteriores
%
%    - q:        vector de desplazamientos (opcional). 


    figure; % Se crea una nueva figura
    
    % Coordenadas cartesianas de los nodos
    x=nodos(:,1); y=nodos(:,2); z=nodos(:,3);
    
    if nargin==2 % Si solo se pasan dos elementos se supone que son simplemente nodos y elem
        elem=CarasExt; % En el lugar de CarasExt (2� argumento) se ha pasado elem
        [CarasExt,BarrasExt,NodosExt,Caras,Barras,TN]=CarasBarras(elem);
    end
    
    if nargin>4
        % Selecci�n de la amplificaci�n para el modo
        %
        % 1ro. Tama�o de la estructura
        xmax=max(x); xmin=min(x); ymax=max(y); ymin=min(y);  zmax=max(z); zmin=min(z);
        D = sqrt( (xmax-xmin)^2 + (ymax-ymin)^2 + (zmax-zmin)^2 );

        % M�ximo desplazamiento 
        qmax=max(abs(q(:)));

        cte=0.1;        % Amplitud m�xima del modo ya amplificada en tanto por uno
                        % respecto al tama�o de la estructura
        Amp=cte*D/qmax; % Factor de amplificaci�n
        
        % Se desplazan las coordenadas de los nodos
        [dx dy dz]=q2xyz(q);
        x = x + Amp*dx;
        y = y + Amp*dy;
        z = z + Amp*dz;
        nodos=[x y z];
    end
 

    nb=length(BarrasExt(:,1)); % N�mero de barras exteriores

    for i=1:nb % Dibujo de las barras exteriores
        ii=BarrasExt(i,:);
        plot3(x(ii),y(ii),z(ii),'b','LineWidth',2); hold on
    end

    
    % Dibujo de los nodos exteriores de la estructura
    ii=NodosExt;
    DibujarNodos=false;
    if DibujarNodos
            plot3(x(ii),y(ii),z(ii),'go');
    end
    
    EscribirNumeros=false;
    if EscribirNumeros
        for k=1:length(ii)
            text(x(ii(k)),y(ii(k)),z(ii(k)),sprintf('%1.0f',ii(k)));
        end
    end
  



    % Dibujo de las caras exteriores
    Opcion='PATCH';
    switch Opcion
        case 'TRISURF'
            % Cada cara (romboide) se transforma en dos triangulos
            Triang=[ CarasExt(:,[1 2 3]) ; CarasExt(:,[3 4 1]) ];
            trisurf(Triang,x,y,z);
            shading interp
            colorbar
        case 'PATCH'
            co=[1.0000    0.7812    0.4975]; % Color cobre
            % co=[1 1 1 ];
            for i=1:length(CarasExt(:,1)) % Bucle a lo largo de todas las caras
                ii=CarasExt(i,:);
                patch( nodos(ii,1),nodos(ii,2),nodos(ii,3),co);
            end
            camlight
            lighting phong
    end

    axis equal, axis on, grid on
    xlabel('X(m)'); ylabel('Y(m)'); zlabel('Z(m)');
    if nargin>4
        title(sprintf('Deformada ante las fuerzas est�ticas - Amplificaci�n x %.0f',Amp));
    end
end

