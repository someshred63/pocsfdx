trigger Medicaid_StateTrigger on Medicaid_State__c (before insert, before update) {
    /*Medicaid_TriggerController ctrl = new Medicaid_TriggerController();
    List<String> existingStateNames = new List<String>();

    if (trigger.isBefore) {
        //Invoke Before Insert trigger action
        if (trigger.isInsert) {
            existingStateNames = ctrl.getExistingMedicaidStateNames(trigger.new); 
            ctrl.validateExistingMedicaidStates(trigger.new, null, existingStateNames, false);
            //Change the Name to proper case
            for (Medicaid_State__c ms:trigger.new) {
                ms.Name = ctrl.capitalizeStateName(ms.Name, Medicaid_Constants.DELIMITED_BY_SPACE);
                System.debug('Name Capitalization: ' + ms.Name);
            }
        }

        //Invoke Before Update trigger action
        if (trigger.isUpdate){
            existingStateNames = ctrl.getExistingMedicaidStateNames(trigger.new);
            ctrl.validateExistingMedicaidStates(trigger.new, trigger.oldMap, existingStateNames, true);
            Map<Id, Medicaid_State__c> oldMedState = trigger.oldMap;
            List<Medicaid_State__c> newMedState = trigger.new;
            for (Medicaid_State__c ms :newMedState) {
                String newStateName = ms.Name;
                String oldStateName = oldMedState.get(ms.Id).Name;
                //if (!newStateName.equals(oldStateName)) {
                    ms.Name = ctrl.capitalizeStateName(ms.Name, Medicaid_Constants.DELIMITED_BY_SPACE);
                //}
            }
        }
    }*/
    
    if (trigger.new != null && trigger.new.size()>0){
        for (Medicaid_State__c mc:trigger.new) {
            mc.name=mc.name.capitalize();
            List<Medicaid_State__c> mcs=[SELECT id, name FROM Medicaid_State__c WHERE 
            name=: mc.name];
            
            if(mcs!=null && mcs.size()>0){
                if (trigger.isInsert){
                    mc.addError('This is the duplicate record of State Ref#: '+mcs[0].name);
                }else if(trigger.isUpdate){
                    if(mc.id != mcs[0].id) 
                        mc.addError('This is the duplicate record of State Ref#: '+mcs[0].name);
                
                }
            }
        }
     }
    
}