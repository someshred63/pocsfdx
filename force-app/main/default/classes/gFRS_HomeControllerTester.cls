@isTest
private class gFRS_HomeControllerTester {
    //-- profiles
    public static String PROF_GFRS_USER_NAME = 'GNE-GFRS-User';
    public static id PROF_GFRS_USER = [ select Id, Name, Type from Profile where Name =:PROF_GFRS_USER_NAME limit 1 ].Id;
    
     static testMethod void testHomeControllerConstructorRFITasks() {
         TestSettings ts = new TestSettings();
         ts.createOneFundingRequest();
         //System.debug( 'before creating funding reqeusts' );
         //ts.createFundingRequests();
        
        // update ts.request;
          
         //ts.tasks = ts.createTasks(ts.otherUser.id);
         //System.debug( 'before controller starts' );
         test.startTest();
         System.RunAs(ts.portalUser){
             gFRS_HomeController cont = new gFRS_HomeController(new ApexPages.StandardController(ts.request));
             System.debug( 'after controller completed' );
             //System.assertEquals(0, cont.myTasks.size() );
         }
         test.stopTest();
     }
     
     static testMethod void testHomeControllerConstructorForPortalUser() {
         TestSettings ts = new TestSettings();
         ts.createOneFundingRequest();
         test.startTest();
         System.RunAs(ts.portalUser){
            ts.fundingRequests.clear();
            ts.createFundingRequests();
            gFRS_HomeController cont = new gFRS_HomeController(new ApexPages.StandardController(ts.request));
            System.assertEquals(ts.organization.id, cont.userOrganization.id );
         }
         test.stopTest();
        
     }
     static testMethod void testPageReferencesFromHomePage() {
         TestSettings ts = new TestSettings();
         ts.createOneFundingRequest();
         test.startTest();
         ApexPages.PageReference decisionPage = new ApexPages.PageReference(gFRS_Util.initializeLink( gFRS_HomeController.PATH_ORG_INFO, null, 'org=' + ts.organization.Id ) );
         ApexPages.PageReference orgInfoPage = new ApexPages.PageReference( gFRS_Util.initializeLink( gFRS_HomeController.PATH_ORG_INFO, null, null ) );
         ApexPages.PageReference editOrgInfoPage = new ApexPages.PageReference( gFRS_Util.initializeLink( gFRS_HomeController.PATH_ORG_INFO, null, 'soc=soc' ) );
         ApexPages.PageReference resultPage;
         System.RunAs(ts.portalUser){
            gFRS_HomeController cont = new gFRS_HomeController(new ApexPages.StandardController(ts.request));
            resultPage = cont.next();
            System.assertEquals(decisionPage.getUrl(), resultPage.getUrl());
            resultPage = cont.goOrgInfo();
            System.assertEquals(editOrgInfoPage.getUrl(), resultPage.getUrl());
         }
         
         System.RunAs(ts.user){
            ts.fundingRequests.clear();
            ts.createFundingRequests();
            gFRS_HomeController cont = new gFRS_HomeController(new ApexPages.StandardController(ts.fundingRequests[0]));
            resultPage = cont.next();
            System.assertEquals(orgInfoPage.getUrl(), resultPage.getUrl());
         }
         test.stopTest();
     }
     
