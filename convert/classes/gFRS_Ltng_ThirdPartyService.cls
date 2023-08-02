/**
* The gFRS_Ltng_ThirdPartyService class contains code responsible for implementing the business logic, validations 
* and updating the gFRS Third Party record
*
* The class follows the ServiceLayer design, which is part of seperation of concern Enterprise design pattern.
* The methods in service class should be concerned with implementation of business logic
*
* @author Veera Mylavarapu
* @see Class: gFRS_Ltng_reqDetailsController

*/
public Without Sharing class gFRS_Ltng_ThirdPartyService {
		
/**
* This method create the gfrs Third Party record 
*
* @param gfrs Third Party record
* @record id return 
*/    
    public static List<gFRS_Ltng_Third_Party__c> createthirdParty(List<gFRS_Ltng_Third_Party__c> thPartyRec){
        SavePoint sp = Database.setSavepoint();
        try{
            insert thPartyRec;
            return [Select id From gFRS_Ltng_Third_Party__c where Id IN:thPartyRec];
        }
        catch(Exception e){
            
            Database.rollback(sp);
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
    }
    
    
/**
* This method return the gfrs Third Party records 
*
* @param gfrs application record
* @record list 
*/    
    public static List<gFRS_Ltng_Third_Party__c> getthirdParties(String gFRSAppId){
        
        try{
            return [SELECT Id, Is_the_Third_Party_org_accredited__c, Is_Third_Party_org_owned_by_physicians__c, 
                    Third_Party_Company_Function__c, Third_Party_Contact_Email__c, 
                    Third_Party_Contact_First_Name__c, Third_Party_Contact_Last_Name__c,
                    gFRS_Application__c,  Third_party_Organization_type__c, Third_Party_Tax_ID__c,
                    Third_Party_Organization_s_website__c, sole_propiertor_or_single_member_LLC__c, 
                    whole_or_in_part_by_a_practicing_physic__c, whole_or_in_part_by_a_group_practice__c,
                    family_member_of_a_practicing_physician__c, Third_party_Organization_Name__c, Company_Name__c, Name
                    FROM gFRS_Ltng_Third_Party__c Where gFRS_Application__c=:gFRSAppId];
        }
        catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
    }
 /**
* This method create the gfrs Third Party record 
*
* @param gfrs Third Party record
* @record id return 
*/    
    public static void updatethirdParty(List<gFRS_Ltng_Third_Party__c> thPartyRec){
        SavePoint sp = Database.setSavepoint();
        try{
            update thPartyRec;
            //return [Select id From gFRS_Ltng_Third_Party__c where Id IN:thPartyRec];
        }
        catch(Exception e){
            
            Database.rollback(sp);
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
    }
       
/**
* This method Delete the gfrs Third Party record 
*
* @param gfrs Third Party record Id
* @record No return 
*/    
    public static void delthirdParty(List<gFRS_Ltng_Third_Party__c> thPartyRec){
        SavePoint sp = Database.setSavepoint();
        try{
            Delete thPartyRec;
            //return [Select id From gFRS_Ltng_Third_Party__c where Id IN:thPartyRec];
        }
        catch(Exception e){
            
            Database.rollback(sp);
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
    }   
    

}