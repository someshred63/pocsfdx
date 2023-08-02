/**
 * @description This class will be called by flow 
 * @author      Kiran Kumar P
 * @createdDate 2021-10-13
 */
public class gFRS_SendProgramStatusEmailI_Remainders {
    @InvocableMethod(label='Send program status email remainder notifications') 
    
    /**     
     * @param reqIds input gFRS Application Id list
     * 
     */
    public static void SendRFINotification(List<String> reqIds){         
        /*String[] VarIds;   
        List<string> RecordId= new List<string>();
        if(reqIds.size()>0){
            for (integer i=0;i< reqIds.size(); i++) {
                VarIds = reqIds[i].split(',');            
            }
        }else{
            VarIds=reqIds;
            
        }*/
        String bccEmailAddress='';
        GFRS_Ltng_OrgSettings__c myOrgCS = GFRS_Ltng_OrgSettings__c.getOrgDefaults();
        if(myOrgCS.gFRS_Inbound_Email__c != null){
            bccEmailAddress=myOrgCS.gFRS_Inbound_Email__c;
        } 
        Id senderId = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'fundingrequestsystem-donotreply-d@gene.com' LIMIT 1].id;       
        EmailTemplate  emailCon=[SELECT Subject, Name, Id, Description, Body,DeveloperName
                                 FROM EmailTemplate
                                 WHERE Name=: 'gFRS 2.0 Program Status Notification email Template'];
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        for(gFRS_Ltng_Application__c app: [select id,Name,Event_Program_Title__c,Program_Start_Date_Min__c,Program_End_Date_max__c,Requested_Amount__c,Owner.FirstName,Owner.LastName, Owner.Email from gFRS_Ltng_Application__c where id=:reqIds]) {
            
            mails.add( createRemainderEmail(app, emailCon ,senderId,bccEmailAddress));
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
    public static Messaging.SingleEmailMessage createRemainderEmail(gFRS_Ltng_Application__c request,EmailTemplate attch, Id senderId,string bcc) {
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String emailSub = attch.Subject;
        String body = attch.Body;
        String title = request.Event_Program_Title__c;      
        string programDate = string.valueOf(request.Program_Start_Date_Min__c);
        string programEndDate = string.valueOf(request.Program_End_Date_max__c);
        string requestedmount = string.valueOf(request.Requested_Amount__c);
        emailSub = emailSub.replace('{!gFRS_Ltng_Application__c.Name}', request.Name);  
        if(String.isNotBlank(request.Owner.FirstName)){
            body= body.replace('{!gFRS_Ltng_Application__c.OwnerFirstName}', request.Owner.FirstName);
        }
        if(String.isNotBlank(programEndDate)){
            body= body.replace('{!gFRS_Ltng_Application__c.Program_End_Date_max__c}', programEndDate);
        }                 
        body = body.replace('{!gFRS_Ltng_Application__c.Name}', request.Name);  
        if(String.isNotBlank(request.Event_Program_Title__c)){
            body = body.replace(' {!gFRS_Ltng_Application__c.Event_Program_Title__c}', request.Event_Program_Title__c); 
        }
        body += '\n\n' + '[ref:' + request.id + ']';  		 
        List<string> emails = new List<String>();     
        emails.add(request.owner.email); 
        List<string> bCCEmails = new List<String>();       
        bCCEmails.add(bcc);
        if(senderId!=null){
            mail.setOrgWideEmailAddressId(senderId);
        }             
        mail.setBccAddresses(bCCEmails);
        mail.setToAddresses(emails);		
        mail.setPlainTextBody(body);  
        mail.setSubject(emailSub);
        mail.setSaveAsActivity(false);
        return mail;
    }
}