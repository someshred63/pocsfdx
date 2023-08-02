public class GNE_EM3_CALL_UTIL {

  public static Map<Id,Call2_vod__c> CallAfterInsert = new Map<Id,Call2_vod__c>();
  public static String userProfile = GNE_SFA2_Util.getCurrentUserProfileName();
  public static boolean firstRun = true; 
  
  
  @future 
  public static void updateCallDiscussion(List<Id> temp) {    
   List<Call2_Discussion_vod__c> tempList = [Select id from Call2_Discussion_vod__c where Id in :temp];
   update tempList;    
  }  
  
  public static Boolean isCurrentUserUseEDM() {
  	 return (userProfile.startsWith('GNE-TLS') 
            || userProfile.startsWith('GNE-MCCO-FRM') 
            || userProfile.startsWith('GNE-MedAffairs') 
            || userProfile.startsWith('GNE-SFA-OCC') 
            || userProfile.startsWith('GNE-SFA-PREP')
            || userProfile.startsWith('GNE-SFA-CC') 
            || userProfile.startsWith('GNE-SFA-HCV-RCC')
            || userProfile.startsWith('GNE-CRM'));
  }
  
  public static Boolean createSPvalidation(Call2_Discussion_vod__c recForValidation) {
    Boolean meetsBasicReqs = (recForValidation.Call2_vod__r.Completed_gne__c == true
                                && recForValidation.Event_Curriculum_gne__c != null 
                                && recForValidation.Call2_vod__r.Account_vod__c != null
                                && recForValidation.Call2_vod__r.Account_vod__r.isPersonAccount == true);

    Boolean isActivityTrainingDeck = (recForValidation.Activity_gne__c == '1:1 Training/Deck Update');

    if(userProfile.startsWith('GNE-TLS')) {
      return (meetsBasicReqs && isActivityTrainingDeck
              && recForValidation.Call2_vod__r.Interaction_Location_gne__c != null);
    }
    else if (userProfile.startsWith('GNE-MCCO-FRM')) {
      return (meetsBasicReqs 
              && recForValidation.Call2_vod__r.Interaction_Type_gne__c == '1:1 Training/Deck Update');
    }
    else if (userProfile.startsWith('GNE-MedAffairs')) {
      return (meetsBasicReqs
             && recForValidation.Call2_vod__r.Interaction_Type_gne__c == '1:1'
             && recForValidation.Call2_vod__r.Visit_Reason_gne__c == 'Speaker Training');
    }
    else if (userProfile.startsWith('GNE-SFA-OCC') || userProfile.startsWith('GNE-SFA-CC')) {
      return (meetsBasicReqs && isActivityTrainingDeck);
    }
    else if (userProfile.startsWith('GNE-SFA-PREP')) {
      return (meetsBasicReqs && isActivityTrainingDeck);
    }
    else if (userProfile.startsWith('GNE-SFA-HCV-RCC')) {
      return (meetsBasicReqs && isActivityTrainingDeck);
    }
    else {
      return false;
    }
  }

  public static String determineDeliveryMethod() {
    return '1:1 Training/Deck Update';
  }
}