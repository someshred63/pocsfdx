/************************************************************
*  @author: Sreedhar Karukonda
*  Date: 12/31/2012
*  Description: This class GNE_SFA2_Call_Discussion_Field_Updates handles field updates on Call2_Discussion_vod__c object on DML operations
*  This class is being used in GNE_SFA2_Call_Discussion_Trigger trigger
*  
*  Modification History
*  Date        Name        			Description
*************************************************************/

public with sharing class GNE_SFA2_Call_Discussion_Field_Updates {
	
	// On Before insert method
	public static void OnBeforeInsert (Map<Id,Call2_Discussion_vod__c> oldCallDiscMap,  List<Call2_Discussion_vod__c> newCallDiscList){
		checkLock(newCallDiscList, false);
		beforeCallDiscussionProcessing(newCallDiscList);
		medAffairsMoleculeChange(null, newCallDiscList);
		FRMAccountTacticUpdate(null, newCallDiscList, true);
		FRMTeamSetName(newCallDiscList);
	}
	// On Before update method
	public static void OnBeforeUpdate (Map<Id,Call2_Discussion_vod__c> oldCallDiscMap,  List<Call2_Discussion_vod__c> newCallDiscList){
		checkLock(newCallDiscList, false);
		beforeCallDiscussionProcessing(newCallDiscList);
		medAffairsMoleculeChange(oldCallDiscMap, newCallDiscList);
		FRMAccountTacticUpdate(oldCallDiscMap, newCallDiscList, false);
		FRMTeamSetName(newCallDiscList);
	}
	
	// On Before update method
	public static void OnBeforeDelete (Map<Id,Call2_Discussion_vod__c> oldCallDiscMap,  List<Call2_Discussion_vod__c> newCallDiscList){
		checkLock(oldCallDiscMap.values(), true);
	}	
	
	// On After insert method
	public static void OnAfterInsert (Map<Id,Call2_Discussion_vod__c> oldCallDiscMap,  List<Call2_Discussion_vod__c> newCallDiscList){
		assosiateChildCallMedicalEventToParentCall(oldCallDiscMap, newCallDiscList);
	}
	// On After update method
	public static void OnAfterUpdate (Map<Id,Call2_Discussion_vod__c> oldCallDiscMap,  List<Call2_Discussion_vod__c> newCallDiscList){
		assosiateChildCallMedicalEventToParentCall(oldCallDiscMap, newCallDiscList);
	}
	
  private static void checkLock(List<Call2_Discussion_vod__c> recs, Boolean isDelete) {
    if (GNE_SFA2_Call_Helper.getPerformSubmitCheck()) {
      for(Call2_Discussion_vod__c callDisc : recs) {
        if (!isDelete && callDisc.Override_Lock_vod__c==true) {
          callDisc.Override_Lock_vod__c = false;
        } else if(GNE_SFA2_Call_Helper.isLocked(callDisc.Call_Status_calc_gne__c)) {
          callDisc.Call2_vod__c.addError(isDelete ? System.Label.GNE_SFA2_Submitted_Call_Delete_Error : System.Label.GNE_SFA2_Submitted_Call_Update_error);
        }
      }
    }
  }
	
	//Implemented based on trigger VOD_CALL2_DISCUSSION_BEFORE_TRIGGER on Call2_Discussion_vod__c (before delete, before insert, before update) 
	private static void beforeCallDiscussionProcessing(List<Call2_Discussion_vod__c> newDiscList){
    Call2_Discussion_vod__c [] cRow = newDiscList;
    
    for(Call2_Discussion_vod__c cDisc : newDiscList) {
      if(String.isNotBlank(cDisc.Attendee_Type_vod__c) && String.isNotBlank(cDisc.Entity_Reference_Id_vod__c)) {
        if ('Person_Account_vod' == cDisc.Attendee_Type_vod__c  || 'Group_Account_vod' == cDisc.Attendee_Type_vod__c) {
          cDisc.Account_vod__c = cDisc.Entity_Reference_Id_vod__c; 
          cDisc.Entity_Reference_Id_vod__c = null;                      
        } else if ('Contact_vod' == cDisc.Attendee_Type_vod__c) {
          cDisc.Contact_vod__c = cDisc.Entity_Reference_Id_vod__c;
          cDisc.Entity_Reference_Id_vod__c = null;   
        } else if ('User_vod' == cDisc.Attendee_Type_vod__c) {
          cDisc.User_vod__c = cDisc.Entity_Reference_Id_vod__c;
          cDisc.Entity_Reference_Id_vod__c = null;   
        } else if ('Event_vod' == cDisc.Attendee_Type_vod__c) {
          cDisc.Medical_Event_vod__c = cDisc.Entity_Reference_Id_vod__c;
          cDisc.Entity_Reference_Id_vod__c = null;   
        }
      }
    }
	}
		
	private static void medAffairsMoleculeChange(Map<Id, Call2_Discussion_vod__c> oldDiscMap, List<Call2_Discussion_vod__c> newDiscList){
	    try {
	    	Map<String, Schema.RecordTypeInfo> cdRecordType = Schema.SObjectType.Call2_Discussion_vod__c.getRecordTypeInfosByName();
	    	Set<Id> medAffairsRecordTypes = new Set<Id>{
	    		cdRecordType.get('MedAffairs Interaction').getRecordTypeId(),
	    		cdRecordType.get('MedAffairs Planned Interaction').getRecordTypeId()
	    	};
	    	Map<Id, Product_vod__c> moleculeProducts = new Map<Id, Product_vod__c>();
	    	Boolean moleculesInitialized = false;
	        for (Call2_Discussion_vod__c call : newDiscList) {
	        	if (medAffairsRecordTypes.contains(call.RecordTypeId) == false || call.Product_vod__c == null) {
	        		continue;
	        	}	        	
	        	if (moleculesInitialized == false){
	        		moleculeProducts = getMedAffairsMoleculeProductsMap();
	        		moleculesInitialized = true;
	        		if (moleculeProducts.size() == 0){
	        			break;
	        		}	        		
	        	}
	        	if (moleculeProducts.containsKey(call.Product_vod__c)){
	        		Product_vod__c molecule = moleculeProducts.get(call.Product_vod__c);
	        		if (call.Molecule_gne__c != molecule.Name){
	        			call.Molecule_gne__c = molecule.Name;
	        		}
	        	}                
	        }
	    } catch(Exception e){
	        insert GNE_SFA2_Interaction_Util.createError('Call2_Discussion_vod__c', 'Low', 'GNE_SFA2_Call_Discussion_Field_Updates', 'ApexTrigger', e);
	    }
	}
	
	private static Map<Id, Product_vod__c> getMedAffairsMoleculeProductsMap(){
		Set<String> medAffairsMolecules = new Set<String>();
	    for (MedAffairs_Molecules_gne__c settingMolecule : MedAffairs_Molecules_gne__c.getAll().values()){
	    	medAffairsMolecules.add(settingMolecule.Molecule_Name_gne__c);
	    }
	    return medAffairsMolecules.size() == 0 ? new Map<Id, Product_vod__c>() : new Map<Id, Product_vod__c>([Select Id, Name From Product_vod__c Where 
	    	(DETAIL_PRODUCT_SUBTYPE_CODE_GNE__C = 'TheraDisease' Or Name = 'Non-Commercial Molecule') And Name In :medAffairsMolecules]);	    	    
	}
	
	//Implemented based trigger GNE_Call2_Discussion_FRM_Account_Tactic_Update on Call2_Discussion_vod__c (before insert, before update)
	private static void FRMAccountTacticUpdate(Map<Id, Call2_Discussion_vod__c> oldDiscMap, List<Call2_Discussion_vod__c> newDiscList, boolean isInsert){
      List<Id> accountTacticIds = new List<Id>();
	    List<Account_Tactic_vod__c> accountTactics = new List<Account_Tactic_vod__c>();
	    Map<Id, String> accountTacticsMap = new Map<Id, String>();
	    
	    // PREPARE DATA
	    // prepare Account Tactic ids and query
	    for (Call2_Discussion_vod__c callDiscussion : newDiscList) {
	        if(callDiscussion.Account_Tactic_vod__c != null){
	            accountTacticIds.add(callDiscussion.Account_Tactic_vod__c);
	        }
	    }
	    
      if(!accountTacticIds.isEmpty()) {     
			    accountTactics = [SELECT Id, Name FROM Account_Tactic_vod__c WHERE Id in : accountTacticIds];
			    // prepare map of Account Tactics to set in Call Discussion
			    for(Account_Tactic_vod__c accountTactic : accountTactics){
			        if(!accountTacticsMap.containsKey(accountTactic.Id)){
			            accountTacticsMap.put(accountTactic.Id, accountTactic.Name);
			        }
			    }
			    if (isInsert){
			        // just fill the Account Tactic on Call2_vod__c basing on Account_Tactic->Name
			        for (Call2_Discussion_vod__c callDiscussion : newDiscList) {
			            System.debug('JL::.. callDiscussion: '+callDiscussion); 
			            callDiscussion.FRM_Account_Tactic_Name_gne__c = accountTacticsMap.get(callDiscussion.Account_Tactic_vod__c);
			        }
			    }
			    if (!isInsert){
			        // check if Account_Tactic changed and update Account Tactic field on Call2 if so
			        // otherwise do not update this field
			        for (Call2_Discussion_vod__c callDiscussion : newDiscList) {
			            if (oldDiscMap.get(callDiscussion.Id).Account_Tactic_vod__c != callDiscussion.Account_Tactic_vod__c){
			                System.debug('JL::.. account tactic changed from: '+oldDiscMap.get(callDiscussion.Id).Account_Tactic_vod__c+' to: '+callDiscussion.Account_Tactic_vod__c);
			                callDiscussion.FRM_Account_Tactic_Name_gne__c = accountTacticsMap.get(callDiscussion.Account_Tactic_vod__c);
			            } else {
			                System.debug('JL::.. account tactic NOT changed from: '+oldDiscMap.get(callDiscussion.Id).Account_Tactic_vod__c+' to: '+callDiscussion.Account_Tactic_vod__c);
			            }
			        }   
			    }
      }
	}
	// implemented based trigger gne_PointChildMedicalEvent_to_Parent on Call2_Discussion_vod__c (after insert, after update)
	private static void assosiateChildCallMedicalEventToParentCall(Map<Id, Call2_Discussion_vod__c> oldDiscMap, List<Call2_Discussion_vod__c> newDiscList){
    List<Id> callDiscIds2Update = new List<Id>();
    Set<Id> medicalEventIds = new Set<Id>();
    List<Call2_Discussion_vod__c> callDs = new List<Call2_Discussion_vod__c>();
    
    // Build List of CallIds to query along with Reference from Medical Event to Parent
    for (Call2_Discussion_vod__c callD: newDiscList){
      if (callD.Medical_Event_vod__c != null){
        callDiscIds2Update.add(callD.Id);
        medicalEventIds.add(callD.Medical_Event_vod__c);
      }
    }
    
    if(!callDiscIds2Update.isEmpty()) {
      // Get references to Medical Event Parent    
      CallDs = [Select Id, Medical_Event_vod__r.Parent_Medical_Event_gne__c from Call2_Discussion_vod__c where Id in :callDiscIds2Update];
      // Clear this out to user again
      callDiscIds2Update.clear();
      Map<Id, Medical_Event_vod__c> medicalEventsMap = new Map<Id, Medical_Event_vod__c>([Select Id, Parent_Medical_Event_gne__c from Medical_Event_vod__c where id in :medicalEventIds]);
      
      for (Call2_Discussion_vod__c callD: callDs) {
        Medical_Event_vod__c me = medicalEventsMap.get(callD.Medical_Event_vod__c);
        
        if (me!=null && me.Parent_Medical_Event_gne__c != null){
          callDiscIds2Update.add(callD.Id);
        }
	    }
      
      if(!callDiscIds2Update.isEmpty()){
        medEventHandler_gne.changetoMedEventParent(callDiscIds2Update);
      }
    }
	}
	
    public static void FRMTeamSetName(List<Call2_Discussion_vod__c> newCallDiscList){
        String profileName = GNE_SFA2_Util.getCurrentUserProfileName().toUpperCase();
        Pattern frmPattern = Pattern.compile('GNE-MCCO-FRM-(\\w+FRM)-{0,1}\\w*');
        Matcher frmMatcher = frmPattern.matcher(profileName);
        String teamName;
        if(frmMatcher.find()) {
            teamName = frmMatcher.group(1);                        
        } else if(profileName.contains('GNE-CRM')) {
            teamName = 'CRM';
        }
        if(teamName != null) {
            for (Call2_Discussion_vod__c callDisc : newCallDiscList){
                callDisc.FRM_Team_gne__c = teamName;
            }
        }
    }	
}