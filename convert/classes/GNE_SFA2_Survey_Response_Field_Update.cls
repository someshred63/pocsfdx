/************************************************************
*  @author: Sreedhar Karukonda
*  Date: 1/6/2013
*  Description: This class GNE_SFA2_Survey_Response_Field_Update handles field updates on Survey_Response_gne__c object on DML operations
*  This class is being used in GNE_SFA2_Survey_Trigger trigger
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/

public with sharing class GNE_SFA2_Survey_Response_Field_Update {
	
		// On Before insert method
	public static void OnBeforeInsert (Map<Id, Survey_Response_gne__c> oldSurveyRespMap,  List<Survey_Response_gne__c> newSurveyRespList){
		assignFullTitle(oldSurveyRespMap, newSurveyRespList );
		reportPreparation(oldSurveyRespMap, newSurveyRespList );
	}
	// On Before update method
	public static void OnBeforeUpdate (Map<Id, Survey_Response_gne__c> oldSurveyRespMap,  List<Survey_Response_gne__c> newSurveyRespList){
		assignFullTitle(oldSurveyRespMap, newSurveyRespList );
		reportPreparation(oldSurveyRespMap, newSurveyRespList );
	}
	// implemted based trigger Concatenate_Title_Section_On_Create_Update on Survey_Response_gne__c (before insert, before update)
	private static void assignFullTitle(map<id, Survey_Response_gne__c> oldRespMap, list<Survey_Response_gne__c> newRespList){
		for (Survey_Response_gne__c resp : newRespList) {
			if(resp.Category_gne__c==null) resp.Full_Title_gne__c=resp.Title_gne__c;
			else resp.Full_Title_gne__c=resp.Category_gne__c + ' ' + resp.Title_gne__c;
		}
	}
	//Implemented trigger Report_Preperation_gne on Survey_Response_gne__c (before insert, before update) {
	private static void reportPreparation(map<id, Survey_Response_gne__c> oldRespMap, list<Survey_Response_gne__c> newRespList){
		List<String> tempLabels = new List<String>();
		List<String> tempValues = new List<String>();
		List<String> SelectedLabels = new List<String>();
    	for(Survey_Response_gne__c record : newRespList) {
	       tempLabels.clear();
	       tempValues.clear();
	       SelectedLabels.clear();
	       record.Report_Value_gne__c = '$' ;
	       if(record.Type_gne__c == 'Labels and Values') {
	            if(record.Labels_gne__c != null)
	                tempLabels = record.Labels_gne__c.split(',');
	            else
	                tempLabels = new List<String>();
	            if(record.Values_gne__c != null)
	                tempValues = record.Values_gne__c.split(',');
	            else
	                tempValues = new List<String>();
	            Map<String,String> LabelsToValues = new Map<String,String>();   
	            for(Integer i=0;i<tempLabels.size();i++) {
	                LabelsToValues.put(tempLabels[i].trim(), String.valueOf(i));
	            }
	            if(record.Selected_Label_gne__c != null)
	                SelectedLabels = record.Selected_Label_gne__c.split(',');
	            else
	                SelectedLabels.add('No Answer');
	            for(String tmp : SelectedLabels) {
	                if(LabelsToValues.containsKey(tmp))
	                    record.Report_Value_gne__c += LabelsToValues.get(tmp) + ',';
	                else
	                    record.Report_Value_gne__c += 'No Answer';
	            }
	            if(record.Report_Value_gne__c.endsWith(','))
	                    record.Report_Value_gne__c = record.Report_Value_gne__c.substring(0, record.Report_Value_gne__c.lastIndexOf(','));
	        }
	        else if (record.Type_gne__c == 'List of Values') {
	            if(record.Selected_Label_gne__c != null) {
	                SelectedLabels = record.Selected_Label_gne__c.split(',');
	                for(String tmp : SelectedLabels) {
	                    record.Report_Value_gne__c += tmp + ',';
	                }
	                if(record.Report_Value_gne__c.endsWith(','))
	                        record.Report_Value_gne__c = record.Report_Value_gne__c.substring(0, record.Report_Value_gne__c.lastIndexOf(','));
	             }
	             else if (record.Response_Score_gne__c != null) {
	                record.Report_Value_gne__c += String.valueOf(Integer.valueOf(record.Response_Score_gne__c));
	             }
	        }
	        else if (record.Type_gne__c == 'Numeric') {
	            if(record.Response_Score_gne__c != null)
	                record.Report_Value_gne__c = String.valueOf(record.Response_Score_gne__c);
	            else
	                record.Report_Value_gne__c = 'No Answer';
	        }
	        else if (record.Type_gne__c == 'Free Text') {
	            record.Report_Value_gne__c = 'Free Text Answer';
	        }
	    	System.debug('record.Report_Value_gne__c : ' + record.Report_Value_gne__c);
	    if(record.Report_Value_gne__c != null && record.Report_Value_gne__c.startsWith('$'))
	        record.Report_Value_gne__c = record.Report_Value_gne__c.substring(1, record.Report_Value_gne__c.length());    
	    }
	}
}