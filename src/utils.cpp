#include "utils.h"
#include <cstdio>
#include <cstdlib>
void error(const char* msg) {
    fprintf(stderr, "%s\n", msg);
    exit(1);
}
void println_int(int x) {
    std::fprintf(stdout, "%d\n", x);
}
