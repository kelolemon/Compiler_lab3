%{
    # include "lrparser.tab.h"
    void yyerror(char *);
    # define YYSTYPE past
    extern char* ID_text;
    extern char* cmp_text;
    extern char* assign_text;
%}

/* Definitions, node: \042 is '"'*/
INTEGER             ([0-9]+)
UNTERM_STRING       (\042[^\042\n]*)
STRING              (\042[^\042\n]*\042)
IDENTIFIER          ([_a-zA-Z][_a-zA-Z0-9]*)
OPERATOR            ([\*\-\+\<\>\=\!\%\/\^])
DELIMITER           ([,;:\.\(\)\{}\[\]\?])
SINGLE_COMMENT1     ("//"[^\n]*)
SINGLE_COMMENT2     ("#"[^\n]*)
SINGLE_COMMENT3     ([/][*][^*]*[*]+([^*/][^*]*[*]+)*[/])
SINGLE_COMMENT4     ("@"[^\n]*)
FLOAT               (^[1-9]\d*\.\d*|0\.\d*[1-9]\d*$)

/* rule */
%%

[\n]                {                            }
[ \t\r\a]+          {                            }
{SINGLE_COMMENT1}   { /* skip for single line comment */    }
{SINGLE_COMMENT2}   { /* skip for single line commnet */    }
{SINGLE_COMMENT3}   { /*skip */                             }
{SINGLE_COMMENT4}   { /* skip @ commet  */                  }
"+" |
"-" |
"*" |
"/" |
"%" |
"=" |
";" |
"," |
"(" |
")" |
"[" |
"]" |
"{" |
"}"                 { return yytext[0];                             }
"=="                { cmp_text = strdup(yytext); return CMP;        }
"!="                { cmp_text = strdup(yytext); return CMP;        }
">="                { cmp_text = strdup(yytext); return CMP;        }
"<="                { cmp_text = strdup(yytext); return CMP;        }
{INTEGER}           { return number;                                }
{FLOAT}             { return number;                                }
{STRING}            { return string;                                }
"+="                { assign_text = strdup(yytext); return ASSIGN;  }
"-="                { assign_text = strdup(yytext); return ASSIGN;  }
"*="                { assign_text = strdup(yytext); return ASSIGN;  }
"/="                { assign_text = strdup(yytext); return ASSIGN;  }
"%="                { assign_text = strdup(yytext); return ASSIGN;  }
">"                 { cmp_text = strdup(yytext); return CMP;        }
"<"                 { cmp_text = strdup(yytext); return CMP;        }
"int"               { return INT;                                   }
"string"            { return STR;                                   }
"str"		        { return STR;			                        }
"void"              { return VOID;                                  }
"if"                { return IF;                                    }
"else"              { return ELSE;                                  }
"while"             { return WHILE;                                 }
"print"             { return PRINT;                                 }
"scan"              { return SCAN;                                  }
"return"            { return RETURN;                                }
{IDENTIFIER}        { ID_text = strdup(yytext); return ID;          }
%%

int yywrap(void){
    return 1;
}
