;Sam Mosleh 610395145
;Merge Sort data_list
;Run program with:
;nasm -f elf64 Calculator.asm
;ld -o run -e _start Calculator.o
;./run

BITS 64

section .data
  stars db '********************', 0xa, 0
  string3 db 'Something wrong happend!', 0xa, 0
  string8 db 'Brightening started for ', 0
  integer_format db '%d', 0
  integer_format2 db '%lld', 0xa, 0
  integer_format3 db '%d ', 0
  floatp_format db '%f', 0
  double_format db '%lf', 0
  double_format2 db '= %lf', 0xa, 0
  string_format db '%s', 0
  char_format db '%c', 0

  longSize equ 8
  shortSize equ 2
  readBufferSize equ 800000

  images_path db './images/', 0
  result_folder db './changed_images/', 0
  parent db '../', 0
  endl db 0xa, 0

  zero dq 0.0

  SYS_READ equ 0
  SYS_WRITE equ 1
  SYS_OPEN equ 2
  SYS_CLOSE equ 3
  SYS_EXIT equ 60
  SYS_GETDENTS equ 78
  SYS_GETCWD equ 79
  SYS_CHDIR equ 80
  SYS_MKDIR equ 83
  SYS_CREAT equ 85

  O_RDONLY equ 0
  O_WRONLY equ 1
  STDIN equ 0
  STDOUT equ 1

  bufferSize equ 800

section .bss
  buffer resb 800
  image resb readBufferSize
  file_descriptor resq 1
  files resb 800

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

%macro make_redZone 0
  and rsp, -16
  sub rsp, 128                  ;RedZone for leaf functions
%endmacro

  ;<---------------------------------------------------------------------->

%macro print_register 1
  save_before_io
  mov rsi, %1
  mov rdi, integer_format2
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

%include 'make_directory.asm'
%include 'save_file.asm'
%include 'get_files_of_dir.asm'
%include 'print_greetings.asm'
%include 'show_working_directory.asm'
%include 'goto_directory.asm'
%include 'process_image.asm'

  ;<---------------------------------------------------------------------->

main:
  entering

  print_greetings

  get_files_of_dir images_path, files
  mov rbx, rax

  make_directory result_folder

  goto_directory images_path
  ;process_image files, image, readBufferSize
  ;save_file files, image, r10


  mov rcx, files
main_processLoop:
  print stars
  print string8
  process_image rcx, image, readBufferSize
  mov r12, rax                  ; Save image buffer size

  goto_directory parent
  goto_directory result_folder  ; Go to ../result

  save_file rcx, image, r12

  goto_directory parent
  goto_directory images_path  ; Go to ../images

  xor rax, rax
main_processLoop_findNextFileName:
  mov al, byte[rcx]
  inc rcx
  cmp al, 0
  jne main_processLoop_findNextFileName

  mov al, byte[rcx]
  cmp al, 0
  je main_processLoop_end

  jmp main_processLoop

main_processLoop_end:

  ;show_current_working_directory

  leave
  ret

  ;<---------------------------------------------------------------------->

exit:
  print string3
  mov rax, SYS_EXIT
  mov rdi, 0
  syscall                       ;rax, rdi, rsi, rdx, r10, r8, r9

  ;<---------------------------------------------------------------------->
