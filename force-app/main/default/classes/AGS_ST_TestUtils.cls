/** @date 2/25/2014
* @Author Konrad Malinowski
* @description Test Class with methods for creating test objects
*/
@isTest
public class AGS_ST_TestUtils {

	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Util Method for validating existence of sObject
	* @param sObject obj
	*/
	public static void checkIfIdExistsAfterInsert(sObject obj) {
		System.assertNotEquals( null, obj.Id );
	}

	/** @date 2/11/2014
	* @Author Konrad Malinowski
	* @description Util Method for validating existence of list of sObjects
	* @param List<sObject> objs
	*/
	public static void checkIfIdExistsAfterInsert(List<sObject> objs) {
		for(sObject obj : objs) {
			System.assertNotEquals( null, obj.Id );
		}
	}

	/** @date 2/25/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create Recipient Specialities
    * @return List<AGS_ST_RecipientSpeciality_gne__c>
	*/
	public static List<AGS_ST_RecipientSpeciality_gne__c> createRecipientSpecialities() {
		List<AGS_ST_RecipientSpeciality_gne__c>  recSpecs = new List<AGS_ST_RecipientSpeciality_gne__c>();
		List<String> specNames = new List<String>{ 'ALLERGY', 'EPIDEMIOLOGY', 'NEUROLOGY' };
		for(String name : specNames){
			recSpecs.add( new AGS_ST_RecipientSpeciality_gne__c( Speciality_Name_gne__c = name ) );
		}
		insert recSpecs;
		checkIfIdExistsAfterInsert(recSpecs);
		return recSpecs;
	}

	/** @date 2/26/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create Brands
    * @return List<AGS_Brand_gne__c>
	*/
	public static List<AGS_Brand_gne__c> createBrands() {
		List<AGS_Brand_gne__c> brands = new List<AGS_Brand_gne__c>();
		List<String> brandNames = new List<String>{ 'Avastin', 'Herceptin', 'Lucentis' };
		for(String name : brandNames){
			brands.add( new AGS_Brand_gne__c( Brand_Name__c = name ) );
		}
		insert brands;
		checkIfIdExistsAfterInsert(brands);
		return brands;
	}

	/** @date 5/14/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create Disputes
	* @param String status
    * @return List<AGS_ST_DisputeManagement_gne__c>
	*/
	public static List<AGS_ST_DisputeManagement_gne__c> createDisputes(String status) {
		AGS_CCO_Case_Recipient_gne__c recipient = createSpendRecipient();
		AGS_Spend_Expense_Transaction_gne__c agsTransaction = createSpendExpenseTrans(recipient);

		List<AGS_ST_DisputeManagement_gne__c> ds = new List<AGS_ST_DisputeManagement_gne__c>{
			new AGS_ST_DisputeManagement_gne__c(
				Internal_Status_gne__c 					= status,
				AGS_Spend_Expense_Transaction_gne__c 	= agsTransaction.Id,
				Dispute_Resolver_gne__c 				= createDisputeResolver().Id,
				Dispute_List_gne__c 					= createDisputeList( agsTransaction.Id ).Id,
				Drug_Name_gne__c 						= 'Avastin',
				Amount_gne__c 							= 1
			)
		};
		insert ds;
		checkIfIdExistsAfterInsert(ds);
		return ds;
	}

