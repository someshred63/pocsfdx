public with sharing class gSFA_iPhone_Controller {
	
	public gSFA_iPhone_Controller(){}
	
	@RemoteAction
    @ReadOnly
    public static List<SObject> query(String query){        
        return Database.Query(query);
    }
}