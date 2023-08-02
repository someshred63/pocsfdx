/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-10-11
*  Description: This is a helper class for Call related objects
*    
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_Call_Helper {
	private static boolean performSubmitCheckOnChild = true;
            
    public static boolean getPerformSubmitCheck () {
        return performSubmitCheckOnChild;
    }
    public static void setSubmitCheck (boolean value) {
        performSubmitCheckOnChild = value;
    }
    
    public static boolean isLocked(String callStatus) {
    	return callStatus == 'Submitted_vod';
    }
    
    // Deprecated
    public static boolean isLocked (String Id, Map <Id,Call2_vod__c> calls) {
    	Boolean result = false;
        Call2_vod__c call = calls.get(Id);        
        if (call != null) {
            if (call.Parent_Call_vod__r != null ) {
                if (isLocked(call.Parent_Call_vod__r.Status_vod__c))
                    result = true;
            }
            if (isLocked(call.Status_vod__c))
                result = true;
        }
        return result;
    }
    
    // Deprecated
    public static Map<Id,Call2_vod__c> getCallMap (List<String> callIds) {
        Map<Id, Call2_vod__c> calls = new Map<Id, Call2_vod__c> ([ SELECT Id, Name, Parent_Call_vod__r.Status_vod__c, Status_vod__c, Override_Lock_vod__c, OwnerId, Call_Date_vod__c FROM Call2_vod__c WHERE Id IN :callIds ]);
        return calls;      
    }
}