	/** @date 3/3/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create Dispute
	* @param AGS_Spend_Expense_Transaction_gne__c agsTransaction
	* @param String status
    * @return AGS_ST_DisputeManagement_gne__c
	*/
	public static AGS_ST_DisputeManagement_gne__c createDispute(AGS_Spend_Expense_Transaction_gne__c agsTransaction, String status) {
		AGS_ST_DisputeManagement_gne__c d = new AGS_ST_DisputeManagement_gne__c(
			Internal_Status_gne__c 					= status,
			AGS_Spend_Expense_Transaction_gne__c 	= agsTransaction.Id,
			Dispute_Resolver_gne__c 				= createDisputeResolver().Id,
			Dispute_List_gne__c 					= createDisputeList( agsTransaction.Id ).Id,
			Drug_Name_gne__c 						= 'Avastin',
			Amount_gne__c 							= 1
		);
		insert d;
		checkIfIdExistsAfterInsert(d);
		d = [
			SELECT Id,
				Amount_gne__c,
				Amount_frm_gne__c,
        		Attendees_gne__c,
        		Corrected_gne__c,
        		CreatedDate,
        		Drug_Name_gne__c,
        		Drug_Name_frm_gne__c,
        		Form_Of_Payment_gne__c,
        		Form_Of_Payment_frm_gne__c,
        		Internal_Status_gne__c,
        		IsPrivate__c,
        		External_Status_gne__c,
        		LastModifiedDate,
        		Name,
        		Nature_Of_Payment_gne__c,
        		Nature_Of_Payment_frm_gne__c,
        		Opt_Out_gne__c,
        		Orig_Drug_Name_gne__c,
        		Orig_Form_Of_Payment_gne__c,
        		Orig_Nature_Of_Payment_gne__c,
        		Orig_Source_Transaction_Amount_gne__c,
        		Orig_Allocated_Transaction_Amount_gne__c,
        		Orig_Event_Actual_Attendee_Count_gne__c,
        		Orig_Event_Planned_Attendee_Count_gne__c,
        		OwnerId,
        		Owner.Name,
        		Source_Amount_gne__c,
        		Dispute_Resolver_gne__c,
        		Dispute_Resolver_gne__r.OwnerId,
        		Dispute_Resolver_gne__r.Owner.Name,
        		Dispute_List_gne__r.AGS_ST_Proxy_gne__c,
        		Dispute_List_gne__r.AGS_ST_Proxy_gne__r.User_gne__r.Email,
        		Dispute_List_gne__r.AGS_ST_Proxy_gne__r.User_gne__r.Name,
                Dispute_List_gne__r.AGS_ST_Proxy_gne__r.User_gne__r.Username,
        		Dispute_List_gne__r.Amount_gne__c,
        		Dispute_List_gne__r.CreatedDate,
        		Dispute_List_gne__r.Drug_Name_gne__c,
        		Dispute_List_gne__r.Form_Of_Payment_gne__c,
        		Dispute_List_gne__r.IsCmsDispute_gne__c,
                Dispute_List_gne__r.CmsDisputeId_gne__c,
        		Dispute_List_gne__r.Nature_Of_Payment_gne__c,
        		Dispute_List_gne__r.OwnerId,
        		Dispute_List_gne__r.Owner.Username,
        		Dispute_List_gne__r.Owner.Name,
        		AGS_Spend_Expense_Transaction_gne__c,
        		AGS_Spend_Expense_Transaction_gne__r.Allocated_Transaction_Amount_gne__c,
        		AGS_Spend_Expense_Transaction_gne__r.CreatedDate,
        		AGS_Spend_Expense_Transaction_gne__r.Event_Actual_Attendee_Count_gne__c,
        		AGS_Spend_Expense_Transaction_gne__r.Event_Planned_Attendee_Count_gne__c,
        		AGS_Spend_Expense_Transaction_gne__r.Event_Date_gne__c,
        		AGS_Spend_Expense_Transaction_gne__r.Form_Of_Payment_gne__c,
        		AGS_Spend_Expense_Transaction_gne__r.LogicalDeleteFlag_gne__c,
        		AGS_Spend_Expense_Transaction_gne__r.Nature_Of_Payment_gne__c,
        		AGS_Spend_Expense_Transaction_gne__r.Primary_Recipient_gne__c,
        		AGS_Spend_Expense_Transaction_gne__r.Primary_Recipient_gne__r.First_Name_gne__c,
        		AGS_Spend_Expense_Transaction_gne__r.Primary_Recipient_gne__r.Last_Name_gne__c,
 				AGS_Spend_Expense_Transaction_gne__r.Primary_Recipient_gne__r.Address_Line_1_gne__c,
 				AGS_Spend_Expense_Transaction_gne__r.Primary_Recipient_gne__r.Address_line_2_gne__c,
 				AGS_Spend_Expense_Transaction_gne__r.Primary_Recipient_gne__r.City_gne__c,
 				AGS_Spend_Expense_Transaction_gne__r.Primary_Recipient_gne__r.State_gne__c,
 				AGS_Spend_Expense_Transaction_gne__r.Primary_Recipient_gne__r.Zip_gne__c,
				AGS_Spend_Expense_Transaction_gne__r.Primary_Recipient_gne__r.Specialty_gne__c,
				AGS_Spend_Expense_Transaction_gne__r.Primary_Recipient_gne__r.NPI_gne__c,
				AGS_Spend_Expense_Transaction_gne__r.Party1_NPI_gne__c,
				AGS_Spend_Expense_Transaction_gne__r.Party1_ADDRESS_LINE1_gne__c,
				AGS_Spend_Expense_Transaction_gne__r.Party1_ADDRESS_LINE2_gne__c,
				AGS_Spend_Expense_Transaction_gne__r.Party1_CITY_gne__c,
				AGS_Spend_Expense_Transaction_gne__r.Party1_State_gne__c,
				AGS_Spend_Expense_Transaction_gne__r.Party1_ZIP_gne__c,
				AGS_Spend_Expense_Transaction_gne__r.PTY1_LIC_ST_CD_gne__c,
				AGS_Spend_Expense_Transaction_gne__r.PTY1_LIC_NUM_gne__c,
				AGS_Spend_Expense_Transaction_gne__r.Primary_Recipient_MDM_ID_gne__c,
				AGS_Spend_Expense_Transaction_gne__r.Secondary_Recipient_MDM_ID_gne__c,
        		AGS_Spend_Expense_Transaction_gne__r.SCH_Activity_gne__c,
        		AGS_Spend_Expense_Transaction_gne__r.SCh_Category_gne__c,
        		AGS_Spend_Expense_Transaction_gne__r.SCH_Expense__c,
        		AGS_Spend_Expense_Transaction_gne__r.SCH_Spend_gne__c,
        		AGS_Spend_Expense_Transaction_gne__r.Source_Transaction_Amount_gne__c,
        		AGS_Spend_Expense_Transaction_gne__r.Source_System_Code_gne__c,
        		AGS_Spend_Expense_Transaction_gne__r.Unique_Transaction_Id_gne__c
			FROM AGS_ST_DisputeManagement_gne__c WHERE Id = :d.Id
			LIMIT 1
		];
		return d;
	}

