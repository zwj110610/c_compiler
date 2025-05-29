#include <iostream>
#include "parser.hpp"
#include "codegen.h"
extern int yyparse();
int main(int argc, char* argv[]) {
  if (argc < 2) { std::cerr << "Usage: Compilerlab4 <source.c>\n"; return 1; }
  FILE* f = fopen(argv[1], "r");
  if (!f) { perror("fopen"); return 1; }
  extern FILE* yyin;
  yyin = f;
  yyparse();
  codegen::gen_runtime();
  return 0;
}
