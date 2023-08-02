public class gFRS_Ltng_Change_Auth_Sign{
    @AuraEnabled
    public static gFRS_Ltng_Application__c doinit1(String recordId){
        boolean valid=true;
        System.debug('-before-valid--'+valid);
        gFRS_Ltng_Application__c lst=[ SELECT Status__c,Sub_Status__c,Email_Address__c,Authorized_Signer__c,
                                      First_Name__c, Last_Name__c, LOA_Signed__c
                                      FROM gFRS_Ltng_Application__c
                                      WHERE id = :recordId limit 1];
        
        //if(lst.Sub_Status__c!='Approved-Awaiting LOA'&&lst.Status__c!='Compliance'&&lst.Status__c!='Decision'){
        if(lst.Status__c=='Intake'||lst.LOA_Signed__c=='Yes'){
            valid=false;
        }
        System.debug('-after-valid--'+valid);
        return lst;
    }
    public static User[] userByEmail(String p_email) {
        return [SELECT Id, FirstName, LastName, Email FROM User WHERE Email = :p_email LIMIT 1];
    }
    public static void applySharingRulesForSelectedUsers(Id requestId, String targetEmail) {
        
        User[] users = [SELECT Id, Email FROM User WHERE Email = :targetEmail];
        
        if (requestId != null && users.size() > 0) {
            List<gFRS_Ltng_Application__Share> requestShrs = new List<gFRS_Ltng_Application__Share>();
            for (User us1 : users) {
                gFRS_Ltng_Application__Share requestShr = new gFRS_Ltng_Application__Share();
                requestShr.ParentId = requestId;
                requestShr.UserOrGroupId = us1.Id;
                requestShr.AccessLevel = 'Edit';
                requestShr.RowCause = Schema.gFRS_Ltng_Application__Share.RowCause.Manual;
                requestShrs.add(requestShr);
            }
            
            Database.SaveResult[] lsr = Database.insert(requestShrs, false);
            //System.debug(lsr);
            
            // Process the save results
            for (Database.SaveResult sr : lsr) {
                //System.debug(sr.isSuccess());
                if (!sr.isSuccess()) {
                    Database.Error err = sr.getErrors()[0];
                    System.debug(err.getMessage());
                    
                }
            }
            
        }
        
        
        
    }
    public static void saveLockedFundingRequest(gFRS_Ltng_Application__c request) {
        Profile userProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId()];
        
        if(request.Email_Address__c !=null && request.Accountable_Employee__c!=null && userProfile.Name=='GNE-GFRS-Backoffice'){
            request.ownerId=request.Accountable_Employee__c;
            request.Payment_Delivery_Notification__c=request.Accountable_Employee__c;
            
            update request;
            
            if(request.Email_Address__c!=null && request.Accountable_Employee__c!=null){
                List<gFRS_Ltng_Application__Share> requestShrs = new List<gFRS_Ltng_Application__Share>();
                gFRS_Ltng_Application__Share requestShr = new gFRS_Ltng_Application__Share();
                requestShr.ParentId = request.Id;
                requestShr.UserOrGroupId = Userinfo.getUserId();
                requestShr.AccessLevel = 'Read';
                requestShr.RowCause = Schema.gFRS_Ltng_Application__Share.RowCause.Manual;
                requestShrs.add(requestShr);
                Database.SaveResult[] lsr = Database.insert(requestShrs, false);
            }
        }
        
        
        
        
        
        
        
        
    }
    @AuraEnabled
    public static void saveMethod(Id recordId,String email,String firstname,String lastname){
        
        User[] potentialAuthorizedSigners =[SELECT Id, FirstName, LastName, Email FROM User WHERE Email = :email LIMIT 1];
        
        gFRS_Ltng_Application__c gla=[SELECT ID,Status__c,Sub_Status__c,External_Status__c,Authorized_Signer__c,Email_Address__c,Accountable_Employee__c,Payment_Delivery_Notification__c from gFRS_Ltng_Application__c where Id=: recordId];
        if(potentialAuthorizedSigners.size()>0) {
            
            gla.Authorized_Signer__c = potentialAuthorizedSigners[0].Id;
            applySharingRulesForSelectedUsers(gla.Id,email);
            saveLockedFundingRequest(gla);
            //  gFRS_CalloutSendEnvelopeMethod.sendwithDocusign(recordId);
        }
        else {
            gla.Authorized_Signer__c=null;
        }
        gla.Email_Address__c=email;
        gla.First_Name__c=firstname;
        gla.Last_Name__c=lastname;
        //update gla;
        gFRS_Ltng_Util_NoShare.updateAppRec(gla);
        System.debug('-->'+gla.Email_Address__c);
        if(gla.Status__c=='Processing & Disposition'&&gla.Sub_Status__c=='Approved-Awaiting LOA'&&gla.External_Status__c=='Approved-Awaiting LOA'){
            sendLoaMethod(recordId);
            System.debug('-sendLoaMethod->');
        } 
        
        
        
        
        /*  User[] potentialAuthorizedSigners =[SELECT Id, FirstName, LastName, Email FROM User WHERE Email = :email LIMIT 1];

List<gFRS_Ltng_Application__c> lst=new List<gFRS_Ltng_Application__c>();
for(gFRS_Ltng_Application__c gla:[SELECT ID,Status__c,Sub_Status__c,External_Status__c,Authorized_Signer__c,Email_Address__c,Accountable_Employee__c,Payment_Delivery_Notification__c from gFRS_Ltng_Application__c where Id=: recordId]){          

if(potentialAuthorizedSigners.size()>0) {

gla.Authorized_Signer__c = potentialAuthorizedSigners[0].Id;
applySharingRulesForSelectedUsers(gla.Id,email);
saveLockedFundingRequest(gla);
//  gFRS_CalloutSendEnvelopeMethod.sendwithDocusign(recordId);
}
else {
gla.Authorized_Signer__c=null;
}
if(gla.Status__c=='Processing & Disposition'&&gla.Sub_Status__c=='Approved-Awaiting LOA'&&gla.External_Status__c=='Approved-Awaiting LOA'){
sendLoaMethod(recordId);
System.debug('-sendLoaMethod->');
}


lst.add(gla);
}
if(lst.size()>0){
update lst;
//    if(lst.Status__c=='Processing & Disposition'&&gla.Sub_Status__c=='Approved-Awaiting LOA'&&gla.External_Status__c=='Approved-Awaiting LOA'){
// sendLoaMethod(recordId);
//     System.debug('-sendLoaMethod->');
//  }
}
*/
    }
    public static void sendLoaMethod(String recordId){
        for(gFRS_Ltng_Application__c gFRSApp:[SELECT ID,Authorized_Signer__c,Email_Address__c,RecordType.Name from gFRS_Ltng_Application__c where Id=: recordId]){          
            if(gFRSApp.RecordType.Name == 'Field exhibits'){
                gFRS_DocusignAttachPDF_Internal.InsertDocument(recordId);
            }
            else if(gFRSApp.RecordType.Name == 'Commercial Sponsorship' || gFRSApp.RecordType.Name == 'Corporate Memberships' || gFRSApp.RecordType.Name == 'Non-Commercial Sponsorship'){
                //gFRS_DocusignAttachPDF.InsertDocument(recordId);
                gFRS_DocusignAttachPDF_Internal.InsertDocument(recordId);
                SendToDocuSignController.SendNow(recordId);
            }
            else  if(gFRSApp.RecordType.Name == 'Independent Medical Education (CME)'){
                gFRS_DocusignAttachPDF_CME.InsertDocument(recordId,'');
                SendToDocuSignController.SendNow(recordId);
            }
            else if(gFRSApp.RecordType.Name == 'Community Giving' || gFRSApp.RecordType.Name == 'Education Focused Giving K-12'){
                gFRS_DocusignAttachPDF_CG_K12.InsertDocument(recordId,'');
                SendToDocuSignController.SendNow(recordId);
            }
            else if(gFRSApp.RecordType.Name == 'Patient and Health Focused Giving' || gFRSApp.RecordType.Name == 'Scientific and Research Focused Giving' || gFRSApp.RecordType.Name == 'Education Focused Giving Graduate and Post-Graduate'){
                gFRS_DocusignAttachPDF_Pat_Sci_Edu.InsertDocument(recordId,'');
                SendToDocuSignController.SendNow(recordId);
            }
        }
    }
    
   @InvocableMethod
   public static void OoOEmail(List<Id> CustInteractionIDs)
   {

       List<gFRS_Ltng_Customer_Intraction__c> CI = [SELECT Id,Name,Grant_Request_Number__c,owner.Name,owner.email FROM gFRS_Ltng_Customer_Intraction__c Where Id=:CustInteractionIDs];
       
       gFRS_Ltng_Application__c appRec = new gFRS_Ltng_Application__c();
       if(CI[0].Grant_Request_Number__c != '' && CI[0].Grant_Request_Number__c != null){
           appRec = [SELECT Id, Name, Event_Program_Title__c, Requested_Amount__c, Program_Start_Date_Min__c, Record_Type__c, Owner.email FROM gFRS_Ltng_Application__c WHERE Name =:CI[0].Grant_Request_Number__c];
       }
       
       EmailTemplate ET = [SELECT Id, Name, Body, Subject FROM EmailTemplate WHERE DeveloperName = 'gFRS_Out_of_Office_email_for_Contact_Us_form_submission'];
       Messaging.SingleEmailMessage email=new Messaging.SingleEmailMessage();
       List<String> toAddresses = new List<String>();
       toAddresses.add(CI[0].owner.email);
       string EmailBody;
       
       if(CI[0].Grant_Request_Number__c != '' && CI[0].Grant_Request_Number__c != null){
           EmailBody = ET.Body.replace('<<Request ID>>', 'Request ID: ' + appRec.Name);
           EmailBody = EmailBody.replace('<<Event/Program Title>>', 'Event/Program Title: ' + appRec.Event_Program_Title__c);
           EmailBody = EmailBody.replace('<<Funding Type>>', 'Funding Type: ' + appRec.Record_Type__c);
           EmailBody = EmailBody.replace('<<Start Date>>', 'Start Date: ' + string.valueOf(appRec.Program_Start_Date_Min__c));
           
           Decimal reqAmt = appRec.Requested_Amount__c;
           List<String> args = new String[]{'0','number','###,###,##0.00'};
               String amount = String.format(reqAmt.format(), args);
           
           EmailBody = EmailBody.replace('<<Requested Amount>>', 'Requested Amount: $' + amount);
           EmailBody = EmailBody.replace('<<Owner First Name>>', '' + CI[0].owner.Name);
       } else {
           EmailBody = ET.Body.replace('<<Request ID>>', '');
           EmailBody = EmailBody.replace('<<Event/Program Title>>', '');
           EmailBody = EmailBody.replace('<<Funding Type>>', '');
           EmailBody = EmailBody.replace('<<Start Date>>', '');
           EmailBody = EmailBody.replace('<<Requested Amount>>', '');
           EmailBody = EmailBody.replace('<<Owner First Name>>', CI[0].owner.Name);
       }
       
       OrgWideEmailAddress owea = [select Id from OrgWideEmailAddress where Address='fundingrequestsystem-donotreply-d@gene.com' LIMIT 1];
       email.setOrgWideEmailAddressId(owea.Id);
       email.setToAddresses(toAddresses);       
       email.setSubject(ET.Subject);
       email.setPlainTextBody(EmailBody);
       
       List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email }); 
																
    }    
}