/** 
* @Author chavvas
* @date 4/26/2021
* @description Trigger on gFRS_Ltng_CAF_User object.
*/
trigger gFRS_Ltng_CAF_User on gFRS_Ltng_CAF_User__c (before insert, before update) {
    
    if(Trigger.isBefore && (Trigger.isInsert))
    {  
        for(gFRS_Ltng_CAF_User__c copayUser : Trigger.New) {
            if(copayUser.Invite_Code_Status__c == 'Approved'){
                copayUser.Invite_Code__c = gFRS_Ltng_Copay_Util.generateInviteCode(copayUser);
            }
	    }  
    }
    
    if(Trigger.isBefore && (Trigger.isUpdate))
    {  
        for(gFRS_Ltng_CAF_User__c copayUser : Trigger.New) {
            if(copayUser.Invite_Code_Status__c == 'Approved' && copayUser.Invite_Code__c == Null){
                gFRS_Ltng_CAF_User__c copayUserOld = Trigger.oldMap.get(copayUser.Id);
                if(copayUserOld.Invite_Code_Status__c != 'Approved' && copayUser.Invite_Code_Status__c == 'Approved'){
                	copayUser.Invite_Code__c = gFRS_Ltng_Copay_Util.generateInviteCode(copayUser);        
                }
    	    }
    	}  
    }

}