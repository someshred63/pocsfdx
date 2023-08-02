public class GNE_SFA2_PREP_ATS_Child_Record_Updates {
	public static void onAfterUpdate(List<SFA2_PREP_Account_Testing_Strategy_gne__c> triggerOld, List<SFA2_PREP_Account_Testing_Strategy_gne__c> triggerNew) {
        setMBOStatus(triggerOld, triggerNew);
    }
    
    private static void setMBOStatus(List<SFA2_PREP_Account_Testing_Strategy_gne__c> triggerOld, List<SFA2_PREP_Account_Testing_Strategy_gne__c> triggerNew) {
    	Set<Id> accStrategyIds = new Set<Id>();
    	Map<Id,SFA2_PREP_Account_Testing_Strategy_gne__c> accStrategiesMap = new Map<Id,SFA2_PREP_Account_Testing_Strategy_gne__c>();
    	
    	for(Integer i=0; i<(triggerNew!=null ? triggerNew.size() : triggerOld.size()); i++) {
    		SFA2_PREP_Account_Testing_Strategy_gne__c oldRec = triggerOld[i];
    		SFA2_PREP_Account_Testing_Strategy_gne__c newRec = triggerNew[i];
    		 
    		if(newRec.Status_gne__c!=oldRec.Status_gne__c) {
    			accStrategyIds.add(newRec.Id);
    			accStrategiesMap.put(newRec.Id, newRec);
    		}
    	}
    	
    	if(!accStrategyIds.isEmpty()) {
    		setMBOStatus(accStrategyIds, accStrategiesMap);
    	}
    }
    
    private static void setMBOStatus(Set<Id> accStrategyIds, Map<Id,SFA2_PREP_Account_Testing_Strategy_gne__c> accStrategiesMap) {
    	Map<Id,List<Database.SaveResult>> sResults = GNE_SFA2_PREP_Util.setMBOStatus(accStrategyIds);
    		
    	for(Id aStrategyId : sResults.keySet()) {
    		SFA2_PREP_Account_Testing_Strategy_gne__c rec = accStrategiesMap.get(aStrategyId);
    		
    		for(Database.SaveResult sResult : sResults.get(aStrategyId)) {
    			if(!sResult.isSuccess()) {
    				for(Database.Error err : sResult.getErrors()) {
    					rec.addError(err.getMessage());
    				}
    			}
    		}
    	}
    }
}