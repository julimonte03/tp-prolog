

% Ejercicio 1
% matriz(+F, +C,-M)
matriz(0, _, []).
matriz(F, C, [N|XS]) :- columna(C,N), matriz(G,C,XS), F is G+1.
% columna(+C,-M)
columna(0,[]).
columna(C,[_|XS]):- columna(N, XS), C is N+1.
 
% Ejercicio 2
%replicar(+Elem, +N, -Lista)
replicar(_, 0, []).
replicar(X, N, [X|XS]) :- replicar(X, M, XS), N is M+1.
 
% Ejercicio 3
% transponer(+M, -MT)
transponer([], []). 
transponer([[]|_], []) :- !.
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
 
pintadasValidas(r([B|Bs], Celdas)) :-
    length(Celdas, N),
    sum_list(Bs, SumR),              
    length(Bs, K),
    SepR is max(0, K - 1),           
    MaxAntes is N - (B + SepR + SumR),
    MaxAntes >= 0,
    between(0, MaxAntes, OsAntes),   
    colocarOs(OsAntes, Celdas, R1),  
    colocarXs(B, R1, R2),            
    poner_sep(K, R2, R3),            
    pintadasValidas(r(Bs, R3)).
 
poner_sep(0, L, L).
poner_sep(K, LIn, LOut) :-
    K > 0,
    colocarOs(1, LIn, LOut).
 
colocarOs(0, L, L).
colocarOs(N, [C|Cs], R) :-
    N > 0,
    C = o,
    N1 is N - 1,
    colocarOs(N1, Cs, R).
 
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
pintarObligatorias(r(Res, Celdas)):-
    length(Celdas, N),
    findall(L, (length(L, N) , pintadasValidas(r(Res, L))), Soluciones),
    combinarSoluciones(Soluciones, Celdas).

combinarSoluciones([Ultima], Ultima).
combinarSoluciones([S1, S2| Resto], Resultado):-
    combinarListas(S1, S2, Combinado),
    combinarSoluciones([Combinado | Resto], Resultado).

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
% Ejercicio 8
%nono(Matriz, Restricciones)

restriccionConMenosLibres(NN, R) :-
	NN = nono(_, RS), %r(Bloques, Celdas)
    member(R, RS), % agarramos una restricción candidata R
    R = r(_, L),        % agarro su lista de celdas L
    cantidadVariablesLibres(L, N),
    N > 0,
	%ya teneemos las vars libres de R, y ahora 
	%vemos que no existe OTRA restriccion en RS tal tenga menos celdas sin decidir
    not(( member(OTRA, RS),
          OTRA \== R,
          OTRA = r(_, L2),
          cantidadVariablesLibres(L2, N2),
          N2 > 0,
          N2 < N )).

% Ejercicio 9
resolverDeduciendo(_) :- completar("Ejercicio 9").

% Ejercicio 10
solucionUnica(nono(M, Res)) :- 
    findall(M, resolverNaive(nono(M,Res)), Soluciones),
    length(Soluciones, N),
    N =:= 1.
	
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
