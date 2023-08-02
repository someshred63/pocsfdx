public with sharing class GNE_SFA2_RCanada_DCR_Notification_Ctrl {

	public String dcrId {get; set;}
    public String dcrName {get; set;}

    
    public String getDcrUrl() {
        return Url.getSalesforceBaseUrl().toExternalForm() + '/apex/GNE_SFA2_DCR_Layout?id=' + dcrId;
    }    
}