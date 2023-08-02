@isTest
private class ART_Issue_Test 
{
    static testMethod void CreatedDateTest() 
    {
		ART_Site_gne__c site = new ART_Site_gne__c();
		site.Name = 'siteTestName';
		insert site;
		ART_Issue_gne__c art = new ART_Issue_gne__c();
		art.ART_Site_Local_gne__c = site.Id;
		insert art;
		ART_Issue_gne__c arts = [select id, Created_Date_gne__c, CreatedDate from ART_Issue_gne__c where id = :art.Id limit 1];
		System.assert(arts <> null);
		System.assert(arts.CreatedDate <> null);
		System.assert(arts.Created_Date_gne__c <> null);
		System.assertEquals(arts.CreatedDate, arts.Created_Date_gne__c);
    }
}