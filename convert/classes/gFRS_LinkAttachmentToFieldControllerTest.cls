/**
* @author GFRS Dev Team
* @date 28/02/2017
* @description gFRS_LinkAttachmentToFieldControllerTest - test class for gFRS_LinkAttachmentToFieldController
*/
@isTest
private class gFRS_LinkAttachmentToFieldControllerTest {
    class TestSettings {
        Account acc;
        GFRS_Organization__c org;
        GFRS_Funding_Request__c fundingRequest; 
        GFRS_Program__c program;
        GFRS_Location__c loc;
        GFRS_Annual_Evaluation__c evaluation;
        Attachment att;
        Attachment programAtt;
        List<Attachment> attList;
        GFRS_Settings__c customSetting = new GFRS_Settings__c();
        GFRS_Content__c content = new GFRS_Content__c();
        GFRS_Content_Translation__c translation = new GFRS_Content_Translation__c();
        gFRS_LinkAttachmentToFieldController controller;

         public TestSettings(){
            loadContentAndCustomSettingsValues();
            acc = gFRS_TestCreationUtils.createAccount('gFRS_LinkAttachmentToFieldControllerTestAcc');
            insert acc;
            org = gFRS_TestCreationUtils.createOrganization('TestOrg1', acc);
            insert org;
            loc = gFRS_TestCreationUtils.createLocation('gFRS_FundingRequestReadControllerTesterLoc',org.id);
            insert loc;
            fundingRequest = gFRS_TestCreationUtils.createFundingRequest(gFRS_Util.TYPE_HC_CHAR, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_Util.REQUEST_DEFAULT_SUB_STATUS, gFRS_Util.REQUEST_DEFAULT_SUB_STATUS, '', org.Id, loc.Id);
            insert fundingRequest;
            fundingRequest = [select id, RecordTypeId, Status__c,Sub_Status__c,External_Sub_status__c,Location__c,Evaluation_Summary_of_results_file__c,Foundation_Classified__c,Organization__c,Record_Type_Name__c from GFRS_Funding_Request__c where id=:fundingRequest.Id];
            att = new Attachment(parentId = fundingRequest.Id, name = 'testName2', body = Blob.valueOf('testBody1'));
            insert att;
            att = gFRS_TestCreationUtils.createAttachment(fundingRequest.Id, 'testName2', Blob.valueOf('testBody2'));
            insert att;
            evaluation = new GFRS_Annual_Evaluation__c( Funding_Request__c = fundingRequest.Id );
            insert evaluation;
            evaluation = [Select Id, Name, Funding_Request__c, Financial_Report__c from GFRS_Annual_Evaluation__c where Funding_Request__c =: fundingRequest.Id];
            program = new GFRS_Program__c( Type__c = 'progType', Funding_Request__c = fundingRequest.Id);
            insert program;
            program = [Select Id, Name, Funding_Request__c from GFRS_Program__c where Funding_Request__c =: fundingRequest.Id];
            programAtt = gFRS_TestCreationUtils.createAttachment(program.Id, 'testNameForProgram', Blob.valueOf('testBodyforProgram'));
            insert programAtt;
            attList = [SELECT Id, name, body, ParentId, LastModifiedDate, CreatedBy.Name FROM Attachment WHERE ParentId =: fundingRequest.Id];
            
         }

         public void setupControllerVariables(){
            controller = new gFRS_LinkAttachmentToFieldController();
            controller.needConfirmation = false;
            controller.showRelatedRecordPicklist = false;
            controller.request = fundingRequest; 
            controller.currentObject = controller.request;  
            controller.queryLimit = 5;             
         }
    }
    
    static testmethod void testConstructorForFundingRequest(){
        TestSettings ts = new TestSettings();
        ApexPages.currentPage().getParameters().put('id',ts.fundingRequest.Id);
        ts.setupControllerVariables();
        
        System.assertEquals(ts.controller.objectId,ts.fundingRequest.Id);
        System.assertEquals(ts.controller.selectedObject,gFRS_Util.FUNDING_REQUEST_API_NAME);
        System.assertEquals(String.valueOf(ts.controller.currentObject.get('Record_Type_Name__c')), gFRS_Util.TYPE_HC_CHAR_NAME);
        System.assertEquals(gFRS_Settings__c.getValues('Sect_FundReq_HcChar').Value__c,'Loa_page;Evaluation_page');

        ts.controller.getDisablePrevious();
        System.assertEquals(true,ts.controller.getDisablePrevious());
        ts.controller.getDisableNext();
        System.assertEquals(true,ts.controller.getDisableNext());
        ts.controller.offsetSize = ts.controller.queryLimit;
        ts.controller.getDisablePrevious();
        System.assertEquals(false,ts.controller.getDisablePrevious());
        ts.controller.offsetSize = 0;
        ts.controller.countTotalRecords = 10;
        ts.controller.getDisableNext();
        System.assertEquals(false,ts.controller.getDisableNext());
        ts.controller.back();
    }

