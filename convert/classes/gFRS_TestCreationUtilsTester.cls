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
private class gFRS_TestCreationUtilsTester {


static testMethod void createAccountMustNotThrowError(){
    try {
        Account acct = gFRS_TestCreationUtils.createAccount( gFRS_TestCreationUtils.makeUnique( 'test' ));
        //insert acct;
    } catch( Exception err ){
        System.assert( false, 'Exception must not be thrown when creationg accounts' + err.getMessage() );
    }
}

static testMethod void createOrganizationMustNotThrowError(){
    try {
        Account acct = gFRS_TestCreationUtils.createAccount( gFRS_TestCreationUtils.makeUnique( 'test' ));
        GFRS_Organization__c org = gFRS_TestCreationUtils.createOrganization( '201102', acct );
        //insert org;
    } catch( Exception err ){
        System.assert( false, 'Exception must not be thrown when creationg Organizations' + err.getMessage() );
    }
}

static testMethod void createLocationMustNotThrowError(){
    try {
        Account acct = gFRS_TestCreationUtils.createAccount( gFRS_TestCreationUtils.makeUnique( 'acct' ));
        insert acct;
        GFRS_Organization__c organization = gFRS_TestCreationUtils.createOrganization2( gFRS_TestCreationUtils.makeUnique( 'org'), acct.id );
        insert organization;
        GFRS_Location__c location = gFRS_TestCreationUtils.createLocation( gFRS_TestCreationUtils.makeUnique('loc'), organization.id );
        insert location;
    } catch( Exception err ){
        System.assert( false, 'Exception must not be thrown when creationg Funding Requests' + err.getMessage() );
    }
}

static testMethod void createFundingRequestMustNotThrowError(){
    try {
        Account acct = gFRS_TestCreationUtils.createAccount( gFRS_TestCreationUtils.makeUnique( 'acct' ));
        insert acct;
        GFRS_Organization__c organization = gFRS_TestCreationUtils.createOrganization2( gFRS_TestCreationUtils.makeUnique( 'org'), acct.id );
        insert organization;
        GFRS_Location__c location = gFRS_TestCreationUtils.createLocation( gFRS_TestCreationUtils.makeUnique('loc'), organization.id );
        insert location;
        GFRS_Funding_Request__c request = gFRS_TestCreationUtils.createFundingRequest2( gFRS_TestCreationUtils.RT_FR_IMED, 'Intake', 'Not Submitted', 'Not Submitted', '', organization.id, location.id );
        insert request;
    } catch( Exception err ){
        System.assert( false, 'Exception must not be thrown when creationg Funding Requests' + err.getMessage() );
    }
}

static testMethod void createFundingRequestWithTAMustNotThrowError(){
   /* try {
        Account acct = gFRS_TestCreationUtils.createAccount( gFRS_TestCreationUtils.makeUnique( 'acct' ));
        insert acct;
        GFRS_Organization__c organization = gFRS_TestCreationUtils.createOrganization2( gFRS_TestCreationUtils.makeUnique( 'org'), acct.id );
        insert organization;
        GFRS_Location__c location = gFRS_TestCreationUtils.createLocation( gFRS_TestCreationUtils.makeUnique('loc'), organization.id );
        insert location;
        GFRS_Funding_Request__c request = gFRS_TestCreationUtils.createFundingRequestWithTA( gFRS_TestCreationUtils.RT_FR_IMED, 'Intake', 'Not Submitted', 'Not Submitted','Breast Cancer', '', organization.id, location.id );
        insert request;
    } catch( Exception err ){
        System.assert( false, 'Exception must not be thrown when creationg Funding Requests with TA' + err.getMessage() );
    }*/
}

static testMethod void createWbsCode(){
    try {
        GFRS_WBS_Codes__c wbsCode = gFRS_TestCreationUtils.createWBSCode( '21011.11', 'Arthritis', 'IMED' );
        insert wbsCode;
    } catch( Exception err ){
        System.assert( false, 'Exception must not be thrown when creating WBS Codes' + err.getMessage() );
    }
}

static testMethod void createWbsCode2(){
    try {
        GFRS_WBS_Codes__c wbsCode = gFRS_TestCreationUtils.createWBSCode2( '21011.11', 'Arthritis', 'IMED', DateTime.newInstance( 2000, 01, 01 ), DateTime.newInstance( 2000, 01, 01 ) );
        insert wbsCode;
    } catch( Exception err ){
        System.assert( false, 'Exception must not be thrown when creating WBS Codes' + err.getMessage() );
    }
}

static testMethod void createAdminBudget(){
    try {
        GFRS_Administrative_Budget__c adminBudget = gFRS_TestCreationUtils.createAdminBudget( Date.today(), null );
        insert adminBudget;
    } catch( Exception err ){
        System.assert( false, 'Exception must not be thrown when creating admin budget' + err.getMessage() );
    }
}

static testMethod void createAdminBudgetWithAdminBudgetName(){
    try {
        GFRS_Administrative_Budget__c adminBudget = gFRS_TestCreationUtils.createAdminBudget( Date.today(), 'AdminBudgetName' );
        insert adminBudget;
    } catch( Exception err ){
        System.assert( false, 'Exception must not be thrown when creating admin budget' + err.getMessage() );
    }
}
static testMethod void createAdminBudgetLI(){
    try {
        GFRS_Administrative_Budget__c adminBudget = gFRS_TestCreationUtils.createAdminBudget( Date.today(), null );
        insert adminBudget;
        GFRS_Administrative_Budget_Line_Item__c adminBudgetLI = gFRS_TestCreationUtils.createAdminBudgetLI( '2010.01', 201.01, adminBudget.id );
        insert adminBudgetLI;
    } catch( Exception err ){
        System.assert( false, 'Exception must not be thrown when creating admin budget' + err.getMessage() );
    }
}

/*
static testMethod void createUser(){
    try {
        User u = gFRS_TestCreationUtils.createUser3( 'first','last', 'test@domain.com', gFRS_TestCreationUtils.PROF_GFRS_PORTAL, '1234' );
        insert u;
    } catch( Exception err ){
        System.assert( false, 'exception must not be thrown when creating test users:' + err.getMessage() );
    }
}
*/

}