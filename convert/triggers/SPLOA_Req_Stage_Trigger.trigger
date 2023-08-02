trigger SPLOA_Req_Stage_Trigger on C_Ops_IAP_Requests_Stage__c (after insert) {
SPLOA_Req_Stage_Controller cntl = new SPLOA_Req_Stage_Controller();
    cntl.updatemainreq(trigger.old,trigger.new);
}