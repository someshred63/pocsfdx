/************************************************************
*  @author: Michal Zaganczyk (michal.zaganczyk@contractors.roche.com)
*  Date: 2013-4-26
*  Description: Extends SFA2 Force.com platform for List View Component. 
*
*  James Hou (hou.james-chung@gene.com) 5/27 NOTE: 
*  Checkbox action button functions in this class are on hold as SFA2 List View is not behaving as it should.
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public class GNE_FRM_Market_Insights_List_Ctrlr extends GNE_SFA2_List_View_Base_Controller {
	
	public final static String MARKET_INSIGHT_RECORD_IDS_SEPARATOR = ',';
	
	public final static String MARKET_INSIGHT_RECORD_IDS_PARAM_NAME = 'miids';
	
	public final GNE_SFA2_List_View_Base_Controller thisController {get; private set;}
	
	public GNE_FRM_Market_Insights_List_Ctrlr() {
		super('Market_Insight_gne__c');
		this.thisController = this;
	}
	
	public static Boolean getIsMonitor() {
		Boolean result = GNE_FRM_Market_Insights_Util.checkMonitorStatus(UserInfo.getUserId());
		system.debug('isMonitor: ' + result);
		return result;
	}
	
	/************************************************ Properties ******************************************************/
	
	/**
	 * Stores the Id of a trend to assign the selected Market Insight records.
	 */
	public String trendIdToAssignMarketInsights {get; set;}
	
	/********************************************** Action handlers ***************************************************/
	
	/**
	 * Handler for "Make a Trend" action. Not used yet, due to the SFA List View Component checkboxes problem.
	 * To pass the Market Insights which will make a trend, gets the Ids of selected Market Insight records 
	 * and puts into URL params of Trend Edit/Create page (create mode), which will handle the rest.
	 */
	public PageReference makeTrendAction() {
		try {
			/* Check the ability to make a Trend, will throw an exception if one of Insights is not valid to make a Trend */
			Set<Id> marketInsightIds = this.getSelectedRecords();
			GNE_FRM_Market_Insights_Trends_Util.validateMarketInsightsAbilityToMakeTrend(marketInsightIds);
			
			/* Redirect to Trend Layout in create mode to finish Trend creation */
			String joinedMarketInsightIds = String.join(new List<Id>(marketInsightIds), MARKET_INSIGHT_RECORD_IDS_SEPARATOR);
			PageReference pr = Page.GNE_FRM_Market_Insights_Trend_Layout;
			pr.getParameters().put(MARKET_INSIGHT_RECORD_IDS_PARAM_NAME, joinedMarketInsightIds);
			pr.setRedirect(true);
			return pr;
		} catch (Exception ex) {
			/* Do not redirect on error, show error message only */
			ApexPages.addMessages(ex);
			return null;
		}
	}
	
	/**
	 * Handler for "Assign to Trend" action. Not used yet, due to the SFA List View Component checkboxes problem.
	 * To pass the Market Insights which will be assigned to the existing trend, gets the Ids of selected Market Insight 
	 * records and puts into URL params of Trend Edit/Create page (edit mode), which will handle the rest.
	 * The Id of the Trend which will be edited (and will have the selected Market Insight records assigned) is fetched
	 * from other property of this controller (will be set as a result of Trend search).
	 */
	public PageReference assignToTrendAction() {
		/* Get the selected Insights Ids and found Trend Id from request parameters */
		String trendIdStr = ApexPages.currentPage().getParameters().get('selectedTrendId');
		Set<Id> marketInsightIds = this.getSelectedRecords();
		if ((null != marketInsightIds) && (!marketInsightIds.isEmpty()) && (null != trendIdStr)) {
			try {
				/* Assign the Insight to the Trend, can throw exception on validation during assignment */
				Id trendId = trendIdStr;
				GNE_FRM_Market_Insights_Trends_Util.assignMarketInsightsToTrend(marketInsightIds, trendId);
				
				/* On success - reload, because we modified the data and the aggregate query results and Market Insight list will be diferent */
				//TODO: Reload
				
				/* Show confirmation message that the Insights were succesfuly assigned to the Trend */
				Market_Insight_Trend_gne__c trend = GNE_FRM_Market_Insights_Trends_Util.loadMarketInsightTrend(trendId);
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 
					'Selected Insights were succesfully assigned to a Trend ID: '
					+ '<a href="/' + trend.Id + '" target="_blank">' + trend.Name + '</a>' + ' - ' + trend.Trend_Name_gne__c));
			} catch (Exception ex) {
				/* Show error message */
				ApexPages.addMessages(ex);
			}
		} else {
			/* Handle the case of missing request parameters */
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Insight IDs or Trend ID were not passed.'));
		}
		return null;
	}
}