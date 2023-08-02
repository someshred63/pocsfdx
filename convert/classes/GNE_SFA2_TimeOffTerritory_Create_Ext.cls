public with sharing class GNE_SFA2_TimeOffTerritory_Create_Ext extends GNE_Base_Controller {
	//------------------------------
	// Author:      Liz Ichihashi
	// Date:        10/07/2010  
	// Description: 
	//    This controller is used by the GNE_TimeOffTerritory page 
	//    Which is the New button override for Time_Off_Territory_gne__c.
	//    This page/controller combination is a re-factored version of TimeOffTerritory scontrol
	//    With new logic for Primary care users.
	//
	// Change History:
	// Duplicted for Force.com project // 2013-02-19
	// kozminsl - SFA-428 // 2013-10-31
	//------------------------------
	public Time_Off_Territory_gne__c tot {get; set;}
	public Time_off_Territory_Day_gne__c from_totd {get; set;}
	public Time_off_Territory_Day_gne__c to_totd {get; set;}
	public String profileName {get; set;} 
	public String retUrl;
	private SFA2_Configuration_Object_gne__c pageConfiguration;
	
	public String assignedReferralSearchId { get; set;}
	public String assignedUserLookupFilter {
		get {
			return 'Profile_name_gne__c IN (\'GNE-MedAffairs-MSL\',\'GNE-MedAffairs-MSL-Manager\') And isActive = true And Id <> \'' + UserInfo.getUserId() + '\''; 
		}
		set;
	}    
	public String enableReferralAssignment {get; set;}
	public List<SelectOption>enableReferralAssignmentOptions {get;	private set;}
	
	public GNE_SFA2_TimeOffTerritory_Create_Ext(ApexPages.StandardController controller){
		this.tot = (Time_Off_Territory_gne__c)controller.getRecord();
		init();      
	}  

	public GNE_SFA2_TimeOffTerritory_Create_Ext(){
		init();      
	}  

	public void init(){
		pageConfiguration = GNE_SFA2_Util.getListPageConfiguration('Time_Off_Territory_gne__c');
		from_totd = new Time_off_Territory_Day_gne__c();
		from_totd.Hours_Off_Territory__c = '8';
		to_totd = new Time_off_Territory_Day_gne__c();
		from_totd.Hours_Off_Territory__c = '8';

		// Get user data for profile name
		List <User> userList = [Select id, Profile_Name_gne__c From User where id = :UserInfo.getUserId()];
		if (userList.size() > 0){
			profileName = userList[0].Profile_Name_gne__c;
		}
		enableReferralAssignmentOptions = new List<SelectOption>{new SelectOption('','--None--'), new SelectOption('Yes','Yes'), new SelectOption('No','No')};
	}  

	public PageReference cancel(){
		// Return to Time off Territoty list page      
		retUrl = ApexPages.currentPage().getParameters().get('retURL');
		if (retUrl == null){
			 retUrl = '/apex/GNE_SFA2_MyAccounts';
		}
		PageReference totListPage = new PageReference(retUrl);
		totListPage.setRedirect(true);
		return totListPage;
	}
	
	public PageReference createTOT(){
		try{
			if (!validate()){
				return null;
			}
			if(getIsMSLProfile() && enableReferralAssignment=='Yes') {
				tot.Assigned_Referral_Activity_gne__c = assignedReferralSearchId;
			}
			
			// Save Time of Territory record
			tot.Approval_Status_gne__c = 'Pending';
			if (profileName.contains('MCCO')){
				tot.Description_gne__c = from_totd.Reason_MCCO_gne__c;
			} else if (profileName.contains('Primary-Care')){
				tot.Description_gne__c = from_totd.Reason_PC_gne__c;
			}else if (profileName.contains('MedAffairs')){
				tot.Description_gne__c = from_totd.Reason_MedAffair_gne__c;
			} else{
				tot.Description_gne__c = from_totd.Reason_SFA_gne__c;
			}
			insert tot;
			
			// Save Time of Territory Days record (or records, if date range)       
			List<Actual_Working_Days_gne__c> awdList = [SELECT Date_gne__c, Id FROM Actual_Working_Days_gne__c WHERE Date_gne__c >= :from_totd.Date_gne__c AND Date_gne__c <= :to_totd.Date_gne__c];
			List<Time_Off_Territory_Day_gne__c> totdList = new List<Time_Off_Territory_Day_gne__c>();        
			
			for(Actual_Working_Days_gne__c awd :awdList){
				Time_Off_Territory_Day_gne__c t = new Time_Off_Territory_Day_gne__c();
				t.Date_gne__c = awd.Date_gne__c;
				t.Time_Off_Territory_gne__c = tot.id;
				t.Hours_Off_Territory__c = from_totd.Hours_Off_Territory__c;
				t.Reason_PC_gne__c = from_totd.Reason_PC_gne__c;
				t.Reason_SFA_gne__c = from_totd.Reason_SFA_gne__c;
				t.Reason_MCCO_gne__c = from_totd.Reason_MCCO_gne__c;
				totdList.add(t);
			}
			insert totdList;
			
			// Return to Time of Territoty detail page        
			PageReference totPage = new ApexPages.StandardController(tot).view();
			totPage.setRedirect(true);
			totPage.getParameters().put('retUrl','/apex/GNE_SFA2_Time_Off_Territory');
			return totPage;
		} catch (Exception e){
			handleError('GNE_TimeOffTerritory_Controller', 'createTOT', e);
		}
		return null;        
	}
	
	public Boolean validate(){
		Boolean retVal = true;
		if (from_totd.Date_gne__c == null) {
			from_totd.Date_gne__c.addError('From Date is required');
			retVal = false;
		}
		if (to_totd.Date_gne__c == null) {
			to_totd.Date_gne__c.addError('To Date is required');
			retVal = false;
		}
		if(enableReferralAssignment == null && getIsMSLProfile()){
			tot.addError(System.Label.GNE_SFA2_ToT_Enable_Reassignment_Req);
			retVal = false;
		}
		
		if (retVal) {
			if (from_totd.Date_gne__c > to_totd.Date_gne__c) {
				to_totd.Date_gne__c.addError('Invalid date range. To Date cannot be prior to From Date');
				retVal = false;
			}
			
			if (retVal) {
				Integer from_year = from_totd.Date_gne__c.year();
				Integer to_year = to_totd.Date_gne__c.year();
				if (from_year != to_year) {
					to_totd.Date_gne__c.addError('Invalid date range.  You must create separate entries for a time period covering multiple years.');
					retVal = false;
				}
			}    
		}    
		
		if (retVal &&  getIsMSLProfile()) {
			if (getIsReferralAssignmentEnabled() && String.isBlank(assignedReferralSearchId)){
				tot.addError('Assign Referral Activity is required');
				retVal = false;
			} else if (getIsReferralAssignmentEnabled()){
				List<User> users = [SELECT Id FROM User WHERE Id <> :UserInfo.getUserId() AND Profile_name_gne__c LIKE 'GNE-MedAffairs-MSL%' AND isActive= true AND Id = :assignedReferralSearchId];              
				if (users.isEmpty()){
					tot.addError('No User found. Click Lookup icon at at \'Assign Referral Activity to\' Field to select appropriate user.');
					retVal = false;
				}
			} 
		}    
		return retVal;  
	}
	
	public void setReferralAssignmentFlag(){
	}
	
	public String getActiveMenuItem() {
		String result = '';
		if(pageConfiguration != null && pageConfiguration.Attributes_gne__c != null && pageConfiguration.Attributes_gne__c.contains('activeMenuItem')){
			result = pageConfiguration.Attributes_gne__c.substringBetween('activeMenuItem=',';');
		}
		return result;
	}
	
	public Boolean getIsMSLProfile() {
		return profileName.contains('GNE-MedAffairs-MSL');
	}
	
	public Boolean getIsReferralAssignmentEnabled(){
		return enableReferralAssignment == 'Yes'; 
	}
}