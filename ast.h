//
// Created by 邓萌达 on 2019-12-04.
//

#ifndef HANDIN_AST_H
#define HANDIN_AST_H

#endif //HANDIN_AST_H

# include "define.h"
# include <stdlib.h>
# include <stdio.h>

extern FILE* yyout;

typedef struct _ast ast;
typedef struct _ast* past;
struct _ast{
    char* token_type;
    char* value;
    past left;
    past right;
};
