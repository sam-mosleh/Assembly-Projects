;Sam Mosleh 610395145
;Merge Sort data_list
;Run program with:
;nasm -f elf64 Calculator.asm
;ld -o run -e _start Calculator.o
;./run

section .data
  string1 db '<Calculator program>', 0xa, 'USAGE:  Use R character to use the last result', 0xa, 0

  integer_format db '%d', 0
  string_format db '%s', 0

  endl db 0xa, 0

  SYS_EXIT equ 60
  STDIN equ 0
  STDOUT equ 1
  SYS_READ equ 0
  SYS_WRITE equ 1

section .bss
  reg_digits  resq 80
  n resq 1
  array resq 100

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
%endmacro

  ;<---------------------------------------------------------------------->

%macro print_greetings 0
  save_before_io
  call print_greetings_func
  restore_before_io
%endmacro

  ;<---------------------------------------------------------------------->

%macro make_redzone 0
  and rsp, -16
  sub rsp, 128                  ;RedZone for leaf functions
%endmacro

  ;<---------------------------------------------------------------------->

main:
  entering

  print_greetings

  leave
  ret

  ;<---------------------------------------------------------------------->

exit:
  mov rax, SYS_EXIT
  mov rdi, 0
  syscall                       ;rax, rdi, rsi, rdx, r10, r8, r9

  ;<---------------------------------------------------------------------->
print_endl:
  entering
  mov rdi, string_format
  mov rsi, endl
  mov rax, 0
  call printf
  leave
  ret
  ;<---------------------------------------------------------------------->

print_greetings_func:
  entering

  mov rdi, string_format
  mov rsi, string1
  mov rax, 0
  call printf

  leave
  ret