    static testmethod void testConstructorForIncorrectObject(){
        TestSettings ts = new TestSettings();
        ApexPages.currentPage().getParameters().put('id',ts.acc.Id);
        ts.setupControllerVariables();
        List<Apexpages.Message> messages = ApexPages.getMessages();
        messages = ApexPages.getMessages();
        Boolean hasFundingRequestId = true;
        for(Apexpages.Message msg:messages){
            if (msg.getDetail().contains('Unable to find funding request.')) hasFundingRequestId = false; 
        }
        System.assertEquals(false, hasFundingRequestId);
    }

    static testmethod void testOnChangeObjectValue(){
        TestSettings ts = new TestSettings();
        ApexPages.currentPage().getParameters().put('id',ts.fundingRequest.Id);
        ts.setupControllerVariables();
        ts.controller.selectedObject = gFRS_Util.ORGANIZATION_API_NAME;
        ts.controller.onChangeObjectValue();
        System.assertEquals(ts.org.Id, ts.controller.selectedRelatedRecord);
        System.assertEquals(0, ts.controller.attachments.size());
        ts.controller.selectedObject = gFRS_Util.PROGRAM_API_NAME;
        ts.controller.onChangeObjectValue();
        System.assertEquals(1,ts.controller.relatedPrograms.size());
        System.assertEquals(1, ts.controller.attachments.size());
        System.assertEquals(true,ts.controller.showRelatedRecordPicklist);
    }

    static testmethod void testOnChangeSectionValue(){
        TestSettings ts = new TestSettings();
        ApexPages.currentPage().getParameters().put('id',ts.fundingRequest.Id);
        ts.setupControllerVariables();
        ts.controller.selectedSection = 'Evaluation_page';
        ts.controller.onChangeSectionValue();
        System.assertEquals(false,ts.controller.needConfirmation);
        System.assertEquals('',ts.controller.selectedAttachment);
        System.assertEquals(true,ts.controller.attachmentFieldsList.size() > 1);
    }

    static testmethod void testOnChangeAttachmentFieldName(){
        TestSettings ts = new TestSettings();
        ApexPages.currentPage().getParameters().put('id',ts.fundingRequest.Id);
        ts.setupControllerVariables();
        ts.controller.selectedSection = 'Evaluation_page';
        ts.controller.onChangeSectionValue();
        ts.controller.selectedAttachmentField = 'Evaluation_Summary_of_results_file__c';
        ts.controller.onChangeAttachmentFieldName();  
        ts.controller.onChangeRelatedRecord();
        System.assertEquals(1,ts.controller.attachmentIds.size());

        GFRS_Funding_Request__c fundReq = gFRS_TestCreationUtils.createFundingRequest(gFRS_Util.TYPE_FELLOWSHIPS_NAME, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_Util.REQUEST_DEFAULT_SUB_STATUS, gFRS_Util.REQUEST_DEFAULT_SUB_STATUS, '', ts.org.Id, ts.loc.Id);
        fundReq.Foundation_Eligible__c = 'Yes';
        insert fundReq;
        fundReq = [select id, RecordTypeId, Status__c,Sub_Status__c,External_Sub_status__c,Location__c,Evaluation_Summary_of_results_file__c,Foundation_Classified__c,Organization__c,Record_Type_Name__c from GFRS_Funding_Request__c where id=:fundReq.Id];
        ts.att = new Attachment(parentId = fundReq.Id, name = 'testName2', body = Blob.valueOf('testBody1'));
        insert ts.att;
        ts.att = gFRS_TestCreationUtils.createAttachment(fundReq.Id, 'testName2', Blob.valueOf('testBody2'));
        ts.controller.objectId = fundReq.Id;
        ts.controller.request = fundReq;
        System.assertEquals(true,ts.controller.isFellowshipsFoundation());
        System.assertEquals(false,ts.controller.checkAttachmentAvailability());
        ts.controller.selectedSection = 'Evaluation_page';
        ts.controller.onChangeSectionValue();
        ts.controller.selectedAttachmentField = 'Evaluation_Summary_of_results_file__c';
        ts.controller.onChangeAttachmentFieldName();
        ts.controller.onChangeRelatedRecord();

        ts.controller.selectedObject = gFRS_Util.ORGANIZATION_API_NAME;
        ts.controller.onChangeObjectValue();  
        ts.controller.selectedSection = 'Location_page';
        ts.controller.onChangeSectionValue();
        ts.controller.selectedAttachmentField = 'W9_Form_W_8BEN_Form__c';
        ts.controller.onChangeAttachmentFieldName();     
        ts.controller.onChangeRelatedRecord();

        ts.controller.selectedObject = gFRS_Util.PROGRAM_API_NAME;
        ts.controller.onChangeObjectValue();
        ts.controller.selectedSection = 'Program_page_HcChar';
        ts.controller.onChangeSectionValue();
        ts.controller.selectedRelatedRecord = ts.program.Id;
        ts.controller.selectedAttachmentField = 'Meeting_Agenda__c';
        ts.controller.onChangeAttachmentFieldName(); 
        ts.controller.onChangeRelatedRecord();
        System.assertEquals(false,ts.controller.selectedAttachment != null);

        ts.controller.selectedRelatedRecord = 'None';
        ts.controller.onChangeRelatedRecord();        
    }

