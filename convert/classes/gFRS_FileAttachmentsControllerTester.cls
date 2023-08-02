/**
* @author GFRS Dev Team
* @date 27/08/2013
* @description gFRS_FileAttachmentsControllerTester class - test class for gFRS_FileAttachmentsController
*/
@isTest
public with sharing class gFRS_FileAttachmentsControllerTester {
	
	public static final Blob DEMO_FILE_DATA = Blob.valueOf( 'ZGVtbyBiYXNlIDY0IGRhdGEgdXNlZA==' );
	
	public static final String TASK_ACTION_TYPE_RFI = 'RFI';
	
    public static final String DEMO_FILE_NAME = 'Demo.file';
    
	class TestSettings {
		//-- profiles
        public String PROF_GFRS_USER_NAME = 'GNE-GFRS-User';
        public id PROF_GFRS_USER;
        
        //-- instance variables
        public Account account;
        User user;
        public GFRS_Organization__c organization;
        public GFRS_Location__c location;
        public GFRS_Funding_Request__c request;
        public GFRS_Funding_Allocation__c allocation;
        public GFRS_Funding_Allocation_Line_Item__c[] allocationLIs;
        public GFRS_WBS_Codes__c[] wbsCodes;
        public GFRS_Cost_Center_Code__c[] costCodes;
        public GFRS_Third_Party__c[] thirdPartyRecords;
        public GFRS_Content_Translation__c[] firewallQuestions;
        public GFRS_Content_Translation__c[] contentItems;
        public GFRS_Administrative_Budget__c adminBudget;
        public GFRS_Administrative_Budget_Line_Item__c adminBudgetLI;
        
        public Attachment meetingAgenda;
        
        public gFRS_FileAttachmentsController controller;
        
        public TestSettings(){
            //-- initialization done for ALL SETUPs done here
            this.account = gFRS_TestCreationUtils.createAccount( gFRS_TestCreationUtils.makeUnique( 'acct' ));
            insert this.account;
            
            this.organization = gFRS_TestCreationUtils.createOrganization2( '20110101', this.account.id );
            insert this.organization;
            
            this.location = gFRS_TestCreationUtils.createLocation( 'SomeLocation', this.organization.id );
            insert this.location;
            
            GFRS_WBS_Codes__c[] WBSCodes = [select Id, Name from GFRS_WBS_Codes__c];
            GFRS_Cost_Center_Code__c[] CostCenterCodes = [select Id, Name from GFRS_Cost_Center_Code__c];
            GFRS_Administrative_Budget__c[] budgets = [select Id, Name from GFRS_Administrative_Budget__c];
            GFRS_Administrative_Budget_Line_Item__c[] budgetLIs = [select Id, Name from GFRS_Administrative_Budget_Line_Item__c];
            GFRS_Funding_Request__c[] reqs = [select Id, Name from GFRS_Funding_Request__c];
            GFRS_Funding_Allocation__c[] all = [select Id, Name from GFRS_Funding_Allocation__c];
            delete WBSCodes;
            delete CostCenterCodes;

            this.wbsCodes = new GFRS_WBS_Codes__c[]{
                gFRS_TestCreationUtils.createWBSCode('testIMED_A','Asthma', gFRS_Util.TYPE_IMED_NAME),
                gFRS_TestCreationUtils.createWBSCode('testIMED_A2','Asthma', gFRS_Util.TYPE_IMED_NAME),
                gFRS_TestCreationUtils.createWBSCode('testCM','Asthma', gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME),
                gFRS_TestCreationUtils.createWBSCode('testEX','Breast Cancer', gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME),
                gFRS_TestCreationUtils.createWBSCode('testF','Breast Cancer', gFRS_Util.TYPE_FELLOWSHIPS_NAME),
                gFRS_TestCreationUtils.createWBSCode('testFI','Hemodialysis', gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME),
                gFRS_TestCreationUtils.createWBSCode('testHC','Hemodialysis', gFRS_Util.TYPE_HC_CHAR_NAME),
                gFRS_TestCreationUtils.createWBSCode('testPH','Lupus', gFRS_Util.TYPE_PHILANTHROPIC_NAME),
                gFRS_TestCreationUtils.createWBSCode('testSC','Lupus', gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME)
            };
            insert this.wbsCodes;
            
            this.costCodes = new GFRS_Cost_Center_Code__c[]{
                gFRS_TestCreationUtils.createCostCenter('testIMED',gFRS_Util.TYPE_IMED_NAME),
                gFRS_TestCreationUtils.createCostCenter('testCM', gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME),
                gFRS_TestCreationUtils.createCostCenter('testEX', gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME),
                gFRS_TestCreationUtils.createCostCenter('testF',  gFRS_Util.TYPE_FELLOWSHIPS_NAME),
               // gFRS_TestCreationUtils.createCostCenter('testFI', gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME),
                gFRS_TestCreationUtils.createCostCenter('testHC', gFRS_Util.TYPE_HC_CHAR_NAME),
                gFRS_TestCreationUtils.createCostCenter('testPH', gFRS_Util.TYPE_PHILANTHROPIC_NAME),
                gFRS_TestCreationUtils.createCostCenter('testSC', gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME)
            };
            insert this.costCodes;
            
            GFRS_Content__c[] content = new GFRS_Content__c[]{
                gFRS_TestCreationUtils.createContent( 'firewall01', null, GFRS_ApplicationController.FIREWALL_CONTENT_TYPE ),
                gFRS_TestCreationUtils.createContent( 'firewall02', null, GFRS_ApplicationController.FIREWALL_CONTENT_TYPE ),
                gFRS_TestCreationUtils.createContent( 'firewall03', null, GFRS_ApplicationController.FIREWALL_CONTENT_TYPE ),
                gFRS_TestCreationUtils.createContent( 'firewall04', null, GFRS_ApplicationController.FIREWALL_CONTENT_TYPE ),
                gFRS_TestCreationUtils.createContent( 'firewall05', null, GFRS_ApplicationController.FIREWALL_CONTENT_TYPE ),
                gFRS_TestCreationUtils.createContent( 'firewall06', null, GFRS_ApplicationController.FIREWALL_CONTENT_TYPE ),
                gFRS_TestCreationUtils.createContent( 'firewall07', null, GFRS_ApplicationController.FIREWALL_CONTENT_TYPE ),
                gFRS_TestCreationUtils.createContent( 'firewall08', null, GFRS_ApplicationController.FIREWALL_CONTENT_TYPE ),
                gFRS_TestCreationUtils.createContent( 'firewall09', null, GFRS_ApplicationController.FIREWALL_CONTENT_TYPE ),
                gFRS_TestCreationUtils.createContent( 'firewall10', null, GFRS_ApplicationController.FIREWALL_CONTENT_TYPE ),
                gFRS_TestCreationUtils.createContent( 'firewall11', null, GFRS_ApplicationController.FIREWALL_CONTENT_TYPE )
            };
            
            insert content;
            
            this.firewallQuestions = new GFRS_Content_Translation__c[]{
                gFRS_TestCreationUtils.createContentTranslation( content[0], 'firewall01', null, gFRS_TestCreationUtils.LANG_EN ),
                gFRS_TestCreationUtils.createContentTranslation( content[1], 'firewall02', null, gFRS_TestCreationUtils.LANG_EN ),
                gFRS_TestCreationUtils.createContentTranslation( content[2], 'firewall03', null, gFRS_TestCreationUtils.LANG_EN ),
                gFRS_TestCreationUtils.createContentTranslation( content[3], 'firewall04', null, gFRS_TestCreationUtils.LANG_EN ),
                gFRS_TestCreationUtils.createContentTranslation( content[4], 'firewall05', null, gFRS_TestCreationUtils.LANG_EN ),
                gFRS_TestCreationUtils.createContentTranslation( content[5], 'firewall06', null, gFRS_TestCreationUtils.LANG_EN ),
                gFRS_TestCreationUtils.createContentTranslation( content[6], 'firewall07', null, gFRS_TestCreationUtils.LANG_EN ),
                gFRS_TestCreationUtils.createContentTranslation( content[7], 'firewall08', null, gFRS_TestCreationUtils.LANG_EN ),
                gFRS_TestCreationUtils.createContentTranslation( content[8], 'firewall09', null, gFRS_TestCreationUtils.LANG_EN ),
                gFRS_TestCreationUtils.createContentTranslation( content[9], 'firewall10', null, gFRS_TestCreationUtils.LANG_EN ),
                gFRS_TestCreationUtils.createContentTranslation( content[10], 'firewall11', null, gFRS_TestCreationUtils.LANG_EN )
            };
            
            insert this.firewallQuestions;
            
            content = new GFRS_Content__c[]{
                gFRS_TestCreationUtils.createContent( 'ThirdParty', null, GFRS_ApplicationController.CONTENT_TYPE ),
                gFRS_TestCreationUtils.createContent( gFRS_ApplicationController.CONTENT_KEY_FIREWALLFAQ, null, GFRS_ApplicationController.CONTENT_TYPE ),
                gFRS_TestCreationUtils.createContent( 'IMEDFootnote', null, GFRS_ApplicationController.CONTENT_TYPE )
            };
            insert content;
            
            this.contentItems = new GFRS_Content_Translation__c[]{
                gFRS_TestCreationUtils.createContentTranslation( content[0], 'ThirdParty', null, gFRS_TestCreationUtils.LANG_EN ),
                gFRS_TestCreationUtils.createContentTranslation( content[1], gFRS_ApplicationController.CONTENT_KEY_FIREWALLFAQ, null, gFRS_TestCreationUtils.LANG_EN ),
                gFRS_TestCreationUtils.createContentTranslation( content[2], 'IMEDFootnote', null, gFRS_TestCreationUtils.LANG_EN )
            };
            insert this.contentItems;
        }
        
        
        public void setupIMED(){
            this.request = gFRS_TestCreationUtils.createFundingRequest2( gFRS_TestCreationUtils.RT_FR_IMED, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id );
            
            insert this.request;
            this.controller = new gFRS_FileAttachmentsController( new ApexPages.StandardController( this.request ) );
        }

         public void setupFellowships(){
            this.request = gFRS_TestCreationUtils.createFundingRequest2( gFRS_TestCreationUtils.RT_FR_FELLOWSHIPS, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id);
            insert this.request;
        }

        public void setupCorporate(){
            this.request = gFRS_TestCreationUtils.createFundingRequest2( gFRS_TestCreationUtils.RT_FR_CORPORATE_MEMBERSHIPS, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id);
            
            insert this.request;
            this.controller = new gFRS_FileAttachmentsController( new ApexPages.StandardController( this.request ) );  
        }

        public void setupExhibits(){
            this.request = gFRS_TestCreationUtils.createFundingRequest2( gFRS_TestCreationUtils.RT_FR_EXHIBITS_OTHER_PROMOS, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id );
            this.request.Funding_Sub_Type__c = 'Exhibit Booth';
            
            insert this.request;
            this.controller = new gFRS_FileAttachmentsController( new ApexPages.StandardController( this.request ) );  
        }

        
        public void createUser(){
            PROF_GFRS_USER = [ select Id, Name, Type from Profile where Name =:PROF_GFRS_USER_NAME limit 1 ].Id;
            user = gFRS_TestCreationUtils.createUser3('Test', 'test', 'aaa@gene.com', PROF_GFRS_USER, '1234');
            insert user;
        }

        public Boolean checkApexMessages(String message) {
            for(Apexpages.Message msg : ApexPages.getMessages()){
                if (msg.getDetail().contains(message)) {
                    return true;
                }
            }
            return false;
        }
        
        //-- utility methods
        public GFRS_Funding_Request__c refreshRequest(){
            try {
                GFRS_Funding_Request__c result = [ select id,
                    (select id,ParentID,name from Attachments)
                    from GFRS_Funding_Request__c where id = :this.request.id
                    limit 1];
                return( result );
            } catch( Exception err ){
                System.debug( 'unable to refresh funding request:' + err.getMessage() );
                return( null );
            }
        }
        
        public GFRS_Organization__c refreshOrganization(){
            try {
                GFRS_Organization__c result = [ select id,
                    (select id,ParentID,name from Attachments)
                    from GFRS_Organization__c where id = :this.organization.id
                    limit 1];
                return( result );
            } catch( Exception err ){
                System.debug( 'unable to refresh Organization:' + err.getMessage() );
                return( null );
            }
        }

	}

	/**
	* @author GFRS Dev Team	
	* @date 28/08/2013
	* @description testUploadMeetingAgendaReplaceAttachment method - upload one Attachment
	*
	static testMethod void testUploadMeetingAgendaReplaceAttachment(){
		TestSettings ts = new TestSettings();
        ts.setupIMED();        
        ts.createUser();
        
        ts.controller.meetingAgenda.name = DEMO_FILE_NAME;
        ts.controller.meetingAgenda.body = DEMO_FILE_DATA;
        
        Test.startTest();
			ts.controller.uploadMeetingAgenda();
			GFRS_Funding_Request__c resultRequest = [ select Id,
                    (select Id, ParentId, Name from Attachments)
                    from GFRS_Funding_Request__c where id = :ts.request.id
                    limit 1];
        	System.assert(resultRequest.Attachments.size()>0);
		Test.stopTest();			
	}

    static testMethod void testUploadFellowshipProgram(){
        TestSettings ts = new TestSettings();
        ts.setupFellowships(); 
        ts.createUser(); 
        Attachment att = gFRS_TestCreationUtils.createAttachment(ts.request.Id, 'Fellowship_Project_Description__c', Blob.valueOf('testBody'));
        insert att;
        ts.request.Information_Needed__c = gFRS_Util.INFO_NEEDED_FILE_ATTACHMENTS; 
        ts.request.Fellowship_Project_Description__c = att.id;
        update ts.request;   
        ts.controller = new gFRS_FileAttachmentsController( new ApexPages.StandardController( ts.request ) );  

        gFRS_Tasks__c task = gFRS_TestCreationUtils.createTask2(ts.request.Id,'Please Review', ts.user.Id);
        insert task;
        ts.controller.uploadFellowshipProgram();

        task.Action_Type__c = TASK_ACTION_TYPE_RFI;
        update task;
        ts.controller.uploadFellowshipProgram();

        
    }

    static testMethod void testUploadLetterOfRequest(){
       TestSettings ts = new TestSettings();
        ts.setupFellowships(); 
        ts.createUser(); 
        Attachment att = gFRS_TestCreationUtils.createAttachment(ts.request.Id, 'Letter_of_Request__c', Blob.valueOf('testBody'));
        insert att;
        ts.request.Information_Needed__c = gFRS_Util.INFO_NEEDED_FILE_ATTACHMENTS; 
        ts.request.Letter_of_Request__c = att.id;
        update ts.request;   
        ts.controller = new gFRS_FileAttachmentsController( new ApexPages.StandardController( ts.request ) );  

        gFRS_Tasks__c task = gFRS_TestCreationUtils.createTask2(ts.request.Id,'Please Review', ts.user.Id);
        insert task;
        ts.controller.uploadLetterOfRequest(); 

        task.Action_Type__c = TASK_ACTION_TYPE_RFI;
        update task;
        ts.controller.uploadLetterOfRequest();
    }

    static testMethod void testUploadPromoEvent(){
       TestSettings ts = new TestSettings();
        ts.setupFellowships(); 
        ts.createUser(); 
        Attachment att = gFRS_TestCreationUtils.createAttachment(ts.request.Id, 'Promotional_Event_Advertising__c', Blob.valueOf('testBody'));
        insert att;
        ts.request.Information_Needed__c = gFRS_Util.INFO_NEEDED_FILE_ATTACHMENTS; 
        ts.request.Promotional_Event_Advertising__c = att.id;
        update ts.request;   
        ts.controller = new gFRS_FileAttachmentsController( new ApexPages.StandardController( ts.request ) );  

        gFRS_Tasks__c task = gFRS_TestCreationUtils.createTask2(ts.request.Id,'Please Review', ts.user.Id);
        insert task;
        ts.controller.uploadPromoEvent(); 

        task.Action_Type__c = TASK_ACTION_TYPE_RFI;
        update task;
        ts.controller.uploadPromoEvent();
    }

    static testMethod void testUploadMeetingAgenda(){
       TestSettings ts = new TestSettings();
        ts.setupFellowships(); 
        ts.createUser(); 
        Attachment att = gFRS_TestCreationUtils.createAttachment(ts.request.Id, 'Meeting_Agenda__c', Blob.valueOf('testBody'));
        insert att;
        ts.request.Information_Needed__c = gFRS_Util.INFO_NEEDED_FILE_ATTACHMENTS; 
        ts.request.Meeting_Agenda__c = att.id;
        update ts.request;   
        ts.controller = new gFRS_FileAttachmentsController( new ApexPages.StandardController( ts.request ) );  

        gFRS_Tasks__c task = gFRS_TestCreationUtils.createTask2(ts.request.Id,'Please Review', ts.user.Id);
        insert task;
        ts.controller.uploadMeetingAgenda(); 

        task.Action_Type__c = TASK_ACTION_TYPE_RFI;
        update task;
        ts.controller.uploadMeetingAgenda();
    }

    static testMethod void testUploadNeedsAssessment(){
       TestSettings ts = new TestSettings();
        ts.setupFellowships(); 
        ts.createUser(); 
        Attachment att = gFRS_TestCreationUtils.createAttachment(ts.request.Id, 'Needs_Assessment_Document__c', Blob.valueOf('testBody'));
        insert att;
        ts.request.Information_Needed__c = gFRS_Util.INFO_NEEDED_FILE_ATTACHMENTS; 
        ts.request.Needs_Assessment_Document__c = att.id;
        update ts.request;   
        ts.controller = new gFRS_FileAttachmentsController( new ApexPages.StandardController( ts.request ) );  

        gFRS_Tasks__c task = gFRS_TestCreationUtils.createTask2(ts.request.Id,'Please Review', ts.user.Id);
        insert task;
        ts.controller.uploadNeedsAssessment(); 

        task.Action_Type__c = TASK_ACTION_TYPE_RFI;
        update task;
        ts.controller.uploadNeedsAssessment();
    }

    static testMethod void testUploadImplementationPlan(){
       TestSettings ts = new TestSettings();
        ts.setupFellowships(); 
        ts.createUser(); 
        Attachment att = gFRS_TestCreationUtils.createAttachment(ts.request.Id, 'Implementation_Plan__c', Blob.valueOf('testBody'));
        insert att;
        ts.request.Information_Needed__c = gFRS_Util.INFO_NEEDED_FILE_ATTACHMENTS; 
        ts.request.Implementation_Plan__c = att.id;
        update ts.request;   
        ts.controller = new gFRS_FileAttachmentsController( new ApexPages.StandardController( ts.request ) );  

        gFRS_Tasks__c task = gFRS_TestCreationUtils.createTask2(ts.request.Id,'Please Review', ts.user.Id);
        insert task;
        ts.controller.uploadImplementationPlan(); 

        task.Action_Type__c = TASK_ACTION_TYPE_RFI;
        update task;
        ts.controller.uploadImplementationPlan();
    }

    static testMethod void testUploadAdditionalDocumentUpload1(){
       TestSettings ts = new TestSettings();
        ts.setupFellowships(); 
        ts.createUser(); 
        Attachment att = gFRS_TestCreationUtils.createAttachment(ts.request.Id, 'Additional_Document_Uploads__c', Blob.valueOf('testBody'));
        insert att;
        ts.request.Information_Needed__c = gFRS_Util.INFO_NEEDED_FILE_ATTACHMENTS; 
        ts.request.Additional_Document_Uploads__c = att.id;
        update ts.request;   
        ts.controller = new gFRS_FileAttachmentsController( new ApexPages.StandardController( ts.request ) );  

        gFRS_Tasks__c task = gFRS_TestCreationUtils.createTask2(ts.request.Id,'Please Review', ts.user.Id);
        insert task;
        ts.controller.uploadAdditionalDocumentUpload1(); 

        task.Action_Type__c = TASK_ACTION_TYPE_RFI;
        update task;
        ts.controller.uploadAdditionalDocumentUpload1();
    }

    static testMethod void testUploadAdditionalDocumentUpload2(){
       TestSettings ts = new TestSettings();
        ts.setupFellowships(); 
        ts.createUser(); 
        Attachment att = gFRS_TestCreationUtils.createAttachment(ts.request.Id, 'Additional_Document_Uploads_2__c', Blob.valueOf('testBody'));
        insert att;
        ts.request.Information_Needed__c = gFRS_Util.INFO_NEEDED_FILE_ATTACHMENTS; 
        ts.request.Additional_Document_Uploads_2__c = att.id;
        update ts.request;   
        ts.controller = new gFRS_FileAttachmentsController( new ApexPages.StandardController( ts.request ) );  

        gFRS_Tasks__c task = gFRS_TestCreationUtils.createTask2(ts.request.Id,'Please Review', ts.user.Id);
        insert task;
        ts.controller.uploadAdditionalDocumentUpload2(); 

        task.Action_Type__c = TASK_ACTION_TYPE_RFI;
        update task;
        ts.controller.uploadAdditionalDocumentUpload2();
    }

    static testMethod void testUploadAdditionalDocumentUpload3(){
       TestSettings ts = new TestSettings();
        ts.setupFellowships(); 
        ts.createUser(); 
        Attachment att = gFRS_TestCreationUtils.createAttachment(ts.request.Id, 'Additional_Document_Uploads_3__c', Blob.valueOf('testBody'));
        insert att;
        ts.request.Information_Needed__c = gFRS_Util.INFO_NEEDED_FILE_ATTACHMENTS; 
        ts.request.Additional_Document_Uploads_3__c = att.id;
        update ts.request;   
        ts.controller = new gFRS_FileAttachmentsController( new ApexPages.StandardController( ts.request ) );  

        gFRS_Tasks__c task = gFRS_TestCreationUtils.createTask2(ts.request.Id,'Please Review', ts.user.Id);
        insert task;
        ts.controller.uploadAdditionalDocumentUpload3(); 

        task.Action_Type__c = TASK_ACTION_TYPE_RFI;
        update task;
        ts.controller.uploadAdditionalDocumentUpload3();
    }

    static testMethod void testUploadAdditionalDocumentUpload4(){
       TestSettings ts = new TestSettings();
        ts.setupFellowships(); 
        ts.createUser(); 
        Attachment att = gFRS_TestCreationUtils.createAttachment(ts.request.Id, 'Additional_Document_Uploads_4__c', Blob.valueOf('testBody'));
        insert att;
        ts.request.Information_Needed__c = gFRS_Util.INFO_NEEDED_FILE_ATTACHMENTS; 
        ts.request.Additional_Document_Uploads_4__c = att.id;
        update ts.request;   
        ts.controller = new gFRS_FileAttachmentsController( new ApexPages.StandardController( ts.request ) );  

        gFRS_Tasks__c task = gFRS_TestCreationUtils.createTask2(ts.request.Id,'Please Review', ts.user.Id);
        insert task;
        ts.controller.uploadAdditionalDocumentUpload4(); 

        task.Action_Type__c = TASK_ACTION_TYPE_RFI;
        update task;
        ts.controller.uploadAdditionalDocumentUpload4();
    }

    static testMethod void testUploadAdditionalDocumentUpload5(){
       TestSettings ts = new TestSettings();
        ts.setupFellowships(); 
        ts.createUser(); 
        Attachment att = gFRS_TestCreationUtils.createAttachment(ts.request.Id, 'Additional_Document_Uploads_5__c', Blob.valueOf('testBody'));
        insert att;
        ts.request.Information_Needed__c = gFRS_Util.INFO_NEEDED_FILE_ATTACHMENTS; 
        ts.request.Additional_Document_Uploads_5__c = att.id;
        update ts.request;   
        ts.controller = new gFRS_FileAttachmentsController( new ApexPages.StandardController( ts.request ) );  

        gFRS_Tasks__c task = gFRS_TestCreationUtils.createTask2(ts.request.Id,'Please Review', ts.user.Id);
        insert task;
        ts.controller.uploadAdditionalDocumentUpload5(); 

        task.Action_Type__c = TASK_ACTION_TYPE_RFI;
        update task;
        ts.controller.uploadAdditionalDocumentUpload5();
    }

    static testMethod void testUploadForm2010(){
       TestSettings ts = new TestSettings();
        ts.setupFellowships(); 
        ts.createUser(); 
        Attachment att = gFRS_TestCreationUtils.createAttachment(ts.organization.Id, 'Form_990_for_the_previous_year__c', Blob.valueOf('testBody'));
        insert att;
        ts.request.Information_Needed__c = gFRS_Util.INFO_NEEDED_FILE_ATTACHMENTS; 
        update ts.request;   
        ts.organization.Form_990_for_the_previous_year__c = att.id;
        update ts.organization;
        ts.controller = new gFRS_FileAttachmentsController( new ApexPages.StandardController( ts.request ) );  

        gFRS_Tasks__c task = gFRS_TestCreationUtils.createTask2(ts.request.Id,'Please Review', ts.user.Id);
        insert task;
        ts.controller.uploadForm2010(); 

        task.Action_Type__c = TASK_ACTION_TYPE_RFI;
        update task;
        ts.controller.uploadForm2010();
    }

    static testMethod void testUploadForm2009(){
       TestSettings ts = new TestSettings();
        ts.setupFellowships(); 
        ts.createUser(); 
        Attachment att = gFRS_TestCreationUtils.createAttachment(ts.organization.Id, 'Form_990_for_the_previous_two_year__c', Blob.valueOf('testBody'));
        insert att;
        ts.request.Information_Needed__c = gFRS_Util.INFO_NEEDED_FILE_ATTACHMENTS; 
        update ts.request;  
        ts.organization.Form_990_for_the_previous_two_year__c = att.id; 
        update ts.organization;
        ts.controller = new gFRS_FileAttachmentsController( new ApexPages.StandardController( ts.request ) );  

        gFRS_Tasks__c task = gFRS_TestCreationUtils.createTask2(ts.request.Id,'Please Review', ts.user.Id);
        insert task;
        ts.controller.uploadForm2009(); 

        task.Action_Type__c = TASK_ACTION_TYPE_RFI;
        update task;
        ts.controller.uploadForm2009();
    }

    static testMethod void testUploadForm2008(){
       TestSettings ts = new TestSettings();
        ts.setupFellowships(); 
        ts.createUser(); 
        Attachment att = gFRS_TestCreationUtils.createAttachment(ts.organization.Id, 'Form_990_for_the_previous_three_year__c', Blob.valueOf('testBody'));
        insert att;
        ts.request.Information_Needed__c = gFRS_Util.INFO_NEEDED_FILE_ATTACHMENTS; 
        update ts.request; 
        ts.organization.Form_990_for_the_previous_three_year__c = att.id; 
        update ts.organization; 
        ts.controller = new gFRS_FileAttachmentsController( new ApexPages.StandardController( ts.request ) );  

        gFRS_Tasks__c task = gFRS_TestCreationUtils.createTask2(ts.request.Id,'Please Review', ts.user.Id);
        insert task;
        ts.controller.uploadForm2008(); 

        task.Action_Type__c = TASK_ACTION_TYPE_RFI;
        update task;
        ts.controller.uploadForm2008();
    }

    static testMethod void testUploadAuditFin2010(){
       TestSettings ts = new TestSettings();
        ts.setupFellowships(); 
        ts.createUser(); 
        Attachment att = gFRS_TestCreationUtils.createAttachment(ts.organization.Id, 'Audited_financials_for_the_previous_year__c', Blob.valueOf('testBody'));
        insert att;
        ts.request.Information_Needed__c = gFRS_Util.INFO_NEEDED_FILE_ATTACHMENTS; 
        update ts.request;  
        ts.organization.Audited_financials_for_the_previous_year__c = att.id;
        update ts.organization; 
        ts.controller = new gFRS_FileAttachmentsController( new ApexPages.StandardController( ts.request ) );  

        gFRS_Tasks__c task = gFRS_TestCreationUtils.createTask2(ts.request.Id,'Please Review', ts.user.Id);
        insert task;
        ts.controller.uploadAuditFin2010(); 

        task.Action_Type__c = TASK_ACTION_TYPE_RFI;
        update task;
        ts.controller.uploadAuditFin2010();
    }

    static testMethod void testUploadAuditFin2009(){
       TestSettings ts = new TestSettings();
        ts.setupFellowships(); 
        ts.createUser(); 
        Attachment att = gFRS_TestCreationUtils.createAttachment(ts.organization.Id, 'Audited_Financials_for_the_previous_two__c', Blob.valueOf('testBody'));
        insert att;
        ts.request.Information_Needed__c = gFRS_Util.INFO_NEEDED_FILE_ATTACHMENTS; 
        update ts.request;  
        ts.organization.Audited_Financials_for_the_previous_two__c = att.id;
        update ts.organization; 
        ts.controller = new gFRS_FileAttachmentsController( new ApexPages.StandardController( ts.request ) );  

        gFRS_Tasks__c task = gFRS_TestCreationUtils.createTask2(ts.request.Id,'Please Review', ts.user.Id);
        insert task;
        ts.controller.uploadAuditFin2009(); 

        task.Action_Type__c = TASK_ACTION_TYPE_RFI;
        update task;
        ts.controller.uploadAuditFin2009();
    }

    static testMethod void testUploadAuditFin2008(){
        TestSettings ts = new TestSettings();
        ts.setupFellowships(); 
        ts.createUser(); 
        Attachment att = gFRS_TestCreationUtils.createAttachment(ts.organization.Id, 'Audited_Financials_for_the_previous_thre__c', Blob.valueOf('testBody'));
        insert att;
        ts.request.Information_Needed__c = gFRS_Util.INFO_NEEDED_FILE_ATTACHMENTS; 
        update ts.request;  
        ts.organization.Audited_Financials_for_the_previous_thre__c = att.id; 
        update ts.organization;
        ts.controller = new gFRS_FileAttachmentsController( new ApexPages.StandardController( ts.request ) );  

        gFRS_Tasks__c task = gFRS_TestCreationUtils.createTask2(ts.request.Id,'Please Review', ts.user.Id);
        insert task;
        ts.controller.uploadAuditFin2008(); 

        task.Action_Type__c = TASK_ACTION_TYPE_RFI;
        update task;
        ts.controller.uploadAuditFin2008();
    }
*/
    static testMethod void testIsCMEOShown(){
        TestSettings ts = new TestSettings();
        ts.setupCorporate(); 

        Boolean result = ts.controller.isCMEOShown;
        System.assertEquals(false,result);

        ts.controller.fundingRequest.Benefits_Exchanged_for_Funding__c = 'Exhibit space';
        update ts.controller.fundingRequest;

        result = ts.controller.isCMEOShown;
        System.assertEquals(true,result);
    }

    static testMethod void testBack(){
        TestSettings ts = new TestSettings();
        ts.setupCorporate(); 
        String pathBack = gFRS_Util.PATH_PROGRAM;

        //System.assertEquals(pathBack+ '?id=' + ts.request.Id + '&t=t',ts.controller.back().getUrl());

        ts.setupIMED(); 
        pathBack = gFRS_Util.PATH_BUDGET;

        
        System.assertEquals(pathBack+ '?id=' + ts.request.Id + '&t=t',ts.controller.back().getUrl());
    }

    /*static testMethod void testSaveFileAttachments(){
        TestSettings ts = new TestSettings();
        ts.setupCorporate(); 

        //set below feileds to retrieve /apex/GFRS_Confirmation page
        ts.controller.letterRequest.name = 'test';
        ts.controller.auditFin2008.name = 'test';
        ts.controller.auditFin2009.name = 'test';
        ts.controller.auditFin2010.name = 'test';
        ts.controller.form2008.name = 'test';
        ts.controller.form2009.name = 'test';
        ts.controller.form2010.name = 'test';
        ts.controller.promoEvent.name = 'test';
        ts.controller.letterRequest.name = 'test';

        //Verify result
        System.assertEquals('/apex/GFRS_Confirmation?id=' + ts.request.Id + '&t=t', ts.controller.saveFileAttachments().getUrl());
        
        //setting of isCMEOShown == true
        ts.controller.fundingRequest.Benefits_Exchanged_for_Funding__c = 'Exhibit space';
        //update ts.controller.fundingRequest;

        //Verify ERROR MESSAGE: (Meeting Agenda is required)
        ts.controller.meetingAgenda.name = null;
        System.assertEquals(null,ts.controller.saveFileAttachments());
        System.assert(ts.checkApexMessages(Label.gFRS_ERROR_MEETING_AGENDA_REQUIRED));

        ts.setupFellowships();
        ts.controller = new gFRS_FileAttachmentsController( new ApexPages.StandardController( ts.request ) );  
        //setting of isFoundationShown == true
        ts.controller.fundingRequest.Basic_Research_Fellow__c = 'Yes';
        //setting of validateFoundation == false 
        //Verify ERROR MESSAGE: (Audited Financials for last three years are required)
        ts.controller.form2008.name = 'test';
        ts.controller.form2009.name = 'test';
        ts.controller.form2010.name = 'test';
        System.assertEquals(null,ts.controller.saveFileAttachments());
        System.assert(ts.checkApexMessages(Label.gFRS_ERROR_AUDITED_FINANCIALS_REQUIRED));

        //setting of validateFoundation == false 
        //Verify ERROR MESSAGE: (Forms 990 for last three years are required)
        ts.controller.auditFin2008.name = 'test';
        ts.controller.auditFin2009.name = 'test';
        ts.controller.auditFin2010.name = 'test';
        ts.controller.form2008.name = null;
        ts.controller.form2009.name = null;
        ts.controller.form2010.name = null;
        System.assertEquals(null,ts.controller.saveFileAttachments());
        System.assert(ts.checkApexMessages(Label.gFRS_ERROR_FORMS_REQUIRED));

        ts.setupExhibits();
        //Verify ERROR MESSAGE: (Letter of Request is required)
        ts.controller.meetingAgenda.name = 'test';
        ts.controller.promoEvent.name = 'test';
        System.assertEquals(null,ts.controller.saveFileAttachments());
        System.assert(ts.checkApexMessages(Label.gFRS_ERROR_LOA_REQUIRED));

        //Verify ERROR MESSAGE: (Promotional/Event Advertising is required)
        ts.controller.letterRequest.name = 'test';
        ts.controller.promoEvent.name = null;
        System.assertEquals(null,ts.controller.saveFileAttachments());
        System.assert(ts.checkApexMessages(Label.gFRS_ERROR_PROMO_REQUIRED));

        ts.controller.isInternalRequest = false;
        //Verify ERROR MESSAGE: (Meeting Agenda is required)
        ts.setupIMED();
        ts.controller.needsAssessment.name = 'test';
        ts.controller.implementationPlan.name = 'test';
        System.assertEquals(null,ts.controller.saveFileAttachments());
        System.assert(ts.checkApexMessages(Label.gFRS_ERROR_MEETING_AGENDA_REQUIRED));

        //Verify ERROR MESSAGE: (Needs Assessment is required)
        ts.controller.needsAssessment.name = null;
        ts.controller.implementationPlan.name = 'test';
        System.assertEquals(null,ts.controller.saveFileAttachments());
        System.assert(ts.checkApexMessages(Label.gFRS_ERROR_NEEDS_ASSESMENT_REQUIRED));

        //Verify ERROR MESSAGE: (Implementation Plan is required)
        ts.controller.needsAssessment.name = 'test';
        ts.controller.implementationPlan.name = null;
        System.assertEquals(null,ts.controller.saveFileAttachments());
        System.assert(ts.checkApexMessages(Label.gFRS_ERROR_IMPLEMENTATION_PLAN_REQUIRED));

        //Verify ERROR MESSAGE: (Fellowship/Project Description is required)
        ts.controller.fellowshipProgram.name = null;
        System.assertEquals(null,ts.controller.saveFileAttachments());
        System.assert(ts.checkApexMessages(Label.gFRS_ERROR_FELLOWSHIP_REQUIRED));
    }

	
	static testMethod void testUploadMeetingAgendaAddAttachment(){

		TestSettings ts = new TestSettings();
        ts.setupIMED();        
        ts.createUser();
        
        ts.controller.meetingAgenda.name = DEMO_FILE_NAME;
        ts.controller.meetingAgenda.body = DEMO_FILE_DATA;
        
        
        Test.startTest();
        
        	GFRS_Funding_Request__c resultRequest = [ select Id,
	                (select Id, ParentId, Name from Attachments)
	                from GFRS_Funding_Request__c where id = :ts.controller.fundingRequest.id
	                limit 1];
	                
        	System.assert( resultRequest.Attachments == null || resultRequest.Attachments.size() == 0, 'There must not be any attachments on teh funding request[' + resultRequest.Attachments + ']' );
        
	        ts.controller.uploadMeetingAgenda();
	        
	        resultRequest = [ select Id,
	                (select Id, ParentId, Name from Attachments)
	                from GFRS_Funding_Request__c where id = :ts.controller.fundingRequest.id
	                limit 1];
	        
	        System.assert(resultRequest.Attachments.size()==1, 'Size of Attachments list: ' + resultRequest.Attachments);
	        
	        gFRS_Util_NoShare.createTask( 'Not Started', 'Test subject', '', ts.controller.fundingRequest.Id , ts.user.Id, 'RFI');
	        System.assert([select Id from gFRS_Tasks__c where gFRS_Funding_Request__c =: ts.controller.fundingRequest.Id].size()>0);
	        
	        ts.controller.fundingRequest.Information_Needed__c = 'Attachments';
        	update ts.controller.fundingRequest;
		
			List<Attachment> testAttachments = Test.loadData(Attachment.sObjectType, 'testAttachments');
	     
	        ts.controller.meetingAgenda = testAttachments.get(0);
	        ts.controller.meetingAgenda.ParentId = ts.controller.fundingRequest.Id;
	        ts.controller.meetingAgenda.Body = DEMO_FILE_DATA; 
	        ts.controller.meetingAgenda.Name = 'testAttachment'; 
	        update ts.controller.meetingAgenda;
	        
	        ts.controller.uploadMeetingAgenda();
	        
	        resultRequest = [ select Id,
	                (select Id, ParentId, Name from Attachments)
	                from GFRS_Funding_Request__c where id = :ts.controller.fundingRequest.id
	                limit 1];
	                
	    	System.assert(resultRequest.Attachments.size()==2, 'Size of Attachments list: ' + resultRequest.Attachments + ' : ' + (ts.controller.meetingAgenda.CreatedDate.getTime() + ' || ' + gFRS_Util_NoShare.getRfiDate(ts.controller.fundingRequest.Id).getTime()));
		Test.stopTest();
			
	}
*/

}