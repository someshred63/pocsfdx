/*****************************************************************************************************************************
CLASS NAME: PreAppRecUpdate
DESCRIPTION: 
LOGS: Maintain atleast last 5 logs

DATE            DEVELOPER           PURPOSE
-----------------------------------------------------------------------------------------------------------------------------
07-Sep-2020     Kiran               Created  a method sendNotificationEmails() to send emails to record owners.
09-Sep-2020     Kiran               Created  a method checkTinStatus() to check taxid in Tincheck service.

******************************************************************************************************************************/

public class PreAppRecUpdate {
     @AuraEnabled
    public static Boolean updateStatus(Id recId){
        
        Boolean checkEMDRecFlag = false;
        user u= [Select Id,Name From User Where Id =:UserInfo.getUserId()];
        List<gFRS_Ltng_Pre_Application__c> recListToUpdate = new List<gFRS_Ltng_Pre_Application__c>();
        for(gFRS_Ltng_Pre_Application__c rec:[Select id,Status__c,PreApp_Business_Reviewer__c from gFRS_Ltng_Pre_Application__c  where Id=:recId]){
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
    public static string updateInvitedtoapply(Id recId){
       string StatusVal = '';
        List<gFRS_Ltng_Pre_Application__c> recListToUpdate = new List<gFRS_Ltng_Pre_Application__c>();
        for(gFRS_Ltng_Pre_Application__c rec:[Select id,Status__c,PreApp_Business_Reviewer__c from gFRS_Ltng_Pre_Application__c  where Id=:recId]){
            if(rec.Status__c == 'In Process' && rec.Status__c != 'Invited to apply' && rec.Status__c != 'Not Invited to apply'){
            rec.Status__c = 'Invited to apply';
            recListToUpdate.add(rec);
            }
            else
            {
                StatusVal = rec.Status__c;
            }
        }
        if(recListToUpdate.size()>0){
        update recListToUpdate;
        StatusVal = 'success';
        
        }
        
        return StatusVal;
        
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
    public static gFRS_Ltng_Pre_Application__c getCurrentRecordStatus(Id recId){
       gFRS_Ltng_Pre_Application__c rec = [Select id,Status__c,Giving_Priorities_Alignment__c,gFRS_Organization__c,gFRS_Organization__r.Tax_Status__c from gFRS_Ltng_Pre_Application__c where Id=:recId];        
       return rec; 
    }
    
    @AuraEnabled
    public static wrapperEmailData getEmailContent(String EmailName, String RecId, List<String> SelectedFields){

        wrapperEmailData returnwrapperClass = new  wrapperEmailData ();
        EmailTemplate  emailCon=[SELECT Subject, Name, Id, Description, Body,DeveloperName,HtmlValue
                                 FROM EmailTemplate
                                 WHERE DeveloperName = :EmailName ];
        gFRS_Ltng_Pre_Application__c gfrsRequest=[SELECT Id,Owner.FirstName,Owner.LastName,Email__c,Owner.email,Event_Program_Title__c,Status__c,Name,CGN_PLNG_Title__r.CGN_PLNG_Title__c FROM gFRS_Ltng_Pre_Application__c Where Id=:RecId];
        //string str = '<'+RecId.left(9)+'@'+RecId.right(9)+'>';
        String emailSub = emailCon.Subject;
        emailSub = emailSub.replace('<<G-#####>>', gfrsRequest.Name);        
        emailSub = emailSub.replace('{!gFRS_Ltng_Pre_Application__c.Name}', gfrsRequest.Name); 
        //emailSub = emailSub.replace('<<#######>>',str);
        User usrRec = [SELECT Id, Username, LastName, FirstName, Name, CompanyName FROM User Where Id=:UserInfo.getUserId()];
       
         String body =  emailCon.HtmlValue;
        system.debug('value' +body);
        //String body = emailCon.Body;
       // body.unescapeHtml4();
       // System.debug('-unescaped4->'+body.unescapeHtml4());
        //body.stripHtmlTags();
       // body=body.replace('<p><br /></p>','');
        body=body.replace(']]>','');
        //body=body.replace('contact me','<a href=https://salesforce.com>contact me</a>');
        body = body.replace('<<G-#####>>', gfrsRequest.Name);     
        body = body.replace('{!gFRS_Ltng_Pre_Application__c.Name}', gfrsRequest.Name); 
        if(gfrsRequest.CGN_PLNG_Title__r.CGN_PLNG_Title__c != null && gfrsRequest.CGN_PLNG_Title__r.CGN_PLNG_Title__c != '') {
        body = body.replace('{!RFP_Title}', gfrsRequest.CGN_PLNG_Title__r.CGN_PLNG_Title__c);
        }else{
            body = body.replace('{!RFP_Title}', '');
        }
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
        body = body.replace('{!Sender First Name Last Name}', gfrsRequest.Owner.FirstName+' '+gfrsRequest.Owner.LastName);
       
        returnwrapperClass.emailBody = body;
        returnwrapperClass.subject = emailSub;
        returnwrapperClass.bcc = 'FundingRequestSystem-donotreply-d@gene.com';        
        //returnwrapperClass.ownerEmail = gfrsRequest.Email__c;    /*comment as part of defect fix **Kiran */
        returnwrapperClass.ownerEmail = gfrsRequest.owner.email; /* add code as part of defect fix - Sending email to the record owner email add code as part of defect fix **Kiran */
        returnwrapperClass.recStatus = gfrsRequest.Status__c;
        returnwrapperClass.ownerName = gfrsRequest.Owner.FirstName+''+gfrsRequest.Owner.LastName;
        return returnwrapperClass;

    }
        /*
    Method Name:sendNotificationEmails
    Description: This method will help to send emails to users when Pre App record status is changed to not invited to Apply. 
    */
    @AuraEnabled
    public static Boolean  sendNotificationEmails(String To,String RecId,String EmailBody,String bcc,String Subject, String recordStatus, String cc){
        //system.debug('toAddresses'+To);
        //System.debug('toccddresses'+bcc);
        //System.debug('tobCCddresses'+cc );
        String refferId = '[ref:'+RecId+']';
        Boolean isSuccess = false;
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        List<String> toAddresses = new List<String>();
        List<String> toCCddresses = new List<String>();
        List<String> tobCCddresses = new List<String>();
        
        if(String.isNotBlank(To)){ /* Added code as part of defect fix ** Kiran */
            if(To.contains(',')){
                for(String emailId:To.split(',')){
                    if(emailId != null && emailId !=''&& emailId != ' '){
                        toAddresses.add(emailId.trim());
                        
                    } 
                }
            }
            else{
                toAddresses.add(To);
            }
            
        }
        
        if(String.isNotBlank(cc)){ /* Added code as part of defect fix ** Kiran */
            if(cc.contains(',')){
                for(String emailId:cc.split(',')){
                    if(emailId != null && emailId !=''&& emailId != ' '){
                        toCCddresses.add(emailId.trim());
                        
                    } 
                }
            }
            else{
                toCCddresses.add(cc);
            }
            
        }
        if(String.isNotBlank(bcc)){ /* Added code as part of defect fix ** Kiran */
            if(bcc.contains(',')){
                for(String emailId:bcc.split(',')){
                    if(emailId != null && emailId !=''&& emailId != ' '){
                        tobCCddresses.add(emailId.trim());
                        
                    } 
                }
            }else{
                tobCCddresses.add(bcc);
            }
        }
        
        GFRS_Ltng_OrgSettings__c myOrgCS = GFRS_Ltng_OrgSettings__c.getOrgDefaults();
        if(myOrgCS.gFRS_Inbound_Email__c != null){
            String bccEmailAddress=myOrgCS.gFRS_Inbound_Email__c;
            tobCCddresses.add(bccEmailAddress.trim());
        }
        
        System.debug('toAddresses'+toAddresses);
        System.debug('toccddresses'+toccddresses);
        System.debug('tobCCddresses'+tobCCddresses);
        string str = '<'+RecId.left(9)+'@'+RecId.right(9)+'>';
        String reff = 'References: 1*'+str+' CRLF';
        System.debug('RecordID'+str);
        System.debug('RecordID'+reff);
        OrgWideEmailAddress owea = [select Id from OrgWideEmailAddress where Address='fundingrequestsystem-donotreply-d@gene.com' LIMIT 1];
        email.setOrgWideEmailAddressId(owea.Id);
        email.setToAddresses(toAddresses);
        email.setCcAddresses(toccddresses);
        email.setBccAddresses(tobCCddresses);
        email.setReferences('References: 1*'+str+' CRLF');
        email.setSubject(Subject);
        email.setHtmlBody(EmailBody);
        //email.setPlainTextBody(EmailBody);
        email.setTreatBodiesAsTemplate(true);
        try{
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });  
           
           if(results[0].success){// Added code as part of defect fix ** Kiran
                //System.debug('result'+results);
                try{
                    Attachment a       = new Attachment();
                    a.ParentId         = RecId;
                    a.ContentType = '.pdf';
                    String fileContent = '';
                    
                    fileContent +='From: '+email.toaddresses+'\n';
                    fileContent +='To: '+email.toAddresses+'\n';
                    
                    if(email.ccAddresses == null){
                        fileContent +='CC: \n';  
                    }else{
                        fileContent +='CC: '+email.ccAddresses+'\n';
                    }
                    fileContent =fileContent.replace(')','').replace('(','');
                    fileContent +='Subject: '+email.subject+'\n\n';
                    string bodyText;
                    if (string.isEmpty(email.htmlBody)){
                        bodyText = email.plainTextBody;                        
                    }else{
                        bodyText = HtmlToText(email.htmlBody);                        
                    }
                    fileContent += EncodingUtil.urlDecode(bodyText,'UTF-8');
                    a.Body = Blob.valueOf(fileContent);  
                    a.Name = email.subject.replace(' ','_').replace('[','').replace(']','').replace(',','_').replace(':','').replace('@','at').replace('Sandbox_','')+'.txt'; 
                    
                    if(email.toaddresses != null){
                        a.Description='Sent by ' +email.toaddresses;
                    }else{                  
                        a.Description='test';
                        
                    }  
                    
                    insert a;                                
                    isSuccess = TRUE;
                }
                catch(Exception e){
                    isSuccess = FALSE; 
                } 
               isSuccess = TRUE;
            }else{
                isSuccess = FALSE;
            }
        } catch(Exception ex){
            isSuccess = FALSE;
        }
        return isSuccess;   
        
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
        @AuraEnabled public String emailBody{get;set;}
        @AuraEnabled public String ownerEmail{get;set;}
        @AuraEnabled public String subject{get;set;}
        @AuraEnabled public String bcc{get;set;}
        @AuraEnabled public String recStatus{get;set;}
        @AuraEnabled public String ownerName{get;set;}
        
    }
    
    @AuraEnabled
    public static void updateStatusNTA(Id recId,String decision,String action,String givingType,String givingSubType){
        //Boolean checkEMDRecFlag = false;
        
        List<gFRS_Ltng_Pre_Application__c> recListToUpdate = new List<gFRS_Ltng_Pre_Application__c>();
        for(gFRS_Ltng_Pre_Application__c rec:[Select id,Status__c,Decision_Reaons__c,Giving_Type__c,Giving_Sub_Type__c from gFRS_Ltng_Pre_Application__c  where Id=:recId]){
            //if((rec.Status__c == 'In Process' || rec.Status__c == 'Invited to apply') && rec.Status__c != 'Not Invited to apply'){
            if(action == 'Invited'){
                rec.Status__c = 'Invited to apply';
                rec.Giving_Type__c = givingType;
                rec.Giving_Sub_Type__c = givingSubType;
            } else {
                rec.Status__c = 'Not Invited to apply';
                rec.Decision_Reaons__c = decision;                
            }

            recListToUpdate.add(rec);
            /* }else if(rec.Status__c == 'Not Invited to apply'){
                //checkEMDRecFlag = false;
            } */    
            
        }
        
        if(recListToUpdate.size()>0){
            String msg = '';
        try{
            //update  Record
            update recListToUpdate; 
             
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
        finally {
        }
        }
        
    }
    
    /*
    Method Name:checkTinStatus
    Description: This method will help to check tax id is valid or not in Tin check service. 
    */
    @AuraEnabled
    public static wrapperTinCheck checkTinStatus(String recId){
        wrapperTinCheck wrapTin = new wrapperTinCheck();
        
        gFRS_Ltng_Pre_Application__c rec =[Select id,Status__c, Organization_Tax_ID__c,Organization_Name__c from gFRS_Ltng_Pre_Application__c where Id=:recId];
        String orgTaxID = rec.Organization_Tax_ID__c;
        if(String.isNotBlank(orgTaxID)){
            orgTaxID = orgTaxID.replaceAll('[^0-9s+]', '');
            System.debug('strText ======> '+orgTaxID);
            }
        if((rec.Status__c != 'In Process' && rec.Status__c != 'Invited to apply' && rec.Status__c != 'Not Invited to apply')){
        
        gFRS_Ltng_TincheckWebservice.PVSServiceSoap TinCheck = new gFRS_Ltng_TincheckWebservice.PVSServiceSoap(); 

            gFRS_Ltng_TincheckWebservice.TinNameClass TinNameClass = new gFRS_Ltng_TincheckWebservice.TinNameClass();
            TinNameClass.TIN = orgTaxID;
            TinNameClass.LName = rec.Organization_Name__c;
            TinNameClass.Encryption = '';
            TinNameClass.FName = '';
            TinNameClass.Giin = '';

            gFRS_Ltng_TincheckWebservice.UserClass UserClass = new gFRS_Ltng_TincheckWebservice.UserClass();
            UserClass.UserID = '';
            UserClass.UserLogin = 'ylam@gene.com';
            UserClass.UserPassword = 'vendormaster';
            UserClass.UserEncryption = '';

            gFRS_Ltng_TincheckWebservice.TINNAME_RESPONSE Response = TinCheck.ValidateTinName(TinNameClass, UserClass);
            system.debug('Tin Name Code is : '+Response.TINNAME_CODE);
            system.debug('Tin Name Details are : '+Response.TINNAME_DETAILS);

            wrapTin.tinCode = Response.TINNAME_CODE;
            //wrapTin.tinCode = '6';
            wrapTin.tinDetails = Response.TINNAME_DETAILS;
            
            return wrapTin;

        }else{
        if(rec.Status__c == 'In Process' || rec.Status__c == 'Invited to apply' || rec.Status__c == 'Not Invited to apply'){
            wrapTin.recStatus= true;
        }
        return wrapTin;
        }
  
    
    }
    public class wrapperTinCheck{
        @AuraEnabled public String tinCode{get;set;}
        @AuraEnabled public String tinDetails{get;set;}
        @AuraEnabled public boolean recStatus{get;set;}        
        
    }
    
    
}