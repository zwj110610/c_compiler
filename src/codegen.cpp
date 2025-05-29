// src/codegen.cpp
#include "codegen.h"
#include "ast.h"
#include "symbol_table.h"
#include <iostream>
#include <vector>

namespace {


static int  label_id_in_fn;
static std::string current_fn;

static SymbolTable symtab;

static std::vector<int> break_stack, continue_stack;


void collectDecls(AST *node) {
    if (auto d = dynamic_cast<DeclAST*>(node)) {
        for (auto &p : d->decls)
            symtab.add(p.first, 8);
    } else if (auto sl = dynamic_cast<StmtListAST*>(node)) {
        for (auto &s : sl->stmts) collectDecls(s);
    } else if (auto i = dynamic_cast<IfAST*>(node)) {
        collectDecls(i->cond);
        for (auto &s : i->thenStmts) collectDecls(s);
        for (auto &s : i->elseStmts) collectDecls(s);
    } else if (auto w = dynamic_cast<WhileAST*>(node)) {
        collectDecls(w->cond);
        for (auto &s : w->body) collectDecls(s);
    } else if (auto e = dynamic_cast<ExprStmtAST*>(node)) {
        collectDecls(e->expr);
    } else if (auto b = dynamic_cast<BinaryAST*>(node)) {
        collectDecls(b->lhs);
        collectDecls(b->rhs);
    } else if (auto c = dynamic_cast<CallAST*>(node)) {
        for (auto &arg : c->args) collectDecls(arg);
    }
}

void gen_expr(ExprAST *e);  

void gen_stmt(StmtAST *s) {
    if (auto r = dynamic_cast<ReturnAST*>(s)) {
        gen_expr(r->expr);
        std::cout << "  mov rsp, rbp\n"
                     "  pop rbp\n"
                     "  ret\n";
    }
    else if (auto d = dynamic_cast<DeclAST*>(s)) {
        for (auto &pr : d->decls) {
            if (pr.second) {
                gen_expr(pr.second);
                int off = symtab.lookup(pr.first);
                std::cout << "  mov QWORD PTR [rbp-" << off << "], rax\n";
            }
        }
    }
    else if (auto e = dynamic_cast<ExprStmtAST*>(s)) {
        gen_expr(e->expr);
    }
    else if (auto i = dynamic_cast<IfAST*>(s)) {
        int Lelse = label_id_in_fn++;
        int Lend  = label_id_in_fn++;
        gen_expr(i->cond);
        std::cout << "  cmp rax, 0\n"
                  << "  je ." << current_fn << "_L" << Lelse << "\n";
        for (auto &st : i->thenStmts) gen_stmt(st);
        std::cout << "  jmp ." << current_fn << "_L" << Lend << "\n"
                  << "." << current_fn << "_L" << Lelse << ":\n";
        for (auto &st : i->elseStmts) gen_stmt(st);
        std::cout << "." << current_fn << "_L" << Lend << ":\n";
    }
    else if (auto br = dynamic_cast<BreakAST*>(s)) {
        std::cout << "  jmp ." << current_fn << "_L" << break_stack.back() << "\n";
    }
    else if (auto ct = dynamic_cast<ContinueAST*>(s)) {
        std::cout << "  jmp ." << current_fn << "_L" << continue_stack.back() << "\n";
    }
    else if (auto w = dynamic_cast<WhileAST*>(s)) {
        int Ltop = label_id_in_fn++;
        int Lend = label_id_in_fn++;
        // push
        break_stack.push_back(Lend);
        continue_stack.push_back(Ltop);

        std::cout << "." << current_fn << "_L" << Ltop << ":\n";
        gen_expr(w->cond);
        std::cout << "  cmp rax, 0\n"
                  << "  je ." << current_fn << "_L" << Lend << "\n";
        for (auto &st : w->body) gen_stmt(st);
        std::cout << "  jmp ." << current_fn << "_L" << Ltop << "\n"
                  << "." << current_fn << "_L" << Lend << ":\n";

        break_stack.pop_back();
        continue_stack.pop_back();
    }
}

void gen_expr(ExprAST *e) {
    if (auto c = dynamic_cast<IntAST*>(e)) {
        std::cout << "  mov rax, " << c->value << "\n";
    }
    else if (auto v = dynamic_cast<VarAST*>(e)) {
        int off = symtab.lookup(v->name);
        std::cout << "  mov rax, QWORD PTR [rbp-" << off << "]\n";
    }
    else if (auto b = dynamic_cast<BinaryAST*>(e)) {
        if (b->op == "=") {
            gen_expr(b->rhs);
            auto L = dynamic_cast<VarAST*>(b->lhs);
            int off = symtab.lookup(L->name);
            std::cout << "  mov QWORD PTR [rbp-" << off << "], rax\n";
            return;
        }
    
        gen_expr(b->lhs);
        std::cout << "  push rax\n";
        gen_expr(b->rhs);
        //std::cout << "  pop rcx\n";
	std::cout << "  mov rcx, rax\n"
                 "  pop rax\n";
        if      (b->op == "+") {
        std::cout << "  add rax, rcx\n";
    }
    else if (b->op == "-") {
        std::cout << "  sub rax, rcx\n";
    }
    else if (b->op == "*") {
        std::cout << "  imul rax, rcx\n";
    }
    else if (b->op == "/") {
        std::cout << "  cqo\n"
                     "  idiv rcx\n";
    }
    else if (b->op == "%") {
        std::cout << "  cqo\n"
                     "  idiv rcx\n"
                     "  mov rax, rdx\n";
    }
    else {
        // 比较操作
        std::string setop;
        if      (b->op == "==") setop = "sete";
        else if (b->op == "!=") setop = "setne";
        else if (b->op == "<")  setop = "setl";
        else if (b->op == "<=") setop = "setle";
        else if (b->op == ">")  setop = "setg";
        else if (b->op == ">=") setop = "setge";
        std::cout << "  cmp rax, rcx\n"
                     "  " << setop << " al\n"
                     "  movzx rax, al\n";
    }
    }
    else if (auto c = dynamic_cast<CallAST*>(e)) {
        // 只传一个参数
        if (!c->args.empty()) {
            gen_expr(c->args[0]);
            std::cout << "  mov rdi, rax\n";
        }
        std::cout << "  call " << c->callee << "\n";
    }
}

} // namespace

