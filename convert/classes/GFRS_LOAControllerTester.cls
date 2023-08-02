@isTest
private class GFRS_LOAControllerTester {

     class TestSettings {
        //-- profiles
        public String PROF_GFRS_USER_NAME = 'GNE-GFRS-User';
        public id PROF_GFRS_USER;
        //organization
        GFRS_Organization__c organization;
        GFRS_Location__c location;
        Contact contact;
        Contact otherContact;
        User portalUser;
        User otherPortalUser;
        User user;
        User otherUser;
        Account account;
        public GFRS_Funding_Request__c request;
        public GFRS_Payment_History__c paymentHistory;
        
        GFRS_Organization__c userOrganization;
        
        public  String DEFAULT_STATUS = 'Intake';
        public  String DEFAULT_SUB_STATUS = 'Not Submitted';
        public  Integer NUM = 2;
        
        public TestSettings(){
            PROF_GFRS_USER = [ select Id, Name, Type from Profile where Name =:PROF_GFRS_USER_NAME limit 1 ].Id;
            account = gFRS_TestCreationUtils.createAccount('test');
            insert account;

            organization = gFRS_TestCreationUtils.createOrganization('223344556', account);
            organization.Organization_Name__c='testOrg';
            insert organization;

            location = gFRS_TestCreationUtils.createLocation('test',organization.id);
            insert location;

            contact = gFRS_TestCreationUtils.createContact(account);
            insert contact;

            otherContact = gFRS_TestCreationUtils.createContact(account);
            insert otherContact;

            portalUser = gFRS_TestCreationUtils.createUser(contact, 'test@gene.com');
            insert portalUser;

            otherPortalUser = gFRS_TestCreationUtils.createUser(otherContact, 'test3@gene.com');
            insert otherPortalUser;

            user = gFRS_TestCreationUtils.createUser3('Test', 'test', 'aaa@gene.com', PROF_GFRS_USER, '1234');
            insert user;

            otherUser = gFRS_TestCreationUtils.createUser3('Test', 'test', 'aafffa@gene.com',PROF_GFRS_USER, '1234');
            insert otherUser;        
        }            
        
        public void createPaymentHistory(){
       	
	       	this.paymentHistory = gFRS_TestCreationUtils.createPayment(this.request.Id, 200);
	       	insert this.paymentHistory;
	       
	    }
       
        public void createFundingRequest(String requestType, Id autorizedAsigner, String signed){
            if (signed == null) {
            	signed = gFRS_Util.NO;
            }
            request = gFRS_TestCreationUtils.createFundingRequest(requestType , DEFAULT_STATUS, DEFAULT_SUB_STATUS, DEFAULT_SUB_STATUS, '', organization.Id, location.Id);
            request.Authorized_Signer__c = autorizedAsigner;
            request.LOA_Signed__c = signed;
            request.Approved_Amount__c=10;

            if(requestType == gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS || requestType == gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO){
                request.Funding_Sub_Type__c = 'Exhibit Booth';
            }
            insert request;
        }
        
         public void createFoundationFundingRequest(String requestType, Id autorizedAsigner, String signed,decimal approvedAmount){
            if (signed == null) {
            	signed = gFRS_Util.NO;
            }
            request = gFRS_TestCreationUtils.createFundingRequest(requestType , DEFAULT_STATUS, DEFAULT_SUB_STATUS, DEFAULT_SUB_STATUS, '', organization.Id, location.Id);
            request.Authorized_Signer__c = autorizedAsigner;
            request.LOA_Signed__c = signed;
            request.Approved_Amount__c=approvedAmount;
            request.Foundation_Eligible__c=gFRS_Util.YES;
            
            insert request;
        }
        public void createFundingRequestWithPayments(String requestType, Id autorizedAsigner, String signed){
            if (signed == null) {
                signed = gFRS_Util.NO;
            }
            request = gFRS_TestCreationUtils.createFundingRequest(requestType , DEFAULT_STATUS, DEFAULT_SUB_STATUS, DEFAULT_SUB_STATUS, '', organization.Id, location.Id);
            request.Authorized_Signer__c = autorizedAsigner;
            request.LOA_Signed__c = signed;
            request.Approved_Amount__c=10;
            insert request;
            GFRS_Payment_History__c paymentHistory = new GFRS_Payment_History__c();
            paymentHistory.SAP_Request_ID__c    = request.Name + '_1';
            paymentHistory.Date__c              = date.today();
            paymentHistory.Grant__c             = request.Id;
            paymentHistory.Amount__c            = 10;
            paymentHistory.Action__c            = 'Payment Sent';
            insert paymentHistory;
        }
    }
 	
    
    
