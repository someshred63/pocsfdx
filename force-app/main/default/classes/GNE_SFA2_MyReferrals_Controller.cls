public with sharing class GNE_SFA2_MyReferrals_Controller extends GNE_SFA2_List_View_Base_Controller {

    public GNE_SFA2_List_View_Base_Controller thisController { get; set; }
    
    public Boolean isCanadaUser { 
    	get {
    		return GNE_SFA2_Util.isCanadaUser();
    	}
    }
    
    private String editPageUrl; 
     
    public GNE_SFA2_MyReferrals_Controller () {
        super('Referral_Assignment_gne__c');
        thisController = this;
    }
    
    public String getEditPageUrl(){
    	if (String.isBlank(this.editPageUrl)){
    		this.editPageUrl = isCanadaUser ? '/apex/GNE_SFA2_Referral' : '/apex/GNE_SFA2_EditReferralPage';
    	}
    	return this.editPageUrl;
    }
}