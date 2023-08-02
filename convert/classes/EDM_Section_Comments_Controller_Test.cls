@isTest
public class EDM_Section_Comments_Controller_Test {
	@testSetup
	public static void setupData() {		
		EDM_AABP_gne__c aabp = createAABP();
		createIABP(false, aabp.Id);
	}

	@isTest
	public static void shouldAddIABPComment() {
		//given	
		EDM_Section_Comments_Controller ctrl = new EDM_Section_Comments_Controller();
		ctrl.objectId = getIABP().Id;

		//when
		ctrl.Body = 'New Comment';
		ctrl.sectionHeader = 'Some Section';
		ctrl.addComment();

		//then
		System.assertEquals(1, [SELECT Count() FROM EDM_Comment_gne__c]);
	}

	@isTest
	public static void shouldDelIABPComment() {
		//given
		EDM_IABP_gne__c iabp = getIABP();
		EDM_Comment_gne__c comment = new EDM_Comment_gne__c(EDM_Parent_IABP_gne__c = iabp.Id, EDM_Body_gne__c = 'New Comment', EDM_Section_gne__c = 'Some Section');
		insert comment;
		EDM_Section_Comments_Controller ctrl = new EDM_Section_Comments_Controller();
		ctrl.objectId = iabp.Id;

		//when
		ctrl.CommentToDel = comment.Id;
		ctrl.sectionHeader = 'Some Section';
		ctrl.delComment();

		//then
		System.assertEquals(0, [SELECT Count() FROM EDM_Comment_gne__c]);
	}

	@isTest
	public static void shouldAddAABPComment() {
		//given	
		EDM_Section_Comments_Controller ctrl = new EDM_Section_Comments_Controller();
		ctrl.objectId = getAABP().Id;

		//when
		ctrl.Body = 'New Comment';
		ctrl.sectionHeader = 'Some Section';
		ctrl.addComment();

		//then
		System.assertEquals(1, [SELECT Count() FROM EDM_Comment_gne__c]);
	}

	@isTest
	public static void shouldDelAABPComment() {
		//given
		EDM_AABP_gne__c aabp = getAABP();
		EDM_Comment_gne__c comment = new EDM_Comment_gne__c(EDM_Parent_AABP_gne__c = aabp.Id, EDM_Body_gne__c = 'New Comment', EDM_Section_gne__c = 'Some Section');
		insert comment;
		EDM_Section_Comments_Controller ctrl = new EDM_Section_Comments_Controller();
		ctrl.objectId = aabp.Id;

		//when
		ctrl.CommentToDel = comment.Id;
		ctrl.sectionHeader = 'Some Section';
		ctrl.delComment();

		//then
		System.assertEquals(0, [SELECT Count() FROM EDM_Comment_gne__c]);
	}

	@isTest
	public static void generateCoverate() {
		EDM_Section_Comments_Controller ctrl = new EDM_Section_Comments_Controller();
		ctrl.showDel = false;
		List<EDM_Comment_gne__c> cmts = ctrl.Comments;
	}

	private static EDM_AABP_gne__c createAABP() {
		User usr = [SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()];
		EDM_AABP_gne__c newAabp = EDM_ABM_Test_Utils.getTestAABP('GROUP', usr, usr);
		insert newAabp;
		return newAabp;
	}

	private static EDM_IABP_gne__c createIABP(Boolean isExeSum, Id parentAABP) {
		EDM_IABP_gne__c newIabp = new EDM_IABP_gne__c();
		newIabp.EDM_Type_of_Event_gne__c = 'CAB';
		newIabp.EDM_Executive_Summary_gne__c = isExeSum;
		newIabp.EDM_Meeting_Approach_gne__c = 'iAdvise';
		newIabp.EDM_Estimated_Quarter_gne__c = 'Q1';
		newIabp.EDM_Start_Date_gne__c = Date.today();
		newIabp.EDM_End_Date_gne__c = Date.today();
		newIabp.EDM_Meeting_Date_gne__c = Date.today();
		newIabp.EDM_IABP_Version_gne__c = 0;
		List<User> ablead = EDM_ABM_Utils.getUsersForRole(EDM_ABM_Utils.ABLEAD);
		if (ablead.size() > 0) {
			newIabp.EDM_Primary_AB_Lead_gne__c = ablead[0].Id;
		}
		newIabp.EDM_Parent_AABP_gne__c = parentAABP;
		newIabp.EDM_Strategic_Context_gne__c = 'Context';
		newIabp.EDM_Advisor_Selection_Criteria_gne__c = 'Criteria';
		newIabp.EDM_Advisor_Selection_Duties_gne__c = 'Duties';
		insert newIabp;
		return newIabp;
	}

	private static EDM_IABP_gne__c getIABP() {
		return [SELECT Id, Name FROM EDM_IABP_gne__c LIMIT 1];
	}

	private static EDM_AABP_gne__c getAABP() {
		return [SELECT Id, Name FROM EDM_AABP_gne__c LIMIT 1];
	}
}