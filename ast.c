//
// Created by 邓萌达 on 2019-12-04.
//

# include "ast.h"

past new_node(char* token_type, char* value, past l, past r){
    past node = (past) malloc(sizeof(ast));
    if (node == NULL) {
        puts("ERROR! out of memory");
        exit(0);
    }
    node->token_type = token_type;
    node->value = value;
    node->left = l;
    node->right = r;
    return node;
}

void show_tree(past node, int high){
    if (node == NULL) return;
    if (node->token_type == token_Compound_list) {
        show_tree(node->left, high);
        show_tree(node->right, high);
        return;
    }

    for (int i = 0; i < high; i++) fprintf(yyout,"\t");
    fprintf(yyout, "%s: %s\n", node->token_type, node->value);
    show_tree(node->left, high + 1);
    show_tree(node->right, high + 1);
}
