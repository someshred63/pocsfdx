public without sharing class GNE_SFA2_DCR_Ext {

	public Boolean loadComplete {
		get {
			if (loadComplete == null) {
				loadComplete = false;
			}
			return loadComplete;
		}
		set;
	}

	public PageReference loadComplete() {
		loadComplete = true;
		return null;
	}

	Change_Request_gne__c changeRequest = null;

	public enum ViewUserType {Requestor, RequestDataAnalyst, VendorDataAnalyst} 

	public ViewUserType userType = ViewUserType.RequestDataAnalyst;

	public Boolean getRequestor() {
		return ( userType == ViewUserType.Requestor );  
	}

	public Boolean getVendorDataAnalyst() {
		return ( userType == ViewUserType.VendorDataAnalyst );  
	}

	public Boolean getRequestDataAnalyst() {
		return ( userType == ViewUserType.RequestDataAnalyst );  
	}

	public Change_Request_gne__c getChangeRequest() {
		return changeRequest;   
	}

	public Boolean editPage { get; set; }
	public Boolean hasCanadaProfile { get { return getHasCanadaProfile(); } }
	private final ApexPages.StandardController stdController;
	private String retURL;


	public GNE_SFA2_DCR_Ext (ApexPages.StandardController stdController) {
		
		this.stdController = stdController; 
		System.debug (ApexPages.currentPage() + ' page constructor.');
		
		retURL = System.currentPageReference().getParameters().get('retURL');
		
		if(retURL!=null) {
			retURL = EncodingUtil.urlDecode(retURL, 'UTF-8');
		}

		changeRequest = GNE_SFA2_DCR_Util.getDCR((Id)stdController.getRecord().get('Id'));
		
		Id userId = UserInfo.getUserId();
		
		if (changeRequest.createdById == userId){ 
			userType = ViewUserType.Requestor;
			if (changeRequest.status_gne__c == 'Need Info' || changeRequest.status_gne__c == 'Ready to Close'){
				editPage = true;
			}
		}else if ( ChangeRequestControllerHelper.isVendor(userId) && changeRequest.status_gne__c == 'Ready for Data Vendor') {
			userType = ViewUserType.VendorDataAnalyst;
			editPage = true;
		}
		
		if( (userType == ViewUserType.RequestDataAnalyst)   && changeRequest.assigned_analyst_gne__c == null && ApexPages.currentPage().getURL().contains('/GNEEditDCR')){
			changeRequest.assigned_analyst_gne__c =  userId;
		}             
	}

	//method to indicate whether the logged on user is a Canada user
	public Boolean getHasCanadaProfile() {
		return GNE_SFA2_Util.isCanadaUser();
	}
}