/********************************************************************************************
*  @author: Sebastian Karczmarski, Roche (contractor)
*  @email: sebastian.karczmarski@contractors.roche.com   
*  Created: 2013-05-24
*  Project: OTR2
*  Description: REST Webservice, returns a list of SpeakerBureauMemberships for the specified 
*  accounts.             
*********************************************************************************************/
@RestResource(urlMapping='/iPhoneGetAccountSpeakerBureauMemberships/*')
global with sharing class iPhone_Get_Account_SpeakerBureauMshp_gne {
	
	@HttpPost 
    global static iPhone_Commons_gne.RestResponse processRequest(String lastSyncDate, List<String> accountIds) {    	
    	return iPhone_Commons_gne.buildResponse(
	    		new GetAccountSpeakerBureauMShipResponseBuilder(), 
	    		new iPhone_Commons_gne.DefaultDeltaArgs(lastSyncDate, accountIds)
    	);     	     	    	 
    } 
    
    class GetAccountSpeakerBureauMShipResponseBuilder extends iPhone_Commons_gne.DeltaRecordsResponseBuilder { 
    	    	    	
    	protected override List<SObject> selectSObjects(iPhone_Commons_gne.DeltaArgs args) {
    		return iPhone_DAO.getSpeakerBureauMembershipByAccountIds(args.accountIds);    		  
    	} 	
    	     	 			
    	protected override iPhone_Commons_gne.DeltaRecord getAsRecord(SObject sObj) {
    		return new GetAccountSpeakerBureauMShipRecord((Speaker_Bureau_Membership_gne__c)sObj); 		    		
    	}     	    	
    }
    
    class GetAccountSpeakerBureauMShipRecord extends iPhone_Commons_gne.DeltaRecord {  
		public String ai; // (account id)
		public String sb; // (name)
		public String sc; // (category)
		public String ac; // (contract active)
		public String ss; // (calssification)
		public String nm; // (speaker id)
		public String nd; // (nomination date)
		public String mc; // (meets speaker criteria)
		public String st; // (membership status)
    	public String sy; // (speaker bureau year)
    	public String bt; //Bureau Type
    	public String es; //Exclusion Status
		
		public GetAccountSpeakerBureauMShipRecord(Speaker_Bureau_Membership_gne__c speakerBureauMembership) {			
			this.id = speakerBureauMembership.Id;		
			this.nm = speakerBureauMembership.Name;																					
			this.sb = iPhone_StringUtil.getString(speakerBureauMembership.Speaker_Bureau_ID_gne__r.Name); 
			this.ai = iPhone_StringUtil.getString(speakerBureauMembership.Bureau_Member_gne__c); 		  	
			this.sc = iPhone_StringUtil.getString(speakerBureauMembership.Speaker_Category_gne__c); 		
			this.ac = iPhone_StringUtil.getString(speakerBureauMembership.Contract_Active_gne__c); 			
			this.ss = iPhone_StringUtil.getString(speakerBureauMembership.Speaker_Scope_gne__c);	
			this.nd = iPhone_StringUtil.getStringDate(speakerBureauMembership.Nomination_Date_gne__c);			
			this.mc = iPhone_StringUtil.getString(speakerBureauMembership.Meets_Speaker_Criteria_gne__c);	
			this.st = iPhone_StringUtil.getString(speakerBureauMembership.Speaker_Status_gne__c);
      		this.sy = iPhone_StringUtil.getString(speakerBureauMembership.Speaker_Bureau_ID_gne__r.Speaker_Bureau_Year_gne__c);
      		this.bt = iPhone_StringUtil.getString(speakerBureauMembership.EDM_Bureau_Type_gne__c);
      		this.es = iPhone_StringUtil.getString(speakerBureauMembership.Exclusion_Status_gne__c);
		} 		    	
    }
}