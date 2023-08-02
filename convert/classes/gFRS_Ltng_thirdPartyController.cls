/**
* The gFRS_Ltng_reqDetailsController class contains code responsible for handling the events related
* to gFRS_Ltng_requestDeatils Lightning component
* 
* @author Veera Mylavarapu
* @see Lightning component: gFRS_Ltng_thiirdPartyDeatils
*/
public class gFRS_Ltng_thirdPartyController {
    
    
    /**
* This method calls the service layer to get the third party record
*
* @param third party lst
* @return third party lst
*/
    @AuraEnabled
    public static List<gFRS_Ltng_Third_Party__c> saveThirdParty(List<gFRS_Ltng_Third_Party__c> thPartyReclst){
        
        return gFRS_Ltng_ThirdPartyService.createthirdParty(thPartyReclst);
    }
    
    
    
    /**
* This method calls the service layer to get the transaction record
*
* @param gfRS Application record id
* @return third party list
*/
    @AuraEnabled
    public static List<gFRS_Ltng_Third_Party__c> getThirdParty(String gFRSAppId){
        
        return gFRS_Ltng_ThirdPartyService.getthirdParties(gFRSAppId);
    }
    
    /**
* This method calls the service layer to update the third party record
*
* @param third party list
* @return third party list
*/
    @AuraEnabled
    public static string updateAppDtls(String objAPIName){
        system.debug('objAPIName'+objAPIName);
        gFRS_Ltng_Application__c gFRSApp=new gFRS_Ltng_Application__c();
        gFRSApp.Id=objAPIName;
        gFRSApp.Selected_Tab_Val__c='prgInfo';
        update gFRSApp;
        return gFRSApp.Id;
    }    
    @AuraEnabled
    public static void updateThirdParty(List<gFRS_Ltng_Third_Party__c> thPartyReclst){
        
        gFRS_Ltng_ThirdPartyService.updatethirdParty(thPartyReclst);
    }
    
    /**
* This method calls the service layer to delete the third party record
*
* @param third party list
* @return No Return
*/
    @AuraEnabled
    public static void deleteThirdParty(List<gFRS_Ltng_Third_Party__c> thPartyReclst){
        
        gFRS_Ltng_ThirdPartyService.delthirdParty(thPartyReclst);
    }
    
    
    
    
    
    
    /**
* This method calls the meta data to get picklist values 
*
* @param String,String
* @return Picklistwrapper 
*/
    
    @AuraEnabled  
    public static List<picklistWrapper> getPicklistvalues(string objAPIName, string fieldAPIname) {
        list<picklistWrapper> returnValue = new list<picklistWrapper>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        // Get the object type of the SObject.
        Schema.sObjectType objType = schemaMap.get(objAPIName);
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        // Get a map of fields for the SObject
        map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
        // Get the list of picklist values for this field.
        list < Schema.PicklistEntry > values = fieldMap.get(fieldAPIname).getDescribe().getPickListValues();
        
        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a: values) {
            picklistWrapper aa = new picklistWrapper();
            aa.pickListLabel = a.getLabel();
            aa.pickListValue = a.getValue();
            returnValue.add(aa);
        }
        system.debug('*****returnValue'+returnValue);
        return returnValue;   
    }    
    
    public class picklistWrapper{
        @AuraEnabled 
        public string pickListLabel;
        @AuraEnabled 
        public string pickListValue;
        
    }
}