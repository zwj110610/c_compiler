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
  pop rcx
  cmp rcx, rax
  sete al
  movzx rax, al
  cmp rax, 0
  je .L0
  mov rax, 0
  mov rsp, rbp
  pop rbp
  ret
  jmp .L1
.L0:
  mov rax, QWORD PTR [rbp-8]
  push rax
  mov rax, QWORD PTR [rbp-8]
  push rax
  mov rax, 1
  pop rcx
  sub rcx, rax
  mov rax, rcx
  mov rdi, rax
  call sum
  pop rcx
  add rax, rcx
  mov rsp, rbp
  pop rbp
  ret
.L1:
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
