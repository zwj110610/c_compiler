#pragma once
#include <vector>
#include <string>


struct AST {
    virtual ~AST() = default;
};


struct ExprAST : AST {};


struct StmtAST : AST {};


struct StmtListAST : StmtAST {
    std::vector<StmtAST*> stmts;
};


struct IntAST : ExprAST {
    int value;
    IntAST(int v): value(v) {}
};


struct VarAST : ExprAST {
    std::string name;
    VarAST(const std::string &n): name(n) {}
};


struct BinaryAST : ExprAST {
    std::string op;
    ExprAST *lhs;
    ExprAST *rhs;
    BinaryAST(const std::string &o, ExprAST *l, ExprAST *r)
      : op(o), lhs(l), rhs(r) {}
};


struct CallAST : ExprAST {
    std::string callee;
    std::vector<ExprAST*> args;
    CallAST(const std::string &c, std::vector<ExprAST*> a)
      : callee(c), args(std::move(a)) {}
};


struct DeclAST : StmtAST {
 
    std::vector<std::pair<std::string, ExprAST*>> decls;
};


struct ExprStmtAST : StmtAST {
    ExprAST *expr;
    ExprStmtAST(ExprAST *e): expr(e) {}
};


struct IfAST : StmtAST {
    ExprAST *cond;
    std::vector<StmtAST*> thenStmts;
    std::vector<StmtAST*> elseStmts;
};


struct ReturnAST : StmtAST {
    ExprAST *expr;
    ReturnAST(ExprAST *e): expr(e) {}
};


struct FunctionAST : AST {
    std::string name;
    std::vector<StmtAST*> body;
};
struct WhileAST : StmtAST {
    ExprAST *cond;
    std::vector<StmtAST*> body;
    WhileAST(ExprAST *c, std::vector<StmtAST*> b)
      : cond(c), body(std::move(b)) {}
};
struct BreakAST : StmtAST { };
struct ContinueAST : StmtAST { };
