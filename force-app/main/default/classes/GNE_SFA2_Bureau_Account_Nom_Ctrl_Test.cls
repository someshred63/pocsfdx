@isTest
private class GNE_SFA2_Bureau_Account_Nom_Ctrl_Test{

	public static testMethod void singleNominationConstructorTest(){
		Account acc = new Account(
			Name = 'Test Account',
			AGS_EX_Exclusion_Status_base_gne__c = '',
			EDM_Clinical_Classification_gne__c = '',
			EDM_Business_Classification_gne__c = ''
		);
		insert acc;

		ApexPages.currentPage().getParameters().put('Id',acc.Id);
		GNE_SFA2_Bureau_Account_Nomination_Ctrl ctrl = new GNE_SFA2_Bureau_Account_Nomination_Ctrl();

		System.assert(!ctrl.showPopupMessageOrError);
		System.assertEquals(acc.Id,ctrl.account.Id);
	}

	public static testMethod void multipleNominationConstructorNewWrapperTest(){
		
		Speaker_Bureau_gne__c businessBureau = new Speaker_Bureau_gne__c(Name = 'TestBureau',Speaker_Bureau_Type_gne__c = 'Business');
		insert businessBureau;

		ApexPages.currentPage().getParameters().put('retBureau',businessBureau.Id);
		ApexPages.currentPage().getParameters().put('multiple','true');

		GNE_SFA2_Bureau_Account_Nomination_Ctrl ctrl = new GNE_SFA2_Bureau_Account_Nomination_Ctrl();

		System.assert(!ctrl.showPopupMessageOrError);
	}

	public static testMethod void multipleNominationConstructorTest(){
		
		Speaker_Bureau_gne__c businessBureauLY = new Speaker_Bureau_gne__c(Name = 'TestBureau_LastYear',Speaker_Bureau_Type_gne__c = 'Business');
		insert businessBureauLY;

		List<Account> accnts = new List<Account>();
		accnts.add(new Account(
			Name = 'Test Account',
			AGS_EX_Exclusion_Status_base_gne__c = 'Not checked'
		));
		accnts.add(new Account(
			Name = 'Test Account',
			AGS_EX_Exclusion_Status_base_gne__c = 'Check pending'
		));
		insert accnts;
		List<Speaker_Bureau_Membership_gne__c> sbm = new List<Speaker_Bureau_Membership_gne__c>();
		for(Account a : accnts){
			sbm.add(new Speaker_Bureau_Membership_gne__c(
				Bureau_Member_gne__c = a.Id,
				Speaker_Bureau_ID_gne__c = businessBureauLY.Id,
				Speaker_Status_gne__c = 'Nominated'
			));
		}
		insert sbm;

		String wrapper = '';
		Integer i = sbm.size();
		for(Speaker_Bureau_Membership_gne__c s : sbm){
			wrapper += s.Id;
			i--;
			if(i>0) wrapper += ';';
		}
		System.debug('### '+wrapper);
		EDM_Multiple_Nomination_Wrapper__c wrapperOb = new EDM_Multiple_Nomination_Wrapper__c(
			EDM_Multiple_Nomination_Ids__c = wrapper
		);
		insert wrapperOb;
		Speaker_Bureau_gne__c businessBureau = new Speaker_Bureau_gne__c(
			Name = 'TestBureau',
			Speaker_Bureau_Type_gne__c = 'Business',
			Last_Year_Speaker_Bureau_gne__c = businessBureauLY.Id
		);
		insert businessBureau;

		ApexPages.currentPage().getParameters().put('retBureau',businessBureau.Id);
		ApexPages.currentPage().getParameters().put('multiple','true');
		ApexPages.currentPage().getParameters().put('wrapperId',wrapperOb.Id);

		GNE_SFA2_Bureau_Account_Nomination_Ctrl ctrl = new GNE_SFA2_Bureau_Account_Nomination_Ctrl();

		System.assert(!ctrl.showPopupMessageOrError);
	}

