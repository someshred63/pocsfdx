public class AGG_RedirectUser 
{

	/*
	This class is the controller for AGG_RedirectUserPage
	The class is called when the page is loaded.
	It activates a user if inactive(user passed as parameter to page) and redirects to Company portal login page 
	After user is looged in to Salesforce via SSO(Single Sign on), it loads the Infrequent user page based on passed parameters	
	*/
	
	public String sIsInfrequentUser{get; set;}
	public String sIsInfrequentUserURL{get; set;}
	public String sUnixId{get; set;}
	public String sInfrequentRecordMode{get; set;}
	public String sActivateUserFlag{get; set;}
	public String sFirstName{get; set;}
	public String sLastName{get; set;}
	public String sURL{get; set;}	
	public String sErrMessage{get; set;}
	public String sTargetURL{get; set;}
		
	//public String sCompanyPortal='http://gwiz.gene.com/tlcrm';
	//public String sCompanyPortal='https://wacqa.gene.com/siteminderagent/forms/login.fcc?TYPE=33554433&REALMOID=06-3f52fd2e-131f-1013-8563-83c43f45304d&GUID=&SMAUTHREASON=0&METHOD=GET&SMAGENTNAME=$SM$Sp%2f7jGxRSvQTDtFL876QoBEAFSM1sW01FON4jRMPVfvejLhppNM%2bfFWuUSbHq7zR&TARGET=$SM$https%3a%2f%2fcrm%2egene%2ecom%2fpf%2ftlcrm%2f';
	//public String sCompanyPortal = 'https://wacqa.gene.com/siteminderagent/forms/login.fcc?TYPE=33554433&REALMOID=06-87dcd130-22a1-105e-b1eb-839b7f61304d&GUID=&SMAUTHREASON=0&METHOD=GET&SMAGENTNAME=$SM$DMSGBWNyAxlshEv1LWAFMP9QgH%2bERJBViI1sPsB9YTM35e1q4umRj2vWmB9Vwg5O&TARGET=$SM$http%3a%2f%2fcommportal-qa.gene.com%2fportal%2fsite%2fcommercial%2ftemplate.LOGIN%2f'; 
	public AGG_RedirectUser()
	{
		if(System.currentPageReference().getParameters().get('activateuserflag')!=null)
		{
			sActivateUSerFlag=System.currentPageReference().getParameters().get('activateuserflag');
		}
		if(System.currentPageReference().getParameters().get('unixid')!=null)
		{
			sUnixId=System.currentPageReference().getParameters().get('unixid');
		}
		if(System.currentPageReference().getParameters().get('infuser')!=null)
		{
			sIsInfrequentUser=System.currentPageReference().getParameters().get('infuser');
		}
		if(System.currentPageReference().getParameters().get('infuserurl')!=null)
		{
			sIsInfrequentUserURL=System.currentPageReference().getParameters().get('infuserurl');
		}
		if(System.currentPageReference().getParameters().get('mode')!=null)
		{
			sInfrequentRecordMode=System.currentPageReference().getParameters().get('mode'); //mode can be view or edit
		}
		
		if(System.currentPageReference().getParameters().get('SSOUrl')!=null)
		{
			sURL=System.currentPageReference().getParameters().get('SSOUrl'); 			
		}
		
		if(System.currentPageReference().getParameters().get('targetURL')!=null)
		{
			sTargetURL=System.currentPageReference().getParameters().get('targetURL'); 			
		}
		
	}
	
	public PageReference init()
	{
		PageReference pg ;
		String sActivateMessage='';
		
		
		sErrMessage = sURL;
		if(!Utility.isNull(sActivateUserFlag) && sActivateUserFlag=='true') 
		{

			
			if(!Utility.isNull(sUnixId) )
			{
				//activate user with given UnixId  comportal.gene.com/uat
				sActivateMessage = UserManager.activateSFUser(sUnixId, true);
				sErrMessage = sActivateMessage;
			}
			else
			{
				sErrMessage = 'Unix Id is null';
				return null;
			}
			

			if(!Utility.isNull(sActivateMessage) && sActivateMessage.IndexOf('Error')==-1) //user activation sucessful
			{
				//sErrMessage = sTargetURL;
				//return null;
				//Save Target URL
				system.debug('!!!! - UNIX ID'+sUnixId);
	//			UserManager.InsertRedirectURL(sUnixId, sTargetURL, sActivateMessage);
/*				User_Redirect_Info_gne__c userRedirectInfo = new User_Redirect_Info_gne__c(); 
				userRedirectInfo.Unix_Id_gne__c = sUnixId;
				userRedirectInfo.Redirect_URL_gne__c = sTargetURL;
				userRedirectInfo.Redirect_User_gne__c = sActivateMessage;
				insert userRedirectInfo;
*/				UserManager.UpdateURL(sUnixId, sTargetURL);
				sErrMessage = sURL;
				//return null;
				//UserManager.deactivateUsersReadyForDeactivate();
				pg= new PageReference(sURL);
				pg.setRedirect(true);
				return pg;
			}
		}
		
		return null;
		
		
	}


	
}