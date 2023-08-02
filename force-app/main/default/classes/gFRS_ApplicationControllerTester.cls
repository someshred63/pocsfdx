/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the  
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class gFRS_ApplicationControllerTester {
    
    /** demo base 64 data used **/
    public static final Blob DEMO_FILE_DATA = Blob.valueOf( 'ZGVtbyBiYXNlIDY0IGRhdGEgdXNlZA==' );
    public static final String DEMO_FILE_NAME = 'Demo.file';
    
    
    /**
     *  Internal Testing class that takes care of setup and tear downs.
     **/
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
        
        public gFRS_ApplicationController controller;
        
        public TestSettings(){
            //-- initialization done for ALL SETUPs done here
            this.account = gFRS_TestCreationUtils.createAccount( gFRS_TestCreationUtils.makeUnique( 'acct' ));
            insert this.account;
            
            this.organization = gFRS_TestCreationUtils.createOrganization2( '20110101', this.account.id );
            insert this.organization;
            System.debug('this.organization ' + this.organization);
            
            this.location = gFRS_TestCreationUtils.createLocation( 'SomeLocation', this.organization.id );
            insert this.location;
            
            GFRS_WBS_Codes__c[] WBSCodes = new List<GFRS_WBS_Codes__c>();
            GFRS_Cost_Center_Code__c[] CostCenterCodes =new List<GFRS_Cost_Center_Code__c>();
            GFRS_Administrative_Budget__c[] budgets = [select Id, Name from GFRS_Administrative_Budget__c];
            GFRS_Administrative_Budget_Line_Item__c[] budgetLIs = [select Id, Name from GFRS_Administrative_Budget_Line_Item__c];
            GFRS_Funding_Request__c[] reqs = [select Id, Name from GFRS_Funding_Request__c];
            GFRS_Funding_Allocation__c[] all = [select Id, Name from GFRS_Funding_Allocation__c];
            //delete WBSCodes;
            //delete CostCenterCodes;
       //     delete budgets;

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
            this.request = gFRS_TestCreationUtils.createFundingRequest2( gFRS_TestCreationUtils.RT_FR_IMED, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id);
            this.prepareRequestForUpdate();
            insert this.request;
        }
        
        public void setupCorporate(){
            this.request = gFRS_TestCreationUtils.createFundingRequest2( gFRS_TestCreationUtils.RT_FR_CORPORATE_MEMBERSHIPS, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id);
            this.prepareRequestForUpdate();
            insert this.request;
        }
        
        public void setupExhibitsWithBlob(){
            this.request = gFRS_TestCreationUtils.createFundingRequest2( gFRS_TestCreationUtils.RT_FR_EXHIBITS_OTHER_PROMOS, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id);
            this.request.Funding_Sub_Type__c = 'Exhibit Booth';
            this.prepareRequestForUpdate();
            insert this.request;
            
            meetingAgenda = new Attachment(ParentId = this.request.id, name='Meeting Agenda Test');
            Blob b = Blob.valueOf('test meeting agenda');  
            meetingAgenda.body=b;
            insert meetingAgenda;
            
            this.request.Meeting_Agenda__c = meetingAgenda.id;
            update this.request;         
        }
        
         public void setupExhibits(){
            this.request = gFRS_TestCreationUtils.createFundingRequest2( gFRS_TestCreationUtils.RT_FR_EXHIBITS_OTHER_PROMOS, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id);
            this.request.Funding_Sub_Type__c = 'Exhibit Booth';
            this.prepareRequestForUpdate();
            insert this.request;    
        }
        
        public void setupFellowships(){
            this.request = gFRS_TestCreationUtils.createFundingRequest2( gFRS_TestCreationUtils.RT_FR_FELLOWSHIPS, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id);
            this.prepareRequestForUpdate();
            insert this.request;
        }
        
         public void setupField(){
            this.request = gFRS_TestCreationUtils.createFundingRequest2( gFRS_TestCreationUtils.RT_FR_FIELD_INITIATED_EXHIBITS, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id);
            this.prepareRequestForUpdate();
            insert this.request;
        }
        
         public void setupHCChar(){
            this.request = gFRS_TestCreationUtils.createFundingRequest2( gFRS_TestCreationUtils.RT_FR_HC_CHAR, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id);
            this.prepareRequestForUpdate();
            insert this.request;
        }
        
         public void setupPhilanthropic(){
            this.request = gFRS_TestCreationUtils.createFundingRequest2( gFRS_TestCreationUtils.RT_FR_PHILANTHROPIC, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id);
            this.prepareRequestForUpdate();
            insert this.request;
        }
        
         public void setupScientific(){
            this.request = gFRS_TestCreationUtils.createFundingRequest2( gFRS_TestCreationUtils.RT_FR_SCIENTIFIC_PROJECTS, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id);
            this.prepareRequestForUpdate();
            insert this.request;
        }
        
        public void setupCorporateMembership(){
            this.request = gFRS_TestCreationUtils.createFundingRequest2( gFRS_TestCreationUtils.RT_FR_CORPORATE_MEMBERSHIPS, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id);
            this.prepareRequestForUpdate();
            insert this.request;
        }
        
        public void setupCorporateMembershipCustom(){
            this.request = gFRS_TestCreationUtils.createFundingRequest2( gFRS_TestCreationUtils.RT_FR_CORPORATE_MEMBERSHIPS, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id);
            this.prepareRequestForUpdate();
            this.request.Requested_Amount__c=10000;
            insert this.request;
        }
        
        
        public void setupControllerIndex0(){
            ApexPages.PageReference imedPage = new ApexPages.PageReference( '?id=' + this.request.id + '&' + gFRS_UTIL.PARAM_CURRENT_INDEX + '=0' );
            Test.setCurrentPage( imedPage );
            
            this.controller = new gFRS_ApplicationController( new ApexPages.StandardController( this.request ) );
        }
        
        public void setupControllerIndex1(){
            ApexPages.PageReference imedPage = new ApexPages.PageReference( '?id=' + this.request.id + '&' + gFRS_UTIL.PARAM_CURRENT_INDEX + '=0' );
            Test.setCurrentPage( imedPage );
            
            this.controller = new gFRS_ApplicationController( new ApexPages.StandardController( this.request ) );
        }
        
        public void createUser(){
            PROF_GFRS_USER = [ select Id, Name, Type from Profile where Name =:PROF_GFRS_USER_NAME limit 1 ].Id;
            user = gFRS_TestCreationUtils.createUser3('Test', 'test', 'aaa@gene.com', PROF_GFRS_USER, '1234');
            insert user;
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
        
        // cleanup the fundingRequest to the point that an update can occur
        public void prepareRequestForUpdate(){
            //this.request.Name = 'testRequest';
            
        }
        
        public  void createTwoSplits(Boolean setCostCenter){
            this.allocation = gFRS_TestCreationUtils.createFundingAllocation_min(this.request);
            insert this.allocation;
            
            this.adminBudget = gFRS_TestCreationUtils.createAdminBudget(null, null);
            insert this.adminBudget;
            this.adminBudgetLI = gFRS_TestCreationUtils.createAdminBudgetLI('abc', 200, adminBudget.Id);
            insert this.adminBudgetLi;
            
            GFRS_Funding_Allocation_Line_Item__c item1 = gFRS_TestCreationUtils.createFundingAllocationLIWithNumber(this.allocation, 10, 1);
            
            GFRS_Funding_Allocation_Line_Item__c item2 = gFRS_TestCreationUtils.createFundingAllocationLIWithNumber(this.allocation, 50, 5);
            
            this.allocationLIs = new GFRS_Funding_Allocation_Line_Item__c[]{
                item1, item2
                
            };
            insert this.allocationLIs;
            System.debug('this.allocationLIs: ' + this.allocationLIs);

        }

        public Boolean checkApexMessages(String message) {
            for(Apexpages.Message msg : ApexPages.getMessages()){
                if (msg.getDetail().contains(message)) {
                    return true;
                }
            }
            return false;
        }
    }
   
    static testmethod void testGetThirdPartyWrapperList(){
    	TestSettings ts = new TestSettings();
    	ts.setupIMED();
    	ts.setupControllerIndex0();	
    	
    	Test.startTest();
    	
    	ts.controller.getThirdPartyWrapperList();
    	
    	System.assert([SELECT Id FROM GFRS_Third_Party__c WHERE Funding_Request__c = :ts.request.Id].size() == 1);
    	
    	Test.stopTest();
    }
    

    
   static testmethod void testSettingsSetsUpWithoutErrors(){
        try {
            TestSettings ts = new TestSettings();
            ts.setupIMED();
            //ts.setupA(); //-- perform specialized setup if needed
        } catch( Exception err ){
            System.assert( false, 'TestSetting/Setup must not throw any exceptions' );
        }
    }
 
    static testmethod  void testLoadFundingRequest(){
        try {
            TestSettings ts = new TestSettings();
            ts.setupIMED();
            ts.setupControllerIndex0();
        } catch( Exception err ){
            System.assert( false, 'exception must not occur from creating the controller:' + err.getmessage() );
        }
    }

    
    /*static testmethod  void testuploadAuditFin2010(){
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ts.setupControllerIndex0();
        
        System.assert( ts.request.Attachments == null || ts.request.Attachments.size() == 0, 'There must not be any attachments on teh funding request[' + ts.request.Attachments + ']' );
        
        //-- mock data being sent for file upload as base64
        ts.controller.auditFin2010.name = DEMO_FILE_NAME;
        ts.controller.auditFin2010.body = DEMO_FILE_DATA;
        
        ts.controller.uploadAuditFin2010();
        
        GFRS_Organization__c foundOrg = ts.refreshOrganization();

        ts.controller.uploadAuditFin2010();
        
        System.assertEquals( 1, foundOrg.Attachments.size(), 'The attachment was not saved' );
    }
    
    static testmethod  void testuploadAuditFin2009(){
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ts.setupControllerIndex0();
        
        System.assert( ts.request.Attachments == null || ts.request.Attachments.size() == 0, 'There must not be any attachments on teh funding request[' + ts.request.Attachments + ']' );
        
        //-- mock data being sent for file upload as base64
        ts.controller.auditFin2009.name = DEMO_FILE_NAME;
        ts.controller.auditFin2009.body = DEMO_FILE_DATA;
        
        ts.controller.uploadAuditFin2009();
        
        GFRS_Organization__c foundOrg = ts.refreshOrganization();

        ts.controller.uploadAuditFin2009();
        
        System.assertEquals( 1, foundOrg.Attachments.size(), 'The attachment was not saved' );
    }
    
    static testmethod  void testuploadAuditFin2008(){
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ts.setupControllerIndex0();
        
        System.assert( ts.request.Attachments == null || ts.request.Attachments.size() == 0, 'There must not be any attachments on teh funding request[' + ts.request.Attachments + ']' );
        
        //-- mock data being sent for file upload as base64
        ts.controller.auditFin2008.name = DEMO_FILE_NAME;
        ts.controller.auditFin2008.body = DEMO_FILE_DATA;
        
        ts.controller.uploadAuditFin2008();
        
        GFRS_Organization__c foundOrg = ts.refreshOrganization();

        ts.controller.uploadAuditFin2008();
        
        System.assertEquals( 1, foundOrg.Attachments.size(), 'The attachment was not saved' );
    }
    
    static testmethod  void testuploadForm2008(){
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ts.setupControllerIndex0();
        
        System.assert( ts.request.Attachments == null || ts.request.Attachments.size() == 0, 'There must not be any attachments on teh funding request[' + ts.request.Attachments + ']' );
        
        //-- mock data being sent for file upload as base64
        ts.controller.form2008.name = DEMO_FILE_NAME;
        ts.controller.form2008.body = DEMO_FILE_DATA;
        
        ts.controller.uploadForm2008();
        
        GFRS_Organization__c foundOrg = ts.refreshOrganization();

        ts.controller.uploadForm2008();
        
        System.assertEquals( 1, foundOrg.Attachments.size(), 'The attachment was not saved' );
    }
    
    static testmethod  void testuploadForm2009(){
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ts.setupControllerIndex0();
        
        System.assert( ts.request.Attachments == null || ts.request.Attachments.size() == 0, 'There must not be any attachments on teh funding request[' + ts.request.Attachments + ']' );
        
        //-- mock data being sent for file upload as base64
        ts.controller.form2009.name = DEMO_FILE_NAME;
        ts.controller.form2009.body = DEMO_FILE_DATA;
        
        ts.controller.uploadForm2009();
        
        GFRS_Organization__c foundOrg = ts.refreshOrganization();

        ts.controller.uploadForm2009();
        
        System.assertEquals( 1, foundOrg.Attachments.size(), 'The attachment was not saved' );
    }
    
   
    static testmethod  void testuploadForm2010(){
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ts.setupControllerIndex0();
        
        System.assert( ts.request.Attachments == null || ts.request.Attachments.size() == 0, 'There must not be any attachments on teh funding request[' + ts.request.Attachments + ']' );
        
        //-- mock data being sent for file upload as base64
        ts.controller.form2010.name = DEMO_FILE_NAME;
        ts.controller.form2010.body = DEMO_FILE_DATA;
        
        ts.controller.uploadForm2010();
        
        GFRS_Organization__c foundOrg = ts.refreshOrganization();

        ts.controller.uploadForm2010();
        
        System.assertEquals( 1, foundOrg.Attachments.size(), 'The attachment was not saved' );
    }
*/
    
    static testmethod  void backOnFirstPanelMustGoBack(){
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ts.setupControllerIndex0();
        
        ts.controller.currentIndex = 0;
        //ts.controller.showThirdParty = false;
        ts.controller.showAllocationGrid = false;
        
        ApexPages.PageReference redirect = ts.controller.back();
        String targetUrl = redirect.getUrl();
        
        System.assertEquals( true, targetURL.contains( gFRS_ApplicationController.PATH_BACK ), 'since we are at the first index, we should go back but are going to:' + targetUrl );
        System.assertEquals( false, targetURL.contains( 'apex/GFRS_Application' ), 'since we are at the first index, we should not stay on the page, but are going to:' + targetUrl );
    }
    
    
    static testmethod  void backWhenPossibleMustMoveBackIndex(){
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ts.setupControllerIndex0();
        
        ts.controller.currentIndex = 1;
        //ts.controller.showThirdParty = true;
        ts.controller.showAllocationGrid = false;
        
        ApexPages.PageReference redirect = ts.controller.back();
        String targetUrl = redirect.getUrl();
        
        System.assertEquals( false, targetURL.contains( gFRS_ApplicationController.PATH_BACK ), 'since we are at the second index, we not go back but are going to:' + targetUrl );
        System.assertEquals( true, targetURL.contains( 'apex/GFRS_Application' ), 'since we are at the second index, we should stay on the page but are going to:' + targetUrl );
    }
    
    //-- next
    
    static testmethod  void nextOnLastMustMoveNext(){
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ts.setupControllerIndex0();
        
        ts.controller.currentIndex = 0;
        //ts.controller.showThirdParty = false;
        ts.controller.showAllocationGrid = false;
        
        ApexPages.PageReference redirect = ts.controller.next();
        String targetUrl = redirect.getUrl();
        
        //System.assertEquals( true, targetURL.contains( gFRS_ApplicationController.PATH_COMPLETE ), 'since there isnt a next index, next should go to the next page but are going to:' + targetUrl );
        System.assertEquals( false, targetURL.contains( 'apex/GFRS_Application' ), 'since there isnt a next index, we should not stay on the page, but are going to:' + targetUrl );
    }
    
    
    static testmethod  void nextWhenPossibleMustMoveNextIndex(){
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ts.setupControllerIndex0();
        
        ts.controller.currentIndex = 0;
       // ts.controller.isCMEOShown = true;
        ts.controller.showAllocationGrid = true;
        
        ApexPages.PageReference redirect = ts.controller.next();
        String targetUrl = redirect.getUrl();
        
        //System.assertEquals( false, targetURL.contains( gFRS_ApplicationController.PATH_COMPLETE ), 'since there is a next index, next should not go to the next page but are going to:' + targetUrl );
        System.assertEquals( true, targetURL.contains( 'apex/GFRS_Application' ), 'since there is a next index, we should stay on the page, but are going to:' + targetUrl );
    }

    
    
    static testmethod void testThirdPartySavesCorrectly(){
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ts.setupControllerIndex0();

        GFRS_Third_Party__c thirdPartyRecord;
        
        ts.controller.thirdPartyRecords = null;
        
        System.assertEquals( false, ts.controller.validateThirdParty(), 'If no third party records are present, then a save must not continue' );
        
        //validate for Company_Name__c == null
        
        thirdPartyRecord = gFRS_TestCreationUtils.createThirdParty( ts.request.id, 'John', 'Doe', null, 'jdoe@accme.com', 'Janitor' );
        
        upsert thirdPartyRecord;
        ts.controller.getThirdPartyWrapperList();
        System.assertEquals( false, ts.controller.validateThirdParty());
        System.assert(ts.checkApexMessages(Label.gFRS_ThirdParty_Company_Name_Error));
        ts.controller.clearThirdParty();

        //validate for Third_Party_Contact_First_Name__c == null
        ts.controller.thirdPartyRecords = new GFRS_Third_Party__c[]{
            gFRS_TestCreationUtils.createThirdParty( ts.request.id, null, 'Doe', 'Accme Co.', 'jdoe@accme.com', 'Janitor' )
        }; 
        upsert ts.controller.thirdPartyRecords;
        ts.controller.getThirdPartyWrapperList();

        System.assertEquals( false, ts.controller.validateThirdParty());
        System.assert(ts.checkApexMessages(Label.gFRS_ThirdParty_Contact_FirstName_Error));
        ts.controller.clearThirdParty();

        //validate for Third_Party_Contact_Last_Name__c == null
        ts.controller.thirdPartyRecords = new GFRS_Third_Party__c[]{
            gFRS_TestCreationUtils.createThirdParty( ts.request.id, 'John', null, 'Accme Co.', 'jdoe@accme.com', 'Janitor' )
        }; 
        upsert ts.controller.thirdPartyRecords;
        ts.controller.getThirdPartyWrapperList();

        System.assertEquals( false, ts.controller.validateThirdParty());
        System.assert(ts.checkApexMessages(Label.gFRS_ThirdParty_Contact_LastName_Error));
        ts.controller.clearThirdParty();

        //validate for Third_Party_Company_Function__c == null
        ts.controller.thirdPartyRecords = new GFRS_Third_Party__c[]{
            gFRS_TestCreationUtils.createThirdParty( ts.request.id, 'John', 'Doe', 'Accme Co.', 'jdoe@accme.com', null )
        }; 
        upsert ts.controller.thirdPartyRecords;
        ts.controller.getThirdPartyWrapperList();

        System.assertEquals( false, ts.controller.validateThirdParty());
        System.assert(ts.checkApexMessages(Label.gFRS_ThirdParty_Company_Function_Error));
        ts.controller.clearThirdParty();

        //validate for Third_Party_Contact_Email__c == null
        ts.controller.thirdPartyRecords = new GFRS_Third_Party__c[]{
            gFRS_TestCreationUtils.createThirdParty( ts.request.id, 'John', 'Doe', 'Accme Co.', null, 'Janitor' )
        }; 
        upsert ts.controller.thirdPartyRecords;
        ts.controller.getThirdPartyWrapperList();

        System.assertEquals( false, ts.controller.validateThirdParty());
        System.assert(ts.checkApexMessages(Label.gFRS_ThirdParty_Contact_Email_Error));
        ts.controller.clearThirdParty();
    
        //validate for fulfilled all data
        ts.controller.thirdPartyRecords = new GFRS_Third_Party__c[]{
            gFRS_TestCreationUtils.createThirdParty( ts.request.id, 'John', 'Doe', 'Accme Co.', 'jdoe@accme.com', 'Janitor' ) 
        };
        
        upsert ts.controller.thirdPartyRecords;
        ts.controller.getThirdPartyWrapperList();
        
        System.assertEquals( true, ts.controller.validateThirdParty(), 'As there are third party records, they must be allowed to save' );
        
        ApexPages.PageReference result = ts.controller.saveThirdParty();
        
        System.assertNotEquals( null, result, 'As the validation succeeded, the save must continue' );   
    }

    
    static testmethod  void testThirdPartyShowsCorrectly(){
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ts.setupControllerIndex0();
        ts.controller.fundReq.Will_You_be_Working_With_a_3rd_Party__c = gFRS_Util.YES;
        System.assertEquals( true, ts.controller.showThirdParty, 'third party should be shown' );
        ts.controller.fundReq.Will_You_be_Working_With_a_3rd_Party__c = gFRS_Util.NO;
        System.assertEquals( false, ts.controller.showThirdParty, 'third party should not be shown' );
    }

    
    static testmethod void testFoundationShowsCorrectly(){
        TestSettings ts = new TestSettings();
        ts.setupHCChar();
        ts.setupControllerIndex0();
        ts.controller.fundReq.Pediatric_Cancer_Assistance__c  = gFRS_Util.YES;
        System.assertEquals( true, ts.controller.isFoundationShown , 'foundation should be shown' );
        ts.controller.fundReq.Pediatric_Cancer_Assistance__c = gFRS_Util.NO;
        System.assertEquals( false, ts.controller.isFoundationShown , 'foundation should not be shown' );

        ts.setupFellowships();
        ts.setupControllerIndex0();
        ts.controller.fundReq.Basic_Research_Fellow__c  = gFRS_Util.YES;
        System.assertEquals( true, ts.controller.isFoundationShown , 'foundation should be shown' );
        ts.controller.fundReq.Basic_Research_Fellow__c = gFRS_Util.NO;
        System.assertEquals( false, ts.controller.isFoundationShown , 'foundation should not be shown' );

        ts.setupPhilanthropic();
        ts.setupControllerIndex0();
        ts.controller.fundReq.Students_of_Color_Scholarships__c  = gFRS_Util.YES;
        System.assertEquals( true, ts.controller.isFoundationShown , 'foundation should be shown' );
        ts.controller.fundReq.Students_of_Color_Scholarships__c = gFRS_Util.NO;
        ts.controller.fundReq.Hunger__c = gFRS_Util.NO;
        ts.controller.fundReq.Requested_Amount__c = 26000;
        System.assertEquals( true, ts.controller.isFoundationShown , 'foundation should be shown' );
        ts.controller.fundReq.Requested_Amount__c = 24000;
        System.assertEquals( false, ts.controller.isFoundationShown , 'foundation should not be shown' );
    }


    
    static testmethod  void testCMEOShowsCorrectly(){
        TestSettings ts = new TestSettings();
        ts.setupCorporate();
        ts.setupControllerIndex0();
        
        ts.controller.fundReq.Benefits_Exchanged_for_Funding__c = null;
        System.assertEquals( false, ts.controller.isCMEOShown  , 'CMEO should not be shown' );
        
        ts.controller.fundReq.Benefits_Exchanged_for_Funding__c  = gFRS_Util.EXHIBIT_SPACE;
        //update ts.controller.fundReq;
        System.assertEquals( true, ts.controller.isCMEOShown  , 'CMEO should be shown' );
       
    }

    @isTest(SeeAllData=true)
    static  void testCostCenterApproverWS(){
    	
    	GFRS_OrgSettings__c myOrgCS = GFRS_OrgSettings__c.getOrgDefaults();
        myOrgCS.Funding_Request_Trigger_Enabled__c = true;
        update myOrgCS;
        
        TestSettings ts = new TestSettings();
        ts.setupExhibits();
        ts.createTwoSplits(true);
        
        ts.createUser();
        ts.request.Financial_Approver_2__c = ts.user.id;
        update(ts.request);
        
        
        
        Test.StartTest();
        ts.setupControllerIndex0();
        ts.controller.fundReq.Requested_Amount__c = 20000;
       
        //test if error flag was added if WS fails
        
        ts.controller.callWebServices();
        System.assertEquals( null, gFRS_Util.multiSelectHasItem(ts.controller.fundReq.gCOI_Pending_Actions__c, gFRS_ApplicationController.ACTION_WS_MISSING_UNIX)  , 'Error flag not set to request object' );
        ts.controller.fundReq.gCOI_Pending_Actions__c = null;
        
        gFRS_CostCenterApprovalWS.costCenterApprvers_element cc1 = new gFRS_CostCenterApprovalWS.costCenterApprvers_element();
        cc1.costCenter = '7701';
        cc1.amount = '1000.00';
        cc1.firstName = 'Cyanna';
        cc1.lastName = 'Cyanna';
        cc1.unixId = 'sandora1';
        gFRS_CostCenterApprovalWS.costCenterApprvers_element[] costCenterApprvers = new gFRS_CostCenterApprovalWS.costCenterApprvers_element[]{
            cc1
        };
        gFRS_CostCenterApprovalWS.costCenterApproverResponse_element result = new gFRS_CostCenterApprovalWS.costCenterApproverResponse_element();
        
        //test if error flag was added if no records returned
        result.MessageType = 'Successful';
        result.MessageText = 'Successfully retreaved the CostCenter Approver Hierarchy';
        ts.controller.handleWSResponse(result);
        System.assertEquals( true, gFRS_Util.multiSelectHasItem(ts.controller.fundReq.gCOI_Pending_Actions__c, gFRS_ApplicationController.ACTION_WS_MISSING_UNIX)  , 'Error flag not set to request object' );
        ts.controller.fundReq.gCOI_Pending_Actions__c = null;
        
        //test if error flag was added if error msg returned
        result.MessageType = 'Successful';
        result.MessageText = gFRS_ApplicationController.WS_NO_APPROVERS;
        ts.controller.handleWSResponse(result);
        System.assertEquals( true, gFRS_Util.multiSelectHasItem(ts.controller.fundReq.gCOI_Pending_Actions__c, gFRS_ApplicationController.ACTION_WS_MISSING_UNIX)  , 'Error flag not set to request object' );
        ts.controller.fundReq.gCOI_Pending_Actions__c = null;
        
        //test if success
        result.MessageText = 'Successfully retreaved the CostCenter Approver Hierarchy';
        result.costCenterApprvers = costCenterApprvers;
        ts.controller.handleWSResponse(result);
        System.assertEquals( true, ts.controller.costCenterApprovers[0].firstName == 'Cyanna'  , 'costCenterApprovers object not set' );
        System.assertEquals( true, ts.controller.costCenterApproversMap.get('sandora1') != null , 'costCenterApproversMap object not set' );
        System.assertEquals( true, ts.controller.fundReq.gCOI_Pending_Actions__c==null  , 'Error flag shouldn\'t be set' );
        System.assertEquals( false, ts.controller.costCenterApprovers[0].canApproveRequest  , 'canApproveRequest set incorrectly' );
        System.assertEquals( false, ts.controller.costCenterApprovers[0].isChecked  , 'isChecked set incorrectly' );
        
        
        gFRS_CostCenterApprovalWS.costCenterApprvers_element cc2 = new gFRS_CostCenterApprovalWS.costCenterApprvers_element();
        cc2.costCenter = '7701';
        cc2.amount = '100000.00';
        cc2.firstName = 'test';
        cc2.lastName = 'test';
        cc2.unixId = 'aaa';
        costCenterApprvers.add(cc2);
        result.costCenterApprvers = costCenterApprvers;
        
        ts.controller.handleWSResponse(result);
        System.assertEquals( true, ts.controller.costCenterApprovers[1].firstName == 'test'  , 'costCenterApprovers object not set' );
        System.assertEquals( true, ts.controller.costCenterApprovers[1].canApproveRequest  , 'canApproveRequest set incorrectly' );
        System.assertEquals( true, ts.controller.costCenterApprovers[1].isChecked  , 'isChecked set incorrectly' );
        Test.StopTest();
    }


    
    static testmethod void testSaveAllocationItems2(){
    	
    	TestSettings ts = new TestSettings();
        
      	
        ts.createUser();
        
        //System.RunAs(ts.user)
        //{
    		GFRS_Cost_Center_Code__c testCenterCode1000 = gFRS_UnitTestHelper.createCostCenterCode('1111', '1000');
        GFRS_Cost_Center_Code__c testCenterCode1010 = gFRS_UnitTestHelper.createCostCenterCode('2222', '1010');
        
        
        GFRS_WBS_Codes__c testWBS1010 = gFRS_TestCreationUtils.createWBSCodeWithSAPCompanyCode('309.07076', null, 'Field Initiated Exhibits', null, null, '1010');
        GFRS_WBS_Codes__c testWBS1000 = gFRS_TestCreationUtils.createWBSCodeWithSAPCompanyCode('309.01006', null, 'Field Initiated Exhibits', null, null, '1000');
        
        insert testWBS1010;
        insert testWBS1000;
        
        
        
      	gFRS_UnitTestHelper.setGfrsCustomSettings(false);
            ts.setupField();
            gFRS_Funding_Allocation__c fundingAllocation = gFRS_UnitTestHelper.createFundingAllocation(ts.request);
            //ts.createTwoSplits(true);
            ts.setupControllerIndex0();
         
            Test.startTest();
            ts.controller.fundReq.Entering_on_Behalf_of_Another__c = gFRS_Util.NO;
            ts.controller.fundReq.Financial_Approver_1__c = ts.user.id;
            ts.controller.allocationLi = new GFRS_Funding_Allocation_Line_Item__c();
 
            //Case #1
            ts.controller.currentCostCenterName = '1111';
            ts.controller.saveAllocationItems();
            System.assertEquals( true, ts.controller.allocationLi.WBS_Code_Lookup__c ==  testWBS1000.Id , 'PN : ' + testWBS1000.Id + ' ; ' +  ts.controller.allocationLi.WBS_Code_Lookup__c);
            
            //Case #2
            ts.controller.currentCostCenterName = '2222';
            ts.controller.saveAllocationItems();
            System.assertEquals( true, ts.controller.allocationLi.WBS_Code_Lookup__c ==  testWBS1010.Id );
            
            Test.stopTest();
        //}	
    }
    
    static testmethod void testSaveAllocationItems(){
       
        TestSettings ts = new TestSettings();
        
        ts.createUser();
        
        System.RunAs(ts.user)
        {
            ts.setupField();
            //ts.createTwoSplits(true);
            ts.setupControllerIndex0();
         
            Test.startTest();
            ts.controller.fundReq.Entering_on_Behalf_of_Another__c = gFRS_Util.NO;
            ts.controller.fundReq.Financial_Approver_1__c = ts.user.id;
            ts.controller.saveAllocationItems();
            System.assertEquals( true, ts.controller.fundReq.Accountable_Employee_Approval__c == ts.user.id  , 'Accountable_Employee_Approval__c set incorrectly' );
            System.assertEquals( true, ts.controller.fundReq.Financial_Approver_1__c == ts.user.id  , 'Financial_Approver_1__c set incorrectly' );
            Test.stopTest();
        }
    }

	@isTest(SeeAllData=true)
    static  void testSaveAllocationItemsForCorpMembers(){
       
        TestSettings ts = new TestSettings();
        
        ts.createUser();
        
        GFRS_OrgSettings__c myOrgCS = GFRS_OrgSettings__c.getOrgDefaults();
        myOrgCS.Funding_Request_Trigger_Enabled__c = true;
        update myOrgCS;
        
        System.RunAs(ts.user)
        {
        	System.assertNotEquals([select id, GFRS_Content__r.Name, TextBlock__c from GFRS_Content_Translation__c where GFRS_Content__r.Filter__c = 'Firewall' order by GFRS_Content__r.Name].size(),0);
			System.assertNotEquals(myOrgCS.Funding_Request_Trigger_Enabled__c , false);
            ts.setupCorporateMembershipCustom();
            
            ts.setupControllerIndex0();
         
            Test.startTest();
            
            System.assertNotEquals(ts.controller, null);
            
            ts.controller.fundReq.Entering_on_Behalf_of_Another__c = gFRS_Util.NO;
            ts.controller.fundReq.Financial_Approver_1__c = ts.user.id;
            ts.controller.fundReq.Requested_Amount__c=10000;
            ts.controller.saveAllocationItems();
            
           	System.assertNotEquals(ts.controller.allocationLI, null);
            System.assertNotEquals([select id from GFRS_Funding_Allocation_Line_Item__c].size(), 0);        
            Test.stopTest();
        }
    }


     static testmethod   void testSaveFinancialApprovers(){
        TestSettings ts = new TestSettings();
        ts.setupExhibits();
        ts.createTwoSplits(true);
        
        ts.createUser();
        ts.request.Financial_Approver_2__c = ts.user.id;
        update(ts.request);
        
        Test.startTest(); 
        ts.setupControllerIndex0();
        ts.controller.fundReq.Requested_Amount__c = 20000; 
        gFRS_CostCenterApprovalWS.costCenterApprvers_element cc1 = new gFRS_CostCenterApprovalWS.costCenterApprvers_element();
        cc1.costCenter = '7701';
        cc1.amount = '100000.00';
        cc1.firstName = 'Cyanna';
        cc1.lastName = 'Cyanna';
        cc1.unixId = 'aaa';
        gFRS_CostCenterApprovalWS.costCenterApprvers_element[] costCenterApprvers = new gFRS_CostCenterApprovalWS.costCenterApprvers_element[]{
            cc1
        };
        gFRS_CostCenterApprovalWS.costCenterApproverResponse_element result = new gFRS_CostCenterApprovalWS.costCenterApproverResponse_element();
        
        //test if error flag was added if no records returned
        result.MessageType = 'Successful';
        result.MessageText = 'Successfully retreaved the CostCenter Approver Hierarchy';
        result.costCenterApprvers = costCenterApprvers;
        ts.controller.handleWSResponse(result);
        
        ts.controller.selectedCostCenterUnixId = 'aaa';
        ts.controller.fundReq.Finance_Managers__c = 'aaa aaa (aaa)';
        System.RunAs(ts.user){
            ts.controller.saveFinancialApprovers(); 
            System.assertEquals( true, ts.controller.fundReq.Financial_Approver_1__c != null  , 'Financial_Approver_1__c set incorrectly' );
            System.assertEquals( true, ts.controller.fundReq.Financial_Approver_2__c == ts.user.id  , 'Financial_Approver_2__c set incorrectly' );
            System.assertEquals( true, ts.controller.fundReq.Financial_Approver_3__c == ts.user.id  , 'Financial_Approver_3__c set incorrectly' );          
        }
        Test.stopTest(); 
     }
     
     /*static testmethod  void testSaveFoundation(){
        TestSettings ts = new TestSettings();
        ts.setupField();
        ts.setupControllerIndex0();
        ts.controller.auditFin2008.name = DEMO_FILE_NAME;
        ts.controller.auditFin2008.body = DEMO_FILE_DATA;
        
        ts.controller.auditFin2009.name = DEMO_FILE_NAME;
        ts.controller.auditFin2009.body = DEMO_FILE_DATA;
        
        ts.controller.auditFin2010.name = DEMO_FILE_NAME;
        ts.controller.auditFin2010.body = DEMO_FILE_DATA;
        
        ts.controller.form2008.name = DEMO_FILE_NAME;
        ts.controller.form2008.body = DEMO_FILE_DATA;
        
        ts.controller.form2009.name = DEMO_FILE_NAME;
        ts.controller.form2009.body = DEMO_FILE_DATA;
        
        ts.controller.form2010.name = DEMO_FILE_NAME;
        ts.controller.form2010.body = DEMO_FILE_DATA;
        
        ts.controller.saveFoundation();
        System.assertEquals( false, ApexPages.hasMessages()  , 'validation returned errors and it shouldn\'t' );
        
         ts.controller.auditFin2008.name = null;
        ts.controller.auditFin2008.body = null;
        
        ts.controller.auditFin2009.name = null;
        ts.controller.auditFin2009.body = null;
        
        ts.controller.auditFin2010.name = null;
        ts.controller.auditFin2010.body = null;
        
        ts.controller.form2008.name = null;
        ts.controller.form2008.body = null;
        
        ts.controller.form2009.name = null;
        ts.controller.form2009.body = null;
        
        ts.controller.form2010.name = null;
        ts.controller.form2010.body = null;
        
        ts.controller.saveFoundation();
        System.assertEquals( true, ApexPages.hasMessages()  , 'validation did not worked' );
        
     }*/
    
     
     static testmethod  void testSaveCMEO(){
        TestSettings ts = new TestSettings();
        ts.setupExhibitsWithBlob();
        ts.setupControllerIndex0();
        ts.controller.saveCMEO();
        System.assertEquals( false, ApexPages.hasMessages()  , 'validation method is not working correctly' );
     }
  
     
     static testmethod  void testSavePage(){
        TestSettings ts = new TestSettings();
        ts.setupScientific();
        ts.setupControllerIndex0();
        

        ts.controller.savePage();
        System.assertEquals( false, ApexPages.hasMessages()  , 'validation method is not working correctly' );
     }
     
     
     static testmethod void testProjectTypeSelected(){
     	
        TestSettings ts = new TestSettings();
        ts.setupScientific();
        ts.setupControllerIndex0();
        
        Test.startTest();
        
        ts.controller.projectType = gFRS_Util.REQUEST_PROGRAM_TYPE_CLINICAL_TRIAL;
        ts.controller.clinicalTrialFlag = false;
		ts.controller.projectTypeSelected();
        System.assertEquals( true, ts.controller.clinicalTrialFlag );
        
        ts.controller.projectType = '';
        ts.controller.projectTypeSelected();
        System.assertEquals( false, ts.controller.clinicalTrialFlag );
        
        Test.stopTest();
     }

     static testmethod void testClearFoundation(){
        TestSettings ts = new TestSettings();
        ts.setupField();
        ts.organization.Outstanding_Accounts_Payable__c = 1000;
        ts.organization.Salary_of_the_Highest_Paid_Executive__c = 1000;
        ts.organization.Pending_Litigation__c = 'Yes';
        update ts.organization;
        ts.setupControllerIndex0();
/*
        ts.controller.auditFin2008.name = DEMO_FILE_NAME;
        ts.controller.auditFin2008.body = DEMO_FILE_DATA;
        ts.controller.uploadAuditFin2008();
        
        ts.controller.auditFin2009.name = DEMO_FILE_NAME;
        ts.controller.auditFin2009.body = DEMO_FILE_DATA;
        ts.controller.uploadAuditFin2009();
        
        ts.controller.auditFin2010.name = DEMO_FILE_NAME;
        ts.controller.auditFin2010.body = DEMO_FILE_DATA;
        ts.controller.uploadAuditFin2010();
        
        ts.controller.form2008.name = DEMO_FILE_NAME;
        ts.controller.form2008.body = DEMO_FILE_DATA;
        ts.controller.uploadForm2008();
        
        ts.controller.form2009.name = DEMO_FILE_NAME;
        ts.controller.form2009.body = DEMO_FILE_DATA;
        ts.controller.uploadForm2009();
        
        ts.controller.form2010.name = DEMO_FILE_NAME;
        ts.controller.form2010.body = DEMO_FILE_DATA;
        ts.controller.uploadForm2010();
*/
        ts.controller.saveFoundation();
        System.assertEquals(ts.controller.organization.Audited_Financials_for_the_previous_thre__c,null);
        System.assertEquals(ts.controller.organization.Audited_Financials_for_the_previous_two__c,null);
        System.assertEquals(ts.controller.organization.Audited_financials_for_the_previous_year__c,null);
        System.assertEquals(ts.controller.organization.Form_990_for_the_previous_three_year__c,null);
        System.assertEquals(ts.controller.organization.Form_990_for_the_previous_two_year__c,null);
        System.assertEquals(ts.controller.organization.Form_990_for_the_previous_year__c,null);

        List<Attachment> organizationAttachments = new List<Attachment>();
        for (String attKey : ts.controller.apiNameToAttachmentMap.keySet()){
            organizationAttachments.add(ts.controller.apiNameToAttachmentMap.get(attKey));
        }
        for (Attachment att : organizationAttachments){
            att.Name = 'TestName'+att.ParentId;
            att.Body = Blob.valueOf('body');
        }
        upsert organizationAttachments;
        ts.controller.saveFoundation();
        System.assertNotEquals(ts.controller.organization.Outstanding_Accounts_Payable__c,null);
        System.assertNotEquals(ts.controller.organization.Salary_of_the_Highest_Paid_Executive__c,null);
        System.assertNotEquals(ts.controller.organization.Pending_Litigation__c,null);
        System.assertNotEquals(ts.controller.organization.Audited_Financials_for_the_previous_thre__c,null);
        System.assertNotEquals(ts.controller.organization.Audited_Financials_for_the_previous_two__c,null);
        System.assertNotEquals(ts.controller.organization.Audited_financials_for_the_previous_year__c,null);
        System.assertNotEquals(ts.controller.organization.Form_990_for_the_previous_three_year__c,null);
        System.assertNotEquals(ts.controller.organization.Form_990_for_the_previous_two_year__c,null);
        System.assertNotEquals(ts.controller.organization.Form_990_for_the_previous_year__c,null);

        ts.controller.clearFoundation();

        System.assertEquals(ts.controller.organization.Outstanding_Accounts_Payable__c,null);
        System.assertEquals(ts.controller.organization.Salary_of_the_Highest_Paid_Executive__c,null);
        System.assertEquals(ts.controller.organization.Pending_Litigation__c,null);
        System.assertEquals(ts.controller.organization.Audited_Financials_for_the_previous_thre__c,null);
        System.assertEquals(ts.controller.organization.Audited_Financials_for_the_previous_two__c,null);
        System.assertEquals(ts.controller.organization.Audited_financials_for_the_previous_year__c,null);
        System.assertEquals(ts.controller.organization.Form_990_for_the_previous_three_year__c,null);
        System.assertEquals(ts.controller.organization.Form_990_for_the_previous_two_year__c,null);
        System.assertEquals(ts.controller.organization.Form_990_for_the_previous_year__c,null);

     }

     static testmethod void testSaveFirewall(){
        TestSettings ts = new TestSettings();
        ts.setupScientific();
        ts.setupControllerIndex0();

        PageReference gFRS_Application = ts.controller.saveFirewall();
        // Verify the success page
        System.assertEquals('/apex/GFRS_Application?id=' + ts.controller.fundReq.id, gFRS_Application.getUrl());


        ts.organization.Sister_Parent_Org_Strategic_Promo_Mktg__c = gFRS_Util.YES;

        update ts.organization;
        ts.setupControllerIndex0();

        PageReference gFRS_Error = ts.controller.saveFirewall();
        // Verify the error page
        System.assertEquals('/apex/gFRS_Error?code=' + gFRS_ErrorController.CODE_FIREWALL,gFRS_Error.getUrl());
     }

     static testmethod void testAddThirdParty(){
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ts.setupControllerIndex0();

        Test.startTest();

        GFRS_Third_Party__c thirdPartyRecord = gFRS_TestCreationUtils.createThirdParty( ts.request.id, 'John', 'Doe', 'Accme Co.', 'jdoe@accme.com', 'Janitor' );
        
        upsert thirdPartyRecord;
        
        ts.controller.getThirdPartyWrapperList();
        ts.controller.addThirdParty();
        Test.stopTest();
  
        System.assert([SELECT Id FROM GFRS_Third_Party__c WHERE Funding_Request__c = :ts.request.Id].size() == 2);

     }

     static testmethod void testValidateSave(){
        TestSettings ts = new TestSettings();
        ts.setupFellowships();

        //Validation of the gFRS_ERROR_INVALID_FUND_REQ
        /* Waiting for improvement of validateSave method (adding return isValid into if( this.fundReq == null || this.fundReq.id == null ))
        ts.setupControllerIndex0();
        ts.controller.fundReq = null;
        System.assertEquals(false,ts.controller.validateSave());
        System.assertEquals(true,ts.checkApexMessages(Label.gFRS_ERROR_INVALID_FUND_REQ));
        */

        //Validation of the gFRS_ERROR_SPECIFY_THERAPEUTIC_AREA
        ts.request.Therapeutic_Area__c = 'Other';
        update ts.request;
        ts.setupControllerIndex0();

        System.assertEquals(false,ts.controller.validateSave());
        System.assertEquals(true,ts.checkApexMessages(Label.gFRS_ERROR_SPECIFY_THERAPEUTIC_AREA));

        //Validation of the gFRS_ERROR_NON_CHARITABLE_AMOUNT
        ts.request.Non_Charitable__c = 1000;
        ts.request.Requested_Amount__c = 500;
        update ts.request;
        ts.setupControllerIndex0();

        System.assertEquals(false,ts.controller.validateSave());
        System.assertEquals(true,ts.checkApexMessages(Label.gFRS_ERROR_NON_CHARITABLE_AMOUNT));

        //Validation of the gFRS_Is_Required
        ts.request.Resubmission__c = 'Yes';
        update ts.request;
        ts.setupControllerIndex0();

        System.assertEquals(false,ts.controller.validateSave());
        System.assertEquals(true,ts.checkApexMessages(GFRS_Funding_Request__c.Resubmission_Request_Name__c.getDescribe().getInlineHelpText() + ' ' + Label.gFRS_Is_Required));

     }

     static testmethod void testGetCostCenterApprovers(){
        TestSettings ts = new TestSettings();
        ts.setupExhibits();
        ts.request.Requested_Amount__c = 1000;
        update ts.request;
        
        ts.createTwoSplits(true);
        GFRS_Funding_Allocation_Line_Item__c allocation = ts.allocationLIs[0];
        Id costCenterLookupId = ts.allocation.Id;
        GFRS_Cost_Center_Code__c costCenterCode = gFRS_UnitTestHelper.createCostCenterCode('IMED','1010');
        allocation.Cost_Center_Lookup__c = costCenterCode.Id;
        upsert allocation;
        ts.setupControllerIndex0();
        ts.controller.getCostCenterApprovers();
     }

     static testmethod void testOtherSupportersSelected(){
        TestSettings ts = new TestSettings();
        ts.setupPhilanthropic();
        ts.setupControllerIndex0();

        Test.startTest();
        ts.controller.otherSupportersSelected();
        System.assertEquals(false,ts.controller.otherSupportersRequired);

        ts.controller.otherSupporters = 'Yes';
        ts.controller.otherSupportersSelected();
        System.assertEquals(true,ts.controller.otherSupportersRequired);
        Test.stopTest();
     }

     static testmethod void testNqsSelected(){
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ts.setupControllerIndex0();

        Test.startTest();
        ts.controller.nqsSelected();
        System.assertEquals(false,ts.controller.nqsSummaryRendered);

        ts.controller.nqsCriteriaSelected = 'test';
        ts.controller.nqsSelected();
        System.assertEquals(true,ts.controller.nqsSummaryRendered);
        Test.stopTest();
     }

     static testmethod void testBarriersSelected(){
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ts.setupControllerIndex0();

        Test.startTest();
        ts.controller.barriersSelected();
        System.assertEquals(false,ts.controller.barrierSummaryRendered);

        ts.controller.barrierSelected = 'Access to equipment';
        ts.controller.barriersSelected();
        System.assertEquals(true,ts.controller.barrierSummaryRendered);
        Test.stopTest();
     }

     static testmethod void testQualityOfCareComponentsSelected(){
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ts.setupControllerIndex0();

        Test.startTest();
        ts.controller.qualityOfCareComponentsSelected();
        System.assertEquals(false,ts.controller.qualityOfCareComponentsSummaryRendered);

        ts.controller.qualityOfCareComponentSelected = 'Shared Decision making';
        ts.controller.qualityOfCareComponentsSelected();
        System.assertEquals(true,ts.controller.qualityOfCareComponentsSummaryRendered);
        Test.stopTest();
     }

     static testmethod void testResetThirdPartyOrgAccreditedToNUll(){
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ts.setupControllerIndex0();

        Test.startTest();
        ts.controller.fundReq.Is_the_Third_Party_org_accredited__c = 'Yes';
        ts.controller.fundReq.Is_the_Third_Party_org_owned_physician__c = 'Yes';
        ts.controller.resetThirdPartyOrgAccreditedToNUll();
        System.assertNotEquals(null,ts.controller.fundReq.Is_the_Third_Party_org_accredited__c);
        System.assertNotEquals(null,ts.controller.fundReq.Is_the_Third_Party_org_owned_physician__c);

        ts.controller.fundReq.Will_You_be_Working_With_a_3rd_Party__c = 'Yes';
        ts.controller.resetThirdPartyOrgAccreditedToNUll();
        System.assertEquals('',ts.controller.fundReq.Is_the_Third_Party_org_accredited__c);
        System.assertEquals('',ts.controller.fundReq.Is_the_Third_Party_org_owned_physician__c);
        Test.stopTest();
     }

     static testmethod void testGetDefaultCostCenter(){
        TestSettings ts = new TestSettings();
        ts.setupExhibits();
        ts.createTwoSplits(true);
        GFRS_Funding_Allocation_Line_Item__c allocation = ts.allocationLIs[0];
        ts.setupControllerIndex0();
        ts.controller.getDefaultCostCenter();
     }

    @IsTest
    static void testControllerProperties() {
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ts.setupControllerIndex0();

        System.assertEquals('Audited_financials_for_the_previous_year__c', ts.controller.getAUDITED_FINANCIALS_PREV_YEAR_API_NAME());
        System.assertEquals('Audited_Financials_for_the_previous_two__c', ts.controller.getAUDITED_FINANCIALS_PREV_TWO_YEARS_API_NAME());
        System.assertEquals('Audited_Financials_for_the_previous_thre__c', ts.controller.getAUDITED_FINANCIALS_PREV_THREE_YEARS_API_NAME());
        System.assertEquals('Form_990_for_the_previous_three_year__c', ts.controller.getFORM990_THREE_YEARS_API_NAME());
        System.assertEquals('Form_990_for_the_previous_two_year__c', ts.controller.getFORM990_TWO_YEARS_API_NAME());
        System.assertEquals('Form_990_for_the_previous_year__c', ts.controller.getFORM990_ONE_YEARS_API_NAME());
        System.assertEquals(3, ts.controller.simpleFieldSet.size());
    }

    @IsTest
    static void testUploadAttachment() {
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ts.setupControllerIndex0();

        ts.controller.apiName = 'Audited_Financials_for_the_previous_thre__c';
        Attachment attachment = new Attachment();
        attachment.Name = 'Test Attachment';
        attachment.Body = Blob.valueOf('Test');

        ts.controller.apiNameToAttachmentMap.put(ts.controller.apiName, attachment);
        ts.controller.uploadAttachment();

        System.assertEquals(6, ts.controller.apiNameToAttachmentMap.size());
        System.assertEquals(attachment.Name, ts.controller.apiNameToAttachmentMap.get(ts.controller.apiName).Name);
    }

    @IsTest
    static void testUploadOrganizationAttachment() {
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ts.setupControllerIndex0();

        ts.controller.apiName = 'Audited_Financials_for_the_previous_thre__c';
        Attachment attachment = new Attachment();
        attachment.Name = 'Test Attachment';
        attachment.Description = 'Description';
        attachment.Body = Blob.valueOf('Test');

        ts.controller.apiNameToAttachmentMap.put(ts.controller.apiName, attachment);
        System.debug(ts.controller.apiNameToAttachmentMap);
        ts.controller.uploadOrganizationAttachment(ts.controller.apiName, attachment.Description, true);

        System.assertEquals(6, ts.controller.apiNameToAttachmentMap.size());
        System.assertEquals(attachment.Name, ts.controller.apiNameToAttachmentMap.get(ts.controller.apiName).Name);
        System.assertEquals(attachment.Description, ts.controller.apiNameToAttachmentMap.get(ts.controller.apiName).Description);

        ts.controller.uploadOrganizationAttachment(ts.controller.apiName, attachment.Description, false);
        System.assertEquals(null, ts.controller.apiNameToAttachmentMap.get(ts.controller.apiName).Body);
    }

    @IsTest
    static void testBackFromThirdParty() {
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ts.setupControllerIndex1();

        System.assertEquals(null, ts.controller.backFromThirdParty());

        ts.controller.thirdPartyRecords = null;
        List<GFRS_Third_Party__c> thirdPartyRecords = new List<gFRS_Third_Party__c>();
        thirdPartyRecords.add(gFRS_TestCreationUtils.createThirdParty(ts.request.id, 'John', 'Doe', 'TestCompany', 'jdoe@accme.com', 'Janitor' ));
        thirdPartyRecords.add(gFRS_TestCreationUtils.createThirdParty(ts.request.id, 'Mary', 'Doe', 'TestCompany', 'mdoe@accme.com', 'Janitor' ));
        insert thirdPartyRecords;
        ts.controller.getThirdPartyWrapperList();

        ts.controller.currentIndex = 1;
        ts.controller.backFromThirdParty();
        System.assert(ts.controller.backFromThirdParty().getUrl().contains(ts.controller.fundReq.Id));
        System.assert(ts.controller.backFromThirdParty().getUrl().contains('ci=0'));
    }

    @IsTest
    static void testValidateAndSaveThirdPartyField() {
        TestSettings ts = new TestSettings();
        ts.setupIMED();
        ts.setupControllerIndex1();

        ts.controller.thirdPartyRecords = null;
        List<GFRS_Third_Party__c> thirdPartyRecords = new List<gFRS_Third_Party__c>();
        thirdPartyRecords.add(gFRS_TestCreationUtils.createThirdParty(ts.request.id, 'John', 'Doe', 'TestCompany', 'jdoe.accme.com', 'Janitor' ));
        thirdPartyRecords.add(gFRS_TestCreationUtils.createThirdParty(ts.request.id, 'Mary', 'Doe', 'TestCompany', 'mdoe.accme.com', 'Janitor' ));
        insert thirdPartyRecords;
        ts.controller.getThirdPartyWrapperList();
        ts.controller.thirdPartyToSave = 1;
        ts.controller.thirdPartyField = 'Third_Party_Contact_Email__c';

        ts.controller.validateAndSaveThirdPartyField();
        System.assert(ts.checkApexMessages('Contact Email is incorrect'));

        ts.controller.thirdPartyToDelete = 1;
        ts.controller.deleteThirdPartyRow();
        System.assertEquals(1, ts.controller.thirdPartyRecordsWrapperList.size());
    }
}