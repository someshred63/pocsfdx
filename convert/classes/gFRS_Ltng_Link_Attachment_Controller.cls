public class gFRS_Ltng_Link_Attachment_Controller {
    public class Wrapper1{
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public String ParentId;
        @AuraEnabled
        public Date lastModified;
        @AuraEnabled
        public String createdBy;
    }
    
    @AuraEnabled
    public static List<Wrapper1> attachmentTable(ID recid){
        List<Wrapper1> lstWrapper=new List<Wrapper1>();
        List<ContentDocumentLink> contentDocLink = new List<ContentDocumentLink>();
        map<id,String> userMap = new map<id,String>();
        set<Id> userId = new set<Id>();
        Wrapper1 wr;
        for(Attachment attachment:[SELECT ID,Name,ParentId,LastModifiedDate, CreatedBy.Name FROM Attachment where ParentId=:recid]){
            wr=new Wrapper1();
            wr.Id=attachment.Id;          
            wr.Name=attachment.Name;
            wr.lastModified= Date.ValueOf(attachment.LastModifiedDate);
            wr.createdBy=attachment.CreatedBy.Name;
            wr.ParentId=attachment.ParentId;
            lstWrapper.add(wr);
        }
        contentDocLink = [SELECT ContentDocument.id,ContentDocument.Title,ContentDocument.OwnerId,ContentDocument.LastModifiedDate,LinkedEntityId from ContentDocumentLink where LinkedEntityId=:recId];
        for(ContentDocumentLink cdl:contentDocLink){
            userId.add(cdl.ContentDocument.OwnerId);
        }
        for(user u:[select id,Name from user where id IN:userId]){
            userMap.put(u.id,u.Name);
        }
        for(ContentDocumentLink content:contentDocLink){
            wr=new Wrapper1();  
            wr.Id=content.ContentDocument.id;            
            wr.Name=content.ContentDocument.Title;
            wr.lastModified= Date.ValueOf(content.ContentDocument.LastModifiedDate);            
            wr.createdBy= userMap.get(content.ContentDocument.OwnerId);
            wr.ParentId=content.LinkedEntityId;
            lstWrapper.add(wr);
        }
        
        return lstWrapper;
        
    }
    @AuraEnabled
    public static string fetchSectionNames(ID objectId){
        String sectionNames;
        Schema.SObjectType sObjType = objectId.getSobjectType();
        string objectName = sObjType.getDescribe().getName();
        system.debug('object Name' +objectName);
        gFRS2_0_Link_Attachment_Settings__mdt	linkAttachment = [select SectionNames__c,FieldNames__c from gFRS2_0_Link_Attachment_Settings__mdt where Label=:objectName];
        sectionNames=linkAttachment.SectionNames__c;
        return sectionNames;
        
    }
    @AuraEnabled
    public static  List<fieldWrapper> fetchFieldsNames(String sectionName ,Id recordId){
        system.debug('object Name' +recordId);
        system.debug('object Name' +sectionName);
        Schema.SObjectType sObjType = recordId.getSobjectType();
        string objectName = sObjType.getDescribe().getName();
        system.debug('object Name' +objectName);
        gFRS2_0_Link_Attachment_Settings__mdt	linkAttachment;
        list<fieldWrapper> fieldValue = new list<fieldWrapper>();
        if(objectName=='gFRS_Ltng_Application__c'){
            gFRS_Ltng_Application__c app =[select id,Record_Type__c from gFRS_Ltng_Application__c where id=:recordId];
            if(app.Record_Type__c=='Commercial Sponsorship' || app.Record_Type__c=='Corporate Memberships' || app.Record_Type__c=='Field Exhibits'  || app.Record_Type__c=='Non-Commercial Sponsorship' ){
                linkAttachment = [select FieldNames__c from gFRS2_0_Link_Attachment_Settings__mdt where Label='Application_page_internal FundingType'];
            }else if(app.Record_Type__c=='Independent Medical Education (CME)' || app.Record_Type__c=='Community Giving' || app.Record_Type__c=='Education Focused Giving Graduate and Under Graduate' || app.Record_Type__c=='Education Focused Giving K-12'  || app.Record_Type__c=='Patient and Health Focused Giving'|| app.Record_Type__c=='Scientific and Research Focused Giving'){
                    linkAttachment = [select FieldNames__c from gFRS2_0_Link_Attachment_Settings__mdt where Label='Application_page_ExternalFundingType'];
            }
        }
        else if(objectName =='gFRS_Ltng_Organization__c'){
            linkAttachment = [select FieldNames__c from gFRS2_0_Link_Attachment_Settings__mdt where Label='Location_page'];
        }
        if(sectionName=='LOA'){
            linkAttachment = [select FieldNames__c from gFRS2_0_Link_Attachment_Settings__mdt where Label='LOA'];
        }
        
        List<String> objectAttachmentsFields = new List<String>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType gfrsSchema = schemaMap.get(objectName);
        Map<String, Schema.SObjectField> fieldMap = gfrsSchema.getDescribe().fields.getMap();            
        objectAttachmentsFields = linkAttachment.FieldNames__c.split(',');            
        for (String apiName : objectAttachmentsFields) {
            fieldWrapper aa = new fieldWrapper();
            aa.fieldLabel = fieldMap.get(apiName).getDescribe().getLabel();
            aa.fieldAPIValue = apiName;
            fieldValue.add(aa);
            
        }
        system.debug('fieldValue' +fieldValue);
        return fieldValue;
        
    }
     @AuraEnabled
    public static  string fetchAttachemntNames(Id objectId ,String fieldValue) {
        system.debug('object Name' +objectId); 
        Map<string, string> attachmentLinkMap = new Map<string, string>();
        String attachemntId;
        Schema.SObjectType sObjType = objectId.getSobjectType();
        string objectName = sObjType.getDescribe().getName();
        system.debug('object Name' +objectName);
        String queryString = 'Select ' + fieldValue;
        queryString += ' FROM ' + objectName + ' WHERE Id = \'' + objectId + '\' LIMIT 1';
        if(objectName =='gFRS_Ltng_Organization__c'){
          gFRS_Ltng_Organization__c org= Database.query(queryString);
             system.debug('orgDetails Name' + 'org.'+fieldValue);
            if(fieldValue=='gFRS_W9_Form_W_8BEN_Form__c'){
                    attachemntId=org.gFRS_W9_Form_W_8BEN_Form__c;
                }else if(fieldValue=='Additional_Document__c'){
                   attachemntId=org.Additional_Document__c;
                }
            return attachemntId;
        } else if(objectName =='gFRS_Ltng_Application__c'){
          gFRS_Ltng_Application__c app= Database.query(queryString);
             system.debug('AppDetails Name' +app);
            if(fieldValue=='Event_Program_Documentation__c'){
                    attachemntId=app.Event_Program_Documentation__c;
                }else if(fieldValue=='gFRS_Attachment1__c'){
                   attachemntId=app.gFRS_Attachment1__c;
                }else if(fieldValue=='Additional_Document1__c'){
                    attachemntId=app.Additional_Document1__c;
                }else if(fieldValue=='Additional_Document2__c'){
                    attachemntId=app.Additional_Document2__c;
                }else if(fieldValue=='Additional_Document3__c'){
                    attachemntId=app.Additional_Document3__c;
                }else if(fieldValue=='Additional_Document4__c'){
                    attachemntId=app.Additional_Document4__c;
                }else if(fieldValue=='Additional_Document5__c'){
                    attachemntId=app.Additional_Document5__c;
                }else if(fieldValue=='Executed_LOA_Document_ID__c'){
                    attachemntId=app.Executed_LOA_Document_ID__c;
                }
            return attachemntId;
        } 
        return null;
    }
    @AuraEnabled
    public static boolean attach(ID recid,String attach,String fieldValue){
        Boolean check=false;
        gFRS_Ltng_Application__c app = new gFRS_Ltng_Application__c();
        system.debug('object Name' +recid);         
        Schema.SObjectType sObjType = recid.getSobjectType();
        string objectName = sObjType.getDescribe().getName();
        system.debug('object Name' +objectName);
        System.debug('-recid->'+recid);
        System.debug('-attach->'+attach);
        if (objectName=='gFRS_Ltng_Application__c') {
            List<gFRS_Ltng_Application__c> lstmf=new List<gFRS_Ltng_Application__c>();
            for(gFRS_Ltng_Application__c mf:[SELECT id,Event_Program_Documentation__c,gFRS_Attachment1__c,Sub_Status__c,External_Status__c,Additional_Document1__c,Executed_LOA_Document_ID__c,Additional_Document2__c,Additional_Document3__c,Additional_Document4__c,Additional_Document5__c from gFRS_Ltng_Application__c  where Id=:recid]){
                if(fieldValue=='Event_Program_Documentation__c'){
                    mf.Event_Program_Documentation__c=attach;
                }else if(fieldValue=='gFRS_Attachment1__c'){
                    mf.gFRS_Attachment1__c=attach;
                }else if(fieldValue=='Additional_Document1__c'){
                    mf.Additional_Document1__c=attach;
                }else if(fieldValue=='Additional_Document2__c'){
                    mf.Additional_Document2__c=attach;
                }else if(fieldValue=='Additional_Document3__c'){
                    mf.Additional_Document3__c=attach;
                }else if(fieldValue=='Additional_Document4__c'){
                    mf.Additional_Document4__c=attach;
                }else if(fieldValue=='Additional_Document5__c'){
                    mf.Additional_Document5__c=attach;
                }else if(fieldValue=='Executed_LOA_Document_ID__c'){
                    mf.Executed_LOA_Document_ID__c=attach;
                    mf.Sub_Status__c='Process Payment';
                    mf.External_Status__c='Approved';
                }
                
                lstmf.add(mf);
                
            }
            try{
                gFRS_Ltng_Util_NoShare.updateApplicationRecords(lstmf);              
                check=true;
            }catch(Exception e){
                 check=false;
            }
           
        }else if (objectName=='gFRS_Ltng_Organization__c') {
            List<gFRS_Ltng_Organization__c> lstOrg=new List<gFRS_Ltng_Organization__c>();
            for(gFRS_Ltng_Organization__c org:[SELECT id,gFRS_W9_Form_W_8BEN_Form__c,Additional_Document__c from gFRS_Ltng_Organization__c  where Id=:recid]){
                if(fieldValue=='gFRS_W9_Form_W_8BEN_Form__c'){
                    org.gFRS_W9_Form_W_8BEN_Form__c=attach;
                }else if(fieldValue=='Additional_Document__c'){
                    org.Additional_Document__c=attach;
                }
                lstOrg.add(org);
                
            }
            try{
              update lstOrg; 
                check=true;
            }catch(Exception e){
                 check=false;
            }
        }
        return check;
    }
    public class fieldWrapper{
        @AuraEnabled 
        public string fieldLabel{get;set;}
        @AuraEnabled 
        public string fieldAPIValue{get;set;}
        
    }
    
    @AuraEnabled
    public static gFRS_Ltng_Application__c fetchLOAUser(ID objectId){
        return [Select Id,Name,LOA_Performed_By__c,Purpose_of_offline_LOA__c FROM gFRS_Ltng_Application__c WHERE Id =:objectId ];
    }
    
    @AuraEnabled
    public static void updateLOASignedDate(ID objectId){
        gFRS_Ltng_Application__c gfrs = [Select Id,Name,LOA_Signed_Date__c FROM gFRS_Ltng_Application__c WHERE Id =:objectId];
        gfrs.LOA_Signed_Date__c = system.today();
        
    	try{
            update gfrs;
        } catch(Exception e) {
            throw new AuraHandledException(e.getLineNumber()+':'+e.getMessage());
        }
    }
    
    
    
    
    
}