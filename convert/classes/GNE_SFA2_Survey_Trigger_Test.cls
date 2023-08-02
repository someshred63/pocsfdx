/************************************************************
*  @author: Sreedhar Karukonda
*  Date: 12/12/2012
*  Description: This class GNE_SFA2_Survey_Trigger_Test test class to test the triggers on Survey_gne__c object
*  
*  Modification History
*  Date        Name                 Description
*  2014-01-13  Piotr Przesmycki     Fixed test and removed SeeAllData=true annotation
*  2014-02-14  Piotr Przesmycki     Modified unit test to use GNE_SFA2_Triggers_Test_Util for creating data 
*************************************************************/
//@isTest(SeeAllData=true) 
@isTest
private class GNE_SFA2_Survey_Trigger_Test {

    /* Create Data Methods*/
    public static Call2_vod__c getCall(){
        Account acc = getAcccount();
        Call2_vod__c call = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod('No Collateral');
        call.Meal_Expense_gne__c        = true;
        call.Planned_Attendees_gne__c   = 3;
        call.Actual_Attendees_gne__c    = 3;
        call.Detailed_Products_vod__c   = 'Rituxan - GPA/MPA';
        call.RecordTypeId               = '01270000000HfnbAAC';
        call.Account_vod__c             = acc.id;
        call.Status_vod__c              = 'Saved_vod';
        call.Parent_Address_vod__c      = getAddress(acc).id;
        call.Call_Datetime_vod__c       = System.now();
        call.Territory_vod__c           = '00X3607-SPOKANE-STD';
        call.Call_Type_vod__c           = 'Group Detail';
        call.Completed_gne__c           = false;
        call.Address_vod__c             = '60 HOSPITAL RD, 997, NEWNAN, GA 30263';
        call.Call_Date_vod__c           = System.now().date();
        call.Attendees_vod__c           = 2;
        call.Attendee_Type_vod__c       = 'Group_Account_vod';
        call.User_Business_Role_gne__c  = 'Clinical Specialist - Actemra';
        call.Address_Line_1_vod__c      = '60 HOSPITAL RD';
        call.Address_Line_2_vod__c      = '997';
        call.City_vod__c                = 'NEWNAN';
        call.State_vod__c               = 'GA';
        call.Zip_4_vod__c               = '1210';
        call.Zip_vod__c                 = '99999';
        return call;
    }
    
    public static Address_vod__c getAddress(Account testAccount){
        Address_vod__c address = GNE_SFA2_Triggers_Test_Util.prepareAddress_vod(testAccount.Id, '611 Gateway Blvd', true, 'Unit Test Address Name');
        address.Address_line_2_vod__c   = 'Street Address 2';
        address.city_vod__c             = 'South San Francisco';
        address.state_vod__c            = 'CA';
        address.zip_vod__c              = '94580';
        address.fax_vod__c              = '1234567890';
        address.fax_2_vod__c            = '1234567890';
        address.Primary_vod__c          = true;
        insert address;
        System.assert(address.id != null);
        return address;
    }
    
    private static Account getAcccount(){
        Account testAccount = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('testName');
        insert testAccount;
        System.assert(testAccount.id != null);
        return testAccount;
    }
    
    private static Call2_vod__c getCall(Account acc, Address_vod__c add){
        Call2_vod__c call = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod('No Collateral');
        call.Meal_Expense_gne__c        = true;
        call.Planned_Attendees_gne__c   = 3;
        call.Actual_Attendees_gne__c    = 3;
        call.Detailed_Products_vod__c   = 'Rituxan - GPA/MPA';
        call.RecordTypeId               = '01270000000DyvdAAC';
        call.Account_vod__c             = acc.id;
        call.Status_vod__c              = 'Saved_vod';
        call.Parent_Address_vod__c      = add.id;
        call.Call_Datetime_vod__c       = System.now();
        call.Territory_vod__c           = '00X3607-SPOKANE-STD';
        call.Call_Type_vod__c           = 'Group Detail';
        call.Interaction_Status_gne__c  = 'Planned';
        call.Completed_gne__c           = false;
        call.Address_vod__c             = '60 HOSPITAL RD, 997, NEWNAN, GA 30263';
        call.Attendees_vod__c           = 2;
        call.Attendee_Type_vod__c       = 'Group_Account_vod';
        call.User_Business_Role_gne__c  ='Clinical Specialist - Actemra';
        call.Address_Line_1_vod__c      ='60 HOSPITAL RD';
        call.Address_Line_2_vod__c      ='997';
        call.City_vod__c                ='NEWNAN';
        call.State_vod__c               ='GA';
        call.Zip_4_vod__c               ='1210';
        call.Zip_vod__c                 ='99999';
        return call;
    }
    
