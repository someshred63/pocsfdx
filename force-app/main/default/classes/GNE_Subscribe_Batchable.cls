public virtual class GNE_Subscribe_Batchable {
	
	protected void sendSummaryMail(String jobName, GNE_Subscribe_Metrics metrics, String configName) {
        //Create a new single email message object
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        Map<String, GNE_Foun_Misc_Config_Items_gne__c> configItemsMap = GNE_Foun_Misc_Config_Items_gne__c.getAll();
        String addr = configItemsMap.get(configName).Configuration_Value_gne__c;
        //Address
        email.setToAddresses(new String[] {addr});
        // Subject
        email.setSubject(jobName + ' finished');
        
        String summary = jobName + ' finished: ' + DateTime.now() + '\n';
        summary += printMetrics(metrics);
                    
        //Content
        email.setPlainTextBody(summary);
        //Send
        List<Messaging.Sendemailresult> error = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        if (!error[0].isSuccess()){
            System.debug('Couldn\'t send metrics summary email!');
        }
    }
    
    protected void sendSummaryMail(String jobName, GNE_Subscribe_Metrics metrics) {
    	sendSummaryMail(jobName, metrics, 'SubscribeNotfyEmail');
    }
    
    public static String printMetrics(GNE_Subscribe_Metrics metrics) {
    	String out = '';
    	if (metrics.entityType != GNE_Subscribe_Metrics.EntityTypeName.UNDEFINED) {
	        out += 'Metrics for ' + metrics.entityType + ':\n';
	        out += ' - upserted: ' + metrics.upsertCount + '\n';
	        if (metrics.deleteCount > 0) 
	        	out += ' - deleted: ' + metrics.deleteCount + '\n';
	        out += ' - errors: ' + metrics.errorCount + '\n';
	        out += '\n';
    	}
        if (metrics.relatedSubscribeMetrics != null) {
	        for (GNE_Subscribe_Metrics m : metrics.relatedSubscribeMetrics) {
	        	
	            out += printMetrics(m);
	        }
        }
        return out;
    }
}