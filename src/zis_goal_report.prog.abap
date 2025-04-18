*&---------------------------------------------------------------------*
*& Report zis_goal_report
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zis_goal_report.

PARAMETERS: p_user TYPE sy-uname DEFAULT sy-uname.

DATA: lo_alv TYPE REF TO cl_salv_table,
      lt_data TYPE TABLE OF zist_goals.

SELECT * FROM zist_goals INTO TABLE lt_data
  WHERE username = sy-uname.

cl_salv_table=>factory(
  IMPORTING
    r_salv_table = lo_alv
  CHANGING
    t_table      = lt_data ).

lo_alv->display( ).
