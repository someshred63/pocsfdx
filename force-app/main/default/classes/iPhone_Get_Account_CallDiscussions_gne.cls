/*********************************************************************************************
*  @author: Sebastian Karczmarski, Roche (contractor)
*  @email: sebastian.karczmarski@contractors.roche.com   
*  Created: 2013-05-24
*  Project: OTR2
*  Description: REST Webservice, returns a list of Call2Discussions for the specified accounts.             
**********************************************************************************************/
@RestResource(urlMapping='/iPhoneGetAccountCallDiscussions/*')
global with sharing class iPhone_Get_Account_CallDiscussions_gne {
	
	@HttpPost 
  global static iPhone_Commons_gne.RestResponse processRequest(String lastSyncDate, String unixId, List<String> accountIds, Boolean enhDelta, String otrVersion) {  	
  	return iPhone_Commons_gne.buildResponse(
    		new GetAccountCallDiscussionsResponseBuilder(), 
    		new iPhone_Commons_gne.DefaultDeltaArgs(lastSyncDate, unixId, accountIds, enhDelta, otrVersion)    		
  	);     	    	 
  }

  class GetAccountCallDiscussionsResponseBuilder extends iPhone_Commons_gne.DeltaRecordsResponseBuilder {
  													
  	protected override List<SObject> selectSObjects(iPhone_Commons_gne.DeltaArgs args) {
  		return args.isEnhancedDelta() ? iPhone_DeltaDAO.getCallDiscussionsByAccountIds(args.accountIds, args.getLastSyncDate()) : iPhone_DAO.getCallDiscussionsByAccountIds(args.accountIds);      
  	} 	

  	protected override iPhone_Commons_gne.DeltaRecord getAsRecord(SObject sObj) {
  		return new GetAccountCallDiscussionsRecord((Call2_Discussion_vod__c)sObj);
  	}
  }

  class GetAccountCallDiscussionsRecord extends iPhone_Commons_gne.DeltaRecord {
		public String pd;  // Call2_Discussion_vod__c.Product_vod__c
		public String ps;  // Call2_Discussion_vod__c.Product_Strategy_vod__c
		public String pt;  // Call2_Discussion_vod__c.Product_Tactic_vod__c
		public String iid; // Call2_Discussion_vod__c.Call2_vod__c
		public String mo;  // Call2_Discussion_vod__c.Molecule_gne__c
		public String mt;  // Call2_Discussion_vod__c.Topic_gne__c
		public String mi;  // Call2_Discussion_vod__c.Current_Issue_gne__c
		public String ma;  // Call2_Discussion_vod__c.Answer_gne__c
		public String mq;  // Call2_Discussion_vod__c.Question_gne__c
		public String np;  // Call2_Discussion_vod__c.Number_Of_Patients_Impacted_gne__c
		public String ac;  // Call2_Discussion_vod__c.Activity_gne__c
		public String cu;  // Call2_Discussion_vod__c.Event_Curriculum_gne__c
		public String er;  // Call2_Discussion_vod__c.Event_gne__c
		public String at;  // Call2_Discussion_vod__c.Account_Tactic_vod__c		
		public String rea; // Call2_Discussion_vod__c.Reaction_gne__c
	    public String reas;     // Call2_Discussion_vod__c.Reason_gne__c
		public String dp;  // Call2_Discussion_vod__c.Detail_Priority_gne__c
		public String ats;  // Call2_Discussion_vod__c.Activity_Time_Spent_gne__c
		public String obs;  // Call2_Discussion_vod__c.Observation_gne__c
		public String mbo;  // Call2_Discussion_vod__c.PREP_MBO_gne__c
		public String frmtt;  // Call2_Discussion_vod__c.FRM_Triaged_To_gne__c
		public Integer frmpi;  // Call2_Discussion_vod__c.FRM_Patients_Impacted_gne__c
		public Boolean frmie;  // Call2_Discussion_vod__c.FRM_Issue_entered_into_ASMI_gne__c
		public String frmdu;  // Call2_Discussion_vod__c.FRM_Deck_Used_gne__c
		public String frmst; // Call2_Discussion_vod__c .FRM_Issue_Status__c
		public String dc;  // Call2_Discussion_vod__c.Decision_Cycle_gne__c
		public String agrp; // Call2_Discussion_vod__c.Attendee_Group_gne__c
		public String noa;  // Call2_Discussion_vod__c.Number_of_Attendees_gne__c
   		public String str; // Call2_Discussion_vod__c.Speaker_Training_gne__c;
   		public String npg;  // Call2_Discussion_vod__c.Non_provider_Group__c;
   		public String pjo; // Call2_Discussion_vod__c.Patient_Journey_F2F_or_Virtual__c;
   		public String inbr; // Call2_Discussion_vod__c.Patient_Interaction_F2F_or_Virtual__c;
      	public String crmmo; //Call2_Discussion_vod__c.CRM_Meeting_Objective__c
        public Boolean om; //Call2_Discussion_vod__c.CRM_Objectives_Met__c
        public String crmt;//Call2_Discussion_vod__c.CRM_Tactic__c
        public String crmw;//Call2_Discussion_vod__c.CRM_When__c
        public String imp;//Call2_Discussion_vod__c.CRM_Impact__c
        public String crmmm;//Call2_Discussion_vod__c.CRM_Marketing_Material__c
        public String util;//Call2_Discussion_vod__c.CRM_Value__c
	              
		public GetAccountCallDiscussionsRecord(Call2_Discussion_vod__c callDiscussion) {
			this.id	 = callDiscussion.Id;
			this.pd	 = iPhone_StringUtil.getString(callDiscussion.Product_vod__c);
			this.ps	 = iPhone_StringUtil.getString(callDiscussion.Product_Strategy_vod__c);
			this.pt	 = iPhone_StringUtil.getString(callDiscussion.Product_Tactic_vod__c);
			this.iid = callDiscussion.Call2_vod__c;
			this.mo	 = iPhone_StringUtil.getString(callDiscussion.Molecule_gne__c);
			this.mt	 = iPhone_StringUtil.getString(callDiscussion.Topic_gne__c);
			this.mi	 = iPhone_StringUtil.getString(callDiscussion.Current_Issue_gne__c);
			this.ma	 = iPhone_StringUtil.getString(callDiscussion.Answer_gne__c);
			this.mq	 = iPhone_StringUtil.getString(callDiscussion.Question_gne__c);
			this.np	 = iPhone_StringUtil.getString(callDiscussion.Number_Of_Patients_Impacted_gne__c);
			this.ac	 = iPhone_StringUtil.getString(callDiscussion.Activity_gne__c);
			this.cu	 = iPhone_StringUtil.getString(callDiscussion.Event_Curriculum_gne__c);
			this.er	 = iPhone_StringUtil.getString(callDiscussion.Event_gne__c);
			this.at	 = iPhone_StringUtil.getString(callDiscussion.Account_Tactic_vod__c);	
			this.rea = iPhone_StringUtil.getString(callDiscussion.Reaction_gne__c);
			this.reas = iPhone_StringUtil.getString(callDiscussion.Reason_gne__c);
			this.dp	 = iPhone_StringUtil.getString(callDiscussion.Detail_Priority_gne__c);
			this.ats = iPhone_StringUtil.getString(callDiscussion.Activity_Time_Spent_gne__c);
			this.obs = iPhone_StringUtil.getString(callDiscussion.Observation_gne__c);
			this.mbo = iPhone_StringUtil.getString(callDiscussion.PREP_MBO_gne__c);
			this.frmtt = iPhone_StringUtil.getString(callDiscussion.FRM_Triaged_To_gne__c);
			this.frmpi = callDiscussion.FRM_Patients_Impacted_gne__c!=null ? callDiscussion.FRM_Patients_Impacted_gne__c.intValue() : null;
			this.frmie = callDiscussion.FRM_Issue_entered_into_ASMI_gne__c;
			this.frmdu = iPhone_StringUtil.getString(callDiscussion.FRM_Deck_Used_gne__c);
			this.frmst = iPhone_StringUtil.getString(callDiscussion.FRM_Issue_Status__c);
			this.dc = iPhone_StringUtil.getString(callDiscussion.Decision_Cycle_gne__c);
			this.agrp = iPhone_StringUtil.getString(callDiscussion.Attendee_Group_gne__c);
			this.noa = iPhone_StringUtil.getString(callDiscussion.Number_of_Attendees_gne__c);
      		this.str = iPhone_StringUtil.getString(callDiscussion.Speaker_Training_gne__c);
      		this.npg = iPhone_StringUtil.getString(callDiscussion.Non_provider_Group__c);
      		this.pjo = iPhone_StringUtil.getString(callDiscussion.Patient_Journey_F2F_or_Virtual__c);
      		this.inbr = iPhone_StringUtil.getString(callDiscussion.Patient_Interaction_F2F_or_Virtual__c);
            this.crmmo = iPhone_StringUtil.getString(callDiscussion.CRM_Meeting_Objective__c); 
            this.om = callDiscussion.CRM_Objectives_Met__c; 
            this.crmt = iPhone_StringUtil.getString(callDiscussion.CRM_Tactic__c);
            this.crmw = iPhone_StringUtil.getString(callDiscussion.CRM_When__c);
            this.imp = iPhone_StringUtil.getString(callDiscussion.CRM_Impact__c);
            this.crmmm = iPhone_StringUtil.getString(callDiscussion.CRM_Marketing_Material__c);
            this.util = iPhone_StringUtil.getString(callDiscussion.CRM_Value__c);
		}
  }
}