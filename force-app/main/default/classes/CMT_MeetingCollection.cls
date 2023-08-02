/**
 * A collection of meetings wrapped in an object as required by the return format of the 'AllMeetings' REST service.
 */
public class CMT_MeetingCollection
{
    public List<CMT_Meeting_Properties> Meetings { get; private set; }
    public List<CMT_DeletedObject> DeletedMeetings { get; set; }
    public List<CMT_ServerInfo> ServerInfo { get; private set; }
    public List<CMT_DeletedObject> DeletedAttachments { get; set; }
    
    public void setServerInfo (CMT_ServerInfo info)
    {
        if (ServerInfo == null)
        {
            ServerInfo = new List<CMT_ServerInfo>();
        }
        
        ServerInfo.clear();
        ServerInfo.add(info);
    }
    
    public CMT_MeetingCollection (List<CMT_Meeting_Properties> meetings, List<CMT_DeletedObject> deletedMeetings, List<CMT_DeletedObject> deletedAttachments)
    {
        this.Meetings = meetings;
        this.DeletedMeetings = deletedMeetings;
        this.DeletedAttachments = deletedAttachments;
    }
}