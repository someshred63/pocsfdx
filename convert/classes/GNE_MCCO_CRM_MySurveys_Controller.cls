/* 
 * GNE_MCCO_CRM_MySurveys_Controller
 *
 * Created By :         Tadeusz Hyzy (tadeusz.hyzy@contractors.roche.com)
 * Last Modified By :   Tadeusz Hyzy (tadeusz.hyzy@contractors.roche.com)
 * Last Modified Date : 01/13/2015
 */
public with sharing class GNE_MCCO_CRM_MySurveys_Controller {
    
    /* Init variables */    
    public static final Integer MAX_RECORDS = 50;
    
    public Boolean hasSurveys { get; private set; }
    private SFA2_Configuration_Object_gne__c pageConfiguration;
    
    public List<Survey_gne__c> surveysList { get; private set; }
    public String surveysListJson { get; private set; }
    
    public Integer surveysCount { get; private set; }
    
    public String sortField { get; private set; }
    public String sortDirection { get; private set; }
                            
    /* 
     * Constructor
     */
    public GNE_MCCO_CRM_MySurveys_Controller() {
    	sortField 			= 'LastModifiedDate';
    	sortDirection 		= 'DESC';
    	pageConfiguration 	= GNE_SFA2_Util.getListPageConfiguration('Survey_gne__c');
    	surveysCount 		= countSurveys();
    	if(surveysCount > 0) {
    		hasSurveys 		= true;
    		surveysList 	= loadSurveys(1, sortField, sortDirection);
    		surveysListJson = JSON.serializePretty(surveysList);
    	} else {
    		hasSurveys 		= false;
    		surveysList		= new List<Survey_gne__c>();
    		surveysListJson = JSON.serializePretty(surveysList);
    	}
    }
    
    public Integer getMAX_RECORDS() {
    	return MAX_RECORDS;
    }
                        
    /* 
     * loadSurveys(String sortField, String sortDirection)
     *
     * Load all surveys based on JSON settings
     *
     * return List<Survey_gne__c>
     */
    @RemoteAction
    @ReadOnly
    public static List<Survey_gne__c> loadSurveys(Integer page, String sortField, String sortDirection) {
    	Integer offset = (MAX_RECORDS * page) - MAX_RECORDS;
    	
        String query = 'SELECT Id, Name, Account__c, Account__r.Name, Survey_Status_gne__c, LastModifiedDate FROM Survey_gne__c WHERE CreatedById = \'' + UserInfo.getUserId() + '\' ORDER BY ' + sortField + ' ' + sortDirection  + ' LIMIT ' + MAX_RECORDS  +' OFFSET '+ offset;
        List<Survey_gne__c> surveysList = Database.query(query);

        return surveysList; 
    }
                        
    /* 
     * updateViewPreference(String viewId)
     *
     * Update user preference with new last view
     *
     * return boolean
     */
    @RemoteAction
    public static Boolean updateViewPreference(String viewId) {
        SFA2_User_Preferences_gne__c preference  = new SFA2_User_Preferences_gne__c( User_gne__c = UserInfo.getUserId(), Last_View_Used_gne__c = viewId );
        
        try {
            preference = [ SELECT Last_View_Used_gne__c FROM  SFA2_User_Preferences_gne__c WHERE Last_View_Used_gne__r.Page_Name_gne__c = 'My Accounts' AND User_gne__c = :Userinfo.getUserId() LIMIT 1 ];
            preference.Last_View_Used_gne__c = viewId;
        } catch(Exception e) {}
        
        try {
            upsert preference;
            return true;
        } catch(DMLException e) {
            return false;
        }
    }
           
    private Integer countSurveys() {
        return [SELECT COUNT() FROM Survey_gne__c WHERE CreatedById = :UserInfo.getUserId()];
    }
    
}