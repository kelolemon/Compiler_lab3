%{
    # include <stdio.h>
    # include "ast.h"
    # include <stdlib.h>
    # include <string.h>
    # include "define.h"
    char* ID_text;
    char* cmp_text;
    char* assign_text;
    int yylex();
    void yyerror();
    char* yytext;
    #define YYSTYPE past
    extern past new_node(char* token_type, char* value, past l, past r);
    extern void show_tree(past node, int high);
%}

%expect 1
%token number string equal CMP
%token ASSIGN
%token INT VOID STR IF ELSE WHILE RETURN PRINT SCAN ID


%%


S: program { show_tree($1, 0); }
    ;

program: external_declaration { $$ = $1; }
        | program external_declaration { $$ = new_node(token_Compound_list, "", $1, $2); }
        ;

external_declaration: function_definition { $$ = $1; }
                    | declaration { $$ = $1; }
                    ;

function_definition: type declarator compound_statement { $$ = new_node(token_func_decl, "", $1, new_node(token_Compound_list, "", $2, $3)); }
        ;

declaration: type init_declarator_list ';' { $$ = new_node(token_decl, "", $1, $2); }
        ;

init_declarator_list: init_declarator { $$ = $1; }
                    | init_declarator_list ',' init_declarator { $$ = new_node(token_Compound_list, "", $1, $3); }
                    ;

init_declarator: declarator { $$ = $1; }
                | declarator '=' add_expr { $$ = new_node(token_Compound_list, "", $1, $3); }
                | declarator '=' '{' intstr_list '}' { $$ = new_node(token_instr_list, "", $1, $4); }
                ;

intstr_list: initializer { $$ = $1; };
            | intstr_list ',' initializer { $$ = new_node(token_Compound_list, "", $1, $3); }
            ;

initializer: number { $$ = new_node(token_number, strdup(yytext), NULL, NULL); }
            | string { $$ = new_node(token_string, strdup(yytext), NULL, NULL); }
            ;

declarator: direct_declarator { $$ = $1; }
            ;

direct_declarator: ID { $$ = new_node(token_v_decl, ID_text, NULL, NULL); }
                  | direct_declarator '(' parameter_list ')' { $1->token_type = token_func_decl; $$ = new_node(token_Compound_list, "", $1, $3); }
                  | direct_declarator '(' ')' { $1->token_type = token_func_decl; $$ = new_node(token_Compound_list, "", $1, NULL); }
                  | ID '[' expr ']' { $$ = new_node(token_v_list, ID_text, $3, NULL); }
                  | ID '[' ']'  {$$ = new_node(token_v_list, ID_text, NULL, NULL); }
                  ;

parameter_list: parameter { $$ = $1; }
               | parameter_list ',' parameter { $$ = new_node(token_Compound_list, "", $1, $3); }
               ;

parameter: type ID { $$ = new_node(token_para, "", $1, new_node(token_v, ID_text, NULL, NULL)); }
        ;

type: INT { $$ = new_node(token_type_id, "int", NULL, NULL); }
     | STR { $$ = new_node(token_type_id, "str", NULL, NULL); }
     | VOID { $$ = new_node(token_type_id, "void", NULL, NULL); }
     ;

statement: compound_statement { $$ = $1; }
          | expression_statement { $$ = $1; }
          | selection_statement { $$ = $1; }
          | iteration_statement { $$ = $1; }
          | jump_statement { $$ = $1; }
          | print_statement { $$ = $1; }
          | scan_statement { $$ = $1; }
          | declaration {$$ = $1; }
          ;

compound_statement: begin_scope end_scope { $$ = new_node(token_Compound_list, "", $1, $2); }
                   | begin_scope statement_list end_scope { $$ = new_node(token_Compound_list, "", $1, new_node(token_Compound_list, "", $2, $3)); }
                   ;

begin_scope: '{' { $$ = new_node(token_begin_s, "{", NULL, NULL); }
        ;

end_scope: '}' { $$ = new_node(token_end_s, "}", NULL, NULL); }
        ;

statement_list: statement { $$ = $1; }
               | statement_list statement { $$ = new_node(token_Compound_list, "", $1, $2)}
               ;

expression_statement: ';' { $$ = NULL; }
                     | expr ';' { $$ = $1; }
                     ;

selection_statement: IF '(' expr ')' statement { $$ = new_node(token_IF_stat, "", $3, $5); }
                    | IF '(' expr ')' statement ELSE statement { $$ = new_node(token_IF_stat, "", $3, new_node(token_Else_stat, "", $5, $7)); }
                    ;

iteration_statement: WHILE '(' expr ')' statement { $$ = new_node(token_While_stat, "", $3, $5); }
        ;

jump_statement: RETURN ';' { $$ = new_node(token_rt_stat, "", NULL, NULL); }
               | RETURN expr ';' { $$ = new_node(token_rt_stat, "", $2, NULL); }
               ;

print_statement: PRINT ';' { $$ = new_node(token_Pint_stat, "", NULL, NULL); }
                | PRINT expr_list ';' { $$ = new_node(token_Pint_stat, "", $2, NULL); }
                ;

scan_statement: SCAN id_list ';' { $$ = new_node(token_Scan_stat, "", $2, NULL); }
            ;

expr: assign_expr { $$ = $1; }
    ;

assign_expr: cmp_expr  {$$ = $1; }
            | ID ASSIGN assign_expr { $$ = new_node(token_operator, assign_text, new_node(token_var_ref, ID_text, NULL, NULL), $3); }
            | ID '=' assign_expr { $$ = new_node(token_operator, "=", new_node(token_var_ref, ID_text, NULL, NULL), $3);  }
            | ID '[' expr ']' '=' assign_expr { $$ = new_node(token_operator, assign_text, new_node(token_v_list, ID_text, $3, NULL), $6); }
            ;

cmp_expr: add_expr { $$ = $1; }
         | cmp_expr CMP add_expr { $$ = new_node(token_operator, cmp_text, $1, $3); }
         ;

add_expr: mul_expr { $$ = $1; }
         | add_expr '+' mul_expr { $$ = new_node(token_operator, "+", $1, $3); }
         | add_expr '-' mul_expr { $$ = new_node(token_operator, "-", $1, $3); }
         ;

mul_expr: primary_expr { $$ = $1; }
         | mul_expr '*' primary_expr { $$ = new_node(token_operator, "*", $1, $3); }
         | mul_expr '/' primary_expr { $$ = new_node(token_operator, "/", $1, $3); }
         | mul_expr '%' primary_expr { $$ = new_node(token_operator, "%", $1, $3); }
         | '-' primary_expr { $$ = new_node(token_operator, "-", $2, NULL); }
         ;

primary_expr: ID '(' expr_list ')' {  $$ = new_node(token_func_ref, ID_text, $3, NULL); }
             | ID '(' ')' { $$ = new_node(token_var_ref, ID_text, NULL, NULL); }
             | '(' expr ')' { $$ = $2; }
             | ID { $$ = new_node(token_var_ref, ID_text, NULL, NULL); }
             | initializer { $$ = $1; }
             | ID '[' expr ']' { $$ = new_node(token_v_list, ID_text, $3, NULL); }
             ;

expr_list: expr { $$ = $1; }
          | expr_list ',' expr { $$ = new_node(token_Compound_list, "", $1, $3); }
          ;

id_list: ID { $$ = $1; }
        | id_list ',' ID { $$ = new_node(token_Compound_list, "", $1, $3); }
        ;

%%

void yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
}
