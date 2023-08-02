trigger beforeUpdateAdditionalPharmacy on C_Ops_SPLOA_Additional_Pharmacy__c (before update) {

    C_Ops_SPLOA_Additional_Pharmacy__c newOne= trigger.new[0];    
    C_Ops_SPLOA_Additional_Pharmacy__c oldOne= trigger.old[0];
       
     if(trigger.IsUpdate && (!isITSupportUser())&& !FeatureManagement.checkPermission('C_OPS_SPLOA_dnabler')){
     
         C_Ops_SPLOA_Request__c parent=[select id, Assign_To__c, C_Ops_SPLOA_Request_Status__c from C_Ops_SPLOA_Request__c 
             where id=:oldOne.C_Ops_SPLOA_Request__c limit 1];
             
         if(parent==null) newOne.addError('This additional Parmamcy is not associated with any SPLOA request');
         else {
             if(parent.Assign_To__c==null || parent.Assign_To__c!=userInfo.getUserId()){
                 newOne.addError('You can not update an additional pharmacy when its parent SPLOA request is not assigned to you');
             }else if(parent.C_Ops_SPLOA_Request_Status__c!=null &&
                 (parent.C_Ops_SPLOA_Request_Status__c=='Cancelled' || parent.C_Ops_SPLOA_Request_Status__c=='Processed')){
                 newOne.addError('You can not update an additional pharamcy when its parent SPLOA request is completed');
             }
         }
     }
 
     
     
  
     
     private Boolean isITSupportUser(){
         List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
         String proflieName = PROFILE[0].Name;
         if(proflieName =='System Administrator' || proflieName =='GNE-SYS-Support' || proflieName =='GNE-LWO-CUSTOPS' || proflieName =='C-Ops SPLOA Profile') 
             return true;
         else   return false;
     }

}