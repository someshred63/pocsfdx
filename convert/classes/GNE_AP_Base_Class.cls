public virtual class GNE_AP_Base_Class {
	public Id accountPlanId {get; set;}
	public Id csUserId {get; set;}
	public Id fmUserId {get; set;}
	public Id territoryId {get; set;}
	public String fmComments {get; set;}

	public Boolean isReadOnly{get; set;}
	public String csName{get; set;}

	private String lastViewedPageName;

	public GNE_AP_Base_Class(){
		if(String.isNotEmpty(ApexPages.currentPage().getParameters().get('planId'))){
			accountPlanId = ApexPages.currentPage().getParameters().get('planId');
		}
		if(String.isNotEmpty(ApexPages.currentPage().getParameters().get('csUserId'))){
			csUserId = ApexPages.currentPage().getParameters().get('csUserId');
		}

		if (GNE_AP_Util.isFE()){
			if(String.isEmpty(csUserId)){
				csUserId = UserInfo.getUserId();
			}
			if(String.isEmpty(accountPlanId)){
				AP_Account_Planning_gne__c activePlan = GNE_AP_DAO.getActiveAccountPlan(csUserId);
				if(accountPlanId == null && activePlan != null){
					accountPlanId = activePlan.id;
					fmComments = activePlan.DM_Comments_gne__c;
					territoryId = activePlan.Territory_Id_gne__c;
					fmUserId = activePlan.DM_User_gne__c;
				}

			}
		}
		if(!String.isEmpty(accountPlanId)){
			AP_Account_Planning_gne__c plan = [SELECT DM_Comments_gne__c, DM_User_gne__c, Territory_Id_gne__c FROM AP_Account_Planning_gne__c WHERE Id = :accountPlanId];
			fmComments = plan.DM_Comments_gne__c;
			territoryId = plan.Territory_Id_gne__c;
			fmUserId = plan.DM_User_gne__c;
		}
		if(String.isNotEmpty(csUserId)){
			csName = GNE_AP_Util.getCSName(csUserId);
		}
		if(getIsFM()){
			fmUserId = UserInfo.getUserId();
		}

		isReadOnly = GNE_AP_Util.getIsReadOnly();
	}

	public Boolean getIsFE(){
		return GNE_AP_Util.isFE();
	}

	public Boolean getIsFM(){
		return GNE_AP_Util.isFM();
	}

	public virtual PageReference createAccountPlan(){
		if (GNE_AP_Util.isFE()){
			AP_Account_Planning_gne__c activePlan = GNE_AP_DAO.getActiveAccountPlan(Userinfo.getUserId());
			if(activePlan == null){
				activePlan = GNE_AP_Util.createNewAccountPlan();
				insert activePlan;
				accountPlanId = activePlan.id;
			}
			fmUserId = activePlan.DM_User_gne__c;
		}

		String apAction = ApexPages.currentPage().getParameters().get('apAction');
		if(String.isBlank(apAction) || apAction != 'navigate') {
			return redirectToLastViewedPage();
		}
		
		setLastVisitedPage();
		return null;
	}

	private PageReference redirectToLastViewedPage() {
        try{
        	String currentPageName = ApexPages.currentPage().getUrl().substringAfter('/apex/').substringBefore('?');        	
            lastViewedPageName = [SELECT Last_page_visited_gne__c FROM SFA2_User_Preferences_gne__c WHERE CreatedById =: UserInfo.getUserId() ORDER BY CreatedDate DESC LIMIT 1].Last_page_visited_gne__c;

            if(String.isNotBlank(lastViewedPageName) 
            	&& !lastViewedPageName.contains(currentPageName)             	
             	&& lastViewedPageName.contains('GNE_AP_SalesData')) {
             	lastViewedPageName = lastViewedPageName.substringBefore(';');             	
                PageReference lastPage = new PageReference ('/apex/' + lastViewedPageName);
                return lastPage;
            }
        }
        catch(Exception e) {
        }

        return null;
    }    

    public static void setLastVisitedPage() {
    	GNE_AP_Navigation_Controller.setLastVisitedPage();
	}

	public virtual Pagereference CSSubmit(){
		try{
			system.debug(accountPlanId);
			system.debug(fmUserId);
			AP_Account_Planning_gne__c accountPlanning = GNE_AP_DAO.getAccountPlan(accountPlanId);
			if(accountPlanning.Status_gne__c == GNE_AP_Util.AP_IN_PROGRESS){
				GNE_AP_Util.setAccountPlanActionAndStatus(accountPlanning, GNE_AP_Util.AP_APPROVED_STATUS);
			}else if(accountPlanning.Status_gne__c == GNE_AP_Util.AP_RETURNED){
				GNE_AP_Util.setAccountPlanActionAndStatus(accountPlanning, GNE_AP_Util.AP_APPROVED_RESUBMITED_STATUS);
			}
			accountPlanning.Date_Submitted_gne__c = System.now();
			accountPlanning.DM_User_gne__c = fmUserId;
			accountPlanning.Territory_Id_gne__c = territoryId;
			if(String.isNotEmpty(territoryId)){
				accountPlanning.Territory_Number_gne__c = [SELECT Territory_Number_gne__c FROM Territory2 WHERE id=:territoryId].Territory_Number_gne__c;
			}
			update accountPlanning;
			//share plan to DM
			GNE_AP_Util.removeAccountPlanSharing(accountPlanning.id);
			AP_Account_Planning_gne__Share apShare = new AP_Account_Planning_gne__Share();
			apShare.ParentId = accountPlanning.id;
			apShare.AccessLevel = 'Edit';
			apShare.RowCause = Schema.AP_Account_Planning_gne__Share.RowCause.Manual;
			apShare.UserOrGroupId = accountPlanning.DM_User_gne__c;
			insert apShare;

			String addresses = [SELECT Email FROM User WHERE Id= :fmUserId].Email;
			sendStatusEmail(addresses, accountPlanning.Name, 'Submitted', accountPlanning.Date_Submitted_gne__c, '');
		}catch(EmailException ex){
			return GNE_AP_Util.redirectToErrorPage('Sending email message failed!', Apexpages.currentPage().getUrl(), ex.getMessage());
		}catch (Exception ex){
			return GNE_AP_Util.redirectToErrorPage('CS account plan submit failed!', Apexpages.currentPage().getUrl(), ex.getMessage());
		}
		PageReference redirect = Page.GNE_AP_Status;
		redirect.setRedirect(true);
		return redirect;
	}

	public virtual PageReference csArchive(){
		system.debug(accountPlanId);
		try{
			AP_Account_Planning_gne__c accountPlanning = GNE_AP_DAO.getAccountPlan(accountPlanId);
			if(accountPlanning.Status_gne__c != GNE_AP_Util.AP_APPROVED){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Only approved plan can be archived.'));
				return null;
			}
			GNE_AP_Util.setAccountPlanActionAndStatus(accountPlanning, GNE_AP_Util.AP_ARCHIVED_STATUS);
			accountPlanning.Date_Archived_gne__c = System.now();
			update accountPlanning;
			sendStatusEmail(accountPlanning.DM_User_gne__r.Email, accountPlanning.Name, 'Archived', accountPlanning.Date_Archived_gne__c, '');
			createAccountPlan();
		}catch(EmailException ex){
			return GNE_AP_Util.redirectToErrorPage('Sending email message failed!', Apexpages.currentPage().getUrl(), ex.getMessage());
		}catch (Exception ex){
			return GNE_AP_Util.redirectToErrorPage('CS account plan archiving failed!', Apexpages.currentPage().getUrl(), ex.getMessage());
		}
		PageReference redirect = Page.GNE_AP_History;
		redirect.setRedirect(true);
		return redirect;
	}

	public virtual Pagereference dmApprove(){
		try{
			List<AP_Account_PTP_gne__c>accountPtp = [SELECT id FROM AP_Account_PTP_gne__c WHERE AP_Account_Planning_gne__c=:accountPlanId];
			List<AP_PTP_gne__c>apPtp = [SELECT id FROM AP_PTP_gne__c WHERE AP_Account_Planning_gne__c=:accountPlanId];

			system.debug('dmApprove method accountPlanId: '+accountPlanId);
			AP_Account_Planning_gne__c accountPlanning = GNE_AP_DAO.getAccountPlan(accountPlanId);
			GNE_AP_Util.savePerformanceData(accountPlanning);

			delete accountPtp;
			delete apPtp;

			GNE_AP_Util.setAccountPlanActionAndStatus(accountPlanning, GNE_AP_Util.AP_COMPLETED_STATUS);
			accountPlanning.Date_Approved_gne__c = System.now();
			update accountPlanning;

			if(String.isNotEmpty(accountPlanning.Territory_Id_gne__c)){
				GNE_AP_Util.shareAccountPlanToTerritory(accountPlanning.id, accountPlanning.Territory_Id_gne__c);
			}

			sendStatusEmail(accountPlanning.CS_User_gne__r.Email, accountPlanning.Name, 'Approved', accountPlanning.Date_Approved_gne__c, '');
		}catch(EmailException ex){
			return GNE_AP_Util.redirectToErrorPage('Sending email message failed!', Apexpages.currentPage().getUrl(), ex.getMessage());
		}catch (Exception ex){
			return GNE_AP_Util.redirectToErrorPage('DM account plan approval failed!', Apexpages.currentPage().getUrl(), ex.getMessage(), ex.getLineNumber());
		}
		PageReference redirect = Page.GNE_AP_Status;
		redirect.setRedirect(true);
		return redirect;
	}

	public virtual Pagereference dmReturn(){
		system.debug('DM return method accountPlanId: '+accountPlanId);
		try{
			AP_Account_Planning_gne__c accountPlanning = GNE_AP_DAO.getAccountPlan(accountPlanId);
			GNE_AP_Util.setAccountPlanActionAndStatus(accountPlanning, GNE_AP_Util.AP_RESUBMIT_STATUS);
			accountPlanning.Date_Returned_gne__c = System.now();
			String fmFeedback = accountPlanning.DM_Comments_gne__c;
			accountPlanning.DM_Comments_gne__c = '';
			update accountPlanning;
			GNE_AP_Util.removeAccountPlanSharing(accountPlanning.id);

			String additionalMessage = '\nFM Feedback/Comments:\n' + fmComments;
			sendStatusEmail(accountPlanning.CS_User_gne__r.Email, accountPlanning.Name, 'Returned', accountPlanning.Date_Returned_gne__c, additionalMessage);
		}catch(EmailException ex){
			return GNE_AP_Util.redirectToErrorPage('Sending email message failed!', Apexpages.currentPage().getUrl(), ex.getMessage());
		}catch (Exception ex){
			system.debug('DM return method failed: '+ex.getMessage());
			return GNE_AP_Util.redirectToErrorPage('DM account plan return failed!', Apexpages.currentPage().getUrl(), ex.getMessage());
		}
		PageReference redirect = Page.GNE_AP_Status;
		redirect.setRedirect(true);
		return redirect;
	}

	public virtual Pagereference dmArchive(){
		try{
			system.debug('dmArchive method accountPlanId: '+accountPlanId);
			AP_Account_Planning_gne__c accountPlanning = GNE_AP_DAO.getAccountPlan(accountPlanId);
			if(accountPlanning == null || accountPlanning.Status_gne__c != GNE_AP_Util.AP_APPROVED){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Only approved plan can be archived.'));
				return null;
			}
			GNE_AP_Util.setAccountPlanActionAndStatus(accountPlanning, GNE_AP_Util.AP_ARCHIVED_STATUS);
			accountPlanning.Date_Archived_gne__c = System.now();
			update accountPlanning;
			sendStatusEmail(accountPlanning.CS_User_gne__r.Email, accountPlanning.Name, 'Archived', accountPlanning.Date_Archived_gne__c, '');
		}catch(EmailException ex){
			return GNE_AP_Util.redirectToErrorPage('Sending email message failed!', Apexpages.currentPage().getUrl(), ex.getMessage());
		}catch (Exception ex){
			return GNE_AP_Util.redirectToErrorPage('DM account plan archiving failed!', Apexpages.currentPage().getUrl(), ex.getMessage());
		}
		PageReference redirect = Page.GNE_AP_History;
		redirect.setRedirect(true);
		return redirect;
	}

	private void sendStatusEmail(String addresses, String planName, String planStatus, Datetime changeDate, String additionalMessage){
		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		if (String.isNotEmpty(addresses)){
			List<String> toAddresses = addresses.split(':', 0);
			email.setSubject('Account Plan '+ planName +' '+planStatus);
			email.setToAddresses(toAddresses);
			String userDate = GNE_AP_Util.getLocalDate(changeDate);
			email.setPlainTextBody('Account Plan '+ planName +' was ' + planStatus + ' as of ' + userDate + additionalMessage);
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
		}
	}

	public virtual PageReference redirectToPreview1(){
		PageReference redirect = new PageReference('/apex/GNE_AP_Preview_Report');
		redirect.setRedirect(true);
		redirect.getParameters().put('planId', accountPlanId);
		redirect.getParameters().put('csUserId', csUserId);
		return redirect;
	}

}