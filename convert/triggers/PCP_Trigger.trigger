trigger PCP_Trigger on Political_Contribution_Requests__c (before insert , before update) {
    PCP_Controller cntl = new PCP_Controller();
    if(trigger.isInsert){
    cntl.populatesubdetails(trigger.old,trigger.new);    
    }
    if(trigger.isUpdate){
    cntl.populateadmindetails(trigger.oldMap,trigger.new);
    }
}