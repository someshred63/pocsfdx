/**
* @author GFRS Dev Team
* @date 28/06/2013
* @description gFRS_Util class - utility Class for the GFRS application. 
*/
public with sharing class gFRS_Util {

    public static Boolean isTest = false;
    public static final String DOES_NOT_MATCH_FILTER = 'does not match filter criteria';
    public static GFRS_OrgSettings__c cs = GFRS_OrgSettings__c.getOrgDefaults();

    public static String getCustomSettingStringValue(String csName) {
        return String.valueOf(cs.get(csName + '__c'));
    }

    //-- Literal Constants
    public static final String FUNDING_REQUEST_API_NAME = 'gFRS_Funding_Request__c';
    public static final String ORGANIZATION_API_NAME = 'gFRS_Organization__c';
    public static final String PROGRAM_API_NAME = 'GFRS_Program__c';
    public static final String MCS_GROUP_NAME = 'GNE-GFRS-M&CS';

    public static Boolean firstFundingRequestBeforeTriggerExecution = true;
    public static Boolean firstFundingRequestAfterTriggerExecution = true;

    public static final String TYPE_CORPORATE_MEMBERSHIPS = 'Corporate_Memberships';
    public static final String TYPE_EXHIBHITS_OTHER_PROMOS = 'Exhibits_Other_Promos';
    public static final String TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO = 'Sci_Pipeline_Exhibits_Other_Non_Promo';
    public static final String TYPE_FELLOWSHIPS = 'Fellowships';
    public static final String TYPE_FIELD_INITIATED_EXHIBITS = 'Field_Initiated_Exhibits';
    public static final String TYPE_HC_CHAR = 'HC_CHAR';
    public static final String TYPE_IMED = 'IMED';
    public static final String TYPE_PHILANTHROPIC = 'Philanthropic';
    public static final String TYPE_SCIENTIFIC_PROJECTS = 'Scientific_Projects';
    public static final String Sub_Type_Exhibit_Booth = 'Exhibit Booth';
    public static final String Sub_Type_Sponsorship = 'Sponsorship';

    public static final String TYPE_CORPORATE_MEMBERSHIPS_NAME = 'Corporate Memberships';
    public static final String TYPE_EXHIBHITS_OTHER_PROMOS_NAME = 'Exhibits & Other Promos';
    public static final String TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME = 'Sci/Pipeline Exhibits & Other Non-Promo';
    public static final String TYPE_FELLOWSHIPS_NAME = 'Fellowships';
    public static final String TYPE_FIELD_INITIATED_EXHIBITS_NAME = 'Field Initiated Exhibits';
    public static final String TYPE_HC_CHAR_NAME = 'HC Char';
    public static final String TYPE_IMED_NAME = 'IMED';
    public static final String TYPE_PHILANTHROPIC_NAME = 'Philanthropic';
    public static final String TYPE_SCIENTIFIC_PROJECTS_NAME = 'Scientific Projects';

    public static final String TYPE_CORPORATE_MEMBERSHIPS_DESCRIPTION = 'Corporate Memberships';
    public static final String TYPE_EXHIBHITS_OTHER_PROMOS_DESCRIPTION = 'Exhibits & Other Promotional Payments';
    public static final String TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_DESCRIPTION = 'Scientific Pipeline Exhibits & Other Non-Promotional';
    public static final String TYPE_FELLOWSHIPS_DESCRIPTION = 'Fellowships';
    public static final String TYPE_FIELD_INITIATED_EXHIBITS_DESCRIPTION = 'Field-Initiated Exhibits';
    public static final String TYPE_HC_CHAR_DESCRIPTION = 'Healthcare-Related Charitable Support';
    public static final String TYPE_IMED_DESCRIPTION = 'Independent Medical Education';
    public static final String TYPE_PHILANTHROPIC_DESCRIPTION = 'Philanthropic Charitable Support';
    public static final String TYPE_SCIENTIFIC_PROJECTS_DESCRIPTION = 'Scientific Project Support';

    public static final String TYPE_CORPORATE_MEMBERSHIPS_LETTER = 'Corporate Memberships';
    public static final String TYPE_EXHIBHITS_OTHER_PROMOS_LETTER = 'Exhibits and Other Promotional Payments';
    public static final String TYPE_FELLOWSHIPS_LETTER = 'Fellowships';
    public static final String TYPE_FIELD_INITIATED_EXHIBITS_LETTER = 'Exhibits and Other Promotional Payments';
    public static final String TYPE_HC_CHAR_LETTER = 'Healthcare-Related Charitable Support, Healthcare-Related Charitable Support for Meetings or Patient Education and Outreach';
    public static final String TYPE_PHILANTHROPIC_LETTER = 'Healthcare-Related Charitable Support, Healthcare-Related Charitable Support for Meetings or Patient Education and Outreach';

    public static final String PATH_PROGRAM = '/apex/gFRS_Program';
    public static final String PATH_PROGRAMDESIGN = '/apex/gFRS_ProgramDesign';
    public static final String PATH_DEMOGRAPHIC = '/apex/GFRS_DemographicGroups';
    public static final String PATH_THIRDPARTY = '/apex/gFRS_ThirdParty';
    public static final String PATH_APPLICATION = '/apex/GFRS_Application';
    public static final String PATH_BUDGET = '/apex/gFRS_Budget';
    public static final String PATH_CONFIRMATION = '/apex/GFRS_Confirmation';
    public static final String PATH_CHANGEAPPROVER = '/apex/GFRS_ChangeApprover';

    public static final String TYPE_HC_CHAR_SAP = 'Health Care-Related Charitable';
    public static final String TYPE_IMED_SAP = 'Independent Medical Education';
    public static final String TYPE_PHILANTHROPIC_SAP = 'Philanthropic Charitable';
    public static final String TYPE_SCIENTIFIC_PROJECTS_SAP = 'Scientific Project Support';
    public static final String TYPE_FELLOWSHIPS_SAP = 'Fellowships';
    public static final String TYPE_CORPORATE_MEMBERSHIPS_SAP = 'Corporate Memberships';
    public static final String TYPE_EXHIBHITS_OTHER_PROMOS_SAP = 'Exhibits & Other Promo';
    public static final String TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_SAP = 'Sci/Pipeline Exhibits & Other Non-Promo';
    public static final String TYPE_FIELD_INITIATED_EXHIBITS_SAP = 'Field-Initiated Exhibits';

    public static final String PROFILE_NAME_GFRS_ADMIN = 'GNE-GFRS-Admin';
    public static final String PROFILE_NAME_GNEGFRSEXTERNALREQUESTOR = 'GNE-GFRS-External Requestor';
    public static final String PROFILE_NAME_SYS_ADMIN = 'System Administrator';
    public static final String PROFILE_NAME_SUPER_USER = 'GNE-GFRS-Super User';
    public static final String PROFILE_NAME_USER = 'GNE-GFRS-User';
    public static final String PROFILE_NAME_SYS_SUPPORT = 'GNE-SYS-Support';
    public static final String PROFILE_NAME_NO_SSO_SUPER_USER = 'GNE-GFRS-NoSSO-Super User';
    public static final String PROFILE_NAME_GRANT_COORDINATOR = 'GNE-GFRS-Grant Coordinator';
    public static final String PROFILE_NAME_BACKOFFICE = 'GNE-GFRS-Backoffice';


    /* gRFS Funding Request Approve statuses*/
    public static final String FUNDING_REQUEST_APPROVE_TYPE_APPROVED = 'Approved';
    public static final String FUNDING_REQUEST_APPROVE_TYPE_REJECTED = 'Rejected';
    public static final String FUNDING_REQUEST_APPROVE_TYPE_CANCELED = 'Canceled';

    public static final String INFO_NEEDED_ORGANIZATION = 'Organization';
    public static final String INFO_NEEDED_LOCATION = 'Location';
    public static final String INFO_NEEDED_APPLICATION = 'Application';
    public static final String INFO_NEEDED_PROGRAM_DESIGN = 'Program Design';
    public static final String INFO_NEEDED_THIRD_PARTY = 'Third Party';
    public static final String INFO_NEEDED_PROGRAM = 'Program';
    public static final String INFO_NEEDED_BUDGET = 'Budget';
    public static final String INFO_NEEDED_PAYMENT_METHOD   = 'Payment Method';    
    public static final String INFO_NEEDED_FILE_ATTACHMENTS = 'Attachments';

    public static final String RT_PAYHISTORY_READONLY = 'ReadOnly';

    public static final String RT_ORG_INTERNAL = 'Internal';
    public static final String RT_ORG_EXTERNAL = 'External';

    public static final String RT_LOC_INTERNAL = 'Internal';
    public static final String RT_LOC_EXTERNAL = 'External';

    public static final String RT_PROGRAM_SUFFIX = ' - Program';

    public static final String BUDGET_RT_IMED = 'IMED';
    public static final String BUDGET_RT_CAPP = 'CAPP';
    public static final String BUDGET_RT_DEV = 'DEV';

    public static final String PAYMENT_TYPE_PAYMENT = 'Payment';
    public static final String PAYMENT_ACTION_SENT = 'Payment Sent';

    public static final String TYPE_SCIENTIFIC_PROJECTS_LETTER = 'Scientific Project';

    //-- content filters
    public static final String FILTER_GCAL = 'Google Calendar';

    //-- content keys
    public static final String KEY_GCAL_FILTER = 'gcal Footer';

    public static final String SUNSHINE_ACT_DISCLOSURE_REQUEST_COMMUNICATION_NAME = 'Sunshine Act Disclosure Request Communication';

    public static final String PROGRAM_PAGE = '/apex/GFRS_Program';
    public static final String BUDGET_PAGE = '/apex/GFRS_Budget';

    /** deprecated, use Type until the data can be cleared to ensure type exists **/
    public static final String BUDGET_DESC_LIVE = 'Budget for Live Activity';
    public static final String BUDGET_DESC_WEB = 'Budget for Webinar Activity';
    public static final String BUDGET_DESC_ENDURE = 'Budget for Enduring Activity';

    public static final String BUDGET_TYPE_LIVE = 'Live';
    public static final String BUDGET_TYPE_WEB = 'Web';
    public static final String BUDGET_TYPE_ENDURING = 'Enduring';

    public static final String PROGRAM_TYPE_LIVE = 'Live';
    public static final String PROGRAM_SUBTYPE_GRAND_ROUNDS_LIVE = 'Grand Rounds: Live';
    public static final String PROGRAM_SUBTYPE_MEETING_SERIES = 'Meeting Series: Live';
    public static final String PROGRAM_STATUS_CANCELLED = 'Canceled';

    public static final String FMV_SYMPOSIUM = 'Symposia';
    public static final String FMV_ENDURING = 'Enduring Materials';
    public static final String FMV_GRAND = 'Grand Rounds';

    public static final String FMV_HEADER_TOTAL_ACT_ATTENDEE = 'Total Activity Attendee Cost';
    public static final String FMV_HEADER_TOTAL_ACT_EVENT = 'Total Event Activity Cost';
    public static final String FMV_HEADER_TOTAL_MANAGMENT = 'Total Management Fees';
    public static final String FMV_HEADER_PASS_THROUGH = 'Pass Through Cost';

    public static final String REQUEST_STATUS_HC_COMPLIANCE = 'HC Compliance';
    public static final String REQUEST_STATUS_PRICESSING_DISPOSITION = 'Processing & Disposition';
    public static final String REQUEST_STATUS_DECISION = 'Decision';
    public static final String PROGRAM_STATUS_CONFIRMED = 'Confirmed';
    public static final String PROGRAM_STATUS_COMPLETED = 'Completed';
    public static final String REQUEST_STATUS_RFI = 'RFI';
    public static final String REQUEST_STATUS_CLOSED = 'Closed';
    public static final String REQUEST_UPDATE_STATUS_CAPP_LR = 'CAPP-DEV-LR';
    public static final String REQUEST_UPDATE_STATUS_CAPP_BR = 'CAPP-DEV-BR';
    public static final String REQUEST_SUB_STATUS_BUSINESS_REV = 'Business Review';
    public static final String REQUEST_SUB_STATUS_MANAGER_REVIEW = 'Manager Review';
    public static final String REQUEST_SUB_STATUS_LEGAL_REV = 'Legal Review';
    public static final String REQUEST_SUB_STATUS_RECONCILE_REQ = 'Reconciliation Required';
    public static final String REQUEST_SUB_STATUS_REFUND_REQ = 'Refund Required';
    public static final String REQUEST_SUB_STATUS_APPROVED = 'Approved';
    public static final String REQUEST_SUB_STATUS_APPROVED_STATUS_UPDATES_OUTCOMES = 'Approved-Status Updates/Outcomes';
    public static final String REQUEST_SUB_STATUS_WAITING_LOA = 'Approved-Awaiting LOA';
    public static final String REQUEST_SUB_STATUS_PAYMENT = 'Process Payment';
    public static final String REQUEST_SUB_STATUS_EVALUATIONS = 'Approved-Program Evaluations';
    public static final String REQUEST_SUB_STATUS_CCO = 'CCO Review';
    public static final String REQUEST_SUB_STATUS_GC = 'GC Review';
    public static final String REQUEST_SUB_STATUS_NEW = 'New';
    public static final String REQUEST_SUB_STATUS_CANCELLED = 'Canceled';
    public static final String REQUEST_SUB_STATUS_FINANCIAL_APPROVAL = 'Financial Approval';
    public static final String REQUEST_SUB_STATUS_SUNSHINE = 'Sunshine Act Disclosure';
    public static final String REQUEST_EXTERNAL_SUB_STATUS_APPROVED = 'Approved';
    public static final String REQUEST_EXTERNAL_SUB_STATUS_FUNDING_TYPE_CHANGED = 'RFI - Funding Type Changed';

    public static final String REQUEST_BENEFITS_EXCHANGED_EXHIBIT_SPACE = 'Exhibit space';
    public static final String REQUEST_BENEFITS_EXCHANGED_EXHIBIT_SPACE_PREF_LOC = 'Exhibit space (Preferred Location)';

    public static final String IS_SUCCESSFULLY_RELEASED = 'is successfully released';
    public static final String IS_SUCCESSFULLY_SUBMITTED = 'successfully submitted to sap';

    public static final String REQUEST_UPDATE_STATUS_FIELD_EXHIB = 'FIELD-EXHB-LR';

    public static final String REQUEST_DEFAULT_STATUS = 'Intake';
    public static final String REQUEST_DEFAULT_SUB_STATUS = 'Not Submitted';

    /** Default number of third party records for a funding reqeust **/
    public static final Integer REQUEST_DEF_THIRD_PARTY_COUNT = 4;

    public static final String FUNDING_TYPE_IMED = 'CME';
    public static final String FUNDING_TYPE_HCCHAR = 'HCCHAR';

    public static final String OPERATION_TYPE_CREATE = 'CREATE';
    public static final String OPERATION_TYPE_UPDATE = 'UPDATE';
    public static final String OPERATION_TYPE_DELETE = 'DELETE';

    public static final String NOT_IN_BLACKLIST = '';

    public static final String YES = 'Yes';
    public static final String NO = 'No';
    public static final String BOOL_TRUE = 'True';
    public static final String BOOL_FALSE = 'False';

    public static final String FOUNDATION_TRUE = 'TRUE';
    public static final String FOUNDATION_FALSE = 'FALSE';

    public static final String SHARING_READ = 'Read';
    public static final String SHARING_WRITE = 'Edit';

    public static final String GFRS_WS_PARAM_AUTHORIZATION = 'Authorization';

    public static final String EXHIBIT_AVAILABLE = 'Exhibit opportunities are available for a separate fee';
    public static final String EXHIBIT_NOT_AVAILABLE = 'Exhibit opportunities are not available for a separate fee';

    public static final String SFDC_ORANGE_POUCH = 'Orange Pouch';
    public static final String SFDC_VENDOR = 'Vendor';
    public static final String SFDC_SALES_REP = 'Field Sales Rep';

    public static final String ESB_ORANGE_POUCH = 'OrangePouch';
    public static final String ESB_VENDOR = 'Vendor';
    public static final String ESB_SALES_REP = 'SalesRep';

    public static final String ESB_CHEQUE = 'Cheque';
    public static final String ESB_ACH = 'Ach';


    public static final String DELIVERY_METHOD_MANUAL = 'Manual';

    public static final String EXHIBIT_SPACE = 'Exhibit space';
    public static final String EXHIBIT_SPACE_PREF_LOCATION = 'Exhibit space (Preferred Location)';

    public static final String TASK_ONGOING = 'Ongoing';
    public static final String TASK_COMPLETED = 'Completed';
    public static final String TASK_NOT_COMPLETED = 'Not Completed';
    public static final String TASK_NOT_STARTED = 'Not Started';
    public static final String TASK_NOT_SUBMITTED = 'Not Submitted';
    public static final String TASK_SUBMITTED = 'Submitted';

    public static final String NOT_APPLICABLE_STRING = 'Not Applicable';
    public static final String NON_OF_THE_ABOVE_STRING = 'None of the above';

    /** Approval SubStatus Steps **/
    public static final String APPROVAL_GC = 'GC';
    public static final String APPROVAL_BUSINESS_REV = 'Business Review';
    public static final String APPROVAL_LEGAL_REV = 'Legal Review';
    public static final String APPROVAL_BUSINESS_APPROVER = 'Business Approval';
    public static final String APPROVAL_BUSINESS_APPROVER_1 = 'Business Approver 1';
    public static final String APPROVAL_FINANCIAL_APPROVER_2 = 'Financial Approver 2';

    public static final Decimal FLOAT_TOLERANCE = 0.0001;

    public static final Map<String, String> DEF_GL_ACCS_BY_TYPE = new Map<String, String>{
            gFRS_Util.TYPE_IMED_NAME => System.Label.gFRS_GL_Account_IMED,
            gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME => System.Label.gFRS_GL_Account_FIE,
            gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME => System.Label.gFRS_GL_Account_Exhibits,
            gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME => System.Label.gFRS_GL_Account_Corpo_Memberships,
            gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME => System.Label.gFRS_GL_Account_SciencePipeline
    };

    public static final Set<String> INTERNAL_FUNDING_TYPES = new Set<String>{
            gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME, gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME, gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME, gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME
    };


//-- Map to add approved Founding Request
    public static final Set<Id> APPROVAL_IDS = new Set<Id>();

//-- content filter types
/** the Question Filter type **/
    public static final String FILTER_QUESTION = 'Question';
/** the Answer Filter type **/
    public static final String FILTER_ANSWER = 'Answer';

/** the Internal Question Filter type **/
    public static final String FILTER_INTERNAL_QUESTION = 'Internal Question';
/** the Internal Answer Filter type **/
    public static final String FILTER_INTERNAL_ANSWER = 'Internal Answer';

    public static final String COUNTRY_US = 'United States';

/** the parameter that describes teh current index in the accordion **/
    public static final String PARAM_CURRENT_INDEX = 'ci';


/**
* Program/Event type of funding request.
*/
    public static final String REQUEST_PROGRAM_TYPE_CLINICAL_TRIAL = 'Clinical trial';


    public static final String TASK_SUNSHINE_ACT_DISCLOSURE = 'Sunshine Act Disclosure';

    public static final String TASK_RECONCILIATION = 'Reconciliation';
    public static final String TASK_CHANGE_FUNDING_TYPE = Label.gFRS_ChangeFundingType;

    public static Boolean firstRun = true;
/**
* @author GFRS Dev Team
* @date 26/11/2013
* @description floatEquals method - Determines whether two float values are within a specific tolerance from each other.
*/
    public static Boolean floatEquals(Decimal val1, Decimal val2) {
        return(Math.abs(val1 - val2) <= FLOAT_TOLERANCE);
    }

/**
* @author GFRS Dev Team
* @date 26/11/2013
* @description initializeLink method - Intializes the url to include the funding request id, to ensure it is passed along.
*  <p>The decision was made to use this since session variables and view
*  states will not suffice.</p>
*/
    public static String initializeLink(String targetPage, GFRS_Funding_Request__c request, String parameters) {
        String result = targetPage + '?t=t';
        if (request != null && request.Id != null) result += '&id=' + request.Id;
        if (parameters != null) result += '&' + parameters;
        return(result);
    }


/**
* @author GFRS Dev Team
* @date 26/11/2013
* @description initializeLinkById method - Initialize the URL with parameters - one of them is a Funding Request Id.
*/
    public static String initializeLinkById(String targetPage, Id requestId, String parameters) {
        String result = targetPage + '?t=t';
        if (requestId != null) result += '&id=' + requestId;
        if (parameters != null) result += '&' + parameters;
        return(result);
    }


/**
* @author GFRS Dev Team
* @date 26/11/2013
* @description convertPicklistOptions method - Converts a list of picklist values into a comma separated String.
*/
    public static String convertPicklistOptions(Schema.PicklistEntry[] picklistEntries) {
        if (picklistEntries == null) {
            return('');
        }
        String result = '';
        Boolean isFirst = true;
        for (Schema.PicklistEntry entry : picklistEntries) {
            result += (isFirst ? '' : ',') + entry.getValue();
            isFirst = false;
        }
        return(result);
    }


/**
* @author GFRS Dev Team
* @date 26/11/2013
* @description assignSObjectValue method - Assigns a specific field and value to a specific SObject.
*/
    public static Boolean assignSObjectValue(SObject obj, String fieldName, String value) {

//-- TODO: change the logic to utilize a describe instead (but unable to find how to accomplish this from a string name for now)

        try {
            obj.put(fieldName, value);
            return(true);
        } catch (Exception err) {
        }

//-- did not return so contine
        try {
//-- try converting to Integer
            obj.put(fieldName, Integer.valueOf(value));
            return(true);
        } catch (Exception err) {
        }

//-- did not return so contine
        try {
//-- try converting to Decimal
            obj.put(fieldName, Decimal.valueOf(value));
            return(true);
        } catch (Exception err) {
        }

//-- did not return so contine
        System.debug('unable to set the right type[' + obj.Id + ':' + fieldName + ':' + value + ']');
        return(false);
    }

/**
* @author GFRS Dev Team
* @date 26/11/2013
* @description getContactOrganization method - Method used to allow either the link of the user's contact
* or the method by finding the organization aligned with the same account as the contact (deprecated)
* Once the second method is no longer supported, this method should only support the former.
*/
    public static GFRS_Organization__c getContactOrganization(Contact userContact) {
        if (userContact == null) {
            return(null);
        } else if (userContact.Organization__r != null) {
            return(userContact.Organization__r);
        } else {
            if (userContact.AccountId != null) {
                return(gFRS_Util.getAccountOrganization(userContact.AccountId));
            } else if (userContact.Account.Id != null) {
                return(gFRS_Util.getAccountOrganization(userContact.Account.Id));
            } else {
                System.debug('account not selected for contact, nor link for organization found. nothing to do.');
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to find user\'s organization. Please contact your system administrator'));

//-- nothing to do
                return(null);
            }
        }
    }


