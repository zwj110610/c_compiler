.intel_syntax noprefix
.global main
main:
  push rbp
  mov rbp, rsp
  sub rsp, 16
  mov rax, 5
  mov QWORD PTR [rbp-8], rax
  mov rax, 3
  mov QWORD PTR [rbp-16], rax
  mov rax, QWORD PTR [rbp-8]
  push rax
  mov rax, QWORD PTR [rbp-16]
  mov rcx, rax
  pop rax
  cmp rax, rcx
  setle al
  movzx rax, al
  cmp rax, 0
  je .main_L0
  mov rax, QWORD PTR [rbp-8]
  mov rdi, rax
  call println_int
  jmp .main_L1
.main_L0:
.main_L1:
  mov rax, QWORD PTR [rbp-16]
  mov rdi, rax
  call println_int
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
