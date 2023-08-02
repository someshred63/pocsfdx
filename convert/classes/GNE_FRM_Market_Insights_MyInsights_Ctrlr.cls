/************************************************************
*  @author: James Hou (hou.james-chung@gene.com)
*  Date: 2013-4-11
*  Description: Extends SFA2 Force.com platform for List View Component. 
*
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public class GNE_FRM_Market_Insights_MyInsights_Ctrlr extends GNE_SFA2_List_View_Base_Controller {
	
	public final GNE_SFA2_List_View_Base_Controller thisController {get; private set;}
	
	public GNE_FRM_Market_Insights_MyInsights_Ctrlr() {
		super('Market_Insight_gne__c');
		this.thisController = this;
	}
}