public without sharing class AGS_EX_Request_Email_Controller {

    public String requestId {get; set;} 

    public List<CORE_Pub_License__c> getLicenses(){
        AGS_EX_Exclusion_Request_gne__c requestAccount = [SELECT AGS_EX_Account_Name_gne__r.MdmId_gne__c FROM AGS_EX_Exclusion_Request_gne__c WHERE Id = :requestId];
        return [SELECT Id, License_Number_gne__c, License_State_gne__c FROM CORE_Pub_License__c WHERE Party_Id_ref_gne__r.Mdm_Id_gne__c =:requestAccount.AGS_EX_Account_Name_gne__r.MdmId_gne__c AND (License_Status_gne__c = 'Active' OR Smpl_Ovrl_Elig_Flag_gne__c='Y')];
    }

    public List<AGS_EX_Exclusion_Requestor_gne__c>  getRequestors(){
        List<AGS_EX_Exclusion_Requestor_gne__c> requestors = [
            SELECT AGS_EX_Date_Of_Request_gne__c, AGS_EX_Requestor_Email_gne__c, AGS_EX_Exclusion_Request_gne__c, 
                AGS_EX_Requestor_Name_gne__c, AGS_EX_Requestor_Name_gne__r.Name FROM AGS_EX_Exclusion_Requestor_gne__c 
            WHERE AGS_EX_Exclusion_Request_gne__c = :requestId
        ];        
        return requestors;
    }

}