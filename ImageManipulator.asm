;Sam Mosleh 610395145
;Merge Sort data_list
;Run program with:
;nasm -f elf64 Calculator.asm
;ld -o run -e _start Calculator.o
;./run

BITS 64

section .data
  string1 db '<Image Manipulator Program>', 0xa
  db 'USAGE:  Put some BMP images in the images folder', 0xa, 0

  c_one db '1', 0
  c_zero db '0', 0
  stars db '********************', 0xa, 0
  string2 db 'Invalid input', 0xa, 0
  string3 db 'Something wrong happend!', 0xa, 0
  string4 db 'Number of chars:', 0xa, 0
  integer_format db '%d', 0
  integer_format2 db '%d', 0xa, 0
  integer_format3 db '%d ', 0
  floatp_format db '%f', 0
  double_format db '%lf', 0
  double_format2 db '= %lf', 0xa, 0
  string_format db '%s', 0
  char_format db '%c', 0

  longSize equ 8
  shortSize equ 2

  txt_files_postfix db './images/wow.txt', 0
  folder_prefix db './images/', 0
  endl db 0xa, 0

  zero dq 0.0

  SYS_READ equ 0
  SYS_WRITE equ 1
  SYS_OPEN equ 2
  SYS_CLOSE equ 3
  SYS_EXIT equ 60
  SYS_GETDENTS equ 78

  O_RDONLY equ 0
  STDIN equ 0
  STDOUT equ 1

section .bss
  tmp_buffer resb 80
  file_descriptor resq 1
  reg_digits resb 80

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

%macro print_return_number_of_chars 1
  push rdi
  push rsi
  ;push rax                      ;No pushing for this!
  push rbx                      ;Not for IO
  push rcx
  push rdx
  push r8
  push r9
  push r10
  push r11

  mov rdi, string_format
  mov rsi, %1
  mov rax, 0
  call printf

  pop r11
  pop r10
  pop r9
  pop r8
  pop rdx
  pop rcx
  pop rbx                       ;Only for the counter
  ;pop rax                       ;And no poping!
  pop rsi
  pop rdi
%endmacro

  ;<---------------------------------------------------------------------->

%macro print_greetings 0
  save_before_io
  call print_greetings_func
  restore_after_io
%endmacro

  ;<---------------------------------------------------------------------->

main:
  entering

  print_greetings
  call get_files_of_dir

  leave
  ret

  ;<---------------------------------------------------------------------->

exit:
  print string3
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

get_files_of_dir:
  entering

  mov rax, SYS_OPEN
  ;mov rdi, txt_files_postfix
  mov rdi, folder_prefix
  mov rsi, O_RDONLY
  syscall

  ;print_register rax

  mov qword[file_descriptor], rax

  mov r10, 1000                  ;Local space size
  sub rsp, r10                  ;Local space created

  ;xor rcx, rcx
;loop1:
  ;lea rbx, [rsp + rcx]
  ;mov qword[rbx], 0
  ;add rcx, 8
  ;cmp rcx, r10
  ;jb loop1

  mov rax, SYS_GETDENTS
  mov rdi, qword[file_descriptor]
  mov rsi, rsp
  mov rdx, r10
  syscall

  ;print_register rax

  ;print endl
  ;print endl
  ;print endl

  ;mov rax, qword[rsp]
  ;print_register rax
  ;print endl

  ;xor rax, rax
  ;xor rcx, rcx
;loop2:
  ;lea rbx, [rsp + rcx]
  ;mov al, byte[rbx]
  ;;print_register rax
  ;inc rcx
  ;cmp rcx, r10
  ;jb loop2


  xor rcx, rcx
  mov rdx, rsp
  ;print_register rsp
loop3:
  ;print_register rdx

  lea rdx, [rdx + 2*longSize + shortSize]
  ;print_register rbx
  print_return_number_of_chars rdx
  ;print endl
  ;print string4
  ;print_register rax

  add rax, 3
  mov rbx, rax                  ; Null terminated string

  ;print_register rbx
  add rbx, 7
  and rbx, -8                   ; First multiple of 8
  sub rbx, 2
  ;sub rbx, rax                  ; How much need to align
  add rdx, rbx                  ; Align
  print endl
  ;print_register rbx
  ;print_register rdx
  ;print stars
  inc rcx
  cmp rcx, 6
  jb loop3

  leave
  ret
