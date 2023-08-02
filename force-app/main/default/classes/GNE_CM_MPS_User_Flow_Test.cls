/**
 * Test class for various aspects of the MPS user flow.
 * @author Radek Krawiec
 * @created 07/20/2012
 */
@isTest
public with sharing class GNE_CM_MPS_User_Flow_Test
{
    public static testMethod void testUserStatusUpdate()
    {
        // create test user
        GNE_CM_MPS_User__c mpsUser = new GNE_CM_MPS_User__c();      
        String email = 'test-email-1234@gene.com';
        mpsUser.First_name__c = 'John';
        mpsUser.Email_address__c = email;
        mpsUser.Disabled__c = false;
        insert mpsUser;
        
        // go through all status updates for all Workflow_State__c picklist values
        Schema.DescribeFieldResult fieldResult = GNE_CM_MPS_User__c.Workflow_State__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        // ------------------------------------------------------------------------------------------------------
        // test mps users that are NOT disabled
        // ------------------------------------------------------------------------------------------------------
        for (Schema.PicklistEntry entry : ple)
        {
            String workflowState = entry.getValue();
            mpsUser.Workflow_State__c = workflowState;
            update mpsUser;
            
            // refetch user to see changes
            mpsUser = [SELECT Id, Workflow_State__c, User_Status__c FROM GNE_CM_MPS_User__c WHERE Id = :mpsUser.Id];
            
            // NOTE: a slightly different check would need to be added for disabled MPS users
            String expectedState = GNE_CM_MPS_User_Trigger_Util.getMpsUserStatusFromWorkflowState(workflowState);
            System.assert (mpsUser.User_Status__c == expectedState, 'MPS User status not properly updated, for Workflow State = \'' + workflowState + '\' the expected result is \'' + expectedState + '\', but the actual value is \'' + mpsUser.User_Status__c + '\'');
        }
        
        // ------------------------------------------------------------------------------------------------------
        // test mps users that ARE disabled
        // ------------------------------------------------------------------------------------------------------
        for (Schema.PicklistEntry entry : ple)
        {
            String workflowState = entry.getValue();
            mpsUser.Workflow_State__c = workflowState;
            mpsUser.Disabled__c = true;
            mpsUser.User_Status__c = 'Active';
            update mpsUser;
            
            // refetch user to see changes
            mpsUser = [SELECT Id, Workflow_State__c, User_Status__c FROM GNE_CM_MPS_User__c WHERE Id = :mpsUser.Id];
            
            // the same status for all Workflow_State values
            String expectedState = 'Active-Disabled';
            System.assert (mpsUser.User_Status__c == expectedState, 'MPS User status not properly updated, for disabled active users it should always be \'' + expectedState + '\', the actual value is \'' + mpsUser.User_Status__c + '\'');
        }
        
        // ------------------------------------------------------------------------------------------------------
        // Test mps users that already have user status 'Active-Disabled' and this status should be kept
        // as long as the user is disabled.
        // ------------------------------------------------------------------------------------------------------
        for (Schema.PicklistEntry entry : ple)
        {
            String workflowState = entry.getValue();
            mpsUser.Workflow_State__c = workflowState;
            mpsUser.Disabled__c = true;
            mpsUser.User_Status__c = 'Active-Disabled';
            update mpsUser;
            
            // refetch user to see changes
            mpsUser = [SELECT Id, Workflow_State__c, User_Status__c FROM GNE_CM_MPS_User__c WHERE Id = :mpsUser.Id];
            
            // the same status for all Workflow_State values
            String expectedState = 'Active-Disabled';
            System.assert (mpsUser.User_Status__c == expectedState, 'MPS User status not properly updated, for disabled active users it should always be \'' + expectedState + '\', the actual value is \'' + mpsUser.User_Status__c + '\'');
        }
    }
    
    public static testMethod void testResetLockoutCounter()
    {
        // create test user
        GNE_CM_MPS_User__c mpsUser = new GNE_CM_MPS_User__c();      
        String email = 'test-email-1234@gene.com';
        mpsUser.First_name__c = 'John';
        mpsUser.Email_address__c = email;
        mpsUser.Disabled__c = false;
        insert mpsUser;
        /*mpsUser.Login_Failed__c no longer exists
        //mpsUser.Login_Failed__c = 3;
       // mpsUser.Is_Locked__c = true;
        update mpsUser;
        
        //List<GNE_CM_MPS_User__c> users = [SELECT Login_Failed__c FROM GNE_CM_MPS_User__c WHERE Id =: mpsUser.Id];
        //System.assertEquals(mpsUser.Login_Failed__c, users[0].Login_Failed__c);
        
        //mpsUser.Is_Locked__c is no longer used
        
        users = [SELECT Login_Failed__c FROM GNE_CM_MPS_User__c WHERE Id =: mpsUser.Id];
        System.assertEquals(0, users[0].Login_Failed__c);*/
    }
}