     static testMethod void testGetRequestById() {
        TestSettings ts = new TestSettings();
        GFRS_Funding_Request__c[] resultRequests;
        System.RunAs(ts.portalUser){
            ts.createFundingRequests();
            test.startTest();
            gFRS_HomeController cont = new gFRS_HomeController(new ApexPages.StandardController(ts.fundingRequests[0]));
            
            //method should delete the record
            cont.currentRequestId = ts.fundingRequests[1].id;
            cont.deleteRequest();
            resultRequests = [select Id,Name from GFRS_Funding_Request__c where Id=: ts.fundingRequests[1].id];
            System.assertEquals(0, resultRequests.size());
            
            GFRS_Funding_Request__c newRequest = gFRS_TestCreationUtils.createFundingRequest(gFRS_Util.TYPE_IMED , ts.DEFAULT_STATUS, ts.DEFAULT_SUB_STATUS, ts.DEFAULT_SUB_STATUS, '', ts.organization.Id, ts.location.Id);
            insert newRequest;
            //method should not delete this time
            cont.currentRequestId = newRequest.id;
            cont.deleteRequest();
            resultRequests = [select Id,Name from GFRS_Funding_Request__c where Id=: newRequest.id];
            System.assertEquals(1, resultRequests.size());
            test.stopTest();
            
         }
        
     }
     
     
    static testMethod void testCloseCloningPopup(){
        
        TestSettings ts = new TestSettings();
        ts.createOneFundingRequest();
        
        Test.startTest();
        
            gFRS_HomeController cont = new gFRS_HomeController(new ApexPages.StandardController(ts.request));
            cont.closeCloningPopup();
            System.assert(cont.displayCloningPopUp == false);
            
            cont.showCloningPopup();
            System.assert(cont.displayCloningPopUp == true);
            
            cont.closeCloningPopup();
            System.assert(cont.displayCloningPopUp == false);
        
        Test.stopTest();
    }
    
    
    static testmethod void testStartCloningOperation(){
    	
    	
    	
    	TestSettings ts = new TestSettings();
    	gFRS_UnitTestHelper.setGfrsCustomSettings(true);
        ts.createExhibitsFundingRequest();
       
    	
    	Test.startTest();
    	
    		gFRS_HomeController cont = new gFRS_HomeController(new ApexPages.StandardController(ts.request));
    		cont.setCon = null;
    		//cont.requestIDToClone = ts.request.Id;

    		
    		cont.requestIDToClone = ts.request.ID;
    		
    		System.assert(cont.clonedRequestName != null);
    		
    		ApexPages.PageReference result = cont.startCloningOperation();

    		System.assert(result == null);
    		System.assert(cont.clonedRequest != null);
    		System.assert(cont.clonedRequest.Id != null);
    		System.assert(cont.clonedRequest.Id != ts.request.Id);
    		
    		
    	
    	Test.stopTest();
    }
    
    
    static testmethod void testPaginationMethods(){
    	
    	TestSettings ts = new TestSettings();
    	gFRS_UnitTestHelper.setGfrsCustomSettings(true);
        ts.createExhibitsFundingRequest();
       
    	
    	Test.startTest();
    	
    		gFRS_HomeController cont = new gFRS_HomeController(new ApexPages.StandardController(ts.request));

    		System.debug('hasNext ' + cont.hasNext);
            System.debug('hasPrevious ' + cont.hasPrevious);
            System.debug('pageNumber ' + cont.pageNumber);

            if(cont.noOfRecords > 1){
              System.assert(cont.hasNext == true);  
            }else{
              System.assert(cont.hasNext == false);  
            }
    		
    		System.assert(cont.hasPrevious == false);
    		System.assert(cont.pageNumber == 1);
    		
    		
    		cont.previous();
    		System.assert(cont.selectedPageNumber == '');
    		cont.nextSet();
    		System.assert(cont.selectedPageNumber == '');
    		
    		cont.selectedPageNumber = '1';
    		cont.goToPage();
    		
    	Test.stopTest();
    }

    static testMethod void testIsInternal(){
        TestSettings ts = new TestSettings();
        ts.createOneFundingRequest();

        gFRS_HomeController cont = new gFRS_HomeController(new ApexPages.StandardController(ts.request));
        
        User externalUser = [SELECT Id FROM User WHERE Contact.Account.Id <> null AND isActive = true LIMIT 1];
        
        System.assertEquals(true,cont.isInternal);
        
        System.runAs(externalUser){
            cont = new gFRS_HomeController(new ApexPages.StandardController(ts.request));
            System.assertEquals(false,cont.isInternal);
        }

        

    }

