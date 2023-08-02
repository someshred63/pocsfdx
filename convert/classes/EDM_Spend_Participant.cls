public with sharing class EDM_Spend_Participant {
	public Account account { get; private set; }
	public Address_vod__c primaryAddress { get; private set; }
	public Account primaryAffiliatedHCO { get; private set; }
	public EDM_Attendee_gne__c attendee { get; private set; }   
	public CORE_Pub_License__c license { get; private set; }
	public FeeOrganization feeOrg { get; set; }

	public List<Attendance> attendance { get; set; }
	public String hcpFeesPaidTo { get; set; }

	public EDM_Spend_gne__c proxyInputsForHCP { get; set; }
	public EDM_Spend_gne__c proxyInputsForOopHCP { get; set; }

	public String errorPopupMessage { get; set; }

	private enum PageMode { VIEW, EDIT }
	private PageMode currentPageMode;

	private IEDM_VDST_Participant vdstParticipantApi;

	public EDM_Spend_Participant() {
		this(null, null);
	}

	public EDM_Spend_Participant(String attendeeId, List<EDM_Spend_Ex.DailyMeals> dailyMeals) {
		this(attendeeId, dailyMeals, new EDM_VDST_ParticipantAPI());
	}

	public EDM_Spend_Participant(String attendeeId, List<EDM_Spend_Ex.DailyMeals> dailyMeals, IEDM_VDST_Participant vdstParticipantApi) {
		currentPageMode = (ApexPages.currentPage() == null || ApexPages.currentPage().getUrl().containsIgnoreCase('EDM_Spend_View_Layout')) ? PageMode.VIEW  : PageMode.EDIT;
		this.vdstParticipantApi = vdstParticipantApi;
		initProperties();

		if (String.isNotBlank(attendeeId)) {
			List<EDM_Attendee_gne__c> attendees = EDM_Spend_Utils.getAttendees(attendeeId);

			if (listIsNotNullNorEmpty(attendees)) {
				this.attendee = attendees[0];
				List<Account> accounts = EDM_Spend_Utils.getAccountsWithAddressAndLicensesAndAffiliation(attendee.EDM_Account_gne__c);

				if (listIsNotNullNorEmpty(accounts)) {
					this.account = accounts[0];
					List<CORE_Pub_License__c> licenses = EDM_Spend_Utils.getLicenses(this.account);

					if (this.account != null) {
						setAddress();
						setLicense(licenses);
						setAffiliatedHCOFromDB();
						setCredentialAndProffessionToOtherIfBlank();
					}
				}
			}

			readSpendParticipantInfoFromVDST(attendeeId, this.vdstParticipantApi);
		}

		if (dailyMeals != null && this.attendance.isEmpty()) {
			this.attendance = populateAttendance(dailyMeals);
		}
	}

	public EDM_Spend_Participant(EDM_Attendee_gne__c attendeeRec, Account accountRec, List<CORE_Pub_License__c> licenses, JsonParticipantReadWrapper readSpendParticipant) {
		currentPageMode = PageMode.VIEW;
		initProperties();

  
		this.attendee = attendeeRec;
		this.account = accountRec;

		if (this.account != null) {
			setAddress();
			setLicense(licenses);
		}

		if (readSpendParticipant != null) {
			convertDataFromVDST(readSpendParticipant);
		}
	}

	private void readSpendParticipantInfoFromVDST(String attendeeId, IEDM_VDST_Participant vdstParticipantApi) {
		String jsonString = vdstParticipantApi.readParticipantSpendData(attendeeId);//VDST_API.readParticipantSpendData(attendeeId); 
		System.debug(jsonString);
		JsonParticipantReadWrapper readSpendParticipant = parseStringToParticipantReadWrapper(jsonString);
		System.debug(readSpendParticipant);

		if (readSpendParticipant == null) {
			return;
		}

		convertDataFromVDST(readSpendParticipant);
	}

	private void convertDataFromVDST(JsonParticipantReadWrapper readSpendParticipant) {
		if (readSpendParticipant.participant_spends != null) {
			for (ParticipantSpends participant_spend : readSpendParticipant.participant_spends) {
				if (participant_spend.code == 'HCPTRVL') {
					proxyInputsForHCP.EDM_Non_HCP_Travel_gne__c = participant_spend.amount;
				} else if (participant_spend.code == 'HCPLODGNG') {
					proxyInputsForHCP.EDM_Non_HCP_Hotel_gne__c = participant_spend.amount;
				} else if (participant_spend.code == 'OOPTRVL') {
					proxyInputsForOopHCP.EDM_Non_HCP_Travel_gne__c = participant_spend.amount;
				} else if (participant_spend.code == 'OOPLODGNG') {
					proxyInputsForOopHCP.EDM_Non_HCP_Hotel_gne__c = participant_spend.amount;
				} else if (participant_spend.code == 'OOPMEALS') {
					proxyInputsForOopHCP.EDM_Non_HCP_Meals_gne__c = participant_spend.amount;
				} else if (participant_spend.code == 'OOPOTHR') {
					proxyInputsForOopHCP.EDM_Non_HCP_Fees_gne__c = participant_spend.amount;
				} else if (participant_spend.code == 'HONORARIA') {
					proxyInputsForHCP.EDM_Non_HCP_Fees_gne__c = participant_spend.amount;
				}
			}
		}

		if (readSpendParticipant.att_data != null) {
			for (AttData att : readSpendParticipant.att_data) {
				this.attendance.add(new Attendance(att));
			}
		}

		if (readSpendParticipant.organization_data != null) {
			hcpFeesPaidTo = 'Organization';
			feeOrg = new FeeOrganization(readSpendParticipant.organization_data);
		}
		else {
			hcpFeesPaidTo = 'Individual';
			if (currentPageMode == PageMode.VIEW) {
				feeOrg = new FeeOrganization();
			}
		}
	}

	public String getLastUpdatedByFormatted() {
		return String.format('{0} {1} ({2})', new List<String> {attendee.LastModifiedBy.FirstName, attendee.LastModifiedBy.LastName, attendee.LastModifiedBy.Email});
	}

	public Decimal getTotalAttendanceAmount() {
		Decimal total = 0;
		if (attendance != null) {
			for (Attendance item : attendance) {
				total += item.amount != null ? item.amount : 0;
			}
		}
		return total;
	}

	@testVisible
	private List<Attendance> populateAttendance(List<EDM_Spend_Ex.DailyMeals> dailyMeals) {
		List<Attendance> result = new List<Attendance>();
		for (EDM_Spend_Ex.DailyMeals meal : dailyMeals) {
			result.add(new Attendance(meal.eventDate, 0));
		}
		return result;
	}

	private void initProperties() {
		this.account = new Account();
		this.attendee = new EDM_Attendee_gne__c();
		this.primaryAddress = new Address_vod__c();
		this.primaryAffiliatedHCO = new Account();
		this.feeOrg = new FeeOrganization();
		this.license = new CORE_Pub_License__c();
		this.attendance = new List<Attendance>();
		this.errorPopupMessage = null;
		this.proxyInputsForHCP = new EDM_Spend_gne__c();
		this.proxyInputsForOopHCP = new EDM_Spend_gne__c();
	}

	private void setAddress() {
		if (listIsNotNullNorEmpty(this.account.Address_vod__r)) {
			primaryAddress = this.account.Address_vod__r[0];
		}        
	}

	private void setLicense(List<CORE_Pub_License__c> licenses) {
		if (listIsNotNullNorEmpty(licenses)) {
			Boolean foundLicenseMatchingAddress = false;
			for (CORE_Pub_License__c lic : licenses) {
				if (lic.License_State_gne__c == primaryAddress.State_vod__c) {
					this.license = lic;
					foundLicenseMatchingAddress = true;
				}
			}
			if (!foundLicenseMatchingAddress) {
				license = licenses[0];
			}
		}
	}

	private void setAffiliatedHCOFromDB() {
		if (listIsNotNullNorEmpty(this.account.Affiliation_vod__r)) {
			List<Account> affiliatedHCOs = EDM_Spend_Utils.getAccountsWithAddressAndLicensesAndAffiliation(this.account.Affiliation_vod__r[0].To_Account_vod__c);
			if (listIsNotNullNorEmpty(affiliatedHCOs)) {
				primaryAffiliatedHCO = affiliatedHCOs[0];
				this.feeOrg.name = primaryAffiliatedHCO.Name;
				this.feeOrg.npi = primaryAffiliatedHCO.NPI_vod__c;
				if (listIsNotNullNorEmpty(primaryAffiliatedHCO.Address_vod__r)) {
					this.feeOrg.dea = primaryAffiliatedHCO.Address_vod__r[0].DEA_vod__c;
				}
				this.feeOrg.mdmId = primaryAffiliatedHCO.MDMID_gne__c;
				setAffiliatedHCPAddress();
			}
		}
	}

	private void setAffiliatedHCPAddress() {
		if (listIsNotNullNorEmpty(primaryAffiliatedHCO.Address_vod__r)) {
			this.feeOrg.country       = EDM_Spend_Participant.getCountryCapitalizedAsInGSSPMapping(primaryAffiliatedHCO.Address_vod__r[0].Country_gen__c);       
			this.feeOrg.city          = primaryAffiliatedHCO.Address_vod__r[0].City_vod__c;
			this.feeOrg.address       = primaryAffiliatedHCO.Address_vod__r[0].Name;
			this.feeOrg.postalCode    = primaryAffiliatedHCO.Address_vod__r[0].Zip_vod__c;

			Map<String, String> statesByCode = VDST_API.getStateValues();
			this.feeOrg.stateProvince = statesByCode.get(primaryAffiliatedHCO.Address_vod__r[0].State_vod__c);
		}
	}

	private void setCredentialAndProffessionToOtherIfBlank() {
		if (String.isBlank(this.account.Credentials_gne__c)) {
			this.account.Credentials_gne__c = 'Other';
		}
		if (String.isBlank(this.account.Professional_Type_gne__c)) {
			this.account.Professional_Type_gne__c = 'Other';
		}
	}

	private Boolean listIsNotNullNorEmpty(List<Object> listToCheck) {
		return listToCheck != null && listToCheck.size() > 0;
	}


	public class Attendance implements Comparable {
		public Boolean attended { get; set; }
		public Date attDate { get; set; }
		public String mealStatus { get; set;}
		public Decimal amount { get; set; }

		public Attendance(Date eventDate, Decimal amount) {
			this.attDate = eventDate;
			this.amount = amount;
		}

		public Attendance(AttData att) {
			this.attDate = att.event_date;
			this.mealStatus = att.consumption_status;
			this.attended = att.att_status == 'ATND';
			this.amount = att.meal_amount;
		}

		public String getDateFormatted() {
			return attDate.format();
		}

		public Integer compareTo(Object compareTo) {
	        Attendance compareToAtt = (Attendance)compareTo;
	        if (attDate < compareToAtt.attDate) return -1;
	        if (attDate > compareToAtt.attDate) return 1;
	        return 0;        
	    }

	}

	public class FeeOrganization {
		public String name { get; set; }
		public Boolean charitableOrg { get; set; }
		public String country { get; set; }
		public String address { get; set; }
		public String city { get; set; }
		public String stateProvince { get; set; }
		public String postalCode { get; set; }      
		public String tin { get; set; }
		public String npi { get; set; }
		public String dea { get; set; }
		public String mdmId { get; set; }

		public FeeOrganization() {
		}

		public FeeOrganization(OrganizationData orgData) {
			Map<String, String> countriesByCode = VDST_API.getCountryValues();
			Map<String, String> statesByCode = VDST_API.getStateValues();

			this.name = orgData.org_name;
			this.tin = orgData.tin;
			this.charitableOrg = orgData.charitable_org;
			this.npi = orgData.npi;
			this.dea = orgData.dea;
			this.mdmId = orgData.mdm_id;
			if (countriesByCode.containsKey(orgData.address_country)) {
				this.country = countriesByCode.get(orgData.address_country);
			} else {
				this.country = orgData.address_country;
			}
			this.address = orgData.address_street;
			this.city = orgData.address_city;
			if (statesByCode.containsKey(orgData.address_state)) {
				this.stateProvince = statesByCode.get(orgData.address_state);
			} else {
				this.stateProvince = orgData.address_state;
			}
			this.postalCode = orgData.address_zip;
		}
	}


	public Boolean saveToVDST(String abm_event_id) {
		errorPopupMessage = null;

		JsonParticipantWrapper wrapper = new JsonParticipantWrapper(abm_event_id, attendee,
				account, primaryAddress, license, primaryAffiliatedHCO);

		if (hcpFeesPaidTo == 'Organization') {
			wrapper.organization_data = new OrganizationData(feeOrg);
		}

		wrapper.participant_spends = getConvertedParticipantSpends();
		wrapper.att_data = getConvertedAttData();

		String participantWrapperJSON = wrapper.toJSON();
		System.debug(participantWrapperJSON);

		String resultFromVDST = vdstParticipantApi.sendParticipantJSON(participantWrapperJSON);
		System.debug(resultFromVDST);

		if (resultFromVDST == 'OK') { 
			update attendee; //to set LAST UPDATED.
			return true;
		} else {
			try {
				ErrorWrapper errorWrapper  = parseStringToErrorWrapper(resultFromVDST);
				errorPopupMessage = errorWrapper.errorMsg;
			} catch(Exception ex) {
				errorPopupMessage = resultFromVDST;
			}
			return false;
		}
	}

	private List<ParticipantSpends> getConvertedParticipantSpends() {
		List<ParticipantSpends> participant_spends = new List<ParticipantSpends>();
		participant_spends.add(new ParticipantSpends('HCPTRVL', proxyInputsForHCP.EDM_Non_HCP_Travel_gne__c));
		participant_spends.add(new ParticipantSpends('HCPLODGNG', proxyInputsForHCP.EDM_Non_HCP_Hotel_gne__c));
		participant_spends.add(new ParticipantSpends('OOPTRVL', proxyInputsForOopHCP.EDM_Non_HCP_Travel_gne__c));
		participant_spends.add(new ParticipantSpends('OOPLODGNG', proxyInputsForOopHCP.EDM_Non_HCP_Hotel_gne__c));
		participant_spends.add(new ParticipantSpends('OOPMEALS', proxyInputsForOopHCP.EDM_Non_HCP_Meals_gne__c));
		participant_spends.add(new ParticipantSpends('OOPOTHR', proxyInputsForOopHCP.EDM_Non_HCP_Fees_gne__c));
		participant_spends.add(new ParticipantSpends('HONORARIA', proxyInputsForHCP.EDM_Non_HCP_Fees_gne__c));

		return participant_spends;
	}

	@testVisible
	private List<AttData> getConvertedAttData() {
		List<AttData> att_data = new List<AttData>();

		for (Attendance att : attendance) {
			att_data.add(new AttData(att));
		}

		return att_data;
	}

	public static String getCountryCapitalizedAsInGSSPMapping(String countryFromAccount) {
		for (String country : VDST_API.getCountryValues().values()) {
			if (countryFromAccount == country) {
				return country;
			}
		}
		return null;
	}

	public static void sendForRemovalInGSSP(Map<Id, EDM_Attendee_gne__c> oldMap) {
		sendForRemovalInGSSP(oldMap, new EDM_VDST_ParticipantAPI());
	}

	public static void sendForRemovalInGSSP(Map<Id, EDM_Attendee_gne__c> oldMap, IEDM_VDST_Participant vdstParticipantApi) {
		for (EDM_Attendee_gne__c attendee : filterAttendeeToDeleteFromGSSP(oldMap.keySet())) {
			sendForRemovalInGSSP(attendee.EDM_Parent_IABP_gne__r.Name, attendee.Id, vdstParticipantApi);
		}
	}

	@testVisible
	private static List<EDM_Attendee_gne__c> filterAttendeeToDeleteFromGSSP(Set<Id> attendeeIds) {
		List<EDM_Attendee_gne__c> results = [
				SELECT Id, EDM_Parent_IABP_gne__r.Name
				FROM EDM_Attendee_gne__c 
				WHERE Id = :attendeeIds AND
					EDM_System_Type_gne__c = :EDM_IABP_Utils.AttendeeSystemType.Advisor.name() AND 
					EDM_Parent_IABP_gne__r.EDM_Executive_Summary_gne__c = false];

		return results;
	}

	private static void sendForRemovalInGSSP(String abm_event_id, Id idToRemove, IEDM_VDST_Participant vdstParticipantApi) {
		System.debug('sendForRemovalInGSSP: ' + abm_event_id + ',' + idToRemove);
		JsonParticipantWrapper wrapper = new JsonParticipantWrapper(abm_event_id, idToRemove);
		wrapper.isRemoval = true;
		String participantWrapperJSON = wrapper.toJSON();
		System.debug(participantWrapperJSON);

		String resultFromVDST = vdstParticipantApi.sendParticipantJSON(participantWrapperJSON);
		System.debug(resultFromVDST);
	}


		// Event Participant Wrapper
	public virtual class JsonParticipantReadWrapper {
		// Read/Write fields
		String                   abm_participant_id { get; set; }
		OrganizationData          organization_data { get; set; }
		List<ParticipantSpends>  participant_spends { get; set; }
		List<AttData>                      att_data { get; set; }
		Boolean                          contracted { get; set; }
	}

	// Event Participant Wrapper
	@testVisible
	class JsonParticipantWrapper extends JsonParticipantReadWrapper {
		// Flags
		Boolean                        isValidation { get; set; }
		Boolean                           isRemoval { get; set; }
		String                         abm_event_id { get; set; }
		// Create/Update data
		String                           first_name { get; set; }
		String                            last_name { get; set; }
		String                     participant_role { get; set; }
		String                               suffix { get; set; }
		String                           credential { get; set; }
		String                           profession { get; set; }
		String                          affiliation { get; set; }
		String                                  npi { get; set; }
		String                                  dea { get; set; }
		String                       license_number { get; set; }
		String                        license_state { get; set; }
		String                      address_country { get; set; }
		String                       address_street { get; set; }
		String                      address_street2 { get; set; }
		String                         address_city { get; set; }
		String                        address_state { get; set; }
		String                          address_zip { get; set; }
		String                                phone { get; set; }
		String                                email { get; set; }
		String                               mdm_id { get; set; }
		String                              sfdc_id { get; set; }

		public JsonParticipantWrapper(String abm_event_id, EDM_Attendee_gne__c attendee, 
				Account account, Address_vod__c primaryAddress, CORE_Pub_License__c license, Account primaryAffiliatedHCO) {
			Map<String, String> statesByCode = VDST_API.getStateValues();

			this.isValidation = false;
			this.abm_event_id = abm_event_id;
			this.abm_participant_id = attendee.Id;
			this.first_name = account.FirstName;
			this.last_name = account.LastName;
			this.participant_role = attendee.EDM_Role_gne__c;
			this.suffix = account.Suffix_vod__c;
			this.contracted = true;
			this.credential = account.Credentials_gne__c;
			this.profession = account.Professional_Type_gne__c;
			this.affiliation = primaryAffiliatedHCO.Name;
			this.npi = account.NPI_vod__c;
			this.dea = primaryAddress.DEA_vod__c;
			this.license_number = license.License_Number_gne__c;
			this.license_state = statesByCode.get(license.License_State_gne__c);
			this.address_country = EDM_Spend_Participant.getCountryCapitalizedAsInGSSPMapping(primaryAddress.Country_gen__c);
			this.address_street = primaryAddress.Name;
			this.address_street2 = primaryAddress.Address_line_2_vod__c;
			this.address_city = primaryAddress.City_vod__c;
			this.address_state = statesByCode.get(primaryAddress.State_vod__c);
			this.address_zip = primaryAddress.Zip_vod__c;
			this.phone = account.Phone;
			this.email = primaryAddress.Email_gne__c;
			this.mdm_id = account.MDMID_gne__c;
			this.sfdc_id = account.Id;
		}

		public JsonParticipantWrapper(String abm_event_id, Id attendeeId) {
			this.isValidation = false;
			this.abm_event_id = abm_event_id;
			this.abm_participant_id = attendeeId;
		}

		public String toJSON() {
			 return System.JSON.serialize(this);
		}
	}

	public class ParticipantSpends {
		String                                 code { get; set; }
		Decimal                              amount { get; set; }
		public ParticipantSpends(String code, Decimal amount) {
			this.code = code;
			this.amount = amount != null ? amount : 0;
		}
	}
	
	public class OrganizationData {
		String                             org_name { get; set; }
		String                                  tin { get; set; }
		Boolean                      charitable_org { get; set; }
		String                                  npi { get; set; }
		String                                  dea { get; set; }
		String                               mdm_id { get; set; }
		String                      address_country { get; set; }
		String                       address_street { get; set; }
		String                         address_city { get; set; }
		String                        address_state { get; set; }
		String                          address_zip { get; set; }

		public OrganizationData(FeeOrganization org) {
			this.org_name = org.name;
			this.tin = org.tin;
			this.charitable_org = org.charitableOrg;
			this.npi = org.npi;
			this.dea = org.dea;
			this.mdm_id = org.mdmId;
			this.address_country = org.country;
			this.address_street = org.address;
			this.address_city = org.city;
			this.address_state = org.stateProvince;
			this.address_zip = org.postalCode;
		}
	}

	public class AttData {
		String                           att_status { get; set; }
		String                   consumption_status { get; set; }
		Decimal                         meal_amount { get; set; }
		Date                             event_date { get; set; }

		public AttData(Attendance att) {
			this.att_status = att.attended != null ? (att.attended ? 'ATND' : 'DNS') : 'DNS';
			this.consumption_status = att.attended != null ? (!att.attended ? 'NOMLPRVD' : 'CONSUMED') : 'NOTAPPLI';
			this.meal_amount = att.amount;
			this.event_date = att.attDate;

			System.debug(this);
		}
	}

	private static JsonParticipantReadWrapper parseStringToParticipantReadWrapper(String jsonString) {
		return (JsonParticipantReadWrapper) System.JSON.deserialize(jsonString, JsonParticipantReadWrapper.class);
	}

	// Error Wrapper
	class ErrorWrapper {
		String                             errorMsg { get; set; }
	}

	private static ErrorWrapper parseStringToErrorWrapper(String jsonString) {
		return (ErrorWrapper) System.JSON.deserialize(jsonString, ErrorWrapper.class);
	}



	public interface IEDM_VDST_Participant {
		String readParticipantSpendData(String attendeeId);
		String sendParticipantJSON(String participantWrapperJSON);
	}

	public class EDM_VDST_ParticipantAPI implements IEDM_VDST_Participant {
		public String readParticipantSpendData(String attendeeId) {
			return VDST_API.readParticipantSpendData(attendeeId);
		}

		public String sendParticipantJSON(String participantWrapperJSON) {
			return VDST_API.sendParticipantJSON(participantWrapperJSON);
		}
	}
}