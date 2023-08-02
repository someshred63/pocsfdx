/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-08-20
*  Description: This is a helper class for handling Affiliation validation rules
*  Test class: GNE_SFA2_Affiliation_Trigger_Test
*    
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public without sharing class GNE_SFA2_Affiliation_Validation_Rules {
    
    private static Boolean handleDrugRequiredAffiliationValidationRules(List<Affiliation_vod__c> triggerNew) {
        Boolean result = false;
        for(Affiliation_vod__c affiliation : triggerNew) {
            if((affiliation.Role_vod__c == 'Preferred AIC' || affiliation.Role_vod__c == 'Preferred Distributor') && affiliation.Drug_gne__c == null) {
                affiliation.adderror(System.Label.Drug_field_cannot_be_empty);
                result = true;
                break;
            }
        }
        return result;
    }
    
    private static Boolean handleAffiliationValidationOnInsertUpdate(Affiliation_vod__c affiliation) {
        Boolean result = false;
        if (affiliation.To_Account_vod__c != null && affiliation.To_Contact_vod__c != null) {
            affiliation.addError(System.Label.Only_One_To_Allowed_Label);
            result = true;
        }
        if (affiliation.From_Account_vod__c != null && affiliation.From_Contact_vod__c != null) {
            affiliation.addError(System.Label.Only_One_From_Allowed_Label);
            result = true;
        }
        if (affiliation.To_Account_vod__c == null && affiliation.To_Contact_vod__c == null) {
            affiliation.addError(System.Label.Must_Specify_To_Label);
            result = true;
        }
        if (affiliation.From_Account_vod__c == null && affiliation.From_Contact_vod__c == null) {
            affiliation.addError(System.Label.Must_Specify_From_Label);
            result = true;
        }
        return result;
    }
    
    private static Boolean handleAffiliationValidationsOnInsert(List<Affiliation_vod__c> triggerNew) {
        Boolean result = false;
        for(Affiliation_vod__c affiliation : triggerNew) {
            if(handleAffiliationValidationOnInsertUpdate(affiliation)) {
                result = true;
                break;
            }
        }
        return result;
    }
    
    private static Boolean handleAffiliationValidationsOnUpdate(List<Affiliation_vod__c> triggerOld, List<Affiliation_vod__c> triggerNew) {
        Boolean result = false;
        for(Integer i = 0; i < triggerNew.size(); i++) {
            if(handleAffiliationValidationOnInsertUpdate(triggerNew[i])) {
                result = true;
                break;
            }
            if (triggerNew[i].From_Account_vod__c != triggerOld[i].From_Account_vod__c ||
                triggerNew[i].To_Account_vod__c != triggerOld[i].To_Account_vod__c ||
                triggerNew[i].From_Contact_vod__c != triggerOld[i].From_Contact_vod__c ||
                triggerNew[i].To_Contact_vod__c != triggerOld[i].To_Contact_vod__c ) {
                    
                triggerNew[i].Id.addError(System.Label.Affiliation_Update_Lock_Label);
                result = true;
                break;
            }
        }
        return result;
    }
    
    private static Boolean validateToAndFromContacts(Affiliation_vod__c newAffiliation) {
        Boolean result = false;
        if(newAffiliation.To_Contact_vod__c != null && newAffiliation.To_Contact_vod__c == newAffiliation.From_Contact_vod__c) {
            result = true;
            newAffiliation.addError(System.Label.Affiliation_Same_From_to_Contacts);
        }
        return result;
    }
    
    private static Boolean validateAccountAddress(Affiliation_vod__c newAffiliation) {
        Boolean result = false;
        if(newAffiliation.Portal_Affiliation_gne__c && (newAffiliation.To_Address_gne__c == null || newAffiliation.From_Account_vod__c == null)) {
            result = true;
            newAffiliation.addError(System.Label.Affiliation_To_Account_To_Address_Empty);
        }
        return result;
    }
    
    private static Boolean validatePortalAffiliationEdit(Affiliation_vod__c oldAffiliation, Affiliation_vod__c newAffiliation, String currentUserProfile) {
        Boolean result = false;
        if(oldAffiliation.Child_affiliation_vod__c == newAffiliation.Child_affiliation_vod__c && oldAffiliation.Parent_vod__c == newAffiliation.Parent_vod__c
            && oldAffiliation.Portal_Affiliation_gne__c && !oldAffiliation.Portal_Validation_Flag_gne__c 
            && !(currentUserProfile.equalsIgnoreCase('System Administrator') || currentUserProfile.startsWith('GNE-SYS') || currentUserProfile.startsWith('GNE-SFA-InternalUser') || currentUserProfile.startsWithIgnoreCase('GNE-SFA-Ops'))) {
                newAffiliation.addError(System.Label.Affiliation_Portal_Affiliation);
                result = true; 
            }
        return result;
    }
    
    private static Boolean runValidationsOnInsert(List<Affiliation_vod__c> triggerNew) {
        Boolean result = false;
        for(Integer i = 0; i < triggerNew.size(); i++) {
            if(validateToAndFromContacts(triggerNew[i])) {
                result = true;
                break;
            } else if(validateAccountAddress(triggerNew[i])) {
                result = true;
                break;
            }
        }
        return result;
    }
    
     private static Boolean runValidationsOnUpdate(List<Affiliation_vod__c> triggerOld, List<Affiliation_vod__c> triggerNew) {
        Boolean result = false;
        String currentUserProfile = GNE_SFA2_Util.getCurrentUserProfileName();
        for(Integer i = 0; i < triggerNew.size(); i++) {
            if(validateToAndFromContacts(triggerNew[i])) {
                result = true;
                break;
            } else if(validateAccountAddress(triggerNew[i])) {
                result = true;
                break;
            } else if(validatePortalAffiliationEdit(triggerOld[i], triggerNew[i], currentUserProfile)) {
                result = true;
                break;
            }
        }
        return result;
    }
    
    public static Boolean onBeforeUpdate(List<Affiliation_vod__c> triggerOld, List<Affiliation_vod__c> triggerNew) {
    	return !GNE_SFA2_Util.isMergeMode() && (runValidationsOnUpdate(triggerOld, triggerNew) || handleDrugRequiredAffiliationValidationRules(triggerNew) 
                || handleAffiliationValidationsOnUpdate(triggerOld, triggerNew));
    }
    
    public static Boolean onBeforeInsert(List<Affiliation_vod__c> triggerNew) {
        return !GNE_SFA2_Util.isMergeMode() && (runValidationsOnInsert(triggerNew) || handleDrugRequiredAffiliationValidationRules(triggerNew)
                || handleAffiliationValidationsOnInsert(triggerNew));
    }
}