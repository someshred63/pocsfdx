public with sharing class EMS_Main_Menu_Ctrl {

    public static Integer moreMenuColumnsSize { get; set; }
    public List<DynamicLink> menuList { get; set; }
    public List<List<DynamicLink>> links { get; set; }
    public Boolean mySetupAccess { get; private set; }

    // Attributes in component
    public String recordID { get; set; }
    public String sobjectAPIName { get; set; }
    public String pageName { get; set; }
    public Boolean forceReadonly { get; set; }
    public String userThumbPhoto;

    public EMS_Main_Menu_Ctrl() {
        try {
            init();
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, '## message: ' + e.getMessage());
            System.debug(LoggingLevel.ERROR, '## stack trace: ' + e.getStackTraceString());
            ApexPages.addMessages(e);
        }
    }

    public static final String fundRequestQuery = 'SELECT count() FROM EMS_Fund_Request_gne__c WHERE Status_gne__c = \'Submitted\' AND Approver_gne__c = \'' + UserInfo.getUserId() + '\'';
    public static final String eventRequestMedOpsQuery = 'SELECT count() FROM EMS_Event__c WHERE (Approver_gne__c = \'' + UserInfo.getUserId() + '\' AND (Status_gne__c = \'Pending Committee Review\' OR Status_gne__c = \'Pending Approval\')) OR Status_gne__c = \'Pending Med Ops Review\'';
    public static final String eventRequestQuery = 'SELECT count() FROM EMS_Event__c WHERE Status_gne__c LIKE \'%Pending%\' AND Status_gne__c != \'Pending Med Ops Review\' AND Status_gne__c != \'Pending Event Director Approval\' AND Approver_gne__c = \'' + UserInfo.getUserId() + '\' AND Pending_Budget_Approval_gne__c = false';
    public static final String budgetAllocationQuery = 'SELECT count() FROM EMS_Budget_Allocation_gne__c WHERE Status_gne__c = \'Submitted\' AND Approver_gne__c = \'' + UserInfo.getUserId() + '\'';
    public static final String dcrQuery = 'select count() from EMS_Data_Change_Request_gne__c WHERE Status_gne__c IN (\'Submitted\', \'New\')';
    public static final String dcrBpsQuery = 'select count() from EMS_Data_Change_Request_gne__c WHERE Assigned_BPS_gne__c = \'' + UserInfo.getUserId() + '\' AND Status_gne__c IN (\'Submitted\')';

    public static Integer tasksCount {
        get {
            if (tasksCount == null) tasksCount = fundRequestCount + eventRequestCount + budgetsAllocationCount + dcrCount + dcrBpsCount;
            return tasksCount;
        }
        private set;
    }
    public static Integer fundRequestCount { get {return EMS_Util.isAdmin() ? 0 : Database.countQuery(fundRequestQuery);} }
    public static Integer dcrBpsCount { get {return EMS_Util.isAdmin() ? 0 : Database.countQuery(dcrBpsQuery);} }
    public static Integer eventRequestCount { get {return EMS_Util.isAdmin() ? 0 : EMS_Util.getUserRole() == 'MedOps' ? Database.countQuery(eventRequestMedOpsQuery) : Database.countQuery(eventRequestQuery);} }
    public static Integer budgetsAllocationCount { get {return EMS_Util.isAdmin() ? 0 : EMS_Util.getUserRole() == 'MedOps' ? 0 : Database.countQuery(budgetAllocationQuery);} }
    public static Integer dcrCount { get {return EMS_Util.isAdmin() ? Database.countQuery(dcrQuery) : 0;} }

    private void init() {
        mySetupAccess = false;
        moreMenuColumnsSize = Integer.valueOf([SELECT More_Menu_Clumn_Size__c FROM GNE_SFA2_Main_Menu_Settings__c LIMIT 1].More_Menu_Clumn_Size__c); // Read value from custom setting

        List<SFA2_User_Sales_Roster_gne__c> userSalesRosterList = GNE_SFA2_Util.getUserSalesRosters(UserInfo.getUserId());
        if (userSalesRosterList.isEmpty()) {
            ApexPages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR, 'User Sales Roster Configuration is not valid.'));
        } else {

            Map<String, List<SFA2_User_Sales_Roster_gne__c>> salesRostersMap = new Map<String, List<SFA2_User_Sales_Roster_gne__c>>();
            for (SFA2_User_Sales_Roster_gne__c userSalesRosterItem : getUserSalesRosters()) {
                if (userSalesRosterItem.Sales_Roster_gne__r.Type_gne__c != GNE_SFA2_Application_Cache.userApplicationContext.App_Name_gne__c) {
                    if (salesRostersMap.get(userSalesRosterItem.Sales_Roster_gne__r.Type_gne__c) == null) {
                        salesRostersMap.put(userSalesRosterItem.Sales_Roster_gne__r.Type_gne__c, new List<SFA2_User_Sales_Roster_gne__c>{
                                userSalesRosterItem
                        });
                    } else {
                        salesRostersMap.get(userSalesRosterItem.Sales_Roster_gne__r.Type_gne__c).add(userSalesRosterItem);
                    }
                }
            }

            Map<String, List<DynamicLink>> menuToMenuSubitem = new Map<String, List<DynamicLink>>();
            links = new List<List<DynamicLink>>();
            menuList = new List<DynamicLink>();
            List<SFA2_Configuration_Object_gne__c> sfa2Configurations = getSFA2Configurations();
            if (!sfa2Configurations.isEmpty()) {
                for (SFA2_Configuration_Object_gne__c sfa2Config : sfa2Configurations) {

                    // Menu buttons
                    DynamicLink menu = new DynamicLink();
                    menu.strName = sfa2Config.Name;
                    if (sfa2Config.Attributes_gne__c != null) {
                        List<String> attributes = (sfa2Config.Attributes_gne__c).split(';');
                        if (attributes.size() > 0) {
                            menu.pageRef = attributes[0];
                        }
                        if (attributes.size() > 1) {
                            menu.imgSrc = attributes[1].trim();
                        }
                        if (attributes.size() > 2) {
                            menu.linkId = attributes[2];
                        }
                    }
                    menuList.add(menu);

                    // Details (subitems) for each menu button
                    for (SFA2_Configuration_Object_Detail_gne__c sfa2ConfigDetails : sfa2Config.Configuration_Objects__r) {
                        // Subitems
                        List<DynamicLink> menuSubitems;

                        if (String.isNotEmpty(sfa2ConfigDetails.API_Name_gne__c) && sfa2ConfigDetails.API_Name_gne__c.equalsIgnoreCase('ApplicationsList')) {
                            for (String applicationType : salesRostersMap.keySet()) {
                                if (applicationType != GNE_SFA2_Application_Cache.userApplicationContext.App_Name_gne__c) {
                                    // Creating a new Menu Subitem
                                    DynamicLink menuSubitem = new DynamicLink();
                                    menuSubitem.strName = sfa2ConfigDetails.Name;
                                    menuSubitem.apiName = sfa2ConfigDetails.API_Name_gne__c;

                                    if (applicationType.equalsIgnoreCase('SFA-US') && salesRostersMap.get(applicationType).size() > 1) { // multibrand scenario
                                        menuSubitem.strLabel = 'SFA 2.0';
                                        menuSubitem.pageRef = '/apex/GNE_SFA2_Application_Dispatcher?application=' + applicationType;
                                    } else {
                                        if (salesRostersMap.get(applicationType)[0].Sales_Roster_gne__r.Brand_Name_gne__c == null) {
                                            menuSubitem.strLabel = salesRostersMap.get(applicationType)[0].Sales_Roster_gne__r.Type_gne__c;
                                        } else {
                                            menuSubitem.strLabel = salesRostersMap.get(applicationType)[0].Sales_Roster_gne__r.Type_gne__c + ' ' + salesRostersMap.get(applicationType)[0].Sales_Roster_gne__r.Brand_Name_gne__c;
                                        }
                                        menuSubitem.pageRef = '/apex/GNE_SFA2_Application_Dispatcher?application=' + applicationType;
                                    }

                                    // Adding a new Subitem to all existing ones
                                    menuSubitems = menuToMenuSubitem.get(sfa2ConfigDetails.Name);
                                    // If column is full or null, create a new one
                                    if (menuSubitems == null || menuSubitems.size() == moreMenuColumnsSize) {
                                        menuSubitems = new List<DynamicLink>();
                                        menuToMenuSubitem.put(sfa2ConfigDetails.Name, menuSubitems);
                                        links.add(menuSubitems);
                                    }
                                    menuSubitems.add(menuSubitem);
                                }
                            }

                        } else {
                            // Creating a new Menu Subitem
                            DynamicLink menuSubitem = new DynamicLink();
                            menuSubitem.strName = sfa2ConfigDetails.Name;
                            menuSubitem.strLabel = sfa2ConfigDetails.Label_gne__c;

                            if (sfa2ConfigDetails.Attributes_gne__c != null) {
                                menuSubitem.strAttribute = sfa2ConfigDetails.Attributes_gne__c;
                                List<String> strMenuItemArray = (menuSubitem.strAttribute).split(';');
                                if (strMenuItemArray.size() > 0) {
                                    if (strMenuItemArray[0] == 'Revegy_Business_Planning') {
                                        menuSubitem.pageRef = GNE_SFA2_Revegy_Utils.getStandaloneUrl();
                                    } else {
                                        menuSubitem.pageRef = strMenuItemArray[0];
                                    }
                                }
                                if (strMenuItemArray.size() > 1) {
                                    menuSubitem.imgSrc = strMenuItemArray[1].trim();
                                }
                                if (strMenuItemArray.size() > 2) {
                                    menuSubitem.linkId = strMenuItemArray[2];
                                }
                            }

                            // Adding a new Subitem to all existing ones
                            menuSubitems = menuToMenuSubitem.get(sfa2ConfigDetails.Name);
                            // If column is full or null, create a new one
                            if (menuSubitems == null || menuSubitems.size() == moreMenuColumnsSize) {
                                menuSubitems = new List<DynamicLink>();
                                menuToMenuSubitem.put(sfa2ConfigDetails.Name, menuSubitems);
                                links.add(menuSubitems);
                            }
                            menuSubitems.add(menuSubitem);
                        }
                    }
                }
            }
            if (GNE_SFA2_Util.isCanadaMSL()) {
	            DynamicLink synapseApp = new DynamicLink();
	            synapseApp.strName = 'External Links';
	            synapseApp.apiName = 'ApplicationsList';
	            synapseApp.strLabel = 'Synapse';
	            synapseApp.pageRef = GNE_SFA2_S2S_Config_Items_gne__c.getInstance('MABaseUrl').Value_gne__c;
            	links.get(links.size() -1).add(synapseApp);
                
                mySetupAccess = true;
            }
        }
    }

    private List<SFA2_User_Sales_Roster_gne__c> getUserSalesRosters() {
        List<SFA2_User_Sales_Roster_gne__c> userSalesRosters = [
                SELECT Role_gne__c, Sales_Roster_gne__r.Brand_Name_gne__c, Sales_Roster_gne__r.Type_gne__c, Sales_Roster_gne__r.Is_SFA2_Available_gne__c
                FROM SFA2_User_Sales_Roster_gne__c
                WHERE User_gne__c = :UserInfo.getUserId() AND Is_Active_gne__c = true AND Sales_Roster_gne__r.Is_SFA2_Available_gne__c = true
                ORDER BY Sales_Roster_gne__r.Type_gne__c, Sales_Roster_gne__r.Brand_Name_gne__c, Role_gne__c
        ];
        return userSalesRosters;
    }

    private List<SFA2_Configuration_Object_gne__c> getSFA2Configurations() {
        List<SFA2_Configuration_Object_gne__c> configs = [
                SELECT Name, Attributes_gne__c, (SELECT Name, Label_gne__c, Attributes_gne__c, Order_gne__c, API_Name_gne__c FROM Configuration_Objects__r WHERE Is_Active_gne__c = true AND Type_gne__c = 'Menu Item' Order BY Order_gne__c ASC)
                FROM SFA2_Configuration_Object_gne__c
                WHERE Role_gne__c = :GNE_SFA2_Application_Cache.userApplicationContext.Role_gne__c AND Brand_gne__c = :GNE_SFA2_Application_Cache.userApplicationContext.Brand_gne__c
                AND Application_Type__c = :GNE_SFA2_Application_Cache.userApplicationContext.App_Name_gne__c AND Configuration_Type_gne__c = 'Menu Layout' AND Is_Active_gne__c = true
                ORDER BY Order_gne__c
        ];
        return configs;
    }

    public String getUserThumbPhoto() {
        Id userId = UserInfo.getUserId();
        String thePhoto = [SELECT SmallPhotoUrl FROM User WHERE User.ID = :userId LIMIT 1].SmallPhotoUrl;
        return thePhoto;
    }

    private static String eventAPIName = EMS_Event__c.sObjectType.getDescribe().getName();
    private static String budgetallocationAPIName = EMS_Budget_Allocation_gne__c.sObjectType.getDescribe().getName();
    private static String productbudgetAPIName = EMS_Budget_Product_gne__c.sObjectType.getDescribe().getName();
    private static String regionbudgetAPIName = EMS_Budget_Region_gne__c.sObjectType.getDescribe().getName();
    private static String territorybudgetAPIName = EMS_Budget_Territory_gne__c.sObjectType.getDescribe().getName();
    private static String travelAPIName = EMS_Travel_gne__c.sObjectType.getDescribe().getName();
    private static String attachmentAPIName = EMS_Attachment_gne__c.sObjectType.getDescribe().getName();
    private static String expenseAPIName = EMS_Expense_gne__c.sObjectType.getDescribe().getName();
    private static String fundrequestAPIName = EMS_Fund_Request_gne__c.sObjectType.getDescribe().getName();
    private static String internationalspeakerAPIName = EMS_International_Speaker_gne__c.sObjectType.getDescribe().getName();
    private static String datachangerequestAPIName = EMS_Data_Change_Request_gne__c.sObjectType.getDescribe().getName();
    private static String paymentqueueAPIName = EMS_Speaker_Role_gne__c.sObjectType.getDescribe().getName();
    private static String costcetnerAPIName = EMS_Cost_Center_gne__c.sObjectType.getDescribe().getName();
    private static String assignmenterrorAPIName = EMS_Assignment_Error_gne__c.sObjectType.getDescribe().getName();
    private static String costcentertypeAPIName = EMS_Cost_Center_Type_gne__c.sObjectType.getDescribe().getName();
    private static String transactionAPIName = EMS_Transaction_gne__c.sObjectType.getDescribe().getName();
    private static String userdelegationsAPIName = GNE_User_Delegation__c.sObjectType.getDescribe().getName();
    private static String userAPIName = User.sObjectType.getDescribe().getName();

    private static Map<Id, EMS_Event__c> eventsMap;
    private static EMS_Event__c getEvent(Id eventId) {
        if (eventsMap == null) eventsMap = new Map<Id, EMS_Event__c>();
        if (!eventsMap.containsKey(eventId)) eventsMap.putAll([SELECT Name FROM EMS_Event__c WHERE Id = :eventId]);
        return eventsMap.get(eventId);
    }


    // Boolean showBreadcrumbs =
    public List<Breadcrumb> getBreadcrumbs() {
        System.debug(LoggingLevel.ERROR, '## recID: ' + recordID + '   API: ' + sobjectAPIName + '    # pageName: ' + pageName);
        List<Breadcrumb> breadcrumbs = new List<Breadcrumb>();
        Boolean deleteLastLink = false;

        // Add Home tab
        breadcrumbs.add(new Breadcrumb('Tasks', Page.EMS_Home.getUrl() + '?nr=true'));

        // Related to Event
        if (sobjectAPIName == eventAPIName) {
            breadcrumbs.add(new Breadcrumb('Events', Page.EMS_Event.getUrl()));
            if (String.isNotBlank(recordID)) {
                EMS_Event__c event = getEvent(recordID);
                breadcrumbs.add(new Breadcrumb(event.name, '/' + event.Id));
            }

            if (String.isNotBlank(pageName) && pageName.equalsIgnoreCase('ems_event_edit_create_layout')) {
                breadcrumbs.add(new Breadcrumb('Edit', '#'));
            }
            deleteLastLink = true;
        }

        if (sobjectAPIName == budgetallocationAPIName) {
            if (String.isNotBlank(recordID)) {
                EMS_Budget_Allocation_gne__c ba = [SELECT Name, EMS_Event_gne__r.Name, EMS_Event_gne__r.Id FROM EMS_Budget_Allocation_gne__c WHERE Id = :recordID LIMIT 1];
                breadcrumbs.add(new Breadcrumb('Events', Page.EMS_Event.getUrl()));
                breadcrumbs.add(new Breadcrumb(ba.EMS_Event_gne__r.Name, '/' + ba.EMS_Event_gne__r.Id));
                breadcrumbs.add(new Breadcrumb(ba.name, '/' + ba.Id));
            }

            if (String.isNotBlank(pageName) && pageName.equalsIgnoreCase('EMS_Budget_Allocation_Edit_Create_Layout')) {
                breadcrumbs.add(new Breadcrumb('Edit', '#'));
            }
            deleteLastLink = true;
        }

        if (String.isBlank(sobjectAPIName) && String.isNotBlank(pageName) && pageName.toLowerCase() == 'ems_budget_allocation_page') {
            if (String.isNotBlank(recordID)) {
                EMS_Event__c event = getEvent(recordID);
                breadcrumbs.add(new Breadcrumb('Events', Page.EMS_Event.getUrl()));
                breadcrumbs.add(new Breadcrumb(event.name, '/' + event.Id));
                breadcrumbs.add(new Breadcrumb('Budget Allocations', '#'));

                deleteLastLink = true;
            }
        }

        if (String.isBlank(sobjectAPIName) && String.isNotBlank(pageName) && pageName.toLowerCase() == 'ems_approve_reject_budget_allocation') {
            if (String.isNotBlank(recordID)) {
                EMS_Budget_Allocation_gne__c ba = [SELECT Name, EMS_Event_gne__r.Name, EMS_Event_gne__r.Id FROM EMS_Budget_Allocation_gne__c WHERE Id = :recordID LIMIT 1];
                breadcrumbs.add(new Breadcrumb('Events', Page.EMS_Event.getUrl()));
                breadcrumbs.add(new Breadcrumb(ba.EMS_Event_gne__r.Name, '/' + ba.EMS_Event_gne__r.Id));
                breadcrumbs.add(new Breadcrumb(ba.name, '/' + ba.Id));

                deleteLastLink = false;
            }
        }

        if (sobjectAPIName == travelAPIName) {
            breadcrumbs.add(new Breadcrumb('Events', Page.EMS_Event.getUrl()));
            Boolean isNewTravel = false;
            if (String.isNotBlank(recordID)) {
                // there are possible two cases
                List<Schema.DescribeSObjectResult> describe = Schema.describeSObjects(new List<String>{
                        eventAPIName, travelAPIName
                });
                // 1) record is a new one. consequently parent object is an even record (EMS_Event__c ID)
                if (recordID.startsWith(describe[0].getKeyPrefix())) {
                    EMS_Event__c event = getEvent(recordID);
                    breadcrumbs.add(new Breadcrumb(event.name, '/' + event.Id));
                    isNewTravel = true;
                }
                // 2) record is being edited (EMS_Travel_gne__c ID)
                if (recordID.startsWith(describe[1].getKeyPrefix())) {
                    EMS_Travel_gne__c t = [SELECT Name, EMS_Event_gne__r.Name, EMS_Event_gne__r.Id FROM EMS_Travel_gne__c WHERE Id = :recordID LIMIT 1];
                    breadcrumbs.add(new Breadcrumb(t.EMS_Event_gne__r.Name, '/' + t.EMS_Event_gne__r.Id));
                    breadcrumbs.add(new Breadcrumb(t.name, '/' + t.Id));
                }
            }

            if (String.isNotBlank(pageName) && pageName.equalsIgnoreCase('ems_travel_edit_create_layout')) {
                breadcrumbs.add(new Breadcrumb(isNewTravel ? 'Travels' : 'Edit', '#'));
            }
            deleteLastLink = true;
        }

        if (sobjectAPIName == attachmentAPIName) {
            breadcrumbs.add(new Breadcrumb('Events', Page.EMS_Event.getUrl()));
            if (String.isNotBlank(recordID)) {
                // there are possible two cases
                List<Schema.DescribeSObjectResult> describe = Schema.describeSObjects(new List<String>{
                        eventAPIName, attachmentAPIName
                });
                // 1) record is a new one. consequently parent object is an even record (EMS_Event__c ID)
                if (recordID.startsWith(describe[0].getKeyPrefix())) {
                    EMS_Event__c event = getEvent(recordID);
                    breadcrumbs.add(new Breadcrumb(event.name, '/' + event.Id));
                }
                // 2) record is being edited (EMS_Attachment_gne__c ID)
                if (recordID.startsWith(describe[1].getKeyPrefix())) {
                    EMS_Attachment_gne__c a = [SELECT Name, EMS_Event_gne__r.Name, EMS_Event_gne__r.Id FROM EMS_Attachment_gne__c WHERE Id = :recordID LIMIT 1];
                    breadcrumbs.add(new Breadcrumb(a.EMS_Event_gne__r.Name, '/' + a.EMS_Event_gne__r.Id));
                    breadcrumbs.add(new Breadcrumb(a.name, '/' + a.Id));
                }
            }
            if (String.isNotBlank(pageName) && pageName.equalsIgnoreCase('ems_upload_attachments')) {
                breadcrumbs.add(new Breadcrumb('Attachments', '#'));
            }

            if (String.isNotBlank(pageName) && pageName.equalsIgnoreCase('EMS_Attachment_Edit_Create_Layout')) {
                breadcrumbs.add(new Breadcrumb('Edit', '#'));
            }
            deleteLastLink = true;
        }

        // Related to EMS_Transaction_gne__c
        if (sobjectAPIName == transactionAPIName) {
            breadcrumbs.add(new Breadcrumb('Payment Queue Manual', Page.EMS_Payment_Queue_Manual.getUrl()));
            if (String.isNotBlank(recordID)) {
                EMS_Transaction_gne__c t = [SELECT Name FROM EMS_Transaction_gne__c WHERE Id = :recordID LIMIT 1];
                breadcrumbs.add(new Breadcrumb(t.Name, '/' + t.Id));
            }

            if (String.isNotBlank(pageName) && pageName.equalsIgnoreCase('ems_transaction_edit_create_layout')) {
                breadcrumbs.add(new Breadcrumb('Edit', '#'));
            }
            deleteLastLink = true;
        }

        // Related to ems_bcd_data_processor page
        if (String.isBlank(sobjectAPIName) && String.isNotBlank(pageName) && pageName.toLowerCase() == 'ems_bcd_data_processor') {
            breadcrumbs.add(new Breadcrumb('BCD Data Processor', Page.EMS_BCD_Data_Processor.getUrl()));
            deleteLastLink = true;
        }

        // Related to EMS_Cost_Center_Type_gne__c
        if (sobjectAPIName == costcentertypeAPIName) {
            breadcrumbs.add(new Breadcrumb('Cost Center Types', Page.EMS_Cost_Center_types.getUrl()));
            if (String.isNotBlank(recordID)) {
                EMS_Cost_Center_Type_gne__c cct = [SELECT Name FROM EMS_Cost_Center_Type_gne__c WHERE Id = :recordID LIMIT 1];
                breadcrumbs.add(new Breadcrumb(cct.Name, '/' + cct.Id));
            }

            if (String.isNotBlank(pageName) && pageName.equalsIgnoreCase('ems_cost_center_types_edit_create_layout')) {
                breadcrumbs.add(new Breadcrumb('Edit', '#'));
            }
            deleteLastLink = true;
        }

        // Related to EMS_Assignment_Error_gne__c
        if (sobjectAPIName == assignmenterrorAPIName) {
            breadcrumbs.add(new Breadcrumb('User Assignment Errors', Page.EMS_Assignment_Error_Layout.getUrl()));
            if (String.isNotBlank(recordID)) {
                EMS_Assignment_Error_gne__c ar = [SELECT Name FROM EMS_Assignment_Error_gne__c WHERE Id = :recordID LIMIT 1];
                breadcrumbs.add(new Breadcrumb(ar.Name, '/' + ar.Id));
            }

            if (String.isNotBlank(pageName) && pageName.equalsIgnoreCase('ems_assignment_error_layout')) {
                breadcrumbs.add(new Breadcrumb('Edit', '#'));
            }
            deleteLastLink = true;
        }

        // Related to EMS_Cost_Center_gne__c
        if (sobjectAPIName == costcetnerAPIName) {
            breadcrumbs.add(new Breadcrumb('Cost Centers', Page.EMS_Cost_Center.getUrl()));
            if (String.isNotBlank(recordID)) {
                EMS_Cost_Center_gne__c cc = [SELECT Name FROM EMS_Cost_Center_gne__c WHERE Id = :recordID LIMIT 1];
                breadcrumbs.add(new Breadcrumb(cc.Name, '/' + cc.Id));
            }

            if (String.isNotBlank(pageName) && pageName.equalsIgnoreCase('ems_cost_center_edit_create_layout')) {
                breadcrumbs.add(new Breadcrumb('Edit', '#'));
            }
            deleteLastLink = true;
        }

        // Related to EMS_Speaker_Role_gne__c
        if (sobjectAPIName == paymentqueueAPIName) {
            if (String.isNotBlank(pageName) && pageName.toLowerCase() == 'ems_ariba_payment_queue') {
                breadcrumbs.add(new Breadcrumb('Payment Queue', Page.EMS_Ariba_Payment_Queue.getUrl()));
            } else {
                breadcrumbs.add(new Breadcrumb('Events', Page.EMS_Event.getUrl()));
            }
            if (String.isNotBlank(recordID)) {
                // there are possible two cases
                List<Schema.DescribeSObjectResult> describe = Schema.describeSObjects(new List<String>{
                        eventAPIName, paymentqueueAPIName
                });
                // 1) record is a new one. consequently parent object is an even record (EMS_Event__c ID)
                if (recordID.startsWith(describe[0].getKeyPrefix())) {
                    EMS_Event__c event = getEvent(recordID);
                    breadcrumbs.add(new Breadcrumb(event.name, '/' + event.Id));
                    breadcrumbs.add(new Breadcrumb('Payment Requests', '#'));
                }
                // 2) record is being edited (EMS_Speaker_Role_gne__c ID)
                if (recordID.startsWith(describe[1].getKeyPrefix())) {
                    EMS_Speaker_Role_gne__c sr = [SELECT Name, EMS_Event_gne__c FROM EMS_Speaker_Role_gne__c WHERE Id = :recordID LIMIT 1];
                    EMS_Event__c event = getEvent(sr.EMS_Event_gne__c);

                    if (event != null) breadcrumbs.add(new Breadcrumb(event.Name, '/' + event.Id));
                    breadcrumbs.add(new Breadcrumb(sr.Name, '/' + sr.Id));
                    if (!forceReadonly) {
                        breadcrumbs.add(new Breadcrumb('Edit', '#'));
                    }
                }
            }

            deleteLastLink = true;
        }

        // Related to EMS_Data_Change_Request_gne__c
        if (sobjectAPIName == datachangerequestAPIName) {
            breadcrumbs.add(new Breadcrumb('Data Change Requests', Page.EMS_Data_Change_Request.getUrl()));
            if (String.isNotBlank(recordID)) {
                EMS_Data_Change_Request_gne__c cr = [SELECT Name FROM EMS_Data_Change_Request_gne__c WHERE Id = :recordID LIMIT 1];
                breadcrumbs.add(new Breadcrumb(cr.Name, '/' + cr.Id));
            }

            if (String.isNotBlank(pageName) && pageName.equalsIgnoreCase('ems_data_change_request_edit_create_layo')) {
                breadcrumbs.add(new Breadcrumb('Edit', '#'));
            }
            deleteLastLink = true;
        }

        // Related to EMS_Expense_gne__c
        if (sobjectAPIName == expenseAPIName) {
            breadcrumbs.add(new Breadcrumb('Expenses', Page.EMS_Expense.getUrl()));
            if (String.isNotBlank(recordID)) {
                EMS_Expense_gne__c e = [SELECT Name FROM EMS_Expense_gne__c WHERE Id = :recordID LIMIT 1];
                breadcrumbs.add(new Breadcrumb(e.name, '/' + e.Id));
            }

            if (String.isNotBlank(pageName) && pageName.equalsIgnoreCase('ems_expense_edit_create_layout')) {
                breadcrumbs.add(new Breadcrumb('Edit', '#'));
            }
            deleteLastLink = true;
        }

        // Related to EMS_International_Speaker_gne__c
        if (sobjectAPIName == internationalspeakerAPIName) {
            breadcrumbs.add(new Breadcrumb('iHCPs', Page.EMS_IHCP.getUrl()));
            if (String.isNotBlank(recordID)) {
                EMS_International_Speaker_gne__c is = [SELECT First_Name_gne__c, Last_Name_gne__c FROM EMS_International_Speaker_gne__c WHERE Id = :recordID LIMIT 1];
                breadcrumbs.add(new Breadcrumb(is.First_Name_gne__c + ' ' + is.Last_Name_gne__c, '/' + is.Id));
            }
            deleteLastLink = true;
        }

        // Related to EMS_Fund_Request_gne__c
        if (sobjectAPIName == fundrequestAPIName) {
            breadcrumbs.add(new Breadcrumb('Fund requests', Page.EMS_Fund_Request.getUrl()));
            if (String.isNotBlank(recordID)) {
                EMS_Fund_Request_gne__c fr = [SELECT Name FROM EMS_Fund_Request_gne__c WHERE Id = :recordID LIMIT 1];
                breadcrumbs.add(new Breadcrumb(fr.name, '/' + fr.Id));
            }

            if (String.isNotBlank(pageName) && (pageName.equalsIgnoreCase('ems_fund_request_edit_create_layout') || pageName.equalsIgnoreCase('ems_approve_reject_fr'))) {
                breadcrumbs.add(new Breadcrumb('Edit', '#'));
            }
            deleteLastLink = true;
        }

        // Related to EMS_Budget_Product_gne__c
        if (sobjectAPIName == productbudgetAPIName) {
            breadcrumbs.add(new Breadcrumb('Product Budgets', Page.EMS_Product_Budget.getUrl()));
            if (String.isNotBlank(recordID)) {
                EMS_Budget_Product_gne__c pb = [SELECT Name FROM EMS_Budget_Product_gne__c WHERE Id = :recordID LIMIT 1];
                breadcrumbs.add(new Breadcrumb(pb.name, '/' + pb.Id));
            }

            if (String.isNotBlank(pageName) && pageName.equalsIgnoreCase('ems_budget_product_edit_create_layout')) {
                breadcrumbs.add(new Breadcrumb('Edit', '#'));
            }
            deleteLastLink = true;
        }

        // Related to EMS_Budget_Region_gne__c
        if (sobjectAPIName == regionbudgetAPIName) {
            breadcrumbs.add(new Breadcrumb('Region Budgets', Page.EMS_Region_Budget.getUrl()));
            if (String.isNotBlank(recordID)) {
                EMS_Budget_Region_gne__c rb = [SELECT Name FROM EMS_Budget_Region_gne__c WHERE Id = :recordID LIMIT 1];
                breadcrumbs.add(new Breadcrumb(rb.name, '/' + rb.Id));
            }

            if (String.isNotBlank(pageName) && pageName.equalsIgnoreCase('ems_budget_region_edit_create_layout')) {
                breadcrumbs.add(new Breadcrumb('Edit', '#'));
            }
            deleteLastLink = true;
        }

        // Related to EMS_Budget_Territory_gne__c
        if (sobjectAPIName == territorybudgetAPIName) {
            breadcrumbs.add(new Breadcrumb('Territory Budgets', Page.EMS_Territory_Budget.getUrl()));
            if (String.isNotBlank(recordID)) {
                EMS_Budget_Territory_gne__c tb = [SELECT Name FROM EMS_Budget_Territory_gne__c WHERE Id = :recordID LIMIT 1];
                breadcrumbs.add(new Breadcrumb(tb.name, '/' + tb.Id));
            }

            if (String.isNotBlank(pageName) && pageName.equalsIgnoreCase('ems_budget_territory_edit_create_layout')) {
                breadcrumbs.add(new Breadcrumb('Edit', '#'));
            }
            deleteLastLink = true;
        }

        // Related to GNE_User_Delegation__c
        if (sobjectAPIName == userdelegationsAPIName) {
            breadcrumbs.add(new Breadcrumb('User Delegations', Page.GNE_User_Delegation.getUrl()));
            if (String.isNotBlank(recordID)) {
                GNE_User_Delegation__c ud = [select Name from GNE_User_Delegation__c where Id = :recordID LIMIT 1];
                breadcrumbs.add(new Breadcrumb(ud.Name, '/' + ud.Id));
            }
            deleteLastLink = String.isBlank(pageName) || pageName.equalsIgnoreCase('GNE_User_Delegation_Layout');
        }

        if (String.isNotBlank(pageName) && pageName.containsIgnoreCase('EMS_User_Layout')) {
            User currentUser = [SELECT Name from User WHERE Id = :recordID LIMIT 1];
            breadcrumbs.add(new Breadcrumb(currentUser.Name, '#'));
            deleteLastLink = true;
        }

        if (String.isBlank(sobjectAPIName) && String.isNotBlank(pageName) && pageName.containsIgnoreCase('EMS_Report_layout')) {
            breadcrumbs.add(new Breadcrumb('Reports', Page.EMS_Report_Layout.getUrl()));
            deleteLastLink = true;
        }

        if (String.isNotBlank(pageName) && pageName.containsIgnoreCase('List_View_Setup_Page')) {
            breadcrumbs.add(new Breadcrumb('List View Setup', '#'));
            deleteLastLink = true;
        }

        // remove link in the last record
        if (deleteLastLink) {
            breadcrumbs.get(breadcrumbs.size() - 1).url = null;
        }

        return breadcrumbs;
    }

    public class DynamicLink {
        public String strName { get; set; }
        public String apiName { get; set; }
        public String strLabel { get; set; }
        public String strAttribute { get; set; }
        public String pageRef { get; set; }
        public String linkId { get; set; }
        public String imgSrc { get; set; }
    }

    public class Breadcrumb {
        public String url { get; set; }
        public String name { get; set; }

        Breadcrumb(String name, String url) {
            this.name = name;
            this.url = url;
        }

        Breadcrumb(String name) {
            this.name = name;
        }
    }
}