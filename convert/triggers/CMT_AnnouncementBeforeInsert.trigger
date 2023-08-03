trigger CMT_AnnouncementBeforeInsert on CMT_Announcement_gne__c (before insert)
{
    Id meetingId = Trigger.NEW.get(0).Meeting_gne__c;
    
    if (meetingId == null)
    {
        throw new CMT_Exception('Meeting ID is null');
    }
    
    CMT_Announcement_Group_gne__c oGroup = null;
    
    List<CMT_Announcement_Group_gne__c> oGroups = [SELECT Id FROM CMT_Announcement_Group_gne__c WHERE Meeting_gne__c = :meetingId LIMIT 1];
    
    // if group does not exist, create it
    if (oGroups == null || oGroups.isEmpty())
    {
        oGroup = new CMT_Announcement_Group_gne__c();
        oGroup.Meeting_gne__c = meetingId;
        oGroup.Name = CMT_Config.ANNOUNCEMENT_GROUP_NAME;
        
        insert oGroup;
    }
    else
    {
        oGroup = oGroups.get(0);
    }
    
    for (CMT_Announcement_gne__c o : Trigger.NEW)
    {
        o.Group_gne__c = oGroup.Id;
    }
}