    static testmethod void testLinkAttachment(){
        TestSettings ts = new TestSettings();
        ApexPages.currentPage().getParameters().put('id',ts.fundingRequest.Id);
        ts.setupControllerVariables();
        ts.controller.selectedSection = 'Evaluation_page';
        ts.controller.onChangeSectionValue();        
        ts.controller.selectedAttachmentField = 'None';
        ts.controller.linkAttachment();
        System.assertEquals('',ts.controller.selectedRelatedRecord);
        System.assertEquals('',ts.controller.selectedAttachment);

        ts.controller.selectedAttachmentField = null;
        ts.controller.linkAttachment(); 
        system.assertEquals(3,ts.controller.sectionsList.size());

        ts.controller.selectedAttachmentField = 'Evaluation_Summary_of_results_file__c';
        ts.controller.onChangeAttachmentFieldName();  
        ts.controller.onChangeRelatedRecord();
        ts.controller.selectedAttachment = ts.att.Id;
        System.assertEquals(null,String.valueOf(ts.controller.currentObject.get('Evaluation_Summary_of_results_file__c')));
        System.assertEquals(ts.att.Id,ts.controller.selectedAttachment);
        ts.controller.linkAttachment();

        ts.controller.updateAfterConfirmation();
        ts.controller.request.Evaluation_Summary_of_results_file__c = ts.att.Id;
        update ts.controller.request;
        ts.controller.linkAttachment();

        ts.controller.currentFieldValue = 'Financial_Report__c';
        ts.controller.updateAfterConfirmation();
        System.assertEquals(true,ts.controller.selectedAttachmentField != null);
        ts.controller.currentFieldValue = 'Evaluation_Summary_of_results_file__c';
        ts.controller.selectedAttachmentField = 'Financial_Report__c';
        ts.controller.updateAfterConfirmation();    
        
        List<Apexpages.Message> messages = ApexPages.getMessages();
        ts.controller.currentFieldValue = 'Evaluation_Summary_of_results_file__c';
        ts.controller.selectedAttachmentField = 'W9_Form_W_8BEN_Form__c';
        ts.controller.updateAfterConfirmation(); 
        System.assertEquals(true,messages.size() > 0);

        GFRS_Funding_Request__c fundReq = gFRS_TestCreationUtils.createFundingRequest(gFRS_Util.TYPE_FELLOWSHIPS_NAME, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_Util.REQUEST_DEFAULT_SUB_STATUS, gFRS_Util.REQUEST_DEFAULT_SUB_STATUS, '', ts.org.Id, ts.loc.Id);
        fundReq.Foundation_Eligible__c = 'Yes';
        insert fundReq;
        fundReq = [select id, RecordTypeId, Status__c,Sub_Status__c,External_Sub_status__c,Location__c,Evaluation_Summary_of_results_file__c,Foundation_Classified__c,Organization__c,Record_Type_Name__c from GFRS_Funding_Request__c where id=:fundReq.Id];
        ts.controller.objectId = fundReq.Id;
        ts.controller.request = fundReq;
        update ts.controller.request;
        ts.controller.selectedSection = 'Evaluation_page';
        ts.controller.selectedAttachmentField = 'Financial_Report__c';
        ts.controller.selectedAttachment = ts.att.Id;
        system.assertEquals(0,ts.controller.getAnnualEvaluationForRequest().size());
        System.assertEquals(true, ts.controller.isFellowshipsFoundation());
        ts.controller.linkAttachment();
        messages = ApexPages.getMessages();
        Boolean hasEvaluation = true;
        for(Apexpages.Message msg:messages){
            if (msg.getDetail().contains('Funding request does not have Annual Evaluation')) hasEvaluation = false; 
        }
        System.assertEquals(false, hasEvaluation);

        GFRS_Annual_Evaluation__c annualEvaluation = new GFRS_Annual_Evaluation__c( Funding_Request__c = fundReq.Id, Financial_Report__c = ts.att.Id );
        insert annualEvaluation;
        ts.controller.selectedAttachment = ts.att.Id;
        system.assertEquals(1,ts.controller.getAnnualEvaluationForRequest().size());
        System.assertEquals(true,ts.controller.isFellowshipsFoundation());
        System.assertEquals(ts.controller.selectedAttachment, ts.controller.getAnnualEvaluationForRequest().get(0).get('Financial_Report__c'));
        ts.controller.linkAttachment();

        ts.controller.selectedAttachment = '';
        ts.controller.linkAttachment();

        ts.controller.selectedObject = gFRS_Util.PROGRAM_API_NAME;
        ts.controller.onChangeObjectValue();
        ts.controller.selectedSection = 'Program_page_HcChar';
        ts.controller.onChangeSectionValue();
        ts.controller.selectedRelatedRecord = ts.program.Id;
        ts.controller.selectedAttachmentField = 'Meeting_Agenda__c';
        ts.controller.onChangeAttachmentFieldName(); 
        ts.controller.onChangeRelatedRecord(); 
        ts.controller.linkAttachment(); 
        messages = ApexPages.getMessages();
        System.assertEquals(4,messages.size());
    }

