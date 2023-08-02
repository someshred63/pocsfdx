/************************************************************
*  @author: Sreedhar Karukonda
*  Date: 12/12/2012
*  Description: This class GNE_SFA2_Interaction_Trigger_Test test class to test the triggers on Call2_vod__c object
*
*  Modification History
*  Date        Name        Description
*
*************************************************************/

@isTest(SeeAllData=false)
public with sharing class GNE_SFA2_Interaction_Trigger_Test {

	/* Create Data Methods*/
	private static User getSFA2User(){
		//User GNE_SFA2_user = [SELECT id FROM User WHERE id ='00570000001DapE'];
		//Profile p = [SELECT Id FROM Profile WHERE Name='GNE-SFA2-US'];
		Profile p = [SELECT Id FROM Profile WHERE Name='GNE-SFA-Actemra-CS'];

		User GNE_SFA2_user = new User(Alias = 'TestUser', Email='GNE_SFA2_user@gene.com',
			EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
			LocaleSidKey='en_US', ProfileId = p.Id,
			TimeZoneSidKey='America/Los_Angeles', UserName='GNE_SFA2_user@gene.com');
			insert GNE_SFA2_user;
		return GNE_SFA2_user;
	}
	public static Call2_vod__c getCall(){
		Account acc = getAcccount();
		Call2_vod__c call = new Call2_vod__c(Meal_Expense_gne__c=true, Planned_Attendees_gne__c = 3,
		Actual_Attendees_gne__c = 3, Detailed_Products_vod__c='Rituxan - GPA/MPA',RecordTypeId='01270000000HfnbAAC',
		Account_vod__c=acc.id,Status_vod__c='Saved_vod',Parent_Address_vod__c=getAddress(acc).id,
		Call_Datetime_vod__c=System.now(),Territory_vod__c='00F51B3-SPOKANE, WA',Call_Type_vod__c='Group Detail',
		Completed_gne__c=FALSE,Address_vod__c='60 HOSPITAL RD, 997, NEWNAN, GA 30263',Interaction_location_gne__c='In Office',
		Call_Date_vod__c=System.now().date(),Attendees_vod__c=2,Attendee_Type_vod__c='Group_Account_vod',
		User_Business_Role_gne__c='Clinical Specialist - Actemra',Address_Line_1_vod__c='60 HOSPITAL RD',
		Address_Line_2_vod__c='997',City_vod__c='NEWNAN',State_vod__c='GA',Zip_4_vod__c='1210',Zip_vod__c='99999');
		return call;
	}

	public static Address_vod__c getAddress(Account testAccount){
		Address_vod__c address = new Address_vod__c();
		address.name = 'Unit Test Address Name';
		address.Address_1_gne__c = '611 Gateway Blvd';
		address.Address_line_2_vod__c = 'Street Address 2';
		address.city_vod__c = 'South San Francisco';
		address.state_vod__c = 'CA';
		address.zip_vod__c = '94580';
		address.fax_vod__c = '1234567890';
		address.fax_2_vod__c = '1234567890';
		address.Primary_vod__c = true;
		address.Active_Flag_gne__c = true;
		address.Account_vod__c = testAccount.Id;
		insert address;
		System.assert(address.id != null);
		return address;
	}

	private static Account getAcccount(){
		Account testAccount = new Account(Name = 'TestAccount');
		insert testAccount;
		System.assert(testAccount.id != null);
		return testAccount;
	}

	private static Call2_vod__c getCall(Account acc, Address_vod__c add){
		Call2_vod__c call = new Call2_vod__c(Meal_Expense_gne__c=true, Planned_Attendees_gne__c = 3,
		Actual_Attendees_gne__c = 3, Detailed_Products_vod__c='Rituxan - GPA/MPA',RecordTypeId='01270000000DyvdAAC',
		Account_vod__c=acc.id,Status_vod__c='Saved_vod',Parent_Address_vod__c=add.id,
		Call_Datetime_vod__c=System.now(),Territory_vod__c='00F51B3-SPOKANE, WA',Call_Type_vod__c='Group Detail',
		Interaction_Status_gne__c='Planned',Completed_gne__c=FALSE,Address_vod__c='60 HOSPITAL RD, 997, NEWNAN, GA 30263',
		Attendees_vod__c=2,Attendee_Type_vod__c='Group_Account_vod',Interaction_location_gne__c='In Office',
		User_Business_Role_gne__c='Clinical Specialist - Actemra',Address_Line_1_vod__c='60 HOSPITAL RD',
		Address_Line_2_vod__c='997',City_vod__c='NEWNAN',State_vod__c='GA',Zip_4_vod__c='1210',Zip_vod__c='99999');
		return call;
	}

	public static List<Call2_vod__c> getCalls(integer numberOfCalls){
		List<Call2_vod__c> calls = new List<Call2_vod__c>();
		Account acc = getAcccount();
		Address_vod__c add = getAddress(acc);

		for(integer idx =0; idx < numberOfCalls; idx++){
			calls.add(getCall(acc, add));
		}
		return calls;
	}

	/* Successfull Interaction insert Test Method*/
	public static  testMethod void testInsert(){
		User SFA2User = GNE_SFA2_Util.selectSFA2User();

		System.runAs(SFA2User){
			Call2_vod__c call = getCall();
			try{
				Test.startTest();
				insert call;
				Test.stopTest();
				System.assert(call.id != null);
				List<Call2_vod__c> qCall = [SELECT id FROM Call2_vod__c WHERE id =:call.Id];
				System.assertNotEquals(qcall[0].id, null);
			}catch (System.Exception e){
				System.debug('EXCEPTION MESSAGE : '+e.getMessage());
				System.assert(false, e.getMessage());
			}
		}
	}
	/* Successfull Interaction Update Test Method*/
	public static testMethod void testUpdate(){
		User SFA2User = GNE_SFA2_Util.selectSFA2User();

		System.runAs(SFA2User){
			Call2_vod__c call = getCall();
			try{
				insert call;
				call.Interaction_Status_gne__c='';
				System.assert(call.id != null);
				List<Call2_vod__c> qCall = [SELECT id FROM Call2_vod__c WHERE id =:call.Id];
				System.assertNotEquals(qcall[0].id, null);
				Id cid = call.Id;
				call.Completed_gne__c = true;
				call.Sales_Collateral_gne__c = 'No Collateral';
				Test.startTest();
				update call;
				Test.stopTest();
				List<Call2_vod__c> qCall1 = [SELECT id, Completed_gne__c FROM Call2_vod__c WHERE id =:cid];
				System.assert(qCall1[0].Completed_gne__c == true);
			}catch (System.Exception e){
				System.debug('EXCEPTION MESSAGE : '+e.getMessage());
				System.assert(false, e.getMessage());
			}
		}
	}
	/* Successfull Interaction Delete Test Method*/
	public static testMethod void testDelete(){
		User SFA2User = GNE_SFA2_Util.selectSFA2User();
		System.runAs(SFA2User){
			Call2_vod__c call = getCall();
			call.Interaction_Status_gne__c ='Completed';
			try{
				insert call;
				System.assert(call.id != null);
				List<Call2_vod__c> qCall = [SELECT id FROM Call2_vod__c WHERE id =:call.Id];
				System.assertNotEquals(qcall[0].id, null);
				Id cid = call.Id;
				Test.startTest();
				delete call;
				Test.stopTest();
				List<Call2_vod__c> qCall1 = [SELECT id, Completed_gne__c FROM Call2_vod__c WHERE id =:cid];
				System.assert(qCall1.size() == 0);
				List<Call2_Deleted_gne__c> deletedCalls = [SELECT id, Call__c FROM Call2_Deleted_gne__c WHERE Call__c =: cid];
				System.assert(deletedCalls.size() == 1);
			}catch (System.Exception e){
				System.debug('EXCEPTION MESSAGE : '+e.getMessage());
				System.assert(false, e.getMessage());
			}
		}
	}
	/* Successfull Interaction insert bulk Test Method*/
	public static  testMethod void testInsertBULK(){
		User SFA2User = GNE_SFA2_Util.selectSFA2User();
		System.runAs(SFA2User){
			List<Call2_vod__c> calls  = getCalls(200);
			List<Call2_vod__c> completedWithZip99999 = [SELECT id FROM Call2_vod__c WHERE Zip_vod__c='99999'];
			integer zip99999CountBefore = 0;
			if(completedWithZip99999 != null) zip99999CountBefore= completedWithZip99999.size();
			try{
				Test.startTest();
				insert calls;
				Test.stopTest();
				String TestString ='All IDs : ';
				for(Call2_vod__c c : calls){ TestString = TestString+' '+ c.id;}
				System.debug(TestString);
				System.assert(calls[0].id != null);
				List<Call2_vod__c> qCall = [SELECT id FROM Call2_vod__c WHERE id =:calls[0].Id];
				System.assertNotEquals(qcall[0].id, null);
				integer zip99999CountAfter= [SELECT id FROM Call2_vod__c WHERE Zip_vod__c='99999'].size();
				System.assertEquals(zip99999CountAfter, zip99999CountBefore + 200);
			}catch (System.Exception e){
				System.debug('EXCEPTION MESSAGE : '+e.getMessage());
				System.assert(false, e.getMessage());
			}
		}
	}
	/* Successfull Interaction update bulk Test Method*/
	public static  testMethod void testUpdateBULK(){
		User SFA2User = GNE_SFA2_Util.selectSFA2User();
		System.runAs(SFA2User){
			List<Call2_vod__c> calls = getCalls(200);
			List<Call2_vod__c> completedWithZip99999 = [SELECT id FROM Call2_vod__c WHERE Zip_vod__c='99999' and Completed_gne__c=true];
			Integer zip99999CountBefore = 0;
			if(completedWithZip99999 != null) zip99999CountBefore= completedWithZip99999.size();
			try{
				insert calls;
				for(Call2_vod__c iCall : calls){
					iCall.Completed_gne__c = true;
					iCall.Sales_Collateral_gne__c = 'No Collateral';
				}
				Test.startTest();
				update calls;
				Test.stopTest();
				integer zip99999CountAfter= [SELECT id FROM Call2_vod__c WHERE Zip_vod__c='99999' and Completed_gne__c = true].size();
				System.assertEquals(zip99999CountAfter, zip99999CountBefore + 200);
			}catch (System.Exception e){
				System.debug('EXCEPTION MESSAGE : '+e.getMessage());
				System.assert(false, e.getMessage());
			}
		}
	}

	/* Successfull Interaction update bulk Test Method*/
	public static  testMethod void testDeleteBULK(){
		User SFA2User = GNE_SFA2_Util.selectSFA2User();
		System.runAs(SFA2User){
			List<Call2_vod__c> calls = getCalls(200);
			List<Call2_vod__c> completedWithZip99999 = [SELECT id FROM Call2_vod__c WHERE Zip_vod__c='99999' and Completed_gne__c=true];
			integer zip99999CountBefore = 0;
			if(completedWithZip99999 != null) zip99999CountBefore= completedWithZip99999.size();
			try{
				insert calls;
				for(Call2_vod__c iCall : calls){
					iCall.Completed_gne__c = true;
				}
				Test.startTest();
				delete calls;
				Test.stopTest();
				integer zip99999CountAfter= [SELECT id FROM Call2_vod__c WHERE Zip_vod__c='99999' and Completed_gne__c = true].size();
				System.assertEquals(zip99999CountAfter, zip99999CountBefore);
			}catch (System.Exception e){
				System.debug('EXCEPTION MESSAGE : '+e.getMessage());
				System.assert(false, e.getMessage());
			}
		}
	}

	//BR-INT-09, 10 11 Previously Completed Interactions
	public static  testMethod void testPreviouslyCompletedInteractionsUpdate(){
		User SFA2User = GNE_SFA2_Util.selectSFA2User();
		System.runAs(SFA2User){
			try{
				Call2_vod__c call = getCall();
				call.Completed_gne__c = true;
				call.Sales_Collateral_gne__c = 'No Collateral';
				call.Call_Datetime_vod__c = System.now() -10;

				Test.startTest();
				insert call;
				System.assert(call.id != null);
				call.Call_Datetime_vod__c = System.now()+1;

				update call;
				Test.stopTest();
				System.assert(false); // Execution should not reach here
			}catch (System.Exception e){
				System.debug('EXCEPTION MESSAGE : '+e.getMessage());
				system.assert(e.getMessage().contains(Label.GNE_SFA2_ErrMsg_Interaction_GNE_COMPLETED), e.getMessage());
				Test.stopTest();
			}
		}
	}

	/* This test will fail if Workflow  with field update are enable*/
	public static  testMethod void testPreviouslyCompletedInteractionsDelete(){
		User SFA2User = GNE_SFA2_Util.selectSFA2User();
		System.runAs(SFA2User){
			Test.startTest();
			try{
				Call2_vod__c call = getCall();
				call.Completed_gne__c = true;
				call.Sales_Collateral_gne__c = 'No Collateral';
				insert call;
				System.debug('@@@@ INSERT COMPLETE @@@@@');
				System.assert(call.id != null);
				delete call;
				System.assert(false); // Execution should not reach here
			}catch (System.Exception e){
				System.debug('EXCEPTION MESSAGE : '+e.getMessage());
				System.assert(e.getMessage().contains(Label.GNE_SFA2_ErrMsg_Cannot_Delete_Completed_Interaction), e.getMessage());
			}
			Test.stopTest();
		}
	}

	// Iteraction Type related Validation Rules Test
	public static testMethod void testIteractionTypeValidation1(){
		System.runAs(GNE_SFA2_Util.selectSFA2User()){
			Test.startTest();
			try{
				Call2_vod__c call = getCall();
				call.Interaction_Type_gne__c='Planned';
				call.Account_Plan_vod__c = 'a0C70000004GAwdEAG';

				insert call;
				System.assert(call.id != null);
				System.assert([SELECT id, name FROM Call2_vod__c WHERE id =:call.id].size()==1);

			}catch(Exception e){
				System.debug('EXCEPTION MESSAGE' + e.getMessage());
				System.assert(false, e.getMessage());
			}

			Test.stopTest();
		}
	}

	// Iteraction Type related Validation Rules Test
	public static testMethod void testIteractionTypeValidation2(){
		System.runAs(GNE_SFA2_Util.selectSFA2User()){
			Test.startTest();

			try{
				Call2_vod__c call = getCall();
				call.Account_vod__c='0017000000Sw4my';
				call.Parent_Address_vod__c='a017000000Db80vAAB';
				call.Interaction_Type_gne__c='Planned Tactic';
				//call.Account_Plan_vod__c = 'a0C70000004GAwdEAG';
				insert call;
				System.assert(call.id != null);
				System.assert([SELECT id, name FROM Call2_vod__c WHERE id =:call.id].size()!=0, 'Reason: Interaction Should be not inserted with Type Planed Tactic with out Account Plan');
			}catch(Exception e){
				System.debug('EXCEPTION MESSAGE' + e.getMessage());
				System.assert(e.getMessage().contains(Label.GNE_SFA2_ErrMsg_FRM_Interaction_Type_Validation), e.getMessage());
			}
			Test.stopTest();
		}
	}

	// Iteraction Type related Validation Rules Test
	public static testMethod void testIteractionTypeValidation3(){
		System.runAs(GNE_SFA2_Util.selectSFA2User()){
			Test.startTest();
			try{
				Call2_vod__c call = getCall();
				call.Account_vod__c='0017000000Sw4my';
				call.Parent_Address_vod__c='a017000000Db80vAAB';
				call.Interaction_Type_gne__c='1:1';
				insert call;
				System.assert(call.id != null);
				System.assert([SELECT id, name FROM Call2_vod__c WHERE id =:call.id].size()!=0, 'Reason: Interaction Should be not inserted with Type "1:1" with out Group Meeting Topic');
			}catch(Exception e){
				System.debug('EXCEPTION MESSAGE' + e.getMessage());
				System.assert(e.getMessage().contains(Label.GNE_SFA2_ErrMsg_Group_Meeting_Value), e.getMessage());
			}
			Test.stopTest();
		}
	}
	// Iteraction Type related Validation Rules Test
	public static testMethod void testIteractionTypeValidation4(){
		System.runAs(GNE_SFA2_Util.selectSFA2User()){
			Test.startTest();
			try{
				Call2_vod__c call2 = getCall();
				call2.Account_vod__c='0017000000Sw4my';
				call2.Parent_Address_vod__c='a017000000Db80vAAB';
				call2.Interaction_Type_gne__c = '1:1 Brand Meeting';
				call2.Account_Plan_vod__c = 'a0C70000004GAwdEAG';
				insert call2;
				System.assert(call2.id != null);
				System.assert([SELECT id, name FROM Call2_vod__c WHERE id =:call2.id].size()!=0, 'Reason: Interaction Should be not inserted with Type not "Planed Tactic" with Account Plan');

			}catch(Exception e){
				System.debug('EXCEPTION MESSAGE' + e.getMessage());
				System.assert(e.getMessage().contains(Label.GNE_SFA2_ErrMsg_FRM_Interaction_Type_Validation), e.getMessage());
			}
			Test.stopTest();
		}
	}


	public static testMethod void testInteractionCompletedValidation(){
		System.runAs(GNE_SFA2_Util.selectSFA2User()){
			Test.startTest();
			try{
				Call2_vod__c call = getCall();
				call.Call_Datetime_vod__c = System.now() + 10;
				System.debug('');
				insert call;
				call.Completed_gne__c = true;
				update call;
				System.assert(false, 'Future call can not be completed'); // Excution should not reach here
			}catch (Exception e){
				System.debug('EXCEPTION MESSAGE : ' + e.getMessage());
				System.assert(e.getMessage().contains(Label.GNE_SFA2_ErrMsg_Interaction_GNE_COMPLETED), e.getMessage());

			}
			Test.stopTest();
		}
	}

	public static testMethod void testInteractionMealExpenseObjectiveValidation(){
		Set<String> objectiveAndLocationProfileNames = GNE_SFA2_Interaction_Validation_Rules.locationProfileName;
		objectiveAndLocationProfileNames.addAll(GNE_SFA2_Interaction_Validation_Rules.objectiveProfileName);
		User usr = [Select ID From User Where isActive=true AND (Not Profile.Name In :objectiveAndLocationProfileNames) Limit 1];

		System.runAs(usr){
			Test.startTest();
			try{
				Call2_vod__c call = getCall();
				call.Detailed_Products_vod__c = null;
				call.Meal_Expense_gne__c = true;
				insert call;
				System.assert(false, 'REASON: Call with Meal Expense and with out Detailed Product should not be insertable');
			}catch(Exception e){
				System.debug('EXCEPTION MESSAGE : ' + e.getMessage());
				System.assert(e.getMessage().contains(Label.GNE_SFA2_ErrMsg_AGS_Must_Have_Product), e.getMessage());
			}
			Test.stopTest();
		}
	}

	public static testMethod void testInteractionAttendeeValidation(){
		System.runAs(GNE_SFA2_Util.selectSFA2User()){
			Test.StartTest();
			Call2_vod__c call = getCall();
			try{
				call.Planned_Attendees_gne__c = 0;
				call.Actual_Attendees_gne__c = 0;
				insert call;
				System.assert(false, 'REASON: Call with Meal Expense and with Planned_Attendees_gne__c = 0 and Actual_Attendees_gne__c = 0 insertable');
			}catch(Exception e){
				System.debug('EXCEPTION MESSAGE : ' + e.getMessage());
				System.assert(e.getMessage().contains(Label.GNE_SFA2_Planned_Attnd_Greater_1_Label), e.getMessage());
			}

			try{
				call.Planned_Attendees_gne__c = null;
				call.Actual_Attendees_gne__c = null;
				insert call;
				System.assert(false, 'REASON: Call with Meal Expense and with Planned_Attendees_gne__c = 0 and Actual_Attendees_gne__c = 0 insertable');
			}catch(Exception e){
				System.debug('EXCEPTION MESSAGE : ' + e.getMessage());
			}
			try{
				call.Planned_Attendees_gne__c = 1;
				call.Actual_Attendees_gne__c = 1;
				insert call;
				System.assert(false, 'REASON: Call with Meal Expense and with Planned_Attendees_gne__c = 1 and Actual_Attendees_gne__c = 1 insertable');
			}catch(Exception e){
				System.debug('EXCEPTION MESSAGE : ' + e.getMessage());
			}

//			try{
//				call.Planned_Attendees_gne__c = 2;
//				call.Actual_Attendees_gne__c = 2;
//				insert call;
//				System.assert(false, 'REASON: Call with Meal Expense and with Planned_Attendees_gne__c = 2 and Actual_Attendees_gne__c = 2 when Attendee_gne__c =2 insertable');
//			}catch(Exception e){
//				System.debug('EXCEPTION MESSAGE : ' + e.getMessage());
//			}

			try{
				call.Meal_Expense_gne__c = false;
				call.Planned_Attendees_gne__c = 2;
				call.Actual_Attendees_gne__c = 2;
				insert call;
				System.assert(false, 'REASON: Call with Meal Expense as false and with Planned_Attendees_gne__c > 0 and Actual_Attendees_gne__c > 0 insertable');
			}catch(Exception e){
				System.debug('EXCEPTION MESSAGE : ' + e.getMessage());
				System.assert(e.getMessage().contains(Label.Meal_Expense_Required_Label), e.getMessage());
			}
			Test.stopTest();
		}
	}
	public static testMethod void testUpdateParentCallUpdateTimeStamp(){
		System.runAs(GNE_SFA2_Util.selectSFA2User()){
			Test.startTest();
			try{
				Call2_vod__c ParentCall = getCall();
				insert ParentCall;
				System.assert(ParentCall.Id != null);

				Call2_vod__c pCall = [SELECT id, createdDate, LastModifiedDate FROM Call2_vod__c WHERE id =: ParentCall.Id limit 1];
				DateTime parentCallLastMofifedDateBefore = pCall.LastModifiedDate;

                DateTime dt = System.now(); 
                while(System.Now()< dt.addSeconds(1)){}

				Call2_vod__c call = getCall();
				call.Parent_call_vod__c = pCall.id;
				insert call;
				System.assert(call.id != null);
				Call2_vod__c pCallAfter = [SELECT id, createdDate, LastModifiedDate FROM Call2_vod__c WHERE id =: ParentCall.Id limit 1];
				DateTime parentCallLastMofifedDateAfter = pCallAfter.LastModifiedDate;

				System.assert(parentCallLastMofifedDateAfter > parentCallLastMofifedDateBefore, 'REASON: Parent Call LastModified Date is not updated');

			}catch(Exception e){
				System.debug('EXCEPTION MESSAGE : ' + e.getMessage());
				System.assert(false, e.getMessage());
			}
			Test.stopTest();
		}
	}
	public static testMethod void testArchiveDeletedInteractions(){
		System.runAs(GNE_SFA2_Util.selectSFA2User()){
			try{
				Call2_vod__c call = getCall();
				insert call;
				System.assert(call.id != null);
				Test.startTest();
				delete call;
				Test.stopTest();
				Call2_Deleted_gne__c archivedCall = [SELECT id, Call__c, createdDate, LastModifiedDate FROM Call2_Deleted_gne__c WHERE call__c =: call.Id limit 1];
				System.assert(archivedCall.Id != null);
			}catch(Exception e){
				System.debug('EXCEPTION MESSAGE : ' + e.getMessage());
				System.assert(false, e.getMessage());
			}
		}
	}

		//Outdated requirement?
	//@isTest
	public static void testUpdateXolairCategory1(){
		System.runAs(GNE_SFA2_Util.selectSFA2User()){
			//try{
				Test.startTest();
				Call2_vod__c call = getCall();
				insert call;
				System.assert(Call.Id != null);
				Product_vod__c prod =new Product_vod__c(Name='Xolair');
				insert prod;
				System.assert(prod.Id != null);
				Product_Tactic_vod__c prdTactic = new Product_Tactic_vod__c(NAME='Refer to specialist');
				insert prdTactic;
				System.assert(prdTactic.Id != null, 'Product_Tactic_vod__c insert failed');
				System.debug('@@@@@@@@ PRODUCT Tactic @@@@@@' + prdTactic.id);
				Product_Strategy_vod__c productStrat = new Product_Strategy_vod__c(Name = 'Xolair - B', Active_vod__c=true);
				insert productStrat;
				System.assert(productStrat.id != null, 'Product_Strategy_vod__c insert failed');

				Call2_Discussion_vod__c callDisc = new Call2_Discussion_vod__c(Call2_vod__c = call.id, Account_vod__c =call.Account_vod__c, Product_Strategy_vod__c  = productStrat.id, Product_vod__c=prod.id, Product_Tactic_vod__c = prdTactic.id);
				insert callDisc;


				delete call;
				Test.stopTest();

				Product_Metrics_vod__c qPM = [SELECT id, Xolair_Category_gne__c FROM Product_Metrics_vod__c WHERE Account_vod__c =:call.Account_vod__c limit 1];
				System.assert(qPM.Xolair_Category_gne__c == '' || qPM.Xolair_Category_gne__c == null, 'Product_Metrics_vod__c Xolair_Category_gne__c should be updated to Blank');
			//}catch(Exception e){
			//	System.debug('EXCEPTION MESSAGE : ' + e.getMessage());
			//	System.assert(false, e.getMessage());
			//}
		}
	}

	//Outdated requirement?
	//@isTest
	public static void testUpdateXolairCategory2(){
		System.runAs(GNE_SFA2_Util.selectSFA2User()){
			Test.startTest();
			try{
				Call2_vod__c call = getCall();
				insert call;
				System.assert(Call.Id != null);
				Product_vod__c prod =new Product_vod__c(Name='Xolair');
				insert prod;
				System.assert(prod.Id != null);
				Product_Tactic_vod__c prdTactic = new Product_Tactic_vod__c(NAME='Refer to specialist');
				insert prdTactic;
				System.assert(prdTactic.Id != null, 'Product_Tactic_vod__c insert failed');
				System.debug('@@@@@@@@ PRODUCT Tactic @@@@@@' + prdTactic.id);
				Product_Strategy_vod__c productStrat = new Product_Strategy_vod__c(Name = 'Xolair - B', Active_vod__c=true);
				insert productStrat;
				System.assert(productStrat.id != null, 'Product_Strategy_vod__c is null');
				Call2_Discussion_vod__c callDisc = new Call2_Discussion_vod__c(Call2_vod__c = call.id, Account_vod__c =call.Account_vod__c, Product_Strategy_vod__c  = productStrat.id, Product_vod__c=prod.id, Product_Tactic_vod__c = prdTactic.id);
				insert callDisc;
				Call2_vod__c call1 = getCall();
				call1.Account_vod__c = call.Account_vod__c;
				insert call1;
				Call2_Discussion_vod__c callDisc1 = new Call2_Discussion_vod__c(Call2_vod__c = call1.id, Account_vod__c =call.Account_vod__c, Product_Strategy_vod__c  = productStrat.id,  Product_vod__c=prod.id, Product_Tactic_vod__c = prdTactic.id);
				insert callDisc1;
				delete call;
				Product_Metrics_vod__c qPM = [SELECT id, Xolair_Category_gne__c FROM Product_Metrics_vod__c WHERE Account_vod__c =: call.Account_vod__c limit 1];
				System.debug('QUERIED Product_Metrics_vod__c : ' + qPM);
				System.assertEquals(qPM.Xolair_Category_gne__c, 'Refer to specialist', 'qPM.Xolair_Category_gne__c : ' +qPM.Xolair_Category_gne__c);
			}catch(Exception e){
				System.debug('EXCEPTION MESSAGE : ' + e.getMessage());
				System.assert(false, e.getMessage());
			}
			Test.stopTest();
		}
	}

	/* Successfull GNE Notification  Test Method*/
	public static  testMethod void testGneNotification(){
		User SFA2User = GNE_SFA2_Util.selectSFA2User();
		
		System.runAs(SFA2User){			
			
			try{
				Test.startTest();
				Call2_vod__c call = getCall();
				insert call;
				System.assert(call.id != null);
				List<Call2_vod__c> qCall = [SELECT id FROM Call2_vod__c WHERE id =:call.Id];
				System.assertNotEquals(qcall[0].id, null);
				call.Call_Datetime_vod__c=System.now()+1;
				update call;
				delete call;
				Test.stopTest();				
				List<GNE_Notification__c> createNotifications = [SELECT Id, Name, ObjectType__c, TransactionId__c, TransactionType__c, objectId__c, objectName__c FROM GNE_Notification__c WHERE objectId__c=:call.id and ObjectType__c='Call2_vod__c' and TransactionType__c='CREATE'];
				System.assert(createNotifications.size() == 1, 'Call2_vod__c insert is not creating Notification record');
				List<GNE_Notification__c> updateNotifications = [SELECT Id, Name, ObjectType__c, TransactionId__c, TransactionType__c, objectId__c, objectName__c FROM GNE_Notification__c WHERE objectId__c=:call.id and ObjectType__c='Call2_vod__c' and TransactionType__c='UPDATE'];
				System.assert(updateNotifications.size() > 0, 'Call2_vod__c insert is not creating Notification record');
				List<GNE_Notification__c> deleteNotifications = [SELECT Id, Name, ObjectType__c, TransactionId__c, TransactionType__c, objectId__c, objectName__c FROM GNE_Notification__c WHERE objectId__c=:call.id and ObjectType__c='Call2_vod__c' and TransactionType__c='DELETE'];
				System.assert(deleteNotifications.size() == 1, 'Call2_vod__c insert is not creating Notification record');
			}catch (System.Exception e){
				System.debug('EXCEPTION MESSAGE : '+e.getMessage());
				System.assert(false, e.getMessage());
			}

		}
	}

	public static  testMethod void testGneNotificationsExclusionByUser() {
		User SFA2User = GNE_SFA2_Util.selectSFA2User();
		insert new GNE_Notifications_Exclusion__c (SetupOwnerId = SFA2User.Id);

		System.runAs(SFA2User){
			Call2_vod__c call = getCall();
			try {
				Test.startTest();
				insert call;
				System.assert(call.id != null);
				List<Call2_vod__c> qCall = [SELECT id FROM Call2_vod__c WHERE id =:call.Id];
				System.assertNotEquals(qcall[0].id, null);
				call.Call_Datetime_vod__c=System.now()+1;
				update call;
				delete call;
				Test.stopTest();
				List<GNE_Notification__c> allNotifications = [SELECT Id, Name, ObjectType__c, TransactionId__c, TransactionType__c, objectId__c, objectName__c FROM GNE_Notification__c WHERE objectId__c=:call.id];
				System.assert(allNotifications.isEmpty(), 'Call2_vod__c is creating Notification record, but should be excluded');
			} catch (System.Exception e) {
				System.debug('EXCEPTION MESSAGE : '+e.getMessage());
				System.assert(false, e.getMessage());
			}

		}
	}

	public static  testMethod void testGneNotificationsExclusionByProfile() {
		User SFA2User = GNE_SFA2_Util.selectSFA2User();
		User SFA2UserWithProfile = [ SELECT ProfileId FROM USER WHERE Id = :SFA2User.Id LIMIT 1];
		GNE_Notifications_Exclusion__c ex = new GNE_Notifications_Exclusion__c (SetupOwnerId = SFA2UserWithProfile.ProfileId);
		insert ex;

		System.runAs(SFA2User){
			Call2_vod__c call = getCall();
			try {
				Test.startTest();
				insert call;
				System.assert(call.id != null);
				List<Call2_vod__c> qCall = [SELECT id FROM Call2_vod__c WHERE id =:call.Id];
				System.assertNotEquals(qcall[0].id, null);
				call.Call_Datetime_vod__c=System.now()+1;
				update call;
				delete call;
				Test.stopTest();
				List<GNE_Notification__c> allNotifications = [SELECT Id, Name, ObjectType__c, TransactionId__c, TransactionType__c, objectId__c, objectName__c FROM GNE_Notification__c WHERE objectId__c=:call.id];
				System.assert(allNotifications.isEmpty(), 'Call2_vod__c is creating Notification record, but should be excluded  ' + ex);
			} catch (System.Exception e) {
				System.debug('EXCEPTION MESSAGE : '+e.getMessage());
				System.assert(false, e.getMessage());
			}

		}
	}

	/* Successfull Interaction Objective Trigger  Test Method*/
	public static  testMethod void testUpdateContactAndCallDiscussion(){
		User SFA2User = GNE_SFA2_Util.selectSFA2User();
		System.runAs(SFA2User){
			Call2_vod__c call = getCall();
			try{
				Test.startTest();
				insert call;
				System.assert(call.id != null);
				List<Call2_vod__c> qCall = [SELECT id FROM Call2_vod__c WHERE id =:call.Id];
				System.assert(qcall[0].id != null, 'Call insert failed');

				Call2_Discussion_vod__c callDisc = new Call2_Discussion_vod__c(Call2_vod__c = call.id, Account_vod__c =call.Account_vod__c);
				insert callDisc;
				System.assert(callDisc.id != null, 'Call Discussion insert failed');
				Call2_Discussion_vod__c qCallDisc = [SELECT Id, LastModifiedDate FROM Call2_Discussion_vod__c WHERE id =: callDisc.Id];
				DateTime callDiscInsertTimeBefore = qCallDisc.LastModifiedDate;
				update call;
				Test.stopTest();
				Call2_Discussion_vod__c qCallDiscAfter = [SELECT Id, LastModifiedDate FROM Call2_Discussion_vod__c WHERE id =: callDisc.Id];
				DateTime callDiscInsertTimeAfterUpdate = qCallDiscAfter.LastModifiedDate;
				//System.assert(callDiscInsertTimeAfterUpdate > callDiscInsertTimeBefore, 'Call Discussion Last Modified Date is not updated');

			}catch (System.Exception e){
				System.debug('EXCEPTION MESSAGE : '+e.getMessage());
				System.assert(false, e.getMessage());
			}
		}
	}

		//Outdated requirement?
	//@isTest
	public static void testProcessTSFWithExistingTSF(){
		System.runAs(GNE_SFA2_Util.selectSFA2User()){
			try{
				Call2_vod__c call = getCall();
				insert call;
				System.assert(call.id != null);
				Call2_vod__c testCalls = [ SELECT Territory_vod__c, Account_vod__c,
				(SELECT Account_vod__c FROM Call2_vod__r WHERE Account_vod__c != null and Account_vod__r.IsPersonAccount = false LIMIT 1)
				FROM Call2_vod__c  WHERE Id  =: call.id];
				System.debug('@@@@ call id @@@@ ' + call.id +' testCall '+ testCalls);
				TSF_vod__c tsf = new TSF_vod__c(Account_vod__c=call.Account_vod__c, Territory_vod__c=call.Territory_vod__c, External_Id_vod__c=call.Account_vod__c+'__'+call.Territory_vod__c, YTD_Activity_vod__c = 10 );
				insert tsf;
				System.assert(tsf.id != null, 'TSF insert failed');
				System.debug('CALL ID' + call.id);

				TSF_vod__c updatedTSF = [SELECT id, YTD_Activity_vod__c FROM TSF_vod__c WHERE Id =: tsf.id];
				System.debug('updatedTSF: ' + updatedTSF );

				Test.startTest();
				delete call;
				Test.stopTest();

				updatedTSF = [SELECT id, YTD_Activity_vod__c FROM TSF_vod__c WHERE Id =: tsf.id];
				System.debug('updatedTSF: ' + updatedTSF );


				System.assert(updatedTSF.YTD_Activity_vod__c == 0, 'TSF is not updated');

			}catch(Exception e){
				System.debug('EXCEPTION MESSAGE : ' + e.getMessage());
				System.assert(false, e.getMessage());
			}
		}
	}


		//Outdated requirement?
	//@isTest
	public static void testProcessTSFWithoutExistingTSF(){
		System.runAs(GNE_SFA2_Util.selectSFA2User()){
			try{
				Call2_vod__c call = getCall();
				Call2_vod__c call1 = getCall();
				call1.Account_vod__c = call.Account_vod__c;
				//call1.Call_Date_vod__c = System.now().date()-2;
				insert call1;
				Test.startTest();
				insert call;
				System.assert(call.id != null);
				delete call;
				Test.stopTest();
				List<TSF_vod__c> checkTSFIsCreated = [SELECT id, Last_Activity_Date_vod__c, YTD_Activity_vod__c FROM TSF_vod__c WHERE Account_vod__c =:call.Account_vod__c];
				System.debug('@@@@@ checkTSFIsCreated[0].Last_Activity_Date_vod__c @@@@' + checkTSFIsCreated[0].Last_Activity_Date_vod__c);
				Call2_vod__c  qCall1 = [SELECT id, Call_Date_vod__c FROM Call2_vod__c WHERE id=: call1.id];
				System.assert(checkTSFIsCreated[0].Last_Activity_Date_vod__c == qCall1.Call_Date_vod__c, 'TSF is Created but Last activity date is not set to pervious call date time');
			}catch(Exception e){
				System.debug('EXCEPTION MESSAGE : ' + e.getMessage());
				System.assert(false, e.getMessage());
			}
		}
	}

	public static testMethod void testUpdateCompletedDate(){
		System.runAs(GNE_SFA2_Util.selectSFA2User()){
			try{
				Call2_vod__c call = getCall();
				Test.startTest();
				insert call;
				System.assert(call.id != null);
				call.Completed_gne__c= true;
				call.Date_Completed_gne__c = null;
				call.Sales_Collateral_gne__c = 'No Collateral';
				update call;
				Test.stopTest();
				Call2_vod__c updatedCall = [SELECT id, Date_Completed_gne__c, Completed_gne__c FROM Call2_vod__c WHERE id=:call.id];
				System.assert(updatedCall.Date_Completed_gne__c == Date.today(), 'Date_Completed_gne__c is not updated when Completed_gne__c= true');
			}catch(Exception e){
				System.debug('EXCEPTION MESSAGE : ' + e.getMessage());
				System.assert(false, e.getMessage());
			}
		}
	}

	// Thids tests validations in BeforeDeleteCallValidation trigger
	public static testMethod void testBeforeDeleteCallValidation_validations1(){
		User SFA2User = GNE_SFA2_Util.selectSFA2User();
		System.runAs(SFA2User){
			Call2_vod__c call = getCall();
			try{
				call.Status_vod__c = 'Submitted_vod';
				Test.startTest();
				insert call;
				System.assert(call.id != null);
				delete call;
				System.assert(false, 'Submitted call should not be deleted');
			}catch (System.Exception e){
				System.debug('EXCEPTION MESSAGE : '+e.getMessage());
				System.assert(e.getMessage().contains(Label.GNE_SFA2_Submitted_Call_Delete_Error), e.getMessage());
				Test.stopTest();
			}


		}
	}

	// Thids tests validations in BeforeDeleteCallValidation trigger
	public static testMethod void testBeforeDeleteCallValidation_validations2(){
		User SFA2User = GNE_SFA2_Util.selectSFA2User();
		System.runAs(SFA2User){
			Call2_vod__c call = getCall();
			try{
				Test.startTest();
				call.Signature_Date_vod__c = System.now()-1;
				insert call;
				System.assert(call.id != null);
				delete call;
				System.assert(false, 'Signatured call should not be deleted');
			}catch (System.Exception e){
				System.debug('EXCEPTION MESSAGE : '+e.getMessage());
				System.assert(e.getMessage().contains(Label.Signed_Call_Delete_Lock_Label), e.getMessage());
				Test.stopTest();
			}

		}
	}

	// Thids tests validations in BeforeDeleteCallValidation trigger
	public static testMethod void testBeforeDeleteCallValidation_validations3(){
		User SFA2User = GNE_SFA2_Util.selectSFA2User();
		System.runAs(SFA2User){
			Call2_vod__c call = getCall();
			try{
				Test.startTest();
				call.Status_vod__c = 'Saved_vod';
				call.Sample_Send_Card_vod__c = 'true';
				insert call;
				System.assert(call.id != null);
				delete call;
				System.assert(false, 'Saved call should not be deleted');
			}catch (System.Exception e){
				System.debug('EXCEPTION MESSAGE : '+e.getMessage());
				System.assert(e.getMessage().contains(Label.GNE_SFA2_Calls_with_submitted_disbursements_Error), e.getMessage());
				Test.stopTest();
			}
		}
	}

	/*public static testMethod void testBeforeDeleteCallValidation_childDeleteFail(){
	User SFA2User = GNE_SFA2_Util.selectSFA2User();
	Call2_vod__c call = getCall();
	Call2_vod__c call1 = getCall();
	System.runAs(SFA2User){
			try{

				Test.startTest();
				insert call;
				System.assert(call.id != null);
				call1.Parent_call_vod__c= call.id;
				call1.Completed_gne__c = true;
				insert call1;
				System.assert(call1.id != null);
				delete call;
				Test.stopTest();
				System.assert(false, 'Submitted call should not be deleted');
			}catch (System.Exception e){
				System.debug('EXCEPTION MESSAGE : '+e.getMessage());
				System.assert(e.getMessage().contains('You cannot delete a completed interaction'), e.getMessage());
			}
		}
	}*/

		//Outdated requirement?
	//@isTest
	public static void testAfterInsertCreateCallDetailsAndKeyMessages(){
		System.runAs(GNE_SFA2_Util.selectSFA2User()){
			try{
				Call2_vod__c call = getCall();
				Product_vod__c product = new Product_Vod__c(Name='Test Prod');
				insert product;
				System.assert(product.id != null, 'TEST DATA CREATION: Product insert failed');
				Key_Message_vod__c msg = new Key_Message_vod__c(Description_vod__c='Test Description', Product_vod__c=product.id);
				insert msg;
				System.assert(msg.id != null, 'TEST DATA CREATION: Key Message insert failed');
				Medical_Event_vod__c medEvent = new Medical_Event_vod__c(name='Test Event', Active_vod__c= true, Description_vod__c='Test Medical Event', Start_Date_vod__c = System.Now().date(),  End_Date_vod__c = System.Now().date()+1);
				insert medEvent;
				System.assert(medEvent.id != null, 'Medical Event insert failed');


				call.Attendee_Type_vod__c ='Event_vod';
				call.Entity_Reference_Id_vod__c=medEvent.id;

				//Call.Medical_Event_vod__c = medEvent.id;
				call.Add_Detail_vod__c=Product.Id;
				call.Add_Key_Message_vod__c = msg.id+'@@'+product.id;
				Test.startTest();
				insert call;
				Test.stopTest();
				System.assert(call.id != null);
				List<Call2_Detail_vod__c> dets = [SELECT id, Call2_vod__c FROM Call2_Detail_vod__c WHERE Call2_vod__c =: call.id];
				System.debug('QUERIED CALL DETAILS @@@@@ : ' + dets);
				System.assert(dets.size() > 0 , 'TEST OUTCOME: Call Details are not created');
				List<Call2_Key_Message_vod__c> keyMsgs = [SELECT id, Call2_vod__c FROM Call2_Key_Message_vod__c WHERE Call2_vod__c =: call.id];
				System.debug('QUERIED CALL Key Messages @@@@@ : ' + keyMsgs);
				System.assert(keyMsgs.size() > 0 , 'TEST OUTCOME: Call Details are not created');

			}catch (System.Exception e){
				System.debug('EXCEPTION MESSAGE : '+e.getMessage());
				System.assert(false, e.getMessage());
			}
		}
	}

	//public static testMethod void testInteractionProcessAfterInsertUpdate1(){
	//	System.runAs(GNE_SFA2_Util.selectSFA2User()){
	//		try{
	//			test.StartTest();
	//			Call2_vod__c call = getCall();
	//			call.Attendee_Type_vod__c ='User_vod';
	//			call.Entity_Reference_Id_vod__c=UserInfo.getUserId();
	//			call.Call_Datetime_vod__c = null;
	//			call.Add_Detail_vod__c = 'DELETE';
	//			call.Add_Key_Message_vod__c = 'DELETE';
	//			call.Signature_vod__c = 'TEST';
	//			call.Unlock_vod__c = true;
	//			insert call;
	//			System.assert(call.id != null, 'Call insert failed');
	//			Call2_vod__c qCall = [SELECT Id, User_vod__c, Call_Date_vod__c, Add_Detail_vod__c, Add_Key_Message_vod__c FROM Call2_vod__c WHERE id =: call.id];
	//			System.assert(qCall.Add_Detail_vod__c == null, 'Add_Detail_vod__c  should be updated to NULL');
	//			System.assert(qCall.Add_Key_Message_vod__c == null, 'Add_Key_Message_vod__c  should be updated to NULL');
	//			System.assert(qCall.Call_Date_vod__c != null, 'Call_Date_vod__c should be assigned automatically to NULL');
	//			System.assert(qCall.User_vod__c == Userinfo.getUserId(), 'Call_Date_vod__c should be assigned automatically to NULL');
	//			test.stopTest();
	//		}catch(Exception e){
	//			System.debug('EXCEPTION MESSAGE : ' + e.getMessage());
	//			System.assert(false, e.getMessage());
	//		}
	//	}
	//}

	public static testMethod void testInteractionProcessAfterInsertUpdate2(){
		User owner = GNE_SFA2_Util.selectSFA2User();
		System.runAs(owner){
			try{
				test.StartTest();
				Call2_vod__c call = getCall();
				call.Attendee_Type_vod__c='Person_Account_vod';
				call.Entity_Reference_Id_vod__c=call.Account_vod__c;
				call.Signature_vod__c = 'TEST';
				insert call;
				owner = [SELECT id, profileid FROM user WHERE id=: owner.Id limit 1];
				User newUser = new User(Alias = 'TestUser', Email='GNE_SFA2_user1@gene.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
				LocaleSidKey='en_US', ProfileId = owner.ProfileId, TimeZoneSidKey='America/Los_Angeles', UserName='GNE_SFA2_user1@gene.com');
				insert newUser;
				call.ownerId= newUser.id;
				call.Status_vod__c = 'Submitted_vod';
				update call;
				System.assert(call.id != null, 'Call insert failed');
				Call2_vod__c qCall = [SELECT Id, OwnerId FROM Call2_vod__c WHERE id =: call.id];
				System.assert(qCall.OwnerId == owner.id, 'Owner should not be changed when Signature_vod__c != null');

				try{
					call.Call_Datetime_vod__c = System.now();
					call.Call_Date_vod__c = System.now().date()+2;
					call.Status_vod__c = 'Submitted_vod';
					update call;
					System.assert(false, 'Call Status Submitted_vod and Call Date in future can not be updated	');
				}catch(Exception e){
					System.debug('EXCEPTION MESSAGE : ' + e.getMessage());
					System.assert(e.getMessage().contains(Label.GNE_SFA2_Submitted_Call_Update_error), e.getMessage());
				}
				test.stopTest();

			}catch(Exception e){
				System.debug('EXCEPTION MESSAGE : ' + e.getMessage());
				System.assert(false, e.getMessage());
			}
		}
	}


		//Outdated requirement?
	//@isTest
	public static void testAfterUpdateProcess(){
		System.runAs(GNE_SFA2_Util.selectSFA2User()){
			try{
				Test.startTest();
				Call2_vod__c call = getCall();
				Product_vod__c product = new Product_Vod__c(Name='Test Prod');
				insert product;
				System.assert(product.id != null, 'TEST DATA CREATION: Product insert failed');
				Key_Message_vod__c msg = new Key_Message_vod__c(Description_vod__c='Test Description', Product_vod__c=product.id);
				insert msg;
				System.assert(msg.id != null, 'TEST DATA CREATION: Key Message insert failed');
				call.Add_Detail_vod__c=Product.Id;
				call.Add_Key_Message_vod__c = msg.id+'@@'+product.id;
				insert call;
				System.assert(call.id != null);
				List<Call2_Detail_vod__c> dets = [SELECT id, Call2_vod__c FROM Call2_Detail_vod__c WHERE Call2_vod__c =: call.id];
				System.debug('QUERIED CALL DETAILS @@@@@ : ' + dets);
				System.assert(dets.size() > 0 , 'TEST OUTCOME: Call Details are not created');
				List<Call2_Key_Message_vod__c> keyMsgs = [SELECT id, Call2_vod__c FROM Call2_Key_Message_vod__c WHERE Call2_vod__c =: call.id];
				System.debug('QUERIED CALL Key Messages @@@@@ : ' + keyMsgs);
				System.assert(keyMsgs.size() > 0 , 'TEST OUTCOME: Call Details are not created');
				GNE_SFA2_Interaction_Util.insertAction = false;
				call.Add_Detail_vod__c='DELETE';
				call.Add_Key_Message_vod__c = 'DELETE';
				update call;
				System.assert(call.id != null);
				List<Call2_Detail_vod__c> detsAfter = [SELECT id, Call2_vod__c FROM Call2_Detail_vod__c WHERE Call2_vod__c =: call.id];
				System.debug('QUERIED CALL DETAILS @@@@@ : ' + detsAfter);
				System.assert(detsAfter.size() == 0 , 'TEST OUTCOME: Call Details should be deleted');
				List<Call2_Key_Message_vod__c> keyMsgsAfter = [SELECT id, Call2_vod__c FROM Call2_Key_Message_vod__c WHERE Call2_vod__c =: call.id];
				System.debug('QUERIED CALL Key Messages @@@@@ : ' + keyMsgsAfter);
				System.assert(keyMsgsAfter.size() == 0 , 'TEST OUTCOME: Call Details should be deleted');

				GNE_SFA2_Interaction_Util.updateAction = false;
				call.Add_Detail_vod__c=Product.Id;
				call.Add_Key_Message_vod__c = msg.id+'@@'+product.id;
				update call;
				Test.stopTest();

				List<Call2_Detail_vod__c> dets2 = [SELECT id, Call2_vod__c FROM Call2_Detail_vod__c WHERE Call2_vod__c =: call.id];
				System.debug('QUERIED CALL DETAILS @@@@@ : ' + dets2);
				System.assert(dets2.size() > 0 , 'TEST OUTCOME: Call Details are not created');
				List<Call2_Key_Message_vod__c> keyMsgs2 = [SELECT id, Call2_vod__c FROM Call2_Key_Message_vod__c WHERE Call2_vod__c =: call.id];
				System.debug('QUERIED CALL Key Messages @@@@@ : ' + keyMsgs2);
				System.assert(keyMsgs2.size() > 0 , 'TEST OUTCOME: Call Details are not created');
			}catch (System.Exception e){
				System.debug('EXCEPTION MESSAGE : '+e.getMessage());
				System.assert(false, e.getMessage());
			}
		}
	}

	public static testMethod void  testTSFFieldUpdates(){
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2User!=null){
			System.runAs(sfa2User){
				List<Call2_vod__c> interactionsTest = [SELECT Id,Account_vod__c,Completed_gne__c,Territory_vod__c,parent_Address_vod__c FROM Call2_vod__c WHERE  Completed_gne__c=false LIMIT 100];
				for(Call2_vod__c intr : interactionsTest){
					intr.Completed_gne__c = true;
				}
				Test.startTest();
				try{
					update interactionsTest;
				}
				catch(Exception e) {
					System.debug('Error in updating interactions');
				}
				Test.stopTest();
			}
		}
	}

	public static testMethod void testORTDeletedRecordsCreation(){
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		Set<Id> sCallIds;
		if(sfa2User!=null){
			System.runAs(sfa2User){
				List<Call2_vod__c> interactionsTest = getCalls(200);
				insert interactionsTest;
				sCallIds = new Map<Id,Call2_vod__c>(interactionsTest).keySet();
				Test.startTest();
				try{
					delete interactionsTest;
				}
				catch(Exception e) {
					System.assert(false, 'Error in deleting interactions');
				}
				Test.stopTest();
			}
			String nameOfDeletedObject = GNE_SFA2_Deleted_Records_Util.getOtrObjectNameForObjectType(Call2_vod__c.getSObjectType());
			List<OTR_Deleted_Record_gne__c> deletedRecords  =  [SELECT id, name,Object_name__c,Deleted_Record_Id__c,Parent_Account_Id_gne__c   FROM OTR_Deleted_Record_gne__c WHERE Deleted_Record_Id__c IN :sCallIds];
			System.assertEquals(200, deletedRecords.size());
		}
	}

	@isTest
	public static void testProcessTSFWithExistingTSFIncrementYTDForInsertingCompleted(){
		System.runAs(GNE_SFA2_Util.selectSFA2User()) {
			try {
				Call2_vod__c call = getCall();
				call.Completed_gne__c = true;
				List<Territory2> territories = [SELECT Id FROM Territory2 WHERE Name = :call.Territory_vod__c];
				call.Territory_Id_gne__c = territories.get(0).Id;				

				TSF_vod__c tsf = new TSF_vod__c(Account_vod__c = call.Account_vod__c,
						Territory_vod__c = call.Territory_vod__c, External_Id_vod__c = call.Account_vod__c + '__' + call.Territory_vod__c,
						YTD_Activity_vod__c = 10);
				insert tsf;

				GNE_SFA2_Interaction_Adv_Future.additionalUserTerritoriesForTest.add(call.Territory_vod__c);

				Test.startTest();
				insert call;
				Test.stopTest();

				TSF_vod__c updatedTSF = [SELECT id, YTD_Activity_vod__c FROM TSF_vod__c WHERE Id = :tsf.id];
				System.debug('updatedTSF: ' + updatedTSF );

				System.assertEquals(tsf.YTD_Activity_vod__c + 1, updatedTSF.YTD_Activity_vod__c, 'TSF is not updated');

			} catch(Exception e) {
				System.debug('EXCEPTION MESSAGE : ' + e.getMessage());
				System.assert(false, e.getMessage());
			}
		}
	}

	@isTest
	public static void testProcessTSFWithExistingTSFIncrementYTDWhenChangingToCompleted(){
		System.runAs(GNE_SFA2_Util.selectSFA2User()) {
			try {
				Call2_vod__c call = getCall();

				List<Territory2> territories = [SELECT Id FROM Territory2 WHERE Name = :call.Territory_vod__c];
				call.Territory_Id_gne__c = territories.get(0).Id;

				TSF_vod__c tsf = new TSF_vod__c(Account_vod__c = call.Account_vod__c,
						Territory_vod__c = call.Territory_vod__c, External_Id_vod__c = call.Account_vod__c + '__' + call.Territory_vod__c,
						YTD_Activity_vod__c = 10);
				insert tsf;

				GNE_SFA2_Interaction_Adv_Future.additionalUserTerritoriesForTest.add(call.Territory_vod__c);
				insert call;

				Test.startTest();
				call.Completed_gne__c = true;
				update call;
				Test.stopTest();

				TSF_vod__c updatedTSF = [SELECT id, YTD_Activity_vod__c FROM TSF_vod__c WHERE Id = :tsf.id];
				System.debug('updatedTSF: ' + updatedTSF );

				System.assertEquals(tsf.YTD_Activity_vod__c + 1, updatedTSF.YTD_Activity_vod__c, 'TSF is not updated');

			} catch(Exception e) {
				System.debug('EXCEPTION MESSAGE : ' + e.getMessage());
				System.assert(false, e.getMessage());
			}
		}
	}

	@isTest
	public static void testProfileCanadaRama(){
		User u = selectCanadaRAMAUser();
		if (u != null) {
			System.runAs(u) {
				Call2_vod__c call = getCall();
				call.Interaction_Type_RAMA_gne__c = 'abc';
				insert call;
				Call2_vod__c callUpdated = [select Interaction_Type_RAMA_gne__c, Interaction_Type_gne__c from Call2_vod__c where Id = :call.Id];
				System.assertEquals('abc', callUpdated.Interaction_Type_gne__c);					
				System.assertEquals(callUpdated.Interaction_Type_RAMA_gne__c, callUpdated.Interaction_Type_gne__c);					

				call = getCall();
				call.Interaction_Type_gne__c = 'cde';
				insert call;
				callUpdated = [select Interaction_Type_RAMA_gne__c, Interaction_Type_gne__c from Call2_vod__c where Id = :call.Id];
				System.assertEquals('cde', callUpdated.Interaction_Type_gne__c);					
				System.assertEquals(callUpdated.Interaction_Type_RAMA_gne__c, callUpdated.Interaction_Type_gne__c);		

				call.Interaction_Type_gne__c = 'efg';
				update call;
				callUpdated = [select Interaction_Type_RAMA_gne__c, Interaction_Type_gne__c from Call2_vod__c where Id = :call.Id];
				System.assertEquals('efg', callUpdated.Interaction_Type_gne__c);					
				System.assertEquals(callUpdated.Interaction_Type_RAMA_gne__c, callUpdated.Interaction_Type_gne__c);					

				call.Interaction_Type_RAMA_gne__c = 'ghi';
				update call;
				callUpdated = [select Interaction_Type_RAMA_gne__c, Interaction_Type_gne__c from Call2_vod__c where Id = :call.Id];
				System.assertEquals('ghi', callUpdated.Interaction_Type_gne__c);					
				System.assertEquals(callUpdated.Interaction_Type_RAMA_gne__c, callUpdated.Interaction_Type_gne__c);					
			}
		}
	}

	private static User selectCanadaRAMAUser() {
        List<Profile> sfa2Profiles = [ SELECT Id FROM Profile WHERE Name = 'RCanada-SFA-RAMA' ];
        if(sfa2Profiles != null && sfa2Profiles.size() > 0) {
            List<User> sfa2Users = [ SELECT Id, External_ID_gne__c FROM USER WHERE ProfileId in :sfa2Profiles AND isActive = true ];
            if(sfa2Users != null && sfa2Users.size() > 0) {
                return sfa2Users[0];
            }
        }
        return null;
    }
}