    /** @date 7/20/2016
    * @Author Pawel Sprysak
    * @description Util Method - Create AGS Spend Expense Transaction
    * @param AGS_CCO_Case_Recipient_gne__c recipient
    * @return AGS_Spend_Expense_Transaction_gne__c
    */
    public static AGS_Spend_Expense_Transaction_gne__c createSpendExpenseTrans(AGS_CCO_Case_Recipient_gne__c recipient) {
    	return createSpendExpenseTrans(recipient, false);
    }

	/** @date 3/3/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create AGS Spend Expense Transaction
	* @param AGS_CCO_Case_Recipient_gne__c recipient, Boolean isResearch
	* @return AGS_Spend_Expense_Transaction_gne__c
	*/
	public static AGS_Spend_Expense_Transaction_gne__c createSpendExpenseTrans(AGS_CCO_Case_Recipient_gne__c recipient, Boolean isResearch) {
		String pymtType = 'NON-CLINICAL';
		if(isResearch) {
			pymtType = 'CLINICAL';
		}
		AGS_Spend_Expense_Transaction_gne__c t = new AGS_Spend_Expense_Transaction_gne__c(
			Allocated_Transaction_Amount_gne__c = 5,
			Event_Date_gne__c 					= Date.today(),
			Event_ID_gne__c 					= 'EventId',
			Form_Of_Payment_gne__c 				= 'Cash or cash equivalent',
			Home_Payment_ID_gne__c 				= 'HOMEID00001_NR',
			LogicalDeleteFlag_gne__c			= false,
			Nature_Of_Payment_gne__c 			= 'Consulting Fee',
			Primary_Recipient_gne__c 			= recipient.Id,
			Report_Code_gne__c 					= 'XC_MON',
			SCh_Category_gne__c 				= 'Category',
			Source_System_Code_gne__c			= 'SAPBW',
			Source_Transaction_Amount_gne__c 	= 5.0,
			Source_Transaction_ID_gne__c 		= 'transId',
			Study_Name_gne__c 					= 'StudyName',
			Research_Pymt_Typ_Cd_gne__c         = pymtType
		);
		insert t;
		checkIfIdExistsAfterInsert(t);
		return t;
	}

	/** @date 3/3/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create AGS Spend Recipient
	* @return AGS_CCO_Case_Recipient_gne__c
	*/
	public static AGS_CCO_Case_Recipient_gne__c createSpendRecipient() {
		AGS_CCO_Case_Recipient_gne__c  r = new AGS_CCO_Case_Recipient_gne__c(
		    Name                    = '12345',
			First_Name_gne__c 		= 'FirstName',
			Last_Name_gne__c 		= 'LastName',
			Tax_Id_gne__c 			= '123456789',
			Address_Line_1_gne__c 	= '312 6TH AVE',
			Address_Line_2_gne__c 	= '312 6TH AVE',
			City_gne__c 			= 'CHARLESTON',
			State_gne__c 			= 'West Virginia',
			Zip_gne__c 				= '11518'
		);
		insert r;
		checkIfIdExistsAfterInsert(r);
		return r;
	}

	/** @date 3/3/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create AGS ST Dispute Resolver
	* @return AGS_ST_DisputeResolver_gne__c
	*/
	public static AGS_ST_DisputeResolver_gne__c createDisputeResolver() {
		AGS_ST_DisputeResolver_gne__c dr = new AGS_ST_DisputeResolver_gne__c();
		insert dr;
		checkIfIdExistsAfterInsert(dr);
		return dr;
	}

	/** @date 3/4/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create AGS Recipient License State
	* @param AGS_CCO_Case_Recipient_gne__c recipient
	* @return AGS_Recipient_License_State_gne__c
	*/
	public static AGS_Recipient_License_State_gne__c createRecipientLicenseState(AGS_CCO_Case_Recipient_gne__c recipient) {
		AGS_Recipient_License_State_gne__c rls = new AGS_Recipient_License_State_gne__c(
			AGS_Recipient_MDM_ID_gne__c = recipient.Id,
			License_State_gne__c 		= 'West Virginia',
			State_License_Number_gne__c = '20783'
		);
		insert rls;
		checkIfIdExistsAfterInsert(rls);
		return rls;
	}

	/** @date 3/4/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create AGS Dispute Note And Attachments
	* @param AGS_ST_DisputeManagement_gne__c dispute
	* @return List<AGS_ST_Dispute_Note_and_Attachment_gne__c>
	*/
	public static List<AGS_ST_Dispute_Note_and_Attachment_gne__c> createDisputeNoteAndAttachments(AGS_ST_DisputeManagement_gne__c dispute) {
		List<AGS_ST_Dispute_Note_and_Attachment_gne__c> dnaa = new List<AGS_ST_Dispute_Note_and_Attachment_gne__c>{
			 new AGS_ST_Dispute_Note_and_Attachment_gne__c(
			 	AGS_ST_Dispute_Management_gne__c = dispute.Id,
			 	About_gne__c = null,
			 	Email_Recipients_gne__c = 'test@gmail.com',
			 	Communication_Type_gne__c = 'From Physician',
			 	IsPrivate_gne__c = false
			 ),
			 new AGS_ST_Dispute_Note_and_Attachment_gne__c(
			 	AGS_ST_Dispute_Management_gne__c = dispute.Id,
			 	About_gne__c = 'HCP Dispute',
			 	Email_Recipients_gne__c = 'test@gmail.com',
			 	Communication_Type_gne__c = 'To Physician',
			 	IsPrivate_gne__c = false
			 )
		};
		insert dnaa;
		checkIfIdExistsAfterInsert(dnaa);
		return dnaa;
	}

