public without sharing class gFRS_Ltng_preAppCntrl {
    
    @AuraEnabled
    public static homePageWrapper getProfileInfo(string fctype){
        try{
            String profileId = UserInfo.getProfileId();
            string currentView;            
            User  userRec = [SELECT Id, Name,Username,email FROM User WHERE Id =: userinfo.getUserId()];
            List<gFRS_Ltng_Pre_Application__c> preApps = new List<gFRS_Ltng_Pre_Application__c>();
            preApps = [SELECT Id, Name FROM gFRS_Ltng_Pre_Application__c WHERE createdbyId =: userinfo.getUserId() and Status__c = 'Invited to apply' and (Giving_Type__c = 'Foundation Undergraduate' or Giving_Type__c = 'Foundation Safety Net Support')];
            List<PermissionSetAssignment> permAssign = [SELECT Id, PermissionSetId, PermissionSet.Name, AssigneeId FROM PermissionSetAssignment WHERE AssigneeId =: userinfo.getUserId() and PermissionSet.Name = 'gFRS_Internal_To_External'];
            
            homePageWrapper hpWrapper=new homePageWrapper();
            hpWrapper.userRecord=userRec;
            if(permAssign.size() > 0){
                hpWrapper.externalPermSet = true;
            } else {
                hpWrapper.externalPermSet = false;
            }
            
            if(preApps.size() > 0){
                hpWrapper.enableFoundation = true;
            } else {
                hpWrapper.enableFoundation = false;
            }
            
            hpWrapper.Profile=[SELECT Id, Name FROM Profile WHERE Id =:profileId];
            if(hpWrapper.Profile.Name.Contains('external') || hpWrapper.Profile.Name.Contains('GNE-GFRS-External Applicant') || hpWrapper.Profile.Name.Contains('GNE-GFRS-External Requestor')){
                currentView='external';
            }else{
                currentView='internal';
                
            }
            if(fctype =='Genentech Inc'){
                if(currentView =='internal'){
                    hpWrapper.actionRequiredCount= [SELECT COUNT() from gFRS_Ltng_Task__c  
                                                    where ((gFRS_Application__r.ownerid=:userinfo.getUserId() AND Action_Type__c != 'Payment Method' AND Action_Type__c != 'Refund' AND Action_Type__c != 'Program Status' AND Action_Type__c != 'Letter of Agreement(LOA)')
                                                           OR (gFRS_Application__r.Accountable_Employee_Internal__c=:userinfo.getUserId() AND Action_Type__c = 'Program Status') 
                                                          OR gFRS_Application__r.Person_To_Whom_Payment_should_addressed__c =: userRec.email) 
                                                          AND (gFRS_Application__r.Record_Type_Name__c !='Foundation Safety Net Support' AND gFRS_Application__r.Record_Type_Name__c !='Foundation Undergraduate') 
                                                          AND Status__c != 'Completed'];
                    
                }else{
                    hpWrapper.actionRequiredCount= [select count() From gFRS_Ltng_Task__c where 
                                                    (
                                                        (gFRS_Application__r.ownerid=:userinfo.getUserId() AND Action_Type__c != 'Payment Method' AND Action_Type__c != 'Refund') 
                                                        OR (gFRS_Application__r.ownerid=:userinfo.getUserId() AND gFRS_Application__r.Record_Type__c != 'Field Exhibits' 
                                                        AND gFRS_Application__r.Record_Type__c != 'Corporate Memberships' AND gFRS_Application__r.Record_Type__c != 'Commercial Sponsorship' 
                                                        AND gFRS_Application__r.Record_Type__c != 'Non-Commercial Sponsorship' AND Action_Type__c = 'Refund')  
                                                        OR (gFRS_Application__r.Person_To_Whom_Payment_should_addressed__c =: userRec.email AND (Action_Type__c = 'Payment Method' OR Action_Type__c = 'Refund'))
                                                        OR (gFRS_Application__r.Email_Address__c =: userRec.email AND Action_Type__c = 'Letter of Agreement(LOA)'))
                                                        AND (gFRS_Application__r.Record_Type_Name__c !='Foundation Safety Net Support' 
                                                        AND gFRS_Application__r.Record_Type_Name__c !='Foundation Undergraduate') 
                                                        AND Status__c != 'Completed' ]; 
                hpWrapper.actionRequiredCountCAF= [select COUNT() From gFRS_CAF_Task__c where gFRS_CAF_Application__r.ownerid=:userinfo.getUserId() AND Status__c != 'Completed'];  
                hpWrapper.actionRequiredCount=hpWrapper.actionRequiredCount+hpWrapper.actionRequiredCountCAF;
                hpWrapper.actionRequiredCountRFPInvited=[SELECT COUNT() from gFRS_Ltng_Pre_Application__c Where ownerid=:userinfo.getUserId() and (Status__c = 'Invited to apply') and  Full_App_Submitted__c = 'No'  and (NOT Giving_Type__c LIKE '%Foundation%')];  
                hpWrapper.actionRequiredCount=hpWrapper.actionRequiredCount+hpWrapper.actionRequiredCountRFPInvited;
                }
                hpWrapper.draftCount=[SELECT COUNT() from gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId() and (Record_Type_Name__c !='Foundation Safety Net Support' and Record_Type_Name__c !='Foundation Undergraduate') and (Sub_Status__c = 'Not Submitted'and (Event_Program_Title__c!=null and (Preapplication__c = null or (Preapplication__c != null and Preapplication__r.Preapptoappcreatecheck__c = true and Selected_Tab_Val__c != null))) )];
                hpWrapper.draftCountCAF=[SELECT COUNT() from gFRS_Ltng_CAF_Application__c Where ownerid=:userinfo.getUserId() and Internal_Sub_Status__c = 'Not Submitted'];
                hpWrapper.draftCount= hpWrapper.draftCount+hpWrapper.draftCountCAF;
                hpWrapper.underReviewCount=[SELECT COUNT() FROM gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId() and (Record_Type_Name__c !='Foundation Safety Net Support' and  Record_Type_Name__c !='Foundation Undergraduate') and (Status__c = 'Compliance' OR Status__c = 'Decision') and(Sub_Status__c!='RFI Sent')];
                hpWrapper.underReviewCountCAF=[SELECT COUNT() FROM gFRS_Ltng_CAF_Application__c Where ownerid=:userinfo.getUserId() and (Status__c = 'Compliance' OR Status__c = 'Decision')];
                hpWrapper.underReviewCount=hpWrapper.underReviewCount+hpWrapper.underReviewCountCAF;
                hpWrapper.draftCountRFP=[SELECT COUNT() from gFRS_Ltng_Pre_Application__c Where ownerid=:userinfo.getUserId() and Status__c='Draft' and ( NOT Giving_Type__c LIKE '%Foundation%')];
                hpWrapper.draftCount= hpWrapper.draftCount+hpWrapper.draftCountRFP;
                system.debug('userinfo.getUserId()'+userinfo.getUserId());
            }else if(fctype =='Genentech Foundation'){
                hpWrapper.actionRequiredCount= [SELECT COUNT() from gFRS_Ltng_Task__c where ((gFRS_Application__r.ownerid=:userinfo.getUserId() AND Action_Type__c != 'Payment Method') OR gFRS_Application__r.Person_To_Whom_Payment_should_addressed__c =: userRec.email) AND (gFRS_Application__r.Record_Type_Name__c ='Foundation Safety Net Support' OR gFRS_Application__r.Record_Type_Name__c ='Foundation Undergraduate') AND Status__c != 'Completed'];
                hpWrapper.draftCount=[SELECT COUNT() from gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId() and (Record_Type_Name__c ='Foundation Safety Net Support' or Record_Type_Name__c ='Foundation Undergraduate') and (Sub_Status__c = 'Not Submitted'and (Event_Program_Title__c!=null and Selected_Tab_Val__c != null) )];
                hpWrapper.underReviewCount=[SELECT COUNT() FROM gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId() and (Record_Type_Name__c ='Foundation Safety Net Support' or Record_Type_Name__c ='Foundation Undergraduate') and (Status__c = 'Compliance' OR Status__c = 'Decision') and(Sub_Status__c!='RFI Sent')];
                hpWrapper.draftCountRFP=[SELECT COUNT() from gFRS_Ltng_Pre_Application__c Where ownerid=:userinfo.getUserId() and Status__c='Draft' and (Giving_Type__c LIKE '%Foundation%')];
                hpWrapper.draftCount= hpWrapper.draftCount+hpWrapper.draftCountRFP;
                hpWrapper.actionRequiredCountRFPInvited=[SELECT COUNT() from gFRS_Ltng_Pre_Application__c Where ownerid=:userinfo.getUserId() and (Status__c = 'Invited to apply') and  Full_App_Submitted__c = 'No' and Giving_Type__c LIKE '%Foundation%'];  
                hpWrapper.actionRequiredCount=hpWrapper.actionRequiredCount+hpWrapper.actionRequiredCountRFPInvited;
            }
            
            return hpWrapper;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage()); 
        }
    }      
    public class  homePageWrapper{
        @AuraEnabled
        public Profile Profile {get;set;}
        @AuraEnabled
        public User userRecord {get;set;}
        @AuraEnabled
        public Integer actionRequiredCount {get;set;}
        @AuraEnabled
        public Integer actionRequiredCountCAF {get;set;}
        @AuraEnabled
        public Integer actionRequiredCountRFPInvited {get;set;}
        @AuraEnabled
        public Integer draftCount {get;set;}
        @AuraEnabled
        public Integer draftCountCAF{get;set;}
        @AuraEnabled
        public Integer underReviewCount {get;set;}
         @AuraEnabled
        public Integer underReviewCountCAF {get;set;}
        @AuraEnabled
        public Boolean enableFoundation {get;set;}
        @AuraEnabled
        public Boolean externalPermSet {get;set;}
        @AuraEnabled
        public Integer draftCountRFP{get;set;}
    }
    @AuraEnabled
    public static map<String,String> 
        ActiveTitleList() {
            map<String,String> CGN_List=new map<String,String>();
            try{
                List<gFRS_CGN_PLNG_Bulk_Email__c> CGN_Title_List = [SELECT id,CGN_PLNG_Status__c,CGN_PLNG_Title__c,Survey_Link__c,invitationId__c FROM gFRS_CGN_PLNG_Bulk_Email__c where CGN_PLNG_Status__c = true]; //
                CGN_List.put('None','None');
                for(gFRS_CGN_PLNG_Bulk_Email__c gFRS_CGN:CGN_Title_List){
                    CGN_List.put(gFRS_CGN.Id,gFRS_CGN.CGN_PLNG_Title__c);
                }
                
                return CGN_List;
            }catch(Exception e){
                AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
                throw auraExceptionObj;              
            }
            
        }
    @AuraEnabled
    public static userCGNWrapper getCGN(String grantName) {
        
        try{
            User userRecord = [SELECT Id, Contact.Id,Contact.AccountId, Contact.Account.Id, Contact.Account.Name, Contact.gFRS_Organization2__c, Contact.gFRS_Organization2__r.Country__c,Contact.gFRS_Organization2__r.Tax_Id__c,Contact.gFRS_Organization2__r.Organization_Name__c FROM User WHERE Id = :userinfo.getuserid()];
            gFRS_CGN_PLNG_Bulk_Email__c cgnRecord = [SELECT Id,Start_date_Validation__c,CGN_PLNG_Status__c,CGN_PLNG_Title__c,Giving_Priorities_Alignment__c,Survey_Link__c,invitationId__c,Users_to_whom_email_sent__c,Do_you_need_custom_questions__c,standquestion1__c,standquestion2__c,standquestion3__c,standquestion4__c,standquestion5__c,standquestion6__c,ProgramStartDateCheck__c,ProgramEndDateCheck__c,Event_Program_Origin__c,Briefly_describe_the_intended_audience__c,Event_Program_Origin_SRFG__c,Briefly_describe_intended_audience_SRFG__c,Event_Program_Origin_EFG__c,Briefly_describe_intended_audience_EFG__c,Event_Program_Origin_CG__c,Briefly_describe_intended_audience_CG__c,Event_Program_Origin_CME__c,Briefly_describe_intended_audience_CME__c,Sample_Question_Picklist_Multi_SRFG__c,Sample_Question_Radio_SRFG__c,phfgtext4__c,phfgtext5__c,phfgtext6__c,phfgtext7__c,phfgtext8__c,phfgtext9__c,phfgtext10__c,srfgtext4__c,srfgtext5__c,srfgtext6__c,srfgtext7__c,srfgtext8__c,srfgtext9__c,srfgtext10__c,cmetext7__c,cmetext8__c,cmetext9__c,cmetext10__c,cmetext11__c,cmetext12__c,efgtext1__c,efgtext2__c,efgtext3__c,efgtext4__c,efgtext5__c,efgtext6__c,efgtext7__c,efgtext8__c,efgtext9__c,efgtext10__c,cgtext1__c,cgtext2__c,cgtext3__c,cgtext4__c,cgtext5__c,cgtext6__c,cgtext7__c,cgtext8__c,cgtext9__c,cgtext10__c,foundtext1__c,foundtext2__c,foundtext3__c,foundtext4__c,foundtext5__c,foundtext6__c,foundtext7__c,foundtext8__c,foundtext9__c,foundtext10__c FROM gFRS_CGN_PLNG_Bulk_Email__c where CGN_PLNG_Title__c=:grantName];
            
            userCGNWrapper userCgnWrap = new userCGNWrapper();
            userCgnWrap.userRec = userRecord;
            userCgnWrap.CgnRec = cgnRecord;
            
            return userCgnWrap;
        }catch(Exception e){
            system.debug('@@@:::'+e.getMessage());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
        
    }
    
    @AuraEnabled
    public static User getUser() {
        
        try{
            User userRecord = [SELECT Id, Contact.Id,Contact.AccountId, Contact.Account.Id, Contact.Account.Name, Contact.gFRS_Organization2__c, Contact.gFRS_Organization2__r.Country__c,Contact.gFRS_Organization2__r.Tax_Id__c,Contact.gFRS_Organization2__r.Organization_Name__c FROM User WHERE Id = :userinfo.getuserid()];
            
            return userRecord;
        }catch(Exception e){
            system.debug('@@@:::'+e.getMessage());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
        
    }    
    
    public class userCGNWrapper {
        
        @AuraEnabled
        public User userRec {get;set;}
        @AuraEnabled
        public gFRS_CGN_PLNG_Bulk_Email__c CgnRec {get;set;}
    }    
    
    @AuraEnabled
    public static List<ContentDocument> getContentDocs(Id arecordId) {
        try{
            List<ContentDocumentLink> CDLs = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :arecordId];
            if (CDLs.size() < 1) {
                return new List<ContentDocument>();
            }
            List<Id> CDIdList = new List<Id> (); 
            for (ContentDocumentLink nextCDL : CDLs) { 
                CDIdList.add(nextCDL.ContentDocumentId); 
            } 
            List<ContentDocument> entries = [SELECT id,Title,FileType,CreatedBy.Name,ContentSize FROM ContentDocument WHERE Id IN :CDIdList]; 
            system.debug('entries'+entries);
            return entries;
        }catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
        
    }
    @AuraEnabled    
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType) {
        try{
            base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
            
            Attachment oAttachment = new Attachment();
            oAttachment.parentId = parentId;
            
            oAttachment.Body = EncodingUtil.base64Decode(base64Data);
            oAttachment.Name = fileName;
            oAttachment.ContentType = contentType;
            
            insert oAttachment;
            system.debug('oAttachment'+oAttachment);
            return oAttachment.Id;
        }catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
        
        
    }
    
    @AuraEnabled
    public static Id postsaveChunk1(Id parentId, String fileName, String base64Data, String contentType, String fileId, string ext){
        try{          
            system.debug('@@@ in save chunk');
            if (fileId == '') {
                fileId = saveTheFile(parentId, fileName, base64Data, contentType);
            } else {
                appendToFile(fileId, base64Data);
            }
            if(fileId != null){
                /*   gFRS_Ltng_Task_Update__c objBudget = [Select id,Scope_Attachment__c From gFRS_Ltng_Task_Update__c where id=: parentId];

objBudget.id = parentId;
objBudget.Scope_Attachment__c = Id.valueOf(fileId);                
objBudget.Scope_Attachment_File_Name__c  = fileName;
objBudget.Scope_Attachment_File_Type__c  = ext;
upsert objBudget;
*/
            }
            return Id.valueOf(fileId);
        }catch(Exception e){
            System.debug('@@@@ Upload chunk Error :'+e.getMessage());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
    }
    
    
    
    @AuraEnabled
    public static Id saveChunk(Id parentId, String fileName,String cgnId, String base64Data, String contentType, String fileId,string ext,String att) {
        try{
            if(cgnId !=null && cgnId!=''){
                system.debug('cgnId'+cgnId);
                gFRS_Ltng_Pre_Application__c lp=[select id,CGN_PLNG_Title__c,Giving_Priorities_Alignment__c from gFRS_Ltng_Pre_Application__c where id=:parentId];
                lp.CGN_PLNG_Title__c=cgnId;
                gFRS_CGN_PLNG_Bulk_Email__c CGNRec=[select id,Giving_Priorities_Alignment__c from gFRS_CGN_PLNG_Bulk_Email__c where id=:cgnId];
                lp.Giving_Priorities_Alignment__c = CGNRec.Giving_Priorities_Alignment__c;
                system.debug('lp.Giving_Priorities_Alignment__c'+lp.Giving_Priorities_Alignment__c);
                update lp;
            }
            
            if (fileId == '') {
                fileId = saveTheFile(parentId, fileName, base64Data, contentType);
            } else {
                appendToFile(fileId, base64Data);
            }
            /*
if(att=='Scope'){
gFRS_Ltng_Task_Update__c objBudget = [Select id,Scope_Attachment__c From gFRS_Ltng_Task_Update__c where id=: parentId];

objBudget.id = parentId;
objBudget.Scope_Attachment__c = Id.valueOf(fileId);                
objBudget.Scope_Attachment_File_Name__c  = fileName;
objBudget.Scope_Attachment_File_Type__c  = ext;
upsert objBudget;
}
if(att=='upload1'){
gFRS_Ltng_Task_Update__c objBudget = [Select id,Outcome1_Attach_Id__c,Outcome1_Attach_Name__c,Outcome1_Attach_Type__c From gFRS_Ltng_Task_Update__c where id=: parentId];

objBudget.id = parentId;
objBudget.Outcome1_Attach_Id__c = Id.valueOf(fileId);                
objBudget.Outcome1_Attach_Name__c  = fileName;
objBudget.Outcome1_Attach_Type__c  = ext;
upsert objBudget;
}
if(att=='upload2'){
gFRS_Ltng_Task_Update__c objBudget = [Select id,Outcome2_Attach_Id__c,Outcome2_Attach_Name__c,Outcome2_Attach_Type__c From gFRS_Ltng_Task_Update__c where id=: parentId];

objBudget.id = parentId;
objBudget.Outcome2_Attach_Id__c= Id.valueOf(fileId);                
objBudget.Outcome2_Attach_Name__c  = fileName;
objBudget.Outcome2_Attach_Type__c  = ext;
upsert objBudget;
}
if(att=='upload3'){
gFRS_Ltng_Task_Update__c objBudget = [Select id,Outcome3_Attach_Id__c,Outcome3_Attach_Name__c,Outcome3_Attach_Type__c From gFRS_Ltng_Task_Update__c where id=: parentId];

objBudget.id = parentId;
objBudget.Outcome3_Attach_Id__c = Id.valueOf(fileId);                
objBudget.Outcome3_Attach_Name__c  = fileName;
objBudget.Outcome3_Attach_Type__c  = ext;
upsert objBudget;
}
if(att=='upload4'){
gFRS_Ltng_Task_Update__c objBudget = [Select id,Outcome4_Attach_Id__c,Outcome4_Attach_Name__c,Outcome4_Attach_Type__c From gFRS_Ltng_Task_Update__c where id=: parentId];

objBudget.id = parentId;
objBudget.Outcome4_Attach_Id__c = Id.valueOf(fileId);                
objBudget.Outcome4_Attach_Name__c  = fileName;
objBudget.Outcome4_Attach_Type__c  = ext;
upsert objBudget;
}*/
            return Id.valueOf(fileId);
        }catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
    }
    private static void appendToFile(Id fileId, String base64Data) {
        try{
            base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
            
            Attachment a = [
                SELECT Id, Body
                FROM Attachment
                WHERE Id =: fileId
            ];
            
            String existingBody = EncodingUtil.base64Encode(a.Body);
            
            a.Body = EncodingUtil.base64Decode(existingBody + base64Data);
            
            update a;
        }catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
    }
    
    /*    @AuraEnabled
public static Boolean checkSurevyResponse(Id recId){

try{
Boolean checkSurvey;
gFRS_Ltng_Pre_Application__c preAppRec=[Select id,Name,Email__c From gFRS_Ltng_Pre_Application__c Where Id=:recId];
//System.debug('@@@ Pre App Name'+preAppRec.Name);
List<SurveyQuestionResponse> surResp2=[SELECT Id, ResponseShortText, ResponseId, ResponseValue,ChoiceValue,QuestionId FROM SurveyQuestionResponse Where ResponseShortText=:preAppRec.Name];

if(surResp2.size()>0){
checkSurvey=true;
}
else{
checkSurvey=false;
//system.debug('@@ Survey response'+checkSurvey);
}        
return checkSurvey; 
}
catch(Exception e){
AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
throw auraExceptionObj;              
}
} */
    @AuraEnabled
    public static gFRS_Ltng_Organization__c getOrgTaxDetails(string taxId){
        gFRS_Ltng_Organization__c org;
        try{
            org=[select Id,Name,Tax_Id__c from gFRS_Ltng_Organization__c where Tax_Id__c =:taxId];
            return org;  
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage()); 
        }
    } 
    @AuraEnabled
    public static List <gFRS_Ltng_Application__c> fetchReq() {
        
        List<gFRS_Ltng_Application__c> subList=[SELECT Name,Status__c,External_Status__c,Organization__c,Sub_Status__c,Event_Program_Title__c,Requested_Amount__c,Approved_Amount__c from gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId() and Status__c != 'Intake'];
        //return list of accounts
        
        return subList;
    }
    @AuraEnabled
    public static gFRS_Ltng_Application__c fetchAppReq(String appId) {
        try{
            return [SELECT Name,Email_Address__c,Status__c,External_Status__c,Organization__c,Sub_Status__c,Event_Program_Title__c,Requested_Amount__c,Approved_Amount__c from gFRS_Ltng_Application__c where Id=:appId];
        }
        catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }        
    }
    @AuraEnabled
    public static List <gFRS_Ltng_Task__c> fetchTask(string fctype) {
        List<gFRS_Ltng_Task__c> taskList;
        User userRec = [SELECT Id, Name, email FROM User WHERE Id =: userinfo.getUserId()];
        
        if(fctype =='Genentech Inc'){
            taskList = [select Id,Name, Action_Type__c,lastmodifieddate,Start_Date__c,Status__c,Description__c,CreatedDate,gFRS_Application__c,gFRS_Application__r.Name,gFRS_Application__r.First_Name__c,gFRS_Application__r.Last_Name__c,gFRS_Application__r.Information_Needed__c,gFRS_Application__r.Event_Program_Title__c,gFRS_Application__r.Record_Type_Name__c,gFRS_Application__r.Email_Address__c,gFRS_Application__r.Authorized_Signer__c,gFRS_Application__r.Program_Start_Date_Min__c,gFRS_Application__r.Organization__r.Organization_Name__c, 
                       gFRS_Application__r.Program_End_Date_max__c From gFRS_Ltng_Task__c where 
                        (
                            (gFRS_Application__r.ownerid=:userinfo.getUserId() AND Action_Type__c != 'Payment Method' AND Action_Type__c != 'Refund' AND Action_Type__c != 'Program Status') 
                            OR (gFRS_Application__r.Accountable_Employee_Internal__c=:userinfo.getUserId() AND Action_Type__c = 'Program Status') 
                            OR (gFRS_Application__r.ownerid=:userinfo.getUserId() AND gFRS_Application__r.Record_Type__c != 'Field Exhibits' AND gFRS_Application__r.Record_Type__c != 'Corporate Memberships' AND gFRS_Application__r.Record_Type__c != 'Commercial Sponsorship' AND gFRS_Application__r.Record_Type__c != 'Non-Commercial Sponsorship' AND Action_Type__c = 'Refund')  
                            OR (gFRS_Application__r.Person_To_Whom_Payment_should_addressed__c =: userRec.email AND (Action_Type__c = 'Payment Method' OR Action_Type__c = 'Refund'))
                            OR ((gFRS_Application__r.ownerid=:userinfo.getUserId() OR gFRS_Application__r.Email_Address__c =: userRec.email) AND gFRS_Application__r.Record_Type__c != 'Field Exhibits' AND gFRS_Application__r.Record_Type__c != 'Corporate Memberships' AND gFRS_Application__r.Record_Type__c != 'Commercial Sponsorship' AND gFRS_Application__r.Record_Type__c != 'Non-Commercial Sponsorship' AND Action_Type__c = 'Letter of Agreement(LOA)') )
                        AND (gFRS_Application__r.Record_Type_Name__c !='Foundation Safety Net Support' AND gFRS_Application__r.Record_Type_Name__c !='Foundation Undergraduate') 
                        AND Status__c != 'Completed' order by Action_Type_Formula__c,Start_Date__c DESC];
            
        }else{
            taskList = [select Id,Name, Action_Type__c,lastmodifieddate,Start_Date__c,Status__c,Description__c,CreatedDate,gFRS_Application__c,gFRS_Application__r.Name,gFRS_Application__r.Information_Needed__c,gFRS_Application__r.Event_Program_Title__c,gFRS_Application__r.Record_Type_Name__c,gFRS_Application__r.Email_Address__c,gFRS_Application__r.Program_Start_Date_Min__c from gFRS_Ltng_Task__c where gFRS_Application__r.ownerid=:userinfo.getUserId() and (gFRS_Application__r.Record_Type_Name__c ='Foundation Safety Net Support' or gFRS_Application__r.Record_Type_Name__c ='Foundation Undergraduate') AND Status__c != 'Completed' order by Action_Type_Formula__c,Start_Date__c DESC];
            
        }
        system.debug('subList'+taskList);
        return taskList;
    } 
  /*  @AuraEnabled
    public static taskListWrapper fetchTask(string fctype) {
        taskListWrapper lsttask=new taskListWrapper();
        List<gFRS_Ltng_Task__c> taskList1;
        List<gFRS_CAF_Task__c> taskCAFList;
        User userRec = [SELECT Id, Name, email FROM User WHERE Id =: userinfo.getUserId()];
        
        if(fctype =='Genentech Inc'){
            taskList1 = [select Id,Name, Action_Type__c,lastmodifieddate,Start_Date__c,Status__c,Description__c,CreatedDate,gFRS_Application__c,gFRS_Application__r.Name,gFRS_Application__r.First_Name__c,gFRS_Application__r.Last_Name__c,gFRS_Application__r.Information_Needed__c,gFRS_Application__r.Event_Program_Title__c,gFRS_Application__r.Record_Type_Name__c,gFRS_Application__r.Email_Address__c,gFRS_Application__r.Authorized_Signer__c,gFRS_Application__r.Program_Start_Date_Min__c,gFRS_Application__r.Organization__r.Organization_Name__c, 
                       gFRS_Application__r.Program_End_Date_max__c From gFRS_Ltng_Task__c where 
                        (
                            (gFRS_Application__r.ownerid=:userinfo.getUserId() AND Action_Type__c != 'Payment Method' AND Action_Type__c != 'Refund') 
                            OR (gFRS_Application__r.ownerid=:userinfo.getUserId() AND gFRS_Application__r.Record_Type__c != 'Field Exhibits' AND gFRS_Application__r.Record_Type__c != 'Corporate Memberships' AND gFRS_Application__r.Record_Type__c != 'Commercial Sponsorship' AND gFRS_Application__r.Record_Type__c != 'Non-Commercial Sponsorship' AND Action_Type__c = 'Refund')  
                            OR (gFRS_Application__r.Person_To_Whom_Payment_should_addressed__c =: userRec.email AND (Action_Type__c = 'Payment Method' OR Action_Type__c = 'Refund'))
                            OR ((gFRS_Application__r.ownerid=:userinfo.getUserId() OR gFRS_Application__r.Email_Address__c =: userRec.email) AND gFRS_Application__r.Record_Type__c != 'Field Exhibits' AND gFRS_Application__r.Record_Type__c != 'Corporate Memberships' AND gFRS_Application__r.Record_Type__c != 'Commercial Sponsorship' AND gFRS_Application__r.Record_Type__c != 'Non-Commercial Sponsorship' AND Action_Type__c = 'Letter of Agreement(LOA)') )
                        AND (gFRS_Application__r.Record_Type_Name__c !='Foundation Safety Net Support' AND gFRS_Application__r.Record_Type_Name__c !='Foundation Undergraduate') 
                        AND Status__c != 'Completed' order by Action_Type_Formula__c,Start_Date__c DESC];
             taskCAFList = [select Id,Name, CreatedDate, CreatedById, LastModifiedDate,Action_Type__c, Description__c, gFRS_CAF_Application__c, Start_Date__c, Status__c, Subject__c from gFRS_CAF_Task__c where Status__c != 'Completed' and gFRS_CAF_Application__r.ownerid=:userRec.Id];
            lsttask.taskListvar=taskList1;
            lsttask.taskListvar=taskCAFList;
        }else{
            taskList1 = [select Id,Name, Action_Type__c,lastmodifieddate,Start_Date__c,Status__c,Description__c,CreatedDate,gFRS_Application__c,gFRS_Application__r.Name,gFRS_Application__r.Information_Needed__c,gFRS_Application__r.Event_Program_Title__c,gFRS_Application__r.Record_Type_Name__c,gFRS_Application__r.Email_Address__c,gFRS_Application__r.Program_Start_Date_Min__c from gFRS_Ltng_Task__c where gFRS_Application__r.ownerid=:userinfo.getUserId() and (gFRS_Application__r.Record_Type_Name__c ='Foundation Safety Net Support' or gFRS_Application__r.Record_Type_Name__c ='Foundation Undergraduate') AND Status__c != 'Completed' order by Action_Type_Formula__c,Start_Date__c DESC];
            
        }
        system.debug('subList'+lsttask);
        return lsttask;
    } 
    public class taskListWrapper{
        @AuraEnabled
        public List<sObject> taskListvar{get;set;}
    }
    
*/    
    
    
    @AuraEnabled
    public static RequestDataTableWrapper fetchPendingReqUI(string fctype) {
        
        RequestDataTableWrapper objDT =  new RequestDataTableWrapper();  
        if(fctype =='Genentech Inc'){
            Integer totalRecords = [SELECT COUNT() FROM gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId() and (Record_Type_Name__c !='Foundation Safety Net Support' or Record_Type_Name__c !='Foundation Undergraduate') and (Sub_Status__c = 'Not Submitted'and Event_Program_Title__c!=null and Selected_Tab_Val__c != null) ];
            //   Integer recordEnd = pageSize * pageNumber;
            objDT.totalRecords = totalRecords;
            objDT.ReqList =[SELECT Name,Program_Objectives__c,Program_Start_Date_Min__c,Record_Type_Name__c,External_Status__c,Status__c,
                            Organization__c,Selected_Tab_Val__c,Sub_Status__c,Event_Program_Title__c,CreatedDate,Organization__r.Organization_Name__c from gFRS_Ltng_Application__c 
                            Where ownerid=:userinfo.getUserId() and (Record_Type_Name__c !='Foundation Safety Net Support' and Record_Type_Name__c !='Foundation Undergraduate') 
                            and Sub_Status__c = 'Not Submitted' and Event_Program_Title__c !=null and Selected_Tab_Val__c != null order by Name DESC];
            
            objDT.ReqListCopay=[select id,name,Status__c,SelectedTab__c,Date_Submitted__c,Review_Step__c,Donation_Requested_for_Quarter__c from gFRS_Ltng_CAF_Application__c where ownerid=:userinfo.getUserId() and (Internal_Sub_Status__c = 'Not Submitted') order by Name DESC];
        }else if(fctype =='Genentech Foundation'){
            Integer totalRecords = [SELECT COUNT() FROM gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId() and (Record_Type_Name__c ='Foundation Safety Net Support' or Record_Type_Name__c ='Foundation Undergraduate') and (Sub_Status__c = 'Not Submitted'and Event_Program_Title__c!=null and Selected_Tab_Val__c != null)];
            //   Integer recordEnd = pageSize * pageNumber;
            objDT.totalRecords = totalRecords;
            objDT.ReqList =[SELECT Name,Program_Objectives__c,Program_Start_Date_Min__c,Record_Type_Name__c,External_Status__c,Status__c,Organization__c,Selected_Tab_Val__c,Sub_Status__c,Event_Program_Title__c,CreatedDate,Organization__r.Organization_Name__c from gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId() and (Record_Type_Name__c ='Foundation Safety Net Support' or Record_Type_Name__c ='Foundation Undergraduate') and (Sub_Status__c = 'Not Submitted'and (Event_Program_Title__c!=null) and Selected_Tab_Val__c != null )order by Name DESC];
            
        }
        return objDT;
    }
    @AuraEnabled
    public static RequestDataTablePreAppWrapper fetchPreAppDeatils(string fctype) {
        RequestDataTablePreAppWrapper objDT =  new RequestDataTablePreAppWrapper();  
        
        if(fctype =='Genentech Inc'){
            
            Integer invTotalRecords = [SELECT COUNT() FROM gFRS_Ltng_Pre_Application__c Where ownerid=:userinfo.getUserId() and (NOT Giving_Type__c LIKE '%Foundation%') and (Status__c = 'Invited to apply')];
            Integer notInvTotalRecords = [SELECT COUNT() FROM gFRS_Ltng_Pre_Application__c Where ownerid=:userinfo.getUserId() and (NOT Giving_Type__c LIKE '%Foundation%') and (Status__c = 'Not Invited to apply')];
            
            //Instance of Contact DataTable Wrapper Class
            objDT.invTotalRecords = invTotalRecords;
            objDT.notInvTotalRecords = notInvTotalRecords;
            objDT.invitedReqList= [SELECT Id,Name,Status__c,Event_Program_Title__c,CGN_PLNG_Title__c,Program_Start_Date__c,CGN_PLNG_Title__r.CGN_PLNG_Title__c,CreatedDate,Preapptoappcreatecheck__c,(select id,name,Preapplication__c,Selected_Tab_Val__c,Preapptoappcreatecheck__c from gFRS_Applications__r WHERE Preapplication__r.Preapptoappcreatecheck__c = true order by CreatedDate desc limit 1) from gFRS_Ltng_Pre_Application__c Where ownerid=:userinfo.getUserId() and (Status__c = 'Invited to apply') and  Full_App_Submitted__c = 'No'  and (NOT Giving_Type__c LIKE '%Foundation%')];
            objDT.notInvitedReqList= [SELECT Id,Name,Status__c,Event_Program_Title__c,CGN_PLNG_Title__c,Program_Start_Date__c,CGN_PLNG_Title__r.CGN_PLNG_Title__c,CreatedDate from gFRS_Ltng_Pre_Application__c Where ownerid=:userinfo.getUserId() and (Status__c = 'Not Invited to apply') and (NOT Giving_Type__c LIKE '%Foundation%')];
            objDT.invitedFullAppReqList=[SELECT Id,CGN_PLNG_Title__c,Name,Event_Program_Title__c,Program_Start_Date__c,CreatedDate,Giving_Type__c,(select id,name,Preapplication__c from gFRS_Applications__r WHERE Status__c != 'Intake' order by CreatedDate asc limit 1) from gFRS_Ltng_Pre_Application__c Where ownerid=:userinfo.getUserId() and  Full_App_Submitted__c = 'Yes' and ( NOT Giving_Type__c LIKE '%Foundation%')];
            objDT.submittedReqList= [SELECT Id,Name,Status__c,Event_Program_Title__c,CGN_PLNG_Title__c,Program_Start_Date__c,CGN_PLNG_Title__r.CGN_PLNG_Title__c,CreatedDate from gFRS_Ltng_Pre_Application__c Where ownerid=:userinfo.getUserId() and (Status__c = 'Submitted' or Status__c = 'In Process') and ( NOT Giving_Type__c LIKE '%Foundation%') order by createddate desc];
            objDT.draftReqList= [SELECT Id,Name,Status__c,Event_Program_Title__c,CGN_PLNG_Title__c,Program_Start_Date__c,CGN_PLNG_Title__r.CGN_PLNG_Title__c,CreatedDate from gFRS_Ltng_Pre_Application__c Where ownerid=:userinfo.getUserId() and Status__c='Draft' and ( NOT Giving_Type__c LIKE '%Foundation%') order by createddate desc];
            
        }else if(fctype =='Genentech Foundation'){
            Integer invTotalRecords = [SELECT COUNT() FROM gFRS_Ltng_Pre_Application__c Where ownerid=:userinfo.getUserId() and (Status__c = 'Invited to apply') and Giving_Type__c LIKE '%Foundation%'];
            Integer notInvTotalRecords = [SELECT COUNT() FROM gFRS_Ltng_Pre_Application__c Where ownerid=:userinfo.getUserId() and (Status__c = 'Not Invited to apply') and Giving_Type__c LIKE '%Foundation%'];
            
            //Instance of Contact DataTable Wrapper Class
            objDT.invTotalRecords = invTotalRecords;
            objDT.notInvTotalRecords = notInvTotalRecords;
            objDT.invitedReqList= [SELECT Id,Name,Status__c,Program_Start_Date__c,Event_Program_Title__c,CGN_PLNG_Title__c,CGN_PLNG_Title__r.CGN_PLNG_Title__c,CreatedDate,Preapptoappcreatecheck__c,(select id,name,Preapplication__c,Selected_Tab_Val__c,Preapptoappcreatecheck__c from gFRS_Applications__r WHERE Preapplication__r.Preapptoappcreatecheck__c = true order by CreatedDate desc limit 1) from gFRS_Ltng_Pre_Application__c Where ownerid=:userinfo.getUserId() and (Status__c = 'Invited to apply') and  Full_App_Submitted__c = 'No' and Giving_Type__c LIKE '%Foundation%'];
            objDT.notInvitedReqList= [SELECT Id,Name,Status__c,Program_Start_Date__c,Event_Program_Title__c,CGN_PLNG_Title__c,CGN_PLNG_Title__r.CGN_PLNG_Title__c,CreatedDate from gFRS_Ltng_Pre_Application__c Where ownerid=:userinfo.getUserId() and (Status__c = 'Not Invited to apply') and  Giving_Type__c LIKE '%Foundation%'];
            objDT.invitedFullAppReqList=[SELECT Id,Name,CGN_PLNG_Title__c,Event_Program_Title__c,Program_Start_Date__c,CreatedDate,(select id,name,Preapplication__c from gFRS_Applications__r order by CreatedDate asc limit 1) from gFRS_Ltng_Pre_Application__c Where ownerid=:userinfo.getUserId() and  (Full_App_Submitted__c = 'Yes' and (Giving_Type__c LIKE '%Foundation%'))];
            objDT.submittedReqList= [SELECT Id,Name,Status__c,Event_Program_Title__c,CGN_PLNG_Title__c,Program_Start_Date__c,CGN_PLNG_Title__r.CGN_PLNG_Title__c,CreatedDate from gFRS_Ltng_Pre_Application__c Where ownerid=:userinfo.getUserId() and (Status__c = 'Submitted' or Status__c = 'In Process') and ( Giving_Type__c LIKE '%Foundation%')];
            objDT.draftReqList= [SELECT Id,Name,Status__c,Event_Program_Title__c,CGN_PLNG_Title__c,Program_Start_Date__c,CGN_PLNG_Title__r.CGN_PLNG_Title__c,CreatedDate from gFRS_Ltng_Pre_Application__c Where ownerid=:userinfo.getUserId() and Status__c='Draft' and ( Giving_Type__c LIKE '%Foundation%')];
     
        }
        return objDT;
    }
    
    public class RequestDataTablePreAppWrapper {
        @AuraEnabled
        public Integer pageSize {get;set;}
        @AuraEnabled
        public Integer pageNumber {get;set;}
        @AuraEnabled
        public Integer invTotalRecords {get;set;}
        @AuraEnabled
        public Integer notInvTotalRecords {get;set;}
        @AuraEnabled
        public Integer recordStart {get;set;}
        @AuraEnabled
        public Integer recordEnd {get;set;}
        @AuraEnabled
        public List<gFRS_Ltng_Pre_Application__c> invitedReqList {get;set;}
        @AuraEnabled
        public List<gFRS_Ltng_Pre_Application__c> notInvitedReqList {get;set;}
        @AuraEnabled
        public List<gFRS_Ltng_Pre_Application__c> invitedFullAppReqList {get;set;}
        @AuraEnabled
        public List<gFRS_Ltng_Pre_Application__c> submittedReqList {get;set;}
        @AuraEnabled
        public List<gFRS_Ltng_Pre_Application__c> draftReqList {get;set;}
        
        
        
    }
    @AuraEnabled
    public static RequestDataTableWrapper fetchInProcessReqUI(Integer pageNumber, Integer pageSize,String sortField, boolean isAsc) {
        
        //Qyery 10 accounts
        //List<GFRS_Funding_Request__c> subList  = [SELECT Name,Organization_Name__c,Sub_Status__c,Record_Type_Name__c,Next_Approver__r.FirstName,Next_Approver__r.LastName,Date_Submitted__c,Event_Program_Title__c,Requested_Amount__c,Approved_Amount__c from GFRS_Funding_Request__c Where ownerid=:userinfo.getUserId() and (Sub_Status__c != 'Not Submitted' and Sub_Status__c != 'New' and Sub_Status__c != 'Approved')];
        //return list of accounts
        //return subList;
        //Offset for SOQL
        Integer offset = (pageNumber - 1) * pageSize;
        
        //Total Records
        Integer totalRecords = [SELECT COUNT() FROM gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId() and (Status__c = 'Compliance' OR Status__c = 'Decision')];
        Integer recordEnd = pageSize * pageNumber;
        String sSoql = 'SELECT Id,Name,Program_Objectives__c,Status__c,External_Status__c,Organization__c,Sub_Status__c,Event_Program_Title__c,Requested_Amount__c,Approved_Amount__c,CreatedDate From gFRS_Ltng_Application__c where ownerid=\''+UserInfo.getUserId()+'\'and (Status__c = \'Compliance\' OR Status__c = \'Decision\') order by ';
        if (sortField != '' && sortField !=null) {
            sSoql += sortField;
        }
        if (isAsc) {
            sSoql += ' asc NULLS LAST';
        } else {
            sSoql += ' desc NULLS LAST';
        }
        sSoql+=' LIMIT '+pageSize+'OFFSET '+offset; 
        system.debug('sSoql'+sSoql);
        list <gFRS_Ltng_Application__c> lstResult;
        lstResult = Database.query(sSoql);
        List < gFRS_Ltng_Application__c > returnConList = new List < gFRS_Ltng_Application__c > ();
        for (gFRS_Ltng_Application__c c: lstResult) {
            returnConList.add(c);
        }
        //Instance of Contact DataTable Wrapper Class
        RequestDataTableWrapper objDT =  new RequestDataTableWrapper();  
        objDT.pageSize = pageSize;
        objDT.pageNumber = pageNumber;
        objDT.recordStart = offset + 1;
        objDT.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        objDT.totalRecords = totalRecords;
        objDT.ReqList =returnConList;
        return objDT;
    }
    
    @AuraEnabled
    public static getExternalReqRecordtypeBasedWrapper fetchPaymentReqUI() {
        //Integer totalRecords = [SELECT COUNT() FROM gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId() and (Status__c = 'Processing & Disposition') ];
        
        //Instance of Contact DataTable Wrapper Class
        //objDT.totalRecords = totalRecords;
        //objDT.ReqList = [SELECT Id,Name,Program_Objectives__c,Status__c,Record_Type_Name__c,External_Status__c,Organization__c,Sub_Status__c,Event_Program_Title__c,Requested_Amount__c,Approved_Amount__c,CreatedDate from gFRS_Ltng_Application__c  Where ownerid=:userinfo.getUserId() and (Status__c = 'Processing & Disposition') ];
        getExternalReqRecordtypeBasedWrapper objDT =  new getExternalReqRecordtypeBasedWrapper();  
        // objDT.totalRecords = totalRecords;
        objDT.scientificResearchRecordList =[SELECT Id,Name,DraftLOA_href__c,Executed_LOA_href__c,Program_Objectives__c,Approval_Step__c,Record_Type_Name__c,Status__c,External_Status__c,Organization__c,Sub_Status__c,Event_Program_Title__c,Requested_Amount__c,Funding_Sub_Type__c,Approved_Amount__c,CreatedDate,final_Approval_Step__c,(select Id,Name,Status__c from FRS_Payment_Historys__r) from gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId() and (Record_Type_Name__c ='Scientific and Research Focused Giving') and (Status__c = 'Processing & Disposition') and Id IN (SELECT gFRS_Application__c FROM gFRS_Ltng_Payment_History__c where SAP_Payment_Document_ID__c ='') and LOA_Signed__c='Yes'  order by Name DESC];
        objDT.patientHealthcareRecordList =[SELECT Id,Name,DraftLOA_href__c,Executed_LOA_href__c,Program_Objectives__c,Approval_Step__c,Record_Type_Name__c,Status__c,External_Status__c,Organization__c,Sub_Status__c,Event_Program_Title__c,Requested_Amount__c,Funding_Sub_Type__c,Approved_Amount__c,CreatedDate,final_Approval_Step__c,(select Id,Name,Status__c from FRS_Payment_Historys__r) from gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId() and (Record_Type_Name__c ='Patient and Health Focused Giving') and (Status__c = 'Processing & Disposition') and Id IN (SELECT gFRS_Application__c FROM gFRS_Ltng_Payment_History__c where SAP_Payment_Document_ID__c ='') and LOA_Signed__c='Yes'  order by Name DESC];
        objDT.CMERecordList =[SELECT Id,Name,Program_Objectives__c,DraftLOA_href__c,Executed_LOA_href__c,Approval_Step__c,Record_Type_Name__c,Status__c,External_Status__c,Organization__c,Sub_Status__c,Event_Program_Title__c,Requested_Amount__c,Funding_Sub_Type__c,Approved_Amount__c,CreatedDate,final_Approval_Step__c,(select Id,Name,Status__c from FRS_Payment_Historys__r) from gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId() and (Record_Type_Name__c ='Independent Medical Education (CME)') and (Status__c = 'Processing & Disposition') and Id IN (SELECT gFRS_Application__c FROM gFRS_Ltng_Payment_History__c where SAP_Payment_Document_ID__c ='') and LOA_Signed__c='Yes'  order by Name DESC];
        objDT.communityGivingRecordList =[SELECT Id,Name,DraftLOA_href__c,Executed_LOA_href__c,Program_Objectives__c,Approval_Step__c,Record_Type_Name__c,Status__c,External_Status__c,Organization__c,Sub_Status__c,Event_Program_Title__c,Requested_Amount__c,Funding_Sub_Type__c,Approved_Amount__c,CreatedDate,final_Approval_Step__c,(select Id,Name,Status__c from FRS_Payment_Historys__r) from gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId() and (Record_Type_Name__c ='Community Giving') and (Status__c = 'Processing & Disposition') and Id IN (SELECT gFRS_Application__c FROM gFRS_Ltng_Payment_History__c where SAP_Payment_Document_ID__c ='') and LOA_Signed__c='Yes'  order by Name DESC];
        objDT.educationK12RecordList =[SELECT Id,Name,DraftLOA_href__c,Executed_LOA_href__c,Program_Objectives__c,Approval_Step__c,Record_Type_Name__c,Status__c,External_Status__c,Organization__c,Sub_Status__c,Event_Program_Title__c,Requested_Amount__c,Funding_Sub_Type__c,Approved_Amount__c,CreatedDate,final_Approval_Step__c,(select Id,Name,Status__c from FRS_Payment_Historys__r) from gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId() and (Record_Type_Name__c ='Education Focused Giving K-12') and (Status__c = 'Processing & Disposition') and Id IN (SELECT gFRS_Application__c FROM gFRS_Ltng_Payment_History__c where SAP_Payment_Document_ID__c ='') and LOA_Signed__c='Yes'  order by Name DESC];
        objDT.educationGradNpostRecordList =[SELECT Id,Name,DraftLOA_href__c,Executed_LOA_href__c,Program_Objectives__c,Approval_Step__c,Record_Type_Name__c,Status__c,External_Status__c,Organization__c,Sub_Status__c,Event_Program_Title__c,Requested_Amount__c,Funding_Sub_Type__c,Approved_Amount__c,CreatedDate,final_Approval_Step__c,(select Id,Name,Status__c from FRS_Payment_Historys__r) from gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId() and (Record_Type_Name__c ='Education Focused Giving Graduate and Post-Graduate') and (Status__c = 'Processing & Disposition') and Id IN (SELECT gFRS_Application__c FROM gFRS_Ltng_Payment_History__c where SAP_Payment_Document_ID__c ='') and LOA_Signed__c='Yes'  order by Name DESC];
        objDT.educationGradNpostRecordList =[SELECT Id,Name,DraftLOA_href__c,Executed_LOA_href__c,Program_Objectives__c,Approval_Step__c,Record_Type_Name__c,Status__c,External_Status__c,Organization__c,Sub_Status__c,Event_Program_Title__c,Requested_Amount__c,Funding_Sub_Type__c,Approved_Amount__c,CreatedDate,final_Approval_Step__c,(select Id,Name,Status__c from FRS_Payment_Historys__r) from gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId() and (Record_Type_Name__c ='Education Focused Giving Graduate and Post-Graduate') and (Status__c = 'Processing & Disposition') and Id IN (SELECT gFRS_Application__c FROM gFRS_Ltng_Payment_History__c where SAP_Payment_Document_ID__c ='') and LOA_Signed__c='Yes'  order by Name DESC];
        objDT.educationGradNpostRecordList =[SELECT Id,Name,DraftLOA_href__c,Executed_LOA_href__c,Program_Objectives__c,Approval_Step__c,Record_Type_Name__c,Status__c,External_Status__c,Organization__c,Sub_Status__c,Event_Program_Title__c,Requested_Amount__c,Funding_Sub_Type__c,Approved_Amount__c,CreatedDate,final_Approval_Step__c,(select Id,Name,Status__c from FRS_Payment_Historys__r) from gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId() and (Record_Type_Name__c ='Education Focused Giving Graduate and Post-Graduate') and (Status__c = 'Processing & Disposition') and Id IN (SELECT gFRS_Application__c FROM gFRS_Ltng_Payment_History__c where SAP_Payment_Document_ID__c ='') and LOA_Signed__c='Yes'  order by Name DESC];
        objDT.foundationUndergraduateRecordList =[SELECT Id,Name,DraftLOA_href__c,Executed_LOA_href__c,Program_Objectives__c,Approval_Step__c,Record_Type_Name__c,Status__c,External_Status__c,Organization__c,Sub_Status__c,Event_Program_Title__c,Requested_Amount__c,Funding_Sub_Type__c,Approved_Amount__c,CreatedDate,final_Approval_Step__c,(select Id,Name,Status__c from FRS_Payment_Historys__r) from gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId() and (Record_Type_Name__c ='Foundation Undergraduate') and (Status__c = 'Processing & Disposition') and Id IN (SELECT gFRS_Application__c FROM gFRS_Ltng_Payment_History__c where SAP_Payment_Document_ID__c ='') and LOA_Signed__c='Yes'  order by Name DESC];
        objDT.foundationSafetyNetRecordList =[SELECT Id,Name,DraftLOA_href__c,Executed_LOA_href__c,Program_Objectives__c,Approval_Step__c,Record_Type_Name__c,Status__c,External_Status__c,Organization__c,Sub_Status__c,Event_Program_Title__c,Requested_Amount__c,Funding_Sub_Type__c,Approved_Amount__c,CreatedDate,final_Approval_Step__c,(select Id,Name,Status__c from FRS_Payment_Historys__r) from gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId() and (Record_Type_Name__c ='Foundation Safety Net Support') and (Status__c = 'Processing & Disposition') and Id IN (SELECT gFRS_Application__c FROM gFRS_Ltng_Payment_History__c where SAP_Payment_Document_ID__c ='') and LOA_Signed__c='Yes'  order by Name DESC];
        objDT.copayRecordList=[select id,name,Status__c,Date_Submitted__c,Total_Apprv_Amount__c,Donation_Requested_for_Quarter__c,(select Id,name,Status__c from gFRS_CAF_Payment_Refund_History__r) from gFRS_Ltng_CAF_Application__c where  ownerid=:userinfo.getUserId() and Status__c = 'Processing and Disposition' and Internal_Sub_Status__c !='Paid' order by Name DESC];
        return objDT;
    }
    public class RequestDataTablePaymentWrapper {
        @AuraEnabled
        public Integer pageSize {get;set;}
        @AuraEnabled
        public Integer pageNumber {get;set;}
        @AuraEnabled
        public Integer totalRecords {get;set;}
        @AuraEnabled
        public Integer recordStart {get;set;}
        @AuraEnabled
        public Integer recordEnd {get;set;}
        @AuraEnabled
        public List<gFRS_Ltng_Application__c> ReqList {get;set;}
    }
    @AuraEnabled
    public static RequestDataTableWrapper fetchCompletedReqUI(string fctype) {
        RequestDataTableWrapper objDT =  new RequestDataTableWrapper();  
        
        if(fctype =='Genentech Inc'){
            
            Integer totalRecords = [SELECT COUNT() FROM gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId() and (Record_Type_Name__c !='Foundation Safety Net Support' or Record_Type_Name__c !='Foundation Undergraduate') and (Status__c = 'Closed'and (Sub_Status__c ='Approved')) ];
            Integer totalRecords_notFunded = [SELECT COUNT() FROM gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId() and  (Record_Type_Name__c !='Foundation Safety Net Support' or Record_Type_Name__c !='Foundation Undergraduate') and (Status__c = 'Closed' and (Sub_Status__c ='Canceled' OR Sub_Status__c ='Denied'))];
            Integer totalRecordsCopay = [SELECT COUNT() FROM gFRS_Ltng_CAF_Application__c Where ownerid=:userinfo.getUserId() and  (Status__c = 'Closed'and (Internal_Sub_Status__c ='Approved'))];
            Integer totalRecords_notFundedCopay = [SELECT COUNT() FROM gFRS_Ltng_CAF_Application__c Where ownerid=:userinfo.getUserId() and (Status__c = 'Closed'and (Internal_Sub_Status__c ='Canceled' OR Internal_Sub_Status__c ='Denied'))];
            //   Integer recordEnd = pageSize * pageNumber;
            objDT.totalRecords = totalRecords;
            objDT.totalRecords_notFunded = totalRecords_notFunded;
            objDT.copaytotalRecords = totalRecordsCopay;
            objDT.copaytotalRecords_notFunded = totalRecords_notFundedCopay;
            objDT.ReqList =[SELECT Id,Name,Preapplication__r.Name,Program_Start_Date_Min__c,Executed_LOA_href__c,Program_Objectives__c,Record_Type_Name__c,Status__c,External_Status__c,Organization__c,Sub_Status__c,Event_Program_Title__c,Requested_Amount__c,Approved_Amount__c,Organization__r.Organization_Name__c,CreatedDate from gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId() and (Record_Type_Name__c !='Foundation Safety Net Support' AND Record_Type_Name__c !='Foundation Undergraduate') and   Id IN (SELECT gFRS_Application__c FROM gFRS_Ltng_Payment_History__c where SAP_Payment_Document_ID__c !='') and LOA_Signed__c='Yes' order by Name DESC];
            objDT.ReqList_notFunded =[SELECT Id,Name,Preapplication__r.Name,Program_Start_Date_Min__c,Record_Type_Name__c,Decision_Reasons__c,Program_Objectives__c,Status__c,External_Status__c,Organization__c,Sub_Status__c,Event_Program_Title__c,Requested_Amount__c,Approved_Amount__c,Organization__r.Organization_Name__c,CreatedDate from gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId() and (Record_Type_Name__c !='Foundation Safety Net Support' AND Record_Type_Name__c !='Foundation Undergraduate') and (Status__c = 'Closed' and (Sub_Status__c ='Canceled' OR Sub_Status__c ='Denied'))];
            objDT.ReqListCopay =[select Id,name,Status__c,Date_Submitted__c,Donation_Requested_for_Quarter__c from gFRS_Ltng_CAF_Application__c where  ownerid=:userinfo.getUserId() and Internal_Sub_Status__c ='Paid'];
            objDT.ReqList_notFundedCopay =[select Id,name,Status__c,Date_Submitted__c,Donation_Requested_for_Quarter__c from gFRS_Ltng_CAF_Application__c where ownerid=:userinfo.getUserId() and  (Status__c = 'Closed' and (Internal_Sub_Status__c ='Cancelled' OR Internal_Sub_Status__c ='Denied'))];
            
        }else if(fctype =='Genentech Foundation'){
            Integer totalRecords = [SELECT COUNT() FROM gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId() and  (Record_Type_Name__c ='Foundation Safety Net Support' or Record_Type_Name__c ='Foundation Undergraduate') and (Status__c = 'Closed'and Sub_Status__c ='Approved')];
            Integer totalRecords_notFunded = [SELECT COUNT() FROM gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId() and  (Record_Type_Name__c ='Foundation Safety Net Support' or Record_Type_Name__c ='Foundation Undergraduate') and (Status__c = 'Closed' and (Sub_Status__c ='Canceled' OR Sub_Status__c ='Denied'))];
            
            //   Integer recordEnd = pageSize * pageNumber;
            objDT.totalRecords = totalRecords;
            objDT.totalRecords_notFunded = totalRecords_notFunded;
            objDT.ReqList =[SELECT Id,Name,Preapplication__r.Name,Program_Objectives__c,Program_Start_Date_Min__c,Record_Type_Name__c,Status__c,External_Status__c,Organization__c,Sub_Status__c,Event_Program_Title__c,Requested_Amount__c,Approved_Amount__c,CreatedDate from gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId() and  (Record_Type_Name__c ='Foundation Safety Net Support' or Record_Type_Name__c ='Foundation Undergraduate') and (Status__c = 'Closed' and (Sub_Status__c ='Approved'))];
            objDT.ReqList_notFunded =[SELECT Id,Name,Preapplication__r.Name,Program_Start_Date_Min__c,Record_Type_Name__c,Decision_Reasons__c,Program_Objectives__c,Status__c,External_Status__c,Organization__c,Sub_Status__c,Event_Program_Title__c,Requested_Amount__c,Approved_Amount__c,CreatedDate from gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId() and  (Record_Type_Name__c ='Foundation Safety Net Support' or Record_Type_Name__c ='Foundation Undergraduate') and (Status__c = 'Closed' and (Sub_Status__c ='Canceled' OR Sub_Status__c ='Denied'))];
            
        }else if(fctype =='Internal'){
            Integer totalRecords = [SELECT COUNT() FROM gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId()  and ((Status__c = 'Closed' and Sub_Status__c ='Approved') or (Status__c = 'Processing & Disposition' and Sub_Status__c ='Process Payment'))];
            Integer totalRecords_notFunded = [SELECT COUNT() FROM gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId()  and (Status__c = 'Closed' and (Sub_Status__c ='Canceled' OR Sub_Status__c ='Denied'))];
            //   Integer recordEnd = pageSize * pageNumber;
            objDT.totalRecords = totalRecords;
            objDT.totalRecords_notFunded = totalRecords_notFunded;
            objDT.ReqList =[SELECT Id,Name,Executed_LOA_Document_ID__c,Program_Start_Date_Min__c,Executed_LOA_href__c,Executed_LOA_PDF_Document__c,Preapplication__r.Name,Program_Objectives__c,Record_Type_Name__c,Status__c,External_Status__c,Organization__c,Sub_Status__c,Event_Program_Title__c,Requested_Amount__c,Approved_Amount__c,Organization__r.Organization_Name__c,CreatedDate from gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId() and  ((Status__c = 'Closed' and Sub_Status__c ='Approved') or (Status__c = 'Processing & Disposition' and Sub_Status__c ='Process Payment'))];
            objDT.ReqList_notFunded =[SELECT Id,Name,Executed_LOA_Document_ID__c,Program_Start_Date_Min__c,Executed_LOA_href__c,Executed_LOA_PDF_Document__c,Preapplication__r.Name,Record_Type_Name__c,Decision_Reasons__c,Program_Objectives__c,Status__c,External_Status__c,Organization__c,Sub_Status__c,Event_Program_Title__c,Requested_Amount__c,Approved_Amount__c,Organization__r.Organization_Name__c,CreatedDate from gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId()  and (Status__c = 'Closed' and (Sub_Status__c ='Canceled' OR Sub_Status__c ='Denied'))];
            
        }
        System.debug('-objDT->'+objDT);
        return objDT;
    }
    @AuraEnabled
    public static gFRS_Ltng_Pre_Application__c fetchCompletedPreApp() {
        
        gFRS_Ltng_Pre_Application__c completedPreApp =  new gFRS_Ltng_Pre_Application__c();  
        completedPreApp = [SELECT Id,Name,Event_Program_Title__c,CreatedDate from gFRS_Ltng_Pre_Application__c Where ownerid=:userinfo.getUserId() and  Full_App_Submitted__c = 'Yes'];
        
        return completedPreApp;
    }    
    public class RequestDataTableWrapper {
        @AuraEnabled
        public Integer pageSize {get;set;}
        @AuraEnabled
        public Integer pageNumber {get;set;}
        @AuraEnabled
        public Integer totalRecords {get;set;}
        @AuraEnabled
        public Integer totalRecords_notFunded {get;set;}
        @AuraEnabled
        public Integer copaytotalRecords {get;set;}
        @AuraEnabled
        public Integer copaytotalRecords_notFunded {get;set;}
        @AuraEnabled
        public Integer recordStart {get;set;}
        @AuraEnabled
        public Integer recordEnd {get;set;}
        @AuraEnabled
        public List<gFRS_Ltng_Application__c> ReqList {get;set;}
        @AuraEnabled
        public List<gFRS_Ltng_Application__c> ReqList_notFunded {get;set;}
        @AuraEnabled
        public List<gFRS_Ltng_CAF_Application__c> ReqListCopay {get;set;}
        @AuraEnabled
        public List<gFRS_Ltng_CAF_Application__c> ReqList_notFundedCopay {get;set;}
        @AuraEnabled
        public List<sObject> ReqListFull {get;set;}
        
    }
    @AuraEnabled
    public static ContactDataTableWrapper getContactData(Integer pageNumber, Integer pageSize) {
        
        //Offset for SOQL
        Integer offset = (pageNumber - 1) * pageSize;
        
        //Total Records
        Integer totalRecords = [SELECT COUNT() FROM gFRS_Ltng_Application__c];
        Integer recordEnd = pageSize * pageNumber;
        
        //Instance of Contact DataTable Wrapper Class
        ContactDataTableWrapper objDT =  new ContactDataTableWrapper();  
        objDT.pageSize = pageSize;
        objDT.pageNumber = pageNumber;
        objDT.recordStart = offset + 1;
        objDT.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        objDT.totalRecords = totalRecords;
        objDT.contactList = [SELECT Id, Name FROM gFRS_Ltng_Application__c ORDER BY Name LIMIT :pageSize OFFSET :offset];
        return objDT;
    }
    
    //Wrapper Class For Contact DataTable  
    public class ContactDataTableWrapper {
        @AuraEnabled
        public Integer pageSize {get;set;}
        @AuraEnabled
        public Integer pageNumber {get;set;}
        @AuraEnabled
        public Integer totalRecords {get;set;}
        @AuraEnabled
        public Integer recordStart {get;set;}
        @AuraEnabled
        public Integer recordEnd {get;set;}
        @AuraEnabled
        public List<gFRS_Ltng_Application__c> contactList {get;set;}
    }
    @AuraEnabled  
    public static List<gFRS_Ltng_Application__c> loadData(){  
        List<gFRS_Ltng_Application__c> conList = [select Id,Name,Program_Objectives__c from gFRS_Ltng_Application__c order by Name asc];  
        return conList;  
    }
    
    @AuraEnabled 
    public static getExternalReqRecordtypeBasedWrapper getAppDtls() {
        // Integer totalRecords = [SELECT COUNT() FROM gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId() and (Status__c = 'Compliance' OR Status__c = 'Decision')];
        //   Integer recordEnd = pageSize * pageNumber;
        getExternalReqRecordtypeBasedWrapper objDT =  new getExternalReqRecordtypeBasedWrapper();  
        // objDT.totalRecords = totalRecords;
        // list<gFRS_Ltng_Application__c> gfObjRef=[SELECT Id,Name,Program_Objectives__c,Approval_Step__c,Record_Type_Name__c,Status__c,External_Status__c,Organization__c,Sub_Status__c,Event_Program_Title__c,Requested_Amount__c,Funding_Sub_Type__c,Approved_Amount__c,CreatedDate,final_Approval_Step__c from gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId() and (Status__c = 'Compliance' OR Status__c = 'Decision') order by Name ASC];
        
        
        objDT.scientificResearchRecordList =[SELECT Id,Name,Date_Submitted__c,Program_Start_Date_Min__c,DraftLOA_href__c,Program_Objectives__c,Approval_Step__c,Record_Type_Name__c,Status__c,External_Status__c,Organization__c,Sub_Status__c,Event_Program_Title__c,Requested_Amount__c,Funding_Sub_Type__c,Approved_Amount__c,CreatedDate,final_Approval_Step__c from gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId() and (Record_Type_Name__c ='Scientific and Research Focused Giving') and (Status__c = 'Compliance' OR Status__c = 'Decision') order by Name DESC];
        objDT.patientHealthcareRecordList =[SELECT Id,Name,Date_Submitted__c,Program_Start_Date_Min__c,DraftLOA_href__c,Program_Objectives__c,Approval_Step__c,Record_Type_Name__c,Status__c,External_Status__c,Organization__c,Sub_Status__c,Event_Program_Title__c,Requested_Amount__c,Funding_Sub_Type__c,Approved_Amount__c,CreatedDate,final_Approval_Step__c from gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId() and (Record_Type_Name__c ='Patient and Health Focused Giving') and (Status__c = 'Compliance' OR Status__c = 'Decision') order by Name DESC];
        objDT.CMERecordList =[SELECT Id,Name,Date_Submitted__c,Program_Start_Date_Min__c,Program_Objectives__c,DraftLOA_href__c,Approval_Step__c,Record_Type_Name__c,Status__c,External_Status__c,Organization__c,Sub_Status__c,Event_Program_Title__c,Requested_Amount__c,Funding_Sub_Type__c,Approved_Amount__c,CreatedDate,final_Approval_Step__c from gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId() and (Record_Type_Name__c ='Independent Medical Education (CME)') and (Status__c = 'Compliance' OR Status__c = 'Decision') order by Name DESC];
        objDT.communityGivingRecordList =[SELECT Id,Name,Program_Start_Date_Min__c,Date_Submitted__c,DraftLOA_href__c,Program_Objectives__c,Approval_Step__c,Record_Type_Name__c,Status__c,External_Status__c,Organization__c,Sub_Status__c,Event_Program_Title__c,Requested_Amount__c,Funding_Sub_Type__c,Approved_Amount__c,CreatedDate,final_Approval_Step__c from gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId() and (Record_Type_Name__c ='Community Giving') and (Status__c = 'Compliance' OR Status__c = 'Decision') order by Name DESC];
        objDT.educationK12RecordList =[SELECT Id,Name,Program_Start_Date_Min__c,Date_Submitted__c,DraftLOA_href__c,Program_Objectives__c,Approval_Step__c,Record_Type_Name__c,Status__c,External_Status__c,Organization__c,Sub_Status__c,Event_Program_Title__c,Requested_Amount__c,Funding_Sub_Type__c,Approved_Amount__c,CreatedDate,final_Approval_Step__c from gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId() and (Record_Type_Name__c ='Education Focused Giving K-12') and (Status__c = 'Compliance' OR Status__c = 'Decision') order by Name DESC];
        objDT.educationGradNpostRecordList =[SELECT Id,Name,Program_Start_Date_Min__c,Date_Submitted__c,DraftLOA_href__c,Program_Objectives__c,Approval_Step__c,Record_Type_Name__c,Status__c,External_Status__c,Organization__c,Sub_Status__c,Event_Program_Title__c,Requested_Amount__c,Funding_Sub_Type__c,Approved_Amount__c,CreatedDate,final_Approval_Step__c from gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId() and (Record_Type_Name__c ='Education Focused Giving Graduate and Post-Graduate') and (Status__c = 'Compliance' OR Status__c = 'Decision') order by Name DESC];
        objDT.foundationUndergraduateRecordList =[SELECT Id,Name,Program_Start_Date_Min__c,Date_Submitted__c,DraftLOA_href__c,Program_Objectives__c,Approval_Step__c,Foundation_Approval_Step__c,Record_Type_Name__c,Status__c,External_Status__c,Organization__c,Sub_Status__c,Event_Program_Title__c,Requested_Amount__c,Funding_Sub_Type__c,Approved_Amount__c,CreatedDate,final_Approval_Step__c from gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId() and (Record_Type_Name__c ='Foundation Undergraduate') and (Status__c = 'Compliance' OR Status__c = 'Decision') order by Name DESC];
        objDT.foundationSafetyNetRecordList =[SELECT Id,Name,Program_Start_Date_Min__c,Date_Submitted__c,DraftLOA_href__c,Program_Objectives__c,Approval_Step__c,Foundation_Approval_Step__c,Record_Type_Name__c,Status__c,External_Status__c,Organization__c,Sub_Status__c,Event_Program_Title__c,Requested_Amount__c,Funding_Sub_Type__c,Approved_Amount__c,CreatedDate,final_Approval_Step__c from gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId() and (Record_Type_Name__c ='Foundation Safety Net Support') and (Status__c = 'Compliance' OR Status__c = 'Decision') order by Name DESC];
        objDT.copayRecordList=[select id,name,Status__c,Date_Submitted__c,Review_Step__c,Donation_Requested_for_Quarter__c from gFRS_Ltng_CAF_Application__c where  ownerid=:userinfo.getUserId() and(Status__c = 'Compliance' OR Status__c = 'Decision') order by Name DESC];
        
        objDT.DAFRecordList =[SELECT Id,Name,Program_Start_Date_Min__c,Select_DAF__c,Date_Submitted__c,DraftLOA_href__c,Executed_LOA_href__c,Program_Objectives__c,Approval_Step__c,Record_Type_Name__c,Status__c,External_Status__c,Organization__c,Sub_Status__c,Event_Program_Title__c,Requested_Amount__c,Funding_Sub_Type__c,Approved_Amount__c,CreatedDate,final_Approval_Step__c from gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId() and Select_DAF__c = 'Yes' order by Name DESC];
        
        return objDT;
    }
    @AuraEnabled 
    public static getInternalReqRecordtypeBasedWrapper getUnderReviewRecordDtls(){
        
        getInternalReqRecordtypeBasedWrapper objDT =  new getInternalReqRecordtypeBasedWrapper(); 
        objDT.fieldExhibitRecordList =[SELECT Id,DraftLOA_href__c,Program_Start_Date_Min__c,Date_Submitted__c,Submitted_Draft_LOA__c,Submitted_Draft_ID__c,Name,Finance_Approver__r.Name,Finance_Manager__r.Name,Business_Approver__r.Name,Legal_Approver__r.Name,FPO_compliance_owner__r.Name,Record_Type_Name__c,Status__c,Organization__c,Sub_Status__c,Event_Program_Title__c,Requested_Amount__c,Funding_Sub_Type__c,Approved_Amount__c,CreatedDate,final_Approval_Step__c,Organization__r.Organization_Name__c,Record_Type__c from gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId() and (Status__c = 'Compliance' OR Status__c = 'Decision') and Record_Type__c='Field Exhibits' order by Name DESC];
        objDT.corporateMembershipsRecordList =[SELECT Id,DraftLOA_href__c,Program_Start_Date_Min__c,Date_Submitted__c,Submitted_Draft_LOA__c,Submitted_Draft_ID__c,Name,Finance_Approver__r.Name,Finance_Manager__r.Name,Business_Approver__r.Name,Legal_Approver__r.Name,FPO_compliance_owner__r.Name,Record_Type_Name__c,Status__c,Organization__c,Sub_Status__c,Event_Program_Title__c,Requested_Amount__c,Funding_Sub_Type__c,Approved_Amount__c,CreatedDate,final_Approval_Step__c,Organization__r.Organization_Name__c,Record_Type__c from gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId() and (Status__c = 'Compliance' OR Status__c = 'Decision') and Record_Type__c='Corporate Memberships' order by Name DESC];
        objDT.commercialSponsorshipsRecordList =[SELECT Id,DraftLOA_href__c,Program_Start_Date_Min__c,Date_Submitted__c,Submitted_Draft_LOA__c,Submitted_Draft_ID__c,Name,Finance_Approver__r.Name,Finance_Manager__r.Name,Business_Approver__r.Name,Legal_Approver__r.Name,FPO_compliance_owner__r.Name,Record_Type_Name__c,Status__c,Organization__c,Sub_Status__c,Event_Program_Title__c,Requested_Amount__c,Funding_Sub_Type__c,Approved_Amount__c,CreatedDate,final_Approval_Step__c,Organization__r.Organization_Name__c,Record_Type__c from gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId() and (Status__c = 'Compliance' OR Status__c = 'Decision') and Record_Type__c='Commercial Sponsorship' order by Name DESC];
        objDT.nonCommercialSponsorshipsRecordList =[SELECT Id,DraftLOA_href__c,Program_Start_Date_Min__c,Date_Submitted__c,Submitted_Draft_LOA__c,Submitted_Draft_ID__c,Name,Finance_Approver__r.Name,Finance_Manager__r.Name,Business_Approver__r.Name,Legal_Approver__r.Name,FPO_compliance_owner__r.Name,Record_Type_Name__c,Status__c,Organization__c,Sub_Status__c,Event_Program_Title__c,Requested_Amount__c,Funding_Sub_Type__c,Approved_Amount__c,CreatedDate,final_Approval_Step__c,Organization__r.Organization_Name__c,Record_Type__c from gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId() and (Status__c = 'Compliance' OR Status__c = 'Decision') and Record_Type__c='Non-Commercial Sponsorship' order by Name DESC];
        
        return objDT;
        
    }
    @AuraEnabled 
    public static getInternalReqRecordtypeBasedWrapper getInternalPaymentRecordDtls(){
        
        getInternalReqRecordtypeBasedWrapper objDT =  new getInternalReqRecordtypeBasedWrapper(); 
        objDT.fieldExhibitRecordList =[SELECT Id,Name,DraftLOA_href__c,Program_Start_Date_Min__c,Submitted_Draft_LOA__c,Submitted_Draft_ID__c,Record_Type_Name__c,Status__c,Organization__c,Sub_Status__c,Event_Program_Title__c,Requested_Amount__c,Funding_Sub_Type__c,Approved_Amount__c,CreatedDate,final_Approval_Step__c,Organization__r.Organization_Name__c,Record_Type__c from gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId() and Status__c = 'Processing & Disposition' and Sub_Status__c = 'Approved-Awaiting LOA' and Record_Type__c='Field Exhibits' order by Name DESC];
        objDT.corporateMembershipsRecordList =[SELECT Id,Name,DraftLOA_href__c,Program_Start_Date_Min__c,Submitted_Draft_LOA__c,Submitted_Draft_ID__c,Record_Type_Name__c,Status__c,Organization__c,Sub_Status__c,Event_Program_Title__c,Requested_Amount__c,Funding_Sub_Type__c,Approved_Amount__c,CreatedDate,final_Approval_Step__c,Organization__r.Organization_Name__c,Record_Type__c from gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId() and Status__c = 'Processing & Disposition' and Sub_Status__c = 'Approved-Awaiting LOA' and Record_Type__c='Corporate Memberships' order by Name DESC];
        objDT.commercialSponsorshipsRecordList =[SELECT Id,Name,DraftLOA_href__c,Program_Start_Date_Min__c,Submitted_Draft_LOA__c,Submitted_Draft_ID__c,Record_Type_Name__c,Status__c,Organization__c,Sub_Status__c,Event_Program_Title__c,Requested_Amount__c,Funding_Sub_Type__c,Approved_Amount__c,CreatedDate,final_Approval_Step__c,Organization__r.Organization_Name__c,Record_Type__c from gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId() and Status__c = 'Processing & Disposition' and Sub_Status__c = 'Approved-Awaiting LOA' and Record_Type__c='Commercial Sponsorship' order by Name DESC];
        objDT.nonCommercialSponsorshipsRecordList =[SELECT Id,Name,DraftLOA_href__c,Program_Start_Date_Min__c,Submitted_Draft_LOA__c,Submitted_Draft_ID__c,Record_Type_Name__c,Status__c,Organization__c,Sub_Status__c,Event_Program_Title__c,Requested_Amount__c,Funding_Sub_Type__c,Approved_Amount__c,CreatedDate,final_Approval_Step__c,Organization__r.Organization_Name__c,Record_Type__c from gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId() and Status__c = 'Processing & Disposition' and Sub_Status__c = 'Approved-Awaiting LOA' and Record_Type__c='Non-Commercial Sponsorship' order by Name DESC];
        
        return objDT;
        
    }
    public class getInternalReqRecordtypeBasedWrapper {
        
        @AuraEnabled
        public List<gFRS_Ltng_Application__c> fieldExhibitRecordList {get;set;}
        @AuraEnabled
        public List<gFRS_Ltng_Application__c> corporateMembershipsRecordList {get;set;}
        @AuraEnabled
        public List<gFRS_Ltng_Application__c> commercialSponsorshipsRecordList {get;set;}
        @AuraEnabled
        public List<gFRS_Ltng_Application__c> nonCommercialSponsorshipsRecordList {get;set;}
    }
    public class getExternalReqRecordtypeBasedWrapper {
        
        @AuraEnabled
        public List<gFRS_Ltng_Application__c> scientificResearchRecordList {get;set;}
        @AuraEnabled
        public List<gFRS_Ltng_Application__c> patientHealthcareRecordList {get;set;}
        @AuraEnabled
        public List<gFRS_Ltng_Application__c> CMERecordList {get;set;}
        @AuraEnabled
        public List<gFRS_Ltng_Application__c> communityGivingRecordList {get;set;}
        @AuraEnabled
        public List<gFRS_Ltng_Application__c> educationK12RecordList {get;set;}
        @AuraEnabled
        public List<gFRS_Ltng_Application__c> educationGradNpostRecordList {get;set;}
        @AuraEnabled
        public List<gFRS_Ltng_Application__c> foundationUndergraduateRecordList {get;set;}
        @AuraEnabled
        public List<gFRS_Ltng_Application__c> foundationSafetyNetRecordList {get;set;}
        @AuraEnabled
        public List<gFRS_Ltng_Application__c> DAFRecordList {get;set;}
        @AuraEnabled
        public List<gFRS_Ltng_CAF_Application__c> copayRecordList {get;set;}
        
    }
    @AuraEnabled 
    public static preappClsWrapper fetchPreAppRecord(string recordId) {
        system.debug('&&&&&&&&&&@@@@@@@@@@@@@@@@@recordId'+recordId);
        gFRS_Ltng_Pre_Application__c preApp = new gFRS_Ltng_Pre_Application__c();
        try{
            preApp = [SELECT Id, Name,Giving_Type__c,Program_Start_Date__c,Program_End_Date__c,Giving_Sub_Type__c,gFRS_Organization__c,Organization_Tax_ID__c,Non_US_Tax_ID__c,Event_Program_Title__c,Program_Description__c,Total_Overall_Budget__c,Requested_Amount__c,Disease_State__c,Therapuetic_Area__c,standquestion5__c FROM gFRS_Ltng_Pre_Application__c WHERE Id =: recordId];
            system.debug('@@@ preApp record : '+preApp.gFRS_Organization__c);
            system.debug('@@@ preApp Giving_Type__c : '+preApp.Giving_Type__c);
            gFRS_Ltng_Application__c appInfoRec = new gFRS_Ltng_Application__c();
            gFRS_Ltng_Organization__c orgInfo = new gFRS_Ltng_Organization__c();
            system.debug('@@@ Pre app org Id :'+preApp.gFRS_Organization__c);
            if(String.isBlank(preApp.gFRS_Organization__c)){
                orgInfo=[Select id,Name from gFRS_Ltng_Organization__c Where Organization_Name__c='Testing record 1' LIMIT 1];
            } else {
                orgInfo=[Select id,Name from gFRS_Ltng_Organization__c Where id=:preApp.gFRS_Organization__c LIMIT 1];
            }
            
            system.debug('@@@ orgInfo Id :'+orgInfo.Id);
            Id appRcdTypeId;
            if(preApp.Giving_Type__c == 'Research Projects and Scientific Meetings'){
                appRcdTypeId = Schema.SObjectType.gFRS_Ltng_Application__c.getRecordTypeInfosByName().get('Scientific and Research Focused Giving').getRecordTypeId();
            } else {
                appRcdTypeId = Schema.SObjectType.gFRS_Ltng_Application__c.getRecordTypeInfosByName().get(preApp.Giving_Type__c).getRecordTypeId();
            }
            system.debug('appRcdTypeId'+appRcdTypeId);
            appInfoRec.RecordTypeId = appRcdTypeId;
            appInfoRec.Funding_Sub_Type__c=preApp.Giving_Sub_Type__c;
            appInfoRec.Organization__c=orgInfo.Id;
            appInfoRec.Event_Program_Title__c=preApp.Event_Program_Title__c;
            appInfoRec.Support_Purpose_Program_Description__c=preApp.Program_Description__c;
            appInfoRec.Total_Overall_Budget__c=preApp.Total_Overall_Budget__c;
            appInfoRec.Requested_Amount__c=preApp.Requested_Amount__c;
            appInfoRec.Lead_or_co_led_by_a_Person_of_Color__c=preApp.standquestion5__c;
            //  appInfoRec.Therapeutic_Area__c=preApp.Therapuetic_Area__c;
            //  appInfoRec.Disease_State__c=preApp.Disease_State__c;
            //   appInfoRec.First_Program_Start_Date__c=preApp.Program_Start_Date__c;
            //    appInfoRec.Last_Program_End_Date__c=preApp.Program_End_Date__c;
            
            //  appInfoRec.Preapptoappcreatecheck__c=true;
            appInfoRec.Preapplication__c=preApp.Id;
            Database.UpsertResult srList = Database.upsert(appInfoRec,false);
            if(srList.isSuccess()){
                system.debug('@@@@:::Value of upsert record:::' + appInfoRec);
                system.debug('@@@@:::Value of upsert ID:::' + appInfoRec.id);
                Id recID = srList.getId();
                
                /* preApp.Preapptoappcreatecheck__c=true;
update preApp; */
                
                gFRS_Ltng_Application__c appRecord = [SELECT Id, Name,Record_Type_Name__c,Organization__c,Funding_Sub_Type__c FROM gFRS_Ltng_Application__c WHERE Id =: recID];
                preappClsWrapper preappWrap=new preappClsWrapper();
                preappWrap.preApplicationDtls=preApp;
                preappWrap.applicationDtls=appRecord;
                return preappWrap;
            }else{
                return null;
            }
        }catch(Exception e){
            system.debug('@@@@ Excep::'+e.getMessage());
            throw new AuraHandledException(e.getMessage()); 
        }        
        
    }
    public class  preappClsWrapper{
        @AuraEnabled
        public gFRS_Ltng_Pre_Application__c preApplicationDtls {get;set;}
        @AuraEnabled
        public gFRS_Ltng_Application__c applicationDtls {get;set;}       
    }
    @AuraEnabled
    public static List <gFRS_Ltng_Pre_Application__c> fetchPreAppDtls(String searchKeyWord) {
        String searchKey =  '%'+searchKeyWord + '%';
        List < gFRS_Ltng_Pre_Application__c > returnList = new List < gFRS_Ltng_Pre_Application__c > ();
        List < gFRS_Ltng_Pre_Application__c > lstOfAccount = [SELECT Id,Name,Status__c,CGN_PLNG_Title__c,CGN_PLNG_Title__r.CGN_PLNG_Title__c,CreatedDate from gFRS_Ltng_Pre_Application__c Where (CGN_PLNG_Title__r.CGN_PLNG_Title__c LIKE: searchKey OR Name LIKE: searchKey) and ownerid=:userinfo.getUserId() and (Status__c = 'Invited to apply')  ];
        
        for (gFRS_Ltng_Pre_Application__c acc: lstOfAccount) {
            returnList.add(acc);
        }
        system.debug('returnList'+returnList);
        return returnList;
    }    
    @AuraEnabled
    public static List <gFRS_Ltng_Pre_Application__c> fetchPreAppDtls_Notinv(String searchKeyWord) {
        String searchKey =  '%'+searchKeyWord + '%';
        List < gFRS_Ltng_Pre_Application__c > returnList = new List < gFRS_Ltng_Pre_Application__c > ();
        List < gFRS_Ltng_Pre_Application__c > lstOfAccount = [SELECT Id,Name,Status__c,CGN_PLNG_Title__c,CGN_PLNG_Title__r.CGN_PLNG_Title__c,CreatedDate from gFRS_Ltng_Pre_Application__c Where (CGN_PLNG_Title__r.CGN_PLNG_Title__c LIKE: searchKey OR Name LIKE: searchKey) and ownerid=:userinfo.getUserId() and(Status__c = 'Not Invited to apply')];
        
        for (gFRS_Ltng_Pre_Application__c acc: lstOfAccount) {
            returnList.add(acc);
        }
        system.debug('returnList'+returnList);
        return returnList;
    } 
    @AuraEnabled
    public static List <gFRS_Ltng_Task__c> fetchTask_Filter(String searchKeyWord) {
        String searchKey =  '%'+searchKeyWord + '%';
        List<gFRS_Ltng_Task__c> taskList;
        taskList = [select Id,Name, Action_Type__c,lastmodifieddate,Start_Date__c,Status__c,Description__c,CreatedDate,gFRS_Application__c,gFRS_Application__r.Name,gFRS_Application__r.Information_Needed__c,gFRS_Application__r.Event_Program_Title__c,gFRS_Application__r.Program_Start_Date_Min__c from gFRS_Ltng_Task__c where ( Name LIKE: searchKey or gFRS_Application__r.Event_Program_Title__c LIKE: searchKey) and gFRS_Application__r.ownerid=:userinfo.getUserId() order by Start_Date__c desc];
        system.debug('subList'+taskList);
        return taskList;
    }
    @AuraEnabled
    public static RequestDataTableWrapper deleteCopayApplication(String AppId) {
        gFRS_Ltng_CAF_Application__c delAccount=[Select Id from gFRS_Ltng_CAF_Application__c where id=:AppId];
        delete delAccount;
        Integer totalRecords = [SELECT COUNT() FROM gFRS_Ltng_CAF_Application__c Where ownerid=:userinfo.getUserId() and (Internal_Sub_Status__c = 'Not Submitted')];
        //   Integer recordEnd = pageSize * pageNumber;
        RequestDataTableWrapper objDT =  new RequestDataTableWrapper();  
        objDT.totalRecords = totalRecords;
        objDT.ReqListCopay=[select id,name,Status__c,SelectedTab__c,Date_Submitted__c,Review_Step__c,Donation_Requested_for_Quarter__c from gFRS_Ltng_CAF_Application__c where ownerid=:userinfo.getUserId() and (Internal_Sub_Status__c = 'Not Submitted') order by Name ASC];
        return objDT;
    }
    @AuraEnabled
    public static RequestDataTablePreAppWrapper deleteEFP(String AppId) {
        gFRS_Ltng_Pre_Application__c delAccount=[Select Id from gFRS_Ltng_Pre_Application__c where id=:AppId];
        delete delAccount;
        RequestDataTablePreAppWrapper objDT =  new RequestDataTablePreAppWrapper();
        objDT.draftReqList=[SELECT Id,Name,Status__c,Event_Program_Title__c,CGN_PLNG_Title__c,Program_Start_Date__c,CGN_PLNG_Title__r.CGN_PLNG_Title__c,CreatedDate from gFRS_Ltng_Pre_Application__c Where ownerid=:userinfo.getUserId() and Status__c ='Draft' order by createddate desc];
        return objDT;
    }
    
    @AuraEnabled
    public static RequestDataTableWrapper deleteApplication(String AppId) {
        gFRS_Ltng_Application__c delAccount=[Select Id from gFRS_Ltng_Application__c where id=:AppId];
        delete delAccount;
        Integer totalRecords = [SELECT COUNT() FROM gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId() and (Sub_Status__c = 'Not Submitted'and Event_Program_Title__c!=null)];
        //   Integer recordEnd = pageSize * pageNumber;
        RequestDataTableWrapper objDT =  new RequestDataTableWrapper();  
        objDT.totalRecords = totalRecords;
        objDT.ReqList =[SELECT Name,Program_Objectives__c,Record_Type_Name__c,External_Status__c,Status__c,Organization__c,Selected_Tab_Val__c,Sub_Status__c,Event_Program_Title__c,CreatedDate from gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId() and (Sub_Status__c = 'Not Submitted'and (Event_Program_Title__c!=null) )];
        return objDT;
    }
    @AuraEnabled
    public static gFRS_Ltng_Application__c cloneReqDtls(String reqId) {
        ID recordId = reqId;
        list<Attachment> attList=new list<Attachment>();
        try{ DescribeSObjectResult describeResult = recordId.getSObjectType().getDescribe();    
            List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );  
            String query =
                ' SELECT ' +
                String.join( fieldNames, ',' ) +
                ' FROM ' +
                describeResult.getName() +
                ' WHERE ' +  
                ' id = :recordId ' +
                ' LIMIT 1 ' ;   
            system.debug('query'+query);
            gFRS_Ltng_Application__c acc =  Database.query( query );
            // return generic list of sobjects or typecast to expected type List<SObject> records = Database.query( query );    
            // gFRS_Ltng_Application__c acc = [SELECT ID, Name FROM gFRS_Ltng_Application__c WHERE Id = : reqId];
            acc.Status__c='Intake';
            acc.Sub_Status__c='Not Submitted';
            acc.External_Status__c='Not Submitted';
            acc.Request_Cloned__c='Yes';
            acc.ParentRequest__c= recordId;
            acc.Decision_Date__c= null;
            acc.Approved_Amount__c= null;
            acc.FPO_Reviewer_Decision_Date__c=null;
            acc.Selected_Tab_Val__c='reqInfo';
            acc.Event_Program_Documentation__c='';
            acc.gFRS_Attachment1__c='';
            acc.Additional_Document1__c='';
            acc.Additional_Document2__c='';
            acc.Additional_Document3__c='';
            acc.Additional_Document4__c='';
            acc.Create_FA_Record__c=false;
            acc.ACH_Details_Rec_ID__c='';
            acc.Vendor_Detail__c=null;
            acc.Authorized_Signer__c=null;
            acc.Business_Approver_Decision__c='';
            acc.Business_Approver_Decision_Date__c=null;
            acc.Business_Reviewer_Comments__c='';
            acc.Business_Approver_2_Comments__c='';
            acc.Comments__c='';
            acc.Finance_Manager_Comments__c='';
            acc.Financial_Reviewer_Comments__c='';
            acc.Financial_Reviewer1_Comments__c='';
            acc.Financial_Reviewer2_Comments__c='';
            acc.Financial_Reviewer3_Comments__c='';
            acc.Financial_Reviewer4_Comments__c='';
            acc.FPO_Reviewer_Comments__c='';
            acc.Legal_Reviewer_Comments__c='';
            acc.PAR_Approval_Comments__c='';
            acc.Closed_Date__c=null;
            acc.Compliance_Flags_PDF_ID__c='';
            acc.Confirm_Payment_Contact_Email_Address__c='';
            acc.Decision_Flags_PDF_ID__c='';
            acc.DocusignAttach_PDF_ID__c='';
            acc.EnvelopeId__c='';
            acc.Evaluation_Completed__c='';
            acc.Evaluation_Task_Created_Date__c=null;
            acc.Executed_LOA_Document_ID__c='';
            acc.Final_Approver_Decision_Date__c=null;
            acc.Financial_Approver_Decision__c='';
            acc.Financial_Approver_Decision_Date__c=null;
            acc.FPO_compliance_owner__c=null;
            acc.FPO_Reviewer_Decision__c='';
            acc.LOA_Signed__c='';
            acc.LOA_Signed_Date__c=null;
            acc.Payment_Call_Counter__c=null;
            acc.Payment_Info__c='';
            acc.Payment_Method__c='';
            acc.Person_To_Whom_Payment_should_addressed__c='';
            acc.Confirm_Payment_Contact_Email_Address__c='';
            acc.Attention_To__c='';
            acc.SAP_Payment_ID__c='';
            acc.Submitted_Draft_ID__c='';
            acc.Transaction_Check_Number__c='';
            acc.Requested_Amount__c=null;
            acc.Focus_on_equity__c='';
            acc.Evaluation_Methodology__c='';
            acc.Partners_or_Collaborators__c='';
            acc.Dissemination__c='';
            acc.Sustainability__c='';
            acc.If_known_List_Other_Supporters__c='';
            acc.Funding_Publicized__c='';
            acc.Selection_Decisions__c='';
            acc.Decision_making__c='';
            acc.Criteria_for_Fellow_Selection__c='';
            acc.Lead_or_co_led_by_a_Person_of_Color__c='';
            acc.Clinical_Practice_Guideline_Development__c='';
            acc.Associated_clinical_practice_guidelines__c='';
            acc.Print_Deadline__c='';
            acc.Print_Deadline_Date__c=null;
            acc.Thank_You_Benifits__c='';
            acc.Select_GNE_Alignment__c='';
            acc.Financial_Approver_1__c=null;
            acc.Total_Overall_Budget__c=null;
            acc.Legal_Approver__c=null;
            acc.Legal_Reviewer_Decision__c='';
            acc.Legal_Reviewer_Decision_Date__c=null;
            /*added Fileds to status and sub status  miss match */
            acc.Docusign_Task_Check__c=false;
            acc.Business_Approver__c=null;
            acc.Finance_Approver__c=null;
            acc.Finance_Manager__c=null;
            acc.Status_Values_Updated__c='No';
            acc.Evaluation_PB_Check__c=false;           
            acc.Auto_Payment_Check_for_External__c=false;
            acc.Create_FA_Record__c=false;
            acc.Refund_Manager_Status_Check_PB__c=false;
            acc.Refund_Task_Created_Date__c=null;
            acc.Closed_Status_Check_PB_Non_CME__c=false;
            acc.PB_Recon_Task_Check__c=false;
            acc.Is_Scope_Change__c=false;
            acc.Refund_Status_Check_PB_Non_CME__c=false;
            acc.Is_Evaluation_Required__c=false;
            acc.Manager_Status_Check_PB__c=false;
            acc.Reconciliation_PB_Check_1__c=false;
            acc.Scope_Change_Date__c=null;
            /*End of Fileds to status and sub status  miss match */
            gFRS_Ltng_Application__c accCopy = acc.clone(false,true);
            insert accCopy;
            
            /* list<Attachment> attachmentDetail=[SELECT Id, name, parentId FROM Attachment where parentId =:acc.Id];
for(Attachment thrdprg:attachmentDetail){
recordId=thrdprg.Id;
DescribeSObjectResult describeResultOfPrg = thrdprg.Id.getSObjectType().getDescribe();  
List<String> prgFieldNames = new List<String>( describeResultOfPrg.fields.getMap().keySet() );  
String queryPrg =
' SELECT ' +
String.join( prgFieldNames, ',' ) +
' FROM ' +
describeResultOfPrg.getName() +
' WHERE ' +  
' id = :recordId';  
Attachment prgqury=Database.query(queryPrg);
Attachment conCopy= prgqury.clone(false,true);
conCopy.parentId = accCopy.Id;
attList.add(conCopy);
}
insert attList;*/
            gFRS_Ltng_Application__c cloneApp=[Select Id,Name,Selected_Tab_Val__c from gFRS_Ltng_Application__c where id=:accCopy.Id];
            return cloneApp;
           }catch(Exception e){
               system.debug('@@@@ Excep::'+e.getMessage());
               throw new AuraHandledException(e.getMessage()); 
           }        
        
        
    }
    
    
    @AuraEnabled
    public static id fetchFocusarea(String recordtypename){
        try{
            RecordType recid=[select Id, Name, DeveloperName, NamespacePrefix, Description, BusinessProcessId, SobjectType, IsActive, IsPersonType from RecordType where SobjectType='gFRS_Ltng_Application__c' and DeveloperName=:recordtypename LIMIT 1];
            System.debug('-->'+recid.id);
            return recid.id;
        }catch(Exception e){
            system.debug('@@@@ Excep::'+e.getMessage());
            throw new AuraHandledException(e.getMessage()); 
        }       
    }
    @AuraEnabled 
    public static user fetchUser(){
        // query current user information  
        User oUser = [select id,FirstName,LastName,Email,Phone,MobilePhone,Extension 
                      FROM User Where id =: userInfo.getUserId()];
        return oUser;
    }
    @AuraEnabled
    public static void updategivingpriority(String parentId,String cgnId,Id attchId,string attchName,string attchType,Boolean requiredcheck){
        system.debug('@@ CGN :'+cgnId);
        system.debug('@@ parentId :'+parentId);
        system.debug('@@ attchId :'+attchId);
        string CGN = cgnId;
        string attachmentId = attchId;
        try{
            gFRS_Ltng_Pre_Application__c lp=[select id,CGN_PLNG_Title__c,Giving_Priorities_Alignment__c,CGN_PLNG_Title__r.Giving_Priorities_Alignment__c,CGN_PLNG_Title__r.id,RFP_Attachment_Id__c,RFP_Attachment_Name__c,RFP_Attachment_Type__c,Status__c from gFRS_Ltng_Pre_Application__c where id=:parentId];
 
            if((CGN != null && CGN != '') || (attachmentId != null && attachmentId != '')){
                
                system.debug('parentId'+parentId);
                
                if(attachmentId != null && attachmentId != ''){
                    ContentVersion CV = new ContentVersion();
                    CV = [SELECT Id, VersionData, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId =: attachmentId];
                    
                    ContentVersion cVersion = new ContentVersion();
                    cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
                    cVersion.PathOnClient = attchName;//File name with extention
                    cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
                    cVersion.OwnerId = UserInfo.getUserId();//Owner of the file
                    cVersion.Title = attchName;//Name of the file
                    cVersion.VersionData = CV.VersionData;//File content
                    Insert cVersion;
                    
                    //After saved the Content Verison, get the ContentDocumentId
                    Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;
                    
                    //Insert ContentDocumentLink
                    ContentDocumentLink cDocLink = new ContentDocumentLink();
                    cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
                    cDocLink.LinkedEntityId = parentId;//Add attachment parentId
                    cDocLink.ShareType = 'I';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
                    cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
                    Insert cDocLink;
                    
                    lp.RFP_Attachment_Id__c   = conDocument;
                    lp.RFP_Attachment_Name__c = attchName;
                    lp.RFP_Attachment_Type__c = attchType;
                    
                }
                
                if(CGN != null && CGN != ''){
                    lp.CGN_PLNG_Title__c=CGN;
                    gFRS_CGN_PLNG_Bulk_Email__c CGNRec=[select id,Giving_Priorities_Alignment__c from gFRS_CGN_PLNG_Bulk_Email__c where id=:CGN];
                    lp.Giving_Priorities_Alignment__c=CGNRec.Giving_Priorities_Alignment__c;
                    system.debug('lp.Giving_Priorities_Alignment__c'+lp.Giving_Priorities_Alignment__c);
                }
             
             //   System.debug('-12345->'+lp.Status__c+'-->'+requiredcheck);
               
                
            }
            if(requiredcheck){
                    lp.Status__c='Submitted';
                }else{
                    lp.Status__c='Draft';
                }
            update lp;
        } catch(Exception e){
            system.debug('@@@@ Excep::'+e.getMessage());
            throw new AuraHandledException(e.getMessage()); 
        }  
        
    }
    
    
    
    public class picklistWrapper{
        @AuraEnabled 
        public string pickListLabel{get;set;}
        @AuraEnabled 
        public string pickListValue{get;set;}
        
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
    @AuraEnabled  
    public static List<string> getMultiPicklistvalues(string objAPIName, string fieldAPIname) {        
        list<string> options = new List<string>();
        // list<picklistWrapper> returnValue = new list<picklistWrapper>();
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Map<String, Schema.SObjectField> field_map = gd.get(objAPIName.toLowerCase()).getDescribe().fields.getMap();
        // Get the list of picklist values for this field.
        list < Schema.PicklistEntry > values = field_map.get(fieldAPIname).getDescribe().getPickListValues();
        
        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a: values) {           
            options.add(a.getValue());
            
        }
        system.debug('picklist values ' +options);
        return options;
        
    }
    @AuraEnabled  
    public static gFRS_Ltng_Pre_Application__c getPreapp(string appId) {       
        return [select id,Program_Description__c,CGN_PLNG_Title__c,CGN_PLNG_Title__r.CGN_PLNG_Title__c,Organization_Name__c,Organization_Tax_ID__c,Non_US_Tax_ID__c,Where_is_the_organization_located__c,Giving_Priorities_Alignment__c,Giving_Sub_Type__c,Program_Start_Date__c,Summary_Please_provide_a_2_sentence_sum__c,Program_End_Date__c,Provide_the_grant_decision_or_print_dead__c,Does_the_grant_target_any_of_the_specifi__c,Do_you_have_a_grant_decision_or_print_de__c,Focus_Area12__c,RFP_Attachment_Id__c,RFP_Attachment_Name__c,RFP_Attachment_Type__c,Therapuetic_Area__c,Disease_State__c,phfgtext11__c  from gFRS_Ltng_Pre_Application__c WHERE id=:appId];
    }
    
    @AuraEnabled  
    public static Boolean getProfileName() {   
        
        Boolean returnValue;
        Profile prof = [Select Id, Name from Profile where Id =: userinfo.getProfileid()];
        
        if(prof.Name == 'GNE-GFRS-External Applicant'){
            returnValue= true;
        }
        else{
            returnValue = false;
        } 
        
        return returnValue;  
        
    }
    @AuraEnabled  
    public static gFRS_CAF_Payment_Refund_History__c getPaymentCopayInfo(string recId) {   
        
        gFRS_CAF_Payment_Refund_History__c pmtHistRec = new gFRS_CAF_Payment_Refund_History__c();
        pmtHistRec = [SELECT Id, SAP_Payment_Document_ID__c,Check_Number__c,Encashment_Date__c,Payment_Method__c,SAP_Payment_Sent_Date__c,Status__c,Grant__c,Grant__r.id,Grant__r.name,Grant__r.gFRS_Organization__c,Grant__r.gFRS_Organization__r.Organization_Name__c FROM gFRS_CAF_Payment_Refund_History__c WHERE Status__c = 'Success' AND Grant__c =: recId order by createddate desc LIMIT 1];
        
        return pmtHistRec;     
    } 
    @AuraEnabled
    public static gFRS_Ltng_Payment_History__c getPaymentInfo(string recId) {   
        
        gFRS_Ltng_Payment_History__c pmtHistRec = new gFRS_Ltng_Payment_History__c();
        pmtHistRec = [SELECT Id, SAP_Payment_Document_ID__c, Check_Number__c, SAP_Payment_Sent_Date__c, Encashment_Date__c, Payment_Method__c, Status__c, gFRS_Application__c, gFRS_Application__r.Name, gFRS_Application__r.Org_Name__c FROM gFRS_Ltng_Payment_History__c WHERE Status__c = 'Success' AND gFRS_Application__c =: recId order by createddate desc LIMIT 1];
        
        return pmtHistRec;     
    }  
    
    @AuraEnabled
    public static void deleteAttachment(Id attchId) {
        try{            
            
            List<ContentDocument> entries = [SELECT id,Title,FileType,CreatedBy.Name,ContentSize FROM ContentDocument WHERE Id =:attchId]; 
            delete entries;            
            
        }catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
    }
      @AuraEnabled
       public static List <gFRS_CAF_Task__c> fetchCAFTask(String fctype) {
        List<gFRS_CAF_Task__c> taskList;
       if(fctype =='Genentech Inc'){
        User userRec = [SELECT Id, Name, email FROM User WHERE Id =: userinfo.getUserId()];
        taskList = [select Id,Name, CreatedDate, CreatedById, LastModifiedDate,Action_Type__c, Description__c, gFRS_CAF_Application__c, gFRS_CAF_Application__r.Name,Start_Date__c, Status__c, Subject__c,gFRS_CAF_Application__r.Donation_Requested_for_Quarter_CreatedDt__c from gFRS_CAF_Task__c where Status__c != 'Completed' and gFRS_CAF_Application__r.ownerid=:userRec.Id order by Start_Date__c DESC];
       }
           return taskList;
    }
    public class Wrapper1{
        @AuraEnabled
        public sObject obj{get;set;}
        public Wrapper1(sObject s){
            obj=s;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Wrapper1> getResults(String value){
        List<Wrapper1> lstWrapper=new List<Wrapper1>();
		String  searchKey='%'+value+'%';
        Wrapper1 wr;
        
        for(gFRS_Ltng_Application__c app :[SELECT Id,Name,Status__c,Sub_Status__c,CreatedDate,Event_Program_Title__c,Requested_Amount__c,Selected_Tab_Val__c FROM gFRS_Ltng_Application__c WHERE OwnerId=:userinfo.getUserId() and Selected_Tab_Val__c != null and Name LIKE :searchKey]){          
         
            
            lstWrapper.add(new Wrapper1(app));
        }
        
        
        for(gFRS_Ltng_CAF_Application__c caf :[SELECT Id,Name,Status__c,Internal_Sub_Status__c,CreatedDate,Total_Requested_Amount__c,SelectedTab__c FROM gFRS_Ltng_CAF_Application__c WHERE OwnerId=:userinfo.getUserId() and SelectedTab__c != null and Name LIKE :searchKey]){          
         
            lstWrapper.add(new Wrapper1(caf));
        }
        System.debug('-size->'+lstWrapper.size());
        return lstWrapper;
        
    }
    @auraenabled(cacheable=true)
    public static List<gFRS_Ltng_Application__c> getAllResults() {
       List<gFRS_Ltng_Application__c> lstapp=[SELECT Id,Name,Status__c,Sub_Status__c,CreatedDate,Event_Program_Title__c,Requested_Amount__c,Selected_Tab_Val__c FROM gFRS_Ltng_Application__c WHERE OwnerId=:userinfo.getUserId() and Selected_Tab_Val__c != null];
       return lstapp;
    }
    
}