global class OTR_Crash_Email_Service implements Messaging.InboundEmailHandler {
		
  	global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.Inboundenvelope envelope) {
  		Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();	
		if (String.isBlank(email.subject) || !email.subject.containsIgnoreCase('OTR PRD') /*|| !email.subject.containsIgnoreCase('Service Message')*/){
			result.success = true;
			return result;
		}		
		try {
			intHandleInboundEmail(email, envelope);
			result.success = true;
		} catch(Exception e){
			result.success = false;			
			result.message = e.getMessage();
			//sendNotificationErrorMessage(email, getHtmlErrorMessage(e));
		}
		return result;
  	}
  	
  	private void intHandleInboundEmail(Messaging.InboundEmail email,  Messaging.Inboundenvelope envelope){
  		OTR_Crash_gne__c crashLog = new OTR_Crash_gne__c();
  		String subject = email.subject;
  		
		crashLog.Version__c = getValue(subject, '(\\d+(\\.\\d+)*)');
		crashLog.Crash_Date__c = getValue(email.PlainTextBody, 'Crashed on (.*)');
		crashLog.Profile__c = getValue(email.PlainTextBody, 'Profile:(.*)');
		
		if(email.textAttachments != null && email.textAttachments.size() > 0){
			String attachmentText = email.textAttachments.get(0).body;	
			
			String iosVersion = getValue(attachmentText, 'OS Version: (.*)');
			crashLog.iOS_Version__c = getIOSVersion(iosVersion);
			
			String hardwareModel = getValue(attachmentText, 'Hardware Model: (.*)');
			crashLog.Hardware_Model__c = getIOSModelGeneration(hardwareModel);

			String gmtDateStr = getValue(attachmentText, 'Time: (.*)');
			if (String.isNotBlank(gmtDateStr)){
				crashLog.Crash_GMT_Date__c = Datetime.valueOfGMT(gmtDateStr);
			}
		}
		
		String unixId = getValue(subject, '(?<=\\[)(.*?)(?=\\])');
		if (String.isNotBlank(unixId)){
			crashLog.UnixId__c = unixId;
			List<User> userList = [SELECT Id FROM User WHERE External_ID_gne__c = :unixId LIMIT 1];		
			if(!userList.isEmpty()){
				crashLog.User__c = userList.get(0).Id;
			}
		}
		
  		insert crashLog;
  	}
  	
  	private String getValue(String text, String regex){
  		String result = null;
  		if (String.isBlank(text)){
  			return result;
  		}
  		Pattern mPattern = Pattern.compile(regex);
		Matcher mMatcher = mPattern.matcher(text);		
		if(mMatcher.find() && mMatcher.groupCount() > 0) {
	    	result = mMatcher.group(1);
		}
		return result;
  	}
  	
  	private String getIOSModelGeneration(String hardwareModel){
  		String result = hardwareModel;
  		if (String.isBlank(hardwareModel)){
  			return result;
  		}
  		Boolean found = false;
  		Map<String, IOS_Devices_Models_gne__c> models = IOS_Devices_Models_gne__c.getAll();
  		for (String generation : models.keyset()){
  			String identifiers = models.get(generation).Identifiers_gne__c;
  			if (String.isBlank(identifiers)){
  				continue;
  			}  			
  			for (String identifier : identifiers.split(';')){
  				if (identifier.trim() == hardwareModel.trim()){
  					result = generation;
  					found = true;
  					break;
  				}
  			}
  			if (found == true){
  				break;
  			}
  		}
  		return result;
  	}
  	
  	private String getIOSVersion(String iosVersion){
  		String result = iosVersion;
  		if (String.isBlank(iosVersion) || !iosVersion.containsIgnoreCase('OS')) {
  			return result;
  		}
		Integer osStampIndex;
		Boolean found = false;
		for (String osMask : new List<String>{'OS X ', 'OSX ', 'OS '}){
			if ((osStampIndex = iosVersion.indexOfIgnoreCase(osMask)) == 0){
				result = iosVersion.substring(osStampIndex + osMask.length()).trim();
				found = true;
				break;
			}
		}
		if (found == false){
		 	for (String osMask : new List<String>{' OS X ', ' OSX ', ' OS '}){
				if ((osStampIndex = iosVersion.indexOfIgnoreCase(osMask)) > -1){
					result = iosVersion.substring(osStampIndex + osMask.length()).trim();
					found = true;
					break;
				}
		 	}
		}
		return result;
  	}
  	
  	/*private void sendNotificationErrorMessage(Messaging.InboundEmail email, String errorMessage){
  		List<String> serviceEmailAdmins = getCrashEmailServiceAdmins();
  		if (serviceEmailAdmins.isEmpty()){
  			return;
  		}  		
  		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
  		if(email.textAttachments != null && email.textAttachments.size() > 0){
  			List<Messaging.EmailFileAttachment> attachs = new List<Messaging.EmailFileAttachment>();
  			for(Messaging.InboundEmail.TextAttachment inboundAttachment : email.textAttachments){
  				if(String.isBlank(inboundAttachment.body)){
  					continue;
  				}
				Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
				attachment.setFileName(inboundAttachment.fileName);
				attachment.setContentType('text/plain');
				attachment.Body = Blob.valueOf(inboundAttachment.body);
				attachs.add(attachment);
  			}
  			mail.setFileAttachments(attachs);
  		}  		
		mail.setToAddresses(serviceEmailAdmins); 
		String messageBody = errorMessage + '<br/><br/>' + email.plaintextBody;
		mail.setHtmlBody(messageBody);
		mail.setSubject('Error: ' + email.subject);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
  	}
  	
  	private List<String> getCrashEmailServiceAdmins(){
       	List<String> result = new List<String>();
       	GNE_SFA2_OTR_Services_Settings__c serviceSetting = GNE_SFA2_OTR_Services_Settings__c.getValues('CrashEmailServiceAdmins');
       	if (serviceSetting != null && String.isNotBlank(serviceSetting.Value_gne__c)){
       		result = serviceSetting.Value_gne__c.Split(';');
       	}
      	return result;
    }
    
    private String getHtmlErrorMessage(Exception e){  		
  		return String.format('An error occured while processing OTR_Crash_Email_Service class.<br/><br/><b>Type:</b> {0}<br/><b>Error message:</b> {1}<br/><b>Line number:</b> {2}<br/><b>Stack trace:</b> {3}<br/><br/>',
			new String[]{
				e.getTypeName(),
				e.getMessage(),
				e.getLineNumber() != null ? String.valueOf(e.getLineNumber()) : '',
				e.getStackTraceString()
			}
		);		
  	}*/
}