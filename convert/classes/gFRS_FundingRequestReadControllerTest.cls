@isTest
public class gFRS_FundingRequestReadControllerTest {
	public class TestSettings{
        public Account account{get;set;}
        public Contact testContact{get;set;}
        public User testUser{get;set;}
        public TestSettings(){
            Account testAccount = gFRS_UnitTestHelper.createAccount('TestAccount');
            Contact testContact = gFRS_UnitTestHelper.createContact(testAccount.Id);
            User testUser = gFRS_UnitTestHelper.createPortalUser(testContact);
            GFRS_Organization__c testOrganization = gFRS_UnitTestHelper.createOrganization('99-9999999', testAccount.Id);
            GFRS_Location__c testLocation = gFRS_UnitTestHelper.createLocation('TestLocation', testOrganization.Id);
            GFRS_Funding_Request__c testFundingRequest = gFRS_UnitTestHelper.createCorporateMembershipFundingRequestObject(testOrganization.Id, testLocation.Id, 'Processing & Disposition', 'Process Payment', 'Process Payment', 'Cardiology', 'Acromegaly', 'Organization;Location;Application;Third Party;Program;Budget;Attachments');
            testFundingRequest.Venue_city__c = 'Test';
            update testFundingRequest;
            GFRS_Program__c testProgram = gFRS_UnitTestHelper.createProgram(testFundingRequest.Id, 'Live', 1, 2, 3, gFRS_UnitTestHelper.ID_PROGRAM_HC_RECTYPE);
            testProgram.Venue_city__c = 'Test';
            insert testProgram;
        }
        GFRS_Funding_Request__c createIMEDReqest(){
            account = gFRS_UnitTestHelper.createAccount('Test Account Name');
            testContact = gFRS_UnitTestHelper.createContact(account.Id);
            testUser = gFRS_UnitTestHelper.createPortalUser(testContact);
            Id organizationId = gFRS_UnitTestHelper.createOrganization('87-9999999', account.Id).Id;
            Id localizationId = gFRS_UnitTestHelper.createLocation('Vendor Name', organizationId).Id;
            
            Date startDate = Date.today().addYears(1);
            Date stopDate = Date.today().addYears(2);
            
            return gFRS_UnitTestIMEDHelper.createIMEDFundingRequestApplicationStep(organizationId, localizationId);
        }
        
        GFRS_Funding_Request__c createChCHarReqest(){
            account = gFRS_UnitTestHelper.createAccount('Test Account Name');
            testContact = gFRS_UnitTestHelper.createContact(account.Id);
            testUser = gFRS_UnitTestHelper.createPortalUser(testContact);
            Id organizationId = gFRS_UnitTestHelper.createOrganization('87-9999999', account.Id).Id;
            Id localizationId = gFRS_UnitTestHelper.createLocation('Vendor Name', organizationId).Id;
            
            Date startDate = Date.today().addYears(1);
            Date stopDate = Date.today().addYears(2);
            
            GFRS_Funding_Request__c req=[select id,name from GFRS_Funding_Request__c where id =:gFRS_UnitTestHelperHcChar.CreateHcCharRequestInStatusNew(organizationId, localizationId, testUser)];
            return req;
        }
        
        GFRS_Funding_Request__c createPhilantropicReqest(){
            account = gFRS_UnitTestHelper.createAccount('Test Account Name');
            testContact = gFRS_UnitTestHelper.createContact(account.Id);
            testUser = gFRS_UnitTestHelper.createPortalUser(testContact);
            Id organizationId = gFRS_UnitTestHelper.createOrganization('87-9999999', account.Id).Id;
            Id localizationId = gFRS_UnitTestHelper.createLocation('Vendor Name', organizationId).Id;
            
            Date startDate = Date.today().addYears(1);
            Date stopDate = Date.today().addYears(2);
            
            GFRS_Funding_Request__c req=[select id,name from GFRS_Funding_Request__c where id =:gFRS_UnitTestHelperPhilanthropic.CreatePhilanthropicRequestInStatusNew(organizationId, localizationId, testUser)];
            return req;
        }
        
        GFRS_Funding_Request__c createFellowShipReqest(){
            account = gFRS_UnitTestHelper.createAccount('Test Account Name');
            testContact = gFRS_UnitTestHelper.createContact(account.Id);
            testUser = gFRS_UnitTestHelper.createPortalUser(testContact);
            Id organizationId = gFRS_UnitTestHelper.createOrganization('87-9999999', account.Id).Id;
            Id localizationId = gFRS_UnitTestHelper.createLocation('Vendor Name', organizationId).Id;
            
            Date startDate = Date.today().addYears(1);
            Date stopDate = Date.today().addYears(2);
            
            GFRS_Funding_Request__c req=[select id,name from GFRS_Funding_Request__c where id =:gFRS_UnitTestHelperFellowship.CreateFellowshipRequestInStatusNew(organizationId, localizationId, testUser)];
            return req;
        }
        
        GFRS_Funding_Request__c createExhibitAnsOtherPromoReqest(){
            account = gFRS_UnitTestHelper.createAccount('Test Account Name');
            testContact = gFRS_UnitTestHelper.createContact(account.Id);
            testUser = gFRS_UnitTestHelper.createPortalUser(testContact);
            Id organizationId = gFRS_UnitTestHelper.createOrganization('87-9999999', account.Id).Id;
            Id localizationId = gFRS_UnitTestHelper.createLocation('Vendor Name', organizationId).Id;
            
            Date startDate = Date.today().addYears(1);
            Date stopDate = Date.today().addYears(2);
            
            return gFRS_UnitTestHelperExhibitsOtherPromo.createExhibitOtherPromosDecisionStep(organizationId, localizationId, testUser);
            
        }
        
