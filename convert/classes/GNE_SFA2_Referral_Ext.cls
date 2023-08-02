public without sharing class GNE_SFA2_Referral_Ext {

	/* 
	This class is used to edit and view Referral.
	Referral is a Medical Communication request to an MSL. The Referral is identified as a Medical communication
	request with a recordType Referral.

	Author : Sweta Khalasi
	Created : 01 Jul 2011
	Last Modified : 06 Oct 2014
	Modification:
	giszczap: SFA-923
	kozminsl: SFA-428, sfa-617
	*/
	private GNE_SFA2_User_App_Context_gne__c userApplicationContext = GNE_SFA2_Util.getUserApplicationContext();

	public String comments{get; set;}
	public String searchFld { get; set; }
	public Id searchId { get; set; }
	public String selectedStatus{get; set;} 
	public Boolean isClosed {get; private set;}
	public Boolean isEditable {get; private set;}
	public Boolean isAssigned {get; private set;}
	public List<ReferralCommentsWrapper> refComments {get; private set;}
	public List<ReferralAssignmentWrapper> refHistory {get; private set;}
	
	private List<String> lstStatus = new List<String> ();
	private Medical_Communication_gne__c objReferralProxy;
	private Referral_Assignment_gne__c objReferralAssignmentProxy;
	private User currentUser = new User();
	
	private Referral_Assignment_gne__c referralAssignment;
	private Referral_Assignment_gne__c referralAssignmentCopy;
	private Medical_Communication_gne__c objReferral;
	private String searchFldCopy = '';
	private Id searchIdCopy;
	private SFA2_Configuration_Object_gne__c pageConfiguration; 
	private Boolean isReAssigned = false;

	public Medical_Communication_gne__c getReferralProxyObject(){
		return objReferralProxy;
	}
	
	public Referral_Assignment_gne__c getReferralAssignmentProxyObject(){
		return objReferralAssignmentProxy;
	}
	
	public List<SelectOption> getStatusList(){               
		List<SelectOption> options=new List<SelectOption>();
		for(String strStatus: lstStatus){
			if(strStatus != null){
				options.add(new SelectOption(strStatus, strStatus));
			}    
		}
		return options;
	}
	
	private void loadStatusList(String strCurrentStatus){
		lstStatus.clear();
		if(strCurrentStatus==GNE_Referral_Utils.strAssigned){
			lstStatus.add(GNE_Referral_Utils.strAssigned);
			lstStatus.add(GNE_Referral_Utils.strAcknowledged);
		}else if(strCurrentStatus==GNE_Referral_Utils.strAcknowledged){
			lstStatus.add(GNE_Referral_Utils.strAcknowledged);
			if (GNE_Referral_Utils.isMCLorMSL(currentUser)){
				lstStatus.add(GNE_Referral_Utils.strClosedDuplicate);
			}
			lstStatus.add(GNE_Referral_Utils.strClosedHCPUnresponsive);
			lstStatus.add(GNE_Referral_Utils.strClosedNotVerifiable);
		}else{
			lstStatus.add(strCurrentStatus);
		}
	}

	public Boolean getIsMedAffairProfileUser(){
		if(currentUser !=null && currentUser.Profile_Name_gne__c !=null && currentUser.Profile_Name_gne__c !='' &&(currentUser.Profile_Name_gne__c.contains(GNE_Referral_Utils.MedAffairProfile) || currentUser.Profile_Name_gne__c.contains(GNE_Referral_Utils.SysAdminProfile)) && (!currentUser.Profile_Name_gne__c.contains(GNE_Referral_Utils.TISLProfile))){
			return true;
		}
		return false;
	}

	public GNE_SFA2_Referral_Ext(ApexPages.StandardController stdController) {
		isClosed = false;
		pageConfiguration = GNE_SFA2_Util.getListPageConfiguration('Referral_Assignment_gne__c');    
		
		//instantiate proxy object
		objReferralProxy = new Medical_Communication_gne__c();
		objReferralAssignmentProxy = new Referral_Assignment_gne__c();
		
		Referral_Assignment_gne__c refAssignment = (Referral_Assignment_gne__c)  stdController.getRecord();
		referralAssignment = [Select Account_gne__c, AccountId_gne__c, Assigned_To_gne__c, Assigned_To_gne__r.Id, Assigned_To_gne__r.Name, Assigned_To_Manager_gne__c, Call2_vod__c, Referral_Assigned_Manager_Email_gne__c, Referral_Assigned_User_Email_gne__c, CreatedById, CreatedDate, Follow_up_Method_gne__c, Id,Revised_Requested_Completion_Date_gne__c,Referral_Link_gne__c, Medical_Request_gne__c, Medical_Request_gne__r.Account_gne__c, Medical_Request_gne__r.Account_Medcom_gne__c, Medical_Request_gne__r.Account_Referral_gne__c, Medical_Request_gne__r.Address_Line_1_gne__c, Medical_Request_gne__r.Assigned_To_gne__c, Medical_Request_gne__r.Assigned_To_Id_gne__c, Medical_Request_gne__r.Comments_Referral_gne__c, Medical_Request_gne__r.CreatedById, Medical_Request_gne__r.CreatedDate, Medical_Request_gne__r.Email_gne__c, Medical_Request_gne__r.Fax_gne__c, Medical_Request_gne__r.Follow_up_Method_gne__c, Medical_Request_gne__r.Id, Medical_Request_gne__r.Medical_Question_gne__c,Medical_Request_gne__r.Molecule_Name_gne__c,Medical_Request_gne__r.Product_Name_gne__c,Medical_Request_gne__r.TA_SubTA_Name_gne__c, Medical_Request_gne__r.Molecule_gne__c, Medical_Request_gne__r.Name, Medical_Request_gne__r.OwnerId, Medical_Request_gne__r.Phone_gne__c,Medical_Request_gne__r.Phone_1_gne__c, Medical_Request_gne__r.Priority_gne__c, Medical_Request_gne__r.Product_gne__c, Medical_Request_gne__r.RecordTypeId, Medical_Request_gne__r.Referral_Assignment_gne__c, Medical_Request_gne__r.Referral_History_gne__c,         
		Medical_Request_gne__r.Requested_By_gne__c,Medical_Request_gne__r.Referral_Source_gne__c,Medical_Request_gne__r.Is_MedComm_gne__c, Medical_Request_gne__r.Requested_Completion_Date_gne__c, 
		Medical_Request_gne__r.Status_Referral_Date_gne__c, Medical_Request_gne__r.Status_Referral_Email_Date_gne__c, Medical_Request_gne__r.Status_Referral_Email_gne__c, Medical_Request_gne__r.Status_Referral_gne__c, Medical_Request_gne__r.TA_SubTA_gne__c, Medical_Request_gne__r.Unsolicited_Request_Verified_By_gne__c,Medical_Request_gne__r.Unsolicited_Request_Verified_gne__c, Medical_Request_gne__r.Unsolicited_Request_Verified_Date_gne__c, Molecule_gne__c, Name, OwnerId, Priority_gne__c, Product_gne__c, Status_Email_Date_gne__c, Status_Email_gne__c, Status_Referral_Date_gne__c,Escalation_Status_gne__c,Due_Date_gne__c, Status_Referral_gne__c, TA_SubTA_gne__c from Referral_Assignment_gne__c where Id =: refAssignment.Id];
		
		if(referralAssignment!=null){
			objReferralAssignmentProxy.Assigned_To_gne__c = referralAssignment.Assigned_To_gne__c;
			searchFld = referralAssignment.Assigned_To_gne__r.Name;
			searchId = referralAssignment.Assigned_To_gne__r.Id;
			
			referralAssignmentCopy = new Referral_Assignment_gne__c(Assigned_To_gne__c = referralAssignment.Assigned_To_gne__c, Medical_Request_gne__c=referralAssignment.Medical_Request_gne__c,Status_Referral_gne__c=referralAssignment.Status_Referral_gne__c,OwnerId=referralAssignment.OwnerId,Revised_Requested_Completion_Date_gne__c=referralAssignment.Revised_Requested_Completion_Date_gne__c );
			searchFldCopy = referralAssignment.Assigned_To_gne__r.Name;
			searchIdCopy = referralAssignment.Assigned_To_gne__c;
			if(referralAssignment.Medical_Request_gne__c!=null){
				objReferral = [SELECT Account_gne__c, Account_Medcom_gne__c, Account_Referral_gne__c, Address_Line_1_gne__c, Assigned_To_gne__c, Assigned_To_Id_gne__c, Comments_Referral_gne__c, CreatedById, CreatedDate, Email_gne__c, Fax_gne__c, 
									Follow_up_Method_gne__c, Id, Medical_Question_gne__c, Molecule_Name_gne__c,Product_Name_gne__c,TA_SubTA_Name_gne__c,Molecule_gne__c, Name, OwnerId, Phone_gne__c,Phone_1_gne__c, Priority_gne__c, Product_gne__c,
									RecordTypeId, Referral_Assignment_gne__c, Referral_Assignment_gne__r.Account_gne__c, Referral_Assignment_gne__r.AccountId_gne__c, Referral_Assignment_gne__r.Assigned_To_gne__c,Referral_Assignment_gne__r.Assigned_To_Manager_gne__c, 
									Referral_Assignment_gne__r.Referral_Assigned_Manager_Email_gne__c, Referral_Assignment_gne__r.Referral_Assigned_User_Email_gne__c, Referral_Assignment_gne__r.CreatedById, Referral_Assignment_gne__r.CreatedDate, 
									Referral_Assignment_gne__r.Follow_up_Method_gne__c, Referral_Assignment_gne__r.Id, Referral_Assignment_gne__r.Medical_Request_gne__c, Referral_Assignment_gne__r.Molecule_gne__c, Referral_Assignment_gne__r.Name, 
									Referral_Assignment_gne__r.OwnerId, Referral_Assignment_gne__r.Priority_gne__c, Referral_Assignment_gne__r.Product_gne__c, Referral_Assignment_gne__r.Status_Email_Date_gne__c, Referral_Assignment_gne__r.Status_Email_gne__c, 
									Referral_Assignment_gne__r.Status_Referral_Date_gne__c,Referral_Assignment_gne__r.Due_Date_gne__c, Referral_Assignment_gne__r.Status_Referral_gne__c, Referral_Assignment_gne__r.TA_SubTA_gne__c, Referral_History_gne__c,             
									Requested_Completion_Date_gne__c, Requested_By_gne__c,Referral_Source_gne__c,Is_MedComm_gne__c, Status_Referral_Date_gne__c, Status_Referral_Email_Date_gne__c, Status_Referral_Email_gne__c, Status_Referral_gne__c, 
									TA_SubTA_gne__c, Unsolicited_Request_Verified_By_gne__c,Unsolicited_Request_Verified_gne__c, Unsolicited_Request_Verified_Date_gne__c, Referral_Assignment_gne__r.Call2_vod__c
							   FROM Medical_Communication_gne__c
							   WHERE id = :referralAssignment.Medical_Request_gne__c];
				
				objReferralProxy.Unsolicited_Request_Verified_gne__c = objReferral.Unsolicited_Request_Verified_gne__c;
				if((String)objReferral.Unsolicited_Request_Verified_By_gne__c != null){
					objReferralProxy.Unsolicited_Request_Verified_By_gne__c = objReferral.Unsolicited_Request_Verified_By_gne__c;
				}
				if(String.valueOf(objReferral.Unsolicited_Request_Verified_Date_gne__c) != null){
					objReferralProxy.Unsolicited_Request_Verified_Date_gne__c = objReferral.Unsolicited_Request_Verified_Date_gne__c;
				}
			}
			currentUser=GNE_Referral_Utils.getCurrentUser(UserInfo.getUserId());
			//If status is Assigned, than do not allow user to alow edit any thing untill acknowledge
			isAssigned = isReferralAssigned();
			//Once verified by an MSL, the unsolicited request verified by field cannot be updated.
			isEditable = isUnsolicitedIsEditable();
			
			//To display Referral history
			loadRefHistory();
			//To display Referral Comments
			loadRefComments();
			loadStatusList(referralAssignment.Status_Referral_gne__c);
		}
	}
	
	public PageReference edit() {
		//A Closed or Fulfilled referral cannot be edited.
		if(!isClosed){  
			PageReference p = Page.GNE_SFA2_EditReferralPage;
			p.setRedirect(true);
			p.getParameters().put('id',referralAssignment.Id);
			return p;
		}else{
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'A Closed or Fulfilled referral cannot be edited.'));        
			return null;
		}
	}
	
	public GNE_SFA2_Referral_Ext(){
		this.isClosed = false;
		this.isAssigned = false;
		this.isEditable = false;
	}

	public Boolean isReferralAssigned(){
		if(currentUser.Profile_Name_gne__c.contains(GNE_Referral_Utils.SysAdminProfile)){
			isClosed = false;
		}else if((String)referralAssignment.Status_Referral_gne__c != GNE_Referral_Utils.strAcknowledged && (String)referralAssignment.Status_Referral_gne__c != GNE_Referral_Utils.strAssigned){
			isClosed = true;
		}else{
			if(currentUser.Profile_Name_gne__c.contains(GNE_Referral_Utils.MSLManagerProfile)){
				isClosed = false;
			}else if(referralAssignment.OwnerId != UserInfo.getUserId()){
				isClosed = true;
			}else{
				isClosed = false;
			}
		}
		
		if((String)referralAssignment.Status_Referral_gne__c == GNE_Referral_Utils.strAssigned){
			return true;
		}else{
			return false;
		}
	}
	
	public String getReferralName(){
		if(referralAssignment!=null){
			return referralAssignment.Name;
		}
		return '';
	}
	
	public String getMedCommName(){
		if(objReferral != null){
			return objReferral.Name;
		}
		return '';
	}

	public String getActiveMenuItem(){
		String result = '';
		if(pageConfiguration != null && pageConfiguration.Attributes_gne__c!=null && pageConfiguration.Attributes_gne__c.contains('activeMenuItem')){
			result = pageConfiguration.Attributes_gne__c.subStringBetween('activeMenuItem=',';');
		}
		return result;
	}

	public Boolean isUnsolicitedIsEditable(){
		if(objReferral != null){
			//once Unsolicited_Request_Verified_gne__c is true than it can not be edited again
			if(objReferral.Unsolicited_Request_Verified_gne__c && (String)objReferral.Unsolicited_Request_Verified_By_gne__c != null && String.valueOf(objReferral.Unsolicited_Request_Verified_Date_gne__c) != null){
				return false;
			}else if(!isAssigned){
				objReferralProxy.Unsolicited_Request_Verified_By_gne__c = UserInfo.getUserId();
				objReferralProxy.Unsolicited_Request_Verified_Date_gne__c = Date.today();
				return true;
			}
		}
		return false;
	}

	public Boolean isStatusAndAssignedToChanged(){
		if(selectedStatus != null && selectedStatus != (String)referralAssignmentCopy.Status_Referral_gne__c){    
			if((String)searchId != null && (String)searchId!= (String)referralAssignmentCopy.Assigned_To_gne__c){
				return true;
			}
		}
		return false;
	}

	public Boolean isVerified(){
		if(!isEditable || objReferral == null){
			return true;
		}
		//Referral can not be fullfill unless it gets verified.
		if(selectedStatus != null && (selectedStatus !=GNE_Referral_Utils.strAcknowledged && selectedStatus != GNE_Referral_Utils.strAssigned && selectedStatus !=GNE_Referral_Utils.strClosedHCPUnresponsive && selectedStatus != GNE_Referral_Utils.strClosedNotVerifiable && selectedStatus != GNE_Referral_Utils.strClosedDuplicate) && (String)objReferralProxy.Unsolicited_Request_Verified_By_gne__c == null && String.valueOf(objReferralProxy.Unsolicited_Request_Verified_Date_gne__c) == null && (!objReferralProxy.Unsolicited_Request_Verified_gne__c)){
			return false;
		}
		return true;
	}

	public Medical_Communication_gne__c getReferral(){
		return objReferral;
	}

	public Referral_Assignment_gne__c getReferralAssignment(){
		return referralAssignment;
	}
	
	public Referral_Assignment_gne__c getNewReferralAssignment(Id objNewRefAssId){
		Referral_Assignment_gne__c objNewReferralAssignment = new Referral_Assignment_gne__c();
		try{
			objNewReferralAssignment = [Select Account_gne__c, AccountId_gne__c, Assigned_To_gne__c, Assigned_To_gne__r.Id, Assigned_To_gne__r.Name,Assigned_To_Manager_gne__c, Referral_Assigned_Manager_Email_gne__c, Referral_Assigned_User_Email_gne__c, CreatedById, CreatedDate, Follow_up_Method_gne__c, Id,Referral_Link_gne__c,Revised_Requested_Completion_Date_gne__c, Medical_Request_gne__c, Medical_Request_gne__r.Account_gne__c, Medical_Request_gne__r.Account_Medcom_gne__c, Medical_Request_gne__r.Account_Referral_gne__c, Medical_Request_gne__r.Address_Line_1_gne__c, Medical_Request_gne__r.Assigned_To_gne__c, Medical_Request_gne__r.Assigned_To_Id_gne__c, Medical_Request_gne__r.Comments_Referral_gne__c, Medical_Request_gne__r.CreatedById, Medical_Request_gne__r.CreatedDate, Medical_Request_gne__r.Email_gne__c, Medical_Request_gne__r.Fax_gne__c, Medical_Request_gne__r.Follow_up_Method_gne__c, Medical_Request_gne__r.Id, Medical_Request_gne__r.Medical_Question_gne__c, Medical_Request_gne__r.Molecule_Name_gne__c,Medical_Request_gne__r.Product_Name_gne__c,Medical_Request_gne__r.TA_SubTA_Name_gne__c,Medical_Request_gne__r.Molecule_gne__c, Medical_Request_gne__r.Name, Medical_Request_gne__r.OwnerId, Medical_Request_gne__r.Phone_gne__c,Medical_Request_gne__r.Phone_1_gne__c, Medical_Request_gne__r.Priority_gne__c, Medical_Request_gne__r.Product_gne__c, Medical_Request_gne__r.RecordTypeId, Medical_Request_gne__r.Referral_Assignment_gne__c, Medical_Request_gne__r.Referral_History_gne__c,             
			Medical_Request_gne__r.Requested_By_gne__c,Medical_Request_gne__r.Referral_Source_gne__c,Medical_Request_gne__r.Is_MedComm_gne__c,Medical_Request_gne__r.Requested_Completion_Date_gne__c, 
			Medical_Request_gne__r.Status_Referral_Date_gne__c, Medical_Request_gne__r.Status_Referral_Email_Date_gne__c, Medical_Request_gne__r.Status_Referral_Email_gne__c, Medical_Request_gne__r.Status_Referral_gne__c, Medical_Request_gne__r.TA_SubTA_gne__c, Medical_Request_gne__r.Unsolicited_Request_Verified_By_gne__c,Medical_Request_gne__r.Unsolicited_Request_Verified_gne__c, Medical_Request_gne__r.Unsolicited_Request_Verified_Date_gne__c, Molecule_gne__c, Name, OwnerId, Priority_gne__c, Product_gne__c, Status_Email_Date_gne__c, Status_Email_gne__c, Status_Referral_Date_gne__c,Escalation_Status_gne__c,Due_Date_gne__c, Status_Referral_gne__c, TA_SubTA_gne__c from Referral_Assignment_gne__c where Id =: objNewRefAssId];
		}catch (Exception e) {
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error on the page:' + e));
			return null;
		}
		return objNewReferralAssignment;
	}

	public PageReference cancel() {
		PageReference p = Page.GNE_SFA2_MyReferrals;
		p.setRedirect(true);
		return p;
	}
	
	public PageReference save() {
		Boolean blnIsReferralUpdated = false;
		Boolean blnIsReferralAssignmentUpdated = false;
		Boolean blnIsStatusChanged = false;
		Boolean isRequestVerified = false;
		
		String refHistory=(String)objReferral.Referral_History_gne__c;
		List<String> lstAssignmentErrors = new List<String> ();
		
		GNE_Referral_Utils.isMedicalReferral = true;    
		Savepoint sp1=null;
		
		if(String.isEmpty(searchFld)){
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter the value for Assigned To field.'));
			GNE_Referral_Utils.isMedicalReferral = false;
			return null;
		}
		if (searchFld != searchFldCopy || searchId != searchIdCopy){
			List<User> lstUserIds = GNE_Referral_Utils.getAssignedUser(searchFld, 'Edit');
			if (lstUserIds != null && lstUserIds.size() >0){
				if(lstUserIds.size() ==1){
					searchId = lstUserIds[0].Id;
					searchFld = lstUserIds[0].Name;
				}else{
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Multiple User found. Click Lookup icon at Assigned To Field to refine the search.'));
					GNE_Referral_Utils.isMedicalReferral = false;
					return null;
				}
			}else{
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No User found. Click Lookup icon at Assigned To Field to select appropriate user.'));
				GNE_Referral_Utils.isMedicalReferral = false;
				return null;
			}       
		}
		
		//Revised Completion Date Should be greater than today.
		if(referralAssignment.Revised_Requested_Completion_Date_gne__c != null && referralAssignment.Revised_Requested_Completion_Date_gne__c != referralAssignmentCopy.Revised_Requested_Completion_Date_gne__c && referralAssignment.Revised_Requested_Completion_Date_gne__c < Date.today()){
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Revised Completion Date Should be greater than today.'));
			GNE_Referral_Utils.isMedicalReferral = false;
			return null;
		}else{
			//A Closed or Fulfilled referral cannot be edited.
			if(isClosed){
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'A Closed or Fulfilled referral cannot be edited.'));
				GNE_Referral_Utils.isMedicalReferral = false;
				return null;
			}
			try{
				//get Referral due date
				DateTime dueDate = GNE_Referral_Utils.getDueDate(datetime.now(), (String)objReferral.Priority_gne__c);
				String strAssignedUserNameRole = GNE_Referral_Utils.getUserNameAndRole((String)referralAssignmentCopy.Assigned_To_gne__c);
				String strAssignedUserName='';
				String strAssignedUserRole='';
				
				if(strAssignedUserNameRole != ''){
					String[] lstUserNameAndRole = strAssignedUserNameRole.split(',', 2);
					if(lstUserNameAndRole.size() >0){
						strAssignedUserName =lstUserNameAndRole[0];
						strAssignedUserRole =lstUserNameAndRole[1];                     
					}
				}
				sp1 = Database.setSavepoint();
				//Once verified , the unsolicited request verified by field cannot be updated.
				if(isEditable){
					if(objReferralProxy.Unsolicited_Request_Verified_gne__c){
						isRequestVerified = true;
						objReferral.Unsolicited_Request_Verified_gne__c = objReferralProxy.Unsolicited_Request_Verified_gne__c;
						objReferral.Unsolicited_Request_Verified_By_gne__c = UserInfo.getUserId();
						objReferral.Unsolicited_Request_Verified_Date_gne__c = Date.today();
						blnIsReferralUpdated=true;                  
						refHistory = refHistory + datetime.now().format(GNE_Referral_Utils.strPSTFormat,GNE_Referral_Utils.strPST) + ', ' + GNE_Referral_Utils.strRequestVerified +  ', ' + UserInfo.getName() + ', ' + strAssignedUserName + ', ' + (String)referralAssignmentCopy.Assigned_To_gne__c + ', ' + strAssignedUserRole + ', ' + (String)referralAssignmentCopy.Status_Referral_gne__c + ';';
					}else{
						objReferralProxy.Unsolicited_Request_Verified_By_gne__c = null;
						objReferralProxy.Unsolicited_Request_Verified_Date_gne__c = null;
					}
				}
				if(String.isNotEmpty(comments)){
					String strComment = objReferral.Comments_Referral_gne__c != null ? objReferral.Comments_Referral_gne__c : '';
					strComment = 'Created By: ' + UserInfo.getName() + ' (' + datetime.now().format(GNE_Referral_Utils.strPSTFormat,GNE_Referral_Utils.strPST) + ')' + ',@,' + comments + ',#,' + strComment;
					objReferral.Comments_Referral_gne__c = strComment;
					blnIsReferralUpdated=true;
				}
				//If Revised Requested Completion Date is entered than put the status in Referral history
				if(referralAssignment.Revised_Requested_Completion_Date_gne__c != null && referralAssignment.Revised_Requested_Completion_Date_gne__c != referralAssignmentCopy.Revised_Requested_Completion_Date_gne__c){
					blnIsReferralAssignmentUpdated=true;
					blnIsReferralUpdated=true;
					refHistory = refHistory + datetime.now().format(GNE_Referral_Utils.strPSTFormat,GNE_Referral_Utils.strPST) + ', ' + GNE_Referral_Utils.strCompletionDateUpdate +  ', ' + UserInfo.getName() + ', ' + strAssignedUserName + ', ' + (String)referralAssignmentCopy.Assigned_To_gne__c + ', ' + strAssignedUserRole + ', ' + (String)referralAssignmentCopy.Status_Referral_gne__c + ';';
				}
				
				//If status changed than put the status in Referral history
				if(selectedStatus != null && selectedStatus != (String)referralAssignmentCopy.Status_Referral_gne__c){
					referralAssignment.Status_Referral_gne__c = selectedStatus;
					referralAssignment.Status_Referral_Date_gne__c = datetime.now();
					blnIsReferralAssignmentUpdated = true;
					blnIsReferralUpdated = true;
					blnIsStatusChanged = true;
					refHistory = refHistory + datetime.now().format(GNE_Referral_Utils.strPSTFormat,GNE_Referral_Utils.strPST) + ', ' + GNE_Referral_Utils.strStatusUpdate +  ', ' + UserInfo.getName() + ', ' + strAssignedUserName + ', ' + (String)referralAssignmentCopy.Assigned_To_gne__c + ', ' + strAssignedUserRole + ', ' + selectedStatus + ';';
				}
				
				//User attempts to manually saved a linked Referral as 'Fulfilled'
				if(blnIsStatusChanged && selectedStatus == GNE_Referral_Utils.strFulfilled && referralAssignment.Call2_vod__c !=null){
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.GNE_SFA2_Referral_Validation_Fulfilled));
					GNE_Referral_Utils.isMedicalReferral = false;
					return null;	
				}
				//User attempts to manually saved a linked Referral as 'Fulfilled and Med Comm'
				if(blnIsStatusChanged && selectedStatus == GNE_Referral_Utils.strFulfilledMedComm && referralAssignment.Call2_vod__c !=null){
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.GNE_SFA2_Referral_Validation_FulfilledMedComm));
					GNE_Referral_Utils.isMedicalReferral = false;
					return null;	
				}
				
				//Any MSL in the chain can verify. This naturally means that the asignee can reassign to another without verifying but only after acknowledging.
				if(isVerified()){
					if(!isStatusAndAssignedToChanged()){
						if(searchId != null && (String)searchId != (String)referralAssignmentCopy.Assigned_To_gne__c){                      
							//Manual Assignment on edit                     
							User assignedUser = GNE_Referral_Utils.getCurrentUser(searchId);
							if(assignedUser != null){
								GNE_Referral_Utils.loadUserProfileType(assignedUser);
								if(GNE_Referral_Utils.isMCL || GNE_Referral_Utils.isMSL){
									searchId = GNE_Referral_Utils.getManualAssigned(assignedUser.Id,dueDate);
									if(searchId == null){
										isReAssigned = false;
										lstAssignmentErrors.add((String)assignedUser.name + ' is not available, please asign to someone else.');
									}else{
										isReAssigned = true;                                
									}
								}else if(GNE_Referral_Utils.isManager){
									if(GNE_Referral_Utils.isOnVacation(assignedUser.Id,dueDate)){
										isReAssigned = false;
										lstAssignmentErrors.add((String)assignedUser.name + ' is out of office, please asign to someone else.');
									}else{
										isReAssigned = true;
										searchId = assignedUser.Id;
									}
								}else{
									isReAssigned = false;
									lstAssignmentErrors.add('Referral can not be assigned to non-MedAffair user, please asign to MedAffair user.');
								}
							}else{
								isReAssigned = false;
								lstAssignmentErrors.add('Referral can not be assigned to inactive user, please asign to someone else.');
							}
							if(isReAssigned){
								strAssignedUserNameRole = GNE_Referral_Utils.getUserNameAndRole((String)searchId);
								
								if(strAssignedUserNameRole != ''){                              
									String[] lstUserNameAndRole = strAssignedUserNameRole.split(',',2);
									if(lstUserNameAndRole.size() >0){
										strAssignedUserName =lstUserNameAndRole[0];
										strAssignedUserRole =lstUserNameAndRole[1];                     
									}
								}
								blnIsReferralAssignmentUpdated=true;
								blnIsReferralUpdated=true;
								refHistory = refHistory + datetime.now().format(GNE_Referral_Utils.strPSTFormat,GNE_Referral_Utils.strPST) + ', ' + GNE_Referral_Utils.strReassigned +  ', ' + UserInfo.getName() + ', ' + strAssignedUserName + ', ' + (String)searchId + ', ' + strAssignedUserRole + ', ' + GNE_Referral_Utils.strAssigned + ';';
							}else{
								if(lstAssignmentErrors.size() >0){
									for (String strErrMsg : lstAssignmentErrors){
										ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,strErrMsg));
									}
									Database.rollback(sp1);
									GNE_Referral_Utils.isMedicalReferral = false;
									return null;
								}
							}
						}
						if(isReAssigned){
							//mslQueueId = GNE_Referral_Utils.getMSLQueueId(GNE_Referral_Utils.ReferralReassignedQueueName);
							Map<String, User> mapUserId = GNE_Referral_Utils.getAssignedManagerUser(searchId);
							User finalAssignedUser = new User();
							User assignedUserManager = new User();
							
							if(mapUserId != null && mapUserId.size()>0){
								if(mapUserId.containsKey('ManagerId')){
									assignedUserManager = mapUserId.get('ManagerId');
								}
								if(mapUserId.containsKey('UserId')){
									finalAssignedUser = mapUserId.get('UserId');
								}                               
							}
							referralAssignment.OwnerId = searchId;
							referralAssignment.Assigned_To_gne__c=searchId;                         
							referralAssignment.Referral_Assigned_User_Email_gne__c=finalAssignedUser.Email;                         
							referralAssignment.Due_Date_gne__c=dueDate;
							referralAssignment.Status_Referral_gne__c = GNE_Referral_Utils.strAssigned;
							referralAssignment.Status_Referral_Date_gne__c = datetime.now();
							referralAssignment.Revised_Requested_Completion_Date_gne__c = null;
							referralAssignment.Status_Email_gne__c = null;
							referralAssignment.Status_Email_Date_gne__c = null;
							referralAssignment.Escalation_Status_gne__c = false;
							
							if(assignedUserManager != null){
								referralAssignment.Assigned_To_Manager_gne__c=assignedUserManager.Id;
								referralAssignment.Referral_Assigned_Manager_Email_gne__c=assignedUserManager.Email;                                
							}else{
								referralAssignment.Assigned_To_Manager_gne__c=null;
								referralAssignment.Referral_Assigned_Manager_Email_gne__c=null;
							}
							blnIsReferralUpdated=true;
							blnIsReferralAssignmentUpdated=true;
						}
						if(blnIsReferralUpdated){
							objReferral.Referral_History_gne__c=refHistory;
							update objReferral;
						}
						if(blnIsReferralAssignmentUpdated){
							update referralAssignment;
						}
						if(isRequestVerified && !GNE_Referral_Utils.isMCLorMSL(currentUser) && !GNE_Referral_Utils.isUSCSUser() && GNE_Referral_Utils.sendReferralEmail(referralAssignment,objReferral, GNE_Referral_Utils.strRequestVerified)){
							referralAssignment.Status_Email_gne__c = GNE_Referral_Utils.strStatusUnsolicitedRequestVerifiedEmail;
							referralAssignment.Status_Email_Date_gne__c = datetime.now();
							blnIsReferralAssignmentUpdated=true;
						}
						
						if(blnIsStatusChanged && GNE_Referral_Utils.sendReferralEmail(referralAssignment, objReferral, selectedStatus)){
							referralAssignment.Status_Email_gne__c = GNE_Referral_Utils.getStatusEmail(referralAssignment.Status_Referral_gne__c);
							referralAssignment.Status_Email_Date_gne__c = datetime.now();
							blnIsReferralAssignmentUpdated=true;
						}
						
						if(blnIsReferralAssignmentUpdated){
							update referralAssignment;
						}
						
						if(isReAssigned){
							if(GNE_Referral_Utils.sendReferralEmail(referralAssignment, objReferral, GNE_Referral_Utils.strReassigned)){
								referralAssignment.Status_Email_gne__c = GNE_Referral_Utils.getStatusEmail(GNE_Referral_Utils.strAssigned);
								referralAssignment.Status_Email_Date_gne__c = datetime.now();
								update referralAssignment;
							}
						}
						referralAssignmentCopy = referralAssignment;
					}else{
						ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'You cannot reassign and close the referral at the same time. Either close or reasign the referral.'));
						Database.rollback(sp1);
						GNE_Referral_Utils.isMedicalReferral = false;
						return null;
					}
				}else{
					ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Unsolicited Request Verified must be checked to close a Referral.'));
					Database.rollback(sp1);
					GNE_Referral_Utils.isMedicalReferral = false;
					return null;
				}
			}catch (Exception e) {
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error on the page:' + e));
				Database.rollback(sp1);
				GNE_Referral_Utils.isMedicalReferral = false;
				return null;
			}
		}
		GNE_Referral_Utils.isMedicalReferral = false;
		try{
			if(referralAssignment.call2_vod__c != null){
				processLinkedInteraction(referralAssignment.Status_Referral_gne__c, referralAssignment.call2_vod__c, isReAssigned);
			}
		}catch(Exception e){
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
			Database.rollback(sp1);
			GNE_Referral_Utils.isMedicalReferral = false;
			return null;
		}
		PageReference p = new PageReference('/'+ referralAssignment.Id); 
		return p;
	}

	public class ReferralAssignmentWrapper{
		public String strDateTime {get;set;}
		public String strAction {get;set;}
		public String strActionBy {get;set;}
		public String strAssignedToId {get;set;}
		public String strAssignedToRole {get;set;}
		public String strStatus {get;set;}
		
		public ReferralAssignmentWrapper(String dt, String act, String actBy,String assignedTo, String role, String status){      
			strDateTime = dt;
			strAction = act;
			strActionBy = actBy;
			strAssignedToId = assignedTo;
			strAssignedToRole = role;
			strStatus = status;
		}
	}

	private void loadRefHistory(){
		String strDateTime='';
		String strAction='';
		String strActionBy='';
		String strAssignedToId='';
		String strAssignedToRole='';
		String strStatus='';
		
		refHistory = new List<ReferralAssignmentWrapper>();
		
		if(objReferral != null && String.isNotEmpty(objReferral.Referral_History_gne__c)){
			String refHistoryRecords=(String)objReferral.Referral_History_gne__c;
			for (String refHist : refHistoryRecords.split(';')) {
				String[] lstSepRefAssRec = refHist.split(',');
				System.debug('lstSepRefAssRec: ' + lstSepRefAssRec);
				
				if (lstSepRefAssRec[0] != null){
					strDateTime = lstSepRefAssRec[0];
				}
				if (lstSepRefAssRec[1] != null){
					strAction = lstSepRefAssRec[1];
				}
				if (lstSepRefAssRec[2] != null){
					strActionBy = lstSepRefAssRec[2];
				}
				if (lstSepRefAssRec[3] != null){
					strAssignedToId = lstSepRefAssRec[3];
				}
				if (lstSepRefAssRec.size() > 5 && lstSepRefAssRec[5] != null){
					strAssignedToRole = lstSepRefAssRec[5];
				}
				if (lstSepRefAssRec.size() > 6 && lstSepRefAssRec[6] != null){
					strStatus = lstSepRefAssRec[6];
				}
				refHistory.add(new ReferralAssignmentWrapper(strDateTime, strAction, strActionBy, strAssignedToId, strAssignedToRole, strStatus));
			}
		}
	}

	public class ReferralCommentsWrapper{
		public String strActionBy {get;set;}
		public String strAction {get;set;}    
		
		public ReferralCommentsWrapper(String actBy, String act){
			strActionBy = actBy;
			strAction = act;    
		}
	}

	private void loadRefComments(){
		String strActionBy='';
		String strAction='';
		refComments = new List<ReferralCommentsWrapper>();

		if(objReferral != null && objReferral.Comments_Referral_gne__c != null && (String)objReferral.Comments_Referral_gne__c !='' ){
			String refCommentRecords=(String)objReferral.Comments_Referral_gne__c;
			String[] lstRefCommRecs = refCommentRecords.split(',#,');
			String[] lstSepRefCommRec = new List<String> ();

			for (String refComm : lstRefCommRecs) {
				if(lstSepRefCommRec.size() >0){
					lstSepRefCommRec.clear();
				}
				lstSepRefCommRec = refComm.split(',@,');
				if (lstSepRefCommRec[0] != null){
					strActionBy = lstSepRefCommRec[0];
				}
				if(lstSepRefCommRec.size() >1){
					if (lstSepRefCommRec[1] != null){
						strAction = lstSepRefCommRec[1];
					}
				}
				refComments.add(new ReferralCommentsWrapper(strActionBy, strAction));
			}
		}
	}
	
	/*SFA-428*/
	public PageReference createLinkedInteraction(){
		PageReference pr = Page.GNE_SFA2_Interaction;
		pr.setRedirect(true);		
		pr.getParameters().put('referralId', referralAssignment.Id);
		return pr;
	}
	
	/* BR-004 - Referral status marked "Closed – HCP Unresponsive": Interaction record canceled. 
	   BR-005 Referral status marked "Closed – Not Verifiable": Interaction record canceled.
	   BR-015 - Reassign Referral – delete linked Interaction
	*/
	public static void processLinkedInteraction(String referralStatus, Id callId, Boolean isReAssigned){
		if(referralStatus == GNE_Referral_Utils.strClosedHCPUnresponsive || referralStatus == GNE_Referral_Utils.strClosedNotVerifiable || referralStatus == GNE_Referral_Utils.strClosedDuplicate || isReAssigned){
			Call2_vod__c call = new Call2_vod__c(Id = callId);
			delete call;
		}
	}
	
	public Boolean getIsLinkedInteractionButtonEnabled(){
		if(referralAssignment != null && referralAssignment.Status_Referral_gne__c == GNE_Referral_Utils.strAcknowledged && referralAssignment.call2_vod__c == null){
			return true;
		}
		return false;
	}
}