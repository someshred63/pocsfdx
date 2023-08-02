@RestResource(urlMapping='/iPhoneGetUsers/*')
global with sharing class iPhone_Get_Users {
	
	@HttpPost 
    global static iPhone_Commons_gne.RestResponse processRequest(String lastSyncDate) {
    	return iPhone_Commons_gne.buildResponse(
	    		new GetUsersResponseBuilder(), 
	    		new iPhone_Commons_gne.DefaultDeltaArgs(lastSyncDate, null, null)    		
    	);     	    	    	    	
    } 

	class GetUsersResponseBuilder extends iPhone_Commons_gne.DeltaRecordsResponseBuilder {
		
		protected override List<SObject> selectSObjects(iPhone_Commons_gne.DeltaArgs args) {
    		return iPhone_DAO.getReferralUsers();      
    	} 	 
    	     	 			
    	protected override iPhone_Commons_gne.DeltaRecord getAsRecord(SObject sObj) {
    		return new GetUsersResponse((User)sObj);    		    		
    	}
    	
    	protected override iPhone_Commons_gne.DeltaCalculator getDeltaCalculator(String lastSyncDate){
        	return new UserDeltaCalculator(lastSyncDate);
        } 
	}
	
	 class UserDeltaCalculator extends iPhone_Commons_gne.DeltaCalculator{
    	
    	private String lastModifiedDateFieldName; 
    	
    	public UserDeltaCalculator(String lastSyncDate){
    		super(lastSyncDate);
    		this.lastModifiedDateFieldName = String.valueOf(User.LastModifiedDate);
    	}
    	
		protected override String getDeltaStatus(SObject sObj) {
			if(lastSynchronized == null) // delta is OFF.
				return null;		
			Datetime created = (Datetime)sObj.get('CreatedDate');
							
			if(created >= lastSynchronized) { 
				return STAT_INSERT; 	// created AFTER last synchronization.
			} else {
				object lastModifiedDateObj = sObj.get(this.lastModifiedDateFieldName);
				Datetime lastModified = null;
				if (lastModifiedDateObj != null){
					lastModified =(Datetime)lastModifiedDateObj;					
				}
				
				if(lastModified != null && lastModified >= lastSynchronized) {
					return STAT_UPDATE; // created BEFORE last synchonization but updated AFTER last synchronization. 
				} else {
					return STAT_SYNC; // created and updated BEFORE last synchronization (is eXisting = already synchronized). 
				}
			}							
		}							
	}	 

	public class GetUsersResponse extends iPhone_Commons_gne.DeltaRecord {	
		public String id; //(sfdcId)
		public String cn; //(company name)
		public String pn; //(profile name)
		public String pi; //(profile id)		
		public String fn; //(first name)
		public String ln; //(last name)

		
		public GetUsersResponse(User user) {
			String profileName = user.Profile_Name_gne__c.toUpperCase();			
			this.id = user.id; 			
			this.cn = user.CompanyName;
			this.pn = user.Profile_Name_gne__c; 			
			this.pi = user.ProfileId; 		   		
			this.fn = user.FirstName; 		
			this.ln = user.LastName; 		
		}
	}
}