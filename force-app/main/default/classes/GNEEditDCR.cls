public without sharing class GNEEditDCR {
    
    public List<MergeBundle> mergeBundles {get; private set;}
    public Boolean isFrmDataSteward {get; private set;}
    
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
    
    public PageReference cancelAction() {
        String redirParam = ApexPages.currentPage().getParameters().get('backMode');
        String redirUrl = redirParam == 'portal' ? '/apex/GNE_FRM_DCR_Portal': '/apex/GNE_FRM_DCR_Layout?id='+changeRequest.Id;
        PageReference pr = new PageReference(redirUrl);
        pr.setRedirect(true);
        return pr;
    }
    
    public PageReference cancelForCRM() {
        String redirParam = ApexPages.currentPage().getParameters().get('backMode');
        String redirUrl = redirParam == 'cmrDcr' ? '/apex/GNE_CRM_DCR': '/apex/GNEViewDCR?id='+changeRequest.Id;
        PageReference pr = new PageReference(redirUrl);
        pr.setRedirect(true);
        return pr;    
    }
    
    public Change_Request_gne__c changeRequest;
    
    public enum ViewUserType {Requestor, RequestDataAnalyst, VendorDataAnalyst} 

    public ViewUserType userType = ViewUserType.RequestDataAnalyst;
    
    public Boolean getRequestor() {
        return userType == ViewUserType.Requestor;  
    }

    public Boolean getVendorDataAnalyst() {
        return userType == ViewUserType.VendorDataAnalyst;  
    }

    public Boolean getRequestDataAnalyst() {
        return userType == ViewUserType.RequestDataAnalyst;  
    }
    
    public Change_Request_gne__c getChangeRequest() {
        return changeRequest;   
    }
    
    public Boolean getIsOpen() {
        return GNE_SFA2_DCR_Util.isOpen(changeRequest);   
    }
    
    public Boolean editPage {get; set;}
    
    public GNEEditDCR (ApexPages.StandardController stdController) {
        changeRequest = GNE_SFA2_DCR_Util.getDCR((Id)stdController.getRecord().get('Id'));
        Id userId = UserInfo.getUserId();
        isFrmDataSteward = GNE_SFA2_Util.isFrmDataSteward(userId);
        
        if(changeRequest.createdById == userId){ 
            userType = ViewUserType.Requestor;
            if (changeRequest.status_gne__c == 'Need Info' || changeRequest.status_gne__c == 'Ready to Close'){
            	editPage = true;
            }
        }else if (ChangeRequestControllerHelper.isVendor(userId) && changeRequest.status_gne__c == 'Ready for Data Vendor'){
            userType = ViewUserType.VendorDataAnalyst;
            editPage = true;
        }
        
        if(isFrmDataSteward){
        	userType = ViewUserType.RequestDataAnalyst;
        }
        if(userType == ViewUserType.RequestDataAnalyst  && changeRequest.assigned_analyst_gne__c == null && (ApexPages.currentPage().getURL().toLowerCase().contains(Page.GNEEditDCR.getUrl().toLowerCase()) || ApexPages.currentPage().getUrl().toLowerCase().contains(Page.GNE_FRM_DCR_Edit.getUrl().toLowerCase()))){
        	changeRequest.assigned_analyst_gne__c =  userId;
        }
        
        mergeBundles = getMergeBundles(changeRequest);
    }
    
    public PageReference updateDCR() {

        PageReference pageRef = null;

        try {            
            if (changeRequest != null) {
            	Account_Group_gne__c accountGroup = getAccountGroup(changeRequest.Account_Group_gne__c);
            	
            	if(GNE_SFA2_DCR_Util.isApprovedForParentUpdate(changeRequest) && isProcessedByMerge()){
            		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.FRM_Datasteward_Merge_Info));
            		return null;
            	}
            	if(GNE_SFA2_DCR_Util.isApprovedForParentUpdate(changeRequest) && String.isNotBlank(changeRequest.Account_Group_gne__c) && accountGroup == null){
            		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.FRM_Datasteward_Account_Group_Info));
            		return null;
            	}
            	if(String.isBlank(changeRequest.Account_Group_gne__c)){
            		changeRequest.Account_Group_ref_gne__c = null;
            	} else if (accountGroup != null) {
            		changeRequest.Account_Group_ref_gne__c = accountGroup.Id;
            	}
                update changeRequest;
				if(ApexPages.currentPage().getUrl().toLowerCase().contains(Page.GNE_FRM_DCR_Edit.getUrl().toLowerCase())){
					pageRef = Page.GNE_FRM_DCR_Portal;
                    pageRef.setRedirect(true);
				}else if ( getRequestor() ) {
                    pageRef = (new ApexPages.StandardController(changeRequest)).view();
                    pageRef.setRedirect(true);
                } else {
                    String retURL = ApexPages.currentPage().getParameters().get('retURL');
                    if ( retURL != null ) {
                        pageRef = new PageReference ( retURL );
                        pageRef.setRedirect(true);                          
                    } else { 
                        String changeRequestPrefix = Schema.SObjectType.Change_Request_gne__c.getKeyPrefix();
                        pageRef = new PageReference ('/' + changeRequestPrefix );
                        pageRef.setRedirect(true);
                    }                           
                }
            }
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }            
        return pageRef;
    }

    public List<SelectOption> getAvailableDataStewards() {
    	return GNE_SFA2_Util.getAvailableFrmDataStewards();
    }
    
    private Boolean isProcessedByMerge(){
    	return !mergeBundles.isEmpty();
    }
    
    private Account_Group_gne__c getAccountGroup(String groupName){
    	if(String.isNotBlank(changeRequest.Account_Group_gne__c)) {
    		List<Account_Group_gne__c> groups = [SELECT id FROM Account_Group_gne__c WHERE name = :groupName limit 1];
    		if(!groups.isEmpty()){
		    	return groups.get(0);
    		}
    	}
		return null;    			
    }
    
    private List<MergeBundle> getMergeBundles(Change_Request_gne__c dcr){
    	Map<Id, MergeBundle> result = new Map<Id, MergeBundle>();
    	if(dcr != null){
    		for(DST_Match_Loser__c looser : [SELECT Id, Name, Mdm_Bundle_Status__c FROM DST_Match_Loser__c WHERE Is_Open_gne__c = true AND Match_Loser_Account_SfdcId__c = :dcr.Account_gne__c]){
    			if(!result.containsKey(looser.Id)){
    				result.put(looser.Id, new MergeBundle(looser.Id, looser.Name, looser.Mdm_Bundle_Status__c));
    			}
    		}
    		
    		for(DST_Match_Winner__c winner : [SELECT Id, Match_Loser__c, Match_Loser__r.Name, Match_Loser__r.Mdm_Bundle_Status__c FROM DST_Match_Winner__c WHERE Match_Loser__r.Is_Open_gne__c = true AND Match_Winner_SfdcId__c = :dcr.Account_gne__c]){
    			if(!result.containsKey(winner.Match_Loser__c)){
    				result.put(winner.Match_Loser__c, new MergeBundle(winner.Match_Loser__c, winner.Match_Loser__r.Name, winner.Match_Loser__r.Mdm_Bundle_Status__c));
    			}
    		}

    	}
    	return result.values();
    }
    
    class MergeBundle{
    	public Id id {get; private set;}
    	public String name {get; private set;}
    	public String status {get; private set;}
    	
    	public MergeBundle(Id Id, String name, String status){
    		this.id = id;
    		this.name = name;
    		this.status = status;
    	}
    }

    public PageReference editDCR(){
        PageReference pageRef = Page.GNE_FRM_DCR_Edit;  
        pageRef.getParameters().put('id', changeRequest.Id);  
        pageRef.setRedirect(true);
        return pageRef;  
    }    
    
    public PageReference editPageLayout(){
    	if (isFrmDataSteward && !GNE_SFA2_DCR_Util.isOpen(changeRequest)) {
    		PageReference pr = Page.GNE_FRM_DCR_Layout;
    		pr.getParameters().put('id', changeRequest.Id);
	        pr.setRedirect(true);
	        return pr;
    	}
        if(isFrmDataSteward || changeRequest.RecordType.DeveloperName.startsWith('HCO') || changeRequest.RecordType.DeveloperName.startsWith('HCP') || changeRequest.RecordType.DeveloperName.startsWith('Duplicate_Address')){ 
        	return null;
        }                  
        // backward compability of existing DCRs records 
        // use old page layout with embedded javascript   
        PageReference pageRef = new PageReference('/' + changeRequest.Id + '/e');  
        pageRef.getParameters().put('nooverride', '1');  
        pageRef.getParameters().put('id', changeRequest.Id);  
        pageRef.setRedirect(true);
        return pageRef;  
    }
    
    public Boolean getHasCanadaProfile(){
        return GNE_SFA2_Util.isCanadaUser();
    }
    
    //get list of available statues via Custom Setting 
    public List<SelectOption> statuses {
        get {
            List<SelectOption> options;
            if(statuses == null){
                statuses = new List<SelectOption>();
                
                Map <String, GNE_SFA_Canada_DCR_Statuses__c> statusesMap = GNE_SFA_Canada_DCR_Statuses__c.getAll();
                if(statusesMap != null && statusesMap.size() > 0){
                	Set<String>uniqueValues = new Set<String>();
                    for (GNE_SFA_Canada_DCR_Statuses__c row : statusesMap.values()){
                    	if(uniqueValues.add(row.Name)){
                        	options.add(new SelectOption(row.Name, row.Name));
                    	}                            
                    }
                    statuses = options;
                }
            }
            return statuses;    
        } set;
    }
    
    public String getAccount1Info() {
        return getAccountDuplicateInfo(changeRequest.Account_gne__c); 
    }

    public String getAccount2Info() {
        return getAccountDuplicateInfo(changeRequest.Duplicate_Account_2_gne__c);              
    }

    public String getAccount3Info() {
        return getAccountDuplicateInfo(changeRequest.Duplicate_Account_3_gne__c);              
    }

    public String getAccount4Info() {
        return getAccountDuplicateInfo(changeRequest.Duplicate_Account_4_gne__c);              
    }

    public String getAccount5Info() {
        return getAccountDuplicateInfo(changeRequest.Duplicate_Account_5_gne__c);              
    }
    
    private String getAccountDuplicateInfo (Id id) {    
        String acctInfo = '';        
        try {
            if ( id != null) {          
                Account acct = [select id, MDMID_gne__c from Account where id =: id ];            
                acctInfo = acct.MDMID_gne__c;                             
            }
        } catch (Exception e) {
            System.debug ( e.getMessage());
        }
        return acctInfo;            
    }
    
    public static List<SelectOption> getOrganizationTypes() {
    	String profileName = GNE_SFA2_Util.getCurrentUserProfileName();
    	//for users with permission set load records like for frm users
    	if(GNE_SFA2_Util.isFrmDataSteward(UserInfo.getUserId())){
    		profileName = 'GNE-MCCO-FRM-Support';
    	}
    	List<SelectOption> orgTypeList = GNE_SFA2_AccountDCRController.getOrgTypesList(profileName);
        if(orgTypeList[0].getValue() == GNE_SFA2_AccountDCRController.NONE_SELECTED){
            orgTypeList.remove(0);
        }
        return orgTypeList;
    }
   
    // USPS Address Validation Logic 
    @RemoteAction
    public static String addressValidate(Map<String, String> params) {
        return GNE_SFA2_USPSEngine.addressValidate(params);
    }

    @RemoteAction
    public static String cityStateLookup(Map<String, String> params) {
        return GNE_SFA2_USPSEngine.cityStateLookup(params);
    }

    @RemoteAction
    public static String zipCodeLookup(Map<String, String> params) {
        return GNE_SFA2_USPSEngine.zipCodeLookup(params);
    }
    
    public List<GNE_SFA2_List_View_Util.History> getHistories() {
    	List<Change_Request_gne__History> history = [SELECT ParentId, OldValue, NewValue, IsDeleted, Id, Field, CreatedDate, CreatedById, CreatedBy.Name
										            FROM Change_Request_gne__History
										            WHERE ParentId =: changeRequest.Id
										            ORDER BY CreatedDate DESC];
    	return GNE_SFA2_List_View_Util.getHistories(history, 'Change_Request_gne__c');
    }
    
    public Boolean isFrmHcoDcr(Change_Request_gne__c changeRequest) {
		return changeRequest.Account_gne__c != null && changeRequest.Account_gne__r.RecordType.DeveloperName == GNE_SFA2_Account_Trigger_Helper.REC_TYPE_FRM_HCO;
	}
	
	public Boolean getIsFrmHcoDcr() {
		return isFrmHcoDcr(changeRequest);
	}
	
	public Id getFrmRecordTypeId() {
		return GNE_SFA2_Util.getFrmHcoAccountRecordTypeId();
	}
}