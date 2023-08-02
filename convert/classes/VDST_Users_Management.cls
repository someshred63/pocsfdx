/** @date 6/4/2013
* @Author Marcin Pawlak
* @description User Managment (Provisioning) controller
*/
public class VDST_Users_Management {
    // Constants
    public final String                     GENE_VENDORNAME = 'Genentech';
    public final String                     GENE_VENDORCODE = 'GNE';
    public static final String                     GSSP_PERM_SET = 'VDST_Permission_Set_gne';
    // Privileges
    public VDST_Utils.PrivilegesWrapper     privileges          { get; set; }
    public Boolean                          canAccessPage       { get; set; }
    public Boolean                          isGene              { get; set; }
    // Managing groups
    public List<SelectOption>               groupItems          { get; set; }
    public String                           selectedGroup       { get; set; }
    public String                           selectedBehalfGroup { get; set; } //bdejnega
    public VDST_EventProvider_gne__c        selectedGroupObj    { get; set; }
    public VDST_EventProvider_gne__c        newProvider         { get; set; }
    // Others
    public List<VDST_User_gne__c>           usersList           { get; set; }
    public VDST_User_gne__c                 newUserAssignment   { get; set; }
    public List<VDST_EventProvider_gne__c>  providers           { get; set; }
    public String                           userId              { get; set; }
    public UserWrapper                      newPortalUser       { get; set; }
    // User info
    public String                           usrName             { get; set; }
    public String                           today               { get; set; }

    /** @date 6/4/2013
    * @Author Marcin Pawlak, Pawel Sprysak
    * @description VDST_Users_Management constructor
    */
    public VDST_Users_Management() {
        setUserPrivileges();
    }

    /** @date 6/4/2013
    * @Author Marcin Pawlak, Pawel Sprysak
    * @description Set user privileges method
    */
    private void setUserPrivileges() {
        setPageFields();
        // Check privileges
        privileges = new VDST_Utils.PrivilegesWrapper();
        validateUserAccess(VDST_Utils.getUserPrivileges());
        // Set primary values
        newPortalUser = new UserWrapper();
        newUserAssignment = new VDST_User_gne__c();
        usersList = new List<VDST_User_gne__c>();
        newProvider = new VDST_EventProvider_gne__c();
        // Setting group values
        setGroupItems();
        if(!isGene && canAccessPage) {
            selectedGroup = providers.get(0).Id;
            selectedGroupObj = providers.get(0);
            loadUsers();
        }
    }

    /** @date 3/5/2013
    * @Author Marcin Pawlak
    * @description Constructor for Controller
    */
    private void setPageFields() {
        usrName = UserInfo.getName();
        today = Date.today().format();
    }

    /** @date 6/13/2013
    * @Author Pawel Sprysak
    * @description Go to Event List Page
    * @return PageReference
    */
    public PageReference goToEventList() {
        PageReference pr = new PageReference('/apex/VDST_EventList');
        pr.setRedirect(true);
        return pr;
    }

    /** @date 10/2/2013
    * @Author Pawel Sprysak
    * @description Log-out button
    * @return PageReference
    */
    public PageReference logOut() {
        PageReference pr = new PageReference('/secur/logout.jsp');
        return pr.setRedirect(true);
    }

    /** @date 6/4/2013
    * @Author Marcin Pawlak, Pawel Sprysak
    * @description Method for validating user access to tool
    * @param List<VDST_User_gne__c> currentUsersVDST (List of User access objects)
    */
    public void validateUserAccess(List<VDST_User_gne__c> currentUsersVDST) {
        canAccessPage = false;
        if('Provisioner'.equals(privileges.userRole) || 'Proxy Submitter'.equals(privileges.userRole)) {
            canAccessPage = true;
        }
        isGene = false;
        if(GENE_VENDORNAME.equals(privileges.providerName) && GENE_VENDORCODE.equals(privileges.providerCode)) {
            isGene = true;
        }
    }

    /** @date 6/4/2013
    * @Author Marcin Pawlak, Pawel Sprysak
    * @description Method for setting groups into Select List
    */
    public void setGroupItems() {
            if(isGene) {
                providers = VDST_Utils.getEvProviderById(true, privileges.providerId);
            } else if(canAccessPage) {
                providers = VDST_Utils.getEvProviderById(false, privileges.providerId);
            }
            groupItems = new List<SelectOption>{new SelectOption('', '-Select-')};
            if(providers == null || providers.isEmpty()) {
                return;
            }

            for(VDST_EventProvider_gne__c provider : providers) {
                groupItems.add(new SelectOption(provider.Id, provider.VendorCode_gne__c + ' - ' + provider.VendorName_gne__c));
                if(privileges.providerId == provider.Id && !GENE_VENDORCODE.equals(provider.VendorCode_gne__c)){
                    selectedBehalfGroup = provider.Id;
                }
            }
    }