	public static testMethod void multipleNominationNextTest(){
		
		Speaker_Bureau_gne__c businessBureauLY = new Speaker_Bureau_gne__c(Name = 'TestBureau_LastYear',Speaker_Bureau_Type_gne__c = 'Business');
		insert businessBureauLY;

		List<Account> accnts = new List<Account>();
		accnts.add(new Account(
			Name = 'Test Account',
			AGS_EX_Exclusion_Status_base_gne__c = 'Not checked'
		));
		accnts.add(new Account(
			Name = 'Test Account',
			AGS_EX_Exclusion_Status_base_gne__c = 'Check pending'
		));
		insert accnts;
		List<Speaker_Bureau_Membership_gne__c> sbm = new List<Speaker_Bureau_Membership_gne__c>();
		for(Account a : accnts){
			sbm.add(new Speaker_Bureau_Membership_gne__c(
				Bureau_Member_gne__c = a.Id,
				Speaker_Bureau_ID_gne__c = businessBureauLY.Id,
				Speaker_Status_gne__c = 'Nominated'
			));
		}
		insert sbm;

		String wrapper = '';
		Integer i = sbm.size();
		for(Speaker_Bureau_Membership_gne__c s : sbm){
			wrapper += s.Id;
			i--;
			if(i>0) wrapper += ';';
		}
		System.debug('### '+wrapper);
		EDM_Multiple_Nomination_Wrapper__c wrapperOb = new EDM_Multiple_Nomination_Wrapper__c(
			EDM_Multiple_Nomination_Ids__c = wrapper
		);
		insert wrapperOb;
		Speaker_Bureau_gne__c businessBureau = new Speaker_Bureau_gne__c(
			Name = 'TestBureau',
			Speaker_Bureau_Type_gne__c = 'Business',
			Last_Year_Speaker_Bureau_gne__c = businessBureauLY.Id
		);
		insert businessBureau;

		ApexPages.currentPage().getParameters().put('retBureau',businessBureau.Id);
		ApexPages.currentPage().getParameters().put('multiple','true');
		ApexPages.currentPage().getParameters().put('wrapperId',wrapperOb.Id);

		GNE_SFA2_Bureau_Account_Nomination_Ctrl ctrl = new GNE_SFA2_Bureau_Account_Nomination_Ctrl();

		System.assert(!ctrl.showPopupMessageOrError);

		ctrl.next();

		System.assert(ctrl.showPopupMessageOrError);

		ctrl.selectedBureau = businessBureau.Id;

		ctrl.next();

		System.assertEquals(wrapper,[Select EDM_Multiple_Nomination_Ids__c From EDM_Multiple_Nomination_Wrapper__c Limit 1].EDM_Multiple_Nomination_Ids__c);

	}

	public static testMethod void multipleNominationOnlyOneAccountNextTest(){
		
		Speaker_Bureau_gne__c businessBureauLY = new Speaker_Bureau_gne__c(Name = 'TestBureau_LastYear',Speaker_Bureau_Type_gne__c = 'Business');
		insert businessBureauLY;

		List<Account> accnts = new List<Account>();
		accnts.add(new Account(
			Name = 'Test Account',
			AGS_EX_Exclusion_Status_base_gne__c = 'Not checked'
		));
		insert accnts;
		List<Speaker_Bureau_Membership_gne__c> sbm = new List<Speaker_Bureau_Membership_gne__c>();
		for(Account a : accnts){
			sbm.add(new Speaker_Bureau_Membership_gne__c(
				Bureau_Member_gne__c = a.Id,
				Speaker_Bureau_ID_gne__c = businessBureauLY.Id,
				Speaker_Status_gne__c = 'Nominated'
			));
		}
		insert sbm;

		String wrapper = '';
		Integer i = sbm.size();
		for(Speaker_Bureau_Membership_gne__c s : sbm){
			wrapper += s.Id;
			i--;
			if(i>0) wrapper += ';';
		}
		System.debug('### '+wrapper);
		EDM_Multiple_Nomination_Wrapper__c wrapperOb = new EDM_Multiple_Nomination_Wrapper__c(
			EDM_Multiple_Nomination_Ids__c = wrapper
		);
		insert wrapperOb;
		Speaker_Bureau_gne__c businessBureau = new Speaker_Bureau_gne__c(
			Name = 'TestBureau',
			Speaker_Bureau_Type_gne__c = 'Business',
			Last_Year_Speaker_Bureau_gne__c = businessBureauLY.Id
		);
		insert businessBureau;

		ApexPages.currentPage().getParameters().put('retBureau',businessBureau.Id);
		ApexPages.currentPage().getParameters().put('multiple','true');
		ApexPages.currentPage().getParameters().put('wrapperId',wrapperOb.Id);

		GNE_SFA2_Bureau_Account_Nomination_Ctrl ctrl = new GNE_SFA2_Bureau_Account_Nomination_Ctrl();

		ctrl.selectedBureau = businessBureau.Id;

		ctrl.next();

		List<ApexPages.Message> msgs = ApexPages.getMessages();
		System.assertEquals('All but one of the selected accounts are already members of target bureau. To nominate an individual speaker please start from the speaker’s account detail page.',msgs[0].getDetail());
	}

