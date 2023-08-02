/******************************************************************************************
*  @author: Lukasz Bieniawski, Roche (contractor)
*  @email: lukasz.bieniawski@contractors.roche.com   
*  Created: 2014-01-21
*  Project: OTR2
*  Test class: IPhoneSettingsRecord_Test
*  Description: The Read/write logic responsible for manage data stored in the GNE_iPhone_Settings__c object.
*	Global configuration for OTR2 project is stored as a json string in one record and several fields.
* 	The configuration text can be edited at the iPhone_Settings_gne.page and is returned
*	by REST Webservice iPhone_Get_Configuration_gne
*
*  Modification History
*  Date            Name               Description
*******************************************************************************************/

public with sharing class IPhoneSettingsRecord {
	
	private static IPhoneSettingsRecord instance = null;
	
	private SObject record = null;
	
	// Text must be wrapped to avoid losing whitespaces
	private String textWrappingChar = '\'';
	
	@TestVisible
	private Integer textWrappingCharsSize;
	
	@TestVisible 
	private Integer availableTextLength { get; set; }
	
	private Boolean hasErrors { get; set; }
	
	// Fields containing the text. If need more space, just simply add new one, but keep focus on correct order.
	@TestVisible 
	private List<IPhoneFieldDescription> textFields {
		get {
			if (textFields == null || textFields.isEmpty()){
				textFields = new List<IPhoneFieldDescription>{
					new IPhoneFieldDescription(String.valueOf(GNE_iPhone_Settings__c.Text_Settings_gne__c)),
					new IPhoneFieldDescription(String.valueOf(GNE_iPhone_Settings__c.Text_Settings_2_gne__c)),
					new IPhoneFieldDescription(String.valueOf(GNE_iPhone_Settings__c.Text_Settings_3_gne__c)),
					new IPhoneFieldDescription(String.valueOf(GNE_iPhone_Settings__c.Text_Settings_4_gne__c)),
					new IPhoneFieldDescription(String.valueOf(GNE_iPhone_Settings__c.Text_Settings_5_gne__c))
				}; 
			}
			return textFields;
		}
		set;
	}
	
	private String text { get; set; } 
					
	public String getText(){
		return this.text;
	}
	
	public void setText(String textStr){
		this.hasErrors = false;
		if (String.isBlank(textStr)){
			for (IPhoneFieldDescription fieldDescription : textFields){
				this.record.put(fieldDescription.apiName, null);
			}			
		} else {
			Integer textLength = textStr.length();
			if (textLength > this.availableTextLength){
				this.record.addError('The text is too long: ' + textLength + ', available length: ' + this.availableTextLength + '.');
				this.hasErrors = true;
				return;
			}			
			Integer startIndex = 0;
			Integer endIndex = textLength;
			Boolean textContained = false;
			for (IPhoneFieldDescription fieldDescription : textFields){
				if (textContained){
					this.record.put(fieldDescription.apiName, null);
					continue;
				}
				if (fieldDescription.fieldSize < (endIndex - startIndex + this.textWrappingCharsSize)){
					endIndex = fieldDescription.fieldSize + startIndex - this.textWrappingCharsSize;
				} else {
					textContained = true;
				}				
				String fieldValue = wrapText(textStr.substring(startIndex, endIndex));
				this.record.put(fieldDescription.apiName, fieldValue);
				startIndex = endIndex;
				endIndex = textLength;
			}			
		}
		this.text = textStr;
	}
	
	private IPhoneSettingsRecord(){
		this.hasErrors = false;
		this.textWrappingCharsSize = String.isNotBlank(this.textWrappingChar) ? (this.textWrappingChar.length() * 2) : 0;
		this.availableTextLength = getAvailableTextLength();			
		this.record = readRecord();
		this.text = readText();
	}
	
	private Integer getAvailableTextLength(){
		Integer result = 0;
		for (IPhoneFieldDescription fieldDescription : textFields){
			result += (fieldDescription.fieldSize - this.textWrappingCharsSize);
		}
		return result;
	}
	
	private SObject readRecord(){
		String query = 'Select Id, ';
		for (IPhoneFieldDescription fieldDescription : textFields){
			query += fieldDescription.apiName + ', ';
		}
		query = query.removeEnd(', ') + ' From GNE_iPhone_Settings__c LIMIT 1';
		List<SObject> settings = Database.query(query);		
		if (!settings.isEmpty()){
			return settings[0];			
		} else {
			SObject newRecord = GNE_SFA2_Application_Cache.globalDescribe.get('GNE_iPhone_Settings__c').newSObject();
			for (IPhoneFieldDescription fieldDescription : textFields){
				newRecord.put(fieldDescription.apiName, null);
			}
   			insert newRecord;
    		return newRecord;
		}				
	}
		
	private String readText(){
		String result = null;
		for (IPhoneFieldDescription fieldDescription : textFields){						
			object recordValue = this.record.get(fieldDescription.apiName);
			String fieldValue = null;
			if (recordValue != null){
				fieldValue = (String)recordValue;
			}
			if (String.isNotBlank(fieldValue)){
				fieldValue = unWrapText(fieldValue);				
				if (result == null){
					result = fieldValue;
				} else {
					result += fieldValue;
				}
			} else {
				break;
			}
		}
		return result;		
	}
	
	private String wrapText(String textStr){
		String result = textStr;
		if (String.isNotBlank(result) && String.isNotBlank(this.textWrappingChar)){
			result = this.textWrappingChar + result + this.textWrappingChar; 
		}
		return result;
	}
	
	private String unWrapText(String textStr){
		String result = textStr;
		if (String.isNotBlank(result) && String.isNotBlank(this.textWrappingChar) &&
			result.startsWith(this.textWrappingChar) && result.endsWith(this.textWrappingChar)){
			result = result.removeStart(this.textWrappingChar).removeEnd(this.textWrappingChar);
		}
		return result;
	}
		
	public static IPhoneSettingsRecord getInstance(){
		if (instance == null){
			instance = new IPhoneSettingsRecord();
		}
		return instance;
	}
	
	public void save(){
		if (!this.hasErrors){
			try {	
				update this.record;
			} catch (Exception ex){
				this.record.addError(ex.getMessage());
			}
			refresh();
		}
	}
	
	public static void refresh(){
		dispose();		
		instance = new IPhoneSettingsRecord();
	}
	
	public static void dispose(){
		instance = null;
	}
	
	private class IPhoneFieldDescription{
		public Integer fieldSize { get; private set; }
		public String apiName { get; private set; }
		
		public IPhoneFieldDescription(String apiName){
			this.fieldSize =  GNE_SFA2_Application_Cache.describeObject('GNE_iPhone_Settings__c').fields.getMap().get(apiName).getDescribe().getLength();
			this.apiName = apiName;			
		}
	}
}