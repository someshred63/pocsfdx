public without sharing class CustomerInteractionController {
    
    
    @AuraEnabled
    public static list<gFRS_Ltng_Customer_Intraction__c> fetchCustomerInteractionData(Id appId){
        list<gFRS_Ltng_Customer_Intraction__c> customerIntList=[select id,name,Request_Id__c,Status__c,Active_Incident_Status__c,Description__c,Triaged_to__c,CreatedById from gFRS_Ltng_Customer_Intraction__c where Request_Id__c=:appId order by createddate desc ];
        if(customerIntList.size()>0){
        for(gFRS_Ltng_Customer_Intraction__c customer:customerIntList){
      gFRS_Ltng_Customer_Intraction__Share myCustomObject  = new gFRS_Ltng_Customer_Intraction__Share();
      myCustomObject.ParentId = customer.id;
      myCustomObject.UserOrGroupId = UserInfo.getUserId();
      myCustomObject.AccessLevel = 'EDIT';
      myCustomObject.RowCause = Schema.gFRS_Ltng_Customer_Intraction__Share.RowCause.Manual;
      Database.SaveResult jobShareInsertResult = Database.insert(myCustomObject,false);
        }
        }
        return customerIntList;
        
    }
    
}