/**
* @author GFRS Dev Team
* @date 26/11/2013
* @description getAccountOrganization method - Determines the Organization affiliated with a specific account.
*/
    public static GFRS_Organization__c getAccountOrganization(Id accountId) {
        System.debug('organization connected with account: ' + accountId);
        GFRS_Organization__c[] organizations = [
                SELECT Id, Tax_Id__c
                FROM GFRS_Organization__c
                WHERE Account__c = :accountId
        ];
        if (organizations == null || organizations.size() < 1) {
            System.debug('no organization found');
            return(null);
        } else if (organizations.size() > 1) {
            System.debug('more than one organization associated to this account...');
            return(null);
        } else {
            return(organizations[0]);
        }
    }


/**
* @author GFRS Dev Team
* @date 26/11/2013
* @description isBlacklistedOrganization method - Determines whether an organization is blacklisted.
*/
    public static Boolean isBlacklistedOrganization(String taxId, String nonUsTaxId, String recordType) {
        if (taxId == null && nonUsTaxId == null) return(false);
        GFRS_Organization__c[] organizations = null;
        if (taxId != null) {
            organizations = [
                    SELECT Id, Exclusion_Blacklist_Reasons__c, Funding_Type_Specific_Blacklist__c
                    FROM GFRS_Organization__c
                    WHERE Tax_Id__c = :taxId
                    LIMIT 1
            ];
        } else if (nonUsTaxId != null) {
            organizations = [
                    SELECT Id, Exclusion_Blacklist_Reasons__c, Funding_Type_Specific_Blacklist__c
                    FROM GFRS_Organization__c
                    WHERE Non_US_Organization_ID__c = :nonUsTaxId
                    LIMIT 1
            ];
        }
        if (organizations == null || organizations.size() < 1) {
            return(false);
        }

        GFRS_Organization__c org = organizations[0];
        System.debug('org:[' + org.Exclusion_Blacklist_Reasons__c + ']:' + org);
//change conditon for SFDC-2017
        String fundingBlackListed = org.Funding_Type_Specific_Blacklist__c == null ? null : org.Funding_Type_Specific_Blacklist__c.toLowerCase().replace('&', '').replace('  ', ' ');
//fundingBlackListed=
        if (recordType.equals('Exhibits_Promo_Sponsorship')) {
            recordType = 'Exhibits_Other_Promos';
        }
        if (fundingBlackListed != null && fundingBlackListed.contains(recordType.toLowerCase().replace('_', ' '))) {
            return(true);
        } else if (org.Exclusion_Blacklist_Reasons__c != null && org.Exclusion_Blacklist_Reasons__c != '') {
            return(true);
        } else {
            return false;
        }
    }


/**
* @author GFRS Dev Team
* @date 26/11/2013
* @description createDefaultFRPrograms method - Adds a default program when a funding Request is created.
*/
    public static GFRS_Program__c[] createDefaultFRPrograms(GFRS_Funding_Request__c[] fundingRequests) {
        GFRS_Program__c[] programs = createFundingRequestPrograms(fundingRequests);
        insert programs;
        return(programs);
    }


/**
* @author GFRS Dev Team
* @date 26/11/2013
* @description createFundingRequestPrograms method - Creates a list of programs for a set of funding requests.
*/
    public static GFRS_Program__c[] createFundingRequestPrograms(GFRS_Funding_Request__c[] requests) {

        Map<String, Id> recordTypeMap = getProgramRecordTypeMap(requests);
        GFRS_Program__c[] newPrograms = new GFRS_Program__c[]{
        };
        String programType = gFRS_Util.BUDGET_TYPE_LIVE;
        for (GFRS_Funding_Request__c request2 : requests) {
            String recordTypeName = request2.Record_Type_Name__c + gFRS_Util.RT_PROGRAM_SUFFIX;
            if( recordTypeMap.containsKey( recordTypeName )){
                gFRS_Program__c newProgram = new GFRS_Program__c( Funding_Request__c = request2.id, Type__c = programType, Expected_of_attendees_that_are_HCPs__c = 0, RecordTypeId =  recordTypeMap.get( recordTypeName ) );

/*
if( gFRS_Util.TYPE_IMED_NAME.equals( request2.Record_Type_Name__c )){
    newProgram.Venue_Country__c = gFRS_Util.COUNTRY_US;
}
*/

                newPrograms.add(newProgram);
            }
        }
        return(newPrograms);
    }

/**
* @author GFRS Dev Team
* @date 10/10/2018
* @description getProgramRecordTypeMap method - Return map record type name to record type id for provided requests
*/
    public static Map<String, Id> getProgramRecordTypeMap(GFRS_Funding_Request__c[] requests) {
        Set<String> recordTypes = new Set<String>();
        for (GFRS_Funding_Request__c request : requests) {
            String recordTypeName = request.Record_Type_Name__c + gFRS_Util.RT_PROGRAM_SUFFIX;
            recordTypes.add(recordTypeName);
        }
        Map<String, Id> recordTypeMap = new Map<String, Id>();
//-- convert the list of recordTypes into a map
        for (RecordType rt : [SELECT Name, Id FROM RecordType WHERE Name IN :recordTypes]) {
            recordTypeMap.put(rt.Name, rt.Id);
        }
        return recordTypeMap;
    }


/**
* @author GFRS Dev Team
* @date 27/11/2013
* @description getPrettyDMLMessage method - Creates a Program for a funding request.
*/
    public static GFRS_Program__c createFundingRequestProgram(GFRS_Funding_Request__c fundingRequest) {
        GFRS_Program__c[] results = createFundingRequestPrograms(new GFRS_Funding_Request__c[]{
                fundingRequest
        });
        return((results != null && results.size() > 0) ? results[0] : null);
    }


/**
* @author GFRS Dev Team
* @date 27/11/2013
* @description getPrettyDMLMessage method - Determines if an item is in a multi-select list.
* @return (Boolean) - if the value exists in the multi-select (true) or not (false)
*/
    public static Boolean multiSelectHasItem(String multiSelect, String itemToFind) {
        if (multiSelect == null) return(null);

        return(multiSelect.indexOf(itemToFind) > -1);
    }


/**
* @author GFRS Dev Team
* @date 27/11/2013
* @description addMultiSelectItem method - Adds an item to a multi-select list (only if it does not already exist).
* @return String - the new multiselect string value
*/
    public static String addMultiSelectItem(String multiSelect, String itemToAdd) {
        if (multiSelect == null) {
            return(itemToAdd);
        } else if (multiSelect.indexOf(itemToAdd) > -1) {
//-- @TODO: address check if itemToAdd is a substring of another item. i.e. 'Item' in 'cuca;Item' works, but not 'cuca;My_Item';
//-- item already exists
            return(multiSelect);
        } else {
            return(multiSelect + ';' + itemToAdd);
        }
    }


/**
* @author GFRS Dev Team
* @date 27/11/2013
* @description removeMultiSelectItem method - Removes a multiselect item from the list.
* @return String - the new multiselect without the item
*/
    public static String removeMultiSelectItem(String multiSelect, String itemToRemove) {
        if (multiSelect == null) {
            return(null);
        } else {
            String newValue = multiSelect;
            newValue = newValue.replaceAll('^' + itemToRemove + '(;|$)', '');
            newValue = newValue.replaceAll(';' + itemToRemove + '(;|$)', '$1');
            return(newValue);
        }
    }


/**
* @author GFRS Dev Team
* @date 27/11/2013
* @description getPrettyDMLMessage method - Determines the current accordion index.
* @return (Integer) - the integer of the index sent or 0 if one could not be not be found
*/
    public static Integer getCurrentIndex() {
        Map<String, String> params = ApexPages.currentPage().getParameters();
        try {
            String cIndex = params.get(PARAM_CURRENT_INDEX);
            return(Integer.valueOf(cIndex));
        } catch (Exception err) {
//-- occurs if an invalid value is sent or is not an integer
            return(0);
        }
    }


/**
* @author GFRS Dev Team
* @date 27/11/2013
* @description getPrettyDMLMessage method - Determines an id sent from the parameters.
*/
    public static Id getSentId(String paramName) {
        Map<String, String> params = ApexPages.currentPage().getParameters();
        String sentId = null;
        try {
            if (params.containsKey(paramName)) {
                sentId = params.get(paramName);
                return(Id.valueOf(sentId));
            } else {
                return(null);
            }
        } catch (Exception err) {
            System.debug('unable to translate id:' + sentId);
            return(null);
        }
    }


/**
* @author GFRS Dev Team
* @date 27/11/2013
* @description getPrettyDMLMessage method - Turns a DML Exception into a list of error message strings.
*/
    public static String getPrettyDMLMessage(DmlException err) {
        String errMsg = '';
        for (Integer errorIndex = 0; errorIndex < err.getNumDml(); errorIndex++) {
            errMsg += err.getDmlMessage(errorIndex);
        }
        return(unescapeHTML(errMsg));
    }


/**
* @author GFRS Dev Team
* @date 27/11/2013
* @description getPrettyMessage method - Turns a standard Exception into a list of error message strings.
*/
    public static String getPrettyMessage(Exception err) {

//-- unfortunately, I'm unsure of a better way to try to cast
        try {
            DmlException dErr = (DmlException) err;
            return(getPrettyDMLMessage(dErr));
        } catch (Exception e) {
        }

//-- try as standard exception type
        return(unescapeHTML(err.getMessage()));
    }


/**
* @author GFRS Dev Team
* @date 27/11/2013
* @description unescapeHTML method - Unescapes html code to standard text.
*/
    public static String unescapeHTML(String str) {
        System.debug('beforeunescape:' + str);
        if (str == null) return(null);

        str = str.replaceAll('&amp;', '&');
        str = str.replaceAll('&quot;', '"');

        System.debug('after unescape:' + str);

        return(str);
    }


/**
* @author GFRS Dev Team
* @date 27/11/2013
* @description getRecordTypeDescription method - Return a default value if the test value is null.
*/
    public static String blankValue(String testValue, String defaultValue) {
        if (testValue == null) {
            return(defaultValue);
        } else {
            return(testValue);
        }
    }


/**
* @author GFRS Dev Team
* @date 27/11/2013
* @description getRecordTypeDescription method - Return full text description for  given record type.
*/
    public static String getRecordTypeDescription(String recordTypeName) {
        if (recordTypeName == TYPE_CORPORATE_MEMBERSHIPS_NAME) {
            return(TYPE_CORPORATE_MEMBERSHIPS_DESCRIPTION);
        } else if (recordTypeName == TYPE_EXHIBHITS_OTHER_PROMOS_NAME) {
            return(TYPE_EXHIBHITS_OTHER_PROMOS_DESCRIPTION);
        } else if (recordTypeName == TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME) {
            return(TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_DESCRIPTION);
        } else if (recordTypeName == TYPE_FELLOWSHIPS_NAME) {
            return(TYPE_FELLOWSHIPS_DESCRIPTION);
        } else if (recordTypeName == TYPE_FIELD_INITIATED_EXHIBITS_NAME) {
            return(TYPE_FIELD_INITIATED_EXHIBITS_DESCRIPTION);
        } else if (recordTypeName == TYPE_HC_CHAR_NAME) {
            return(TYPE_HC_CHAR_DESCRIPTION);
        } else if (recordTypeName == TYPE_IMED_NAME) {
            return(TYPE_IMED_DESCRIPTION);
        } else if (recordTypeName == TYPE_PHILANTHROPIC_NAME) {
            return(TYPE_PHILANTHROPIC_DESCRIPTION);
        } else if (recordTypeName == TYPE_SCIENTIFIC_PROJECTS_NAME) {
            return(TYPE_SCIENTIFIC_PROJECTS_DESCRIPTION);
        } else {
            return (null);
        }
    }


/**
* @author GFRS Dev Team
* @date 27/11/2013
* @description replaceContentVariable method - Function replaces variable string in content by given value.
*/
    public static String replaceContentVariable(String variableName, String value, String content) {
        value = value != null ? value : '';
        return content.replace(variableName, value);
    }


/**
* @author GFRS Dev Team
* @date 27/11/2013
* @description updateStatusLastModifiedDate2 method - Sets the last date of change of Status__c field.
*/
    public static GFRS_Funding_Request__c[] updateStatusLastModifiedDate2(GFRS_Funding_Request__c[] newRequests, Map<Id, GFRS_Funding_Request__c> oldRequests) {
//-- find all the funding requests that have changed statuses
        GFRS_Funding_Request__c[] updatedStatusRequests = new GFRS_Funding_Request__c[]{
        };
        gFRS_ObjectUtil.filterChangedObjects(newRequests, oldRequests, 'Status__c', updatedStatusRequests);

        GFRS_Funding_Request__c[] requestsToUpdate = new GFRS_Funding_Request__c[]{
        };
        for (GFRS_Funding_Request__c changedRequest : updatedStatusRequests) {
            if (changedRequest.Status__c != null) {
                changedRequest.Status_Last_Modified_Date__c = Date.today();
                requestsToUpdate.add(changedRequest);
            }
        }

//-- update is done through the before insert/update
//if( requestsToUpdate.size() > 0 ) update requestsToUpdate;
        return(requestsToUpdate);
    }


/**
* @author GFRS Dev Team
* @date 27/11/2013
* @description canAccessPage method - Indicates whetrher page should be accessible while filling given Funding Type.
*/
    public static Boolean canAccessPage(String recordType, String pageName) {
        if (pageName.equals(gFRS_Util.PROGRAM_PAGE)) {
            if (recordType.equals(gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME)) {
                return false;
            } else {
                return true;
            }
        } else if (pageName.equals(gFRS_Util.PATH_BUDGET)) {
            if (recordType.equals(gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME) || recordType.equals(gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME) || recordType.equals(gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME) || recordType.equals(gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME)) {
                return false;
            } else {
                return true;
            }
        } else {
            return true;
        }
    }


/**
* @author GFRS Dev Team
* @date 27/11/2013
* @description linkBudgetLIsToFMV method - Creates links from Budget Line Items records to FMV Records.
*/
    public static void linkBudgetLIsToFMV(GFRS_Request_Budget_Line_Item__c[] newBudgetLIs, Map<Id, GFRS_Request_Budget_Line_Item__c> oldBudgetLIsMap) {
/*--
Choice was made to determine whether to select all FMV values, and match against the BudgetLIs
(which loads more FMV records into memory than used)
or use the budget LIs to filter to FMV records that are used
(lowers the number of FMV records used, but increases the execution line count)
--
chose the former as could potentially be fewer FMV records and simpler until it is called for
this also helps to avoid combined keys (where Category=x and SubCategory=y) which would need to utilize formula fields
--*/

//-- UGH this has to change to match the Task

        GFRS_Request_Budget_Line_Item__c[] budgetLIs = [SELECT Id, Name, FMV_Lower__c, Budget__r.Budget_Summary_Description__c, Budget_Category__c, Budget_Subcategory__c, Budget__r.Grant_Request__c FROM GFRS_Request_Budget_Line_Item__c WHERE Id IN :newBudgetLIs];

        GFRS_FMV__c[] eligibleFMVs = [SELECT Id, Lower_Amount__c, Median_Amount__c, Upper_Amount__c, Budget_Category__c, Budget_SubCategory__c, Program_Name__c FROM GFRS_FMV__c];

        Map<String, GFRS_FMV__c> liveMap = new Map<String, GFRS_FMV__c>();
        Map<String, GFRS_FMV__c> enduringMap = new Map<String, GFRS_FMV__c>();
        Map<String, GFRS_FMV__c> grandMap = new Map<String, GFRS_FMV__c>();
        String fmvKey = null;

        for (GFRS_FMV__c fmv : eligibleFMVs) {
            fmvKey = fmv.Budget_Category__c + '-' + fmv.Budget_SubCategory__c;
            if (fmv.Program_Name__c == null) {
            } else if (fmv.Program_Name__c == gFRS_Util.FMV_SYMPOSIUM) {
                liveMap.put(fmvKey, fmv);
            } else if (fmv.Program_Name__c == gFRS_Util.FMV_ENDURING) {
                enduringMap.put(fmvKey, fmv);
            } else if (fmv.Program_Name__c == gFRS_Util.FMV_GRAND) {
                grandMap.put(fmvKey, fmv);
            }
        }
//system.debug(liveMap);
//system.debug(enduringMap);
//system.debug(grandMap);
        GFRS_Request_Budget_Line_Item__c oldBudgetLI = null;
        GFRS_Request_Budget_Line_Item__c[] updatedLIs = new GFRS_Request_Budget_Line_Item__c[]{
        };

        GFRS_FMV__c fmv = null;
        Map<String, GFRS_FMV__c> fmvMap = null;

        GFRS_Request_Budget_Line_Item__c[] eligibleLIs = new GFRS_Request_Budget_Line_Item__c[]{
        };
        gFRS_ObjectUtil.filterChangedObjects(budgetLIs, oldBudgetLIsMap, 'Budget_Subcategory__c', eligibleLIs);

//-- only iterate over those that have changed the subcategory
        for (GFRS_Request_Budget_Line_Item__c budgetLI : eligibleLIs) {

//-- determine which fmvMap we use
            System.debug(budgetLI.Budget__r);
            if (budgetLI.Budget__r.Budget_Summary_Description__c != null && budgetLI.Budget__r.Budget_Summary_Description__c.equals(gFRS_Util.BUDGET_DESC_LIVE)) {
                fmvMap = liveMap;
                System.debug('--------------live');
                GFRS_Program__c[] programList = [SELECT Program_Subtype__c FROM GFRS_Program__c WHERE Funding_Request__c = :budgetLI.Budget__r.Grant_Request__c];
                for (GFRS_Program__c p : programList) {
                    if (p.Program_Subtype__c == gFRS_Util.PROGRAM_SUBTYPE_GRAND_ROUNDS_LIVE) {
                        System.debug('--------------grand');
                        fmvMap = grandMap;
                        break;
                    }
                }
            } else {
                System.debug('--------------enduring');
                fmvMap = enduringMap;
            }
//system.debug(fmvMap);
//-- determine which FMV to use
            fmv = null;
            fmvKey = budgetLI.Budget_Category__c + '-' + budgetLI.Budget_Subcategory__c;
            if (fmvMap.get(fmvKey) != null) {
                System.debug('--------------cat exists');
                fmv = fmvMap.get(fmvKey);
            }
            System.debug('fmvFound:' + fmv);

            if (fmv != null) {
                budgetLI.FMV_Lower__c = fmv.Lower_Amount__c;
                budgetLI.FMV_Median__c = fmv.Median_Amount__c;
                budgetLI.FMV_Upper__c = fmv.Upper_Amount__c;
            } else {
                budgetLI.FMV_Lower__c = null;
                budgetLI.FMV_Median__c = null;
                budgetLI.FMV_Upper__c = null;
            }
            updatedLIs.add(budgetLI);

        }
        System.debug('updatedLIs:' + updatedLIs);

        gFRS_Util_NoShare.saveLockedBudgetLIs(updatedLIs);
    }


/**
* @author GFRS Dev Team
* @date 27/11/2013
* @description assignFinancialApprovers method - Creates links from Budget items to FMV records.
*/
    public static void assignRequestBudgetFMV(GFRS_RequestBudget__c[] newBudgets, Map<Id, GFRS_RequestBudget__c> oldBudgetMap) {
//-- determine the budgets that can be updated
        GFRS_RequestBudget__c[] updatedBudgets = new GFRS_RequestBudget__c[]{
        };

        GFRS_RequestBudget__c[] eligibleBudgets = new GFRS_RequestBudget__c[]{
        };
        gFRS_ObjectUtil.filterChangedObjects(newBudgets, oldBudgetMap, 'Budget_Summary_Description__c', eligibleBudgets);
//System.debug( 'eligibleBudgets:' + eligibleBudgets );

        if (eligibleBudgets == null || eligibleBudgets.size() < 1) return;

//-- determine the FMVs
        GFRS_FMV__c[] eligibleFMVs = [SELECT Id, Lower_Amount__c, Median_Amount__c, Upper_Amount__c, Budget_Category__c, Budget_SubCategory__c, Program_Name__c FROM GFRS_FMV__c];

        Map<String, GFRS_FMV__c> liveMap = new Map<String, GFRS_FMV__c>();
        Map<String, GFRS_FMV__c> enduringMap = new Map<String, GFRS_FMV__c>();
        Map<String, GFRS_FMV__c> grandMap = new Map<String, GFRS_FMV__c>();

        for (GFRS_FMV__c fmv : eligibleFMVs) {
            if (fmv.Program_Name__c == null) {
            } else if (fmv.Program_Name__c == gFRS_Util.FMV_SYMPOSIUM) {
                liveMap.put(fmv.Budget_Category__c, fmv);
            } else if (fmv.Program_Name__c == gFRS_Util.FMV_ENDURING) {
                enduringMap.put(fmv.Budget_Category__c, fmv);
            } else if (fmv.Program_Name__c == gFRS_Util.FMV_GRAND) {
                grandMap.put(fmv.Budget_Category__c, fmv);
            }
        }

        GFRS_FMV__c fmv;
        Map<String, GFRS_FMV__c> fmvMap = null;

        for (GFRS_RequestBudget__c budget : [SELECT Id, Budget_Summary_Description__c, Grant_Request__c FROM GFRS_RequestBudget__c WHERE Id IN :eligibleBudgets]) {
            fmvMap = null;
            if (budget.Budget_Summary_Description__c == gFRS_Util.BUDGET_DESC_LIVE) {
                fmvMap = liveMap;
                GFRS_Program__c[] programList = [SELECT Program_Subtype__c FROM GFRS_Program__c WHERE Funding_Request__c = :budget.Grant_Request__c];
                for (GFRS_Program__c p : programList) {
                    if (p.Program_Subtype__c == gFRS_Util.PROGRAM_SUBTYPE_GRAND_ROUNDS_LIVE) {
                        fmvMap = grandMap;
                        break;
                    }
                }
            } else {
//-- assume enduring for now
                fmvMap = enduringMap;
            }
//System.debug( 'fmvMap:' + fmvMap );


            if (fmvMap != null) {
//-- can switch to optimistic later if the headers are guaranteed
                if (fmvMap.containsKey(gFRS_Util.FMV_HEADER_PASS_THROUGH)) {
                    fmv = fmvMap.get(gFRS_Util.FMV_HEADER_PASS_THROUGH);
                    budget.FMV_Median_Total_Pass_Through__c = fmv.Median_Amount__c;
                }
                if (fmvMap.containsKey(gFRS_Util.FMV_HEADER_TOTAL_ACT_ATTENDEE)) {
                    fmv = fmvMap.get(gFRS_Util.FMV_HEADER_TOTAL_ACT_ATTENDEE);
                    budget.FMV_Median_Total_Activity_Cost__c = fmv.Median_Amount__c;
                }
                if (fmvMap.containsKey(gFRS_Util.FMV_HEADER_TOTAL_ACT_EVENT)) {
                    fmv = fmvMap.get(gFRS_Util.FMV_HEADER_TOTAL_ACT_EVENT);
                    budget.FMV_Median_Total_Activity_Event__c = fmv.Median_Amount__c;
                }
                if (fmvMap.containsKey(gFRS_Util.FMV_HEADER_TOTAL_MANAGMENT)) {
                    fmv = fmvMap.get(gFRS_Util.FMV_HEADER_TOTAL_MANAGMENT);
                    budget.FMV_Median_Total_Management_Fees__c = fmv.Median_Amount__c;
                }
                System.debug('budget:' + budget);
                updatedBudgets.add(budget);
            }
        }

        if (updatedBudgets.size() > 0) gFRS_Util_NoShare.saveLockedBudgets(updatedBudgets);
    }


