public class GNE_SFA2_BrandAff_ResourceCenter_Cntllr
{   
    public Id brandAffId {get; set;} 
    public Product_metrics_vod__c brandAff { get; set; }
    public String AccountId{get;set;}
    public String envUrl{
        get{
          return Utilities.getGlobalVariable('BO_Server_Name');
        }
        private set;
    }
    public GNE_SFA2_BrandAff_ResourceCenter_Cntllr(ApexPages.StandardController controller)
    {
        if(ApexPages.currentPage().getParameters().get('id')!=null)
        {
            brandAffId = ApexPages.currentPage().getParameters().get('id');
            System.debug('KK..........'+brandAffId);
        }
        brandAff = [Select Id,Account_vod__c,Account_vod__r.Id,Account_vod__r.Speaker__c,Account_vod__r.MDMID_gne__c  from Product_metrics_vod__c where Id=:brandAffId ];
        System.debug('hi brandAff'+brandAff);
     }
     
}