@isTest
private class gFRS_CompilanceControllerTest {
    public class TestSettings{
        GFRS_OrgSettings__c customSettings = GFRS_OrgSettings__c.getOrgDefaults();
        
        public TestSettings(){
            if (customSettings.gFRS_Legal_Reviewer_Fields_Required__c){
                customSettings.gFRS_Legal_Reviewer_Fields_Required__c = false;
                upsert customSettings GFRS_OrgSettings__c.Id;
            }            
            GFRS_Content__c content = new GFRS_Content__c(Name='Gcal_Header',Filter__c='Test_Gcal_Header'); 
            insert content;
            GFRS_Content_Translation__c translation = new GFRS_Content_Translation__c(GFRS_Content__c = content.Id, TextBlock__c = 'testTranslation', Language__c ='en_US');
            insert translation;
        }
        GFRS_Funding_Request__c createIMEDReqest(){
            Account account = gFRS_UnitTestHelper.createAccount('Test Account Name');
            Contact testContact = gFRS_UnitTestHelper.createContact(account.Id);
            User testUser = gFRS_UnitTestHelper.createPortalUser(testContact);
            Id organizationId = gFRS_UnitTestHelper.createOrganization('87-9999999', account.Id).Id;
            Id localizationId = gFRS_UnitTestHelper.createLocation('Vendor Name', organizationId).Id;
            
            Date startDate = Date.today().addYears(1);
            Date stopDate = Date.today().addYears(2);
            
            return gFRS_UnitTestIMEDHelper.createIMEDFundingRequestApplicationStep(organizationId, localizationId);
        }
        
        GFRS_Funding_Request__c createChCHarReqest(){
            Account account = gFRS_UnitTestHelper.createAccount('Test Account Name');
            Contact testContact = gFRS_UnitTestHelper.createContact(account.Id);
            User testUser = gFRS_UnitTestHelper.createPortalUser(testContact);
            Id organizationId = gFRS_UnitTestHelper.createOrganization('87-9999999', account.Id).Id;
            Id localizationId = gFRS_UnitTestHelper.createLocation('Vendor Name', organizationId).Id;
            
            Date startDate = Date.today().addYears(1);
            Date stopDate = Date.today().addYears(2);
            
            GFRS_Funding_Request__c req=[select id,name from GFRS_Funding_Request__c where id =:gFRS_UnitTestHelperHcChar.CreateHcCharRequestInStatusNew(organizationId, localizationId, testUser)];
            return req;
        }
        
        GFRS_Funding_Request__c createPhilantropicReqest(){
            Account account = gFRS_UnitTestHelper.createAccount('Test Account Name');
            Contact testContact = gFRS_UnitTestHelper.createContact(account.Id);
            User testUser = gFRS_UnitTestHelper.createPortalUser(testContact);
            Id organizationId = gFRS_UnitTestHelper.createOrganization('87-9999999', account.Id).Id;
            Id localizationId = gFRS_UnitTestHelper.createLocation('Vendor Name', organizationId).Id;
            
            Date startDate = Date.today().addYears(1);
            Date stopDate = Date.today().addYears(2);
            
            GFRS_Funding_Request__c req=[select id,name from GFRS_Funding_Request__c where id =:gFRS_UnitTestHelperPhilanthropic.CreatePhilanthropicRequestInStatusNew(organizationId, localizationId, testUser)];
            return req;
        }
        
        GFRS_Funding_Request__c createFellowShipReqest(){
            Account account = gFRS_UnitTestHelper.createAccount('Test Account Name');
            Contact testContact = gFRS_UnitTestHelper.createContact(account.Id);
            User testUser = gFRS_UnitTestHelper.createPortalUser(testContact);
            Id organizationId = gFRS_UnitTestHelper.createOrganization('87-9999999', account.Id).Id;
            Id localizationId = gFRS_UnitTestHelper.createLocation('Vendor Name', organizationId).Id;
            
            Date startDate = Date.today().addYears(1);
            Date stopDate = Date.today().addYears(2);
            
            GFRS_Funding_Request__c req=[select id,name from GFRS_Funding_Request__c where id =:gFRS_UnitTestHelperFellowship.CreateFellowshipRequestInStatusNew(organizationId, localizationId, testUser)];
            return req;
        }
        
