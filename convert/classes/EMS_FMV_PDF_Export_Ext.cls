public without sharing class EMS_FMV_PDF_Export_Ext {

    private String attendeeId { get; set; }
    public String fileName { get; private set; }
    public EMS_Attendee_gne__c fmv { get; private set; }
    public String HCPType { get; private set; }
    public String HCPAttendee { get; private set; }
    public String eventStartDate { get; private set; }
    public String eventEndDate { get; private set; }

    public Decimal talkPrepAmount { get; private set; }
    public Decimal activityAmount { get; private set; }
    public Decimal hourlyRateOfHCP { get; private set; }
    public Boolean hidePreperationFields { get; private set; }
    public String eventInfoHeader { get; private set; }

    public Map<Integer, Decimal> preparationTimeSummary { get; private set; }

    public EMS_FMV_PDF_Export_Ext() {
        attendeeId = ApexPages.currentPage().getParameters().get('id');
        fileName = ApexPages.currentPage().getParameters().get('fn') + ' Export ' + Datetime.now().format('MM_dd_yyyy h:mm a');

        fmv = new EMS_Attendee_gne__c();
        if (!String.isBlank(attendeeId)) {
            fmv = [
                    SELECT Preparation_Time_1_gne__c, Preparation_Time_2_gne__c, Preparation_Time_3_gne__c, Preparation_Time_4_gne__c, Preparation_Time_5_gne__c, Preparation_Time_6_gne__c,
                            Account_gne__r.Name, Account_gne__r.FirstName, Account_gne__r.LastName, EMS_International_Speaker_gne__r.Name, Activity_Time_gne__c, Address_gne__c, Disturbance_Fee__c, Email_address_gne__c, Hourly_Rate_of_HCP_gne__c,
                            Topic_and_Intent_1_gne__c, Topic_and_Intent_2_gne__c, Topic_and_Intent_3_gne__c, Topic_and_Intent_4_gne__c, Topic_and_Intent_5_gne__c, Topic_and_Intent_6_gne__c,
                            EMS_Event_gne__r.Start_Date_gne__c, EMS_Event_gne__r.End_Date_gne__c, Event_Start_Time_gne__c, Event_End_Time_gne__c, Payable_To_Name_gne__c,
                            km_gne__c, Name_and_email_of_the_contact_person_gne__c, Role_gne__c, Type_of_HCP_other_gne__c, HCP_hourly_rate_table_gne__c, Type_of_HCP_gne__c,
                            Preferred_way_to_contact_the_speaker_gne__c, Special_Request_additional_inf_gne__c, Topic_and_Intent_gne__c, Telephone_number_gne__c, RecordType.Name,
                            Total_Honoraria_gne__c, Activity_Time_1_gne__c, Activity_Time_2_gne__c, Activity_Time_3_gne__c, Activity_Time_4_gne__c, Activity_Time_5_gne__c, Activity_Time_6_gne__c,
                            Hourly_Rate_of_HCP_2_gne__c, Disturbance_Fee_Amount_gne__c, Activity_Amount_gne__c, Talk_Prep_Amount_gne__c, New_FMV_Form_gne__c,
                            EMS_Event_gne__r.Event_Type_gne__c, EMS_Event_gne__r.Event_Sub_Type_gne__c, EMS_Event_gne__r.Name, EMS_Event_gne__r.Event_Name_gne__c, Prep_Time_gne__c, Prep_Amount_gne__c, EMS_Event_gne__r.CreatedDate
                    FROM EMS_Attendee_gne__c
                    WHERE Id = :attendeeId
                    LIMIT 1
            ];
        }

        eventInfoHeader = (fmv.EMS_Event_gne__r.Name + ': ' + fmv.EMS_Event_gne__r.Event_Name_gne__c);

        HCPType = ApexPages.currentPage().getParameters().get('att_type');
        if (String.isNotBlank(fmv.Account_gne__c)) {
            HCPAttendee = fmv.Account_gne__r.Name;
            if (HCPAttendee == null) {
                HCPAttendee = fmv.Account_gne__r.FirstName + ' ' + fmv.Account_gne__r.LastName;
            }
        } else if (String.isNotBlank(fmv.EMS_International_Speaker_gne__c)) {
            HCPAttendee = fmv.EMS_International_Speaker_gne__r.Name;
        }

        if(fmv.EMS_Event_gne__r.Start_Date_gne__c != null) {
            Date startDate = (Date) fmv.EMS_Event_gne__r.Start_Date_gne__c;
            eventStartDate = startDate.month() + '/' + startDate.day() + '/' + startDate.year();
        } else {
            eventStartDate = '';
        }
        if(fmv.EMS_Event_gne__r.Start_Date_gne__c != null) {
            Date endDate = (Date) fmv.EMS_Event_gne__r.End_Date_gne__c;
            eventEndDate = endDate.month() + '/' + endDate.day() + '/' + endDate.year();
        } else {
            eventEndDate = '';
        }


        preparationTimeSummary = new Map<Integer, Decimal>();
        if (fmv.Preparation_Time_1_gne__c != null) {
            preparationTimeSummary.put(1, Decimal.valueOf(fmv.Preparation_Time_1_gne__c) * ((fmv.Hourly_Rate_of_HCP_2_gne__c != null) ? Decimal.valueOf(fmv.Hourly_Rate_of_HCP_2_gne__c) : 0.00));
        }
        if (fmv.Preparation_Time_2_gne__c != null) {
            preparationTimeSummary.put(2, Decimal.valueOf(fmv.Preparation_Time_2_gne__c) * ((fmv.Hourly_Rate_of_HCP_2_gne__c != null) ? Decimal.valueOf(fmv.Hourly_Rate_of_HCP_2_gne__c) : 0.00));
        }
        if (fmv.Preparation_Time_3_gne__c != null) {
            preparationTimeSummary.put(3, Decimal.valueOf(fmv.Preparation_Time_3_gne__c) * ((fmv.Hourly_Rate_of_HCP_2_gne__c != null) ? Decimal.valueOf(fmv.Hourly_Rate_of_HCP_2_gne__c) : 0.00));
        }
        if (fmv.Preparation_Time_4_gne__c != null) {
            preparationTimeSummary.put(4, Decimal.valueOf(fmv.Preparation_Time_4_gne__c) * ((fmv.Hourly_Rate_of_HCP_2_gne__c != null) ? Decimal.valueOf(fmv.Hourly_Rate_of_HCP_2_gne__c) : 0.00));
        }
        if (fmv.Preparation_Time_5_gne__c != null) {
            preparationTimeSummary.put(5, Decimal.valueOf(fmv.Preparation_Time_5_gne__c) * ((fmv.Hourly_Rate_of_HCP_2_gne__c != null) ? Decimal.valueOf(fmv.Hourly_Rate_of_HCP_2_gne__c) : 0.00));
        }
        if (fmv.Preparation_Time_6_gne__c != null) {
            preparationTimeSummary.put(6, Decimal.valueOf(fmv.Preparation_Time_6_gne__c) * ((fmv.Hourly_Rate_of_HCP_2_gne__c != null) ? Decimal.valueOf(fmv.Hourly_Rate_of_HCP_2_gne__c) : 0.00));
        }

        Decimal sumPreparationTime = ((fmv.Preparation_Time_1_gne__c != null) ? Decimal.valueOf(fmv.Preparation_Time_1_gne__c) : 0)
                + ((fmv.Preparation_Time_2_gne__c != null) ? Decimal.valueOf(fmv.Preparation_Time_2_gne__c) : 0)
                + ((fmv.Preparation_Time_3_gne__c != null) ? Decimal.valueOf(fmv.Preparation_Time_3_gne__c) : 0)
                + ((fmv.Preparation_Time_4_gne__c != null) ? Decimal.valueOf(fmv.Preparation_Time_4_gne__c) : 0)
                + ((fmv.Preparation_Time_5_gne__c != null) ? Decimal.valueOf(fmv.Preparation_Time_5_gne__c) : 0)
                + ((fmv.Preparation_Time_6_gne__c != null) ? Decimal.valueOf(fmv.Preparation_Time_6_gne__c) : 0);

        talkPrepAmount = ((fmv.Hourly_Rate_of_HCP_2_gne__c != null) ? Decimal.valueOf(fmv.Hourly_Rate_of_HCP_2_gne__c) : 0.00) * sumPreparationTime;
        talkPrepAmount = talkPrepAmount.setScale(2);

        if (getIsOLA_CHE()) {
            Decimal sumActivityTime = ((fmv.Activity_Time_1_gne__c != null) ? Decimal.valueOf(fmv.Activity_Time_1_gne__c) : 0)
                    + ((fmv.Activity_Time_2_gne__c != null) ? Decimal.valueOf(fmv.Activity_Time_2_gne__c) : 0)
                    + ((fmv.Activity_Time_3_gne__c != null) ? Decimal.valueOf(fmv.Activity_Time_3_gne__c) : 0)
                    + ((fmv.Activity_Time_4_gne__c != null) ? Decimal.valueOf(fmv.Activity_Time_4_gne__c) : 0)
                    + ((fmv.Activity_Time_5_gne__c != null) ? Decimal.valueOf(fmv.Activity_Time_5_gne__c) : 0)
                    + ((fmv.Activity_Time_6_gne__c != null) ? Decimal.valueOf(fmv.Activity_Time_6_gne__c) : 0);

            activityAmount = ((fmv.Hourly_Rate_of_HCP_2_gne__c != null) ? Decimal.valueOf(fmv.Hourly_Rate_of_HCP_2_gne__c) : 0.00) * sumActivityTime;
        } else {
            // isConsultingMeeting, isInformalConsulting, isPreceptorships
            if (fmv.Type_of_HCP_gne__c != 'iHCP') {
                activityAmount = ((fmv.Hourly_Rate_of_HCP_2_gne__c != null) ? Decimal.valueOf(fmv.Hourly_Rate_of_HCP_2_gne__c) : 0.00)
                        * ((fmv.Activity_Time_gne__c != null) ? Decimal.valueOf(fmv.Activity_Time_gne__c) : 0.00);
            } else {
                activityAmount = 0.00;
            }
        }
        activityAmount = activityAmount.setScale(2);

        if (fmv.Hourly_Rate_of_HCP_gne__c == null) {
            fmv.Hourly_Rate_of_HCP_gne__c = 0.00;
        }
        if (fmv.Disturbance_Fee__c == null) {
            fmv.Disturbance_Fee_Amount_gne__c = 0.00;
            fmv.km_gne__c = '--None--';
        }
        if (fmv.Total_Honoraria_gne__c == null) {
            fmv.Total_Honoraria_gne__c = 0.00;
        }

        Map<String, List<String>> fmvSettings = getPreparationTimes(fmv.EMS_Event_gne__r.Event_Type_gne__c, fmv.EMS_Event_gne__r.Event_Sub_Type_gne__c);
        if (fmvSettings.containsKey(fmv.Role_gne__c)) {
            hidePreperationFields = false;
        } else {
            hidePreperationFields = true;
        }

        hourlyRateOfHCP = (String.isBlank(fmv.Hourly_Rate_of_HCP_2_gne__c)) ? 0.00 : Decimal.valueOf(fmv.Hourly_Rate_of_HCP_2_gne__c).setScale(2);
    }

    public Boolean isOldFMV {
        get {
            return !(fmv.New_FMV_Form_gne__c);
        }
    }
    
    public Boolean isOldDisturbanceFeeLabel {
        get {
            return EMS_Util.oldDisturbanceFeeLabel(fmv.EMS_Event_gne__r.CreatedDate);
        }
    }

    public Map<String, String> labelReplacement {
        get {
            if (labelReplacement == null) {
                if (isOldFMV) { // for all old FMV forms
                    labelReplacement = new Map<String, String>{
                            Schema.SObjectType.EMS_Attendee_gne__c.fields.Type_of_HCP_gne__c.Label => 'HCP / Stakeholder',
                            Schema.SObjectType.EMS_Attendee_gne__c.fields.Hourly_Rate_of_HCP_gne__c.Label => 'Hourly Rate of HCP',
                            Schema.SObjectType.EMS_Attendee_gne__c.fields.km_gne__c.Label => 'km (Round trip)'

                    };
                    if (HCPType.toLowerCase() == 'ihcp') {
                        labelReplacement.put(Schema.SObjectType.EMS_Attendee_gne__c.fields.Type_of_HCP_gne__c.Label, 'iHCP Attendee');
                    } else {
                        labelReplacement.put(Schema.SObjectType.EMS_Attendee_gne__c.fields.Type_of_HCP_gne__c.Label, 'HCP Attendee');
                    }
                } else {
                    labelReplacement = new Map<String, String>{
                            Schema.SObjectType.EMS_Attendee_gne__c.fields.Type_of_HCP_gne__c.Label => Schema.SObjectType.EMS_Attendee_gne__c.fields.Type_of_HCP_gne__c.Label,
                            Schema.SObjectType.EMS_Attendee_gne__c.fields.Hourly_Rate_of_HCP_gne__c.Label => Schema.SObjectType.EMS_Attendee_gne__c.fields.Hourly_Rate_of_HCP_gne__c.Label,
                            Schema.SObjectType.EMS_Attendee_gne__c.fields.km_gne__c.Label => Schema.SObjectType.EMS_Attendee_gne__c.fields.km_gne__c.Label
                    };
                    if (HCPType.toLowerCase() == 'ihcp') {
                        labelReplacement.put(Schema.SObjectType.EMS_Attendee_gne__c.fields.Type_of_HCP_gne__c.Label, 'iHCP');
                    } else {
                        labelReplacement.put(Schema.SObjectType.EMS_Attendee_gne__c.fields.Type_of_HCP_gne__c.Label, 'HCP / Stakeholder');
                    }
                }
                if(isOldDisturbanceFeeLabel) {
                    labelReplacement.put(Schema.SObjectType.EMS_Attendee_gne__c.fields.Disturbance_Fee__c.Label, 'Disturbance Fee');
                    labelReplacement.put(Schema.SObjectType.EMS_Attendee_gne__c.fields.Disturbance_Fee_Amount_gne__c.Label, Schema.SObjectType.EMS_Attendee_gne__c.fields.Disturbance_Fee_Amount_gne__c.Label);
                } else {
                    labelReplacement.put(Schema.SObjectType.EMS_Attendee_gne__c.fields.Disturbance_Fee__c.Label, Schema.SObjectType.EMS_Attendee_gne__c.fields.Disturbance_Fee__c.Label);
                    labelReplacement.put(Schema.SObjectType.EMS_Attendee_gne__c.fields.Disturbance_Fee_Amount_gne__c.Label, 'Travel Adjustment');
                }

                if(getIsOlaAccreditedCheDevelopment() || getIsRamaHealthEconomics()) {
                    labelReplacement.put(Schema.SObjectType.EMS_Attendee_gne__c.fields.Role_gne__c.Label, 'Attendee role');
                    labelReplacement.put(Schema.SObjectType.EMS_Attendee_gne__c.fields.Topic_and_Intent_gne__c.Label, 'Summary of work required');
                    labelReplacement.put(Schema.SObjectType.EMS_Attendee_gne__c.fields.Activity_Time_gne__c.Label, 'Number of Hours');
                    labelReplacement.put(Schema.SObjectType.EMS_Attendee_gne__c.fields.Activity_Amount_gne__c.Label, 'Number of Hours');
                } else {
                    labelReplacement.put(Schema.SObjectType.EMS_Attendee_gne__c.fields.Role_gne__c.Label, 'HCP Role');
                    labelReplacement.put(Schema.SObjectType.EMS_Attendee_gne__c.fields.Topic_and_Intent_gne__c.Label, Schema.SObjectType.EMS_Attendee_gne__c.fields.Topic_and_Intent_gne__c.Label);
                    labelReplacement.put(Schema.SObjectType.EMS_Attendee_gne__c.fields.Activity_Time_gne__c.Label, Schema.SObjectType.EMS_Attendee_gne__c.fields.Activity_Time_gne__c.Label);
                    labelReplacement.put(Schema.SObjectType.EMS_Attendee_gne__c.fields.Activity_Amount_gne__c.Label, Schema.SObjectType.EMS_Attendee_gne__c.fields.Activity_Amount_gne__c.Label);
                }
            }
            return labelReplacement;
        }
        private set;
    }

    public Boolean getIsConsultingMeeting() {
        return String.isNotBlank(fmv.EMS_Event_gne__r.Event_Type_gne__c) && fmv.EMS_Event_gne__r.Event_Type_gne__c.startsWithIgnoreCase('Consultancy Meeting');
    }
    public Boolean getIsPreceptorships() {
        return (fmv.EMS_Event_gne__r.Event_Sub_type_gne__c == 'Preceptorships (HCP to Roche)' ||
                fmv.EMS_Event_gne__r.Event_Sub_type_gne__c == 'Preceptorships (Roche to HCP)' ||
                fmv.EMS_Event_gne__r.Event_Sub_type_gne__c == 'Preceptorships (HCP to HCP)'
        );
    }
    public Boolean getIsOLA_CHE() {
        return (fmv.EMS_Event_gne__r.Event_Type_gne__c == 'Learning Programs' && (
                    fmv.EMS_Event_gne__r.Event_Sub_type_gne__c == 'Accredited CHE' ||
                    fmv.EMS_Event_gne__r.Event_Sub_type_gne__c == 'Accredited CHE Implementation' ||
                    fmv.EMS_Event_gne__r.Event_Sub_type_gne__c == 'OLA (on Medical Strategy)' ||
                    fmv.EMS_Event_gne__r.Event_Sub_type_gne__c == 'OLA Implementation' ||
                    fmv.EMS_Event_gne__r.Event_Sub_type_gne__c == 'OLA/Accredited CHE Development'
            )
        );
    }
    public Boolean getDisplayEventSubType() {
        return fmv.EMS_Event_gne__r.Event_Sub_type_gne__c == 'OLA/Accredited CHE Development'
                || fmv.EMS_Event_gne__r.Event_Sub_type_gne__c == 'HCP Initiated OLA Implementation'
                || fmv.EMS_Event_gne__r.Event_Sub_type_gne__c == 'RAMA - Health Economics'
                || fmv.EMS_Event_gne__r.Event_Sub_type_gne__c == 'Panel/Round Table'
                || fmv.EMS_Event_gne__r.Event_Sub_type_gne__c == 'Global Standalone';
    }
    public Boolean getIsOlaAccreditedCheDevelopment() {
        return fmv.EMS_Event_gne__r.Event_Sub_type_gne__c == 'OLA/Accredited CHE Development';
    }
    public Boolean getIsInformalConsulting() {
        return fmv.EMS_Event_gne__r.Event_Sub_type_gne__c.startsWith('Informal consulting');
    }
    public Boolean getIsPanelRoundTable() {
        return fmv.EMS_Event_gne__r.Event_Sub_type_gne__c.startsWith('Panel/Round Table');
    }
    public Boolean getIsRamaHealthEconomics() {
        return fmv.EMS_Event_gne__r.Event_Sub_type_gne__c.startsWith('RAMA - Health Economics');
    }
    public Boolean getIsPreceptorshipsHcpToRoche() {
        return fmv.EMS_Event_gne__r.Event_Sub_type_gne__c == 'Preceptorships (HCP to Roche)' && fmv.Prep_Time_gne__c != null && fmv.Prep_Amount_gne__c != null;
    }

    public boolean getIsSpeakerTraining() {
        if (fmv.EMS_Event_gne__r.Event_Type_gne__c == 'Learning Programs' && (
                fmv.EMS_Event_gne__r.Event_Sub_type_gne__c == 'Speaker Training (Faculty Training)' ||
                fmv.EMS_Event_gne__r.Event_Sub_type_gne__c == 'Train the Trainer (Speaker Training)'
        )) {
            return true;
        }
        return false;
    }

    public static Map<String, List<String>> getPreparationTimes(String eventType, String eventSubType) {
        Map<String, List<String>> result = new Map<String, List<String>>();

        Id recordTypeId = Schema.SObjectType.EMS_FMV_Configuration_gne__c.getRecordTypeInfosByName().get('Preparation Time Config').getRecordTypeId();

        for (EMS_FMV_Configuration_gne__c fmvConfig : [
                SELECT Available_Role_gne__c, Preparation_Time_gne__c
                FROM EMS_FMV_Configuration_gne__c
                WHERE EMS_Event_Configuration_gne__r.Event_Type_gne__c = :eventType
                AND EMS_Event_Configuration_gne__r.Event_Sub_Type_gne__c = :eventSubType AND RecordTypeId = :recordTypeId
        ]) {

            if (!result.containsKey(fmvConfig.Available_Role_gne__c)) {
                result.put(fmvConfig.Available_Role_gne__c, new List<String>());
            }

            result.get(fmvConfig.Available_Role_gne__c).add(String.valueOf(fmvConfig.Preparation_Time_gne__c));
        }
        return result;
    }
}