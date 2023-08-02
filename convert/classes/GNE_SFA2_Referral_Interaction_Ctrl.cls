public without sharing class GNE_SFA2_Referral_Interaction_Ctrl {
	
	private Referral_Assignment_gne__c referralAssignment;
	private GNE_SFA2_Interaction_Controller mainController;
	private Id referralId;
	
	public GNE_SFA2_Referral_Interaction_Ctrl(GNE_SFA2_Interaction_Controller mainController, String referralId) {
		this.referralId = String.isNotEmpty(referralId) ? referralId : null;
		this.mainController = mainController;
	}
	
	public Call2_vod__c createCall(){
		Call2_vod__c call = new Call2_vod__c(Referral_Assignment_gne__c = getReferralAssignment().Id, Account_vod__c = getReferralAssignment().Medical_Request_gne__r.Account_gne__c);
		call.Visit_Reason_gne__c='Pending Follow-Up';
		call.Interaction_Status_gne__c = 'Planned';
		return call;
	}
	
	public void save(){
		Referral_Assignment_gne__c referralAssignment = getReferralAssignment();
		if(referralAssignment != null){
			if(referralAssignment.Call2_vod__c == null){
				referralAssignment.Call2_vod__c = mainController.call.Id;
			}
			if(mainController.call.Completed_gne__c){
				completedCallProcessLinkedReferral(referralAssignment);
			}else{
				update referralAssignment;
			}
		}
	}
	
	public static void completedCallProcessLinkedReferral(Referral_Assignment_gne__c referralAssignment){
		referralAssignment.Medical_Request_gne__r.Unsolicited_Request_Verified_gne__c = true;
		referralAssignment.Medical_Request_gne__r.Unsolicited_Request_Verified_By_gne__c = UserInfo.getUserId();
		referralAssignment.Medical_Request_gne__r.Unsolicited_Request_Verified_Date_gne__c = Date.today();
		String refHistory = Datetime.now().format(GNE_Referral_Utils.strPSTFormat, GNE_Referral_Utils.strPST) + ',' + GNE_Referral_Utils.strStatusUpdate +  ',' + UserInfo.getName() + ',' + referralAssignment.Assigned_To_gne__r.Name + ',' + referralAssignment.Assigned_To_gne__r.Name + ', ' + referralAssignment.Assigned_To_gne__r.Profile_Name_gne__c + ',' + GNE_Referral_Utils.strFulfilled + ';';
		if (String.isBlank(referralAssignment.Medical_Request_gne__r.Referral_History_gne__c)){
			referralAssignment.Medical_Request_gne__r.Referral_History_gne__c = refHistory;
		} else {
			referralAssignment.Medical_Request_gne__r.Referral_History_gne__c += refHistory;
		}
		update referralAssignment.Medical_Request_gne__r;

		Medical_Communication_gne__c medicalCommunication = new Medical_Communication_gne__c(id=referralAssignment.Medical_Request_gne__c);
		if( referralAssignment.Status_Referral_gne__c != GNE_Referral_Utils.strFulfilled ) {
			GNE_Referral_Utils.sendReferralEmail(referralAssignment, medicalCommunication, GNE_Referral_Utils.strFulfilled);
		}
		referralAssignment.Status_Referral_gne__c = GNE_Referral_Utils.strFulfilled;

		update referralAssignment;
	}
	
	public static Referral_Assignment_gne__c getReferralAssignmentById(String referralId){
    	return [Select Medical_Request_gne__c, Medical_Request_gne__r.Account_gne__c, Call2_vod__c, Medical_Request_gne__r.Unsolicited_Request_Verified_gne__c, Medical_Request_gne__r.Referral_History_gne__c, Status_Referral_gne__c, Assigned_To_gne__c, Assigned_To_gne__r.Name, Assigned_To_gne__r.Profile_Name_gne__c FROM Referral_Assignment_gne__c WHERE id = :referralId];
    }
    
    public Account getAccountFromReferral(){
    	return  [SELECT id, Name, isPersonAccount, RecordType.DeveloperName FROM Account WHERE ID = :getReferralAssignment().Medical_Request_gne__r.Account_gne__c];
    }
    
    private Referral_Assignment_gne__c getReferralAssignment(){
    	referralId = String.isEmpty(referralId) ? mainController.call.Referral_Assignment_gne__c : referralId;
    	if(String.isEmpty(referralId)){
    		return null;
    	}
    	if(referralAssignment==null){
    		referralAssignment = getReferralAssignmentById(referralId);
    	}
    	return referralAssignment;
    }
}