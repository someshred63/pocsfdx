trigger gFRS_Ltng_CAFApp_Trigger on gFRS_Ltng_CAF_Application__c (after update) {
    
    for(gFRS_Ltng_CAF_Application__c cafApp : Trigger.new){
        
        gFRS_Ltng_CAF_Application__c cafAppOld = Trigger.oldMap.get(cafApp.Id);
        
        If((cafApp.Total_Approved_Amount__c != cafAppOld.Total_Approved_Amount__c)
           || (cafApp.Date_for_Limit_Calculation__c != cafAppOld.Date_for_Limit_Calculation__c)){
               
               GFRS_Ltng_OrgSettings__c myOrgCS = GFRS_Ltng_OrgSettings__c.getOrgDefaults();
               if(myOrgCS.CAF_App_for_Hybrid_Calculation__c != null){
                   if(cafApp.Id != myOrgCS.CAF_App_for_Hybrid_Calculation__c){
                       gFRS_Ltng_Copay_Util.doLimtCal(cafApp.Id);	    
                   }
               }            
           }        
    }   
    
    if(Trigger.isAfter && Trigger.isUpdate)
    {
        gFRS_Ltng_Copay_Util.submitForApprovalcopay(Trigger.new, Trigger.oldMap);        
    }
}