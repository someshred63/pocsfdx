/************************************************************
*  @author: Sreedhar Karukonda
*  Date: 12/31/2012
*  Description: This class GNE_SFA2_Call_Discussion_Trigger_Test test class to test the triggers on Call2_Discussion_vod__c object
*  
*  Modification History
*  Date         Name                Description
*  2014-01-30   Piotr Przesmycki    Removed seeAllData annotation
*  2014-02-19   Piotr Przesmycki    Modified unit test to use GNE_SFA2_Triggers_Test_Util for creating data
*  2014-12-03   Mateusz Michalczyk  Added after delete logic test for OTR_Deleted_Record_gne__c record creation. 
*************************************************************/
@isTest
private class GNE_SFA2_Call_Discussion_Trigger_Test {
		/* Create Data Methods*/
    private static Call2_vod__c getCall(){
        Account acc = getAcccount();
        Call2_vod__c call = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod('No Collateral');
        call.Meal_Expense_gne__c        = true;
        call.Planned_Attendees_gne__c   = 3;
        call.Actual_Attendees_gne__c    = 3;
        call.Detailed_Products_vod__c   = 'Rituxan - GPA/MPA';
        call.RecordTypeId               = '01270000000HfnbAAC';
        call.Account_vod__c             = acc.id;
        call.Status_vod__c              = 'Saved_vod';
        call.Parent_Address_vod__c      = getAddress(acc).id;
        call.Call_Datetime_vod__c       = System.now();
        call.Territory_vod__c           = '00X3607-SPOKANE-STD';
        call.Call_Type_vod__c           = 'Group Detail';
        call.Completed_gne__c           = false;
        call.Address_vod__c             = '60 HOSPITAL RD, 997, NEWNAN, GA 30263';
        call.Call_Date_vod__c           = System.now().date();
        call.Attendees_vod__c           = 2;
        call.Attendee_Type_vod__c       = 'Group_Account_vod';
        call.User_Business_Role_gne__c  = 'Clinical Specialist - Actemra';
        call.Address_Line_1_vod__c      = '60 HOSPITAL RD';
        call.Address_Line_2_vod__c      = '997';
        call.City_vod__c                = 'NEWNAN';
        call.State_vod__c               = 'GA';
        call.Zip_4_vod__c               = '1210';
        call.Zip_vod__c                 = '99999';
        return call;
    }

    private static Address_vod__c getAddress(Account testAccount){
        Address_vod__c address = GNE_SFA2_Triggers_Test_Util.prepareAddress_vod(testAccount.Id, '611 Gateway Blvd', true, 
                                                                                'Unit Test Address Name');
        address.Address_line_2_vod__c = 'Street Address 2';
        address.city_vod__c = 'South San Francisco';
        address.state_vod__c = 'CA';
        address.zip_vod__c = '94580';
        address.fax_vod__c = '1234567890';
        address.fax_2_vod__c = '1234567890';
        address.Primary_vod__c = true;
        insert address;
        System.assert(address.id != null);
        return address;
    }

    private static Account getAcccount(){
        Account testAccount = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('TestAccount');
        insert testAccount;
        System.assert(testAccount.id != null);
        return testAccount;
    }

    private static Call2_vod__c getCall(Account acc, Address_vod__c add){
        Call2_vod__c call = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod('No Collateral');
        call.Meal_Expense_gne__c        = true;
        call.Planned_Attendees_gne__c   = 3;
        call.Actual_Attendees_gne__c    = 3;
        call.Detailed_Products_vod__c   = 'Rituxan - GPA/MPA';
        call.RecordTypeId               = '01270000000DyvdAAC';
        call.Account_vod__c             = acc.id;
        call.Status_vod__c              = 'Saved_vod';
        call.Parent_Address_vod__c      = add.id;
        call.Call_Datetime_vod__c       = System.now();
        call.Territory_vod__c           = '00X3607-SPOKANE-STD';
        call.Call_Type_vod__c           = 'Group Detail';
        call.Interaction_Status_gne__c  = 'Planned';
        call.Completed_gne__c           = false;
        call.Address_vod__c             = '60 HOSPITAL RD, 997, NEWNAN, GA 30263';
        call.Attendees_vod__c           = 2;
        call.Attendee_Type_vod__c       = 'Group_Account_vod';
        call.User_Business_Role_gne__c  = 'Clinical Specialist - Actemra';
        call.Address_Line_1_vod__c      = '60 HOSPITAL RD';
        call.Address_Line_2_vod__c      = '997';
        call.City_vod__c                = 'NEWNAN';
        call.State_vod__c               = 'GA';
        call.Zip_4_vod__c               = '1210';
        call.Zip_vod__c                 = '99999';
        return call;
    }

