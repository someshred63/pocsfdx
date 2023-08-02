@isTest(seeAllData=false)
public with sharing class CFAR_Comment_ControllerTest {

	static testMethod void testCreateNewCommentAndSort() {
		User cfarUser = CFAR_TestUtils.createTestAverageUser();
        System.runAs(cfarUser) {
        	CFAR_Contact_gne__c cnt = CFAR_TestUtils.createTestContactForUser(cfarUser, 'CPL = Clinical Program Leader');
        	CFAR_Trial_gne__c trial = CFAR_TestUtils.createTestTrial();
        	Test.startTest();
            CFAR_Comment_Controller ctrl = new CFAR_Comment_Controller();
            ctrl.trialWrapper.innerObject = trial;
            ctrl.createNewComment();
            //5 options: --None--, cnt and 3 contacts created by createTestTrialMethod (Primary Contact, Investigator, MSL)
            System.assertEquals(5, ctrl.getContactSearchList1().size());
            System.assertEquals(0, ctrl.getContactSearchList2().size());
            System.assertEquals(0, ctrl.getContactSearchList3().size());
            System.assertEquals(0, ctrl.getContactSearchList4().size());
            ctrl.cancelNewComment();
            ctrl.createNewComment();
            ctrl.newComment.Comments_gne__c = 'abc';
            Date todayDate = ctrl.newComment.Activity_Date_gne__c;
            ctrl.submitNewComment();
            System.assertEquals(1, ctrl.stdSetControllerComment.getResultSize());
            System.assertEquals(((CFAR_Comment_gne__c)ctrl.getObjectListComment().get(0).innerObject).Id, ((CFAR_Comment_gne__c)ctrl.stdSetControllerComment.getRecords().get(0)).Id);
            System.assertEquals(((CFAR_Comment_gne__c)ctrl.getObjectListComment().get(0).innerObject).Id, ((CFAR_Comment_gne__c)ctrl.commentsMap.get(ctrl.newComment.Id).innerObject).Id);
            System.assertEquals(cnt.Id, ((CFAR_Comment_gne__c)ctrl.getObjectListComment().get(0).innerObject).Created_By_CFAR_Contact_ref_gne__c);
            ctrl.createNewComment();
            ctrl.newComment.Comments_gne__c = 'abc';
            ctrl.newComment.Activity_Date_gne__c = System.today().addDays(-1);
            Date yesterdayDate = ctrl.newComment.Activity_Date_gne__c;
            ctrl.submitNewComment();
            System.assertEquals(2, ctrl.stdSetControllerComment.getResultSize());
            ctrl.sortExpression = 'Activity_Date_gne__c';
            ctrl.sortDirection = 'asc';
            ctrl.sortComment();
            //security, in case test starts before midnight and ends after
            if (todayDate != yesterdayDate) {
            	System.assertEquals('C2', ((CFAR_Comment_gne__c)ctrl.getObjectListComment().get(0).innerObject).Name);
            	System.assertEquals('C1', ((CFAR_Comment_gne__c)ctrl.getObjectListComment().get(1).innerObject).Name);
            	System.assertEquals(yesterdayDate, ((CFAR_Comment_gne__c)ctrl.getObjectListComment().get(0).innerObject).Activity_Date_gne__c);
            	System.assertEquals(todayDate, ((CFAR_Comment_gne__c)ctrl.getObjectListComment().get(1).innerObject).Activity_Date_gne__c);
            }
            Test.stopTest();
        }
	}
	
	static testMethod void testEditValidateAndDeactivateComment() {
		User itAdm = CFAR_TestUtils.createTestITAdminUser();
		System.runAs(itAdm) {
			CFAR_Contact_gne__c cnt = CFAR_TestUtils.createTestContactForUser(itAdm, 'ITADMIN = IT Administrator');
        	CFAR_Trial_gne__c trial = CFAR_TestUtils.createTestTrial();
        	CFAR_Comment_gne__c comment = CFAR_TestUtils.createTestComment(trial.Id, cnt.Id);
        	Test.startTest();
        	CFAR_Comment_Controller ctrl = new CFAR_Comment_Controller();
            ctrl.trialWrapper.innerObject = trial;
            System.assertEquals(comment.Id, ((CFAR_Comment_gne__c)ctrl.getObjectListComment().get(0).innerObject).Id);
            ctrl.commentId = comment.Id;
            ctrl.editComment();
            ctrl.cancelNewComment();
            ctrl.commentId = comment.Id;
            ctrl.editComment();
            ctrl.newComment.Comments_gne__c = null;
            ctrl.submitNewComment();
            System.assertEquals(true, ctrl.isError);
            System.assertEquals('Please, fill in all required fields', ctrl.errorMessage);
            ctrl.newComment.Comments_gne__c = 'abc';
            ctrl.newComment.Activity_Date_gne__c = System.today().addDays(1);
            ctrl.submitNewComment();
            System.assertEquals(true, ctrl.isError);
            System.assertEquals('Activity Date cannot be in the future', ctrl.errorMessage);
            ctrl.newComment.Activity_Date_gne__c = System.today();
            ctrl.submitNewComment();
            System.assertEquals(false, ctrl.isError);
            System.assertEquals('', ctrl.errorMessage);
            ctrl.commentId = comment.Id;
            ctrl.deactivateComment();
            System.assertEquals(false, ((CFAR_Comment_gne__c)ctrl.getObjectListComment().get(0).innerObject).Active_gne__c);
        	Test.stopTest();
		}
	}

    static testMethod void testDefaultSortOrder(){
        User itAdm = CFAR_TestUtils.createTestITAdminUser();
        System.runAs(itAdm) {
            CFAR_Contact_gne__c contact = CFAR_TestUtils.createTestContactForUser(itAdm, 'ITADMIN = IT Administrator');
            CFAR_Trial_gne__c trial = CFAR_TestUtils.createTestTrial();

            Test.startTest();
                CFAR_Comment_Controller ctrl = new CFAR_Comment_Controller();
                ctrl.trialWrapper.innerObject = trial;

                ctrl.createNewComment();
                ctrl.newComment.Comments_gne__c = 'comment1';
                ctrl.newComment.Activity_Date_gne__c = (Date.Today() - 1);
                ctrl.submitNewComment();

                ctrl.createNewComment();
                ctrl.newComment.Comments_gne__c = 'comment2';
                ctrl.newComment.Activity_Date_gne__c = Date.Today();
                ctrl.submitNewComment();

                ctrl.createNewComment();
                ctrl.newComment.Comments_gne__c = 'comment3';
                ctrl.newComment.Activity_Date_gne__c = (Date.Today() - 2);
                ctrl.submitNewComment();

                System.assertEquals(3, [SELECT ID FROM CFAR_Comment_gne__c].size());
                //comment with the latest Activity Date, should be first on the list of comments
                CFAR_Comment_gne__c firstComment = [SELECT ID, Activity_Date_gne__c FROM CFAR_Comment_gne__c ORDER BY Activity_Date_gne__c DESC LIMIT 1];
                System.assertEquals( firstComment.id, ((CFAR_Comment_gne__c)ctrl.getObjectListComment().get(0).innerObject).Id);

                CFAR_Comment_gne__c editedComment = [SELECT ID FROM CFAR_Comment_gne__c ORDER BY Activity_Date_gne__c LIMIT 1];
                ctrl.commentId = editedComment.Id;
                ctrl.editComment();
                ctrl.newComment.Comments_gne__c = 'editedComment';
                ctrl.submitNewComment();
                //still order by Activity_Date
                System.assertEquals( firstComment.id, ((CFAR_Comment_gne__c)ctrl.getObjectListComment().get(0).innerObject).Id);

            Test.stopTest();

        }
    }

}