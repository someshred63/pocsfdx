public class CFAR_Utils{
//        public static List<SelectOption> getSelectOptionsFromSobj(List<Sobject> sObjects, String valueFieldName, String LabelFieldName, Set<ID> excludeIds) {

    //public static final String MSL_PERMISSION_SET = 'CFAR_MSL';
    public static final String MSL_PERMISSION_SET = 'CFAR_MSL%';
    public static final String GENERAL_INDICATION_OTHER_OPTION_ID;
    public static final String GENERAL_INDICATION_OTHER_MALIGNANCIES_OPTION_ID;
    public static final String GENERAL_INDICATION_HEAD_AND_NECK_OPTION_ID;
    public static final String SPECIFIC_INDICATION_OTHER_OPTION_ID;
    public static final String BIOONCOLOGY_TA_ID;
    public static final Set<String> terminalStatuses = new Set<String>{ Label.CFAR_GSTARS_TRIAL_STATUS_PREMATURE_TERMINATION, Label.CFAR_GSTARS_TRIAL_STATUS_CANCELLED, Label.CFAR_GSTARS_TRIAL_STATUS_CONCLUDED, Label.CFAR_GSTARS_TRIAL_STATUS_ADMIN_FIX};
    public static final Set<String> terminalStatusesWithoutAdminFix = new Set<String>{ Label.CFAR_GSTARS_TRIAL_STATUS_PREMATURE_TERMINATION, Label.CFAR_GSTARS_TRIAL_STATUS_CANCELLED, Label.CFAR_GSTARS_TRIAL_STATUS_CONCLUDED};
    public static final Set<String> disabledMilestoneActivities = new Set<String>{'TRAC Protocol Approval'};

    static {
        List<CFAR_General_Indication_gne__c> GIIds = [SELECT Id, Name FROM CFAR_General_Indication_gne__c WHERE Name = 'Other'
        OR Name = 'Head & Neck' OR Name = 'Other Malignancies' order by Active_gne__c desc];

        for(CFAR_General_Indication_gne__c GIId : GIIds ) {
            if(GIId.Name == 'Other' && GENERAL_INDICATION_OTHER_OPTION_ID == null)
                GENERAL_INDICATION_OTHER_OPTION_ID = GIId.Id;
            else if(GIId.Name == 'Other Malignancies' && GENERAL_INDICATION_OTHER_MALIGNANCIES_OPTION_ID == null)
                GENERAL_INDICATION_OTHER_MALIGNANCIES_OPTION_ID = GIId.Id;
            else if(GIId.Name == 'Head & Neck' && GENERAL_INDICATION_HEAD_AND_NECK_OPTION_ID == null)
                GENERAL_INDICATION_HEAD_AND_NECK_OPTION_ID = GIId.Id;
        }
        List<CFAR_Specific_Indication_gne__c> SIotherIds = [SELECT Id FROM CFAR_Specific_Indication_gne__c WHERE Name = 'Other' order by Active_gne__c desc];
        if(SIotherIds.size()>0)
            SPECIFIC_INDICATION_OTHER_OPTION_ID = SIotherIds[0].id;
        BIOONCOLOGY_TA_ID = String.valueOf(getBioOncologyTAId());
    }

    public static Integer howManyProcessedCTTrigger = 0;

    public static void increaseHowManyProcessedCTTrigger() {
        howManyProcessedCTTrigger++;
    }

    private static boolean alreadyProcessed = false;

    public static boolean hasAlreadyProcessed() {
        return alreadyProcessed;
    }

    public static void setAlreadyProcessed() {
        alreadyProcessed = true;
    }

    private static boolean alreadyProcessedTrialForJunctions = false;

    public static boolean hasAlreadyProcessedTrialForJunctions() {
        return alreadyProcessedTrialForJunctions;
    }

    public static void setAlreadyProcessedTrialForJunctions() {
        alreadyProcessedTrialForJunctions = true;
    }

    private static boolean alreadyProcessedContact = false;

    public static boolean hasAlreadyProcessedContact() {
        return alreadyProcessedContact;
    }

    private static Id actualTrialId;

    public static Id getActualTrialId() {
        return actualTrialId;
    }

    public static void setActualTrialId(Id trialId) {
        if(trialId != null) {
            actualTrialId = String.valueOf(trialId);
            system.debug('TEST LOL'+ actualTrialId);
        }
    }

    public static void createMilestoneActivities(Map<ID,CFAR_Trial_gne__c> trials) {
        List<CFAR_Milestone_Activity_gne__c> newTrialActivities = new List<CFAR_Milestone_Activity_gne__c>();
        for (CFAR_Trial_gne__c trial : trials.values()){
            for (Schema.PicklistEntry pEntry : CFAR_DAO.milestoneActivityTypes){
                newTrialActivities.add(new CFAR_Milestone_Activity_gne__c(CFAR_Trial_ref_gne__c = trial.id, name = pEntry.getLabel(), sfdc_Type_gne__c = pEntry.getLabel() ) );
            }
        }
        insert newTrialActivities;
    }

    public static void createRegulatoryTrackingActivities(Map<ID, CFAR_Trial_gne__c> trials) {
    List<CFAR_Regulatory_Document_Tracking_gne__c> newTrialTrackingActivities = new List<CFAR_Regulatory_Document_Tracking_gne__c>();

    List<CFAR_Regulatory_Document_Tracking_gne__c> existingTrialTrackingActivities = [
        SELECT Id, CFAR_Trial_gne__c, frm_Regulatory_Tracking_Activity_gne__c 
        FROM CFAR_Regulatory_Document_Tracking_gne__c 
        WHERE CFAR_Trial_gne__c IN :trials.values()
    ];

    Map<String, Id> trialToRdtsMap = new Map<String, Id>();
    for (CFAR_Regulatory_Document_Tracking_gne__c rdt : existingTrialTrackingActivities) {
        trialToRdtsMap.put(rdt.frm_Regulatory_Tracking_Activity_gne__c, rdt.CFAR_Trial_gne__c);
    }

    Set<String> initialTrackingActivitiesSet = new Set<String>{
        'Study Introduction Packet Sent',
        'Protocol Approval Letter Sent',
        'CV (Curriculum Vitae)',
        'ML (Medical License)',
        'IB Signature Page',
        'clinicaltrials.gov',
        'CTV Confirmation Email',
        'CTV Safety Letter signed',
        'Study Activation Letter',
        'Final Enrollment Log',
        'Final Drug Accountability Log',
        'Final CTV Confirmation',
        'Study Closure Letter Sent',
        'Study Closure Letter PI signed & returned'
    };

    Set<String> IRBActivitiesSet = new Set<String>{
        'IRB Approval Letter for Original Protocol',
        'IRB Approved Protocol',
        'IRB Closure Letter Received'
    };

    Set<String> INDActivitiesSet = new Set<String>{
        'Cross Reference Letter',
        '1571',
        'FDA response to IND Submission (copy)',
        'FDA Notification of Closure'
    };

    Set<String> FSRActivitiesSet = new Set<String>{
        'Final Study Report Received'
    };

    Set<String> CapAssessActivitiesSet = new Set<String>{
        'Capability Assessment Form Completed'
    };

    Map<String, Id> activitiesIdsMap = new Map<String, Id>();
    for (CFAR_Tracking_Activity_gne__c trackAct : [
        SELECT Name
        FROM CFAR_Tracking_Activity_gne__c
        WHERE Active_gne__c = true
    ]) {
        String trackActName = trackAct.Name;
        if (initialTrackingActivitiesSet.contains(trackActName) ||
                IRBActivitiesSet.contains(trackActName) ||
                INDActivitiesSet.contains(trackActName) ||
                FSRActivitiesSet.contains(trackActName) ||
                CapAssessActivitiesSet.contains(trackActName)) {
            activitiesIdsMap.put(trackActName, trackAct.Id);
        }
    }

    List<CFAR_Team_Member_gne__c> teamMembers = [
        SELECT CFAR_Trial_ref_gne__c, Id
        FROM CFAR_Team_Member_gne__c
        WHERE CFAR_Trial_ref_gne__c IN :trials.values()
            AND Function_Role_gne__c = 'PI = Primary (or Principal) Investigator'
    ];

    Map<Id, Id> teamMembersToTrialIdsMap = new Map<Id, Id>();
    for (CFAR_Team_Member_gne__c tm : teamMembers) {
        teamMembersToTrialIdsMap.put(tm.CFAR_Trial_ref_gne__c, tm.Id);
    }

    for (CFAR_Trial_gne__c trial : trials.values()) {
        if (trial.frm_Trial_Status_ref_gne__c != 'Concluded') {
            for (String initialTrackingActivity : initialTrackingActivitiesSet) {
                if (existingTrialTrackingActivities.isEmpty() &&
                        activitiesIdsMap.containsKey(initialTrackingActivity)) {
                    newTrialTrackingActivities.add(new CFAR_Regulatory_Document_Tracking_gne__c(
                        CFAR_Trial_gne__c = trial.Id,
                        Regulatory_Tracking_Activity_gne__c = activitiesIdsMap.get(initialTrackingActivity),
                        Reg_Doc_Investigator_gne__c = teamMembersToTrialIdsMap.get(trial.Id)
                    ));
                }
            }
            for (String indTrackingActivity : INDActivitiesSet) {
                if (trial.IND_Required_gne__c == 'YES' &&
                        !trialToRdtsMap.containsKey(indTrackingActivity) &&
                        activitiesIdsMap.containsKey(indTrackingActivity)) {
                    newTrialTrackingActivities.add(new CFAR_Regulatory_Document_Tracking_gne__c(
                        CFAR_Trial_gne__c = trial.Id,
                        Regulatory_Tracking_Activity_gne__c = activitiesIdsMap.get(indTrackingActivity),
                        Reg_Doc_Investigator_gne__c = teamMembersToTrialIdsMap.get(trial.Id)
                    ));
                }
            }
            if (trial.IRB_Required_gne__c == 'YES' || (trial.Subject_Type__c == 'Human' && trialToRdtsMap.isEmpty())) {
                for (String irbTrackingActivity : IRBActivitiesSet) {
                    if (!trialToRdtsMap.containsKey(irbTrackingActivity) &&
                            activitiesIdsMap.containsKey(irbTrackingActivity)) {
                        newTrialTrackingActivities.add(new CFAR_Regulatory_Document_Tracking_gne__c(
                            CFAR_Trial_gne__c = trial.Id,
                            Regulatory_Tracking_Activity_gne__c = activitiesIdsMap.get(irbTrackingActivity),
                            Reg_Doc_Investigator_gne__c = teamMembersToTrialIdsMap.get(trial.Id)
                        ));
                    }
                }
            }
            if (trial.FSR_Required_gne__c == 'YES' && trialToRdtsMap.isEmpty()) {
                for (String fsrTrackingActivity : FSRActivitiesSet) {
                    if (!trialToRdtsMap.containsKey(fsrTrackingActivity) &&
                            activitiesIdsMap.containsKey(fsrTrackingActivity)) {
                        newTrialTrackingActivities.add(new CFAR_Regulatory_Document_Tracking_gne__c(
                            CFAR_Trial_gne__c = trial.Id,
                            Regulatory_Tracking_Activity_gne__c = activitiesIdsMap.get(fsrTrackingActivity),
                            Reg_Doc_Investigator_gne__c = teamMembersToTrialIdsMap.get(trial.Id)
                        ));
                    }
                }
            }
            for (String capAssessTrackingActivity : CapAssessActivitiesSet) {
                if (trial.Capability_Assessment_Required__c == 'YES' &&
                        !trialToRdtsMap.containsKey(capAssessTrackingActivity) &&
                        activitiesIdsMap.containsKey(capAssessTrackingActivity)) {
                    newTrialTrackingActivities.add(new CFAR_Regulatory_Document_Tracking_gne__c(
                        CFAR_Trial_gne__c = trial.Id,
                        Regulatory_Tracking_Activity_gne__c = activitiesIdsMap.get(capAssessTrackingActivity),
                        Reg_Doc_Investigator_gne__c = teamMembersToTrialIdsMap.get(trial.Id)
                    ));
                }
            }
        }
    }

    insert newTrialTrackingActivities;
}

    public static void updateRdts(Map<ID,CFAR_Team_Member_gne__c> teamMember){
        Map<Id,Id> teamMemberTrialMap = new Map<Id,Id>();
        for(CFAR_Team_Member_gne__c tm : teamMember.values()){
            if(tm.Function_Role_gne__c == 'PI = Primary (or Principal) Investigator'){
                teamMemberTrialMap.put(tm.CFAR_Trial_ref_gne__c, tm.Id);
            }
        }
        if(!teamMemberTrialMap.isEmpty()){
            List<CFAR_Regulatory_Document_Tracking_gne__c> existingTrialTrackingActivitiesNoTM = [SELECT Id, CFAR_Trial_gne__c, Reg_Doc_Investigator_gne__c FROM CFAR_Regulatory_Document_Tracking_gne__c WHERE CFAR_Trial_gne__c IN :teamMemberTrialMap.keySet() AND Reg_Doc_Investigator_gne__c = null];
            for(CFAR_Regulatory_Document_Tracking_gne__c rdt : existingTrialTrackingActivitiesNoTM){
                rdt.Reg_Doc_Investigator_gne__c = teamMemberTrialMap.get(rdt.CFAR_Trial_gne__c);
            }
            update existingTrialTrackingActivitiesNoTM;
        }
    }

    public static Boolean hasCFARPermissionSet() {
        List<PermissionSet> CFARPermissionSets = [select Id from PermissionSet where Name like :MSL_PERMISSION_SET];
        List<Id> permissionSetCFARIds = new List<Id>();
        for (PermissionSet ps : CFARPermissionSets) {
            permissionSetCFARIds.add(ps.Id);
        }
        return Integer.valueOf([SELECT count(Id) counter FROM PermissionSetAssignment
        WHERE AssigneeId = :UserInfo.getUserId() and PermissionSetId IN :permissionSetCFARIds][0].get('counter')) > 0;

    }

    public static User currentUser{
        get{
            if(currentUser==null) {
                List<Id> userIds = new List<Id>{UserInfo.getUserId()};
                currentUser= (User)getUserById(userIds)[0];
            }
            return currentUser;
        }
        private set;
    }

    public static List<User> getUserById(List<Id>userIds){
        return [select id,profile.name from user where id in : userIds];
    }


    public static Boolean isCurrentUserAdmin() {
        String profileName = currentUser.Profile.Name;
        return (profileName == 'GNE-CFAR-Admin-New')
                || (profileName == 'GNE-CFAR-IT-Admin-New')
                || (profileName == 'System Administrator')
                || (profileName == 'GNE-MA-Support');
    }

    public static List<SelectOption> getSelectOptionsFromSobj(Sobject[] sObjects, String valueFieldName, String LabelFieldName) {
        List<SelectOption> options = new List<SelectOption>();
        for (sObject dbObj: sObjects){
            try{
                options.add(new SelectOption((String)dbObj.get(valueFieldName), (String)dbObj.get(labelFieldName) ) );
            } catch(Exception ex){
                System.debug(ex.getMessage());
            }
        }
        return options;
    }

    public static List<SelectOption> getSelectOptionsFromPicklistValues(List<Schema.PicklistEntry> inputPicklistEntries, Boolean addNoneValue) {
        List<SelectOption> resultSelectOptions = new List<SelectOption>();
        if (addNoneValue) {
            resultSelectOptions.add(new SelectOption('', '--None--'));
        }
        for (Schema.PicklistEntry pickVal : inputPicklistEntries) {
            resultSelectOptions.add(new SelectOption(pickval.getValue(), pickval.getLabel()));
        }
        return resultSelectOptions;
    }

    public static SelectOption[] getContactSelectOptions(CFAR_SearchParameters searchParameters){
        List<CFAR_Contact_gne__C> contacts = CFAR_DAO.getContactsForSelectOptions(searchParameters);
        return CFAR_Utils.getSelectOptionsFromSobj(contacts, 'id', 'Search_Name__c');
    }

    public static SelectOption[] getWBSCodeSelectoptions(CFAR_SearchParameters searchParameters){
        List<CFAR_WBS_gne__c> wbs = CFAR_DAO.getWBSCodesForSelectOptions(searchParameters);
        return CFAR_Utils.getSelectOptionsFromSobj(wbs, 'id', 'GSR_WBS_gne__c');
    }

    public static SelectOption[] getStudyStatusSelectoptions(CFAR_SearchParameters searchParameters){
        return CFAR_Utils.getSelectOptionsFromSobj(CFAR_DAO.getStudyStatusesForSelectOptions(searchParameters), 'id', 'Name');
    }
    public static SelectOption[] getGNESupportSelectOptions(CFAR_SearchParameters searchParameters) {
        return CFAR_Utils.getSelectOptionsFromSobj(CFAR_DAO.getDollarAndDrugActive(), 'id', 'Name');
    }

    public static SelectOption[] getProductSelectOptions(CFAR_SearchParameters searchParameters){
        List<CFAR_Product_gne__c> products = CFAR_DAO.getProductsForSelectOptions(searchParameters);
        return CFAR_Utils.getSelectOptionsFromSobj(products, 'id', 'Generic_Name_gne__c');
    }    
    
    public static SelectOption[] getStudiedProductSelectOptions(CFAR_SearchParameters searchParameters){
        List<CFAR_Product_gne__c> products = CFAR_DAO.getStudiedProductsForSelectOptions(searchParameters);
        return CFAR_Utils.getSelectOptionsFromSobj(products, 'id', 'Generic_Name_gne__c');
    }

    public static SelectOption[] getInstitutions(CFAR_SearchParameters searchParameters){
        List<CFAR_Institution_gne__c> institutions = CFAR_DAO.getInstitutions(searchParameters);
        return CFAR_Utils.getSelectOptionsFromSobj(institutions, 'name', 'name');
    }

    public static SelectOption[] getParentOrganizations(CFAR_SearchParameters searchParameters){
        List<CFAR_Parent_Organization_gne__c> organizations = CFAR_DAO.getParentOrganizations(searchParameters);
        return CFAR_Utils.getSelectOptionsFromSobj(organizations, 'name', 'name');
    }

    public static SelectOption[] getThemeSelectOptions(CFAR_SearchParameters searchParameters){
        List<CFAR_Theme_gne__c> themes = CFAR_DAO.getThemesForSelectOptions(searchParameters);
        return CFAR_Utils.getSelectOptionsFromSobj(themes, 'id', 'name');
    }

    public static SelectOption[] getGeneralIndicationSelectOptions(CFAR_SearchParameters searchParameters){
        List<CFAR_General_Indication_gne__c> generalIndications = CFAR_DAO.getGeneralIndicationsForSelectOptions(searchParameters);
        return CFAR_Utils.getSelectOptionsFromSobj(generalIndications, 'id', 'name');
    }

    public static SelectOption[] getSpecificIndicationSelectOptions(CFAR_SearchParameters searchParameters){
        List<CFAR_Specific_Indication_gne__c> specificIndications = CFAR_DAO.getSpecificIndicationsForSelectOptions(searchParameters);
        return CFAR_Utils.getSelectOptionsFromSobj(specificIndications , 'id', 'name');
    }

    public static SelectOption[] getTrialSelectOptions(CFAR_SearchParameters searchParameters){
        List<CFAR_Trial_gne__c> trials = CFAR_DAO.getTrialsForSelectOptionsList(searchParameters);
        return CFAR_Utils.getSelectOptionsFromSobj(trials, 'id', 'name');
    }

    public static SelectOption[] getTherapeuticAreasSelectOptions(CFAR_SearchParameters searchParameters){
        List<CFAR_Therapeutic_Area_gne__c> therapeuticAreas = CFAR_DAO.getTherapeuticAreas(searchParameters);
        return CFAR_Utils.getSelectOptionsFromSobj(therapeuticAreas , 'id', 'name');
    }

    public static SelectOption[] getPartnershipSelectOptions(CFAR_SearchParameters searchParameters){
        List<CFAR_Partnership_gne__c > partnerships = CFAR_DAO.getPartnerships(searchParameters);
        return CFAR_Utils.getSelectOptionsFromSobj(partnerships, 'id', 'name');
    }

    public static List<SelectOption> getCFARPicklistSelectOptions(Id recordtypeId) {
        return CFAR_Utils.getSelectOptionsFromSobj(CFAR_DAO.getCFARPicklistValues(recordtypeId), 'Id', 'Name');
    }

    public static SelectOption[] getWBSSelectOptions(CFAR_SearchParameters searchParameters){
        List<CFAR_WBS_gne__c> wbses = CFAR_DAO.getWBSes(searchParameters);
        List<SelectOption> options = new List<SelectOption>();
        Boolean hasRequested = false;
        options.add(new SelectOption('', 'Requested'));
        for (CFAR_WBS_gne__c dbObj: wbses){
            if(dbObj.GSR_WBS_gne__c != null){
                if ((String)dbObj.get('GSR_WBS_gne__c') != 'Requested') {
                    options.add(new SelectOption((String)dbObj.get('id'), (String)dbObj.get('GSR_WBS_gne__c') ) );
                }
                else {
                    options[0].setValue((String)dbObj.get('id'));
                    hasRequested = true;
                }
            }
        }
        if (!hasRequested) {
            options.remove(0);
        }
        return options;
    }

    public static SelectOption[] getPaymentScheduleStatusSelectOptions(CFAR_SearchParameters searchParameters){
        List<CFAR_Payment_Schedule_Status_gne__c> statuses = CFAR_DAO.getPaymentScheduleStatuses(searchParameters);
        return CFAR_Utils.getSelectOptionsFromSobj(statuses , 'id', 'name');
    }

    public static void logInfo(String msg){
        System.debug(LoggingLevel.INFO, '###INFO_MSG:' + msg);
    }

    public static void logError(String msg){
        System.debug(LoggingLevel.ERROR,'###ERROR_MSG:'+ msg);
    }

    public static Set<String> fetchSet(List<sObject> sObjectList,String fieldName){
        Set<String> stringList = new Set<String>();
        for (sObject sObjectItem : sObjectList){
            stringList.add((String)sObjectItem.get(fieldName));
        }
        return stringList;
    }

    public static Set<Id> fetchIdSet(List<sObject> sObjectList, String idFieldName){
        Set<Id> stringList = new Set<Id>();
        for (sObject sObjectItem : sObjectList){
            stringList.add((Id)sObjectItem.get(idFieldName));
        }
        return stringList;
    }

    public static Map<String, List<sObject>> sObjectListToFieldToSobjectMap(List<sObject> sObjectList, String fieldName) {
        Map<String, List<sObject>> fieldToSobjects = new Map<String, List<sObject>>();
    
        for (sObject sObjectItem : sObjectList) {
            Object fieldValue = sObjectItem.get(fieldName);
            String fieldStringValue = convertFieldValueToString(fieldValue);
    
            if (fieldToSobjects.get(fieldStringValue) == null) {
                fieldToSobjects.put(fieldStringValue, new List<sObject>());
            }
    
            fieldToSobjects.get(fieldStringValue).add(sObjectItem);
        }
    
        return fieldToSobjects;
    }
    
    private static String convertFieldValueToString(Object fieldValue) {
        if (fieldValue instanceof Decimal) {
            return ((Decimal) fieldValue).toPlainString();
        } else {
            return (String) fieldValue;
        }
    }

    public static CFAR_Team_Member_gne__c createPITeamMemberNoSave(CFAR_Trial_gne__c trial, Id addrId, Id addrIdType, Id gneSupportId) {
        CFAR_Team_Member_gne__c trialMember = new CFAR_Team_Member_gne__c(CFAR_Trial_ref_gne__c = trial.Id, Active_On_gne__c = trial.Received_Date_gne__c,
                contact_address_ref_gne__c = addrId, Address_Type_ref_gne__c = addrIdType, Dollar_and_Drug_ref_gne__c = gneSupportId);
        return trialMember;
    }
    

    public static void createOrUpdateTeamMembers(final Map<Id, CFAR_Trial_gne__c> newMap, final Map<Id, CFAR_Trial_gne__c> oldMap) {
        List<CFAR_Team_Member_gne__c> trialMembers = new List<CFAR_Team_Member_gne__c>();
        if (oldMap == null) {

            Set<Id> contactIds = new Set<Id>();
            for (Id trialId : newMap.keySet()) {
                CFAR_Trial_gne__c c = newMap.get(trialId);
                if(String.isNotBlank(c.Genentech_Primary_Contact_ref_gne__c)){
                    contactIds.add(c.Genentech_Primary_Contact_ref_gne__c);
                }
                if(String.isNotBlank(c.MSL_ref_gne__c)){
                    contactIds.add(c.MSL_ref_gne__c);
                }
                if(String.isNotBlank(c.SRT_Chair_ref_gne__c)) {
                    contactIds.add(c.SRT_Chair_ref_gne__c);
                }
            }

            if(contactIds.isEmpty()){
                return;
            }

            Map<Id, CFAR_Contact_gne__c> contactMap = new Map<Id, CFAR_Contact_gne__c>(
            [SELECT (SELECT Id, Contact_Address_ref_gne__r.Address_Type_ref_gne__c FROM gStars_Contact_Join_Addresses__r WHERE active_gne__c = true ORDER BY CreatedDate) FROM CFAR_Contact_gne__c WHERE id IN :contactIds]
            );

            for (Id trialId : newMap.keySet()) {
                CFAR_Trial_gne__c c = newMap.get(trialId);

                try {
                    CFAR_Contact_gne__c primaryContactJoinAddress = contactMap.get(c.Genentech_Primary_Contact_ref_gne__c);
                    String primaryContactId = primaryContactJoinAddress.gStars_Contact_Join_Addresses__r[0].Id;
                    String primaryContactAddressType = primaryContactJoinAddress.gStars_Contact_Join_Addresses__r[0].Contact_Address_ref_gne__r.Address_Type_ref_gne__c;
                    trialMembers.add(new CFAR_Team_Member_gne__c(CFAR_Trial_ref_gne__c = trialId, Active_On_gne__c = c.Received_Date_gne__c, Address_Type_ref_gne__c = primaryContactAddressType, Contact_address_ref_gne__c = primaryContactId, Is_Trial_Primary_Contact_gne__c = true));
                } catch (Exception e) {
                    System.debug(e.getMessage());
                }

                try {
                    CFAR_Contact_gne__c mslJoinAddress = contactMap.get(c.MSL_ref_gne__c);
                    String mslId = mslJoinAddress.gStars_Contact_Join_Addresses__r[0].Id;
                    String mslAddressType = mslJoinAddress.gStars_Contact_Join_Addresses__r[0].Contact_Address_ref_gne__r.Address_Type_ref_gne__c;
                    trialMembers.add(new CFAR_Team_Member_gne__c(CFAR_Trial_ref_gne__c = trialId, Active_On_gne__c = c.Received_Date_gne__c, Contact_address_ref_gne__c = mslId, Address_Type_ref_gne__c = mslAddressType, Is_Trial_MSL_gne__c = true));
                } catch (Exception e) {
                    System.debug(e.getMessage());
                }
                try {
                    CFAR_Contact_gne__c srtAddress = contactMap.get(c.SRT_Chair_ref_gne__c);
                    String srtId = srtAddress.gStars_Contact_Join_Addresses__r[0].Id;
                    String srtAddressType = srtAddress.gStars_Contact_Join_Addresses__r[0].Contact_Address_ref_gne__r.Address_Type_ref_gne__c;
                    trialMembers.add(new CFAR_Team_Member_gne__c(CFAR_Trial_ref_gne__c = trialId, Active_On_gne__c = c.Received_Date_gne__c, Contact_address_ref_gne__c = srtId, Address_Type_ref_gne__c = srtAddressType));
                } catch (Exception e) {
                    System.debug(e.getMessage());
                }
            }

            CFAR_ConfigUtil.setDisabled('Disabled_Triggers_gne__c', new List<String>{'CFAR_TeamMemberTrigger'});
            insert trialMembers;
            CFAR_ConfigUtil.setDisabled('Disabled_Triggers_gne__c', new List<String>{});
            
        }
    }

    public static Map<String, String> getUserRoleMapping() {
        Map<String, String> availableRolesMap = new Map<String, String>();
        List<CFAR_Roles_To_Users_Mapping_gne__c> rolesFromCustomSetting = CFAR_Roles_To_Users_Mapping_gne__c.getAll().values();
        for (CFAR_Roles_To_Users_Mapping_gne__c role : rolesFromCustomSetting) {
            availableRolesMap.put(role.Drop_down_value_gne__c, role.Role_Function_gne__c);
        }
        return availableRolesMap;
    }

    //CAUTION! Because of some exception needed for Jocelyn Martinez, it's allowed to add Admins as Primary Contacts!
    //No - remark above is not actual!
    public static List<String> getAvailableRolesForPrimaryContact() {
        return getRolesByFunction('Primary Contact');
    }
    
    public static List<String> getAvailableRolesForSRTChair() {
        return getRolesByExactMatch('SRT = Study Review Team Chair');
    }
    
    public static List<String> getAvailableRolesForInvestigator() {
        return getRolesByFunction('Investigator');
    }
    
    public static List<String> getAvailableRolesForMSL() {
        return getRolesByFunction('Medical Science Liason');
    }
    
    private static List<String> getRolesByFunction(String function) {
        List<String> availableRoles = new List<String>();
        Map<String, String> allRolesMap = getUserRoleMapping();
        for (String role : allRolesMap.keySet()) {
            String roleFunction = allRolesMap.get(role);
            if (roleFunction == function) {
                availableRoles.add(role);
            }
        }
        return availableRoles;
    }
    
    private static List<String> getRolesByExactMatch(String roleToMatch) {
        List<String> availableRoles = new List<String>();
        Map<String, String> allRolesMap = getUserRoleMapping();
        for (String role : allRolesMap.keySet()) {
            if (role == roleToMatch) {
                availableRoles.add(role);
            }
        }
        return availableRoles;
    }

    public static Map<Id, String> getContractTypeMap() {
        Map<Id, String> m = new Map<Id, String>();
        List<CFAR_Budget_Contract_Type_gne__c> l = [select Id,Name from CFAR_Budget_Contract_Type_gne__c where Active_gne__c = true];
        for(CFAR_Budget_Contract_Type_gne__c t : l) {
            m.put(t.Id, t.Name);
        }
        return m;
    }

    public static String customEscape(String s) {
        if(String.isBlank(s)){
            return '';
        }
        return s.replaceAll('<', '&lt;').replaceAll('>', '&gt;');
    }

    public static List<id> convertIdSet2IdList(Set<id> s){
        List<id> ret = new List<id>();
        for(Id identifier : s){
            ret.add( (String)identifier );
        }
        return ret;
    }

    public static Boolean setRDCCriteria(CFAR_Trial_gne__c trial, List<CFAR_Regulatory_Document_Tracking_gne__c> rdtList){
        Boolean rdcDateCriteria;
        Boolean cVActivityExist = false;
        Boolean mLActivityExist = false;
        Boolean iRBActivityExist = false;
        Boolean originalContractExist = CFAR_Budget_Utils.hasOrginalContractTracking(trial.Id) && trial.Original_Contract_Execution_Date_gne__c != null;
        System.debug('DBG originalContractExist: ' + originalContractExist);
        if(rdtList == null){
            rdtList = [SELECT Activity_gne__c, Id, Regulatory_Tracking_Activity_gne__r.Name, Date_Received_gne__c FROM CFAR_Regulatory_Document_Tracking_gne__c WHERE Active_gne__c = true AND CFAR_Trial_gne__c =: trial.Id and Regulatory_Tracking_Activity_gne__r.Name in ('CV', 'Medical License', 'IRB Approval Letter for Original Protocol') and Date_Received_gne__c != null];
        }
        for(CFAR_Regulatory_Document_Tracking_gne__c rdt : rdtList){
            if (rdt.Date_Received_gne__c != null) {
                if(rdt.Regulatory_Tracking_Activity_gne__r.Name == 'CV'){
                    cVActivityExist = true;
                }
                if(rdt.Regulatory_Tracking_Activity_gne__r.Name == 'Medical License'){
                    mLActivityExist = true;
                }
                if(rdt.Regulatory_Tracking_Activity_gne__r.Name == 'IRB Approval Letter for Original Protocol'){
                    iRBActivityExist = true;
                }
            }
        }
        rdcDateCriteria = originalContractExist && cVActivityExist && mLActivityExist && (iRBActivityExist || trial.IRB_Required_gne__c =='NO') && (trial.IND_gne__c != null || trial.IND_Required_gne__c == 'NO');
        System.debug('DBG rdcDateCriteria: ' + rdcDateCriteria);
        if(rdcDateCriteria && trial.Regulatory_Document_Complete_Date_gne__c == null){
            trial.Regulatory_Document_Complete_Date_gne__c = Date.today();
            setAlreadyProcessed();
            CFAR_SecurityUtils.updateRecord(trial);
        }
        return rdcDateCriteria;
    }

    public static Map<Id, String> hasInActiveRole(Set<String> roleNamesSet, Map<String, String> roleMapping, List<CFAR_Team_Member_gne__c> teamMembers) {
        Map<Id, String> mapRole = new Map<Id, String>();
        set<Id> processedOk = new set<Id>();
        for(CFAR_Team_Member_gne__c t : teamMembers) {

            system.debug('t.frm_Function_Role_gne__c= '+t.frm_Function_Role_gne__c);
            system.debug('roleNamesSet.contains(roleMapping.get(t.frm_Function_Role_gne__c))= '+roleNamesSet.contains(roleMapping.get(t.frm_Function_Role_gne__c)));
            system.debug('t.frm_Is_Inactive_gne__c= '+t.frm_Is_Inactive_gne__c);
            system.debug('processedOk.isEmpty()= '+processedOk.isEmpty());
            system.debug('!processedOk.contains(t.CFAR_Trial_ref_gne__c))= '+!processedOk.contains(t.CFAR_Trial_ref_gne__c));

            if(roleNamesSet.contains(roleMapping.get(t.frm_Function_Role_gne__c)) && t.frm_Is_Inactive_gne__c
                    && (processedOk.isEmpty() || !processedOk.contains(t.CFAR_Trial_ref_gne__c))) {
                mapRole.put(t.CFAR_Trial_ref_gne__c, t.frm_Name_gne__c);
            }
            if(roleNamesSet.contains(roleMapping.get(t.frm_Function_Role_gne__c)) && !t.frm_Is_Inactive_gne__c) {
                if(mapRole.containsKey(t.CFAR_Trial_ref_gne__c)) {
                    mapRole.remove(t.CFAR_Trial_ref_gne__c);
                }
                processedOk.add(t.CFAR_Trial_ref_gne__c);

            }
        }
        return mapRole;
    }

    public static Map<Id,String> hasInactivePC(List<CFAR_Team_Member_gne__c> teamMembers) {
        Map<Id, String> mapRole = new Map<Id, String>();

        for(CFAR_Team_Member_gne__c tm : teamMembers) {
            if(tm.Is_Trial_Primary_Contact_gne__c == true && tm.frm_Is_Inactive_gne__c) {
                mapRole.put(tm.CFAR_Trial_ref_gne__c, tm.frm_Name_gne__c);
            }
        }
        return mapRole;
    }

    public static Map<Id,String> hasInactiveMSL(List<CFAR_Team_Member_gne__c> teamMembers) {
        Map<Id, String> mapRole = new Map<Id, String>();

        for(CFAR_Team_Member_gne__c tm : teamMembers) {
            if(tm.Is_Trial_MSL_gne__c == true && tm.frm_Is_Inactive_gne__c) {
                mapRole.put(tm.CFAR_Trial_ref_gne__c, tm.frm_Name_gne__c);
            }
        }
        return mapRole;
    }

    public static List<CFAR_Home_Controller.AlertWrapper> getContactAlerts(Set<Id> trialsWhereCurrentUserShouldSeeAlerts) {

        List<CFAR_Home_Controller.AlertWrapper> alertList = new List<CFAR_Home_Controller.AlertWrapper>();
        List<CFAR_Contact_gne__c> contacts = [select Id from CFAR_Contact_gne__c where Active_gne__c = false];
        List<CFAR_Trial_gne__c> trialsWithInactiveContact = [select Id, Name, frm_Investigator_ref_gne__c, Genentech_Primary_Contact_ref_gne__c, Genentech_Primary_Contact_ref_gne__r.Active_gne__c, Genentech_Primary_Contact_ref_gne__r.Search_Name__c,
                MSL_ref_gne__c, MSL_ref_gne__r.Active_gne__c, MSL_ref_gne__r.Search_Name__c, Investigator_ref_gne__c, Investigator_ref_gne__r.Active_gne__c, Investigator_ref_gne__r.Search_Name__c
        from CFAR_Trial_gne__c where Trial_Status_ref_gne__r.Name NOT IN :terminalStatuses and (Genentech_Primary_Contact_ref_gne__c in :contacts OR MSL_ref_gne__c in :contacts OR Investigator_ref_gne__c in :contacts ) and Id IN :trialsWhereCurrentUserShouldSeeAlerts];

        for(CFAR_Trial_gne__c t : trialsWithInactiveContact) {
            system.debug('t.Genentech_Primary_Contact_ref_gne__r.Active_gne__c ' + t.Genentech_Primary_Contact_ref_gne__r.Active_gne__c);
            system.debug('t.MSL_ref_gne__r.Active_gne__c ' + t.MSL_ref_gne__r.Active_gne__c);
            system.debug('t.Investigator_ref_gne__r.Active_gne__c ' + t.Investigator_ref_gne__r.Active_gne__c);
            if(!t.Genentech_Primary_Contact_ref_gne__r.Active_gne__c) {
                alertList.add(new CFAR_Home_Controller.AlertWrapper(String.format(Label.CFAR_CONTACT_INACTIVE, new String[]{t.Genentech_Primary_Contact_ref_gne__r.Search_Name__c}), t.frm_Investigator_ref_gne__c, t.Name, t.Id));
            }
            if(!t.MSL_ref_gne__r.Active_gne__c) {
                alertList.add(new CFAR_Home_Controller.AlertWrapper(String.format(Label.CFAR_CONTACT_INACTIVE, new String[]{t.MSL_ref_gne__r.Search_Name__c}), t.frm_Investigator_ref_gne__c, t.Name, t.Id));
            }
            if(!t.Investigator_ref_gne__r.Active_gne__c) {
                alertList.add(new CFAR_Home_Controller.AlertWrapper(String.format(Label.CFAR_CONTACT_INACTIVE, new String[]{t.Investigator_ref_gne__r.Search_Name__c}), t.frm_Investigator_ref_gne__c, t.Name, t.Id));
            }
        }
        system.debug('alertList: ' + alertList);

        return alertList;

    }

    public static List<ID> setToList(Set<ID> sourceSet){
        List<ID> outputList = new List<ID>();
        for (string setElt : sourceSet)
            outputList.add(setElt);
        return outputList;
    }

    public static set<Id> setToIdSet(Set<String> sourceSet){
        set<Id> outputList = new set<Id>();
        for (string setElt : sourceSet)
            outputList.add(setElt);
        return outputList;
    }

    public static List<SelectOption> getContactSearchListPart1(List<SelectOption> wholeContactsSearchList) {
        List<SelectOption> contactSearchList1 = new List<SelectOption>();
        if (wholeContactsSearchList != null && !wholeContactsSearchList.isEmpty()) {
            if (wholeContactsSearchList.size() >= 1000) {
                for (Integer i=0; i<1000; i++) {
                    contactSearchList1.add(wholeContactsSearchList[i]);
                }
            }
            else {
                for (Integer i=0; i<wholeContactsSearchList.size(); i++) {
                    contactSearchList1.add(wholeContactsSearchList[i]);
                }
            }
        }
        return contactSearchList1;
    }

    public static List<SelectOption> getContactSearchListPart2(List<SelectOption> wholeContactsSearchList) {
        List<SelectOption> contactSearchList2 = new List<SelectOption>();
        if (wholeContactsSearchList != null && !wholeContactsSearchList.isEmpty() && wholeContactsSearchList.size() > 1000) {
            if (wholeContactsSearchList.size() >= 2000) {
                for (Integer i=1000; i<2000; i++) {
                    contactSearchList2.add(wholeContactsSearchList[i]);
                }
            }
            else {
                for (Integer i=1000; i<wholeContactsSearchList.size(); i++) {
                    contactSearchList2.add(wholeContactsSearchList[i]);
                }
            }
        }
        return contactSearchList2;
    }

    public static List<SelectOption> getContactSearchListPart3(List<SelectOption> wholeContactsSearchList) {
        List<SelectOption> contactSearchList3 = new List<SelectOption>();
        if (wholeContactsSearchList != null && !wholeContactsSearchList.isEmpty() && wholeContactsSearchList.size() > 2000) {
            if (wholeContactsSearchList.size() >= 3000) {
                for (Integer i=2000; i<3000; i++) {
                    contactSearchList3.add(wholeContactsSearchList[i]);
                }
            }
            else {
                for (Integer i=2000; i<wholeContactsSearchList.size(); i++) {
                    contactSearchList3.add(wholeContactsSearchList[i]);
                }
            }
        }
        return contactSearchList3;
    }

    public static List<SelectOption> getContactSearchListPart4(List<SelectOption> wholeContactsSearchList) {
        List<SelectOption> contactSearchList4 = new List<SelectOption>();
        if (wholeContactsSearchList != null && !wholeContactsSearchList.isEmpty() && wholeContactsSearchList.size() > 3000) {
            if (wholeContactsSearchList.size() >= 4000) {
                for (Integer i=3000; i<4000; i++) {
                    contactSearchList4.add(wholeContactsSearchList[i]);
                }
            }
            else {
                for (Integer i=3000; i<wholeContactsSearchList.size(); i++) {
                    contactSearchList4.add(wholeContactsSearchList[i]);
                }
            }
        }
        return contactSearchList4;
    }

    public static List<SelectOption> getObjectSearchListPart1(List<SelectOption> wholeObjectsSearchList) {
        return getThousandSelectOptions(wholeObjectsSearchList, 1);
    }

    public static List<SelectOption> getObjectSearchListPart2(List<SelectOption> wholeObjectsSearchList) {
        return getThousandSelectOptions(wholeObjectsSearchList, 2);
    }

    public static List<SelectOption> getObjectSearchListPart3(List<SelectOption> wholeObjectsSearchList) {
        return getThousandSelectOptions(wholeObjectsSearchList, 3);
    }

    public static List<SelectOption> getObjectSearchListPart4(List<SelectOption> wholeObjectsSearchList) {
        return getThousandSelectOptions(wholeObjectsSearchList, 4);
    }

    public static List<SelectOption> getThousandSelectOptions(List<SelectOption> wholeObjectsSearchList, Integer listNo) {
        List<SelectOption> objectSearchList = new List<SelectOption>();
        if (wholeObjectsSearchList != null && wholeObjectsSearchList.size() > (listNo * 1000) - 1000) {
            Integer n;
            if (wholeObjectsSearchList.size() >= listNo * 1000)
                n = listNo * 1000;
            else
                    n = wholeObjectsSearchList.size();
            for (Integer i=((listNo * 1000) - 1000); i<n; i++) {
                objectSearchList.add(wholeObjectsSearchList[i]);
            }
        }
        return objectSearchList;
    }

    public static void handleOtherGNEAgentsChanged(Map<Id,CFAR_Trial_gne__c> oldTrialMap, Map<Id,CFAR_Trial_gne__c> newTrialMap) {
        if (oldTrialMap != null && newTrialMap != null && !oldTrialMap.isEmpty() && !newTrialMap.isEmpty()) {
            List<CFAR_Trial_gne__c> trialsWithOtherGNEAgentsChanged = new List<CFAR_Trial_gne__c>();
            for (Id trialId : newTrialMap.keySet()) {
                if (newTrialMap.get(trialId).Other_GNE_Agents_Multi_gne__c != oldTrialMap.get(trialId).Other_GNE_Agents_Multi_gne__c) {
                    trialsWithOtherGNEAgentsChanged.add(newTrialMap.get(trialId));
                }
            }
            if (trialsWithOtherGNEAgentsChanged.isEmpty()) {
                return;
            }
            List<CFAR_Trial_Other_GNE_Agent_gne__c> currentAgents = [select Other_GNE_Agent_ref_gne__c, CFAR_Trial_ref_gne__c from CFAR_Trial_Other_GNE_Agent_gne__c where CFAR_Trial_ref_gne__c IN :trialsWithOtherGNEAgentsChanged];
            Map<Id, Map<String,CFAR_Trial_Other_GNE_Agent_gne__c>> currentAgentsInTrialsMap = new Map<Id, Map<String,CFAR_Trial_Other_GNE_Agent_gne__c>>();
            for (CFAR_Trial_Other_GNE_Agent_gne__c trialOGA : currentAgents) {
                Map<String,CFAR_Trial_Other_GNE_Agent_gne__c> tmpOGAMap = currentAgentsInTrialsMap.get(trialOGA.CFAR_Trial_ref_gne__c);
                if (tmpOGAMap == null) {
                    currentAgentsInTrialsMap.put(trialOGA.CFAR_Trial_ref_gne__c, new Map<String,CFAR_Trial_Other_GNE_Agent_gne__c>{trialOGA.Other_GNE_Agent_ref_gne__c => trialOGA});
                }
                else {
                    tmpOGAMap.put(trialOGA.Other_GNE_Agent_ref_gne__c, trialOGA);
                }
            }
            List<CFAR_Trial_Other_GNE_Agent_gne__c> agentsToInsert = new List<CFAR_Trial_Other_GNE_Agent_gne__c>();
            List<CFAR_Trial_Other_GNE_Agent_gne__c> agentsToDel = new List<CFAR_Trial_Other_GNE_Agent_gne__c>();
            for (CFAR_Trial_gne__c trial : trialsWithOtherGNEAgentsChanged) {
                List<String> OGAsFromMulti = new List<String>();
                if (String.isNotBlank(trial.Other_GNE_Agents_Multi_gne__c)) {
                    OGAsFromMulti = trial.Other_GNE_Agents_Multi_gne__c.split(';');
                }
                Set<String> OGAsFromMultiSet = new Set<String>(OGAsFromMulti);
                List<String> OGAsFromMultiOld = new List<String>();
                Set<String> OGasNA = new Set<String>();
                System.debug('======1 ' + (newTrialMap.get(trial.Id).Other_GNE_Agents_Multi_gne__c != null));
                //System.debug('======2 ' + (newTrialMap.get(trial.Id).Other_GNE_Agents_Multi_gne__c.contains('N/A')));
                System.debug('======3 ' + newTrialMap.get(trial.Id).Id);
                if (newTrialMap.get(trial.Id).Other_GNE_Agents_Multi_gne__c != null && newTrialMap.get(trial.Id).Other_GNE_Agents_Multi_gne__c.contains('N/A')) {
                    System.debug('======4 ' + newTrialMap.get(trial.Id).Id);
                    OGasNA.add(newTrialMap.get(trial.Id).Id);
                }
                if (String.isNotBlank(oldTrialMap.get(trial.Id).Other_GNE_Agents_Multi_gne__c)) {
                    OGAsFromMultiOld = oldTrialMap.get(trial.Id).Other_GNE_Agents_Multi_gne__c.split(';');
                }
                Set<String> OGAsFromMultiOldSet = new Set<String>(OGAsFromMultiOld);
                for (String s : OGAsFromMultiSet) {
                    System.debug('======5 ' + !OGasNA.contains(s));
                    System.debug('======6 ' + s);
                    System.debug('======7 ' + (!OGAsFromMultiOldSet.contains(s)));
                    System.debug('======8 ' + OGAsFromMultiOldSet);
                    System.debug('======9 ' + OGasNA);
                    if (!OGAsFromMultiOldSet.contains(s) && !OGasNA.contains(trial.Id)) {
                        agentsToInsert.add(new CFAR_Trial_Other_GNE_Agent_gne__c(CFAR_Trial_ref_gne__c = trial.Id, Other_GNE_Agent_ref_gne__c = s));
                    }
                }
                for (String s : OGAsFromMultiOldSet) {
                    if (!OGAsFromMultiSet.contains(s) && currentAgentsInTrialsMap.get(trial.Id) != null && currentAgentsInTrialsMap.get(trial.Id).get(s) != null) {
                        agentsToDel.add(currentAgentsInTrialsMap.get(trial.Id).get(s));
                    }
                }
            }
            CFAR_SecurityUtils.deleteRecords(agentsToDel);
            insert agentsToInsert;
        }
    }

    public static void handleIMPShippedChanged(Map<Id,CFAR_Trial_gne__c> oldTrialMap, Map<Id,CFAR_Trial_gne__c> newTrialMap) {
        if (oldTrialMap != null && newTrialMap != null && !oldTrialMap.isEmpty() && !newTrialMap.isEmpty()) {
            List<CFAR_Trial_gne__c> trialsWithIMPShippedChanged = new List<CFAR_Trial_gne__c>();
            for (Id trialId : newTrialMap.keySet()) {
                if (newTrialMap.get(trialId).IMP_Shipped_Multi_gne__c != oldTrialMap.get(trialId).IMP_Shipped_Multi_gne__c) {
                    trialsWithIMPShippedChanged.add(newTrialMap.get(trialId));
                }
            }
            if (trialsWithIMPShippedChanged.isEmpty()) {
                return;
            }
            List<CFAR_Trial_IMP_Shipped__c> currentIMPShipped = [select IMP_Shipped_ref__c, CFAR_Trial_ref_gne__c from CFAR_Trial_IMP_Shipped__c where CFAR_Trial_ref_gne__c IN :trialsWithIMPShippedChanged];
            Map<Id, Map<String,CFAR_Trial_IMP_Shipped__c>> currentIMPShippedInTrialsMap = new Map<Id, Map<String,CFAR_Trial_IMP_Shipped__c>>();
            for (CFAR_Trial_IMP_Shipped__c trialIMPShipped : currentIMPShipped) {
                Map<String,CFAR_Trial_IMP_Shipped__c> tmpIMPShippedMap = currentIMPShippedInTrialsMap.get(trialIMPShipped.CFAR_Trial_ref_gne__c);
                if (tmpIMPShippedMap == null) {
                    currentIMPShippedInTrialsMap.put(trialIMPShipped.CFAR_Trial_ref_gne__c, new Map<String,CFAR_Trial_IMP_Shipped__c>{trialIMPShipped.IMP_Shipped_ref__c => trialIMPShipped});
                }
                else {
                    tmpIMPShippedMap.put(trialIMPShipped.IMP_Shipped_ref__c, trialIMPShipped);
                }
            }
            List<CFAR_Trial_IMP_Shipped__c> impShippedToInsert = new List<CFAR_Trial_IMP_Shipped__c>();
            List<CFAR_Trial_IMP_Shipped__c> impShippedToDel = new List<CFAR_Trial_IMP_Shipped__c>();
            for (CFAR_Trial_gne__c trial : trialsWithIMPShippedChanged) {
                List<String> impShippedFromMulti = new List<String>();
                if (String.isNotBlank(trial.IMP_Shipped_Multi_gne__c)) {
                    impShippedFromMulti = trial.IMP_Shipped_Multi_gne__c.split(';');
                }
                Set<String> impShippedFromMultiSet = new Set<String>(impShippedFromMulti);
                List<String> impShippedFromMultiOld = new List<String>();
                if (String.isNotBlank(oldTrialMap.get(trial.Id).IMP_Shipped_Multi_gne__c)) {
                    impShippedFromMultiOld = oldTrialMap.get(trial.Id).IMP_Shipped_Multi_gne__c.split(';');
                }
                Set<String> impShippedFromMultiOldSet = new Set<String>(impShippedFromMultiOld);
                for (String s : impShippedFromMultiSet) {
                    if (!impShippedFromMultiOldSet.contains(s)) {
                        impShippedToInsert.add(new CFAR_Trial_IMP_Shipped__c(CFAR_Trial_ref_gne__c = trial.Id, IMP_Shipped_ref__c = s));
                    }
                }
                for (String s : impShippedFromMultiOldSet) {
                    if (!impShippedFromMultiSet.contains(s) && currentIMPShippedInTrialsMap.get(trial.Id) != null && currentIMPShippedInTrialsMap.get(trial.Id).get(s) != null) {
                        impShippedToDel.add(currentIMPShippedInTrialsMap.get(trial.Id).get(s));
                    }
                }
            }
            CFAR_SecurityUtils.deleteRecords(impShippedToDel);
            insert impShippedToInsert;
        }
    }

    public static void setGeneralIndicationsField(CFAR_TrialWrapper tw) {
        String generalIndicationsField = null;
        if (tw.selectedGeneralIndications != null && !tW.selectedGeneralIndications.isEmpty()) {
            generalIndicationsField = '';
            for (String s : tW.selectedGeneralIndications) {
                generalIndicationsField += (s.substring(0, 15) + ';');
            }
            generalIndicationsField = generalIndicationsField.removeEnd(';');
        }
        //this version is also fine
        //CFAR_Trial_gne__c myTrial = (CFAR_Trial_gne__c)trialWrapper.innerObject;
        //myTrial.Other_GNE_Agents_Multi_gne__c = agentsField;
        tw.innerObject.put('General_Indication_Multi_gne__c', generalIndicationsField);
        //return tw;
    }

    public static void setSpecificIndicationsField(CFAR_TrialWrapper tw) {
        String specificIndicationsField = null;
        if (tw.selectedSpecificIndications != null && !tw.selectedSpecificIndications.isEmpty()) {
            specificIndicationsField = '';
            for (String s : tw.selectedSpecificIndications) {
                specificIndicationsField += (s.substring(0, 15) + ';');
            }
            specificIndicationsField = specificIndicationsField.removeEnd(';');
        }
        //this version is also fine
        //CFAR_Trial_gne__c myTrial = (CFAR_Trial_gne__c)trialWrapper.innerObject;
        //myTrial.Other_GNE_Agents_Multi_gne__c = agentsField;
        tw.innerObject.put('Specific_Indication_Multi_gne__c', specificIndicationsField);
        //return tw;
    }

    public static Id getBioOncologyTAId() {
        Id bioOncologyTAId;
        List<CFAR_Therapeutic_Area_gne__c> bioOncoTAList = [select Id from CFAR_Therapeutic_Area_gne__c where Name = 'BioOncology' order by Active_gne__c desc limit 1];
        if (!bioOncoTAList.isEmpty()) {
            bioOncologyTAId = bioOncoTAList.get(0).Id;
        }
        return bioOncologyTAId;
    }

    public static void handleGeneralIndicationsNew(Map<Id,CFAR_Trial_gne__c> newTrialMap) {
        if (newTrialMap != null && !newTrialMap.isEmpty()) {
            List<CFAR_Trial_gne__c> trialsWithGeneralIndications = new List<CFAR_Trial_gne__c>();
            for (Id trialId : newTrialMap.keySet()) {
                trialsWithGeneralIndications.add(newTrialMap.get(trialId));
            }
            if (trialsWithGeneralIndications.isEmpty()) {
                return;
            }
            List<CFAR_General_Indication_for_Trial_gne__c> indicationsToInsert = new List<CFAR_General_Indication_for_Trial_gne__c>();
            for (CFAR_Trial_gne__c trial : trialsWithGeneralIndications) {
                List<String> GIsFromMulti = new List<String>();
                if (String.isNotBlank(trial.General_Indication_Multi_gne__c)) {
                    GIsFromMulti =CFAR_Utils.convert15to18ID(trial.General_Indication_Multi_gne__c.split(';'));
                }
                Set<String> GIsFromMultiSet = new Set<String>(GIsFromMulti);
                for (String s : GIsFromMultiSet) {
                    IndicationsToInsert.add(new CFAR_General_Indication_for_Trial_gne__c(CFAR_Trial_ref_gne__c = trial.Id, CFAR_General_Indication_ref_gne__c = s));
                }

            }
            insert indicationsToInsert;
        }
    }

    public static void handleGeneralIndicationsChanged(Map<Id,CFAR_Trial_gne__c> oldTrialMap, Map<Id,CFAR_Trial_gne__c> newTrialMap) {
        if (oldTrialMap != null && newTrialMap != null && !oldTrialMap.isEmpty() && !newTrialMap.isEmpty()) {
            List<CFAR_Trial_gne__c> trialsWithGeneralIndicationsChanged = new List<CFAR_Trial_gne__c>();
            for (Id trialId : newTrialMap.keySet()) {
                if (newTrialMap.get(trialId).General_Indication_Multi_gne__c != oldTrialMap.get(trialId).General_Indication_Multi_gne__c) {
                    trialsWithGeneralIndicationsChanged.add(newTrialMap.get(trialId));
                }
            }
            if (trialsWithGeneralIndicationsChanged.isEmpty()) {
                return;
            }
            List<CFAR_General_Indication_for_Trial_gne__c> currentIndications = [select CFAR_General_Indication_ref_gne__c, CFAR_Trial_ref_gne__c from CFAR_General_Indication_for_Trial_gne__c where CFAR_Trial_ref_gne__c IN :trialsWithGeneralIndicationsChanged];
            Map<Id, Map<String,CFAR_General_Indication_for_Trial_gne__c>> currentIndicationsInTrialsMap = new Map<Id, Map<String,CFAR_General_Indication_for_Trial_gne__c>>();
            for (CFAR_General_Indication_for_Trial_gne__c trialGI : currentIndications) {
                Map<String,CFAR_General_Indication_for_Trial_gne__c> tmpGIMap = currentIndicationsInTrialsMap.get(trialGI.CFAR_Trial_ref_gne__c);
                if (tmpGIMap == null) {
                    currentIndicationsInTrialsMap.put(trialGI.CFAR_Trial_ref_gne__c, new Map<String,CFAR_General_Indication_for_Trial_gne__c>{trialGI.CFAR_General_Indication_ref_gne__c => trialGI});
                }
                else {
                    tmpGIMap.put(trialGI.CFAR_General_Indication_ref_gne__c, trialGI);
                }
            }
            List<CFAR_General_Indication_for_Trial_gne__c> indicationsToInsert = new List<CFAR_General_Indication_for_Trial_gne__c>();
            List<CFAR_General_Indication_for_Trial_gne__c> indicationsToDel = new List<CFAR_General_Indication_for_Trial_gne__c>();
            for (CFAR_Trial_gne__c trial : trialsWithGeneralIndicationsChanged) {
                List<String> GIsFromMulti = new List<String>();
                if (String.isNotBlank(trial.General_Indication_Multi_gne__c)) {
                    GIsFromMulti = CFAR_Utils.convert15to18ID(trial.General_Indication_Multi_gne__c.split(';'));
                }
                Set<String> GIsFromMultiSet = new Set<String>(GIsFromMulti);
                List<String> GIsFromMultiOld = new List<String>();
                if (String.isNotBlank(oldTrialMap.get(trial.Id).General_Indication_Multi_gne__c)) {
                    GIsFromMultiOld = CFAR_Utils.convert15to18ID(oldTrialMap.get(trial.Id).General_Indication_Multi_gne__c.split(';'));
                }
                Set<String> GIsFromMultiOldSet = new Set<String>(GIsFromMultiOld);
                for (String s : GIsFromMultiSet) {
                    if (!GIsFromMultiOldSet.contains(s)) {
                        IndicationsToInsert.add(new CFAR_General_Indication_for_Trial_gne__c(CFAR_Trial_ref_gne__c = trial.Id, CFAR_General_Indication_ref_gne__c = s));
                    }
                }
                for (String s : GIsFromMultiOldSet) {
                    if (!GIsFromMultiSet.contains(s) && currentIndicationsInTrialsMap.get(trial.Id) != null && currentIndicationsInTrialsMap.get(trial.Id).get(s) != null) {
                        indicationsToDel.add(currentIndicationsInTrialsMap.get(trial.Id).get(s));
                    }
                }
            }
            CFAR_SecurityUtils.deleteRecords(indicationsToDel);
            insert indicationsToInsert;
        }
    }

    public static void handleSpecificIndicationsNew(Map<Id,CFAR_Trial_gne__c> newTrialMap) {
        if (newTrialMap != null && !newTrialMap.isEmpty()) {
            List<CFAR_Trial_gne__c> trialsWithSpecificIndications = new List<CFAR_Trial_gne__c>();
            for (Id trialId : newTrialMap.keySet()) {
                trialsWithSpecificIndications.add(newTrialMap.get(trialId));
            }
            if (trialsWithSpecificIndications.isEmpty()) {
                return;
            }
            List<CFAR_Specific_Indication_for_Trial_gne__c> indicationsToInsert = new List<CFAR_Specific_Indication_for_Trial_gne__c>();
            for (CFAR_Trial_gne__c trial : trialsWithSpecificIndications) {
                List<String> SIsFromMulti = new List<String>();
                if (String.isNotBlank(trial.Specific_Indication_Multi_gne__c)) {
                    SIsFromMulti = CFAR_Utils.convert15to18ID(trial.Specific_Indication_Multi_gne__c.split(';'));
                }
                Set<String> SIsFromMultiSet = new Set<String>(SIsFromMulti);
                for (String s : SIsFromMultiSet) {
                    IndicationsToInsert.add(new CFAR_Specific_Indication_for_Trial_gne__c(CFAR_Trial_ref_gne__c = trial.Id, CFAR_Specific_Indication_ref_gne__c = s));
                }

            }
            insert indicationsToInsert;
        }
    }

    public static void handleSpecificIndicationsChanged(Map<Id,CFAR_Trial_gne__c> oldTrialMap, Map<Id,CFAR_Trial_gne__c> newTrialMap) {
        if (oldTrialMap != null && newTrialMap != null && !oldTrialMap.isEmpty() && !newTrialMap.isEmpty()) {
            List<CFAR_Trial_gne__c> trialsWithSpecificIndicationsChanged = new List<CFAR_Trial_gne__c>();
            for (Id trialId : newTrialMap.keySet()) {
                if (newTrialMap.get(trialId).Specific_Indication_Multi_gne__c != oldTrialMap.get(trialId).Specific_Indication_Multi_gne__c) {
                    trialsWithSpecificIndicationsChanged.add(newTrialMap.get(trialId));
                }
            }
            if (trialsWithSpecificIndicationsChanged.isEmpty()) {
                return;
            }
            List<CFAR_Specific_Indication_for_Trial_gne__c> currentIndications = [select CFAR_Specific_Indication_ref_gne__c, CFAR_Trial_ref_gne__c from CFAR_Specific_Indication_for_Trial_gne__c where CFAR_Trial_ref_gne__c IN :trialsWithSpecificIndicationsChanged];
            Map<Id, Map<String,CFAR_Specific_Indication_for_Trial_gne__c>> currentIndicationsInTrialsMap = new Map<Id, Map<String,CFAR_Specific_Indication_for_Trial_gne__c>>();
            for (CFAR_Specific_Indication_for_Trial_gne__c trialSI : currentIndications) {
                Map<String,CFAR_Specific_Indication_for_Trial_gne__c> tmpSIMap = currentIndicationsInTrialsMap.get(trialSI.CFAR_Trial_ref_gne__c);
                if (tmpSIMap == null) {
                    currentIndicationsInTrialsMap.put(trialSI.CFAR_Trial_ref_gne__c, new Map<String,CFAR_Specific_Indication_for_Trial_gne__c>{trialSI.CFAR_Specific_Indication_ref_gne__c => trialSI});
                }
                else {
                    tmpSIMap.put(trialSI.CFAR_Specific_Indication_ref_gne__c, trialSI);
                }
            }
            List<CFAR_Specific_Indication_for_Trial_gne__c> indicationsToInsert = new List<CFAR_Specific_Indication_for_Trial_gne__c>();
            List<CFAR_Specific_Indication_for_Trial_gne__c> indicationsToDel = new List<CFAR_Specific_Indication_for_Trial_gne__c>();
            for (CFAR_Trial_gne__c trial : trialsWithSpecificIndicationsChanged) {
                List<String> SIsFromMulti = new List<String>();
                if (String.isNotBlank(trial.Specific_Indication_Multi_gne__c)) {
                    SIsFromMulti = CFAR_Utils.convert15to18ID(trial.Specific_Indication_Multi_gne__c.split(';'));
                }
                Set<String> SIsFromMultiSet = new Set<String>(SIsFromMulti);
                List<String> SIsFromMultiOld = new List<String>();
                if (String.isNotBlank(oldTrialMap.get(trial.Id).Specific_Indication_Multi_gne__c)) {
                    SIsFromMultiOld = CFAR_Utils.convert15to18ID(oldTrialMap.get(trial.Id).Specific_Indication_Multi_gne__c.split(';'));
                }
                Set<String> SIsFromMultiOldSet = new Set<String>(SIsFromMultiOld);
                for (String s : SIsFromMultiSet) {
                    if (!SIsFromMultiOldSet.contains(s)) {
                        IndicationsToInsert.add(new CFAR_Specific_Indication_for_Trial_gne__c(CFAR_Trial_ref_gne__c = trial.Id, CFAR_Specific_Indication_ref_gne__c = s));
                    }
                }
                for (String s : SIsFromMultiOldSet) {
                    if (!SIsFromMultiSet.contains(s) && currentIndicationsInTrialsMap.get(trial.Id) != null && currentIndicationsInTrialsMap.get(trial.Id).get(s) != null) {
                        indicationsToDel.add(currentIndicationsInTrialsMap.get(trial.Id).get(s));
                    }
                }
            }
            CFAR_SecurityUtils.deleteRecords(indicationsToDel);
            insert indicationsToInsert;
        }
    }

    public static String getSIForInfrepReport(List<CFAR_Specific_Indication_for_Trial_gne__c> specInds){
        String di = '';
        for (CFAR_Specific_Indication_for_Trial_gne__c si : specInds) {
            di += si.CFAR_Specific_Indication_ref_gne__r.Name + ', ';
        }
        if (!String.isBlank(di)) {
            di = di.removeEnd(', ');
        }
        return di;
    }

    public static List<String> convert15to18ID(List<String> ids15) {
        List<String> ids18 = new List<String>();
        for(String id15 : ids15) {
            if(String.isNotBlank(id15)) {
                id15 = String.escapeSingleQuotes(id15);
                if((id15.length() == 15 || id15.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', id15))
                    ids18.add(String.valueOf(Id.valueOf(id15)));
            }
        }
        return ids18;
    }

    public static List<String> convert18to15ID(List<String> ids18) {
        List<String> ids15 = new List<String>();
        for(String id18 : ids18) {
            if(String.isNotBlank(id18)) {
                String id = String.escapeSingleQuotes(id18);
                if((id.length() == 15 || id.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', id))
                    ids15.add(id.substring(0,15));
            }
        }
        return ids15;
    }

    public static Set<Id> getTrialsWhereCurrentUserShouldSeeAlerts(Id currentUserId) {
        Set<Id> trialsWhereCurrentUserShouldSeeAlerts = new Set<Id>();
    
        for (CFAR_Team_Member_gne__c teamMember : [SELECT CFAR_Trial_ref_gne__c FROM CFAR_Team_Member_gne__c WHERE Alerts_gne__c = TRUE AND Contact_address_ref_gne__r.CFAR_Contact_ref_gne__r.User_ref_gne__c = :currentUserId]) {
            trialsWhereCurrentUserShouldSeeAlerts.add(teamMember.CFAR_Trial_ref_gne__c);
        }
    
        return trialsWhereCurrentUserShouldSeeAlerts;
    }
    
    public static List<CFAR_Home_Controller.AlertWrapper> getRegulatoryDocumentAlertWrappers(Set<Id> trialsWhereCurrentUserShouldSeeAlerts, Date compareDate, Date compareDateNegative, Date today) {
        List<CFAR_Home_Controller.AlertWrapper> alertWrappers = new List<CFAR_Home_Controller.AlertWrapper>();
    
        for (CFAR_Regulatory_Document_Tracking_gne__c rdt : [SELECT Id, Name, CFAR_Trial_gne__c, Expiry_Date_gne__c, CFAR_Trial_gne__r.Name, CFAR_Trial_gne__r.CTMS_gne__c, CFAR_Trial_gne__r.frm_Investigator_ref_gne__c, Regulatory_Tracking_Activity_gne__c, Regulatory_Tracking_Activity_gne__r.Name, Activity_gne__c FROM CFAR_Regulatory_Document_Tracking_gne__c WHERE CFAR_Trial_gne__c IN :trialsWhereCurrentUserShouldSeeAlerts AND Expiry_Date_gne__c != null AND Regulatory_Tracking_Activity_gne__r.Name = 'IRB Renewal' ORDER BY CreatedDate DESC LIMIT 1]) {
            String rdtName = (rdt.Regulatory_Tracking_Activity_gne__r != null && rdt.Regulatory_Tracking_Activity_gne__r.Name != null) ? rdt.Regulatory_Tracking_Activity_gne__r.Name : '';
    
            if (rdt.Expiry_Date_gne__c <= compareDate && rdt.Expiry_Date_gne__c >= compareDateNegative) {
                Integer days = today.daysBetween(rdt.Expiry_Date_gne__c);
                String dayPart = (days == 1 || days == -1) ? ' day' : ' days';
                String expiryPart = (days < 0) ? ' expired ' : ' expiring in ';
                String agoPart = (days < 0) ? ' ago' : '';
    
                String alertMessage = (days == 0) ? 'You have a Reg Doc ' + rdtName + ' expiring today' : 'You have a Reg Doc ' + rdtName + expiryPart + days + dayPart + agoPart;
    
                CFAR_Home_Controller.AlertWrapper alertWrapper = new CFAR_Home_Controller.AlertWrapper(alertMessage, rdt.CFAR_Trial_gne__r.frm_Investigator_ref_gne__c, rdt.CFAR_Trial_gne__r.Name, rdt.CFAR_Trial_gne__r.CTMS_gne__c, rdt.CFAR_Trial_gne__c);
                alertWrappers.add(alertWrapper);
            }
        }
    
        return alertWrappers;
    }
    
    public static List<CFAR_Home_Controller.AlertWrapper> getMilestoneActivityAlertWrappers(Set<Id> trialsWhereCurrentUserShouldSeeAlerts, Date compareDate, Date today) {
        List<CFAR_Home_Controller.AlertWrapper> alertWrappers = new List<CFAR_Home_Controller.AlertWrapper>();
    
        for (CFAR_Milestone_Activity_gne__c ma : [SELECT Id, Name, CFAR_Trial_ref_gne__c, CFAR_Trial_ref_gne__r.frm_Investigator_ref_gne__c, CFAR_Trial_ref_gne__r.Name, CFAR_Trial_ref_gne__r.CTMS_gne__c, Actual_Date_gne__c, Baselined_Date_gne__c, Planned_Date_gne__c FROM CFAR_Milestone_Activity_gne__c WHERE Planned_Date_gne__c != null AND Planned_Date_gne__c < :compareDate AND Actual_Date_gne__c = null AND Name NOT IN :CFAR_Utils.disabledMilestoneActivities AND CFAR_Trial_ref_gne__c IN :trialsWhereCurrentUserShouldSeeAlerts]) {
            if (ma.Planned_Date_gne__c != null && ma.Planned_Date_gne__c <= compareDate) {
                Integer days = today.daysBetween(ma.Planned_Date_gne__c);
                String dayPart = (days == 1 || days == -1) ? ' day' : ' days';
                if (days == 0) {
                    String expiryPart = ' Milestone that will expire today.';
                    String agoPart = '';
                    String startPart = 'You have an ';
                    String alertMessage = startPart + ma.Name + expiryPart;
    
                    CFAR_Home_Controller.AlertWrapper alertWrapper = new CFAR_Home_Controller.AlertWrapper(alertMessage, ma.CFAR_Trial_ref_gne__r.frm_Investigator_ref_gne__c, ma.CFAR_Trial_ref_gne__r.Name, ma.CFAR_Trial_ref_gne__r.CTMS_gne__c, ma.CFAR_Trial_ref_gne__c);
                    alertWrappers.add(alertWrapper);
                }
                if (ma.Name == 'FSR' && days > 0 && days < 31) {
                    String expiryPart = ' Milestone that will expire in ';
                    String agoPart = '';
                    String startPart = 'You have an ';
                    String alertMessage = startPart + ma.Name + expiryPart + days + dayPart + agoPart;
    
                    CFAR_Home_Controller.AlertWrapper alertWrapper = new CFAR_Home_Controller.AlertWrapper(alertMessage, ma.CFAR_Trial_ref_gne__r.frm_Investigator_ref_gne__c, ma.CFAR_Trial_ref_gne__r.Name, ma.CFAR_Trial_ref_gne__r.CTMS_gne__c, ma.CFAR_Trial_ref_gne__c);
                    alertWrappers.add(alertWrapper);
                } else if (days > -31 && days < 0) {
                    days = -days;
                    String expiryPart = ' Milestone that expired ';
                    String agoPart = ' ago';
                    String startPart = 'You have an ';
                    String alertMessage = startPart + ma.Name + expiryPart + days + dayPart + agoPart;
    
                    CFAR_Home_Controller.AlertWrapper alertWrapper = new CFAR_Home_Controller.AlertWrapper(alertMessage, ma.CFAR_Trial_ref_gne__r.frm_Investigator_ref_gne__c, ma.CFAR_Trial_ref_gne__r.Name, ma.CFAR_Trial_ref_gne__r.CTMS_gne__c, ma.CFAR_Trial_ref_gne__c);
                    alertWrappers.add(alertWrapper);
                } 
            }
        }
    
        return alertWrappers;
    }
    
    public static List<CFAR_Home_Controller.AlertWrapper> getContractAlertWrappers(Set<Id> trialsWhereCurrentUserShouldSeeAlerts, Date today) {
        List<CFAR_Home_Controller.AlertWrapper> alertWrappers = new List<CFAR_Home_Controller.AlertWrapper>();
        Map<Id, List<String>> budgetIdsToTrials = new Map<Id, List<String>>();
        for (CFAR_Budget_Contract_gne__c bC : [SELECT Id, Team_Member_ref_gne__r.CFAR_Trial_ref_gne__r.CTMS_gne__c, Team_Member_ref_gne__r.CFAR_Trial_ref_gne__r.Name, Team_Member_ref_gne__r.CFAR_Trial_ref_gne__r.frm_Investigator_ref_gne__c, Team_Member_ref_gne__r.CFAR_Trial_ref_gne__r.Id FROM CFAR_Budget_Contract_gne__c WHERE Team_Member_ref_gne__r.CFAR_Trial_ref_gne__c IN :trialsWhereCurrentUserShouldSeeAlerts]) {
            budgetIdsToTrials.put(bC.Id, new List<String>{
                bC.Team_Member_ref_gne__r.CFAR_Trial_ref_gne__r.Name,
                bC.Team_Member_ref_gne__r.CFAR_Trial_ref_gne__r.frm_Investigator_ref_gne__c,
                bC.Team_Member_ref_gne__r.CFAR_Trial_ref_gne__r.CTMS_gne__c,
                bC.Team_Member_ref_gne__r.CFAR_Trial_ref_gne__r.Id
            });
        }
    
        List<Id> isContractUnique = new List<Id>();
    
        for (CFAR_Budget_Contract_Tracking_gne__c bCT : [SELECT Id, Contract_Expiry_Date_gne__c, Budget_Contract_ref_gne__c FROM CFAR_Budget_Contract_Tracking_gne__c WHERE Budget_Contract_ref_gne__c  IN :budgetIdsToTrials.keySet() ORDER BY Name DESC]) {
            if (bCT.Contract_Expiry_Date_gne__c != null) {
                Integer daysBetween = Date.today().daysBetween(bCT.Contract_Expiry_Date_gne__c);
                if (daysBetween > 30 || daysBetween < -30) {
                    isContractUnique.add(bCT.Budget_Contract_ref_gne__c);
                }
    
                if (!isContractUnique.contains(bCT.Budget_Contract_ref_gne__c)) {
                    if (daysBetween <= 30 && daysBetween >= -30) {
                        String alertMessage = '';
                        String trialName = budgetIdsToTrials.get(bCT.Budget_Contract_ref_gne__c)[0];
                        String investigatorName = budgetIdsToTrials.get(bCT.Budget_Contract_ref_gne__c)[1];
                        String ctmsNumber = budgetIdsToTrials.get(bCT.Budget_Contract_ref_gne__c)[2];
                        String trialId = budgetIdsToTrials.get(bCT.Budget_Contract_ref_gne__c)[3];
                        isContractUnique.add(bCT.Budget_Contract_ref_gne__c);
    
                        String startMessage = 'You have a Contract that ';
    
                        if (daysBetween > 1 && daysBetween <= 30) {
                            alertMessage = startMessage + 'will expire in ' + daysBetween + ' days.';
                        }
                        if (daysBetween == 0) {
                            alertMessage = startMessage + 'will expire today.';
                        }
                        if (daysBetween == -1) {
                            startMessage = 'You had a Contract ';
                            alertMessage = startMessage + 'expired yesterday.';
                        }
                        if (daysBetween == 1) {
                            alertMessage = startMessage + 'will expire tomorrow.';
                        }
                        if (daysBetween < -1 && daysBetween >= -30) {
                            startMessage = 'You had a Contract ';
                            alertMessage = startMessage + 'expired ' + (-daysBetween) + ' days ago.';
                        }
                        CFAR_Home_Controller.AlertWrapper alertWrapper = new CFAR_Home_Controller.AlertWrapper(alertMessage, investigatorName, trialName, ctmsNumber, trialId);
                        alertWrappers.add(alertWrapper);
                    }
                }
            }
        }
    
        return alertWrappers;
    }
    //VALIDATION METHODS

    public static Boolean invalidNumber(Object numberToCheck) {
        System.debug('Slawek DBG invalid number check');
        Boolean retVal = false;
        Integer cnt = 0;
        String str;
        if (numberToCheck == null) {
            retVal = true;
        }
        else {
            try {
                str = String.valueOf(numberToCheck);
            }
            catch (Exception e) {
                retVal = true;
            }
            if (!String.isBlank(str)) {
                try {
                    Decimal dec = Decimal.valueOf(str);
                } catch (Exception e) {
                    cnt++;
                    System.debug('Slawek DBG not Decimal');
                }
                try {
                    Double db = Double.valueOf(str);
                } catch (Exception e) {
                    cnt++;
                    System.debug('Slawek DBG not Double');
                }
                try {
                    Integer i = Integer.valueOf(str);
                } catch (Exception e) {
                    cnt++;
                    System.debug('Slawek DBG not Integer');
                }
                try {
                    Long l = Long.valueOf(str);
                } catch (Exception e) {
                    cnt++;
                    System.debug('Slawek DBG not Long');
                }
                if (cnt == 4) {
                    retVal = true;
                }
                System.debug('Slawek DBG cnt: ' + cnt);
            }
        }
        return retVal;
    }

    public static Boolean invalidIntegerOrLong(Object numberToCheck) {
        Boolean retVal = false;
        Integer cnt = 0;
        String str;
        if (numberToCheck == null) {
            retVal = true;
        }
        else {
            try {
                str = String.valueOf(numberToCheck);
            }
            catch (Exception e) {
                retVal = true;
            }
            if (!String.isBlank(str)) {
                try {
                    Integer i = Integer.valueOf(str);
                } catch (Exception e) {
                    cnt++;
                    System.debug('Slawek DBG not Integer');
                }
                try {
                    Long l = Long.valueOf(str);
                } catch (Exception e) {
                    cnt++;
                    System.debug('Slawek DBG not Long');
                }
                if (cnt == 2) {
                    retVal = true;
                }
            }
        }
        return retVal;
    }

    public static Boolean invalidNegativeNumber(Object numberToCheck) {
        Boolean retVal = false;
        if (numberToCheck == null || invalidNumber(numberToCheck)) {
            retVal = true;
        }
        else if ((Decimal)numberToCheck < 0 || (Decimal)numberToCheck == 0 ){
            retVal = true;
        }
        return retVal;
    }

    public static list<SelectOption> getPicklistValues(SObject obj, String fld) {
        list<SelectOption> options = new list<SelectOption>();
        // Get the object type of the SObject.
        Schema.sObjectType objType = obj.getSObjectType();
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        // Get a map of fields for the SObject
        map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        // Get the list of picklist values for this field.
        list<Schema.PicklistEntry> values =
                fieldMap.get(fld).getDescribe().getPickListValues();
        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a : values)
        {
            options.add(new SelectOption(a.getValue(), a.getLabel()));
        }
        return options;
    }

    public static CFAR_Team_Member_gne__c getPrimaryInvestigatorForTrial(Id trialID) {
        return getPrimaryInvestigatorForTrial(trialID, true);
    }

    public static CFAR_Team_Member_gne__c getPrimaryInvestigatorForTrial(Id trialID, boolean activeOnly) {
        String piRole = 'PI = Primary (or Principal) Investigator';
        String query = 'select Id, frm_Name_gne__c from CFAR_Team_Member_gne__c where CFAR_Trial_ref_gne__c = :trialID and frm_Function_Role_gne__c = :piRole';
        if (activeOnly) {
            query += ' and frm_Is_Inactive_gne__c = false';
        }
        List<CFAR_Team_Member_gne__c> investigators = Database.query(query);
        return investigators.size() > 0 ? investigators.get(0) : null;
    }

    public static Boolean checkExternalDuplicate(String trialId, String otherTrialId){
        List<CFAR_Trial_gne__c> trials;
        if(String.isNotBlank(otherTrialId)) {
            if(String.isNotBlank(trialId))
                trials = [SELECT Id, Other_Trial_gne_Id__c FROM CFAR_Trial_gne__c Where Other_Trial_gne_Id__c = :otherTrialId AND Id != :trialId];
            else
                    trials = [SELECT Id, Other_Trial_gne_Id__c FROM CFAR_Trial_gne__c Where Other_Trial_gne_Id__c = :otherTrialId];
        }
        if(trials != null && trials.size() > 0) {
            return false;
        }
        return true;
    }

    public static void handleUserAssignmentUnassignmentOnContact(Map<Id, CFAR_Contact_gne__c> oldContactsMap, Map<Id, CFAR_Contact_gne__c> newContactsMap) {
        List<CFAR_Team_Member_gne__c> teamMembersToUpdate = new List<CFAR_Team_Member_gne__c>();
        Set<Id> contactsToUnassignIds = new Set<Id>();
        Set<Id> contactsToAssignIds = new Set<Id>();
        
        for (Id contactId : newContactsMap.keySet()) {
            CFAR_Contact_gne__c oldContact = oldContactsMap.get(contactId);
            CFAR_Contact_gne__c newContact = newContactsMap.get(contactId);
            
            // Unassign user
            if (oldContact.User_ref_gne__c != null && newContact.User_ref_gne__c == null) {
                contactsToUnassignIds.add(contactId);
            }
            // Assign user
            else if (newContact.User_ref_gne__c != null && oldContact.User_ref_gne__c == null) {
                contactsToAssignIds.add(contactId);
            }
        }
        
        if (!contactsToUnassignIds.isEmpty()) {
            List<CFAR_Team_Member_gne__c> teamMembersToUnassign = [
                SELECT Alerts_gne__c 
                FROM CFAR_Team_Member_gne__c 
                WHERE Contact_address_ref_gne__r.CFAR_Contact_ref_gne__c IN :contactsToUnassignIds 
                    AND Alerts_gne__c = true
            ];
            
            for (CFAR_Team_Member_gne__c tm : teamMembersToUnassign) {
                tm.Alerts_gne__c = false;
                teamMembersToUpdate.add(tm);
            }
        }
        
        if (!contactsToAssignIds.isEmpty()) {
            List<CFAR_Team_Member_gne__c> teamMembersToAssign = [
                SELECT Alerts_gne__c 
                FROM CFAR_Team_Member_gne__c 
                WHERE Contact_address_ref_gne__r.CFAR_Contact_ref_gne__c IN :contactsToAssignIds 
                    AND Alerts_gne__c != true
                    AND Is_Trial_Primary_Contact_gne__c = true 
                    AND frm_Is_Inactive_gne__c = false
            ];
            
            for (CFAR_Team_Member_gne__c tm : teamMembersToAssign) {
                tm.Alerts_gne__c = true;
                teamMembersToUpdate.add(tm);
            }
        }
        
        CFAR_SecurityUtils.updateRecords(teamMembersToUpdate);
    }

    public static Integer compare(String str1, String str2, boolean nullLast) {
        boolean isStr1Blank = String.isBlank(str1);
        boolean isStr2Blank = String.isBlank(str2);
    
        if (isStr1Blank && isStr2Blank) {
            return 0;
        } else if (isStr1Blank) {
            return (nullLast) ? 1 : -1;
        } else if (isStr2Blank) {
            return (nullLast) ? -1 : 1;
        } else {
            return str1.toLowerCase().compareTo(str2.toLowerCase());
        }
    }

    public static Integer compare(String str1, String str2) {
        return compare(str1, str2, false);
    }

    public static Decimal nullSafeGet(Decimal value) {
        return (value == null) ? Decimal.valueOf(0) : value;
    }

    public static String toStringNullBlank(Date value) {
        return (value == null) ? '' : value.format();
    }

    public static void logError(Exception ex, Id recordId) {
        try {
            String relatedToType = (recordId == null) ? '' : recordId.getSObjectType().getDescribe().getName();
            insertErrorLog(ex.getStackTraceString(), ex.getTypeName(), ex.getMessage(), recordId, relatedToType);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }
    
    @future
    public static void insertErrorLog(String description, String type, String message, Id recordId, String relatedToType) {
        try {
            insert new CFAR_Error_gne__c(Description_gne__c = description, Type_gne__c = type,
            Message_gne__c = message, Related_To_gne__c = recordId, Related_To_Type_gne__c = relatedToType);
        } catch (DmlException ex) {
            System.debug(ex.getMessage());
        }
    }

    public static void sortAndJoinImpacts (CFAR_Trial_gne__c trial) {

        List<String> impactsToSort = new List<String>();
        for (String impact : trial.Impacts_gne__c.split(';')) {
            impactsToSort.add(impact);
        }

        impactsToSort.sort();
        trial.Impacts_gne__c = String.join(impactsToSort, ';');
    }

    public static List<Object> getIntersectionList(List<Object> list1, List<Object> list2) {
        Set<Object> resultSet = new Set<Object>();
        for (Object obj1 : list1) {
            for (Object obj2 : list2) {
                if (obj1 == obj2) {
                    resultSet.add(obj1);
                }
            }
        }
        return new List<Object>(resultSet);
    }

    public static Set<String> getTrialsForContacts(List<String> contacts) {
        CFAR_SearchParameters searchParams = new CFAR_SearchParameters();
        searchParams.andInParameters.put('contact_address_ref_gne__r.CFAR_Contact_ref_gne__c', contacts);
        Set<String> resultList = new Set<String>();
        for (CFAR_Team_Member_gne__c tm : CFAR_DAO.getTeamMembers(searchParams)) {
            resultList.add(tm.CFAR_Trial_ref_gne__c);
        }
        return resultList;
    }

    public static Boolean checkProductDuplicate(Id themeId, String productName, Id productId) {
        if (productId == null) {
            return [SELECT COUNT() FROM CFAR_Product_gne__c WHERE Theme_ref_gne__c = :themeId AND Name = :productName] > 0;
        } else {
            return [SELECT COUNT() FROM CFAR_Product_gne__c WHERE Theme_ref_gne__c = :themeId AND Name = :productName AND Id != :productId] > 0;
        }
    }

    public static Boolean checkThemeDuplicate(String themeNumber, Id themeId) {
        if (themeId == null) {
            return [SELECT COUNT() FROM CFAR_Theme_gne__c WHERE Name = :themeNumber] > 0;
        } else {
            return [SELECT COUNT() FROM CFAR_Theme_gne__c WHERE Name = :themeNumber AND Id != :themeId] > 0;
        }
    }
}