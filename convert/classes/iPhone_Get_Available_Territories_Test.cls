/******************************************************************************************
*  @author: Waldemar Kaczor, Roche (contractor)
*  @email: waldemar.kaczor@contractors.roche.com
*  Created: 2018-08-03
*  Project: OTR2
*  Description: Tests for class iPhone_Get_Available_Territories_gne.
*******************************************************************************************/

@isTest
public class iPhone_Get_Available_Territories_Test {

	@testSetup
	static void testData() {
		Map<String, Id> ids2ProfilesMap = GNE_FRM_TestUtilities.getProfiles();
		User user1 = GNE_FRM_TestUtilities.createUser('TESTUSERXXXX', ids2ProfilesMap.get('GNE-Field'), false);
		User user2 = GNE_FRM_TestUtilities.createUser('TESTUSERYYYY', ids2ProfilesMap.get('GNE-Field'), false);
		User user3 = GNE_FRM_TestUtilities.createUser('TESTUSERZZZZ', ids2ProfilesMap.get('GNE-Field'), false);
		GNE_SFA2_Util.updateAdminSetings(true);
		insert new List<User> {user1,user2,user3};

		futureDML();
	}

	@future
	static void futureDML() {
		Id terrModelId = [SELECT Id FROM Territory2Model LIMIT 1].Id;
		Id terrTypeId = [SELECT Id FROM Territory2Type LIMIT 1].Id;
		Territory2 parentTerr = new Territory2(Name = 'GNE-US-SFA', DeveloperName = 'TEST', Territory2ModelId = terrModelId, Territory2TypeId = terrTypeId, External_Id_gne__c = 'Root;GNE-US-SFA', Parent_External_Id_gne__c ='Root');
		insert parentTerr;
		Territory2[] toInsert = new Territory2[]{};
		for(Integer x= 1; x<21; x++){
			Territory2 terr = GNE_FRM_TestUtilities.createTerritory('00F'+x+'-TEST', parentTerr.Id, false);
			terr.Salesforce_Code_gne__c = 'TEST';
			terr.Salesforce_SubTeam_Code_gne__c = 'TEST';
			terr.external_id_gne__c = 'Root;GNE-US-SFA;'+terr.Name;
			terr.Parent_External_Id_gne__c = 'Root;GNE-US-SFA';
			terr.Territory2ModelId = terrModelId;
			terr.Territory2TypeId = terrTypeId;
			toInsert.add(terr);
		}
		insert toInsert;
	}

    static testMethod void invokePostCall() {

		User[] existingUserInSystem = [
				SELECT Id, External_ID_gne__c
				FROM User
				WHERE Id IN (SELECT UserId FROM UserTerritory2Association)
				AND isActive = true
				AND Profile.Name IN ('GNE-SFA-Actemra-Manager','GNE-SFA-DM','GNE-SFA-Actemra-CS','GNE-SFA-CS','GNE-SFA-Lucentis-CS') LIMIT 1
		];
		if(existingUserInSystem.isEmpty()) return;

        Test.startTest();

			iPhone_Commons_gne.RestResponse restResponse = iPhone_Get_Available_Territories_gne.processRequest(existingUserInSystem.get(0).External_ID_gne__c);
			System.assertEquals(true, restResponse.success);
        
        Test.stopTest();
        
    }
    
}