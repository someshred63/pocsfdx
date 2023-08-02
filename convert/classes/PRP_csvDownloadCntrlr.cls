public class PRP_csvDownloadCntrlr {
    @AuraEnabled(Cacheable = true)
    public static List<PRP_Site__c> getSitesInfo(String prpid)
    {
        Set<Id> siteIds = new Set<Id>();
        List<PRP_Site__c> sites = new List<PRP_Site__c>();
        List<PRP_Site_Request__c> siteRequests = new List<PRP_Site_Request__c>();
        siteRequests = [SELECT Id, Site__c FROM PRP_Site_Request__c WHERE Request__r.Id=:prpid];

        if (siteRequests?.size() > 0) 
        {
            for (PRP_Site_Request__c psr:siteRequests) 
            {
                siteIds.add(psr.Site__c);
            }

            sites = 
            [
                SELECT Name
                      ,Address1__c
                      ,Address2__c
                      ,City__c
                      ,State__c
                      ,Zip__c
                      ,ProductFormula__c
                      ,Site_Type__c
                      ,Status__c
                      ,HIN_Number__c
                	  ,Other_ID__c
                      ,Distributor_Number__c
                      ,DEA_Number__c
                      ,Prospective_Termination_Date__c 
                  FROM PRP_Site__c 
                 WHERE Id IN :siteIds
            ];
        }
        
        return sites;
    }
}