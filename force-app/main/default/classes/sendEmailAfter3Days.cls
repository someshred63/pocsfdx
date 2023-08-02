global class sendEmailAfter3Days implements Schedulable {
    global void execute(SchedulableContext sc) {
        List<SPCM_Medicaid_Payment_Packet__c> med = [SELECT Id, Name, Submitted_Date__c,Initiated_By__c,Appr_Approver_1__c,Initiated_By__r.Email,Appr_Approver_1__r.Email
                                                     FROM SPCM_Medicaid_Payment_Packet__c 
                                                     WHERE Approval_Status__c = 'Submitted for Approval' AND No_Of_Days_From_Submitted_Date__c > 3 ];
        list<string> userids= new list<string>();
        for(SPCM_Medicaid_Payment_Packet__c sp : med) {
            if( String.isnotEmpty(sp.Appr_Approver_1__c)){
                userids.add(sp.Appr_Approver_1__c);
            }
        }
        set<string> userexist= new set<string>();
        if(userids.Size()>0){
            for(SPCM_Level_1_Approver__c spcm: [select id,User__c from SPCM_Level_1_Approver__c where User__c in:userids AND Is_Active__c = true]){
                userexist.add(spcm.User__c);
            }
            userids= new list<string>();
        }
        list<Messaging.SingleEmailMessage> mailstosend = new list<Messaging.SingleEmailMessage>();
        
        for(SPCM_Medicaid_Payment_Packet__c sp : med) {
            Date dt = sp.Submitted_Date__c;
            String subDat = dt.month() + '/' + dt.day()  + '/' + dt.year();

            if(String.isnotEmpty(sp.Initiated_By__c) ){        
                mailstosend.add(buildEmail(sp.Initiated_By__r.Email, sp.Name,subDat));
            }
            if(userexist.size()>0 && userexist.contains(sp.Appr_Approver_1__c)){
                mailstosend.add(buildEmail(sp.Appr_Approver_1__r.Email, sp.Name,subDat));
            } 
        }       
        try{
            if(mailstosend.size()>0)
                Messaging.sendEmail(mailstosend);
        }catch(exception ex){
            System.debug('Exception Occured while sending emails'+ex);
            
        }
    }
    
    Global Messaging.SingleEmailMessage buildEmail (string emailtosend, string name, String  subDate ){
        Messaging.SingleEmailMessage mail= new Messaging.SingleEmailMessage();
        OrgWideEmailAddress owa=[select id, Address, DisplayName from OrgWideEmailAddress WHERE DisplayName='SPCM Medicaid Payment Program'];
        if(owa!=null) mail.setOrgWideEmailAddressId(owa.id);
        mail.setToAddresses(new List<String>{emailtosend});
        mail.setSubject('eWorkflow reminder to take action on ' + name +'.');
        mail.setPlainTextBody('Reminder that ' + name + ' needs to be reviewed or recalled.This was last submitted to the eWorkflow system on ' + subDate+'.');
        return mail;
        
    }
}