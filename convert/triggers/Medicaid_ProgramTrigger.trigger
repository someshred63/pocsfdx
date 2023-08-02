trigger Medicaid_ProgramTrigger on Medicaid_Program__c (before insert, before update) {

    if (trigger.new != null && trigger.new.size()>0){
        for (Medicaid_Program__c mp:trigger.new) {
            mp.Program__c = mp.Program_Name__c+' '+mp.Program_Year__c+' '+mp.Quarter__c;
            List<Medicaid_Program__c> emps=[SELECT id, name FROM Medicaid_Program__c WHERE 
            Labeler__c=: mp.Labeler__c and
            Program_Year__c =: mp.Program_Year__c and 
            Quarter__c =: mp.Quarter__c and
            Program_Name__c =: mp.Program_Name__c and
            State_Code__c =: mp.State_Code__c];
            
            if(emps!=null && emps.size()>0){
                if (trigger.isInsert){
                    mp.addError('This is the duplicate record of Program Ref#: '+emps[0].name);
                }else if(trigger.isUpdate){
                    if(mp.id != emps[0].id) 
                        mp.addError('This is the duplicate record of Program Ref#: '+emps[0].name);
                
                }
            }
        }
        
    }
}