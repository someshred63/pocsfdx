/* 
 * GNE_MCCO_CRM_Edit_Survey_Controller
 *
 * Created By :         Tadeusz Hyzy (tadeusz.hyzy@contractors.roche.com)
 * Last Modified By :   Tadeusz Hyzy (tadeusz.hyzy@contractors.roche.com)
 * Last Modified Date : 01/13/2015
 * 
 */
 
public without sharing class GNE_MCCO_CRM_Edit_Survey_Controller {
    
    public String surveyId { get; private set; }
    
    public Boolean hasSurvey { get; private set; }
    public Boolean hasQuestions { get; private set; }
    
    public Survey_gne__c survey { get; private set; }
    public List<Survey_Response_gne__c> questionList { get; private set; }
    
    private SurveyWrapper surveyWrapper { get; private set; }
    public String surveyWrapperJson { get; private set; }
    public String retUrl { get; set; }
    
    public GNE_MCCO_CRM_Edit_Survey_Controller() {
    	surveyId = (ApexPages.currentPage().getParameters().get('id') != null && ApexPages.currentPage().getParameters().get('id') != '') ? ApexPages.currentPage().getParameters().get('id') : null;
    	retUrl = (ApexPages.currentPage().getParameters().get('retUrl') != null && ApexPages.currentPage().getParameters().get('retUrl') != '') ? ApexPages.currentPage().getParameters().get('retUrl') : ApexPages.currentPage().getHeaders().get('Referer');
    	
    	hasSurvey = false;
    	hasQuestions = false;
    	
    	if(surveyId!=null && !String.isEmpty(surveyId)) {
    		init();
    	} else {
    		hasSurvey = false;
    	}
    	
    }
    
    private void init() {
    	survey 			= getSurvey();
    	questionList 	= getQuestionList();
    	
    	if(survey != null) {
    		hasSurvey = true;
    	}
    	
    	if(questionList != null && !questionList.isEmpty()) {
    		hasQuestions = true;
    	}
    	
    	if(hasSurvey && hasQuestions) {
    		surveyWrapper 		= new SurveyWrapper(questionList);
    		surveyWrapperJson 	= JSON.serializePretty(surveyWrapper);
    	}
    }
    
    private Survey_gne__c getSurvey() {
    	try {
    		return [ SELECT Account__c, Account_Name_gne__c, Category_gne__c, Contact_gne__c, Contact_Name_gne__c, Questionnaire_gne__c, Title_gne__c, Type_gne__c, Survey_Status_gne__c, Version_gne__c FROM Survey_gne__c WHERE Id = :surveyId LIMIT 1 ][0];
    	} catch(Exception ex) {
    		return null;
    	}
    }
        
    private List<Survey_Response_gne__c> getQuestionList() {
    	try {
    		return [ SELECT Selected_Label_gne__c, Selected_Values_gne__c, Response_Score_gne__c, Free_Text_gne__c, Category_gne__c, Help_Text_gne__c, Labels_gne__c, Maximum_Score_gne__c, Minimum_Score_gne__c, Position_gne__c, Title_gne__c, Type_gne__c, Values_gne__c, Multiple_Responses_gne__c FROM Survey_Response_gne__c WHERE Survey_gne__c = :surveyId ];
    	} catch(Exception ex) {
    		return null;
    	}
    }
    
    private class SurveyWrapper {
    	
    	private List<Survey_Response_gne__c> questionList { get; set; }
    	public Map<String, List<SurveyQuestionWrapper>> sectionMap { get; private set; }
    	
    	public SurveyWrapper(List<Survey_Response_gne__c> questionList) {
    		this.questionList 	= questionList;
    		this.sectionMap		= this.prepareSection();
    	}
    	
    	private Map<String, List<SurveyQuestionWrapper>> prepareSection() {
    		
    		Map<String, List<SurveyQuestionWrapper>> result = new Map<String, List<SurveyQuestionWrapper>>();
    		
    		for(Survey_Response_gne__c question : this.questionList) {
    			
    			if(!String.isEmpty(question.Category_gne__c)) {

    				if(result.get(question.Category_gne__c) != null) {
    					
    					result.get(question.Category_gne__c).add( new SurveyQuestionWrapper(question.Id, question.Type_gne__c, question.Title_gne__c, question.Help_Text_gne__c, question.Values_gne__c, question.Labels_gne__c, (Integer)question.Minimum_Score_gne__c, (Integer)question.Maximum_Score_gne__c, (Integer)question.Position_gne__c, question.Multiple_Responses_gne__c, question.Selected_Label_gne__c, question.Selected_Values_gne__c, (Integer)question.Response_Score_gne__c, question.Free_Text_gne__c) );
    					
    				} else {
						
						result.put(question.Category_gne__c, new List<SurveyQuestionWrapper> { new SurveyQuestionWrapper(question.Id, question.Type_gne__c, question.Title_gne__c, question.Help_Text_gne__c, question.Values_gne__c, question.Labels_gne__c, (Integer)question.Minimum_Score_gne__c, (Integer)question.Maximum_Score_gne__c, (Integer)question.Position_gne__c, question.Multiple_Responses_gne__c, question.Selected_Label_gne__c, question.Selected_Values_gne__c, (Integer)question.Response_Score_gne__c, question.Free_Text_gne__c) } );
						
    				}
    				
    			} else {

    				if(result.get('-none-') != null) {
    					
    					result.get('-none-').add( new SurveyQuestionWrapper(question.Id, question.Type_gne__c, question.Title_gne__c, question.Help_Text_gne__c, question.Values_gne__c, question.Labels_gne__c, (Integer)question.Minimum_Score_gne__c, (Integer)question.Maximum_Score_gne__c, (Integer)question.Position_gne__c, question.Multiple_Responses_gne__c, question.Selected_Label_gne__c, question.Selected_Values_gne__c, (Integer)question.Response_Score_gne__c, question.Free_Text_gne__c) );
    					
    				} else {
    					
    					result.put('-none-', new List<SurveyQuestionWrapper> { new SurveyQuestionWrapper(question.Id, question.Type_gne__c, question.Title_gne__c, question.Help_Text_gne__c, question.Values_gne__c, question.Labels_gne__c, (Integer)question.Minimum_Score_gne__c, (Integer)question.Maximum_Score_gne__c, (Integer)question.Position_gne__c, question.Multiple_Responses_gne__c, question.Selected_Label_gne__c, question.Selected_Values_gne__c, (Integer)question.Response_Score_gne__c, question.Free_Text_gne__c) } );
    					
    				}
    				
    			}
    			
    		}
    		
    		for (String section : result.keySet()) {
			    result.get(section).sort();
			}
    		
    		return result;
    		
    	}
    	
    }
    
    @RemoteAction
    public static Map<String, Map<String, String>> save(String jsonString) {
        JSONParser parser = JSON.createParser(jsonString);
        List<Map<String, String>> answerList = (List<Map<String, String>>)parser.readValueAs(List<Map<String, String>>.class);
        
        Set<Id> responseIds = new Set<Id>();
        Map<String, String> resultMap = new Map<String, String>();
        
        for(Map<String, String> answer : answerList) {
        	responseIds.add(answer.get('name'));
        	
        	if(resultMap.get(answer.get('name')) != null) {
        		resultMap.put(answer.get('name'), resultMap.get(answer.get('name')) + ',' + answer.get('value'));
        	} else {
        		resultMap.put(answer.get('name'), answer.get('value'));
        	}
        	
        }
        
        List<Survey_Response_gne__c> listToUpdate = [SELECT Id, Selected_Label_gne__c, Labels_gne__c, Report_Value_gne__c, Selected_Values_gne__c, Response_Score_gne__c, Free_Text_gne__c, Type_gne__c FROM Survey_Response_gne__c WHERE Id IN :responseIds];
        
        for(Survey_Response_gne__c response : listToUpdate) {
        	
        	if(response.Type_gne__c == 'List of Values') {
        		
        		response.Selected_Values_gne__c = resultMap.get(response.Id);
        		response.Response_Score_gne__c = Decimal.valueOf(resultMap.get(response.Id));
        		response.Report_Value_gne__c = resultMap.get(response.Id);
        		response.Selected_Label_gne__c = resultMap.get(response.Id);
        		
        	} else if(response.Type_gne__c == 'Labels and Values') {
        		
        		response.Selected_Values_gne__c = resultMap.get(response.Id);
        		response.Report_Value_gne__c = resultMap.get(response.Id);
        		  		
        		List<String> splitLabel = response.Labels_gne__c.split(',');
        		List<String> splitValues = resultMap.get(response.Id).split(',');
					
				String selectedLabels = '';
				for(String i : splitValues) {
					selectedLabels += splitLabel[Integer.valueOf(i)] + ',';
				}

        		response.Selected_Label_gne__c = selectedLabels.removeEnd(',');
        		
        	} else if(response.Type_gne__c == 'Numeric') {
        		
        		response.Response_Score_gne__c = Decimal.valueOf(resultMap.get(response.Id));
        		
        	} else if(response.Type_gne__c == 'Free Text') {
        		
        		response.Free_Text_gne__c = resultMap.get(response.Id);
        		
        	}
        	
        }
        
        Map<String, Map<String, String>> result = new Map<String, Map<String, String>>();
        
        try {
        	update listToUpdate;
        	result.put('message', null);
        	return result;
        } catch(DMLException ex) {
        	
        	System.debug(logginglevel.ERROR, ex.getMessage());
        	Map<String, String> returnErrors = new Map<String, String>();
        	
        	for (Integer i = 0; i < ex.getNumDml(); i++) {
        	
        		returnErrors.put(ex.getDmlId(i), ex.getDmlStatusCode(i));

		    }
        	
        	result.put('message', returnErrors);
        	return result;
        }
    }
    
    private class SurveyQuestionWrapper implements Comparable {
    	
    	public Id id { get; private set; }
    	public String type { get; private set; }
    	public String question { get; private set; }
    	public String help { get; private set; }
    	public List<String> values { get; private set; }
    	public Map<String, String> labels { get; private set; }
    	public Integer minimumScore { get; private set; }
    	public Integer maximumScore { get; private set; }
    	public Integer position { get; private set; }
    	public Boolean multiple { get; private set; }
    	public List<String> selectedLabels { get; private set; }
    	public List<String> selectedValues { get; private set; }
    	public Integer numericAnwser { get; private set; }
		public String freeTextAnwser { get; private set; }
    	
    	public SurveyQuestionWrapper(Id id, String type, String question, String help, String valuesString, String labelsString, Integer minimumScore, Integer maximumScore, Integer position, Boolean multiple, String selectedLabels, String selectedValues, Integer numericAnwser, String freeTextAnwser) {
    		this.id 			= id;
    		this.type 			= type;
    		this.question 		= question;
    		this.help 			= help;
    		this.values 		= this.prepareValuesFromString(valuesString);
    		this.labels 		= this.prepareLabelsFromString(labelsString, valuesString);
    		this.minimumScore 	= minimumScore;
    		this.maximumScore 	= maximumScore;
    		this.position 		= position;
    		this.multiple 		= multiple;
    		this.selectedLabels = this.prepareValuesFromString(selectedLabels);
    		this.selectedValues = this.prepareValuesFromString(selectedValues);
    		this.numericAnwser 	= numericAnwser;
    		this.freeTextAnwser = freeTextAnwser;
    	}
    	
    	private List<String> prepareValuesFromString(String valuesString) {
    		if(!String.isEmpty(valuesString)) {
    			return valuesString.split(',', 0);
    		} else {
    			return null;
    		}
    	}
    	
    	private Map<String, String> prepareLabelsFromString(String labelsString, String valuesString) {
    		if(!String.isEmpty(labelsString) && !String.isEmpty(valuesString)) {
    			
    			List<String> labelsSplit 	= labelsString.split(',', 0);
    			List<String> valuesSplit 	= valuesString.split(',', 0);
    			
    			System.debug(labelsSplit);
    			System.debug(valuesSplit);

				Map<String, String> result = new Map<String, String>();
    				
				Integer i = 0;
    				
				for(String value : valuesSplit) {
    					
    				if(labelsSplit[i] != null) {
						result.put(value, labelsSplit[i]);
    				}
					i++;
    					
				}
				
				System.debug(result);
    				
				return result;

    			
    		} else {
    			return null;
    		}
    	}
    	        
        public Integer compareTo(Object compareTo) {
            SurveyQuestionWrapper comparableData = (SurveyQuestionWrapper)compareTo;
            Integer result = 0;
            if (this.position == comparableData.position) {
                result = 0;
            } else if (this.position > comparableData.position) {
                result = 1;
            } else {
                result = -1;
            }

            return result;
        }
    }
    
}