	/** @date 3/4/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create Attachments for AGS Dispute Note And Attachments
	* @param List<AGS_ST_Dispute_Note_and_Attachment_gne__c> disputeNoteAndAttachments
	* @return List<Attachment>
	*/
	public static List<Attachment> createAttachmentsForDistputes(List<AGS_ST_Dispute_Note_and_Attachment_gne__c> disputeNoteAndAttachments) {
		List<Attachment> attachs = new List<Attachment>();
		for(Integer i = 0; i < disputeNoteAndAttachments.size(); i++) {
			attachs.add(
				new Attachment(
					ParentId 	= disputeNoteAndAttachments[i].Id,
					Name 		= 'Test' + i,
					Body 		= Blob.valueOf('Test'),
					ContentType = 'text/plain'
				)
			);
		}
		insert attachs;
		checkIfIdExistsAfterInsert(attachs);
		return attachs;
	}

	/** @date 4/9/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create Notes for AGS Dispute Note And Attachments
	* @param List<AGS_ST_Dispute_Note_and_Attachment_gne__c> disputeNoteAndAttachments
	* @return List<Note>
	*/
	public static List<Note> createNotesForDistputes(List<AGS_ST_Dispute_Note_and_Attachment_gne__c> disputeNoteAndAttachments) {
		List<Note> noteList = new List<Note>();
		for(Integer i = 0; i < disputeNoteAndAttachments.size(); i++) {
			noteList.add(
				new Note(
					ParentId = disputeNoteAndAttachments[i].Id,
					Body 	= 'Test',
					Title 	= 'Title'
				)
			);
		}
		insert noteList;
		checkIfIdExistsAfterInsert(noteList);
		return noteList;
	}

	/** @date 3/5/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create AGS Expense Products Interactions
	* @param List<AGS_Brand_gne__c> brands
	* @param Id spendExpenseTransId
	* @return List<AGS_Expense_Products_Interaction__c>
	*/
	public static List<AGS_Expense_Products_Interaction__c> createExpenseProductsInteractions(List<AGS_Brand_gne__c> brands, Id transactionId) {
		List<AGS_Expense_Products_Interaction__c> pis = new List<AGS_Expense_Products_Interaction__c>();
		for(AGS_Brand_gne__c b : brands) {
			pis.add(
				new AGS_Expense_Products_Interaction__c(
					Expense_Transaction_ID_gne__c 		= transactionId,
					AGS_Brand_gne__c 					= b.Id
				)
			);
		}
		insert pis;
		checkIfIdExistsAfterInsert( pis );
		return pis;
	}

	/** @date 3/5/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create User
	* @param String profileName
	* @return User
	*/
	public static User createUser(String profileName) {
		Profile p = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
        User u = new User(
        	FirstName 			= 'John',
        	Alias 				= 'gssptest',
        	Email 				= 'aggstestuser@gene.com',
            EmailEncodingKey 	= 'UTF-8',
            LastName 			= 'Brown',
            LanguageLocaleKey 	= 'en_US',
            LocaleSidKey 		= 'en_US',
            ProfileId 			= p.Id,
            TimeZoneSidKey 		= 'America/Los_Angeles',
            Username 			= 'aggstestuser@gene.com'
        );
       	return u;
	}

	/** @date 3/5/2014
	* @Author Konrad Malinowski
	* @description Util Future Method - Create System Administrator User and assign to CCO Analyst Group
	* @param String username
	*/
	@future
    public static void insertSysAdminUserAndAssignToCcoAnalystGroup(String username) {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User u = new User(
        	FirstName 			= 'John',
        	Alias 				= 'assstest',
        	Email 				= 'aggstestuser@gene.com',
            EmailEncodingKey 	= 'UTF-8',
            LastName 			= 'Brown',
            LanguageLocaleKey 	= 'en_US',
            LocaleSidKey 		= 'en_US',
            ProfileId 			= p.Id,
            TimeZoneSidKey 		= 'America/Los_Angeles',
            Username 			= username
        );
        insert u;
        Group g = [SELECT Id FROM Group WHERE Name = 'GNE-AGS-CCO-Analyst-Group' LIMIT 1];
        insert new GroupMember(GroupId = g.Id, UserOrGroupId = u.Id);
    }

    /** @date 3/14/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create CCO Analyst Group User
	* @param String username
	* @return User
	*/
    public static User createCcoAnalystUser(String username) {
    	User usr = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
     	System.runAs(usr) {
	    	Test.startTest();
			insertSysAdminUserAndAssignToCcoAnalystGroup(username);
			Test.stopTest();
		}
		return [SELECT Id, AccountId, Username FROM User WHERE Username = :username LIMIT 1];
    }

