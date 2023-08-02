global with sharing class GNE_AP_File_Upload_Controller {
	
	public GNE_AP_File_Upload_Controller(ApexPages.StandardController controller) {
		
	}

	@RemoteAction
    global static String attachBlob(String parentId, String attachmentId, String tempAttachId, String fileName, String contentType, String base64BlobValue){
        if(tempAttachId != '' && tempAttachId != null){
            delete [SELECT Id FROM Attachment WHERE Id =: tempAttachId];
        }
        //If recordId is blank this is the first part of a multi piece upload
        if(attachmentId == '' || attachmentId == null){
            Attachment att = new Attachment(
                ParentId = parentId,
                Body = EncodingUtil.Base64Decode(base64BlobValue),
                Name = fileName,
                ContentType = contentType
            );
            insert att;
            
            //Return the new attachment Id
            return att.Id;
            
        }else{
            for(Attachment atm : [SELECT Id, Body FROM Attachment WHERE Id = :attachmentId]){
                //Take the body of the current attachment, convert to base64 string, append base64 value sent from page, then convert back to binary for the body
                update new Attachment(Id = attachmentId, Body = EncodingUtil.Base64Decode(EncodingUtil.Base64Encode(atm.Body) + base64BlobValue));
            }
            
            //Return the Id of the attachment we are currently processing
            return attachmentId;
        }
    }
}