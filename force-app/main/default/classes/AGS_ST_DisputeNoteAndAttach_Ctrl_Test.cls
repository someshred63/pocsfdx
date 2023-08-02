/** @date 3/14/2014
* @Author Konrad Malinowski
* @description Test Class for AGS Sunshine Track Dispute Note And Attachment Extension Controller
*/
@isTest
private class AGS_ST_DisputeNoteAndAttach_Ctrl_Test {
    /** @date 3/14/2014
    * @Author Konrad Malinowski
    * @description Test Method - Test for deleteAttachments() method
    */
    @isTest static void shouldDeleteAttachments() {
        // GIVEN
        AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
        AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
        AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
        String disputeInternalStatus = 'In Progress';
        AGS_ST_DisputeManagement_gne__c dispute = AGS_ST_TestUtils.createDispute(agsTransaction, disputeInternalStatus);
        List<AGS_ST_Dispute_Note_and_Attachment_gne__c> disputeNoteAndAttachments = AGS_ST_TestUtils.createDisputeNoteAndAttachments(dispute);
        AGS_ST_Dispute_Note_and_Attachment_gne__c dna = disputeNoteAndAttachments[0];
        List<Attachment> attachs = AGS_ST_TestUtils.createAttachmentsForDistputes(
            new List<AGS_ST_Dispute_Note_and_Attachment_gne__c>{ dna, dna }
        );

        ApexPages.currentPage().getParameters().put('id', dispute.Id);
        ApexPages.currentPage().getParameters().put('dnaId', dna.Id);
        AGS_ST_DisputeNoteAndAttach_Controller ctrl = new AGS_ST_DisputeNoteAndAttach_Controller();
        System.assertEquals( 2, [SELECT COUNT() FROM Attachment WHERE ParentId = :dna.Id] );
        ctrl.disputeAttachments[0].isSelected = true;
        ctrl.disputeAttachments[1].isSelected = false;

        // WHEN
        ctrl.deleteAttachments();

        // THEN
        System.assert( String.isNotBlank(ctrl.actionMessages) );
        System.assert( ctrl.actionMessages.contains('Attachment has been deleted') );
        System.assertEquals( 1, [SELECT COUNT() FROM Attachment WHERE ParentId = :dna.Id] );
    }

    /** @date 3/14/2014
    * @Author Konrad Malinowski
    * @description Test Method - Test for getting other User's Attachments
    */
    @isTest static void shouldNotBeOwner() {
        // GIVEN
        User ccoAnalyst = AGS_ST_TestUtils.createCcoAnalystUser('aggstestuserdisputedetail@gene.com');
        AGS_ST_DisputeManagement_gne__c dispute;
        AGS_ST_Dispute_Note_and_Attachment_gne__c dna;
        System.runAs(ccoAnalyst) {
            AGS_CCO_Case_Recipient_gne__c recipient = AGS_ST_TestUtils.createSpendRecipient();
            AGS_Recipient_License_State_gne__c recipientLicenseState = AGS_ST_TestUtils.createRecipientLicenseState(recipient);
            AGS_Spend_Expense_Transaction_gne__c agsTransaction = AGS_ST_TestUtils.createSpendExpenseTrans(recipient);
            String disputeInternalStatus = 'In Progress';
            dispute = AGS_ST_TestUtils.createDispute(agsTransaction, disputeInternalStatus);
            List<AGS_ST_Dispute_Note_and_Attachment_gne__c> disputeNoteAndAttachments = AGS_ST_TestUtils.createDisputeNoteAndAttachments(dispute);
            dna = disputeNoteAndAttachments[0];
            dna.Communication_Method_gne__c = 'Email';
            update dna;
            List<Attachment> attachs = AGS_ST_TestUtils.createAttachmentsForDistputes(disputeNoteAndAttachments);
        }
        
        // WHEN
        ApexPages.currentPage().getParameters().put('id', dispute.Id);
        ApexPages.currentPage().getParameters().put('dnaId', dna.Id);
        AGS_ST_DisputeNoteAndAttach_Controller ctrl = new AGS_ST_DisputeNoteAndAttach_Controller();

        // THEN
        System.assert( !ctrl.isOwner );
        System.assertNotEquals( null, ctrl.backToDisputeDetail() );
    }
}