/************************************************************
*  @author: Michal Hrycenko, Roche
*  Date: 2012-12-10
*  Description: This is a extension controller for GNE_SFA2_Edit_Servey_Layout Page
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public without sharing class GNE_SFA2_Edit_Survey_Layout_Ext {

    private Survey_gne__c survey {get; set;}                                                                          // current survey
    public String inputTextStyle {get; set;}                                                                          // inputText style used to validate Number Type answers
    public List<String> categoriesList {get; set;}
    public List<Survey_Response_gne__c> surveyResponsesList {get; set;}
    public Map<String, List<ViewResponsesWrapper>> responsesByCategoryMap {get; set;}
    public List<ViewResponsesWrapper> viewResponsesWrappers {get; set;}                                               // list for all survey responses
    private SFA2_Configuration_Object_gne__c pageConfiguration;     
    public Boolean isReadOnly {get; private set;}

    public GNE_SFA2_Edit_Survey_Layout_Ext(ApexPages.StandardController controller) { }
    
    public PageReference init() {
        pageConfiguration = GNE_SFA2_Util.getListPageConfiguration('Survey_gne__c');         
        // Get Survey From DB
        try{
            survey = [SELECT Id, Account__c, Contact_gne__c, Product_Metrics_vod__c, Questionnaire_gne__c, Questionnaire_gne__r.RecordType.Name, Survey_Status_gne__c FROM Survey_gne__c WHERE Id =: ApexPages.currentPage().getParameters().get('Id') limit 1];
        } catch (System.QueryException ex){
            PageReference pageref = new PageReference('/apex/GNE_SFA2_Exception_Layout');
            pageref.setredirect(true);
            System.debug('pageref: '+pageref);
            pageref.getParameters().put('ex', 'Record not found or Id parameter missing!');
            return pageref;
        }
        
         // Get Servey Response From DB
        surveyResponsesList = [SELECT Id, Category_gne__c, Free_Text_gne__c, Help_Text_gne__c, Labels_gne__c, Maximum_Score_gne__c, Minimum_Score_gne__c, Multiple_Responses_gne__c, Position_gne__c, Response_Score_gne__c, Selected_Label_gne__c, Selected_Values_gne__c, Survey_gne__r.Survey_Status_gne__c, Title_gne__c, Type_gne__c, Values_gne__c FROM Survey_Response_gne__c WHERE Survey_gne__c =: survey.Id ORDER BY Position_gne__c];
        isReadOnly = getAssesmentReadOnlyByMCCOTeamsShared();
        
        return null;
    }

    public String getActiveMenuItem() {
       String result = '';
        if(pageConfiguration != null && pageConfiguration.Attributes_gne__c!=null && pageConfiguration.Attributes_gne__c.contains('activeMenuItem')){
        result = pageConfiguration.Attributes_gne__c.substringBetween('activeMenuItem=',';');
        }
        return result;
    }
    
    public List<String> getCategories() {
        // Create Responses Cetegory List
        categoriesList = new List<String>();
        Boolean categoryOne = false;
        Set<String> categoriesSet = new Set<String>();
        for(Survey_Response_gne__c s : surveyResponsesList) {
            if(s.Category_gne__c == null || s.Category_gne__c == '') {
                categoryOne = true;
            } else {
                categoriesSet.add(s.Category_gne__c);
            }
        }
        categoriesList.addAll(categoriesSet);
        categoriesList.sort();
        if( categoryOne ) {
        	if( categoriesList.size() == 0 ) {
        		categoriesList.add( '1' );
        	} else {
        		categoriesList.add( 0, '1' );
        	}
        }
        return categoriesList;
    }
    
    private List<SelectOption> getAnswersToSelectOption(String values, String labels) {
    	// Prepare Labels List
        List<String> labelsList = new List<String>();
        if(labels != null && labels != '') {
            labelsList = labels.split(',', 0);
        } else if(values != null && values != '') {
            labelsList = values.split(',', 0); 
        }
        
        // Prepare Select Option List
        List<SelectOption> selectOptions = new List<SelectOption>();
        for(Integer i = 0; i < labelsList.size(); i++) {
           selectOptions.add( new SelectOption( String.valueOf(i), labelsList[i].trim() ) );
        }
        return selectOptions;
    }
    
    private Map<String, String> getLabelsMap(String values, String labels) {
        // Prepare Labels List
        List<String> labelsList = new List<String>();
        if(labels != null && labels != '') {
            labelsList = labels.split(',', 0);
        } else if(values != null && values != '') {
            labelsList = values.split(',', 0); 
        }
        
        // Prepare Labels Map
        Map<String, String> labelsMap = new Map<String, String>();
        for(Integer i = 0; i < labelsList.size(); i++) {
           labelsMap.put( String.valueOf(i), labelsList[i].trim() );
        }
        return labelsMap;
    }
    
    public Map<String, List<ViewResponsesWrapper>> getAllResponsesByCategory() {
        responsesByCategoryMap = new Map<String, List<ViewResponsesWrapper>>();
        for(String categor : categoriesList) {
            viewResponsesWrappers = new List<ViewResponsesWrapper>();
            for(Survey_Response_gne__c surveyResponse : surveyResponsesList) {
                if((surveyResponse.Category_gne__c == null || surveyResponse.Category_gne__c == '') && categor == '1') {
                    // Prepare Answer To Select Options
                    List<SelectOption> answersList = getAnswersToSelectOption(surveyResponse.Values_gne__c, surveyResponse.Labels_gne__c);
                    //Prepare Labels Map
                    Map<String, String> labelsMap = getLabelsMap(surveyResponse.Values_gne__c, surveyResponse.Labels_gne__c);
                    // Prepare View Responses
                    viewResponsesWrappers.add( new ViewResponsesWrapper(surveyResponse, answersList, labelsMap) );
                } else if( surveyResponse.Category_gne__c != null && surveyResponse.Category_gne__c.compareTo(categor) == 0 ) {
                    // Prepare Answer To Select Options
                    List<SelectOption> answersList = getAnswersToSelectOption(surveyResponse.Values_gne__c, surveyResponse.Labels_gne__c);
                    //Prepare Labels Map
                    Map<String, String> labelsMap = getLabelsMap(surveyResponse.Values_gne__c, surveyResponse.Labels_gne__c);
                    // Prepare View Responses
                    viewResponsesWrappers.add( new ViewResponsesWrapper(surveyResponse, answersList, labelsMap) );
                } 
            }
            responsesByCategoryMap.put(categor, viewResponsesWrappers);
        }
        return responsesByCategoryMap;
    }
    
    public Boolean getShowSaveButton() {
        return survey.Survey_Status_gne__c != 'Closed';
    }
    
    public Boolean getShowAnalyzeButton() {
        String profileName = GNE_SFA2_Util.getCurrentUserProfileName();
        Pattern p = Pattern.compile('^GNE-MCCO-AM$|^GNE-MCCO-FRM-\\wFRM$|^GNE-MCCO-FRM-\\wFRM-MANAGER$|^GNE-MEDAFFAIRS-MCL$|^GNE-MEDAFFAIRS-MCL-MANAGER$');
        
        if ((profileName != null && profileName.toUpperCase().contains('GNE-SFA')) || (profileName != null && p.matcher(profileName.toUpperCase()).matches())) {
            return false;
        } else {
            return true;
        }
    }
    
     private Boolean getAssesmentReadOnlyByMCCOTeamsShared(){
        Boolean result = false;
        String recordTypeName = 'MCCO Teams - Shared';
         
        if (survey.Questionnaire_gne__c != null && survey.Questionnaire_gne__r.RecordTypeId != null 
            && (survey.Questionnaire_gne__r.RecordType.Name == recordTypeName)){
            Set<String> profilesWithReadOnlyView = new Set<String>{'GNE-MEDAFFAIRS-MCL', 'GNE-MEDAFFAIRS-MCL-MANAGER'};             
            String profileName = GNE_SFA2_Util.getCurrentUserProfileName();
            if (profileName != null && profilesWithReadOnlyView.contains(profileName.toUpperCase())){
                result = true;
            }
        }
        return result;
    }
    
    public PageReference saveSurveyClick() {
        Boolean errorMessage = false;
        List<Survey_Response_gne__c> surveyResponsesToSaveList = new List<Survey_Response_gne__c>();
        for(String categor : categoriesList) {
            for(ViewResponsesWrapper vrw : responsesByCategoryMap.get(categor)) {
                if(vrw.surveyResponse.Type_gne__c == 'Numeric' && vrw.surveyResponse.Selected_Values_gne__c.isNumeric()) {
                    Decimal numericDecimalValue = Decimal.valueOf(vrw.surveyResponse.Selected_Values_gne__c);
                    if((numericDecimalValue >= vrw.surveyResponse.Minimum_Score_gne__c) && (numericDecimalValue <= vrw.surveyResponse.Maximum_Score_gne__c)) {
                        vrw.surveyResponse.Response_Score_gne__c = numericDecimalValue;
                        vrw.surveyResponse.Selected_Label_gne__c = '';
                        vrw.surveyResponse.Selected_Values_gne__c = '';
                        surveyResponsesToSaveList.add(vrw.surveyResponse);
                    } else {
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Response \'' + vrw.surveyResponse.Title_gne__c + '\' is outside the allowed value range.'));
                        vrw.surveyResponse.Selected_Values_gne__c += 'errorMessage';
                        errorMessage = true;
                    }
                } else if(vrw.surveyResponse.Type_gne__c == 'Numeric' && !vrw.surveyResponse.Selected_Values_gne__c.isNumeric()) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Response \'' + vrw.surveyResponse.Title_gne__c + '\' is not numeric.'));
                    vrw.surveyResponse.Selected_Values_gne__c += 'errorMessage';
                    errorMessage = true;
                } else if( (vrw.surveyResponse.Type_gne__c == 'Labels and Values' || vrw.surveyResponse.Type_gne__c == 'List of Values') && String.isNotBlank( vrw.surveyResponse.Selected_Values_gne__c ) ) {
                    vrw.surveyResponse.Response_Score_gne__c = 0;	// if no answers or answer without value, Score = 0
                    if(vrw.surveyResponse.Selected_Values_gne__c.contains(',')) {
                        Integer responseScore = 0;
                        List<String> valuesList = vrw.surveyResponse.Selected_Values_gne__c.split(',', 0);
                        for(Integer i = 0; i < valuesList.size(); i++) {
                            if(valuesList[i].isNumeric()) {
                            	responseScore += Integer.valueOf(valuesList[i]);
                            }
                        }
                        vrw.surveyResponse.Response_Score_gne__c = Decimal.valueOf(responseScore);
                    } else {
                    	if(vrw.surveyResponse.Selected_Values_gne__c.isNumeric()) {
                        	vrw.surveyResponse.Response_Score_gne__c = Decimal.valueOf(vrw.surveyResponse.Selected_Values_gne__c);
                    	}
                    }
                    surveyResponsesToSaveList.add(vrw.surveyResponse);
                } else {
                    surveyResponsesToSaveList.add(vrw.surveyResponse);
                }
            }   
        }
        
        if(!errorMessage) {
            try {
                update surveyResponsesToSaveList;
                
                PageReference pageref;
                String retURL = ApexPages.currentPage().getParameters().get('retURL');
                
                if(retURL != null && retURL != '') {
                    pageref = new PageReference(retURL);    
                } else if (survey.Account__c != null) {
                    UserRecordAccess userRecordAccess = GNE_SFA2_Util.getUserRecordAccess(UserInfo.getUserId(), survey.Account__c);
                    if(!userRecordAccess.HasReadAccess) {
                        pageref = new PageReference('/apex/GNE_SFA2_Access_Denied');
                    } else {
                        pageref = new PageReference('/apex/GNE_SFA2_Account_Layout?Id=' + survey.Account__c);
                    }
                } else if (survey.Contact_gne__c != null) {
                    UserRecordAccess userRecordAccess = GNE_SFA2_Util.getUserRecordAccess(UserInfo.getUserId(), survey.Contact_gne__c);
                    if(!userRecordAccess.HasReadAccess) {
                        pageref = new PageReference('/apex/GNE_SFA2_Access_Denied');
                    } else {
                        pageref = new PageReference('/apex/GNE_SFA2_Contact_Layout?Id=' + survey.Contact_gne__c);
                    }
                } else if (survey.Product_Metrics_vod__c != null) {
                    UserRecordAccess userRecordAccess = GNE_SFA2_Util.getUserRecordAccess(UserInfo.getUserId(), survey.Product_Metrics_vod__c);
                    if(!userRecordAccess.HasReadAccess) {
                        pageref = new PageReference('/apex/GNE_SFA2_Access_Denied');
                    } else {
                        pageref = new PageReference('/apex/GNE_SFA2_Brand_Aff_Layout?Id=' + survey.Product_Metrics_vod__c);
                    }
                }
                pageref.setredirect(true);
                return pageref;
            } catch(exception e) {
                if(e.getMessage().contains('INSUFFICIENT_ACCESS_OR_READONLY')) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Insufficent edit access rights for this record.'));
                    return null;
                } else {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
                    return null;
                }          
            }
        } else {
            return null;
        }
    }
    
    public PageReference analyzeClick() {
        PageReference pageref = new PageReference('/apex/GNE_SFA2_SurveyGraph?Id=' + survey.Questionnaire_gne__c);
        pageref.setredirect(true);
        return pageref; 
    }
    
    public PageReference cancelClick() {
        PageReference pageref;
        String retURL = ApexPages.currentPage().getParameters().get('retURL');
        
        if(retURL != null && retURL != '') {
            pageref = new PageReference(retURL);    
        } else if (survey.Account__c != null) {
            UserRecordAccess userRecordAccess = GNE_SFA2_Util.getUserRecordAccess(UserInfo.getUserId(), survey.Account__c);
            if(!userRecordAccess.HasReadAccess) {
                pageref = new PageReference('/apex/GNE_SFA2_Access_Denied');
            } else {
                pageref = new PageReference('/apex/GNE_SFA2_Account_Layout?Id=' + survey.Account__c);
            }
        } else if (survey.Contact_gne__c != null) {
            UserRecordAccess userRecordAccess = GNE_SFA2_Util.getUserRecordAccess(UserInfo.getUserId(), survey.Contact_gne__c);
            if(!userRecordAccess.HasReadAccess) {
                pageref = new PageReference('/apex/GNE_SFA2_Access_Denied');
            } else {
                pageref = new PageReference('/apex/GNE_SFA2_Contact_Layout?Id=' + survey.Contact_gne__c);
            }
        } else if (survey.Product_Metrics_vod__c != null) {
            UserRecordAccess userRecordAccess = GNE_SFA2_Util.getUserRecordAccess(UserInfo.getUserId(), survey.Product_Metrics_vod__c);
            if(!userRecordAccess.HasReadAccess) {
                pageref = new PageReference('/apex/GNE_SFA2_Access_Denied');
            } else {
                pageref = new PageReference('/apex/GNE_SFA2_Brand_Aff_Layout?Id=' + survey.Product_Metrics_vod__c);
            }
        }
        pageref.setredirect(true);
        return pageref; 
    }
   
    //       WRAPPER CLASS 
    public class ViewResponsesWrapper {
        
        public Survey_Response_gne__c surveyResponse {get; set;}
        public String answer {get; set;}
        public List<SelectOption> answersList {get; set;}
        public List<String> multiSelectAnswersList {get; set;}
        public Map<String, String> labelsMap {get; set;}
        public List<String> valuesList {get; set;}
       
        public ViewResponsesWrapper (Survey_Response_gne__c surveyResponse, List<SelectOption> answersList, Map<String, String> labelsMap) {
            this.surveyResponse = surveyResponse;
            this.answersList = answersList;
            this.labelsMap = labelsMap;
            this.valuesList = surveyResponse.Values_gne__c != null ? surveyResponse.Values_gne__c.split(',', 0) : null ;
        }
        
        public String getCurrentAnswer() {
            if(	surveyResponse.Selected_Label_gne__c != null && surveyResponse.Selected_Label_gne__c != '' && surveyResponse.Multiple_Responses_gne__c == false && (surveyResponse.Type_gne__c == 'Labels and Values' || surveyResponse.Type_gne__c == 'List of Values') ) {
                for( SelectOption so : answersList ) {
                	if( so.getLabel() == surveyResponse.Selected_Label_gne__c.trim() ) {
                		answer = so.getValue();
                		if( surveyResponse.Selected_Values_gne__c == null || surveyResponse.Selected_Values_gne__c == '' ) {
                			this.setCurrentAnswer( answer );
                		}
                	}
                }
            } else if(surveyResponse.Free_Text_gne__c != null && surveyResponse.Free_Text_gne__c != '' && surveyResponse.Type_gne__c == 'Free Text') {
                answer = surveyResponse.Free_Text_gne__c;
            } else if(surveyResponse.Response_Score_gne__c != null && surveyResponse.Type_gne__c == 'Numeric') {
                String numericAnswer = String.valueOf(surveyResponse.Response_Score_gne__c);
                numericAnswer = numericAnswer.removeEnd('.00');
                if(surveyResponse.Selected_Values_gne__c != null && surveyResponse.Selected_Values_gne__c.contains('errorMessage')) {
                    answer = surveyResponse.Selected_Values_gne__c.removeEnd('errorMessage');
                } else {
                    answer = numericAnswer;
                }
            }
            return answer;
        }
        
        public List<String> getCurrentMultiSelectAnswers() {
            multiSelectAnswersList = new List<String>();
            if( surveyResponse.Multiple_Responses_gne__c == true ) {
	            if( String.isNotBlank(surveyResponse.Selected_Label_gne__c) ){
					List<String> selectedLabels = surveyResponse.Selected_Label_gne__c.split(',');
					for( String selectedLabel : selectedLabels ){
						for( SelectOption so : answersList ) {
							if (so.getLabel() == selectedLabel){
								multiSelectAnswersList.add( so.getValue() );
								break;
							}
						}
					}
				} else if( String.isNotBlank(surveyResponse.Selected_Values_gne__c) ) {
					for( SelectOption so : answersList ) {
						if( so.getValue() == surveyResponse.Selected_Values_gne__c && so.getLabel() == '' ) {
							multiSelectAnswersList.add( so.getValue() );
							break;
						}
					}
				}
            }
            return multiSelectAnswersList;
        }

        public String getCurrentAnswerFromClosedSurvey() {
            if(surveyResponse.Selected_Label_gne__c != null && surveyResponse.Selected_Label_gne__c != '' && (surveyResponse.Type_gne__c == 'Labels and Values' || surveyResponse.Type_gne__c == 'List of Values')) {
                answer = surveyResponse.Selected_Label_gne__c;
            } else if(surveyResponse.Free_Text_gne__c != null && surveyResponse.Free_Text_gne__c != '') {
                answer = surveyResponse.Free_Text_gne__c;
            } else if(surveyResponse.Response_Score_gne__c != null && surveyResponse.Type_gne__c == 'Numeric') {
                Decimal numericAnswer = surveyResponse.Response_Score_gne__c;
                answer = String.valueOf(numericAnswer);
                answer = answer.removeEnd('.00');
            }
            return answer;
        }
        
        public void setCurrentAnswer(String answer) {
            if(surveyResponse.Type_gne__c == 'Labels and Values' && surveyResponse.Multiple_Responses_gne__c == false) {
                // Set Selected_Values_gne__c
                this.surveyResponse.Selected_Values_gne__c = (answer != null) && (valuesList != null) ? valuesList.get( Integer.valueOf(answer) ) : null;
                // Set Selected_Label_gne__c
                surveyResponse.Selected_Label_gne__c = labelsMap.get(answer);
            } else if(surveyResponse.Type_gne__c == 'List of Values' && surveyResponse.Multiple_Responses_gne__c == false) {
                // Set Selected_Values_gne__c
                this.surveyResponse.Selected_Values_gne__c = (answer != null) && (valuesList != null) ? valuesList.get( Integer.valueOf(answer) ) : null;
                // Set Selected_Label_gne__c
                surveyResponse.Selected_Label_gne__c = labelsMap.get(answer);
            } else if(surveyResponse.Type_gne__c == 'Numeric') {
                // Set Selected_Label_gne__c
                this.surveyResponse.Selected_Values_gne__c = answer;
            } else if(surveyResponse.Type_gne__c == 'Free Text') {
                // Set Free_Text_gne__c
                this.surveyResponse.Free_Text_gne__c = answer;
            }
        }
        
        public void setCurrentMultiSelectAnswers(List<String> multiSelectAnswersList) {
            if(surveyResponse.Type_gne__c == 'Labels and Values' && surveyResponse.Multiple_Responses_gne__c == true) {
                surveyResponse.Selected_Values_gne__c = '';
                surveyResponse.Selected_Label_gne__c = '';
                for(String answer : multiSelectAnswersList) {
                	surveyResponse.Selected_Values_gne__c += valuesList.get( Integer.valueOf(answer) ) + ',';
                	surveyResponse.Selected_Label_gne__c += labelsMap.get(answer) + ',';
                }
                surveyResponse.Selected_Values_gne__c = surveyResponse.Selected_Values_gne__c.removeEnd(',');
                surveyResponse.Selected_Label_gne__c = surveyResponse.Selected_Label_gne__c.removeEnd(',');
            }
        }
        
        public String getMinMaxNumericScore() {
            String result;
            if(surveyResponse.Type_gne__c == 'Numeric') {
                result  = '(' + surveyResponse.Minimum_Score_gne__c + '-' + surveyResponse.Maximum_Score_gne__c + ')';
            }
            return result;
        }
        
        public String getInputStyle() {
            String result = '';
            if(surveyResponse.Selected_Values_gne__c != null && surveyResponse.Selected_Values_gne__c.contains('errorMessage')) {
                result = 'inputError';    
            }
            return result;    
        } 
        
        public String getErrorMessage() {
            String result;
            if(surveyResponse.Selected_Values_gne__c != null && surveyResponse.Selected_Values_gne__c.contains('errorMessage')) {
                answer = surveyResponse.Selected_Values_gne__c.removeEnd('errorMessage');
                if(answer.isNumeric()) {
                    result = 'Outside the allowed value range.';
                } else {
                    result = 'Not numeric.';
                }
            }
            return result;
        }
    }
}