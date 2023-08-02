/**
*  @author: Przemek Giszczak
*  Date: 2014-08-11
*  This is a test class for GNE_SFA2_User_Ext
*
*  Modification History
*  Date        Name        Description
 */
@isTest
public with sharing class GNE_SFA2_User_Ext_Test {

    static testMethod void test_GNE_SFA2_User_Ext() {

        Map<Id, Profile> profilesMap = new Map<Id, Profile>(
                        [SELECT Id FROM Profile
                         WHERE Name LIKE 'GNE-Field'
                         AND (NOT Name LIKE 'GNE-SFA-Ops%')
                         AND (NOT Name LIKE '%Admin%')
                        ]);

        User usr = [Select Id From User Where
                    ProfileId IN :profilesMap.keySet()
                    AND Id in(Select UserID From UserTerritory2Association)
                    AND isActive = true
                    Limit 1];

        List<UserTerritory2Association> lUserTerritories = [Select Id From UserTerritory2Association Where UserId = :usr.Id];

        System.runAs( usr ) {


            ApexPages.StandardController stdCtrl = new ApexPages.StandardController( usr );

            GNE_SFA2_User_Ext testCtrl = new GNE_SFA2_User_Ext( stdCtrl );

            // constructor test
            system.assertEquals( UserInfo.getUserId(), testCtrl.UserId );

            PageReference pr = Page.GNE_SFA2_User_Layout;
            pr.getParameters().put( 'Id', '1' );
            Test.setCurrentPage( pr );
            testCtrl = new GNE_SFA2_User_Ext( stdCtrl );
            system.assertEquals( '1', testCtrl.UserId );

            // clickEdit() method test
            pr = testCtrl.clickEdit();
            system.assert( pr.getUrl().contains('GNE_SFA2_Edit_User_Layout') );
            system.assertEquals( true, pr.getredirect() );
            system.assertEquals( '1', pr.getParameters().get('id') );

            // overrideUserViewLink() method test
            pr = testCtrl.overrideUserViewLink();
            system.assert( pr.getUrl().contains('GNE_SFA2_User_Layout') );
            system.assertEquals( true, pr.getredirect() );
            system.assertEquals( 'null', pr.getParameters().get('id') );

            // getIsEdit() method test
            pr.getParameters().put( 'Id', UserInfo.getUserId() );
            Test.setCurrentPage( pr );
            system.assertEquals( true, testCtrl.getIsEdit() );


            pr.getParameters().remove( 'Id');
            Test.setCurrentPage( pr );
            system.assertEquals( false, testCtrl.getIsEdit() );

            // getUserTerritories() method test
            testCtrl = new GNE_SFA2_User_Ext( stdCtrl );
            System.assertEquals( lUserTerritories.size(), testCtrl.getUserTerritories().size() );

            system.assertEquals( true, testCtrl.assignToTerritories );
        }
    }
}