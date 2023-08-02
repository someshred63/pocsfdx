/** Class Name  : EmailConversationCntl
*  Description  : This is Email Conversation Controller
*
*  Modification Log:  
*  ————————————————————————————————————————————–
*   Developer                Date                   Modification ID      Description 
*  —————————————————————————————————————————————
**/
global without sharing class gFRS_Ltng_EmailConversationCntl{
    
/**
* @description : To get all Email messages related to Record ID 
* @param : RecID
* @return : List<EmailMessage>
**/
    
    @AuraEnabled
    global static List<EmailMessage> getEmailMessages(String RecId){
        
        system.debug('>>>>>>>>>>Id>>>'+ RecId);
        String ObjectName='';
        List<String> myFilter = new List<String>();    
        if(RecId.startsWith('00Q')){
            ObjectName='gFRS_Ltng_Customer_Intraction__c';
            myFilter.add('gFRS_Customer_Interaction__c  =\''+ RecId+'\'');
        } else {
            ObjectName='gFRS_Ltng_Customer_Intraction__c';
            myFilter.add('gFRS_Customer_Interaction__c  =\''+ RecId+'\'');
        }   
        
        System.debug('@@@@@Obejct NAme@@'+ObjectName);
        System.debug('@@@@@REcord Id@@'+RecId);
        
        String  queryString='SELECT Id, Subject,Status,TextBody,Incoming,HtmlBody,Headers,FromName,gFRS_Customer_Interaction__c,FromAddress,ToAddress FROM EmailMessage';
        
        if(myFilter.size()>0){
            queryString += ' WHERE ' + myFilter[0] + 'ORDER BY CreatedDate DESC'; 
        }
        else {
            string ss = 'No Emails';
        }
        system.debug('Structured Query>>>'+queryString);
        List<EmailMessage> allEmailMessages= database.query(queryString);
        system.debug('>>>>>>>>>>All Records>>>'+allEmailMessages);
  
        return allEmailMessages;
    }
    
    @AuraEnabled
    global static string getpassemaildetails(String RecordId){
        system.debug('>>>>>>>>>>Id>>>'+ RecordId);
        string idm = RecordId;
        string email='';
        system.debug('>>>>>>>>>>RecordId>>> '+ idm);
  
            system.debug('>>>>>>>>>>RecordId if >>> '+ idm);
            List<gFRS_Ltng_Customer_Intraction__c> passvalues = [select id,Name,Email_Address__c from gFRS_Ltng_Customer_Intraction__c WHERE id =: idm limit 1];
            for(gFRS_Ltng_Customer_Intraction__c l:passvalues ){
                if(l.Email_Address__c == null){
                	email= 'accdemo245@gmail.com' ;
                } else {
                    email= l.Email_Address__c ;
                }
            }
        
        return email;
    }
    
    @AuraEnabled
    global static EmailMessage getemailAddress(String EMsgId){
        system.debug('>>>>>>>>>>Id>>>'+ EMsgId);
        string emid = EMsgId;
        system.debug('>>>>>>>>>>RecordId>>>'+ emid);
        List<EmailMessage> passemid = [select id,FromAddress,TextBody,ToAddress,Subject,HtmlBody,Incoming,gFRS_Customer_Interaction__c from EmailMessage WHERE id =: emid limit 1];
        string email='';
                
        return passemid[0];
    }
    
}