    public static List<Call2_vod__c> getCalls(integer numberOfCalls){
        List<Call2_vod__c> calls = new List<Call2_vod__c>();
        Account acc = getAcccount();
        Address_vod__c add = getAddress(acc);
        
        for(integer idx =0; idx < numberOfCalls; idx++){
            calls.add(getCall(acc, add));
        }
        return calls;
    }
    public static Survey_Response_gne__c getSurveyResp(Survey_gne__c s, Question_gne__c q){
        Survey_Response_gne__c resp = GNE_SFA2_Triggers_Test_Util.prepareSurvey_Response_gne(s.Id);
        resp.Response_Score_gne__c=0.112;
        resp.Question_gne__c = q.id;
        return resp;       
    }
    
    
    public static Survey_Response_gne__c getSurveyResp1(Survey_gne__c s){
        Survey_Response_gne__c resp = GNE_SFA2_Triggers_Test_Util.prepareSurvey_Response_gne(s.Id);
        resp.Response_Score_gne__c = 0.112;
        resp.Type_gne__c = 'Labels and Values';
        resp.Labels_gne__c ='Test1,Test2,Test3';
        resp.Selected_Label_gne__c = 'Test1,Test3';
        resp.Category_gne__c = 'Category';
        resp.Title_gne__c = 'Title';
        return resp;       
    }
    
    
    public static List<Survey_Response_gne__c> getSurveyResponse( Survey_gne__c s){
        List<Question_gne__c> qts = new List<Question_gne__c>();
        for(Integer i = 1; i<=6; i++){
            qts.add(prepQuestion(s.Questionnaire_gne__c, i));
        }
        
        insert qts;
        List<Survey_Response_gne__c> respList = new List<Survey_Response_gne__c>();
        
        respList.add (getSurveyResp(s, qts[0]));
        respList.add (getSurveyResp(s, qts[1]));
        respList.add (getSurveyResp(s, qts[2]));
        respList.add (getSurveyResp(s, qts[3]));
        respList.add (getSurveyResp(s, qts[4]));
        respList.add (getSurveyResp(s, qts[5]));
        return respList;       
    }

    private static Question_gne__c prepQuestion(Id questionnaireId, Integer position){
        Question_gne__c q = GNE_SFA2_Triggers_Test_Util.prepareQuestion_gne(questionnaireId);
        q.Position_gne__c       = position;
        q.Maximum_Score_gne__c  = 1.0;
        return q;
    }
    
