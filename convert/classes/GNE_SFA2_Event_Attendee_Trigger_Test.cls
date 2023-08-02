/************************************************************
*  @author: Rakesh Boinepalli 
*  Date: 2012-12-13
*  Description: This is a test class for GNE_SFA2_Event_Attendee_Trigger trigger
*  
*  Modification History
*  Date        	Name        		Description
*  2014-02-03  	Piotr Przesmycki	Fixed unit test
*  2014-02-20   Piotr Przesmycki    Using GNE_SFA2_Trigger_Test_Util to prepare data
*  2014-12-03   Mateusz Michalczyk  Added after delete logic test for OTR_Deleted_Record_gne__c record creation. (testEventAttendeeOTRDeletedRecordCreation)
*
*************************************************************/
@isTest
public with sharing class GNE_SFA2_Event_Attendee_Trigger_Test {
	
	public static testMethod void testEventAttendeeValidations() { 
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2User!=null){
			System.runAs(sfa2User){
				boolean isDMLSuccess = true;
				Medical_Event_vod__c med = GNE_SFA2_Triggers_Test_Util.prepareMedical_Event_vod(Date.today()-1, Date.today());
				med.Event_Type__c='test';
				insert med;
				med = GNE_SFA2_Event_Attendee_Trigger_Helper.getMedicalEvent();
				Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('test');
				insert acc;
				Contact con = GNE_SFA2_Triggers_Test_Util.prepareContact('test');
				con.Account = acc;
				insert con;
				
				Event_Attendee_vod__c event = new Event_Attendee_vod__c();
				try{
					insert event;
				} catch(Exception e){
				 	System.assert(event.id==null);
				}
				
				if(med!=null){
					Event_Attendee_vod__c event1,event2,event3,event4;
				 	List<Event_Attendee_vod__c> events = new List<Event_Attendee_vod__c>();
				 	
				 	event1 = new Event_Attendee_vod__c(Medical_Event_vod__c=med.Id,Role_gne__c='Speaker', Account_vod__c=acc.Id, Contact_vod__c=con.Id, User_vod__c=sfa2User.Id) ; 
				 	event2 = new Event_Attendee_vod__c(Medical_Event_vod__c=med.Id,Role_gne__c='Speaker', Account_vod__c=acc.Id, User_vod__c=sfa2User.Id) ;
				 	event3 = new Event_Attendee_vod__c(Medical_Event_vod__c=med.Id,Role_gne__c='Speaker', Contact_vod__c=con.Id, User_vod__c=sfa2User.Id) ;
				 	event4 = new Event_Attendee_vod__c(Medical_Event_vod__c=med.Id,Role_gne__c='Speaker', Account_vod__c=acc.Id, Contact_vod__c=con.Id) ;
				 	events.add(event1);events.add(event2);events.add(event3);events.add(event4);
				 	
			 		Database.SaveResult[] res = Database.insert(events,false);
			 		for (Database.SaveResult dsr : res){
			 			system.assert(!dsr.isSuccess(),'events shouldn\'t insert because of validation rules');
			 		}
				}
			}
		}
	}
	
	public static testMethod void testEventAttendeeFieldUpdates() {
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		List<Event_Attendee_vod__c> events = new List<Event_Attendee_vod__c>();
		if(sfa2User!=null){
			System.runAs(sfa2User){
				Medical_Event_vod__c med = GNE_SFA2_Triggers_Test_Util.prepareMedical_Event_vod(Date.today()-1, Date.today());
				med.Event_Type__c='test';
				insert med;
				med = GNE_SFA2_Event_Attendee_Trigger_Helper.getMedicalEvent();
				Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('test');
				insert acc;
				Contact con = GNE_SFA2_Triggers_Test_Util.prepareContact('test');
				con.Account = acc;
				insert con;
				if(acc!=null && con!=null && med!=null){
				    Event_Attendee_vod__c event1  = new Event_Attendee_vod__c(Medical_Event_vod__c=med.Id,Role_gne__c='Speaker',Account_vod__c=acc.Id,Signature_Datetime_vod__c=System.now()) ;
					Event_Attendee_vod__c event2  = new Event_Attendee_vod__c(Medical_Event_vod__c=med.Id,Role_gne__c='Speaker',Contact_vod__c=con.Id,Signature_Datetime_vod__c=System.now()) ;  
					Event_Attendee_vod__c event3  = new Event_Attendee_vod__c(Medical_Event_vod__c=med.Id,Role_gne__c='Speaker',User_vod__c=sfa2User.Id,Signature_Datetime_vod__c=System.now()) ; 
					events.add(event1); events.add(event2); events.add(event3); 
					processDeletionTest(events);
					events.clear();
					Event_Attendee_vod__c event4  = new Event_Attendee_vod__c(Medical_Event_vod__c=med.Id,Role_gne__c='Speaker',Account_vod__c=acc.Id);
					Event_Attendee_vod__c event5  = new Event_Attendee_vod__c(Medical_Event_vod__c=med.Id,Role_gne__c='Speaker',Contact_vod__c=con.Id) ;
					Event_Attendee_vod__c event6  = new Event_Attendee_vod__c(Medical_Event_vod__c=med.Id,Role_gne__c='Speaker',User_vod__c=sfa2User.Id) ;
					events.add(event4); events.add(event5); events.add(event6); 
					processFieldUpdatesTest(events);
					events.clear();
					event4  = new Event_Attendee_vod__c(Medical_Event_vod__c=med.Id,Role_gne__c='Speaker',Account_vod__c=acc.Id);
					event5  = new Event_Attendee_vod__c(Medical_Event_vod__c=med.Id,Role_gne__c='Speaker',Account_vod__c=acc.Id) ;
					event6  = new Event_Attendee_vod__c(Medical_Event_vod__c=med.Id,Role_gne__c='Speaker',Account_vod__c=acc.Id) ;
					events.add(event4); events.add(event5); events.add(event6); 
					try{
						insert events;
						delete events;
						system.assert(true,'It should succeed now');
					} catch(Exception ex){
						system.assert(false,'It should have succeeded');
					}

				}
			}
		}
	}
	
	public static testMethod void testEventAttendeeOTRDeletedRecordCreation(){
		Medical_Event_vod__c med = GNE_SFA2_Triggers_Test_Util.prepareMedical_Event_vod(Date.today()-1, Date.today());
		insert med;
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('test');
		insert acc;
		Event_Attendee_vod__c  attendee = GNE_SFA2_Triggers_Test_Util.prepareEvent_Attendee_vod(acc.id, null, null, med.id);
		insert attendee;
		Test.startTest();
		try{
			delete attendee;
		} catch (DmlException e ){
			System.assert(false, 'attendee deletion failed');
		}
		Test.stopTest();
		String idOfDeletedRecord = String.valueOf(attendee.id);
		List<OTR_Deleted_Record_gne__c> deletedRecords  =  [SELECT id, name,Object_name__c,Deleted_Record_Id__c,Parent_Account_Id_gne__c   FROM OTR_Deleted_Record_gne__c WHERE Deleted_Record_Id__c=:idOfDeletedRecord];
		System.assertEquals(1, deletedRecords.size());

	}

	public static void processDeletionTest(List<Event_Attendee_vod__c> events){
		boolean isSuccess=true;
		try{
			Database.insert(events,false);
		} catch(Exception e){
			isSuccess=false;
			System.debug('DML Exception' + e.getMessage());
		}
		if(isSuccess){
			try{
				delete events;
			} catch(Exception ex){
				System.assertEquals('FIELD_CUSTOM_VALIDATION_EXCEPTION' , ex.getDmlStatusCode(0));
			}
		} else{
			Medical_Event_vod__c med =GNE_SFA2_Event_Attendee_Trigger_Helper.getMedicalEvent();
			Account acc = [select Id,Name from Account limit 1];
			Event_Attendee_vod__c event = new Event_Attendee_vod__c(Medical_Event_vod__c=med.Id,Role_gne__c='Speaker',Account_vod__c=acc.Id,Signature_Datetime_vod__c=System.now());
			try{
				insert event;
				update event;
				delete event;
			}
			catch(Exception e){
				System.debug('deletion failed');
			}
		}
	}

	public static void processFieldUpdatesTest(List<Event_Attendee_vod__c> events){
		boolean isSuccess=true;
		try{
			Database.insert(events,false);
		} catch(Exception e){
			isSuccess=false;
			System.debug('DML Exception' + e.getMessage());
		}
		if(isSuccess){
		  	for(Event_Attendee_vod__c event : events){
		  		if(event.Account_vod__c!=null){
					System.assert(event.Attendee_vod__c==event.Account_vod__r.Name);
				} else if(event.Contact_vod__c!=null){
					System.assert(event.Attendee_vod__c==event.Contact_vod__r.Name);
				} else if(event.user_vod__c!=null){
					System.assert(event.Attendee_vod__c==event.User_vod__r.Name);
				}
		  	}
		  	try{
		  		update events;
		  	} catch(Exception e){
		  		System.debug('error updating records');
		  	}
		}
	}
}