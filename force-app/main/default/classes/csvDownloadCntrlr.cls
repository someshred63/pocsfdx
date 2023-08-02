public  class csvDownloadCntrlr {
   @AuraEnabled(Cacheable = true)
    public static List<PRP_Site_Request__c> getSitesInfo(String prpid){
   return [select Site_Name__c,Address1__c, Address2__c,City__c,State__c,Zip__c,Request_Product__c,Site_Type__c,Site_Status__c,HIN_Number__c,Distributor_Number__c,Prospective_Termination_Date__c from PRP_Site_Request__c where Request__r.Id=:prpid];
    }
}