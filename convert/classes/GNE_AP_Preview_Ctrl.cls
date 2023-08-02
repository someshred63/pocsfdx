public class GNE_AP_Preview_Ctrl extends GNE_AP_Report_Controller{
	
	public String searchTerm {get; set;}
	public String selectedEmail{get; set;}
	
	public GNE_AP_Preview_Ctrl() {
		super();
	}

	@RemoteAction
	public static List<AggregateResult> searchEmail(String searchTerm) {
		String[] emails = searchTerm.split(';', 0);
		searchTerm = emails[emails.size()-1];
		searchTerm = String.escapeSingleQuotes(searchTerm)+'%';
		List<AggregateResult> email= Database.query('Select Email from User where Email like :searchTerm GROUP BY Email ORDER BY Email LIMIT 5');
		return email;
	}
}