/************************************************************
*  @author: Piotr Przesmycki
*  Date: 2014-03-26
*  This is a test class for GNE_SFA2_Interaction_Controller
*    
*  Modification History
*  Date        Name        			Description
*  2015.07.09  Przemyslaw Giszczak	Change Interaction_Type_gne__c to 'Planned Tactic' on interactions
*************************************************************/
@isTest
private class GNE_SFA2_Interaction_Controller_Test {
    private static final Map<String, Id> ids2ProfilesMap = GNE_FRM_TestUtilities.getProfiles();
    
    
    @testSetup
    static void testData() {
        Map<String, Id> name2RtId = GNE_FRM_TestUtilities.getAccountRecordTypes();

        User user1 = GNE_FRM_TestUtilities.createUser('TESTUSERXXXX', ids2ProfilesMap.get('GNE-MedAffairs-MCL'), false);
        User user2 = GNE_FRM_TestUtilities.createUser('TESTUSERYYYY', ids2ProfilesMap.get('GNE-MedAffairs-MSL'), false);

        GNE_SFA2_Util.updateAdminSetings(true);
        
        insert new List<User> {user1,user2};
    }

	public static testMethod void testInit(){
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('Account Name');
		insert acc;
		Call2_vod__c call = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod('No Collateral');
		call.Account_vod__c = acc.Id;
		insert call;
		SFA2_User_Preferences_gne__c userPref = new SFA2_User_Preferences_gne__c();
		insert userPref;
		List<Product_vod__c> prod = new List<Product_vod__c>();
		prod.add(GNE_SFA2_Triggers_Test_Util.prepareProduct_vod());
		prod.add(GNE_SFA2_Triggers_Test_Util.prepareProduct_vod());

		prod[0].Name = 'Avastin';
		prod[1].Name = 'Actemra';
		prod[1].active__c = true;
		insert prod;
		prod[1].Parent_Product_vod__c = prod[0].Id;
		update prod[1];
		insert new My_Setup_Products_vod__c(Product_vod__c = prod[0].Id);

		PageReference currentPage = Page.GNE_SFA2_Interaction_Layout;
		currentPage.getParameters().put('Id', call.Id);
		currentPage.getParameters().put('accountId', acc.Id);
		Test.setCurrentPage(currentPage);

		GNE_SFA2_Interaction_Controller controller = new GNE_SFA2_Interaction_Controller();
		system.assertEquals(false, controller.disableButtons);
		system.assertNotEquals(null, controller.pfgController);
		system.assertNotEquals(null, controller.referralInteractionController);

		PageReference pr = controller.init();
		system.assertEquals(null, pr);
		system.assertEquals(acc.Id, controller.callAccount.Id);
		system.assertEquals(48, controller.timeOptions.size());
		system.assertEquals(1, controller.availableProducts.size());
		system.assertEquals('Avastin', controller.availableProducts[0].getLabel());
		system.assertEquals(prod[0].Id, controller.availableProducts[0].getValue());
		system.assertEquals(3, controller.availableMaterials.size());
		system.assertEquals('--None--', controller.availableMaterials[0].getLabel());
		system.assertEquals('', controller.availableMaterials[0].getValue());
		system.assertEquals(0, controller.callProducts.size());
		system.assertEquals(false, controller.mealOptOutEnabled);
		system.assertEquals(1, controller.callDiscussionProducts.size());
		system.assertEquals('--None--', controller.callDiscussionProducts[0].getLabel());
		system.assertEquals('', controller.callDiscussionProducts[0].getValue());
		system.assertEquals(0, controller.selectedProducts.size());
		system.assertEquals(0, controller.selectedAccounts.size());
		system.assertEquals(0, controller.selectedKeyMessages.size());
		system.assertEquals(0, controller.productToKeyMessagesWrappers.size());
		system.assertEquals(userPref.Id, controller.tempAttachmentParentId);
		system.assertNotEquals(null, controller.temporaryCallId);
		system.assertNotEquals('', controller.temporaryCallId);
		system.assertEquals(false, controller.isUsingDatetime);

		insert new Attachment(Name = 'test', Body = Blob.valueOf('testBody'), ParentId = userPref.Id, Description = controller.temporaryCallId);
		system.assertEquals(1, [SELECT Count() FROM Attachment WHERE ParentId =: userPref.Id AND Description =: controller.temporaryCallId]);
		controller.removeTemporaryAttachments();
		system.assertEquals(0, [SELECT Count() FROM Attachment WHERE ParentId =: userPref.Id AND Description =: controller.temporaryCallId]);
	}

	public static testMethod void testInitInsert(){
		insert new SFA2_Configuration_Object_gne__c(Record_Type_gne__c 	= [SELECT DeveloperName FROM RecordType 
																		WHERE SobjectType='Call2_vod__c' LIMIT 1].DeveloperName,
													Object_Name_gne__c 	= 'Call2_vod__c',
													Is_Active_gne__c 	= true,
													Is_Default_Record_Type_gne__c = true);
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('Account Name');
		insert acc;
		SFA2_User_Preferences_gne__c userPref = new SFA2_User_Preferences_gne__c();
		insert userPref;

		PageReference currentPage = Page.GNE_SFA2_Interaction_Layout;
		currentPage.getParameters().put('accountId', acc.Id);
		Test.setCurrentPage(currentPage);

		GNE_SFA2_Interaction_Controller controller = new GNE_SFA2_Interaction_Controller();
		PageReference pr = controller.init();
		system.assertEquals(null, pr);
		system.assertEquals(true, controller.isCallInsert);
		system.assertNotEquals(null, controller.call);
		system.assertEquals(acc.Id, controller.call.Account_vod__c);
		system.assertEquals(Datetime.newInstance(System.now().year(), System.now().month(), System.now().day(), System.now().hour(), 0, 0), controller.call.Call_Datetime_vod__c);
		system.assertEquals('Planned', controller.call.Interaction_Status_gne__c );
	}

	public static testMethod void testJSON(){
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('Account Name');
		Account acc2 = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('Account Name');
		Account acc3 = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('Account Name');
		List<Account> accountsList = new List<Account>{acc, acc2, acc3};
		insert accountsList;
		Call2_vod__c call = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod('No Collateral');
		call.Account_vod__c = acc.Id;
		insert call;
		SFA2_User_Preferences_gne__c userPref = new SFA2_User_Preferences_gne__c();
		insert userPref;

		PageReference currentPage = Page.GNE_SFA2_Interaction_Layout;
		currentPage.getParameters().put('Id', call.Id);
		currentPage.getParameters().put('accountId', acc.Id);
		Test.setCurrentPage(currentPage);

		GNE_SFA2_Interaction_Controller controller = new GNE_SFA2_Interaction_Controller();
		PageReference pr = controller.init();

		controller.addActivity();
		system.assertEquals(1, controller.activities.size());
		controller.selectedAccountsJSON = '[{'
										+	'"accountId": "' + acc.Id + '",'
										+	'"addressId": ' + null + ','
				 						+	'"accountDescription": ' + null + ','
  										+	'"addressDescription": ' + null + ','
				  						+	'"recordType": ' + null + ','
  										+	'"isContact": ' + false + ','
  										+	'"isUser": ' + false + ''
  										+ '}]';
		system.assertEquals(null, controller.addAttendees());
		system.assertEquals(1, controller.attendees.size());

		controller.selectedAccountsJSON = '[{'
										+	'"accountId": "' + acc.Id + '",'
										+	'"addressId": ' + null + ','
				 						+	'"accountDescription": ' + null + ','
  										+	'"addressDescription": ' + null + ','
				  						+	'"recordType": ' + null + ','
  										+	'"isContact": ' + false + ','
  										+	'"isUser": ' + true + ''
  										+ '}]';
  		system.assertEquals(null, controller.addAttendees());
  		system.assertEquals(1, controller.attendees.size());

  		controller.selectedAccountsJSON = '[{'
										+	'"accountId": "' + acc2.Id + '",'
										+	'"addressId": ' + null + ','
				 						+	'"accountDescription": ' + null + ','
  										+	'"addressDescription": ' + null + ','
				  						+	'"recordType": ' + null + ','
  										+	'"isContact": ' + false + ','
  										+	'"isUser": ' + true + ''
  										+ '}]';
  		system.assertEquals(null, controller.addAttendees());
  		system.assertEquals(2, controller.attendees.size());

  		controller.selectedAccountsJSON = '[{'
										+	'"accountId": "' + acc3.Id + '",'
										+	'"addressId": ' + null + ','
				 						+	'"accountDescription": ' + null + ','
  										+	'"addressDescription": ' + null + ','
				  						+	'"recordType": ' + null + ','
  										+	'"isContact": ' + true + ','
  										+	'"isUser": ' + false + ''
  										+ '}]';
  		system.assertEquals(null, controller.addAttendees());
  		system.assertEquals(3, controller.attendees.size());
	}

