@isTest
private class iPhone_FindEcoSystemsTest {
    @testSetup
    static void testData() {
        List<Ecosystem_Details_gne__c> ecoSystems = new List<Ecosystem_Details_gne__c> ();
        ecoSystems.add(new Ecosystem_Details_gne__c(ECO_CD_gne__c='E01', ECO_City_gne__c='CARLISLE', ECO_Name_gne__c='PENNSYLVANIA', ECO_State_gne__c='PA', ECO_ZIP_Code_gne__c='17015'));
        ecoSystems.add(new Ecosystem_Details_gne__c(ECO_CD_gne__c='E01', ECO_City_gne__c='CORNWALL', ECO_Name_gne__c='PENNSYLVANIA', ECO_State_gne__c='PA', ECO_ZIP_Code_gne__c='17016'));
        ecoSystems.add(new Ecosystem_Details_gne__c(ECO_CD_gne__c='E01', ECO_City_gne__c='DALMATIA',  ECO_Name_gne__c='PENNSYLVANIA', ECO_State_gne__c='PA', ECO_ZIP_Code_gne__c='17017'));
        ecoSystems.add(new Ecosystem_Details_gne__c(ECO_CD_gne__c='E01', ECO_City_gne__c='DAUPHIN', ECO_Name_gne__c='PENNSYLVANIA', ECO_State_gne__c='PA', ECO_ZIP_Code_gne__c='17018'));
        ecoSystems.add(new Ecosystem_Details_gne__c(ECO_CD_gne__c='E01', ECO_City_gne__c='DILLSBURG', ECO_Name_gne__c='PENNSYLVANIA', ECO_State_gne__c='PA', ECO_ZIP_Code_gne__c='17019'));
        
        Database.insert(ecoSystems, false);
        //expecting 5 records, we do not want duplicates
        System.assertEquals(5, [Select count() FROM Ecosystem_Details_gne__c], 'Records number should equals to 5');
        
    }
    
    @isTest
    static void  correctInputFor_0_record() {
        String httpRequestBody = '{"ecoCode":"E01","city":"PHILADELPHIA","recordLimit": 1,"state" : "PA","ecoName" :"PENNSYLVANIA"}';
        iPhone_FindEcoSystems.EcoSystemPattern request = (iPhone_FindEcoSystems.EcoSystemPattern) JSON.deserialize(httpRequestBody,iPhone_FindEcoSystems.EcoSystemPattern.class);

        iPhone_FindEcoSystems.RecordsResponse resp = (iPhone_FindEcoSystems.RecordsResponse)iPhone_FindEcoSystems.processPostRequest(request);
        
        System.assertEquals(0, resp.result.size());        
    }
    
    @isTest 
    static void CorrectInputFor_1_record() {
        String httpRequestBody = '{"ecoCode":"E01","city":"DILLSBURG","recordLimit": 100,"state" : "PA","ecoName" :"PENNSYLVANIA"}';
        iPhone_FindEcoSystems.EcoSystemPattern request = (iPhone_FindEcoSystems.EcoSystemPattern) JSON.deserialize(httpRequestBody,iPhone_FindEcoSystems.EcoSystemPattern.class);

        iPhone_FindEcoSystems.RecordsResponse resp = (iPhone_FindEcoSystems.RecordsResponse)iPhone_FindEcoSystems.processPostRequest(request);
        
        System.assertEquals(1, resp.result.size());     
    }
    
    @isTest 
    static void CorrectInputFor_5_records() {
        String httpRequestBody = '{"ecoCode":"E01"}';
        iPhone_FindEcoSystems.EcoSystemPattern request = (iPhone_FindEcoSystems.EcoSystemPattern) JSON.deserialize(httpRequestBody,iPhone_FindEcoSystems.EcoSystemPattern.class);

        iPhone_FindEcoSystems.RecordsResponse resp = (iPhone_FindEcoSystems.RecordsResponse)iPhone_FindEcoSystems.processPostRequest(request);
        
        System.assertEquals(5, resp.result.size());     
    }

}