// Added By: Deepak Yadav
// Merge field for case manager
public virtual class SCM_MF_CaseMangCollection extends SCM_MergeField {
	
	protected User caseManager;
	
	private static List<User> caseManagerList;
	public SCM_MF_CaseMangCollection(String userId) {
        this.checked = false;
        this.displayCheck = false;
        this.displayTextBox = false;
        this.displayLabel = true;
        if(caseManagerList==null)
        {
         caseManagerList = [Select u.FirstName, u.LastName, u.Extension From User u
        					where u.Id = :userId LIMIT 1];
        }
        if(caseManagerList.size()>=1)
            caseManager= caseManagerList[0];
        else
        {
            caseManager = null;
        }
    }
    


}