    /** @date 26/9/2013
    * @Author Bartlomiej Dejnega
    * @description Method for assinging user proxy
    * @return PageReference
    */
    public PageReference assignUserProxy(){
        List<VDST_User_gne__c> uList = [SELECT VDST_Proxy_gne__c, Id, User_gne__c FROM VDST_User_gne__c WHERE User_gne__c =: UserInfo.getUserId() LIMIT 1];
        if(uList.size() > 0){
            uList.get(0).VDST_Proxy_gne__c = selectedBehalfGroup;
            update uList;

            selectedGroup = null;
            setUserPrivileges();
        }
        return null;
    }


    /** @date 26/9/2013
    * @Author Bartlomiej Dejnega
    * @description Method for unassinging user proxy
    * @return PageReference
    */
    public PageReference unassignUserProxy(){
        List<VDST_User_gne__c> uList = [SELECT VDST_Proxy_gne__c, Id, User_gne__c  FROM VDST_User_gne__c WHERE User_gne__c =: UserInfo.getUserId() LIMIT 1];
        if(uList.size() > 0){
            uList.get(0).VDST_Proxy_gne__c = null;
            selectedBehalfGroup = '';
            update uList;

            selectedGroup = null;
            setUserPrivileges();
        }
        return null;
    }


    /** @date 6/4/2013
    * @Author Marcin Pawlak, Pawel Sprysak
    * @description Method for Loading Users to stage
    * @return PageReference
    */
    public PageReference loadUsers() {
        if(selectedGroup == null || ''.equals(selectedGroup)) {
            selectedGroupObj.VendorCode_gne__c = null;
            usersList = new List<VDST_User_gne__c>();
            return null;
        }
        selectedGroupObj = VDST_Utils.getEvProviderById(false, selectedGroup).get(0);
        usersList = VDST_Utils.getAllRelatedUsers(selectedGroupObj.Id);
        return null;
    }

    /** @date 6/4/2013
    * @Author Marcin Pawlak
    * @description Flag method - is group selected
    * @return Boolean
    */
    public Boolean getIsGroupSelected() {
        return (selectedGroup != null && !''.equals(selectedGroup));
    }

