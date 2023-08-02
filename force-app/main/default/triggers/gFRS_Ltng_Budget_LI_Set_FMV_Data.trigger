trigger gFRS_Ltng_Budget_LI_Set_FMV_Data on gFRS_Ltng_Request_Budget_Detail__c (after insert, after update) {
  //gFRS_Ltng_Util.linkBudgetLIsToFMV(trigger.new, trigger.oldMap );
  if (trigger.isAfter && trigger.isInsert){
      gFRS_Ltng_Util.afterinsert_linkBudgetLIsToFMV(trigger.new);
      }
  if (trigger.isAfter && trigger.isUpdate){
       gFRS_Ltng_Util.afterupdate_linkBudgetLIsToFMV(trigger.new,trigger.oldMap);
      }
}