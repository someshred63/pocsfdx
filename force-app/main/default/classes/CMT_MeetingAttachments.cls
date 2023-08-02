@RestResource(urlMapping='/MeetingAttachments/*')
global class CMT_MeetingAttachments
{
    private static final String SERVICE_NAME = 'MeetingAttachments';
    
    @HttpGet
    global static Attachment[] doGet (RestRequest req, RestResponse res)
    {
        String meetingId = getIdFromUrl (SERVICE_NAME, req.requestURI);
        Attachment[] attachments = [SELECT Id FROM Attachment WHERE ParentId in (SELECT Id FROM CMT_Attachment_gne__c WHERE Meeting_gne__r.Id = :meetingId)];
                                             
        return attachments;
    }
    
    private static String getIdFromUrl (String serviceName, String url)
    {
        // extract the part of the URL that starts after the 'SERVICE_NAME/' substring
        String urlPart = url.substring(url.lastIndexOf(serviceName)+serviceName.length()+1);
        String id = urlPart.split('/')[0];
        
        return id;
    }
}