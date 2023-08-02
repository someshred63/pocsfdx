/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-09-17
*  Description: This is a helper class for handling ART Issue validation rules
*  Test class: GNE_SFA2_ART_Issue_Trigger_Test
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public without sharing class GNE_SFA2_ART_Issue_Validation_Rules {
    
    private static Boolean validateARTSiteMembership(List<ART_Issue_gne__c> triggerNew) {
        Boolean validationFailed = false;
        String currentUserProfileName = GNE_SFA2_Util.getCurrentUserProfileName();
        /*Set<String> mccoProfiles = GNE_SFA2_MCCO_Profiles__c.getAll().keySet();
        if(mccoProfiles.contains(currentUserProfileName)){
            Set<String> memberships = new Set<String>();
            for(ART_Team_gne__c membership : [ SELECT Id, ART_Site_gne__c, Team_Member_gne__c FROM ART_Team_gne__c ]) {
                memberships.add(((String) membership.ART_Site_gne__c) + ((String)membership.Team_Member_gne__c));
            }
          
            for(ART_Issue_gne__c artIssue : triggerNew) {
                if(!memberships.contains(artIssue.ART_Site_Local_gne__c + Userinfo.getUserId())) {
                    // current user is not a member of this ART Site
                    artIssue.ART_Site_Local_gne__c.addError(System.Label.Cannot_Add_ART_Issues);
                    validationFailed = true;
                }
            }
        }*/
        return validationFailed;
    }
    
    private static Boolean validateLocalMarketIssueNameChange(ART_Issue_gne__c oldValue, ART_Issue_gne__c newValue, String profileName) {
        Boolean result = false;
        if(oldValue.Name != newValue.Name) {
            if(!profileName.contains('GNE-SYS') && !profileName.contains('GNE-MCCO')
                    && !profileName.contains('Manager') && !profileName.equalsIgnoreCase('System Administrator')
                    && !profileName.startsWithIgnoreCase('GNE-SFA-Ops') && !profileName.equalsIgnoreCase('GNE-SFA-InternalUser')) {
                    
                newValue.addError(System.Label.Local_Market_Issue_Name_Change);
                result = true;
            }
        }
        return result;
    }
    
    private static Boolean validateLocalMarketIssueNameLength(ART_Issue_gne__c newValue) {
        Boolean result = false;
        if(newValue.Name.length() > 45) {
            newValue.addError(System.Label.Local_Market_Issue_Name_MaxLength);
            result = true;
        }
        return result;
    }
    
    private static Boolean validateResolutionTypeSelectedAndStatusClosed(ART_Issue_gne__c newValue) {
        Boolean result = false;
        if((newValue.Resolution_Type_gne__c != null && newValue.Resolution_Type_gne__c != '') && newValue.Issue_Status_gne__c == 'Open') {
            newValue.addError(System.Label.Resolution_Type_Selected_And_Status_Closed);
            result = true;
        }
        return result;
    }
    
    private static Boolean validateTypeIssueAndStatusClosed(ART_Issue_gne__c newValue) {
        Boolean result = false;
        if(newValue.Type_gne__c == 'Issue' && newValue.Issue_Status_gne__c == 'Closed' && (newValue.Resolution_Type_gne__c == null || newValue.Resolution_Type_gne__c == '')) {
            newValue.addError(System.Label.Type_Issue_And_Status_Closed);
            result = true;      
        }
        return result;
    }
    
    private static Boolean runValidationsOnUpdate(List<ART_Issue_gne__c> triggerOld, List<ART_Issue_gne__c> triggerNew) {
        Boolean result = false;
        
        for(Integer i = 0; i < triggerNew.size(); i++) {
            if(validateLocalMarketIssueNameChange(triggerOld[i], triggerNew[i], GNE_SFA2_Util.getCurrentUserProfileName())) {
                result = true;
                break;
            } else if(validateLocalMarketIssueNameLength(triggerNew[i])) {
                result = true;
                break;
            } else if(validateResolutionTypeSelectedAndStatusClosed(triggerNew[i])) {
                result = true;
                break;
            } else if(validateTypeIssueAndStatusClosed(triggerNew[i])) {
                result = true;
                break;
            }
        }
        return result;
    }
    
    private static Boolean runValidationsOnInsert(List<ART_Issue_gne__c> triggerNew) {
        Boolean result = false;
        for(Integer i = 0; i < triggerNew.size(); i++) {
            if(validateLocalMarketIssueNameLength(triggerNew[i])) {
                result = true;
                break;
            } else if(validateResolutionTypeSelectedAndStatusClosed(triggerNew[i])) {
                result = true;
                break;
            } else if(validateTypeIssueAndStatusClosed(triggerNew[i])) {
                result = true;
                break;
            }
        }
        return result;
    }
    
    public static Boolean onBeforeInsert(List<ART_Issue_gne__c> triggerNew) {
        return (validateARTSiteMembership(triggerNew) || runValidationsOnInsert(triggerNew));
    }
    
    public static Boolean onBeforeUpdate(List<ART_Issue_gne__c> triggerOld, List<ART_Issue_gne__c> triggerNew) {
        return (validateARTSiteMembership(triggerNew) || runValidationsOnUpdate(triggerOld, triggerNew));
    }
}