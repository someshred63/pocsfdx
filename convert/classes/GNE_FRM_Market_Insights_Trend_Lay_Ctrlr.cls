/************************************************************
*  @author: Michal Zaganczyk (michal.zaganczyk@contractors.roche.com)
*  Date: 2013-5-15
*  Description:
*  
*  Modification History
*  Date        Name        Description
*  2013-6-10   James Hou   added currentMode for create/view/edit mode handling on single page
*            
*************************************************************/
public with sharing class GNE_FRM_Market_Insights_Trend_Lay_Ctrlr {
	
	/**
     * Enum with availability mode values used to distinguish between different modes of access.
     */
    private enum AvailabilityModeEnum { CREATE, EDIT, VIEW }
    
    /**
     * Name of the URL parameter used to pass value of the Market Insight Trend record Id.
     */
    private final static String TREND_RECORD_ID_URL_PARAM_NAME = 'id';
    
    /**
     * Name of the URL parameter used to pass value determining the availability mode.
     */
    private final static String AVAILABILITY_MODE_URL_PARAM_NAME = 'mode';
    
    public AvailabilityModeEnum availabilityMode;
    
    /**
     * Handler for triple-mode VF page
     */
    public String currentMode {
    	get {
            return this.availabilityMode.name();
        }
        set {
            this.currentMode = this.availabilityMode.name();
        }
    }
    
    /**
     * Guidance URL fetched from custom setting
     */
	public final String guidanceURL {get; private set;}
	
	public Market_Insight_Trend_gne__c trend {get; private set;}
	
	public TrendToMarketInsightAssociations associatedMarketInsights {get; private set;}
	
	public Integer indexOfMarketInsightToRemove {get; set;}
	
	/**
	 * 
	 */
	public GNE_FRM_Market_Insights_Trend_Lay_Ctrlr() {
		this.associatedMarketInsights = new TrendToMarketInsightAssociations();
		this.guidanceURL = GNE_FRM_Market_Insights_Util.getGuidanceURL();
		this.initialize();
	}
	
	private void initialize() {
        Map<String, String> urlParams = ApexPages.currentPage().getParameters();
        String recordIdUrlParamValue = urlParams.get(TREND_RECORD_ID_URL_PARAM_NAME);
        if (null == recordIdUrlParamValue) {
            this.availabilityMode = AvailabilityModeEnum.CREATE;
        } else {
            String availabilityModeUrlParamValue = urlParams.get(AVAILABILITY_MODE_URL_PARAM_NAME);
            if ('edit' == availabilityModeUrlParamValue) {
                this.availabilityMode = AvailabilityModeEnum.EDIT;
            } else if ('view' == availabilityModeUrlParamValue) {
                this.availabilityMode = AvailabilityModeEnum.VIEW;
            } else {
                this.availabilityMode = AvailabilityModeEnum.EDIT;
            }
        }
        
        if (this.availabilityMode == AvailabilityModeEnum.EDIT || this.availabilityMode == AvailabilityModeEnum.VIEW) {
            this.loadMarketInsightTrend(recordIdUrlParamValue);
            this.associatedMarketInsights.load(this.trend.Id);
        }
        else if (this.availabilityMode == AvailabilityModeEnum.CREATE) {
            this.trend = new Market_Insight_Trend_gne__c();
            String marketInsightsIds = urlParams.get('miids');
            Set<Id> setOfMiIds = GNE_FRM_Market_Insights_Trends_Util.parseRecordIdsIntoSet(marketInsightsIds);
            this.associatedMarketInsights.load(setOfMiIds);
        }
    }
    
    private void loadMarketInsightTrend(String trendId) {
        this.trend = GNE_FRM_Market_Insights_Trends_Util.loadMarketInsightTrend(trendId);
    }
    
    public static Boolean getIsMonitor() {
        Boolean result = GNE_FRM_Market_Insights_Util.checkMonitorStatus(UserInfo.getUserId());
        system.debug('isMonitor: ' + result);
        return result;
    }
    
    /**
     * Handler for "Cancel" action for title bar button.
     */
    public PageReference cancel() {
        String retUrl = ApexPages.currentPage().getParameters().get('retUrl');
        PageReference pageRef = (retUrl==null) ? Page.GNE_FRM_Market_Insights_Trends : new PageReference(retUrl);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    /**
     * Handler for "Edit" action for title bar button.
     */
    public PageReference edit() {
        PageReference pageRef = Page.GNE_FRM_Market_Insights_Trend_Layout;
        pageRef.getParameters().put('id', this.trend.Id);
        pageRef.getParameters().put('mode', 'edit');
        pageRef.getParameters().put('retUrl', '/apex/GNE_FRM_Market_Insights_Trend_Layout?id=' + this.trend.Id + '&mode=view');
        pageRef.setRedirect(true);
        return pageRef;
    }
    
	public PageReference removeMarketInsightAction() {
		try {
			this.unassociateMarketInsight();
		} catch (Exception ex) {
			ApexPages.addMessages(ex);
		}
		return null;
	}
	
	public PageReference saveTrendAction() {
		String incomingTrendStatus = Apexpages.currentPage().getParameters().get('actionFunctionStatusValue');
		/* Leave previous status value alone */
		String trendStatus = (String.isNotBlank(incomingTrendStatus)) ? incomingTrendStatus : this.trend.Status_gne__c;
		system.debug('trendStatus is: ' + trendstatus);
		System.Savepoint sp = Database.setSavepoint();
		try {
			this.trend.Status_gne__c = trendStatus;
			if (trend.Creator_Role_gne__c == null)
				this.trend.Creator_Role_gne__c = GNE_SFA2_Util.getUserApplicationContext().Role_gne__c;
			upsert this.trend;
			this.associatedMarketInsights.save(this.trend.Id);
		} catch (Exception ex) {
			Database.rollback(sp);
			ApexPages.addMessages(ex);
			return null;
		}
        this.loadMarketInsightTrend(this.trend.Id);
        /* Removed for triple-mode VF page
        String savedMessage = (this.trend.Status_gne__c == 'Archived') ? 'archived.' : 'saved.';
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Market Insight Trend has been successfully ' + savedMessage));
        */
        
        /* To mimic mode switching - we redirect to the same page with an updated mode parameter */
        PageReference pageRef = Page.GNE_FRM_Market_Insights_Trend_Layout;
        String retUrl = ApexPages.currentPage().getParameters().get('retUrl');
        String retRedirect = (retUrl==null) ? '/apex/GNE_FRM_Market_Insights_Trends' : retUrl;
        pageRef.getParameters().put('id', this.trend.Id);
        pageRef.getParameters().put('mode', 'view');
        pageRef.getParameters().put('retUrl', retRedirect);
        pageRef.setRedirect(true);
        return pageRef;
	}
	
	private void unassociateMarketInsight() {
		try {
			if ((this.indexOfMarketInsightToRemove > -1) 
				&& (this.indexOfMarketInsightToRemove < this.associatedMarketInsights.elements.size())) {
				if (this.associatedMarketInsights.elements.size() < 2)
					throw new MarketInsightUnassociationException('Trends must always have one or more Insights.');
				this.associatedMarketInsights.remove(this.indexOfMarketInsightToRemove);
			}
		} finally {
			this.indexOfMarketInsightToRemove = -1;
		}
	}
	
	private class MarketInsightUnassociationException extends Exception {}
	
	/**
	 * Custom list of MarketInsightWrapper elements.
	 * 
	 * @author Michal Zaganczyk (michal.zaganczyk@contractors.roche.com)
	 * @date 4/18/2013
	 */
	public class TrendToMarketInsightAssociations {
		public final List<MarketInsightWrapper> elements {get; private set;}
		public TrendToMarketInsightAssociations() {
			this.elements = new List<MarketInsightWrapper>();
		}
		
		public Integer add(MarketInsightWrapper element) {
			return this.add(null, element);
		}
		
		public Integer add(Integer index, MarketInsightWrapper element) {
			Integer result = 0;
			if (null != index) {
				this.elements.add(index, element);
				result = index;
			} else {
				this.elements.add(element);
				result = this.elements.size() - 1;
			}
			this.reindexElements();
			return result;
		}
		
		public void addAll(List<MarketInsightWrapper> elements) {
			Integer size = this.elements.size();
			for (MarketInsightWrapper element : elements) {
				this.elements.add(element);
				element.index = size++;
			}
		}
		
		public MarketInsightWrapper remove(Integer index) {
			MarketInsightWrapper result = this.elements.remove(index);
			this.reindexElements();
			result.index = -1;
			return result;
		}
		
		public void clear() {
			this.elements.clear();
		}
		
		public void load (Set<Id> marketInsightIds) {
			this.clear();
			for (Market_Insight_gne__c mi : loadMarketInsightRecords(marketInsightIds)) {
				this.add(null, new MarketInsightWrapper(null, mi));
			}
		}
		
		public void load(Id trendId) {
			this.clear();
			for (Market_Insight_gne__c mi : loadAssociatedMarketInsightRecords(trendId)) {
				this.add(null, new MarketInsightWrapper(null, mi));
			}
		}
		
		public void save(Id trendId) {
			/* Get Ids of assigned Market Insights (database state and current state) */
			Set<Id> oldIds = GNE_FRM_Market_Insights_Trends_Util.loadMarketInsightsAssignedToTrendAsMap(trendId).keySet();
			Set<Id> newIds = this.getWrappedRecordsAsMap().keySet();
			
			/* Detect changes to minimize updates */
			Set<Id> comIds = new Set<Id>(oldIds);
			comIds.retainAll(newIds);
			oldIds.removeAll(comIds);
			newIds.removeAll(comIds);
			/* To use in the future - detection if we will have at least one Insight assigned */
			/*if (comIds.size() < 1) {
				if (oldIds.size() > newIds.size()) {
					throw new MarketInsightUnassociationException('Trends must always have one or more Insights.');
				}
			}*/
			
			/* Unassign old (set null trendId), assign new (set trendId), leave unchanged alone */
			/* Validation will be applied during assignment, can throw an exception which should be handled outside */
			GNE_FRM_Market_Insights_Trends_Util.assignMarketInsightsToTrend(oldIds, null);
			GNE_FRM_Market_Insights_Trends_Util.assignMarketInsightsToTrend(newIds, trendId);
		}
		
		private void reindexElements() {
			for (Integer i = 0; i < this.elements.size(); i++) {
				this.elements[i].index = i;
			}
		}
		
		private Map<Id, Market_Insight_gne__c> getWrappedRecordsAsMap() {
			Map<Id, Market_Insight_gne__c> result = new Map<Id, Market_Insight_gne__c>();
			for (MarketInsightWrapper w : this.elements) {
				result.put(w.marketInsightRecord.Id, w.marketInsightRecord);
			}
			return result;
		}
		
		private List<Market_Insight_gne__c> loadMarketInsightRecords(Set<Id> marketInsightIds) {
			return GNE_FRM_Market_Insights_Trends_Util.loadMarketInsightsAsList(marketInsightIds);
		}
		
		private List<Market_Insight_gne__c> loadAssociatedMarketInsightRecords(Id trendId) {
			return GNE_FRM_Market_Insights_Trends_Util.loadMarketInsightsAssignedToTrendAsList(trendId);
		}
	}
	
	/**
	 * MarketInsightWrapper - record wrapper maintaining its index in list. 
	 * The index is needed and maintained to preserve the order on the list and to be able to pass an "argument" 
	 * to VisualForce action (to remove an element from the list basing on its index in list).
	 * 
	 * @author Michal Zaganczyk (michal.zaganczyk@contractors.roche.com)
	 * @date 4/18/2013
	 */
	public class MarketInsightWrapper {
		public final Market_Insight_gne__c marketInsightRecord {get; private set;}
		public Integer index {get; set;}
		public MarketInsightWrapper(Integer listIndex, Market_Insight_gne__c marketInsightRecord) {
			this.index = listIndex;
			this.marketInsightRecord = marketInsightRecord;
		}
	}
}