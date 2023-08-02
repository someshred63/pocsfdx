public class CMT_Franchise extends CMT_JSONWrapper
{
    public List<CMT_Session> Sessions { get; set; }
    public List<CMT_DeletedObject> DeletedSessions { get; set; }
    public List<CMT_Intermediate_Level> IntermediateLevels { get; set; }
    public List<CMT_DeletedObject> DeletedIntermediateLevels { get; set; }
    public String Name { get; set; } 
    
    public CMT_Franchise()
    {
    }
    
    private void init (CMT_Franchise_gne__c franchise, List<CMT_Attachment> attachments, List<CMT_DeletedObject> deletedSessions,List<CMT_DeletedObject> deletedIntermediateLevels)
    {
    	if (franchise != null)
    	{
        	Id = franchise.Id;
        	Name = franchise.Name;
        	Sessions = new List<CMT_Session>();
        	this.Attachments = attachments != null ? attachments : new List<CMT_Attachment>();
        	this.DeletedSessions = deletedSessions != null? deletedSessions : new List<CMT_DeletedObject>();
        	this.IntermediateLevels = this.IntermediateLevels !=null? this.IntermediateLevels : new List<CMT_Intermediate_Level>();
        	this.DeletedIntermediateLevels = deletedIntermediateLevels != null? deletedIntermediateLevels : new List<CMT_DeletedObject>();
    	}
    }
    
    public CMT_Franchise (CMT_Franchise_gne__c franchise)
    {
    	init (franchise, null, null,null);	
    }
    
    public CMT_Franchise (CMT_Franchise_gne__c franchise, List<CMT_Attachment> attachments, List<CMT_DeletedObject> deletedSessions)
    {
    	init (franchise, attachments, deletedSessions,null);	
    }
    
    public CMT_Franchise (CMT_Franchise_gne__c franchise, List<CMT_Attachment> attachments, List<CMT_DeletedObject> deletedSessions,List<CMT_DeletedObject> deletedIntermediateLevels)
    {
    	init (franchise, attachments, deletedSessions,deletedIntermediateLevels);	
    }
    
    public void addSession (CMT_Session session)
    {
        if (Sessions == null)
        {
            Sessions = new List<CMT_Session>();
        }
        
        // This is a tricky part. If a session has been removed from the franchise and then reassigned to it, it will appear both
    	// in the Sessions collection and in DeletedSessions. Obviously in this case we want it out of the DeletedSessions collection so
    	// here we remove such duplicate sessions.
    	if (this.DeletedSessions != null)
    	{
    		Integer indexToDelete = null;
    		Integer currentIndex = 0;
    		for (CMT_DeletedObject deletedSession : this.DeletedSessions)
    		{
    			if (deletedSession.Id == session.Id)
    			{
    				indexToDelete = currentIndex;
    				break;
    			}
    			currentIndex++;
    		}
    		
    		if (indexToDelete != null)
    		{
    			this.DeletedSessions.remove(indexToDelete);
    		}
    	}
        
        Sessions.add(session);
    }
}