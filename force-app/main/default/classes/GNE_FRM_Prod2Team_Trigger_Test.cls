@isTest
private class GNE_FRM_Prod2Team_Trigger_Test {
    
    static Map<String, Id> ids2ProfilesMap = GNE_FRM_TestUtilities.getProfiles();
    static Product_vod__c createProduct(String name, Id ownerId) {
        return new Product_vod__c(
            Name = name,
            Product_Type_vod__c = 'Detail',
            Region_Code_gne__c = 1,
            OwnerId = ownerId
        );
    }
    
    @testSetup
    static void initData() {
        User u = GNE_FRM_TestUtilities.createUser('GNE-SFA-QUEUE', ids2ProfilesMap.get('System Administrator'), false);
        u.LastName = 'GNE-SFA-QUEUE';
        insert u;
        Product_vod__c p1 = createProduct('ProductOne', u.Id);
        Product_vod__c p2 = createProduct('ProductTwo', u.Id);
        Product_vod__c p3 = createProduct('ProductThree', u.Id);
        Product_vod__c p4 = createProduct('ProductFour', u.Id);
        insert new List<Product_vod__c>{p1, p2, p3, p4};        
    }
    
    @isTest
    static void testInsertTwoCorrectRecords(){
        FRM_Prod_2_Team_gne__c p2t_1 = new FRM_Prod_2_Team_gne__c(Product_Name_gne__c = 'ProductOne', FRM_Team_Code_gne__c ='FRM' );
        FRM_Prod_2_Team_gne__c p2t_2 = new FRM_Prod_2_Team_gne__c(Product_Name_gne__c = 'ProductOne1', FRM_Team_Code_gne__c ='FRM' );
        FRM_Prod_2_Team_gne__c p2t_3 = new FRM_Prod_2_Team_gne__c(Product_Name_gne__c = 'ProductOne2', FRM_Team_Code_gne__c ='FRM' );
        FRM_Prod_2_Team_gne__c p2t_4 = new FRM_Prod_2_Team_gne__c(Product_Name_gne__c = 'ProductOne3', FRM_Team_Code_gne__c ='FRM' );
        FRM_Prod_2_Team_gne__c p2t_5 = new FRM_Prod_2_Team_gne__c(Product_Name_gne__c = 'ProductOne4', FRM_Team_Code_gne__c ='FRM' );
        FRM_Prod_2_Team_gne__c p2t_6 = new FRM_Prod_2_Team_gne__c(Product_Name_gne__c = 'ProductTwo', FRM_Team_Code_gne__c ='FRM' );
        
        Test.startTest();
            Database.insert(new List<FRM_Prod_2_Team_gne__c>{p2t_1, p2t_2, p2t_3, p2t_4, p2t_5, p2t_6}, false);
        Test.stopTest();
        
        Integer listSize = [SELECT Id FROM FRM_Prod_2_Team_gne__c].size();
        System.assertEquals(2, listSize);
    }
    
    
    @isTest
    static void testBulkOperations(){
        FRM_Prod_2_Team_gne__c p2t_1 = new FRM_Prod_2_Team_gne__c(Product_Name_gne__c = 'ProductOne', FRM_Team_Code_gne__c ='FRM' );
        FRM_Prod_2_Team_gne__c p2t_2 = new FRM_Prod_2_Team_gne__c(Product_Name_gne__c = 'ProductOne1', FRM_Team_Code_gne__c ='FRM' );
        FRM_Prod_2_Team_gne__c p2t_3 = new FRM_Prod_2_Team_gne__c(Product_Name_gne__c = 'ProductOne2', FRM_Team_Code_gne__c ='FRM' );
        FRM_Prod_2_Team_gne__c p2t_4 = new FRM_Prod_2_Team_gne__c(Product_Name_gne__c = 'ProductOne3', FRM_Team_Code_gne__c ='FRM' );
        FRM_Prod_2_Team_gne__c p2t_5 = new FRM_Prod_2_Team_gne__c(Product_Name_gne__c = 'ProductOne4', FRM_Team_Code_gne__c ='FRM' );
        FRM_Prod_2_Team_gne__c p2t_6 = new FRM_Prod_2_Team_gne__c(Product_Name_gne__c = 'ProductTwo', FRM_Team_Code_gne__c ='FRM' );
        List<FRM_Prod_2_Team_gne__c> toInsert = new List<FRM_Prod_2_Team_gne__c>{p2t_1, p2t_2, p2t_3, p2t_4, p2t_5, p2t_6};
        for(Integer x = 0; x < 1000; x++){
            FRM_Prod_2_Team_gne__c p = new FRM_Prod_2_Team_gne__c(Product_Name_gne__c = 'ProductTwo', FRM_Team_Code_gne__c ='FRM'+x );    
            toInsert.add(p);
        }
            
        Database.insert(toInsert, false);
        Integer listSize = [SELECT Id FROM FRM_Prod_2_Team_gne__c].size();
        System.assertEquals(1002, listSize);
    }
    
