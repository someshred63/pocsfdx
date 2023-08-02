public with sharing class SRW_ContactUsController {
	public SRW_ContactUsController() {
		
	}

	public PageReference emailUs() {
		PageReference pr = new PageReference('/apex/SRW_EmailUs');
		pr.setRedirect(true);
		return pr;
	}
}