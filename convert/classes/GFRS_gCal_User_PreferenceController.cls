public with sharing class GFRS_gCal_User_PreferenceController {
    
	private final UnifiedCalendarUserEventPreference_gne__c imedEventPreference;
    private final ApexPages.StandardController standardController;
    private final String IMED_EVENT_TYPE;
    
    public Boolean SaveButtonRender{get; set;}
   
    public GFRS_gCal_User_PreferenceController(ApexPages.StandardController controller)
    {
        IMED_EVENT_TYPE                                 = 'IMED';
        standardController                              = (ApexPages.StandardController) controller;       
        imedEventPreference                             = (UnifiedCalendarUserEventPreference_gne__c) controller.getRecord();
        imedEventPreference.Event_Type__c               = IMED_EVENT_TYPE;
        List<UnifiedCalendar_gne__c> tmpUnifiedCalendar = [select Secondary_Calendar_ID__c from UnifiedCalendar_gne__c  where User_Unified_Calendar__c = :Userinfo.getUserId() and Secondary_Calendar_Name__c = 'My gFRS Live Events' limit 1 ];

        if(tmpUnifiedCalendar != null && tmpUnifiedCalendar.size()>0){
        	imedEventPreference.secondary_calendar_id__c =	tmpUnifiedCalendar[0].Secondary_Calendar_ID__c;
        }else{
        	imedEventPreference.secondary_calendar_id__c=null;
        }
         
        SaveButtonRender=true;
        
        if(imedEventPreference.secondary_calendar_id__c==null)
        {
           ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Your Secondary Calendar for gFRS has not yet been setup. Please call the Service Desk to setup your gFRS calendar.' ));
           //imedEventPreference.addError('No definded gCalendar ID');
           SaveButtonRender=false;
        }
    }
    
    public PageReference init()
    {
        PageReference retPage = null;
        String currentUser    = UserInfo.getUserId();

        //Check if any preference record, associated to a user, exists in database.         
        List <UnifiedCalendarUserEventPreference_gne__c> imedEvent = 
                [SELECT id FROM UnifiedCalendarUserEventPreference_gne__c 
                     WHERE CreatedById = :currentUser AND Event_Type__c = :IMED_EVENT_TYPE];   
        
     
         
        //If yes, then open the page for this record.        
        if (imedEventPreference.Id == null && imedEvent.size() == 1)
        {
            retPage = new PageReference('/apex/UserImedEventPreferences?id='+imedEvent[0].id);
            retPage.setRedirect(true);
        }                                   
 
        //If retPage == null, then refresh
        //else load the provided page
        return retPage;        
    }
    
    public PageReference initCustom()
    {
        PageReference retPage = null;
        String currentUser    = UserInfo.getUserId();

        //Check if any preference record, associated to a user, exists in database.         
        List <UnifiedCalendarUserEventPreference_gne__c> imedEvent = 
                [SELECT id FROM UnifiedCalendarUserEventPreference_gne__c 
                     WHERE CreatedById = :currentUser AND Event_Type__c = :IMED_EVENT_TYPE];   
        
     
         
        //If yes, then open the page for this record.        
        if (imedEventPreference.Id == null && imedEvent.size() == 1)
        {
            retPage = new PageReference('/apex/GFRS_gCal_User_Preference?id='+imedEvent[0].id);
            retPage.setRedirect(true);
        }                                   
 
        //If retPage == null, then refresh
        //else load the provided page
        return retPage;        
    }
    
    public PageReference save()
    {                     
        String currentUser    = UserInfo.getUserId();
        PageReference retPage = null;
        // Get the latest preferences the user has saved before, in case if he/she coincidentally 
        // opened another window and was creating it while this page was still up
        List <UnifiedCalendarUserEventPreference_gne__c> imedEvent = [SELECT id FROM UnifiedCalendarUserEventPreference_gne__c 
             WHERE CreatedById = :currentUser AND Event_Type__c = :IMED_EVENT_TYPE];
        if(imedEvent != null && imedEvent.size() > 0 && imedEvent[0].id <> imedEventPreference.id)
        {
            // delete existing preferences
            delete imedEvent;
        }
        
        try
        {   
        	Boolean validationError =false;
        	if(imedEventPreference.St__c == null){
        		ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'States: You must enter a value' ));
        		validationError=true;
        	}
        	if(imedEventPreference.Therapeutic_Areas__c == null){
        		ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Disease States: You must enter a value' ));
        		validationError=true;
        	}
        	if(validationError) return null;              
            retPage = standardController.save();
        }
        catch(DmlException DmlEx)
        {
          System.Debug('Dml Error! '+ DmlEx.getMessage());     
          throw DmlEx;
        }
        
        retPage = new PageReference('/apex/GFRS_gCal_User_Preference_Confirm');
        return retPage;      
    }
}