/***********************************************************************************************
*  @author: Sebastian Karczmarski, Roche (contractor)
*  @email: sebastian.karczmarski@contractors.roche.com   
*  Created: 2013-05-24
*  Project: OTR2
*  Description: REST Webservice, returns a list of Affiliations (only) with contacts assigned 
*  for the specified accounts.               
************************************************************************************************/
@RestResource(urlMapping='/iPhoneGetAccountContactAffiliations/*')
global with sharing class iPhone_Get_Account_ContAffiliations_gne {
	
	@HttpPost 
    global static iPhone_Commons_gne.RestResponse executeRequest(String lastSyncDate, String unixId, List<String> accountIds) {    	    	
    	return iPhone_Commons_gne.buildResponse(
	    		new GetAccountContactAffiliationsResponseBuilder(), 
	    		new iPhone_Commons_gne.DefaultDeltaArgs(
	    							   	lastSyncDate, unixId, accountIds
    		)
    	);     
    } 
     
    class GetAccountContactAffiliationsResponseBuilder extends iPhone_Commons_gne.DeltaRecordsResponseBuilder {
    	
    	private String myBrandFieldApiName;
    	
    	public GetAccountContactAffiliationsResponseBuilder(){
    		if (GNE_Account_Affiliation_Dao.canSetActiveForMyBrand()){
    			this.myBrandFieldApiName = GNE_Account_Affiliation_Dao.getMyBrandFieldApiName();
    		}
    	}
    		    	    	
    	protected override List<SObject> selectSObjects(iPhone_Commons_gne.DeltaArgs args) {
    		return iPhone_DAO.getAccountAffiliationsWithContactsByAccountIds(args.accountIds);	       
    	} 	
    	     	 			
    	protected override iPhone_Commons_gne.DeltaRecord getAsRecord(SObject sObj) {
    		return new GetAccountContactAffiliationsRecord((Affiliation_vod__c)sObj, this.myBrandFieldApiName);
    	}
    	
    	protected override DeltaCalculator getDeltaCalculator(String lastSyncDate){
            return new GetAccountContAffiliationsDeltaCalculator(lastSyncDate);
        }
    }
    
    public class GetAccountContAffiliationsDeltaCalculator extends iPhone_Commons_gne.DeltaCalculator {

        public GetAccountContAffiliationsDeltaCalculator(String lastSyncDate) {
            super(lastSyncDate);
        }

        protected override String getDeltaStatus(SObject sObj) {
            if (lastSynchronized == null){ // delta is OFF.
                return null;
            }

            Affiliation_vod__c aff = (Affiliation_vod__c) sObj;
            Datetime created = aff.CreatedDate;
            Datetime lastModified = aff.LastModifiedDate;
            Datetime contactLastModified = aff.To_Contact_vod__r.LastModifiedDate;

            if (created >= lastSynchronized) {
                return STAT_INSERT;     // created AFTER last synchronization.
            }
            else {
                if(lastModified >= lastSynchronized || contactLastModified >= lastSynchronized) {
                    return STAT_UPDATE; // created BEFORE last synchonization but updated AFTER last synchronization.
                }
                else {
                    return STAT_SYNC; // created and updated BEFORE last synchronization (is eXisting = already synchronized).
                }
            }
        }
    }
    
    class GetAccountContactAffiliationsRecord extends iPhone_Commons_gne.DeltaRecord {        	    
		public String ln; 	//To_Contact_vod__r.LastName,
		public String p2; 	//To_Contact_vod__r.Secondary_Phone_gne__c,
		public String fx; 	//To_Contact_vod__r.Fax,
		public String z4; 	//To_Contact_vod__r.Zip_4_gne__c,
		public String ar; 	//Role_vod__c Affiliated with,
		public String fid;  //From_Account_vod__c,
		public String x2; 	//To_Contact_vod__r.Secondary_ext_gne__c,
		public String ct; 	//To_Contact_vod__r.MailingCity,
		public String xt; 	//To_Contact_vod__r.Ext_gne__c,
		public String tid;  //To_Contact_vod__c,
		public String ty; 	//To_Contact_vod__r.Contact_Type_gne__c,
		public String e2; 	//To_Contact_vod__r.Secondary_Email_gne__c,
		public String ci; 	//To_Contact_vod__r.CreatedById,
		public String a1; 	//To_Contact_vod__r.MailingStreet,
		public String mdi; 	//To_Contact_vod__r.iPhone_Request_Id_gne__c,
		public String st; 	//To_Contact_vod__r.MailingState,
		public String zp; 	//To_Contact_vod__r.MailingPostalCode,
		public String em; 	//To_Contact_vod__r.Email,
		public String emailOptOut; //To_Contact_vod__r.Has_Opted_Out_gne__c,
		public String ph; 	//To_Contact_vod__r.Phone ,
		public String fn; 	//To_Contact_vod__r.FirstName,
		public String cd; 	//To_Contact_vod__r.CreatedDate,
		public String nm;   //To_Contact_vod__r.Name
		public String www;  //To_Contact_vod__r.Website_gne__c
		public String lni;  //To_Contact_vod__r.LinkedIn_gne__c
		public String fpmt;	//To_Contact_vod__r.Type_gne__c
		public String twr;  //To_Contact_vod__r.Twitter_gne__c
		public String pr;   //Primary_gne__c
		public String fpmpr;//Primary_fpm_gne__c
		public String mb;	//Active for my brand
		public String ia;  //To_Contact_vod__r.IsPersonAccount
		public String ca;  //To_Contact_vod__r.AccountId
		public String aft; //Affiliation_Type_gne__c
        public String inf; //Influence_vod__c
        public String cm; //Comments_vod__c
        public String pt; //To_Contact_vod__r.Professional_Type_2_frm_gne__c
        public String ac; // Active
	
	    public GetAccountContactAffiliationsRecord(Affiliation_vod__c affiliation, String myBrandFieldApiName) {
		    this.id  = iPhone_StringUtil.getString(affiliation.Id);
			this.ln  = iPhone_StringUtil.getString(affiliation.To_Contact_vod__r.LastName);
			this.p2  = iPhone_StringUtil.getString(affiliation.To_Contact_vod__r.Secondary_Phone_gne__c);
			this.fx  = iPhone_StringUtil.getString(affiliation.To_Contact_vod__r.Fax);
			this.z4  = iPhone_StringUtil.getString(affiliation.To_Contact_vod__r.zip_4_gne__c);
			this.ar  = iPhone_StringUtil.getString(affiliation.Role_vod__c);
			this.fid = iPhone_StringUtil.getString(affiliation.From_Account_vod__c);
			this.x2  = iPhone_StringUtil.getString(affiliation.To_Contact_vod__r.Secondary_ext_gne__c);
			this.ct  = iPhone_StringUtil.getString(affiliation.To_Contact_vod__r.MailingCity);
			this.xt  = iPhone_StringUtil.getString(affiliation.To_Contact_vod__r.ext_gne__c);
			this.tid = iPhone_StringUtil.getString(affiliation.To_Contact_vod__c);
			this.ty  = iPhone_StringUtil.getString(affiliation.To_Contact_vod__r.Contact_Type_gne__c);
			this.e2  = iPhone_StringUtil.getString(affiliation.To_Contact_vod__r.Secondary_Email_gne__c);
			this.ci  = iPhone_StringUtil.getString(affiliation.To_Contact_vod__r.CreatedById);
			this.a1  = iPhone_StringUtil.getString(affiliation.To_Contact_vod__r.MailingStreet);
			this.mdi = iPhone_StringUtil.getString(affiliation.To_Contact_vod__r.iPhone_Request_Id_gne__c);
			this.st  = iPhone_StringUtil.getString(affiliation.To_Contact_vod__r.MailingState);
			this.zp  = iPhone_StringUtil.getString(affiliation.To_Contact_vod__r.MailingPostalCode);
			this.em  = iPhone_StringUtil.getString(affiliation.To_Contact_vod__r.email);
			this.emailOptOut = iPhone_StringUtil.getString(affiliation.To_Contact_vod__r.Has_Opted_Out_gne__c);
			this.ph  = iPhone_StringUtil.getString(affiliation.To_Contact_vod__r.phone);
			this.fn  = iPhone_StringUtil.getString(affiliation.To_Contact_vod__r.firstname);
			this.cd  = iPhone_StringUtil.getString(affiliation.To_Contact_vod__r.CreatedDate);  	
			this.nm  = iPhone_StringUtil.getString(affiliation.To_Contact_vod__r.Name);
			this.www = iPhone_StringUtil.getString(affiliation.To_Contact_vod__r.Website_gne__c);
			this.lni = iPhone_StringUtil.getString(affiliation.To_Contact_vod__r.LinkedIn_gne__c);
			this.fpmt = iPhone_StringUtil.getString(affiliation.To_Contact_vod__r.Type_gne__c);
			this.twr = iPhone_StringUtil.getString(affiliation.To_Contact_vod__r.Twitter_gne__c);
			this.pr  = iPhone_StringUtil.getString(affiliation.Primary_gne__c);
			this.fpmpr  = iPhone_StringUtil.getString(affiliation.Primary_fpm_gne__c);
			this.mb = iPhone_StringUtil.getString(String.isNotBlank(myBrandFieldApiName) ? (Boolean)affiliation.get(myBrandFieldApiName) : null);
			this.ia = iPhone_StringUtil.getString(affiliation.To_Contact_vod__r.IsPersonAccount);
			this.ca = iPhone_StringUtil.getString(affiliation.To_Contact_vod__r.AccountId);
			this.aft = iPhone_StringUtil.getString(affiliation.Affiliation_Type_gne__c);
            this.inf = iPhone_StringUtil.getString(affiliation.Influence_vod__c);
            this.cm = iPhone_StringUtil.getString(affiliation.Comments_vod__c);
            this.pt = iPhone_StringUtil.getString(affiliation.To_Contact_vod__r.Professional_Type_2_frm_gne__c);
            this.ac = iPhone_StringUtil.getString(affiliation.To_Contact_vod__r.Active_gne__c);   
	    }
    }    
}