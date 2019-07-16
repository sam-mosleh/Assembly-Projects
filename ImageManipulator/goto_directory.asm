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
