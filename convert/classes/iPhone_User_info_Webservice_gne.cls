global without sharing class iPhone_User_info_Webservice_gne 
{
    /**
     * Basic User definition
     */
    global class UserInfo
    {
        WebService String Id;
        WebService String firstName;
        WebService String lastName;
        WebService String profileName;
        WebService Id profileId;
        WebService Id managerId;
        WebService List<String> myProducts;
    }
    /**
     * Response Package
     */
    global class ResponseItem
    {
        WebService UserInfo uInfo;
        ResponseItem(UserInfo ui){
           uInfo = ui;
        }
    }
    /**
     * Get UserInfo by User SFDC Id
     */
    WebService static ResponseItem returnUserInfoById(Id userId)
    {
        UserInfo uInfo = new UserInfo();
        User u = [Select Id, Firstname, Lastname, profileid, profile.name, managerid from user where id = :userId];

        uInfo.Id = u.Id;
        uInfo.firstName = u.FirstName;
        uInfo.lastName= u.Lastname;
        uInfo.profileName = u.profile.Name;
        uInfo.profileId = u.profileId;
        uInfo.managerId = u.ManagerId;
        uInfo.myProducts = new List<String>();
        
        List<My_Setup_Products_vod__c> myProds = [Select product_vod__c, product_vod__r.name from my_setup_products_vod__c where ownerid = :userId];
        System.debug(myProds);
        for(My_Setup_Products_vod__c setup: myProds)
          uInfo.myProducts.add(setup.product_vod__r.name);
                
        return new ResponseItem(uInfo);
    }

    /**
     * Get Current Users UserInfo 
     */
    WebService static ResponseItem returnUserInfo()
    {
        return returnUserInfoById(UserInfo.getUserId());
    }

    /**
     * Get UserInfo by users UnixId
     */
    WebService static ResponseItem returnUserInfoByUnixId(string unixId)
    {
        User u = [Select Id from user where External_id_gne__c = :unixId];
        System.debug('@@--@@--@@-User: '+u);
        return returnUserInfoById(u.Id);
    }

    /**
     * Unit Test Method
     *    test returnUserInfo()
     *         returnUserInfoById(Id)
     *         returnUserInfoByUnixId(String)
     */        
    public static UserInfo testMe(){
    
        // Test base mehtod
        ResponseItem ri = returnUserInfo();
        
        System.debug(ri.uInfo);

        // Build Map of users for each SFA profile to test with each profile
        Map<Id,User> uMap = new Map<Id, User>([Select profileId, Name, Id, External_id_gne__c From user where profile.name like 'GNE-SFA%' AND (NOT profile.name LIKE 'GNE-SFA-Ops%') LIMIT 4000]);
        for (Id id : uMap.keySet()) {

            ri = returnUserInfoById(uMap.get(id).Id);
            System.debug(ri.uInfo);

            ri = returnUserInfoByUnixId(uMap.get(id).External_id_gne__c);
            System.debug(ri.uInfo);
        }
        
        return ri.uInfo;
    }
}