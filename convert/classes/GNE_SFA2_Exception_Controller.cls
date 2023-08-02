public with sharing class GNE_SFA2_Exception_Controller {
    public String appName {get; private set;}
    public String exMessage {get; set;}
    public String unixId {get; set;}
    public Datetime currentDate {get; set;}
    public String developerMessage {get; set;}
    public String exUrl {get; set;}
    public Boolean insufficientAccess {get;set;}
    
    public GNE_SFA2_Exception_Controller(){
        insufficientAccess = false;
        GNE_SFA2_User_App_Context_gne__c userApplicationContext = GNE_SFA2_Util.getUserApplicationContext();
        appName = '';
        if (userApplicationContext != null){
        	if (!String.isBlank(userApplicationContext.App_Name_gne__c)){
        		appName += userApplicationContext.App_Name_gne__c + ' ';     	
        	}
        	if (!String.isBlank(userApplicationContext.Brand_gne__c)){
        		appName += userApplicationContext.Brand_gne__c + ' ';	
        	}
        	if (!String.isBlank(userApplicationContext.Role_gne__c)){
        		appName += userApplicationContext.Role_gne__c;
        	}
        	if (!String.isBlank(appName)){
        		appName = appName.trim();
        	}
        }
        exMessage = ApexPages.currentPage().getParameters().get('exMessage');
        developerMessage = Apexpages.currentPage().getParameters().get('developerMessage');
        unixId = getUnixId();
        currentDate = Datetime.now();
        exUrl = ApexPages.currentPage().getParameters().get('exUrl');
        if (developerMessage!=null && developerMessage!= '' && (developerMessage.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') || developerMessage.contains('You do not have the level of access necessary ')||developerMessage.contains('INSUFFICIENT_ACCESS'))){
            insufficientAccess = true;
        }
    }
    
    private String getUnixId(){
        List<User> users = [SELECT Username FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        String unixId = users[0].Username.Substring(0, users[0].Username.indexOf('@'));
        return unixId;
    }
}