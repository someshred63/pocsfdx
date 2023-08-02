/***********************************************************************************************
*  @author: Piotr Przesmycki
*  Created: 2014-11-04
*  Description: REST Webservice, returns a list of Distributors for FPM project 
*  for the specified accounts.               
************************************************************************************************/
@RestResource(urlMapping='/iPhoneGetAccountDistributors/*')
global class iPhone_Get_Account_Distributor {

	@HttpPost 
    global static iPhone_Commons_gne.RestResponse executeRequest(String lastSyncDate, String unixId, List<String> accountIds, Boolean enhDelta, String otrVersion) {    	    	
    	return iPhone_Commons_gne.buildResponse(
	    		new iPhoneGetAccountDistributorsResponseBuilder(), 
	    		new iPhone_Commons_gne.DefaultDeltaArgs(lastSyncDate, unixId, accountIds, enhDelta, otrVersion)
    	);     
    } 
     
    class iPhoneGetAccountDistributorsResponseBuilder extends iPhone_Commons_gne.DeltaRecordsResponseBuilder { 
    		    	    	
    	protected override List<SObject> selectSObjects(iPhone_Commons_gne.DeltaArgs args) {
    		return args.isEnhancedDelta() ? iPhone_DeltaDAO.getAccountDistributorsByAccountIds(args.accountIds, args.getLastSyncDate()) : iPhone_DAO.getAccountDistributorsByAccountIds(args.accountIds);	       
    	} 	
    	     	 			
    	protected override iPhone_Commons_gne.DeltaRecord getAsRecord(SObject sObj) {
    		return new GetAccountDistributorsRecord((Distributor_fpm_gne__c)sObj);    			    		
    	}    	         	 	 
    }
    
    class GetAccountDistributorsRecord extends iPhone_Commons_gne.DeltaRecord {        	    
		public String dan;	//Distributor_Account_Number_fpm_gne__c
		public String dis;  //Distributor__c,
		public String acc; 	//Account_ref_gne__c,
		public String cbi; 	//CreatedById,
		public String cbn; 	//CreatedBy.Name,
		public String cd;	//CreatedDate
	
	    public GetAccountDistributorsRecord(Distributor_fpm_gne__c distributor) {
		    this.id  = iPhone_StringUtil.getString(distributor.Id);
			this.dan  = iPhone_StringUtil.getString(distributor.Distributor_Account_Number_fpm_gne__c);
			this.dis  = iPhone_StringUtil.getString(distributor.Distributor__c);
			this.acc  = iPhone_StringUtil.getString(distributor.Account_ref_gne__c);
			this.cbi  = iPhone_StringUtil.getString(distributor.CreatedById);
			this.cbn  = iPhone_StringUtil.getString(distributor.CreatedBy.Name);
			this.cd = iPhone_StringUtil.getString(distributor.CreatedDate);
	    }
    }    
}