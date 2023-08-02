/**
 * @author GFRS Dev Team
 * @date 17/04/2018
 * @description Global email service class to handle emails sent to gFRS_ChangeApprover email service.
 *                  Emails contains parameters like action, record id and new approver user id.
 *                  After parameters deserialization from email gFRS_Util_NoShare.forceReassignApprover method is invoked
 *                  by Admin user (set in email service context user).
 *
 *                  To use this class email service gFRS_ChangeApprover needs to be configured manually.
 *                  Context user needs to be gFRS Admin.
 */

global without sharing class GFRS_ChangeApproverService implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail inboundEmail, Messaging.InboundEnvelope inboundEnvelope) {
        Messaging.InboundEmailResult inboundEmailResult = new Messaging.InboundEmailResult();
        Map<String, Object> parametersMap = new Map<String, Object>();

        try {
            parametersMap = (Map<String, Object>) JSON.deserializeUntyped(inboundEmail.plainTextBody);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error handling email service and deserialization. Exception :' + e.getMessage());
        }

        try {
            String action = (String) parametersMap.get('Action');
            String requestId = (String) parametersMap.get('RecordId');
            String newApproverId = (String) parametersMap.get('ApproverId');
            if (!String.isBlank(requestId) || !String.isBlank(newApproverId) || (!String.isBlank(action) && action.equals('Reassign'))) {
                gFRS_Util_NoShare.forceReassignApprover(requestId, newApproverId);
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error handling approver change. Exception :' + e.getMessage());
        }

        return inboundEmailResult;
    }

    global static Boolean changeApprovalAction(Id requestId, Id newApproverId) {
        Map<String, Object> parametersMap = new Map<String, Object>{
                'Action' => 'Reassign',
                'RecordId' => requestId,
                'ApproverId' => newApproverId
        };

        try {
            EmailServicesAddress emailServicesAddress = getEmailServicesAddress();
            Messaging.SingleEmailMessage message = generateMessage(emailServicesAddress, 'Change approver', parametersMap);

            Messaging.SendEmailResult[] results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{
                    message
            });

            if (results[0].success) {
                System.debug(LoggingLevel.DEBUG, 'Send email to change approver.');
                return true;
            }
            System.debug(LoggingLevel.ERROR, 'Got error sending email to change approver.');
            return false;
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error getting email service. Exception : ' + e.getMessage());
        }
        return false;
    }

    private static EmailServicesAddress getEmailServicesAddress() {
        List<EmailServicesAddress> emailServicesAddresses = [
                SELECT SystemModstamp, RunAsUserId, LocalPart, IsActive, FunctionId, EmailDomainName, AuthorizedSenders
                FROM EmailServicesAddress
                WHERE IsActive = true
                AND LocalPart LIKE 'gFRS_ChangeApprover'
        ];
        return emailServicesAddresses.size() == 1 ? emailServicesAddresses.get(0) : null;
    }

    private static Messaging.SingleEmailMessage generateMessage(EmailServicesAddress emailServicesAddress, String subject, Map<String, Object> parametersMap) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[]{
                emailServicesAddress.LocalPart + '@' + emailServicesAddress.EmailDomainName
        };
        message.setSubject(subject);
        message.plainTextBody = JSON.serialize(parametersMap);
        return message;
    }
}