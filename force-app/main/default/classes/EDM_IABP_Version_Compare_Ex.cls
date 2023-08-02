public with sharing class EDM_IABP_Version_Compare_Ex {

	public EDM_IABP_gne__c record1 { get; private set; }
	public EDM_IABP_gne__c record2 { get; private set; }
	public List<CompareWrapper> Values { get; private set; }
	public List<CompareWrapper> ValuesAgenda { get; private set; }
	public List<CompareWrapper> ValuesRL { get; private set; }

	public String pageTitle { get; set; }

	public EDM_IABP_Version_Compare_Ex(ApexPages.StandardController controller) {
		try {
			Id record1Id = ApexPages.currentPage().getparameters().get('idOld');
			Id record2Id = ApexPages.currentPage().getparameters().get('idNew');

			ValuesRL = new List<CompareWrapper>();

			record1 = getRecordById(record1Id);
			record2 = getRecordById(record2Id);

			if (!record1.EDM_Executive_Summary_gne__c) {
				pageTitle = 'IABP Comparator';

				Values = populateMainValues();
				ValuesAgenda = (new AgendaComparator(record1, record2)).getAgendaValues();

				ValuesRL.addAll(
						(new RelatedListComparator(
								record1,
								record2,
								'EDM_Question_gne__c',
								new Map<String, String> {
										'EDM_Value_gne__c' => 'Question',
										'EDM_Estimated_Minutes_gne__c' => 'Estimated # of minutes'
								},
								'Agenda (Advisory Board Questions)',
								new DefaultQueryExecutor('EDM_Question_gne__c', 'EDM_Parent_Exe_Summary_gne__c', 'AND EDM_Type_gne__c = \'Advisory Board\'')
						)).getCompareValues()
				);

				ValuesRL.addAll(
						(new RelatedListComparator(
								record1,
								record2,
								'EDM_Objective_gne__c',
								new Map<String, String> {
										'EDM_Group_gne__c' => 'Group',
										'EDM_Number_gne__c' => 'Number',
										'EDM_Description_gne__c' => 'Description',
										'EDM_Projected_Output_gne__c' => 'PTD'
								},
								'Advisory Board Objectives',
								new DefaultQueryExecutor('EDM_Objective_gne__c', 'EDM_Parent_IABP_gne__c', '')
						)).getCompareValues()
				);

				ValuesRL.addAll(
						(new RelatedListComparator(
								record1,
								record2,
								'EDM_Budget_gne__c',
								new Map<String, String> {
										'EDM_Type_gne__c' => 'Type',
										'EDM_Description_gne__c' => 'Description',
										'EDM_Amount_gne__c' => 'Amount'
								},
								'Budget',
								new DefaultQueryExecutor('EDM_Budget_gne__c', 'EDM_Parent_IABP_gne__c', '')
						)).getCompareValues()
				);

				ValuesRL.addAll(
						(new RelatedListComparator(
								record1,
								record2,
								'EDM_Attendee_gne__c',
								new Map<String, String> {
										'EDM_First_Name_gne__c' => 'First Name',
										'EDM_Last_Name_gne__c' => 'Last Name',
										'EDM_Role_gne__c' => 'Title',
										'EDM_Purpose_gne__c' => 'Role/Purpose',
										'EDM_Observer_gne__c' => 'Observer',
										'EDM_Company_gne__c' => 'Company',
										'EDM_Date_Added_Snapshot_gne__c' => 'Date Added',
										'EDM_Date_Added_gne__c' => 'Date Added'
								},
								'Genentech and Co-Promote Attendees',
								new DefaultQueryExecutor('EDM_Attendee_gne__c', 'EDM_Parent_IABP_gne__c', 'AND EDM_System_Type_gne__c = \'Genentech\'')
						)).getCompareValues()
				);

				ValuesRL.addAll(
						(new RelatedListComparator(
								record1,
								record2,
								'EDM_Attendee_gne__c',
								new Map<String, String> {
										'EDM_Account_gne__r.FirstName' => 'First Name',
										'EDM_Account_gne__r.LastName' => 'Last Name',
										'EDM_Role_gne__c' => 'Role',
										'EDM_Clinical_Classification_gne__c' => 'Clinical Classification',
										'EDM_Account_gne__r.Credentials_gne__c' => 'Credentials',
										'EDM_Clinical_Specialties_gne__c' => 'Specialties',
										'EDM_Business_Classification_gne__c' => 'Business Classification',
										'EDM_Business_Classification_Role_gne__c' => 'Business Role',
										'EDM_Exclusion_Status_gne__c' => 'Exclusion Status',
										'EDM_Account_gne__r.AGS_EX_Date_Checked_Exclusion_gne__c' => 'Exclusion Checked Date',
										'EDM_Date_Added_Snapshot_gne__c' => 'Date Added',
										'EDM_Date_Added_gne__c' => 'Date Added'
								},
								'US HCP and Business Leader Advisors',
								new DefaultQueryExecutor('EDM_Attendee_gne__c', 'EDM_Parent_IABP_gne__c', 'AND EDM_System_Type_gne__c = \'Advisor\'')
						)).getCompareValues()
				);

				ValuesRL.addAll(
						(new RelatedListComparator(
								record1,
								record2,
								'EDM_Attendee_gne__c',
								new Map<String, String> {
										'EDM_First_Name_gne__c' => 'First Name',
										'EDM_Last_Name_gne__c' => 'Last Name',
										'EDM_Role_gne__c' => 'Role',
										'EDM_Country_gne__c' => 'Country',
										'EDM_Date_Added_Snapshot_gne__c' => 'Date Added',
										'EDM_Date_Added_gne__c' => 'Date Added'
								},
								'Non-US HCP and Business Leader Advisors',
								new DefaultQueryExecutor('EDM_Attendee_gne__c', 'EDM_Parent_IABP_gne__c', 'AND EDM_System_Type_gne__c = \'NonUSAdvisor\'')
						)).getCompareValues()
				);

				ValuesRL.addAll(
						(new RelatedListComparator(
								record1,
								record2,
								'EDM_Attendee_gne__c',
								new Map<String, String> {
										'EDM_First_Name_gne__c' => 'First Name',
										'EDM_Last_Name_gne__c' => 'Last Name',
										'EDM_Role_gne__c' => 'Role',
										'EDM_Date_Added_Snapshot_gne__c' => 'Date Added',
										'EDM_Date_Added_gne__c' => 'Date Added'
								},
								'Patients and Other Advisors (non-HCP)',
								new DefaultQueryExecutor('EDM_Attendee_gne__c', 'EDM_Parent_IABP_gne__c', 'AND EDM_System_Type_gne__c = \'Other\'')
						)).getCompareValues()
				);

				ValuesRL.add(new CompareWrapper('Statistics', null, null, 'title'));
				if(record2.EDM_Meeting_Approach_gne__c == 'iAdvise') {
					ValuesRL.add(new CompareWrapper('Total Question Hours', record1.EDM_Total_Question_Hours_gne__c, record2.EDM_Total_Question_Hours_gne__c, 'label'));
				}
				ValuesRL.add(new CompareWrapper('Actual # of Advisors', record1.EDM_Actual_Nr_of_Advisors_gne__c, record2.EDM_Actual_Nr_of_Advisors_gne__c, 'label'));
				ValuesRL.add(new CompareWrapper('Actual # of Gene Reps', record1.EDM_Actual_Nr_of_Gene_Reps_gne__c, record2.EDM_Actual_Nr_of_Gene_Reps_gne__c, 'label'));
				ValuesRL.addAll(
						(new RelatedListComparator(
								record1,
								record2,
								'EDM_Attachment_gne__c',
								new Map<String, String> {
										'EDM_Document_Name_gne__c' => 'Document Name',
										'EDM_Type_gne__c' => 'Document Type',
										'EDM_Upload_Date_gne__c' => 'Added Date',
										'EDM_Description_gne__c' => 'Description'
								},
								'Event Documents',
								new DefaultQueryExecutor('EDM_Attachment_gne__c', 'EDM_Parent_IABP_gne__c', 'AND EDM_System_Type_gne__c = \'Event Document\'')
						)).getCompareValues()
				);
			}
			else {
				pageTitle = 'Executive Summary Comparator';

				Values = populateMainExeSumValues();
				ValuesRL.addAll(
						(new RelatedListComparator(
								record1,
								record2,
								'EDM_Attendee_gne__c',
								new Map<String, String> {
										'EDM_First_Name_gne__c' => 'First Name',
										'EDM_Last_Name_gne__c' => 'Last Name',
										'EDM_Role_gne__c' => 'Title',
										'EDM_Purpose_gne__c' => 'Role/Purpose',
										'EDM_Observer_gne__c' => 'Observer',
										'EDM_Company_gne__c' => 'Company',
										'EDM_Date_Added_Snapshot_gne__c' => 'Date Added',
										'EDM_Date_Added_gne__c' => 'Date Added'
								},
								'Genentech and Co-Promote Attendees',
								new DefaultQueryExecutor('EDM_Attendee_gne__c', 'EDM_Parent_IABP_gne__c', 'AND EDM_System_Type_gne__c = \'Genentech\'')
						)).getCompareValues()
				);

				ValuesRL.addAll(
						(new RelatedListComparator(
								record1,
								record2,
								'EDM_Attendee_gne__c',
								new Map<String, String> {
										'EDM_Account_gne__r.FirstName' => 'First Name',
										'EDM_Account_gne__r.LastName' => 'Last Name',
										'EDM_Role_gne__c' => 'Role',
										'EDM_Clinical_Classification_gne__c' => 'Clinical Classification',
										'EDM_Account_gne__r.Credentials_gne__c' => 'Credentials',
										'EDM_Clinical_Specialties_gne__c' => 'Specialties',
										'EDM_Business_Classification_gne__c' => 'Business Classification',
										'EDM_Business_Classification_Role_gne__c' => 'Business Role',
										'EDM_Exclusion_Status_gne__c' => 'Exclusion Status',
										'EDM_Current_Exclusion_Checked_Date_Disp__c' => 'Current Exclusion Checked Date',
										'EDM_Date_Added_Snapshot_gne__c' => 'Date Added',
										'EDM_Date_Added_gne__c' => 'Date Added'
								},
								'US HCP and Business Leader Advisors',
								new DefaultQueryExecutor('EDM_Attendee_gne__c', 'EDM_Parent_IABP_gne__c', 'AND EDM_System_Type_gne__c = \'Advisor\'')
						)).getCompareValues()
				);

				ValuesRL.addAll(
						(new RelatedListComparator(
								record1,
								record2,
								'EDM_Attendee_gne__c',
								new Map<String, String> {
										'EDM_First_Name_gne__c' => 'First Name',
										'EDM_Last_Name_gne__c' => 'Last Name',
										'EDM_Role_gne__c' => 'Role',
										'EDM_Country_gne__c' => 'Country',
										'EDM_Date_Added_Snapshot_gne__c' => 'Date Added',
										'EDM_Date_Added_gne__c' => 'Date Added'
								},
								'Non-US HCP and Business Leader Advisors',
								new DefaultQueryExecutor('EDM_Attendee_gne__c', 'EDM_Parent_IABP_gne__c', 'AND EDM_System_Type_gne__c = \'NonUSAdvisor\'')
						)).getCompareValues()
				);

				ValuesRL.addAll(
						(new RelatedListComparator(
								record1,
								record2,
								'EDM_Attendee_gne__c',
								new Map<String, String> {
										'EDM_First_Name_gne__c' => 'First Name',
										'EDM_Last_Name_gne__c' => 'Last Name',
										'EDM_Role_gne__c' => 'Role',
										'EDM_Date_Added_Snapshot_gne__c' => 'Date Added',
										'EDM_Date_Added_gne__c' => 'Date Added'
								},
								'Patients and Other Advisors (non-HCP)',
								new DefaultQueryExecutor('EDM_Attendee_gne__c', 'EDM_Parent_IABP_gne__c', 'AND EDM_System_Type_gne__c = \'Other\'')
						)).getCompareValues()
				);

				ValuesRL.addAll(
						(new RelatedListComparator(
								record1,
								record2,
								'EDM_Session_gne__c',
								new Map<String, String> {
										'EDM_Title_gne__c' => 'Session Title',
										'EDM_Information_Gained_gne__c' => 'Information Gained'
								},
								'Agenda and Information Gained',
								new DefaultQueryExecutor('EDM_Session_gne__c', 'EDM_Parent_IABP_gne__c', 'AND EDM_Is_Break_gne__c = false ORDER BY CreatedDate')
						)).getCompareValues()
				);

				ValuesRL.addAll(
						(new RelatedListComparator(
								record1,
								record2,
								'EDM_Attachment_gne__c',
								new Map<String, String> {
										'EDM_Document_Name_gne__c' => 'Document Name',
										'EDM_Responsible_Party_gne__r.Name' => 'Responsible Party',
										'EDM_Estimated_Quarter_gne__c' => 'Estimated Quarter',
										'EDM_Year_gne__c' => 'Year'
								},
								'Pull-Through Documentation',
								new PTDQueryExecutor('EDM_Attachment_gne__c', 'EDM_Parent_IABP_gne__c', 'AND EDM_Pull_Through_Doc_gne__c = true ORDER BY EDM_PreSnap_Attachment__r.CreatedDate, CreatedDate')
						)).getCompareValues()
				);

			}

		}
		catch (Exception ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The records to compare could not be retrieved. ' + ex.getMessage() + ' ' + ex.getStackTraceString()));
			System.debug('The records to compare could not be retrieved. ' + ex.getMessage() + ' ' + ex.getStackTraceString());
		}
	}

	public PageReference goBack() {
		PageReference pr;
		String retURL = System.currentPageReference().getParameters().get('retURL');

		if (retURL == null) {
			pr = new PageReference('/apex/EDM_IABP_Review_Layout?id=' + record1.Id);
			pr.setRedirect(true);
		}
		else {
			pr = new PageReference(retURL);
			pr.setRedirect(true);
		}
		return pr;
	}

	private List<CompareWrapper> populateMainValues() {
		List<CompareWrapper> result = new List<CompareWrapper>();
		result.add(new CompareWrapper('Event Details', null, null, 'title'));
		result.add(new CompareWrapper('Year', record1.EDM_Year_gne__c, record2.EDM_Year_gne__c, 'label'));
		result.add(new CompareWrapper('Team(s)', record1.EDM_Team_gne__c, record2.EDM_Team_gne__c, 'label'));
		result.add(new CompareWrapper('Brand/Molecule', record1.EDM_Brand_gne__c, record2.EDM_Brand_gne__c, 'label'));
		result.add(new CompareWrapper('Type of Event', record1.EDM_Type_of_Event_gne__c, record2.EDM_Type_of_Event_gne__c, 'label'));
		result.add(new CompareWrapper('Event Focus', record1.EDM_Event_Focus_gne__c, record2.EDM_Event_Focus_gne__c, 'label'));
		result.add(new CompareWrapper('Title', record1.EDM_Event_Name_gne__c, record2.EDM_Event_Name_gne__c, 'label'));
		result.add(new CompareWrapper('Optional Detail', record1.EDM_Optional_Detail_gne__c, record2.EDM_Optional_Detail_gne__c, 'label'));
		result.add(new CompareWrapper('Start Date', record1.EDM_Start_Date_gne__c, record2.EDM_Start_Date_gne__c, 'label'));
		result.add(new CompareWrapper('End Date', record1.EDM_End_Date_gne__c, record2.EDM_End_Date_gne__c, 'label'));
		result.add(new CompareWrapper('Meeting Date', record1.EDM_Meeting_Date_gne__c, record2.EDM_Meeting_Date_gne__c, 'label'));
		result.add(new CompareWrapper('Meeting Style', record1.EDM_Meeting_Approach_gne__c, record2.EDM_Meeting_Approach_gne__c, 'label'));
		result.add(new CompareWrapper('Integrated Approach', record1.EDM_Joint_Approach_gne__c, record2.EDM_Joint_Approach_gne__c, 'label'));
		result.add(new CompareWrapper('City', record1.EDM_City_gne__c, record2.EDM_City_gne__c, 'label'));
		result.add(new CompareWrapper('State/Province', record1.EDM_State_gne__c, record2.EDM_State_gne__c, 'label'));
		result.add(new CompareWrapper('Country', record1.EDM_Country_gne__c, record2.EDM_Country_gne__c, 'label'));
		result.add(new CompareWrapper('Venue', record1.EDM_Venue_gne__c, record2.EDM_Venue_gne__c, 'label'));
		result.add(new CompareWrapper('ABS Manager', record1.EDM_ABS_Manager_gne__r.Name, record2.EDM_ABS_Manager_gne__r.Name, 'label'));
		result.add(new CompareWrapper('Primary AB Lead', record1.EDM_Primary_AB_Lead_gne__r.Name, record2.EDM_Primary_AB_Lead_gne__r.Name, 'label'));
		result.add(new CompareWrapper('Second AB Lead', record1.EDM_Secondary_AB_Lead_gne__r.Name, record2.EDM_Secondary_AB_Lead_gne__r.Name, 'label'));
		result.add(new CompareWrapper('Third AB Lead', record1.EDM_Third_AB_Lead_gne__r.Name, record2.EDM_Third_AB_Lead_gne__r.Name, 'label'));
		result.add(new CompareWrapper('Admin', record1.EDM_Admin_gne__r.Name, record2.EDM_Admin_gne__r.Name, 'label'));
		result.add(new CompareWrapper('Primary Vendor Lead', record1.EDM_Primary_Vendor_Lead_gne__r.Name, record2.EDM_Primary_Vendor_Lead_gne__r.Name, 'label'));
		result.add(new CompareWrapper('Second Vendor Lead', record1.EDM_Second_Vendor_Lead_gne__r.Name, record2.EDM_Second_Vendor_Lead_gne__r.Name, 'label'));
		result.add(new CompareWrapper('Email of SES Manager', record1.EDM_MCS_Manager_gne__c, record2.EDM_MCS_Manager_gne__c, 'label'));

		result.add(new CompareWrapper('Event Documentation Status', null, null, 'title'));
		result.add(new CompareWrapper('IABP Submitted', record1.EDM_IABP_Submitted_gne__c, record2.EDM_IABP_Submitted_gne__c, 'label'));
		result.add(new CompareWrapper('IABP Approved', record1.EDM_IABP_Approved_gne__c, record2.EDM_IABP_Approved_gne__c, 'label'));
		result.add(new CompareWrapper('Approved By', record1.EDM_Approved_By_gne__c, record2.EDM_Approved_By_gne__c, 'label'));
		result.add(new CompareWrapper('IABP Version', record1.EDM_IABP_Version_gne__c, record2.EDM_IABP_Version_gne__c, 'label'));
		result.add(new CompareWrapper('Version Validated', record1.EDM_Version_Validated_gne__c, record2.EDM_Version_Validated_gne__c, 'label'));
		result.add(new CompareWrapper('ExeSum Submitted', record1.EDM_ExeSum_Submitted_gne__c, record2.EDM_ExeSum_Submitted_gne__c, 'label'));
		result.add(new CompareWrapper('ExeSum Finalized', record1.EDM_ExeSum_Finalized_gne__c, record2.EDM_ExeSum_Finalized_gne__c, 'label'));

		result.add(new CompareWrapper('Logistics Vendor', null, null, 'title'));
		result.add(new CompareWrapper('Logistics Vendor Company Name', record1.EDM_Log_Vendor_Company_Name_gne__c, record2.EDM_Log_Vendor_Company_Name_gne__c, 'label'));
		result.add(new CompareWrapper('Logistics Vendor Contact', record1.EDM_Log_Vendor_Contact_Name_gne__c, record2.EDM_Log_Vendor_Contact_Name_gne__c, 'label'));
		result.add(new CompareWrapper('Logistics Vendor Contact Email', record1.EDM_Log_Vendor_Contact_Email_gne__c, record2.EDM_Log_Vendor_Contact_Email_gne__c, 'label'));

		result.add(new CompareWrapper('Content Vendor', null, null, 'title'));
		result.add(new CompareWrapper('Content Vendor Name', record1.EDM_Cont_Vendor_Company_Name_gne__c, record2.EDM_Cont_Vendor_Company_Name_gne__c, 'label'));
		result.add(new CompareWrapper('Content Vendor Contact', record1.EDM_Cont_Vendor_Contact_Name_gne__c, record2.EDM_Cont_Vendor_Contact_Name_gne__c, 'label'));
		result.add(new CompareWrapper('Content Vendor Contact Email', record1.EDM_Cont_Vendor_Contact_Email_gne__c, record2.EDM_Cont_Vendor_Contact_Email_gne__c, 'label'));

		result.add(new CompareWrapper('Strategic Context', null, null, 'title'));
		result.add(new CompareWrapper('Strategic Context', record1.EDM_Strategic_Context_gne__c, record2.EDM_Strategic_Context_gne__c, 'label-rich'));

		result.add(new CompareWrapper('Affiliated with Major Medical Meeting or Congress (Optional)', null, null, 'title'));
		result.add(new CompareWrapper('Affiliated with Major Medical Meeting or Congress (Optional)', record1.EDM_Affiliated_w_Meeting_Congress_gne__c, record2.EDM_Affiliated_w_Meeting_Congress_gne__c, 'label-rich'));

		result.add(new CompareWrapper('Advisor Selection Criteria', null, null, 'title'));
		result.add(new CompareWrapper('Advisor Selection Criteria', record1.EDM_Advisor_Selection_Criteria_gne__c, record2.EDM_Advisor_Selection_Criteria_gne__c, 'label-rich'));
		result.add(new CompareWrapper('Advisor Duties', record1.EDM_Advisor_Selection_Duties_gne__c, record2.EDM_Advisor_Selection_Duties_gne__c, 'label-rich'));
		result.add(new CompareWrapper('Moderator Selection Criteria', record1.EDM_Moderator_Selection_Criteria_gne__c, record2.EDM_Moderator_Selection_Criteria_gne__c, 'label-rich'));
		result.add(new CompareWrapper('Moderator Duties', record1.EDM_Moderator_Selection_Duties_gne__c, record2.EDM_Moderator_Selection_Duties_gne__c, 'label-rich'));
		result.add(new CompareWrapper('Chair Selection Criteria', record1.EDM_Chair_Selection_Criteria_gne__c, record2.EDM_Chair_Selection_Criteria_gne__c, 'label-rich'));
		result.add(new CompareWrapper('Chair Duties', record1.EDM_Chair_Selection_Duties_gne__c, record2.EDM_Chair_Selection_Duties_gne__c, 'label-rich'));
		result.add(new CompareWrapper('Clinical Expert Selection Criteria', record1.EDM_Cl_Expert_Selection_Criteria_gne__c, record2.EDM_Cl_Expert_Selection_Criteria_gne__c, 'label-rich'));
		result.add(new CompareWrapper('Clinical Expert Duties', record1.EDM_Cl_Expert_Selection_Duties_gne__c, record2.EDM_Cl_Expert_Selection_Duties_gne__c, 'label-rich'));

		result.add(new CompareWrapper('Exception request', null, null, 'title'));
		result.add(new CompareWrapper('Ratio exception rationale', record1.EDM_Exception_Rationale_gne__c, record2.EDM_Exception_Rationale_gne__c, 'label-rich'));
		result.add(new CompareWrapper('Location exception rationale', record1.EDM_Location_exception_rationale_gne__c, record2.EDM_Location_exception_rationale_gne__c, 'label-rich'));

		return result;
	}

	private List<CompareWrapper> populateMainExeSumValues() {
		List<CompareWrapper> result = new List<CompareWrapper>();
		result.add(new CompareWrapper('Event Details', null, null, 'title'));
		result.add(new CompareWrapper('Year', record1.EDM_Year_gne__c, record2.EDM_Year_gne__c, 'label'));
		result.add(new CompareWrapper('Team(s)', record1.EDM_Team_gne__c, record2.EDM_Team_gne__c, 'label'));
		result.add(new CompareWrapper('Brand/Molecule', record1.EDM_Brand_gne__c, record2.EDM_Brand_gne__c, 'label'));
		result.add(new CompareWrapper('Type of Event', record1.EDM_Type_of_Event_gne__c, record2.EDM_Type_of_Event_gne__c, 'label'));
		result.add(new CompareWrapper('Event Focus', record1.EDM_Event_Focus_gne__c, record2.EDM_Event_Focus_gne__c, 'label'));
		result.add(new CompareWrapper('Title', record1.EDM_Event_Name_gne__c, record2.EDM_Event_Name_gne__c, 'label'));
		result.add(new CompareWrapper('Optional Detail', record1.EDM_Optional_Detail_gne__c, record2.EDM_Optional_Detail_gne__c, 'label'));
		result.add(new CompareWrapper('Start Date', record1.EDM_Start_Date_gne__c, record2.EDM_Start_Date_gne__c, 'label'));
		result.add(new CompareWrapper('End Date', record1.EDM_End_Date_gne__c, record2.EDM_End_Date_gne__c, 'label'));
		result.add(new CompareWrapper('Meeting Date', record1.EDM_Meeting_Date_gne__c, record2.EDM_Meeting_Date_gne__c, 'label'));
		result.add(new CompareWrapper('Meeting Style', record1.EDM_Meeting_Approach_gne__c, record2.EDM_Meeting_Approach_gne__c, 'label'));
		result.add(new CompareWrapper('Integrated Approach', record1.EDM_Joint_Approach_gne__c, record2.EDM_Joint_Approach_gne__c, 'label'));
		result.add(new CompareWrapper('City', record1.EDM_City_gne__c, record2.EDM_City_gne__c, 'label'));
		result.add(new CompareWrapper('State/Province', record1.EDM_State_gne__c, record2.EDM_State_gne__c, 'label'));
		result.add(new CompareWrapper('Country', record1.EDM_Country_gne__c, record2.EDM_Country_gne__c, 'label'));
		result.add(new CompareWrapper('Venue', record1.EDM_Venue_gne__c, record2.EDM_Venue_gne__c, 'label'));
		result.add(new CompareWrapper('ABS Manager', record1.EDM_ABS_Manager_gne__r.Name, record2.EDM_ABS_Manager_gne__r.Name, 'label'));
		result.add(new CompareWrapper('Primary AB Lead', record1.EDM_Primary_AB_Lead_gne__r.Name, record2.EDM_Primary_AB_Lead_gne__r.Name, 'label'));
		result.add(new CompareWrapper('Second AB Lead', record1.EDM_Secondary_AB_Lead_gne__r.Name, record2.EDM_Secondary_AB_Lead_gne__r.Name, 'label'));
		result.add(new CompareWrapper('Third AB Lead', record1.EDM_Third_AB_Lead_gne__r.Name, record2.EDM_Third_AB_Lead_gne__r.Name, 'label'));
		result.add(new CompareWrapper('Admin', record1.EDM_Admin_gne__r.Name, record2.EDM_Admin_gne__r.Name, 'label'));
		result.add(new CompareWrapper('Primary Vendor Lead', record1.EDM_Primary_Vendor_Lead_gne__r.Name, record2.EDM_Primary_Vendor_Lead_gne__r.Name, 'label'));
		result.add(new CompareWrapper('Second Vendor Lead', record1.EDM_Second_Vendor_Lead_gne__r.Name, record2.EDM_Second_Vendor_Lead_gne__r.Name, 'label'));
		result.add(new CompareWrapper('Email of SES Manager', record1.EDM_MCS_Manager_gne__c, record2.EDM_MCS_Manager_gne__c, 'label'));

		result.add(new CompareWrapper('Logistics Vendor', null, null, 'title'));
		result.add(new CompareWrapper('Logistics Vendor Company Name', record1.EDM_Log_Vendor_Company_Name_gne__c, record2.EDM_Log_Vendor_Company_Name_gne__c, 'label'));
		result.add(new CompareWrapper('Logistics Vendor Contact', record1.EDM_Log_Vendor_Contact_Name_gne__c, record2.EDM_Log_Vendor_Contact_Name_gne__c, 'label'));
		result.add(new CompareWrapper('Logistics Vendor Contact Email', record1.EDM_Log_Vendor_Contact_Email_gne__c, record2.EDM_Log_Vendor_Contact_Email_gne__c, 'label'));

		result.add(new CompareWrapper('Content Vendor', null, null, 'title'));
		result.add(new CompareWrapper('Content Vendor Name', record1.EDM_Cont_Vendor_Company_Name_gne__c, record2.EDM_Cont_Vendor_Company_Name_gne__c, 'label'));
		result.add(new CompareWrapper('Content Vendor Contact', record1.EDM_Cont_Vendor_Contact_Name_gne__c, record2.EDM_Cont_Vendor_Contact_Name_gne__c, 'label'));
		result.add(new CompareWrapper('Content Vendor Contact Email', record1.EDM_Cont_Vendor_Contact_Email_gne__c, record2.EDM_Cont_Vendor_Contact_Email_gne__c, 'label'));

		result.add(new CompareWrapper('Attendees summary', null, null, 'title'));
		result.add(new CompareWrapper('Genentech and Co-Promote Attendees', record1.EDM_Actual_Nr_of_Gene_Reps_gne__c, record2.EDM_Actual_Nr_of_Gene_Reps_gne__c, 'label'));
		result.add(new CompareWrapper('Advisors', record1.EDM_Actual_Nr_of_Advisors_gne__c, record2.EDM_Actual_Nr_of_Advisors_gne__c, 'label'));

		result.add(new CompareWrapper('Support and Monitoring Attendees (not included above)', record1.EDM_Est_nr_of_Other_Attendees_gne__c, record2.EDM_Est_nr_of_Other_Attendees_gne__c, 'label'));
		result.add(new CompareWrapper('Explanation of Attendee Changes from IABP', record1.EDM_Explanation_of_Att_Changes_gne__c, record2.EDM_Explanation_of_Att_Changes_gne__c, 'label-rich'));

		return result;
	}

	private EDM_IABP_gne__c getRecordById(Id id) {
		List<String> extraFields = new List<String>
		{
				'EDM_Primary_AB_Lead_gne__r.Name',
				'EDM_Secondary_AB_Lead_gne__r.Name',
				'EDM_Third_AB_Lead_gne__r.Name',
				'EDM_Admin_gne__r.Name',
				'EDM_Primary_Vendor_Lead_gne__r.Name',
				'EDM_Second_Vendor_Lead_gne__r.Name',
				'EDM_ABS_Manager_gne__r.Name'
		};
		EDM_IABP_gne__c iabp = (EDM_IABP_gne__c)Database.query(EDM_ABM_Utils.getAllFieldsSOQL('EDM_IABP_gne__c', 'Id =\'' + id + '\'', extraFields));
		return iabp;
	}

	public class CompareWrapper {
		public String label { get; private set; }
		public String v1 { get; private set; }
		public String v2 { get; private set; }
		public String t { get; private set; }

		public CompareWrapper(String label, Object v1, Object v2, String rType) {
			this.label = label;
			this.v1 = String.valueOf(v1);
			this.v2 = String.valueOf(v2);
			this.t = rType;
		}
	}

	private class AgendaComparator {
		EDM_IABP_gne__c record1;
		EDM_IABP_gne__c record2;

		List<EDM_Session_gne__c> sessions1;
		List<EDM_Session_gne__c> sessions2;

		Map<String, EDM_Session_gne__c> sessions1ByCompID;
		Map<String, EDM_Session_gne__c> sessions2ByCompID;
		Set<String> compareSessionIDs;

		private List<EDM_Session_gne__c> getSessionsByParendId(Id parentId) {
			return [SELECT Id, Name, EDM_Description_gne__c, EDM_Discussion_End_Time_gne__c, EDM_Discussion_Start_Time_gne__c, EDM_Parent_IABP_gne__c, EDM_ID_For_Comparator_gne__c,
					EDM_Presentation_End_Time_gne__c, EDM_Presentation_Start_Time_gne__c, EDM_Presenter_gne__c, EDM_Title_gne__c, EDM_Is_Break_gne__c,
					EDM_Session_Objectives_gne__c, EDM_Representative_AB_Questions_gne__c, EDM_Content_Description_gne__c, EDM_Session_Date_gne__c
			FROM EDM_Session_gne__c
			WHERE EDM_Parent_IABP_gne__c = :parentId];
		}

		private void populateSessionStructure() {
			for (EDM_Session_gne__c ses : sessions1) {
				this.sessions1ByCompID.put(ses.EDM_ID_For_Comparator_gne__c, ses);
			}

			for (EDM_Session_gne__c ses : sessions2) {
				this.sessions2ByCompID.put(ses.EDM_ID_For_Comparator_gne__c, ses);
			}

			compareSessionIDs.addAll(sessions1ByCompID.keySet());
			compareSessionIDs.addAll(sessions2ByCompID.keySet());
		}

		public AgendaComparator(EDM_IABP_gne__c record1, EDM_IABP_gne__c record2) {
			this.record1 = record1;
			this.record2 = record2;

			compareSessionIDs = new Set<String>();
			sessions1ByCompID = new Map<String, EDM_Session_gne__c>();
			sessions2ByCompID = new Map<String, EDM_Session_gne__c>();

			this.sessions1 = getSessionsByParendId(record1.Id);
			this.sessions2 = getSessionsByParendId(record2.Id);
			populateSessionStructure();
		}

		public List<CompareWrapper> getAgendaValues() {
			List<CompareWrapper> result = new List<CompareWrapper>();
			result.add(new CompareWrapper('Agenda', null, null, 'title'));

			for (String compID : compareSessionIDs) {
				result.add(new CompareWrapper('Date',
						sessions1ByCompID.containsKey(compID) ? sessions1ByCompID.get(compID).EDM_Session_Date_gne__c : null,
						sessions2ByCompID.containsKey(compID) ? sessions2ByCompID.get(compID).EDM_Session_Date_gne__c : null,
						'label'));
				result.add(new CompareWrapper('Title',
						sessions1ByCompID.containsKey(compID) ? sessions1ByCompID.get(compID).EDM_Title_gne__c : null,
						sessions2ByCompID.containsKey(compID) ? sessions2ByCompID.get(compID).EDM_Title_gne__c : null,
						'label'));

				if (sessions1ByCompID.containsKey(compID) && !sessions1ByCompID.get(compID).EDM_Is_Break_gne__c
						|| sessions2ByCompID.containsKey(compID) && !sessions2ByCompID.get(compID).EDM_Is_Break_gne__c) {
					result.add(new CompareWrapper('Presenter',
							sessions1ByCompID.containsKey(compID) ? sessions1ByCompID.get(compID).EDM_Presenter_gne__c : null,
							sessions2ByCompID.containsKey(compID) ? sessions2ByCompID.get(compID).EDM_Presenter_gne__c : null,
							'label'));
					result.add(new CompareWrapper('Presentation Start',
							sessions1ByCompID.containsKey(compID) ? sessions1ByCompID.get(compID).EDM_Presentation_Start_Time_gne__c : null,
							sessions2ByCompID.containsKey(compID) ? sessions2ByCompID.get(compID).EDM_Presentation_Start_Time_gne__c : null,
							'label'));
					result.add(new CompareWrapper('Presentation End',
							sessions1ByCompID.containsKey(compID) ? sessions1ByCompID.get(compID).EDM_Presentation_End_Time_gne__c : null,
							sessions2ByCompID.containsKey(compID) ? sessions2ByCompID.get(compID).EDM_Presentation_End_Time_gne__c : null,
							'label'));
					result.add(new CompareWrapper('Discussion Start',
							sessions1ByCompID.containsKey(compID) ? sessions1ByCompID.get(compID).EDM_Discussion_Start_Time_gne__c : null,
							sessions2ByCompID.containsKey(compID) ? sessions2ByCompID.get(compID).EDM_Discussion_Start_Time_gne__c : null,
							'label'));
					result.add(new CompareWrapper('Discussion End',
							sessions1ByCompID.containsKey(compID) ? sessions1ByCompID.get(compID).EDM_Discussion_End_Time_gne__c : null,
							sessions2ByCompID.containsKey(compID) ? sessions2ByCompID.get(compID).EDM_Discussion_End_Time_gne__c : null,
							'label'));

					result.add(new CompareWrapper('Session Objective',
							sessions1ByCompID.containsKey(compID) ? sessions1ByCompID.get(compID).EDM_Session_Objectives_gne__c : null,
							sessions2ByCompID.containsKey(compID) ? sessions2ByCompID.get(compID).EDM_Session_Objectives_gne__c : null,
							'label-rich'));

					result.add(new CompareWrapper('Representative AB Question',
							sessions1ByCompID.containsKey(compID) ? sessions1ByCompID.get(compID).EDM_Representative_AB_Questions_gne__c : null,
							sessions2ByCompID.containsKey(compID) ? sessions2ByCompID.get(compID).EDM_Representative_AB_Questions_gne__c : null,
							'label-rich'));

					result.add(new CompareWrapper('Content Description',
							sessions1ByCompID.containsKey(compID) ? sessions1ByCompID.get(compID).EDM_Content_Description_gne__c : null,
							sessions2ByCompID.containsKey(compID) ? sessions2ByCompID.get(compID).EDM_Content_Description_gne__c : null,
							'label-rich'));

				} else if (sessions1ByCompID.containsKey(compID) && sessions1ByCompID.get(compID).EDM_Is_Break_gne__c
						|| sessions2ByCompID.containsKey(compID) && sessions2ByCompID.get(compID).EDM_Is_Break_gne__c) {
					result.add(new CompareWrapper('Break Start',
							sessions1ByCompID.containsKey(compID) ? sessions1ByCompID.get(compID).EDM_Presentation_Start_Time_gne__c : null,
							sessions2ByCompID.containsKey(compID) ? sessions2ByCompID.get(compID).EDM_Presentation_Start_Time_gne__c : null,
							'label'));
					result.add(new CompareWrapper('Break End',
							sessions1ByCompID.containsKey(compID) ? sessions1ByCompID.get(compID).EDM_Presentation_End_Time_gne__c : null,
							sessions2ByCompID.containsKey(compID) ? sessions2ByCompID.get(compID).EDM_Presentation_End_Time_gne__c : null,
							'label'));
				}

				result.add(new CompareWrapper('', null, null, 'separator'));
			}
			result.add(new CompareWrapper('Total Presentation Time', record1.EDM_Total_Presentation_Time_gne__c, record2.EDM_Total_Presentation_Time_gne__c, 'label'));
			result.add(new CompareWrapper('Total Discussion Time', record1.EDM_Total_Discussion_Time_gne__c, record2.EDM_Total_Discussion_Time_gne__c, 'label'));
			result.add(new CompareWrapper('Total Meeting Time', record1.EDM_Total_Meetings_Time__c, record2.EDM_Total_Meetings_Time__c, 'label'));
			result.add(new CompareWrapper('Total Discussion Time %', record1.EDM_Discussion_Time_Percent_gne__c, record2.EDM_Discussion_Time_Percent_gne__c, 'percent'));

			return result;
		}
	}

	private class RelatedListComparator {
		EDM_IABP_gne__c record1;
		EDM_IABP_gne__c record2;

		String objectType;
		Map<String, String> queryFieldsToLabel;

		List<sObject> list1;
		List<sObject> list2;

		Map<String, sObject> list1ByCompareId;
		Map<String, sObject> list2ByCompareId;
		Set<String> compareIDs;

		Map<String, String> fieldAPINameToType;

		String title;

		private void populateCompareIDStructure() {
			for (SObject o : list1) {
				list1ByCompareId.put((String)o.get('EDM_ID_For_Comparator_gne__c'), o);
			}
			for (SObject o : list2) {
				list2ByCompareId.put((String)o.get('EDM_ID_For_Comparator_gne__c'), o);
			}

			compareIDs.addAll(list1ByCompareId.keySet());
			compareIDs.addAll(list2ByCompareId.keySet());
		}

		private void populateFieldTypes() {
			fieldAPINameToType = new Map<String, String>();
			for (String fieldName : queryFieldsToLabel.keySet()) {
				String fieldType = getFieldType(objectType, fieldName);
				fieldAPINameToType.put(fieldName, fieldType);
			}
		}

		private String getFieldType(String sObjectName, String fieldName) {
			if (fieldName.contains('.')) {
				return 'REFERENCE';
			}
			else {
				Schema.SObjectType t = Schema.getGlobalDescribe().get(sObjectName);
				Schema.DescribeSObjectResult r = t.getDescribe();
				Schema.DescribeFieldResult f = r.fields.getMap().get(fieldName).getDescribe();
				return f.getType().name();
			}
		}

		public RelatedListComparator(EDM_IABP_gne__c record1, EDM_IABP_gne__c record2, String objectType, Map<String, String> queryFieldsToLabel, String title, QueryExecutor executor) {
			this.record1 = record1;
			this.record2 = record2;

			list1ByCompareId = new Map<String, SObject>();
			list2ByCompareId = new Map<String, SObject>();
			compareIDs = new Set<String>();

			this.objectType = objectType;
			this.queryFieldsToLabel = queryFieldsToLabel;

			this.title = title;

			list1 = executor.getRecordList(record1, queryFieldsToLabel);
			list2 = executor.getRecordList(record2, queryFieldsToLabel);

			if(this.objectType == 'EDM_Attachment_gne__c') {
				Map<String, sObject> tmpEdmIdForComparatorToEdmAttachmentMap1 = createMapBasedOnsObjectList(list1, 'EDM_ID_For_Comparator_gne__c');
				Map<String, sObject> tmpEdmIdForComparatorToEdmAttachmentMap2 = createMapBasedOnsObjectList(list2, 'EDM_ID_For_Comparator_gne__c');
				compareEventDocumentsRecords(tmpEdmIdForComparatorToEdmAttachmentMap1, tmpEdmIdForComparatorToEdmAttachmentMap2);
			}

			populateCompareIDStructure();
			populateFieldTypes();
		}

		private Map<String, sObject> createMapBasedOnsObjectList(List<sObject> sObjectList, String fieldApiName) {
			Map<String, sObject> tmpEdmIdForComparatorToEdmAttachmentMap = new Map<String, sObject>();
			for(sObject sObj : sObjectList) {
				tmpEdmIdForComparatorToEdmAttachmentMap.put((String)sObj.get(fieldApiName), sObj);
			}
			return tmpEdmIdForComparatorToEdmAttachmentMap;
		}

		private void compareEventDocumentsRecords(Map<String, sObject> tmpEdmIdForComparatorToEdmAttachmentMap1, Map<String, sObject> tmpEdmIdForComparatorToEdmAttachmentMap2) {
			for(String edmIdForComparator : tmpEdmIdForComparatorToEdmAttachmentMap1.keySet()) {
				if(!tmpEdmIdForComparatorToEdmAttachmentMap2.containsKey(edmIdForComparator)) {
					sObject sObjectEdmAttachment = tmpEdmIdForComparatorToEdmAttachmentMap1.get(edmIdForComparator);
					sObject tmpEdmAttachment = sObjectEdmAttachment.clone(true, false, false, false);
					tmpEdmAttachment.put('EDM_Document_Name_gne__c', ' ');
					tmpEdmAttachment.put('EDM_Type_gne__c', ' ');
					tmpEdmAttachment.put('EDM_Upload_Date_gne__c', null);
					tmpEdmAttachment.put('EDM_Description_gne__c', ' ');
					list2.add(tmpEdmAttachment);
				}
			}
		}

		public List<CompareWrapper> getCompareValues() {
			Integer count = 0;
			List<CompareWrapper> result = new List<CompareWrapper>();
			Set<String> skippedFields = new Set<String> {
					'EDM_Account_gne__r.AGS_EX_Date_Checked_Exclusion_gne__c',
					'EDM_Current_Exclusion_Checked_Date_Disp__c',
					'EDM_Date_Added_gne__c'};
			result.add(new CompareWrapper(title, null, null, 'title'));
			for (String compID : compareIDs) {
				for (String fieldName : queryFieldsToLabel.keySet()) {
					String resultType;
					if (fieldAPINameToType.get(fieldName) == 'TEXTAREA') {
						resultType = 'label-rich';
					}
					else {
						resultType = 'label';
					}

					if(skippedFields.contains(fieldName)) {
						continue;
					}

					if(fieldName == 'EDM_Exclusion_Status_gne__c') {
						Object list1currExclusionCheckedDate;
						Object list2currExclusionCheckedDate;
						Object list1ExclusionCheckedDate;
						Object list2ExclusionCheckedDate;

						if(queryFieldsToLabel.keySet().contains('EDM_Current_Exclusion_Checked_Date_Disp__c')) {
							list1currExclusionCheckedDate = list1ByCompareId.containsKey(compID) ? list1ByCompareId.get(compID).get('EDM_Current_Exclusion_Checked_Date_Disp__c') : null;
							list2currExclusionCheckedDate = list2ByCompareId.containsKey(compID) ? list2ByCompareId.get(compID).get('EDM_Current_Exclusion_Checked_Date_Disp__c') : null;
						} else if(queryFieldsToLabel.keySet().contains('EDM_Account_gne__r.AGS_EX_Date_Checked_Exclusion_gne__c')) {
							list1ExclusionCheckedDate = list1ByCompareId.containsKey(compID) ? list1ByCompareId.get(compID).getsObject('EDM_Account_gne__r').get('AGS_EX_Date_Checked_Exclusion_gne__c') : null;
							list2ExclusionCheckedDate = list2ByCompareId.containsKey(compID) ? list2ByCompareId.get(compID).getsObject('EDM_Account_gne__r').get('AGS_EX_Date_Checked_Exclusion_gne__c') : null;
						}

						Date list1ExclusionDate = extractFormattedDate(list1currExclusionCheckedDate, list1ExclusionCheckedDate);
						Date list2ExclusionDate = extractFormattedDate(list2currExclusionCheckedDate, list2ExclusionCheckedDate);
						result.add(new CompareWrapper(queryFieldsToLabel.get(fieldName),
								list1ByCompareId.containsKey(compID) ? list1ByCompareId.get(compID).get(fieldName) + (list1ExclusionDate != null ? ' (' + list1ExclusionDate + ')' : '') : null,
								list2ByCompareId.containsKey(compID) ? list2ByCompareId.get(compID).get(fieldName) + (list2ExclusionDate != null ? ' (' + list2ExclusionDate + ')' : '') : null,
								resultType));
					} else if(fieldName == 'EDM_Date_Added_Snapshot_gne__c') {
						Object list1DateAddedSnapshot = list1ByCompareId.containsKey(compID) ? list1ByCompareId.get(compID).get(fieldName) : null;
						Object list2DateAddedSnapshot = list2ByCompareId.containsKey(compID) ? list2ByCompareId.get(compID).get(fieldName) : null;
						Object list1DateAdded = list1ByCompareId.containsKey(compID) ? list1ByCompareId.get(compID).get('EDM_Date_Added_gne__c') : null;
						Object list2DateAdded = list2ByCompareId.containsKey(compID) ? list2ByCompareId.get(compID).get('EDM_Date_Added_gne__c') : null;
						result.add(new CompareWrapper(queryFieldsToLabel.get(fieldName),
								list1ByCompareId.containsKey(compID) ? extractFormattedDate(list1DateAddedSnapshot, list1DateAdded) : null,
								list2ByCompareId.containsKey(compID) ? extractFormattedDate(list2DateAddedSnapshot, list1DateAdded != null ? list1DateAdded : list2DateAdded) : null,
								resultType));
					} else if(fieldName == 'EDM_Observer_gne__c') {
						result.add(new CompareWrapper(queryFieldsToLabel.get(fieldName),
								list1ByCompareId.containsKey(compID) ? (String.valueOf(list1ByCompareId.get(compID).get(fieldName)) == 'true' ? 'YES' : 'NO') : null,
								list2ByCompareId.containsKey(compID) ? (String.valueOf(list2ByCompareId.get(compID).get(fieldName)) == 'true' ? 'YES' : 'NO') : null,
								resultType));
					} else if(!fieldName.contains('.')) {
						result.add(new CompareWrapper(queryFieldsToLabel.get(fieldName),
								list1ByCompareId.containsKey(compID) ? list1ByCompareId.get(compID).get(fieldName) : null,
								list2ByCompareId.containsKey(compID) ? list2ByCompareId.get(compID).get(fieldName) : null,
								resultType));
					} else {
						List<String> rField = fieldName.split('\\.');
						result.add(new CompareWrapper(queryFieldsToLabel.get(fieldName),
								list1ByCompareId.containsKey(compID) ? list1ByCompareId.get(compID).getsObject(rField[0]).get(rField[1]) : null,
								list2ByCompareId.containsKey(compID) ? list2ByCompareId.get(compID).getsObject(rField[0]).get(rField[1]) : null,
								resultType));
					}

				}
				count++;
				if (count < compareIDs.size()) {
					result.add(new CompareWrapper('', null, null, 'separator'));
				}
			}
			return result;
		}

		private Date extractFormattedDate(Object snapshotDate, Object currentDate) {
			return snapshotDate != null ? (Date)snapshotDate : (currentDate != null ? ((DateTime)currentDate).date() : null);
		}
	}

	private abstract class QueryExecutor {
		private String objectType;
		private String parentField;
		private String additionalWhere;

		public QueryExecutor(String objectType, String parentField, String additionalWhere) {
			this.objectType = objectType;
			this.parentField = parentField;
			this.additionalWhere = additionalWhere;
		}

		public abstract List<SObject> getRecordList(EDM_IABP_gne__c parent, Map<String, String> queryFieldsToLabel);

		private List<SObject> executeQuery(EDM_IABP_gne__c parent, Map<String, String> queryFieldsToLabel) {
			List<SObject> result;
			Id parentId = parent.Id;

			String query = getQuery(queryFieldsToLabel);
			result = Database.query(query);
			return result;
		}

		private String getQuery(Map<String, String> queryFieldsToLabel) {
			List<String> queryFields = new List<String>();
			queryFields.addAll(queryFieldsToLabel.keySet());

			String query = 'SELECT ';
			query += String.join(queryFields, ',');
			query += ' ,EDM_ID_For_Comparator_gne__c';
			query += ' FROM ' + objectType;
			query += ' WHERE ' + parentField + ' = :parentId';
			query += ' ' + additionalWhere;
			System.debug(query);
			return query;
		}
	}

	private class DefaultQueryExecutor extends QueryExecutor {

		public DefaultQueryExecutor(String objectType, String parentField, String additionalWhere) {
			super(objectType, parentField, additionalWhere);
		}

		public override List<sObject> getRecordList(EDM_IABP_gne__c parent, Map<String, String> queryFieldsToLabel) {
			return executeQuery(parent, queryFieldsToLabel);
		}
	}

	private class PTDQueryExecutor extends QueryExecutor {

		public PTDQueryExecutor(String objectType, String parentField, String additionalWhere) {
			super(objectType, parentField, additionalWhere);
		}

		public override List<sObject> getRecordList(EDM_IABP_gne__c parent, Map<String, String> queryFieldsToLabel) {
			additionalWhere = setAdditionalWhereForExeSum(parent, additionalWhere);
			return executeQuery(parent, queryFieldsToLabel);
		}

		private String setAdditionalWhereForExeSum(EDM_IABP_gne__c parent, String additionalWhere) {
			if (shouldGetPTDSnaps(parent)) {
				additionalWhere = ' AND EDM_System_Type_gne__c = \'PTD_Snapshot\' ' + additionalWhere;
			}
			else {
				additionalWhere = ' AND EDM_System_Type_gne__c = null ' + additionalWhere;
			}

			return additionalWhere;
		}

		private Boolean shouldGetPTDSnaps(EDM_IABP_gne__c parent) {
			return parent.EDM_Executive_Summary_gne__c && (parent.EDM_ExeSum_Status_gne__c == 'Finalized' || parent.EDM_ExeSum_Status_gne__c == 'Complete');
		}
	}
}