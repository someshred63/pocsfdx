trigger CFAR_TrialPicklist on CFAR_Trial_Picklist_gne__c (before insert, after insert, after delete) {

	if (trigger.isInsert && trigger.isBefore) {
		for (CFAR_Trial_Picklist_gne__c tp : Trigger.new) {
			tp.UniqueKey_gne__c = tp.CFAR_Trial_ref_gne__c + '-' + tp.CFAR_PicklistValue_ref_gne__c;
		}
	}

	if (CFAR_ConfigUtil.isTriggerEnabled(new List<String> {'CFAR_TrialPicklist', 'CFAR_Trial_Picklist_gne__c'}) && !(trigger.isInsert && trigger.isBefore)) {

		Map<Id, List<CFAR_Trial_Picklist_gne__c>> trialIdToPicklists = new Map<Id, List<CFAR_Trial_Picklist_gne__c>>();
		Map<Id, CFAR_Picklist_Value_gne__c> idToPicklistValues = new Map<Id, CFAR_Picklist_Value_gne__c>();
		Set<Id> trialsIds = new Set<Id>();
		Set<Id> pvIdsToPull = new Set<Id>();
		for (CFAR_Trial_Picklist_gne__c tp : trigger.isInsert ? Trigger.new : Trigger.old) {
			trialsIds.add(tp.CFAR_Trial_ref_gne__c);
			pvIdsToPull.add(tp.CFAR_PicklistValue_ref_gne__c);
			if (trialIdToPicklists.containsKey(tp.CFAR_Trial_ref_gne__c)) {
				trialIdToPicklists.get(tp.CFAR_Trial_ref_gne__c).add(tp);
			} else {
				trialIdToPicklists.put(tp.CFAR_Trial_ref_gne__c, new List<CFAR_Trial_Picklist_gne__c> {tp});
			}
		}

		for (CFAR_Picklist_Value_gne__c pv : [SELECT Name, RecordType.Name FROM CFAR_Picklist_Value_gne__c WHERE Active_gne__c = true AND Id IN :pvIdsToPull]) {
			idToPicklistValues.put(pv.Id, pv);
		}

		CFAR_Trial_gne__c[] impactedTrials = [SELECT Id, Impacts_gne__c FROM CFAR_Trial_gne__c WHERE Id IN :trialsIds];
		for (CFAR_Trial_gne__c impactedTrial : impactedTrials) {
			List<String> impactsToSort = String.isBlank(impactedTrial.Impacts_gne__c) ? new List<String>() : impactedTrial.Impacts_gne__c.split(';');
			for (CFAR_Trial_Picklist_gne__c tp : trialIdToPicklists.get(impactedTrial.Id)) {
				if (idToPicklistValues.get(tp.CFAR_PicklistValue_ref_gne__c).RecordType.Name == 'Impact') {
					if (trigger.isInsert) {
						if (String.isBlank(impactedTrial.Impacts_gne__c)) {
							impactedTrial.Impacts_gne__c = idToPicklistValues.get(tp.CFAR_PicklistValue_ref_gne__c).Name;
						} else {
							impactedTrial.Impacts_gne__c += ';' + idToPicklistValues.get(tp.CFAR_PicklistValue_ref_gne__c).Name;
						}
					} else if (trigger.isDelete) {
						String pvName = idToPicklistValues.get(tp.CFAR_PicklistValue_ref_gne__c).Name;
						if (impactedTrial.Impacts_gne__c != null && impactedTrial.Impacts_gne__c.contains(pvName)) {
							impactedTrial.Impacts_gne__c = impactedTrial.Impacts_gne__c.contains(pvName + ';') ? impactedTrial.Impacts_gne__c.remove(pvName + ';') : impactedTrial.Impacts_gne__c.remove(pvName);
						}
					}
				}
			}
			if (trigger.isInsert) {
				CFAR_Utils.sortAndJoinImpacts(impactedTrial);
			}
		}

		CFAR_ConfigUtil.setDisabled('Disabled_Triggers_gne__c', new List<String> {'CFAR_Trial_gne__c'});
		update impactedTrials;
		CFAR_ConfigUtil.setDisabled('Disabled_Triggers_gne__c', new List<String> {});
	}
}