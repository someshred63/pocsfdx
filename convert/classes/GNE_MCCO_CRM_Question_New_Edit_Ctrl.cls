/* 
 * GNE_MCCO_CRM_Question_New_Edit_Ctrl
 *
 * Created By :         Tadeusz Hyzy (tadeusz.hyzy@contractors.roche.com)
 * Last Modified By :   Tadeusz Hyzy (tadeusz.hyzy@contractors.roche.com)
 * Last Modified Date : 01/13/2015
 * 
 */
public with sharing class GNE_MCCO_CRM_Question_New_Edit_Ctrl {
	
    public String questionnaireId { get; set; }
    private String questionId { get; set; }
    public Question_gne__c question { get; set; }
    
    public String pageTitle { get; private set; }
    public Boolean editMode { get; private set; }
    
    public List<SelectOption> questionTypeList { get; private set; }
    
    public Boolean isNumericType { get; private set; }
    public Boolean isListType { get; private set; }
    public Boolean isLabelsType { get; private set; }

	public GNE_MCCO_CRM_Question_New_Edit_Ctrl() {
		
		questionnaireId = (ApexPages.currentPage().getParameters().get('qid') != null && ApexPages.currentPage().getParameters().get('qid') != '') ? ApexPages.currentPage().getParameters().get('qid') : null;
		questionId = (ApexPages.currentPage().getParameters().get('id') != null && ApexPages.currentPage().getParameters().get('id') != '') ? ApexPages.currentPage().getParameters().get('id') : null;
		
		if(questionId != '' && questionId != null) {
			pageTitle = 'Edit Question';
			editMode = true;
			question = [ SELECT Id, Name, Category_gne__c, Force_Ranking_Value_gne__c, Help_Text_gne__c, Labels_gne__c, Maximum_Score_gne__c, Minimum_Score_gne__c, Multiple_Responses_gne__c, Position_gne__c, Questionnaire_gne__c, Region_Code_gne__c, Title_gne__c, Type_gne__c, Values_gne__c, Weight_gne__c FROM Question_gne__c WHERE Id = :questionId LIMIT 1][0];
			if(questionnaireId == '' || questionnaireId == null) {
				questionnaireId = question.Questionnaire_gne__c;
			}
		} else {
			pageTitle = 'New Question';
			editMode = false;
			question = new Question_gne__c( Questionnaire_gne__c = questionnaireId, Position_gne__c = getNextQuestionPosition() );
		}
		
		questionTypeList = loadQuestionTypeList();

		changeQuestionType();

	}
	
	private Integer getNextQuestionPosition() {
		try {
			return (Integer)[ SELECT Position_gne__c FROM Question_gne__c WHERE Questionnaire_gne__c = :questionnaireId ORDER BY Position_gne__c DESC LIMIT 1][0].Position_gne__c + 1;
		} catch(Exception ex) {
			return 1;
		}
	}
	
	public PageReference save() {
		
		PageReference pageRef;
		
		if(!validateValuesField()) {
       		Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR, 'Values must be numeric.'));
       		return null;
		}
		    
        if(questionnaireId==null){
       		Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR, 'You cannot add question without passing questionnaire record'));
			return null;
        }
		
		
		try {
			upsert question;
			pageRef = new PageReference('/apex/GNE_MCCO_CRM_Questionnaire_View?id='+questionnaireId);
			pageRef.getParameters().put('success', 'Success!');
		} catch(DMLException ex) {
			pageRef = ApexPages.currentPage();
			pageRef.getParameters().put('error', ex.getMessage());
		}
        pageRef.setredirect(true);
        return pageRef;
	}
	
	public PageReference changeQuestionType() {
						
		isNumericType = false;
		isListType = false;
		isLabelsType = false;
		
		if(String.isEmpty(question.Type_gne__c)) {
			isNumericType = true;
		} else if(question.Type_gne__c == 'Numeric') {
			isNumericType = true;
		} else if(question.Type_gne__c == 'List of Values') {
			isListType = true;
		} else if(question.Type_gne__c == 'Labels and Values') {
			isListType = true;
			isLabelsType = true;
		}
		
		return null;
		
	}
	
	private Boolean validateValuesField() {
		if(question.Type_gne__c == 'List of Values') {
			System.debug(question.Values_gne__c.deleteWhitespace());
			System.debug(Pattern.matches('[0-9,]+', question.Values_gne__c.deleteWhitespace()));
			return Pattern.matches('[0-9,]+', question.Values_gne__c.deleteWhitespace());
		} else {
			return true;
		}
	}
	
	private List<SelectOption> loadQuestionTypeList() {
		List<SelectOption> result = new List<SelectOption>();
		
		Schema.DescribeFieldResult fieldResult = Question_gne__c.Type_gne__c.getDescribe();
	  	List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
	        
	   	for(Schema.PicklistEntry f : ple) {
	    	result.add(new SelectOption(f.getLabel(), f.getValue()));
   		}
   		
   		if(isShowFreeText()) {
   			result.add(new SelectOption('Free Text', 'Free Text'));
   		}
   		
   		return result;
	}
	
	private Boolean isShowFreeText(){
        List<String> profiles = new List<String>();
        List<String> whereConList = new List<String>();
        List<Questionnaire_Config_gne__c> question_configs = [select Value_gne__c from Questionnaire_Config_gne__c WHERE Name = 'ProfileWithFreeTextQuestions'];
        String whereCon='';
        if(question_configs!=null && question_configs.size()>0){
            profiles = question_configs[0].Value_gne__c.split(';',-1);
            for(String p : profiles){
                whereConList.add('Profile_Name_gne__c '+p);
            }
            
            for(String profileName : whereConList){
                whereCon = whereCon + profileName + ' OR ';
            }
            whereCon = whereCon.removeEnd('OR ');
            String.escapeSingleQuotes(whereCon);
            System.debug('where condition' + whereCon);
            
            if(!whereCon.equals('')){
                String db_Query = 'select Profile_Name_gne__c from User where ('+whereCon+ ') and ID = \''+userInfo.getUserId() + '\'' ;
                System.debug('query condition' + db_Query);
                List<User> users = Database.query(db_Query);
                
                if(users!=null && users.size()>0){
                    return true;
                }
                return false;
            }
        } else {
            return false;
        }
        return false;
        
        
    }
}