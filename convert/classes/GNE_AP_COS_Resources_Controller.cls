public class GNE_AP_COS_Resources_Controller {
	
	public static final String AP_COS_RESOURCES_FOLDER_NAME = 'AP_COS_Resources';
	private List<APDocument> availableDocuments;
	
	public GNE_AP_COS_Resources_Controller(){
		this.availableDocuments = null;
	}

	public void setLastVisitedPage() {
		GNE_AP_Navigation_Controller.setLastVisitedPage();		
	}
	
	public List<APDocument> getAvailableDocuments(){
		if (this.availableDocuments == null){
			this.availableDocuments = initializeDocuments();
		}
		return this.availableDocuments;
	}
	
	private List<APDocument> initializeDocuments(){
		List<APDocument> documents = new List<APDocument>();
		for (Document document : getAvailableCOSDocuments()){
			documents.add(
				new APDocument(document.Id, document.Name)
			);
		}
		return documents;
	}
	
	private class APDocument{
		public Id docId { get; private set; }
		public String docName { get; private set; }		
		public String docUrl { get; private set; }
		
		public APDocument(Id docId, String docName){
			this.docId = docId;
			this.docName = docName;			
			this.docUrl = String.format('{0}/servlet/servlet.FileDownload?file={1}'
				, new String[]{
					System.URL.getSalesforceBaseUrl().toExternalForm(),
					this.docId
				}
			);
		}
	}
	
	public static List<Document> getAvailableCOSDocuments(){
		return [
			SELECT 
				Id, 
				Name								 
			FROM 
				Document 
			WHERE 
				Folder.DeveloperName = :AP_COS_RESOURCES_FOLDER_NAME
		];
	}
}