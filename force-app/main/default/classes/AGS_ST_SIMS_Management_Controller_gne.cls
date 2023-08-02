public without sharing class AGS_ST_SIMS_Management_Controller_gne 
{       
    public PageReference manageSIMS()
    {
        PageReference currentPageRef = System.currentPageReference();
        String userId = currentPageRef.getParameters().get('uid');
        String stid = currentPageRef.getParameters().get('stid');
             
        //*********
        //CALL SIMS WEBSERVICE TO CREATE USER IN SIMS, CREATE SFDC SIMS RECORD
        //*********                         
        AGS_ST_SIMS_RegistrationHelper_gne registrationHelper = new AGS_ST_SIMS_RegistrationHelper_gne();       
        Boolean userCreated = registrationHelper.registerUser(stid);
        System.debug('SIMS USER CREATED:' + userCreated);           
        if(userCreated)
        {
            //AGS_ST_DbUtils.updateSTUser(stid, userId);
            return preparePermissionAssignmentPage(userId);
        }       
        else
        {
            return prepareRegisterErrorPage('Error while registering user in SIMS! Please contact Your helpdesk! ');            
        }                               
    }
            
    //************
    //ASSIGN PERMISSIONS - CAN'T BE DONE WITH CUSTOM OBJECT INSERT/UPDATE
    //************  
    public PageReference assignPermissionSetToUser()
    {        
        PageReference currentPageRef = System.currentPageReference();
        String userId = currentPageRef.getParameters().get('usrID');
        
        Boolean success = AGS_ST_DbUtils.assignPermissionSetToUser(userId);
        if(!success)
        {
            System.debug('Failed to assign permissionSet to user: ' + userId);
        }
        
        PageReference registrationFinishRef = new PageReference('/apex/AGS_ST_Registration_Finish');
        registrationFinishRef.setRedirect(true);
        return registrationFinishRef; 
    }
    
    private PageReference prepareRegisterErrorPage(String errMessage)
    {
        PageReference pr = Page.AGS_ST_RegisterError_gne;
        pr.setRedirect(true);
        pr.getParameters().put('errMsg',errMessage);        
        return pr;
    }

    private PageReference preparePermissionAssignmentPage(String userId)
    {
       PageReference permissionAssignmentRef = new PageReference('/apex/AGS_ST_PermissionsAssignment_gne?usrID=' + userId);
       permissionAssignmentRef.setRedirect(true);
       return permissionAssignmentRef; 
    }        
    
}