    /** @date 3/6/2014
	* @Author Konrad Malinowski
	* @description Util Method - Prepare Attachment
	* @param Id parentId
	* @return Attachment
	*/
	public static Attachment prepareAttachment(Id parentId) {
		Attachment a = new Attachment(
			ParentId 	= parentId,
			Name 		= 'Test',
			Body 		= Blob.valueOf('Test'),
			ContentType = 'text/plain'
		);
		insert a;
		a = [SELECT Id, Body, BodyLength, ContentType, Name FROM Attachment WHERE Id = :a.Id];
		delete [SELECT Id FROM Attachment WHERE Id = :a.Id];
		a.Id = null;
		return a;
	}

	/** @date 3/6/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create AGS ST Dispute List
	* @param Id spendId
	* @return AGS_ST_Dispute_List_gne__c
	*/
	public static AGS_ST_Dispute_List_gne__c createDisputeList(Id spendId) {
		AGS_ST_Dispute_List_gne__c dl = new AGS_ST_Dispute_List_gne__c(
			AGS_Spend_Expense_Transaction_gne__c 	= spendId,
            AGS_ST_Proxy_gne__c     = createProxy().Id,
			IsPrivate_gne__c 		= false,
			IsAmountDisputed_gne__c = true,
			IsFormDisputed_gne__c	= true,
			IsNatureDisputed_gne__c = true,
			IsBrandDisputed_gne__c 	= true
		);
		insert dl;
		checkIfIdExistsAfterInsert(dl);
		return dl;
	}

    /** @date 10/3/2014
    * @Author Konrad Malinowski
    * @description Util Method - Create AGS ST Proxy
    * @return AGS_ST_Proxy_gne__c
    */
    public static AGS_ST_Proxy_gne__c createProxy() {
        AGS_ST_Proxy_gne__c p = new AGS_ST_Proxy_gne__c(
            User_gne__c = UserInfo.getUserId()
        );
        insert p;
        checkIfIdExistsAfterInsert(p);
        return p;
    }

	/** @date 3/7/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create AGS ST Setting
	* @return AGS_ST_Settings_gne__c
	*/
	public static AGS_ST_Settings_gne__c createAgsSetting() {
		List<OrgWideEmailAddress> oweas = [SELECT DisplayName FROM OrgWideEmailAddress];
		System.assertNotEquals( 0, oweas.size() );

		AGS_ST_Settings_gne__c s = new AGS_ST_Settings_gne__c(
			ARX_QuizAccount__c 			= '0',
			ARX_Url_gne__c 				= 'http://dev.sunshine.iassist.com',
			CmsPaymentIdDisplayDate_gne__c = Date.today().addDays(-1),
			Is_Arx_Skip_gne__c 			= true,
			Name 						= 'test',
			OrgWideAddressName_gne__c 	= oweas[0].DisplayName,
			Site_Domain_gne__c 			= URL.getSalesforceBaseUrl().toExternalForm()
		);
		insert s;
		checkIfIdExistsAfterInsert(s);
		return s;
	}

	/** @date 3/11/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create AGS ST Held Transaction
	* @return AGS_ST_Held_Transaction_gne__c
	*/
	public static AGS_ST_Held_Transaction_gne__c createHeldTransaction() {
		AGS_ST_Held_Transaction_gne__c ht = new AGS_ST_Held_Transaction_gne__c(
			Actual_Attendee_Count_gne__c 	= 1,
			Brand_Code_List_gne__c 			= 'Indirect Product',
			Form_of_Payment_gne__c 			= 'Cash or cash equivalent',
			Held_Transaction_Process_Status_Code_gne__c = 'Ok to Process',
			MDM_ID_GNE__c 					= 'MDM_ID',
			Nature_of_Payment_gne__c 		= 'Consulting Fee',
			Planned_Attendee_Count__c 		= 1,
			SRC_EXP_KEY_GNE__c 				= 'SRC_EXP_KEY_GNE__c',
			Source_Transaction_Amount_gne__c= 1,
			Transaction_Date_gne__c 		= Date.today()
		);
		insert ht;
		checkIfIdExistsAfterInsert(ht);
		return [
			SELECT 	Name,
					Actual_Attendee_Count_gne__c,
					Brand_Code_List_gne__c,
					Form_of_Payment_gne__c,
					Held_Transaction_Process_Status_Code_gne__c,
					MDM_ID_GNE__c,
					Nature_of_Payment_gne__c,
					Planned_Attendee_Count__c,
					SRC_EXP_KEY_GNE__c,
					Source_Transaction_Amount_gne__c,
					Transaction_Date_gne__c
			FROM 	AGS_ST_Held_Transaction_gne__c
			WHERE 	Id = :ht.Id
		];
	}

