@RestResource(urlMapping='/iPhoneGetAccountContacts/*')
global with sharing class iPhone_Get_Account_Contacts_gne {
	
	@HttpPost 
    global static iPhone_Commons_gne.RestResponse processRequest(String lastSyncDate, List<String> accountIds) {    	
    	return iPhone_Commons_gne.buildResponse(
    		new GetAccountContactsResponseBuilder(), 
    		new iPhone_Commons_gne.DefaultDeltaArgs(lastSyncDate, accountIds)
    	);     	    	 
    } 
              
    class GetAccountContactsResponseBuilder extends iPhone_Commons_gne.DeltaRecordsResponseBuilder {
    											
    	protected override List<SObject> selectSObjects(iPhone_Commons_gne.DeltaArgs args) {
    		return iPhone_DAO.getContactsByAccountIds(args.accountIds);     
    	} 	
    	     	 			
    	protected override iPhone_Commons_gne.DeltaRecord getAsRecord(SObject sObj) {
    		return new GetAccountContactsDetailsRecord((Contact)sObj);    		    		
    	}
    	
    } 
    
    global class GetAccountContactsDetailsRecord extends iPhone_Commons_gne.DeltaRecord {	
    	
    	public String id; // Contact Id
        public String nm; // Name
        public String fn; // First Name
        public String ln; // Last Name
        public String aid; // Account Id
        public String an; // Account Name
        public String tl; // Title
        public String otl; // Other Title
        public String em; // Email
        public String ph; // Phone
        public String cph; // Cell Phone
        public String ac; // Active
        public String ir; // Inactive reason
        public String ia; // Is Person Account
        public String rId; // iPhone Request Id
        public Integer photoHash; // hashcode from Photo_gne__c
        public String photo; // photo, that will be passed in iPhoneManageContact service

        // For FRMs
        public String sa; // Salutation
        public String mnf; // Middle_frm_gne__c
        public String ptf; // Professional_Type_2_frm_gne__c
        public String pn; // Preferred_Name_gne__c
        public Boolean re; // Reimbursement_KOL_frm_gne__c
        public Boolean pmcf; // Primary_Main_Contact_frm_gne__c
        public Boolean dnc; // DO_NOT_CONTACT_gne__c
        public Boolean emoo; // Has_Opted_Out_gne__c
        public String ws; // Website_gne__c
        
        public Boolean afrmat; // AFRM_Additional_Target_frm_gne__c
        public Boolean bfrmat; // BFRM_Additional_Target_frm_gne__c
        public Boolean efrmat; // EFRM_Additional_Target_frm_gne__c
        public Boolean gfrmat; // GFRM_Additional_Target_frm_gne__c
        public Boolean ifrmat; // IFRM_Additional_Target_frm_gne__c
        public Boolean nfrmat; // PFRM_Additional_Target_frm_gne__c
        public Boolean pfrmat; // PFRM_Additional_Target_frm_gne__c
        public Boolean rfrmat; // RFRM_Additional_Target_frm_gne__c
        public Boolean respfrmat; // RESPFRM_Additional_Target_frm_gne__c
        public String afrmsc; // AFRM_Survey_Contact_frm_gne__c
        public String bfrmsc; // BFRM_Survey_Contact_frm_gne__c
        public String efrmsc; // EFRM_Survey_Contact_frm_gne__c
        public String gfrmsc; // GFRM_Survey_Contact_frm_gne__c
        public String ifrmsc; // IFRM_Survey_Contact_frm_gne__c
        public String nfrmsc; // NFRM_Survey_Contact_frm_gne__c
        public String pfrmsc; // PFRM_Survey_Contact_frm_gne__c
        public String rfrmsc; // RFRM_Survey_Contact_frm_gne__c
        public String respfrmsc; // RESPFRM_Survey_Contact_frm_gne__c
        public String cred; // Credentials_gne__c
        public String ex;   // Ext_gne__c
        public String func; // Function_gne__c
        public String rto;  // ReportsToId
        public String rton; //ReportsTo.Name
        public String fax;  //Fax
        public Boolean x340Bc; // X340B_Contact__c
        public String owid; // OwnerId,
        public String owna; // Owner.Name
        public Boolean prcon; // Primary_Contact_gne__c
        public String comtyp; // Communication_Type_gne__c
        public String mstr; //MailingStreet
		public String mstat; //State_Province_gne__c
		public String mcity; //MailingCity
		public String mzip; //MailingPostalCode
		public String mcoun; //MailingCountry
        public String comment;//Comments_frm_gne__c
        public String crbyid; //CreatedById
        public String crbyna; //CreatedBy.Name
        public String lmdbyid; //LastModifiedById
        public String lmbyna; // LastModifiedBy.Name
        public String ofunc;//Function_Other_gne__c
                
        public GetAccountContactsDetailsRecord(Contact contactDetail) {
        	this.id = contactDetail.Id;
            this.nm = contactDetail.Name;
        	this.fn = contactDetail.FirstName;
        	this.ln = contactDetail.LastName;
            this.aid = contactDetail.AccountId;
            this.tl = contactDetail.Title_gne__c;
            this.otl = contactDetail.Title;
        	this.an = contactDetail.Account.Name;
        	this.em = contactDetail.Email;
        	this.ph = contactDetail.Phone;
        	this.cph = contactDetail.Cell_Phone_frm_gne__c;
        	this.ac = iPhone_StringUtil.getString(contactDetail.Active_gne__c);       	      
        	this.ir = contactDetail.Inactive_Reason__c;
        	this.ia = iPhone_StringUtil.getString(contactDetail.IsPersonAccount);
            this.sa = contactDetail.Salutation;
            this.mnf = contactDetail.Middle_frm_gne__c;
            this.ptf = contactDetail.Professional_Type_2_frm_gne__c;
            this.pn = contactDetail.Preferred_Name_gne__c;
            this.re = contactDetail.Reimbursement_KOL_frm_gne__c;
            this.pmcf = contactDetail.Primary_Main_Contact_frm_gne__c;
            this.dnc = contactDetail.DO_NOT_CONTACT_gne__c;
            this.emoo = contactDetail.Has_Opted_Out_gne__c;
            this.ws = contactDetail.Website_gne__c;

            this.afrmat = contactDetail.AFRM_Additional_Target_frm_gne__c;
            this.bfrmat = contactDetail.BFRM_Additional_Target_frm_gne__c;
            this.efrmat = contactDetail.EFRM_Additional_Target_frm_gne__c;
            this.gfrmat = contactDetail.GFRM_Additional_Target_frm_gne__c;
            this.ifrmat = contactDetail.IFRM_Additional_Target_frm_gne__c;
            this.nfrmat = contactDetail.NFRM_Additional_Target_frm_gne__c;
            this.pfrmat = contactDetail.PFRM_Additional_Target_frm_gne__c;
            this.rfrmat = contactDetail.RFRM_Additional_Target_frm_gne__c;
            this.respfrmat = contactDetail.RESPFRM_Additional_Target_frm_gne__c;
            this.afrmsc = contactDetail.AFRM_Survey_Contact_frm_gne__c;
            this.bfrmsc = contactDetail.BFRM_Survey_Contact_frm_gne__c;
            this.efrmsc = contactDetail.EFRM_Survey_Contact_frm_gne__c;
            this.gfrmsc = contactDetail.GFRM_Survey_Contact_frm_gne__c;
            this.ifrmsc = contactDetail.IFRM_Survey_Contact_frm_gne__c;
            this.nfrmsc = contactDetail.NFRM_Survey_Contact_frm_gne__c;
            this.pfrmsc = contactDetail.PFRM_Survey_Contact_frm_gne__c;
            this.rfrmsc = contactDetail.RFRM_Survey_Contact_frm_gne__c;
            this.respfrmsc = contactDetail.RESPFRM_Survey_Contact_frm_gne__c;
            this.rid    = contactDetail.iPhone_Request_Id_gne__c;

            String photo = contactDetail.Photo_gne__c;
            this.photoHash = photo == null ? null : photo.hashCode();
            this.cred = contactDetail.Credentials_gne__c;
            this.ex = contactDetail.Ext_gne__c;
            this.func = contactDetail.Function_gne__c;
            this.rto = contactDetail.ReportsToId;
        	this.rton = contactDetail.ReportsTo.Name;
            this.fax = contactDetail.Fax;
            this.x340Bc = contactDetail.X340B_Contact__c;
            this.owid = contactDetail.OwnerId;
            this.owna = contactDetail.Owner.Name;
            this.prcon = contactDetail.Primary_Contact_gne__c;
            this.comtyp = contactDetail.Communication_Type_gne__c;
            this.mstr = contactDetail.MailingStreet;
            this.mstat = contactDetail.State_Province_gne__c;
			this.mcity = contactDetail.MailingCity;
            this.mzip = contactDetail.MailingPostalCode;
            this.mcoun = contactDetail.MailingCountry;
            this.comment = contactDetail.Comments_frm_gne__c;
            this.crbyid = contactDetail.CreatedById;
            this.crbyna = contactDetail.CreatedBy.Name;
            this.lmdbyid = contactDetail.LastModifiedById;
            this.lmbyna = contactDetail.LastModifiedBy.Name;
            this.ofunc = contactDetail.Function_Other_gne__c;
        }
	}
}