    /*
    static testMethod void testLOAControllerApproveLOAWithPayment () {
        TestSettings ts = new TestSettings();
        System.RunAs(ts.user){
        	
	            ts.createFundingRequestWithPayments(gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS, ts.user.Id, gFRS_Util.NO);
	            GFRS_LOAController cont = new GFRS_LOAController(new ApexPages.StandardController(ts.request));
	            Test.startTest();
	            cont.signerName = 'Signer Name';
	            cont.pin = '1234';
	            Pagereference pr = cont.approve();
	            System.assertEquals('YES',ts.request.LOA_Signed__c);
	            Test.stopTest();
        	}
    }
    */
    
    static testMethod void testLOAControllerConstructorIsPinRequiredForEOP() {
        TestSettings ts = new TestSettings();
        System.RunAs(ts.user){
            ts.createFundingRequest(gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS, ts.portalUser.Id, gFRS_Util.NO);
            Test.startTest();
            GFRS_LOAController cont = new GFRS_LOAController(new ApexPages.StandardController(ts.request));
            Test.stopTest();
            System.assertEquals(true, cont.isPinRequired);
        }
    }
    
    
    static testMethod void testLOAControllerConstructorIsPinRequiredForIMED() {
        TestSettings ts = new TestSettings();
        System.RunAs(ts.user){
            ts.createFundingRequest(gFRS_Util.TYPE_IMED, ts.portalUser.Id, gFRS_Util.NO);
            GFRS_LOAController cont = new GFRS_LOAController(new ApexPages.StandardController(ts.request));
            System.assertEquals(true, cont.isPinRequired);
        }
    }
     
    static testMethod void testLOAControllerConstructorStepParamDefaultValue() {
        TestSettings ts = new TestSettings();
        System.RunAs(ts.user){
            ts.createFundingRequest(gFRS_Util.TYPE_IMED, ts.portalUser.Id, gFRS_Util.NO);
            GFRS_LOAController cont = new GFRS_LOAController(new ApexPages.StandardController(ts.request));
            System.assertEquals(1, cont.pageStep);
        }
    }

    static testMethod void testLOAControllerConstructorStepParamIsCorrect() {
        TestSettings ts = new TestSettings();
        map<String,String> pageParams = ApexPages.currentPage().getParameters();
        pageParams.put(GFRS_LOAController.PARAM_STEP, '3');
        System.RunAs(ts.user){
            ts.createFundingRequest(gFRS_Util.TYPE_IMED, ts.portalUser.Id, gFRS_Util.NO);
            GFRS_LOAController cont = new GFRS_LOAController(new ApexPages.StandardController(ts.request));
            System.assertEquals(3, cont.pageStep);
        }
    }

    static testMethod void testLOAControllerConstructorStepParamInvalidValue() {
        TestSettings ts = new TestSettings();
        map<String,String> pageParams = ApexPages.currentPage().getParameters();
        pageParams.put(GFRS_LOAController.PARAM_STEP, 'abc');
        System.RunAs(ts.user){
            ts.createFundingRequest(gFRS_Util.TYPE_IMED, ts.portalUser.Id, gFRS_Util.NO);
            GFRS_LOAController cont = new GFRS_LOAController(new ApexPages.StandardController(ts.request));
            System.assertEquals(1, cont.pageStep);
        }
    }
     
    static testMethod void testLOAControllerConstructorNullInsteadOfFundingRequset() {
        TestSettings ts = new TestSettings();
        GFRS_Funding_Request__c fundingRequest = new GFRS_Funding_Request__c(); 
        GFRS_LOAController cont = new GFRS_LOAController(new ApexPages.StandardController(fundingRequest));
        list<Apexpages.Message> msgs = Apexpages.getMessages();
        Boolean exists = false;
        for (Apexpages.Message m : msgs) {
            if (m.getDetail() == 'Funding request was not sent') {
                exists = true;
                break;
            }
        }
        System.assertEquals(true, exists, 'Missing error message');
        
    }
    
