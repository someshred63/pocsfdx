public class GNE_SFA2_PREP_AMBO_Parent_Record_Updates {
	public static void onAfterInsert(List<SFA2_PREP_Account_MBO_gne__c> triggerNew) {
        setAccountStrategyStatus(null, triggerNew);
    }
    
    public static void onAfterUpdate(List<SFA2_PREP_Account_MBO_gne__c> triggerOld, List<SFA2_PREP_Account_MBO_gne__c> triggerNew) {
        setAccountStrategyStatus(triggerOld, triggerNew);
    }
    
    public static void onAfterDelete(List<SFA2_PREP_Account_MBO_gne__c> triggerOld) {
        setAccountStrategyStatus(triggerOld, null);
    }
    
    public static void onAfterUndelete(List<SFA2_PREP_Account_MBO_gne__c> triggerOld) {
        setAccountStrategyStatus(triggerOld, null);
    }
    
    private static void setAccountStrategyStatus(List<SFA2_PREP_Account_MBO_gne__c> triggerOld, List<SFA2_PREP_Account_MBO_gne__c> triggerNew) {
    	Set<Id> accStrategyIdsToUpdate = new Set<Id>();
    	Map<Id,Set<SFA2_PREP_Account_MBO_gne__c>> accStrategyToMBOs = new Map<Id,Set<SFA2_PREP_Account_MBO_gne__c>>();
    	
    	for(Integer i=0; i<(triggerNew!=null ? triggerNew.size() : triggerOld.size()); i++) {
    		SFA2_PREP_Account_MBO_gne__c oldRec = triggerOld!=null ? triggerOld[i] : null;
    		SFA2_PREP_Account_MBO_gne__c newRec = triggerNew!=null ? triggerNew[i] : null;
    		SFA2_PREP_Account_MBO_gne__c rec = newRec!=null ? newRec : oldRec;
    		 
    		if(oldRec==null || newRec==null || newRec.Status_gne__c!=oldRec.Status_gne__c) {
    			accStrategyIdsToUpdate.add(rec.Account_Testing_Strategy_gne__c);
    			
    			if(!accStrategyToMBOs.containsKey(rec.Account_Testing_Strategy_gne__c)) {
    				accStrategyToMBOs.put(rec.Account_Testing_Strategy_gne__c, new Set<SFA2_PREP_Account_MBO_gne__c>());
    			}
    			
    			accStrategyToMBOs.get(rec.Account_Testing_Strategy_gne__c).add(rec);
    		}
    	}
    	
    	if(!accStrategyIdsToUpdate.isEmpty()) {
    		setAccountStrategyStatus(accStrategyIdsToUpdate, accStrategyToMBOs);
    	}
    }
    
    private static void setAccountStrategyStatus(Set<Id> accStrategyIdsToUpdate, Map<Id,Set<SFA2_PREP_Account_MBO_gne__c>> accStrategyToMBOs) {
    	Database.SaveResult[] sResults = GNE_SFA2_PREP_Util.setAccountStrategyStatus(accStrategyIdsToUpdate);
    		
    	if(sResults!=null) {
    		for(Database.SaveResult sResult : sResults) {
    			if(!sResult.isSuccess()) {
    				for(Database.Error err : sResult.getErrors()) {
    					for(SFA2_PREP_Account_MBO_gne__c rec : accStrategyToMBOs.get(sResult.getId())) {
    						rec.addError(err.getMessage());
    					}
    				}
    			}
    		}
    	}
    }
}