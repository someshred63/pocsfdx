public without sharing class SRW_HelpController {

	public String urlForResource {get; set;}
	public Boolean isFOIM {get; set;}

	public List<SRW_Custom_Message_gne__c> getHelp() {
		List<SRW_Custom_Message_gne__c> hlpList = new List<SRW_Custom_Message_gne__c>();
		if(!isFOIM)
			hlpList = [select Id, Question_Number_gne__c, Answer_gne__c, Question_gne__c, Type_gne__c from SRW_Custom_Message_gne__c where Type_gne__c = 'Step by step TP' order by Question_Number_gne__c];
		else 
			hlpList = [select Id, Question_Number_gne__c, Answer_gne__c, Question_gne__c, Type_gne__c from SRW_Custom_Message_gne__c where Type_gne__c = 'Step by step FOIM' order by Question_Number_gne__c];
		return hlpList;
	}

	public SRW_HelpController() {
		List<Profile> FOIMs = [SELECT Name, Id FROM Profile WHERE (Id = :UserInfo.getProfileId() AND Name = 'GNE-GST-Partner-External')];
    	isFOIM = FOIMs.isEmpty();
    	if(isFOIM) {
    		List<SRW_Mimic_Data__c> mimicData = [select Id, SRW_Trading_Partner_Profile_gne__c, User_gne__c from SRW_Mimic_Data__c where User_gne__c =: UserInfo.getUserId()]; 
            isFOIM = mimicData.isEmpty();
    	}
		//resourceIsSet = false;
	}

	public PageReference setUrlFor() {
		//resourceIsSet = true;
		return null;
	}
	public PageReference setUrlFor1() {
		//resourceIsSet = true;
		return null;
	}
	
}