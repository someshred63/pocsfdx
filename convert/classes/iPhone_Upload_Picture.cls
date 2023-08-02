/***********************************************************************************************
*  @author: Lukasz Kozminski, Roche (contractor)
*  @email: lukasz.kozminski@contractors.roche.com   
*  Created: 2017-02-14
*  Project: 
*  Description: REST Webservice for uploading pictures to user or hcp account. 
************************************************************************************************/

@RestResource(urlMapping='/iPhoneUploadPicture/*')
global without sharing class iPhone_Upload_Picture {
	
	private static final String UPLOAD_ACTION = 'UPLOAD';
	private static final String CLEAR_ACTION = 'DELETE';

	@HttpPost
	global static iPhone_Commons_gne.RestResponse processRequest(iPhone_Upload_Picture.UploadPictureRequest request){
		return iPhone_Commons_gne.buildResponse (
        	new GetUploadPhotoResponseBuilder(),
            request
        );
    }
    
    class GetUploadPhotoResponseBuilder implements iPhone_Commons_gne.ResponseBuilder {

        public iPhone_Commons_gne.RestResponse build(Object args) {
        	GetUploadPhotoResponse response;
        	iPhone_Upload_Picture.UploadPictureRequest request = (iPhone_Upload_Picture.UploadPictureRequest)args;
            if(request.action.equalsIgnoreCase(UPLOAD_ACTION) && String.isNotEmpty(request.userId)) {
				try{
					String fileData = request.body.substring(request.body.indexOf(',')+1,request.body.length());
					Blob body = EncodingUtil.base64Decode(fileData);
					ConnectApi.BinaryInput fileUpload = new ConnectApi.BinaryInput(body, request.contentType, request.filename);
					ConnectApi.Photo photo = ConnectApi.UserProfiles.setPhoto(null, request.userId, fileUpload);
					response = new GetUploadPhotoResponse(photo);
				} catch(Exception ex){
					throw new iPhone_Commons_gne.IPhoneException('Upload photo failed: ' + ex);
				}
			} else if (request.action.equalsIgnoreCase(CLEAR_ACTION) && String.isNotEmpty(request.userId)){
				try{
					ConnectApi.UserProfiles.deletePhoto(null, request.userId);
				} catch(Exception ex){
					throw new iPhone_Commons_gne.IPhoneException('Delete photo failed: ' + ex);
				}
			}else if(request.action.equalsIgnoreCase(UPLOAD_ACTION) && String.isNotEmpty(request.accountId)) {
				try{
					String fileData = request.body.substring(request.body.indexOf(',')+1, request.body.length());
					String pictureId = getPictureId(request.accountId);
					if(pictureId != null){
						delete new Attachment(id = pictureId);
					}
					Attachment pictureFileAttach = new Attachment(ParentId = request.accountId);
					pictureFileAttach.Name = request.filename;
					pictureFileAttach.Body = EncodingUtil.Base64Decode(fileData);
					pictureFileAttach.contentType = request.contentType;
					insert pictureFileAttach;
					Account acc = new Account(id = request.accountId, Picture_File_Id_gne__c= pictureFileAttach.Id);
					update acc;
					response = new GetUploadPhotoResponse(pictureFileAttach.id);
				} catch(Exception ex){
					throw new iPhone_Commons_gne.IPhoneException('Upload account photo failed: ' + ex);
				}
			} else if (request.action.equalsIgnoreCase(CLEAR_ACTION) && String.isNotEmpty(request.accountId)){
				try{
					Account acc = [Select id, Picture_File_Id_gne__c FROM Account WHERE Id = :request.accountId];
					delete new Attachment(id = acc.Picture_File_Id_gne__c);
					acc.Picture_File_Id_gne__c = null;
					update acc;
				} catch(Exception ex){
					throw new iPhone_Commons_gne.IPhoneException('Delete account photo failed: ' + ex);
				}
			} else {
				throw new iPhone_Commons_gne.IPhoneException('No valid action found: ' + request.action);
			}
			if(response == null){
				response = new GetUploadPhotoResponse();
			}
            return response;
        }
    }
    
    public static String getPictureId(Id accountId){
    	return [Select id, Picture_File_Id_gne__c FROM Account WHERE Id = :accountId].Picture_File_Id_gne__c;
    }

	public class GetUploadPhotoResponse extends iPhone_Commons_gne.RestResponse {
		private String photoUrl;
		
		public GetUploadPhotoResponse() {
        }

        public GetUploadPhotoResponse(String attachmentId) {
        	this.photoUrl = '/services/data/v36.0/sobjects/Attachment/' + attachmentId + '/Body';
        }
        
        public GetUploadPhotoResponse(ConnectApi.Photo photo) {
        	this.photoUrl = photo.smallPhotoUrl;
        }
    }

	global class UploadPictureRequest{
		public String action;
		public String userId;
		public String accountId;
		public String body;
		public String contentType;
		public String filename;
	}
}