	/** @date 3/11/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create AGS ST Held And Dispute Junction
	* @param AGS_ST_Held_Transaction_gne__c heldTrans
	* @param AGS_ST_DisputeManagement_gne__c dispute
	* @return AGS_ST_Held_And_Dispute_Junction_gne__c
	*/
	public static AGS_ST_Held_And_Dispute_Junction_gne__c createHeldAndDisputeJunction(AGS_ST_Held_Transaction_gne__c heldTrans, AGS_ST_DisputeManagement_gne__c dispute) {
		AGS_ST_Held_And_Dispute_Junction_gne__c hdj = new AGS_ST_Held_And_Dispute_Junction_gne__c(
			AGS_ST_Held_Transaction_gne__c = heldTrans.Id,
			AGS_ST_Dispute_Management_gne__c = dispute.Id,
			AGS_ST_ProcessedByEmailBatch_gne__c = true
		);
		insert hdj;
		checkIfIdExistsAfterInsert(hdj);
		return [SELECT Id,
				AGS_ST_Held_Transaction_gne__c,
				AGS_ST_Dispute_Management_gne__c,
				LastModifiedDate,
				AGS_ST_Direct_Relationship_Indicator_gne__c,
				AGS_ST_Dispute_Management_gne__r.Name,
				AGS_ST_Dispute_Management_gne__r.Id,
				AGS_ST_Dispute_Management_gne__r.isPrivate__c,
				AGS_ST_Dispute_Management_gne__r.Internal_Status_gne__c
			FROM AGS_ST_Held_And_Dispute_Junction_gne__c WHERE Id = :hdj.Id LIMIT 1];
	}

	/** @date 3/18/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create AGS ST CMS Popup
	* @param AGS_ST_FAQ_DYK_gne__c faq
	* @return AGS_ST_FAQ_DYK_gne__c
	*/
	public static AGS_ST_FAQ_DYK_gne__c createPopup(AGS_ST_FAQ_DYK_gne__c faq) {
		Date today = Date.today();
		AGS_ST_FAQ_DYK_gne__c p = new AGS_ST_FAQ_DYK_gne__c(
			Type_gne__c 				= 'Popup',
			StartDate_gne__c 			= today.addDays(-1),
			EndDate_gne__c 				= today.addDays(1),
			TC_Description_Text_gne__c 	= '<a href="#" data-faq-id="' + faq.Id + '"></a>',
			Status_gne__c 				= 'Active'
		);
		insert p;
		checkIfIdExistsAfterInsert(p);
		return p;
	}

	/** @date 3/18/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create AGS ST CMS FAQ
	* @return AGS_ST_FAQ_DYK_gne__c
	*/
	public static AGS_ST_FAQ_DYK_gne__c createFaq() {
		AGS_ST_FAQ_DYK_gne__c faq = new AGS_ST_FAQ_DYK_gne__c(
			Type_gne__c 			= 'FAQ',
			Question_number_gne__c 	= 1,
			Question_gne__c 		= 'How are you?',
			Answer_gne__c 			= 'Fine, thanks.'
		);
		insert faq;
		checkIfIdExistsAfterInsert(faq);
		return faq;
	}

	/** @date 3/19/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create AGS ST CMS Objects
	* @return Map<String, AGS_ST_FAQ_DYK_gne__c>
	*/
	public static Map<String, AGS_ST_FAQ_DYK_gne__c> createCmsObjects() {
		List<AGS_ST_FAQ_DYK_gne__c> cmsObjs = new List<AGS_ST_FAQ_DYK_gne__c>();
		List<String> types = new List<String>{ 'Popup', 'FAQ', 'Did you know', 'About Sunshine Act', 'Terms Conditions', 'ToolTip' };
		List<String> toolTipTypes = new List<String>{ 'User Details', 'Filters', 'What', 'Export', 'Detail1', 'Detail2', 'Phone',
			'Login', 'CMS Payment ID', 'ResearchTypeDescription', 'NonResearchTypeDescription', 'BothPaymentTypesDescription' };
		for(String type : types) {
			if(type != 'ToolTip') {
				cmsObjs.add(
					new AGS_ST_FAQ_DYK_gne__c(
						Type_gne__c = type,
						TC_Description_Text_gne__c = 'Description'
					)
				);
			} else {
				for(String toolTipType : toolTipTypes) {
					cmsObjs.add(
						new AGS_ST_FAQ_DYK_gne__c(
							Type_gne__c = type,
							ToolTip_Type_gne__c = toolTipType,
							TC_Description_Text_gne__c = 'Description'
						)
					);
				}
			}

		}
		insert cmsObjs;
		checkIfIdExistsAfterInsert(cmsObjs);
		Map<String, AGS_ST_FAQ_DYK_gne__c> cmsTypeToObjMap = new Map<String, AGS_ST_FAQ_DYK_gne__c>();
		for(AGS_ST_FAQ_DYK_gne__c cmsObj : cmsObjs) {
			cmsTypeToObjMap.put( cmsObj.Type_gne__c + ( String.isBlank(cmsObj.ToolTip_Type_gne__c) ? '' : ' ' + cmsObj.ToolTip_Type_gne__c ), cmsObj );
		}
		return cmsTypeToObjMap;
	}

	/** @date 3/21/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create User with Contact
	* @return User
	*/
	public static User createUserWithContact() {
		return createUserWithContact('GNE-CM-IHCP-PROFILE');
	}