    private static List<Call2_vod__c> getCalls(integer numberOfCalls){
        List<Call2_vod__c> calls = new List<Call2_vod__c>();
        Account acc = getAcccount();
        Address_vod__c add = getAddress(acc);
        for(integer idx =0; idx < numberOfCalls; idx++){
            calls.add(getCall(acc, add));
        }
        return calls;
    }

    private static Call2_Discussion_vod__c getCallDiscussion(Call2_vod__c call){
    	insert call;
    	Call2_Discussion_vod__c callDisc = new Call2_Discussion_vod__c(Account_vod__c= call.Account_vod__c, Call2_vod__c= call.id);
    	return callDisc;
    }

    private static testMethod void DMLCallDiscussion() {
        System.runAs(GNE_SFA2_Util.selectSFA2User()){
        	try{
        		Call2_Discussion_vod__c callDisc = getCallDiscussion(getCall());
        		Test.startTest();
        		insert callDisc;
        		System.assertNotEquals(callDisc.id, null, 'Call Discussion insert failed');
        		List<Call2_Discussion_vod__c> qCallDisc = [select id, Call2_vod__c, Account_vod__c, Comments__c from Call2_Discussion_vod__c where Id=: callDisc.id];
        		System.assertNotEquals(qcallDisc[0].id, null, 'Call Discussion insert failed');
        		qcallDisc[0].Comments__c='UPDATE COMMENT';
        		update qCallDisc;
        		List<Call2_Discussion_vod__c> qCallDiscU = [select id, Call2_vod__c, Account_vod__c, Comments__c from Call2_Discussion_vod__c where Id=: callDisc.id];
        		System.assertEquals(qcallDiscU[0].Comments__c,'UPDATE COMMENT', 'Call Discussion Update failed');
        		delete qCallDiscU;
        		Test.stopTest();
        		List<Call2_Discussion_vod__c> qCallDiscD = [select id, Call2_vod__c, Account_vod__c, Comments__c from Call2_Discussion_vod__c where Id=: callDisc.id];
        		System.assertEquals(qcallDiscD.size(), 0, 'Call Discussion Update failed');
        		/*undelete just for coverage since it doesn't have any logic*/
                undelete qCallDiscU;
        	}catch(Exception e){
        		System.debug(e.getMessage());
        		System.assert(false, e.getMessage());
        	}
        }
    }
    
    private static testMethod void testBeforeCallDiscussionProcessing() {
     	User sfa2User = GNE_SFA2_Util.selectSFA2User();
        System.runAs(sfa2User){
        	try{
        		Call2_vod__c call = getCall();
        		Call2_Discussion_vod__c callDisc = getCallDiscussion(call);
        		Test.startTest();
        		insert callDisc;
        		System.assertNotEquals(callDisc.id, null, 'Call Discussion insert failed');
        		List<Call2_Discussion_vod__c> qCallDisc = [select id, Call2_vod__c, Account_vod__c, Comments__c from Call2_Discussion_vod__c where Id=: callDisc.id];
        		System.assertNotEquals(qcallDisc[0].id, null, 'Call Discussion insert failed');
        		qcallDisc[0].Comments__c='UPDATE COMMENT';
        		update qCallDisc;
        		List<Call2_Discussion_vod__c> qCallDiscU = [select id, Call2_vod__c, Account_vod__c, Comments__c from Call2_Discussion_vod__c where Id=: callDisc.id];
        		System.assertEquals(qcallDiscU[0].Comments__c,'UPDATE COMMENT', 'Call Discussion Update failed');
        		try{
        			qCallDiscU[0].Attendee_Type_vod__c='Person_Account_vod';
        			qCallDiscU[0].Entity_Reference_Id_vod__c=call.Account_vod__c;
        			call.Status_vod__c = 'Submitted_vod';
        			update call;
        			update qCallDiscU;
        		}catch(Exception e){
        			System.debug(e.getMessage());
        			System.assert(e.getMessage().contains(System.Label.GNE_SFA2_Submitted_Call_Update_error), e.getMessage());
        		}
        		try{
        			qCallDiscU[0].Attendee_Type_vod__c='User_vod';
        			qCallDiscU[0].Entity_Reference_Id_vod__c=sfa2User.id;
        			qCallDiscU[0].Override_Lock_vod__c = true;
        			update qCallDiscU;
        		}catch(Exception e){
        			System.debug(e.getMessage());
        			System.assert(e.getMessage().contains(System.Label.GNE_SFA2_Submitted_Call_Update_error), e.getMessage());
        		}
        		try{
        			call.Status_vod__c = 'Submitted_vod';
        			delete qCallDiscU;
        		}catch(Exception e){
        			System.debug(e.getMessage());
        			System.assert(e.getMessage().contains(System.Label.GNE_SFA2_Submitted_Call_Delete_Error), e.getMessage());
        		}
        		Test.stopTest();
        		List<Call2_Discussion_vod__c> qCallDiscD = [select id, Call2_vod__c, Account_vod__c, Comments__c from Call2_Discussion_vod__c where Id=: callDisc.id];
        		System.assertEquals(qcallDiscD.size(), 1, 'Call Discussion Update failed');
        	}catch(Exception e){
        		System.debug(e.getMessage());
        		System.assert(false, e.getMessage());
        	}
        }
    }
    