/**
* @author GFRS Dev Team
* @date 27/11/2013
* @description assignFinancialApprovers method - Method assigns appropriate Financial Approver for given Fundings Requests.
*/
    public static GFRS_Funding_Request__c[] assignFinancialApprovers(GFRS_Funding_Request__c[] newRequests) {
        User curUser = gFRS_Util_NoShare.getUserById(UserInfo.getUserId());
        System.debug('XXXXX method start: ' + curUser);
        GFRS_Funding_Request__c[] newRequestsUpdate = new GFRS_Funding_Request__c[]{
        };
        if (curUser.External_ID_gne__c != null) {
            All_User_Hierarchy_gne__c[] userHierarchies = [SELECT Id, All_User_Hierarchy_Level1_gne__r.User_External_Id_gne__c FROM All_User_Hierarchy_gne__c WHERE User_External_Id_gne__c = :curUser.External_ID_gne__c AND All_User_Hierarchy_Level1_gne__r.User_External_Id_gne__c != NULL];
            System.debug('XXXXX method continuation: ' + userHierarchies);
            if (userHierarchies.size() > 0) {
                User[] user2Bassigned = [SELECT Id FROM User WHERE External_ID_gne__c = :userHierarchies[0].All_User_Hierarchy_Level1_gne__r.User_External_Id_gne__c];
                if (user2Bassigned.size() > 0) {
                    for (GFRS_Funding_Request__c newRequest : newRequests) {
                        if (gFRS_Util.isInternalRequest(newRequest.Record_Type_Name__c)) {
                            GFRS_Funding_Request__c fr2bUpd = new GFRS_Funding_Request__c(Id = newRequest.Id, Financial_Approver_1__c = user2Bassigned[0].Id);
                            newRequestsUpdate.add(fr2bUpd);
                        }
                    }
//-- assume before trigger should update
//update newRequestsUpdate;
                }
            }
        }

        return(newRequestsUpdate);
    }


/**
* @author GFRS Dev Team
* @date 27/11/2013
* @description createActivities method - Create activities  after Funding Request update (called in GFRS_FR_Submit_For_Approval trigger).
*/
    public static void createActivities(GFRS_Funding_Request__c[] newRequests, Map<Id, GFRS_Funding_Request__c> oldMap) {
        GFRS_Funding_Request__c[] filteredRequestsList = new List<GFRS_Funding_Request__c>();
        gFRS_ObjectUtil.filterChangedObjects(newRequests, oldMap, 'Decision_Date__c', filteredRequestsList);
//Fix bug http://jira.intranet.roche.com/jira/browse/SFDC-3816
//preventing before 2 times execution in one context following worfklfow case and
// double execution of this method https://cs1.salesforce.com/01Q70000000BmdP
        for (Integer i = 0; i < filteredRequestsList.size(); i++) {
            if (filteredRequestsList[i].Approved_Awaiting_LOA_Status_Date__c == null) {
                filteredRequestsList.remove(i);
            }
        }
        Map<Id, GFRS_Funding_Request__c> filteredRequestsMap = new Map<Id, GFRS_Funding_Request__c>(filteredRequestsList);
        GFRS_Funding_Request__c oldRequest = null;
        GFRS_Funding_Request__c newRequest = null;
        List<GFRS_Program__c> activitiesToInsert = new List<GFRS_Program__c>();
        Map<Id, List<GFRS_Program_Audience_Group__c>> programAudienceGroupForProgram = new Map<Id, List<GFRS_Program_Audience_Group__c>>();
        Map<Id, Integer> numerOfEachProgram = new Map<Id, Integer>();
        List<Id> orderedProgramOrginalIds = new List<Id>();
        try {
            for (GFRS_Program__c program : filteredRequestsMap.isEmpty() ? new GFRS_Program__c[]{
            } : [
                    SELECT (SELECT Actual_Learners__c, Actual_Learners_with_Credit__c, Actual_Number_Participants__c, Category_of_Credit__c, Credit_Hours__c, Expected_Learners__c, Expected_Learners_Credit__c, Funding_Request__c, Intended_Audience__c, Invitations_Distributed__c, MayEdit, Number_of_Participants__c, Number_of_Speaking__c, Other__c, Specialty__c, Program__c FROM Audience_Groups__r ORDER BY CreatedDate ASC), g.Would_You_Recommend_to_Colleagues_RAC__c, g.Will_Content_Impact_Your_Practice_CIP__c, g.Were_Learning_Objectives_Achieved_LOA__c, g.Web_URL__c, g.Was_the_Activity_Fair_and_Balanced_FAB__c, g.Was_Material_Organized_Clearly_MOC__c, g.Verified__c, g.Venue_Zip_Code__c, g.Venue_Type__c, g.Venue_State__c, g.Venue_Name__c, g.Venue_Country__c, g.Venue_City__c, g.Unique_Visits__c, g.Type__c, g.Total_Visits__c, g.Total_Number_of_Participants__c, g.Total_Number_of_Pages__c, g.Targeted_Visits__c, g.SystemModstamp, g.Support_Purpose_Program_Description__c, g.Status__c, g.Start_Date__c, g.Speakers_Faculty__c, g.Satisfaction_1__c, g.Results_were_Achieved__c, g.RecordTypeId, g.Rating_Against_Other_CME_Activities_AR__c, g.Publicity_Plan__c, g.Promotional_Event_Advertising__c, g.Promotional_Event_Advertising_URL__c, g.Program_URL__c, g.Program_Subtype__c, g.Program_Status__c, g.Program_Reinforce_Current_Patterns_CPP__c, g.Product_being_Promoted__c, g.Percent_Responding_RAC__c, g.Percent_Responding_MOC__c, g.Percent_Responding_LOA__c, g.Percent_Responding_FH__c, g.Percent_Responding_FAB__c, g.Percent_Responding_CVI__c, g.Percent_Responding_CTE__c, g.Percent_Responding_CR__c, g.Percent_Responding_CPP__c, g.Percent_Responding_CIP__c, g.Percent_Responding_ASA__c, g.Percent_Responding_AR__c, g.Percent_Responding_APO__c, g.Percent_Responding_AFU__c, g.Percent_Responding_AAS__c, g.Outstanding_Accounts_Payable__c, g.Outcomes_Review_Comments__c, g.Other_Companies_Supporting_Meeting__c, g.Opt_In_Process_for_Enduring_Materials__c, g.Number_of_Respondents_RAC__c, g.Number_of_Respondents_MOC__c, g.Number_of_Respondents_LOA__c, g.Number_of_Respondents_FH__c, g.Number_of_Respondents_FAB__c, g.Number_of_Respondents_CVI__c, g.Number_of_Respondents_CTE__c, g.Number_of_Respondents_CR__c, g.Number_of_Respondents_CPP__c, g.Number_of_Respondents_CIP__c, g.Number_of_Respondents_ASA__c, g.Number_of_Respondents_AR__c, g.Number_of_Respondents_APO__c, g.Number_of_Respondents_AFU__c, g.Number_of_Respondents_AAS__c, g.Number_of_Pages_Viewed__c, g.Number_of_Learners_del__c, g.Number_of_Learners_Receiving_CME_Credits__c, g.Number_of_Completions__c, g.Number_of_Certificates_Issued__c, g.Number_of_Activities__c, g.Number_Responding_Positively_RA__c, g.Needs_Assessment_Document__c, g.Needs_Assessment_Document_URL__c, g.Name, g.NCI_Designated_Cancer_Center__c, g.Method_for_Measuring_Program_Success__c, g.Meeting_Agenda__c, g.Meeting_Agenda_URL__c, g.Letter_of_Request__c, g.Letter_of_Request_URL__c, g.Launch_Date__c, g.LastModifiedDate, g.LastModifiedById, g.Is_the_Content_Relevant_to_Practice_CR__c, g.Is_Volunteering_Opportunity_Public__c, g.IsDeleted, g.Intended_Audience__c, g.Implementation_Plan__c, g.Implementation_Plan_URL__c, g.If_Yes_Please_Describe_this_Process__c, g.If_Yes_New_Total_Budget_for_Program__c, g.If_Yes_New_Educational_Objectives__c, g.If_Yes_How_Many_Commercial_Supporters__c, g.If_Results_Not_Achieved_State_Why__c, g.If_Known_List_Other_Supporters__c, g.Id, g.Geographic_Region__c, g.Funding_Type__c, g.Funding_Request__c, g.Format_Helpful_in_Achieving_Objective_FH__c, g.Fellowship_Project_Description__c, g.Fellowship_Project_Description_URL__c, g.Expiration_Date__c, g.Expected_of_attendees_that_are_HCPs__c, g.Expected_of_Attendees_US_Based_HCPs__c, g.Expected_Number_of_Attendees__c, g.Event_Program_Type__c, g.Event_Meeting_Membership_Public__c, g.Enduring_Materials_Opt_Out__c, g.Enduring_Materials_Opt_Out_Description__c, g.End_Date__c, g.Employees_with_Advanced_Degrees__c, g.Educational_Objectives_Intended_Outcome__c, g.Does_Event_Have_Volunteering_Opportunity__c, g.Does_Content_Translate_Evidence_CTE__c, g.Did_You_Find_the_Format_to_be_Useful_AFU__c, g.Did_Total_Budget_Amount_for_this_Program__c, g.Did_Educational_Objectives_Change__c, g.Did_Content_Contribute_Valuable_Info_CVI__c, g.Did_Activity_Provide_Interactivity_APO__c, g.Did_Activity_Achieve_Objectives_ASA__c, g.Criteria_for_Fellow_Selection__c, g.CreatedDate, g.CreatedById, g.Change_in_Number_of_Commercial_Supporter__c, g.Booth_Type__c, g.Average_Years_in_Practice__c, g.Average_Number_of_Patients__c, g.Average_Minutes_Per_Visit__c, g.Audience_US_Based__c, g.Audience_Non_US_Based__c, g.Alternate_Program_Title__c, g.Activity_Address_Overcoming_Barrier_AAS__c, g.Activities__c, g.ACGME_Program_Number__c
                    FROM GFRS_Program__c g
                    WHERE g.Funding_Request__c IN :filteredRequestsMap.keySet()
                    AND g.Funding_Request__r.Record_Type_Name__c = :gFRS_Util.TYPE_IMED_NAME
                    AND g.Type__c = :gFRS_Util.PROGRAM_TYPE_LIVE
                    AND (g.Program_Subtype__c = :gFRS_Util.PROGRAM_SUBTYPE_GRAND_ROUNDS_LIVE OR g.Program_Subtype__c = :gFRS_Util.PROGRAM_SUBTYPE_MEETING_SERIES )
                    AND g.Number_of_Activities__c > 1
            ]) {
                newRequest = filteredRequestsMap.get(program.Funding_Request__c);
                oldRequest = null;
                if (oldMap.containsKey(program.Funding_Request__c)) {
                    oldRequest = oldMap.get(program.Funding_Request__c);
                }
                System.debug('program evaluated:' + program);
                System.debug('newRequest:' + newRequest + ':' + (newRequest != null ? '' + newRequest.Decision_Date__c : ''));
                System.debug('oldRequest:' + oldRequest + ':' + (oldRequest != null ? '' + oldRequest.Decision_Date__c : ''));
                if (newRequest.Decision_Date__c != null && oldRequest != null && oldRequest.Decision_Date__c == null) {
                    System.debug('cloning program:' + program.Number_of_Activities__c);
//-- clone that program Number of Activiteis - 1 (since the original already exists)
                    List<GFRS_Program__c> clonedPrograms = new List<GFRS_Program__c>();
                    for (Integer i = 0; i < program.Number_of_Activities__c - 1; i++) {
                        GFRS_Program__c activity = program.clone(false, true);
//SFDC-3779 some field need to be cleared for each Program type
                        activity.Venue_State__c = null;
                        activity.Venue_Province_Region__c = null;
                        activity.OriginalClonedProgramID__c = program.Id;
//End of SFDC-3779
                        activitiesToInsert.add(activity);
                        System.debug(program.Audience_Groups__r);
                        if (program.Audience_Groups__r != null && program.Audience_Groups__r.size() > 0 && !programAudienceGroupForProgram.containsKey(program.Id)) {
                            orderedProgramOrginalIds.add(program.Id);
                            Integer tmpNumOfAct = Integer.valueOf(program.Number_of_Activities__c) - 1;
                            numerOfEachProgram.put(program.Id, tmpNumOfAct);
//-- clone Program Audience group for each activity/program
                            List<GFRS_Program_Audience_Group__c> listOfProgramGroup = new List<GFRS_Program_Audience_Group__c>();
                            for (GFRS_Program_Audience_Group__c agItem : program.Audience_Groups__r) {
                                listOfProgramGroup.add(agItem.clone(false, true));
                            }
                            programAudienceGroupForProgram.put(program.Id, listOfProgramGroup);
                        }
                    }
                }
            }
            if (activitiesToInsert != null && activitiesToInsert.size() > 0) {
                insert activitiesToInsert;
//populate audience groups to proper programs
                try {
//Integer lastActivitySelectedIndex=0;
                    List<GFRS_Program_Audience_Group__c> finalAudienceListToInsert = new List<GFRS_Program_Audience_Group__c>();
                    for (GFRS_Program__c prog : activitiesToInsert) {
                        List<GFRS_Program_Audience_Group__c> finalProgAudienceListSub = new List<GFRS_Program_Audience_Group__c>();
//prepere duplicated list
                        for (GFRS_Program_Audience_Group__c tmpItem : programAudienceGroupForProgram.get(Id.valueOf(prog.OriginalClonedProgramID__c))) {
                            finalProgAudienceListSub.add(tmpItem.clone(false, true));
                        }
                        for (GFRS_Program_Audience_Group__c tmpItem : finalProgAudienceListSub) {
                            tmpItem.Program__c = prog.Id;
                        }
                        finalAudienceListToInsert.addAll(finalProgAudienceListSub);
                    }
                    insert finalAudienceListToInsert;
                } catch (Exception ex) {
                    System.debug('There was problem in list');
                    System.debug('Error Occurs inside createActivities method error log: ' + ex.getMessage());
                }
            }
        } catch (Exception ex) {
            System.debug('Error Occurs inside createActivities method error log: ');
            System.debug(ex.getMessage());
        }
    }

/**
* @author GFRS Dev Team
* @date 27/11/2013
* @description isInternalRequest method - Method indicates if request is an internal request, based on request's record type name.
*/
    public static Boolean isInternalRequest(String recordTypeName) {
        return INTERNAL_FUNDING_TYPES.contains(recordTypeName);
    }

/**
* @author GFRS Dev Team
* @date 27/11/2013
* @description createAuthenticationHeaderMap method - Creates the security authentication headers.
*/
    public static Map<String, String> createAuthenticationHeaderMap() {
        Map<String, String> headers = new Map<String, String>();
        headers.put(GFRS_WS_PARAM_AUTHORIZATION, gFRS_Util.getCustomSettingStringValue('WS_SAP_Authorization') == null ? System.Label.gFRS_WS_Authorization : gFRS_Util.getCustomSettingStringValue('WS_SAP_Authorization'));
        return(headers);
    }

/**
* @author GFRS Dev Team
* @date 27/11/2013
* @description prepareXmlMessageToParse method - Puts message into XML tags.
*/
    public static String prepareXmlMessageToParse(String message) {
        return '<errorMessages>' + message.replace('<?xml version="1.0"?>', '') + '</errorMessages>';
    }


/**
* @author GFRS Dev Team
* @date 23/09/2016
* @description isExternalRequest method - Method indicates if request is an external request, based on request's record type name.
*/
    public static Boolean isExternalRequest(String recordTypeName) {
        return recordTypeName.equals(gFRS_Util.TYPE_HC_CHAR_NAME) || recordTypeName.equals(gFRS_Util.TYPE_PHILANTHROPIC_NAME) || recordTypeName.equals(gFRS_Util.TYPE_FELLOWSHIPS_NAME) || recordTypeName.equals(gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME) ? true : false;
    }

/**
* @author GFRS Dev Team
* @date 27/11/2013
* @description updateOrganizationAccreditationStatus method - Updates the Organizations with the appropriate Accreditation_Status__c.
*/
    public static GFRS_Organization__c[] updateOrganizationAccreditationStatus(GFRS_Organization__c[] organizations) {
        Map<String, GFRS_Organization__c> organizationTaxMap = new Map<String, GFRS_Organization__c>();
        gFRS_ObjectUtil.createStringFieldMap(organizations, 'Tax_Id__c', organizationTaxMap);

        Set<String> taxIds = organizationTaxMap.keySet();

        gFRS_ACCME__c[] matchedRecords = [
                SELECT Id, Accreditation_Status__c, Tax_ID__c
                FROM gFRS_ACCME__c
                WHERE Tax_ID__c IN :taxIds
        ];

        GFRS_Organization__c[] updatedOrganizations = new GFRS_Organization__c[]{
        };
        GFRS_Organization__c organization = null;

        if (matchedRecords != null && matchedRecords.size() > 0) {
            for (gFRS_ACCME__c match : matchedRecords) {
                if (organizationTaxMap.containsKey(match.Tax_ID__c)) {
                    organization = organizationTaxMap.get(match.Tax_ID__c);

                    organization.ACCME_Accreditations__c = match.Accreditation_Status__c;

                    updatedOrganizations.add(organization);
                }
            }

//update updatedOrganizations;
        }

        return(updatedOrganizations);
    }

/**
* @author GFRS Dev Team
* @date 27/11/2013
* @description translateDeliveryMethodToESB method - Translates SFDC Delivery Methods to ESB.
*/
    public static void sumUpAudienceForFundingRequest(GFRS_Program_Audience_Group__c[] newAudienceList) {
        Set<Id> reqIds = new Set<Id>();
        Id tempId = null;

//-- determine the funding requests referenced, to get all audience groups (not just those changed)
        for (GFRS_Program_Audience_Group__c audience : newAudienceList) {
            try {
                tempId = Id.valueOf(audience.Funding_Request__c);
                System.debug('1[' + audience.Funding_Request__c + '] 2[' + tempId + ']');
                reqIds.add(tempId);
            } catch (Exception err) {
                System.debug('Error is problem with Formula Field - unable to translate FundingRequest from audience:' + err.getMessage());
//ignore
            }
        }

//System.debug( 'reqIds:' + reqIds );

//-- Note: a map is needed to bypass the limitation that a group-by cannot be done on a formula field (Funding Request) as that is the actual value we're looking for
        Map<Id, GFRS_Funding_Request__c> fundingRequestMap = new Map<Id, GFRS_Funding_Request__c>();
        AggregateResult[] programsSummaryList = [
                SELECT Program__c, MAX(Funding_Request__c) Funding_Request__c, SUM( Actual_Learners__c ) Actual_Learners__c, SUM( Expected_Learners__c ) Expected_Learners__c
                FROM GFRS_Program_Audience_Group__c
                WHERE Program__r.Funding_Request__c IN :reqIds
                GROUP BY Program__c
        ];

//system.debug('ProgramSummaryList:'+programsSummaryList);

        GFRS_Funding_Request__c[] reqsToUpdate = new GFRS_Funding_Request__c[]{
        };
        GFRS_Funding_Request__c tempRequest = null;

        Object testObject = null;
        for (AggregateResult result : programsSummaryList) {
            tempId = (Id) result.get('Funding_Request__c');

            if (!fundingRequestMap.containsKey(tempId)) {
                tempRequest = new GFRS_Funding_Request__c(Id = tempId, Expected_Attendees__c = 0, Total_of_Expected_Learners__c = 0);
                fundingRequestMap.put(tempId, tempRequest);
            } else {
                tempRequest = fundingRequestMap.get(tempId);
            }

//System.debug( 'fundingRequestRecord:' + result + ', tempRequest:' + tempRequest );

            if (result.get('Actual_Learners__c') != null) tempRequest.Expected_Attendees__c += Double.valueOf(result.get('Actual_Learners__c'));
            if (result.get('Expected_Learners__c') != null) tempRequest.Total_of_Expected_Learners__c += Double.valueOf(result.get('Expected_Learners__c'));

//System.debug( 'tempRequest:' + tempRequest );
        }

        reqsToUpdate = fundingRequestMap.values();
//system.debug('ReqsToUpdate:'+reqsToUpdate);

        if (reqsToUpdate.size() > 0) gFRS_Util_NoShare.saveLockedFundingRequests(reqsToUpdate);
    }


/**
* @author GFRS Dev Team
* @date 27/11/2013
* @description translateDeliveryMethodToESB method - Translates SFDC Delivery Methods to ESB.
*/
    public static String translateDeliveryMethodToESB(String deliveryMethod) {
        if (deliveryMethod == SFDC_ORANGE_POUCH) {
            return(ESB_ORANGE_POUCH);
        } else if (deliveryMethod == SFDC_VENDOR) {
            return(ESB_VENDOR);
        } else if (deliveryMethod == SFDC_SALES_REP) {
            return(ESB_SALES_REP);
        } else {
            return(deliveryMethod);
        }
    }


