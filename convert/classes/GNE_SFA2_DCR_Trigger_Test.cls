/************************************************************
*  @author: unknown
*  Date: unknown
*  Description: This is a test class for GNE_SFA2_Data_Change_Request_Trigger trigger.
*  
*  Modification History
*  Date        	Name        		Description
*  2014-02-07	Piotr Przesmycki	Fixed and improved unit test, added header for this class
*  2014-02-20   Piotr Przesmycki    Using GNE_SFA2_Trigger_Test_Util to prepare data
*************************************************************/

@isTest 
public with sharing class GNE_SFA2_DCR_Trigger_Test {
	
	public static testMethod void testDCRValidations() {
		initCustomSettings();
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		Change_Request_gne__c new_chg = GNE_SFA2_Triggers_Test_Util.prepareChange_Request_gne();
		if(sfa2User!=null){
			System.runAs(sfa2User){
				try{
					Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('Test');
					insert acc;
					new_chg.Account_gne__c=acc.Id;
					insert new_chg;
				} catch(Exception ex){ 
					system.assert(false,ex);
				}
			}
			new_chg.Reason_dcr_gne__c='Organization is not my account or not in my territory';
			try{
				update new_chg;
			} catch(DMLException ex){
				system.assertEquals(ex.getDmlType(0),StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION);
				system.assert(ex.getMessage().contains(System.Label.NotMyAccount_InvalidRequest));
			}
			new_chg.Reason_dcr_gne__c='HCP is not my account or not in my territory';
			try{
				update new_chg;
			} catch(Exception ex){
				system.assertEquals(ex.getDmlType(0),StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION);
				system.assert(ex.getMessage().contains(System.Label.NotMyAccount_InvalidRequest));
			}
			new_chg.Reason_dcr_gne__c=null;
			new_chg.Remove_Inactive_Address_gne__c='This address is valid but not relevant to my job';
			try{
				update new_chg;
			} catch(Exception ex){
				system.assertEquals(ex.getDmlType(0),StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION);
				system.assert(ex.getMessage().contains(System.Label.NotRelevantAddressDCR));
			}
			new_chg.Remove_Inactive_Address_gne__c=null;
			new_chg.Postal_Code_can_gne__c='ABC';
			try{
				update new_chg;
			} catch(Exception ex){
				system.assertEquals(ex.getDmlType(0),StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION);
				system.assert(ex.getMessage().contains(System.Label.GNE_SFA_Canada_Postal_Code_Validation));
			}
		}
	}

	public static testmethod void testCanadaValidations(){
		initCustomSettings();
		User canada_user = getCanadaUser();
		Change_Request_gne__c new_chg = GNE_SFA2_Triggers_Test_Util.prepareChange_Request_gne();
		boolean isCanada=false;
        if(canada_user!=null){
        	isCanada=true;
        	System.runAs(canada_user){
        		Account hco = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('testHCO');
                hco.Account_type_gne__c='testTypeHCO';
        		insert hco;

        		Account hcp = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('HCP');
                hcp.FirstName='test';
                hcp.Account_type_gne__c='testTypeHCP';
                hcp.Middle_vod__c='mid';
        		insert hcp;

				Address_vod__c addr = GNE_SFA2_Triggers_Test_Util.prepareAddress_vod(hco.Id, null, true, 'testAddr');
                addr.City_vod__c='Atlanta';
                addr.Province_can_gne__c='testProv';
                addr.Postal_Code_can_gne__c='A0A 1B1';
        		insert addr;
        		List<String> recordTypesDCR = new List<String>();
        		recordTypesDCR.add('HCO_Change_Organization_Info');
        		recordTypesDCR.add('HCP_Change_HCP_Info');
        		recordTypesDCR.add('HCP_Existing_Address_Typo_Missing_Info');
        		recordTypesDCR.add('HCO_Change_Address');
        		List<Change_Request_gne__c> dcrList = new List<Change_Request_gne__c >();
        		for(String s: recordTypesDCR){
        			try{
	        			dcrList.add(getDCRInstance(s, isCanada, hco, addr));
	        			dcrList.add(getDCRInstance(s, isCanada, hcp, addr));
        			} catch(Exception ex){
        				system.assert(false,ex.getMessage());
        			}
        		}
       			Database.SaveResult[] srList = Database.insert(dcrList,false);
       			Integer success = 0;
       			Integer failed = 0;
       			for (Database.SaveResult sr : srList) {
       				if(sr.isSuccess()){
       					success++;
       					system.assert(false,'each should fail');
       				} else {
       					failed++;
       					system.assert(sr.getErrors().size()>0);
       				}
       			}
       			
        		
        		try{
        			Change_Request_gne__c cr = getDCRInstance('HCP_Existing_Address_Typo_Missing_Info', true, hco, addr);
        			cr.Postal_Code_can_gne__c = 'a0a 0Aa';
        			insert cr;
        			//system.assert(false,'This line should not be reached.');
        		}catch(DMLException ex){
        			system.assertEquals(ex.getDmlType(0),StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION);
        			system.assert(ex.getMessage().contains(System.Label.GNE_SFA_Canada_Postal_Code_Validation));
        		}
        	}
        } else{
	        System.assert(false);
        }
	}

	public static testmethod void testCanadaValidationsSuccess(){
		initCustomSettings();
		User canada_user = getCanadaUser();
		Change_Request_gne__c new_chg = new Change_Request_gne__c();
		boolean isCanada=false;
        if(canada_user!=null){
        	isCanada=true;
        	System.runAs(canada_user){
        		Account hco = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('testHCO');
                hco.Account_type_gne__c='testTypeHCO';
                insert hco;
        		
                Account hcp = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('HCP');
                hcp.FirstName='test';
                hcp.Account_type_gne__c='testTypeHCP';
                hcp.Middle_vod__c='mid';
                insert hcp;

				Address_vod__c addr = GNE_SFA2_Triggers_Test_Util.prepareAddress_vod(hco.Id, null, true, 'testAddr');
                addr.City_vod__c='Atlanta';
                addr.Province_can_gne__c='testProv';
                addr.Postal_Code_can_gne__c='A0A 1B1';
                insert addr;

        		List<String> recordTypesDCR = new List<String>();
        		recordTypesDCR.add('HCO_Change_Organization_Info');
        		recordTypesDCR.add('HCP_Change_HCP_Info');
        		List<Change_Request_gne__c> dcrList = new List<Change_Request_gne__c >();
        		for(String s: recordTypesDCR){
        			try{
	        			dcrList.add(getDCRModification(s, isCanada, hco, addr));
	        			dcrList.add(getDCRModification(s, isCanada, hcp, addr));
        			} catch(Exception ex){
        				system.assert(false,ex.getMessage());
        			}
        		}
        		dcrList.add(getDCRModification('HCP_Existing_Address_Typo_Missing_Info', isCanada, hcp, addr));
        		dcrList.add(getDCRModification('HCO_Change_Address', isCanada, hco, addr));
       			Database.SaveResult[] srList = Database.insert(dcrList,false);
       			Integer success = 0;
       			Integer failed = 0;
       			for (Database.SaveResult sr : srList) {
       				if(sr.isSuccess()){
       					success++;
       				} else {
       					failed++;
       					system.debug(failed+':'+sr.getErrors());
       					system.assert(false,'none should fail');
       				}
       			}
       			system.assertEquals(success,6);
       			dcrList = new List<Change_Request_gne__c >();
       			dcrList.add(getDCRModification('HCP_Existing_Address_Typo_Missing_Info', isCanada, hco, addr));
        		dcrList.add(getDCRModification('HCO_Change_Address', isCanada, hcp, addr));
        		srList = Database.insert(dcrList,false);
       			success = 0;
       			failed = 0;
       			for (Database.SaveResult sr : srList) {
       				if(sr.isSuccess()){
       					success++;
       				} else {
       					failed++;
       					system.debug(failed+':'+sr.getErrors());
       					system.assert(false,'none should fail');
      				}
       			}
       			system.assertEquals(success,2);
        	}
        } else{
	        System.assert(false);
        }
	}

	public static testmethod void testSomeMoreValidations(){
		initCustomSettings();
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		boolean isCanada=false;
        if(sfa2User!=null){
        	System.runAs(sfa2User){
        		Account hco = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('testHCO');
                hco.Account_type_gne__c='testTypeHCO';
                insert hco;
                
                Account hcp = GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('HCP');
                hcp.FirstName='test';
                hcp.Account_type_gne__c='testTypeHCP';
                hcp.Middle_vod__c='mid';
                insert hcp;

                Address_vod__c addr = GNE_SFA2_Triggers_Test_Util.prepareAddress_vod(hco.Id, null, true, 'testAddr');
                addr.City_vod__c='Atlanta';
                addr.Province_can_gne__c='testProv';
                addr.Postal_Code_can_gne__c='A0A 1B1';
                insert addr;
                
                Address_vod__c addrHcp = GNE_SFA2_Triggers_Test_Util.prepareAddress_vod(hcp.Id, null, true, 'testAddr');
                addrHcp.City_vod__c='Atlanta';
                addrHcp.Province_can_gne__c='testProv';
                addrHcp.Postal_Code_can_gne__c='A0A 1B1';
                insert addrHcp;

            Test.startTest();
        		List<String> recordTypesDCR = new List<String>();
        		recordTypesDCR.add('HCP_Change_HCP_Info');
        		recordTypesDCR.add('HCP_Existing_Address_Typo_Missing_Info');
        		recordTypesDCR.add('HCO_Change_Address');
        		List<Change_Request_gne__c> dcrList = new List<Change_Request_gne__c >();
        		for(String s: recordTypesDCR){
        			try{
	        			dcrList.add(getDCRInstance(s, isCanada, hco, addr));
	        			dcrList.add(getDCRInstance(s, isCanada, hcp, addr));
        			} catch(Exception ex){
        				system.assert(false,ex.getMessage());
        			}
        		}
        		dcrList.add(getDCRInstance('HCO_Change_Organization_Info', isCanada, hco, addr));
       			Database.SaveResult[] srList = Database.insert(dcrList,false);
       			Integer success = 0;
       			Integer failed = 0;
       			for (Database.SaveResult sr : srList) {
       				if(sr.isSuccess()){
       					success++;
       					system.assert(false,'each should fail');
       				} else {
       					failed++;
       					system.assert(sr.getErrors().size()>0);
       				}
       			}
       			system.assertEquals(failed,7);
       			
        		
        		try{
        			Change_Request_gne__c cr = getDCRInstance('HCP_Existing_Address_Typo_Missing_Info', false, hcp, addr);
        			//cr.Postal_Code_can_gne__c = 'a0a 0Aa';
        			insert cr;
        			//system.assert(false,'This line should not be reached.');
        		}catch(DMLException ex){
        			system.assertEquals(ex.getDmlType(0),StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION);
        			system.assert(ex.getMessage().contains(System.Label.Change_RequestChange_Attribute));
        		}
            Test.stopTest();
        	}
        } else{
	        System.assert(false);
        }
	}

	public static testMethod void testData_Change_Request_Controller(){
		initCustomSettings();
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2User!=null){
			System.runAs(sfa2User){
				ID queueId=ChangeRequestControllerHelper.getAnalystsQueueNameQueueID();
				List<Change_Request_gne__c > DCRMatchingQueues= [select Id,Name,Status_gne__c,Vendor_Type_gne__c,Account_gne__c,Assigned_Analyst_gne__c,Current_Sharing_Owner_gne__c from Change_Request_gne__c where ownerId =:queueId LIMIT 100];
				updateChangeRequests('Submitted',DCRMatchingQueues);
				updateChangeRequests('In-Progress',DCRMatchingQueues);
				updateChangeRequests('Ready for Data Vendor',DCRMatchingQueues);
				updateChangeRequests('Issue Identified by Vendor',DCRMatchingQueues);
				updateChangeRequests('Ready to Load',DCRMatchingQueues);
				updateChangeRequests('Ready to Close',DCRMatchingQueues);
				updateChangeRequests('Disputed',DCRMatchingQueues);
				updateChangeRequests('Closed',DCRMatchingQueues);
				updateChangeRequests('Closed By System',DCRMatchingQueues);
			}
		}
	}		

	public static void updateChangeRequests(String status,List<Change_Request_gne__c> CRList){
		List<Change_Request_gne__c> updateList = new List<Change_Request_gne__c>();
		for(Change_Request_gne__c cr : CRList ){
			cr.Status_gne__c=status;
			cr.Vendor_Type_gne__c=null;
			if(status=='In-Progress'){
				cr.Assigned_Analyst_gne__c=null;
			}
			cr.Date_Ready_To_Close_Last_Set_gne__c=null;
			cr.New_Vendor_Note_gne__c='testing';
			updateList.add(cr);
		}
		try{
			Database.update(updateList,false);
		} catch(Exception e){
			System.debug('***' + e.getMessage());
		}
	}
	
	public static Id getRecordtypeId(String recName){
		RecordType rec = [select id,Name from RecordType where sobjecttype ='change_request_gne__c' and developerName=:recName];
		if(rec!=null){
			return rec.id;
		} else{
			return null;
		}
	}
	
	public static User  getCanadaUser(){
        insert new GNE_SFA2_Canadian_Users__c(Name = 'RCanada-SFA-MSL');
		List<Profile> sfa2Profiles = [ SELECT Id FROM Profile WHERE Name IN :GNE_SFA2_Canadian_Users__c.getAll().keySet()];
        if(sfa2Profiles != null && sfa2Profiles.size() > 0) {
            List<User> sfa2Users = [ SELECT Id FROM USER WHERE ProfileId in :sfa2Profiles AND isActive = true ];
            if(sfa2Users != null && sfa2Users.size() > 0) {
                return sfa2Users[0];
            }
        }
        return null;
	}		
	
	public static Change_Request_gne__c getDCRInstance(String rectypeName,boolean isCanada, Account account, Address_vod__c address){
		Change_Request_gne__c new_chg = new Change_Request_gne__c();
		if(rectypeName.equals('HCO_Change_Organization_Info')){
			new_chg.recordTypeId=getRecordtypeId('HCO_Change_Organization_Info');
        	new_chg.New_Organization_Name_gne__c=account.name;
        	new_chg.account_type_dcr_Gne__c=account.account_type_gne__c;
        	new_chg.Account_gne__c=account.Id;
        	return new_chg;
		} else if(rectypeName.equals('HCP_Change_HCP_Info')){
			new_chg.recordTypeId=getRecordtypeId('HCP_Change_HCP_Info');
        	new_chg.first_name_dcr_gne__c=account.FirstName;
        	new_chg.last_name_dcr_gne__c=account.LastName;
        	new_chg.new_value_2_gne__c=account.middle_vod__c;
        	new_chg.account_type_dcr_Gne__c=account.account_type_gne__c;
        	new_chg.Verify_Gender_can_gne__c =false;
        	new_chg.Account_gne__c=account.Id;
        	return new_chg;
		} else if(rectypeName.equals('HCP_Existing_Address_Typo_Missing_Info')){
			new_chg.recordTypeId=getRecordtypeId('HCP_Existing_Address_Typo_Missing_Info');
        	new_chg.address_line_1_gne__c=address.name;
        	new_chg.city_gne__c=address.city_vod__c;
        	new_chg.Province_can_gne__c=address.Province_can_gne__c;
        	new_chg.Postal_Code_can_gne__c=address.Postal_Code_can_gne__c;
        	new_chg.Current_Address_gne__c=address.Id;
        	return new_chg;
		} else if(rectypeName.equals('HCO_Change_Address')){
			new_chg.recordTypeId=getRecordtypeId('HCO_Change_Address');
        	new_chg.address_line_1_gne__c=address.name;
        	new_chg.city_gne__c=address.city_vod__c;
        	new_chg.Province_can_gne__c=address.Province_can_gne__c;
        	new_chg.Postal_Code_can_gne__c=address.Postal_Code_can_gne__c;
        	new_chg.Current_Address_gne__c=address.Id;
        	return new_chg;
		}
		return new_chg;
	}

	public static Change_Request_gne__c getDCRModification(String rectypeName,boolean isCanada, Account account, Address_vod__c address){
		
		Change_Request_gne__c new_chg = new Change_Request_gne__c();

		if(rectypeName.equals('HCO_Change_Organization_Info')){
			new_chg.recordTypeId=getRecordtypeId('HCO_Change_Organization_Info');
        	new_chg.New_Organization_Name_gne__c='new'+account.name;
        	new_chg.account_type_dcr_Gne__c='new'+account.account_type_gne__c;
        	new_chg.Account_gne__c=account.Id;
        	new_chg.Notes_gne__c='';
        	return new_chg;
		} else if(rectypeName.equals('HCP_Change_HCP_Info')){
			new_chg.recordTypeId=getRecordtypeId('HCP_Change_HCP_Info');
        	new_chg.first_name_dcr_gne__c='new'+account.FirstName;
        	new_chg.last_name_dcr_gne__c='new'+account.LastName;
        	new_chg.new_value_2_gne__c='new'+account.middle_vod__c;
        	new_chg.account_type_dcr_Gne__c='new'+account.account_type_gne__c;
        	new_chg.Verify_Gender_can_gne__c =true;
        	new_chg.Account_gne__c=account.Id;
        	new_chg.Notes_gne__c='';
        	return new_chg;
		} else if(rectypeName.equals('HCP_Existing_Address_Typo_Missing_Info')){
			new_chg.recordTypeId=getRecordtypeId('HCP_Existing_Address_Typo_Missing_Info');
        	new_chg.address_line_1_gne__c='new'+address.name;
        	new_chg.city_gne__c='new'+address.city_vod__c;
        	new_chg.Province_can_gne__c='new'+address.Province_can_gne__c;
        	new_chg.Postal_Code_can_gne__c='X0X 1Y1';
        	new_chg.Current_Address_gne__c=address.Id;
        	new_chg.Notes_gne__c='';
        	return new_chg;
		} else if(rectypeName.equals('HCO_Change_Address')){
			new_chg.recordTypeId=getRecordtypeId('HCO_Change_Address');
        	new_chg.address_line_1_gne__c='new'+address.name;
        	new_chg.city_gne__c='new'+address.city_vod__c;
        	new_chg.Province_can_gne__c='new'+address.Province_can_gne__c;
        	new_chg.Postal_Code_can_gne__c='X0X 1Y1';
        	new_chg.Current_Address_gne__c=address.Id;
        	new_chg.Notes_gne__c='';
        	return new_chg;
		}
		return new_chg;
	}
	
	public static testMethod void testRemoveHCPDuplicateCanada(){
		initCustomSettings();
		Change_Request_gne__c new_chg = new Change_Request_gne__c();
		new_chg.RecordTypeId=getRecordtypeId('HCP_Remove_Duplicate');
		User canada_user = getCanadaUser();
        if(canada_user!=null){
        	System.runAs(canada_user){
				List<Account> hcps = new List<Account>();
				hcps.add(GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('name'));
				hcps.add(GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('name'));
				hcps.add(GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('name'));
				hcps.add(GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('name'));
				hcps.add(GNE_SFA2_Triggers_Test_Util.prepareAccountHCP('name'));
				insert hcps;
				new_chg.Duplicate_Account_gne__c=hcps[0].Id;
				new_chg.Duplicate_Account_2_gne__c=hcps[1].Id;
				new_chg.Duplicate_Account_3_gne__c=hcps[2].Id;
				new_chg.Duplicate_Account_4_gne__c=hcps[3].Id;
				new_chg.Duplicate_Account_5_gne__c=hcps[4].Id;
				try{
					insert new_chg;
					new_chg=[SELECT Duplicate_Account_gne__c, Duplicate_Account_2_gne__c, Duplicate_Account_3_gne__c, 
									Duplicate_Account_4_gne__c, Duplicate_Account_5_gne__c, Notes_gne__c
							 FROM Change_Request_gne__c
							 WHERE Id = :new_chg.Id
							 LIMIT 1];
					system.assert(new_chg.Notes_gne__c.contains(new_chg.Duplicate_Account_2_gne__c));
					system.assert(new_chg.Notes_gne__c.contains(new_chg.Duplicate_Account_3_gne__c));
					system.assert(new_chg.Notes_gne__c.contains(new_chg.Duplicate_Account_4_gne__c));
					system.assert(new_chg.Notes_gne__c.contains(new_chg.Duplicate_Account_5_gne__c));
				} catch(Exception ex){
			        System.assert(false, ex.getMessage() );
				}
			}
		}
	}

	public static testMethod void testRemoveHCODuplicateCanada(){
		initCustomSettings();
		Change_Request_gne__c new_chg = new Change_Request_gne__c();
		new_chg.RecordTypeId=getRecordtypeId('HCO_Remove_Duplicate_Organization');
		User canada_user = getCanadaUser();
        if(canada_user!=null){
        	System.runAs(canada_user){
				List<Account> hcos = new List<Account>();
				hcos.add(GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('test'));
				hcos.add(GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('test'));
				hcos.add(GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('test'));
				hcos.add(GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('test'));
				hcos.add(GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('test'));
				insert hcos;

				new_chg.Duplicate_Account_gne__c=hcos[0].Id;
				new_chg.Duplicate_Account_2_gne__c=hcos[1].Id;
				new_chg.Duplicate_Account_3_gne__c=hcos[2].Id;
				new_chg.Duplicate_Account_4_gne__c=hcos[3].Id;
				new_chg.Duplicate_Account_5_gne__c=hcos[4].Id;
				try{
					insert new_chg;
					new_chg=[SELECT Duplicate_Account_gne__c, Duplicate_Account_2_gne__c, Duplicate_Account_3_gne__c, 
									Duplicate_Account_4_gne__c, Duplicate_Account_5_gne__c, Notes_gne__c
							 FROM Change_Request_gne__c
							 WHERE Id = :new_chg.Id
							 LIMIT 1];
					system.assert(new_chg.Notes_gne__c.contains(new_chg.Duplicate_Account_2_gne__c));
					system.assert(new_chg.Notes_gne__c.contains(new_chg.Duplicate_Account_3_gne__c));
					system.assert(new_chg.Notes_gne__c.contains(new_chg.Duplicate_Account_4_gne__c));
					system.assert(new_chg.Notes_gne__c.contains(new_chg.Duplicate_Account_5_gne__c));
				} catch(Exception ex){
			        System.assert(false, ex.getMessage() );
				}
			}
		}
	}

	public static testMethod void testFailingRemoveHCODuplicateCanada(){
		initCustomSettings();
		Change_Request_gne__c new_chg = new Change_Request_gne__c();
		new_chg.RecordTypeId=getRecordtypeId('HCO_Remove_Duplicate_Organization');
		User canada_user = getCanadaUser();
        if(canada_user!=null){
        	System.runAs(canada_user){
				List<Account> hcos = new List<Account>();
				hcos.add(GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('test'));
				hcos.add(GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('test'));
				hcos.add(GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('test'));
                hcos.add(GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('test'));
				hcos.add(GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('test'));
				insert hcos;
				new_chg.Duplicate_Account_gne__c=hcos[0].Id;
				new_chg.Duplicate_Account_2_gne__c=hcos[0].Id;
				new_chg.Duplicate_Account_3_gne__c=hcos[0].Id;
				new_chg.Duplicate_Account_4_gne__c=hcos[0].Id;
				new_chg.Duplicate_Account_5_gne__c=hcos[0].Id;
				try{
					insert new_chg;
					System.assert(false, 'this insert should fail due to validation rules' );
				} catch(DMLException ex){
			        system.assertEquals(ex.getDmlType(0),StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION);
				}
			}
		}
	}

    public static testMethod void testSuccessfulDeleteJustFroCoverage(){
        /*there is no logic in afterDelete - this method is just for coverage*/
        initCustomSettings();
        Change_Request_gne__c cr = GNE_SFA2_Triggers_Test_Util.prepareChange_Request_gne();
        insert cr;
        delete cr;
    }
    
    private static void initCustomSettings(){
		insert new GNE_SFA2_DCR_Config_Items_gne__c(Name='AddressDcrFields', Key_gne__c='AddressDcrFields', Value_gne__c='Name,City_vod__c,State_vod__c,Zip_vod__c', Configuration_Type_gne__c='Main');
		//insert new GNE_SFA2_DCR_Config_Items_gne__c(Name='AddressDcrFields', Key_gne__c='HCO_Change_Address::Address_vod__c::Current_Address_gne__c', Value_gne__c='Account_vod__r.Name::Address_Line_4_gne__c::Address_Line_4_gne__c');
	}
}