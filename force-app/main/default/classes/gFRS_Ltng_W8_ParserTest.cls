@isTest
private class gFRS_Ltng_W8_ParserTest {

    @isTest static void testParse() {
		String json = '{'+
		'  \"name\": \"Electronic_Payment_Form 1.pdf\",'+
		'  \"forms\": ['+
		'    {'+
		'      \"tables_data\": [],'+
		'      \"name\": \"electronic_payment_form\",'+
		'      \"template_id\": 27429,'+
		'      \"unstructured_data\": [],'+
		'      \"id\": 11284253,'+
		'      \"data\": ['+
		'        {'+
		'          \"confidence\": 0.975,'+
		'          \"uuid\": \"2812497f-9152-450c-9410-47f494b5c2a4\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127506,'+
		'          \"field_id\": 8701765,'+
		'          \"value\": \"john smith\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474379,'+
		'          \"field_name\": \"payee_name\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.5245,'+
		'          \"uuid\": \"6fe4d1bd-9726-43d7-a669-2cf303c68108\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127507,'+
		'          \"field_id\": 8701766,'+
		'          \"value\": \"5125677364\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474378,'+
		'          \"field_name\": \"payee_ein_ssn\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.7727,'+
		'          \"uuid\": \"4ae2ae1a-bfe5-4d16-ae1a-0cbb45ba570e\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127508,'+
		'          \"field_id\": 8701767,'+
		'          \"value\": \"5104458394\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474377,'+
		'          \"field_name\": \"payee_phone\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9549,'+
		'          \"uuid\": \"84255f9b-bfbc-4246-9d3e-6f61ddd501c0\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127509,'+
		'          \"field_id\": 8701768,'+
		'          \"value\": \"johnsmith@gmail.com\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474376,'+
		'          \"field_name\": \"payee_email\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9777,'+
		'          \"uuid\": \"af8803e7-6b27-463b-9d19-7003107050e8\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127511,'+
		'          \"field_id\": 8701769,'+
		'          \"value\": \"053902197\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474372,'+
		'          \"field_name\": \"bank_rounting_sort_code\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9688,'+
		'          \"uuid\": \"55aaf702-8866-453f-8627-df940c581310\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127512,'+
		'          \"field_id\": 8701770,'+
		'          \"value\": \"0047362839405\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474373,'+
		'          \"field_name\": \"bank_account_no\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9682,'+
		'          \"uuid\": \"0834e082-97e0-46b3-865b-f423ecacea8d\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127513,'+
		'          \"field_id\": 8701771,'+
		'          \"value\": \"2347837468373\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474374,'+
		'          \"field_name\": \"bank_swift_code\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9977,'+
		'          \"uuid\": \"809b928e-c135-4711-b984-b270761033db\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127514,'+
		'          \"field_id\": 8701772,'+
		'          \"value\": \"--blank--\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474375,'+
		'          \"field_name\": \"bank_iban\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9977,'+
		'          \"uuid\": \"72eb5272-caa6-482c-a564-49eb0e8e8b29\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127515,'+
		'          \"field_id\": 8701773,'+
		'          \"value\": \"--blank--\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474371,'+
		'          \"field_name\": \"bank_canada_branch_id\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9731,'+
		'          \"uuid\": \"cb36fa29-2b17-4391-9c28-bab60a922a73\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127516,'+
		'          \"field_id\": 8701774,'+
		'          \"value\": \"wells fargo\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474370,'+
		'          \"field_name\": \"bank_name\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9753,'+
		'          \"uuid\": \"0dc231f7-dd90-4d1e-b69b-830bbf3d3338\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127517,'+
		'          \"field_id\": 8701775,'+
		'          \"value\": \"california\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474369,'+
		'          \"field_name\": \"bank_branch_name\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.8308,'+
		'          \"uuid\": \"3ccef451-016d-4ac1-88ac-400ac27f4070\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127518,'+
		'          \"field_id\": 8701776,'+
		'          \"value\": \"p.o. box 51193, los angeles\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474368,'+
		'          \"field_name\": \"bank_street_address\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9731,'+
		'          \"uuid\": \"97e97906-3d7f-44df-a33c-37b63adf294c\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127519,'+
		'          \"field_id\": 8701777,'+
		'          \"value\": \"los angeles\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474367,'+
		'          \"field_name\": \"bank_city\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9752,'+
		'          \"uuid\": \"d858872f-5f9b-4c74-b0e7-a6d8cfbc1586\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127520,'+
		'          \"field_id\": 8701778,'+
		'          \"value\": \"john smith\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474366,'+
		'          \"field_name\": \"bank_account_holder_name\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9684,'+
		'          \"uuid\": \"e9b7e752-7f9f-4d8c-b948-c03dc532bee5\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127549,'+
		'          \"field_id\": 8701779,'+
		'          \"value\": \"united states\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474365,'+
		'          \"field_name\": \"bank_country\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9987,'+
		'          \"uuid\": \"0fe65ab1-82b3-49fe-a89e-d502a6ac0467\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127555,'+
		'          \"field_id\": 8701780,'+
		'          \"value\": \"No\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474364,'+
		'          \"field_name\": \"intermediary_bank_check\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9464,'+
		'          \"uuid\": \"28119251-71ce-4a4e-a886-7a4a6a981ad0\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127521,'+
		'          \"field_id\": 8701781,'+
		'          \"value\": \"fol\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474362,'+
		'          \"field_name\": \"intermediary_bank_name\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9977,'+
		'          \"uuid\": \"95ed597b-5088-4d95-bebf-549917212610\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127522,'+
		'          \"field_id\": 8701782,'+
		'          \"value\": \"--blank--\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474363,'+
		'          \"field_name\": \"intermediary_bank_country\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9977,'+
		'          \"uuid\": \"dab4d058-98a5-4a3e-914f-fa2a2aed3f2c\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127523,'+
		'          \"field_id\": 8701783,'+
		'          \"value\": \"--blank--\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474361,'+
		'          \"field_name\": \"intermediary_bank_account_no\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9977,'+
		'          \"uuid\": \"27603333-8a77-48e7-be47-39e7d9ac8431\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127524,'+
		'          \"field_id\": 8701784,'+
		'          \"value\": \"--blank--\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474360,'+
		'          \"field_name\": \"intermediary_bank_swift_code\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9977,'+
		'          \"uuid\": \"c6e50984-7dc4-4085-bd26-b1e181bdd0e0\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127525,'+
		'          \"field_id\": 8701785,'+
		'          \"value\": \"--blank--\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474359,'+
		'          \"field_name\": \"intermediary_bank_routing_id\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.975,'+
		'          \"uuid\": \"a921cfa6-98ae-469c-b840-9d619566726e\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127526,'+
		'          \"field_id\": 8701786,'+
		'          \"value\": \"john smith\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474358,'+
		'          \"field_name\": \"approver_name_title\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9938,'+
		'          \"uuid\": \"2a498c6c-48dd-428a-804e-42c345f241f5\",'+
		'          \"data_type\": \"Signature\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127550,'+
		'          \"field_id\": 8701787,'+
		'          \"value\": \"--blank--\",'+
		'          \"finalization_criteria_used\": \"any_ml\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474357,'+
		'          \"field_name\": \"approver_signature\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9977,'+
		'          \"uuid\": \"3dc61ca5-0da1-460b-abc7-03392fd127c0\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127527,'+
		'          \"field_id\": 8701788,'+
		'          \"value\": \"--blank--\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474356,'+
		'          \"field_name\": \"signed_date\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.578,'+
		'          \"uuid\": \"b9e1164e-2eeb-4cbc-8517-c4b5da72e455\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127553,'+
		'          \"field_id\": 8701863,'+
		'          \"value\": \"Checking\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474355,'+
		'          \"field_name\": \"account_type_check\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9901,'+
		'          \"uuid\": \"c217c3bd-bf9e-49b3-8da1-247625358da0\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127554,'+
		'          \"field_id\": 8701864,'+
		'          \"value\": \"ACH/EFT\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474354,'+
		'          \"field_name\": \"payment_type_check\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.6014,'+
		'          \"uuid\": \"fbd7c581-fa1d-487f-bcf6-a0f2be5b9cff\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127510,'+
		'          \"field_id\": 8701865,'+
		'          \"value\": \"usd - us dollar\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474353,'+
		'          \"field_name\": \"payement_currency\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        }'+
		'      ],'+
		'      \"pages\": ['+
		'        {'+
		'          \"form_id\": 11284253,'+
		'          \"template_name\": \"electronic_payment_form\",'+
		'          \"batch_file_id\": 266474775,'+
		'          \"sheet_name\": \"epf_p1_rev_12_sep_2018\",'+
		'          \"instance_id\": 77478152,'+
		'          \"page_name\": \"Electronic_Payment_Form 1-page1.png\",'+
		'          \"batch_page_id\": null,'+
		'          \"sheet_id\": 604283,'+
		'          \"page_id\": 51002743,'+
		'          \"order\": 1'+
		'        }'+
		'      ]'+
		'    },'+
		'    {'+
		'      \"tables_data\": [],'+
		'      \"name\": \"\",'+
		'      \"template_id\": null,'+
		'      \"unstructured_data\": [],'+
		'      \"id\": 11284133,'+
		'      \"data\": [],'+
		'      \"pages\": []'+
		'    }'+
		'  ],'+
		'  \"workflow_id\": 291,'+
		'  \"batch_id\": 10714965,'+
		'  \"id\": 6750305,'+
		'  \"metadata\": {'+
		'    \"batch_file_metadata\": ['+
		'      {'+
		'        \"batch_file_id\": 266474775,'+
		'        \"metadata\": {}'+
		'      }'+
		'    ]'+
		'  }'+
		'}';
		gFRS_Ltng_W8_Parser obj = gFRS_Ltng_W8_Parser.parse(json);
		System.assert(obj != null);
	}

    
     @isTest static void testParse2() {
		String json = '{'+
		'  \"name\": \"Electronic_Payment_Form 1.pdf\",'+
		'  \"forms\": ['+
		'    {'+
		'      \"tables_data\": [],'+
		'      \"name\": \"electronic_payment_form\",'+
		'      \"template_id\": 27429,'+
		'      \"unstructured_data\": [],'+
		'      \"id\": 11284253,'+
		'      \"data\": ['+
		'        {'+
		'          \"confidence\": 0.975,'+
		'          \"uuid\": \"2812497f-9152-450c-9410-47f494b5c2a4\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127506,'+
		'          \"field_id\": 8701765,'+
		'          \"value\": \"john smith\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474379,'+
		'          \"field_name\": \"payee_name\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.5245,'+
		'          \"uuid\": \"6fe4d1bd-9726-43d7-a669-2cf303c68108\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127507,'+
		'          \"field_id\": 8701766,'+
		'          \"value\": \"5125677364\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474378,'+
		'          \"field_name\": \"payee_ein_ssn\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.7727,'+
		'          \"uuid\": \"4ae2ae1a-bfe5-4d16-ae1a-0cbb45ba570e\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127508,'+
		'          \"field_id\": 8701767,'+
		'          \"value\": \"5104458394\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474377,'+
		'          \"field_name\": \"payee_phone\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9549,'+
		'          \"uuid\": \"84255f9b-bfbc-4246-9d3e-6f61ddd501c0\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127509,'+
		'          \"field_id\": 8701768,'+
		'          \"value\": \"johnsmith@gmail.com\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474376,'+
		'          \"field_name\": \"payee_email\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9777,'+
		'          \"uuid\": \"af8803e7-6b27-463b-9d19-7003107050e8\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127511,'+
		'          \"field_id\": 8701769,'+
		'          \"value\": \"053902197\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474372,'+
		'          \"field_name\": \"bank_rounting_sort_code\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9688,'+
		'          \"uuid\": \"55aaf702-8866-453f-8627-df940c581310\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127512,'+
		'          \"field_id\": 8701770,'+
		'          \"value\": \"0047362839405\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474373,'+
		'          \"field_name\": \"bank_account_no\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9682,'+
		'          \"uuid\": \"0834e082-97e0-46b3-865b-f423ecacea8d\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127513,'+
		'          \"field_id\": 8701771,'+
		'          \"value\": \"2347837468373\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474374,'+
		'          \"field_name\": \"bank_swift_code\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9977,'+
		'          \"uuid\": \"809b928e-c135-4711-b984-b270761033db\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127514,'+
		'          \"field_id\": 8701772,'+
		'          \"value\": \"--blank--\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474375,'+
		'          \"field_name\": \"bank_iban\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9977,'+
		'          \"uuid\": \"72eb5272-caa6-482c-a564-49eb0e8e8b29\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127515,'+
		'          \"field_id\": 8701773,'+
		'          \"value\": \"--blank--\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474371,'+
		'          \"field_name\": \"bank_canada_branch_id\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9731,'+
		'          \"uuid\": \"cb36fa29-2b17-4391-9c28-bab60a922a73\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127516,'+
		'          \"field_id\": 8701774,'+
		'          \"value\": \"wells fargo\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474370,'+
		'          \"field_name\": \"bank_name\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9753,'+
		'          \"uuid\": \"0dc231f7-dd90-4d1e-b69b-830bbf3d3338\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127517,'+
		'          \"field_id\": 8701775,'+
		'          \"value\": \"california\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474369,'+
		'          \"field_name\": \"bank_branch_name\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.8308,'+
		'          \"uuid\": \"3ccef451-016d-4ac1-88ac-400ac27f4070\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127518,'+
		'          \"field_id\": 8701776,'+
		'          \"value\": \"p.o. box 51193, los angeles\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474368,'+
		'          \"field_name\": \"bank_street_address\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9731,'+
		'          \"uuid\": \"97e97906-3d7f-44df-a33c-37b63adf294c\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127519,'+
		'          \"field_id\": 8701777,'+
		'          \"value\": \"los angeles\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474367,'+
		'          \"field_name\": \"bank_city\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9752,'+
		'          \"uuid\": \"d858872f-5f9b-4c74-b0e7-a6d8cfbc1586\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127520,'+
		'          \"field_id\": 8701778,'+
		'          \"value\": \"john smith\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474366,'+
		'          \"field_name\": \"bank_account_holder_name\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9684,'+
		'          \"uuid\": \"e9b7e752-7f9f-4d8c-b948-c03dc532bee5\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127549,'+
		'          \"field_id\": 8701779,'+
		'          \"value\": \"united states\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474365,'+
		'          \"field_name\": \"bank_country\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9987,'+
		'          \"uuid\": \"0fe65ab1-82b3-49fe-a89e-d502a6ac0467\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127555,'+
		'          \"field_id\": 8701780,'+
		'          \"value\": \"No\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474364,'+
		'          \"field_name\": \"intermediary_bank_check\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9464,'+
		'          \"uuid\": \"28119251-71ce-4a4e-a886-7a4a6a981ad0\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127521,'+
		'          \"field_id\": 8701781,'+
		'          \"value\": \"fol\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474362,'+
		'          \"field_name\": \"intermediary_bank_name\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9977,'+
		'          \"uuid\": \"95ed597b-5088-4d95-bebf-549917212610\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127522,'+
		'          \"field_id\": 8701782,'+
		'          \"value\": \"--blank--\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474363,'+
		'          \"field_name\": \"intermediary_bank_country\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9977,'+
		'          \"uuid\": \"dab4d058-98a5-4a3e-914f-fa2a2aed3f2c\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127523,'+
		'          \"field_id\": 8701783,'+
		'          \"value\": \"--blank--\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474361,'+
		'          \"field_name\": \"intermediary_bank_account_no\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9977,'+
		'          \"uuid\": \"27603333-8a77-48e7-be47-39e7d9ac8431\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127524,'+
		'          \"field_id\": 8701784,'+
		'          \"value\": \"--blank--\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474360,'+
		'          \"field_name\": \"intermediary_bank_swift_code\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9977,'+
		'          \"uuid\": \"c6e50984-7dc4-4085-bd26-b1e181bdd0e0\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127525,'+
		'          \"field_id\": 8701785,'+
		'          \"value\": \"--blank--\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474359,'+
		'          \"field_name\": \"intermediary_bank_routing_id\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.975,'+
		'          \"uuid\": \"a921cfa6-98ae-469c-b840-9d619566726e\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127526,'+
		'          \"field_id\": 8701786,'+
		'          \"value\": \"john smith\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474358,'+
		'          \"field_name\": \"approver_name_title\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9938,'+
		'          \"uuid\": \"2a498c6c-48dd-428a-804e-42c345f241f5\",'+
		'          \"data_type\": \"Signature\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127550,'+
		'          \"field_id\": 8701787,'+
		'          \"value\": \"--blank--\",'+
		'          \"finalization_criteria_used\": \"any_ml\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474357,'+
		'          \"field_name\": \"approver_signature\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9977,'+
		'          \"uuid\": \"3dc61ca5-0da1-460b-abc7-03392fd127c0\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127527,'+
		'          \"field_id\": 8701788,'+
		'          \"value\": \"--blank--\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474356,'+
		'          \"field_name\": \"signed_date\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.578,'+
		'          \"uuid\": \"b9e1164e-2eeb-4cbc-8517-c4b5da72e455\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127553,'+
		'          \"field_id\": 8701863,'+
		'          \"value\": \"Checking\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474355,'+
		'          \"field_name\": \"account_type_check\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9901,'+
		'          \"uuid\": \"c217c3bd-bf9e-49b3-8da1-247625358da0\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127554,'+
		'          \"field_id\": 8701864,'+
		'          \"value\": \"ACH/EFT\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474354,'+
		'          \"field_name\": \"payment_type_check\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.6014,'+
		'          \"uuid\": \"fbd7c581-fa1d-487f-bcf6-a0f2be5b9cff\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127510,'+
		'          \"field_id\": 8701865,'+
		'          \"value\": \"usd - us dollar\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474353,'+
		'          \"field_name\": \"payement_currency\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        }'+
		'      ],'+
		'      \"pages\": ['+
		'        {'+
		'          \"form_id\": 11284253,'+
		'          \"template_name\": \"electronic_payment_form\",'+
		'          \"batch_file_id\": 266474775,'+
		'          \"sheet_name\": \"epf_p1_rev_12_sep_2018\",'+
		'          \"instance_id\": 77478152,'+
		'          \"page_name\": \"Electronic_Payment_Form 1-page1.png\",'+
		'          \"batch_page_id\": null,'+
		'          \"sheet_id\": 604283,'+
		'          \"page_id\": 51002743,'+
		'          \"order\": 1'+
		'        }'+
		'      ]'+
		'    },'+
		'    {'+
		'      \"tables_data\": [],'+
		'      \"name\": \"\",'+
		'      \"template_id\": null,'+
		'      \"unstructured_data\": [],'+
		'      \"id\": 11284133,'+
		'      \"data\": [],'+
		'      \"pages\": []'+
		'    }'+
		'  ],'+
		'  \"workflow_id\": 291,'+
		'  \"batch_id\": 10714965,'+
		'  \"id\": 6750305,'+
		'  \"metadata\": {'+
		'    \"batch_file_metadata\": ['+
		'      {'+
		'        \"batch_file_id\": 266474775,'+
		'        \"metadata\": {}'+
		'      }'+
		'    ]'+
		'  }'+
		'}';
		gFRS_Ltng_W9_Parser obj = gFRS_Ltng_W9_Parser.parse(json);
		System.assert(obj != null);
	}
    
