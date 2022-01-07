%:- include('basedados.pl').
:-include('queries.pl').

%Gerar os circuitos de entrega, caso existam, que cubram um determinado território
% %não informada --> n sabe o q vem a seguir

adjacente(X,Y,E) :- edge(X,Y,E).
adjacente(X,Y,E) :- edge(Y,X,E).

%BEST FIRST SEARCH
bfs(Orig, Dest, Cam):- bfs2(Dest,[[Orig]],Cam).
bfs2(Dest,[[Dest|T]|_],Cam):- reverse([Dest|T],Cam). % Caminho aparece pela ordem inversa

bfs2(Dest,[LA|Outros],Cam) :- LA=[Act|_],
                              findall([X|LA],
                              (Dest\==Act,adjacente(Act,X,_),\+member(X,LA)),Novos),
                              append(Outros,Novos,Todos),
                              bfs2(Dest,Todos,Cam).


%DEPTH FIRST SEARCH
dfs(Orig,Dest,Cam):- dfs2(Orig,Dest,[Orig],Cam). %condicao final: nó actual = destino
dfs2(Dest,Dest,LA,Cam):- reverse(LA,Cam). %caminho actual esta invertido
dfs2(Act,Dest,LA,Cam) :- adjacente(Act,X,_), %testar ligacao entre ponto actual e um qualquer X
                         \+ member(X,LA), % testar nao circularidade p/evitar nós ja visitados
                         dfs2(X,Dest,[X|LA],Cam). %chamada recursiva



listaDeAdjacentes(X, Lista):- findall(Y, adjacente(X, Y, _), Lista).



%BUSCA ITERATIVA EM PROFUNDIDADE
/*depth_first_iterative_deepening(Node, Solution) :- 
    path(Node, GoalNode,[Node],Solution),
    pontorecolha(GoalNode).

path(Node, Node, Path,Cam):-reverse(Path,Cam).
path(FirstNode, LastNode, Path,Cam) :- 
    path(FirstNode, OneButLast, Path,Cam),
    adjacente(OneButLast, LastNode,_),
    \+(member(LastNode, Path)).
*/

depth_first_iterative_deepening(Node, Solution) :- 
                        path(Node, GoalNode, Solution),
                        pontorecolha(GoalNode).

%path1(Node, Node, Nodo,Cam):-reverse([Node|Nodo],Cam).
path(Node, Node, [Node]).
path(FirstNode, LastNode, [LastNode|Path]) :- 
                    path(FirstNode, OneButLast, Path),
                    adjacente(OneButLast, LastNode,_),
                    not(member(LastNode, Path)).


%GULOSA
resolve_gulosa(Nodo, Caminho/Custo) :-
	nodo(Nodo, Estima),
	agulosa([[Nodo]/0/Estima], InvCaminho/Custo/_),
	reverse(InvCaminho, Caminho).

agulosa(Caminhos, Caminho) :-
	obtem_melhor_g(Caminhos, Caminho),
	Caminho = [Nodo|_]/_/_,
	pontorecolha(Nodo).

agulosa(Caminhos, SolucaoCaminho) :-
	obtem_melhor_g(Caminhos, MelhorCaminho),
	select(MelhorCaminho, Caminhos, OutrosCaminhos),
	expande_gulosa(MelhorCaminho, ExpCaminhos),
	append(OutrosCaminhos, ExpCaminhos, NovoCaminhos),
    agulosa(NovoCaminhos, SolucaoCaminho).		

obtem_melhor_g([Caminho], Caminho) :- !.

obtem_melhor_g([Caminho1/Custo1/Est1,_/Custo2/Est2|Caminhos], MelhorCaminho) :-
	Est1 =< Est2, !,
	obtem_melhor_g([Caminho1/Custo1/Est1|Caminhos], MelhorCaminho).
	
obtem_melhor_g([_|Caminhos], MelhorCaminho) :- 
	obtem_melhor_g(Caminhos, MelhorCaminho).

expande_gulosa(Caminho, ExpCaminhos) :-
	findall(NovoCaminho, adjacente2(Caminho,NovoCaminho), ExpCaminhos).	



%%ESTRELA

resolve_aestrela(Nodo, Caminho/Custo) :-
	nodo(Nodo, Estima),
	aestrela([[Nodo]/0/Estima], InvCaminho/Custo/_),
	reverse(InvCaminho, Caminho).

