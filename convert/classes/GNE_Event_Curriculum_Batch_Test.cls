/************************************************************
*  @author: Jakub Lewandowski, Roche
*  Date: 2011-02-10
*  Description: Test for batch Event_curriculume_gne__c owner change
*  
*  Modification History
*  Date        Name        Description
*                
*************************************************************/

@isTest
private class GNE_Event_Curriculum_Batch_Test {
	static testMethod void ownerUpdateTest(){
		List<Event_Curriculum_gne__c> eventCurriculumList = new List<Event_Curriculum_gne__c>();
		String activeOwnerId = '';
		String inactiveOwnerId = '';
		
		// Create Event_Curriculum_gne__c test objects
		Event_Curriculum_gne__c activeEventCurriculum = new Event_Curriculum_gne__c(Name = 'Active Test Curriculum', Deactivation_Date_gne__c = System.today()+7);
		Event_Curriculum_gne__c inactiveEventCurriculum = new Event_Curriculum_gne__c(Name = 'Inactive Test Curriculum', Deactivation_Date_gne__c = System.today()-7);
		eventCurriculumList.add(activeEventCurriculum);
		eventCurriculumList.add(inactiveEventCurriculum);
		insert(eventCurriculumList);
		
		// TODO: REMOVE AFTER TEST
		for(Event_Curriculum_gne__c eventCurriculum : eventCurriculumList){
			System.debug('Cr Name: '+eventCurriculum.Name+', Cr Date: '+eventCurriculum.Deactivation_Date_gne__c);
		}
		
		// Set active owner id to current user
		activeOwnerId = UserInfo.getUserId();
		
		// Query inactive owner id by name
		List<QueueSobject> queueSobjectList = [Select QueueId from QueueSobject where Queue.Name = 'No Users'];
	    if(queueSobjectList.size() > 0){
	    	inactiveOwnerId = queueSobjectList[0].QueueId;
	    	System.debug('No Users queue Id: '+inactiveOwnerId);
	    }
		
		Test.startTest();
		
		Id batchinstanceid = database.executeBatch(new GNE_Event_Curriculum_Batch(), 100);
		
		Test.stopTest();
		
		// Query the database for the newly inserted records.
		List<Event_Curriculum_gne__c> insertedEventCurriculumList = [SELECT Name, OwnerId
	                                      								FROM Event_Curriculum_gne__c
	                                      								WHERE Id IN :eventCurriculumList];
		System.debug('insertedEventCurriculumList size: '+insertedEventCurriculumList.size());
		
		for(Event_Curriculum_gne__c insertedEventCurriculum : insertedEventCurriculumList){
			if(insertedEventCurriculum.Name == 'Active Test Curriculum') {
				System.debug('active test: '+insertedEventCurriculum.Name);
				System.assertEquals(activeOwnerId, insertedEventCurriculum.OwnerId);
			} else {
				System.debug('inactive test: '+insertedEventCurriculum.Name);
				System.assertEquals(inactiveOwnerId, insertedEventCurriculum.OwnerId);
			}
			
		}
	}
}