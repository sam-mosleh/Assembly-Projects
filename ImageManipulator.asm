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
  string5 db 'File has been found:', 0
  string6 db 'Return value of the system call is:', 0
  string7 db '<Creating Folder>', 0xa, 0
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

%macro print_greetings 0
  save_before_io
  call print_greetings_func
  restore_after_io
%endmacro

  ;<---------------------------------------------------------------------->
;; The length of files is in RAX
%macro get_files_of_dir 2
  push r12
  save_before_io

  push %2
  push %1
  call get_files_of_dir_func

  restore_after_io
  mov rax, r12
  pop r12
%endmacro

  ;<---------------------------------------------------------------------->

%macro make_directory 1
  push rcx
  push rdi
  push rsi

  push %1
  call make_directory_func

  pop rsi
  pop rdi
  pop rcx
%endmacro

  ;<---------------------------------------------------------------------->

%macro goto_directory 1
  push rcx
  push rdi

  mov rax, SYS_CHDIR
  mov rdi, %1
  syscall
  ;print_register rax

  pop rdi
  pop rcx
%endmacro

  ;<---------------------------------------------------------------------->

%macro process_image 3
  push r12
  save_before_io

  push %3
  push %2
  push %1
  call process_image_func

  restore_after_io
  mov rax, r12
  pop r12
%endmacro

  ;<---------------------------------------------------------------------->

%macro save_file 3
  push rax
  push rcx
  push rdx
  push rdi
  push rsi
  push r11

  push %3
  push %2
  push %1
  call save_file_func

  pop r11
  pop rsi
  pop rdi
  pop rdx
  pop rcx
  pop rax
%endmacro

  ;<---------------------------------------------------------------------->
;;Approved!
%macro show_current_working_directory 0
  push rax
  push rbx
  push rcx
  push rdi
  push rsi
  push r11

  call show_current_working_directory_func

  pop r11
  pop rsi
  pop rdi
  pop rcx
  pop rbx
  pop rax
%endmacro

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

get_files_of_dir_func:
  entering
  mov r12, 0
  mov r9, qword[rbp + 3*8]
  mov r10, 1000                 ;Local space size
  sub rsp, r10                  ;Local space created

  ;Open the folder
  ;<------------------>

  mov rax, SYS_OPEN
  mov rdi, qword[rbp + 2*8]
  mov rsi, O_RDONLY
  syscall

  ;print_register rax

  mov qword[file_descriptor], rax

  ;Get folder items
  ;<------------------>

  mov rax, SYS_GETDENTS
  mov rdi, qword[file_descriptor]
  mov rsi, rsp
  mov rdx, r10
  syscall

  print_register rax
  mov r11, rax                  ; Size of read bytes in folder

  ;Iterate over {linux_dirent} structs
  ;<------------------>

  xor rcx, rcx
  mov rdx, rsp
get_files_of_dir_while1:
  lea rdx, [rdx + 2*longSize + shortSize]

  print string5
  print_return_number_of_chars rdx

  ;Save file name
  ;<------------------>
  cmp byte[rdx], '.'
  je get_files_of_dir_while1_dont_save
  call save_fileName
get_files_of_dir_while1_dont_save:

  ;Parse the struct which is in shape of {linux_dirent}
  ;<------------------>

  inc rax                       ; Null terminated string size
  lea rbx, [rax + shortSize]

  add rbx, 8
  and rbx, -8                   ; First multiple of 8
  sub rbx, shortSize            ; How much need to align
  add rdx, rbx                  ; Align
  print endl
  lea rax, [rbx + 2*longSize + shortSize]
  add rcx, rax
  cmp rcx, r11
  jb get_files_of_dir_while1


  ;Close folder
  ;<------------------>

  mov rax, SYS_CLOSE
  mov rdi, qword[file_descriptor]
  syscall

  leave
  ret 2*8

save_fileName:
  entering
  push rcx
  push rbx
  push rax

  mov rbx, 0
  mov rcx, rdx
  add rax, rdx
save_fileName_mainLoop:
  mov bl, byte[rcx]
  mov byte[r9 + r12], bl
  inc r12
  inc rcx
  cmp rcx, rax
  jbe save_fileName_mainLoop

  pop rax
  pop rbx
  pop rcx
  leave
  ret

make_directory_func:
  entering
  print string7
  mov rax, SYS_MKDIR
  mov rdi, qword[rbp + 2*8]
  mov rsi, 0q755
  syscall
  print string6
  print_register rax
  leave
  ret 2*8

process_image_func:
  entering

  ;Open image
  ;<------------------>

  mov rcx, qword[rbp + 2*8]
  mov r8, qword[rbp + 3*8]      ;r8 = image buffer pointer

  print rcx
  print endl

  mov rax, SYS_OPEN
  mov rdi, rcx
  mov rsi, O_RDONLY
  syscall
  mov qword[file_descriptor], rax

  ;Read image
  ;<------------------>
  mov rax, SYS_READ
  mov rdi, qword[file_descriptor]
  mov rsi, r8
  mov rdx, qword[rbp + 4*8]
  syscall


  xor r9, r9
  xor r10, r10
  xor r11, r11
  xor r12, r12

  mov r9d, dword[r8 + 2 + 4 + 4]              ; r9 = where image data starts
  mov r10d, dword[r8 + 2 + 4 + 4 + 4 + 4]     ; r10 = width of image
  mov r11d, dword[r8 + 2 + 4 + 4 + 4 + 4 + 4] ; r10 = height of image
  mov r12d, dword[r8 + 2]                     ; r12 = size of the image

  print_register r9
  print_register r10
  print_register r11

  mov rcx, r9
process_image_func_brighteningLoop:
  movzx rax, byte[r8 + rcx]
  add rax, 100                   ; Make 10 degrees brighter
  cmp rax, 255
  jb process_image_func_brighteningLoop_dontTouchColor
  mov rax, 255                  ; RAX = maximum brightness
process_image_func_brighteningLoop_dontTouchColor:
  mov byte[r8 + rcx], al
  inc rcx
  cmp rcx, r12
  jb process_image_func_brighteningLoop


  ;Close folder
  ;<------------------>

  mov rax, SYS_CLOSE
  mov rdi, qword[file_descriptor]
  syscall
  ;print_register rax

  mov rax, r12

  leave
  ret 3*8


save_file_func:
  entering

  ;Create file
  ;<------------------>

  mov rax, SYS_CREAT
  mov rdi, qword[rbp + 2*8]
  mov rsi, 0q755
  syscall
  mov qword[file_descriptor], rax

  ;Write file
  ;<------------------>
  mov rax, SYS_WRITE
  mov rdi, qword[file_descriptor]
  mov rsi, qword[rbp + 3*8]
  mov rdx, qword[rbp + 4*8]
  syscall
  ;print_register rax

  ;Close file
  ;<------------------>
  mov rax, SYS_CLOSE
  mov rdi, qword[file_descriptor]
  syscall
  ;print_register rax

  leave
  ret 3*8

show_current_working_directory_func:
  entering
  sub rsp, 200                  ; Make local memory
  mov rbx, rsp

  make_redZone
  mov rax, SYS_GETCWD
  mov rdi, rbx
  mov rsi, 200
  syscall

  print rbx
  print endl

  leave
  ret
