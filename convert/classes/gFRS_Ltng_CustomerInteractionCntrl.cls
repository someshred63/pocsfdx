public class gFRS_Ltng_CustomerInteractionCntrl {
    @AuraEnabled 
    public static user fetchUser(){
        // query current user information  
        User oUser = [select id,Name,Email,FirstName,LastName
                      FROM User Where id =: userInfo.getUserId()];
        return oUser;
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
    public static List<gFRS_Ltng_Application__c> fetchRequestDetails() {
        List<gFRS_Ltng_Application__c> lstApp = new List<gFRS_Ltng_Application__c>();       
        lstApp =[SELECT id, Name,Event_Program_Title__c from gFRS_Ltng_Application__c Where ownerid=:userinfo.getUserId() Limit 50];
        return lstApp;
    }
    
    @AuraEnabled
    public static String saveCustomerRecd( gFRS_Ltng_Customer_Intraction__c objCustRec) {
        SavePoint sp = Database.setSavepoint();
        try{
            objCustRec.RecordTypeId=Schema.SObjectType.gFRS_Ltng_Customer_Intraction__c.getRecordTypeInfosByName().get('Internal Customer').getRecordTypeId();
            objCustRec.Status__c='New';
            insert objCustRec;
            return objCustRec.Id;
        }
        catch(exception e){
            Database.rollback(sp);
            system.debug('@@@:::Msg:::'+e.getMessage());
            system.debug('@@@LineNum:::'+e.getLineNumber());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            system.debug('auraExceptionObj'+auraExceptionObj);
            throw auraExceptionObj; 
            
        }
        
    }
    
    @AuraEnabled 
    public static string createServiceRequest( String recordId){
        HttpResponse response = gFRS_ServiceNowCallout.makeServiceNowCallout();
        System.debug('@@@Response body' +response.getBody());
        return null;
    }
    
    public class picklistWrapper{
        @AuraEnabled 
        public string pickListLabel{get;set;}
        @AuraEnabled 
        public string pickListValue{get;set;}
        
    }
    
    @AuraEnabled
    public static Id saveChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId) {
        // check if fileId id ''(Always blank in first chunk), then call the saveTheFile method,
        //  which is save the check data and return the attachemnt Id after insert,
        //  next time (in else) we are call the appentTOFile() method
        //   for update the attachment with reamins chunks  
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
            WHERE Id =: fileId
        ];
        
        String existingBody = EncodingUtil.base64Encode(a.Body);
        
        a.Body = EncodingUtil.base64Decode(existingBody + base64Data);
        
        update a;
    }
    
    @AuraEnabled
    public static gFRS_Ltng_Customer_Intraction__c saveCustomerExternalRecd( gFRS_Ltng_Customer_Intraction__c objCustRec) {
        SavePoint sp = Database.setSavepoint();
        try{
            objCustRec.RecordTypeId=Schema.SObjectType.gFRS_Ltng_Customer_Intraction__c.getRecordTypeInfosByName().get('External Customer').getRecordTypeId();
            objCustRec.Status__c='New';
            insert objCustRec;
            gFRS_Ltng_Customer_Intraction__c rec = [Select Id,Name FROM gFRS_Ltng_Customer_Intraction__c WHERE Id =:objCustRec.Id ];  
            return rec;
        }
        catch(exception e){
            Database.rollback(sp);
            system.debug('@@@:::Msg:::'+e.getMessage());
            system.debug('@@@LineNum:::'+e.getLineNumber());
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            system.debug('auraExceptionObj'+auraExceptionObj);
            throw auraExceptionObj; 
            
        }
        
    }
    
    
    @AuraEnabled 
    public static String getOrgNameByUser(){
        // query current user information  
        gFRS_Ltng_Organization__c oUserOrg = [select id,Name,Organization_Name__c	
                      FROM gFRS_Ltng_Organization__c Where CreatedById =: userInfo.getUserId() LIMIT 1];
        return oUserOrg.Organization_Name__c;
    }
}