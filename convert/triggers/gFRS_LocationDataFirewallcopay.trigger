trigger gFRS_LocationDataFirewallcopay on GFRS_Location_Copay__c (before insert, before update) {
gFRS_Utilcopay.locationDataFirewall(Trigger.new, Trigger.oldMap);
}