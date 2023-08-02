/******************************************************************************************
*  @author: Lukasz Bieniawski, Roche (contractor)
*  @email: lukasz.bieniawski@contractors.roche.com   
*  Created: 2014-05-30
*  Description: Common class with usefull methods being used in case of Revegy system integration

*  Modification History
*  Date            Name               Description
*******************************************************************************************/
public with sharing class GNE_SFA2_Revegy_Utils {
        
    private static GNE_SFA2_Revegy_Config_Items_gne__c setting {
        get {
            if (setting == null){
                setting = GNE_SFA2_Revegy_Config_Items_gne__c.getInstance('GNE_Revegy_Content');                
            }
            return setting;
        }       
    }
    
    private static String getCompanyId(){
        return GNE_SFA2_Revegy_Utils.setting != null ? GNE_SFA2_Revegy_Utils.setting.Company_Id_gne__c : '';
    }
    
    private static String getMenuMoreURL(){
        return GNE_SFA2_Revegy_Utils.setting != null ? GNE_SFA2_Revegy_Utils.setting.Menu_More_URL_gne__c : '';
    }
    
    private static String getiFrameURL(){
        return GNE_SFA2_Revegy_Utils.setting != null ? GNE_SFA2_Revegy_Utils.setting.iFrame_URL_gne__c : '';
    }
    
    private static String getSessionUrl(){
        String result = String.format('{0}/services/Soap/u/22.0/{1}',
            new String[] { 
                URL.getSalesforceBaseUrl().toExternalForm(),
                UserInfo.getOrganizationId()
            }
        );
        return result.replace('c.', '').replace('.visual.force.', '.salesforce.');
    }
    
    private static String getLogoutURL(){
        return GNE_SFA2_Revegy_Utils.setting != null ? GNE_SFA2_Revegy_Utils.setting.Logout_URL_gne__c : '';
    }
    
    public static String getStandaloneUrl(){        
        return String.format('{0}?sessionId={1}&sessionURL={2}&viewType=PORTFOLIO&companyId={3}&logoutUrl={4}',
            new String[]{
                GNE_SFA2_Revegy_Utils.getMenuMoreURL(),
                UserInfo.getSessionId(),
                GNE_SFA2_Revegy_Utils.getSessionUrl(),
                GNE_SFA2_Revegy_Utils.getCompanyId(),
                GNE_SFA2_Revegy_Utils.getLogoutURL()
            }
        );      
    }
    
    public static String getIFrameUrl(Id accountId){
        return String.format('{0}?sessionId={1}&sessionURL={2}&accountId={3}&companyId={4}',
            new String[]{
                GNE_SFA2_Revegy_Utils.getiFrameURL(),
                UserInfo.getSessionId(),
                GNE_SFA2_Revegy_Utils.getSessionUrl(),
                accountId,
                GNE_SFA2_Revegy_Utils.getCompanyId()                
            }       
        );
    }       
}