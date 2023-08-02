/************************************************************************************
Name   : gne_CalendarTestUtility
Created: Nov 11th 2009 
Author : Vinod Koosam @ Appirio
Usage  : A general test class for all new and future implementations for Unified 
Calendar app. 
*************************************************************************************/
@isTest
private class gne_CalendarTestUtility {  
    
    static testMethod void createCallTest(){      
        try{            
            List<Account> tAccounts = [Select id from account limit 3];
            
            Call2_vod__c myCall    = new Call2_vod__c(Account_vod__c = tAccounts[0].id );                           
            Call2_vod__c myChildCall1    = new Call2_vod__c(Account_vod__c = tAccounts[1].id );
            Call2_vod__c myChildCall2    = new Call2_vod__c(Account_vod__c = tAccounts[2].id );
                                                                                                        
            Test.startTest();
                                        
            insert myCall;    
            myChildCall1.parent_call_vod__c = myCall.id;
            myChildCall2.parent_call_vod__c = myCall.id;
            insert myChildCall1;
            insert myChildCall2;
            
            myCall.Call_DateTime_vod__c = System.now();        
            update myCall;            
            
            delete myChildCall2;
            delete myCall;
            
            Test.stopTest();
            
        }catch(Exception nE){
            System.debug('gne_CalendarTestUtility.createCallTest exception ' + nE.getMessage());
        }
    }
    
    static testMethod void createUserPreferencesTest(){
        try{

            UnifiedCalendarUserEventPreference_gne__c pref = new UnifiedCalendarUserEventPreference_gne__c(name='test');

            Test.startTest();
                                        
            insert pref ;    
            
            pref.Name = 'test ' + System.now();        
            update pref;            
            
            delete pref;
            
            Test.stopTest();
                        
        }catch(Exception nE){
            System.debug('gne_CalendarTestUtility.createUserPreferencesTest exception ' + nE.getMessage());
        }            
    }

}