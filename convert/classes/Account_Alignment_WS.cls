global without sharing class Account_Alignment_WS {

	Webservice static Boolean GetAlignmentStatus (String territoryId, String accountId) {

		Boolean isAligned = false;

		try {
			Group groupRec = [select id from group
			                  where relatedId = :territoryId
			                                    and Type = 'Territory'
			                 ];

			AccountShare[] accShare =  [Select Id  from AccountShare
			                            where      AccountId = :accountId
			                                    and userorGroupId = :groupRec.id
			                           ];

			if ( accShare.size() > 0 )
				isAligned = true;
		} catch (Exception e) {
			return isAligned = false;
		}

		return isAligned;

	}
	Webservice static String getTerritoryName (String territoryId) {

		String terrName = '';
		try {
			List<Territory2> terr = [select Id, Name from Territory2
			                         where Id = :territoryId];
			terrName = terr[0].Name;
		} catch (Exception e) {
			system.debug('Error while getting territory Name ...');
		}
		return terrName;


	}/* getTerritoryId() */

	Webservice static String getUserorGroupId (String territoryId) {

		String UserorGroupId = '';
		try {
			List<group> grp = [select id from group
			                   where relatedId = :territoryId
			                                     and Type = 'Territory'
			                  ];

			if (grp.Size() > 0)
				UserorGroupId = grp[0].Id;
		} catch (Exception e) {
			system.debug('Error while getting territory Name ...');
		}
		return UserorGroupId;


	}/* GetUserorGroupId() */


	Webservice static Boolean GetTsfStatus (String territoryId, String accountId) {

		Boolean isAligned = false;

		try {
			Group groupRec = [select id from group
			                  where relatedId = :territoryId
			                                    and Type = 'Territory'
			                 ];

			AccountShare[] accShare =  [Select Id  from AccountShare
			                            where      AccountId = :accountId
			                                    and userorGroupId = :groupRec.id
			                           ];

			if ( accShare.size() > 0 )
				isAligned = true;
		} catch (Exception e) {
			return isAligned = false;
		}

		return isAligned;

	}
	Webservice static String GetTerritoryCode (String territoryName) {

		String TerrCode = '';
		Integer TerrCodeSize = 0;

		try {
			List<Product_Ind_to_Terr_gne__c> p = [select id, Territory_Code_gne__C, Territory_Code_Size_gne__C
			                                      from Product_Ind_To_Terr_gne__c
			                                     ];
			//System.debug('Size in Prod Ind : '+ p.Size());
			for (integer i = 0; i < p.Size(); i++) {
				// System.debug('The value of code '+ p[i].Territory_Code_Size_gne__c);
				TerrCodeSize = p[i].Territory_Code_Size_gne__c.intValue();
				// System.debug('TerrName: '+ territoryName.Substring(0,TerrCodeSize)+' and Code is '+ p[i].Territory_Code_gne__c);

				if (territoryName.Substring(0, TerrCodeSize) == p[i].Territory_Code_gne__c) {
					TerrCode = p[i].Territory_Code_gne__c;
					break;
				}
			}
		} catch (Exception e) {
			//TerrCode = 'Failed:' + p[0].Territory_Code_Size_gne__c;
			TerrCode = '';
		}

		return TerrCode ;

	}/*GetTerritoryCode */
	Webservice static Boolean InsertAccountShare (String territoryId, String accountId, Boolean tsfFlag) {
		Boolean isAligned = false;
		Account vAccount = [select id from account where id = :accountId];
		if (CheckAccountShareExists(territoryId, accountId) == false) {
			List<Group> groupRec = [select id, relatedId 
									from Group
			                        where relatedId = :territoryId
			                                and Type = 'Territory'
			                       ];

			System.debug('Executed Group query...' + groupRec.size());

			if (groupRec.size() != 0) {
				ObjectTerritory2Association territoryAssociation = new ObjectTerritory2Association(ObjectId = vAccount.id, Territory2Id = territoryId, AssociationCause='Territory2Manual');
				try {
					insert territoryAssociation;
					isAligned  = true;
				} catch (Exception e) {
					isAligned  = false;
				}
			}

		} else
			isAligned  = true;
		if (isAligned == true) {
			isAligned = false; //Reset to false until insert the tsf record
			tsf_vod__c tsf = new tsf_vod__c();
			tsf.Account_Vod__c = accountId;
			tsf.My_Target_vod__c =  tsfFlag;
			tsf.Territory_vod__c = getTerritoryName(TerritoryId); //TerritoryName
			/*****************************************************************************************************************************************
			Code change Modification Log
			Author  :- Kaustav Debnath
			Content :- Modified the insertion of a tsf record into upsert of the tsf record
			*****************************************************************************************************************************************/
			tsf.External_Id_vod__c = vAccount.id + '__' + tsf.Territory_vod__c; /*Packing the account id with the territory name to prepare the external id*/
			System.debug('####### tsf external id:- ' + tsf.External_Id_vod__c);/*Printing the external id in the debug log to
                                                                            check the 18digit account id gets
                                                                            concatenated with the territory name*/
			List<tsf_vod__c> tsfCheck = [select id from tsf_vod__c where External_Id_vod__c = :tsf.External_Id_vod__c];
			/*Checking if there is an entry with the external id in tsf table*/
			System.debug('####### tsfCheck :- ' + tsfCheck); /*printing the tsf check in the debug log*/
			if (tsfCheck.Size() > 0) {
				tsf.id = tsfCheck[0].id;/*equating the queried tsf id to our tsf record if found*/
				System.debug('####### tsf :- ' + tsf); /*printing the tsf record to check if the found tsf id has been associated to our tsf record*/
			}
			/*****************************************************************************************************************************************
			End of Modification of code
			*****************************************************************************************************************************************/
			try {
				upsert(tsf);/*changed the insert condition to upsert of the tsf record to overwrite the my target flag false value
                                entered by an interaction with a true value if My View is selected for MedAffairs records*/

				isAligned = true;
			} catch (Exception e) {
				isAligned = false;
			}
		}// end if (isAligned)
		//Begin: Siva Added few lines for taking care of NonTarget Accounts on 8/11/2010
//     else{
//        // The Account needs to be aligned into AccountShare but this is not Target Account, so we're removing from TSF
//        Boolean bDelTSF =DeleteTSF (territoryId,  accountId);
//     }
		//End:Siva
		Boolean bAffl = InsertBrandAffiliation(territoryId , accountId);
		return isAligned;
	}

	Webservice static Boolean SwitchAlignToTerritoryTransactionMode(Boolean mode) {
		//Use custom setting to inform account validation rules that we are in BAs insert transaction.
		Canada_Account_Config_gne__c cs = Canada_Account_Config_gne__c.getInstance(UserInfo.getUserID());

		if (cs != null) {
			cs.Align_To_Territory_Transaction_gne__c = mode;
			upsert cs;
		} else {
			System.debug('[BOS] Custom setting <Canada_Account_Config_gne__c> is missing');
		}
		return mode;
	}

	/*Webservice static Boolean InsertBrandAffiliation(String territoryId ,String accountId) {
	   Boolean isInsert = false;

	   //GetTerritoryName
	   String terrName = getTerritoryName(territoryId);
	   String terrCode = GetTerritoryCode(terrName);//terrName.substring(0,3);// This should be determined based on Length of the TerrCode
	   List<Product_Metrics_vod__c> brand_Affl_list  = new List<Product_Metrics_vod__c> ();

	     for (Product_Ind_To_Terr_gne__c pi : [ select Product_Indication_Name_gne__c from Product_Ind_To_Terr_gne__c
	                        where  Territory_Code_gne__c = :terrCode ] ) {
	          if (CheckBrandAfflExists(pi.Product_Indication_Name_gne__c,accountId) == false){
	          Product_Metrics_vod__c ba = new Product_Metrics_vod__c();
	          ba.Account_vod__c = accountId ;
	          ba.Products_vod__c = pi.Product_Indication_Name_gne__c ;
	          brand_Affl_list.add ( ba );
	          System.debug('ProductId: '+ pi.Product_Indication_Name_gne__c);
	          isInsert  = true;
	      }
	     }
	   if (brand_Affl_list.size()>0)
	       insert brand_Affl_list;
	   return isInsert ;
	}*/

	Webservice static Boolean InsertBrandAffiliation(String territoryId , String accountId) {
		Boolean isInsert = false;

		//GetTerritoryName
		String terrName = getTerritoryName(TerritoryId);
		String terrCode = GetTerritoryCode(terrName);//terrName.substring(0,3);// This should be determined based on Length of the TerrCode
		List<Product_Metrics_vod__c> brand_Affl_list  = new List<Product_Metrics_vod__c> ();

		List<Product_Metrics_vod__c> existingBrandAffiliations = [select Id, Name, Products_vod__c from Product_Metrics_vod__c
		        where Account_vod__c = :accountId];

		for (Product_Ind_To_Terr_gne__c pi : [ select Product_Indication_Name_gne__c from Product_Ind_To_Terr_gne__c
		                                       where  Territory_Code_gne__c = :terrCode ] ) {
			//if (CheckBrandAfflExists(pi.Product_Indication_Name_gne__c,accountId) == false){
			if (checkIfBrandAffiliationExists(pi.Product_Indication_Name_gne__c, existingBrandAffiliations) == false) {
				Product_Metrics_vod__c ba = new Product_Metrics_vod__c();
				ba.Account_vod__c = accountId ;
				ba.Products_vod__c = pi.Product_Indication_Name_gne__c ;
				brand_Affl_list.add ( ba );
				System.debug('ProductId: ' + pi.Product_Indication_Name_gne__c);
				isInsert  = true;
			}
		}
		if (brand_Affl_list.size() > 0)
			insert brand_Affl_list;
		return isInsert ;
	}

	Webservice static Boolean CheckAccountShareExists (String TerritoryId, String AccountId) {

		Boolean ASHExists = false;
		try {
			List<AccountShare> ash = [select Id from Accountshare
			                          where accountid = :AccountId and userorGroupId = :GetUserorGroupId(TerritoryId)
			                         ];
			if  (ash.Size() > 0) {
				ASHExists = true;
			}
		} catch (Exception e) {
			system.debug('Error while checking AccountShare...');
		}
		return ASHExists ;


	}/* CheckBrandAfflExists () */


	Webservice static Boolean CheckBrandAfflExists (String ProdIndId, String AccountId) {

		Boolean BAExists = false;
		try {
			List<Product_Metrics_vod__c> prod = [select Id, Name from Product_Metrics_vod__c
			                                     where Products_Vod__c = :ProdIndId and Account_vod__c = :AccountId];
			if  (prod.Size() > 0) {
				BAExists = true;
			}
		} catch (Exception e) {
			system.debug('Error while checking Brand Affiliation ...');
		}
		return BAExists ;


	}/* CheckBrandAfflExists () */

	private static Boolean checkIfBrandAffiliationExists(String prodIndId, List<Product_Metrics_vod__c> existingBrandAffiliations) {
		Boolean result = false;

		for (Product_Metrics_vod__c brandAffiliation : existingBrandAffiliations) {
			if (brandAffiliation.Products_Vod__c == prodIndId) {
				result = true;
				break;
			}
		}

		return result;
	}


	Webservice static Boolean DeleteAccountShare (String territoryId, String accountId) {
		Boolean isDelete = false;
		List<Group> groupRec = [select id from Group
		                        where relatedId = :territoryId
		                                and Type = 'Territory'
		                       ];

		if (groupRec.size() != 0) {

			// Delete all the existing AccountShare object for this Account and Territory
			AccountShare[] ash_delete_list =  [select id from AccountShare ash where ash.AccountId = :accountId
			                                   and ash.UserorGroupId in :groupRec and ash.rowcause = 'Territory2AssociationManual'];
			Database.DeleteResult[] results = Database.Delete (ash_delete_list);
			//ETL Optimization part
			GNE_SFA2_SharingMgmt_Trigger_Helper.insertSharingMgmtDeleteRecord(territoryId, accountId, results[0].getId());

			//GetTerritoryName
			String terrName = getTerritoryName(TerritoryId);

			// Delete all the existing tsf object for this Account and Territory
			tsf_vod__c[] tsf_delete_list =  [select id from tsf_vod__C tsf where tsf.Account_Vod__c = :accountId
			                                 and tsf.territory_Vod__C = :terrName] ;
			Database.Delete (tsf_delete_list);
			isDelete = true;
		}
		return isDelete;
	}
	Webservice static Boolean DeleteTSF (String territoryId, String accountId) {
		Boolean isDelete = false;

		//GetTerritoryName
		String terrName = getTerritoryName(TerritoryId);

		// Delete all the existing tsf object for this Account and Territory
		tsf_vod__c[] tsf_delete_list =  [select id from tsf_vod__C tsf where tsf.Account_Vod__c = :accountId
		                                 and tsf.territory_Vod__C = :terrName] ;
		Database.Delete (tsf_delete_list);
		isDelete = true;

		return isDelete;
	}
}