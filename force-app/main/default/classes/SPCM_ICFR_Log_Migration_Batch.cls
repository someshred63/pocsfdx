public class SPCM_ICFR_Log_Migration_Batch implements Database.Batchable<sObject>, Database.Stateful {
	
	private final Boolean IS_IMPORT { get; set; }
	private final List<String> EMAIL_ADRESSES = new List<String> { 'tadeusz.hyzy@contractors.roche.com' };
	
	private Map<String, Id> agreementTypeMap { get; set; }
	private Map<String, Id> userMap { get; set; }
	private Map<String, Id> customerTypeMap { get; set; }
	private Map<String, Id> productMap { get; set; }
	
	private List<SPCM_ICFR_Log__c> logsWithSuccess { get; set; }
	private List<SPCM_ICFR_Log_Migration__c> migrationLogsWithSuccess { get; set; }
	private List<SPCM_ICFR_Log_Migration__c> logsWithErrors { get; set; }
	
	private Integer logsSuccessCount { get; set; }
	private Integer logsErrorCount { get; set; }
	
	private Set<String> invalidAgreementTypes { get; set; }
	private Set<String> invalidCOpsContractManagers { get; set; }
	private Set<String> invalidCustomerTypes { get; set; }
	private Set<String> invalidMCCContractManagers { get; set; }
	private Set<String> invalidMCCManagers { get; set; }
	private Set<String> invalidReviewers { get; set; }
	private Set<String> invalidProducts { get; set; }
	
	private Set<String> setOfExceptions { get; set; }
	
	public SPCM_ICFR_Log_Migration_Batch(Boolean isImport) {
		IS_IMPORT = isImport;
	}	
	
	public SPCM_ICFR_Log_Migration_Batch() {
		IS_IMPORT = true;
	}
	
	public Database.QueryLocator start(Database.BatchableContext BC)
	{
		
		setOfExceptions = new Set<String>();
		
		if(IS_IMPORT)
		{
			logsSuccessCount = 0;
			logsErrorCount = 0;
			
			logsWithSuccess = new List<SPCM_ICFR_Log__c>();
			migrationLogsWithSuccess = new List<SPCM_ICFR_Log_Migration__c>();
			logsWithErrors = new List<SPCM_ICFR_Log_Migration__c>();
			
			invalidAgreementTypes = new Set<String>();
			invalidCOpsContractManagers = new Set<String>();
			invalidCustomerTypes = new Set<String>();
			invalidMCCContractManagers = new Set<String>();
			invalidMCCManagers = new Set<String>();
			invalidReviewers = new Set<String>();
	
			return Database.getQueryLocator('SELECT Account__c, Agreement_Type__c, Amendment_Number__c, Amended_Contracts__c, C_Ops_Contract_Manager__c, CARS_Activation_Date__c, CARS_Key_Legacy__c, CARS_Version__c, Contract_ID__c, Created_Date__c, Customer__c, Document_Type__c, Effective_Date__c, Email_Notice_Date__c, Expected_Activation_Date__c, Impacts_Revenue_Recognition__c, MCC_Contract_Manager__c, MCC_Manager__c, Notes__c, Product_List__c, Retro_Effective_Dated__c, Reviewer__c, Status__c FROM SPCM_ICFR_Log_Migration__c WHERE Imported__c = false');
		}
		else 
		{
			invalidProducts = new Set<String>();
			
			return Database.getQueryLocator('SELECT Id, Product_List__c FROM SPCM_ICFR_Log__c');
		}
	}
	
	public void execute(Database.BatchableContext BC, List<sObject> scope)
	{
		// IMPORT NEW ICFR LOGS
		if(IS_IMPORT) 
		{
			
			List<SPCM_ICFR_Log__c> logsToInsert = new List<SPCM_ICFR_Log__c>();
			
			agreementTypeMap = new Map<String, Id>();
			userMap = new Map<String, Id>();
			customerTypeMap = new Map<String, Id>();
			
			for(sObject item : scope) 
			{
				SPCM_ICFR_Log_Migration__c migrationLog = (SPCM_ICFR_Log_Migration__c) item;
				
				agreementTypeMap.put(migrationLog.Agreement_Type__c, null);
				userMap.put(migrationLog.C_Ops_Contract_Manager__c, null);
				userMap.put(migrationLog.MCC_Contract_Manager__c, null);
				userMap.put(migrationLog.MCC_Manager__c, null);
				userMap.put(migrationLog.Reviewer__c, null);
				customerTypeMap.put(migrationLog.Customer__c, null);
			}
			
			// Get all Agreement Types
			for(SPCM_Agreement_Type__c agreementType : [SELECT Id, Name FROM SPCM_Agreement_Type__c WHERE Name IN :agreementTypeMap.keySet()])
			{
				agreementTypeMap.put(agreementType.Name, agreementType.Id);
			}
			
			// Get all Users	
			for(User u : [SELECT Id, Name FROM User WHERE Name IN :userMap.keySet()])
			{
				userMap.put(u.Name, u.Id);
			}
					
			// Get all Customer Types
			for(SPCM_Customer_Type__c customerType : [SELECT Id, Name FROM SPCM_Customer_Type__c WHERE Name IN :customerTypeMap.keySet()])
			{
				customerTypeMap.put(customerType.Name, customerType.Id);
			}
			
			for(sObject item : scope) 
			{
				SPCM_ICFR_Log_Migration__c migrationLog = (SPCM_ICFR_Log_Migration__c) item;
				
				Map<Boolean, SPCM_ICFR_Log__c> result = convertLog(migrationLog);
				
				if(result.containsKey(true)) 
				{
					logsWithSuccess.add(result.get(true));
					logsToInsert.add(result.get(true));
					migrationLogsWithSuccess.add(migrationLog);
					logsSuccessCount++;
				}
				else
				{
					logsWithErrors.add(migrationLog);
					logsErrorCount++;
				}
				
			}
			
			try 
			{
				insert logsToInsert;
			}
			catch (Exception ex) 
			{
				setOfExceptions.add(ex.getMessage());
			}
		} 
		else
		{
			List<SPCM_Log_To_Product_Junction__c> junctionsToInsert = new List<SPCM_Log_To_Product_Junction__c>();
			
			productMap = new Map<String, Id>();
			
			for(sObject item : scope) 
			{
				SPCM_ICFR_Log__c log = (SPCM_ICFR_Log__c) item;
				
				if(String.isNotEmpty(log.Product_List__c)) 
				{
					for (String product : log.Product_List__c.split(','))
					{
						if(String.isNotEmpty(product)) 
						{
							productMap.put(product.trim(), null);
						}
					}
				}
			}
			
			// Get all Products
			for(SPCM_Product__c product : [SELECT Id, Name FROM SPCM_Product__c WHERE Name IN :productMap.keySet()])
			{
				productMap.put(product.Name, product.Id);
			}
			
			System.debug('## ProductMap : ' + productMap);
						
			for(sObject item : scope) 
			{
				SPCM_ICFR_Log__c log = (SPCM_ICFR_Log__c) item;
				
				if(String.isNotEmpty(log.Product_List__c))  
				{
					for (String product : log.Product_List__c.split(','))
					{
						if(productMap != null && productMap.containsKey(product.trim()) && productMap.get(product.trim()) != null) {
							junctionsToInsert.add(new SPCM_Log_To_Product_Junction__c(ICFR_Log__c = log.Id, SPCM_Product__c = productMap.get(product.trim())));
						} else {
							invalidProducts.add(product.trim());
						}
					}
				}
			}
					
			try 
			{
				insert junctionsToInsert;
			}
			catch (Exception ex) 
			{
				setOfExceptions.add(ex.getMessage());
			}
			
		}
		
	}
	
	private Map<Boolean, SPCM_ICFR_Log__c> convertLog(SPCM_ICFR_Log_Migration__c migrationLog) 
	{
		
		Map<Boolean, SPCM_ICFR_Log__c> result = new Map<Boolean, SPCM_ICFR_Log__c>();
		
		List<String> errors = new List<String>();

		SPCM_ICFR_Log__c log = new SPCM_ICFR_Log__c();
		
			// Account
			log.Account__c = migrationLog.Account__c;
			
			// Agreement Type Lookup
			if(String.isNotEmpty(migrationLog.Agreement_Type__c)) 
				{
				if(agreementTypeMap != null && agreementTypeMap.containsKey(migrationLog.Agreement_Type__c) && agreementTypeMap.get(migrationLog.Agreement_Type__c) != null) {
					log.Agreement_Type__c = agreementTypeMap.get(migrationLog.Agreement_Type__c);
				} else { 
					errors.add('Agreement_Type__c'); 
					invalidAgreementTypes.add(migrationLog.Agreement_Type__c);
				}
			}
					
			// Amended_Contracts
			log.Amended_Contracts__c = migrationLog.Amended_Contracts__c;
			
			// Amendment Number
			log.Amendment_Number__c = migrationLog.Amendment_Number__c;
						
			// C-Ops Contract Manager Lookup
			if(String.isNotEmpty(migrationLog.C_Ops_Contract_Manager__c)) 
			{
				if(userMap != null && userMap.containsKey(migrationLog.C_Ops_Contract_Manager__c) && userMap.get(migrationLog.C_Ops_Contract_Manager__c) != null) {
					log.C_Ops_Contract_Manager__c = userMap.get(migrationLog.C_Ops_Contract_Manager__c);
				} else { 
					errors.add('C_Ops_Contract_Manager__c');
					invalidCOpsContractManagers.add(migrationLog.C_Ops_Contract_Manager__c); 
				}
			}	
				
			// CARS_Activation_Date__c
			log.CARS_Activation_Date__c = convertDate(migrationLog.CARS_Activation_Date__c);
							
			// CARS Key (Legacy)
			log.CARS_Key_Legacy__c = migrationLog.CARS_Key_Legacy__c;
												
			// CARS Version #
			log.CARS_Version__c = migrationLog.CARS_Version__c;
																	
			// CMS Id
			log.Contract_ID__c = migrationLog.Contract_ID__c;
																						
			// Created Date
			log.Created_Date__c = convertDate(migrationLog.Created_Date__c);
																				
			// Customer Type Lookup
			if(String.isNotEmpty(migrationLog.Customer__c)) 
			{
				if(customerTypeMap != null && customerTypeMap.containsKey(migrationLog.Customer__c) && customerTypeMap.get(migrationLog.Customer__c) != null) {
					log.Customer__c = customerTypeMap.get(migrationLog.Customer__c);
				} else { 
					errors.add('Customer__c'); 
					invalidCustomerTypes.add(migrationLog.Customer__c);
				}	
			}		
																					
			// Document Type
			log.Document_Type__c = migrationLog.Document_Type__c;
																											
			// Effective Date
			log.Effective_Date__c = convertDate(migrationLog.Effective_Date__c);
																															
			// Email Notice Date
			log.Email_Notice_Date__c = convertDate(migrationLog.Email_Notice_Date__c);
																																					
			// Impacts Revenue Recognition
			log.Impacts_Revenue_Recognition__c = migrationLog.Impacts_Revenue_Recognition__c;
						
			// MCC Contract Manager
			if(String.isNotEmpty(migrationLog.MCC_Contract_Manager__c)) 
			{
				if(userMap != null && userMap.containsKey(migrationLog.MCC_Contract_Manager__c) && userMap.get(migrationLog.MCC_Contract_Manager__c) != null) {
					log.MCC_Contract_Manager__c = userMap.get(migrationLog.MCC_Contract_Manager__c);
				} else { 
					errors.add('MCC_Contract_Manager__c');
					invalidMCCContractManagers.add(migrationLog.MCC_Contract_Manager__c);
				}
			}		
										
			// MCC Manager
			if(String.isNotEmpty(migrationLog.MCC_Manager__c)) 
			{
				if(userMap != null && userMap.containsKey(migrationLog.MCC_Manager__c) && userMap.get(migrationLog.MCC_Manager__c) != null)	{
					log.MCC_Manager__c = userMap.get(migrationLog.MCC_Manager__c);
				} else { 
					errors.add('MCC_Manager__c'); 
					invalidMCCManagers.add(migrationLog.MCC_Manager__c);
				}			
			}
																																														
			// Notes
			log.Notes__c = migrationLog.Notes__c;
																																																			
			// Product List
			log.Product_List__c = convertProductList(migrationLog.Product_List__c);
																																																		
			// Retro Effective Dated
			log.Retro_Effective_Dated__c = migrationLog.Retro_Effective_Dated__c;
						
			// Reviewer
			if(String.isNotEmpty(migrationLog.Reviewer__c))
			{
				if(userMap != null && userMap.containsKey(migrationLog.Reviewer__c) && userMap.get(migrationLog.Reviewer__c) != null) {
					log.Reviewer__c = userMap.get(migrationLog.Reviewer__c);
				} else { 
					errors.add('Reviewer__c'); 
					invalidReviewers.add(migrationLog.Reviewer__c);
				}	
			}											
																																																						
			// ICFR Status
			log.Status__c = migrationLog.Status__c;
							
		if(errors.isEmpty())
		{
			result.put(true, log);
		}
		else
		{
			migrationLog.Errors__c = joinList(errors, ';');
			result.put(false, null);
		}
	
		return result;
	}
	
	private String joinList(List<String> listToJoin, String delimer) {
		String result = '';
		
		for(String toJoin : listToJoin) 
		{
			result += toJoin + delimer + ' ';
		}
		
		result = result.removeEnd(delimer + ' ');
		
		return result;
	}
	
	private Date convertDate(String dateString) 
	{
		
		if(String.isEmpty(dateString)) 
		{
			return null;
		}
		
		List<String> dateSplit_1 = dateString.split('-');
		List<String> dateSplit_2 = dateString.split('/');
		
		String year, month, day;
		
		if(dateSplit_1.size() == 3) 
		{
			if(dateSplit_1[0].length() == 4) {
				year = dateSplit_1[0];
				month = dateSplit_1[1];
				day = dateSplit_1[2];
			} else {
				year = '20' + dateSplit_1[2];
				month = dateSplit_1[0];
				day = dateSplit_1[1];
			}
		}

		if(dateSplit_2.size() == 3) 
		{
			if(dateSplit_2[0].length() == 4) {
				year = dateSplit_2[0];
				month = dateSplit_2[1];
				day = dateSplit_2[2];
			} else {
				year = '20' + dateSplit_2[2];
				month = dateSplit_2[0];
				day = dateSplit_2[1];
			}
		}
		
		if(String.isEmpty(year) || String.isEmpty(month) || String.isEmpty(day)) {
			return null;
		}
		
		return Date.valueOf(year + '-' + month + '-' + day + ' 00:00:00');
	}	
	
	private String convertProductList(String productList) 
	{
		String result = '';
		if(String.isNotEmpty(productList))
		{
			for(String product : productList.split(';')) 
			{
				if(String.isNotEmpty(product)) {
					result += product + ', ';
				}
			}
			result = result.removeEnd(', ');
		}
		return result;
	}
	
	public void finish(Database.BatchableContext BC)
	{
		if(IS_IMPORT)
		{
			for(SPCM_ICFR_Log_Migration__c migrationLog : migrationLogsWithSuccess)
			{
				migrationLog.Imported__c = true;
			}
			
			try 
			{
				update migrationLogsWithSuccess;
				Database.executeBatch(new SPCM_ICFR_Log_Migration_Batch(false), 200);
			}
			catch (Exception ex) 
			{
				setOfExceptions.add(ex.getMessage());
			}
		}
		
		if(!setOfExceptions.isEmpty()) {
			System.debug('# Exceptions : ');
			for(String ex : setOfExceptions) {
				System.debug('## ' + ex);
			}
		}
		
		sendEmails();
		
	}
	
	private void sendEmails() 
	{
		
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		
		mail.setToAddresses(EMAIL_ADRESSES);
		
		if(IS_IMPORT) {
			mail.setSubject('ICFR Log Migration Tool (part 1/2) - Status after migration');
	      	mail.setHtmlBody(createEmailBody());
		} else {
			mail.setSubject('ICFR Log Migration Tool (part 2/2) - Status product junction');
	      	mail.setHtmlBody(createEmailJunctionBody());
		}
      	
      	Messaging.sendEmail(new List<Messaging.SingleEmailMessage> { mail });
      	
	}
	
	private String createEmailBody() 
	{
		String result = '<h1>ICFR Log Migration Tool (part 1/2) - Status after migration</h1>';
		
		result += '<p><strong>Date of import :</strong> ' + System.now() + '</p>';
		result += '<p><strong>Logs imported :</strong> ' + logsSuccessCount + '</p>';
		result += '<p><strong>Logs with errors: </strong> ' + logsErrorCount + '</p>';

		if(!invalidAgreementTypes.isEmpty()) {
			result += '<h3>Invalid Agreement Types (' + invalidAgreementTypes.size() + '):</h3><ul>';
			for(String s : invalidAgreementTypes) 
			{
				result += '<li>' + s + '</li>';
			}
			result += '</ul>';
		}
			
		if(!invalidCOpsContractManagers.isEmpty()) {
			result += '<h3>Invalid C-Ops Contract Managers (' + invalidCOpsContractManagers.size() + '):</h3><ul>';
			for(String s : invalidCOpsContractManagers) 
			{
				result += '<li>' + s + '</li>';
			}
			result += '</ul>';
		}
					
		if(!invalidCustomerTypes.isEmpty()) {
			result += '<h3>Invalid Customer Types (' + invalidCustomerTypes.size() + '):</h3><ul>';
			for(String s : invalidCustomerTypes) 
			{
				result += '<li>' + s + '</li>';
			}
			result += '</ul>';
		}	
						
		if(!invalidMCCContractManagers.isEmpty()) {
			result += '<h3>Invalid Contract Managers (' + invalidMCCContractManagers.size() + '):</h3><ul>';
			for(String s : invalidMCCContractManagers) 
			{
				result += '<li>' + s + '</li>';
			}
			result += '</ul>';
		}	
						
		if(!invalidMCCManagers.isEmpty()) {
			result += '<h3>Invalid Managers (' + invalidMCCManagers.size() + '):</h3><ul>';
			for(String s : invalidMCCManagers) 
			{
				result += '<li>' + s + '</li>';
			}
			result += '</ul>';
		}
								
		if(!invalidReviewers.isEmpty()) {
			result += '<h3>Invalid Reviewers (' + invalidReviewers.size() + '):</h3><ul>';
			for(String s : invalidReviewers) 
			{
				result += '<li>' + s + '</li>';
			}
			result += '</ul>';
		}
										
		if(!setOfExceptions.isEmpty()) {
			result += '<h3>Exceptions (' + setOfExceptions.size() + '):</h3><ul>';
			for(String s : setOfExceptions) 
			{
				result += '<li>' + s + '</li>';
			}
			result += '</ul>';
		}

		result += '<h3>List of logs with errors:</h3>';
		
		result += '<table width="100%">';
		
		result += '<thead>';
			result += '<tr>';
				result += '<th style="text-align: left;">Contract Id</th>';
				result += '<th style="text-align: left;"b>Agreement_Type__c</th>';
				result += '<th style="text-align: left;"b>C_Ops_Contract_Manager__c</th>';
				result += '<th style="text-align: left;"b>Customer__c</th>';
				result += '<th style="text-align: left;"b>MCC_Contract_Manager__c</th>';
				result += '<th style="text-align: left;"b>MCC_Manager__c</th>';
				result += '<th style="text-align: left;"b>Reviewer__c</th>';
				result += '<th style="text-align: left;">Id</th>';
			result += '</tr>';
		result += '</thead>';
		
		result += '<tbody>';
		
		for(SPCM_ICFR_Log_Migration__c logWithErrors : logsWithErrors)
		{
			List<String> errorsList = logWithErrors.Errors__c.split(';');
			Set<String> errorsSet = new Set<String>();
			
			errorsSet.addAll(errorsList);
			
			result += '<tr>';
				
				result += '<td>' + logWithErrors.Contract_Id__c + '</td>';
				
				if(!errorsSet.isEmpty() && errorsSet.contains('Agreement_Type__c')) { 
					result += '<td><strong style="color: #ff4444">' + ((String.isNotBlank(logWithErrors.Agreement_Type__c)) ? logWithErrors.Agreement_Type__c : '') + '</strong></td>';
				} else {
					result += '<td>' + ((String.isNotBlank(logWithErrors.Agreement_Type__c)) ? logWithErrors.Agreement_Type__c : '') + '</td>';
				} 	
							
				if(!errorsSet.isEmpty() && errorsSet.contains('C_Ops_Contract_Manager__c'))	{ 
					result += '<td><strong style="color: #ff4444">' + ((String.isNotBlank(logWithErrors.C_Ops_Contract_Manager__c)) ? logWithErrors.C_Ops_Contract_Manager__c : '') + '</strong></td>';
				} else {
					result += '<td>' + ((String.isNotBlank(logWithErrors.C_Ops_Contract_Manager__c)) ? logWithErrors.C_Ops_Contract_Manager__c : '') + '</td>';
				} 							
								
				if(!errorsSet.isEmpty() && errorsSet.contains('Customer__c'))	{ 
					result += '<td><strong style="color: #ff4444">' + ((String.isNotBlank(logWithErrors.Customer__c)) ? logWithErrors.Customer__c : '') + '</strong></td>';
				} else {
					result += '<td>' + ((String.isNotBlank(logWithErrors.Customer__c)) ? logWithErrors.Customer__c : '') + '</td>';
				} 								
				
				if(!errorsSet.isEmpty() && errorsSet.contains('MCC_Contract_Manager__c'))	{ 
					result += '<td><strong style="color: #ff4444">' + ((String.isNotBlank(logWithErrors.MCC_Contract_Manager__c)) ? logWithErrors.MCC_Contract_Manager__c : '') + '</strong></td>';
				} else {
					result += '<td>' + ((String.isNotBlank(logWithErrors.MCC_Contract_Manager__c)) ? logWithErrors.MCC_Contract_Manager__c : '') + '</td>';
				} 				
				
				if(!errorsSet.isEmpty() && errorsSet.contains('MCC_Manager__c'))	{ 
					result += '<td><strong style="color: #ff4444">' + ((String.isNotBlank(logWithErrors.MCC_Manager__c)) ? logWithErrors.MCC_Manager__c : '') + '</strong></td>';
				} else {
					result += '<td>' + ((String.isNotBlank(logWithErrors.MCC_Manager__c)) ? logWithErrors.MCC_Manager__c : '') + '</td>';
				} 			
					
				if(!errorsSet.isEmpty() && errorsSet.contains('Reviewer__c'))	{ 
					result += '<td><strong style="color: #ff4444">' + ((String.isNotBlank(logWithErrors.Reviewer__c)) ? logWithErrors.Reviewer__c : '') + '</strong></td>';
				} else {
					result += '<td>' + ((String.isNotBlank(logWithErrors.Reviewer__c)) ? logWithErrors.Reviewer__c : '') + '</td>';
				} 
				
				result += '<td>' + logWithErrors.Id + '</td>';

			result += '</tr>';
		}
		
		result += '</tbody>';
		result += '</table>';
		
		return result;
	}
	
   	private String createEmailJunctionBody() 
	{
		String result = '<h1>ICFR Log Migration Tool (part 2/2) - Status product junction</h1>';
		
		if(!setOfExceptions.isEmpty()) {
			result += '<h3>Exceptions (' + setOfExceptions.size() + '):</h3><ul>';
			for(String s : setOfExceptions) 
			{
				result += '<li>' + s + '</li>';
			}
			result += '</ul>';
		}
		
		if(!invalidProducts.isEmpty() && invalidProducts.size() > 1) {
			result += '<h3>Invalid Products (' + invalidProducts.size() + '):</h3><ul>';
			for(String s : invalidProducts) 
			{
				result += '<li>' + s + '</li>';
			}
			result += '</ul>';
		} else {
			result += '<h3>Everything is OK with products :)</h3>';
		}
			
		return result;
	}
}