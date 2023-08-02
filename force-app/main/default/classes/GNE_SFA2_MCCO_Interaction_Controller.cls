public with sharing class GNE_SFA2_MCCO_Interaction_Controller {

    private GNE_SFA2_Interaction_Controller mainController;
	private final Id accountId;
	private final Id contactId;
	private final Id callId;
    public String interactionMethod {get;set;}
    public Account callAccount{get; private set;}

    // Multiple Accounts Interaction
    public List<InteractionWrapper> multipleAccountList {get;set;}
    public String interactionIndexToRemove {get;set;}
    public String selectedMultipleAccountsJSON {get;set;}
    public Boolean isMultipleInteraction {get;set;}
    public Map<Id,List<MultipleAccountsAttendeesWrapper>> multipleAccountsInteractionMap {get;set;}
    public List<MultipleAccountsAttendeesWrapper> multipleAccountsInteractionList {get;set;}
    public List<Id> multipleAccountsIds {get;set;}
    public Map<Id,String> accountsMap {get;set;}
    public String accountIdToAffil {get;set;}
    public Map<Id,Boolean> ifAffiliationsSelected {get;set;}

    // Email Method
    public String emailContent {get;set;}
    public String emailRecipients {get;set;}
    public String emailSubject {get;set;}
    public String availableContactsJSON {get;set;}

    // Attachments Method
    public String parentId {get;set;}
    public String temporaryCallId {get;set;}

    public GNE_SFA2_MCCO_Interaction_Controller(GNE_SFA2_Interaction_Controller a_mainController, String accountId, String contactId, String callId) {
		this.accountId = accountId;
		this.contactId = contactId;
		this.callId = callId;
		mainController = a_mainController;

		//parentId = getParentId();
		//prepareEmailSection(callId);
        multipleAccountList = getMultipleAccounts();

        if(!multipleAccountList.isEmpty()) {
            isMultipleInteraction = true;
            accountsMap = new Map<Id,String>();
            accountsMap = getAccountsName(multipleAccountList);
            multipleAccountsIds = getMultipleAccountsIds();
            ifAffiliationsSelected = prepareAffiliationsSelectedMap(multipleAccountsIds);
            accountIdToAffil = multipleAccountList.get(0).account.Id;
            multipleAccountsInteractionMap = new Map<Id,List<MultipleAccountsAttendeesWrapper>>();
            multipleAccountsInteractionMap = getAteendessToMultipleAccounts(multipleAccountsIds);
        } else {
            isMultipleInteraction = false;
        }

        availableContactsJSON = prepareAvalableContactsJSON();

        temporaryCallId = String.valueOf(System.now()).remove(':').remove(' ').remove('-') + Math.random();
		temporaryCallId = temporaryCallId.remove('0.');
	}

	public void removeTemporaryAttachments() {
        List<Attachment> attachmentsToRemove = [SELECT Id, ParentId FROM Attachment WHERE ParentId =: parentId AND Description =: temporaryCallId];
        delete attachmentsToRemove;
    }

	public PageReference removeCall(){
        Integer listIndex = -1;
        for(Integer i=0; i< multipleAccountList.size(); i++){
            if(Integer.valueOf(interactionIndexToRemove) == multipleAccountList.get(i).index){
                listIndex = i;
                break;
            }
        }
        if(multipleAccountList.get(listIndex).account.Id == accountIdToAffil) {
                if(listIndex == 0) {
                        accountIdToAffil = multipleAccountList.get(1).account.Id;
                } else {
                        accountIdToAffil = multipleAccountList.get(listIndex - 1).account.Id;
                }
        }

        if(listIndex > -1){
            multipleAccountList.remove(listIndex);
        }
        return null;
    }

    public PageReference addInteractions(){

        Set<String> selectedAccountIds = new Set<String>();
        for(InteractionWrapper mal : multipleAccountList) {
            selectedAccountIds.add(mal.account.id);
        }

        List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper>selectedAccounts = (List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper>) JSON.deserialize(selectedMultipleAccountsJSON, List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper>.class);
        List<Id>accountIds = new List<Id>();

        for(GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper wrapper: selectedAccounts){
                if(!wrapper.isContact && !selectedAccountIds.contains(wrapper.accountId)){
                    accountIds.add(wrapper.accountId);
                }
        }

        multipleAccountsInteractionMap = getAteendessToMultipleAccounts(accountIds);

        Map<Id, Account> accountsTempMap = new Map<Id, Account>([SELECT Id, IsPersonAccount, Territory_vod__c, Name,(SELECT Id, Name, City_vod__c FROM Address_vod__r WHERE Inactive_vod__c = false) FROM Account WHERE  id IN :accountIds]);

        Integer counter = multipleAccountList.size();
        for(GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper wrapper: selectedAccounts){
            if(!wrapper.isContact && !selectedAccountIds.contains(wrapper.accountId)){
                multipleAccountList.add(new InteractionWrapper(accountsTempMap.get(wrapper.accountId), accountsTempMap.get(wrapper.accountId).address_vod__r.get(0).Id, accountsTempMap.get(wrapper.accountId).address_vod__r, counter, null));
                ifAffiliationsSelected.put(wrapper.accountId, false);
            }
            counter++;
        }

        accountsMap = getAccountsName(multipleAccountList);
        return null;
    }

    public Map<Id,List<MultipleAccountsAttendeesWrapper>> getAteendessToMultipleAccounts(List<Id> accountsIds) {

        for(Affiliation_vod__c affiliation: [Select Id, Name, From_Account_vod__c, To_Account_Type_gne__c, To_Account_vod__c, To_Account_vod__r.Name, To_Account_vod__r.PersonEmail, To_Contact_vod__c, To_Contact_vod__r.Name, To_Contact_vod__r.Email from Affiliation_vod__c WHERE From_Account_vod__c =: accountsIds AND To_Contact_vod__r.Active_gne__c = true] ){
            /*
            if(affiliation.To_Account_vod__c!=null && !multipleAccountsInteractionMap.containsKey(affiliation.From_Account_vod__c)){
                multipleAccountsInteractionMap.put(affiliation.From_Account_vod__c, new List<MultipleAccountsAttendeesWrapper>());
                multipleAccountsInteractionMap.get(affiliation.From_Account_vod__c).add(new MultipleAccountsAttendeesWrapper(affiliation.To_Account_vod__c, affiliation.To_Account_vod__r.Name, affiliation.To_Account_vod__r.PersonEmail, false));
            } else if(affiliation.To_Account_vod__c!=null) {
                multipleAccountsInteractionMap.get(affiliation.From_Account_vod__c).add(new MultipleAccountsAttendeesWrapper(affiliation.To_Account_vod__c, affiliation.To_Account_vod__r.Name, affiliation.To_Account_vod__r.PersonEmail, false));
            }
            */
            if(affiliation.To_Contact_vod__c!=null && !multipleAccountsInteractionMap.containsKey(affiliation.From_Account_vod__c)){
                multipleAccountsInteractionMap.put(affiliation.From_Account_vod__c, new List<MultipleAccountsAttendeesWrapper>());
                multipleAccountsInteractionMap.get(affiliation.From_Account_vod__c).add(new MultipleAccountsAttendeesWrapper(affiliation.To_Contact_vod__c, affiliation.To_Contact_vod__r.Name, affiliation.To_Contact_vod__r.Email, false));
            } else if (affiliation.To_Contact_vod__c!=null){
                multipleAccountsInteractionMap.get(affiliation.From_Account_vod__c).add(new MultipleAccountsAttendeesWrapper(affiliation.To_Contact_vod__c, affiliation.To_Contact_vod__r.Name, affiliation.To_Contact_vod__r.Email, false));
            }
        }

        for(Id acct : accountsIds) {
            if(!multipleAccountsInteractionMap.containsKey(acct)){
                multipleAccountsInteractionMap.put(acct, new List<MultipleAccountsAttendeesWrapper>());
                multipleAccountsInteractionMap.get(acct).add(new MultipleAccountsAttendeesWrapper(null, 'No records to display.', null, false));
            }
        }

        return multipleAccountsInteractionMap;
    }

    public List<Id> getSelectedAttendees(String accountId) {
        List<Id> result = new List<Id>();
        for(MultipleAccountsAttendeesWrapper selAtt : multipleAccountsInteractionMap.get(accountId)) {
            if(selAtt.isChecked) {
                result.add(selAtt.Id);
            }
        }

        return result;
    }

    public class MultipleAccountsAttendeesWrapper {
        public Id id {get;set;}
        public String name {get;set;}
        public String email {get;set;}
        public Boolean isChecked {get;set;}

        public MultipleAccountsAttendeesWrapper(Id id, String name, String email, Boolean isChecked) {
                this.id = id;
                this.name = name;
                this.email = email;
                this.isChecked = isChecked;
        }

    }

    public class InteractionWrapper{
        public Account account {get;set;}
        public Id selectedAddress {get;set;}
        public List<SelectOption> addressesOptions {get;set;}
        public Integer index {get; set;}
        public String affiliations {get;set;}

        public InteractionWrapper(){

        }

        public InteractionWrapper(Account account, Id selectedAddress, List<Address_vod__c> addresses, Integer index, String affiliations){
            this.account = account;
            this.addressesOptions = new List<SelectOption>();

            for(Address_vod__c address: addresses){
                this.addressesOptions.add(new SelectOption(address.Id, address.Name));
            }
            if(addresses.size()==1){
                this.selectedAddress = addresses.get(0).id;
            } else {
                this.selectedAddress = selectedAddress;
            }

            this.index = index;
            this.affiliations = affiliations;
        }
    }

    public PageReference updateAffiliations() {
        List<MultipleAccountsAttendeesWrapper> affilList = multipleAccountsInteractionMap.get(accountIdToAffil);
        String selectedAffil = '';
        for(MultipleAccountsAttendeesWrapper interaction : affilList) {
            if(interaction.isChecked) {
                selectedAffil += interaction.Name + ', ';
            }
        }

        selectedAffil = selectedAffil.removeEnd(', ');

        for(InteractionWrapper call : multipleAccountList) {
            if(call.account.Id == accountIdToAffil && (selectedAffil != null && selectedAffil != '')) {
                call.affiliations = selectedAffil;
                ifAffiliationsSelected.put(call.account.Id,true);
            } else if(call.account.Id == accountIdToAffil && (selectedAffil == null || selectedAffil == '')){
                call.affiliations = selectedAffil;
                ifAffiliationsSelected.put(call.account.Id,false);
            }
        }

        return null;
    }

    public List<InteractionWrapper> getMultipleAccounts() {

        List<InteractionWrapper> result = new List<InteractionWrapper>();
        if(ApexPages.currentPage().getParameters().get('selectedAccountIds') != null){
            List<String> ids = ApexPages.currentPage().getParameters().get('selectedAccountIds').split(',');
            Integer counter = 0;
            if(!ids.isEmpty()) {
                for(Account account: [SELECT Id, Name, IsPersonAccount,(SELECT Id, Name, City_vod__c, PFG_BDTD_gne__c FROM Address_vod__r where Inactive_vod__c = false and Primary_vod__c = true) FROM Account WHERE id IN :ids ORDER BY Name]){
                    result.add(new InteractionWrapper(account, account.address_vod__r.get(0).Id, account.address_vod__r, counter, null));
                    counter++;
                }
            }
        }

        return result;
    }

    public List<Id> getMultipleAccountsIds() {

        List<Id> result = new List<Id>();
        if(ApexPages.currentPage().getParameters().get('selectedAccountIds') != null){
            result = ApexPages.currentPage().getParameters().get('selectedAccountIds').split(',');
        }

        return result;
    }

    public Map<Id,Boolean> prepareAffiliationsSelectedMap(List<Id> multipleAccountsIds) {
        Map<Id,Boolean> result = new Map<Id,Boolean>();
        for(Id acctId : multipleAccountsIds) {
                result.put(acctId, false);
        }

        return result;
    }

    public Map<Id,String> getAccountsName(List<InteractionWrapper> multipleAccountsList) {
        Map<Id,String> result = new Map<Id,String>();
        for(InteractionWrapper acct : multipleAccountsList) {
                result.put(acct.account.Id, acct.account.Name);
        }

        return result;
    }

    public PageReference addSelectedAccountId() {
        return null;
    }

    public String prepareAvalableContactsJSON() {
        String result = '';

        List<Territory2> userTerritories = [SELECT Name FROM Territory2 WHERE Id IN (SELECT Territory2Id FROM UserTerritory2Association WHERE UserId =: Userinfo.getUserId())];

        List<String> territoriesName = new List<String>();
        for(Territory2 terr : userTerritories) {
            territoriesName.add(terr.Name);
        }

        List<TSF_vod__c> tsfs = [Select Account_vod__c from TSF_vod__c where External_Id_vod__c != null AND Address_vod__c != null and Territory_vod__c IN : territoriesName];

        List<String> accountsIds = new List<String>();
        if(!tsfs.isEmpty()) {
            for(TSF_vod__c tsf : tsfs) {
                accountsIds.add(tsf.Account_vod__c);
            }

        }

        List<Contact> contactsList = [SELECT AccountId, Name, Email FROM Contact WHERE Email != null AND AccountId IN : accountsIds];
        for(Integer i = 0; i < contactsList.size(); i++) {
            result += '\"' + contactsList[i].Name + '<' + contactsList[i].Email + '>\",';
        }

        result = result.removeEnd(',');

        return result;
    }

    public String getParentId() {
    	SFA2_User_Preferences_gne__c result = [SELECT Id FROM SFA2_User_Preferences_gne__c limit 1];
    	return result.Id;
    }

    public List<SFA2_Configuration_Object_gne__c> getConfigForMultipleAccounts(String role, String brand, String recordTypeName, String app) {
    	return [SELECT Id,
    				   Name,
    				   Role_gne__c,
    				   External_ID_gne__c,
    				   Object_Name_gne__c,
    				   Section_Header_gne__c,
                       Record_Type_gne__c,
                       Brand_gne__c,
                       Is_Active_gne__c,
                       Order_gne__c,
                       Style_gne__c,
                       Attributes_gne__c,
                       (SELECT Name,
                       		   API_Name_gne__c,
                       		   Label_gne__c,
                       		   Attributes_gne__c,
                       		   Is_Read_Only_gne__c,
                               Is_Required_gne__c,
                               Order_gne__c,
                               Style_gne__c,
                               Type_gne__c,
                               Availability_Mode_gne__c
                        FROM Configuration_Objects__r
                        WHERE Is_Active_gne__c = true
                        	AND API_Name_gne__c != 'Account_vod__c'
                            AND API_Name_gne__c != 'Parent_Address_vod__c'
                        ORDER BY Order_gne__c, API_Name_gne__c)
                 FROM SFA2_Configuration_Object_gne__c
                 WHERE Object_Name_gne__c = 'Call2_vod__c'
                 	  AND Role_gne__c = : role
                      AND Brand_gne__c = : brand
                      AND Record_Type_gne__c = : recordTypeName
                      AND Application_Type__c = : app
                      AND Is_Active_gne__c = true
                      AND Configuration_Type_gne__c='Page'
                      AND Section_Header_gne__c != 'Attendees'
                 ORDER BY Order_gne__c, Section_Header_gne__c];
    }

}