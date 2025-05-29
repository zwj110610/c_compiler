%define parse.error verbose

%code requires {
  #include "ast.h"
}
%{
#include "codegen.h"
#include "symbol_table.h"
#include <cstdio>


extern int yylex();

void yyerror(const char *s) {
    std::fprintf(stderr, "Syntax error: %s\n", s);
}
%}

%union {
    int                     ival;
    char                   *sval;
    AST                    *ast;
    std::vector<ExprAST*>  *elist;
    std::vector<std::string> *plist;
}


%token <ival>   INT_CONST
%token <sval>   IDENT
%token          INT RETURN IF ELSE
%token          WHILE
%token          BREAK CONTINUE
%token          LE GE EQ NE AND OR

/* —— 先把各运算符的结合性和优先级都声明好 —— */
/* 等号最低 */
%nonassoc EQ NE
/* 关系运算 */
%nonassoc '<' '>' LE GE
/* 加减 */
%left '+' '-'
/* 乘除取余，最高 */
%left '*' '/' '%'

/* 给所有表达式层次指定 AST* 类型 */
%type  <ast>
    program function compound_stmt stmt_list stmt
    decl decl_list declarator
    expr eq_expr rel_expr add_expr mul_expr primary

%type  <elist>   expr_list
%type  <plist>   param_list

%%

program:
      function
    | program function
    ;

function:
    INT IDENT '(' param_list ')' compound_stmt {
        codegen::gen_function($2, *$4, (StmtListAST*)$6);
        delete $4;
    }
    ;

compound_stmt:
    '{' stmt_list '}' { $$ = $2; }
    ;

stmt_list:
      /* empty */            { $$ = new StmtListAST(); }
    | stmt_list stmt        { ((StmtListAST*)$1)->stmts.push_back((StmtAST*)$2); $$ = $1; }
    ;

stmt:
      decl ';'              { $$ = $1; }
    | IDENT '=' expr ';'    { $$ = new ExprStmtAST(new BinaryAST("=", new VarAST(std::string($1)), (ExprAST*)$3)); }
    | IDENT '(' expr_list ')' ';' {
        $$ = new ExprStmtAST(new CallAST(std::string($1), std::move(*$3)));
        delete $3;
      }
    | IF '(' expr ')' compound_stmt ELSE compound_stmt {
        auto n = new IfAST();
        n->cond      = (ExprAST*)$3;
        n->thenStmts = ((StmtListAST*)$5)->stmts;
        n->elseStmts = ((StmtListAST*)$7)->stmts;
        $$ = n;
      }
    | IF '(' expr ')' compound_stmt {
        auto n = new IfAST();
        n->cond      = (ExprAST*)$3;
        n->thenStmts = ((StmtListAST*)$5)->stmts;
        $$ = n;
      }
    | WHILE '(' expr ')' compound_stmt {
        $$ = new WhileAST((ExprAST*)$3, ((StmtListAST*)$5)->stmts);
      }
    | BREAK ';'             { $$ = new BreakAST(); }
    | CONTINUE ';'          { $$ = new ContinueAST(); }
    | RETURN expr ';'       { $$ = new ReturnAST((ExprAST*)$2); }
    ;

/* 变量声明 */
decl:
    INT decl_list           { $$ = $2; }
    ;

decl_list:
      declarator           { $$ = $1; }
    | decl_list ',' declarator {
        auto d1 = (DeclAST*)$1, d2 = (DeclAST*)$3;
        d1->decls.insert(d1->decls.end(), d2->decls.begin(), d2->decls.end());
        $$ = d1;
      }
    ;

declarator:
      IDENT                  {
        auto d = new DeclAST();
        d->decls.push_back({ std::string($1), nullptr });
        $$ = d;
      }
    | IDENT '=' expr         {
        auto d = new DeclAST();
        d->decls.push_back({ std::string($1), (ExprAST*)$3 });
        $$ = d;
      }
    ;

/* 表达式列表 */
expr_list:
      expr                   { $$ = new std::vector<ExprAST*>(); $$->push_back((ExprAST*)$1); }
    | expr_list ',' expr     { $1->push_back((ExprAST*)$3); $$ = $1; }
    ;

/* 参数列表 */
param_list:
      /* empty */            { $$ = new std::vector<std::string>(); }
    | INT IDENT             { $$ = new std::vector<std::string>(); $$->push_back(std::string($2)); }
    | param_list ',' INT IDENT {
        $1->push_back(std::string($4)); $$ = $1;
      }
    ;

/* 顶层：直接过渡到 eq_expr */
expr:
    eq_expr                 { $$ = $1; }
    ;

/* 第二层：== 和 != */
eq_expr:
      eq_expr EQ  rel_expr        { $$ = new BinaryAST("==", (ExprAST*)$1, (ExprAST*)$3); }
    | eq_expr NE  rel_expr        { $$ = new BinaryAST("!=", (ExprAST*)$1, (ExprAST*)$3); }
    | rel_expr              { $$ = $1; }
    ;

/* 第三层：<, >, <=, >= */
rel_expr:
      rel_expr '<'  add_expr      { $$ = new BinaryAST("<",  (ExprAST*)$1, (ExprAST*)$3); }
    | rel_expr '>'  add_expr      { $$ = new BinaryAST(">",  (ExprAST*)$1, (ExprAST*)$3); }
    | rel_expr LE   add_expr      { $$ = new BinaryAST("<=", (ExprAST*)$1, (ExprAST*)$3); }
    | rel_expr GE   add_expr      { $$ = new BinaryAST(">=", (ExprAST*)$1, (ExprAST*)$3); }
    | add_expr              { $$ = $1; }
    ;

/* 第四层：+ 和 - */
add_expr:
      add_expr '+' mul_expr       { $$ = new BinaryAST("+",  (ExprAST*)$1, (ExprAST*)$3); }
    | add_expr '-' mul_expr       { $$ = new BinaryAST("-",  (ExprAST*)$1, (ExprAST*)$3); }
    | mul_expr              { $$ = $1; }
    ;

/* 第五层：*、/、% */
mul_expr:
      mul_expr '*' primary        { $$ = new BinaryAST("*",  (ExprAST*)$1, (ExprAST*)$3); }
    | mul_expr '/' primary        { $$ = new BinaryAST("/",  (ExprAST*)$1, (ExprAST*)$3); }
    | mul_expr '%' primary        { $$ = new BinaryAST("%",  (ExprAST*)$1, (ExprAST*)$3); }
    | primary               { $$ = $1; }
    ;

/* 最底层：常量、变量、函数调用、小括号 */
primary:
      INT_CONST             { $$ = new IntAST($1); }
    | IDENT                 { $$ = new VarAST(std::string($1)); }
    | IDENT '(' expr_list ')' {
        $$ = new CallAST(std::string($1), std::move(*$3));
        delete $3;
      }
    | '(' expr ')'          { $$ = $2; }
    ;

%%



