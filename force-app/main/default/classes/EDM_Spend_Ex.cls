public with sharing class EDM_Spend_Ex {
    public EDM_IABP_gne__c currentIABP { get; set; }
    public EDM_Spend_gne__c edmSpend { get; set; }
    public Financials financials { get; set; }
    public List<EDM_Spend_Attendance_gne__c> edmSpendAttendance { get; set; }
    public List<EDM_Spend_Attendance_gne__c> edmSpendAttendanceToRemove { get; set; }

    public Spend spend { get; set; }
    public EDM_Spend_Participant participant { get; set; }
    public List<EDM_Attendee_gne__c> participants { get; set; }
    public String participantMessagePopup { get; set; }

    public String spendStatusToSet { get; set; }
    public Boolean goBackAfterSave { get; set; }

    public HelpText helpTexts { get; private set; }

    @TestVisible
    private User nonVendorABLead;
    private String currentAttendeeId;

    public Boolean downloadDocumentsStarted { get; set; }
    public String sessionIDForDrawLoop { get; private set; }

    public EDM_Spend_Ex(ApexPages.StandardController controller) {
        this(controller, true);
    }

    public EDM_Spend_Ex(ApexPages.StandardController controller, Boolean addFields) {
        if (addFields) {
            controller.addFields(new List<String>{
                    'EDM_Start_Date_gne__c', 'EDM_End_Date_gne__c',
                    'Name', 'EDM_Event_Name_gne__c', 'EDM_Brand_gne__c',
                    'EDM_Canceled_gne__c', 'EDM_Meeting_Approach_gne__c',
                    'EDM_City_gne__c', 'EDM_State_gne__c', 'EDM_Country_gne__c', 'EDM_Venue_gne__c',
                    'EDM_Parent_AABP_gne__c',
                    'EDM_Log_Vendor_Company_Name_gne__c', 'EDM_Cont_Vendor_Company_Name_gne__c',
                    'EDM_Primary_AB_Lead_gne__c', 'EDM_Secondary_AB_Lead_gne__c', 'EDM_Third_AB_Lead_gne__c', 'EDM_Zip_gne__c'
            });
        }
        currentIABP = (EDM_IABP_gne__c) controller.getRecord();

        initNonVendorABLead();

        retrieveEDMSpend(currentIABP.Id);
        retrieveEDMSpendAttendance(currentIABP.Id);
        financials = new Financials(currentIABP.Id);

        participant = new EDM_Spend_Participant();

        helpTexts = new HelpText();

        getParticipantsFromExeSum();

        readSpendInfoFromVDST();

        initVenueForVirtual();
    }

    public PageReference redirectToViewIfFinalized() {
        if (edmSpend.EDM_Spend_Status_gne__c == 'Save & Finalize' || (currentIABP.EDM_Canceled_gne__c && !getIsABMSuperUser())) {
            PageReference pr = Page.EDM_Spend_View_Layout;
            pr.getParameters().put('id', currentIABP.Id);
            pr.setRedirect(true);
            return pr;
        }

        return null;
    }

    public PageReference onChangeEventCancellationType() {
        validateCanceledIABP();
        return null;
    }

    private void validateCanceledIABP() {
        List<String> iabpRequiredDataMissing = new List<String>();
        if (currentIABP.EDM_Canceled_gne__c && edmSpend.EDM_Cancellation_Type_gne__c == 'Cancel w/ Spend') {
            if (currentIABP.EDM_Start_Date_gne__c == null) {
                iabpRequiredDataMissing.add('&emsp;Field Start Date is required');
            }
            if (currentIABP.EDM_End_Date_gne__c == null) {
                iabpRequiredDataMissing.add('&emsp;Field End Date is required');
            }

            if (currentIABP.EDM_Brand_gne__c == null) {
                iabpRequiredDataMissing.add('&emsp;Field Brand(s) is required (If no Brand then please select \'No Product Discussed\')');
            }

            if (!iabpRequiredDataMissing.isEmpty()) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Missing IABP required fields:<BR/>' +
                        String.join(iabpRequiredDataMissing, '<BR/>') +
                        '<BR/><BR/>Please use following link to fill the required fields on IABP: <a style="font-weight:bold" href="' + getLinkToEditIABP() + '">Update Canceled IABP</a>'));
            }
        }
    }

    private String getLinkToEditIABP() {
        return Page.EDM_IABP_Edit_Create.getURL() + '?id=' + currentIABP.Id + '&retURL=/apex/EDM_Spend_Edit_Create?id=' + currentIABP.Id;
    }

    public void initNonVendorABLead() {
        List<User> vendors = EDM_ABM_Utils.getUsersForRole(EDM_ABM_Utils.VDST_ABM);
        Set<Id> vendorIds = (new Map<Id, User>(vendors)).keySet();
        List<User> result;
        if (!vendorIds.contains(currentIABP.EDM_Primary_AB_Lead_gne__c)) {
            result = EDM_ABM_Utils.getUsers(new Set<Id>{
                    currentIABP.EDM_Primary_AB_Lead_gne__c
            });
        } else if (!vendorIds.contains(currentIABP.EDM_Secondary_AB_Lead_gne__c)) {
            result = EDM_ABM_Utils.getUsers(new Set<Id>{
                    currentIABP.EDM_Secondary_AB_Lead_gne__c
            });
        } else if (!vendorIds.contains(currentIABP.EDM_Third_AB_Lead_gne__c)) {
            result = EDM_ABM_Utils.getUsers(new Set<Id>{
                    currentIABP.EDM_Third_AB_Lead_gne__c
            });
        }

        if (result == null || result.isEmpty()) {
            if (ApexPages.currentPage() != null) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Advisory Board Lead with Permission Set other than \'EDM VDST Partner External ABM\' not found on IABP'));
            }
            nonVendorABLead = new User();
        } else {
            nonVendorABLead = result.get(0);
        }
    }

    private void retrieveEDMSpend(ID parentIABPId) {
        List<EDM_Spend_gne__c> edmSpends = EDM_Spend_Utils.retrieveEDMSpend(parentIABPId);

        if (edmSpends.isEmpty()) {
            edmSpend = new EDM_Spend_gne__c(EDM_Parent_IABP_gne__c = parentIABPId);
        } else {
            edmSpend = edmSpends.get(0);
        }
    }

    private void retrieveEDMSpendAttendance(ID parentIABPId) {
        edmSpendAttendance = [
                SELECT Id, EDM_Event_Date_gne__c,
                        EDM_Planned_Attendee_HCP_Count_gne__c, EDM_Planned_Attendee_Other_Count_gne__c,
                        EDM_Meal_Total_gne__c, EDM_Actual_Attendee_HCP_Count_gne__c, EDM_Actual_Attendee_Other_Count_gne__c
                FROM EDM_Spend_Attendance_gne__c
                WHERE EDM_Parent_IABP_gne__c = :parentIABPId
        ];
        if (edmSpendAttendance.isEmpty()) {
            Date d = currentIABP.EDM_Start_Date_gne__c;
            if (d != null) {
                do {
                    edmSpendAttendance.add(createNewSpendAttendance(d, parentIABPId));
                    d = d.addDays(1);
                } while (d <= currentIABP.EDM_End_Date_gne__c);
            }
        } else {
            edmSpendAttendanceToRemove = new List<EDM_Spend_Attendance_gne__c>();

            for (EDM_Spend_Attendance_gne__c sa : edmSpendAttendance) {
                if (sa.EDM_Event_Date_gne__c < currentIABP.EDM_Start_Date_gne__c || sa.EDM_Event_Date_gne__c > currentIABP.EDM_End_Date_gne__c) {
                    edmSpendAttendanceToRemove.add(sa);
                }
            }

            Map<Date, EDM_Spend_Attendance_gne__c> edmSpendAttendanceByDate = new Map<Date, EDM_Spend_Attendance_gne__c>();
            for (EDM_Spend_Attendance_gne__c sa : edmSpendAttendance) {
                edmSpendAttendanceByDate.put(sa.EDM_Event_Date_gne__c, sa);
            }
            edmSpendAttendance.clear();

            Date d = currentIABP.EDM_Start_Date_gne__c;
            if (d != null) {
                do {
                    if (!edmSpendAttendanceByDate.containsKey(d)) {
                        edmSpendAttendance.add(createNewSpendAttendance(d, parentIABPId));
                    } else {
                        edmSpendAttendance.add(edmSpendAttendanceByDate.get(d));
                    }
                    d = d.addDays(1);
                } while (d <= currentIABP.EDM_End_Date_gne__c);
            }
        }
    }

    private EDM_Spend_Attendance_gne__c createNewSpendAttendance(Date d, Id parentIABPId) {
        return new EDM_Spend_Attendance_gne__c(
                EDM_Event_Date_gne__c = d,
                EDM_Parent_IABP_gne__c = parentIABPId,
                EDM_Planned_Attendee_HCP_Count_gne__c = 0,
                EDM_Planned_Attendee_Other_Count_gne__c = 0,
                EDM_Meal_Total_gne__c = 0,
                EDM_Actual_Attendee_HCP_Count_gne__c = 0,
                EDM_Actual_Attendee_Other_Count_gne__c = 0);
    }

    private void readSpendInfoFromVDST() {
        String jsonString = VDST_API.readEventSpendData(currentIABP.Name);
        System.debug('readSpendInfoFromVDST JSON: ' + jsonString);
        spend = new Spend(currentIABP, edmSpendAttendance, parseStringToEventReadWrapper(jsonString));
    }

    private void initVenueForVirtual() {
        if (isVirtualVenue(currentIABP)) {
            currentIABP.EDM_City_gne__c = 'South San Francisco';
            currentIABP.EDM_Venue_gne__c = 'Virtual';
            currentIABP.EDM_State_gne__c = 'California';
            currentIABP.EDM_Country_gne__c = 'United States';
            currentIABP.EDM_Zip_gne__c = '94080';
        }
    }

    private void getParticipantsFromExeSum() {
        participants = EDM_IABP_Utils.unwrapAttendeesWrapper(EDM_IABP_Utils.populateAdvisors(currentIABP.Id));
    }

    public EDM_Attachment_gne__c getAttachment() {
        List<EDM_Attachment_gne__c> attachs = [SELECT Id, Name, EDM_Link_gne__c FROM EDM_Attachment_gne__c WHERE EDM_Parent_IABP_gne__c = :currentIABP.Id and EDM_System_Type_gne__c = 'Spend'];

        return attachs.isEmpty() ? new EDM_Attachment_gne__c() : attachs.get(0);
    }

    public Boolean getIsContentOrLogisticsUser() {
        return EDM_ABM_Utils.hasPermissionSet(EDM_ABM_Utils.VDST_ABM);
    }

    public Boolean getIsGeneUser() {
        return !getIsContentOrLogisticsUser();
    }

    public Boolean getIsABMSuperUser() {
        return EDM_ABM_Utils.hasPermissionSet(EDM_ABM_Utils.ABS);
    }

    public Boolean getIsAblUser() {
        return EDM_ABM_Utils.hasPermissionSet(EDM_ABM_Utils.ABLEAD) || EDM_ABM_Utils.hasPermissionSet(EDM_ABM_Utils.VDST_ABM);
    }

    public String getCurrentSpendStatusWithModDate() {
        if (edmSpend.EDM_Spend_Status_gne__c != null) {
            return edmSpend.EDM_Spend_Status_gne__c + '&emsp;' + (edmSpend.LastModifiedDate != null ? edmSpend.LastModifiedDate.format() : '');
        }
        return null;
    }

    public Integer getPlannedAttendeeCount() {
        Integer total = 0;
        for (EDM_Spend_Attendance_gne__c sa : edmSpendAttendance) {
            Integer plannedHCP = sa.EDM_Planned_Attendee_HCP_Count_gne__c != null ? sa.EDM_Planned_Attendee_HCP_Count_gne__c.intValue() : 0;
            Integer plannedOther = sa.EDM_Planned_Attendee_Other_Count_gne__c != null ? sa.EDM_Planned_Attendee_Other_Count_gne__c.intValue() : 0;
            if (total < plannedHCP + plannedOther) {
                total = plannedHCP + plannedOther;
            }
        }
        System.debug('plannedAttendeeCount = ' + total);
        return total;
    }

    public PageReference save() {
        /*if (!spend.validateDailyMeals()) {
            return null;
        }*/
        Savepoint sp = Database.setSavepoint();
        try {
            if (!getIsNonHCPEvent()) {
                if (!currentIABP.EDM_Canceled_gne__c || (currentIABP.EDM_Canceled_gne__c && edmSpend.EDM_Cancellation_Type_gne__c == 'Cancel w/ Spend')) {
                    spend.sendEventToVDST(currentIABP, getAggsSpendStatus(spendStatusToSet), getPlannedAttendeeCount(), getNonVendorABLeadExternalId());
                }
            }

            edmSpend.EDM_Spend_Status_gne__c = spendStatusToSet;

            financials.save();
            suppressEDMSpendDuplicates();
            upsert edmSpend;

            suppressEdmSpendAttendanceDuplicates();
            upsert edmSpendAttendance;

            upsert currentIABP;
            retrieveEDMSpend(currentIABP.Id);
        } catch (SpendException e) {
            Database.rollback (sp);
            System.debug('Failed on save Spend:' + e.getMessage());
            if (currentIABP.EDM_Canceled_gne__c && edmSpend.EDM_Cancellation_Type_gne__c == 'Cancel w/ Spend') {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please use following link to fill the required fields on IABP: <a style="font-weight:bold" href="' + getLinkToEditIABP() + '">Update Canceled IABP</a>'));
            }
        } catch (Exception e) {
            Database.rollback (sp);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
        }

        if (goBackAfterSave != null && goBackAfterSave && !Apexpages.hasMessages(ApexPages.Severity.ERROR)) {
            return goBack();
        }

        if (!getIsNonHCPEvent()) {
            readSpendInfoFromVDST();
        }

        if (edmSpendAttendanceToRemove != null) {
            delete edmSpendAttendanceToRemove;
        }

        return null;
    }

    @TestVisible
    private void suppressEDMSpendDuplicates() {
        if (edmSpend.Id == null) {
            List<EDM_Spend_gne__c> edmSpends = EDM_Spend_Utils.retrieveEDMSpend(edmSpend.EDM_Parent_IABP_gne__c);
            if (!edmSpends.isEmpty()) {
                edmSpend.Id = edmSpends.get(0).Id;
            }
        }
    }

    @TestVisible
    private void suppressEdmSpendAttendanceDuplicates() {
        List<EDM_Spend_Attendance_gne__c> existingEdmSpendAttendance = [
                SELECT Id, EDM_Event_Date_gne__c
                FROM EDM_Spend_Attendance_gne__c
                WHERE EDM_Parent_IABP_gne__c = :edmSpend.EDM_Parent_IABP_gne__c
        ];
        if (!existingEdmSpendAttendance.isEmpty()) {
            Map<Date, EDM_Spend_Attendance_gne__c> existingEdmSpendAttendanceByDate = new Map<Date, EDM_Spend_Attendance_gne__c>();
            for (EDM_Spend_Attendance_gne__c rec : existingEdmSpendAttendance) {
                existingEdmSpendAttendanceByDate.put(rec.EDM_Event_Date_gne__c, rec);
            }

            for (EDM_Spend_Attendance_gne__c rec : edmSpendAttendance) {
                if (rec.Id == null && existingEdmSpendAttendanceByDate.containsKey(rec.EDM_Event_Date_gne__c)) {
                    rec.Id = existingEdmSpendAttendanceByDate.get(rec.EDM_Event_Date_gne__c).Id;
                }
            }
        }
    }

    public PageReference reopenAndEdit() {
        Savepoint sp = Database.setSavepoint();
        try {
            if (!getIsNonHCPEvent()) {
                if (!currentIABP.EDM_Canceled_gne__c || (currentIABP.EDM_Canceled_gne__c && edmSpend.EDM_Cancellation_Type_gne__c == 'Cancel w/ Spend')) {
                    spend.sendEventToVDST(currentIABP, getAggsSpendStatusForReopen(), getPlannedAttendeeCount(), getNonVendorABLeadExternalId());
                }
            }

            edmSpend.EDM_Spend_Status_gne__c = 'Save';
            upsert edmSpend;
        } catch (SpendException e) {
            Database.rollback (sp);
            System.debug('Failed on reopenAndEdit Spend:' + e.getMessage());
        } catch (Exception e) {
            Database.rollback (sp);
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
        }

        if (!Apexpages.hasMessages(ApexPages.Severity.ERROR)) {
            PageReference pr = Page.EDM_Spend_Edit_Create;
            pr.getParameters().put('id', currentIABP.Id);
            pr.setRedirect(true);
            return pr;
        }

        return null;
    }

    public PageReference goBack() {
        PageReference pr = new PageReference('/apex/EDM_AABP_Layout?id=' + currentIABP.EDM_Parent_AABP_gne__c);
        pr.setRedirect(true);
        return pr;
    }

    public PageReference initParticipantPopup() {
        currentAttendeeId = System.currentPagereference().getParameters().get('attendeeId');
        participant = new EDM_Spend_Participant(currentAttendeeId, spend.dailyMeals);
        return null;
    }

    public PageReference saveParticipantPopup() {
        if (edmSpend.Id == null || String.isBlank(spend.currentStatus)) {
            goBackAfterSave = false;
            spendStatusToSet = 'Save';
            save();
        }

        if (participant.saveToVDST(currentIABP.Name)) {
            readSpendInfoFromVDST();
            participant = new EDM_Spend_Participant(currentAttendeeId, spend.dailyMeals);
        }

        return null;
    }

    public List<SelectOption> getNumberOfMealsSelectOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('1 meal/break', '1 meal/break'));
        options.add(new SelectOption('2 meals/break', '2 meals/break'));
        options.add(new SelectOption('3 meals/break', '3 meals/break'));
        return options;
    }

    public List<SelectOption> getMealStatusSelectOptions() {
        List<SelectOption> options = new List<SelectOption>();
        //options.add(new SelectOption('','Please Choose'));
        options.add(new SelectOption('CONSUMED', 'Consumed'));
        options.add(new SelectOption('NOMLPRVD', 'No Meal'));
        return options;
    }

    public List<SelectOption> getFeePaidToSelectOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Individual', 'Individual'));
        options.add(new SelectOption('Organization', 'Organization'));
        return options;
    }

    public List<SelectOption> getCancellationTypes() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Cancel w/ Spend', 'Cancel w/ Spend'));
        options.add(new SelectOption('Cancel w/o Spend', 'Cancel w/o Spend'));
        return options;
    }

    public List<SelectOption> getCountries() {
        List<SelectOption> countries = new List<SelectOption>();
        countries.add(new SelectOption('', '--None--'));
        for (String country : EDM_IABP_Utils.getCountries()) {
            countries.add(new SelectOption(country, country));
        }
        return countries;
    }

    public List<SelectOption> getStates() {
        List<SelectOption> states = new List<SelectOption>();
        states.add(new SelectOption('', '--None--'));
        for (String state : EDM_IABP_Utils.getUSStates()) {
            states.add(new SelectOption(state, state));
        }
        return states;
    }

    public List<SelectOption> getProvinces() {
        List<SelectOption> provinces = new List<SelectOption>();
        provinces.add(new SelectOption('', '--None--'));
        for (String province : EDM_IABP_Utils.getCanadianProvinces()) {
            provinces.add(new SelectOption(province, province));
        }
        return provinces;
    }

    private static Boolean isVirtualVenue(EDM_IABP_gne__c iabp) {
        return iabp.EDM_Meeting_Approach_gne__c != 'Face to Face';
    }

    public PageReference closeDownloadDocuments() {
        return null;
    }

    public String getNonVendorABLeadName() {
        return nonVendorABLead.Name;
    }

    public String getNonVendorABLeadExternalId() {
        return nonVendorABLead.External_Id_gne__c;
    }

    public PageReference startDownloadDocuments() {
        downloadDocumentsStarted = true;
        sessionIDForDrawLoop = UserInfo.getSessionId();
        return null;
    }

    public String getZipPostalCode() {
        return (String.isNotBlank(currentIABP.EDM_Zip_gne__c) ? currentIABP.EDM_Zip_gne__c : spend.zipPostalCode);
    }

    public Boolean getIsNonHCPEvent() {
        return (participants == null || participants.isEmpty());
    }

    public Boolean getIsIAdviseEvent() {
        return currentIABP.EDM_Meeting_Approach_gne__c == 'iAdvise';
    }

    public class Financials {
        public List<EDM_Spend_Financial_gne__c> items { get; set; }
        private Id parentIABPId;

        public Financials(Id parentIABPId) {
            this.parentIABPId = parentIABPId;
            items = retrieve(parentIABPId);
            if (items.isEmpty()) {
                insertDefautls(parentIABPId);
            }
        }

        private List<EDM_Spend_Financial_gne__c> retrieve(Id parentIABPId) {
            return [
                    SELECT Id, EDM_Type_gne__c, EDM_Total_Cost_gne__c, EDM_OverheadFees_gne__c,
                            EDM_HCP_Fees_gne__c, EDM_Hotel_gne__c, EDM_Meals_gne__c, EDM_Travel_gne__c
                    FROM EDM_Spend_Financial_gne__c
                    WHERE EDM_Parent_IABP_gne__c = :parentIABPId
                    ORDER BY EDM_Type_gne__c
            ];
        }


        private void insertDefautls(Id parentIABPId) {
            items.add(
                    new EDM_Spend_Financial_gne__c(EDM_Parent_IABP_gne__c = parentIABPId, EDM_Type_gne__c = 'Content'));
            items.add(
                    new EDM_Spend_Financial_gne__c(EDM_Parent_IABP_gne__c = parentIABPId, EDM_Type_gne__c = 'Logistics'));
            items.add(
                    new EDM_Spend_Financial_gne__c(EDM_Parent_IABP_gne__c = parentIABPId, EDM_Type_gne__c = 'Genentech'));
        }

        public void save() {
            List<EDM_Spend_Financial_gne__c> existingItems = retrieve(parentIABPId);

            for (EDM_Spend_Financial_gne__c fin : items) {
                //fin.EDM_Unique_Idx_gne__c = fin.EDM_Parent_IABP_gne__c + '#' + fin.EDM_Type_gne__c;
                if (fin.Id == null && !existingItems.isEmpty()) {
                    suppressDuplicates(fin, existingItems);
                }
            }

            upsert items;
        }

        private void suppressDuplicates(EDM_Spend_Financial_gne__c fin, List<EDM_Spend_Financial_gne__c> existingItems) {
            for (EDM_Spend_Financial_gne__c existingItem : existingItems) {
                if (existingItem.EDM_Type_gne__c == fin.EDM_Type_gne__c) {
                    fin.Id = existingItem.Id;
                    break;
                }
            }
        }

        public Decimal getTotalAdvisoryBoardCost() {
            Decimal total = 0;
            for (EDM_Spend_Financial_gne__c fin : items) {
                if (fin.EDM_Total_Cost_gne__c != null) {
                    total += fin.EDM_Total_Cost_gne__c;
                }
            }
            return total;
        }
    }

    private String getAggsSpendStatusForReopen() {
        return currentIABP.EDM_Canceled_gne__c ? 'CANCEL' : 'OCCURRED';
    }

    private String getAggsSpendStatus(String newEdmSpendStatus) {
        if (newEdmSpendStatus == 'Save & Finalize') {
            return currentIABP.EDM_Canceled_gne__c ? 'CANCEL' : 'CLOSED';

        }
        if (String.isBlank(Spend.currentStatus)) {
            return currentIABP.EDM_Canceled_gne__c ? 'CANCEL' : 'PENDING';
        }
        return Spend.currentStatus;
    }

    public class Spend {
        public String currentStatus { get; set; }
        public String canceledSpendType { get; set; }

        public Boolean virtualVenue { get; set; }
        public String zipPostalCode { get; set; }

        public String logisticsVendorCode { get; set; }
        public String contentVendorCode { get; set; }

        public List<DailyMeals> dailyMeals { get; set; }

        public HcpEventSpend hcpEventSpend { get; set; }

        public String comment { get; set; }

        public Spend(EDM_IABP_gne__c currentIABP) {
            dailyMeals = new List<DailyMeals>();

            this.virtualVenue = isVirtualVenue(currentIABP);
            initVendorCodes(currentIABP);
        }

        public Spend(EDM_IABP_gne__c currentIABP, List<EDM_Spend_Attendance_gne__c> edmSpendAttendance, JsonEventReadWrapper parsedJSON) {
            this(currentIABP);
            this.currentStatus = parsedJSON.event_status;
            this.hcpEventSpend = new HcpEventSpend(parsedJSON.summary_spends);
            this.zipPostalCode = parsedJSON.address_zip;

            initDailyMeals(currentIABP, edmSpendAttendance, parsedJSON);
        }

        public void initDailyMeals(EDM_IABP_gne__c currentIABP, List<EDM_Spend_Attendance_gne__c> edmSpendAttendance, JsonEventReadWrapper parsedJSON) {
            if (parsedJSON.event_spends != null) {

                Map<Date, EDM_Spend_Attendance_gne__c> edmSpendAttendanceByDate = new Map<Date, EDM_Spend_Attendance_gne__c>();
                Map<Date, DailyMeals> dailyMealsMap = new Map<Date, DailyMeals>();
                for (EDM_Spend_Attendance_gne__c sa : edmSpendAttendance) {
                    edmSpendAttendanceByDate.put(sa.EDM_Event_Date_gne__c, sa);
                }

                for (EventSpends eventSpend : parsedJSON.event_spends) {
                    if (edmSpendAttendanceByDate.containsKey(eventSpend.spend_date)) {
                        dailyMealsMap.put(eventSpend.spend_date, new DailyMeals(eventSpend, edmSpendAttendanceByDate.get(eventSpend.spend_date)));
                        edmSpendAttendanceByDate.remove(eventSpend.spend_date);
                    }
                }
                for (EDM_Spend_Attendance_gne__c sa : edmSpendAttendanceByDate.values()) {
                    dailyMealsMap.put(sa.EDM_Event_Date_gne__c, new DailyMeals(sa.EDM_Event_Date_gne__c, sa));
                }
                for (EDM_Spend_Attendance_gne__c sa : edmSpendAttendance) {
                    if (dailyMealsMap.get(sa.EDM_Event_Date_gne__c) != null) {
                        dailyMeals.add(dailyMealsMap.get(sa.EDM_Event_Date_gne__c));
                    }
                }
            } else {
                for (EDM_Spend_Attendance_gne__c sa : edmSpendAttendance) {
                    dailyMeals.add(new DailyMeals(sa.EDM_Event_Date_gne__c, sa));
                }
            }
        }

        /*public Boolean validateDailyMeals() {
            Boolean valid = true;
            for (DailyMeals dailyMeal : dailyMeals) {
                if (dailyMeal.actualAttendeeConsumedCount.other > dailyMeal.actualAttendeeAttendedCount.other) {
                    dailyMeal.errorMsg = 'Consumed - Other cannot be greater than Attended - Other';
                    valid = false;
                } else {
                    dailyMeal.errorMsg = '';
                }
            }
            if (!valid) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Daily Meal Amounts and Attendance: Actual Attendee Count: Consumed - Other cannot be greater than Attended - Other'));
            }
            return valid;
        }*/

        private void initVendorCodes(EDM_IABP_gne__c currentIABP) {
            if (String.isBlank(currentIABP.EDM_Log_Vendor_Company_Name_gne__c)) {
                currentIABP.EDM_Log_Vendor_Company_Name_gne__c = 'Genentech';
                logisticsVendorCode = 'GNE';
            } else {
                logisticsVendorCode = getVendorCodeByName(
                        EDM_ABM_Utils.getLogisticVendors(),
                        currentIABP.EDM_Log_Vendor_Company_Name_gne__c);
            }

            if (String.isBlank(currentIABP.EDM_Cont_Vendor_Company_Name_gne__c)) {
                currentIABP.EDM_Cont_Vendor_Company_Name_gne__c = 'Genentech';
                contentVendorCode = 'GNE';
            } else if (currentIABP.EDM_Cont_Vendor_Company_Name_gne__c == 'Genentech') {
                contentVendorCode = 'GNE'; // GNE exists only in Logistic Vendors map
            } else {
                contentVendorCode = getVendorCodeByName(
                        EDM_ABM_Utils.getContentVendors(),
                        currentIABP.EDM_Cont_Vendor_Company_Name_gne__c);
            }
        }

        private String getVendorCodeByName(List<VDST_EventProvider_gne__c> vendors, String vendorName) {
            for (VDST_EventProvider_gne__c vendor : vendors) {
                if (vendor.VendorName_gne__c == vendorName) {
                    return vendor.VendorCode_gne__c;
                }
            }
            return null;
        }

        public void sendEventToVDST(EDM_IABP_gne__c currentIABP, String aggsSpendStatus, Integer plannedAttendeeCount, String accountable_unix_id) {
            System.debug('sendEventToVDST dailyMeals: ' + dailyMeals);
            String eventWrapperJSON = System.JSON.serialize(toJsonEventWrapper(currentIABP, aggsSpendStatus, plannedAttendeeCount, accountable_unix_id));
            System.debug('sendEventToVDST JSON: ' + eventWrapperJSON);
            String results = VDST_API.sendEventJSON(eventWrapperJSON);
            System.debug('sendEventToVDST result: ' + results);
            if (results != 'OK') {
                //ErrorWrapper errorWrp = parseStringToErrorWrapper(results);
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, results));
                throw new SpendException(results);
            }
        }

        private JsonEventWrapper toJsonEventWrapper(EDM_IABP_gne__c currentIABP, String aggsSpendStatus, Integer plannedAttendeeCount, String accountable_unix_id) {
            JsonEventWrapper result = new JsonEventWrapper();
            result.isValidation = false;
            result.abm_event_id = currentIABP.Name;
            result.event_status = aggsSpendStatus;
            result.event_spends = new List<EventSpends>();

            for (DailyMeals dailyMeal : dailyMeals) {
                result.event_spends.add(new EventSpends(dailyMeal));
            }

            result.logistic_vendor = String.isBlank(currentIABP.EDM_Log_Vendor_Company_Name_gne__c) ? 'Genentech' : currentIABP.EDM_Log_Vendor_Company_Name_gne__c;
            result.content_vendor = String.isBlank(currentIABP.EDM_Cont_Vendor_Company_Name_gne__c) ? 'Genentech' : currentIABP.EDM_Cont_Vendor_Company_Name_gne__c;
            result.accountable_unix_id = accountable_unix_id;
            result.genentech_event_id = currentIABP.Id;
            result.meeting_name = currentIABP.EDM_Event_Name_gne__c;
            if (currentIABP.EDM_Brand_gne__c != null) {
                result.brands = currentIABP.EDM_Brand_gne__c.replace(';', ',');
            }
            result.event_start_date = currentIABP.EDM_Start_Date_gne__c;
            result.event_end_date = currentIABP.EDM_End_Date_gne__c;
            result.invitation_sent_date = currentIABP.EDM_End_Date_gne__c;
            result.planned_attendee_count = plannedAttendeeCount;

            result.address_type = isVirtualVenue(currentIABP);
            result.address_venue_name = currentIABP.EDM_Venue_gne__c;
            result.address_country = currentIABP.EDM_Country_gne__c;
            result.address_street = currentIABP.EDM_Venue_gne__c; //TODO
            result.address_city = currentIABP.EDM_City_gne__c;
            result.address_state = currentIABP.EDM_State_gne__c;
            //we have to handle with old iabp without zip
            result.address_zip = (String.isNotBlank(currentIABP.EDM_Zip_gne__c) ? currentIABP.EDM_Zip_gne__c : this.zipPostalCode);

            System.debug(result.accountable_unix_id);

            return result;
        }
    }

    public class DailyMeals {
        public Date eventDate { get; set; }
        public String numberOfMeals { get; set; }
        public AttendeeCount actualAttendeeAttendedCount {
            get;
            set {
                actualAttendeeAttendedCount = value;
                actualAttendeeConsumedCount = value;
                system.debug('testPP: ' + actualAttendeeAttendedCount + ' ' + actualAttendeeConsumedCount);
            }
        }
        public AttendeeCount actualAttendeeConsumedCount { get; set; }

        //Yousuf: Business (EDM - Ad Board and Speaker Bureau) and AGGS (Jenna) looked at the Sunshine needs closely and
        // determined that Planned Attendee Counts will be needed on a daily basis in the future.
        // gSSP ( and downstream) is not yet ready to consume this information but may tackle this issue later on this year
        // through another project. We (ABM) would like to account for it on the Spend side so that ABM is ready to send
        // this info to gSSP when the changes are made there.
        public EDM_Spend_Attendance_gne__c edmSpendAttendanceRec { get; set; }
        public AttendeeCount plannedAttendeeCount { get; set; }

        public String errorMsg { get; set; }

        public DailyMeals(Date eventDate, EDM_Spend_Attendance_gne__c edmSpendAttendanceRec) {
            this.eventDate = eventDate;
            this.numberOfMeals = null;
            this.plannedAttendeeCount = new AttendeeCount(0, 0);
            this.actualAttendeeAttendedCount = new AttendeeCount(0, 0);
            this.actualAttendeeConsumedCount = new AttendeeCount(0, 0);
            this.edmSpendAttendanceRec = edmSpendAttendanceRec;
            this.errorMsg = '';
        }

        public DailyMeals(EventSpends eventSpends, EDM_Spend_Attendance_gne__c edmSpendAttendanceRec) {
            this.eventDate = eventSpends.spend_date;
            this.numberOfMeals = eventSpends.number_of_meals;

            this.plannedAttendeeCount = new AttendeeCount(0, 0);
            this.actualAttendeeAttendedCount = new AttendeeCount(eventSpends.hcp_actual_attendee_count, eventSpends.nonHcp_actual_attendee_count);
            this.actualAttendeeConsumedCount = new AttendeeCount(eventSpends.hcp_actual_consumed_count, eventSpends.nonHcp_actual_consumed_count);
            this.edmSpendAttendanceRec = edmSpendAttendanceRec;
            this.edmSpendAttendanceRec.EDM_Meal_Total_gne__c = eventSpends.amount;
            this.edmSpendAttendanceRec.EDM_Actual_Attendee_HCP_Count_gne__c = eventSpends.hcp_actual_attendee_count;
            this.edmSpendAttendanceRec.EDM_Actual_Attendee_Other_Count_gne__c = eventSpends.nonHcp_actual_attendee_count;
            this.errorMsg = '';
        }
    }

    public class AttendeeCount {
        public Integer hcps { get; set; }
        public Integer other { get; set; }

        public AttendeeCount(Integer hcps, Integer other) {
            this.hcps = hcps;
            this.other = other;
        }
    }

    enum SummarySpendsType {
        EVTMEALS, TOTALEVENT, EVTOOP, EVTHCPTRVL, HOTEL, EVTFEES
    }

    public class HcpEventSpend {
        public Map<String, Decimal> summarySpends { get; set; }

        public HcpEventSpend(List<EventSummary> vdst_summary_spends) {
            summarySpends = new Map<String, Decimal>();

            for (SummarySpendsType sumSpendtype : SummarySpendsType.values()) {
                summarySpends.put(sumSpendtype.name(), 0);
            }

            if (vdst_summary_spends != null) {
                for (EventSummary sum_spend : vdst_summary_spends) {
                    summarySpends.put(sum_spend.code, sum_spend.amount);
                }
            }
        }
    }

    public class HelpText {
        public Map<String, String> body { get; private set; }
        public String keys { get; private set; }

        public HelpText() {
            body = new Map<String, String>();
            keys = '';
            populateHelpTextMap();
        }

        private void populateHelpTextMap() {
            Map<String, EDM_Spend_Help_Text_gne__c> helpTextsMap = EDM_Spend_Help_Text_gne__c.getAll();
            List<String> keyList = new List<String>();
            for (EDM_Spend_Help_Text_gne__c item : helpTextsMap.values()) {
                body.put(item.Name, item.EDM_Help_Text_Body_gne__c);
            }
            keys = String.join(new List<String>(body.keySet()), ';');
        }
    }

    // Event Read Wrapper
    virtual class JsonEventReadWrapper {
        // Read Data
        String abm_event_id { get; set; }

        String event_status { get; set; }
        List<EventSpends> event_spends { get; set; }
        List<EventSummary> summary_spends { get; set; } // Only Read
        String address_zip { get; set; }
    }

    // Event Write Wrapper
    class JsonEventWrapper extends JsonEventReadWrapper {
        // Flags
        Boolean isValidation { get; set; }
        // Fields for Upsert only
        String logistic_vendor { get; set; }
        String content_vendor { get; set; }
        String accountable_unix_id { get; set; }
        String genentech_event_id { get; set; }
        String meeting_name { get; set; }
        String brands { get; set; }
        Date event_start_date { get; set; }
        Date event_end_date { get; set; }
        Date invitation_sent_date { get; set; }
        Boolean address_type { get; set; }
        String address_venue_name { get; set; }
        String address_country { get; set; }
        String address_street { get; set; }
        String address_city { get; set; }
        String address_state { get; set; }

        Integer planned_attendee_count { get; set; }
    }

    class EventSpends {
        Date spend_date { get; set; }
        Decimal amount { get; set; }
        String number_of_meals { get; set; }
        Integer nonHcp_actual_attendee_count { get; set; }
        Integer nonHcp_actual_consumed_count { get; set; }
        Integer hcp_actual_attendee_count { get; set; } // Read Only
        Integer hcp_actual_consumed_count { get; set; } // Read Only

        public EventSpends(DailyMeals dailyMeals) {
            this.spend_date = dailyMeals.eventDate;
            this.amount = dailyMeals.edmSpendAttendanceRec.EDM_Meal_Total_gne__c;
            this.amount = this.amount != null ? this.amount : 0;
            if (this.amount != 0) {
                this.number_of_meals = dailyMeals.numberOfMeals;
            }

            Integer actAttOthCount = (dailyMeals.edmSpendAttendanceRec.EDM_Actual_Attendee_Other_Count_gne__c != null ?
                    dailyMeals.edmSpendAttendanceRec.EDM_Actual_Attendee_Other_Count_gne__c.intValue() : 0);

            //this.nonHcp_actual_attendee_count = dailyMeals.actualAttendeeAttendedCount.other;
            this.nonHcp_actual_attendee_count = actAttOthCount;

            //this.nonHcp_actual_consumed_count = dailyMeals.actualAttendeeConsumedCount.other;

            //this.nonHcp_actual_consumed_count = dailyMeals.actualAttendeeAttendedCount.other;
            this.nonHcp_actual_consumed_count = actAttOthCount;
        }
    }

    class EventSummary {
        String code { get; set; }
        Decimal amount { get; set; }
    }

    private static JsonEventReadWrapper parseStringToEventReadWrapper(String jsonString) {
        return (JsonEventReadWrapper) System.JSON.deserialize(jsonString, JsonEventReadWrapper.class);
    }

    // Error Wrapper
    class ErrorWrapper {
        String errorMsg { get; set; }
    }

    private static ErrorWrapper parseStringToErrorWrapper(String jsonString) {
        return (ErrorWrapper) System.JSON.deserialize(jsonString, ErrorWrapper.class);
    }

    private class SpendException extends Exception {
    }

}