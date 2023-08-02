public class EMS_DebugTools {

    private String errorLog = '';
    private String sendToEmail = '';
    private String comment = '';


	/** Constructor **/
    public EMS_DebugTools(String sendTo) {
        sendToEmail = sendTo;
    }

    public void addComment(String comment) {
        this.comment = comment;
    }

    public void addDebugMsg(String debugString) {
        errorLog += debugString + '\n\n';

    }

	/**** Action Methods ****/

    // Send debug info by email
    public void sendDebugMessages() {
        sendEmail('Debug messages.', errorLog, null);
    }


    // Limits summary
    public void sendLimitsUsage() {
        String emailContent = comment + '\n' + 'LIMITS USED \n';

        emailContent += '######## DATABASE ##########';
        emailContent += 'Number of SOQL queries: ' + Limits.getQueries() + ' out of ' + Limits.getLimitQueries() + '\n';
        emailContent += 'Number of query rows: ' + Limits.getQueryRows() + ' out of ' + Limits.getLimitQueryRows() + '\n';
        emailContent += 'Number of SOSL queries: ' + Limits.getSoslQueries() + ' out of ' + Limits.getLimitSoslQueries() + '\n';
        emailContent += 'Number of DML statements: ' + Limits.getDMLStatements() + ' out of ' + Limits.getLimitDMLStatements() + '\n';
        emailContent += 'Number of DML rows: ' + Limits.getDMLRows() + ' out of ' + Limits.getLimitDMLRows() + '\n';
        emailContent += '######## SYSTEM #############';
        emailContent += 'Maximum CPU time: ' + Limits.getCpuTime() + ' out of ' + Limits.getLimitCpuTime() + '\n';
        emailContent += 'Maximum heap size: ' + Limits.getHeapSize() + ' out of ' + Limits.getLimitHeapSize() + '\n';
        emailContent += 'Number of callouts: ' + Limits.getCallouts() + ' out of ' + Limits.getLimitCallouts() + '\n';
        emailContent += 'Email Invocations: ' + (Limits.getEmailInvocations() + 1) + ' out of ' + Limits.getLimitEmailInvocations() + '\n'; // +1 as additioonal email with this summary will be send
        emailContent += '######### SCHEMA ############';
        emailContent += 'fields describes: ' + Limits.getFieldsDescribes() + ' out of ' + Limits.getLimitFieldsDescribes() + '\n';
        emailContent += 'record type describes: ' + Limits.getRecordTypesDescribes() + ' out of ' + Limits.getLimitRecordTypesDescribes() + '\n';
        emailContent += 'child relationships describes: ' + Limits.getChildRelationshipsDescribes() + ' out of ' + Limits.getLimitChildRelationshipsDescribes() + '\n';
        emailContent += 'picklist describes: ' + Limits.getPicklistDescribes() + ' out of ' + Limits.getLimitPicklistDescribes() + '\n';
        emailContent += 'future calls: ' + Limits.getFutureCalls() + ' out of ' + Limits.getLimitFutureCalls() + '\n';
        //emailContent += '' + Limits. + ' out of ' + Limits + '\n';
        //emailContent += '' + Limits. + ' out of ' + Limits + '\n';

        sendEmail('Limits usage.', emailContent, null);
		
		/*
		getAggregateQueries() 
		getFieldSetsDescribes() 
		getFindSimilarCalls() 
		getLimitAggregateQueries() 
		getLimitFieldSetsDescribes() 
		getLimitFindSimilarCalls()
		getLimitQueryLocatorRows() 
		getLimitRunAs() 
		getLimitSavepointRollbacks() 
		getLimitSavepoints() 
		getLimitScriptStatements() 
		getQueryLocatorRows() 
		getRunAs() 
		getSavepointRollbacks() 
		getSavepoints() 
		getScriptStatements() 
		 */
    }

    // Send List to email.
    public List<Messaging.SendEmailResult> sendCollectionToEmail(List<Object> listToSend, String sendTo) {

        List<String> toAddresses = new List<String>{
                sendTo
        };
        String objectName = String.valueOf(listToSend[0]).substringBefore(':');
        String headerRow = String.valueOf(listToSend[0]).replace(objectName + ':{', '').replaceAll('=\\w+,? ?', ';').replace('}', '') + '\r\n';
        String csvContent = headerRow;
        String csvFileName = 'Debug-' + objectName + '.csv';
        String subject = 'Debug CSV';
        String plainTextBody = 'Debug Message with attached CSV.';

        for (Object o : listToSend) {
            csvContent += String.valueOf(o).replaceFirst(objectName + ':', '').replace('{', '').replace('}', '').replaceAll('[a-zA-Z_]+=', '').replaceAll(', ', ';') + ';' + '\r\n'; // TO DO: Text fields may be corrupted by replace of ', '.
        }

        // Create Attachement
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        csvAttc.setFileName(csvFileName);
        csvAttc.setBody(Blob.valueOf(csvContent));

        // Send Email
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject(subject);
        email.setToAddresses(toAddresses);
        email.setPlainTextBody(plainTextBody);
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{
                csvAttc
        });
        List<Messaging.SendEmailResult> sendResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                email
        });

        return sendResults;
    }

	/**** Helper Methods ****/

    public Messaging.EmailFileAttachment createAtt(String filename, String attContent) {
        Messaging.EmailFileAttachment att = new Messaging.EmailFileAttachment();
        att.setFileName(filename);
        att.setBody(Blob.valueOf(attContent));
        return att;
    }

    // Send Email
    public List<Messaging.SendEmailResult> sendEmail(String subject, String plainTextBody, Set<Messaging.EmailFileAttachment> att) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject(subject);
        email.setToAddresses(new List<String>{
                sendToEmail
        });
        email.setPlainTextBody(plainTextBody);
        //if (att != null) email.setFileAttachments(att);
        List<Messaging.SendEmailResult> sendResults = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                email
        });
        return sendResults;
    }
}