        GFRS_Funding_Request__c createExhibitAnsOtherPromoReqest(){
            Account account = gFRS_UnitTestHelper.createAccount('Test Account Name');
            Contact testContact = gFRS_UnitTestHelper.createContact(account.Id);
            User testUser = gFRS_UnitTestHelper.createPortalUser(testContact);
            Id organizationId = gFRS_UnitTestHelper.createOrganization('87-9999999', account.Id).Id;
            Id localizationId = gFRS_UnitTestHelper.createLocation('Vendor Name', organizationId).Id;
            
            Date startDate = Date.today().addYears(1);
            Date stopDate = Date.today().addYears(2);
            
            return gFRS_UnitTestHelperExhibitsOtherPromo.createExhibitOtherPromosDecisionStep(organizationId, localizationId, testUser);
            
        }
        
        GFRS_Funding_Request__c createScinetficPipelinReqest(){
            Account account = gFRS_UnitTestHelper.createAccount('Test Account Name');
            Contact testContact = gFRS_UnitTestHelper.createContact(account.Id);
            User testUser = gFRS_UnitTestHelper.createPortalUser(testContact);
            Id organizationId = gFRS_UnitTestHelper.createOrganization('87-9999999', account.Id).Id;
            Id localizationId = gFRS_UnitTestHelper.createLocation('Vendor Name', organizationId).Id;
            
            Date startDate = Date.today().addYears(1);
            Date stopDate = Date.today().addYears(2);
            GFRS_Funding_Request__c  req =gFRS_UnitTestHelperExhibitsOtherPromo.createExhibitOtherPromosDecisionStep(organizationId, localizationId, testUser);
            req.recordTypeId= [select id from RecordType where SobjectType = 'GFRS_Funding_Request__c' and DeveloperName='Sci_Pipeline_Exhibits_Other_Non_Promo'].id;
            update req;
            return req;
            
        }
        
        GFRS_Funding_Request__c createFIEReqest(){
            Account account = gFRS_UnitTestHelper.createAccount('Test Account Name');
            Contact testContact = gFRS_UnitTestHelper.createContact(account.Id);
            User testUser = gFRS_UnitTestHelper.createPortalUser(testContact);
            Id organizationId = gFRS_UnitTestHelper.createOrganization('87-9999999', account.Id).Id;
            Id localizationId = gFRS_UnitTestHelper.createLocation('Vendor Name', organizationId).Id;
            
            Date startDate = Date.today().addYears(1);
            Date stopDate = Date.today().addYears(2);
            GFRS_Funding_Request__c  req =gFRS_UnitTestHelperExhibitsOtherPromo.createExhibitOtherPromosDecisionStep(organizationId, localizationId, testUser);
            req.recordTypeId= [select id from RecordType where SobjectType = 'GFRS_Funding_Request__c' and DeveloperName='Field_Initiated_Exhibits'].id;
            update req;
            return req;
            
        }
        
        GFRS_Funding_Request__c createCorporateMembershipReqest(){
            Account account = gFRS_UnitTestHelper.createAccount('Test Account Name');
            Contact testContact = gFRS_UnitTestHelper.createContact(account.Id);
            User testUser = gFRS_UnitTestHelper.createPortalUser(testContact);
            Id organizationId = gFRS_UnitTestHelper.createOrganization('87-9999999', account.Id).Id;
            Id localizationId = gFRS_UnitTestHelper.createLocation('Vendor Name', organizationId).Id;
            
            Date startDate = Date.today().addYears(1);
            Date stopDate = Date.today().addYears(2);
            
            GFRS_Funding_Request__c req=[select id,name from GFRS_Funding_Request__c where id =:gFRS_UnitTestHelperCorporateMembership.CreateCorpMemberRequestInStatusNew(organizationId, localizationId, testUser)];
            return req;
            
        }
        
        GFRS_Funding_Request__c createScientificProReqest(){
            Account account = gFRS_UnitTestHelper.createAccount('Test Account Name');
            Contact testContact = gFRS_UnitTestHelper.createContact(account.Id);
            User testUser = gFRS_UnitTestHelper.createPortalUser(testContact);
            Id organizationId = gFRS_UnitTestHelper.createOrganization('87-9999999', account.Id).Id;
            Id localizationId = gFRS_UnitTestHelper.createLocation('Vendor Name', organizationId).Id;
            
            Date startDate = Date.today().addYears(1);
            Date stopDate = Date.today().addYears(2);
            GFRS_Funding_Request__c  req =gFRS_UnitTestHelperExhibitsOtherPromo.createExhibitOtherPromosDecisionStep(organizationId, localizationId, testUser);
            req.recordTypeId= [select id from RecordType where SobjectType = 'GFRS_Funding_Request__c' and DeveloperName='Scientific_Projects'].id;
            update req;
            return req;
            
        }
    }
    static testMethod void checkComplianceForImed(){
        TestSettings helper=new TestSettings();
        
        ApexPages.StandardController std=new ApexPages.StandardController(helper.createIMEDReqest());
        gFRS_CompilanceController compianceCont=new gFRS_CompilanceController(std);
    }
    
