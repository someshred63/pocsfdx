/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-10-10
*  Description: This is a helper class for GNE_SFA2_User_Trigger for handling User validation rules
*  Test class: GNE_SFA2_User_Trigger_Test
*    
*  Modification History
*  Date        Name        Description
*************************************************************/
public with sharing class GNE_SFA2_User_Validation_Rules {
    
    private static Boolean validateEmailUpdate(User oldValue, User newValue, Set<String> gstExternalProfileIds) {
        Boolean result = false;
        if(!GNE_SFA2_Util.getCurrentUserProfileName().equalsIgnoreCase('System Administrator') && !GNE_SFA2_Util.getCurrentUserProfileName().contains('GNE-SYS') && !GNE_SFA2_Util.getCurrentUserProfileName().equalsIgnoreCase('GNE-SFA-InternalUser') && !GNE_SFA2_Util.getCurrentUserProfileName().startsWithIgnoreCase('GNE-SFA-OPS') && !GNE_SFA2_Util.getCurrentUserProfileName().equalsIgnoreCase('RCanada-SFA-Ops') && !GNE_SFA2_Util.getCurrentUserProfileName().equalsIgnoreCase('RCanada-EMS-Ops') && !isGSTUpdate(newValue, gstExternalProfileIds) && oldValue.Email != newValue.Email) {
            newValue.addError(System.Label.User_Email_Update);
            result = true;
        }
        return result;
    }
    
    private static Boolean isGSTUpdate(User newValue, Set<String> gstExternalProfileIds) {

        if((GNE_SFA2_Util.getCurrentUserProfileName().equalsIgnoreCase('GNE-GST-Partner-External') || GNE_SFA2_Util.getCurrentUserProfileName().equalsIgnoreCase('GNE-GST-FOIM-BSA')) 
            && gstExternalProfileIds.contains(newValue.ProfileId))
            return true;

        return false;

    }
    private static Boolean validateCanadaGroupProfile(User newValue) {
        Boolean result = false;
        if(newValue.Profile_Name_gne__c != null && newValue.Role_Name_gne__c != null && newValue.Profile_Name_gne__c.containsIgnoreCase('Canada') && !newValue.Role_Name_gne__c.containsIgnoreCase('Canada')) {
            newValue.addError(System.Label.Canada_Profile_Role);
            result = true;
        } else if(newValue.Profile_Name_gne__c != null && newValue.Role_Name_gne__c != null && !newValue.Profile_Name_gne__c.containsIgnoreCase('Canada') && newValue.Role_Name_gne__c.containsIgnoreCase('Canada')) {
            newValue.addError(System.Label.Canada_Role_Profile);
            result = true;
        }
        return result;
    }
    
    private static Boolean runValidationsOnUpdate(List<User> triggerOld, List<User> triggerNew) {
        Boolean result = false;

        Set<String> gstProfileIds = new Set<String>();
        Set<String> gstProfileNames = new Set<String>{'GNE-GST-Partner-External'};
        for(Profile gstProd : [SELECT Name FROM Profile WHERE Name in :gstProfileNames]) {
            gstProfileIds.add(gstProd.Id);
        }
        
        for(Integer i = 0; i < triggerNew.size(); i++) {
            if(validateEmailUpdate(triggerOld[i], triggerNew[i], gstProfileIds)) {
                result = true;
                break;
            } else if(validateCanadaGroupProfile(triggerNew[i])) {
                result = true;
                break;
            }
        }
        return result;
    }
    
    private static Boolean runValidationsOnInsert(List<User> triggerNew) {
        Boolean result = false;
        for(Integer i = 0; i < triggerNew.size(); i++) {
            if(validateCanadaGroupProfile(triggerNew[i])) {
                result = true;
                break;
            }
        }
        return result;
    }
    
    public static Boolean onBeforeInsert(List<User> triggerNew) {
        return runValidationsOnInsert(triggerNew);
    }
    
    public static Boolean onBeforeUpdate(List<User> triggerOld, List<User> triggerNew) {
        return runValidationsOnUpdate(triggerOld, triggerNew);
    }
}