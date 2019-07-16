section .data
  double_format2 db '= %lf', 0xa, 0
  
  ;<---------------------------------------------------------------------->

%macro print_the_result 0
  save_before_io
  call print_the_result_func
  restore_after_io
%endmacro

  ;<---------------------------------------------------------------------->
;;print_the_result_func() -> Prints last_result by the policy
print_the_result_func:
  entering
  mov rdi, double_format2
  movq xmm0, qword[last_result]
  mov rax, 1
  call printf
  leave
  ret

