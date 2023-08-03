trigger SPLOA_Questionnairetrigger on C_Ops_SPLOA_Questionnaire_Questions__c (before insert) {
    SPLOA_Ques_Controller cntl = new SPLOA_Ques_Controller();
		cntl.updatemainreq(trigger.new);
}