    static testmethod void testUploadAttachment(){
        TestSettings ts = new TestSettings();
        ApexPages.currentPage().getParameters().put('id',ts.fundingRequest.Id);
        ts.setupControllerVariables();

        ts.controller.selectedObject = gFRS_Util.PROGRAM_API_NAME;
        ts.controller.relatedPrograms = new List<GFRS_Program__c>();
        ts.controller.uploadAttachment();
        List<Apexpages.Message> messages = ApexPages.getMessages();
        messages = ApexPages.getMessages();
        Boolean hasProgram = true;
        for(Apexpages.Message msg:messages){
            if (msg.getDetail().contains('There are no programs related to this funding request.')) hasProgram = false; 
        }
        System.assertEquals(false, hasProgram);

        ts.controller.relatedPrograms.add(ts.program);
        ts.controller.onChangeObjectValue();
        ts.controller.selectedSection = 'Program_page_HcChar';
        ts.controller.onChangeSectionValue();
        
        ts.controller.selectedAttachmentField = 'Meeting_Agenda__c';
        ts.controller.onChangeAttachmentFieldName(); 
        ts.controller.onChangeRelatedRecord();
        
        ts.controller.selectedRelatedRecord = ts.program.Id;            
        ts.controller.uploadAttachment();
        GFRS_Program__c secondProgram = new GFRS_Program__c( Type__c = 'progType2', Funding_Request__c = ts.fundingRequest.Id);
        insert secondProgram;
        ts.controller.relatedPrograms.add(secondProgram);
        ts.controller.selectedRelatedRecord = 'None';
        ts.controller.uploadAttachment();
        messages = ApexPages.getMessages();
        Boolean hasRelatedProgram = true;
        for(Apexpages.Message msg:messages){
            if (msg.getDetail().contains('Please select related program.')) hasRelatedProgram = false; 
        }
        System.assertEquals(false, hasRelatedProgram);

        ts.controller.selectedRelatedRecord = secondProgram.Id;
        ts.controller.uploadAttachment();

        ts.controller.selectedObject = gFRS_Util.FUNDING_REQUEST_API_NAME;
        ts.controller.onChangeObjectValue();
        ts.controller.uploadAttachment();
        System.assertEquals(true, ts.controller.uploadAttachment() != null);

        ts.controller.selectedObject = 'GFRS_Location__c';
        ts.controller.uploadAttachment();
        System.assertEquals(false, ts.controller.uploadAttachment() != null);
    }

