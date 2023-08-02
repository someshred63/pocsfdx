public class CMT_DeletedObjectCollection
{
    public List<CMT_DeletedObject> DeletedObjects { get; set; }
    
    public CMT_DeletedObjectCollection (CMT_Deleted_Record_gne__c[] deletedObjs)
    {
        for (CMT_Deleted_Record_gne__c o : deletedObjs)
        {
            this.addObject(new CMT_DeletedObject(o));
        }
    }
    
    public void addObject (CMT_DeletedObject o)
    {
        if (this.DeletedObjects == null)
        {
            this.DeletedObjects = new List<CMT_DeletedObject>();
        }
        
        this.DeletedObjects.add(o);
    }
}