     @isTest static void testParse3() {
		String json = '{'+
		'  \"name\": \"Electronic_Payment_Form 1.pdf\",'+
		'  \"forms\": ['+
		'    {'+
		'      \"tables_data\": [],'+
		'      \"name\": \"electronic_payment_form\",'+
		'      \"template_id\": 27429,'+
		'      \"unstructured_data\": [],'+
		'      \"id\": 11284253,'+
		'      \"data\": ['+
		'        {'+
		'          \"confidence\": 0.975,'+
		'          \"uuid\": \"2812497f-9152-450c-9410-47f494b5c2a4\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127506,'+
		'          \"field_id\": 8701765,'+
		'          \"value\": \"john smith\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474379,'+
		'          \"field_name\": \"payee_name\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.5245,'+
		'          \"uuid\": \"6fe4d1bd-9726-43d7-a669-2cf303c68108\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127507,'+
		'          \"field_id\": 8701766,'+
		'          \"value\": \"5125677364\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474378,'+
		'          \"field_name\": \"payee_ein_ssn\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.7727,'+
		'          \"uuid\": \"4ae2ae1a-bfe5-4d16-ae1a-0cbb45ba570e\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127508,'+
		'          \"field_id\": 8701767,'+
		'          \"value\": \"5104458394\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474377,'+
		'          \"field_name\": \"payee_phone\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9549,'+
		'          \"uuid\": \"84255f9b-bfbc-4246-9d3e-6f61ddd501c0\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127509,'+
		'          \"field_id\": 8701768,'+
		'          \"value\": \"johnsmith@gmail.com\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474376,'+
		'          \"field_name\": \"payee_email\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9777,'+
		'          \"uuid\": \"af8803e7-6b27-463b-9d19-7003107050e8\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127511,'+
		'          \"field_id\": 8701769,'+
		'          \"value\": \"053902197\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474372,'+
		'          \"field_name\": \"bank_rounting_sort_code\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9688,'+
		'          \"uuid\": \"55aaf702-8866-453f-8627-df940c581310\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127512,'+
		'          \"field_id\": 8701770,'+
		'          \"value\": \"0047362839405\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474373,'+
		'          \"field_name\": \"bank_account_no\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9682,'+
		'          \"uuid\": \"0834e082-97e0-46b3-865b-f423ecacea8d\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127513,'+
		'          \"field_id\": 8701771,'+
		'          \"value\": \"2347837468373\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474374,'+
		'          \"field_name\": \"bank_swift_code\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9977,'+
		'          \"uuid\": \"809b928e-c135-4711-b984-b270761033db\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127514,'+
		'          \"field_id\": 8701772,'+
		'          \"value\": \"--blank--\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474375,'+
		'          \"field_name\": \"bank_iban\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9977,'+
		'          \"uuid\": \"72eb5272-caa6-482c-a564-49eb0e8e8b29\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127515,'+
		'          \"field_id\": 8701773,'+
		'          \"value\": \"--blank--\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474371,'+
		'          \"field_name\": \"bank_canada_branch_id\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9731,'+
		'          \"uuid\": \"cb36fa29-2b17-4391-9c28-bab60a922a73\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127516,'+
		'          \"field_id\": 8701774,'+
		'          \"value\": \"wells fargo\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474370,'+
		'          \"field_name\": \"bank_name\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9753,'+
		'          \"uuid\": \"0dc231f7-dd90-4d1e-b69b-830bbf3d3338\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127517,'+
		'          \"field_id\": 8701775,'+
		'          \"value\": \"california\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474369,'+
		'          \"field_name\": \"bank_branch_name\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.8308,'+
		'          \"uuid\": \"3ccef451-016d-4ac1-88ac-400ac27f4070\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127518,'+
		'          \"field_id\": 8701776,'+
		'          \"value\": \"p.o. box 51193, los angeles\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474368,'+
		'          \"field_name\": \"bank_street_address\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9731,'+
		'          \"uuid\": \"97e97906-3d7f-44df-a33c-37b63adf294c\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127519,'+
		'          \"field_id\": 8701777,'+
		'          \"value\": \"los angeles\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474367,'+
		'          \"field_name\": \"bank_city\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9752,'+
		'          \"uuid\": \"d858872f-5f9b-4c74-b0e7-a6d8cfbc1586\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127520,'+
		'          \"field_id\": 8701778,'+
		'          \"value\": \"john smith\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474366,'+
		'          \"field_name\": \"bank_account_holder_name\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9684,'+
		'          \"uuid\": \"e9b7e752-7f9f-4d8c-b948-c03dc532bee5\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127549,'+
		'          \"field_id\": 8701779,'+
		'          \"value\": \"united states\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474365,'+
		'          \"field_name\": \"bank_country\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9987,'+
		'          \"uuid\": \"0fe65ab1-82b3-49fe-a89e-d502a6ac0467\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127555,'+
		'          \"field_id\": 8701780,'+
		'          \"value\": \"No\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474364,'+
		'          \"field_name\": \"intermediary_bank_check\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9464,'+
		'          \"uuid\": \"28119251-71ce-4a4e-a886-7a4a6a981ad0\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127521,'+
		'          \"field_id\": 8701781,'+
		'          \"value\": \"fol\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474362,'+
		'          \"field_name\": \"intermediary_bank_name\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9977,'+
		'          \"uuid\": \"95ed597b-5088-4d95-bebf-549917212610\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127522,'+
		'          \"field_id\": 8701782,'+
		'          \"value\": \"--blank--\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474363,'+
		'          \"field_name\": \"intermediary_bank_country\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9977,'+
		'          \"uuid\": \"dab4d058-98a5-4a3e-914f-fa2a2aed3f2c\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127523,'+
		'          \"field_id\": 8701783,'+
		'          \"value\": \"--blank--\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474361,'+
		'          \"field_name\": \"intermediary_bank_account_no\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9977,'+
		'          \"uuid\": \"27603333-8a77-48e7-be47-39e7d9ac8431\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127524,'+
		'          \"field_id\": 8701784,'+
		'          \"value\": \"--blank--\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474360,'+
		'          \"field_name\": \"intermediary_bank_swift_code\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9977,'+
		'          \"uuid\": \"c6e50984-7dc4-4085-bd26-b1e181bdd0e0\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127525,'+
		'          \"field_id\": 8701785,'+
		'          \"value\": \"--blank--\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474359,'+
		'          \"field_name\": \"intermediary_bank_routing_id\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.975,'+
		'          \"uuid\": \"a921cfa6-98ae-469c-b840-9d619566726e\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127526,'+
		'          \"field_id\": 8701786,'+
		'          \"value\": \"john smith\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474358,'+
		'          \"field_name\": \"approver_name_title\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9938,'+
		'          \"uuid\": \"2a498c6c-48dd-428a-804e-42c345f241f5\",'+
		'          \"data_type\": \"Signature\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127550,'+
		'          \"field_id\": 8701787,'+
		'          \"value\": \"--blank--\",'+
		'          \"finalization_criteria_used\": \"any_ml\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474357,'+
		'          \"field_name\": \"approver_signature\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9977,'+
		'          \"uuid\": \"3dc61ca5-0da1-460b-abc7-03392fd127c0\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127527,'+
		'          \"field_id\": 8701788,'+
		'          \"value\": \"--blank--\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474356,'+
		'          \"field_name\": \"signed_date\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.578,'+
		'          \"uuid\": \"b9e1164e-2eeb-4cbc-8517-c4b5da72e455\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127553,'+
		'          \"field_id\": 8701863,'+
		'          \"value\": \"Checking\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474355,'+
		'          \"field_name\": \"account_type_check\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.9901,'+
		'          \"uuid\": \"c217c3bd-bf9e-49b3-8da1-247625358da0\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127554,'+
		'          \"field_id\": 8701864,'+
		'          \"value\": \"ACH/EFT\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474354,'+
		'          \"field_name\": \"payment_type_check\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        },'+
		'        {'+
		'          \"confidence\": 0.6014,'+
		'          \"uuid\": \"fbd7c581-fa1d-487f-bcf6-a0f2be5b9cff\",'+
		'          \"data_type\": \"String\",'+
		'          \"original_value\": null,'+
		'          \"is_active\": true,'+
		'          \"schema_field_id\": 127510,'+
		'          \"field_id\": 8701865,'+
		'          \"value\": \"usd - us dollar\",'+
		'          \"finalization_criteria_used\": \"ml_only\",'+
		'          \"was_edited\": false,'+
		'          \"shred_id\": 1875474353,'+
		'          \"field_name\": \"payement_currency\",'+
		'          \"form_schema_id\": 2018,'+
		'          \"page_id\": 51002743,'+
		'          \"form_id\": 11284253'+
		'        }'+
		'      ],'+
		'      \"pages\": ['+
		'        {'+
		'          \"form_id\": 11284253,'+
		'          \"template_name\": \"electronic_payment_form\",'+
		'          \"batch_file_id\": 266474775,'+
		'          \"sheet_name\": \"epf_p1_rev_12_sep_2018\",'+
		'          \"instance_id\": 77478152,'+
		'          \"page_name\": \"Electronic_Payment_Form 1-page1.png\",'+
		'          \"batch_page_id\": null,'+
		'          \"sheet_id\": 604283,'+
		'          \"page_id\": 51002743,'+
		'          \"order\": 1'+
		'        }'+
		'      ]'+
		'    },'+
		'    {'+
		'      \"tables_data\": [],'+
		'      \"name\": \"\",'+
		'      \"template_id\": null,'+
		'      \"unstructured_data\": [],'+
		'      \"id\": 11284133,'+
		'      \"data\": [],'+
		'      \"pages\": []'+
		'    }'+
		'  ],'+
		'  \"workflow_id\": 291,'+
		'  \"batch_id\": 10714965,'+
		'  \"id\": 6750305,'+
		'  \"metadata\": {'+
		'    \"batch_file_metadata\": ['+
		'      {'+
		'        \"batch_file_id\": 266474775,'+
		'        \"metadata\": {}'+
		'      }'+
		'    ]'+
		'  }'+
		'}';
		gFRS_Ltng_ElePay_Parser obj = gFRS_Ltng_ElePay_Parser.parse(json);
		System.assert(obj != null);
	}

}