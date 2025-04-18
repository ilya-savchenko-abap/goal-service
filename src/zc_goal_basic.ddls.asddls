@AbapCatalog.sqlViewName: 'ZCGOALBASIC'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Goal Basic Consumption View'
@Metadata.allowExtensions: true
@Search.searchable: true

define view ZC_GOAL_BASIC
  as select from ZI_GOAL_BASIC
{
      @ObjectModel.text.element: ['GoalTitle']
  key GoalId,
      @Search.defaultSearchElement: true
      Username,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.7
      GoalTitle,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.7
      GoalDescription,
      CreatedOn,
      
      /* Administrative Data */
      CreatedBy,
      CreatedAt,
      ChangedBy,
      ChangedAt,
      LocalLastChangedAt
}