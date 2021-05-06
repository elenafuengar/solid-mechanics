%ENTREGA 12 EJERCICIO 3%
%En este ejercicio se repite lo calculado en el Ejercicio 1 y 2, con un
%n�mero creciente de elementos por malla, para tabular como var�a la
%frecuencia al afinar la malla.
%Se ha usado la funci�n Entrega12Ej3 para que devuelva la frecuencia en funcion del
%numero de elementos escogido. Se representa la evolucion gr�ficamente, asi
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
%Gr�fico Frecuencia-Numero de elementos
subplot(2,1,1);
plot(Nelem,f, 'go',Nelem,f,'--g'); xlabel('N�mero de elementos'); ylabel('1� Frecuencia de resonancia');
title('Relaci�n Frecuencia-Mallado'); grid on; 
subplot(2,1,2);
plot(Nelem,t, 'ro',Nelem,t,'--r'); xlabel('N�mero de elementos'); ylabel('Tiempo tardado (s)');
title('Relaci�n Tiempo-Mallado'); grid on; 
