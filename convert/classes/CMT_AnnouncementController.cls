public with sharing class CMT_AnnouncementController {
    
    public CMT_Announcement_gne__c announcement  
    { 
        get 
        {
            if(announcement == null) 
            {
                announcement = new CMT_Announcement_gne__c();
            }
            return announcement;
        } 
        set; 
    }
    
    public List<CMT_Announcement_gne__c> announcements { get; set; }
    
    public String recordId { get; set; }
    public String groupId { get; set; }
    public String meetingId { get; set; }
    public String target { get; set; }
    public String announcementId { get; set; }
    public String redirectUrl { get; set; }
    public Boolean isDescriptionRequired { get; set; }
    public Boolean isArchived { get; set; }
    
    public CMT_AnnouncementController()
    {
    	if (isDescriptionRequired == null)
    	{
    		isDescriptionRequired = false;
    	}
    	if (isArchived == null)
    	{
    		isArchived = false;
    	}
    }
    
    public boolean fetchAnnouncements { get {
	        announcements = [ select Name_gne__c, Description_gne__c from CMT_Announcement_gne__c where Record_id_gne__c = :recordId];
	        return true;
    	} set; 
    }
    
    public PageReference deleteAnnouncement() {
    	CMT_Announcement_gne__c ann = [SELECT Id FROM CMT_Announcement_gne__c WHERE Id = :announcementId LIMIT 1];
        delete ann;
    	return null;
    }
    
    public PageReference save()
    {
        // check if announcement group exists
        List<CMT_Announcement_Group_gne__c> announcementGroups = [ select Name from CMT_Announcement_Group_gne__c where Meeting_gne__c = :meetingId ];
        if((announcementGroups != null)&&(announcementGroups.isEmpty()))
        {
            // no announcement groups exist - create one
            CMT_Announcement_Group_gne__c groupToAdd = new CMT_Announcement_Group_gne__c();
            groupToAdd.Meeting_gne__c = meetingId;
            insert groupToAdd;
        }
        
        // select announcement category
        List<CMT_Announcement_Group_gne__c> existingAnnouncementGroups = [ select Name from CMT_Announcement_Group_gne__c where Meeting_gne__c = :meetingId ];
        
        // add announcement
        if(!existingAnnouncementGroups.isEmpty()) {
            announcement.Record_Id_gne__c = recordId;
            announcement.Meeting_gne__c = meetingId;
            announcement.Target_gne__c = target;
            announcement.Group_gne__c = existingAnnouncementGroups[0].id;
            insert announcement;
        }
        
        if (redirectUrl == null || redirectUrl == '')
        {
        	// redirect to the view page of the parent object
        	redirectUrl = recordId;
        }
        
        PageReference pageRef = new PageReference('/' + redirectUrl);
        pageRef.setRedirect(true);
        return pageRef;
    }
}