	public static testMethod void testKeyMessageSelect(){
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('Account Name');
		insert acc;
		Call2_vod__c call = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod('No Collateral');
		call.Account_vod__c = acc.Id;
		insert call;
		SFA2_User_Preferences_gne__c userPref = new SFA2_User_Preferences_gne__c();
		insert userPref;
		Key_Message_vod__c keyMessage = new Key_Message_vod__c();
		insert keyMessage;

		PageReference currentPage = Page.GNE_SFA2_Interaction_Layout;
		currentPage.getParameters().put('Id', call.Id);
		currentPage.getParameters().put('accountId', acc.Id);
		Test.setCurrentPage(currentPage);

		GNE_SFA2_Interaction_Controller controller = new GNE_SFA2_Interaction_Controller();
		PageReference pr = controller.init();
		controller.keyMessageId = keyMessage.Id;
		system.assertEquals(null, controller.keyMessageSelected());
		system.assertEquals(1, controller.selectedKeyMessages.size());
		system.assertEquals(1, controller.keyMessages.size());

		system.assertEquals(null, controller.keyMessageDeselected());
		system.assertEquals(0, controller.selectedKeyMessages.size());
		system.assertEquals(0, controller.keyMessages.size());


	}

	public static testMethod void testGetters(){
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('Account Name');
		insert acc;
		Account_Plan_vod__c accPlan = GNE_SFA2_Triggers_Test_Util.prepareAccount_Plan_vod(acc.Id, 'teamName');
		insert accPlan;
		Call2_vod__c call = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod('No Collateral');
		call.Account_vod__c = acc.Id;
		call.Account_Plan_vod__c = accPlan.Id;
		call.Interaction_Type_gne__c = 'Planned';
		insert call;
		SFA2_User_Preferences_gne__c userPref = new SFA2_User_Preferences_gne__c();
		insert userPref;

		PageReference currentPage = Page.GNE_SFA2_Interaction_Layout;
		currentPage.getParameters().put('Id', call.Id);
		currentPage.getParameters().put('accountId', acc.Id);
		Test.setCurrentPage(currentPage);

		GNE_SFA2_Interaction_Controller controller = new GNE_SFA2_Interaction_Controller();
		controller.init();

		system.assertEquals(true, controller.getCanDelete());
		system.assertEquals(true, controller.getHasEdit());

		User u = selectSFA2User();
		system.runAs(u){
			system.assertEquals(false, controller.getCanDelete());
			system.assertEquals(false, controller.getHasEdit());
		}
		controller.call = call;
		system.assertEquals('Active_vod__c = true AND Account_vod__c = \'' + acc.Id + '\'', controller.getAccountPlanFilter);
		system.assertEquals('Account_Plan_vod__c = \'' + accPlan.Id + '\'', controller.getAccountTacticDiscussionFilter);

		call.Account_vod__c = null;
		call.Account_Plan_vod__c = null;
		update call;
		controller = new GNE_SFA2_Interaction_Controller();
		controller.init();
		system.assertEquals('Id = null', controller.getAccountPlanFilter);
		system.assertEquals('Id = null', controller.getAccountTacticDiscussionFilter);

		system.assertNotEquals(null, controller.getCustomButtons());
	}

	public static testMethod void testPageReferences(){
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('Account Name');
		insert acc;
		Account_Plan_vod__c accPlan = GNE_SFA2_Triggers_Test_Util.prepareAccount_Plan_vod(acc.Id, 'teamName');
		insert accPlan;
		Call2_vod__c call = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod('No Collateral');
		call.Account_vod__c = acc.Id;
		call.Account_Plan_vod__c = accPlan.Id;
		call.Interaction_Type_gne__c = 'Planned';
		insert call;
		SFA2_User_Preferences_gne__c userPref = new SFA2_User_Preferences_gne__c();
		insert userPref;
		Account acc2 = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('lastName');
		insert acc2;
		insert GNE_SFA2_Triggers_Test_Util.prepareAffiliation_vod(acc.Id, null, acc2.Id, null);

		PageReference currentPage = Page.GNE_SFA2_Interaction_Layout;
		currentPage.getParameters().put('Id', call.Id);
		currentPage.getParameters().put('accountId', acc.Id);
		Test.setCurrentPage(currentPage);

		GNE_SFA2_Interaction_Controller controller = new GNE_SFA2_Interaction_Controller();
		controller.init();

		PageReference pr = controller.addAttachments();
		system.assertEquals(true, pr.getRedirect());
		system.assertEquals(call.Id, pr.getParameters().get('Id'));
		system.assertEquals('/' + call.Id, pr.getParameters().get('retURL'));
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_UploadAttachment'), 'Wrong URL: '+pr.getUrl());

		system.assertEquals(0, controller.attachments.size());
		pr = controller.addAttachment();
		system.assertEquals(null, pr);
		system.assertEquals(1, controller.attachments.size());

		system.assertEquals(0, controller.materials.size());
		pr = controller.addMaterial();
		system.assertEquals(null, pr);
		system.assertEquals(1, controller.materials.size());

		system.assertEquals(0, controller.discussions.size());
		pr = controller.addInteractionDiscussion();
		system.assertEquals(null, pr);
		system.assertEquals(1, controller.discussions.size());

		system.assertEquals(acc.Id, controller.call.Account_vod__c);
		controller.affiliatedAccountId = acc2.Id;
		pr = controller.affiliatedAccountSelected();
		system.assertEquals(null, pr);
		system.assertEquals(1, controller.selectedAccounts.size());
		system.assertEquals(acc2.Id, controller.selectedAccounts[0]);
		system.assertEquals(1, controller.attendees.size());
		system.assertEquals(2, controller.recipients.size());

		pr = controller.affiliatedAccountDeselected();
		system.assertEquals(null, pr);
		system.assertEquals(0, controller.selectedAccounts.size());
		system.assertEquals(0, controller.attendees.size());
		system.assertEquals(1, controller.recipients.size());

		Test.startTest();
		acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('Account Name');
		insert acc;
		call = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod('No Collateral');
		call.Account_vod__c = acc.Id;
		insert call;
		
		currentPage = Page.GNE_SFA2_Interaction_Layout;
		currentPage.getParameters().put('Id', call.Id);
		currentPage.getParameters().put('accountId', acc.Id);
		Test.setCurrentPage(currentPage);
		
		controller = new GNE_SFA2_Interaction_Controller();
		controller.init();

		pr = controller.saveInProgress();
		system.assertNotEquals(null, pr);
		controller.call.Account_vod__c = call.Id;
		pr = controller.saveInProgress();
		system.assertEquals(null, pr);

		pr = controller.saveAndComplete();
		system.assertEquals(null, pr);
		system.assertEquals(false, controller.call.Completed_gne__c);
		system.assertEquals(null, controller.call.Date_Completed_gne__c);
		controller.call.Account_vod__c = acc.Id;
		pr = controller.saveAndComplete();
		system.assertNotEquals(null, pr);
		system.assertEquals(true, controller.call.Completed_gne__c);
		system.assertEquals(Date.today(), controller.call.Date_Completed_gne__c);

		pr = controller.edit();
		system.assertEquals(true, pr.getRedirect());
		system.assertEquals(call.Id, pr.getParameters().get('id'));
		system.assert(pr.getUrl().contains(Page.GNE_SFA2_Interaction_Edit_Create.getUrl()), 'Wrong URL: '+pr.getUrl());

		pr = controller.toObservationHelpPage();
		system.assertEquals(true, pr.getRedirect());
		system.assert(pr.getUrl().contains(Page.GNE_SFA2_Call_Observation_Help_Info.getUrl()), 'Wrong URL: '+pr.getUrl());
		Test.stopTest();
	}

