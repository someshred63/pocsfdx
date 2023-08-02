/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-08-03
*  Description: This is a helper class used for validation in GNE_SFA2_Contact_Trigger trigger
*  Test class: GNE_SFA2_Contact_Trigger_Test
*    
*  Modification History
*  Date        Name        Description
*  2012-11-18  kwiatkol    Moved validation rules to the trigger
*************************************************************/

public with sharing class GNE_SFA2_Contact_Validation_Rules {
    
    private static Boolean checkExistingCallsReferenceContact(List<Contact> triggerOld) {
        Boolean result = false;
        for(Contact c : triggerOld) {
            Contact contact = GNE_SFA2_Contact_Trigger_Helper.contactsMap.get(c.Id);
            boolean interactionExists = false;
            if(contact != null) {
                for (Call2_vod__c call : contact.Call2_vod__r) {
                    interactionExists = true;
                    break;
                }
                if(interactionExists){
                    result = true;
                    c.Id.addError(System.Label.Cannot_Delete_Object_Call_References);
                }
            }
        }
        return result;
    }
    
    private static Boolean canadaPostalCodeValidation(Contact newContact) {
        Boolean result = false;
        if(GNE_SFA2_Util.isCanadaUser() && !String.isEmpty(newContact.MailingPostalCode)) {
            String regExString = '[A-Z]\\d[A-Z]\\s\\d[A-Z]\\d';
            Pattern p = Pattern.compile(regExString);
            Matcher matcher = p.matcher(newContact.MailingPostalCode);
            if(!matcher.matches()) {
                newContact.MailingPostalCode.addError(System.Label.Address_Invalid_Canada_Postal_Code);
                result = true;
            }
        }
        return result;
    }
    
    private static Boolean validateFaxNumberHelper(String faxNumber) {
        Boolean result = false;
        if(!String.isEmpty(faxNumber)){
            
            String a = '\\D*?(\\d\\D*?){10}';
            Pattern p = Pattern.compile(a);
            Matcher matcher = p.matcher(faxNumber);
            if(!matcher.matches()) {
                result = true;
            }
        }
        return result;
    }
    
    private static Boolean validateAlternateFaxFormat(Contact newContact) {
        if(validateFaxNumberHelper(newContact.Alternate_Fax_gne__c )){
            newContact.Alternate_Fax_gne__c.addError(System.Label.Alternate_Fax_Required);
            return true;
        } else {
            return false;
        }
    }
    
    private static Boolean validateFaxFormat(Contact newContact) {
        if(validateFaxNumberHelper(newContact.Fax)){
            newContact.Fax.addError(System.Label.Fax_Required);
            return true;
        } else {
            return false;
        }
    }
    
    private static Boolean validateDepartmentRequired(Contact newContact) {
        Boolean result = false;
        if(newContact.Contact_Type_gne__c == 'Department' && String.isEmpty(newContact.Department_gne__c)) {
            newContact.addError(System.Label.Department_Required);
            result = true;
        }
        return result;
    }
    
    private static Boolean validateNameRequired(Contact newContact) {
        Boolean result = false;
        if(newContact.Contact_Type_gne__c == 'Program' && String.isEmpty(newContact.Name_Other_gne__c)) {
            newContact.addError(System.Label.Name_Other_Required);
            result = true;
        }
        return result;
    }
    
    private static Boolean validateRoleRequired(Contact newContact) {
        Boolean result = false;
        if(newContact.Contact_Type_gne__c == 'Role' && String.isEmpty(newContact.Role_gne__c)) {
            newContact.addError(System.Label.Role_Required);
            result = true;
        }
        return result;
    }
    
    private static Boolean validateTitleRequired(Contact newContact) {
        Boolean result = false;
        if(newContact.Contact_Type_gne__c == 'Individual' && String.isEmpty(newContact.Title) && !GNE_SFA2_Util.isMccoCrmUser()) {
            newContact.addError(System.Label.Title_Required);
            result = true;
        }
        return result;
    }
    
    private static Boolean runValidationsOnInsertUpdate(List<Contact> triggerNew) {
        Boolean result = false;
        for(Integer i = 0; i < triggerNew.size(); i++) {
            if(canadaPostalCodeValidation(triggerNew[i])) {
                result = true;
                break;
            } else if(validateAlternateFaxFormat(triggerNew[i])) {
                result = true;
                break;
            } else if(validateFaxFormat(triggerNew[i])) {
                result = true;
                break;
            } else if(validateDepartmentRequired(triggerNew[i])) {
                result = true;
                break;
            } else if(validateNameRequired(triggerNew[i])) {
                result = true;
                break;
            } else if(validateRoleRequired(triggerNew[i])) {
                result = true;
                break;
            } else if(validateTitleRequired(triggerNew[i])) {
                result = true;
                break;
            }
        }
        return result;
    }
    
    public static Boolean onAfterDelete(List<Contact> triggerOld) {
        return !GNE_SFA2_Util.isMergeMode() && checkExistingCallsReferenceContact(triggerOld);
    }
    
    public static Boolean onBeforeInsert(List<Contact> triggerNew) {
        return !GNE_SFA2_Util.isMergeMode() && runValidationsOnInsertUpdate(triggerNew);
    }
    
    public static Boolean onBeforeUpdate(List<Contact> triggerOld, List<Contact> triggerNew) {
        return !GNE_SFA2_Util.isMergeMode() && runValidationsOnInsertUpdate(triggerNew);
    }
}