/****************************************************************************************
 *  @author: Adam Bebenek, Roche ADMD
 *  Date: 10-March-2010 
 *  Description: Create or edit IMED Events Calendar Preferences associated to the user. 
 *                          
 *  Modification History
 *  Date        Name        Description
 *  7/21/2011   Michal Gajewski - created on DEV           
 ****************************************************************************************/
 
public class ImedEventsExtension
{
    private final UnifiedCalendarUserEventPreference_gne__c imedEventPreference;
    private final ApexPages.StandardController standardController;
    private final String IMED_EVENT_TYPE;
    
    public boolean SaveButtonRender{get; set;}
   
    public ImedEventsExtension(ApexPages.StandardController controller)
    {
        IMED_EVENT_TYPE = 'IMED';
        standardController = (ApexPages.StandardController) controller;       
        imedEventPreference = (UnifiedCalendarUserEventPreference_gne__c) controller.getRecord();
        imedEventPreference.Event_Type__c = IMED_EVENT_TYPE;
        imedEventPreference.secondary_calendar_id__c = [select Secondary_gCal_ID_gne__c from User u where u.id = :Userinfo.getUserId()].Secondary_gCal_ID_gne__c;
        SaveButtonRender=true;
        
        if(imedEventPreference.secondary_calendar_id__c==null)
        {
           imedEventPreference.addError('No definded gCalendar ID');
           SaveButtonRender=false;
        }
    }
    
    public PageReference init()
    {
        PageReference retPage = null;
        String currentUser = UserInfo.getUserId();

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
    
    public PageReference save()
    {                     
        String currentUser = UserInfo.getUserId();
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
            retPage = standardController.save();
        }
        catch(DmlException DmlEx)
        {
          System.Debug('Dml Error! '+ DmlEx.getMessage());     
          throw DmlEx;
        }
        
        retPage = new PageReference('/apex/UserImedEventPreferencesConfirmClose');
        return retPage;      
    }
}