        GFRS_Funding_Request__c createScinetficPipelinReqest(){
            account = gFRS_UnitTestHelper.createAccount('Test Account Name');
            testContact = gFRS_UnitTestHelper.createContact(account.Id);
            testUser = gFRS_UnitTestHelper.createPortalUser(testContact);
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
            account = gFRS_UnitTestHelper.createAccount('Test Account Name');
            testContact = gFRS_UnitTestHelper.createContact(account.Id);
            testUser = gFRS_UnitTestHelper.createPortalUser(testContact);
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
            account = gFRS_UnitTestHelper.createAccount('Test Account Name');
            testContact = gFRS_UnitTestHelper.createContact(account.Id);
            testUser = gFRS_UnitTestHelper.createPortalUser(testContact);
            Id organizationId = gFRS_UnitTestHelper.createOrganization('87-9999999', account.Id).Id;
            Id localizationId = gFRS_UnitTestHelper.createLocation('Vendor Name', organizationId).Id;
            
            Date startDate = Date.today().addYears(1);
            Date stopDate = Date.today().addYears(2);
            
            GFRS_Funding_Request__c req=[select id,name from GFRS_Funding_Request__c where id =:gFRS_UnitTestHelperCorporateMembership.CreateCorpMemberRequestInStatusNew(organizationId, localizationId, testUser)];
            return req;
            
        }
        
