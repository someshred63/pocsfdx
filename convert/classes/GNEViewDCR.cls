public without sharing class GNEViewDCR {
	
	public ViewUserType userType = ViewUserType.RequestDataAnalyst;
	public enum ViewUserType {Requestor, RequestDataAnalyst, VendorDataAnalyst}
	private Change_Request_gne__c changeRequest;
	public Boolean editPage {get; set;}
	public Boolean displayPopup {get; set;}	
	
	public Boolean loadComplete{
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
	
	public Boolean getRequestor() {
		return userType == ViewUserType.Requestor;
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
	
	public GNEViewDCR (ApexPages.StandardController stdController) {
		changeRequest = GNE_SFA2_DCR_Util.getDCR((Id)stdController.getRecord().get('Id'));
		
		Id userId = UserInfo.getUserId();
		if (changeRequest.createdById == userId){
			userType = ViewUserType.Requestor;
			if(changeRequest.status_gne__c == 'Need Info' || changeRequest.status_gne__c == 'Ready to Close'){
				editPage = true;
			}
		}else if ( ChangeRequestControllerHelper.isVendor(userId) && changeRequest.status_gne__c == 'Ready for Data Vendor') {
			userType = ViewUserType.VendorDataAnalyst;
			editPage = true;
		}
		if(isFrmHcoDcr(changeRequest)){
			editPage = true;
		}
		displayPopup = false;
	}
	
	//method to indicate whether the logged on user is a Canada user
	public Boolean getHasCanadaProfile() {
		return  GNE_SFA2_Util.isCanadaUser();
	}
	
	public Boolean isFrmHcoDcr(Change_Request_gne__c changeRequest) {
		return changeRequest.Account_gne__c != null && changeRequest.Account_gne__r.RecordType.DeveloperName == GNE_SFA2_Account_Trigger_Helper.REC_TYPE_FRM_HCO;
	}
	
	public Boolean getIsFrmHcoDcr() {
		return isFrmHcoDcr(changeRequest);
	}
	
	public Boolean getIsDisputeButtonAvailable() {
		if(isFrmHcoDcr(changeRequest) && changeRequest.Status_gne__c == 'Closed' && changeRequest.CreatedById == UserInfo.getUserId() && changeRequest.assigned_analyst_gne__c != UserInfo.getUserId()){
			return true;
		}
		return false;
	}
	
    public void showPopup() {
	    displayPopup = true;
    }
    
    public void closePopup() {
        displayPopup = false;
    }
    
    public PageReference dispute() {
	    displayPopup = false;
	    changeRequest.New_Note_gne__c = 'Dispute Reason:\n' + changeRequest.New_Note_gne__c;
	    changeRequest.Status_gne__c = 'Disputed';
	    update changeRequest;
        PageReference p = Page.GNE_CRM_DCR;
        p.setRedirect(true);
        return p;
    }
}