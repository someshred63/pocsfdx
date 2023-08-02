public class gFRS_Ltng_PreAppBulkapprovalCNTRL {  
   @AuraEnabled
    public static Map<id,string> GetPreApplicationRecords()        
    {
        Map<Id, String> perMap = new Map<Id, String>();
        for(gFRS_Ltng_Pre_Application__c preApprec:[select id,Name,CGN_PLNG_Title__r.Name,CGN_PLNG_Title__r.Id from gFRS_Ltng_Pre_Application__c where Status__c='Submitted' OR Status__c='In Process']){
            perMap.put(preApprec.CGN_PLNG_Title__r.Id,preApprec.CGN_PLNG_Title__r.Name);
        }
        system.debug('IDs' +perMap.keySet());
        system.debug('values' +perMap.values());
        system.debug('size' +perMap.size());
        return perMap;
        
    } 
    
    @AuraEnabled
    public static List<gFRS_Ltng_Pre_Application__c> GetPreApplicationList(String recId)        
    {
        Map<Id, String> perMap = new Map<Id, String>();
        List<gFRS_Ltng_Pre_Application__c> preApprec=[select id,Name,Status__c,Organization_Name__c,Event_Program_Title__c,Requested_Amount__c,Giving_Priorities_Alignment__c,CGN_PLNG_Title__r.Name,CGN_PLNG_Title__c,CGN_PLNG_Title__r.Giving_Priorities_Alignment__c from gFRS_Ltng_Pre_Application__c where CGN_PLNG_Title__r.Id=:recId AND Status__c=:'Submitted'];
        system.debug('values' +preApprec);        
        return preApprec;
        
    }
    @AuraEnabled
    public static Map<String, String> getDecisions(){
        Map<String, String> options = new Map<String, String>();        
        Schema.DescribeFieldResult fieldResult = gFRS_Ltng_Pre_Application__c.Decision_Reaons__c.getDescribe();        
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
    
    @AuraEnabled
    public static List<gFRS_Ltng_Pre_Application__c> GetPreApplicationProcessList(String recId)        
    {
        Map<Id, String> perMap = new Map<Id, String>();
        List<gFRS_Ltng_Pre_Application__c> preApprec=[select id,Name,Status__c,Organization_Name__c,Event_Program_Title__c,Requested_Amount__c,Giving_Priorities_Alignment__c,CGN_PLNG_Title__r.Name,CGN_PLNG_Title__r.Giving_Priorities_Alignment__c from gFRS_Ltng_Pre_Application__c where CGN_PLNG_Title__r.Id=:recId AND Status__c=:'In Process'];
        system.debug('values' +preApprec);        
        return preApprec;
        
    }
    @AuraEnabled
    public static Boolean updateInProcessStatus(List<String> recIds){
        
        Boolean checkEMDRecFlag = false;
        user u= [Select Id,Name From User Where Id =:UserInfo.getUserId()];
        List<gFRS_Ltng_Pre_Application__c> recListToUpdate = new List<gFRS_Ltng_Pre_Application__c>();
        for(gFRS_Ltng_Pre_Application__c rec:[Select id,Status__c,PreApp_Business_Reviewer__c from gFRS_Ltng_Pre_Application__c   where Id =:recIds]){
            if(rec.Status__c != 'In Process' && rec.Status__c != 'Invited to apply' && rec.Status__c != 'Not Invited to apply'&& rec.PreApp_Business_Reviewer__c !=u.id){
                rec.Status__c = 'In Process';            
                rec.PreApp_Business_Reviewer__c = u.id;
                recListToUpdate.add(rec);
            }
            if(rec.PreApp_Business_Reviewer__c !=null||rec.PreApp_Business_Reviewer__c !=''){
                checkEMDRecFlag = false;  
            }
            
        }
        
        if(recListToUpdate.size()>0){
            update recListToUpdate;
            checkEMDRecFlag = true;
        }
        
        
        return checkEMDRecFlag;
        
    }       
    @AuraEnabled
    public static Boolean updateStatusNTA(List<String> recIds,String action,String givingType){
        Boolean checkEMDRecFlag = false;
        system.debug('recIds@@@' +recIds);
        List<gFRS_Ltng_Pre_Application__c> recListToUpdate = new List<gFRS_Ltng_Pre_Application__c>();
        for(gFRS_Ltng_Pre_Application__c rec:[Select id,Status__c,Decision_Reaons__c,Giving_Type__c,Giving_Sub_Type__c from gFRS_Ltng_Pre_Application__c  where Id =:recIds]){            
            
            if(action == 'Invited'){
                rec.Status__c = 'Invited to apply';
                rec.Giving_Type__c = givingType;
                
            } else {
                rec.Status__c = 'Not Invited to apply';
                rec.Decision_Reaons__c = givingType;
            }
            
            recListToUpdate.add(rec);
        }
        
        if(recListToUpdate.size()>0){
            String msg = '';
            
            try{
                //update  Record
                update recListToUpdate; 
                checkEMDRecFlag = true;
                
                
            }catch(DmlException e){ /* Error handling  code updated as part of defect fix **Kiran*/
                //Any type of Validation Rule error message, Required field missing error message, Trigger error message etc..
                
                //Get All DML Messages
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    //Get Validation Rule & Trigger Error Messages
                    msg =+ e.getDmlMessage(i) +  '\n' ;
                }
                //throw DML exception message
                throw new AuraHandledException(msg);
                
            }catch(Exception e){
                //throw all other exception message
                throw new AuraHandledException(e.getMessage());
            }
            
        }
        return checkEMDRecFlag;
    }
    
    @AuraEnabled
    public static Boolean sendEmailNotifications(List<String> recIds,String emailName){
        wrapperEmailData returnwrapperClass = new  wrapperEmailData ();
        Boolean checkEMDRecFlag = false;
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        List<Attachment> attList = new List<Attachment>();
        try{
            Id senderId = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'fundingrequestsystem-donotreply-d@gene.com' LIMIT 1].id;
            EmailTemplate  emailCon=[SELECT Subject, Name, Id, Description, Body,DeveloperName,HtmlValue
                                     FROM EmailTemplate
                                     WHERE DeveloperName =:emailName ];
            //gFRS_Ltng_Pre_Application__c gfrsRequest=[SELECT Id,Owner.FirstName,Owner.LastName,Email__c,Owner.email,Event_Program_Title__c,Status__c,Name FROM gFRS_Ltng_Pre_Application__c where Id =:recIds];
            user u= [Select Id,Name,Username, LastName, FirstName,CompanyName From User Where Id =:UserInfo.getUserId()];        
            for(gFRS_Ltng_Pre_Application__c rec:[SELECT Id,Owner.FirstName,Owner.LastName,Email__c,Owner.email,Event_Program_Title__c,Status__c,Name,CGN_PLNG_Title__r.CGN_PLNG_Title__c FROM gFRS_Ltng_Pre_Application__c where Id =:recIds]){
                returnwrapperClass=createRemainderEmail(rec, emailCon, senderId,u);
                mails.add(returnwrapperClass.mail);
                attList.add(returnwrapperClass.attach);
            }
            system.debug('mail'+mails);
            Messaging.sendEmail(mails);
            insert attList;
            checkEMDRecFlag=true;
            
        }
        catch (Exception ex) {
            system.debug('[EMAIL SEND FAILURE] Exception:' +ex.getMessage());
        }
        return checkEMDRecFlag;
        
    }
    
    public static wrapperEmailData createRemainderEmail(gFRS_Ltng_Pre_Application__c gfrsRequest, EmailTemplate emailTemplate, Id senderId ,User u) {
        wrapperEmailData returnwrapperClass = new  wrapperEmailData ();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String emailSub = emailTemplate.Subject;
        emailSub = emailSub.replace('<<G-#####>>', gfrsRequest.Name);        
        emailSub = emailSub.replace('{!gFRS_Ltng_Pre_Application__c.Name}', gfrsRequest.Name); 
        //String body = emailTemplate.Body;
       // String body =  emailTemplate.HtmlValue;
      String body;
        if(EmailTemplate.DeveloperName=='gFRS_2_0_Limited_Funding_Availability_RFP'||EmailTemplate.DeveloperName=='gFRS_2_0_Limited_budget_availability_RFP'){
         body =  emailTemplate.Body;
        }else{
        body =  emailTemplate.HtmlValue;
        }
        body=body.replace(']]>','');        
        body = body.replace('<<G-#####>>', gfrsRequest.Name);
        if(gfrsRequest.CGN_PLNG_Title__r.CGN_PLNG_Title__c != null && gfrsRequest.CGN_PLNG_Title__r.CGN_PLNG_Title__c != '') {
        body = body.replace('{!RFP_Title}', gfrsRequest.CGN_PLNG_Title__r.CGN_PLNG_Title__c);
        }else{
            body = body.replace('{!RFP_Title}', '');
        }
        body = body.replace('<<RFP Title>>', gfrsRequest.CGN_PLNG_Title__r.CGN_PLNG_Title__c);
        body = body.replace('{!gFRS_Ltng_Pre_Application__c.OwnerFirstName}',gfrsRequest.Owner.FirstName);
        body = body.replace('{!gFRS_Ltng_Pre_Application__c.Name}', gfrsRequest.Name);
        body = body.replace('<<First Name Last Name>>',gfrsRequest.Owner.FirstName+''+gfrsRequest.Owner.LastName);
        body = body.replace('{!gFRS_Ltng_Pre_Application__c.OwnerFirstName}{!gFRS_Ltng_Pre_Application__c.OwnerLastName}',gfrsRequest.Owner.FirstName+''+gfrsRequest.Owner.LastName);
        
        if(gfrsRequest.Event_Program_Title__c != null && gfrsRequest.Event_Program_Title__c != '') {
            body = body.replace('<<Program/Event Title>>', gfrsRequest.Event_Program_Title__c);
            body = body.replace('{!gFRS_Ltng_Pre_Application__c.Event_Program_Title__c}', gfrsRequest.Event_Program_Title__c);
        } else {
            body = body.replace('<<Program/Event Title>>', '');
            body = body.replace('{!gFRS_Ltng_Pre_Application__c.Event_Program_Title__c}', '');
        }
        
        String senderName = Userinfo.getFirstName() + ' ' + Userinfo.getLastName();
        body = body.replace('{!Sender First Name Last Name}', gfrsRequest.Owner.FirstName+''+gfrsRequest.Owner.LastName);
        
        String refferId = '[ref:'+gfrsRequest.Id+']';
        List<String> toAddresses = new List<String>();
        List<String> toCCddresses = new List<String>();
        List<String> tobCCddresses = new List<String>();
        toAddresses.add(gfrsRequest.owner.email);
        //tobCCddresses.add(senderId);
        GFRS_Ltng_OrgSettings__c myOrgCS = GFRS_Ltng_OrgSettings__c.getOrgDefaults();
        if(myOrgCS.gFRS_Inbound_Email__c != null){
            String bccEmailAddress=myOrgCS.gFRS_Inbound_Email__c;
            tobCCddresses.add(bccEmailAddress.trim());
        }
        String recId=gfrsRequest.Id;        
        string str = '<'+recId.left(9)+'@'+recId.right(9)+'>';
        String reff = 'References: 1*'+str+' CRLF';               
        mail.setOrgWideEmailAddressId(senderId);
        mail.setToAddresses(toAddresses);
        mail.setCcAddresses(toccddresses);
        mail.setBccAddresses(tobCCddresses);        
        mail.setReferences('References: 1*'+str+' CRLF');
        mail.setSubject(emailSub);
        System.debug('-HTMLBODY->'+body);
      //  mail.setPlainTextBody(body);
       if(EmailTemplate.DeveloperName=='gFRS_2_0_Limited_Funding_Availability_RFP'||EmailTemplate.DeveloperName=='gFRS_2_0_Limited_budget_availability_RFP'){
          mail.setPlainTextBody(body);  
        }else{
          mail.setHtmlBody(body);
            mail.setTreatBodiesAsTemplate(true);  
        }
      //    mail.setHtmlBody(body);
       //     mail.setTreatBodiesAsTemplate(true); 
        
        returnwrapperClass.mail=mail;
        Attachment a       = new Attachment();
        a.ParentId         = RecId;
        a.ContentType = '.pdf';
        String fileContent = '';
        
        fileContent +='From: fundingrequestsystem-donotreply-d@gene.com'+'\n';
        fileContent +='To: '+mail.toAddresses+'\n';
        
        if(mail.ccAddresses == null){
            fileContent +='CC: \n';  
        }else{
            fileContent +='CC: '+mail.ccAddresses+'\n';
        }
        fileContent =fileContent.replace(')','').replace('(','');
        fileContent +='Subject: '+mail.subject+'\n\n';
        
        
        string bodyText;
        if (string.isEmpty(mail.htmlBody)){
            bodyText = mail.plainTextBody;                        
        }else{
            bodyText = HtmlToText(mail.htmlBody);                        
        }
        fileContent += EncodingUtil.urlDecode(bodyText,'UTF-8'); 
        
        a.Body = Blob.valueOf(fileContent);  
        a.Name = mail.subject.replace(' ','_').replace('[','').replace(']','').replace(',','_').replace(':','').replace('@','at').replace('Sandbox_','')+'.txt'; 
        
        if(mail.toaddresses != null){
            a.Description='Sent by ' +mail.toaddresses;
        }else{                  
            a.Description='test';
            
        }  
        returnwrapperClass.attach=a;
        return returnwrapperClass;
    }
    public static string HtmlToText(string html){
        //replace all <BR> tags with \n to support new lines
        string result = html.replaceAll('<br/>', '\n');
        result = result.replaceAll('<br />', '\n');
        result = result.replaceAll('&nbsp;', ' ');
        result = result.replaceAll('</div>', '\n');
         result = result.replaceAll('</span>', '');
    
        //all HTML/XML tags
        string HtmlPattern = '<.*?>';
        
        Matcher match =  Pattern.compile(HtmlPattern).matcher(result);
        
        //remove the tags and return string     
        return match.replaceAll('');
    }
    
    public class wrapperEmailData{
        @AuraEnabled public Messaging.SingleEmailMessage mail{get;set;}
        @AuraEnabled public Attachment attach{get;set;}
        
        
    }
}