	public static testMethod void multipleNominationZeroAccountNextTest(){
		
		Speaker_Bureau_gne__c businessBureauLY = new Speaker_Bureau_gne__c(Name = 'TestBureau_LastYear',Speaker_Bureau_Type_gne__c = 'Business');
		insert businessBureauLY;
		Speaker_Bureau_gne__c businessBureau = new Speaker_Bureau_gne__c(
			Name = 'TestBureau',
			Speaker_Bureau_Type_gne__c = 'Business',
			Last_Year_Speaker_Bureau_gne__c = businessBureauLY.Id
		);
		insert businessBureau;

		List<Account> accnts = new List<Account>();
		accnts.add(new Account(
			Name = 'Test Account',
			AGS_EX_Exclusion_Status_base_gne__c = 'Check pending'
		));
		insert accnts;
		List<Speaker_Bureau_Membership_gne__c> sbm = new List<Speaker_Bureau_Membership_gne__c>();
		for(Account a : accnts){
			sbm.add(new Speaker_Bureau_Membership_gne__c(
				Bureau_Member_gne__c = a.Id,
				Speaker_Bureau_ID_gne__c = businessBureauLY.Id,
				Speaker_Status_gne__c = 'Nominated'
			));
			sbm.add(new Speaker_Bureau_Membership_gne__c(
				Bureau_Member_gne__c = a.Id,
				Speaker_Bureau_ID_gne__c = businessBureau.Id,
				Speaker_Status_gne__c = 'Nominated'
			));
		}
		insert sbm;

		String wrapper = '';
		Integer i = sbm.size();
		for(Speaker_Bureau_Membership_gne__c s : sbm){
			wrapper += s.Id;
			i--;
			if(i>0) wrapper += ';';
		}
		System.debug('### '+wrapper);
		EDM_Multiple_Nomination_Wrapper__c wrapperOb = new EDM_Multiple_Nomination_Wrapper__c(
			EDM_Multiple_Nomination_Ids__c = wrapper
		);
		insert wrapperOb;
		

		ApexPages.currentPage().getParameters().put('retBureau',businessBureau.Id);
		ApexPages.currentPage().getParameters().put('multiple','true');
		ApexPages.currentPage().getParameters().put('wrapperId',wrapperOb.Id);

		GNE_SFA2_Bureau_Account_Nomination_Ctrl ctrl = new GNE_SFA2_Bureau_Account_Nomination_Ctrl();

		ctrl.selectedBureau = businessBureau.Id;

		ctrl.next();

		List<ApexPages.Message> msgs = ApexPages.getMessages();
		System.assertEquals('All of the selected accounts are already members of target bureau.',msgs[0].getDetail());
	}

