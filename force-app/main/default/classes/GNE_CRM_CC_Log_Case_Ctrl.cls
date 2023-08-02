/**********************************************************************
Purpose: GNE_CRM_CC_Log_Case_Ctrl class is used to log the cases.
========================================================
History                                                            
-------                                                            
VERSION  AUTHOR        DATE            DETAIL                       
1.0                                 INITIAL DEVELOPMENT
1.1     Vijay       03/31/2020      allowing to save any text in the "Account Name" Field 
									using the "SAP Account ID" of Non-GNE-Account.
***********************************************************************/
public with sharing class GNE_CRM_CC_Log_Case_Ctrl {

    public GNE_CRM_CC_Case__c myObject {get; set;}
    public Boolean isEditMode {get; private set;}
    public Boolean isNewCase {get; private set;}
    public String sapId {get; set;}
    public String accountName {get; set;}
    public String inquiryParam {get; private set;}
    public List<GNE_CRM_CC_Related_Product__c> relatedProducts {get; set;}
    private List<GNE_CRM_CC_Related_Product__c> relatedProductsToDelete;
    public List<GNE_CRM_CC_Question__c> questions {get; set;}
    public List<GNE_CRM_CC_Answer__c> answers {get; set;}
    public Integer productToRemove {get; set;}
    public List<QuestionWrapper> questionWrappers {get; private set;}
    public Boolean isAccountReadOnly {get; private set;}
    public Boolean isAccountEdit {get; private set;}
    public id clonedcaseid;
    public string srRender{get;set;}
    public string warmcallRender{get;set;}
     public Boolean isEditexisting {get; private set;}
    
    //Jie added at May 10, 2017 for clone case from case detail page
    private String accountId;
    private boolean cloneCase;
    //private String oldCaseId;
    //end Jie additional
    
   //Vijay - default account Name
   public static final String DEFAULT_ACCOUNT_NAME = 'Non-GNE-Account'; 
     
    public GNE_CRM_CC_Log_Case_Ctrl(ApexPages.StandardController stdCtrl) {
    
       
       
    
        
        isAccountEdit = false;        
        isEditMode = true;
        isNewCase = false;
        cloneCase=false;
        if(!Test.isRunningTest()){
            stdCtrl.addFields(new List<String>{'Extreme_Weather__c' , 'Account_Name_ref__c', 'Contact_Name__c', 'Telephone__c', 'Call_Type__c', 'Email__c', 'Account_Name__c', 'SAP_Account_Id__c' ,
                'Account_Type__c', 'SAP_Account_Id_Sold_To__c', 'Address__c', 'Zip_Code__c', 'Inquiry__c', 'Warm_Call_Transfer_To_Name__c', 'OTN__c', 'Order_Number__c', 
                'Comments__c', 'OwnerId', 'Case_Status__c'});
        }
        myObject = (GNE_CRM_CC_Case__c)stdCtrl.getRecord();
        
        if(myObject.Inquiry__c == 'Adverse Event Call'){
        srRender = 'true';
        }
        else{
        srRender = 'false';
        }
        
        if(myObject.Inquiry__c == 'Warm / Internal Transfer'){
        warmcallRender = 'true';
        }
        else{
        warmcallRender = 'false';
        }
        
        
        if(myObject.Id == null){        
            isEditMode = false;
            isNewCase = true;
            copyCaseFromCaseDetail();   
                    
        } else if( myObject.Case_Status__c=='Closed'){
            isEditMode = false;
        } 
        
        isAccountReadOnly = false;
        
        
        
        
         listEmailtemplateoptions = new List<SelectOption>();
       mapTotemailtemplate = new Map<Integer, emailtemplate>();
       lsttemplate = new list<emailtemplate>();
        //As part of these change(CHG0185671) added "AND isActive=true"
        lsttemplate = [select id, Name, body, subject from emailtemplate where folder.name = 'GNE-CUSTOPS Cases Email Forms Templates' AND IsActive = true];
        lsttemplate.sort();
        if(lsttemplate.size()>0){
        for(emailtemplate em : lsttemplate){
       
        listEmailtemplateoptions.add(new SelectOption(em.Name,em.Name));
        }
       // listEmailtemplateoptions.sort();
        firsttemplate = lsttemplate[0].Name;
        }
        lstemailtracker = new list<GNE_Channel_Ops_Email_Tracker__c>();
         lsttrackerclass = new list<emailtrackerclass>();
         String extId=ApexPages.currentPage().getParameters().get('id');
         if(extId != null && extId != ''){
        renderTracker();    
        }
    } 
    
    //Jie added at May 10, 2017 for clone case from case detail page
    //when custOp case id is null, it could be a new case form or a clone case form, depends on the parameter 'caseId' value
            
    private void copyCaseFromCaseDetail(){
        String caseId=ApexPages.currentPage().getParameters().get('caseId');
        if(caseId!=null || String.isNotBlank(caseId)){
                List <GNE_CRM_CC_Case__c> cases=[select id, Extreme_Weather__c , Account_Name_ref__r.id, Contact_Name__c, Telephone__c, Call_Type__c, Email__c, Account_Name__c, SAP_Account_Id__c ,
                    Account_Type__c, SAP_Account_Id_Sold_To__c, Address__c, Zip_Code__c, Inquiry__c, Warm_Call_Transfer_To_Name__c, OTN__c, Order_Number__c, 
                    Comments__c, OwnerId, Case_Status__c from GNE_CRM_CC_Case__c where id=: caseId];
                
                if(cases!=null && cases.size()>0){
                     myObject.id = cases[0].id;         
                    //myObject.Account_Name_ref__r.id = cases[0].Account_Name_ref__r.id;
                    myObject.Contact_Name__c = cases[0].Contact_Name__c;
                    myObject.Telephone__c = cases[0].Telephone__c;
                    myObject.Call_Type__c = cases[0].Call_Type__c;
                    myObject.Email__c = cases[0].Email__c;
                    //myObject.Account_Name__c = cases[0].Account_Name__c;
                    //myObject.SAP_Account_Id__c = cases[0].SAP_Account_Id__c;
                    myObject.Account_Type__c = cases[0].Account_Type__c;
                    myObject.SAP_Account_Id_Sold_To__c = cases[0].SAP_Account_Id_Sold_To__c;
                    myObject.Address__c = cases[0].Address__c;
                    myObject.Zip_Code__c = cases[0].Zip_Code__c;
                    myObject.Inquiry__c = cases[0].Inquiry__c;
                    myObject.Warm_Call_Transfer_To_Name__c = cases[0].Warm_Call_Transfer_To_Name__c;
                    myObject.OTN__c = cases[0].OTN__c;
                    myObject.Order_Number__c = cases[0].Order_Number__c;
                    myObject.Comments__c = cases[0].Comments__c;
                    myObject.Case_Status__c = cases[0].Case_Status__c;
                    myObject.Extreme_Weather__c = cases[0].Extreme_Weather__c;
                    accountId=cases[0].Account_Name_ref__r.id;
                    cloneCase = true;
                    
                }
            }
            
        
    }
    
    private void updateRelatedProductsForClone(){
        if(relatedProducts!=null){
                
                List<GNE_CRM_CC_Related_Product__c> relatedProductsTemp = new List<GNE_CRM_CC_Related_Product__c>();                
                for(GNE_CRM_CC_Related_Product__c rp :  relatedProducts){
                    GNE_CRM_CC_Related_Product__c tempPrd=new GNE_CRM_CC_Related_Product__c();
                    tempPrd.Product__c = rp.Product__c;
                    tempPrd.Order__c = rp.Order__c;
                    relatedProductsTemp.add(tempPrd);
                }
                
                relatedProducts = relatedProductsTemp;
            }
        
    }
    
    //end Jie additional

    public void init(){
        initAccount();
        initProducts();
        initQuestions();
        
        if(cloneCase) {
            myObject.id=null;
            updateRelatedProductsForClone();
   
        }
    }

    private void initAccount(){
        
        if(accountId==null) accountId = ApexPages.currentPage().getParameters().get('accountId');
        
        isAccountReadOnly = !isEditMode && String.isNotBlank(accountId);
        
        
        
        if(isAccountReadOnly){
            try{
                Account acc = [SELECT Id, Name, SAP_ID_gne__c FROM Account WHERE Id = :accountId LIMIT 1];
                myObject.Account_Name__c = acc.Name;
                myObject.SAP_Account_Id__c = acc.SAP_ID_gne__c;
                myObject.Account_Name_ref__c = acc.Id;
            } catch(Exception ex){
                system.debug(ex);
            }
        }
        // Added to fix Defect 136
        String cloneparam =ApexPages.currentPage().getParameters().get('cloneparam');
        if(cloneparam == 'true'){
        isAccountEdit = true;
        }
        
        
        
    }

    private void initProducts(){
        
        if(myObject.id!=null && String.isNotBlank(myObject.id)){
            relatedProducts = [SELECT Id, Case_ref__c, Product__c, Order__c FROM GNE_CRM_CC_Related_Product__c WHERE Case_ref__c = :myObject.id ORDER BY Order__c];
        } else {
            relatedProducts = new List<GNE_CRM_CC_Related_Product__c>();
        }
        if(relatedProducts.size() == 0){
            addProduct();
        }
        relatedProductsToDelete = new List<GNE_CRM_CC_Related_Product__c>();
    } 

    private void initQuestions(){
        setQuestionWrappers(myObject.Inquiry__c);
    }

    public Boolean getCanAddProduct(){
        return relatedProducts.size() < 5;
    }

    public Boolean getCanRemoveProduct(){
        return relatedProducts.size() > 1;
    }

    public void addProduct(){
        GNE_CRM_CC_Related_Product__c product = new GNE_CRM_CC_Related_Product__c(Order__c = relatedProducts.size());
        relatedProducts.add(product);
    }

    public void removeProduct(){
        for(Integer i = relatedProducts.size() - 1; i >= productToRemove; i--){
            if(i == productToRemove){
                if(relatedProducts[i].Id != null){
                    relatedProductsToDelete.add(relatedProducts.remove(i));
                } else {
                    relatedProducts.remove(i);
                }
            } else {
                relatedProducts[i].Order__c--;
            }
        }
    }

    public PageReference cancel(){
        String retUrl = ApexPages.currentPage().getParameters().get('retUrl');
        if(String.isNotEmpty(retUrl)){
            return new PageReference(retUrl);
        }
        return new PageReference('/' + GNE_CRM_CC_Case__c.sObjectType.getDescribe().getKeyPrefix());
    }

    public PageReference save(){
        if(!isValid()){
            return null;
        }
        if(!isEditMode){
            myObject.OwnerId = UserInfo.getUserId();
        }
        if(!isAccountReadOnly){
            Account relatedAccount = getRelatedAccount(myObject.SAP_Account_Id__c, myObject.Account_Name__c);
            myObject.Account_Name_ref__c = relatedAccount.Id;
            if(String.isNotBlank(relatedAccount.Name) && relatedAccount.Name != DEFAULT_ACCOUNT_NAME){
            	myObject.Account_Name__c = relatedAccount.Name; 
            }
        }
        SavePoint sp = Database.setSavePoint();
        try{
            upsert myObject;
            saveProducts();
            saveAnswers();
        } catch (Exception ex){
            system.debug(ex);
            Database.rollback(sp);
            return null;
        }
      
        for(emailtrackerclass et : lsttrackerclass )
        {
        et.emtracker.Parent_Case__c = myObject.Id;
        upsert et.emtracker;
        }
      
        return new PageReference('/' + myObject.Id);
    }
    
    //Jie added on May 17 for the button save & new
    public PageReference saveAndNew(){
        //cloneCase = false;
        if(!isValid()){
            return null;
        }
        if(!isEditMode){
            myObject.OwnerId = UserInfo.getUserId();
        }
        if(!isAccountReadOnly){
            Account relatedAccount = getRelatedAccount(myObject.SAP_Account_Id__c, myObject.Account_Name__c);
            myObject.Account_Name_ref__c = relatedAccount.Id;
            if(String.isNotBlank(relatedAccount.Name) && relatedAccount.Name != DEFAULT_ACCOUNT_NAME){
            	myObject.Account_Name__c = relatedAccount.Name; 
            }
        }
        SavePoint sp = Database.setSavePoint();
        try{
            upsert myObject;
           // clonedcaseid = myobject.id;
            saveProducts();
            saveAnswers();
        } catch (Exception ex){
            system.debug(ex);
            Database.rollback(sp);
            return null;
        }
        
        
        for(emailtrackerclass et : lsttrackerclass )
        {
        et.emtracker.Parent_Case__c = myObject.Id;
        upsert et.emtracker;
        }
        
        
        //open an empty new case page
        myObject=new GNE_CRM_CC_Case__c();   
        PageReference page=new PageReference('/apex/GNE_CRM_CC_Log_Case');
        page.setRedirect(true);
        
        return page;
    }


    public PageReference saveAndClone(){
        if(!isValid()){
            return null;
        }
        if(!isEditMode){
            myObject.OwnerId = UserInfo.getUserId();
        }
        if(!isAccountReadOnly){
            Account relatedAccount = getRelatedAccount(myObject.SAP_Account_Id__c, myObject.Account_Name__c);
            myObject.Account_Name_ref__c = relatedAccount.Id;
            if(String.isNotBlank(relatedAccount.Name) && relatedAccount.Name != DEFAULT_ACCOUNT_NAME){
            	myObject.Account_Name__c = relatedAccount.Name; 
            }
        }
        SavePoint sp = Database.setSavePoint();
        try{
            upsert myObject;
            saveProducts();
            saveAnswers();
        } catch (Exception ex){
            system.debug(ex);
            Database.rollback(sp);
            return null;
        }
        
        for(emailtrackerclass et : lsttrackerclass )
        {
        et.emtracker.Parent_Case__c = myObject.Id;
        upsert et.emtracker;
        }
                     
        PageReference page=new PageReference('/apex/GNE_CRM_CC_Log_Case');
        page.getParameters().put('caseId', myObject.id);
        page.getParameters().put('cloneparam', 'true');
        page.setRedirect(true);
        return page;
       
    }
    
    //End of Jie update on May 2017

    private Boolean isValid(){
        Boolean isValid = true;
        isValid = isValid && validateAnswers();
        return isValid;
    }

    public void saveProducts(){
        
        List<GNE_CRM_CC_Related_Product__c> productsToDelete = new List<GNE_CRM_CC_Related_Product__c>();
        Boolean emptyRowRemoved = false;
        for(Integer i = 0; i < relatedProducts.size();){
            if(String.isEmpty(relatedProducts[i].Product__c)){
                if(relatedProducts[i].Id != null){
                    productsToDelete.add(relatedProducts[i]);
                }
                relatedProducts.remove(i);
                emptyRowRemoved = true;
            } else {
                if(relatedProducts[i].Case_ref__c == null ){
                    relatedProducts[i].Case_ref__c = myObject.Id;
                }
                if(emptyRowRemoved){
                    relatedProducts[i].Order__c = i;
                }
                i++;
            }
        }
        productsToDelete.addAll(relatedProductsToDelete);
        if(relatedProducts.size()>0){
            upsert relatedProducts;
            clonedcaseid = relatedProducts[0].Case_ref__c;
        }
        if(productsToDelete.size() > 0){
            delete productsToDelete;
        }
    }


    private Boolean validateAnswers(){
        Boolean allAnswersAreValid = true;
        for(QuestionWrapper qw :getValidQuestions()){
            if(!qw.validateAnswer()){
                qw.addErrorMessage();
                allAnswersAreValid = false;
            }
        }
        return allAnswersAreValid;
    }

    private List<QuestionWrapper> getValidQuestions(){
        List<QuestionWrapper> validQuestionWrappers = new List<QuestionWrapper>();
        Map<String, Boolean> externalIdsToCheckboxValue = new Map<String, Boolean>();
        for(QuestionWrapper qw :questionWrappers){
            externalIdsToCheckboxValue.put(qw.externalId, qw.checkboxValue);
        }

        for(QuestionWrapper qw :questionWrappers){
            String prerequisite = qw.prerequisite;
            if(String.isBlank(prerequisite) || (externalIdsToCheckboxValue.get(prerequisite) != null && externalIdsToCheckboxValue.get(prerequisite))){
                validQuestionWrappers.add(qw);
            }
        }
        return validQuestionWrappers;
    }

    private void saveAnswers(){
       String cloneparam =ApexPages.currentPage().getParameters().get('cloneparam');
        if(cloneparam != 'true'){
    
        List<GNE_CRM_CC_Answer__c> answersToUpsert = new List<GNE_CRM_CC_Answer__c>();
        Set<Id> validAnswers = new Set<Id>();
        for(QuestionWrapper qw :getValidQuestions()){
            GNE_CRM_CC_Answer__c answer = qw.getAnswer();
            if(answer.Case_ref__c == null){
                answer.Case_ref__c = myObject.Id;
            }
            answersToUpsert.add(answer);
            if(answer.Id != null){
                validAnswers.add(answer.Id);
            }
        }
        List<GNE_CRM_CC_Answer__c> answersToDelete = [SELECT Id FROM GNE_CRM_CC_Answer__c WHERE Id NOT IN :validAnswers AND Case_ref__c = :myObject.Id];
        
        upsert answersToUpsert;
        if(answersToDelete.size() > 0){
            delete answersToDelete;
        }
        }
        else{
        clonedcaseid = myObject.id;
        List<GNE_CRM_CC_Answer__c> answersToUpsert = new List<GNE_CRM_CC_Answer__c>();
        for(QuestionWrapper qw :getValidQuestions()){
            system.debug(qw+'==');
            GNE_CRM_CC_Answer__c answer = new GNE_CRM_CC_Answer__c();
            answer.Case_ref__c = clonedcaseid;
            answer.Question_ref__c = qw.question.Id;
            if(qw.type.equalsIgnoreCase('Dropdown')){
                answer.Selected_Answer__c = qw.selectedValue;
            } else if(qw.type.equalsIgnoreCase('Multi Select')){
                answer.Selected_Answer__c = String.join(qw.selectedValues, ';');
            } else if(qw.type.equalsIgnoreCase('Checkbox')){
                 answer.Selected_Answer__c = String.valueOf(qw.checkboxValue);
            } else if(qw.type.equalsIgnoreCase('Text')){
                answer.Selected_Answer__c = qw.selectedValue;
            } else if(qw.type.equalsIgnoreCase('Numeric')){
                 answer.Selected_Answer__c = qw.selectedValue;
            } else if(qw.type.equalsIgnoreCase('Alpha-Numeric')){
                 answer.Selected_Answer__c = qw.selectedValue;
            }
     
            answersToUpsert.add(answer);
            
         }
        upsert answersToUpsert;

        
        }
        
        
    }

    private Account getRelatedAccount(String sapId, String accountName){
        List<Account> matchingAccounts = [SELECT Id, Name FROM Account WHERE SAP_ID_gne__c = :sapId LIMIT 1];
        if(matchingAccounts.size() > 0){
            return matchingAccounts[0];
        }
        RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType = 'Account' AND DeveloperName = 'LWOHealthCareOrganization_gne' LIMIT 1];
        Account newAccountToReturn = new Account(Name = accountName, SAP_ID_gne__c = sapId, RecordTypeId = rt.Id);
        insert newAccountToReturn;
        return newAccountToReturn;
    }

    public List<GNE_CRM_CC_Question__c> getQuestions(String inquiry){
        
        return [SELECT Id, External_Id__c, Inquiry__c, Possible_Values__c, Question__c, Type__c, Order__c, Prerequisite__c, (SELECT Id, Case_ref__c, Selected_Answer__c FROM Answers__r WHERE Case_ref__c = :myObject.id) FROM GNE_CRM_CC_Question__c WHERE Inquiry__c = :inquiry ORDER BY Order__c];
    }

    public void setQuestionWrappers(){
        inquiryParam = ApexPages.currentPage().getParameters().get('inquiry');
         if(inquiryParam == 'Adverse Event Call'){
        srRender = 'true';
        
        myObject.Comments__c = '';
        }
        else{
        myObject.OTN__c = '';
        srRender = 'false';
        }
        
         if(inquiryParam == 'Warm / Internal Transfer'){
        warmcallRender = 'true';
        }
        else{
        myObject.Warm_Call_Transfer_To_Name__c = '';
        warmcallRender = 'false';
        }
        
        setQuestionWrappers(inquiryParam);
    }

    private void setQuestionWrappers(String inquiry){
    if(inquiry == 'Adverse Event Call'){
        srRender = 'true';
        }
        else{
        srRender = 'false';
        }
        
        if(inquiry == 'Warm / Internal Transfer'){
        warmcallRender = 'true';
        }
        else{
        warmcallRender = 'false';
        }
        
        questionWrappers = new List<QuestionWrapper>();
        system.debug(inquiry);
        for(GNE_CRM_CC_Question__c question :getQuestions(inquiry)){
            questionWrappers.add(new QuestionWrapper(question));
        }
    }

    public class QuestionWrapper{
        public GNE_CRM_CC_Question__c question {get; private set;}
        private GNE_CRM_CC_Answer__c answer;
        private String errorMessage;
        public String label {get; private set;}
        public String selectedValue {get; set;}
        public List<String> selectedValues {get; set;}
        public Boolean checkboxValue {get; set;}
        public String type {get; private set;}
        public String externalId {get; private set;}
        public String prerequisite {get; private set;}
        public List<SelectOption> possibleValues {get; private set;}
        

        public QuestionWrapper(GNE_CRM_CC_Question__c question){
            this.question = question;
            label = question.Question__c;
            type = question.Type__c;
            possibleValues = new List<SelectOption>();
            if(type.equalsIgnoreCase('Dropdown') || type.equalsIgnoreCase('Multi Select')){
                possibleValues.add(new SelectOption('','--None--'));
                for(String value :question.Possible_Values__c.split(';;;')){
                    possibleValues.add(new SelectOption(value, value));
                }
            }
            externalId = question.External_Id__c;
            prerequisite = question.Prerequisite__c;
            if(question.Answers__r.size()>0){
                setAnswer(question.Answers__r[0]);
            } else {
                answer = new GNE_CRM_CC_Answer__c(Question_ref__c = question.Id);
            }
        }

        private void setAnswer(GNE_CRM_CC_Answer__c answer){
            this.answer = answer;
            if(type.equalsIgnoreCase('Multi Select') && String.isNotBlank(answer.Selected_Answer__c)){
                selectedValues = answer.Selected_Answer__c.split(';');
            } else if(type.equalsIgnoreCase('Checkbox')){
                checkboxValue = Boolean.valueOf(answer.Selected_Answer__c);
            } else if(type.equalsIgnoreCase('Dropdown') || type.equalsIgnoreCase('Text') || type.equalsIgnoreCase('Numeric') || type.equalsIgnoreCase('Alpha-Numeric')){
                selectedValue = answer.Selected_Answer__c;
            }
        }

        public GNE_CRM_CC_Answer__c getAnswer(){
            updateAnswer();
            return answer;
        }

        private void updateAnswer(){
            if(type.equalsIgnoreCase('Dropdown')){
                setPicklistAnswer();
            } else if(type.equalsIgnoreCase('Multi Select')){
                setMultiSelectAnswer();
            } else if(type.equalsIgnoreCase('Checkbox')){
                setCheckboxAnswer();
            } else if(type.equalsIgnoreCase('Text')){
                setTextAnswer();
            } else if(type.equalsIgnoreCase('Numeric')){
                setNumberAnswer();
            } else if(type.equalsIgnoreCase('Alpha-Numeric')){
                setAlphaNumericAnswer();
            }
        }

        private void setPicklistAnswer(){
            answer.Selected_Answer__c = selectedValue;
        }

        private void setMultiSelectAnswer(){
            answer.Selected_Answer__c = String.join(selectedValues, ';');
        }

        private void setCheckboxAnswer(){
            answer.Selected_Answer__c = String.valueOf(checkboxValue);
        }

        private void setTextAnswer(){
            answer.Selected_Answer__c = selectedValue;
        }

        private void setNumberAnswer(){
            answer.Selected_Answer__c = selectedValue;
        }

        private void setAlphaNumericAnswer(){
            answer.Selected_Answer__c = selectedValue;
        }

        public Boolean validateAnswer(){
            Boolean isValid = true;
            errorMessage = '';
            if(type.equalsIgnoreCase('Dropdown')){
                isValid = validatePicklistAnswer();
            } else if(type.equalsIgnoreCase('Multi Select')){
                isValid = validateMultiSelectAnswer();
            } else if(type.equalsIgnoreCase('Checkbox')){
                isValid = validateCheckboxAnswer();
            } else if(type.equalsIgnoreCase('Text')){
                isValid = validateTextAnswer();
            } else if(type.equalsIgnoreCase('Numeric')){
                isValid = validateNumberAnswer();
            } else if(type.equalsIgnoreCase('Alpha-Numeric')){
                isValid = validateAlphaNumericAnswer();
            }
            return isValid;
        }

        private Boolean validatePicklistAnswer(){
            if(String.isBlank(selectedValue)){
                return true;
            }
            for(SelectOption so :possibleValues){
                if(so.getValue().equalsIgnoreCase(selectedValue)){
                    return true;
                }
            }
            
            errorMessage = 'Question "' + label + '": selected value "' + selectedValue + '" is not valid';
            return false;
        }

        private Boolean validateMultiSelectAnswer(){
            if(selectedValues.size() == 0){
                return true;
            }

            List<String> invalidValues = new List<String>();
            for(String selectedValue :selectedValues){
                Boolean isValid = false;
                for(SelectOption so :possibleValues){
                    if(so.getValue().equalsIgnoreCase(selectedValue)){
                        isValid = true;
                    }
                }
                if(!isValid){
                    invalidValues.add(selectedValue);
                }
            }

            if(invalidValues.size()>0){
                errorMessage = 'Question "' + label + '": following value(s) are invalid: ';
                for(String invalidValue :invalidValues){
                    errorMessage += '"' + invalidValue + '" ';
                }
                return false;
            } else {
                return true;
            }
        }

        private Boolean validateCheckboxAnswer(){
            return true;
        }

        private Boolean validateTextAnswer(){
            return true;
        }

        private Boolean validateNumberAnswer(){
            Boolean isValid = String.isBlank(selectedValue) || selectedValue.isNumeric();
            if(isValid){
                return true;
            }
            errorMessage = 'Question "' + label + '": answer should contain only digits';
            return false;
        }

        private Boolean validateAlphaNumericAnswer(){
            Boolean isValid = String.isBlank(selectedValue) || selectedValue.isAlphaNumeric();
            if(isValid){
                return true;
            }
            errorMessage = 'Question "' + label + '": answer should contain only digits or letters';
            return false;
        }

        public void addErrorMessage(){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage);
            ApexPages.addMessage(myMsg);
        }
    }        
       
    
    
     public string subjectTemplate{get; set;}
     public string contentTemplate{get; set;}
     list<emailtemplate> lsttemplate;
     public List<SelectOption> listEmailtemplateoptions{get; set;}
     public string firsttemplate{get; set;}
     public Map<Integer, emailtemplate> mapTotemailtemplate{get; set;} 
     public Map<Integer, attachment> mapToattachment{get; set;} 
     public String selectedtemplate {get; set;}
     public list<emailtrackerclass> lsttrackerclass{get;set;}
     public list<GNE_Channel_Ops_Email_Tracker__c> lstemailtracker{get; set;}
     
     
     public class emailtrackerclass{
        public GNE_Channel_Ops_Email_Tracker__c emtracker{get; set;}
        public map<integer, attachment> maatt{get; set;}
        public emailtrackerclass(GNE_Channel_Ops_Email_Tracker__c em){
        this.emtracker = em;
        this.maatt = new map<integer, attachment>();
        integer i = 0;
        string strtemplate = string.valueof(em.Attachments__c);
        if(strtemplate != null){
        list<string> liststrtemplate = strtemplate.split(';');
        for(string str: liststrtemplate){
        list<string> strr = str.split('--');
        list<attachment> at = new list<attachment>();
        
        if(strr[1] != null){
        at= [select id, name from attachment where name =: strr[1] ];
        //parent.name =: strr[0] AND name =: strr[1] ];
                                                  
        
        maatt.put(i, at[0]);
        i++;
        }
        
        
        }
        }  
        }
        }
        
        
     public void templateChange(){
        string passedParam1 = Apexpages.currentPage().getParameters().get('myParam');
        string tempname = passedParam1;
        emailtemplate em = [select id, name, subject, body from emailtemplate where name =: tempname ];
        list<attachment> lstatt = new list<attachment>();
       lstatt = [select name, id from attachment where parentid =: em.id  ];
        /*Always clear the List when begin so that previous values will be removed.*/
        
        subjectTemplate = em.subject;
        contentTemplate = em.body;
        contentTemplate = contentTemplate.replace('<div >', '');
        contentTemplate = contentTemplate.replace('</div>', '');
        contentTemplate = contentTemplate.replace('{!IF(GNE_CRM_CC_Case__c.Name=\'\', \"\" , \"Case Number: \" +GNE_CRM_CC_Case__c.Name)}', '');
        system.debug(contentTemplate);
        Integer i = 0;
        for (emailtemplate e : lsttemplate) {
        mapTotemailtemplate.put(i, e);
        i++;
        }
        i = 0;
        mapToattachment = new map<integer, attachment>();
        if(lstatt.size()>0){
        for (attachment e : lstatt) {
        mapToattachment.put(i, e);
        i++;
        }
        }
        else{
        mapToattachment = new map<integer, attachment>();
        }
        }
       
       
       
      
        
        
        
        
        public void sendEmailFormsAF(){
          string passedParam1 = Apexpages.currentPage().getParameters().get('myParamm');
        string totalstr = passedParam1;
      
        
        List<String> parts = totalstr.split('====');
      string templatename = parts[0];
      string emailRecipients = parts[1]; 

        emailtemplate template = [Select Id, subject, body, name from emailtemplate where Name =: templatename limit 1];
        list<attachment> lstatt = new list<attachment>();
        lstatt = [select name, id from attachment where parentid =: template.id  ];
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        OrgWideEmailAddress orgWideAddress = null;
        try{
       // orgWideAddress = [SELECT Id, Address FROM OrgWideEmailAddress WHERE DisplayName = 'GNE FORMS TEST'];
        string sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        
        orgWideAddress = [SELECT Id, Address FROM OrgWideEmailAddress WHERE DisplayName = 'noreplyco-d@gene.com'];
        if(sfdcBaseURL.contains('dev') || sfdcBaseURL.contains('sqa') || sfdcBaseURL.contains('uat')){
        orgWideAddress = [SELECT Id, Address FROM OrgWideEmailAddress WHERE DisplayName = 'gneforms-d@gene.com'];
        }
        } catch (Exception ex){
        system.debug('OrgWide address or configuration not found');
        }
        if(orgWideAddress != null){
        mail.setOrgWideEmailAddressId(orgWideAddress.Id);
        }
        //mail.setSenderDisplayName('doNotReply@Genentech.com');
        mail.setTreatTargetObjectAsRecipient(false);
        //mail.setWhatId(cc.Id);
        list<string> lstemail = new list<string>();
        set<string> setemail = new set<string>();
        lstemail = emailRecipients.split(';');
        system.debug('emailRecipients'+lstemail);
        setemail.addAll(lstemail);
        list<contact> lstc = new list<contact>();
        ChannelOps_App_Property__c property=[select Account_Name_for_sending_email__c from ChannelOps_App_Property__c where active__c=true and Application_Name__c='Spoilage From' limit 1];
        lstc =[select id, name, email from Contact where name=:accountName limit 1];
        EmailServicesFunction emsf = [select id, FunctionName from EmailServicesFunction where functionname='ChannelOpsCasesSendtemplatereply'];
        EmailServicesAddress emsa = [SELECT EmailDomainName,LocalPart FROM EmailServicesAddress where FunctionId=: emsf.id];
        string replyemail = emsa.LocalPart+'@'+emsa.EmailDomainName;
        mail.setReplyTo(replyemail);
        mail.setTemplateID(template.Id);
        if(lstc.size()>0){
        mail.setTargetObjectId(lstc[0].Id);
        boolean b = setemail.remove(lstc[0].Email);
        list<string> lststr = new list<string>();
        lststr.addall(setemail);
        mail.setToAddresses(lstemail);
        system.debug('emailRecipients'+lststr);
        mail.setBccAddresses( new String[]{UserInfo.getUserEmail()});

        }
        else{
         list<string> lststr = new list<string>();
        lststr.addall(setemail);
        contact c = [select id from contact limit 1];
        mail.setTargetObjectId(c.Id);
         mail.setToAddresses(lststr);
         system.debug('emailRecipients'+lststr);
        mail.setBccAddresses( new String[]{UserInfo.getUserEmail()});

        }
        mail.setSaveAsActivity(false);
        emailsToSend.add(mail);
        if(emailsToSend.size()>0){
        try{
          Messaging.sendEmail(emailsToSend);
          Messaging.SingleEmailMessage sem = emailsToSend[0];
          GNE_Channel_Ops_Email_Tracker__c et = new GNE_Channel_Ops_Email_Tracker__c();
          et.From_Address__c = orgWideAddress.Address;
          et.To_Address__c = emailRecipients;
          et.BCC__c = UserInfo.getUserEmail();
          et.GNE_Sent_by_User__c = userinfo.getuserid();
          et.Subject__c = template.subject;
          et.Body__c = template.body;
          et.Time_Stamp__c = datetime.now();
           
            String exttId=ApexPages.currentPage().getParameters().get('id');
            if(exttId != null && exttId != ''){
           et.Parent_Case__c = exttId;
          }  
          string str = '';
          if(lstatt.size()>0){
          for(attachment att : lstatt){
          str = str + template.name + '--'+att.name+';';
          }
          et.Attachments__c = str;
          }
          
          insert et;
         lsttrackerclass.add(new emailtrackerclass(et));
        } catch(Exception ex){
       // return ex.getMessage();
        }
        }
      //  return null;
      
       
      
      
        }
       
       
       
        
        
        
        
        
       
        public void renderTracker(){
        String extId=ApexPages.currentPage().getParameters().get('id');
         lsttrackerclass = new list<emailtrackerclass>();
         if(extId == null || extId == ''){
         lstemailtracker = [select Attachments__c, BCC__c, Body__c, From_Address__c, Subject__c, Time_Stamp__c, To_Address__c, GNE_Sent_by_User__c from GNE_Channel_Ops_Email_Tracker__c where Parent_Case__c = null AND GNE_Sent_by_User__c =: userinfo.getuserid() ORDER BY createddate DESC];
         }
         else{
         lstemailtracker = [select Attachments__c, BCC__c, Body__c, From_Address__c, Subject__c, Time_Stamp__c, To_Address__c, GNE_Sent_by_User__c from GNE_Channel_Ops_Email_Tracker__c where Parent_Case__c =: extId  ORDER BY createddate DESC];
       
         }
        if(lstemailtracker!=null && lstemailtracker.size()>0)
        for(GNE_Channel_Ops_Email_Tracker__c l : lstemailtracker){
        lsttrackerclass.add(new emailtrackerclass(l));
        system.debug(lsttrackerclass);
        }
        }
    

}