public without sharing class GNE_CAN_Subscribe_DAO {
	
	 
	public static List<RecordType> getAccountAndAddressRecordTypes() {
		Set<String> rtNames = new Set<String>{
			GNE_CAN_Subscribe_Util.RECORD_TYPE_HCP,
			GNE_CAN_Subscribe_Util.RECORD_TYPE_HCO,
			GNE_CAN_Subscribe_Util.RECORD_TYPE_HCO_DEPARTMENT,
			GNE_CAN_Subscribe_Util.RECORD_TYPE_ADDRESS_HCP,
			GNE_CAN_Subscribe_Util.RECORD_TYPE_ADDRESS_HCO
		};
		
		return [SELECT Id, Name, SObjectType FROM RecordType WHERE Name IN :rtNames];
	}
	
	private static List<String> getStagingCustomerFields() {
		Set<String> stgCustFieldNames = GNE_CAN_Subscribe_Util.getFieldSetForObject(String.valueOf(Stg_SFA_Cust_Can__c.sObjectType));
		
		stgCustFieldNames.addAll(new Set<String>{
			String.valueOf(Stg_SFA_Cust_Can__c.Name),
			String.valueOf(Stg_SFA_Cust_Can__c.Acount_Type_can__c),
			String.valueOf(Stg_SFA_Cust_Can__c.FirstName_can__c),
			String.valueOf(Stg_SFA_Cust_Can__c.Gender_can__c),
			String.valueOf(Stg_SFA_Cust_Can__c.IsLocked_can__c),
			String.valueOf(Stg_SFA_Cust_Can__c.LastName_can__c),
			String.valueOf(Stg_SFA_Cust_Can__c.Middle_can__c),
			String.valueOf(Stg_SFA_Cust_Can__c.MRM_Status_can__c),
			String.valueOf(Stg_SFA_Cust_Can__c.Org_Name_can__c),
			String.valueOf(Stg_SFA_Cust_Can__c.Roche_Cust_Id_can__c),
			String.valueOf(Stg_SFA_Cust_Can__c.Prim_IMS_Id_can__c),
			String.valueOf(Stg_SFA_Cust_Can__c.Salutation_can__c),
			String.valueOf(Stg_SFA_Cust_Can__c.Title_can__c),
			String.valueOf(Stg_SFA_Cust_Can__c.Src_Cust_Id_can__c),
			String.valueOf(Stg_SFA_Cust_Can__c.Cust_class_can__c),
			String.valueOf(Stg_SFA_Cust_Can__c.Subscribe_Status_can__c),
			String.valueOf(Stg_SFA_Cust_Can__c.Last_Subscribe_Date_can__c),
			String.valueOf(Stg_SFA_Cust_Can__c.Specialities_can__c),
			String.valueOf(Stg_SFA_Cust_Can__c.Sub_Type_can__c),
			String.valueOf(Stg_SFA_Cust_Can__c.Language_can__c),
			String.valueOf(Stg_SFA_Cust_Can__c.UAD_Ind_can__c),
			String.valueOf(Stg_SFA_Cust_Can__c.UCI_Id_can__c)
		});
		
		return new List<String>(stgCustFieldNames);
	}
	
	private static List<String> getStagingAddressFields() {
		Set<String> stgAddrFieldNames = GNE_CAN_Subscribe_Util.getFieldSetForObject(String.valueOf(Stg_SFA_Cust_Addr_Can__c.sObjectType));
		
		stgAddrFieldNames.addAll(new Set<String>{
			String.valueOf(Stg_SFA_Cust_Addr_Can__c.Name),
			String.valueOf(Stg_SFA_Cust_Addr_Can__c.Address_Line1_can__c),
			String.valueOf(Stg_SFA_Cust_Addr_Can__c.Address_Line2_can__c),
			String.valueOf(Stg_SFA_Cust_Addr_Can__c.Address_Type_can__c),
			String.valueOf(Stg_SFA_Cust_Addr_Can__c.City_can__c),
			String.valueOf(Stg_SFA_Cust_Addr_Can__c.Country_can__c),
			String.valueOf(Stg_SFA_Cust_Addr_Can__c.Fax_can__c),
			String.valueOf(Stg_SFA_Cust_Addr_Can__c.Location_Description_can__c),
			String.valueOf(Stg_SFA_Cust_Addr_Can__c.Phone_1_can__c),
			String.valueOf(Stg_SFA_Cust_Addr_Can__c.Phone_1_Ext_can__c),
			String.valueOf(Stg_SFA_Cust_Addr_Can__c.Postal_Code_can__c),
			String.valueOf(Stg_SFA_Cust_Addr_Can__c.Pri_Addr_Ind_can__c),
			String.valueOf(Stg_SFA_Cust_Addr_Can__c.Province_can__c),
			String.valueOf(Stg_SFA_Cust_Addr_Can__c.Roche_Addr_Id_can__c),
			String.valueOf(Stg_SFA_Cust_Addr_Can__c.Roche_Id_can__c),
			String.valueOf(Stg_SFA_Cust_Addr_Can__c.Src_Addr_Id_can__c),
			String.valueOf(Stg_SFA_Cust_Addr_Can__c.Stg_SFA_Cust_ref_can__c),
			String.valueOf(Stg_SFA_Cust_Addr_Can__c.Src_Id_can__c),
			String.valueOf(Stg_SFA_Cust_Addr_Can__c.UAD_Ind_can__c),
			String.valueOf(Stg_SFA_Cust_Addr_Can__c.LOCK_IND_can__c)
		});
		
		return new List<String>(stgAddrFieldNames);
	}
	
	private static List<String> getAccountFields() {
		Set<String> accountFieldNames = GNE_CAN_Subscribe_Util.getFieldSetForObject(String.valueOf(Account.sObjectType));
		
		accountFieldNames.addAll(new Set<String>{
			String.valueOf(Account.Account_Type_gne__c),
			String.valueOf(Account.FirstName),
			String.valueOf(Account.Gender_vod__c),
			String.valueOf(Account.MRM_Lock_can_gne__c),
			String.valueOf(Account.LastName),
			String.valueOf(Account.Middle_vod__c),
			String.valueOf(Account.MRM_Status_can_gne__c),
			String.valueOf(Account.Name),
			String.valueOf(Account.Roche_Id_can_gne__c),
			String.valueOf(Account.Prim_IMS_Id_can__c),
			String.valueOf(Account.Salutation),
			String.valueOf(Account.PersonTitle),
			String.valueOf(Account.RecordTypeId),
			String.valueOf(Account.Region_Code_gne__c),
			String.valueOf(Account.LastModifiedDate),
			String.valueOf(Account.OwnerId),
			String.valueOf(Account.Specialties_can_gne__c),
			String.valueOf(Account.Sub_Type_can_gne__c),
			String.valueOf(Account.Language_of_Preference_can_gne__c),
			String.valueOf(Account.UCI_Id_can__c)
		});
		
		return new List<String>(accountFieldNames);
	}
	
	private static List<String> getAddressFields() {
		Set<String> addressFieldNames = GNE_CAN_Subscribe_Util.getFieldSetForObject(String.valueOf(Address_vod__c.sObjectType));
		
		addressFieldNames.addAll(new Set<String>{
			String.valueOf(Address_vod__c.Account_vod__c),
			String.valueOf(Address_vod__c.Name),
			String.valueOf(Address_vod__c.Address_line_2_vod__c),
			String.valueOf(Address_vod__c.Address_Type_gne__c),
			String.valueOf(Address_vod__c.City_vod__c),
			String.valueOf(Address_vod__c.Country_gen__c),
			String.valueOf(Address_vod__c.Fax_vod__c),
			String.valueOf(Address_vod__c.Org_Name_can_gne__c),
			String.valueOf(Address_vod__c.Phone_vod__c),
			String.valueOf(Address_vod__c.Phone_1_Ext_gne__c),
			String.valueOf(Address_vod__c.Postal_Code_can_gne__c),
			String.valueOf(Address_vod__c.Primary_vod__c),
			String.valueOf(Address_vod__c.Province_can_gne__c),
			String.valueOf(Address_vod__c.Inactive_vod__c),
			String.valueOf(Address_vod__c.Inactivate_Reason_gne__c),
			String.valueOf(Address_vod__c.MRM_Lock_add_can_gne__c),
			String.valueOf(Address_vod__c.Roche_Address_Id_can__c),
			String.valueOf(Address_vod__c.RecordTypeId),
			String.valueOf(Address_vod__c.LastModifiedDate)
		});
		
		return new List<String>(addressFieldNames);
	}
	
	/**
	Retrieves staging customers records with connected addresses.
	*/	
	public static List<Stg_SFA_Cust_Can__c> getCustomersWithAddressesByIds(Set<Id> stgCustIds) {
		List<String> stgCustFieldNames = getStagingCustomerFields();
		List<String> stgAddrFieldNames = getStagingAddressFields();
		
		return Database.query(String.format(
			'SELECT {0}, (SELECT {1} FROM {2}) FROM {3} WHERE Id IN :stgCustIds',
			new String[]{
				String.join(stgCustFieldNames, ','),
				String.join(stgAddrFieldNames, ','),
				Stg_SFA_Cust_Addr_Can__c.Stg_SFA_Cust_ref_can__c.getDescribe().getRelationshipName(),
				String.valueOf(Stg_SFA_Cust_Can__c.sObjectType)
			}
		));
	}
	
	/**
	Retrieves staging customers records with connected addresses.
	*/	
	public static List<Stg_SFA_Cust_Addr_Can__c> getCustomerAddressesByIds(Set<Id> stgAddrIds) {
		List<String> stgAddrFieldNames = getStagingAddressFields();
		
		return Database.query(String.format(
			'SELECT {0} FROM {1} WHERE Id IN :stgAddrIds',
			new String[]{
				String.join(stgAddrFieldNames, ','),
				String.valueOf(Stg_SFA_Cust_Addr_Can__c.sObjectType)
			}
		));
	}
	
	public static List<Account> getAccountsByRocheIds(Set<String> rocheIds){
		return 
		[
		SELECT
			Id,
			Roche_Id_can_gne__c
		FROM Account
		WHERE Roche_Id_can_gne__c IN :rocheIds
		];
		
	}
	
	/**
	Retrieves SFDC Account records which should be updated - takes records which has ID	field matched with values from staging objects.
	*/
	public static List<Account> getAccountsBySfdcIds(Set<String> srcCustIds){
		List<String> accountFieldNames = getAccountFields();
		
		return Database.query(String.format(
			'SELECT {0} FROM {1} WHERE Id IN :srcCustIds',
			new String[]{
				String.join(accountFieldNames, ','),
				String.valueOf(Account.sObjectType)
			}
		));
	}
	
	public static List<Address_vod__c> getAddressesByRocheIds(Set<String> rocheIds){
		return 
		[
		SELECT
			Id,
			Roche_Address_Id_can__c,
			Account_vod__c,
			Account_vod__r.Roche_Id_can_gne__c
		FROM Address_vod__c
		WHERE Roche_Address_Id_can__c IN :rocheIds
		];
		
	}
	
	/**
	Retrieves SFDC Address records which should be updated - takes records which has ID field matched with values from staging objects.
	*/
	public static List<Address_vod__c> getAddressesBySfdcIds(Set<String> addrSfdcIds){
		List<String> addressFieldNames = getAddressFields();
		
		return Database.query(String.format(
			'SELECT {0} FROM {1} WHERE Id IN :addrSfdcIds',
			new String[]{
				String.join(addressFieldNames, ','),
				String.valueOf(Address_vod__c.sObjectType)
			}
		));
	}
	
	public static List<Stg_SFA_Subscribe_Apex_Job_Error__c> getErrorsByRocheIds(Set<String> rocheIds) {
		Set<String> recordIds = new Set<String>();
		
		Set<Id> accountIds = new Set<Id>();
		Set<Id> addressIds = new Set<Id>();
		Set<String> addressRocheIds = new Set<String>();
		
		for(Stg_SFA_Cust_Can__c stgCustomer : [SELECT Id, Src_Cust_Id_can__c, 
												(SELECT Id, Roche_Addr_Id_can__c, Src_Addr_Id_can__c  FROM Stg_SFA_Cust_ref_can__r) 
											   FROM Stg_SFA_Cust_Can__c
											   WHERE Roche_Cust_Id_can__c IN :rocheIds]) {
			recordIds.add(stgCustomer.Id);
			
			if(stgCustomer.Src_Cust_Id_can__c!=null) {
				accountIds.add((Id)stgCustomer.Src_Cust_Id_can__c);
			}
			
			for(Stg_SFA_Cust_Addr_Can__c stgAddress : stgCustomer.Stg_SFA_Cust_ref_can__r) {
				recordIds.add(stgAddress.Id);
				addressRocheIds.add(stgAddress.Roche_Addr_Id_can__c);
				
				if(stgAddress.Src_Addr_Id_can__c!=null) {
					addressIds.add((Id)stgAddress.Src_Addr_Id_can__c);
				}
			}
		}
		
		for(Account sfdcAccount : [SELECT Id FROM Account WHERE 
												Id IN :accountIds]) {
			recordIds.add(sfdcAccount.Id);
		}
		
		for(Address_vod__c sfdcAddress : [SELECT Id FROM Address_vod__c WHERE 
														Id IN :addressIds]) {
			recordIds.add(sfdcAddress.Id);
		}
		
		return getErrorsByRecordIds(recordIds);
	}
	
	public static List<Stg_SFA_Subscribe_Apex_Job_Error__c> getErrorsByRocheAddressIds(Set<String> rocheAddressIds) {
		Set<String> recordIds = new Set<String>();
		
		Set<Id> addressIds = new Set<Id>();
		
		for(Stg_SFA_Cust_Addr_Can__c stgAddress : [SELECT Id, Src_Addr_Id_can__c  FROM Stg_SFA_Cust_Addr_Can__c
												   WHERE Roche_Addr_Id_can__c IN :rocheAddressIds]) {
			recordIds.add(stgAddress.Id);
			
			if(stgAddress.Src_Addr_Id_can__c!=null) {
				addressIds.add((Id)stgAddress.Src_Addr_Id_can__c);
			}
		}
		
		for(Address_vod__c sfdcAddress : [SELECT Id FROM Address_vod__c WHERE 
											Id IN :addressIds]) {
			recordIds.add(sfdcAddress.Id);
		}
		
		return getErrorsByRecordIds(recordIds);
	}
	
	private static List<Stg_SFA_Subscribe_Apex_Job_Error__c> getErrorsByRecordIds(Set<String> recordIds) {
		return [SELECT
					Id,
					Name,
					Record_Id_can__c,
					Object_Name_can__c,
					Object_Type_can__c,
					Code_Type_can__c,
					Error_Description_can__c,
					Error_Level_can__c,
					Error_Type_can__c,
					Snippet_Name_can__c,
					CreatedDate,
					CreatedById,
					CreatedBy.Name,
					Job_Id_can__c,
					Job_Id_can__r.Job_Type_can__c,
					Job_Id_can__r.Log_can__c,
					Job_Id_can__r.Logging_Level_can__c,
					Job_Id_can__r.Name
				FROM Stg_SFA_Subscribe_Apex_Job_Error__c
				WHERE Record_Id_can__c IN :recordIds
				ORDER BY CreatedDate desc];
	}
}