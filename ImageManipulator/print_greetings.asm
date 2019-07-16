section .data
  string1 db '<Image Manipulator Program>', 0xa
  db 'USAGE:  Put some BMP images in the images folder', 0xa, 0

  ;<---------------------------------------------------------------------->

%macro print_greetings 0
  save_before_io
  print string1
  restore_after_io
%endmacro

  ;<---------------------------------------------------------------------->
