trigger SPLOA_MCC_Req_Trigger on C_ops_MCC_Request__c (before insert, before update) {
SPLOA_MCC_Req_Controller controller = new SPLOA_MCC_Req_Controller();
    controller.checkfordupe(trigger.old, trigger.new);
}