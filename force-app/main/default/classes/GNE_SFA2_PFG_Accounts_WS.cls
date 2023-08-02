@RestResource(urlMapping='/Accounts/*')
global class GNE_SFA2_PFG_Accounts_WS {

	global class AccountsResult {
		public List<Product_Tactic_vod__c> 	tacs = new List<Product_Tactic_vod__c>();  		//Product Tactics
		public List<Product_vod__c> prods = new List<Product_vod__c>(); 					//Product Catalogs
		public List<Product_Strategy_vod__c> strs = new List<Product_Strategy_vod__c>(); 	//Product Strategies
		public List<Account> prefs = new List<Account>();									//Accounts
		public List<Product_vod__c> cprods = new List<Product_vod__c>();					//Product Catalogs
		public List<Territory2> ters = new List<Territory2>();								//Territories

	}

	@HttpPost
	global static List<Account> doGetAccounts(String unixId){
		List<Account> response;

		try{
			response = [SELECT Name FROM Account WHERE id=:unixId LIMIT 4];
		}catch(Exception ex){
			System.debug('ERROR: ' + ex.getMessage());
		}
		return response;
	}
}