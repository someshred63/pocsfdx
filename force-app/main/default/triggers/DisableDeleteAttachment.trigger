trigger DisableDeleteAttachment on Attachment (before delete) {
    List<Attachment> attachments;
    Id pId;
    
    if(Trigger.isDelete){
        attachments=Trigger.old;
    }
    
    if(attachments!=null && attachments.size()>0){
        for(Attachment a: attachments){
            List<GNE_CRM_CC_Case__c> cases=[select id, Case_Status__c from GNE_CRM_CC_Case__c where id=:a.ParentId];
            if(cases!=null && cases.size()>0){
            for(GNE_CRM_CC_Case__c c: cases){
                if(c.Case_Status__c=='Closed'){
                    a.addError('This case is Closed. You cannot delete any attachments associated to a Closed case.');
                }
            }
        }
        }
        
        
    }
}