/**
* @author GFRS Dev Team
* @date 27/11/2013
* @description determineCompanyCode method - Determines the company code for a specific funding request.
* <p>Currently there must be a single company code, but the only knowledge of the company code
* is through the allocation line items (which know the cost center which know the company code ).
* This is intended to be a central place to put logic on which company code from possible multiple ones to use.
* (Currently using FirstCome heuristic)</p>
*/
    public static String determineCompanyCode(GFRS_Funding_Allocation_Line_Item__c[] splits) {
        String result = null;
        try {
            if (splits != null && splits.size() > 0) {
                result = splits[0].Cost_Center_Lookup__r.SAP_Company_Code__c;
            }
        } catch (Exception err) {
            System.debug('Splits must have the cost center and company code to determine the company code.');
        }
        return(result);
    }

/**
* @author GFRS Dev Team
* @date 09/10/2018
* @description validateFunding type change - method check if user can change funding type
*/
    public static void validateFundingTypeChange(GFRS_Funding_Request__c[] newRequests, Map<Id, GFRS_Funding_Request__c> oldRequests) {
        final GFRS_Funding_Request__c[] changedFundingRequests = new GFRS_Funding_Request__c[]{
        };
        gFRS_ObjectUtil.filterChangedObjects(newRequests, oldRequests, 'Record_Type_Name__c', changedFundingRequests);
        for (GFRS_Funding_Request__c fundingRequest : changedFundingRequests) {
            if (oldRequests.get(fundingRequest.Id).Sub_Status__c != REQUEST_SUB_STATUS_NEW && fundingRequest.Sub_Status__c != REQUEST_SUB_STATUS_NEW &&
                    oldRequests.get(fundingRequest.Id).Sub_Status__c != REQUEST_SUB_STATUS_CCO && fundingRequest.Sub_Status__c != REQUEST_SUB_STATUS_CCO) {
                fundingRequest.addError(System.Label.gFRS_ERROR_REQUEST_WRONG_STATE);
            }
        }
    }

/**
* @author GFRS Dev Team
* @date 22/08/2014
* @description updateFundingTypeName method - method for handling change of Funding Type. Added double check for method execution.
*/
    public static Boolean updateFundingTypeName(GFRS_Funding_Request__c[] newRequests, Map<Id, GFRS_Funding_Request__c> oldRequests) {
        Boolean isPaymentPaid = false;
        final GFRS_Funding_Allocation_Line_Item__c[] modifiedAllocLineItems = new List<GFRS_Funding_Allocation_Line_Item__c>();
        final GFRS_Funding_Allocation__c[] modifiedAllocItems = new List<GFRS_Funding_Allocation__c>();
        final GFRS_Funding_Request__c[] changedFundingRequests = new GFRS_Funding_Request__c[]{
        };
        final GFRS_Program__c[] modifiedPrograms = new GFRS_Program__c[]{
        };
        final GFRS_OrgSettings__c myOrgCS = GFRS_OrgSettings__c.getOrgDefaults();
        final Map<String, Id> costCenters = new Map<String, Id>{
                myOrgCS.IMEDDefaultCostCenterForLI__c => null,
                myOrgCS.CapDefaultCostCenterForLI__c => null
        };
        final Id[] requestIds = new Id[]{
        };
        try {
            gFRS_ObjectUtil.filterChangedObjects(newRequests, oldRequests, 'Record_Type_Name__c', changedFundingRequests);
// check do we need to do something
            if (changedFundingRequests.isEmpty()) {
                return false;
            }
// collect identifiers of modified requests
            requestIds.addAll(new Map<Id, SObject>(changedFundingRequests).keySet());
// collect prerequisite data
            List<GFRS_Funding_Allocation_Line_Item__c> fundingAllocationLineItemsList = gFRS_DAO.getAllocationLineItemListByRequestIds(requestIds);
            Map<String, List<GFRS_Funding_Allocation_Line_Item__c>> fundingIdtoFaliMap = getFundingIdtoFaliMap(fundingAllocationLineItemsList);
            List<GFRS_Funding_Allocation__c> fundingAllocationList = gFRS_DAO.getFundingAllocationsByRequestIds(new Set<Id>(requestIds));
            Map<String, List<GFRS_Funding_Allocation__c>> fundingIdtoFundingAllocationMap = getFundingIdtoFundingAllocationMap(fundingAllocationList);
            List<GFRS_Payment_History__c> paymentHistoryList = gFRS_DAO.getPaymentHistoryByFundingAllocationList(fundingAllocationList);
            Map<Id, List<GFRS_Program__c>> fundingIdToProgramMap = gFRS_DAO.getProgramMapByRequestIds(new Set<Id>(requestIds));

            Set<Id> setOfRequestsWithPaidPayments = getSetOfRequestsWithPaidPayments(paymentHistoryList);
// collect cost center codes grouped by type of the request
            for (GFRS_Cost_Center_Code__c costCenter : [
                    SELECT Name
                    FROM GFRS_Cost_Center_Code__c
                    WHERE IsActive__c = TRUE AND Name IN :costCenters.keySet()
                    LIMIT :costCenters.size()
            ]) {
                costCenters.put(costCenter.Name == myOrgCS.IMEDDefaultCostCenterForLI__c ?
                        TYPE_IMED_NAME : TYPE_PHILANTHROPIC_NAME, costCenter.Id
                );
                costCenters.put(costCenter.Name == myOrgCS.IMEDDefaultCostCenterForLI__c ?
                        TYPE_IMED_NAME : TYPE_HC_CHAR_NAME, costCenter.Id
                );
            }

            Map<String, Id> programRecordTypeMap = getProgramRecordTypeMap(changedFundingRequests);

// process requests for which funding type have been changed
            for (GFRS_Funding_Request__c fundingRequest : changedFundingRequests) {
                isPaymentPaid = setOfRequestsWithPaidPayments.contains(fundingRequest.Id) ? true : false;
                fundingRequest.Funding_Type__c = convertFundingTypeSAP(fundingRequest.Record_Type_Name__c);
//GFRSME2-3
                fundingRequest.Sub_Status__c = REQUEST_STATUS_RFI;
                fundingRequest.External_Sub_status__c = REQUEST_EXTERNAL_SUB_STATUS_FUNDING_TYPE_CHANGED;
                fundingRequest.Information_Needed__c = INFO_NEEDED_APPLICATION + ';' + INFO_NEEDED_THIRD_PARTY + ';' + INFO_NEEDED_PROGRAM + ';' + INFO_NEEDED_BUDGET + ';' + INFO_NEEDED_FILE_ATTACHMENTS + ';' + INFO_NEEDED_PROGRAM_DESIGN;
                if(!isInternalRequest(fundingRequest.Record_Type_Name__c)){
                    fundingRequest.Information_Needed__c = fundingRequest.Information_Needed__c + ';' + INFO_NEEDED_PAYMENT_METHOD;
                }

// update GL Account
                if (!isPaymentPaid) {
                    modifiedAllocItems.addAll(changeGLAccount(
                            fundingIdtoFundingAllocationMap.get(fundingRequest.Id),
                            getGlAccountMapping(fundingRequest.Record_Type_Name__c)
                    ));
// set or clear cost center for IMED and all external unpaid requests
                    if (isExternalRequest(fundingRequest.Record_Type_Name__c) ||
                            fundingRequest.Record_Type_Name__c == TYPE_IMED_NAME
                            ) {
                        modifiedAllocLineItems.addAll(populateAllocationLineItems(
                                fundingIdtoFaliMap.get(fundingRequest.Name), fundingRequest,
                                costCenters.get(fundingRequest.Record_Type_Name__c), null
                        ));
                    }
                }
// clear Cost Center and WBS fro internal funding types
                if (isInternalRequest(oldRequests.get(fundingRequest.Id).Record_Type_Name__c) &&
                        isInternalRequest(fundingRequest.Record_Type_Name__c)
                        ) {
                    modifiedAllocLineItems.addAll(populateAllocationLineItems(
                            fundingIdtoFaliMap.get(fundingRequest.Name), fundingRequest, null, null
                    ));
                }

//update program record types
                for (GFRS_Program__c program : fundingIdToProgramMap.get(fundingRequest.Id)) {
                    program.RecordTypeId = programRecordTypeMap.get(fundingRequest.Record_Type_Name__c + gFRS_Util.RT_PROGRAM_SUFFIX);
                    modifiedPrograms.add(program);
                }
            }
// persist modified allocation line items
            if (modifiedAllocLineItems.size() > 0) {
                update modifiedAllocLineItems;
            }
// perist modified allocation items
            if (modifiedAllocItems.size() > 0) {
                update modifiedAllocItems;
            }
// perist modified program items
            if (modifiedPrograms.size() > 0) {
                update modifiedPrograms;
            }
// indicate successful execution
            return true;
        } catch (Exception ex) {
            System.debug('Error: ' + ex);
            throw ex;
        }
    }

/**
* @author GFRS Dev Team
* @date 25/08/2014
* @description getSetOfRequestsWithPaidPayments method - returns Set od IDs of Funding Request which Payments was Paid
*/
    public static Set<Id> getSetOfRequestsWithPaidPayments(List<GFRS_Payment_History__c> paymentHistoryList) {

        Set<Id> result = new Set<Id>();
        for (GFRS_Payment_History__c item : paymentHistoryList) {
            if (item.SAP_Doc_ID__c != null) {
                result.add(item.Grant__c);
            }

        }
        return result;

    }

/**
* @author GFRS Dev Team
* @date 25/08/2014
* @description getFundingIdtoFaliMap method - gets map of funding requests to their Faunding Allocaiton line Items list
*/
    public static Map<String, List<GFRS_Funding_Allocation_Line_Item__c>> getFundingIdtoFaliMap(List<GFRS_Funding_Allocation_Line_Item__c> fundingAllocationLineItemsList) {

        Map<String, List<GFRS_Funding_Allocation_Line_Item__c>> result = new Map<String, List<GFRS_Funding_Allocation_Line_Item__c>>();
        for (GFRS_Funding_Allocation_Line_Item__c item : fundingAllocationLineItemsList) {
            if (result.containsKey(item.Grant_Request__c)) {
                result.get(item.Grant_Request__c).add(item);
            } else {
                result.put(item.Grant_Request__c, new List<GFRS_Funding_Allocation_Line_Item__c>{
                        item
                });
            }

        }
        return result;

    }

/**
* @author GFRS Dev Team
* @date 25/08/2014
* @description getFundingIdtoFundingAllocationMap method - gets map of funding requests to their Faunding Allocaiton list
*/
    public static Map<String, List<GFRS_Funding_Allocation__c>> getFundingIdtoFundingAllocationMap(List<GFRS_Funding_Allocation__c> fundingAllocationLineItemsList) {

        Map<String, List<GFRS_Funding_Allocation__c>> result = new Map<String, List<GFRS_Funding_Allocation__c>>();
        for (GFRS_Funding_Allocation__c item : fundingAllocationLineItemsList) {
            if (result.containsKey(item.Grant_Request__c)) {
                result.get(item.Grant_Request__c).add(item);
            } else {
                result.put(item.Grant_Request__c, new List<GFRS_Funding_Allocation__c>{
                        item
                });
            }

        }
        return result;

    }

/**
* @author GFRS Dev Team
* @date 22/08/2014
* @description changeGLAccount method - changes GL Account after flipping Funding Type
*/
    public static List<GFRS_Funding_Allocation__c> changeGLAccount(List<GFRS_Funding_Allocation__c> fundingAllocationsList, String newGlAccountValue) {
        Id newGLAccountId;
        if (newGlAccountValue != null) {
            newGLAccountId = [
                    SELECT Id
                    FROM GFRS_GL_Account__c
                    WHERE Name = :newGlAccountValue
                    LIMIT 1
            ].Id;
        }
        for (GFRS_Funding_Allocation__c item : fundingAllocationsList) {
            item.GL_Account_ref__c = newGLAccountId;
        }
        return fundingAllocationsList;
    }

/**
* @author GFRS Dev Team
* @date 22/08/2014
* @description populateAllocationLineItems method - populates Cost Center and WBS to given FALI
*/
    private static GFRS_Funding_Allocation_Line_Item__c[] populateAllocationLineItems(
            final GFRS_Funding_Allocation_Line_Item__c[] allocationLineItems,
            final GFRS_Funding_Request__c fundingRequest,
            final Id costCenterId,
            final Id wbsId
    ) {
        final String requestType = fundingRequest == null ? null : fundingRequest.Record_Type_Name__c;
        final Boolean isPercentageNullable = requestType == TYPE_IMED_NAME || requestType == TYPE_FELLOWSHIPS_NAME ||
                requestType == TYPE_SCIENTIFIC_PROJECTS_NAME;
        final Boolean isAmountNullable = requestType == TYPE_HC_CHAR_NAME || requestType == TYPE_PHILANTHROPIC_NAME ||
                isInternalRequest(requestType);
        final GFRS_Funding_Allocation_Line_Item__c[] items = allocationLineItems == null ?
                new GFRS_Funding_Allocation_Line_Item__c[]{
                } : allocationLineItems;
// set cost center, wbs code and percentage or amount
        for (GFRS_Funding_Allocation_Line_Item__c item : items) {
            item.Percent__c = isPercentageNullable ? null : isAmountNullable ? 100 : item.Percent__c;
            item.Amount__c = isPercentageNullable ? 0 : isAmountNullable ? null : item.Amount__c;
            item.Cost_Center_Lookup__c = costCenterId;
            item.WBS_Code_Lookup__c = wbsId;
        }
// return procesed allocation line items
        return items;
    }

/**
* @author GFRS Dev Team
* @date 22/08/2014
* @description getGlAccountMapping method - returns GL Account code for given Funding Type
*/
    public static String getGlAccountMapping(String recordTypeName) {
        return DEF_GL_ACCS_BY_TYPE.get(recordTypeName);
    }

/**
* @author GFRS Dev Team
* @date 27/11/2013
* @description upsertFundingRequestStatusHistory method - Upon Funding Request Sub-Status chagne a record crates with new sub-status and updates old status record.
*/
    public static void upsertFundingRequestStatusHistory(Map<Id, GFRS_Funding_Request__c> newMap, Map<Id, GFRS_Funding_Request__c> oldMap) {
        try {
            GFRS_Funding_Request__c[] changedFundingRequests = new GFRS_Funding_Request__c[]{
            };
            gFRS_ObjectUtil.filterChangedObjects(newMap.values(), oldMap, 'Sub_Status__c', changedFundingRequests);
            Set<Id> changedFRSet = new Set<Id>();
            if (changedFundingRequests == null || changedFundingRequests.size() < 1) {
                return;
            } else {
                for (GFRS_Funding_Request__c newRequest : changedFundingRequests) {
                    changedFRSet.add(newRequest.Id);
                }
            }
            List<GFRS_Funding_Request_Status_History__c> newStatusHistoryList = new List<GFRS_Funding_Request_Status_History__c>();
            List<GFRS_Funding_Request_Status_History__c> updStatusHistoryList = new List<GFRS_Funding_Request_Status_History__c>();
            BusinessHours bh = [SELECT Id FROM BusinessHours WHERE Name = 'GFRS Business Days'];
            GFRS_Funding_Request__c[] modifiedFundingRequests = [SELECT Id, Sub_Status__c, (SELECT Id, CreatedDate, Sub_Status__c, End_Date__c, Elapsed_Days__c, Start_Date__c FROM GFRS_Funding_Request_Status_History__r ORDER BY CreatedDate DESC LIMIT 1) FROM GFRS_Funding_Request__c WHERE Id IN:changedFRSet];
            for (GFRS_Funding_Request__c fundReq : modifiedFundingRequests) {
                if (fundReq.GFRS_Funding_Request_Status_History__r.size() > 0) {
                    GFRS_Funding_Request_Status_History__c updateHistory = fundReq.GFRS_Funding_Request_Status_History__r[0];
                    if (fundReq.Sub_Status__c == updateHistory.Sub_Status__c) {
                        continue;
                    }
                    updateHistory.Elapsed_Days__c = Integer.valueOf(BusinessHours.diff(bh.Id, updateHistory.Start_Date__c, Date.today()) / (24 * 60 * 60 * 1000)) + 1;
                    updateHistory.End_Date__c = Date.today();
                    updateHistory.End_Date_Time__c = Datetime.now();
                    updStatusHistoryList.add(updateHistory);
                }
                GFRS_Funding_Request_Status_History__c newHistory = new GFRS_Funding_Request_Status_History__c();

                newHistory.gFRS_Funding_Request__c = fundReq.Id;
                newHistory.Start_Date__c = Date.today();
                newHistory.Start_Date_Time__c = Datetime.now();
                newHistory.Sub_Status__c = fundReq.Sub_Status__c;
                newStatusHistoryList.add(newHistory);
            }
            update updStatusHistoryList;
            insert newStatusHistoryList;
        } catch (Exception ex) {
            System.debug('Error: ' + ex);
        }
    }


/**
* @Author ADMD Team
* @date 27/11/2013
* @description submitForApproval method - Submits a funding request for Approval after changing the status from New to CCO Review.
* @POSTCONDITION: if the sub status changed from new to cco review, then the funding request is sent for approval
*/
    public static void submitForApproval(
            final Map<Id, GFRS_Funding_Request__c> newRequests,
            final Map<Id, GFRS_Funding_Request__c> oldRequests
    ) {
        try {
            final Set<Id> approverIds = new Set<Id>();
            final GFRS_Funding_Request__Share[] shares = new GFRS_Funding_Request__Share[]{
            };
            final Map<Id, GFRS_Funding_Request__c> requests = new Map<Id, GFRS_Funding_Request__c>();
            final Approval.ProcessSubmitRequest[] approvalRequests = new Approval.ProcessSubmitRequest[]{
            };
            for (GFRS_Funding_Request__c req : newRequests.values()) {
                if (APPROVAL_IDS.add(req.Id) &&
                        oldRequests.containsKey(req.Id) &&
                        req.Sub_Status__c == gFRS_Util.REQUEST_SUB_STATUS_CCO &&
                        oldRequests.get(req.Id).Sub_Status__c == gFRS_Util.REQUEST_SUB_STATUS_NEW
                        ) {
                    requests.put(req.Id, req);
                }
            }
            requests.putAll(requests.isEmpty() ? new GFRS_Funding_Request__c[]{
            } : [
                    SELECT
                            Name,
                            Record_Type_Name__c,
                            Legal_Reviewer_1__c, Legal_Reviewer_1__r.IsActive,
                            Financial_Approver_1__c, Financial_Approver_1__r.IsActive,
                            Financial_Approver_2__c, Financial_Approver_2__r.IsActive,
                            Financial_Approver_3__c, Financial_Approver_3__r.IsActive, (SELECT AccessLevel, ParentId, RowCause, UserOrGroupId FROM Shares)
                    FROM GFRS_Funding_Request__c
                    WHERE Id IN :requests.keySet()
                    LIMIT :requests.size()
            ]);
            for (Id requestId : requests.keySet()) {
                final Approval.ProcessSubmitRequest approvalReq = new Approval.ProcessSubmitRequest();
                approvalReq.setComments('Submitting request for approval.');
                approvalReq.setObjectId(requestId);
                approvalRequests.add(approvalReq);
            }
            final Approval.ProcessResult[] approvalResults = approvalRequests.isEmpty() ?
                    new Approval.ProcessResult[]{
                    } : Approval.process(approvalRequests, false);
            for (Integer i = 0; i < approvalResults.size(); i++) {
                final GFRS_Funding_Request__c request = (approvalResults[i].isSuccess() ? requests : newRequests).get(
                        approvalRequests[i].getObjectId()
                );
                if (approvalResults[i].isSuccess() ||
                        approvalResults[i].getErrors()[0].getStatusCode() == StatusCode.ALREADY_IN_PROCESS
                        ) {
                    if (request.Legal_Reviewer_1__c != null &&
                            request.Legal_Reviewer_1__r.IsActive &&
                            getUserSharing(request.Id, request.Legal_Reviewer_1__c, request.Shares) == null
                            ) {
                        shares.add(createRequestShare(request.Id, request.Legal_Reviewer_1__c, SHARING_READ));
                    }
                    if (request.Financial_Approver_1__c != null &&
                            request.Financial_Approver_1__r.IsActive
                            ) {
                        final GFRS_Funding_Request__Share share = getUserSharing(
                                request.Id, request.Financial_Approver_1__c, request.Shares
                        );
                        if (share == null) {
                            shares.add(createRequestShare(request.Id, request.Financial_Approver_1__c,
                                    request.Record_Type_Name__c == TYPE_FIELD_INITIATED_EXHIBITS_NAME ? SHARING_WRITE : SHARING_READ
                            ));
                        } else if (request.Record_Type_Name__c == TYPE_FIELD_INITIATED_EXHIBITS_NAME && share.RowCause != 'Owner') {
                            share.AccessLevel = SHARING_WRITE;
                            shares.add(share);
                        }
                    }
                    if (request.Financial_Approver_2__c != null &&
                            request.Financial_Approver_2__r.IsActive &&
                            getUserSharing(request.Id, request.Financial_Approver_2__c, request.Shares) == null
                            ) {
                        shares.add(createRequestShare(request.Id, request.Financial_Approver_2__c, SHARING_READ));
                    }
                    if (request.Financial_Approver_3__c != null &&
                            request.Financial_Approver_3__r.IsActive &&
                            getUserSharing(request.Id, request.Financial_Approver_3__c, request.Shares) == null
                            ) {
                        shares.add(createRequestShare(request.Id, request.Financial_Approver_3__c, SHARING_READ));
                    }
                    if (gFRS_Util_NoShare.APPROVER_IDS.add(request.Legal_Reviewer_1__c)) {
                        approverIds.add(request.Legal_Reviewer_1__c);
                    }
                    if (gFRS_Util_NoShare.APPROVER_IDS.add(request.Financial_Approver_1__c)) {
                        approverIds.add(request.Financial_Approver_1__c);
                    }
                    if (gFRS_Util_NoShare.APPROVER_IDS.add(request.Financial_Approver_2__c)) {
                        approverIds.add(request.Financial_Approver_2__c);
                    }
                    if (gFRS_Util_NoShare.APPROVER_IDS.add(request.Financial_Approver_3__c)) {
                        approverIds.add(request.Financial_Approver_3__c);
                    }
                } else {
                    System.debug(LoggingLevel.ERROR, request.Name + ': ' + approvalResults[i].getErrors());
                    request.addError(approvalResults[i].getErrors()[0].getMessage());
                }
            }
            approverIds.remove(null);
            if (!(approverIds.isEmpty() || System.isFuture() || System.isBatch()) &&
                    Limits.getFutureCalls() < Limits.getLimitFutureCalls()
                    ) {
                gFRS_Util_NoShare.grantApproverAccessAsync(new List<Id>(approverIds));
            }
            gFRS_Util_NoShare.upsertRequestShares(shares, newRequests);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'submitForApproval error:' + e);
        }
    }

