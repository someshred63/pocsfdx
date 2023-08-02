/** @date 02/10/2017
* @Author Gabriel Juriewicz
* @description Unit Test for VDST_Admins_Management_Ctrl
*/
@isTest
private class VDST_Admins_Management_Ctrl_Test {
    static testMethod void setUserPrivileges_shouldSetcanAccessPageToTrue() {
        // GIVEN
        VDST_Settings__c vdstSettingCurrentOrg = new VDST_Settings__c(Admin_Username__c = userInfo.getUserName(), Name = 'otherOrg');
        VDST_Settings__c vdstSettingOtherOrg = new VDST_Settings__c(Admin_Username__c = userInfo.getUserName(), Name = AGS_ST_Utils.getEnvName());
        insert vdstSettingCurrentOrg;
        insert vdstSettingOtherOrg;
        // WHEN
        VDST_Admins_Management_Ctrl ctrl = new VDST_Admins_Management_Ctrl();
        // THAN
        System.assertEquals(true, ctrl.canAccessPage, 'Should set canAccessPage to true, if current user is admin specified in VDST_Settings__c.Admin_Username__c of current organization.');
    }

    static testMethod void setUserPrivileges_shouldSetcanAccessPageToFalse() {
        // GIVEN
        VDST_Settings__c vdstSettingCurrentOrg = new VDST_Settings__c(Admin_Username__c = 'testuser@gene.com', Name = 'otherOrg');
        insert vdstSettingCurrentOrg;
        // WHEN
        VDST_Admins_Management_Ctrl ctrl = new VDST_Admins_Management_Ctrl();
        // THAN
        System.assertEquals(false, ctrl.canAccessPage, 'Should set canAccessPage to false, if current user is not admin specified in VDST_Settings__c.Admin_Username__c of current organization.');
    }

    static testMethod void setUserPrivileges_shouldCatchException() {
        // WHEN
        VDST_Admins_Management_Ctrl ctrl = new VDST_Admins_Management_Ctrl();
        // THAN
        System.assertEquals(false, ctrl.canAccessPage, 'Should set canAccessPage to false and catch exception, if no VDST_Settings__c record exists in current organization.');
    }
}