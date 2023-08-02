/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-07-16
*  Description: This is a helper class for GNE_SFA2_SharingMgmt_Trigger, which creates actual AccountShares and CaseShares
*    
*  Modification History
*  Date        Name        Description
*  2012-08-10  kwiatkol    Added more descriptive error messages
*  2012-10-15  kwiaktol    Added inserting AccountShares with User Id specified
*************************************************************/
public without sharing class GNE_SFA2_SharingMgmt_Child_Record_Update {
    
    public static void onAfterInsertUpdate(List<Sharing_Mgmt_gne__c> triggerNew) {
        List<AccountShare> accSharesToAdd = new List<AccountShare>();
        List<ObjectTerritory2Association> objTerr2AssToAdd = new List<ObjectTerritory2Association>();
        Map<String, Sharing_Mgmt_gne__c> accSharingManagementToAdd = new Map<String, Sharing_Mgmt_gne__c>();
        List<CaseShare> caseSharesToAdd = new List<CaseShare>();
        List<Sharing_Mgmt_gne__c> caseSharingManagementToAdd = new List<Sharing_Mgmt_gne__c>();
        
        List<AccountShare> accSharesToDelete = new List<AccountShare>();
        List<ObjectTerritory2Association> objTerr2AssToDelete = new List<ObjectTerritory2Association>();
        Map<String, Sharing_Mgmt_gne__c> accSharingManagementToDelete = new Map<String, Sharing_Mgmt_gne__c>();
        Map<String, Sharing_Mgmt_gne__c> objTerr2AssManagemenToDelete = new Map<String, Sharing_Mgmt_gne__c>();
        List<CaseShare> caseSharesToDelete = new List<CaseShare>();
        Map<String, Sharing_Mgmt_gne__c> caseSharingManagementToDelete = new Map<String, Sharing_Mgmt_gne__c>();
        
        Set<Id> accountIdsToDelete = new Set<Id>();
        Set<Id> caseIdsToDelete = new Set<Id>();
        Set<Id> terrIdsToDelete = new Set<Id>();
        Set<Id> userIdsToDelete = new Set<Id>();
        
        Set<Id> terrIds = new Set<Id>();
        for(Sharing_Mgmt_gne__c shareMgmt : triggerNew) {
            terrIds.add(shareMgmt.Territory_Id_gne__c);
        }
        
        Map<String, String> terrToGroup = new Map<String, String>();
        for(Group g : [ SELECT RelatedId, Id FROM Group WHERE RelatedId in :terrIds AND Type = 'Territory']) {
          terrToGroup.put(g.RelatedId, g.Id);
        }
        
        for(Sharing_Mgmt_gne__c shareMgmt : triggerNew) {
            if(shareMgmt.Object_Name_gne__c == 'AccountShare') {
                if(shareMgmt.Operation_gne__c == 'Insert' && shareMgmt.Status_gne__c == 'New') {
                	if(shareMgmt.Territory_Id_gne__c != null) {
                		objTerr2AssToAdd.add(new ObjectTerritory2Association(ObjectId = shareMgmt.Account_Id_gne__c, Territory2Id = shareMgmt.Territory_Id_gne__c, AssociationCause='Territory2Manual'));
                    	accSharingManagementToAdd.put(String.valueOf(shareMgmt.Account_Id_gne__c) + String.valueOf(shareMgmt.Territory_Id_gne__c), shareMgmt);
                    } else if(shareMgmt.User_Id_gne__c != null){
                		accSharesToAdd.add(new AccountShare(AccountId = shareMgmt.Account_Id_gne__c, UserOrGroupId = shareMgmt.User_Id_gne__c, AccountAccessLevel = shareMgmt.Account_Access_Level_gne__c, OpportunityAccessLevel = shareMgmt.Opportunity_Access_Level_gne__c));
                		accSharingManagementToAdd.put(String.valueOf(shareMgmt.Account_Id_gne__c) + String.valueOf(shareMgmt.User_Id_gne__c), shareMgmt);
                	}
                } else if(shareMgmt.Operation_gne__c == 'Delete' && shareMgmt.Status_gne__c == 'New') {
                    accountIdsToDelete.add(shareMgmt.Account_Id_gne__c);
                    if(shareMgmt.Territory_Id_gne__c != null) {
                    	terrIdsToDelete.add(shareMgmt.Territory_Id_gne__c);
                    	accSharingManagementToDelete.put(String.valueOf(shareMgmt.Account_Id_gne__c) + String.valueOf(shareMgmt.Territory_Id_gne__c), shareMgmt);
                    	objTerr2AssManagemenToDelete.put(String.valueOf(shareMgmt.Account_Id_gne__c) + String.valueOf(shareMgmt.Territory_Id_gne__c), shareMgmt);
                    } else if(shareMgmt.User_Id_gne__c != null){
                    	userIdsToDelete.add(shareMgmt.User_Id_gne__c);
                    	accSharingManagementToDelete.put(String.valueOf(shareMgmt.Account_Id_gne__c) + String.valueOf(shareMgmt.User_Id_gne__c), shareMgmt);
                    }
                }
            } else if(shareMgmt.Object_Name_gne__c == 'CaseShare') {
                if(shareMgmt.Operation_gne__c == 'Insert' && shareMgmt.Status_gne__c == 'New') {
                    caseSharesToAdd.add(new CaseShare(CaseId = shareMgmt.Case_Id_gne__c, UserOrGroupId = shareMgmt.User_Id_gne__c, CaseAccessLevel = shareMgmt.Case_Access_Level_gne__c));
                    caseSharingManagementToAdd.add(shareMgmt);
                } else if(shareMgmt.Operation_gne__c == 'Delete' && shareMgmt.Status_gne__c == 'New') {
                    caseIdsToDelete.add(shareMgmt.Case_Id_gne__c);
                    userIdsToDelete.add(shareMgmt.User_Id_gne__c);
                    caseSharingManagementToDelete.put(String.valueOf(shareMgmt.Case_Id_gne__c) + String.valueOf(shareMgmt.User_Id_gne__c), shareMgmt);
                }
            }
        } 
        
        if(objTerr2AssToAdd.size() > 0) {
            Database.SaveResult[] r = Database.insert(objTerr2AssToAdd, false);
            for(Integer i = 0; i < objTerr2AssToAdd.size(); i++) {
                String accountId = String.valueOf(objTerr2AssToAdd[i].ObjectId);
                String territoryId = String.valueOf(objTerr2AssToAdd[i].Territory2Id);
                if(r[i].isSuccess()) {
                    accSharingManagementToAdd.get(accountId + territoryId).Status_gne__c = 'Completed';
                    accSharingManagementToAdd.get(accountId + territoryId).Record_Id_gne__c = r[i].getId();
                } else {
                    accSharingManagementToAdd.get(accountId + territoryId).Status_gne__c = 'Error';
                    accSharingManagementToAdd.get(accountId + territoryId).Comments_gne__c = r[i].getErrors()[0].getMessage();
                }
            }
        }  
        
        if(accSharesToAdd.size() > 0) {
            Database.SaveResult[] r = Database.insert(accSharesToAdd, false);
            for(Integer i = 0; i < accSharesToAdd.size(); i++) {
                String accountId = String.valueOf(accSharesToAdd[i].AccountId);
                String userId = String.valueOf(accSharesToAdd[i].UserOrGroupId);
                if(r[i].isSuccess()) {
                    accSharingManagementToAdd.get(accountId + userId).Status_gne__c = 'Completed';
                    accSharingManagementToAdd.get(accountId + userId).Record_Id_gne__c = r[i].getId();
                } else {
                    accSharingManagementToAdd.get(accountId + userId).Status_gne__c = 'Error';
                    accSharingManagementToAdd.get(accountId + userId).Comments_gne__c = r[i].getErrors()[0].getMessage();
                }
            }
        }
        
        if(caseSharesToAdd.size() > 0) {
            Database.SaveResult[] r = Database.insert(caseSharesToAdd, false);
            for(Integer i = 0; i < caseSharesToAdd.size(); i++) {
                if(r[i].isSuccess()) {
                    caseSharingManagementToAdd[i].Status_gne__c = 'Completed';
                    caseSharingManagementToAdd[i].Record_Id_gne__c = r[i].getId();
                } else {
                    caseSharingManagementToAdd[i].Status_gne__c = 'Error';
                    caseSharingManagementToAdd[i].Comments_gne__c = r[i].getErrors()[0].getMessage(); 
                }
            }
        }
        
        // map used for checking if AccountShare record was found for Sharing Management record
        // key is an external id build this way: External_Id_gne__c = SharingManagmenet_gne__c.Account_Id_gne__c + SharingManagmenet_gne__c.Territory_Id_gne__c
        Map<String, AccountShare> accountShareExternalIdToAccountShare = new Map<String, AccountShare>();
        Map<Id, Group> terrGroupIds = new Map<Id, Group>([ SELECT Id, RelatedId FROM Group WHERE RelatedId in :terrIdsToDelete ]);
        if(accountIdsToDelete.size() > 0 && terrIdsToDelete.size() > 0) {
            objTerr2AssToDelete = [ SELECT Id, ObjectId, Territory2Id FROM ObjectTerritory2Association WHERE ObjectId IN :accountIdsToDelete AND Territory2Id IN :terrIdsToDelete ];
            System.debug('##### objTerr2AssToDelete ===' + objTerr2AssToDelete);
            // build map
            for (AccountShare accountShare : accSharesToDelete) {
                accountShareExternalIdToAccountShare.put(String.valueOf(accountShare.AccountId) + String.valueOf(terrGroupIds.get(accountShare.UserOrGroupId).RelatedId), accountShare);
            }
        } else if (accountIdsToDelete.size() > 0 && userIdsToDelete.size() > 0) {
        	accSharesToDelete = [ SELECT Id, AccountId, UserOrGroupId FROM AccountShare WHERE AccountId IN :accountIdsToDelete AND UserOrGroupId IN :userIdsToDelete ];
            // build map
            for (AccountShare accountShare : accSharesToDelete) {
                accountShareExternalIdToAccountShare.put(String.valueOf(accountShare.AccountId) + String.valueOf(accountShare.UserOrGroupId), accountShare);
            }
        }
        
        for(Sharing_Mgmt_gne__c shareMgmt : accSharingManagementToDelete.values()) {
        	if(shareMgmt.Territory_Id_gne__c != null) {
	            if(! accountShareExternalIdToAccountShare.containsKey(String.valueOf(shareMgmt.Account_Id_gne__c) + String.valueOf(shareMgmt.Territory_Id_gne__c))) {
	                shareMgmt.Status_gne__c = 'Error';
	                shareMgmt.Comments_gne__c = System.Label.No_AccountShare_To_Delete;
	            }
        	} else if(shareMgmt.User_Id_gne__c != null) {
        		if(! accountShareExternalIdToAccountShare.containsKey(String.valueOf(shareMgmt.Account_Id_gne__c) + String.valueOf(shareMgmt.User_Id_gne__c))) {
	                shareMgmt.Status_gne__c = 'Error';
	                shareMgmt.Comments_gne__c = System.Label.No_AccountShare_To_Delete;
	            }
        	}
        }
        if(objTerr2AssToDelete.size() > 0) {
            Database.DeleteResult[] r = Database.delete(objTerr2AssToDelete, false);
            for(Integer i = 0; i < objTerr2AssToDelete.size(); i++) {
            	String accountId = String.valueOf(objTerr2AssToDelete[i].ObjectId);
            	String territoryId = String.valueOf(objTerr2AssToDelete[i].Territory2Id);
            	system.debug(accountId + '; ' +territoryId);
            	system.debug(accSharingManagementToDelete.containsKey(accountId + territoryId));
            	system.debug(r[i].isSuccess());
            	
            	if(accSharingManagementToDelete.containsKey(accountId + territoryId)) {
                    if(r[i].isSuccess()) {
	                        accSharingManagementToDelete.get(accountId + territoryId).Status_gne__c = 'Completed';
	                        accSharingManagementToDelete.get(accountId + territoryId).Record_Id_gne__c = r[i].getId();	                    	
                    } else {
	                	accSharingManagementToDelete.get(accountId + territoryId).Status_gne__c = 'Error';
	                    accSharingManagementToDelete.get(accountId + territoryId).Comments_gne__c = r[i].getErrors()[0].getMessage();
                    }
                }
            	
            }
        }
        system.debug(accSharesToDelete);
        if(accSharesToDelete.size() > 0) {
            Database.DeleteResult[] r = Database.delete(accSharesToDelete, false);
            for(Integer i = 0; i < accSharesToDelete.size(); i++) {
        		if(accSharingManagementToDelete.containsKey(String.valueOf(accSharesToDelete[i].AccountId) + String.valueOf(accSharesToDelete[i].UserOrGroupId))) {
                    if(r[i].isSuccess()) {
	                	accSharingManagementToDelete.get(String.valueOf(accSharesToDelete[i].AccountId) + String.valueOf(accSharesToDelete[i].UserOrGroupId)).Status_gne__c = 'Completed';
	                    accSharingManagementToDelete.get(String.valueOf(accSharesToDelete[i].AccountId) + String.valueOf(accSharesToDelete[i].UserOrGroupId)).Record_Id_gne__c = r[i].getId();	                    	
                    } else {
	                	accSharingManagementToDelete.get(String.valueOf(accSharesToDelete[i].AccountId) + String.valueOf(accSharesToDelete[i].UserOrGroupId)).Status_gne__c = 'Error';
	                    accSharingManagementToDelete.get(String.valueOf(accSharesToDelete[i].AccountId) + String.valueOf(accSharesToDelete[i].UserOrGroupId)).Comments_gne__c = r[i].getErrors()[0].getMessage();
                    }
                }
            }
        }
        
        // mark remaining account share records with an error
         for(Sharing_Mgmt_gne__c shareMgmt : accSharingManagementToDelete.values()) {
            if(shareMgmt.Status_gne__c == 'New') {
                shareMgmt.Status_gne__c = 'Error';
                shareMgmt.Comments_gne__c = 'Given Territory Id and Account Id pair was already processed'; 
            }
         }
        
        // map used for checking if CaseShare record was found for Sharing Management record
        // key is an external id build this way: External_Id_gne__c = SharingManagmenet_gne__c.Case_Id_gne__c + SharingManagmenet_gne__c.User_Id_gne__c
        Map<String, CaseShare> caseShareExternalIdToCaseShare = new Map<String, CaseShare>();  
        if(caseIdsToDelete.size() > 0 && userIdsToDelete.size() > 0) {
            caseSharesToDelete = [ SELECT Id, CaseId, UserOrGroupId  FROM CaseShare WHERE CaseId IN :caseIdsToDelete AND UserOrGroupId IN :userIdsToDelete ];
            // build map
            for (CaseShare caseShare : caseSharesToDelete) {
                //system.debug('Inside case share delete:' + String.valueOf(caseShare.CaseId) + String.valueOf(caseShare.UserOrGroupId));
                caseShareExternalIdToCaseShare.put(String.valueOf(caseShare.CaseId) + String.valueOf(caseShare.UserOrGroupId), caseShare);
            }
        }
        
        for(Sharing_Mgmt_gne__c shareMgmt : caseSharingManagementToDelete.values()) {
        //system.debug('Inside share mgmt:'+ String.valueOf(shareMgmt.Case_Id_gne__c) + String.valueOf(shareMgmt.User_Id_gne__c) );
            if(! caseShareExternalIdToCaseShare.containsKey(String.valueOf(shareMgmt.Case_Id_gne__c) + String.valueOf(shareMgmt.User_Id_gne__c))) {
                shareMgmt.Status_gne__c = 'Error';
                shareMgmt.Comments_gne__c = System.Label.No_CaseShare_To_Delete;
            }
        }
        if(caseSharesToDelete.size() > 0) {
            Database.DeleteResult[] r = Database.delete(caseSharesToDelete, false);
            for(Integer i = 0; i < caseSharesToDelete.size(); i++) {
                if(caseSharingManagementToDelete.containsKey(String.valueOf(caseSharesToDelete[i].CaseId) + String.valueOf(caseSharesToDelete[i].UserOrGroupId))) {
                    if(r[i].isSuccess()) {
                        caseSharingManagementToDelete.get(String.valueOf(caseSharesToDelete[i].CaseId) + String.valueOf(caseSharesToDelete[i].UserOrGroupId)).Status_gne__c = 'Completed';
                        caseSharingManagementToDelete.get(String.valueOf(caseSharesToDelete[i].CaseId) + String.valueOf(caseSharesToDelete[i].UserOrGroupId)).Record_Id_gne__c = r[i].getId();
                    } else {
                        caseSharingManagementToDelete.get(String.valueOf(caseSharesToDelete[i].CaseId) + String.valueOf(caseSharesToDelete[i].UserOrGroupId)).Status_gne__c = 'Error';
                        caseSharingManagementToDelete.get(String.valueOf(caseSharesToDelete[i].CaseId) + String.valueOf(caseSharesToDelete[i].UserOrGroupId)).Comments_gne__c = r[i].getErrors()[0].getMessage();
                    }
                }
            }
        }
        
        // mark remaining case share records with an error
         for(Sharing_Mgmt_gne__c shareMgmt : caseSharingManagementToDelete.values()) {
            if(shareMgmt.Status_gne__c == 'New') {
                shareMgmt.Status_gne__c = 'Error';
                shareMgmt.Comments_gne__c = 'Given User Id and Case Id pair was already processed'; 
            }
         }
    }
}