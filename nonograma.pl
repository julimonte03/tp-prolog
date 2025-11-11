% Ejercicio 1
% matriz(+F, +C,-M)

matriz(0, _, []). 
 % generamos una fila de C elementos y despues el resto de la matriz
matriz(F, C, [N|XS]) :- columna(C,N), matriz(G,C,XS), F is G+1.

% columna(+C,-M) auxiliar
columna(0,[]).
columna(C,[_|XS]):- columna(N, XS), C is N+1.
 
% Ejercicio 2
%replicar(+Elem, +N, -Lista)

% replicar(a,3,L) -> L = [a,a,a]
replicar(_, 0, []).
replicar(X, N, [X|XS]) :- replicar(X, M, XS), N is M+1. 
 
% Ejercicio 3
% transponer(+M, -MT)
transponer([], []). 
transponer([[]|_], []) :- !. % si ya no hay más columnas
% saca las cabezas de cada fila y sigue con las colas
transponer(M, [C|MT]) :- cabezasYColas(M,C,Resto), transponer(Resto, MT). 
 
% cabezasYColas(+Fila,-Primeros,-Colas)
cabezasYColas([],[],[]).
cabezasYColas([[X|XS]|YS], [X|ZS], [XS|TS]):-
	cabezasYColas(YS, ZS, TS).

% Predicado dado armarNono/3
armarNono(RF, RC, nono(M, RS)) :-
	length(RF, F),
	length(RC, C),
	matriz(F, C, M),
	transponer(M, Mt),
	zipR(RF, M, RSFilas),
	zipR(RC, Mt, RSColumnas),
	append(RSFilas, RSColumnas, RS).

zipR([], [], []).
zipR([R|RT], [L|LT], [r(R,L)|T]) :- zipR(RT, LT, T).

% Ejercicio 4
% pintadasValidas(+R)
% R = r(Res, Celdas)
% Caso base: sin bloques => todo 'o'

pintadasValidas(r([], Celdas)) :-
    length(Celdas, N),
    replicar(o, N, Celdas).
% caso rec
pintadasValidas(r([B|Bs], Celdas)) :-
    length(Celdas, N),
    sum_list(Bs, SumR),   % espacio libre antes del primer bloque            
    length(Bs, K),
    SepR is max(0, K - 1),           
    MaxAntes is N - (B + SepR + SumR),
    MaxAntes >= 0,
    between(0, MaxAntes, OsAntes),     % probamos con distintas cantidades de 'o'
    colocarOs(OsAntes, Celdas, R1),  
    colocarXs(B, R1, R2),            
    poner_sep(K, R2, R3),            
    pintadasValidas(r(Bs, R3)).

% poner_sep(+K, +LIn, -LOut) 
poner_sep(0, L, L).
poner_sep(K, LIn, LOut) :-
    K > 0,
    colocarOs(1, LIn, LOut).


% colocarOs(+N, +L, -R)
% pone N 'o's al principio de la lista
colocarOs(0, L, L).
colocarOs(N, [C|Cs], R) :-
    N > 0,
    C = o,
    N1 is N - 1,
    colocarOs(N1, Cs, R).
% colocarXs(+N, +L, -R)
% pone N 'x' al principio (el bloque pintado)
colocarXs(0, L, L).
colocarXs(N, [C|Cs], R) :-
    N > 0,
    C = x,
    N1 is N - 1,
    colocarXs(N1, Cs, R).


% Ejercicio 5
% resolverNaive(+NN) 
resolverNaive(nono(_M,Res)) :-  
        maplist(pintadasValidas, Res).

% Ejercicio 6
% pintarObligatorias(+R)
pintarObligatorias(r(Res, Celdas)):-
    length(Celdas, N),
    findall(L, (length(L, N) , pintadasValidas(r(Res, L))), Soluciones),
    combinarSoluciones(Soluciones, Celdas).
% si una celda es igual en todas, se mantiene si no, queda libre
combinarSoluciones([Ult], Ult).
combinarSoluciones([S1, S2| Resto], Resultado):-
    combinarListas(S1, S2, Combi),
    combinarSoluciones([Combi | Resto], Resultado).

combinarListas([], [], []).
combinarListas([H1|T1], [H2|T2], [HResultado | TResultado]):-
    combinarCelda(H1, H2, HResultado),
    combinarListas(T1, T2, TResultado).

% Predicado dado combinarCelda/3
combinarCelda(A, B, _) :- var(A), var(B).
combinarCelda(A, B, _) :- nonvar(A), var(B).
combinarCelda(A, B, _) :- var(A), nonvar(B).
combinarCelda(A, B, A) :- nonvar(A), nonvar(B), A = B.
combinarCelda(A, B, _) :- nonvar(A), nonvar(B), A \== B.

% Ejercicio 7
% deducir1Pasada(+NN)
deducir1Pasada(nono(Filas,Columnas)) :-
maplist(pintarObligatorias, Filas),
maplist(pintarObligatorias, Columnas).

