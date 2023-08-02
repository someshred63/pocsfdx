public with sharing class GNE_SFA2_InteractionScheduler_Controller {

    public List<SelectOption>availableProducts {get; set;}
    public List<InteractionWrapper>wrappers {get; set;}
    public Date weekStart{get; set;}
    public Date weekEnd {get; set;}
    public String selectedDate {get; set;}
    public String interactionIndexToRemove {get; set;}
    public List<GNE_SFA2_SearchAccounts_Controller.AccountWrapper> availableAccounts {get; set;}
    public String selectedAccountsJSON {get; set;}
    
    public List<SelectOption>timeOptions {get; set;}
    public List<SelectOption>accountOptions {get; set;}
    public List<String> visibleFields {get;set;}
    public Id currentUser { get; set; }
    public Boolean schedulingWithSuccess {get; set;}
    public Boolean scheduleButton = true;
    
    public GNE_SFA2_InteractionScheduler_Controller(){
      this.schedulingWithSuccess = false;
        this.currentUser = UserInfo.getUserId();
        this.selectedDate = Date.today().format();
        wrappers = new List<InteractionWrapper>();
        visibleFields = new List<String>{ 'Entity_Display_Name_vod__c', 'Call_Datetime_vod__c' };
        timeOptions = GNE_SFA2_Interaction_Controller.createTimeOptions();
        
        if(ApexPages.currentPage().getParameters().get('selectedAccountIds')!=null){
            List<String> ids = ApexPages.currentPage().getParameters().get('selectedAccountIds').split(',');
            Integer counter = 0;
            for(Account account: [SELECT Id, Name, IsPersonAccount,(SELECT Id, Name, City_vod__c FROM Address_vod__r where Inactive_vod__c =: false ) FROM Account WHERE id IN :ids ORDER BY Name]){
                Integer index = Math.mod(counter, timeOptions.size());
                String interactionTime = timeOptions.get(index).getValue();
                String interactionDate = Date.today().format();
                if(counter >= timeOptions.size()){
                    interactionDate = Date.today().addDays(counter / timeOptions.size()).format();
                }
                System.debug('Addresses' + account.address_vod__r);          
                wrappers.add(new InteractionWrapper(account, account.address_vod__r, null, null, interactionDate, interactionTime, counter));
                counter++;
            }
        }
        
        accountOptions = new List<SelectOption>();
        availableProducts = GNE_SFA2_Interaction_Controller.getAvailableProducts(UserInfo.getUserId());
    }
    
    public boolean getScheduleButton(){
        return scheduleButton;
    }
    
    private Boolean validate(){
    	Boolean isValid = true;
    	for(InteractionWrapper wrapper: wrappers){
           if(String.isEmpty(wrapper.selectedAddress)){
		        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'You must enter a value for Address'));
		        isValid=false;
		        break;
           }
        }
        return isValid;
    }
    
    public PageReference scheduleInteractions(){
    	if(!validate()){
    		return null;
    	}
        Map<InteractionWrapper , Call2_vod__c> calls = new Map<InteractionWrapper , Call2_vod__c>();
        List<Call2_Discussion_vod__c> discussions = new List<Call2_Discussion_vod__c>();
        List<Call2_Detail_vod__c> details = new List<Call2_Detail_vod__c>();
        
        Set<Id>addressIds = new Set<Id>();

        for(InteractionWrapper wrapper: wrappers){
            addressIds.add(wrapper.selectedAddress);
        }
        
        Map<Id, Address_vod__c> addresses = new Map<Id, Address_vod__c>([SELECT id, Name, Address_1_gne__c, Address_line_2_vod__c, City_vod__c, State_vod__c, Zip_vod__c, Zip_4_vod__c, Province_can_gne__c, Postal_Code_can_gne__c FROM Address_vod__c WHERE id IN :addressIds]); 

        for(InteractionWrapper wrapper: wrappers){
            calls.put(wrapper, createCall(wrapper, addresses));
        }
        PageReference pr = null;
        if(calls.size()>0){
            SavePoint savePoint = Database.setSavePoint();
            try{
                system.debug('insert calls: '+calls.values());
                insert calls.values();
                for(InteractionWrapper wrapper: calls.keySet()){
                    discussions.add(createCallDiscusion(wrapper, calls.get(wrapper)));
                    details.add(createCallDetails(wrapper, calls.get(wrapper)));
                }
                system.debug('insert discussions: '+discussions);
                insert discussions;
                system.debug('insert details: '+details);
                insert details;                
            schedulingWithSuccess = true;
            }catch(Exception e){
                system.debug(e);
                system.debug(schedulingWithSuccess);
                Database.rollback ( savePoint );
                ApexPages.addMessages(e);
            }
        }else{
          schedulingWithSuccess = true;
        }
        system.debug(schedulingWithSuccess);
        return pr;
    }
    
    public void clearStatus(){
      schedulingWithSuccess = false;
    }
    
    private Call2_vod__c createCall(InteractionWrapper wrapper, Map<Id, Address_vod__c> addresses){
        system.debug(wrapper);
        system.debug(addresses);        
        DateTime callDate =  DateTime.parse(wrapper.interactionDate +' '+ wrapper.interactionTime);
        
        Call2_vod__c call = new Call2_vod__c(Account_vod__c = wrapper.account.id, Call_Datetime_vod__c = callDate, Parent_Address_vod__c = wrapper.selectedAddress);
        if(wrapper.selectedProduct!=null){
            call.Detailed_Products_vod__c = getProductName(wrapper.selectedProduct);
        }
        Address_vod__c callAddress = addresses.get(wrapper.selectedAddress);
        call.Address_Line_1_vod__c = callAddress.Name;
        call.Address_line_2_vod__c = callAddress.Address_line_2_vod__c;
        
        call.Address_vod__c = GNE_SFA2_Util.getAddressAsString(callAddress);
        call.Zip_4_vod__c = callAddress.Zip_4_vod__c;
        call.City_vod__c = callAddress.City_vod__c;
        call.State_vod__c = callAddress.State_vod__c;
        call.Zip_vod__c = callAddress.Zip_vod__c;
        if(wrapper.account.IsPersonAccount){
            call.Attendee_Type_vod__c='Person_Account_vod';
        }else{
            call.Attendee_Type_vod__c='Group_Account_vod';
        }
        call.Detailed_Products_vod__c = getProductName(wrapper.selectedProduct);
        call.Call_Type_vod__c='Call Only';
        call.Last_Device_vod__c='Online_vod';
        call.Status_vod__c='Planned_vod';
        return call;
    }
    
    private String getProductName(String productId){
        for(SelectOption option: availableProducts){
            if(option.getValue()==productId){
                return option.getLabel(); 
            }
        }
        return '';  
    }
    
    public Call2_Discussion_vod__c createCallDiscusion(InteractionWrapper wrapper, Call2_vod__c call){
        Call2_Discussion_vod__c discussion = new Call2_Discussion_vod__c(Account_vod__c  = wrapper.account.id, Call2_vod__c = call.id, Product_vod__c = wrapper.selectedProduct);
        discussion.Attendee_Type_vod__c=call.Attendee_Type_vod__c;
        discussion.Call_Date_vod__c=Date.parse(wrapper.interactionDate);
        return discussion;
    }
    
    public Call2_Detail_vod__c createCallDetails(InteractionWrapper wrapper, Call2_vod__c call){
        Call2_Detail_vod__c detail = new Call2_Detail_vod__c(Call2_vod__c = call.id, Product_vod__c = wrapper.selectedProduct);
        return detail;
    }
        
    public PageReference cancel(){
        PageReference pr = Page.GNE_SFA2_MyAccounts;
        pr.setRedirect(true);
        return pr;
    }
    
    public PageReference removeCall(){
        system.debug(interactionIndexToRemove);
        Integer listIndex = -1;
        for(Integer i=0; i< wrappers.size(); i++){
            if(Integer.valueOf(interactionIndexToRemove) == wrappers.get(i).index){
                listIndex = i;
                break;
            }
        }
        if(listIndex > -1){
            wrappers.remove(listIndex);
        }
        return null;
    }
    
    @RemoteAction
    public static List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper>searchAccounts(String searchString, Integer recordLimit, Boolean onlyPersonAccounts){
        return GNE_SFA2_SearchAccounts_Controller.searchAccounts(searchString, recordLimit, onlyPersonAccounts);
    }

    public PageReference addInteractions(){
        List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper>selectedAccounts =  (List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper>) JSON.deserialize(selectedAccountsJSON, List<GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper>.class);
        List<Id>accountIds = new List<Id>();
        for(GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper wrapper: selectedAccounts){
                if(!wrapper.isContact){
                        accountIds.add(wrapper.accountId);
                }
        }
        Map<Id, Account> accountsMap = new Map<Id, Account>([SELECT Id, IsPersonAccount, Territory_vod__c, Name,(SELECT Id, Name, City_vod__c FROM Address_vod__r WHERE Inactive_vod__c =: false) FROM Account WHERE  id IN :accountIds]);
        
        Integer counter = wrappers.size();
        for(GNE_SFA2_SearchAccounts_Controller.SimpleAccountWrapper wrapper: selectedAccounts){
                Integer index = Math.mod(counter, timeOptions.size());
            String interactionTime = timeOptions.get(index).getValue();
            String interactionDate = Date.today().format();
            if(counter >= timeOptions.size()){
                interactionDate = Date.today().addDays(counter / timeOptions.size()).format();
            }
            if(!wrapper.isContact){          
                wrappers.add(new InteractionWrapper(accountsMap.get(wrapper.accountId), accountsMap.get(wrapper.accountId).address_vod__r, wrapper.addressId, null, interactionDate, interactionTime, counter));
            }
            counter++;
        } 
        return null;
    }
        
    public class InteractionWrapper{
        public Account account {get; set;}
        public Id selectedAddress {get; set;}
        public List<SelectOption> addressesOptions {get; set;}
        public String interactionDate {get; set;}
        public String interactionTime {get; set;}
        public String notes {get; set;}
        public Integer index {get; set;}
        public Id selectedProduct {get; set;}
        
        public InteractionWrapper(){
        }
        
        public InteractionWrapper(Account account, List<Address_vod__c>addresses, Id selectedAddress, Id selectedProduct, String interactionDate, String interactionTime, Integer index){
            this.account = account;
            this.interactionDate = interactionDate;
            this.interactionTime = interactionTime;
            this.notes = '';
            this.addressesOptions = new List<SelectOption>();
            this.addressesOptions.add(new SelectOption('', '--None--'));
            for(Address_vod__c address: addresses){
                this.addressesOptions.add(new SelectOption(address.Id, address.Name));
            }
            if(addresses.size()==1){
                this.selectedAddress = addresses.get(0).id;
            }else{
                this.selectedAddress = selectedAddress;
            }
            this.index = index;
            this.selectedProduct = selectedProduct;       
        }
    }
    
    
}