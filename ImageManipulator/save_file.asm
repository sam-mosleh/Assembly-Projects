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
