//
// Created by 邓萌达 on 2019-12-05.
//

# include <stdio.h>

extern FILE* yyin;
extern FILE* yyout;

extern int yyparse();

int main(int argv, char* argc[]) {
    if (argv >= 2){
        yyin = fopen(argc[1], "r");
        if (yyin == NULL) {
            printf("Can not open the file: %s\n", argc[1]);
            return 404;
        }
    }
    if (argv >= 3){
        yyout = fopen(argc[2], "w");
    }

    yyparse();
    return 0;

}
