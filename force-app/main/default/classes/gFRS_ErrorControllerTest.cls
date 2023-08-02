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
private class gFRS_ErrorControllerTest {
	
	static final String ERROR_MSG_BLACKLIST = 'blacklist';
	static final String ERROR_MSG_INVALID_REQUEST = 'invalid';

    /**
     *  Internal Testing class that takes care of setup and tear downs.
     **/
    class TestSettings {
    	
    	//-- instance variables
    	ApexPages.PageReference pageRef;
    	gFRS_ErrorController controller;
    	
    	GFRS_Content__c[] content;
    	GFRS_Content_Translation__c[] contentTranslations;
    	
    	public TestSettings(){
    		//-- initialization done for ALL SETUPs done here
    		
    		gFRS_Content__c[] contentToRemove = new gFRS_Content__c[]{};
    		for( gFRS_Content__c content : [ select id from gFRS_Content__c ]){
    			contentToRemove.add( content );
    		}
    		delete contentToRemove;
    		
    		content = new GFRS_Content__c[]{
				gFRS_TestCreationUtils.createContent( 'WEB 201 Internal', null, gFRS_ErrorController.CONTENT_TYPE ),
				gFRS_TestCreationUtils.createContent( 'WEB 301 External', null, gFRS_ErrorController.CONTENT_TYPE ),
				gFRS_TestCreationUtils.createContent( 'WEB 201 External', null, gFRS_ErrorController.CONTENT_TYPE ),
				gFRS_TestCreationUtils.createContent( 'WEB 202A External', null, gFRS_ErrorController.CONTENT_TYPE ),
				gFRS_TestCreationUtils.createContent( 'WEB 202B External', null, gFRS_ErrorController.CONTENT_TYPE ),
				gFRS_TestCreationUtils.createContent( 'WEB 203 Internal', null, gFRS_ErrorController.CONTENT_TYPE ),
				gFRS_TestCreationUtils.createContent( 'WEB 203 External', null, gFRS_ErrorController.CONTENT_TYPE ),
				gFRS_TestCreationUtils.createContent( 'WEB 401 External', null, gFRS_ErrorController.CONTENT_TYPE )
			};
			insert content;
			
			this.contentTranslations = new GFRS_Content_Translation__c[]{
				gFRS_TestCreationUtils.createContentTranslation( content[0], ERROR_MSG_BLACKLIST, null, gFRS_TestCreationUtils.LANG_EN ),
				gFRS_TestCreationUtils.createContentTranslation( content[1], ERROR_MSG_INVALID_REQUEST, null, gFRS_TestCreationUtils.LANG_EN ),
				gFRS_TestCreationUtils.createContentTranslation( content[2], ERROR_MSG_INVALID_REQUEST, null, gFRS_TestCreationUtils.LANG_EN ),
				gFRS_TestCreationUtils.createContentTranslation( content[3], ERROR_MSG_INVALID_REQUEST, null, gFRS_TestCreationUtils.LANG_EN ),
				gFRS_TestCreationUtils.createContentTranslation( content[4], ERROR_MSG_INVALID_REQUEST, null, gFRS_TestCreationUtils.LANG_EN ),
				gFRS_TestCreationUtils.createContentTranslation( content[5], ERROR_MSG_INVALID_REQUEST, null, gFRS_TestCreationUtils.LANG_EN ),
				gFRS_TestCreationUtils.createContentTranslation( content[6], ERROR_MSG_INVALID_REQUEST, null, gFRS_TestCreationUtils.LANG_EN ),
				gFRS_TestCreationUtils.createContentTranslation( content[7], ERROR_MSG_INVALID_REQUEST, null, gFRS_TestCreationUtils.LANG_EN )
			};
			insert this.contentTranslations;
    	}
    	
    	public void sentNoErrorCode(){
    		//-- specialized setup done here
    		this.pageRef = new ApexPages.PageReference( '/apex/gFRS_ErrorPage' );
    	}
    	