    static testMethod void testLOAControllerExhibitOtherPromosConstructorSignatureUrl () {
        TestSettings ts = new TestSettings();
        System.RunAs(ts.user){
            ts.createFundingRequest(gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS, ts.portalUser.Id, gFRS_Util.NO);
            Test.startTest();
            GFRS_LOAController cont = new GFRS_LOAController(new ApexPages.StandardController(ts.request));
            String msg = cont.introductionMessage; 
        	String appMsg = cont.approvalMessage; 
            Test.stopTest();
        }
    }
    
    static testMethod void testLOAControllerConstructorIMEDSignatureUrl () {
        TestSettings ts = new TestSettings();
        System.RunAs(ts.user){
            ts.createFundingRequest(gFRS_Util.TYPE_IMED, ts.portalUser.Id, gFRS_Util.NO);
            GFRS_LOAController cont = new GFRS_LOAController(new ApexPages.StandardController(ts.request));
            String msg = cont.introductionMessage; 
        	String appMsg = cont.approvalMessage;
        }
    }
    
    static testMethod void testLOAControllerConstructorCMSignatureUrl () {
        TestSettings ts = new TestSettings();
        System.RunAs(ts.user){
            ts.createFundingRequest(gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS, ts.portalUser.Id, gFRS_Util.NO);
            
            Test.startTest();
            GFRS_LOAController cont = new GFRS_LOAController(new ApexPages.StandardController(ts.request));
            String msg = cont.introductionMessage; 
        	String appMsg = cont.approvalMessage;
        	Test.stopTest();
        }
    }
    
    static testMethod void testLOAControllerConstructorPhilanthropicSignatureUrl () {
        TestSettings ts = new TestSettings();
        System.RunAs(ts.user){
            ts.createFundingRequest(gFRS_Util.TYPE_PHILANTHROPIC, ts.portalUser.Id, gFRS_Util.NO);
            Test.startTest();
            GFRS_LOAController cont = new GFRS_LOAController(new ApexPages.StandardController(ts.request));
            String msg = cont.introductionMessage; 
        	String appMsg = cont.approvalMessage;
        	Test.stopTest();
        }
    }
    
    static testMethod void testLOAControllerConstructorHCSignatureUrl () {
        TestSettings ts = new TestSettings();
        System.RunAs(ts.user){
            ts.createFundingRequest(gFRS_Util.TYPE_HC_CHAR, ts.portalUser.Id, gFRS_Util.NO);
            Test.startTest();
            GFRS_LOAController cont = new GFRS_LOAController(new ApexPages.StandardController(ts.request));
            String msg = cont.introductionMessage; 
        	String appMsg = cont.approvalMessage;
        	Test.stopTest();
        }
    }
    
    static testMethod void testLOAControllerConstructorScientificSignatureUrl () {
        TestSettings ts = new TestSettings();
        System.RunAs(ts.user){
            ts.createFundingRequest(gFRS_Util.TYPE_SCIENTIFIC_PROJECTS, ts.portalUser.Id, gFRS_Util.NO);
            Test.startTest();
            GFRS_LOAController cont = new GFRS_LOAController(new ApexPages.StandardController(ts.request));
            String msg = cont.introductionMessage; 
        	String appMsg = cont.approvalMessage;
        	Test.stopTest();
        }
    }
    
    static testMethod void testLOAControllerConstructorFellowshipSignatureUrl () {
        TestSettings ts = new TestSettings();
        System.RunAs(ts.user){
            ts.createFundingRequest(gFRS_Util.TYPE_FELLOWSHIPS, ts.portalUser.Id, gFRS_Util.NO);
            Test.startTest();
            GFRS_LOAController cont = new GFRS_LOAController(new ApexPages.StandardController(ts.request));
            String msg = cont.introductionMessage; 
        	String appMsg = cont.approvalMessage;
        	Test.stopTest();
        }
    }
    
    static testMethod void testLOAControllerCancelRedirectUrl () {
        TestSettings ts = new TestSettings();
        System.RunAs(ts.user){
            ts.createFundingRequest(gFRS_Util.TYPE_FELLOWSHIPS, ts.portalUser.Id, gFRS_Util.NO);
            Test.startTest();
            GFRS_LOAController cont = new GFRS_LOAController(new ApexPages.StandardController(ts.request));
            Pagereference pr = cont.cancel();
            System.assertEquals(gFRS_Util.initializeLink(GFRS_LOAController.PATH_HOME, null, null), pr.getUrl());
            Test.stopTest();
        }
    }
	
