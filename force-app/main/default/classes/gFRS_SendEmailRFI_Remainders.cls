/**
 * @description This class will be called by flow 
 * @author      Kiran Kumar P
 * @createdDate 2021-10-13
 */

public class gFRS_SendEmailRFI_Remainders {
    @InvocableMethod(label='Send RFI Email Notification') 
    
    /**     
     * @param reqIds input gFRS Application Id list
     * 
     */
    public static void SendRFINotification(List<String> reqIds){ 
        system.debug('@@@ reqIds'+reqIds);
         system.debug('@@@ reqIdsSize'+reqIds.size());
        String[] VarIds;        
        for (integer i=0;i< reqIds.size(); i++) {
            string str= reqIds[i].replace('(','');
            str=str.replace('[','');
            str=str.replace(']','');
            str=str.replace(')','');
            VarIds = str.split(',');
        }        
        system.debug('@@@ VarIds'+VarIds);
        String bccEmailAddress='';
        GFRS_Ltng_OrgSettings__c myOrgCS = GFRS_Ltng_OrgSettings__c.getOrgDefaults();
        if(myOrgCS.gFRS_Inbound_Email__c != null){
            bccEmailAddress=myOrgCS.gFRS_Inbound_Email__c;
        }       
        Id senderId = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'fundingrequestsystem-donotreply-d@gene.com' LIMIT 1].id;
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Attachment> attachments = new List<Attachment>();              
       
        List<String> AttchmentId = new List<String>();
        for(gFRS_Ltng_Application__c app: [select id,name,owner.Email,RFI_SubmitDate__c,RecordType.Name,RFI_Reminder_Days__c, (select id ,Name from attachments where Name LIKE '%RFI%'  order by createddate desc limit 1 )from gFRS_Ltng_Application__c where id =:VarIds]) {
            
            for(Attachment attachmentRecord: app.Attachments) {
                AttchmentId.add(attachmentRecord.id);                          
            }
           
        }
         
        Map<Id,Attachment> attachmap1 = new Map<Id,Attachment>();
        for(Attachment attachmentRecord: [select id,Name,body,parentId from attachment where id=:AttchmentId]) {
            attachmap1.put(attachmentRecord.parentId,attachmentRecord);
        }
       for(gFRS_Ltng_Application__c app: [select id,name,owner.Email,RFI_SubmitDate__c,RecordType.Name,RFI_Reminder_Days__c, (select id ,name from attachments where Name LIKE '%RFI%'  order by createddate desc limit 1 )from gFRS_Ltng_Application__c where id=:VarIds]) {
            if(attachmap1.containsKey(app.Id)){
                mails.add( createRemainderEmail(app, attachmap1.get(app.Id) ,senderId,bccEmailAddress));
            }
            
        }         
        Messaging.sendEmail(mails); 
    }
    
    
    /**     
     * @param request input gFRS Application Record
     * @param attachment input Attachment record
     * @param Id input orgMail Id list
     * @param bcc input mail of  org mail id
     
     * @return mail
     */
    public static Messaging.SingleEmailMessage createRemainderEmail(gFRS_Ltng_Application__c request,attachment attch, Id senderId, string bcc ) {
        
        String bodyContent = attch.body.toString();        
        String s2 = ''; 
        
        String emailSub = '';
        //if(request.RFI_SubmitDate__c + 7 == System.today()){
        //MOD(DATEVALUE({!$Flow.CurrentDateTime})-DATEVALUE({!RFiRecordValues.RFI_SubmitDate__c} ),14)
        if(request.RFI_Reminder_Days__c == 7)  {
            
            if(request.RecordType.Name == 'Independent Medical Education (CME)' || 
                request.RecordType.Name == 'Community Giving' || 
                request.RecordType.Name == 'Education Focused Giving Graduate and Post-Graduate' ||
                request.RecordType.Name == 'Education Focused Giving K-12' ||
                request.RecordType.Name == 'Patient and Health Focused Giving' ||
                request.RecordType.Name == 'Scientific and Research Focused Giving') {
                    emailSub = 'REMINDER: Request for Information (RFI) - Genentech Funding Request ID '+request.Name+'';
                    s2 = bodyContent.substringAfter('Genentech Funding Request ID '+request.Name);
                }
            if (request.RecordType.Name == 'Foundation Safety Net Support' || 
                request.RecordType.Name == 'Foundation Undergraduate') {
                	emailSub = 'REMINDER: Request for Information (RFI) - Genentech Funding Request ID '+request.Name+'';
                    s2 = bodyContent.substringAfter('Genentech Foundation Funding Request ID '+request.Name);
                }
            if (request.RecordType.Name == 'Field Exhibits'|| request.RecordType.Name == 'Commercial Sponsorship'||
                request.RecordType.Name == 'Non-Commercial Sponsorship'||request.RecordType.Name=='Corporate Memberships') {
                	emailSub = 'REMINDER: gFRS Request ID '+request.Name+' - Request for Information (RFI)';
                    s2 = bodyContent.substringAfter('Request for Information (RFI)'); 
                }
        }
        
        if(request.RFI_Reminder_Days__c == 14)  {
            if(request.RecordType.Name == 'Independent Medical Education (CME)' || 
                request.RecordType.Name == 'Community Giving' || 
                request.RecordType.Name == 'Education Focused Giving Graduate and Post-Graduate' ||
                request.RecordType.Name == 'Education Focused Giving K-12' ||
                request.RecordType.Name == 'Patient and Health Focused Giving' ||
                request.RecordType.Name == 'Scientific and Research Focused Giving') {
                    emailSub = 'FINAL REMINDER: Request for Information (RFI) - Genentech Funding Request ID '+request.Name+'';
                    s2 = bodyContent.substringAfter('Genentech Funding Request ID '+request.Name); 
                }
            if (request.RecordType.Name == 'Foundation Safety Net Support' || 
                request.RecordType.Name == 'Foundation Undergraduate') {
                	emailSub = 'REMINDER: Request for Information (RFI) - Genentech Funding Request ID '+request.Name+'';
                    s2 = bodyContent.substringAfter('Genentech Foundation Funding Request ID '+request.Name);
                }
            if (request.RecordType.Name == 'Field Exhibits'|| request.RecordType.Name == 'Commercial Sponsorship'||
                request.RecordType.Name == 'Non-Commercial Sponsorship'||request.RecordType.Name=='Corporate Memberships') {
                	emailSub = 'REMINDER: gFRS Request ID '+request.Name+'- Request for Information (RFI)';
                    s2 = bodyContent.substringAfter('Request for Information (RFI)'); 
                }
        }
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        List<string> emails = new List<String>();  
        List<string> bCCEmails = new List<String>();
        bCCEmails.add(bcc);       
        emails.add(request.owner.email);        
        if(senderId!=null){
            mail.setOrgWideEmailAddressId(senderId);
        }
        if(bcc != null){
            mail.setBccAddresses(bCCEmails);
        }
        mail.setToAddresses(emails);        
        mail.setPlainTextBody(s2);        
        //mail.setSubject('REMINDER: gFRS Request ID'+request.Name+'- Request for Information (RFI)');
        mail.setSubject(emailSub);
        mail.setSaveAsActivity(false);
        return mail;
    }
}