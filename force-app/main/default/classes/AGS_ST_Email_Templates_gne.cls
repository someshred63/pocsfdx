/** @date 6/25/2012
* @Author Pawel Sprysak
* @description Email Template Util Class
*/
public without sharing class AGS_ST_Email_Templates_gne  {
    public String name      { get; set; }
    public String subject   { get; set; }
    public String body      { get; set; }
    public String api_name  { get; set; }

    public String disputeFormOfPayment      { get; set; }
    public String disputeNatureOfPayment    { get; set; }
    public String disputeDrug               { get; set; }
    public String disputeAmount             { get; set; }

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Email Template Util Class Constructor
    * @param String disputeFormOfPayment
    * @param String disputeNatureOfPayment
    * @param String disputeDrug
    * @param String disputeAmount
    */
    public AGS_ST_Email_Templates_gne(String disputeFormOfPayment, String disputeNatureOfPayment, String disputeDrug, String disputeAmount) {
        this.disputeFormOfPayment   = ( 'null'.equals(disputeFormOfPayment)     ? '' : disputeFormOfPayment     );
        this.disputeNatureOfPayment = ( 'null'.equals(disputeNatureOfPayment)   ? '' : disputeNatureOfPayment   );
        this.disputeDrug            = ( 'null'.equals(disputeDrug)              ? '' : disputeDrug              );
        this.disputeAmount          = ( 'null'.equals(disputeAmount)            ? '' : disputeAmount            );
    }

    /** @date 6/25/2012
    * @Author Pawel Sprysak
    * @description Method for getting Email Templates
    * @param String disputeId
    * @return Map<String,AGS_ST_Email_Templates_gne>
    */
    public Map<String,AGS_ST_Email_Templates_gne> getEmailTemplates(String disputeId) {
        AGS_ST_DisputeManagement_gne__c orgDisputeDetails = AGS_ST_DbUtils.getDisputeDetailsByDisputeManagementId(disputeId);
        Map<String,AGS_ST_Email_Templates_gne> templates = new Map<String,AGS_ST_Email_Templates_gne>();

        // Request additional info
        AGS_ST_Email_Templates_gne templateAdditionalInfo = new AGS_ST_Email_Templates_gne('', '', '', '');
        templateAdditionalInfo.name = 'Request additional info';
        templateAdditionalInfo.api_name = 'Information';
        templateAdditionalInfo.subject = 'Request for additional information - Dispute ID ' + orgDisputeDetails.Name + '\n';
        templateAdditionalInfo.body = 'Dear Dr. ' + orgDisputeDetails.Dispute_List_gne__r.owner.LastName + ',\r\n\r\n';
        templateAdditionalInfo.body += 'We are researching Dispute ID ' + orgDisputeDetails.Name + ' and need some additional information to be able to resolve your dispute. Please reply to this email and provide the below information at your earliest convenience:\r\n\r\n';
        templateAdditionalInfo.body += 'Thank you,\r\n';
        templateAdditionalInfo.body += 'The Genentech Sunshine Help Desk Team\r\n';
        templates.put(templateAdditionalInfo.api_name, templateAdditionalInfo);

        AGS_ST_Email_Templates_gne resolveAndRemovedTempl = new AGS_ST_Email_Templates_gne('', '', '', '');
        resolveAndRemovedTempl.name = 'Resolved and Removed';
        resolveAndRemovedTempl.api_name = 'Resolved';
        resolveAndRemovedTempl.subject = 'Dispute resolved - Dispute ID ' + orgDisputeDetails.Name + '\n';
        resolveAndRemovedTempl.body = 'Dear Dr. '+ orgDisputeDetails.Dispute_List_gne__r.owner.LastName + ',\r\n\r\n';
        resolveAndRemovedTempl.body += 'Dispute ID ' + orgDisputeDetails.Name + ' has been resolved and the reportable value has been removed from your payments list.\r\n\r\n';
        resolveAndRemovedTempl.body += 'Thank you,\r\n';
        resolveAndRemovedTempl.body += 'The Genentech Sunshine Help Desk Team\r\n';
        templates.put(resolveAndRemovedTempl.api_name, resolveAndRemovedTempl);

        // Resolved without correction
        if( String.isBlank(disputeFormOfPayment) && String.isBlank(disputeNatureOfPayment) && String.isBlank(disputeDrug) && String.isBlank(disputeAmount) ) {
            AGS_ST_Email_Templates_gne templateResolve = new AGS_ST_Email_Templates_gne('', '', '', '');
            templateResolve.name = 'Resolve dispute';
            templateResolve.api_name = 'Resolution';
            templateResolve.subject = 'Dispute resolved - Dispute ID ' + orgDisputeDetails.Name + '\r\n\r\n';
            templateResolve.body =  'Dear Dr. ' + orgDisputeDetails.Dispute_List_gne__r.owner.LastName + ',\r\n\r\n';
            templateResolve.body += 'We have researched your dispute, Dispute ID ' + orgDisputeDetails.Name + ', and have concluded this transaction is correct; therefore we are closing this dispute without any revisions. If you have additional questions, please contact the Genentech Sunshine Help Desk at SunshineQuestions-d@gene.com or (877) 313-5778 between 8am and 5pm Pacific Time, Monday through Friday.\r\n\r\n';
            templateResolve.body += 'Thank you,\r\n';
            templateResolve.body += 'The Genentech Sunshine Help Desk Team\r\n';
            templates.put(templateResolve.api_name, templateResolve);
        // Resolved with correction
        } else {
            AGS_ST_Email_Templates_gne templateResolve = new AGS_ST_Email_Templates_gne('', '', '', '');
            templateResolve.name = 'Resolve dispute';
            templateResolve.api_name = 'Resolution';
            templateResolve.subject = 'Dispute resolved - Dispute ID ' + orgDisputeDetails.Name + '\r\n\r\n';
            templateResolve.body =  'Dear Dr. ' + orgDisputeDetails.Dispute_List_gne__r.owner.LastName + ',\r\n\r\n';
            templateResolve.body += 'We have corrected the data associated with Dispute ID ' + orgDisputeDetails.Name + ' and this dispute is now resolved. You should see the change reflected on Sunshine Track.\r\n\r\n';
            templateResolve.body += 'Resolution details:\r\n';
            templateResolve.body += 'Amount: ' + disputeAmount + '\r\n';
            templateResolve.body += 'Form of Payment: ' + disputeFormOfPayment + '\r\n';
            templateResolve.body += 'Nature of Payment: ' + disputeNatureOfPayment + '\r\n';
            templateResolve.body += 'Brand:   ' + disputeDrug + '\r\n\r\n';
            templateResolve.body += 'Thank you,\r\n';
            templateResolve.body += 'The Genentech Sunshine Help Desk Team\r\n';
            templates.put(templateResolve.api_name, templateResolve);
        }
        return templates;
    }
}