/**
* @author GFRS Dev Team
* @date 21/11/2013
* @description getUserSharing method - checks if user have already sharing to funding request
*/
    public static GFRS_Funding_Request__Share getUserSharing(final Id fundingId, final Id userId, final GFRS_Funding_Request__Share[] shares) {
        for (GFRS_Funding_Request__Share share : shares) {
            if (share.UserOrGroupId == userId && share.ParentId == fundingId) {
                return share;
            }
        }

        return null;
    }

/**
* @Author ADMD Team
* @date 27/11/2013
* @description createRequestShare method - Creates a funding request sharing record.
*/
    public static GFRS_Funding_Request__Share createRequestShare(final Id parentId, Id userOrGroupId, final String accessLevel) {
        return new GFRS_Funding_Request__Share(
                RowCause = Schema.GFRS_Funding_Request__Share.RowCause.Manual,
                UserOrGroupId = userOrGroupId,
                AccessLevel = accessLevel,
                ParentId = parentId
        );
    }

/**
* @Author ADMD Team
* @date 27/11/2013
* @description setApprovalOptionalStepStatus method - Method that sets the status for the funding request as optionalSteps are completed.
*/
    public static GFRS_Funding_Request__c[] setApprovalOptionalStepStatus(GFRS_Funding_Request__c[] requestsNew, Map<Id, GFRS_Funding_Request__c> requestsOld) {
        GFRS_Funding_Request__c[] changedRequests = new GFRS_Funding_Request__c[]{
        };

//-- filter to only those objects changing the approval steps
        gFRS_ObjectUtil.filterChangedObjects(requestsNew, requestsOld, 'Approval_Step__c', changedRequests);

//System.debug( 'changedRequests:' + changedRequests );
        GFRS_Funding_Request__c[] modifiedRequests = new GFRS_Funding_Request__c[]{
        };

        for (GFRS_Funding_Request__c req : changedRequests) {
//-- check if business review needed or not closed
//System.debug( 'checkReq:' + req );
//System.debug( 'isHCCHAR:[' + req.Record_Type_Name__c + ']' + gFRS_Util.TYPE_HC_CHAR_NAME.equals( req.Record_Type_Name__c ));
//System.debug( 'hasReviewer:' + (req.Business_Approver__c != null) );
//System.debug( 'hasMultiSelectItem:' + gFRS_Util.multiSelectHasItem( req.Approval_Step__c, APPROVAL_BUSINESS_APPROVER ) );
            GFRS_Funding_Request__c tmpOldRequest = null;
            if (requestsOld.containsKey(req.Id)) {
                tmpOldRequest = requestsOld.get(req.Id);

            }

            if (tmpOldRequest == null || ((tmpOldRequest.Approval_Step__c == null || tmpOldRequest.Approval_Step__c != '') && (req.Approval_Step__c == null || req.Approval_Step__c == ''))) {
//-- do nothing
            } else if (req.Business_Reviewer_1__c != null && !gFRS_Util.multiSelectHasItem(req.Approval_Step__c, APPROVAL_BUSINESS_REV)) {
                req.Sub_Status__c = APPROVAL_BUSINESS_REV;
                modifiedRequests.add(req);
            } else if (req.Legal_Reviewer_1__c != null && !gFRS_Util.multiSelectHasItem(req.Approval_Step__c, APPROVAL_LEGAL_REV) && req.Foundation_Classified__c != 'TRUE') {
//Foundation Requests does not have 'Legal Review' step in Approval Process so we should skip this logic
                req.Sub_Status__c = APPROVAL_LEGAL_REV;
//QC-24576 move legal Review Status Date update form workflow here.
                req.Legal_Review_Status_Date__c = Date.today();
                modifiedRequests.add(req);
            }
//SFDC- For Financial Approver 1 and 2, set Sub Status = 'Business Review'. For Financial Approver 3, set Sub Status = 'Financial Approval'
            else if (gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME.equals(req.Record_Type_Name__c) || gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME.equals(req.Record_Type_Name__c) || gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME.equals(req.Record_Type_Name__c)) {
                System.debug('Check current APPROVAL STEP' + req.Approval_Step__c);

                if (req.Financial_Approver_2__c != null && req.Financial_Approver_1_Decision__c != null && req.Financial_Approver_1_Decision__c == 'Approved' && req.Financial_Approver_2_Decision__c == null) {
                    req.Sub_Status__c = REQUEST_SUB_STATUS_BUSINESS_REV;
                    System.debug('status was change to status:' + REQUEST_SUB_STATUS_BUSINESS_REV);
                    modifiedRequests.add(req);
                } else if (req.Financial_Approver_2__c == null && req.Financial_Approver_1_Decision__c != null && req.Financial_Approver_1_Decision__c == 'Approved' && req.Financial_Approver_3_Decision__c == null) {
                    req.Sub_Status__c = REQUEST_SUB_STATUS_FINANCIAL_APPROVAL;
                    System.debug('status was change to status: ' + REQUEST_SUB_STATUS_FINANCIAL_APPROVAL);
                    modifiedRequests.add(req);
                }
            } else if (gFRS_Util.isRequestFoundationType(req.Id) && req.Foundation_Classified__c == 'TRUE') {

                if (!gFRS_Util.multiSelectHasItem(req.Approval_Step__c, APPROVAL_BUSINESS_REV)) {
                    req.Sub_Status__c = APPROVAL_BUSINESS_REV;
                    modifiedRequests.add(req);
                } else if (req.Business_Approver__c != null && !gFRS_Util.multiSelectHasItem(req.Approval_Step__c, APPROVAL_BUSINESS_APPROVER_1)) {
                    req.Sub_Status__c = APPROVAL_BUSINESS_APPROVER;
                    modifiedRequests.add(req);
                }

            } else if (gFRS_Util.TYPE_HC_CHAR_NAME.equals(req.Record_Type_Name__c) || gFRS_Util.TYPE_PHILANTHROPIC_NAME.equals(req.Record_Type_Name__c) ||
                    gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME.equals(req.Record_Type_Name__c) || gFRS_Util.TYPE_FELLOWSHIPS_NAME.equals(req.Record_Type_Name__c)
                    ) {
                if (req.Business_Approver__c != null && !gFRS_Util.multiSelectHasItem(req.Approval_Step__c, APPROVAL_BUSINESS_APPROVER)) {
                    req.Sub_Status__c = APPROVAL_BUSINESS_APPROVER;
                    modifiedRequests.add(req);
                }
            }
        }
        return(modifiedRequests);
    }


/**
* @Author ADMD Team
* @date 27/11/2013
* @description releasePaymentHistoryApprovesFR method - Method that sets the status to approved if the paymentHistory is set to released by the ESB.
*/
    public static void releasePaymentHistoryApprovesFR(GFRS_Payment_History__c[] newList, Map<Id, GFRS_Payment_History__c> oldMap) {
        GFRS_Payment_History__c[] changedHistories = new GFRS_Payment_History__c[]{
        };

//-- filter to only those objects changing the approval steps
        gFRS_ObjectUtil.filterChangedObjects(newList, oldMap, 'ESB_Error__c', changedHistories);

        if (changedHistories == null || changedHistories.size() < 1) return;

        Set<Id> paymentRequestIds = gFRS_ObjectUtil.createIdFieldSet(changedHistories, 'Grant__c');
        GFRS_Funding_Request__c[] paymentRequests = [SELECT Id, Status__c, Sub_Status__c, LOA_Signed__c, Record_Type_Name__c FROM GFRS_Funding_Request__c WHERE Id IN :paymentRequestIds];
        Map<Id, GFRS_Funding_Request__c> paymentRequestMap = new Map<Id, GFRS_Funding_Request__c>(paymentRequests);

        GFRS_Funding_Request__c changedRequest = null;
        GFRS_Funding_Request__c[] changedRequests = new GFRS_Funding_Request__c[]{
        };

        String lowerMsg = null;
        String newSubStatus = null;
        for (GFRS_Payment_History__c changedHistory : changedHistories) {
            if (changedHistory.ESB_Error__c != null) {
                lowerMsg = changedHistory.ESB_Error__c.toLowerCase();
                if (lowerMsg.indexOf(IS_SUCCESSFULLY_RELEASED) > 0 ||
                        (gFRS_Util.PAYMENT_TYPE_PAYMENT.equals(changedHistory.Payment_Type__c) && lowerMsg.indexOf(IS_SUCCESSFULLY_SUBMITTED) > 0)
                        ) {
                    changedRequest = paymentRequestMap.get(changedHistory.Grant__c);

                    if (gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME.equals(changedRequest.Record_Type_Name__c)) {
                        changedRequest.Sub_Status__c = gFRS_Util.REQUEST_SUB_STATUS_PAYMENT;
                        changedRequest.External_Sub_status__c = gFRS_Util.REQUEST_EXTERNAL_SUB_STATUS_APPROVED;
                    } else if (!gFRS_Util.YES.equals(changedRequest.LOA_Signed__c)) {
                        changedRequest.Sub_Status__c = gFRS_Util.REQUEST_SUB_STATUS_WAITING_LOA;
                    } else if (gFRS_Util.TYPE_HC_CHAR_NAME.equals(changedRequest.Record_Type_Name__c) ||
                            gFRS_Util.TYPE_PHILANTHROPIC_NAME.equals(changedRequest.Record_Type_Name__c) ||
                            gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME.equals(changedRequest.Record_Type_Name__c) ||
                            gFRS_Util.TYPE_FELLOWSHIPS_NAME.equals(changedRequest.Record_Type_Name__c)
                            ) {
                        changedRequest.Sub_Status__c = REQUEST_SUB_STATUS_EVALUATIONS;
                        changedRequest.External_Sub_status__c = REQUEST_SUB_STATUS_EVALUATIONS;
                    } else if (gFRS_Util.TYPE_IMED_NAME.equals(changedRequest.Record_Type_Name__c)) {
// After Payment is successfully submitted, for IMED the sub-status and external sub-status are handled through
// Workflow Rule : gFRS Change IMED Status Payment LOA Signed
// Workflow Rule : gFRS Change IMED Status Payment LOA Not Signed
                    } else {
                        changedRequest.Sub_Status__c = REQUEST_SUB_STATUS_PAYMENT;
                        changedRequest.External_Sub_status__c = REQUEST_EXTERNAL_SUB_STATUS_APPROVED;
                    }

                    changedRequests.add(changedRequest);
                }
            }
        }

        if (changedRequests.size() > 0) update changedRequests;
    }


/**
* @Author ADMD Team
* @date 27/11/2013
* @description transferApprovalSteps method
* Method that sets specific flags when the status has changed at specific points
* to ensure that workflows are fired from approval processes. (This will currently fail
* as the approval process is considered a workflow, where workflows cannot be triggered by
* other workflows)
* <p>POSTCONDITION: ensures that SYS_Request_Approved__c is set appropriately depending on the change in status.</p>
*/
    public static void transferApprovalSteps(GFRS_Funding_Request__c[] newList, Map<Id, GFRS_Funding_Request__c> oldMap) {
        GFRS_Funding_Request__c oldRequest = null;

        List<Id> updatedRequests = new List<Id>();

        for (GFRS_Funding_Request__c newRequest : newList) {
            if (oldMap.containsKey(newRequest.Id)) {
                oldRequest = oldMap.get(newRequest.Id);

//System.debug( 'oldRequest.Status__c['+oldRequest.Status__c+']');
//System.debug( 'newRequest.Status__c['+newRequest.Status__c+']');
//System.debug( 'newRequest.Sub_Status__c['+newRequest.Sub_Status__c+']');
//System.debug( 'newRequest.SYS_Request_Approved__c['+newRequest.SYS_Request_Approved__c+']');

                if (oldRequest.Status__c == gFRS_Util.REQUEST_STATUS_DECISION &&
                        newRequest.Status__c == gFRS_Util.REQUEST_STATUS_PRICESSING_DISPOSITION &&
                        newRequest.Sub_Status__c == gFRS_Util.REQUEST_SUB_STATUS_WAITING_LOA &&
                        !gFRS_Util.YES.equals(newRequest.SYS_Request_Approved__c)
                        ) {
/*--
It appears that workflows cannot be fired by triggers fired by workflows
to bypass the workflow to workflow limitation
either before or after triggers

Further choices are to either run it as a future method
or to rewrite the entire process as a batch process

//tmpRequest = new gFRS_Funding_Request__c( id = newRequest.id, SYS_Request_Approved__c = gFRS_Util.YES );
//newRequest.SYS_Request_Approved__c = gFRS_Util.YES;
//updatedRequests.add( tmpRequest );
*/
                    updatedRequests.add(newRequest.Id);

                    System.debug('set request approved[' + newRequest.Id + ']');
                }
            }
        }

        if (updatedRequests != null && updatedRequests.size() > 0) applyIsApproved(updatedRequests);
    }


/**
* @Author ADMD Team
* @date 27/11/2013
* @description applyIsApproved method - Code that runs when a funding request has just been approved.
*/
    @Future
    public static void applyIsApproved(List<Id> approvedRequests) {
        if (approvedRequests == null || approvedRequests.size() < 1) return;

        GFRS_Funding_Request__c[] updatedRequests = new GFRS_Funding_Request__c[]{
        };
        for (Id requestId : approvedRequests) {
            updatedRequests.add(new GFRS_Funding_Request__c(Id = requestId, SYS_Request_Approved__c = gFRS_Util.YES));
        }

        gFRS_Util_NoShare.saveLockedFundingRequests(updatedRequests);
    }


/**
* @Author ADMD Team
* @date 27/11/2013
* @description changeStatusOnApproval method - Code that runs when a funding request has just been approved.
*/
    public static void changeStatusOnApproval(GFRS_Funding_Request__c[] newList, Map<Id, GFRS_Funding_Request__c> oldMap) {
        try {
            GFRS_Funding_Request__c oldRequest = null;
            GFRS_Funding_Request__c[] changedRequests = new GFRS_Funding_Request__c[]{
            };
            GFRS_Funding_Request__c changedRequest = null;

/*--
currently, this request is synchronous (not done by future)
so this means that we can only send one web service request.
If there are multiple, we will have to determine something to
apply to the funding request to say that the payment must be done separately.
Or only change one item from processing and disposition to decision at a time.
If more than one needs to be set, then change the status to another status first
before moving to disposition to avoid firing the trigger
--*/
//Boolean hasFiredWebService = false;

            for (GFRS_Funding_Request__c updatedRequest : newList) {
                if (oldMap.containsKey(updatedRequest.Id)) {
                    if (oldRequest != null) System.debug('Process_Disposition_Date__c[' + oldRequest.Process_Disposition_Date__c + '][' + updatedRequest.Process_Disposition_Date__c + ']');

                    oldRequest = oldMap.get(updatedRequest.Id);

                    if (oldRequest != null &&
                            oldRequest.Process_Disposition_Date__c == null && updatedRequest.Process_Disposition_Date__c != null
                            ) {
                        System.debug('passed process dispositionDate');
//-- request was just approved, so we must use a new request to avoid (record is read only)
                        if (gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME.equals(updatedRequest.Record_Type_Name__c) ||
                                gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME.equals(updatedRequest.Record_Type_Name__c) ||
                                gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME.equals(updatedRequest.Record_Type_Name__c)
                                ) {

                            changedRequest = new GFRS_Funding_Request__c(Id = updatedRequest.Id);

                            changedRequest.Sub_Status__c = gFRS_Util.REQUEST_SUB_STATUS_WAITING_LOA;
                            changedRequest.External_Sub_status__c = gFRS_Util.REQUEST_SUB_STATUS_WAITING_LOA;
                            changedRequests.add(changedRequest);

                            gFRS_PaymentUtil.sendFutureFundingAllocationPaymentToESB(updatedRequest.Id, null);
                        } else if (gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME.equals(updatedRequest.Record_Type_Name__c)) {

                            changedRequest = new GFRS_Funding_Request__c(Id = updatedRequest.Id);
                            changedRequest.Status__c = gFRS_Util.REQUEST_STATUS_PRICESSING_DISPOSITION;
                            changedRequest.Sub_Status__c = gFRS_Util.REQUEST_SUB_STATUS_PAYMENT;
                            changedRequest.External_Sub_status__c = gFRS_Util.REQUEST_EXTERNAL_SUB_STATUS_APPROVED;
                            changedRequests.add(changedRequest);

                            gFRS_PaymentUtil.sendFutureFundingAllocationPaymentToESB(updatedRequest.Id, null);
                        }

                        if (isInternalRequest(updatedRequest.Record_Type_Name__c) && firstRun) {
                            firstRun = false;
                            List<Attachment> requestAttachments = [SELECT Name FROM Attachment WHERE ParentId = :updatedRequest.Id AND Name LIKE '%Vendor_Details%'];
                            Integer max = 0;
                            if (requestAttachments.size() > 0) {
                                for (Attachment att : requestAttachments) {
                                    String attachmentNumber = att.Name.substring(att.Name.indexOf('_V') + 2, att.Name.length() - 4);
                                    if (max < Integer.valueOf(attachmentNumber)) {
                                        max = Integer.valueOf(attachmentNumber);
                                    }
                                }
                            }
                            max = max + 1;
                            String documentName = 'Vendor_Details_' + updatedRequest.Name + '_V' + max + '.pdf';
                            gFRS_Util_NoShare.insertVendorDetailsAttachmentInternal(documentName, updatedRequest.Id);
                        }
                    }
                }
            }

            if (changedRequests.size() > 0) gFRS_Util_NoShare.saveLockedFundingRequests(changedRequests);
        } catch (Exception err) {
            String errMsg = gFRS_Util.getPrettyMessage(err);
            throw(new CustomException('<br/><br/>' + errMsg + '<br/><br/>'));
        }
    }

/**
* @Author ADMD Team
* @date 27/11/2013
* @description submitHC_Programs method - Automatically creates programs for given FUnding Requests.
*/
    public static void submitHC_Programs(GFRS_Funding_Request__c[] newList, Map<Id, GFRS_Funding_Request__c> oldMap) {
        Id[] recentlySubmitedRequests = new Id[]{
        };

//-- find all funding requests that have been recently approved
        GFRS_Funding_Request__c oldRequest = null;
        for (GFRS_Funding_Request__c newRequest : newList) {
            if (gFRS_Util.TYPE_HC_CHAR_NAME.equals(newRequest.Record_Type_Name__c) &&
                    oldMap.containsKey(newRequest.Id)
                    ) {

                oldRequest = oldMap.get(newRequest.Id);
                System.debug('Check values on fields');
                System.debug(oldRequest.Sub_Status__c + 'Check substatus');
                System.debug(newRequest.Sub_Status__c + 'new substatus');
                if ((oldRequest.Status__c == 'Intake' &&
                        newRequest.Status__c == 'HC Compliance') ||
                        (oldRequest.Sub_Status__c == 'RFI' && newRequest.Sub_Status__c == 'RFI Received' && newRequest.Status__c != 'Intake')
                        ) {
                    recentlySubmitedRequests.add(newRequest.Id);
                }
            }
        }

//-- update all programs for those funding requests to status confirmed.
        if (recentlySubmitedRequests.size() > 0) {
            GFRS_Program__c[] updatedPrograms = new GFRS_Program__c[]{
            };
            for (GFRS_Program__c program : [
                    SELECT Id, Program_Status__c
                    FROM GFRS_Program__c
                    WHERE Funding_Request__c IN :recentlySubmitedRequests
            ]
            ) {
                if (program.Program_Status__c == 'Planned') {
                    program.Program_Status__c = 'Confirmed';
                    updatedPrograms.add(program);
                }
            }
            if (updatedPrograms.size() > 0) update updatedPrograms;
        }
    }


/**
* @Author ADMD Team
* @date 27/11/2013
* @description locationDataFirewall method - Converts funding request record types to the SAP accepted record types.
*/
    public static String convertFundingTypeSAP(String recordTypeName) {
        if (recordTypeName == gFRS_Util.TYPE_IMED_NAME) {
            return (gFRS_Util.TYPE_IMED_SAP);
        } else if (recordTypeName == gFRS_Util.TYPE_HC_CHAR_NAME) {
            return (gFRS_Util.TYPE_HC_CHAR_SAP);
        } else if (recordTypeName == gFRS_Util.TYPE_PHILANTHROPIC_NAME) {
            return (gFRS_Util.TYPE_PHILANTHROPIC_SAP);
        } else if (recordTypeName == gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME) {
            return (gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_SAP);
        } else if (recordTypeName == gFRS_Util.TYPE_FELLOWSHIPS_NAME) {
            return (gFRS_Util.TYPE_FELLOWSHIPS_SAP);
        } else if (recordTypeName == gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME) {
            return (gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_SAP);
        } else if (recordTypeName == gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME) {
            return (gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_SAP);
        } else if (recordTypeName == gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME) {
            return (gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_SAP);
        } else if (recordTypeName == gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME) {
            return (gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_SAP);
        } else {
            return (null);
        }

    }


/**
* @Author ADMD Team
* @date 27/11/2013
* @description locationDataFirewall method - If user who edits location is an external user, change location record type to 'External'.
*/
    public static void locationDataFirewall(GFRS_Location__c[] locations, Map<Id, GFRS_Location__c> oldMap) {
        Contact userContact = gFRS_Util_NoShare.getUserContact(UserInfo.getUserId());
        Boolean isInternal = userContact == null;

//-- create a map of the recordTypes to ids
        Map<String, Id> rtMap = new Map<String, Id>();
        for (RecordType r : [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'GFRS_Location__c']) {
            rtMap.put(r.DeveloperName, r.Id);
        }

        if (rtMap.containsKey(gFRS_Util.RT_LOC_INTERNAL)
                && rtMap.containsKey(gFRS_Util.RT_LOC_EXTERNAL)
                ) {
            if (isInternal) { //-- only set if it is new
                for (GFRS_Location__c loc : locations) {

                    if (oldMap == null || !oldMap.containsKey(loc.Id)) {
                        loc.RecordTypeId = rtMap.get(gFRS_Util.RT_LOC_INTERNAL);
//system.debug('record type changed');
                    }
                }
            } else { //-- set if the org was saved on org page (Organization_LastModifiedBy) or if its new
                for (GFRS_Location__c loc : locations) {
//-- unlike the location, there isn't another page that we want to protect the user from making modifications from
                    loc.RecordTypeId = rtMap.get(gFRS_Util.RT_LOC_EXTERNAL);
                    System.debug('record type changed[' + loc.Id + ']:External');
                }
            }
        }
    }


