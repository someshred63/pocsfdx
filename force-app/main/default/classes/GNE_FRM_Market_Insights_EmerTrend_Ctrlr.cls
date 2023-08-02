/************************************************************
*  @author: James Hou (hou.james-chung@gene.com)
*  Date: 2013-4-18
*  Description: Aggregating Emerging Trends and then displaying their individual collections. Utilizes FieldSets for columns
*               displayed on the collections generated when selecting the individual AggregateResult.
*  
*  Modification History
*  Date        Name        Description
*  2013-6-4    James Hou   - Concurrency error now uses LastModifiedId of Trend to see who was the last person to make or assign to it.
*                            (This works well because of a trend trigger which updates count)
*                          - Verbiage for Error msg 'Market Insight' -> 'Insight' (refer to it without 'Market').
*
*************************************************************/
public class GNE_FRM_Market_Insights_EmerTrend_Ctrlr {
	
	/**
	 * Stores the Aggregate of insights (Market_Insight_gne__c) that are displayed.
	 */
    public List<AggregateResult> emerTrend {get; private set;}

	/**
	 * Stores the collection of insights displayed after clicking an emerging trend.
	 */
    public List<Market_Insight_gne__c> emerTrendCollection {get; private set;}
    
	/**
	 * Stores the team filters for emerTrend and emerTrendCollection. Populated from MI custom setting, selected with jquery multiselect on VF page.
	 */
	public List<String> selectedTeamFilters {get; set;}
	
    /**
     * Stores the clicked emerging trend to generate the filtered collection.
     */
    public String selectedMasterCategory {get; set;}
    
	/**
	 * Stores the fieldset name to be rerendered on the page. This provides some ad-hoc analytics. 
	 */
    public String selectedFieldSet {get; set;}
    
	/**
	 * Stores the threshhold fetched from custom setting for reference on the page
	 */
    public Integer selectedThreshold {get; set;}
	
	/**
	 * Custom exception class to notify errors during concurrency in the Emerging Trend -> Trend flow and assignments
	 */
	private class EmergingTrendException extends Exception {}
	
    /**
     * Monitor checking
     */
    public static Boolean getIsMonitor() {
        Boolean result = GNE_FRM_Market_Insights_Util.checkMonitorStatus(UserInfo.getUserId());
        system.debug('isMonitor: ' + result);
        return result;
    }
    
	/**
	 * 1) Stores threshold count of unique insight master categories before they are considered an emerging trend.
	 * 2) Stores the team filters available for filtering emerging trends and their collections.
     *    Set to a custom setting to avoid filtering in unwanted insight entries collected from unauthroized roles.
	 */
    GNE_FRM_Market_Insights_Settings__c miSetting = GNE_FRM_Market_Insights_Settings__c.getInstance('AppSettings');
    private final Integer fetchedThreshold = miSetting.Threshold__c.intValue();
    private final String fetchedTeamFilters = miSetting.Team_Filters__c;
    
    public final GNE_FRM_Market_Insights_Trends_Search trendSearch {get; private set;}
    
    /**
     * Constructor (initializes fields and properties).
     */
    public GNE_FRM_Market_Insights_EmerTrend_Ctrlr() {
    	this.trendSearch = new GNE_FRM_Market_Insights_Trends_Search();
    	this.selectedTeamFilters = new List<String>();
    	/* Custom Settings*/
    	this.selectedThreshold = fetchedThreshold;
    	fetchAvailableTeamFilters();
    	/* Initialize Data */
    	this.emerTrendCollection = new List<Market_Insight_gne__c>();
    	this.populateEmerTrend();
    }
    
    /**
     * Generates the team filters from a custom setting available to select at the very top of Emerging Trends.
     * Backup provided in case settings are deleted.
     */
    public List<String> fetchAvailableTeamFilters() {
        if (this.fetchedTeamFilters==null) {
            this.selectedTeamFilters = new List<String>{'AFRM','BFRM','EFRM','IFRM','RFRM','GFRM','PFRM','RESPFRM'}; // Backup
        } else {
            this.selectedTeamFilters = this.fetchedTeamFilters.split(';');
        }
        return selectedTeamFilters;
    }
    
    /**
     * This will generate the top half of the page containing the aggregate query of all insights
     *
     * @param multiSelectParam is a custom setting JS populated, list of teams which populateEmerTrend will use
     */
    public void fetchEmergingTrends() {
        String multiSelectParam = Apexpages.currentPage().getParameters().get('actionFunctionMultiSelectString');
        system.debug('multiSelectParam is: ' + multiSelectParam);
        this.selectedTeamFilters = multiSelectParam.split(';');
        this.emerTrendCollection.clear();
        try {
            this.populateEmerTrend();
        } catch (Exception ex) {
            ApexPages.addMessages(ex);
        }
    }
    