    static testMethod void checkComplianceForHcHar(){
        TestSettings helper=new TestSettings();
        
        ApexPages.StandardController std=new ApexPages.StandardController(helper.createChCHarReqest());
        gFRS_CompilanceController compianceCont=new gFRS_CompilanceController(std);
        System.assertEquals(11,compianceCont.ComplianceFlags.size());

        helper.customSettings.gFRS_Legal_Reviewer_Fields_Required__c = true;
        upsert helper.customSettings;        
        compianceCont = new gFRS_CompilanceController(new ApexPages.StandardController(compianceCont.fundReq));
        System.assertEquals(12,compianceCont.ComplianceFlags.size());
    }
    
    static testMethod void checkComplianceForPhilantropic(){
        TestSettings helper=new TestSettings();
        
        ApexPages.StandardController std=new ApexPages.StandardController(helper.createPhilantropicReqest());
        gFRS_CompilanceController compianceCont=new gFRS_CompilanceController(std);
        System.assertEquals(10,compianceCont.ComplianceFlags.size());

        helper.customSettings.gFRS_Legal_Reviewer_Fields_Required__c = true;
        upsert helper.customSettings;        
        compianceCont = new gFRS_CompilanceController(new ApexPages.StandardController(compianceCont.fundReq));
        System.assertEquals(11,compianceCont.ComplianceFlags.size());
    }
    
    static testMethod void checkComplianceForFellowShip(){
        TestSettings helper=new TestSettings();
        
        ApexPages.StandardController std=new ApexPages.StandardController(helper.createFellowShipReqest());
        gFRS_CompilanceController compianceCont=new gFRS_CompilanceController(std);
    }
    
    static testMethod void checkComplianceForExhibitsOtherPromo(){
        TestSettings helper=new TestSettings();
        
        ApexPages.StandardController std=new ApexPages.StandardController(helper.createExhibitAnsOtherPromoReqest());
        gFRS_CompilanceController compianceCont=new gFRS_CompilanceController(std);
    }
    
    static testMethod void checkComplianceForCorporateMembership(){
        TestSettings helper=new TestSettings();
        
        ApexPages.StandardController std=new ApexPages.StandardController(helper.createCorporateMembershipReqest());
        gFRS_CompilanceController compianceCont=new gFRS_CompilanceController(std);
        System.assertEquals(8,compianceCont.ComplianceFlags.size());

        helper.customSettings.gFRS_Legal_Reviewer_Fields_Required__c = true;
        upsert helper.customSettings;        
        compianceCont = new gFRS_CompilanceController(new ApexPages.StandardController(compianceCont.fundReq));
        System.assertEquals(9,compianceCont.ComplianceFlags.size());
    }
    
    static testMethod void checkComplianceForScientificPipeline(){
        TestSettings helper=new TestSettings();
        
        ApexPages.StandardController std=new ApexPages.StandardController(helper.createScinetficPipelinReqest());
        gFRS_CompilanceController compianceCont=new gFRS_CompilanceController(std);
        System.assertEquals(7,compianceCont.ComplianceFlags.size());

        helper.customSettings.gFRS_Legal_Reviewer_Fields_Required__c = true;
        upsert helper.customSettings;        
        compianceCont = new gFRS_CompilanceController(new ApexPages.StandardController(compianceCont.fundReq));
        System.assertEquals(8,compianceCont.ComplianceFlags.size());
    }
    
    static testMethod void checkComplianceForFIE(){
        TestSettings helper=new TestSettings();
        
        ApexPages.StandardController std=new ApexPages.StandardController(helper.createFIEReqest());
        gFRS_CompilanceController compianceCont=new gFRS_CompilanceController(std);
    }
    
    static testMethod void checkComplianceForScientificProject(){
        TestSettings helper=new TestSettings();
        
        ApexPages.StandardController std=new ApexPages.StandardController(helper.createScientificProReqest());
        gFRS_CompilanceController compianceCont=new gFRS_CompilanceController(std);
    }
    
    static testMethod void checkComplianceHandleError(){
        TestSettings helper=new TestSettings();
        GFRS_Funding_Request__c req=new GFRS_Funding_Request__c();
        ApexPages.StandardController std=new ApexPages.StandardController(req);
        gFRS_CompilanceController compianceCont=new gFRS_CompilanceController(std);
    }
}