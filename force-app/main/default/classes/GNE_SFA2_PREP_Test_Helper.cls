@isTest
public with sharing class GNE_SFA2_PREP_Test_Helper {
	private static final String US_HCP_RECORD_TYPE_NAME = 'Health Care Professional (Prescriber)';
    private static final String US_HCO_RECORD_TYPE_NAME = 'Hospital';
    private static final String US_ADDRESS_RECORD_TYPE_NAME = 'Rep Maintained';


	private static User currentUser;
	private static User usOwner;
	private static Id prepQueueId;
	public static UserHelper userHelper;
	public static AccountHelper accountHelper;
	public static List<Product_vod__c> prepProds = new List<Product_vod__c>();
	public static List<Product_vod__c> eduItems = new List<Product_vod__c>();
	public static List<SFA2_PREP_MBO_gne__c> mbos = new List<SFA2_PREP_MBO_gne__c>();

	public static void init() {
		init('GNE-Field', 2);
	}

	public static void init(String userRole, Integer numberOfAccounts) {
		//insertPrepSettings();
		insertPrepProduct();
		insertTestingStrategiesAndMBOs();

		userHelper = new UserHelper();
		accountHelper = new AccountHelper();
		usOwner = userHelper.getUser('usOwner');
		currentUser = userHelper.getUser(userRole);
		accountHelper.insertAccountsWithAddresses(numberOfAccounts);
		accountHelper.createAccountShares(currentUser);
	}

	/*private static void insertPrepSettings() {
		Map<String, String> settings = new Map<String,String>{
			'TestTypes' => '{"Breast Cancer HER2 Testing": "prep-her2-breast", "EGFRm Testing": "prep-egfrm", "mGeJ/mGastric Testing": "prep-her2-gastric"}',
			'RootTerritoryNumber' => '0B4'

		};

		List<GNE_SFA2_PREP_Config_Items_gne__c> toInsert = new List<GNE_SFA2_PREP_Config_Items_gne__c>();

		for(String itemName : settings.keySet()) {
			String value = settings.get(itemName);
			GNE_SFA2_PREP_Config_Items_gne__c cRec = new GNE_SFA2_PREP_Config_Items_gne__c(Name = itemName);
			cRec.Value_gne__c = value;
			toInsert.add(cRec);
		}

		insert toInsert;
	}*/

	private static void insertPrepProduct() {
		String queueName = 'GNE-SFA-PREP-QUEUE';

		Set<String> prepProductNames = new Set<String>{
			'Breast Cancer HER2 Testing',
			'EGFRm Testing',
			'mGeJ/mGastric Testing'
		};

		Id ownerId = [SELECT Id FROM Group WHERE Name = :queueName].Id;
		prepQueueId = ownerId;
		List<Product_vod__c> detailProdsToInsert = new List<Product_vod__c>();

		for(String prodName : prepProductNames) {
			Product_vod__c dProd = new Product_vod__c(
					Name = prodName,
					Product_Type_vod__c = 'Detail',
					Detail_Product_Subtype_Code_gne__c = 'Approved Product Indications',
					OwnerId = ownerId
			);

			detailProdsToInsert.add(dProd);
		}

		if(!detailProdsToInsert.isEmpty()) {
			insert detailProdsToInsert;
			prepProds = detailProdsToInsert;
		}
	}

	private static void insertTestingStrategiesAndMBOs() {
		Map<String,Set<String>> testingData = new Map<String,Set<String>>{
			'Breast Cancer HER2 Testing' => new Set<String>{
				'MBO 1::Expanded Reflex Testing::Account re-tests in appropriate circumstances including: IHC 0/1+ and ISH-negatives per 2013 ASCO/CAP Guidelines::Red',
				'MBO 2::ISH Algorithm::Account reporting ISH based on algorithm defined in 2013 ASCO/CAP Guidelines::Red',
				'MBO 3::Clinical Trial Cutoffs::Account is scoring utilizing the clinical trial cutoffs (10% IHC staining and ISH 2.0)::Red',
				'MBO 4::HER2 Testing for Neoadj BC::Account ensures HER2 test result is available in all patients prior to surgery to ensure all therapy options are available to every patient::Gray'
			},
			'EGFRm Testing' => new Set<String>{
				'MBO 5::Rapid EGFRm Testing::Account recognizes turnaround time as an important parameter in EGFR testing and has implemented an EGFRm testing process that reduces EGFRm Testing TAT and increases # of NSCLC patients appropriately tested::Red',
				'MBO 6::Tissue Conservation::Account pre-cuts slides to avoid refacing in appropriate situations and creating multiple blocks to conserve NSCLC tissue::Red'
			},
			'mGeJ/mGastric Testing' => new Set<String>{
				'MBO 7::mGeJ/mGastric Testing::Account HER2 tests appropriate metastatic GeJ and Gastric cancer patients::Gray'
			}
		};

		List<String> tStrategyOrder = new List<String>{
			'Breast Cancer HER2 Testing',
			'EGFRm Testing',
			'mGeJ/mGastric Testing'
		};

		Map<String,String> strategyToProductMap = new Map<String,String>{
			'Breast Cancer HER2 Testing' => 'Breast Cancer HER2 Testing',
			'EGFRm Testing' => 'EGFRm Testing',
			'mGeJ/mGastric Testing' => 'mGeJ/mGastric Testing'
		};

		Map<String,Id> productNameToIdMap = new Map<String,Id>();

		for(Product_vod__c prod : prepProds) {
			productNameToIdMap.put(prod.Name, prod.Id);
		}

		Map<String,SFA2_PREP_Testing_Strategy_gne__c> tsToUpsert = new Map<String,SFA2_PREP_Testing_Strategy_gne__c>();

		Integer idx = 0;
		for(String tsName : tStrategyOrder) {
			SFA2_PREP_Testing_Strategy_gne__c ts = new SFA2_PREP_Testing_Strategy_gne__c(
				Name = tsName,
				Product_gne__c = productNameToIdMap.get(strategyToProductMap.get(tsName)),
				Region_Code_gne__c = 1,
				External_Id_gne__c = ('1_' + tsName),
				Order_gne__c = idx++
			);

			tsToUpsert.put(ts.Name, ts);
		}

		upsert tsToUpsert.values() External_Id_gne__c;

		List<SFA2_PREP_MBO_gne__c> mboToUpsert = new List<SFA2_PREP_MBO_gne__c>();

		for(String tsName : testingData.keySet()) {
			SFA2_PREP_Testing_Strategy_gne__c ts = tsToUpsert.get(tsName);
			for(String mboData : testingData.get(tsName)) {
				String[] mboDataList = mboData.split('::',4);
				String mboName = mboDataList[0];
				String mboDesc = mboDataList[1];
				String mboDef = mboDataList[2];
				String defaultStatus = mboDataList[3];
				SFA2_PREP_MBO_gne__c mbo = new SFA2_PREP_MBO_gne__c(
					Short_Description_gne__c = mboDesc,
					Definition_gne__c = mboDef,
					Default_Status_gne__c = defaultStatus,
					External_Id_gne__c = ts.External_Id_gne__c + '_' + mboName,
					Testing_Strategy_ref_gne__c = ts.Id,
					Testing_Strategy_ref_gne__r = ts
				);
				mboToUpsert.add(mbo);
			}
		}

		upsert mboToUpsert External_Id_gne__c;

		update tsToUpsert.values();
		update mboToUpsert;

		mbos = mboToUpsert;
	}

	public static void insertEducationalItems() {
		Map<String,Set<String>> eduItemsData = new Map<String,Set<String>>{
			'Breast Cancer HER2 Testing' => new Set<String>{'HER2 Testing leave behind::PRC', 'HER2 Testing slides::PRC'},
			'EGFRm Testing' => new Set<String>{'EGFR Testing leave behind::PRC', 'EGFRm Testing slides::PRC'},
			'mGeJ/mGastric Testing' => new Set<String>{}
		};

		String queueName = 'GNE-SFA-PREP-QUEUE';
		Id ownerId = prepQueueId;
		Map<String,Product_vod__c> detailProds = new Map<String, Product_vod__c>();

		for(Product_vod__c detailProd : prepProds) {
			detailProds.put(detailProd.Name.toUpperCase(), detailProd);
		}

		List<Product_vod__c> eduItemsToInsert = new List<Product_vod__c>();

		for(String prodName : eduItemsData.keySet()) {
			Product_vod__c prod = detailProds.get(prodName.toUpperCase());

			for(String edutItemData : eduItemsData.get(prodName)) {
				String[] edutItemDataList = edutItemData.split('::',2);
				String eduItemName = edutItemDataList[0];
				String eduItemType = edutItemDataList[1];

				Product_vod__c eduItem = new Product_vod__c(
					Name = eduItemName,
					Product_Type_vod__c = eduItemType,
					Parent_Product_vod__c = prod.Id,
					Active__c = true,
					OwnerId = ownerId
				);

				eduItemsToInsert.add(eduItem);
			}
		}

		insert eduItemsToInsert;
		eduItems = eduItemsToInsert;
	}

	public static void insertTestingInfoCOs() {
		Set<String> brandNames = new Set<String>{''};
		Set<String> roleNames = new Set<String>{'PREP-PS','PREP-DM','PREP-Manager'};
		Set<String> recordTypes = new Set<String>{''};
		String sObjName = 'SFA2_PREP_Account_Testing_Info_gne__c';

		List<Map<String,Object>> sectionsData = new List<Map<String,Object>>{
			new Map<String,Object>{'Name' => sObjName + '_buttons',
				'Details' => new List<Map<String,Object>>{
					new Map<String,Object>{'Name' => sObjName + '_Button', 'API_Name_gne__c' => 'Edit', 'Label_gne__c' => 'Edit', 'Type_gne__c' => 'Button',
						'Availability_Mode_gne__c' => null,
						'Attributes_gne__c' => 'action=edit;rerender=main-content;styleClass=button sfa-plh sfa-plh-title-bar;'}
				}
			},
			new Map<String,Object>{'Section_Header_gne__c' => 'Basic Information',
				'Details' => new List<Map<String,Object>>{
					new Map<String,Object>{'API_Name_gne__c' => 'Test_Type_gne__c', 'Label_gne__c' => 'Test Type', 'Is_Required_gne__c' => true},
					new Map<String,Object>{'API_Name_gne__c' => 'Account_gne__c', 'Label_gne__c' => 'Account', 'Is_Required_gne__c' => true, 'Is_Read_Only_gne__c' => true}
				}
			},
			new Map<String,Object>{'Section_Header_gne__c' => 'Test Type',
				'Attributes_gne__c' => 'prep-her2-breast',
				'Details' => new List<Map<String,Object>>{
					new Map<String,Object>{'API_Name_gne__c' => 'Test_Type_gne__c', 'Label_gne__c' => 'Test Type', 'Is_Required_gne__c' => true}
				}
			},
			new Map<String,Object>{'Section_Header_gne__c' => 'Test Type',
				'Attributes_gne__c' => 'prep-egfrm',
				'Details' => new List<Map<String,Object>>{
					new Map<String,Object>{'API_Name_gne__c' => 'Test_Type_gne__c', 'Label_gne__c' => 'Test Type', 'Is_Required_gne__c' => true}
				}
			},
			new Map<String,Object>{'Section_Header_gne__c' => 'Test Type',
				'Attributes_gne__c' => 'prep-her2-gastric',
				'Details' => new List<Map<String,Object>>{
					new Map<String,Object>{'API_Name_gne__c' => 'Test_Type_gne__c', 'Label_gne__c' => 'Test Type', 'Is_Required_gne__c' => true}
				}
			},
			new Map<String,Object>{'Section_Header_gne__c' => 'Breast Cancer HER2 Testing Information',
				'Attributes_gne__c' => 'prep-her2-breast',
				'Details' => new List<Map<String,Object>>{
					new Map<String,Object>{'API_Name_gne__c' => 'Test_Method_gne__c', 'Label_gne__c' => 'Test Method', 'Is_Required_gne__c' => true},
					new Map<String,Object>{'API_Name_gne__c' => 'Test_Hierarchy_gne__c', 'Label_gne__c' => 'Test Hierarchy'},
					new Map<String,Object>{'API_Name_gne__c' => 'Test_Component_gne__c', 'Label_gne__c' => 'Test Component', 'Is_Required_gne__c' => true},
					new Map<String,Object>{'API_Name_gne__c' => 'Referred_Account_gne__c', 'Label_gne__c' => 'Refers to', 'Attributes_gne__c' => '--customLookup'},
					new Map<String,Object>{'API_Name_gne__c' => 'Stage_Tested_gne__c', 'Label_gne__c' => 'Stage Tested'},
					new Map<String,Object>{'API_Name_gne__c' => 'Test_Initiator_gne__c', 'Label_gne__c' => 'Test Initiator'},
					new Map<String,Object>{'API_Name_gne__c' => 'Percent_of_TC_gne__c', 'Label_gne__c' => '% TC'},
					new Map<String,Object>{'API_Name_gne__c' => 'Testing_Volume_Month_gne__c', 'Label_gne__c' => 'Testing Volume/Year'},
					new Map<String,Object>{'API_Name_gne__c' => 'Percent_of_Global_gne__c', 'Label_gne__c' => '% Global'}
				}
			},
			new Map<String,Object>{'Section_Header_gne__c' => 'Who is overall MDT Lead?',
				'Attributes_gne__c' => 'prep-her2-breast',
				'Details' => new List<Map<String,Object>>{
					new Map<String,Object>{'API_Name_gne__c' => 'MDT_Lead_gne__c', 'Label_gne__c' => 'Name'},
					new Map<String,Object>{'API_Name_gne__c' => 'MDT_Lead_Title_gne__c', 'Label_gne__c' => 'Title'}
				}
			},
			new Map<String,Object>{'Section_Header_gne__c' => 'EGFRm Testing Information',
				'Attributes_gne__c' => 'prep-egfrm',
				'Details' => new List<Map<String,Object>>{
					new Map<String,Object>{'API_Name_gne__c' => 'Test_Method_gne__c', 'Label_gne__c' => 'Test Method', 'Is_Required_gne__c' => true},
					new Map<String,Object>{'API_Name_gne__c' => 'Test_Hierarchy_gne__c', 'Label_gne__c' => 'Test Hierarchy'},
					new Map<String,Object>{'API_Name_gne__c' => 'Test_Component_gne__c', 'Label_gne__c' => 'Test Component', 'Is_Required_gne__c' => true},
					new Map<String,Object>{'API_Name_gne__c' => 'Referred_Account_gne__c', 'Label_gne__c' => 'Refers to', 'Attributes_gne__c' => '--customLookup'},
					new Map<String,Object>{'API_Name_gne__c' => 'Stage_Tested_gne__c', 'Label_gne__c' => 'Stage Tested'},
					new Map<String,Object>{'API_Name_gne__c' => 'Test_Initiator_gne__c', 'Label_gne__c' => 'Test Initiator'},
					new Map<String,Object>{'API_Name_gne__c' => 'Percent_of_TC_gne__c', 'Label_gne__c' => '% TC'},
					new Map<String,Object>{'API_Name_gne__c' => 'Testing_Volume_Month_gne__c', 'Label_gne__c' => 'Testing Volume/Year'},
					new Map<String,Object>{'API_Name_gne__c' => 'Percent_of_Global_gne__c', 'Label_gne__c' => '% Global'}
				}
			},
			new Map<String,Object>{'Section_Header_gne__c' => 'Who is overall MDT Lead?',
				'Attributes_gne__c' => 'prep-egfrm',
				'Details' => new List<Map<String,Object>>{
					new Map<String,Object>{'API_Name_gne__c' => 'MDT_Lead_gne__c', 'Label_gne__c' => 'Name'},
					new Map<String,Object>{'API_Name_gne__c' => 'MDT_Lead_Title_gne__c', 'Label_gne__c' => 'Title'}
				}
			},
			new Map<String,Object>{'Section_Header_gne__c' => 'mGeJ/mGastric Testing Information',
				'Attributes_gne__c' => 'prep-her2-gastric',
				'Details' => new List<Map<String,Object>>{
					new Map<String,Object>{'API_Name_gne__c' => 'Testing_Volume_Month_gne__c', 'Label_gne__c' => 'Testing Volume/Year'}
				}
			}

		};

		SFA2_Configuration_Object_gne__c coTemplate = new SFA2_Configuration_Object_gne__c(
			Name = sObjName + '_detail',
			Application_Type__c = 'SFA-US',
			Configuration_Type_gne__c = 'Page',
			Is_Active_gne__c = true,
			Is_Default_Record_Type_gne__c = true,
			Object_Name_gne__c = sObjName,
			OTR2_gne__c = false,
			RT_Available_On_Create_gne__c = false
		);

		SFA2_Configuration_Object_Detail_gne__c codTemplate = new SFA2_Configuration_Object_Detail_gne__c(
			Type_gne__c = 'Field',
			Availability_Mode_gne__c = 'Edit;New;View',
			Is_Active_gne__c = true,
			Is_Read_Only_gne__c = false,
			Is_Required_gne__c = false,
			OTR2_gne__c = false
		);

		Map<String,SFA2_Configuration_Object_gne__c> cosToInsert = insertCos(coTemplate, sectionsData, brandNames, roleNames, recordTypes);
		List<SFA2_Configuration_Object_Detail_gne__c> codsToInsert = insertCods(codTemplate, sectionsData, brandNames, roleNames, recordTypes, cosToInsert);
	}

	public static void insertPrepInteractionCOs() {
		Set<String> brandNames = new Set<String>{''};
		Set<String> roleNames = new Set<String>{'PREP-PS','PREP-DM','PREP-Manager'};
		String sObjName = 'Call2_vod__c';
		String newRecordTypeName = 'PREP_Interaction';

		List<Map<String,Object>> sectionsData = new List<Map<String,Object>>{
			new Map<String,Object>{'Name' => 'CallDetail', 'Section_Header_gne__c' => 'Interaction Information',
				'Attributes_gne__c' => '--nap,--nab,--notEditableOnComplete',
				'Details' => new List<Map<String,Object>>{
					new Map<String,Object>{'API_Name_gne__c' => 'Account_vod__c', 'Label_gne__c' => 'Account', 'Is_Read_Only_gne__c' => true},
					new Map<String,Object>{'API_Name_gne__c' => 'Call_Datetime_vod__c', 'Label_gne__c' => 'Date', 'Is_Required_gne__c' => true},
					new Map<String,Object>{'API_Name_gne__c' => 'PREP_Status_gne__c', 'Label_gne__c' => 'Status', 'Is_Read_Only_gne__c' => true},
					//new Map<String,Object>{'API_Name_gne__c' => 'PREP_Status_calc_gne__c', 'Label_gne__c' => 'Status', 'Is_Read_Only_gne__c' => true, 'Availability_Mode_gne__c' => 'View'},
					new Map<String,Object>{'API_Name_gne__c' => 'Interaction_Type_gne__c', 'Label_gne__c' => 'Interaction Type'},
					new Map<String,Object>{'API_Name_gne__c' => 'Name', 'Label_gne__c' => 'Interaction Name', 'Is_Read_Only_gne__c' => true, 'Availability_Mode_gne__c' => 'Edit;View'},
					new Map<String,Object>{'API_Name_gne__c' => 'Interaction_Status_gne__c', 'Label_gne__c' => 'Interaction Status', 'Is_Required_gne__c' => true},
					new Map<String,Object>{'API_Name_gne__c' => 'Parent_Address_vod__c', 'Label_gne__c' => 'Address', 'Is_Required_gne__c' => true},
					new Map<String,Object>{'API_Name_gne__c' => 'Interaction_Length_gne__c', 'Label_gne__c' => 'Length of Interaction', 'Is_Required_gne__c' => true},
					new Map<String,Object>{'API_Name_gne__c' => 'Date_Completed_gne__c', 'Label_gne__c' => 'Date Completed'},
					new Map<String,Object>{'API_Name_gne__c' => 'Collaboration_gne__c', 'Label_gne__c' => 'Collaboration', 'Attributes_gne__c' => '--mpicklistEnhUI'}
				}
			},
			new Map<String,Object>{'Name' => 'CallDetail', 'Section_Header_gne__c' => 'Next Steps',
				'Attributes_gne__c' => '--notEditableOnComplete',
				'Details' => new List<Map<String,Object>>{
					new Map<String,Object>{'API_Name_gne__c' => 'PREP_Follow_Up_With_gne__c', 'Label_gne__c' => 'Follow up with'},
					new Map<String,Object>{'API_Name_gne__c' => 'PREP_MBOs_gne__c', 'Label_gne__c' => 'Regarding'},
					new Map<String,Object>{'API_Name_gne__c' => 'PREP_Speak_With_gne__c', 'Label_gne__c' => 'Speak with'},
					new Map<String,Object>{'API_Name_gne__c' => 'PREP_About_gne__c', 'Label_gne__c' => 'About', 'Attributes_gne__c' => '--mpicklistEnhUI'},
					new Map<String,Object>{'API_Name_gne__c' => 'Blank Space', 'Type_gne__c' => 'Blank Space'},
					new Map<String,Object>{'API_Name_gne__c' => 'PREP_Other_gne__c', 'Label_gne__c' => 'Other'}
				}
			},
			new Map<String,Object>{'Name' => 'CallAttendees', 'Section_Header_gne__c' => 'Attendees',
				'Attributes_gne__c' => '--paa,--ns,--nnc,--su,--st',
				'Details' => new List<Map<String,Object>>{
					new Map<String,Object>{'API_Name_gne__c' => 'PREP_Status_gne__c', 'Label_gne__c' => 'Status', 'Is_Read_Only_gne__c' => true, 'Attributes_gne__c' => '--columnField'},
					//new Map<String,Object>{'API_Name_gne__c' => 'PREP_Status_calc_gne__c', 'Label_gne__c' => 'Status', 'Is_Read_Only_gne__c' => true, 'Attributes_gne__c' => '--columnField', 'Availability_Mode_gne__c' => 'View'},
					new Map<String,Object>{'API_Name_gne__c' => 'Other_Attendees_Count_gne__c', 'Label_gne__c' => 'Count of other Attendees'}
				}
			},
			new Map<String,Object>{'Name' => 'CallObjectives', 'Section_Header_gne__c' => 'Testing Discussion',
				'Attributes_gne__c' => '--rd',
				'Details' => new List<Map<String,Object>>{
					new Map<String,Object>{'API_Name_gne__c' => 'Product_vod__c', 'Label_gne__c' => 'Test'},
					new Map<String,Object>{'API_Name_gne__c' => 'PREP_MBO_gne__c', 'Label_gne__c' => 'MBO'}
				}
			},
			new Map<String,Object>{'Name' => 'CallMealExpense', 'Section_Header_gne__c' => 'Meal Expense',
				'Attributes_gne__c' => '--mealOptOut',
				'Details' => new List<Map<String,Object>>{
					new Map<String,Object>{'API_Name_gne__c' => 'Meal_Expense_gne__c', 'Label_gne__c' => 'Meal Expense Included?'},
					new Map<String,Object>{'API_Name_gne__c' => 'Planned_Attendees_gne__c', 'Label_gne__c' => '# Planned Meal Recipients'},
					new Map<String,Object>{'API_Name_gne__c' => 'Blank Space', 'Type_gne__c' => 'Blank Space'},
					new Map<String,Object>{'API_Name_gne__c' => 'Actual_Attendees_gne__c', 'Label_gne__c' => '# Actual Meal Recipients'}
				}
			},
			new Map<String,Object>{'Name' => 'CallMaterials', 'Section_Header_gne__c' => 'Educational Items',
				'Attributes_gne__c' => '--ns,--pg',
				'Details' => new List<Map<String,Object>>{
					new Map<String,Object>{'API_Name_gne__c' => 'Product_vod__c', 'Label_gne__c' => 'Educational Items', 'Is_Required_gne__c' => true},
					new Map<String,Object>{'API_Name_gne__c' => 'Account_vod__c', 'Label_gne__c' => 'Recipient', 'Is_Required_gne__c' => true},
					new Map<String,Object>{'API_Name_gne__c' => 'Quantity_vod__c', 'Label_gne__c' => 'Quantity', 'Is_Required_gne__c' => true}
				}
			}
		};

		SFA2_Configuration_Object_gne__c coTemplate = new SFA2_Configuration_Object_gne__c(
			Name = sObjName + '_detail',
			Application_Type__c = 'SFA-US',
			Configuration_Type_gne__c = 'Page',
			Is_Active_gne__c = true,
			Is_Default_Record_Type_gne__c = true,
			Object_Name_gne__c = sObjName,
			OTR2_gne__c = false,
			Record_Type_gne__c = newRecordTypeName,
			RT_Available_On_Create_gne__c = false
		);

		SFA2_Configuration_Object_Detail_gne__c codTemplate = new SFA2_Configuration_Object_Detail_gne__c(
			Type_gne__c = 'Field',
			Availability_Mode_gne__c = 'New;Edit;View',
			Is_Active_gne__c = true,
			Is_Read_Only_gne__c = false,
			Is_Required_gne__c = false,
			OTR2_gne__c = false
		);

		Map<String,SFA2_Configuration_Object_gne__c> cosToInsert = insertCos(coTemplate, sectionsData, brandNames, roleNames, new Set<String>{newRecordTypeName});
		List<SFA2_Configuration_Object_Detail_gne__c> codsToInsert = insertCods(codTemplate, sectionsData, brandNames, roleNames, new Set<String>{newRecordTypeName}, cosToInsert);
	}

	public static void insertAccSocMemCOs() {
		Set<String> brandNames = new Set<String>{''};
		Set<String> roleNames = new Set<String>{'PREP-PS','PREP-DM','PREP-Manager'};
		Set<String> recordTypes = new Set<String>{''};
		String sObjName = 'SFA2_Account_Society_Membership_gne__c';

		List<Map<String,Object>> sectionsData = new List<Map<String,Object>>{
			new Map<String,Object>{'Name' => sObjName + '_buttons',
				'Details' => new List<Map<String,Object>>{
					new Map<String,Object>{'Name' => sObjName + '_Button', 'API_Name_gne__c' => 'Edit', 'Label_gne__c' => 'Edit', 'Type_gne__c' => 'Button',
						'Availability_Mode_gne__c' => null,
						'Attributes_gne__c' => 'action=edit;rerender=main-content;styleClass=button sfa-plh sfa-plh-title-bar;'},
					new Map<String,Object>{'Name' => sObjName + '_Button', 'API_Name_gne__c' => 'Delete', 'Label_gne__c' => 'Delete', 'Type_gne__c' => 'Button',
						'Availability_Mode_gne__c' => null,
						'Attributes_gne__c' => 'action=deleteClick;styleClass=button sfa-plh sfa-plh-title-bar;onclick=if(!confirm(\'Are you sure?\')) return false;'}
				}
			},
			new Map<String,Object>{'Section_Header_gne__c' => 'Information',
				'Details' => new List<Map<String,Object>>{
					new Map<String,Object>{'API_Name_gne__c' => 'Account_gne__c', 'Label_gne__c' => 'Account', 'Is_Read_Only_gne__c' => true},
					new Map<String,Object>{'API_Name_gne__c' => 'Blank Space', 'Type_gne__c' => 'Blank Space'},
					new Map<String,Object>{'API_Name_gne__c' => 'Membership_Name_gne__c', 'Label_gne__c' => 'Membership Name'},
					new Map<String,Object>{'API_Name_gne__c' => 'Other_gne__c', 'Label_gne__c' => 'Other'},
					new Map<String,Object>{'API_Name_gne__c' => 'Year_gne__c', 'Label_gne__c' => 'Year'}
				}
			}
		};

		SFA2_Configuration_Object_gne__c coTemplate = new SFA2_Configuration_Object_gne__c(
			Name = sObjName + '_detail',
			Application_Type__c = 'SFA-US',
			Configuration_Type_gne__c = 'Page',
			Is_Active_gne__c = true,
			Is_Default_Record_Type_gne__c = true,
			Object_Name_gne__c = sObjName,
			OTR2_gne__c = false,
			RT_Available_On_Create_gne__c = false
		);

		SFA2_Configuration_Object_Detail_gne__c codTemplate = new SFA2_Configuration_Object_Detail_gne__c(
			Type_gne__c = 'Field',
			Availability_Mode_gne__c = 'Edit;New;View',
			Is_Active_gne__c = true,
			Is_Read_Only_gne__c = false,
			Is_Required_gne__c = false,
			OTR2_gne__c = false
		);

		Map<String,SFA2_Configuration_Object_gne__c> cosToInsert = insertCos(coTemplate, sectionsData, brandNames, roleNames, recordTypes);
		List<SFA2_Configuration_Object_Detail_gne__c> codsToInsert = insertCods(codTemplate, sectionsData, brandNames, roleNames, recordTypes, cosToInsert);
	}

	private static Map<String,SFA2_Configuration_Object_gne__c> insertCos(SFA2_Configuration_Object_gne__c coTemplate,
			List<Map<String,Object>> sectionsData, Set<String> brandNames, Set<String> roleNames, Set<String> recordTypes) {
		Map<String,SFA2_Configuration_Object_gne__c> result = new Map<String,SFA2_Configuration_Object_gne__c>();
		for(String brandName : brandNames) {
			for(String roleName : roleNames) {
				for(String recType : recordTypes) {
					Integer idx = 0;
					for(Map<String,Object> sectionData : sectionsData) {
						SFA2_Configuration_Object_gne__c co = coTemplate.clone();
						co.Brand_gne__c = brandName;
						co.Record_Type_gne__c = recType;
						co.Role_gne__c = roleName;
						co.Order_gne__c = idx;

						for(String sectionPoperty : sectionData.keySet()) {
							if(sectionPoperty.endsWith('__c') || sectionPoperty == 'Name') {
								co.put(sectionPoperty, sectionData.get(sectionPoperty));
							}
						}

						result.put(brandName + '_' + roleName + '_' + recType + '_' + idx,co);
						idx++;
					}
				}
			}
		}

		insert result.values();
		return result;
	}

	private static List<SFA2_Configuration_Object_Detail_gne__c> insertCods(SFA2_Configuration_Object_Detail_gne__c codTemplate,
			List<Map<String,Object>> sectionsData, Set<String> brandNames, Set<String> roleNames, Set<String> recordTypes, Map<String,SFA2_Configuration_Object_gne__c> cosToInsert) {
		List<SFA2_Configuration_Object_Detail_gne__c> result = new List<SFA2_Configuration_Object_Detail_gne__c>();
		for(String brandName : brandNames) {
			for(String roleName : roleNames) {
				for(String recType : recordTypes) {
					Integer idx = 0;
					for(Map<String,Object> sectionData : sectionsData) {
						SFA2_Configuration_Object_gne__c co = cosToInsert.get(brandName + '_' + roleName + '_' + recType + '_' + idx++);

						if(sectionData.containsKey('Details')) {
							List<Map<String,Object>> detailsData = (List<Map<String,Object>>)sectionData.get('Details');

							Integer detailOrderIdx = 0;
							for(Map<String,Object> detailData : detailsData) {
								SFA2_Configuration_Object_Detail_gne__c cod = codTemplate.clone();
								cod.Configuration_Object_ref_gne__c = co.Id;
								cod.Order_gne__c = detailOrderIdx++;

								for(String detailPoperty : detailData.keySet()) {
									if(detailPoperty.endsWith('__c') || detailPoperty == 'Name') {
										cod.put(detailPoperty, detailData.get(detailPoperty));
									}
								}

								if(cod.Name==null) {
									cod.Name = (String)detailData.get('API_Name_gne__c');
								}

								result.add(cod);
							}
						}
					}
				}
			}
		}

		insert result;
		return result;
	}

	public static User getCurrentUser() {
		return currentUser;
	}

	public class UserHelper {
		private Map<String,User> userCache;
		private Map<Id,Id> userToTerritoryIdCache;

		public UserHelper() {
			userCache = new Map<String,User>();
			userToTerritoryIdCache = new Map<Id,Id>();
			Set<Id> prepUsersInTerrs = new Set<Id>();

			for(UserTerritory2Association ut : [SELECT UserId FROM UserTerritory2Association WHERE UserId IN (SELECT Id FROM User WHERE Profile.Name like 'GNE-FIELD')]) {
				prepUsersInTerrs.add(ut.UserId);
			}

			for(Profile p : [SELECT Name,
                            (SELECT Id, Name, Alias, Profile.Name FROM Users WHERE IsActive = true AND (Id IN :prepUsersInTerrs OR Profile.Name IN ('GNE-SYS-AutomatedJob')) LIMIT 1)
                         FROM Profile
                         WHERE Name like 'GNE-Field' OR Name = 'GNE-SYS-AutomatedJob']) {
            	if(p.Name == 'GNE-SYS-AutomatedJob') {
                    System.debug(' userCache put usOwner');
            		userCache.put('usOwner', p.Users[0]);
            	} else if(!p.Users.isEmpty()) {
                    System.debug(' userCache put '+p.Name);
            		userCache.put(p.Name, p.Users[0]);
            	}
            }

            for(UserTerritory2Association ut : [SELECT UserId, Territory2Id FROM UserTerritory2Association WHERE UserId IN :userCache.values()]) {
            	userToTerritoryIdCache.put(ut.UserId, ut.Territory2Id);
            }

            insertSalesRostersAndAppContext();
            insertUserPreferences();
        }

        public User getUser() {
        	return getUser('GNE-Field');
        }

        public User getUser(String role) {
        	return userCache.get(role);
        }

        private void insertSalesRostersAndAppContext() {
        	IC_Calc_Sales_Roster_gne__c noBrandSR = new IC_Calc_Sales_Roster_gne__c(Brand_Name_gne__c = null, Salesforce_gne__c = null, Type_gne__c = 'SFA-US');
        	insert noBrandSR;
        	List<SFA2_User_Sales_Roster_gne__c> uSRstoInsert = new List<SFA2_User_Sales_Roster_gne__c>();
        	List<GNE_SFA2_User_App_Context_gne__c> appContextsToInsert = new List<GNE_SFA2_User_App_Context_gne__c>();

        	for(String role : userCache.keySet()) {
                System.debug('user role >> '+role);
        		User u = userCache.get(role);
                System.debug(' user by role '+u);
        		String srRole = 'PREP-' + role;
        		if(role=='GNE-FIELD') {
        			srRole = 'PREP-PS';
        		} else if(role=='usOwner') {
        			continue;
        		}

				SFA2_User_Sales_Roster_gne__c uSR = new SFA2_User_Sales_Roster_gne__c(
					Sales_Roster_gne__c = noBrandSR.Id,
					Role_gne__c = srRole,
					User_gne__c = u.Id
				);
				uSRstoInsert.add(uSR);

				GNE_SFA2_User_App_Context_gne__c appContext = new GNE_SFA2_User_App_Context_gne__c(
					SetupOwnerId = u.Id,
					App_Name_gne__c = 'SFA-US',
					Brand_gne__c = null,
					Role_gne__c = srRole,
					Run_in_SFA2_UI_gne__c = true,
					SFA2_Mode_gne__c = true
				);

				appContextsToInsert.add(appContext);
			}

			insert uSRstoInsert;
			insert appContextsToInsert;
        }

        private void insertUserPreferences() {
        	List<SFA2_User_Preferences_gne__c> prefs = new List<SFA2_User_Preferences_gne__c>();

        	for(User u : userCache.values()) {
        		prefs.add(new SFA2_User_Preferences_gne__c(User_gne__c = u.Id));
        	}

        	insert prefs;
        }
	}

	public class AccountHelper {
        private final String US_CODE = 'US';

        public Map<Id,Account> accountsCache;
        public Map<String,Set<Id>> accountsByTypeCache;
        public Map<Id,Address_vod__c> addressCache;

        private Map<String,Id> accRecTypesCache;
    	private Map<String,Id> addrRecTypesCache;


        public void insertAccountsWithAddresses(Integer numberOfAccts) {
        	cacheRecordTypes();
            GNE_SFA2_Account_Trigger_Helper.setAccountTrig(true);
            GNE_SFA2_Address_Trigger_Helper.setAddressTrig(true);

            List<Account> accountsToInsert = new List<Account>();
            List<Address_vod__c> addressesToInsert = new List<Address_vod__c>();

            String hcpFirstName = 'JOHN', hcpLastName = 'SMITH', hcoName = 'MEDICAL CENTER';
            String addressName = 'TEST STREET', addressLine2 = 'STE', city = 'SAN FRANCISCO', state = 'CA', zip = '99999', zip4 = '1111';

            Integer idx = 0;
            for(String mode : new String[]{'US_HCP','US_HCO'}) {
                Id recTypeId = accRecTypesCache.get(mode);

                for(Integer i = 0; i < numberOfAccts; i++) {
                    idx++;
                    Account acc = new Account(
                        RecordTypeId = recTypeId,
                        OwnerId = usOwner.Id);

                    if(mode.endsWith('HCP')) {
                        acc.FirstName = hcpFirstName + idx;
                        acc.LastName = hcpLastName + idx;
                        acc.PREP_Professional_Type_gne__c = 'Other';
                    } else {
                        acc.Name = hcoName;
                    }

                    accountsToInsert.add(acc);
                }
            }

            insert accountsToInsert;

            idx = 0;
            for(Account acc : accountsToInsert) {
                idx++;
                Id recTypeId = addrRecTypesCache.get(getAccountType(acc));

                Address_vod__c addr = new Address_vod__c(
                    RecordTypeId = recTypeId,
                    Account_vod__c = acc.Id,
                    Name = addressName + ' ' + idx,
                    Address_Line_2_vod__c = addressLine2 + ' ' + idx,
                    Primary_vod__c = true,
                    City_vod__c = city,
                    State_vod__c = state,
                    Zip_vod__c = zip,
                    Zip_4_vod__c = zip4);
                addressesToInsert.add(addr);
            }

            insert addressesToInsert;

            cacheAccounts(new Map<Id,Account>(accountsToInsert).keySet());

            GNE_SFA2_Account_Trigger_Helper.setAccountTrig(false);
            GNE_SFA2_Address_Trigger_Helper.setAddressTrig(false);
        }

        public void cacheAccounts(Set<Id> accIds) {
            List<Account> accs = [
                SELECT Id, Name, OwnerId, FirstName, LastName, IsPersonAccount, RecordTypeId, RecordType.Name, PREP_Professional_Type_gne__c,
                    (SELECT Id, Primary_vod__c, Account_vod__c, Name, Address_Line_2_vod__c, City_vod__c, State_vod__c, Zip_vod__c, Zip_4_vod__c, Province_can_gne__c, Postal_Code_can_gne__c
                     FROM Address_vod__r)
                FROM Account
                WHERE Id IN :accIds
            ];

            for(Account acc : accs) {
                cacheAccount(acc);

                for(Address_vod__c addr : acc.Address_vod__r) {
                    cacheAddress(addr);
                }
            }
        }

        public void cacheAccount(Account acc) {
            if(accountsCache==null) {
                accountsCache = new Map<Id,Account>();
                accountsByTypeCache = new Map<String,Set<Id>>{
                    'US_HCP' => new Set<Id>(),
                    'US_HCO' => new Set<Id>()
                };
            }

            accountsCache.put(acc.Id, acc);
            String accType = getAccountType(acc);
            accountsByTypeCache.get(accType).add(acc.Id);
        }

        public void cacheAddress(Address_vod__c addr) {
            if(addressCache==null) {
                addressCache = new Map<Id,Address_vod__c>();
            }

            addressCache.put(addr.Id, addr);
        }

        private void cacheRecordTypes() {
	        accRecTypesCache = new Map<String,Id>();
	        List<Schema.RecordTypeInfo> rtInfos = Account.getSobjectType().getDescribe().getRecordTypeInfos();

	        for(Schema.RecordTypeInfo rtInfo : rtInfos) {
	            Id rtId = rtInfo.getRecordTypeId();
	            String rtName = rtInfo.getName();
	            if(rtName == US_HCP_RECORD_TYPE_NAME) {
	                accRecTypesCache.put('US_HCP', rtId);
	            } else if(rtName == US_HCO_RECORD_TYPE_NAME) {
	                accRecTypesCache.put('US_HCO', rtId);
	            }
	        }

	        addrRecTypesCache = new Map<String,Id>();
	        rtInfos = Address_vod__c.getSobjectType().getDescribe().getRecordTypeInfos();

	        for(Schema.RecordTypeInfo rtInfo : rtInfos) {
	            Id rtId = rtInfo.getRecordTypeId();
	            String rtName = rtInfo.getName();
	            if(rtName == US_ADDRESS_RECORD_TYPE_NAME) {
	                addrRecTypesCache.put('US_HCP', rtId);
	                addrRecTypesCache.put('US_HCO', rtId);
	            }
	        }
	    }

        private String getAccountType(Account acc) {
            String region = US_CODE;
            String accMode = acc.RecordTypeId == accRecTypesCache.get(region + '_HCP') ? 'HCP' : 'HCO';
            return region + '_' + accMode;
        }

        private void createAccountShares(User u) {
            System.debug('u.Id +++ '+u.Id);
        	Id terrId = userHelper.userToTerritoryIdCache.get(u.Id);
        	List<ObjectTerritory2Association> territoryAssociations = new List<ObjectTerritory2Association>();

        	for(Account acc : accountsCache.values()) {
    			ObjectTerritory2Association territoryAssociation = new ObjectTerritory2Association(ObjectId = acc.Id, Territory2Id = terrId, AssociationCause='Territory2Manual');
				territoryAssociations.add(territoryAssociation);
    		}

        	insert territoryAssociations;
        }
    }
}