    /**
     * This will set the params, then call for population for all the insights in the Emerging Trend. This is the bottom half.
     */
    public void fetchCollections() {
    	system.debug('apexpages params are: ' + Apexpages.currentPage().getParameters().get('actionFunctionCategory') + ' and ' +Apexpages.currentPage().getParameters().get('actionFunctionFieldSet'));
    	this.selectedMasterCategory = Apexpages.currentPage().getParameters().get('actionFunctionCategory');
    	this.selectedFieldSet = Apexpages.currentPage().getParameters().get('actionFunctionFieldSet');
		this.populateEmerTrendCollection(this.selectedMasterCategory, this.selectedFieldSet);
    }
    
    /**
     * Generates the Emerging Trend - an AggregateResult
     */
    private void populateEmerTrend() {
    	system.debug('selectedTeamFilters is: ' + this.selectedTeamFilters);
    	try {
		    this.emerTrend = [SELECT 
					Master_Category_gne__c, 
					count(id) iterations, 
					sum(Patients_Affected_gne__c) patients
		         FROM 
		         	Market_Insight_gne__c
		         WHERE
		         	Status_gne__c = 'Monitoring'
		         	AND
		         	Known_Trend_gne__c = null
		         	AND
		         	Role_gne__c =: this.selectedTeamFilters
		         GROUP BY
		         	Master_Category_gne__c
		         HAVING 
		         	count(id) >=: fetchedThreshold
		         ORDER BY
		         	count(id) DESC, 
		         	sum(Patients_Affected_gne__c) DESC 
		         	NULLS LAST];
    	} catch (Exception ex) {
            ApexPages.addMessages(ex);
        }
    }
    
    /**
     * Generates the collection of insights that make up the Emerging Trend (AggregateResult). It is dependent on fieldsets
     * to generate the columns of which to analyze the collection of insights. There is also a concurrency error for when multiple
     * MI SuperUsers (Aka Monitors in Phase 1) begin Make / Assign functions for insights out of an AggregateResult.
     *
     * @param masterCategory will provide the master category to get the collection of insights
     * @param fieldSet will provide the focus (field set) to provide some ad-hoc analysis on the collection of insights
     */
    public void populateEmerTrendCollection (String masterCategory, String fieldSet) {
    	system.debug('Collection population parameters are: ' + masterCategory + ' and ' + fieldSet);
    	this.selectedFieldSet = fieldset;
    	
		String query = 'SELECT ';
        for(Schema.FieldSetMember f : this.getFields()) {
            query += f.getFieldPath() + ', ';
        }
        query += 'Id, Name, Master_Category_gne__c, Role_gne__c, Insight_Submitted_Date_gne__c, Owner.Name FROM Market_Insight_gne__c WHERE Master_Category_gne__c = \'' 
                 + String.escapeSinglequotes(masterCategory).trim() + 
                 '\' AND Role_gne__c =: selectedTeamFilters AND Status_gne__c = \'Monitoring\' AND Known_Trend_gne__c = null ORDER BY Id DESC';
        
        try {
            this.emerTrendCollection = Database.query(query);
            /**
             * We likely have a concurrency error:
             * Someone else has made / assigned away all the insights in the Emerging Trend loaded on the page
             */
            if (this.emerTrendCollection.isEmpty() || this.emerTrendCollection == null) {   
            	system.debug('emerging trend collection is empty');
            	
            	/* Let's get the most recent record that belonged in the same master category */
                Market_Insight_gne__c recentlyTrendedInsight = [
                    SELECT
                        Known_Trend_gne__c,
                        Known_Trend_gne__r.Name,
                        Known_Trend_gne__r.Trend_Name_gne__c,
                        Known_Trend_gne__r.LastModifiedById
                    FROM 
                        Market_Insight_gne__c 
                    WHERE 
                        Master_Category_gne__c =: String.escapeSinglequotes(masterCategory).trim()
                        AND
                        Status_gne__c = 'Trending'
                        AND
                        Known_Trend_gne__c != null
                    ORDER BY
                        LastModifiedDate DESC
                    LIMIT 1
                ];
                if (recentlyTrendedInsight.Known_Trend_gne__r.LastModifiedById != UserInfo.getUserId()) {
	                transient String trendLink = '<a href="/' + recentlyTrendedInsight.Known_Trend_gne__c + '" target="_blank">' + recentlyTrendedInsight.Known_Trend_gne__r.Name + '</a>' + ' - ' + recentlyTrendedInsight.Known_Trend_gne__r.Trend_Name_gne__c;
	                throw new EmergingTrendException('Insights in this Emerging Trend may have been assigned to Trend ID: ' + trendLink);
                }
            }
        } catch (Exception ex) {
            ApexPages.addMessages(ex);
        }
    }
    
