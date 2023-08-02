/************************************************************
*  @author: Lukasz Bieniawski, Roche (contractor)
*  @email: lukasz.bieniawski@contractors.roche.com
*  Date: 2014-01-21
*  Description: Test Class for IPhoneSettingsRecord
*  
*  Modification History
*  Date            Name               Description
*************************************************************/

@isTest
private class IPhoneSettingsRecord_Test {
	
	static testMethod void testCreateNewSettingRecordSimpleText(){
		Integer textLength = getFirstFieldAvailableTextLength();
		String testStr = constructTestString(textLength);
		setText(testStr);
		checkResult(testStr);
	}
	
	static testMethod void testCreateNewSettingRecordNullText(){
		String testStr = null;
		setText(testStr);
		checkResult(testStr);
	}
	
	static testMethod void testCreateNewSettingRecordEmptyText(){
		String testStr = '';
		String expectedTextStr = null;
		setText(testStr);
		checkResult(expectedTextStr);
	}
	
	static testMethod void testCreateNewSettingRecordTextTooLong(){
		Integer textLength = IPhoneSettingsRecord.getInstance().availableTextLength + 1;
		String testStr = constructTestString(textLength);
		String expectedTextStr = null;
		setText(testStr);
		checkResult(expectedTextStr);
	}
	
	static testMethod void testUpdateSettingRecordSimpleText(){
		prepareRecord();
		Integer textLength = getFirstFieldAvailableTextLength();
		String testStr = constructTestString(textLength); 
		setText(testStr);
		checkResult(testStr);
	}
	
	static testMethod void testUpdateSettingRecordFullText(){
		prepareRecord();
		Integer textLength = IPhoneSettingsRecord.getInstance().availableTextLength;
		String testStr = constructTestString(textLength); 
		setText(testStr);
		checkResult(testStr);
	}
	
	static testMethod void testUpdateSettingRecordHalfText(){
		prepareRecord();
		Integer textLength = Integer.valueOf(IPhoneSettingsRecord.getInstance().availableTextLength / 2);
		String testStr = constructTestString(textLength);
		setText(testStr);
		checkResult(testStr);
	}
	
	private static void setText(String textStr){
		IPhoneSettingsRecord.getInstance().setText(textStr);
		IPhoneSettingsRecord.getInstance().save();
	}
	
	private static void checkResult(String expectedTextStr){
		IPhoneSettingsRecord.refresh();
		System.assertEquals(expectedTextStr, IPhoneSettingsRecord.getInstance().getText());		
	}
	
	private static void prepareRecord(){
		SObject newRecord = GNE_SFA2_Application_Cache.globalDescribe.get('GNE_iPhone_Settings__c').newSObject();
		insert newRecord;
	}
	
	private static Integer getFirstFieldAvailableTextLength(){
		return IPhoneSettingsRecord.getInstance().textFields[0].fieldSize - IPhoneSettingsRecord.getInstance().textWrappingCharsSize;
	}
	
	public static String constructTestString(Integer length) {
    	String sample = 'abc  12345'; // 10-digit string    
    	for (Integer cutoff = 10; cutoff <= 1000000; cutoff = cutoff * 10) {
        	if (length <= cutoff) {
            	return sample.substring(0, length);
        	}else {
            	String newSample = '';
            	for (Integer i = 0; i < 10; i ++) {
                	newSample += sample;
            	}
            	sample = newSample;
        	}
    	}    
    	return null;
	}
}