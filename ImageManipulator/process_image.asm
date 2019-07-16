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
