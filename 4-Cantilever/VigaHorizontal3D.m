function [nodos,barras]=VigaHorizontal3D(a,b,L,N);
% Construye una viga horizontal, paralela al eje X, de sección axb 
% y longitud L formada por n cubos

[no,barras]=Pilar3D(a,b,L,N);

% Se intercambian la x por la z para conseguir la viga horizontal

nodos = [ no(:,3) no(:,2) -no(:,1) ];