/**
* @Author ADMD Team
* @date 27/11/2013
* @description isFieldSalesUser method - Determines if a user is in the Field Sales Group custom label.
* <p>Note, this requires that each level above the user group is another query,
* so determining if the user is in a group that contains a group that contains a group that contains the user
* Pattern was modified to GNE-SFA-%-CS,GNE-SFA-%-Pathology-Specialist,GNE-SFA-%-PS JIRA-GFRS-80
* requires three queries.</p>
*/
    public static Boolean isFieldSalesUser(Id userId) {

        User[] users = [SELECT Id, ProfileId FROM User WHERE Id = :userId AND (Profile_Name_gne__c LIKE 'GNE-SFA-%-Pathology-Specialist' OR Profile_Name_gne__c LIKE 'GNE-SFA-%-PS')];
        return(users != null && users.size() > 0);
    }


/**
* @Author ADMD Team
* @date 27/11/2013
* @description isSystemAdministrator method - Determines whether the user is a system administrator or a Super User.
*/
    public static Boolean isSystemAdministrator(Id UserId) {
        User[] users = [SELECT Id, Name FROM User WHERE Id = :UserId AND (Profile.Name = :gFRS_Util.PROFILE_NAME_SYS_ADMIN OR Profile.Name = :gFRS_Util.PROFILE_NAME_SUPER_USER )];
        return (users.size() > 0 ? true : false);
    }
    /** 
    * @Author TechM Team
    * @date 14/01/2019
    * @description isExternalRequestor method - Determines whether the user is an external requestor.
    */
    public static Boolean isExternalRequestor(Id UserId){
        User[] users = [ select id, Name from User where id = :userId and Profile.Name =: PROFILE_NAME_GNEGFRSEXTERNALREQUESTOR];
        return (users.size() > 0 ? true : false);
    }


/**
* @Author ADMD Team
* @date 27/11/2013
* @description isCMEOShown method - Determines if a CMEO should be shown.
*/
    public static Boolean isCMEOShown(GFRS_Funding_Request__c request) {
        return(gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME.equals(request.Record_Type_Name__c) &&
                request.Benefits_Exchanged_for_Funding__c != null &&
                (gFRS_Util.multiSelectHasItem(request.Benefits_Exchanged_for_Funding__c, gFRS_Util.EXHIBIT_SPACE) || gFRS_Util.multiSelectHasItem(request.Benefits_Exchanged_for_Funding__c, gFRS_Util.EXHIBIT_SPACE_PREF_LOCATION))
        );
    }


/**
* @Author ADMD Team
* @date 27/11/2013
* @description createOrDestroyCMEO_Program method - Creates or destroys a CMEO program off a funding request.
* @param mustExist (Boolean) - whether a CMEO program should be present (true) or the CMEO program must not be present (should be destroyed) (false)
* @param requestId (id<fundingRequest>) - the id of the funding request to find or create the CMEO program on
*/
    public static void createOrDestroyCMEO_Program(Boolean mustExist, GFRS_Funding_Request__c request) {
        GFRS_Program__c[] cmeos = [SELECT Id, Name, Is_CMEO__c FROM GFRS_Program__c WHERE Funding_Request__c = :request.Id AND Is_CMEO__c = TRUE];
        String corpMembershipRT_Name = gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME + gFRS_Util.RT_PROGRAM_SUFFIX;
        RecordType corpMembershipRT = [SELECT Id FROM RecordType WHERE SobjectType = 'gFRS_Program__c' AND Name = :corpMembershipRT_Name];

//-- MUST match type of createFundingRequestPrograms
        String programType = gFRS_Util.BUDGET_TYPE_LIVE;

        if( mustExist ){
            if( cmeos != null && cmeos.size() < 1 ){
                //-- they do not exist so create one.
                cmeos = new gFRS_Program__c[]{
                    //-- MUST match those created through createFundingRequestPrograms
                    new GFRS_Program__c( Is_CMEO__c = true, Funding_Request__c = request.Id, Type__c = programType, Expected_of_attendees_that_are_HCPs__c = 0, RecordTypeId = corpMembershipRT.id )
                };
                gFRS_Util_NoShare.saveLockedPrograms(cmeos);
            }
        } else { //-- should delete
            if (cmeos != null && cmeos.size() > 0) {
//-- they exist so should be removed
                gFRS_Util_NoShare.removeLockedPrograms(cmeos);
                gFRS_Util_NoShare.resetExhibitOpportunity(request);
            }
        }
    }


/**
* @Author ADMD Team
* @date 27/11/2013
* @description getRFI_StartingPage method - Determines the appropriate page for an RFI.
*/
    public static String getRequestStartingPage(GFRS_Funding_Request__c request) {
        String resultURL = Page.GFRS_Org_Info.getUrl();
        if (request == null || request.Id == null) return(resultURL);
        String idParam = '?id=' + request.Id;

        resultURL += idParam;

        if (request.Information_Needed__c == null) {
//-- leave alone
        } else if (gFRS_Util.multiSelectHasItem(request.Information_Needed__c, INFO_NEEDED_ORGANIZATION)) {
            resultURL = Page.GFRS_Org_Info.getUrl() + idParam;
        } else if (gFRS_Util.multiSelectHasItem(request.Information_Needed__c, INFO_NEEDED_LOCATION)) {
            resultURL = Page.GFRS_Org_Info.getUrl() + idParam + '&ci=2';
        } else if (gFRS_Util.multiSelectHasItem(request.Information_Needed__c, INFO_NEEDED_APPLICATION)) {
            resultURL = Page.GFRS_Application.getUrl() + idParam;
        } else if (gFRS_Util.multiSelectHasItem(request.Information_Needed__c, INFO_NEEDED_THIRD_PARTY)) {
            resultURL = Page.GFRS_Application.getUrl() + idParam + '&ci=1';
        } else if (gFRS_Util.multiSelectHasItem(request.Information_Needed__c, INFO_NEEDED_PROGRAM_DESIGN)) {
            resultURL = Page.gFRS_ProgramDesign.getUrl() + idParam;
        } else if (gFRS_Util.multiSelectHasItem(request.Information_Needed__c, INFO_NEEDED_PROGRAM)) {
            resultURL = Page.GFRS_Program.getUrl() + idParam;
        } else if (gFRS_Util.multiSelectHasItem(request.Information_Needed__c, INFO_NEEDED_BUDGET)) {
            resultURL = Page.GFRS_Budget.getUrl() + idParam;
        } else {
//-- leave alone
        }
        return(resultURL);
    }


/**
* @Author ADMD Team
* @date 27/11/2013
* @description getRFI_StartingPage method - Determines the appropriate page for an RFI.
*/
    public static String getRFI_StartingPage(Id requestId) {
        try {
            GFRS_Funding_Request__c request = [SELECT Id, Information_Needed__c FROM GFRS_Funding_Request__c WHERE Id = :requestId LIMIT 1];
            return(gFRS_Util.getRequestStartingPage(request));
        } catch (Exception err) {
            return(gFRS_Util.getRequestStartingPage(null));
        }
    }

/**
* @Author ADMD Team
* @date 27/11/2013
* @description CheckESBPaymentUpdate method - Check if ESB/SAP update SAP DOC ID. If we have SAP DOC ID change payment status to Success.
*/
    public static void CheckESBPaymentUpdate(GFRS_Payment_History__c[] newPaymenList, Map<Id, GFRS_Payment_History__c> oldMap) {
        for (GFRS_Payment_History__c currentPayment : newPaymenList) {
            GFRS_Payment_History__c oldItem = oldMap.get(currentPayment.Id);
            if (currentPayment.SAP_Doc_ID__c != null && currentPayment.SAP_Doc_ID__c != oldItem.SAP_Doc_ID__c) {
//update status to Success.
                currentPayment.Status__c = 'Success';

//set the payment/refund date to today's date
                currentPayment.Date__c = Date.today();
            }

        }
    }

/**
variable needed fro navigation prototype [pawel.niedziela@contractors.roche.com]
*/
    public static final String PARAM_NAV_SUBSECTION = 'navss';


/**
* @Author ADMD Team
* @date 27/11/2013
* @description autoPopulateCCOOwnerIfNeeded method - method sets current user as a CCO Owner, but only when Funding Request status changed to 'CCO Review' and CCO Owner was not set before.
*/
    public static void autoPopulateCCOOwnerIfNeeded(GFRS_Funding_Request__c[] newRequests, Map<Id, GFRS_Funding_Request__c> oldRequests) {
        for (GFRS_Funding_Request__c newRequest : newRequests) {
            GFRS_Funding_Request__c oldRequest = oldRequests.get(newRequest.Id);
            if (newRequest.CCO_Owner__c == null &&
                    newRequest.Sub_Status__c != oldRequest.Sub_Status__c &&
                    newRequest.Sub_Status__c == 'CCO Review') {
                autoPopulateCCOOwner(newRequest);
            }
        }
    }


/**
* @Author ADMD Team
* @date 27/11/2013
* @description autoPopulateCCOOwner method - method sets current user as a CCO Owner.
*/
    public static void autoPopulateCCOOwner(GFRS_Funding_Request__c request) {
        try {
            User curUser = gFRS_Util_NoShare.getUserById(UserInfo.getUserId());
            request.CCO_Owner__c = curUser.Name;
        } catch (Exception err) {
            System.debug('Could not auto populate CCO Owner: ' + request.Name);
        }
    }


/**
* @Author ADMD Team
* @date 27/11/2013
* @description cObject inner class - Helper class to method sortList.
*/
    public class cObject {
        SObject obj {
            get;
            set;
        }

        public cObject(SObject obj) {
            this.obj = obj;
        }
    }


/**
 * @Author ADMD Team
 * @date 27/11/2013
 * @description RfiResetInformationNeeded method - method resets Information_Needed__c field of Funding Request. That means the external portal forms will not bo editable.
 */
    public static void RfiResetInformationNeeded(GFRS_Funding_Request__c[] newFundingList) {
        for (GFRS_Funding_Request__c currentFunding : newFundingList) {
            System.debug('External_Sub_status__c :' + currentFunding.External_Sub_status__c + ' Check status :' + currentFunding.Status__c);
            if (currentFunding.External_Sub_status__c != null && currentFunding.External_Sub_status__c != 'RFI' && currentFunding.External_Sub_status__c != REQUEST_EXTERNAL_SUB_STATUS_FUNDING_TYPE_CHANGED && currentFunding.Status__c != 'Intake') {
                currentFunding.Information_Needed__c = '';

            }
        }
    }


/**
* @Author ADMD Team
* @date 27/11/2013
* @description updateUnixID method - SFDC-1457 - When user is changing 'Payment Delivery/Notification' field then Unix_ID__c and Payment_Email_Notification__c fields should be changed.
*/

    private static final Set<Id> UNIX_ID_OVERRIDES = new Set<Id>();

    public static void updateUnixID(
            final GFRS_Funding_Request__c[] newRequests,
            final Map<Id, GFRS_Funding_Request__c> oldMap
    ) {
        final Map<Id, User> usrs = new Map<Id, User>();
        final GFRS_Funding_Request__c[] reqs = new GFRS_Funding_Request__c[]{
        };
// collect all affected funding requests first
        for (SObject req : gFRS_ObjectUtil.filterChangedObjects(
                newRequests, oldMap, 'Payment_Delivery_Notifications__c'
        )) {
            final Object reqType = req.get('Record_Type_Name__c');
            if (UNIX_ID_OVERRIDES.add(req.Id) && (
                    reqType == TYPE_CORPORATE_MEMBERSHIPS_NAME ||
                            reqType == TYPE_EXHIBHITS_OTHER_PROMOS_NAME ||
                            reqType == TYPE_FIELD_INITIATED_EXHIBITS_NAME ||
                            reqType == TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME
            )) {
                usrs.put((Id) req.get('Payment_Delivery_Notifications__c'), null);
                reqs.add((GFRS_Funding_Request__c) req);
            }
        }
        usrs.remove(null);
        usrs.putAll(usrs.isEmpty() ? new User[]{
        } : [
                SELECT Alias
                FROM User
                WHERE Id IN :usrs.keySet()
                LIMIT :usrs.size()
        ]);
        for (GFRS_Funding_Request__c req : reqs) {
            if (req.Payment_Delivery_Notifications__c == null ||
                    usrs.get(req.Payment_Delivery_Notifications__c) == null
                    ) {
                req.Unix_ID__c = req.Payment_Email_Notification__c = null;
            } else {
                req.Unix_ID__c = req.Payment_Email_Notification__c = usrs.get(req.Payment_Delivery_Notifications__c).Alias;
            }
        }
    }

/**
 * @Author ADMD Team
 * @date 27/11/2013
 * @description setBiogenIdecLogo method - SFDC-1723 new method version of setting BiogenLogo Flag.
 * Fired on before/update FR trigger
 */

    public static Set<Id> SETRequestToAvoidsetBiogenIdecLogo = new Set<Id>();

    public static void setBiogenIdecLogo(Map<Id, GFRS_Funding_Request__c> mapNewRequests, List<GFRS_Funding_Request__c> listNewRequests, GFRS_OrgSettings__c orgCS, Map<Id, GFRS_Funding_Request__c> oldMapRequest) {

        try {
            GFRS_Funding_Request__c[] arrNewRequest = mapNewRequests.values();
            Map<Id, GFRS_Funding_Request__c> fundingRequestMap = new Map<Id, GFRS_Funding_Request__c>();

//HC CHar Biogen requests
            for (GFRS_Funding_Request__c objNewReq : listNewRequests) {
                if (!SETRequestToAvoidsetBiogenIdecLogo.contains(objNewReq.Id)) {
//by default each request should have biogen set to false
                    objNewReq.Is_Biogen_Idec_Logo__c = false;

//HC Char request
                    if (objNewReq.Record_Type_Name__c == 'HC Char') {
                        if (objNewReq.Therapeutic_Area__c == 'Leukemia'
                                || objNewReq.Therapeutic_Area__c == 'Lymphoma'
                                || objNewReq.Therapeutic_Area__c == 'Vasculitis'
                                || objNewReq.Therapeutic_Area__c == 'Rheumatoid Arthritis') {
                            objNewReq.Is_Biogen_Idec_Logo__c = true;
                        }
                    } else if (objNewReq.Record_Type_Name__c == 'IMED' && (objNewReq.Therapeutic_Area__c == 'Rheumatoid Arthritis'
                            || objNewReq.Therapeutic_Area__c == 'Leukemia'
                            || objNewReq.Therapeutic_Area__c == 'Lymphoma'
                            || objNewReq.Therapeutic_Area__c == 'Vasculitis'
                    ))
                        fundingRequestMap.put(objNewReq.Id, objNewReq);
                } else {
                    SETRequestToAvoidsetBiogenIdecLogo.add(objNewReq.Id);
                }
            }

            Map<Id, GFRS_Funding_Allocation_Line_Item__c> mapIMEDRequestWithBiogen = new Map<Id, GFRS_Funding_Allocation_Line_Item__c>();

            if (fundingRequestMap.size() > 0) {
                Set<String> bioncImedWbs = new Set<String>{
                        orgCS.BiogenIMEDLeukOrLymphomaWBS__c, orgCS.BiogenIMEDRheumArthrWBS__c, orgCS.BiogenIMEDVasculitisWBS__c
                };


                for (GFRS_Funding_Allocation_Line_Item__c allocLineItem : [
                        SELECT Funding_Allocation__r.Grant_Request__c,
                                Funding_Allocation__r.Grant_Request__r.Name,
                                Funding_Allocation__r.Grant_Request__r.Therapeutic_Area__c,
                                WBS__c
                        FROM GFRS_Funding_Allocation_Line_Item__c
                        WHERE
                        Funding_Allocation__r.Grant_Request__r.Record_Type_Name__c = 'IMED'
                        AND
                        (
                                WBS__c IN :bioncImedWbs
                        ) AND Funding_Allocation__r.Grant_Request__c IN:fundingRequestMap.keySet()
                ]) {
                    mapIMEDRequestWithBiogen.put(allocLineItem.Funding_Allocation__r.Grant_Request__c, allocLineItem);
                }
            }


            if (mapIMEDRequestWithBiogen.size() > 0) {
                for (GFRS_Funding_Request__c objNewReq : fundingRequestMap.values()) {

                    if (mapIMEDRequestWithBiogen.containsKey(objNewReq.Id)) {
                        GFRS_Funding_Allocation_Line_Item__c tmpAllocFR = mapIMEDRequestWithBiogen.get(objNewReq.Id);

                        if (tmpAllocFR.WBS__c == orgCS.BiogenIMEDRheumArthrWBS__c && objNewReq.Therapeutic_Area__c == 'Rheumatoid Arthritis') {
                            objNewReq.Is_Biogen_Idec_Logo__c = true;
                        } else if (tmpAllocFR.WBS__c == orgCS.BiogenIMEDLeukOrLymphomaWBS__c && (objNewReq.Therapeutic_Area__c == 'Leukemia' || objNewReq.Therapeutic_Area__c == 'Lymphoma')) {
                            objNewReq.Is_Biogen_Idec_Logo__c = true;
                        } else if (tmpAllocFR.WBS__c == orgCS.BiogenIMEDVasculitisWBS__c && objNewReq.Therapeutic_Area__c == 'Vasculitis') {
                            objNewReq.Is_Biogen_Idec_Logo__c = true;
                        } else {
                            objNewReq.Is_Biogen_Idec_Logo__c = false;
                        }
                    }
                }
            }

        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }

    }


/**
* @Author ADMD Team
* @date 27/11/2013
* @description setRecallDate method - method sets the date of recalling of approval process.
*/
    public static void setRecallDate(List<GFRS_Funding_Request__c> newRequests, Map<Id, GFRS_Funding_Request__c> oldMapRequests) {
        for (GFRS_Funding_Request__c fr : newRequests) {
            GFRS_Funding_Request__c tmpFr = oldMapRequests.get(fr.Id);
            if (fr.Sub_Status__c != tmpFr.Sub_Status__c && fr.Sub_Status__c == 'New' && tmpFr.Sub_Status__c != 'Not Submitted') {
                fr.Recall_Date__c = Date.today();
            }
        }
    }


/**
* @Author ADMD Team
* @date 27/11/2013
* @description resetFieldsAfterRecall method - method resets approprite fields after recalling approval process.
*/
    public static void resetFieldsAfterRecall(List<GFRS_Funding_Request__c> newRequests, Map<Id, GFRS_Funding_Request__c> oldMapRequests) {
        for (GFRS_Funding_Request__c fr : newRequests) {
            GFRS_Funding_Request__c tmpFr = oldMapRequests.get(fr.Id);
            if (fr.Sub_Status__c != tmpFr.Sub_Status__c && fr.Recall_Approval_Type__c == null && fr.Sub_Status__c == 'CCO Review') {
                if (fr.Record_Type_Name__c == 'Fellowships'
                        || fr.Record_Type_Name__c == 'HC Char'
                        || fr.Record_Type_Name__c == 'Philanthropic'
                        || fr.Record_Type_Name__c == 'Scientific Projects') {
                    if (fr.Foundation_Classified__c == 'FALSE') {
                        fr.Recall_Approval_Type__c = 'CAPP';
                    }

                }
                if (fr.Record_Type_Name__c == 'IMED') {
                    fr.Recall_Approval_Type__c = 'IMED';
                }
                if (fr.Record_Type_Name__c == TYPE_CORPORATE_MEMBERSHIPS_NAME
                        || fr.Record_Type_Name__c == TYPE_EXHIBHITS_OTHER_PROMOS_NAME
                        || fr.Record_Type_Name__c == TYPE_FIELD_INITIATED_EXHIBITS_NAME
                        || fr.Record_Type_Name__c == gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME) {
                    fr.Recall_Approval_Type__c = 'Corp Mem';
                }
            } else if (fr.Sub_Status__c != tmpFr.Sub_Status__c && fr.Recall_Approval_Type__c == null && fr.Sub_Status__c == 'New') {
                if ((fr.Record_Type_Name__c == 'Fellowships'
                        || fr.Record_Type_Name__c == 'HC Char'
                        || fr.Record_Type_Name__c == 'Philanthropic') && fr.Foundation_Classified__c == 'TRUE') {
                    fr.Recall_Approval_Type__c = 'Foundation';
                }
            }

            if (fr.Recall_Approval_Type__c != null && tmpFr.Recall_Approval_Type__c == null) {
                if (fr.Recall_Approval_Type__c == 'IMED') {
                    fr.Business_Approver_Decision__c = null;
                    fr.Business_Approver_Decision_Date__c = null;
                    fr.CCO_Decision__c = null;
                    fr.CCO_Decision_Date__c = null;
                    fr.Decision_Date__c = null;
                    fr.Financial_Approver_1_Decision__c = null;
                    fr.Financial_Approver_1_Decision_Date__c = null;
                    fr.Financial_Approver_2_Decision__c = null;
                    fr.Financial_Approver_2_Decision_Date__c = null;
                    fr.Financial_Approver_3_Decision__c = null;
                    fr.Financial_Approver_3_Decision_Date__c = null;
                    fr.Financial_Approver_4_Decision__c = null;
                    fr.Financial_Approver_4_Decision_Date__c = null;
                    fr.Financial_Approver_5_Decision__c = null;
                    fr.Financial_Approver_5_Decision_Date__c = null;
                    fr.GC_Decision__c = null;
                    fr.GC_Review_Decision_Date__c = null;
                    fr.HC_Compliance_Date__c = null;
                    fr.Legal_Review_Status_Date__c = null;
                    fr.Recall_Approval_Type__c = null;
                    fr.SYS_Request_Approved__c = null;
//fr.Approval_Step__c='';
                } else if (fr.Recall_Approval_Type__c == 'CAPP') {
                    fr.Business_Reviewer_Decision_Date__c = null;
                    fr.Business_Reviewer_Decision__c = null;
                    fr.CCO_Decision__c = null;
                    fr.CCO_Decision_Date__c = null;
                    fr.Decision_Date__c = null;
                    fr.Financial_Approver_1_Decision__c = null;
                    fr.Financial_Approver_1_Decision_Date__c = null;
                    fr.Financial_Approver_2_Decision__c = null;
                    fr.Financial_Approver_2_Decision_Date__c = null;
                    fr.Financial_Approver_3_Decision__c = null;
                    fr.Financial_Approver_3_Decision_Date__c = null;
                    fr.GC_Decision__c = null;
                    fr.GC_Review_Decision_Date__c = null;
                    fr.HC_Compliance_Date__c = null;
                    fr.Legal_Decision__c = null;
                    fr.Legal_Decision_Date__c = null;
                    fr.Legal_Review_Status_Date__c = null;
                    fr.Business_Approver_Decision__c = null;
                    fr.Business_Approver_Decision_Date__c = null;
                    fr.Recall_Approval_Type__c = null;
                    fr.SYS_Request_Approved__c = null;
//fr.Approval_Step__c='';
                } else if (fr.Recall_Approval_Type__c == 'Foundation') {
                    System.debug('PN****:FOUNDATION !!!');
                    fr.Business_Approver_Decision__c = null;
                    fr.Business_Approver_Decision_Date__c = null;
                    fr.Legal_Decision__c = null;
                    fr.Legal_Decision_Date__c = null;
                    fr.Legal_Review_Status_Date__c = null;
                    fr.Business_Approver_2_Decision__c = null;
                    fr.Business_Approver_2_Decision_Date__c = null;
                    fr.Business_Approver_3_Decision__c = null;
                    fr.Business_Approver_3_Decision_Date__c = null;
                    fr.GC_Decision__c = null;
                    fr.GC_Review_Decision_Date__c = null;
                    fr.Business_Reviewer_Decision__c = null;
                    fr.Business_Reviewer_Decision_Date__c = null;
                    fr.Recall_Approval_Type__c = null;
                    fr.SYS_Request_Approved__c = null;
                } else if (fr.Recall_Approval_Type__c == 'Corp Mem') {
                    fr.CCO_Decision__c = null;
                    fr.CCO_Decision_Date__c = null;
                    fr.Decision_Date__c = null;
                    fr.Decision_Reasons__c = null;
                    fr.Financial_Approver_1_Decision__c = null;
                    fr.Financial_Approver_1_Decision_Date__c = null;
                    fr.Financial_Approver_2_Decision__c = null;
                    fr.Financial_Approver_2_Decision_Date__c = null;
                    fr.Financial_Approver_3_Decision__c = null;
                    fr.Financial_Approver_3_Decision_Date__c = null;
                    fr.HC_Compliance_Date__c = null;
                    fr.Legal_Decision__c = null;
                    fr.Legal_Decision_Date__c = null;
                    fr.Legal_Review_Status_Date__c = null;
                    fr.LOA_Signed__c = null;
                    fr.Process_Disposition_Date__c = null;
                    fr.Recall_Approval_Type__c = null;
                    fr.SYS_Request_Approved__c = null;

//### clear technical InternalDenialNotificationSent__c flag. Request might be again rejected after recall
                    fr.InternalDenialNotificationSent__c = false;
                    fr.UICloseRequestDenial__c = false;
//###
                }
            }
        }
    }


