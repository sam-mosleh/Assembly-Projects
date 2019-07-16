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
