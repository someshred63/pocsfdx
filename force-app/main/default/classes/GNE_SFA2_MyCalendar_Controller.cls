/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-11-14
*  Description: This is a controller class for GNE_SFA2_MyCalendar
*  
*  Modification History
*  Date        Name        Description
*
*************************************************************/
public with sharing class GNE_SFA2_MyCalendar_Controller {
    
    public List<String> visibleFields { get; set; }
    public Boolean isAccountCalendar {get;set;}
    public Account account {get;set;}
    private SFA2_Configuration_Object_gne__c pageConfiguration;
        
    public GNE_SFA2_MyCalendar_Controller() {
           
           pageConfiguration = GNE_SFA2_Util.getListPageConfiguration('Calendar');     
           visibleFields = new List<String>{ 'Call_Datetime_vod__c, Entity_Display_Name_vod__c' };
                
           try{
               account = [Select Id from Account where Id =: ApexPages.currentPage().getParameters().get('Id') limit 1];
               isAccountCalendar = true;
           } catch (System.QueryException ex){
               isAccountCalendar = false;
           }
        
    }
    
    public String getListPageName() {
        String result;
        if(pageConfiguration != null) {
            result = pageConfiguration.Section_Header_gne__c;
        } else {
            result = '';
        }
        return result;
    }
  
    public String getActiveMenuItem() {
        String result = '';
        if(pageConfiguration != null && pageConfiguration.Attributes_gne__c!=null && pageConfiguration.Attributes_gne__c.contains('activeMenuItem')){
          result = pageConfiguration.Attributes_gne__c.substringBetween('activeMenuItem=',';');
        }
        return result;
    }
}