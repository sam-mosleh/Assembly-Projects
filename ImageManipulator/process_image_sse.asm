section .data
align 16, db 0
  oneHundred_array db 100, 100, 100, 100
                   db 100, 100, 100, 100
                   db 100, 100, 100, 100
                   db 100, 100, 100, 100

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

  ;First Phase: Try to brighten pixels until aligned position found
  ;<------------------>
  mov rbx, r9
  add rbx, 15
  and rbx, -16                  ; First occurance of multiple of 16Bytes

  mov rcx, r9
process_image_func_firstBrighteningPhase:
  cmp rcx, rbx
  jge process_image_func_firstBrighteningPhase_end

  movzx rax, byte[r8 + rcx]
  add rax, 100
  cmp rax, 255
  jb process_image_func_firstBrighteningPhase_dontTouchColor
  mov rax, 255
process_image_func_firstBrighteningPhase_dontTouchColor:
  mov byte[r8 + rcx], al
  inc rcx
  jmp process_image_func_firstBrighteningPhase
process_image_func_firstBrighteningPhase_end:

  ;Second Phase: Using SSE registers for rest of pixels
  ;<------------------>
  movdqa xmm1, [oneHundred_array]
process_image_func_secondBrighteningPhase:
  movdqa xmm0, [r8 + rcx]
  paddusb xmm0, xmm1            ; Make it brighten
  ;psubusb xmm0, xmm1            ; Make it darker
  movdqa [r8 + rcx], xmm0
  add rcx, 16
  cmp rcx, r12
  jb process_image_func_secondBrighteningPhase

  ;Close folder
  ;<------------------>

  mov rax, SYS_CLOSE
  mov rdi, qword[file_descriptor]
  syscall
  ;print_register rax

  mov rax, r12

  leave
  ret 3*8
