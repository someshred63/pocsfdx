global with sharing class CFAR_AddressBookNew_Controller extends CFAR_BaseController {
    
    public String contactId {get; set;}
    public CFAR_Contact_gne__c contact {get; set;}
    public Boolean isNew {get; set;}
    public Boolean isEdit {get; set;}
    private transient List<SelectOption> contactSearchList1;
    private transient List<SelectOption> contactSearchList2;
    private transient List<SelectOption> contactSearchList3;
    private transient List<SelectOption> contactSearchList4;
    public String selectedContact {get; set;}
    public Boolean isPrimaryInternal {get; set;}
    public Map<String, SelectOption> availableRolesMap {get; set;}
    public List<SelectOption> primaryRoles {get; set;}
    public List<SelectOption> secondaryRoles {get; set;}
    public List<SelectOption> tertiaryRoles {get; set;}
    private Map<String, SelectOption> availableRolesMapForPrimary;
    private Map<String, SelectOption> availableRolesMapForSecondary;
    private Map<String, SelectOption> availableRolesMapForTertiary;
    private Map<String, Boolean> roleIsInternalMap;
    public List<SelectOption> availableUsers {get; set;}
    public List<SelectOption> availableDegrees {get; set;}
    public List<String> selectedDegrees {get; set;}
    private Set<Id> selectedDegreesSet;
    public CFAR_AddressUtils contactAddressUtil {get; set;}
    private List<SelectOption> wholeContactsSearchList;
    public Integer messageNumber {get;set;} 
    
    public CFAR_AddressBookNew_Controller() {
        super();
        contactId = ApexPages.currentPage().getParameters().get('id');
        isNew = (ApexPages.currentPage().getParameters().get('isNew') != null);
        isEdit = (ApexPages.currentPage().getParameters().get('isEdit') != null);
        contactAddressUtil = new CFAR_AddressUtils(contactId);
        //init contact (it's unnecessary when there's no contactId and user doesn't create new contact)
        if (!(contactId == null && !isNew)) {
            initContact();
        }
        initWholeContactSearchList();
        setSelectedContactValue();
        loadRoleIsInternalMap();
        if (!isNew && !isEdit && contactId != null) {
            isPrimaryInternal = checkIsPrimaryInternal();
            initSelectedDegreesList();
        }
        if (isNew || isEdit) {
            loadAvailableRolesMap();
        }
        if (isNew) {
            isPrimaryInternal = false;
            initRolesListsAndMapsForNew();
            initAvailableUsersList();
            initSelectedDegreesList();
            initAvailableDegreesList();
        }
        if (isEdit) {
            isPrimaryInternal = checkIsPrimaryInternal();
            initRolesListsAndMapsForEdit();
            initAvailableUsersList();
            initSelectedDegreesList();
            initAvailableDegreesList();
        }
    }
     
    private void initContact() {
        //get existing contact
        if (contactId != null) {
            contact = [select Id, Name, Salutation_gne__c, Primary_Role_Function_gne__c, Other_Primary_Comments_gne__c, First_Name_gne__c, Role_Function_gne__c, Other_Secondary_Comments_gne__c,
                              Middle_Initials_gne__c, Tertiary_Role_Function_gne__c, Other_Tertiary_Comments_gne__c, Last_Name_gne__c, Suffix_gne__c, Employee_Type_gne__c,
                              Previous_Names_gne__c, Phone_gne__c, Active_Date_gne__c, Alternate_Phone_gne__c, Inactive_Date_gne__c, Mobile_Phone_gne__c, Fax_gne__c, Email_gne__c,
                              User_ref_gne__c, User_ref_gne__r.LastName, User_ref_gne__r.FirstName, Comments_gne__c, Search_Name__c, Active_gne__c
                       from CFAR_Contact_gne__c
                       where Id = :contactId];
        }
        //init new contact
        else {
            contact = new CFAR_Contact_gne__c();
            contactAddressUtil.addNewAddress();
        }
    }

    private void initWholeContactSearchList() {
    	wholeContactsSearchList = new List<SelectOption>();
    	wholeContactsSearchList.add(new SelectOption('', '--None--', true));
    	for (CFAR_Contact_gne__c cnt : [select Id, Search_Name__c from CFAR_Contact_gne__c where Search_Name__c != null order by Search_Name__c limit 3999]) {
            wholeContactsSearchList.add(new SelectOption(cnt.Id, cnt.Search_Name__c));
        }
    }
    
    public List<SelectOption> getContactSearchList1() {
    	contactSearchList1 = CFAR_Utils.getContactSearchListPart1(wholeContactsSearchList);
    	return contactSearchList1;
    }
    
    public List<SelectOption> getContactSearchList2() {
    	contactSearchList2 = CFAR_Utils.getContactSearchListPart2(wholeContactsSearchList);
    	return contactSearchList2;
    }
    
    public List<SelectOption> getContactSearchList3() {
    	contactSearchList3 = CFAR_Utils.getContactSearchListPart3(wholeContactsSearchList);
    	return contactSearchList3;
    }
    
    public List<SelectOption> getContactSearchList4() {
    	contactSearchList4 = CFAR_Utils.getContactSearchListPart4(wholeContactsSearchList);
    	return contactSearchList4;
    }
    
    private void setSelectedContactValue() {
    	selectedContact = '';
    	if (contact != null && !isNew) {
            selectedContact = contact.Id;
        }
    }
    
    private void initAvailableDegreesList() {
        availableDegrees = new List<SelectOption>();
        for (CFAR_Degree_gne__c degree : [select Id, Name, Active_gne__c from CFAR_Degree_gne__c order by Name]) {
            if (degree.Active_gne__c == true || (degree.Active_gne__c == false && selectedDegreesSet.contains(degree.Id))) {
                availableDegrees.add(new SelectOption(degree.Id, degree.Name));
            }
        }
    }

    @RemoteAction
    public static String checkIfReferencedOrLastActive(String contactJoinAddressId){
        
        CFAR_Team_Member_gne__c[] numberOfReferences = [SELECT Id, CFAR_Trial_ref_gne__r.Name FROM CFAR_Team_Member_gne__c WHERE contact_address_ref_gne__c =: contactJoinAddressId];
        CFAR_Contact_Address_JO_gne__c[] currentAddress = [SELECT Active_gne__c,CFAR_Contact_ref_gne__c FROM CFAR_Contact_Address_JO_gne__c WHERE Id = :contactJoinAddressId];
        String Idr = String.valueOf(currentAddress[0].CFAR_Contact_ref_gne__c);
        List<CFAR_Contact_Address_JO_gne__c> addressList = [SELECT Active_gne__c FROM CFAR_Contact_Address_JO_gne__c WHERE CFAR_Contact_ref_gne__c = : Idr AND Active_gne__c = true];
        
        if (numberOfReferences.size() > 0)
            return 'isReferencedInTrial';
        else if (currentAddress[0].Active_gne__c && addressList.size() < 2)
            return 'isLastActiveAddress';
        else return 'canDelete';
    }
    
    private void initSelectedDegreesList() {
        if (isEdit) {
        	List<CFAR_Contact_Degree_gne__c> contactDegrees = [select CFAR_Degree_ref_gne__c from CFAR_Contact_Degree_gne__c where CFAR_Contact_ref_gne__c = :contactId order by frm_CFAR_Degree_ref_gne__c];
        	if (!contactDegrees.isEmpty()) {
        		selectedDegrees = new List<String>();
        		for (CFAR_Contact_Degree_gne__c cd : contactDegrees) {
        			selectedDegrees.add(cd.CFAR_Degree_ref_gne__c);
        		}
        	}
        }
        selectedDegreesSet = new Set<Id>();
        if (selectedDegrees != null && !selectedDegrees.isEmpty()) {
            for (String degree : selectedDegrees) {
            	selectedDegreesSet.add(Id.valueOf(degree));
            }
        }
    }
    
    private void initAvailableUsersList() {
        Id currentUserId;
        if (isEdit && contact.User_ref_gne__c != null) {
        	currentUserId = contact.User_ref_gne__c;
        }
        Set<Id> MSLsIds = new Set<Id>();
        for (PermissionSetAssignment psa : [select AssigneeId from PermissionSetAssignment where PermissionSet.Name like 'CFAR_MSL%']) {
            MSLsIds.add(psa.AssigneeId);
        }
        availableUsers = new List<SelectOption>{new SelectOption('', '--None--')};
        //select only users without cfar contacts
        if (currentUserId == null) {
        	for (User u : [select Id, FirstName, LastName from User
                       	   where (Id not IN (select User_ref_gne__c from CFAR_Contact_gne__c where User_ref_gne__c != null) and (Profile_Name_gne__c like 'GNE-CFAR-%' or Id IN :MSLsIds))
                           order by LastName, FirstName]) {
            	availableUsers.add(new SelectOption(u.Id, assembleSelectOptionName(u)));
        	}
        }
        else {
        	for (User u : [select Id, FirstName , LastName from User
                       	   where (Id not IN (select User_ref_gne__c from CFAR_Contact_gne__c where User_ref_gne__c != null and User_ref_gne__c != :currentUserId) and (Profile_Name_gne__c like 'GNE-CFAR-%' or Id IN :MSLsIds or Id = :currentUserId))
                           order by LastName, FirstName]) {
            	availableUsers.add(new SelectOption(u.Id, assembleSelectOptionName(u)));
        	}
        }
    }

    private String assembleSelectOptionName(User user){ 
        return String.isBlank(user.FirstName) ? user.LastName : user.LastName+', '+user.FirstName;
    }

    public PageReference goToTrialReassign() {
        PageReference pRef = new PageReference('/apex/CFAR_TrialReassign');
        pRef.getParameters().put('id', selectedContact);
        pRef.setRedirect(true);
        return pRef;
    }

    public PageReference goToSelectedContactDetailsPage() {
        PageReference pRef = null;
        if (!String.isBlank(selectedContact)) {
            pRef = new PageReference('/apex/CFAR_AddressBookNew');
            pRef.getParameters().put('id', selectedContact);
            pRef.setRedirect(true);
        }
        return pRef;
    }
    
    public PageReference addNewContact() {
        PageReference pRef = new PageReference('/apex/CFAR_AddressBookNew');
        pRef.getParameters().put('isNew', 'true');
        pRef.setRedirect(true);
        return pRef;
    }
    
    public PageReference editContact() {
        PageReference pRef = new PageReference('/apex/CFAR_AddressBookNew');
        pRef.getParameters().put('id', contactId);
        pRef.getParameters().put('isEdit', 'true');
        pRef.setRedirect(true);
        return pRef;
    }

    public PageReference deleteContact() {
        PageReference pRef;
        try {
            if (canDeleteContact()) {
                CFAR_SecurityUtils.deleteRecord(contact);
                pRef = new PageReference('/apex/CFAR_AddressBookNew');
                pRef.setRedirect(true);
            } else {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error: Contact cannot be deleted. Contact is used as Team Member.'));
            }
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
        }
        return pRef;
    }
    
    public Boolean canDeleteContact(){
        List<CFAR_Team_Member_gne__c> teamMembers = [SELECT Id, contact_address_ref_gne__c FROM CFAR_Team_Member_gne__c WHERE contact_address_ref_gne__c IN
                                                        (SELECT ID FROM CFAR_Contact_Address_JO_gne__c WHERE CFAR_Contact_ref_gne__c =: contactId)];
        return teamMembers.isEmpty();
    }
    
    private void loadAvailableRolesMap() {
        availableRolesMap = new Map<String, SelectOption>();
        List<CFAR_Roles_To_Users_Mapping_gne__c> rolesFromCustomSetting = CFAR_Roles_To_Users_Mapping_gne__c.getAll().values();
        for (CFAR_Roles_To_Users_Mapping_gne__c role : rolesFromCustomSetting) {
            availableRolesMap.put(role.Drop_down_value_gne__c, new SelectOption(role.Drop_down_value_gne__c, role.Drop_down_value_gne__c));
        }
    }

    private void initRolesListsAndMapsForNew() {
        availableRolesMapForPrimary = availableRolesMap.clone();
        availableRolesMapForSecondary = availableRolesMap.clone();
        availableRolesMapForTertiary = availableRolesMap.clone();
        
        List<String> valuesToSort = new List<String>();
        valuesToSort.addAll(availableRolesMap.keySet());
        valuesToSort.sort();
        
        List<SelectOption> initialSelectList = new List<SelectOption>{new SelectOption('', '--None--')};
        for (String s : valuesToSort) {
            initialSelectList.add(new SelectOption(s, s));
        }
        
        primaryRoles = initialSelectList.clone();
        secondaryRoles = initialSelectList.clone();
        tertiaryRoles = initialSelectList.clone();
    }
    
    private void initRolesListsAndMapsForEdit() {
        //Run rebuild methods to initialize all lists and maps and remove from each of them values chosen on other lists
        rebuild1();
        rebuild2();
        rebuild3();
    }
    
    private void loadRoleIsInternalMap() {
        roleIsInternalMap = new Map<String, Boolean>();
        for (CFAR_Roles_To_Users_Mapping_gne__c role : CFAR_Roles_To_Users_Mapping_gne__c.getAll().values()) {
            roleIsInternalMap.put(role.Drop_down_value_gne__c, !String.isBlank(role.Permissions_gne__c));
        }
    }
    
    public void onPrimaryRoleChange() {
        //check if chosen role maps to internal / external (to show user field or not)
        isPrimaryInternal = checkIsPrimaryInternal();       
        //always clear user field
        if (!isPrimaryInternal) {
            contact.User_ref_gne__c = null;
        }
        
        //clear other comment field
        contact.Other_Primary_Comments_gne__c = null;
        
        //rebuild lists and maps for 2 and 3
        rebuild2();
        rebuild3();     
    }
    
    public void onSecondaryRoleChange() {
        //clear other comment field
        contact.Other_Secondary_Comments_gne__c = null;
        
        //rebuild lists and maps for 1 and 3
        rebuild1();
        rebuild3();
    }
    
    public void onTertiaryRoleChange() {
        //clear other comment field
        contact.Other_Tertiary_Comments_gne__c = null;
        
        //rebuild lists and maps for 1 and 2
        rebuild1();
        rebuild2();
    }
    
    private void rebuild1() {
        availableRolesMapForPrimary = availableRolesMap.clone();
        if (!String.isBlank(contact.Role_Function_gne__c)) {
            availableRolesMapForPrimary.remove(contact.Role_Function_gne__c);
        }
        if (!String.isBlank(contact.Tertiary_Role_Function_gne__c)) {
            availableRolesMapForPrimary.remove(contact.Tertiary_Role_Function_gne__c);
        }
        List<String> primaryValuesToSort = new List<String>();
        primaryValuesToSort.addAll(availableRolesMapForPrimary.keySet());
        primaryValuesToSort.sort();
        primaryRoles = new List<SelectOption>{new SelectOption('', '--None--')};
        for (String s : primaryValuesToSort) {
            primaryRoles.add(new SelectOption(s, s));
        }
    }
    
    private void rebuild2() {
        availableRolesMapForSecondary = availableRolesMap.clone();
        if (!String.isBlank(contact.Primary_Role_Function_gne__c)) {
            availableRolesMapForSecondary.remove(contact.Primary_Role_Function_gne__c);
        }
        if (!String.isBlank(contact.Tertiary_Role_Function_gne__c)) {
            availableRolesMapForSecondary.remove(contact.Tertiary_Role_Function_gne__c);
        }
        List<String> secondaryValuesToSort = new List<String>();
        secondaryValuesToSort.addAll(availableRolesMapForSecondary.keySet());
        secondaryValuesToSort.sort();
        secondaryRoles = new List<SelectOption>{new SelectOption('', '--None--')};
        for (String s : secondaryValuesToSort) {
            secondaryRoles.add(new SelectOption(s, s));
        }
    }
    
    private void rebuild3() {
        availableRolesMapForTertiary = availableRolesMap.clone();
        if (!String.isBlank(contact.Primary_Role_Function_gne__c)) {
            availableRolesMapForTertiary.remove(contact.Primary_Role_Function_gne__c);
        }
        if (!String.isBlank(contact.Role_Function_gne__c)) {
            availableRolesMapForTertiary.remove(contact.Role_Function_gne__c);
        }
        List<String> tertiaryValuesToSort = new List<String>();
        tertiaryValuesToSort.addAll(availableRolesMapForTertiary.keySet());
        tertiaryValuesToSort.sort();
        tertiaryRoles = new List<SelectOption>{new SelectOption('', '--None--')};
        for (String s : tertiaryValuesToSort) {
            tertiaryRoles.add(new SelectOption(s, s));
        }
    }
    
    public PageReference cancelChanges() {
        PageReference pRef = new PageReference('/apex/CFAR_AddressBookNew');
        if (isEdit) {
            //redirect to view page for edited contact (for new redirect to empty form)
            pRef.getParameters().put('id', contactId);
        }
        pRef.setRedirect(true);
        return pRef;
    }
    
    private void manageContactDegreesJunctionObjects() {
    	List<CFAR_Contact_Degree_gne__c> contactDegreesToInsert = new List<CFAR_Contact_Degree_gne__c>();
    	if (isNew && selectedDegrees != null && !selectedDegrees.isEmpty()) {
    		for (String dgr : selectedDegrees) {
    			contactDegreesToInsert.add(new CFAR_Contact_Degree_gne__c(CFAR_Contact_ref_gne__c = contact.Id, CFAR_Degree_ref_gne__c = dgr));
    		}
    		insert contactDegreesToInsert;
    	}
    	else if (isEdit && contactId != null) {
    		List<CFAR_Contact_Degree_gne__c> contactDegreesToDel = new List<CFAR_Contact_Degree_gne__c>();
    		List<CFAR_Contact_Degree_gne__c> currentDegrees = [select CFAR_Degree_ref_gne__c from CFAR_Contact_Degree_gne__c where CFAR_Contact_ref_gne__c = :contactId];
    		Map<Id, CFAR_Contact_Degree_gne__c> currentDegreesMap = new Map<Id, CFAR_Contact_Degree_gne__c>();
    		for (CFAR_Contact_Degree_gne__c dgr : currentDegrees) {
    			currentDegreesMap.put(dgr.CFAR_Degree_ref_gne__c, dgr);
    		}
    		Set<Id> lastSelectedDegreesSet = new Set<Id>();
    		if (selectedDegrees != null && !selectedDegrees.isEmpty()) {
    			for (String dgr : selectedDegrees) {
    				Id degreeInId = Id.valueOf(dgr);
    				lastSelectedDegreesSet.add(degreeInId);
    				if (!currentDegreesMap.keySet().contains(degreeInId)) {
    					contactDegreesToInsert.add(new CFAR_Contact_Degree_gne__c(CFAR_Contact_ref_gne__c = contactId, CFAR_Degree_ref_gne__c = dgr));
    				}
    			}
    		}
    		for (Id dgr : currentDegreesMap.keySet()) {
    			if (!lastSelectedDegreesSet.contains(dgr)) {
    				contactDegreesToDel.add(currentDegreesMap.get(dgr));
    			}
    		}
    		CFAR_SecurityUtils.deleteRecords(contactDegreesToDel);
    		insert contactDegreesToInsert;
    	}
    }
    
    public String getDegreesDisplayed() {
    	String dd = null;
    	if (contactId != null) {
    		List<CFAR_Contact_Degree_gne__c> orderedDegrees = [select frm_CFAR_Degree_ref_gne__c from CFAR_Contact_Degree_gne__c where CFAR_Contact_ref_gne__c = :contactId order by frm_CFAR_Degree_ref_gne__c];
    		if (!orderedDegrees.isEmpty()) {
    			dd = '';
    			for (CFAR_Contact_Degree_gne__c dgr : orderedDegrees) {
    				dd += (dgr.frm_CFAR_Degree_ref_gne__c + ', ');
    			}
    			if (!String.isBlank(dd)) {
    				dd = dd.removeEnd(', ');
    			}
    		}
    	}
    	return dd;
    }
    
    public PageReference saveContact() {
        PageReference pref = null;
        System.Savepoint sp = Database.setSavepoint();
        try {
            if(!checkValidations()) {
                return pref;
            }
            if (isNew) {
                CFAR_SecurityUtils.insertRecord(contact);
                contactAddressUtil.saveAddressForContactId(contact.Id);
            }
            if (isEdit) {
                CFAR_SecurityUtils.updateRecord(contact);
            }
            manageContactDegreesJunctionObjects();
        }
        catch (Exception e) {
            Database.rollback(sp);
            ApexPages.addMessages(e);
            return pref;
        }
        //success
        pref = new PageReference('/apex/CFAR_AddressBookNew');
        pRef.getParameters().put('id', contact.Id);
        pRef.setRedirect(true);
        return pref;
    }
    
    private Boolean checkValidations() {
        Boolean valid = true;

        if (isEdit) {
            if (String.isBlank(contact.First_Name_gne__c) || String.isBlank(contact.Last_Name_gne__c) || contact.Active_Date_gne__c == null
            || String.isBlank(contact.Primary_Role_Function_gne__c)) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error: Please enter a value.'));
                valid = false;
            }
        }
        else{
            if (String.isBlank(contact.First_Name_gne__c) || String.isBlank(contact.Last_Name_gne__c) || contact.Active_Date_gne__c == null
            || String.isBlank(contact.Primary_Role_Function_gne__c) || !contactAddressUtil.checkNullValidationsForAddress()) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error: Please enter a value.'));
                valid = false;
            }
        }
        
        //check if there's already created contact for these user (duplicate check will show not user friendly message)
        if (isNew && !String.isBlank(String.valueOf(contact.User_ref_gne__c))) {
            List<CFAR_Contact_gne__c> existingContactForChosenUser = [select Id, First_Name_gne__c, Last_Name_gne__c from CFAR_Contact_gne__c where User_ref_gne__c =: contact.User_ref_gne__c limit 1];
            if (existingContactForChosenUser != null && !existingContactForChosenUser.isEmpty()) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'There is already contact ' + existingContactForChosenUser[0].First_Name_gne__c + ' ' + existingContactForChosenUser[0].Last_Name_gne__c + ' created for chosen User in the system!'));
                valid = false;
            }
        }

        if (!String.isBlank(String.valueOf(contact.Email_gne__c)) && String.valueOf(contact.Email_gne__c).contains('.@')) {
        	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Email: Invalid Email Address.'));
            valid = false;
        }
        return valid;
    }

    public  void showCantDeleteLastAddressError(){
         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Cannot delete contact address since it is currently the only address for this contact.'));       

    }

    public  void showCantDeleteReferencedAddressError(){
         ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Cannot delete contact address since it is referenced in one or more studies.'));       

    }     
    
    private Boolean checkIsPrimaryInternal() {
        Boolean retval = false;
        if (!String.isBlank(contact.Primary_Role_Function_gne__c)) {
            retval = roleIsInternalMap.get(contact.Primary_Role_Function_gne__c);
        }
        return (retval != null ? retval : false);
    }

}