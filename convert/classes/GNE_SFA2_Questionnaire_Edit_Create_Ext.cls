public with sharing class GNE_SFA2_Questionnaire_Edit_Create_Ext  { 
    
    public boolean isProduct{get;set;}
    public String selCategory{get;set;}
    public String selAudience{get;set;}
    public String selSurveyMode{get;set;}
    public List<SelectOption> categories {get;set;}
    public List<SelectOption> audiences {get;set;}
    public List<SelectOption> surveyModes {get;set;}
    public List<SelectOption> recordTypes{get;set;}
    private Set<String> recordTypesString {get;set;}
    public String availabilityMode{get;set;}
    public String recordTypeName{get;set;}
    public boolean hasMultipleRecordTypes{get;set;}
    public Questionnaire_gne__c quesnr{get;set;}
    public String accountcsvList{get;set;}
    public boolean hasQuestionnaireSurveys{get;set;}
    public Map<String,Id> recordTypeIdMap {get;set;}
    public String recTypeId{get;set;}
    public boolean isShowTable{get;set;}
    public boolean showPreviewBlock{get;set;}
    public List<Account> questionnaireAccountList{get;set;}
    public Map<String,List<previewMode>> categoryLookupMap {get;set;}
    public List<List<previewMode>> lstofpreviews{get;set;}
    public boolean showQposition{get;set;}
    public boolean isNoQuestions{get;set;}
    private String retURL;
    private SFA2_Configuration_Object_gne__c pageConfiguration;    
    
    public Boolean noEdit {get;set;}
    public Boolean freezeSurveys {get;set;}
    public Boolean hideSurvey {get;set;}
    
    public String getProductWhereExpr {
        get {
            return recordTypeName == 'MedAffairs'               
                ? '(Detail_Product_Subtype_Code_gne__c = \'Molecule\' OR Detail_Product_Subtype_Code_gne__c = \'TheraDisease\')'                
                : null;
        }       
    }
    
    //temp 
    
    private String questionnaireId {get;set;}
    
    public class previewMode{
        
        public List<SelectOption> answerList{get;set;}
        public String question{get;set;}  
        public Decimal weight{get;set;}
        public String helpText {get;set;}
        public boolean ishelpAvailable{get;set;}
        public boolean listValues_less_three{get;set;}
        public String sectionTitle{get;set;}
        public Integer position{get;set;}
        public boolean isNumeric{get;set;}
        public String answerNumeric{get;set;}
        public boolean isFreeText{get;set;}
        public String freeText{get;set;}
        public boolean showPosition{get;set;}
        public String qId{get;set;}
        
        
    }
    
    public GNE_SFA2_Questionnaire_Edit_Create_Ext(ApexPages.StandardController controller){
        pageConfiguration = GNE_SFA2_Util.getListPageConfiguration('Questionnaire_gne__c');
        this.quesnr = (Questionnaire_gne__c)controller.getRecord();
        System.debug('##### quesnr === ' + quesnr);
        recordTypes = new List<SelectOption>();categories= new List<SelectOption>();audiences= new List<SelectOption>(); surveyModes= new List<SelectOption>();
        retURL = System.currentPageReference().getParameters().get('retURL');
        
        if(retURL!=null) {
            retURL = EncodingUtil.urlDecode(retURL, 'UTF-8');
        }
        if(controller.getRecord().Id!=null)
        {
            this.availabilityMode='Edit';
            //quesnr=myObject;
            quesnr =[SELECT Audience_Type_gne__c, recordtype.name,Category_gne__c,No_Edit_gne__c , CreatedById, CreatedDate, Freeze_Surveys_gne__c, Hide_Surveys_gne__c,LastModifiedById, LastModifiedDate,OwnerId, Product_gne__c,Product_gne__r.Name, ProductSpecific_gne__c, Name, Questionnaire_Status_gne__c, Ready_For_Use_gne__c, Id, RecordTypeId, Region_Code_gne__c, Show_Questions_Position_gne__c, Show_Weight_gne__c, Single_Survey_per_Mode_gne__c, SystemModstamp, Territories_can_gne__c, Type_gne__c, Version_gne__c
            FROM  Questionnaire_gne__c where id=:controller.getRecord().Id];
            
            questionnaireId = quesnr.Id;
            
            if(quesnr.Version_gne__c == null || quesnr.Version_gne__c == 'undefined') {
                quesnr.Version_gne__c = '1';
            }
            this.recordTypeName=quesnr.recordtype.name;
            this.selCategory=quesnr.Category_gne__c;
            this.selAudience=quesnr.Audience_Type_gne__c;
            this.selSurveyMode=quesnr.Single_Survey_per_Mode_gne__c;                   
            this.showQposition=quesnr.Show_Questions_Position_gne__c;
            hasQuestionnaireSurveys=Assesment_WS.hasQuestionnaireSurveys(quesnr.Id);
        }
        else{
            this.availabilityMode='New';
            this.quesnr.OwnerId = UserInfo.getUserId();
        }
        
        //if(availabilityMode.equals('New'))
        //{ 
            populateRecordTypes();
        //}
        
        if(availabilityMode.equals('Edit') && System.currentPageReference().getParameters().get('isRdytoAddaccs')!=null && System.currentPageReference().getParameters().get('isRdytoAddaccs')=='true')
        {
            Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.INFO,'The questionnaire has been succesfully created.\nYou can now add the related accounts list.'));
        }
        
        if(System.currentPageReference().getParameters().get('duplicateQstner')!=null && System.currentPageReference().getParameters().get('duplicateQstner')=='true'){
            Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.INFO,'This data belongs to the duplicated questionnaire. Please apply your changes and update it.'));
            
        }
        
        if(questionnaireId != '' && questionnaireId != null) {
            checkQuestionnaireSurveyIsExists(questionnaireId);
        } else {
            noEdit = true;
            freezeSurveys = true;
            hideSurvey = true;
        }
        
        hasQuestionnaireSurveys=false;
        isShowTable=false;
        showPreviewBlock=false;
        loadQuestionnaireData(availabilityMode);
        
        if(questionnaireId != null && questionnaireId !='') {
            accountcsvList = '';
            List<String> accountIdList = new List<String>();
            List<QuestionnaireAccount_gne__c> questAccounts = [SELECT Account__c FROM QuestionnaireAccount_gne__c WHERE Questionnaire_gne__c =: questionnaireId] ;
            for(QuestionnaireAccount_gne__c questAcct : questAccounts) {
                accountcsvList += questAcct.Account__c + ',';
                accountIdList.add(questAcct.Account__c);
            }
            
            accountcsvList = accountcsvList.removeEnd(',');
            
            if(questAccounts.size() > 0) {
                questionnaireAccountList = [SELECT Id, Name FROM Account WHERE Id IN : accountIdList LIMIT 1000];
                isShowTable=true;   
            } 
        }
    }
    
    public void populaterecordTypes(){
        
        recordTypes.clear();
        recordTypesString = new Set<String>();
        Schema.DescribeSObjectResult dsr =  Questionnaire_gne__c.SObjectType.getDescribe();
        Schema.RecordTypeInfo defaultRecordType;
        for(Schema.RecordTypeInfo rti : dsr.getRecordTypeInfos()) {
            System.debug('#### RTI === ' + rti);
            if ((rti.isAvailable() == true) && rti.getName()!=null) {
                recordTypes.add(new SelectOption(rti.getName(),rti.getName()));
                recordTypesString.add(rti.getName());
            }
            if(rti.isDefaultRecordTypeMapping() && rti.isAvailable() && rti.getName()!=null && recordtypeName==null ){
                recordtypeName=rti.getName();
            }
            
        }
        
        if( recordtypes!=null &&  recordtypes.size()>0){
            if(recordtypes.size()>2){//we have to ignore master record type.
                this.hasMultipleRecordTypes = true;
                Integer i = 0;
                Integer rtToRemove = 0;
                Boolean removeMasterRecordType = false;
                for(SelectOption selectOption : recordTypes){
                        if(selectOption.getLabel().equalsIgnoreCase('Master')){
                                rtToRemove = i;
                                removeMasterRecordType = true;
                        }
                        i++;
                }
                if(removeMasterRecordType){
                        recordTypes.remove(rtToRemove);
                }
            }
            
        }
        else{
            this.hasMultipleRecordTypes=false;
        }
    }
    
    public PageReference onRecordTypeChange(){
        System.debug('onRecordTypeChange called');
        //populaterecordTypes();
        loadQuestionnaireData('New');
        return null;
    }
    
    public String  setAccountsDataCSV(Id QuestionnerId,String accountcsvList){
        return Assesment_WS.setQuestionnaireAccountsFromCSV(QuestionnerId,accountcsvList);
    }

    public String getActiveMenuItem() {
       String result = '';
        if(pageConfiguration != null && pageConfiguration.Attributes_gne__c!=null && pageConfiguration.Attributes_gne__c.contains('activeMenuItem')){
        result = pageConfiguration.Attributes_gne__c.substringBetween('activeMenuItem=',';');
        }
        return result;
    }
        
    
    public PageReference updateAccountList(){
        String message =setAccountsDataCSV(quesnr.Id,accountcsvList);
        if(message.equalsIgnoreCase('ok')){
            questionnaireAccountList = Assesment_WS.getQuestionnaireAccounts(quesnr.Id);
            for(Account a : questionnaireAccountList ){
                System.debug('**'+ a);
            }
            isShowTable=true;
            
        }
        else{
            isShowTable=false;
            Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR,message));
            return null;
        }
        return null;
        
    }
    
    public PageReference reorderQuestions(){
        System.debug('**isjdie reordering ');
        try{
        Assesment_WS.reorderQuestionnaireQuestions(quesnr.Id);
        Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.INFO,'Question positioning succesfully rebuilt.'));
        }
        catch(exception e){
            Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR,e.getMessage()));
            return null;
        }
        return null;
        
    }
    
    
    public void loadQuestionnaireData(String mode){
        if(mode.equals('New') || mode.equals('Edit')){
                //if(categories.size()>0){
                        categories.clear();
                //}
                
                //if(audiences.size()>0){
                        audiences.clear();
                //}
                
                //if(surveyModes.size()>0){
                        surveyModes.clear();
                //}
        }

        System.debug('*rectypename*'+ recordTypeName);
        System.debug('##### RT String === ' + recordTypesString);
        
        //if(mode.equals('New')){
            if(recordTypeName.equals('Managed Care - PT')){
                
                categories.add(new SelectOption('Managed Care - PT','Managed Care - PT'));
                audiences.add(new SelectOption('Targeted','Targeted'));
                audiences.add(new SelectOption('General','General'));
                surveyModes.add(new SelectOption('Per Account','Per Account'));
                surveyModes.add(new SelectOption('Per User Per Account','Per User Per Account'));
                surveyModes.add(new SelectOption('No Limit','No Limit'));
            }
            
            else if(recordTypeName.equals('Managed Care - Access Metrics')){
                
                categories.add(new SelectOption('Managed Care - Access Metrics','Managed Care - Access Metrics'));
                audiences.add(new SelectOption('Targeted','Targeted'));
                surveyModes.add(new SelectOption('Per Account','Per Account'));

            }
            else if(recordTypeName.equals('Medical Event Survey')){
                
                categories.add(new SelectOption('Speaker Content','Speaker Content'));
                categories.add(new SelectOption('Speaker Skills','Speaker Skills'));
                audiences.add(new SelectOption('Targeted','Targeted'));
                audiences.add(new SelectOption('General','General'));
                surveyModes.add(new SelectOption('Per Account','Per Account'));
                surveyModes.add(new SelectOption('Per User Per Account','Per User Per Account'));
                surveyModes.add(new SelectOption('No Limit','No Limit'));

            }
            else if(recordTypeName.equals('Speaker Nomination Survey')){
                
                categories.add(new SelectOption('Managed Care','Managed Care'));
                categories.add(new SelectOption('Nurses','Nurses'));
                categories.add(new SelectOption('Physicians','Physicians'));
                categories.add(new SelectOption('Patient Ambassador','Patient Ambassador'));
                audiences.add(new SelectOption('Targeted','Targeted'));
                audiences.add(new SelectOption('General','General'));
                surveyModes.add(new SelectOption('Per Account','Per Account'));
                surveyModes.add(new SelectOption('Per User Per Account','Per User Per Account'));
                surveyModes.add(new SelectOption('No Limit','No Limit'));

            }
            else if(recordTypeName.equals('MedAffairs')){
                
                categories.add(new SelectOption('MedAffairs','MedAffairs'));
                audiences.add(new SelectOption('Targeted','Targeted'));
                audiences.add(new SelectOption('General','General'));
                surveyModes.add(new SelectOption('Per Account','Per Account'));
                surveyModes.add(new SelectOption('Per User Per Account','Per User Per Account'));
                surveyModes.add(new SelectOption('No Limit','No Limit'));

            }
            else if(recordTypeName.equals('Managed Care - CFT')){
                
                categories.add(new SelectOption('Managed Care - CFT','Managed Care - CFT'));
                audiences.add(new SelectOption('Targeted','Targeted'));
                audiences.add(new SelectOption('General','General'));
                surveyModes.add(new SelectOption('Per Account','Per Account'));
                surveyModes.add(new SelectOption('Per User Per Account','Per User Per Account'));
                surveyModes.add(new SelectOption('No Limit','No Limit'));

            }
            else if(recordTypeName.equals('Managed Care - FRM')){
                
                categories.add(new SelectOption('Managed Care - FRM','Managed Care - FRM'));
                audiences.add(new SelectOption('Targeted','Targeted'));
                audiences.add(new SelectOption('General','General'));
                surveyModes.add(new SelectOption('Per Account','Per Account'));
                surveyModes.add(new SelectOption('Per User Per Account','Per User Per Account'));
                surveyModes.add(new SelectOption('No Limit','No Limit'));
            }
            else if(recordTypeName.equals('Canada Sales')){
                
                categories.add(new SelectOption('Canada Sales','Canada Sales'));
                audiences.add(new SelectOption('Targeted','Targeted'));
                audiences.add(new SelectOption('General','General'));
                surveyModes.add(new SelectOption('Per Account','Per Account'));
                surveyModes.add(new SelectOption('Per User Per Account','Per User Per Account'));
                surveyModes.add(new SelectOption('No Limit','No Limit'));
            } else if(recordTypeName.equals('ATLS')){
                categories.add(new SelectOption('ATLS','ATLS'));
                categories.add(new SelectOption('ATLS Advocacy Assesment','ATLS Advocacy Assesment'));
                categories.add(new SelectOption('Medical Event Survey','Medical Event Survey'));
                categories.add(new SelectOption('Speaker Nomination Survey','Speaker Nomination Survey'));
                audiences.add(new SelectOption('Targeted','Targeted'));
                audiences.add(new SelectOption('General','General'));
                surveyModes.add(new SelectOption('Per Account','Per Account'));
                surveyModes.add(new SelectOption('Per User Per Account','Per User Per Account'));
                surveyModes.add(new SelectOption('No Limit','No Limit'));
            } else if(recordTypeName.contains('MCCO Teams') && recordTypeName.contains('Shared')){
                categories.add(new SelectOption('Sales','Sales'));
                categories.add(new SelectOption('ATLS','ATLS'));
                categories.add(new SelectOption('ATLS Advocacy Assesment','ATLS Advocacy Assesment'));
                categories.add(new SelectOption('Speaker Nomination Survey','Speaker Nomination Survey'));
                categories.add(new SelectOption('Managed Care - PT','Managed Care - PT'));
                categories.add(new SelectOption('MedAffairs','MedAffairs'));
                categories.add(new SelectOption('Managed Care - CFT','Managed Care - CFT'));
                categories.add(new SelectOption('Managed Care - FRM','Managed Care - FRM'));
                categories.add(new SelectOption('Canada Sales','Canada Sales'));
                categories.add(new SelectOption('MCCO Teams - Shared','MCCO Teams - Shared'));
                audiences.add(new SelectOption('Targeted','Targeted'));
                audiences.add(new SelectOption('General','General'));
                surveyModes.add(new SelectOption('Per Account','Per Account'));
                surveyModes.add(new SelectOption('Per User Per Account','Per User Per Account'));
                surveyModes.add(new SelectOption('No Limit','No Limit'));
            } else if(recordTypeName.equals('Master')){
                categories.add(new SelectOption('Sales','Sales'));
                categories.add(new SelectOption('ATLS','ATLS'));
                categories.add(new SelectOption('ATLS Advocacy Assesment','ATLS Advocacy Assesment'));
                categories.add(new SelectOption('Speaker Nomination Survey','Speaker Nomination Survey'));
                categories.add(new SelectOption('Managed Care - PT','Managed Care - PT'));
                categories.add(new SelectOption('MedAffairs','MedAffairs'));
                categories.add(new SelectOption('Managed Care - CFT','Managed Care - CFT'));
                categories.add(new SelectOption('Managed Care - FRM','Managed Care - FRM'));
                categories.add(new SelectOption('Canada Sales','Canada Sales'));
                categories.add(new SelectOption('MCCO Teams - Shared','MCCO Teams - Shared'));
                audiences.add(new SelectOption('Targeted','Targeted'));
                audiences.add(new SelectOption('General','General'));
                surveyModes.add(new SelectOption('Per Account','Per Account'));
                surveyModes.add(new SelectOption('Per User Per Account','Per User Per Account'));
                surveyModes.add(new SelectOption('No Limit','No Limit'));
            } else if(recordTypesString.contains('Master')){
                categories.add(new SelectOption('Sales','Sales'));
                categories.add(new SelectOption('ATLS','ATLS'));
                categories.add(new SelectOption('ATLS Advocacy Assesment','ATLS Advocacy Assesment'));
                categories.add(new SelectOption('Speaker Nomination Survey','Speaker Nomination Survey'));
                categories.add(new SelectOption('Managed Care - PT','Managed Care - PT'));
                categories.add(new SelectOption('MedAffairs','MedAffairs'));
                categories.add(new SelectOption('Managed Care - CFT','Managed Care - CFT'));
                categories.add(new SelectOption('Managed Care - FRM','Managed Care - FRM'));
                categories.add(new SelectOption('Canada Sales','Canada Sales'));
                categories.add(new SelectOption('MCCO Teams - Shared','MCCO Teams - Shared'));
                audiences.add(new SelectOption('Targeted','Targeted'));
                audiences.add(new SelectOption('General','General'));
                surveyModes.add(new SelectOption('Per Account','Per Account'));
                surveyModes.add(new SelectOption('Per User Per Account','Per User Per Account'));
                surveyModes.add(new SelectOption('No Limit','No Limit'));
            } else {
                if(recordTypes!=null && recordTypes.size()>0)
                {
                    categories = recordTypes;
                }

                // TODO  laod pick list dynamiccally..
                audiences.add(new SelectOption('Targeted','Targeted'));
                audiences.add(new SelectOption('General','General'));
                surveyModes.add(new SelectOption('Per Account','Per Account'));
                surveyModes.add(new SelectOption('Per User Per Account','Per User Per Account'));
                surveyModes.add(new SelectOption('No Limit','No Limit'));
            }
            
            System.debug('*categories*'+ categories);
            
        //}
        
    }
    
    
    public Id getRecordTypeId(String categoryName){
        Map<String,GNE_SFA2_Questionnaire_Category_Type_gne__c> categoryRecordTypelookup = GNE_SFA2_Questionnaire_Category_Type_gne__c.getAll();

        String recordtypeName = (categoryRecordTypelookup.get(categoryName) != null && categoryRecordTypelookup.get(categoryName).Record_Type_Name__c!=null)?(categoryRecordTypelookup.get(categoryName).Record_Type_Name__c):null;
        if(recordtypeName!=null){   
            List<RecordType> recCategory = [select Id from RecordType where name =: recordtypeName and SobjectType='Questionnaire_gne__c'];
            if(recCategory!=null && recCategory.size()>0){
                return recCategory[0].Id;
            }
        }
        return null;
    }
    
    public PageReference save(){
        PageReference pageRef;

        String message = runValidations();
        if(message.equals('success')){
            quesnr.Category_gne__c = selCategory;            
            quesnr.Audience_Type_gne__c = selAudience;
            quesnr.Single_Survey_per_Mode_gne__c = selSurveyMode;
            quesnr.recordtypeId = getRecordTypeId(selCategory);
            
            if(!quesnr.ProductSpecific_gne__c && String.isNotBlank(quesnr.Product_gne__c)){
                quesnr.Product_gne__c = null;
            }   
            
            try{
                upsert quesnr;
            }catch(Exception e){
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR,e.getMessage()));
                return null;
            }
        }else{
            Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR,message));
            return null;
        }

        if(availabilityMode.equals('New') && !selCategory.equals('Canada Sales') && selAudience.equals('Targeted')){
            pageRef= new PageReference('/apex/GNE_SFA2_Qstner_Edit_Create_Layout?id='+quesnr.Id+'&isRdytoAddaccs=true&retURL='+retURL);
            pageRef.setredirect(true);
            return pageRef;
        }
        
        pageRef= new PageReference('/apex/GNE_SFA2_Questionnaire_Layout?id='+quesnr.Id+ '&retURL='+retURL);
        pageRef.setredirect(true);
        return pageRef;
    }
    
    public PageReference isFullClone(){
        Questionnaire_gne__c newQsnr;
        try{
            newQsnr = Assesment_WS.duplicateQuestionnaire(quesnr.Id);
            newQsnr.recordtypeId = quesnr.recordtypeId;
            update newQsnr;
        }
        catch(exception e){
            Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR,e.getMessage()));
            return null;
        }
        
         PageReference pageRef;
         pageRef= new PageReference('/apex/GNE_SFA2_Qstner_Edit_Create_Layout?id='+newQsnr.Id+'&duplicateQstner=true&retURL='+retURL);
         pageRef.setredirect(true);
         return pageRef;
    }
    
    public Integer getProductSize(String productName){
        Integer size=0;
        try{
            size =Assesment_WS.getProductByName(productName).size();
        }catch(exception e){}
        
        return size;
    }
    
    public PageReference cancel(){
        PageReference pageRef;
        if(availabilityMode.equals('Edit')){
         pageRef= new PageReference('/apex/GNE_SFA2_Questionnaire_Layout?id='+quesnr.Id+ '&retURL='+retURL);
         pageRef.setredirect(true);
         return pageRef;
        }
        else{//new
            pageRef= new PageReference('/apex/GNE_SFA2_Questionnaires');
         pageRef.setredirect(true);
         return pageRef;
        } 
        return null;
        
    }

    public String runValidations(){
        if(quesnr.ProductSpecific_gne__c){
            if (String.isBlank(quesnr.Product_gne__c)) {
                return 'The questionnaire is product specific. Please select a product.';                    
            }
        }    

        if(selAudience.equals('Targeted') && availabilityMode.equals('Edit') && accountcsvList==null && quesnr.Ready_For_Use_gne__c )
        {
            if(!selCategory.equals('Managed Care - Access Metrics') && !selCategory.equals('Medical Event Survey - Speaker Skills') && !selCategory.equals('Medical Event Survey - Speaker Content') && !selCategory.equals('Nomination Survey') && !selCategory.equals('MedAffairs') && !selCategory.equals('Canada Sales'))
            {
             return 'A targeted questionnaire must be associated with accounts once is ready for use.';
            }
        }
        
     else if(selCategory.equals('Managed Care - Access Metrics') && availabilityMode.equals('Edit')  && quesnr.Ready_For_Use_gne__c){
        
        List<Questionnaire_gne__c> quesners = [select Id from Questionnaire_gne__c where Id !=:quesnr.Id and Category_gne__c ='Managed Care - Access Metrics' and Ready_For_Use_gne__c=true ];
        if(quesners!=null && quesners.size()>0){
            
            return 'There cannot be more than one Access Metric Questionnaire Ready for Use.';
        }
        
     }
        //handle warnOfTheTerribleConsequencesThatClickNoEditWillBring on javascript when no edit is not enabled. 
           return 'success';
    }
    
    public void checkQuestionnaireSurveyIsExists(String questionnaireID) {
        Boolean surveyIsExist = ([Select count() from Survey_gne__c s where s.Questionnaire_gne__c =: questionnaireID]>0);
        
        if(!surveyIsExist) {
            noEdit = false;
            freezeSurveys = false;
            hideSurvey = false;
        }
    }
    
    public PageReference showPreviewQuestions(){
        showPreviewBlock=true;
        List<Question_gne__c> questions = Assesment_WS.getQuestionnaireQuestions(quesnr.Id);
        boolean showPosition=quesnr.Show_Questions_Position_gne__c;
        Decimal min_score,max_score;
        Integer position,count=1;
        String category_q,prevCategory_q;
        List<previewMode> previews = new List<previewMode>();
        categoryLookupMap = new Map<String,List<previewMode>>();
        System.debug('questions ** size' +questions.size() );
        if(questions!=null && questions.size()>0){
        isNoQuestions=false;
        for(Question_gne__c question: questions){
            
                min_score=question.Minimum_Score_gne__c;
                max_score=question.Maximum_Score_gne__c;
                previewMode preview = new previewMode();
                category_q=(question.Category_gne__c==null)?' ':question.Category_gne__c;
                if(count==1){
                    prevCategory_q=category_q;
                }
                List<SelectOption> answersList = new List<SelectOption>();  
                        preview.isNumeric=false;preview.ishelpAvailable=false;preview.listValues_less_three=false;
                        preview.helpText= question.Help_Text_gne__c;
                        preview.ishelpAvailable=(question.Help_Text_gne__c!=null);
                        preview.position=Integer.valueof(question.Position_gne__c);
                        preview.question=question.Title_gne__c;
                        preview.sectionTitle=category_q!=null?category_q:' ';
                        preview.weight=question.Weight_gne__c;
                        preview.qId=question.Id;
                        if(question.Type_gne__c.equals('Numeric')){
                            preview.isNumeric=true;
                            preview.answerNumeric='Numeric ('+String.valueof(min_score)+' - '+String.valueof(max_score)+')';
                        }
                        else{
                            List<String> Values;
                            List<String> Labels;
                            if(question.Values_gne__c!=null){
                           Values = question.Values_gne__c.split(',',-1);
                           }
                            if(question.Labels_gne__c!=null){
                                Labels=question.Labels_gne__c.split(',',-1);
                            }
                            
                            if(question.Type_gne__c.equals('List of Values')){   //category type equals list of values 
                                if( Values !=null && Values.size()==2){
                                preview.listValues_less_three=true;
                            }
                            else{
                              for(String value :Values  )
                              answersList.add(new SelectOption(value,value));
                            }
                            
                        }
                        else if(question.Type_gne__c.equals('Labels and Values')){ //category type equals Labels and values 
                            
                            for(String s : Labels){
                                answersList.add(new SelectOption(s,s));
                            }
                        }
                        else if(question.Type_gne__c.equals('Free Text')){
                          preview.isFreeText=true;
                          preview.freeText='Free Text'; 
                        }
                        }
                        
                        if(answersList!=null && answersList.size()>0){
                            preview.answerList=answersList;
                        }
                        
                        if(prevCategory_q.equals(category_q)){
                            previews.add(preview);
                        }
                        else{
                            categoryLookupMap.put(prevCategory_q,previews);
                            previews=null;
                            previews = new List<previewMode>();
                            previews.add(preview);
                        }
                        
                        if(count==questions.size() && count!=1)//last record
                        {
                            if(prevCategory_q.equals(category_q)){
                                
                                categoryLookupMap.put(prevCategory_q,previews);
                                
                            }
                            else{
                                categoryLookupMap.put(category_q,previews);
                            }
                        }
                        
                        if(count==questions.size() && count==1)//only one record 
                        {
                            categoryLookupMap.put(category_q,previews);
                        }
                        count++;
                        prevCategory_q=category_q;
            }
        }
        else{
            isNoQuestions=true;
            categoryLookupMap.put('No Questions exist',null);
        }
        
        System.debug('**categoery map**'+categoryLookupMap );
        
        return null;
    }
        
    public PageReference checkProduct(){
        
        System.debug('****quesnr***'+quesnr);
        isProduct=true;
        return null;
    }
    
}