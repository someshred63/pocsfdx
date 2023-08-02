public class gFRS_Ltng_Change_Owner_Controller {
    @AuraEnabled
    public static List<gFRS_Ltng_Application__c> main(id orgid){
        return [SELECT ID,Name,Record_Type__c,Status__c,Sub_Status__c,Event_Program_Title__c,OwnerId,Owner_Full_Name__c from gFRS_Ltng_Application__c where Organization__c=:orgid AND Status__c!= 'Closed' AND Status__c!= 'Closed' and Status__c!='Intake' ORDER BY Name LIMIT 1000];
    }
    @AuraEnabled
    public static void main2(List<gFRS_Ltng_Application__c> recordid,id Ownerid,String reason){
        
        System.debug('-->recorid '+recordid);
        System.debug('-->Ownerid '+Ownerid);
        List<gFRS_Ltng_Application__c> lst=new List<gFRS_Ltng_Application__c>();
        List<Note> lstnote=new List<Note>();
        for(gFRS_Ltng_Application__c mf:[SELECT ID,OwnerId,Organization__c FROM gFRS_Ltng_Application__c where id =:recordid]){
            mf.OwnerId=Ownerid;
            lst.add(mf);
        }
        if(lst.size()>0){
            update lst;
            emailNotification(recordid);
            for(gFRS_Ltng_Application__c mr:[SELECT ID,Organization__c from gFRS_Ltng_Application__c where id =:recordid limit 1]){
                Note nt=new Note();
                nt.ParentId=mr.Organization__c;
                nt.body=reason;
                nt.Title=reason;
                lstnote.add(nt);
            }
            if(lstnote.size()==1){
                insert lstnote;
            }
        }
    }
    
    @AuraEnabled
    public static void emailNotification(List<gFRS_Ltng_Application__c> recordid){
    //public static void emailNotification(String recordid){
        User usrRec = [SELECT Id, Username, LastName, FirstName, Name,Alias, Email, CompanyName FROM User Where Id=:UserInfo.getUserId()];
        String userInfo='';
        userInfo = userInfo + usrRec.Name + '<br/>' + usrRec.Email +'<br/>';
        system.debug('userInfo' +userInfo);
        
        for(gFRS_Ltng_Application__c appRec:[SELECT ID,Event_Program_Title__c,Name,OwnerId,Owner.FirstName,Owner.LastName,Organization__c,owner.email,RecordType.Name FROM gFRS_Ltng_Application__c where id =:recordid]){
		//gFRS_Ltng_Application__c appRec = [SELECT ID,OwnerId,Organization__c,owner.email,RecordType.Name FROM gFRS_Ltng_Application__c where id =:recordid];
			String refferId = '[ref:'+recordid+']';
            Messaging.SingleEmailMessage message = new  Messaging.SingleEmailMessage();
            List<String> tobCCddresses = new List<String>();
	        GFRS_Ltng_OrgSettings__c myOrgCS = GFRS_Ltng_OrgSettings__c.getOrgDefaults();
        	if(myOrgCS.gFRS_CAF_Inbound_Email__c != null){
            	String bccEmailAddress=myOrgCS.gFRS_CAF_Inbound_Email__c;
            	tobCCddresses.add(bccEmailAddress);
        	}
        	message.setBccAddresses(tobCCddresses);
            OrgWideEmailAddress owea = [select Id from OrgWideEmailAddress where Address='fundingrequestsystem-donotreply-d@gene.com' LIMIT 1];
        	message.setOrgWideEmailAddressId(owea.Id);
            
            String emailName = '';
            if(appRec.RecordType.Name == 'Foundation Safety Net Support' || appRec.RecordType.Name == 'Foundation Undergraduate'){
                emailName = 'FOUNDATION_Change_Owner_Email';
            }else{
                emailName = 'External_Change_Owner_Email';
            }
            EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName =: emailName];
            message.setTemplateID(emailTemplate.Id);
            
            string Subject = emailTemplate.Subject.replace('{!gFRS_Ltng_Application__c.Name}', appRec.Name);
            message.setSubject(Subject);
            String htmlBody=emailTemplate.HtmlValue;
            
            htmlBody = htmlBody.replace('{!gFRS_Ltng_Application__c.Name}', appRec.Name);
            
            if(appRec.Event_Program_Title__c != null && appRec.Event_Program_Title__c != '') {
                htmlBody = htmlBody.replace('{!gFRS_Ltng_Application__c.Event_Program_Title__c}', appRec.Event_Program_Title__c);
            } else {
                htmlBody = htmlBody.replace('{!gFRS_Ltng_Application__c.Event_Program_Title__c}', '');
            }
            
            if(appRec.Owner.FirstName != null && appRec.Owner.FirstName != '') {
                htmlBody = htmlBody.replace('{!gFRS_Ltng_Application__c.OwnerFirstName}', appRec.Owner.FirstName);
            }
            else {
                htmlBody = htmlBody.replace('{!gFRS_Ltng_Application__c.OwnerFirstName}','');
            }
            
            if(appRec.Owner.LastName != null && appRec.Owner.LastName != '') {
                htmlBody = htmlBody.replace('{!gFRS_Ltng_Application__c.OwnerLastName}', appRec.Owner.LastName);
            }
            else {
                htmlBody = htmlBody.replace('{!gFRS_Ltng_Application__c.OwnerLastName}','');
            }
            
            if(string.isNotBlank(userInfo)){
                htmlBody = htmlBody.replace('{!gFRS_Ltng_Application__c.loggedUser}', userInfo);
            }else{
                htmlBody = htmlBody.replace('{Approver Full Name}', '');
            }
            htmlBody = htmlBody.replace(']]>', '');
            
            message.toAddresses = new String[] { appRec.owner.email};
                message.setHtmlBody(htmlBody);
            //message.setTargetObjectId(appRec.ID); 
            //   message.setReferences(refferId);
            message.setTreatBodiesAsTemplate(true);
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            
            if (results[0].success) 
            {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send:' +  results[0].errors[0].message);
            }
        }
    }
    
	/*public static void sendEmail(List<gFRS_Ltng_Application__c> recordid){
        gFRS_Ltng_Application__c appRec=[SELECT Id,name,owner.email FROM gFRS_Ltng_Application__c WHERE Id=:reqid.get(0)];
         
    //    message.setTargetObjectId(reqid); 
    message.setWhatId(reqid.get(0));
        
       
      //   String ss='[ref:aLQ3C0000008OwA]';
    //     body = body.replace('<refid>',ss);
        message.toAddresses = new String[] { caf.owner.email};
        message.setPlainTextBody(body);
     //   message.setReferences(refferId);
        message.setTreatBodiesAsTemplate(true);
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
        if (results[0].success) 
        {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send:' +  results[0].errors[0].message);
        }
    }*/
}