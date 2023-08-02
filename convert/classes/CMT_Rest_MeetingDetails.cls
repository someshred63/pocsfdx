@RestResource(urlMapping='/MeetingDetails/*')
global class CMT_Rest_MeetingDetails
{
    public static final String SERVICE_NAME = 'MeetingDetails';
    
    @HttpGet
    global static String doGetMeeting (RestRequest req, RestResponse res)
    {
        String meetingId = CMT_RESTUtils.getIdFromUrl (SERVICE_NAME, req.requestURI);
        String syncDate = CMT_RESTUtils.getDeltaParam(req);
        
        System.debug('Request URI = ' + req.requestURI + ', meetingId = ' + meetingId + ', syncDate = ' + syncDate);
        
        //return CMT_Meeting_Collections.convertSyncDateToOrgTimezone(DateTime.valueOf(syncDate));//.format('yyyy-MM-dd hh:mm:ss');
        
        if (syncDate != null && syncDate != '')
        {
            Datetime parsedSyncDate = null;
            try
            {
                parsedSyncDate = DateTime.valueOf(syncDate);
            }
            catch (Exception e)
            {
                return CMT_JSONUtils.format(new JSONError('Incorrect date time format: \'' + syncDate + '\''));
            }
            
            try
            {
                return getMeetingDelta (meetingId, parsedSyncDate);
            }
            catch (CMT_Exception e)
            {
                // return an error message
                return CMT_JSONUtils.format(new JSONError(e.getMessage()));
            }
        }
        else
        {
            return getMeetingData(meetingId);
        }
    }
    
    private static String getMeetingDelta (String meetingId, Datetime syncDate)
    {
        CMT_Meeting_gne__c meeting = getMeetingById (meetingId, syncDate);
      
        if (meeting != null)
        {
            CMT_Meeting_Collections wrappedMeeting = new CMT_Meeting_Collections(meeting, syncDate);
            System.debug('serializePretty');
            wrappedMeeting.setServerInfo(new CMT_ServerInfo(meetingId, CMT_MiscUtils.getCurrentUserTime()));
            return CMT_JSONUtils.format(wrappedMeeting);
        }
        else
        {
            throw new CMT_Exception('Meeting with ID = \'' + meetingId + '\' not found');
        } 
    }
    
    private static String getMeetingData (String meetingId)
    {
        CMT_Meeting_gne__c meeting = getMeetingById (meetingId, null);
      
        if (meeting != null)
        {
            CMT_Meeting_Collections wrappedMeeting = new CMT_Meeting_Collections(meeting);
            wrappedMeeting.setServerInfo(new CMT_ServerInfo(meetingId, CMT_MiscUtils.getCurrentUserTime()));
            return CMT_JSONUtils.format(wrappedMeeting);
        }
        else
        {
            return '';
        }                                                            
    }
    
    // Get the meeting using SOQL and returns it
    private static CMT_Meeting_gne__c getMeetingById (String meetingId, DateTime syncDate)
    {
        syncDate = syncDate != null ? syncDate : DateTime.valueOf('1900-01-01 00:00:00');
        
        List<CMT_Meeting_gne__c> meetings = [SELECT Id, Name,
                                                     (SELECT Id, Name FROM Meet_Green_Groups__r LIMIT 1),
                                                     (SELECT Id, Name FROM Transportation_Groups__r LIMIT 1),
                                                     (SELECT Id, Name FROM Contact_Category_Groups__r LIMIT 1),
                                                     (SELECT Id, Name FROM Abstract_Category_Groups__r LIMIT 1),
                                                     (SELECT Id, Name FROM Information_Groups__r LIMIT 1),
                                                     (SELECT Id, Name FROM Expo_Groups__r LIMIT 1),
                                                     (SELECT Id, Name FROM Exhibit_Groups__r LIMIT 1),
                                                     (SELECT Id, Name FROM Event_Groups__r LIMIT 1),
                                                     (SELECT Id, Name FROM Announcement_Groups__r LIMIT 1),
                                                     (SELECT Id, Name FROM Hotel_Groups__r LIMIT 1),
                                                     (SELECT Id, Name FROM Agendas__r LIMIT 1),
                                                     (SELECT Id FROM Commercial_Event_Sessions__r LIMIT 1),
                                                     (SELECT Id, Name, MeetingAttachmentType_gne__c, downloadURL_gne__c, Parent_Id_gne__c, Parent_Type_gne__c, File_Name_gne__c, URL_gne__c, Description_gne__c, Type_gne__c FROM Attachments__r
                                                            WHERE LastModifiedDate >= :syncDate)
                                              FROM CMT_Meeting_gne__c
                                              WHERE Id = :meetingId
                                              LIMIT 1];
                                              
        return (meetings != null && !meetings.isEmpty()) ? meetings.get(0) : null; 
    }
    
    private class JSONError
    {
        public String Error { get; set; }
        
        public JSONError (String msg)
        {
            this.Error = msg;
        }
    }
}