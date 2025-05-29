#pragma once
#include <string>
#include "ast.h"

namespace codegen {

  void gen_function(const std::string &name,
                    const std::vector<std::string> &params,
                    StmtListAST *stmts);
  void gen_runtime();
}
