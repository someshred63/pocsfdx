public without sharing class EM3_Calendar_util {

    //List to hold all UserOrGroupID Ids
    static List<ID> UserOrGroupIDs;

    //List to hold all RelatedID
    static List<ID> relatedIDs;

    //Map to hold all accounts mapped to a list of there respective groupID
    static Map<ID,List<ID>> acc_to_GroupID_map;

    static set<ID> terrs_set = new Set<ID>();
    static set<ID> users_list = new set<ID>();
    static set<ID> groups_set = new Set<ID>();
    static Map<ID,List<ID>> terr_to_groups_map = new Map<ID,List<ID>>();
    static Map<ID, List<ID>> User_to_Terrs_map = new Map<ID,List<ID>>();

    //Lists for finding Nationwide Accounts ID : req 2579
     static List<String> ParentTerritory_List = new List<String>();
     static Map<String,String> terrID_ParentID_Map = new Map<String,String>();
     static Set<String> terrID_List = new Set<String>();// Final list of all territoryIDs unfer PFT Director
     static Set<String> tempTerrID_List = new Set<String>();
     static Set<String> finalTerrID_List = new Set<String>();
     static Set<String> childTerrID_List = new Set<String>();

     //List<String> accountIDs = new List<String>();
     static String terr_PFT_Director = '';
     static String temp ='';
     public static List<ID> accounts_PFTOps(){

        //List to hold all Territories
        List<Territory2> territories = [Select Id, parent_external_id_gne__c, ParentTerritory2Id from Territory2  where parent_external_id_gne__c LIKE '%PFT Director%'];
        //List of Ids of all territories unnder PFT Director
        for(Territory2 objTerr : territories){
            finalTerrID_List.add(objTerr.Id);
        }
        System.debug('Sudhanshu Jain finalTerrID_List after recursive search : '+ finalTerrID_List);
        List<Group> Groups = [select ID, RelatedId From Group where Type = 'Territory' AND RelatedID IN :finalTerrID_List];

        for(Group gr : groups){
            groups_set.add(gr.id);
        }
        /*
        terr_to_groups_map = new Map<ID,List<ID>>();

        for(ID ut : terrs_set){
            for(Group gr : Groups){
                if(gr.RelatedID == ut){
                    if(!terr_to_groups_map.containsKey(ut)){
                        terr_to_groups_map.put(ut, new List<ID>());
                    }
                    terr_to_groups_map.get(ut).add(gr.id);
                }
            }
        }
        //return terr_to_groups_map;
        //territory to Groups-end
        */
        //user To accout Map - start
        List<AccountShare> accShare = new List<AccountShare>();
        List<ID> accountIDs = new List<ID>();
        for(AccountShare accountS :[Select AccountID, UserOrGroupId from AccountShare where  (RowCause = 'TerritoryRule' or
        RowCause = 'Territory2AssociationManual') AND UserOrGroupID IN :groups_set]){
        accShare.add(accountS);
        accountIDs.add(accountS.AccountID);
        }
        //user To Account Map -ends

        return accountIDs;
    }
    //Requirement 2571 start
    public static List<ID> fetchAccountOfChildTerrIDs(set<ID> users){
        List<UserTerritory2Association> userTerritories = [Select Territory2Id, UserId from UserTerritory2Association where UserID IN :users];
        List<ID> list_ChildTerr_IDs = new List<ID>();
        List<ID> currentTerritories = new List<ID>();
        List<String> terrExtIDs = new List<String>();
        String parentExternalID;
        String externalID;
        //String tempID;
        for(UserTerritory2Association objID : userTerritories){
        currentTerritories.add(objID.Territory2Id);
        }
        list_ChildTerr_IDs.addAll(currentTerritories);
        System.debug('currentTerritories: ' + currentTerritories);
        //Finding External IDs of all the territories
        List<Territory2> terrForNames = [Select Name,external_id_gne__c from Territory2  where Id IN :currentTerritories];
        //System.debug('terrForNames.size(): '+terrForNames.size());
        String strTerritoryExtId ='';
        List<Territory2> territories = new List <Territory2> ();
        for(Territory2 terr : terrForNames){
            if(terr.external_id_gne__c != null && terr.external_id_gne__c !=''){
                strTerritoryExtId = terr.external_id_gne__c + '%';
                System.debug('strTerritoryExtId: '+strTerritoryExtId);
                territories=[Select Id, parent_external_id_gne__c, external_id_gne__c, ParentTerritory2Id from Territory2 where parent_external_id_gne__c like : strTerritoryExtId];
                if(territories !=null && territories.size() >0){
                    //System.debug('territories.size(): '+territories.size());
                    for(Territory2 terrExt : territories){
                        list_ChildTerr_IDs.add(terrExt.Id);
                    }
                    territories.clear();
                }
                terrExtIDs.add(terr.external_id_gne__c);
            }
        }

        System.debug('list_ChildTerr_IDs.size(): '+list_ChildTerr_IDs.size());
        List<Group> Groups = [select ID, RelatedId From Group where Type = 'Territory' AND RelatedID IN :list_ChildTerr_IDs];
        System.debug('Groups.size(): '+Groups.size());
        for(Group gr : groups){
            groups_set.add(gr.id);
        }

        //user To accout Map - start
        List<AccountShare> accShare = new List<AccountShare>();
        List<ID> accountIDs = new List<ID>();
        for(AccountShare accountS :[Select AccountID, UserOrGroupId from AccountShare where  (RowCause = 'TerritoryRule' or
        RowCause = 'Territory2AssociationManual') AND UserOrGroupID IN :groups_set]){
        accShare.add(accountS);
        accountIDs.add(accountS.AccountID);
        }
        //user To Account Map -ends
        System.debug('accountIDs.size(): '+accountIDs.size());
        return accountIDs;
    }
       //Requirement 2571 end

    public static Map<ID,List<ID>> acc_to_grp(set<ID> AccountID_set){
        //List to hold all account shares where the accountID is in the accountID_set
        List<AccountShare> Account_shares = [Select AccountID, UserOrGroupId from AccountShare where AccountID IN :AccountID_set and (RowCause = 'TerritoryRule' or RowCause = 'Territory2AssociationManual')];

        //List to hold all UserOrGroupID Ids
        UserOrGroupIDs = new List<ID>();

        //Map to hold all accounts mapped to a list of there respective groupID
        acc_to_GroupID_map = new Map<ID,List<ID>>();

        //Populates the acc_to_groupID_map
        for(AccountShare accShare : Account_shares){
            UserOrGroupIDs.add(accShare.UserOrGroupID);

            if(!acc_to_GroupID_map.containsKey(accShare.AccountID)){
                acc_to_GroupID_map.put(accShare.AccountID,new List<ID>());
            }
            acc_to_GroupID_map.get(accShare.AccountID).add(accShare.UserOrGroupId);
        }
        system.debug('Acc->Grp:'+acc_to_GroupID_map);
        return acc_to_GroupID_map;
    }

    public static Map<ID, List<ID>> acc_to_terr(){
        //List to hold all Group's where the ID is derived from the ID's gathered in the previous query to the AccountShare table
        List<Group> Groups = [Select ID, RelatedId from Group where Type = 'Territory' and ID IN :UserOrGroupIDs];

        //List to hold all RelatedID
        relatedIDs = new List<ID>();

        //Map to hold Accounts to a list of it's related Groups(Territories)
        Map<ID, List<ID>> Acc_to_groups_map = new Map<ID,List<ID>>();

        //The following loop populates the RelatedIDs set.  Also, it iterates through the acc_to_GroupID map and finds account id
        //for the matching accountShare.UserOrGroupID.  Lastly it populates the acc_to_groups_map with the found account id and
        //the related ID of the current Group record
        for(Group grp : Groups){
            relatedIDs.add(grp.RelatedID);
            ID accId;
            Boolean found = false;
            for(ID accountID : acc_to_GroupID_map.keySet()){
                for(ID UsrGrp : acc_to_groupID_map.get(accountID)){
                    if(UsrGrp == grp.ID){
                        //accId = grp.ID;
                        accId = accountID;
                        found = true;
                        break;
                    }
                }
                if(found){
                    break;
                }
            }

            if(!acc_to_groups_map.containsKey(accID)){
                acc_to_groups_map.put(accID, new List<ID>());
            }
            acc_to_groups_map.get(accID).add(grp.RelatedID);
        }
        system.debug('Acc->Terr:'+acc_to_groups_map);
        return acc_to_groups_map;
    }

        public static Map<ID, List<ID>> usr_to_terr_PFTOps(set<ID> users){
        users_list = users;
        //List<String> ParentTerritory_List = new List<String>();
        //List to hold all userTerritories queried using the previously retrieved relatedIds from the Group recordset
        List<UserTerritory2Association> userTerritories = [Select Territory2Id, UserId from UserTerritory2Association where UserID IN :users];
        //updated code for req 2579 - start

        for(UserTerritory2Association objUserTerritory : userTerritories ){
            ParentTerritory_List.add(objUserTerritory.Territory2Id);
        }

        List<Territory2> territories_List = [Select Id, ParentTerritory2Id from Territory2 where ParentTerritory2Id IN:ParentTerritory_List];

        for(UserTerritory2Association ut : userTerritories){
            terrs_set.add(ut.Territory2Id);
        }
        for(Territory2 territory : territories_List){
            terrs_set.add(territory.Id);
        }
        System.debug('terrs_set : '+ terrs_set);
        //updated code for req 2579 - end
        //Map to hold Territories to a list of related Users
        User_to_Terrs_map = new Map<ID,List<ID>>();

        for(ID Usr : users){
            //This for loop populates the terr_to_users map
            for(UserTerritory2Association ut : userTerritories){
                if(ut.UserID == usr){
                    if(!User_to_Terrs_map.containsKey(ut.UserID)){
                        User_to_Terrs_map.put(ut.UserID, new List<ID>());
                    }
                    User_to_Terrs_map.get(ut.UserID).add(ut.Territory2Id);
                }
            }
        }

        system.debug('User->Terrs:'+User_to_Terrs_map);
        return User_to_Terrs_map;
    }

    public static Map<ID, List<ID>> terr_to_usrs(){
       //List to hold all userTerritories queried using the previously retrieved relatedIds from the Group recordset
        List<UserTerritory2Association> userTerritories = [Select Territory2Id, UserId from UserTerritory2Association where Territory2Id IN :relatedIDs];
        set<ID> users_set = new Set<ID>();
        for(UserTerritory2Association ut : userTerritories){
            users_set.add(ut.UserId);
        }

        //List to hold all UserIDs
        List<User> ActiveUserIDs = [select ID from User where ID IN :users_set and isActive = true];
        Set<ID> ActiveUserIDS_set = new Set<ID>();
        for(User u: ActiveUserIDs){
            ActiveUserIDS_set.add(u.id);
        }

        for(integer i=0;i<userTerritories.size();i++){
            if(!ActiveUserIDS_set.contains(userTerritories[i].UserId)){
                userTerritories.remove(i);
            }
        }

        //Map to hold Territories to a list of related Users
        Map<ID, List<ID>> Terr_to_Users_map = new Map<ID,List<ID>>();

        //This for loop populates the terr_to_users map
        for(UserTerritory2Association ut : userTerritories){
            if(!terr_to_users_map.containsKey(ut.Territory2Id)){
                terr_to_users_map.put(ut.Territory2Id, new List<ID>());
            }
            terr_to_users_map.get(ut.Territory2Id).add(ut.UserId);
        }
        system.debug('Terr->Users:'+terr_to_users_map);
        return terr_to_users_map;
    }

    public static Map<ID, List<ID>> usr_to_terr(set<ID> users){
        users_list = users;
        //List to hold all userTerritories queried using the previously retrieved relatedIds from the Group recordset
        List<UserTerritory2Association> userTerritories = [Select Territory2Id, UserId from UserTerritory2Association where UserID IN :users];

        for(UserTerritory2Association ut : userTerritories){
            terrs_set.add(ut.Territory2Id);
        }

        //Map to hold Territories to a list of related Users
        User_to_Terrs_map = new Map<ID,List<ID>>();

        for(ID Usr : users){
            //This for loop populates the terr_to_users map
            for(UserTerritory2Association ut : userTerritories){
                if(ut.UserID == usr){
                    if(!User_to_Terrs_map.containsKey(ut.UserID)){
                        User_to_Terrs_map.put(ut.UserID, new List<ID>());
                    }
                    User_to_Terrs_map.get(ut.UserID).add(ut.Territory2Id);
                }
            }
        }

        system.debug('User->Terrs:'+User_to_Terrs_map);
        return User_to_Terrs_map;
    }

    public static Map<ID,List<ID>> terr_to_groups(){
        List<Group> Groups = [select ID, RelatedId From Group where Type = 'Territory' AND RelatedID IN :terrs_set];

        for(Group gr : groups){
            groups_set.add(gr.id);
        }

        terr_to_groups_map = new Map<ID,List<ID>>();

        for(ID ut : terrs_set){
            for(Group gr : Groups){
                if(gr.RelatedID == ut){
                    if(!terr_to_groups_map.containsKey(ut)){
                        terr_to_groups_map.put(ut, new List<ID>());
                    }
                    terr_to_groups_map.get(ut).add(gr.id);
                }
            }
        }

        return terr_to_groups_map;
    }

    public static Map<ID, set<ID>> groups_to_userAcc_map(){
        List<AccountShare> accShare = new List<AccountShare>();
        for(AccountShare accountS :[Select AccountID, UserOrGroupId from AccountShare where  (RowCause = 'TerritoryRule' or
        RowCause = 'Territory2AssociationManual') AND UserOrGroupID IN :groups_set]){
        accShare.add(accountS);
        }

        Map<ID,List<ID>> groups_to_accs_map = new Map<ID,List<ID>>();

        for(ID gr : groups_set){
            for(AccountShare aShare : accShare){
                if(aShare.UserOrGroupID == gr){
                    if(!groups_to_accs_map.containsKey(gr)){
                        groups_to_accs_map.put(gr, new List<ID>());
                    }
                    groups_to_accs_map.get(gr).add(aShare.AccountID);
                }
            }
        }
        system.debug('GROUPS_TO_ACCS_MAP:'+groups_to_accs_map);
        system.debug('TERR_TO_GROUPS_MAP:'+TERR_TO_GROUPS_map);

        Map<ID,set<ID>> user_to_accs_map = new Map<ID,set<ID>>();

        for(ID usr : Users_list){
            if(User_to_terrs_map.containsKey(usr)){
                for(ID terr : User_to_Terrs_map.get(usr)){
                    if(terr_to_groups_map.containsKey(terr)){
                        for(ID gr : terr_to_groups_map.get(terr)){
                            if(groups_to_accs_map.containsKey(gr)){
                                for(ID acc : groups_to_accs_map.get(gr)){
                                    if(!user_to_accs_map.containsKey(usr)){
                                        user_to_accs_map.put(usr, new set<ID>());
                                    }
                                    user_to_accs_map.get(usr).add(acc);
                                }
                            }
                        }
                    }
                }
            }
        }
            system.debug('User->Accs:');
        for(ID usr : user_to_accs_map.keySet()){
            system.debug('User:'+usr);
            for(ID accs : user_to_accs_map.get(usr)){
                system.debug('Acc:'+accs);
            }
        }
        return user_to_accs_map;
    }

    //For going in reverse: User->Related Accounts via Territory
    //User->Accs
    /*
        List<UserTerritory2Association> userTerritories2 = [Select Territory2Id, UserId from UserTerritory2Association where UserID = :activeUserIDs[0].ID];
        system.debug(userTerritories2);

        List<Group> Groups2 = [Select ID, RelatedId from Group where Type = 'Territory' and RelatedID = :UserTerritories2[0].Territory2Id];
        system.debug(Groups2);

        List<AccountShare> Account_shares2 = [Select AccountID, UserOrGroupId from AccountShare where  (RowCause = 'TerritoryRule' or RowCause = 'TerritoryManual') AND UserOrGroupID = :groups2[0].id  limit 1];
        system.debug(Account_shares2);
    */
}