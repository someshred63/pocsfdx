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
private class gFRS_OrganizationAccmeAssociationTester {

    static final String FOUND_TAX_ID = '88-888888';
    static final String FOUND_TAX_ID2 = '213442';
    static final String NOT_FOUND_TAX_ID = '2210';

    static final String ACCREDITED = 'Accreditation';

    /**
     *  Internal Testing class that takes care of setup and tear downs.
     **/
    class TestSettings {
        //-- instance variables
        public Account account;
        public gFRS_Organization__c foundOrg;
        public gFRS_Organization__c notFoundOrg;
        public gFRS_ACCME__c[] accmeAccreditations;

        public TestSettings() {
            //-- initialization done for ALL SETUPs done here
            this.accmeAccreditations = new gFRS_ACCME__c[]{
                    gFRS_TestCreationUtils.createAccmeAccreditation(FOUND_TAX_ID, ACCREDITED),
                    gFRS_TestCreationUtils.createAccmeAccreditation(FOUND_TAX_ID2, ACCREDITED)
            };
            insert this.accmeAccreditations;

            this.account = gFRS_TestCreationUtils.createAccount(gFRS_TestCreationUtils.makeUnique('acct'));
            insert this.account;

            this.foundOrg = gFRS_TestCreationUtils.createOrganization2(FOUND_TAX_ID, this.account.id);
            insert this.foundOrg;

            this.notFoundOrg = gFRS_TestCreationUtils.createOrganization2(NOT_FOUND_TAX_ID, this.account.id);
            insert this.notFoundOrg;

        }
    }

    static testMethod void testSettingsSetsUpWithoutErrors() {
        try {
            TestSettings ts = new TestSettings();
            //ts.setupA(); //-- perform specialized setup if needed
        } catch (Exception err) {
            System.assert(false, 'TestSetting/Setup must not throw any exceptions');
        }
    }

    static testMethod void testOrganizationAssignAccreditation() {
        if (isTriggerIsEnabled()) {
            TestSettings ts = new TestSettings();
            gFRS_Organization__c foundOrg = [select id, ACCME_Accreditations__c from gFRS_Organization__c where id = :ts.foundOrg.id limit 1];
            System.debug('foundOrg ' + foundOrg);
            System.assertEquals(ACCREDITED, foundOrg.ACCME_Accreditations__c, 'because the org has the correct Tax id, it must have the matched accreditation');
        }
    }

    static testMethod void testOrganizationIfNotMatched() {
        if (isTriggerIsEnabled()) {
            TestSettings ts = new TestSettings();
            gFRS_Organization__c notFoundOrg = [select id, ACCME_Accreditations__c from gFRS_Organization__c where id = :ts.notFoundOrg.id limit 1];
            System.assertNotEquals(ACCREDITED, notFoundOrg.ACCME_Accreditations__c, 'because the org has DOES NOT have the correct Tax id, it must not be accredited');
        }
    }

    static testMethod void testOrganizationChanged() {
        if (isTriggerIsEnabled()) {
            TestSettings ts = new TestSettings();

            gFRS_Organization__c notFoundOrg = [select id, ACCME_Accreditations__c from gFRS_Organization__c where id = :ts.notFoundOrg.id limit 1];
            System.assertNotEquals(ACCREDITED, notFoundOrg.ACCME_Accreditations__c, 'because the org has DOES NOT have the correct Tax id, it must not be accredited');

            ts.notFoundOrg.Tax_Id__c = FOUND_TAX_ID2;
            update ts.notFoundOrg;

            gFRS_Organization__c foundOrg = [select id, ACCME_Accreditations__c from gFRS_Organization__c where id = :ts.foundOrg.id limit 1];
            System.debug('foundOrg2 ' + foundOrg);
            System.assertEquals(ACCREDITED, foundOrg.ACCME_Accreditations__c, 'because the org has the correct Tax id, it must have the matched accreditation');
        }
    }

    static Boolean isTriggerIsEnabled() {
        ApexTrigger defaultTrigger = [Select Id, Status from ApexTrigger where name = 'gFRS_OrganizationAccmeAssociation'];
        if (defaultTrigger.Status == 'Inactive') {
            return false;
        }
        return true;
    }
}