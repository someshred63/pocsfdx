public without sharing class AGS_EX_Account_Name_ctrl {
    public String requestId{get;set;}
    
    public String getAccountName(){
    	String accountName = '';
        try{
        	accountName = [SELECT AGS_EX_Exclusion_Request_gne__r.AGS_EX_Account_Name_gne__r.Name 
        					FROM AGS_EX_Exclusion_Check_gne__c 
        					WHERE Id = :requestId LIMIT 1].AGS_EX_Exclusion_Request_gne__r.AGS_EX_Account_Name_gne__r.Name;
        } catch(Exception ex){
        }
        return accountName;
    }

    public String getExcludedAccountName(){
        String accountName = '';
        try{
            accountName = [SELECT Name 
                            FROM Account 
                            WHERE Id = :requestId LIMIT 1].Name;
        } catch(Exception ex){
        }
        return accountName;
    }

	public AGS_EX_Account_Name_ctrl() {
	}
}