/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
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
private class gFRS_FR_Approval_Status_Tester {
	
	static final String STATUS_NEW = 'HC Compliance';
	static final String SUB_STATUS_NEW = 'New';

    /**
     *  Internal Testing class that takes care of setup and tear downs.
     **/
    class TestSettings {
		
		//-- instance variables
		public Account account;
		public GFRS_Organization__c organization;
		public GFRS_Location__c location;
		public GFRS_Funding_Request__c request;
		//public GFRS_WBS_Codes__c[] wbsCodes;
		public GFRS_Cost_Center_Code__c[] costCodes;
		
		public User businessReviewer;
		public User legalReviewer;
		public User businessApprover;
		
		public TestSettings(){
			//-- initialization done for ALL SETUPs done here
			this.account = gFRS_TestCreationUtils.createAccount( gFRS_TestCreationUtils.makeUnique( 'acct' ));
			insert this.account;
			
			this.organization = gFRS_TestCreationUtils.createOrganization2( '20110101', this.account.id );
			insert this.organization;
			
			this.location = gFRS_TestCreationUtils.createLocation( 'SomeLocation', this.organization.id );
			insert this.location;
			
			//GFRS_WBS_Codes__c[] WBSCodes = [select Id, Name from GFRS_WBS_Codes__c];
			GFRS_Cost_Center_Code__c[] CostCenterCodes = [select Id, Name from GFRS_Cost_Center_Code__c];
			GFRS_Administrative_Budget__c[] budgets = [select Id, Name from GFRS_Administrative_Budget__c];
			
		/*	this.wbsCodes = new GFRS_WBS_Codes__c[]{
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
			*/
			this.costCodes = new GFRS_Cost_Center_Code__c[]{
				gFRS_TestCreationUtils.createCostCenter('testIMED',gFRS_Util.TYPE_IMED_NAME),
				gFRS_TestCreationUtils.createCostCenter('testCM', gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME),
				gFRS_TestCreationUtils.createCostCenter('testEX', gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME),
				gFRS_TestCreationUtils.createCostCenter('testF',  gFRS_Util.TYPE_FELLOWSHIPS_NAME),
				gFRS_TestCreationUtils.createCostCenter('testFI', gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME),
				gFRS_TestCreationUtils.createCostCenter('testHC', gFRS_Util.TYPE_HC_CHAR_NAME),
				gFRS_TestCreationUtils.createCostCenter('testPH', gFRS_Util.TYPE_PHILANTHROPIC_NAME),
				gFRS_TestCreationUtils.createCostCenter('testSC', gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME)
			};
			
			//System.debug( 'profile:' + gFRS_TestCreationUtils.PROF_GFRS_USER );
			businessReviewer = gFRS_TestCreationUtils.createUser3('Test1', 'test1', 'aaa1@gene.com', gFRS_TestCreationUtils.PROF_GFRS_USER, '1234');
			insert businessReviewer;
            legalReviewer = gFRS_TestCreationUtils.createUser3('Test2', 'test2', 'aaa2@gene.com', gFRS_TestCreationUtils.PROF_GFRS_USER, '1234');
            insert legalReviewer;
            businessApprover = gFRS_TestCreationUtils.createUser3('Test3', 'test3', 'aaa3@gene.com', gFRS_TestCreationUtils.PROF_GFRS_USER, '1234');
            insert businessApprover;
            
            //System.debug( 'businessReviewer:' + businessReviewer );
            
		}
		
		public void setupIMED(){
		   	this.request = gFRS_TestCreationUtils.createFundingRequest2( gFRS_TestCreationUtils.RT_FR_IMED, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id );
			this.prepareRequestForUpdate();
			insert this.request;
		}
		
		public void setupCorporate(){
			this.request = gFRS_TestCreationUtils.createFundingRequest2( gFRS_TestCreationUtils.RT_FR_CORPORATE_MEMBERSHIPS, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id );
			this.prepareRequestForUpdate();
			insert this.request;
		}
		
		public void setupExhibits(){
			this.request = gFRS_TestCreationUtils.createFundingRequest2( gFRS_TestCreationUtils.RT_FR_EXHIBITS_OTHER_PROMOS, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id );
			this.prepareRequestForUpdate();
			insert this.request;
		}
		
		public void setupFellowships(){
			this.request = gFRS_TestCreationUtils.createFundingRequest2( gFRS_TestCreationUtils.RT_FR_FELLOWSHIPS, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id );
			this.prepareRequestForUpdate();
			insert this.request;
		}
		
