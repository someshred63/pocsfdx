/******************************************************************************************
*  @author: Tomasz Kosecki, Roche (contractor)
*  @email: tomasz.kosecki@contractors.roche.com   
*  Created: 2018-02-14
*  Project: OTR2
*  Description: REST Webservice, returns a list of Call2_Category_vod__c for the specified accounts.             
*******************************************************************************************/
@RestResource(urlMapping='/iPhoneGetAccountCallCategories/*')
global with sharing class iPhone_Get_Account_CallCategories_gne {
	
	@HttpPost 
    global static iPhone_Commons_gne.RestResponse processRequest(String lastSyncDate, String unixId, List<String> accountIds, Boolean enhDelta, String otrVersion) {    	
    	return iPhone_Commons_gne.buildResponse(
	    		new GetAccountCallDetailsResponseBuilder(), 
	    		new iPhone_Commons_gne.DefaultDeltaArgs(lastSyncDate, unixId, accountIds, enhDelta, otrVersion)
    	);     	    	 
    } 
              
    class GetAccountCallDetailsResponseBuilder extends iPhone_Commons_gne.DeltaRecordsResponseBuilder {
    													
    	protected override List<SObject> selectSObjects(iPhone_Commons_gne.DeltaArgs args) {
    		return args.isEnhancedDelta() ? iPhone_DeltaDAO.getCallCategoriesByAccountIds(args.accountIds, args.getLastSyncDate()) : iPhone_DAO.getCallCategoriesByAccountIds(args.accountIds);      
    	} 	
    	     	 			
    	protected override iPhone_Commons_gne.DeltaRecord getAsRecord(SObject sObj) {
    		return new GetAccountCallCategoriesRecord((Call2_Category_vod__c)sObj);    		    		
    	}     	
    } 
    
    class GetAccountCallCategoriesRecord extends iPhone_Commons_gne.DeltaRecord {	
        public String iid; // Call2_Category_vod__c.Call2_vod__c
        public String bab; // Call2_Category_vod__c.Brand_Above_Brand_gne__c
        public String brn; // Call2_Category_vod__c.Brand_Name_gne__c
        public String ind; // Call2_Category_vod__c.Indication_gne__c
        public String mol; // Call2_Category_vod__c.Molecule_gne__c              
        public String noc; // Call2_Category_vod__c.NOC_Status_gne__c              
        public String tpa; // Call2_Category_vod__c.Therapeutic_Area_gne__c              
                
        public GetAccountCallCategoriesRecord(Call2_Category_vod__c callDetail) {
        	this.id  = callDetail.Id;
            this.iid = callDetail.Call2_vod__c;
            this.bab = iPhone_StringUtil.getString(callDetail.Brand_Above_Brand_gne__c);
            this.brn = iPhone_StringUtil.getString(callDetail.Brand_Name_gne__c);
            this.ind = iPhone_StringUtil.getString(callDetail.Indication_gne__c);
            this.mol = iPhone_StringUtil.getString(callDetail.Molecule_gne__c);              	      
            this.noc = iPhone_StringUtil.getString(callDetail.NOC_Status_gne__c);              	      
            this.tpa = iPhone_StringUtil.getString(callDetail.Therapeutic_Area_gne__c);              	      
        }
	}
}