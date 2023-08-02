public with sharing class GNE_CM_NewRelicComponentController {
	public Boolean active {get; set;}
	public String applicationId {get; set;}
	public String beacon {get; set;}
	public String errorBeacon {get; set;}
	public String licenseKey {get; set;}
    public String sa {get; set;}
    
    public GNE_CM_NewRelicComponentController() {
    	String environmentName = GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG).Environment_Name__c;
    	if (!String.isBlank(environmentName)) {
	    	List<New_Relic_Configuration__mdt> instances = [SELECT DeveloperName, active__c, applicationId__c, beacon__c, errorBeacon__c, licenseKey__c, sa__c FROM New_Relic_Configuration__mdt WHERE (MasterLabel = :environmentName.toUpperCase())];
	    	if (!instances.isEmpty()) {
				this.active = instances.get(0).active__c;
	    		this.applicationId = instances.get(0).applicationId__c;
	    		this.beacon = instances.get(0).beacon__c;
	    		this.errorBeacon = instances.get(0).errorBeacon__c;
	    		this.licenseKey = instances.get(0).licenseKey__c;
	    		this.sa = instances.get(0).sa__c;
	    	}
    	}		
    }
}