		 public void setupField(){
			this.request = gFRS_TestCreationUtils.createFundingRequest2( gFRS_TestCreationUtils.RT_FR_FIELD_INITIATED_EXHIBITS, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id );
			this.prepareRequestForUpdate();
			insert this.request;
		}
		
		 public void setupHCChar(){
			this.request = gFRS_TestCreationUtils.createFundingRequest2( gFRS_TestCreationUtils.RT_FR_HC_CHAR, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id );
			this.prepareRequestForUpdate();
			insert this.request;
		}
		
		 public void setupPhilanthropic(){
			this.request = gFRS_TestCreationUtils.createFundingRequest2( gFRS_TestCreationUtils.RT_FR_PHILANTHROPIC, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id );
			this.prepareRequestForUpdate();
			insert this.request;
		}
		
		 public void setupScientific(){
			this.request = gFRS_TestCreationUtils.createFundingRequest2( gFRS_TestCreationUtils.RT_FR_SCIENTIFIC_PROJECTS, gFRS_Util.REQUEST_DEFAULT_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, gFRS_UTIL.REQUEST_DEFAULT_SUB_STATUS, '', this.organization.id, this.location.id );
			this.prepareRequestForUpdate();
			insert this.request;
		}
		
		public void setupApprovalFields( Boolean useBusinessReview, Boolean useLegalReview, Boolean useBusinessApproval ){
			if( useBusinessReview ) this.request.Business_Reviewer_1__c = this.businessReviewer.id;
			if( useLegalReview ) this.request.Legal_Reviewer_1__c = this.legalReviewer.id;
			if( useBusinessApproval ) this.request.Business_Approver__c = this.businessApprover.id;
			update this.request;
			//System.debug( '[' + useBusinessReview + ']:reviewers:' + (this.request.Business_Reviewer_1__c != null) );
		}
		
		/** cleanup the fundingRequest to the point that an update can occur **/
		public void prepareRequestForUpdate(){
			//this.request.Name = 'testRequest';
			this.request.Status__c = STATUS_NEW;
			this.request.Sub_Status__c = SUB_STATUS_NEW;
		}
		
		public gFRS_Funding_Request__c[] getNewList(){
			return( new gFRS_Funding_Request__c[]{ this.request } );
		}
		
		public Map<Id,gFRS_Funding_Request__c> getOldMap(){
			gFRS_Funding_Request__c[] frs = [ select id, Approval_Step__c from gFRS_Funding_Request__c where id = :this.request.id ];
			return( new Map<Id,gFRS_Funding_Request__c>( frs ) );
		}
		
		public void refreshRequest(){
			this.request = [ select id, Record_Type_Name__c, Status__c, Sub_Status__c,
				Business_Reviewer_1__c, Legal_Reviewer_1__c, Business_Approver__c
				from gFRS_Funding_Request__c where id = :this.request.id ];
		}
		
		public gFRS_Funding_Request__c getChangedRequest( gFRS_Funding_Request__c[] changedRequests ){
			if( changedRequests == null || changedRequests.size() < 1 ){
				return( this.request );
			} else {
				return( changedRequests[0] );
			}
		}
		
		public String makeStatus( Boolean isBusinessComplete, Boolean isLegalComplete, Boolean isBusinessApprovComplete ){
			String result = gFRS_Util.APPROVAL_GC;
			if( isBusinessComplete ) result += ',' + gFRS_Util.APPROVAL_BUSINESS_REV;
			if( isLegalComplete ) result += ',' + gFRS_Util.APPROVAL_LEGAL_REV;
			if( isBusinessApprovComplete ) result += ',' + gFRS_Util.APPROVAL_BUSINESS_APPROVER;
			return( result );
		}
	}
    
    static testMethod void testSettingsSetsUpWithoutErrors(){
    	try {
	    	TestSettings ts = new TestSettings();
			ts.setupCorporate();
			ts.setupApprovalFields( true, true, true );
    	} catch( Exception err ){
    		System.assert( false, 'TestSetting/Setup must not throw any exceptions:' + err.getMessage() );
    	}
    }
    
