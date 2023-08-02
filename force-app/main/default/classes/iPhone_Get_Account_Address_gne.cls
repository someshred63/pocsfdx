/******************************************************************************************
*  @author: Sebastian Karczmarski, Roche (contractor)
*  @email: sebastian.karczmarski@contractors.roche.com   
*  Created: 2013-05-24
*  Project: OTR2
*  Description: REST Webservice, returns a list of Addresses for the specified accounts.             
*******************************************************************************************/
@RestResource(urlMapping='/iPhoneGetAccountAddresses/*')
global with sharing class iPhone_Get_Account_Address_gne {
	
	@HttpPost 
    global static iPhone_Commons_gne.RestResponse processRequest(String lastSyncDate, String unixId, List<String> accountIds, Boolean enhDelta, String otrVersion) {
    	return iPhone_Commons_gne.buildResponse(
	    		new GetAccountAddressResponseBuilder(), 
	    		new iPhone_Commons_gne.DefaultDeltaArgs(lastSyncDate, unixId, accountIds, enhDelta, otrVersion)    		
    	);     	    	    	    	
    } 
      
    class GetAccountAddressResponseBuilder extends iPhone_Commons_gne.DeltaRecordsResponseBuilder { 
    													
    	protected override List<SObject> selectSObjects(iPhone_Commons_gne.DeltaArgs args) {
    		if(GNE_SFA2_Util.isBrandUser()){
    			return args.isEnhancedDelta() ? iPhone_DeltaDAO.getAllAddressesByAccountIds(args.accountIds, args.getLastSyncDate()) : iPhone_DAO.getAllAddressesByAccountIds(args.accountIds);
    		}else{
    			return args.isEnhancedDelta() ? iPhone_DeltaDAO.getAddressesByAccountIds(args.accountIds, args.getLastSyncDate()) : iPhone_DAO.getAddressesByAccountIds(args.accountIds);
    		}      
    	} 	
    	     	 			
    	protected override iPhone_Commons_gne.DeltaRecord getAsRecord(SObject sObj) {
    		return new GetAccountAddressRecord((Address_vod__c)sObj);    		    		
    	}     	
    	
    	protected override iPhone_Commons_gne.DeltaCalculator getDeltaCalculator(String lastSyncDate){
        	return new AddressDeltaCalculator(lastSyncDate);
        }
    } 
    
    class AddressDeltaCalculator extends iPhone_Commons_gne.DeltaCalculator{
    	
    	private String lastModifiedDateFieldName; 
    	
    	public AddressDeltaCalculator(String lastSyncDate){
    		super(lastSyncDate);
    		this.lastModifiedDateFieldName = String.valueOf(Address_vod__c.iPhone_Fields_LastModifiedDate_gne__c);
    	}
    	
		protected override String getDeltaStatus(SObject sObj) {
			if(lastSynchronized == null) // delta is OFF.
				return null;		
			Datetime created = (Datetime)sObj.get('CreatedDate');
							
			if(created >= lastSynchronized) { 
				return STAT_INSERT; 	// created AFTER last synchronization.
			} else {
				object lastModifiedDateObj = sObj.get(this.lastModifiedDateFieldName);
				Datetime lastModified = null;
				if (lastModifiedDateObj != null){
					lastModified =(Datetime)lastModifiedDateObj;					
				}
				
				if(lastModified != null && lastModified >= lastSynchronized) {
					return STAT_UPDATE; // created BEFORE last synchonization but updated AFTER last synchronization. 
				} else {
					return STAT_SYNC; // created and updated BEFORE last synchronization (is eXisting = already synchronized). 
				}
			}							
		}							
	}	 
      
    class GetAccountAddressRecord extends iPhone_Commons_gne.DeltaRecord {
    	public String aid; //(Account ID)                
        public String nm;  //(name)
        public String pr;  //(is primary)
        public String a2;  //(address line 2)
        public String ct;  //(city)
        public String st;  //(state)
        public String zp;  //(zip)
        public String z4;  //(zip 4)
        public String ph;  //(phone)
        public String xt;  //(phone ext)
        public String p2;  //(phone 2)
        public String x2;  //(phone ext 2)
        public String fx;  //(fax)
        public String f2;  //(fax 2)
        public String ln;  //(license number)
        public String ld;  //(license expiration date)
        public String lt;  //(license status) <empty if unknown>
        public String vs;  //(valid to sample)
        public String pc;  //(province)
        public String pco; //(postal code)
        public String orn; //(org name) Pole: on => orn
        public String rt;  //(record type)
        public String bdd; //(best days to deliver)
        public Double lat; //(latitude)
        public Double lng; //(longitude)
        public String sts; //(mdm status)
        public String mi; //(mdm address id)
        public String isAddrCm; //isAddressCompanyMaintained
        public String bus; //(business name)
        public String bat; //(business address type)
        public Boolean adc; //(changed address)
        public String ei; //(address external Id)
        
        public GetAccountAddressRecord(Address_vod__c address) {
            this.id  = address.id;        
            this.nm  = address.Name ;                                               
            this.aid = iPhone_StringUtil.getString(address.Account_vod__c);                                                           
            this.pr  = iPhone_StringUtil.getString(address.Primary_vod__c);                       
            this.a2  = iPhone_StringUtil.getString(address.Address_line_2_vod__c);  
            this.ct  = iPhone_StringUtil.getString(address.City_vod__c);           
            this.st  = iPhone_StringUtil.getString(address.State_vod__c);           
            this.zp  = iPhone_StringUtil.getString(address.Zip_vod__c);            
            this.z4  = iPhone_StringUtil.getString(address.Zip_4_vod__c);           
            this.ph  = iPhone_StringUtil.getString(address.Phone_vod__c);            
            this.xt  = iPhone_StringUtil.getString(address.Phone_1_Ext_gne__c);     
            this.p2  = iPhone_StringUtil.getString(address.Phone_2_vod__c);          
            this.x2  = iPhone_StringUtil.getString(address.Phone_2_Ext_gne__c);     
            this.fx  = iPhone_StringUtil.getString(address.Fax_vod__c);             
            this.f2  = iPhone_StringUtil.getString(address.Fax_2_vod__c);           
            this.ln  = iPhone_StringUtil.getString(address.License_vod__c);         
            this.ld  = iPhone_StringUtil.getStringDate(address.License_Expiration_Date_vod__c);
            this.lt  = iPhone_StringUtil.getString(address.License_Status_vod__c);  
            this.vs  = iPhone_StringUtil.getString(address.License_Valid_To_Sample_vod__c); 
            this.pc  = iPhone_StringUtil.getString(address.Province_can_gne__c);   
            this.pco = iPhone_StringUtil.getString(address.Postal_Code_can_gne__c);
            this.orn = iPhone_StringUtil.getString(address.Org_Name_can_gne__c);    
            this.rt  = iPhone_StringUtil.getString(address.RecordType.Name);
            this.bdd = iPhone_StringUtil.getString(address.PFG_BDTD_gne__c);
            this.lat = address.Location_gne__Latitude__s;
            this.lng = address.Location_gne__Longitude__s;
            this.sts = iPhone_StringUtil.getString(address.MDM_Status_gne__c);
            this.mi  = iPhone_StringUtil.getString(address.MDM_Address_ID_gne__c);
            this.isAddrCm = iPhone_StringUtil.getString(GNE_SFA2_Address_Field_Updates.isRecordCompanyMaintained(address.RecordType.DeveloperName));
            this.bus = iPhone_StringUtil.getString(address.Business_Name_gne__c);
            this.bat = iPhone_StringUtil.getString(address.Business_Address_Type_gne__c);
            this.adc = address.Changed_Address_gne__c;
            this.ei = iPhone_StringUtil.getString(address.External_ID_vod__c);
        }                	
    }            	
}