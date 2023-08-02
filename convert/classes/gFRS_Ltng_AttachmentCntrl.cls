public class gFRS_Ltng_AttachmentCntrl {
    
    @AuraEnabled    
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType) {
        
        try{

            base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');            
            
            Attachment attach = new Attachment();
            attach.parentId = parentId;
            attach.OwnerId = UserInfo.getUserId();
            attach.Body = EncodingUtil.base64Decode(base64Data);
            attach.Name = fileName;
            attach.ContentType = contentType;
            
            insert attach;
            
            //Insert ContentVersion
            /* ContentVersion cVersion = new ContentVersion();
            cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
            cVersion.PathOnClient = attach.Name;//File name with extention
            cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
            cVersion.OwnerId = attach.OwnerId;//Owner of the file
            cVersion.Title = attach.Name;//Name of the file
            cVersion.VersionData = attach.Body;//File content
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
            
            system.debug('@@@ value of :::'+cDocLink); */
            
            return attach.Id;            
        }catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
        
        
    }
    
    @AuraEnabled
    public static void deleteAttachment(Id attchId, string attchmentName,Id parentId) {
        try{            

            //Id parentId = [SELECT LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId =:attchId Limit 1].LinkedEntityId;
            List<ContentDocument> entries = [SELECT id,Title,FileType,CreatedBy.Name,ContentSize FROM ContentDocument WHERE Id =:attchId]; 
            delete entries;            
            
            gFRS_Ltng_Application__c objApp = [Select id,gFRS_Attachment1__c,gFRS_Attachment2__c,gFRS_Attachment3__c,CME_Additional_Document1__c,CME_Additional_Document2__c,Event_Program_Documentation__c,Additional_Document1__c,Additional_Document2__c,Additional_Document3__c,Additional_Document4__c,Additional_Document5__c From gFRS_Ltng_Application__c
                                               where id=: parentId];
            
            if(attchmentName == 'Meeting agendas'){
                objApp.id = parentId;
                objApp.gFRS_Attachment1__c = '';
            }else if(attchmentName == 'Needs assessment document'){
                objApp.id = parentId;
                objApp.gFRS_Attachment2__c = '';
            }else if(attchmentName == 'Implementation plan'){
                objApp.id = parentId;
                objApp.gFRS_Attachment3__c = '';
            }else if(attchmentName == 'CME Addnl Document 4'){
                objApp.id = parentId;
                objApp.CME_Additional_Document1__c = '';
            }else if(attchmentName == 'CME Addnl Document 5'){
                objApp.id = parentId;
                objApp.CME_Additional_Document2__c = '';
            }else if(attchmentName == 'Additional Document 1'){
                objApp.id = parentId;
                objApp.Additional_Document1__c = '';
            }else if(attchmentName == 'Additional Document 2'){
                objApp.id = parentId;
                objApp.Additional_Document2__c = '';
            }else if(attchmentName == 'Additional Document 3'){
                objApp.id = parentId;
                objApp.Additional_Document3__c = '';
            }else if(attchmentName == 'Additional Document 4'){
                objApp.id = parentId;
                objApp.Additional_Document4__c = '';
            }else if(attchmentName == 'Additional Document 5'){
                objApp.id = parentId;
                objApp.Additional_Document5__c = '';
            }else if(attchmentName == 'Event/Program Documentation'){
                objApp.id = parentId;
                objApp.Event_Program_Documentation__c = '';
            }
            
            //upsert objApp;
            gFRS_Ltng_Util_NoShare.updateAppRecord(objApp);

        }catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
    }    
    
    @AuraEnabled
    public static Id saveChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId,String typOfFile,String status) {
        try{  
            if(status != 'completed'){
                if (fileId == '') {
                    fileId = saveTheFile(parentId, fileName, base64Data, contentType);
                    system.debug('@@@:::'+fileId);
                } else {
                    fileId = appendToFile(fileId, base64Data);
                }            
            } else {
                fileId = saveTheContentVersion(parentId, fileName, base64Data, contentType, typOfFile, fileId);
                if(fileId != null && String.isNotBlank(typOfFile)){
                    gFRS_Ltng_Application__c objApp = [Select id,gFRS_Attachment1__c,gFRS_Attachment2__c,gFRS_Attachment3__c,CME_Additional_Document1__c,CME_Additional_Document2__c,Event_Program_Documentation__c,Additional_Document1__c,Additional_Document2__c,Additional_Document3__c,Additional_Document4__c,Additional_Document5__c From gFRS_Ltng_Application__c
                                                       where id=: parentId];
                    if(typOfFile == 'Meeting agendas'){
                        objApp.id = parentId;
                        objApp.gFRS_Attachment1__c = Id.valueOf(fileId);
                    }else if(typOfFile == 'Needs assessment document'){
                        objApp.id = parentId;
                        objApp.gFRS_Attachment2__c = Id.valueOf(fileId);
                    }else if(typOfFile == 'Implementation plan'){
                        objApp.id = parentId;
                        objApp.gFRS_Attachment3__c = Id.valueOf(fileId);
                    }else if(typOfFile == 'CME Addnl Document 4'){
                        objApp.id = parentId;
                        objApp.CME_Additional_Document1__c = Id.valueOf(fileId);
                    }else if(typOfFile == 'CME Addnl Document 5'){
                        objApp.id = parentId;
                        objApp.CME_Additional_Document2__c = Id.valueOf(fileId);
                    }else if(typOfFile == 'Additional Document 1'){
                        objApp.id = parentId;
                        objApp.Additional_Document1__c = Id.valueOf(fileId);
                    }else if(typOfFile == 'Additional Document 2'){
                        objApp.id = parentId;
                        objApp.Additional_Document2__c = Id.valueOf(fileId);
                    }else if(typOfFile == 'Additional Document 3'){
                        objApp.id = parentId;
                        objApp.Additional_Document3__c = Id.valueOf(fileId);
                    }else if(typOfFile == 'Additional Document 4'){
                        objApp.id = parentId;
                        objApp.Additional_Document4__c = Id.valueOf(fileId);
                    }else if(typOfFile == 'Additional Document 5'){
                        objApp.id = parentId;
                        objApp.Additional_Document5__c = Id.valueOf(fileId);
                    }else if(typOfFile == 'Event/Program Documentation'){
                        objApp.id = parentId;
                        objApp.Event_Program_Documentation__c = Id.valueOf(fileId);
                    }
                    //upsert objApp;
                    objApp.Selected_Tab_Val__c='paymt';
                    gFRS_Ltng_Util_NoShare.updateAppRecord(objApp);
                }
            }
            return Id.valueOf(fileId);
        }catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
    }
 @AuraEnabled
    public static Id updateApplicationRecd (Id parentId, Id docId, string typOfFile, string contentType) {
        try{ 
            gFRS_Ltng_Application__c objApp =new gFRS_Ltng_Application__c();
            	objApp.Id=parentId;                   
                    if(typOfFile == 'Meeting agendas'){
                        objApp.id = parentId;
                        objApp.gFRS_Attachment1__c = docId;
                    }else if(typOfFile == 'Needs assessment document'){
                        objApp.id = parentId;
                        objApp.gFRS_Attachment2__c = docId;
                    }else if(typOfFile == 'Implementation plan'){
                        objApp.id = parentId;
                        objApp.gFRS_Attachment3__c = docId;
                    }else if(typOfFile == 'CME Addnl Document 4'){
                        objApp.id = parentId;
                        objApp.CME_Additional_Document1__c = docId;
                    }else if(typOfFile == 'CME Addnl Document 5'){
                        objApp.id = parentId;
                        objApp.CME_Additional_Document2__c = docId;
                    }else if(typOfFile == 'Additional Document 1'){
                        objApp.id = parentId;
                        objApp.Additional_Document1__c = docId;
                    }else if(typOfFile == 'Additional Document 2'){
                        objApp.id = parentId;
                        objApp.Additional_Document2__c = docId;
                    }else if(typOfFile == 'Additional Document 3'){
                        objApp.id = parentId;
                        objApp.Additional_Document3__c = docId;
                    }else if(typOfFile == 'Additional Document 4'){
                        objApp.id = parentId;
                        objApp.Additional_Document4__c = docId;
                    }else if(typOfFile == 'Additional Document 5'){
                        objApp.id = parentId;
                        objApp.Additional_Document5__c = docId;
                    }else if(typOfFile == 'Event/Program Documentation'){
                        objApp.id = parentId;
                        objApp.Event_Program_Documentation__c = docId;
                    }
                    //upsert objApp;
                    objApp.Selected_Tab_Val__c='paymt';
                    gFRS_Ltng_Util_NoShare.updateAppRecord(objApp);
            		return docId;
        }catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
    }
    
    public static Id saveTheContentVersion(Id parentId, String fileName, String base64Data, String contentType,String typOfFile, Id fileId) {
        //base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');

        try{
            Attachment attach = new Attachment();
            attach = [SELECT Id, Name, parentId, OwnerId, Body, ContentType FROM Attachment WHERE Id =: fileId];
            /* attach.parentId = parentId;
            attach.OwnerId = UserInfo.getUserId();
            attach.Body = EncodingUtil.base64Decode(base64Data);
            attach.Name = fileName;
            attach.ContentType = contentType; */
            
            //insert attach;
            
            //Insert ContentVersion
            ContentVersion cVersion = new ContentVersion();
            cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
            cVersion.PathOnClient = attach.Name;//File name with extention
            cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
            cVersion.OwnerId = attach.OwnerId;//Owner of the file
            cVersion.Title = attach.Name;//Name of the file
            cVersion.VersionData = attach.Body;//File content
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
            
            delete attach;
            
            return cDocLink.ContentDocumentId;
            
        } catch(Exception ex){
            system.debug('@@@ exception::'+ex.getMessage());
            return null;
        }

    }           
    
    private static Id appendToFile(Id fileId, String base64Data) {
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
            
            return a.Id;
        }catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
    }
    @AuraEnabled
    public static fileResWrapper getAttachmentDetails(String appId) {
        fileResWrapper filewp = new fileResWrapper();
        try{
            gFRS_Ltng_Application__c objApp=[SELECT id,gFRS_Attachment1__c,gFRS_Attachment2__c,gFRS_Attachment3__c,CME_Additional_Document1__c,CME_Additional_Document2__c,Event_Program_Documentation__c,Additional_Document1__c,Additional_Document2__c,Additional_Document3__c,Additional_Document4__c,Additional_Document5__c from gFRS_Ltng_Application__c  where Id=:appId] ;
            system.debug('attList'+objApp);
            if(String.isNotBlank(objApp.gFRS_Attachment1__c)){
                ContentDocument a = [
                SELECT id,Title,FileType,CreatedBy.Name,ContentSize FROM ContentDocument WHERE Id =: objApp.gFRS_Attachment1__c]; 
                system.debug('file1'+a.Title);
                filewp.file1 = a.Title;
                filewp.file1Id = a.Id;
                filewp.fileType1=a.FileType;
            } if(String.isNotBlank(objApp.gFRS_Attachment2__c)){
                ContentDocument a = [
                SELECT id,Title,FileType,CreatedBy.Name,ContentSize FROM ContentDocument WHERE Id =: objApp.gFRS_Attachment2__c]; 
                filewp.file2 = a.Title;
                filewp.file2Id = a.Id;
                filewp.fileType2=a.FileType;
                system.debug('file2'+a.Title);
            } if(String.isNotBlank(objApp.gFRS_Attachment3__c)){
                ContentDocument a = [
                SELECT id,Title,FileType,CreatedBy.Name,ContentSize FROM ContentDocument WHERE Id =: objApp.gFRS_Attachment3__c]; 
                filewp.file3 = a.Title;
                filewp.file3Id = a.Id;
                filewp.fileType3=a.FileType;
                system.debug('file3'+a.Title);
            } if(String.isNotBlank(objApp.CME_Additional_Document1__c)){
                ContentDocument a = [
                SELECT id,Title,FileType,CreatedBy.Name,ContentSize FROM ContentDocument WHERE Id =: objApp.CME_Additional_Document1__c]; 
                filewp.file4 = a.Title;
                filewp.file4Id = a.Id;
                filewp.fileType4=a.FileType;
                system.debug('file4'+a.Title);
            } if(String.isNotBlank(objApp.CME_Additional_Document2__c)){
                ContentDocument a = [
                SELECT id,Title,FileType,CreatedBy.Name,ContentSize FROM ContentDocument WHERE Id =: objApp.CME_Additional_Document2__c]; 
                filewp.file5 = a.Title;
                filewp.file5Id = a.Id;
                filewp.fileType5=a.FileType;
                system.debug('file5'+a.Title);
            } if(String.isNotBlank(objApp.Event_Program_Documentation__c)){
                ContentDocument a = [
                SELECT id,Title,FileType,CreatedBy.Name,ContentSize FROM ContentDocument WHERE Id =: objApp.Event_Program_Documentation__c]; 
                filewp.file6 = a.Title;
                filewp.file6Id = a.Id;
                filewp.fileType6=a.FileType;
                system.debug('file6'+a.Title);
            } if(String.isNotBlank(objApp.Additional_Document1__c)){
                ContentDocument a = [
                SELECT id,Title,FileType,CreatedBy.Name,ContentSize FROM ContentDocument WHERE Id =: objApp.Additional_Document1__c]; 
                filewp.addnlfile1 = a.Title;
                filewp.addnlfile1Id = a.Id;
                filewp.addfileType1=a.FileType;
                system.debug('addnlfile1'+a.Title);
            } if(String.isNotBlank(objApp.Additional_Document2__c)){
                ContentDocument a = [
                SELECT id,Title,FileType,CreatedBy.Name,ContentSize FROM ContentDocument WHERE Id =: objApp.Additional_Document2__c]; 
                filewp.addnlfile2 = a.Title;
                filewp.addnlfile2Id = a.Id;
                filewp.addfileType2=a.FileType;
                system.debug('addnlfile2'+a.Title);
            } if(String.isNotBlank(objApp.Additional_Document3__c)){
                ContentDocument a = [
                SELECT id,Title,FileType,CreatedBy.Name,ContentSize FROM ContentDocument WHERE Id =: objApp.Additional_Document3__c]; 
                filewp.addnlfile3 = a.Title;
                filewp.addnlfile3Id = a.Id;
                filewp.addfileType3=a.FileType;
                system.debug('addnlfile3'+a.Title);
            } if(String.isNotBlank(objApp.Additional_Document4__c)){
                ContentDocument a = [
                SELECT id,Title,FileType,CreatedBy.Name,ContentSize FROM ContentDocument WHERE Id =: objApp.Additional_Document4__c]; 
                filewp.addnlfile4 = a.Title;
                filewp.addnlfile4Id = a.Id;
                filewp.addfileType4=a.FileType;
                system.debug('addnlfile4'+a.Title);
            } if(String.isNotBlank(objApp.Additional_Document5__c)){
                ContentDocument a = [
                SELECT id,Title,FileType,CreatedBy.Name,ContentSize FROM ContentDocument WHERE Id =: objApp.Additional_Document5__c]; 
                filewp.addnlfile5 = a.Title;
                filewp.addnlfile5Id = a.Id;
                filewp.addfileType5=a.FileType;
                system.debug('addnlfile5'+a.Title);
            }
            
            system.debug('allfiles'+filewp);
            return filewp;
        }catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }
    }
    public class fileResWrapper{        
        @AuraEnabled public String file1{get;set;} 
        @AuraEnabled public Id file1Id{get;set;} 
        @AuraEnabled public String file2{get;set;}
        @AuraEnabled public Id file2Id{get;set;} 
        @AuraEnabled public String file3{get;set;}
        @AuraEnabled public Id file3Id{get;set;} 
        @AuraEnabled public String file4{get;set;}
        @AuraEnabled public Id file4Id{get;set;} 
        @AuraEnabled public String file5{get;set;}
        @AuraEnabled public Id file5Id{get;set;}
        @AuraEnabled public String file6{get;set;}
        @AuraEnabled public Id file6Id{get;set;}        
        @AuraEnabled public String addnlfile1{get;set;}
        @AuraEnabled public Id addnlfile1Id{get;set;} 
        @AuraEnabled public String addnlfile2{get;set;}
        @AuraEnabled public Id addnlfile2Id{get;set;} 
        @AuraEnabled public String addnlfile3{get;set;}
        @AuraEnabled public Id addnlfile3Id{get;set;} 
        @AuraEnabled public String addnlfile4{get;set;}
        @AuraEnabled public Id addnlfile4Id{get;set;} 
        @AuraEnabled public String addnlfile5{get;set;}
        @AuraEnabled public Id addnlfile5Id{get;set;}         
        @AuraEnabled public String fileType1{get;set;}
         @AuraEnabled public String fileType2{get;set;}
         @AuraEnabled public String fileType3{get;set;}
         @AuraEnabled public String fileType4{get;set;}
        @AuraEnabled public String fileType5{get;set;}
        @AuraEnabled public String fileType6{get;set;}
        @AuraEnabled public String addfileType1{get;set;}
         @AuraEnabled public String addfileType2{get;set;}
         @AuraEnabled public String addfileType3{get;set;}
         @AuraEnabled public String addfileType4{get;set;}
         @AuraEnabled public String addfileType5{get;set;}
    } 

    @AuraEnabled
    public static gFRS_Ltng_Application__c getFundingReqDetails(String appId){

        Id rId = appId;
        DescribeSObjectResult describeResult = rId.getSObjectType().getDescribe();      
        List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );	
        String query =	  ' SELECT ' +	      String.join( fieldNames, ',' ) +	  ' FROM ' +	      describeResult.getName() +	  ' WHERE ' +	      ' id = :rId ' +	  ' LIMIT 1 '	;	
        gFRS_Ltng_Application__c appRec = Database.query( query );
        return appRec;
    
    } 

    @AuraEnabled
    public static pgmTypeWrapper getPgmTypeDetails(String appId){
        try{
            pgmTypeWrapper pgmTypeWrap = new pgmTypeWrapper();
            list<gFRS_Ltng_Program__c> livePgmList = new list<gFRS_Ltng_Program__c>();
            list<gFRS_Ltng_Program__c> fellowPgmList = new list<gFRS_Ltng_Program__c>();
            livePgmList = [SELECT Id, name, gFRS_Program_Type__c FROM gFRS_Ltng_Program__c WHERE gFRS_Application__c =: appId and gFRS_Program_Type__c = 'Live (in-person)'];
            fellowPgmList = [SELECT Id, name, gFRS_Program_Type__c FROM gFRS_Ltng_Program__c WHERE gFRS_Application__c =: appId and gFRS_Application__r.Record_Type_Name__c = 'Education Focused Giving' and gFRS_Application__r.Funding_Sub_Type__c = 'Graduate and Post-Graduate' and gFRS_Sub_Focus_Area__c = 'Fellowships'];
            
            if(livePgmList.size() > 0){
                pgmTypeWrap.livePgm = true;
                //return true;
            } else {
                pgmTypeWrap.livePgm = false;
                //return false;
            }
            
            if(fellowPgmList.size() > 0){
                pgmTypeWrap.fellowshipPgm = true;
                //return true;
            } else {
                pgmTypeWrap.fellowshipPgm = false;
                //return false;
            }
            return pgmTypeWrap;
        }
        catch(Exception e){
            AuraHandledException auraExceptionObj = new AuraHandledException(e.getMessage());
            throw auraExceptionObj;              
        }        
    }     
    
    public class pgmTypeWrapper{        
        @AuraEnabled public boolean livePgm{get;set;} 
        @AuraEnabled public boolean fellowshipPgm{get;set;}               
    }     
    
    @AuraEnabled
    public static String fetchDocId(String funding,String focusarea){
        String str;
        if(funding == 'Foundation Safety Net Support' || funding == 'Foundation Undergraduate'){
            str=[select id,DeveloperName  from Document where DeveloperName='Attachment_Template_Foundation'].id;    
        }
        return str;
    }
}