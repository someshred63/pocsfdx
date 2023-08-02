/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-09-17
*  Description: This is a helper class for handling ART Issue field updates
*  Test class: GNE_SFA2_ART_Issue_Trigger_Test
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public without sharing class GNE_SFA2_ART_Issue_Field_Updates {
    
    private static void updateClosedDateOnUpdate(List<ART_Issue_gne__c> triggerOld, List<ART_Issue_gne__c> triggerNew) {
        for(Integer i = 0; i < triggerNew.size(); i++) {
            if(triggerOld[i].Issue_Status_gne__c == 'Open' && triggerNew[i].Issue_Status_gne__c == 'Closed' && triggerOld[i].Date_Closed_gne__c == null){
                triggerNew[i].Date_Closed_gne__c = System.today();
            } else if(triggerOld[i].Issue_Status_gne__c == 'Closed' && triggerNew[i].Issue_Status_gne__c == 'Open' && triggerOld[i].Date_Closed_gne__c != null){
                triggerNew[i].Date_Closed_gne__c = null;
            }
        }
    }
    
    private static void updateClosedDateOnInsert(List<ART_Issue_gne__c> triggerNew) {
        for(ART_Issue_gne__c artIssue : triggerNew) {
            if(artIssue.Issue_Status_gne__c == 'Open'){
                artIssue.Date_Closed_gne__c = null;
            } else if(artIssue.Issue_Status_gne__c == 'Closed'){
                artIssue.Date_Closed_gne__c = System.today();
            }
        }
    }
    
    public static void onBeforeInsert(List<ART_Issue_gne__c> triggerNew) {
        updateClosedDateOnInsert(triggerNew);
    }
    
    public static void onBeforeUpdate(List<ART_Issue_gne__c> triggerOld, List<ART_Issue_gne__c> triggerNew) {
        updateClosedDateOnUpdate(triggerOld, triggerNew);
    }
}