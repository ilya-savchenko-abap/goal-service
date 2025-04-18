*&---------------------------------------------------------------------*
*& Report zis_goal_report
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zis_goal_report.

CLASS lcl_event_handler DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      on_user_command FOR EVENT added_function OF cl_salv_events
        IMPORTING e_salv_function.
ENDCLASS.

CLASS lcl_event_handler IMPLEMENTATION.
  METHOD on_user_command.
    CASE e_salv_function.
      WHEN 'SAVE'.
        MODIFY zist_goals FROM TABLE gt_data.
        IF sy-subrc = 0.
          COMMIT WORK.
          MESSAGE 'Data saved successfully' TYPE 'S'.
        ELSE.
          MESSAGE 'Error saving data' TYPE 'E'.
        ENDIF.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.

TABLES: zist_goals.

DATA: go_alv  TYPE REF TO cl_salv_table,
      gt_data TYPE TABLE OF zist_goals,
      go_functions TYPE REF TO cl_salv_functions_list,
      go_display   TYPE REF TO cl_salv_display_settings,
      go_columns   TYPE REF TO cl_salv_columns_table,
      go_column    TYPE REF TO cl_salv_column_table,
      go_events    TYPE REF TO cl_salv_events_table.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_user TYPE sy-uname DEFAULT sy-uname.
SELECTION-SCREEN END OF BLOCK b1.

START-OF-SELECTION.
  PERFORM get_data.
  PERFORM display_alv.

*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
FORM get_data.
  SELECT * FROM zist_goals INTO TABLE gt_data
    WHERE username = p_user.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form display_alv
*&---------------------------------------------------------------------*
FORM display_alv.
  TRY.
      cl_salv_table=>factory(
        IMPORTING
          r_salv_table = go_alv
        CHANGING
          t_table      = gt_data ).

      go_functions = go_alv->get_functions( ).
      go_functions->set_all( abap_true ).
      go_functions->set_default( abap_true ).

      go_display = go_alv->get_display_settings( ).
      go_display->set_striped_pattern( abap_true ).

      go_columns = go_alv->get_columns( ).
      go_columns->set_optimize( abap_true ).

      LOOP AT go_columns->get( ) INTO go_column.
        go_column->set_edit( abap_true ).
      ENDLOOP.

      go_events = go_alv->get_event( ).
      SET HANDLER lcl_event_handler=>on_user_command FOR go_events.

      go_alv->display( ).

    CATCH cx_salv_msg
          cx_salv_not_found
          cx_salv_data_error.
      MESSAGE 'Error initializing ALV Grid' TYPE 'E'.
  ENDTRY.
ENDFORM.