    /**
     * Getter for the fields property on the VF page.
     *
     * @param fieldSetValue is set to 'Default' for first time Emerging Trend selection. Subsequent clicks will
     *                      take the selectoptions generated from getAvailableFieldSets(). this.selectedFieldSet is set
     *                      in populateEmerTrendCollection() as that is the main method used to populate (and repopulate)
     *                      the Emerging Trend Collection.
     */
    public List<Schema.FieldSetMember> getFields() {
        system.debug('getFields selectedFieldSet is: ' + this.selectedFieldSet);
        string fieldSetValue = (this.selectedFieldSet == null) ? 'Default' : this.selectedFieldSet;
        return SObjectType.Market_Insight_gne__c.FieldSets.getMap().get(fieldSetValue).getFields();
    }
    
    /**
     * Getter for the focus picklist on the collections after selecting an Emerging Trend. This generates the fieldsets available
     * on Market_Insight_gne__c which will provide some ad-hoc column / field analysis of an Emerging Trend Collection.
     */
    public List<SelectOption> getAvailableFieldSets() {
        List<SelectOption> results = new List<SelectOption>();
        
        Map<String, Schema.FieldSet> FsMap = Schema.SObjectType.Market_Insight_gne__c.fieldSets.getMap();
        for (Schema.Fieldset miFieldSets : FsMap.values()) {
            results.add(new SelectOption(miFieldSets.getName(), miFieldSets.getLabel()));
        }
        return results;
    }
    
    /**
     * Action handler for the "Make a Trend" button. 
     * Validates the selected Insights to make a Trend, on succesful validation redirects to the 
     * Trend Layout in Create mode to finish the Trend creation.
     */
	public PageReference makeTrendAction() {
		/* Get the selected Insight Ids from the request parameters */
		String selectedMarketInsightIdsStr = ApexPages.currentPage().getParameters().get('selectedMarketInsightIds');
		if (null != selectedMarketInsightIdsStr) {
			try {
				/* Validate the Insights to make a Trend, will throw an exception if even one of them is not valid to make a Trend */
				Set<Id> marketInsightIds = GNE_FRM_Market_Insights_Trends_Util.parseRecordIdsIntoSet(selectedMarketInsightIdsStr);
				GNE_FRM_Market_Insights_Trends_Util.validateMarketInsightsAbilityToMakeTrend(marketInsightIds);
				/* After succesful validation redirect to Trend Layout in create mode */
				PageReference pr = Page.GNE_FRM_Market_Insights_Trend_Layout;
				pr.getParameters().put('miids', GNE_FRM_Market_Insights_Trends_Util.joinRecordIds(marketInsightIds));
				pr.getParameters().put('retUrl', '/apex/GNE_FRM_Market_Insights_EmergingTrends');
				pr.setRedirect(true);
				return pr;
			} catch (Exception ex) {
				/* Do not redirect, show error message only */
				ApexPages.addMessages(ex);
			}
		} else {
			/* Handle the case of missing request parameter */
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Insight IDs were not passed.'));
		}
		return null;
	}
	
	/**
	 * Action handler for "Assign" button on the Trend Search popup. Assigns the Insights (selected before 
	 * the Trend Search popup was shown) to the Trend found on the Trend Search popup.
	 */
	public PageReference assignToTrendAction() {
		/* Get the selected Insights Ids and found Trend Id from request parameters */
		String marketInsightsIdsStr = ApexPages.currentPage().getParameters().get('selectedMarketInsightIds');
		String trendIdStr = ApexPages.currentPage().getParameters().get('selectedTrendId');
		if ((null != marketInsightsIdsStr) && (null != trendIdStr)) {
			try {
				/* Assign the Insight to the Trend, can throw exception on validation during assignment */
				Id trendId = trendIdStr;
				Set<Id> marketInsightsIds = GNE_FRM_Market_Insights_Trends_Util.parseRecordIdsIntoSet(marketInsightsIdsStr);
				GNE_FRM_Market_Insights_Trends_Util.assignMarketInsightsToTrend(marketInsightsIds, trendId);
				
				/* On success - reload, because we modified the data and the aggregate query results and Market Insight list will be diferent */
				this.populateEmerTrend();
				this.populateEmerTrendCollection(this.selectedMasterCategory, this.selectedFieldSet);
				
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
	
	/**
	 * Action handler for the "Search" button on the Trend Search popup dialog.
	 * Gets the search mode an search criteria from request params, sets them in the Trend Search class and 
	 * calls the search method.
	 */
	public PageReference performTrendSearchAction() {
		this.trendSearch.searchMode = Integer.valueOf(ApexPages.currentPage().getParameters().get('trendSearchMode'));
		this.trendSearch.searchCriteria = ApexPages.currentPage().getParameters().get('trendSearchCriteria');
		this.trendSearch.rowsLimit = 5;
		this.trendSearch.performSearch();
		return null;
	}
	
	/**
	 * Acton handler for closing the Trend Search popup dialog.
	 * Calls the reset method in the Trend Search class.
	 */
	public PageReference resetTrendSearchAction() {
		this.trendSearch.reset();
		return null;
	}
}