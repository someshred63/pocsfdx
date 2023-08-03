trigger DisableDeleteNote on Note (before delete) {
    
    List<Note> notes;
    Id pId;
    
    if(Trigger.isDelete){
        notes=Trigger.old;
    }
    
    if(notes!=null && notes.size()>0){
        for(Note a: notes){
            List<GNE_CRM_CC_Case__c> cases=[select id, Case_Status__c from GNE_CRM_CC_Case__c where id=:a.ParentId];
            if(cases!=null && cases.size()>0){
            for(GNE_CRM_CC_Case__c c: cases){
                if(c.Case_Status__c=='Closed'){
                    a.addError('This case is Closed. You cannot delete any notes associated to a Closed case.');
                }
            }
        }
        }
        
        
    }
    
}