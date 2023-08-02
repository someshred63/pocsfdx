/**
* @File Name:   PRP_bemcntrlr
* @Description: Controller for PRP_BEMCreationScreen Aura component.
				While creating BEM, check if the user is active or not based on the Unix id if not; (activate) the User and create BEM record.
* @group:       Apex Class
* @Author:     Rabindranath
* @Modification Log  :
______________________________________________________________________________________
* Ver       Date         Modification
* 1.0       2022-06-23   Created the Component
**/
public class PRP_bemcntrlr {
    @AuraEnabled
    public static List < String > getselectOptions(sObject objObject, string fld) {
        system.debug('objObject --->' + objObject);
        system.debug('fld --->' + fld);
        List < String > allOpts = new list < String > ();
        // Get the object type of the SObject.
        Schema.sObjectType objType = objObject.getSObjectType();
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
        list < Schema.PicklistEntry > values =
            fieldMap.get(fld).getDescribe().getPickListValues();
        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a: values) {
            allOpts.add(a.getValue());
        }
        system.debug('allOpts ---->' + allOpts);
        allOpts.sort();
        return allOpts;
        
    }
    @AuraEnabled
    public static Id createBEMRecs(String name,String unixid,String region,Boolean active,List<String> ecosystem) {
        PRP_BEM__c bem = new PRP_BEM__c();
        User usr =[Select id,External_ID_gne__c,IsActive,Email,Phone, Name from User where External_ID_gne__c =:unixid];
        if(usr.External_ID_gne__c!=null){
            updateusr(unixid);
            
            try{
                bem.User__c = usr.Id;
                bem.Email__c = usr.Email;
                bem.Phone__c = usr.Phone;
                bem.Name =name;
                bem.Unix_Id__c= unixid;
                bem.Region__c = region;
                bem.Is_Active__c = active;
                bem.Ecosystem__c = format (ecosystem);
                upsert bem;
            }
            
            catch (DmlException ex) {
                throw new AurahandledException(ex.getDmlMessage(0));
            } catch (Exception ex) {
                throw new AurahandledException(ex.getMessage());
            }
        }
        return bem.Id;
    }
    public static String format(List<String> values) {
        if (values == null) return null;
        return String.join(values, ';');
    }
    //This method is seperated to avoid Mixed DML exception.
    @future
    public static void updateusr(String unixid){
        User u =[Select id,External_ID_gne__c,IsActive from User where External_ID_gne__c =:unixid];
        if(!u.IsActive){
            u.IsActive =true;
            update u;        
        }
    }
}