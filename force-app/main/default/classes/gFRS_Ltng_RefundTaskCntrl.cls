public class gFRS_Ltng_RefundTaskCntrl {
    
    @AuraEnabled
    public static gFRS_Ltng_Application__c fetchFundingReqDetails(String reqId){
        Id recId = Id.valueof(reqId);        
        gFRS_Ltng_Application__c appRec = new gFRS_Ltng_Application__c();
        try{
            //appRec = [SELECT Id, Name,Event_Program_Title__c,Approved_Amount__c,Refund_Due__c,Reason_for_refund_due__c,Refund_Amount_Internal__c,Transaction_Check_Number__c,Total_Amount_Used__c  FROM gFRS_Ltng_Application__c WHERE Id =: recId];
            appRec = gFRS_Ltng_Util_NoShare.fetchAppRec(recId);
            return appRec;
        }
        catch(Exception e){ 
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        } 
    } 
    @AuraEnabled
    public static gFRS_Ltng_Application__c updateRefundTaskDetails(gFRS_Ltng_Application__c objAppRec){        
        try{
            gFRS_Ltng_Util_NoShare.updateAppRecord(objAppRec);
            //gFRS_Ltng_Application__c  appRec = [SELECT Id, Name,Approved_Amount__c,Refund_Due__c,Refund_Amount_Internal__c,Transaction_Check_Number__c,Total_Amount_Used__c  FROM gFRS_Ltng_Application__c WHERE Id =:objAppRec.Id];
            gFRS_Ltng_Application__c  appRec = gFRS_Ltng_Util_NoShare.fetchAppRec(objAppRec.Id);
            gFRS_Ltng_Util_NoShare.getFundingAllocationRecord(objAppRec.Id);

            return appRec;
        }
        catch(Exception e){ 
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        } 
    } 
    @AuraEnabled
    public static Id updateApplicationRecd (Id parentId, Id docId, string typOfFile, string contentType) {
        try{ 
            
           /* ContentDocumentLink cDocLink = new ContentDocumentLink();
            cDocLink.ContentDocumentId = docId;//Add ContentDocumentId
            cDocLink.LinkedEntityId = parentId;//Add attachment parentId
            cDocLink.ShareType = 'I';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
            cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
            gFRS_Ltng_Util_NoShare.insertContDocLink(cDocLink);*/
            
            gFRS_Ltng_Application__c objApp =new gFRS_Ltng_Application__c();
            objApp.Id=parentId;  
            
            if(typOfFile == 'Transction Recepit'){
                objApp.id = parentId;
                objApp.Transaction_Receipt_Document__c = docId;
            }
            gFRS_Ltng_Util_NoShare.updateAppRecord(objApp);
            
            return docId;
        } catch (Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
    }
    @AuraEnabled
    public static void deleteAttachment(Id attchId,String attchmentName, Id parentId) {
        try{            
            
            List<ContentDocument> entries = [SELECT id,Title,FileType,CreatedBy.Name,ContentSize FROM ContentDocument WHERE Id =:attchId]; 
            delete entries;            
            
            /* gFRS_Ltng_Application__c objApp = [Select id,Transaction_Receipt_Document__c From gFRS_Ltng_Application__c
                                               where id=: parentId]; */
            gFRS_Ltng_Application__c objApp = new gFRS_Ltng_Application__c();
            
            objApp.id = parentId;
            if(attchmentName=='Attachment'){
                objApp.Transaction_Receipt_Document__c = '';
                
            }
            
            gFRS_Ltng_Util_NoShare.updateAppRecord(objApp);
            
            
        }catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
    }    
    
}