	public static testMethod void multipleNominationCancelTest(){
		
		Speaker_Bureau_gne__c businessBureauLY = new Speaker_Bureau_gne__c(Name = 'TestBureau_LastYear',Speaker_Bureau_Type_gne__c = 'Business');
		insert businessBureauLY;
		Speaker_Bureau_gne__c businessBureau = new Speaker_Bureau_gne__c(
			Name = 'TestBureau',
			Speaker_Bureau_Type_gne__c = 'Business',
			Last_Year_Speaker_Bureau_gne__c = businessBureauLY.Id
		);
		insert businessBureau;

		List<Account> accnts = new List<Account>();
		accnts.add(new Account(
			Name = 'Test Account',
			AGS_EX_Exclusion_Status_base_gne__c = 'Check pending'
		));
		insert accnts;
		List<Speaker_Bureau_Membership_gne__c> sbm = new List<Speaker_Bureau_Membership_gne__c>();
		for(Account a : accnts){
			sbm.add(new Speaker_Bureau_Membership_gne__c(
				Bureau_Member_gne__c = a.Id,
				Speaker_Bureau_ID_gne__c = businessBureauLY.Id,
				Speaker_Status_gne__c = 'Nominated'
			));
			sbm.add(new Speaker_Bureau_Membership_gne__c(
				Bureau_Member_gne__c = a.Id,
				Speaker_Bureau_ID_gne__c = businessBureau.Id,
				Speaker_Status_gne__c = 'Nominated'
			));
		}
		insert sbm;		

		ApexPages.currentPage().getParameters().put('retBureau',businessBureau.Id);
		ApexPages.currentPage().getParameters().put('multiple','true');
		ApexPages.currentPage().getParameters().put('parentRecordType','');

		GNE_SFA2_Bureau_Account_Nomination_Ctrl ctrl = new GNE_SFA2_Bureau_Account_Nomination_Ctrl();

		ctrl.selectedBureau = businessBureau.Id;

		PageReference pr = ctrl.cancel();

		System.assertEquals('/apex/GNE_SFA2_SBMembership?br_id='+businessBureau.Id+'&parentObjectName=Speaker_Bureau_gne__c&parentRecordType=',pr.getUrl());
	}

	public static testMethod void singleNominationCancelTest(){
		
		Account acc = new Account(
			Name = 'Test Account',
			AGS_EX_Exclusion_Status_base_gne__c = '',
			EDM_Clinical_Classification_gne__c = '',
			EDM_Business_Classification_gne__c = ''
		);
		insert acc;

		ApexPages.currentPage().getParameters().put('Id',acc.Id);
		GNE_SFA2_Bureau_Account_Nomination_Ctrl ctrl = new GNE_SFA2_Bureau_Account_Nomination_Ctrl();

		PageReference pr = ctrl.cancel();

		System.assertEquals('/'+acc.Id,pr.getUrl());
	}

	public static testMethod void getYearOptionsTest(){

		Account acc = new Account(
			Name = 'Test Account',
			AGS_EX_Exclusion_Status_base_gne__c = '',
			EDM_Clinical_Classification_gne__c = '',
			EDM_Business_Classification_gne__c = ''
		);
		insert acc;

		ApexPages.currentPage().getParameters().put('Id',acc.Id);

		GNE_SFA2_Bureau_Account_Nomination_Ctrl ctrl = new GNE_SFA2_Bureau_Account_Nomination_Ctrl();
		List<SelectOption> years = ctrl.getYear_Options();
		System.assertEquals(String.valueOf(Date.today().year()),years[1].getValue());
		System.assertEquals(String.valueOf(Date.today().year()+1),years[2].getValue());
	}

