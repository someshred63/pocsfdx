/*
* @author ADMD GFRS Dev Team
* @date 08/22/2013
* @description Mass update organization records. All us-based org must have US_Organization__c picklist set to 'Yes'
*/
global with  sharing class gFRS_UpdateOrgUsBasedBatch implements Database.Batchable<sObject>
 { 
    global Database.Querylocator start(Database.BatchableContext BC)
    {
        string query= 'select id, US_Organization__c,Tax_Status__c, Country__c from GFRS_Organization__c';        
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
     
      List<GFRS_Organization__c> itempsToUpdate=new List<GFRS_Organization__c>();
      GFRS_OrgSettings__c myGFRSOrgSettings = GFRS_OrgSettings__c.getOrgDefaults();
      string strlistUSBasedCountries = myGFRSOrgSettings.USBasedOrganizations__c;
      
      try
      {
        for(GFRS_Organization__c org : (List<GFRS_Organization__c>)scope)
        {
          if(strlistUSBasedCountries.contains(org.Country__c))
          {
              org.US_Organization__c='Yes';
          }
          else
          {
              org.US_Organization__c='No';
          }
          itempsToUpdate.add(org);                       
        }
        
        if(itempsToUpdate.size()>0){update itempsToUpdate;}
      }
      catch(Exception ex)
      {
        system.debug('probelms were occured: '+ex.getMessage());
        system.debug(ex);
      }
       
    }
    
    global void finish(Database.BatchableContext BC)
    {
        system.debug('execution ended successfully');
    }
}