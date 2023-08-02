public class emailSyncToPRPEmailTracker {
    public static void emailTracker(List<EmailMessage> emsg){
        Boolean RunOnce = false;
        
        PRP_Email_Tracker__c prp = new PRP_Email_Tracker__c();
         for (EmailMessage msg:emsg){
            if(msg.RelatedToId != Null && String.valueOf(msg.RelatedToId).startsWith('aKv')){
                RunOnce= true;
                prp.Body__c = msg.HtmlBody;
                prp.CC_Address__c=msg.CcAddress;
                prp.Provider_Rebate_Program_Request__c =msg.RelatedToId;
                prp.Sent_On__c =msg.MessageDate;
                prp.Sent__c=msg.FromAddress;
                prp.Subject__c =msg.Subject;
                prp.To_Address__c =msg.ToAddress;
                prp.EmailMessageId__c = msg.Id;
                
            }
        }
        try {
            if(RunOnce == true){
                insert prp;
                PRP_Email_Tracker__c prp1 = [select id,EmailMessageId__c from PRP_Email_Tracker__c where Id =:prp.Id]; 
                
                if(prp1.EmailMessageId__c != null){
                    createDocLink bcn = new createDocLink(prp1.EmailMessageId__c,prp.Id);
                    Datetime sysTime = System.now().addSeconds(10);
                    String exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
                    
					system.schedule(exp, exp, bcn);
                }
            }
        }
        catch(DMLException e) {
            System.debug(e);
        } 
    }
    public static void createContentLink(String oldrecid, String recordId) {
        list<ContentDocumentLink> Doclinks =[select id,ContentDocumentId,LinkedEntityId  from ContentDocumentLink where LinkedEntityId =:oldrecid];
        list<ContentDocumentLink> newDoclinks   = new list<ContentDocumentLink>();
        for(ContentDocumentLink docid:DocLinks){
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = docid.ContentDocumentId;
            cdl.LinkedEntityId = recordId;
            cdl.ShareType = 'V';
            newDoclinks.add(cdl);
        }
        try {
            insert newDoclinks;            
        } catch(DMLException e) {
            System.debug(e);
            
        }
    }
}