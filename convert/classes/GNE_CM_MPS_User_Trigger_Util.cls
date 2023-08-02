/**
 * Contains various methods called in MPS User triggers.
 * 
 * Test classes: 
 * - GNE_CM_MPS_User_Flow_Test
 *
 * @author Radek Krawiec
 * @created 07/20/2012
 */
public class GNE_CM_MPS_User_Trigger_Util
{
    /**
     * Update field User_Status__c depending on the value of the field Workflow_State__c.
     * Only objects are updated, no updates sent to DB.
     */
    public static void updateUserStatus (List<GNE_CM_MPS_User__c> mpsUsers)
    {   
        for (GNE_CM_MPS_User__c mpsUser : mpsUsers) 
        {
        	if (mpsUser.User_Status__c != 'Approved for PACT') {
	            System.debug('tested mps user = ' + mpsUser);
	            if (mpsUser.Disabled__c && (mpsUser.User_Status__c == 'Active' || mpsUser.User_Status__c == 'Active-Disabled'))
	            {
	                mpsUser.User_Status__c = 'Active-Disabled';
	            }
	            else
	            {
	                String newStatus = getMpsUserStatusFromWorkflowState(mpsUser.Workflow_State__c);
	                if(newStatus != null)
	                {
	                    mpsUser.User_Status__c = newStatus;
	                }
	            }
        	}
        }
    }
    
    /**mpsUsersOld.get(newUser.Id).Is_Locked__c is no longer used
     * Resets lockout counter when changed status from isLocked true to false    * 
    */

    public static void updateLockoutCounter(Map<Id, GNE_CM_MPS_User__c> mpsUsersNew, Map<Id, GNE_CM_MPS_User__c> mpsUsersOld)
    {
    /*
        for(GNE_CM_MPS_User__c newUser : mpsUsersNew.values())
        {
            if(mpsUsersOld.get(newUser.Id).Is_Locked__c == true && newUser.Is_Locked__c == false)
            {
                newUser.Login_Failed__c = 0;
            }
        }
    */
    }
    
    /**
     * Returns value for field User_Status__c depending on the value of the field Workflow_State__c.
     * NOTE: this method is public for test purposes.
     */
    public static String getMpsUserStatusFromWorkflowState (String workflowState)
    {
        if (workflowState == 'NEW')
        {
            return 'Pending';
        }
        else if (workflowState == 'APPROVED')
        {
            return 'Approved';
        }
        else if(workflowState == 'ACTIVATION_EMAIL_SENT')
        {
            return 'Email Sent';
        }
        else if(workflowState == 'ACTIVATED')
        {
            return 'Active';
        }
        else if(workflowState == 'ACTIVATED')
        {
            return 'Active';
        }
        else if(workflowState == 'REJECTED')
        {
            return 'Rejected';
        }           
        else if(workflowState == 'ACTIVATION_LINK_EXPIRED')
        {
            return 'Expired';
        }
        // TODO - is this status used?
        else if(workflowState == 'MIGRATED')
        {
            return 'Active';
        }
        else if(workflowState == null)
        {
            return null;
        }
        else
        {
            throw new GNE_CM_Exception('Invalid Workflow State \'' + workflowState + '\'');
        }
    }
}