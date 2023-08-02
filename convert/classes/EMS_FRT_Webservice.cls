/**
 * Created by nakoniej on 2020-07-10.
 */

@RestResource(UrlMapping='/EMS/FRT/*')
global without sharing class EMS_FRT_Webservice {
    static final Map<String, RecordTypeInfo> ALLOCATION_RECORD_TYPES = EMS_Budget_Allocation_gne__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName();
    static final EMS_Interface_Settings__c settings = EMS_Interface_Settings__c.getAll().get('FRT');
    public static final Set<String> allowedStatuses = new Set<String>{
            'Awaiting Signature from HCP',
            'Signed Agreement Received'
    };

    /* -------- WEBSERVICE OBJECTS -------- */

    global class FundRequestEventData {
        public String fundRequestId;
        public Map<String, String> EMS_Event;
        public Map<String, String> EMS_GSD_Detail;
        public Map<String, String> FRT_Data;

        public List<FundRequestBudgets> EMS_Budgets;
    }

    global class FundRequestEventResult {
        public FundRequestEventData source;
        public EMS_Event__c event;
        public EMS_GSD_Detail__c gsdDetail;

        private List<EMS_Budget_Allocation_gne__c> budgetAllocations;

        public FundRequestEventResult(FundRequestEventData data) {
            source = data;

            budgetAllocations = new List<EMS_Budget_Allocation_gne__c>();
        }

        private EMS_Event__c getEvent() {
            String frtId = source.FRT_Data.get('id');
            List<EMS_Event__c> events = [
                    SELECT Id
                    FROM EMS_Event__c
                    WHERE Event_Name_gne__c LIKE :('[' + frtId + ']%')
                    OR FRT_Id__c = :frtId
                    LIMIT 1
            ];
            return events.isEmpty() ? new EMS_Event__c() : events[0];
        }

        private EMS_GSD_Detail__c getGSD(EMS_Event__c event) {
            List<EMS_GSD_Detail__c> details = [
                    SELECT Id, EMS_Event__c
                    FROM EMS_GSD_Detail__c
                    WHERE EMS_Event__c = :event.Id
            ];
            return details.isEmpty() ?  new EMS_GSD_Detail__c() : details[0];
        }

        private Id getUser(String userIdentifier) {
            List<User> users = [
                    SELECT Id
                    FROM User
                    WHERE Email = :userIdentifier
                    LIMIT 1
            ];

            return users.isEmpty() ? null : users[0].Id;
        }

        private String getUserTerritory(String userId) {
            List<EMS_Util.EMS_Territory> territories = EMS_Util.getUserTerritories(userId);
            return territories.isEmpty() ? null : territories[0].Name;
        }

        private void processEvent() {
            event = getEvent();

            System.debug('------- EMS_Event: ');
            for(String key : source.EMS_Event.keySet()) {
                System.debug(key + ' : ' + source.EMS_Event.get(key));
            }

            // requestStatus : Approved - pending contract

            /* --- User data --- */
            event.Assigned_AARC_gne__c = getUser(source.EMS_Event.get('seaUser'));
            event.Event_Owner_gne__c = getUser(source.EMS_Event.get('owner'));
            event.Event_Requestor_gne__c = getUser(source.EMS_Event.get('assignee'));

            event.Assigned_To_Territory_Requestor_gne__c = getUserTerritory(event.Event_Requestor_gne__c);
            event.Assigned_To_Territory_Owner_gne__c = getUserTerritory(event.Event_Owner_gne__c);

            event.Event_Name_gne__c = source.EMS_Event.get('eventName');
            event.Event_Sub_Type_gne__c = source.EMS_Event.get('eventSubType');
            event.Event_Type_gne__c = source.EMS_Event.get('eventType');
            if(String.isNotBlank(source.EMS_Event.get('approvedFundingAmount'))) {
                event.Planned_Expenses_gne__c = Decimal.valueOf(source.EMS_Event.get('approvedFundingAmount'));
            }

            if(String.isNotBlank(source.EMS_Event.get('requestTA'))) {
                List<String> therapeuticArea = (List<String>) JSON.deserialize(source.EMS_Event.get('requestTA'), List<String>.class);
                event.Therapeutic_Area_gne__c = therapeuticArea[0];
            }

            if(String.isNotBlank(source.EMS_Event.get('eventStartDate'))) {
                List<String> eventStartDate = source.EMS_Event.get('eventStartDate').split('-'); // eventStartDate : 2020-12-01
                event.Start_Date_gne__c = Date.newInstance(
                        Integer.valueOf(eventStartDate[0]),
                        Integer.valueOf(eventStartDate[1]),
                        Integer.valueOf(eventStartDate[2])
                );
            }

            if(String.isNotBlank(source.EMS_Event.get('eventEndDate'))) {
                List<String> eventEndDate = source.EMS_Event.get('eventEndDate').split('-'); // eventEndDate : 2020-12-31
                event.End_Date_gne__c = Date.newInstance(
                        Integer.valueOf(eventEndDate[0]),
                        Integer.valueOf(eventEndDate[1]),
                        Integer.valueOf(eventEndDate[2])
                );
            }

            /* --- FRT Section --- */
            event.FRT_Id__c = source.FRT_Data.get('id'); /* String */
            event.FRT_Status__c = source.FRT_Data.get('requestStatus'); /* String */

            if(String.isNotBlank(source.EMS_Event.get('requestDate'))) {
                event.Request_date_submitted_frt__c = Datetime.valueOf(
                        source.EMS_Event.get('requestDate')
                ).date();
            }

            event.Contract_Notes_to_BPS__c = source.EMS_Event.get('notesToSEA');
            event.Information_to_be_included_in_Contract__c = source.EMS_Event.get('contractComments');

            if(String.isNotBlank(source.EMS_Event.get('tangibleBenefitsDescription'))) {
                System.debug('tangibleBenefitsDescription' + source.EMS_Event.get('tangibleBenefitsDescription'));
                List<String> tangibleBenefits = (List<String>) JSON.deserialize(source.EMS_Event.get('tangibleBenefitsDescription'), List<String>.class);
                System.debug(tangibleBenefits);
                event.Description_of_Tangible_Benefit__c = String.join(tangibleBenefits, ';');
            }
            event.Other_benefits__c = source.EMS_Event.get('otherBenefits'); /* String */
            event.Other_Funding_Sources__c = Boolean.valueOf(source.EMS_Event.get('otherFundersInvolved'));

            event.Status_gne__c = 'Unplanned';
            event.RecordTypeId = Schema.SObjectType.EMS_Event__c.getRecordTypeInfosByName().get('EMS Event').getRecordTypeId();

            System.debug(event);
        }

        private void processGSD() {
            System.debug('------- EMS_GSD_Detail: ');

            for(String key : source.EMS_GSD_Detail.keySet()) {
                System.debug(key + ' : ' + source.EMS_GSD_Detail.get(key));
            }

            gsdDetail = getGSD(event);
            gsdDetail.Website_URL_gne__c = source.EMS_GSD_Detail.get('patientOrgURL');
            gsdDetail.Request_Summary_gne__c = source.EMS_GSD_Detail.get('requestSummary');
            gsdDetail.Phone_Number_gne__c = '000-000-000';
            gsdDetail.Purpose_gne__c = source.EMS_GSD_Detail.get('purpose');

            gsdDetail.Name_of_Vendor_Signatory_gne__c = source.EMS_GSD_Detail.get('signatoryName');
            gsdDetail.Recipient_Job_Title_gne__c = source.EMS_GSD_Detail.get('signatoryTitle');
            gsdDetail.Email_Address_Vendor_Signatory_gne__c = source.EMS_GSD_Detail.get('signatoryEmail');

            gsdDetail.Institution_gne__c = source.EMS_GSD_Detail.get('payableToName');
            gsdDetail.Email_Address_gne__c = source.EMS_GSD_Detail.get('payableToEmail');
            gsdDetail.Street_1_gne__c = source.EMS_GSD_Detail.get('payableToStreet');
            gsdDetail.Street_2_gne__c = source.EMS_GSD_Detail.get('payableToStreet2');
            gsdDetail.City_gne__c = source.EMS_GSD_Detail.get('payableToCity');
            gsdDetail.Province_gne__c = source.EMS_GSD_Detail.get('payableToProvince');
            gsdDetail.Postal_Code_gne__c = source.EMS_GSD_Detail.get('payableToPostalCode');
            gsdDetail.Country_gne__c = source.EMS_GSD_Detail.get('payableToCountry');

            System.debug(gsdDetail);
        }

        private void processBudgetAllocations() {
            for(FundRequestBudgets data : source.EMS_Budgets) {
                System.debug('------- EMS_Budgets: ');
                for(String key : data.fields.keySet()) {
                    System.debug(key + ' : ' + data.fields.get(key));
                }

                EMS_Budget_Allocation_gne__c ba = data.parsePayload(event);
                if(ba != null) {
                    budgetAllocations.add(ba);
                }
            }
        }

        public EMS_Event__c processPayload() {
            processEvent();
            processGSD();
            processBudgetAllocations();

            System.debug('------- FRT_Data: ');
            for(String key : source.FRT_Data.keySet()) {
                System.debug(key + ' : ' + source.FRT_Data.get(key));
            }

            return event;
        }

        public Boolean savePayload() {
            EMS_Event_Trigger_Helper.skipTriggerValidationRules = true;
            upsert event;
            if(String.isBlank(gsdDetail.EMS_Event__c)) {
                gsdDetail.EMS_Event__c = event.Id;
            }

            EMS_GSD_Detail_Validation_Rules.skipValidationRules = true;
            upsert gsdDetail;

            for(EMS_Budget_Allocation_gne__c allocation : budgetAllocations) {
                if(String.isBlank(allocation.EMS_Event_gne__c)) {
                    allocation.EMS_Event_gne__c = event.Id;
                }
            }
            upsert budgetAllocations;

            event = [
                    SELECT Id, Name, Status_gne__c, Start_Date_gne__c, End_Date_gne__c, Event_Type_gne__c, Event_Sub_Type_gne__c
                    FROM EMS_Event__c
                    WHERE Id = :event.Id
            ];

            return true;
        }
    }

    global class FundRequestBudgets {
        public Map<String, String> fields;
        public EMS_Budget_Allocation_gne__c result;

        public EMS_Budget_Allocation_gne__c parsePayload(EMS_Event__c event) {
            result = new EMS_Budget_Allocation_gne__c();

            Id requestorId = event.Event_Requestor_gne__c;
            Id ownerId = event.Event_Owner_gne__c;
            String costCenterName = fields.get('costCenter');


            Decimal plannedExpenses = event.Planned_Expenses_gne__c;
            Decimal percentage = Decimal.valueOf(fields.get('percentage')) / 100;
            Decimal amount = plannedExpenses * percentage;

            List<EMS_Budget_Allocation_gne__c> allocations =  [
                    SELECT Id, EMS_Event_gne__c, Allocated_Budget_gne__c, Percentage_Contribution_gne__c, Cost_Center_gne__c
                    FROM EMS_Budget_Allocation_gne__c
                    WHERE Cost_Center_gne__c = :costCenterName
                    AND EMS_Event_gne__c = :event.Id
                    AND Allocated_Budget_gne__c = :amount
            ];

            if(!allocations.isEmpty()) {
                System.debug('Found matching Budget Allocations: ');
                for(EMS_Budget_Allocation_gne__c allocation : allocations) {
                    System.debug(allocation);
                }

                result = allocations[0];
                return result;
            }

            List<EMS_Cost_Center_gne__c> costCenters = [
                    SELECT Id FROM EMS_Cost_Center_gne__c WHERE Name = :costCenterName
            ];
            EMS_Cost_Center_gne__c costCenter;

            if(costCenters.isEmpty()) {
                return null;
            } else {
                costCenter = costCenters[0];
            }

            for(EMS_Budget_Product_gne__c budget : [
                    SELECT Id, Product_Balance_gne__c
                    FROM EMS_Budget_Product_gne__c
                    WHERE Cost_Center_gne__c = :costCenter.Id AND
                    Status_gne__c = 'Active' AND (
                            Assigned_to_gne__c = :requestorId
                            OR Assigned_to_gne__c = :ownerId
                    )
            ]) {
                result = new EMS_Budget_Allocation_gne__c(
                        EMS_Product_Budget_gne__c = budget.Id,
                        Allocated_Budget_gne__c = Math.min(amount, budget.Product_Balance_gne__c),
                        Percentage_Contribution_gne__c = percentage,
                        RecordTypeId = ALLOCATION_RECORD_TYPES.get('Product_Budget_Allocation').getRecordTypeId()
                );

                return result;
            }

            for(EMS_Budget_Region_gne__c budget : [
                    SELECT Id, Region_Balance_gne__c
                    FROM EMS_Budget_Region_gne__c
                    WHERE Cost_Center_gne__c = :costCenter.Id AND
                    Status_gne__c = 'Active' AND (
                            Assigned_to_gne__c = :requestorId
                            OR Assigned_to_gne__c = :ownerId
                    )
            ]) {
                result = new EMS_Budget_Allocation_gne__c(
                        EMS_Region_Budget_gne__c = budget.Id,
                        Allocated_Budget_gne__c = Math.min(amount, budget.Region_Balance_gne__c),
                        Percentage_Contribution_gne__c = percentage,
                        RecordTypeId = ALLOCATION_RECORD_TYPES.get('Region_Budget_Allocation').getRecordTypeId()
                );

                return result;
            }

            for(EMS_Budget_Territory_gne__c budget : [
                    SELECT Id, Territory_Balance_gne__c
                    FROM EMS_Budget_Territory_gne__c
                    WHERE Cost_Center_gne__c = :costCenter.Id AND
                    Status_gne__c = 'Active' AND (
                            Assigned_to_gne__c = :requestorId
                            OR Assigned_to_gne__c = :ownerId
                    )
            ]) {
                result = new EMS_Budget_Allocation_gne__c(
                        EMS_Territory_Budget_gne__c = budget.Id,
                        Allocated_Budget_gne__c = Math.min(amount, budget.Territory_Balance_gne__c),
                        Percentage_Contribution_gne__c = percentage,
                        RecordTypeId = ALLOCATION_RECORD_TYPES.get('Territory_Budget_Allocation').getRecordTypeId()
                );

                return result;
            }

            return null;
        }
    }

    /* -------- WEBSERVICE METHODS -------- */

    @HttpPost
    global static List<FundRequestEventResult> loadFundRequestEvents(List<FundRequestEventData> payload) {
        List<FundRequestEventResult> results = new List<FundRequestEventResult>();
        for(FundRequestEventData payloadData : payload) {
            FundRequestEventResult result = new FundRequestEventResult(payloadData);
            result.processPayload();
            result.savePayload();
            results.add(result);
        }
        return results;
    }

    @HttpPatch
    global static List<FundRequestEventResult> updateFundRequestEvents(List<FundRequestEventData> payload) {
        List<FundRequestEventResult> results = new List<FundRequestEventResult>();
        for (FundRequestEventData payloadData : payload) {
            FundRequestEventResult result = new FundRequestEventResult(payloadData);
            result.processPayload();
            results.add(result);
        }
        return results;
    }

    @HttpGet
    global static List<EMS_Event__c> listFRTEvents() {
        RestRequest req = RestContext.request;
        String eventId = req.params.get('id');

        if(String.isNotBlank(eventId)) {
            return [
                    SELECT Id, Status_gne__c, FRT_Id__c
                    FROM EMS_Event__c
                    WHERE Id = :eventId
            ];
        } else {
            return [
                    SELECT Id, Status_gne__c, FRT_Id__c
                    FROM EMS_Event__c
                    WHERE FRT_Id__c != NULL
                    LIMIT 100
            ];
        }

    }

    public static void onAfterUpdate(Map<Id, EMS_Event__c> oldEventsMap, List<EMS_Event__c> newEvents) {
        if (settings == null
                || String.isBlank(settings.Endpoint_URL__c)
                || String.isBlank(settings.API_KEY__c)) {
            System.debug('FRT Interface settings invalid ' + settings);
            return;
        }

        for (EMS_Event__c event : newEvents) {
            EMS_Event__c oldEvent = oldEventsMap.get(event.Id);
            Set<String> allowedStatuses = new Set<String>{
                    'Awaiting Signature from HCP',
                    'Signed Agreement Received'
            };

            if (oldEvent.Status_gne__c != event.Status_gne__c && String.isNotBlank(event.FRT_Id__c) && allowedStatuses.contains(event.Status_gne__c)) {
                sendEventStatus(new EMS_Event__c(
                        Id = event.Id,
                        FRT_Id__c = event.FRT_Id__c,
                        Status_gne__c = event.Status_gne__c
                ));
            }
        }
    }

    @Future(Callout=true)
    public static void sendEventStatusFuture(Id eventId) {
        sendEventStatus([
                SELECT Id, Status_gne__c, FRT_Id__c FROM EMS_Event__c WHERE Id = :eventId
        ]);
    }

    public static void sendEventStatus(EMS_Event__c event) {
        if (settings == null
                || String.isBlank(settings.Endpoint_URL__c)
                || String.isBlank(settings.API_KEY__c)) {
            System.debug('FRT Interface settings invalid ' + settings);
            return;
        }

        if(!allowedStatuses.contains(event.Status_gne__c)) {
            System.debug('Incorrect Status to send to frt: ' + event.Status_gne__c);
            return;
        }

        if(String.isBlank(event.FRT_Id__c)) {
            System.debug('Missing FRT Id');
            return;
        }

        Map<String, String> requestBody = new Map<String, String> {
                'status' => event.Status_gne__c
        };

        System.debug('---- Sending EMS Event to FRT ' + event);

        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint(settings.Endpoint_URL__c + event.FRT_Id__c);
        request.setHeader('FRT-API-Key', settings.API_KEY__c);
        request.setHeader('Content-Type','application/json;charset=UTF-8');
        request.setBody(JSON.serialize(requestBody));

        HttpResponse response = new Http().send(request);
        FundRequestEventData responseData = (FundRequestEventData) JSON.deserialize(response.getBody(), FundRequestEventData.class);
        EMS_Event__c updatedEvent = new EMS_Event__c(
                Id = event.Id,
                FRT_Sync_Time__c = Datetime.now(),
                FRT_Sync_Status__c = response.getStatus()
        );

        if(String.isNotBlank(responseData.FRT_Data.get('requestStatus'))) {
            updatedEvent.FRT_Status__c = responseData.FRT_Data.get('requestStatus');
        }

        Database.update(updatedEvent);
    }
}