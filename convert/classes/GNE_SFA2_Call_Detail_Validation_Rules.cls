/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-10-09
*  Description: This is a helper class for GNE_SFA2_Call_Detail_Trigger trigger for handling Call Detail validation rules
*  Test class: GNE_SFA2_Call_Detail_Trigger_Test
*    
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public without sharing class GNE_SFA2_Call_Detail_Validation_Rules {
	
  public static void onBeforeInsertUpdate(List<Call2_Detail_vod__c> triggerNew) {
  	checkLock(triggerNew, false);
  }
  
  public static void onBeforeDelete(List<Call2_Detail_vod__c> triggerOld) {
  	checkLock(triggerOld, true);
  }
  
  private static void checkLock(List<Call2_Detail_vod__c> recs, Boolean isDelete) {
    if (GNE_SFA2_Call_Helper.getPerformSubmitCheck()) {
      for(Call2_Detail_vod__c callDetail : recs) {
        if(GNE_SFA2_Call_Helper.isLocked(callDetail.Call_Status_calc_gne__c)) {
          callDetail.Call2_vod__c.addError(isDelete ? System.Label.GNE_SFA2_Submitted_Call_Delete_Error : System.Label.GNE_SFA2_Submitted_Call_Update_error);
        }
      }
    }
  }
}