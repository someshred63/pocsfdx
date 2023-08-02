/************************************************************
*  @author: James Hou (hou.james-chung@gene.com)
*  Date: 2013-5-1
*  Description: Util class for various functions on Market Insight Application
*  
*  Modification History
*  Date        Name        Description
*  2013-6-10   James Hou   Added Market_Insight_Trend_gne__c to the remoteAction query
*  2014-8-04   James hou   Product and ICD9 mappings are now configurable
*            
*************************************************************/
public class GNE_FRM_Market_Insights_Util {

    /**
     * Uses FRM_Monitor to check for superuser status. This governs many VF renders and goldenrod action bar buttons.
     *
     * JH Note: FRM_Monitor also contains all the required permissions for the MI Application should we need to add
     *          MI superusers on an ad-hoc basis who do not belong in the FRM world. 
     *
     *          The MI application would not be suitable for non-FRMs to add insights, however a SFA2_View_Config 
     *          change for the "Known Trends" views would open up view visibility into Trends for non-FRMs granted the
     *          permission set. "Emerging Trends" is open to whoever is assigned the permission set and requires no
     *          further configuration for access.
     */
    public static Boolean checkMonitorStatus(String currentUser) {
        List<PermissionSetAssignment> permissionList = [
            SELECT 
                PermissionSetId 
            FROM 
                PermissionSetAssignment 
            WHERE 
                PermissionSet.Name = 'FRM_Monitor'
            AND 
                AssigneeId =: currentUser
        ];
        if (permissionList != null && permissionList.size() > 0) {
            return true;
        } else {
            return false;
        }
    }
    
    public static Boolean getIsMonitor() {
        Boolean result = checkMonitorStatus(UserInfo.getUserId());
        system.debug('isMonitor: ' + result);
        return result;
    }
    
    public static String getGuidanceURL() {
        GNE_FRM_Market_Insights_Settings__c miSetting = GNE_FRM_Market_Insights_Settings__c.getInstance('AppSettings');
        return miSetting.URL__c;
    }

    public static List<String> getFRMProducts(String frmTeam) {
        List<String> frmProducts = new List<String>();

        for (Market_Insight_Product__c asmiProduct : [
            SELECT 
                Name,
                Ordering_gne__c
            FROM 
                Market_Insight_Product__c 
            WHERE 
                FRM_Team_gne__c =: frmTeam
            ORDER BY
                Ordering_gne__c ASC
        ]) {
            frmProducts.add(asmiProduct.Name);
        }
        system.debug('frmProducts are: '+frmProducts);
        return frmProducts;
    }

    public static Map<String, List<String>> getCompleteProductCodesMap(List<SelectOption> availableProducts) {
        List<String> products = new List<String>();
        Map<String, List<String>> completeDiagnosisCodeMap = new Map<String, List<String>>();

        for (SelectOption s : availableProducts) {
            if (s.getValue()!=null && s.getValue()!='')
                products.add(s.getValue());
        }
        List<Market_Insight_Code__c> productCodes = new List<Market_Insight_Code__c>([
            SELECT
                Name,
                Ordering_gne__c,
                ASMI_Product_gne__r.Name
            FROM
                Market_Insight_Code__c
            WHERE
                ASMI_Product_gne__r.Name =: products
            ORDER BY Ordering_gne__c ASC
        ]);
        for (String p : products) {
            List<String> tempCodeContainer = new List<String>();
            for (Market_Insight_Code__c code : productCodes) {
                if (code.ASMI_Product_gne__r.Name==p) {
                    // code.Name == diagnosis code
                    tempCodeContainer.add(code.Name);
                }
            }
            completeDiagnosisCodeMap.put(p,tempCodeContainer);
        }
        system.debug('getCompleteProductCodesMap keyset is: '+completeDiagnosisCodeMap.keySet());
        return completeDiagnosisCodeMap;
    }
    
    /**
     * Assigns a Map of boolean to records (Insight or Trend) which should have their edit links on any sfa2 list view component removed.
     * 
     * @param recordHrefId: Collected from jquery on the main template page, which detects if an action column header exists
     *                       and then parses the editActionLink href for an id param. The Id is pushed into a JS array and
     *                       is directly passed here.
     * @param parsedCurrentPage: is the current page, taken from the url parsing plugin. This affects code flow for building
     *                           the query string and expression checking its results.
     */
    @RemoteAction
    public static String removeEditAction(List<String> recordHrefId, String parsedCurrentPage) {
        boolean isMonitor = getIsMonitor();
        Map<Id, Boolean> actionLinkMap = new Map<Id, Boolean>();
        system.debug('Current Page is: ' + parsedCurrentPage);
        
        String objectName = (parsedCurrentPage.contains('Trend')) ? 'Market_Insight_Trend_gne__c' : 'Market_Insight_gne__c'; 
        String query = 'SELECT ';
        query += 'Id,Status_gne__c';
        if (objectName == 'Market_Insight_gne__c')
            query += ',Issue_Resolution_Date_gne__c';
        query += ' FROM ' + objectName + ' WHERE Id =: recordHrefID';
        
        system.debug('query string is: ' + query);
        
        for (sObject mi : Database.query(query)) {
            if (String.valueOf(mi.get('Status_gne__c')) == 'Archived') {
                actionLinkMap.put(mi.Id, true);
            } else if (objectName == 'Market_Insight_gne__c' && 
                       !isMonitor && 
                       String.valueOf(mi.get('Issue_Resolution_Date_gne__c')) != null &&
                       String.valueOf(mi.get('Status_gne__c')) != 'Draft') 
            {
                actionLinkMap.put(mi.Id, true);
            } else {
                actionLinkMap.put(mi.Id, false);
            }
        }
        system.debug('Serialized actionLinkMap: ' + JSON.serialize(actionLinkMap));
        return JSON.serialize(actionLinkMap);
    }

}