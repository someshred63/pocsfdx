/************************************************************
*  @author: Jakub Lewandowski, Roche
*  Date: 2011-02-10
*  Description: 
*  This batch class processes Event Curriculum Objects to check if they are active or not
*  depending on Deactivation Date field
*
*  Modification History
*  Date        Name        Description
*                
*************************************************************/


global class GNE_Event_Curriculum_Batch implements Database.Batchable<SObject> {
	private String query;
	private String queueId;
	private List<Event_Curriculum_gne__c> eventCurriculumList;
	
	private void initiate(){
		queueId = ''; 
		// get queue to be set as owner of inactive event curriculum objects
		List<QueueSobject> queueSobjectList = [Select QueueId from QueueSobject where Queue.Name = 'No Users'];
	    if(queueSobjectList.size() > 0){
	        queueId = queueSobjectList[0].QueueId;
	    }

    	query = 'SELECT Id, Name, Deactivation_Date_gne__c ' 
		+ 'FROM Event_Curriculum_gne__c '
		+ 'WHERE Deactivation_Date_gne__c <= TODAY AND OwnerId != \'' +queueId+ '\'';	
    }

	public GNE_Event_Curriculum_Batch(){
    	initiate();   	
    }
	
	global Database.QueryLocator start(Database.batchableContext bc){    	      
        return Database.getQueryLocator(query);      
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope) {
		eventCurriculumList = (List<Event_Curriculum_gne__c>)scope;
		
		if(queueId != '') {
			for(Event_Curriculum_gne__c eventCurriculum : eventCurriculumList){
				system.debug('Deactivation Date = '+eventCurriculum.Deactivation_Date_gne__c);
				eventCurriculum.OwnerId = queueId;
			}
		}
		update(eventCurriculumList);
    }
    
    global void finish(Database.BatchableContext bc){
    }
}