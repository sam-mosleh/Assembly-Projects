section .data
  string6 db 'Return value of the system call is:', 0
  string7 db '<Creating Folder>', 0xa, 0

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