    @isTest(SeeAllData=true)
    static void testWelcomeMessage(){
        TestSettings ts = new TestSettings();
        ts.createOneFundingRequest();

        String welcomeMessage = [ SELECT TextBlock__c FROM GFRS_Content_Translation__c
            WHERE Language__c = :UserInfo.getLanguage() and GFRS_Content__r.Filter__c = 'HomePage' AND GFRS_Content__r.Name = 'Welcome' ].TextBlock__c;
        Test.startTest();
            gFRS_HomeController cont = new gFRS_HomeController(new ApexPages.StandardController(ts.request));
        Test.stopTest();

        System.assertEquals(welcomeMessage,cont.welcomeMessage);
    }

    static testMethod void testCloseBlockReconciliaitonPopup(){
        TestSettings ts = new TestSettings();
        ts.createOneFundingRequest();

        Test.startTest();
            gFRS_HomeController cont = new gFRS_HomeController(new ApexPages.StandardController(ts.request));
            cont.closeBlockReconciliaitonPopup();
        Test.stopTest();

        System.assertEquals(false,cont.displayBlockReconciliaitonPopUp);
    }

    static testMethod void testShowBlockReconciliaitonPopup(){
        TestSettings ts = new TestSettings();
        ts.createOneFundingRequest();

        Test.startTest();
            gFRS_HomeController cont = new gFRS_HomeController(new ApexPages.StandardController(ts.request));
            cont.showBlockReconciliaitonPopup();
        Test.stopTest();

        System.assertEquals(true,cont.displayBlockReconciliaitonPopUp);
    }

    static testMethod void testCloseBlockAnnualReportPopup(){
        TestSettings ts = new TestSettings();
        ts.createOneFundingRequest();

        Test.startTest();
            gFRS_HomeController cont = new gFRS_HomeController(new ApexPages.StandardController(ts.request));
            cont.closeBlockAnnualReportPopup();
        Test.stopTest();

        System.assertEquals(false,cont.displayBlockAnnualReportPopUp);
    }

    static testMethod void testShowBlockAnnualReportPopup(){
        TestSettings ts = new TestSettings();
        ts.createOneFundingRequest();

        Test.startTest();
            gFRS_HomeController cont = new gFRS_HomeController(new ApexPages.StandardController(ts.request));
            cont.showBlockAnnualReportPopup();
        Test.stopTest();

        System.assertEquals(true,cont.displayBlockAnnualReportPopUp);
    }
    
    
     
     class TestSettings {
        GFRS_Organization__c organization;
        GFRS_Location__c location;
        Contact contact;
        Contact otherContact;
        User portalUser;
        User otherPortalUser;
        User user;
        User otherUser;
        Account account;
        GFRS_Funding_Request__c[] fundingRequests = new List<GFRS_Funding_Request__c>();
        GFRS_Funding_Request__c request;
        gFRS_Tasks__c[] tasks = new List<gFRS_Tasks__c>();
        gFRS_Tasks__c[] otherUserTasks = new List<gFRS_Tasks__c>();
        
        GFRS_Organization__c userOrganization;
        
        public  String DEFAULT_STATUS = 'Intake';
        public  String DEFAULT_SUB_STATUS = 'Not Submitted';
        public  Integer NUM = 2;
        
        public TestSettings(){
            account = gFRS_TestCreationUtils.createAccount('test');
            insert account;
            organization = gFRS_TestCreationUtils.createOrganization('223344556', account);
            insert organization;
            location = gFRS_TestCreationUtils.createLocation('test',organization.id);
            insert location;
            contact = gFRS_TestCreationUtils.createContact(account);
            insert contact;
            portalUser = gFRS_TestCreationUtils.createUser(contact, 'test@gene.com');
            insert portalUser;
            system.debug(PROF_GFRS_USER);
            user = gFRS_TestCreationUtils.createUser3('Test', 'test', 'aaa@gene.com', PROF_GFRS_USER, '1234');
            insert user;
            otherUser = gFRS_TestCreationUtils.createUser3('Test', 'test', 'aafffa@gene.com',PROF_GFRS_USER, '1234');
            insert otherUser;
            
        }           
        
