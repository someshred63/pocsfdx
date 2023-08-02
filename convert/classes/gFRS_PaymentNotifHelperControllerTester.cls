/**
* @author ADMD Team
* @date 02/01/2014
* @description gFRS_PaymentNotifHelperControllerTester class - testing gFRS_PaymentNotifHelperController class reponsible for displaying proper content in gFRS_PaymentNotificationHelper component 
   component  
*
*/

@isTest 
private with sharing class gFRS_PaymentNotifHelperControllerTester {
    
    /**
    * @author: GFRS Dev Team
    * @date: 28/05/2014
    * @description: checkIfContentSetProperlyForIMEDForWBS134 Test method which is checkinf if correct content to display was selected for IMED with WSB 134.09042. 
    */
    @isTest(SeeAllData=true)
    static  void checkIfContentSetProperlyForIMEDForWBS134(){
        //gFRS_UnitTestHelper.setGfrsCustomSettings(false);
        GFRS_OrgSettings__c myOrgCS = GFRS_OrgSettings__c.getOrgDefaults();
        
        Account account = gFRS_UnitTestHelper.createAccount('Test Account Name');
        Contact testContact = gFRS_UnitTestHelper.createContact(account.Id);
        User testUser = gFRS_UnitTestHelper.createPortalUser(testContact);
        Id organizationId = gFRS_UnitTestHelper.createOrganization('87-9999999', account.Id).Id;
        Id localizationId = gFRS_UnitTestHelper.createLocation('Vendor Name', organizationId).Id;
        
        Date startDate = Date.today().addYears(1);
        Date stopDate = Date.today().addYears(2);
        
        GFRS_Cost_Center_Code__c costCenter = gFRS_UnitTestHelper.createCostCenterCode('testName', '1010');
        
        GFRS_WBS_Codes__c wbsCode = gFRS_UnitTestHelper.createWBSCodeWithoutSaving(myOrgCS.AckGenAstSupportedProgramIMEDWbsCode__c, true, 'Autism', 20, 'IMED', '1010', Date.today()+1, 'Biogen-Idec', myOrgCS.AckGenAstSupportedProgramIMEDWbsCode__c, '1010 Description');

        insert wbsCode;
        
        GFRS_Funding_Request__c request = gFRS_UnitTestIMEDHelper.createIMEDFundingRequestApplicationStep(organizationId, localizationId);
        GFRS_Funding_Allocation__c fundingAllocation = gFRS_UnitTestHelper.createFundingAllocationWithoutSaving(gFRS_UnitTestHelper.ID_FUNDING_ALLOCATION_PAYMENT_RECTYPE, request, 'Genentech');
        fundingAllocation.Refund_Amount__c = 20;
        insert fundingAllocation;
        
        GFRS_Funding_Allocation_Line_Item__c fundingAllocationLineItem =gFRS_UnitTestHelper.createFundingAllocationLineItem(testUser, costCenter, fundingAllocation, wbsCode);
        
        Test.startTest();
        gFRS_PaymentNotifHelperController emCont=new gFRS_PaymentNotifHelperController();
        emCont.fundIdController=request.id;
        emCont.fundTypeController='IMED';
        String contentId=emCont.getProperContentId();
        System.assertEquals(contentId,'1','Content for IMED with wbs '+myOrgCS.AckGenAstSupportedProgramIMEDWbsCode__c+' should be different than stnadard in Payment notification Email');
        Test.stopTest();
        
    }
    
    /**
    * @author: GFRS Dev Team
    * @date: 28/05/2014
    * @description: checkIfContentSetProperlyForIMEDForWBS134 Test method which is checkinf if correct content to display was selected for IMED with WSB different than  134.09042. 
    */
    @isTest(SeeAllData=true)
    static  void checkIfContentSetProperlyForIMEDForWBSDiffThan134(){
        GFRS_OrgSettings__c myOrgCS = GFRS_OrgSettings__c.getOrgDefaults();
        
        Account account = gFRS_UnitTestHelper.createAccount('Test Account Name');
        Contact testContact = gFRS_UnitTestHelper.createContact(account.Id);
        User testUser = gFRS_UnitTestHelper.createPortalUser(testContact);
        Id organizationId = gFRS_UnitTestHelper.createOrganization('87-9999999', account.Id).Id;
        Id localizationId = gFRS_UnitTestHelper.createLocation('Vendor Name', organizationId).Id;
        
        Date startDate = Date.today().addYears(1);
        Date stopDate = Date.today().addYears(2);
        
        GFRS_Cost_Center_Code__c costCenter = gFRS_UnitTestHelper.createCostCenterCode('testName', '1010');
        
        GFRS_WBS_Codes__c wbsCode = gFRS_UnitTestHelper.createWBSCodeWithoutSaving('999.99999', true, 'Autism', 20, 'IMED', '1010', Date.today()+1, 'Biogen-Idec', '999.99999', '1010 Description');

        insert wbsCode;
        
        GFRS_Funding_Request__c request = gFRS_UnitTestIMEDHelper.createIMEDFundingRequestApplicationStep(organizationId, localizationId);
        GFRS_Funding_Allocation__c fundingAllocation = gFRS_UnitTestHelper.createFundingAllocationWithoutSaving(gFRS_UnitTestHelper.ID_FUNDING_ALLOCATION_PAYMENT_RECTYPE, request, 'Genentech');
        fundingAllocation.Refund_Amount__c = 20;
        insert fundingAllocation;
        
        GFRS_Funding_Allocation_Line_Item__c fundingAllocationLineItem =gFRS_UnitTestHelper.createFundingAllocationLineItem(testUser, costCenter, fundingAllocation, wbsCode);
        
        Test.startTest();
        gFRS_PaymentNotifHelperController emCont=new gFRS_PaymentNotifHelperController();
        emCont.fundIdController=request.id;
        emCont.fundTypeController='IMED';
        String contentId=emCont.getProperContentId();
        System.assertEquals(contentId,'0','Content for IMED with wbs different than  '+myOrgCS.AckGenAstSupportedProgramIMEDWbsCode__c+' should be  stnadard in Payment notification Email');
        Test.stopTest();
    }
    
    
    /**
    * @author: GFRS Dev Team
    * @date: 28/05/2014
    * @description: checkIfContentSetProperlyForCHCHarLungCancer Test method which is checkinf if correct content to display was selected for HC HCAR with TA Lung Cancer. 
    */
    @isTest(SeeAllData=true)
    static  void checkIfContentSetProperlyForCHCHarLungCancer(){
        //gFRS_UnitTestHelper.setGfrsCustomSettings(false);
        
        Account account = gFRS_UnitTestHelper.createAccount('Test Account Name');
        Contact testContact = gFRS_UnitTestHelper.createContact(account.Id);
        User testUser = gFRS_UnitTestHelper.createPortalUser(testContact);
        Id organizationId = gFRS_UnitTestHelper.createOrganization('87-9999999', account.Id).Id;
        Id localizationId = gFRS_UnitTestHelper.createLocation('Vendor Name', organizationId).Id;
        
        Date startDate = Date.today().addYears(1);
        Date stopDate = Date.today().addYears(2);
        
                
        Id requestID = gFRS_UnitTestHelperHcChar.CreateHcCharRequestInStatusNewAndProperTA(organizationId,localizationId,testUser,'Oncology','Lung Cancer');
        Test.startTest();
        gFRS_PaymentNotifHelperController emCont=new gFRS_PaymentNotifHelperController();
        emCont.fundIdController=requestID;
        emCont.fundTypeController='HC CHAR';
        String contentId=emCont.getProperContentId();
        System.assertEquals(contentId,'2','Content for HC HCAR with TA Lung Cancer should be different');
        Test.stopTest();
    }
    
    /**
    * @author: GFRS Dev Team
    * @date: 28/05/2014
    * @description: checkIfContentSetProperlyForCHCHarMelanoma Test method which is checkinf if correct content to display was selected for HC HCAR with TA Melanoma. 
    */
     @isTest(SeeAllData=true)
    static  void checkIfContentSetProperlyForCHCHarMelanoma(){
        //gFRS_UnitTestHelper.setGfrsCustomSettings(false);
        
        Account account = gFRS_UnitTestHelper.createAccount('Test Account Name');
        Contact testContact = gFRS_UnitTestHelper.createContact(account.Id);
        User testUser = gFRS_UnitTestHelper.createPortalUser(testContact);
        Id organizationId = gFRS_UnitTestHelper.createOrganization('87-9999999', account.Id).Id;
        Id localizationId = gFRS_UnitTestHelper.createLocation('Vendor Name', organizationId).Id;
        
        Date startDate = Date.today().addYears(1);
        Date stopDate = Date.today().addYears(2);
        
                
        Id requestID = gFRS_UnitTestHelperHcChar.CreateHcCharRequestInStatusNewAndProperTA(organizationId,localizationId,testUser,'Oncology','Melanoma');
        Test.startTest();
        gFRS_PaymentNotifHelperController emCont=new gFRS_PaymentNotifHelperController();
        emCont.fundIdController=requestID;
        emCont.fundTypeController='HC CHAR';
        String contentId=emCont.getProperContentId();
        System.assertEquals(contentId,'3','Content for HC HCAR with TA Melanoma should be different');
        Test.stopTest();
    }
    
    /**
    * @author: GFRS Dev Team
    * @date: 28/05/2014
    * @description: checkIfContentSetProperlyForCHCHarAllergicAsthma Test method which is checkinf if correct content to display was selected for HC HCAR with TA Melanoma. 
    */
     @isTest(SeeAllData=true)
    static  void checkIfContentSetProperlyForCHCHarAllergicAsthma(){
        //gFRS_UnitTestHelper.setGfrsCustomSettings(false);
        
        Account account = gFRS_UnitTestHelper.createAccount('Test Account Name');
        Contact testContact = gFRS_UnitTestHelper.createContact(account.Id);
        User testUser = gFRS_UnitTestHelper.createPortalUser(testContact);
        Id organizationId = gFRS_UnitTestHelper.createOrganization('87-9999999', account.Id).Id;
        Id localizationId = gFRS_UnitTestHelper.createLocation('Vendor Name', organizationId).Id;
        
        Date startDate = Date.today().addYears(1);
        Date stopDate = Date.today().addYears(2);
        
                
        Id requestID = gFRS_UnitTestHelperHcChar.CreateHcCharRequestInStatusNewAndProperTA(organizationId,localizationId,testUser,' Immunology','Allergic Asthma');
        Test.startTest();
        gFRS_PaymentNotifHelperController emCont=new gFRS_PaymentNotifHelperController();
        emCont.fundIdController=requestID;
        emCont.fundTypeController='HC CHAR';
        String contentId=emCont.getProperContentId();
        System.assertEquals(contentId,'4','Content for HC HCAR with TA AllergicAsthma should be different');
        Test.stopTest();
    }
    
    /**
    * @author: GFRS Dev Team
    * @date: 28/05/2014
    * @description: checkIfContentSetProperlyForCHCHarNotAstellas Test method which is checking if default content selected for  HC HCAR with where  TA different than  Lung Cancer, Pancreatic Cancer,Melanoma,Allergic Asthma . 
    */
     @isTest(SeeAllData=true)
    static  void checkIfContentSetProperlyForCHCHarNotAstellas(){
        //gFRS_UnitTestHelper.setGfrsCustomSettings(false);
        
        Account account = gFRS_UnitTestHelper.createAccount('Test Account Name');
        Contact testContact = gFRS_UnitTestHelper.createContact(account.Id);
        User testUser = gFRS_UnitTestHelper.createPortalUser(testContact);
        Id organizationId = gFRS_UnitTestHelper.createOrganization('87-9999999', account.Id).Id;
        Id localizationId = gFRS_UnitTestHelper.createLocation('Vendor Name', organizationId).Id;
        
        Date startDate = Date.today().addYears(1);
        Date stopDate = Date.today().addYears(2);
        
                
        Id requestID = gFRS_UnitTestHelperHcChar.CreateHcCharRequestInStatusNewAndProperTA(organizationId,localizationId,testUser,' Immunology','Fibromyalgia');
        Test.startTest();
        gFRS_PaymentNotifHelperController emCont=new gFRS_PaymentNotifHelperController();
        emCont.fundIdController=requestID;
        emCont.fundTypeController='HC CHAR';
        String contentId=emCont.getProperContentId();
        System.assertEquals(contentId,'0','Content for HC HCAR with TA different than Lung Cancer, Pancreatic Cancer,Melanoma,Allergic Asthma should be default');
        Test.stopTest();
    }

}