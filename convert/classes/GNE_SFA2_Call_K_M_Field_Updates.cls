/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-10-09
*  Description: This is a helper class for GNE_SFA2_Call_Key_Message_Trigger trigger for handling Call Key Message field updates
*  Test class: GNE_SFA2_Call_Key_Message_Trigger_Test
*    
*  Modification History
*  Date        Name        			Description
*************************************************************/
public with sharing class GNE_SFA2_Call_K_M_Field_Updates {
  
  public static void onBeforeInsertUpdate(List<Call2_Key_Message_vod__c> triggerNew) {
    updateFileds(triggerNew);	
  }
  
  private static void updateFileds(List<Call2_Key_Message_vod__c> triggerNew) {
    for(Call2_Key_Message_vod__c callKeyMessage : triggerNew)  {
      if (String.isNotBlank(callKeyMessage.Attendee_Type_vod__c) && String.isNotBlank(callKeyMessage.Entity_Reference_Id_vod__c)) {
        if (callKeyMessage.Attendee_Type_vod__c == 'Person_Account_vod' || callKeyMessage.Attendee_Type_vod__c == 'Group_Account_vod' ) {
          callKeyMessage.Account_vod__c = callKeyMessage.Entity_Reference_Id_vod__c;             
          callKeyMessage.Entity_Reference_Id_vod__c = null;
        } else if (callKeyMessage.Attendee_Type_vod__c == 'Contact_vod') {
          callKeyMessage.Contact_vod__c = callKeyMessage.Entity_Reference_Id_vod__c;
          callKeyMessage.Entity_Reference_Id_vod__c = null; 
        } else if (callKeyMessage.Attendee_Type_vod__c == 'User_vod') {
          callKeyMessage.User_vod__c = callKeyMessage.Entity_Reference_Id_vod__c;
          callKeyMessage.Entity_Reference_Id_vod__c = null; 
        }
      }
    }
  }
}