	public static testMethod void testPostMethods(){
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('Account Name');
		insert acc;
		Account_Plan_vod__c accPlan = GNE_SFA2_Triggers_Test_Util.prepareAccount_Plan_vod(acc.Id, 'teamName');
		insert accPlan;
		Call2_vod__c call = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod('No Collateral');
		call.Account_vod__c = acc.Id;
		call.Account_Plan_vod__c = accPlan.Id;
		call.Interaction_Type_gne__c = 'Planned';
		insert call;
		SFA2_User_Preferences_gne__c userPref = new SFA2_User_Preferences_gne__c();
		insert userPref;
		Account acc2 = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('lastName');
		insert acc2;
		insert GNE_SFA2_Triggers_Test_Util.prepareAffiliation_vod(acc.Id, null, acc2.Id, null);

		PageReference currentPage = Page.GNE_SFA2_Interaction_Layout;
		currentPage.getParameters().put('Id', call.Id);
		currentPage.getParameters().put('accountId', acc.Id);
		Test.setCurrentPage(currentPage);

		GNE_SFA2_Interaction_Controller controller = new GNE_SFA2_Interaction_Controller();
		controller.init();
		controller.materialIndex = 0;
		controller.discussionIndex = 0;
		controller.addMaterial();
		controller.addInteractionDiscussion();
		controller.materialParam = call.Id;
		controller.recipientParam  = call.Id;
		controller.activityParam  = call.Id;
		controller.curriculumParam  = call.Id;
		controller.accountTacticParam  = call.Id;
		controller.productTacticParam  = call.Id;

		controller.postMaterialValue();
		system.assertEquals(call.Id, controller.materials.get(0).callSample.Product_vod__c);

		controller.postRecipientValue();
		system.assertEquals(call.Id, controller.materials.get(0).callSample.Account_vod__c);

		controller.postActivityValue();
		system.assertEquals(call.Id, controller.discussions.get(0).callDiscussion.Activity_gne__c);

		controller.postCurriculumValue();
		system.assertEquals(call.Id, controller.discussions.get(0).callDiscussion.Event_Curriculum_gne__c );

		controller.postAccountTacticValue();
		system.assertEquals(call.Id, controller.discussions.get(0).callDiscussion.Account_Tactic_vod__c );

		controller.postProductTacticValue();
		system.assertEquals(call.Id, controller.discussions.get(0).callDiscussion.Product_Tactic_vod__c );

		Test.startTest();
		call.Account_Plan_vod__c = null;
		update call;
		controller.init();
		controller.addInteractionDiscussion();

		controller.setAccountTactics();
		system.assertEquals(null, controller.discussions.get(0).callDiscussion.Account_Tactic_vod__c );
		Test.stopTest();
	}
	
