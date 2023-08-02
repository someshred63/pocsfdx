global without sharing class iPhoneApex_2 {

    static final String DEFAULT_CALL_INTERACTION_TYPE = 'Office Appt/Drop In';
    static final String DEFAULT_CALL_TYPE = 'Detail with Sample';
    static final String DEFAULT_GROUP_CALL_TYPE = 'Group Detail with Sample';
    static final String NON_GROUP_CALL_TYPE = 'Detail Only';
    static final String GROUP_CALL_TYPE = 'Group Detail';
    static final String DEFAULT_CONTACT_AFFILIATION_TYPE = 'AFFILIATION';
    static final String DEFAULT_CONTACT_AFFILIATION_ROLE = 'Affiliated with';
    static final String DEFAULT_CALL_STATUS = 'Saved_vod';
    static final String DEFAULT_SAMPLE_RECORD_TYPE_FOR_CALL = 'Meeting Brief SFA-Primary-Care';
    static final String DEFAULT_LAST_DEVICE = 'iPhone_gne';
    static final String DEFAULT_CREATED_ON_DEVICE = 'iPhone_gne';
    static final String NonProduct_NonMolecule = 'Non-Product/Non-Molecule';
    static final String REQUESTID_PREFIX_FOR_MAIN_CALL = 'Infu_INT';
    static final String REQUESTID_PREFIX_FOR_ATTENDEE = 'Infu_ATT';
    static final String REQUESTID_PREFIX_FOR_SAMPLE = 'Infu_SAM';
    static final String REQUESTID_PREFIX_FOR_PFG = 'Infu_PFG';
    static final String REQUESTID_PREFIX_FOR_DETAIL = 'Infu_DET';
    static final String REQUESTID_PREFIX_FOR_DISCUSSION = 'Infu_DISC';
    static final Map<String, AttendeeType> CALL_ATTENDEE_TYPES_MAP;
    static final Map<String, AddressAttributeType> ADDRESS_ATTRIBUTE_TYPES_MAP;

    global enum AttendeeType {
        PERSONACCOUNT, ACCOUNT, CONTACT, USER
    }
    global enum ContactType {
        PERSONACCOUNT, CONTACT
    }

    static {
        CALL_ATTENDEE_TYPES_MAP = new Map<String, AttendeeType>();

        for (AttendeeType attType : AttendeeType.values()) {
            CALL_ATTENDEE_TYPES_MAP.put(attType.name(), attType);
        }

        ADDRESS_ATTRIBUTE_TYPES_MAP = new Map<String, AddressAttributeType>();

        for (AddressAttributeType addrAttrType : AddressAttributeType.values()) {
            ADDRESS_ATTRIBUTE_TYPES_MAP.put(addrAttrType.name(), addrAttrType);
        }
    }

    //Exception for iPhoneApex_2 errors
    public class iPhoneApexException extends Exception {
    }

    // response
    global class Response {
        WebService DateTime StartTime = DateTime.now();
        WebService DateTime EndTime = null;
        WebService String ErrorCode;
        WebService String ErrorMessage;
        WebService List<RequestIdResponseIdMap> RequestIdResponseIdList;
        WebService DebugInfo DebugInfo = new DebugInfo();
    }

    global class RequestIdResponseIdMap {
        WebService String RequestId;
        WebService String ResponseId;
        WebService String ObjectType;
        WebService String ObjectName;
    }

    global class DebugInfo {
        WebService String ScriptStatements;
        WebService String QueryStatements;
        WebService String QueryRows;
        WebService String DmlStatements;
        WebService String DmlRows;
        WebService String CpuTime;

        public void refresh() {
            ScriptStatements = Limits.getScriptStatements() + '/' + Limits.getLimitScriptStatements();
            QueryStatements = Limits.getQueries() + '/' + Limits.getLimitQueries();
            QueryRows = Limits.getQueryRows() + '/' + Limits.getLimitQueryRows();
            DmlStatements = Limits.getDmlStatements() + '/' + Limits.getLimitDmlStatements();
            DmlRows = Limits.getDmlRows() + '/' + Limits.getLimitDmlRows();
            CpuTime = Limits.getCpuTime() + '/' + Limits.getLimitCpuTime();
        }
    }

    // call structures
    global class CallDetail {
        WebService String Id;
        WebService String Product;
        WebService String DetailPriority;
        WebService String RequestId;
        WebService String TherapeuticArea;
        WebService String DiseaseIndication;
    }

    global class CallDiscussion {
        WebService String Id;
        WebService String Product;
        WebService String ProductStrategy;
        WebService String ProductTactic;
        WebService String Reaction;
        WebService String Reason;
        WebService String RequestId;
        WebService Integer NbrPatientsImpacted;
        WebService String AccountTactic;

        //Attributes to support MSL users interactions
        WebService String Answer;
        WebService String Question;
        WebService String Topic;
        WebService String CurrentIssue;
        WebService String Molecule;
        //new fields for OTR Added by Dominik Wasilewski 5-13-2011
        Webservice String Curriculum;
        WebService String Activity;
        WebService Boolean EventRelated;
        // new field added for OTR by Konrad Maluszkiewicz 9-27-2017
        WebService Boolean SpeakerTraining;

        //new field for force.com new data model
        WebService String DetailPriority;
        WebService String ActivityTimeSpent;
        WebService String Observation;

        WebService String PrepMbo;

        WebService String TriagedTo;
        WebService Integer PatientsImpacted;
        WebService Boolean IssueEnteredIntoASMI;
        WebService String DeckUsed;

        WebService String DecisionCycle; //DecisionCycle
        WebService String NextInteractionObjectives; //NextInteractionObjectives
        WebService String AttendeeGroup;
        WebService String NumOfAttendees;
        //OTR 4068
        WebService String NonProviderGroup;
        WebService String PatientJourney;
        WebService String InteractionNumber;

        WebService String Status;
        WebService String CRMMeetingObjective; //CRM_Meeting_Objective__c
        WebService Boolean ObjectivesMet; //CRM_Objectives_Met__c
        WebService String CRMTactic;//CRM_Tactic__c
        WebService String CRMWhen;//CRM_When__c
        WebService String Impact;//CRM_Impact__c
        WebService String CRMMarketingMaterial;//CRM_Marketing_Material__c
        WebService String Utility;//CRM_Value__c
    }

    global class CallThreat {
        WebService String Id;
        WebService String product;//Product_vod__c
        WebService String bookOfBusiness;//Book_of_Business__c
        WebService String requestedPosition;//Requested_Position__c
        WebService String rebate;//Rebate__c, 
        WebService Date requestedStartDate; //Requested_Start_Date__c
        WebService String riskLevel;//Risk_Level__c
        WebService String initialAssessment;//Initial_Assessment__c
        WebService String RequestId;//	iPhone_Request_Id_gne__c
    }

    global class CallVisitReason {
        WebService String Id;
        WebService String RequestId;
        //new fields for Call2_Interaction_Detail_vod__c
        WebService String visitReason;
        WebService String conferenceName;
        WebService String conferenceType;
        WebService String visitReasonTactic;

        WebService String strategyType;
        WebService String strategyTactic;
        WebService String strategyTool;
    }

    global class CallSample {
        WebService String Id;
        WebService String Account;
        WebService String Product;
        WebService Double Quantity;
        WebService String RequestId;
        WebService String LotNo;
    }

    global class CallPfgDetail {
        WebService String Account;
        WebService Date cDate;
        WebService String DistributionMethod;
        WebService String LotNo;
        WebService String Product;
        WebService Integer Quantity;
        WebService String RequestId;
    }

    global class CallKeyMessage {
        WebService String Id;
        WebService String Account;
        WebService String KeyMessage;
        WebService String Reaction;
        WebService String RequestId;
        WebService String Product; //new field for OTR Added by Dominik Wasilewski 5-13-2011
    }

    global class CallPreCall {
        WebService String Id;
        WebService String CustomerSegment;
        WebService String DecisionCycle;
        WebService String ImplicationQuestions;
        WebService String NeedsPayoffQuestions;
        WebService String ProblemQuestions;
        WebService String InteractionObjectives;
        WebService String Product;
        WebService String RequestId;
    }

    global class CallAttendee implements iPhoneBase.EnumSerializable {
        WebService String Id;
        WebService String Attendee;
        WebService String Address;
        WebService AttendeeType CallAttendeeType; // user, account or contact
        WebService String RequestId;
        WebService Boolean MealOptOut;
        WebService ContactType CallContactType;

        public String callAttendeeTypeString;  // Used in JSON serialization

        public void serializeEnums() {
            callAttendeeTypeString = CallAttendeeType != null ? CallAttendeeType.name() : null;
        }

        public void deserializeEnums() {
            CallAttendeeType = CALL_ATTENDEE_TYPES_MAP.get(callAttendeeTypeString);
        }
    }

    global class CallCategory {
        WebService String Id;
        WebService String RequestId;
        WebService String BrandAboveBrand; //Call2_Category_vod__c.Brand_Above_Brand_gne__c
        WebService String BrandName; //Call2_Category_vod__c.Brand_Name_gne__c
        WebService String Indication; //Call2_Category_vod__c.Indication_gne__c
        WebService String Molecule; //Call2_Category_vod__c.Molecule_gne__c
        WebService String NOCStatus; //Call2_Category_vod__c.NOC_Status_gne__c
        WebService String TherapeuticArea; //Call2_Category_vod__c.Therapeutic_Area_gne__c
    }

    global class CallAttributes implements iPhoneBase.EnumSerializable, iPhoneBase.RequestTestable {
        // used to remove existing call Info
        WebService String Id;
        WebService String RequestId;
        WebService String OwnerId;
        WebService String CreatedById;

        WebService String Account;
        WebService String Address;
        WebService String AddressText;
        WebService DateTime CallDateTime;
        WebService Boolean IsComplete;
        WebService Boolean isOtrRequest;
        WebService String InteractionType;
        WebService AttendeeType CallAttendeeType;

        WebService Integer NumOfCustomersPresent;
        // compliance
        WebService Double MealAmount;
        WebService Integer MealPlannedAttendeeCount;
        WebService Integer MealActualAttendeeCount;
        WebService String BusinessSponsor;
        WebService String MealLocationCity;
        WebService String MealLocationState;

        WebService List<CallAttendee> callAttendeeList;
        WebService List<CallDetail> callDetailList;
        WebService List<CallDiscussion> callDiscussionList;
        WebService List<CallVisitReason> callVisitReasonList;
        WebService List<CallSample> callSampleList;
        WebService List<CallPfgDetail> callPfgDetailList;
        WebService List<CallThreat> callThreatList;
        // atls key message
        WebService List<CallKeyMessage> callKeyMessageList;

        WebService List<CallPreCall> callPreCallList;

        //added by sandeep on Feb 12 2009
        WebService String SpendUser;

        WebService Boolean ContractedServices;
        WebService String TerritoryName;
        WebService String TerritoryId;

        //PFG fields
        WebService String Signature;
        WebService DateTime SignatureDate;
        WebService String RequestSignature;
        WebService DateTime RequestSignatureDate;
        WebService String Disclaimer;
        WebService String SampleReceiver ;
        WebService String LicenseNumber; //commented out StateMedicalLicense below. To clarify wether LicenseNumber is the SDFC id or textual Licence number
        WebService Boolean ValidationEngine;

        //Attributes to support FRM users interactions
        WebService Boolean isFRM;
        WebService String SpeakerProgram;
        WebService String Resolution;
        WebService Boolean Reactive;
        WebService String ResponseTime;
        WebService String InteractionMethod;
        WebService String TopicsAddressed;
        WebService String InteractionLocation;
        WebService String AdditionalNotes;
        WebService String AccountPlan;
        WebService Decimal Latitude;
        webService Decimal Longitude;

        //Attributes to support MSL users interactions
        WebService Boolean isMSL;
        WebService String isVisitReason;
        WebService String visitReasonDescription;
        WebService String GroupMeetingTopic;
        WebService String PrimaryInteractionReason;

        WebService Boolean UnwillingToMeet;
        WebService Boolean MealOptOut;
        WebService Boolean FollowUpOpt;

        WebService String NotesCanada;
        WebService String MedicalSupportNotesCanada;
        WebService String Referral;
        WebService String UnsolicitedRequest;
        WebService String SalesCollateral;
        WebService String VisitReasonCanadaMSL;
        Webservice String VisitReasonCanadaSAM;

        //sfa-793
        WebService Boolean isReferral;
        WebService String otherReferralSource;
        WebService String referralRequestedBy;
        WebService Date referralRequestedDate;
        WebService String referralSource;

        WebService Boolean PatientEducationMaterials;
        WebService Boolean ProtectionStrategy;

        WebService String InteractionLength;
        WebService String Collaboration;
        WebService Integer OtherAttendeesCount;
        // PREP Next Steps
        WebService String FollowUpWith;
        WebService String SpeakWith;
        WebService String About;
        WebService String Other;
        WebService String MboIds;
        Webservice String PrepStatus;

        // MC checkboxes from configuration for ATLS profiles, CallObjectives section
        WebService Boolean Mbac;
        WebService Boolean Mbic;
        WebService Boolean Mboc;
        WebService Boolean Biosimilars;

        WebService String HCPSpecialty;
        WebService Boolean IsPrecall;
        WebService String GroupCallWith;
        WebService Integer AttendeesInService;

        WebService String GroupCanada;
        WebService String AccessEchoAlignment;
        WebService List<CallCategory> callCategoryList;
        WebService String NoteObjectives;
        WebService String NoteKeyMessages;
        WebService String NoteOutcomes;
        WebService String NoteNextSteps;

        WebService String MAAccount;//M_A_Account__c
        WebService String Probability;//Probability__c
        WebService Boolean InitiatedByAccount;//Initiated_by_Account__c

        WebService String InteractionDescription;//Interaction_Description_gne__c
        WebService String Insight;//Insight_gne__c
        WebService String NextInteractionObjective;//Next_Interaction_Objective_gne__c

        public String callAttendeeTypeString; // Used in JSON serialization

        public void serializeEnums() {
            callAttendeeTypeString = CallAttendeeType != null ? CallAttendeeType.name() : null;

            if (callAttendeeList != null) {
                for (CallAttendee cAtt : callAttendeeList) {
                    cAtt.serializeEnums();
                }
            }
        }

        public void deserializeEnums() {
            CallAttendeeType = CALL_ATTENDEE_TYPES_MAP.get(callAttendeeTypeString);

            if (callAttendeeList != null) {
                for (CallAttendee cAtt : callAttendeeList) {
                    cAtt.deserializeEnums();
                }
            }
        }

        public void testRequest() {
            iPhoneApex_2.intUpdateOrCreateCall(this, new Response());
        }
    }

    global class MedcomAttributes implements iPhoneBase.RequestTestable {
        WebService String RequestId;
        WebService String Account;

        WebService String MedicalQuestion;
        WebService String Product;
        WebService String Priority;
        WebService String FollowUpMethod;
        WebService Boolean NotifyForEducation;

        WebService String StreetAddress;
        WebService String Suite;
        WebService String DepartmentName;
        WebService String AttnCareOf;
        WebService String City;
        WebService String State;
        WebService String Zip;
        WebService String ZipPlus4;

        WebService String Email;
        WebService String Phone;
        WebService String Fax;

        WebService String LanguageOfPreferenceCan;
        WebService String ProvinceCan;
        WebService String PostalCodeCan;

        public void testRequest() {
            iPhoneApex_2.intCreateMedcomRequest(this, new Response());
        }
    }

    global enum AddressAttributeType {
        PHONE, PHONEEXT, PHONE2, PHONE2EXT, FAX, FAX2, POSTALCODE, PROVINCE, ORGANIZATION, BESTDAYS2DELIVER
    }

    global class AttributeValuePair implements iPhoneBase.EnumSerializable {
        WebService String value;
        WebService AddressAttributeType attributeType;
        public String attributeTypeString; // Used in JSON serialization

        public void serializeEnums() {
            attributeTypeString = attributeType != null ? attributeType.name() : null;
        }

        public void deserializeEnums() {
            attributeType = ADDRESS_ATTRIBUTE_TYPES_MAP.get(attributeTypeString);
        }
    }

    global class AddressAttributes implements iPhoneBase.EnumSerializable, iPhoneBase.RequestTestable {
        WebService String AddressId;
        WebService Boolean isOtrRequest;
        WebService String RequestId;
        WebService Boolean isPfgUser;
        WebService List<AttributeValuePair> AttributeValuePairList;

        public void serializeEnums() {
            if (AttributeValuePairList != null) {
                for (AttributeValuePair attr : AttributeValuePairList) {
                    attr.serializeEnums();
                }
            }
        }

        public void deserializeEnums() {
            if (AttributeValuePairList != null) {
                for (AttributeValuePair attr : AttributeValuePairList) {
                    attr.deserializeEnums();
                }
            }
        }

        public void testRequest() {
            iPhoneApex_2.intUpdateAddress(this, new Response());
        }
    }

    global class ContactAttributes implements iPhoneBase.RequestTestable {
        WebService String RequestId;
        WebService String AffiliationRequestId;
        WebService Boolean isOtrRequest;

        WebService String Id;
        WebService String AffiliationId;

        WebService String Account;
        WebService String Role;
        WebService String professionalType;
        WebService Boolean ActiveForMyBrand;

        WebService String FirstName;
        WebService String LastName;
        WebService String MiddleName;

        WebService String StreetAddress;
        WebService String City;
        WebService String State;
        WebService String Country;
        WebService String Zipcode;
        WebService String Zip4;

        WebService String Phone;
        WebService String PhoneExt;
        WebService String Phone2;
        WebService String Phone2Ext;
        WebService String Email;
        WebService String Email2;
        WebService String Fax;

        WebService String Website;
        WebService String LinkedIn;
        WebService String Twitter;

        // For FRMs
        WebService String affiliationType;
        WebService String affiliationInfluence;
        WebService String affiliationComments;

        WebService Boolean emailOptOut;
        WebService String modificationDate;

        public void testRequest() {
            iPhoneApex_2.intUpdateOrCreateContact(this, new Response());
        }
    }

    global class ReferralInfo implements iPhoneBase.RequestTestable {
        WebService String RequestId;
        WebService Id AccountId;
        WebService Id AddressId;
        WebService String MedicalQuestion;
        WebService String FollowupMethod;
        WebService Id ProductId;
        WebService Id MoleculeId;
        WebService Id TA_SubTAId;
        WebService Date RequestedCompletionDate;
        WebService String Priority;
        WebService Id RequestedById;
        WebService Boolean isMedComm;
        WebService Id UserId;
        WebService Id AssignedToId;
        WebService String customPhone;
        WebService Boolean isOtrRequest;

        public void testRequest() {
            iPhoneApex_2.intCreateReferral(this, new Response());
        }
    }

    global enum PreferenceType {
        FAVORITE, PREFERREDADDRESS
    }
    global enum ObjectType {
        ACCOUNT, CONTACT
    }

    global class UserPreferenceAttributes {
        WebService PreferenceType preferenceType;
        WebService String OnObjectId;
        WebService ObjectType OnObjectType;
        WebService Boolean MyFavorite;
        WebService String WithObjectId;
    }

    global class AccountSurveyAttributes {
        WebService String SurveyId;
        WebService String RequestId;
    }

    global class CallListAfterDelete {
        WebService List<Call2_vod__c> remainingCallList;
    }

    WebService static Response deleteCall(CallAttributes callAttributes) {

        //DIRTY HACK FOR OTR-4187
        Set<String> ignoredInteractions = new Set<String>();
        List<OTR_Interaction_Recovery__c> otrRecoveries = OTR_Interaction_Recovery__c.getall().values();
        for (OTR_Interaction_Recovery__c recovery : otrRecoveries) {
            ignoredInteractions.addAll(recovery.Ids__c.split(','));
        }
        if ((String.isNotBlank(callAttributes.Id) && ignoredInteractions.contains(callAttributes.Id)) ||
                (String.isNotBlank(callAttributes.RequestId) && ignoredInteractions.contains(callAttributes.RequestId))) {
            Response callResponse = new Response();
            callResponse.RequestIdResponseIdList = new List<RequestIdResponseIdMap>();
            RequestIdResponseIdMap requestIdResponseIdItem = new RequestIdResponseIdMap();
            requestIdResponseIdItem.RequestId = callAttributes.RequestId;
            requestIdResponseIdItem.ResponseId = callAttributes.Id;
            requestIdResponseIdItem.ObjectType = 'Call2_vod__c';
            callResponse.RequestIdResponseIdList.add (requestIdResponseIdItem);
            callResponse.EndTime = DateTime.now();
            try {
                if (String.isNotEmpty(callAttributes.Id)) {
                    List<Call2_vod__c> callList = [SELECT Id FROM Call2_vod__c WHERE Id = :callAttributes.Id];
                    if (callList.size() > 0) {
                        update callList;
                    }
                }
                if (String.isNotEmpty(callAttributes.RequestId)) {
                    List<Call2_vod__c> callList = [SELECT Id FROM Call2_vod__c WHERE iPhone_Request_Id_gne__c = :callAttributes.RequestId];
                    if (callList.size() > 0) {
                        update callList;
                    }
                }
            } catch (Exception e) {
                //ignore
            }

            return callResponse;
        }
        //END OF DIRTY HACK

        Response callResponse = new Response();
        SavePoint savePoint = Database.setSavePoint();
        String callId = callAttributes.Id;

        try {
            if (String.isNotEmpty(callAttributes.Id)) {
                List<Call2_vod__c> callList = [SELECT id FROM call2_vod__c WHERE id = :callAttributes.id];
                if (callList.size() > 0) {
                    callId = callList[0].Id;
                }
            }
            //if call found then delete call
            if (String.isNotEmpty(callId)) {
                iPhoneApexUtil_2.deletCallHelper(callId);

                //Request Id to Response Id Map
                callResponse.RequestIdResponseIdList = new List<RequestIdResponseIdMap>();
                RequestIdResponseIdMap requestIdResponseIdItem = new RequestIdResponseIdMap();
                requestIdResponseIdItem.RequestId = callAttributes.RequestId;
                requestIdResponseIdItem.ResponseId = callId;
                requestIdResponseIdItem.ObjectType = 'Call2_vod__c';
                callResponse.RequestIdResponseIdList.add (requestIdResponseIdItem);
            } else {
                //return error call does not exists in SFDC
                callResponse.ErrorMessage = 'Invalid call';
                callResponse.RequestIdResponseIdList = new List<RequestIdResponseIdMap>();
            }
        } catch (Exception e) {
            callResponse.ErrorMessage = e.getMessage();
            callResponse.RequestIdResponseIdList = new List<RequestIdResponseIdMap>();
            Database.rollback (savePoint);
        }
        callResponse.EndTime = DateTime.now();
        return callResponse;
    }

    WebService static Response deleteAccountSurvey(AccountSurveyAttributes surveyAttributes) {
        Response surveyResponse = new Response();
        Boolean hasErrors = false;

        Savepoint sp = Database.setSavepoint();
        try {
            if (String.isNotBlank(surveyAttributes.SurveyId)) {
                List<Survey_gne__c> surveyList = [SELECT Id FROM Survey_gne__c WHERE Id = :surveyAttributes.SurveyId];
                if (!surveyList.isEmpty()) {
                    Id surveyId = surveyList[0].Id;
                    if (GNE_SFA2_Util.getUserCanDeleteRecordAccess(UserInfo.getUserId(), surveyId)) {
                        delete surveyList;
                        surveyResponse.RequestIdResponseIdList = new List<RequestIdResponseIdMap>();
                        RequestIdResponseIdMap requestIdResponseIdItem = new RequestIdResponseIdMap();
                        requestIdResponseIdItem.RequestId = surveyAttributes.RequestId;
                        requestIdResponseIdItem.ResponseId = surveyId;
                        requestIdResponseIdItem.ObjectType = 'Survey_gne__c';
                        surveyResponse.RequestIdResponseIdList.add(requestIdResponseIdItem);
                    } else {
                        surveyResponse.ErrorMessage = 'User does not have the level of access to delete the record!';
                        hasErrors = true;
                    }
                } else {
                    surveyResponse.ErrorMessage = 'Survey for given SurveyId: \'' + surveyAttributes.SurveyId + '\' has not been found!';
                    hasErrors = true;
                }
            } else {
                surveyResponse.ErrorMessage = 'SurveyId cannot be empty!';
                hasErrors = true;
            }
        } catch (Exception ex) {
            Database.rollback(sp);
            surveyResponse.ErrorMessage = ex.getMessage();
            hasErrors = true;
        }

        if (hasErrors) {
            surveyResponse.RequestIdResponseIdList = new List<RequestIdResponseIdMap>();
        }

        return surveyResponse;
    }

    static void executeDmlForChildRecords(String action, List<SObject> childRecords, List<RequestIdResponseIdMap> requestIdResponseIdList, List<String> inputRequestIdList, Map<String, String> acctAttendee2CallIdMap) {
        Schema.DescribeSObjectResult descSobject = childRecords[0].getSObjectType().getDescribe();
        try {
            if (action == 'insert') {
                List<Database.SaveResult> saveResultList = Database.Insert(childRecords);
                addIdToRequestReponseMap(requestIdResponseIdList, descSobject.getName(), saveResultList, inputRequestIdList);
            } else if (action == 'upsert') {
                List<Database.UpsertResult> upsertResultList = Database.Upsert(childRecords);
                addIdToRequestReponseMap(requestIdResponseIdList, descSobject.getName(), upsertResultList, inputRequestIdList);
                if (acctAttendee2CallIdMap != null && descSobject.getName() == 'Call2_vod__c') {
                    for (Integer i = 0; i < upsertResultList.size(); i++) {
                        Database.UpsertResult upsertResult = upsertResultList[i];
                        Id attendeeCallId = upsertResult.getId();
                        if (((Call2_vod__c) childRecords[i]).Account_Vod__c != null) {
                            acctAttendee2CallIdMap.put(((Call2_vod__c) childRecords[i]).account_Vod__c, attendeeCallId);
                        } else if (((Call2_vod__c) childRecords[i]).Contact_Vod__c != null) {
                            acctAttendee2CallIdMap.put(((Call2_vod__c) childRecords[i]).Contact_Vod__c, attendeeCallId);
                        }
                    }
                }
            }
        } catch (DmlException e) {
            System.debug(e.getLineNumber());
            System.debug(e.getStackTraceString());
            throw new iPhoneApexException(String.format('{0} {1}: {2}', new String[]{
                    action.toUpperCase(), descSobject.getLabel(), e.getMessage()
            }), e);
        }
    }

    static void addIdToRequestReponseMap(List<RequestIdResponseIdMap> requestIdResponseIdList, String objectType, List<Database.SaveResult> saveResultList, List<String> inputRequestIdList) {
        for (Integer i = 0; i < saveResultList.size(); i++) {
            Database.SaveResult saveResult = saveResultList[i];
            if (saveResult.getId() != null) {
                RequestIdResponseIdMap requestIdResponseIdItem = new RequestIdResponseIdMap();
                requestIdResponseIdItem.RequestId = inputRequestIdList[i];
                requestIdResponseIdItem.ResponseId = saveResult.getId();
                requestIdResponseIdItem.ObjectType = objectType;
                requestIdResponseIdList.add (requestIdResponseIdItem);
            }
        }
    }

    static void addIdToRequestReponseMap(List<RequestIdResponseIdMap> requestIdResponseIdList, String objectType, List<Database.Upsertresult> saveResultList, List<String> inputRequestIdList) {
        for (Integer i = 0; i < saveResultList.size(); i++) {
            Database.Upsertresult saveResult = saveResultList[i];
            if (saveResult.getId() != null) {
                RequestIdResponseIdMap requestIdResponseIdItem = new RequestIdResponseIdMap();
                requestIdResponseIdItem.RequestId = inputRequestIdList[i];
                requestIdResponseIdItem.ResponseId = saveResult.getId();
                requestIdResponseIdItem.ObjectType = objectType;
                requestIdResponseIdList.add (requestIdResponseIdItem);
            }
        }
    }

    //This method returns a newly created call record or call record that will be updated
    static List<Call2_vod__c> findOrCreateCall(CallAttributes callAttributes) {
        Call2_vod__c callRecord = null;
        List<Call2_vod__c> mainCall = new List<Call2_vod__c>();
        iPhoneApexUtil_2.callSampleCache = new Map<Id, List<Call2_Sample_vod__c>>();
        String callId = callAttributes.Id;
        String requestId = callAttributes.RequestId;

        // If call Id is not set in CallAttributes, try to find existing call with requestId
        if (String.isBlank(callId) && String.isNotBlank(requestId)) {
            for (Call2_vod__c call : [SELECT Id FROM Call2_vod__c WHERE iPhone_Request_Id_gne__c = :requestId LIMIT 1]) {
                callId = call.Id;
            }
        }

        // If call Id does not exist -> new record, otherwise -> update
        if (String.isNotBlank(callId)) {
            List<Call2_vod__c> callList = new List<Call2_vod__c>();
            // Query also Child Calls, because Samples can be attached to children - not only to parent call
            for (Call2_vod__c call : [
                    SELECT id, parent_call_vod__c, account_vod__c, attendee_type_vod__c, call_type_vod__c, parent_address_vod__c, address_vod__c, completed_gne__c, customers_gne__c,
                            meal_expense_gne__c, detailed_products_vod__c, planned_attendees_gne__c, actual_attendees_gne__c, business_sponsor_gne__c, city_gne__c, state_gne__c, Status_vod__c, iPhone_Request_Id_gne__c,
                            Signature_Date_vod__c, License_vod__c, Disclaimer_vod__c, Signature_vod__c, Is_Sampled_Call_vod__c, License_designation_gne__c, Request_Signature_gne__c, Request_Signature_Date_gne__c, Last_Device_vod__c, EMS_International_Speaker_gne__c,
                            HCP_Specialty_gne__c, PREP_Status_gne__c, Group_Call_with_gne__c, Biosimilars_gne__c,
                            Group_RAMA_gne__c, Access_Echo_Alignment_RAMA_gne__c, Objectives_RAMA_gne__c, Key_Messages_RAMA_gne__c, Outcomes_RAMA_gne__c, Next_Steps_RAMA_gne__c, M_A_Account__c,Initiated_by_Account__c, (SELECT id, iPhone_Request_Id_gne__c, Product_vod__c, Detail_Priority_vod__c, Therapeutic_Area_gne__c, Indication_gne__c FROM call2_detail_vod__r), (
                            SELECT id, iPhone_Request_Id_gne__c, Product_vod__c, Detail_Priority_gne__c, Account_vod__c, Product_Strategy_vod__c, Product_Tactic_vod__c, PREP_MBO_gne__c, Account_Tactic_vod__c,
                                    Reaction_gne__c, Reason_gne__c, Number_of_Patients_Impacted_gne__c, Event_Curriculum_gne__c, Activity_gne__c, Event_gne__c, Speaker_Training_gne__c, Activity_Time_Spent_gne__c, Observation_gne__c, Answer_gne__c,
                                    FRM_Triaged_To_gne__c, FRM_Patients_Impacted_gne__c, FRM_Deck_Used_gne__c, Attendee_Group_gne__c, Number_of_Attendees_gne__c, CRM_Meeting_Objective__c, CRM_Objectives_Met__c, CRM_Tactic__c, CRM_When__c,
                                    CRM_Impact__c, CRM_Marketing_Material__c, CRM_Value__c
                            FROM call2_discussion_vod__r
                    ), (SELECT id, iPhone_Request_Id_gne__c, Tactic_vod__c, Type_vod__c, Visit_Reason_vod__c, Name_vod__c, Strategy_RAMA_vod__c, Tactic_RAMA_vod__c, Tools_RAMA_vod__c FROM Call2_Interaction_Detail_vod__r), (SELECT id, iPhone_Request_Id_gne__c, Brand_Above_Brand_gne__c, Brand_Name_gne__c, Indication_gne__c, Molecule_gne__c, NOC_Status_gne__c, Therapeutic_Area_gne__c FROM Call2_Categories__r), (SELECT id, iPhone_Request_Id_gne__c, Product_vod__c, Call_Date_vod__c, Account_vod__c, quantity_vod__c, Lot_vod__c FROM call2_sample_vod__r), (SELECT id, iPhone_Request_Id_gne__c, EMS_International_Speaker_gne__c, account_vod__c, attendee_type_vod__c, contact_vod__c FROM Call2_vod__r), (SELECT id FROM Call_PFG_Details__r), (SELECT id, iPhone_Request_Id__c, Product_vod__c, Account_vod__c, Key_Message_vod__c, Reaction_vod__c FROM call2_key_message_vod__r), (SELECT id FROM call2_expense_vod__r), (SELECT id, iPhone_Request_Id_gne__c, Mbo_gne__c, Call_gne__c FROM Call_PREP_MBOs_gne__r), (SELECT Id, Customer_Segment_gne__c, Decision_Cycle_gne__c, Interaction_Objectives_gne__c, Implication_Questions_gne__c, Need_payoff_Questions_gne__c, Problem_Questions_gne__c, iPhone_Request_Id__c, Product_gne__c FROM Call_Pre_Calls__r), (SELECT Id,Product_vod__c, Book_of_Business__c, Requested_Position__c, Rebate__c, Requested_Start_Date__c,Risk_Level__c,Initial_Assessment__c,iPhone_Request_Id_gne__c FROM Call2_Threat_vod__r)
                    FROM Call2_vod__c
                    WHERE Id = :callId OR parent_call_vod__c = :callId
            ]) {
                // Add only parent call
                if (call.parent_call_vod__c == null) {
                    callList.add(call);
                }

                // Cache all samples
                for (Call2_Sample_vod__c cSample : call.call2_sample_vod__r) {
                    if (!iPhoneApexUtil_2.callSampleCache.keySet().contains(call.Id)) {
                        iPhoneApexUtil_2.callSampleCache.put(call.Id, new List<Call2_Sample_vod__c>());
                    }
                    iPhoneApexUtil_2.callSampleCache.get(call.Id).add(cSample);
                }
            }

            if (callList.size() == 1) {
                callRecord = callList[0];
            }
        }

        if (callRecord == null) {
            callRecord = new Call2_vod__c();
        }

        // initializer for iPhone call
        if (callAttributes.InteractionType == null || callAttributes.InteractionType.trim().length() == 0) {
            //callRecord.Interaction_Type_gne__c = iPhoneApex_2.DEFAULT_CALL_INTERACTION_TYPE;
            callRecord.Interaction_Type_gne__c = null;
        } else {
            callRecord.Interaction_Type_gne__c = callAttributes.InteractionType;
        }
        callRecord.Call_Type_vod__c = iPhoneApex_2.DEFAULT_CALL_TYPE;
        callRecord.iPhone_Request_Id_gne__c = callAttributes.RequestId;
        mainCall.add(callRecord);
        return mainCall;
    }

    //return winner account id for a merged account
    public static String getWinnerAccountId(Map<String, String> mapAcctIds, String accountId) {
        if (accountId != null) {
            if (mapAcctIds != null && mapAcctIds.containsKey(accountId)) {
                return mapAcctIds.get(accountId);
            }
        }
        return accountId;
    }

    //return winner account id for a merged address
    static String getWinnerAddressId(Map<String, String> mapaddrIds, String addressId) {
        if (addressId != null) {
            if (mapaddrIds != null && mapaddrIds.containsKey(addressId)) {
                return mapaddrIds.get(addressId);
            }
        }
        return addressId;
    }

    //get state medical license record for Account and license number
    static Address_vod__c getAddressFields(String addressId) {
        Address_vod__c obAddress;
        try {
            obAddress = [
                    SELECT Id, Name, Account_vod__c,
                            ADDRESS_1_GNE__C, ADDRESS_LINE_2_VOD__C, ADDRESS_LINE_3_GNE__C, ADDRESS_LINE_4_GNE__C,
                            City_Vod__c, State_vod__c, ZIP_VOD__C, Designation_gne__c, Country_vod__c, Zip_4_vod__c,
                            PFG_BDTD_gne__c, Province_can_gne__c, Postal_Code_can_gne__c
                    FROM Address_vod__c
                    WHERE Id = :addressId
            ];
        } catch (Exception ex) {
            //do nothing)
        }
        return obAddress;
    }

    //method call for Sample Signatur(Sampling)
    Webservice static Response updateOrCreateCall(CallAttributes callAttributes) {
        Response callResponse = new Response();
        SavePoint savePoint = Database.setSavePoint();

        try {
            callResponse = intUpdateOrCreateCall(callAttributes, callResponse);
        } catch (Exception e) {
            System.debug(e.getLineNumber());
            System.debug(e.getStackTraceString());
            Database.rollback (savePoint);
            callResponse.RequestIdResponseIdList = new List<RequestIdResponseIdMap>();
            callResponse.ErrorMessage = e.getMessage();
            iPhoneBase.handleException(e, UserInfo.getUserId(), (callAttributes.isOtrRequest == true ? 'OTR' : null),
                    'Record Interaction', iPhoneApex_2.CallAttributes.class, callAttributes.RequestId, callAttributes,
                    '[iPhoneApex] Error while creating or updating interaction');
            callResponse = checkManualFix(callResponse);
        }

        callResponse.EndTime = DateTime.now();
        callResponse.DebugInfo.refresh();
        return callResponse;
    }

    public static Response intUpdateOrCreateCall(CallAttributes callAttributes, Response callResponse) {
        String terrName;
        String terrId;
        Map<String, String> acctAttendee2CallIdMap = new Map<String, String>();

        String callOwnerId = callAttributes.OwnerId != null ? callAttributes.OwnerId : UserInfo.getUserId();
        Map<String, String> mapMergedAccountIds = iPhoneApexUtil_2.findMergedAccounts(iPhoneApexUtil_2.AccountIdsFromCallAttribute(callAttributes)) ;

        // Add current call address id to addrIds and find winner if it is looser
        List<String> addrIds = new List<String>();
        if (callAttributes.Address != null) {
            addrIds.add(callAttributes.Address);
        }
        Map<String, String> mapMergedAddressIds = iPhoneApexUtil_2.findMergedAddresses(addrIds);

        if (callAttributes.Address != null) {
            Address_vod__c fullAddress = getAddressFields(getWinnerAddressId(mapMergedAddressIds, callAttributes.Address));
            System.debug('getWinnerAddressId(' + mapMergedAddressIds + ', ' + callAttributes.Address + ') = ' + getWinnerAddressId(mapMergedAddressIds, callAttributes.Address));
            System.debug('fullAddress = ' + fullAddress);
            String accountId = getWinnerAccountId(mapMergedAccountIds, callAttributes.Account);
            // Call account is different than call address account
            if (accountId != null && fullAddress.Account_vod__c != null && accountId != fullAddress.Account_vod__c) {

                List<Address_vod__c> accountAddressList = [SELECT Id, Account_vod__c, Name, City_vod__c, State_vod__c, Zip_vod__c, Country_vod__c FROM Address_vod__c WHERE Account_vod__c = :accountId];
                String initialCallAddress = callAttributes.Address;
                Boolean addressFound = false;

                for (Address_vod__c tmpAddress : accountAddressList) {
                    if (((fullAddress.Name == null && tmpAddress.Name == null) || (fullAddress.Name != null && tmpAddress.Name != null && fullAddress.Name.equalsIgnoreCase(tmpAddress.Name))) &&
                            ((fullAddress.City_Vod__c == null && tmpAddress.City_Vod__c == null) || (fullAddress.City_Vod__c != null && tmpAddress.City_Vod__c != null && fullAddress.City_Vod__c.equalsIgnoreCase(tmpAddress.City_Vod__c))) &&
                            ((fullAddress.State_vod__c == null && tmpAddress.State_vod__c == null) || (fullAddress.State_vod__c != null && tmpAddress.State_vod__c != null && fullAddress.State_vod__c.equalsIgnoreCase(tmpAddress.State_vod__c))) &&
                            ((fullAddress.Zip_vod__c == null && tmpAddress.Zip_vod__c == null) || (fullAddress.Zip_vod__c != null && tmpAddress.Zip_vod__c != null && fullAddress.Zip_vod__c.equalsIgnoreCase(tmpAddress.Zip_vod__c))) &&
                            ((fullAddress.Country_vod__c == null && tmpAddress.Country_vod__c == null) || (fullAddress.Country_vod__c != null && tmpAddress.Country_vod__c != null && fullAddress.Country_vod__c.equalsIgnoreCase(tmpAddress.Country_vod__c)))) { // identical address found
                        // swap call address to the same address from account
                        callAttributes.Address = tmpAddress.Id;
                        addressFound = true;
                        break;
                    }
                }
                if (!addressFound) { //create new address and add it to the call account
                    Address_vod__c newAccountAddress = new Address_vod__c();
                    newAccountAddress.Account_vod__c = getWinnerAccountId(mapMergedAccountIds, callAttributes.Account);
                    newAccountAddress.Name = fullAddress.Name;
                    newAccountAddress.Address_line_2_vod__c = fullAddress.Address_line_2_vod__c;
                    newAccountAddress.Address_Line_3_gne__c = fullAddress.Address_Line_3_gne__c;
                    newAccountAddress.Address_Line_4_gne__c = fullAddress.Address_Line_4_gne__c;
                    newAccountAddress.City_vod__c = fullAddress.City_vod__c;
                    newAccountAddress.Zip_vod__c = fullAddress.Zip_vod__c;
                    newAccountAddress.Zip_4_vod__c = fullAddress.Zip_4_vod__c;
                    newAccountAddress.Country_vod__c = fullAddress.Country_vod__c;
                    newAccountAddress.State_vod__c = fullAddress.State_vod__c;
                    newAccountAddress.PFG_BDTD_gne__c = fullAddress.PFG_BDTD_gne__c;
                    newAccountAddress.Province_can_gne__c = fullAddress.Province_can_gne__c;
                    newAccountAddress.Postal_Code_can_gne__c = fullAddress.Postal_Code_can_gne__c;
                    newAccountAddress.PFG_BDTD_gne__c = fullAddress.PFG_BDTD_gne__c;

                    try {
                        insert newAccountAddress;
                        callAttributes.Address = newAccountAddress.Id;
                        system.debug('###########################call address successfully changed to: ' + callAttributes.Address);
                    } catch (Exception e) {
                        callAttributes.Address = initialCallAddress;
                        iPhoneBase.handleException(e, UserInfo.getUserId(), (callAttributes.isOtrRequest == true ? 'OTR' : null),
                                'Record Interaction', iPhoneApex_2.CallAttributes.class, callAttributes.RequestId, callAttributes,
                                '[iPhoneApex] Error while creating new address for interaction');
                    }
                }
            }
        }

        if (callAttributes.ValidationEngine != null) {
            callAttributes = iPhoneApexUtil_2.updateOrCreateCallForValEngine(callAttributes);
        }

        Call2_vod__c c = null;
        List<Call2_vod__c> mainCall = findOrCreateCall(callAttributes);

        Boolean isNewMode = true;

        if (mainCall != null && mainCall.size() > 0) {
            c = mainCall[0];
            isNewMode = c.Id == null ? true : false;
            iPhoneApex_PFG_Util.cacheOldCallRecord(c, mapMergedAccountIds);
        }

        //get list of detail, discussion and molecule products
        Set<Id> productIdList = iPhoneApexUtil_2.getDetailproductIdList(callAttributes);
        Set<Id> moleculeIdList = iPhoneApexUtil_2.getMoleculeproductIdList(callAttributes);
        if (moleculeIdList != null) {
            for (String sm : moleculeIdList) {
                if (!productIdList.contains(sm)) {
                    productIdList.add(sm);
                }
            }
        }
        Map<Id, Product_vod__c> mapProducts = iPhoneApexUtil_2.getDetailedProducts(productIdList, callAttributes);
        c.detailed_products_vod__c = iPhoneApexUtil_2.getDetailedProductString(mapProducts, moleculeIdList);

        system.Debug('-------------------------etWinnerAccountId' + getWinnerAccountId(mapMergedAccountIds, callAttributes.Account));

        c.Last_Device_vod__c = iPhoneApex_2.DEFAULT_LAST_DEVICE;

        //to update address fields address_line_1, line_2, city_vod__c on call object
        Address_vod__c objAddress = getAddressFields(getWinnerAddressId(mapMergedAddressIds, callAttributes.Address));

        c.account_vod__c = getWinnerAccountId(mapMergedAccountIds, callAttributes.Account); //if call is not sample attendee then update with incoming acount
        c.call_datetime_vod__c = callAttributes.CallDateTime;
        c.OwnerId = callOwnerId;
        c.Status_vod__c = iPhoneApex_2.DEFAULT_CALL_STATUS;

        if(callAttributes.TerritoryId != null) {
            Id recordTypeId = iphoneApexUtil_2.getRecordTypeId(isNewMode, callAttributes.TerritoryId);
            if(recordTypeId != null) {
                c.RecordTypeId = recordTypeId;
            }
        }

        c.Parent_address_vod__c = getWinnerAddressId(mapMergedAddressIds, callAttributes.Address);
        c.address_vod__c = callAttributes.AddressText;
        //assign the address fields to call object address fields
        if (objAddress != null) {
            c.License_designation_gne__c = objAddress.Designation_gne__c;
            c.Address_Line_1_vod__c = objAddress.Name;
            c.Address_Line_2_vod__c = objAddress.Address_line_2_vod__c;
            c.City_vod__c = objAddress.City_vod__c;
            c.State_vod__c = objAddress.State_vod__c;
            c.Zip_vod__c = objAddress.Zip_vod__c;

            if (c.Completed_gne__c != true) {
                c.PFG_BDTD_gne__c = objAddress.PFG_BDTD_gne__c;
            }
        }
        c.Attendees_vod__c = callAttributes.callAttendeeList != null ? callAttributes.callAttendeeList.size() : 0;

        if (callAttributes.CallAttendeeType == AttendeeType.ACCOUNT) {
            c.attendee_type_vod__c = 'Group_Account_vod';
            c.call_type_vod__c = iPhoneApex_2.GROUP_CALL_TYPE;
        } else if (callAttributes.CallAttendeeType == AttendeeType.PERSONACCOUNT) {
            //a group call with PersonAccount as main call will always have its attendee_type_vod__c as 'Person_Account_vod'
            c.attendee_type_vod__c = 'Person_Account_vod';
            c.call_type_vod__c = NON_GROUP_CALL_TYPE;
            //TODO: kozminsl investigate
            //c.Attendees_vod__c += 1;
        }

        // compliance: meal section attributes
        if (callAttributes.MealAmount != null) {
            c.meal_amount_gne__c = callAttributes.MealAmount;
        }

        if ((callAttributes.MealPlannedAttendeeCount != null && callAttributes.MealPlannedAttendeeCount > 0) &&
                (callAttributes.MealActualAttendeeCount != null && callAttributes.MealActualAttendeeCount > 0)) {
            c.meal_expense_gne__c = true;
            c.planned_attendees_gne__c = callAttributes.MealPlannedAttendeeCount;
            c.actual_attendees_gne__c = callAttributes.MealActualAttendeecount;
        } else {
            c.meal_expense_gne__c = false;
            c.meal_amount_gne__c = 0;
            c.planned_attendees_gne__c = 0;
            c.actual_attendees_gne__c = 0;
        }

        // lytics only - provided to match Lytics Interaction layout
        if (callAttributes.NumOfCustomersPresent != null) {
            c.customers_gne__c = callAttributes.NumOfCustomersPresent;
        }

        if (callAttributes.IsComplete != null) {
            c.completed_Gne__c = callAttributes.IsComplete;
        }

        if (c.completed_Gne__c == true) {
            c.Interaction_Status_gne__c = 'Completed';
            if (c.Date_Completed_gne__c == null) {
                c.Date_Completed_gne__c = date.today();
            }
        }

        if (callAttributes.isOtrRequest != null) {
            GNE_SFA2_Interaction_Trigger_Helper.setIsOtrRequest(callAttributes.isOtrRequest);
        } else {
            GNE_SFA2_Interaction_Trigger_Helper.setIsSfdcUiRequest(true);
        }
        if (callAttributes.UnwillingToMeet != null) {
            c.Attempted_Visit_HCP_UnwillingToMeet_gne__c = callAttributes.UnwillingToMeet;
        }
        if (callAttributes.BusinessSponsor != null) {
            c.Business_sponsor_gne__c = callAttributes.BusinessSponsor;
        }
        if (callAttributes.MealLocationCity != null) {
            c.city_gne__c = callAttributes.MealLocationCity;
        }
        if (callAttributes.MealLocationState != null) {
            c.state_gne__c = callAttributes.MealLocationState;
        }
        if (callAttributes.SpendUser != null) {
            c.Spend_User_gne__c = callAttributes.SpendUser;
        }
        if (callAttributes.Referral != null) {
            c.Referral_Assignment_gne__c = callAttributes.Referral;
        }
        if (callAttributes.ContractedServices != null) {
            c.Contracted_Services_gne__c = callAttributes.ContractedServices;
        }
        if (!iPhoneApexUtil_2.isNull(callAttributes.InteractionLocation)) {
            c.Interaction_Location_gne__c = callAttributes.InteractionLocation;
        }
        //for MSL or FRM interactions its an FRM user
        if (callAttributes.isFRM != null && callAttributes.isFRM) {
            c = iPhoneApexUtil_2.updateFRMInteraction(c, callAttributes);
        }
        if (!iPhoneApexUtil_2.isNull(callAttributes.AccountPlan)) {
            c.Account_Plan_vod__c = callAttributes.AccountPlan;
        }
        if (callAttributes.isMSL != null && callAttributes.isMSL) {
            c = iPhoneApexUtil_2.updateMSLInteraction(c, callAttributes);
        }
        if (callAttributes.NotesCanada != null) {
            c.Notes_can_gne__c = callAttributes.NotesCanada;
        }
        if (callAttributes.MedicalSupportNotesCanada != null) {
            c.Medical_Support_Notes_gne__c = callAttributes.MedicalSupportNotesCanada;
        }
        if (callAttributes.UnsolicitedRequest != null) {
            c.Unsolicited_Request_gne__c = callAttributes.UnsolicitedRequest;
        }
        if (callAttributes.SalesCollateral != null) {
            c.Sales_Collateral_gne__c = callAttributes.SalesCollateral;
        }
        if (callAttributes.VisitReasonCanadaMSL != null) {
            c.Visit_Reason_RCanada_MSL_gne__c = callAttributes.VisitReasonCanadaMSL;
        }
        if (callAttributes.VisitReasonCanadaSAM != null) {
            c.Visit_Reason_Canada_SAM_gne__c = callAttributes.VisitReasonCanadaSAM;
        }
        if (callAttributes.PatientEducationMaterials != null) {
            c.Patient_Education_Materials_gne__c = callAttributes.PatientEducationMaterials;
        }
        if (callAttributes.ProtectionStrategy != null) {
            c.Protection_Strategy_gne__c = callAttributes.ProtectionStrategy;
        }

        if (callAttributes.InteractionLength != null) {
            c.Interaction_Length_gne__c = callAttributes.InteractionLength;
        }

        if (callAttributes.Collaboration != null) {
            c.Collaboration_gne__c = callAttributes.Collaboration;
        }

        if (callAttributes.OtherAttendeesCount != null) {
            c.Other_Attendees_Count_gne__c = callAttributes.OtherAttendeesCount;
        }

        if (callAttributes.FollowUpWith != null) {
            c.PREP_Follow_Up_With_gne__c = callAttributes.FollowUpWith;
        }

        if (callAttributes.SpeakWith != null) {
            c.PREP_Speak_With_gne__c = callAttributes.SpeakWith;
        }

        if (callAttributes.About != null) {
            c.PREP_About_gne__c = callAttributes.About;
        }

        if (callAttributes.Other != null) {
            c.PREP_Other_gne__c = callAttributes.Other;
        }

        if (callAttributes.PrepStatus != null) {
            c.PREP_Status_gne__c = callAttributes.PrepStatus;
        }
        if (callAttributes.GroupCanada != null) {
            c.Group_RAMA_gne__c = callAttributes.GroupCanada;
        }
        if (callAttributes.AccessEchoAlignment != null) {
            c.Access_Echo_Alignment_RAMA_gne__c = callAttributes.AccessEchoAlignment;
        }
        if (callAttributes.NoteObjectives != null) {
            c.Objectives_RAMA_gne__c = callAttributes.NoteObjectives;
        }
        if (callAttributes.NoteKeyMessages != null) {
            c.Key_Messages_RAMA_gne__c = callAttributes.NoteKeyMessages;
        }
        if (callAttributes.NoteOutcomes != null) {
            c.Outcomes_RAMA_gne__c = callAttributes.NoteOutcomes;
        }
        if (callAttributes.NoteNextSteps != null) {
            c.Next_Steps_RAMA_gne__c = callAttributes.NoteNextSteps;
        }

        //sfa-793
        if (callAttributes.isReferral != null) {
            c.Is_Referral_gne__c = callAttributes.isReferral;
        }
        if (String.isNotEmpty(callAttributes.referralRequestedBy)) {
            c.Referral_Requested_By_gne__c = callAttributes.referralRequestedBy;
        } else {
            c.Referral_Requested_By_gne__c = null;
        }
        c.Other_Referral_Source_gne__c = callAttributes.otherReferralSource;
        c.Referral_Requested_Date_gne__c = callAttributes.referralRequestedDate;
        c.Referral_Source_gne__c = callAttributes.referralSource;

        if (callAttributes.Mbac != null) {
            c.MBaC_gne__c = callAttributes.Mbac;
        }
        if (callAttributes.Mbic != null) {
            c.MBiC_gne__c = callAttributes.Mbic;
        }
        if (callAttributes.Mboc != null) {
            c.MBoC_gne__c = callAttributes.Mboc;
        }
        if (callAttributes.Biosimilars != null) {
            c.Biosimilars_gne__c = callAttributes.Biosimilars;
        }
        if (callAttributes.IsPrecall != null) {
            c.Pre_Call_Plan_gne__c = callAttributes.IsPrecall;
        }
        if (callAttributes.MAAccount != null) {
            c.M_A_Account__c = callAttributes.MAAccount;
        }
        if (callAttributes.Probability != null) {
            c.Probability__c = callAttributes.Probability;
        }
        if (callAttributes.InitiatedByAccount != null) {
            c.Initiated_by_Account__c = callAttributes.InitiatedByAccount;
        }

        //---------------Starts Get User territory and assign to call--------------------
        //for backward compatibllity, if Territory name is passed then stamp territry_vod with territory name else fetch territory name
        //if existing interaction in sfdc was already stamped with territory name and incoming user no longer belongs to any territory then this code will not update existing territory to blank/null
        if (callAttributes.TerritoryName != null) {
            terrName = callAttributes.TerritoryName;
            c.Territory_vod__c = callAttributes.TerritoryName;
        }

        if (callAttributes.TerritoryId != null) {
            c.Territory_Id_gne__c = callAttributes.TerritoryId;
            terrId = callAttributes.TerritoryId;
        }

        //---------------Ends Get User territory and assign to call--------------------

        //---------------Meal Opt Out -------------------------------------------
        if (callAttributes.MealOptOut == null) {
            callAttributes.MealOptOut = false;
        }

        Boolean isHcpOrAttendeeMealOptOut = callAttributes.MealOptOut;
        if (!isHcpOrAttendeeMealOptOut) {
            if (callAttributes.CallAttendeeList != null) {
                for (CallAttendee attendee : callAttributes.CallAttendeeList) {
                    if (attendee.MealOptOut == null) {
                        attendee.MealOptOut = false;
                    }
                    if (attendee.MealOptOut) {
                        isHcpOrAttendeeMealOptOut = true;
                        break;
                    }
                }
            }
        }
        c.HCP_OR_Attendee_Meal_Opt_Out_gne__c = isHcpOrAttendeeMealOptOut;
        c.HCP_Account_Meal_Opt_Out_gne__c = callAttributes.MealOptOut;
        //---------------Meal Opt Out END ----------------------------------------

        if (callAttributes.FollowUpOpt != null) {
            c.HCP_Follow_Up_Opt_In_gne__c = callAttributes.FollowUpOpt;
        }

        //---- Geolocation ---------
        if (callAttributes.Latitude != null && callAttributes.Longitude != null &&
                iPhoneBase.validateCoordinates(callAttributes.latitude, callAttributes.longitude, iPhoneApex_2.class, 'Record Interaction', callAttributes.isOtrRequest == true ? 'OTR' : null, callAttributes.RequestId)
                ) {
            c.Geolocation_gne__Latitude__s = callAttributes.Latitude;
            c.Geolocation_gne__Longitude__s = callAttributes.Longitude;
        }

        if (callAttributes.GroupCallWith != null) {
            c.Group_Call_with_gne__c = callAttributes.GroupCallWith;
        }

        if (callAttributes.AttendeesInService != null) {
            c.No_InService_Attendees__c = callAttributes.AttendeesInService;
        }

        if (callAttributes.InteractionDescription != null) {
            c.Interaction_Description_gne__c = callAttributes.InteractionDescription;
        }

        if (callAttributes.Insight != null) {
            c.Insight_gne__c = callAttributes.Insight;
        }

        if (callAttributes.NextInteractionObjective != null) {
            c.Next_Interaction_Objective_gne__c = callAttributes.NextInteractionObjective;
        }

        // PFG START
        iPhoneApex_PFG_Util.updateCallSignature(c, callAttributes);
        // PFG END

        Database.UpsertResult upsertResult = Database.Upsert (c);
        Id id = upsertResult.getId();
        if (id == null) {
            Database.Error dbError = upsertResult.getErrors()[0];
            throw new iPhoneApexException(dbError.getStatusCode().Name() + ' : ' + dbError.getMessage());
        } else if (callAttributes.Referral != null) {
            //hco compliance
            Referral_Assignment_gne__c referralAssignment = GNE_SFA2_Referral_Interaction_Ctrl.getReferralAssignmentById(callAttributes.Referral);
            if (referralAssignment.Call2_vod__c == null) {
                referralAssignment.Call2_vod__c = id;
                update referralAssignment;
            }
        }

        String sObjectType = iPhoneApexUtil_2.prefixToSObjectType.get(String.valueOf(callAttributes.Account).substring(0, 3));

        if (sObjectType == 'Account') {
            acctAttendee2CallIdMap.put (getWinnerAccountId(mapMergedAccountIds, callAttributes.Account), id);
        } else if (sObjectType == 'Contact') {
            acctAttendee2CallIdMap.put(callAttributes.Account, id);
        }

        //Request Id to Response Id Map
        callResponse.RequestIdResponseIdList = new List<RequestIdResponseIdMap>();
        RequestIdResponseIdMap requestIdResponseIdItem = new RequestIdResponseIdMap();
        requestIdResponseIdItem.RequestId = callAttributes.RequestId;
        requestIdResponseIdItem.ResponseId = id;
        requestIdResponseIdItem.ObjectType = 'Call2_vod__c';
        requestIdResponseIdItem.ObjectName = [SELECT Name FROM Call2_vod__c WHERE Id = :id].Name;
        callResponse.RequestIdResponseIdList.add (requestIdResponseIdItem);

        //attendees if any passed
        if (callAttributes.CallAttendeeList != null || !c.Call2_vod__r.isEmpty()) {
            List<String> inputRequestIdList = new List<String>();
            //prepare list of Call Attendees to create or update
            List<Call2_vod__c> attendees = iPhoneApexUtil_2.getListOfAttendeesToCreateOrUpdate(c, callAttributes, callOwnerId, terrName, terrId, mapMergedAccountIds, inputRequestIdList, iPhoneApex_2.DEFAULT_LAST_DEVICE);
            //insert attendees;
            if (attendees != null && attendees.size() > 0) {
                executeDmlForChildRecords('upsert', attendees, callResponse.RequestIdResponseIdList, inputRequestIdList, acctAttendee2CallIdMap);
            }
        }

        // call detail
        if (callAttributes.callDetailList != null || !c.call2_detail_vod__r.isEmpty()) {
            List<String> inputRequestIdList = new List<String>();
            //prepare list of Call Detail to create or update
            List<Call2_Detail_vod__c> callDetailList = iPhoneApexUtil_2.getListOfCallDetailToCreateOrUpdate(c, callAttributes, inputRequestIdList);
            //insert callDetailList;
            if (!callDetailList.isEmpty()) {
                executeDmlForChildRecords('upsert', callDetailList, callResponse.RequestIdResponseIdList, inputRequestIdList, null);
            }
        }

        // call discussion
        List<Call2_Discussion_vod__c> callDiscussionList;
        if (callAttributes.callDiscussionList != null || !c.call2_discussion_vod__r.isEmpty()) {
            List<String> inputRequestIdList = new List<String>();
            //prepare list of Call Discussion to create or update
            callDiscussionList = iPhoneApexUtil_2.getListOfCallDiscussionToCreateOrUpdate(c, callAttributes, mapMergedAccountIds, mapProducts, inputRequestIdList);
            //insert callDiscussionList;
            if (!callDiscussionList.isEmpty()) {
                executeDmlForChildRecords('upsert', callDiscussionList, callResponse.RequestIdResponseIdList, inputRequestIdList, null);
            }
        }

        // call interaction detail (Call2_Interaction_Detail_vod__c)
        List<Call2_Interaction_Detail_vod__c> callInteractionDetailList;
        if (callAttributes.callVisitReasonList != null || !c.Call2_Interaction_Detail_vod__r.isEmpty()) {
            List<String> inputRequestIdList = new List<String>();
            //prepare list of Call Interaction Details to create or update
            callInteractionDetailList = iPhoneApexUtil_2.getListOfCallInteractionDetailToCreateOrUpdate(c, callAttributes, mapMergedAccountIds, mapProducts, inputRequestIdList);
            //insert callInteractionDetailList;
            if (!callInteractionDetailList.isEmpty()) {
                executeDmlForChildRecords('upsert', callInteractionDetailList, callResponse.RequestIdResponseIdList, inputRequestIdList, null);
            }
        }

        // call interaction category (Call2_Category_vod__c)
        List<Call2_Category_vod__c> callCategoryList;
        if (callAttributes.callCategoryList != null || !c.Call2_Categories__r.isEmpty()) {
            List<String> inputRequestIdList = new List<String>();
            //prepare list of Call Categories to create or update
            callCategoryList = iPhoneApexUtil_2.getListOfCallCategoryToCreateOrUpdate(c, callAttributes, mapMergedAccountIds, mapProducts, inputRequestIdList);
            //insert callCategoryList;
            if (!callCategoryList.isEmpty()) {
                executeDmlForChildRecords('upsert', callCategoryList, callResponse.RequestIdResponseIdList, inputRequestIdList, null);
            }
        }

        List<Call2_Threat_vod__c> callThreatList;
        if (callAttributes.callThreatList != null || !c.Call2_Threat_vod__r.isEmpty()) {
            List<String> inputRequestIdList = new List<String>();
            callThreatList = iPhoneApexUtil_2.getListOfCallThreatToCreateOrUpdate(c, callAttributes, inputRequestIdList);
            if (!callThreatList.isEmpty()) {
                executeDmlForChildRecords('upsert', callThreatList, callResponse.RequestIdResponseIdList, inputRequestIdList, null);
            }
        }

        if (callAttributes.callKeyMessageList != null || !c.call2_key_message_vod__r.isEmpty()) {
            List<String> inputRequestIdList = new List<String>();
            //prepare list of Call Key Message to create or update
            List<Call2_Key_Message_vod__c> callKeyMessageList = iPhoneApexUtil_2.getListOfCallKeyMessageToCreateOrUpdate(c, callAttributes, mapMergedAccountIds, inputRequestIdList);
            //insert callKeyMessageList;
            system.debug('--------------------------------------' + callKeyMessageList);
            if (!callKeyMessageList.isEmpty()) {
                executeDmlForChildRecords('upsert', callKeyMessageList, callResponse.RequestIdResponseIdList, inputRequestIdList, null);
            }
        }

        if (c.Pre_Call_Plan_gne__c && callAttributes.callPreCallList != null || !c.Call_Pre_Calls__r.isEmpty()) {
            List<String> inputRequestIdList = new List<String>();
            //prepare list of Call Pre Calls to create or update
            List<Call_Pre_Call_gne__c> callPreCallList = iPhoneApexUtil_2.getListOfCallPreCallToCreateOrUpdate(c, callAttributes, inputRequestIdList);
            if (!callPreCallList.isEmpty()) {
                executeDmlForChildRecords('upsert', callPreCallList, callResponse.RequestIdResponseIdList, inputRequestIdList, null);
            }
        }
        //delete all pre calls
        if (!c.Pre_Call_Plan_gne__c && !c.Call_Pre_Calls__r.isEmpty()) {
            delete c.Call_Pre_Calls__r;
        }

        // call samples
        if (callAttributes.callSampleList != null || iPhoneApexUtil_2.callSampleCache.keyset().size() > 0) {
            List<String> inputRequestIdList = new List<String>();
            //prepare list of Call Samples to create or update
            List<Call2_sample_vod__C> callSampleList = iPhoneApexUtil_2.getListOfCallSampleToCreateOrUpdate(c, callAttributes, acctAttendee2CallIdMap, mapMergedAccountIds, inputRequestIdList);
            //insert callSampleList;
            if (callSampleList != null && callSampleList.size() > 0) {
                system.debug('JL::.. upserting sample list: ' + callSampleList);
                executeDmlForChildRecords('upsert', callSampleList, callResponse.RequestIdResponseIdList, inputRequestIdList, null);
            }
        }

        // PFG START
        iPhoneApex_PFG_Util.managePfgDetails(c, callAttributes);
        if (String.isNotBlank(callAttributes.HCPSpecialty)) {
            c.HCP_Specialty_gne__c = callAttributes.HCPSpecialty;
        }
        // PFG END

        // PREP START
        if (GNE_SFA2_PREP_Util.isPrepUser(GNE_SFA2_Util.getCurrentUserProfileName())) {
            GNE_SFA2_PREP_Util.manageCallMbos(
                    c.Id,
                    (String.isNotBlank(callAttributes.MboIds) ? new Set<String>(callAttributes.MboIds.split(';')) : new Set<String>()),
                    c.Call_PREP_MBOs_gne__r
            );
        }
        // PREP END

        if (callDiscussionList != null && c.completed_Gne__c == true) {
            FRM_ASMI_Integration_Manager frmAsmiIntegration = new FRM_ASMI_Integration_Manager(c, callDiscussionList);
            if (frmAsmiIntegration.shouldCreateMarketInsigts()) {
                frmAsmiIntegration.createMarketInsigts();
            }
        }

        callResponse.EndTime = DateTime.now();
        callResponse.DebugInfo.refresh();
        return callResponse;
    }

    Webservice static Response createMedcomRequest(MedcomAttributes medcomAttributes) {
        Response response = new Response();
        SavePoint savePoint = Database.setSavePoint();

        try {
            response = intCreateMedcomRequest(medcomAttributes, response);
        } catch (Exception e) {
            Database.rollback (savePoint);
            response.RequestIdResponseIdList = new List<RequestIdResponseIdMap>();
            response.ErrorMessage = e.getMessage();
            iPhoneBase.handleException(e, UserInfo.getUserId(), null,
                    'Create MedComm Request', iPhoneApex_2.MedcomAttributes.class, medcomAttributes.RequestId, medcomAttributes,
                    '[iPhoneApex] Error while creating MedCom');
            response = checkManualFix(response);
        }

        response.EndTime = DateTime.now();
        response.DebugInfo.refresh();
        return response;
    }

    public static Response intCreateMedcomRequest(MedcomAttributes medcomAttributes, Response response) {
        response.RequestIdResponseIdList = new List<RequestIdResponseIdMap>();
        RequestIdResponseIdMap requestIdResponseIdItem = new RequestIdResponseIdMap();
        requestIdResponseIdItem.RequestId = medcomAttributes.RequestId;
        requestIdResponseIdItem.ObjectType = 'Medical_Communication_gne__c';
        response.RequestIdResponseIdList.add (requestIdResponseIdItem);

        List<String> acctIds = new List<String>();
        if (medcomAttributes.Account != null) {
            acctIds.add(medcomAttributes.Account);
        }
        Map<String, String> mapMergedAccountIds = iPhoneApexUtil_2.findMergedAccounts(acctIds);

        List<Medical_Communication_gne__c> medcomList;
        if (medcomAttributes.RequestId != null) {
            medcomList = [
                    SELECT Id
                    FROM Medical_Communication_gne__c
                    WHERE iphone_request_id_gne__c = :medcomAttributes.RequestId
                    ORDER BY createddate DESC
                    LIMIT 1
            ];
        }

        // check for existence
        if (medcomList != null && medcomList.size() > 0) {
            requestIdResponseIdItem.ResponseId = medcomList[0].Id;
        } else {
            Boolean bNotifyForEducation = false;
            if (medcomAttributes.NotifyForEducation != null) {
                bNotifyForEducation = medcomAttributes.NotifyForEducation;
            }

            // create new medical communication object
            Medical_Communication_gne__c medcom = new Medical_Communication_gne__c();
            medcom.iphone_request_id_gne__c = medcomAttributes.RequestId;
            medcom.account_gne__c = getWinnerAccountId(mapMergedAccountIds, medcomAttributes.Account);

            //medcom.product_gne__c = medcomAttributes.Product;
            //as for OTR-2333 Molecule and Product should be filled like in SFDC
            if (!iPhoneApexUtil_2.isNull(medcomAttributes.Product)) {
                Product_vod__c objProduct = [SELECT id, name, Product_Type_vod__c, Detail_Product_Subtype_Code_gne__c FROM Product_vod__c WHERE id = :medcomAttributes.Product];
                if (objProduct != null) {
                    if (!GNE_SFA2_Util.getCurrentUserProfileName().contains('MedAffairs')) {
                        if (!iPhoneApexUtil_2.isNull(objProduct.Detail_Product_Subtype_Code_gne__c) && objProduct.Detail_Product_Subtype_Code_gne__c == 'Molecule') {
                            medcom.Molecule_gne__c = medcomAttributes.Product;
                        } else {
                            medcom.Product_gne__c = medcomAttributes.Product;
                        }
                    } else {
                        medcom.Molecule_gne__c = medcomAttributes.Product;
                        medcom.Product_gne__c = medcomAttributes.Product;
                    }
                }
            }

            medcom.medical_question_gne__c = medcomAttributes.MedicalQuestion;
            medcom.priority_gne__c = medcomAttributes.Priority;
            medcom.Follow_up_method_gne__c = medcomAttributes.FollowUpMethod;
            medcom.Notify_for_education_gne__c = bNotifyForEducation;

            medcom.address_line_1_gne__c = medcomAttributes.StreetAddress;
            medcom.address_line_2_gne__c = medcomAttributes.Suite;
            medcom.address_line_3_gne__c = medcomAttributes.DepartmentName;
            medcom.address_line_4_gne__c = medcomAttributes.AttnCareOf;
            medcom.city_gne__c = medcomAttributes.City;
            medcom.state_gne__c = medcomAttributes.State;
            medcom.zip_gne__c = medcomAttributes.Zip;
            medcom.zip_4_gne__c = medcomAttributes.zipPlus4;

            medcom.email_gne__c = medcomAttributes.Email;
            medcom.phone_gne__c = medcomAttributes.Phone;
            medcom.fax_gne__c = medcomAttributes.Fax;
            if (medcomAttributes.LanguageOfPreferenceCan != null) {
                medcom.Language_of_Preference_can_gne__c = medcomAttributes.LanguageOfPreferenceCan;
            }
            if (medcomAttributes.ProvinceCan != null) {
                medcom.Province_can_gne__c = medcomAttributes.ProvinceCan;
            }
            if (medcomAttributes.PostalCodeCan != null) {
                medcom.Postal_Code_can_gne__c = medcomAttributes.PostalCodeCan;
            }
            Database.SaveResult saveResult = Database.Insert (medcom);

            if (saveResult.getId() == null) {
                Database.Error dbError = saveResult.getErrors()[0];
                throw new iPhoneApexException(dbError.getStatusCode().Name() + ' : ' + dbError.getMessage());
            } else {
                requestIdResponseIdItem.ResponseId = saveResult.getId();
            }
        }

        return response;
    }

    Webservice static Response updateAddress(AddressAttributes addressAttributes) {
        Response response = new Response();
        SavePoint savePoint = Database.setSavePoint();

        try {
            response = intUpdateAddress(addressAttributes, response);
        } catch (Exception e) {
            Database.rollback (savePoint);
            response.RequestIdResponseIdList = new List<RequestIdResponseIdMap>();
            response.ErrorMessage = e.getMessage();
            iPhoneBase.handleException(e, UserInfo.getUserId(), (addressAttributes.isOtrRequest == true ? 'OTR' : null),
                    'Update Address', iPhoneApex_2.AddressAttributes.class, addressAttributes.RequestId, addressAttributes,
                    '[iPhoneApex] Error while updating address');
            response = checkManualFix(response);
        }

        response.EndTime = DateTime.now();
        response.DebugInfo.refresh();
        return response;
    }

    private static Response intUpdateAddress(AddressAttributes addressAttributes, Response response) {
        if (addressAttributes.AddressId != null && addressAttributes.AttributeValuepairList != null && addressAttributes.AttributeValuePairList.size() > 0) {
            List<String> addrIds = new List<String>();

            if (addressAttributes.AddressId != null) {
                addrIds.add(addressAttributes.AddressId);
            }

            Map<String, String> mapMergedAddressIds = iPhoneApexUtil_2.findMergedAddresses(addrIds);
            Id addrId = getWinnerAddressId(mapMergedAddressIds, addressAttributes.AddressId);
            Address_vod__c addr;

            for (Address_vod__c addrRec : [
                    SELECT
                            id, Phone_vod__c, Phone_1_Ext_gne__c, Phone_2_vod__c, Phone_2_Ext_gne__c, Fax_vod__c, Fax_2_vod__c, PFG_BDTD_gne__c
                    FROM address_vod__c
                    WHERE id = :addrId
            ]) {
                addr = addrRec;
            }

            if (addr == null) {
                throw new iPhoneApexException(String.format('Address with Id {0} doesn\'t exist', new String[]{
                        addrId
                }));
            }

            // need to generalize this assignment to support more
            // attributes
            for (AttributeValuePair attributeValuePair : addressAttributes.AttributeValuePairList) {
                if (attributeValuePair.attributeType == AddressAttributeType.PHONE) {
                    addr.phone_vod__c = attributeValuePair.value;
                } else if (attributeValuePair.attributeType == AddressAttributeType.PHONEEXT) {
                    addr.phone_1_ext_gne__c = attributeValuePair.value;
                } else if (attributeValuePair.attributeType == AddressAttributeType.PHONE2) {
                    addr.phone_2_vod__c = attributeValuePair.value;
                } else if (attributeValuePair.attributeType == AddressAttributeType.PHONE2EXT) {
                    addr.phone_2_ext_gne__c = attributeValuePair.value;
                } else if (attributeValuePair.attributeType == AddressAttributeType.FAX) {
                    addr.fax_vod__c = attributeValuePair.value;
                } else if (attributeValuePair.attributeType == AddressAttributeType.FAX2) {
                    addr.fax_2_vod__c = attributeValuePair.value;
                } else if (attributeValuePair.attributeType == AddressAttributeType.POSTALCODE) {
                    addr.Postal_Code_can_gne__c = attributeValuePair.value;
                } else if (attributeValuePair.attributeType == AddressAttributeType.PROVINCE) {
                    addr.Province_can_gne__c = attributeValuePair.value;
                } else if (attributeValuePair.attributeType == AddressAttributeType.ORGANIZATION) {
                    addr.Org_Name_can_gne__c = attributeValuePair.value;
                } else if (addressAttributes.isPfgUser != false && attributeValuePair.attributeType == AddressAttributeType.BESTDAYS2DELIVER) {
                    addr.PFG_BDTD_gne__c = attributeValuePair.value;
                }
            }

            update addr;
        }

        return response;
    }

    static String updateContactAffiliation(String ToAccount, String FromContact, String AffiliationType, String AffiliationRole, String affiliationInfluence, String affiliationComments, Boolean activeForMyBrand, String requestId) {
        String affiliationId = null;
        String queriedFields = String.join(
                new List<String>{
                        'Id',
                        String.valueOf(Affiliation_vod__c.Affiliation_Type_gne__c),
                        String.valueOf(Affiliation_vod__c.Role_vod__c),
                        String.valueOf(Affiliation_vod__c.Influence_vod__c),
                        String.valueOf(Affiliation_vod__c.Comments_vod__c),
                        String.valueOf(Affiliation_vod__c.Role_Opposite_vod__c),
                        String.valueOf(Affiliation_vod__c.Iphone_Request_Id_gne__c),
                        GNE_Account_Affiliation_Dao.ACTIVE_FOR_MY_BRAND_FIELD_LIST_STR
                },
                ', '
        );
        String query = String.format('SELECT {0}, (SELECT {0} FROM Affiliation_vod__r) FROM Affiliation_vod__c WHERE {1} = True and {2} = \'\'{3}\'\' and {4} = \'\'{5}\'\' and createdById = \'\'{6}\'\' ORDER BY LastModifiedDate desc Limit 1 ',
                new String[]{
                        queriedFields,                                            // 0
                        String.valueOf(Affiliation_vod__c.parent_vod__c),        // 1
                        String.valueOf(Affiliation_vod__c.to_account_vod__c),    // 2
                        ToAccount,                                                // 3
                        String.valueOf(Affiliation_vod__c.from_contact_vod__c),    // 4
                        FromContact,                                            // 5
                        UserInfo.getUserId()                                    // 6
                }
        );

        List<Affiliation_vod__c> affiliationList = Database.query(query);
        if (affiliationList.size() > 0) {
            affiliationList[0].Affiliation_Type_gne__c = AffiliationType != null && iPhoneApexUtil_2.checkIfPicklistValueExist('Affiliation_vod__c', 'Affiliation_Type_gne__c', AffiliationType) ? AffiliationType : iPhoneApex_2.DEFAULT_CONTACT_AFFILIATION_TYPE;
            affiliationList[0].Role_vod__c = AffiliationRole != null && iPhoneApexUtil_2.checkIfPicklistValueExist('Affiliation_vod__c', 'Role_vod__c', AffiliationRole) ? AffiliationRole : iPhoneApex_2.DEFAULT_CONTACT_AFFILIATION_ROLE;
            affiliationList[0].Role_Opposite_vod__c = AffiliationRole != null && iPhoneApexUtil_2.checkIfPicklistValueExist('Affiliation_vod__c', 'Role_opposite_vod__c', AffiliationRole) ? AffiliationRole : null;
            affiliationList[0].Influence_vod__c = affiliationInfluence;
            affiliationList[0].Comments_vod__c = affiliationComments;

            Affiliation_vod__c childAffiliation = affiliationList[0].affiliation_vod__r;
            childAffiliation.Affiliation_Type_gne__c = AffiliationType != null && iPhoneApexUtil_2.checkIfPicklistValueExist('Affiliation_vod__c', 'Affiliation_Type_gne__c', AffiliationType) ? AffiliationType : iPhoneApex_2.DEFAULT_CONTACT_AFFILIATION_TYPE;
            childAffiliation.Role_vod__c = AffiliationRole != null && iPhoneApexUtil_2.checkIfPicklistValueExist('Affiliation_vod__c', 'Role_vod__c', AffiliationRole) ? AffiliationRole : iPhoneApex_2.DEFAULT_CONTACT_AFFILIATION_ROLE;
            childAffiliation.Role_Opposite_vod__c = AffiliationRole != null && iPhoneApexUtil_2.checkIfPicklistValueExist('Affiliation_vod__c', 'Role_opposite_vod__c', AffiliationRole) ? AffiliationRole : null;
            childAffiliation.Influence_vod__c = affiliationInfluence;
            childAffiliation.Comments_vod__c = affiliationComments;
            childAffiliation.iphone_request_id_gne__c = requestId;

            String activeForMyBrandFieldApiName = GNE_Account_Affiliation_Dao.canSetActiveForMyBrand() ? GNE_Account_Affiliation_Dao.getMyBrandFieldApiName() : null;
            if (String.isNotBlank(activeForMyBrandFieldApiName) && activeForMyBrand != null) {
                affiliationList[0].put(activeForMyBrandFieldApiName, activeForMyBrand);
                childAffiliation.put(activeForMyBrandFieldApiName, activeForMyBrand);
            }

            affiliationId = childAffiliation.Id;
            affiliationList.add (childAffiliation);
            update affiliationList;
        }
        return affiliationId;
    }

    Webservice static Response updateOrCreateContact(ContactAttributes contactAttributes) {
        Response resultResponse = new Response();
        SavePoint savePoint = Database.setSavePoint();

        try {
            resultResponse = intUpdateOrCreateContact(contactAttributes, resultResponse);
        } catch (Exception e) {
            Database.rollback (savePoint);
            resultResponse.ErrorMessage = e.getMessage();
            resultResponse.RequestIdResponseIdList = new List<RequestIdResponseIdMap>();
            iPhoneBase.handleException(e, UserInfo.getUserId(), (contactAttributes.isOtrRequest == true ? 'OTR' : null),
                    'Record Contact', iPhoneApex_2.ContactAttributes.class, contactAttributes.RequestId, contactAttributes,
                    '[iPhoneApex] Error while creating or updating contact');
            resultResponse = checkManualFix(resultResponse);
        }

        resultResponse.EndTime = DateTime.now();
        resultResponse.DebugInfo.refresh();
        return resultResponse;
    }

    public static Response intUpdateOrCreateContact(ContactAttributes contactAttributes, Response response) {
        response.RequestIdResponseIdList = new List<RequestIdResponseIdMap>();
        RequestIdResponseIdMap requestIdResponseIdItem = new RequestIdResponseIdMap();
        requestIdResponseIdItem.RequestId = contactAttributes.RequestId;
        requestIdResponseIdItem.ObjectType = 'Contact';
        response.RequestIdResponseIdList.add(requestIdResponseIdItem);

        Boolean isMyBrandCalculated = GNE_Account_Affiliation_Dao.isMyBrandCalculated();
        String myBrandFieldApiName = GNE_Account_Affiliation_Dao.getMyBrandFieldApiName();
        iPhoneApexUtil_2.AffiliatedContact affContact = null;
        Boolean foundMatchedContact = false;

        List<String> acctIds = new List<String>();
        if (contactAttributes.Account != null) {
            acctIds.add(contactAttributes.Account);
        }

        Map<String, String> mapMergedAccountIds = iPhoneApexUtil_2.findMergedAccounts(acctIds);

        Contact contact = null;
        List<Contact> contactList = [
                SELECT Id, Iphone_Request_Id_gne__c, FirstName, LastName, Middle_Name_gne__c, MailingStreet,
                        MailingCity, MailingState, MailingCountry, MailingPostalCode, Zip_4_gne__c, Phone, Ext_gne__c,
                        Secondary_Phone_gne__c, Secondary_Ext_gne__c, Fax, Email, Secondary_Email_gne__c, Type_gne__c,
                        Website_gne__c, LinkedIn_gne__c, Twitter_gne__c, Has_Opted_Out_Date_gne__c, Has_Opted_Out_gne__c
                FROM Contact
                WHERE Id = :contactAttributes.Id OR (Iphone_Request_Id_gne__c = :contactAttributes.RequestId AND Iphone_Request_Id_gne__c != null)
        ];

        if (contactList != null && contactList.size() > 0) {
            contact = contactList[0];
        } else {
            if (isMyBrandCalculated) {
                affContact = iPhoneApexUtil_2.findMatchingContact(contactAttributes);
                contact = affContact.contact;
                foundMatchedContact = String.isNotBlank(contact.Id);
            } else {
                contact = new Contact();
            }
        }

        if (!foundMatchedContact) {
            if (contact.FirstName != contactAttributes.FirstName) {
                contact.FirstName = contactAttributes.FirstName;
            }
            if (contact.LastName != contactAttributes.LastName) {
                contact.LastName = contactAttributes.LastName;
            }
            contact.Middle_Name_gne__c = contactAttributes.MiddleName;
            contact.MailingStreet = contactAttributes.StreetAddress;
            contact.MailingCity = contactAttributes.City;
            contact.MailingState = contactAttributes.State;
            contact.MailingCountry = contactAttributes.Country;
            contact.MailingPostalCode = contactAttributes.Zipcode;
            contact.Zip_4_gne__c = contactAttributes.Zip4;
            contact.Type_gne__c = contactAttributes.Role;
        }

        if (!foundMatchedContact || String.isNotBlank(contactAttributes.professionalType)) {
            contact.Professional_Type_2_frm_gne__c = contactAttributes.professionalType;
        }

        if (!foundMatchedContact || (String.isBlank(contact.iphone_request_id_gne__c) && String.isNotBlank(contactAttributes.RequestId))) {
            contact.iphone_request_id_gne__c = contactAttributes.RequestId;
        }
        if (!foundMatchedContact || String.isNotBlank(contactAttributes.Phone)) {
            contact.Phone = contactAttributes.Phone;
        }
        if (!foundMatchedContact || String.isNotBlank(contactAttributes.PhoneExt)) {
            contact.Ext_gne__c = contactAttributes.PhoneExt;
        }
        if (!foundMatchedContact || String.isNotBlank(contactAttributes.Phone2)) {
            contact.Secondary_Phone_gne__c = contactAttributes.Phone2;
        }
        if (!foundMatchedContact || String.isNotBlank(contactAttributes.Phone2Ext)) {
            contact.Secondary_Ext_gne__c = contactAttributes.Phone2Ext;
        }
        if (!foundMatchedContact || String.isNotBlank(contactAttributes.Fax)) {
            contact.Fax = contactAttributes.Fax;
        }
        if (!foundMatchedContact || String.isNotBlank(contactAttributes.Email)) {
            contact.Email = contactAttributes.Email;
        }
        if (!foundMatchedContact || String.isNotBlank(contactAttributes.Email2)) {
            contact.Secondary_Email_gne__c = contactAttributes.Email2;
        }
        if (!foundMatchedContact || String.isNotBlank(contactAttributes.Website)) {
            contact.Website_gne__c = contactAttributes.Website;
        }
        if (!foundMatchedContact || String.isNotBlank(contactAttributes.LinkedIn)) {
            contact.LinkedIn_gne__c = contactAttributes.LinkedIn;
        }
        if (!foundMatchedContact || String.isNotBlank(contactAttributes.Twitter)) {
            contact.Twitter_gne__c = contactAttributes.Twitter;
        }

        if (contactAttributes.emailOptOut != null && String.isNotBlank(contactAttributes.modificationDate)) {
            DateTime modificationDate = DateTime.valueofGmt(contactAttributes.modificationDate);
            if (contact.Id != null && contact.Has_Opted_Out_Date_gne__c != null) {
                if (contact.Has_Opted_Out_Date_gne__c < modificationDate) {
                    contact.Has_Opted_Out_gne__c = contactAttributes.emailOptOut;
                    if (contactAttributes.emailOptOut) {
                        contact.Has_Opted_Out_Date_gne__c = modificationDate;
                    }
                }
            } else {
                contact.Has_Opted_Out_gne__c = contactAttributes.emailOptOut;
                if (contactAttributes.emailOptOut) {
                    contact.Has_Opted_Out_Date_gne__c = modificationDate;
                }
            }
        }

        if (contact.Id != null) {
            system.debug('update contact');
            update contact;
            system.debug('contact updated');
            requestIdResponseIdItem.ResponseId = contact.Id;
            String affId = contactAttributes.affiliationId;
            if (foundMatchedContact) {
                // Existing Contact is found in the system - need to return its iphone request id
                requestIdResponseIdItem.RequestId = contact.iphone_request_id_gne__c;
                affId = affContact.affiliationId;
            }
            Affiliation_vod__c contactAffiliation = null;
            if (String.isNotBlank(affId)) {
                String query = String.format('SELECT {0} FROM Affiliation_vod__c WHERE Id = \'\'{1}\'\'',
                        new String[]{
                                GNE_Account_Affiliation_Dao.FIELD_LIST,
                                affId
                        }
                );
                Affiliation_vod__c aff = Database.query(query);
                aff.role_vod__c = contactAttributes.Role != null && iPhoneApexUtil_2.checkIfPicklistValueExist('Affiliation_vod__c', 'Role_vod__c', contactAttributes.Role) ? contactAttributes.Role : iPhoneApex_2.DEFAULT_CONTACT_AFFILIATION_ROLE;
                aff.role_opposite_vod__c = contactAttributes.Role != null && iPhoneApexUtil_2.checkIfPicklistValueExist('Affiliation_vod__c', 'Role_opposite_vod__c', contactAttributes.Role) ? contactAttributes.Role : null;

                Boolean stampOrigAff = false;
                if (isMyBrandCalculated) {
                    Affiliation_vod__c existedRecord = GNE_Account_Affiliation_Dao.calculateByExternalId(aff);
                    // Check if other affiliation with planned external id already exists
                    if (existedRecord != null && String.valueOf(existedRecord.Id).compareTo(String.valueOf(aff.Id)) != 0) {
                        Boolean isActive = (Boolean) existedRecord.get(myBrandFieldApiName);
                        if (!isActive || contactAttributes.ActiveForMyBrand == null) {
                            existedRecord.put(myBrandFieldApiName, true);
                        } else {
                            existedRecord.put(myBrandFieldApiName, contactAttributes.ActiveForMyBrand);
                        }
                        contactAffiliation = existedRecord;
                        if (!foundMatchedContact) {
                            stampOrigAff = true;
                        }
                    } else {
                        if (foundMatchedContact && (Boolean) aff.get(myBrandFieldApiName) != true) {
                            aff.put(myBrandFieldApiName, true);
                        } else if (contactAttributes.ActiveForMyBrand != null) {
                            aff.put(myBrandFieldApiName, contactAttributes.ActiveForMyBrand);
                        }
                        contactAffiliation = aff;
                    }
                } else {
                    if (GNE_Account_Affiliation_Dao.canSetActiveForMyBrand() && contactAttributes.ActiveForMyBrand != null) {
                        aff.put(myBrandFieldApiName, contactAttributes.ActiveForMyBrand);
                    }
                    contactAffiliation = aff;
                }
                update contactAffiliation;
                if (stampOrigAff) {
                    // Only to stamp lastModifiedDate on original record - must to be returned back in delta process
                    GNE_SFA2_Affiliation_Trigger_Helper.setAfilTrig(true);
                    update [Select Id From Affiliation_vod__c Where Id = :contactAttributes.affiliationId];
                    GNE_SFA2_Affiliation_Trigger_Helper.setAfilTrig(false);
                }
            } else if (isMyBrandCalculated && foundMatchedContact && String.isNotBlank(contactAttributes.Account)) {
                // need to create new affiliation record
                contactAffiliation = new Affiliation_vod__c(
                        Affiliation_Type_gne__c = contactAttributes.affiliationType != null ? contactAttributes.affiliationType : iPhoneApex_2.DEFAULT_CONTACT_AFFILIATION_TYPE,
                        To_Account_vod__c = contactAttributes.Account,
                        From_Contact_vod__c = contact.Id,
                        Role_vod__c = contactAttributes.Role != null && iPhoneApexUtil_2.checkIfPicklistValueExist('Affiliation_vod__c', 'Role_vod__c', contactAttributes.Role) ? contactAttributes.Role : iPhoneApex_2.DEFAULT_CONTACT_AFFILIATION_ROLE,
                        Role_opposite_vod__c = contactAttributes.Role != null && iPhoneApexUtil_2.checkIfPicklistValueExist('Affiliation_vod__c', 'Role_opposite_vod__c', contactAttributes.Role) ? contactAttributes.Role : null,
                        Influence_vod__c = contactAttributes.affiliationInfluence,
                        Comments_vod__c = contactAttributes.affiliationComments,
                        Iphone_request_id_gne__c = contactAttributes.AffiliationRequestId
                );
                contactAffiliation.put(myBrandFieldApiName, true);
                insert contactAffiliation;
            }
            if (contactAffiliation != null) {
                RequestIdResponseIdMap affRequestIdResponseIdItem = new RequestIdResponseIdMap();
                affRequestIdResponseIdItem.RequestId = contactAffiliation.Iphone_request_id_gne__c;
                affRequestIdResponseIdItem.ObjectType = 'Affiliation_vod__c';
                affRequestIdResponseIdItem.ResponseId = contactAffiliation.Id;
                response.RequestIdResponseIdList.add (affRequestIdResponseIdItem);
            }
        } else {
            contact.AccountId = getWinnerAccountId(mapMergedAccountIds, contactAttributes.Account);
            Database.SaveResult saveResult = Database.Insert(contact);
            if (saveResult.getId() != null) {
                requestIdResponseIdItem.ResponseId = saveResult.getId();
                String affiliationId = updateContactAffiliation(getWinnerAccountId(mapMergedAccountIds, contactAttributes.Account), (String) saveResult.getId(), contactAttributes.affiliationType, contactAttributes.Role, contactAttributes.affiliationInfluence, contactAttributes.affiliationComments, contactAttributes.ActiveForMyBrand, contactAttributes.AffiliationRequestId);
                RequestIdResponseIdMap affRequestIdResponseIdItem = new RequestIdResponseIdMap();
                affRequestIdResponseIdItem.RequestId = contactAttributes.AffiliationRequestId;
                affRequestIdResponseIdItem.ObjectType = 'Affiliation_vod__c';
                affRequestIdResponseIdItem.ResponseId = affiliationId;
                response.RequestIdResponseIdList.add (affRequestIdResponseIdItem);
            } else {
                Database.Error dbError = saveResult.getErrors()[0];
                throw new iPhoneApexException(dbError.getStatusCode().Name() + ' : ' + dbError.getMessage());
            }
        }

        return response;
    }

    // This method is deprecated. Use iPhone_ManageUserPreferences.processRequest(iPhone_ManageUserPreferences.ManageUserPreferencesRequest request) instead.
    Webservice static Response addOrRemoveUserPreference(UserPreferenceAttributes userPreferenceAttributes) {
        Response response = new Response();
        try {
            List<iPhone_ManageUserPreferences.UserPreferenceWrapper> recWrappers = new List<iPhone_ManageUserPreferences.UserPreferenceWrapper>();
            iPhone_ManageUserPreferences.UserPreferenceWrapper recWrapper = new iPhone_ManageUserPreferences.UserPreferenceWrapper();
            recWrapper.primaryId = userPreferenceAttributes.OnObjectId;
            recWrapper.secondaryId = userPreferenceAttributes.WithObjectId;
            recWrapper.active = userPreferenceAttributes.preferenceType != PreferenceType.FAVORITE || userPreferenceAttributes.MyFavorite != false;
            recWrapper.type = userPreferenceAttributes.preferenceType != null ? userPreferenceAttributes.preferenceType.name() : null;
            recWrappers.add(recWrapper);

            if (userPreferenceAttributes.preferenceType == PreferenceType.PREFERREDADDRESS) {
                List<User_Preference_gne__c> existingUps = [
                        SELECT Id, Type_gne__c, Account_gne__c, Address_gne__c, User_gne__c
                        FROM User_Preference_gne__c
                        WHERE Account_gne__c = :recWrapper.primaryId
                        AND Address_gne__c <> :recWrapper.secondaryId
                        AND Type_gne__c = :recWrapper.type
                        AND User_gne__c = :UserInfo.getUserId()
                ];

                for (User_Preference_gne__c up : existingUps) {
                    iPhone_ManageUserPreferences.UserPreferenceWrapper otherRecWrapper = new iPhone_ManageUserPreferences.UserPreferenceWrapper();
                    otherRecWrapper.primaryId = up.Account_gne__c;
                    otherRecWrapper.secondaryId = up.Address_gne__c;
                    otherRecWrapper.active = false;
                    otherRecWrapper.type = up.Type_gne__c;
                    recWrappers.add(otherRecWrapper);
                }
            }

            iPhone_Commons_gne.RestResponse restResponse = iPhone_ManageUserPreferences.processRequest(new iPhone_ManageUserPreferences.ManageUserPreferencesRequest(null, recWrappers));

            if (restResponse != null && restResponse.success == false && restResponse.error != null) {
                response.ErrorMessage = restResponse.error.message;
            }
        } catch (Exception e) {
            response.ErrorMessage = e.getMessage();
        }
        response.EndTime = DateTime.now();
        response.DebugInfo.refresh();
        return response;
    }

    // get call attributes for infrequent user
    WebService static CallAttributes getCallAttributes(String callId) {
        return iPhoneApexUtil_2.getCallAttributes(callId);
    }

    Webservice static Response updateOrCreateCallForIFU(CallAttributes callAttributes) {
        if (callAttributes == null) {
            return null;
        }
        String callOwnerId = callAttributes.OwnerId != null ? callAttributes.OwnerId : UserInfo.getUserId();
        String requestId = DateTime.Now().format ('yyyyMMddHHmmssS');
        String userAlias = [SELECT alias FROM user WHERE Id = :callOwnerId].alias;

        if (callAttributes.RequestId == null) {
            callAttributes.RequestId = REQUESTID_PREFIX_FOR_MAIN_CALL + userAlias + requestId + '0';
        }

        if (callAttributes.callAttendeeList != null) {
            for (Integer i = 0; i < callAttributes.CallAttendeeList.size(); i++) {
                if (callAttributes.CallAttendeeList[i].RequestId == null) {
                    callAttributes.CallAttendeeList[i].RequestId = REQUESTID_PREFIX_FOR_ATTENDEE + userAlias + requestId + (i + 1) ;
                }
            }
        }

        if (callAttributes.callDetailList != null) {
            for (Integer i = 0; i < callAttributes.callDetailList.size(); i++) {
                if (callAttributes.callDetailList[i].RequestId == null) {
                    callAttributes.callDetailList[i].RequestId = REQUESTID_PREFIX_FOR_DETAIL + userAlias + requestId + i ;
                }
            }
        }

        if (callAttributes.callDiscussionList != null) {
            for (Integer i = 0; i < callAttributes.callDiscussionList.size(); i++) {
                if (callAttributes.callDiscussionList[i].RequestId == null) {
                    callAttributes.callDiscussionList[i].RequestId = REQUESTID_PREFIX_FOR_DISCUSSIOn + userAlias + requestId + i ;
                }
            }
        }

        if (callAttributes.callSampleList != null) {
            for (Integer i = 0; i < callAttributes.callSampleList.size(); i++) {
                if (callAttributes.callSampleList[i].RequestId == null)
                    callAttributes.callSampleList[i].RequestId = REQUESTID_PREFIX_FOR_SAMPLE + userAlias + requestId + i ;
            }
        }

        if (callAttributes.callPfgDetailList != null) {
            for (Integer i = 0; i < callAttributes.callPfgDetailList.size(); i++) {
                if (callAttributes.callPfgDetailList[i].RequestId == null) {
                    callAttributes.callPfgDetailList[i].RequestId = REQUESTID_PREFIX_FOR_PFG + userAlias + requestId + i ;
                }
            }
        }
        return updateOrCreateCall(callAttributes);
    }

    Webservice static Boolean checkUserForImmunoTerr(String userId) {
        return GlobalUtils.isUserInTerr(UserInfo.getUserId(), System.Label.GNE_MedAffairs_Immunology_Terr);
    }

    Webservice static Boolean checkCallIsPersonAccount(String callId) {
        return [SELECT Account_vod__r.isPersonAccount FROM Call2_vod__c WHERE Id = :callId].Account_vod__r.isPersonAccount;
    }

    Webservice static Response createReferral(ReferralInfo refInfo) {
        Response callResponse = new Response();
        SavePoint savePoint = Database.setSavePoint();

        try {
            callResponse = intCreateReferral(refInfo, callResponse);
        } catch (Exception e) {
            Database.rollback (savePoint);
            callResponse.ErrorMessage = e.getMessage();
            callResponse.RequestIdResponseIdList = new List<RequestIdResponseIdMap>();
            iPhoneBase.handleException(e, UserInfo.getUserId(), (refInfo.isOtrRequest == true ? 'OTR' : null),
                    'Create Referral', iPhoneApex_2.ReferralInfo.class, refInfo.RequestId, refInfo,
                    '[iPhoneApex] Error while creating Referral');
            callResponse = checkManualFix(callResponse);
        }

        callResponse.EndTime = DateTime.now();
        callResponse.DebugInfo.refresh();
        return callResponse;
    }

    private static Response intCreateReferral(ReferralInfo refInfo, Response callResponse) {
        List<String> acctIds = new List<String>();
        if (refInfo.AccountId != null) {
            acctIds.add(refInfo.AccountId);
        }

        Map<String, String> mapMergedAccountIds = iPhoneApexUtil_2.findMergedAccounts(acctIds);

        GNE_Med_iPhone_CreateReferral.ReferralInfo refferalInfo = new GNE_Med_iPhone_CreateReferral.ReferralInfo();
        refferalInfo.RequestId = refInfo.RequestId;
        refferalInfo.AccountId = getWinnerAccountId(mapMergedAccountIds, refInfo.AccountId);
        refferalInfo.AddressId = refInfo.AddressId;
        refferalInfo.MedicalQuestion = refInfo.MedicalQuestion;
        refferalInfo.FollowupMethod = refInfo.FollowupMethod;
        refferalInfo.ProductId = refInfo.ProductId;
        refferalInfo.MoleculeId = refInfo.MoleculeId;
        refferalInfo.TA_SubTAId = refInfo.TA_SubTAId;
        refferalInfo.RequestedCompletionDate = refInfo.RequestedCompletionDate;
        refferalInfo.Priority = refInfo.Priority;
        refferalInfo.RequestedById = refInfo.RequestedById;
        refferalInfo.isMedComm = refInfo.isMedComm;
        refferalInfo.UserId = refInfo.UserId;
        refferalInfo.AssignedToId = refInfo.AssignedToId;
        refferalInfo.phone = refInfo.customPhone;

        GNE_Med_iPhone_CreateReferral.Response createRefResponse = GNE_Med_iPhone_CreateReferral.intCreateReferral(
                refferalInfo, new GNE_Med_iPhone_CreateReferral.Response());
        callResponse.RequestIdResponseIdList = new List<RequestIdResponseIdMap>();

        RequestIdResponseIdMap requestIdResponseIdItem = new RequestIdResponseIdMap();
        requestIdResponseIdItem.RequestId = refInfo.RequestId;
        requestIdResponseIdItem.ObjectType = 'Medical_Communication_gne__c';
        requestIdResponseIdItem.ResponseId = createRefResponse.getResponseReferral().Id;
        callResponse.RequestIdResponseIdList.add (requestIdResponseIdItem);
        system.debug('ResponseHere : ' + String.valueOf(callResponse));
        GNE_Referral_Utils.isMedicalReferral = false;

        return callResponse;
    }

    private static Response checkManualFix(Response response) {
        try {
            Object manualFixResponse = iPhoneBase.getManualFixResponse();
            response = manualFixResponse != null ? (Response) manualFixResponse : response;
        } catch (Exception e) {
        }

        return response;
    }
}