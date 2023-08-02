/***********************************************************************************************
*  @author: Piotr Przesmycki
*  Created: 2014-11-04
*  Description: REST Webservice, returns a list of HIN Numbers for FPM project 
*  for the specified accounts.               
************************************************************************************************/
@RestResource(urlMapping='/iPhoneGetAccountHINNumbers/*')
global class iPhone_Get_Account_HIN_Number {

	@HttpPost 
    global static iPhone_Commons_gne.RestResponse executeRequest(String lastSyncDate, String unixId, List<String> accountIds, Boolean enhDelta, String otrVersion) {    	    	
    	return iPhone_Commons_gne.buildResponse(
	    		new iPhoneGetAccountHINNumbersResponseBuilder(), 
	    		new iPhone_Commons_gne.DefaultDeltaArgs(lastSyncDate, unixId, accountIds, enhDelta, otrVersion)
    	);     
    } 
     
    class iPhoneGetAccountHINNumbersResponseBuilder extends iPhone_Commons_gne.DeltaRecordsResponseBuilder { 
    		    	    	
    	protected override List<SObject> selectSObjects(iPhone_Commons_gne.DeltaArgs args) {
    		return args.isEnhancedDelta() ? iPhone_DeltaDAO.getAccountHINNumbersByAccountIds(args.accountIds, args.getLastSyncDate()) : iPhone_DAO.getAccountHINNumbersByAccountIds(args.accountIds);	       
    	} 	
    	     	 			
    	protected override iPhone_Commons_gne.DeltaRecord getAsRecord(SObject sObj) {
    		return new GetAccountHINNumbersRecord((HIN_Number_fpm_gne__c)sObj);    			    		
    	}    	         	 	 
    }
    
    class GetAccountHINNumbersRecord extends iPhone_Commons_gne.DeltaRecord {        	    
		public String hin;	//HIN_Number_fpm_gne__c
		public String acc; 	//Account_ref_gne__c,
		public String cbi; 	//CreatedById,
		public String cbn; 	//CreatedBy.Name,
		public String cd;	//CreatedDate
	
	    public GetAccountHINNumbersRecord(HIN_Number_fpm_gne__c hinNumber) {
		    this.id  = iPhone_StringUtil.getString(hinNumber.Id);
			this.hin  = iPhone_StringUtil.getString(hinNumber.HIN_Number_fpm_gne__c);
			this.acc  = iPhone_StringUtil.getString(hinNumber.Account_ref_gne__c);
			this.cbi  = iPhone_StringUtil.getString(hinNumber.CreatedById);
			this.cbn  = iPhone_StringUtil.getString(hinNumber.CreatedBy.Name);
			this.cd = iPhone_StringUtil.getString(hinNumber.CreatedDate);
	    }
    }    
}