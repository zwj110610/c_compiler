.intel_syntax noprefix
.global main
main:
  push rbp
  mov rbp, rsp
  sub rsp, 16
  mov rax, 0
  mov QWORD PTR [rbp-8], rax
.L0:
  mov rax, QWORD PTR [rbp-8]
  push rax
  mov rax, 3
  pop rcx
  cmp rcx, rax
  setl al
  movzx rax, al
  cmp rax, 0
  je .L1
  mov rax, 0
  mov QWORD PTR [rbp-16], rax
.L2:
  mov rax, QWORD PTR [rbp-16]
  push rax
  mov rax, 2
  pop rcx
  cmp rcx, rax
  setl al
  movzx rax, al
  cmp rax, 0
  je .L3
  mov rax, QWORD PTR [rbp-8]
  push rax
  mov rax, 10
  pop rcx
  imul rax, rcx
  push rax
  mov rax, QWORD PTR [rbp-16]
  pop rcx
  add rax, rcx
  mov rdi, rax
  call println_int
  mov rax, QWORD PTR [rbp-16]
  push rax
  mov rax, 1
  pop rcx
  add rax, rcx
  mov QWORD PTR [rbp-16], rax
  jmp .L2
.L3:
  mov rax, QWORD PTR [rbp-8]
  push rax
  mov rax, 1
  pop rcx
  add rax, rcx
  mov QWORD PTR [rbp-8], rax
  jmp .L0
.L1:
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
