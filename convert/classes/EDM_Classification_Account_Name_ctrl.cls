public without sharing class EDM_Classification_Account_Name_ctrl {
    public String requestId{get;set;}
    
    public String getAccountName(){
    	String accountName = '';
        try{
        	accountName = [SELECT EDM_Account_gne__r.Name FROM EDM_Classification_Request_gne__c WHERE Id = :requestId LIMIT 1].EDM_Account_gne__r.Name;
        } catch(Exception ex){
        }
        return accountName;
    }

	public EDM_Classification_Account_Name_ctrl() {
		
	}
}