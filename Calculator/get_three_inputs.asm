  ;<---------------------------------------------------------------------->

%macro get_three_inputs 3
  save_before_io
  push %3
  push %2
  push %1
  call get_three_inputs_func
  restore_after_io
%endmacro

    ;<---------------------------------------------------------------------->
;;get_three_input_func(*x, *y, *z) -> scanf 2 numbers and one character
get_three_inputs_func:
  entering

  ;Get and validate first input (Double)
  ;<------------------>
  mov rdi, double_format
  mov rsi, [rbp + 2*8]
  call scanf
  ;print_register rax

  cmp rax, 0
  jne get_three_inputs_func_continue1
  call confirm_R_character
  mov rax, qword[last_result]
  mov rbx, [rbp + 2*8]
  mov qword[rbx], rax
get_three_inputs_func_continue1:

  ;Get and validate second input (Sign)
  ;<------------------>

  mov rdi, string_format
  mov rsi, [rbp + 3*8]
  call scanf
  ;print_register rax
  push qword[rbp + 3*8]
  call is_char_valid

  ;Get and validate third input (Double)
  ;<------------------>

  mov rdi, double_format
  mov rsi, [rbp + 4*8]
  call scanf

  cmp rax, 0
  jne get_three_inputs_func_continue2
  call confirm_R_character
  mov rax, qword[last_result]
  mov rbx, [rbp + 4*8]
  mov qword[rbx], rax
get_three_inputs_func_continue2:

  leave
  ret 3*8
  ;<---------------------------------------------------------------------->

confirm_R_character:
  entering
  save_before_io

  mov rdi, string_format
  mov rsi, tmp_buffer
  call scanf

  mov rax, 0
  mov al, byte[R_char]
  cmp al, byte[tmp_buffer]
  jne exit

  mov rax, 0
  cmp al, byte[tmp_buffer + 1]
  jne exit

  restore_after_io
  leave
  ret

  ;<---------------------------------------------------------------------->
;;is_char_valid(*char)
is_char_valid:
  entering
  mov rax, [rbp + 2*8]
  mov rbx, 0
  cmp bl, byte[rax + 1]
  jne exit

  mov bl, byte[rax]
  cmp bl, byte[plusSign]
  je is_char_valid_end
  cmp bl, byte[minusSign]
  je is_char_valid_end
  cmp bl, byte[multSign]
  je is_char_valid_end
  cmp bl, byte[divSign]
  je is_char_valid_end
  jmp exit
is_char_valid_end:
  leave
  ret 1*8
