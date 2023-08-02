global class gFRS_Recall_Approval_Request implements Messaging.InboundEmailHandler {
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        Id workItemId ;
        
        String emailContent                 = email.plainTextBody.trim();
        system.debug('@@@ Work Item Id : '+emailContent.substring(10, 28));
        
        workItemId     = emailContent.substring(10, 28);
        
        try{
            Approval.ProcessWorkitemRequest submittedReq = new Approval.ProcessWorkitemRequest();  
            
            submittedReq.setAction('Removed');
            submittedReq.setWorkItemId(workItemId);
            Approval.ProcessResult approvalResult =  Approval.process(submittedReq);
            
            result.success = true;
            
        }  catch(Exception e){
            system.debug('@@@ Error Message : '+e.getmessage());
            result.success = false; 
        } 
        
        return result; 
    }
    
}