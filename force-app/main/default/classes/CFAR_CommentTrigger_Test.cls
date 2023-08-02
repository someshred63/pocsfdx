@isTest(SeeAllData=true)
private class CFAR_CommentTrigger_Test {

    static testMethod void testCommentInsert() {
    	CFAR_Trial_Status_gne__c tStatus = [SELECT Id, Name FROM CFAR_Trial_Status_gne__c WHERE Name = 'Active Enrollment'];
    	CFAR_Trial_gne__c trial = new CFAR_Trial_gne__c(
    		Planned_Enrollment_gne__c = 100, 
    		Received_Date_gne__c = System.today().addDays(5),
    		Trial_Status_ref_gne__c = tStatus.Id,
			IIS_Portal_RO_Number_gne__c = 'RO-IIS-2017-12312'
    	);
    	insert trial;
		CFAR_Contact_gne__c contact = new CFAR_Contact_gne__c(
			Name = 'test1234xyz',
			Primary_Role_Function_gne__c = CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR
		);
		insert contact;
    	
        CFAR_Comment_gne__c comment = new CFAR_Comment_gne__c(
        	CFAR_Trial_ref_gne__c = trial.Id, 
        	Created_By_CFAR_Contact_ref_gne__c = contact.Id, 
        	Activity_Date_gne__c = System.today()
        );
        insert comment;
        
        List<CFAR_Comment_gne__c> insertedComments = [
        	SELECT Id, CFAR_Trial_ref_gne__c, Created_By_CFAR_Contact_ref_gne__c, Activity_Date_gne__c, Trial_Status_ref_gne__c, Trial_Status_ref_gne__r.Name
        	FROM CFAR_Comment_gne__c
        	WHERE Id = :comment.Id
        ];
        
        System.assertNotEquals(null, insertedComments);
        System.assertNotEquals(0, insertedComments.size());
        System.assertEquals('Active Enrollment', insertedComments[0].Trial_Status_ref_gne__r.Name);
    }
}