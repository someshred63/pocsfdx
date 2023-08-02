/*****************************************************************************************************************************
CLASS NAME: gFRS_Contact_Communication
DESCRIPTION: 
LOGS: Maintain atleast last 5 logs

DATE			DEVELOPER			PURPOSE
-----------------------------------------------------------------------------------------------------------------------------
09-Sep-2020		Kiran				Modified  method sendEmail() to send emails to record owners.

******************************************************************************************************************************/


public class gFRS_Contact_Communication {
    
    @AuraEnabled
    public static wrapperEmailData getEmailContent(String EmailName, String RecId){

        wrapperEmailData returnwrapperClass = new  wrapperEmailData ();
        EmailTemplate  emailCon=[SELECT Subject, Name, Id, Description, Body,DeveloperName
                                 FROM EmailTemplate
                                 WHERE DeveloperName = :EmailName ];
        gFRS_Ltng_Pre_Application__c gfrsRequest=[SELECT Id,Owner.FirstName,Owner.LastName, Owner.email,Event_Program_Title__c,Status__c,Name FROM gFRS_Ltng_Pre_Application__c Where Id=:RecId];
        
        String emailSub = emailCon.Subject;
        emailSub = emailSub.replace('<<G-#####>>', gfrsRequest.Name);
        
        User usrRec = [SELECT Id, Username, LastName, FirstName, Name, CompanyName FROM User Where Id=:UserInfo.getUserId()];
        
        String body = emailCon.Body;
        body = body.replace('<<G-#####>>', gfrsRequest.Name);     
        body = body.replace('<<First Name Last Name>>',gfrsRequest.Owner.FirstName+''+gfrsRequest.Owner.LastName);
        String senderName = Userinfo.getFirstName() + ' ' + Userinfo.getLastName();
        body = body.replace('<<Sender First Name Last Name>>', senderName);
       	String fName='';
        returnwrapperClass.emailBody = body;
        returnwrapperClass.subject = emailSub;
        returnwrapperClass.bcc = 'fundingrequestsystem-donotreply-dev-d@gene.com';
        returnwrapperClass.ownerEmail = gfrsRequest.Owner.email;
        returnwrapperClass.ownerName = gfrsRequest.Owner.FirstName+''+gfrsRequest.Owner.LastName;
        
        
        return returnwrapperClass;

    }
    
    @AuraEnabled
    public static Boolean sendEmail(String To,String RecId,String EmailBody,String bcc,String Subject,String cc){
        Boolean isSuccess = false;
        Messaging.SingleEmailMessage email=new Messaging.SingleEmailMessage();
        List<String> toAddresses = new List<String>();
        List<String> toCCddresses = new List<String>();
        List<String> tobCCddresses = new List<String>();
        
        /* Added code as part of defect fix ** Kiran */
        if(String.isNotBlank(To)){
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
        
        if(String.isNotBlank(cc)){
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
        if(String.isNotBlank(bcc)){
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
        email.setToAddresses(toAddresses);
        email.setCcAddresses(toCCddresses);
        email.setBccAddresses(tobCCddresses);
        email.setSubject(Subject);
        email.setPlainTextBody(EmailBody);
        
        try{
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });  
            if(results[0].success){
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
                    
                    
                    if(email.plainTextBody != null){
                        fileContent += EncodingUtil.urlDecode(email.plainTextBody,'UTF-8');
                    }  
                    
                    a.Body = Blob.valueOf(fileContent);  
                    a.Name = email.subject.replace('Genentech','Communication').replace(' ','_').replace('[','').replace(']','').replace(',','_').replace(':','').replace('@','at').replace('Sandbox_','')+'.txt'; 
                    
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
                
            }else{
                isSuccess = FALSE;
            }
        } catch(Exception ex){
            isSuccess = FALSE;
        }
        return isSuccess;
        
    }
    
    public class wrapperEmailData{
        @AuraEnabled public String emailBody{get;set;}
        @AuraEnabled public String ownerEmail{get;set;}
        @AuraEnabled public String subject{get;set;}
        @AuraEnabled public String bcc{get;set;}
        @AuraEnabled public String ownerName{get;set;}
        
    }
}