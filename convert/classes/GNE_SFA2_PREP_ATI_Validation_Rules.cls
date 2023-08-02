public class GNE_SFA2_PREP_ATI_Validation_Rules {
	public static final Map<String,List<Integer>> numericFieldRanges = new Map<String,List<Integer>> {
		String.valueOf(SFA2_PREP_Account_Testing_Info_gne__c.Percent_of_Global_gne__c) => new List<Integer>{0,100},
		String.valueOf(SFA2_PREP_Account_Testing_Info_gne__c.Percent_of_TC_gne__c) => new List<Integer>{0,100},
		String.valueOf(SFA2_PREP_Account_Testing_Info_gne__c.Testing_Volume_Month_gne__c) => new List<Integer>{0,999999}	
	};
	
	public static void onBeforeInsert(List<SFA2_PREP_Account_Testing_Info_gne__c> triggerNew) {
		validateNumericFields(null, triggerNew);
    }
    
    public static void onBeforeUpdate(List<SFA2_PREP_Account_Testing_Info_gne__c> triggerOld, List<SFA2_PREP_Account_Testing_Info_gne__c> triggerNew) {
		validateNumericFields(triggerOld, triggerNew);
    }
    
    private static void validateNumericFields(List<SFA2_PREP_Account_Testing_Info_gne__c> triggerOld, List<SFA2_PREP_Account_Testing_Info_gne__c> triggerNew) {
    	Integer idx = 0;
    	
    	for(SFA2_PREP_Account_Testing_Info_gne__c tInfoNew : triggerNew) {
    		SFA2_PREP_Account_Testing_Info_gne__c tInfoOld = triggerOld!=null ? triggerOld[idx++] : null;
    		
    		for(String fieldName : numericFieldRanges.keySet()) {
    			Object newValue = tInfoNew.get(fieldName);
    			if(newValue!=null && (tInfoOld==null || tInfoOld.get(fieldName)!= newValue)) {
    				Integer intValue = ((Double)newValue).intValue();
    				List<Integer> range = numericFieldRanges.get(fieldName);
    				
    				if(intValue<range[0] || intValue>range[1]) {
    					String errorMsg = String.format(System.Label.GNE_SFA2_PREP_NUMBER_OUT_OF_RANGE, new String[]{String.valueOf(range[0]), String.valueOf(range[1])});
    					
    					if(fieldName == String.valueOf(SFA2_PREP_Account_Testing_Info_gne__c.Percent_of_Global_gne__c)) {
    						tInfoNew.Percent_of_Global_gne__c.addError(errorMsg);	
    					} else if(fieldName == String.valueOf(SFA2_PREP_Account_Testing_Info_gne__c.Percent_of_TC_gne__c)) {
    						tInfoNew.Percent_of_TC_gne__c.addError(errorMsg);
    					} else if(fieldName == String.valueOf(SFA2_PREP_Account_Testing_Info_gne__c.Testing_Volume_Month_gne__c)) {
    						tInfoNew.Testing_Volume_Month_gne__c.addError(errorMsg);
    					}
    				}
    			}
    		}
    	}
    }
}