// symbol_table.h
#pragma once
#include <string>
#include <unordered_map>

struct SymbolTable {
  
  int current_size = 0;
  std::unordered_map<std::string,int> table;

  // 分配 size 字节，返回给 name 的偏移
  int add(const std::string &name, int size);
  int lookup(const std::string &name) const;
  int total_size() const { return current_size; }
};

