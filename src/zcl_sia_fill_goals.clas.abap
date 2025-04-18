CLASS zcl_sia_fill_goals DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES: if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_sia_fill_goals IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA:
      lt_goals TYPE STANDARD TABLE OF zist_goals,
      ls_goal  TYPE zist_goals,
      lv_user  TYPE sy-uname.

    DELETE FROM zist_goals.

    DO 6 TIMES.
      ls_goal-goal_id     = |{ sy-datum+4(4) }{ sy-uzeit+2(4) }{ sy-index }|.
      ls_goal-username    = sy-uname.
      ls_goal-goal_title  = |Goal #{ sy-index }|.
      ls_goal-goal_desc   = |Description # { sy-index }|.
      ls_goal-created_on  = sy-datum.
      APPEND ls_goal TO lt_goals.
    ENDDO.

    INSERT zist_goals FROM TABLE lt_goals.

    out->write( 'done' ).
  ENDMETHOD.
ENDCLASS.