	/** @date 3/21/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create User with given Profile name, with Contact
	* @return User
	*/
	public static User createUserWithContact(String profileName) {
		Account acc = new Account (Name = 'testAccount', MDMID_gne__c = '12345', NPI_vod__c = 'NPI');
		insert acc;
		Contact con = new Contact (AccountId = acc.id, LastName = 'testPortalUser');
		insert con;

		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		User u;
		System.runAs ( thisUser ) {
			//UserRole ur = [SELECT Id FROM UserRole WHERE PortalType = 'CustomerPortal' LIMIT 1];
			Profile p = [SELECT Id, Name FROM Profile WHERE Name = :profileName LIMIT 1];
	        String email = 'aggstestuserwithcon@gene.com';
	        u = new User(
	        	//UserRoleId 			= ur.Id,
	        	ProfileId 			= p.Id,
	        	ContactId 			= con.Id,
	        	FirstName 			= 'John',
	        	Alias 				= 'gssptest',
	        	Email 				= email,
	            EmailEncodingKey 	= 'UTF-8',
	            LastName 			= 'Brown',
	            LanguageLocaleKey 	= 'en_US',
	            LocaleSidKey 		= 'en_US',
	            TimeZoneSidKey 		= 'America/Los_Angeles',
	            Username 			= email + '.test'
	        );
			insert u;
			checkIfIdExistsAfterInsert(u);
		}
       	return [SELECT Id, AccountId, ContactId, Username, Email FROM User WHERE Id = :u.Id LIMIT 1];
	}

	/** @date 3/21/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create AGS ST User
	* @return AGS_ST_User_gne__c
	*/
	public static AGS_ST_User_gne__c createAgsUser(User u) {
		AGS_ST_Registration_gne__c r = createRegistration();
		AGS_ST_User_gne__c agsU = new AGS_ST_User_gne__c(
			Mapped_Account__c 			= u.AccountId,
			SFDC_User__c 				= u.Id,
			AGS_ST_Registration_gne__c 	= r.Id,
			State_License_gne__c 		= '12345',
			State_License_State_gne__c 	= 'CA',
			NPI_gne__c 					= '4444111103',
			First_name__c 				= 'Adam',
			Last_name__c 				= 'Test',
			Email_address__c 			= u.Username,
			IsTCaccepted__c 			= true,
			Filter_date_from_gne__c 	= '2014-01-01',
			Filter_date_to_gne__c 		= '2014-01-01',
			Filter_date_range_gne__c  	= 1,
			Filter_amount__c 			= '1',
			Activation_Hash_Number__c 	= 'q1w2e3r4t5y6',
			Phone_number__c 			= '123456789'
		);
		insert agsU;
		checkIfIdExistsAfterInsert(agsU);
		return [SELECT
				Mapped_Account__r.MDMID_gne__c,
				Mapped_Account__c,
				SFDC_User__c,
				AGS_ST_Registration_gne__c,
				State_License_gne__c,
				State_License_State_gne__c,
				NPI_gne__c,
				First_name__c,
				Last_name__c,
				Email_address__c,
				IsTCaccepted__c,
				Filter_date_from_gne__c,
				Filter_date_to_gne__c,
				Filter_date_range_gne__c,
				Filter_amount__c,
				Activation_Hash_Number__c
			FROM AGS_ST_User_gne__c WHERE Id = :agsU.Id
		];
	}

	/** @date 3/21/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create AGS ST AssistRx Management
	* @param AGS_ST_User_gne__c agsUser
	* @return AGS_ST_AssistRx_Management_gne__c
	*/
	public static AGS_ST_AssistRx_Management_gne__c createAssistRxManagement(AGS_ST_User_gne__c agsUser) {
		String longCall = '';
		for(Integer i = 0; i < 51; i++) {
			longCall += 'a';
		}
		AGS_ST_AssistRx_Management_gne__c arxM = new AGS_ST_AssistRx_Management_gne__c(
			AGS_ST_User_gne__c = agsUser.Id,
			WS_Call_Parameters_Long_gne__c = longCall,
			WS_Call_Response_Long_gne__c = longCall
		);
		insert arxM;
		checkIfIdExistsAfterInsert(arxM);
		return arxM;
	}

	/** @date 3/21/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create GNE IHCP User
	* @param User u
	* @return GNE_CM_IHCP_User__c
	*/
	public static GNE_CM_IHCP_User__c createIhcpUser(User u) {
		GNE_CM_IHCP_User__c ihcpU = new GNE_CM_IHCP_User__c(
			AGS_ST_Status__c = 'Submitted',
			LWO_Status__c    = 'Approved',
			MPS_Status__c    = 'Approved',
			SFDC_User__c     = u.Id
		);
		insert ihcpU;
		checkIfIdExistsAfterInsert(ihcpU);
		return ihcpU;
	}

	/** @date 3/24/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create AGS ST Registration
	* @return AGS_ST_Registration_gne__c
	*/
	public static AGS_ST_Registration_gne__c createRegistration() {
		AGS_ST_Registration_gne__c r = new AGS_ST_Registration_gne__c(
			State_gne__c 			= 'CA',
			City_gne__c 			= 'Los Angeles',
			Street_Address_gne__c 	= 'Test 1',
			Zip_gne__c 				= '90028',
			Gender_gne__c 			= 'Male'
		);
		insert r;
		checkIfIdExistsAfterInsert(r);
		return r;
	}

