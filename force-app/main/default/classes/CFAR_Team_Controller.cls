public with sharing class CFAR_Team_Controller extends CFAR_TrialBaseController {

    public Boolean addMember {get; set;}
    public Boolean editMemberFlag {get; set;}
    public CFAR_Team_Member_gne__c newMember {get; set;}
    public Id memberId {get; set;}  
    public Boolean hasMoreRoles {get; private set;} 
    public List<SelectOption> memberRoles {get; private set;}
    public Boolean isContractRole {get;set;}
    public Id selectedContactId {get;set;}
    
    private String memberToDeactivate;
    public static final Set<String> PRIMARY_ROLES_SET = new Set<String>{'Primary Contact'};
    public static final Set<String> INVESTIGATOR_ROLES_SET = new Set<String>{'Investigator'};
    public static final Set<String> MSL_ROLES_SET = new Set<String>{'Medical Science Liason'};
    public static final Set<String> ONE_MEMBER_ROLES = new Set<String>{'CPL = Clinical Program Leader', 'CA = Clinical Assistant', 'PEM = Planning and Execution Manager', 'SRT = Study Review Team Chair'};
    
    private List<SelectOption> wholeContactsSearchList;
    private transient List<SelectOption> contactSearchList1;
    private transient List<SelectOption> contactSearchList2;
    private transient List<SelectOption> contactSearchList3;
    private transient List<SelectOption> contactSearchList4;
    
    public Id newPCMemberId {get; set;}
    public Id newMSLMemberId {get; set;}
    public Id changeNotificationMemberId {get; set;}
    private Map<Id, CFAR_Team_Member_gne__c> teamMembersMap;
    public List<SelectOption> memberAddresses {get; set;}
    public List<SelectOption> addressTypeSelectOptions {get; set;}
    private Map<Id, CFAR_Contact_Address_gne__c> addresses = new Map<Id, CFAR_Contact_Address_gne__c>();
    public static final Map<String, Boolean> roleIsInternalMap {get; private set;}
    public static final Set<String> externalRoles {get; private set;}
    
    static {
        roleIsInternalMap = new Map<String, Boolean>();
        externalRoles = new Set<String>();
        for (CFAR_Roles_To_Users_Mapping_gne__c role : CFAR_Roles_To_Users_Mapping_gne__c.getAll().values()) {
            boolean emptyPermissions = String.isBlank(role.Permissions_gne__c);
            roleIsInternalMap.put(role.Drop_down_value_gne__c, !emptyPermissions);
            if (emptyPermissions) {
                externalRoles.add(role.Drop_down_value_gne__c);
            }
        }
    }

    public String sortExpression {get; 
        set {
            sortExpression = value;
            if(sortFieldOld == null) sortFieldOld = sortExpression;
            if(sortFieldOld == sortExpression) {
                if(sortDirection == 'desc') sortDirection = 'asc';
                else sortDirection = 'desc';
            } else {
                sortDirection = 'desc';
                sortFieldOld = sortExpression;
            }
        }
    }
    private String sortFieldOld;
    public String sortDirection {get; set;}       

    public CFAR_Team_Controller() {
        super(true);
        hasMoreRoles = false;
        memberRoles = new List<SelectOption>();
        memberAddresses = new List<SelectOption>();
        addressTypeSelectOptions = new List<SelectOption>();
        initContactOptions();
        fillAddressTypes();
    }

    public void fillTeamMembers() {
        getTeamMembers();
    }

    public List<CFAR_Team_Member_gne__c> getTeamMembers() {

        CFAR_SearchParameters params = new CFAR_SearchParameters();
        if (sortDirection != null) params.sortDirection = sortDirection;
        if (sortExpression != null) params.sortExpression = sortExpression;
        else params.sortExpression = 'frm_Is_Inactive_gne__c';

        if (sortExpression == 'Inactive_On_gne__c' && sortDirection == 'asc') params.sortExpression  = 'frm_Is_Inactive_gne__c, Inactive_On_gne__c';
        params.andEqualsParameters.put('CFAR_Trial_ref_gne__c', trial.Id);
        List<CFAR_Team_Member_gne__c> teamMemberList = CFAR_DAO.getTeamMembers(params);
        List<CFAR_Team_Member_gne__c> MemberList = new List<CFAR_Team_Member_gne__c>();
        if (sortExpression == null) {
            for (CFAR_Team_Member_gne__c member : teamMemberList) {
                if (member.frm_Function_Role_gne__c == 'SRT = Study Review Team Chair')
                    MemberList.add(member);
            }
            for (CFAR_Team_Member_gne__c member : teamMemberList) {
                if (member.frm_Function_Role_gne__c == 'MSD = Medical Science Director')
                    MemberList.add(member);
            }
            for (CFAR_Team_Member_gne__c member : teamMemberList) {
                if (member.frm_Function_Role_gne__c == 'MSL = Medical Science Liaison')
                    MemberList.add(member);
            }
            for (CFAR_Team_Member_gne__c member : teamMemberList) {
                if (member.frm_Function_Role_gne__c == 'CSM = Clinical Study Manager')
                    MemberList.add(member) ;
            }
            for (CFAR_Team_Member_gne__c member : teamMemberList) {
                if (member.frm_Function_Role_gne__c == 'CA = Clinical Assistant')
                    MemberList.add(member);
            }
            for (CFAR_Team_Member_gne__c member : teamMemberList) {
                if (member.frm_Function_Role_gne__c == 'PI = Primary (or Principal) Investigator')
                    MemberList.add(member);
            }
            for (CFAR_Team_Member_gne__c member : teamMemberList) {
                if (member.frm_Function_Role_gne__c == 'Sub-I = Sub-investigator')
                    MemberList.add(member);
            }
            for (CFAR_Team_Member_gne__c member : teamMemberList) {
                if (member.frm_Function_Role_gne__c == 'SC = Study Coordinator')
                    MemberList.add(member);
            }
            for (CFAR_Team_Member_gne__c member : teamMemberList) {
                if (member.frm_Function_Role_gne__c == 'Ph = Pharmacist')
                    MemberList.add(member);
            }                        
            for (CFAR_Team_Member_gne__c member : teamMemberList) {
                if (member.frm_Function_Role_gne__c != 'SRT = Study Review Team Chair'
                        && member.frm_Function_Role_gne__c != 'MSD = Medical Science Director'
                        && member.frm_Function_Role_gne__c != 'MSL = Medical Science Liaison'
                        && member.frm_Function_Role_gne__c != 'CSM = Clinical Study Manager'
                        && member.frm_Function_Role_gne__c != 'CA = Clinical Assistant'
                        && member.frm_Function_Role_gne__c != 'PI = Primary (or Principal) Investigator'
                        && member.frm_Function_Role_gne__c != 'Sub-I = Sub-investigator'
                        && member.frm_Function_Role_gne__c != 'SC = Study Coordinator'
                        && member.frm_Function_Role_gne__c != 'Ph = Pharmacist')
                    MemberList.add(member);
            }
            teamMemberList = MemberList;
        }
        teamMembersMap = new Map<Id, CFAR_Team_Member_gne__c>(teamMemberList);
        return teamMemberList;
    }
    
    public void initContactOptions() {
        wholeContactsSearchList = new SelectOption[]{};
        CFAR_SearchParameters searchParms = new CFAR_SearchParameters();
        searchParms.andEqualsParameters.put('Active_gne__c','true'); 
        searchParms.sortExpression = 'Search_Name__c'; 
        searchParms.sortDirection = 'asc';  
        wholeContactsSearchList.addAll(CFAR_Utils.getContactSelectOptions(searchParms)) ;
    }
    
    public Boolean getIsStandardUser() {
        Boolean retVal = false;
    	Profile prof = [select Name from Profile where Id =: UserInfo.getProfileId() limit 1][0];
    	if (prof.Name.equals('GNE-CFAR-User-New')) {
    		retVal = true;
    	}
    	return retVal;
    }
    
    public Boolean getIsAdmin() {
    	Boolean retVal = false;
    	Profile prof = [select Name from Profile where Id =: UserInfo.getProfileId() limit 1][0];
    	if (prof.Name.equals('GNE-CFAR-IT-Admin-New') || prof.Name.equals('System Administrator') || prof.Name.equals('GNE-SYS-Support-MedAffairs') || prof.Name.equals('GNE-MA-Support') || prof.Name.equals('GNE-CFAR-Admin-New')) {
    		retVal = true;
    	}
    	return retVal;
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
    
    public void addNewMember() {
        resetError();
        selectedContactId = null;
        addMember = true;
        memberRoles = new List<SelectOption>();
        memberAddresses.clear();
        addressTypeSelectOptions.clear();
        newMember = new CFAR_Team_Member_gne__c(CFAR_Trial_ref_gne__c = trial.Id, Active_On_gne__c = System.today());
    }

    private Boolean hasActiveRole(Set<String> roleNamesSet, Map<String, String> roleMapping, List<CFAR_Team_Member_gne__c> teamMembers, Id memberToOmit) {
        for(CFAR_Team_Member_gne__c t : teamMembers) {
            if(roleNamesSet.contains(roleMapping.get(t.frm_Function_Role_gne__c)) && !(t.Inactive_On_gne__c != null && t.Inactive_On_gne__c <= System.today()) && t.Active_On_gne__c <= System.today() && t.Contact_address_ref_gne__r.CFAR_Contact_ref_gne__c != memberToOmit){
            	memberToDeactivate = t.frm_Name_gne__c;
            	return true;
            }
        }
        return false;
    }
    
	private Boolean hasActiveOneMemberRole(List<CFAR_Team_Member_gne__c> teamMembers, Id memberToOmit, String newMemberFunctionRole) {
    	for(CFAR_Team_Member_gne__c t : teamMembers) {	
    		if(String.valueOf(t.frm_Function_Role_gne__c).equals(newMemberFunctionRole) && !(t.Inactive_On_gne__c != null && t.Inactive_On_gne__c <= System.today()) && t.Active_On_gne__c <= System.today() && t.Contact_address_ref_gne__r.CFAR_Contact_ref_gne__c != memberToOmit){
    			memberToDeactivate = t.frm_Name_gne__c;
            	return true;
    		}
    	}
    	return false;
    }
  
    public PageReference submitMember() {
        isError = false;    
        if(String.isBlank(newMember.Id))  {
            setDefaultAddressForInternalRole();
            
            if(String.isBlank(selectedContactId)) {
                isError = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Name cannot be blank. Please enter a value.'));
            }
            Boolean memberExists = false;
            
            	for (CFAR_Team_Member_gne__c teamMember : teamMembersMap.values()) {
            		if (teamMember.Contact_address_ref_gne__r.CFAR_Contact_ref_gne__c == selectedContactId && teamMember.frm_Is_Inactive_gne__c == false) {
            			memberExists = true;
            			break;
            		}
            	}

            if (memberExists) {
                isError = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'This person already exists in the study'));
            }  
        }

        if (String.isBlank(newMember.Contact_address_ref_gne__c) && !String.isBlank(selectedContactId)) {
            isError = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Address cannot be blank. Please enter a value.'));
        }
        if (String.isBlank(newMember.address_type_ref_gne__c) && !String.isBlank(selectedContactId)) {
            isError = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Address Type cannot be blank. Please enter a value.'));
        }
        if (String.isBlank(newMember.Function_Role_gne__c)) {
            isError = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Function Role cannot be blank. Please enter a value.'));
        }

        if (String.isBlank(String.valueOf(newMember.Active_On_gne__c))) {
            isError = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Active On cannot be blank. Please enter a value.'));
        }
        
        if(newMember.Inactive_On_gne__c != null && newMember.Active_On_gne__c >= newMember.Inactive_On_gne__c) {
            isError = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Active date should be before Inactive date'));
        }
        
        if(!String.isBlank(String.valueOf(newMember.Active_On_gne__c)) && newMember.Active_On_gne__c > System.today()) {
            isError = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Active On cannot be in the future'));
         }
        
        if(!String.isBlank(String.valueOf(newMember.Inactive_On_gne__c)) && newMember.Inactive_On_gne__c > System.today()) {
            isError = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Inactive On cannot be in the future'));
         }
         
        if(newMember.Active_On_gne__c <= System.today() && (newMember.Inactive_On_gne__c == null || newMember.Inactive_On_gne__c > System.today())){
            Map<String, String> sampleRoleMapping = CFAR_Utils.getUserRoleMapping();
            List<CFAR_Team_Member_gne__c> sampleTeamMembers = teamMembersMap.values();

            if(INVESTIGATOR_ROLES_SET.contains(sampleRoleMapping.get(newMember.Function_Role_gne__c)) && hasActiveRole(INVESTIGATOR_ROLES_SET, sampleRoleMapping , sampleTeamMembers, selectedContactId)){
                isError = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please deactivate ' + memberToDeactivate + ' before activating this Investigator'));
            }
            if(ONE_MEMBER_ROLES.contains(newMember.Function_Role_gne__c) && hasActiveOneMemberRole(sampleTeamMembers, selectedContactId, newMember.Function_Role_gne__c)) {
            	isError = true;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please deactivate ' + memberToDeactivate + ' before activating this ' + newMember.Function_Role_gne__c.split('=')[0].trim()));
            }
        }
        
        if(isError)
            return null;
        
        addMember = false;
        editMemberflag = false;
        ApexPages.StandardController ctrl = new ApexPages.StandardController(newMember);
        PageReference pr = ctrl.save();
        isError = pr == null && ApexPages.hasMessages();
        if(isError) {
            errorMessage = '';
            for(ApexPages.Message m : ApexPages.getMessages()) {
                errorMessage += m.getDetail();
            }
            return null;
        } 
        refreshTrial();
        clearEditMember();
        return null;
    }
    
    private void setDefaultAddressForInternalRole() {
        if (!getIsExternalRole()){
            List<CFAR_Contact_Address_JO_gne__c> addressesJO = getActiveAddressForContact(selectedContactId);
            if (!addressesJO.isEmpty()) {
                if (newMember.Contact_Address_ref_gne__c == null) {
                    newMember.Contact_Address_ref_gne__c = addressesJO.get(0).Id;
                }
                if (newMember.Address_Type_ref_gne__c == null) {
                    newMember.Address_Type_ref_gne__c = addressesJO.get(0).Contact_Address_ref_gne__r.Address_Type_ref_gne__c;
                }
            }
        }
    }

    private void clearEditMember() {
        editMemberFlag = false;
        addMember = false;
        newMember = null;
        isContractRole = false;
    }

    public void cancelCreateMember() {
    	clearEditMember();
        resetError();
    }
    
    public void contactChanged() {
        memberRoles = new List<SelectOption>();
        if(selectedContactId == null) {
            return;
        }
        CFAR_Contact_gne__c contact = [select Primary_Role_Function_gne__c, Role_Function_gne__c, Tertiary_Role_Function_gne__c 
            from CFAR_Contact_gne__c where Id = :selectedContactId];
        
        memberRoles.add(new SelectOption(contact.Primary_Role_Function_gne__c,contact.Primary_Role_Function_gne__c));   
        newMember.Function_Role_gne__c = contact.Primary_Role_Function_gne__c;
        if(!String.isBlank(contact.Role_Function_gne__c)) {
            memberRoles.add(new SelectOption(contact.Role_Function_gne__c,contact.Role_Function_gne__c));   
        }
        if(!String.isBlank(contact.Tertiary_Role_Function_gne__c)) {
            memberRoles.add(new SelectOption(contact.Tertiary_Role_Function_gne__c,contact.Tertiary_Role_Function_gne__c)); 
        }
        if (contact.Primary_Role_Function_gne__c != null)
            isContractRole = checkIfContractRole(contact.Primary_Role_Function_gne__c);
        resetAddressPart(contact);
    }

    public boolean getHasMoreAddresses() {
        return addresses == null || addresses.isEmpty() || addresses.size() > 1;
    }

    public void addressChanged() {
        if (newMember.Contact_Address_ref_gne__c == null) {
            newMember.Address_Type_ref_gne__c = null;
        } else {
            newMember.Address_Type_ref_gne__c = addresses.get(newMember.Contact_Address_ref_gne__c).Address_Type_ref_gne__c;
        }
    }

    public List<SelectOption> getMemberAddresses2() {
        System.debug('Adam dbg - getMemberAddresses2');
        List<SelectOption> memberAddresses2 = new List<SelectOption>();

        if (selectedContactId != null) {
            List<CFAR_Contact_Address_JO_gne__c> addressesJO = getActiveAddressForContact(selectedContactId);
            if (addressesJO.size() > 0) {
                if (addressesJO.size() == 1 && isNewMember()) {
                    newMember.Contact_Address_ref_gne__c = addressesJO.get(0).Id;
                } else if (addressesJO.size() > 1 || newMember.Contact_Address_ref_gne__c == null) {
                    memberAddresses2.add(new SelectOption('', '--None--'));
                }
                addresses = new Map<Id, CFAR_Contact_Address_gne__c>();
                for (CFAR_Contact_Address_JO_gne__c addrJO : addressesJO) {

                    String address = addrJO.Contact_Address_ref_gne__r.Institution_gne__r.Name + ', ';
                    if (addrJO.Department_Division_gne__c != null)
                        address += addrJO.Department_Division_gne__c + ', ';

                    address += addrJO.Contact_Address_ref_gne__r.Address_gne__c + ', ' + addrJO.Contact_Address_ref_gne__r.City_gne__c + ' ';

                    if (addrJO.Contact_Address_ref_gne__r.Country_gne__c == 'USA')
                        address += addrJO.Contact_Address_ref_gne__r.State_gne__c + ' ' + addrJO.Contact_Address_ref_gne__r.Zip_gne__c;

                    else
                        address += addrJO.Contact_Address_ref_gne__r.Province_gne__c + ' ' + addrJO.Contact_Address_ref_gne__r.Postal_Code_gne__c;

                    memberAddresses2.add(new SelectOption(addrJO.Id, address));
                    addresses.put(addrJO.Id, addrJO.Contact_Address_ref_gne__r);
                }
            }
        }
        return memberAddresses2;
    }

    public List<SelectOption> getAddressTypeSelectOptions2() {
        List<SelectOption> addressTypes2 = new List<SelectOption>();
        if (newMember.Contact_Address_ref_gne__c != null) {
            if (newMember.Address_Type_ref_gne__c == null) {
                newMember.Address_Type_ref_gne__c = addresses.get(newMember.Contact_Address_ref_gne__c).Address_Type_ref_gne__c;
            }
            if (newMember.Address_Type_ref_gne__c == null) {
                addressTypes2.add(new SelectOption('', '--None--'));
            }
            for(CFAR_Address_Type_gne__c addressType : addressTypes) {
                addressTypes2.add(new SelectOption(addressType.Id, addressType.Name));
            }
        }
        return addressTypes2;
    }

    public boolean getIsExternalRole() {
        return (newMember != null) && CFAR_Team_Controller.isExternalRole(newMember.Function_Role_gne__c);
    }

    public static boolean isExternalRole(String role) {
        return String.isNotBlank(role) && CFAR_Team_Controller.externalRoles.contains(role);
    }

    private Boolean teamMemberHasContract(){
        CFAR_SearchParameters parameters = new CFAR_SearchParameters();
        Boolean hasContract = false;
        if (memberId != null) {
            parameters.andEqualsParameters.put('Team_Member_ref_gne__c', memberId);
            CFAR_Budget_Contract_gne__c[] contractList = CFAR_DAO.getBudgetContracts(parameters);
            if (contractList.size() > 0) {
                hasContract = true;
            } 
        }
        return hasContract;
    }


	public Boolean isExternalVendor(){
		 if(newMember.Function_Role_gne__c.equals(CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR)
        || newMember.Function_Role_gne__c.equals(CFAR_TeamMemberHelper.ROLE_SPECIALTY_LAB_CONTACT)
        || newMember.Function_Role_gne__c.equals(CFAR_TeamMemberHelper.ROLE_DRUG_DEPOT_CONTACT)
        || newMember.Function_Role_gne__c.equals(CFAR_TeamMemberHelper.ROLE_READING_CENTER_CONTACT)
        || newMember.Function_Role_gne__c.equals(CFAR_TeamMemberHelper.ROLE_OTHER_EXTERNAL)
        || newMember.Function_Role_gne__c.equals(CFAR_TeamMemberHelper.ROLE_PHARMACIST)
        || newMember.Function_Role_gne__c.equals(CFAR_TeamMemberHelper.ROLE_STUDY_COORDINATOR)
        || (newMember.Function_Role_gne__c.equals(CFAR_TeamMemberHelper.ROLE_SUB_INVESTIGATOR))){
        	return true;	
        }
        return false;   
	}
	
    public List<SelectOption> getDollarAndDrugSelectOptions() {
            List<SelectOption> selectOptions = new List<SelectOption>();
            CFAR_SearchParameters searchParms = new CFAR_SearchParameters();
            searchParms.sortExpression = 'Name'; 
            searchParms.sortDirection = 'asc'; 

            for (CFAR_Dollar_and_Drug_gne__c drg : CFAR_DAO.getDollarAndDrug(searchParms)) {
                if (drg.Active_gne__c == true || drg.Id == newMember.Dollar_and_Drug_ref_gne__c) {
                    selectOptions.add(new SelectOption(drg.Id, drg.Name));
                }
            }                 
            return selectOptions;           
        } 

    private void resetAddressPart(CFAR_Contact_gne__c contact) {
        newMember.Contact_Address_ref_gne__c = null;
        newMember.Address_Type_ref_gne__c = null;
    }

    // return true only when adding TM; false when editing
    private boolean isNewMember() {
        return newMember.Id == null;
    }

    public static List<CFAR_Contact_Address_JO_gne__c> getActiveAddressForContact(String contactId) {
        return [select Id, Contact_Address_ref_gne__r.Name,
                Contact_Address_ref_gne__r.Institution_Company_gne__c,
                Contact_Address_ref_gne__r.Address_Type_ref_gne__c,
                CFAR_Contact_ref_gne__c,
                Contact_Address_ref_gne__r.Institution_gne__c,
                Contact_Address_ref_gne__r.Institution_gne__r.Active_gne__c,
                Contact_Address_ref_gne__r.Institution_gne__r.Parent_Organization__c,
                Contact_Address_ref_gne__r.Institution_gne__r.Name,
                Contact_Address_ref_gne__r.Address_gne__c,
                Contact_Address_ref_gne__r.City_gne__c,
                Contact_Address_ref_gne__r.Postal_Code_gne__c,
                Contact_Address_ref_gne__r.Zip_gne__c,
                Contact_Address_ref_gne__r.State_gne__c,
                Contact_Address_ref_gne__r.Province_gne__c,
                Contact_Address_ref_gne__r.Country_gne__c,
                Department_Division_gne__c,
                Contact_Address_ref_gne__r.Institution_gne__r.Parent_Organization__r.Active_gne__c
                from CFAR_Contact_Address_JO_gne__c
                where CFAR_Contact_ref_gne__c = :contactId
                AND Contact_Address_ref_gne__r.Institution_gne__r.Active_gne__c = true
                AND Contact_Address_ref_gne__r.Institution_gne__r.Parent_Organization__r.Active_gne__c = true
                AND active_gne__c = true
                order by CreatedDate];
    }

    public void editMember() {
        resetError();
        editMemberFlag = true;
        addMember = true;
        memberRoles = new List<SelectOption>();

        newMember = teamMembersMap.get(memberId);
        selectedContactId = newMember.Contact_address_ref_gne__r.CFAR_Contact_ref_gne__c;
        if (newMember.Contact_Address_ref_gne__r.CFAR_Contact_ref_gne__r.Primary_Role_Function_gne__c != null)
            isContractRole = checkIfContractRole(newMember.Contact_Address_ref_gne__r.CFAR_Contact_ref_gne__r.Primary_Role_Function_gne__c);
        Boolean hasContract = teamMemberHasContract();
        if (!hasContract || (hasContract && (isContractRole(newMember.Contact_Address_ref_gne__r.CFAR_Contact_ref_gne__r.Primary_Role_Function_gne__c))))
            memberRoles.add(new SelectOption(newMember.Contact_Address_ref_gne__r.CFAR_Contact_ref_gne__r.Primary_Role_Function_gne__c, newMember.Contact_Address_ref_gne__r.CFAR_Contact_ref_gne__r.Primary_Role_Function_gne__c));

        if (!String.isBlank(newMember.Contact_Address_ref_gne__r.CFAR_Contact_ref_gne__r.Role_Function_gne__c)
        || !String.isBlank(newMember.Contact_Address_ref_gne__r.CFAR_Contact_ref_gne__r.Tertiary_Role_Function_gne__c)) {
            hasMoreRoles = true;
            if ( (!String.isBlank(newMember.Contact_Address_ref_gne__r.CFAR_Contact_ref_gne__r.Role_Function_gne__c)) && (!hasContract || (hasContract && (isContractRole(newMember.Contact_Address_ref_gne__r.CFAR_Contact_ref_gne__r.Role_Function_gne__c)))))
                memberRoles.add(new SelectOption(newMember.Contact_Address_ref_gne__r.CFAR_Contact_ref_gne__r.Role_Function_gne__c, newMember.Contact_Address_ref_gne__r.CFAR_Contact_ref_gne__r.Role_Function_gne__c));
            if ( (!String.isBlank(newMember.Contact_Address_ref_gne__r.CFAR_Contact_ref_gne__r.Tertiary_Role_Function_gne__c)) && (!hasContract || (hasContract && (isContractRole(newMember.Contact_Address_ref_gne__r.CFAR_Contact_ref_gne__r.Tertiary_Role_Function_gne__c)))))
                memberRoles.add(new SelectOption(newMember.Contact_Address_ref_gne__r.CFAR_Contact_ref_gne__r.Tertiary_Role_Function_gne__c, newMember.Contact_Address_ref_gne__r.CFAR_Contact_ref_gne__r.Tertiary_Role_Function_gne__c));
        } else {
            hasMoreRoles = false;
        }
    }

    private Boolean isContractRole(String role){
        if(role == 'PI = Primary (or Principal) Investigator'
        || role == 'SLC = Specialty Lab Contact'
        || role == 'DDC = Drug Depot Contact'
        || role == 'RCC = Reading Center Contact'
        || (role == 'Sub-I = Sub-investigator'))
            return true;
        else return false;
    }

    private Boolean checkIfContractRole(String role){
        if(role == 'PI = Primary (or Principal) Investigator'
        || role == 'SLC = Specialty Lab Contact'
        || role == 'DDC = Drug Depot Contact'
        || role == 'RCC = Reading Center Contact'
        || (role == 'Sub-I = Sub-investigator'))
            return true;
        else return false;
    }    
    
    public PageReference setNewPrimaryContact() {
    	System.Savepoint sp = Database.setSavepoint();
    	try {
    		CFAR_Team_Member_gne__c memberPC = teamMembersMap.get(newPCMemberId);
    		List<CFAR_Team_Member_gne__c> previousMemberPCList = new List<CFAR_Team_Member_gne__c>();
    		for (CFAR_Team_Member_gne__c teamMember : teamMembersMap.values()) {
    			if (teamMember.Is_Trial_Primary_Contact_gne__c == true && teamMember.Id != memberPC.Id) {
    				previousMemberPCList.add(teamMember);
    			}
    		}
    		trial.Genentech_Primary_Contact_ref_gne__c = memberPC.Contact_address_ref_gne__r.CFAR_Contact_ref_gne__c;
    		for (CFAR_Team_Member_gne__c member : previousMemberPCList) {
    			member.Is_Trial_Primary_Contact_gne__c = false;
    		}
    		CFAR_Utils.setAlreadyProcessed();
    		CFAR_SecurityUtils.updateRecord(trial);
    		update memberPC;
    		update previousMemberPCList;
    	}
    	catch (Exception e) {
            Database.rollback(sp);
            ApexPages.addMessages(e);
            return null;
        }
        //success
        refreshTrial();
        return null;
    }
    
    public PageReference setNewMSL() {
    	System.Savepoint sp = Database.setSavepoint();
    	try {
    		CFAR_Team_Member_gne__c memberMSL = teamMembersMap.get(newMSLMemberId);
    		List<CFAR_Team_Member_gne__c> previousMemberMSLList = new List<CFAR_Team_Member_gne__c>();
    		for (CFAR_Team_Member_gne__c teamMember : teamMembersMap.values()) {
    			if (teamMember.Is_Trial_MSL_gne__c == true && teamMember.Id != memberMSL.Id) {
    				previousMemberMSLList.add(teamMember);
    			}
    		}
    		trial.MSL_ref_gne__c = memberMSL.Contact_address_ref_gne__r.CFAR_Contact_ref_gne__c;
    		for (CFAR_Team_Member_gne__c member : previousMemberMSLList) {
    			member.Is_Trial_MSL_gne__c = false;
    		}
    		CFAR_Utils.setAlreadyProcessed();
    		CFAR_SecurityUtils.updateRecord(trial);
    		update memberMSL;
    		update previousMemberMSLList;
    	}
    	catch (Exception e) {
            Database.rollback(sp);
            ApexPages.addMessages(e);
            return null;
        }
        refreshTrial();
        return null;
    }
    
    public PageReference changeNotificationSetting() {
    	System.Savepoint sp = Database.setSavepoint();
    	try {
    		CFAR_Team_Member_gne__c memberToChangeNotificationsSetting = teamMembersMap.get(changeNotificationMemberId);
    		update memberToChangeNotificationsSetting;
    	}
    	catch (Exception e) {
            Database.rollback(sp);
            ApexPages.addMessages(e);
            return null;
        }
        return null;
    }

    private List<CFAR_Address_Type_gne__c> addressTypes;
    private void fillAddressTypes(){
        addressTypes = CFAR_DAO.getAddressTypes(new CFAR_SearchParameters());
    }
}