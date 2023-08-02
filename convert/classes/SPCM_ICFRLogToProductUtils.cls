public without sharing class SPCM_ICFRLogToProductUtils {
	
	static Set<Id> logIds = new Set<Id>();

	//Updates ICFR Log string list of products.
	//This method is called on insert and delete of Log-to-Product junction entries
	public static void UpdateICFRLogProductList(List<SPCM_log_to_Product_Junction__c> LogsToProductsModified)
	{
		for (SPCM_log_to_Product_Junction__c LogToProd : LogsToProductsModified)
			logIds.add(LogToProd.ICFR_Log__c);
		
		SPCM_ICFR_Log__c[] logs = [select id, Product_List__c, (SELECT Product_name__c FROM Log_To_Product_Junction__r)
									from SPCM_ICFR_Log__c where id in :logIds];

		for (SPCM_ICFR_Log__c log : logs){
			log.Product_List__c = GetAllProductsFor(log);
		}

		update logs;
	}

	public static void ValidateNewJunction(List<SPCM_log_to_Product_Junction__c> LogsToProductsNew, String triggerName)
	{
		
		// Don't validate this if comming from ESB by WebService SPCM_ICFR_Log_Webservice	
		if(SPCM_ICFR_Log_Webservice.IS_WEBSERVICE)
		{	
			return;
		}
			
		Set<Id> icfrLogIds = new Set<Id>();

		String errorMsg;
		
		if(triggerName == 'isInsert') {
			errorMsg = 'Can\'t add SPCM Product. ICFR Log entry Status is not In Process.';
		}
		if(triggerName == 'isDelete') {
			errorMsg = 'Can\'t delete SPCM Product. ICFR Log entry Status is not In Process.';
		} 

		for (SPCM_log_to_Product_Junction__c LogToProd : LogsToProductsNew){
			icfrLogIds.add(LogToProd.ICFR_Log__c);
		}
		
		Map<id, SPCM_ICFR_Log__c> logsMap = new Map<id, SPCM_ICFR_Log__c>([select id, status__c from SPCM_ICFR_Log__c where id in :icfrLogIds]);
		
		for (SPCM_log_to_Product_Junction__c LogToProd : LogsToProductsNew){
			if (logsMap.get(LogToProd.ICFR_Log__c).Status__c != 'In Process') {
				LogToProd.addError(errorMsg);
			}
		}

	}


	//creates coma-delimited string from log's related products
	private static string GetAllProductsFor(SPCM_ICFR_Log__c log)
	{
		List<string> prodLst = new List<string>();
		for(SPCM_log_to_Product_Junction__c childJunctionProd : log.Log_To_Product_Junction__r){
			prodLst.add(childJunctionProd.Product_name__c);
		}
			
		prodLst.sort();
		return String.join(prodLst, ', ');
	}
}