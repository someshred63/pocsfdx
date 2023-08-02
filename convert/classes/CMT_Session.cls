public class CMT_Session extends CMT_JSONWrapper
{
    public String RoomName { get; set; }
    public String Name { get; set; }
    public DateTime StartTime { get; set; }
    public DateTime EndTime { get; set; }
    public String Location { get; set; }
    public String Description { get; set; }
    public Id IntermediateLevelId { get; set; }
    
    public CMT_Session ()
    {
    }
    
    private void init (CMT_Session_gne__c session, List<CMT_Attachment> attachments, Id IntermediateLevel)
    {
    	if (session != null)
    	{
    		Id = session.Id;
	        RoomName = session.Room_Name_gne__c;
	        Name = session.Name;
	        Description = session.Description_gne__c;
	        EndTime = session.End_Time_gne__c;
	        StartTime = session.Start_Time_gne__c;
	        Location = session.Location_gne__c;
	        IntermediateLevelId = IntermediateLevel;
        	this.Attachments = attachments != null ? attachments : new List<CMT_Attachment>();
    	}
    }
    
    
    public CMT_Session (CMT_Session_gne__c session)
    {
        init (session, null,null);
    }
    
    public CMT_Session (CMT_Session_gne__c session, List<CMT_Attachment> attachments)
    {
        init (session, attachments,null);
    }
    
    public CMT_Session (CMT_Session_gne__c session, List<CMT_Attachment> attachments,Id IntermediateLevel)
    {
        init (session, attachments,IntermediateLevel);
    }
}