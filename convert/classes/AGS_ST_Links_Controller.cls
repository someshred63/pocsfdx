public without sharing class AGS_ST_Links_Controller
{
    public String recordId {get;set;}
    public String recordName {get;set;}
    public String target_url {
        get {
            AGS_ST_DisputeManagement_gne__c dispute = [select Name from AGS_ST_DisputeManagement_gne__c where Id = :recordId];
            recordName = dispute.Name;
            return AGS_ST_Utils.getDefaultCustomSettings().Domain_gne__c + '/' + recordId;
        }
        set;
    }
}