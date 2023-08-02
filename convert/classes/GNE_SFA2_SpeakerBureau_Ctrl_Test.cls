@isTest
public class GNE_SFA2_SpeakerBureau_Ctrl_Test {

	@testSetup
	public static void setupData() {
		createBureau();
		createPageConfig();
	}

	@isTest
	public static void shouldShowSpeakerBureau() {
		//given
		Speaker_Bureau_gne__c bureau = getBureau();
		GNE_SFA2_SpeakerBureau_Ctrl ctrl = new GNE_SFA2_SpeakerBureau_Ctrl();
		PageReference currentPage = Page.GNE_SFA2_SpeakerBureau;
		currentPage.getParameters().put('Id', bureau.Id);
		Test.setCurrentPage(currentPage);

		//when
		GNE_SFA2_Base_Ctrl.DataWrapper result = ctrl.saveRecord(ctrl.constructorDataJSON);

		//then
		System.assertNotEquals(null, result);
	}

	private static Speaker_Bureau_gne__c getBureau() {
		return [SELECT Id, Name FROM Speaker_Bureau_gne__c LIMIT 1];
	}

	private static Speaker_Bureau_gne__c createBureau() {
		Speaker_Bureau_gne__c bureau = new Speaker_Bureau_gne__c(Name='Bureau',Speaker_Bureau_Type_gne__c = 'Business');
		insert bureau;
		return bureau;
	}

	private static void createPageConfig() {
		SFA2_Configuration_Object_gne__c confObject = new SFA2_Configuration_Object_gne__c();
		confObject.Name = 'Speaker_Bureau_gne__c_detail';
		confObject.Application_Type__c = null;
		confObject.Brand_gne__c = null;
		confObject.Role_gne__c = null;
		confObject.Record_Type_gne__c = null;
		confObject.Configuration_Type_gne__c = 'Page';
		confObject.Is_Active_gne__c = true;
		confObject.Object_Name_gne__c = 'Speaker_Bureau_gne__c';
		confObject.Order_gne__c = 0;
		confObject.OTR2_gne__c = false;
		confObject.Section_Header_gne__c = 'Header';
		insert confObject;

		SFA2_Configuration_Object_Detail_gne__c fieldDetail = new SFA2_Configuration_Object_Detail_gne__c();
        fieldDetail.Configuration_Object_ref_gne__c = confObject.Id;
        fieldDetail.API_Name_gne__c = 'Name';
        fieldDetail.Availability_Mode_gne__c = 'View;New;Edit';
        fieldDetail.Is_Active_gne__c = true;
        fieldDetail.Label_gne__c ='Name';
        fieldDetail.Order_gne__c = 0;
        fieldDetail.Type_gne__c = 'Field';
        fieldDetail.Is_Read_Only_gne__c =false;
        insert fieldDetail;
	}
}