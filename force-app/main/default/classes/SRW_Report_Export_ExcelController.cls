public without sharing class SRW_Report_Export_ExcelController {
	
	public transient String pageContent {get; set;}
	public String parameters {get; set;}
	public String activeReportName {get; set;}
	public String docId {get; set;}
	public String filename {get; set;}
	
	public SRW_Report_Export_ExcelController() {
		parameters = ApexPages.currentPage().getParameters().get('params');
		activeReportName = ApexPages.currentPage().getParameters().get('activeComponent');
		docId = ApexPages.currentPage().getParameters().get('docId');
		filename = 'export';
		filename = ApexPages.currentPage().getParameters().get('filename');
		filename += '_' + String.valueOf(System.now());
		Document doc = [Select Id, Body from Document where id=: docId];
		pageContent = doc.Body.toString();		
		//delete doc;		
	}

	public PageReference deleteDoc() {
		Document doc = [Select Id from Document where id=: docId];
		delete doc;
		return null;
	}

}