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
@IsTest
private class AGS_ST_SourceTransactionExtensionTest {

    @IsTest
    static void testSourceTransactionShouldBeRetrieved() {
        // given
        final AGS_Spend_Expense_Transaction_gne__c txn = new AGS_Spend_Expense_Transaction_gne__c();
        insert txn;
        final AGS_Source_Transaction__c srcTxn = new AGS_Source_Transaction__c(
                AGS_Spend_Expense_Transaction__c = txn.Id,
                PTY2_Name_gne__c = 'PTY2 Unit Test Name',
                PTY1_Credential_gne__c = 'NA'
        );
        insert srcTxn;
        final ApexPages.StandardController stdCtrl = new ApexPages.StandardController(txn);
        // when
        Test.startTest();
        final AGS_ST_SourceTransactionExtension extUnderTest = new AGS_ST_SourceTransactionExtension(stdCtrl);
        List<AGS_FormRawWrapper> primaryRecipientFormData = extUnderTest.getPrimaryRecipientFormData();
        List<AGS_FormRawWrapper> relatedRecipientFormData = extUnderTest.getRelatedRecipientFormData();

        Test.stopTest();
        // then
        System.assertEquals(true, extUnderTest.isPrimaryRecipientBlank);
        System.assertEquals(false, extUnderTest.isRelatedRecipientBlank);
        System.assertEquals(primaryRecipientFormData.size(), relatedRecipientFormData.size());
        System.assertEquals(srcTxn.Id, extUnderTest.srcTxnId, extUnderTest.sourceTxn);
        System.assertEquals(txn.Id, extUnderTest.sourceTxn.AGS_Spend_Expense_Transaction__r.Id, extUnderTest.sourceTxn);
    }
}