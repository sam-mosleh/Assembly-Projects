;Sam Mosleh 610395145
;Merge Sort data_list
;Run program with:
;nasm -f elf64 Calculator.asm
;ld -o run -e _start Calculator.o
;./run

BITS 64

section .data
  string1 db '<Calculator program>', 0xa
  db 'USAGE:  Use R character to use the last result', 0xa
  db '        And type like followings {1 + 2}', 0xa
  db '        This program can compute +, *, -, /:', 0xa, 0

  string2 db 'Invalid input', 0xa, 0
  integer_format db '%d', 0
  integer_format2 db '%d', 0xa, 0
  integer_format3 db '%d ', 0
  floatp_format db '%f', 0
  double_format db '%lf', 0
  string_format db '%s', 0
  char_format db '%c', 0
  R_char db 'R'

  endl db 0xa, 0

  zero dq 0.0

  SYS_EXIT equ 60
  STDIN equ 0
  STDOUT equ 1
  SYS_READ equ 0
  SYS_WRITE equ 1

section .bss
  last_result resq 1
  tmp_buffer resb 80
  a resq 1
  b resb 80
  c resq 1

section	.text
  global main
  extern printf
  extern scanf


  ;<---------------------------------------------------------------------->
%macro save_before_io 0
  push rdi
  push rsi
  push rax
  push rbx                      ;Not for IO
  push rcx
  push rdx
  push r8
  push r9
  push r10
  push r11
%endmacro

%macro restore_after_io 0
  pop r11
  pop r10
  pop r9
  pop r8
  pop rdx
  pop rcx
  pop rbx                       ;Only for the counter
  pop rax
  pop rsi
  pop rdi
%endmacro

  ;<---------------------------------------------------------------------->

%macro entering 0
  push rbp
  mov rbp, rsp
  and rsp, -16                  ;To make TheStack pointer multiple of 64bits
%endmacro

  ;<---------------------------------------------------------------------->

%macro make_redzone 0
  and rsp, -16
  sub rsp, 128                  ;RedZone for leaf functions
%endmacro

  ;<---------------------------------------------------------------------->

%macro print_register 1
  save_before_io
  push %1
  mov rdi, integer_format2
  pop rsi
  mov rax, 0
  call printf
  restore_after_io
%endmacro

  ;<---------------------------------------------------------------------->

%macro print 1
  save_before_io
  mov rdi, string_format
  mov rsi, %1
  mov rax, 0
  call printf
  restore_after_io
%endmacro

  ;<---------------------------------------------------------------------->

%macro print_double 1
  save_before_io
  mov rdi, double_format
  movq xmm0, %1
  mov rax, 1
  call printf
  print endl
  restore_after_io
%endmacro

  ;<---------------------------------------------------------------------->

%macro initialize_last_result 0
  push rax
  mov rax, qword[zero]
  mov qword[last_result], rax
  pop rax
%endmacro

  ;<---------------------------------------------------------------------->

%include 'calculate_result_by.asm'
%include 'get_three_inputs.asm'
%include 'print_the_result.asm'

  ;<---------------------------------------------------------------------->

main:
  entering

  initialize_last_result
  print string1

infinity_while:
  get_three_inputs a, b, c
  calculate_result_by a, b, c
  print_the_result
  jmp infinity_while

  leave
  ret

  ;<---------------------------------------------------------------------->

exit:
  print string2
  mov rax, SYS_EXIT
  mov rdi, 0
  syscall                       ;rax, rdi, rsi, rdx, r10, r8, r9

  ;<---------------------------------------------------------------------->
