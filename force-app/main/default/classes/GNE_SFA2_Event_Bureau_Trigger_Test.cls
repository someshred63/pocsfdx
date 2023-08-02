/************************************************************
*  @author: Rakesh Boinepalli 
*  Date: 2012-12-14
*  Description: This is a test class for GNE_SFA2_Event_Bureau_Trigger trigger
*  
*  Modification History
*  Date         Name                Description
*  2014-02-03   Piotr Przesmycki    Fixed unit test
*  2014-02-20   Piotr Przesmycki    Using GNE_SFA2_Trigger_Test_Util to prepare data
*************************************************************/
@isTest
public with sharing class GNE_SFA2_Event_Bureau_Trigger_Test {
    
    public static testMethod void testEventBureauFieldUpdates() {
        User sfa2User = GNE_SFA2_Util.selectSFA2User();
        if(sfa2User!=null){
            System.runAs(sfa2User){
                Medical_Event_vod__c med = GNE_SFA2_Triggers_Test_Util.prepareMedical_Event_vod(Date.today()-1, Date.today());
                med.Event_Type_gne__c='test';

                Speaker_Bureau_gne__c sp = GNE_SFA2_Triggers_Test_Util.prepareSpeaker_Bureau_gne('testId');
                sp.Name = 'test';

                insert med;
                insert sp;
                if(med!=null && sp!=null){
                    Event_Bureaus_gne__c event_b = new Event_Bureaus_gne__c(Medical_Event_gne__c = med.Id,Speaker_Bureau_gne__c=sp.Id);
                    try{
                        insert event_b;
                        /*if(med.Event_Type_gne__c!=null && med.Event_Type_gne__c.length()>0){
                            System.assert(med.Event_Type_gne__c==event_b.Event_Type_gne__c);
                        }*/
                        system.debug('med:'+med.Event_Type_gne__c+' event: '+event_b.Event_Type_gne__c);
                        if(med.Status_gne__c!=null && med.Status_gne__c.length()>0){
                            sYSTEM.DEBUG('***' + med.Status_gne__c + '***' + event_b.Event_Status_gne__c );
                            System.assert(med.Status_gne__c==event_b.Event_Status_gne__c);
                        }
                        if(med.Brands_gne__c!=null && med.Brands_gne__c.length()>0){
                            System.assert(med.Brands_gne__c==event_b.Brands_gne__c);
                        }
                        if(med.Indications_gne__c!=null && med.Indications_gne__c.length()>0){
                            System.assert(med.Indications_gne__c==event_b.Indications_gne__c);
                        }
                        if(med.Parent_Site_gne__c!=null){
                            System.assert(med.Parent_Site_gne__c==event_b.Parent_Site_gne__c);
                        }
                    } catch(Exception e){
                        System.assert(false);
                        System.debug('Failed insertion' + e.getMessage());
                    }
                }
            }
        }
    }
}