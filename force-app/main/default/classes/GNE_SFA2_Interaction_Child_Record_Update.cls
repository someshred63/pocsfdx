/************************************************************
*  @author: Sreedhar Karukonda
*  Date: 12/13/2012
*  Description: This class GNE_SFA2_Interaction_Child_Record_Update handles updates Dependent objects and Referenced objects on Call2__vod__c object on DML operations
*  This class is being used in GNE_SFA2_Interaction_Trigger trigger
*
*  Modification History
*  Date         Name        Description
*  25.02.2014   hrycenkm    Refactoring code.
*
*************************************************************/

public without sharing class GNE_SFA2_Interaction_Child_Record_Update {

  public static void onAfterInsert (List<Call2_vod__c> triggerNew) {
    if (!GNE_SFA2_Util.isMergeMode()) {
      updateParentCallTimeStamp(null, triggerNew, false);
    }
  }

  public static void onAfterUpdate (List<Call2_vod__c> triggerNew) {
    if (!GNE_SFA2_Util.isMergeMode()) {
      updateParentCallTimeStamp(null, triggerNew, false);
      if (GNE_SFA2_Interaction_Util.PARENT_CALL_UPDATE_MODE != true) {
        updateCallDiscussion(triggerNew);
      }
    }
  }

  public static void onBeforeDelete (Map<Id, Call2_vod__c> triggerOldMap) {
    if (!GNE_SFA2_Util.isMergeMode()) {
      updateParentCallTimeStamp(triggerOldMap.values(), null, true);
      //updateXolairCategory(triggerOldMap.values());
      deleteIndependentInsights(triggerOldMap.values());
      archiveDeletedInteractions(JSON.serialize(triggerOldMap));
    }
  }

  private static void updateParentCallTimeStamp(List<Call2_vod__c> triggerOld, List<Call2_vod__c> triggerNew, Boolean isDelete) {
	  if(!GNE_SFA2_Interaction_Trigger_Helper.isOtrRequest() && !GNE_SFA2_Interaction_Trigger_Helper.isSfdcUiRequest()) {
	    Set<Call2_vod__c> parentCalls =  new Set<Call2_vod__c>();

	    for(Call2_vod__c call : isDelete ? triggerOld : triggerNew) {
	      if(String.isNotBlank(call.Parent_Call_vod__c)) {
	        parentCalls.add(new Call2_vod__c(Id = call.Parent_Call_vod__c));
	      }
	    }
	    
	    if(!parentCalls.isEmpty()) {
	      try {
	        GNE_SFA2_Interaction_Util.PARENT_CALL_UPDATE_MODE = true;
	        GNE_SFA2_Interaction_Trigger_Helper.setInteractionTrig(true);
	        update new List<Call2_vod__c>(parentCalls);
	      } catch (System.DmlException ex) {
	        List<Error_Log_gne__c> errorsToInsert = new List<Error_Log_gne__c>();
	        
	        for (Integer i = 0; i < ex.getNumDml(); i++) {
	          errorsToInsert.add(GNE_SFA2_Interaction_Util.createError('Call2_vod__c', 'Low', 'GNE_SFA2_Interaction_Child_Record_Update', 'Trigger', ex.getDmlMessage(i)));
	        }
	
	        if (!errorsToInsert.isEmpty()) {
            Database.insert(errorsToInsert, false);
	        }
	      } finally {
	        GNE_SFA2_Interaction_Util.PARENT_CALL_UPDATE_MODE = false;
	        GNE_SFA2_Interaction_Trigger_Helper.setInteractionTrig(false);
	      }
	    }
	  }
	}

  private static Boolean isFirstUpdate = true;
  private static void updateCallDiscussion(List<Call2_vod__c> triggerNew) {
    if(isFirstUpdate && GNE_EM3_CALL_UTIL.isCurrentUserUseEDM() && !Test.isRunningTest()) {
      updateCallDiscussionFuture(new Set<Id>(new Map<Id,Call2_vod__c>(triggerNew).keySet()));
      isFirstUpdate = false;
    }
  }
  
  @future
  public static void updateCallDiscussionFuture(Set<Id> callIds) {
    List<Call2_Discussion_vod__c> callDiscussion = [SELECT Id FROM Call2_Discussion_vod__c WHERE Call2_vod__c IN : callIds];
    update callDiscussion;
  }
  
  @future
  private static void archiveDeletedInteractions(String triggerOld) {

        Map<Id, Call2_vod__c> triggerOldMap = (Map<Id, Call2_vod__c>)JSON.deserialize(triggerOld, Map<Id, Call2_vod__c>.class);
        List<Call2_Deleted_gne__c> callDeletedToInsert = new List<Call2_Deleted_gne__c>();
        for (Call2_vod__c call : triggerOldMap.values()) {
            Call2_Deleted_gne__c callDeleted = new Call2_Deleted_gne__c(Call__c = Call.Id,
                                                                        Account_Plan_vod__c = call.Account_Plan_vod__c,
                                                                        Account_vod__c = call.Account_vod__c,
                                                                        Activity_Type__c = call.Activity_Type__c,
                                                                        Actual_Attendees_gne__c = call.Actual_Attendees_gne__c,
                                                                        Actual_Spend_Per_HCP_gne__c = call.Actual_Spend_Per_HCP_gne__c,
                                                                        Address_vod__c = call.Address_vod__c,
                                                                        Agenda_gne__c = call.Agenda_gne__c,
                                                                        Attendee_Type_vod__c = call.Attendee_Type_vod__c,
                                                                        Attendees_vod__c = call.Attendees_vod__c,
                                                                        Call_Comments_vod__c = call.Call_Comments_vod__c,
                                                                        Call_Date_vod__c = call.Call_Date_vod__c,
                                                                        Call_Datetime_vod__c = call.Call_Datetime_vod__c,
                                                                        Call_Type_vod__c = call.Call_Type_vod__c,
                                                                        Contact_vod__c = call.Contact_vod__c,
                                                                        Date_of_Interaction_gne__c = call.Date_of_Interaction_gne__c,
                                                                        Detailed_Products_vod__c = call.Detailed_Products_vod__c,
                                                                        Disbursed_To_vod__c = call.Disbursed_To_vod__c,
                                                                        Disclaimer_vod__c = call.Disclaimer_vod__c,
                                                                        Home_Office_Reporting_gne__c = call.Home_Office_Reporting_gne__c,
                                                                        Ideal_Outcomes_gne__c = call.Ideal_Outcomes_gne__c,
                                                                        Interaction_Location_gne__c = call.Interaction_Location_gne__c,
                                                                        Interaction_Method_gne__c = call.Interaction_Method_gne__c,
                                                                        Interaction_Status_gne__c = call.Interaction_Status_gne__c,
                                                                        Interaction_Type_gne__c = call.Interaction_Type_gne__c,
                                                                        Is_Parent_Call_vod__c = call.Is_Parent_Call_vod__c,
                                                                        Location_vod__c = call.License_vod__c,
                                                                        Meal_Amount_gne__c = call.Meal_Amount_gne__c,
                                                                        Meal_Expense_gne__c = call.Meal_Expense_gne__c,
                                                                        Medical_Event_vod__c = call.Medical_Event_vod__c,
                                                                        Meeting_Outcome_gne__c = call.Meeting_Outcome_gne__c,
                                                                        Meeting_Quality_gne__c = call.Meeting_Quality_gne__c,
                                                                        Mobile_Created_Datetime_vod__c = call.Mobile_Created_Datetime_vod__c,
                                                                        Mobile_ID_vod__c = call.Mobile_ID_vod__c,
                                                                        Mobile_Last_Modified_Datetime_vod__c = call.Mobile_Last_Modified_Datetime_vod__c,
                                                                        Next_Call_Notes_vod__c = call.Next_Call_Notes_vod__c,
                                                                        Next_Steps_gne__c = call.Next_Steps_gne__c,
                                                                        No_Disbursement_vod__c = call.No_Disbursement_vod__c,
                                                                        Override_Spend_Limit_gne__c = call.Override_Spend_Limit_gne__c,
                                                                        Parent_Address_vod__c = call.Parent_Address_vod__c,
                                                                        Parent_Call_vod__c = call.Parent_Call_vod__c,
                                                                        Planned__c = call.Planned__c,
                                                                        Planned_Attendees_gne__c = call.Planned_Attendees_gne__c,
                                                                        Planned_Date_gne__c = call.Planned_Date_gne__c,
                                                                        Planned_gne__c = call.Planned_gne__c,
                                                                        Pre_Call_Notes_vod__c = call.Pre_Call_Notes_vod__c,
                                                                        Property_vod__c = call.Property_vod__c,
                                                                        Purpose_of_Meeting_gne__c = call.Purpose_of_Meeting_gne__c,
                                                                        RecordType_gne__c = call.RecordTypeId,
                                                                        Request_Receipt_vod__c = call.Request_Receipt_vod__c,
                                                                        Sample_Card_vod__c = call.Sample_Card_vod__c,
                                                                        Signature_Date_vod__c = call.SFA_Brand_Go_Live_Date_gne__c,
                                                                        Signature_vod__c = call.Signature_vod__c,
                                                                        Significant_Event__c = call.Significant_Event__c,
                                                                        Status_vod__c = call.Status_vod__c,
                                                                        Subject_vod__c = call.Subject_vod__c,
                                                                        Submitted_By_Mobile_vod__c = call.Submitted_By_Mobile_vod__c,
                                                                        Territory_vod__c = call.Territory_vod__c,
                                                                        Territory_Id_gne__c = call.Territory_Id_gne__c,
                                                                        TLX_Activity_Id_gne__c = call.TLX_Activity_Id_gne__c
                                                                       );
            callDeletedToInsert.add(callDeleted);
        }

        if (!callDeletedToInsert.isEmpty()) {
            Database.SaveResult[] lsr = Database.Insert(callDeletedToInsert, false);
            integer i=0;
            for(Database.SaveResult sr : lsr){
                if(!sr.isSuccess()){
                    String errorMessage ='';
                    for(Database.Error err : sr.getErrors()){
                        errorMessage += err.getMessage();
                    }
                    Call2_vod__c oldRecord =triggerOldMap.get(callDeletedToInsert[i].Call__c);
                    if(oldRecord == null) { 
                        oldRecord = triggerOldMap.get(callDeletedToInsert[i].Parent_Call_vod__c);
                    }

                    if(oldRecord != null) { 
                        oldRecord.addError('Unable to archive the Call due to following exception:' +errorMessage);
                    }
                    i++;
                }
            }
        }
    }

    private static void deleteIndependentInsights(List<Call2_vod__c> triggerOld) {
        Set<String> enabledProfilesSet = new Set<String> {
                'RCanada-SFA-Ops', 'RCanada-SFA-Manager', 'RCanada-SFA-TS'
        };
        String userProfileName = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
        try{
            if(enabledProfilesSet.contains(userProfileName)) {
                List<Independent_Insight_vod__c> independentInsightsToDelete = new List<Independent_Insight_vod__c>();
                Set<String> callIdsSet = new Set<String>();
                for(Call2_vod__c call : triggerOld) {
                    callIdsSet.add(call.Id);
                }
                independentInsightsToDelete = [Select Id From Independent_Insight_vod__c Where Call2_vod__c In : callIdsSet];
                if(!independentInsightsToDelete.isEmpty()) {
                    Database.delete(independentInsightsToDelete);
                }
            }
        } catch(System.DmlException ex) {
            insert GNE_SFA2_Interaction_Util.createError('Independent_Insight_vod__c', 'Low', 'GNE_SFA2_Interaction_Child_Record_Update', 'Trigger', ex);
        }
    }
}