    static testMethod void withoutApprovalStatusUnchanged(){
    	TestSettings ts = new TestSettings();
		ts.setupCorporate();
		ts.setupApprovalFields( false, false, false );
		gFRS_Funding_Request__c[] newList = ts.getNewList();
		Map<Id,gFRS_Funding_Request__c> oldMap = ts.getOldMap();
		//System.debug( 'newList:' + newList + ', oldMap:' + oldMap );
		
		ts.request.Approval_Step__c = ts.makeStatus(false,false,false);
		
		gFRS_Funding_Request__c[] changedRequests =  gFRS_util.setApprovalOptionalStepStatus( ts.getNewList(), ts.getOldMap() );
		System.assertNotEquals( null, changedRequests, 'ChangedRequests must not return null' );
		
		gFRS_Funding_Request__c refreshedRequest = ts.getChangedRequest( changedRequests );
		System.assertEquals( ts.request.Sub_Status__c, refreshedRequest.Sub_Status__c, 'Sub status must not change since there were no optional steps' );
    }
    
    static testMethod void approvalStatusBusinessOnly(){
    	TestSettings ts = new TestSettings();
		ts.setupCorporate();
		ts.setupApprovalFields( true, false, false );
		//System.debug( 'after set reviewers:' + ( ts.request.Business_Reviewer_1__c != null) );
		gFRS_Funding_Request__c[] newList = ts.getNewList();
		Map<Id,gFRS_Funding_Request__c> oldMap = ts.getOldMap();
		
		ts.request.Approval_Step__c = ts.makeStatus(false,false,false);
		
		gFRS_Funding_Request__c[] changedRequests =  gFRS_util.setApprovalOptionalStepStatus( ts.getNewList(), ts.getOldMap() );
		System.assertNotEquals( null, changedRequests, 'ChangedRequests must not return null' );
		
		gFRS_Funding_Request__c refreshedRequest = ts.getChangedRequest( changedRequests );
		System.assertEquals( gFRS_Util.APPROVAL_BUSINESS_REV, refreshedRequest.Sub_Status__c, 'Setting without it being complete should set the status to business' );
    }
    
    static testMethod void approvalStatusBusinessOnlyComplete(){
    	TestSettings ts = new TestSettings();
		ts.setupCorporate();
		ts.setupApprovalFields( true, false, false );
		gFRS_Funding_Request__c[] newList = ts.getNewList();
		Map<Id,gFRS_Funding_Request__c> oldMap = ts.getOldMap();
		
		ts.request.Approval_Step__c = ts.makeStatus(true,false,false);
		
		gFRS_Funding_Request__c[] changedRequests =  gFRS_util.setApprovalOptionalStepStatus( ts.getNewList(), ts.getOldMap() );
		System.assertNotEquals( null, changedRequests, 'ChangedRequests must not return null' );
		
		gFRS_Funding_Request__c refreshedRequest = ts.getChangedRequest( changedRequests );
		System.assertEquals( ts.request.Sub_Status__c, refreshedRequest.Sub_Status__c, 'Even though business is set, it has been complete, so the status remains unchanged' );
    }
    
    static testMethod void approvalLegalOnly(){
    	TestSettings ts = new TestSettings();
		ts.setupCorporate();
		ts.setupApprovalFields( false, true, false );
		gFRS_Funding_Request__c[] newList = ts.getNewList();
		Map<Id,gFRS_Funding_Request__c> oldMap = ts.getOldMap();
		
		ts.request.Approval_Step__c = ts.makeStatus(false,false,false);
		
		gFRS_Funding_Request__c[] changedRequests =  gFRS_util.setApprovalOptionalStepStatus( ts.getNewList(), ts.getOldMap() );
		System.assertNotEquals( null, changedRequests, 'ChangedRequests must not return null' );
		
		gFRS_Funding_Request__c refreshedRequest = ts.getChangedRequest( changedRequests );
		System.assertEquals( gFRS_Util.APPROVAL_LEGAL_REV, refreshedRequest.Sub_Status__c, 'Setting legal without it being complete should set the status' );
    }
    
    static testMethod void approvalLegalOnlyComplete(){
    	TestSettings ts = new TestSettings();
		ts.setupCorporate();
		ts.setupApprovalFields( false, true, false );
		gFRS_Funding_Request__c[] newList = ts.getNewList();
		Map<Id,gFRS_Funding_Request__c> oldMap = ts.getOldMap();
		
		ts.request.Approval_Step__c = ts.makeStatus(false,true,false);
		
		gFRS_Funding_Request__c[] changedRequests =  gFRS_util.setApprovalOptionalStepStatus( ts.getNewList(), ts.getOldMap() );
		System.assertNotEquals( null, changedRequests, 'ChangedRequests must not return null' );
		
		gFRS_Funding_Request__c refreshedRequest = ts.getChangedRequest( changedRequests );
		System.assertEquals( ts.request.Sub_Status__c, refreshedRequest.Sub_Status__c, 'Even though legal is set, it has been complete, so the status remains unchanged' );
    }
    
