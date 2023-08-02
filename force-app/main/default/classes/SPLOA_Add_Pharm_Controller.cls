public class SPLOA_Add_Pharm_Controller {

    public void updatemainreq(List<C_Ops_SPLOA_Additional_Pharmacy__c> newList){
    Set<Id> reqStageIds = new Set<Id>();
         Set<Id> reqIds = new Set<Id>();
        for(C_Ops_SPLOA_Additional_Pharmacy__c addpharm :newList){
         if(addpharm.C_Ops_IAP_Requests_Stage__c != null  ){
               reqStageIds.add(addpharm.C_Ops_IAP_Requests_Stage__c);        
        	 }
         if(addpharm.C_Ops_SPLOA_Request__c != null && addpharm.C_Ops_IAP_Requests_Stage__c != null ){
               reqIds.add(addpharm.C_Ops_SPLOA_Request__c);        
        	 }    
         }
        Map<Id,C_Ops_SPLOA_Additional_Pharmacy__c> addPharmMap = new Map<Id,C_Ops_SPLOA_Additional_Pharmacy__c>([SELECT Id ,C_Ops_SPLOA_Request__c FROM C_Ops_SPLOA_Additional_Pharmacy__c WHERE C_Ops_SPLOA_Request__c =: reqIds AND C_Ops_IAP_Requests_Stage__c = NULL]);
    
     Delete addPharmMap.values();
    for(C_Ops_SPLOA_Additional_Pharmacy__c addpharm :newList){
         if(addpharm.C_Ops_SPLOA_Request__c != null && addpharm.C_Ops_IAP_Requests_Stage__c != null  ){
               addpharm.C_Ops_IAP_Requests_Stage__c = null;       
        	 }
         }
    
    }
}