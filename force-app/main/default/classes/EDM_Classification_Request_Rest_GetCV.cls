@RestResource(urlMapping='/S2S/ClassificationRequests/*/CV')
global with sharing  class EDM_Classification_Request_Rest_GetCV
{
	@HttpGet
	global static void getClassificationRequestCV() {
		RestRequest req = RestContext.request;
		String classificationRequestId = req.requestURI.substringBetween('/ClassificationRequests/', '/CV');

		Attachment attach = [SELECT name, body, ContentType FROM attachment WHERE parentId = :classificationRequestId LIMIT 1];
		RestResponse res = RestContext.response;
		res.addHeader('Content-Type', attach.ContentType);
		res.addHeader('content-disposition', 'attachemnt; filename=\"'+ attach.name +'\"');
		res.responseBody = attach.body;
	}
}