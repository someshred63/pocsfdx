/************************************************************
*  @author: Sreedhar Karukonda
*  Date: 1/6/2013
*  Description: This class GNE_SFA2_SFASearchStr_Validation_Rules handles Validations on SFASearchStrings_gne__c object on DML operations
*  This class is being used in GNE_SFA2_SFASearchStrings_Trigger trigger
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/

public with sharing class GNE_SFA2_SFASearchStr_Validation_Rules {
	// On Before insert method
	public static void OnBeforeInsert (Map<Id,SFASearchStrings_gne__c> oldSearchStrMap,  List<SFASearchStrings_gne__c> newSearchStrList){
		LicenceAndStateRequired(oldSearchStrMap, newSearchStrList);
	}
	// On Before Update method
	public static void OnBeforeUpdate (Map<Id,SFASearchStrings_gne__c> oldSearchStrMap,  List<SFASearchStrings_gne__c> newSearchStrList){
		LicenceAndStateRequired(oldSearchStrMap, newSearchStrList);
	}
	private static void LicenceAndStateRequired(Map<id, SFASearchStrings_gne__c> oldSFASearchStrMap, List<SFASearchStrings_gne__c> newSFASearchStrList){
		for(SFASearchStrings_gne__c searchStr: newSFASearchStrList){
			if((!(searchStr.License_Number_gne__c == '' || searchStr.License_Number_gne__c == null)) && (searchStr.License_State_gne__c == null || searchStr.License_State_gne__c.contains('None')) && searchStr.Mode_gne__c == 'License'){
				searchStr.addError(Label.GNE_SFA2_SFASreachString_LICENCE_STATE_Required);
			}
		}
	}
}