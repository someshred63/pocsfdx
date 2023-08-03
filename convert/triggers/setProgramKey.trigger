trigger setProgramKey on SPCM_Program__c (Before insert, Before update) {
    for(SPCM_Program__c p : Trigger.New) {
        if (Trigger.isInsert) {
            if (String.isBlank(p.program_key__c)) p.program_key__c=p.name;
        } else if (Trigger.isUpdate) {
            p.program_key__c=p.name;
        }
    }

}