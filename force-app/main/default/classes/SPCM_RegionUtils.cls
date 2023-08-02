public class SPCM_RegionUtils
{

    // method to handle before insert actions
    public static void HandleBeforeInsert(List<SPCM_Region__c> records)
    {
        
        // loop through records and update unique key
        for (SPCM_Region__c record : records)
        {
            record.Unique_Key__c = record.Name;
        }
    }
    
    // method to handle before update actions
    public static void HandleBeforeUpdate(List<SPCM_Region__c> records)
    {
    
        // loop through records and update unique key
        for (SPCM_Region__c record : records)
        {
            record.Unique_Key__c = record.Name;
        }
    }

    // test method for coverage
    public static testMethod void runTests()
    {
        
        // insert 200 regions
        List<SPCM_Region__c> regions = new List<SPCM_Region__c>();
        for (integer i = 0; i < 200; i++)
        {
            regions.add(new SPCM_Region__c(Name = 'Region' + i));
        }
        insert (regions);
        
        // retrieve ids
        Set<Id> regionIds = new Set<Id>();
        for(SPCM_Region__c region : regions)
        {
            regionIds.add(region.Id);
        }
        
        // run assertions
        regions = [SELECT Id, Name, Unique_Key__c FROM SPCM_Region__c WHERE Id IN :regionIds];
        for (SPCM_Region__c region : regions)
        {
            System.assertEquals(region.Name, region.Unique_Key__c);
        }
        
        // update 200 records
        for (integer i = 0; i < 200; i++)
        {
            regions[i].Name = 'Region_Updated' + i;
        }
        update (regions);
        
        // run assertions
        regions = [SELECT Id, Name, Unique_Key__c FROM SPCM_Region__c WHERE Id IN :regionIds];
        System.assertEquals(regions.size(), 200);
        for (SPCM_Region__c region : regions)
        {
            System.assertEquals(region.Name, region.Unique_Key__c);
        }
    }
}