    static testMethod void testLOAControllerCheckPageStepDefaultRedirectUrl () {
        TestSettings ts = new TestSettings();
        System.RunAs(ts.user){
            ts.createFundingRequest(gFRS_Util.TYPE_IMED, ts.portalUser.Id, gFRS_Util.NO);
            GFRS_LOAController cont = new GFRS_LOAController(new ApexPages.StandardController(ts.request));
            System.assertEquals(1, cont.pageStep);
            Pagereference pr = cont.checkPageStep();
            System.assertEquals(null, pr);
        }
    }
	
    static testMethod void testLOAControllerCheckPageStep2NotAuthorizedSigner () {
        TestSettings ts = new TestSettings();
        System.RunAs(ts.user){
            ts.createFundingRequest(gFRS_Util.TYPE_IMED, ts.portalUser.Id, gFRS_Util.NO);
            //ts.createPaymentHistory();
            
            GFRS_LOAController cont = new GFRS_LOAController(new ApexPages.StandardController(ts.request));
            Test.startTest();
            System.assertEquals(1, cont.pageStep);
            Pagereference pr = cont.checkPageStep();
            System.assertEquals(null, pr);
            Test.stopTest();
        }
    }
	
    static testMethod void testLOAControllerCheckPageStep2AutorizedSignerNotSignedLOA () {
        TestSettings ts = new TestSettings();
        map<String,String> pageParams = ApexPages.currentPage().getParameters();
        pageParams.put(GFRS_LOAController.PARAM_STEP, '2');
        System.RunAs(ts.user){
            ts.createFundingRequest(gFRS_Util.TYPE_IMED, ts.portalUser.Id, gFRS_Util.NO);
            //ts.createPaymentHistory();
        }
        System.RunAs(ts.portalUser){
        	
            GFRS_LOAController cont = new GFRS_LOAController(new ApexPages.StandardController(ts.request));
            Test.startTest();
            System.assertEquals(2, cont.pageStep);
            Pagereference pr = cont.checkPageStep();
            System.assertEquals(null, pr);
            Test.stopTest();
        }
    }
    
    
    static testMethod void testLOAControllerCheckPageStep2AutorizedSignerSignedLOA () {
        TestSettings ts = new TestSettings();
        map<String,String> pageParams = ApexPages.currentPage().getParameters();
        pageParams.put(GFRS_LOAController.PARAM_STEP, '2');
        System.RunAs(ts.user){
            ts.createFundingRequest(gFRS_Util.TYPE_IMED, ts.portalUser.Id, gFRS_Util.YES);
            //ts.createPaymentHistory();
        }
        System.RunAs(ts.portalUser){
        	
            GFRS_LOAController cont = new GFRS_LOAController(new ApexPages.StandardController(ts.request));
            Test.startTest();
            System.assertEquals(2, cont.pageStep);
            Pagereference pr = cont.checkPageStep();
            System.assertEquals('/apex/gfrs_loa?id='+ts.request.id+'&isSrollDown=true&step=3', pr.getUrl());
            Test.stopTest();
        }
    }
	
	
    static testMethod void testLOAControllerBackRedirectUrl () {
        TestSettings ts = new TestSettings();
        System.RunAs(ts.user){
            ts.createFundingRequest(gFRS_Util.TYPE_FELLOWSHIPS, ts.portalUser.Id, gFRS_Util.NO);
            Test.startTest();
            GFRS_LOAController cont = new GFRS_LOAController(new ApexPages.StandardController(ts.request));
            Pagereference pr = cont.back();
            Pagereference expexctedPr = new ApexPages.PageReference(gFRS_Util.initializeLink(GFRS_LOAController.PATH_LOA, ts.request, null));
            System.assertEquals(expexctedPr.getUrl(), pr.getUrl());
            Test.stopTest();
        }
    }
	
