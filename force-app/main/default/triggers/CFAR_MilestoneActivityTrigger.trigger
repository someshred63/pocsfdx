trigger CFAR_MilestoneActivityTrigger on CFAR_Milestone_Activity_gne__c(before update, after update) {
	if (CFAR_ConfigUtil.isTriggerEnabled(new List<String> {'CFAR_MilestoneActivityTrigger', 'CFAR_Milestone_Activity_gne__c'})) {
		if (Trigger.isBefore) {
			for (CFAR_Milestone_Activity_gne__c ma : trigger.new) {
				if (Trigger.oldMap.get(ma.Id).Actual_Date_gne__c != ma.Actual_Date_gne__c) {
					ma.Actual_Date_Last_Change_gne__c = System.Today();
				}
			}
		}
		if (Trigger.isAfter) {
			Integer maTypeIndex = 0;
			Map<Id, String> trialIdToMAS = new Map<Id, String>();
			Map<Id, CFAR_Trial_gne__c> trialsToUpdate = new Map<Id, CFAR_Trial_gne__c>();
			Map<String, Integer> maTypePriority = new Map<String, Integer>();
			Map<Id, Id> trialIdToStatusIds = new Map<Id, Id>();
			Map<Id, CFAR_Trial_gne__c> trialIdToDate = new Map<Id, CFAR_Trial_gne__c>();
			for (Schema.PicklistEntry pe : CFAR_Milestone_Activity_gne__c.sfdc_Type_gne__c.getDescribe().getPicklistValues()) {
				if (CFAR_MilestonesUtils.maTypeToTrialStatus.containsKey(pe.getLabel())) {
					maTypePriority.put(pe.getLabel(), maTypeIndex);
				}
				maTypeIndex ++;
			}

			for (CFAR_Milestone_Activity_gne__c ma : trigger.new) {
				if (maTypePriority.containsKey(ma.Name) && ma.Actual_Date_gne__c != null && Trigger.oldMap.get(ma.Id).Actual_Date_gne__c != ma.Actual_Date_gne__c) {
					if (trialIdToMAS.containsKey(ma.CFAR_Trial_ref_gne__c)) {
						if (maTypePriority.get(ma.Name) > maTypePriority.get(trialIdToMAS.get(ma.CFAR_Trial_ref_gne__c))) {
							trialIdToMAS.put(ma.CFAR_Trial_ref_gne__c, ma.Name);
						}
					} else {
						trialIdToMAS.put(ma.CFAR_Trial_ref_gne__c, ma.Name);
					}
				}
			}

			if (!trialIdToMAS.isEmpty()) {
				for (CFAR_Trial_Status_gne__c status : [SELECT Id, Name FROM CFAR_Trial_Status_gne__c WHERE Name IN :CFAR_MilestonesUtils.maTypeToTrialStatus.values()]) {
					for (Id v : trialIdToMAS.keySet()) {
						if (CFAR_MilestonesUtils.maTypeToTrialStatus.get(trialIdToMAS.get(v)) == status.Name) {
							trialIdToStatusIds.put(v, status.Id);
						}
					}
				}

				for (CFAR_Trial_gne__c trial : [SELECT Trial_Status_ref_gne__c FROM CFAR_Trial_gne__c WHERE Id IN :trialIdToStatusIds.keySet()]) {
					if (trial.Trial_Status_ref_gne__c != trialIdToStatusIds.get(trial.Id)) {
						trial.Trial_Status_ref_gne__c = trialIdToStatusIds.get(trial.Id);
						trialsToUpdate.put(trial.Id, trial);
					}
				}
			}

			for (CFAR_Milestone_Activity_gne__c ma : trigger.new) {
				if ((ma.Name == 'LPI' || ma.Name == 'FPI' || ma.Name == 'LPO')  &&  (Trigger.oldMap.get(ma.Id).Actual_Date_gne__c != ma.Actual_Date_gne__c || Trigger.oldMap.get(ma.Id).Planned_Date_gne__c != ma.Planned_Date_gne__c)) {
					if (trialsToUpdate.containsKey(ma.CFAR_Trial_ref_gne__c)) {
						if (ma.Name == 'LPI') {
							trialsToUpdate.get(ma.CFAR_Trial_ref_gne__c).CFAR_Enrollment_End_Date_gne__c = ma.Actual_Date_gne__c != null ? ma.Actual_Date_gne__c : ma.Planned_Date_gne__c;
						} else if (ma.Name == 'FPI') {
							trialsToUpdate.get(ma.CFAR_Trial_ref_gne__c).CFAR_Enrollment_Start_Date_gne__c = ma.Actual_Date_gne__c != null ? ma.Actual_Date_gne__c : ma.Planned_Date_gne__c;
							trialsToUpdate.get(ma.CFAR_Trial_ref_gne__c).Drug_Supply_Generate_Forecasts_Date__c = ma.Actual_Date_gne__c;
						} else if (ma.Name == 'LPO' &&  (Trigger.oldMap.get(ma.Id).Actual_Date_gne__c != ma.Actual_Date_gne__c)) {
							trialsToUpdate.get(ma.CFAR_Trial_ref_gne__c).LPO_Actual_Date_gne__c = ma.Actual_Date_gne__c;
						}
					} else {
						CFAR_Trial_gne__c t = new CFAR_Trial_gne__c(Id = ma.CFAR_Trial_ref_gne__c);
						if (ma.Name == 'LPI') {
							t.CFAR_Enrollment_End_Date_gne__c = ma.Actual_Date_gne__c != null ? ma.Actual_Date_gne__c : ma.Planned_Date_gne__c;
						} else if (ma.Name == 'FPI') {
							t.CFAR_Enrollment_Start_Date_gne__c = ma.Actual_Date_gne__c != null ? ma.Actual_Date_gne__c : ma.Planned_Date_gne__c;
                            t.Drug_Supply_Generate_Forecasts_Date__c = ma.Actual_Date_gne__c;
						} else if (ma.Name == 'LPO' &&  (Trigger.oldMap.get(ma.Id).Actual_Date_gne__c != ma.Actual_Date_gne__c)) {
							t.LPO_Actual_Date_gne__c = ma.Actual_Date_gne__c;
						}
						trialsToUpdate.put(t.Id, t);
					}
				}
			}
			update trialsToUpdate.values();

			Boolean checkCaseForRebaseline = false;
            Boolean isFirstCall = true;
            Map<Id, CFAR_Milestone_Activity_gne__c> previousActivitiesMap = Trigger.oldMap;
            for (CFAR_Milestone_Activity_gne__c pAM : previousActivitiesMap.values()) {
                if (pAM.Planned_Date_gne__c == null) {
                    checkCaseForRebaseline = true;
                }
            }
        
            if (isFirstCall && checkCaseForRebaseline) {
                isFirstCall = false;
                CFAR_Milestone_Activity_gne__c masterDetailId = [SELECT CFAR_Trial_ref_gne__r.Id FROM CFAR_Milestone_Activity_gne__c WHERE Id = :Trigger.new LIMIT 1];
                List<CFAR_Milestone_Activity_gne__c> activitiesList = new List<CFAR_Milestone_Activity_gne__c>([SELECT Id, Planned_Date_gne__c FROM CFAR_Milestone_Activity_gne__c WHERE CFAR_Trial_ref_gne__r.Id = :masterDetailId.CFAR_Trial_ref_gne__r.Id]);
                List<CFAR_Milestone_Activity_gne__c> plannedToBaselineDates = new List<CFAR_Milestone_Activity_gne__c>();
                Map<Id, Date> activitiesMap = new Map<Id, Date>();
        
                for (CFAR_Milestone_Activity_gne__c activity : activitiesList) {
                    activitiesMap.put(Activity.Id, activity.Planned_Date_gne__c);
                }
        
                if (!activitiesMap.values().contains(null)) {
                    for (Id activity : activitiesMap.keySet()) {
                        CFAR_Milestone_Activity_gne__c milestone = new CFAR_Milestone_Activity_gne__c();
                        milestone.Id = activity;
                        milestone.Baselined_Date_gne__c = activitiesMap.get(Activity);
                        plannedToBaselineDates.add(milestone);
                    }
                    update plannedToBaselineDates;
                }
			}	
		}
	}
}