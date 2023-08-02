trigger CFAR_TrialTrigger on CFAR_Trial_gne__c (after insert, after update, before insert, before update) {
    if (CFAR_ConfigUtil.isTriggerEnabled(new List<String>{'CFAR_TrialTrigger','CFAR_Trial_gne__c'})){
        if(!CFAR_Utils.hasAlreadyProcessed()) {    	
            if(Trigger.isInsert && Trigger.isAfter ){
                CFAR_Utils.createMilestoneActivities(trigger.newMap); 
                CFAR_Utils.createOrUpdateTeamMembers(trigger.newMap, null);
                CFAR_Utils.handleGeneralIndicationsNew(trigger.newMap);
                CFAR_Utils.handleSpecificIndicationsNew(trigger.newMap);
                CFAR_Utils.createRegulatoryTrackingActivities(trigger.newMap);

            }
            //it's not needed since, there're no updates of Pri Cont / Inv / MSL from other places than Team Info tab (e.g. General Info)
            /**
            if(Trigger.isUpdate && Trigger.isAfter ){
                CFAR_Utils.createOrUpdateTeamMembers(trigger.newMap, trigger.oldMap);

            }
            */
            
            /**
            if(Trigger.isInsert && Trigger.isBefore) {
    			CFAR_Utils.setIRBValueYes(trigger.new);   
    		}
        	*/
            if(Trigger.isInsert && Trigger.isBefore) {
                for(CFAR_Trial_gne__c trial : Trigger.New){
                    if(trial.Planned_Enrollment_gne__c != null){
                        trial.Total_Study_Enrollment__c = trial.Planned_Enrollment_gne__c;
                    }
                }
    		}
        	
        	
        	if(Trigger.isUpdate && Trigger.isAfter){
        		CFAR_MilestonesUtils.handleNumOfMonthsChanged(trigger.oldMap,trigger.newMap);
        		//to prevent creating duplicate: GI, SI, OGA in case workflows make second update and second trigger execution
        		if (!CFAR_Utils.hasAlreadyProcessedTrialForJunctions()) {
        			CFAR_Utils.handleOtherGNEAgentsChanged(trigger.oldMap,trigger.newMap);  		
        			CFAR_Utils.handleIMPShippedChanged(trigger.oldMap,trigger.newMap);	
        			CFAR_Utils.handleGeneralIndicationsChanged(trigger.oldMap,trigger.newMap);
        			CFAR_Utils.handleSpecificIndicationsChanged(trigger.oldMap,trigger.newMap);
        			CFAR_Utils.setAlreadyProcessedTrialForJunctions();
                    CFAR_Utils.createRegulatoryTrackingActivities(trigger.newMap);
        		}  
        	}

        }
        if(Trigger.isUpdate && Trigger.isBefore) {
    			CFAR_MilestonesUtils.handleTrialsChange(trigger.oldMap,trigger.newMap);      
    			CFAR_MilestonesUtils.handleGenerateDrugSupplyForecasts(trigger.oldMap,trigger.newMap);
                for(CFAR_Trial_gne__c updatedTrial : Trigger.New){
                    if(updatedTrial.Planned_Enrollment_gne__c != null){              
                        if(Trigger.oldMap.get(updatedTrial.Id).Total_Study_Enrollment__c != null && updatedTrial.Total_Study_Enrollment__c == null){
                            updatedTrial.Total_Study_Enrollment__c = null;
                        } else if(updatedTrial.Total_Study_Enrollment__c == null){
                            updatedTrial.Total_Study_Enrollment__c = updatedTrial.Planned_Enrollment_gne__c;
                        }
                    }
                }
    	}
    }
}