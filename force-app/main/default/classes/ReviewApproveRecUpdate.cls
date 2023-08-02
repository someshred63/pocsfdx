public without sharing class ReviewApproveRecUpdate {
    
    /**
     * @description This method fetches gFRS Application request and user profile info
     * @param requestId This holds the Application request id
     * @return ApplicationInfo
     * @userstory GFRS-1008
     */
    @AuraEnabled
    public static ApplicationInfo getApplicationInfo(Id reqId) {
        User usr = [SELECT Id, Profile.Name, Username FROM User WHERE Id = :UserInfo.getUserId()];
        gFRS_Ltng_Application__c request = fetchApplicationReq(reqId);
        ApplicationInfo info = new ApplicationInfo();
        info.profile = usr.Profile.Name;
        info.userName = usr.Username;
        info.request = request;
        return info;
    }

    @AuraEnabled
    public static gFRS_Ltng_Application__c fetchApplicationReq(Id reqId){
        return [Select Id,Name,Invite_Code__c,Is_Evaluation_Required__c,Turn_off_LOA_Reminders__c,Recall_Date__c,X33_Limit_Percentage__c,Organization__r.X33_Limit_Percentage__c,Organization__r.Limit_Percentage__c,Organization__r.gFRS_Tot_Aprv_Crnt_Yr__c,Requested_Amount__c,Therapeutic_Area__c,Last_Program_End_Date__c,First_Program_Start_Date__c,
                Disease_State__c,Approved_Amount__c,Giving_Strategy__c,Did_this_request_go_through_GSD_System__c,CreatedBy.Name,CreatedBy.Id ,Organization__c,Vendor_Detail__c,
                Organization__r.Name,Organization__r.Id,Organization__r.Organization_Name__c,Organization__r.Country__c, Organization__r.City__c, Organization__r.Operational_Budget__c,
                Organization__r.Type__c, Organization__r.Annual_PAR_Approval__c,PAR_approval_Status__c,DAF_Org_Name__c,Select_GNE_Alignment__c,
                Grant_Review_Committee__c,OwnerId,Status__c,Sub_Status__c,Decision_Reasons__c,External_Status__c,Event_Program_Title__c,Date_for_Limit_Calculation__c,
                RecordTypeId,RecordType.Name,RecordType_Values__c,Funding_Sub_Type__c,Legal_Approver__c,Legal_Approver__r.Name,Financial_Approver_1__r.Name,Financial_Approver_2__r.Name,
                Financial_Approver_3__r.Name,Financial_Approver_4__r.Name,Owner.Name,FPO_Reviewer_Comments__c,Business_Reviewer_Comments__c,
                Legal_Reviewer_Comments__c,Financial_Reviewer_Comments__c,Business_Approver__c, Accountable_Employee_Internal__c,SAP_Vendor_Required__c,Partner_Bank_Type__c,Payment_Method__c,
                Accountable_Employee_Internal__r.Name,Business_Approver_2_Comments__c,Financial_Reviewer1_Comments__c,Financial_Reviewer2_Comments__c,
                Financial_Reviewer3_Comments__c,Business_Approver_2__c,Social_Impact_Goals__c,If_other_please_specify_Social_Impact__c,Fin_Approver_1__c,Fin_Approver_2__c,Fin_Approver_3__c,Fin_Approver_4__c,
                Financial_Approver_1__c,Financial_Approver_2__c,Financial_Approver_3__c,Financial_Approver_4__c,Refundable_Deposit_Amount_if_any__c,
                External_Tracking_Code__c,Internal_Tracking_Code__c,Finance_Approver__c,Finance_Manager__c,Compliance_Reviewer_Attachment__c,Program_Start_Date_Min__c,
                Decision_Date__c,Total_Amount_Payable__c,FPO_Inputs_Is_MultiPay__c,FPO_Inputs_PaymentAmt__c,Payment_Cost_Center__c,Program_Venue_City__c,
                (Select id,name  ,gFRS_Venue_City__c,gFRS_Start_Date__c from FRS_Programs__r) FROM gFRS_Ltng_Application__c WHERE Id =:reqId ];
    }
     @AuraEnabled
    public static gFRS_Ltng_Application__c UpdatePARStatusReq(Id reqId,string status,string PARComments){
        gFRS_Ltng_Application__c app =[select id,name,PAR_approval_Status__c,PAR_Approval_Comments__c from gFRS_Ltng_Application__c where id=:reqId];
        app.PAR_approval_Status__c=status;
        app.PAR_Approval_Comments__c=PARComments;
        
        update app;
        return  app;
        
    }
	@AuraEnabled
    public static complianceWrapper fetchComplianceFlagHistory(Id recordID){
        gFRS_Ltng_Application__c appRecord = [SELECT Id,Name,(SELECT ID, Name FROM FRS_Compliance_Flags__r) FROM gFRS_Ltng_Application__c WHERE Id =: recordID];
        Id compId;
        for(gFRS_Ltng_Compliance_Flag__c compRec : appRecord.FRS_Compliance_Flags__r){
            compId = compRec.Id;
        }
        
        String type = 'gFRS_Ltng_Compliance_Flag__c';
        Map<String,String> fieldsMap = new Map<String,String>();
        
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(type);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        
        for (String fieldName: fieldMap.keySet()) {
            System.debug('@@ Field API Name='+fieldName);// list of all field API name
            fieldsMap.put(fieldName, fieldMap.get(fieldName).getDescribe().getLabel());
        }	
        
        List<gFRS_Ltng_Compliance_Flag__History> complianceHist = new List<gFRS_Ltng_Compliance_Flag__History>();
        
        complianceHist = [Select Id,CreatedDate,Field,CreatedBy.Name,OldValue,NewValue FROM gFRS_Ltng_Compliance_Flag__History WHERE ParentId =:compId and Field != 'created' ];
        
        complianceWrapper compWrapper = new complianceWrapper();
        compWrapper.compHistory = complianceHist;
        compWrapper.compFields  = fieldsMap;
        
        return compWrapper;
    }     
    
    public class complianceWrapper{
        @AuraEnabled public List<gFRS_Ltng_Compliance_Flag__History> compHistory{get;set;}
        @AuraEnabled public Map<String,String> compFields{get;set;}
        
    }    
    
    @AuraEnabled
    public static User fetchUser(Id userID){
        return [Select Id,Name FROM User WHERE Id =:userID ];
    }    
    @AuraEnabled
    public static User fetchUserID(String userName){
        String str = userName;
        String unixID = str.substring(str.indexOf('(')+1, str.indexOf(')'));
       return [Select Id,Name FROM User WHERE External_ID_gne__c =:unixID ];
      
        
    }
    @AuraEnabled
    public static gFRS_Ltng_Compliance_Flag__c fetchComplianceFlag(Id reqId){
        return [select Id,Name,Organization_Type_Manually_Resolved__c,gFRS_Application__r.Record_Type__c,Organization_Type_Manually_Resolved_Note__c,HCP_Audience_Mix_Learners_not_US__c,gFRS_Application__c,gFRS_Application__r.Sub_Status__c,Organization_Tax_Status__c,Organization_Tax_Status_Notes__c,Broad_Audience_Not_Open_To_Public_Notes__c, Broad_Audience__c, gFRS_Org_Type_Individual_or_Group_Notes__c, Manual_Resolution__c, Organization__c, gFRS_Req_Submitted_by_Individual_or_Grp__c, gFRRS_Org_Type_Political_Sectarian_Notes__c, gFRS_Org_Type_Political_Sectarian_2__c, gFRS_Org_Reputation_Blacklist_Notes__c, gFRS_Organization_Reputation_Blacklist__c, gFRS_No_Undue_Influ_Clinical_Pract_Notes__c, gFRS_Clinical_Practice_Guideline_Dev__c, gFRS_Funding_for_Developing_CPG__c, gFRS_HCP_Aud_Mix_Lrn_not_US_based_Notes__c, gFRS_Funding_Purp_Tgt_Aud_not_HCPs_Nts__c, Funding_Purpose_Target_audience_not_HCPs__c, Promo_Material_Separated_from_CME_Notes__c, gFRS_Program__c, HCP_Audience_Mix_Learners_not_US_based__c, OrgType_Charitable_Foundation_of_a_Group__c, Organization_Ownership_Ind_OR_Grp_Notes__c, Organization_Ownership_Individual_OR_Gr__c, Organization_Type_Poltical_Sec__c, No_Undue_Influence_Clinical_Practices__c, Broad_Audience_Not_Open_To_Public__c, Reach_of_the_Event_Program_Notes__c, Reach_of_the_Event_Program__c, Promotional_Material_Separated_from_CME__c, No_Undue_Influence_General_Org_Support_N__c, No_Undue_Influence_General_Org_Support__c, ApplicationRecordtype__c, OrgType_Other_Notes__c, OrgType_Other__c, Organization_Type_Field_Exhibits_Notes__c, Organization_Type_Memberships_Notes__c, Organization_Type_Field_Exhibits__c, Organization_Type_Memberships__c  from gFRS_Ltng_Compliance_Flag__c WHERE gFRS_Application__c =:reqId LIMIT 1];
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
    public static List<ContentDocument> getContentDocs(Id arecordId) {
        
        try{
            system.debug('@@ in getContentDocs');
            List<ContentDocumentLink> CDLs = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE 
                                              ContentDocumentId =: arecordId];
            //LinkedEntityId = :arecordId];
            if (CDLs.size() < 1) {
                return new List<ContentDocument>();
            }
            List<Id> CDIdList = new List<Id> (); 
            for (ContentDocumentLink nextCDL : CDLs) { 
                CDIdList.add(nextCDL.ContentDocumentId); 
            } 
            List<ContentDocument> entries = [SELECT id,Title,FileType,CreatedBy.Name,ContentSize FROM ContentDocument WHERE Id IN :CDIdList]; 
            system.debug('@@@ entries'+entries);
            return entries;
        }catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        } 
        
    }    
    
    @AuraEnabled
    public static wrapperEmailData getEmailContent(String EmailName, String RecId){
        
        wrapperEmailData returnwrapperClass = new  wrapperEmailData ();
        EmailTemplate  emailCon = [SELECT Subject, Name, Id, Markup,Description,HTMLValue, Body,DeveloperName
                                   FROM EmailTemplate WHERE DeveloperName = :EmailName ];
        gFRS_Ltng_Application__c gfrsRequest=[SELECT Id,Event_Program_Title__c,Name,Contact_Us_URL1__c,DocusignAttach_PDF__c,FPO_compliance_owner__c,Owner.Name,Owner.Email,Owner.FirstName,Owner.LastName,Status__c,Sub_Status__c,Decision_Reasons__c,Program_Start_Date_Min__c,Program_End_Date_max__c,
                                              Payment_Cost_Center__c,Disease_State__c,LastModifiedBy.Name,Requested_Amount__c,Record_Type__c,Business_Approver__c,Business_Approver_2__c,Compliance_Approver__c,Finance_Approver__c,Legal_Approver__c,RecordType_Values__c FROM gFRS_Ltng_Application__c Where Id=:RecId];
       	system.debug('Application values' +gfrsRequest);
        String emailSub = emailCon.Subject;
        emailSub = emailSub.replace('{!gFRS_Ltng_Application__c.Name}', gfrsRequest.Name); 
        
        User usrRec = [SELECT Id, Username, LastName, FirstName, Name,Alias, Email, CompanyName FROM User Where Id=:UserInfo.getUserId()];
        List<string> userIds = new List<string>();
        userIds.add(gfrsRequest.Business_Approver__c);
        userIds.add(gfrsRequest.Business_Approver_2__c);
        userIds.add(gfrsRequest.Compliance_Approver__c);
        userIds.add(gfrsRequest.Finance_Approver__c);
        userIds.add(gfrsRequest.Legal_Approver__c);
        String userInfo='';
        /*if(userIds!=null && !userIds.isEmpty()) {
            List<User> userlst =[SELECT Id, Username, Name,Email,Alias FROM User Where Id=:userIds];           
            for(User u :userlst ){ 
                userInfo = userInfo + u.Name +'\n'+ u.Alias + '\n' + u.Email +'\n'; 
                
            }
        }*/
        /*userInfo = userInfo + usrRec.Name + '<br/>' + usrRec.Alias + '<br/>' + usrRec.Email +'<br/>'; */
        /*userInfo = userInfo + usrRec.Name + '\n' + usrRec.Alias + '\n' + usrRec.Email +'\n';*/
        userInfo = userInfo + usrRec.Name + '\n' + usrRec.Alias + '\n' + usrRec.Email +'\n';
        system.debug('userInfo' +userInfo);
        
        string prgStartDate =  string.valueOf(gfrsRequest.Program_Start_Date_Min__c);
        String programDate = '';
        if(String.isNotBlank(prgStartDate)){
            Date dt=gfrsRequest.Program_Start_Date_Min__c;
            programDate=dt.format();
        }
        
        string programEndDate = string.valueOf(gfrsRequest.Program_End_Date_max__c);
      	string requestedmount = string.valueOf(gfrsRequest.Requested_Amount__c);
        String title = gfrsRequest.Event_Program_Title__c;
        String htmlBody = emailCon.Body;
        //String htmlBody = emailCon.HTMLValue;
        //body = body.replace('{!gFRS_Ltng_Application__c.Name}', gfrsRequest.Name); 
        htmlBody = htmlBody.replace('{!gFRS_Ltng_Application__c.Name}', gfrsRequest.Name); 
        //htmlBody = htmlBody.replace('{!gFRS_Ltng_Application__c.LastModifiedBy}', gfrsRequest.LastModifiedBy.Name);
        htmlBody = htmlBody.replace('{!gFRS_Ltng_Application__c.OwnerFullName}', gfrsRequest.Owner.Name);
        
        if(String.isNotBlank(gfrsRequest.RecordType_Values__c)){
            htmlBody = htmlBody.replace('{!gFRS_Ltng_Application__c.Record_Type__c}',gfrsRequest.RecordType_Values__c);
        }
         else {
            htmlBody = htmlBody.replace('{!gFRS_Ltng_Application__c.Record_Type__c}','');
        }
        
        if(gfrsRequest.Event_Program_Title__c != null && gfrsRequest.Event_Program_Title__c != '') {
        	//body = body.replace('{!gFRS_Ltng_Application__c.Event_Program_Title__c}', gfrsRequest.Event_Program_Title__c);
            htmlBody = htmlBody.replace('{!gFRS_Ltng_Application__c.Event_Program_Title__c}', gfrsRequest.Event_Program_Title__c);
        } else {
            htmlBody = htmlBody.replace('{!gFRS_Ltng_Application__c.Event_Program_Title__c}', '');
        }
        
        if(gfrsRequest.Record_Type__c != null && gfrsRequest.Record_Type__c != ''){
            htmlBody = htmlBody.replace('{!gFRS_Ltng_Application__c.RecordType}', gfrsRequest.Record_Type__c);
        }
        else {
            htmlBody = htmlBody.replace('{!gFRS_Ltng_Application__c.RecordType}','');
        }
        
        if(String.isNotBlank(gfrsRequest.Disease_State__c)){
            htmlBody = htmlBody.replace('{!gFRS_Ltng_Application__c.Disease_State__c}',gfrsRequest.Disease_State__c); 
        }else {
            htmlBody = htmlBody.replace('{!gFRS_Ltng_Application__c.Disease_State__c}','');
        }
        
        if(String.isNotBlank(gfrsRequest.Payment_Cost_Center__c)){
            htmlBody = htmlBody.replace('{!gFRS_Ltng_Application__c.Payment_Cost_Center__c}',gfrsRequest.Payment_Cost_Center__c); 
        }else {
            htmlBody = htmlBody.replace('{!gFRS_Ltng_Application__c.Payment_Cost_Center__c}','');
        }
        
        if(String.isNotBlank(programDate)){
            htmlBody = htmlBody.replace('{!gFRS_Ltng_Application__c.Program_Start_Date_Min__c}',programDate); 
        }else {
            htmlBody = htmlBody.replace('{!gFRS_Ltng_Application__c.Program_Start_Date_Min__c}','');
        }
        if(String.isNotBlank(requestedmount)){
            htmlBody = htmlBody.replace('{!gFRS_Ltng_Application__c.Requested_Amount__c}','$'+requestedmount);
        }
         else {
            htmlBody = htmlBody.replace('{!gFRS_Ltng_Application__c.Requested_Amount__c}','');
        }
        if(gfrsRequest.Owner.FirstName != null && gfrsRequest.Owner.FirstName != '') {
            htmlBody = htmlBody.replace('{!gFRS_Ltng_Application__c.OwnerFirstName}', gfrsRequest.Owner.FirstName);
        }
        else {
            htmlBody = htmlBody.replace('{!gFRS_Ltng_Application__c.OwnerFirstName}','');
        }
        if(gfrsRequest.Sub_Status__c != null && gfrsRequest.Sub_Status__c != '') {
            htmlBody = htmlBody.replace('{Approver Role}', gfrsRequest.Sub_Status__c);
        }
        else {
            htmlBody = htmlBody.replace('{Approver Role}','');
        }
        if(string.isNotBlank(userInfo)){
            htmlBody = htmlBody.replace('{Approver Full Name}', userInfo);
        }else{
            htmlBody = htmlBody.replace('{Approver Full Name}', '');
        }
        
        string fpoUserId=gfrsRequest.FPO_compliance_owner__c;
        if(fpoUserId != null && fpoUserId != '') {           
            User fpoRec = [SELECT Id, Username, LastName, FirstName, Name,Email, CompanyName FROM User Where Id=:fpoUserId];
            htmlBody = htmlBody.replace('{Compliance Approver Name}',fpoRec.Name);
            //htmlBody = htmlBody.replace('{Compliance Approver email}',fpoRec.Email);
        }else{
            htmlBody = htmlBody.replace('{Compliance Approver Name}','');
            //htmlBody = htmlBody.replace('{Compliance Approver email}','');
        }
        String emailAddress=System.UserInfo.getUserEmail();
        htmlBody = htmlBody.replace(']]>', '');
        htmlBody = htmlBody.replace('{!GFRS_Funding_Request__c.LastModifiedBy}',gfrsRequest.LastModifiedBy.Name);
        htmlBody = htmlBody.replace('[Populate the email of the sender]',emailAddress);
        //htmlBody += '\n\n' + '[ref:' + gfrsRequest.id + ']';
        //htmlBody = htmlBody.replace('{!gFRS_Ltng_Application__c.Contact_Us_URL1__c}', gfrsRequest.Contact_Us_URL1__c);
        returnwrapperClass.emailBody = htmlBody;
        //returnwrapperClass.emailBody = body;
        //returnwrapperClass.emailBody = body.stripHtmlTags();
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
    public static void updateCloseRequestSubStatus(Id recId,gFRS_Ltng_Application__c request,String comments){
        gFRS_Ltng_Application__c gfrs = new gFRS_Ltng_Application__c();
        
        gfrs.Sub_Status__c = request.Sub_Status__c;
        gfrs.Comments__c = comments;
        gfrs.Status__c = 'Closed';
        gfrs.Decision_Reasons__c = request.Decision_Reasons__c;
        gfrs.Decision_Date__c = system.today();
        gfrs.Compliance_Approver__c = UserInfo.getUserId();
        if(request.Sub_Status__c == 'Canceled'){
            gfrs.External_Status__c = 'Canceled';
        } else if(request.Sub_Status__c == 'Denied'){
            gfrs.External_Status__c = 'Not Funded';
        }
        String compliancedocumentName = 'Decision_Flags_' + request.Name;
        
        if(request.RecordType.Name == 'Commercial Sponsorship' || request.RecordType.Name == 'Non-Commercial Sponsorship'){
            gFRS_Ltng_Compliance_Flag_Util_Comm.generatePDF(request.Id,compliancedocumentName);
        } else if(request.RecordType.Name == 'Field Exhibits' || request.RecordType.Name == 'Corporate Memberships'){
            gFRS_Ltng_Compliance_Flag_Util_FE.generatePDF(request.Id,compliancedocumentName);
        }
        
        if(request.RecordType.Name == 'Independent Medical Education (CME)'){
            gFRS_Ltng_Compliance_Flag_Util_IME.generatePDF(request.Id,compliancedocumentName);
        }
        
        if(request.RecordType.Name == 'Community Giving' || request.RecordType.Name == 'Education Focused Giving K-12' ||
           request.RecordType.Name == 'Foundation Undergraduate' || request.RecordType.Name == 'Foundation Safety Net Support'){
               gFRS_Ltng_Compliance_Flag_Util_Foun_CG.generatePDF(request.Id,compliancedocumentName);                        
        } 
        if(request.RecordType.Name == 'Patient and Health Focused Giving'){
            gFRS_Ltng_Compliance_Flag_Util_Patient.generatePDF(request.Id,compliancedocumentName);
        }
        if(request.RecordType.Name == 'Scientific and Research Focused Giving' || request.RecordType.Name == 'Education Focused Giving Graduate and Post-Graduate'){
            gFRS_Ltng_Compliance_Flag_Util_Scien_Edu.generatePDF(request.Id,compliancedocumentName);
        }
        
        gfrs.id = recId;        
        try{

            update gfrs;
        } catch(Exception e) {
            throw new AuraHandledException(e.getLineNumber()+':'+e.getMessage());
        }  
    }
    
    @AuraEnabled
    public static gFRS_Ltng_Application__c updateDAFSubStatus(Id recId,gFRS_Ltng_Application__c request,String DAFVal,String CommentSection){
        gFRS_Ltng_Application__c gfrs = new gFRS_Ltng_Application__c();
        gfrs.Status__c = 'Processing & Disposition';
        if(request.Is_Evaluation_Required__c == false){
            gfrs.Sub_Status__c = 'Intent to Donate from DAF';
            gfrs.External_Status__c = 'Donor Advised Fund (DAF)';
        }
        if(request.Is_Evaluation_Required__c == true){
            gfrs.Sub_Status__c = 'Approved-Program Evaluations';
            gfrs.External_Status__c = 'Approved-Program Evaluations';
            gfrs.Is_Evaluation_Required__c = true;
        }
        gfrs.DAF_Org_Name__c = request.DAF_Org_Name__c;
        gfrs.Approved_Amount__c = request.Approved_Amount__c;
        gfrs.Select_DAF__c = DAFVal;
        gfrs.DAF_Comments__c = CommentSection;
        gfrs.id = recId; 
        try{
            update gfrs;
        } catch(Exception e) {
            throw new AuraHandledException(e.getLineNumber()+':'+e.getMessage());
        }  
        return gfrs;
    }
    
    @AuraEnabled
    public static void updateFpoReviewAndSubmitForApproval(Id recId){
        user u= [Select Id,Name From User Where Id =:UserInfo.getUserId()];
        gFRS_Ltng_Application__c rec = [Select id,Status__c,Sub_Status__c,FPO_Review_Required__c,RecordTypeId,RecordType.Name,Funding_Sub_Type__c,FPO_compliance_owner__c from gFRS_Ltng_Application__c  where Id = :recId];            
                
        if(rec.Status__c == 'Compliance' && (rec.Sub_Status__c == 'New' || rec.Sub_Status__c == 'RFI Received')){
            if(rec.RecordType.Name == 'Patient and Health Focused Giving' && rec.FPO_Review_Required__c=='No'){
                rec.Status__c = 'Decision';
                rec.Sub_Status__c = 'Grant Approver 1'; 
            }else{
                rec.Sub_Status__c = 'Compliance Approver';
            }
            if(rec.RecordType.Name == 'Scientific and Research Focused Giving' ||
               rec.RecordType.Name == 'Independent Medical Education (CME)' ||
               rec.RecordType.Name == 'Education Focused Giving Graduate and Post-Graduate')
            {
                rec.Sub_Status__c = 'Compliance Approver';
            } else if(rec.RecordType.Name == 'Community Giving' || rec.RecordType.Name == 'Foundation Undergraduate' ||
                      rec.RecordType.Name == 'Foundation Safety Net Support' || rec.RecordType.Name == 'Education Focused Giving K-12')
            {
                rec.Status__c = 'Decision';
                rec.Sub_Status__c = 'Grant Approver 1';  
            }else if(rec.RecordType.Name == 'Field Exhibits' || rec.RecordType.Name == 'Commercial Sponsorship' || rec.RecordType.Name == 'Non-Commercial Sponsorship' || rec.RecordType.Name == 'Corporate Memberships'){
                rec.Sub_Status__c = 'Compliance Approver'; 
            }
            rec.FPO_compliance_owner__c = u.id;
        } 
        update rec;
        Approval.ProcessSubmitRequest approvalReq = new Approval.ProcessSubmitRequest();
        approvalReq.setComments('Submitting request for approval.');
        approvalReq.setObjectId(recId);
        //approvalReq.setProcessDefinitionNameOrId('IME_Approval_Process');
        approvalReq.setProcessDefinitionNameOrId('');
        approvalReq.setSkipEntryCriteria(true);
        Approval.ProcessResult processResult = Approval.process(approvalReq);
        //return StatusVal;
    }
    
    @AuraEnabled
    public static void CancelOrDeny(gFRS_Ltng_Application__c request){
        //gFRS_Ltng_Application__c gfrs = new gFRS_Ltng_Application__c();
		Id userId=userinfo.getUserId();
        request.Status__c = 'Closed';
        request.Sub_Status__c = 'Denied';
		request.Internal_Tracking_Code__c = 'Denial';
        request.Person_Denied__c = userId;
        request.Person_Denied_Date__c = Date.today();
        gFRS_Ltng_Util_NoShare.updateGfrsAPP(request);

    }
    
    @AuraEnabled
    public static Boolean approveOrRejectRequest(String comments,gFRS_Ltng_Application__c request,String action,Id reqId,List<String> selectedValues,sObject file){
        
        ProcessInstanceWorkitem workItem  = [SELECT p.Id, ActorId, OriginalActorId FROM ProcessInstanceWorkitem p where p.ProcessInstance.TargetObjectId =: reqId];
        Id profileId=userinfo.getProfileId();
        Id userId=userinfo.getUserId();
        String profileName = [Select Id,Name from Profile where Id=:profileId].Name;
        system.debug('@@@ workItem ActorId : '+workItem.ActorId);
        if(workItem != null && (validateUser(UserInfo.getUserId(), workItem.ActorId) || profileName == 'System Administrator')) {
            gFRS_Ltng_Application__c gfrs = new gFRS_Ltng_Application__c();
            Approval.ProcessWorkitemRequest submittedReq = new Approval.ProcessWorkitemRequest();
            request.RFI_Status__c = '';
            if(selectedValues.size() > 0){
                String SelectStr = String.join(selectedValues, ';');
                request.Internal_Tracking_Code__c = SelectStr;
            }
            
            if(request.Sub_Status__c == 'Compliance Approver'){
                request.Compliance_Approver__c = userId;
            }
            if(request.Organization__r.Limit_Percentage__c != null && request.Organization__r.Limit_Percentage__c > 0){
                if((request.Organization__r.Limit_Percentage__c/100) >0.33){
                    
                    
                    if(request.Approved_Amount__c <=500000 && request.Sub_Status__c == 'Financial Approval 1'){
                        request.Acknowledge_33_Exceeded__c =true;
                    }else if((request.Approved_Amount__c>500000) && request.Sub_Status__c == 'Financial Approval 2'){
                        request.Acknowledge_33_Exceeded__c =true;
                    }
                }
            }
            gFRS_Ltng_Util_NoShare.updateGfrsAPP(request);
            submittedReq.setComments(comments);
            submittedReq.setAction(action);
            submittedReq.setWorkitemId(workItem.Id);
            Approval.ProcessResult result =  Approval.process(submittedReq);
            system.debug('@@@ result : '+result.isSuccess());
            gFRS_Ltng_Application__c gfrsrec = [Select id,Name,Sub_Status__c,RecordType.Name from gFRS_Ltng_Application__c  where Id = :request.Id];            
            system.debug(request.Sub_Status__c);
            if(request.Sub_Status__c == 'Compliance Approver'){
                String compliancedocumentName = 'Compliance_Flags_' + request.Name;
                //generatePDF(reqId,compliancedocumentName);
                gFRS_Ltng_Compliance_Flag_Util_IME.generatePDF(reqId,compliancedocumentName);
            }
            if(gfrsrec.Sub_Status__c == 'Approved-Awaiting LOA'){
                String compliancedocumentName = 'Decision_Flags_' + request.Name;
                //generatePDF(reqId,compliancedocumentName);
                gFRS_Ltng_Compliance_Flag_Util_IME.generatePDF(reqId,compliancedocumentName);
            }
            return result.isSuccess();
        }else {
            return false;
        }
    }
    
    @AuraEnabled
    public static Boolean approveOrRejectRequestCG(Id reqId,gFRS_Ltng_Application__c request,List<String> selectedValues,List<String> selectedGSValues, String comments,String action){
        //gFRS_Ltng_Application__c gfrs = new gFRS_Ltng_Application__c();
        gFRS_Ltng_Application__c gfrsrec = [Select id,Name,Sub_Status__c,RecordType.Name,Financial_Approver_1__c,Financial_Approver_2__c,Financial_Approver_3__c,Financial_Approver_4__c from gFRS_Ltng_Application__c  where Id = :request.Id];            
       
        Id workItemId = null;
        Id assignedApprover = null;
        //Id actualApprover = null;
        ProcessInstanceWorkitem workItem = [SELECT Id, ActorId, OriginalActorId FROM ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: reqId];
        
        workItemId  =  workItem.Id != null ? workItem.Id : '';
        assignedApprover = workItem.ActorId != null ? workItem.ActorId : '';
        //actualApprover = workItem.OriginalActorId;
        
        system.debug('@@@ assignedApprover :'+workItem.ActorId);
        Id profileId=userinfo.getProfileId();
        String profileName = [Select Id,Name from Profile where Id=:profileId].Name;
        
        if(validateUser(UserInfo.getUserId(), assignedApprover) || profileName == 'System Administrator') {
            Approval.ProcessWorkitemRequest submittedReq = new Approval.ProcessWorkitemRequest();
            if(action == 'Approve') {
                if(selectedValues.size() > 0){
                    String SelectStr = String.join(selectedValues, ';');
                    request.Internal_Tracking_Code__c = SelectStr;
                }
                request.RFI_Status__c = '';
                if(selectedGSValues.size() > 0){
                    String SelectGSStr = String.join(selectedGSValues, ';');
                    request.Giving_Strategy__c=SelectGSStr;
                }
                system.debug('@@@ Before sub status :'+request.Sub_Status__c);
                if(request.Sub_Status__c == 'Grant Approver 1' || request.Sub_Status__c == 'Grant Approver 2'){
                    system.debug('@@@ After sub status :'+request.Sub_Status__c);
                    //system.debug('@@@ After sub status gfrs.Financial_Approver_1__c:'+gfrs.Financial_Approver_1__c);
                    /*if(String.isNotBlank(request.Financial_Approver_1__c) && request.Financial_Approver_1__c != gfrsrec.Financial_Approver_1__c) {
                        Pattern unixIdPattern = Pattern.compile( '[(]([^)]+)[)]' );
                        Matcher unixIdMatcher = unixIdPattern.matcher( request.Financial_Approver_1__c );
                        String unixId = null;
                        
                        if( unixIdMatcher.find()){
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
                        
                        request.Financial_Approver_1__c = targetId;   
                    }*/
                    
                    /*if(String.isNotBlank(request.Financial_Approver_2__c) && request.Financial_Approver_2__c != gfrsrec.Financial_Approver_2__c) {
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
                        request.Financial_Approver_2__c = targetId;   
                        system.debug('Request1234'+targetId);
                    }*/
                    
                    /*if(String.isNotBlank(request.Financial_Approver_3__c) && request.Financial_Approver_3__c != gfrsrec.Financial_Approver_3__c) {
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
                        request.Financial_Approver_3__c = targetId;   
                    }*/
                    
                    /*if(String.isNotBlank(request.Financial_Approver_4__c) && request.Financial_Approver_4__c != gfrsrec.Financial_Approver_4__c) {
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
                        request.Financial_Approver_4__c = targetId;   
                    }*/
                }
                if(request.Organization__r.Limit_Percentage__c != null && request.Organization__r.Limit_Percentage__c > 0){
                    if((request.Organization__r.Limit_Percentage__c/100) >0.33){
                        
                        
                        if(request.Approved_Amount__c <=100000 && request.Sub_Status__c == 'Financial Approval 1'){
                            request.Acknowledge_33_Exceeded__c =true;
                        }else if((request.Approved_Amount__c >100000 && request.Approved_Amount__c <=1000000) && request.Sub_Status__c == 'Financial Approval 2'){
                            request.Acknowledge_33_Exceeded__c =true;
                        }else if((request.Approved_Amount__c >1000000 && request.Approved_Amount__c <=5000000) && request.Sub_Status__c == 'Financial Approval 3'){
                            request.Acknowledge_33_Exceeded__c =true;
                        }else if(request.Approved_Amount__c >5000000 && request.Sub_Status__c == 'Financial Approval 4'){
                            request.Acknowledge_33_Exceeded__c =true;
                        }
                    }
                }
                gFRS_Ltng_Util_NoShare.updateGfrsAPP(request);
            }
            //if(action == 'Reject'){}
            // UPDATE request;
            //gfrs.id = reqId;
            
            submittedReq.setComments(comments);
            submittedReq.setAction(action);
            submittedReq.setWorkitemId(workItemId);
            Approval.ProcessResult result =  Approval.process(submittedReq);
            system.debug('result status----->>> '+result.getInstanceStatus());
            system.debug('result status----->>> '+result.isSuccess());
            //gFRS_Ltng_Application__c gfrsrec = [Select id,Name,Sub_Status__c,RecordType.Name from gFRS_Ltng_Application__c  where Id = :request.Id];            
            system.debug(request.Sub_Status__c);
            /*if((request.Sub_Status__c == 'Grant Approver 1' && (request.RecordType.Name == 'Foundation Undergraduate' || request.RecordType.Name == 'Foundation Safety Net Support' || request.RecordType.Name == 'Community Giving' || request.RecordType.Name == 'Education Focused Giving K-12'))||
              (request.Sub_Status__c == 'Compliance Approver' && (request.RecordType.Name == 'Patient and Health Focused Giving' || request.RecordType.Name == 'Scientific and Research Focused Giving' ||
           request.RecordType.Name == 'Education Focused Giving Graduate and Post-Graduate'))){
                String compliancedocumentName = 'Compliance_Flags_' + request.Name;
                generatePDF(reqId,compliancedocumentName);
            }
            if(gfrsrec.Sub_Status__c == 'Approved-Awaiting LOA'){
                String compliancedocumentName = 'Decision_Flags_' + request.Name;
                generatePDF(reqId,compliancedocumentName);
            }*/
            
            if(request.RecordType.Name == 'Scientific and Research Focused Giving' || request.RecordType.Name == 'Education Focused Giving Graduate and Post-Graduate'){
                if(request.Sub_Status__c == 'Compliance Approver'){
                    String compliancedocumentName = 'Compliance_Flags_' + request.Name;
                    //generatePDF(reqId,compliancedocumentName);
                    gFRS_Ltng_Compliance_Flag_Util_Scien_Edu.generatePDF(reqId,compliancedocumentName);
                }else if(gfrsrec.Sub_Status__c == 'Approved-Awaiting LOA'){
                    String compliancedocumentName = 'Decision_Flags_' + request.Name;
                    //generatePDF(reqId,compliancedocumentName);
                	gFRS_Ltng_Compliance_Flag_Util_Scien_Edu.generatePDF(reqId,compliancedocumentName);
                }
            }
            
            if(request.RecordType.Name == 'Patient and Health Focused Giving'){
                if(request.Sub_Status__c == 'Compliance Approver'){
                    String compliancedocumentName = 'Compliance_Flags_' + request.Name;
                    //generatePDF(reqId,compliancedocumentName);
                    gFRS_Ltng_Compliance_Flag_Util_Patient.generatePDF(reqId,compliancedocumentName);
                }else if(gfrsrec.Sub_Status__c == 'Approved-Awaiting LOA'){
                    String compliancedocumentName = 'Decision_Flags_' + request.Name;
                    //generatePDF(reqId,compliancedocumentName);
                	gFRS_Ltng_Compliance_Flag_Util_Patient.generatePDF(reqId,compliancedocumentName);
                }
            }
            
            if(request.RecordType.Name == 'Foundation Undergraduate' || request.RecordType.Name == 'Foundation Safety Net Support' || request.RecordType.Name == 'Community Giving' || request.RecordType.Name == 'Education Focused Giving K-12'){
                if(request.Sub_Status__c == 'Grant Approver 1'){
                    String compliancedocumentName = 'Compliance_Flags_' + request.Name;
                    //generatePDF(reqId,compliancedocumentName);
                    gFRS_Ltng_Compliance_Flag_Util_Foun_CG.generatePDF(reqId,compliancedocumentName);
                }else if(gfrsrec.Sub_Status__c == 'Approved-Awaiting LOA'){
                    String compliancedocumentName = 'Decision_Flags_' + request.Name;
                    //generatePDF(reqId,compliancedocumentName);
                	gFRS_Ltng_Compliance_Flag_Util_Foun_CG.generatePDF(reqId,compliancedocumentName);
                }
            }
            return result.isSuccess();
        } else {
            return false;
        }
        
    }
    
    @AuraEnabled
    public static Boolean approveInternalRequest(gFRS_Ltng_Application__c request, String comments,String action){

        Id workItemId = null;
        Id assignedApprover = null;
        
        ProcessInstanceWorkitem workItem = [SELECT Id, ActorId, OriginalActorId FROM ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =: request.Id];
        
        workItemId  =  workItem.Id != null ? workItem.Id : '';
        assignedApprover = workItem.ActorId != null ? workItem.ActorId : '';
        
        system.debug('@@@ assignedApprover :'+workItem.ActorId);
        Id profileId=userinfo.getProfileId();
        String profileName = [Select Id,Name from Profile where Id=:profileId].Name;
        
        if(validateUser(UserInfo.getUserId(), assignedApprover) || profileName == 'System Administrator') {
            Approval.ProcessWorkitemRequest submittedReq = new Approval.ProcessWorkitemRequest();  
            request.RFI_Status__c = '';
            gFRS_Ltng_Util_NoShare.updateGfrsAPP(request);            
            submittedReq.setComments(comments);
            submittedReq.setAction(action);
            submittedReq.setWorkitemId(workItemId);
            Approval.ProcessResult result =  Approval.process(submittedReq);
            if(request.RecordType.Name == 'Field Exhibits'){
                if(request.Sub_Status__c == 'Compliance Approver'){
                    String compliancedocumentName = 'Compliance_Flags_' + request.Name;                   
                    gFRS_Ltng_Compliance_Flag_Util_FE.generatePDF(request.Id,compliancedocumentName);
                } else {
                    if(action == 'Reject'){
                        String compliancedocumentName = 'Decision_Flags_' + request.Name;
                        gFRS_Ltng_Compliance_Flag_Util_FE.generatePDF(request.Id,compliancedocumentName);
                    }
                }
                /* if(gfrs.Sub_Status__c == 'Approved-Awaiting LOA'){
                    String compliancedocumentName = 'Decision_Flags_' + request.Name;
                    //generatePDF(request.Id,compliancedocumentName);
                    gFRS_Ltng_Compliance_Flag_Util_FE.generatePDF(request.Id,compliancedocumentName);
                } */
            }
            
            if(request.RecordType.Name == 'Commercial Sponsorship' || request.RecordType.Name == 'Non-Commercial Sponsorship'){
                if(request.Sub_Status__c == 'Compliance Approver'){
                    String compliancedocumentName = 'Compliance_Flags_' + request.Name;
                    //generatePDF(request.Id,compliancedocumentName);
                    gFRS_Ltng_Compliance_Flag_Util_Comm.generatePDF(request.Id,compliancedocumentName);
                } else{
                    if(action == 'Reject'){
                        String compliancedocumentName = 'Decision_Flags_' + request.Name;
                        gFRS_Ltng_Compliance_Flag_Util_Comm.generatePDF(request.Id,compliancedocumentName);
                    }
                }
                /* if(gfrs.Sub_Status__c == 'Approved-Awaiting LOA'){
                    String compliancedocumentName = 'Decision_Flags_' + request.Name;
                    //generatePDF(request.Id,compliancedocumentName);
                    gFRS_Ltng_Compliance_Flag_Util_Comm.generatePDF(request.Id,compliancedocumentName);
                } */
            }

            if(request.RecordType.Name == 'Corporate Memberships'){
                if(request.Sub_Status__c == 'Compliance Approver'){
                    String compliancedocumentName = 'Compliance_Flags_' + request.Name;
                    //generatePDF(request.Id,compliancedocumentName);
                    gFRS_Ltng_Compliance_Flag_Util_FE.generatePDF(request.Id,compliancedocumentName);
                } else {
                    if(action == 'Reject'){
                        String compliancedocumentName = 'Decision_Flags_' + request.Name;
                        gFRS_Ltng_Compliance_Flag_Util_FE.generatePDF(request.Id,compliancedocumentName);
                    }
                }
                /* if(gfrs.Sub_Status__c == 'Approved-Awaiting LOA'){
                    String compliancedocumentName = 'Decision_Flags_' + request.Name;
                    //generatePDF(request.Id,compliancedocumentName);
                    gFRS_Ltng_Compliance_Flag_Util_FE.generatePDF(request.Id,compliancedocumentName);
                } */
            }
            
            if(request.RecordType.Name == 'Corporate Memberships' || request.RecordType.Name == 'Commercial Sponsorship' || request.RecordType.Name == 'Non-Commercial Sponsorship'){
                if(request.Sub_Status__c == 'Business Approver' && request.Finance_Approver__c!=null ){
                    request.Sub_Status__c='Financial Approver';
                    gFRS_Ltng_Util_NoShare.updateGfrsAPP(request);
                }if(request.Sub_Status__c == 'Business Approver' && request.Finance_Approver__c==null ){
                    request.Sub_Status__c='Finance Manager';
                    gFRS_Ltng_Util_NoShare.updateGfrsAPP(request);
                }
            }
             
            return result.isSuccess();
        } else {
            return false;
        }
        
    }
    
    @AuraEnabled
    public static void RecallRequest(String comments, gFRS_Ltng_Application__c request){
        gFRS_Ltng_Application__c gfrs = new gFRS_Ltng_Application__c();
        request.Recall_Date__c = Date.today();
        ProcessInstanceWorkitem workItem  = [SELECT Id, ActorId, OriginalActorId FROM ProcessInstanceWorkitem  where ProcessInstance.TargetObjectId =: request.id];
        Approval.ProcessWorkitemRequest submittedReq = new Approval.ProcessWorkitemRequest();  
        gFRS_Ltng_Util_NoShare.updateGfrsAPP(request);
        submittedReq.setAction('Removed');
        submittedReq.setWorkItemId(workItem.Id);
        //Approval.ProcessResult result =  Approval.process(submittedReq);
        
        Messaging.SingleEmailMessage mail1 = new Messaging.SingleEmailMessage();
        string body 	= 'wrkItemId:' + workItem.Id;
        GFRS_Ltng_OrgSettings__c myOrgCS1 = GFRS_Ltng_OrgSettings__c.getOrgDefaults();
        
        mail1.setSubject('Dummy email for recall request from approval ');
        mail1.setPlainTextBody(body);
        mail1.setToAddresses(new List<String>{myOrgCS1.Recall_Inbound_Email__c});
        mail1.setTreatBodiesAsTemplate(true);
        
        List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail1 });
    }
    
    @AuraEnabled
    public static Boolean generateCompliancePDF(Id reqId){
        gFRS_Ltng_Application__c request = [Select id,Name,Sub_Status__c,RecordType.Name,Legal_Approver__c,Business_Approver_2__c,Final_Approver_Decision_Date__c,FPO_Reviewer_Decision_Date__c from gFRS_Ltng_Application__c  where Id = :reqId];            
        system.debug(request.Sub_Status__c);
        system.debug(request);
        system.debug(request.Legal_Approver__c);
        system.debug(request.Business_Approver_2__c);
        if(request.RecordType.Name == 'Foundation Undergraduate' || request.RecordType.Name == 'Foundation Safety Net Support' ||
           request.RecordType.Name == 'Community Giving' || request.RecordType.Name == 'Education Focused Giving K-12'){
            if(request.Sub_Status__c == 'Legal Review' || (request.Sub_Status__c == 'Grant Approver 2' && (request.Legal_Approver__c == '' || request.Legal_Approver__c == null)) ){
                String compliancedocumentName = 'Compliance_Flags_' + request.Name;
                generatePDF(reqId,compliancedocumentName);
            }
        }
        if(request.RecordType.Name == 'Patient and Health Focused Giving' || request.RecordType.Name == 'Scientific and Research Focused Giving' ||
           request.RecordType.Name == 'Education Focused Giving Graduate and Post-Graduate'){
               if(request.Sub_Status__c == 'Legal Review' || (request.Sub_Status__c == 'Grant Approver 1' && (request.Legal_Approver__c == '' || request.Legal_Approver__c == null)) ){
                   String compliancedocumentName = 'Compliance_Flags_' + request.Name;
                   generatePDF(reqId,compliancedocumentName);
               }
           }
        if(request.Status__c == 'Processing & Disposition'){
            String compliancedocumentName = 'Decision_Flags_' + request.Name;
            generatePDF(reqId,compliancedocumentName);
        }
        return true;
    }
    
    @future(callout=true)
    public static void generatePDF(String reqId,String documentName) {
        system.debug('documentName---->'+documentName);
        PageReference pdfPage = new PageReference('/apex/gfrs_ltng_compliancecheckflagpdf');
        pdfPage.getParameters().put('Id', reqId);
        Blob pdfContent = pdfPage.getContentAsPDF();
        
        /*Attachment attach1= new Attachment();
attach1.ParentId = reqId;
attach1.Name = documentName;
attach1.Body = pdfContent;
attach1.contentType = 'application/pdf';
insert attach1;*/
        
        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
        cVersion.PathOnClient = documentName + '.pdf';//File name with extention
        //cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
        //cVersion.OwnerId = attach2.OwnerId;//Owner of the file
        cVersion.Title = documentName + '.pdf';//Name of the file
        cVersion.VersionData =  pdfContent;//File content
        Insert cVersion;
        
        //After saved the Content Verison, get the ContentDocumentId
        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
        
        //Insert ContentDocumentLink
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
        cDocLink.LinkedEntityId = reqId;//Add attachment parentId
        //cDocLink.ShareType = 'I';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        //cDocLink.Visibility = 'InternalUsers';//AllUsers, InternalUsers, SharedUsers
        Insert cDocLink;
        
        gFRS_Ltng_Application__c gfrs = new gFRS_Ltng_Application__c();
        if(documentName.contains('Compliance')){
            gfrs.Compliance_Flags_PDF_ID__c = conDocument;
            gfrs.id = reqId;
            update gfrs;
        } else if(documentName.contains('Decision')){
            gfrs.Decision_Flags_PDF_ID__c = conDocument;
            gfrs.id = reqId;
            update gfrs; 
        }
    }
    
    @AuraEnabled
    public static Id saveChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId) {
        gFRS_Ltng_Application__c appRec;

        appRec = [Select Id, Name, Compliance_Reviewer_Attachment__c From gFRS_Ltng_Application__c where id=: parentId];
        try{
            if (fileId == '') {
                fileId = saveTheFileInternal(parentId, fileName, base64Data, contentType);
            } else {
                appendToFileInternal(fileId, base64Data);
            }
            
            if(fileId != null){  
                appRec.Compliance_Reviewer_Attachment__c = Id.valueOf(fileId);
                update appRec;
            }
            
            return Id.valueOf(fileId);
        }catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
    }    
    
    public static Id saveTheFileInternal(Id parentId, String fileName, String base64Data, String contentType) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');

        try{
            Attachment attach = new Attachment();
            attach.parentId = parentId;
            attach.OwnerId = UserInfo.getUserId();
            attach.Body = EncodingUtil.base64Decode(base64Data);
            attach.Name = fileName;
            attach.ContentType = contentType;
            
            //insert attach;
            
            //Insert ContentVersion
            ContentVersion cVersion = new ContentVersion();
            cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
            cVersion.PathOnClient = attach.Name;//File name with extention
            cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
            cVersion.OwnerId = attach.OwnerId;//Owner of the file
            cVersion.Title = attach.Name;//Name of the file
            cVersion.VersionData = attach.Body;//File content
            cVersion.IsMajorVersion = false;
            Insert cVersion;
            
            //After saved the Content Verison, get the ContentDocumentId
            Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
            
            //Insert ContentDocumentLink
            ContentDocumentLink cDocLink = new ContentDocumentLink();
            cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
            cDocLink.LinkedEntityId = attach.ParentId;//Add attachment parentId
            cDocLink.ShareType = 'I';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
            cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
            Insert cDocLink;

            return cDocLink.ContentDocumentId;
            
        } catch(Exception ex){
            system.debug('@@@ exception::'+ex.getMessage());
            return null;
        }

    }  
    
    private static void appendToFileInternal(Id fileId, String base64Data) {
        try{
            base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
          
            ContentVersion cVersion = [ 
                SELECT VersionData 
                FROM ContentVersion 
                WHERE ContentDocumentId = :fileId AND IsLatest = true];
            
            String existingBody = EncodingUtil.base64Encode(cVersion.VersionData);
            
            cVersion.VersionData = EncodingUtil.base64Decode(existingBody + base64Data);
            
            update cVersion;
        }catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
    }
    
    @AuraEnabled
    public static Boolean deleteContentDoc(Id contentDocID, Id appRecId) {
        
        try{
            List<ContentDocument> entries = [SELECT id,Title,FileType,CreatedBy.Name,ContentSize FROM ContentDocument WHERE Id =:contentDocID]; 
            delete entries;
            
            gFRS_Ltng_Application__c appRec = [Select id,name,Compliance_Reviewer_Attachment__c From gFRS_Ltng_Application__c where id=: appRecId];

            appRec.Compliance_Reviewer_Attachment__c = '';
            update appRec;                        
            
            system.debug('@@@ Content Doc deleted');
            return true;
        }catch(Exception e){
            system.debug('@@@ Content Doc deletion failure');
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        } 
        
    }      
    
    @AuraEnabled
    public static Boolean validateUser(Id currentUserId, Id assignedApproverId) {
        Boolean isSuccess = false;
        if(currentUserId == assignedApproverId) {
            isSuccess = true; 
        } else {
            List<GroupMember> gm= [Select Group.Id FROM GroupMember WHERE UserOrGroupId = :currentUserId AND Group.Type = 'Queue' AND Group.Id =:assignedApproverId];
            if(gm.size() > 0) {
                isSuccess = true;  
            }
        }
        return isSuccess;
    }
    
    @AuraEnabled
    public static void updateComments(Id reqId,String assignBA2,String Comments){
        gFRS_Ltng_Application__c gfrsRec = [Select Id,Name,Status__c,Sub_Status__c,Legal_Approver__c FROM gFRS_Ltng_Application__c WHERE Id =:reqId];
        
        gFRS_Ltng_Application__c gfrs = new gFRS_Ltng_Application__c();
        
        //String documentName = 'Compliance_Flags_' + gfrsRec.Name;
        //generatePDF(reqId,documentName);
        if(gfrsRec.Sub_Status__c == 'Legal Review'){
            gfrs.FPO_Reviewer_Comments__c = Comments;
            String compliancedocumentName = 'Compliance_Flags_' + gfrsRec.Name;
            generatePDF(reqId,compliancedocumentName);
            //gfrs.Legal_Reviewer_Comments__c = Comments;
        } else if(gfrsRec.Sub_Status__c == 'Grant Approver 1'){
            if(gfrsRec.Legal_Approver__c == ''){
                gfrs.FPO_Reviewer_Comments__c = Comments;
                String compliancedocumentName = 'Compliance_Flags_' + gfrsRec.Name;
                generatePDF(reqId,compliancedocumentName);
            }else if(gfrsRec.Legal_Approver__c != ''){
                gfrs.Legal_Reviewer_Comments__c = Comments;
            }
        } else if(gfrsRec.Sub_Status__c == 'Financial Approval'|| (gfrsRec.Sub_Status__c == 'Grant Approver 2'&& assignBA2 == 'Yes') || (gfrsRec.Sub_Status__c == 'Financial Approval 1'&& assignBA2 == 'No')){
            gfrs.Business_Reviewer_Comments__c = Comments;
        } else if(gfrsRec.Sub_Status__c == 'Financial Approval 1' && assignBA2 == 'Yes'){
            gfrs.Business_Approver_2_Comments__c = Comments;
        } else if(gfrsRec.Sub_Status__c == 'Financial Approval 2'){
            gfrs.Financial_Reviewer1_Comments__c = Comments;
        } else if(gfrsRec.Sub_Status__c == 'Financial Approval 3'){
            gfrs.Financial_Reviewer2_Comments__c = Comments;
        } else if(gfrsRec.Sub_Status__c == 'Financial Approval 4'){
            gfrs.Financial_Reviewer3_Comments__c = Comments;
        } else if(gfrsRec.Status__c == 'Processing & Disposition'){
            gfrs.Financial_Reviewer_Comments__c = Comments;
            String decisiondocumentName = 'Decision_Flags_' + gfrsRec.Name;
            generatePDF(reqId,decisiondocumentName);
        }
        gfrs.id = reqId;
        try{
            UPDATE gfrs;
        } catch(Exception e) {
            throw new AuraHandledException(e.getLineNumber()+':'+e.getMessage());
        }  
    }
    
    @AuraEnabled
    public static void updateComplianceFlag(Id reqId,String manualResol,String noteinput1,String noteinput2,String noteinput3,String noteinput4,String noteinput5,String noteinput6,String noteinput7,String noteinput8,String noteinput9,String noteinput11,String noteinput12,String noteinput13,String noteinput14,String noteinput15,String noteinput16,String noteinput17){
        gFRS_Ltng_Compliance_Flag__c gfrs = new gFRS_Ltng_Compliance_Flag__c();
        gfrs.Manual_Resolution__c = manualResol;
        gfrs.gFRS_No_Undue_Influ_Clinical_Pract_Notes__c = noteinput1;
        gfrs.gFRS_Org_Type_Individual_or_Group_Notes__c = noteinput2;
        gfrs.Organization_Ownership_Ind_OR_Grp_Notes__c = noteinput3;
        gfrs.gFRS_Org_Reputation_Blacklist_Notes__c = noteinput4;
        gfrs.gFRRS_Org_Type_Political_Sectarian_Notes__c = noteinput5;
        gfrs.No_Undue_Influence_General_Org_Support_N__c = noteinput6;
        gfrs.Broad_Audience_Not_Open_To_Public_Notes__c = noteinput7;
        gfrs.Promo_Material_Separated_from_CME_Notes__c = noteinput8;
        gfrs.Reach_of_the_Event_Program_Notes__c = noteinput9;
        gfrs.Organization_Type_Memberships_Notes__c= noteinput11;
        gfrs.Organization_Type_Field_Exhibits_Notes__c= noteinput12;
        gfrs.OrgType_Other_Notes__c= noteinput13;
        gfrs.Organization_Tax_Status_Notes__c= noteinput14;
        gfrs.gFRS_HCP_Aud_Mix_Lrn_not_US_based_Notes__c= noteinput15;
        gfrs.gFRS_Funding_Purp_Tgt_Aud_not_HCPs_Nts__c= noteinput16;
        gfrs.Organization_Type_Manually_Resolved_Note__c= noteinput17;
        gfrs.id = reqId;
        try{
            UPDATE gfrs;
        } catch(Exception e) {
            throw new AuraHandledException(e.getLineNumber()+':'+e.getMessage());
        }  
        
    }
    
    @AuraEnabled
    public static gFRS_Ltng_Application__c updateApplicationReqStatus(Id reqId,String status){
        gFRS_Ltng_Application__c singleApp = new gFRS_Ltng_Application__c(Id=reqId,Status__c=status);
        try{        
            update singleApp;    
        } catch(Exception e) {
            throw new AuraHandledException(e.getLineNumber()+':'+e.getMessage());
        }        
        return singleApp;
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
        Schema.DescribeFieldResult fieldResult = gFRS_Ltng_Application__c.Grant_Review_Committee__c.getDescribe();
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
    public static Map<String, String> getGNEValues(){
        Map<String, String> gneoptions = new Map<String, String>();
        //get Account Industry Field Describe
        Schema.DescribeFieldResult fieldResult = gFRS_Ltng_Application__c.Select_GNE_Alignment__c.getDescribe();
        //get Account Industry Picklist Values
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            //Put Picklist Value & Label in Map
            gneoptions.put(p.getValue(), p.getLabel());
        }
        return gneoptions;
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
    
    @AuraEnabled 
    public static Map<String, List<String>> getDependentMap(sObject objDetail, string contrfieldApiName,string depfieldApiName) {
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        Schema.sObjectType objType = objDetail.getSObjectType();
        if (objType == null){
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
    
    //ToDo Need to check where this method is being used
    @AuraEnabled
    public static string updateClosedStatus(Id recId){
        gFRS_Ltng_Application__c gfrs = new gFRS_Ltng_Application__c();
        gfrs.Status__c = 'Closed';
        gfrs.id = recId;        
        try{
            update gfrs;
        } catch(Exception e) {
            throw new AuraHandledException(e.getLineNumber()+':'+e.getMessage());
        }  
        return gfrs.Status__c;
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
        GFRS_Ltng_OrgSettings__c myOrgCS = GFRS_Ltng_OrgSettings__c.getOrgDefaults();
        if(myOrgCS.gFRS_Inbound_Email__c != null){
            String bccEmailAddress=myOrgCS.gFRS_Inbound_Email__c;
            tobCCddresses.add(bccEmailAddress.trim());
        }
        string str = '<'+RecId.left(9)+'@'+RecId.right(9)+'>';
        String reff = 'References: 1*'+str+' CRLF';
        
        email.setToAddresses(toAddresses);
        email.setCcAddresses(toccddresses);
        email.setBccAddresses(tobCCddresses);
        //email.setReplyTo('gene@f-21hve11zrrgw470vywnvee0df1zgfnzpckv1w20dy9rhauvy0k.3c-8z1juaq.cs60.apex.sandbox.salesforce.com');
        
        email.setReferences('References: 1*'+str+' CRLF');
        email.setSubject(Subject);
        
        //EmailBody.replaceAll('\n', '<br/>');
        EmailBody =EmailBody +'\n\n' + '[ref:' + RecId + ']';
        //email.setHtmlBody(EmailBody);
        
        email.setplainTextBody(EmailBody);
        //email.setTreatBodiesAsTemplate(true);
        
        //mail.setHtmlBody('Your case:<b> ' + case.Id +' </b>has been created.<p>'+'To view your case <a href=https://na1.salesforce.com/'+case.Id+'>click here.</a>');
        
        //email.setHtmlBody(EmailBody+'To contact us <a href=https://gfrsdev08-genentech-prod.cs60.force.com/gFRS/s/gfrs-contact-us>click here.</a>');
        
        try{
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });  
            if(results[0].success){/* Added code as part of defect fix ** Kiran */
                isSuccess = TRUE;
                /*try{
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
                    
                    //fileContent+=EncodingUtil.urlDecode(email.htmlbody.stripHtmlTags(),'UTF-8');
                    
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
                } */
            }else{
                isSuccess = FALSE;
            }
        } catch(Exception ex){
            isSuccess = FALSE;
        }
        return isSuccess;   
        
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
    public static void genPDF(Id reqId)
    {
        gFRS_Ltng_Compliance_Flag__c compReq = [Select Id,Manual_Resolution__c,No_Undue_Influence_Clinical_Practices__c,gFRS_No_Undue_Influ_Clinical_Pract_Notes__c,
                                                gFRS_Organization_Reputation_Blacklist__c,gFRS_Org_Reputation_Blacklist_Notes__c,OrgType_Charitable_Foundation_of_a_Group__c,gFRS_Org_Type_Individual_or_Group_Notes__c,Organization_Type_Poltical_Sec__c,gFRRS_Org_Type_Political_Sectarian_Notes__c,Organization_Ownership_Individual_OR_Gr__c,Organization_Ownership_Ind_OR_Grp_Notes__c,No_Undue_Influence_General_Org_Support__c,No_Undue_Influence_General_Org_Support_N__c,Broad_Audience_Not_Open_To_Public__c,Broad_Audience_Not_Open_To_Public_Notes__c,
                                                OrgType_Other__c,OrgType_Other_Notes__c,Promotional_Material_Separated_from_CME__c,Promo_Material_Separated_from_CME_Notes__c,Reach_of_the_Event_Program__c,Reach_of_the_Event_Program_Notes__c,Organization_Type_Memberships__c,Organization_Type_Memberships_Notes__c,Organization_Type_Field_Exhibits__c,Organization_Type_Field_Exhibits_Notes__c,Funding_Purpose_Target_audience_not_HCPs__c,gFRS_Funding_Purp_Tgt_Aud_not_HCPs_Nts__c,HCP_Audience_Mix_Learners_not_US_based__c,gFRS_HCP_Aud_Mix_Lrn_not_US_based_Notes__c from gFRS_Ltng_Compliance_Flag__c WHERE gFRS_Application__c =:reqId LIMIT 1];
        gFRS_Ltng_Application__c request = [Select Id,Name,RecordType.Name,Organization__r.Name,Event_Program_Type__c,Event_Program_Title__c,FPO_Reviewer_Decision_Date__c,Business_Approver_Decision_Date__c,Final_Approver_Decision_Date__c FROM gFRS_Ltng_Application__c WHERE  Id =:reqId ];            
        String image = compReq.gFRS_Organization_Reputation_Blacklist__c;
		String Notes = compReq.gFRS_Org_Reputation_Blacklist_Notes__c;
        if(String.isBlank(Notes)){
        	Notes = '';
        }
        String documentName = 'Compliance_Flags_Test';
        String FORM_HTML_START = '<HTML>'+'<BODY>';
        String FORM_HTML_BODY='<DIV>'+
            '<div>'+
            '<h1 style="font-weight: bold; font-size: 30px;color: #005A95;font-family:sans-serif">Genentech</h1>'+
            '<p style="color:#1e3e63; font-size:11px; letter-spacing: -0.5px;font-style: italic;font-family:sans-serif">A Member of the Roche Group</p>'+
            '</div>'+
            '<BR/>'+
            '<div>'+
            '<P>'+
            '<span>Request ID: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span>' +request.Name+'</span><br/>'+
            '</P>'+
            '<P>'+
            '<span>Funding Type Name: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span>'+request.RecordType.Name+'</span><br/>'+
            '</P>'+
            '<p>'+
            '<span>Organization Name: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span>'+request.Organization__r.Name+'</span>'+
            '</p>'+
            '<P>'+
            '<span>Event / Program Type: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span>'+request.Event_Program_Type__c+'</span>'+
            '</P>'+
            '<P>'+
            '<span>Event / Program Title: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span>'+request.Event_Program_Title__c+'</span>'+
            '</P>'+
            '<P>'+
            '<span>HC Compliance Date: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span>'+request.Business_Approver_Decision_Date__c+'</span>'+
            '</P>'+
            '<P>'+
            '<span>Decision Date: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span>'+request.Final_Approver_Decision_Date__c+'</span>'+
            '</P>'+
            
            '</div>'+
            '<BR/>'+
            '<div>'+
            '<h1 style="font-weight: bold; font-size: 14px;color: #000000;font-family:sans-serif">Compliance Flags</h1>'+
            '<BR/>'+
            '<p>'+
            '<span>No Undue Influence Clinical Practices &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span style="float:left">'+compReq.No_Undue_Influence_Clinical_Practices__c+'</span>'+
            '</p>'+
            '<BR/>'+
            '<P>'+
            '<span>Organization - Restricted Access/Exclusion List &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span>'+compReq.gFRS_Organization_Reputation_Blacklist__c+'</span><span>'+compReq.gFRS_Org_Reputation_Blacklist_Notes__c+'</span>'+
            '</P>'+
            '<BR/>'+
            '</div>'+
            '<div style="color:#1e3e63;font-size: 12px;">'+
            '<table style="border: 1px solid #000000;">'+
            	'<tr style="border: 1px solid black;">'+
                '<td style="width:150px; colspan="2";">'+'Organization - Restricted Access/Exclusion List'+'</td>'+
            	'<td style="width:10px;">'+compReq.gFRS_Organization_Reputation_Blacklist__c+'</td>'+
                '<td>'+compReq.gFRS_Org_Reputation_Blacklist_Notes__c+'</td>'+
                '</tr>'+
            	'<tr style="border: 1px solid black;">'+
                '<td style="width:150px;">'+'Organization - Restricted Access/Exclusion List'+'</td>'+
            	'<td style="width:10px;">'+'Organization - Restricted Access/Exclusion List'+'</td>'+
                '<td>'+'Organization - Restricted Access/Exclusion List'+'</td>'+
                '</tr>'+
			'</table>'+
            '</div>'+
            '<div>'+
            '<P>'+
            '<span style="font-weight: bold; font-size: 14px;color: #000000;font-family:sans-serif">Organization - Restricted Access/Exclusion List &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span style="float:left">'+compReq.gFRS_Organization_Reputation_Blacklist__c+'</span>'+
            '</P>'+
            '<BR/>'+
            '</div>'+
            '<div>'+
            '<P>'+
            '<span style="float:left">'+image+'</span><span>Organization - Restricted Access/Exclusion List</span>'+
            '</P>'+
            '<BR/>'+
            '</div>'+
            '<DIV>';
        String FORM_HTML_Compliance1='<DIV>'+
            '<P>'+
            '<span style="font-weight: bold; font-size: 14px;color: #000000;font-family:sans-serif">OrgType - Charitable Foundation of a Group Practice &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span><span style="float:left">'+compReq.OrgType_Charitable_Foundation_of_a_Group__c+'</span>'+
            '</P>'+
            '<DIV>';
        String FORM_HTML_Compliance='<DIV>'+
            '<DIV>'+
            '<P>'+
            '<SPAN>'+compReq.No_Undue_Influence_Clinical_Practices__c+'</SPAN><SPAN>No Undue Influence Clinical Practices</SPAN><br/>'+
            '<SPAN>'+compReq.gFRS_Organization_Reputation_Blacklist__c+'</SPAN><SPAN>gFRS Organization Reputation Blacklist</SPAN><br/>'+
            '<SPAN>'+compReq.OrgType_Charitable_Foundation_of_a_Group__c+'</SPAN><SPAN>OrgType Charitable Foundation of a Group</SPAN><br/>'+
            '<SPAN>'+compReq.Organization_Type_Poltical_Sec__c+'</SPAN><SPAN>Organization Type Poltical Sec</SPAN><br/>'+
            '<SPAN>'+compReq.Organization_Ownership_Individual_OR_Gr__c+'</SPAN><SPAN>Organization Ownership Individual OR Gr</SPAN><br/>'+
            '<SPAN>'+compReq.No_Undue_Influence_General_Org_Support__c+'</SPAN><SPAN>No Undue Influence General Org Support</SPAN><br/>'+
            '<SPAN>'+compReq.Broad_Audience_Not_Open_To_Public__c+'</SPAN><SPAN>Broad Audience Not Open To Public</SPAN><br/>'+
            '<SPAN>'+compReq.OrgType_Other__c+'</SPAN><SPAN>OrgType Other</SPAN><br/>'+
            '</P>'+
            '<DIV>'+
            '<DIV>';
        String FORM_HTML_END = '</BODY></HTML>';
        String pdfContent=FORM_HTML_START+FORM_HTML_BODY+FORM_HTML_END;
        
        Attachment attach1= new Attachment();
        attach1.ParentId = reqId;
        attach1.Name = documentName;
        attach1.Body = Blob.toPDF(pdfContent);//File content
        attach1.contentType = 'application/pdf';
        insert attach1;
        
        /*     //Insert ContentVersion
ContentVersion cVersion = new ContentVersion();
cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
cVersion.PathOnClient = documentName + '.pdf';//File name with extention
//cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
//cVersion.OwnerId = attach2.OwnerId;//Owner of the file
cVersion.Title = documentName + '.pdf';//Name of the file
cVersion.VersionData =  Blob.toPDF(pdfContent);//File content
Insert cVersion;

//After saved the Content Verison, get the ContentDocumentId
Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;

//Insert ContentDocumentLink
ContentDocumentLink cDocLink = new ContentDocumentLink();
cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
cDocLink.LinkedEntityId = reqId;//Add attachment parentId
//cDocLink.ShareType = 'I';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
//cDocLink.Visibility = 'InternalUsers';//AllUsers, InternalUsers, SharedUsers
Insert cDocLink;  */
    }
    
    @AuraEnabled
    public static Boolean activateBussinessUser(Id userId, string subStatus, string appId) 
    {
        Boolean isSuccess = false; 
        
        User bUser=[Select id,Isactive from User Where Id=:userId];
        
        if(!bUser.IsActive){
            
            bUser.IsActive=true;
            //update bUser;
            Database.SaveResult SR =Database.update(bUser);
            if(SR.isSuccess()){
                isSuccess=true;
            }
            
        }
        else if(bUser.IsActive)
        {
            
            isSuccess=true;
            
        }
        else{
            
            isSuccess=false;
        }
        
        if(isSuccess == true && (subStatus == 'Compliance Approver' || subStatus == 'Legal Review')){
            recordSharingWithApprover(userId, subStatus, appId);
        }
        
        return isSuccess;
    }
    
    @future
    public static void recordSharingWithApprover(Id userId, string subStatus, string appId){
        List<GFRS_Ltng_Application__Share> shrForBrAndBaApprovers = new List<GFRS_Ltng_Application__Share>();
        GFRS_Ltng_Application__Share shrFundingRequest = new GFRS_Ltng_Application__Share();
        shrFundingRequest.ParentId = appId;
        shrFundingRequest.UserOrGroupId = userId;
        shrFundingRequest.AccessLevel = 'Read';
        shrFundingRequest.RowCause = 'Manual';
        shrForBrAndBaApprovers.add(shrFundingRequest);  
        
        Database.SaveResult [] srList = gFRS_Ltng_Util_NoShare.insertSharingRecs(shrForBrAndBaApprovers);
    }
    
    @AuraEnabled
    public static gFRS_Ltng_CAF_Application__c fetchCAFComplianceFlag(Id reqId){
        return [select Id,Manual_Resolution__c,Internal_Sub_Status__c,No_Undue_Influence_Clinical_Practices__c,No_Undue_Influence_Clinical_Pract_Notes__c,Organization_Reputation_Blacklist__c,Org_Reputation_Blacklist_Notes__c,OrgType_Charitable_Foundation_of_a_Group__c, OrgType_Charitable_Foundation_Notes__c,Organization_Type_Poltical_Sec__c,Org_Type_Political_Sectarian_Notes__c,Application_Acknowledgment__c,Application_Acknowledgment_Notes__c,Organization_Tax_Status__c,Organization_Tax_Status_Notes__c,Organization_Favorable_OIG_Opinion_Notes__c from gFRS_Ltng_CAF_Application__c where  Id=:reqId LIMIT 1];
    }
    @AuraEnabled
    public static void updateCAFComplianceFlag(Id reqId,String manualResol,String noteinput1,String noteinput2,String noteinput3,String noteinput4,String noteinput5,String noteinput6){
        gFRS_Ltng_CAF_Application__c gfrs = new gFRS_Ltng_CAF_Application__c();
        gfrs.Manual_Resolution__c = manualResol;
        gfrs.No_Undue_Influence_Clinical_Pract_Notes__c = noteinput1;
        gfrs.Org_Reputation_Blacklist_Notes__c = noteinput2;
        gfrs.OrgType_Charitable_Foundation_Notes__c = noteinput3;
        gfrs.Org_Type_Political_Sectarian_Notes__c = noteinput4;
        gfrs.Application_Acknowledgment_Notes__c = noteinput5;
        gfrs.Organization_Tax_Status_Notes__c = noteinput6;
        gfrs.id = reqId;
        try{
            UPDATE gfrs;
        } catch(Exception e) {
            throw new AuraHandledException(e.getLineNumber()+':'+e.getMessage());
        }  
    }
    
    @AuraEnabled 
    public static Map<String,List<String>> getRecTypePicklistValues( String objectName, string fieldName, string RecordTypeId ) {
        
        System.debug( 'objectName : ' + objectName );
        System.debug( 'fieldName : ' + fieldName );
        System.debug( 'RecordTypeId : ' + RecordTypeId );
        
        if(String.isBlank( objectName) || String.isBlank(fieldName)){
            return null;
        }
        
        //String recordTypeId;
        //if( !String.isBlank( recordTypeName ) ){
          //  recordTypeId = Schema.getGlobalDescribe().get( objectName ).getDescribe().getRecordTypeInfosByDeveloperName().get( recordTypeName ).getRecordTypeId();
        //}
        if( recordTypeId == null || recordTypeId == '' ){
            recordTypeId = Schema.getGlobalDescribe().get( objectName ).getDescribe().getRecordTypeInfosByDeveloperName().get( 'Master' ).getRecordTypeId(); 
        }
      
        Map<String, List<String>> mapPicklistValues = new Map<String, List<String>>();
        
        mapPicklistValues = getValues( objectName, recordTypeId, fieldName );
        
        return mapPicklistValues;
    }
    

    public static Map<String, List<String>> getValues(String objectType, String recordTypeId, String fieldName) {
        
        // Create the endpoint dynamically for your og
        String Endpoint = URL.getSalesforceBaseUrl().toExternalForm();      
        endpoint += '/services/data/v45.0';
        endpoint += '/ui-api/object-info/' + objectType + '/picklist-values/' + recordTypeId + '/' + fieldName;
        
        
        EncodingUtil.urlEncode(endpoint,'UTF-8');
        
        // Call the API in order to get the values 
        HttpRequest req = new HttpRequest();
        
        // Since, we can not use the UserInfo.getSessionId() method here, I am using a Visualforce page in order
        // to extract the session id which we can use for making API calls
        //req.setHeader('Authorization', 'OAuth ' + getSessionIdFromVFPage(Page.SessionId)); 
        req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId()); 
        req.setHeader('Accept', 'application/json '); 
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        Http http = new Http();
        
        HTTPResponse res = http.send(req);
        Map<String, String> result = new Map<String,String>();
        Map<String, List<String>> mapControllingWithDependentList = new Map<String,List<String>>();
        Map<Object, String> mapControllingValueWithIndex = new Map<Object,String>();
        Map<String, List<String>> mapPicklistValues = new Map<String,List<String>>();
        
        // Parse the response and build the dependent and controlling picklist values map
        if( res.getStatus() == 'OK' && res.getStatusCode() == 200 ) {
            
            Map<String,Object> root = (Map<String,Object>) JSON.deserializeUntyped( res.getBody() );
            
            System.debug( ' Response Body : ' + res.getBody() );
            
            
            // Get all the controlling values from response 
            if( root.containsKey('controllerValues') ) {
                
                Map<String, Object> controllingValues = (Map<String, Object>) root.get( 'controllerValues' );
               
                // Map of all the controlling values with their index 
                for( String cValue: controllingValues.keySet() ) {
                    
                    mapControllingValueWithIndex.put( controllingValues.get(cValue), cValue );
                }
            }
            
            System.debug('mapControllingValueWithIndex : ' + JSON.serializePretty( mapControllingValueWithIndex ) );
            
            if( !root.containsKey( 'values' ) ){ 
                
                return mapControllingWithDependentList; 
            }
            
            // Get all the dependent values from the response returned with the Validfor attribute
            // Each bit in the bitmap indicates whether this dependent picklist value is "valid for" a corresponding controlling field value
            // The value in the validFor member is a Base64-encoded bitmap. 
            List<Object> pValues = (List<Object>) root.get( 'values' );
            for(Object pValue : pValues) {
                
                Map<String,Object> pValueMap = (Map<String,Object>)pValue;
                result.put( (String) pValueMap.get('value'), (String) pValueMap.get('label') );
                
                for(Object validfor : (List<Object>)pValueMap.get('validFor')) {
                    
                    //Map the dependent Values List with their Controlling Value 
                    if( mapControllingValueWithIndex.containsKey( validfor ) ) {
                        
                        if( !mapControllingWithDependentList.containsKey( mapControllingValueWithIndex.get( validfor ) ) ) {
                            
                            mapControllingWithDependentList.put( mapControllingValueWithIndex.get( validfor ), new List<String>() );
                        }
                        
                        mapControllingWithDependentList.get( mapControllingValueWithIndex.get( validfor ) ).add( (String) pValueMap.get( 'label' ) );    
                    }
                }                
            }
            
            System.debug( 'mapControllingWithDependentList : ' + JSON.serializePretty( mapControllingWithDependentList ) );
            
            //Map all the controlling values 
            for( String controllingFields : mapControllingValueWithIndex.Values() ){
                //Map controllingFields which has no dependent values associated to it
                if( !mapPicklistValues.containsKey( controllingFields ) ) {
                    
                    mapPicklistValues.put(controllingFields,new List<String>());
                }
                //Map controllingFields which has dependent values associated to it
                if(mapPicklistValues.containsKey( controllingFields ) && 
                   mapControllingWithDependentList.containsKey( controllingFields ) ) {
                    
                    mapPicklistValues.get( controllingFields ).addAll( mapControllingWithDependentList.get( controllingFields ) );
                } 
            }            
        }
        else{
            
             System.debug( 'mapPicklistValues : ' + JSON.serializePretty( mapPicklistValues ) );
        }
        
        //Return the Map of Controlling fields with the List of Dependent fields on the basis of Record Types
        System.debug( 'mapPicklistValues : ' + JSON.serializePretty( mapPicklistValues ) );
        
        return mapPicklistValues;
        
    }
    
    
     public static String getSessionIdFromVFPage( PageReference visualforcePage ) {
         
        if( !Test.isRunningTest() ) {
            
            String sessionId = visualforcePage.getContent().toString();
            return sessionId;
        }
         
        return UserInfo.getSessionId();
         
    }
    
    
    // Added code for Payment Process
    
    
    @AuraEnabled
    Public static gFRS_Ltng_App_Funding_Allocation__c getfundAllocationData(Id applicationId){
        gFRS_Ltng_App_Funding_Allocation__c fundAlclst = [SELECT Id,Name,Approved_Amount__c,Payment_Amounts__c,Payment_Type__c,Multiple_payments_associated_with_Rqst__c,gFRS_Application__r.Name,Record_Type_Name__c,Funding_Total__c,gFRS_GL_Account__c
                                                                FROM gFRS_Ltng_App_Funding_Allocation__c Where gFRS_Application__c=:applicationId and Auto_Process_Check__c=true LIMIT 1];
        return fundAlclst;
    }
    
    @AuraEnabled
    Public static List<gFRS_Ltng_Funding_Allocation_Line_Item__c> getfundAllocationlineData(Id applicationId){
        
        gFRS_Ltng_App_Funding_Allocation__c fundAlclst = [SELECT Id,Name,Approved_Amount__c,Payment_Amounts__c,Payment_Type__c,Multiple_payments_associated_with_Rqst__c,gFRS_Application__r.Name,Record_Type_Name__c,Funding_Total__c
                                                          FROM gFRS_Ltng_App_Funding_Allocation__c Where gFRS_Application__c=:applicationId and Auto_Process_Check__c=true LIMIT 1];
        
        if(fundAlclst != null){
        	List<gFRS_Ltng_Funding_Allocation_Line_Item__c> fundAlclinelst = [Select id, name,Cost_Center_Code__c,Cost_Center_Description__c,WBS_Code__c,WBS_Description__c,gFRS_Funding_Allocation__c,Amount__c, Commercial_Activity_ID__c, Percent__c,gFRS_Funding_Allocation__r.gFRS_Application__c,gFRS_Funding_Allocation__r.gFRS_GL_Account__c
                                                                          From gFRS_Ltng_Funding_Allocation_Line_Item__c Where gFRS_Funding_Allocation__c=:fundAlclst.Id];
            return fundAlclinelst;    
        }else{
            return null;
        }
    }
    
    @AuraEnabled
    public static void updateFundAlcRecd(gFRS_Ltng_App_Funding_Allocation__c upFundAc){
        System.debug('@@@@'+upFundAc);
        try{
            upsert upFundAc;
        }
        catch(Exception e) {
            throw new AuraHandledException(e.getLineNumber()+':'+e.getMessage());
        }  
        
    }
    @AuraEnabled
    public static List<gFRS_Ltng_Funding_Allocation_Line_Item__c> updateFundAlclineItems(List<gFRS_Ltng_Funding_Allocation_Line_Item__c> upReclst,
                                              List<gFRS_Ltng_Funding_Allocation_Line_Item__c> newReclst,
											  List<Id> delReclst,
                                              String appId,
                                              gFRS_Ltng_App_Funding_Allocation__c upFundAc){
        //System.debug('@@@@ appId'+appId);
        //update (new gFRS_Ltng_App_Funding_Allocation__c(Id = appId, Payment_Amounts__c = paymentAmt,
                                                        //Multiple_payments_associated_with_Rqst__c=mulitpt,Payment_Type__c=ptype ));
       
        System.debug('@@@@'+upFundAc);
       	upsert upFundAc;
        //update upFundAc;
         
        List<gFRS_Ltng_Funding_Allocation_Line_Item__c> newlst=new List<gFRS_Ltng_Funding_Allocation_Line_Item__c>();
        if(newReclst.size()>0)
        {
            
            for(gFRS_Ltng_Funding_Allocation_Line_Item__c chItem:newReclst){
                
                chItem.gFRS_Funding_Allocation__c = upFundAc.Id;
                newlst.add(chItem);  
            } 
            
        }
        
        
        Database.SaveResult[] upResults= Database.update(upReclst,false);
        Database.SaveResult[] inRresults= Database.insert(newlst,false);
        //Database.DeleteResult[] delResults=Database.delete(delReclst,false);
		delLineItems(delReclst);
            
        system.debug('@@@ Veera Debug upResults'+upResults);
        system.debug('@@@ Veera Debug inRresults'+inRresults);
		//system.debug('@@@ deleted Records '+delResults);
                                                  
		List<gFRS_Ltng_Funding_Allocation_Line_Item__c> fundAlclinelst = [Select id, name,Cost_Center_Code__c,Cost_Center_Description__c,WBS_Code__c,WBS_Description__c,gFRS_Funding_Allocation__c,Amount__c, Commercial_Activity_ID__c, Percent__c,gFRS_Funding_Allocation__r.gFRS_Application__c,gFRS_Funding_Allocation__r.gFRS_GL_Account__c
                                                                          From gFRS_Ltng_Funding_Allocation_Line_Item__c Where gFRS_Funding_Allocation__c=:upFundAc.Id];
        return fundAlclinelst; 
    }
    
    @AuraEnabled
    public static void delLineItems(List<Id> lstIds){
        
        SavePoint sp = Database.setSavepoint();
        try{
            
            Database.DeleteResult[] delResults=Database.delete(lstIds,false);
            system.debug('@@@ deleted Records '+delResults);
            
        }
        catch(Exception e){
            
            Database.rollback(sp);
            System.debug('@@@@'+e.getMessage());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
        
    }
    
    @AuraEnabled
    Public static String submitPaymenttoEBS(Id fundAlocId){ 
        
        /* Payment History */
        
        // Application Query
        
        
        
        // Funding Allocation 
                
        Organization org = [select IsSandbox from Organization ];
        GFRS_Ltng_OrgSettings__c myOrgCS = GFRS_Ltng_OrgSettings__c.getOrgDefaults();
        if(org.IsSandbox == true && myOrgCS.WS_SubmitGrant_Endpoint__c.contains('prd.roche.com')){
            system.debug('@@@ You can not submit payment as you are in Sandbox and the Grant Submit endpoint URL pointing to Production.');
            return '';
        } else {
            system.debug('@@@ Proceeding with Payment submission');
        }
        
       gFRS_Ltng_App_Funding_Allocation__c fundAlloc=[SELECT Id, Name, gFRS_Application__c, Approved_Amount__c, 
                                                       Check_Number__c, Payment_Amounts__c, Organization_Name__c,
                                                       Record_Type_Name__c, Baseline_Date__c FROM gFRS_Ltng_App_Funding_Allocation__c Where Id=:fundAlocId];
        
        
        gFRS_Ltng_Application__c gfrsApp=[Select Id,name ,Requested_Amount__c,Approved_Amount__c,Record_Type_Name__c,Vendor_Detail__r.Vendor_id__c,Attention_To__c,Partner_Bank_Type__c,Payment_Call_Counter__c,Event_Program_Title__c  From gFRS_Ltng_Application__c
                                          Where Id=:fundAlloc.gFRS_Application__c];
        
        // Funding Allocation Line Item
        
        List<gFRS_Ltng_Funding_Allocation_Line_Item__c> fundalcintem=[SELECT Id, Name,Line_Item_Total__c,Cost_Center_Code__c,WBS_Code__c, gFRS_Funding_Allocation__c, Amount__c, 
                                                                      Percent__c,WBS_Description__c, Cost_Center_Description__c,
                                                                      Are_there_multiple_payments_associated_w__c,
                                                                      Payment_Type__c FROM gFRS_Ltng_Funding_Allocation_Line_Item__c Where gFRS_Funding_Allocation__c=:fundAlloc.Id];
        
        //gFRS_Ltng_PaymentUtil.getGrantSubmitSplitLines( gfrsApp, fundalcintem );
        System.debug('@@@'+gfrsApp.Payment_Call_Counter__c);
        
        if(gfrsApp.Payment_Call_Counter__c==null){
            gfrsApp.Payment_Call_Counter__c=0;
        }
        
        
        gfrsApp.Payment_Call_Counter__c =  gfrsApp.Payment_Call_Counter__c+1;
        update (new gFRS_Ltng_Application__c(Id = gfrsApp.Id, Payment_Call_Counter__c = gfrsApp.Payment_Call_Counter__c ));
        
        String sapRequestId =gfrsApp.Name + '_' + gfrsApp.Payment_Call_Counter__c;
        
        Double paymentAmount =fundAlloc.Payment_Amounts__c;
        
        gFRS_Ltng_Payment_History__c paymentHistory=new gFRS_Ltng_Payment_History__c();
        paymentHistory.SAP_Request_ID__c= sapRequestId;
        paymentHistory.Date__c= date.today();
        paymentHistory.gFRS_Application__c= gfrsApp.Id;
        paymentHistory.gFRS_Funding_Allocation__c=fundAlloc.Id;
        paymentHistory.Amount__c= paymentAmount;
        paymentHistory.Payment_Type__c='Payment';
        paymentHistory.Action__c='Payment Sent';
        paymentHistory.RecordTypeId=[SELECT id FROM RecordType where DeveloperName='ReadOnly' and SobjectType='gFRS_Ltng_Payment_History__c'].id;
        paymentHistory.InvokeType__c='UI';
        paymentHistory.Status__c='Initialized';
        insert paymentHistory;
        
        gFRS_Ltng_PaymentUtil.sendltngFundingAllocationPaymentToESB(gfrsApp.Id,fundAlloc.id,paymentHistory.id);
        
        return paymentHistory.Id;
        
       
        
    }
    
    @AuraEnabled
    public static gFRS_Default_GL_Account_Info__mdt getDefaultGLAccBU(String recordType, Id allocRecordId){
        
        String recordTypeStr = '';
        if(recordType.length() > 40){
        	recordTypeStr = recordType.substring(0,40);
        }else{
            recordTypeStr = recordType;
        }
        gFRS_Default_GL_Account_Info__mdt defaultGLAccountInfo = new gFRS_Default_GL_Account_Info__mdt();
        
        recordTypeStr = recordTypeStr +'%';
        /*if(allocRecordId != null && allocRecordId != ''){
            gFRS_Ltng_App_Funding_Allocation__c fundingAllocation = [SELECT Id, gFRS_GL_Account__c FROM gFRS_Ltng_App_Funding_Allocation__c
                                                                    	Where Id =: allocRecordId];
            
            defaultGLAccountInfo.GL_Account_Id__c = fundingAllocation.gFRS_GL_Account__c; 
        }*/ 
        
            gFRS_Ltng_App_Funding_Allocation__c fundingAllocation = [SELECT Id, gFRS_GL_Account__c FROM gFRS_Ltng_App_Funding_Allocation__c
                                                                    	Where gFRS_Application__c =: allocRecordId];
        if(fundingAllocation.gFRS_GL_Account__c != null && fundingAllocation.gFRS_GL_Account__c != ''){
            defaultGLAccountInfo.GL_Account_Id__c = fundingAllocation.gFRS_GL_Account__c; 
        } else {
            defaultGLAccountInfo = [SELECT Id, Label, GL_Account__c, GL_Account_Id__c, Editable__c
                                                                      FROM gFRS_Default_GL_Account_Info__mdt 
                                                                      WHERE Label LIKE :recordTypeStr LIMIT 1];
            
            if(defaultGLAccountInfo != null){
                GFRS_GL_Account__c glAcc = [SELECT Id, Name, IsActive__c FROM GFRS_GL_Account__c WHERE Name =: defaultGLAccountInfo.GL_Account__c AND IsActive__c = TRUE LIMIT 1];    
                if(glAcc != null){
                    defaultGLAccountInfo.GL_Account_Id__c = glAcc.Id;    
                }else{
                    defaultGLAccountInfo = null;
                }            
            }        
        }
        return defaultGLAccountInfo;
        
    }
    
    @AuraEnabled
    public static gFRS_Default_GL_Account_Info__mdt getDefaultGLAcc(String recordType){
        
        String recordTypeStr = '';
        if(recordType.length() > 40){
        	recordTypeStr = recordType.substring(0,40);
        }else{
            recordTypeStr = recordType;
        }
        
        recordTypeStr = recordTypeStr +'%';
        gFRS_Default_GL_Account_Info__mdt defaultGLAccountInfo = [SELECT Id, Label, GL_Account__c, GL_Account_Id__c, Editable__c
                                                                    	FROM gFRS_Default_GL_Account_Info__mdt 
                                                                  		WHERE Label LIKE :recordTypeStr LIMIT 1];
  
        if(defaultGLAccountInfo != null){
        	GFRS_GL_Account__c glAcc = [SELECT Id, Name, IsActive__c FROM GFRS_GL_Account__c WHERE Name =: defaultGLAccountInfo.GL_Account__c AND IsActive__c = TRUE LIMIT 1];    
            if(glAcc != null){
            	defaultGLAccountInfo.GL_Account_Id__c = glAcc.Id;    
            }else{
                defaultGLAccountInfo = null;
            }            
        }        
        
        return defaultGLAccountInfo;
        
    }
    
    @AuraEnabled
    public static GFRS_Cost_Center_Code__c getCostCenterId(String CostCenterCode){
        
        //Id costCenterId = null;
        //GFRS_Cost_Center_Code__c costCenter;
        
        //if(string.isNotEmpty(CostCenterCode)){
        	GFRS_Cost_Center_Code__c costCenter = [SELECT Id,Name,Cost_Center_Description__c from GFRS_Cost_Center_Code__c WHERE Name =: CostCenterCode LIMIT 1];
        //}else{*/
          //  return [SELECT Id,Name,Cost_Center_Description__c from GFRS_Cost_Center_Code__c WHERE Id =: CostCenterCodeId LIMIT 1];
        //}
        /*if(costCenter != null){
        	costCenterId = costCenter.Id;  
        }*/
        
        return costCenter;
    }
    
    @AuraEnabled
    public static GFRS_Cost_Center_Code__c getCostCenterDetails(Id CostCenterId){
        
       	GFRS_Cost_Center_Code__c costCenter = [SELECT Id,Name,Cost_Center_Description__c from GFRS_Cost_Center_Code__c WHERE Id =: CostCenterId LIMIT 1];
        return costCenter;
    }
    
    @AuraEnabled
    public static GFRS_WBS_Codes__c getWBSDetails(Id WBSRecId){
        
       	GFRS_WBS_Codes__c WBSRec = [Select Id, name,WBS_Description__c From GFRS_WBS_Codes__c Where Id =: WBSRecId LIMIT 1];
            return WBSRec;
    }
    
    @AuraEnabled
    public static gFRS_Imed_Ds_Wbs_Mapping__c getWBSCode(String diseaseState){
        
        List<gFRS_Imed_Ds_Wbs_Mapping__c> WBSCode = new List<gFRS_Imed_Ds_Wbs_Mapping__c>();
        
        WBSCode = [SELECT Id, Disease_State__c, WBS_Code__c, Percent_Allocation__c from gFRS_Imed_Ds_Wbs_Mapping__c WHERE Disease_State__c =: diseaseState LIMIT 1];
        
        if(WBSCode.size() > 0){
            return WBSCode[0];
        } else {
            return null;
        }
        
    }    
    
    @AuraEnabled
    public static List<String> getAttachmentsIds(Id recordId) {
        List<string> attachemntList = new List<String>();
        try{
            for(Attachment att:[SELECT id FROM Attachment WHERE parentId =: recordId]){
                attachemntList.add(att.Id);
            }
            //LinkedEntityId = :arecordId];                       
            for (ContentDocumentLink nextCDL : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE  LinkedEntityId = :recordId]) { 
                //attachemntList.add(nextCDL.ContentDocumentId); 
            } 
           
            return attachemntList;
        }catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        } 
        
    }
    
    @AuraEnabled
    public static void saveFundingAlc(String appId, Decimal paymentAmount, String multiPayValue){

            gFRS_Ltng_App_Funding_Allocation__c fundAlc = [SELECT Id, Payment_Amounts__c, Multiple_payments_associated_with_Rqst__c, gFRS_Application__c
                                                                FROM gFRS_Ltng_App_Funding_Allocation__c Where gFRS_Application__c =: appId and Auto_Process_Check__c = true LIMIT 1];
            
            if(fundAlc != null){
                fundAlc.Payment_Amounts__c = paymentAmount;
                fundAlc.Multiple_payments_associated_with_Rqst__c = multiPayValue;                
                update fundAlc;     
            }
               
    }
    
    @AuraEnabled
    public static String validateCompanyCode(List<gFRS_Ltng_Funding_Allocation_Line_Item__c> lineItemList){
        
        String validationMsg = null;        
        Set<Id> costCenterIds = new Set<Id>();
        Set<Id> wbsCodeIds = new Set<Id>();
        Set<String> companyCodes = new Set<String>();
        
        for(gFRS_Ltng_Funding_Allocation_Line_Item__c lineItem : lineItemList){
        	costCenterIds.add(lineItem.Cost_Center_Code__c);
            wbsCodeIds.add(lineItem.WBS_Code__c);
        }
        
        Map<Id,GFRS_Cost_Center_Code__c> costCenterMap = New Map<Id,GFRS_Cost_Center_Code__c>([SELECT Id, Name, IsActive__c, SAP_Company_Code__c FROM GFRS_Cost_Center_Code__c WHERE Id in :costCenterIds]);
        Map<Id,GFRS_WBS_Codes__c> wbsCodeMap = New Map<Id,GFRS_WBS_Codes__c>([SELECT Id, Name, IsActive__c, SAP_Company_Code__c FROM GFRS_WBS_Codes__c WHERE Id in :wbsCodeIds]);
        
		for(gFRS_Ltng_Funding_Allocation_Line_Item__c lineItem : lineItemList )
        {
            
            if(costCenterMap.get(lineItem.Cost_Center_Code__c).IsActive__c != true){
                validationMsg = 'Cost Center ' + costCenterMap.get(lineItem.Cost_Center_Code__c).Name + ' is inactive. Please make sure the Cost Center is active.';
                return validationMsg;                
            }
            
            if(wbsCodeMap.get(lineItem.WBS_Code__c).IsActive__c  != true){
                validationMsg = 'WBS Code ' + wbsCodeMap.get(lineItem.WBS_Code__c).Name + ' is inactive. Please make sure the WBS Code is active.';
                return validationMsg;                
            }
            
            if(costCenterMap.get(lineItem.Cost_Center_Code__c).SAP_Company_Code__c != wbsCodeMap.get(lineItem.WBS_Code__c).SAP_Company_Code__c){
            	validationMsg = 'The Cost Center and WBS Code\'s company code do not match. Please make sure the Cost Center and WBS Code are correct.';
                return validationMsg;    
            }
            
            companyCodes.add(costCenterMap.get(lineItem.Cost_Center_Code__c).SAP_Company_Code__c);
            if(companyCodes.size() > 1){
                validationMsg = 'Payment allocation line items Cost Center Company Codes do not match. Please enter appropriate Cost Centers under the same Company Code.';
                return validationMsg;   
            }
        }
      
        return validationMsg;
        
    }
    
    @AuraEnabled
    public static Boolean isGlAccountActive(String glAccountId){
        
        Boolean isActiveAcc = False;
        
        if(glAccountId != null){
            GFRS_GL_Account__c glAcc = [SELECT Id, Name, IsActive__c FROM GFRS_GL_Account__c WHERE Id =: glAccountId];    
            if(glAcc != null && glAcc.IsActive__c == True){
                isActiveAcc = True;
            }           
        }        
        
        return isActiveAcc;        
    } 
    @AuraEnabled
    public static void reqUpdate(String req,String username,String field){
             gFRS_Ltng_Application__c gla=[SELECT Id,Fin_Approver_1__c,Fin_Approver_2__c,Fin_Approver_3__c,Fin_Approver_4__c FROM gFRS_Ltng_Application__c WHERE Id=:req];
        if(field=='FA1'){
            gla.Fin_Approver_1__c=username;
        }else if(field=='FA2'){
            gla.Fin_Approver_2__c=username;
        }else if(field=='FA3'){
            gla.Fin_Approver_3__c=username;
        }else if(field=='FA4'){
            gla.Fin_Approver_4__c=username;
        }
        update gla;
    }
    
    @AuraEnabled
    public static decimal getTotalApprovedAmount(Id orgId, Id appId){
        
        Date datobj;
        Decimal totalApprovedAmt = 0;
        List<gFRS_Ltng_Application__c> appList =new List<gFRS_Ltng_Application__c>();
        List<String> extFundType =new  List<String>();
        extFundType = new List<String>{'Community Giving','Independent Medical Education (CME)',
            'Patient and Health Focused Giving', 'Scientific and Research Focused Giving',
            'Education Focused Giving K-12','Education Focused Giving Graduate and Post-Graduate'};
                appList = [SELECT Id, Approved_Amount__c, Date_Submitted__c,Record_Type__c,Sub_Status__c FROM gFRS_Ltng_Application__c WHERE 
                           Organization__c =: orgId AND Id != :appId and ( Date_Submitted__c !=null) and (Sub_Status__c != 'Canceled' AND Sub_Status__c != 'Denied' AND Sub_Status__c != 'Not Submitted')];
        
        for(gFRS_Ltng_Application__c app : appList){
            system.debug('app.Approved_Amount__c'+app.Approved_Amount__c);                    
            if(app.Date_Submitted__c.year() == Date.today().year() && extFundType.contains(app.Record_Type__c)){
                    totalApprovedAmt +=  (app.Approved_Amount__c != null ? app.Approved_Amount__c : 0); 
            }            
        }
        system.debug('totalApprovedAmt'+totalApprovedAmt);
        return totalApprovedAmt;     
        
    }
    @AuraEnabled
    public static Boolean prodPaymentURLCheck(){
        Boolean check=false;
        Organization org = [select IsSandbox from Organization ];
        GFRS_Ltng_OrgSettings__c myOrgCS = GFRS_Ltng_OrgSettings__c.getOrgDefaults();
        if(org.IsSandbox == true && myOrgCS.WS_SubmitGrant_Endpoint__c.contains('prd.roche.com')){
            system.debug('@@@ You can not submit payment as you are in Sandbox and the Grant Submit endpoint URL pointing to Production.');
            check=true;
            return check;
        }else{
            check=false;
            return check;
        }
        
    }

    public class ApplicationInfo {
        @AuraEnabled
        public String profile {get; set;}
        @AuraEnabled
        public String userName {get; set;}
        @AuraEnabled
        public gFRS_Ltng_Application__c request {get; set;}
    }
}