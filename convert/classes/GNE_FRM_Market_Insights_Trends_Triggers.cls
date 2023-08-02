/************************************************************
*  @author: James Hou (hou.james-chung@gene.com)
*  Date: 2013-5-23
*  Description: Trigger logic for Market_Insight_Trend_gne__c.
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public without sharing class GNE_FRM_Market_Insights_Trends_Triggers {
    private final Map<Id, Market_Insight_Trend_gne__c> oldMap;
    private final Map<Id, Market_Insight_Trend_gne__c> newMap;
    private final List<Market_Insight_Trend_gne__c> newObjs;
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
    private class TrendTriggerException extends Exception {}
    
/**
* The constructor
*
* @param xoldMap The old map from the trigger
* @param xnewObj The list of new objects from the trigger
* @param isBefore If the trigger is in before or after
*/
    public GNE_FRM_Market_Insights_Trends_Triggers(Map<Id, Market_Insight_Trend_gne__c> xoldMap, List<Market_Insight_Trend_gne__c> xnewObjs, Boolean isBefore) {
        oldMap = xoldMap;
        newObjs = xnewObjs;
    
        if (!isBefore && newObjs != null) {
            newMap = new Map<Id, Market_Insight_Trend_gne__c>(newObjs);
        }
    
        isDelete = (((newObjs == null || newObjs.isEmpty()) && isBefore) || ((newMap == null || newMap.isEmpty()) && !isBefore));
        isUpdate = ! (isDelete || oldMap == null || oldMap.isEmpty());
        isInsert = ! (isDelete || isUpdate);
        isBulk = (newObjs != null && newObjs.size() > 1) ? true : false;
        
        if (isBefore && isUpdate && newObjs != null) {
            newMap = new Map<Id, Market_Insight_Trend_gne__c>(newObjs);
        }
    }

/**
* BEFORE UPDATE
* BEFORE INSERT
*
* Calculation count of Insight associated to this Trend - Syncing from parent to child.
*/
    public void calculateInsightCount() {
        if (isUpdate || (isUpdate && isBulk)) {
            for (Market_Insight_Trend_gne__c miTrend : [SELECT Id,(SELECT Id FROM Market_Insights__r) FROM Market_Insight_Trend_gne__c WHERE ID =: newObjs]) {
                newMap.get(miTrend.Id).Insight_Count_gne__c = miTrend.Market_Insights__r.size();
            }
        } else if (isInsert || (isInsert && isBulk)) {
            for (Market_Insight_Trend_gne__c miTrend : newObjs)
                miTrend.Insight_Count_gne__c = 0;
        } else {
            return;
        }
    }

/**
* BEFORE UPDATE
*
* Maintain the minimum number of insights required to make a trend.
*/
	public void maintainMinimumInsights() {
		if (isUpdate || (isUpdate && isBulk)) {
			for (Market_Insight_Trend_gne__c miTrend : newObjs) {
				if (oldMap.get(miTrend.Id).Insight_Count_gne__c >=1 && miTrend.Insight_Count_gne__c == 0) {
					transient String msg = 'Trends must always have one or more Insights';
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, msg));
					throw new TrendTriggerException(msg);
                }
			}
		} else {
			return;
		}
	}

/**
* BEFORE UPDATE
*
* Set Archived Date for Trend
*/
    public void setArchivedDate() {
    	if (isUpdate || (isUpdate && isBulk)) {
    		for (Market_Insight_Trend_gne__c miTrend : newObjs) {
    			if (miTrend.Status_gne__c == 'Archived' && miTrend.Trend_Archived_Date_gne__c == null)
    			    miTrend.Trend_Archived_Date_gne__c = system.today();
    		}
    	} else {
    		return;
    	}
    }
    
/**
* AFTER UPDATE
*
* Archiving the child Insights when set to 'Archived'.
*/
    public void archiveChildrenInsights() {
        if (isUpdate || (isUpdate && isBulk)) {
            List<Market_Insight_Trend_gne__c> trendListToUpdate = new List<Market_Insight_Trend_gne__c>();
            List<Market_Insight_gne__c> miListToUpdate = new List<Market_Insight_gne__c>();
            
            for (Market_Insight_Trend_gne__c miTrend : newObjs) {
                if (miTrend.Status_gne__c == 'Archived' && miTrend.Trend_Archived_Date_gne__c != null) // limit scope of processing
                    trendListToUpdate.add(miTrend);
            }
            if (trendListToUpdate == null) {
                return;
            } else {
                for (Market_Insight_gne__c mi : [SELECT Id FROM Market_Insight_gne__c WHERE Known_Trend_gne__c =: trendListToUpdate]) {
                    mi.Status_gne__c = 'Archived';
                    mi.Insight_Archived_Date_gne__c = system.today();
                    miListToUpdate.add(mi);
                }
                update miListToUpdate;
            }
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
    public static void processTrigger(Map<Id, Market_Insight_Trend_gne__c> oldMap, List<Market_Insight_Trend_gne__c> newObj, Boolean isBefore) {
        final GNE_FRM_Market_Insights_Trends_Triggers myTrigger = new GNE_FRM_Market_Insights_Trends_Triggers(oldMap, newObj, isBefore);

        if (isBefore) {
            myTrigger.calculateInsightCount();
            myTrigger.maintainMinimumInsights();
            myTrigger.setArchivedDate();
        }
        if (!isBefore) {
            myTrigger.archiveChildrenInsights();
        }
    }
}