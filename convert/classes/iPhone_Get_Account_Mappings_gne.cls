/******************************************************************************************
*  @author: Lukasz Kozminski, Roche (contractor)
*  @email: lukasz.kozminski@contractors.roche.com   
*  Created: 2016-12-06
*  Project: PACT
*  Description: REST Webservice, returns a list of hcp mappings for the specified accounts.             
*******************************************************************************************/
@RestResource(urlMapping='/iPhoneGetAccountMappings/*')
global with sharing class iPhone_Get_Account_Mappings_gne {
	private static String userIdPrefix;
	
	@HttpPost 
    global static iPhone_Commons_gne.RestResponse processRequest(String lastSyncDate, String unixId, List<String> accountIds, Boolean enhDelta, String otrVersion) {    	
    	return iPhone_Commons_gne.buildResponse(
	    		new GetAccountMappingsResponseBuilder(), 
	    		new iPhone_Commons_gne.DefaultDeltaArgs(lastSyncDate, unixId, accountIds, enhDelta, otrVersion)
    	);     	  
    } 
              
    class GetAccountMappingsResponseBuilder extends iPhone_Commons_gne.DeltaRecordsResponseBuilder { 
    	protected override List<SObject> selectSObjects(iPhone_Commons_gne.DeltaArgs args) {
    		List<FRM_HCO_Mapping_gne__c> mappingsToReturn = args.isEnhancedDelta() ? iPhone_DeltaDAO.getMappingsByAccountIds(args.accountIds, args.getLastSyncDate()) : iPhone_DAO.getMappingsByAccountIds(args.accountIds);
    		return mappingsToReturn;
    	}
  	 			
    	protected override iPhone_Commons_gne.DeltaRecord getAsRecord(SObject sObj) {
    		return new GetAccountMappingsRecord((FRM_HCO_Mapping_gne__c)sObj);    		    		
    	}        	    	
    }
      
    //FRM_HCO_Mapping_gne__c
    class GetAccountMappingsRecord extends iPhone_Commons_gne.DeltaRecord {	
    	public String hcoId;
		public Address address;
		public AccountDetail account;
		public String rid;	// FRM_HCO_Mapping_gne__c.iphone_request_id_gne__c
		
		public GetAccountMappingsRecord(FRM_HCO_Mapping_gne__c mapping) {
			Set<String> mappingKeys = mapping.getPopulatedFieldsAsMap().keySet();
            if (mappingKeys.contains('FRM_HCO_Account_gne__c') && mappingKeys.contains('HCP_Account_gne__r') && mappingKeys.contains('HCP_Address_gne__r')) {
                this.id = mapping.id;
    			this.hcoId = mapping.FRM_HCO_Account_gne__c;
    			this.account = new AccountDetail(mapping.HCP_Account_gne__r);
    			this.address = new Address(mapping.HCP_Address_gne__r);
    			this.address.aid = mapping.HCP_Account_gne__c;
            }
		}
	}
	
	public class AccountDetail {
		public String id;  //(name)
        public String nm;  //(name)
        public String fn;  //(first name)
        public String ln;  //(last name)
        public String mi;  //(mdm id)
        public String ph;  //(phone)
        public String st; // Status_gne__c
        
        public AccountDetail(Account account){
			this.id = account.Id;                                                                                           
            this.nm = account.Name;
            this.fn = iPhone_StringUtil.getString(account.FirstName);               
            this.ln = iPhone_StringUtil.getString(account.LastName);                
            this.mi = iPhone_StringUtil.getString(account.MDMID_gne__c);  
            this.st = iPhone_StringUtil.getString(account.Status_gne__c);
            this.ph = iPhone_StringUtil.getString(account.Phone);      
        }
	}
	
	 public class Address {
	 	public String id;  //(Address ID)
    	public String aid; //(Account ID)                
        public String nm;  //(name)
        public String a2;  //(address line 2)
        public String ct;  //(city)
        public String st;  //(state)
        public String zp;  //(zip)
        public Double lat; //(latitude)
        public Double lng; //(longitude)
        
        public Address(Address_vod__c address){
        	this.id  = address.id;        
            this.nm  = address.Name ;                                               
            this.a2  = iPhone_StringUtil.getString(address.Address_line_2_vod__c);  
            this.ct  = iPhone_StringUtil.getString(address.City_vod__c);           
            this.st  = iPhone_StringUtil.getString(address.State_vod__c);           
            this.zp  = iPhone_StringUtil.getString(address.Zip_vod__c);
            this.lat = address.Location_gne__Latitude__s;
            this.lng = address.Location_gne__Longitude__s;          
        }
	 }
}