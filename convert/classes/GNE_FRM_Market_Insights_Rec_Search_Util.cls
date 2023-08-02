public with sharing class GNE_FRM_Market_Insights_Rec_Search_Util {
	/**
	 * Abstract class for simple search template. Implements only the common (templated) functionality. 
	 * Specific classes need to implement only the specific records search. 
	 */
	public abstract with sharing class GNE_FRM_Market_Insights_Abstract_Search {
		
		/**
		 * Search mode set by the user.
		 */
		public Integer searchMode {get; set;}
		
		/**
		 * Search criteria to apply during the search.
		 */
		public String searchCriteria {get; set;}
		
		/**
		 * Maximum number of matching rows returned by the search operation.
		 */
		public Integer rowsLimit {get; set;}
		
		/**
		 * Flag indicating whether the search operation was performed with current search mode and criteria.
		 */
		public Boolean wasSearchPerformed {get; private set;}
		
		/**
		 * Flag indicating whether the number of matching rows is greater than the maximum number of 
		 * returned matching rows set for the "rowsLimit" property.
		 */
		public Boolean searchCriteriaNeedsRefine {get; private set;}
		
		/**
		 * List of records matching the search criteria after performing a search.
		 */
		protected List<SObject> searchResultsRecordsList;
		
		/**
		 * Constructor, puts class into the initial state.
		 */
		public GNE_FRM_Market_Insights_Abstract_Search() {
			this.reset();
		}
		
		/**
		 * Clears search results and resets all properties to an initial state (as if the search was not yet performed).
		 * Override in descendant classes to reset their own parameters.
		 */
		public virtual void reset() {
			this.searchResultsRecordsList = new List<Case>();
			this.searchMode = 0;
			this.searchCriteria = '';
			this.rowsLimit = 5;
			this.wasSearchPerformed = false;
			this.searchCriteriaNeedsRefine = false;
		}
		
		/**
		 * Checks if the current values of "rowsLimit" and "searchCriteria" properties are set in a way which could 
		 * potentially give any search results at all (used to detect if we can return an empty list of search results
		 * instead of querying the database).
		 * 
		 * Override this method in descendant classes to add additional checks.
		 */
		protected virtual Boolean areSearchParamsValid() {
			return ((this.rowsLimit > 0) && (String.isNotBlank(this.searchCriteria)));
		}
		
		/**
		 * Performs the search operation to find matching records satisfying the search criteria in current 
		 * search mode.
		 */
		public void performSearch() {
			/* Clear previous search results, to cover the case when the reset() method was not 
			   called and an exception thrown during search, but catched outside by the caller */
			this.searchResultsRecordsList.clear();
			
			/* Fetch records matching current search criteria with current search mode */
			this.searchResultsRecordsList = this.searchForMatchingRecords();
			
			/* Set the flag indicating that the search was performed */
			this.wasSearchPerformed = true;
			
			/* Detect if the search criteria should be more precise */
			this.searchCriteriaNeedsRefine = (this.searchResultsRecordsList.size() > this.rowsLimit);
			
			/* Remove excess records from search results */
			while (this.searchResultsRecordsList.size() > this.rowsLimit)
				this.searchResultsRecordsList.remove(this.searchResultsRecordsList.size() - 1);
		}
		
		/**
		 * Checks if the search parameters are valid and if they are, calls the method fetching records from database.
		 * Other than that, the empty list of search results is returned.
		 */
		private List<SObject> searchForMatchingRecords() {
			if (!this.areSearchParamsValid()) {
				return new List<SObject>();
			} else {
				/* Fetch this.rowsLimit + 1 rows to be able to detect that there are more rows than 
				   the value set as the rowsLimit and search criteria should be more precise */
				return this.loadMatchingRecords(this.rowsLimit + 1);
			}
		}
		
		/**
		 * Abstract method to implement in the specific, non-abstract descendant classes. Should execute appropriate 
		 * database query and return matching records as a list in the method result.
		 * 
		 * @param maxNumberOfRows Maximum number of rows to return (pass it to the LIMIT parameter variable). During 
		 *                        the implementation in a descendant class, note that you should not use the class 
		 *                        property "rowsLimit", but this value (will be set as rowsLimit + 1 to detect that
		 *                        search criteria should be refined). You can also omit the check for the value of 
		 *                        this parameter, because the method will only be called, if the value is valid.
		 */
		protected abstract List<SObject> loadMatchingRecords(Integer maxNumberOfRows);
	}
	
	
	/************************************************** Case Search ***************************************************/
	
	/**
	 * Specific search class implementing the basic search for Case records.
	 */
	public with sharing class GNE_FRM_Market_Insights_Case_Search extends GNE_FRM_Market_Insights_Abstract_Search {
		
		/**
		 * Implementation of fetching the Case records that match the search criteria.
		 */
		protected override List<SObject> loadMatchingRecords(Integer maxNumberOfRows) {
			String paddedCaseNumber = this.searchCriteria.replaceAll('\\s','').leftPad(10).replace(' ', '0');
			return [
				SELECT
					Id,
					CaseNumber,
					RecordType.Name,
					Product_gne__c,
					Practice_ID_gne__c,
					Practice_gne__r.Name
				FROM
					Case
				WHERE
					CaseNumber = :paddedCaseNumber
				ORDER BY
					CaseNumber
				LIMIT
					:maxNumberOfRows
			];
		}
		
		/**
		 * Returns the search results as list of Case records.
		 */
		public List<Case> searchResults {
			get {
				return ((List<Case>) this.searchResultsRecordsList);
			}
		}
	}
	
	
	/************************************************** Trend Search **************************************************/
	
	/**
	 * Specific search class implementing the basic search for Market Insight Trend records.
	 */
	public with sharing class GNE_FRM_Market_Insights_Trend_Search extends GNE_FRM_Market_Insights_Abstract_Search {
		
		/**
		 * Search mode set by the user (0 - for search by Trend ID, 1 - for search by Trend Name)
		 */
		public Integer searchMode {get; set;}
		
		/**
		 * Overrides the base method by adding a validation to the searchMode param.
		 */
		protected override Boolean areSearchParamsValid() {
			return (super.areSearchParamsValid() && ((this.searchMode == 0) || (this.searchMode == 1)));
		}
		
		/**
		 * Implementation of fetching the Market Insight Trend records that match the search criteria.
		 */
		protected override List<SObject> loadMatchingRecords(Integer maxNumberOfRows) {
			return GNE_FRM_Market_Insights_Trends_Util.findMarketInsightTrends(
				this.searchMode, this.searchCriteria, maxNumberOfRows);
		}
		
		/**
		 * Returns the search results as list of Market Insight Trend records.
		 */
		public List<Market_Insight_Trend_gne__c> searchResults {
			get {
				return ((List<Market_Insight_Trend_gne__c>) this.searchResultsRecordsList);
			}
		}
	}
}