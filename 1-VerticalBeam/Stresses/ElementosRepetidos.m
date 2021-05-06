function [nodos_new, barras_new]=ElementosRepetidos (nodos, barras)

%Elimina los nodos y las barras repetidas

%Detección y eliminación de nodos repetidos
T = 0.001;
nodos = T*round(nodos/T);
[nodos_new, inew, iold] = unique(nodos, 'rows', 'stable');
viejo = [];

%Matriz con nodos nuevos y viejos que hay que sustituir en las barras
for i = 1:length(nodos)
    if isempty(find(inew == i))
        viejo = [viejo; i];
    end
end

viejo2 = inew-[1:length(inew)]';
ii = find(viejo2 ~= 0);
jj = inew(ii);

sust = [iold(viejo) viejo; ii jj];

%Sustitución de nodos no repetidos en las barras

barras_new = barras;
for i = 1: length(sust)
    ii = find(barras == sust(i, 2));
    barras_new (ii) = sust(i, 1);
end

%Detección y eliminación de barras reptidas
barras_new=sort(barras_new, 2);
barras_new=unique(barras_new, 'rows', 'stable');

end