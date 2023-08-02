/***********************************************************************************************
*  @author: Sebastian Karczmarski, Roche (contractor)
*  @email: sebastian.karczmarski@contractors.roche.com   
*  Created: 2013-05-24
*  Project: OTR2
*  Description: REST Webservice, returns a list of Affiliations (only) with no contacts assigned
*  for the specified accounts.               
************************************************************************************************/
@RestResource(urlMapping='/iPhoneGetAccountAffiliations/*')
global with sharing class iPhone_Get_Account_Affiliations_gne {
	
	@HttpPost 
    global static iPhone_Commons_gne.RestResponse executeRequest(String lastSyncDate, String unixId, List<String> accountIds) {    	    	
    	return iPhone_Commons_gne.buildResponse(
	    		new GetAccountAffiliationsResponseBuilder(), 
	    		new iPhone_Commons_gne.DefaultDeltaArgs(
	    							   	lastSyncDate, unixId, accountIds
    		)
    	);     
    } 
     
    class GetAccountAffiliationsResponseBuilder extends iPhone_Commons_gne.DeltaRecordsResponseBuilder { 
    	    	    	
    	private String myBrandFieldApiName;

        public GetAccountAffiliationsResponseBuilder(){
            if (GNE_Account_Affiliation_Dao.canSetActiveForMyBrand()){
                this.myBrandFieldApiName = GNE_Account_Affiliation_Dao.getMyBrandFieldApiName();
            }
        }

        protected override List<SObject> selectSObjects(iPhone_Commons_gne.DeltaArgs args) {
    		return iPhone_DAO.getAccountAffiliationsNoContactsByAccountIds(args.accountIds);	       
    	} 	
    	     	 			
    	protected override iPhone_Commons_gne.DeltaRecord getAsRecord(SObject sObj) {
    		return new GetAccountAffiliationsRecord((Affiliation_vod__c)sObj, this.myBrandFieldApiName);    			    		
    	}
    	
    	protected override DeltaCalculator getDeltaCalculator(String lastSyncDate){
            return new GetAccountAffiliationsDeltaCalculator(lastSyncDate);
        }
    }
    
    public class GetAccountAffiliationsDeltaCalculator extends iPhone_Commons_gne.DeltaCalculator {

        public GetAccountAffiliationsDeltaCalculator(String lastSyncDate) {
            super(lastSyncDate);
        }

        protected override String getDeltaStatus(SObject sObj) {
            if (lastSynchronized == null){ // delta is OFF.
                return null;
            }

            Affiliation_vod__c aff = (Affiliation_vod__c) sObj;
            Datetime created = aff.CreatedDate;
            Datetime lastModified = aff.LastModifiedDate;
            Datetime accountLastModified = aff.To_Account_vod__r.iPhone_Fields_LastModifiedDate_gne__c;

            if (created >= lastSynchronized) {
                return STAT_INSERT;     // created AFTER last synchronization.
            }
            else {
                if(lastModified >= lastSynchronized || accountLastModified >= lastSynchronized) {
                    return STAT_UPDATE; // created BEFORE last synchonization but updated AFTER last synchronization.
                }
                else {
                    return STAT_SYNC; // created and updated BEFORE last synchronization (is eXisting = already synchronized).
                }
            }
        }
    }
    
    class GetAccountAffiliationsRecord extends iPhone_Commons_gne.DeltaRecord {    
	    public String tid; //To_Account_vod__c, 
	    public String ln;  //To_Account_vod__r.LastName,  
	    public String rn;  //Role_vod__c,  
	    public String fid; //From_Account_vod__c, 
	    public String fn;  //To_Account_vod__r.FirstName,  
	    public String ip;  //To_Account_vod__r.IsPersonAccount,  
	    public String nm;  //To_Account_vod__r.Name  
	    public String pr;  //Primary_gne__c
	    public String prfpm;  //Primary_fpm_gne__c
        public String prepst; //To_Account_vod__r.PREP_Status_gne__c
        public String aft; //Affiliation_Type_gne__c
        public String inf; //Influence_vod__c
        public String cm; //Comments_vod__c
        public String mb;   //Active for my brand
        public String pt;   //To_Account_vod__r.PREP_Professional_Type_gne__c
        public String mdmId; //MDM_ID_gne__c
        public String mi; //Account mdmId 
	    	    
	    public GetAccountAffiliationsRecord(Affiliation_vod__c affiliation, String myBrandFieldApiName) {
			this.id  = iPhone_StringUtil.getString(affiliation.Id);
			this.tid = iPhone_StringUtil.getString(affiliation.To_Account_vod__c);
			this.ln  = iPhone_StringUtil.getString(affiliation.To_Account_vod__r.LastName);
			this.rn  = iPhone_StringUtil.getString(affiliation.Role_vod__c);
			this.fid = iPhone_StringUtil.getString(affiliation.From_Account_vod__c);
			this.fn  = iPhone_StringUtil.getString(affiliation.To_Account_vod__r.FirstName);
			this.ip  = iPhone_StringUtil.getString(affiliation.To_Account_vod__r.IsPersonAccount);
			this.nm  = iPhone_StringUtil.getString(affiliation.To_Account_vod__r.Name);
			this.pr  = iPhone_StringUtil.getString(affiliation.Primary_gne__c);
			this.prfpm  = iPhone_StringUtil.getString(affiliation.Primary_fpm_gne__c);
            this.prepst = iPhone_StringUtil.getString(affiliation.To_Account_vod__r.PREP_Status_gne__c);
            this.aft = iPhone_StringUtil.getString(affiliation.Affiliation_Type_gne__c);
            this.inf = iPhone_StringUtil.getString(affiliation.Influence_vod__c);
            this.cm = iPhone_StringUtil.getString(affiliation.Comments_vod__c);
            this.mb = iPhone_StringUtil.getString(String.isNotBlank(myBrandFieldApiName) ? (Boolean)affiliation.get(myBrandFieldApiName) : null);
            this.pt = iPhone_StringUtil.getString(affiliation.To_Account_vod__r.PREP_Professional_Type_gne__c);
            this.mdmId = iPhone_StringUtil.getString(String.isNotBlank(affiliation.MDM_ID_gne__c) ? affiliation.MDM_ID_gne__c.substringAfter('>').substringBefore('<') : null);
	        this.mi = this.mdmId;
        }
    }    
}