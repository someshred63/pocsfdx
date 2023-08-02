/************************************************************
*  @author:unknown
*  Date: unknown
*  Description: This is a test class for GNE_SFA2_Medical_Event_Trigger trigger
*  
*  Modification History
*  Date         Name                Description
*  2014-02-05   Piotr Przesmycki    Fixed and improved unit test, removed SeeAllData annotation, added header to class
*  2014-02-20   Piotr Przesmycki    Using GNE_SFA2_Trigger_Test_Util to prepare data
*************************************************************/
@isTest
public with sharing class GNE_SFA2_Medical_Event_Trigger_Test {
    
    public static testMethod void testInsert(){ 
        
        User sfa2User = GNE_SFA2_Util.selectSFA2User();
        if(sfa2User!=null){
            Test.startTest();
            System.runAs(sfa2User){
                try{
                    Medical_Event_vod__c mem = new Medical_Event_vod__c(Start_Date_vod__c=System.now().date(),End_Date_vod__c=System.now().date()-1);
                    insert mem;
                } catch(Exception e){
                    System.assert(true,e.getMessage());//this is expected. 
                }
            }
            Test.stopTest();
        }
    }
    
    public static Call2_vod__c getCall(Id medicalEventId){
        Account acc = getAcccount();
        Call2_vod__c call = GNE_SFA2_Triggers_Test_Util.prepareCall2_vod('No Collateral');
        call.Medical_Event_vod__c       = medicalEventId;
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
    
    public static Address_vod__c getAddress(Account testAccount){
        Address_vod__c address = GNE_SFA2_Triggers_Test_Util.prepareAddress_vod(testAccount.Id, '611 Gateway Blvd', true, 'Unit Test Address Name');
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
    
    public static Event_Attendee_vod__c getEventAttendee(Id medicalEventId,Id userId){
        
        Event_Attendee_vod__c event = GNE_SFA2_Triggers_Test_Util.prepareEvent_Attendee_vod(null, userId, null, medicalEventId);
        event.Role_gne__c='Speaker';
        event.Signature_Datetime_vod__c = Datetime.now();
        try{
            insert event;
            return event;
        } catch(exception e){
            System.assert(false,e.getMessage());
        }
        return null;
    }    
    
    public static testMethod void testUpdate(){ 
        
        User sfa2User = GNE_SFA2_Util.selectSFA2User();
        if(sfa2User!=null){
            Test.startTest();
            System.runAs(sfa2User){
                Medical_Event_vod__c mems;
                try{
                    mems = GNE_SFA2_Triggers_Test_Util.prepareMedical_Event_vod(Date.today()-1, Date.today());
                    insert mems;
                    mems.Start_Date_vod__c = Date.today()+1;
                    try{
                        update mems;
                    } catch(Exception e){
                        System.assert(true, e.getMessage());//this is expected. 
                    }
                } catch(Exception e){
                    System.assert(false, e.getMessage());
                }
            }
            Test.stopTest();
        }
    }
    
    public static testMethod void testDelete_1(){ 
        
        User sfa2User = GNE_SFA2_Util.selectSFA2User();
        if(sfa2User!=null){
            Test.startTest();
            System.runAs(sfa2User){
                Medical_Event_vod__c mems;
                try{
                    mems = GNE_SFA2_Triggers_Test_Util.prepareMedical_Event_vod(Date.today()-1, Date.today());
                    insert mems;
                    Call2_vod__c call = getCall(mems.Id);
                    insert call;
                    Call2_Discussion_vod__c callD = GNE_SFA2_Triggers_Test_Util.prepareCall2_Discussion_vod(call.Id);
                    callD.Medical_Event_vod__c=mems.Id;
                    insert callD;
                    System.assert(true,'this part should complete');
                } catch(Exception e){
                    System.assert(false,e.getMessage());
                }
                try{
                    delete mems;
                    system.assert(false,'It should fail');
                } catch(Exception e){
                    System.assert(true,e.getMessage());
                }
            }
            Test.stopTest();
        }
    }
    
    public static testMethod void testDelete_2(){ 
        
        User sfa2User = GNE_SFA2_Util.selectSFA2User();
        if(sfa2User!=null){
            Test.startTest();
            System.runAs(sfa2User){
                Medical_Event_vod__c mems;
                try{
                    mems = GNE_SFA2_Triggers_Test_Util.prepareMedical_Event_vod(Date.today()-1, Date.today());
                    insert mems;
                    Event_Attendee_vod__c event = getEventAttendee(mems.Id,sfa2User.Id);
                    System.assert(true,'this part should complete');
                } catch(Exception e){
                    System.assert(false,e.getMessage());
                }
                try{
                    delete mems;
                    system.assert(false,'It should fail');
                } catch(Exception e){
                    System.assert(true,e.getMessage());
                }
            }
            Test.stopTest();
        }
    }
}