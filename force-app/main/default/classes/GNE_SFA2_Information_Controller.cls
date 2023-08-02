public with sharing class GNE_SFA2_Information_Controller {
	
	public String pageTitle {get; set;}
	public String message {get; set;}
	public String retUrl {get; set;}
	
	public GNE_SFA2_Information_Controller(){
		message = ApexPages.currentPage().getParameters().get('message');
        pageTitle = Apexpages.currentPage().getParameters().get('pageTitle');
        retUrl = ApexPages.currentPage().getParameters().get('retUrl');
	}

}