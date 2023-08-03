trigger CFAR_TeamMemberTrigger on CFAR_Team_Member_gne__c(after insert, after update) {

	if(Trigger.isAfter && Trigger.isUpdate && !Test.isRunningTest()){
		CFAR_Utils.updateRdts(trigger.newMap);	
	}

	if (CFAR_ConfigUtil.isTriggerEnabled(new List<String> {'CFAR_TeamMemberTrigger', 'CFAR_Team_Member_gne__c'})) {
		Map<String, String> roleMapping = CFAR_Utils.getUserRoleMapping();
		Map<Id, CFAR_Trial_gne__c> trialsToValidateMap = new Map<Id, CFAR_Trial_gne__c>();
		Map<Id, CFAR_Trial_gne__c> trialsToUpdateMap = new Map<Id, CFAR_Trial_gne__c>();
		Map<Id, Id> junctionToContactId = new Map<Id, Id>();
		Set<Id> relatedTrialsIds = new Set<Id>();
		Set<Id> relatedContactAddressIds = new Set<Id>();

		for (CFAR_Team_Member_gne__c tm : trigger.new) {
			if (tm.frm_Function_Role_gne__c == CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR && !tm.frm_Is_Inactive_gne__c
				&& (Trigger.isInsert || Trigger.oldMap.get(tm.Id).Dollar_and_Drug_ref_gne__c != tm.Dollar_and_Drug_ref_gne__c)
			) {
				relatedTrialsIds.add(tm.CFAR_Trial_ref_gne__c);
			}
			if (tm.Active_On_gne__c != null && tm.Active_On_gne__c <= System.today() && !(tm.Inactive_On_gne__c != null && tm.Inactive_On_gne__c <= System.today())
				&& !String.isBlank(tm.Function_Role_gne__c) && CFAR_Team_Controller.INVESTIGATOR_ROLES_SET.contains(roleMapping.get(tm.Function_Role_gne__c))
			) {
				relatedContactAddressIds.add(tm.contact_address_ref_gne__c);
				relatedTrialsIds.add(tm.CFAR_Trial_ref_gne__c);
			}
		}

		if (!relatedTrialsIds.isEmpty()) {
			for (CFAR_Trial_gne__c trial : [SELECT Dollar_and_Drug_ref_gne__c, Investigator_ref_gne__c FROM CFAR_Trial_gne__c WHERE Id IN :relatedTrialsIds]) {
				trialsToValidateMap.put(trial.Id, trial);
			}
		}

		if (!relatedContactAddressIds.isEmpty()) {
			for (CFAR_Contact_Address_JO_gne__c junction : [SELECT CFAR_Contact_ref_gne__c FROM CFAR_Contact_Address_JO_gne__c WHERE Id IN :relatedContactAddressIds]) {
				junctionToContactId.put(junction.Id, junction.CFAR_Contact_ref_gne__c);
			}
		}

		for (CFAR_Team_Member_gne__c tm : trigger.new) {
			if (trialsToValidateMap.containsKey(tm.CFAR_Trial_ref_gne__c)
				&& tm.frm_Function_Role_gne__c == CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR && !tm.frm_Is_Inactive_gne__c
				&& (Trigger.isInsert || Trigger.oldMap.get(tm.Id).Dollar_and_Drug_ref_gne__c != tm.Dollar_and_Drug_ref_gne__c)
				&& tm.Dollar_and_Drug_ref_gne__c != trialsToValidateMap.get(tm.CFAR_Trial_ref_gne__c).Dollar_and_Drug_ref_gne__c
			) {
				trialsToUpdateMap.put(tm.CFAR_Trial_ref_gne__c, new CFAR_Trial_gne__c(Id = tm.CFAR_Trial_ref_gne__c, Dollar_and_Drug_ref_gne__c = tm.Dollar_and_Drug_ref_gne__c));
			}

			if (junctionToContactId.containsKey(tm.Contact_address_ref_gne__c) &&
				trialsToValidateMap.get(tm.CFAR_Trial_ref_gne__c).Investigator_ref_gne__c != junctionToContactId.get(tm.Contact_address_ref_gne__c)
			) {
				if (trialsToUpdateMap.containsKey(tm.CFAR_Trial_ref_gne__c)) {
					trialsToUpdateMap.get(tm.CFAR_Trial_ref_gne__c).Investigator_ref_gne__c = junctionToContactId.get(tm.Contact_address_ref_gne__c);
				} else {
					trialsToUpdateMap.put(tm.CFAR_Trial_ref_gne__c, new CFAR_Trial_gne__c(Id = tm.CFAR_Trial_ref_gne__c, Investigator_ref_gne__c = junctionToContactId.get(tm.Contact_address_ref_gne__c)));
				}
			}
		}

		if (!trialsToUpdateMap.isEmpty()) {
			CFAR_Utils.setAlreadyProcessed();
			update trialsToUpdateMap.values();
		}
	}
}