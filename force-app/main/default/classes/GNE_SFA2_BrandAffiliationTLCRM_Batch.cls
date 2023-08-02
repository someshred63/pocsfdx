global class GNE_SFA2_BrandAffiliationTLCRM_Batch implements Database.Batchable<sObject>, Database.Stateful{

	private Set<Id> productsToActivate;
	private Set<Id> productsToDeactivate;
	private Boolean deltaOn;
	private final String APPLICATION_NAME = 'TLCRM';

	public GNE_SFA2_BrandAffiliationTLCRM_Batch(){
		init(true);
	}

	public GNE_SFA2_BrandAffiliationTLCRM_Batch(Boolean deltaIsOn){
		init(deltaIsOn);
	}

	private void init(Boolean deltaIsOn){
		productsToActivate = new Set<Id>();
		productsToDeactivate = new Set<Id>();
		deltaOn = deltaIsOn;
	}

	global Database.QueryLocator start(Database.BatchableContext BC){
		Datetime lastProcessTimeStamp = deltaOn == true ? this.getLastProcessExecutionTime(BC) : null;

		Set<Id> userIds = new Set<Id>();
		Set<Id> allProductsIds = new Set<Id>();
		Set<String> allTerritoriesNames = new Set<String>();
		Set<String> recTypesScope = new Set<String>();

		userIds = this.getUsersAndInitProductsMap(lastProcessTimeStamp);
		if (userIds.size() > 0){
			allProductsIds.addAll(productsToActivate);
			allProductsIds.addAll(productsToDeactivate);
			if (allProductsIds.size() > 0){
				allTerritoriesNames = this.getAllUsersTerritoriesNames(userIds);
				if (allTerritoriesNames.size() > 0){
					recTypesScope = this.getRecordTypes(userIds);
				}
			}
		}

		return userIds.size() == 0 || allProductsIds.size() == 0 || allTerritoriesNames.size() == 0 || recTypesScope.size() == 0 ? Database.getQueryLocator([SELECT Id FROM Account WHERE Id = '000000000000000']) : Database.getQueryLocator([
			SELECT Id,
				(SELECT Id, Account_vod__c, Products_vod__c, Brand_Affiliation_Status_gne__c FROM Product_Metrics_vod__r WHERE Products_vod__c In :allProductsIds)
			FROM Account
			WHERE Id In (SELECT Account_vod__c FROM TSF_vod__c Where External_Id_vod__c != null AND Address_vod__c != null AND Account_vod__c != null AND Territory_vod__c != null AND Territory_vod__c In :allTerritoriesNames)
				AND RecordType.DeveloperName In :recTypesScope]);
	}

	private DateTime getLastProcessExecutionTime(Database.BatchableContext BC) {
    	DateTime lastProcessExecutionTime = null;
    	for(AsyncApexJob job : [SELECT CreatedDate FROM AsyncApexJob
    		WHERE ApexClass.Name = :GNE_SFA2_BrandAffiliationTLCRM_Batch.class.getName() AND Id <> :BC.getJobId() AND ParentJobId = null AND JobType = 'BatchApex' AND Status = 'Completed' ORDER BY CreatedDate DESC LIMIT 1]) {
			lastProcessExecutionTime = job.CreatedDate;
			break;
		}
        return lastProcessExecutionTime;
    }

    private Set<Id> getUsersAndInitProductsMap(DateTime lastProcessTimeStamp){
		Set<Id> result = new Set<Id>();
		Set<String> inactiveProdQueues = new Set<String>{'GNE-CANADA-INACTIVE-PROD-QUEUE', 'GNE-INACTIVE-PROD-QUEUE'};
		for (My_Setup_Products_vod__c userProduct : Database.query('SELECT OwnerId, Product_vod__c, Product_vod__r.Owner.Name, IsDeleted FROM My_Setup_Products_vod__c WHERE Product_vod__c != null AND OwnerId In (SELECT Id FROM User WHERE Profile.Name Like \'GNE-TLS%\' AND IsActive = true) '
			+ (lastProcessTimeStamp != null ? ' AND LastModifiedDate >= :lastProcessTimeStamp' : '') + ' ALL ROWS ')){
			result.add(userProduct.OwnerId);
		 	if (userProduct.IsDeleted == true || inactiveProdQueues.contains(userProduct.Product_vod__r.Owner.Name.toUpperCase())){
		 		this.productsToDeactivate.add(userProduct.Product_vod__c);
			} else {
		 		this.productsToActivate.add(userProduct.Product_vod__c);
		 	}
		}
		if (this.productsToDeactivate.size() > 0){
			this.productsToDeactivate.removeAll(this.productsToActivate);

			if (this.productsToDeactivate.size() > 0){
				Set<Id> userProductsInUse = new Set<Id>();
				for (My_Setup_Products_vod__c userProduct : [SELECT Product_vod__c FROM My_Setup_Products_vod__c WHERE Product_vod__c IN :this.productsToDeactivate
					AND OwnerId In (SELECT Id FROM User WHERE Profile.Name Like 'GNE-TLS%' AND IsActive = true)	AND Product_vod__r.Owner.Name NOT IN :inactiveProdQueues]){
					userProductsInUse.add(userProduct.Product_vod__c);
				}
				if (userProductsInUse.size() > 0){
					this.productsToDeactivate.removeAll(userProductsInUse);
				}
			}
		}
		return result;
	}

    private Set<String> getAllUsersTerritoriesNames(Set<Id> userIds) {
    	Set<String> result = new Set<String>();
    	Map<Id, Territory2> userTerritories = new Map<Id, Territory2>([SELECT Name, External_id_gne__c FROM Territory2 WHERE Id in (SELECT Territory2Id FROM UserTerritory2Association WHERE UserId In :userIds) ORDER BY Name]);
    	if (userTerritories.size() == 0){
    		return result;
    	}
        String queryString = 'SELECT Name FROM Territory2 WHERE Name != null AND External_id_gne__c Like \'GNE-US%\' AND (NOT External_id_gne__c Like \'INACTIVE TERRITORIES%\')';
        String conditions = ' AND (';
        for(Territory2 t : userTerritories.values()) {
            conditions += 'External_id_gne__c Like \'' + t.External_id_gne__c + '%\' OR ';
        }
        Set<Id> userTerritoriesIds = userTerritories.keySet();
        queryString += conditions + 'Id IN : userTerritoriesIds) ORDER BY External_id_gne__c';
        for (Territory2 territory : (List<Territory2>)Database.query(queryString)){
        	result.add(territory.Name);
        }
        return result;
    }

	private Set<String> getRecordTypes(Set<Id> userIds){
		Set<String> result = new Set<String>();

		Set<String> brandNames = new Set<String>();
		Set<String> roleNames = new Set<String>();

		for (SFA2_User_Group_Mapping_gne__c userGroupMapping : [SELECT Brand_gne__c, Role_gne__c FROM SFA2_User_Group_Mapping_gne__c WHERE Application_gne__c = :APPLICATION_NAME AND Profile_Name_gne__c Like 'GNE-TLS%']){
			brandNames.add(userGroupMapping.Brand_gne__c);
			roleNames.add(userGroupMapping.Role_gne__c);
		}

		for (SFA2_Configuration_Object_Detail_gne__c confObj : [SELECT Configuration_Object_ref_gne__r.Record_Type_gne__c FROM SFA2_Configuration_Object_Detail_gne__c
			WHERE Configuration_Object_ref_gne__r.Is_Active_gne__c = true
				AND Configuration_Object_ref_gne__r.Object_Name_gne__c = 'Account'
				AND Configuration_Object_ref_gne__r.Application_Type__c = :APPLICATION_NAME
				AND Configuration_Object_ref_gne__r.Brand_gne__c In :brandNames
				AND Configuration_Object_ref_gne__r.Role_gne__c In :roleNames
				AND Configuration_Object_ref_gne__r.Record_Type_gne__c != null
				AND Is_Active_gne__c = true
				AND Type_gne__c = 'Related List'
				AND API_Name_gne__c = 'Product_Metrics_vod__c']){
				result.add(confObj.Configuration_Object_ref_gne__r.Record_Type_gne__c);
			}
		return result;
	}

	global void execute(Database.BatchableContext bc, List<sObject> scope) {
		if (scope == null){
    		return;
    	}
    	List<Product_Metrics_vod__c> baToUpdate = new List<Product_Metrics_vod__c>();
    	List<Product_Metrics_vod__c> baToInsert = new List<Product_Metrics_vod__c>();

    	for (Account account : (List<Account>)scope){
    		Set<Id> accountBAsProducts = new Set<Id>();
    		for (Product_Metrics_vod__c ba : account.Product_Metrics_vod__r){
         		accountBAsProducts.add(ba.Products_vod__c);
         		if (this.productsToActivate.contains(ba.Products_vod__c) && ba.Brand_Affiliation_Status_gne__c != 'Active'){
        			ba.Brand_Affiliation_Status_gne__c = 'Active';
        			baToUpdate.add(ba);
        		} else if (this.productsToDeactivate.contains(ba.Products_vod__c) && ba.Brand_Affiliation_Status_gne__c != 'Inactive'){
        			ba.Brand_Affiliation_Status_gne__c = 'Inactive';
        			baToUpdate.add(ba);
        		}
        	}
        	Set<Id> newBAs = this.productsToActivate.clone();
        	newBAs.removeAll(accountBAsProducts);
        	for (Id prodId : newBAs){
        		baToInsert.add(
        			new Product_Metrics_vod__c(
        				Account_vod__c = account.Id,
        				Products_vod__c = prodId,
        				Brand_Affiliation_Status_gne__c = 'Active'
        			)
        		);
        	}
    	}
    	try {
    		if (baToUpdate.size() > 0){
    			Database.SaveResult[] saveResultsUpdate = Database.update(baToUpdate, false);
    		}
    		if (baToInsert.size() > 0){
    			Database.SaveResult[] saveResultsInsert = Database.insert(baToInsert, false);
    		}
    	} catch(Exception ex){
    		System.debug('[GNE_SFA2_BrandAffiliationTLCRM_Batch] an error occured: ' + ex);
    	}
	}

	global void finish(Database.BatchableContext bc){
		//sendConfirmationEmail();
    }

    private void sendConfirmationEmail(){
    	String emailSubject = 'Completed brand affiliation addition.';
		String emailBody = 'Brand Affiliation addition is completed for Accounts in User Territories.';
		try{
			String userEmail = '';
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setToAddresses(new List<String>{userEmail});
	    	mail.setBccSender(false);
	    	mail.setSubject(emailSubject);
			mail.setHtmlBody(emailBody);
			List<Messaging.Sendemailresult> emailResult = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
			if(emailResult != null && !emailResult[0].isSuccess()) {
				List<Messaging.SendEmailError> emailError = emailResult[0].getErrors();
				if(emailError!=null) {
					System.debug('email error : ' + emailError[0].getMessage());
				}
			}
		} catch(Exception ex) {
			throw ex;
		}
    }

}