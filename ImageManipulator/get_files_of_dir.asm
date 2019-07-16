section .data
  string5 db 'File has been found:', 0
  
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
