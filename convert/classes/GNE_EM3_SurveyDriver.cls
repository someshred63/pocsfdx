public with sharing class GNE_EM3_SurveyDriver {
	
	ID medicalEventId = ApexPages.currentPage().getParameters().get('id');
	List<Account> actAttendees = new List<Account>();
	List<Speaker_Bureau_Membership_gne__c> sbm = new List<Speaker_Bureau_Membership_gne__c>();
	List<Questionnaire_gne__c> quests = new List<Questionnaire_gne__c>();
	List<Event_Bureaus_gne__c> eventB_list = new List<Event_Bureaus_gne__c>();
	//Selected ActId
	String actId;
	//Debug
	String Test;
	//Selected Bureau Id
	String burId;
	//Bureau Membership Id
	String burMemId;
	//Selected Questionnaire Id
	String questId;
	//Error Condition
	Boolean error_noMemberships = false;
	//Medical Survey Questionnaire RecordType ID
	ID recType;
	//RunTime User
	String userId = userinfo.getUserId();
	//Initial Info - onChange not required
	String initial_act;
	String initial_bureau;
	List<Questionnaire_gne__c> initial_quests = new List<Questionnaire_gne__c>();
	//String Initial Load Boolean
	Boolean initial_load;
	//Error
	Boolean noActive;
	//Id Set for Event_Bureaus
	Set<ID> eventBureaus = new Set<ID>();

	
	public GNE_EM3_SurveyDriver (ApexPages.StandardController stdController) {
		
		//Get RecTypes for Questionnaires
		recType = Schema.SObjectType.Questionnaire_gne__c.getRecordTypeInfosByName().get('Medical Event Survey').getRecordTypeId();
		system.debug('ME Id: '+medicalEventId);
		actAttendees = [select id, Name from Account where id in (select Account_vod__c from Event_Attendee_vod__c where Medical_Event_vod__c =:medicalEventId)];
		system.debug('Act Ids: '+actAttendees);
		eventB_list = [select Speaker_Bureau_gne__c from Event_Bureaus_gne__c where Medical_Event_gne__c=:medicalEventId];
		
		for (Event_Bureaus_gne__c e_x : eventB_list){
			eventBureaus.add(e_x.Speaker_Bureau_gne__c);
		}
		
		
	}
	
	public ID getMedicalEventId () {
		return medicalEventId;
	}
	public Boolean getNoActive() {
		return noActive;
	}
	
	public void Initial_Load() {
		this.initial_load = true;
		system.debug('$$$ I am entering ONLOAD FUNCTION');
		
		//actId = actAttendees[0].Id;
		noActive = true;
		for (Account a_v : actAttendees){
			
			if (noActive)
			sbm = [select Name, Speaker_Bureau_ID_gne__c, Speaker_Bureau_ID_gne__r.Name, id from Speaker_Bureau_Membership_gne__c where Bureau_Member_gne__c =:a_v.Id and (Speaker_Status_gne__c!='Rejected' and Speaker_Status_gne__c!='Removed') and Speaker_Bureau_ID_gne__c in :eventBureaus];
			
			if (sbm.size() > 0){ 
			noActive = false;
			burId = sbm[0].Speaker_Bureau_ID_gne__c;
			actId = a_v.Id;
			break;
			}
	
		}
		
			

		
		List<Survey_gne__c> taken_Surveys = new List<Survey_gne__c>([select Questionnaire_gne__c from Survey_gne__c where OwnerId=:userId and Account__c=:actId and Speaker_Bureau_gne__c =:burId and Questionnaire_gne__r.RecordTypeId=:recType]);
    	Set<ID> s_ids = new Set<ID>();
    	
    	for (Survey_gne__c s_x : taken_Surveys){
    		s_ids.add(s_x.Questionnaire_gne__c);
    	}
    	system.debug('****************The Surveys already taken: '+s_ids);
    	quests = [select id, Category_gne__c, Type_gne__c from Questionnaire_gne__c where ready_for_use_gne__c = true and id in (select Questionnaire_gne__c from questionnaireBureau_gne__c where Speaker_Bureau_gne__c=:burId)and id not in : s_ids and RecordTypeId=:recType order by Category_gne__c];
		
	}
	
	public Boolean getInitial_Load() {
		return this.initial_Load;
	}
	
	public List<SelectOption> getSpeakers() {
		List<SelectOption> options = new List<SelectOption>();
		system.debug('Acountx2: '+actAttendees);
		
		//if (initial_load && actAttendees.size() > 0)
		//actId = actAttendees[0].Id;
		//options.add(new SelectOption('-None Selected-', '-None Selected-'));
		
		for (Account a_x : actAttendees){
			options.add(new SelectOption(a_x.Id, a_x.Name));
		}
		
		system.debug('OPTIONS: '+options);
		return options;
	}
	public Boolean getError_NoMemberships () {
		return error_noMemberships;
	}
	
    public String getactId() {
        return actId;
        }
            
    public void setactId (String a) {  	
        this.actId = a;
        }
    
	public List<SelectOption> getBureaus () {
		List<SelectOption> options = new List<SelectOption>();
		system.debug('Account Ids: '+actId);
		
		if (actId != null && actId != '') {
			String modified = actId.subString(0,15);
			system.debug('NewString: '+modified);
			sbm = [select Name, Speaker_Bureau_ID_gne__c, Speaker_Bureau_ID_gne__r.Name, id from Speaker_Bureau_Membership_gne__c where Bureau_Member_gne__c =:modified and (Speaker_Status_gne__c!='Rejected' and Speaker_Status_gne__c!='Removed')and Speaker_Bureau_ID_gne__c in :eventBureaus];
		}

		//options.add(new SelectOption('-None Selected-', '-None Selected-'));
		
		if (initial_load && sbm.size() > 0)
		burId = sbm[0].Speaker_Bureau_ID_gne__c;		
		
		if (sbm.size() > 0){
			for (Speaker_Bureau_Membership_gne__c s_x : sbm){
				options.add(new SelectOption(s_x.Speaker_Bureau_ID_gne__c, s_x.Speaker_Bureau_ID_gne__r.Name));
			}		
		}
		return options;
		
	} 
    public String getburId() {
        return burId;
        }
            
    public void setburId(String burId) {
    system.debug('BUR ID: '+burId);
    
     if (burId == '000000000000000000'){
		sbm = [select Name, Speaker_Bureau_ID_gne__c, Speaker_Bureau_ID_gne__r.Name, id from Speaker_Bureau_Membership_gne__c where Bureau_Member_gne__c =:actId and (Speaker_Status_gne__c!='Rejected' and Speaker_Status_gne__c!='Removed')];
		if (sbm.size() > 0){
			burId = sbm[0].Speaker_Bureau_ID_gne__c;
			
			List<Survey_gne__c> taken_Surveys = new List<Survey_gne__c>([select Questionnaire_gne__c from Survey_gne__c where OwnerId=:userId and Account__c=:actId and Speaker_Bureau_gne__c =:burId and Questionnaire_gne__r.RecordTypeId=:recType]);
	    	Set<ID> s_ids = new Set<ID>();
	    	
	    	for (Survey_gne__c s_x : taken_Surveys){
	    		s_ids.add(s_x.Questionnaire_gne__c);
	    	}
	    	system.debug('****************The Surveys already taken: '+s_ids);
	    	quests = [select id, Category_gne__c, Type_gne__c from Questionnaire_gne__c where ready_for_use_gne__c = true and id in (select Questionnaire_gne__c from questionnaireBureau_gne__c where Speaker_Bureau_gne__c=:burId)and id not in : s_ids and RecordTypeId=:recType order by Category_gne__c];
		}
     }
        this.burId = burId;
        }	 
            
    public List<Questionnaire_gne__c> getQuests () {
    	system.debug('****************I am in getQuests -ACTID: ' + actId);
    	system.debug('****************I am in getQuests -BURID:' + burId);
    	
    	
    	if (burId != null && burId != '') {
    		
	    	String modified = burId.subString(0,15);
	    	
	    	List<Survey_gne__c> taken_Surveys = new List<Survey_gne__c>([select Questionnaire_gne__c from Survey_gne__c where OwnerId=:userId and Account__c=:actId and Speaker_Bureau_gne__c =:burId and Questionnaire_gne__r.RecordTypeId=:recType]);
	    	Set<ID> s_ids = new Set<ID>();
	    	for (Survey_gne__c s_x : taken_Surveys){
	    		s_ids.add(s_x.Questionnaire_gne__c);
	    	}
	    	system.debug('****************The Surveys already taken: '+s_ids);
	    	quests = [select id, Category_gne__c, Type_gne__c from Questionnaire_gne__c where ready_for_use_gne__c = true and id in (select Questionnaire_gne__c from questionnaireBureau_gne__c where Speaker_Bureau_gne__c=:modified)and id not in : s_ids and RecordTypeId=:recType order by Category_gne__c];
    		system.debug('****************The Questionnaires returned: '+quests);
    	}
    	
    	return quests;
    	
    }
    public String getQuestId () {
    	return questId;
    }
    
    public void setQuestId (String q){
    	this.questid = q;
    }
    
    public pageReference createSurvey () {
    	
    	Questionnaire_gne__c q=[Select q.Category_gne__c, q.Id, 
                           q.Name, q.Show_Questions_Position_gne__c,
                           q.Type_gne__c,
                           (Select Category_gne__c, Help_Text_gne__c, Id, Maximum_Score_gne__c, 
                                   Minimum_Score_gne__c, Position_gne__c, Title_gne__c, 
                                   Type_gne__c, Values_gne__c, Labels_gne__c, Weight_gne__c From Questions__r) 
                           from Questionnaire_gne__c q where q.ID=:questid];
                           
        Survey_gne__c surv=new Survey_gne__c();
        surv.Account__c=actId;
        surv.Type_gne__c = 'Medical Event Survey';
        surv.Medical_Event_gne__c=medicalEventId;
        surv.Speaker_Bureau_gne__c=burId;
        surv.Speaker_Bureau_Membership_gne__c=[select id from Speaker_Bureau_Membership_gne__c where Speaker_Bureau_ID_gne__c =:burId and Bureau_Member_gne__c =:actId limit 1 ].Id;
        surv.Speaker_Bureau_Member_Name_gne__c=actId;
        surv.Questionnaire_gne__c=questid;
        //surv.Title_gne__c = q.Type_gne__c;
        insert surv;
        List<Survey_Response_gne__c> survResps=new List<Survey_Response_gne__c>();
        for(Question_gne__c quest:q.Questions__r){
            Survey_Response_gne__c survResp=new Survey_Response_gne__c();
            survResp.Survey_gne__c=surv.Id;
            survResp.Title_gne__c=quest.Title_gne__c;
            survResp.Help_Text_gne__c = quest.Help_Text_gne__c ;
            survResp.Minimum_Score_gne__c = quest.Minimum_Score_gne__c;
            survResp.Maximum_Score_gne__c = quest.Maximum_Score_gne__c;
            survResp.Weight_gne__c =  quest.Weight_gne__c ;
            survResp.Position_gne__c = quest.Position_gne__c;
            survResp.Category_gne__c = quest.Category_gne__c;
            survResp.Values_gne__c = quest.Values_gne__c;
            survResp.Labels_gne__c = quest.Labels_gne__c;
            survResp.Type_gne__c = quest.Type_gne__c;
            survResp.Question_gne__c=quest.Id;
            survResps.add(survResp);
        }
        insert survResps;                           
                           
       PageReference pageRef = new PageReference('/'+surv.Id+'?retUrl='+burId);                    
                           
       return pageRef;                    
                           
                           
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}