    private static testMethod void testMedAffairsMoleculeChange() {
     	User sfa2User = GNE_SFA2_Util.selectSFA2User();
        insert new MedAffairs_Molecules_gne__c(Name='Molecule-3', Molecule_Name_gne__c='Pipeline Cross Portfolio');
        insert new Product_vod__c(Name='Non-Commercial Molecule');
        System.runAs(sfa2User){
        	try{
        		Call2_vod__c call = getCall();
        		Test.startTest();
        		Call2_Discussion_vod__c callDisc = getCallDiscussion(call);
        		callDisc.RecordTypeId='01270000000DyvaAAC';
        		Product_vod__c prod =new Product_vod__c(Name='Pipeline Cross Portfolio', DETAIL_PRODUCT_SUBTYPE_CODE_GNE__C='TheraDisease');
        		insert prod;
        		System.assert(prod!= null, 'Product Insert Failed');
        		callDisc.product_vod__c = prod.id;
        		insert callDisc;
        		System.assertNotEquals(callDisc.id, null, 'Call Discussion insert failed');
        		List<Call2_Discussion_vod__c> qCallDisc = [select id, Call2_vod__c, Account_vod__c, Comments__c, Molecule_gne__c from Call2_Discussion_vod__c where Id=: callDisc.id];
        		System.assertEquals(qcallDisc[0].Molecule_gne__c, 'Pipeline Cross Portfolio', 'Molecule Name is not updated on Call Discussion');
        		update qCallDisc;
        		Test.stopTest();
        		List<Call2_Discussion_vod__c> qCallDiscU = [select id, Call2_vod__c, Account_vod__c, Comments__c,  Molecule_gne__c from Call2_Discussion_vod__c where Id=: callDisc.id];
        		System.assertEquals(qcallDiscU[0].Molecule_gne__c, 'Pipeline Cross Portfolio',  'Molecule Name is not updated on Call Discussion');
        		
        	}catch(Exception e){
        		System.debug(e.getMessage());
        		System.assert(false, e.getMessage());
        	}
        }
    }
    private static testMethod void testFRMAccountTacticUpdate() {
     	User sfa2User = GNE_SFA2_Util.selectSFA2User();
        System.runAs(sfa2User){
        	try{
        		Call2_vod__c call = getCall();
        		Test.startTest();
        		Call2_Discussion_vod__c callDisc = getCallDiscussion(call);
        		callDisc.RecordTypeId='01270000000DyvaAAC';
        		Account_Tactic_vod__c tactic =new Account_Tactic_vod__c(Name='Test Tactic', Account_vod__c=call.Account_vod__c);
        		insert tactic;
        		System.assert(tactic!= null, 'Account Tactic  Insert Failed');
        		callDisc.Account_Tactic_vod__c = tactic.id;
        		insert callDisc;
        		System.assertNotEquals(callDisc.id, null, 'Call Discussion insert failed');
        		List<Call2_Discussion_vod__c> qCallDisc = [select id, Call2_vod__c, Account_vod__c, Comments__c, Account_Tactic_vod__c, FRM_Account_Tactic_Name_gne__c from Call2_Discussion_vod__c where Id=: callDisc.id];
        		System.assertEquals(qcallDisc[0].FRM_Account_Tactic_Name_gne__c, 'Test Tactic', 'Molecule Name is not updated on Call Discussion');
        		
        		Account_Tactic_vod__c tactic1 =new Account_Tactic_vod__c(Name='Test Tactic1', Account_vod__c=call.Account_vod__c);
        		insert tactic1;
        		System.assert(tactic1!= null, 'Account Tactic  Insert Failed');
        		qCallDisc[0].Account_Tactic_vod__c = tactic1.id;
        		
        		update qCallDisc;
        		Test.stopTest();
        		List<Call2_Discussion_vod__c> qCallDiscU = [select id, Call2_vod__c, Account_vod__c, Comments__c,  Account_Tactic_vod__c, FRM_Account_Tactic_Name_gne__c from Call2_Discussion_vod__c where Id=: callDisc.id];
        		System.assertEquals(qcallDiscU[0].FRM_Account_Tactic_Name_gne__c, 'Test Tactic1',  'Molecule Name is not updated on Call Discussion');
        		
        	}catch(Exception e){
        		System.debug(e.getMessage());
        		System.assert(false, e.getMessage());
        	}
        }
    }
    
