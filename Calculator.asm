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
  string3 db 'Something wrong happend!', 0xa, 0
  integer_format db '%d', 0
  integer_format2 db '%d', 0xa, 0
  integer_format3 db '%d ', 0
  floatp_format db '%f', 0
  double_format db '%lf', 0
  double_format2 db '= %lf', 0xa, 0
  string_format db '%s', 0
  char_format db '%c', 0
  R_char db 'R'

  plusSign db '+'
  minusSign db '-'
  multSign db '*'
  divSign db '/'

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

%macro print_greetings 0
  save_before_io
  call print_greetings_func
  restore_after_io
%endmacro

  ;<---------------------------------------------------------------------->

%macro get_three_inputs 3
  save_before_io
  push %3
  push %2
  push %1
  call get_three_inputs_func
  restore_after_io
%endmacro

  ;<---------------------------------------------------------------------->

%macro calculate_result_by 3
  save_before_io
  push %3
  push %2
  push %1
  call calculate_result_by_func
  restore_after_io
%endmacro

  ;<---------------------------------------------------------------------->

%macro print_the_result 0
  save_before_io
  call print_the_result_func
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
main:
  entering

  initialize_last_result
  print_greetings

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

  ;Get and validate first input (Double)
  ;<------------------>
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

  ;Get and validate second input (Sign)
  ;<------------------>

  mov rdi, string_format
  mov rsi, [rbp + 3*8]
  call scanf
  ;print_register rax
  push qword[rbp + 3*8]
  call is_char_valid

  ;Get and validate third input (Double)
  ;<------------------>

  mov rdi, double_format
  mov rsi, [rbp + 4*8]
  call scanf

  cmp rax, 0
  jne get_three_inputs_func_continue2
  call confirm_R_character
  mov rax, qword[last_result]
  mov rbx, [rbp + 4*8]
  mov qword[rbx], rax
get_three_inputs_func_continue2:

  leave
  ret 3*8

  ;<---------------------------------------------------------------------->

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

  ;<---------------------------------------------------------------------->
;;is_char_valid(*char)
is_char_valid:
  entering
  mov rax, [rbp + 2*8]
  mov rbx, 0
  cmp bl, byte[rax + 1]
  jne exit

  mov bl, byte[rax]
  cmp bl, byte[plusSign]
  je is_char_valid_end
  cmp bl, byte[minusSign]
  je is_char_valid_end
  cmp bl, byte[multSign]
  je is_char_valid_end
  cmp bl, byte[divSign]
  je is_char_valid_end
  jmp exit
is_char_valid_end:
  leave
  ret 1*8

  ;<---------------------------------------------------------------------->
;;calculate_result_by_func(*float, *char, *float) -> decide which type of operation to use
calculate_result_by_func:
  entering

  ;Load two doubles in XMM registers
  ;<------------------>

  mov rax, [rbp + 2*8]
  movq xmm0, qword[rax]
  mov rax, [rbp + 4*8]
  movq xmm1, qword[rax]

  ;Calculate result in the XMM0 (Double)
  ;<------------------>

  mov rax, [rbp + 3*8]
  mov bl, byte[rax]
  cmp bl, byte[plusSign]
  jne calculate_result_by_func_continue1
  addpd xmm0, xmm1
  jmp calculate_result_by_func_end
calculate_result_by_func_continue1:
  cmp bl, byte[minusSign]
  jne calculate_result_by_func_continue2
  subpd xmm0, xmm1
  jmp calculate_result_by_func_end
calculate_result_by_func_continue2:
  cmp bl, byte[multSign]
  jne calculate_result_by_func_continue3
  mulpd xmm0, xmm1
  jmp calculate_result_by_func_end
calculate_result_by_func_continue3:
  cmp bl, byte[divSign]
  jne calculate_result_by_func_continue4
  divpd xmm0, xmm1
  jmp calculate_result_by_func_end
calculate_result_by_func_continue4:
  print string3
  jmp exit
calculate_result_by_func_end:
  movq  qword[last_result], xmm0

  leave
  ret 3*8

  ;<---------------------------------------------------------------------->
;;print_the_result_func() -> Prints last_result by the policy
print_the_result_func:
  entering
  mov rdi, double_format2
  movq xmm0, qword[last_result]
  mov rax, 1
  call printf
  leave
  ret
