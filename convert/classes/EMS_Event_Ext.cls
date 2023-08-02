public without sharing class EMS_Event_Ext extends EMS_DynamicVFLoader {

    // **** STATIC VARIABLES **** //
    private static Set<String> subtypesWithGDCommitteeApproval = new Set<String>{
            'Grant / Patient Organization',
            'Institutional/Organizational/Foundation Donations',
            'Donation / Patient Association',
            'Philanthropic Donation'
    };

    public List<SelectOption> learningProgramPicklist {
        get {
            if(learningProgramPicklist == null) {
                learningProgramPicklist = new List<SelectOption>{
                        new SelectOption('', '--Select--')
                };

                Boolean valueFound = false;
                for(EMS_Learning_Program__c program : [
                        SELECT Id, Name
                        FROM EMS_Learning_Program__c
                        WHERE Is_Active__c = TRUE
                ]) {
                    valueFound |= program.Name == event.Learning_Program__c;
                    learningProgramPicklist.add(new SelectOption(program.Name, program.Name));
                }

                if(valueFound == false && String.isNotBlank(event.Learning_Program__c)) {
                    learningProgramPicklist.add(new SelectOption(event.Learning_Program__c, event.Learning_Program__c));
                }
            }
            return learningProgramPicklist;
        }
        private set;
    }

    public static List<SelectOption> defaultProvincePicklist {
        get {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('', '--Select--'));
            for (Schema.PicklistEntry f : EMS_Event__c.Province_gne__c.getDescribe().getPicklistValues()) {
                options.add(new SelectOption(f.getValue(), f.getLabel()));
            }
            return options;
        }
    }

    private static EMS_GSD_Event_Types_gne__c eventGSDCustomSetting {
        get {
            return EMS_GSD_Event_Types_gne__c.getInstance();
        }
    }

    private static Map<String, List<String>> provinceToCitiesMap {
        get {
            Map<String, List<String>> result = new Map<String, List<String>>();
            for (EMS_City_To_Province_Mapping_gne__c mapping : [SELECT Province_gne__c, City_gne__c FROM EMS_City_To_Province_Mapping_gne__c ORDER BY Order_gne__c NULLS LAST, City_gne__c LIMIT 30000]) {
                if (result.containsKey(mapping.Province_gne__c)) {
                    List<String> temp = result.get(mapping.Province_gne__c);
                    temp.add(mapping.City_gne__c);
                    result.put(mapping.Province_gne__c, temp);
                } else {
                    result.put(mapping.Province_gne__c, new List<String>{
                            mapping.City_gne__c
                    });
                }
            }
            return result;
        }
    }

    // **** LISTS **** //
    public List<sObject> approvalHistoryRecords { get; set; }

    public List<SelectOption> requestorTerritories { get; set; }
    public List<SelectOption> ownerTerritories { get; set; }

    public List<ComplianceRecord> complianceChecklists { get; set; } // checkboxes on the sidebar - Old compliance checklist pop up window
    public List<EMS_Checklist_gne__c> complianceNotes { get; set; } // notes

    public List<ProcessInstance> processInstanceList { get; set; }

    private List<EMS_Budget_Allocation_gne__c> budgetAllocations {
        get {
            if (budgetAllocations == null) {
                budgetAllocations = new List<EMS_Budget_Allocation_gne__c>();
            }
            return budgetAllocations;
        }
        set;
    }

    private List<EMS_Possible_Budget_Allocation_gne__c> possibleBudgetAllocations {
        get {
            if (possibleBudgetAllocations == null) {
                possibleBudgetAllocations = [
                        SELECT GSD_Type_gne__c, EMS_Event_Configuration_gne__r.Event_Type_gne__c
                        FROM EMS_Possible_Budget_Allocation_gne__c
                        WHERE (EMS_Event_Configuration_gne__r.Event_Type_gne__c = :event.Event_Type_gne__c
                        AND EMS_Event_Configuration_gne__r.Event_Sub_Type_gne__c = :event.Event_Sub_Type_gne__c)
                        OR EMS_Event_Configuration_gne__r.Event_Type_gne__c = 'Sponsorships'
                ];
            }
            return possibleBudgetAllocations;
        }
        set;
    }

    public List<EMS_Budget_Allocation_gne__c> budgetAllocationsToApprove { get; set; }
    public List<EMS_Budget_Allocation_gne__c> budgetAllocationsToRecall { get; set; }

    // **** MAPS **** //
    public Map<Id, Id> budgetallocationProcessInstanceWorkItems { get; set; }

    private Map<Id, EMS_Checklist_Response_gne__c> checklistResponses { get; set; }

    // **** SETS **** //
    private Set<Id> budgetSubmitters {
        get {
            if (budgetSubmitters == null) {
                budgetSubmitters = new Set<Id>();
            }
            return budgetSubmitters;
        }
        set;
    }
    private Set<Id> budgetApprovers {
        get {
            if (budgetApprovers == null) {
                budgetApprovers = new Set<Id>();
            }
            return budgetApprovers;
        }
        set;
    }

    // **** OBJECTS AND IDS **** //
    public EMS_Event__c event { get; set; }
    public EMS_GSD_Detail__c gsdDetail { get; set; }
    public EMS_Event_Configuration_gne__c eventConfiguration { get; private set; }

    public Id processInstanceWorkitemId { get; set; }
    private Id submittedBy { get; set; }

    // **** FLAGS **** //
    public Boolean isUserBudgetSubmiter { get {return budgetSubmitters.contains(UserInfo.getUserId());} }
    public Boolean isUserBudgetApprover { get {return budgetApprovers.contains(UserInfo.getUserId());} }
    public Boolean isUserEventSubmiter { get {return submittedBy == UserInfo.getUserId();} }
    public Boolean isUserAdmin { get { return EMS_Access.isAdmin(); } }

    public Boolean showApproveAllocations { get {return !budgetAllocationsToApprove.isEmpty();} }
    public Boolean showRecallAllocations { get {return !budgetAllocationsToRecall.isEmpty();} }

    // **** STRINGS **** //
    public String pageErrorMessage { get; set; }

    public String submitButtonLabel { get {return eventConfiguration.Submit_to_Approval_Label_gne__c;} }
    public String approvalAction { get; set; }
    public String approvalComment { get; set; }

    public String eventJSON {
        get {
            return JSON.serialize(event);
        }
    }

    public String provinceToCitiesJSON {
        get {
            return JSON.serialize(provinceToCitiesMap);
        }
    }

    // **** OTHER **** //
    private ApexPages.StandardController stdController;

    // **** CONSTRUCTOR **** //
    public EMS_Event_Ext(ApexPages.StandardController controller) {
        super(controller, '/apex/EMS_Event_Layout');
        stdController = controller;
        event = getEventByID(stdController.getId());
        if (String.isBlank(event.RecordTypeId)) {
            event.RecordTypeId = EMS_Event__c.getSObjectType().getDescribe().getRecordTypeInfosByName().get('EMS Event').getRecordTypeId();
        }

        // If "Event Requestor" is not editable, the requestor territory is visible on the page, though it is not saved to DB.
        requestorTerritories = getTerritories(event.Event_Requestor_gne__c);
        if (requestorTerritories.size() == 1) {
            event.Assigned_To_Territory_Requestor_gne__c = requestorTerritories[0].getValue();
        }
        ownerTerritories = getTerritories(event.Event_Owner_gne__c);
        if (ownerTerritories.size() == 1) {
            event.Assigned_To_Territory_Owner_gne__c = ownerTerritories[0].getValue();
        }
        approvalHistoryRecords = new List<sObject>{
                event
        };
        budgetallocationProcessInstanceWorkItems = new Map<Id, Id>();
        budgetApprovers = new Set<Id>();
        budgetAllocationsToApprove = new List<EMS_Budget_Allocation_gne__c>();
        budgetAllocationsToRecall = new List<EMS_Budget_Allocation_gne__c>();
        eventConfiguration = getEventConfiguration();

        // Compliance Checklist & Responses
        preparesidebarChecklists();

        // this one is called from GNE_SFA2_DynamicVFLoader.cls
        init();

        loadGSDDetail();

        getBudgetAllocations();
        fetchApprovalProcessItems();
    }

    // **** GETTER METHODS **** //

    // Old Data Form
    public Boolean getOldDataFieldsVisible() {
        return EMS_Util.oldDataFieldsVisible(event.CreatedDate);
    }

    // Old Disturbance Fee Label in FMV Form
    public Boolean getOldDisturbanceFeeLabelVisible() {
        return EMS_Util.oldDisturbanceFeeLabel(event.CreatedDate);
    }

    // User Role
    public String getUserRole() {
        return EMS_Util.getUserRole();
    }

    // GSD
    public String getGSDAttributes() {
        return (String.isNotBlank(eventGSDCustomSetting.GSD_Events_names__c)) ? eventGSDCustomSetting.GSD_Events_names__c : '';
    }

    public String getCostCenterTypes() { // GSD type which are taken from related budgets only for Sponsorships events
        Set<String> types = new Set<String>();
        if (budgetAllocations != null && !budgetAllocations.isEmpty() && event.Event_Type_gne__c == 'Sponsorships') {
            for (EMS_Budget_Allocation_gne__c ba : budgetAllocations) {
                types.add(ba.Cost_Center_Type_gne__c);
            }
        }
        return JSON.serialize(types);
    }

    public String getAvailableGSDTypesSet() { // GSD type dropdown is used on EMS_GSD_Detail_Layout.page
        Set<String> types = new Set<String>();
        for (EMS_Possible_Budget_Allocation_gne__c pba : possibleBudgetAllocations) {
            if (String.isNotBlank(event.Event_Type_gne__c) && event.Event_Type_gne__c == pba.EMS_Event_Configuration_gne__r.Event_Type_gne__c && String.isNotBlank(pba.GSD_Type_gne__c)) {
                types.addAll(pba.GSD_Type_gne__c.split(';'));
            }
        }
        return JSON.serialize(types);
    }

    public String getSposorshipCostCenterTypes() { // Default GSD type values only for a Sponsorship event
        Set<String> types = new Set<String>();
        for (EMS_Possible_Budget_Allocation_gne__c pba : possibleBudgetAllocations) {
            if (pba.EMS_Event_Configuration_gne__r.Event_Type_gne__c == 'Sponsorships' && String.isNotBlank(pba.GSD_Type_gne__c)) {
                types.add(pba.GSD_Type_gne__c);
            }
        }
        return JSON.serialize(types);
    }

    // Requestor Territory
    private static List<SelectOption> getTerritories(Id personID) {
        return EMS_Util.getUserTerritorySelectOptions(personID);
    }

    // Event Details Fields
    private static EMS_Event__c getEventByID(Id eventID) {
        String soql = 'SELECT ';

        List<String> fields = new List<String>();
        for (String field : Schema.getGlobalDescribe().get('EMS_Event__c').getDescribe().fields.getMap().keySet()) {
            fields.add(field);
        }
        soql += String.join(fields, ',');
        soql += ',createdBy.name,lastmodifiedby.name,recordtype.name';
        soql += ' FROM EMS_Event__c WHERE Id = \'' + eventID + '\' LIMIT 1';
        return Database.query(soql);
    }

    private EMS_Event_Configuration_gne__c getEventConfiguration() {
        if (String.isBlank(event.Event_Type_gne__c) || String.isBlank(event.Event_Sub_Type_gne__c)) {
            return new EMS_Event_Configuration_gne__c();
        }
        List<EMS_Event_Configuration_gne__c> eventConfig = [
                SELECT Submit_to_Approval_Label_gne__c, Budget_Approval_Required_gne__c, Pending_Budget_Approval_Label_gne__c, Budget_Approved_Label_gne__c, AARC_Uploads_Contract_gne__c
                FROM EMS_Event_Configuration_gne__c
                WHERE Event_Type_gne__c = :event.Event_Type_gne__c AND Event_Sub_Type_gne__c = :event.Event_Sub_Type_gne__c
                LIMIT 1
        ];
        return (!eventConfig.isEmpty()) ? eventConfig[0] : new EMS_Event_Configuration_gne__c();
    }

    public List<SelectOption> getCities() {
        if (event.Country_gne__c != 'Canada' || event.Province_gne__c == null) {
            return new List<SelectOption>{
                    new SelectOption('', '--None--')
            };
        }

        List<SelectOption> cities = new List<SelectOption>();
        for (EMS_City_To_Province_Mapping_gne__c mapping : [SELECT City_gne__c FROM EMS_City_To_Province_Mapping_gne__c WHERE Province_gne__c = :event.Province_gne__c ORDER BY Order_gne__c NULLS LAST, City_gne__c]) {
            cities.add(new SelectOption(mapping.City_gne__c, mapping.City_gne__c));
        }
        return cities;
    }

    private Boolean getBudgetApprovalRequired() {
        // if the event requires budget approval submit budget allocations, else submit event
        Boolean budgetOwnerOtherThanEventOwner = false;
        for (EMS_Budget_Allocation_gne__c ba : budgetAllocations) {
            budgetOwnerOtherThanEventOwner |= ba.Budget_Owner_gne__c != event.Event_Owner_gne__c;
        }

        return subtypesWithGDCommitteeApproval.contains(event.Event_Sub_Type_gne__c) || (eventConfiguration.Budget_Approval_Required_gne__c && budgetOwnerOtherThanEventOwner);
    }

    private void getBudgetAllocations() {
        for (EMS_Budget_Allocation_gne__c budgetAllocation : [SELECT Id, Name, Cost_Center_gne__c, Cost_Center_Type_gne__c, Percentage_Contribution_gne__c, Product_Indication_gne__c, Allocated_Budget_gne__c, Approver_gne__c, Budget_Owner_gne__c, Budget_Owner_gne__r.Name, Status_gne__c, Submitted_By_gne__c FROM EMS_Budget_Allocation_gne__c WHERE EMS_Event_gne__c = :event.Id]) {
            if ((budgetAllocation.Status_gne__c != null && budgetAllocation.Status_gne__c.contains('Submitted')) && (budgetAllocation.Approver_gne__c == UserInfo.getUserId() || EMS_Util.isAdmin())) {
                budgetAllocationsToApprove.add(budgetAllocation);
            }

            if ((budgetAllocation.Status_gne__c != null && budgetAllocation.Status_gne__c.contains('Submitted')) && budgetAllocation.Submitted_By_gne__c == UserInfo.getUserId()) {
                budgetAllocationsToRecall.add(budgetAllocation);
            }

            budgetAllocations.add(budgetAllocation);
            approvalHistoryRecords.add(budgetAllocation);
        }
    }

    // Event Actions
    public Boolean getCanEdit() {
        return EMS_Access.isEventEditable(event, budgetAllocations);
    }

    public Boolean getAttachmentsTravelsEditable() {
        return EMS_Access.isAttachmentTravelSectionEditable(event, budgetAllocations);
    }

    public Boolean getLocationSectionEditable() {
        return EMS_Access.isLocationSectionEditable(event, budgetAllocations);
    }

    public Boolean getPlanningSectionEditable() {
        return EMS_Access.isEventPlanningSectionEditable(event);
    }

    public Boolean getCanRecallFromMedOpsReview() {
        return event.Status_gne__c == 'Pending Med Ops Review' && (event.Event_Requestor_gne__c == UserInfo.getUserId() || event.Event_Owner_gne__c == UserInfo.getUserId());
    }

    // Query for all object fields
    private static String getQueryStringForAllFields(String objectName, List<String> additionalFields, Set<String> excludedFields) {
        String queryString = 'SELECT ';
        Map<String, Schema.SObjectField> objectFields = Schema.GetGlobalDescribe().get(objectName).getDescribe().fields.getMap();

        for (Schema.SObjectField field : objectFields.values()) {
            String fieldName = field.getDescribe().getName().trim();
            if (excludedFields == null || !excludedFields.contains(fieldName)) {
                queryString += fieldName + ', ';
            }
        }
        if (additionalFields != null && additionalFields.size() > 0) {
            for (String addField : additionalFields) {
                queryString += addField + ', ';
            }
        }
        queryString = queryString.removeEnd(', ');
        queryString += ' FROM ' + objectName;

        return queryString;
    }

    // Budget Allocation Related Attributes
    public GNE_SFA2_RL_Component_AttributesWrapper getBudgetAllocationRLAttributes() {
        GNE_SFA2_User_App_Context_gne__c userApplicationContext = EMS_Util.getUserApplicationContext();
        EMS_Event__c localEvent = [
                SELECT RecordType.DeveloperName, Event_Requestor_gne__c, Event_Owner_gne__c, Planned_Expenses_gne__c
                FROM EMS_Event__c
                WHERE Id = :event.Id
        ];

        SFA2_Configuration_Object_Detail_gne__c budgetAllocationsRLConfig = [
                SELECT API_Name_gne__c, Label_gne__c, Attributes_gne__c, Is_Required_gne__c, Is_Read_Only_gne__c, Order_gne__c,
                        Type_gne__c, Style_gne__c, Availability_Mode_gne__c
                FROM SFA2_Configuration_Object_Detail_gne__c
                WHERE Type_gne__c = 'Related List'
                AND API_Name_gne__c = 'EMS_Budget_Allocation_gne__c'
                AND Configuration_Object_ref_gne__r.Object_Name_gne__c = 'EMS_Event__c'
                AND Configuration_Object_ref_gne__r.Role_gne__c = :userApplicationContext.Role_gne__c
                AND Configuration_Object_ref_gne__r.Brand_gne__c = :userApplicationContext.Brand_gne__c
                AND Configuration_Object_ref_gne__r.Application_Type__c = :userApplicationContext.App_Name_gne__c
                AND Configuration_Object_ref_gne__r.Record_Type_gne__c = :localEvent.RecordType.DeveloperName
                AND Configuration_Object_ref_gne__r.Is_Active_gne__c = TRUE
                AND Configuration_Object_ref_gne__r.Configuration_Type_gne__c = 'Page'
                AND Is_Active_gne__c = TRUE
                ORDER BY Order_gne__c, API_Name_gne__c
        ];

        GNE_SFA2_RL_Component_AttributesWrapper budgetAllocationRelatedListAttributes = new GNE_SFA2_RL_Component_AttributesWrapper(budgetAllocationsRLConfig.Attributes_gne__c);

        // Manage Budget Allocations button is available only for event owner/requestor, Admin or AARC
        Boolean isAllowedUser = localEvent.Event_Requestor_gne__c == UserInfo.getUserId() || localEvent.Event_Owner_gne__c == UserInfo.getUserId() || EMS_Access.isBPS();
        Boolean isCreatable = GNE_SFA2_Application_Cache.describeObject('EMS_Budget_Allocation_gne__c').isCreateable();
        Boolean hasPlannedExpenses = localEvent.Planned_Expenses_gne__c != null && localEvent.Planned_Expenses_gne__c > 0;

        Boolean canManageBudgetAllocations = EMS_Util.isAdmin() || EMS_Util.isCR() || (isAllowedUser && isCreatable && hasPlannedExpenses && getCanEdit());
        if (!canManageBudgetAllocations) {
            budgetAllocationRelatedListAttributes.customButtonsList.clear();
            budgetAllocationRelatedListAttributes.hideDeleteLink = true;
        }
        budgetAllocationRelatedListAttributes.hideEditLink = true;
        return budgetAllocationRelatedListAttributes;
    }

    // Budget Allocation Related Attributes
    public GNE_SFA2_RL_Component_AttributesWrapper getPaymentRequestRLAttributes() {
        GNE_SFA2_User_App_Context_gne__c userApplicationContext = EMS_Util.getUserApplicationContext();
        EMS_Event__c localEvent = [
                SELECT RecordType.DeveloperName, Event_Requestor_gne__c, Event_Owner_gne__c, Planned_Expenses_gne__c
                FROM EMS_Event__c
                WHERE Id = :event.Id
        ];

        SFA2_Configuration_Object_Detail_gne__c confDetail = [
                SELECT API_Name_gne__c, Label_gne__c, Attributes_gne__c, Is_Required_gne__c, Is_Read_Only_gne__c, Order_gne__c,
                        Type_gne__c, Style_gne__c, Availability_Mode_gne__c
                FROM SFA2_Configuration_Object_Detail_gne__c
                WHERE Type_gne__c = 'Related List'
                AND API_Name_gne__c = 'EMS_Speaker_Role_gne__c'
                AND Configuration_Object_ref_gne__r.Object_Name_gne__c = 'EMS_Event__c'
                AND Configuration_Object_ref_gne__r.Role_gne__c = :userApplicationContext.Role_gne__c
                AND Configuration_Object_ref_gne__r.Brand_gne__c = :userApplicationContext.Brand_gne__c
                AND Configuration_Object_ref_gne__r.Application_Type__c = :userApplicationContext.App_Name_gne__c
                AND Configuration_Object_ref_gne__r.Record_Type_gne__c = :localEvent.RecordType.DeveloperName
                AND Configuration_Object_ref_gne__r.Is_Active_gne__c = TRUE
                AND Configuration_Object_ref_gne__r.Configuration_Type_gne__c = 'Page'
                AND Is_Active_gne__c = TRUE
                ORDER BY Order_gne__c, API_Name_gne__c
        ];
        GNE_SFA2_RL_Component_AttributesWrapper paymentRequestAttributes = new GNE_SFA2_RL_Component_AttributesWrapper(confDetail.Attributes_gne__c);

        Boolean isEditable = (EMS_Util.isRecordEditable(event.Id) || (!EMS_Util.isRecordEditable(event.Id) && EMS_Util.isEventAttendee(event.Id)));
        // remove buttons for Watchers, Payment Request, etc.
        if (!isEditable) {
            paymentRequestAttributes.customButtonsList.clear();
        }
        return paymentRequestAttributes;
    }

    // Related Fields to Event Set List
    public List<String> getRelatedFieldSetListOverwritten() {
        if (relatedFieldSetList == null) {
            return (new List<String>());
        }

        List<SFA2_Configuration_Object_Detail_gne__c> overwrittenRelatedList;
        for (String rf : relatedFieldSetList) {
            if (relatedFieldSetMap.get(rf) != null) {
                overwrittenRelatedList = new List<SFA2_Configuration_Object_Detail_gne__c>();
                for (SFA2_Configuration_Object_Detail_gne__c confDetail : relatedFieldSetMap.get(rf)) {
                    if (confDetail.Type_gne__c == 'Related List' && confDetail.Label_gne__c != 'Budget Allocations' && confDetail.Label_gne__c != 'Payment Requests') {

                        Boolean isEditable = (EMS_Util.isRecordEditable(event.Id) || (!EMS_Util.isRecordEditable(event.Id) && EMS_Util.isEventAttendee(event.Id)));
                        // remove buttons for Watchers, Payment Request, etc.
                        if (!isEditable) {
                            relatedListAttributes.get(confDetail.API_Name_gne__c).customButtonsList = null;
                        }
                        overwrittenRelatedList.add(confDetail);
                    }
                }
                relatedFieldSetMap.get(rf).clear();
                relatedFieldSetMap.get(rf).addAll(overwrittenRelatedList);
            }
        }
        return relatedFieldSetList;
    }

    // Honorarium popup render conditions
    public EMS_Attendee_gne__c attendeeHonorarium {
        get {
            if (attendeeHonorarium == null) {
                attendeeHonorarium = new EMS_Attendee_gne__c();
            }
            return attendeeHonorarium;
        }
        set;
    }


    // **** BUTTON CLICKS **** //
    public PageReference edit() {
        Pagereference pageref = new pagereference('/apex/EMS_Event_Edit_Create_Layout?id=' + myObject.Id);
        pageref.setredirect(true);
        return pageref;
    }

    public override PageReference callMethod(String methodName) {
        if (methodName.equalsIgnoreCase('newAttendeeClick')) {
            return newAttendeeClick();
        } else if (methodName.equalsIgnoreCase('manageBudgetAllocationsClick')) {
            return manageBudgetAllocationsClick();
        } else if (methodName.equalsIgnoreCase('newExpenseClick')) {
            return newExpenseClick();
        } else if (methodName.equalsIgnoreCase('newTravelClick')) {
            return newTravelClick();
        } else if (methodName.equalsIgnoreCase('newRocheAttendeeClick')) {
            return newRocheAttendeeClick();
        } else if (methodName.equalsIgnoreCase('newPaymentRequestClick')) {
            return newPaymentRequestClick();
        } else if (methodName.equalsIgnoreCase('newAttachmentClick')) {
            return newAttachmentClick();
        } else if (methodName.equalsIgnoreCase('closeEventClick')) {
            return closeEventClick();
        } else if (methodName.equalsIgnoreCase('cancelEventClick')) {
            return cancelEventClick();
        } else {
            return null;
        }
    }

    public PageReference manageBudgetAllocationsClick() {
        PageReference pageRef = Page.EMS_Budget_Allocation_Page;
        pageRef.getParameters().put('objectId', myObject.Id);
        pageRef.getParameters().put('retURL', '/' + myObject.Id);
        return pageRef;
    }

    public PageReference newAttendeeClick() {
        return null;
    }

    public PageReference newExpenseClick() {
        PageReference pageRef = Page.EMS_Expense_Edit_Create_Layout;
        pageRef.getParameters().put('objectId', myObject.Id);
        pageRef.getParameters().put('retURL', '/' + myObject.Id);
        return pageRef;
    }

    public PageReference newTravelClick() {
        PageReference pageRef = Page.EMS_Travel_Edit_Create_Layout;
        pageRef.getParameters().put('objectId', myObject.Id);
        pageRef.getParameters().put('retURL', '/' + myObject.Id);
        return pageRef;
    }

    public PageReference newRocheAttendeeClick() {
        PageReference pageRef = Page.EMS_Roche_Attendee_Edit_Create_Layout;
        pageRef.getParameters().put('objectId', myObject.Id);
        pageRef.getParameters().put('retURL', '/' + myObject.Id);
        return pageRef;
    }

    public PageReference newPaymentRequestClick() {
        PageReference pageRef = Page.EMS_Payment_Request_Edit_Create_Layout;
        pageRef.getParameters().put('objectId', myObject.Id);
        pageRef.getParameters().put('retURL', '/' + myObject.Id);
        return pageRef;
    }

    public PageReference newAttachmentClick() {
        PageReference pageRef = Page.EMS_Upload_Attachments;
        pageRef.getParameters().put('objectId', myObject.Id);
        pageRef.getParameters().put('retURL', '/' + myObject.Id);
        return pageRef;
    }

    public PageReference duplicateEventClick() {
        System.Savepoint initialState = Database.setSavepoint();
        pageErrorMessage = null;
        try {
            List<String> additionalEventFields = new List<String>{
                    'Event_Owner_gne__r.IsActive',
                    'Event_Requestor_gne__r.IsActive',
                    'Assigned_AARC_gne__r.IsActive',
                    'Meeting_Planner_Member_gne__r.IsActive',
                    'HCP_HCO_Name_gne__r.MRM_Status_can_gne__c'
            };
            EMS_Event__c currentEvent = (EMS_Event__c) Database.query(getQueryStringForAllFields('EMS_Event__c', additionalEventFields, null) + ' WHERE Id = \'' + event.Id + '\'')[0];
            EMS_Event__c duplicatedEvent = currentEvent.clone(false, false, false, false);
            duplicatedEvent.OwnerId = UserInfo.getUserId();
            duplicatedEvent.Status_gne__c = 'Unplanned';
            duplicatedEvent.RecordTypeId = EMS_Event__c.getSObjectType().getDescribe().getRecordTypeInfosByName().get('EMS Event').getRecordTypeId();
            duplicatedEvent.Budget_Approval_Required_gne__c = false;
            duplicatedEvent.Budget_Approval_Failed_gne__c = false;
            duplicatedEvent.Pending_Budget_Approval_gne__c = false;
            duplicatedEvent.Submitted_By_gne__c = null;
            duplicatedEvent.Total_Expenses_gne__c = 0;               // Clear Total Expenses

            if (currentEvent.Event_Owner_gne__c != null && currentEvent.Event_Owner_gne__r.IsActive == false) {
                duplicatedEvent.Event_Owner_gne__c = null;
                duplicatedEvent.Assigned_To_Territory_Owner_gne__c = null;
                duplicatedEvent.Assigned_To_Territory_Owner_Id_gne__c = null;
            }
            if (currentEvent.Event_Requestor_gne__c != null && currentEvent.Event_Requestor_gne__r.IsActive == false) {
                duplicatedEvent.Event_Requestor_gne__c = null;
                duplicatedEvent.Assigned_To_Territory_Requestor_gne__c = null;
                duplicatedEvent.Assigned_To_Territory_Requestor_Id_gne__c = null;
            }
            if (currentEvent.Assigned_AARC_gne__c != null && currentEvent.Assigned_AARC_gne__r.IsActive == false) {
                duplicatedEvent.Assigned_AARC_gne__c = null;
            }
            if (currentEvent.Meeting_Planner_Member_gne__c != null && currentEvent.Meeting_Planner_Member_gne__r.IsActive == false) {
                duplicatedEvent.Meeting_Planner_Member_gne__c = null;
            }
            if (currentEvent.Is_GSD_Event_gne__c == false || (
                    currentEvent.HCP_HCO_Name_gne__c != null &&
                            currentEvent.HCP_HCO_Name_gne__r.MRM_Status_can_gne__c != 'ACTIVE'
            )) {
                duplicatedEvent.HCP_HCO_Name_gne__c = null;
            }

            EMS_Event_Trigger_Helper.skipTriggerValidationRules = true;
            insert duplicatedEvent;

            String soql = '';
            // cloning Metting requests
            soql = getQueryStringForAllFields('EMS_Meeting_Request_gne__c', null, null);
            soql += ' WHERE EMS_Event_gne__c = \'' + event.Id + '\'';
            List<EMS_Meeting_Request_gne__c> duplicatedMeetingRequests = new List<EMS_Meeting_Request_gne__c>();
            List<EMS_Meeting_Request_gne__c> meetingRequestsToBeCloned = Database.query(soql);
            duplicatedMeetingRequests = meetingRequestsToBeCloned.deepClone(false);
            for (EMS_Meeting_Request_gne__c mr : duplicatedMeetingRequests) {
                mr.EMS_Event_gne__c = duplicatedEvent.Id;
            }

            // cloning Products
            soql = getQueryStringForAllFields('EMS_Event_Product_gne__c', null, null);
            soql += ' WHERE Event_gne__c = \'' + event.Id + '\'';
            List<EMS_Event_Product_gne__c> duplicatedEventProducts = new List<EMS_Event_Product_gne__c>();
            duplicatedEventProducts = Database.query(soql).deepClone(false);
            for (EMS_Event_Product_gne__c ep : duplicatedEventProducts) {
                ep.Event_gne__c = duplicatedEvent.Id;
            }

            // cloning Attendees
            soql = getQueryStringForAllFields('EMS_Roche_Attendee_gne__c', null, null);
            soql += ' WHERE EMS_Event_gne__c = \'' + event.Id + '\' AND User_gne__r.IsActive = true' ;
            List<EMS_Roche_Attendee_gne__c> duplicatedAttendees = Database.query(soql).deepClone(false);
            List<EMS_Roche_Attendee_gne__c> autoCreatedAttendees = [SELECT User_gne__c, Territory_Id_gne__c FROM EMS_Roche_Attendee_gne__c WHERE EMS_Event_gne__c = :duplicatedEvent.Id];
            List<EMS_Roche_Attendee_gne__c> rocheAttendeesToUpsert = new List<EMS_Roche_Attendee_gne__c>();
            Map<Id, Set<Id>> userTerritoriesMap = EMS_Util.getEventRocheAttendeeTerritories(event.Id);
            for (EMS_Roche_Attendee_gne__c a : duplicatedAttendees) {
                Set<Id> territories = userTerritoriesMap.get(a.User_gne__c);
                // Select first available territory if current one is invalid
                if (territories != null && !territories.contains((Id) a.Territory_Id_gne__c)) {
                    a.Territory_Id_gne__c = new List<Id>(territories).get(0);
                }

                if (!autoCreatedAttendees.isEmpty() && a.User_gne__c == autoCreatedAttendees.get(0).User_gne__c) {
                    EMS_Roche_Attendee_gne__c temp = autoCreatedAttendees.get(0);
                    temp.Territory_Id_gne__c = a.Territory_Id_gne__c;
                    rocheAttendeesToUpsert.add(temp);
                } else {
                    a.EMS_Event_gne__c = duplicatedEvent.Id;
                    rocheAttendeesToUpsert.add(a);
                }
            }

            // cloning HCP/iHCP attendees
            soql = getQueryStringForAllFields('EMS_Attendee_gne__c', null, null);
            soql += ' WHERE EMS_Event_gne__c = \'' + event.Id + '\'' ;
            List<EMS_Attendee_gne__c> duplicatedHCPiHCP = new List<EMS_Attendee_gne__c>();
            duplicatedHCPiHCP = Database.query(soql).deepClone(false);
            for (EMS_Attendee_gne__c a : duplicatedHCPiHCP) {
                a.EMS_Event_gne__c = duplicatedEvent.Id;
            }

            if (!duplicatedMeetingRequests.isEmpty()) {
                insert duplicatedMeetingRequests;

// clone meeting rooms only when there is meeting request created
                soql = getQueryStringForAllFields('EMS_Meeting_Room_gne__c', null, null);
                soql += ' WHERE EMS_Meeting_Request_gne__c = \'' + meetingRequestsToBeCloned[0].Id + '\'';
                List<EMS_Meeting_Room_gne__c> duplicateddMeetingRoom = new List<EMS_Meeting_Room_gne__c>();
                duplicateddMeetingRoom = Database.query(soql).deepClone(false);
                for (EMS_Meeting_Room_gne__c mr : duplicateddMeetingRoom) {
                    mr.EMS_Meeting_Request_gne__c = duplicatedMeetingRequests[0].Id;
                }
                if (!duplicateddMeetingRoom.isEmpty()) {
                    insert duplicateddMeetingRoom;
                }
            }
            if (!duplicatedEventProducts.isEmpty()) {
                insert duplicatedEventProducts;
            }
            if (!rocheAttendeesToUpsert.isEmpty()) {
                upsert rocheAttendeesToUpsert;
            }
            if (!duplicatedHCPiHCP.isEmpty()) {
                insert duplicatedHCPiHCP;
            }

            PageReference newPage = Page.EMS_Event_Layout;
            newPage.getParameters().put('Id', duplicatedEvent.ID);
            newPage.getParameters().put('retURL', '/' + event.ID);
            newPage.setRedirect(true);
            return newPage;
        } catch (Exception e) {
            pageErrorMessage = e.getMessage();
            Database.rollback(initialState);
            return null;
        }
    }

    public PageReference cancelEventClick() {
        System.Savepoint savePoint = Database.setSavepoint();
        pageErrorMessage = null;
        try {
            EMS_Event_Trigger_Helper.skipTriggerValidationRules = true;
            update new EMS_Event__c(
                    Id = event.Id,
                    Status_gne__c = 'Cancelled'
            );
        } catch (DMLException ex) {
            Database.rollback(savePoint);

            for (Integer i = 0; i < ex.getNumDml(); i++) {
// Display an error which is longer than others
                if (String.isBlank(pageErrorMessage) || pageErrorMessage.length() < ex.getDmlMessage(i).length()) {
                    pageErrorMessage = ex.getDmlMessage(i);
                }
            }
            resetController();
            return null;
        }

        PageReference pref = new PageReference('/' + event.Id);
        pref.setRedirect(true);
        return pref;
    }

    public PageReference uncancelEventClick() {
        pageErrorMessage = null;
        EMS_Event__c tempEvent = new EMS_Event__c(Id = event.Id);
//check previous status and record type of the event
        List<EMS_Event__History> latestStatus = [SELECT Field, NewValue, OldValue FROM EMS_Event__History WHERE ParentId = :event.Id AND Field = 'Status_gne__c' ORDER BY CreatedDate DESC LIMIT 1];
        if (latestStatus.size() > 0) {
            tempEvent.Status_gne__c = String.valueOf(latestStatus[0].OldValue);
        } else {
            resetController();
            pageErrorMessage = EMS_Event_Message_Handler.cannotUncancelEvent();
            return null;
        }

        String recordTypePrefix = Schema.GetGlobalDescribe().get('RecordType').getDescribe().getKeyPrefix();
        Boolean rtFound = false;
        for (EMS_Event__History reordTypeHistory : [SELECT Field, NewValue, OldValue FROM EMS_Event__History WHERE ParentId = :event.Id AND Field = 'RecordType' ORDER BY CreatedDate DESC]) {
            String oldVal = String.valueOf(reordTypeHistory.OldValue);
            if (oldVal != null && oldVal.startsWith(recordTypePrefix)) {
                tempEvent.RecordTypeId = oldVal;
                rtFound = true;
                break;
            }
        }
        if (!rtFound) {
            resetController();
            pageErrorMessage = EMS_Event_Message_Handler.cannotUncancelEvent();
            return null;
        }

        System.Savepoint initialState = Database.setSavepoint();
        try {
            EMS_Event_Trigger_Helper.skipTriggerValidationRules = true;
            update tempEvent;
        } catch (DMLException ex) {
            Database.rollback(initialState);
            for (Integer i = 0; i < ex.getNumDml(); i++) {
// Display an error which is longer than others
                if (String.isBlank(pageErrorMessage) || pageErrorMessage.length() < ex.getDmlMessage(i).length()) {
                    pageErrorMessage = ex.getDmlMessage(i);
                }
            }
            resetController();
            return null;
        }

        PageReference pref = new PageReference('/' + event.Id);
        pref.setRedirect(true);
        return pref;
    }

    public PageReference closeEventClick() {
        System.Savepoint savePoint = Database.setSavepoint();    // capture initial DB state to rollback to in case of error
        pageErrorMessage = null;
        try {
            EMS_Event_Trigger_Helper.skipTriggerValidationRules = true;
            update new EMS_Event__c(
                    Id = event.Id,
                    Status_gne__c = 'Closed',
                    Reopen_Date_gne__c = null
            );
        } catch (DMLException ex) {
            Database.rollback(savePoint);
            for (Integer i = 0; i < ex.getNumDml(); i++) {
// Display an error which is longer than others
                if (String.isBlank(pageErrorMessage) || pageErrorMessage.length() < ex.getDmlMessage(i).length()) {
                    pageErrorMessage = ex.getDmlMessage(i);
                }
            }

            pageErrorMessage = EMS_Event_Message_Handler.validationException(pageErrorMessage);

            resetController();
            return null;
        }

        PageReference pref = new PageReference('/' + event.Id);
        pref.setRedirect(true);
        return pref;
    }

    public PageReference reopenEventClick() {
        pageErrorMessage = null;
        EMS_Event__c tempEvent = new EMS_Event__c(Id = event.Id);
//check previous status and record type of the event
        List<EMS_Event__History> latestStatus = [SELECT Field, NewValue, OldValue FROM EMS_Event__History WHERE ParentId = :event.Id AND Field = 'Status_gne__c' ORDER BY CreatedDate DESC LIMIT 1];
        if (latestStatus.size() > 0) {
            tempEvent.Status_gne__c = String.valueOf(latestStatus[0].OldValue);
        } else {
            resetController();
            pageErrorMessage = EMS_Event_Message_Handler.cannotReopenEvent();
            return null;
        }

        String recordTypePrefix = Schema.GetGlobalDescribe().get('RecordType').getDescribe().getKeyPrefix();
        Boolean rtFound = false;
        for (EMS_Event__History reordTypeHistory : [SELECT Field, NewValue, OldValue FROM EMS_Event__History WHERE ParentId = :event.Id AND Field = 'RecordType' ORDER BY CreatedDate DESC]) {
            String oldVal = String.valueOf(reordTypeHistory.OldValue);
            if (oldVal != null && oldVal.startsWith(recordTypePrefix)) {
                tempEvent.RecordTypeId = oldVal;
                rtFound = true;
                break;
            }
        }
        if (!rtFound) {
            resetController();
            pageErrorMessage = EMS_Event_Message_Handler.cannotReopenEvent();
            return null;
        }

        System.Savepoint initialState = Database.setSavepoint();
        try {
            EMS_Event_Trigger_Helper.skipTriggerValidationRules = true;
            tempEvent.Auto_Closed_gne__c = false;
            tempEvent.Reopen_Date_gne__c = System.today();
            update tempEvent;
        } catch (DMLException ex) {
            Database.rollback(initialState);
            for (Integer i = 0; i < ex.getNumDml(); i++) {
// Display an error which is longer than others
                if (String.isBlank(pageErrorMessage) || pageErrorMessage.length() < ex.getDmlMessage(i).length()) {
                    pageErrorMessage = ex.getDmlMessage(i);
                }
            }
            resetController();
            return null;
        }

        PageReference pref = new PageReference('/' + event.Id);
        pref.setRedirect(true);
        return pref;
    }

    public PageReference submitForApprovalClick() {
        Savepoint savePoint = Database.setSavepoint();
        pageErrorMessage = null;
        try {
            event = getEventByID(event.Id);    // read the current state of event to caputre possible changes from quick save
            Boolean isBpsMember = event.Assigned_AARC_gne__c == UserInfo.getUserId();
            if (isBpsMember) {
                event = EMS_Event_Helper.notAllBudgetApproved(event, eventConfiguration.Pending_Budget_Approval_Label_gne__c);
            } else if (getBudgetApprovalRequired()) {
                event.Budget_Approval_Failed_gne__c = false;
                // check if all BAs are approved
                Boolean allBAsApproved = (budgetAllocations.size() > 0);
                for (EMS_Budget_Allocation_gne__c ba : budgetAllocations) {
                    allBAsApproved &= ba.Status_gne__c.equalsIgnoreCase('Approved');
                }

                if (allBAsApproved) {
                    event = EMS_Event_Helper.allBudgetApproved(event, eventConfiguration.Budget_Approved_Label_gne__c);
                } else {
                    event = EMS_Event_Helper.notAllBudgetApproved(event, eventConfiguration.Pending_Budget_Approval_Label_gne__c);
                }
            } else {
                event = EMS_Event_Helper.budgetApprovalNotRequired(event);
            }
        } catch (DMLException ex) {
            String message = ex.getMessage();
            pageErrorMessage = EMS_Event_Message_Handler.approveEventException(message);
            Database.rollback(savePoint);
            resetController();
            return null;
        } catch (Exception ex) {
            pageErrorMessage = ex.getMessage();
            Database.rollback(savePoint);
            resetController();
            return null;
        }

        PageReference result = Page.EMS_Event_Layout;
        result.getParameters().put('id', event.Id);
        result.getParameters().put('msg', EMS_Event_Message_Handler.successfulSubmission());
        result.setRedirect(true);
        return result;
    }

    public PageReference cancellApprovalClick() {
        pageErrorMessage = null;
        Savepoint savePoint = Database.setSavepoint();
        try {
            List<ProcessInstanceWorkitem> piwItems = [SELECT Id, ProcessInstanceId FROM ProcessInstanceWorkitem WHERE ProcessInstanceId IN (SELECT Id FROM ProcessInstance WHERE TargetObjectId = :event.Id)];

            if (piwItems.size() > 0) {
                List<Approval.ProcessWorkitemRequest> approvalsToReject = new List<Approval.ProcessWorkitemRequest>();
                for (ProcessInstanceWorkitem piwItem : piwItems) {
                    Approval.ProcessWorkitemRequest rejectAppr = new Approval.ProcessWorkitemRequest();
                    rejectAppr.setComments('Approval process cancelled.');
                    rejectAppr.setAction('Removed');
                    rejectAppr.setWorkitemId(piwItem.Id);
                    approvalsToReject.add(rejectAppr);
                }
                List<Approval.ProcessResult> rejectResults = Approval.process(approvalsToReject);
            }

            Id startRT = Schema.SObjectType.EMS_Event__c.getRecordTypeInfosByName().get('EMS Event').getRecordTypeId();
            update new EMS_Event__c(
                    Id = event.Id,
                    Budget_Approval_Required_gne__c = false,
                    Pending_Budget_Approval_gne__c = false,
                    Budget_Approval_Failed_gne__c = false,
                    RecordTypeId = startRT,
                    Status_gne__c = event.Is_Planned_gne__c ? 'Planned' : 'Unplanned'
            );

            PageReference result = Page.EMS_Event_Layout;
            result.getParameters().put('id', event.Id);
            result.setRedirect(true);
            return result;
        } catch (Exception ex) {
            pageErrorMessage = ex.getMessage();
            Database.rollback(savePoint);
        }
        resetController();
        return null;
    }

    public PageReference awaitingSignatureFromHCPClick() {
        System.Savepoint initialState = Database.setSavepoint();
        pageErrorMessage = null;
        try {
            update new EMS_Event__c(
                    Id = event.id,
                    Status_gne__c = 'Awaiting Signature from HCP'
            );
        } catch (DMLException ex) {
            Database.rollback(initialState);
            resetController();

            for (Integer i = 0; i < ex.getNumDml(); i++) {
                // Display an error which is longer than others
                if (String.isBlank(pageErrorMessage) || pageErrorMessage.length() < ex.getDmlMessage(i).length()) {
                    pageErrorMessage = ex.getDmlMessage(i);
                }
            }
            return null;
        }

        PageReference pref = new PageReference('/' + event.Id);
        pref.setRedirect(true);
        return pref;
    }

    public PageReference sendStatusToFRT() {
        EMS_FRT_Webservice.sendEventStatus(event);
        return null;
    }

    // **** MISCELLANEUS METHODS **** //
    private void resetController() {
        stdController.reset();
        event = getEventByID(stdController.getId());
    }

    private void loadGSDDetail() {
        if (event.Is_GSD_Event_gne__c) {
            List<EMS_GSD_Detail__c> gsdDetails = [
                    SELECT Date_of_Request_Letter_gne__c, HCP_HCO_Name__r.Name, Request_Summary_gne__c, Recipient_Job_Title_gne__c, Institution_gne__c, Website_URL_gne__c,
                            Street_1_gne__c, Street_2_gne__c, City_gne__c, Province_gne__c, Postal_Code_gne__c, Country_gne__c, Purpose_gne__c, Phone_Number_gne__c,
                            Email_Address_gne__c, GSD_Type_gne__c, Email_Address_Vendor_Signatory_gne__c, Name_of_Vendor_Signatory_gne__c
                    FROM EMS_GSD_Detail__c
                    WHERE EMS_Event__c = :event.Id
                    ORDER BY CreatedDate DESC
            ];
            if (gsdDetails.size() > 0) {
                gsdDetail = gsdDetails[0];
            } else {
                gsdDetail = new EMS_GSD_Detail__c(EMS_Event__c = event.id);
            }
        }
    }

    private void fetchApprovalProcessItems() {
        Map<Id, EMS_Budget_Allocation_gne__c> budgetAllocationsMap = new Map<Id, EMS_Budget_Allocation_gne__c>(budgetAllocations);
        Map<Id, SObject> targetObjectMap = new Map<Id, SObject>(approvalHistoryRecords);
        targetObjectMap.put(event.Id, event);

        processInstanceList = [
                SELECT Id, TargetObject.Name, TargetObjectID, TargetObject.Type, Status, CreatedDate, (SELECT Id, CreatedDate, CreatedById, Actor.Name, Actor.Id, OriginalActor.Id, OriginalActor.Name FROM WorkItems ORDER BY CreatedDate DESC), (SELECT id, Actor.Name, CreatedDate, Comments, StepStatus, OriginalActor.Id, OriginalActor.Name FROM Steps ORDER BY CreatedDate DESC)
                FROM ProcessInstance
                where TargetObject.Id IN :targetObjectMap.keySet()
                ORDER BY CreatedDate DESC
        ];

        for (ProcessInstance pi : processInstanceList) {
            if (pi.Workitems != null && pi.Workitems.size() != 0) {
                // event approval
                if (pi.TargetObjectId == event.Id) {
                    for (ProcessInstanceWorkitem piw : pi.Workitems) {
                        submittedBy = piw.CreatedById;
                        processInstanceWorkitemId = piw.Id; //Only one item can be in pending status.
                        break;
                    }
                }
                // budget approval
                if (budgetAllocationsMap.containsKey(pi.TargetObjectId)) {
                    for (ProcessInstanceWorkitem piw : pi.Workitems) {
                        budgetApprovers.add(piw.OriginalActor.Id);
                        budgetSubmitters.add(piw.CreatedById);
                        budgetallocationProcessInstanceWorkItems.put(pi.TargetObjectID, piw.Id);
                    }
                }
            }
        }
    }

    private void prepareSidebarChecklists() {
        complianceChecklists = new List<ComplianceRecord>();
        checklistResponses = new Map<Id, EMS_Checklist_Response_gne__c>();
        Date approvalDate = event.Approval_Date_gne__c;

        // records which will be displayed on the side bar
        List<EMS_Checklist_gne__c> sidebarChecklists = new List<EMS_Checklist_gne__c>();
        // responses
        List<EMS_Checklist_Response_gne__c> responseList = new List<EMS_Checklist_Response_gne__c>();
        if (approvalDate != null) {
            // Select all records that might satisfy two conditions:
            // Approval date of event is between end and start dates
            // Approval date of event is between today and stard dates
            List<EMS_Checklist_gne__c> checklist = [
                    SELECT Is_Dependent_Required_gne__c, Depends_On_gne__c, Has_Depending_Items_gne__c, Has_Parent_gne__c, Index_gne__c,
                            Is_Checked_gne__c, Is_Note_gne__c, Is_One_Choice_gne__c, Parent_Index_gne__c, Is_All_Choice_gne__c, Verison_Number_gne__c,
                            Is_Multi_Choice_gne__c, Is_Parent_gne__c, Item_gne__c, Requires_Input_gne__c, End_Date_gne__c, External_Id_gne__c, Type_gne__c
                    FROM EMS_Checklist_gne__c
                    WHERE Event_Type_gne__c = :event.Event_Type_gne__c
                    AND Event_Sub_Type_gne__c = :event.Event_Sub_Type_gne__c
                    AND Type_gne__c = 'Compliance Checklist'
                    AND Is_Note_gne__c = false
                    AND Is_Active_gne__c = true
                    AND Start_Date_gne__c <= :approvalDate
                    AND (End_Date_gne__c >= :approvalDate OR End_Date_gne__c = null)
                    ORDER BY Index_gne__c
            ];

            Map<String, EMS_Checklist_gne__c> extId_checklist_map = new Map<String, EMS_Checklist_gne__c>();
            // checklist records are defined in the loop
            for (EMS_Checklist_gne__c checklistItem : checklist) {
                if (checklistItem.Type_gne__c == 'Compliance Checklist') {
                    // toTrim is a tail that contains only version number
                    String toTrim = String.valueOf(checklistItem.Verison_Number_gne__c);
                    String key = checklistItem.External_Id_gne__c;
                    key = key.substring(0, key.length() - toTrim.length());
                    if (extId_checklist_map.containsKey(key)) {
                        // Replace map's value for the one that should be in the list
                        if (checklistItem.End_Date_gne__c != null && checklistItem.End_Date_gne__c >= approvalDate) {
                            extId_checklist_map.put(key, checklistItem);
                        }
                    } else {
                        extId_checklist_map.put(key, checklistItem);
                    }
                }
            }
            checklist.clear();

            // prepare Sidebar Statements
            sidebarChecklists = extId_checklist_map.values();

            // prepare Notes
            complianceNotes = [
                    SELECT Item_gne__c
                    FROM EMS_Checklist_gne__c
                    WHERE Event_Type_gne__c = :event.Event_Type_gne__c
                    AND Event_Sub_Type_gne__c = :event.Event_Sub_Type_gne__c
                    AND Type_gne__c = 'Compliance Checklist'
                    AND Is_Note_gne__c = true
                    AND Is_Active_gne__c = true
                    AND Start_Date_gne__c <= :approvalDate
                    AND (End_Date_gne__c >= :approvalDate OR End_Date_gne__c = null)
                    ORDER BY Index_gne__c
            ];

            // get responses for Sidebar Statements
            responseList = [SELECT Is_Checked_gne__c, Text_gne__c, EMS_Checklist_gne__c FROM EMS_Checklist_Response_gne__c WHERE EMS_Event_gne__c = :event.Id AND EMS_Checklist_gne__c IN :sidebarChecklists];
        } else {
            // prepare Notes
            complianceNotes = [
                    SELECT Item_gne__c
                    FROM EMS_Checklist_gne__c
                    WHERE Event_Type_gne__c = :event.Event_Type_gne__c
                    AND Event_Sub_Type_gne__c = :event.Event_Sub_Type_gne__c
                    AND Type_gne__c = 'Compliance Checklist'
                    AND Is_Note_gne__c = true
                    AND Is_Active_gne__c = true
                    AND Start_Date_gne__c != null
                    AND Start_Date_gne__c <= :Date.today()
                    AND (End_Date_gne__c = null OR End_Date_gne__c >= :Date.today())
                    ORDER BY Index_gne__c
            ];
        }

        // prepare Responses (Answers/Selected statements)
        for (EMS_Checklist_Response_gne__c response : responseList) {
            checklistResponses.put(response.EMS_Checklist_gne__c, response);
        }

        // common collection for checklists
        List<EMS_Checklist_gne__c> checklist = new List<EMS_Checklist_gne__c>();
        if (!sidebarChecklists.isEmpty()) {
            checklist.addAll(sidebarChecklists);
        }

        Map<Integer, ComplianceRecord> sidebarStatements = new Map<Integer, ComplianceRecord>();
        // maxIndex is used for sorting records // loop through 0 to maxIndex
        Integer maxIndex = 0;
        for (EMS_Checklist_gne__c clItem : checklist) {
            if (maxIndex < clItem.Index_gne__c) {
                maxIndex = Integer.valueOf(clItem.Index_gne__c);
            }
            String itemText = '';
            Boolean checked = false;
            if (checklistResponses.get(clItem.Id) != null) {
                itemText = checklistResponses.get(clItem.Id).Text_gne__c;
                checked = checklistResponses.get(clItem.Id).Is_Checked_gne__c;
            }
            Integer dependsOn = (clItem.Depends_On_gne__c == null) ? null : Integer.valueOf(clItem.Depends_On_gne__c);
            // prepare sidebarStatements only if an event record is approved
            if (clItem.Type_gne__c == 'Compliance Checklist') {
                if (dependsOn == null || (sidebarStatements.containsKey(dependsOn) && sidebarStatements.get(dependsOn).isChecked)) {
                    ComplianceRecord complRec = new ComplianceRecord(
                            clItem,
                            clItem.Index_gne__c,
                            clItem.Item_gne__c,
                            clItem.Is_Parent_gne__c,
                            clItem.Has_Parent_gne__c,
                            checked,
                            clItem.Is_One_Choice_gne__c,
                            clItem.Is_Multi_Choice_gne__c,
                            clItem.Is_All_Choice_gne__c,
                            clItem.Requires_Input_gne__c,
                            itemText,
                            dependsOn,
                            clItem.Has_Depending_Items_gne__c,
                            clItem.Parent_Index_gne__c
                    );
                    complRec.isDependentRequired = clItem.Is_Dependent_Required_gne__c;
                    sidebarStatements.put(Integer.valueOf(clItem.Index_gne__c), complRec);
                }
            }
        }

        // generate a sorted list
        List<ComplianceRecord> sidebarStatements_sorted = new List<ComplianceRecord>();
        for (Integer i = 0; i <= maxIndex; i++) {
            if (sidebarStatements.containsKey(i)) {
                sidebarStatements_sorted.add(sidebarStatements.get(i));
            }
        }
        complianceChecklists.addAll(sidebarStatements_sorted);
    }

    // **** REMOTE METHODS **** //
    @RemoteAction
    public static Map<String, Set<String>> getAvailableCostCenterTypes(String eventID, String eventType, String eventSubtype) { // Loaded dynamically
        Set<String> typesFromBudgets = new Set<String>();
        // types awailable from budgets
        for (EMS_Budget_Allocation_gne__c ba : [SELECT Cost_Center_Type_gne__c FROM EMS_Budget_Allocation_gne__c WHERE EMS_Event_gne__c = :eventID]) {
            typesFromBudgets.add(ba.Cost_Center_Type_gne__c);
        }

        // types available from possible budget allocations (linked with EMS Event Configuration)
        Set<String> typesFromPossibleBudgets = new Set<String>();
        List<EMS_Possible_Budget_Allocation_gne__c> pbas = [
                SELECT GSD_Type_gne__c
                FROM EMS_Possible_Budget_Allocation_gne__c
                WHERE EMS_Event_Configuration_gne__r.Event_Type_gne__c = :eventType
                AND EMS_Event_Configuration_gne__r.Event_Sub_Type_gne__c = :eventSubtype
        ];
        for (EMS_Possible_Budget_Allocation_gne__c pba : pbas) {
            if (pba.GSD_Type_gne__c == null) {
                continue;
            }
            for (String gsdType : pba.GSD_Type_gne__c.split(';')) {
                if (!typesFromPossibleBudgets.contains(gsdType)) {
                    typesFromPossibleBudgets.add(gsdType);
                }
            }
        }

        Map<String, Set<String>> types = new Map<String, Set<String>>{
                'costCenterTypes' => typesFromBudgets,
                'availableGSDTypes' => typesFromPossibleBudgets
        };
        return types;
    }

    @RemoteAction
    public static EMS_Remote_Response prepareAcknowledgementStatement(String eventType, String eventSubtype, String eventID, String approvalDate) {
        EMS_Remote_Response response = new EMS_Remote_Response();
        response.isSuccess = false;
        try {
            List<EMS_Checklist_gne__c> checklists = [
                    SELECT Is_Dependent_Required_gne__c, Depends_On_gne__c, Has_Depending_Items_gne__c, Has_Parent_gne__c, Index_gne__c,
                            Is_Checked_gne__c, Is_Note_gne__c, Is_One_Choice_gne__c, Parent_Index_gne__c, Is_All_Choice_gne__c,
                            Is_Multi_Choice_gne__c, Is_Parent_gne__c, Item_gne__c, Requires_Input_gne__c, Type_gne__c
                    FROM EMS_Checklist_gne__c
                    WHERE Event_Type_gne__c = :eventType
                    AND Event_Sub_Type_gne__c = :eventSubtype
                    AND Type_gne__c = 'Acknowledgement Statement'
                    AND Is_Note_gne__c = false
                    AND Is_Active_gne__c = true
                    AND Start_Date_gne__c != null
                    AND Start_Date_gne__c <= :Date.today()
                    AND (End_Date_gne__c = null OR End_Date_gne__c >= :Date.today())
                    ORDER BY Index_gne__c
            ];

            Map<Id, EMS_Checklist_Response_gne__c> checklistResponse = new Map<Id, EMS_Checklist_Response_gne__c>();
            for (EMS_Checklist_Response_gne__c item : [SELECT Is_Checked_gne__c, Text_gne__c, EMS_Checklist_gne__c, EMS_Event_gne__r.Approval_Date_gne__c FROM EMS_Checklist_Response_gne__c WHERE EMS_Event_gne__c = :eventID AND EMS_Checklist_gne__c IN :checklists]) {
                checklistResponse.put(item.EMS_Checklist_gne__c, item);
            }

            List<ComplianceRecord> acknowledgementStatements = new List<ComplianceRecord>();
            for (EMS_Checklist_gne__c item : checklists) {
                String itemText = '';
                // If event is approved, that means user has agreed with requirements
                Boolean checked = String.isBlank(approvalDate) ? false : true;
                if (checklistResponse.get(item.Id) != null) {
                    itemText = checklistResponse.get(item.Id).Text_gne__c;
                    checked = checklistResponse.get(item.Id).Is_Checked_gne__c;
                }
                acknowledgementStatements.add(new ComplianceRecord(
                        item,
                        item.Index_gne__c,
                        item.Item_gne__c,
                        item.Is_Parent_gne__c,
                        item.Has_Parent_gne__c,
                        checked,
                        item.Is_One_Choice_gne__c,
                        item.Is_Multi_Choice_gne__c,
                        item.Is_All_Choice_gne__c,
                        item.Requires_Input_gne__c,
                        itemText,
                        item.Depends_On_gne__c,
                        item.Has_Depending_Items_gne__c,
                        item.Parent_Index_gne__c
                ));
            }

            if (checklists.size() == 1) {
                response.acknowledgementStatement = acknowledgementStatements[0];
                response.isSuccess = true;
            } else if (checklists.size() == 0) {
                response.addError('There is no Compliance Requirement record.');
            } else {
                response.addError('The number of Compliance Requirement records is more than one, which does not comply with requirements.');
            }
        } catch (Exception e) {
            response.addError(e.getMessage());
        }
        return response;
    }

    @RemoteAction
    public static EMS_Remote_Response agreeWithStatement(String statementID, String eventID, Boolean isChecked, String statementText) {
        EMS_Remote_Response response = new EMS_Remote_Response();
        response.isSuccess = false;
        try {
            List<EMS_Checklist_Response_gne__c> responses = [SELECT Is_Checked_gne__c, Text_gne__c, EMS_Checklist_gne__c FROM EMS_Checklist_Response_gne__c WHERE EMS_Event_gne__c = :eventID AND EMS_Checklist_gne__c = :statementID];
            if (responses.isEmpty()) {
                // no existing responses, let's create a new one
                insert (new EMS_Checklist_Response_gne__c(
                        EMS_Event_gne__c = eventID,
                        EMS_Checklist_gne__c = statementID,
                        Is_Checked_gne__c = isChecked,
                        Text_gne__c = statementText
                ));
                response.isSuccess = true;
            } else {
                // change an existing response, it should be one record
                responses[0].Is_Checked_gne__c = isChecked;
                responses[0].Text_gne__c = statementText;
                update responses[0];
                response.isSuccess = true;
            }
        } catch (Exception e) {
            response.addError(e.getMessage());
        }
        return response;
    }

    @RemoteAction
    public static EMS_Remote_Response remoteDeleting(String eventID) {
        EMS_Remote_Response response = new EMS_Remote_Response();
        response.isSuccess = false;

        Savepoint savePoint = Database.setSavepoint();
        try {
            EMS_Event_Trigger_Helper.skipTriggerValidationRules = true;
            delete [SELECT Id FROM EMS_Event__c WHERE Id = :eventID LIMIT 1];
            response.isSuccess = true;
        } catch (Exception e) {
            Database.rollback(savePoint);
            response.addError(e.getMessage());
        }
        return response;
    }

    @RemoteAction
    public static EMS_Remote_Response remoteSaving(String eventJSON, Boolean doOwnerTerritoryUpdate, Boolean doRequestorTerritoryUpdate, Boolean typeHasChanged) {
        EMS_Event__c parsedEvent = (EMS_Event__c) JSON.deserialize(eventJSON, EMS_Event__c.class);
        EMS_Remote_Response response = new EMS_Remote_Response();
        response.isSuccess = false;

        Savepoint savePoint = Database.setSavepoint();
        try {
            Map<String, List<SelectOption>> userTerritories = new Map<String, List<SelectOption>>();
            if (String.isNotBlank(parsedEvent.Event_Requestor_gne__c)) {
                List<SelectOption> territories = getTerritories(parsedEvent.Event_Requestor_gne__c);
                userTerritories.put(String.valueOf(parsedEvent.Event_Requestor_gne__c).substring(0, 14), territories);

                if (doRequestorTerritoryUpdate) {
                    if (territories.size() == 1) {
                        parsedEvent.Assigned_To_Territory_Requestor_gne__c = territories[0].getValue();
                    } else {
                        parsedEvent.Assigned_To_Territory_Requestor_gne__c = '';
                    }
                }
            }
            if (String.isNotBlank(parsedEvent.Event_Owner_gne__c)) {
                List<SelectOption> territories = getTerritories(parsedEvent.Event_Owner_gne__c);
                userTerritories.put(String.valueOf(parsedEvent.Event_Owner_gne__c).substring(0, 14), territories);
                if (doOwnerTerritoryUpdate) {
                    if (territories.size() == 1) {
                        parsedEvent.Assigned_To_Territory_Owner_gne__c = territories[0].getValue();
                    } else {
                        parsedEvent.Assigned_To_Territory_Owner_gne__c = '';
                    }
                }
            }

            List<EMS_Event_Configuration_gne__c> eventConfig = [
                    SELECT Max_Attendee_Count_gne__c
                    FROM EMS_Event_Configuration_gne__c
                    WHERE Event_Type_gne__c = :parsedEvent.Event_Type_gne__c AND Event_Sub_Type_gne__c = :parsedEvent.Event_Sub_Type_gne__c
                    LIMIT 1
            ];
            if (!eventConfig.isEmpty()) {
                parsedEvent.Maximum_Attendees__c = Integer.valueOf(eventConfig[0].Max_Attendee_Count_gne__c);
            }

            EMS_Event_Trigger_Helper.skipTriggerValidationRules = true;
            update parsedEvent;

            response.isSuccess = true;
            response.userTerritories = userTerritories;
            response.responseObject = getEventByID(parsedEvent.Id);
        } catch (Exception e) {
            response.addError(e.getMessage());
            Database.rollback(savePoint);
        }
        return response;
    }

    @RemoteAction
    public static Map<String, String> getGSDAccountInfo(String gsdAccountID) {
        Map<String, String> response = new Map<String, String>();

        //check to see what type of id was passed in
        if (gsdAccountID.startsWith(Schema.SObjectType.Address_vod__c.getKeyPrefix())) {
            Address_vod__c address = [SELECT Account_vod__c, Account_vod__r.Name FROM Address_vod__c WHERE Id = :gsdAccountID];
            if (address != null) {
                response.put(address.Account_vod__c, address.Account_vod__r.Name);
            }
        } else if (gsdAccountID.startsWith(Schema.SObjectType.Account.getKeyPrefix())) {
            Account acct = [SELECT Name FROM Account WHERE Id = :gsdAccountID LIMIT 1];
            response.put(gsdAccountID, acct.Name);
        } else {
            Account acct;
            try {
                GNE_Stg_Party_Dao ptyDao = new GNE_Stg_Party_Dao(false);
                acct = ptyDao.subscribeAddress(gsdAccountID);
                String temp = (String) acct.get('Name');
                response.put(gsdAccountID, acct.Name);
            } catch (System.NullPointerException e) {
                acct = [SELECT Name FROM Account WHERE Id = :gsdAccountID LIMIT 1];
                response.put(gsdAccountID, acct.Name);
            } catch (Exception e) {
                response = null;
            }
        }
        return response;
    }

    @RemoteAction
    public static EMS_Remote_Response approveRejectRecallBudgetAllocations(String action, List<String> baIds, List<String> processInstanceWorkitemIds, List<String> amounts, String comments) {
        EMS_Remote_Response response = new EMS_Remote_Response();

        List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();
        for (String processInstanceWorkitemId : processInstanceWorkitemIds) {
            Approval.ProcessWorkitemRequest request = new Approval.ProcessWorkitemRequest();
            request.setComments(comments);
            request.setAction(action);
            request.setWorkitemId(processInstanceWorkitemId);

            requests.add(request);
        }

        Savepoint sp = Database.setSavepoint();
        try {
            List<EMS_Budget_Allocation_gne__c> basToUpdate = new List<EMS_Budget_Allocation_gne__c>();
            for (Integer i = 0; i < baIds.size(); i++) {
                EMS_Budget_Allocation_gne__c ba = new EMS_Budget_Allocation_gne__c(Id = baIds[i]);
                ba.Comments_gne__c = comments;
                if (action == 'Approve' && amounts != null && !String.isBlank(amounts[i])) {
                    ba.Allocated_Budget_gne__c = Decimal.valueOf(amounts[i]);
                }
                basToUpdate.add(ba);
            }
            update basToUpdate;

            List<Approval.ProcessResult> result = Approval.process(requests);
            response.isSuccess = true;
        } catch (Exception ex) {
            Database.rollback(sp);
            response.isSuccess = false;
            response.addError(ex.getMessage());
        }

        return response;
    }

    @RemoteAction
    public static EMS_Remote_Response approveRejectRecallEvent(String action, String eventId, String processInstanceWorkitemId, String comments) {
        EMS_Remote_Response response = new EMS_Remote_Response();

        Approval.ProcessWorkitemRequest request = new Approval.ProcessWorkitemRequest();
        request.setComments(comments);
        request.setAction(action);
        request.setWorkitemId(processInstanceWorkitemId);

        Savepoint sp = Database.setSavepoint();
        try {
            EMS_Event__c event = new EMS_Event__c(Id = eventId);
            event.Approval_Rejection_Comments_gne__c = comments;
            update event;

            Approval.ProcessResult result = Approval.process(request);
            response.isSuccess = true;
        } catch (Exception ex) {
            Database.rollback(sp);
            response.isSuccess = false;
            response.addError(ex.getMessage());
        }

        return response;
    }

    @RemoteAction
    public static String getEventDefinition(Id eventId) {
        EMS_Event__c currentEvent = [
                SELECT Id, Event_Type_gne__c, Event_Sub_Type_gne__c
                FROM EMS_Event__c
                WHERE Id = :eventId
        ];
        List<EMS_Event_Configuration_gne__c> currentConfiguration = [
                SELECT Id, Description_gne__c
                FROM EMS_Event_Configuration_gne__c
                WHERE Event_Type_gne__c = :currentEvent.Event_Type_gne__c
                AND Event_Sub_Type_gne__c = :currentEvent.Event_Sub_Type_gne__c
                LIMIT 1
        ];
        return currentConfiguration.isEmpty() ? '' : currentConfiguration[0].Description_gne__c;
    }

    @RemoteAction
    public static ButtonsVisibilityResponse calculateButtons(String eventJSON) {
        ButtonsVisibilityResponse response = new ButtonsVisibilityResponse((EMS_Event__c) JSON.deserialize(eventJSON, EMS_Event__c.class));
        return response;
    }

    // **** INTERNAL CLASSES **** //
    public class ButtonsVisibilityResponse {
        public Map<String, Boolean> visibilityMap { get; private set; }
        public EMS_Event_Configuration_gne__c eventConfiguration { get; private set; }
        EMS_Event__c eventData { get; private set; }

        public Boolean isGrant { get; private set; }
        public Boolean isDonation { get; private set; }
        public Boolean isEventRequestor { get; private set; }
        public Boolean isEventOwner { get; private set; }
        public Boolean isEventApprover { get; private set; }
        public Boolean isEventCreator { get; private set; }
        public Boolean isEventPlanned { get; private set; }
        public Boolean isEventBPSMember { get; private set; }

        public Boolean isAdmin { get; private set; }
        public Boolean isCR { get; private set; }
        public Boolean isBPS { get; private set; }
        public Boolean isReadOnly { get; private set; }

        public Boolean isPendingApproval { get; private set; }
        public Boolean isAarcUploadsContract { get; private set; }
        public Boolean isBudgetApprovalRequired { get; private set; }

        public Boolean isEventSubmitter { get; private set; }
        public Boolean isBudgetSubmitter { get; private set; }
        public Boolean isBudgetApprover { get; private set; }
        public Boolean isOnlyBudgetOwner { get; private set; }

        private Id eventApproverId { get; set; }
        private Id currentUserId { get; set; }

        private Map<Id, EMS_Budget_Allocation_gne__c> budgetAllocations {
            get {
                if (budgetAllocations == null) {
                    budgetAllocations = new Map<Id, EMS_Budget_Allocation_gne__c>([
                            SELECT Id, Budget_Owner_gne__c
                            FROM EMS_Budget_Allocation_gne__c
                            WHERE EMS_Event_gne__c = :eventData.Id
                    ]);
                }
                return budgetAllocations;
            }
            set;
        }

        private List<ProcessInstance> workflowInstances {
            get {
                if (workflowInstances == null) {
                    workflowInstances = [
                            SELECT Id, TargetObjectID, (SELECT Id, CreatedById, OriginalActorId FROM WorkItems ORDER BY CreatedDate DESC)
                            FROM ProcessInstance
                            WHERE TargetObjectId in :targetIds
                    ];
                }
                return workflowInstances;
            }
            set;
        }

        private Set<Id> targetIds {
            get {
                if (targetIds == null) {
                    targetIds = new Set<Id>(budgetAllocations.keySet());
                    targetIds.add(eventData.Id);
                }
                return targetIds;
            }
            set;
        }

        public ButtonsVisibilityResponse(EMS_Event__c data) {
            eventData = data;
            isBudgetApprover = false;
            isBudgetSubmitter = false;
            isEventSubmitter = false;
            isOnlyBudgetOwner = true;
            currentUserId = UserInfo.getUserId();

            for (EMS_Budget_Allocation_gne__c allocation : budgetAllocations.values()) {
                isOnlyBudgetOwner &= allocation.Budget_Owner_gne__c == currentUserId;
            }

            for (ProcessInstance pi : workflowInstances) {
                for (ProcessInstanceWorkitem piw : pi.Workitems) {
                    if (budgetAllocations.containsKey(pi.TargetObjectId)) {
                        if (piw.OriginalActorId != null) isBudgetApprover |= piw.OriginalActorId == currentUserId;
                        if (piw.CreatedById != null) isBudgetSubmitter |= piw.CreatedById == currentUserId;
                    } else if (String.valueOf(eventData.Id).containsIgnoreCase(pi.TargetObjectId)) {
                        if (piw.CreatedById != null) isEventSubmitter |= piw.CreatedById == currentUserId;
                    }
                }
            }

            List<EMS_Event_Configuration_gne__c> eventConfig = [
                    SELECT AARC_Uploads_Contract_gne__c, Submit_to_Approval_Label_gne__c, Budget_Approval_Required_gne__c
                    FROM EMS_Event_Configuration_gne__c
                    WHERE Event_Type_gne__c = :eventData.Event_Type_gne__c
                    AND Event_Sub_Type_gne__c = :eventData.Event_Sub_type_gne__c
                    LIMIT 1
            ];


            if (String.isNotBlank(eventData.Event_Owner_gne__c)) {
                eventApproverId = eventData.Event_Owner_gne__c;
                Map<Id, GNE_User_Delegation__c> delegations = EMS_Util.getUserDelegations();
                if (delegations.containsKey(eventApproverId)) {
                    eventApproverId = delegations.get(eventApproverId).Delegated_User__c;
                }
            }

            eventConfiguration = eventConfig.isEmpty() ? new EMS_Event_Configuration_gne__c() : eventConfig[0];
            isAarcUploadsContract = eventConfiguration.AARC_Uploads_Contract_gne__c;
            isGrant = String.isNotBlank(eventData.Event_Sub_type_gne__c) && eventData.Event_Sub_type_gne__c.containsIgnoreCase('Grant');
            isDonation = String.isNotBlank(eventData.Event_Sub_type_gne__c) && eventData.Event_Sub_type_gne__c.containsIgnoreCase('Donation');
            isEventRequestor = String.isNotBlank(eventData.Event_Requestor_gne__c) && eventData.Event_Requestor_gne__c == currentUserId ;
            isEventOwner = String.isNotBlank(eventData.Event_Owner_gne__c) && eventData.Event_Owner_gne__c == currentUserId ;
            isEventBPSMember = String.isNotBlank(eventData.Assigned_AARC_gne__c) && eventData.Assigned_AARC_gne__c == currentUserId ;
            isEventApprover = eventApproverId == currentUserId;
            isEventPlanned = eventData.Is_Planned_gne__c;
            isEventCreator = eventData.CreatedBy.Id == currentUserId;
            isPendingApproval = eventData.Pending_Budget_Approval_gne__c;
            isAdmin = EMS_Util.isAdmin();
            isCR = EMS_Util.isCR();
            isBPS = EMS_Access.isBPS();
            isReadOnly = EMS_Util.isReadOnly();
            isBudgetApprovalRequired = getBudgetApprovalRequired();

            visibilityMap = new Map<String, Boolean>{
                    'canCancel' => getCanCancel(),
                    'canClose' => getCanClose(),
                    'canDuplicate' => getCanDuplicate(),
                    'canCancellApproval' => getCanCancelApproval(),
                    'canRecall' => getCanRecall(),
                    'canApprove' => getCanApprove(),
                    'canSubmitToCommittee' => getCanSubmitToCommittee(),
                    'canSubmitToMedOpsReview' => getCanSubmitToMedOpsReview(),
                    'canClickAwaitingSignature' => getCanClickAwaitingSignature(),
                    'canSubmitForApproval' => getCanSubmitForApproval(),
                    'canReopen' => getCanReopen(),
                    'canUncancel' => getCanUncancel()
            };
        }

        private Boolean isEventStatus(String expectedStatus) {
            return (String.isNotBlank(eventData.Status_gne__c) && eventData.Status_gne__c.equalsIgnoreCase(expectedStatus));
        }

        private Boolean isEventStatusOverall(String expectedStatus) {
            return (String.isNotBlank(eventData.Overall_Status_gne__c) && eventData.Overall_Status_gne__c.equalsIgnoreCase(expectedStatus));
        }

        private Boolean isEventType(String expectedType) {
            return (String.isNotBlank(eventData.Event_Type_gne__c) && eventData.Event_Type_gne__c.equalsIgnoreCase(expectedType));
        }

        private Boolean getBudgetApprovalRequired() {
            Boolean budgetOwnerOtherThanEventOwner = false;
            for (EMS_Budget_Allocation_gne__c ba : budgetAllocations.values()) {
                budgetOwnerOtherThanEventOwner |= ba.Budget_Owner_gne__c != eventData.Event_Owner_gne__c;
            }

            return (eventConfiguration.Budget_Approval_Required_gne__c && budgetOwnerOtherThanEventOwner) || subtypesWithGDCommitteeApproval.contains(eventData.Event_Sub_Type_gne__c);
        }
        private Boolean getCanCancel() {
            if (isReadOnly) {
                return false;
            }

            return !eventData.Status_gne__c.contains('Pending') && !isEventStatus('Cancelled') && !isEventStatus('Closed') && !isEventStatus('Payment Request Initiated')
                    && (isAdmin || isEventRequestor || isEventOwner);
        }
        private Boolean getCanClose() {
            if (isReadOnly || (!isAdmin && !isEventRequestor && !isEventOwner)) {
                return false;
            }
            if (isEventStatus('Approved') || isEventStatus('Signed Agreement Received') || isEventStatus('Awaiting Signature from HCP') || isEventStatus('Payment Request Initiated')) {
// event types with owner approval
                if (isEventType('GD') && (isDonation || isGrant) && !isEventPlanned) {
                    return true;
                }
            }

            return isEventStatusOverall('Budget Approved') || isEventStatus('Signed Agreement Received') || isEventStatus('Awaiting Signature from HCP') || isEventStatus('Payment Request Initiated') || isEventStatus('Med Ops Approved');
        }
        private Boolean getCanDuplicate() {
            if (isReadOnly) {
                return false;
            }
            return isAdmin || isEventOwner || isEventRequestor;
        }
        private Boolean getCanCancelApproval() {
            if (isReadOnly) {
                return false;
            }
            Set<String> validStatuses = new Set<String>{
                    'Approved',
                    'Awaiting Signature from HCP',
                    'Budget Rejected',
                    'Director / Manager Approved',
                    'Med Ops Approved',
                    'Payment Request Initiated',
                    'Pending Approval',
                    'Pending Committee Review',
                    'Pending Director / Manager Review',
                    'Recalled',
                    'Rejected',
                    'Signed Agreement Received'
            };
            return (isAdmin || isBPS) && validStatuses.contains(eventData.Status_gne__c);
        }
        private Boolean getCanRecall() {
            if (isReadOnly) {
                return false;
            }
            return (!isEventStatus('Pending Med Ops Review') && eventData.Status_gne__c.containsIgnoreCase('Pending') && isEventSubmitter)
                    || isEventStatus('Pending Med Ops Review') && (isEventRequestor || isEventOwner)
                    || isBudgetSubmitter;
        }
        private Boolean getCanApprove() {
            if (!isPendingApproval && (EMS_Util.getUserRole() == 'MedOps' || isAdmin) && isEventStatus('Pending Med Ops Review')) {
                return true;
            } else if (!isPendingApproval && (isEventApprover || isAdmin) && eventData.Status_gne__c.containsIgnoreCase('Pending') && !isEventStatus('Pending Med Ops Review') && !isEventStatus('Pending Event Director Approval')) {
                return true;
            } else if ((isPendingApproval && isAdmin) || isBudgetApprover) {
                return true;
            } else {
                return false;
            }
        }
        private Boolean getCanSubmitToCommittee() {
            if ((eventData.RecordType.Name == 'EMS Cancelled Event') || (eventData.RecordType.Name == 'EMS Closed Event') || isReadOnly) {
                return false;
            }
            if (!isAdmin && !isEventRequestor) {
                return false;
            }

            return isEventType('GD')
                    && (isDonation || isGrant)
                    && !isEventPlanned
                    && (isEventStatus('Unplanned') || isEventStatus('Rejected'))
                    && !isBudgetApprover
                    && (isAdmin || isEventRequestor);
        }
        private Boolean getCanSubmitToMedOpsReview() {
            return false;

            if (isReadOnly || (eventData.RecordType.Name == 'EMS Cancelled Event' || eventData.RecordType.Name == 'EMS Closed Event')) {
                return false;
            }

            Boolean firstCondition = isEventRequestor && isOnlyBudgetOwner;
            Boolean secondCondition = isEventApprover && !isBudgetApprovalRequired;

            return (firstCondition || secondCondition)
                    && (isEventStatus('Unplanned') || isEventStatus('Planned') || isEventStatus('Rejected') || isEventStatus('Med Ops Rejected'));
        }
        private Boolean getCanClickAwaitingSignature() {
            if (isReadOnly || (!isAdmin && !isBPS)) {
                return false;
            }

            Boolean isProperStatus = isEventStatusOverall('Budget Approved') || isEventStatus('Med Ops Approved');

            if (isEventType('GD') && (isGrant || isDonation) && !isEventPlanned && isProperStatus) {
                return true;
            } else if (isEventType('GD') && (isGrant || isDonation) && isEventPlanned && isProperStatus) {
                return true;
            } else if (isProperStatus && isAarcUploadsContract) {
                return true;
            }
            return false;
        }
        private Boolean getCanSubmitForApproval() {
            if ((eventData.RecordType.Name == 'EMS Cancelled Event') || (eventData.RecordType.Name == 'EMS Closed Event') || isReadOnly) {
                return false;
            }

            Boolean isGDStatus = isEventStatus('Planned') || isEventStatus('Rejected') || isEventStatus('Med Ops Rejected');
            Boolean isStatus = isEventStatus('Planned') || isEventStatus('Rejected') || isEventStatus('Med Ops Rejected') || isEventStatus('Unplanned');
            Boolean isCondition = (
                    isEventType('GD') && (isGrant || isDonation) && isEventPlanned && eventData.Cost_Center_Type_gne__c.contains('Medical') && isGDStatus
            ) || isStatus;

            return ((isAdmin || isEventRequestor || isEventBPSMember || (isCR && isEventCreator)) && isCondition) && !getCanSubmitToMedOpsReview() && !getCanSubmitToCommittee();
        }
        private Boolean getCanReopen() {
            if (isReadOnly) {
                return false;
            }
            return isEventStatus('Closed') && (isAdmin || isBPS | isEventRequestor || isEventOwner);
        }
        private Boolean getCanUncancel() {
            return isEventStatus('Cancelled') && isAdmin;
        }
    }

    public class ComplianceRecord {
        public String name { get; set; }
        public Boolean isChecked { get; set; }
        public Boolean isParent { get; set; }
        public Decimal index { get; set; }
        public Boolean hasParent { get; set; }
        public Boolean isOneChoice { get; set; }
        public Boolean isMultiChoice { get; set; }
        public Boolean isAllChoice { get; set; }
        public Boolean requiresInput { get; set; }
        public String itemText { get; set; }
        public Decimal dependsOn { get; set; }
        public Boolean hasDependingItems { get; set; }
        public Decimal parentIndex { get; set; }
        public EMS_Checklist_gne__c checklistItem { get; set; }
        public Boolean isDependentRequired { get; set; } // can be null, if not defined

        public complianceRecord(EMS_Checklist_gne__c checklistItem, Decimal index, String name, Boolean isParent, Boolean hasParent,
                Boolean isChecked, Boolean isOneChoice, Boolean isMultiChoice, Boolean isAllChoice, Boolean requiresInput, String itemText, Decimal dependsOn,
                Boolean hasDependingItems, Decimal parentIndex) {

            this.checklistItem = checklistItem;
            this.IsParent = isParent;
            this.name = name;
            this.index = index;
            this.hasParent = hasParent;
            this.isChecked = isChecked;
            this.isOneChoice = isOneChoice;
            this.isAllChoice = isAllChoice;
            this.isMultiChoice = isMultiChoice;
            this.requiresInput = requiresInput;
            this.itemText = itemText;
            this.dependsOn = dependsOn;
            this.hasDependingItems = hasDependingItems;
            this.parentIndex = parentIndex;
        }

        public complianceRecord(EMS_Checklist_gne__c checklistItem, String name, Boolean isChecked) {
            this.checklistItem = checklistItem;
            this.name = name;
            this.isChecked = isChecked;
        }
    }
}