public class AGG_SearchUserHierarchy {

    /*##################################################
#Project Name           : Genentec - Infrequent Users Search
# File                  : AGG_SearchUser.cls
# Version               : 1.0 
# Created by            : <<Sandeep Kumar>> 
# Created Date          : <<11nd Nov 09>> 
# Last Modified by      : <<Gitika Sharma>> 
# Last Modified Date    : <<29th Jun 10>> 
# Description           : <<This is the controller class for Infrequent User Search that searches for Users based on User hierarchy>>  
# 
# 
##################################################*/

    public String sSearchText { get; set; }
    public String sErrMessage { get; set; }
    public String sSearchString = '';

    public String sUserAddName { get; set; }
    public String sUserAddNameType { get; set; }
    public String sUserButtonName { get; set; }
    public String Userhierarchyunixid { get; set; }
    private static final Integer MAX_RECORDS_COUNT = 50;
    String usersfid ;
    List<All_User_Hierarchy_gne__c> lstUsers = new List<All_User_Hierarchy_gne__c>();
    //constructors
    public AGG_SearchUserHierarchy() {

    }

    public AGG_SearchUserHierarchy(ApexPages.StandardController stdController) {
        //names of input Text fields in calling form passed as parameter values.
        //These names will be referenced from called form to post values back to parent/called form
        if (System.currentPageReference().getParameters().get('hcpname') != null) {
            sUserAddName = System.currentPageReference().getParameters().get('hcpname');
        }
        if (System.currentPageReference().getParameters().get('hcpnametype') != null) {
            sUserAddNameType = System.currentPageReference().getParameters().get('hcpnametype');
        }
        if (System.currentPageReference().getParameters().get('hcpbutton') != null) {
            sUserButtonName = System.currentPageReference().getParameters().get('hcpbutton');
        }

    }

    @AuraEnabled
    public static SearchResult searchUsers(String searchText) {
        List<List<SObject>> searchList = [
                FIND :searchText
                IN NAME FIELDS
                        RETURNING
                        All_User_Hierarchy_gne__c (Id, Name, email_id__c, User_External_Id_gne__c WHERE Active_gne__c = TRUE ORDER BY Name LIMIT :MAX_RECORDS_COUNT + 1)
        ];
        return new SearchResult((List<All_User_Hierarchy_gne__c>) searchList[0]);
    }

    @AuraEnabled
    public static User fetchOrCreateUser(String userUnixId) {
        String result = UserManager.findSFUser(userUnixId);
        if (result.substring(0, 3) == '005') {
            return [SELECT Name, FirstName, Id, LastName, CompanyName, Username, City, Street, State, PostalCode, Country, External_ID_gne__c FROM User WHERE Id = :result];
        } else {
            throw new UserCreationException(result);
        }
    }

    //List to bind/diplay resutls to VF page
    public List<All_User_Hierarchy_gne__c> getMatchesFound() {
        return lstUsers;
    }

    //action value for Search button on VF page
    //retrieves users based on the search crieria
    public PageReference goSearch() {
        sErrMessage = '';

        if (lstUsers != null && lstUsers.size() > 0) {
            lstUsers.clear();
            lstUsers = new List<All_User_Hierarchy_gne__c>();
        }

        if (sSearchText.length() <= 1) {
            sErrMessage = 'Search term must be longer than one character.';
            return null;
        }

        sSearchString = sSearchText;

        List<List<SObject>> searchList = [
                FIND :sSearchString
                IN NAME FIELDS
                        RETURNING
                        All_User_Hierarchy_gne__c (email_id__c, Id, Name, User_External_Id_gne__c, Active_gne__c WHERE Active_gne__c = TRUE ORDER BY Name LIMIT :MAX_RECORDS_COUNT + 1)
        ];
        System.debug('------------------------searchList' + searchList);
        lstUsers = (List<All_User_Hierarchy_gne__c>) searchList[0];
        System.debug('------------------------' + lstUsers);

        if (lstUsers != null && lstUsers.size() > MAX_RECORDS_COUNT) {
            sErrMessage = 'The search returned more than the maximum number of rows (' + String.valueOf(MAX_RECORDS_COUNT) + '). Please refine your search criteria.';
        }
        //sErrMessage='SELECT  u.Name, u.FirstName, u.Id, u.LastName, u.Phone, u.MobilePhone, u.Title, u.Email, u.CompanyName, u.UserRoleId, u.UserRole.Name, u.Username, u.City, u.Street, u.State, u.PostalCode, u.Country, u.isActive FROM User u WHERE isActive=true AND (FirstName LIKE :sSearchString OR LastName Like '+ sSearchString + ')  order BY Name LIMIT ' + iMaxSearch+1;

        return null;
    }

    public PageReference apexfetchuser() {
        System.debug('apexfetchuser Method invoked' + Userhierarchyunixid);
        usersfid = UserManager.findSFUser(Userhierarchyunixid);
        System.debug('usersfid ' + usersfid);
        return null;
    }

    //////Starts Getters & Setters///////
    public String getusersfid() {
        return usersfid;
    }

    public void setusersfid(String u) {
        this.usersfid = u ;
    }
    public String getUserhierarchyunixid() {
        return Userhierarchyunixid;
    }

    public void setUserhierarchyunixid(String u) {
        this.Userhierarchyunixid = u ;
    }

    class UserCreationException extends Exception {

    }

    class SearchResult {
        @AuraEnabled
        public List<All_User_Hierarchy_gne__c> users;
        @AuraEnabled
        public String message;

        public SearchResult(List<All_User_Hierarchy_gne__c> users) {
            this.users = users;
            this.message = (users.size() > MAX_RECORDS_COUNT) ? 'The search returned more than the maximum number of rows (' + String.valueOf(MAX_RECORDS_COUNT) + '). Please refine your search criteria.' : null;
        }
    }
}