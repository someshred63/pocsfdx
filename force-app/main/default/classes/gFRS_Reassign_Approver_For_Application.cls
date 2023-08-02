global class gFRS_Reassign_Approver_For_Application implements Messaging.InboundEmailHandler {
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        Id reqId ;
        Id approverId ;
        
        String emailContent                 = email.plainTextBody.trim();
		system.debug('@@@ Req Id : '+emailContent.substring(10, 28));
        system.debug('@@@ Approver Id : '+emailContent.right(18));
        
        reqId 		= emailContent.substring(10, 28);
        approverId	= emailContent.right(18);
        
        try{
            ProcessInstanceWorkitem PIWI = [SELECT Id, ActorId, OriginalActorId, ProcessInstanceId FROM ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: reqId];
            PIWI.ActorId = approverId;
            
            update PIWI;
            
            result.success = true;
            
        }  catch(Exception e){
            system.debug('@@@ Error Message : '+e.getmessage());
            result.success = false; 
        } 
        
        return result; 
    }
    
}