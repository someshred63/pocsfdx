public without sharing class CAFUserRecUpdate {
    
    @AuraEnabled
    public static gFRS_Ltng_CAF_User__c fetchCAFUserREc(Id reqId){
        return [Select Id,Name,Code_Req_Approver__c,Incorrect_Attempts__c,Invite_Code__c,Invite_Code_Status__c,Organization_Name__c,User__c FROM gFRS_Ltng_CAF_User__c WHERE Id =:reqId ];
    }
    
    @AuraEnabled
    public static User fetchUser(Id userID){
        return [Select Id,Name FROM User WHERE Id =:userID ];
    }
    
    @AuraEnabled
    public static gFRS_Ltng_CAF_Application__c fetchCAFAppREc(Id reqId){
        return [Select Id,Manual_Resolution__c,Name,CreatedBy.Name,Status__c,Approval_Process_Counter__c,Internal_Sub_Status__c,Date_for_Limit_Calculation__c,Record_Type__c,OIG_Opinion__c,Total_Requested_Amount__c,Total_Apprv_Amount__c,Total_Approved_Amount__c,Total_Payment_Amount_Rollup__c ,Estimated_Current_Revenue__c,Payment_Type__c,Manual_Automated_Payment__c,Vendor_Bank_Reviewed__c,Review_Recommendation_Deck_Attachment_ID__c,Review_Recommendation_Deck_Attachment__c,Summary_Snapshot_PDF_ID__c,Summary_Snapshot_PDF__c,Acknowledge_Current_Revenue_33__c,Grant_Approver__c,Grant_Approver__r.Name,Finance_Approver__c,Finance_Approver__r.Name,VP_Approver__c,VP_Approver__r.Name,CFO_Approver__c,CFO_Approver__r.Name,Compliance_Reviewer_Comments__c,Grant_Reviewer_Comments__c,Grant_Approver_Comments__c,Finance_Approver_Comments__c,VP_Approver_Comments__c,No_Undue_Influence_Clinical_Practices__c,No_Undue_Influence_Clinical_Pract_Notes__c,Organization_Reputation_Blacklist__c,Org_Reputation_Blacklist_Notes__c,OrgType_Charitable_Foundation_of_a_Group__c,OrgType_Charitable_Foundation_Notes__c,Organization_Type_Poltical_Sec__c,Org_Type_Political_Sectarian_Notes__c,gFRS_Organization__r.Name,gFRS_Organization__r.Organization_Name__c,gFRS_Organization__c,Application_Acknowledgment__c,Application_Acknowledgment_Notes__c,Organization_Favorable_OIG_Opinion_Notes__c,Organization_Tax_Status__c,Organization_Tax_Status_Notes__c FROM gFRS_Ltng_CAF_Application__c WHERE Id =:reqId ];
    }
    
    @AuraEnabled
    public static gFRS_Ltng_CAF_Application__c doCAFLimtCal(Id cafAppId){
        gFRS_Ltng_Copay_Util.doLimtCal(cafAppId);
        return [Select Id,Name,Status__c,Internal_Sub_Status__c,Date_for_Limit_Calculation__c,Record_Type__c,OIG_Opinion__c,Total_Approved_Amount__c,Estimated_Current_Revenue__c,Payment_Type__c,Manual_Automated_Payment__c,Vendor_Bank_Reviewed__c,Review_Recommendation_Deck_Attachment_ID__c,Review_Recommendation_Deck_Attachment__c,Summary_Snapshot_PDF_ID__c,Summary_Snapshot_PDF__c,Acknowledge_Current_Revenue_33__c,Grant_Approver__c,Grant_Approver__r.Name,Finance_Approver__c,Finance_Approver__r.Name,VP_Approver__c,VP_Approver__r.Name,CFO_Approver__c,CFO_Approver__r.Name,Compliance_Reviewer_Comments__c,Grant_Reviewer_Comments__c,Grant_Approver_Comments__c,Finance_Approver_Comments__c,VP_Approver_Comments__c,No_Undue_Influence_Clinical_Practices__c,Organization_Reputation_Blacklist__c,OrgType_Charitable_Foundation_of_a_Group__c,Organization_Type_Poltical_Sec__c,gFRS_Organization__r.Name,gFRS_Organization__r.Organization_Name__c,gFRS_Organization__c,Application_Acknowledgment__c,Organization_Favorable_OIG_Opinion_Notes__c,Organization_Tax_Status__c,Organization_Tax_Status_Notes__c FROM gFRS_Ltng_CAF_Application__c WHERE Id =:cafAppId ];
    }
    
    @AuraEnabled    
    public static List <gFRS_CAF_Disease_State__c> fetchDisease(Id reqId) {    
        System.debug('RecordId'+reqId);
        return [ SELECT Id, Name,Disease_Fund_Name__c,Approved__c,Fund_Type__c,Requested_Donation_Amount__c,Payment_Amount__c,Time_Frame_for_Requested_Donation__c  FROM gFRS_CAF_Disease_State__c where gFRS_CAF_Application__c=:reqId ];    
        
    }
    
    @AuraEnabled
    public static void SubmitForApproval(Id reqId){
        user u= [Select Id,Name From User Where Id =:UserInfo.getUserId()];
        gFRS_Ltng_CAF_Application__c rec = [Select Id,Name,Status__c,Internal_Sub_Status__c,Compliance_Owner__c FROM gFRS_Ltng_CAF_Application__c WHERE Id =:reqId ];            
        if(rec.Status__c == 'Compliance' && rec.Internal_Sub_Status__c == 'New'){
            rec.Internal_Sub_Status__c = 'Compliance Approver';
            rec.Compliance_Owner__c = u.id;
        } 
        update rec;
        Approval.ProcessSubmitRequest approvalReq = new Approval.ProcessSubmitRequest();
        approvalReq.setComments('Submitting request for approval.');
        approvalReq.setObjectId(reqId);
        //approvalReq.setProcessDefinitionNameOrId('IME_Approval_Process');
        approvalReq.setProcessDefinitionNameOrId('');
        approvalReq.setSkipEntryCriteria(true);
        Approval.ProcessResult processResult = Approval.process(approvalReq);
        //return StatusVal;
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
        //gfrs.Organization_Favorable_OIG_Opinion_Notes__c = noteinput7;
        gfrs.id = reqId;
        try{
            UPDATE gfrs;
        } catch(Exception e) {
            throw new AuraHandledException(e.getLineNumber()+':'+e.getMessage());
        }  
    }
    
    @AuraEnabled
    public static Boolean approveOrRejectRequest(Id reqId,gFRS_Ltng_CAF_Application__c request,String action,String comments){
        
        System.debug('Request1'+request);
        Id workItemId = null;
        Id assignedApprover = null;
        ProcessInstanceWorkitem workItem  = [SELECT p.Id, ActorId, OriginalActorId FROM ProcessInstanceWorkitem p where p.ProcessInstance.TargetObjectId =: reqId];
        workItemId  =  workItem.Id != null ? workItem.Id : '';
        assignedApprover = workItem.ActorId != null ? workItem.ActorId : '';
        
        if(validateUser(UserInfo.getUserId(), assignedApprover))  {
            //gFRS_Ltng_CAF_Application__c gfrs = new gFRS_Ltng_CAF_Application__c();
            Approval.ProcessWorkitemRequest submittedReq = new Approval.ProcessWorkitemRequest();
            if(action == 'Approve') {
                //gfrs.Payment_Type__c = request.Payment_Type__c;
                //gfrs.Manual_Automated_Payment__c =request.Manual_Automated_Payment__c;          
                //gfrs.Acknowledge_Current_Revenue_33__c = request.Acknowledge_Current_Revenue_33__c;
                //gfrs.Vendor_Bank_Reviewed__c = vendor;
                if(request.Internal_Sub_Status__c == 'Grant Approver 1'){
                    request.Grant_Reviewer__c = UserInfo.getUserId();
                    System.debug('Request.Grant_Approver__c'+request.Grant_Approver__c);
                    if(request.Grant_Approver__c != null) {
                        Pattern unixIdPattern = Pattern.compile( '[(]([^)]+)[)]' );
                        Matcher unixIdMatcher = unixIdPattern.matcher( request.Grant_Approver__c );
                        String unixId = null;
                        
                        if( unixIdMatcher.find()){
                            unixId = unixIdMatcher.group(1);
                            //System.debug( 'Grant_Approver unixId:' + unixId );
                        } else {
                            //-- calling method catches the custom exception to add the item to gCOI_Pending_Actions
                            //System.debug( 'before addError Grant Approver not exists' );
                            request.addError('Grant Approver not exists'); 
                        }
                        
                        Id targetId = gFRS_Ltng_Util_NoShare.getUserByUnixId(unixId);
                        if( targetId == null ){
                            //System.debug( 'before addError' + targetId );
                            request.addError('Grant Approver not exists');   
                        }
                        //System.debug( 'Grant_Approver targetId:' + targetId );
                        request.Grant_Approver__c = targetId;   
                    }
                    
                    //if(request.Finance_Approver__c != null) {
                    if(String.isNotBlank(request.Finance_Approver__c)) {
                        Pattern unixIdPattern = Pattern.compile( '[(]([^)]+)[)]' );
                        Matcher unixIdMatcher = unixIdPattern.matcher( request.Finance_Approver__c );
                        String unixId = null;
                        
                        if( unixIdMatcher.find() ){
                            unixId = unixIdMatcher.group(1);
                            //System.debug( 'Finance Manager unixId:' + unixId );
                        } else {
                            //-- calling method catches the custom exception to add the item to gCOI_Pending_Actions
                            request.addError('Finance Approver not exists'); 
                        }
                        
                        
                        Id targetId = gFRS_Ltng_Util_NoShare.getUserByUnixId(unixId);
                        if( targetId == null ){
                            request.addError('Finance Approver not exists');   
                        }
                        request.Finance_Approver__c = targetId;   
                        system.debug('Request1234'+targetId);
                    }
                    
                    //if(request.VP_Approver__c != null) {
                    if(String.isNotBlank(request.VP_Approver__c)) {
                        Pattern unixIdPattern = Pattern.compile( '[(]([^)]+)[)]' );
                        Matcher unixIdMatcher = unixIdPattern.matcher( request.VP_Approver__c );
                        String unixId = null;
                        
                        if( unixIdMatcher.find() ){
                            unixId = unixIdMatcher.group(1);
                            System.debug( 'VP_Approver unixId:' + unixId );
                        } else {
                            //-- calling method catches the custom exception to add the item to gCOI_Pending_Actions
                            request.addError('VP Approver not exists'); 
                        }
                        
                        Id targetId = gFRS_Ltng_Util_NoShare.getUserByUnixId(unixId);
                        if( targetId == null ){
                            request.addError('VP Approver not exists');   
                        }
                        request.VP_Approver__c = targetId;   
                    }
                    
                    if(String.isNotBlank(request.CFO_Approver__c)) {
                        Pattern unixIdPattern = Pattern.compile( '[(]([^)]+)[)]' );
                        Matcher unixIdMatcher = unixIdPattern.matcher( request.CFO_Approver__c );
                        String unixId = null;
                        
                        if( unixIdMatcher.find() ){
                            unixId = unixIdMatcher.group(1);
                            System.debug( 'CFO_Approver unixId:' + unixId );
                        } else {
                            //-- calling method catches the custom exception to add the item to gCOI_Pending_Actions
                            request.addError('CFO Approver not exists'); 
                        }
                        
                        Id targetId = gFRS_Ltng_Util_NoShare.getUserByUnixId(unixId);
                        if( targetId == null ){
                            request.addError('CFO Approver not exists');   
                        }
                        system.debug('Request'+targetId);
                        request.CFO_Approver__c = targetId;   
                    }
                }
            }
            System.debug('Request'+request);
            if(action == 'Reject'){
                List<gFRS_CAF_Disease_State__c> lstdis=[SELECT Id,Name,Payment_Amount__c,gFRS_CAF_Application__c FROM gFRS_CAF_Disease_State__c WHERE gFRS_CAF_Application__c=:reqId];
                if(lstdis.size()>0&&!lstdis.isEmpty()){
                    for(gFRS_CAF_Disease_State__c DS:lstdis){
                        DS.Payment_Amount__c = 0;
                    }
                }
                request.Date_for_Limit_Calculation__c = null;
                request.Estimated_Current_Revenue__c = null;
                request.Estimated_Donation_Limit__c = null;
				request.Estimated_Remaining_Donation_Limit__c = null;
                request.Total_Payment_Amount__c = null;
                request.YTD_Total_Approved_Donations__c = null;
                request.Compliance_Reviewer_Comments__c = '';
                request.Grant_Reviewer_Comments__c = '';
                request.Grant_Approver_Comments__c = '';
                request.Finance_Approver_Comments__c = '';
                request.VP_Approver_Comments__c = '';
                request.CFO_Approver_Comments__c = '';
                request.Acknowledge_Current_Revenue_33__c = false;
                request.Payment_Type__c = '';
                request.Payment_Method__c = '';
                request.Grant_Reviewer__c = null;
                request.VP_Approver__c = null;
                request.CFO_Approver__c = null;
                request.Finance_Approver__c = null;
                request.Review_Recommendation_Deck_Attachment_ID__c = '';
                request.Vendor_Bank_Reviewed__c = '';
            }
            // UPDATE request;
            //gfrs.id = reqId;
            if(request.Approval_Process_Counter__c==null){
                System.debug('-Inside-'+request.Approval_Process_Counter__c);
                request.Approval_Process_Counter__c=1;
            }
            gFRS_Ltng_Util_NoShare.updateCAFAPP(request);
            submittedReq.setComments(comments);
            submittedReq.setAction(action);
            submittedReq.setWorkitemId(workItemId);
            try{
                Approval.ProcessResult result =  Approval.process(submittedReq);
                system.debug('result status----->>> '+result.getInstanceStatus());
                system.debug('result status----->>> '+result.isSuccess());
                
                gFRS_Ltng_CAF_Application__c gfrs = [Select id,Name,Internal_Sub_Status__c,Approval_Process_Counter__c from gFRS_Ltng_CAF_Application__c  where Id = :request.Id];            
                
                System.debug('-counter->'+gfrs.Approval_Process_Counter__c);
                if(request.Internal_Sub_Status__c == 'Grant Approver 1'){
                    system.debug('GA1 summPDF----->>> 1');
                    String documentName = 'CAF Donation Summary Snapshot'+request.Name+'_V'+gfrs.Approval_Process_Counter__c;
                    system.debug('GA1 summPDF----->>> 2');
                    //generatePDF(reqId,documentName,'Summary');
                    Summary_Snapshot_Flag_PDF_CoPay.generatePDF(reqId,documentName);
                }
                
                system.debug('gfrs.Internal_Sub_Status__c'+gfrs.Internal_Sub_Status__c);
                system.debug('request.Internal_Sub_Status__c'+request.Internal_Sub_Status__c);
                if(request.Internal_Sub_Status__c == 'Compliance Approver'){
                    String compliancedocumentName = 'Compliance_Flags_'+request.Name+'_V'+gfrs.Approval_Process_Counter__c;
                    //generatePDF(request.Id,compliancedocumentName,'Compliance');
                    gFRS_Ltng_Compliance_Flag_Util_CoPay.generatePDF(request.Id,compliancedocumentName);
                }
                if(gfrs.Internal_Sub_Status__c == 'Approved' || gfrs.Internal_Sub_Status__c == 'Cancelled' || gfrs.Internal_Sub_Status__c == 'Denied'){
                    String compliancedocumentName = 'Compliance Flags Snapshot'+request.Name+'_V'+request.Approval_Process_Counter__c;
                    //generatePDF(request.Id,compliancedocumentName,'Compliance');
                    gFRS_Ltng_Compliance_Flag_Util_CoPay.generatePDF(request.Id,compliancedocumentName);
                }
                
                return result.isSuccess();
            } catch(Exception e) {
                system.debug( e.getLineNumber()+':'+e.getMessage());
            } 
            return true;
        }
        else {
            system.assertequals(1,4);
            return false;
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
    public static Boolean approveOrRejectIC(Id reqId,String action,String comments){
        
        ProcessInstanceWorkitem workItem  = [SELECT p.Id, ActorId, OriginalActorId FROM ProcessInstanceWorkitem p where p.ProcessInstance.TargetObjectId =: reqId];
        
        if(workItem != null) {
            gFRS_Ltng_CAF_User__c gfrs = new gFRS_Ltng_CAF_User__c();
            Approval.ProcessWorkitemRequest submittedReq = new Approval.ProcessWorkitemRequest();
            submittedReq.setComments(comments);
            submittedReq.setAction(action);
            submittedReq.setWorkitemId(workItem.Id);
            Approval.ProcessResult result =  Approval.process(submittedReq);
            /*if(result.isSuccess() && action == 'Approve'){
gfrs.Approved_Amount__c = request.Approved_Amount__c;
gfrs.Grant_Review_Committee__c = request.Grant_Review_Committee__c;
gfrs.Legal_Approver__c = request.Legal_Approver__c; 
gfrs.id = reqId;
UPDATE gfrs;
}*/
            return result.isSuccess();
        }else {
            return false;
        }
    }
    
    @AuraEnabled
    public static void updateComments(Id reqId,String Comments){
        gFRS_Ltng_CAF_Application__c gfrsRec = [Select Id,Name,Status__c,Internal_Sub_Status__c FROM gFRS_Ltng_CAF_Application__c WHERE Id =:reqId];
        
        gFRS_Ltng_CAF_Application__c gfrs = new gFRS_Ltng_CAF_Application__c();
        
        //String documentName = 'Compliance_Flags_' + gfrsRec.Name;
        //generatePDF(reqId,documentName);
        
        if(gfrsRec.Internal_Sub_Status__c == 'Grant Approver 1'){
            gfrs.Compliance_Reviewer_Comments__c = Comments;
            //String compliancedocumentName = 'Compliance_Flags_' + gfrsRec.Name;
            //generatePDF(reqId,compliancedocumentName);
        } else if(gfrsRec.Internal_Sub_Status__c == 'Grant Approver 2'){
            gfrs.Grant_Reviewer_Comments__c = Comments;
        } else if(gfrsRec.Internal_Sub_Status__c == 'Finance Approval'){
            gfrs.Grant_Approver_Comments__c = Comments;
        } else if(gfrsRec.Internal_Sub_Status__c == 'VP Approval'){
            gfrs.Finance_Approver_Comments__c = Comments;
        } else if(gfrsRec.Internal_Sub_Status__c == 'CFO Approval'){
            gfrs.VP_Approver_Comments__c = Comments;
        } else if(gfrsRec.Status__c == 'Processing & Disposition'){
            gfrs.CFO_Approver_Comments__c = Comments;
            //String decisiondocumentName = 'Decision_Flags_' + gfrsRec.Name;
            //generatePDF(reqId,decisiondocumentName);
        }
        gfrs.id = reqId;
        try{
            UPDATE gfrs;
        } catch(Exception e) {
            throw new AuraHandledException(e.getLineNumber()+':'+e.getMessage());
        }  
    }
    
    @AuraEnabled
    public static void RecallReq(String comments, Id reqId){
        gFRS_Ltng_CAF_Application__c gfrs = new gFRS_Ltng_CAF_Application__c();
        
        ProcessInstanceWorkitem workItem  = [SELECT Id, ActorId, OriginalActorId FROM ProcessInstanceWorkitem  where ProcessInstance.TargetObjectId =: reqId];
        Approval.ProcessWorkitemRequest submittedReq = new Approval.ProcessWorkitemRequest();  
        submittedReq.setAction('Removed');
        submittedReq.setWorkItemId(workItem.Id);
        Approval.ProcessResult result =  Approval.process(submittedReq);
        gfrs.Status__c = 'Compliance';
        gfrs.Internal_Sub_Status__c = 'New';
        gfrs.id = reqId;
        UPDATE gfrs;
    }
    
    @AuraEnabled
    public static void RecallRequest(String comments, gFRS_Ltng_CAF_Application__c request){
        gFRS_Ltng_CAF_Application__c gfrs = new gFRS_Ltng_CAF_Application__c();
        
        ProcessInstanceWorkitem workItem  = [SELECT Id, ActorId, OriginalActorId FROM ProcessInstanceWorkitem  where ProcessInstance.TargetObjectId =: request.id];
        Approval.ProcessWorkitemRequest submittedReq = new Approval.ProcessWorkitemRequest();  
        gFRS_Ltng_Util_NoShare.updateCAFAPP(request);
        submittedReq.setAction('Removed');
        submittedReq.setWorkItemId(workItem.Id);
        Approval.ProcessResult result =  Approval.process(submittedReq);
    }
    
    @AuraEnabled
    public static Id saveChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId) {
        // check if fileId id ''(Always blank in first chunk), then call the saveTheFile method,
        // Id parentId, String fileName, String base64Data, String contentType, String fileId
        //  which is save the check data and return the attachemnt Id after insert, 
        //  next time (in else) we are call the appentTOFile() method
        //   for update the attachment with reamins chunks   
        System.debug( 'Inside saveChunk:');
        gFRS_Ltng_CAF_Application__c appRec;
        appRec = [Select Id, Name, Internal_Sub_Status__c, Review_Recommendation_Deck_Attachment_ID__c From gFRS_Ltng_CAF_Application__c where id=: parentId];
        System.debug( 'saveChunk Internal_Sub_Status__c:'+appRec.Internal_Sub_Status__c);
        try{
            if (fileId == '') {
                fileId = saveTheFile(parentId, fileName, base64Data, contentType);
            } else {
                appendToFile(fileId, base64Data);
            }
            
            if(fileId != null && appRec.Internal_Sub_Status__c == 'Grant Approver 2'){  
                appRec.Review_Recommendation_Deck_Attachment_ID__c = Id.valueOf(fileId);
                update appRec;
            }
            
            return Id.valueOf(fileId);
            //return parentId;
        }catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
    }
    
    @AuraEnabled    
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType) {
        
        try{
            //gFRS_Ltng_Application__c gfrsApp=new gFRS_Ltng_Application__c();
            //gfrsApp.Id=parentId;
            //gfrsApp.Selected_Tab_Val__c='paymt';
            //update gfrsApp;
            base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');            
            
            Attachment attach = new Attachment();
            attach.parentId = parentId;
            attach.OwnerId = UserInfo.getUserId();
            attach.Body = EncodingUtil.base64Decode(base64Data);
            attach.Name = fileName;
            attach.ContentType = contentType;
            
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
            
            //system.debug('@@@ value of :::'+cDocLink);
            return cDocLink.ContentDocumentId;            
        }catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
        
        
    }
    
    private static void appendToFile(Id fileId, String base64Data) {
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
            
            //gFRS_Ltng_CAF_Application__c appRec = [Select id,name From gFRS_Ltng_CAF_Application__c where id=: appRecId];
            
            //appRec.Compliance_Reviewer_Attachment__c = '';
            //update appRec;                        
            
            system.debug('@@@ Content Doc deleted');
            return true;
        }catch(Exception e){
            system.debug('@@@ Content Doc deletion failure');
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        } 
        
    }    
    
    @AuraEnabled
    public static Boolean generateSummaryPDF(Id reqId){
        gFRS_Ltng_CAF_Application__c request = [Select id,Name,Internal_Sub_Status__c from gFRS_Ltng_CAF_Application__c  where Id = :reqId];            
        if(request.Internal_Sub_Status__c == 'Grant Approver 2'){
            String documentName = 'Summary_PDF_Snapshot_' + request.Name;
            generatePDF(reqId,documentName,'Summary');
        }
        return true;
    }
    @future(callout=true)
    public static void generatePDF(String reqId,String documentName,String VFPage) {
        system.debug('documentName---->'+documentName);
        PageReference pdfPage;
        if(VFPage == 'Compliance'){
            pdfPage = new PageReference('/apex/gFRS_CAF_ComplianceFlagPDF');
        }
        if(VFPage == 'Summary'){
            pdfPage = new PageReference('/apex/gFRS_CoPay_Summary_SnapshotPDF');
        }
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
        
        gFRS_Ltng_CAF_Application__c gfrs = new gFRS_Ltng_CAF_Application__c();
        //if(gfrs.Internal_Sub_Status__c == 'Grant Approver 2'){
        if(VFPage == 'Summary'){
            gfrs.Summary_Snapshot_PDF_ID__c = conDocument;
            gfrs.id = reqId;
            update gfrs;
        }
        //}
    }
    
    @AuraEnabled
    public static void updateCloseRequestSubStatus(Id recId,gFRS_Ltng_CAF_Application__c request){
        gFRS_Ltng_CAF_Application__c gfrs = new gFRS_Ltng_CAF_Application__c();
        
        gfrs.Internal_Sub_Status__c = request.Internal_Sub_Status__c;
        gfrs.Status__c = 'Closed';
        gfrs.Decision_Reasons__c = request.Decision_Reasons__c;
        if(request.Internal_Sub_Status__c == 'Cancelled'){
            gfrs.External_Status__c = 'Canceled';
        } else if(request.Internal_Sub_Status__c == 'Denied'){
            gfrs.External_Status__c = 'Not Funded';
        } else {
            gfrs.Internal_Sub_Status__c = 'Denied';
            gfrs.External_Status__c = 'Not Funded';
        }
        gfrs.id = recId;        
        try{
            update gfrs;
        } catch(Exception e) {
            throw new AuraHandledException(e.getLineNumber()+':'+e.getMessage());
        }  
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
    public static wrapperEmailData getEmailContent(String EmailName, String RecId){
        
        wrapperEmailData returnwrapperClass = new  wrapperEmailData ();
        EmailTemplate  emailCon = [SELECT Subject, Name, Id, Description, Body,DeveloperName
                                   FROM EmailTemplate WHERE DeveloperName = :EmailName ];
        gFRS_Ltng_CAF_Application__c gfrsRequest = [SELECT Id,Name,Owner.Name,Owner.Email,Owner.FirstName,Owner.LastName,Status__c,Decision_Reasons__c FROM gFRS_Ltng_CAF_Application__c Where Id = :RecId];
        
        String emailSub = emailCon.Subject.replace('{!gFRS_Ltng_CAF_Application__c.Name}', gfrsRequest.Name); 
        String body = emailCon.Body.replace('{!gFRS_Ltng_CAF_Application__c.Name}', gfrsRequest.Name); 
        if(!string.isBlank(gfrsRequest.Owner.Name)) {
            body = body.replace('{!gFRS_Ltng_CAF_Application__c.OwnerFullName}',gfrsRequest.Owner.Name);
        }
        //body = string.isNotBlank(gfrsRequest.Event_Program_Title__c) ?
        //  body.replace('{!gFRS_Ltng_Application__c.Event_Program_Title__c}', gfrsRequest.Event_Program_Title__c) : body.replace('{!gFRS_Ltng_Application__c.Event_Program_Title__c}', '');
        
        returnwrapperClass.templateName = emailCon.Name;
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
        @AuraEnabled public String templateName{get;set;}
        
    }
    
    @AuraEnabled
    public static Boolean  sendNotificationEmails(String To,String RecId,String EmailBody,String bcc,String Subject, String cc,String templateName){
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
        
        if(templateName=='gFRS CoPay Canceled at the Request of Applicant'||templateName=='gFRS CoPay Canceld due to the updated request'||templateName=='gFRS CoPay Incorrect Funding Type -Donations CAF'){
            String emailcc=System.Label.gFRS2_0_gFRS_CAF_Email_CC_Email;
            toCCddresses.add(emailcc);
        }
        System.debug('Today-->'+templateName);
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
}