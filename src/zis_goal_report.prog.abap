*&---------------------------------------------------------------------*
*& Report zis_goal_report
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zis_goal_report.

CLASS lcl_app DEFINITION.
  PUBLIC SECTION.
    DATA: mo_grid   TYPE REF TO cl_gui_alv_grid,
          mo_custom TYPE REF TO cl_gui_custom_container.

    METHODS:
      constructor,
      create_objects,
      display_alv,
      refresh_alv,
      handle_toolbar FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING e_object,
      handle_user_command FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm,
      handle_data_changed FOR EVENT data_changed OF cl_gui_alv_grid
        IMPORTING er_data_changed.

  PRIVATE SECTION.
    METHODS:
      set_layout RETURNING VALUE(rs_layout) TYPE lvc_s_layo,
      set_fieldcat RETURNING VALUE(rt_fcat) TYPE lvc_t_fcat.
ENDCLASS.

CLASS lcl_event_handler DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      on_user_command FOR EVENT added_function OF cl_salv_events
        IMPORTING e_salv_function.
ENDCLASS.

CLASS lcl_app IMPLEMENTATION.
  METHOD constructor.
    create_objects( ).
    display_alv( ).
  ENDMETHOD.

  METHOD create_objects.
    CREATE OBJECT mo_custom
      EXPORTING
        container_name = 'CONT'.

    CREATE OBJECT mo_grid
      EXPORTING
        i_parent = mo_custom.

    SET HANDLER: me->handle_toolbar FOR mo_grid,
                me->handle_user_command FOR mo_grid,
                me->handle_data_changed FOR mo_grid.
  ENDMETHOD.

  METHOD display_alv.
    DATA: lt_fcat TYPE lvc_t_fcat,
          ls_layout TYPE lvc_s_layo.

    lt_fcat = set_fieldcat( ).
    ls_layout = set_layout( ).

    mo_grid->set_table_for_first_display(
      EXPORTING
        is_layout                     = ls_layout
      CHANGING
        it_outtab                     = gt_data
        it_fieldcatalog              = lt_fcat
      EXCEPTIONS
        invalid_parameter_combination = 1
        program_error                = 2
        too_many_lines              = 3
        OTHERS                      = 4 ).
  ENDMETHOD.

  METHOD refresh_alv.
    mo_grid->refresh_table_display( ).
  ENDMETHOD.

  METHOD handle_toolbar.
    DATA: ls_toolbar TYPE stb_button.

    CLEAR ls_toolbar.
    ls_toolbar-function = 'SAVE'.
    ls_toolbar-icon = icon_system_save.
    ls_toolbar-quickinfo = 'Save'.
    ls_toolbar-text = 'Save'.
    APPEND ls_toolbar TO e_object->mt_toolbar.
  ENDMETHOD.

  METHOD handle_user_command.
    CASE e_ucomm.
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

  METHOD handle_data_changed.
    DATA: ls_mod_cells TYPE lvc_s_modi.

    LOOP AT er_data_changed->mt_good_cells INTO ls_mod_cells.
      MODIFY gt_data FROM gt_data INDEX ls_mod_cells-row_id.
    ENDLOOP.
  ENDMETHOD.

  METHOD set_layout.
    rs_layout-zebra = abap_true.
    rs_layout-cwidth_opt = abap_true.
    rs_layout-sel_mode = 'A'.
  ENDMETHOD.

  METHOD set_fieldcat.
    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name = 'ZIST_GOALS'
      CHANGING
        ct_fieldcat      = rt_fcat.
  ENDMETHOD.
ENDCLASS.

TABLES: zist_goals.

DATA: go_app TYPE REF TO lcl_app,
      gt_data TYPE TABLE OF zist_goals.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_user TYPE sy-uname DEFAULT sy-uname.
SELECTION-SCREEN END OF BLOCK b1.

START-OF-SELECTION.
  PERFORM get_data.
  CALL SCREEN 100.

*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
FORM get_data.
  SELECT * FROM zist_goals INTO TABLE gt_data
    WHERE username = p_user.
ENDFORM.

*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'MAIN100'.
  SET TITLEBAR 'TITLE100'.

  IF go_app IS NOT BOUND.
    CREATE OBJECT go_app.
  ENDIF.
ENDMODULE.

*&---------------------------------------------------------------------*
*& Module USER_COMMAND_0100 INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE sy-ucomm.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.
