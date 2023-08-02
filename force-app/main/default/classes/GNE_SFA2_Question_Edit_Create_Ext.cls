public with sharing class GNE_SFA2_Question_Edit_Create_Ext  { 
    
    public boolean isNumeric{get;set;}
    public boolean isLabels{get;set;}
    public boolean isValues{get;set;}
    public String selType{get;set;}
    public List<SelectOption> questionTypes {get;set;}
    public String availabilityMode{get;set;}
    public Question_gne__c questn{get;set;}
    public Questionnaire_gne__c questnr{get;set;}
    public ID questnrId{get;set;}
    public boolean showFreeText{get;set;}
    public boolean isClone {get;set;}
    public boolean isCreatable{get;set;}
    private String retURL;
    
    // temp
    
	public Boolean forceRank {get;set;}
	public Boolean requiredSection {get;set;}

    public GNE_SFA2_Question_Edit_Create_Ext(ApexPages.StandardController controller){
        
        requiredSection = false;
        this.questn = (Question_gne__c)controller.getRecord();
        isCreatable=false;
        if(System.currentPageReference().getParameters().get('objectId')!=null){
            questnrId = System.currentPageReference().getParameters().get('objectId');
        }
        retURL = System.currentPageReference().getParameters().get('retURL');
        
        if(retURL!=null) {
            retURL = EncodingUtil.urlDecode(retURL, 'UTF-8');
        }        
        if(controller.getRecord().Id!=null)
        {
            this.availabilityMode='Edit';
            //quesnr=myObject;
            questn =[SELECT Force_Ranking_Value_gne__c,Help_Text_gne__c,Labels_gne__c,Maximum_Score_gne__c,Minimum_Score_gne__c,Multiple_Responses_gne__c,Position_gne__c,Questionnaire_gne__c,Region_Code_gne__c,Category_gne__c,Title_gne__c,Type_gne__c,Values_gne__c,Weight_gne__c from Question_gne__c
            where id=:controller.getRecord().Id];
            this.selType=questn.Type_gne__c;
            this.forceRank = questn.Force_Ranking_Value_gne__c;
            this.questnrId =questn.Questionnaire_gne__c;
            if(forceRank == true) {
            	requiredSection = true;
            }
        }
        else{
            this.availabilityMode='New';
            questn.Position_gne__c=Integer.ValueOf((Assesment_WS.getQuestionnaireQuestionsNumber(questnrId))+1);
        }
        
        showFreeText = isShowFreeText();
        populateQuestionTypes();
        selType = (selType==null)?'Numeric':selType;
        switchCategory(selType);
    }
    
    public PageReference isNewQuestionCreatable(){
        
          if(questnrId!=null){
           List<Questionnaire_gne__c> questionar = [select Id,No_Edit_gne__c from Questionnaire_gne__c where Id=:questnrId];
           if(questionar!=null && questionar.size()>0){
            if(questionar[0].No_Edit_gne__c && availabilityMode.equals('New')){
                         Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR,'This questionnaire is Not Editable, thus no questions can be added to it'));
                         return null;
                    }
           }
           else{
               Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR,'You cannot add question without passing questionnaire record'));
               return null;
           }
        }
        isCreatable=true;
        return null;
    }
    
    public PageReference OK(){
        PageReference pg= new PageReference('/apex/GNE_SFA2_Questionnaire_Layout?id='+questnrId);
        pg.setredirect(true);
        return pg;
    }
    



    public void populateQuestionTypes(){
        if(questionTypes!=null && questionTypes.size()>0) 
        questionTypes.clear();
        questionTypes = new List<SelectOption>();
        questionTypes.add(new SelectOption('Numeric','Numeric'));
        questionTypes.add(new SelectOption('List of Values','List of Values'));
        questionTypes.add(new SelectOption('Labels and Values','Labels and Values'));
        if(showFreeText){
            questionTypes.add(new SelectOption('Free Text','Free Text'));
        }
        
    }

    public void switchCategory(String selType){
        
        if(selType.equals('Numeric')){
            isNumeric=true;isLabels=false;isValues=false;
        }
        
        else if(selType.equals('List of Values')){
            isNumeric=false;isLabels=false;isValues=true;
        }
        else if(selType.equals('Labels and Values')){
            isNumeric=false;isLabels=true;isValues=false;
        }
        else if(selType.equals('Free Text')){
            isNumeric=false;isLabels=false;isValues=false;
            
        }
        
    }

    public boolean isShowFreeText(){
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
        }
        else{
            return false;
        }
        return false;
        
        
    }


    public PageReference onChangeType(){
        
        switchCategory(selType);
        return null;
        
    }
    
    public PageReference onChangeForceRank() {
    	
    	return null;
    }

    public PageReference Save(){
    
        if(questnrId==null){
               Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR,'You cannot add question without passing questionnaire record'));
                return null;
        }
        
        String message = runValidations();
        if( System.currentPageReference().getParameters().get('isClone')!=null && System.currentPageReference().getParameters().get('isClone')=='true'){
               questn = questn.clone();
                isClone=true;
            }
        
        if(message.equals('success')){
            questn.Type_gne__c=selType;
            if(availabilityMode.equals('New')){
                questn.Questionnaire_gne__c=questnrId;
                List<Questionnaire_gne__c> questionar = [select Id,No_Edit_gne__c from Questionnaire_gne__c where Id=:questnrId];
                if(questionar!=null && questionar.size()>0){
                    
                    if(questionar[0].No_Edit_gne__c){
                         Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR,'This questionnaire is Not Editable, thus no questions can be added to it'));
                         return null;
                    }
                }
                
            }
            
            try{
                upsert questn;
            }
            catch(Exception e){ 
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR,e.getMessage()));
                return null;
            }
            
        }
        else{
            Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR,message));
            return null;
        }
        PageReference pg= new PageReference('/apex/GNE_SFA2_Question_Layout?id='+questn.Id);
        pg.setredirect(true);
        return pg;
        
    }

    public PageReference cancel(){
        String viewURL = '';
        if(retURL != null && !retURL.equalsIgnoreCase('')){
            viewURL = retURL;
        }else {
            viewURL = '/apex/GNE_SFA2_Questionnaires';
        }

        Pagereference pageref = new pagereference(viewURL);
        pageref.setredirect(true);
        return pageref;
    }

    public String runValidations(){
        Pattern isnumbers = Pattern.Compile('^[0-9]+$');
        if(selType.equals('Labels and Values')){
            List<String> values = questn.Values_gne__c.split(',',-1);
            List<String> labels = questn.Labels_gne__c.split(',',-1);
            if((labels==null || values==null) || (labels.size()!=values.size()) || (labels.size()==0 || values.size()==0)){
                return 'Values and Labels must contain the same number of values and cannot be empty.';
                
            }
            if(questn.Multiple_Responses_gne__c && questn.Force_Ranking_Value_gne__c ) {
                return 'Force Ranking checkbox cannot be checked for questions with Multiple Responses.';
            }
        } 
        
        
        else if(selType.equals('Free Text') && questn.Force_Ranking_Value_gne__c){
            
            return 'Force Ranking checkbox cannot be checked for Free Text questions.';
        }
        else if(selType.equals('List of Values')){
            List<String> values = questn.Values_gne__c.split(',',-1);
            
            for(String val : values){
                
                Matcher intOnly = isnumbers.matcher(val);
                if(!intOnly.Matches()){
                    return 'Values list must be numeric.';
                }
            }
            
        }
        
        if(questn.Maximum_Score_gne__c<=questn.Minimum_Score_gne__c)
        {
            return 'The Maximum Score is smaller than the minimum score.';
        }
        
        return 'success';
        
    }

	public PageReference checkIfSectionIsRequired() {
		if((forceRank == false && requiredSection == false)) {
			requiredSection = true;
		} else if((forceRank == false && requiredSection == true) || (forceRank == true && requiredSection == true)) {
			requiredSection = false;
		}
		return null;
		
	}



}