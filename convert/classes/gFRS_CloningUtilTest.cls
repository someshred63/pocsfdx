/**
* @author GFRS Dev Team
* @date 03/12/2014
* @description gFRS_CloningUtilTest class - test class for gFRS_CloningUtil
*/
@isTest(SeeAllData=true)
private class gFRS_CloningUtilTest {


    static testmethod void testCustomCloneWithInsert(){
        
        TestSettings ts = new TestSettings();
        ts.setupExhibits();
        ts.createUser();
        
        
        Test.startTest();
        
            GFRS_Funding_Request__c result = gFRS_CloningUtil.customCloneWithInsert(ts.request, ts.user.Id, gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME, ts.organization.Id, ts.location.Id);
            
            GFRS_Program__c resultProgram = [SELECT Id FROM GFRS_Program__c WHERE Funding_Request__c =: result.Id];
            
            GFRS_Funding_Allocation__c resultFundingAllocation = [SELECT Id FROM GFRS_Funding_Allocation__c WHERE Grant_Request__c =: result.id].get(0);
            
            GFRS_Funding_Allocation_Line_Item__c resultFundingAllocationLineItem = [ SELECT Id,Funding_Allocation__c FROM GFRS_Funding_Allocation_Line_Item__c 
                WHERE Funding_Allocation__c =:resultFundingAllocation.Id ];
            
            System.assert(result != null);
            
            System.assert(result.Status__c == gFRS_Util.REQUEST_DEFAULT_STATUS);
            System.assert(result.Sub_Status__c == gFRS_Util.REQUEST_DEFAULT_SUB_STATUS);
            System.assert(result.External_Sub_status__c == gFRS_Util.REQUEST_DEFAULT_SUB_STATUS);
            
            System.debug('Information needed' + result.Information_Needed__c);
            System.assert(result.Information_Needed__c == gFRS_Util.INFO_NEEDED_BUDGET + ';' 
                + gFRS_Util.INFO_NEEDED_LOCATION + ';'
                + gFRS_Util.INFO_NEEDED_APPLICATION + ';'
                + gFRS_Util.INFO_NEEDED_FILE_ATTACHMENTS + ';'
                + gFRS_Util.INFO_NEEDED_PROGRAM + ';'
                + gFRS_Util.INFO_NEEDED_THIRD_PARTY + ';'
                + gFRS_Util.INFO_NEEDED_PROGRAM_DESIGN);
            
            System.assert(result.Organization__c == ts.organization.Id);
            System.assert(result.Location__c == ts.location.Id);
            System.assert(result.Funding_Sub_Type__c == ts.request.Funding_Sub_Type__c);
            
            
            System.assert(resultProgram != null);
            System.assert(resultFundingAllocation != null);
            System.assert(resultFundingAllocationLineItem != null);

        Test.stopTest();
    }
    
     class TestSettings {
        public Account account;
        public GFRS_Organization__c organization;
        public GFRS_Location__c location;
        public GFRS_Funding_Request__c request;
        public GFRS_Program__c programs;
        public String PROF_GFRS_USER_NAME = 'GNE-GFRS-User';
        public Id PROF_GFRS_USER;
        User user;
        
        public TestSettings(){
            this.account = gFRS_TestCreationUtils.createAccount( gFRS_TestCreationUtils.makeUnique( 'acct' ));
            insert this.account;
            
            this.organization = gFRS_TestCreationUtils.createOrganization2( '20110101', this.account.id );
            insert this.organization;
            
            this.location = gFRS_TestCreationUtils.createLocation( 'SomeLocation', this.organization.id );
            insert this.location;
            
            gFRS_UnitTestHelper.setGfrsCustomSettings(true);
        }
        
        public void createUser(){
            PROF_GFRS_USER = [ select Id, Name, Type from Profile where Name =:PROF_GFRS_USER_NAME limit 1 ].Id;
            user = gFRS_TestCreationUtils.createUser3('Test', 'test', 'aaa@gene.com', PROF_GFRS_USER, '1234');
            insert user;
        }
        
        public void setupExhibits(){
            this.request = gFRS_TestCreationUtils.createFundingRequest2( gFRS_TestCreationUtils.RT_FR_EXHIBITS_OTHER_PROMOS, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id);
            this.request.Funding_Sub_Type__c = 'Exhibit Booth';
            insert this.request;
            this.request = [select Id, Name, Status__c, Status_Last_Modified_Date__c, Funding_Sub_Type__c from GFRS_Funding_Request__c where Id= : this.request.Id];
        }

        public void createContentTranslation(){
        	GFRS_Content__c item =new GFRS_Content__c();
     		item.Filter__c='Google Calendar';
     		item.name='Gcal_Header';
      		insert item;

      		GFRS_Content_Translation__c itemTranslation=new GFRS_Content_Translation__c();
     		itemTranslation.GFRS_Content__c=item.id;
     		itemTranslation.Language__c='en_US';
     		itemTranslation.TextBlock__c='The inclusion of an event in this calendar does not guarantee that the event is appropriate to exhibit and/or attend. Benefits received in conjunction with a charitable grant cannot be used for promotional purposes. If interested in attending an event for business purposes, please obtain your manager’s approval. For business attendance at patient education programs, you are required to obtain advance approval from Advocacy Relations (infoadvocacyrelations-d@gene.com). If interested in exhibiting, you are required to obtain advance approval from Advocacy Relations (infoadvocacyrelations-d@gene.com). In addition, all exhibits must be requested and approved in gFRS in advance of a program and are subject to compliance and business review. To submit your request in gFRS, visit gwiz.gene.com/gFRS. Please contact your manager if you have any questions.';
			insert itemTranslation;
        }

        
     }
}