public with sharing class AGS_EX_Exclusion_Req_List_Controller {
    
    public String listViewId { get; set; }
    
    public AGS_EX_Exclusion_Req_List_Controller() {
        listViewId = AGS_EX_Exclusion_Utils.getListViewId('AGS_EX_Exclusion_Request_gne__c', 'Pending Exclusion Requests');
    }
}