% Predicado dado
cantidadVariablesLibres(T, N) :- term_variables(T, LV), length(LV, N).

% Predicado dado
deducirVariasPasadas(NN) :-
	NN = nono(M,_),
	cantidadVariablesLibres(M, VI), % VI = cantidad de celdas sin instanciar en M en este punto
	deducir1Pasada(NN),
	cantidadVariablesLibres(M, VF), % VF = cantidad de celdas sin instanciar en M en este punto
	deducirVariasPasadasCont(NN, VI, VF).

% Predicado dado
deducirVariasPasadasCont(_, A, A). % Si VI = VF entonces no hubo más cambios y frenamos.
deducirVariasPasadasCont(NN, A, B) :- A =\= B, deducirVariasPasadas(NN).

% Ejercicio 8
 %nono(Matriz, Restricciones)

restriccionConMenosLibres(NN, R) :-
	NN = nono(_, Res), %r(Bloques, Celdas)
    member(R, Res), % agarramos una restricción candidata R
    R = r(_, L),        % agarro su lista de celdas L
    cantidadVariablesLibres(L, N),
    N > 0,
	%ya teneemos las vars libres de R, y ahora 
	%vemos que no existe OTRA restriccion en Res tal tenga menos celdas sin decidir
    not(( member(OTRA, Res),
          OTRA \== R,
          OTRA = r(_, L2),
          cantidadVariablesLibres(L2, N2),
          N2 > 0,
          N2 < N )).

% Ejercicio 9
resolverDeduciendo(NN) :-
    deducirVariasPasadas(NN), 
    cantidadVariablesLibres(NN, 0),
    !.

resolverDeduciendo(NN):-
    deducirVariasPasadas(NN),
    restriccionConMenosLibres(NN, R),
    pintadasValidas(R),
    resolverDeduciendo(NN).


% Ejercicio 10
solucionUnica(nono(M, Res)) :- 
    findall(M, resolverNaive(nono(M,Res)), Soluciones),
    length(Soluciones, N),
    N =:= 1.

% Ejercicio 11 – 
 
tam(N, (F, C)) :-
	% generamos la matriz M del nonograma N
    nn(N, nono(M, _)),     
	% contamos las filas
    length(M, F),          
    M = [PrimeraFila|_],   % agarramos la primera fila y contamos sus columnas
	length(PrimeraFila, C).
 
 
% Consultas:
%   Para obtener el tamaño de cada nonograma -> ?- tam(N, T).
%   Para verificar si tiene una única solución -> ?- nn(N, NN), solucionUnica(NN).
%   Para verificar si se puede deducir sin backtracking -> ?- nn(N, NN), resolverDeduciendo(NN).

% Resultados

% N | Tamaño | ¿Solución única? | ¿Deducible sin backtracking? 

% 0 | 2×3    
% 1 | 5×5    
% 2 | 5×5    
% 3 | 10×10  
% 4 | 5×5    
% 5 | 5×5    
% 6 | 5×5    
% 7 | 10×10  
% 8 | 10×10  
% 9 | 5×5    
% 10| 5×5    
% 11| 10×10  
% 12| 15×15  
% 13| 11×5   
% 14| 4×4    
 
%Comentarios: La consulta de tamanio anda bien pero las otras no. El 9 se cuelga y el 10 no se cuelga, pero no devuelve false. cuando debería 
%o sea, muestra algun nono siempre.
% Lamentablemente no llegamos a encontrar errores a tiempo para hacer las consultas  “solución única” y “deducible sin backtracking” 

%Ejercicio 12: Reversibilidad
% Queremos ver replicar(+Elem, -N, -Lista)
% ->  nunca termina por el segundo argumento.
% Vemos que pasa cuando ....
%
% replicar(+Elem, +N, -Lista) funciona bien:
%   ?- replicar(a, 3, L).
%   L = [a, a, a].
%
% Tambien  replicar(+Elem, -N, +Lista):
%   ?- replicar(a, N, [a, a, a]).
%   N = 3.
%
% Pero replicar(+Elem, -N, -Lista) no funciona:
%   ?- replicar(a, N, L).
%   entra en backtracking infinito.
%
% Esto es porque la recursión no está acotada ya que intenta generar
% listas de cualquier longitud sin límite, por lo tanto no termina nunca.
 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                              %
