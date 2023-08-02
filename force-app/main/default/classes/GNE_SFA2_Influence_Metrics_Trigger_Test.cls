/************************************************************
*  @author:unknown
*  Date: unknown
*  Description: This is a test class for GNE_SFA2_Influence_Metrics_Trigger trigger
*  
*  Modification History
*  Date         Name                Description
*  2014-02-05   Piotr Przesmycki    Fixed and improved unit test, removed SeeAllData annotation, added header to class
*  2014-02-20   Piotr Przesmycki    Using GNE_SFA2_Trigger_Test_Util to prepare data
*************************************************************/
@isTest
public with sharing class GNE_SFA2_Influence_Metrics_Trigger_Test {
	
	
    private static void insertAccounts(){
    	List<Account> accs = new List<Account>();
        Account testAccount1 = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('TestAccount1');
        testAccount1.MDMID_gne__c='aaaaaa';
        Account testAccount2 = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('TestAccount2');
        testAccount2.MDMID_gne__c='bbbbbb';
        accs.add(testAccount1);
        accs.add(testAccount2);
        insert accs;  
    }
    
    public static Influence_Metrics_gne__c getInfMetric(){	
    	Influence_Metrics_gne__c infM = new Influence_Metrics_gne__c(Target_Physician_MDM_ID_gne__c='aaaaaa',Related_Physician_MDM_ID_gne__c='bbbbbb');
    	return infM;
    }
    
    public static testMethod void testInsert(){ 
    	User sfa2User = GNE_SFA2_Util.selectSFA2User();
        if(sfa2User!=null){
        	System.runAs(sfa2User){
        		insertAccounts();
        		try{
        			Influence_Metrics_gne__c infM = getInfMetric();
                    Test.startTest();
        			insert infM;
                    Test.stopTest();
                    infM=[SELECT Id, Target_Physician_gne__c, Related_Physician_gne__c FROM Influence_Metrics_gne__c WHERE Id=:infM.Id LIMIT 1];
        			System.assert(infM.Target_Physician_gne__c!=null);
        		    System.assert(infM.Related_Physician_gne__c!=null);
        		} catch(Exception e){
        			System.assert(false,e.getMessage());
        		}
        		
        	}
        }
    }
     
    public static testMethod void testUpdate(){ 
        User sfa2User = GNE_SFA2_Util.selectSFA2User();
        if(sfa2User!=null){
        	Test.startTest();
        	System.runAs(sfa2User){
        		insertAccounts();
        		try{
        			Influence_Metrics_gne__c infM = getInfMetric();
        			insert infM;
        			infM.Self_Influence_gne__c=24;
        			update infM;
                    infM=[SELECT Id, Target_Physician_gne__c, Related_Physician_gne__c FROM Influence_Metrics_gne__c WHERE Id=:infM.Id LIMIT 1];
        			System.assert(infM.Target_Physician_gne__c!=null);
        		    System.assert(infM.Related_Physician_gne__c!=null);
        		} catch(Exception e){
        			System.assert(false,e.getMessage());
        		}
        		Test.stopTest();
        	}
        }
    }
    
}