    static testmethod void testNextPreviousButtons(){
        TestSettings ts = new TestSettings();
        ApexPages.currentPage().getParameters().put('id',ts.fundingRequest.Id);
        ts.setupControllerVariables();
        ts.controller.offsetSize = 0;
        ts.controller.next();
        System.assertEquals(5,ts.controller.offsetSize);
        System.assertEquals(false,ts.controller.attachments.size() > 0);

        ts.controller.previous();  
        System.assertEquals(true,ts.controller.offsetSize == 0);
        System.assertEquals(true,ts.controller.attachments.size() > 0);  
    }

    static void loadContentAndCustomSettingsValues(){
        List<gFRS_Settings__c> settings = new List<gFRS_Settings__c>{
            new gFRS_Settings__c(
                Name = 'Location_page',
                Value__c = 'W9_Form_W_8BEN_Form__c'),
            new gFRS_Settings__c(
                Name = 'Foundation_page',
                Value__c = 'Audited_financials_for_the_previous_year__c;Audited_Financials_for_the_previous_two__c;Audited_Financials_for_the_previous_thre__c;Form_990_for_the_previous_year__c;Form_990_for_the_previous_two_year__c;Form_990_for_the_previous_three_year__c'),
            new gFRS_Settings__c(
                Name = 'Loa_page',
                Value__c = 'LOA_PDF__c'),
            new gFRS_Settings__c(
                Name = 'Program_page_HcChar',
                Value__c = 'Promotional_Event_Advertising__c;Meeting_Agenda__c;Additional_Document_Uploads__c;Additional_Document_Uploads_2__c;Additional_Document_Uploads_3__c;Additional_Document_Uploads_4__c;Additional_Document_Uploads_5__c'),
            new gFRS_Settings__c(
                Name = 'Evaluation_page',
                Value__c = 'Evaluation_Summary_of_results_file__c;Evaluation_Other_outputs_file__c;Evaluation_Additional_attachment_1__c;Evaluation_Additional_attachment_2__c'),
            new gFRS_Settings__c(
                Name = 'Sect_gFRS_Organization__c_Fund',
                Value__c = 'Location_page;Foundation_page'),
            new gFRS_Settings__c(
                Name = 'Sect_gFRS_Organization__c',
                Value__c = 'Location_page'),
            new gFRS_Settings__c(
                Name = 'Sect_GFRS_Program__c',
                Value__c = 'Program_page_HcChar'),
            new gFRS_Settings__c(
                Name = 'Sect_FundReq_HcChar',
                Value__c = 'Loa_page;Evaluation_page')
        };
        insert settings;

        Map<Id, String> translationsMap = new Map<Id, String>();
        Map<String, List<String>> contentValuesMap = new Map<String, List<String>>();
        GFRS_Content__c item = null;
        GFRS_Content_Translation__c translation = null;
        List<GFRS_Content__c> contentsList = new List<GFRS_Content__c>();
        List<GFRS_Content_Translation__c> translations = new List<GFRS_Content_Translation__c>();
        contentValuesMap.put('Gcal_Header',new List<String>{'Gcal_Header','test'});
        contentValuesMap.put('Location_page',new List<String>{'Link_Att_Sections','Location Page'});
        contentValuesMap.put('Foundation_page',new List<String>{'Link_Att_Sections','Foundation Page'});
        contentValuesMap.put('Program_page_HcChar',new List<String>{'Link_Att_Sections','Program Page'});
        contentValuesMap.put('Loa_page',new List<String>{'Link_Att_Sections','LOA'});
        contentValuesMap.put('Evaluation_page',new List<String>{'Link_Att_Sections','Evaluation Page'});

        for (String key : contentValuesMap.keySet()) {    
            List<GFRS_Content__c> listOfItems= [select 
                                                 Name, Filter__c
                                                 from GFRS_Content__c
                                                 where Filter__c = :contentValuesMap.get(key).get(0) and Name=:key and isDeleted=false];
            item =new GFRS_Content__c();
            item.Filter__c=contentValuesMap.get(key).get(0);
            item.name=key;                
            contentsList.add(item);
        }
        insert contentsList;
        for (GFRS_Content__c content : contentsList){
            translationsMap.put(content.Id,contentValuesMap.get(content.Name).get(1));
        }
        for (Id key : translationsMap.keySet()) {
            List<GFRS_Content_Translation__c> itemTranslationList = [select 
                                                                     GFRS_Content__c, Language__c, TextBlock__c
                                                                     from GFRS_Content_Translation__c
                                                                     where GFRS_Content__c =:key and isDeleted=false];
             translation=new GFRS_Content_Translation__c();
             translation.GFRS_Content__c = key;
             translation.Language__c ='en_US';
             translation.TextBlock__c = translationsMap.get(key);
            translations.add(translation);
        }
        insert translations;
    }
}