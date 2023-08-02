public without sharing class GFRS_Ltng_ChangefocussubfocusModal {
    
    private static List <Map<String,String>> getPickListValues(String objApiName, String fieldName,List<String> picklistval) {
        List <Map<String,String>> options = new List < Map < String, String >>();
        Map<String,Schema.SObjectType> objGlobalMap = Schema.getGlobalDescribe();
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objApiName);
        if (objType == null) {
            return options;
        }
        Schema.DescribeSObjectResult sobjectDescribe = objType.getDescribe();
        Map<String,Schema.SObjectField> fieldMap = sobjectDescribe.fields.getMap();
        if (fieldMap.get(fieldName) == null) {
            return options;
        }
        List <Schema.PicklistEntry> pickListValues = fieldMap.get(fieldName).getDescribe().getPickListValues();
        Map<String,String> valuesofallpicklist = new  Map<String,String>();
        for (Schema.PicklistEntry f: pickListValues) {
            valuesofallpicklist.put(f.getValue(),f.getLabel());                           
        }
        for(String ss : picklistval){
            Map<String,String> valuesmapfinal = new  Map<String,String>();
            valuesmapfinal.put('label',valuesofallpicklist.get(ss));
            valuesmapfinal.put('value',ss);
            options.add(valuesmapfinal);   
        }
        System.debug('options:::'+options);
        return options;
    }
    
    @AuraEnabled
    public static List<Map<String,String>> getPickListValuesbyrecordtype(String recordtypeName) { 
        try{
            String picklistval=[SELECT Id,Long_Text_Field__c FROM gFRS_Configuration__mdt WHERE DeveloperName='gFRS_ApplicationRecordtypeWithPicklist' LIMIT 1]?.Long_Text_Field__c;
            List<Map<String,String>> fetchpicklistvalue=new List<Map<String,String>>();
            Id fetchrecordtypeId= Schema.getGlobalDescribe().get('gFRS_Ltng_Application__c').getDescribe().getRecordTypeInfosByDeveloperName().get(recordtypeName).getRecordTypeId();
            if(String.isNotBlank(fetchrecordtypeId) && String.isNotBlank(picklistval)){
                Map<String,Object> picklistmap=(Map<String,Object>)JSON.deserializeUntyped(picklistval);
                System.debug('picklistmap:::'+String.valueof(picklistmap.get(recordtypeName)).split(','));
                fetchpicklistvalue=getPickListValues('gFRS_Ltng_Application__c','Focus_Area__c',String.valueof(picklistmap.get(recordtypeName)).split(','));
            }
            system.debug('fetchpicklistvalue:::'+fetchpicklistvalue);
            return fetchpicklistvalue;          
        }
        Catch(Exception Ex){
            throw new AurahandledException(Ex.getMessage()+' Line Number:::'+Ex.getLineNumber());
        }   
        
    }
    
    @AuraEnabled
    public static String saverecord(String recordId,String selectedpickval) {
        List<gFRS_Ltng_Program__c> programlistupdate=new List<gFRS_Ltng_Program__c>();
        String returnresult='';
        if(String.isNotBlank(recordId) && String.isNotBlank(selectedpickval)){
            try{
                gFRS_Ltng_Application__c updateapplication=new gFRS_Ltng_Application__c(Id=recordId,Focus_Area__c=selectedpickval);
                List<gFRS_Ltng_Program__c> programlist=[SELECT Id,gFRS_Focus_Area__c,gFRS_Sub_Focus_Area__c FROM gFRS_Ltng_Program__c WHERE gFRS_Application__c=:recordId];
                if(programlist!=null && programlist.size() > 0){
                    for(gFRS_Ltng_Program__c program : programlist){
                        program.gFRS_Focus_Area__c=selectedpickval;
                        program.gFRS_Sub_Focus_Area__c=null;
                        programlistupdate.add(program);
                    }
                }
                update updateapplication;
                if(programlistupdate!=null && !programlistupdate.IsEmpty()){
                    update programlistupdate;
                }
                returnresult='Success';
            } 
            Catch(Exception Ex){
                returnresult=Ex.getMessage()+' Line Number:::'+Ex.getLineNumber();
                throw new AurahandledException(Ex.getMessage()+' Line Number:::'+Ex.getLineNumber());
            }   
        } 
        return returnresult;
    }
    
    
    
}