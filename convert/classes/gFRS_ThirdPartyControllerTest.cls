/**
* @author GFRS Dev Team
* @date 08/02/2015    
* @description gFRS_ThirdPartyControllerTest class - test class for gFRS_ThirdParty page.
*/

@isTest
public class gFRS_ThirdPartyControllerTest {
    
    /**
    * @author GFRS Dev Team
    * @date 08/02/2015    
    * @description testController test method - testinig initialization of controller constructor
    */
    public static testMethod void  testController(){
        Account account = gFRS_UnitTestHelper.createAccount('Test Account Name');
        Contact testContact = gFRS_UnitTestHelper.createContact(account.Id);
        User testUser = gFRS_UnitTestHelper.createPortalUser(testContact);
        Id organizationId = gFRS_UnitTestHelper.createOrganization('87-9999999', account.Id).Id;
        Id localizationId = gFRS_UnitTestHelper.createLocation('Vendor Name', organizationId).Id;
        
        Date startDate = Date.today().addYears(1);
        Date stopDate = Date.today().addYears(2);
        
        GFRS_Funding_Request__c req = gFRS_UnitTestIMEDHelper.createIMEDFundingRequestApplicationStep(organizationId, localizationId);
        req.Will_You_be_Working_With_a_3rd_Party__c='Yes';
        update req;
        PageReference pRef = Page.gFRS_ThirdParty;
        pRef.getParameters().put('id',req.id);
        Test.setCurrentPage(pRef);
        Test.startTest();
            gFRS_ThirdPartyController cont = new gFRS_ThirdPartyController(new ApexPages.StandardController(req));
            gFRS_Third_Party__c t =new gFRS_Third_Party__c();
            
            // at least one third party should be created
            System.assertEquals(true, cont.requestThirdParties.size() >0);
            cont.saveThirdParties();
            //check if validation messages are displayed
            system.assertEquals(true, ApexPages.hasMessages());
            //check email validation
            cont.requestThirdParties.get(0).Third_Party_Contact_Email__c = 'wrongTestEmail';
            cont.addThirdParty();
            system.assertEquals(true, ApexPages.hasMessages());
        Test.stopTest();    
    }
    
    /**
    * @author GFRS Dev Team
    * @date 08/02/2015    
    * @description testController test method - testinig dml operation 
    */
    public static testMethod void  testSavingThirdParty(){
        Account account = gFRS_UnitTestHelper.createAccount('Test Account Name');
        Contact testContact = gFRS_UnitTestHelper.createContact(account.Id);
        User testUser = gFRS_UnitTestHelper.createPortalUser(testContact);
        Id organizationId = gFRS_UnitTestHelper.createOrganization('87-9999999', account.Id).Id;
        Id localizationId = gFRS_UnitTestHelper.createLocation('Vendor Name', organizationId).Id;
        
        Date startDate = Date.today().addYears(1);
        Date stopDate = Date.today().addYears(2);
        
        GFRS_Funding_Request__c req = gFRS_UnitTestIMEDHelper.createIMEDFundingRequestApplicationStep(organizationId, localizationId);
        req.Will_You_be_Working_With_a_3rd_Party__c='Yes';
        update req;
        PageReference pRef = Page.gFRS_ThirdParty;
        pRef.getParameters().put('id',req.id);
        Test.setCurrentPage(pRef);
        Test.startTest();
            gFRS_ThirdPartyController cont = new gFRS_ThirdPartyController(new ApexPages.StandardController(req));
            gFRS_Third_Party__c t =new gFRS_Third_Party__c();
            
                
            // at least one third party should be created
            System.assertEquals(true, cont.requestThirdParties.size() >0);
            cont.requestThirdParties.get(0).Company_Name__c='Test';
            cont.requestThirdParties.get(0).Is_Third_Party_org_owned_by_physicians__c='Yes';
        	cont.requestThirdParties.get(0).Is_the_Third_Party_org_accredited__c='Yes';
            cont.requestThirdParties.get(0).Third_Party_Company_Function__c='Accreditation';
            cont.requestThirdParties.get(0).Third_Party_Contact_Email__c='test@test.pl';
            cont.requestThirdParties.get(0).Third_Party_Contact_First_Name__c='Test First Name';
            cont.requestThirdParties.get(0).Third_Party_Contact_Last_Name__c='Test Last Name';
            cont.saveThirdParties();
            //check if validation messages are displayed
            system.assertEquals(false, ApexPages.hasMessages());
            //check email validation
            cont.addThirdParty();
            system.assertEquals(false, ApexPages.hasMessages());
        	System.assertEquals(true, cont.requestThirdParties.size() >1);
            cont.removeThirdParty();
            System.assertEquals(true, cont.requestThirdParties.size() == 1);
            PageReference pRefBack= cont.back();
            //System.assertEquals(Page.GFRS_Application, pRefBack);
        Test.stopTest();    
    }


}