    static testMethod void approvalBusinessAndLegal(){
    	TestSettings ts = new TestSettings();
		ts.setupCorporate();
		ts.setupApprovalFields( true, true, false );
		gFRS_Funding_Request__c[] newList = ts.getNewList();
		Map<Id,gFRS_Funding_Request__c> oldMap = ts.getOldMap();
		
		ts.request.Approval_Step__c = ts.makeStatus(false,false,false);
		
		gFRS_Funding_Request__c[] changedRequests =  gFRS_util.setApprovalOptionalStepStatus( ts.getNewList(), ts.getOldMap() );
		System.assertNotEquals( null, changedRequests, 'ChangedRequests must not return null' );
		
		gFRS_Funding_Request__c refreshedRequest = ts.getChangedRequest( changedRequests );
		System.assertEquals( gFRS_Util.APPROVAL_BUSINESS_REV, refreshedRequest.Sub_Status__c, 'Setting busines and legal without business being complete should set the status' );
    }
    
    static testMethod void approvalBusinesAndLegalComplete1(){
    	TestSettings ts = new TestSettings();
		ts.setupCorporate();
		ts.setupApprovalFields( true, true, false );
		gFRS_Funding_Request__c[] newList = ts.getNewList();
		Map<Id,gFRS_Funding_Request__c> oldMap = ts.getOldMap();
		
		ts.request.Approval_Step__c = ts.makeStatus(true,false,false);
		
		gFRS_Funding_Request__c[] changedRequests =  gFRS_util.setApprovalOptionalStepStatus( ts.getNewList(), ts.getOldMap() );
		System.assertNotEquals( null, changedRequests, 'ChangedRequests must not return null' );
		
		gFRS_Funding_Request__c refreshedRequest = ts.getChangedRequest( changedRequests );
		System.assertEquals( gFRS_Util.APPROVAL_LEGAL_REV, refreshedRequest.Sub_Status__c, 'Setting busines and legal without legal being complete should set the status' );
    }
    
    static testMethod void approvalBusinesAndLegalComplete2(){
    	TestSettings ts = new TestSettings();
		ts.setupCorporate();
		ts.setupApprovalFields( true, true, false );
		gFRS_Funding_Request__c[] newList = ts.getNewList();
		Map<Id,gFRS_Funding_Request__c> oldMap = ts.getOldMap();
		
		ts.request.Approval_Step__c = ts.makeStatus(true,true,false);
		
		gFRS_Funding_Request__c[] changedRequests =  gFRS_util.setApprovalOptionalStepStatus( ts.getNewList(), ts.getOldMap() );
		System.assertNotEquals( null, changedRequests, 'ChangedRequests must not return null' );
		
		gFRS_Funding_Request__c refreshedRequest = ts.getChangedRequest( changedRequests );
		System.assertEquals( ts.request.Sub_Status__c, refreshedRequest.Sub_Status__c, 'Setting busines and legal and both being complete leaves the status alone' );
    }
    
    static testMethod void approvalStatusApprovernly(){
    	TestSettings ts = new TestSettings();
		ts.setupHCChar();
		ts.setupApprovalFields( false,false,true );
		ts.refreshRequest();
		
		gFRS_Funding_Request__c[] newList = ts.getNewList();
		Map<Id,gFRS_Funding_Request__c> oldMap = ts.getOldMap();
		
		ts.request.Approval_Step__c = ts.makeStatus(false,false,false);
		
		gFRS_Funding_Request__c[] changedRequests =  gFRS_util.setApprovalOptionalStepStatus( ts.getNewList(), ts.getOldMap() );
		System.assertNotEquals( null, changedRequests, 'ChangedRequests must not return null' );
		
		gFRS_Funding_Request__c refreshedRequest = ts.getChangedRequest( changedRequests );
		System.assertEquals( gFRS_Util.APPROVAL_BUSINESS_APPROVER, refreshedRequest.Sub_Status__c, 'Approval is set and must set the status' );
    }
    