    private static testMethod void testAssosiateChildCallMedicalEventToParentCall() {
     	User sfa2User = GNE_SFA2_Util.selectSFA2User();
        System.runAs(sfa2User){
        	try{
        		Call2_vod__c call = getCall();
        		Test.startTest();
        		Call2_Discussion_vod__c callDisc = getCallDiscussion(call);
        		callDisc.RecordTypeId='01270000000DyvaAAC';
        		Medical_Event_vod__c medEvent = new Medical_Event_vod__c(name='Test Event', Active_vod__c= true, Description_vod__c='Test Medical Event', Start_Date_vod__c = System.Now().date(),  End_Date_vod__c = System.Now().date()+1);
				insert medEvent;
				System.assert(medEvent.id != null, 'Medical Event insert failed');
				
				Medical_Event_vod__c medEvent1 = new Medical_Event_vod__c(name='Test Event1', Active_vod__c= true, Description_vod__c='Test Medical Event', Start_Date_vod__c = System.Now().date(),  End_Date_vod__c = System.Now().date()+1, parent_medical_event_gne__c=medEvent.id);
				insert medEvent1;
				System.assert(medEvent1.id != null, 'Medical Event insert failed');
				
        		callDisc.Medical_Event_vod__c = medEvent1.id;
        		insert callDisc;
        		Test.stopTest();
        		System.assertNotEquals(callDisc.id, null, 'Call Discussion insert failed');
        		List<Call2_Discussion_vod__c> qCallDisc = [select id, Call2_vod__c, Account_vod__c,Medical_Event_vod__c, Medical_Event_vod__r.name from Call2_Discussion_vod__c where Id=: callDisc.id];
        		System.assertEquals(qcallDisc[0].Medical_Event_vod__c, medEvent.id, 'Molecule Name is not updated on Call Discussion');
        	}catch(Exception e){
        		System.debug(e.getMessage());
        		System.assert(false, e.getMessage());
        	}
        }
    }
    
    private static testMethod void testOTRDeletedRecordsCreation(){
        System.runAs(GNE_SFA2_Util.selectSFA2User()){
            try{
                Call2_Discussion_vod__c callDisc = getCallDiscussion(getCall());
                insert callDisc;
                Test.startTest();
                    delete callDisc;
                Test.stopTest();
                String nameOfDeletedObject = GNE_SFA2_Deleted_Records_Util.getOtrObjectNameForObjectType(Call2_Discussion_vod__c.getSObjectType());
                List<OTR_Deleted_Record_gne__c> deletedRecords  =  [SELECT id, name,Object_name__c,Deleted_Record_Id__c,Parent_Account_Id_gne__c   FROM OTR_Deleted_Record_gne__c WHERE Object_name__c LIKE :nameOfDeletedObject];
                System.assertEquals(1, deletedRecords.size());
            }catch(Exception e){
                System.debug(e.getMessage());
                System.assert(false, e.getMessage());
            }
        }
    }
    
   
    
}