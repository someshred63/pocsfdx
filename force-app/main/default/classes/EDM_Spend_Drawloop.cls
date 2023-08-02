global class EDM_Spend_Drawloop implements Loop.IApexDataSource {
	public Set<String> getGlobalDescribe() {
		return new Set<String>{
			'SpendInfo',
			'Venue',
			'Vendor',
			'Financials',
			'DailyMealAmountsAndAttendance',
			'NonHCPParticipants',
			'HCPEventSpend',
			'HCPParticipants',
			'HCPParticipantsInfo',
			'HCPParticipantsContactDetails',
			'HCPParticipantsAttendance',
			'HCPParticipantsTransactionsandOrganization'
		};
	}

	public Set<String> getChildRelationships(string objectName) {
		Set<String> childObjectNames = new Set<String>();
		if (objectName == 'HCPParticipantsInfo') {
			childObjectNames.add('HCPParticipantsAttendance');
			childObjectNames.add('HCPParticipantsContactDetails');
			childObjectNames.add('HCPParticipantsTransactionsandOrganization');
		}
		return childObjectNames;
	}

	public List<Loop.ExternalData.DataObject> describeObjects(List<string> objNames) {
		List<Loop.ExternalData.DataObject> output = new List<Loop.ExternalData.DataObject>();
		for (string objName : objNames) {
			List<Loop.ExternalData.FieldInfo> outputFields = new List<Loop.ExternalData.FieldInfo>();
			if (objName == 'SpendInfo') {
				outputFields.add(new Loop.ExternalData.FieldInfo('Canceled', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('AdvisoryBoardLead', Schema.DisplayType.STRING));
				outputFields.add(createFieldInfoForCurrency('TotalAdvisoryBoardCost'));
				outputFields.add(new Loop.ExternalData.FieldInfo('FileAttached', Schema.DisplayType.STRING));
			} else if (objName == 'Venue') {
				outputFields.add(new Loop.ExternalData.FieldInfo('Virtual', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('Name', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('Country', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('City', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('StateProvince', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('ZipPostalCode', Schema.DisplayType.STRING));
			} else if (objName == 'Vendor') {
				outputFields.add(new Loop.ExternalData.FieldInfo('CreatedByEmail', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('LastUpdatedByEmail', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('LogisticsVendorCode', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('ContentVendorCode', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('LogisticsVendorName', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('ContentVendorName', Schema.DisplayType.STRING));
			} else if (objName == 'Financials') {
				outputFields.add(new Loop.ExternalData.FieldInfo('Type', Schema.DisplayType.STRING));
				outputFields.add(createFieldInfoForCurrency('TotalCost'));
				outputFields.add(new Loop.ExternalData.FieldInfo('OverheadFees', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('HCPFees', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('Hotel', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('Meals', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('Travel', Schema.DisplayType.STRING));
			} else if (objName == 'DailyMealAmountsAndAttendance') {
				outputFields.add(new Loop.ExternalData.FieldInfo('EventDate', Schema.DisplayType.STRING));
				outputFields.add(createFieldInfoForCurrency('MealTotal'));
				outputFields.add(new Loop.ExternalData.FieldInfo('NumberOfMeals', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('PlannedAttendeeCountHCP', Schema.DisplayType.Integer));
				outputFields.add(new Loop.ExternalData.FieldInfo('PlannedAttendeeCountOther', Schema.DisplayType.Integer));
				outputFields.add(new Loop.ExternalData.FieldInfo('ActualAttendeeCountAttendedHCP', Schema.DisplayType.Integer));
				outputFields.add(new Loop.ExternalData.FieldInfo('ActualAttendeeCountAttendedOther', Schema.DisplayType.Integer));
				outputFields.add(new Loop.ExternalData.FieldInfo('ActualAttendeeCountConsumedHCP', Schema.DisplayType.Integer));
				outputFields.add(new Loop.ExternalData.FieldInfo('ActualAttendeeCountConsumedOther', Schema.DisplayType.Integer));
			} else if (objName == 'HCPEventSpend') {
				outputFields.add(createFieldInfoForCurrency('HCPOutOfPocketTotal'));
				outputFields.add(createFieldInfoForCurrency('HCPFeesTotal'));
				outputFields.add(createFieldInfoForCurrency('HCPEventLodgingTotal'));
				outputFields.add(createFieldInfoForCurrency('HCPEventMealTotal'));
				outputFields.add(createFieldInfoForCurrency('HCPEventTravelTotal'));
				outputFields.add(createFieldInfoForCurrency('HCPEventSpendTotal'));
			} else if (objName == 'NonHCPParticipants') {
				outputFields.add(createFieldInfoForCurrency('NonHCPFees'));
				outputFields.add(createFieldInfoForCurrency('Hotel'));
				outputFields.add(createFieldInfoForCurrency('Meals'));
				outputFields.add(createFieldInfoForCurrency('Travel'));
				outputFields.add(createFieldInfoForCurrency('Total'));
			} else if (objName == 'HCPParticipants') {
				outputFields.add(new Loop.ExternalData.FieldInfo('LastName', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('FirstName', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('Role', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('LastUpdated', Schema.DisplayType.DateTime));
			} else if (objName == 'HCPParticipantsInfo') {
				outputFields.add(new Loop.ExternalData.FieldInfo('Id', Schema.DisplayType.Id));
				outputFields.add(new Loop.ExternalData.FieldInfo('FirstName', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('MiddleName', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('LastName', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('LastUpdated', Schema.DisplayType.DateTime));
				outputFields.add(new Loop.ExternalData.FieldInfo('lastUpdatedByFormatted', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('NPI', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('ParticipantRole', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('LicenseNo', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('Suffix', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('LicenseState', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('Credential', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('MDMID', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('Profession', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('ClassificationClinical', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('ClassificationBusiness', Schema.DisplayType.STRING));
				outputFields.add(createFieldInfoForCurrency('AttendanceMealTotal'));
			} else if (objName == 'HCPParticipantsContactDetails') {
				outputFields.add(new Loop.ExternalData.FieldInfo('Country', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('PrimaryStreetAddress', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('PrimaryStreetAddress2', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('City', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('StateProvince', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('PostalCode', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('BusinessPhone', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('Email', Schema.DisplayType.STRING));
				Loop.ExternalData.FieldInfo outputInfo = new Loop.ExternalData.FieldInfo('Participant', Schema.DisplayType.REFERENCE);
				outputInfo.referenceTo = 'HCPParticipantsInfo';
				outputFields.add(outputInfo);
			} else if (objName == 'HCPParticipantsAttendance') {
				outputFields.add(new Loop.ExternalData.FieldInfo('Attended', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('Date', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('MealStatus', Schema.DisplayType.STRING));
				outputFields.add(createFieldInfoForCurrency('Amount'));
				Loop.ExternalData.FieldInfo outputInfo = new Loop.ExternalData.FieldInfo('Participant', Schema.DisplayType.REFERENCE);
				outputInfo.referenceTo = 'HCPParticipantsInfo';
				outputFields.add(outputInfo);
			} else if (objName == 'HCPParticipantsTransactionsandOrganization') {
				outputFields.add(createFieldInfoForCurrency('HCPTravel'));
				outputFields.add(createFieldInfoForCurrency('HCPLodging'));
				outputFields.add(createFieldInfoForCurrency('OOPHCPTravel'));
				outputFields.add(createFieldInfoForCurrency('OOPHCPLodging'));
				outputFields.add(createFieldInfoForCurrency('OOPHCPMeals'));
				outputFields.add(createFieldInfoForCurrency('OOPHCPOther'));
				outputFields.add(createFieldInfoForCurrency('HCPFees'));
				outputFields.add(new Loop.ExternalData.FieldInfo('HCPFeePaidTo', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('OrganizationName', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('Country', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('Address', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('City', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('StateProvince', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('PostalCode', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('CharitableOrganization', Schema.DisplayType.STRING));
				outputFields.add(new Loop.ExternalData.FieldInfo('TIN', Schema.DisplayType.STRING));
				Loop.ExternalData.FieldInfo outputInfo = new Loop.ExternalData.FieldInfo('Participant', Schema.DisplayType.REFERENCE);
				outputInfo.referenceTo = 'HCPParticipantsInfo';
				outputFields.add(outputInfo);
			}


			
			output.add(new Loop.ExternalData.DataObject(objName, outputFields));
		}
		return output;
	}

	private Loop.ExternalData.FieldInfo createFieldInfoForCurrency(String fieldName) {
		Loop.ExternalData.FieldInfo outputInfo = new Loop.ExternalData.FieldInfo(fieldName, Schema.DisplayType.CURRENCY);
		outputInfo.scale = 2;
		return outputInfo;
	}

	public Loop.ExternalData.QueryResultSet query(Loop.ExternalData.QueryRequestInfo requestInfo) {
		Loop.ExternalData.QueryResultSet results = new Loop.ExternalData.QueryResultSet();

		EDM_Spend_Ex spendEx = retrieveData(requestInfo.RecordId);
		List<EDM_Spend_Participant> hcpParticipantsDetails = retrieveParticipantsData(spendEx.participants, spendEx.currentIABP.Name);

		List<String> objectNames = Test.isRunningTest() ? new List<String>(getGlobalDescribe()) : requestInfo.GetObjectNames();
		for (String objectName : objectNames) {
			if (objectName == 'SpendInfo') {
				results.add(getSpendInfo(objectName, spendEx));
			} else if (objectName == 'Venue') {
				results.add(getVenue(objectName, spendEx.spend.virtualVenue, spendEx.spend.zipPostalCode, spendEx.currentIABP));
			} else if (objectName == 'Vendor') {
				results.add(getVendor(objectName, spendEx));
			} else if (objectName == 'Financials') {
				results.add(getFinancials(objectName, spendEx.financials));
			} else if (objectName == 'DailyMealAmountsAndAttendance') {
				results.add(getDailyMealAmountsAndAttendance(objectName, spendEx.spend.dailyMeals));
			} else if (objectName == 'HCPEventSpend') {
				results.add(getHCPEventSpend(objectName, spendEx.spend.hcpEventSpend));
			} else if (objectName == 'NonHCPParticipants') {
				results.add(getNonHCPParticipants(objectName, spendEx.edmSpend));
			} else if (objectName == 'HCPParticipants') {
				results.add(getHCPParticipants(objectName, spendEx.participants));
			} else if (objectName == 'HCPParticipantsInfo') {
				results.add(getHCPParticipantsInfo(objectName, hcpParticipantsDetails));
			} else if (objectName == 'HCPParticipantsContactDetails') {
				results.add(getHCPParticipantsContactDetails(objectName, hcpParticipantsDetails));
			} else if (objectName == 'HCPParticipantsAttendance') {
				results.add(getHCPParticipantsAttendance(objectName, hcpParticipantsDetails));
			} else if (objectName == 'HCPParticipantsTransactionsandOrganization') {
				results.add(getHCPParticipantsTransactionsandOrganization(objectName, hcpParticipantsDetails));
			}
		}

		System.debug(requestInfo.RecordId);
		System.debug(getHCPParticipantsInfo('HCPParticipantsInfo', hcpParticipantsDetails));
		System.debug(getHCPParticipantsAttendance('HCPParticipantsAttendance', hcpParticipantsDetails));

		return results;
	}

	private Loop.ExternalData.QueryResult getSpendInfo(String objectName, EDM_Spend_Ex spendEx ) {
		Loop.ExternalData.QueryResult results = new Loop.ExternalData.QueryResult(objectName, 
				new List<String> {'Canceled', 'AdvisoryBoardLead', 'TotalAdvisoryBoardCost',
						'FileAttached'});
		String canceled = 'No';
		if (spendEx.currentIABP.EDM_Canceled_gne__c) {
			canceled = 'Yes - ' + spendEx.edmSpend.EDM_Cancellation_Type_gne__c;
		}

		results.rows.add(new List<String>{
				canceled,
				spendEx.getNonVendorABLeadName(),
				String.valueOf(spendEx.financials.getTotalAdvisoryBoardCost()),
				spendEx.getAttachment().Id == null ? 'No' : 'Yes'});
		return results;
	}

	private Loop.ExternalData.QueryResult getVenue(String objectName, Boolean virtualVenue, String zipPostalCode, EDM_IABP_gne__c currentIABP) {
		Loop.ExternalData.QueryResult results = new Loop.ExternalData.QueryResult(objectName, 
				new List<String> {'Virtual', 'Name', 'Country', 'City', 'StateProvince', 'ZipPostalCode' });
		results.rows.add(new List<String>{
				virtualVenue ? 'Yes' : 'No',
				currentIABP.EDM_Venue_gne__c,
				currentIABP.EDM_Country_gne__c,
				currentIABP.EDM_City_gne__c,
				currentIABP.EDM_State_gne__c,
				(String.isNotBlank(currentIABP.EDM_Zip_gne__c) ? currentIABP.EDM_Zip_gne__c : zipPostalCode) });
		return results;
	}

	private Loop.ExternalData.QueryResult getVendor(String objectName, EDM_Spend_Ex spendEx) {
		Loop.ExternalData.QueryResult results = new Loop.ExternalData.QueryResult(objectName, 
				new List<String> { 'CreatedByEmail', 'LastUpdatedByEmail', 'LogisticsVendorCode', 'ContentVendorCode',
						'LogisticsVendorName', 'ContentVendorName' });
		//LogisticsVendorName and ContentVendorName will be changed from NULL to Genentech in SpendEx controller and not saved to database, but only displayed on page & drawloop doc
		results.rows.add(new List<String>{
				spendEx.edmSpend.CreatedBy.Email,
				spendEx.edmSpend.LastModifiedBy.Email,
				spendEx.spend.logisticsVendorCode, 
				spendEx.spend.contentVendorCode,
				spendEx.currentIABP.EDM_Log_Vendor_Company_Name_gne__c, 
				spendEx.currentIABP.EDM_Cont_Vendor_Company_Name_gne__c});
		return results;
	}

	private Loop.ExternalData.QueryResult getFinancials(String objectName, EDM_Spend_Ex.Financials financials) {
		Loop.ExternalData.QueryResult results = new Loop.ExternalData.QueryResult(objectName, 
				new List<String> { 'Type', 'TotalCost', 'OverheadFees', 'HCPFees', 'Hotel', 'Meals', 'Travel' });
		for (EDM_Spend_Financial_gne__c fin : financials.items) {
			results.rows.add(new List<String>{
				fin.EDM_Type_gne__c,
				String.valueOf(fin.EDM_Total_Cost_gne__c),
				fin.EDM_OverheadFees_gne__c ? 'Y' : '',
				fin.EDM_HCP_Fees_gne__c ? 'Y' : '',
				fin.EDM_Hotel_gne__c ? 'Y' : '',
				fin.EDM_Meals_gne__c ? 'Y' : '',
				fin.EDM_Travel_gne__c ? 'Y' : '' });
		}
		
		return results;
	}


	private Loop.ExternalData.QueryResult getDailyMealAmountsAndAttendance(String objectName, List<EDM_Spend_Ex.DailyMeals> dailyMeals) {
		Loop.ExternalData.QueryResult results = new Loop.ExternalData.QueryResult(objectName, 
				new List<String> { 'EventDate', 'MealTotal',
						'NumberOfMeals', 'PlannedAttendeeCountHCP', 'PlannedAttendeeCountOther', 
						'ActualAttendeeCountAttendedHCP', 'ActualAttendeeCountAttendedOther',
						'ActualAttendeeCountConsumedHCP', 'ActualAttendeeCountConsumedOther' });
 		for (EDM_Spend_Ex.DailyMeals dailyMeal : dailyMeals) {
			DateTime dt = DateTime.newInstance(dailyMeal.eventDate.year(), dailyMeal.eventDate.month(), dailyMeal.eventDate.day());
			results.rows.add(new List<String>{ dt.format('M/dd/yyyy'), 
					String.valueOf(dailyMeal.edmSpendAttendanceRec.EDM_Meal_Total_gne__c),
					dailyMeal.numberOfMeals, 
					String.valueOf(dailyMeal.edmSpendAttendanceRec.EDM_Planned_Attendee_HCP_Count_gne__c),
					String.valueOf(dailyMeal.edmSpendAttendanceRec.EDM_Planned_Attendee_Other_Count_gne__c),
					String.valueOf(dailyMeal.actualAttendeeAttendedCount.hcps),
					//String.valueOf(dailyMeal.actualAttendeeAttendedCount.other),
					String.valueOf(dailyMeal.edmSpendAttendanceRec.EDM_Actual_Attendee_Other_Count_gne__c),
					String.valueOf(dailyMeal.actualAttendeeConsumedCount.hcps),
					String.valueOf(dailyMeal.actualAttendeeConsumedCount.other) });
		}

		return results;
	}


	private Loop.ExternalData.QueryResult getHCPEventSpend(String objectName, EDM_Spend_Ex.HcpEventSpend hcpEventSpend) {
		Loop.ExternalData.QueryResult results = new Loop.ExternalData.QueryResult(objectName, 
				new List<String> {'HCPOutOfPocketTotal', 'HCPFeesTotal', 'HCPEventLodgingTotal', 'HCPEventMealTotal', 'HCPEventTravelTotal', 'HCPEventSpendTotal'});
		results.rows.add(new List<String>{
				String.valueOf(hcpEventSpend.summarySpends.get('EVTOOP')),
				String.valueOf(hcpEventSpend.summarySpends.get('EVTFEES')),
				String.valueOf(hcpEventSpend.summarySpends.get('HOTEL')),
				String.valueOf(hcpEventSpend.summarySpends.get('EVTMEALS')),
				String.valueOf(hcpEventSpend.summarySpends.get('EVTHCPTRVL')),
				String.valueOf(hcpEventSpend.summarySpends.get('TOTALEVENT')) });
		return results;
	}

	private Loop.ExternalData.QueryResult getNonHCPParticipants(String objectName, EDM_Spend_gne__c edmSpend) {
		Loop.ExternalData.QueryResult results = new Loop.ExternalData.QueryResult(objectName, 
				new List<String> { 'NonHCPFees', 'Hotel', 'Meals', 'Travel', 'Total'});
		results.rows.add(new List<String>{ 
				String.valueOf(edmSpend.EDM_Non_HCP_Fees_gne__c),
				String.valueOf(edmSpend.EDM_Non_HCP_Hotel_gne__c),
				String.valueOf(edmSpend.EDM_Non_HCP_Meals_gne__c),
				String.valueOf(edmSpend.EDM_Non_HCP_Travel_gne__c),
				String.valueOf(edmSpend.EDM_Non_HCP_Total_gne__c)});
		return results;
	}

	private Loop.ExternalData.QueryResult getHCPParticipants(String objectName, List<EDM_Attendee_gne__c> participants) {
		Loop.ExternalData.QueryResult results = new Loop.ExternalData.QueryResult(objectName, 
				new List<String> { 'LastName', 'FirstName', 'Role', 'LastUpdated'});
		for (EDM_Attendee_gne__c participant : participants) {
			results.rows.add(new List<String>{ participant.EDM_Account_gne__r.LastName,
					participant.EDM_Account_gne__r.FirstName,
					participant.EDM_Role_gne__c,
					participant.LastModifiedDate.format('M/dd/yyyy')});
		}
		return results;
	}

	private Loop.ExternalData.QueryResult getHCPParticipantsInfo(String objectName, List<EDM_Spend_Participant> hcpParticipantsDetails) {
		Loop.ExternalData.QueryResult results = new Loop.ExternalData.QueryResult(objectName, 
				new List<String> {'Id', 'FirstName', 'MiddleName', 'LastName', 'LastUpdated', 'lastUpdatedByFormatted', 'NPI', 'ParticipantRole', 'LicenseNo', 'Suffix', 'LicenseState', 'Credential', 'MDMID', 'Profession', 'ClassificationClinical', 'ClassificationBusiness', 'AttendanceMealTotal'});
		for (EDM_Spend_Participant hcpParticipantsDetail : hcpParticipantsDetails) {
			results.rows.add(new List<String>{
					hcpParticipantsDetail.attendee.Id,
					hcpParticipantsDetail.account.FirstName,
					hcpParticipantsDetail.account.Middle_gne__c,
					hcpParticipantsDetail.account.LastName,
					hcpParticipantsDetail.attendee.LastModifiedDate.format('M/dd/yyyy'),
					hcpParticipantsDetail.getLastUpdatedByFormatted(),
					hcpParticipantsDetail.account.NPI_vod__c,
					hcpParticipantsDetail.attendee.EDM_Role_gne__c,
					hcpParticipantsDetail.license.License_Number_gne__c,
					hcpParticipantsDetail.account.Suffix_vod__c,
					hcpParticipantsDetail.license.License_State_gne__c,
					String.isBlank(hcpParticipantsDetail.account.Credentials_gne__c) ? 'Other' : hcpParticipantsDetail.account.Credentials_gne__c,
					hcpParticipantsDetail.account.MDMID_gne__c,
					String.isBlank(hcpParticipantsDetail.account.Professional_Type_gne__c) ? 'Other' : hcpParticipantsDetail.account.Professional_Type_gne__c,
					hcpParticipantsDetail.account.EDM_Clinical_Classification_gne__c,
					hcpParticipantsDetail.account.EDM_Business_Classification_gne__c,
					String.valueOf(hcpParticipantsDetail.getTotalAttendanceAmount())});
		}
		return results;
	}

	private Loop.ExternalData.QueryResult getHCPParticipantsContactDetails(String objectName, List<EDM_Spend_Participant> hcpParticipantsDetails) {
		Loop.ExternalData.QueryResult results = new Loop.ExternalData.QueryResult(objectName, 
				new List<String> {'Country', 'PrimaryStreetAddress', 'PrimaryStreetAddress2', 'City', 'StateProvince', 'PostalCode', 'BusinessPhone', 'Email', 'Participant'});
		for (EDM_Spend_Participant hcpParticipantsDetail : hcpParticipantsDetails) {
			results.rows.add(new List<String>{ 
					hcpParticipantsDetail.primaryAddress.Country_gen__c,
					hcpParticipantsDetail.primaryAddress.Name,
					hcpParticipantsDetail.primaryAddress.Address_line_2_vod__c,
					hcpParticipantsDetail.primaryAddress.City_vod__c,
					hcpParticipantsDetail.primaryAddress.State_vod__c,
					hcpParticipantsDetail.primaryAddress.Zip_vod__c,
					hcpParticipantsDetail.account.Phone,
					hcpParticipantsDetail.primaryAddress.Email_gne__c,
					hcpParticipantsDetail.attendee.Id});
		}
		return results;
	}


	private Loop.ExternalData.QueryResult getHCPParticipantsAttendance(String objectName, List<EDM_Spend_Participant> hcpParticipantsDetails) {
		Loop.ExternalData.QueryResult results = new Loop.ExternalData.QueryResult(objectName, 
				new List<String> {'Attended', 'Date', 'MealStatus', 'Amount', 'Participant'});
		for (EDM_Spend_Participant hcpParticipantsDetail : hcpParticipantsDetails) {
			if (hcpParticipantsDetail.attendance.isEmpty()) {
				results.rows.add(new List<String>{'', '', '', '0', hcpParticipantsDetail.attendee.Id});
			} else {
				for (EDM_Spend_Participant.Attendance attendance : hcpParticipantsDetail.attendance) {
					DateTime dt = DateTime.newInstance(attendance.attDate.year(), attendance.attDate.month(), attendance.attDate.day());
					results.rows.add(new List<String>{
						attendance.attended ? 'Yes' : 'No',
						dt.format('M/dd/yyyy'),
						attendance.mealStatus == 'NOMLPRVD' ? 'No meal' : attendance.mealStatus == 'CONSUMED' ? 'Consumed' : attendance.mealStatus,
						String.valueOf(attendance.amount),
						hcpParticipantsDetail.attendee.Id});
				}
			}
		}


		return results;
	}

	private Loop.ExternalData.QueryResult getHCPParticipantsTransactionsandOrganization(String objectName, List<EDM_Spend_Participant> hcpParticipantsDetails) {
		Loop.ExternalData.QueryResult results = new Loop.ExternalData.QueryResult(objectName, 
				new List<String> {'HCPTravel', 'HCPLodging', 'OOPHCPTravel', 'OOPHCPLodging', 'OOPHCPMeals', 'OOPHCPOther', 'HCPFees', 'HCPFeePaidTo',
				'OrganizationName', 'Country', 'Address', 'City', 'StateProvince', 'PostalCode', 'CharitableOrganization', 'TIN', 
				 'Participant'});
		for (EDM_Spend_Participant hcpParticipantsDetail : hcpParticipantsDetails) {
			results.rows.add(new List<String>{ 
					String.valueOf(hcpParticipantsDetail.proxyInputsForHCP.EDM_Non_HCP_Travel_gne__c),
					String.valueOf(hcpParticipantsDetail.proxyInputsForHCP.EDM_Non_HCP_Hotel_gne__c),
					String.valueOf(hcpParticipantsDetail.proxyInputsForOopHCP.EDM_Non_HCP_Travel_gne__c),
					String.valueOf(hcpParticipantsDetail.proxyInputsForOopHCP.EDM_Non_HCP_Hotel_gne__c),
					String.valueOf(hcpParticipantsDetail.proxyInputsForOopHCP.EDM_Non_HCP_Meals_gne__c),
					String.valueOf(hcpParticipantsDetail.proxyInputsForOopHCP.EDM_Non_HCP_Fees_gne__c),
					String.valueOf(hcpParticipantsDetail.proxyInputsForHCP.EDM_Non_HCP_Fees_gne__c),
					hcpParticipantsDetail.hcpFeesPaidTo,
					hcpParticipantsDetail.feeOrg.name != null ? hcpParticipantsDetail.feeOrg.name : '',
					hcpParticipantsDetail.feeOrg.country != null ? hcpParticipantsDetail.feeOrg.country : '',
					hcpParticipantsDetail.feeOrg.address != null ? hcpParticipantsDetail.feeOrg.address : '',
					hcpParticipantsDetail.feeOrg.city != null ? hcpParticipantsDetail.feeOrg.city : '',
					hcpParticipantsDetail.feeOrg.stateProvince != null ? hcpParticipantsDetail.feeOrg.stateProvince : '',
					hcpParticipantsDetail.feeOrg.postalCode  != null ? hcpParticipantsDetail.feeOrg.postalCode : '',
					hcpParticipantsDetail.feeOrg.charitableOrg != null ? (hcpParticipantsDetail.feeOrg.charitableOrg ? 'Yes' : 'No') : '',
					hcpParticipantsDetail.feeOrg.tin != null ? hcpParticipantsDetail.feeOrg.tin : '',
					hcpParticipantsDetail.attendee.Id});
		}
		return results;
	}

	private static EDM_Spend_Ex retrieveData(Id spendID) {
		EDM_Spend_gne__c edmSpend = [SELECT EDM_Parent_IABP_gne__c FROM EDM_Spend_gne__c WHERE id =:spendID LIMIT 1];

		EDM_IABP_gne__c iabp = [ 
				SELECT Id, EDM_Start_Date_gne__c, EDM_End_Date_gne__c,
				Name, EDM_Event_Name_gne__c, EDM_Brand_gne__c,
				EDM_Canceled_gne__c, EDM_Meeting_Approach_gne__c, 
				EDM_City_gne__c, EDM_State_gne__c, EDM_Country_gne__c, EDM_Venue_gne__c,
				EDM_Parent_AABP_gne__c,
				EDM_Log_Vendor_Company_Name_gne__c, EDM_Cont_Vendor_Company_Name_gne__c, 
				EDM_Primary_AB_Lead_gne__c, EDM_Secondary_AB_Lead_gne__c, EDM_Third_AB_Lead_gne__c, EDM_Zip_gne__c
				FROM EDM_IABP_gne__c WHERE id = :edmSpend.EDM_Parent_IABP_gne__c LIMIT 1];
		ApexPages.StandardController stdIabp = new ApexPages.StandardController(iabp);
		return new EDM_Spend_Ex(stdIabp, false);
	}

	private static List<EDM_Spend_Participant> retrieveParticipantsData(List<EDM_Attendee_gne__c> attendees, String currentIABPName) {
		List<EDM_Spend_Participant> hcpParticipantsDetails = new List<EDM_Spend_Participant>();
		Map<Id, Account> accountsById  = retrieveAccounts(attendees);
		Map<String, List<CORE_Pub_License__c>> licensesByMdmId = retrieveLicenses(accountsById.values());
		Map<String, EDM_Spend_Participant.JsonParticipantReadWrapper> dataContainer = readAllSpendParticipantsInfoFromVDST(currentIABPName);

		for (EDM_Attendee_gne__c attendee : retrieveEDMAttendeeWithAdditionalsColumns(attendees)) {
			Account acc = accountsById.get(attendee.EDM_Account_gne__c);
			hcpParticipantsDetails.add(new EDM_Spend_Participant(attendee, acc, 
					licensesByMdmId.get(acc.MDMID_gne__c), dataContainer.get(attendee.Id)));
		}

		return hcpParticipantsDetails;
	}

	private static Map<Id, Account> retrieveAccounts(List<EDM_Attendee_gne__c> attendees) {
		Set<Id> accountIds = new Set<Id>();
		for (EDM_Attendee_gne__c attendee : attendees) {
			accountIds.add(attendee.EDM_Account_gne__c);
		}
		return new Map<Id, Account>(EDM_Spend_Utils.getAccountsWithAddressAndLicensesAndAffiliation(accountIds));
	}

	private static Map<String, List<CORE_Pub_License__c>> retrieveLicenses(List<Account> accounts) {
		Set<String> mdmIds = new Set<String>();
		for (Account acc : accounts) {
			mdmIds.add(acc.MDMID_gne__c);
		}
		return EDM_Spend_Utils.getLicensesByMdmId(mdmIds);
	}

	private static List<EDM_Attendee_gne__c> retrieveEDMAttendeeWithAdditionalsColumns(List<EDM_Attendee_gne__c> attendees) {
		Set<Id> attendeeIds = new Set<Id>();
		for (EDM_Attendee_gne__c attendee : attendees) {
			attendeeIds.add(attendee.Id);
		}
		return EDM_Spend_Utils.getAttendees(attendeeIds);
	}

	private static Map<String, EDM_Spend_Participant.JsonParticipantReadWrapper> readAllSpendParticipantsInfoFromVDST(String currentIABPName) {
		String jsonString = VDST_API.readAllParticipantsSpendData(currentIABPName);
		System.debug('readAllParticipantsSpendData: ' + jsonString);
		Map<String, EDM_Spend_Participant.JsonParticipantReadWrapper> dataContainer = parseStringToParticipantReadWrappers(jsonString);
		System.debug(dataContainer);

		return dataContainer;
	}

	private static Map<String, EDM_Spend_Participant.JsonParticipantReadWrapper> parseStringToParticipantReadWrappers(String jsonString) {
		return (Map<String, EDM_Spend_Participant.JsonParticipantReadWrapper>) System.JSON.deserialize(jsonString, Map<String, EDM_Spend_Participant.JsonParticipantReadWrapper>.class);
	}
}