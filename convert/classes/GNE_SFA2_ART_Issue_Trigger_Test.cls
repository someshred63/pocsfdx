/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-09-17
*  Description: This is a test class for GNE_SFA2_ART_Issue_Trigger
*    
*  Modification History
*  Date        Name        Description	    
*************************************************************/
@isTest
public with sharing class GNE_SFA2_ART_Issue_Trigger_Test {
	
	public static testMethod void testFieldUpdateUpdateCloseDateOnInsert() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_ART_Issue_Trigger', false);
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
				ART_Site_gne__c testArtSite = GNE_SFA2_ART_Issue_Test_Helper.prepareTestARTSite();
				
				Test.startTest();
				List<ART_Issue_gne__c> testArtIssues = GNE_SFA2_ART_Issue_Test_Helper.prepareTestARTIssues(null, new Map<String, String>{'ART_Site_Local_gne__c' => testArtSite.Id,
																	'Issue_Status_gne__c' => 'Closed', 'Date_Closed_gne__c' => null});
				insert testArtIssues;
				Test.stopTest();
				testArtIssues = [ SELECT Date_Closed_gne__c FROM ART_Issue_gne__c WHERE Id in :testArtIssues ];
				for(ART_Issue_gne__c artIssue : testArtIssues) {
					System.assertNotEquals(null, artIssue.Date_Closed_gne__c);
					System.assertEquals(System.today(), artIssue.Date_Closed_gne__c);
				}
			}
		} else {
			System.assert(false, 'Could not find any SFA2 Users!');
		}
	}
	
	public static testMethod void testFieldUpdateUpdateCloseDateOnInsert2() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_ART_Issue_Trigger', false);
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
				GNE_SFA2_Util.switchAdminMode(false);
				ART_Site_gne__c testArtSite = GNE_SFA2_ART_Issue_Test_Helper.prepareTestARTSite();
				
				Test.startTest();
				List<ART_Issue_gne__c> testArtIssues = GNE_SFA2_ART_Issue_Test_Helper.prepareTestARTIssues(null, new Map<String, Object>{'ART_Site_Local_gne__c' => testArtSite.Id,
																	'Issue_Status_gne__c' => 'Open', 'Date_Closed_gne__c' => System.today(), 'Resolution_Type_gne__c' => null});
				
				insert testArtIssues;
				Test.stopTest();
				testArtIssues = [ SELECT Date_Closed_gne__c FROM ART_Issue_gne__c WHERE Id in :testArtIssues ];
				for(ART_Issue_gne__c artIssue : testArtIssues) {
					System.assertEquals(null, artIssue.Date_Closed_gne__c);
				}
			}	
		} else {
			System.assert(false, 'Could not find any SFA2 Users!');
		}
	}
	
	public static testMethod void testFieldUpdateUpdateCloseDateOnUpdate() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_ART_Issue_Trigger', false);
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
				ART_Site_gne__c testArtSite = GNE_SFA2_ART_Issue_Test_Helper.prepareTestARTSite();
				
				Test.startTest();
				List<ART_Issue_gne__c> testArtIssues = GNE_SFA2_ART_Issue_Test_Helper.prepareTestARTIssues(null, new Map<String, Object>{'ART_Site_Local_gne__c' => testArtSite.Id,
																	'Issue_Status_gne__c' => 'Open', 'Date_Closed_gne__c' => null, 'Resolution_Type_gne__c' => null});
				insert testArtIssues;
				for(ART_Issue_gne__c testIssue : testArtIssues) {
					testIssue.Issue_Status_gne__c = 'Closed';
				}
				update testArtIssues;
				Test.stopTest();
				
				testArtIssues = [ SELECT Date_Closed_gne__c FROM ART_Issue_gne__c WHERE Id in :testArtIssues ];
				for(ART_Issue_gne__c artIssue : testArtIssues) {
					System.assertNotEquals(null, artIssue.Date_Closed_gne__c);
					System.assertEquals(System.today(), artIssue.Date_Closed_gne__c);
				}
			}	
		} else {
			System.assert(false, 'Could not find any SFA2 Users!');
		}
	}
	public static testMethod void testFieldUpdateUpdateCloseDateOnUpdate2() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_ART_Issue_Trigger', false);
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
				ART_Site_gne__c testArtSite = GNE_SFA2_ART_Issue_Test_Helper.prepareTestARTSite();
				
				Test.startTest();
				List<ART_Issue_gne__c> testArtIssues = GNE_SFA2_ART_Issue_Test_Helper.prepareTestARTIssues(null, new Map<String, Object>{'ART_Site_Local_gne__c' => testArtSite.Id,
																	'Issue_Status_gne__c' => 'Closed', 'Date_Closed_gne__c' => System.today(), 'Resolution_Type_gne__c' => 'test'});
				insert testArtIssues;
				for(ART_Issue_gne__c testIssue : testArtIssues) {
					testIssue.Issue_Status_gne__c = 'Open';
					testIssue.Resolution_Type_gne__c = null;
				}
				update testArtIssues;
				Test.stopTest();
				
				testArtIssues = [ SELECT Date_Closed_gne__c FROM ART_Issue_gne__c WHERE Id in :testArtIssues ];
				for(ART_Issue_gne__c artIssue : testArtIssues) {
					System.assertEquals(null, artIssue.Date_Closed_gne__c);
				}
			}	
		} else {
			System.assert(false, 'Could not find any SFA2 Users!');
		}
	}
	
	public static testMethod void testValidationRulesOnInsert() {
		//List<Profile> mccoProfiles = [ SELECT Id FROM Profile WHERE Name Like 'GNE-MCCO%' AND (NOT Name LIKE '%manager%')
		//								AND (NOT Name LIKE '%ops%') AND (NOT Name LIKE '%leadership%')];
		List<Profile> mccoProfiles = [ SELECT Id FROM Profile WHERE Name Like 'GNE-340B' AND (NOT Name LIKE '%manager%')
		AND (NOT Name LIKE '%ops%') AND (NOT Name LIKE '%leadership%')];

		List<User> mccoUsers = [ SELECT Id FROM User WHERE ProfileId in :mccoProfiles AND isActive = true limit 1];
		//GNE_SFA2_Util.insertMCCOProfileNamesCustomSetting();
		if(mccoUsers != null && mccoUsers.size() > 0) {
			ART_Site_gne__c testArtSite = GNE_SFA2_ART_Issue_Test_Helper.prepareTestARTSite();
			System.runAs(mccoUsers[0]) {
				List<ART_Issue_gne__c> testArtIssues = GNE_SFA2_ART_Issue_Test_Helper.prepareTestARTIssues(null, new Map<String, Object>{'ART_Site_Local_gne__c' => testArtSite.Id,
																'Issue_Status_gne__c' => 'Closed', 'Date_Closed_gne__c' => System.today()});
				try {
					insert testArtIssues;
					System.assert(false, 'ART Issues should not be added!');
				} catch (DMLException ex) {
					//System.assert(ex.getMessage().contains(System.Label.Cannot_Add_ART_Issues), ex.getMessage());
					//System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
				}
			}
		} else {
			System.assert(false, 'Could not find any GNE-MCCO Users');
		}
	}
	
	public static testMethod void testValidationRulesOnInsert2() {
		//List<Profile> mccoProfiles = [ SELECT Id FROM Profile WHERE Name Like 'GNE-MCCO%' AND (NOT Name LIKE '%manager%')
		//								AND (NOT Name LIKE '%ops%') AND (NOT Name LIKE '%leadership%')];
		List<Profile> mccoProfiles = [ SELECT Id FROM Profile WHERE Name Like 'GNE-340B' AND (NOT Name LIKE '%manager%')
										AND (NOT Name LIKE '%ops%') AND (NOT Name LIKE '%leadership%')];
		List<User> mccoUsers = [ SELECT Id FROM User WHERE ProfileId in :mccoProfiles AND isActive = true limit 1];
		ART_Site_gne__c testArtSite = GNE_SFA2_ART_Issue_Test_Helper.prepareTestARTSite();
		//GNE_SFA2_Util.insertMCCOProfileNamesCustomSetting();
		if(mccoUsers != null && mccoUsers.size() > 0) {
			System.runAs(mccoUsers[0]) {
				List<ART_Issue_gne__c> testArtIssues = GNE_SFA2_ART_Issue_Test_Helper.prepareTestARTIssues(null, new Map<String, Object>{'ART_Site_Local_gne__c' => testArtSite.Id,
																'Issue_Status_gne__c' => 'Closed', 'Date_Closed_gne__c' => System.today()});
				GNE_SFA2_ART_Issue_Test_Helper.prepareTestARTTeamMembership(testArtSite, mccoUsers[0]);
				try {
					insert testArtIssues;
				} catch (DMLException ex) {
					System.assert(false, 'ART Issues should be added: ' + ex.getMessage());
				}
			}
		} else {
			System.assert(false, 'Could not find any GNE-MCCO Users');
		}
	}
	
	public static testMethod void testValidationRulesOnInsertIssueNameMaxLength() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_ART_Issue_Trigger', false);
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
				ART_Site_gne__c testArtSite = GNE_SFA2_ART_Issue_Test_Helper.prepareTestARTSite();
		
				List<ART_Issue_gne__c> testArtIssues = GNE_SFA2_ART_Issue_Test_Helper.prepareTestARTIssues(null, new Map<String, Object>{'ART_Site_Local_gne__c' => testArtSite.Id,
																'Issue_Status_gne__c' => 'Closed', 'Date_Closed_gne__c' => System.today(), 
																'Name' => 'testtesttesttesttesttesttesttesttesttesttesttest'});
				try {
					insert testArtIssues;
				} catch (DMLException ex) {
					System.assert(ex.getMessage().contains(System.Label.Local_Market_Issue_Name_MaxLength), ex.getMessage());
					System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
				}
			}
		} else {
			System.assert(false, 'Could not find any SFA2 Users!');
		}
	}
	
	public static testMethod void testValidationRulesOnInsertResolutionTypeSelectedStatusClosed() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_ART_Issue_Trigger', false);
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
				ART_Site_gne__c testArtSite = GNE_SFA2_ART_Issue_Test_Helper.prepareTestARTSite();
		
				List<ART_Issue_gne__c> testArtIssues = GNE_SFA2_ART_Issue_Test_Helper.prepareTestARTIssues(null, new Map<String, Object>{'ART_Site_Local_gne__c' => testArtSite.Id,
																'Issue_Status_gne__c' => 'Open', 'Date_Closed_gne__c' => System.today(), 
																'Resolution_Type_gne__c' => 'Policy Changed'});
				try {
					insert testArtIssues;
				} catch (DMLException ex) {
					System.assert(ex.getMessage().contains(System.Label.Resolution_Type_Selected_And_Status_Closed), ex.getMessage());
					System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
				}
			}
		} else {
			System.assert(false, 'Could not find any SFA2 Users!');
		}
	}
	
	public static testMethod void testValidationRulesOnInsertTypeIssueAndStatusClosed() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_ART_Issue_Trigger', false);
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
				ART_Site_gne__c testArtSite = GNE_SFA2_ART_Issue_Test_Helper.prepareTestARTSite();
		
				List<ART_Issue_gne__c> testArtIssues = GNE_SFA2_ART_Issue_Test_Helper.prepareTestARTIssues(null, new Map<String, Object>{'ART_Site_Local_gne__c' => testArtSite.Id,
																'Issue_Status_gne__c' => 'Closed', 'Date_Closed_gne__c' => System.today(), 
																'Resolution_Type_gne__c' => '', 'Type_gne__c' => 'Issue'});
				try {
					insert testArtIssues;
				} catch (DMLException ex) {
					System.assert(ex.getMessage().contains(System.Label.Type_Issue_And_Status_Closed), ex.getMessage());
					System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
				}
			}
		} else {
			System.assert(false, 'Could not find any SFA2 Users!');
		}
	}
	
	public static testMethod void testValidationRulesOnUpdateIssueNameChange() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_ART_Issue_Trigger', false);
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
				ART_Site_gne__c testArtSite = GNE_SFA2_ART_Issue_Test_Helper.prepareTestARTSite();
		
				List<ART_Issue_gne__c> testArtIssues = GNE_SFA2_ART_Issue_Test_Helper.prepareTestARTIssues(null, new Map<String, Object>{'ART_Site_Local_gne__c' => testArtSite.Id,
																'Issue_Status_gne__c' => 'Closed', 'Date_Closed_gne__c' => null, 
																'Name' => 'test'});
				insert testArtIssues;
				
				for(ART_Issue_gne__c artIssue : testArtIssues) {
					artIssue.Name = 'changed name';
				}
				try {
					update testArtIssues;
				} catch (DMLException ex) {
					System.assert(ex.getMessage().contains(System.Label.Local_Market_Issue_Name_Change), ex.getMessage());
					System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
				}
			}
		} else {
			System.assert(false, 'Could not find any SFA2 Users!');
		}
	}
	
	public static testMethod void testValidationRulesOnUpdateIssueNameMaxLength() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_ART_Issue_Trigger', false);
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2USer != null) {
			//System.runAs(sfa2User) {
				ART_Site_gne__c testArtSite = GNE_SFA2_ART_Issue_Test_Helper.prepareTestARTSite();
		
				List<ART_Issue_gne__c> testArtIssues = GNE_SFA2_ART_Issue_Test_Helper.prepareTestARTIssues(null, new Map<String, Object>{'ART_Site_Local_gne__c' => testArtSite.Id,
																'Issue_Status_gne__c' => 'Closed', 'Date_Closed_gne__c' => System.today(), 
																'Name' => 'test'});
				insert testArtIssues;
				
				for(ART_Issue_gne__c artIssue : testArtIssues) {
					artIssue.Name = 'testtesttesttesttesttesttesttesttesttesttesttest';
				}
				try {
					update testArtIssues;
				} catch (DMLException ex) {
					System.assert(ex.getMessage().contains(System.Label.Local_Market_Issue_Name_MaxLength), ex.getMessage());
					System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
				}
			//}
		} else {
			System.assert(false, 'Could not find any SFA2 Users!');
		}
	}
	
	public static testMethod void testValidationRulesOnUpdateResolutionTypeSelectedStatusClosed() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_ART_Issue_Trigger', false);
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
				ART_Site_gne__c testArtSite = GNE_SFA2_ART_Issue_Test_Helper.prepareTestARTSite();
		
				List<ART_Issue_gne__c> testArtIssues = GNE_SFA2_ART_Issue_Test_Helper.prepareTestARTIssues(null, new Map<String, Object>{'ART_Site_Local_gne__c' => testArtSite.Id,
																'Issue_Status_gne__c' => 'Open', 'Date_Closed_gne__c' => System.today(), 
																'Resolution_Type_gne__c' => null});
				insert testArtIssues;
				for(ART_Issue_gne__c artIssue : testArtIssues) {
					artIssue.Resolution_Type_gne__c = 'Policy Changed';
				}															
				try {
					update testArtIssues;
				} catch (DMLException ex) {
					System.assert(ex.getMessage().contains(System.Label.Resolution_Type_Selected_And_Status_Closed), ex.getMessage());
					System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
				}
			}
		} else {
			System.assert(false, 'Could not find any SFA2 Users!');
		}
	}
	
	public static testMethod void testValidationRulesOnUpdateTypeIssueAndStatusClosed() {
		GNE_SFA2_Util.switchAdminMode(false);
		GNE_SFA2_Util.setTriggerDisabled('GNE_SFA2_ART_Issue_Trigger', false);
		//GNE_SFA2_Util.insertSFA2ProfileNamesCustomSetting('GNE-SFA2');
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2USer != null) {
			System.runAs(sfa2User) {
				ART_Site_gne__c testArtSite = GNE_SFA2_ART_Issue_Test_Helper.prepareTestARTSite();
		
				List<ART_Issue_gne__c> testArtIssues = GNE_SFA2_ART_Issue_Test_Helper.prepareTestARTIssues(null, new Map<String, Object>{'ART_Site_Local_gne__c' => testArtSite.Id,
																'Issue_Status_gne__c' => 'Open', 'Date_Closed_gne__c' => null,
																'Resolution_Type_gne__c' => null, 'Type_gne__c' => 'Issue'});
				insert testArtIssues;
				for(ART_Issue_gne__c artIssue : testArtIssues) {
					artIssue.Issue_Status_gne__c = 'Closed';
					artIssue.Date_Closed_gne__c = System.today();
				}	
				try {
					update testArtIssues;
				} catch (DMLException ex) {
					System.assert(ex.getMessage().contains(System.Label.Type_Issue_And_Status_Closed), ex.getMessage());
					System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
				}
			}
		} else {
			System.assert(false, 'Could not find any SFA2 Users!');
		}
	}
}