/** @date 17/11/2014
* @Author Michal Szewczyk
* @description Controller for Header
*/
public with sharing class SRW_HeaderController {
	public String emailContent { get; set; }
	public String emailSubject {get; set; }
	public boolean isFOIM {get; set;}
	public boolean guestPages {get; set;}

	public SRW_HeaderController(){
		List<Profile> FOIMs = [SELECT Name, Id FROM Profile WHERE (Id = :UserInfo.getProfileId() AND Name = 'GNE-GST-Partner-External')];
    	isFOIM = FOIMs.isEmpty();
    	if(isFOIM) {
    		List<SRW_Mimic_Data__c> mimicData = [select Id, SRW_Trading_Partner_Profile_gne__c, User_gne__c from SRW_Mimic_Data__c where User_gne__c =: UserInfo.getUserId()]; 
            isFOIM = mimicData.isEmpty();
    	}
    	String pageName = ApexPages.currentPage().getURL();
    	guestPages = pageName.toLowerCase().endsWith('loginscreenfortradingpartners') || pageName.toLowerCase().endsWith('forgotpassword') || pageName.toLowerCase().endsWith('forgotusername') || pageName.toLowerCase().endsWith('sitelogin.apexp');
    }

	public PageReference goToFAQ() {
		PageReference pr = new PageReference('/apex/SRW_FAQ');
		pr.setRedirect(true);
		return pr;
	}

	public PageReference goToHelp() {
		PageReference pr = new PageReference('/apex/SRW_Help');
		pr.setRedirect(true);
		return pr;
	}
	public PageReference goToContactUs() {
		PageReference pr = new PageReference('/apex/SRW_ContactUs');
		pr.setRedirect(true);
		return pr;
	}

	public PageReference emailUs() {
		PageReference pr = new PageReference('/apex/SRW_EmailUs');
		pr.setRedirect(true);
		return pr;
	}

	   public PageReference sendEmail(){
        Messaging.SingleEmailMessage sem = new Messaging.SingleEmailMessage();
        sem.setPlainTextBody(emailContent);
        emailSubject = 'gST Guest: ' + emailSubject;
        sem.setSubject(emailSubject);
        sem.setSaveAsActivity(false);
        List<String> a = new List<String>();
        String emailAddress = SRW_Utils.getSettingByName('OrgWideEmailAddress');
        OrgWideEmailAddress[] owea = [select Id, Address from OrgWideEmailAddress where Address = :emailAddress LIMIT 1];
        sem.setOrgWideEmailAddressId(owea[0].id);
        a.add(owea[0].Address);
        sem.setToAddresses(a);
        Messaging.SendEmailResult[] ser = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {sem});
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Email sent.'));
        emailContent = '';
        return null;
    }

}