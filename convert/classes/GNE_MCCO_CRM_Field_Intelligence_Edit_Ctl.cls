public with sharing class GNE_MCCO_CRM_Field_Intelligence_Edit_Ctl extends GNE_MCCO_CRM_Survey_Util {
    
    private String fiId { get; set; }
    public String retUrl { get; private set; }
    public String viewId { get; private set; }
    
    public GNE_MCCO_CRM_Field_Intelligence__c fieldIntelligenceObject { get; set; }
    private List<GNE_MCCO_CRM_Field_Intelligence_Answer__c> answerList { get; set; }
    public GNE_MCCO_CRM_Survey__c surveyObject { get; set; }
    private List<GNE_MCCO_CRM_Survey_Question__c> questionsList { get; set; }
    private List<GNE_MCCO_CRM_Survey_Group__c> groupsList { get; set; }
    
    public SurveyWrapper survey { get; private set; }
    public String surveyJson { get; private set; }

    public String iconBase64 { get; private set; }
    
    public Boolean isEditable { get; private set; }
    public Boolean isSubmitted { get; private set; }
    
    public String userTimeZone { get; private set; }

    public GNE_MCCO_CRM_Field_Intelligence_Edit_Ctl() {
        
        isEditable = false;
        isSubmitted = false;
        
        userTimeZone = String.valueOf(UserInfo.getTimeZone());
        
        iconBase64 = GNE_MCCO_CRM_Util.getDocumentBase64('GNE_MCCO_CRM_Survey_Builder_Icon');
        
        fiId = (ApexPages.currentPage().getParameters().get('id') != null && ApexPages.currentPage().getParameters().get('id') != '') ? ApexPages.currentPage().getParameters().get('id') : null;
        retUrl = (ApexPages.currentPage().getParameters().get('retUrl') != null && ApexPages.currentPage().getParameters().get('retUrl') != '') ? ApexPages.currentPage().getParameters().get('retUrl') : null;
        viewId = (ApexPages.currentPage().getParameters().get('view') != null && ApexPages.currentPage().getParameters().get('view') != '') ? ApexPages.currentPage().getParameters().get('view') : null;
        
        try {
            	
        	// FieldIntelligenceObject
        	fieldIntelligenceObject = [SELECT Id, Name, Account_gne__c, Available_gne__c, Comment_gne__c, CreatedById, Previous_Status__c, Survey_gne__c, Survey_Status_gne__c, Title_gne__c, User_gne__c FROM GNE_MCCO_CRM_Field_Intelligence__c WHERE Id = :fiId];
				
			// Field Inelligence Answers
			answerList = [SELECT Answer_gne__c, Conditional_Answer_gne__c, Group_Set_gne__c, MCCO_CRM_Survey_Group_gne__c, Field_Intelligence_gne__c, Survey_Question_gne__c, Survey_Question_gne__r.Group_gne__c FROM GNE_MCCO_CRM_Field_Intelligence_Answer__c WHERE Field_Intelligence_gne__c = :fiId];
				
            // SurveyObject with Questions and Groups
            surveyObject = [SELECT Id, Name, Close_Survey_gne__c, Account_Ids_gne__c, Ready_To_Use_gne__c, Record_Type_gne__c, Territories_gne__c, Title_gne__c, Status_gne__c, Notification_gne__c, CreatedBy.Id, CreatedBy.Name, CreatedDate, Requested_By_gne__r.Id, Requested_By_gne__r.Name, LastModifiedBy.Id, LastModifiedBy.Name, LastModifiedDate, Assignment_Mode_gne__c FROM GNE_MCCO_CRM_Survey__c WHERE Id = :fieldIntelligenceObject.Survey_gne__c LIMIT 1];
            
			// QuestionsList
            questionsList = [SELECT Id, Name, Conditional_Help_Text_gne__c, Group_gne__c, Help_Text_gne__c, Order_gne__c, Required_gne__c, Question_gne__c, Type_gne__c, Values_gne__c FROM GNE_MCCO_CRM_Survey_Question__c WHERE Survey_gne__c = :fieldIntelligenceObject.Survey_gne__c];

            // GroupsList
            groupsList = [SELECT Id, Name, Order_gne__c, Title_gne__c FROM GNE_MCCO_CRM_Survey_Group__c WHERE Survey_gne__c = :fieldIntelligenceObject.Survey_gne__c];
                
            // Create Wrapper From Objects
            survey = new SurveyWrapper();
            survey = survey.createWrapperFromObjects(surveyObject, questionsList, groupsList, answerList);
            surveyJson = JSON.serializePretty(survey);
            	
            if(!surveyObject.Close_Survey_gne__c && surveyObject.Ready_To_Use_gne__c && questionsList.size() > 0 && fieldIntelligenceObject.User_gne__c == UserInfo.getUserId()) {
                isEditable = true;
            }
            
            if(fieldIntelligenceObject.Survey_Status_gne__c == 'Submitted') {
            	isSubmitted = true;
            }
            
        } catch(Exception ex) {
            System.debug(Logginglevel.ERROR, ex.getMessage());
        }
        
    }
    
    public PageReference checkIfFieldIntelligenceCanBeEdit() {
        if(!isEditable) {
            PageReference pageRef;
            pageRef = new PageReference('/apex/GNE_MCCO_CRM_Field_Intelligence_Det');
                        
            pageref.getParameters().put('id', fiId);
            pageref.getParameters().put('msg', 'This survey is not editable.');
            if(String.isNotBlank(retUrl)) {
                pageref.getParameters().put('retUrl', retUrl);  
            }
            
            pageRef.setRedirect(true);
            return pageRef;
        } else {
            return null;
        }
    }
    
    @RemoteAction
    public static Map<String, String> save(String fiId, String answersJson, String fisToDeleteJson, Boolean inProgress) {
        Map<String, String> result = new Map<String, String>();
        Savepoint sp = Database.setSavepoint();
        
        try {
        	
        	List<FieldIntelligenceWrapper> fieldIntelligenceWrapperList = (List<FieldIntelligenceWrapper>)JSON.deserialize(answersJson, List<FieldIntelligenceWrapper>.class);
        	List<String> fieldIntelligencesToDeleteList = (List<String>)JSON.deserialize(fisToDeleteJson, List<String>.class);
        	GNE_MCCO_CRM_Field_Intelligence__c fieldIntelligence = [SELECT Survey_Status_gne__c, Previous_Status__c FROM GNE_MCCO_CRM_Field_Intelligence__c WHERE Id = :fiId];
        	List<GNE_MCCO_CRM_Field_Intelligence_Answer__c> listToUpsert = new List<GNE_MCCO_CRM_Field_Intelligence_Answer__c>();
        	
        	for(FieldIntelligenceWrapper fieldIntelligenceWrapper : fieldIntelligenceWrapperList) {

		    	if(fieldIntelligenceWrapper.Type == 'group') {
		    		for(FieldIntelligenceWrapper fieldIntelligenceChild : fieldIntelligenceWrapper.Elements) {
		    			listToUpsert.add(convertToObject(fieldIntelligenceChild, fiId));
		    		}
		    	} else {
		    		listToUpsert.add(convertToObject(fieldIntelligenceWrapper, fiId));
		    	}
    	
        	}
        	
        	for(GNE_MCCO_CRM_Field_Intelligence_Answer__c fi : listToUpsert) {
        		System.debug(fi);
        	}
        	
        	if(inProgress) {
        		fieldIntelligence.Survey_Status_gne__c = 'In Progress';
        	} else {
        		fieldIntelligence.Survey_Status_gne__c = 'Submitted';
        	}
        	
        	if(fieldIntelligencesToDeleteList.size() > 0) {
        		List<GNE_MCCO_CRM_Field_Intelligence_Answer__c> fisToDelete = [SELECT Id FROM GNE_MCCO_CRM_Field_Intelligence_Answer__c WHERE Id = :fieldIntelligencesToDeleteList];
        		delete fisToDelete;
        	}
        	
        	update fieldIntelligence;
        	upsert listToUpsert;
            
            result.put('status', 'OK');
        } catch(Exception ex) {
            result.put('status', 'ERROR');
            result.put('message', ex.getMessage());
        }
        
        return result;
    }
    
    public static GNE_MCCO_CRM_Field_Intelligence_Answer__c convertToObject(FieldIntelligenceWrapper wrapper, String fiId) {
    	GNE_MCCO_CRM_Field_Intelligence_Answer__c result = new GNE_MCCO_CRM_Field_Intelligence_Answer__c();
	
		if(wrapper.Type == 'multipicklist') {
			if(wrapper.Picklist != null) {
				String tmpAnwser = '';
				for(String s : wrapper.Picklist) {
					if(!String.isEmpty(s)) {
						tmpAnwser += s + ';;;';
					}
				}
				tmpAnwser = tmpAnwser.removeEnd(';;;');
				result.Answer_gne__c 		= tmpAnwser;
			} else {
				result.Answer_gne__c 		= null;
			}
		} else {
			result.Answer_gne__c 			= wrapper.Answer;
		}
		
		if(!String.isEmpty(wrapper.Id)) {
			result.Id 						= wrapper.Id;
		} else {
			result.Field_Intelligence_gne__c = fiId;
			result.MCCO_CRM_Survey_Group_gne__c = wrapper.GroupId;
			result.Survey_Question_gne__c 		= wrapper.QuestionId;
		}
				
		result.Conditional_Answer_gne__c 	= wrapper.Conditional;
		result.Group_Set_gne__c				= wrapper.GroupSet;
	
    	return result;
    }
    
}