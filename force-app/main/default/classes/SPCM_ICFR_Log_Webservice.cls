/*
 * SPCM_ICFR_Log_Webservice
 * 
 * @Desription: Class contains API Interface methods (SOAP) for Agiloft / ESB integration
 * @Author: Tadeusz Hyzy (tadeusz.hyzy@contractors.roche.com)
 */
global class SPCM_ICFR_Log_Webservice 
{
	
	public static final Boolean IS_WEBSERVICE = true;
	
	/*
	 * createICFRLog()
	 *
	 * @Description: This is WebService methods called by Agiloft
	 * @Notes: It needs to be WebService static method
	 * @Returs: Object class ICFRLogResult
	 */
    WebService static ICFRLogResult createICFRLog(String cmsId, String uniqueId, String accountName, String accountType, String agreementType, String documentType, String startDate, String contractManager, String mccManager, String versionNumber, String externalContractId, Boolean retroEffectiveDated, Boolean chargeBackComponentChange, Boolean impactsRevenueRecognition, String eligibleProducts) 
    {    
        ICFRLogData logData = new ICFRLogData(cmsId, uniqueId, externalContractId, accountName, accountType, agreementType, documentType, versionNumber, startDate, contractManager, mccManager, retroEffectiveDated, chargeBackComponentChange, impactsRevenueRecognition, eligibleProducts);
        
        ICFRLogResult result = new ICFRLogResult();
        
        if(logData.errors.size() > 0)
        {
        	result = new ICFRLogResult(logData.errors);
        }
        else 
        {
        	if(logData.duplicatedICFRLog == null)
        	{
        		logData.insertIcfrLog();

		        if(logData.errors.size() > 0)
		        {
		        	result = new ICFRLogResult(logData.errors);
		        }
		        else 
		        {
		        	result = new ICFRLogResult(logData.icfrLogId);
		        }
        	}
        	else 
        	{
        		result = new ICFRLogResult(logData.duplicatedICFRLog);
        	}

        }
        
        return result;
    }
    	
	/*
	 * ICFRLogData
	 *
	 * @Description: This is class that contains all data and methods needed for ICFR Log creation
	 */
    private class ICFRLogData 
    {
    	
        private String cmsId;
        private String uniqueId;
        private String externalContractId;
        private String accountName;
        private String accountType;
        private String agreementType;
        private String documentType;
        private String versionNumber;
        private String startDate;
        private String contractManager;
        private String mccManager;
        private Boolean retroEffectiveDated;
        private Boolean chargeBackComponentChange;
        private Boolean impactsRevenueRecognition;
        private String eligibleProducts;
        
        private Id customerTypeId;
        private Id agreementTypeId;
        private Date effectiveDate;
        private Map<String, Id> unixIdToUserId;
        private Set<Id> productIds;
        
        public List<String> errors;
        public String icfrLogId;
        public SPCM_ICFR_Log__c duplicatedICFRLog;
      	
		/*
		 * ICFRLogData
		 *
		 * @Description: Constructor
		 * @FieldsRequired : cmsId, uniqueId, accountName, accountType, agreementType, documentyType, versionNumber, startDate, contractManager, mccManager
		 * @FieldsOptional: externalContractId, retroEffectiveDated, chargeBackComponentChange, impactsRevenueRecognition, eligibleProducts
		 */            
        public ICFRLogData(String cmsId, String uniqueId, String externalContractId, String accountName, String accountType, String agreementType, String documentType, String versionNumber, String startDate, String contractManager, String mccManager, Boolean retroEffectiveDated, Boolean chargeBackComponentChange, Boolean impactsRevenueRecognition, String eligibleProducts)
        {
        	
			this.cmsId = cmsId;
			this.uniqueId = uniqueId;
			this.externalContractId = externalContractId;
			this.accountName = accountName;
			this.accountType = accountType.trim();
			this.agreementType = agreementType.trim();
			this.documentType = documentType.trim();
			if(String.isNotBlank(versionNumber))
			{
				this.versionNumber = versionNumber;
			}
			this.startDate = startDate;
			this.contractManager = contractManager.trim();
			this.mccManager = mccManager.trim();
			this.retroEffectiveDated = (retroEffectiveDated != null) ? Boolean.valueOf(retroEffectiveDated) : false;
			this.chargeBackComponentChange = (chargeBackComponentChange != null) ? Boolean.valueOf(chargeBackComponentChange) : false;
			this.impactsRevenueRecognition = (impactsRevenueRecognition != null) ? Boolean.valueOf(impactsRevenueRecognition) : false;
			this.eligibleProducts = eligibleProducts;
			
			this.errors = new List<String>();
			this.unixIdToUserId = new Map<String, String>();
			this.productIds	= new Set<Id>();
			
			this.validate();
        }
            	
		/*
		 * validate()
		 *
		 * @Description: This method validate if all the fields are valid
		 */
        private void validate() 
	    {
	    	try 
	    	{
    			this.errors.addAll(checkRequiredFields());
		    	this.errors.addAll(checkUniqueICFR());
		    	this.errors.addAll(checkAccountType());
		    	this.errors.addAll(checkAgreementType());
		    	this.errors.addAll(checkDocumentType());
		    	this.errors.addAll(checkDate());
		    	this.errors.addAll(checkUsers());
		    	this.errors.addAll(checkProducts());
	    	} 
	    	catch(Exception ex) 
	    	{
	    		this.errors.add('[SFDC_ERR_CODE_08] ' + ex.getMessage() + ' | Line : ' + ex.getLineNumber());
	    	}
	    }
	                	
		/*
		 * insertIcfrLog()
		 *
		 * @Description: This method inserts ICFR Log to SFDC based on data after confirm that every field is valid
		 * @Notes: We're using Database transaction to make sure that everything is fine
		 */
        private void insertIcfrLog() 
	    {
	    	
	    	Savepoint sp = Database.setSavepoint();
	    	
	    	SPCM_ICFR_Log__c icfrLog = new SPCM_ICFR_Log__c();

			try 
			{

				icfrLog.Contract_ID__c 					= this.cmsId;
				icfrLog.External_CMS_Unique_ID__c		= this.uniqueId;
				icfrLog.External_Contract_Id__c			= this.externalContractId;
				icfrLog.Account__c 						= this.accountName;
				icfrLog.Customer__c 					= this.customerTypeId;
				icfrLog.Agreement_Type__c 				= this.agreementTypeId;
				icfrLog.Document_Type__c 				= this.documentType;
				icfrLog.Amendment_Number__c 			= this.versionNumber;
				icfrLog.Effective_Date__c 				= this.effectiveDate;
				icfrLog.MCC_Contract_Manager__c 		= this.unixIdToUserId.get(contractManager);
				icfrLog.MCC_Manager__c 					= this.unixIdToUserId.get(mccManager);
				icfrLog.Retro_Effective_Dated__c 		= (Boolean)this.retroEffectiveDated;
				icfrLog.Chargeback_Component__c 		= (Boolean)this.chargeBackComponentChange;
				icfrLog.Impacts_Revenue_Recognition__c 	= (Boolean)this.impactsRevenueRecognition;
				icfrLog.Status__c						= 'New';
				icfrLog.Created_Date__c					= System.today();
				
				System.debug('## SPCM_ICFR_Log__c to insert ##');
				System.debug('####' + icfrLog);
				
				insert icfrLog;
			}
			catch(Exception ex)
			{
				Database.rollback(sp);
				this.errors.add('[SFDC_ERR_CODE_09] ' + ex.getMessage() + ' | Line : ' + ex.getLineNumber());
			}
			
			if(icfrLog.Id != null)
			{    	
				
				this.icfrLogId = String.valueOf(icfrLog.Id);

				if(!this.productIds.isEmpty())
				{
					try 
					{
						List<SPCM_Log_To_Product_Junction__c> productList = new List<SPCM_Log_To_Product_Junction__c>();
						
						for(Id productId : this.productIds)
						{
							productList.add(
								new SPCM_Log_To_Product_Junction__c(ICFR_Log__c = icfrLog.Id, SPCM_Product__c = productId)
							);
						}
												
						System.debug('## List<SPCM_Log_To_Product_Junction__c> to insert ##');
						System.debug('####' + productList);
						
						insert productList;
					}
					catch(Exception ex)
					{
						Database.rollback(sp);
						this.errors.add('[SFDC_ERR_CODE_10] ' + ex.getMessage() + ' | Line : ' + ex.getLineNumber());
					}
				}
			}

	    }
	    
		/*
		 * checkRequiredFields()
		 *
		 * @Description: This method validates if all required fields are there
		 * @Returns: List<String> with some errors
		 */
	    private List<String> checkRequiredFields()
	    {
	    	List<String> result = new List<String>();
	    	
	    	if(String.isBlank(this.cmsId))
	    	{
	    		result.add('[SFDC_ERR_CODE_00] CMS Id is mandatory field.');
	    	}
	    		    	
	    	if(String.isBlank(this.uniqueID))
	    	{
	    		result.add('[SFDC_ERR_CODE_00] Unique Id is mandatory field.');
	    	}
	    		    	
	    	if(String.isBlank(this.accountName))
	    	{
	    		result.add('[SFDC_ERR_CODE_00] Account Name is mandatory field.');
	    	}
	    		    	
	    	if(String.isBlank(this.accountType))
	    	{
	    		result.add('[SFDC_ERR_CODE_00] Account Type is mandatory field.');
	    	}
	    		    	
	    	if(String.isBlank(this.agreementType))
	    	{
	    		result.add('[SFDC_ERR_CODE_00] Agreement Type is mandatory field.');
	    	}
	    		    	
	    	if(String.isBlank(this.documentType))
	    	{
	    		result.add('[SFDC_ERR_CODE_00] Document Type is mandatory field.');
	    	}
	    		    		    	
	    	if(String.isBlank(this.startDate))
	    	{
	    		result.add('[SFDC_ERR_CODE_00] Start Date is mandatory field.');
	    	}
	    		    		    	
	    	if(String.isBlank(this.contractManager))
	    	{
	    		result.add('[SFDC_ERR_CODE_00] Contract Manager is mandatory field.');
	    	}
	    		    		    	
	    	if(String.isBlank(this.mccManager))
	    	{
	    		result.add('[SFDC_ERR_CODE_00] Manager is mandatory field.');
	    	}

	    	return result;	
	    }	  
	      
		/*
		 * checkUniqueICFR()
		 *
		 * @Description: This method validates if UniqueId is not duplicated on SFDC Database
		 * @Returns: List<String> with some errors
		 */
	    private List<String> checkUniqueICFR()
	    {
	    	List<String> result = new List<String>();

			if(String.isNotBlank(this.uniqueID)) 
			{
				List<SPCM_ICFR_Log__c> duplicateICFRLogToCheck = [SELECT Id, Name, Contract_ID__c, External_Contract_Id__c, Account__c, Customer__r.Name, Agreement_Type__r.Name, Document_Type__c, Amendment_Number__c, Effective_Date__c, MCC_Contract_Manager__r.External_ID_gne__c, MCC_Manager__r.External_ID_gne__c, Retro_Effective_Dated__c, Chargeback_Component__c, Impacts_Revenue_Recognition__c FROM SPCM_ICFR_Log__c WHERE External_CMS_Unique_ID__c = :this.uniqueID LIMIT 1];
				
		    	if(!duplicateICFRLogToCheck.isEmpty()) 
		    	{
		    		if(this.checkIfObjectMatches(duplicateICFRLogToCheck[0]))
		    		{
		    			this.duplicatedICFRLog = duplicateICFRLogToCheck[0];
		    		} 
		    		else
		    		{
		    			result.add('[SFDC_ERR_CODE_01] Duplicate found. Data in the duplicate does not match the eWorkflow record ' + duplicateICFRLogToCheck[0].Name + ' (' + duplicateICFRLogToCheck[0].Id + ').');
		    		}
		    	}
			}
	
	    	return result;	
	    }
	      
		/*
		 * compareICFRLog()
		 *
		 * @Description: This method compares ICFR Log from ESB and one with same Unique Id
		 * @Returns: Boolean
		 */
	    private Boolean checkIfObjectMatches(SPCM_ICFR_Log__c duplicateICFRLog)
	    {
	    	Boolean result = true;
	    	
	    	if(this.cmsId != duplicateICFRLog.Contract_ID__c)
	    	{
	    		result = false;
	    	}	    
	    		
	    	if(this.externalContractId != duplicateICFRLog.External_Contract_Id__c)
	    	{
	    		result = false;
	    	}	
	    	    	
	    	if(this.accountName != duplicateICFRLog.Account__c)
	    	{
	    		result = false;
	    	}	
	    	    	
	    	if(this.accountType != duplicateICFRLog.Customer__r.Name)
	    	{
	    		result = false;
	    	}	 
	    	   	
	    	if(this.agreementType != duplicateICFRLog.Agreement_Type__r.Name)
	    	{
	    		result = false;
	    	}	 
	    	   	
	    	if(this.documentType != duplicateICFRLog.Document_Type__c)
	    	{
	    		result = false;
	    	}
	    	
	    	if(this.versionNumber != duplicateICFRLog.Amendment_Number__c)
	    	{
	    		result = false;
	    	}	   

			try {
		    	if(Date.parse(this.startDate) != duplicateICFRLog.Effective_Date__c)
		    	{
		    		result = false;
		    	}
			} 
			catch(Exception ex) 
			{
				result = false;
			}
	    	 	
	    	if(this.contractManager != duplicateICFRLog.MCC_Contract_Manager__r.External_ID_gne__c)
	    	{
	    		result = false;
	    	}	
	    	    	    	
	    	if(this.mccManager != duplicateICFRLog.MCC_Manager__r.External_ID_gne__c)
	    	{
	    		result = false;
	    	}	 
	    	   	    	    	
	    	if(this.retroEffectiveDated != duplicateICFRLog.Retro_Effective_Dated__c)
	    	{
	    		result = false;
	    	}
	    	    	    	    	
	    	if(this.chargeBackComponentChange != duplicateICFRLog.Chargeback_Component__c)
	    	{
	    		result = false;
	    	}
	    	    	    	    	
	    	if(this.impactsRevenueRecognition != duplicateICFRLog.Impacts_Revenue_Recognition__c)
	    	{
	    		result = false;
	    	}
			
	    	return result;
	    }

		/*
		 * checkAccountType()
		 *
		 * @Description: This method validates if Account Type (lookup) exists in SFDC Database
		 * @Returns: List<String> with some errors
		 */
	    private List<String> checkAccountType()
	    {
	    	List<String> result = new List<String>();

			if(String.isNotBlank(this.accountType))
			{
		    	try {
		    		SPCM_Customer_Type__c customerType = [SELECT Id, Is_Active__c FROM SPCM_Customer_Type__c WHERE Name = :this.accountType LIMIT 1];
		    		this.customerTypeId = customerType.Id;
		    		if(!customerType.Is_Active__c)
		    		{
		    			result.add('[SFDC_ERR_CODE_02] Account Type \'' + this.accountType + '\' is not active.');
		    		}
		    	} catch(Exception ex) {
		    		result.add('[SFDC_ERR_CODE_02] Invalid Account Type \'' + this.accountType + '\'.');
		    	}
			}
	
	    	return result;
	    }
	    		
		/*
		 * checkAgreementType()
		 *
		 * @Description: This method validates if Agreement Type (lookup) exists in SFDC Database
		 * @Returns: List<String> with some errors
		 */
	    private List<String> checkAgreementType()
	    {
	    	List<String> result = new List<String>();
	    		    		    	
			if(String.isNotBlank(this.agreementType))
			{
		    	try {
		    		SPCM_Agreement_Type__c agreementType = [SELECT Id, Is_Active__c FROM SPCM_Agreement_Type__c WHERE Name = :this.agreementType LIMIT 1];
		    		this.agreementTypeId = agreementType.Id;
		    		if(!agreementType.Is_Active__c)
		    		{
		    			result.add('[SFDC_ERR_CODE_03] Agreement Type \'' + this.agreementType + '\' is not active.');
		    		}
		    	} catch(Exception ex) {
		    		result.add('[SFDC_ERR_CODE_03] Invalid Agreement Type \'' + this.agreementType + '\'.');
		    	}
			}
	    	
	    	return result;
	    }
	      	    		
		/*
		 * checkDocumentType()
		 *
		 * @Description: This method validates if Document Type (picklist value) exists in SFDC Field Picklist Values
		 * @Returns: List<String> with some errors
		 */      
	    private List<String> checkDocumentType()
	    {
	    	List<String> result = new List<String>();
   		    		    	
			if(String.isNotBlank(this.documentType))
			{
				Set<String> picklistValues = new Set<String>();
				
				for(Schema.PicklistEntry ple : SPCM_ICFR_Log__c.Document_Type__c.getDescribe().getPicklistValues())
				{
					picklistValues.add(ple.getValue());
				}
				
				if(!picklistValues.contains(this.documentType))
				{
					result.add('[SFDC_ERR_CODE_04] Invalid Document Type \'' + this.documentType + '\'.');
				}
			}
	
	    	return result;
	    }
	    		
		/*
		 * checkDate()
		 *
		 * @Description: This method validates if Start Date is in correct format
		 * @Returns: List<String> with some errors
		 */            
	    private List<String> checkDate()
	    {
	    	List<String> result = new List<String>();
	    	
			if(String.isNotBlank(this.startDate))
			{
		    	try {
		    		this.effectiveDate = Date.parse(this.startDate);
		    	} catch(Exception ex) {
		    		result.add('[SFDC_ERR_CODE_05] Start Date has wrong format \'' + this.startDate + '\'. Please use MM/DD/YYYY format.');
		    	}
			}
	    	
	    	return result;
	    }
	    		
		/*
		 * checkUsers()
		 *
		 * @Description: This method validates if Contract Manager (lookup) and MCC Manager (lookup) are in SFDC Database matching by UnixId
		 * @Returns: List<String> with some errors
		 */  
	    private List<String> checkUsers()
	    {
	    	List<String> result = new List<String>();
	    		    		    		    		    		    	
			if(String.isNotBlank(this.contractManager) && String.isNotBlank(this.mccManager))
			{
		    	Set<String> unixIds = new Set<String>{ this.contractManager, this.mccManager };
	
				List<User> userList = [SELECT External_ID_gne__c, Id, IsActive FROM User WHERE External_ID_gne__c IN :unixIds];
			
				Set<String> userNameSet = new Set<String>();
		    	for(User u : userList)
		    	{
		    		this.unixIdToUserId.put(u.External_ID_gne__c, u.Id);
		    		userNameSet.add(u.External_ID_gne__c);
		    	}
		    	
		    	for(String unixId : unixIds)
		    	{
		    		if(!userNameSet.contains(unixId))
		    		{
		    			result.add('[SFDC_ERR_CODE_06] No User found with this UnixID \'' + unixId + '\'.');
		    		}
		    	}
			}
		    	
	    	return result;
	    }
	         	      	    		
		/*
		 * checkProducts()
		 *
		 * @Description: This method validates if Products (lookup) exists in SFDC Database
		 * @Notes: Products needs to be separated by semicolon
		 * @Returns: List<String> with some errors
		 */              
	    private List<String> checkProducts()
	    {
	    	List<String> result = new List<String>();
	    	
	    	if(String.isNotBlank(this.eligibleProducts))
	    	{
		    	Set<String> eligibleProductSet = new Set<String>();
		    	
		    	for(String productName : this.eligibleProducts.split(';'))
		    	{
		    		eligibleProductSet.add(productName.trim());
		    	}
		    	
		    	List<SPCM_Product__c> productList = [SELECT Id, Name, Is_Active__c FROM SPCM_Product__c WHERE Name IN :eligibleProductSet];
		    	
		    	for(SPCM_Product__c product : productList) 
		    	{
	    			if(product.Is_Active__c)
	    			{
			    		this.productIds.add(product.Id);
			    		eligibleProductSet.remove(product.Name);
	    			}
		    	}
		    	
		    	for(String eligibleProduct : eligibleProductSet) 
		    	{
		    		result.add('[SFDC_ERR_CODE_07] Invalid or inactive Product \'' + eligibleProduct + '\'.');
		    	}
	    	}
	    	
	    	return result;
	    }

    }
        	
	/*
	 * ICFRLogResult
	 *
	 * @Description: This is class that contains result for WebService which will be returned to Agiloft
	 * @Notes: Return values must be declared as WebService for Agiloft to see them
	 */
    global class ICFRLogResult 
    {
        WebService String ICFR_Log_Id;
        WebService String Status;
        WebService List<String> Errors;
      	
		/*
		 * ICFRLogResult
		 *
		 * @Description: Constructor
		 * @Notes: This Constructor is on Success
		 */            
        public ICFRLogResult(String icfrLogId) 
        {
        	this.ICFR_Log_Id = icfrLogId;
        	this.Status = 'SUCCESS';
        	this.Errors = null;
        }      
        	
		/*
		 * ICFRLogResult
		 *
		 * @Description: Constructor
		 * @Notes: This Constructor is on Error
		 */            
        public ICFRLogResult(List<String> errors) 
        {
        	this.ICFR_Log_Id = null;
        	this.Status = 'ERROR';
        	this.Errors = errors;
        }  
                       	
		/*
		 * ICFRLogResult
		 *
		 * @Description: Constructor
		 * @Notes: This Constructor is on duplicate warning
		 */            
        public ICFRLogResult(SPCM_ICFR_Log__c duplicatedICFRLog) 
        {
        	this.ICFR_Log_Id = duplicatedICFRLog.Id;
        	this.Status = 'SUCCESS';
        	this.Errors = new List<String> { '[SFDC_WARNING_CODE_00] Duplicate found. Data in the duplicate matches the eWorkflow record ' + duplicatedICFRLog.Name + ' (' + duplicatedICFRLog.Id + ').' };
        }         
       	
		/*
		 * ICFRLogResult
		 *
		 * @Description: Constructor
		 */            
        public ICFRLogResult() 
        {
        	this.ICFR_Log_Id = null;
        	this.Status = 'WARNING';
        	this.Errors = new List<String> { 'In development' };
        }
    }

}