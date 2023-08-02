/**
 * Information about a deleted object.
 */
public class CMT_DeletedObject
{
    //public String Type { get; set; }
    public String Id { get; set; }
    
    public CMT_DeletedObject (CMT_Deleted_Record_gne__c obj)
    {
        //this.Type = obj.Object_Name_gne__c;
        this.Id = obj.Object_Id_gne__c;
    }
    
    public CMT_DeletedObject (String id)
    {
        //this.Type = obj.Object_Name_gne__c;
        this.Id = id;
    }
}