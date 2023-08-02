public without sharing class AGS_EX_Exclusion_Update_SFDC_Ctrl {

	public Account currentAccount { get; set; }
	public String accName { get; set; }
	public String accAddress { get; set; }
	public List<Affiliation_vod__c> affiliations { get; set; }
	public List<AGS_EX_Exclusion_Check_gne__c> mostRecentCheck { get; set; }
	public AGS_EX_Exclusion_Request_gne__c newExRequest { get; set; }
	public AGS_EX_Exclusion_Check_gne__c newExCheck { get; set; }
	public String checkStatus { get; set; }


	public Attachment attachmentFile {get; set;}
    private String nameOfSavedFile;

	public AGS_EX_Exclusion_Update_SFDC_Ctrl() {
		String accId = ApexPages.currentPage().getParameters().get('accId');

		if (accId != null && accId != '') {
			List<Account> lstAcc = [SELECT Id, FirstName, LastName, Specialty_1_vod__c, MDMID_gne__c, NPI_vod__c, AGS_EX_Date_Checked_Exclusion_gne__c,
									 AGS_EX_Exclusion_Status_base_gne__c
									FROM Account WHERE Id = :accId];
			
			if (lstAcc.size() != 1) {
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Did not find Account! Are you sure you came here from Account page?'));
			}
			else {				
				currentAccount = lstAcc[0];
				accName = lstAcc[0].FirstName + ' ' + lstAcc[0].LastName;
				accAddress = AGS_EX_Exclusion_Utils.getAddress(currentAccount.Id);
				affiliations = [SELECT To_Account_vod__c,To_Contact_vod__c,Role_vod__c,CreatedById,CreatedDate 
        									FROM Affiliation_vod__c WHERE From_Account_vod__c=:currentAccount.Id];
        		mostRecentCheck = [SELECT AGS_EX_Check_Date_gne__c, AGS_EX_Status_gne__c, AGS_EX_Reviewer_Name_gne__c, AGS_EX_Comments_gne__c, 
        								AGS_EX_Check_Attachment_gne__c, AGS_EX_Exclusion_Request_gne__c, AGS_EX_Attachment_frm_gne__c
									FROM AGS_EX_Exclusion_Check_gne__c 
									WHERE AGS_EX_Exclusion_Request_gne__r.AGS_EX_Account_Name_gne__c = :currentAccount.Id
									ORDER BY AGS_EX_Check_Date_gne__c DESC, CreatedDate DESC LIMIT 1];
				attachmentFile = new Attachment();
				newExCheck = new AGS_EX_Exclusion_Check_gne__c();
				newExRequest = new AGS_EX_Exclusion_Request_gne__c();
			}
		}
		else {
			 ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Missing Account ID! Are you sure you came here from Account page?'));
		}
	}
	
    public List<CORE_Pub_License__c>getStateLicenses(){
    	if(currentAccount != null && currentAccount.mdmId_gne__c != null){
    		return [SELECT Id, License_Number_gne__c, License_State_gne__c FROM CORE_Pub_License__c WHERE Party_Id_ref_gne__r.Mdm_Id_gne__c =:currentAccount.mdmId_gne__c];
    	}
    	return new List<CORE_Pub_License__c>();
    }
    
	public static String insertCvAttachmentAndSaveURL(AGS_EX_Exclusion_Check_gne__c exlusionCheck, Attachment attachmentFile) {
        if (AGS_EX_Exclusion_Utils.insertAttachment(attachmentFile,exlusionCheck.Id)) {
            exlusionCheck.AGS_EX_Check_Attachment_gne__c = AGS_EX_Exclusion_Utils.prepareLinkToAttachment(attachmentFile);
            update exlusionCheck;

            return attachmentFile.name;
        }

        return '';
    }

    public Boolean getIsAnyAffiliation() {
        if (affiliations != null && affiliations.size() > 0){
        	return true;
        }else{
        	return false;
        }
    }

    public Boolean getIsAnyMRC() {
        if (mostRecentCheck != null && mostRecentCheck.size() > 0){
        	return true;
        }else{ 
        	return false;
        }
    }

    public List<SelectOption> getStatuses() {
        return AGS_EX_Exclusion_Utils.getPickListValues(AGS_EX_Exclusion_Check_gne__c.getSObjectType(), 'AGS_EX_Status_gne__c');
    }

    public PageReference cancelExclusionCheck() {
    	return AGS_EX_Exclusion_Utils.createPageRef(AGS_EX_Exclusion_Utils.getReturnURL(currentAccount.Id));
    }

    public PageReference saveExclusionCheck() {
		Attachment attachmentCVCopy = attachmentFile; //copy attachmentCV to not exceed viewstate when giving response
		attachmentFile = new Attachment();
		
		Savepoint sp = Database.setSavepoint();
		try {
			currentAccount.AGS_EX_Date_Checked_Exclusion_gne__c = Date.today();
			if(checkStatus == 'Excluded') {
				currentAccount.AGS_EX_Exclusion_Status_base_gne__c = 'Excluded';
			} 
			else if(checkStatus == 'Sanctioned but legal approved') {
				currentAccount.AGS_EX_Exclusion_Status_base_gne__c = 'Sanctioned but legal approved';
			} 
			else currentAccount.AGS_EX_Exclusion_Status_base_gne__c = 'Verified and clear';
			update currentAccount;

			newExRequest.AGS_EX_Account_Name_gne__c = currentAccount.Id;
			newExRequest.AGS_EX_Request_Status_gne__c = 'Completed';
			String addr = AGS_EX_Exclusion_Utils.getAddress(currentAccount.Id);
			newExRequest.AGS_EX_Account_Primary_Address_gne__c = (addr == null ? 'No address available' : addr);
			insert newExRequest;
			
			newExCheck.AGS_EX_Exclusion_Request_gne__c = newExRequest.Id;
			newExCheck.AGS_EX_Status_gne__c = checkStatus;
			newExCheck.AGS_EX_Check_Date_gne__c = Date.today();
			newExCheck.AGS_EX_Reviewer_Name_gne__c = UserInfo.getUserId();
			insert newExCheck;
			
			if (attachmentCVCopy.Body != null) {
				nameOfSavedFile = insertCvAttachmentAndSaveURL(newExCheck, attachmentCVCopy);
			}
		}catch (Exception ex) {
			Database.rollback(sp);
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Could not save new Exclusion Check'));
			System.debug('$$$ AGS_EX_Exclusion_Update_SFDC_Ctrl Save Exception: ' + ex.getMessage());
			return ApexPages.currentPage();
		}
		
		return AGS_EX_Exclusion_Utils.createPageRef('/' + currentAccount.Id + '?nooverride=1');
	}
}