@RestResource(urlMapping='/iPhoneGetContentDocuments/*/Body')
global class iPhone_Get_ContentDocumentBody {
	
	@HttpGet
	global static void getDocumentContent() {
		RestRequest req = RestContext.request;
		String contentId = req.requestURI.substringBetween('/iPhoneGetContentDocuments/', '/Body');
		ContentVersion contentDoc = [SELECT Title, FileExtension, FileType, VersionData FROM ContentVersion WHERE Id = :contentId LIMIT 1];
		RestResponse res = RestContext.response;
		res.addHeader('Content-Type', contentDoc.FileType);
		res.addHeader('content-disposition', 'attachment; filename=\"'+ contentDoc.Title + '.' + contentDoc.FileExtension + '\"');
		res.responseBody = contentDoc.VersionData;
	}
}