public with sharing class GNE_SFA2_PFG_TransactionsNotifications 
{
	private final static String TRANSFER_NOTIFICATION = 'Transfer Notification';
	private final static String ADJUSTMENT_NOTIFICATION = 'Adjustment Notification';
	private final static String RETURN_NOTIFICATION = 'Return Notification';

	private static String EMPTY_FIELD_MESSAGE = 'Field is empty';
	private static String CONTAINS_NONASCII_CHARS_MESSAGE = 'Field contains non-ascii characters';

	public static void sortAndProcessTransactions (List<SFA2_PFG_Transaction_gne__c> transactions)
	{
		List<SFA2_PFG_Transaction_gne__c> transferTransactions = new List<SFA2_PFG_Transaction_gne__c>();
		List<SFA2_PFG_Transaction_gne__c> adjustmentTransactions = new List<SFA2_PFG_Transaction_gne__c>();
		List<SFA2_PFG_Transaction_gne__c> returnTransactions = new List<SFA2_PFG_Transaction_gne__c>();
		GNE_SFA2_PFG_Util.cacheInventoryCount(transactions);
		for(SFA2_PFG_Transaction_gne__c trx : transactions)
		{
			String recordType = GNE_SFA2_PFG_Util.getTransactionRecordTypeName(trx.recordTypeId);
			if(recordType == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_TRANSFER)
			{
				transferTransactions.add(trx);
			}
			if(recordType == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ADJUSTMENT)
			{
				adjustmentTransactions.add(trx);
			}
			if(recordType == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RETURN)
			{
				returnTransactions.add(trx);
			}
		}
		checkFieldsCorrectness(transactions);
		if(!transferTransactions.isEmpty())
		{
			sendEmails(transferTransactions, TRANSFER_NOTIFICATION);
		}
		if(!adjustmentTransactions.isEmpty())
		{
			sendEmails(adjustmentTransactions, ADJUSTMENT_NOTIFICATION);
		}
		if(!returnTransactions.isEmpty())
		{
			sendEmails(returnTransactions, RETURN_NOTIFICATION);
		}
	}
	private static void sendEmails(List<SFA2_PFG_Transaction_gne__c> transactions, String notificationType)
	{
		String subject ='';
		String emailBody ='';
		List<Messaging.Singleemailmessage> emailsToSend = new List<Messaging.Singleemailmessage>();
		String hoDistEmail = GNE_SFA2_PFG_Config.HO_EMAIL;
		List<String> hoEmails = new List<String>();
		if(hoDistEmail != null && hoDistEmail !='')
		{
			hoEmails.add(hoDistEmail);
		}
		List<String> toAddresses = new List<String>();
		List<Id> fromUserDM = new List<Id>();
		List<Id> toUserDM = new List<Id>();
		List<SFA2_User_Sales_Roster_gne__c> dmSalesRosterToUser = new List<SFA2_User_Sales_Roster_gne__c>();
		List<SFA2_User_Sales_Roster_gne__c> dmSalesRosterFromUser = new List<SFA2_User_Sales_Roster_gne__c>();
		List<SFA2_User_Sales_Roster_gne__c> fromUserSalesRoster = new List<SFA2_User_Sales_Roster_gne__c>();
		List<SFA2_User_Sales_Roster_gne__c> toUserSalesRoster = new List<SFA2_User_Sales_Roster_gne__c>();
		for(SFA2_PFG_Transaction_gne__c trx : transactions)
		{
			Messaging.Singleemailmessage notificationEmail = new Messaging.Singleemailmessage();
			if(trx.From_User_gne__c != null)
			{	
				fromUserDM.add(GNE_SFA2_PFG_Util.getManagerForUser(trx.From_User_gne__c));
				fromUserSalesRoster.add(GNE_SFA2_PFG_Util.getSalesRosterForUser(trx.From_User_gne__c));
			}
			if(trx.To_User_gne__c != null)
			{	
				toUserDM.add(GNE_SFA2_PFG_Util.getManagerForUser(trx.To_User_gne__c));
				toUserSalesRoster.add(GNE_SFA2_PFG_Util.getSalesRosterForUser(trx.To_User_gne__c));
			}
			if(!toUserDM.isEmpty() && toUserDM.size()==1)
			{
				dmSalesRosterToUser.add(GNE_SFA2_PFG_Util.getSalesRosterForUser(toUserDM[0]));
			}
			if(!fromUserDM.isEmpty() && fromUserDM.size()==1)
			{
				dmSalesRosterFromUser.add(GNE_SFA2_PFG_Util.getSalesRosterForUser(fromUserDM[0]));
			}
			if(notificationType == TRANSFER_NOTIFICATION)
			{
				if(!dmSalesRosterToUser.isEmpty() && dmSalesRosterToUser.size()==1 && !toUserSalesRoster.isEmpty() && toUserSalesRoster.size()==1)
				{
					if(dmSalesRosterToUser[0].User_gne__r.Email != null)
					{
						toAddresses.add(dmSalesRosterToUser[0].User_gne__r.Email);
					}
					if(toUserSalesRoster[0].User_gne__r.Email != null)
					{
						toAddresses.add(toUserSalesRoster[0].User_gne__r.Email);
					}
				}
				if(!dmSalesRosterFromUser.isEmpty() && dmSalesRosterFromUser.size()==1 && !fromUserSalesRoster.isEmpty() && fromUserSalesRoster.size()==1)
				{
					if(dmSalesRosterFromUser[0].User_gne__r.Email != null)
					{
						toAddresses.add(dmSalesRosterFromUser[0].User_gne__r.Email);
					}
					if(fromUserSalesRoster[0].User_gne__r.Email != null)
					{
						toAddresses.add(fromUserSalesRoster[0].User_gne__r.Email);
					}
				}
				notificationEmail.setBccSender(false);
				notificationEmail.setToAddresses(toAddresses);
				if(!hoEmails.isEmpty())
				{
					notificationEmail.setCcAddresses(hoEmails);
				}
				subject = GNE_SFA2_PFG_Util.getPfgProduct(trx.Product_gne__c).Name+' quantity '+ String.valueOf(trx.Requested_Quantity_gne__c) + ' transferred from '+fromUserSalesRoster[0].User_gne__r.Name+' to '+toUserSalesRoster[0].User_gne__r.Name;
				emailBody = GNE_SFA2_PFG_Util.getPfgProduct(trx.Product_gne__c).Name+' quantity '+ String.valueOf(trx.Requested_Quantity_gne__c) + ' transferred from '+fromUserSalesRoster[0].User_gne__r.Name+' to '+toUserSalesRoster[0].User_gne__r.Name + ' on '+String.valueOf(trx.Transaction_Date_gne__c);
				notificationEmail.setSubject(subject);
				notificationEmail.setPlainTextBody(emailBody);
				if(!notificationEmail.getToAddresses().isEmpty())
				{
					emailsToSend.add(notificationEmail);
				}
			}
			if(notificationType == ADJUSTMENT_NOTIFICATION)
			{
				Set<String> vendorsNames = GNE_SFA2_PFG_Util.getVendorNamesForProduct(trx.Product_gne__c);
				Set<String> vendorsEmails = new Set<String>();
				if(!vendorsNames.isEmpty())
				{
					for(String vName : vendorsNames)
					{
						String vendorEmail = GNE_SFA2_PFG_Util.getEmailForVendor(vName);
						if(vendorEmail != null && vendorEmail != '')
						{
							vendorsEmails.add(vendorEmail);
						}
					}
				}
				if(!hoEmails.isEmpty())
				{
					toAddresses.addAll(hoEmails);
				}
				if(!vendorsEmails.isEmpty())
				{
					toAddresses.addAll(vendorsEmails);
				}
				notificationEmail.setToAddresses(toAddresses);
				notificationEmail.setBccSender(false);
				subject ='';
				emailBody ='';
				if(trx.To_User_gne__c != null)
				{
					Double invQuantity = 0;
					if(GNE_SFA2_PFg_Util.getInvCountForUserAndProduct(trx.To_User_gne__c, trx.Product_gne__c) != null)
					{
						invQuantity = GNE_SFA2_PFg_Util.getInvCountForUserAndProduct(trx.To_User_gne__c, trx.Product_gne__c).Count_gne__c;
					}
					Double newQuantity = invQuantity + trx.Requested_Quantity_gne__c;
					subject = GNE_SFA2_PFG_Util.getPfgProduct(trx.Product_gne__c).Name+' adjusted quantity '+String.valueOf(trx.Requested_Quantity_gne__c)+' by '+toUserSalesRoster[0].User_gne__r.Name;
					emailBody = GNE_SFA2_PFG_Util.getPfgProduct(trx.Product_gne__c).Name+' adjusted quantity '+String.valueOf(trx.Requested_Quantity_gne__c)+' by '+toUserSalesRoster[0].User_gne__r.Name+' on '+String.valueOf(trx.Transaction_Date_gne__c)+'. Reason for adjustment: '+trx.Transaction_Reason_gne__c+
								'. Orginal quantity '+String.valueOf(invQuantity)+', new adjusted quantity '+String.valueOf(newQuantity);
				}
				else if(trx.From_User_gne__c != null)
				{
					Double invQuantity = 0;
					if(GNE_SFA2_PFg_Util.getInvCountForUserAndProduct(trx.From_User_gne__c, trx.Product_gne__c) != null)
					{
						invQuantity = GNE_SFA2_PFg_Util.getInvCountForUserAndProduct(trx.From_User_gne__c, trx.Product_gne__c).Count_gne__c;
					}
					Double newQuantity = invQuantity + trx.Requested_Quantity_gne__c;
					subject = GNE_SFA2_PFG_Util.getPfgProduct(trx.Product_gne__c).Name+' adjusted quantity '+String.valueOf(trx.Requested_Quantity_gne__c)+' by '+fromUserSalesRoster[0].User_gne__r.Name;
					emailBody = GNE_SFA2_PFG_Util.getPfgProduct(trx.Product_gne__c).Name+' adjusted quantity '+String.valueOf(trx.Requested_Quantity_gne__c)+' by '+fromUserSalesRoster[0].User_gne__r.Name+' on '+String.valueOf(trx.Transaction_Date_gne__c)+'. Reason for adjustment: '+trx.Transaction_Reason_gne__c+
								'. Orginal quantity '+String.valueOf(invQuantity)+', new adjusted quantity '+String.valueOf(newQuantity);
				}
				notificationEmail.setSubject(subject);
				notificationEmail.setPlainTextBody(emailBody);
				if(!notificationEmail.getToAddresses().isEmpty())
				{
					emailsToSend.add(notificationEmail);
				}
			}
			if(notificationType == RETURN_NOTIFICATION)
			{
				notificationEmail.setBccSender(false);
				if(!dmSalesRosterFromUser.isEmpty() && dmSalesRosterFromUser.size()==1 && !fromUserSalesRoster.isEmpty() && fromUserSalesRoster.size()==1)
				{
					if(dmSalesRosterFromUser[0].User_gne__r.Email !=null)
					{
						toAddresses.add(dmSalesRosterFromUser[0].User_gne__r.Email);
					}
					if(fromUserSalesRoster[0].User_gne__r.Email != null)
					{
						toAddresses.add(fromUserSalesRoster[0].User_gne__r.Email);
					}
				}
				notificationEmail.setToAddresses(toAddresses);
				subject = GNE_SFA2_PFG_Util.getPfgProduct(trx.Product_gne__c).Name+' quantity '+String.valueOf(trx.Requested_Quantity_gne__c)+' returned by '+fromUserSalesRoster[0].User_gne__r.Name;
				emailBody = GNE_SFA2_PFG_Util.getPfgProduct(trx.Product_gne__c).Name+' quantity '+String.valueOf(trx.Requested_Quantity_gne__c)+' returned by '+fromUserSalesRoster[0].User_gne__r.Name +' on '+String.valueOf(trx.Transaction_Date_gne__c)+'. Reason for adjustment: '+trx.Transaction_Reason_gne__c;
				notificationEmail.setSubject(subject);
				notificationEmail.setPlainTextBody(emailBody);
				if(!notificationEmail.getToAddresses().isEmpty())
				{
					emailsToSend.add(notificationEmail);
				}
			}
			if(!emailsToSend.isEmpty())
			{
				Messaging.sendEmail(emailsToSend);
			}
		}
	}

	private static void checkFieldsCorrectness(List<SFA2_PFG_Transaction_gne__c>  trxs) {
		Boolean isValid = true;
		String message = '<html><body>'+
							'<table>'+
								'<tr>'+
									'<td><b>Id</b></td>'+
									'<td><b>Affected Field</b></td>'+
									'<td><b>Message</b></td>'+
									'<td><b>URL</b></td>'+
							'</tr>', address, 
			   environmentUrl = system.URL.getSalesforceBaseUrl().toExternalForm()+'/',
			   environmentId = GNE_SFA2_Util.getEnvironment();

		if(environmentId == '') {
			environmentId = 'dev';
		}
		if(GNE_SFA2_PFG_EmailAddresses__c.getValues(environmentId) != null) {
			address = GNE_SFA2_PFG_EmailAddresses__c.getValues(environmentId).Value__c;
		} else {
			address = 'sfdctestemail-d@gene.com';
		}

		Set<Id> addressIds = new Set<Id>();
		for(SFA2_PFG_Transaction_gne__c trx : trxs) {
			if(trx.Transaction_Type_gne__c == 'Request for Fulfillment') { 
				addressIds.add(trx.Address_ID_gne__c);
			}
		}
		Map<Id, Address_vod__c> id2addressMap = new Map<Id, Address_vod__c>([SELECT Id, Designation_gne__c FROM Address_vod__c WHERE Id IN :addressIds]);

		for(SFA2_PFG_Transaction_gne__c trx : trxs) {
			if(trx.Transaction_Type_gne__c == 'Request for Fulfillment') { 
				if(!isTransactionRefNumberValid(trx.Transaction_Ref_Number_gne__c)) {
					isValid = false;
					message += buildEmailMessage('Transaction_Ref_Number_gne__c', trx.Id, EMPTY_FIELD_MESSAGE, environmentUrl+trx.Id);
				}
				if(!isCallPfgDetailValid(trx.Call_PFG_Detail_ID_gne__c)) {
					isValid = false;
					message += buildEmailMessage('Call_PFG_Detail_ID_gne_c', trx.Id, EMPTY_FIELD_MESSAGE, environmentUrl+trx.Id);
				}
				if(!isTransactionDateValid(trx.Transaction_Date_gne__c)) {
					isValid = false;
					message += buildEmailMessage('Transaction_Date_gne__c', trx.Id, EMPTY_FIELD_MESSAGE, environmentUrl+trx.Id);
				}
				if(!isTransactionTypeValid(trx.Transaction_Type_gne__c)) {
					isValid = false;
					message += buildEmailMessage('Transaction_Type_gne__c', trx.Id, EMPTY_FIELD_MESSAGE, environmentUrl+trx.Id);	
				}
				if(!isNameValid(trx.Name)) {
					isValid = false;
					message += buildEmailMessage('Name', trx.Id, EMPTY_FIELD_MESSAGE, environmentUrl+trx.Id);
				}
				if(!isRequestedQuanitityValid(trx.Requested_Quantity_gne__c)) {
					isValid = false;
					message += buildEmailMessage('Requested_Quantity_gne__c', trx.Id, EMPTY_FIELD_MESSAGE, environmentUrl+trx.Id);
				}
				if(!isProductValid(trx.Product_gne__c)) {
					isValid = false;
					message += buildEmailMessage('Product_gne__c', trx.Id, EMPTY_FIELD_MESSAGE, environmentUrl+trx.Id);
				}
				if(!isAccountValid(trx.Account_gne__c)) {
					isValid = false;
					message += buildEmailMessage('Account_gne__c', trx.Id, EMPTY_FIELD_MESSAGE, environmentUrl+trx.Id);
				}
				if(!isAddressIdValid(trx.Address_ID_gne__c)) {
					isValid = false;
					message += buildEmailMessage('Address_ID_gne__c', trx.Id, EMPTY_FIELD_MESSAGE, environmentUrl+trx.Id);
				}
				FieldValidator addressLine1Validator = getAddressLine1Validator(trx.Address_Line_1_gne__c);
				if(!addressLine1Validator.getIsValid()) {
					isValid = false;
					message += buildEmailMessage('Address_Line_1_gne__c', trx.Id, addressLine1Validator.getMessage(), environmentUrl+trx.Id);
				}
				FieldValidator addressLine2Validator = getAddressLine2Validator(trx.Address_Line_2_gne__c);
				if(!addressLine2Validator.getIsValid()) {
					isValid = false;
					message += buildEmailMessage('Address_Line_2_gne__c', trx.Id, addressLine2Validator.getMessage(), environmentUrl+trx.Id);
				}
				FieldValidator cityValidator = getCityValidator(trx.City_gne__c);
				if(!cityValidator.getIsValid()) {
					isValid = false;
					message += buildEmailMessage('City_gne__c', trx.Id, cityValidator.getMessage(), environmentUrl+trx.Id);
				}
				if(!isStateValid(trx.State_gne__c)) {
					isValid = false;
					message += buildEmailMessage('State_gne__c', trx.Id, EMPTY_FIELD_MESSAGE, environmentUrl+trx.Id);
				}
				FieldValidator zipCodeFieldValidator = getZipCodeValidator(trx.Zip_gne__c);
				if(!zipCodeFieldValidator.getIsValid()) {
					isValid = false;
					message += buildEmailMessage('Zip_gne__c', trx.Id, zipCodeFieldValidator.getMessage(), environmentUrl+trx.Id);
				}
				if(!isRequestSignatureDateValid(trx.Request_Signature_Date_gne__c)) {
					isValid = false;
					message += buildEmailMessage('Request_Signature_Date_gne__c', trx.Id, EMPTY_FIELD_MESSAGE, environmentUrl+trx.Id);
				}
				if(!isRequestSignatureValid(trx.Request_Signature_gne__c)) {
					isValid = false;
					message += buildEmailMessage('Request_Signature_gne__c', trx.Id, EMPTY_FIELD_MESSAGE, environmentUrl+trx.Id);
				}
				if(!isRequestSignatureValid(trx.NDC_Number__c)) {
					isValid = false;
					message += buildEmailMessage('NDC_Number__c', trx.Id, EMPTY_FIELD_MESSAGE, environmentUrl+trx.Id);
				}
				if(trx.Address_ID_gne__c != null && id2addressMap.containsKey(trx.Address_ID_gne__c)) {
					if(!isDesignationValid(id2addressMap.get(trx.Address_ID_gne__c).Designation_gne__c)) {
						isValid = false;
						message += buildEmailMessage('Designation_gne__c', trx.Id, EMPTY_FIELD_MESSAGE, environmentUrl+trx.Id);
					}
				}
				message += '<tr> <td></td> <td></td> <td></td> <td></td> </tr>';
			}
		}
		if(!isValid && !String.isEmpty(address)) {
			sendEmailNotification(message+'</table></body></html>', address);
		}
	}

	private static String buildEmailMessage(String fieldName, Id objectId, String message, String url) {
		String createdMessageLine = '<tr>'+
										'<td>{0}</td>'+
										'<td>{1}</td>'+
										'<td>{2}</td>'+
										'<td>{3}</td>'+
									'</tr>';
		createdMessageLine = String.format(createdMessageLine, new List<String> {objectId, fieldName, message,  url});
		return createdMessageLine;
	}

	private static void sendEmailNotification(String message, String address) {
		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		email.toAddresses = new String[] { address };
		email.subject = 'PFG Corrupted Transactions Notification';
		email.setHTMLBody(message);
		Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {email};
		Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
	}

	private static Boolean isTransactionRefNumberValid(String transactionRefNumber) {
		if(String.isEmpty(transactionRefNumber)) {
			return false;
		}
		return true;
	}

	private static Boolean isCallPfgDetailValid(Id callPFGDetail) {
		if(callPFGDetail == null) {
			return false;
		} 
		return true;
	}

	private static Boolean isTransactionDateValid(Date transactionDate) {
		if(transactionDate == null) {
			return false;
		}
		return true;
	}

	private static Boolean isTransactionTypeValid(String transactionType) {
		if(String.isEmpty(transactionType)) {
			return false;
		}
		return true;
	}

	private static Boolean isNameValid(String name) {
		if(String.isEmpty(name)) {
			return false;
		}
		return true;
	}

	private static Boolean isRequestedQuanitityValid(Decimal requestedQuantity) {
		if(requestedQuantity == null) {
			return false;
		}
		return true;
	}

	private static Boolean isProductValid(Id productId) {
		if(productId == null) {
			return false;
		}
		return true;
	}

	private static Boolean isAccountValid(Id accountId) {
		if(accountId == null) {
			return false;
		}
		return true;
	}

	private static Boolean isAddressIdValid(Id addressId) {
		if(addressId == null) {
			return false;
		}
		return true;
	}

	private static FieldValidator getAddressLine1Validator(String addressLine1) {
		if(String.isEmpty(addressLine1)) {
			return new FieldValidator(EMPTY_FIELD_MESSAGE, false);
		} else if (checkIfStringContainsNonAscii(addressLine1)) {
			return new FieldValidator(CONTAINS_NONASCII_CHARS_MESSAGE, false);
		}
		return new FieldValidator();
	}

	private static FieldValidator getAddressLine2Validator(String addressLine2) {
		if(String.isEmpty(addressLine2)) {
			return new FieldValidator();
		} else if (checkIfStringContainsNonAscii(addressLine2)) {
			return new FieldValidator(CONTAINS_NONASCII_CHARS_MESSAGE, false);
		}
		return new FieldValidator();
	}

	private static Boolean checkIfStringContainsNonAscii(String stringToCheck) {
		Pattern myPattern = Pattern.compile('[^\\x00-\\x7F]+');
		Matcher myMatcher = myPattern.matcher(stringToCheck);
		return myMatcher.find();
	}

	private static FieldValidator getCityValidator(String city) {
		if(String.isEmpty(city)) {
			return new FieldValidator(EMPTY_FIELD_MESSAGE, false);
		} else if(checkIfStringContainsNonAscii(city)) {
			return new FieldValidator(CONTAINS_NONASCII_CHARS_MESSAGE, false);
		}
		return new FieldValidator();
	}

	private static Boolean isStateValid(String state) {
		if(String.isEmpty(state)) {
			return false;
		}
		return true;
	}

	private static FieldValidator getZipCodeValidator(String zipCode) {
		if(String.isEmpty(zipCode)) {
			return new FieldValidator(EMPTY_FIELD_MESSAGE, false);
		} else if(zipCode.length() != 5) {
			return new FieldValidator('Zip Code should contains 5 characters', false);
		}
		return new FieldValidator();
	}

	private static Boolean isRequestSignatureDateValid(Datetime requestSignatureDate) {
		if(requestSignatureDate == null) {
			return false;
		}
		return true;
	}

	private static Boolean isRequestSignatureValid(String requestSignature) {
		if(requestSignature == null) {
			return false;
		}
		return true;
	}

	private static Boolean isNdcNumberValid(String ndcNumber) {
		if(String.isEmpty(ndcNumber)) {
			return false;
		}
		return true;
	}

	private static Boolean isDesignationValid(String designation) {
		if(String.isEmpty(designation) || designation == null) {
			return false;
		}
		return true;
	}

	private class FieldValidator {
		private String message;
		private Boolean isValid;

		public FieldValidator(String message, Boolean isValid) {
			this.message = message;
			this.isValid = isValid;
		}

		public FieldValidator() {
			this.isValid = true;
			this.message = '';
		}

		public void setMessage(String message) {
			this.message = message;
		}

		public void setIsValid(Boolean isValid) {
			this.isValid = isValid;
		}

		public String getMessage() {
			return this.message;
		}

		public Boolean getIsValid() {
			return this.isValid;
		}
	}
}