    static testMethod void testLOAControllerApproveEmptySignerName () {
        TestSettings ts = new TestSettings();
        System.RunAs(ts.user){
            ts.createFundingRequest(gFRS_Util.TYPE_IMED, ts.portalUser.Id, gFRS_Util.NO);
            GFRS_LOAController cont = new GFRS_LOAController(new ApexPages.StandardController(ts.request));
            Pagereference pr = cont.approve();
            System.assertEquals(null, pr);
            list<Apexpages.Message> msgs = Apexpages.getMessages();
            Boolean exists = false;
            for (Apexpages.Message m : msgs) {
                if (m.getDetail() == 'Signer name is required.') {
                    exists = true;
                    break;
                }
            }
            System.assertEquals(true, exists, 'Missing error message');
        }
    }
    
    static testMethod void testLOAControllerApproveNotAuthorizedSigner () {
        TestSettings ts = new TestSettings();
        map<String,String> pageParams = ApexPages.currentPage().getParameters();
        pageParams.put('signerName', 'Signer Name');
        System.RunAs(ts.user){
            ts.createFundingRequest(gFRS_Util.TYPE_IMED, ts.otherPortalUser.Id, gFRS_Util.NO);    
            GFRS_LOAController cont = new GFRS_LOAController(new ApexPages.StandardController(ts.request));
            Pagereference pr = cont.approve();
            System.assertEquals(null, pr);
            list<Apexpages.Message> msgs = Apexpages.getMessages();
            Boolean exists = false;
            for (Apexpages.Message m : msgs) {
                if (m.getDetail() == 'You are not the authorized signer for this grant') {
                    exists = true;
                    break;
                }
            }
            System.assertEquals(true, exists, 'Missing error message');
        }
    }
    
    static testMethod void testLOAControllerApproveEmptyPin () {
        TestSettings ts = new TestSettings();
        System.RunAs(ts.user){
            ts.createFundingRequest(gFRS_Util.TYPE_IMED, ts.user.Id, gFRS_Util.NO);    
            GFRS_LOAController cont = new GFRS_LOAController(new ApexPages.StandardController(ts.request));
            cont.signerName = 'Signer Name';
            Pagereference pr = cont.approve();
            System.assertEquals(null, pr);
            list<Apexpages.Message> msgs = Apexpages.getMessages();
            Boolean exists = false;
            for (Apexpages.Message m : msgs) {
                if (m.getDetail() == 'PIN is required.') {
                    exists = true;
                    break;
                }
            }
            System.assertEquals(true, exists, 'Missing error message');
        }
    }
    
    static testMethod void testLOAControllerApproveInvalidPin () {
        TestSettings ts = new TestSettings();
        System.RunAs(ts.user){
            ts.createFundingRequest(gFRS_Util.TYPE_IMED, ts.user.Id, gFRS_Util.NO);    
            GFRS_LOAController cont = new GFRS_LOAController(new ApexPages.StandardController(ts.request));
            Test.startTest();
            cont.signerName = 'Signer Name';
            cont.pin = '1111';
            Pagereference pr = cont.approve();
            System.assertEquals(null, pr);
            list<Apexpages.Message> msgs = Apexpages.getMessages();
            Boolean exists = false;
            for (Apexpages.Message m : msgs) {
                if (m.getDetail() == 'Invalid PIN.') {
                    exists = true;
                    break;
                }
            }
            System.assertEquals(true, exists, 'Missing error message');
            Test.stopTest();
        }
    }
    
	
    static testMethod void testLOAControllerApproveEmptyPaymentsUpdatesFR () {
        TestSettings ts = new TestSettings();
        System.RunAs(ts.user){
            ts.createFundingRequest(gFRS_Util.TYPE_IMED, ts.user.Id, gFRS_Util.NO);
            GFRS_LOAController cont = new GFRS_LOAController(new ApexPages.StandardController(ts.request));
            Test.startTest();
            cont.signerName = 'Signer Name';
            cont.pin = '1234';
            Pagereference pr = cont.approve();
            System.assertNotEquals(null, pr);
            System.assertEquals('/apex/gfrs_loa?id='+ts.request.id+'&isSrollDown=true&step=3', pr.getUrl());
            GFRS_Funding_Request__c fr = [SELECT LOA_Signer_Name__c, LOA_Signed__c, IP_Address__c, LOA_Signed_Date__c FROM GFRS_Funding_Request__c WHERE Id =: ts.request.Id];
            System.assertNotEquals(null, fr);
            System.assertEquals(cont.signerName, fr.LOA_Signer_Name__c);
            System.assertEquals(gFRS_Util.YES, fr.LOA_Signed__c);
            System.assertEquals(ApexPages.CurrentPage().getHeaders().get('x-Salesforce-SIP'), fr.IP_Address__c);
            System.assertNotEquals(null, fr.LOA_Signed_Date__c);
            Test.stopTest();
        }
    }
    