        GFRS_Funding_Request__c createScientificProReqest(){
            account = gFRS_UnitTestHelper.createAccount('Test Account Name');
            testContact = gFRS_UnitTestHelper.createContact(account.Id);
            testUser = gFRS_UnitTestHelper.createPortalUser(testContact);
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

    public static Boolean checkApexMessages(String message) {
            for(Apexpages.Message msg : ApexPages.getMessages()){
                if (msg.getDetail().contains(message)) {
                    return true;
                }
            }
            return false;
    }

    static testMethod void testExtendControllerForScientific(){
        TestSettings ts=new TestSettings();
        GFRS_Funding_Request__c fundReq=ts.createScientificProReqest();
        system.debug('check fund request data:'+fundReq);
        PageReference pRef= Page.GFRS_Funding_Request_Read;
        Test.setCurrentPage(pRef);
        Test.startTest(); 
        gFRS_FundingRequestReadController cont=new gFRS_FundingRequestReadController(new ApexPages.StandardController(fundReq));
        //Test communication popup
        cont.showRFI_Popup();
        system.assert(true,cont.isRFI_PopUpShown);
        system.assertEquals(true, cont.selectedET=='NONE');
        Boolean requestApprovedIsUserFA=cont.checkIfReqestWasApprovedAndUserIsFA;
        Boolean requestWaitingForBAorLR=cont.checkIfReqestWaitingForBAOrLRApprovalForFoundation;
        List<SelectOption> opt=cont.getAvailableET();
        List<SelectOption> optEmpty=cont.getEmpytSelectList();
        cont.selectedET=opt.get(opt.size() -1).getValue();
        cont.generateEmailContent();
        system.assertEquals(true, cont.selectedET!='NONE');
        system.assertEquals(true, opt.size()>0, 'Communication form should show some available email templates');
        system.assertEquals(true, cont.subjectContent != null, 'Subject of communication email should be set');
        system.assertEquals(true, cont.etBody != null, 'Content of communication email should be set');
        cont.sendEmail();
        cont.hideRFI_Popup();
        //end of communication popu functionality
        //Start test closing funding request
        cont.showClosingPopup();
        cont.fundReq.Sub_Status__c='Denied';
        cont.fundReq.External_Sub_status__c='Denied';
        cont.resetForm();
        cont.fundReq.Decision_Reasons__c='CCO Compliance Denial';
        cont.refreshCloseFundingForm();
        cont.closeFundingRequest();
        cont.hideClosingPopup();
        Test.stopTest();
        
    }

    static testMethod void testExtendControllerForCorporateMembership(){
        TestSettings ts=new TestSettings();
        GFRS_Funding_Request__c fundReq=ts.createCorporateMembershipReqest();
        PageReference pRef= Page.GFRS_Funding_Request_Read;
        Test.setCurrentPage(pRef);
        Test.startTest(); 
        gFRS_FundingRequestReadController cont=new gFRS_FundingRequestReadController(new ApexPages.StandardController(fundReq));
        //Test communication popup
        cont.showRFI_Popup();
        system.assert(true,cont.isRFI_PopUpShown);
        system.assertEquals(true, cont.selectedET=='NONE');
        Boolean requestApprovedIsUserFA=cont.checkIfReqestWasApprovedAndUserIsFA;
        Boolean requestWaitingForBAorLR=cont.checkIfReqestWaitingForBAOrLRApprovalForFoundation;
        List<SelectOption> opt=cont.getAvailableET();
        List<SelectOption> optEmpty=cont.getEmpytSelectList();
        cont.selectedET=opt.get(opt.size() -1).getValue();
        cont.generateEmailContent();
        system.assertEquals(true, cont.selectedET!='NONE');
        system.assertEquals(true, opt.size()>0, 'Communication form should show some available email templates');
        system.assertEquals(true, cont.subjectContent != null, 'Subject of communication email should be set');
        system.assertEquals(true, cont.etBody != null, 'Content of communication email should be set');
        cont.sendEmail();
        cont.hideRFI_Popup();
        //end of communication popu functionality
        //Start test closing funding request
        cont.showClosingPopup();
        cont.fundReq.Sub_Status__c='Denied';
        cont.fundReq.External_Sub_status__c='Denied';
        cont.resetForm();
        cont.fundReq.Decision_Reasons__c='CCO Compliance Denial';
        cont.refreshCloseFundingForm();
        cont.closeFundingRequest();
        cont.hideClosingPopup();
        Test.stopTest();
    }

    static testMethod void testExtendControllerForFIE(){
        TestSettings ts=new TestSettings();
        GFRS_Funding_Request__c fundReq=ts.createFIEReqest();
        PageReference pRef= Page.GFRS_Funding_Request_Read;
        Test.setCurrentPage(pRef);
        Test.startTest(); 
        gFRS_FundingRequestReadController cont=new gFRS_FundingRequestReadController(new ApexPages.StandardController(fundReq));
        //Test communication popup
        cont.showRFI_Popup();
        system.assert(true,cont.isRFI_PopUpShown);
        system.assertEquals(true, cont.selectedET=='NONE');
        Boolean requestApprovedIsUserFA=cont.checkIfReqestWasApprovedAndUserIsFA;
        Boolean requestWaitingForBAorLR=cont.checkIfReqestWaitingForBAOrLRApprovalForFoundation;
        List<SelectOption> opt=cont.getAvailableET();
        List<SelectOption> optEmpty=cont.getEmpytSelectList();
        cont.selectedET=opt.get(opt.size() -1).getValue();
        cont.generateEmailContent();
        system.assertEquals(true, cont.selectedET!='NONE');
        system.assertEquals(true, opt.size()>0, 'Communication form should show some available email templates');
        system.assertEquals(true, cont.subjectContent != null, 'Subject of communication email should be set');
        system.assertEquals(true, cont.etBody != null, 'Content of communication email should be set');
        cont.sendEmail();
        cont.hideRFI_Popup();
        //end of communication popu functionality
        //Start test closing funding request
        cont.showClosingPopup();
        cont.fundReq.Sub_Status__c='Denied';
        cont.fundReq.External_Sub_status__c='Denied';
        cont.resetForm();
        cont.fundReq.Decision_Reasons__c='CCO Compliance Denial';
        cont.refreshCloseFundingForm();
        cont.closeFundingRequest();
        cont.hideClosingPopup();
        Test.stopTest();
    }

    static testMethod void testExtendControllerForSciPipline(){
        TestSettings ts=new TestSettings();
        GFRS_Funding_Request__c fundReq=ts.createScinetficPipelinReqest();
        PageReference pRef= Page.GFRS_Funding_Request_Read;
        Test.setCurrentPage(pRef);
        Test.startTest(); 
        gFRS_FundingRequestReadController cont=new gFRS_FundingRequestReadController(new ApexPages.StandardController(fundReq));
        //Test communication popup
        cont.showRFI_Popup();
        system.assert(true,cont.isRFI_PopUpShown);
        system.assertEquals(true, cont.selectedET=='NONE');
        Boolean requestApprovedIsUserFA=cont.checkIfReqestWasApprovedAndUserIsFA;
        Boolean requestWaitingForBAorLR=cont.checkIfReqestWaitingForBAOrLRApprovalForFoundation;
        List<SelectOption> opt=cont.getAvailableET();
        List<SelectOption> optEmpty=cont.getEmpytSelectList();
        cont.selectedET=opt.get(opt.size() -1).getValue();
        cont.generateEmailContent();
        system.assertEquals(true, cont.selectedET!='NONE');
        system.assertEquals(true, opt.size()>0, 'Communication form should show some available email templates');
        system.assertEquals(true, cont.subjectContent != null, 'Subject of communication email should be set');
        system.assertEquals(true, cont.etBody != null, 'Content of communication email should be set');
        cont.sendEmail();
        cont.hideRFI_Popup();
        //end of communication popu functionality
        //Start test closing funding request
        cont.showClosingPopup();
        cont.fundReq.Sub_Status__c='Denied';
        cont.fundReq.External_Sub_status__c='Denied';
        cont.resetForm();
        cont.fundReq.Decision_Reasons__c='CCO Compliance Denial';
        cont.refreshCloseFundingForm();
        cont.closeFundingRequest();
        cont.hideClosingPopup();
        Test.stopTest();
    }

    static testMethod void testExtendControllerForExhOtherPromo(){
        TestSettings ts=new TestSettings();
        GFRS_Funding_Request__c fundReq=ts.createExhibitAnsOtherPromoReqest();
        PageReference pRef= Page.GFRS_Funding_Request_Read;
        Test.setCurrentPage(pRef);
        Test.startTest(); 
        gFRS_FundingRequestReadController cont=new gFRS_FundingRequestReadController(new ApexPages.StandardController(fundReq));
        //Test communication popup
        cont.showRFI_Popup();
        system.assert(true,cont.isRFI_PopUpShown);
        system.assertEquals(true, cont.selectedET=='NONE');
        Boolean requestApprovedIsUserFA=cont.checkIfReqestWasApprovedAndUserIsFA;
        Boolean requestWaitingForBAorLR=cont.checkIfReqestWaitingForBAOrLRApprovalForFoundation;
        List<SelectOption> opt=cont.getAvailableET();
        List<SelectOption> optEmpty=cont.getEmpytSelectList();
        cont.selectedET=opt.get(opt.size() -1).getValue();
        cont.generateEmailContent();
        system.assertEquals(true, cont.selectedET!='NONE');
        system.assertEquals(true, opt.size()>0, 'Communication form should show some available email templates');
        system.assertEquals(true, cont.subjectContent != null, 'Subject of communication email should be set');
        system.assertEquals(true, cont.etBody != null, 'Content of communication email should be set');
        cont.sendEmail();
        cont.hideRFI_Popup();
        //end of communication popu functionality
        //Start test closing funding request
        cont.showClosingPopup();
        cont.fundReq.Sub_Status__c='Denied';
        cont.fundReq.External_Sub_status__c='Denied';
        cont.resetForm();
        cont.fundReq.Decision_Reasons__c='CCO Compliance Denial';
        cont.refreshCloseFundingForm();
        cont.fundReq.Decision_Reasons__c='CCO Compliance Denial';
        cont.refreshCloseFundingForm();
        cont.fundReq.Decision_Reasons__c='Compliance Denial';
        cont.refreshCloseFundingForm();
        cont.fundReq.Decision_Reasons__c='Limited Funding Availability';
        cont.refreshCloseFundingForm();
        cont.fundReq.Decision_Reasons__c='Low Priority';
        cont.refreshCloseFundingForm();
        cont.fundReq.Decision_Reasons__c='No Funding Available';
        cont.refreshCloseFundingForm();
        cont.fundReq.Decision_Reasons__c='Outside Therapeutic Area of Interest';
        cont.refreshCloseFundingForm();
        cont.fundReq.Decision_Reasons__c='Canceled at the Request of Applicant';
        cont.refreshCloseFundingForm();
        cont.fundReq.Decision_Reasons__c='Canceled Post Funding';
        cont.refreshCloseFundingForm();
        cont.fundReq.Decision_Reasons__c='Cannot Agree to LOA Terms';
        cont.refreshCloseFundingForm();
        cont.fundReq.Decision_Reasons__c= 'Did Not Receive Response to RFI(s)';
        cont.refreshCloseFundingForm();
        cont.fundReq.Decision_Reasons__c= 'Duplicate Request in System';
        cont.refreshCloseFundingForm();
        cont.fundReq.Decision_Reasons__c= 'Insufficient Lead Time to Review Grant';
        cont.refreshCloseFundingForm();
       	cont.fundReq.Decision_Reasons__c= 'Cancel Request';
        cont.refreshCloseFundingForm();
        cont.closeFundingRequest();
        cont.hideClosingPopup();
        //end of closing funding request operation
        
        Test.stopTest();
    }

    static testMethod void testOtherPromoCloneProcess(){
        TestSettings ts=new TestSettings();
        GFRS_Funding_Request__c fundReq=ts.createExhibitAnsOtherPromoReqest();
        PageReference pRef= Page.GFRS_Funding_Request_Read;
        Test.setCurrentPage(pRef);
        gFRS_FundingRequestReadController cont=new gFRS_FundingRequestReadController(new ApexPages.StandardController(fundReq));
        Test.startTest(); 
        if(cont.isCloneButtonVisible){
            cont.showClone_Popup();
            cont.startCloningOperation();
        }
        Test.stopTest();
        
    }

    static testMethod void testExtendControllerForFellowship(){
        TestSettings ts=new TestSettings();
        GFRS_Funding_Request__c fundReq=ts.createFellowShipReqest();
        PageReference pRef= Page.GFRS_Funding_Request_Read;
        Test.setCurrentPage(pRef);
        Test.startTest(); 
        gFRS_FundingRequestReadController cont=new gFRS_FundingRequestReadController(new ApexPages.StandardController(fundReq));
        //Test communication popup
        cont.showRFI_Popup();
        system.assert(true,cont.isRFI_PopUpShown);
        system.assertEquals(true, cont.selectedET=='NONE');
        Boolean requestApprovedIsUserFA=cont.checkIfReqestWasApprovedAndUserIsFA;
        Boolean requestWaitingForBAorLR=cont.checkIfReqestWaitingForBAOrLRApprovalForFoundation;
        List<SelectOption> opt=cont.getAvailableET();
        List<SelectOption> optEmpty=cont.getEmpytSelectList();
        cont.selectedET=opt.get(opt.size() -1).getValue();
        cont.generateEmailContent();
        system.assertEquals(true, cont.selectedET!='NONE');
        system.assertEquals(true, opt.size()>0, 'Communication form should show some available email templates');
        system.assertEquals(true, cont.subjectContent != null, 'Subject of communication email should be set');
        system.assertEquals(true, cont.etBody != null, 'Content of communication email should be set');
        cont.sendEmail();
        cont.hideRFI_Popup();
        //end of communication popu functionality
        //Start test closing funding request
        cont.showClosingPopup();
        cont.fundReq.Sub_Status__c='Denied';
        cont.fundReq.External_Sub_status__c='Denied';
        cont.resetForm();
        cont.fundReq.Decision_Reasons__c='CCO Compliance Denial';
        cont.refreshCloseFundingForm();
        cont.closeFundingRequest();
        cont.hideClosingPopup();
        Test.stopTest();
    }

    static testMethod void testExtendControllerForPhilantropic(){
        TestSettings ts=new TestSettings();
        GFRS_Funding_Request__c fundReq=ts.createPhilantropicReqest();
        PageReference pRef= Page.GFRS_Funding_Request_Read;
        Test.setCurrentPage(pRef);
        Test.startTest(); 
        gFRS_FundingRequestReadController cont=new gFRS_FundingRequestReadController(new ApexPages.StandardController(fundReq));
        //Test communication popup
        cont.showRFI_Popup();
        system.assert(true,cont.isRFI_PopUpShown);
        system.assertEquals(true, cont.selectedET=='NONE');
        Boolean requestApprovedIsUserFA=cont.checkIfReqestWasApprovedAndUserIsFA;
        Boolean requestWaitingForBAorLR=cont.checkIfReqestWaitingForBAOrLRApprovalForFoundation;
        List<SelectOption> opt=cont.getAvailableET();
        List<SelectOption> optEmpty=cont.getEmpytSelectList();
        cont.selectedET=opt.get(opt.size() -1).getValue();
        cont.generateEmailContent();
        system.assertEquals(true, cont.selectedET!='NONE');
        system.assertEquals(true, opt.size()>0, 'Communication form should show some available email templates');
        system.assertEquals(true, cont.subjectContent != null, 'Subject of communication email should be set');
        system.assertEquals(true, cont.etBody != null, 'Content of communication email should be set');
        cont.sendEmail();
        cont.hideRFI_Popup();
        //end of communication popu functionality
        //Start test closing funding request
        cont.showClosingPopup();
        cont.fundReq.Sub_Status__c='Denied';
        cont.fundReq.External_Sub_status__c='Denied';
        cont.resetForm();
        cont.fundReq.Decision_Reasons__c='CCO Compliance Denial';
        cont.refreshCloseFundingForm();
        cont.closeFundingRequest();
        cont.hideClosingPopup();
        Test.stopTest();
    }


    static testMethod void testExtendControllerForHCChar(){
        TestSettings ts=new TestSettings();
        GFRS_Funding_Request__c fundReq=ts.createChCHarReqest();
        PageReference pRef= Page.GFRS_Funding_Request_Read;
        Test.setCurrentPage(pRef);
        Test.startTest(); 
        gFRS_FundingRequestReadController cont=new gFRS_FundingRequestReadController(new ApexPages.StandardController(fundReq));
        //Test communication popup
        cont.showRFI_Popup();
        system.assert(true,cont.isRFI_PopUpShown);
        system.assertEquals(true, cont.selectedET=='NONE');
        Boolean requestApprovedIsUserFA=cont.checkIfReqestWasApprovedAndUserIsFA;
        Boolean requestWaitingForBAorLR=cont.checkIfReqestWaitingForBAOrLRApprovalForFoundation;
        List<SelectOption> opt=cont.getAvailableET();
        List<SelectOption> optEmpty=cont.getEmpytSelectList();
        cont.selectedET=opt.get(opt.size() -1).getValue();
        cont.generateEmailContent();
        system.assertEquals(true, cont.selectedET!='NONE');
        system.assertEquals(true, opt.size()>0, 'Communication form should show some available email templates');
        system.assertEquals(true, cont.subjectContent != null, 'Subject of communication email should be set');
        system.assertEquals(true, cont.etBody != null, 'Content of communication email should be set');
        cont.sendEmail();
        cont.hideRFI_Popup();
        //end of communication popu functionality
        //Start test closing funding request
        cont.showClosingPopup();
        cont.fundReq.Sub_Status__c='Denied';
        cont.fundReq.External_Sub_status__c='Denied';
        cont.resetForm();
        cont.fundReq.Decision_Reasons__c='CCO Compliance Denial';
        cont.refreshCloseFundingForm();
        cont.fundReq.Decision_Reasons__c='Compliance Denial';
        cont.refreshCloseFundingForm();
        cont.fundReq.Decision_Reasons__c='Limited Funding Availability';
        cont.refreshCloseFundingForm();
        cont.fundReq.Decision_Reasons__c='Low Priority';
        cont.refreshCloseFundingForm();
        cont.fundReq.Decision_Reasons__c='No Funding Available';
        cont.refreshCloseFundingForm();
        cont.fundReq.Decision_Reasons__c='Outside Therapeutic Area of Interest';
        cont.refreshCloseFundingForm();
        cont.fundReq.Decision_Reasons__c='Canceled at the Request of Applicant';
        cont.refreshCloseFundingForm();
        cont.fundReq.Decision_Reasons__c='Canceled Post Funding';
        cont.refreshCloseFundingForm();
        cont.fundReq.Decision_Reasons__c='Cannot Agree to LOA Terms';
        cont.refreshCloseFundingForm();
        cont.fundReq.Decision_Reasons__c= 'Did Not Receive Response to RFI(s)';
        cont.refreshCloseFundingForm();
        cont.fundReq.Decision_Reasons__c= 'Duplicate Request in System';
        cont.refreshCloseFundingForm();
        cont.fundReq.Decision_Reasons__c= 'Insufficient Lead Time to Review Grant';
        cont.refreshCloseFundingForm();
       	cont.fundReq.Decision_Reasons__c= 'Cancel Request';
        cont.refreshCloseFundingForm();
        cont.closeFundingRequest();
        cont.hideClosingPopup();
        Test.stopTest();
    }

    static testMethod void testExtendControllerForIMED(){
        TestSettings ts=new TestSettings();
        GFRS_Funding_Request__c fundReq=ts.createIMEDReqest();
        PageReference pRef= Page.GFRS_Funding_Request_Read;
        Test.setCurrentPage(pRef);
        Test.startTest(); 
        gFRS_FundingRequestReadController cont=new gFRS_FundingRequestReadController(new ApexPages.StandardController(fundReq));
        //Test communication popup
        cont.showRFI_Popup();
        system.assert(true,cont.isRFI_PopUpShown);
        system.assertEquals(true, cont.selectedET=='NONE');
        Boolean requestApprovedIsUserFA=cont.checkIfReqestWasApprovedAndUserIsFA;
        Boolean requestWaitingForBAorLR=cont.checkIfReqestWaitingForBAOrLRApprovalForFoundation;
        List<SelectOption> opt=cont.getAvailableET();
        List<SelectOption> optEmpty=cont.getEmpytSelectList();
        cont.selectedET=opt.get(opt.size() -1).getValue();
        cont.generateEmailContent();
        cont.selectedET='Reconciliation Request Communication';
        cont.generateEmailContent();
        cont.selectedET='Canceled Post Funding Communication';
        cont.generateEmailContent();
        cont.selectedET='Outcomes Request Communication';
        cont.generateEmailContent();
        cont.selectedET='Evaluation Reminder Communication';
        cont.generateEmailContent();
        
        system.assertEquals(true, cont.selectedET!='NONE');
        system.assertEquals(true, opt.size()>0, 'Communication form should show some available email templates');
        system.assertEquals(true, cont.subjectContent != null, 'Subject of communication email should be set');
        system.assertEquals(true, cont.etBody != null, 'Content of communication email should be set');
        cont.sendEmail();
        cont.hideRFI_Popup();
        //end of communication popu functionality
        //Start test closing funding request
        cont.showClosingPopup();
        cont.fundReq.Sub_Status__c='Denied';
        cont.fundReq.External_Sub_status__c='Denied';
        cont.resetForm();
        cont.fundReq.Decision_Reasons__c='CCO Compliance Denial';
        cont.refreshCloseFundingForm();
        cont.fundReq.Decision_Reasons__c='CCO Compliance Denial';
        cont.refreshCloseFundingForm();
        cont.fundReq.Decision_Reasons__c='Compliance Denial';
        cont.refreshCloseFundingForm();
        cont.fundReq.Decision_Reasons__c='Limited Funding Availability';
        cont.refreshCloseFundingForm();
        cont.fundReq.Decision_Reasons__c='Low Priority';
        cont.refreshCloseFundingForm();
        cont.fundReq.Decision_Reasons__c='No Funding Available';
        cont.refreshCloseFundingForm();
        cont.fundReq.Decision_Reasons__c='Outside Therapeutic Area of Interest';
        cont.refreshCloseFundingForm();
        cont.fundReq.Decision_Reasons__c='Canceled at the Request of Applicant';
        cont.refreshCloseFundingForm();
        cont.fundReq.Decision_Reasons__c='Canceled Post Funding';
        cont.refreshCloseFundingForm();
        cont.fundReq.Decision_Reasons__c='Cannot Agree to LOA Terms';
        cont.refreshCloseFundingForm();
        cont.fundReq.Decision_Reasons__c= 'Did Not Receive Response to RFI(s)';
        cont.refreshCloseFundingForm();
        cont.fundReq.Decision_Reasons__c= 'Duplicate Request in System';
        cont.refreshCloseFundingForm();
        cont.fundReq.Decision_Reasons__c= 'Insufficient Lead Time to Review Grant';
        cont.refreshCloseFundingForm();
       	cont.fundReq.Decision_Reasons__c= 'Cancel Request';
        cont.refreshCloseFundingForm();
        cont.closeFundingRequest();
        cont.hideClosingPopup();
        Test.stopTest();
    }

    static testMethod void testExtendControllerManagePDFTEST(){
        TestSettings ts=new TestSettings();
        GFRS_Funding_Request__c fundReq=ts.createIMEDReqest();
        PageReference pRef= Page.GFRS_Funding_Request_Read;
        Test.setCurrentPage(pRef);
        Test.startTest(); 
        gFRS_FundingRequestReadController cont=new gFRS_FundingRequestReadController(new ApexPages.StandardController(fundReq));
        
        cont.fundReq.LOA_Signed__c='Yes';
        cont.fundReq.Decision_Date__c=date.today();
        cont.fundReq.HC_Compliance_Date__c=date.today();
        cont.managePDF();
        gFRS_FundingRequestReadController cont1=new gFRS_FundingRequestReadController(new ApexPages.StandardController(cont.fundReq));
        system.assertEquals(true, cont1.fundReq.LOA_PDF__c == null);
        system.assertEquals(true, cont1.fundReq.Compliance_flags_PDF__c == null);
        system.assertEquals(true, cont1.fundReq.HC_Compliance_Flags_PDF__c == null);
        cont.managePDF();
        Test.stopTest();
    }

    static testMethod void testExtendControllerManagePDFForFIE(){
        TestSettings ts=new TestSettings();
        GFRS_Funding_Request__c fundReq=ts.createFIEReqest();
        PageReference pRef= Page.GFRS_Funding_Request_Read;
        Test.setCurrentPage(pRef);
        Test.startTest(); 
        gFRS_FundingRequestReadController cont=new gFRS_FundingRequestReadController(new ApexPages.StandardController(fundReq));
        
        cont.fundReq.LOA_Signed__c='Yes';
        cont.fundReq.Decision_Date__c=date.today();
        cont.fundReq.HC_Compliance_Date__c=date.today();
        cont.managePDF();
        gFRS_FundingRequestReadController cont1=new gFRS_FundingRequestReadController(new ApexPages.StandardController(cont.fundReq));
        system.assertEquals(true, cont1.fundReq.LOA_PDF__c == null);
        system.assertEquals(true, cont1.fundReq.Compliance_flags_PDF__c == null);
        system.assertEquals(true, cont1.fundReq.HC_Compliance_Flags_PDF__c == null);
        cont1.fundReq.LOA_PDF__c='123456789012345678';
        cont1.fundReq.Compliance_flags_PDF__c='123456789012345678';
        cont1.fundReq.HC_Compliance_Flags_PDF__c='123456789012345678';
        cont1.fundReq.LOA_Signed__c=null;
        cont1.fundReq.Decision_Date__c=null;
        cont1.fundReq.HC_Compliance_Date__c=null;
        cont.managePDF();
        Test.stopTest();
    }

    static  void testExtendControllerPyamentCreation(){
        TestSettings ts=new TestSettings();
        GFRS_Funding_Request__c fundReq=ts.createIMEDReqest();
        PageReference pRef= Page.GFRS_Funding_Request_Read;
        Test.setCurrentPage(pRef);
        Test.startTest(); 
        gFRS_FundingRequestReadController cont=new gFRS_FundingRequestReadController(new ApexPages.StandardController(fundReq));
        
        cont.createNewPaymentAllocation();
        cont.createNewRefundAllocation();
        Test.stopTest();
    }    

    static testMethod void testCheckIfReqestWasApprovedAndUserIsFA(){
        TestSettings settings = new TestSettings();
        GFRS_Funding_Request__c fundReq = settings.createIMEDReqest();

        gFRS_FundingRequestReadController controller = new gFRS_FundingRequestReadController(new ApexPages.StandardController(fundReq));

        System.assertEquals(false,controller.checkIfReqestWasApprovedAndUserIsFA);

        User user = [SELECT Id FROM User WHERE Profile.Name = 'GNE-GFRS-Super User' AND IsActive = true LIMIT 1];
        User financialApprover_1 = user;
        controller.fundReq.Financial_Approver_1__c = financialApprover_1.Id;
        controller.fundReq.Financial_Approver_1_Decision_Date__c = Date.today().addDays(-20);

        System.runAs(financialApprover_1){
            System.assertEquals(true,controller.checkIfReqestWasApprovedAndUserIsFA);
        }

        User financialApprover_2 = user;
        controller.fundReq.Financial_Approver_1__c = null;
        controller.fundReq.Financial_Approver_2__c = financialApprover_2.Id;
        controller.fundReq.Financial_Approver_2_Decision_Date__c = Date.today().addDays(-20);

        System.runAs(financialApprover_2){
            System.assertEquals(true,controller.checkIfReqestWasApprovedAndUserIsFA);
        }

        User financialApprover_3 = user;
        controller.fundReq.Financial_Approver_2__c = null;
        controller.fundReq.Financial_Approver_3__c = financialApprover_3.Id;
        controller.fundReq.Financial_Approver_3_Decision_Date__c = Date.today().addDays(-20);

        System.runAs(financialApprover_3){
            System.assertEquals(true,controller.checkIfReqestWasApprovedAndUserIsFA);
        }

        controller.fundReq = null;
        System.assertEquals(false,controller.checkIfReqestWasApprovedAndUserIsFA);
    }

    static testMethod void testCheckIfReqestWaitingForBAOrLRApprovalForFoundation(){
        TestSettings settings = new TestSettings();
        GFRS_Funding_Request__c fundReq = settings.createIMEDReqest();
        fundReq.Foundation_Eligible__c = 'Yes';
        update fundReq;

        gFRS_FundingRequestReadController controller = new gFRS_FundingRequestReadController(new ApexPages.StandardController(fundReq));

        System.assertEquals(false,controller.checkIfReqestWasApprovedAndUserIsFA);

        User user = [SELECT Id FROM User WHERE Profile.Name = 'GNE-GFRS-Super User' AND IsActive = true LIMIT 1];

        controller.fundReq.Legal_Reviewer_1__c = user.Id;
        controller.fundReq.Business_Reviewer_1__c = user.Id;
        controller.fundReq.Business_Approver_2__c = user.Id;
        controller.fundReq.Business_Approver_3__c = user.Id;

        System.runAs(user){
            //BA1 have only read access for Foundation
            System.assertEquals(true,controller.checkIfReqestWaitingForBAOrLRApprovalForFoundation);
            controller.fundReq.Business_Reviewer_1__c = null;
            controller.fundReq.Business_Approver_2__c = null;
            controller.fundReq.Business_Approver_3__c = null;
            //Legal Reviewer have only read access for Foundation 
            System.assertEquals(true,controller.checkIfReqestWaitingForBAOrLRApprovalForFoundation);
        }
    }

    static testMethod void requestShouldBeSubmittedForApprovalOnlyOnceTest(){
        final GFRS_OrgSettings__c settings = GFRS_OrgSettings__c.getOrgDefaults();
        settings.Funding_Request_Trigger_Enabled__c = true;
        upsert settings;
        final Map<String, Schema.RecordTypeInfo> recordTypes = sObjectType.GFRS_Funding_Request__c.getRecordTypeInfosByName();
        final GFRS_Funding_Request__c[] fundRequests = new GFRS_Funding_Request__c[]{
            new GFRS_Funding_Request__c(
                RecordTypeId = recordTypes.get('IMED').getRecordTypeId(),
                Sub_Status__c = 'New'
            ),
            new GFRS_Funding_Request__c(
                RecordTypeId = recordTypes.get('IMED').getRecordTypeId(),
                Sub_Status__c = 'CCO Review'
            )
        };
        insert fundRequests;
        final Approval.ProcessSubmitRequest approvalReq = new Approval.ProcessSubmitRequest();
        approvalReq.setComments('Submitting request for approval.');
        approvalReq.setObjectId(fundRequests[1].Id);
        final Approval.ProcessResult approvalResult = Approval.process(approvalReq);
        fundRequests[1].Sub_Status__c = 'New';
        update fundRequests[1];
        gFRS_Util.APPROVAL_IDS.clear();
        Test.startTest();
        for (Integer i = 0; i < fundRequests.size(); i++) {
            fundRequests[i].Sub_Status__c = 'CCO Review';
        }
        final Database.SaveResult[] actualResults = Database.update(fundRequests, false);
        Test.stopTest();
        System.assertEquals(actualResults.size(), gFRS_Util.APPROVAL_IDS.size());
        for (Integer i = 0; i < actualResults.size(); i++) {
            System.assertEquals(true, actualResults[i].isSuccess(), i + ': ' + actualResults[i].getErrors());
            System.assertEquals(true, gFRS_Util.APPROVAL_IDS.contains(fundRequests[i].Id),
                i + ': ' + gFRS_Util.APPROVAL_IDS
            );
        }
    }
    
    static testMethod void testCloseFundingRequest(){
        TestSettings settings = new TestSettings();
        GFRS_Funding_Request__c fundReq = settings.createIMEDReqest();
        fundReq.Sub_Status__c = 'Manager Review';
        update fundReq;

        gFRS_FundingRequestReadController controller = new gFRS_FundingRequestReadController(new ApexPages.StandardController(fundReq));

        //Veryfication of ERROR MESSAGES
        //1. Decision reason is required
        System.assertEquals(null,controller.closeFundingRequest());
        System.assertEquals(true,checkApexMessages(Label.gFRS_ERROR_DECISION_REASON_REQ));

        controller.closeFundingEmailSubject = null;
        controller.fundReq.Decision_Reasons__c = 'Compliance Denial';

        //2. Please provide the Email Subject.
        System.assertEquals(null,controller.closeFundingRequest());
        System.assertEquals(true,checkApexMessages(Label.gFRS_Error_RFI_EmptySubject));

        controller.closeFundingEmailSubject = 'test';
        controller.closeFundingEmailBody = null;

        //3. Please provide the Email Body.
        System.assertEquals(null,controller.closeFundingRequest());
        System.assertEquals(true,checkApexMessages(Label.gFRS_Error_RFI_EmptyContent));
    }

    static testMethod void testCanCreateAnotherPaymentFA(){
        TestSettings settings = new TestSettings();
        GFRS_Funding_Request__c fundingRequest = settings.createIMEDReqest();

        gFRS_FundingRequestReadController controller = new gFRS_FundingRequestReadController(new ApexPages.StandardController(fundingRequest));

        System.assertEquals(false,controller.canCreateAnotherPaymentFA);
        GFRS_Funding_Allocation__c fundingAllocation = [SELECT Id FROM GFRS_Funding_Allocation__c WHERE RecordType.Name != 'Refund' AND Grant_Request__c=: fundingRequest.Id];
        delete fundingAllocation;
        System.assertEquals(true,controller.canCreateAnotherPaymentFA);

    }

    static testMethod void testFormatToCurrency(){
        String example = '12345';
        String expectedResult = '12,345.00';
        String actualResult;

        Test.startTest();
            actualResult = gFRS_FundingRequestReadController.formatToCurrency(example);
        Test.stopTest();

        System.assertEquals(expectedResult, actualResult);
    }

    static testMethod void testStartCloningOperation(){
        TestSettings settings = new TestSettings();
        GFRS_Funding_Request__c fundingRequest = settings.createIMEDReqest();
        fundingRequest.clonedRequestOwner__c = UserInfo.getUserId();
        update fundingRequest;

        gFRS_FundingRequestReadController controller = new gFRS_FundingRequestReadController(new ApexPages.StandardController(fundingRequest));

        Test.startTest();
            controller.startCloningOperation();
        Test.stopTest();
    }

    @IsTest
    static void testUtilMethods() {
        TestSettings settings = new TestSettings();
        GFRS_Funding_Request__c fundingRequest = settings.createExhibitAnsOtherPromoReqest();

        gFRS_FundingRequestReadController controller = new gFRS_FundingRequestReadController(new ApexPages.StandardController(fundingRequest));

        System.assert(!controller.isCloneButtonVisible);
        controller.fundReq.Status__c = 'QC Review';

        //checkIfStringIsInList
        List<String> sourceList = new List<String>{'Test 1', 'Test 2', 'Test 3'};
        System.assert(controller.checkIfStringIsInList(sourceList, 'Test 1'));
        System.assert(controller.checkIfStringIsInList(sourceList, 'Test 2'));
        System.assert(controller.checkIfStringIsInList(sourceList, 'Test 3'));

        //checkIfSuperUserCanClone
        System.assert(controller.checkIfSuperUserCanClone(gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME));
        System.assert(controller.checkIfSuperUserCanClone(gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME));
        System.assert(controller.checkIfSuperUserCanClone(gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME));
        System.assert(controller.checkIfSuperUserCanClone(gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME));
        System.assert(controller.checkIfSuperUserCanClone(gFRS_Util.TYPE_HC_CHAR_NAME));
        System.assert(controller.checkIfSuperUserCanClone(gFRS_Util.TYPE_PHILANTHROPIC_NAME));
        System.assert(!controller.checkIfSuperUserCanClone(gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME));

        //checkIfUserBelonsToMCSGroup
        System.assert(!controller.checkIfUserBelonsToMCSGroup);
        System.assert(controller.checkIfCloneSuperUser);

        //isCloneButtonVisible
        System.assert(controller.isCloneButtonVisible);

    }
}