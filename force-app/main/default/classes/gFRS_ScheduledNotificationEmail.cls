global class gFRS_ScheduledNotificationEmail implements Schedulable{
    global void execute(SchedulableContext SC) {
        sendEmail();
    }
    /**
    * Function sends email to external users who created a funding request, for all funding requests which status has been updated within past 30 days.
    */
    public void sendEmail(){
        Messaging.SingleEmailMessage[] mailBag = new Messaging.SingleEmailMessage[]{}; 
        String subject = 'gFRS email notification';
        
        for(GFRS_Funding_Request__c r : [select ID, Name, CreatedBy.FirstName, CreatedBy.LastName,  CreatedBy.email, CreatedBy.ContactId from GFRS_Funding_Request__c where Status_Last_Modified_Date__c > :(date.today() - 30 )] ){
            if(r.CreatedBy.ContactId == null){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[] {r.CreatedBy.email});
                mail.setSubject( subject );
                String body = 'Dear '+r.CreatedBy.FirstName+' '+r.CreatedBy.LastName+',\n\nfunding request '+r.Name+' chenged status within the past 30 days.\n\n Genentech Team';
                
                mail.setPlainTextBody(body);
                mailBag.add(mail);
            }
        }
        
        Messaging.sendEmail(mailBag);
    }
}