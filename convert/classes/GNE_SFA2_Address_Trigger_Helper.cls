/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-08-07
*  Description: This is a helper class for GNE_SFA2_Address_Trigger
*  Test class: GNE_SFA2_Address_Trigger_Test
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/

public with sharing class GNE_SFA2_Address_Trigger_Helper {
    
    private static Set<Id> setAddrDel = new Set<Id> ();
    private static Set<Id> addrSetFalse = new Set<Id>();
    private static Boolean isChildAcct = false;
    private static Boolean isPush = false;
    private static Boolean inAddressTrig = false;
    private static Set<Id> failedValidations = new Set<Id>();
    private static Boolean isValidationDisabled = false;
    
    public static void addDelSet (String id) {
        setAddrDel.add(id);
    }
    
    public static Set<Id> getDelSet () {
        return setAddrDel;  
    }
    
    public static void addCopySetFalse (String id) {
        addrSetFalse.add(id);
    }
           
    public static Boolean isCopySetFalse (String id) {
        return addrSetFalse.contains(id);  
    }
           
    public static void setChildAccount (Boolean p_isChildAcct) {
        isChildAcct = p_isChildAcct;
    }
            
    public static Boolean getChildAccount () {
        return isChildAcct;
    }
    
    
    public static void setAddressTrig (Boolean p_inAddressTrig) {
        inAddressTrig = p_inAddressTrig;
    }
            
    public static Boolean inAddressTrig ()  {
        return inAddressTrig;
    }
    
    public static boolean userHasCanadianProfile(){
        return GNE_SFA2_Util.isCanadaUser();
    }      
    
    public static void clearFailedValidations() {
        failedValidations.clear();
    }
    
    public static Set<Id> getFailedValidations() {
        return failedValidations;
    }
    
    public static void setFailedValidation(Id addrID) {
        failedValidations.add(addrID);
    }
    
    public static Boolean getFailedValidation(Id addrID) {
        return failedValidations.contains(addrID);
    }
    
    public static void removeFailedValidationRecords(List<Address_vod__c> addr) {
        if(!addr.isEmpty()) {
            for(Integer i = addr.size()-1;i>=0;i--) {
                if(failedValidations.contains(addr[i].Id)) {
                    addr.remove(i);
                }
            }
        }
    }
    
    public static Boolean isValidationDisabled() {
      return isValidationDisabled==true;
    }
    
    public static void setValidationDisabled(Boolean disabled) {
      isValidationDisabled=disabled;
    }
    
    public static Set<String> getInfoServiceTrackedFields() {
        return new Set<String>{
            String.valueOf(Address_vod__c.Name),
			String.valueOf(Address_vod__c.Account_vod__c),
			String.valueOf(Address_vod__c.Address_line_2_vod__c),
			String.valueOf(Address_vod__c.City_vod__c),
			String.valueOf(Address_vod__c.State_vod__c),
			String.valueOf(Address_vod__c.Zip_vod__c),
			String.valueOf(Address_vod__c.Zip_4_vod__c),
			String.valueOf(Address_vod__c.Phone_vod__c),
			String.valueOf(Address_vod__c.Fax_vod__c),
			String.valueOf(Address_vod__c.Email_gne__c),
			String.valueOf(Address_vod__c.Primary_vod__c),
			String.valueOf(Address_vod__c.DEA_vod__c),
			String.valueOf(Address_vod__c.DEA_Status_vod__c),
			String.valueOf(Address_vod__c.DEA_Expiration_Date_vod__c),
			String.valueOf(Address_vod__c.License_vod__c),
			String.valueOf(Address_vod__c.License_Expiration_Date_vod__c),
			String.valueOf(Address_vod__c.License_Status_vod__c),
			String.valueOf(Address_vod__c.Designation_gne__c)
        };
    }
    
    public static Set<String> getIPhoneTrackedFields() {
        return new Set<String>{
            String.valueOf(Address_vod__c.Name),
			String.valueOf(Address_vod__c.Account_vod__c),
			String.valueOf(Address_vod__c.Primary_vod__c),
			String.valueOf(Address_vod__c.Address_line_2_vod__c),
			String.valueOf(Address_vod__c.City_vod__c),
			String.valueOf(Address_vod__c.State_vod__c),
			String.valueOf(Address_vod__c.Zip_vod__c),
			String.valueOf(Address_vod__c.Zip_4_vod__c),
			String.valueOf(Address_vod__c.Phone_vod__c),
			String.valueOf(Address_vod__c.Phone_1_Ext_gne__c),
			String.valueOf(Address_vod__c.Phone_2_vod__c),
			String.valueOf(Address_vod__c.Phone_2_Ext_gne__c),
			String.valueOf(Address_vod__c.Fax_vod__c),
			String.valueOf(Address_vod__c.Fax_2_vod__c),
			String.valueOf(Address_vod__c.License_vod__c),
			String.valueOf(Address_vod__c.License_Expiration_Date_vod__c),
			String.valueOf(Address_vod__c.License_Status_vod__c),
			String.valueOf(Address_vod__c.License_Valid_To_Sample_vod__c),
			String.valueOf(Address_vod__c.Province_can_gne__c),
			String.valueOf(Address_vod__c.Postal_Code_can_gne__c),
			String.valueOf(Address_vod__c.Org_Name_can_gne__c),
			String.valueOf(Address_vod__c.PFG_BDTD_gne__c),
			String.valueOf(Address_vod__c.Location_gne__Latitude__s),
			String.valueOf(Address_vod__c.Location_gne__Longitude__s),
			String.valueOf(Address_vod__c.MDM_Status_gne__c),
			String.valueOf(Address_vod__c.MDM_Address_ID_gne__c),
			String.valueOf(Address_vod__c.RecordTypeId),
            String.valueOf(Address_vod__c.Business_Name_gne__c),
            String.valueOf(Address_vod__c.Business_Address_Type_gne__c),
            String.valueOf(Address_vod__c.Changed_Address_gne__c)
        };
    }
}