	public static testMethod void testForMCLUsers(){
		List<Profile> p = [SELECT Id FROM Profile WHERE Name LIKE 'GNE-MEDAFFAIRS-MCL%'];
		system.assert(p.size()>0);
		User u = [SELECT Id FROM User WHERE ProfileId IN :p AND IsActive = true LIMIT 1];
		system.assertNotEquals(null, u);
		system.runAs(u){
			String recordTypeName = 'MeetingBrief_vod';
			createConfiguration('CS', 'SFA-US');
			Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('Account Last Name');
			insert acc;
			Call2_vod__c call = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod('No Collateral');
			call.Account_vod__c = acc.Id;
			call.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = :recordTypeName LIMIT 1].Id;
			insert call;
			insert new SFA2_User_Preferences_gne__c();
			insert new GNE_SFA2_Interaction_Overrides__c(Name = 'Visit_Reason_gne__c#GNE-MedAffairs-MCL', 
														Controlled_Field_Name__c = 'Primary_Interaction_Reason_gne__c', 
														Controlled_Field_Value1__c = 'Proactive',
														Controlled_Field_Value2__c = 'Responsive',
														Field_Value1__c = '--None--, Advice Seeking Meeting, Non-Product Presentations, Product Update, Research and Service Engagement, Scientific Meeting',
														Field_Value2__c = '--None--, Non-Product Presentations, Pipeline/New Indications, Product Update, Research and Service Engagement',
														Profiles__c = 'GNE-MedAffairs-MCL, GNE-MedAffairs-MCL-Manager',
														Record_Types__c = 'All');

			PageReference currentPage = Page.GNE_SFA2_Interaction_Layout;
			currentPage.getParameters().put('Id', call.Id);
			currentPage.getParameters().put('accountId', acc.Id);
			Test.setCurrentPage(currentPage);

			GNE_SFA2_Interaction_Controller controller = new GNE_SFA2_Interaction_Controller();
			controller.init();

			system.assertEquals(11, controller.visitReasonOptions.size());
			system.assertEquals('--None--', controller.visitReasonOptions[0].getLabel());
			system.assertEquals('--None--', controller.visitReasonOptions[0].getValue());

			system.assertEquals(Call2_vod__c.Visit_Reason_Description_gne__c.getDescribe().getPicklistValues().size() + 1, controller.visitReasonDescriptionOptions.size());
			system.assertEquals('--None--', controller.visitReasonDescriptionOptions[0].getLabel());
			system.assertEquals('', controller.visitReasonDescriptionOptions[0].getValue());

			PageReference pr = controller.saveInProgress();
			system.assertNotEquals(null, pr);
		}
	}

	public static testMethod void testRemoveAttendee(){
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('Account Name');
		insert acc;
		Call2_vod__c call = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod('No Collateral');
		call.Account_vod__c = acc.Id;
		insert call;
		SFA2_User_Preferences_gne__c userPref = new SFA2_User_Preferences_gne__c();
		insert userPref;

		PageReference currentPage = Page.GNE_SFA2_Interaction_Layout;
		currentPage.getParameters().put('Id', call.Id);
		currentPage.getParameters().put('accountId', acc.Id);
		Test.setCurrentPage(currentPage);

		GNE_SFA2_Interaction_Controller controller = new GNE_SFA2_Interaction_Controller();
		PageReference pr = controller.init();
		controller.selectedAccountsJSON = '[{'
										+	'"accountId": "' + acc.Id + '",'
										+	'"addressId": ' + null + ','
				 						+	'"accountDescription": ' + null + ','
  										+	'"addressDescription": ' + null + ','
				  						+	'"recordType": ' + null + ','
  										+	'"isContact": ' + false + ','
  										+	'"isUser": ' + false + ''
  										+ '}]';
		controller.addAttendees();
		controller.call.Completed_gne__c = true;
		controller.attendeeIndex = 0;
		controller.attendees[0].attendee.Id = call.Id;
		controller.removeAttendee();
		system.assertEquals(0, controller.attendees.size());
	}

	public static testMethod void testDiscussion(){
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('Account Name');
		insert acc;
		Call2_vod__c call = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod('No Collateral');
		call.Account_vod__c = acc.Id;
		insert call;
		SFA2_User_Preferences_gne__c userPref = new SFA2_User_Preferences_gne__c();
		insert userPref;

		PageReference currentPage = Page.GNE_SFA2_Interaction_Layout;
		currentPage.getParameters().put('Id', call.Id);
		currentPage.getParameters().put('accountId', acc.Id);
		Test.setCurrentPage(currentPage);

		GNE_SFA2_Interaction_Controller controller = new GNE_SFA2_Interaction_Controller();
		PageReference pr = controller.init();
		
		controller.addInteractionDiscussion();
		controller.addInteractionDiscussion();
		system.assertEquals(2, controller.discussions.size());
		
		controller.discussionIndex = 1;

		controller.moveDiscussionHigher();
		system.assertEquals(2, controller.discussions.size());

		controller.discussionIndex = 0;
		controller.removeDiscussion();
		system.assertEquals(1, controller.discussions.size());
	}

	public static testMethod void testProduct(){
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('Account Name');
		insert acc;
		Product_vod__c prod = GNE_SFA2_Triggers_Test_Util.prepareProduct_vod();
		prod.Name = 'Avastin';
		insert prod;
		Call2_vod__c call = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod('No Collateral');
		call.Account_vod__c = acc.Id;
		insert call;
		SFA2_User_Preferences_gne__c userPref = new SFA2_User_Preferences_gne__c();
		insert userPref;

		PageReference currentPage = Page.GNE_SFA2_Interaction_Layout;
		currentPage.getParameters().put('Id', call.Id);
		currentPage.getParameters().put('accountId', acc.Id);
		Test.setCurrentPage(currentPage);

		GNE_SFA2_Interaction_Controller controller = new GNE_SFA2_Interaction_Controller();
		PageReference pr = controller.init();
		
		controller.productId = prod.Id;
		controller.productSelected();
		controller.productSelected();
		system.assertEquals(2, controller.callProducts.size());
		system.assertEquals(2, controller.selectedProducts.size());
		controller.callProductIndex = 1;

		controller.moveCallProductHigher();
		system.assertEquals(2, controller.callProducts.size());
		system.assertEquals(2, controller.selectedProducts.size());
		
		controller.productDeselected();
		system.assertEquals(0, controller.callProducts.size());
		system.assertEquals(1, controller.selectedProducts.size());

		controller.productDeselected();
		system.assertEquals(0, controller.callProducts.size());
		system.assertEquals(0, controller.selectedProducts.size());
	}

	public static testMethod void testProductWithVisibleSections(){
		createConfiguration('CS', 'SFA-US');
		String recordTypeName = 'MeetingBrief_vod';
		
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('Account Name');
		insert acc;
		Product_vod__c prod = GNE_SFA2_Triggers_Test_Util.prepareProduct_vod();
		prod.Name = 'Avastin';
		insert prod;
		insert new My_Setup_Products_vod__c(Product_vod__c = prod.Id);
		Call2_vod__c call = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod('No Collateral');
		call.Account_vod__c = acc.Id;
		call.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = :recordTypeName LIMIT 1].Id;
		insert call;
		SFA2_User_Preferences_gne__c userPref = new SFA2_User_Preferences_gne__c();
		insert userPref;

		PageReference currentPage = Page.GNE_SFA2_Interaction_Layout;
		currentPage.getParameters().put('Id', call.Id);
		currentPage.getParameters().put('accountId', acc.Id);
		Test.setCurrentPage(currentPage);

		GNE_SFA2_Interaction_Controller controller = new GNE_SFA2_Interaction_Controller();
		PageReference pr = controller.init();
		
		controller.productId = prod.Id;
		controller.productSelected();
		controller.productSelected();
		system.assertEquals(2, controller.callProducts.size());
		system.assertEquals(2, controller.selectedProducts.size());
		controller.callProductIndex = 1;

		controller.moveCallProductHigher();
		system.assertEquals(2, controller.callProducts.size());
		system.assertEquals(2, controller.selectedProducts.size());
		
		controller.productDeselected();
		system.assertEquals(0, controller.callProducts.size());
		system.assertEquals(1, controller.selectedProducts.size());

		controller.productDeselected();
		system.assertEquals(0, controller.callProducts.size());
		system.assertEquals(0, controller.selectedProducts.size());
	}

	public static testMethod void testMaterial(){
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('Account Name');
		insert acc;
		Call2_vod__c call = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod('No Collateral');
		call.Account_vod__c = acc.Id;
		insert call;
		SFA2_User_Preferences_gne__c userPref = new SFA2_User_Preferences_gne__c();
		insert userPref;
		Call2_Sample_vod__c sample = GNE_SFA2_Triggers_Test_Util.prepareCall2_Sample_vod(call.Id, 1);
		insert sample;

		PageReference currentPage = Page.GNE_SFA2_Interaction_Layout;
		currentPage.getParameters().put('Id', call.Id);
		currentPage.getParameters().put('accountId', acc.Id);
		Test.setCurrentPage(currentPage);

		GNE_SFA2_Interaction_Controller controller = new GNE_SFA2_Interaction_Controller();
		controller.init();
		controller.addMaterial();
		controller.addMaterial();
		system.assertEquals(2, controller.materials.size());
		controller.materials[0].callSample.Id = sample.Id;
		controller.materialIndex = 0;
		controller.removeMaterial();
		system.assertEquals(1, controller.materials.size());
	}

	public static testMethod void testActivity(){
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('Account Name');
		insert acc;
		Call2_vod__c call = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod('No Collateral');
		call.Account_vod__c = acc.Id;
		insert call;
		SFA2_User_Preferences_gne__c userPref = new SFA2_User_Preferences_gne__c();
		insert userPref;
		Task t = GNE_SFA2_Triggers_Test_Util.prepareTask( acc.Id );
		insert t;

		PageReference currentPage = Page.GNE_SFA2_Interaction_Layout;
		currentPage.getParameters().put('Id', call.Id);
		currentPage.getParameters().put('accountId', acc.Id);
		Test.setCurrentPage(currentPage);

		GNE_SFA2_Interaction_Controller controller = new GNE_SFA2_Interaction_Controller();
		controller.init();
		controller.addActivity();
		controller.addActivity();
		system.assertEquals(2, controller.activities.size());
		controller.activities[0].task.Id = t.Id;
		controller.activityIndex = 0;
		controller.removeActivity();
		system.assertEquals(1, controller.activities.size());
	}

	public static testMethod void testAttachment(){
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('Account Name');
		insert acc;
		Call2_vod__c call = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod('No Collateral');
		call.Account_vod__c = acc.Id;
		insert call;
		SFA2_User_Preferences_gne__c userPref = new SFA2_User_Preferences_gne__c();
		insert userPref;

		PageReference currentPage = Page.GNE_SFA2_Interaction_Layout;
		currentPage.getParameters().put('Id', call.Id);
		currentPage.getParameters().put('accountId', acc.Id);
		Test.setCurrentPage(currentPage);

		GNE_SFA2_Interaction_Controller controller = new GNE_SFA2_Interaction_Controller();
		controller.init();
		Attachment att = new Attachment(Name = 'test', Body = Blob.valueOf('testBody'), ParentId = userPref.Id, Description = controller.temporaryCallId);
		insert att;

		controller.addAttachment();
		controller.addAttachment();
		system.assertEquals(2, controller.attachments.size());
		controller.attachments[0].attachment.Id = att.Id;
		controller.attachmentIndex = 0;
		controller.removeAttachment();
		system.assertEquals(1, controller.attachments.size());
	}

	public static testMethod void testInitTacticsAndStrategies(){
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('Account Name');
		insert acc;
		Call2_vod__c call = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod('No Collateral');
		call.Account_vod__c = acc.Id;
		insert call;
		SFA2_User_Preferences_gne__c userPref = new SFA2_User_Preferences_gne__c();
		insert userPref;
		Product_vod__c prod = GNE_SFA2_Triggers_Test_Util.prepareProduct_vod();
		prod.Name = 'Actemra';
		insert prod;
		Product_Strategy_vod__c strategy = GNE_SFA2_Triggers_Test_Util.prepareProduct_Strategy_vod();
		insert strategy;

		PageReference currentPage = Page.GNE_SFA2_Interaction_Layout;
		currentPage.getParameters().put('Id', call.Id);
		currentPage.getParameters().put('accountId', acc.Id);
		Test.setCurrentPage(currentPage);

		GNE_SFA2_Interaction_Controller controller = new GNE_SFA2_Interaction_Controller();
		PageReference pr = controller.init();
		
		controller.addInteractionDiscussion();
		controller.discussionIndex = 0;

		controller.initStrategies();
		system.assertEquals(null, controller.discussions.get(0).callDiscussion.Product_vod__c);
		system.assertEquals('', controller.discussions.get(0).callDiscussion.zvod_Product_Map_vod__c);
		system.assertEquals(1, controller.discussions.get(0).strategies.size());
		system.assertEquals('--None--', controller.discussions.get(0).strategies[0].getLabel());
		system.assertEquals('', controller.discussions.get(0).strategies[0].getValue());
		system.assertEquals(1, controller.discussions.get(0).tactics.size());
		system.assertEquals('--None--', controller.discussions.get(0).tactics[0].getLabel());
		system.assertEquals('', controller.discussions.get(0).tactics[0].getValue());

		controller.productParam = prod.Id;
		controller.initStrategies();
		system.assertEquals(prod.Id, controller.discussions.get(0).callDiscussion.Product_vod__c);
		system.assertEquals('', controller.discussions.get(0).callDiscussion.zvod_Product_Map_vod__c);
		system.assertEquals(1, controller.discussions.get(0).strategies.size());
		system.assertEquals('--None--', controller.discussions.get(0).strategies[0].getLabel());
		system.assertEquals('', controller.discussions.get(0).strategies[0].getValue());
		system.assertEquals(1, controller.discussions.get(0).tactics.size());
		system.assertEquals('--None--', controller.discussions.get(0).tactics[0].getLabel());
		system.assertEquals('', controller.discussions.get(0).tactics[0].getValue());


		controller.initTactics();
		system.assertEquals(null, controller.discussions.get(0).callDiscussion.Product_Strategy_vod__c);
		system.assertEquals(1, controller.discussions.get(0).tactics.size());
		system.assertEquals('--None--', controller.discussions.get(0).tactics[0].getLabel());
		system.assertEquals('', controller.discussions.get(0).tactics[0].getValue());

		controller.strategyParam = strategy.Id;
		controller.initTactics();
		system.assertEquals(strategy.Id, controller.discussions.get(0).callDiscussion.Product_Strategy_vod__c);
		system.assertEquals(1, controller.discussions.get(0).tactics.size());
		system.assertEquals('--None--', controller.discussions.get(0).tactics[0].getLabel());
		system.assertEquals('', controller.discussions.get(0).tactics[0].getValue());
	}

	public static testMethod void testCancelAndDelete(){
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('Account Name');
		insert acc;
		Call2_vod__c call = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod('No Collateral');
		call.Account_vod__c = acc.Id;
		insert call;
		SFA2_User_Preferences_gne__c userPref = new SFA2_User_Preferences_gne__c();
		insert userPref;

		PageReference currentPage = Page.GNE_SFA2_Interaction_Layout;
		currentPage.getParameters().put('Id', call.Id);
		currentPage.getParameters().put('accountId', acc.Id);
		Test.setCurrentPage(currentPage);

		GNE_SFA2_Interaction_Controller controller = new GNE_SFA2_Interaction_Controller();
		controller.init();
		controller.call = call;
		PageReference pr = controller.cancel();
		system.assertEquals(call.Id, pr.getParameters().get('id'));
		system.assert(pr.getUrl().contains(Page.GNE_SFA2_Interaction_Layout.getUrl()), 'Wrong URL: '+pr.getUrl());
		pr = controller.deleteCall();
		system.assert(pr.getUrl().contains('/'+acc.Id), 'Wrong URL: '+pr.getUrl());
		system.assertEquals(true, pr.getRedirect());

		call = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod('No Collateral');
		call.Account_vod__c = acc.Id;
		controller.call = call;
		pr = controller.cancel();
		system.assertEquals(acc.Id, pr.getParameters().get('id'));
		system.assert(pr.getUrl().contains(Page.GNE_SFA2_Account_Layout.getUrl()), 'Wrong URL: '+pr.getUrl());
		system.assertEquals(null, controller.deleteCall());


		currentPage.getParameters().put('retURL', 'sampleRetURL');
		Test.setCurrentPage(currentPage);
		insert call;
		controller.call = call;
		pr = controller.cancel();
		system.assert(pr.getUrl().contains('sampleRetURL'), 'Wrong URL: '+pr.getUrl());
		pr = controller.deleteCall();
		system.assert(pr.getUrl().contains('sampleRetURL'), 'Wrong URL: '+pr.getUrl());
		system.assertEquals(true, pr.getRedirect());
	}

	public static testMethod void testReadConfiguration(){
		String recordTypeName = 'MeetingBrief_vod';
		createConfiguration('CS', 'SFA-US');
		
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('Account Name');
		insert acc;
		Call2_vod__c call = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod('No Collateral');
		call.Account_vod__c = acc.Id;
		call.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = :recordTypeName LIMIT 1].Id;
		insert call;
		SFA2_User_Preferences_gne__c userPref = new SFA2_User_Preferences_gne__c();
		insert userPref;

		PageReference currentPage = Page.GNE_SFA2_Interaction_Layout;
		currentPage.getParameters().put('Id', call.Id);
		currentPage.getParameters().put('accountId', acc.Id);
		Test.setCurrentPage(currentPage);

		GNE_SFA2_Interaction_Controller controller = new GNE_SFA2_Interaction_Controller();
		controller.init();

		List<SFA2_Configuration_Object_gne__c> callSectionsList = controller.callSectionsList;
		Map<ID, List<SFA2_Configuration_Object_Detail_gne__c>> callSectionsMap = controller.callSectionsMap;

		system.assertEquals(12, callSectionsList.size());
		system.assertEquals(12, callSectionsMap.keySet().size());
		for(SFA2_Configuration_Object_gne__c section : callSectionsList){
			if(section.Name == 'CallAttendees' || section.Name == 'CallObjectives' || section.Name == 'CallMaterials'
				|| section.Name == 'CallActivities' || section.Name == 'CallAttachments' || section.Name == 'CallMealExpense'){
				system.assertEquals(1, callSectionsMap.get(section.Id).size(), section.Name);
			} else if (section.Name == 'CallDetail'){
				system.assertEquals(5, callSectionsMap.get(section.Id).size());
			} else if (section.Name == 'CallDetailInformation'){
				system.assertEquals(2, callSectionsMap.get(section.Id).size());
			} else {
				system.assertEquals(0, callSectionsMap.get(section.Id).size(), section.Name);
			}
		}
	}

	public static testMethod void testSaveWithConfiguration(){
		String recordTypeName = 'MeetingBrief_vod';
		createConfiguration('CS', 'SFA-US');
		
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('Account Last Name');
		insert acc;
		Call2_vod__c call = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod('No Collateral');
		call.Account_vod__c = acc.Id;
		call.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = :recordTypeName LIMIT 1].Id;
		insert call;
		SFA2_User_Preferences_gne__c userPref = new SFA2_User_Preferences_gne__c();
		insert userPref;

		PageReference currentPage = Page.GNE_SFA2_Interaction_Layout;
		currentPage.getParameters().put('Id', call.Id);
		currentPage.getParameters().put('accountId', acc.Id);
		Test.setCurrentPage(currentPage);
		
		GNE_SFA2_Interaction_Controller controller = new GNE_SFA2_Interaction_Controller();
		controller.init();

		PageReference pr = controller.saveInProgress();
		system.assertNotEquals(null, pr);
		controller.call.Account_vod__c = call.Id;
		pr = controller.saveInProgress();
		system.assertEquals(null, pr);

		pr = controller.saveAndComplete();
		system.assertEquals(null, pr);
		system.assertEquals(false, controller.call.Completed_gne__c);
		system.assertEquals(null, controller.call.Date_Completed_gne__c);
		controller.call.Account_vod__c = acc.Id;
		pr = controller.saveAndComplete();
		system.assertNotEquals(null, pr);
		system.assertEquals(true, controller.call.Completed_gne__c);
		system.assertEquals(Date.today(), controller.call.Date_Completed_gne__c);
	}

	public static testMethod void testValidatePart1(){
		List<Profile> p = [SELECT Id FROM Profile WHERE Name LIKE 'GNE-MEDAFFAIRS-MSL%'];
		system.assert(p.size()>0);
		User u = [SELECT Id FROM User WHERE ProfileId IN :p AND IsActive = true LIMIT 1];
		system.assertNotEquals(null, u);
		system.runAs(u){
			String recordTypeName = 'MeetingBrief_vod';
			createConfiguration('CS', 'SFA-US');
			Account hcp = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('Account Last Name');
			Account hco = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('Account Name');
			List<Account> accounts = new List<Account>{hcp, hco};
			insert accounts;
			Address_vod__c addr = GNE_SFA2_Triggers_Test_Util.prepareAddress_vod(hco.Id, 'address', true, 'addressName');
			addr.PFG_BDTD_gne__c='test';
			insert addr;
			Call2_vod__c call = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod('No Collateral');
			call.Account_vod__c = hcp.Id;
			call.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = :recordTypeName LIMIT 1].Id;
			call.HCP_Account_Meal_Opt_Out_gne__c=true;
			call.Parent_Address_vod__c = addr.Id;
			insert call;
			insert new SFA2_User_Preferences_gne__c();
			
			PageReference currentPage = Page.GNE_SFA2_Interaction_Layout;
			currentPage.getParameters().put('Id', call.Id);
			currentPage.getParameters().put('accountId', hcp.Id);
			Test.setCurrentPage(currentPage);
			Test.startTest();
			GNE_SFA2_Interaction_Controller controller = new GNE_SFA2_Interaction_Controller();
			controller.init();
			//controller.call.HCP_Account_Meal_Opt_Out_gne__c=true;
			//controller.call.Meal_Expense_gne__c = true;
			//controller.call.Planned_Attendees_gne__c = 2;
			//controller.call.Actual_Attendees_gne__c = 1;
			PageReference pr = controller.saveInProgress();
			system.assertNotEquals(null, pr);
			Call2_vod__c callToCheck = [SELECT Id, Address_vod__c, Address_Line_1_vod__c, Address_line_2_vod__c, PFG_BDTD_gne__c FROM Call2_vod__c WHERE Id = :call.Id LIMIT 1];
			system.assertEquals('addressName, ,', callToCheck.Address_vod__c);
			system.assertEquals('addressName', callToCheck.Address_Line_1_vod__c);
			system.assertEquals(null, callToCheck.Address_Line_2_vod__c);
			system.assertEquals('test', callToCheck.PFG_BDTD_gne__c);
			Test.stopTest();
		}
	}

	public static testMethod void testValidatePart2(){
		List<Profile> p = [SELECT Id FROM Profile WHERE Name LIKE 'GNE-MEDAFFAIRS-MSL%'];
		system.assert(p.size()>0);
		User u = [SELECT Id FROM User WHERE ProfileId IN :p AND IsActive = true LIMIT 1];
		system.assertNotEquals(null, u);
		system.runAs(u){
			String recordTypeName = 'MeetingBrief_vod';
			createConfiguration('CS', 'SFA-US');
			Account hcp = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('Account Last Name');
			Account hco = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('Account Name');
			List<Account> accounts = new List<Account>{hcp, hco};
			insert accounts;
			Address_vod__c addr = GNE_SFA2_Triggers_Test_Util.prepareAddress_vod(hco.Id, 'address', true, 'addressName');
			addr.PFG_BDTD_gne__c='test';
			insert addr;
			Call2_vod__c call = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod('No Collateral');
			call.Account_vod__c = hco.Id;
			call.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = :recordTypeName LIMIT 1].Id;
			call.HCP_Account_Meal_Opt_Out_gne__c=true;
			call.Parent_Address_vod__c = addr.Id;
			insert call;
			insert new SFA2_User_Preferences_gne__c();
			
			PageReference currentPage = Page.GNE_SFA2_Interaction_Layout;
			currentPage.getParameters().put('Id', call.Id);
			currentPage.getParameters().put('accountId', hco.Id);
			Test.setCurrentPage(currentPage);
			Test.startTest();
			GNE_SFA2_Interaction_Controller controller = new GNE_SFA2_Interaction_Controller();
			controller.init();

			PageReference pr = controller.saveInProgress();
			system.assertEquals(null, pr);
			system.assertEquals(1, controller.validationMessagesSummary.size());

			pr = controller.saveAndComplete();
			system.assertEquals(null, pr);
			system.assertEquals(1, controller.validationMessagesSummary.size());
			call = [SELECT Completed_gne__c, Date_Completed_gne__c FROM Call2_vod__c WHERE Id = :call.Id LIMIT 1];
			system.assertEquals(false, call.Completed_gne__c);
			system.assertEquals(null, call.Date_Completed_gne__c);
			Test.stopTest();
		}
	}

	private static void createConfiguration(String role, String appType){
		insert new GNE_SFA2_User_App_Context_gne__c(SFA2_Mode_gne__c = true, App_Name_gne__c = appType, Role_gne__c = role, Brand_gne__c = null, SetupOwnerId = UserInfo.getUserId());

		List<String> recordTypes = new String[]{ 'MeetingBrief_vod', 'SFA_Canada_Interaction' };

		List<SFA2_Configuration_Object_gne__c> configurationObjects = new List<SFA2_Configuration_Object_gne__c>();
		
		List<SFA2_Configuration_Object_gne__c> personalInformationList 	= new List<SFA2_Configuration_Object_gne__c>();
		List<SFA2_Configuration_Object_gne__c> postMeetingList 			= new List<SFA2_Configuration_Object_gne__c>();
		List<SFA2_Configuration_Object_gne__c> callObjectivesList 		= new List<SFA2_Configuration_Object_gne__c>();
		List<SFA2_Configuration_Object_gne__c> productsList 			= new List<SFA2_Configuration_Object_gne__c>();
		List<SFA2_Configuration_Object_gne__c> materialsList 			= new List<SFA2_Configuration_Object_gne__c>();
		List<SFA2_Configuration_Object_gne__c> activitiesList 			= new List<SFA2_Configuration_Object_gne__c>();
		List<SFA2_Configuration_Object_gne__c> attachmentsList 			= new List<SFA2_Configuration_Object_gne__c>();
		List<SFA2_Configuration_Object_gne__c> mealExpensesList			= new List<SFA2_Configuration_Object_gne__c>();
		List<SFA2_Configuration_Object_gne__c> attendeesList 			= new List<SFA2_Configuration_Object_gne__c>();
		List<SFA2_Configuration_Object_gne__c> keyMessagesList 			= new List<SFA2_Configuration_Object_gne__c>();
		List<SFA2_Configuration_Object_gne__c> relatedListList 			= new List<SFA2_Configuration_Object_gne__c>();
		List<SFA2_Configuration_Object_gne__c> buttonsList 				= new List<SFA2_Configuration_Object_gne__c>();
			
		SFA2_Configuration_Object_gne__c personalInformation;
		SFA2_Configuration_Object_gne__c postMeeting;
		SFA2_Configuration_Object_gne__c callObjective;
		SFA2_Configuration_Object_gne__c products;
		SFA2_Configuration_Object_gne__c materials;
		SFA2_Configuration_Object_gne__c activities;
		SFA2_Configuration_Object_gne__c attachments;
		SFA2_Configuration_Object_gne__c mealExpenses;
		SFA2_Configuration_Object_gne__c attendees;
		SFA2_Configuration_Object_gne__c keyMessages;
		SFA2_Configuration_Object_gne__c relatedList;
		SFA2_Configuration_Object_gne__c buttons;
			
		Integer ord = 0;
		
		for(String recType : recordTypes) {
			ord = 0;
				
			personalInformation = new SFA2_Configuration_Object_gne__c(
				Name = 'CallDetail',
				Order_gne__c = ord++,
				Record_Type_gne__c = recType,
				Section_Header_gne__c = 'Personal Information',
				Attributes_gne__c = '--nap,--nab'
			);
			personalInformationList.add(personalInformation);
			configurationObjects.add(personalInformation);
			
			postMeeting = new SFA2_Configuration_Object_gne__c(
				Name = 'CallDetailInformation',
				Order_gne__c = ord++,
				Record_Type_gne__c = recType,
				Section_Header_gne__c = 'Post-Meeting'
			);
			postMeetingList.add(postMeeting);
			configurationObjects.add(postMeeting);

			callObjective = new SFA2_Configuration_Object_gne__c(
				Name = 'CallObjectives',
				Order_gne__c = ord++,
				Record_Type_gne__c = recType,
				Section_Header_gne__c = 'Call Objectives'
			);
			callObjectivesList.add(callObjective);
			configurationObjects.add(callObjective);

			products = new SFA2_Configuration_Object_gne__c(
				Name = 'CallProducts',
				Order_gne__c = ord++,
				Record_Type_gne__c = recType,
				Section_Header_gne__c = 'Products'
			);
			productsList.add(products);
			configurationObjects.add(products);

			materials = new SFA2_Configuration_Object_gne__c(
				Name = 'CallMaterials',
				Order_gne__c = ord++,
				Record_Type_gne__c = recType,
				Section_Header_gne__c = 'Materials'
			);
			materialsList.add(materials);
			configurationObjects.add(materials);

			activities = new SFA2_Configuration_Object_gne__c(
				Name = 'CallActivities',
				Order_gne__c = ord++,
				Record_Type_gne__c = recType,
				Section_Header_gne__c = 'Activities'
			);
			activitiesList.add(activities);
			configurationObjects.add(activities);

			attachments = new SFA2_Configuration_Object_gne__c(
				Name = 'CallAttachments',
				Order_gne__c = ord++,
				Record_Type_gne__c = recType,
				Section_Header_gne__c = 'Attachments'
			);
			attachmentsList.add(attachments);
			configurationObjects.add(attachments);

			mealExpenses = new SFA2_Configuration_Object_gne__c(
				Name = 'CallMealExpense',
				Order_gne__c = ord++,
				Record_Type_gne__c = recType,
				Section_Header_gne__c = 'Meal Expenses',
				Attributes_gne__c = '--mealOptOut'
			);
			mealExpensesList.add(mealExpenses);
			configurationObjects.add(mealExpenses);

			attendees = new SFA2_Configuration_Object_gne__c(
				Name = 'CallAttendees',
				Order_gne__c = ord++,
				Record_Type_gne__c = recType,
				Section_Header_gne__c = 'Attendees',
				Attributes_gne__c = '--paa,--ns,--su,--nnc'
			);
			attendeesList.add(attendees);
			configurationObjects.add(attendees);
			
			keyMessages = new SFA2_Configuration_Object_gne__c(
				Name = 'CallKeyMessages',
				Order_gne__c = ord++,
				Record_Type_gne__c = recType,
				Section_Header_gne__c = 'Key Messages'
			);
			keyMessagesList.add(keyMessages);
			configurationObjects.add(keyMessages);
			
			relatedList = new SFA2_Configuration_Object_gne__c(
				Name = 'Call2_vod__c_rl',
				Order_gne__c = 0.0,
				Record_Type_gne__c = recType,
				Section_Header_gne__c = 'Related List'
			);
			relatedListList.add(relatedList);
			configurationObjects.add(relatedList);
			
			buttons = new SFA2_Configuration_Object_gne__c(
				Name = 'Call2_vod__c_buttons',
				Order_gne__c = 0.0,
				Record_Type_gne__c = recType,
				Section_Header_gne__c = null
			);
			buttonsList.add(buttons);
			configurationObjects.add(buttons);
			
			for(SFA2_Configuration_Object_gne__c confObj : configurationObjects) {
				confObj.Application_Type__c 			= appType;
				confObj.Role_gne__c  					= role;
				confObj.Object_Name_gne__c  			= 'Call2_vod__c';
				confObj.Configuration_Type_gne__c 		= 'Page';
				confObj.Is_Active_gne__c  				= true;
				confObj.Is_Default_Record_Type_gne__c  	= (confObj.Record_Type_gne__c == recordTypes[0]);
				confObj.OTR2_gne__c  					= false;
				confObj.RT_Available_On_Create_gne__c  	= (confObj.Record_Type_gne__c == recordTypes[0]);
			}
		}
		insert configurationObjects;
			
		List<SFA2_Configuration_Object_Detail_gne__c> configurationObjectDetails = new List<SFA2_Configuration_Object_Detail_gne__c>();
			
		for(SFA2_Configuration_Object_gne__c persInf : personalInformationList) {
			ord = 0;
			
			configurationObjectDetails.add(
				new SFA2_Configuration_Object_Detail_gne__c(
					Configuration_Object_ref_gne__c = persInf.Id,
					Order_gne__c 				= ord++,
					Label_gne__c 				= 'Datetime',
					API_Name_gne__c 			= 'Call_Datetime_vod__c',
					Name 						= 'Call_Datetime_vod__c',
					Availability_Mode_gne__c 	= 'New;Edit;View',
					Type_gne__c 				= 'Field',
					Is_Required_gne__c 			= false,
					Is_Read_Only_gne__c 		= false
				)
			);
			configurationObjectDetails.add(
				new SFA2_Configuration_Object_Detail_gne__c(
					Configuration_Object_ref_gne__c = persInf.Id,
					Order_gne__c 				= ord++,
					Label_gne__c 				= 'Subject',
					API_Name_gne__c 			= 'Subject_vod__c',
					Name 						= 'Subject_vod__c',
					Availability_Mode_gne__c 	= 'New;Edit;View',
					Type_gne__c 				= 'Field',
					Is_Required_gne__c 			= false,
					Is_Read_Only_gne__c 		= false
				)
			);
			configurationObjectDetails.add(
				new SFA2_Configuration_Object_Detail_gne__c(
					Configuration_Object_ref_gne__c = persInf.Id,
					Order_gne__c 				= ord++,
					Label_gne__c 				= 'Address',
					API_Name_gne__c 			= 'Parent_Address_vod__c',
					Name 						= 'Parent_Address_vod__c',
					Availability_Mode_gne__c 	= 'New;Edit;View',
					Type_gne__c 				= 'Field',
					Is_Required_gne__c 			= false,
					Is_Read_Only_gne__c 		= false
				)
			);
			configurationObjectDetails.add(
				new SFA2_Configuration_Object_Detail_gne__c(
					Configuration_Object_ref_gne__c = persInf.Id,
					Order_gne__c 				= ord++,
					Label_gne__c 				= 'Interaction Method',
					API_Name_gne__c 			= 'Interaction_Method_gne__c',
					Name 						= 'Interaction_Method_gne__c',
					Availability_Mode_gne__c 	= 'New;Edit;View',
					Type_gne__c 				= 'Field',
					Is_Required_gne__c 			= false,
					Is_Read_Only_gne__c 		= false
				)
			);
			configurationObjectDetails.add(
				new SFA2_Configuration_Object_Detail_gne__c(
					Configuration_Object_ref_gne__c = persInf.Id,
					Order_gne__c 				= ord++,
					Label_gne__c 				= 'Interaction Status',
					API_Name_gne__c 			= 'Interaction_Status_gne__c',
					Name 						= 'Interaction_Status_gne__c',
					Availability_Mode_gne__c 	= null,
					Type_gne__c 				= 'Field',
					Is_Required_gne__c 			= false,
					Is_Read_Only_gne__c 		= true
				)
			);
		}
			
			
		for(SFA2_Configuration_Object_gne__c postMeet : postMeetingList) {
			ord = 0;
		
			configurationObjectDetails.add(
				new SFA2_Configuration_Object_Detail_gne__c(
					Configuration_Object_ref_gne__c = postMeet.Id,
					Order_gne__c 				= ord++,
					Label_gne__c 				= 'Meeting Outcome',
					API_Name_gne__c 			= 'Meeting_Outcome_gne__c',
					Name 						= 'Meeting_Outcome_gne__c',
					Availability_Mode_gne__c 	= 'New;Edit;View',
					Type_gne__c 				= 'Field',
					Is_Required_gne__c 			= false,
					Is_Read_Only_gne__c 		= false
				)
			);
			configurationObjectDetails.add(
				new SFA2_Configuration_Object_Detail_gne__c(
					Configuration_Object_ref_gne__c = postMeet.Id,
					Order_gne__c 				= ord++,
					Label_gne__c 				= 'Next Steps',
					API_Name_gne__c 			= 'Next_Steps_gne__c',
					Name 						= 'Next_Steps_gne__c',
					Availability_Mode_gne__c 	= 'New;Edit;View',
					Type_gne__c 				= 'Field',
					Is_Required_gne__c 			= false,
					Is_Read_Only_gne__c 		= false
				)
			);
		}

		for(SFA2_Configuration_Object_gne__c postMeet : callObjectivesList) {
			ord = 0;
		
			configurationObjectDetails.add(
				new SFA2_Configuration_Object_Detail_gne__c(
					Configuration_Object_ref_gne__c = postMeet.Id,
					Order_gne__c 				= ord++,
					Label_gne__c 				= 'Event Name',
					API_Name_gne__c 			= 'Event_Name_gne__c',
					Name 						= 'Event_Name_gne__c',
					Availability_Mode_gne__c 	= 'New;Edit;View',
					Type_gne__c 				= 'Field',
					Is_Required_gne__c 			= false,
					Is_Read_Only_gne__c 		= false
				)
			);
		}

		for(SFA2_Configuration_Object_gne__c postMeet : materialsList) {
			ord = 0;
		
			configurationObjectDetails.add(
				new SFA2_Configuration_Object_Detail_gne__c(
					Configuration_Object_ref_gne__c = postMeet.Id,
					Order_gne__c 				= ord++,
					Label_gne__c 				= 'Manufacturer',
					API_Name_gne__c 			= 'Manufacturer_vod__c',
					Name 						= 'Manufacturer_vod__c',
					Availability_Mode_gne__c 	= 'New;Edit;View',
					Type_gne__c 				= 'Field',
					Is_Required_gne__c 			= false,
					Is_Read_Only_gne__c 		= false
				)
			);
		}

		for(SFA2_Configuration_Object_gne__c postMeet : activitiesList) {
			ord = 0;
		
			configurationObjectDetails.add(
				new SFA2_Configuration_Object_Detail_gne__c(
					Configuration_Object_ref_gne__c = postMeet.Id,
					Order_gne__c 				= ord++,
					Label_gne__c 				= 'Account Name',
					API_Name_gne__c 			= 'Account_Name_gne__c',
					Name 						= 'Account_Name_gne__c',
					Availability_Mode_gne__c 	= 'New;Edit;View',
					Type_gne__c 				= 'Field',
					Is_Required_gne__c 			= false,
					Is_Read_Only_gne__c 		= false
				)
			);
		}

		for(SFA2_Configuration_Object_gne__c postMeet : attachmentsList) {
			ord = 0;
		
			configurationObjectDetails.add(
				new SFA2_Configuration_Object_Detail_gne__c(
					Configuration_Object_ref_gne__c = postMeet.Id,
					Order_gne__c 				= ord++,
					Label_gne__c 				= 'Meeting Outcome',
					API_Name_gne__c 			= 'Meeting_Outcome_gne__c',
					Name 						= 'Meeting_Outcome_gne__c',
					Availability_Mode_gne__c 	= 'New;Edit;View',
					Type_gne__c 				= 'Field',
					Is_Required_gne__c 			= false,
					Is_Read_Only_gne__c 		= false
				)
			);
		}

		for(SFA2_Configuration_Object_gne__c postMeet : mealExpensesList) {
			ord = 0;
		
			configurationObjectDetails.add(
				new SFA2_Configuration_Object_Detail_gne__c(
					Configuration_Object_ref_gne__c = postMeet.Id,
					Order_gne__c 				= ord++,
					Label_gne__c 				= 'Meeting Outcome',
					API_Name_gne__c 			= 'Meeting_Outcome_gne__c',
					Name 						= 'Meeting_Outcome_gne__c',
					Availability_Mode_gne__c 	= 'New;Edit;View',
					Type_gne__c 				= 'Field',
					Is_Required_gne__c 			= false,
					Is_Read_Only_gne__c 		= false
				)
			);
		}

		for(SFA2_Configuration_Object_gne__c postMeet : attendeesList) {
			ord = 0;
		
			configurationObjectDetails.add(
				new SFA2_Configuration_Object_Detail_gne__c(
					Configuration_Object_ref_gne__c = postMeet.Id,
					Order_gne__c 				= ord++,
					Label_gne__c 				= 'Meeting Outcome',
					API_Name_gne__c 			= 'Meeting_Outcome_gne__c',
					Name 						= 'Meeting_Outcome_gne__c',
					Availability_Mode_gne__c 	= 'New;Edit;View',
					Type_gne__c 				= 'Field',
					Is_Required_gne__c 			= false,
					Is_Read_Only_gne__c 		= false
				)
			);
		}

		for(SFA2_Configuration_Object_gne__c postMeet : keyMessagesList) {
			ord = 0;
		
			configurationObjectDetails.add(
				new SFA2_Configuration_Object_Detail_gne__c(
					Configuration_Object_ref_gne__c = postMeet.Id,
					Order_gne__c 				= ord++,
					Label_gne__c 				= 'Meeting Outcome',
					API_Name_gne__c 			= 'Meeting_Outcome_gne__c',
					Name 						= 'Meeting_Outcome_gne__c',
					Availability_Mode_gne__c 	= 'New;Edit;View',
					Type_gne__c 				= 'Field',
					Is_Required_gne__c 			= false,
					Is_Read_Only_gne__c 		= false
				)
			);
		}
		
		for(SFA2_Configuration_Object_gne__c relList : relatedListList) {
			ord = 0;
			
			configurationObjectDetails.add(
				new SFA2_Configuration_Object_Detail_gne__c(
					Configuration_Object_ref_gne__c = relList.Id,
					Order_gne__c 				= ord++,
					Label_gne__c 				= 'Documentation',
					API_Name_gne__c 			= 'MCCO_Documentation_Junction_gne__c',
					Name 						= 'MCCO_Documentation_Junction_gne__c',
					Availability_Mode_gne__c 	= 'View',
					Type_gne__c 				= 'Related List',
					Is_Required_gne__c 			= false,
					Is_Read_Only_gne__c 		= false,
					Attributes_gne__c			= 'fieldsCSV=Action_frm_gne__c,Flag_frm_gne__c,Type_frm_gne__c,Category_frm_gne__c,Upload_Date_frm_gne__c,Uploaded_by_frm_gne__c,Email_Date_frm_gne__c;'
						+ 'orderByFieldName=Flag_frm_gne__c;sortDirection=ASC;'
						+ 'parentFieldName=Call_ref_gne__c;pageSize=5;'
						+ 'hideButtons=true;hideEditLink=true;hideDeleteLink=true;'
				)
			);
		}
		
		for(SFA2_Configuration_Object_gne__c button : buttonsList) {
			configurationObjectDetails.add(
				new SFA2_Configuration_Object_Detail_gne__c(
					Configuration_Object_ref_gne__c = button.Id,
					Order_gne__c 				= 0.0,
					Label_gne__c 				= 'Attach Document',
					API_Name_gne__c 			= 'Attach Document',
					Name 						= 'Call2_vod__c_Button',
					Availability_Mode_gne__c 	= null,
					Type_gne__c 				= 'Button',
					Is_Required_gne__c 			= false,
					Is_Read_Only_gne__c 		= false,
					Attributes_gne__c			= 'styleClass=image-button sfa-plh sfa-plh-action-bar button;'
				)
			);
		}
		
		for(SFA2_Configuration_Object_Detail_gne__c det : configurationObjectDetails) {
			det.OTR2_gne__c = false;
			det.Is_Active_gne__c = true;
		}
			
		insert configurationObjectDetails;
	}

	public static User selectSFA2User() {
        List<Profile> sfa2Profiles = [ SELECT Id FROM Profile WHERE Name = 'GNE-FIELD' ];
        if(sfa2Profiles != null && sfa2Profiles.size() > 0) {
            List<User> sfa2Users = [ SELECT Id FROM USER WHERE ProfileId in :sfa2Profiles AND isActive = true ];
            if(sfa2Users != null && sfa2Users.size() > 0) {
                return sfa2Users[0];
            }
        }
        return null;
    }
      
    @isTest
    private static void testCreateInteractionForRAMA() {
        User ramaUser = GNE_FRM_TestUtilities.createUser('ramaUser', ids2ProfilesMap.get('RCanada-SFA-RAMA'), false);
    	RecordType hcpRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'HCP_Canada'][0];
        SFA2_User_Preferences_gne__c userPref = new SFA2_User_Preferences_gne__c();
		insert userPref;

    	System.runAs(ramaUser) {
            Account canadaAccount = new Account(LastName = 'Test', RecordTypeId = hcpRT.Id);
        	insert canadaAccount;
            
            Call2_vod__c call = new Call2_vod__c();
			call.Account_vod__c = canadaAccount.Id;
            insert call;
            
            PageReference currentPage = Page.GNE_SFA2_Interaction_Layout;
            currentPage.getParameters().put('Id', call.Id);
            currentPage.getParameters().put('accountId', canadaAccount.Id);
            Test.setCurrentPage(currentPage);

	    	GNE_SFA2_Interaction_Controller controller = new GNE_SFA2_Interaction_Controller();
			controller.init();
            
            controller.call.Account_vod__c = canadaAccount.Id;
            PageReference pr = controller.saveAndComplete();

			Boolean echoMessage = false, groupMessage = false, textBoxesMessage = false;
            for(String msg: controller.validationMessagesSummary){
                if(msg.equals('You must select at least one ACCESS ECHO value to complete the interaction')) {
                    echoMessage = true;
                }
                if(msg.equals('Group: You must select a value')) {
                    groupMessage = true;
                }
                if(msg.equals('You must enter text in all boxes to complete the interaction')) {
                    textBoxesMessage = true;
                }
            }
			System.assertEquals(true, echoMessage);
            System.assertEquals(true, groupMessage);
            System.assertEquals(true, textBoxesMessage);
    
            controller.addInteractionCategory();
            pr = controller.saveAndComplete();
            
            Boolean categoryMessage = false;
          	for(String msg: controller.validationMessagesSummary){
                if(msg.equals('Category: You must select a value')) {
               		categoryMessage = true;
                }
            }
            System.assertEquals(true, categoryMessage);
    	}
    }
        
	@isTest
    private static void testRAMAPosts() {
        User ramaUser = GNE_FRM_TestUtilities.createUser('ramaUser', ids2ProfilesMap.get('RCanada-SFA-RAMA'), false);
    	RecordType hcpRT = [SELECT Id FROM RecordType WHERE DeveloperName = 'HCP_Canada'][0];
        SFA2_User_Preferences_gne__c userPref = new SFA2_User_Preferences_gne__c();
		insert userPref;

    	System.runAs(ramaUser) {
            Account canadaAccount = new Account(LastName = 'Test', RecordTypeId = hcpRT.Id);
        	insert canadaAccount;
            
            Call2_vod__c call = new Call2_vod__c();
			call.Account_vod__c = canadaAccount.Id;
            insert call;
            
            PageReference currentPage = Page.GNE_SFA2_Interaction_Layout;
            currentPage.getParameters().put('Id', call.Id);
            currentPage.getParameters().put('accountId', canadaAccount.Id);
            Test.setCurrentPage(currentPage);

	    	GNE_SFA2_Interaction_Controller controller = new GNE_SFA2_Interaction_Controller();
			controller.init();
            
            controller.addInteractionCategory();
            controller.brandNameIndex = 0;
            controller.brandNameParam = 'Test';
			controller.postBrandNameValue();
            System.assertEquals('Test', controller.interactionCategories[0].interactionCategory.Brand_Name_gne__c);
            
            controller.therapeuticAreaIndex = 0;
            controller.therapeuticAreaParam = 'TA test';
            controller.postTherapeuticAreaValue();
            System.assertEquals('TA test', controller.interactionCategories[0].interactionCategory.Therapeutic_Area_gne__c);
            
            controller.brandAndAboveBrandIndex = 0;
            controller.brandAndAboveBrandParam = 'Test BAAB';
            controller.postBrandAndAboveBrandValue();
            System.assertEquals('Test BAAB', controller.interactionCategories[0].interactionCategory.Brand_Above_Brand_gne__c);
            
            controller.nocStatusIndex = 0;
            controller.nocStatusParam = 'Test Noc';
            controller.postNocStatusValue();
            System.assertEquals('Test Noc', controller.interactionCategories[0].interactionCategory.NOC_Status_gne__c);
    	}     
    }
}