        public void createOneFundingRequest(){
            request = gFRS_TestCreationUtils.createFundingRequest(gFRS_Util.TYPE_IMED , DEFAULT_STATUS, DEFAULT_SUB_STATUS, DEFAULT_SUB_STATUS, '', organization.Id, location.Id);
            request.Therapeutic_Area_Parent__c = 'Cardiology';
        	request.Funding_Sub_Type__c = 'Exhibit Booth';
            insert request;
        }
        
        
        public void createExhibitsFundingRequest(){
            GFRS_Content__c cont = new GFRS_Content__c();
            cont.Filter__c = 'Gcal_Header';
            cont.Name = 'Gcal_Header';
            insert new List<GFRS_Content__c>{cont};
            GFRS_Content_Translation__c contTrans = new GFRS_Content_Translation__c();
            contTrans.GFRS_Content__c = cont.Id;
            contTrans.Language__c ='en_US';
            contTrans.TextBlock__c = 'test';
            insert new List<GFRS_Content_Translation__c>{contTrans};
            request = gFRS_TestCreationUtils.createFundingRequest(gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS , DEFAULT_STATUS, DEFAULT_SUB_STATUS, DEFAULT_SUB_STATUS, '', organization.Id, location.Id);
            request.Therapeutic_Area_Parent__c = 'Cardiology';
        	request.Funding_Sub_Type__c = 'Exhibit Booth';
            insert request;
        }
        
        public void createOneFundingRequestAndUpdateToRFI(){
            request = gFRS_TestCreationUtils.createFundingRequest(gFRS_Util.TYPE_IMED , DEFAULT_STATUS, DEFAULT_SUB_STATUS, DEFAULT_SUB_STATUS, '', organization.Id, location.Id);
            insert request;
            request.Sub_Status__c='RFI';
            request.External_Sub_status__c='RFI';
            update request;
        }
        public void createFundingRequests(){
            for(Integer i=0; i < NUM; i++){
                GFRS_Funding_Request__c request = gFRS_TestCreationUtils.createFundingRequest(gFRS_Util.TYPE_IMED , DEFAULT_STATUS, DEFAULT_SUB_STATUS, DEFAULT_SUB_STATUS, '', organization.Id, location.Id);
                fundingRequests.add(request);
            }
           
            insert fundingRequests;
            fundingRequests = [
                select Id, Name, CreatedDate, Event_Program_Title__c, Date_Submitted__c, Requested_Amount__c, Sub_Status__c, External_Sub_status__c, Status__c, Record_Type_Name__c, Organization__c
                from GFRS_Funding_Request__c
                order by LastModifiedDate desc
            ];
            this.request = fundingRequests[0];
        }
        public gFRS_Tasks__c[] createTasks(Id userId){
            gFRS_Tasks__c[] tasksToInsert = new List<gFRS_Tasks__c>();
            for(Integer i=0; i < NUM; i++){
                gFRS_Tasks__c task = gFRS_TestCreationUtils.createTask2( this.request.id, 'Please Review', userId );
                tasksToInsert.add(task);
            }
            for(Integer i=0; i < NUM; i++){
                gFRS_Tasks__c task = gFRS_TestCreationUtils.createTask2( this.request.id, 'Completed', userId );
                tasksToInsert.add(task);
            }
            insert tasksToInsert;
            
            gFRS_Tasks__c[] tasksList = [ select id, User__c, User__r.Name, gFRS_Funding_Request__c, gFRS_Funding_Request__r.Name, Subject__c, Description__c, Status__c
                from gFRS_Tasks__c
                where ((Status__c != 'Completed' ) or (Status__c = 'Completed' and LastModifiedDate > YESTERDAY ))
                and User__c = :userId
                order by LastModifiedDate desc, Status__c desc
                limit 5
            ];
            
            return tasksList;
        }
    }
    
}