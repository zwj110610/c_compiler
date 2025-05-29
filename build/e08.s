.intel_syntax noprefix
.global factorial
factorial:
  push rbp
  mov rbp, rsp
  sub rsp, 8
  mov QWORD PTR [rbp-8], rdi
  mov rax, QWORD PTR [rbp-8]
  push rax
  mov rax, 1
  mov rcx, rax
  pop rax
  cmp rax, rcx
  setle al
  movzx rax, al
  cmp rax, 0
  je .factorial_L0
  mov rax, 1
  mov rsp, rbp
  pop rbp
  ret
  jmp .factorial_L1
.factorial_L0:
  mov rax, QWORD PTR [rbp-8]
  push rax
  mov rax, QWORD PTR [rbp-8]
  push rax
  mov rax, 1
  mov rcx, rax
  pop rax
  sub rax, rcx
  mov rdi, rax
  call factorial
  mov rcx, rax
  pop rax
  imul rax, rcx
  mov rsp, rbp
  pop rbp
  ret
.factorial_L1:
  mov rsp, rbp
  pop rbp
  ret
.intel_syntax noprefix
.global main
main:
  push rbp
  mov rbp, rsp
  sub rsp, 8
  mov rax, 1
  mov QWORD PTR [rbp-8], rax
.main_L0:
  mov rax, QWORD PTR [rbp-8]
  push rax
  mov rax, 5
  mov rcx, rax
  pop rax
  cmp rax, rcx
  setle al
  movzx rax, al
  cmp rax, 0
  je .main_L1
  mov rax, QWORD PTR [rbp-8]
  mov rdi, rax
  call factorial
  mov rdi, rax
  call println_int
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
