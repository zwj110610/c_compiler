.intel_syntax noprefix
.global main
main:
  push rbp
  mov rbp, rsp
  sub rsp, 8
  mov rax, 5
  mov QWORD PTR [rbp-8], rax
  mov rax, QWORD PTR [rbp-8]
  mov rcx, rax
  mov rax, 2
  push rax
  mov rax, 0
  pop rcx
  cmp rcx, rax
  sete al
  movzx rax, al
  cqo
  idiv rcx
  mov rax, rdx
  cmp rax, 0
  je .L0
  mov rax, 0
  mov rdi, rax
  call println_int
  jmp .L1
.L0:
  mov rax, 1
  mov rdi, rax
  call println_int
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
