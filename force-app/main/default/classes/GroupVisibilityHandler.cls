Global without sharing class GroupVisibilityHandler{

    GroupVisibilityHandler(){
    }
    
    /**
     * SetUserViewAllBrands - Macro function to all user to GNE-View-All-Brands-Users-Data-Group  
     *                        and set corresonding User.View_Mode_All_Brands_gne
     */
    webservice static boolean SetUserViewAllBrands_ws(string userid, boolean viewAllBrands){
       boolean res;
       
       //if (viewAllBrands)
       //   res = AddUserToGroup(userid, 'GNE-View-All-Brands-Users-Data-Group');
       //else
       //   res = RemoveUserFromGroup(userid, 'GNE-View-All-Brands-Users-Data-Group');
       
       User u = [Select Id, View_Mode_All_Brands_gne__c from User where id = :userid];
       u.View_Mode_All_Brands_gne__c = viewAllBrands;
       update(u);
       
       return res;
    }
    
    webservice  static boolean AddUserToGroup_ws(string userid, string groupName){
        return AddUserToGroup(userid, groupName);
    }
    
    /**
     * AddUserToGroup - Lookup users membership. If not a member of group remove user
     *
     * @userId - SFDC Id of user
     * @grpName - Textual name of group
     */
    public static boolean AddUserToGroup(string userId, string groupName){
        
        List<Group> grps = [Select id, name from Group where name = :groupName];
        
        if (grps.Size() == 0){
            System.debug('Group: '+groupName+ ' could not be found on AddUserToGroup. User not added');
            return false;
        }

        // See if already in group
        List<GroupMember> memberships = [Select Id from GroupMember where UserOrGroupId = :userId and GroupId = :grps[0].id];
        
        if(memberships.Size() > 0){
            System.debug('User '+userId+ ' already in group: '+groupName);
            return true;
        }
            
        GroupMember grpMmbrViewAll= new GroupMember();
        
        grpMmbrViewAll.UserOrGroupId = userId;
        grpMmbrViewAll.GroupId = grps[0].id;
        
        insert grpMmbrViewAll;
        
        System.debug('User '+userId+ ' added to group: '+groupName);

        
        return true;
    }/* AddUserToGroup() */
    
    webservice static boolean RemoveUserFromGroup_ws(string userId, string grpName){
        return RemoveUserFromGroup(userId, grpName);
    }
    /**
     * RemoveUserFromGroup - find a groupmembership for this user if exists and remove 
     *                       to removed user from group.
     *
     * @userId - SFDC Id of user
     * @grpName - Textual name of group
     */
    public static boolean RemoveUserFromGroup(string userId, string grpName){
        
        List<Group> grps = [Select Id from Group where name = :grpName];
        if (grps.size() == 0){
            System.debug('Group: '+ grpName+' not found. RemoveUserFromGroup() aborted.');
            return false;
        }
        
        List<GroupMember> memberships = [Select Id from GroupMember where UserOrGroupId = :userId and GroupId = :grps[0].id];
        
        if(memberships.Size() > 0){
            delete memberships;          
            System.debug('Removed user: '+ userid + ' from group: '+ grpName + ' on RemoveUserFromGroup.');
        }else{
            System.debug('User: '+ userid + ' not in group: '+ grpName + ' on RemoveUserFromGroup. Exiting');
        }
        
        return true;
    }/* RemoveUserFromGroup() */     

    webservice static boolean isUserInGroup_ws(string userId, string grpName){
        return isUserInGroup(userId, grpName);
    }

    /**
     * isUserInGroup
     * @userId - ID of user to check if in group
     * @grpName - Name of group to check member ship of
     *
     * @return true - if in group else false
     */    
    public static boolean isUserInGroup(string userId, string grpName){

        List<Group> grps = [Select id, Name from Group where Name = :grpName];
        
        if (grps.Size() == 0)
            return false;   
        
        List<GroupMember> memberships = [Select Id from GroupMember where UserOrGroupId = :userId and GroupId = :grps[0].id];

        System.debug(memberships.size() > 0 ? 'User '+ userid +' in group: '+grpName : 'User '+ userid +' not in group: '+grpName);

        return memberships.size() > 0;
    }/* isUserInGroup() */
    
    /**
     * getCommercialGroupForUser - Search throuch list of commercial user group and identify first group user is in
     *
     * @userId - Id of user to determine group for
     *
     * @return String Id of Commercial User group user is in or null if not in group
     */
    public static string getCommercialGroupForUser(string userId){
        
        List<Group> commGrps = [select id from group where type = 'Regular' and (name like 'GNE-SFA-%-Group' or name like 'GNE-ATLS-%-Group' or name like 'GNE-MCCO-%-Group') order by name DESC];
        
        List<GroupMember> memberships = [select id from groupmember where userorgroupid = :userId and groupId in :commGrps];
        
        if (memberships.size() > 0)
            return memberships[0].id;
        else
            return null;
    }/* getCommericalGroupForUser() */
    
    /**
     * removeUserNameFromGroup
     *
     * username - of user
     * grpName - Name of group
     */
    public static boolean removeUsernameFromGroup(string username, string grpName){
        
        List<User> users = [Select Id from user where username = :username];
        if (users.size()==0){
            System.debug('Username: '+username+' not found. removeUsernameFromGroup() aborted.');
            return false;
        }
        
        return RemoveUserFromGroup(users[0].id, grpName);
    }/* removeUsernameFromGroup() */
    
    /**
     *addUserNameToGroup
     *
     * username - of user
     * grpName - Name of group
     */
    public static boolean addUsernameToGroup(string username, string grpName){
        
        List<User> users = [Select Id from user where username = :username];
        if (users.size()==0){
            System.debug('Username: '+username+' not found. removeUsernameFromGroup() aborted.');
            return false;
        }
                
        return AddUserToGroup(users[0].id, grpName);
    }/* addUsernameToGroup */
    
    /**
     * setupUsernameForProductName
     *
     * @username 
     * @productname
     * @add - if true add else remove
     * @return true of success
     */
    public static boolean setupUsernameForProductname(string username, string prodName, boolean add){
    

        List<User> users = [Select Id from user where username = :username];
        if (users.size()==0){
            System.debug('Username: '+username+' not found. setupUserForProductname() aborted.');
            return false;
        }
                
        List<Product_vod__c> prods = [Select Id from product_vod__c where name = :prodName];
        if (prods.size()==0){
            System.debug('Product Name '+prodName+' not found. setupUserForProductname() aborted.');
            return false;
        }
        
        List<My_Setup_Products_vod__c> setups = [select Id from My_Setup_Products_vod__c where OwnerId = :users[0].id and Product_vod__c = :prods[0].id];
        
        for(integer setupCnt=setups.size()-1; setupCnt>=(add ? 1 : 0); setupCnt--){
           delete setups[setupCnt];
           System.debug('Removed My_Setup_product for user:'+username+' for productname:'+prodName);
        }
        
        if (add){  
            // If not my_product setup exists, create 
            if (setups.size() == 0){
                My_Setup_Products_vod__c setup = new My_Setup_Products_vod__c();
                setup.Product_vod__c = prods[0].id;
                setup.OwnerId = users[0].id;
                insert setup;
                System.debug('Adding  setup for username: '+ username+ ' for productname: '+ prodName); 
            }else{
                System.debug('Not adding setup for username: '+ username+ ' for productname: '+ prodName+ ' since already exist.'); 
            } 
        }/* if (add) */
        return true;
    
    }/* setupUsernameForProductname */
    
    /**
     * showProductsForUsername
     *
     * @username 
     * @return true of success
     */
    public static boolean showProductsForUsername(string username){
    

        List<User> users = [Select Id from user where username = :username];
        if (users.size()==0){
            System.debug('Username: '+username+' not found. setupUserForProductname() aborted.');
            return false;
        }
                        
        List<My_Setup_Products_vod__c> setups = [select Id, Product_vod__r.name from My_Setup_Products_vod__c where OwnerId = :users[0].id];
        
        for(integer setupCnt=setups.size()-1; setupCnt>=0; setupCnt--){
           System.debug('User:'+username+' setup for Product:' + setups[setupcnt].Product_vod__r.name);
        }
  
        return true;
    }
        
    
}/* GroupVisibilityHandler class*/