    @isTest
    static void testInsertErrorMessages(){
        FRM_Prod_2_Team_gne__c p2t_1 = new FRM_Prod_2_Team_gne__c(Product_Name_gne__c = 'ProductOne', FRM_Team_Code_gne__c ='FRM' );
        FRM_Prod_2_Team_gne__c p2t_2 = new FRM_Prod_2_Team_gne__c(Product_Name_gne__c = 'ProductOne', FRM_Team_Code_gne__c ='FRM' );
        FRM_Prod_2_Team_gne__c p2t_3 = new FRM_Prod_2_Team_gne__c(Product_Name_gne__c = 'ProductTwo', FRM_Team_Code_gne__c ='FRM' );
        FRM_Prod_2_Team_gne__c p2t_4 = new FRM_Prod_2_Team_gne__c(Product_Name_gne__c = 'ProductThree', FRM_Team_Code_gne__c ='FRM' );
        FRM_Prod_2_Team_gne__c p2t_5 = new FRM_Prod_2_Team_gne__c(Product_Name_gne__c = 'ProductThree1', FRM_Team_Code_gne__c ='FRM' );
        FRM_Prod_2_Team_gne__c p2t_6 = new FRM_Prod_2_Team_gne__c(Product_Name_gne__c = 'ProductFour', FRM_Team_Code_gne__c ='FRM' );
        FRM_Prod_2_Team_gne__c p2t_7 = new FRM_Prod_2_Team_gne__c(Product_Name_gne__c = 'ProductFour1', FRM_Team_Code_gne__c ='FRM' );
        FRM_Prod_2_Team_gne__c p2t_8 = new FRM_Prod_2_Team_gne__c(Product_Name_gne__c = 'ProductFour', FRM_Team_Code_gne__c ='FRM' );
        insert new List<FRM_Prod_2_Team_gne__c>{p2t_1,p2t_4, p2t_6};
            
        Test.startTest();
            Database.SaveResult[] srList = Database.insert(new List<FRM_Prod_2_Team_gne__c>{p2t_2, p2t_3,  p2t_5, p2t_7, p2t_8}, false);
        Test.stopTest();
        
        Integer listSize = [SELECT Id FROM FRM_Prod_2_Team_gne__c].size();
        System.assertEquals(4, listSize);

        Boolean isProductThree1FRM_notExist = false;
        Boolean isProductFour1FRM_notExist = false;
        
        for (Database.SaveResult sr : srList) {
            if(!sr.isSuccess()){
                for(Database.Error err : sr.getErrors()) {
                    System.debug(err.getMessage() );
                    if(err.getMessage() == 'Product ProductThree1 does not exist in the Product Catalog. Please correct the name and try again.'){
                        isProductThree1FRM_notExist = true;
                    } else if (err.getMessage() == 'Product ProductFour1 does not exist in the Product Catalog. Please correct the name and try again.'){
                        isProductFour1FRM_notExist = true;
                    } 
                }
            }           
        }
        
        System.assert(isProductThree1FRM_notExist);
        System.assert(isProductFour1FRM_notExist);    
        FRM_Prod_2_Team_gne__c[] p2ts = [SELECT Id, Product_Name_gne__c FROM FRM_Prod_2_Team_gne__c WHERE Product_Name_gne__c IN ('ProductOne', 'ProductFour')];
        System.assertEquals(2, p2ts.size());
        Boolean isProductOneFRM_exist = false;
        Boolean isProductFourFRM_exist = false;
        for(FRM_Prod_2_Team_gne__c p2t:p2ts){
            if(p2t.Product_Name_gne__c == 'ProductOne'){
                isProductOneFRM_exist = true;
            } else if(p2t.Product_Name_gne__c == 'ProductFour'){
                isProductFourFRM_exist = true;
            }
        }
        System.assertEquals(true, isProductOneFRM_exist && isProductFourFRM_exist);
    }
    
    @isTest
    static void testUpdateTwoCorrectRecords(){
        FRM_Prod_2_Team_gne__c p2t_1 = new FRM_Prod_2_Team_gne__c(Product_Name_gne__c = 'ProductOne', FRM_Team_Code_gne__c ='FRM' );
        FRM_Prod_2_Team_gne__c p2t_2 = new FRM_Prod_2_Team_gne__c(Product_Name_gne__c = 'ProductTwo', FRM_Team_Code_gne__c ='FRM' );
        FRM_Prod_2_Team_gne__c p2t_3 = new FRM_Prod_2_Team_gne__c(Product_Name_gne__c = 'ProductThree', FRM_Team_Code_gne__c ='FRM' );
        FRM_Prod_2_Team_gne__c p2t_4 = new FRM_Prod_2_Team_gne__c(Product_Name_gne__c = 'ProductFour', FRM_Team_Code_gne__c ='FRM' );
        Database.insert(new List<FRM_Prod_2_Team_gne__c>{p2t_1, p2t_2, p2t_3, p2t_4}, true);
        
        Test.startTest();
            p2t_1.Product_Name_gne__c = 'ProductThree';//error: duplicate with ProductThree key=> ProductThreeFRM
            p2t_2.Product_Name_gne__c = 'ProductThree'; //error: duplicate with ProductThree key=> ProductThreeFRM
            p2t_4.FRM_Team_Code_gne__c = 'BFRM'; //ne error
            Database.SaveResult[] srList = Database.update(new List<FRM_Prod_2_Team_gne__c>{p2t_1, p2t_2, p2t_3}, false);
        Test.stopTest();
        
        Integer errorsCounter = 0;
        Integer successCounter = 0;
        
        for (Database.SaveResult sr : srList) {
            if(!sr.isSuccess()){
                for(Database.Error err : sr.getErrors()) {
                    System.debug(err.getMessage());
                    if(err.getMessage().contains('duplicate value found:')){
                        errorsCounter++;
                    } 
                }
            } else {
                successCounter++;
            }          
        }
        System.assertEquals(2, errorsCounter);
        System.assertEquals(1, successCounter);
    }
}