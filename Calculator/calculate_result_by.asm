section .data
  string3 db 'Something wrong happend!', 0xa, 0

  plusSign db '+'
  minusSign db '-'
  multSign db '*'
  divSign db '/'

  ;<---------------------------------------------------------------------->

%macro calculate_result_by 3
  save_before_io
  push %3
  push %2
  push %1
  call calculate_result_by_func
  restore_after_io
%endmacro

  ;<---------------------------------------------------------------------->
;;calculate_result_by_func(*float, *char, *float) -> decide which type of operation to use
calculate_result_by_func:
  entering

  ;Load two doubles in XMM registers
  ;<------------------>

  mov rax, [rbp + 2*8]
  movq xmm0, qword[rax]
  mov rax, [rbp + 4*8]
  movq xmm1, qword[rax]

  ;Calculate result in the XMM0 (Double)
  ;<------------------>

  mov rax, [rbp + 3*8]
  mov bl, byte[rax]
  cmp bl, byte[plusSign]
  jne calculate_result_by_func_continue1
  addpd xmm0, xmm1
  jmp calculate_result_by_func_end
calculate_result_by_func_continue1:
  cmp bl, byte[minusSign]
  jne calculate_result_by_func_continue2
  subpd xmm0, xmm1
  jmp calculate_result_by_func_end
calculate_result_by_func_continue2:
  cmp bl, byte[multSign]
  jne calculate_result_by_func_continue3
  mulpd xmm0, xmm1
  jmp calculate_result_by_func_end
calculate_result_by_func_continue3:
  cmp bl, byte[divSign]
  jne calculate_result_by_func_continue4
  divpd xmm0, xmm1
  jmp calculate_result_by_func_end
calculate_result_by_func_continue4:
  print string3
  jmp exit
calculate_result_by_func_end:
  movq  qword[last_result], xmm0

  leave
  ret 3*8
