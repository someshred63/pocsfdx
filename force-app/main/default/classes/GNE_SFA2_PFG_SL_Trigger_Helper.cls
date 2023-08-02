public with sharing class GNE_SFA2_PFG_SL_Trigger_Helper {
    
    public static final String APPROVAL_COMMENT;
    
    public static final String ERROR_PHONE_FORMAT_NOT_VALID;
    public static final String ERROR_CANNOT_CHANGE_USER;
    public static final String ERROR_FIELD_REQUIRED;
    
    public static final Set<String> SL_ADDRESS_FIELDS = new Set<String>{
                                        'ADDRESS_LINE_1_GNE__C',
                                        'ADDRESS_LINE_2_GNE__C',       
                                        'CITY_GNE__C',
                                        'STATE_GNE__C',
                                        'ZIP_GNE__C'};
    static {
        APPROVAL_COMMENT                = System.Label.GNE_SFA2_PFG_SL_Approval_Comment;
        ERROR_PHONE_FORMAT_NOT_VALID    = System.Label.GNE_SFA2_PFG_SL_Phone_Format_Not_Valid;
        ERROR_CANNOT_CHANGE_USER        = System.Label.GNE_SFA2_PFG_SL_Cannot_Change_User;
        ERROR_FIELD_REQUIRED            = System.Label.GNE_SFA2_PFG_SL_Field_Required;
    }
    
    private static Boolean inSLTrig = false;
    private static Set<Id> failedValidations = new Set<Id>();
    
    // static variable used to reduce the number of SOQL queries needed
    private static String currentUserProfileName = null;
    
    public static void setSLTrig(Boolean p_inSLTrig) {
        inSLTrig = p_inSLTrig;
    }
            
    public static Boolean inSLTrig()  {
        return inSLTrig;
    }
    
    public static void clearFailedValidations() {
        failedValidations.clear();
    }
    
    public static Set<Id> getFailedValidations() {
        return failedValidations;
    }
    
    public static void setFailedValidation(Id slID) {
        failedValidations.add(slID);
    }
    
    public static Boolean getFailedValidation(Id slID) {
        return failedValidations.contains(slID);
    }
    
    public static void removeFailedValidationRecords(List<SFA2_PFG_Storage_Location_gne__c> sls) {
        if(!sls.isEmpty()) {
            for(Integer i = sls.size()-1;i>=0;i--) {
                if(failedValidations.contains(sls[i].Id)) {
                    sls.remove(i);
                }
            }
        }
    }
    
    public static String getCurrentUserProfileName() {
        return GNE_SFA2_Util.getCurrentUserProfileName();
    }
}