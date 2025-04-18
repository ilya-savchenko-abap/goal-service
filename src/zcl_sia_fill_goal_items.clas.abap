CLASS zcl_sia_fill_goal_items DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES: if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_sia_fill_goal_items IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA:
      lt_items TYPE STANDARD TABLE OF zist_goal_items,
      ls_item  TYPE zist_goal_items,
      lt_goals TYPE STANDARD TABLE OF zist_goals.

    " First, get existing goals
    SELECT * FROM zist_goals INTO TABLE lt_goals.

    " Delete existing items
    DELETE FROM zist_goal_items.

    " Create 3 subgoals for each goal
    LOOP AT lt_goals ASSIGNING FIELD-SYMBOL(&lt;goal>).
      DO 3 TIMES.
        ls_item-subgoal_id   = |{ sy-datum+4(4) }{ sy-uzeit+2(4) }{ sy-index }|.
        ls_item-goal_id      = &lt;goal>-goal_id.
        ls_item-subgoal_title = |Subgoal { sy-index } for Goal { &lt;goal>-goal_id }|.
        ls_item-subgoal_desc = |Description for subgoal { sy-index } of goal { &lt;goal>-goal_id }|.
        ls_item-status      = COND #( WHEN sy-index = 1 THEN 'C'  " Completed
                                     WHEN sy-index = 2 THEN 'P'  " In Progress
                                     ELSE 'N' ).               " Not Started
        ls_item-created_on   = sy-datum.
        APPEND ls_item TO lt_items.
      ENDDO.
    ENDLOOP.

    " Insert all subgoals
    INSERT zist_goal_items FROM TABLE lt_items.

    out->write( |{ lines( lt_items ) } subgoals created successfully!| ).
  ENDMETHOD.
ENDCLASS.