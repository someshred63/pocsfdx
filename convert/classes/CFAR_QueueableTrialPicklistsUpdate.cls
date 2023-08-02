public class CFAR_QueueableTrialPicklistsUpdate implements Queueable {

	private List<CFAR_Trial_gne__c> trialsToUpdate;
	public Set<Id> pvIdsWithChangedName;
	Map<Id, List<Id>> trialIdToPv = new Map<Id, List<Id>>();
	public Map<Id, String> recordIdToName = new Map<Id, String>();
	Map<Id, CFAR_Picklist_Value_gne__c> oldPicklistValueMap;
	Map<Id, CFAR_Picklist_Value_gne__c> newPicklistValueMap;

	public CFAR_QueueableTrialPicklistsUpdate(Set<Id> pvIdsSet, Map<Id, CFAR_Picklist_Value_gne__c> oldPvMap, Map<Id, CFAR_Picklist_Value_gne__c> newPvMap) {
		pvIdsWithChangedName = pvIdsSet;
		oldPicklistValueMap = oldPvMap;
		newPicklistValueMap = newPvMap;
	}

	public void execute(QueueableContext context) {

		for (CFAR_Trial_Picklist_gne__c tp : [SELECT CFAR_Trial_ref_gne__c, CFAR_PicklistValue_ref_gne__c FROM CFAR_Trial_Picklist_gne__c WHERE CFAR_PicklistValue_ref_gne__c = :pvIdsWithChangedName]) {
			if (trialIdToPv.containsKey(tp.CFAR_Trial_ref_gne__c)) {
				trialIdToPv.get(tp.CFAR_Trial_ref_gne__c).add(tp.CFAR_PicklistValue_ref_gne__c);
			} else {
				trialIdToPv.put(tp.CFAR_Trial_ref_gne__c, new List<Id> {tp.CFAR_PicklistValue_ref_gne__c});
			}
		}

		CFAR_Trial_gne__c[] trialsToUpdate = [SELECT Impacts_gne__c FROM CFAR_Trial_gne__c WHERE Id IN :trialIdToPv.keySet()];

		for(CFAR_Picklist_Value_gne__c pv : [SELECT RecordType.Name, RecordTypeId FROM CFAR_Picklist_Value_gne__c WHERE Id IN : pvIdsWithChangedName]){
			recordIdToName.put(pv.RecordTypeId, pv.RecordType.Name);
		}

		for (CFAR_Trial_gne__c trial : trialsToUpdate) {

			for (String pvId : trialIdToPv.get(trial.Id)) {
				if (recordIdToName.get(newPicklistValueMap.get(pvId).RecordTypeId) == 'Impact') {
					trial.Impacts_gne__c = trial.Impacts_gne__c.replace(oldPicklistValueMap.get(pvId).Name, newPicklistValueMap.get(pvId).Name);
				}
			}

			CFAR_Utils.sortAndJoinImpacts(trial);
		}

		CFAR_ConfigUtil.setDisabled('Disabled_Triggers_gne__c', new List<String> {'CFAR_Trial_gne__c'});
		update trialsToUpdate;
		CFAR_ConfigUtil.setDisabled('Disabled_Triggers_gne__c', new List<String> {});
	}
}