@isTest
private class CFAR_ConfigUtil_Test {

	@testSetup
	static void setup() {
		insert new CFAR_Setting_gne__c(SetupOwnerId = UserInfo.getProfileId(), Disabled_Triggers_gne__c = null, Disabled_Validation_Rules_gne__c = null);
		insert new CFAR_Setting_gne__c(SetupOwnerId=UserInfo.getOrganizationId(), Disabled_Triggers_gne__c = null, Disabled_Validation_Rules_gne__c = null);
	}

	static testMethod void setDisabled_shouldSetTrueToCustomSetting() {
		//GIVEN
		CFAR_Setting_gne__c setting = CFAR_Setting_gne__c.getInstance(UserInfo.getProfileId());
		System.assertEquals(null, setting.get('Disabled_Validation_Rules_gne__c'), 
			'Initially, instance setting value of Disabled_Validation_Rules_gne__c should be null.');

		//WHEN
		CFAR_ConfigUtil.setDisabled('Disabled_Validation_Rules_gne__c', new List<String>{'test_Validation_Rule'});

		//THEN
		setting = CFAR_Setting_gne__c.getInstance(UserInfo.getProfileId());
		System.assertEquals('test_Validation_Rule', setting.get('Disabled_Validation_Rules_gne__c'), 
			'setDisabled function should set instance setting value of Disabled_Validation_Rules_gne__c to test_Validation_Rule');

		Boolean isEnabled = CFAR_ConfigUtil.isEnabled('Disabled_Validation_Rules_gne__c', new List<String>{'test_Validation_Rule'});
		System.assertEquals(false, isEnabled,
			'CFAR_ConfigUtil.isEnabled should return false, if CFAR_Setting_gne__c.Disabled_Validation_Rules_gne__c has test_Validation_Rule value, meaning validation rule were disabeled.');
	}

	static testMethod void isTriggerEnabled_shouldCheckIfTriggerIsEnabled() {
		//WHEN
		CFAR_ConfigUtil.setDisabled('Disabled_Triggers_gne__c', new List<String>{'test_Trigger'});

		//THEN
		Boolean functionResult = CFAR_ConfigUtil.isTriggerEnabled(new List<String>{'test_Trigger'});
		System.assertEquals(false, functionResult, 'isTriggerEnabled should return false if trigger is disabled.');
	}
}