	public static testMethod void getYearBureausSingleNominationTest(){

		Account acc = new Account(
			Name = 'Test Account',
			AGS_EX_Exclusion_Status_base_gne__c = '',
			EDM_Clinical_Classification_gne__c = '',
			EDM_Business_Classification_gne__c = ''
		);
		insert acc;

		List<Speaker_Bureau_gne__c> allbureaus = new List<Speaker_Bureau_gne__c>();
		allbureaus.add(new Speaker_Bureau_gne__c(Name = 'TestBureau_LastYear0',Speaker_Bureau_Type_gne__c = 'Business',Speaker_Bureau_Year_gne__c = String.valueOf(Date.today().year())));
		allbureaus.add(new Speaker_Bureau_gne__c(Name = 'TestBureau_LastYear1',Speaker_Bureau_Type_gne__c = 'Business',Speaker_Bureau_Year_gne__c = String.valueOf(Date.today().year())));
		allbureaus.add(new Speaker_Bureau_gne__c(Name = 'TestBureau_LastYear2',Speaker_Bureau_Type_gne__c = 'Business',Speaker_Bureau_Year_gne__c = String.valueOf(Date.today().year())));
		allbureaus.add(new Speaker_Bureau_gne__c(Name = 'TestBureau_LastYear3',Speaker_Bureau_Type_gne__c = 'Business',Speaker_Bureau_Year_gne__c = String.valueOf(Date.today().year())));
		allbureaus.add(new Speaker_Bureau_gne__c(Name = 'TestBureau_LastYear4',Speaker_Bureau_Type_gne__c = 'Business',Speaker_Bureau_Year_gne__c = String.valueOf(Date.today().year())));
		allbureaus.add(new Speaker_Bureau_gne__c(Name = 'TestBureau_LastYear5',Speaker_Bureau_Type_gne__c = 'Business',Speaker_Bureau_Year_gne__c = String.valueOf(Date.today().year())));
		allbureaus.add(new Speaker_Bureau_gne__c(Name = 'TestBureau_LastYear6',Speaker_Bureau_Type_gne__c = 'Business',Speaker_Bureau_Year_gne__c = String.valueOf(Date.today().year()+1)));
		allbureaus.add(new Speaker_Bureau_gne__c(Name = 'TestBureau_LastYear7',Speaker_Bureau_Type_gne__c = 'Business',Speaker_Bureau_Year_gne__c = String.valueOf(Date.today().year()+1)));
		allbureaus.add(new Speaker_Bureau_gne__c(Name = 'TestBureau_LastYear8',Speaker_Bureau_Type_gne__c = 'Business',Speaker_Bureau_Year_gne__c = String.valueOf(Date.today().year()+1)));
		allbureaus.add(new Speaker_Bureau_gne__c(Name = 'TestBureau_LastYear9',Speaker_Bureau_Type_gne__c = 'Business',Speaker_Bureau_Year_gne__c = String.valueOf(Date.today().year()+1)));
		insert allbureaus;

		ApexPages.currentPage().getParameters().put('Id',acc.Id);

		Speaker_Bureau_Membership_gne__c sbm = new Speaker_Bureau_Membership_gne__c(
				Bureau_Member_gne__c = acc.Id,
				Speaker_Bureau_ID_gne__c = allbureaus[0].Id,
				Speaker_Status_gne__c = 'Nominated'
			);
		insert sbm;
		sbm = new Speaker_Bureau_Membership_gne__c(
				Bureau_Member_gne__c = acc.Id,
				Speaker_Bureau_ID_gne__c = allbureaus[8].Id,
				Speaker_Status_gne__c = 'Nominated'
			);
		insert sbm;

		GNE_SFA2_Bureau_Account_Nomination_Ctrl ctrl = new GNE_SFA2_Bureau_Account_Nomination_Ctrl();

		ctrl.selectedYear = String.valueOf(Date.today().year());
		List<SelectOption> bureaus = ctrl.getSpeaker_Bureau_Options();
		System.assertEquals(6,bureaus.size());

		ctrl.selectedYear = String.valueOf(Date.today().year()+1);
		bureaus = ctrl.getSpeaker_Bureau_Options();
		System.assertEquals(4,bureaus.size());
	}

