trigger Medicaid_LabelerTrigger on Medicaid_Labeler__c (before insert, before update) {

    if (trigger.new != null && trigger.new.size()>0){
        
        for (Medicaid_Labeler__c ml:trigger.new) {
            List<Medicaid_Labeler__c> mls=[SELECT id, name, Medicaid_State__c FROM Medicaid_Labeler__c WHERE 
            name =: ml.name and
            Medicaid_State__c =: ml.Medicaid_State__c];
            
            if(mls!=null && mls.size()>0){
                if (trigger.isInsert){
                    ml.addError('This is the duplicate record of Labeler Code Ref#: '+mls[0].name);
                }else if(trigger.isUpdate){
                    if(ml.id != mls[0].id) 
                        ml.addError('This is the duplicate record of Labeler Code Ref#: '+mls[0].name);
                
                }
            }
        }
        
    }
}