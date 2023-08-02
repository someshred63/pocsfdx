public without sharing class GNE_Collaborate_Google_Alerts_Ctrl {

	public String googleAlertRss { get; private set; }

	/* Constructor */
	public GNE_Collaborate_Google_Alerts_Ctrl() {
		googleAlertRss = (ApexPages.currentPage().getParameters().get('googleAlertRss')!=null) ? ApexPages.currentPage().getParameters().get('googleAlertRss') : null;
	}

	@RemoteAction
	public static void insertNewAlert(String googleAlertName, String title, String publishedDate, String content, String id, String link, String contentSnippet) {

		GNE_Collaborate_Google_Alert__c googleAlert = new GNE_Collaborate_Google_Alert__c();
		googleAlert.Title__c = title;
		googleAlert.Published_Date__c = DateTime.parse(publishedDate);
		googleAlert.Content__c = content;
		googleAlert.Alert_Id__c = id;
		googleAlert.Google_Alert_Name__c = googleAlertName;
		googleAlert.Link__c = link;
		googleAlert.Content_Snippet__c = contentSnippet;

		try {
			Insert googleAlert;
		} catch(System.DmlException e) {
			System.debug(e);
		}

	}

	@RemoteAction
	public static List<GNE_Collaborate_Google_Alert__c> loadMoreAlerts(String googleAlertName, String alreadyLoaded) {
		List<String> alreadyExists = alreadyLoaded.removeEnd(',').split(',');
		return [SELECT Title__c, Content__c, Content_Snippet__c, Published_Date__c, Alert_Id__c, Link__c FROM GNE_Collaborate_Google_Alert__c WHERE Alert_Id__c NOT IN :alreadyExists AND Google_Alert_Name__c = :googleAlertName ORDER BY Published_Date__c DESC LIMIT 10];
	}

}