public with sharing class CFAR_InstitutionAddressMigration_Crtl {
	private static final String DELIMITER = ';';
	private static String ORGANIZATION_PLACEHOLDER = '<PLACEHOLDER> Parent Organisation';
	private static String INSTITUTION_PLACEHOLDER = '<PLACEHOLDER> Institution';
	private static String ADDRESS_PLACEHOLDER = '<PLACEHOLDER> Institution Address';
	public String csvInput {get; set;}
	Map<String, Id> institutionMap {get; set;}
	Map<String, Id> organizationMap {get; set;}
	Map<Id, CFAR_Contact_Address_gne__c> institutionAddressMap {get; set;}
	List<CFAR_Parent_Organization_gne__c> organizationsToInsertList {get; set;}
	List<CFAR_Institution_gne__c> institutionsToInsertList {get; set;}
	private Map<String, List<CFAR_Institution_gne__c>> orgName2InstitutionMap;
	private Map<String, List<CFAR_Contact_Address_gne__c>> instName2AddressMap;
	private List<MigrateRow> migrateRows;
	private Set<String> orgNameFromCsvSet;
	private Set<String> instNameFromCsvSet;
	private Set<Id> addrIdFromCsvSet;

	public void startMigration() {
		System.Savepoint sp = Database.setSavepoint();
		try {
			parseCsv();
			if (!migrateRows.isEmpty()) {
				fillInstitutionAddressMap();
				clearMigrationRowsFromFaultAddressId();
				// now addrIdFromCsvSet is filled with ids existing in database
				// instNameFromCsvSet is filled with institution names which should exist in database in order to connect address to them
				// orgNameFromCsvSet is filled with organization names which should exist in database in order to connect institution to them
			if (!migrateRows.isEmpty()) {
				orgName2InstitutionMap = new Map<String, List<CFAR_Institution_gne__c>>();
				instName2AddressMap = new Map<String, List<CFAR_Contact_Address_gne__c>>();
					// fills institutionMap with Name -> Id pairs of institution existing in database; others have to be inserted
				fillInstitutionMap();
					// fills organizationMap with Name -> Id pairs of organization existing in database; others have to be inserted
				fillOrganizationMap();

				organizationsToInsertList = new List<CFAR_Parent_Organization_gne__c>();
				institutionsToInsertList = new List<CFAR_Institution_gne__c>();

				for (MigrateRow row : migrateRows) {
						createFromMigrateRow(row);
				}

				CFAR_SecurityUtils.insertRecords(organizationsToInsertList);
				updateInstitutionWithOrgIds();

				CFAR_SecurityUtils.insertRecords(institutionsToInsertList);
				updateAddressWithInstitutionIds();

				update institutionAddressMap.values();
				}
			}
 		} catch (Exception e) {
 			ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Error occured:'));
 			ApexPages.addMessages(e);
 			System.debug('Adam dbg: ' + e);
			Database.rollback(sp);
 			throw e;
 		} finally {
		}
		// Database.rollback(sp);
	}

	private void parseCsv() {
		migrateRows = new List<MigrateRow>();
		addrIdFromCsvSet = new Set<Id>();
		System.debug(csvInput);
		String[] csvList = csvInput.split('\\n');
		System.debug(csvList.size());
		if (String.isNotBlank(csvInput.trim())) {
			for (String row : csvList) {
				parseCsvRow(row);
			}
		}
	}

	/**
	 * Creates MigrationRow representing one line to parse and adds it to migrateRows list.
	 * Additionally adds addrId to addrIdFromCsvSet which will for now store address ids which can exists i database.
	 **/
	private void parseCsvRow(String row) {
		String[] pia = row.split(CFAR_InstitutionAddressMigration_Crtl.DELIMITER, -1);
		if (!pia.isEmpty() && pia.size() == 3) {
			MigrateRow migrRow = new MigrateRow(pia[2], pia[1], pia[0]);
			migrateRows.add(migrRow);
			// orgNameFromCsvSet.add(migrRow.orgName);
			// instNameFromCsvSet.add(migrRow.instName);
			addrIdFromCsvSet.add(migrRow.addrId);
		} else {
			throw new MigrationException('Incorrect input format for row=' + row + ', pia=' + pia);
		}
	}

	/**
	 * Clears migrateRows list from lines with address Id that doesn't exists in database.
	 * Additionally it creates a set of organization names and institution names which should be created in database.
	 **/
	private void clearMigrationRowsFromFaultAddressId() {
		addrIdFromCsvSet = institutionAddressMap.keySet();
		orgNameFromCsvSet = new Set<String>();
		instNameFromCsvSet = new Set<String>();
		List<MigrateRow> tmpList = new List<MigrateRow>();
		for (MigrateRow migrRow : migrateRows) {
			if (addrIdFromCsvSet.contains(migrRow.addrId)) {
				tmpList.add(migrRow);
				orgNameFromCsvSet.add(migrRow.orgName);
				instNameFromCsvSet.add(migrRow.instName);
			}
		}
		migrateRows = tmpList;
	}

	private void createFromMigrateRow(MigrateRow row) {
		Id currentInstitutionAddressId = row.addrId;
		String currentInstitutionName = row.instName;
		String currentOrganizationName = row.orgName;
		Id currentInstitutionId = null;
		Id currentOrganizationId = null;

		if (institutionAddressMap.containsKey(currentInstitutionAddressId)) {
			//get Id if exists; null otherwise
			currentOrganizationId = migrateParentOrganization(currentOrganizationName);

			//get Id if exists; null otherwise
		currentInstitutionId = migrateInstitution(currentInstitutionName, currentOrganizationName, currentOrganizationId);

		//migrate address
			CFAR_Contact_Address_gne__c address = institutionAddressMap.get(currentInstitutionAddressId);
			// currentInstitutionId can be null - should update FK after inserting Parent Org
			if (null == currentInstitutionId) {
				instName2AddressMap.get(currentInstitutionName).add(address);
			} else {
				address.Institution_gne__c = currentInstitutionId;
			}	
		} //else in the input there is a address ID which doen't exists in database - rollback changes with error
	}

	private Id migrateParentOrganization(String currentOrganizationName) {
		Id currentOrganizationId = null;
		//check if organization exist in database
		//if not then 1) adds new organization to the list organizationsToInsertList
		//            2) adds organization name -> new list of institutions pair which should be connected
		if (organizationMap.containsKey(currentOrganizationName)) {
			currentOrganizationId = organizationMap.get(currentOrganizationName);
		} else if (orgName2InstitutionMap.containsKey(currentOrganizationName)) {
			System.debug('Adam DBG createFromMigrateRow currentOrganizationName=' + currentOrganizationName);
		} else {
			CFAR_Parent_Organization_gne__c newOrganization = new CFAR_Parent_Organization_gne__c();
			newOrganization.Name = currentOrganizationName;
			organizationsToInsertList.add(newOrganization);
			orgName2InstitutionMap.put(currentOrganizationName, new List<CFAR_Institution_gne__c>());
		}
		return currentOrganizationId;
	}

	private Id migrateInstitution(String currentInstitutionName, String currentOrganizationName, Id currentOrganizationId) {
		Id currentInstitutionId = null;
		if (institutionMap.containsKey(currentInstitutionName)) {
			currentInstitutionId = institutionMap.get(currentInstitutionName);
		} else if (instName2AddressMap.containsKey(currentInstitutionName)) {
			System.debug('Adam DBG migrateInstitution currentInstitutionName=' + currentInstitutionName + ', currentOrganizationName=' + currentOrganizationName + ', currentOrganizationId=' + currentOrganizationId);
		} else {
			CFAR_Institution_gne__c newInstitution = new CFAR_Institution_gne__c();
			newInstitution.Name = currentInstitutionName;
			newInstitution.Active_gne__c = true;
			// currentOrganizationId can be null - should update FK after inserting Parent Org
			if (String.isBlank(currentOrganizationId)) {
				orgName2InstitutionMap.get(currentOrganizationName).add(newInstitution);
			} else {
				newInstitution.Parent_Organization__c = currentOrganizationId;
				institutionsToInsertList.add(newInstitution);
			}
			instName2AddressMap.put(currentInstitutionName, new List<CFAR_Contact_Address_gne__c>());
		}
		return currentInstitutionId;
	}

	private void updateInstitutionWithOrgIds() {
		if (!orgName2InstitutionMap.isEmpty()) {
			// get Parent Organizations with Ids and name
			CFAR_SearchParameters params = new CFAR_SearchParameters();
			for (CFAR_Parent_Organization_gne__c org : getParentOrganizationList(orgName2InstitutionMap.keySet())) {
				for (CFAR_Institution_gne__c inst : orgName2InstitutionMap.get(org.Name)) {
					inst.Parent_Organization__c = org.Id;
					institutionsToInsertList.add(inst);
				}
			}
		}
	}

	private void updateAddressWithInstitutionIds() {
		if (!instName2AddressMap.isEmpty()) {
			// get Parent Organizations with Ids and name
			CFAR_SearchParameters params = new CFAR_SearchParameters();
			// params.andInParameters.put('Name', new List<String>(instName2AddressMap.keySet()));
			for (CFAR_Institution_gne__c inst : getInstitutionList(instName2AddressMap.keySet())) {
				for (CFAR_Contact_Address_gne__c addr : instName2AddressMap.get(inst.Name)) {
					addr.Institution_gne__c = inst.Id;
					// institutionAddressMap.put(addr);
				}
			}
		}
	}

	private void fillInstitutionMap() {
		institutionMap = new Map<String, Id>();
		for (CFAR_Institution_gne__c institution : getInstitutionList(instNameFromCsvSet)) {
			institutionMap.put(institution.Name, institution.Id);
		}
	}

	private void fillOrganizationMap() {
		organizationMap = new Map<String, Id>();
		for (CFAR_Parent_Organization_gne__c organization : getParentOrganizationList(orgNameFromCsvSet)) {
			organizationMap.put(organization.Name, organization.Id);
		}
	}

	private void fillInstitutionAddressMap() {
		institutionAddressMap =  new Map<Id, CFAR_Contact_Address_gne__c>(getInstitutionAddressList(addrIdFromCsvSet));
	}

	private List<CFAR_Parent_Organization_gne__c> getParentOrganizationList(Set<String> names) {
		return [select Id, Name, Active_gne__c from CFAR_Parent_Organization_gne__c WHERE Name IN :names];
			}

	private List<CFAR_Institution_gne__c> getInstitutionList(Set<String> names) {
		return [select Id, Name, Parent_Organization__c, Active_gne__c from CFAR_Institution_gne__c WHERE Name IN :names];
		}

	private List<CFAR_Contact_Address_gne__c> getInstitutionAddressList(Set<Id> ids) {
		return [select Id, Institution_gne__c from CFAR_Contact_Address_gne__c WHERE id IN :ids];
	}

	private String debug(List<sObject> objList) {
		String buff = 'sobjList=\n';
		for (sObject obj : objList) {
			buff += obj + '\n';
		}
		return buff;
	}

	class MigrateRow {
		String orgName;
		String instName;
		String addrId;

		public MigrateRow(String orgName, String instName, String addrId) {
			this.orgName = String.isEmpty(orgName) ? ORGANIZATION_PLACEHOLDER : orgName;
			this.instName = String.isEmpty(instName) ? INSTITUTION_PLACEHOLDER : instName;
			this.addrId = String.isEmpty(addrId) ? ADDRESS_PLACEHOLDER : addrId;
		}
	}

    @TestVisible
	class MigrationException extends Exception {
	}
}