%ENTREGA 12 EJERCICIO 3%
%En este ejercicio se repite lo calculado en el Ejercicio 1 y 2, con un
%número creciente de elementos por malla, para tabular como varía la
%frecuencia al afinar la malla.
%Se ha usado la función Entrega12Ej3 para que devuelva la frecuencia en funcion del
%numero de elementos escogido. Se representa la evolucion gráficamente, asi
%como el tiempo tardado.

F=[1 2 3 4 5];
Nelem=5*4*2*F.^3;
f=zeros(length(F),1);
t=zeros(length(F),1);

for i=1:length(F)
    tic,[f(i)]=Entrega12Ej3(F(i)); t(i)=toc;
    fprintf('Tiempo tardado %f segundos\n',t(i));
end

figure
%Gráfico Frecuencia-Numero de elementos
subplot(2,1,1);
plot(Nelem,f, 'go',Nelem,f,'--g'); xlabel('Número de elementos'); ylabel('1ª Frecuencia de resonancia');
title('Relación Frecuencia-Mallado'); grid on; 
subplot(2,1,2);
plot(Nelem,t, 'ro',Nelem,t,'--r'); xlabel('Número de elementos'); ylabel('Tiempo tardado (s)');
title('Relación Tiempo-Mallado'); grid on; 