    static testMethod void testDMLOperationsOnSurvey1() {
        User SFA2User = GNE_SFA2_Util.selectSFA2User();
        System.runAs(SFA2User){ 
            try{
                test.startTest();

                Product_vod__c prod = GNE_SFA2_Triggers_Test_Util.prepareProduct_vod();
                prod.Name='Lucentis - AMD';
                prod.DETAIL_PRODUCT_SUBTYPE_CODE_GNE__C='TheraDisease';
                insert prod;
                System.assert(prod!= null, 'Product Insert Failed');
                
                Questionnaire_gne__c questionnaire = GNE_SFA2_Triggers_Test_Util.prepareQuestionnaire_gne(true);
                questionnaire.Type_gne__c='Lucentis Predictive Profiling';
                insert questionnaire;
                System.assert(questionnaire.id != null, 'Questionnaire id is missing');

                Account acc = getAcccount();

                Survey_gne__c survey = GNE_SFA2_Triggers_Test_Util.prepareSurvey_gne(questionnaire.id);
                survey.Account__c=acc.id;
                insert survey;
                System.assert(survey.id != null);

                List<Survey_gne__c> qSurvey = [Select Questionnaire_gne__c, Name, LastModifiedDate, Id, Account__c From Survey_gne__c  
                                            where Questionnaire_gne__c = :questionnaire.id
                                            and Account__c = :acc.id];
                System.assert(qSurvey.size() == 1, 'Survey is not created'); 

                System.debug(' survey.id :' + survey.id +'acc.id :' + acc.id +' questionnaire.id :' +questionnaire.id );
                List<Survey_Response_gne__c> respList = getSurveyResponse(survey);
                insert respList;

                update qSurvey;

                test.stopTest();

                List<Product_Metrics_vod__c> brandAffil = [Select Id, name, Segment_Lucentis_gne__c, Account_vod__c from Product_Metrics_vod__c 
                                                    where Account_vod__c = : acc.id];
                System.assert(brandAffil.size() == 1 , 'Brand Affiliation is should be created');        
            }catch(Exception e){
                System.debug(e.getMessage());
                System.assert(false, e.getMessage());
            }
        }
    }
    static testMethod void testDMLOperationsOnSurvey2() {
        User SFA2User = GNE_SFA2_Util.selectSFA2User();
        System.runAs(SFA2User){ 
            try{
                test.startTest();

                Product_vod__c prod = GNE_SFA2_Triggers_Test_Util.prepareProduct_vod();
                prod.Name='Lucentis - AMD';
                prod.DETAIL_PRODUCT_SUBTYPE_CODE_GNE__C='TheraDisease';
                insert prod;
                System.assert(prod!= null, 'Product Insert Failed');
                
                Questionnaire_gne__c questionnaire = GNE_SFA2_Triggers_Test_Util.prepareQuestionnaire_gne(true);
                questionnaire.Type_gne__c='Lucentis Predictive Profiling';
                insert questionnaire;
                System.assert(questionnaire.id != null, 'Questionnaire id is missing');

                Account acc = getAcccount();

                Survey_gne__c survey = GNE_SFA2_Triggers_Test_Util.prepareSurvey_gne(questionnaire.id);
                survey.Account__c=acc.id;
                insert survey;
                System.assert(survey.id != null);

                List<Survey_gne__c> qSurvey = [Select Questionnaire_gne__c, Name, LastModifiedDate, Id, Account__c From Survey_gne__c  
                                            where Questionnaire_gne__c = :questionnaire.id
                                            and Account__c = :acc.id];
                System.assert(qSurvey.size() == 1, 'Survey is not created');

                List<Survey_Response_gne__c> respList = getSurveyResponse(survey);
                insert respList;
                delete qSurvey;

                test.stopTest();

                List<Product_Metrics_vod__c> brandAffil = [Select Id, name, Segment_Lucentis_gne__c, Account_vod__c from Product_Metrics_vod__c 
                                                    where Account_vod__c = : acc.id];
                System.assert(brandAffil.size() == 1 , 'Brand Affiliation is should be created');

                /*undelete added just for coverage - it dosen't contain any logic*/
                undelete qSurvey;
            }catch(Exception e){
                System.assert(false, e.getMessage());
            }
        }
    }
    
    static testMethod void testSurveyResponse(){
        User SFA2User = GNE_SFA2_Util.selectSFA2User();
        System.runAs(SFA2User){ 
            try{
                test.startTest();
                Questionnaire_gne__c questionnaire = GNE_SFA2_Triggers_Test_Util.prepareQuestionnaire_gne(true);
                questionnaire.Type_gne__c='Lucentis Predictive Profiling';
                insert questionnaire;
                System.assert(questionnaire.id != null, 'Questionnaire id is missing');

                Account acc = getAcccount();

                Survey_gne__c survey = GNE_SFA2_Triggers_Test_Util.prepareSurvey_gne(questionnaire.id);
                survey.Account__c=acc.id;
                insert survey;
                System.assert(survey.id != null);

                Survey_Response_gne__c resp1 = getSurveyResp1(survey);
                insert resp1;
                System.assert(resp1 != null, 'Response should be created');
                update resp1;
                
                Survey_Response_gne__c resp2 = getSurveyResp1(survey);
                resp2.Type_gne__c = 'List of Values';
                resp2.Response_Score_gne__c = 10;
                insert resp2;
                System.assert(resp2 != null, 'Response should be created');
                update resp2;
                
                Survey_Response_gne__c resp3 = getSurveyResp1(survey);
                resp3.Type_gne__c = 'Numeric';
                resp3.Response_Score_gne__c = 10;
                insert resp3;
                System.assert(resp3 != null, 'Response should be created');
                update resp3;
                
                Survey_Response_gne__c resp4 = getSurveyResp1(survey);
                resp4.Type_gne__c = 'Free Text';
                insert resp4;
                System.assert(resp4 != null, 'Response should be created');
                update resp4;                

                test.stopTest();
            }catch(Exception e){

                System.assert(false, e.getMessage());
            }
        }
    } 
}