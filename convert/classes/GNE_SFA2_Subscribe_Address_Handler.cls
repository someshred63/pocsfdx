public with sharing class GNE_SFA2_Subscribe_Address_Handler extends CORE_Subscribe_Base implements CORE_Subscribe_Interface.Record_Handler{
	
	 public void handle(sObject sourceObject, sObject targetObject){
	 	 // Secondary address, Primary, Gold, Shipping and Billing etc. fields
	 	 Address_vod__c address = (Address_vod__c)targetObject; 
	 	 Boolean isNewAddress = address.Id == null;
	 	 CORE_Pub_Location__c ptyLoc = (CORE_Pub_Location__c)sourceObject;
	 	 
         Boolean isGold = isAddressOfGivenType('AMS_GOLD', ptyLoc);
         
		if(isGold || address.Address_line_2_vod__c == null) {  
            String addressLine = '';
            if (ptyLoc.Unit_Type_gne__c != null)     
                addressLine = ptyLoc.Unit_Type_gne__c;
            if (ptyLoc.Unit_Value_gne__c != null) {
                if (!String.isEmpty(addressLine)){ 
                    addressLine = addressLine + ' ' + ptyLoc.Unit_Value_gne__c;
                }else{
                    addressLine = ptyLoc.Unit_Value_gne__c;
                }
            }                                                                                       
            address.Address_line_2_vod__c= addressLine;
        }                                           
        if(isGold && isNewAddress){
            address.Primary_vod__c = TRUE;
        }
        if (isGold) {
            address.GOLD_RECORD_gne__c       = TRUE;
            address.AMS_gold_record_gne__c   = TRUE;
        } else {
            address.GOLD_RECORD_gne__c       = FALSE;
            address.AMS_gold_record_gne__c   = FALSE;
        }
        if (isNewAddress && isAddressOfGivenType('SHIP', ptyLoc)){
            address.Shipping_vod__c = TRUE;
        }
        if (isNewAddress && isAddressOfGivenType('MAIL', ptyLoc)){
            address.Mailing_vod__c = TRUE;
        }                               
        if (isNewAddress && isAddressOfGivenType('BILL', ptyLoc)){
            address.Billing_vod__c = TRUE;   
        }
        if (isNewAddress && isAddressOfGivenType('BUS', ptyLoc)){
            address.Business_vod__c = TRUE;                      
        }        
        if (isNewAddress && isAddressOfGivenType('OFC', ptyLoc)){
            address.Office_gne__c = TRUE;
        }    
        if (isNewAddress && isAddressOfGivenType('HOSP', ptyLoc)){
            address.Hospital_gne__c = TRUE;
        }
        
        if(!String.isEmpty(ptyLoc.Comm_Chan_json_gne__c)){
        	processCommunicationChannel(ptyLoc.Comm_Chan_json_gne__c, address, 'Address_vod__c.');
        }
       }
        
	 
	/**
    * Verifies if address is of a given usage type
    */
    private Boolean isAddressOfGivenType(String sUsageType, CORE_Pub_Location__c ptyLoc) {
    	if(String.isNotEmpty(ptyLoc.Loc_Use_json_gne__c)) {
            List<JsonList> wrappers = (List<JsonList>)JSON.deserialize(ptyLoc.Loc_Use_json_gne__c, List<JsonList>.class);
        	for(JsonList wrapper: wrappers){
        		if(sUsageType.equalsIgnoreCase(wrapper.code)){
                    return true;
                }
        	}
        }
        return false;
    }
    
    public class FieldHandler implements CORE_Subscribe_Interface.Field_Handler {
        
        public Object handle(sObject sourceObject, sObject targetObject, CORE_Subscribe_Field_Configuration_gne__c fc) {
            Object fieldValue = null;
            String fieldName = fc.Target_Field_gne__c;
            CORE_Pub_Location__c partyLocation = (CORE_Pub_Location__c)sourceObject;
            Address_vod__c address = (Address_vod__c)targetObject;
            if(fieldName == String.valueOf(Address_vod__c.MDM_Status_gne__c)) {
                fieldValue = sourceObject.get(fc.Source_Field_gne__c);
				if(fieldValue == 'A'){
					fieldValue = 'Active';
				}else{
					fieldValue = 'Inactive';
				}
            }             
            return fieldValue;
        }
    }
}