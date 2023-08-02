public class GNE_SFA2_PREP_Interaction_Controller {
	public Map<String,List<SelectOption>> productToMboMap {get; private set;}
	
	public Set<String> inactiveMbosIds {get; private set;}
	public Set<String> inactiveProdByStratIds {get; set;}
	public Map<String,String> mboShortDescriptionsMap {get; private set;}
	public Integer discussionIndex {get; set;}
	public String productMboParam {get; set;}
	public String selectedMboIds {get; set;}
	public Boolean isPrepAvailable {get; private set;}
	
	private Map<String, List<SelectOption>> productToActiveMboMap;
	private GNE_SFA2_Interaction_Controller mainController;	
	private Map<Id,Call_PREP_MBO_gne__c> existingCallMbos;
	
	public final String SELECT_ALL_MBOS_STR = '--Select All--';
	
	public GNE_SFA2_PREP_Interaction_Controller(GNE_SFA2_Interaction_Controller a_mainController) {
		mainController = a_mainController;
		isPrepAvailable = false;
	}
	
	public PageReference initController() {
		for(SFA2_Configuration_Object_gne__c co : mainController.callSectionsList) {
			if(mainController.callSectionsMap.containsKey(co.id)) {
				for(SFA2_Configuration_Object_Detail_gne__c cod : mainController.callSectionsMap.get(co.id)) {
					if(cod.API_Name_gne__c == String.valueOf(Call2_vod__c.PREP_Status_gne__c)) {
						isPrepAvailable = true;
						break;
					}
				}
			}
		}
		
		if(isPrepAvailable) {
			setAttendeeProfessionalType(mainController.attendees);
			
			if(!mainController.isCompleted) {
				List<Call2_vod__c> callAttendees = new List<Call2_vod__c>{mainController.call};
				
				for(GNE_SFA2_Interaction_Controller.AttendeeWrapper attendeeWrapper : mainController.attendees) {
					callAttendees.add(attendeeWrapper.attendee);
				}
				
				refreshPrepStatus(callAttendees);
			}
			
			setProductToMboMap();
			setSelectedMboIds();
			margeAvailableProducts();
		}
		
		return null;
	}
	
	private void margeAvailableProducts(){
		if (inactiveProdByStratIds != null && inactiveProdByStratIds.size() > 0){			
			if (mainController.availableProducts != null && mainController.availableProducts.size() > 0){
				List<SelectOption> availableProducts = new List<SelectOption>();
				for (SelectOption so : mainController.availableProducts){
					if (!inactiveProdByStratIds.contains(so.getValue())){
						availableProducts.add(so);						
					}
				}
				mainController.availableProducts.clear();
				mainController.availableProducts = availableProducts;
			}
			if (mainController.callDiscussionProducts != null && mainController.callDiscussionProducts.size() > 0){
				List<SelectOption> availableProducts = new List<SelectOption>();
				for (SelectOption so : mainController.callDiscussionProducts){
					if (!inactiveProdByStratIds.contains(so.getValue())){
						availableProducts.add(so);						
					}
				}
				mainController.callDiscussionProducts.clear();
				mainController.callDiscussionProducts = availableProducts;
			}
		}
	}
	
	private void setAttendeeProfessionalType(List<GNE_SFA2_Interaction_Controller.AttendeeWrapper> attedeeWrappers) {
		Set<Id> accIds = new Set<Id>();
			
		for(GNE_SFA2_Interaction_Controller.AttendeeWrapper attWrapper : attedeeWrappers) {
			if(String.isNotBlank(attWrapper.attendee.Account_vod__c)) {
				accIds.add(attWrapper.attendee.Account_vod__c);
			}
		}
		
		Map<Id,Account> accs = new Map<Id,Account>(GNE_SFA2_PREP_Util.getAccountsProfTypes(accIds));		
		for(GNE_SFA2_Interaction_Controller.AttendeeWrapper attWrapper : mainController.attendees) {
			String accId = attWrapper.attendee.Account_vod__c;
			if (String.isNotBlank(accId) && accs.containsKey(accId)){
				attWrapper.attendeeType = accs.get(accId).PREP_Professional_Type_gne__c;				
			}
		}
	}
	
	private Map<Id,String> getAccountsStatus(Set<Id> accIds) {
		Map<Id,String> result = new Map<Id,String>();
		Map<Id,Account> accs = new Map<Id,Account>(GNE_SFA2_PREP_Util.getAccountsWithStatus(accIds));
		
		for(Id accId : accIds) {
			Account acc = accs.containsKey(accId) ? accs.get(accId) : null;
			
			String status = (acc==null ? null : (String.isNotBlank(acc.PREP_Status_gne__c) ? acc.PREP_Status_gne__c : GNE_SFA2_PREP_Util.PREP_STATUS_RED));
			result.put(accId, status);
		}
		
		return result;
	}
	
	public PageReference affiliatedAccountSelected(Integer attIdx) {
		if(isPrepAvailable) {
			List<GNE_SFA2_Interaction_Controller.AttendeeWrapper> atts = new List<GNE_SFA2_Interaction_Controller.AttendeeWrapper>{mainController.attendees[attIdx]};
			setAttendeeProfessionalType(atts);
			
			if(!mainController.isCompleted) {
				refreshPrepStatus(atts);
			}
		}
		
		return null;
	}
	
	public PageReference addAttendees(Set<Integer> attIdxs) {
		if(isPrepAvailable) {
			List<GNE_SFA2_Interaction_Controller.AttendeeWrapper> attsToRefresh = new List<GNE_SFA2_Interaction_Controller.AttendeeWrapper>();
			
			for(Integer attIdx : attIdxs) {
				attsToRefresh.add(mainController.attendees[attIdx]);
			}
			
			setAttendeeProfessionalType(attsToRefresh);
			
			if (!mainController.isCompleted) {
				refreshPrepStatus(attsToRefresh);
			}
		}
		
		return null;
	}
	
	private void refreshPrepStatus(List<GNE_SFA2_Interaction_Controller.AttendeeWrapper> attedeeWrappers) {
		List<Call2_vod__c> callAttendees = new List<Call2_vod__c>();
		 
		for(GNE_SFA2_Interaction_Controller.AttendeeWrapper attendeeWrapper : attedeeWrappers) {
			callAttendees.add(attendeeWrapper.attendee);
		}
		
		refreshPrepStatus(callAttendees);
	}
	
	private void refreshPrepStatus(List<Call2_vod__c> callAttendees) {
		Set<Id> accIds = new Set<Id>();
		
		for(Call2_vod__c call : callAttendees) {
			
			if(String.isNotBlank(call.Account_vod__c)) {
				accIds.add(call.Account_vod__c);
			}
		}
		
		Map<Id,String> prepStatuses = getAccountsStatus(accIds);
		
		for(Call2_vod__c call : callAttendees) {
			call.PREP_Status_gne__c = String.isNotBlank(call.Account_vod__c) ? prepStatuses.get(call.Account_vod__c) : null;
		}
	}
	
	public void setProductToMboMap() {
		productToMboMap = new Map<String, List<SelectOption>>{
			null => new List<SelectOption>{new SelectOption('','--None--')},
			'' => new List<SelectOption>{new SelectOption('','--None--')}
		};
		inactiveMbosIds = new Set<String>();		
		inactiveProdByStratIds = new Set<String>();		
		productToActiveMboMap = productToMboMap.clone();		
		mboShortDescriptionsMap = new Map<String,String>{
			null => '',
			'' => ''
		};
		
		for(SFA2_PREP_Testing_Strategy_gne__c tStrategy : GNE_SFA2_PREP_Util.getAllTestingStrategiesWithMBOs()) {
			if(String.isNotBlank(tStrategy.Product_gne__c)) {
				String prodId = tStrategy.Product_gne__c;
				if(!productToMboMap.containsKey(prodId)) {
					productToMboMap.put(prodId, new List<SelectOption>{new SelectOption('','--None--')});
				}
				if(!productToActiveMboMap.containsKey(prodId)) {
					productToActiveMboMap.put(prodId, new List<SelectOption>{new SelectOption('','--None--')});
				}
				if (tStrategy.Active_for_Call_gne__c == false){
					inactiveProdByStratIds.add(tStrategy.Product_gne__c);
				}
				
				for(SFA2_PREP_MBO_gne__c mbo : tStrategy.MBOs_gne__r) {
					mboShortDescriptionsMap.put(mbo.Id, mbo.Short_Description_gne__c);
					productToMboMap.get(prodId).add(new SelectOption(mbo.Id, mbo.Short_Description_gne__c));					
					
					if(mbo.Active_for_Call_gne__c == false) {
						inactiveMbosIds.add(mbo.Id);
					} else {
						productToActiveMboMap.get(prodId).add(new SelectOption(mbo.Id, mbo.Short_Description_gne__c));
					}
				}
			}
		}
		
		// Fill MBO options for products without MBOs
		for(GNE_SFA2_Interaction_Controller.ProductDetailWrapper wrapper : mainController.callProducts) {
			String prodId = wrapper.callDetail.Product_vod__c;
            if(String.isNotBlank(prodId)) {
            	if (!productToMboMap.containsKey(prodId)){
            		productToMboMap.put(prodId, new List<SelectOption>{new SelectOption('','--None--')});
            	}
            	if (!productToActiveMboMap.containsKey(prodId)){
            		productToActiveMboMap.put(prodId, new List<SelectOption>{new SelectOption('','--None--')});
            	}
            }
        }
	}
	
	public void postPrepMboValue() {
        GNE_SFA2_Interaction_Controller.DiscussionWrapper wrapper = mainController.discussions.get(discussionIndex);
        if (productMboParam == this.SELECT_ALL_MBOS_STR){
        	discussionWrapperSelectAllMboForProduct(wrapper);
        } else {
        	wrapper.callDiscussion.PREP_MBO_gne__c = String.isNotBlank(productMboParam) ? productMboParam : null;
        }
    }
    
    public List<SelectOption> discussionWrapperGetMboSelectListForProduct(String productId, String mboAlreadySet){    	
    	List<SelectOption> result = (!inactiveProdByStratIds.contains(productId) && productToActiveMboMap != null && productToActiveMboMap.containsKey(productId)) ? productToActiveMboMap.get(productId).clone() : new List<SelectOption>{new SelectOption('', '--None--')};
    	
    	// Add mbo already set to the list - it can be inactive value
    	Boolean mboIncluded = false;
    	if (String.isNotBlank(mboAlreadySet)){
    		for (SelectOption so : result){
    			if (so.getValue() == mboAlreadySet){
    				mboIncluded = true;
    				break;
    			}
    		}
    		if (mboIncluded == false && mboShortDescriptionsMap.containsKey(mboAlreadySet)){
    			result.add(new SelectOption(mboAlreadySet, mboShortDescriptionsMap.get(mboAlreadySet)));
    		}
    	}
    	
    	if (!inactiveProdByStratIds.contains(productId)){    	
    		// Add Select All option to the list
    		if (discussionWrapperHasSelectAllMboOptionForWrapper(productId)){
           		if (result.size() >= 1 && String.isBlank(result.get(0).getValue())){
           			result.add(1, new SelectOption(this.SELECT_ALL_MBOS_STR, this.SELECT_ALL_MBOS_STR));
           		} else {
           			result.add(new SelectOption(this.SELECT_ALL_MBOS_STR, this.SELECT_ALL_MBOS_STR));
           		}
    		}
    	}
    	return result;
    }
    
    private Boolean discussionWrapperHasSelectAllMboOptionForWrapper(String productId){
    	Boolean result = false;
    	if (!productToActiveMboMap.containsKey(productId) || mainController.discussions == null || mainController.discussions.size() == 0){
    		return result;
    	}
    	Set<String> mboSelected = new Set<String>();
    	for (GNE_SFA2_Interaction_Controller.DiscussionWrapper wrapper : mainController.discussions){
    		if (wrapper.callDiscussion.Product_vod__c == productId && String.isNotBlank(wrapper.callDiscussion.PREP_MBO_gne__c) && !inactiveMbosIds.contains(wrapper.callDiscussion.PREP_MBO_gne__c)){
   				mboSelected.add(wrapper.callDiscussion.PREP_MBO_gne__c);
    		}
    	}
    	// -1 because of None value
    	Integer mbosForProductCount = productToActiveMboMap.get(productId).size();
    	mbosForProductCount--;    	
    	result = mbosForProductCount > 1 && (mboSelected.size() < mbosForProductCount);
    	return result;
    }
    
    public void discussionWrapperSelectAllMboForProduct(GNE_SFA2_Interaction_Controller.DiscussionWrapper wrapperTriggered){
    	String productId = wrapperTriggered.callDiscussion.Product_vod__c;
    	Set<String> selectedMbos = new Set<String>();
    	for (GNE_SFA2_Interaction_Controller.DiscussionWrapper wrapper : mainController.discussions){
    		if (wrapper.callDiscussion.Product_vod__c == productId && String.isNotBlank(wrapper.callDiscussion.PREP_MBO_gne__c)){
   				selectedMbos.add(wrapper.callDiscussion.PREP_MBO_gne__c);
    		}
    	}
    	
    	List<GNE_SFA2_Interaction_Controller.DiscussionWrapper> discussionsToAdd = new List<GNE_SFA2_Interaction_Controller.DiscussionWrapper>();
    	Integer discAdded = 0;
    	Boolean addNewWrapper;
    	for (SelectOption so : productToActiveMboMap.get(productId)){
    		if (String.isNotBlank(so.getValue()) && !selectedMbos.contains(so.getValue()) && so.getValue() != this.SELECT_ALL_MBOS_STR){
    			addNewWrapper = !(discAdded == 0 && String.isBlank(wrapperTriggered.callDiscussion.PREP_MBO_gne__c));
    			GNE_SFA2_Interaction_Controller.DiscussionWrapper discWrapper = addNewWrapper ? wrapperTriggered.cloneWrapper() : wrapperTriggered;
    			discWrapper.callDiscussion.Product_vod__c = productId;
    			discWrapper.callDiscussion.PREP_MBO_gne__c = so.getValue();
    			if (addNewWrapper){
    				discussionsToAdd.add(discWrapper);
    			}
    			discAdded++;
    		}
    	}
    	if (discussionsToAdd.size() > 0){
    		mainController.discussions.addAll(discussionsToAdd);    		
    		for (Integer i = 0; i < mainController.discussions.size(); i++){
    			mainController.discussions.get(i).index = i;
    		}
    	}
    }
    
    private void setSelectedMboIds() {
    	selectedMboIds = null;
    	existingCallMbos = new Map<Id,Call_PREP_MBO_gne__c>();
    	Set<String> existingCallMboDescs = new Set<String>();
    	
    	if(String.isNotBlank(mainController.call.Id)) {
    		existingCallMbos = GNE_SFA2_PREP_Util.getCallMbos(mainController.call.Id);
    		
    		for(Call_PREP_MBO_gne__c cMbo : existingCallMbos.values()) {
   				existingCallMboDescs.add(cMbo.Mbo_gne__r.Short_Description_gne__c);
    		}
    	}
    	
    	selectedMboIds = String.join(new List<Id>(existingCallMbos.keySet()),';');
    	
    	if(Apexpages.currentPage().getUrl().containsIgnoreCase('Layout')) {
    		List<String> existingCallMboDescsList = new List<String>(existingCallMboDescs);
    		existingCallMboDescsList.sort();
    		mainController.call.PREP_MBOs_gne__c = String.join(existingCallMboDescsList,'; ');
    	}
    }
    
    public PageReference save() {
    	if(isPrepAvailable) {
	    	Set<String> selectedIds = String.isNotBlank(selectedMboIds) ? new Set<String>(selectedMboIds.split(';')) : new Set<String>();
	    	GNE_SFA2_PREP_Util.manageCallMbos(mainController.call.Id, selectedIds, existingCallMbos);
    	}
    	
    	return null;
    }
    
    public static void onSearchAccountsContactsEmployees(List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper> result) {
    	if(GNE_SFA2_PREP_Util.isPrepUser((Id)UserInfo.getUserId())) {
	    	Set<Id> accIds = new Set<Id>();
	    	List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper> accountWrappers = new List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper>();
	    	for(GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper recWrapper : result) {	    		
	    		if(recWrapper.recordType == 'HCP' || recWrapper.recordType == 'HCO') {
	    			accIds.add(recWrapper.accountId);
	    			accountWrappers.add(recWrapper);
	    		}
	    	}
	    	
	    	if(!accIds.isEmpty()) {
	    		Map<Id,Account> accs = new Map<Id,Account>(GNE_SFA2_PREP_Util.getAccountsProfTypes(accIds));	    		
	    		for(GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper hcpWrapper : accountWrappers) {
	    			Account acc = accs.get(hcpWrapper.accountId);
	    			if (acc != null){	    				
	    				hcpWrapper.recordType = acc.PREP_Professional_Type_gne__c != null ? acc.PREP_Professional_Type_gne__c : '';
	    			}
	    		}
	    	}
    	}
    }
    
    public static void onGetAffiliatedAccounts(List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper> result) {
    	onSearchAccountsContactsEmployees(result);
    }
    
}