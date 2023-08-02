public without sharing class GNE_SFA2_Rep_Interactions {

	/*
	1. get user territory - t1
	2. get group id for step 1
	2. get step 1 accounts - a1
	3. get step 2 interactions - i1
	4. remove all interactions from rep_interactions_gne__c table
	5. load step 3 into rep_interactions_gne__c
	Rep_Interactions_WS.UpdateRepInteraction
	*/

    public String RPT_REP_INTERACTION {
        get{
            return Utilities.getGlobalVariable('RPT_REP_INTERACTION');
            }
        private set;
    }

    public Pagereference initReport() {
    	Boolean result = false;
    	try{
    		result = updateRepInteraction(UserInfo.getUserName());
    	}catch(Exception ex){
    		system.debug(ex.getMessage());
    		PageReference pageref = Page.GNE_SFA2_Information_Layout;
        	pageref.setredirect(true);
        	pageref.getParameters().put('message', System.Label.GNE_SFA2_Report_Unavailable);
        	pageref.getParameters().put('pageTitle', System.Label.GNE_SFA2_Report_Unavailable_Title);
        	pageref.getParameters().put('retUrl', Apexpages.currentPage().getUrl());
	        return pageref;
	    }
        if (result) {
	        String sURL =  '/apex/GNE_SFA2_Report_layout?id='+Utilities.getGlobalVariable('RPT_REP_INTERACTION');
	        Pagereference pageref = new Pagereference(sURL);
	        pageref.setredirect(true);
	        return pageref;
        }
        return null;
    }

    public static boolean UpdateRepInteraction (String userName){

	     /*
	      // Get List of Territories assigned to the given User
	      List<String> territoryList = new List<String>();
	      for ( UserTerritory2Association userTerritory :  [ SELECT ut.Territory2Id
	                                            FROM UserTerritory2Association ut
	                                            WHERE ut.UserId = :UserInfo.getUserId()] )
	        territoryList.add ( userTerritory.Territory2Id );

	      // Identified GroupIds for List of Territories for those assigned to the given User
	      Map<Id,Group> groupsMap=new Map<Id,Group>([SELECT id
	                                                 FROM Group g
	                                                 WHERE g.RelatedId in :territoryList
	                                                 AND   g.Type = 'Territory'  ]);
	      // Identified Accounts for List of Territories for those assigned to the given User
	      List<String> accountList = new List<String> ();
	      for (AccountShare a :  [ SELECT a.accountId
	                               FROM AccountShare a
	                               WHERE a.UserOrGroupId in :groupsMap.keySet()] )
	        accountList.add ( a.AccountId );

	          System.Debug ( accountList ) ;
	    */
	    // Get List of Territories assigned to the given User
	    Id userId = null;

	    if (username != null) {
	        try {
	        	userId = [SELECT id FROM user WHERE username = :userName].Id;
	    	} catch (Exception e) { }
	    }

	    if (userId == null){
	    	userId = UserInfo.getUserId();
	    }

	    List<String> territoryList = new List<String>();
	    for(UserTerritory2Association userTerritory : [SELECT ut.Territory2Id FROM UserTerritory2Association ut WHERE ut.UserId = :userId]){
	    	territoryList.add(userTerritory.Territory2Id);
	    }
	    System.Debug ('Territory List : ' + territoryList ) ;

	    // Identified TerrName for List of Territories for those assigned to the given User
	    List<String> terrNameList=new List<String>();
	    for (Territory2 terr : [SELECT t.name FROM Territory2 t WHERE t.id in :territoryList ]){
	    	terrNameList.add (terr.Name );
	    }
        System.Debug ('Territory Name List: ' + terrNameList ) ;

	    // Identified Accounts for List of Territories for those assigned to the given User
	    List<String> accountList = new List<String> ();
	    for (Tsf_vod__c tsf :  [SELECT tsf.Account_Vod__c FROM Tsf_vod__c tsf WHERE tsf.territory_Vod__c in :terrNameList AND My_Target_vod__c = true]){
	    	accountList.add (  tsf.Account_Vod__c);
	    }
	    System.Debug ( 'Account List : ' + accountList ) ;

	    // Delete all the existing InteractionsId in Rep_Interaction_gne__c object for this user
    	delete [SELECT id FROM rep_interaction_gne__c WHERE reportid__c = :UserInfo.getUserName()];

	    Integer rowsAllowedToProcess = Limits.getLimitQueryRows();
	    if (rowsAllowedToProcess > 4500){
	    	rowsAllowedToProcess = 4500;
	    }
	    System.Debug('Remaining Rows allowed to Process: ' + rowsAllowedToProcess );

	    // and Date_of_Interaction_gne__c > Last_N_Days:180
		for ( Call2_vod__c[] interactionList : [ SELECT id FROM call2_vod__c WHERE account_vod__c in :accountList
						                          AND Date_of_Interaction_gne__c >= LAST_90_DAYS
						                          ORDER BY Date_of_Interaction_gne__c DESC
	                           					  LIMIT :rowsAllowedToProcess]) {
	        List<Rep_Interaction_gne__c> rep_interaction_list  = new List<Rep_Interaction_gne__c> ();
	        for (Call2_vod__c c : interactionList) {
	        	rep_interaction_list.add (new Rep_Interaction_gne__c(Call_Interaction_vod__c = c.Id, reportId__c = UserInfo.getUserName()));
	        }
	        insert rep_interaction_list;
	    	System.debug(rep_interaction_list);
	    }
		return true;
    }
}