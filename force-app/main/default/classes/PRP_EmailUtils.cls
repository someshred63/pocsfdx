/**
* @File Name:   PRP_EmailUtils
* @Description: Controller for EmailUtil Class
* @group:       Apex Class
* @Modification Log :
______________________________________________________________________________________
* Ver       Date        Author        Modification
* 1.0       2020-04-21  Rabindranath
*/
global class PRP_EmailUtils {
    
    public static String emailBody = '';
    
    public static String subject = '';
    
    global static void sendEmail(String recId,String[] recipients, String emailFlag,String[] ccAddress) { 
        String htmlBody = '';
        system.debug('Record Id' + recId);
        system.debug('Receipients ' + recipients);
        system.debug('Email Flag' + emailFlag);
        system.debug('recipientssize' + recipients.size());
        if(recipients == null) {return;}
        if(recipients.size() == 0) {return;}
        PRP_Request__c prp= new PRP_Request__c();
        User usr = new User();
        List<PRP_Site_Request__c> sites= new List<PRP_Site_Request__c>();
        sites =[select id,Site_Name__c,Address1__c,City__c,State__c,Zip__c from PRP_Site_Request__c where Request__c=:recId ];
        prp =[select id,Approver_Name__c,ownerId,Owner.Name,Prior_Owner_Value__c,Name,BEM__c,BEM__r.Name,Legal_Name__c,Address1__c,Product_Name__c,Contract_ID__c,Effective_Date__c,Request_Type__c from PRP_Request__c where id=: recId limit 1];
        system.debug('PRIOR OWNER VALUE' + prp.Prior_Owner_Value__c);
        if(prp.Prior_Owner_Value__c!=null){
        usr =[Select id,Name,Email from User where id=:prp.Prior_Owner_Value__c];
            system.debug('USERNAME' + usr.Name);
        }
        String link = '<a href="' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + recId + '" target="_blank">'+prp.Name+' </a>';
        List<OrgWideEmailAddress> fe = new List<OrgWideEmailAddress>();
        fe = [Select Id, Address, DisplayName From OrgWideEmailAddress where DisplayName = 'Genentech Provider Rebate Request' LIMIT 1];
        
        if(sites.size() == 0){
         htmlBody +='<div span style="font-family:Calibri; font-size: 12pt;"> Sites Added - N/A </div>';   
        }else{
        htmlBody +='<div span style="font-family:Calibri; font-size: 12pt;"> Sites Added </div>';
        htmlBody +='<table border="1px solid black" style="border-collapse: collapse" ><tr><th>Site Name</th><th>Site Address</th><th>Site City</th><th>State</th><th>Site Zip</th></tr>';
        for(PRP_Site_Request__c site:sites){
            string temp=    '<tr>'+
                '<td span style="font-family:Calibri; font-size: 12pt;">' + site.Site_Name__c + '</td>' +
                '<td span style="font-family:Calibri; font-size: 12pt;">'+ site.Address1__c +'</td>' +
                '<td span style="font-family:Calibri; font-size: 12pt;">'+site.City__c+'</td>' +
                '<td span style="font-family:Calibri; font-size: 12pt;">'+site.State__c+'</td>'+
                '<td span style="font-family:Calibri; font-size: 12pt;">'+site.Zip__c+'</td>'+'</tr>';
            htmlBody = htmlBody+temp;
        }
        htmlBody +='</table>';
        }
        emailBody += '<span style="font-family:Calibri; font-size: 12pt;">';
        emailBody+= '<html><body style="font-family: sans-serif;font-size:5pt;>';
        if(emailFlag == 'pending approval' ){
            emailBody +=('<div span style="font-family:Calibri; font-size: 12pt;"> Dear '+prp.Approver_Name__c+',  </div>'+
                         '<br><div span style="font-family:Calibri; font-size: 12pt;"> The following PRPM request has been assigned to you for approval, please reach out to the undersigned for any questions - '+link+'. </div></br>'+
                         '<br><div span style="font-family:Calibri; font-size: 12pt;"> Thank You,</div></br>'+
                         '<div span style="font-family:Calibri; font-size: 12pt;"> '+usr.Name+'  </div>');
        }else if(emailFlag == 'approved'){
            emailBody += ('<div span style="font-family:Calibri; font-size: 12pt;"> Dear '+prp.Owner.Name+',  </div>'+
                          '<br><div span style="font-family:Calibri; font-size: 12pt;"> The following PRPM request has been approved and assigned back to you, please proceed - '+link+'. </div></br>'+
                          '<br><div span style="font-family:Calibri; font-size: 12pt;"> Thank You,</div></br>'+
                          '<div span style="font-family:Calibri; font-size: 12pt;"> '+prp.Approver_Name__c+'  </div>'+
                          '</body></html>');
        }else{
            emailBody += ('<div span style="font-family:Calibri; font-size: 12pt;"> Hello '+prp.BEM__r.Name+',  </div>'+
                          '<br><div span style="font-family:Calibri; font-size: 12pt;"> The request has been successfully  closed, below are the details </div></br>'+
                          '<br><div span style="font-family:Calibri; font-size: 12pt;"> Legal Name - '+ prp.Legal_Name__c+' </div></br>'+
                          '<div span style="font-family:Calibri; font-size: 12pt;"> Address        - '+ prp.Address1__c+'  </div>'+
                          '<div span style="font-family:Calibri; font-size: 12pt;"> Product Name   - '+ prp.Product_Name__c+'  </div>'+
                          '<div span style="font-family:Calibri; font-size: 12pt;"> Contract Id    - '+ prp.Contract_ID__c+'  </div>'+
                          '<div span style="font-family:Calibri; font-size: 12pt;"> Effective Date - '+ prp.Effective_Date__c+'  </div>'+
                          '<div span style="font-family:Calibri; font-size: 12pt;"> Request Type   - '+ prp.Request_Type__c+'  </div>'+
                          '<div span style="font-family:Calibri; font-size: 12pt;"> Record Id      - '+ link+'  </div>'+
                          '<br><div span style="font-family:Calibri; font-size: 12pt;"> '+ htmlBody +' </div></br>'+
                          '<br><div span style="font-family:Calibri; font-size: 12pt;"> Thank You,</div></br>'+
                          '<div span style="font-family:Calibri; font-size: 12pt;"> Genentech Contract Operations</div>'+
                          '<div span style="font-family:Calibri; font-size: 12pt;"><a href="mailto:Genentech_Provider_Rebate@gene.com">Genentech_Provider_Rebate@gene.com</a> | +1 (650) 553 - 8330');
        }
        emailBody+='</body></html>';
        if(emailFlag == 'pending approval' ){
            subject += +prp.Name+ + ' ' + ' Assigned for approval';
        }else if(emailFlag == 'approved'){
            subject += +prp.Name+ + ' ' + ' Approved';
        }else{
            subject +=  'Update : The request for '+ '  ' + +prp.Legal_Name__c+ + '  ' + ' has been processed';
        }
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        mail.setSubject(subject);
        mail.setHtmlBody(emailBody) ;
        mail.setSaveAsActivity(false);
        mail.setToAddresses(recipients);
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setCcAddresses(ccAddress);
        mail.setOrgWideEmailAddressId(fe.get(0).id);
        try{
            
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            
        }
        catch (Exception exp)
        {  
            AuraHandledException auraEx = new AuraHandledException(exp.getMessage());
            auraEx.setMessage(exp.getMessage());
            throw auraEx;
        }
        
    }
    global static void createEmails(String recId,String recipients) { 
    
         PRP_Request__c prp= new PRP_Request__c();
        prp = [select id,ownerId,Owner.Name from PRP_Request__c where id=: recId limit 1];
        PRP_Email_Tracker__c PRPEmail = new PRP_Email_Tracker__c();
        PRPEmail.Body__c = emailBody;
        PRPEmail.Provider_Rebate_Program_Request__c = recId;
        PRPEmail.Sent__c = 'Provider Rebate Program Site Guest User';
        PRPEmail.Sent_On__c = DateTime.now();
        PRPEmail.Subject__c = subject;
        PRPEmail.To_Address__c = recipients;
        PRPEmail.CC_Address__c = prp.Owner.Name;
        insert PRPEmail;
    } 
}