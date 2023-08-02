/**
* @author GFRS Dev Team
* @date 02/01/2014
* @description gFRS_AttachEmailForFundingRequestService class - responsible for Handling Inbound Emails sent from gfrs application (as for now only from RFI/Communication process) 
*/
global class gFRS_AttachEmailForFundingRequestService implements Messaging.InboundEmailHandler {
  
  
  /**
  * @author GFRS Dev Team
  * @date 02/01/2014
  * @description handleInboundEmail method - responsible for handling inboud emails, method search in subject of email name of FR
    like [G-XXXXXXXX] if name will be found content of email will be attached under Funding Request 
  */
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {

    Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
    Pattern MyPattern                   = Pattern.compile('.*\\[ref.*\\]$');
    String emailContent                 = email.plainTextBody.trim();
    String lastLineOfEmailContent       = '';

        if(emailContent.lastIndexOf('\n') != -1){
            lastLineOfEmailContent = emailContent.substring(emailContent.lastIndexOf('\n'));
        }
        
        Matcher MyMatcher = MyPattern.matcher(lastLineOfEmailContent);

    if(MyMatcher.find()){
        system.debug(MyMatcher.group());
      if(MyMatcher.group() != null){

        String refString                                  = MyMatcher.group();
        refString                                         = refString.replace('[ref:','').replace(']','');
        Id reqId = refString;

        if(reqId.getsobjecttype() == GFRS_Funding_Request__c.sObjectType){
            List<GFRS_Funding_Request__c> fundingRequests = [SELECT Id FROM GFRS_Funding_Request__c WHERE Id=:reqId];
            if(fundingRequests.size()>0 ){
              try{
                system.debug(envelope);  
                Attachment a       = new Attachment();
                a.ParentId         = fundingRequests[0].id;
                String fileContent = '';
                
                fileContent +='From: '+email.fromAddress+'\n';
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
                a.Name = email.subject.replace(' ','_').replace('[','').replace(']','').replace(',','_').replace(':','').replace('@','at').replace('Sandbox_','')+'.txt'; 
                
                if(email.fromName != null){
                  a.Description='Sent by ' +email.fromName;
                }else{
                  List<User> sender = new List<User>([SELECT Id, Name FROM User WHERE email=:email.fromAddress]);
                  if(sender.size()>0){
                    a.Description='Sent by ' +sender[0].Name;
                    
                  }  
                } 
                
                
                insert a;
                
                result.success=true;
              }catch(Exception ex){
                result.success=false;
                
                system.debug(ex.getMessage());
              }  
            }
            
          }else if(reqId.getsobjecttype() == gFRS_Copay_Funding_Request__c.sObjectType){
            List<gFRS_Copay_Funding_Request__c> fundingRequests = [SELECT Id FROM gFRS_Copay_Funding_Request__c WHERE Id=:reqId];
            if(fundingRequests.size()>0 ){
              try{
                system.debug(envelope);  
                Attachment a       = new Attachment();
                a.ParentId         = fundingRequests[0].id;
                String fileContent = '';
                
                fileContent +='From: '+email.fromAddress+'\n';
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
                a.Name = email.subject.replace(' ','_').replace('[','').replace(']','').replace(',','_').replace(':','').replace('@','at').replace('Sandbox_','')+'.txt'; 
                
                if(email.fromName != null){
                  a.Description='Sent by ' +email.fromName;
                }else{
                  List<User> sender = new List<User>([SELECT Id, Name FROM User WHERE email=:email.fromAddress]);
                  if(sender.size()>0){
                    a.Description='Sent by ' +sender[0].Name;
                    
                  }  
                } 
                
                
                insert a;
                
                result.success=true;
              }catch(Exception ex){
                result.success=false;
                
                system.debug(ex.getMessage());
              }  
            }
            
          }   
      }
      
    }
        

        return result;
    }
    
    
}