    static testMethod void approvalStatusApprovernlyComplete(){
    	TestSettings ts = new TestSettings();
		ts.setupHCChar();
		ts.setupApprovalFields( false,false,true );
		ts.refreshRequest();
		
		gFRS_Funding_Request__c[] newList = ts.getNewList();
		Map<Id,gFRS_Funding_Request__c> oldMap = ts.getOldMap();
		
		ts.request.Approval_Step__c = ts.makeStatus(false,false,true);
		
		gFRS_Funding_Request__c[] changedRequests =  gFRS_util.setApprovalOptionalStepStatus( ts.getNewList(), ts.getOldMap() );
		System.assertNotEquals( null, changedRequests, 'ChangedRequests must not return null' );
		
		gFRS_Funding_Request__c refreshedRequest = ts.getChangedRequest( changedRequests );
		System.assertEquals( ts.request.Sub_Status__c, refreshedRequest.Sub_Status__c, 'Approval is set but has been completed, so the status remains unchanged' );
    }
    
    /**
     * Test that the funding requests applied are set to 'SYS_Request_Approved__c' = YES'
     * (these are set asynchronously to avoid the workflow to workflow limitation with salesforce)
     **/
    static testMethod void approvingRequestSetsApprovalFlag(){
    	TestSettings ts = new TestSettings();
    	ts.setupIMED();
    	
    	//-- setup for the initial conditions before an approval is completed
    	gFRS_Funding_Request__c oldRequest = [ select id, Name, Status__c, Sub_Status__c, SYS_Request_Approved__c from gFRS_Funding_Request__c where id = :ts.request.id ];
    	oldRequest.Status__c = gFRS_Util.REQUEST_STATUS_DECISION;
    	oldRequest.SYS_Request_Approved__c = null;
    	
    	//-- make the change in status to mimic the success conditions of an approval process
    	gFRS_Funding_Request__c newRequest = [ select id, Name, Status__c, Sub_Status__c, SYS_Request_Approved__c from gFRS_Funding_Request__c where id = :oldRequest.id ];
    	newRequest.Status__c = gFRS_Util.REQUEST_STATUS_PRICESSING_DISPOSITION;
    	newRequest.Sub_Status__c = gFRS_Util.REQUEST_SUB_STATUS_WAITING_LOA;
    	newRequest.SYS_Request_Approved__c = null;
    	
    	//-- create the lists used below
    	gFRS_Funding_Request__c[] newList = new gFRS_Funding_Request__c[]{ newRequest };
    	Map<id,gFRS_Funding_Request__c> oldMap = new Map<id,gFRS_Funding_Request__c>();
    	oldMap.put( oldRequest.id, oldRequest );
    	
    	//-- run the trigger through the util to avoid issues in the trigger
    	Test.startTest();
    	gFRS_Util.transferApprovalSteps( newList, oldMap );
    	Test.stopTest();
    	
    	gFRS_Funding_Request__c refreshedRequest = [ select id, Name, Status__c, Sub_Status__c, SYS_Request_Approved__c from gFRS_Funding_Request__c where id = :oldRequest.id ];
    	System.assertEquals( gFRS_Util.YES, refreshedRequest.SYS_Request_Approved__c, 'the steps above should mimic the approval completion and mark the request as been approved');
    }
    
    /**
     *  Tests that the funding request approved flag is set through the trigger
     **/
    static testMethod void approvingRequestSetsApprovalFlagTrigger(){
    	TestSettings ts = new TestSettings();
    	ts.setupIMED();
    	
    	Test.startTest();
    	
    	//-- setup for the initial conditions before an approval is completed
    	gFRS_Funding_Request__c oldRequest = ts.request;
    	oldRequest.Status__c = gFRS_Util.REQUEST_STATUS_DECISION;
    	oldRequest.SYS_Request_Approved__c = null;
    	update oldRequest;
    	
    	//-- make the change in status to mimic the success conditions of an approval process
    	gFRS_Funding_Request__c newRequest = ts.request;
    	newRequest.Status__c = gFRS_Util.REQUEST_STATUS_PRICESSING_DISPOSITION;
    	newRequest.Sub_Status__c = gFRS_Util.REQUEST_SUB_STATUS_WAITING_LOA;
    	newRequest.SYS_Request_Approved__c = null;
    	update newRequest;
    	
    	Test.stopTest();
    	
    	gFRS_Funding_Request__c refreshedRequest = [ select id, Name, Status__c, Sub_Status__c, SYS_Request_Approved__c from gFRS_Funding_Request__c where id = :oldRequest.id ];
    	System.assertEquals( gFRS_Util.YES, refreshedRequest.SYS_Request_Approved__c, 'the steps above should mimic the approval completion and mark the request as been approved');
    	
    }
}