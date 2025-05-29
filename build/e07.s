.intel_syntax noprefix
.global main
main:
  push rbp
  mov rbp, rsp
  sub rsp, 8
  mov rax, 0
  mov QWORD PTR [rbp-8], rax
.main_L0:
  mov rax, QWORD PTR [rbp-8]
  push rax
  mov rax, 11
  mov rcx, rax
  pop rax
  cmp rax, rcx
  setl al
  movzx rax, al
  cmp rax, 0
  je .main_L1
  mov rax, QWORD PTR [rbp-8]
  push rax
  mov rax, 3
  mov rcx, rax
  pop rax
  cqo
  idiv rcx
  mov rax, rdx
  push rax
  mov rax, 1
  mov rcx, rax
  pop rax
  cmp rax, rcx
  sete al
  movzx rax, al
  cmp rax, 0
  je .main_L2
  mov rax, QWORD PTR [rbp-8]
  push rax
  mov rax, 2
  mov rcx, rax
  pop rax
  add rax, rcx
  mov QWORD PTR [rbp-8], rax
  mov rax, QWORD PTR [rbp-8]
  mov rdi, rax
  call println_int
  jmp .main_L0
  jmp .main_L3
.main_L2:
.main_L3:
  mov rax, QWORD PTR [rbp-8]
  push rax
  mov rax, 2
  mov rcx, rax
  pop rax
  cqo
  idiv rcx
  mov rax, rdx
  push rax
  mov rax, 0
  mov rcx, rax
  pop rax
  cmp rax, rcx
  sete al
  movzx rax, al
  cmp rax, 0
  je .main_L4
  mov rax, QWORD PTR [rbp-8]
  mov rdi, rax
  call println_int
  jmp .main_L5
.main_L4:
.main_L5:
  mov rax, QWORD PTR [rbp-8]
  push rax
  mov rax, 1
  mov rcx, rax
  pop rax
  add rax, rcx
  mov QWORD PTR [rbp-8], rax
  jmp .main_L0
.main_L1:
  mov rax, 0
  mov rsp, rbp
  pop rbp
  ret
  mov rsp, rbp
  pop rbp
  ret
.intel_syntax noprefix
.section .text
.globl println_int
println_int:
  push rbp
  mov rbp, rsp
  mov rsi, rdi
  lea rdi, [rip+fmt_int]
  xor eax, eax
  call printf
  mov rsp, rbp
  pop rbp
  ret
.section .rodata
fmt_int:
  .string "%d\n"