    static testMethod void testLOAControllerApproveNotEmptyPaymentsUpdatesFR () {
        TestSettings ts = new TestSettings();
        System.RunAs(ts.user){
            ts.createFundingRequest(gFRS_Util.TYPE_IMED, ts.user.Id, gFRS_Util.NO);
            GFRS_LOAController cont = new GFRS_LOAController(new ApexPages.StandardController(ts.request));
            Test.startTest();
            cont.signerName = 'Signer Name';
            cont.pin = '1234';
            Pagereference pr = cont.approve();
            System.assertNotEquals(null, pr);
            System.assertEquals('/apex/gfrs_loa?id='+ts.request.id+'&isSrollDown=true&step=3', pr.getUrl());
            GFRS_Funding_Request__c fr = [SELECT LOA_Signer_Name__c, LOA_Signed__c, IP_Address__c, LOA_Signed_Date__c FROM GFRS_Funding_Request__c WHERE Id =: ts.request.Id];
            System.assertNotEquals(null, fr);
            System.assertEquals(cont.signerName, fr.LOA_Signer_Name__c);
            System.assertEquals(gFRS_Util.YES, fr.LOA_Signed__c);
            System.assertEquals(ApexPages.CurrentPage().getHeaders().get('x-Salesforce-SIP'), fr.IP_Address__c);
            System.assertNotEquals(null, fr.LOA_Signed_Date__c);
            Test.stopTest();
        }
    }
    
    
    static testMethod void testLOAControllerPrintToPdfRedirectUrl () {
        TestSettings ts = new TestSettings();
        System.RunAs(ts.user){
            ts.createFundingRequest(gFRS_Util.TYPE_FELLOWSHIPS, ts.portalUser.Id, gFRS_Util.NO);
            test.startTest();
            GFRS_LOAController cont = new GFRS_LOAController(new ApexPages.StandardController(ts.request));
            
            Pagereference pr = cont.printToPdf();
            String expexctedUrl = GFRS_LOAController.PDF_PAGE + '?id=' + ts.request.Id;
            
            System.assertEquals(expexctedUrl, pr.getUrl());
            test.stopTest();
        }
    }
	
    static testMethod void testLOAControllerApprovalMessage () {
        TestSettings ts = new TestSettings();
        System.RunAs(ts.user){
            System.debug('Limits: ' + Limits.getQueries());
            ts.createFundingRequest(gFRS_Util.TYPE_FELLOWSHIPS, ts.portalUser.Id, gFRS_Util.NO);
            Test.startTest();
            GFRS_LOAController cont = new GFRS_LOAController(new ApexPages.StandardController(ts.request));
            String AM = cont.approvalMessage;
            String expectedAM = gFRS_Util.replaceContentVariable('__REQUESTPAYMENT__', cont.getApprovedAmount(), cont.contentItems.get('LOACommonText'));        
            expectedAM = gFRS_Util.replaceContentVariable('__TYPE__', String.valueOf(gFRS_Util.TYPE_FELLOWSHIPS_LETTER), expectedAM);
            system.debug(expectedAM);
            system.debug(AM);
            System.assertEquals(expectedAM, AM);
            Test.stopTest();
        }
    }
    
