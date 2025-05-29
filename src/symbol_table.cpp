// symbol_table.cpp
#include "symbol_table.h"
#include "utils.h"

int SymbolTable::add(const std::string &name, int size) {
  current_size += size;
  table[name] = current_size;
  return current_size;
}

int SymbolTable::lookup(const std::string &name) const {
  auto it = table.find(name);
  if (it == table.end()) error("Undefined variable");
  return it->second;
}

