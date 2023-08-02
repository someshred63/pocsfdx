public class gFRS_ApplicationCommunicationCtrl {
    public static final String EMAIL_TEMPLATES_FOLDER = 'gFRS_RFI_Templates';// Email templates folder, where available for use templates are stored
    
    
    
    @AuraEnabled
    public static  Map<String, String> getEmailTemplates(String RecId){
        Map<String, String> options = new Map<String, String>();
        list<string> emailtemp = new List<String>();
        gFRS_Ltng_Application__c objApprec =[select id,name,RecordType.Name,Status__c,Sub_Status__c,Did_you_receive_benefits__c,Refund_Due_Status_Update__c,SAP_Payment_19_Series_Check__c from gFRS_Ltng_Application__c where id=:RecId];
        integer  count= [select count() from  gFRS_Ltng_Program__c WHERE gFRS_Application__c =:RecId];
        List<gFRS_Ltng_Program__c> progs=[SELECT Id, Name,Program_Status__c,gFRS_Secondary_program_title__c,gFRS_Start_Date__c,gFRS_End_Date__c FROM gFRS_Ltng_Program__c WHERE gFRS_Application__c =:RecId and Program_Status__c!='Canceled' and Program_Status__c!='Denial'];
        List<gFRS_Ltng_Task__c> programTaskList=[select id,name,Action_Type__c,Status__c from gFRS_Ltng_Task__c where gFRS_Application__c=:RecId and Action_Type__c='Program Status' and Status__c='Completed'];
        List<gFRS_Ltng_Task__c> programTaskList1=[select id,name,Action_Type__c,Status__c from gFRS_Ltng_Task__c where gFRS_Application__c=:RecId and Action_Type__c='Refund'];
        boolean program=false;
        EmailTemplate[] ets = [
            SELECT Subject, Name, Id, Description, Body,DeveloperName
            FROM EmailTemplate
            WHERE Folder.DeveloperName = :EMAIL_TEMPLATES_FOLDER
            ORDER BY Name ASC
        ];
        if(count>1 && progs.size()>0){
            for (gFRS_Ltng_Program__c p1:progs){
                if(p1.Program_Status__c!='Canceled'){
                    program=true;
                }else If(p1.Program_Status__c!='Denail'){
                    program=true; 
                }
            }
        }
        system.debug('emailTemplates' +ets);
        for (EmailTemplate et1 : ets) { 
            if (objApprec.RecordType.Name == 'Independent Medical Education (CME)' || 
                objApprec.RecordType.Name == 'Community Giving' || 
                objApprec.RecordType.Name == 'Education Focused Giving Graduate and Post-Graduate' ||
                objApprec.RecordType.Name == 'Education Focused Giving K-12' ||
                objApprec.RecordType.Name == 'Patient and Health Focused Giving' ||
                objApprec.RecordType.Name == 'Scientific and Research Focused Giving') {
                    if (objApprec.RecordType.Name == 'Foundation Safety Net Support' || 
                        objApprec.RecordType.Name == 'Foundation Undergraduate') {
                        }
                    if(et1.DeveloperName == 'General_Communication_Foundation_2_0'){
                        options.put(et1.Id,'General Communication');
                    }
                }
            if (objApprec.RecordType.Name == 'Field Exhibits'||
                objApprec.RecordType.Name == 'Commercial Sponsorship'||
                objApprec.RecordType.Name == 'Non-Commercial Sponsorship'||objApprec.RecordType.Name=='Corporate Memberships') {
                    if(et1.DeveloperName == 'General_Communication_Internal_2_0'){
                        options.put(et1.Id,'General Communication');
                    }
                }
            if(objApprec.Status__c!='Closed'){
                if (objApprec.RecordType.Name == 'Independent Medical Education (CME)' || 
                    objApprec.RecordType.Name == 'Community Giving' || 
                    objApprec.RecordType.Name == 'Education Focused Giving Graduate and Post-Graduate' ||
                    objApprec.RecordType.Name == 'Education Focused Giving K-12' ||
                    objApprec.RecordType.Name == 'Patient and Health Focused Giving' ||
                    objApprec.RecordType.Name == 'Scientific and Research Focused Giving') {
                        if(objApprec.Status__c =='Compliance' || objApprec.Status__c=='Decision'){
                            if(et1.DeveloperName == 'gFRS_RFI_2_0') {
                                //if(et1.DeveloperName == 'gFRS_RFI_2_0_HTML') {
                                options.put(et1.Id,'RFI - Information Request External');
                            }
                        }
                        
                        if(objApprec.RecordType.Name == 'Independent Medical Education (CME)' &&
                           objApprec.Sub_Status__c == 'Approved-Status Updates/Outcomes' &&
                           objApprec.SAP_Payment_19_Series_Check__c != null &&
                           et1.DeveloperName == 'gFRS_2_0_Canceled_Post_Funding_Communication'){
                               options.put(et1.Id,'Canceled Post Funding at Fundee\'s Request / Change of Scope Denied');
                           }
                        
                        if(objApprec.Status__c =='Processing & Disposition'&&objApprec.Sub_Status__c=='Approved-Awaiting LOA'&&et1.DeveloperName=='gFRS_2_0_Canceled_Conflict_with_LOA_Terms_External'){
                            options.put(et1.Id,'Canceled - Conflict with LOA Terms');
                        }
                    }
                if (objApprec.RecordType.Name == 'Foundation Safety Net Support' || 
                    objApprec.RecordType.Name == 'Foundation Undergraduate') {
                        if(objApprec.Status__c =='Compliance' || objApprec.Status__c=='Decision'){
                            if(et1.DeveloperName == 'gFRS_RFI_2_0_Foundation') {
                                options.put(et1.Id,'RFI - Information Request External');
                                
                            }
                        }
                        
                        if(objApprec.Status__c =='Processing & Disposition'&&objApprec.Sub_Status__c=='Approved-Awaiting LOA'&&et1.DeveloperName=='gFRS_2_0_Canceled_Conflict_with_LOA_Terms_Foundation'){
                            options.put(et1.Id,'Canceled - Conflict with LOA Terms');
                        }
                    }
                if (objApprec.RecordType.Name == 'Community Giving' || 
                    objApprec.RecordType.Name == 'Education Focused Giving Graduate and Post-Graduate' ||
                    objApprec.RecordType.Name == 'Education Focused Giving K-12' ||
                    objApprec.RecordType.Name == 'Foundation Safety Net Support' || 
                    objApprec.RecordType.Name == 'Foundation Undergraduate' ||
                    objApprec.RecordType.Name == 'Patient and Health Focused Giving' ||
                    objApprec.RecordType.Name == 'Scientific and Research Focused Giving') {
                        if(et1.DeveloperName == 'Evaluation_Reminder_Communication' && objApprec.Sub_Status__c =='Approved-Program Evaluations'){
                            options.put(et1.Id, 'Program Evaluation');
                        }
                        if(objApprec.Status__c =='Processing & Disposition' && objApprec.Sub_Status__c=='Approved-Program Evaluations' &&
                           objApprec.SAP_Payment_19_Series_Check__c != null && et1.DeveloperName=='Post_Funding_cancellation_Notification_External' && programTaskList1.size()==0){
                               options.put(et1.Id,'Canceled Post Funding');
                           }
                    }
                
                if (objApprec.RecordType.Name == 'Field Exhibits'||
                    objApprec.RecordType.Name == 'Commercial Sponsorship'||
                    objApprec.RecordType.Name == 'Non-Commercial Sponsorship'||objApprec.RecordType.Name=='Corporate Memberships') {
                        if(objApprec.Status__c =='Compliance' || objApprec.Status__c=='Decision'){
                            if(et1.DeveloperName == 'gFRS_RFI_2_0_Internal') {
                                options.put(et1.Id,'RFI - Information Request Internal');
                                
                            }
                        }
                        
                        if(objApprec.Status__c =='Compliance' || objApprec.Status__c=='Decision'){
                            if(et1.DeveloperName == 'gFRS_2_0_Payment_Method_Task_Reminder'){
                                options.put(et1.Id,'Payment Method Reminder');
                            }
                        }
                        
                        if(objApprec.Refund_Due_Status_Update__c == 'Yes'){
                            
                            if(programTaskList1.size()==0){
                                if(et1.DeveloperName == 'gFRS_2_0_Internal_Refunds_notification'){
                                    options.put(et1.Id,'Internal Refund Communication');
                                }
                            }
                        }
                        if(objApprec.Status__c =='Processing & Disposition'&&objApprec.Sub_Status__c=='Process Payment'&&
                           objApprec.SAP_Payment_19_Series_Check__c != null&&et1.DeveloperName == 'Post_Funding_cancellation_Notification_Internal'&&programTaskList1.size()==0) {
                               options.put(et1.Id,'Canceled Post Funding');
                               
                           }
                        if(objApprec.Status__c =='Processing & Disposition'&&objApprec.Sub_Status__c=='Approved-Awaiting LOA'&&et1.DeveloperName=='gFRS_2_0_Canceled_Conflict_with_LOA_Terms_Internal'){
                            options.put(et1.Id,'Canceled - Conflict with LOA Terms');
                        }
                    }            
                
                if(program){
                    if (objApprec.RecordType.Name == 'Field Exhibits'||
                        objApprec.RecordType.Name == 'Commercial Sponsorship'||
                        objApprec.RecordType.Name == 'Non-Commercial Sponsorship'||objApprec.RecordType.Name=='Corporate Memberships') {
                            if(et1.DeveloperName == 'gFRS_2_0_Program_Cancelation_Communication'){
                                options.put(et1.Id,'Partial Cancellation Communication');
                            }
                            if(et1.DeveloperName == 'gFRS_2_0_Program_Denial_Communication'){
                                options.put(et1.Id,'Partial Denial Communication');
                            }
                        }else{
                            if (objApprec.RecordType.Name!='Foundation Undergraduate'&&objApprec.RecordType.Name!='Foundation Safety Net Support') {
                                if(et1.DeveloperName == 'gFRS_2_0_Program_Cancelation_Communication_External'){
                                    options.put(et1.Id,'Partial Cancellation Communication');
                                }
                                if(et1.DeveloperName == 'gFRS_2_0_Program_Denial_Communication_External'){
                                    options.put(et1.Id,'Partial Denial Communication');
                                }
                            }
                        }
                    
                    
                    
                }
                
                if(programTaskList.size()>0){
                    if(et1.DeveloperName == 'gFRS_2_0_Re_open_Program_Status_Task_Email_Notification'){
                        options.put(et1.Id,'Re-open Program Status Task Communication');
                    }
                }
            }
        }
        
        return options;
    }
    
    @AuraEnabled
    public static reqTaskWrapperData fetchApplicationReq(Id RecId){
        list<gFRS_Ltng_Task__c> taskList = new list<gFRS_Ltng_Task__c>();
        taskList = [SELECT Id, Name, Status__c, Action_Type__c FROM gFRS_Ltng_Task__c WHERE Status__c != 'Completed' AND Action_Type__c = 'RFI' AND gFRS_Application__c =: RecId];
        Integer taskRecCount = taskList.size();
        
        gFRS_Ltng_Application__c applRec = [select id,name,RecordType.Name,Information_Needed__c from gFRS_Ltng_Application__c where id=:RecId];
        reqTaskWrapperData reqTaskWrap = new reqTaskWrapperData();
        reqTaskWrap.appRec 		= applRec;
        reqTaskWrap.taskCount 	= taskRecCount;
        return reqTaskWrap;
        //return [select id,name,RecordType.Name from gFRS_Ltng_Application__c where id=:RecId];
    }
    
    @AuraEnabled
    public static wrapperEmailData getEmailContent(String EmailName, String RecId){
        
        wrapperEmailData returnwrapperClass = new  wrapperEmailData ();
        gFRS_Ltng_Application__c objApprec =[select id,name,Focus_Area__c,Event_Program_Title__c,RecordType.Name,Owner.Name,Owner.FirstName,Owner.LastName, Owner.email,Person_To_Whom_Payment_should_addressed__c,First_Name__c,Last_Name__c,Program_Start_Date_Min__c,Program_End_Date_max__c,Requested_Amount__c,FPO_compliance_owner__c,Organization__r.Organization_Name__c,Approved_Amount__c,Attention_To__c,Email_Address__c from gFRS_Ltng_Application__c where id=:RecId];
        EmailTemplate  emailCon=[SELECT Subject, Name, Id, Description, Body,DeveloperName,HtmlValue
                                 FROM EmailTemplate
                                 WHERE Id=: EmailName];
        
        if(emailCon.DeveloperName =='Evaluation_Reminder_Communication'){
            if(objApprec.RecordType.Name=='Foundation Undergraduate' || objApprec.RecordType.Name=='Foundation Safety Net Support'){
                Program_Evualation_Question__mdt evaulationMdt = new Program_Evualation_Question__mdt();
                //Program_Evualation_Question__mdt evaulationMdt = [select id,DeveloperName,Evaluation_Questions__c from Program_Evualation_Question__mdt where Funding_Types__c=:objApprec.RecordType.Name];
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
        emailSub = emailSub.replace('<<G-#####>>', ' '+objApprec.Name);         
        body = body.replace('<<G-#####>>', objApprec.Name);  
        body = body.replace('{!gFRS_Ltng_Application__c.OwnerFirstName}', objApprec.Owner.FirstName); 
        body = body.replace('{!gFRS_Ltng_Application__c.OwnerLastName},', objApprec.Owner.LastName);
        body = body.replace('{!gFRS_Ltng_Application__c.OwnerFullName}',objApprec.Owner.Name); 
        if(String.isNotBlank(objApprec.Event_Program_Title__c)){
            body = body.replace('{!gFRS_Ltng_Application__c.Event_Program_Title__c}', objApprec.Event_Program_Title__c); 
            body = body.replace('<<Program/Event Title>>', objApprec.Event_Program_Title__c); 
        }
        else{
            body = body.replace('{!gFRS_Ltng_Application__c.Event_Program_Title__c}', '');
            body = body.replace('<<Program/Event Title>>', '');
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
        
        if(objApprec.RecordType.Name == 'Field Exhibits' || objApprec.RecordType.Name == 'Corporate Memberships' || objApprec.RecordType.Name == 'Commercial Sponsorship' || objApprec.RecordType.Name == 'Non-Commercial Sponsorship'){
            body = body.replace('{link to RFI/Request}',System.Label.gFRS_Ltng_Community_URL);
        } else {
            body = body.replace('{link to RFI/Request}',System.Label.gFRS_CIAM_Home);
        }
        Date dToday = Date.today();
        String dateStr1 = Date.today().format();
        DateTime dt = DateTime.newInstance(dToday.year(), dToday.month(),dToday.day());
        String dateStr = dt.format('MM-dd-yyyy');
        body = body.replace('<<Community Link>>',System.Label.gFRS_Ltng_Community_URL);
        body = body.replace('<Cancellation Date>',dateStr);
        
        String senderName = Userinfo.getFirstName() + ' ' + Userinfo.getLastName();
        body = body.replace('<<Sender First Name Last Name>>', senderName);
        /*Datetime RFI = objApprec.RFI_SubmitDate__c + 7;
body += '\n\n' + '[ref:' + objApprec.RFI_SubmitDate__c + System.today()+']';       
body += '\n\n' + '[ref:' + RFI + ']'; */
        body += '\n\n' + '[ref:' + RecId + ']';       
        returnwrapperClass.emailBody = body;
        returnwrapperClass.subject = emailSub;        
        if(emailCon.DeveloperName =='gFRS_2_0_Payment_Method_Task_Reminder' || emailCon.DeveloperName =='gFRS_2_0_Internal_Refunds_notification' ){
            returnwrapperClass.ownerEmail = objApprec.Person_To_Whom_Payment_should_addressed__c;
        }else if(emailCon.DeveloperName =='LOA_Remainder_DocuSign_Attachment'||emailCon.DeveloperName =='gFRS_2_0_Canceled_Conflict_with_LOA_Terms_External'||emailCon.DeveloperName =='gFRS_2_0_Canceled_Conflict_with_LOA_Terms_Foundation') {
            returnwrapperClass.ownerEmail = objApprec.Email_Address__c;    
        }else if(emailCon.DeveloperName =='gFRS_2_0_Canceled_Conflict_with_LOA_Terms_Internal'){
            returnwrapperClass.ownerEmail = objApprec.Owner.email;
        }else{
            returnwrapperClass.ownerEmail = objApprec.Owner.email;
        }
        
        returnwrapperClass.ownerName = objApprec.Owner.FirstName+''+objApprec.Owner.LastName;
        returnwrapperClass.templateName = emailCon.Name;
        if(String.isNotBlank(objApprec.Person_To_Whom_Payment_should_addressed__c)&&emailCon.DeveloperName=='gFRS_2_0_Internal_Refunds_notification_Cancelled'){
            List<String> programInfo=new List<String>();
            sendEmail(objApprec.Person_To_Whom_Payment_should_addressed__c,RecId,body,'',emailSub,'',emailCon.Name,'',programInfo);
        }
        return returnwrapperClass;
    }
    @AuraEnabled
    public static wrapperEmailData getEmailContent1(String EmailName, String RecId){
        
        wrapperEmailData returnwrapperClass = new  wrapperEmailData ();
        List<gFRS_Ltng_Program__c> progs=[SELECT Id, Name,gFRS_Secondary_program_title__c,gFRS_Start_Date__c,gFRS_End_Date__c,Start_Date_Formula__c,End_Date_Formula__c FROM gFRS_Ltng_Program__c WHERE gFRS_Application__c =:RecId and Program_Status__c!='Canceled' and Program_Status__c!='Denial'];
        returnwrapperClass.progsprogramRecords=progs;
        gFRS_Ltng_Application__c objApprec =[select id,name,Event_Program_Title__c,Person_To_Whom_Payment_should_addressed__c,RecordType.Name,Program_Start_Date_Min__c,Program_End_Date_max__c,Requested_Amount__c,Owner.FirstName,Owner.LastName, Owner.email from gFRS_Ltng_Application__c where id=:RecId];
        EmailTemplate  emailCon=[SELECT Subject, Name, Id, Description, Body,DeveloperName,HtmlValue
                                 FROM EmailTemplate
                                 WHERE Id=: EmailName];
        system.debug('emailName' +emailCon.Name);
        if(emailCon.Name=='gFRS 2.0 Re-open Program Status Task - Email Notification'){
            system.debug('emailName' +emailCon.Name);
            String emailSub = emailCon.Subject;
            String body = emailCon.HtmlValue;
            String title = objApprec.Event_Program_Title__c;      
            string programDate = string.valueOf(objApprec.Program_Start_Date_Min__c);
            string programEndDate = string.valueOf(objApprec.Program_End_Date_max__c);
            string requestedmount = string.valueOf(objApprec.Requested_Amount__c);
            emailSub = emailSub.replace('{!gFRS_Ltng_Application__c.Name}', objApprec.Name);            
            body= body.replace('{!gFRS_Ltng_Application__c.OwnerFirstName}', objApprec.Owner.FirstName);
            body= body.replace('{!gFRS_Ltng_Application__c.Program_End_Date_max__c}', programEndDate);                    
            body = body.replace('{!gFRS_Ltng_Application__c.Name}', objApprec.Name);  
            if(String.isNotBlank(objApprec.Event_Program_Title__c)){
                body = body.replace(' {!gFRS_Ltng_Application__c.Event_Program_Title__c}', objApprec.Event_Program_Title__c); 
            }else{
                body = body.replace(' {!gFRS_Ltng_Application__c.Event_Program_Title__c}', '');
            }
            body = body.replace(']]>', '');
            body += '\n\n' + '[ref:' + RecId + ']';
            returnwrapperClass.emailBody = body;
            returnwrapperClass.subject = emailSub;
            returnwrapperClass.bcc = 'fundingrequestsystem-donotreply-dev-d@gene.com';
            returnwrapperClass.ownerName = objApprec.Owner.FirstName+''+objApprec.Owner.LastName;
            returnwrapperClass.templateName = emailCon.Name; 
            returnwrapperClass.ownerEmail = objApprec.Owner.email;
            return returnwrapperClass;
        }else{
            String emailSub = emailCon.Subject;
            emailSub = emailSub.replace('{!gFRS_Ltng_Application__c.Name}', objApprec.Name);
            String body;
            if(emailCon.DeveloperName == 'gFRS_2_0_Program_Cancelation_Communication_HTML'||emailCon.DeveloperName=='gFRS_2_0_Program_Denial_Communication_HTML'||emailCon.DeveloperName =='gFRS_RFI_2_0_HTML'){
                //body = emailCon.HtmlValue;
                body = emailCon.Body;
                System.debug('I am working');
                body=body.replace(']]>','');
            }else{
                body = emailCon.Body;    
            }
            Date dt=objApprec.Program_Start_Date_Min__c;
            String prgdate=dt.format();
            
            String title = objApprec.Event_Program_Title__c;
            // String date = objApprec.Program_Start_Date_Min__c;
            //  string programDate = string.valueOf(objApprec.Program_Start_Date_Min__c);
            string programEndDate = string.valueOf(objApprec.Program_End_Date_max__c);
            string requestedmount = string.valueOf(objApprec.Requested_Amount__c);
            emailSub = emailSub.replace('<<{!gFRS_Ltng_Application__c.Name} >>', objApprec.Name);         
            body = body.replace('{!gFRS_Ltng_Application__c.Name}', objApprec.Name);  
            if(String.isNotBlank(objApprec.Event_Program_Title__c)){
                body = body.replace(' {!gFRS_Ltng_Application__c.Event_Program_Title__c}', objApprec.Event_Program_Title__c); 
            }
            else{
                body = body.replace(' {!gFRS_Ltng_Application__c.Event_Program_Title__c}', '');
            }
            if(String.isNotBlank(objApprec.RecordType.Name)){
                body = body.replace('{!gFRS_Ltng_Application__c.RecordType}', objApprec.RecordType.Name); 
            }else{
                body = body.replace('{!gFRS_Ltng_Application__c.RecordType}', '');
            }
            Date dToday = Date.today();
            String dateStr1 = Date.today().format();
            DateTime dt1 = DateTime.newInstance(dToday.year(), dToday.month(),dToday.day());
            String dateStr = dt1.format('MM-dd-yyyy');
            body = body.replace('<Cancellation Date>',dateStr);
            body = body.replace('{!gFRS_Ltng_Application__c.Record_Type__c}',objApprec.RecordType.Name);
            body = body.replace('{!gFRS_Ltng_Application__c.Program_Start_Date_Min__c}',prgdate);
            body = body.replace('{!gFRS_Ltng_Application__c.Requested_Amount__c}','$'+requestedmount);
            body = body.replace('{!gFRS_Ltng_Application__c.OwnerFirstName}',objApprec.Owner.FirstName); 
            body = body.replace('{!gFRS_Ltng_Application__c.OwnerFullName}',objApprec.Owner.FirstName+''+objApprec.Owner.LastName); 
            body += '\n\n' + '[ref:' + RecId + ']';
            returnwrapperClass.emailBody = body;
            returnwrapperClass.subject = emailSub;
            //returnwrapperClass.bcc = 'fundingrequestsystem-donotreply-dev-d@gene.com';
            returnwrapperClass.ownerName = objApprec.Owner.FirstName+''+objApprec.Owner.LastName;
            returnwrapperClass.templateName = emailCon.Name; 
            returnwrapperClass.ownerEmail = objApprec.Owner.email;
            return returnwrapperClass;
        }
    }
    
    
    
    @AuraEnabled
    public static wrapperEmailData getDenyEmailContent(String RecId){
        String EmailName = 'gFRS_2_0_Limited_budget_availability_External';
        wrapperEmailData returnwrapperClass = new  wrapperEmailData ();
        //List<gFRS_Ltng_Program__c> progs=[SELECT Id, Name,gFRS_Secondary_program_title__c,gFRS_Start_Date__c,gFRS_End_Date__c FROM gFRS_Ltng_Program__c WHERE gFRS_Application__c =:RecId and Program_Status__c!='Canceled' and Program_Status__c!='Denial'];
        //returnwrapperClass.progsprogramRecords=progs;
        gFRS_Ltng_Application__c objApprec =[select id,name,Event_Program_Title__c,RecordType.Name,Requested_Amount__c,Owner.Name,Owner.FirstName,Owner.LastName, Owner.email from gFRS_Ltng_Application__c where id=:RecId];
        EmailTemplate  emailCon=[SELECT Subject, Name, Id, Description, Body,DeveloperName,HtmlValue
                                 FROM EmailTemplate
                                 WHERE DeveloperName=: EmailName];
        system.debug('emailName' +emailCon.Name);
        
        String emailSub = emailCon.Subject;
        String body = emailCon.Body;
        String title = objApprec.Event_Program_Title__c;      
        
        
        string requestedmount = string.valueOf(objApprec.Requested_Amount__c);
        emailSub = emailSub.replace('{!gFRS_Ltng_Application__c.Name}', objApprec.Name);
        
        body = body.replace('{!gFRS_Ltng_Application__c.Name}', objApprec.Name);
        if(String.isNotBlank(objApprec.Event_Program_Title__c)){
            body = body.replace(' {!gFRS_Ltng_Application__c.Event_Program_Title__c}', objApprec.Event_Program_Title__c); 
        }else{
            body = body.replace(' {!gFRS_Ltng_Application__c.Event_Program_Title__c}', '');
        }
        body= body.replace('{!gFRS_Ltng_Application__c.OwnerFullName}', objApprec.Owner.Name);
        if(String.isNotBlank(objApprec.RecordType.Name)){
            body = body.replace('{!gFRS_Ltng_Application__c.RecordType}', objApprec.RecordType.Name); 
        }else{
            body = body.replace('{!gFRS_Ltng_Application__c.RecordType}', '');
        }
        
        body = body.replace(']]>', '');
        body += '\n\n' + '[ref:' + RecId + ']';
        returnwrapperClass.emailBody = body;
        returnwrapperClass.subject = emailSub;
        returnwrapperClass.bcc = 'fundingrequestsystem-donotreply-dev-d@gene.com';
        returnwrapperClass.ownerName = objApprec.Owner.FirstName+''+objApprec.Owner.LastName;
        returnwrapperClass.templateName = emailCon.Name; 
        returnwrapperClass.ownerEmail = objApprec.Owner.email;
        return returnwrapperClass;
    }
    
    
    @AuraEnabled
    public static void CancelOrDeny(gFRS_Ltng_Application__c request){
        //gFRS_Ltng_Application__c gfrs = new gFRS_Ltng_Application__c();
        Id userId=userinfo.getUserId();
        request.Status__c = 'Closed';
        request.Sub_Status__c = 'Denied';
        request.External_Status__c = 'Not Funded';
        request.Internal_Tracking_Code__c = 'Denial';
        request.Decision_Reasons__c = 'Limited budget availability';
        request.Person_Denied__c = userId;
        request.Person_Denied_Date__c = Date.today();
        gFRS_Ltng_Util_NoShare.updateGfrsAPP(request);
        
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
                    questions = questions + objorg.Question__c +'\n\n'; 
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
        
        if(emailtempName=='gFRS 2.0 Canceled - Conflict with LOA Terms External'||emailtempName=='gFRS 2.0 Canceled - Conflict with LOA Terms Foundation'){  
            gFRS_Ltng_Application__c Apprec =[select id,Owner.email from gFRS_Ltng_Application__c where id=:RecId];
            toCCddresses.add(Apprec.Owner.email);
        }
        GFRS_Ltng_OrgSettings__c myOrgCS = GFRS_Ltng_OrgSettings__c.getOrgDefaults();
        if(myOrgCS.gFRS_Inbound_Email__c != null){
            String bccEmailAddress=myOrgCS.gFRS_Inbound_Email__c;
            tobCCddresses.add(bccEmailAddress.trim());
        }
        OrgWideEmailAddress owea = [select Id from OrgWideEmailAddress where Address='fundingrequestsystem-donotreply-d@gene.com' LIMIT 1];
        email.setOrgWideEmailAddressId(owea.Id);
        email.setToAddresses(toAddresses);
        email.setCcAddresses(toCCddresses);
        email.setBccAddresses(tobCCddresses);        
        email.setSubject(Subject);
        if(emailtempName=='LOA_Remainder_DocuSign_Attachment'|| emailtempName=='gFRS 2.0 Payment Method Task Reminder Email'|| emailtempName=='General Communication2.0 HTML'||emailtempName=='gFRS 2.0 Program Cancelation Communication HTML'||emailtempName=='gFRS 2.0 Program Denial Communication HTML'||emailtempName=='gFRS 2.0 Re-open Program Status Task - Email Notification'){
            email.setHtmlBody(EmailBody);
            email.setTreatBodiesAsTemplate(true);
        }else{
            email.setPlainTextBody(EmailBody);
        }
        
        try{
            gFRS_Ltng_Application__c objApprec =[select id,name,Status__c,Sub_Status__c,Information_Needed__c,RFI_SubmitDate__c,Record_Type__c from gFRS_Ltng_Application__c where id=:RecId];
            system.debug('emailtempName' +emailtempName);
            if(String.isNotBlank(rFIinfo)){
                if(emailtempName=='Evaluation Reminder Communication'){
                    gFRS_Ltng_Application__c updateRFI=new gFRS_Ltng_Application__c();
                    updateRFI.Id=RecId;
                    gFRS_Ltng_Util_NoShare.updateGfrsAPP(updateRFI);
                }else{
                    gFRS_Ltng_Application__c updateRFI=new gFRS_Ltng_Application__c();
                    updateRFI.Id=RecId;
                    updateRFI.Information_Needed__c=rFIinfo;
                    updateRFI.RFI_Previous_Status__c = objApprec.Status__c;
                    updateRFI.RFI_Previous_Sub_Status__c = objApprec.Sub_Status__c;
                    //updateRFI.Status__c='RFI';
                    updateRFI.Sub_Status__c='RFI Sent';
                    updateRFI.RFI_Status__c='RFI Sent';
                    updateRFI.External_Status__c='RFI Sent';                    
                    updateRFI.RFI_SubmitDate__c=System.today();
                    gFRS_Ltng_Util_NoShare.updateGfrsAPP(updateRFI);
                    //update updateRFI;
                    
                    gFRS_Ltng_Task__c createTask=new gFRS_Ltng_Task__c();
                    createTask.gFRS_Application__c=RecId;
                    createTask.Status__c='Open';
                    createTask.Action_Type__c = 'RFI';
                    createTask.Description__c = 'Please respond to the RFI for Funding Request: ' + objApprec.Name;
                    createTask.Subject__c='RFI Required';
                    Date todaysDate = System.today();
                    createTask.Start_Date__c=todaysDate; 
                    gFRS_Ltng_Util_NoShare.updateTask(createTask);
                    //insert createTask;
                }
            }
            if(programInfo.size()>0){ 
                List<gFRS_Ltng_Program__c> progRecds = new List<gFRS_Ltng_Program__c>();
                List<gFRS_Ltng_Program__c> progs=[SELECT Id, Name,Program_Status__c FROM gFRS_Ltng_Program__c WHERE Id =:programInfo ];
                system.debug('ProgramInfo' +progs);
                for(gFRS_Ltng_Program__c prog:progs){
                    if(emailtempName=='gFRS 2.0 Program Cancelation Communication HTML'||emailtempName=='gFRS 2.0 Program Cancelation Communication External'||emailtempName=='gFRS 2.0 Program Cancelation Communication'){
                        prog.Program_Status__c='Canceled';
                    }else{
                        prog.Program_Status__c='Denial';
                    }                    
                    progRecds.add(prog);
                }
                gFRS_Ltng_Util_NoShare.updatePrograms(progRecds); 
            }
            if(emailtempName =='gFRS 2.0 Re-open Program Status Task - Email Notification'){
                List<gFRS_Ltng_Task__c> programTaskList=[select id,name,Action_Type__c,Status__c from gFRS_Ltng_Task__c where gFRS_Application__c=:RecId and Action_Type__c='Program Status'];
                gFRS_Ltng_Application__c updateRFI=new gFRS_Ltng_Application__c();
                updateRFI.Id=RecId;                
                updateRFI.Status__c='Processing & Disposition';
                updateRFI.Sub_Status__c='Process payment';
                updateRFI.External_Status__c='Approved'; 
                gFRS_Ltng_Util_NoShare.updateGfrsAPP(updateRFI);
                gFRS_Ltng_Task__c progTask =new gFRS_Ltng_Task__c();
                progTask.id=programTaskList[0].Id;
                progTask.Status__c='Open';
                gFRS_Ltng_Util_NoShare.updateTask(progTask);
            }
            
            if(emailtempName =='gFRS 2.0 Internal Refunds notification'){
                gFRS_Ltng_Task__c createTask=new gFRS_Ltng_Task__c();
                createTask.gFRS_Application__c=RecId;
                createTask.Status__c='Open';
                createTask.Action_Type__c = 'Refund';
                createTask.Description__c = 'Refund task';
                createTask.Subject__c='Refund';
                Date todaysDate = System.today();
                createTask.Start_Date__c=todaysDate; 
                gFRS_Ltng_Util_NoShare.updateTask(createTask);
            }
            if(emailtempName =='Post Funding cancellation Notification External'||emailtempName =='Post Funding cancellation Notification Internal'){
                if(emailtempName =='Post Funding cancellation Notification Internal'){
                    gFRS_Ltng_Task__c createTask=new gFRS_Ltng_Task__c();
                    createTask.gFRS_Application__c=RecId;
                    createTask.Status__c='Open';
                    createTask.Action_Type__c = 'Refund';
                    createTask.Description__c = 'Refund task';
                    createTask.Subject__c='Refund';
                    Date todaysDate = System.today();
                    createTask.Start_Date__c=todaysDate;
                    gFRS_Ltng_Util_NoShare.updateTask(createTask);
                    
                }
                gFRS_Ltng_Application__c appRec = new gFRS_Ltng_Application__c();
                if(objApprec.Record_Type__c=='Foundation Undergraduate'||objApprec.Record_Type__c=='Foundation Safety Net Support'){
                    appRec.Id					= RecId;   
                    appRec.Status__c	= 'Closed';
                    appRec.Sub_Status__c		= 'Canceled';
                    appRec.External_Status__c	= 'Canceled'; 
                    appRec.Decision_Reasons__c='Canceled Post Funding';   
                }else{
                    appRec.Id					= RecId;                
                    appRec.Sub_Status__c		= 'Refund Required';
                    appRec.External_Status__c	= 'Refund Required'; 
                    appRec.Decision_Reasons__c='Canceled Post Funding';
                }
                gFRS_Ltng_Util_NoShare.updateGfrsAPP(appRec);
            }
            if(emailtempName =='Post Funding cancellation Notification Internal'){
                EmailTemplate emailTemp = [Select id,Name,Subject,Body From EmailTemplate Where DeveloperName='gFRS_2_0_Internal_Refunds_notification_Cancelled'];
                getEmailContent(emailTemp.id,RecId);
            }
            
            if(emailtempName =='gFRS 2.0 Canceled Post Funding Communication'){
                gFRS_Ltng_Application__c appRec = new gFRS_Ltng_Application__c();
                appRec.Id					= RecId;                
                appRec.Sub_Status__c		= 'Reconciliation Required';
                appRec.External_Status__c	= 'Reconciliation Required'; 
                appRec.Decision_Reasons__c='Canceled Post Funding';
                gFRS_Ltng_Util_NoShare.updateGfrsAPP(appRec);
            }
            if(emailtempName =='gFRS 2.0 Canceled - Conflict with LOA Terms Internal'||emailtempName =='gFRS 2.0 Canceled - Conflict with LOA Terms External'||emailtempName =='gFRS 2.0 Canceled - Conflict with LOA Terms Foundation'){
                gFRS_Ltng_Application__c appRec = new gFRS_Ltng_Application__c();
                appRec.Id					= RecId;   
                appRec.Status__c	= 'Closed';
                appRec.Sub_Status__c		= 'Canceled';
                appRec.External_Status__c	= 'Canceled'; 
                appRec.Decision_Reasons__c='Cannot Agree to LOA terms';
                gFRS_Ltng_Util_NoShare.updateGfrsAPP(appRec);
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
        @AuraEnabled public gFRS_Ltng_Application__c appRec{get;set;}
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
    
    public static void InternalCancelSendEmail(String appId) {
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        EmailTemplate emailTemp = [Select id, Subject, Body From EmailTemplate Where DeveloperName='gFRS_2_0_Internal_Refunds_notification_Cancelled'];
        
        gFRS_Ltng_Application__c apprecord=[SELECT Id,Person_To_Whom_Payment_should_addressed__c FROM gFRS_Ltng_Application__c where id=:appId];
        List<string> toAddress = new List<string>();
        toAddress.add(apprecord.Person_To_Whom_Payment_should_addressed__c);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateId(emailTemp.Id);
        mail.setToAddresses(toAddress);
        mail.setSubject(emailTemp.Subject);
        // mail.setTargetObjectId(apprecord.Id);
        mail.setWhatId(appId);
        //   mail.setPlainTextBody(emailTemp.Body);
        emailList.add(mail);
        
        if(!emailList.isEmpty()){
            Messaging.sendEmail(emailList);
        }    
    }
}