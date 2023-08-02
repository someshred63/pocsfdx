public with sharing class GNE_SFA2_ViewRHController {
  
  public Integer physycianCount {get; set;}
  
  public GNE_SFA2_ViewRHController()
  {
    String accountId = ApexPages.currentPage().getParameters().get('id');
    String QString = 'Select id from Affiliation_vod__c where From_Account_vod__c =\''+accountId+'\' and To_Account_vod__r.RecordTypeId = \'0127000000015UoAAI\' and To_Account_vod__r.Credentials_gne__c includes (\'MD;DO\',\'MD\',\'DO\')';
    physycianCount = (Database.query(QString)).size();
  }

}