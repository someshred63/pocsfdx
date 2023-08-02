/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-10-09
*  Description: This is a helper class for GNE_SFA2_Call_Key_Message_Trigger trigger for handling Call Key Message validation rules
*  Test class: GNE_SFA2_Call_Key_Message_Trigger_Test
*    
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_Call_K_M_Validation_Rules {
	
  public static Boolean onBeforeInsertUpdate(List<Call2_Key_Message_vod__c> triggerNew) {
    Boolean validationFailed = !checkLock(triggerNew, false);
    return validationFailed;
  }
  
  public static Boolean onBeforeDelete(List<Call2_Key_Message_vod__c> triggerOld) {
    Boolean validationFailed = !checkLock(triggerOld, true);
    return validationFailed;
  }
		
	
  private static Boolean checkLock(List<Call2_Key_Message_vod__c> recs, Boolean isDelete) {
  	Boolean isOk = true;
    
    if (GNE_SFA2_Call_Helper.getPerformSubmitCheck()) {
      for(Call2_Key_Message_vod__c keyMsg : recs) {
        if(GNE_SFA2_Call_Helper.isLocked(keyMsg.Call_Status_calc_gne__c)) {
          keyMsg.Call2_vod__c.addError(isDelete ? System.Label.GNE_SFA2_Submitted_Call_Delete_Error : System.Label.GNE_SFA2_Submitted_Call_Update_error);
          isOk = false;
        }
      }
    }
    
    return isOk;
  }
}