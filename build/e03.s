.intel_syntax noprefix
.global sum
sum:
  push rbp
  mov rbp, rsp
  sub rsp, 8
  mov QWORD PTR [rbp-8], rdi
  mov rax, QWORD PTR [rbp-8]
  push rax
  mov rax, 0
  mov rcx, rax
  pop rax
  cmp rax, rcx
  sete al
  movzx rax, al
  cmp rax, 0
  je .sum_L0
  mov rax, 0
  mov rsp, rbp
  pop rbp
  ret
  jmp .sum_L1
.sum_L0:
  mov rax, QWORD PTR [rbp-8]
  push rax
  mov rax, QWORD PTR [rbp-8]
  push rax
  mov rax, 1
  mov rcx, rax
  pop rax
  sub rax, rcx
  mov rdi, rax
  call sum
  mov rcx, rax
  pop rax
  add rax, rcx
  mov rsp, rbp
  pop rbp
  ret
.sum_L1:
  mov rsp, rbp
  pop rbp
  ret
.intel_syntax noprefix
.global main
main:
  push rbp
  mov rbp, rsp
  sub rsp, 0
  mov rax, 5
  mov rdi, rax
  call sum
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
