global without sharing class Rep_Interactions_WS {


/*
1. get user territory - t1
2. get group id for step 1
2. get step 1 accounts - a1
3. get step 2 interactions - i1
4. remove all interactions from rep_interactions_gne__c table
5. load step 3 into rep_interactions_gne__c
Rep_Interactions_WS.UpdateRepInteraction
*/

    Webservice static boolean UpdateRepInteraction (String userName){

     /*
      // Get List of Territories assigned to the given User
      List<String> territoryList = new List<String>();
      for ( UserTerritory2Association userTerritory :  [ Select ut.Territory2Id
                                            from UserTerritory2Association ut
                                            Where ut.UserId = :UserInfo.getUserId()] )
        territoryList.add ( userTerritory.Territory2Id );

      // Identified GroupIds for List of Territories for those assigned to the given User
      Map<Id,Group> groupsMap=new Map<Id,Group>([Select id
                                                 from Group g
                                                 where g.RelatedId in :territoryList
                                                 and   g.Type = 'Territory'  ]);
      // Identified Accounts for List of Territories for those assigned to the given User
      List<String> accountList = new List<String> ();
      for (AccountShare a :  [ select a.accountId
                               from AccountShare a
                               where a.UserOrGroupId in :groupsMap.keySet()] )
        accountList.add ( a.AccountId );

          System.Debug ( accountList ) ;
    */
     // Get List of Territories assigned to the given User
     Id userId=null;

     if ( username != null ) {
         try {
             userId = [select id from user where username = :userName ].Id;
         } catch (Exception e) { }
     }


     if (userId == null)
       userId = UserInfo.getUserId();


      List<String> territoryList = new List<String>();
      for ( UserTerritory2Association userTerritory :  [ Select ut.Territory2Id
                                            from UserTerritory2Association ut
                                            Where ut.UserId = :userId] )
        territoryList.add ( userTerritory.Territory2Id );
        System.Debug ('Territory List : ' + territoryList ) ;

      // Identified TerrName for List of Territories for those assigned to the given User
      List<String> terrNameList=new List<String>();
       for (Territory2 terr : [Select t.name
                              from Territory2 t
                              where t.id in :territoryList
                             ])
           terrNameList.add (terr.Name );
           System.Debug ('Territory Name List: ' + terrNameList ) ;

      // Identified Accounts for List of Territories for those assigned to the given User
      List<String> accountList = new List<String> ();
      for (tsf_vod__c tsf :  [ select tsf.Account_Vod__c
                               from tsf_vod__c tsf
                               where tsf.territory_Vod__c in :terrNameList
                                 and My_Target_vod__c = true] )
        accountList.add (  tsf.Account_Vod__c);

        System.Debug ( 'Account List : ' + accountList ) ;

        // Delete all the existing InteractionsId in Rep_Interaction_gne__c object for this user

        for (Rep_interaction_gne__c[] rep_delete_list : [select id from rep_interaction_gne__c
                                                         where reportid__c = :UserInfo.getUserName()
                                                        ])
            delete rep_delete_list;


          Integer rowsAllowedToProcess = Limits.getLimitQueryRows();
          if (rowsAllowedToProcess > 4500)
            rowsAllowedToProcess = 4500;
          System.Debug('Remaining Rows allowed to Process: ' + rowsAllowedToProcess );

          // and Date_of_Interaction_gne__c > Last_N_Days:180
        for ( Call2_vod__c[] interactionList : [ select id from call2_vod__c
                           where account_vod__c in :accountList
                           and Date_of_Interaction_gne__c >= LAST_90_DAYS
                           order by Date_of_Interaction_gne__c desc
                           limit :rowsAllowedToProcess ] ) {

             List<Rep_Interaction_gne__c> rep_interaction_list  = new List<Rep_Interaction_gne__c> ();

             for (call2_vod__c c : interactionList) {

                 Rep_Interaction_gne__c rep_interaction = new Rep_Interaction_gne__c();
                 rep_interaction.call_interaction_vod__c = c.Id ;
                 rep_interaction.reportId__c = UserInfo.getUserName() ;
                 rep_interaction_list.add ( rep_interaction );
            }
            insert rep_interaction_list;
            System.debug(rep_interaction_list);
        }
    return true;

    }
}