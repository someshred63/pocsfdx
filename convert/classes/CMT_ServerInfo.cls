public class CMT_ServerInfo
{
    public ID Id { get; set; }
    public DateTime ServerTime { get; set; }
    
    public CMT_ServerInfo (ID id, DateTime sTime)
    {
        this.Id = id;
        this.ServerTime = sTime;
    }
}