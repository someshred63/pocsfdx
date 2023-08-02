global without sharing class GNE_Hide_Button_WS 
{
/*  Author:     Nathan
*   Date:       08/03/2010
*   Description:    
*     Show/Hide custom buttons 'View My Brand' and 'View All Brands' in       
*     'Brand Affiliations' related list of Account. Custom setting 'GNE Profile Entitlements'
*     is used to identify users at profile or user level for Show/Hide these buttons.
*
*     This class is called by vf page GNE_Disable_PageButtons which
*     can be included in any layout where you need to hide buttons
*           
*     GNE SFA Hospital Account Layout
*     GNE SFA Hospital Department Account Layout
*     GNE SFA Practice Account Layout
*     GNE SFA Pharmacy Layout
*     GNE SFA Person Account Layout
*
*
*   Change History: 
*    08/03/2010  Nathan: Initial version
*    08/10/2010  Nathan: Added show/hide for edit and clone buttons for 
*                'Data Change Request' object. 
*                Page layout 'GNE-Change-License-Sampleability'
*/
    
    Webservice static Boolean HideButton()
    {
        Profile_Entitlements_gne__c pe = 
            Profile_Entitlements_gne__c.getInstance();
        return pe.Has_Brand_Filters_gne__c;
    }
    
    Webservice static Boolean HideDCREditButton()
    {
        // Hide/show edit button based on user profile
        
        User u = [select Id, Profile_Name_gne__c 
                    from User 
                    where Id =: UserInfo.getUserId()];
        String pn = u.Profile_Name_gne__c;
        
        if (pn.startsWith('GNE-SYS') ||
        	pn == 'GNE-SFA-InternalUser' ||
        	pn.startsWithIgnoreCase('GNE-SFA-OPS') ||
            pn.equals('Data Support') ||
            pn.equals('Automated Job System Administrator (obsolete)')
            )
        {                 
            return true; 
        }
        else
        {
            return false;
        }               
    }
    Webservice static Boolean HideDCRCloneButton()
    {
        
        // Clone is hidden for all users
        return false;
    }

}