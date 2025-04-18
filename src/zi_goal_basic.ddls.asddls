@AbapCatalog.sqlViewName: 'ZIGOALBASIC'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Goal Basic Interface View'

define view ZI_GOAL_BASIC
  as select from zist_goals
{
  key goal_id      as GoalId,
      username     as Username,
      goal_title   as GoalTitle,
      goal_desc    as GoalDescription,
      created_on   as CreatedOn,
      
      /* Administrative Data */
      @Semantics.user.createdBy: true
      created_by   as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at   as CreatedAt,
      @Semantics.user.lastChangedBy: true
      changed_by   as ChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      changed_at   as ChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt
}