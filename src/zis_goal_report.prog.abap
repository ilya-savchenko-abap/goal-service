*&---------------------------------------------------------------------*
*& Report zis_goal_report
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zis_goal_report.

PARAMETERS: p_user TYPE sy-uname DEFAULT sy-uname.

TYPES: BEGIN OF ty_goals,
         username    TYPE zist_goals-username,
         goal_id     TYPE zist_goals-goal_id,
         goal_desc   TYPE zist_goals-goal_desc,
         status      TYPE zist_goals-status,
         create_date TYPE zist_goals-create_date,
       END OF ty_goals.

DATA: gt_data    TYPE TABLE OF ty_goals,
      gt_fcat    TYPE lvc_t_fcat,
      gs_layout  TYPE lvc_s_layo,
      gv_ok_code TYPE sy-ucomm.

CLASS lcl_handler DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS:
      on_data_changed FOR EVENT data_changed OF cl_gui_alv_grid
        IMPORTING er_data_changed,
      on_toolbar FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING e_object,
      on_user_command FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm.
ENDCLASS.

CLASS lcl_handler IMPLEMENTATION.
  METHOD on_data_changed.
    DATA: ls_mod_cells TYPE lvc_s_modi.

    LOOP AT er_data_changed->mt_good_cells INTO ls_mod_cells.
      MODIFY gt_data FROM gt_data INDEX ls_mod_cells-row_id.
    ENDLOOP.
  ENDMETHOD.

  METHOD on_toolbar.
    DATA: ls_toolbar TYPE stb_button.

    CLEAR ls_toolbar.
    ls_toolbar-function = 'SAVE'.
    ls_toolbar-icon = '@2L@'.
    ls_toolbar-quickinfo = 'Save'.
    ls_toolbar-text = 'Save'.
    APPEND ls_toolbar TO e_object->mt_toolbar.
  ENDMETHOD.

  METHOD on_user_command.
    CASE e_ucomm.
      WHEN 'SAVE'.
        MODIFY zist_goals FROM TABLE gt_data.
        IF sy-subrc = 0.
          MESSAGE 'Data saved successfully' TYPE 'S'.
        ENDIF.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.
  SELECT * FROM zist_goals
    INTO CORRESPONDING FIELDS OF TABLE gt_data
    WHERE username = p_user.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = 'ZIST_GOALS'
    CHANGING
      ct_fieldcat      = gt_fcat.

  gs_layout-zebra = 'X'.
  gs_layout-sel_mode = 'A'.
  gs_layout-edit = 'X'.

  DATA: go_grid TYPE REF TO cl_gui_alv_grid,
        go_container TYPE REF TO cl_gui_custom_container.

  CREATE OBJECT go_container
    EXPORTING
      container_name = 'CONTAINER'.

  CREATE OBJECT go_grid
    EXPORTING
      i_parent = go_container.

  SET HANDLER lcl_handler=>on_data_changed FOR go_grid.
  SET HANDLER lcl_handler=>on_toolbar FOR go_grid.
  SET HANDLER lcl_handler=>on_user_command FOR go_grid.

  CALL METHOD go_grid->set_table_for_first_display
    EXPORTING
      is_layout       = gs_layout
    CHANGING
      it_outtab      = gt_data
      it_fieldcatalog = gt_fcat.

  CALL SCREEN 100.

*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'STANDARD'.
  SET TITLEBAR 'TITLE'.
ENDMODULE.

*&---------------------------------------------------------------------*
*& Module USER_COMMAND_0100 INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE gv_ok_code.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      LEAVE PROGRAM.
  ENDCASE.
ENDMODULE.