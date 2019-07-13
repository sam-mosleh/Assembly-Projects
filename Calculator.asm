;Sam Mosleh 610395145
;Merge Sort data_list
;Run program with:
;nasm -f elf64 Calculator.asm
;ld -o run -e _start Calculator.o
;./run

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
  fn dq 1.2
  R_char db 'R'

  plusSign db '+'
  minusSign db '-'
  multSign db '*'
  divSign db '/'

  endl db 0xa, 0

  zero dq 0.0
  forty_two dq 42.0

  SYS_EXIT equ 60
  STDIN equ 0
  STDOUT equ 1
  SYS_READ equ 0
  SYS_WRITE equ 1

section .bss
  my_string resb 80
  last_result resq 1
  tmp_buffer resb 80
  n resq 1
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

%macro print_greetings 0
  save_before_io
  call print_greetings_func
  restore_before_io
%endmacro

  ;<---------------------------------------------------------------------->

%macro get_three_inputs 3
  ;save_before_io
  push %3
  push %2
  push %1
  call get_three_inputs_func
  ;restore_before_io
%endmacro

  ;<---------------------------------------------------------------------->


%macro print 1
  mov rdi, string_format
  mov rsi, %1
  mov rax, 0
  call printf
%endmacro

  ;<---------------------------------------------------------------------->
main:
  entering

  ; Last_Result = 42
  mov rax, qword[forty_two]
  mov qword[last_result], rax

  print_greetings
  get_three_inputs a, b, c

  leave
  ret

  ;<---------------------------------------------------------------------->

exit:
  print string2
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

  ;<---------------------------------------------------------------------->
;;get_three_input_func(*x, *y, *z) -> scanf 2 numbers and one character
get_three_inputs_func:
  entering
  sub rsp, 8

  mov rdi, double_format
  mov rsi, [rbp + 2*8]
  call scanf
  ;print_register rax

  cmp rax, 0
  jne get_three_inputs_func_continue1
  call confirm_R_character
  mov rax, qword[last_result]
  mov rbx, [rbp + 2*8]
  mov qword[rbx], rax
get_three_inputs_func_continue1:

  ;<------------------>

  mov rdi, string_format
  mov rsi, [rbp + 3*8]
  call scanf
  ;print_register rax
  push qword[rbp + 3*8]
  call is_char_valid

  ;<------------------>

  mov rdi, double_format
  mov rsi, [rbp + 4*8]
  call scanf
  ;print_register rax

  cmp rax, 0
  jne get_three_inputs_func_continue2
  call confirm_R_character
  mov rax, qword[last_result]
  mov rbx, [rbp + 4*8]
  mov qword[rbx], rax
get_three_inputs_func_continue2:

  ;<------------------>

  ;mov rdi, string_format
  ;mov rsi, [rbp + 3*8]
  ;mov rax, 0
  ;call printf

  mov rax, [rbp + 2*8]
  mov rdi, double_format
  movq xmm0, qword[rax]
  mov rax, 1
  call printf

  print endl

  mov rax, [rbp + 4*8]
  mov rdi, double_format
  movq xmm0, qword[rax]
  mov rax, 1
  call printf

  ;print endl

  ;mov rax, [rbp + 2*8]
  ;movq xmm0, qword[rax]
  ;mov rax, [rbp + 4*8]
  ;movq xmm1, qword[rax]
  ;addpd xmm0, xmm1
  ;movq qword[n], xmm0

  ;print endl

  ;mov rdi, double_format
  ;movq xmm0, qword[n]
  ;mov rax, 1
  ;call printf
  ;print endl


  print [rbp + 3*8]
  print endl

  leave
  ret

confirm_R_character:
  entering
  save_before_io

  mov rdi, string_format
  mov rsi, tmp_buffer
  call scanf

  mov rax, 0
  mov al, byte[R_char]
  cmp al, byte[tmp_buffer]
  jne exit

  mov rax, 0
  cmp al, byte[tmp_buffer + 1]
  jne exit

  restore_after_io
  leave
  ret

is_char_valid:
  entering
  mov rax, [rbp + 2*8]
  mov rbx, 0
  cmp rbx, qword[rax + 1]
  jne exit

  
  leave
  ret 1*8
