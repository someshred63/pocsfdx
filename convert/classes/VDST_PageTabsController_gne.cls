/** @date 3/5/2013
* @Author Marcin Pawlak
* @description Page Tabs controller
*/
public with sharing class VDST_PageTabsController_gne {

    public          String      usrName                     { get; set; }
    public          String      today                       { get; set; }
    public          Boolean     isCCO                       { get; set; }
    public          Boolean     showEdmLandingPageLink      { get; set; }
    public          Boolean     redirectToEdmLandingPage    { get; set; }

    /** @date 3/5/2013
    * @Author Marcin Pawlak
    * @description VDST_PageTabsController_gne constructor
    */
	public VDST_PageTabsController_gne(){
        checkPermissionsForEdmLandingPage();
		setPageFields();
	}

    /** @date 4/28/2015
    * @Author Konrad Malinowski
    * @description Check Permissions
    */
    public void checkPermissionsForEdmLandingPage() {
        showEdmLandingPageLink = false;
        redirectToEdmLandingPage = false;
        Boolean isGsspPermisssionSetAssigned = false;
        Boolean isEdmPermisssionSetAssigned = false;
        for(PermissionSetAssignment psa : [
            SELECT PermissionSet.Name
            FROM PermissionSetAssignment
            WHERE AssigneeId = :UserInfo.getUserId()
            AND (PermissionSet.Name = :VDST_Utils.VDST_PERMISSION_SET_NAME OR PermissionSet.Name LIKE 'EDM%')
        ]) {
            if (psa.PermissionSet.Name.equalsIgnoreCase(VDST_Utils.VDST_PERMISSION_SET_NAME)) {
                isGsspPermisssionSetAssigned = true;
            }
            if (psa.PermissionSet.Name.startsWithIgnoreCase('EDM')) {
                isEdmPermisssionSetAssigned = true;
            }
        }
        if (isEdmPermisssionSetAssigned) {
            if (!isGsspPermisssionSetAssigned) {
                redirectToEdmLandingPage = true;
            }
            showEdmLandingPageLink = true;
        }
    }

    /** @date 3/5/2013
    * @Author Marcin Pawlak
    * @description Constructor for Controller
    */
    private void setPageFields() {
        usrName = UserInfo.getName();
        today = Date.today().format();
        if(getCurrentUserProfileName() == 'GNE-AGS-CCO-Analyst'){
            isCCo = true;
        } else {
            isCCo = false;
        }
    }

    /** @date 3/5/2013
    * @Author Marcin Pawlak
    * @description Get Current User Profile Name
    * @return String
    */
    private static String getCurrentUserProfileName() {
        return [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
    }

    /** @date 6/13/2013
    * @Author Pawel Sprysak
    * @description Go to Event List Page
    * @return PageReference
    */
    public PageReference goToEventList() {
        PageReference pr = new PageReference('/apex/VDST_EventList');
        pr.setRedirect(true);
        return pr;
    }

    /** @date 10/2/2013
    * @Author Pawel Sprysak
    * @description Log-out button
    * @return PageReference
    */
    public PageReference logOut() {
        PageReference pr = new PageReference('/secur/logout.jsp');
        return pr.setRedirect(true);
    }

    /** @date 6/13/2013
    * @Author Pawel Sprysak
    * @description Go to User Management Page
    * @return PageReference
    */
    public PageReference goToUserManagement() {
        PageReference pr = new PageReference('/apex/VDST_Users_Management');
        pr.setRedirect(true);
        return pr;
    }

    /** @date 14/10/2013
    * @Author Bartłomiej Dejnega
    * @description Go to Home Page
    * @return PageReference
    */
    public PageReference goToHomePage(){
        PageReference pr = new PageReference('/home/home.jsp');
        pr.setRedirect(true);
        return pr;
    }

    /** @date 25/10/2013
    * @Author Konrad Malinowski
    * @description Go to Batch File Upload Page
    * @return PageReference
    */
    public PageReference goToBatchPage(){
        PageReference pr = new PageReference('/apex/VDST_FileUpload');
        pr.setRedirect(true);
        return pr;
    }

    /** @date 3/9/2015
    * @Author Konrad Malinowski
    * @description Go to CRO File Upload Page
    * @return PageReference
    */
    /*public PageReference goToCroPage(){
        PageReference pr = new PageReference('/apex/VDST_CROFileUpload_gne');
        pr.setRedirect(true);
        return pr;
    }*/

    /** @date 4/28/2015
    * @Author Konrad Malinowski
    * @description Go to EDM Landing Page
    * @return PageReference
    */
    public PageReference goToEdmLandingPage(){
        VDST_Settings__c settings = VDST_Utils.getCustomSettingsIntExt();
        PageReference pr = new PageReference('/apex/' + settings.EDM_Landing_Page_gne__c);
        pr.setRedirect(true);
        return pr;
    }

}