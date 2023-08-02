@isTest
private class GNE_SFA2_Membership_Contracts_Trigg_Test{

	public static testMethod void checkNewContractsTest(){
		Account acc = new Account(Name='TestAccount');
		insert acc;
		Speaker_Bureau_gne__c businessBureau = new Speaker_Bureau_gne__c(Name = 'TestBureau',Speaker_Bureau_Type_gne__c = 'Business');
		insert businessBureau;

		Speaker_Bureau_Membership_gne__c sbm = new Speaker_Bureau_Membership_gne__c(
			Bureau_Member_gne__c = acc.Id,
			Speaker_Bureau_Id_gne__c = businessBureau.Id,
			Speaker_Status_gne__c = 'Nominated',
			Is_Contracted_Speaker_gne__c = false
		);
		insert sbm;
		Product_vod__c prod = new Product_vod__c();
		insert prod;
		Speaker_Bureau_Product_gne__c spkBrProd = new Speaker_Bureau_Product_gne__c(
			Product_vod_gne__c = prod.Id,
			Speaker_Bureau_gne__c = businessBureau.Id
		);
		insert spkBrProd;
		Product_Metrics_vod__c prodMet = new Product_Metrics_vod__c(
			Account_vod__c = acc.Id,
			Products_vod__c = prod.Id
		);
		insert prodMet;
		Speaker_Contract_gne__c spkCont = new Speaker_Contract_gne__c(
			Contracted_Party_ID__c = acc.Id,
			End_Date_gne__c = Date.today()+10
		);
		insert spkCont;
		Membership_Contracts_gne__c memCon = new Membership_Contracts_gne__c(
			Speaker_Bureau_Membership_gne__c = sbm.Id,
			Speaker_Contract_gne__c =  spkCont.Id
		);
		insert memCon;

		sbm = [Select Is_Contracted_Speaker_gne__c From Speaker_Bureau_Membership_gne__c];
		System.assertEquals(true,sbm.Is_Contracted_Speaker_gne__c);
	}

	public static testMethod void uncheckContractsTest(){
		Account acc = new Account(Name='TestAccount');
		insert acc;
		Speaker_Bureau_gne__c businessBureau = new Speaker_Bureau_gne__c(Name = 'TestBureau',Speaker_Bureau_Type_gne__c = 'Business');
		insert businessBureau;

		Speaker_Bureau_Membership_gne__c sbm = new Speaker_Bureau_Membership_gne__c(
			Bureau_Member_gne__c = acc.Id,
			Speaker_Bureau_Id_gne__c = businessBureau.Id,
			Speaker_Status_gne__c = 'Nominated',
			Is_Contracted_Speaker_gne__c = false
		);
		insert sbm;
		Product_vod__c prod = new Product_vod__c();
		insert prod;
		Speaker_Bureau_Product_gne__c spkBrProd = new Speaker_Bureau_Product_gne__c(
			Product_vod_gne__c = prod.Id,
			Speaker_Bureau_gne__c = businessBureau.Id
		);
		insert spkBrProd;
		Product_Metrics_vod__c prodMet = new Product_Metrics_vod__c(
			Account_vod__c = acc.Id,
			Products_vod__c = prod.Id
		);
		insert prodMet;
		Speaker_Contract_gne__c spkCont = new Speaker_Contract_gne__c(
			Contracted_Party_ID__c = acc.Id,
			End_Date_gne__c = Date.today()+10
		);
		insert spkCont;
		Membership_Contracts_gne__c memCon = new Membership_Contracts_gne__c(
			Speaker_Bureau_Membership_gne__c = sbm.Id,
			Speaker_Contract_gne__c =  spkCont.Id
		);
		insert memCon;

		sbm = [Select Is_Contracted_Speaker_gne__c From Speaker_Bureau_Membership_gne__c];
		System.assertEquals(true,sbm.Is_Contracted_Speaker_gne__c);

		delete memCon;

		sbm = [Select Is_Contracted_Speaker_gne__c From Speaker_Bureau_Membership_gne__c];
		System.assertEquals(false,sbm.Is_Contracted_Speaker_gne__c);
	}

	public static testMethod void membershipContractUpdateTest(){
		Account acc = new Account(Name='TestAccount');
		insert acc;
		Speaker_Bureau_gne__c businessBureau = new Speaker_Bureau_gne__c(Name = 'TestBureau',Speaker_Bureau_Type_gne__c = 'Business');
		insert businessBureau;

		Speaker_Bureau_Membership_gne__c sbm = new Speaker_Bureau_Membership_gne__c(
			Bureau_Member_gne__c = acc.Id,
			Speaker_Bureau_Id_gne__c = businessBureau.Id,
			Speaker_Status_gne__c = 'Nominated',
			Is_Contracted_Speaker_gne__c = false
		);
		insert sbm;
		Product_vod__c prod = new Product_vod__c();
		insert prod;
		Speaker_Bureau_Product_gne__c spkBrProd = new Speaker_Bureau_Product_gne__c(
			Product_vod_gne__c = prod.Id,
			Speaker_Bureau_gne__c = businessBureau.Id
		);
		insert spkBrProd;
		Product_Metrics_vod__c prodMet = new Product_Metrics_vod__c(
			Account_vod__c = acc.Id,
			Products_vod__c = prod.Id
		);
		insert prodMet;
		Speaker_Contract_gne__c spkCont = new Speaker_Contract_gne__c(
			Contracted_Party_ID__c = acc.Id,
			End_Date_gne__c = Date.today()+10
		);
		insert spkCont;
		Membership_Contracts_gne__c memCon = new Membership_Contracts_gne__c(
			Speaker_Bureau_Membership_gne__c = sbm.Id,
			Speaker_Contract_gne__c =  spkCont.Id
		);
		insert memCon;

		Speaker_Bureau_gne__c clinicalBureau = new Speaker_Bureau_gne__c(Name = 'TestBureau',Speaker_Bureau_Type_gne__c = 'Clinical');
		insert clinicalBureau;
		sbm = new Speaker_Bureau_Membership_gne__c(
			Bureau_Member_gne__c = acc.Id,
			Speaker_Bureau_Id_gne__c = clinicalBureau.Id,
			Speaker_Status_gne__c = 'Pending',
			Is_Contracted_Speaker_gne__c = false
		);
		insert sbm;
		spkBrProd = new Speaker_Bureau_Product_gne__c(
			Product_vod_gne__c = prod.Id,
			Speaker_Bureau_gne__c = clinicalBureau.Id
		);
		insert spkBrProd;
		memCon.Speaker_Bureau_Membership_gne__c = sbm.Id;
		update memCon;

		List<Speaker_Bureau_Membership_gne__c> sbms = new List<Speaker_Bureau_Membership_gne__c>([
			Select Is_Contracted_Speaker_gne__c From Speaker_Bureau_Membership_gne__c Order By CreatedDate
		]);
		System.assertEquals(2,sbms.size());		
		System.assertEquals(false,sbms[0].Is_Contracted_Speaker_gne__c);
		System.assertEquals(true,sbms[1].Is_Contracted_Speaker_gne__c);
	}
}