    	public void sendBlacklistCode(){
    		this.pageRef = new ApexPages.PageReference( '/apex/gFRS_ErrorPage?' + gFRS_ErrorController.PARAM_ERROR_CODE + '=' + gFRS_ErrorController.CODE_BLACKLIST );
    	}
    	
    	public void sendInvalidFundingRequest(){
    		this.pageRef = new ApexPages.PageReference( '/apex/gFRS_ErrorPage?' + gFRS_ErrorController.PARAM_ERROR_CODE + '=' + gFRS_ErrorController.CODE_INV_FUND );
    	}
    	
    	public void sendInvalidFundingRequest202A(){
    		this.pageRef = new ApexPages.PageReference( '/apex/gFRS_ErrorPage?' + gFRS_ErrorController.PARAM_ERROR_CODE + '=' + gFRS_ErrorController.CODE_RECONCILIATION_DUE );
    	}
    	
    	public void sendInvalidFundingRequest202B(){
    		this.pageRef = new ApexPages.PageReference( '/apex/gFRS_ErrorPage?' + gFRS_ErrorController.PARAM_ERROR_CODE + '=' + gFRS_ErrorController.CODE_REFUND_DUE );
    	}
    	
    	public void sendInvalidFundingRequest203(){
    		this.pageRef = new ApexPages.PageReference( '/apex/gFRS_ErrorPage?' + gFRS_ErrorController.PARAM_ERROR_CODE + '=' + gFRS_ErrorController.CODE_INV_ORG );
    	}
    	
    	public void sendInvalidFundingRequest401(){
    		this.pageRef = new ApexPages.PageReference( '/apex/gFRS_ErrorPage?' + gFRS_ErrorController.PARAM_ERROR_CODE + '=' + gFRS_ErrorController.CODE_FIREWALL );
    	}
    	
    	public void setupController(){
    		Test.setCurrentPage( this.pageRef );
    		System.debug( 'currentPage:' + this.pageRef + '; 2:' + Apexpages.currentPage() );
    		System.debug( 'params:' + ApexPages.currentPage().getParameters() + ']' );
    		this.controller = new gFRS_ErrorController();
    	}
    }
    
    static testMethod void testSettingsSetsUpWithoutErrors(){
    	try {
	    	TestSettings ts = new TestSettings();
    		ts.sentNoErrorCode();
    		ts.setupController();
    		
    	} catch( Exception err ){
    		System.assert( false, 'TestSetting/Setup must not throw any exceptions' );
    	}
    }
    
    static testMethod void testSendBlacklist(){
    	TestSettings ts = new TestSettings();
		ts.sendBlacklistCode();
		ts.setupController();
		
		System.assertEquals( ERROR_MSG_BLACKLIST, ts.controller.errorMessage, 'because we sent the blacklist flag, we should get the blacklist error message' );
    }
    
    static testMethod void testSendInvalidRequest(){
    	TestSettings ts = new TestSettings();
		ts.sendInvalidFundingRequest();
		ts.setupController();
		
		System.assertEquals( ERROR_MSG_INVALID_REQUEST, ts.controller.errorMessage, 'because we sent the invalid request flag, we should get the invalid request error message' );
    }
    
    static testMethod void testErrorCodes(){
    	TestSettings ts = new TestSettings();
		ts.sendInvalidFundingRequest202A();
		ts.setupController();
				
		System.assertEquals( ERROR_MSG_INVALID_REQUEST, ts.controller.errorMessage);
		
		ts.sendInvalidFundingRequest202B();
		ts.setupController();
				
		System.assertEquals( ERROR_MSG_INVALID_REQUEST, ts.controller.errorMessage);
		
		ts.sendInvalidFundingRequest203();
		ts.setupController();
				
		System.assertEquals( ERROR_MSG_INVALID_REQUEST, ts.controller.errorMessage);
		
		ts.sendInvalidFundingRequest401();
		ts.setupController();
				
		System.assertEquals( ERROR_MSG_INVALID_REQUEST, ts.controller.errorMessage);
    }
}