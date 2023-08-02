public class SCM_RecertReq {

public String BatchLevel{get
{
	
return ApexPages.currentPage().getParameters().get('type');
 
}
set{BatchLevel = value;}}

public String Participating{get
{
	
string id = ApexPages.currentPage().getParameters().get('id');
list<Address_vod__c> add  = [select Location_Specific_Preferences_gne__c from Address_vod__c where id = :id and Location_Specific_Preferences_gne__c Includes('Recertification Reminder')];
	if (add.size() > 0) {
		return 'true';

	}
	else {
	return 'false';
	}
}
set{Participating = value;}}



public pageReference CreateNew() {
	
	SCM_FaxSender_WebService.FaxSenderSoap fsws = new SCM_FaxSender_WebService.FaxSenderSoap();
	
	string typ = ApexPages.currentPage().getParameters().get('type');
	fsws.timeout_x = 60000;
	SCM_FaxSender_WebService.BatchStatus bs = fsws.CreateNewBatchFax('RecertificationReport',typ,ApexPages.currentPage().getParameters().get('id'),userinfo.getOrganizationId(),SCM_security.getEnvironmentVariable('SCM_ServerInstanceURL'),userinfo.getSessionId(),userinfo.getUserId(),'Xolair',ApexPages.currentPage().getParameters().get('accountid'),'','','');
	string message;
	if (bs.errormessage != null)
	{
		message = bs.ErrorMessage.replace('<br>','$$returnLine$$');
	}
	return new PageReference('/apex/SCM_AA_Batch_Status?status=' + bs.Status + '&Message=' + message);
}
}