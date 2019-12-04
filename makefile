main: ast.c main.c lrparser.tab.c lex.yy.c
	clang ast.c main.c lrparser.tab.c lex.yy.c -o main
lex.yy.c: lrparser.tab.h lrlex.l
	flex lrlex.l
lrparser.tab.c: lrparser.y
	bison -d lrparser.y
lrparser.tab.h: lrparser.y
	bison -d lrparser.y

