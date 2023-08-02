/**********************************************************************************************************************
Purpose: ROBOCOPS-178 
System shall send renewal email notification when Processed Date/Time on a processed request >= 21 Months.   
=======================================================================================================================
History                                                            
-------                                                            
VERSION  AUTHOR        DATE            DETAIL                       
1.0     Raju Manche  9/10/2020      INITIAL DEVELOPMENT

***********************************************************************************************************************/
public class SPLOA_RenewalEmailRemainder_Batch implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        C_Ops_Captcha_Property__c captcha =[SELECT Id,Active__c,Auto_Renewal_Send_Cadence__c,Months_to_Expired__c FROM C_Ops_Captcha_Property__c WHERE Active__c = true LIMIT 1];
        
        Integer monthstoRemind = Integer.valueOf(captcha.Auto_Renewal_Send_Cadence__c);
        Integer monthsExpire = Integer.valueOf(captcha.Months_to_Expired__c);
        system.debug('monthstoRemind'+monthstoRemind+'monthsExpire'+monthsExpire);
        //  Integer diffbetweenmonths = monthsExpire - monthstoRemind;
        
        DateTime expirydate = System.now().addMonths(-monthsExpire);
        DateTime reminddate = System.now().addMonths(-monthstoRemind); 
        system.debug('expirydate'+expirydate+'reminddate'+reminddate);
        String query =  'SELECT ID, Name, C_Ops_SPLOA_Request_Status__c,Renew_Request_Submitted__c ,SPLOA_Initial_Renewal_Email_Sent_Date__c, C_Ops_SPLOA_Email__c, Processed_Date__c ' + 'FROM C_Ops_SPLOA_Request__c ' + 
            'WHERE Renew_Request_Submitted__c != True ' +
            'AND C_Ops_SPLOA_Request_Status__c = \'Processed\'  ' +
            'AND Processed_Date__c<=:reminddate AND Processed_Date__c>:expirydate ';
        //+
        //'AND C_Ops_SPLOA_Email__c = \'mancher@gene.com\'  ';
        //   ' AND Processed_Date__c< :reminddate AND Processed_Date__c> :expirydate ';
        
        system.debug('query'+query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<C_Ops_SPLOA_Request__c> scope) {
        system.debug('scope'+scope.size());
        EmailTemplate template = getEmailTemplate('IAP Renewal Email Notification'); 
        sendEmailNotifications(scope, template);
    }    
    
    public void finish(Database.BatchableContext bc) {
    } 
    
    
    private EmailTemplate getEmailTemplate(String templateName) {
        EmailTemplate template = null;
        if(!String.isBlank(templateName)) {
            template = [
                SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body 
                FROM EmailTemplate 
                WHERE Name = :templateName 
            ];
        }
        return template;
    }
    
    private void sendEmailNotifications(List<C_Ops_SPLOA_Request__c> reqList, EmailTemplate template) {
        C_Ops_Captcha_Property__c captcha =[SELECT Id,Active__c,Auto_Renewal_Send_Cadence__c,Months_to_Expired__c FROM C_Ops_Captcha_Property__c WHERE Active__c = true LIMIT 1];
        system.debug('reqList*****'+reqList);
        List<contact> conlist = new List<contact> ();
        List<C_Ops_SPLOA_Request__c> updatedReqList = new List<C_Ops_SPLOA_Request__c> ();
        set<Id> conIdset = new set<Id>();
        Integer monthstoRemind = Integer.valueOf(captcha.Auto_Renewal_Send_Cadence__c);
        Integer monthsExpire = Integer.valueOf(captcha.Months_to_Expired__c);
        
        DateTime expirydate = System.now().addMonths(-monthsExpire);
        Date renewDate = System.today().addMonths(-monthstoRemind); 
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        if(reqList!=null && !reqList.isEmpty()) {
            for(C_Ops_SPLOA_Request__c req: reqList) {
                Contact conrec = new Contact();
                conrec.FirstName = 'connnmae';
                conrec.LastName = 'conlastname';
                conrec.Email = req.C_Ops_SPLOA_Email__c;
                conlist.add(conrec);
                //insert conrec;
            }
            if(!conlist.isEmpty()){
                insert conlist;        
            }
            for(contact con : conlist){
                conIdset.add(con.Id);
            }
            Map<Id,String[]> toAddressesByReqNumber = new Map<Id,String[]> ();
            Contact[] contacts = [SELECT Id, Name, Email FROM Contact WHERE Id IN :conIdset LIMIT 1];
            Messaging.SingleEmailMessage[] dummyEmails = new Messaging.SingleEmailMessage[]{};
                Messaging.SingleEmailMessage[] actualEmails = new Messaging.SingleEmailMessage[]{};
                    List<Messaging.SingleEmailMessage> emailListToSend = new List<Messaging.SingleEmailMessage>();
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'indirectaccess@gene.com'];            
            for(C_Ops_SPLOA_Request__c req : reqList){
                System.debug('req*****'+req);
                Integer renewnotification;
                /*
Date processeddate = (req.Processed_Date__c).date();
Integer daysbetween = system.today().daysBetween(processeddate) ;                
Integer renewnotification = math.mod(daysbetween,14);
system.debug('processeddate*****'+processeddate);
*/                
                //system.debug('renewDate*****'+renewDate);                
                if(req.SPLOA_Initial_Renewal_Email_Sent_Date__c==null) {
                    //system.debug('reqList*****'+reqList);
                    toAddressesByReqNumber.put(req.Id,new List<String> { req.C_Ops_SPLOA_Email__c});            
                    email = new Messaging.SingleEmailMessage();                    
                    //set up email for a fake send.
                    email.setWhatId(req.Id);
                    email.setTemplateId(template.Id);
                    email.setTargetObjectId(contacts[0].Id);
                    email.setSaveAsActivity(false);                      
                    dummyEmails.add(email);                    
                    req.SPLOA_Initial_Renewal_Email_Sent_Date__c=System.today();
                    updatedReqList.add(req);
                }                
                //List<String> usersId = toAddressesByReqNumber.get(req.Id);                
                else if(req.SPLOA_Initial_Renewal_Email_Sent_Date__c!=null) {
                    Date processeddate = (req.Processed_Date__c).date();                                
                    Date InitialReminderSentDate = req.SPLOA_Initial_Renewal_Email_Sent_Date__c;
                    system.debug('InitialReminderSentDate*****'+InitialReminderSentDate);
                    //system.debug('processedDateNextDueDate*****'+processeddate.addDays(14));
                    system.debug('processedDateNextDueDate*****'+InitialReminderSentDate.addDays(14));
                    Integer daysbetween = system.today().daysBetween(InitialReminderSentDate);  
                    system.debug('daysbetween*****'+daysbetween);                
                    renewnotification = math.mod(daysbetween,14);
                    system.debug('renewnotification*****'+renewnotification);                
                    if(renewnotification ==0) {
                        //system.debug('reqList*****'+reqList);
                        toAddressesByReqNumber.put(req.Id,new List<String> { req.C_Ops_SPLOA_Email__c});            
                        email = new Messaging.SingleEmailMessage();                    
                        //set up email for a fake send.
                        email.setWhatId(req.Id);
                        email.setTemplateId(template.Id);
                        email.setTargetObjectId(contacts[0].Id);
                        email.setSaveAsActivity(false);                      
                        dummyEmails.add(email);
                    }
                }
            }
            try {
                Savepoint sp = Database.setSavepoint();
                //this causes the email to be parsed.
                Messaging.sendEmail(dummyEmails);
                //we don't actually want to send the email to the owner, so rollback.
                Database.rollback(sp);
            }
            catch (Exception ex) {
            }            
            //now extract our compiled/parsed messages
            for(Messaging.SingleEmailMessage e : dummyEmails){
                
                String[] toAddresses = toAddressesByReqNumber.get(e.getWhatId());
                if (toAddresses.size()<1){
                    continue;
                }
                //extract the parsed details and resend!!
                String mailTextBody = e.getPlainTextBody();
                String mailHtmlBody = e.getHTMLBody();
                String mailSubject = e.getSubject();
                
                //we need a new email to attach all this data to                
                email = new Messaging.SingleEmailMessage();                                     
                if ( owea.size() > 0 ) {
                    email.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                //email.setSenderDisplayName('C-OPS');   
                //email.setReplyTo('cop_sploa-d@gene.com');
                email.setToAddresses(toAddresses);
                email.setHtmlBody(mailHtmlBody);
                email.setPlainTextBody(mailTextBody);
                email.setSubject(mailSubject);
                
                actualEmails.add(email);
            }
            
            try {
                Messaging.sendEmail(actualEmails);
            } 
            catch (Exception ex) {
            }            
            Messaging.SendEmailResult [] r = Messaging.sendEmail(emailListToSend);
            delete conlist;
            update updatedReqList;
        }
    }
}