/**
* @Author ADMD Team
* @date 27/11/2013
* @description changeDecisionFieldStatus method -  method needed for SFDC-2892 - if funding request sub-status is 'Canceled' we have to change statuses of given fields to 'Canceled'.
*/
    private static void changeDecisionFieldStatus(GFRS_Funding_Request__c[] newRequests, Set<String> fieldNames, String statusToChange, String newStatus) {
        for (GFRS_Funding_Request__c fundingRequest : newRequests) {
            if (fundingRequest.Sub_Status__c == REQUEST_SUB_STATUS_CANCELLED) {
                for (String field : fieldNames) {
                    if (fundingRequest.get(field) == statusToChange) {
                        fundingRequest.put(field, newStatus);
                    }
                }
            }
        }
    }

/**
* @Author ADMD Team
* @date 04/09/2013
* @description beforeUpdateFundingRequestLogic method - actions that should be made befoe updating gFRS Funding Request
*/
    public static void beforeUpdateFundingRequestLogic(GFRS_Funding_Request__c[] newRequests, Map<Id, GFRS_Funding_Request__c> oldRequests) {
        try {   //Put here your simple before update logic


/*
    SFDC-2892
    'BG 01 Capture Canceled Requests Data'
    If 'gFRS Funding Request' has 'Sub-Status' set to 'Canceled' then check the following fields and if field value = 'Rejected' change it to 'Canceled':
        HC Compliance Decision
        Legal Decision
        GC Decision
        Business Reviewer Decision
        Business Approver Decision
        Financial Approver 1 Decision
        Financial Approver 2 Decision
        Financial Approver 3 Decision
        Financial Approver 4 Decision
        Financial Approver 5 Decision
*/
            Set<String> decisionFieldsToCheck = new Set<String>{
                    'CCO_Decision__c', 'Legal_Decision__c', 'GC_Decision__c', 'Business_Reviewer_Decision__c', 'Business_Approver_Decision__c',
                    'Financial_Approver_1_Decision__c', 'Financial_Approver_2_Decision__c',
                    'Financial_Approver_3_Decision__c', 'Financial_Approver_4_Decision__c', 'Financial_Approver_5_Decision__c'
            };

            changeDecisionFieldStatus(newRequests, decisionFieldsToCheck, FUNDING_REQUEST_APPROVE_TYPE_REJECTED, FUNDING_REQUEST_APPROVE_TYPE_CANCELED);


/*
    SFDC-2098 Set Payment_Method__c if When Delivery Method
    is Orange Pouch or Field Sales Reps or Send by Fedex is Yes,
    the Payment Method will be automatically set to Check otherwise,
    it's automatically set to Default.

            GFRS_Funding_Request__c[] changedFundingRequests = new GFRS_Funding_Request__c[]{
            };
            gFRS_ObjectUtil.filterChangedObjects(newRequests, oldRequests, 'Delivery_Method__c', changedFundingRequests);

            for (GFRS_Funding_Request__c fundReq : changedFundingRequests) {
                if ((fundReq.Delivery_Method__c == 'Orange Pouch' ||
                        fundReq.Delivery_Method__c == 'Field Sales Rep') ||
                        fundReq.Send_By_FedEx_cost_center_will_be_charg__c == 'Yes') {
                    fundReq.Payment_Method__c = 'Check';
                } else {
                    fundReq.Payment_Method__c = 'Default';
                }

            }

            changedFundingRequests = new GFRS_Funding_Request__c[]{
            };
            gFRS_ObjectUtil.filterChangedObjects(newRequests, oldRequests, 'Send_By_FedEx_cost_center_will_be_charg__c', changedFundingRequests);
            for (GFRS_Funding_Request__c fundReq : changedFundingRequests) {
                if ((fundReq.Delivery_Method__c == 'Orange Pouch' ||
                        fundReq.Delivery_Method__c == 'Field Sales Rep') ||
                        fundReq.Send_By_FedEx_cost_center_will_be_charg__c == 'Yes') {
                    fundReq.Payment_Method__c = 'Check';
                } else {
                    fundReq.Payment_Method__c = 'Default';
                }

            }*/

        } catch (Exception ex) {
            System.debug('Error: ' + ex);
        }
    }


/**
* @Author ADMD Team
* @date 04/10/2013
* @description getCostCentersByIds method - getter util method for querying GFRS_Cost_Center_Code__c objects from database.
*/
    public static List<GFRS_Cost_Center_Code__c> getCostCentersByIds(Set<String> costCenterIds) {

        return [SELECT SAP_Company_Code__c FROM GFRS_Cost_Center_Code__c WHERE Id IN :costCenterIds];
    }

/**
* @Author ADMD Team
* @date 04/15/2013
* @description getCostCentersByIds method - getter util method for querying GFRS_Cost_Center_Code__c objects from database.
*/
    public static List<GFRS_Cost_Center_Code__c> getCostCentersByName(String name) {

        return [SELECT SAP_Company_Code__c FROM GFRS_Cost_Center_Code__c WHERE Name = :name];
    }

/**
* @Author ADMD Team
* @date 04/11/2013
* @description getWbsCodesByIds method - getter util method for querying GFRS_WBS_Codes__c objects from database.
*/
    public static List<GFRS_WBS_Codes__c> getWbsCodesByIds(Set<String> wbsCodesIds) {

        return [SELECT SAP_Company_Code__c FROM GFRS_WBS_Codes__c WHERE Id IN :wbsCodesIds];
    }

/**
* @Author ADMD Team
* @date 04/16/2013
* @description getCostCentersMapByIds method - getter util method for querying GFRS_Cost_Center_Code__c objects from database.
*/
    public static Map<Id, GFRS_Cost_Center_Code__c> getCostCentersMapByIds(Set<String> costCenterIds) {

        return new Map<Id, GFRS_Cost_Center_Code__c>([SELECT SAP_Company_Code__c FROM GFRS_Cost_Center_Code__c WHERE Id IN :costCenterIds]);
    }

/**
* @Author ADMD Team
* @date 04/16/2013
* @description getWbsCodesMapByIds method - getter util method for querying GFRS_WBS_Codes__c objects from database.
*/
    public static Map<Id, GFRS_WBS_Codes__c> getWbsCodesMapByIds(Set<String> wbsCodesIds) {

        return new Map<Id, GFRS_WBS_Codes__c>([SELECT SAP_Company_Code__c FROM GFRS_WBS_Codes__c WHERE Id IN :wbsCodesIds]);
    }

/**
* @Author ADMD Team
* @date 04/18/2013
* @description getFundingRequestsByLocationId method - getter util method for querying GFRS_Funding_Request__c objects from database for a given location id, but only with Status != "Intake","Closed".
*/
    public static List<GFRS_Funding_Request__c> getFundingRequestsByLocationId(String locationId) {

        return [SELECT Name, Funding_Type__c, Location__c FROM GFRS_Funding_Request__c WHERE Location__c = :locationId AND Status__c NOT IN ('Intake', 'Closed') AND SAP_Payment_ID__c = NULL ORDER BY Funding_Type__c];
    }

/**
* @Author ADMD Team
* @date 26/08/2013
* @description showFoundation method - indicates wheter 'Foundation' section should be shown or not
*/
    public static Boolean showFoundation(Id fundingRequestId) {
        List<GFRS_Funding_Request__c> fundingRequestsList = gFRS_DAO.getFundingRequestById(fundingRequestId);

        GFRS_Funding_Request__c fundingRequest;
        if (fundingRequestsList != null && fundingRequestsList.size() > 0) {
            fundingRequest = fundingRequestsList.get(0);
        } else {
            return false;
        }
//Condition for Philantropic was changed for fix QC-23643 in jira SFDC-1693
        if (gFRS_Util.TYPE_PHILANTHROPIC_NAME.equals(fundingRequest.Record_Type_Name__c)) {
            if (gFRS_Util.YES.equals(fundingRequest.Students_of_Color_Scholarships__c) ||
                    gFRS_Util.YES.equals(fundingRequest.Hunger__c)) {
                return true;
            } else if (!gFRS_Util.YES.equals(fundingRequest.Students_of_Color_Scholarships__c) && !gFRS_Util.YES.equals(fundingRequest.Hunger__c) && fundingRequest.Requested_Amount__c > 25000) {
                return true;
            } else
                    return false;

        } else if (gFRS_Util.TYPE_HC_CHAR_NAME.equals(fundingRequest.Record_Type_Name__c)) {
            return(
                    gFRS_Util.YES.equals(fundingRequest.Pediatric_Cancer_Assistance__c)
            );
        } else if (gFRS_Util.TYPE_FELLOWSHIPS_NAME.equals(fundingRequest.Record_Type_Name__c)) {
            return(
                    gFRS_Util.YES.equals(fundingRequest.Basic_Research_Fellow__c)
            );
        } else {
            return(false);
        }
    }

/**
* @Author ADMD Team
* @date 28/02/2014
* @description isRequestFoundationType method - indicates wheter given request is Foundation or Non-Foundation
*/
    public static Boolean isRequestFoundationType(Id fundingRequestId) {
        List<GFRS_Funding_Request__c> fundingRequestsList = gFRS_DAO.getFundingRequestById(fundingRequestId);

        GFRS_Funding_Request__c fundingRequest;
        if (fundingRequestsList != null && fundingRequestsList.size() > 0) {
            fundingRequest = fundingRequestsList.get(0);
        } else {
            return false;
        }

        if (fundingRequest.Record_Type_Name__c == TYPE_FELLOWSHIPS_NAME
                || fundingRequest.Record_Type_Name__c == TYPE_PHILANTHROPIC_NAME
                || fundingRequest.Record_Type_Name__c == TYPE_HC_CHAR_NAME) {

            return true;
        } else {
            return false;
        }

    }

/**
* @Author ADMD Team
* @date 08/08/2013
* @description SetBusinessUnit method - set Business Unit for specific TA.
*/
    public static void SetBusinessUnit(GFRS_Funding_Request__c[] newFundingList, Map<Id, GFRS_Funding_Request__c> oldMap) {
        GFRS_Funding_Request__c objReq;
        GFRS_Funding_Request__c oldReq;
        try {
            for (GFRS_Funding_Request__c currentFunding : newFundingList) {
                objReq = currentFunding;
                System.debug('Business_Unit_2__c :' + currentFunding.Business_Unit_2__c + ' Therapeutic_Area__c :' + currentFunding.Therapeutic_Area_Parent__c);
                System.debug('PN TEST OLD MAP: ' + oldMap);
                System.debug('PN TEST objReq.id: ' + objReq.Id);
                oldReq = oldMap.containsKey(objReq.Id) == true ? oldMap.get(objReq.Id) : null;
                if (currentFunding.Therapeutic_Area_Parent__c != null) {
                    if (oldReq == null || oldReq.Therapeutic_Area_Parent__c != currentFunding.Therapeutic_Area_Parent__c) {
                        currentFunding.Business_Unit_2__c = GetBusinessUnitBasedOnTA(currentFunding.Therapeutic_Area_Parent__c);
                    }
                } else if (currentFunding.Therapeutic_Area_Parent__c == null) {
                    currentFunding.Business_Unit_2__c = null;
                }
            }
        } catch (Exception ex) {
            System.debug('Error occurs STACK TRACE: ' + ex.getStackTraceString());
            System.debug('Error occurs MESSAGE: ' + ex.getMessage());

        }
    }


/**
* @Author ADMD Team
* @date 02/10/2014
* @description setFundingSubTypeForInternalFundingTypes method - set
* Funding Sub Type field when request fliped form Corporate or FIE to
* Scientific Pipline or Exhibit & Other Promo
*/
    public static void setFundingSubTypeForInternalFundingTypes(GFRS_Funding_Request__c[] newFundingList, Map<Id, GFRS_Funding_Request__c> oldMap) {


        GFRS_Funding_Request__c[] changedFundingRequests = new GFRS_Funding_Request__c[]{
        };
        gFRS_ObjectUtil.filterChangedObjects(newFundingList, oldMap, 'Record_Type_Name__c', changedFundingRequests);

        try {
            for (GFRS_Funding_Request__c fundReq : changedFundingRequests) {
                if ((fundReq.Record_Type_Name__c == gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME || fundReq.Record_Type_Name__c == gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME)
                        && (oldMap.get(fundReq.Id).Record_Type_Name__c == gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME || oldMap.get(fundReq.Id).Record_Type_Name__c == gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME)) {
                    fundReq.Funding_Sub_Type__c = gFRS_Util.Sub_Type_Sponsorship;
                } else if ((oldMap.get(fundReq.Id).Record_Type_Name__c == gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME || oldMap.get(fundReq.Id).Record_Type_Name__c == gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME)
                        && (fundReq.Record_Type_Name__c == gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME || fundReq.Record_Type_Name__c == gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME)) {
                    fundReq.Funding_Sub_Type__c = null;
                }
            }
        } catch (Exception ex) {
            System.debug('**********setFundingSubTypeForInternalFundingTypes error occured:' + ex.getMessage());
        }
    }

/**
* @Author ADMD Team
* @date 08/08/2013
* @description SetBusinessUnit method - set Business Unit for specific TA.
*/
    private static String GetBusinessUnitBasedOnTA(String p_TA) {
        String BIOONC_BU_TA_Mapping = '';
        String GIO_BU_TA_Mapping = '';
        String IMPACT_BU_TA_Mapping = '';
        String OTHER_BU_TA_Mapping = '';
        String retVal = '';

        GFRS_OrgSettings__c myOrgCS = GFRS_OrgSettings__c.getOrgDefaults();
        BIOONC_BU_TA_Mapping = myOrgCS.BIOONC_BU_TA_Mapping__c;
        GIO_BU_TA_Mapping = myOrgCS.GIO_BU_TA_Mapping__c;
        IMPACT_BU_TA_Mapping = myOrgCS.IMPACT_BU_TA_Mapping__c;
        OTHER_BU_TA_Mapping = myOrgCS.OTHER_BU_TA_Mapping__c;

        if (BIOONC_BU_TA_Mapping.contains(p_TA)) retVal = 'BIOONC';
        if (GIO_BU_TA_Mapping.contains(p_TA)) retVal = 'GIO';
        if (IMPACT_BU_TA_Mapping.contains(p_TA)) retVal = 'IMPACT';
        if (OTHER_BU_TA_Mapping.contains(p_TA))retVal = 'OTHER';

        return retVal;
    }

/**
 * @Author ADMD Team
 * @date 10/07/2015
 * @description Verify if context user is external
 */
    public static Boolean isExternalUser() {
        return ([SELECT Id, AccountId, IsPortalEnabled FROM User WHERE Id = :UserInfo.getUserId() AND IsPortalEnabled = TRUE AND AccountId != NULL].size() != 0);

    }
/**
* @author GFRS Dev Team
* @date 10/10/2016
* @description checkIfThirdPartyVisible method - check whether third party section should be visible
*/
    public static Boolean checkIfThirdPartyVisible(GFRS_Funding_Request__c fundingRequest) {
        if (fundingRequest != null) {
            return [
                    SELECT Id, Record_Type_Name__c, Will_You_be_Working_With_a_3rd_Party__c
                    FROM GFRS_Funding_Request__c
                    WHERE Id = :fundingRequest.Id AND (Record_Type_Name__c = :gFRS_Util.TYPE_IMED_NAME OR Record_Type_Name__c = :gFRS_Util.TYPE_HC_CHAR_NAME)
                    AND Will_You_be_Working_With_a_3rd_Party__c = :gFRS_Util.YES
            ].size() > 0;
        }
        return false;
    }

    public static Boolean showWarningMessageForGLAccount(GFRS_Funding_Request__c fundReq) {
        if (fundReq.Status__c == REQUEST_STATUS_DECISION && gFRS_Util.isInternalRequest(fundReq.Record_Type_Name__c)) {
            if (fundReq.Record_Type_Name__c == TYPE_FIELD_INITIATED_EXHIBITS_NAME && fundReq.Sub_Status__c == REQUEST_SUB_STATUS_BUSINESS_REV) {
                return true;
            } else if (fundReq.Sub_Status__c == REQUEST_SUB_STATUS_FINANCIAL_APPROVAL || (fundReq.Sub_Status__c == REQUEST_SUB_STATUS_BUSINESS_REV && String.isBlank(fundReq.Financial_Approver_2__c))) {
                return true;
            }
        }
        return false;
    }

/**
 * @author DEV Team
 * @date 10/01/2018
 * @description Method to update Focus Area field. Method used in Funding Request update/insert trigger
 *
 * @param fundingRequests
 */
    public static void updateFocusAreaField(List<GFRS_Funding_Request__c> fundingRequests) {
        String recordTypeName;
        for (GFRS_Funding_Request__c fundingRequest : fundingRequests) {
            recordTypeName = getRecordTypeName(fundingRequest);
            if (recordTypeName.equals(TYPE_HC_CHAR_NAME) || recordTypeName.equals(TYPE_PHILANTHROPIC_NAME) ||
                    recordTypeName.equals(TYPE_FELLOWSHIPS_NAME) || recordTypeName.equals(TYPE_SCIENTIFIC_PROJECTS_NAME)) {
                fundingRequest = updateFocusAreaOnFundingRequest(fundingRequest);
            }
        }
    }

/**
 * @author DEV Team
 * @data 10/01/2018
 * @description Method to update Focus Area field for batch apex.
 *
 * @param fundingRequests
 *
 * @return List of Funding Request objects with updated Focus Area field
 */
    public static List<GFRS_Funding_Request__c> getListOfFundingRequestsWithFocusAreaField(List<GFRS_Funding_Request__c> fundingRequests) {
        for (GFRS_Funding_Request__c fundingRequest : fundingRequests) {
            updateFocusAreaOnFundingRequest(fundingRequest);
        }
        return fundingRequests;
    }

/**
 * @author DEV Team
 * @date 10/01/2018
 * @description Main logic for mapping Social Impact Goals to Focus Area.
 *
 * @param fundingRequest
 *
 * @return Funding Request with modified Focus Area field
 */
    private static GFRS_Funding_Request__c updateFocusAreaOnFundingRequest(GFRS_Funding_Request__c fundingRequest) {
        Set<String> goals = getFocusAreaFromSocialGoal(getSocialGoals(fundingRequest));

        if (goals.size() > 1) {
            System.debug(LoggingLevel.ERROR, 'Error [Social Goals Mapping]: ' + fundingRequest.Id + ';' + fundingRequest.Name);
            if (System.isBatch()) {
                fundingRequest.Focus_Area__c = null;
            } else {
                fundingRequest.addError(Label.gFRS_ERROR_SOCIAL_IMPACT_GOALS_MAPPING);
            }
        } else if (goals.size() == 1) {
            System.debug(LoggingLevel.INFO, 'INFO [Social Goals Mapping]: ' + fundingRequest.Id + ';' + fundingRequest.Name + ';' + fundingRequest.Social_Impact_Goals_CEG__c + ';' + fundingRequest.Focus_Area__c);
            fundingRequest.Focus_Area__c = new List<String>(goals)[0];
        } else {
            System.debug(LoggingLevel.INFO, 'INFO [Social Goals Mapping - Empty]: ' + fundingRequest.Id + ';' + fundingRequest.Name + ';' + fundingRequest.Social_Impact_Goals_CEG__c);
            fundingRequest.Focus_Area__c = null;
        }
        return fundingRequest;
    }

/**
 * @author DEV team
 * @date 10/01/2018
 * @description Method to map Social Impact Goals to Focus Area. Be aware of correct picklist indexes. Mapping is based on document in GFRS-1023 JIRA.
 *
 * @param goals List of goals
 *
 * @return Set with unique Focus Area name
 */
    private static Set<String> getFocusAreaFromSocialGoal(List<String> goals) {
        Set<String> uniqueGoals = new Set<String>();
        Map<String, String> mapping = new Map<String, String>{
                'Strengthen pathways for STEM careers' => 'STEM Pathways',
                'Foster scientific innovation and exchange of ideas' => 'Scientific Innovation',
                'Advance local community development' => 'Community development',
                'Other' => 'Others',
                'Strengthen general disease awareness' => 'Health outcomes',
                'Improve awareness, access, and rates of early detection and diagnosis' => 'Health outcomes',
                'Improve access to and quality of treatment and patient support' => 'Health outcomes',
                'Support the enabling environment for patient care' => 'Health outcomes',
                'Promote, test, and scale models to prevent disease' => 'Health outcomes'
        };

        for (String socialGoal : goals) {
            uniqueGoals.add(mapping.get(socialGoal));
        }
        return uniqueGoals;
    }