%    Ejemplos de nonogramas    %
%        NO MODIFICAR          %
%    pero se pueden agregar    %
%                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Fáciles
nn(0, NN) :- armarNono([[1],[2]],[[],[2],[1]], NN).
nn(1, NN) :- armarNono([[4],[2,1],[2,1],[1,1],[1]],[[4],[3],[1],[2],[3]], NN).
nn(2, NN) :- armarNono([[4],[3,1],[1,1],[1],[1,1]],[[4],[2],[2],[1],[3,1]], NN).
nn(3, NN) :- armarNono([[2,1],[4],[3,1],[3],[3,3],[2,1],[2,1],[4],[4,4],[4,2]], [[1,2,1],[1,1,2,2],[2,3],[1,3,3],[1,1,1,1],[2,1,1],[1,1,2],[2,1,1,2],[1,1,1],[1]], NN).
nn(4, NN) :- armarNono([[1, 1], [5], [5], [3], [1]], [[2], [4], [4], [4], [2]], NN).
nn(5, NN) :- armarNono([[], [1, 1], [], [1, 1], [3]], [[1], [1, 1], [1], [1, 1], [1]], NN).
nn(6, NN) :- armarNono([[5], [1], [1], [1], [5]], [[1, 1], [2, 2], [1, 1, 1], [1, 1], [1, 1]], NN).
nn(7, NN) :- armarNono([[1, 1], [4], [1, 3, 1], [5, 1], [3, 2], [4, 2], [5, 1], [6, 1], [2, 3, 2], [2, 6]], [[2, 1], [1, 2, 3], [9], [7, 1], [4, 5], [5], [4], [2, 1], [1, 2, 2], [4]], NN).
nn(8, NN) :- armarNono([[5], [1, 1], [1, 1, 1], [5], [7], [8, 1], [1, 8], [1, 7], [2, 5], [7]], [[4], [2, 2, 2], [1, 4, 1], [1, 5, 1], [1, 8], [1, 7], [1, 7], [2, 6], [3], [3]], NN).
nn(9, NN) :- armarNono([[4], [1, 3], [2, 2], [1, 1, 1], [3]], [[3], [1, 1, 1], [2, 2], [3, 1], [4]], NN).
nn(10, NN) :- armarNono([[1], [1], [1], [1, 1], [1, 1]], [[1, 1], [1, 1], [1], [1], [ 1]], NN).
nn(11, NN) :- armarNono([[1, 1, 1, 1], [3, 3], [1, 1], [1, 1, 1, 1], [8], [6], [10], [6], [2, 4, 2], [1, 1]], [[2, 1, 2], [4, 1, 1], [2, 4], [6], [5], [5], [6], [2, 4], [4, 1, 1], [2, 1, 2]], NN).
nn(12, NN) :- armarNono([[9], [1, 1, 1, 1], [10], [2, 1, 1], [1, 1, 1, 1], [1, 10], [1, 1, 1], [1, 1, 1], [1, 1, 1, 1, 1], [1, 9], [1, 2, 1, 1, 2], [2, 1, 1, 1, 1], [2, 1, 3, 1], [3, 1], [10]], [[], [9], [2, 2], [3, 1, 2], [1, 2, 1, 2], [3, 11], [1, 1, 1, 2, 1], [1, 1, 1, 1, 1, 1], [3, 1, 3, 1, 1], [1, 1, 1, 1, 1, 1], [1, 1, 1, 3, 1, 1], [3, 1, 1, 1, 1], [1, 1, 2, 1], [11], []], NN).
nn(13, NN) :- armarNono([[2], [1,1], [1,1], [1,1], [1], [], [2], [1,1], [1,1], [1,1], [1]], [[1], [1,3], [3,1,1], [1,1,3], [3]], NN).
nn(14, NN) :- armarNono([[1,1], [1,1], [1,1], [2]], [[2], [1,1], [1,1], [1,1]], NN).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                              %
%    Predicados auxiliares     %
%        NO MODIFICAR          %
%                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%! completar(+S)
%
% Indica que se debe completar el predicado. Siempre falla.
completar(S) :- write("COMPLETAR: "), write(S), nl, fail.

%! mostrarNono(+NN)
%
% Muestra una estructura nono(...) en pantalla
% Las celdas x (pintadas) se muestran como ██.
% Las o (no pintasdas) se muestran como ░░.
% Las no instanciadas se muestran como ¿?.
mostrarNono(nono(M,_)) :- mostrarMatriz(M).

%! mostrarMatriz(+M)
%
% Muestra una matriz. Solo funciona si las celdas
% son valores x, o, o no instanciados.
mostrarMatriz(M) :-
	M = [F|_], length(F, Cols),
	mostrarBorde('╔',Cols,'╗'),
	maplist(mostrarFila, M),
	mostrarBorde('╚',Cols,'╝').

mostrarBorde(I,N,F) :-
	write(I),
	stringRepeat('══', N, S),
	write(S),
	write(F),
	nl.

stringRepeat(_, 0, '').
stringRepeat(Str, N, R) :- N > 0, Nm1 is N - 1, stringRepeat(Str, Nm1, Rm1), string_concat(Str, Rm1, R).

%! mostrarFila(+M)
%
% Muestra una lista (fila o columna). Solo funciona si las celdas
% son valores x, o, o no instanciados.
mostrarFila(Fila) :-
	write('║'),
	maplist(mostrarCelda, Fila),
	write('║'),
	nl.

mostrarCelda(C) :- nonvar(C), C = x, write('██').
mostrarCelda(C) :- nonvar(C), C = o, write('░░').
mostrarCelda(C) :- var(C), write('¿?').
