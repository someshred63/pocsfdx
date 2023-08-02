public class gFRS_CopayDiseasecntrl {

     @AuraEnabled    
    public static List <gFRS_CAF_Disease_State__c> fetchDisease(String recId) {    
            System.debug('RecordId'+recId);
        return [ SELECT Id, Name,Disease_Fund_Name__c,Approved__c,Fund_Type__c,Requested_Donation_Amount__c,Payment_Amount__c,Time_Frame_for_Requested_Donation__c  FROM gFRS_CAF_Disease_State__c where gFRS_CAF_Application__c=:recId ];    
            
    }  
    
    @AuraEnabled
    public static Boolean checkUserAccess(){
        User currentUser=[select profile.Name,ProfileId from user where id=:Userinfo.getUserId()];
    // List<PermissionSetAssignment> lstcurrentUserPerSet =[SELECT count(Id) FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name = 'GNE_GFRS_CAF_DS_EDIT'];
        List<PermissionSetAssignment> psas = [ select Id from PermissionSetAssignment where PermissionSetId IN ( select Id from PermissionSet where Name = :'GNE_GFRS_CAF_DS_EDI') and AssigneeId =:Userinfo.getUserId()];
 
        if(currentUser.profile.Name=='GNE-GFRS-Copay-Reviewer' || currentUser.profile.Name=='System Administrator' || psas.size() > 0){
            return true;
        }else{
            return false;
        }
    }
    
    @AuraEnabled
    public static void updateRecords(String jsonString){
        try{
            List<gFRS_CAF_Disease_State__c> records = (List<gFRS_CAF_Disease_State__c>) JSON.deserialize(jsonString, List<gFRS_CAF_Disease_State__c>.class);
            update records;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled    
    public static boolean updateDisTable( List < gFRS_CAF_Disease_State__c > updatedDiseasStateList ) {    
            
        try {  
          
            update updatedDiseasStateList;  
            return true;  
              
        } catch(Exception e) {  
          
            return false;  
              
        }  
            
    }    
    
}