	/** @date 3/25/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create Person Account
	* @return Account
	*/
	public static Account createPersonAccount() {
		Account a = new Account(
			FirstName 		= 'FirstName',
			LastName 		= 'LastName',
			MDMID_gne__c 	= 'MDMID',
			NPI_vod__c 		= 'NPI'
		);
		insert a;
		checkIfIdExistsAfterInsert(a);
		return a;
	}

	/** @date 5/8/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create Business Account
	* @return Account
	*/
	public static Account createBusinessAccount() {
		Account a = new Account(
			Name = 'Business Account Name'
		);
		insert a;
		checkIfIdExistsAfterInsert(a);
		return a;
	}

	/** @date 3/27/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create Dispute Management History
	* @param AGS_ST_DisputeManagement_gne__c parent
	* @param String fieldName
	* @return AGS_ST_DisputeManagement_gne__History
	*/
	public static AGS_ST_DisputeManagement_gne__History createDisputeHistory(AGS_ST_DisputeManagement_gne__c parent, String fieldName) {
        return (AGS_ST_DisputeManagement_gne__History)JSON.deserialize(
            '{' +
                '"CreatedById"  : "' + UserInfo.getUserId()             + '",' +
                '"CreatedDate"  : "' + '2013-11-27T20:58:00.000+0000'   + '",' +
                '"Field"        : "' + fieldName                        + '",'  +
                '"ParentId"     : "' + parent.Id                        + '",' +
                '"Parent" : {' +
                	'"Name" : "' + parent.Name + '"' +
                '}' +
            '}',
             AGS_ST_DisputeManagement_gne__History.class
        );
    }

    /** @date 3/31/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create Spend Expense Transaction History
	* @param AGS_Spend_Expense_Transaction_gne__c parent
	* @param String fieldName
	* @return AGS_Spend_Expense_Transaction_gne__History
	*/
	public static AGS_Spend_Expense_Transaction_gne__History createTransactionHistory(AGS_Spend_Expense_Transaction_gne__c parent, String fieldName) {
        return (AGS_Spend_Expense_Transaction_gne__History)JSON.deserialize(
            '{' +
                '"CreatedById"  : "' + UserInfo.getUserId()             + '",' +
                '"CreatedDate"  : "' + '2013-11-27T20:58:00.000+0000'   + '",' +
                '"Field"        : "' + fieldName                        + '",'  +
                '"ParentId"     : "' + parent.Id                        + '",' +
                '"Parent" : {' +
                	'"Name" : "' + parent.Name + '"' +
                '}' +
            '}',
             AGS_Spend_Expense_Transaction_gne__History.class
        );
    }

    /** @date 4/1/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create AGS ST Expense Bookmark
	* @return AGS_ST_Expense_Bookmark__c
	*/
	public static AGS_ST_Expense_Bookmark__c createExpenseBookmark(Id transactionId) {
		AGS_ST_Expense_Bookmark__c eb = new AGS_ST_Expense_Bookmark__c(
			AGS_Spend_Expense_Transaction__c = transactionId,
			Bookmarked_User_gne__c = UserInfo.getUserId()
		);
		insert eb;
		checkIfIdExistsAfterInsert(eb);
		return eb;
	}

	/** @date 4/7/2014
	* @Author Konrad Malinowski
	* @description Util Method - Get current User
	* @return User
	*/
	public static User getCurrentUser() {
		User thisUser = [SELECT Id, AccountId, Username FROM User WHERE Id = :UserInfo.getUserId()];
		return thisUser;
	}

	/** @date 4/10/2014
	* @Author Konrad Malinowski
	* @description Util Method - Create AGS ST CMS User Popup
	* @param AGS_ST_FAQ_DYK_gne__c popup
	* @param AGS_ST_User_gne__c agsUser
	* @return AGS_ST_Popup_gne__c
	*/
	public static AGS_ST_Popup_gne__c createUserPopup(AGS_ST_FAQ_DYK_gne__c popup, AGS_ST_User_gne__c agsUser) {
		AGS_ST_Popup_gne__c up = new AGS_ST_Popup_gne__c(
			AGS_ST_CMS_gne__c = popup.Id,
			AGS_ST_User_gne__c = agsUser.Id
		);
		insert up;
		checkIfIdExistsAfterInsert(up);
		return up;
	}

	/** @date 4/7/2014
	* @Author Konrad Malinowski
	* @description Util Method - Initiate valid AGS ST User
	* @return AGS_ST_User
	*/
	public static AGS_ST_User initiateValidAgsStUser() {
		AGS_ST_User agsUser = new AGS_ST_User();
		List<SelectOption> genderList = agsUser.genderList;
		System.assertEquals( 4, genderList.size() );
		agsUser.firstName 			= 'Adam';
		agsUser.lastName 			= 'Test';
		agsUser.email 				= 'test@gmail.com';
		agsUser.email2 				= 'test@gmail.com';
		agsUser.npi 				= '1234567';
		agsUser.stateLicence 		= 'CA';
		agsUser.licenceStateCode 	= '12345';
		agsUser.street 				= 'Street';
		agsUser.suite 				= 'Suite';
		agsUser.city 				= 'Los Angeles';
		agsUser.state 				= 'CA';
		agsUser.zip 				= '12345';
		agsUser.dob 				= '1/1/2014';
		return agsUser;
	}
}