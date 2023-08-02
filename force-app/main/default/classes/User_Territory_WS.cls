global without sharing class User_Territory_WS {

   global class AccountAlignmentInfo {
        WebService String TerritoryId;
        WebService String TerritoryName;
        WebService String GroupId;
        WebService String AccountShareId;
        WebService Integer ReadWrite;
        WebService String CreatedByProfile;
        WebService String CreatedByUser;
        WebService String TSFId;
        WebService Integer TargetFlag;
   }

    global class accountAlignmentReturnValue{
        WebService List<AccountAlignmentInfo> acctAlignmentList;
        WebService List<Group> Groups;
        WebService List<TSF_vod__c> TSFS;
    }
    WebService static List<Territory2> getUserTerritories(string userID){

        List<Territory2> ters=new List<Territory2>();

        set <Id> terrSet = new set <Id>();
        List<Territory2> L1childTerrIds;
        List<Territory2> L2childTerrIds;
        List<Territory2> L3childTerrIds;
        List<Territory2> L4childTerrIds;
        List<Territory2> finalTerrList;

        List<UserTerritory2Association> uts= [Select u.Territory2Id, u.UserId from UserTerritory2Association u where u.UserId=:userID];
        //Added by CP
        String currentUserProfile = getUserProfile(UserInfo.getUserId());

        for(UserTerritory2Association ut:uts){
            ters.add([Select t.Id from Territory2 t where t.Id=:ut.Territory2Id]);

        }
        for(Territory2 t :ters){
            terrSet.add(t.Id);

        }

        if (currentUserProfile.contains('GNE-MedAffairs'))
        {
            if (terrSet.size() > 0)
            {
                L1childTerrIds = [Select Id  from Territory2 where ParentTerritory2Id in :terrSet];
                if  (L1childTerrIds != null && L1childTerrIds.size() > 0) {
                    for(Territory2 terr :L1childTerrIds)
                    {
                        terrSet.add(terr.Id);
                    }

                }
            }

            if (L1childTerrIds != null && L1childTerrIds.size() > 0)
            {
                L2childTerrIds = [Select Id,Name from Territory2 where ParentTerritory2Id in :L1childTerrIds];
                if  (L2childTerrIds != null && L2childTerrIds.size() > 0){
                    for(Territory2 terr :L2childTerrIds)
                    {
                        terrSet.add(terr.Id);
                    }

                }
            }

            if (L2childTerrIds != null && L2childTerrIds.size() > 0)
            {
                L3childTerrIds = [Select Id,Name from Territory2 where ParentTerritory2Id in :L2childTerrIds];
                if  (L3childTerrIds != null && L3childTerrIds.size() > 0){
                    for(Territory2 terr :L3childTerrIds)
                    {
                        terrSet.add(terr.Id);
                    }

                }
            }

            if (L3childTerrIds != null && L3childTerrIds.size() > 0)
            {
                L4childTerrIds = [Select Id,Name from Territory2 where ParentTerritory2Id in :L3childTerrIds];
                if  (L4childTerrIds != null && L4childTerrIds.size() > 0){
                    for(Territory2 terr :L4childTerrIds)
                    {
                        terrSet.add(terr.Id);
                    }

                }
            }

        }
        finalTerrList = [Select Id,Name from Territory2 where Id in :terrSet];
        return finalTerrList;
    }

    WebService static accountAlignmentReturnValue getAccountAlignment(Id accountID) {
        //Declaration
        accountAlignmentReturnValue aARV=new accountAlignmentReturnValue();
        String currentUserProfile = getUserProfile(UserInfo.getUserId());
        String AccountShareUserProfile = '';

        //Initialization
       // List<Group> grps=[Select Id from Group where Type='Territory' and Id in (Select a.UserOrGroupId from AccountShare a where a.AccountId =:accountID and rowcause ='Territory Manual')];
        List<AccountShare> ash=[Select UserOrGroupId,LastModifiedbyId from AccountShare a where a.AccountId =:accountId and a.rowcause ='Territory2AssociationManual'];
       //system.debug('The List of ASH :' +ash);
        aARV.acctAlignmentList = new List<User_Territory_WS.AccountAlignmentInfo>();

        Set<Id> groupIdSet = new Set<Id>();
        for (AccountShare ac : ash ) {
            groupIdSet.add ( ac.userorgroupId);
        }

        Map<Id,Id> groupToTerritoryId = new Map<Id,Id>();
        Set<Id> territoryIdSet = new Set<Id>();
        for (Group g: [select id, relatedId from group where id in :groupIdSet])  {
            groupToTerritoryId.put ( g.id, g.relatedId);
            territoryIdSet.add ( g.relatedId );
        }

        Map <Id,Territory2> territoryMap = new Map<Id,Territory2> ();
        for (Territory2 t : [select t.id, t.name from Territory2 t where t.id in :territoryIdSet] )
              territoryMap.put ( t.id, t);

        Set<Id> UserIdSet = new Set<Id>();
        for (AccountShare uash : ash ) {
            UserIdSet.add (uash.LastModifiedById);
        }

        Map<Id,User> UserMap = new Map<Id,User>();
        Set<Id> ProfileIdSet = new Set<Id>();
        for (User u: [select u.id, u.Name,u.ProfileId from user u where u.id in :UserIdSet])  {
            ProfileIdSet.add(u.ProfileId);
            UserMap.put (u.id, u );
        }

        Map <Id,Profile> ProfileMap = new Map<Id,Profile> ();
        for (Profile p : [select p.id, p.name from profile p where p.id in :ProfileIdSet ] )
              ProfileMap.put (p.id, p);

        for (integer i=0; i<ash.size(); i++) {

          User_Territory_WS.AccountAlignmentInfo acctAlignmentInfo = new User_Territory_WS.AccountAlignmentInfo();

          acctAlignmentInfo.territoryId   = groupToTerritoryId.get( ash[i].UserOrGroupId);
          acctAlignmentInfo.TerritoryName = territoryMap.get(acctAlignmentInfo.territoryId).Name;
          acctAlignmentInfo.CreatedByUser = UserMap.get(ash[i].LastModifiedbyId).Name;
          String sProfileId = UserMap.get(ash[i].LastModifiedbyId).ProfileId;
          acctAlignmentInfo.CreatedByProfile = ProfileMap.get(sProfileId).Name;
          acctAlignmentInfo.TargetFlag =GetTsfStatus(acctAlignmentInfo.territoryId,accountID);

          System.debug('GroupId : ' + ash[i].UserOrGroupId + ' TerritoryId : ' + acctAlignmentInfo.TerritoryId);

          AccountShareUserProfile = acctAlignmentInfo.CreatedByProfile;
          if (currentUserProfile.contains('GNE-MedAffairs')||currentUserProfile.contains('GNE-TLS')||currentUserProfile.contains('GNE-SFA-HCV')){
              acctAlignmentInfo.ReadWrite= 1;
          }else{
              if (AccountShareUserProfile == currentUserProfile)
                 acctAlignmentInfo.ReadWrite= 1;
              else
                 acctAlignmentInfo.ReadWrite= 0;
          }
          aARV.acctAlignmentList.add(acctAlignmentInfo);

          System.debug ('adding element -> ' + i );
        }


        //aARV.AccountShares= [Select g.Id, g.RelatedId from Group g where  g.Id in:grps];
       // aARV.Groups= [Select g.Id, g.RelatedId from Group g where g.Type='Territory' and g.Id in:grps];
        aARV.TSFS=[ Select t.My_Target_vod__c,t.Id,t.Territory_vod__c  from TSF_vod__c t where t.Account_vod__c=:accountID];
        return aARV;
    }
/*
 get user territory - t1
*/
 //  Webservice static String[] GetTerritoryName (String userName){
 //        String[] territoryLists = new String[50];

   Webservice static List<Territory2> GetTerritoryList(String userName) {

       String territoryLists ='';
      // Get List of Territories assigned to the given User
       List<Territory2> terr = [Select Id, Name  from Territory2
                                            where  Id in  ( Select ut.Territory2Id
                                                            from UserTerritory2Association ut
                                                            Where ut.UserId = :UserInfo.getUserId())
                                                          ];


       return terr;
     }
    Webservice static String GetUserProfile (String UserId){

        String userProfile = '';
        try {
            List<Profile> prof = [select Id,Name from Profile
                                            where Id in (Select u.ProfileId from User u where u.Id = :UserId)
                                            ];

            if  (prof.Size() >0) {
             userProfile = prof[0].Name;
            }
         } catch (Exception e){
           system.debug('Error while getting Profile Id for the given User...');
         }
            return userProfile ;


    }/* GetUserProfile () */
   Webservice static String GetTerritoryId (String GroupId){

        String Id= '';
        try {
            List<Territory2> terr = [select Id,Name from Territory2
                                            where Id in (Select g.RelatedId from Group g where g.Id = :GroupId and g.type ='Territory')
                                            ];

            if  (terr.Size() >0) {
             Id= terr[0].Id;
            }
         } catch (Exception e){
           system.debug('Error while getting Territory Id for the given Group...');
         }
            return Id;

    }/* GetTerritoryId () */

   Webservice static Integer GetTsfStatus(String TerritoryId, String AccountId){

        Integer TargetStatus=0;
        String territoryName = getTerritoryName(TerritoryId);
        try {
            List<tsf_vod__c> terr = [Select t.My_Target_vod__c,t.Id
                                     from TSF_vod__c t where t.My_Target_vod__c = true
                                         and t.Account_vod__c=:accountID
                                         and territory_vod__c =:territoryName                                      ];

            if  (terr.Size() >0) {
             if(terr[0].My_Target_vod__c==true)
             TargetStatus = 1;
            }
         } catch (Exception e){
           system.debug('Error while getting TSF Status for the given Account...');
         }
            return TargetStatus;

    }/* GetTsfStatus() */
      Webservice static String getTerritoryName (String territoryId){

        String terrName = '';
        try {
            List<Territory2> terr = [select Id, Name from Territory2
                                            where Id =:territoryId];
            terrName= terr[0].Name;
         } catch (Exception e){
           system.debug('Error while getting territory Name ...');
         }
            return terrName;


    }/* getTerritoryName () */

      Webservice static String GetUserName (String UserId){

        String userName= '';
        try {
            List<User> usr = [select Name from User
                                            where Id =:UserId
                                            ];

            if  (usr.Size() >0) {
             userName= usr[0].Name;
            }
         } catch (Exception e){
           system.debug('Error while getting userName for the given userId...');
         }
            return userName;

    }/* GetUserName () */

     Webservice static String GetProfileName (String UserId){

        String ProfileName= '';
        try {
            List<Profile> prof = [select Name from Profile
                                            where Id in ( select profileid from user where id =:UserId)
                                            ];

            if  (prof.Size() >0) {
             ProfileName= prof[0].Name;
            }
         } catch (Exception e){
           system.debug('Error while getting ProfileName for the given userId...');
         }
            return ProfileName;

    }/* GetProfileName () */


}