namespace codegen {

void gen_function(const std::string &name,
                  const std::vector<std::string> &params,
                  StmtListAST *body) {
 
    symtab = SymbolTable();
    break_stack .clear();
    continue_stack.clear();
    label_id_in_fn = 0;
    current_fn = name;
  
    collectDecls(body);
    for (auto &p : params) symtab.add(p, 8);

    // prologue
    std::cout << ".intel_syntax noprefix\n"
                 ".global " << name << "\n"
              << name << ":\n"
                 "  push rbp\n"
                 "  mov rbp, rsp\n"
                 "  sub rsp, " << symtab.total_size() << "\n";

    
    if (params.size()>0)
      std::cout << "  mov QWORD PTR [rbp-" << symtab.lookup(params[0]) << "], rdi\n";
    if (params.size()>1)
      std::cout << "  mov QWORD PTR [rbp-" << symtab.lookup(params[1]) << "], rsi\n";


    for (auto &st : body->stmts) gen_stmt(st);


    std::cout << "  mov rsp, rbp\n"
                 "  pop rbp\n"
                 "  ret\n";
}

void gen_runtime() {
    // println_int
    std::cout << ".intel_syntax noprefix\n"
                 ".section .text\n"
                 ".globl println_int\n"
              << "println_int:\n"
                 "  push rbp\n"
                 "  mov rbp, rsp\n"
                 "  mov rsi, rdi\n"
                 "  lea rdi, [rip+fmt_int]\n"
                 "  xor eax, eax\n"
                 "  call printf\n"
                 "  mov rsp, rbp\n"
                 "  pop rbp\n"
                 "  ret\n"
                 ".section .rodata\n"
                 "fmt_int:\n"
                 "  .string \"%d\\n\"\n";
}

} // namespace codegen

