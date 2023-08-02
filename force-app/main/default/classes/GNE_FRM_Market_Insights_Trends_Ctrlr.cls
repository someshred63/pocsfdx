/************************************************************
*  @author: James Hou (hou.james-chung@gene.com)
*  Date: 2013-4-10
*  Description: Extends SFA2 Force.com platform for List View Component. 
*
*  Modification History
*  Date        Name        Description
*  2013-6-10   James Hou   Added Monitor Check (to support triple-mode on VF page)
*            
*************************************************************/
public class GNE_FRM_Market_Insights_Trends_Ctrlr extends GNE_SFA2_List_View_Base_Controller {

    public GNE_SFA2_List_View_Base_Controller thisController { get; set; }
     
    public GNE_FRM_Market_Insights_Trends_Ctrlr () {
        super('Market_Insight_Trend_gne__c');
        thisController = this;
    }
    
    public static Boolean getIsMonitor() {
        Boolean result = GNE_FRM_Market_Insights_Util.checkMonitorStatus(UserInfo.getUserId());
        system.debug('isMonitor: ' + result);
        return result;
    }
    
}