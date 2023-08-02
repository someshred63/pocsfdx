// Added By: Deepak Yadav
// Merge field for Physician
public virtual class SCM_MF_PhysicianCollection extends SCM_MergeField {
    
    protected Account physicianManager;
    private static List<Account> physicianManagerList;
    public SCM_MF_PhysicianCollection(String accountId) {
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = true;
        if(physicianManagerList==null)
        {
        	physicianManagerList = [Select a.Middle_vod__c, a.LastName,
        								   a.FirstName, a.Phone, a.Fax, a.Title_gne__pc 
        							From Account a
        							where a.Id = :accountId LIMIT 1];
        }
        if(physicianManagerList.size()>=1)
            physicianManager= physicianManagerList[0];
        else
        {
            physicianManager = null;            
        }
    }

}