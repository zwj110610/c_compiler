/*lexer.l*/
%{
#include "parser.hpp"   /* Bison 生成的头，包含 token 定义 */
#include "utils.h"
%}

%option noyywrap

%%

"int"       { return INT; }
"return"    { return RETURN; }
"if"        { return IF; }
"else"      { return ELSE; }
"while"     { return WHILE; }    
"break"     { return BREAK; }
"continue"  { return CONTINUE; }


[ \t\r\n]+  ;


[0-9]+      {
                yylval.ival = atoi(yytext);
                return INT_CONST;
            }


[A-Za-z_][A-Za-z0-9_]* {
                yylval.sval = strdup(yytext);
                return IDENT;
            }


"<="        { return LE; }
">="        { return GE; }
"=="        { return EQ; }
"!="        { return NE; }
"&&"        { return AND; }
"||"        { return OR; }


";"         { return ';'; }
","         { return ','; }
"("         { return '('; }
")"         { return ')'; }
"{"         { return '{'; }
"}"         { return '}'; }
"="         { return '='; }
[+\-*/%<>!&|^]  { return yytext[0]; }


.           { fprintf(stderr, "Unknown char: %s\n", yytext); }

%%

