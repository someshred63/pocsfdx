/************************************************************
*  @author: Michal Zaganczyk (michal.zaganczyk@contractors.roche.com)
*  Date: 2013-5-23
*  Description: Utility class encapsulating the functionality of searching for Market Insight Trends.
*  
*  This class should be used by the controllers of VF pages which want to use the Trend Search Popup dialog.
*
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_FRM_Market_Insights_Trends_Search {
	
	/**
	 * Search mode set by the user (0 - for search by Trend ID, 1 - for search by Trend Name)
	 */
	public Integer searchMode {get; set;}
	
	/**
	 * Search criteria to match during the search for Trends.
	 */
	public String searchCriteria {get; set;}
	
	/**
	 * Maximum number of matching rows returned by the search operation.
	 */
	public Integer rowsLimit {get; set;}
	
	/**
	 * Flag indicating that the search was performed with current search mode and criteria.
	 */
	public Boolean wasSearchPerformed {get; private set;}
	
	/**
	 * Flag indicating that the number of matching rows is greater than the maximum number of 
	 * returned matching rows set for the "rowsLimit" property.
	 */
	public Boolean searchCriteriaNeedsRefine {get; private set;}
	
	/**
	 * List of records matching the search criteria after performing a search.
	 */
	public List<Market_Insight_Trend_gne__c> searchResults {get; private set;}
	
	/**
	 * Constructor, resets all properties to initial state.
	 */
	public GNE_FRM_Market_Insights_Trends_Search() {
		this.reset();
	}
	
	/**
	 * Performs the search operation to find matching Trend records satisfying the search criteria in current 
	 * search mode. Look at the GNE_FRM_Market_Insights_Trends_Util.findMarketInsightTrends() for details.
	 */
	public void performSearch() {
		/* Clear previous search results, to cover the case when the reset() method was not 
		   called and an exception thrown during search, but catched outside by the caller */
		this.searchResults.clear();
		
		/* Fetch records matching current search criteria with current search mode, fetch this.rowsLimit + 1 
		   rows to detect that the search criteria should be more precise */
		this.searchResults = GNE_FRM_Market_Insights_Trends_Util.findMarketInsightTrends(
			this.searchMode, this.searchCriteria, this.rowsLimit + 1);
		
		/* Set the flag indicating that the search was performed */
		this.wasSearchPerformed = true;
		
		/* Detect if the search criteria should be more precise */
		this.searchCriteriaNeedsRefine = (this.searchResults.size() > this.rowsLimit);
		
		/* Remove excess records from search results */
		while (this.searchResults.size() > this.rowsLimit)
			this.searchResults.remove(this.searchResults.size() - 1);
	}
	
	/**
	 * Resets all properties to an initial state (as if the search was not yet performed).
	 */
	public void reset() {
		this.searchResults = new List<Market_Insight_Trend_gne__c>();
		this.searchMode = 0;
		this.searchCriteria = '';
		this.rowsLimit = 5;
		this.wasSearchPerformed = false;
		this.searchCriteriaNeedsRefine = false;
	}
}