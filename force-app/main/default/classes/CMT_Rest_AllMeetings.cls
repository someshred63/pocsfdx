@RestResource(urlMapping='/AllMeetings/*')
global class CMT_Rest_AllMeetings
{   
    @HttpGet
    global static String doGet (RestRequest req, RestResponse res)
    {
        String lastSyncDate = CMT_RESTUtils.getDeltaParam(req);
        Datetime syncDate = lastSyncDate != null ? Datetime.valueOf(lastSyncDate) : Datetime.valueOf('1900-01-01 00:00:00');
        
        CMT_Meeting_gne__c[] meetings = [SELECT Id,
                                                    Name, 
                                                    Hexadecimal_Color_gne__c,
                                                    Is_Meeting_Active_gne__c,
                                                    Title_gne__c,
                                                    Meeting_Type_gne__c,
                                                    LastModifiedDate,
                                                    Location_gne__c,
                                                    Start_Date_gne__c,
                                                    End_Date_gne__c,
                                                    (SELECT Id,
                                                        Name,
                                                        MeetingAttachmentType_gne__c,
                                                        downloadURL_gne__c,
                                                        Parent_Id_gne__c,
                                                        Parent_Type_gne__c,
                                                        File_Name_gne__c,
                                                        URL_gne__c,
                                                        Description_gne__c,
                                                        Type_gne__c
                                                     FROM
                                                         Attachments__r
                                                     WHERE LastModifiedDate >= :syncDate),
                                                     TimeZone__c
                                                 FROM CMT_Meeting_gne__c];
        
        List<CMT_Meeting_Properties> wrappedMeetings = new List<CMT_Meeting_Properties>();
        for (CMT_Meeting_gne__c m : meetings)
        {
            if (m.LastModifiedDate >= syncDate || (m.Attachments__r != null && !m.Attachments__r.isEmpty()))
            {
                wrappedMeetings.add(new CMT_Meeting_Properties(m));
            }
        }                      
        
        // get deleted meetings if delta is set
        List<CMT_DeletedObject> deletedMeetings = new List<CMT_DeletedObject>();
        if (lastSyncDate != null && lastSyncDate != '')
        {
            List<CMT_Deleted_Record_gne__c> delRecords = [SELECT Object_Id_gne__c FROM CMT_Deleted_Record_gne__c
                                                            WHERE Date_Deleted_gne__c >= :syncDate AND Object_Name_gne__c = :CMT_Config.MEETING_SOBJECT_NAME];
                                                            
            for (CMT_Deleted_Record_gne__c delRec : delRecords)
            {
                deletedMeetings.add(new CMT_DeletedObject(delRec.Object_Id_gne__c));
            }
        }
        
        
       	List<CMT_DeletedObject> deletedAttachments = new List<CMT_DeletedObject>();
       	if (lastSyncDate != null && lastSyncDate != ''){
       		
       		List<CMT_Deleted_Record_gne__c> delAttachmentRecords = [SELECT Object_Id_gne__c, Object_Name_gne__c FROM CMT_Deleted_Record_gne__c WHERE Date_Deleted_gne__c >= :syncDate AND Object_Name_gne__c='CMT_Attachment_gne__c'];
       	  
       	  	for (CMT_Deleted_Record_gne__c delAttachmentRecord: delAttachmentRecords)
            {
                deletedAttachments.add(new CMT_DeletedObject(delAttachmentRecord.Object_Id_gne__c));
            }
       	}
        
        CMT_MeetingCollection allMeetings = new CMT_MeetingCollection(wrappedMeetings, deletedMeetings, deletedAttachments);
        allMeetings.setServerInfo(new CMT_ServerInfo(null, CMT_MiscUtils.getCurrentUserTime()));
        
        //String info = UserInfo.getUserName();
        //return info;//CMT_JSONUtils.format(allMeetings);
        return CMT_JSONUtils.format(allMeetings);
    }
}