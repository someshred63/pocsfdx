/** @date 17/11/2014
* @Author Michal Szewczyk
* @description Page Tabs controller
*/
public with sharing class SRW_PageTabsController {

    // User info
    public String   usrName     { get; set; }
    public String   today       { get; set; }
    public Boolean  isExternal  { get; set; }
    public Boolean  isMimic     { get; set; }
    public String   mimicTPName { get; set; }

    private List<SRW_Mimic_Data__c> mimicData;

	/** @date 17/11/2014
	* @Author Michal Szewczyk
    * @description VDST_PageTabsController_gne constructor
    */
	public SRW_PageTabsController(){
		setPageFields();
	}

	/** @date 17/11/2014
	* @Author Michal Szewczyk
    * @description Constructor for Controller
    */
    private void setPageFields() {
        usrName = UserInfo.getName();
        today = Date.today().format();
        if(getCurrentUserProfileName() == 'GNE-GST-Partner-External'){
            isExternal = true;
        } else {
            isExternal = false;
        }

        //check mimic
        mimicData = [Select SRW_Trading_Partner_Profile_gne__c,SRW_Trading_Partner_Profile_gne__r.Name, SRW_Trading_Partner_Profile_gne__r.Trading_Partner_Name_gne__c, User_gne__c from SRW_Mimic_Data__c where User_gne__c =:UserInfo.getUserId()];
        if(!mimicData.isEmpty()){

            mimicTPName = mimicData[0].SRW_Trading_Partner_Profile_gne__r.Trading_Partner_Name_gne__c;
            isMimic = true;
        }
        else {

            isMimic = false;
        }

    }


    public PageReference stopMimic() {

        try {
            delete mimicData;
            isMimic = false;
        } catch (Exception e) {

                system.debug('MICK_LOKO: Something went wrong :' + e);
        }

        return goToManageTraidingPartners();
    }

	/** @date 17/11/2014
	* @Author Michal Szewczyk
    * @description Get Current User Profile Name
    * @return String
    */
    private static String getCurrentUserProfileName() {
        return [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
    }

	/** @date 17/11/2014
	* @Author Michal Szewczyk
    * @description Manage Traiding Partners
    * @return PageReference
    */
    public PageReference goToManageTraidingPartners() {
        PageReference pr = new PageReference('/apex/SRW_TradingPartnerManagement');
        pr.setRedirect(true);
        return pr;
    }

	/** @date 17/11/2014
	* @Author Michal Szewczyk
    * @description Log-out button
    * @return PageReference
    */
    public PageReference logOut() {
        PageReference pr = new PageReference('/secur/logout.jsp');
        return pr.setRedirect(true);
    }

	/** @date 17/11/2014
	* @Author Michal Szewczyk
    * @description Go to Manage Products Page
    * @return PageReference
    */
    public PageReference goToManageProducts() {
        PageReference pr = new PageReference('/apex/SRW_ManageProducts');
        pr.setRedirect(true);
        return pr;
    }

	/** @date 17/11/2014
	* @Author Michal Szewczyk
    * @description Go to Sweep Page
    * @return PageReference
    */
    public PageReference goToSweep(){
        PageReference pr = new PageReference('/apex/SRW_Sweep');
        pr.setRedirect(true);
        return pr;
    }

	/** @date 17/11/2014
	* @Author Michal Szewczyk
    * @description Go to Re-Sweep Page
    * @return PageReference
    */
    public PageReference goToReSweep(){
        PageReference pr = new PageReference('/apex/SRW_ReSweep');
        pr.setRedirect(true);
        return pr;
    }
    
    /** @date 17/11/2014
	* @Author Michal Szewczyk
    * @description Go to Reporting Page
    * @return PageReference
    */
    public PageReference goToReporting(){
        PageReference pr = new PageReference('/apex/SRW_Reporting');
        pr.setRedirect(true);
        return pr;
    }
    
    /** @date 17/11/2014
	* @Author Michal Szewczyk
    * @description Go to Submit Sales Data Page
    * @return PageReference
    */
    public PageReference goToSubmitSalesData(){
        PageReference pr = new PageReference('/apex/SRW_SubmitSalesData');
        pr.setRedirect(true);
        return pr;
    }
    
    
    /** @date 17/11/2014
	* @Author Michal Szewczyk
    * @description Go to Sales Report History Page
    * @return PageReference
    */
    public PageReference goToSalesReportHistory(){
        PageReference pr = new PageReference('/apex/SRW_SalesReportHistory');
        pr.setRedirect(true);
        return pr;
    }
    
    /** @date 17/11/2014
	* @Author Michal Szewczyk
    * @description Go to Prescriber List Page
    * @return PageReference
    */
    public PageReference goToPrescriberList(){
        PageReference pr = new PageReference('/apex/SRW_PrescriberList');
        pr.setRedirect(true);
        return pr;
    }
    
    
     /** @date 17/11/2014
	* @Author Michal Szewczyk
    * @description Go to Profile Page
    * @return PageReference
    */
    public PageReference goToProfile(){
        PageReference pr = new PageReference('/apex/SRW_Profile');
        pr.setRedirect(true);
        return pr;
    }
    
}