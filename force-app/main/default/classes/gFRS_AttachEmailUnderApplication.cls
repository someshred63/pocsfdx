global class gFRS_AttachEmailUnderApplication implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {

    Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
         Id reqId ;
        /*List<String> recId = email.references;
        String recdId = recId[0];
        String strText = recdId;
        strText = strText.replaceAll('[^a-zA-Z0-9s+]', '');
        System.debug('strText ======> '+strText);
         reqId = strText;*/
        
        Pattern MyPattern                   = Pattern.compile('.*\\[ref.*\\]$');
        String emailContent                 = email.plainTextBody.trim();
        String lastLineOfEmailContent       = '';
        
        if(emailContent.lastIndexOf('\n') != -1){
            lastLineOfEmailContent = emailContent.substring(emailContent.lastIndexOf('\n'));
        }
        system.debug('lastLineOfEmailContent'+lastLineOfEmailContent);
        system.debug('MyPattern'+MyPattern);
        Matcher MyMatcher = MyPattern.matcher(lastLineOfEmailContent);
        system.debug('MyPattern'+MyMatcher);
        if(MyMatcher.find()){
            system.debug('iffind'+MyMatcher.group());
            if(MyMatcher.group() != null){
                
                String refString                                  = MyMatcher.group();
                refString                                         = refString.replace('[ref:','').replace(']','');
                system.debug('refString'+refString);
                reqId =Id.valueOf(refString);
                system.debug('reqId'+reqId);
            }
        }
        if( reqId!=null && reqId.getsobjecttype() == gFRS_Ltng_Application__c.sObjectType){
            List<gFRS_Ltng_Application__c> listPreApp = [SELECT Id FROM gFRS_Ltng_Application__c WHERE Id=:reqId];
            if(listPreApp.size()>0 ){
                try{
                    system.debug(envelope);  
                    Attachment a       = new Attachment();
                    a.ParentId         = listPreApp[0].id;
                    String fileContent = '';
                    //a.ContentType = 'text/html';

                    fileContent +='From: '+email.fromAddress+'\n';
                    fileContent +='To: '+email.toAddresses+'\n';
                    
                    if(email.ccAddresses == null){
                        fileContent +='CC: \n';  
                    }else{
                        fileContent +='CC: '+email.ccAddresses+'\n';
                    }
                    fileContent =fileContent.replace(')','').replace('(','');
                    fileContent +='Subject: '+email.subject+'\n\n';
                    
                    /*if(email.plainTextBody != null){
                        //email.plainTextBody =email.plainTextBody.replace('</div>','\n\n');
                        email.plainTextBody =email.plainTextBody.replace('<br>','\n\n');
                        fileContent += EncodingUtil.urlDecode(email.plainTextBody,'UTF-8');
                    }*/
					
                    string bodyText;
                    if (string.isEmpty(email.htmlBody)){
                        bodyText = email.plainTextBody;
                    }else{
                        bodyText = HtmlToText(email.htmlBody);
                    }
                    
                    /*if(email.htmlBody != null){
                        fileContent += EncodingUtil.urlDecode(email.htmlBody,'UTF-8');
                    }*/
                    fileContent += EncodingUtil.urlDecode(bodyText,'UTF-8');
                    a.Body = Blob.valueOf(fileContent);  
                    a.Name = email.subject.replace(' ','_').replace('[','').replace(']','').replace(',','_').replace(':','').replace('@','at').replace('Sandbox_','')+'.txt'; 
                    
                    if(email.fromName != null){
                        a.Description='Sent by ' +email.fromName;
                    }else{                  
                        a.Description='test';
                        
                    }  
                    
                    insert a;                
                    result.success=true;
                }        
                catch(Exception e){
                system.debug('Error Message attachment'+e.getmessage());
                    result.success=false; 
                }             
            }
            
        }
        return result; 
    }
    
    public static string HtmlToText(string html){
        //replace all <BR> tags with \n to support new lines
        string result = html.replaceAll('<br/>', '\n');
        result = result.replaceAll('<br />', '\n');
        result = result.replaceAll('&nbsp;', ' ');
        result = result.replaceAll('</div>', '\n');
		
        //all HTML/XML tags
        string HtmlPattern = '<.*?>';
        
        Matcher match =  Pattern.compile(HtmlPattern).matcher(result);
        
        //remove the tags and return string     
        return match.replaceAll('');
    }
}