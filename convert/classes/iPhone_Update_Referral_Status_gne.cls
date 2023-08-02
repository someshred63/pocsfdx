/******************************************************************************************
*  @author: Sebastian Karczmarski, Roche (contractor)
*  @email: sebastian.karczmarski@contractors.roche.com   
*  Created: 2013-05-24
*  Project: OTR2
*  Description: REST Webservice, updates ReferralAssignment status.             
*******************************************************************************************/
@RestResource(urlMapping='/iPhoneUpdateReferralStatus/*')
global with sharing class iPhone_Update_Referral_Status_gne {
	
	@HttpPost 
	global static iPhone_Commons_gne.RestResponse processRequest(String referralAssignmentId, String newStatus, Boolean unsolicitedRequestVerified, String iPhoneRequestId) {		
		return iPhone_Commons_gne.executeAlterData(
			new UpdateReferralStatusExecutor(), 
			new UpdateReferralStatusArg(referralAssignmentId, newStatus, unsolicitedRequestVerified, iPhoneRequestId)
		);						 																					
	}
	
	class UpdateReferralStatusArg implements iPhone_Commons_gne.BaseArgs {
		final String referralAssignmentId; 
		final String newStatus;
		final Boolean unsolicitedRequestVerified;
		final String iPhoneRequestId;
		
		public UpdateReferralStatusArg(String referralAssignmentId, String newStatus, Boolean unsolicitedRequestVerified, String iPhoneRequestId) {
			this.referralAssignmentId = referralAssignmentId;
			this.newStatus = newStatus;
			this.unsolicitedRequestVerified = unsolicitedRequestVerified;
			this.iPhoneRequestId = iPhoneRequestId;
		}

		public String getIPhoneRequestId(){
			return this.iPhoneRequestId;
		}
	}
	
	public without sharing class UpdateReferralStatusExecutor implements iPhone_Commons_gne.Runnable {
		
		public Object run(Object obj) {
			UpdateReferralStatusArg arg = (UpdateReferralStatusArg)obj;
			updateStatus(arg.referralAssignmentId, arg.newStatus, arg.unsolicitedRequestVerified, arg.getIPhoneRequestId());
			return null;
		}
						
		private void updateStatus(String referralAssignmentId, String newStatus, Boolean unsolicitedRequestVerified, String iPhoneRequestId) {
			checkHasValue('referralAssignmentId', referralAssignmentId);
			checkHasValue('newStatus', newStatus);			
						 
			Referral_Assignment_gne__c referralAssignment = iPhone_DAO.getReferralAssignmentById(referralAssignmentId);
			system.debug('Found referralAssignment: ' + referralAssignment);	
			
			Medical_Communication_gne__c medicalCommunication = getMedicalCommunicationById(referralAssignment.Medical_Request_gne__c);			
			system.debug('Found medicalCommunication: ' + medicalCommunication);
			
			Boolean statusChanged = referralAssignment.Status_Referral_gne__c != newStatus; 
			if(statusChanged) {
				referralAssignment.Status_Referral_gne__c = newStatus;
				referralAssignment.Status_Referral_Date_gne__c = datetime.now();
				update referralAssignment;
				system.debug('Referral: status successfully updated: ' + referralAssignment);		
				
				User assignedToUser = iPhone_DAO.getUserById(referralAssignment.Assigned_To_gne__c);			
				String strAssignedUserName = assignedToUser.Name;
				String strAssignedUserRole = assignedToUser.Profile_Name_gne__c;
				String referralHistory = datetime.now().format(GNE_Referral_Utils.strPSTFormat, GNE_Referral_Utils.strPST) + ', ' + GNE_Referral_Utils.strStatusUpdate + ', ' + UserInfo.getName() + ', ' + strAssignedUserName + ', ' + (String)referralAssignment.Assigned_To_gne__c + ', ' + strAssignedUserRole + ', ' + newStatus + ';';                      
	            if (String.isBlank(medicalCommunication.Referral_History_gne__c)){
	            	medicalCommunication.Referral_History_gne__c = referralHistory;
	            } else {
	            	medicalCommunication.Referral_History_gne__c += referralHistory;
	            }
				if( String.isNotBlank(iPhoneRequestId) ) {
					medicalCommunication.iPhone_Request_Id_gne__c = iPhoneRequestId;
				}
	            update medicalCommunication;				
	            system.debug('Referral, medical communication updated: ' + medicalCommunication);
				
				if(GNE_Referral_Utils.sendReferralEmail(referralAssignment, medicalCommunication, newStatus)){
		            referralAssignment.Status_Email_gne__c = GNE_Referral_Utils.getStatusEmail(newStatus);
		            referralAssignment.Status_Email_Date_gne__c = datetime.now();	      
		            update referralAssignment;			
					system.debug('Referral: StatusEmail successfully updated: ' + referralAssignment);		
		        } else {
		        	system.debug('Referral: email sending failed!');
		        }
		        if(referralAssignment.call2_vod__c != null){
					GNE_SFA2_Referral_Ext.processLinkedInteraction(referralAssignment.Status_Referral_gne__c, referralAssignment.call2_vod__c, false);
		        }
			}
			if(!medicalCommunication.Unsolicited_Request_Verified_gne__c && unsolicitedRequestVerified == true){
				medicalCommunication.Unsolicited_Request_Verified_gne__c = true;
				medicalCommunication.Unsolicited_Request_Verified_By_gne__c = UserInfo.getUserId();
				medicalCommunication.Unsolicited_Request_Verified_Date_gne__c = Date.today();
				update medicalCommunication;
			}
		}
		
		private void checkHasValue(String valueName, String value) {
			if(!iPhone_StringUtil.hasValue(value)) {
				String message = 'Value: ' + valueName + ' is null or empty.'; 
				throw new iPhone_Commons_gne.IPhoneException(message);	
			}
		}
		
		// Moved from DAO because of 'sharig' problem.
		private Medical_Communication_gne__c getMedicalCommunicationById(String id) {
			return	[
				SELECT
					Id,
					Name,
					Referral_History_gne__c,
					Referral_Assignment_gne__c,
					Unsolicited_Request_Verified_gne__c
				FROM
					Medical_Communication_gne__c
				WHERE
					Id = :id
			];
		}
	}			
}