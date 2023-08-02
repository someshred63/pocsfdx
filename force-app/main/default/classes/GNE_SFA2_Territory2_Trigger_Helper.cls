public with sharing class GNE_SFA2_Territory2_Trigger_Helper {
	
	public static Boolean inTrigger = false;
	public static Boolean isSubscribeMode = false;
	public static Boolean runOnlyAfterEvents = false;
	public static Boolean runBatchable = false;
	public static Boolean isSubscribePrevMode = false;
	
	public static void setInTrigger (Boolean i_inTrigger) {
        inTrigger = i_inTrigger;
    }
	
	public static void setSubscribeMode (Boolean isSubscribe) {
        isSubscribeMode = isSubscribe;
    }
    
    public static void setRunOnlyAfterEvents (Boolean onlyAfterEvents) {
        runOnlyAfterEvents = onlyAfterEvents;
    }

	public static void setRunBatchable (Boolean batchable) {
		runBatchable = batchable;
	}

	public static void setSubPrevMode (Boolean subPrevMode) {
		isSubscribePrevMode = subPrevMode;
	}
    
    public static Map<Integer, List<Territory2>> reorderTerritoriesByHierarchy(List<Territory2> territories) {
		Map<Integer, List<Territory2>> result = new Map<Integer, List<Territory2>>();
		for(Territory2 terr : territories) {
			Integer extIdSplitCount = 0;
			if(String.isNotBlank(terr.External_Id_gne__c)) {
				extIdSplitCount = terr.External_Id_gne__c.split(';').size();
			}
			
			if(!result.containsKey(extIdSplitCount)) {
				result.put(extIdSplitCount, new List<Territory2>{terr});
			} else {
				result.get(extIdSplitCount).add(terr);
			}
		}
		
		return result;
	}
    
}