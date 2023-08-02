public class CMT_MiscUtils
{
    /**
     * This method creates a record for each deleted object of a given type. The deleted object contains the deletion date, the object type
     * and most notably the ID of the deleted entity.
     *
     * @param objectName - the name of the SObject type that is being deleted, e.g. 'Commercial_Event_Abstract_gne__c'
     * @param objs - the list of deleted objects, usually retrieved using 'Trigger.old'
     */
    public static void onDeleteTrigger (String objectName, List<SObject> objs)
    {
        onDeleteTrigger (objectName, objs, null, 'Meeting_gne__c');
    }
    
    /**
     * This method creates a record for each deleted object of a given type. The deleted object contains the deletion date, the object type
     * and most notably the ID of the deleted entity.
     *
     * @param objectName - the name of the SObject type that is being deleted, e.g. 'Commercial_Event_Abstract_gne__c'
     * @param objs - the list of deleted objects, usually retrieved using 'Trigger.old'
     */
    public static void onDeleteTrigger (String objectName, List<SObject> objs, String meetingField)
    {
        onDeleteTrigger (objectName, objs, null, meetingField);
    }
    
    public static void deleteAttachment (String attachmentId)
    {
        CMT_Attachment_gne__c att = [SELECT Id FROM CMT_Attachment_gne__c WHERE Id = :attachmentId LIMIT 1];
        delete att;
    }
    
    public static PageReference getPageRef (String page)
    {
        String redirectURL = '/apex/' + page;
        PageReference pageRef = new PageReference(redirectURL);
        return pageRef;
    }
    
    public static void onSessionUpsertTrigger (List<CMT_Session_gne__c> sessions)
    {
        Integer hourOffset = CMT_MiscUtils.getCurrentUserTimezoneOffset();
        for (CMT_Session_gne__c session : sessions)
        {
            system.debug('Date before = ' + session.Start_Time_gne__c);
            if (session.Start_Time_gne__c != null)
            {
                session.Start_Time_gne__c = session.Start_Time_gne__c.addHours(hourOffset);
            }
            system.debug('Date after = ' + session.Start_Time_gne__c);
            if (session.End_Time_gne__c != null)
            {
                session.End_Time_gne__c = session.End_Time_gne__c.addHours(hourOffset);
            }
        }
    }
    
    // Coverts datetime fields in the given session object (Start_Time_gne__c and End_Time_gne__c) to GMT.
    // E.g. if the times are in PST, which is GMT-8, the timezoneOffset needs to equal -8. Then 8 hours will be ADDED to the
    // times in the session.
    // The timezoneOffset should be the value of method CMT_MiscUtils.getCurrentUserTimezoneOffset()
    public static CMT_Session_gne__c convertSessionTimezonesForDisplay (CMT_Session_gne__c session, Integer timezoneOffset)
    {
        if (session.Start_Time_gne__c != null)
        {
            session.Start_Time_gne__c = session.Start_Time_gne__c.addHours(-1 * timezoneOffset);
        }
        if (session.End_Time_gne__c != null)
        {
            session.End_Time_gne__c = session.End_Time_gne__c.addHours(-1 * timezoneOffset);
        }
        
        return session;   
    }
    
    // Returns the current user's timezone offset from GMT in hours.
    public static Integer getCurrentUserTimezoneOffset()
    {
        List<User> users = [SELECT Id, TimeZoneSidKey FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        
        if (users == null || users.isEmpty())
        {
            throw new CMT_Exception('Current user not found for ID = \'' + UserInfo.getUserId() + '\'');
        }
        
        List<Schema.PicklistEntry> ple = User.TimeZoneSidKey.getDescribe().getPicklistValues();
                
        String tzKey = users.get(0).TimeZoneSidKey;
        String tzDesc = null;
                
        for (Schema.PicklistEntry entry : ple)
        {
            if (entry.getValue() == tzKey)
            {
                tzDesc = entry.getLabel();
                break;
            }
        }  
        
        if (tzDesc == null)
        {
            throw new CMT_Exception('Unknown time zone SID key \'' + tzKey + '\'');
        }
        
        // The tzDesc string has a form of e.g. '(GMT-08:00) Pacific Standard Time (America/Los_Angeles)'.
        // From this we need to extract the offset in hours, i.e. -8.
        String hoursStr = tzDesc.substring(tzDesc.indexOf('(GMT')+4, 7);
        // plus character at the beginning is not valid in the Integer.valueOf method, so we need to remove it
        hoursStr = hoursStr.replace('+', '');
        return Integer.valueOf(hoursStr);
    }
    
    public static DateTime getCurrentUserTime()
    {
    	return System.now().addHours(getCurrentUserTimezoneOffset());
    }
    
    public static PageReference viewLinkPageRef (Id id)
    {
        PageReference pageRef = new PageReference('/' + id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    private static String sObjectLink (Schema.SObjectType objectType)
    {
        return objectType.getDescribe().getKeyPrefix();
    }
    
    public static String sObjectEditLink (Schema.SObjectType objectType)
    {
        return sObjectLink(objectType) + '/e';
    }
    
    public static PageReference sObjectEditPageRef (Schema.SObjectType objectType, String queryString)
    {
        String redirectURL = '/' + CMT_MiscUtils.sObjectEditLink(objectType) + '?' + queryString;
        PageReference pageRef = new PageReference(redirectURL);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public static String sObjectListLink (Schema.SObjectType objectType)
    {
        return sObjectLink(objectType);
    }
    
    public static PageReference sObjectListPageRef (Schema.SObjectType objectType, String queryString)
    {
        String redirectURL = '/' + CMT_MiscUtils.sObjectListLink(objectType) + '?' + queryString;
        PageReference pageRef = new PageReference(redirectURL);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    
    public static CMT_Transportation_gne__c fetchOrCreateTransportation (String meetingId)
    {
        CMT_Transportation_Group_gne__c oGroup = null;
    
        List<CMT_Transportation_Group_gne__c> oGroups = [SELECT Id FROM CMT_Transportation_Group_gne__c WHERE Meeting_gne__c = :meetingId LIMIT 1];
        
        // if group does not exist, create it
        if (oGroups == null || oGroups.isEmpty())
        {
            oGroup = new CMT_Transportation_Group_gne__c();
            oGroup.Meeting_gne__c = meetingId;
            oGroup.Name = CMT_Config.TRANSPORTATION_GROUP_NAME;
            
            insert oGroup;
        }
        else
        {
            oGroup = oGroups.get(0);
        }
        
        // now check that the transportation object exists
        List<CMT_Transportation_gne__c> transportations = [SELECT Id FROM CMT_Transportation_gne__c WHERE Meeting_gne__c = :meetingId LIMIT 1];
        
        CMT_Transportation_gne__c transportation = null;
        
        if (transportations == null || transportations.isEmpty())
        {
            system.debug('adding transportation');
            // add transportation
            transportation = new CMT_Transportation_gne__c();
            transportation.Meeting_gne__c = meetingId;
            transportation.Transportation_Group_gne__c = oGroup.Id;
            
            insert transportation;
        }
        else
        {
            transportation = transportations.get(0);
        }
 
        return transportation;
    }
    
    public static Id getTransportationId (String meetingId)
    {
        List<CMT_Transportation_gne__c> t = [SELECT Id FROM CMT_Transportation_gne__c WHERE Meeting_gne__c = :meetingId LIMIT 1];
        
        return t != null && !t.isEmpty() ? t.get(0).Id : null;
    }
    
    public static void onDeleteTrigger (String objectName, List<SObject> objs, Map<Id, Id> parentMeetingIds)
    {
        onDeleteTrigger (objectName, objs, parentMeetingIds, 'Meeting_gne__c');
    }
    
    /**
     * This method creates a record for each deleted object of a given type. The deleted object contains the deletion date, the object type
     * and most notably the ID of the deleted entity.
     * 
     * It also removes all attachments and announcements related to the entity that is being deleted.
     *
     * @param objectName - the name of the SObject type that is being deleted, e.g. 'Commercial_Event_Abstract_gne__c'
     * @param objs - the list of deleted objects, usually retrieved using 'Trigger.old'
     * @param parentMeetingId - map where keys are object IDs and values - IDs of their parent meetings
     */
    public static void onDeleteTrigger (String objectName, List<SObject> objs, Map<Id, Id> parentMeetingIds, String meetingField)
    {
        List<CMT_Deleted_Record_gne__c> delRecords = new List<CMT_Deleted_Record_gne__c>();
        List<Id> delRecordIds = new List<Id>();
        
        for(SObject o : objs)
        {
            CMT_Deleted_Record_gne__c delRec = new CMT_Deleted_Record_gne__c();
            delRec.Date_Deleted_gne__c = Datetime.now();
            delRec.Object_Name_gne__c = objectName;
            delRec.Object_Id_gne__c = o.Id;
            
            // if parent meeting IDs are not imposed, extract them
            if (parentMeetingIds == null)
            {
                // get the value o the parent ID by simulated reflection
                try
                {
                	if (objectName != CMT_Config.MEETING_SOBJECT_NAME)
                	{
                    	// the property 'Commercial_Meeting_gne__c' may not exist on some objects, in which case an exception will be thrown
                    	delRec.Parent_Meeting_Id_gne__c = (String)o.get(meetingField);
                	}
                	else
                	{
                		delRec.Parent_Meeting_Id_gne__c = (String)o.get('Id');
                	}
                    delRecords.add(delRec);
                }
                catch (SObjectException e)
                {
                   	// sendSystemErrorNotification('Error logging object deletion for object with ID = \'' + o.Id + '\': ' + e.getMessage());
                    throw new CMT_Exception('Error logging object deletion for object with ID = \'' + o.Id + '\': ' + e.getMessage());
                }
            }
            else
            {
                delRec.Parent_Meeting_Id_gne__c = parentMeetingIds.get(o.Id);
                
                if (delRec.Parent_Meeting_Id_gne__c == null && objectName != CMT_Config.MEETING_SOBJECT_NAME)
                {
                    throw new CMT_Exception('Parent meeting ID not passed for object with ID = \'' + o.Id + '\'');
                }
                
                delRecords.add(delRec);
            }
            delRecordIds.add(o.Id);
        }
        
        if (delRecords.size() > 0)
        {
            insert delRecords;
        }
        
        deleteAttachments (delRecordIds);
        deleteAnnouncements (delRecordIds);
    }
    
    // Deletes all attachments related to the objects whose IDs are passed in the parameter collection
    private static void deleteAttachments (List<Id> parentIds)
    {
        List<CMT_Attachment_gne__c> atts = [SELECT Id FROM CMT_Attachment_gne__c WHERE Parent_Id_gne__c in :parentIds];
        if (atts != null && !atts.isEmpty())
        {
            delete atts;
        }   
    }
    
    // Deletes all announcements related to the objects whose IDs are passed in the parameter collection
    private static void deleteAnnouncements (List<Id> parentIds)
    {
        List<CMT_Announcement_gne__c> announcements = [SELECT Id FROM CMT_Announcement_gne__c WHERE Record_Id_gne__c in :parentIds];
        if (announcements != null && !announcements.isEmpty())
        {
            delete announcements;
        }   
    }
    
    
    /**
     * This method creates a record for each deleted object of a given type. The deleted object contains the deletion date, the object type
     * and most notably the ID of the deleted entity.
     *
     * @param objectName - the name of the SObject type that is being deleted, e.g. 'Commercial_Event_Abstract_gne__c'
     * @param objs - the list of deleted objects, usually retrieved using 'Trigger.old'
     */
    public static void onDeleteFranchiseToSessionTrigger (List<SObject> objs)
    {
        List<CMT_Deleted_Franchise_To_Session_gne__c> delRecords = new List<CMT_Deleted_Franchise_To_Session_gne__c>();
        
        for(SObject o : objs)
        {
            CMT_Deleted_Franchise_To_Session_gne__c delRec = new CMT_Deleted_Franchise_To_Session_gne__c();
            delRec.Date_Deleted_gne__c = Datetime.now();
            delRec.Session_gne__c = ((CMT_FranchiseToSession_gne__c)o).Session_gne__c;
            delRec.Franchise_gne__c = ((CMT_FranchiseToSession_gne__c)o).Franchise_gne__c;
            delRec.Intermediate_Level_gne__c = ((CMT_FranchiseToSession_gne__c)o).CMT_Intermediate_Level_gne__c;
            
            // get the value o the parent ID by simulated reflection
            try
            {
                // the property 'Commercial_Meeting_gne__c' may not exist on some objects, in which case an exception will be thrown
                delRec.Parent_Meeting_Id_gne__c = (String)o.get('Meeting_gne__c');
                delRecords.add(delRec);
            }
            catch (SObjectException e)
            {
               // sendSystemErrorNotification('Error logging object deletion for object with ID = \'' + o.Id + '\': ' + e.getMessage());
                throw new CMT_Exception('Error logging object deletion for object with ID = \'' + o.Id + '\': ' + e.getMessage());
            }
        }
        
        system.debug('really deleting: ' + delRecords);
        
        if (delRecords.size() > 0)
        {
            insert delRecords;
        }
    }
    
    public static void sendSystemErrorNotification (String body)
    {
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        msg.setToAddresses (new List<String> { CMT_Config.ERROR_NOTIFICATION_EMAIL });
        msg.setSubject ('[CommMtgs] System error');
        msg.setHtmlBody(body);
        List<Messaging.SendEmailResult> results =  Messaging.sendEmail (new Messaging.Email[] {  msg });
    }
}