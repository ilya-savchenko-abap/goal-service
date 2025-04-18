*&---------------------------------------------------------------------*
*& Report zis_goal_report
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zis_goal_report.

CLASS lcl_app DEFINITION.
  PUBLIC SECTION.
    DATA: mo_salv TYPE REF TO cl_salv_table.

    METHODS:
      constructor,
      display_data.

  PRIVATE SECTION.
    METHODS:
      set_columns,
      set_functions,
      set_layout,
      optimize_columns,
      set_handlers.
ENDCLASS.

TABLES: zist_goals.

DATA: go_app  TYPE REF TO lcl_app,
      gt_data TYPE TABLE OF zist_goals.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_user TYPE sy-uname DEFAULT sy-uname.
SELECTION-SCREEN END OF BLOCK b1.

CLASS lcl_app IMPLEMENTATION.
  METHOD constructor.
    display_data( ).
  ENDMETHOD.

  METHOD display_data.
    TRY.
        cl_salv_table=>factory(
          IMPORTING
            r_salv_table = mo_salv
          CHANGING
            t_table      = gt_data ).

        set_functions( ).
        set_columns( ).
        set_layout( ).
        optimize_columns( ).
        set_handlers( ).

        mo_salv->display( ).
      CATCH cx_salv_msg INTO DATA(lx_msg).
        MESSAGE lx_msg->get_text( ) TYPE 'E'.
    ENDTRY.
  ENDMETHOD.

  METHOD set_columns.
    DATA(lo_columns) = mo_salv->get_columns( ).
    DATA(lt_columns) = lo_columns->get( ).

    LOOP AT lt_columns ASSIGNING FIELD-SYMBOL(<ls_column>).
      DATA(lo_column) = lo_columns->get_column( <ls_column>-columnname ).
      CASE <ls_column>-columnname.
        WHEN 'USERNAME'.
          lo_column->set_short_text( 'User' ).
          lo_column->set_medium_text( 'Username' ).
          lo_column->set_long_text( 'System Username' ).
        WHEN 'GOAL_ID'.
          lo_column->set_short_text( 'Goal ID' ).
          lo_column->set_medium_text( 'Goal ID' ).
          lo_column->set_long_text( 'Goal Identifier' ).
        WHEN 'GOAL_DESC'.
          lo_column->set_short_text( 'Goal' ).
          lo_column->set_medium_text( 'Goal Desc' ).
          lo_column->set_long_text( 'Goal Description' ).
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD set_functions.
    DATA(lo_functions) = mo_salv->get_functions( ).
    lo_functions->set_all( abap_true ).
  ENDMETHOD.

  METHOD set_layout.
    DATA(lo_layout) = mo_salv->get_layout( ).
    DATA(ls_layout) = VALUE slis_layout_alv( zebra = abap_true ).
    lo_layout->set_default( abap_true ).
    lo_layout->set_key( VALUE salv_s_layout_key( report = sy-repid ) ).
  ENDMETHOD.

  METHOD optimize_columns.
    DATA(lo_columns) = mo_salv->get_columns( ).
    lo_columns->set_optimize( abap_true ).
  ENDMETHOD.

  METHOD set_handlers.
    DATA(lo_events) = mo_salv->get_event( ).
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.
  PERFORM get_data.
  CREATE OBJECT go_app.

*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
FORM get_data.
  SELECT * FROM zist_goals INTO TABLE gt_data
    WHERE username = p_user.
ENDFORM.