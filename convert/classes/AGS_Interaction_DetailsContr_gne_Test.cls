/** @date 12/22/2016
* @Author Gabriel Juriewicz
* @description Unit test for AGS_Interaction_DetailsContr_gne
*/
@isTest
private class AGS_Interaction_DetailsContr_gne_Test {
    
    @testSetup static void setupData() {
        Account acc = new Account(LastName = 'Test Account Name');
        insert acc;
        Call2_vod__c parentCall2 = new Call2_vod__c(Account_vod__c = acc.Id);
        insert parentCall2;
        Product_vod__c prod = new Product_vod__c(Name = 'Test Product', Product_Type_vod__c = 'Tools');
        insert prod;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'GNE-AGS-CCO-TempAnalyst'].Id,
                UserRoleId = [SELECT Id FROM UserRole WHERE Name = 'Standard User'].Id,
                Username = 'testUser@gene.com' + System.currentTimeMillis(),
                TimeZoneSidKey = 'America/Los_Angeles',
                Email = 'testUser@gene.com',
                LanguageLocaleKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LocaleSidKey = 'en_US',
                CompanyName = 'TEST',
                LastName = 'last',
                Title = 'title',
                Alias = 'alias'
            );
        }
    }
    
    static testMethod void getListAttendees_shouldReturnChildrenAttendees() {
        // given
        Account acc = [Select Id From Account LIMIT 1];
        Call2_vod__c parentCall2 = [Select Id From Call2_vod__c where Account_vod__c = :acc.Id];
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(parentCall2);
        Call2_vod__c childCall2 = new Call2_vod__c(Account_vod__c = acc.Id, Parent_Call_vod__c = parentCall2.Id);
        insert childCall2;
        // when
        Test.startTest();
        AGS_Interaction_DetailsContr_gne controller = new AGS_Interaction_DetailsContr_gne(stdCtrl);
        Test.stopTest();
        // then
        System.assertEquals(childCall2.Id, controller.listAttendees[0].Id, 'Function getListAttendees should return Call2_vod__c records related to a Call2_vod__c passed in controller.');
        System.assert(controller.hasChilds);
    }
    
    static testMethod void getListAttendees_shouldNotReturnAttendees() {
        // given
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Call2_vod__c parentCall2 = [SELECT Id FROM Call2_vod__c WHERE Account_vod__c = :acc.Id];
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(parentCall2);
        // when
        Test.startTest();
        AGS_Interaction_DetailsContr_gne ctrlUnderTest = new AGS_Interaction_DetailsContr_gne(stdCtrl);
        Test.stopTest();
        // then
        System.assertEquals(false, ctrlUnderTest.hasChilds, 'Function getListAttendees should not return any Call2_vod__c records, if there are no Call2_vod__c related to a parent in controller.');
    }
    
    static testMethod void getLstCallSamples_shouldReturnCallSamples() {
        // given
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Call2_vod__c parentCall2 = [SELECT Id FROM Call2_vod__c WHERE Account_vod__c = :acc.Id];
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(parentCall2);
        Product_vod__c prod = [SELECT Name FROM Product_vod__c LIMIT 1];
        Call2_Sample_vod__c call2Sample = new Call2_Sample_vod__c(
            Call2_vod__c = parentCall2.Id,
            Product_vod__c = prod.Id,
            Account_vod__c = acc.Id,
            Quantity_vod__c = 1
        );
        insert call2Sample;
        // when
        Test.startTest();
        AGS_Interaction_DetailsContr_gne ctrlUnderTest = new AGS_Interaction_DetailsContr_gne(stdCtrl);
        Test.stopTest();
        // then
        System.assertEquals(call2Sample.Id, ctrlUnderTest.lstCallSamples[0].Id, 'Function getLstCallSamples should return Call2_Sample_vod__c records that are related to Call2_vod__c passed in controller.');
        System.assertEquals(prod.Name, ctrlUnderTest.lstCallSamples[0].Product_vod__r.Name, ctrlUnderTest.lstCallSamples[0]);
        System.assertEquals(prod.Id, ctrlUnderTest.lstCallSamples[0].Product_vod__r.Id, ctrlUnderTest.lstCallSamples[0]);
        System.assertEquals(true, ctrlUnderTest.hasCallSamples);
    }
    
    static testMethod void getListCallDiscussions_shouldReturnCallDiscussions() {
        // given
        Account acc = [Select Id From Account LIMIT 1];
        Call2_vod__c parentCall2 = [Select Id From Call2_vod__c where Account_vod__c = :acc.Id];
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(parentCall2);
        Call2_Discussion_vod__c callDiscussion = new Call2_Discussion_vod__c(
            Call2_vod__c = parentCall2.Id,
            Account_vod__c = acc.Id
        );
        insert callDiscussion;
        // when
        Test.startTest();
        AGS_Interaction_DetailsContr_gne ctrlUnderTest = new AGS_Interaction_DetailsContr_gne(stdCtrl);
        Test.stopTest();
        // then
        System.assertEquals(callDiscussion.Id, ctrlUnderTest.listCallDiscussions[0].Id, 'Function getListCallDiscussions should return Call2_Discussion_vod__c records that are related to Call2_vod__c passed in controller.');
        System.assertEquals(true, ctrlUnderTest.hasBrands);
    }
    
    static testMethod void getLstCallSamples_shouldReturnCallSamplesWithNoProductAccess() {
        // given
        User userWithoutAccessToProduct = [
            SELECT Id FROM User WHERE Email = 'testUser@gene.com'
            AND Profile.Name = 'GNE-AGS-CCO-TempAnalyst' LIMIT 1
        ];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Call2_vod__c parentCall2 = [SELECT Id FROM Call2_vod__c WHERE Account_vod__c = :acc.Id];
        Product_vod__c prod = [SELECT Name FROM Product_vod__c LIMIT 1];
        insert new Call2_vod__Share(
            UserOrGroupId = userWithoutAccessToProduct.Id,
            ParentId = parentCall2.Id,
            AccessLevel = 'Read',
            RowCause = 'Manual'
        );
        Call2_Sample_vod__c call2Sample = new Call2_Sample_vod__c(
            Call2_vod__c = parentCall2.Id,
            Product_vod__c = prod.Id,
            Account_vod__c = acc.Id,
            Quantity_vod__c = 1
        );
        insert call2Sample;
        // when
        System.runAs(userWithoutAccessToProduct) {
            ApexPages.StandardController sc = new ApexPages.StandardController(parentCall2);
            Test.startTest();
            AGS_Interaction_DetailsContr_gne ctrlUnderTest = new AGS_Interaction_DetailsContr_gne(sc);
            Test.stopTest();
            // then
            System.assertEquals(1, ctrlUnderTest.lstCallSamples.size());
            System.assertEquals(prod.Id, ctrlUnderTest.lstCallSamples[0].Product_vod__r.Id, ctrlUnderTest.lstCallSamples[0]);
            System.assertEquals(prod.Name, ctrlUnderTest.lstCallSamples[0].Product_vod__r.Name, ctrlUnderTest.lstCallSamples[0]);
        }
    }
}