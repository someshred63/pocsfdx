/**
 * Email services are automated processes that use Apex classes
 * to process the contents, headers, and attachments of inbound
 * email.
 */
global class gFRS_Ltng_CreateCustInRecFrmEmail implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,
    Messaging.InboundEnvelope envelope) {

        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();

		
			gFRS_Ltng_Customer_Intraction__c c = new gFRS_Ltng_Customer_Intraction__c();
            c.Subject__c=email.subject;
			c.Email_Body__c = email.plainTextBody;
            c.Email__c=email.fromAddress;
            c.Status__c='New';
            c.RecordTypeId=Schema.SObjectType.gFRS_Ltng_Customer_Intraction__c.getRecordTypeInfosByName().get('Customer Interaction Email').getRecordTypeId();
			insert c;

	result.success = true;
        return result;
    }

    
}