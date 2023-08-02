public class gFRS_CAFCommunicationCtrl {
    public static final String EMAIL_TEMPLATES_FOLDER = 'gFRS_RFI_Templates';// Email templates folder, where available for use templates are stored
    
    @AuraEnabled
    public static  Map<String, String> getEmailTemplates(String RecId){
        Map<String, String> options = new Map<String, String>();
        list<string> emailtemp = new List<String>();
        gFRS_Ltng_CAF_Application__c objApprec =[select id,name,Status__c,Internal_Sub_Status__c from gFRS_Ltng_CAF_Application__c where id=:RecId];
        //integer  count= [select count() from  gFRS_Ltng_Program__c WHERE gFRS_Application__c =:RecId];
        //List<gFRS_Ltng_Program__c> progs=[SELECT Id, Name,Program_Status__c,gFRS_Secondary_program_title__c,gFRS_Start_Date__c,gFRS_End_Date__c FROM gFRS_Ltng_Program__c WHERE gFRS_Application__c =:RecId and Program_Status__c!='Canceled' and Program_Status__c!='Denial'];
        //List<gFRS_Ltng_Task__c> programTaskList=[select id,name,Action_Type__c,Status__c from gFRS_Ltng_Task__c where gFRS_Application__c=:RecId and Action_Type__c='Program Status' and Status__c='Completed'];
        //List<gFRS_Ltng_Task__c> programTaskList1=[select id,name,Action_Type__c,Status__c from gFRS_Ltng_Task__c where gFRS_Application__c=:RecId and Action_Type__c='Refund'];
        //boolean program=false;
        EmailTemplate[] ets = [
            SELECT Subject, Name, Id, Description, Body,DeveloperName
            FROM EmailTemplate
            WHERE Folder.DeveloperName = :EMAIL_TEMPLATES_FOLDER
            ORDER BY Name ASC
        ];
        /*if(count>1 && progs.size()>0){
            for (gFRS_Ltng_Program__c p1:progs){
                if(p1.Program_Status__c!='Canceled'){
                    program=true;
                }else If(p1.Program_Status__c!='Denail'){
                    program=true; 
                }
            }
        }*/
        system.debug('emailTemplates' +ets);
        for (EmailTemplate et1 : ets) {        
            if(et1.DeveloperName == 'External_General_Communication_CoPay') {
                options.put(et1.Id,'General Communication');
            }
            if(et1.DeveloperName == 'Intent_to_Donate_CoPay'){
                options.put(et1.Id,'Intent to Donate');
            }
            if(objApprec.Status__c != 'Closed'){
                if(et1.DeveloperName == 'RFI_Information_Request_External_Communication_CoPay'){
                    options.put(et1.Id, 'RFI Information Request');
                } 
            }
        }            
        
        return options;
    }
    
    @AuraEnabled
    public static reqTaskWrapperData fetchCAFApplicationReq(Id RecId){
        list<gFRS_CAF_Task__c > taskList = new list<gFRS_CAF_Task__c >();
        taskList = [SELECT Id, Name, Status__c, Action_Type__c FROM gFRS_CAF_Task__c WHERE Status__c != 'Completed' AND Action_Type__c = 'RFI' AND gFRS_CAF_Application__c =: RecId];
        Integer taskRecCount = taskList.size();
        
        gFRS_Ltng_CAF_Application__c applRec = [select id,name,Information_Needed__c from gFRS_Ltng_CAF_Application__c where id=:RecId];
        reqTaskWrapperData reqTaskWrap = new reqTaskWrapperData();
        reqTaskWrap.appRec 		= applRec;
        reqTaskWrap.taskCount 	= taskRecCount;
        return reqTaskWrap;
        //return [select id,name,RecordType.Name from gFRS_Ltng_Application__c where id=:RecId];
    }
    
    @AuraEnabled
    public static wrapperEmailData getEmailContent(String EmailName, String RecId){
        
        wrapperEmailData returnwrapperClass = new  wrapperEmailData ();
        gFRS_Ltng_Application__c objApprec =[select id,name,Focus_Area__c,Event_Program_Title__c,RecordType.Name,Owner.FirstName,Owner.LastName, Owner.email,Person_To_Whom_Payment_should_addressed__c,First_Name__c,Last_Name__c,Program_Start_Date_Min__c,Program_End_Date_max__c,Requested_Amount__c,FPO_compliance_owner__c,Organization__r.Organization_Name__c,Approved_Amount__c,Attention_To__c,Email_Address__c from gFRS_Ltng_Application__c where id=:RecId];
        EmailTemplate  emailCon=[SELECT Subject, Name, Id, Description, Body,DeveloperName,HtmlValue
                                 FROM EmailTemplate
                                 WHERE Id=: EmailName];
        
        if(emailCon.DeveloperName =='Evaluation_Reminder_Communication'){
            if(objApprec.RecordType.Name=='Foundation Undergraduate' || objApprec.RecordType.Name=='Foundation Safety Net Support'){
                Program_Evualation_Question__mdt evaulationMdt = [select id,DeveloperName,Evaluation_Questions__c from Program_Evualation_Question__mdt where Funding_Types__c=:objApprec.RecordType.Name];
                returnwrapperClass.gFRSEvaluationMtd=evaulationMdt;
            }else{
                Program_Evualation_Question__mdt evaulationMdt = [select id,DeveloperName,Evaluation_Questions__c from Program_Evualation_Question__mdt where Label=:objApprec.Focus_Area__c and Funding_Types__c=:objApprec.RecordType.Name];
                returnwrapperClass.gFRSEvaluationMtd=evaulationMdt;
            }
        }else{
            gFRS_RFI_App__mdt mdt=[select Organization__c ,Demographic__c,Budget__c,Budget_Foundation__c,Request_Details__c,Program__c,Program_Foundation__c,Third_Party__c from gFRS_RFI_App__mdt];
            returnwrapperClass.gFRSRFIMdt=mdt;
            List<gFRS_Ltng_Third_Party__c> listThirdpartyRec =[select id,name from gFRS_Ltng_Third_Party__c where gFRS_Application__c=:RecId];
            if(listThirdpartyRec.size() > 0){
                returnwrapperClass.thirdBool = true;
            }else{
                returnwrapperClass.thirdBool = false;
            }
        }
        String prgdate;
        if(objApprec.Program_Start_Date_Min__c != null) {
            Date dt=objApprec.Program_Start_Date_Min__c;
            prgdate=dt.format();
        }
       // string programDate = string.valueOf(objApprec.Program_Start_Date_Min__c);
        string programEndDate = string.valueOf(objApprec.Program_End_Date_max__c);
        string requestedmount = string.valueOf(objApprec.Requested_Amount__c);        
        string approvedAmount = string.valueOf(objApprec.Approved_Amount__c);        
        String emailSub = emailCon.Subject;
        String body;
        
        if(emailCon.DeveloperName=='General_Communication2_0_HTML' ||
		   emailCon.DeveloperName =='LOA_Remainder_DocuSign_Attachment'||
           emailCon.DeveloperName =='gFRS_2_0_Payment_Method_Task_Reminder_Email'||
           emailCon.DeveloperName =='gFRS_RFI_2_0_HTML'){
               body = emailCon.HtmlValue;
              // body = emailCon.Body; 
               //  body=body.replace('<table border="0" cellpadding="5" width="550" cellspacing="5" height="400" >','');
               //  body=body.replace('</table>','');
               body=body.replace(']]>','');
           }else{
               body = emailCon.Body;    
           }
        
        String title = objApprec.Event_Program_Title__c;
        
        emailSub = emailSub.replace('{!gFRS_Ltng_Application__c.Name}', objApprec.Name);         
        body = body.replace('{!gFRS_Ltng_Application__c.Name}', objApprec.Name);  
        body = body.replace('{!gFRS_Ltng_Application__c.OwnerFirstName}', objApprec.Owner.FirstName); 
        
        if(String.isNotBlank(objApprec.Event_Program_Title__c)){
            body = body.replace('{!gFRS_Ltng_Application__c.Event_Program_Title__c}', objApprec.Event_Program_Title__c); 
        }
        else{
            body = body.replace('{!gFRS_Ltng_Application__c.Event_Program_Title__c}', '');
        }
        if(String.isNotBlank(objApprec.RecordType.Name)){
            body = body.replace('{!gFRS_Ltng_Application__c.RecordType}', objApprec.RecordType.Name); 
        }else{
            body = body.replace('{!gFRS_Ltng_Application__c.RecordType}', '');
        }
        if(String.isNotBlank(prgdate)){
            body = body.replace('{!gFRS_Ltng_Application__c.Program_Start_Date_Min__c}',prgdate); 
        }else{
            body = body.replace('{!gFRS_Ltng_Application__c.Program_Start_Date_Min__c}','');
        }
        if(String.isNotBlank(requestedmount)){
            body = body.replace('{!gFRS_Ltng_Application__c.Requested_Amount__c}', '$'+requestedmount); 
        }else{
            body = body.replace('{!gFRS_Ltng_Application__c.Requested_Amount__c}', '');
        }
        string userId=objApprec.FPO_compliance_owner__c;
        if(userId != null && userId != '') {           
            User usrRec = [SELECT Id, Username, LastName, FirstName, Name,Email, CompanyName FROM User Where Id=:userId];
            body = body.replace('{Compliance Approver Name}',usrRec.Name);
            body = body.replace('{Compliance Approver email}',usrRec.Email);
        }else{
            body = body.replace('{Compliance Approver Name}','');
            body = body.replace('{Compliance Approver email}','');
        }
        //body = body.replace('{!gFRS_Ltng_Application__c.First_Name__c} {!gFRS_Ltng_Application__c.Last_Name__c}',objApprec.Owner.FirstName+' '+objApprec.Owner.LastName);
         
        if(String.isNotBlank(objApprec.First_Name__c)){
        	body = body.replace('{Authorized_Signer__FirstName}',objApprec.First_Name__c);
        }else{
            body = body.replace('{Authorized_Signer__FirstName}','');
        }
        
        if(String.isNotBlank(objApprec.Last_Name__c)){
        	body = body.replace('{Authorized_Signer__LastName}',objApprec.Last_Name__c);
        }else{
            body = body.replace('{Authorized_Signer__LastName}','');
        }
        
        if(String.isNotBlank(objApprec.Owner.FirstName)){
            body = body.replace('{!gFRS_Ltng_Application__c.First_Name__c}',objApprec.Owner.FirstName);
            body = body.replace('<<First Name Last Name>>',objApprec.Owner.FirstName+''+objApprec.Owner.LastName);
        }else{
            body = body.replace('<<First Name Last Name>>','');
            body = body.replace('{!gFRS_Ltng_Application__c.First_Name__c}','');
        }
        
        if(String.isNotBlank(objApprec.Owner.LastName)){
            body = body.replace('{!gFRS_Ltng_Application__c.Last_Name__c}',objApprec.Owner.LastName);
        }else{
            body = body.replace('{!gFRS_Ltng_Application__c.Last_Name__c}','');
        }
        
        if(String.isNotBlank(objApprec.Person_To_Whom_Payment_should_addressed__c)){
            body = body.replace('<<Attn To>>',objApprec.Person_To_Whom_Payment_should_addressed__c);
            body = body.replace('{!gFRS_Ltng_Application__c.Person_To_Whom_Payment_should_addressed__c}',objApprec.Person_To_Whom_Payment_should_addressed__c);
        }else{
            body = body.replace('<<Attn To>>','');
            body = body.replace('{!gFRS_Ltng_Application__c.Person_To_Whom_Payment_should_addressed__c}','');
        }
        
        if(String.isNotBlank(approvedAmount)){
            body = body.replace('{!gFRS_Ltng_Application__c.Approved_Amount__c}', '$'+approvedAmount);
        }else{
            body = body.replace('{!gFRS_Ltng_Application__c.Approved_Amount__c}','');
        }
        body = body.replace('{!gFRS_Ltng_Application__c.Organization__r.Organization_Name__c}',objApprec.Organization__r.Organization_Name__c);
        if(String.isNotBlank(objApprec.First_Name__c)){
            body = body.replace('<<Auth First Name>>',objApprec.First_Name__c);
        }else{
             body = body.replace('<<Auth First Name>>','');
        }
        if(String.isNotBlank(objApprec.Last_Name__c)){
            body = body.replace('<<Auth Last Name>>',objApprec.Last_Name__c);
        }else{
            body = body.replace('<<Auth Last Name>>','');
        }
        
        if(String.isNotBlank(objApprec.Attention_To__c)){
            body = body.replace('{Payment Attention To FullName}',objApprec.Attention_To__c);
        }else{
            body = body.replace('{Payment Attention To FullName}','');
        }
        body = body.replace('{link to RFI/Request}',System.Label.gFRS_Ltng_Community_URL);
        body = body.replace('<<Community Link>>',System.Label.gFRS_Ltng_Community_URL);
        
        String senderName = Userinfo.getFirstName() + ' ' + Userinfo.getLastName();
        body = body.replace('<<Sender First Name Last Name>>', senderName); 
        body += '\n\n' + '[ref:' + RecId + ']';       
        returnwrapperClass.emailBody = body;
        returnwrapperClass.subject = emailSub;        
        if(emailCon.DeveloperName =='gFRS_2_0_Payment_Method_Task_Reminder_Email' || emailCon.DeveloperName =='gFRS_2_0_Internal_Refunds_notification' ){
            returnwrapperClass.ownerEmail = objApprec.Person_To_Whom_Payment_should_addressed__c;
        }else if(emailCon.DeveloperName =='LOA_Remainder_DocuSign_Attachment') {
        	returnwrapperClass.ownerEmail = objApprec.Email_Address__c;    
        }else {
            returnwrapperClass.ownerEmail = objApprec.Owner.email;
        }
        
        returnwrapperClass.ownerName = objApprec.Owner.FirstName+''+objApprec.Owner.LastName;
        returnwrapperClass.templateName = emailCon.Name;
        
        return returnwrapperClass;
    }
    @AuraEnabled
    public static wrapperEmailData getEmailContent1(String EmailName, String RecId){
        
        wrapperEmailData returnwrapperClass = new  wrapperEmailData ();
        /*List<gFRS_Ltng_Program__c> progs=[SELECT Id, Name,gFRS_Secondary_program_title__c,gFRS_Start_Date__c,gFRS_End_Date__c FROM gFRS_Ltng_Program__c WHERE gFRS_Application__c =:RecId and Program_Status__c!='Canceled' and Program_Status__c!='Denial'];
        returnwrapperClass.progsprogramRecords=progs;*/
        gFRS_Ltng_CAF_Application__c objApprec =[select id,name,Owner.FirstName,Owner.LastName,Owner.Name,Owner.email,LastModifiedBy.Name,gFRS_Organization__r.Organization_Name__c from gFRS_Ltng_CAF_Application__c where id=:RecId];
        List<gFRS_CAF_Disease_State__c> lstdis=[SELECT Id,Name,Payment_Amount__c,Disease_Fund_Name__c,gFRS_CAF_Application__c FROM gFRS_CAF_Disease_State__c WHERE gFRS_CAF_Application__c=:RecId];
        EmailTemplate  emailCon=[SELECT Subject, Name, Id, Description, Body,DeveloperName,HtmlValue
                                 FROM EmailTemplate
                                 WHERE Id=: EmailName];
        system.debug('emailName' +emailCon.Name);
        	gFRS_RFI_App__mdt mdt=[select Organization__c ,Demographic__c,Budget__c,Budget_Foundation__c,Request_Details__c,Program__c,Program_Foundation__c,Third_Party__c from gFRS_RFI_App__mdt];
            returnwrapperClass.gFRSRFIMdt=mdt;
        	User usrRec = [SELECT Id, Username, LastName, FirstName, Name,Alias, Email, CompanyName FROM User Where Id=:UserInfo.getUserId()];
            String emailSub = emailCon.Subject;
            String body;
            body = emailCon.Body;    
            emailSub = emailSub.replace('{!gFRS_Ltng_CAF_Application__c.Name}', objApprec.name);         
            body = body.replace('{!gFRS_Ltng_CAF_Application__c.Name}', objApprec.name);
            body = body.replace('{!gFRS_Ltng_CAF_Application__c.OwnerFullName}',objApprec.Owner.Name);  
        	body = body.replace('{!gFRS_Ltng_CAF_Application__c.OwnerFirstName}',objApprec.Owner.FirstName);
        	body = body.replace('{!gFRS_Ltng_CAF_Application__c.OwnerLastName}',objApprec.Owner.LastName);
        	body = body.replace('{!OrgName}', objApprec.gFRS_Organization__r.Organization_Name__c);
            String DisStateDetails = '';
            if(lstdis.size()>0&&!lstdis.isEmpty()){
                for(gFRS_CAF_Disease_State__c DS:lstdis){
                    Decimal pA = DS.Payment_Amount__c;
                    List<String> args = new String[]{'0','number','##,###,##0'};
                        String pmtAmt = String.format(pA.format(), args);
                    
                    DisStateDetails = DisStateDetails + DS.Disease_Fund_Name__c + ': $' + pmtAmt + '\n';
                }
                body = body.replace('<Disease area: $ amount for each donation line item>',DisStateDetails);
            }
        	body = body.replace('{!gFRS_Ltng_CAF_Application__c.LastModifiedBy}', usrRec.Name);
        	body = body.replace('[Populate the email of the sender]', usrRec.Email);
        	body = body.replace('{!gFRS_Ltng_CAF_Application__c.Id}', objApprec.id);
        	//body += '\n\n' + '[ref:' + RecId + ']';
            returnwrapperClass.emailBody = body;
            returnwrapperClass.subject = emailSub;
            //returnwrapperClass.bcc = 'gfrs_attachemailforcafapplication@g-1uxioakq3sc9cgbyxrmuw97kax7gp9p10pk1r8s4kstw9grezr.3c-8z1juaq.cs60.apex.sandbox.salesforce.com';
            returnwrapperClass.ownerName = objApprec.Owner.FirstName+''+objApprec.Owner.LastName;
            returnwrapperClass.templateName = emailCon.Name; 
        	system.debug('emailCon.Name'+emailCon.Name);
            returnwrapperClass.ownerEmail = objApprec.Owner.email;
            return returnwrapperClass;

    }
    @AuraEnabled
    public static String getEmailBody(String emailBody, List<string> Cheklabels){
        system.debug('checked labels'+Cheklabels);
        
        
        String body = emailBody;
       // system.debug('@@ Body : '+body);
        if(Cheklabels.size() > 0){
            List<gFRS_Organization_questions__mdt> lstQues =[select Label,Value__c,Question__c from gFRS_Organization_questions__mdt where Label =:Cheklabels order by Label DESC];
            system.debug('Questions'+lstQues);        
            Integer count = lstQues.size();
            Integer count2 = 0;
            String questions='';
            for(gFRS_Organization_questions__mdt objorg :lstQues ){
                count2 = count2 + 1;
                if(count2 == count){
                    questions = questions + objorg.Question__c +'\n\n'; 
                } else {
                    questions = questions + objorg.Question__c +'\n\n';  //'\n\n </b>'; 
                }
                
            }
            system.debug('@@ Questions : '+questions);
            body = body.replace('<Insert requested information here>', questions); 
           // system.debug('@@ Body 2 : '+body);
            return body;
        }else{
            return body;
        }
        
    }
    
    @AuraEnabled
    public static Boolean sendEmail(String To,String RecId,String EmailBody,String bcc,String Subject,String cc,String emailtempName,String rFIinfo,List<String> programInfo){
        String refferId = '[ref:'+RecId+']';
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
        System.debug('BCC:'+tobCCddresses+'CC:'+toCCddresses);
        System.debug('-today->'+emailtempName);
        String emailcc=System.Label.gFRS2_0_gFRS_CAF_Email_CC_Email;
        if(emailtempName=='External General Communication CoPay'||emailtempName=='RFI - Information Request External Communication CoPay'){
        toCCddresses.add(emailcc);
        }
        EmailBody = EmailBody.replace('<Insert requested information here>', '');
        EmailBody = EmailBody.replace('<Insert communication here>', '');
        GFRS_Ltng_OrgSettings__c myOrgCS = GFRS_Ltng_OrgSettings__c.getOrgDefaults();
        if(myOrgCS.gFRS_CAF_Inbound_Email__c != null){
            String bccEmailAddress=myOrgCS.gFRS_CAF_Inbound_Email__c;
            tobCCddresses.add(bccEmailAddress.trim());
        }
        OrgWideEmailAddress owea = [select Id from OrgWideEmailAddress where Address='fundingrequestsystem-donotreply-d@gene.com' LIMIT 1];
        email.setOrgWideEmailAddressId(owea.Id);
        email.setToAddresses(toAddresses);
        email.setCcAddresses(toCCddresses);
        email.setBccAddresses(tobCCddresses);        
        email.setSubject(Subject);
        /*if(emailtempName=='LOA_Remainder_DocuSign_Attachment'|| emailtempName=='gFRS 2.0 Payment Method Task Reminder Email'|| emailtempName=='General Communication2.0 HTML'||emailtempName=='gFRS 2.0 Program Cancelation Communication HTML'||emailtempName=='gFRS 2.0 Program Denial Communication HTML'||emailtempName=='gFRS 2.0 Re-open Program Status Task - Email Notification'){
            email.setHtmlBody(EmailBody);
            email.setTreatBodiesAsTemplate(true);
        }else{*/
            email.setPlainTextBody(EmailBody);
        //}
        
        
        try{
            
            gFRS_Ltng_CAF_Application__c objApprec =[select id,name,Status__c,Internal_Sub_Status__c,External_Status__c from gFRS_Ltng_CAF_Application__c where id=:RecId];
            system.debug('emailtempName' +emailtempName);
            /*if(String.isNotBlank(rFIinfo)){
                if(emailtempName=='Evaluation Reminder Communication'){
                    gFRS_Ltng_Application__c updateRFI=new gFRS_Ltng_Application__c();
                    updateRFI.Id=RecId;
                    gFRS_Ltng_Util_NoShare.updateGfrsAPP(updateRFI);
                }else{*/
                gFRS_Ltng_CAF_Application__c updateRFI=new gFRS_Ltng_CAF_Application__c();
                updateRFI.Id=RecId;
                if(emailtempName=='RFI - Information Request External Communication CoPay'){
                    //RFI_Information_Request_External_Communication_CoPay
                    updateRFI.Information_Needed__c=rFIinfo;
                    
                    updateRFI.RFI_Previous_Status__c = objApprec.Status__c;
                    updateRFI.RFI_Previous_Sub_Status__c = objApprec.Internal_Sub_Status__c;
                    updateRFI.RFI_Previous_External_Status__c = objApprec.External_Status__c;
                    updateRFI.Status__c='RFI';
                    updateRFI.Internal_Sub_Status__c='RFI'; 
                    updateRFI.External_Status__c='RFI';
                    updateRFI.RFI_SubmitDate__c=System.today();
                    gFRS_Ltng_Util_NoShare.updateCAFAPP(updateRFI);
                    //update updateRFI;
                    
                    gFRS_CAF_Task__c createTask=new gFRS_CAF_Task__c();
                    createTask.gFRS_CAF_Application__c=RecId;
                    createTask.Status__c='Open';
                    createTask.Action_Type__c = 'RFI';
                    createTask.Description__c = 'Please respond to the RFI for CAF Application: ' + objApprec.Name;
                    createTask.Subject__c='RFI Required';
                    Date todaysDate = System.today();
                    createTask.Start_Date__c=todaysDate; 
                    gFRS_Ltng_Util_NoShare.updateCAFTask(createTask);
                }
            if(emailtempName=='Intent to Donate CoPay'){

                    updateRFI.Status__c='Processing and Disposition';
                    updateRFI.Internal_Sub_Status__c='Process Payment'; 
                    updateRFI.External_Status__c='Intent to Donate';
                    gFRS_Ltng_Util_NoShare.updateCAFAPP(updateRFI);
                    
                }
                    
            
            
            
            
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });  
            if(results[0].success){
                
               isSuccess = TRUE;
            }else{
                isSuccess = FALSE;
            }
        } catch(Exception ex){
            isSuccess = FALSE;
        }
        return isSuccess;
        
    }
    
    @AuraEnabled
    public static void saveEvaluationQuestions(String RecId, String evaluationques){  
        system.debug('objApprec' +RecId);
        gFRS_Ltng_Application__c objApprec =[select id,name,Status__c,Sub_Status__c,Program_Evaluation_Que_info__c from gFRS_Ltng_Application__c where id=:RecId];
        system.debug('objApprec' +objApprec);
        if(String.isNotBlank(evaluationques)){ 
            objApprec.Program_Evaluation_Que_info__c=evaluationques;
        }
        try{
            gFRS_Ltng_Util_NoShare.updateAppRecord(objApprec);
            
        }
        catch(exception e){  
            system.debug('@@@:::Msg:::'+e.getMessage());
            system.debug('@@@LineNum:::'+e.getLineNumber());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            system.debug('auraExceptionObj'+auraExceptionObj);
            throw auraExceptionObj; 
            
        }  
        
    }
    public class reqTaskWrapperData{
        @AuraEnabled public gFRS_Ltng_CAF_Application__c appRec{get;set;}
        @AuraEnabled public Integer taskCount{get;set;}
        
    }    
    
    public class wrapperEmailData{
        @AuraEnabled public String emailBody{get;set;}
        @AuraEnabled public String ownerEmail{get;set;}
        @AuraEnabled public String subject{get;set;}
        @AuraEnabled public String bcc{get;set;}
        @AuraEnabled public String templateName{get;set;}
        @AuraEnabled public String ownerName{get;set;}        
        @AuraEnabled public boolean thirdBool{get;set;}
        @AuraEnabled public gFRS_RFI_App__mdt gFRSRFIMdt{get;set;}
        @AuraEnabled public Program_Evualation_Question__mdt gFRSEvaluationMtd{get;set;}
        @AuraEnabled public List<gFRS_Ltng_Program__c> progsprogramRecords {get;set;}
        
    }
    @InvocableMethod(label='Sent Intent Donate Email')
     public static void sendIntentToDonateEmail(List<Id> reqid){
        gFRS_Ltng_CAF_Application__c caf=[SELECT Id,name,owner.email,gFRS_Organization__r.Organization_Name__c FROM gFRS_Ltng_CAF_Application__c WHERE Id=:reqid.get(0)];
        List<gFRS_CAF_Disease_State__c> lstdis=[SELECT Id,Name,Payment_Amount__c,Disease_Fund_Name__c,gFRS_CAF_Application__c FROM gFRS_CAF_Disease_State__c WHERE gFRS_CAF_Application__c=:reqid.get(0)];
        String refferId = '[ref:'+reqid+']';
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
    //    message.setTargetObjectId(reqid); 
    message.setWhatId(reqid.get(0));
        
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName ='Intent_to_Donate_CoPay'];
        message.setTemplateID(emailTemplate.Id);
          message.setSubject(emailTemplate.Subject);
        String body=emailTemplate.Body;
         body = body.replace('{!OrgName}', caf.gFRS_Organization__r.Organization_Name__c);
       String DisStateDetails = '';
        if(lstdis.size()>0&&!lstdis.isEmpty()){
            for(gFRS_CAF_Disease_State__c DS:lstdis){
          Decimal pA = DS.Payment_Amount__c;
                List<String> args = new String[]{'0','number','##,###,##0'};
                String pmtAmt = String.format(pA.format(), args);

                DisStateDetails = DisStateDetails + DS.Disease_Fund_Name__c + ': $' + pmtAmt + '\n';
            }
             body = body.replace('<Disease area: $ amount for each donation line item>',DisStateDetails);
        }
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
    }
        
}