aestrela(Caminhos, Caminho) :-
	obtem_melhor(Caminhos, Caminho),
	Caminho = [Nodo|_]/_/_,
	pontorecolha(Nodo).

aestrela(Caminhos, SolucaoCaminho) :-
	obtem_melhor(Caminhos, MelhorCaminho),
	select(MelhorCaminho, Caminhos, OutrosCaminhos),
	expande_aestrela(MelhorCaminho, ExpCaminhos),
	append(OutrosCaminhos, ExpCaminhos, NovoCaminhos),
    aestrela(NovoCaminhos, SolucaoCaminho).	

obtem_melhor([Caminho], Caminho) :- !.
obtem_melhor([Caminho1/Custo1/Est1,_/Custo2/Est2|Caminhos], MelhorCaminho) :-
	Custo1 + Est1 =< Custo2 + Est2, !,
	obtem_melhor([Caminho1/Custo1/Est1|Caminhos], MelhorCaminho). 
obtem_melhor([_|Caminhos], MelhorCaminho) :- 
	           obtem_melhor(Caminhos, MelhorCaminho).


adjacente2([Nodo|Caminho]/Custo/_, [ProxNodo,Nodo|Caminho]/NovoCusto/Est) :-
    adjacente(Nodo,ProxNodo,PassoCusto),
    \+member(ProxNodo, Caminho),
    NovoCusto is Custo + PassoCusto,
    nodo(ProxNodo, Est).


expande_aestrela(Caminho, ExpCaminhos) :-
	findall(NovoCaminho, adjacente2(Caminho,NovoCaminho), ExpCaminhos).


%CAMINHO MAIS RÁPIDO 
%DFS
maisRapidoDFS(Inicio,Path, Cost):- maisRapidoDFS2(Inicio, [], 0, Path, Cost).

maisRapidoDFS2(gualtar, Visited, Cost, Path, Cost):- reverse([gualtar|Visited], Path). 
maisRapidoDFS2(Node, Visited, Cost, Path, Total):- adjacente(Node, X, Value),
    not(member(X, Visited)), 
    NewCost is Cost + Value,
    maisRapidoDFS2(X, [Node|Visited], NewCost, Path, Total).

solucao(Inicio,Lista) :- findall((Path,Cost),maisRapidoDFS(Inicio, Path, Cost),Lista).
                                    %predsort(compare_by_second2,Lista,L),
                                    %first(L,Res).

fim(Inicio, Path, Cost,Res):-solucao(Inicio,Lista), 
                             predsort(compare_by_second2,Lista,L),
                             first(L,Res).


first([H|T],R):- R=H.


%BFS
somasecond([],0).
somasecond([[(U,H)|T]|I],S):-
    somasecond(I,G),S is H+G.

maisRapidoBFS(Orig, Dest, Cam,Custo):- maisRapidoBFS2(Dest,[[Orig]],Cam,0,Cost).
maisRapidoBFS2(Dest,[[Dest|T]|_],Cam,Cost,Cost):- reverse([Dest|T],Cam). % Caminho aparece pela ordem inversa

maisRapidoBFS2(Dest,[LA|Outros],Cam,Cost,Total):- LA=[Act|_],
                                                   findall([(X,Value)|LA],
                                                   (Dest\==Act,adjacente(Act,X,Value),\+member(X,LA)),Novos),
                                                   somasecond(Novos,NewCost),
                                                   append(Outros,Novos,Todos),
                                                   maisRapidoBFS2(Dest,Todos,Cam,NewCost,Total).



encontraVP(X,P,D):-clienteerua(Cliente,rua(X,_)),caminhoV(_,Cliente,encomenda(_,P,_),_,D,_).

%em algumas tem q se passar o seg elemento
encontraPesoDataNovo([H|T],[(H,D)|F],P) :-encontraPesoData([H|T],[(H,D)|F],0,P).
%encontraPesoData(_,[],0).
encontraPesoData([H|T],[(H,D)|F],P,P).
encontraPesoData([H|T],[(H,D)|F],P,Total):-encontraVP(H,P2,D),P1 is P+P2, encontraPesoData(T,F,P1,Total).

auxencontra([H|T],R):-findall((P,Path),encontraPesoDataNovo([H|T],Path,P),List),reverse(List,PathR),first(PathR,R).



takefirst([H|T],T).

runLista([(R,T)|K],FinalLista):-percorreLista([(R,T)|K],[],FinalLista).


