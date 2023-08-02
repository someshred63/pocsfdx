@isTest
private class GNE_Zip2TerritoryTriggerTest {
    @testSetup
    static void testData() { 
        USPS_Address_gne__c add = new USPS_Address_gne__c(City_gne__c = 'XXXX', State_gne__c ='CA', Zip_gne__c ='00000');
        USPS_Address_gne__c add1 = new USPS_Address_gne__c(City_gne__c = 'YYYY', State_gne__c ='SA', Zip_gne__c ='00001');
        USPS_Address_gne__c add2 = new USPS_Address_gne__c(City_gne__c = 'ZZZZ', State_gne__c ='BA', Zip_gne__c ='00002');
        insert new List<USPS_Address_gne__c>{add, add1, add2};
        
        Zip_to_Territory_gne__c z2t1 = new Zip_to_Territory_gne__c(Territory_Number_gne__c = '00F123', Zip_Code_gne__c='99999', STARS_BrandCode_gne__c='TEST'); 
        Zip_to_Territory_gne__c z2t2 = new Zip_to_Territory_gne__c(Territory_Number_gne__c = '00F123', Zip_Code_gne__c='88888', STARS_BrandCode_gne__c='TEST');  
        insert new List<Zip_to_Territory_gne__c>{z2t1, z2t2};        
    }
    
    @isTest
    static void testInsert(){
        Zip_to_Territory_gne__c z2t1 = new Zip_to_Territory_gne__c(Territory_Number_gne__c = '00F123', Zip_Code_gne__c='00000', STARS_BrandCode_gne__c='TEST'); 
        Test.startTest();
        	insert z2t1;
        Test.stopTest();
        z2t1 = [SELECT State_gne__c, City_gne__c FROM Zip_to_Territory_gne__c WHERE Id = : z2t1.Id];
        
        System.assertEquals('XXXX', z2t1.City_gne__c);
        System.assertEquals('CA', z2t1.State_gne__c);
    }
    
    @isTest
    static void testUpdate(){
        Zip_to_Territory_gne__c z2t1 = [SELECT Zip_Code_gne__c, State_gne__c, City_gne__c FROM Zip_to_Territory_gne__c WHERE Territory_Number_gne__c = '00F123' AND Zip_Code_gne__c='99999' LIMIT 1];
        Test.startTest();
        	z2t1.Zip_Code_gne__c = '00001';
        	update z2t1;
        Test.stopTest();
        z2t1 = [SELECT State_gne__c, City_gne__c FROM Zip_to_Territory_gne__c WHERE Id = : z2t1.Id];
        System.assertEquals('YYYY', z2t1.City_gne__c);
        System.assertEquals('SA', z2t1.State_gne__c);
    }
    
    @isTest
    static void testUpdateToNull(){
        Zip_to_Territory_gne__c z2t1 = [SELECT Zip_Code_gne__c, State_gne__c, City_gne__c FROM Zip_to_Territory_gne__c WHERE Territory_Number_gne__c = '00F123' AND Zip_Code_gne__c='99999' LIMIT 1];
        Test.startTest();
        	z2t1.Zip_Code_gne__c = '00004';
        	update z2t1;
        Test.stopTest();
        z2t1 = [SELECT State_gne__c, City_gne__c FROM Zip_to_Territory_gne__c WHERE Id = : z2t1.Id];
        System.assertEquals(null, z2t1.City_gne__c);
        System.assertEquals(null, z2t1.State_gne__c);
    }
}