    static testMethod void testLOAControllerApproveCheckAttachmentGeneration () {
    	gFRS_UnitTestHelper.setGfrsCustomSettings(false);
        TestSettings ts = new TestSettings();
        gFRS_UnitTestHelper.setGfrsCustomSettings(true);
        System.RunAs(ts.user){
            ts.createFundingRequest(gFRS_Util.TYPE_IMED, ts.user.Id, gFRS_Util.NO);
            
            Pagereference pageRef= new Pagereference('apex/GFRS_LOA');
            Test.setCurrentPageReference(pageRef);
            Test.startTest();
            GFRS_LOAController cont = new GFRS_LOAController(new ApexPages.StandardController(ts.request));
            cont.signerName = 'Signer Name';
            cont.pin = '1234';
            String output=cont.approve().getUrl();
            Pagereference pageRef1= new Pagereference(output);
            Test.setCurrentPageReference(pageRef1);
            GFRS_LOAController cont1 = new GFRS_LOAController(new ApexPages.StandardController(ts.request));
            try{
            	cont1.checkPageStep();
            }catch(Exception ex){
            	system.debug('Uder unit test we can not use getContent Method');
            }	
            
            system.debug('check statuses');
            System.assertEquals('/apex/gfrs_loa?id='+ts.request.id+'&isSrollDown=true&step=3', output);
            
            Pagereference pageRef2= new Pagereference('/apex/gfrs_loa?id='+ts.request.id+'&isSrollDown=true&step=2');
            Test.setCurrentPageReference(pageRef2);
            //gFRS_UnitTestHelper.createPaymentHistory(ts.request, paymentType, typeOfCheckReceived, checkNumber, wbs, costCenter, amount)
            GFRS_LOAController cont2 = new GFRS_LOAController(new ApexPages.StandardController(ts.request));
            try{
            	cont2.checkPageStep();
            }catch(Exception ex){
            	system.debug('Uder unit test we can not use getContent Method');
            }
            
            String outputHome=cont.cancel().getUrl();
            System.assertEquals('/apex/gFRS_Home?t=t',outputHome);
            Test.stopTest();
        }
        
    }
    
    static testMethod void testLOAControllerApproveCheckAttachmentGenerationWithPayments () {
    	gFRS_UnitTestHelper.setGfrsCustomSettings(false);
        TestSettings ts = new TestSettings();
        ts.createFundingRequestWithPayments(gFRS_Util.TYPE_IMED, ts.user.Id, gFRS_Util.NO);
        gFRS_UnitTestHelper.setGfrsCustomSettings(true);
        System.RunAs(ts.user){
            
            	
            Pagereference pageRef= new Pagereference('apex/GFRS_LOA');
            Test.setCurrentPageReference(pageRef);
            GFRS_LOAController cont = new GFRS_LOAController(new ApexPages.StandardController(ts.request));
            Test.startTest();
            cont.signerName = 'Signer Name';
            cont.pin = '1234';
            
            //String output=cont.approve().getUrl();
            
            
            Test.stopTest();
        }
        
        
    }
    
     static testMethod void testLOAControllerForFoundationLess25k () {
    	gFRS_UnitTestHelper.setGfrsCustomSettings(false);
        	TestSettings ts = new TestSettings();
        
        	ts.createFoundationFundingRequest(gFRS_Util.TYPE_HC_CHAR, ts.user.Id, gFRS_Util.NO,10000);
        	gFRS_UnitTestHelper.setGfrsCustomSettings(true);
        	System.RunAs(ts.user){
        	
            Pagereference pageRef= new Pagereference('apex/GFRS_LOA');
            Test.setCurrentPageReference(pageRef);
            GFRS_LOAController cont = new GFRS_LOAController(new ApexPages.StandardController(ts.request));
            Test.startTest();
            cont.signerName = 'Signer Name';
            cont.pin = '1234';
            system.debug(cont.fundReq);
            //String contentOutput=cont.foundationLoaContentUnder25k;
            //String output=cont.approve().getUrl();
            
        }
        
     }
        
       
        static testMethod void testLOAControllerForFoundationOver25k () {
    	
        gFRS_UnitTestHelper.setGfrsCustomSettings(false);
	        TestSettings ts = new TestSettings();
        	ts.createFoundationFundingRequest(gFRS_Util.TYPE_HC_CHAR, ts.user.Id, gFRS_Util.NO,26000);
        	gFRS_UnitTestHelper.setGfrsCustomSettings(true);
       		 System.RunAs(ts.user){
        	
            Pagereference pageRef= new Pagereference('apex/GFRS_LOA');
            Test.setCurrentPageReference(pageRef);
            GFRS_LOAController cont = new GFRS_LOAController(new ApexPages.StandardController(ts.request));
            Test.startTest();
            cont.signerName = 'Signer Name';
            cont.pin = '1234';
            //String contentOutput=cont.foundationLoaContentOver25k;
            //String output=cont.approve().getUrl();
            
            Test.stopTest();
        }
        
    }
    
}