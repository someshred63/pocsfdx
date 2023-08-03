trigger SPLOA_Add_Pharm on C_Ops_SPLOA_Additional_Pharmacy__c (before insert) {
SPLOA_Add_Pharm_Controller cntl = new SPLOA_Add_Pharm_Controller();
    cntl.updatemainreq(trigger.new);
}