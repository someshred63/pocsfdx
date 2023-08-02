public without sharing class  ReviewApproveUpdate {
    
        
    @AuraEnabled
    public static gFRS_Ltng_Application__c fetchApplicationReq(Id reqId){
        return [Select Id,Name,Requested_Amount__c,Approved_Amount__c,DAF_Org_Name__c,Select_GNE_Alignment__c,Grant_Review_Committee__c,OwnerId,Status__c,Sub_Status__c,Decision_Reasons__c,External_Status__c,RecordTypeId,RecordType.Name,Owner.Name,FPO_Reviewer_Comments__c,Business_Reviewer_Comments__c,Financial_Reviewer_Comments__c, Business_Approver_2_Comments__c,Business_Approver_2__c,Social_Impact_Goals__c,Financial_Approver_1__c,External_Tracking_Code__c,Internal_Tracking_Code__c FROM gFRS_Ltng_Application__c WHERE Id =:reqId ];
    }
    
    @AuraEnabled
    public static gFRS_Ltng_Compliance_Flag__c fetchComplianceFlag(Id reqId){
        return [Select  id,Manual_Resolution__c,gFRS_Org_Type_Individual_or_Group_Notes__c,gFRRS_Org_Type_Political_Sectarian_Notes__c,gFRS_Org_Reputation_Blacklist_Notes__c,gFRS_No_Undue_Influ_Clinical_Pract_Notes__c,gFRS_HCP_Aud_Mix_Lrn_not_US_based_Notes__c,gFRS_Funding_Purp_Tgt_Aud_not_HCPs_Nts__c,gFRS_Req_Submitted_by_Individual_or_Grp__c,gFRS_Org_Type_Political_Sectarian_2__c,gFRS_Organization_Reputation_Blacklist__c,gFRS_Funding_for_Developing_CPG__c,Funding_Purpose_Target_audience_not_HCPs__c,HCP_Audience_Mix_Learners_not_US_based__c from gFRS_Ltng_Compliance_Flag__c WHERE gFRS_Application__c =:reqId LIMIT 1];
    }
    
    @AuraEnabled
    public static gFRS_Ltng_Program__c fetchProgramDetails(Id reqId){
        return [Select  id,Name,gFRS_Program_Type__c,gFRS_Start_Date__c,gFRS_End_Date__c,gFRS_Venue_Name__c,gFRS_Expected_number_of_attendees__c,gFRS_Venue_City__c,gFRS_Venue_State__c,gFRS_Venue_Province_Region_Territory__c,gFRS_Venue_Country__c,gFRS_Venue_Zip_Code__c,gFRS_Venue_Type__c,gFRS_Web_URL__c,gFRS_Nbr_of_Grand_Round_Mtg_Series_Activ__c,gFRS_Number_of_speakers_faculty__c from gFRS_Ltng_Program__c WHERE gFRS_Application__c =:reqId LIMIT 1];
    }
    
    @AuraEnabled
    public static gFRS_Ltng_Third_Party__c fetchThirdPartyDetails(Id reqId){
        return [Select  id,Name,Third_Party_Contact_First_Name__c,Third_Party_Contact_Last_Name__c,Third_Party_Company_Function__c,Third_Party_Contact_Email__c,Is_the_Third_Party_org_accredited__c,Third_Party_Tax_ID__c,Third_party_Organization_type__c,Third_Party_Organization_s_website__c,sole_propiertor_or_single_member_LLC__c from gFRS_Ltng_Third_Party__c WHERE gFRS_Application__c =:reqId LIMIT 1];
    }
    
    @AuraEnabled
    public static wrapperEmailData getEmailContent(String EmailName, String RecId){

        wrapperEmailData returnwrapperClass = new  wrapperEmailData ();
        EmailTemplate  emailCon=[SELECT Subject, Name, Id, Description, Body,DeveloperName
                                 FROM EmailTemplate
                                 WHERE DeveloperName = :EmailName ];
        gFRS_Ltng_Application__c gfrsRequest=[SELECT Id,Event_Program_Title__c,Name,Owner.Name,Owner.Email,Owner.FirstName,Owner.LastName,Status__c,Sub_Status__c,Decision_Reasons__c,Program_Start_Date_Min__c,Program_End_Date_max__c,Requested_Amount__c,Record_Type__c,Business_Approver__c,Compliance_Approver__c,Finance_Approver__c,Legal_Approver__c FROM gFRS_Ltng_Application__c Where Id=:RecId];
       	system.debug('Application values' +gfrsRequest);
        String emailSub = emailCon.Subject;
        emailSub = emailSub.replace('{!gFRS_Ltng_Application__c.Name}', gfrsRequest.Name); 
        
        User usrRec = [SELECT Id, Username, LastName, FirstName, Name,Email, CompanyName FROM User Where Id=:UserInfo.getUserId()];
        List<string> userIds = new List<string>();
        userIds.add(gfrsRequest.Business_Approver__c);
        userIds.add(gfrsRequest.Compliance_Approver__c);
        userIds.add(gfrsRequest.Finance_Approver__c);
        userIds.add(gfrsRequest.Legal_Approver__c);
        String userInfo='';
        if(userIds!=null && !userIds.isEmpty()) {
            List<User> userlst =[SELECT Id, Username, Name,Email,Alias FROM User Where Id=:userIds];           
            for(User u :userlst ){ 
                userInfo = userInfo + u.Name +'-'+ u.Alias + '-' + u.Email +'\n'; 
                
            }
        }
       system.debug('userInfo' +userInfo);
        string programDate =  string.valueOf(gfrsRequest.Program_Start_Date_Min__c);
        string programEndDate = string.valueOf(gfrsRequest.Program_End_Date_max__c);
      	string requestedmount = string.valueOf(gfrsRequest.Requested_Amount__c);
        String title = gfrsRequest.Event_Program_Title__c;
        String body = emailCon.Body;
        body = body.replace('{!gFRS_Ltng_Application__c.Name}', gfrsRequest.Name); 
        if(gfrsRequest.Event_Program_Title__c != null && gfrsRequest.Event_Program_Title__c != '') {
        	body = body.replace('{!gFRS_Ltng_Application__c.Event_Program_Title__c}', gfrsRequest.Event_Program_Title__c);
        } else {
            body = body.replace('{!gFRS_Ltng_Application__c.Event_Program_Title__c}', '');
        }
        if(gfrsRequest.Record_Type__c != null && gfrsRequest.Record_Type__c != ''){
            body = body.replace('{!gFRS_Ltng_Application__c.RecordType}', gfrsRequest.Record_Type__c); 
        }
        else {
            body = body.replace('{!gFRS_Ltng_Application__c.RecordType}','');
        }
        if(String.isNotBlank(programDate)){
            body = body.replace('{!gFRS_Ltng_Application__c.Program_Start_Date_Min__c}',programDate); 
        }else {
            body = body.replace('{!gFRS_Ltng_Application__c.Program_Start_Date_Min__c}','');
        }
        if(String.isNotBlank(requestedmount)){
            body = body.replace('{!gFRS_Ltng_Application__c.Requested_Amount__c}', requestedmount);
        }
         else {
            body = body.replace('{!gFRS_Ltng_Application__c.Requested_Amount__c}','');
        }
        if(gfrsRequest.Owner.FirstName != null && gfrsRequest.Owner.FirstName != '') {
        	body = body.replace('{!gFRS_Ltng_Application__c.OwnerFirstName}', gfrsRequest.Owner.FirstName);
        }
        else {
            body = body.replace('{!gFRS_Ltng_Application__c.OwnerFirstName}','');
        }
        if(gfrsRequest.Sub_Status__c != null && gfrsRequest.Sub_Status__c != '') {
        	body = body.replace('{Approver Role}', gfrsRequest.Sub_Status__c);
        }
        else {
            body = body.replace('{Approver Role}','');
        }
        if(String.isNotBlank(userInfo)){
            body = body.replace('{Approver Full Name} ', userInfo);
        }else{
            body = body.replace('{Approver Full Name} ', '');
        }

       /* String senderName = Userinfo.getFirstName() + ' ' + Userinfo.getLastName();
        body = body.replace('<<Sender First Name Last Name>>', senderName);*/
       
        returnwrapperClass.emailBody = body;
        returnwrapperClass.subject = emailSub;
        returnwrapperClass.bcc = '';        
        //returnwrapperClass.ownerEmail = gfrsRequest.Email__c;    
        returnwrapperClass.ownerEmail = gfrsRequest.owner.email; /* add code as part of defect fix - Sending email to the record owner email add code as part of defect fix **Kiran */
        //returnwrapperClass.recStatus = gfrsRequest.Status__c;
        returnwrapperClass.ownerName = gfrsRequest.Owner.FirstName+''+gfrsRequest.Owner.LastName;
        return returnwrapperClass;

    }
    
    public class wrapperEmailData{
        @AuraEnabled public String emailBody{get;set;}
        @AuraEnabled public String ownerEmail{get;set;}
        @AuraEnabled public String subject{get;set;}
        @AuraEnabled public String bcc{get;set;}
        //@AuraEnabled public String recStatus{get;set;}
        @AuraEnabled public String ownerName{get;set;}
        
    }
    
    @AuraEnabled
    public static Boolean  sendNotificationEmails(String To,String RecId,String EmailBody,String bcc,String Subject, String cc){
        String refferId = '[ref:'+RecId+']';
        Boolean isSuccess = false;
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'fundingrequestsystem-donotreply-d@gene.com'];
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        if ( owea.size() > 0 ) {
            email.setOrgWideEmailAddressId(owea.get(0).Id);
        }
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
        string str = '<'+RecId.left(9)+'@'+RecId.right(9)+'>';
        String reff = 'References: 1*'+str+' CRLF';
        
        email.setToAddresses(toAddresses);
        email.setCcAddresses(toccddresses);
        email.setBccAddresses(tobCCddresses);
        email.setReplyTo('gene@f-21hve11zrrgw470vywnvee0df1zgfnzpckv1w20dy9rhauvy0k.3c-8z1juaq.cs60.apex.sandbox.salesforce.com');

        email.setReferences('References: 1*'+str+' CRLF');
        email.setSubject(Subject);
        email.setPlainTextBody(EmailBody);

        try{
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });  
            if(results[0].success){/* Added code as part of defect fix ** Kiran */

                try{
                    Attachment a       = new Attachment();
                    a.ParentId         = RecId;
                    a.ContentType = '.pdf';
                    String fileContent = '';
                    
                    fileContent +='From: '+'Funding Request System <fundingrequestsystem-donotreply-d@gene.com>'+'\n';
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
    
    @AuraEnabled
    public static string updateClosedStatus(Id recId){
		gFRS_Ltng_Application__c gfrs = new gFRS_Ltng_Application__c();
            gfrs.Status__c = 'Closed';
			gfrs.id = recId;        
        update gfrs;
        return gfrs.Status__c;
	}
    
    @AuraEnabled
    public static string updateCloseRequestSubStatus(Id recId,String subStat,String decision){
        gFRS_Ltng_Application__c gfrs = new gFRS_Ltng_Application__c();
        gfrs.Status__c = 'Closed';
        gfrs.Sub_Status__c = subStat;
        gfrs.Decision_Reasons__c = decision;
        if(subStat == 'Canceled'){
            gfrs.External_Status__c = 'Canceled';
        }
        if(subStat == 'Denied'){
            gfrs.External_Status__c = 'Not Funded';
        }
        gfrs.id = recId;        
        update gfrs;
        return subStat;
    }
    
    @AuraEnabled
    public static void updateDAFSubStatus(Id recId,decimal approvedAmt,String DAFOrgName,String DAFVal){
        gFRS_Ltng_Application__c gfrs = new gFRS_Ltng_Application__c();
        gfrs.Status__c = 'Processing & Disposition';
        gfrs.Sub_Status__c = 'Intent to Donate from DAF';
        gfrs.External_Status__c = 'Donar Advised Fund (DAF)';
        gfrs.DAF_Org_Name__c = DAFOrgName;
        gfrs.Approved_Amount__c = approvedAmt;
        gfrs.Select_DAF__c = DAFVal;
        gfrs.id = recId;        
        update gfrs;
        //return subStat;
    }
    
    @AuraEnabled
    public static string updateFpoReviewAndSubmitForApproval(Id recId){
        string StatusVal = '';
        user u= [Select Id,Name From User Where Id =:UserInfo.getUserId()];
        List<gFRS_Ltng_Application__c> recListToUpdate = new List<gFRS_Ltng_Application__c>();
        for(gFRS_Ltng_Application__c rec:[Select id,Status__c,Sub_Status__c,FPO_compliance_owner__c from gFRS_Ltng_Application__c  where Id=:recId]){
            if(rec.Status__c == 'Compliance' && rec.Sub_Status__c == 'New'){
                rec.Status__c = 'Decision';
                rec.Sub_Status__c = 'Business Approval 1';
                rec.FPO_compliance_owner__c = u.id;
                recListToUpdate.add(rec);
            }
            else
            {
                StatusVal = rec.Sub_Status__c;
            }
        }
        if(recListToUpdate.size()>0){
            update recListToUpdate;
            StatusVal = 'SUCCESS';
        }
        
        Approval.ProcessSubmitRequest approvalReq = new Approval.ProcessSubmitRequest();
        approvalReq.setComments('Submitting request for approval.');
        approvalReq.setObjectId(recId);
        approvalReq.setProcessDefinitionNameOrId('AEA_CEG_ReviewApprove');
        approvalReq.setSkipEntryCriteria(true);
        Approval.ProcessResult processResult = Approval.process(approvalReq);
        return StatusVal;
    }
    
    @AuraEnabled
    public static Boolean approveOrRejectRequest(Id reqId,gFRS_Ltng_Application__c request,String comments,decimal approvedAmt,String GRC,String action){
        gFRS_Ltng_Application__c gfrs = new gFRS_Ltng_Application__c();
        gfrs.id = reqId;
        system.debug('Request134'+reqId);
 
      // gfrs.Internal_Tracking_Code__c = request.Internal_Tracking_Code__c;
        
      
        // system.debug('Request123'+request.Internal_Tracking_Code__c); 
      //  system.debug('RequestInternal'+request.Select_GNE_Alignment__c);
        //system.debug('Request134'+request.External_Tracking_Code__c);
        
        Id workItemId = null;
        Id assignedApprover = null;
        Id actualApprover = null;
        if(action == 'Approve'){
        gfrs.Approved_Amount__c = request.Approved_Amount__c;
        gfrs.Business_Approver_2__c =request.Business_Approver_2__c;          
                  
        gfrs.Select_GNE_Alignment__c = request.Select_GNE_Alignment__c; 
        gfrs.External_Tracking_Code__c = request.External_Tracking_Code__c;
            system.debug('Request2'+request.Business_Approver_2__c);
            system.debug('Request2'+request.Business_Approver_2__c);
            system.debug('Request1'+request.Approved_Amount__c);
            system.debug('Request2'+request.Business_Approver_2__c);
            
        system.debug('Request4'+request.Financial_Approver_1__c);
        system.debug('Request5'+request.Financial_Approver_2__c);
        system.debug('Request6'+request.Financial_Approver_3__c);
        system.debug('Request6'+request.Financial_Approver_4__c);
        system.debug('Requestobject details'+request);
            if(request.Financial_Approver_1__c != null){
         Pattern unixIdPattern = Pattern.compile( '[(]([^)]+)[)]' );
        Matcher unixIdMatcher = unixIdPattern.matcher( request.Financial_Approver_1__c );
        String unixId = null;
        
        if( unixIdMatcher.find() ){
            unixId = unixIdMatcher.group(1);
            System.debug( 'financeManager unixId:' + unixId );
        } else {
            //-- calling method catches the custom exception to add the item to gCOI_Pending_Actions
          request.addError('Finance Approver not exists'); 
         }
        
        Id targetId = gFRS_Ltng_Util_NoShare.getUserByUnixId(unixId);
        if( targetId == null ){
         request.addError('Finance Approver not exists');   
        }
                
        gfrs.Financial_Approver_1__c = targetId;   
         }
        
        if(request.Financial_Approver_2__c != null){
         Pattern unixIdPattern = Pattern.compile( '[(]([^)]+)[)]' );
        Matcher unixIdMatcher = unixIdPattern.matcher( request.Financial_Approver_2__c );
        String unixId = null;
        
        if( unixIdMatcher.find() ){
            unixId = unixIdMatcher.group(1);
            System.debug( 'financeManager unixId:' + unixId );
        } else {
            //-- calling method catches the custom exception to add the item to gCOI_Pending_Actions
          request.addError('Finance Approver not exists'); 
         }
            
        
        Id targetId = gFRS_Ltng_Util_NoShare.getUserByUnixId(unixId);
        if( targetId == null ){
         request.addError('Finance Approver not exists');   
        }
        gfrs.Financial_Approver_2__c = targetId;   
            system.debug('Request1234'+targetId);
         }
            
      if(request.Financial_Approver_3__c != null){
         Pattern unixIdPattern = Pattern.compile( '[(]([^)]+)[)]' );
        Matcher unixIdMatcher = unixIdPattern.matcher( request.Financial_Approver_3__c );
        String unixId = null;
        
        if( unixIdMatcher.find() ){
            unixId = unixIdMatcher.group(1);
            System.debug( 'financeManager unixId:' + unixId );
        } else {
            //-- calling method catches the custom exception to add the item to gCOI_Pending_Actions
          request.addError('Finance Approver not exists'); 
         }
        
        Id targetId = gFRS_Ltng_Util_NoShare.getUserByUnixId(unixId);
        if( targetId == null ){
         request.addError('Finance Approver not exists');   
        }
        gfrs.Financial_Approver_3__c = targetId;   
         }

		if(request.Financial_Approver_4__c != null){
         Pattern unixIdPattern = Pattern.compile( '[(]([^)]+)[)]' );
        Matcher unixIdMatcher = unixIdPattern.matcher( request.Financial_Approver_4__c );
        String unixId = null;
        
        if( unixIdMatcher.find() ){
            unixId = unixIdMatcher.group(1);
            System.debug( 'financeManager unixId:' + unixId );
        } else {
            //-- calling method catches the custom exception to add the item to gCOI_Pending_Actions
          request.addError('Finance Approver not exists'); 
         }
        
        Id targetId = gFRS_Ltng_Util_NoShare.getUserByUnixId(unixId);
        if( targetId == null ){
         request.addError('Finance Approver not exists');   
        }
            system.debug('Request'+targetId);
        gfrs.Financial_Approver_4__c = targetId;   
         }
            
            
           }
        if(action == 'Reject'){
            
        }
            
           // UPDATE request;
             gFRS_Ltng_Util_NoShare.updateGfrsAPP(gfrs);
            

        for(ProcessInstanceWorkitem workItem  : [SELECT p.Id, ActorId, OriginalActorId FROM ProcessInstanceWorkitem p where p.ProcessInstance.TargetObjectId =: reqId])
        {
            system.debug('@@@ Inside ProcessInstanceWorkitem query :');
            workItemId  =  workItem.Id;
            assignedApprover = workItem.ActorId;
            actualApprover = workItem.OriginalActorId;
        }
        system.debug('@@@ assignedApprover :'+assignedApprover);
		
        if(validateUser(UserInfo.getUserId(), assignedApprover)){
            Approval.ProcessWorkitemRequest submittedReq = new Approval.ProcessWorkitemRequest();
            submittedReq.setComments(comments);
            submittedReq.setAction(action);
            submittedReq.setWorkitemId(workItemId);
            Approval.ProcessResult result =  Approval.process(submittedReq);
            
            return result.isSuccess();
        }else {
            return false;
        }
    }
    
    @AuraEnabled
    public static Boolean validateUser(Id currentUserId, Id assignedApproverId){
        system.debug('@@@ current User Id :'+currentUserId);
        system.debug('@@@ assignedApproverId User Id :'+assignedApproverId);
        Boolean isSuccess = false;
        //user u= [Select Id,Name From User Where Id =:UserInfo.getUserId()];
        //GroupMember gm= [Select Group.Id FROM GroupMember WHERE UserOrGroupId = :currentUserId AND Group.Type = 'Queue' AND Group.Id =:assignedApproverId];
        if(currentUserId == assignedApproverId){
            isSuccess = true; 
        }else{
            List<GroupMember> gm= [Select Group.Id FROM GroupMember WHERE UserOrGroupId = :currentUserId AND Group.Type = 'Queue' AND Group.Id =:assignedApproverId];
            if(gm.size() > 0){
               isSuccess = true;  
            }
        }
        return isSuccess;
    }
    
    @AuraEnabled
    public static void updateComments(Id reqId,String Comments){
        gFRS_Ltng_Application__c gfrsRec = [Select Id,Status__c,Sub_Status__c FROM gFRS_Ltng_Application__c WHERE Id =:reqId];

        gFRS_Ltng_Application__c gfrs = new gFRS_Ltng_Application__c();
        if(gfrsRec.Sub_Status__c == 'Business Approval 2'){
             gfrs.Business_Reviewer_Comments__c = Comments;
        	 gfrs.id = reqId;
        }
        if(gfrsRec.Sub_Status__c == 'Financial Approval 1'){
             gfrs.Business_Approver_2_Comments__c = Comments;
        	 gfrs.id = reqId;
        }
        if(gfrsRec.Sub_Status__c == 'Financial Approval 2'){
             gfrs.Financial_Reviewer1_Comments__c = Comments;
        	 gfrs.id = reqId;
        }
        if(gfrsRec.Sub_Status__c == 'Financial Approval 3'){
             gfrs.Financial_Reviewer2_Comments__c = Comments;
        	 gfrs.id = reqId;
        }
        if(gfrsRec.Sub_Status__c == 'Financial Approval 4'){
             gfrs.Financial_Reviewer3_Comments__c = Comments;
        	 gfrs.id = reqId;
        }
        if(gfrsRec.Status__c == 'Processing & Disposition'){
             gfrs.Financial_Reviewer_Comments__c = Comments;
        	 gfrs.id = reqId;
        }
       UPDATE gfrs;
    }
    
    @AuraEnabled
    public static Map<String, String> getDecisionReasons(){
        Map<String, String> options = new Map<String, String>();        
        Schema.DescribeFieldResult fieldResult = gFRS_Ltng_Application__c.Decision_Reasons__c.getDescribe();        
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
    
    @AuraEnabled
    public static Map<String, String> getSubStatusValues(){
        Map<String, String> substatusoptions = new Map<String, String>();        
        Schema.DescribeFieldResult fieldResult = gFRS_Ltng_Application__c.Sub_Status__c.getDescribe();        
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            substatusoptions.put(p.getValue(), p.getLabel());
        }
        return substatusoptions;
    }
    
    @AuraEnabled
    public static Map<String, String> getGRCValues(){
        Map<String, String> grcoptions = new Map<String, String>();
        //get Account Industry Field Describe
        Schema.DescribeFieldResult fieldResult = gFRS_Ltng_Application__c.Select_GNE_Alignment__c.getDescribe();
        //get Account Industry Picklist Values
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            //Put Picklist Value & Label in Map
            grcoptions.put(p.getValue(), p.getLabel());
        }
        return grcoptions;
    }
    
    @AuraEnabled
    public static Map<String, String> getDAFValues(){
        Map<String, String> dafoptions = new Map<String, String>();
        //get Account Industry Field Describe
        Schema.DescribeFieldResult fieldResult = gFRS_Ltng_Application__c.DAF_Org_Name__c.getDescribe();
        //get Account Industry Picklist Values
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            //Put Picklist Value & Label in Map
            dafoptions.put(p.getValue(), p.getLabel());
        }
        return dafoptions;
    }
    
    @AuraEnabled 
    public static Map<String, List<String>> getDependentMap(sObject objDetail, string contrfieldApiName,string depfieldApiName) {
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        Schema.sObjectType objType = objDetail.getSObjectType();
        if (objType==null){
            return objResults;
        }
        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();
        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)){
            return objResults;     
        }
        Schema.SObjectField theField = objFieldMap.get(dependentField);
        Schema.SObjectField ctrlField = objFieldMap.get(controllingField);
        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        List<String> controllingValues = new List<String>();
        
        for (Schema.PicklistEntry ple : contrEntries) {
            String label = ple.getLabel();
            objResults.put(label, new List<String>());
            controllingValues.add(label);
        }
        
        for (PicklistEntryWrapper plew : depEntries) {
            String label = plew.label;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    objResults.get(controllingValues.get(i)).add(label);
                }
            }
        }
        return objResults;
    }
    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }
    
    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';
        
        String validForBits = '';
        
        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }
        
        return validForBits;
    }
    
    private static final String base64Chars = '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';
    
    
    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>)
            JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }
    
    public class PicklistEntryWrapper{
        public String active {get;set;}
        public String defaultValue {get;set;}
        public String label {get;set;}
        public String value {get;set;}
        public String validFor {get;set;}
        public PicklistEntryWrapper(){            
        }
        
    }
    
    @AuraEnabled
    public static Id saveFile(Id parentId, String fileName, String base64Data, String contentType, String fileId) {
        if (fileId == '') {
            fileId = saveTheFile(parentId, fileName, base64Data, contentType);
        } else {
            appendToFile(fileId, base64Data);
        }
        
        return Id.valueOf(fileId);
    }
    
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        Attachment oAttachment = new Attachment();
        oAttachment.parentId = parentId;
        
        oAttachment.Body = EncodingUtil.base64Decode(base64Data);
        oAttachment.Name = fileName;
        oAttachment.ContentType = contentType;
        
        insert oAttachment;        
        return oAttachment.Id;
    }
    
    private static void appendToFile(Id fileId, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');        
        Attachment a = [
            SELECT Id, Body
            FROM Attachment
            WHERE Id = : fileId
        ];
        
        String existingBody = EncodingUtil.base64Encode(a.Body);        
        a.Body = EncodingUtil.base64Decode(existingBody + base64Data);        
        update a;
    }
    
    @AuraEnabled
    public static void updateComplianceFlag(Id reqId,String Group_Notes,String Sectarian_Notes,String Blacklist_Notes,String Pract_Notes,String TargetAudience_Notes,String HCPAudience_Notes){
        gFRS_Ltng_Compliance_Flag__c gfrs = new gFRS_Ltng_Compliance_Flag__c();
		gfrs.gFRS_Org_Type_Individual_or_Group_Notes__c = Group_Notes;
		gfrs.gFRRS_Org_Type_Political_Sectarian_Notes__c = Sectarian_Notes;
		gfrs.gFRS_Org_Reputation_Blacklist_Notes__c = Blacklist_Notes;
		gfrs.gFRS_No_Undue_Influ_Clinical_Pract_Notes__c = Pract_Notes;
        gfrs.gFRS_Funding_Purp_Tgt_Aud_not_HCPs_Nts__c = TargetAudience_Notes;
        gfrs.gFRS_HCP_Aud_Mix_Lrn_not_US_based_Notes__c = HCPAudience_Notes;
		gfrs.id = reqId;
       UPDATE gfrs;
    }
    
	@AuraEnabled  
    public static List<picklistWrapper> getPicklistvalues(string objAPIName, string fieldAPIname) {        
       
        list<picklistWrapper> returnValue = new list<picklistWrapper>();
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Map<String, Schema.SObjectField> field_map = gd.get(objAPIName.toLowerCase()).getDescribe().fields.getMap();
        // Get the list of picklist values for this field.
        list < Schema.PicklistEntry > values = field_map.get(fieldAPIname).getDescribe().getPickListValues();
        
        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a: values) {
            picklistWrapper aa = new picklistWrapper();
            aa.pickListLabel = a.getLabel();
            aa.pickListValue = a.getValue();
            returnValue.add(aa);
        }
        
        return returnValue;
        
    }
	 public class picklistWrapper{
        @AuraEnabled 
        public string pickListLabel{get;set;}
        @AuraEnabled 
        public string pickListValue{get;set;}
        
    }
    

}