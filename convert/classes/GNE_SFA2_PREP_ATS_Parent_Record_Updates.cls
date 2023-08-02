public class GNE_SFA2_PREP_ATS_Parent_Record_Updates {
	public static void onAfterInsert(List<SFA2_PREP_Account_Testing_Strategy_gne__c> triggerNew) {
        setAccountStatus(null, triggerNew);
    }
    
    public static void onAfterUpdate(List<SFA2_PREP_Account_Testing_Strategy_gne__c> triggerOld, List<SFA2_PREP_Account_Testing_Strategy_gne__c> triggerNew) {
        setAccountStatus(triggerOld, triggerNew);
    }
    
    public static void onAfterDelete(List<SFA2_PREP_Account_Testing_Strategy_gne__c> triggerOld) {
        setAccountStatus(triggerOld, null);
    }
    
    public static void onAfterUndelete(List<SFA2_PREP_Account_Testing_Strategy_gne__c> triggerOld) {
        setAccountStatus(triggerOld, null);
    }
    
    private static void setAccountStatus(List<SFA2_PREP_Account_Testing_Strategy_gne__c> triggerOld, List<SFA2_PREP_Account_Testing_Strategy_gne__c> triggerNew) {
    	Set<Id> accIdsToUpdate = new Set<Id>();
    	Map<Id,Set<SFA2_PREP_Account_Testing_Strategy_gne__c>> accToStrategies = new Map<Id,Set<SFA2_PREP_Account_Testing_Strategy_gne__c>>();
    	
    	for(Integer i=0; i<(triggerNew!=null ? triggerNew.size() : triggerOld.size()); i++) {
    		SFA2_PREP_Account_Testing_Strategy_gne__c oldRec = triggerOld!=null ? triggerOld[i] : null;
    		SFA2_PREP_Account_Testing_Strategy_gne__c newRec = triggerNew!=null ? triggerNew[i] : null;
    		SFA2_PREP_Account_Testing_Strategy_gne__c rec = newRec!=null ? newRec : oldRec;
    		 
    		if(oldRec==null || newRec==null || newRec.Status_gne__c!=oldRec.Status_gne__c) {
    			accIdsToUpdate.add(rec.Account_gne__c);
    			
    			if(!accToStrategies.containsKey(rec.Account_gne__c)) {
    				accToStrategies.put(rec.Account_gne__c, new Set<SFA2_PREP_Account_Testing_Strategy_gne__c>());
    			}
    			
    			accToStrategies.get(rec.Account_gne__c).add(rec);
    		}
    	}
    	
    	if(!accIdsToUpdate.isEmpty()) {
    		setAccountStatus(accIdsToUpdate, accToStrategies);
    	}
    }
    
    private static void setAccountStatus(Set<Id> accIdsToUpdate, Map<Id,Set<SFA2_PREP_Account_Testing_Strategy_gne__c>> accToStrategies) {
    	Database.SaveResult[] sResults = GNE_SFA2_PREP_Util.setAccountStatus(accIdsToUpdate);
    		
    	if(sResults!=null) {
    		for(Database.SaveResult sResult : sResults) {
    			if(!sResult.isSuccess()) {
    				for(Database.Error err : sResult.getErrors()) {
    					for(SFA2_PREP_Account_Testing_Strategy_gne__c rec : accToStrategies.get(sResult.getId())) {
    						rec.addError(err.getMessage());
    					}
    				}
    			}
    		}
    	}
    }
}