	public static testMethod void getYearBureausMultipleNominationTest(){

		Speaker_Bureau_gne__c businessBureau = new Speaker_Bureau_gne__c(
			Name = 'TestBureau',
			Speaker_Bureau_Type_gne__c = 'Business',
			Speaker_Bureau_Year_gne__c = String.valueOf(Date.today().year())
		);
		insert businessBureau;

		List<Speaker_Bureau_gne__c> allbureaus = new List<Speaker_Bureau_gne__c>();
		allbureaus.add(new Speaker_Bureau_gne__c(Name = 'TestBureau_LastYear0',Speaker_Bureau_Type_gne__c = 'Business',Speaker_Bureau_Year_gne__c = String.valueOf(Date.today().year())));
		allbureaus.add(new Speaker_Bureau_gne__c(Name = 'TestBureau_LastYear1',Speaker_Bureau_Type_gne__c = 'Business',Speaker_Bureau_Year_gne__c = String.valueOf(Date.today().year())));
		allbureaus.add(new Speaker_Bureau_gne__c(Name = 'TestBureau_LastYear2',Speaker_Bureau_Type_gne__c = 'Business',Speaker_Bureau_Year_gne__c = String.valueOf(Date.today().year())));
		allbureaus.add(new Speaker_Bureau_gne__c(Name = 'TestBureau_LastYear3',Speaker_Bureau_Type_gne__c = 'Business',Speaker_Bureau_Year_gne__c = String.valueOf(Date.today().year())));
		allbureaus.add(new Speaker_Bureau_gne__c(Name = 'TestBureau_LastYear7',Speaker_Bureau_Type_gne__c = 'Business',Speaker_Bureau_Year_gne__c = String.valueOf(Date.today().year()+1)));
		allbureaus.add(new Speaker_Bureau_gne__c(Name = 'TestBureau_LastYear8',Speaker_Bureau_Type_gne__c = 'Business',Speaker_Bureau_Year_gne__c = String.valueOf(Date.today().year()+1)));
		allbureaus.add(new Speaker_Bureau_gne__c(Name = 'TestBureau_LastYear9',Speaker_Bureau_Type_gne__c = 'Business',Speaker_Bureau_Year_gne__c = String.valueOf(Date.today().year()+1)));
		insert allbureaus;

		List<Account> accnts = new List<Account>();
		accnts.add(new Account(
			Name = 'Test Account',
			AGS_EX_Exclusion_Status_base_gne__c = 'Not checked'
		));
		accnts.add(new Account(
			Name = 'Test Account',
			AGS_EX_Exclusion_Status_base_gne__c = 'Check pending'
		));
		insert accnts;
		List<Speaker_Bureau_Membership_gne__c> sbm = new List<Speaker_Bureau_Membership_gne__c>();
		for(Account a : accnts){
			sbm.add(new Speaker_Bureau_Membership_gne__c(
				Bureau_Member_gne__c = a.Id,
				Speaker_Bureau_ID_gne__c = allbureaus[2].Id,
				Speaker_Status_gne__c = 'Nominated'
			));
			sbm.add(new Speaker_Bureau_Membership_gne__c(
				Bureau_Member_gne__c = a.Id,
				Speaker_Bureau_ID_gne__c = allbureaus[5].Id,
				Speaker_Status_gne__c = 'Nominated'
			));
		}
		insert sbm;

		String wrapper = '';
		Integer i = sbm.size();
		for(Speaker_Bureau_Membership_gne__c s : sbm){
			wrapper += s.Id;
			i--;
			if(i>0) wrapper += ';';
		}
		System.debug('### '+wrapper);
		EDM_Multiple_Nomination_Wrapper__c wrapperOb = new EDM_Multiple_Nomination_Wrapper__c(
			EDM_Multiple_Nomination_Ids__c = wrapper
		);
		insert wrapperOb;
		
		ApexPages.currentPage().getParameters().put('retBureau',businessBureau.Id);
		ApexPages.currentPage().getParameters().put('multiple','true');
		ApexPages.currentPage().getParameters().put('wrapperId',wrapperOb.Id);

		GNE_SFA2_Bureau_Account_Nomination_Ctrl ctrl = new GNE_SFA2_Bureau_Account_Nomination_Ctrl();

		ctrl.selectedYear = String.valueOf(Date.today().year());
		List<SelectOption> bureaus = ctrl.getSpeaker_Bureau_Options();
		System.assertEquals(5,bureaus.size());

		ctrl.selectedYear = String.valueOf(Date.today().year()+1);
		bureaus = ctrl.getSpeaker_Bureau_Options();
		System.assertEquals(4,bureaus.size());
	}
}