    /** @date 6/4/2013
    * @Author Marcin Pawlak, Pawel Sprysak
    * @description Method for saving new group
    * @return PageReference
    */
    public PageReference saveNewGroup() {
        if(isGene) {
            if(String.isBlank(newProvider.VendorName_gne__c)) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'Vendor Name is mandatory. '));
                return null;
            }
            if(String.isBlank(newProvider.VendorCode_gne__c)) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'Vendor Code is mandatory. '));
                return null;
            } else {
                newProvider.VendorCode_gne__c = newProvider.VendorCode_gne__c.toUpperCase();
            }
            for(VDST_EventProvider_gne__c provider : providers) {
                if(provider.VendorCode_gne__c.equalsIgnoreCase(newProvider.VendorCode_gne__c)) {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'Please enter unique Vendor Code.'));
                    return null;
                }
            }
            newProvider.VDST_EventProvider_gne__c = privileges.providerId;
            insert newProvider;

            setGroupItems();
            selectedGroupObj = newProvider;
            selectedGroup = newProvider.Id;
            loadUsers();
            newProvider = new VDST_EventProvider_gne__c();
        }
        return null;
    }

    /** @date 6/4/2013
    * @Author Pawel Sprysak
    * @description VF Method for canceling assignment
    * @return PageReference
    */
    public PageReference cancelAssignment() {
        newUserAssignment = new VDST_User_gne__c();
        return null;
    }

    /** @date 6/4/2013
    * @Author Pawel Sprysak, Marcin Pawlak
    * @description VF Method for saving assignment
    * @return PageReference
    */
    public PageReference saveAssignment() {
        if(insertAssignment()) {
            newUserAssignment = new VDST_User_gne__c();
            loadUsers();
        }
        return null;
    }

    /** @date 6/4/2013
    * @Author Pawel Sprysak, Marcin Pawlak
    * @description Method for inserting data to DB
    * @return Boolean
    */
    private Boolean insertAssignment() {
        try {
            if(selectedGroupObj.Id == null || newUserAssignment.Role_gne__c == null || newUserAssignment.User_gne__c == null) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Invalid data'));
                return false;
            }
            newUserAssignment.VDST_Event_Provider__c = selectedGroupObj.Id;
            // Check is user allready assigned to other group
            String grp = VDST_Utils.checkIfAssignedToOtherGroup(newUserAssignment);
            if(grp != null) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'User already assigned to ' + grp));
                return false;
            }
            // Check is that relation already exist
            if(VDST_Utils.checkIfAssignmentExists(newUserAssignment)) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Assignment already exist'));
                return false;
            }
            insert newUserAssignment;
            assignGsspPermissionSetToUser(newUserAssignment.User_gne__c);
        } catch (Exception ex) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Error during User Assignment - ' + ex.getMessage()));
            return false;
        }
        return true;
    }

    /** @date 6/4/2013
    * @Author Marcin Pawlak
    * @description Unassigning User method
    * @return PageReference
    */
    public PageReference unassignUser() {
        try {
            System.debug('----------- userId ' + userId);
            VDST_User_gne__c usr = VDST_Utils.getUserRelationById(userId);
            if(usr != null) {
                delete usr;
                unassignGsspPermissionSetFromUser(usr.User_gne__c);
            }
            loadUsers();
        } catch(Exception ex) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage()));
        }
        return null;
    }

    /** @date 4/24/2015
    * @Author Konrad Malinowski
    * @description Method for assigning gSSP Permission Set to User
    * @param Id userId
    */
    @future
    private static void assignGsspPermissionSetToUser(Id userId) {
        VDST_Utils.assignPermissionSetToUser(userId, GSSP_PERM_SET);
    }

    /** @date 4/24/2015
    * @Author Konrad Malinowski
    * @description Method for unassigning gSSP Permission Set from User
    * @param Id userId
    */
    @future
    private static void unassignGsspPermissionSetFromUser(Id userId) {
        VDST_Utils.unassignPermissionSetFromUser(userId, GSSP_PERM_SET);
    }

    /** @date 6/4/2013
    * @Author Pawel Sprysak, Marcin Pawlak
    * @description VF Method canceling creating user
    * @return PageReference
    */
    public PageReference cancelPortalUser() {
        newUserAssignment = new VDST_User_gne__c();
        newPortalUser = new UserWrapper();
        return null;
    }

    /** @date 6/4/2013
    * @Author Pawel Sprysak, Marcin Pawlak
    * @description VF Method creating user
    * @return PageReference
    */
    public PageReference createPortalUser() {
        // Validate values
        if(String.isBlank(newPortalUser.firstName)) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'User First Name is mandatory. '));
        }
        if(String.isBlank(newPortalUser.lastName)) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'User Last Name is mandatory. '));
        }
        if(String.isBlank(newPortalUser.emailAddress)) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'User Email Address is mandatory. '));
        }
        if(String.isBlank(newUserAssignment.Role_gne__c)) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Role is mandatory. '));
        }
        if(ApexPages.hasMessages()) {
            return null;
        }

        VDST_Settings__c vdstSetting = VDST_Utils.getCustomSettings();
        Boolean isSimsActive = vdstSetting == null ? false : vdstSetting.Is_SIMS_Active__c;
        if (isSimsActive == true) {
            VDST_SIMS_Service wsSims = new VDST_SIMS_Service();
            Boolean result = wsSims.createSimsUser(newPortalUser.firstName, newPortalUser.lastName, '0', newPortalUser.emailAddress);
            if (result != true) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, 'User not created. Error during SIMS account activation.'));
                return null;
            }
        }
        createSFDCUser(true);
        loadUsers();
        return null;
    }

    /** @date 6/4/2013
    * @Author Pawel Sprysak, Marcin Pawlak
    * @description Method for creating SF user
    * @param Boolean realInsert (testing flag)
    * @return Boolean
    */
    public Boolean createSFDCUser(Boolean realInsert) {
        // rollback at the end if realInsert != true
        Savepoint sp = Database.setSavepoint();
        try {
            User ownerUser = [SELECT Id FROM User WHERE Name LIKE 'AGGS Case Monitor'];
            if(ownerUser == null) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Unable to find AGGS Case Monitor User'));
                return false;
            }
            System.debug('--------------- create portal user ' + newPortalUser.firstName + ' ' + newPortalUser.lastName + ' ' + newPortalUser.emailAddress);
            // Getting Record Type for Account
            List<RecordType> rtype = [SELECT Name, Id FROM RecordType WHERE sObjectType='Account' and DeveloperName='VDST_Vendor_Organization'];
            if(rtype==null || rtype.size() == 0) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'gSSP Vendor Organization - Record Type not found'));
                return false;
            }
            // Creating Account
            Account portalAccount = new Account(Name = 'VDST Account', RecordTypeId = rtype.get(0).Id, OwnerId = ownerUser.Id);
            Database.insert(portalAccount);
            System.debug('--------- account ' + portalAccount);
            // Get Record Type for Contact
            rtype = [Select Name, Id From RecordType where sObjectType='Contact' and DeveloperName='VDST_Vendor_Contact'];
            if(rtype==null  || rtype.size() == 0) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'gSSP Vendor Contact - Record Type not found'));
                return false;
            }
            // Creating Contact
            Contact contact = new Contact(FirstName = newPortalUser.firstName, Lastname = newPortalUser.lastName, RecordTypeId = rtype.get(0).Id ,AccountId = portalAccount.Id, Email = newPortalUser.emailAddress, Phone = newPortalUser.phone, OwnerId = ownerUser.Id);
            Database.insert(contact);
            System.debug('--------- contact ' + contact);
            // Get Profile Id
            Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'GNE-VDST-Partner-External' Limit 1];
            // Creating User
            String nickname = generateNickname(newPortalUser.firstName, newPortalUser.lastName);
            if(nickname == null) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Unable to create Nickname for User'));
                return false;
            }
            User user1 = new User(
                Username =  newPortalUser.emailAddress + VDST_Utils.getCustomSettingsIntExt().Username_Postfix__c, // + '.' +GlobalUtils.getEnvironment(),
                ContactId = contact.Id,
                ProfileId = portalProfile.Id,
                Alias = 'testal',
                Email =  newPortalUser.emailAddress,
                EmailEncodingKey = 'UTF-8',
                FirstName = newPortalUser.firstName,
                LastName = newPortalUser.lastName,
                CommunityNickname = nickname,
                Phone = newPortalUser.phone,
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US'
            );
            System.debug('---------- userName1 - ' + user1.Username);
            Database.insert(user1);
            // Assigning user to VDST Queue (future method)
            // because assingnUserToQueue is a future method
            if(realInsert == true) {
                QueueSobject queue1 = [SELECT CreatedById,Id,QueueId,SobjectType FROM QueueSobject where queue.DeveloperName = 'VDST_Queue_gne' Limit 1];
                assingnUserToQueue(user1.Id, queue1.QueueId);
            }
            newUserAssignment.User_gne__c = user1.Id;
            // Rollback if needed
            if(realInsert == true) {
                if(insertAssignment()) {
                    newUserAssignment = new VDST_User_gne__c();
                    loadUsers();
                } else {
                    Database.rollback(sp);
                    return false;
                }
            }
            else if(!insertAssignment()) {
                Database.rollback(sp);
                return false;
            }
            System.debug('--------- user ' + user1);

            if(realInsert == true) {
                newPortalUser = new UserWrapper();
                return true;
            } else {
                Database.rollback(sp);
                return true;
            }
        }
        catch(Exception ex)
        {
            Database.rollback(sp);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, ex.getMessage()));
            return false;
        }

    }

    /** @date 7/17/2013
    * @Author Pawel Sprysak
    * @description Method generating Nickname for User
    * @param String firstName (User first name), String lastName (User last name)
    */
    private String generateNickname(String firstName, String lastName) {
        String nickname = firstName + '.' +lastName;
        for(Integer i=0; i<100; i++) {
            List<User> userList = [SELECT Id FROM User WHERE CommunityNickname = :nickname];
            if(userList.size() < 1) {
                return nickname;
            } else {
                Integer randomNum = Integer.valueOf(Math.random()*1000);
                nickname = firstName + '.' +lastName + randomNum;
            }
        }
        return null;
    }

    /** @date 6/4/2013
    * @Author Marcin Pawlak
    * @description Future method for assigning User to queue
    * @param Id userId (User Id), queueId (Queue Id)
    */
    @future
    public static void assingnUserToQueue(Id userId, Id queueId) {
        // future - because GroupMember is created in one transaction with Account object - it was causing MIXED DML exception
        GroupMember gm = new GroupMember();
        gm.GroupId  = queueId;
        gm.UserOrGroupId = userId;
        insert gm;
    }

    /** @date 6/5/2013
    * @Author Pawel Sprysak
    * @description Select Option Mapping for Roles
    * @return List<SelectOption>
    */
    public List<SelectOption> getRoleMapping() {
        List<SelectOption> optionList = new List<SelectOption>();
        optionList.add(new SelectOption('Monitoring', 'Monitor'));
        optionList.add(new SelectOption('Vendor', 'Submitter'));
        optionList.add(new SelectOption('Provisioner', 'Provisioner'));
        if(selectedGroupObj != null && selectedGroupObj.VendorCode_gne__c == GENE_VENDORCODE && selectedGroupObj.VendorName_gne__c == GENE_VENDORNAME){
            optionList.add(new SelectOption('Proxy Submitter', 'Proxy Submitter'));
        }
        return optionList;
    }

    /** @date 6/4/2013
    * @Author Marcin Pawlak
    * @description Wrapper class for User
    */
    public class UserWrapper {
        public String firstName {get; set;}
        public String lastName {get; set;}
        public String emailAddress {get; set;}
        public String phone {get;set;}

        public UserWrapper(String fn, String ln, String email, String phoneVal) {
            this.firstName = fn;
            this.lastName = ln;
            this.emailAddress = email;
            this.phone = phoneVal;
        }

        public UserWrapper() {}
    }
}