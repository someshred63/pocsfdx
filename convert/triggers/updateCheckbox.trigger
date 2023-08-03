/**
* @File Name:	updateCheckbox
* @Description: This trigger will set up theHAs attachments flag to true if any attachments are added and set to false when no attachments available. .
* @group: 		Apex Trigger
* @Modification Log	:
______________________________________________________________________________________
* Ver       Date        Author        Modification
* 1.0       2023-02-23  Rabindranath
*/
trigger updateCheckbox on Attachment (before insert,after delete) {
    
    if(Trigger.isInsert){
        List <SPCM_CARS_Payment_Packet__c>carsPaymentList = new List<SPCM_CARS_Payment_Packet__c>();
        Set <Id> carsIds = new  Set <Id>();
        for(Attachment att : trigger.New){
            //Check if added attachment is related to CARS Payment or not
            if(att.ParentId.getSobjectType() == SPCM_CARS_Payment_Packet__c.SobjectType){
                carsIds.add(att.ParentId);
            }
        }
        carsPaymentList = [select id, Has_Attachments__c from SPCM_CARS_Payment_Packet__c where id in : carsIds];
        if(carsPaymentList!=null && carsPaymentList.size()>0){
            for(SPCM_CARS_Payment_Packet__c acc : carsPaymentList){
                acc.Has_Attachments__c = true;
            }
            update carsPaymentList;
        }
    }
    else if(Trigger.isDelete){
        Set<Id> parentIds = new Set<Id>();
        List<SPCM_CARS_Payment_Packet__c> recordsToUpdate = new List<SPCM_CARS_Payment_Packet__c>();
        for(Attachment a : Trigger.old) {
            if(a.ParentId.getSobjectType() == SPCM_CARS_Payment_Packet__c.SobjectType){
                parentIds.add(a.ParentId);
            }
        }
        
        // Get the list of records with no attachments
        List<Attachment> recordsWithNoAttachments = [SELECT Id FROM Attachment WHERE ParentId = :parentIds];
        if (recordsWithNoAttachments.isEmpty()) {
            recordsToUpdate = [SELECT Id,Has_Attachments__c FROM SPCM_CARS_Payment_Packet__c WHERE Id = :parentIds];
            
            for (SPCM_CARS_Payment_Packet__c s : recordsToUpdate) {
                s.put('Has_Attachments__c', false);
            }
            
            
            // Update the records
            update recordsToUpdate;
        }
    }
}