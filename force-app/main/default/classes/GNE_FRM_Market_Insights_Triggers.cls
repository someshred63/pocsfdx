/************************************************************
*  @author: James Hou (hou.james-chung@gene.com)
*  Date: 2013-5-23
*  Description: Trigger logic for Market_Insight_gne__c.
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public without sharing class GNE_FRM_Market_Insights_Triggers {
    private final Map<Id, Market_Insight_gne__c> oldMap;
    private final Map<Id, Market_Insight_gne__c> newMap;
    private final List<Market_Insight_gne__c> newObjs;
    private final Boolean isInsert;
    private final Boolean isUpdate;
    private final Boolean isDelete;
    private final Boolean isBulk;
/**
* Recursion handling
*/
    private static boolean done = false;

    public static boolean alreadyDone() {
        return done;
    }

    public static void setDone () {
        done = true;
    }
    
/**
* Custom Exception handling
*/
    private class InsightTriggerException extends Exception {}
    
/**
* The constructor
*
* @param xoldMap The old map from the trigger
* @param xnewObj The list of new objects from the trigger
* @param isBefore If the trigger is in before or after
*/
    public GNE_FRM_Market_Insights_Triggers(Map<Id, Market_Insight_gne__c> xoldMap, List<Market_Insight_gne__c> xnewObjs, Boolean isBefore) {
	    oldMap = xoldMap;
	    newObjs = xnewObjs;
	
	    if (!isBefore && newObjs != null) {
	        newMap = new Map<Id, Market_Insight_gne__c>(newObjs);
	    }
	
	    isDelete = (((newObjs == null || newObjs.isEmpty()) && isBefore) || ((newMap == null || newMap.isEmpty()) && !isBefore));
	    isUpdate = ! (isDelete || oldMap == null || oldMap.isEmpty());
	    isInsert = ! (isDelete || isUpdate);
	    isBulk = (newObjs != null && newObjs.size() > 1) ? true : false;
    
        if (isBefore && isUpdate && newObjs != null) {
            newMap = new Map<Id, Market_Insight_gne__c>(newObjs);
        }
    }

/**
* BEFORE UPDATE
*
* For Trending insights - maintain status of newly created trends.
*/
    public void maintainTrendRelationship() {
        if (isUpdate || (isUpdate && isBulk)) {
            for (Market_Insight_gne__c mi : newObjs) {
            	transient Id oldTrendId = oldMap.get(mi.Id).Known_Trend_gne__c;
            	// Newly Trending Insights
                if (oldTrendId == null && mi.Known_Trend_gne__c != null) {
                    mi.Status_gne__c = 'Trending';
                }
            }
        } else {
            return;
        }
    }

/**
* AFTER UPDATE
*
* Calculation of count to the Trend - Syncing from child to parent.
*/
    public void calculateInsightCountToTrend() {
        if (isUpdate || (isUpdate && isBulk)) {
		    Map<Id,Market_Insight_Trend_gne__c> trendMapToUpdate = new Map<Id,Market_Insight_Trend_gne__c>();
		    
		    for (Market_Insight_gne__c mi : newObjs) {
		    	// Limit scope to Make / Assign / edits made to insight after association
		    	if (mi.Status_gne__c != 'Archived' && mi.Known_Trend_gne__c != null)
		            trendMapToUpdate.put(mi.Known_Trend_gne__c, new Market_Insight_Trend_gne__c(Id = mi.Known_Trend_gne__c));
		        // Limit scope to unlinking - use the old values
		        if (mi.Status_gne__c != 'Archived' && oldMap.get(mi.Id).Known_Trend_gne__c != null && mi.Known_Trend_gne__c == null) {
		        	transient Id oldTrendId = oldMap.get(mi.Id).Known_Trend_gne__c;
		            trendMapToUpdate.put(oldTrendId, new Market_Insight_Trend_gne__c(Id = oldTrendId));
		        }
		    }
		    trendMapToUpdate.remove(null);
		    update trendMapToUpdate.values();
        } else {
            return;
        }
    }

/**
* Method to initiate trigger logic
*
* @param oldMap The old map from the trigger
* @param newObj The list of new objects from the trigger
* @param isBefore If the trigger is in before or after
*/
    public static void processTrigger(Map<Id, Market_Insight_gne__c> oldMap, List<Market_Insight_gne__c> newObj, Boolean isBefore) {
        final GNE_FRM_Market_Insights_Triggers myTrigger = new GNE_FRM_Market_Insights_Triggers(oldMap, newObj, isBefore);

        if (isBefore) {
            myTrigger.maintainTrendRelationship();
        }
        if (!isBefore) {
            myTrigger.calculateInsightCountToTrend();
        }
    }
}