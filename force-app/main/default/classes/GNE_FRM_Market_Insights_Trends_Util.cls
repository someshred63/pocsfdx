/************************************************************
*  @author: Michal Zaganczyk (michal.zaganczyk@contractors.roche.com)
*  Date: 2013-5-21
*  Description: Utility class providing the functionality of loading, saving and checking 
*               the associations between Market Insights and Market Insight Trends.
*  
*  Modification History
*  Date        Name        Description
*  2013-6-4    James Hou   - Verbiage for Error msg (invalid Insights for Make / Assign etc).
*                          - Verbiage for Error msg 'Market Insight' -> 'Insight' (refer to it without 'Market').
*  2013-6-7    James Hou   - Trend.Name has been prepended with 'T' - adjusted Trend.Name exact search.
*        
*************************************************************/
public with sharing class GNE_FRM_Market_Insights_Trends_Util {
	
	/********************************************* Common utility methods *********************************************/
	
	/**
	 * Collects the names of records from the list passed as the input parameter and returns them in (optionally 
	 * alphabetically sorted) list of Strings.
	 * The "Name" field has to be fetched for all records of the list passed as the the method parameter.
	 * 
	 * @param records List of records to extract their names.
	 * @param sortNames Decides whether or not the output list has to be sorted.
	 * @return List of record names.
	 */
	public static List<String> getRecordNames(List<SObject> records, Boolean sortNames) {
		List<String> result = new List<String>();
		if (null != records) {
			for (SObject o : records) {
				if (null != o) {
					result.add(String.valueOf(o.get('Name')));
				} else {
					result.add(String.valueOf((String) null));
				}
			}
			if (sortNames) {
				result.sort();
			}
		}
		return result;
	}
	
	/**
	 * Collects the Ids of records from the list passed as the input parameter and returns them as a List.
	 * The "Id" field has to be fetched for all records of the list passed as the the input parameter.
	 * 
	 * @param records List of records to extract their Ids.
	 * @return List of record Ids (can be empty if input parameter list was empty or null).
	 */
	public static List<Id> getRecordIdsAsList(List<SObject> records) {
		List<Id> result = new List<Id>();
		if (null != records) {
			for (SObject o : records) {
				result.add(o.Id);
			}
		}
		return result;
	}
	
	/**
	 * Collects the Ids of records from the list passed as the input parameter and returns them as a Set.
	 * This version returns Set and uses the principle of uniqueness of elements in a Set.
	 * The "Id" field has to be fetched for all records of the list passed as the the input parameter.
	 * 
	 * @param records List of records to extract their Ids.
	 * @return Set of record Ids (can be empty if input parameter list was empty or null).
	 */
	public static Set<Id> getRecordIdsAsSet(List<SObject> records) {
		return new Set<Id>(getRecordIdsAsList(records));
	}
	
	/**
	 * Parses an input string containing the Ids separated by a separation sequence and returns as a list 
	 * (allows for duplicate values).
	 * 
	 * @param value String value containing the Ids separated by the separation sequence.
	 * @param separator String or character used as a separation sequence between the elements.
	 * @return List of Ids (can be empty).
	 */
	public static List<Id> parseRecordIdsIntoList(String value, String separator) {
		List<Id> result = new List<Id>();
		if (String.isNotBlank(value)) {
			for (String idString : value.trim().split(separator)) {
				result.add(idString.trim());
			}
		}
		return result;
	}
	
	/**
	 * Parses an input string containing the Ids separated by a default separation sequence (comma) and returns 
	 * as a list (allows for duplicate values).
	 * 
	 * @param value String value containing the Ids separated by the separation sequence.
	 * @return List of Ids (can be empty).
	 */
	public static List<Id> parseRecordIdsIntoList(String value) {
		return parseRecordIdsIntoList(value, ',');
	}
	
	/**
	 * Parses an input string containing the Ids separated by a separation sequence and returns as a set 
	 * (to provide uniqueness of values).
	 * 
	 * @param value String value containing the Ids separated by the separation sequence.
	 * @param separator String or character used as a separation sequence between the elements.
	 * @return Set of Ids (can be empty).
	 */
	public static Set<Id> parseRecordIdsIntoSet(String value, String separator) {
		return new Set<Id>(parseRecordIdsIntoList(value, separator));
	}
	
	/**
	 * Parses an input string containing the Ids separated by a default separation sequence (comma) and returns 
	 * as a set (to provide uniqueness of values).
	 * 
	 * @param value String value containing the Ids separated by the separation sequence.
	 * @return Set of Ids (can be empty).
	 */
	public static Set<Id> parseRecordIdsIntoSet(String value) {
		return parseRecordIdsIntoSet(value, ',');
	}
	
	
	public static String joinRecordIds(Set<Id> ids, String separator) {
		return String.join(new List<Id>(ids), separator);
	}
	
	
	public static String joinRecordIds(Set<Id> ids) {
		return joinRecordIds(ids, ',');
	}
	
	/******************************** Common data-load methods for Trends and Insights ********************************/
	
	/**
	 * Loads the Trend records having given Ids and returns them as a List (to maintain order by Id). 
	 * Returns an empty List if there was no Trend records with any of given Ids, or the passed set of Ids was 
	 * null or empty.
	 * 
	 * @param marketInsightTrendIds Set of Trend Ids to load (passing empty set and null value allowed).
	 * @return A List of Trend records as elements (can be empty).
	 */
	public static List<Market_Insight_Trend_gne__c> loadMarketInsightTrendsAsList(Set<Id> marketInsightTrendIds) {
		if ((null == marketInsightTrendIds) || (marketInsightTrendIds.isEmpty())) {
			return new List<Market_Insight_Trend_gne__c>();
		} else {
			return [
				SELECT
					Id,
					Name,
					CreatedDate,
					CreatedBy.Id,
					CreatedBy.Name,
					LastModifiedDate,
					LastModifiedBy.Id,
					LastModifiedBy.Name,
					Owner.Id,
					Owner.Name,
					Trend_Name_gne__c,
					Status_gne__c,
					Creator_Role_gne__c,
					Insight_Count_gne__c,
					Trend_Archived_Date_gne__c
				FROM
					Market_Insight_Trend_gne__c
				WHERE
					Id IN :marketInsightTrendIds
				ORDER BY
					Id ASC
			];
		}
	}
	
	/**
	 * Loads the Trend records having given Ids and returns them as a map (to allow to perform fast search by Id). 
	 * Returns an empty map if there was no Trend records with any of given Ids, or the passed set of Ids was 
	 * null or empty.
	 * 
	 * @param marketInsightTrendIds Set of Trend Ids to load (passing empty set and null value allowed).
	 * @return A map of Trend records as map values and their Ids as map keys (can be empty).
	 */
	public static Map<Id, Market_Insight_Trend_gne__c> loadMarketInsightTrendsAsMap(Set<Id> marketInsightTrendIds) {
		return new Map<Id, Market_Insight_Trend_gne__c>(loadMarketInsightTrendsAsList(marketInsightTrendIds));
	}
	
	/**
	 * Loads the Trend record having given Id. Returns null if there was no such Trend record with given Id, 
	 * or the passed Id was null.
	 * 
	 * @param marketInsightTrendId The Id of the Trend record to load (passing null value allowed).
	 * @return Trend record with given Id or null if there was no such record or null value for Id was passed.
	 */
	public static Market_Insight_Trend_gne__c loadMarketInsightTrend(Id marketInsightTrendId) {
		return (null == marketInsightTrendId) ? null : loadMarketInsightTrendsAsMap(
			new Set<Id>{marketInsightTrendId}).get(marketInsightTrendId);
	}
	
	/**
	 * Loads the Market Insight records having given Ids and returns them as a List (to maintain order by Id).
	 * Returns an empty List if there was no Market Insight records with any of given Ids, or the passed 
	 * set of Ids was null or empty.
	 * 
	 * @param marketInsightIds Set of Market Insight Ids to load (passing empty set and null value allowed).
	 * @return A List of Market Insight records as map values and their Ids as map keys (can be empty).
	 */
	public static List<Market_Insight_gne__c> loadMarketInsightsAsList(Set<Id> marketInsightIds) {
		if ((null == marketInsightIds) || (marketInsightIds.isEmpty())) {
			return new List<Market_Insight_gne__c>();
		} else {
			return [
				SELECT
					Id,
					Name,
					CreatedDate,
					CreatedBy.Id,
					CreatedBy.Name,
					LastModifiedDate,
					LastModifiedBy.Id,
					LastModifiedBy.Name,
					Owner.Id,
					Owner.Name,
					Master_Category_gne__c,
					Product_gne__c,
					Insight_Submitted_Date_gne__c,
					Account_frm_gne__c,
					Account_State_gne__c,
					Known_Trend_gne__c,
					Status_gne__c
				FROM
					Market_Insight_gne__c
				WHERE
					Id IN :marketInsightIds
				ORDER BY
					Id ASC
			];
		}
	}
	
	/**
	 * Loads the Market Insight records having given Ids and returns them as a map (to allow to perform fast search 
	 * by Id). Returns an empty map if there was no Market Insight records with any of given Ids, or the passed 
	 * set of Ids was null or empty.
	 * 
	 * @param marketInsightIds Set of Market Insight Ids to load (passing empty set and null value allowed).
	 * @return A map of Market Insight records as map values and their Ids as map keys (can be empty).
	 */
	public static Map<Id, Market_Insight_gne__c> loadMarketInsightsAsMap(Set<Id> marketInsightIds) {
		return new Map<Id, Market_Insight_gne__c>(loadMarketInsightsAsList(marketInsightIds));
	}
	
	/**
	 * Loads the Market Insight record having given Id. Returns null if there was no Market Insight record with 
	 * given Id, or the passed Id was null.
	 * 
	 * @param marketInsightTrendId The Id of the Market Insight record to load (passing null value allowed).
	 * @return Market Insight record with given Id or null if there was no such record or null value for Id was passed.
	 */
	public static Market_Insight_gne__c loadMarketInsight(Id marketInsightId) {
		return (null == marketInsightId) ? null : loadMarketInsightsAsMap(new Set<Id>{marketInsightId}).get(marketInsightId);
	}
	
	/**
	 * Loads all the Market Insight records associated with the Trend of having given trendId and returns them 
	 * as List (to maintain order by Id). Returns an empty List if there was no MarketInsight records 
	 * assigned to the Trend of given Id, or the passed marketInsightTrendId was null.
	 * 
	 * @param marketInsightTrendId The Id of the Trend (passing null value allowed).
	 * @return A List of Market Insight records with their Ids as keys (can be empty).
	 */
	public static List<Market_Insight_gne__c> loadMarketInsightsAssignedToTrendAsList(Id marketInsightTrendId) {
		if (null == marketInsightTrendId) {
			return new List<Market_Insight_gne__c>();
		} else {
			return [
				SELECT
					Id,
					Name,
					CreatedDate,
					CreatedBy.Id,
					CreatedBy.Name,
					LastModifiedDate,
					LastModifiedBy.Id,
					LastModifiedBy.Name,
					Owner.Id,
					Owner.Name,
					Master_Category_gne__c,
					Product_gne__c,
					Insight_Submitted_Date_gne__c,
					Account_frm_gne__c,
					Account_State_gne__c,
					Known_Trend_gne__c
				FROM
					Market_Insight_gne__c
				WHERE
					Known_Trend_gne__c = :marketInsightTrendId
				ORDER BY
					Id ASC
			];
		}
	}
	
	/**
	 * Loads all the Market Insight records associated with the Trend of having given trendId and returns them 
	 * as map (to allow to perform fast search by Id). Returns an empty map if there was no MarketInsight records 
	 * assigned to the Trend of given Id, or the passed marketInsightTrendId was null.
	 * 
	 * @param marketInsightTrendId The Id of the Trend (passing null value allowed).
	 * @return A map of Market Insight records with their Ids as keys (can be empty).
	 */
	public static Map<Id, Market_Insight_gne__c> loadMarketInsightsAssignedToTrendAsMap(Id marketInsightTrendId) {
		return new Map<Id, Market_Insight_gne__c>(loadMarketInsightsAssignedToTrendAsList(marketInsightTrendId));
	}
	
	/*************************************** Trend Search methods *****************************************************/
	
	/**
	 * Finds the Trend records satisfying the search criteria and returns them as a list (to preserve the order of rows).
	 * Returns an empty list if there was no Trend records satisfying the search criteria or the search mode was unknown.
	 * 
	 * Depending on the criteria mode parameter, the method considers the row as matching when:
	 * 		criteriaMode = 0 -	the Trend.Name (11 characters, including 'T' prefix) has the exact match, the passed search criteria is 
	 * 							considered as a last fragment of the Trend.Name (will be right-padded with zeroes up 
	 * 							to ten characters. The 'T' will be added in SOQL).
	 * 		criteriaMode = 1 - 	Trend.Trend_Name_gne__c field contains the passed criteria string.
	 * 
	 * @param criteriaMode Search mode: 0 for search by Trend.Name field, 1 for search by Trend.Trend_Name_gne__c field.
	 * @param trendCriteria Criteria to apply for trend search: Trend Number or Trend Name (depends on criteriaMode param).
	 * @param rowsLimit Limits the result to given number of rows.
	 * @return A list of Trend records (can be empty).
	 */
	public static List<Market_Insight_Trend_gne__c> findMarketInsightTrends(
		Integer criteriaMode, String trendCriteria, Integer rowsLimit) {
		if (0 == criteriaMode) {
			return findMarketInsightTrendsByTrendNumber(trendCriteria, rowsLimit);
		} else if (1 == criteriaMode) {
			return findMarketInsightTrendsByTrendName(trendCriteria, rowsLimit);
		} else {
			return new List<Market_Insight_Trend_gne__c>();
		}
	}
	
	/**
	 * Finds the Trend records satisfying the search criteria and returns them as a list (to preserve the order of rows).
	 * Returns an empty list if there was no Trend records satisfying the search criteria.
	 * 
	 * This version is looking for the exact match of the Trend.Name (11 characters, including 'T' prefix), the passed search criteria is 
	 * considered as a last fragment of the Trend.Name (will be right-padded with zeroes up to ten characters. The 'T' will be added in SOQL).
	 * 
	 * @param trendNumber Trend Number to match (will be right-padded with zeroes up to ten characters)
	 * @param rowsLimit Limits the result to given number of rows.
	 * @return A list of Trend records (can be empty).
	 */
	public static List<Market_Insight_Trend_gne__c> findMarketInsightTrendsByTrendNumber(String trendNumber, Integer rowsLimit) {
		if (String.isBlank(trendNumber) || (rowsLimit < 1)) {
			return new List<Market_Insight_Trend_gne__c>();
		} else {
			trendNumber = trendNumber.replaceAll('\\s', '').leftPad(10).replace(' ', '0');
			List<String> allowedStatuses = new List<String>{'Actionable', 'Developing'};
			return [
				SELECT
					Id,
					Name,
					CreatedDate,
					CreatedBy.Id,
					CreatedBy.Name,
					LastModifiedDate,
					LastModifiedBy.Id,
					LastModifiedBy.Name,
					Owner.Id,
					Owner.Name,
					Trend_Name_gne__c,
					Status_gne__c,
					Creator_Role_gne__c,
					Insight_Count_gne__c,
					Trend_Archived_Date_gne__c
				FROM
					Market_Insight_Trend_gne__c
				WHERE
					Name =: 'T' + trendNumber
					AND Status_gne__c IN :allowedStatuses
				ORDER BY
					CreatedDate DESC,
					Id DESC
				LIMIT :rowsLimit
			];
		}
	}
	
	/**
	 * Finds the Trend records satisfying the search criteria and returns them as a list (to preserve the order of rows).
	 * Returns an empty list if there was no Trend records satisfying the search criteria.
	 * 
	 * @param trendName Trend Name to match
	 * @param rowsLimit Limits the result to given number of rows.
	 * @return A list of Trend records (can be empty).
	 */
	public static List<Market_Insight_Trend_gne__c> findMarketInsightTrendsByTrendName(String trendName, Integer rowsLimit) {
		if (String.isBlank(trendName) || (rowsLimit < 1)) {
			return new List<Market_Insight_Trend_gne__c>();
		} else {
			trendName = '%' + trendName + '%';
			List<String> allowedStatuses = new List<String>{'Actionable', 'Developing'};
			return [
				SELECT
					Id,
					Name,
					CreatedDate,
					CreatedBy.Id,
					CreatedBy.Name,
					LastModifiedDate,
					LastModifiedBy.Id,
					LastModifiedBy.Name,
					Owner.Id,
					Owner.Name,
					Trend_Name_gne__c,
					Status_gne__c,
					Creator_Role_gne__c,
					Insight_Count_gne__c,
					Trend_Archived_Date_gne__c
				FROM
					Market_Insight_Trend_gne__c
				WHERE
					Trend_Name_gne__c LIKE :trendName
					AND Status_gne__c IN :allowedStatuses
				ORDER BY
					CreatedDate DESC,
					Id DESC
				LIMIT :rowsLimit
			];
		}
	}
	
	/************************************* Trend assignment utility methods *******************************************/
	
	/**
	 * Enum for available trend assignment operations to execute on Market Insight records.
	 */
	private enum TrendAssignmentOperationType {
		/**
		 * Make a new Trend out of the Market Insights
		 */
		MAKE,
		
		/**
		 * Assign the Market Insights to an existing Trend
		 */
		ASSIGN
	}
	
	/**
	 * Custom exception class used to notify that creating a Trend or assigning Market Insights to the existing Trend 
	 * is not possible due to current conditions (ie Market Insights or Trend statuses).
	 */
	private class TrendAssignmentAbilityException extends Exception {}
	
	/**
	 * Qualifies the Market Insights records from the source Map to one of the two other maps, one for valid and 
	 * second for invalid, based on the ability to execute operation of making a Trend or assigning to a Trend.
	 * The Market Insight records are considered as possible to make or to assign to a Trend only if they are 
	 * not yet assigned to some other trend and only if they are in the 'Monitoring' status.
	 * 
	 * @param marketInsightsMap Source Market Insights records map to qualify its elements to one of two other maps.
	 * @param validMarketInsightsMap Output map filled with these Market Insight records from the source, which are 
	 *                               VALID to assign to, or make a Trend.
	 * @param invalidMarketInsightsMap Output map filled with these Market Insight records from the source, which are 
	 *                                 INVALID to assign to, or make a Trend.
	 */
	private static void qualifyMarketInsightsForTrendAssignment(
		Map<Id, Market_Insight_gne__c> marketInsightsMap,
		Map<Id, Market_Insight_gne__c> validMarketInsightsMap, 
		Map<Id, Market_Insight_gne__c> invalidMarketInsightsMap) {
		
		/* Clear the destination maps (for sanity) */
		validMarketInsightsMap.clear();
		invalidMarketInsightsMap.clear();
		
		/* Iterate over the source map and qualify to appropriate destination map based on status */
		for (Id id : marketInsightsMap.keySet()) {
			Market_Insight_gne__c mi = marketInsightsMap.get(id);
			if ((null != mi) && (mi.Known_Trend_gne__c == null) && (mi.Status_gne__c == 'Monitoring')) {
				validMarketInsightsMap.put(id, mi);
			} else {
				invalidMarketInsightsMap.put(id, mi);
			}
		}
	}
	
	/**
	 * Validates the ability to execute operation of making a Trend or assigning to a Trend for the collection of 
	 * Market Insights. The Market Insight records are considered as possible to make or to assign to a Trend only 
	 * if they are not yet assigned to some other trend and only if they are in the 'Monitoring' status. If they
	 * match either of those two criteria - it is known as "Trending" (the same as the status).
	 * 
	 * This version operates on the fetched records. To be sure, that the results are correct, the records 
	 * should not be modified by code (need to have the original state from database) and should be fetched as late as
	 * possible. Consider using the version using the set of Market Insight Ids to check (fetches records for this 
	 * purpose) if you can.
	 * 
	 * Throws the TrendAssignmentAbilityException with detailed description of reason when one of the insights is 
	 * already assigned to some other trend or is in status other than 'Monitoring'.
	 * 
	 * @param operationType Assignment operation type to check
	 * @param marketInsights Map of Market Insights records to check
	 */
	private static void validateMarketInsightsAssignmentAbility(
		TrendAssignmentOperationType operationType, Map<Id, Market_Insight_gne__c> marketInsights) {
		
		/* Sanity check */
		if ((null == marketInsights) || (marketInsights.isEmpty())) {
			throw new TrendAssignmentAbilityException('No Insight records selected.');
		}
			
		/* Create maps to store during qualification the records invalid and valid for asignment */
		Map<Id, Market_Insight_gne__c> validMarketInsights = new Map<Id, Market_Insight_gne__c>();
		Map<Id, Market_Insight_gne__c> invalidMarketInsights = new Map<Id, Market_Insight_gne__c>();
		
		/* Perform qualification of records to appropriate map */
		qualifyMarketInsightsForTrendAssignment(marketInsights, validMarketInsights, invalidMarketInsights);
		
		/* Check if any of the Insight was qualified as invalid for assignment operation */
		if (invalidMarketInsights.size() > 0) {
			String errorMessage = 'contain records which are already "Trending".'
				+ ' Invalid Insight(s) to Make or Assign to Trend are: ' 
				+ String.join(getRecordNames(invalidMarketInsights.values(), true), ', ') 
				+ '. Please remove them from selection.';
			if (operationType == TrendAssignmentOperationType.MAKE) {
				errorMessage = 'Insight(s) selected to Make a Trend ' + errorMessage;
			} else if (operationType == TrendAssignmentOperationType.ASSIGN) {
				errorMessage = 'Insight(s) selected to Assign to Trend ' + errorMessage;
			}
			throw new TrendAssignmentAbilityException(errorMessage);
		}
		
		/* Check if there is at least one Insight qualified as valid (sanity check) */
		if (validMarketInsights.size() < 1) {
			String errorMessage = 'the Insights list should contain at least one record in "Monitoring" status. ';
			if (operationType == TrendAssignmentOperationType.MAKE) {
				errorMessage = 'To Make a Trend, ' + errorMessage;
			} else if (operationType == TrendAssignmentOperationType.ASSIGN) {
				errorMessage = 'To Assign to Trend, ' + errorMessage;
			}
			throw new TrendAssignmentAbilityException(errorMessage);
		}
	}
	
	/**
	 * Validates the ability to execute operation of making a Trend or assigning to a Trend for the collection of 
	 * Market Insights. The Market Insight records are considered as possible to make or to assign to a Trend only 
	 * if they are not yet assigned to some other trend and only if they are in the 'Monitoring' status.
	 * 
	 * This version loads the Market Insights records for the purpose of validation.
	 * 
	 * Throws the TrendAssignmentAbilityException with detailed description of reason when one of the insights is 
	 * already assigned to some other trend or is in status other than 'Monitoring'.
	 * 
	 * @param operationType Assignment operation type to check
	 * @param marketInsightsIds Set of Market Insights Ids to check
	 */
	public static void validateMarketInsightsAssignmentAbility(
		TrendAssignmentOperationType operationType, Set<Id> marketInsightsIds) {
		
		/* Sanity check */
		if ((null == marketInsightsIds) || (marketInsightsIds.isEmpty())) {
			throw new TrendAssignmentAbilityException('No Insights records selected.');
		}
		
		/* Load the records in their current state and check if all records wanted have been fetched */
		Map<Id, Market_Insight_gne__c> marketInsights = loadMarketInsightsAsMap(marketInsightsIds);
		if (marketInsights.size() != marketInsightsIds.size()) {
			throw new TrendAssignmentAbilityException('Cannot select all Insights records.');
		}
		
		/* Perform validation */
		validateMarketInsightsAssignmentAbility(operationType, marketInsights);
	}
	
	/**
	 * Validates the ability of making a Trend from the collection of Market Insights. 
	 * The Market Insight records are considered as possible to make a Trend only if they are not yet assigned 
	 * to some other trend and only if they are in the 'Monitoring' status.
	 * 
	 * Throws the TrendAssignmentAbilityException with detailed description of reason when one of the insights 
	 * is already assigned to some other trend or is in status other than 'Monitoring'.
	 * 
	 * @param marketInsightsIds Set of Market Insights Ids to check their ability to make a Trend
	 */
	public static void validateMarketInsightsAbilityToMakeTrend(Set<Id> marketInsightsIds) {
		validateMarketInsightsAssignmentAbility(TrendAssignmentOperationType.MAKE, marketInsightsIds);
	}
	
	/**
	 * Validates the ability of assigning to the existing Trend for the collection of Market Insights. 
	 * The Market Insight records are considered as possible to assign to a Trend only if they are not yet assigned 
	 * to some other trend and only if they are in the 'Monitoring' status.
	 * 
	 * Throws the TrendAssignmentAbilityException with detailed description of reason when one of the insights 
	 * is already assigned to some other trend or is in status other than 'Monitoring'.
	 * 
	 * @param marketInsightsIds Set of Market Insights Ids to check their ability to assign an existing Trend
	 */
	public static void validateMarketInsightsAbilityToAssignToTrend(Set<Id> marketInsightsIds) {
		validateMarketInsightsAssignmentAbility(TrendAssignmentOperationType.ASSIGN, marketInsightsIds);
	}
	
	/**
	 * Checks the Trend record if it is valid to assing the Market Insights to.
	 * 
	 * This version is private because it operates on the record.
	 *
	 * @param trend Trend record to validate
	 */
	private static void validateTrendAbilityToAssignMarketInsights(Market_Insight_Trend_gne__c trend) {
		/* Sanity check */
		if (null == trend) {
			throw new TrendAssignmentAbilityException('No Market Insight Trend to validate');
		}
		/* Validate the trend, based on status */
		if (!(trend.Status_gne__c == 'Developing' || trend.Status_gne__c == 'Actionable')) {
			throw new TrendAssignmentAbilityException('To assign Insights to this Trend, the Trend needs to have' 
				+ ' the status of "Developing" or "Actionable", but this Trend has status of "' 
				+ String.valueOf(trend.Status_gne__c) + '".');
		}
	}
	
	/**
	 * Checks the Trend record with given Id if it is valid to assing the Market Insights to.
	 * 
	 * This version is public because it fetches the record to check.
	 * 
	 * @param trend Trend record Id to validate
	 */
	public static void validateTrendAbilityToAssignMarketInsights(Id trendId) {
		Market_Insight_Trend_gne__c trend = loadMarketInsightTrend(trendId);
		validateTrendAbilityToAssignMarketInsights(trend);
	}
	
	/**
	 * Assigns all the Market Insights from the given list to a Trend (can be null to unassign).
	 * 
	 * This version is private because it operates on the records.
	 * 
	 * @param marketInsights List of Market Insights which we want to be assigned with a given Trend.
	 * @param trend The Trend to assign the Market Insights to (allows null reference to remove the assignment).
	 */
	private static void assignMarketInsightsToTrend(
		Map<Id, Market_Insight_gne__c> marketInsights, Market_Insight_Trend_gne__c trend) {
		
		/* Sanity check, exit when there are no Insight records to assign */
		if ((null == marketInsights) || (marketInsights.size() < 1))
			return;
		
		/* Check Trend, but only if the Trend was passed (we also cover the case of unassign operation) */
		if (null != trend) {
			validateTrendAbilityToAssignMarketInsights(trend);
		}
		
		/* Check Market Insights, but only if the Trend was passed (no need to verify in case of unassign operation) */
		if (null != trend) {
			validateMarketInsightsAssignmentAbility(TrendAssignmentOperationType.ASSIGN, marketInsights);
		}
		
		/* Update Market Insights */
		for (Market_Insight_gne__c mi : marketInsights.values()) {
			if (null != mi) {
				mi.Known_Trend_gne__c = (null != trend) ? trend.Id : null;
				mi.Status_gne__c = (null != trend) ? 'Trending' : 'Monitoring';
			}
		}
		update marketInsights.values();
	}
	
	/**
	 * Assigns all the Market Insights from the given list to a Trend (can be null to unassign).
	 * 
	 * This version is public because it fetches the records to check.
	 * 
	 * @param marketInsightsIds List of Market Insights Ids which we want to be assigned with a given Trend.
	 * @param trend The Id of the Trend to assign the Market Insights to (allows null reference to remove the assignment).
	 */
	public static void assignMarketInsightsToTrend(Set<Id> marketInsightsIds, Id trendId) {
		
		/* Sanity check, exit when there are no Insight records to assign */
		if ((null == marketInsightsIds) || (marketInsightsIds.size() < 1))
			return;
		
		/* Fetch the Trend record, can be null (because we also cover the case of unassign operation) */
		Market_Insight_Trend_gne__c trend = loadMarketInsightTrend(trendId);
		
		/* Load the Market Insight records in their current state and check if all records wanted have been fetched */
		Map<Id, Market_Insight_gne__c> marketInsights = loadMarketInsightsAsMap(marketInsightsIds);
		if (marketInsights.size() != marketInsightsIds.size()) {
			throw new TrendAssignmentAbilityException('Cannot select all Insights records.');
		}
		
		/* Call method operating on records */
		assignMarketInsightsToTrend(marketInsights, trend);
	}
}