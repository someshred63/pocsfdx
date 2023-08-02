public class csvDownload {
    public List <PRP_Site__c> sites {get; set;}
    public string recid {get; set;}
 
    public   void csvDownload()
    {
        system.debug(ApexPages.currentPage().getParameters());
        recid=ApexPages.currentPage().getParameters().get('id'); 
         sites = new List<PRP_Site__c>();
        List<PRP_Site_Request__c> siteRequests = new List<PRP_Site_Request__c>();
        Set<Id> siteIds = new Set<Id>();
        siteRequests = [SELECT Id, Site__c FROM PRP_Site_Request__c WHERE Request__r.Id=:ApexPages.currentPage().getParameters().get('id')];
        if (siteRequests?.size() > 0) 
        {
            for (PRP_Site_Request__c psr:siteRequests) 
            {
                siteIds.add(psr.Site__c);
            }
            sites =[SELECT Name
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
            system.debug(sites);
        }
        
    }
}