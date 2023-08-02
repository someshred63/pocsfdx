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
private class gFRS_SampleTemplateControllerTest {

class TestSettings {
    
    //-- lookup constants
    
    //-- test variables
    gFRS_SampleTemplateController controller;
    
    public Account acct;
    public GFRS_Organization__c org;
    public GFRS_Funding_Request__c request;
    public String PROF_GFRS_USER_NAME = 'GNE-GFRS-User';
    public id PROF_GFRS_USER;
    public  String DEFAULT_STATUS = 'Intake';
    public  String DEFAULT_SUB_STATUS = 'Not Submitted';
    public  Integer NUM = 2;
    
    public TestSettings(){
    }
    
    public void setup1(){
        PROF_GFRS_USER = [ select Id, Name, Type from Profile where Name =:PROF_GFRS_USER_NAME limit 1 ].Id;
        this.acct = gFRS_TestCreationUtils.createAccount('test');
        insert this.acct;
        
        this.org = gFRS_TestCreationUtils.createOrganization('223344556', this.acct);
        insert this.org;
        
        this.request = gFRS_TestCreationUtils.createFundingRequest(gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS , DEFAULT_STATUS, DEFAULT_SUB_STATUS, DEFAULT_SUB_STATUS, '', this.org.Id, null);
        this.request.Funding_Sub_Type__c = 'Exhibit Booth';
        insert this.request;
    }
    
    public void getController( String getVars ){
        ApexPages.PageReference ref = new ApexPages.PageReference( '/' + getVars );
        Test.setCurrentPageReference( ref );
        this.controller = new gFRS_SampleTemplateController( new ApexPages.StandardController( this.request ) );
    }
}

static testMethod void testGettingCaseConditions(){
    TestSettings ts = new TestSettings();
    ts.setup1();
    ts.getController( '?case=1' );
    System.assertEquals( '1', ts.controller.caseCondition, 'Sending case=1 as get variables, should match the case condition' );
}
}