percorreLista([(gualtar,_)|_],Nodo,FinalLista):-reverse(Nodo,FinalLista).
percorreLista([(R,T)|K],Nodo,FinalLista):-R\=gualtar,percorreLista(K,[(R,T)|Nodo],FinalLista).


encontraMenorData(Lista,Time):-runLista(Lista,Lista1),predsort(compare_by_second2,Lista1,ListaN),first(ListaN,Time).




velocidadeVeiculo(PesoVol,bicicleta,Velocidade):-Velocidade is 20-(0.7*PesoVol).
velocidadeVeiculo(PesoVol,mota,Velocidade):-Velocidade is 40-(0.5*PesoVol).
velocidadeVeiculo(PesoVol,carro,Velocidade):-Velocidade is 60-(0.1*PesoVol).

% dado um peso devolve a velocidade para cada transporte
getVelocidadeEncomenda(PV,List):- findall((Veiculo,Velocidade),(velocidadeVeiculo(PV,Veiculo,Velocidade)),List).

comparaTempos([],_,_,_).
comparaTempos([(X,Y)|T],Custo,Tempo,Veiculo,TempoTrans):- G is (Custo/Y),
                                                          G >Tempo, comparaTempos(T,Custo,Tempo,Veiculo, TempoTrans).
comparaTempos([(X,Y)|T],Custo,Tempo,Veiculo,TempoTrans) :- TempoTrans is (Custo/Y), TempoTrans =< Tempo, Veiculo = X, TempoTrans = TempoTrans.




% MAIOR VOLUME E PESO DFS 

encontraV(X,P1):-clienteerua(Cliente,rua(X,_)),caminhoV(_,Cliente,encomenda(_,P,V),_,_,_),P1 is P+V.

%em algumas tem q se passar o seg elemento
encontraPesoVNovo([H|T],P) :-encontraPesoV([H|T],0,P).
%encontraPesoData(_,[],0).
encontraPesoV([H|T],P,P).
encontraPesoV([H|T],P,Total):-encontraV(H,P2),P1 is P+P2, encontraPesoV(T,P1,Total).

auxencontra2([H|T],R):-findall((PesoVol,[H|T]),encontraPesoVNovo([H|T],PesoVol),List),reverse(List,PathR),first(PathR,R).


volume(Origem,Peso):-maisRapidoDFS(Origem,Path,Custo),
                     auxencontra2(Path,Peso).





%TEMPO DFS
escolheVeiculoeTempoDFS(Origem,Path,Veiculo,Time,Custo):-maisRapidoDFS(Origem,Path,Custo),
                                    auxencontra(Path,(Peso,Caminho)), 
                                    encontraMenorData(Caminho,(X,MaiorT)), 
                                    getVelocidadeEncomenda(Peso,ListVelVeic),
                                    comparaTempos(ListVelVeic,Custo,MaiorT,Veiculo,Time).


%TEMPO BFS 

/*escolheVeiculoeTempoBFS(Origem,Path,Veiculo,Time):-maisRapidoBFS(Origem,Path,Custo),
                                    auxencontra(Path,(Peso,Caminho)), 
                                    encontraMenorData(Caminho,(X,MaiorT)), 
                                    getVelocidadeEncomenda(Peso,ListVelVeic),
                                    comparaTempos(ListVelVeic,Custo,MaiorT,Veiculo,Time).

*/
 %TEMPO GULOSA  
 escolheVeiculoeTempo_gulosa(Origem,Path,Veiculo,Time,Custo):-resolve_gulosa(Origem,Path/Custo),
                                                             auxencontra(Path,(Peso,Caminho)), 
                                                             encontraMenorData(Caminho,(X,MaiorT)), 
                                                             getVelocidadeEncomenda(Peso,ListVelVeic),
                                                             comparaTempos(ListVelVeic,Custo,MaiorT,Veiculo,Time).

%TEMPO ESTRELA  

escolheVeiculoeTempo_estrela(Origem,Path,Veiculo,Time,Custo):-resolve_aestrela(Origem,Path/Custo),
                                                            auxencontra(Path,(Peso,Caminho)), 
                                                            encontraMenorData(Caminho,(X,MaiorT)), 
                                                            getVelocidadeEncomenda(Peso,ListVelVeic),
                                                            comparaTempos(ListVelVeic,Custo,MaiorT,Veiculo,Time).
                            





