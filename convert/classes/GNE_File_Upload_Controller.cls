global with sharing class GNE_File_Upload_Controller {
    
    public String sfdcBaseURL {get;set;}
	
	public GNE_File_Upload_Controller() {
		sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
	}
	
    @RemoteAction
    global static String attachBlob(String parentId, String temporaryCallId, String attachmentId, String fileName, String contentType, String base64BlobValue){
               
        //If recordId is blank this is the first part of a multi piece upload
        if(attachmentId == '' || attachmentId == null){
            Attachment att = new Attachment(
                ParentId = parentId,
                Body = EncodingUtil.Base64Decode(base64BlobValue),
                Name = fileName,
                ContentType = contentType,
                Description = temporaryCallId
            );
            insert att;
            
            //Return the new attachment Id
            return att.Id;
            
        }else{
            for(Attachment atm : [select Id, Body from Attachment where Id = :attachmentId]){
                //Take the body of the current attachment, convert to base64 string, append base64 value sent from page, then convert back to binary for the body
                update new Attachment(Id = attachmentId, Body = EncodingUtil.Base64Decode(EncodingUtil.Base64Encode(atm.Body) + base64BlobValue));
            }
            
            //Return the Id of the attachment we are currently processing
            return attachmentId;
        }
    }
    
    @RemoteAction
    global static void removeAttachment(String attachmentId){
        if(attachmentId != '' && attachmentId != null) {
            Attachment attachment = [SELECT Id from Attachment where Id =: attachmentId];
            if(attachment != null) {
                delete attachment;
            }
        }
    }
    
    @RemoteAction
    global static void removeAllAttachments(List<String> attachIdList){
        if(!attachIdList.isEmpty()) {
            List<Attachment> attachmentsList = [SELECT Id from Attachment where Id IN : attachIdList];
            if(!attachmentsList.isEmpty()) {
                delete attachmentsList;
            }
        }
    }
    
}