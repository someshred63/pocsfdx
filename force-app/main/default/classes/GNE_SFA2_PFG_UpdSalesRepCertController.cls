public with sharing class GNE_SFA2_PFG_UpdSalesRepCertController extends CustomDataPaginator {
    
    public String newBlockedUser {get; set;}
    public String newBlockedUserDeleteId {get; set;}
    public User userToUnlock {get; set;}
    public List<User> usersToUnlock {get; set;}
    public List<SFA2_PFG_Storage_Location_gne__c> usersToBlock {get; set;}
    public String remainingUserIds {get; set;}
    public String userObjectPrefix {get;set;}
    public List<UncertifiedUserWrapper> uncertifiedUsersWrapperList {get; set;}
    public String csIdParam {get; set;}
    public String rowIdxParam {get; set;}
    
    public Integer rowId {get; set;}
    public Integer userRow {get; set;}
    private List<UncertifiedUserWrapper> blockadesToDel {get;set;}
    private Set<String> remainingUsers;
    
    public GNE_SFA2_PFG_UpdSalesRepCertController(){
        this.userObjectPrefix = Call_PFG_Detail_gne__c.sobjecttype.getdescribe().getkeyprefix();
        this.rowId = 0;
        this.uncertifiedUsersWrapperList = getUncertUsersWrapperList();
        this.blockadesToDel = new List<UncertifiedUserWrapper>();

        this.setPageSize(10);
        this.setNumItems(this.uncertifiedUsersWrapperList.size());
    }
    
    public String getPfgActiveMenuItem() {
        return GNE_SFA2_PFG_Base_Controller.MY_PFG_PAGE_NAME;
    }
    
    //    Prepares user records (blocked reps retrieved in constructor) to print them in User Interface. To achieve this there is a need to put them into SelectOption objects list.
    public List<UncertifiedUserWrapper> getUncertUsersWrapperList() {
        this.uncertifiedUsersWrapperList = new List<UncertifiedUserWrapper>();
        List<User> users = getUsers();
        this.rowId = 0;
        for(User u : users){
            
            UncertifiedUserWrapper userWrap = new UncertifiedUserWrapper(u);   
            userWrap.rowNumber = this.rowId;
            uncertifiedUsersWrapperList.add(userWrap);  
            this.rowId++;       
        }
        return uncertifiedUsersWrapperList;
    }
    
    private List<User> getUsers(){
        List<User> users = new List<User>();
        remainingUsers = new Set<String>();
        
        for(SFA2_User_Sales_Roster_gne__c sRoster : GNE_SFA2_PFG_Util.getUsersByRoleName(GNE_SFA2_PFG_Util.USER_ROLE_CS)) {
            if(validForBlockCsList(sRoster.User_gne__r)) {
                users.add(new User(
                    Id=sRoster.User_gne__c,                    
                    FirstName = sRoster.User_gne__r.FirstName,
                    LastName = sRoster.User_gne__r.LastName,
                    UserName = sRoster.User_gne__r.UserName,
                    PFG_Uncertified_Flag_gne__c = sRoster.User_gne__r.PFG_Uncertified_Flag_gne__c, 
                    LOA_HO_Override_Flag_gne__c = sRoster.User_gne__r.LOA_HO_Override_Flag_gne__c));
            } else {
                remainingUsers.add(sRoster.User_gne__c);
            }
        }
        calculateRemainingUsers();
        return users;
    }
    
    private Boolean validForBlockCsList(User u) {
        return !GNE_SFA2_PFG_Util.checkIsUserCertified(u.Id) || GNE_SFA2_PFG_Util.checkIsUserLOA(u.Id);
    }
    
    private void calculateRemainingUsers() {
        List<String> userIds = new List<String>(remainingUsers);
        
        // make sure that there will be nothing on the list
        if(userIds.isEmpty()) {
            userIds.add(UserInfo.getProfileId());
        }
        
        remainingUserIds = String.join(userIds,',');
    }
    
    public List<SFA2_PFG_Storage_Location_gne__c> getUsersSelectedToBlock() {
        return this.usersToBlock;
    }

    public void addUserToBLock(){
        this.usersToBlock.add(new SFA2_PFG_Storage_Location_gne__c());
    }


    public ApexPages.PageReference goToFirstPageAction(){
        this.gotoFirstPage();
        return null;
    }
    
    public ApexPages.PageReference goToLastPageAction(){
        this.gotoLastPage();
        return null;
    }
    
    public ApexPages.PageReference goToNextPageAction(){
        this.gotoNextPage();
        return null;
    }
    
    public ApexPages.PageReference goToPreviousPageAction(){
        this.gotoPrevPage();
        return null;
    }
    
    public PageReference saveBlockades() {
        PageReference result = null;
        try {
            result = intSaveBlockades();
        } catch(Exception ex) {
            result = setErrorPageReference(GNE_SFA2_PFG_Base_Controller.SAVE_ERROR_MESSAGE_PREFIX, ex);
        }
        
        return result;
    }
    
    private PageReference intSaveBlockades(){
        PageReference result = null;
        
        Map<Id,User> usersToUpdate = new Map<Id,User>();
        
        //blockades
        for(UncertifiedUserWrapper wrap : this.uncertifiedUsersWrapperList){
            User userToUpdate = wrap.newRow ? getUserById(wrap.stagUser.User_gne__c) : wrap.stagUser.User_gne__r.clone(true); 
             
            if(userToUpdate!=null && (wrap.isEditable || wrap.newRow)){
                userToUpdate.PFG_Uncertified_Flag_gne__c = wrap.stagUser.isUncertified_gne__c;
                userToUpdate.LOA_HO_Override_Flag_gne__c = getLoaHoOverrideFlagValue(wrap);
                usersToUpdate.put(wrap.stagUser.User_gne__c,userToUpdate);
            }
        }
        
        //deleted blockades
        for(UncertifiedUserWrapper wrap : this.blockadesToDel){
            if(wrap.stagUser.User_gne__c!=null && !usersToUpdate.containsKey(wrap.stagUser.User_gne__c) && !wrap.newRow) {
                User userToUpdate = wrap.stagUser.User_gne__r.clone(true); 
                userToUpdate.PFG_Uncertified_Flag_gne__c = false;
                userToUpdate.LOA_HO_Override_Flag_gne__c = GNE_SFA2_PFG_Util.USER_LOA_HO_OVERRIDE_FLAG_FALSE;
                usersToUpdate.put(wrap.stagUser.User_gne__c,userToUpdate);
            }
        }
        
        Boolean isOk = false;
        SavePoint savePoint = Database.setSavepoint();
        
        try {
            validate();
            update usersToUpdate.values();
            isOk = true;
        } catch(GNE_SFA2_PFG_Base_Controller.InvalidInputValueException ex) {
            for(String errorMsg : ex.errorMessages) {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR,errorMsg));
            }
        } catch(Exception ex) {
            Apexpages.addMessages(ex);
            Database.rollback(savePoint);
        }
        
        if(isOk) {
            result = GNE_SFA2_PFG_Base_Controller.redirectToReturnUrl();
        }
        
        return result;
    }
    
    private void validate() {
        List<String> errorMsgs = new List<String>();
        
        Integer i = 0;
        Boolean singleMode = this.uncertifiedUsersWrapperList.size()==1;
        
        for(UncertifiedUserWrapper wrap : this.uncertifiedUsersWrapperList) {
            String rowPrefix = singleMode ? '' : ('Row ' + ++i + ': ');
            
            if(wrap.newRow && String.isBlank(wrap.stagUser.User_gne__c)) {
                errorMsgs.add(
                    rowPrefix + 'CS Name' + GNE_SFA2_PFG_Base_Controller.MISSING_REQUIRED_FIELD_VALUE);
            }
        } 
        
        if(!errorMsgs.isEmpty())
            throw new GNE_SFA2_PFG_Base_Controller.InvalidInputValueException(errorMsgs);
    }
    
    private String getLoaHoOverrideFlagValue(UncertifiedUserWrapper wrap) {
        String value = GNE_SFA2_PFG_Util.getUserLOAHoOverrideFlag(wrap.stagUser.User_gne__c);
        Boolean isOnLOA = GNE_SFA2_PFG_Util.checkIsUserLOA(wrap.stagUser.User_gne__c);
        
        if(isOnLOA && !wrap.stagUser.isLOASelected_gne__c) {
            value = GNE_SFA2_PFG_Util.USER_LOA_HO_OVERRIDE_FLAG_FALSE;
        } else if(!isOnLOA && wrap.stagUser.isLOASelected_gne__c) {
            value = GNE_SFA2_PFG_Util.USER_LOA_HO_OVERRIDE_FLAG_TRUE;
        }
        return value;
    }
    
    public PageReference cancel() {
        return GNE_SFA2_PFG_Base_Controller.cancel();
    }

    public PageReference deleteBlockade() {
    	PageReference result = null;
        try {
            result = intDeleteBlockade();
        } catch(Exception ex) {
            result = setErrorPageReference('deleteBlockade', ex);
        }
        
        return result;
    }
    
    private PageReference intDeleteBlockade() {
        Map<Integer, UncertifiedUserWrapper> blockadesMap = new Map<Integer, UncertifiedUserWrapper>();

        for(UncertifiedUserWrapper userWrp : this.uncertifiedUsersWrapperList){
            blockadesMap.put(userWrp.rowNumber, userWrp);
        }
        blockadesMap.get(this.userRow).logicDelete = true;
        this.uncertifiedUsersWrapperList = new List<UncertifiedUserWrapper>();
        
        for(Integer exRowId : blockadesMap.keySet()){
            if(blockadesMap.get(exRowId).logicDelete == false){
                this.uncertifiedUsersWrapperList.add(blockadesMap.get(exRowId));
            }
            if(blockadesMap.get(exRowId).logicDelete == true){
                if(String.isNotBlank(blockadesMap.get(exRowId).stagUser.User_gne__c)) {
                    remainingUsers.add(blockadesMap.get(exRowId).stagUser.User_gne__c);
                    this.blockadesToDel.add(blockadesMap.get(exRowId)); 
                }
            }
        }
        
        calculateRemainingUsers();
        this.setNumItems(this.uncertifiedUsersWrapperList.size());
        return null;
    }
    
    public PageReference editBlockade() {
    	PageReference result = null;
        try {
            result = intEditBlockade();
        } catch(Exception ex) {
            result = setErrorPageReference('editBlockade', ex);
        }
        
        return result;
    }
    
    private PageReference intEditBlockade() {
        Map<Integer, UncertifiedUserWrapper> blockadesMap = new Map<Integer, UncertifiedUserWrapper>();
        for(UncertifiedUserWrapper exWrp : this.uncertifiedUsersWrapperList){
            blockadesMap.put(exWrp.rowNumber, exWrp);
        }
        blockadesMap.get(this.userRow).isEditable = true;
        //this.tableInEditMode = true;
        return null;
    }
    
    public PageReference addBlockade() {
    	PageReference result = null;
        try {
            result = intAddBlockade();
        } catch(Exception ex) {
            result = setErrorPageReference('addBlockade', ex);
        }
        
        return result;
    }
    
    private PageReference intAddBlockade() {
        UncertifiedUserWrapper userWrap = new UncertifiedUserWrapper();
        this.rowId++;
        userWrap.rowNumber = this.rowId;
        this.uncertifiedUsersWrapperList.add(userWrap);
        this.setNumItems(this.uncertifiedUsersWrapperList.size());
        if(getCanGoForward()){
            goToLastPageAction();   
        }
        return null;
    }
    
    private User getUserById(String userId){
        User result = null;
        
        if(String.isNotBlank(userId)) {
            SFA2_User_Sales_Roster_gne__c sRoster = GNE_SFA2_PFG_Util.getSalesRosterForUser((Id)userId);
            result = new User(
                Id=sRoster.User_gne__c,
                FirstName = sRoster.User_gne__r.FirstName,
                LastName = sRoster.User_gne__r.LastName,
                UserName = sRoster.User_gne__r.UserName,
                PFG_Uncertified_Flag_gne__c = sRoster.User_gne__r.PFG_Uncertified_Flag_gne__c, 
                LOA_HO_Override_Flag_gne__c = sRoster.User_gne__r.LOA_HO_Override_Flag_gne__c);
        }
        
        return result;
    }
    
    //populates CS IDfrom choosed user
    public PageReference populateCsId() {
    PageReference result = null;
        try {
            result = intPopulateCsId();
        } catch(Exception ex) {
            result = setErrorPageReference('populateCsId', ex);
        }
        
        return result;
    }
    
    private PageReference intPopulateCsId() {
        Integer rowId = Integer.valueOf(rowIdxParam);
        String username = null; 
        
        for(User u : [Select UserName from user where id= :csIdParam]) {
            username = u.username;
        }
        
        for(UncertifiedUserWrapper wrapper: uncertifiedUsersWrapperList) {
        	if(wrapper.rowNumber == rowId){
            	wrapper.username = username;
            }
        }
        
        return null;
    }
    
    private PageReference setErrorPageReference(String actionName, Exception ex) {
    	return GNE_SFA2_PFG_Base_Controller.setErrorPageReference(GNE_SFA2_PFG_Base_Controller.SAVE_ERROR_MESSAGE_PREFIX, ex);
    }
    
    public class UncertifiedUserWrapper {
        public SFA2_PFG_Staging_User_gne__c stagUser {get;set;}
        public Boolean newRow {get; set;}
        public Boolean isUncertified {get; set;}
        public Boolean isLOASelected {get; set;}
        public Boolean isEditable {get;set;} 
        public String username {get; set;} 
        public Integer rowNumber {get; set;}
        public Boolean logicDelete {get;set;}
        public String fullName {get;set;}

        public UncertifiedUserWrapper(){
            stagUser = new SFA2_PFG_Staging_User_gne__c();  
            newRow = true;
            isUncertified = false;
            isLOASelected = false;  
            rowNumber = 0;
            logicDelete = false;
            isEditable = false;
        }
        
        public UncertifiedUserWrapper(User u){
            stagUser = new SFA2_PFG_Staging_User_gne__c();      
            stagUser.User_gne__c = u.Id;
            stagUser.User_gne__r = u;
            username = u.username;
            newRow = false; 
            stagUser.isUncertified_gne__c = stagUser.User_gne__r.PFG_Uncertified_Flag_gne__c;
            stagUser.isLOASelected_gne__c = GNE_SFA2_PFG_Util.checkIsUserLOA(stagUser.User_gne__c);
            rowNumber = 0;  
            logicDelete = false;
            isEditable = false;     
            fullName = u.FirstName + ' ' + u.LastName;       
        }
    }
    
}