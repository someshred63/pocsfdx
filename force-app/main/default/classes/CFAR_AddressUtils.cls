public with sharing class CFAR_AddressUtils {
    public String contactId {get; set;}
    public Id selectedInstitutionId {get; set;}
    public Id selectedAddressId {get; set;}
    public Id editedAddressId {get; set;}
    public Id addressIdToDelete {get; set;}
	public Boolean editingAddress {get; set;}
    public Boolean addingAddress {get; set;}
    public CFAR_Contact_Address_JO_gne__c newOrEditedAddress {get; set;}
    public Map<Id, CFAR_Institution_gne__c> institutionMap {get; set;}
    public Map<Id, CFAR_Contact_Address_JO_gne__c> addressJOMap {get; set;}
	public List<CFAR_Contact_Address_JO_gne__c> addressList {get; set;}
	private Map<Id, CFAR_Contact_Address_gne__c> addressesMap = new Map<Id, CFAR_Contact_Address_gne__c>();
	private Map<Id, Id> uniqContactAddress = new Map<Id, Id>();
	private CFAR_Institution_gne__c selectedInstitution;

	public CFAR_AddressUtils(String contactId) {
		this.contactId = contactId;
		editingAddress = false;
        addingAddress = false;
        initAddresses();
        fillInstitutionList();
	}

	public CFAR_Parent_Organization_gne__c getParentOrganization() {
	    return selectedInstitution.Parent_Organization__r;
	}

    public List<SelectOption> getInstitutionSelectOptions() {
        List<SelectOption> institutionSelectOptions = new List<SelectOption>{new SelectOption('','--None--')};
        if (selectedInstitutionId != null && !institutionMap.containsKey(selectedInstitutionId)) {            
            institutionSelectOptions.add(new SelectOption(selectedInstitution.Id, selectedInstitution.Name));
        }
        for (CFAR_Institution_gne__c institution : institutionMap.values()) {
            institutionSelectOptions.add(new SelectOption(institution.Id, institution.Name));
        }
        return institutionSelectOptions;
    }

    public List<SelectOption> getAddressSelectOptions() {
        List<SelectOption> addressSelectOptions = new List<SelectOption>{new SelectOption('','--None--')};
        if(selectedInstitutionId != null) {
            String query = 'select Id, Name, Institution_gne__c, Postal_Code_gne__c, Zip_gne__c, Province_gne__c, State_gne__c, City_gne__c, Country_gne__c, Address_gne__c, Active_gne__c from CFAR_Contact_Address_gne__c'
                    + ' WHERE Institution_gne__c = :selectedInstitutionId AND (Active_gne__c = true';
            if (selectedAddressId != null) {
                query += ' OR Id = :selectedAddressId';
            }
            query += ') order by Name asc';
            for (CFAR_Contact_Address_gne__c address : Database.query(query)) {

                String fullAddress = address.Address_gne__c + ', ' + address.City_gne__c + ' ';

                if (address.Country_gne__c == 'USA')
                    fullAddress += address.State_gne__c + ' ' + address.Zip_gne__c;

                else
                    fullAddress += address.Province_gne__c + ' ' + address.Postal_Code_gne__c;

                addressSelectOptions.add(new SelectOption(address.Id, fullAddress));
                addressesMap.put(address.Id, address);
            }
        }
        return addressSelectOptions;
    }

    public boolean hasLastActiveAddressWhenSaving() {
        CFAR_Contact_Address_JO_gne__c[] activeAddressList = new List<CFAR_Contact_Address_JO_gne__c>();
        for(CFAR_Contact_Address_JO_gne__c joAddress : addressList){
            if(joAddress.Active_gne__c){
                activeAddressList.add(joAddress);
            }
        }
           return (null != activeAddressList && activeAddressList.size() == 0);
    }

	private void initAddresses() {
        addressList = CFAR_AddressUtils.getContactAddressList(contactId);
        //init here addressJOMap that'll be used for edits
        addressJOMap = new Map<Id, CFAR_Contact_Address_JO_gne__c>(addressList);
        uniqContactAddress.clear();
        for (CFAR_Contact_Address_JO_gne__c address : addressList) {
            uniqContactAddress.put(address.Contact_Address_ref_gne__c, address.Id);
        }
        selectedInstitutionId = null;
        selectedAddressId = null;
    }

    private void fillInstitutionList() {
        institutionMap = new Map<Id, CFAR_Institution_gne__c>(CFAR_AddressUtils.getActiveInstitutionList());
    }

    public void addNewAddress() {
        addingAddress = true;
        newOrEditedAddress = new CFAR_Contact_Address_JO_gne__c(CFAR_Contact_ref_gne__c = contactId);
        newOrEditedAddress.active_gne__c = true;
        addressList.add(newOrEditedAddress);
    }
    
    public void editAddress() {
        editingAddress = true;
        newOrEditedAddress = addressJOMap.get(editedAddressId);
        selectedInstitutionId = newOrEditedAddress.Contact_Address_ref_gne__r.Institution_gne__c;
        selectedAddressId = newOrEditedAddress.Contact_Address_ref_gne__c;
        setSelectedInstitutionFromSelectionId();
    }
    
    public Boolean validateNewAddress(boolean ValidateAddress){
    	Boolean isError = false;
    	if(selectedInstitutionId == null){
    		ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Institution cannot be blank. Please select a value.'));
    	}
    	if(selectedAddressId == null){
    		ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Institution Address cannot be blank. Please select a value.'));
    	}

        if(newOrEditedAddress.Active_gne__c == false && hasLastActiveAddressWhenSaving()){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Cannot deactivate contact address since it is currently the only active address for this contact.'));
        }

    	if(selectedInstitutionId == null || selectedAddressId == null || (newOrEditedAddress.Active_gne__c == false && hasLastActiveAddressWhenSaving())){
    		isError = true;
    	}
    	return isError;
    }
    
    public PageReference saveAddress() {
        PageReference pref = null;
        System.Savepoint sp = Database.setSavepoint();
        if (!validateNewAddress(true)) {
            if (newOrEditedAddress.Id == null) {
                insert newOrEditedAddress;
            } else {
                update newOrEditedAddress;
            }
        } else {
            Database.rollback(sp);
            return pref;
        }
        cleanAfterAddressSave();
        return pref;
    }

    public void saveAddressForContactId(Id contactId) {
    	this.contactId = contactId;
    	newOrEditedAddress.CFAR_Contact_ref_gne__c = contactId;
    	insert newOrEditedAddress;
    	cleanAfterAddressSave();
    }

    public PageReference deleteAddress() {
        PageReference pref = null;
        CFAR_Contact_Address_JO_gne__c addrJOToDelete = addressJOMap.get(addressIdToDelete);
        System.Savepoint sp = Database.setSavepoint();
        try {
            CFAR_SecurityUtils.deleteRecord(addrJOToDelete);
        } catch (Exception e) {
            Database.rollback(sp);
            ApexPages.addMessages(e);
        } finally {
            cleanAfterAddressSave();
        }
        return pref;
    }

    public void institutionSelected() {
        if (selectedInstitutionId != null) {
            setSelectedInstitutionFromSelectionId();
        }
        selectedAddressId = null;
        addressSelected();
    }

    public void addressSelected() {
        newOrEditedAddress.Contact_Address_ref_gne__c = selectedAddressId;
        newOrEditedAddress.Contact_Address_ref_gne__r = addressesMap.get(selectedAddressId);
    }
    
    public void cancelAddressChanges() {
       cleanAfterAddressSave();
    } 

    public void clearInstitutionSelection() {
        selectedInstitutionId = null;
    }
    
    private void cleanAfterAddressSave() {
        addingAddress = false;
        editingAddress = false;
        newOrEditedAddress = null;
        editedAddressId = null;
        addressIdToDelete = null;
        initAddresses();
    }

    public Boolean checkNullValidationsForAddress() {
        Boolean valid = true;
        if (String.isBlank(selectedInstitutionId)) {
            valid = false;
        }
        if (String.isBlank(selectedAddressId)) {
            valid = false;
        }
        return valid;
    }    

    private void setSelectedInstitutionFromSelectionId() {
        selectedInstitution = institutionMap.get(selectedInstitutionId);
        if (selectedInstitution == null) {
            selectedInstitution = [select Id, Name, Parent_Organization__c, Parent_Organization__r.Name, Active_gne__c from CFAR_Institution_gne__c
                    WHERE Id = :selectedInstitutionId LIMIT 1];
        }
    }

    public static List<CFAR_Institution_gne__c> getActiveInstitutionList() {
    	return [select Id, Name, Parent_Organization__c, Parent_Organization__r.Name, Active_gne__c, Parent_Organization__r.Active_gne__c
    			from CFAR_Institution_gne__c
    			where Active_gne__c = true AND Parent_Organization__r.Active_gne__c = true
    			order by Name asc];
    }

    public static List<CFAR_Contact_Address_JO_gne__c> getContactAddressList(Id contactId) {
        return getContactAddressList(new Set<Id>{contactId}, false);
    }

    public static List<CFAR_Contact_Address_JO_gne__c> getContactAddressList(Set<Id> contactIdSet, boolean activeOnly) {
        String sql = 'select Id, Department_Division_gne__c, Title_gne__c, active_gne__c, Contact_Address_ref_gne__r.Name, Contact_Address_ref_gne__r.Zip_gne__c, '
                + 'Contact_Address_ref_gne__r.State_gne__c, Contact_Address_ref_gne__r.Province_gne__c, Contact_Address_ref_gne__r.Postal_Code_gne__c, '
                + 'Contact_Address_ref_gne__r.Institution_Company_gne__c, Contact_Address_ref_gne__r.Country_gne__c, Contact_Address_ref_gne__r.City_gne__c, '
                + 'CFAR_Contact_ref_gne__c, Contact_Address_ref_gne__r.Address_gne__c, Contact_Address_ref_gne__r.Address_Type_ref_gne__c, '
                + 'Contact_Address_ref_gne__r.frm_Address_Type_ref_gne__c, Contact_Address_ref_gne__r.Institution_gne__c, Contact_Address_ref_gne__r.Institution_gne__r.Name, '
                + 'Contact_Address_ref_gne__r.Institution_gne__r.Parent_Organization__c,Contact_Address_ref_gne__r.Institution_gne__r.Parent_Organization__r.Name '
                + 'from CFAR_Contact_Address_JO_gne__c '
                + 'where CFAR_Contact_ref_gne__c IN :contactIdSet';
        if (activeOnly) {
            sql += ' AND Contact_Address_ref_gne__r.Active_gne__c = true';
        }
        sql += ' order by active_gne__c DESC, CreatedDate';
    	return Database.query(sql);
    }

}