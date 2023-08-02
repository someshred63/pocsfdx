/******************************************************************************************
*  @author: Sebastian Karczmarski, Roche (contractor)
*  @email: sebastian.karczmarski@contractors.roche.com   
*  Created: 2013-05-24
*  Project: OTR2
*  Description: REST Webservice, returns a list of ProductMetrics for the specified accounts.             
*******************************************************************************************/
@RestResource(urlMapping='/iPhoneGetAccountBrandAffiliations/*')
global with sharing class iPhone_Get_Account_BrandAffiliation_gne {

	@HttpPost 
    global static iPhone_Commons_gne.RestResponse processRequest(String lastSyncDate, List<String> accountIds) {
    	return iPhone_Commons_gne.buildResponse(
	    		new GetAccountBrandAffiliationResponseBuilder(), 
	    		new iPhone_Commons_gne.DefaultDeltaArgs(lastSyncDate, accountIds)    	
    	);     	
    } 
    
    class GetAccountBrandAffiliationResponseBuilder extends iPhone_Commons_gne.DeltaRecordsResponseBuilder{ 
        													
    	protected override List<SObject> selectSObjects(iPhone_Commons_gne.DeltaArgs args) {
    		return  iPhone_DAO.getProductMetricsByAccountIds(args.accountIds);	       
    	} 	
    	     	 			
    	protected override iPhone_Commons_gne.DeltaRecord getAsRecord(SObject sObj) {
    		return new GetAccountBrandAffiliationRecord((Product_Metrics_vod__c)sObj);    		    		
    	}     	
    }      
    
    class GetAccountBrandAffiliationRecord extends iPhone_Commons_gne.DeltaRecord {    
		public String ai; //(account id)
		public String pi; //(product id)	
		public String di; //(product decile)
		public String md; //(market decile)
		public String cf; //(company frequency)
		public String sg; //(segment)
		public String nm; //(name)
		public String bs; //(status)
		public String cl; //(classification)
		public String sp; //(contracted speaker)
		public String tr; //(region)		
		
		public GetAccountBrandAffiliationRecord(Product_Metrics_vod__c productMetrics) {									
			this.id = productMetrics.Id;													   	
			this.nm = productMetrics.Name;				   										
			this.ai = iPhone_StringUtil.getString(productMetrics.Account_vod__c);    	   	
			this.pi = iPhone_StringUtil.getString(productMetrics.Products_vod__c);
			this.di = iPhone_StringUtil.getString(productMetrics.Prod_Decile_gne__c);	 	
			this.md = iPhone_StringUtil.getString(productMetrics.Market_Decile_gne__c);  	
			this.sg = iPhone_StringUtil.getString(productMetrics.Segment_gne__c); 	   			
			this.cl = iPhone_StringUtil.getString(productMetrics.Classification_gne__c); 	
			this.cf = iPhone_StringUtil.getString(productMetrics.Company_Frequency_gne__c);	
			this.bs = iPhone_StringUtil.getString(productMetrics.Brand_Affiliation_Status_gne__c); 
			this.sp = iPhone_StringUtil.getString(productMetrics.Contracted_Speaker__c);	
			this.tr = iPhone_StringUtil.getString(productMetrics.TLL_Region_gne__c);		 																												
		}				
    }
}