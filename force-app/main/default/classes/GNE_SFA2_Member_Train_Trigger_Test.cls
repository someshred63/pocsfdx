/************************************************************
*  @author:unknown
*  Date: unknown
*  Description: This is a test class for GNE_SFA2_Membership_Training_Trigger trigger
*  
*  Modification History
*  Date         Name                	Description
*  2014-02-05   Piotr Przesmycki    	Fixed and improved unit test, removed SeeAllData annotation, added header to class   
*  2014-02-21   Piotr Przesmycki    	Using GNE_SFA2_Trigger_Test_Util to prepare data
*  2015-07-08   Przemyslaw Giszczak 	Add status to Speaker_Bureau_Membership_gne__c against DmlException
*************************************************************/
@isTest
public with sharing class GNE_SFA2_Member_Train_Trigger_Test {
	/************************************
	*	note that validation rules executed on trigger prevents only the situation, 
	*	where both Speaker_Bureau_Membership_gne__c and Speaker_Training_gne__c fields are empty.
	*	on the Member_Trainings_gne__c object however there is a validation rule, that prevents the situation,
	*	where only one field is missing - if GNE_SFA2_User_App_Context_gne__c.SFA2_Mode_gne__c is set to false
	*************************************/
	public static testMethod void testInsertAndUpdate(){ 
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2User!=null){
			Test.startTest();
			System.runAs(sfa2User){
				Speaker_Bureau_gne__c sb = GNE_SFA2_Triggers_Test_Util.prepareSpeaker_Bureau_gne('test');
                insert sb;

                Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('test');
                insert acc;

                Speaker_Bureau_Membership_gne__c sbm = GNE_SFA2_Triggers_Test_Util.prepareSpeaker_Bureau_Membership_gne(sb.Id, acc.Id, 'Approved');
                insert sbm;

                Speaker_Training_gne__c st = GNE_SFA2_Triggers_Test_Util.prepareSpeaker_Training_gne(Date.today());
                insert st;
                
				Member_Trainings_gne__c mem = new Member_Trainings_gne__c();
				try{
					insert mem;
					system.assert(false,'this should fail due to missing required fields');
				}catch(DMLException ex){
					system.assertEquals(ex.getDmlType(0),StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION); 
				}
				mem.Speaker_Bureau_Membership_gne__c=sbm.Id;
				try{
					insert mem;
					system.assert(false,'this should fail due to missing required fields');
				} catch(DMLException ex){
					system.assertEquals(ex.getDmlType(0),StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION); 
				}
				mem = new Member_Trainings_gne__c(Speaker_Training_gne__c=st.Id);
				try{
					insert mem;
					system.assert(false,'this should fail due to missing required fields');
				} catch(DMLException ex){
					system.assertEquals(ex.getDmlType(0),StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION); 
				}
				mem = new Member_Trainings_gne__c(Speaker_Bureau_Membership_gne__c=sbm.Id, Speaker_Training_gne__c=st.Id);
				try{
					insert mem;
				} catch(Exception ex){
					system.assert(false, 'this time it should succeed'+ex.getMessage());
				}
				mem.Speaker_Bureau_Membership_gne__c=null;
				try{
					update mem;
					system.assert(false,'It should fail due to missing required fields');
				}catch(DMLException ex){
					system.assertEquals(ex.getDmlType(0),StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION); 
				}
			}
			Test.stopTest();
		}
	}
}