/**
 * @author DEV Team
 * @date 10/01/2018
 * @description Method to get Funding Request record type name
 *
 * @param fundingRequest
 *
 * @return String name of record type
 */
    private static String getRecordTypeName(GFRS_Funding_Request__c fundingRequest) {
        Map<Id, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.GFRS_Funding_Request__c.getRecordTypeInfosById();
        return rtMap.get(fundingRequest.RecordTypeId).getName();
    }

/**
 * @author DEV Team
 * @date 10/01/2018
 * @description Method to retrieve social impact goals from mutlipicklist and put them to list
 *
 * @param fundingRequest
 *
 * @return List with social impact goals
 */
    private static List<String> getSocialGoals(GFRS_Funding_Request__c fundingRequest) {
        List<String> goals = new List<String>();
        if (fundingRequest != null && fundingRequest.Social_Impact_Goals_CEG__c != null) {
            goals = fundingRequest.Social_Impact_Goals_CEG__c.split(';');
        }
        return goals;
    }

/**
 * @author DEV Team
 * @date 10/01/2018
 * @description Generic method to get picklist values based on object and field API name
 *
 * @param objectApiName
 * @param fieldName
 *
 * @return List of picklist values
 */
    public static List<String> getPicklistValues(String objectApiName, String fieldName) {
        List<String> values = new List<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectApiName);
        SObject objectName = targetType.newSObject();
        Schema.SObjectType sObjectType = objectName.getSObjectType();
        Schema.DescribeSObjectResult sObjectDescribe = sObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = sObjectDescribe.fields.getMap();
        List<Schema.PicklistEntry> picklistValues = fieldMap.get(fieldName).getDescribe().getPicklistValues();
        for (Schema.PicklistEntry a : picklistValues) {
            values.add(a.getValue());
        }
        return values;
    }

/**
 * @author DEV Team
 * @date 19/03/2018
 * @description Method to update Vendor Account Group based on first digits of Vendor ID. (001 or 1 for PC01, rest for Z003)
 *
 * @param triggerScope - List of objects from update trigger.
 */
    public static void setCorrectVendorAccountGroup(List<GFRS_Location__c> triggerScope) {
        for (GFRS_Location__c location : triggerScope) {
            if (String.isBlank(location.Vendor_ID__c))
                location.Vendor_Account_Group__c = null; else {
                if (checkForPC01Location(location.Vendor_ID__c)) {
                    location.Vendor_Account_Group__c = 'PC01';
                } else {
                    location.Vendor_Account_Group__c = 'Z003';
                }
            }
        }
    }

/**
 * @description Helper method to check conditions for setting Vendor Account Group
 *
 * @param vendorId - String (10 or 8 digits)
 *
 * @return true if Vendor Account Group should be set to PC01
 */
    private static Boolean checkForPC01Location(String vendorId) {
        if (vendorId.length() == 10 && vendorId.left(3).equals('001')) {
            return true;
        } else if (vendorId.length() == 8 && vendorId.left(1).equals('1')) {
            return true;
        }
        return false;
    }

    public static Boolean isValidBusinessDaysBetweenDates(Date fromDate, Date toDate, Integer days) {
        Set<Date> businessDays = new Set<Date>();
        while (fromDate < toDate) {
            Datetime dtime = Datetime.newInstance(fromDate.year(), fromDate.month(), fromDate.day());
            if (dtime.format('E') != 'Sat' && dtime.format('E') != 'Sun') {
                businessDays.add(fromDate);
            }
            fromDate = fromDate.addDays(1);
        }

        if (businessDays.size() >= days) {
            return true;
        }
        return false;
    }

    public static Boolean isValidCalenderDaysBetweenDates(Date fromDate, Date toDate, Integer days) {
        Set<Date> businessDays = new Set<Date>();
        while (fromDate <= toDate) {
            businessDays.add(fromDate);
            fromDate = fromDate.addDays(1);
        }

        if (businessDays.size() > days) {
            return true;
        }
        return false;
    }       

    private static void sendEmailToOwnerAndAccountableEmployee(Set<GFRS_Funding_Request__c> fundingRequests) {

        for (GFRS_Funding_Request__c fundingRequest : fundingRequests) {
            if (String.isNotBlank(fundingRequest.Accountable_Employee_Approval__c) && fundingRequest.OwnerId != fundingRequest.Accountable_Employee_Approval__c) {
                GFRS_NotificationUtil.prepareEmailMessage(fundingRequest.Accountable_Employee_Approval__c, fundingRequest.Id, 'UC_05_Approving_Rejecting_Requests_Approval_Pending_Email_To_Owner');
            }
            GFRS_NotificationUtil.prepareEmailMessage(fundingRequest.OwnerId, fundingRequest.Id, 'UC_05_Approving_Rejecting_Requests_Approval_Pending_Email_To_Owner');
        }

        GFRS_NotificationUtil.sendNotifications();
    }

    public static void sendNotification(GFRS_Funding_Request__c[] requests, Map<Id, GFRS_Funding_Request__c> oldMap) {
        List<GFRS_Funding_Request__c> changedFundingType = new List<GFRS_Funding_Request__c>();
        gFRS_ObjectUtil.filterChangedObjects(requests, oldMap, 'RecordTypeId', changedFundingType);
        if (!changedFundingType.isEmpty()) {
            gFRS_Util.sendChangeFundingTypeNotification(new Set<GFRS_Funding_Request__c>(changedFundingType));
        }
    }

    public static void sendChangeFundingTypeNotification(Set<GFRS_Funding_Request__c> fundingRequests) {
        for (GFRS_Funding_Request__c fundingRequest : fundingRequests) {
            Messaging.SingleEmailMessage mail = GFRS_NotificationUtil.prepareEmailMessage(fundingRequest.OwnerId, fundingRequest.Id, 'Change_Funding_Type');
            if (GFRS_NotificationUtil.getOWEA() != null) {
                mail.setOrgWideEmailAddressId(GFRS_NotificationUtil.getOWEA().Id);
            } else if (GFRS_NotificationUtil.getSenderDisplayName() != null) {
                mail.setSenderDisplayName(GFRS_NotificationUtil.getSenderDisplayName());
            }
//get email used in email service to attached sent emails
            GFRS_OrgSettings__c myOrgCS = GFRS_OrgSettings__c.getOrgDefaults();
            if (myOrgCS.gFRS_Inbound_Email__c != null) {
                mail.setBccAddresses(new List<String>{
                        myOrgCS.gFRS_Inbound_Email__c
                });
            }
        }

        GFRS_NotificationUtil.sendNotifications();
    }

    private static Set<Id> approvalNotificationFundingRequests = new Set<Id>();

    public static void sendApprovalNotificationEmailsToFundingRequestOwner(List<GFRS_Funding_Request__c> requests, Map<Id, GFRS_Funding_Request__c> oldMap) {

        List<String> fieldsToCheck = new List<String>{
                'CCO_Decision__c',
                'Legal_Decision__c',
                'Financial_Approver_1_Decision__c',
                'Financial_Approver_2_Decision__c'
        };

        Set<GFRS_Funding_Request__c> fundingRequestsToSendEmail = new Set<GFRS_Funding_Request__c>();

        for (GFRS_Funding_Request__c fundingRequest : requests) {

            if (gFRS_Util.isInternalRequest(fundingRequest.Record_Type_Name__c)) {

                for (String fName : fieldsToCheck) {

                    if (fundingRequest.get(fName) != oldMap.get(fundingRequest.Id).get(fName) &&
                            fundingRequest.get(fName) == 'Approved' &&
                            !approvalNotificationFundingRequests.contains(fundingRequest.Id)) {

                        if (!(fundingRequest.Record_Type_Name__c.equals(gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME) && fName == 'Financial_Approver_1_Decision__c')) {
                            approvalNotificationFundingRequests.add(fundingRequest.Id);
                            fundingRequestsToSendEmail.add(fundingRequest);
                        }

                        break;
                    }

                }

            }

        }

        if (fundingRequestsToSendEmail.size() > 0)
            sendEmailToOwnerAndAccountableEmployee(fundingRequestsToSendEmail);

    }

/**
 * @author DEV Team
 * @date 20/07/2018
 * @description Method used in after update trigger to check if Decision Date was changed. Approved Fiscal Year is set as year from Decision Date.
 * Decision_Date__c is set in workflow rule when status is changed to Decision. See GFRSME2-7 for reference.
 *
 * @param requests Trigger.New
 * @param oldMap Trigger.oldMap
 */
    public static void setFiscalYear(List<GFRS_Funding_Request__c> requests, Map<Id, GFRS_Funding_Request__c> oldMap) {
        List<GFRS_Funding_Allocation__c> fundingAllocations = gFRS_DAO.getFundingAllocationsByRequestIds(gFRS_DAO.getFundingRequestsIds(requests));
        List<GFRS_Funding_Allocation__c> fundingAllocationsToUpdate = new List<GFRS_Funding_Allocation__c>();

        for (GFRS_Funding_Allocation__c fundingAllocation : fundingAllocations) {
            GFRS_Funding_Request__c oldFundingRequest = oldMap.get(fundingAllocation.Grant_Request__r.Id);

            if (gFRS_Util_NoShare.isBusinessApprovalRejected(oldFundingRequest, fundingAllocation.Grant_Request__r, true) ||
                    gFRS_Util_NoShare.isBusinessApprovalRejected(oldFundingRequest, fundingAllocation.Grant_Request__r, false)) {
                fundingAllocation.Approved_Fiscal_Year__c = null;
                fundingAllocationsToUpdate.add(fundingAllocation);
                continue;
            }

            if (checkRequestTypeForFiscalYearUpdate(oldFundingRequest) &&
                    fundingAllocation.Grant_Request__r.Decision_Date__c != oldFundingRequest.Decision_Date__c) {

                Date decisionDate = fundingAllocation.Grant_Request__r.Decision_Date__c;
                if (decisionDate != null) {
                    fundingAllocation.Approved_Fiscal_Year__c = String.valueOf(decisionDate.year());
                    fundingAllocationsToUpdate.add(fundingAllocation);
                    continue;
                }
            }
        }

        if (fundingAllocationsToUpdate.size() > 0) {
            update fundingAllocationsToUpdate;
        }
    }

/**
 * @author DEV Team
 * @date 10/01/2018
 * @description Method used in before update trigger to clear request fields values after funding type change. See GFRSME2-4 for reference.
 *
 * @param requests Trigger.New
 * @param oldMap Trigger.oldMap
 */
    public static void cleanupRequestFieldsAfterFundingTypeChange(GFRS_Funding_Request__c[] newRequests, Map<Id, GFRS_Funding_Request__c> oldRequests) {
        final GFRS_Funding_Request__c[] changedFundingRequests = new GFRS_Funding_Request__c[]{
        };
        gFRS_ObjectUtil.filterChangedObjects(newRequests, oldRequests, 'Record_Type_Name__c', changedFundingRequests);


        if (!changedFundingRequests.isEmpty()) {
            Set<Id> requestIds = new Set<Id>();
            Map<String, Set<String>> configuration = getFieldsPerFundingType('GFRS_Funding_Request__c');

            for (GFRS_Funding_Request__c request : changedFundingRequests) {
                requestIds.add(request.Id);
                Set<String> oldTypeFields = configuration.get(oldRequests.get(request.Id).Record_Type_Name__c);
                Set<String> newTypeFields = configuration.get(request.Record_Type_Name__c);
                if (oldTypeFields != null && newTypeFields != null) {
                    for (String field : oldTypeFields) {
                        if (!newTypeFields.contains(field)) {
                            request.put(field, null);
                        }
                    }
                }
            }
        }
    }

/**
 * @author DEV Team
 * @date 10/01/2018
 * @description Method used in after update trigger to clear request related object fields values after funding type change. See GFRSME2-4 for reference.
 *
 * @param requests Trigger.New
 * @param oldMap Trigger.oldMap
 */
    public static void cleanupFieldsAfterFundingTypeChange(GFRS_Funding_Request__c[] newRequests, Map<Id, GFRS_Funding_Request__c> oldRequests) {
        final GFRS_Funding_Request__c[] changedFundingRequests = new GFRS_Funding_Request__c[]{
        };
        gFRS_ObjectUtil.filterChangedObjects(newRequests, oldRequests, 'Record_Type_Name__c', changedFundingRequests);
        if (!changedFundingRequests.isEmpty()) {
            Map<String, Set<String>> configuration = getFieldsPerFundingType('GFRS_Program__c');

            Set<Id> requestIds = new Set<Id>();
            for (GFRS_Funding_Request__c request : changedFundingRequests) {
                requestIds.add(request.Id);
            }
            Map<Id, List<GFRS_Program__c>> requestsToPrograms = new Map<Id, List<GFRS_Program__c>>();
            for (GFRS_Program__c program : [
                    SELECT Id, Funding_Request__c
                    FROM GFRS_Program__c
                    WHERE Funding_Request__c IN :requestIds
            ]) {
                if (!requestsToPrograms.containsKey(program.Funding_Request__c)) {
                    requestsToPrograms.put(program.Funding_Request__c, new List<GFRS_Program__c>());
                }
                requestsToPrograms.get(program.Funding_Request__c).add(program);
            }
            Map<Id, GFRS_Program__c> toUpdate = new Map<Id, GFRS_Program__c>();
            for (GFRS_Funding_Request__c request : changedFundingRequests) {
                Set<String> oldTypeFields = configuration.get(oldRequests.get(request.Id).Record_Type_Name__c);
                Set<String> newTypeFields = configuration.get(request.Record_Type_Name__c);
                if (oldTypeFields != null && newTypeFields != null) {
                    if (requestsToPrograms.containsKey(request.Id)) {
                        for (GFRS_Program__c program : requestsToPrograms.get(request.Id)) {
                            for (String field : oldTypeFields) {
                                if (!newTypeFields.contains(field)) {
                                    program.put(field, null);
                                    toUpdate.put(program.Id, program);
                                }
                            }
                        }
                    }
                }
            }
            update toUpdate.values();
        }
    }

    private static Map<String, Set<String>> getFieldsPerFundingType(String objectName) {
        Map<String, Set<String>> configuration = new Map<String, Set<String>>();
        for (GFRS_Funding_Type_Fields__mdt config : [SELECT Record_Type_Name__c, Fields__c FROM GFRS_Funding_Type_Fields__mdt WHERE Object_Name__c = :objectName]) {
            configuration.put(config.Record_Type_Name__c, new Set<String>(config.Fields__c.split(',')));
        }
        return configuration;
    }

    private static Map<String, Map<String, Set<String>>> getFieldsPerFundingType() {
        Map<String, Map<String, Set<String>>> configuration = new Map<String, Map<String, Set<String>>>();

        for (GFRS_Funding_Type_Fields__mdt config : [SELECT Object_Name__c, Record_Type_Name__c, Fields__c FROM GFRS_Funding_Type_Fields__mdt]) {
            if (!configuration.containsKey(config.Record_Type_Name__c)) {
                configuration.put(config.Record_Type_Name__c, new Map<String, Set<String>>());
            }
            configuration.get(config.Record_Type_Name__c).put(config.Object_Name__c, new Set<String>(config.Fields__c.split(',')));
        }
        return configuration;
    }

/**
 * @author DEV Team
 * @date 20/07/2018
 * @description Method is checking if request is external or IMED
 *
 * @param request Funding Request object with field : Record_Type_Name__c
 *
 * @return true if Funding Request is external or IMED
 */
    public static Boolean checkRequestTypeForFiscalYearUpdate(GFRS_Funding_Request__c request) {
        return request.Record_Type_Name__c == TYPE_IMED_NAME ?
                true : gFRS_Util.isExternalRequest(request.Record_Type_Name__c) ?
                        true : false;
    }
/*    
    /**
     * @author TechM DEV Team
     * @date 16/01/2019
     * @description Method is checking if request is having any mandatory fields that are not filled before submission*/

     public static Boolean checkRequestForUnfilledMandtryFields(GFRS_Funding_Request__c request){
        Boolean isHavingUnfilledMandtryFields = false;
        String fieldSetName = '';
        if(request.Record_Type_Name__c == 'Sci/Pipeline Exhibits & Other Non-Promo'){
            fieldSetName = 'Sci/Pipeline Exhibits & Non-Promo';
        }else{
            gFRS_Mandatory_Fields__c fieldsetDetails = gFRS_Mandatory_Fields__c.getValues(request.Record_Type_Name__c);
            fieldSetName = fieldsetDetails.Mandatory_Fields__c;   
        }
        if(isFundingRequestHvngUnfilledMndtryFlds(fieldSetName,request.Id) || isProgramHvngUnfilledMndtryFlds(fieldSetName,request.Id) || 
                isDemographicHvngUnfilledMndtryFlds(fieldSetName,request.Id) || isThirdPartyHvngUnfilledMndtryFlds(fieldSetName,request.Id)){
                    isHavingUnfilledMandtryFields = true;
        }
        return isHavingUnfilledMandtryFields;  
     }
    /**
     * @author TechM DEV Team
     * @date 16/01/2019
     * @description Method is checking if gFRS Funding Object is having any mandatory fields that are not filled*/
     public static Boolean isFundingRequestHvngUnfilledMndtryFlds(String fieldSetName, Id requestId){
        List<Schema.FieldSetMember> mandtryFields = new List<Schema.FieldSetMember>();
        if(Schema.SObjectType.GFRS_Funding_Request__c.fieldSets.getmap().containsKey(fieldSetName)){
            mandtryFields = Schema.SObjectType.GFRS_Funding_Request__c.fieldSets.getmap().get(fieldSetName).getFields();            
        }else{
            return False;
        }
        String query = 'SELECT ';
            for(Schema.FieldSetMember f : mandtryFields) {
                query += f.getFieldPath() + ', ';
            }
            query += 'Id FROM GFRS_Funding_Request__c where id = \'' + requestId + '\'';
        GFRS_Funding_Request__c fundreq = Database.query(query);
        for(Schema.FieldSetMember f : mandtryFields){
            if(fundreq.get(f.getFieldPath()) == null){
               // system.assertequals('GFRS_Funding_Request__c', f.getFieldPath());
                return True;
            }
        }
        return false;
     }
    /**
     * @author TechM DEV Team
     * @date 16/01/2019
     * @description Method is checking if gFRS Programming Object is having any mandatory fields that are not filled*/
     public static Boolean isProgramHvngUnfilledMndtryFlds(String fieldSetName,  Id requestId){
        List<GFRS_Program__c> programsList = [SELECT Id FROM GFRS_Program__c WHERE Funding_Request__c = :requestId];
        List<Schema.FieldSetMember> mandtryFields = new List<Schema.FieldSetMember>();
        if(Schema.SObjectType.GFRS_Program__c.fieldSets.getmap().containsKey(fieldSetName)){
            mandtryFields = Schema.SObjectType.GFRS_Program__c.fieldSets.getmap().get(fieldSetName).getFields();            
        }else{
            return False;
        }
        for(GFRS_Program__c program : programsList){
            String query = 'SELECT ';
            for(Schema.FieldSetMember f : mandtryFields) {
                query += f.getFieldPath() + ', ';
            }
            query += 'Id FROM GFRS_Program__c where id = \'' + program.Id + '\'';
            GFRS_Program__c program2 = Database.query(query);
            for(Schema.FieldSetMember f : mandtryFields){
                if(program2.get(f.getFieldPath()) == null){
                 // system.assertequals('GFRS_Program__c', f.getFieldPath());
                    return True;
                }
            } 
        }
        return false;
     }
    /**
     * @author TechM DEV Team
     * @date 16/01/2019
     * @description Method is checking if gFRS Demographic Object is having any mandatory fields that are not filled*/
     public static Boolean isDemographicHvngUnfilledMndtryFlds(String fieldSetName,  Id requestId){
        List<GFRS_Demographic_Group__c> demographicList= [SELECT Id FROM GFRS_Demographic_Group__c WHERE gFRS_Funding_Request__c = :requestId];
        List<Schema.FieldSetMember> mandtryFields = new List<Schema.FieldSetMember>();
        if(Schema.SObjectType.GFRS_Demographic_Group__c.fieldSets.getmap().containsKey(fieldSetName)){
            mandtryFields = Schema.SObjectType.GFRS_Demographic_Group__c.fieldSets.getmap().get(fieldSetName).getFields();            
        }else{
            return False;
        }
        for(GFRS_Demographic_Group__c demographic : demographicList){
            String query = 'SELECT ';
            for(Schema.FieldSetMember f : mandtryFields) {
                query += f.getFieldPath() + ', ';
            }
            query += 'Id FROM GFRS_Demographic_Group__c where id = \'' + demographic.Id + '\'';
            GFRS_Demographic_Group__c demographic2 = Database.query(query);
            for(Schema.FieldSetMember f : mandtryFields){
                if(demographic2.get(f.getFieldPath()) == null){
                   //system.assertequals('GFRS_Demographic_Group__c', f.getFieldPath());
                    return True;
                }
            } 
        }
        return false;
     }
    /**
     * @author TechM DEV Team
     * @date 16/01/2019
     * @description Method is checking if gFRS Third Party Object is having any mandatory fields that are not filled*/
     public static Boolean isThirdPartyHvngUnfilledMndtryFlds(String fieldSetName,  Id requestId){
        List<gFRS_Third_Party__c> thirdPartyList = [SELECT Id FROM gFRS_Third_Party__c WHERE Funding_Request__c = :requestId];
        List<Schema.FieldSetMember> mandtryFields = new List<Schema.FieldSetMember>();
        if(Schema.SObjectType.gFRS_Third_Party__c.fieldSets.getmap().containsKey(fieldSetName)){
            mandtryFields = Schema.SObjectType.gFRS_Third_Party__c.fieldSets.getmap().get(fieldSetName).getFields();            
        }else{
            return False;
        }
        for(gFRS_Third_Party__c thirdParty : thirdPartyList){
            String query = 'SELECT ';
            for(Schema.FieldSetMember f : mandtryFields) {
                query += f.getFieldPath() + ', ';
            }
            query += 'Id FROM gFRS_Third_Party__c where id = \'' + thirdParty.Id + '\'';
            gFRS_Third_Party__c thirdParty2 = Database.query(query);
            for(Schema.FieldSetMember f : mandtryFields){
                if(thirdParty2.get(f.getFieldPath()) == null){
                    //system.assertequals('gFRS_Third_Party__c', f.getFieldPath());
                    return True;
                }
            } 
        }
        return false;
     }
/*#######################################################################################################*/
    public class CustomException extends Exception {
    }
}