;Sam Mosleh 610395145
;Merge Sort data_list
;Run program with:
;nasm -f elf64 Calculator.asm
;ld -o run -e _start Calculator.o
;./run
; MY_SUM=0; for i in $(seq 1 10); do TIME_RESULT="$(./run | tail -n 1)"; MY_SUM=$(( $MY_SUM + $TIME_RESULT )); echo "Added ${TIME_RESULT} and the result is ${MY_SUM}"; done
BITS 64

section .data
  stars db '********************', 0xa, 0
  string3 db 'Something wrong happend!', 0xa, 0
  string8 db 'Brightening started for ', 0
  string9 db '<Timing>', 0xa, 0
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

align 16, db 0
  arr db 250, 12, 13, 14, 15, 16, 17, 18
  dq 0
  ten db 10, 10, 10, 10, 10, 10, 10, 10
  dq 0

section .bss
alignb 16
  buffer resb 800
  image resb readBufferSize
  file_descriptor resq 1
  files resb 800
  start_time resq 1
  stop_time resq 1

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
;%include 'process_image.asm'
%include 'process_image_sse.asm'

  ;<---------------------------------------------------------------------->

%macro start_timing_saveTo 1
  cpuid
  rdtsc
  mov dword[%1], eax
  mov dword[%1 + 4], edx
  ;print_register qword[start_time]
%endmacro

%macro stop_timing_saveTo 1
  rdtscp
  mov dword[%1], eax
  mov dword[%1 + 4], edx
  ;print_register qword[stop_time]
  cpuid
%endmacro


main:
  entering

  print_greetings

  get_files_of_dir images_path, files
  ;mov rbx, rax

  make_directory result_folder
  goto_directory images_path

  ;mov dword[temp_num], 7
  ;mov dword[temp_num + 4], 13   ;temp_num = 13 * 2^32 + 7
  ;print_register qword[temp_num]

  start_timing_saveTo start_time

  mov rcx, files
main_processLoop:
  print stars
  print string8
  print rcx
  print endl

  process_image rcx, image, readBufferSize
  mov r12, rax                  ; Save image buffer size

  goto_directory parent         ; 2000 Cycles long
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

  stop_timing_saveTo stop_time

  print string9

  mov rax, qword[stop_time]
  mov rbx, qword[start_time]
  sub rax, rbx
  print_register rax

  ; movdqa xmm0, [arr]
  ; movdqa xmm1, [ten]
  ; paddusb xmm0, xmm1
  ; movdqa [buffer], xmm0
  ; movzx rax, byte[buffer]
  ; print_register rax

  leave
  ret

  ;<---------------------------------------------------------------------->

exit:
  print string3
  mov rax, SYS_EXIT
  mov rdi, 0
  syscall                       ;rax, rdi, rsi, rdx, r10, r8, r9

  ;<---------------------------------------------------------------------->
