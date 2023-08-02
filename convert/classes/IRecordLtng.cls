public without sharing class IRecordLtng {

    @AuraEnabled
    public static Call_No_Show_Spend__c getNoShowSpend(Id spendId) {
        return [
                SELECT Id, Name, Actual_Attendees__c, Planned_Attendees__c, Reason__c, Spend_User__c, Transaction_Date__c
                FROM Call_No_Show_Spend__c
                WHERE Id = :spendId
        ];
    }

    @AuraEnabled
    public static Call_No_Show_Spend__c saveNoShowSpend(Call_No_Show_Spend__c spend) {
        upsert spend;
        return spend;
    }

    @AuraEnabled
    public static List<iPhone_Get_User_Picklists_gne.PicklistItem> getBusinessSponsorStatusesApex() {
        List<iPhone_Get_User_Picklists_gne.PicklistItem> result = new List<iPhone_Get_User_Picklists_gne.PicklistItem>();
        for (picklist_values_gne__c pv : [SELECT Name FROM picklist_values_gne__c WHERE Picklist_Name__c = 'CallBusinessSponsorStatus']) {
            result.add(new iPhone_Get_User_Picklists_gne.PicklistItem(pv.Name));
        }

        return result;
    }

    @AuraEnabled
    public static List<Product_vod__c> getAvailableProducts(String searchText) {
        List<Product_vod__c> result;
        if (String.isEmpty(searchText)) {
            result = [
                    SELECT Id, Name, Disease_Indication_gne__c, Product_Type_vod__c, Therapeutic_Area_vod__c, Therapeutic_Class_vod__c
                    FROM Product_vod__c
                    WHERE (Name = 'No Product discussed') OR (Product_Type_vod__c = 'Detail' AND Detail_Product_Subtype_Code_gne__c = 'Brand')
                    ORDER BY Name, CreatedDate
            ];
        } else {
            List<List<SObject>> searchList = [
                    FIND :searchText
                    IN NAME FIELDS
                    RETURNING
                            Product_vod__c (Id, Name, Disease_Indication_gne__c, Product_Type_vod__c, Therapeutic_Area_vod__c, Therapeutic_Class_vod__c
                                    WHERE Product_Type_vod__c = 'Detail' AND Detail_Product_Subtype_Code_gne__c = 'Brand'
                                    ORDER BY Name, Createddate)
            ];
            result = searchList[0];
        }
        result = new ProductLocator().filterProducts(result);
        return result;
    }

    @AuraEnabled
    public static InitParams getInitParams(String minDate, String maxDate, String mode, String callId, String spendUserId) {
        InitParams result = new InitParams();
        result.states = getStates();
        if (String.isNotBlank(minDate) && String.isNotBlank(maxDate)) {
            result.interactionDateOptions = getInteractionDateOptions(minDate, maxDate);
        }
        result.nonCommercialMolecule = getNonCommercialMolecule();
        result.interaction = getInteraction(mode, callId, spendUserId, maxDate);
        result.possibleAttendees = getPossibleAttendees(result.interaction);
        result.sbcEnabled = isSbcEnabled();
        return result;
    }

    public static Boolean isSbcEnabled() {
        GNE_Foun_Misc_Config_Items_gne__c config = GNE_Foun_Misc_Config_Items_gne__c.getValues('SbcEnabled');
        return config != null ? Boolean.valueOf(config.Configuration_Value_gne__c) : true;
    }

    private static Product getNonCommercialMolecule() {
        Product molecule;
        List<Product_vod__c> molecules = [
                SELECT Id, Name, Product_Type_vod__c, Therapeutic_Area_vod__c, Disease_Indication_gne__c
                FROM Product_vod__c
                WHERE Product_Type_vod__c = 'Detail' AND Name LIKE 'Non-Commercial%'
                ORDER BY Name
                LIMIT 1
        ];
        if (!molecules.isEmpty()) {
            molecule = new Product(molecules[0]);
        }
        return molecule;
    }

    private static Interaction getInteraction(String mode, String callId, String spendUserId, String interactionDate) {
        Interaction interaction;
        //new interaction - create mode
        if (mode == 'create') {
            interaction = new Interaction();
            if (String.isNotBlank(spendUserId)) {
                Attendee userAttendee = getUserAttendee(spendUserId, true);
                interaction.attendees.add(userAttendee);
                interaction.spendUserId = spendUserId;
                interaction.usersCount++;
            }
            Date iDate = Datetime.now().date();
            if (String.isNotBlank(interactionDate)) {
                try {
                    iDate = Date.valueOf(interactionDate);
                } catch (Exception e) {
                    //ignore
                }
            }
            interaction.callDateTime = iDate;
            interaction.employeeName = getEmployeeName(spendUserId);
        } else if (mode == 'edit') {
            interaction = loadInteraction(callId);
        }

        return interaction;
    }

    @AuraEnabled
    public static Interaction saveInteraction(String jsonInteraction) {
        System.debug(jsonInteraction);
        Interaction interaction = (Interaction) JSON.deserialize(jsonInteraction, Interaction.class);
        System.debug(interaction);

        iPhoneApex_2.CallAttributes cAttributes = new iPhoneApex_2.CallAttributes();

        cAttributes.Id = interaction.id;
        cAttributes.OwnerId = UserInfo.getUserId();
        Attendee mainAttendee;
        Integer hcpActual = 0;
        System.debug(interaction.attendees);
        for (Attendee attendee : interaction.attendees) {
            System.debug(attendee);
            if (String.valueOf(attendee.iAttendeeType).toUpperCase() == String.valueOf(iPhoneApex_2.AttendeeType.PERSONACCOUNT)) {
                if (mainAttendee == null) {
                    mainAttendee = attendee;
                }
                hcpActual++;
            }
        }

        cAttributes.Account = mainAttendee.attendeeId;
        cAttributes.CallDateTime = Datetime.newInstance(interaction.callDateTime, Datetime.now().time());
        System.debug('interaction: ' + interaction);
        List<Address_vod__c> addresses;
        if (String.isNotBlank(mainAttendee.addressId)) {
            addresses = [SELECT Id, Name FROM Address_vod__c WHERE Account_vod__c = :mainAttendee.attendeeId ORDER BY CreatedDate DESC LIMIT 1];
        } else {
            addresses = [SELECT Id, Name FROM Address_vod__c WHERE Account_vod__c = :mainAttendee.attendeeId ORDER BY CreatedDate DESC LIMIT 1];
        }
        System.debug('addresses: ' + addresses);
        cAttributes.Address = addresses[0].Id;
        cAttributes.AddressText = addresses[0].Name;

        cAttributes.MealLocationCity = interaction.city;
        cAttributes.MealLocationState = interaction.state;
        cAttributes.AddressText = interaction.city + ' ' + interaction.state;
        cAttributes.CallAttendeeType = iPhoneApex_2.AttendeeType.PERSONACCOUNT;
        cAttributes.IsComplete = true;
        cAttributes.MealAmount = null;
        cAttributes.MealPlannedAttendeeCount = interaction.plannedAttendees;
        cAttributes.MealActualAttendeeCount = interaction.actualAttendees;
        cAttributes.OtherAttendeesCount = interaction.nonHcpsConsumed;
        cAttributes.AttendeesInService  = interaction.employeeConsumed;
        cAttributes.NumOfCustomersPresent = hcpActual;
        cAttributes.SpendUser = interaction.spendUserId;
        cAttributes.IsComplete = true;
        cAttributes.InteractionType = interaction.interactionType;
        cAttributes.BusinessSponsor = interaction.businessSponsor;

        cAttributes.InteractionLocation = interaction.interactionType;

        System.debug('cAttributes:' + cAttributes);

        //TODO: set  cAttributes.ContractedServices
        //Add attendee list in iPhoneApex_2 API
        cAttributes.callAttendeeList = new List <iPhoneApex_2.CallAttendee>();
        for (Attendee attendee : interaction.attendees) {
            //main hcp is not saved as attendee
            if (attendee.attendeeId != mainAttendee.attendeeId) {
                iPhoneApex_2.CallAttendee tempAttendee = new iPhoneApex_2.CallAttendee();
                tempAttendee.CallAttendeeType = convertStringToEnum(attendee.iAttendeeType);
                tempAttendee.Attendee = attendee.attendeeId;
                cAttributes.callAttendeeList.add(tempAttendee);
            }
        }
        System.debug('att size: ' + cAttributes.callAttendeeList.size());
        //Add attendee list in iPhoneApex_2 API
        cAttributes.callDetailList = new List<iPhoneApex_2.CallDetail>();
        Integer i = 1;
        for (Product product : interaction.products) {
            iPhoneApex_2.CallDetail tempCallDetail = new iPhoneApex_2.CallDetail();
            tempCallDetail.DetailPriority = String.valueOf(i) ;
            tempCallDetail.Product = product.productId;
            tempCallDetail.Id = product.id;
            if (String.isNotBlank(product.indication)) {
                tempCallDetail.DiseaseIndication = product.indication;
            }
            if (String.isNotBlank(product.therapeuticArea)) {
                tempCallDetail.TherapeuticArea = product.therapeuticArea;
            }
            System.debug('Product: ' + tempCallDetail);
            cAttributes.callDetailList.add(tempCallDetail);
            i++;
        }
        iPhoneApex_2.Response resp = iPhoneApex_2.updateOrCreateCallForIFU(cAttributes);
        if (resp.ErrorMessage != null) {
            throw new InteractionSaveException(resp.ErrorMessage);
        } else {
            // update the record types for call2_vod__c records
            Set <Id> callIds = new Set<Id>();
            String callResponse = resp.toString();
            List <String> response1 = callResponse.split('RequestIdResponseIdList', 2);
            System.debug('Resp_part1 ' + response1);

            if (response1.size() == 2) {
                System.debug('Resp_part1[1] ' + response1[1]);
                List <String> response2 = response1[1].split(',', -2);
                System.debug('Resp_part2 ' + response2);
                for (Integer j = 0; j < response2.size(); j++) {
                    //system.debug('Resp_part2[j] :'+j +'  '+Resp_part2[j] +' '+(Resp_part2[j].trim()).startswith('ResponseId='));
                    if ((response2[j].trim()).startsWith('ResponseId=')) {
                        System.debug(response2[j].substring(12, 30));
                        callIds.add(response2[j].substring(12, 30));
                    }
                }
                System.debug('Callids.size() ' + callIds.size());
                System.debug('Callids list  ' + callIds);
                if (callIds.size() > 0) {
                    List <Call2_vod__c> callToUpdate = [SELECT RecordTypeId, Id, Spend_User_gne__c, Parent_Call_vod__c FROM Call2_vod__c WHERE Id IN :callIds];
                    //fetch spend user from master record
                    String masterSpendUser;
                    for (Call2_vod__c c : callToUpdate) {
                        if (c.Parent_Call_vod__c == null) {
                            masterSpendUser = c.Spend_User_gne__c;
                            interaction.id = c.Id;
                        }
                    }
                    List <RecordType> infuRecordType = [SELECT Id FROM RecordType WHERE SobjectType = 'Call2_vod__c' AND Name = 'INFU Interaction'];
                    QueueSobject infuQueue = [SELECT q.QueueId FROM QueueSobject q WHERE Queue.Name = 'AGS Infrequent Owner'];
                    if (infuRecordType.size() > 0) {
                        for (Integer k = 0; k < callToUpdate.size(); k++) {
                            callToUpdate[k].RecordTypeId = infuRecordType[0].Id;
                            callToUpdate[k].OwnerId = infuQueue.QueueId;
                            if (callToUpdate[k].Parent_Call_vod__c != null && callToUpdate[k].Spend_User_gne__c == null) {
                                callToUpdate[k].Spend_User_gne__c = masterSpendUser;
                            }
                        }
                    }
                    update callToUpdate;
                }
            }
        }

        return interaction;
    }

    @AuraEnabled
    public static Attendee getHCPAttendee(String hcpId, String addressId) {
        Account account = getAccount(hcpId);
        Address_vod__c selectedAddress = account.Address_vod__r[0];
        for (Address_vod__c address : account.Address_vod__r) {
            if (address.Id == addressId) {
                selectedAddress = address;
                break;
            }
        }
        return new Attendee(account, selectedAddress);
    }

    private static Attendee getUserAttendee(String userId, Boolean isPayer) {
        Attendee attendee;

        List<User> users = [SELECT Name, FirstName, Id, LastName, CompanyName, Username, City, Street, State, PostalCode, Country, External_ID_gne__c FROM User u WHERE Id = :userId AND UserType = 'Standard'];
        if (!users.isEmpty()) {
            User user = users.get(0);
            String sAddress = '';
            if (!Utility.isNull(user.Street)) {
                sAddress += user.Street;
            }

            if (!Utility.isNull(user.City)) {
                sAddress += ' ' + user.City;
            }

            if (!Utility.isNull(user.State)) {
                sAddress += ' ' + user.State;
            }

            if (!Utility.isNull(user.PostalCode)) {
                sAddress += ' ' + user.PostalCode;
            }

            if (!Utility.isNull(user.Country)) {
                sAddress += ' ' + user.Country;
            }
            attendee = new Attendee();
            attendee.attendeeId = user.Id;
            attendee.attendeeName = user.Name;
            attendee.attendeeType = user.CompanyName;
            attendee.primaryAddress = sAddress;
            attendee.iAttendeeType = String.valueOf(iPhoneApex_2.AttendeeType.USER);
            attendee.IsPayer = isPayer;
            attendee.cannotBeDeleted = true;
        }
        return attendee;
    }

    private static Account getAccount(Id accountId) {
        return getAccountsByIds(new Set<Id>{
                accountId
        }).get(accountId);
    }

    private static Map<Id, Account> getAccountsByIds(Set<Id> accountIds) {
        Map<Id, Account> accountByIds = new Map<Id, Account>([
                SELECT Id, FirstName, LastName, Middle_vod__c, RecordType.Name, (SELECT Id, Name, City_vod__c, State_vod__c, Zip_vod__c, Address_line_2_vod__c, Primary_vod__c FROM Address_vod__r ORDER BY Primary_vod__c DESC, CreatedDate DESC)
                FROM Account
                WHERE Id IN :accountIds
        ]);
        return accountByIds;
    }

    private static Interaction loadInteraction(String callId) {
        iPhoneApex_2.CallAttributes existingInteraction = iPhoneApex_2.getCallAttributes(callId);
        if (existingInteraction == null) {
            throw new InteractionSaveException('Cannot find interaction for given Id.');
        }
        Interaction interaction = new Interaction(existingInteraction);
        Set<Id> userIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();
        for (iPhoneApex_2.CallAttendee ca : existingInteraction.callAttendeeList) {
            if (ca.CallAttendeeType == iPhoneApex_2.AttendeeType.USER) {
                userIds.add(ca.Attendee);
            }
            if (ca.CallAttendeeType == iPhoneApex_2.AttendeeType.PERSONACCOUNT) {
                accountIds.add(ca.Attendee);
            }
        }
        accountIds.add(existingInteraction.Account);
        for (iPhoneApex_2.CallDetail cd : existingInteraction.callDetailList) {
            productIds.add(cd.Product);
        }

        Map<Id, User> usersByIds = new Map<Id, User>([SELECT Name, FirstName, Id, LastName, CompanyName, Username, City, Street, State, PostalCode, Country, External_ID_gne__c FROM User WHERE Id = :userIds]);
        Map<Id, Product_vod__c> productsByIds = new Map<Id, Product_vod__c>([SELECT Id, Name, Product_Type_vod__c, Disease_Indication_gne__c, Therapeutic_Area_vod__c FROM Product_vod__c WHERE Id IN :productIds]);
        Map<Id, Account> accountByIds = getAccountsByIds(accountIds);

        //interaction acount added as first attendee
        Account mainAccount = accountByIds.get(existingInteraction.Account);
        interaction.attendees.add(new Attendee(mainAccount, getAccountAddress(mainAccount, existingInteraction.Address)));
        interaction.hcpsCount++;

        for (iPhoneApex_2.CallAttendee ca : existingInteraction.callAttendeeList) {
            if (ca.CallAttendeeType == iPhoneApex_2.AttendeeType.USER) {
                Attendee attendee = new Attendee(ca);
                User user = usersByIds.get(ca.Attendee);
                attendee.attendeeName = user.Name;
                attendee.attendeeType = user.CompanyName;
                attendee.iAttendeeType = String.valueOf(iPhoneApex_2.AttendeeType.USER);
                attendee.primaryAddress = getAddress(user);
                System.debug('userId: ' + user.Id);
                System.debug('existingInteraction.SpendUser: ' + existingInteraction.SpendUser) ;
                if (user.Id == existingInteraction.SpendUser) {
                    attendee.IsPayer = true;
                    attendee.cannotBeDeleted = true;
                }
                interaction.attendees.add(attendee);
                interaction.usersCount++;
            }

            if (ca.CallAttendeeType == iPhoneApex_2.AttendeeType.PERSONACCOUNT) {
                Account account = accountByIds.get(ca.Attendee);
                interaction.attendees.add(new Attendee(account, getAccountAddress(account, null)));
                interaction.hcpsCount++;
            }
        }

        for (iPhoneApex_2.CallDetail cd : existingInteraction.callDetailList) {
            Product product = new Product(cd);
            product.name = productsByIds.get(cd.Product).Name;
            interaction.products.add(product);
        }
        return interaction;
    }

    /**
     * Return address for given addressId. If not exists return primary address.
     * @param account account
     * @param addressId address Id
     *
     * @return address
     */
    private static Address_vod__c getAccountAddress(Account account, String addressId) {
        Address_vod__c selectedAddress;
        if (String.isNotBlank(addressId)) {
            for (Address_vod__c address : account.Address_vod__r) {
                if (address.Id == addressId) {
                    selectedAddress = address;
                    break;
                }
            }
        }
        if (selectedAddress == null) {
            for (Address_vod__c address : account.Address_vod__r) {
                if (address.Primary_vod__c == true) {
                    selectedAddress = address;
                    break;
                }
            }
        }
        if (selectedAddress == null) {
            selectedAddress = account.Address_vod__r[0];
        }
        return selectedAddress;
    }

    private static String getName(Account account) {
        String name = account.FirstName;
        if (!Utility.isNull(account.Middle_vod__c)) {
            name += ' ' + account.Middle_vod__c;
        }
        name += ' ' + account.LastName;
        return name;
    }

    private static String getAddress(User user) {
        String sAddress = '';
        if (!Utility.isNull(user.Street)) {
            sAddress += user.Street;
        }
        if (!Utility.isNull(user.City)) {
            sAddress += ' ' + user.City;
        }
        if (!Utility.isNull(user.State)) {
            sAddress += ' ' + user.State;
        }
        if (!Utility.isNull(user.PostalCode)) {
            sAddress += ' ' + user.PostalCode;
        }
        if (!Utility.isNull(user.Country)) {
            sAddress += ' ' + user.Country;
        }
        return sAddress;
    }

    private static String getAddress(Address_vod__c address) {
        String sAddress = '';
        if (!Utility.isNull(address.Name)) {
            sAddress += ' ' + address.Name;
        }
        if (!Utility.isNull(address.Address_line_2_vod__c)) {
            sAddress += ' ' + address.Address_line_2_vod__c;
        }
        if (!Utility.isNull(address.City_vod__c)) {
            sAddress += ' ' + address.City_vod__c;
        }
        if (!Utility.isNull(address.State_vod__c)) {
            sAddress += ' ' + address.State_vod__c;
        }
        if (!Utility.isNull(address.Zip_vod__c)) {
            sAddress += ' ' + address.Zip_vod__c;
        }
        return sAddress;
    }

    private static iPhoneApex_2.AttendeeType convertStringToEnum(String value) {
        for (iPhoneApex_2.AttendeeType at : iPhoneApex_2.AttendeeType.values()) {
            if (value.toUpperCase() == String.valueOf(at)) {
                return at;
            }
        }
        return null;
    }

    @AuraEnabled
    public static String getEmployeeName(Id userId) {
        String name = '';
        try {
            User user = [SELECT FirstName, LastName, Alias FROM User WHERE Id = :userId];
            name = user.Alias + '[' + user.FirstName + ',' + user.LastName + ']';
        } catch (Exception e) {
            name = UserInfo.getUserName();
        }
        return name;
    }

    private static List<DateLabelPair> getInteractionDateOptions(String minDate, String maxDate) {
        Date min = Date.valueOf(minDate);
        Date max = Date.valueOf(maxDate);
        List<DateLabelPair> options = new List<DateLabelPair>();
        options.add(new DateLabelPair(min.format(), min));
        Integer numberDays = min.daysBetween(max);
        Date nextDate = min;
        for (Integer i = 0; i < numberDays; i++) {
            nextDate = nextDate.addDays(1);
            options.add(new DateLabelPair(nextDate.format(), nextDate));
        }
        return options;
    }

    private static List<ValueLabelPair> getStates() {
        List<ValueLabelPair> options = new List<ValueLabelPair>();
        options.add(new ValueLabelPair('Non-US', 'Non-US'));

        Schema.DescribeFieldResult fieldResult =
                Call2_vod__c.State_gne__c.getDescribe();

        for (Schema.PicklistEntry e : fieldResult.getPicklistValues()) {
            options.add(new ValueLabelPair(e.getLabel(), e.getValue()));
        }
        return options;
    }

    class ValueLabelPair {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
        public ValueLabelPair(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }

    class DateLabelPair {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public Date value;
        public DateLabelPair(String label, Date value) {
            this.label = label;
            this.value = value;
        }
    }

    public class Interaction {
        @AuraEnabled
        public String spendUserId { get; set; }
        @AuraEnabled
        public String id { get; set; }
        @AuraEnabled
        public String name { get; set; }
        @AuraEnabled
        public Date callDateTime { get; set; }
        @AuraEnabled
        public String interactionType { get; set; }
        @AuraEnabled
        public String city { get; set; }
        @AuraEnabled
        public String state { get; set; }
        @AuraEnabled
        public Integer plannedAttendees { get; set; }
        @AuraEnabled
        public String payerUnix { get; set; }
        @AuraEnabled
        public String businessSponsor { get; set; }
        @AuraEnabled
        public String employeeName { get; set; }
        @AuraEnabled
        public Integer actualAttendees { get; set; }
        @AuraEnabled
        public User employee { get; set; }
        @AuraEnabled
        public List<Attendee> attendees { get; private set; }
        @AuraEnabled
        public List<Product> products { get; private set; }
        @AuraEnabled
        public Integer hcpsCount { get; set; }
        @AuraEnabled
        public Integer usersCount { get; set; }
        @AuraEnabled
        public Integer nonHcpsConsumed { get; set; }
        @AuraEnabled
        public Integer employeeConsumed { get; set; }

        public Interaction() {
            this.attendees = new List<Attendee>();
            this.products = new List<Product>();
            hcpsCount = 0;
            usersCount = 0;
            employeeConsumed = 0;
            nonHcpsConsumed = 0;
            actualAttendees = 1;
        }

        public Interaction(iPhoneApex_2.CallAttributes callAttributes) {
            this();
            this.id = callAttributes.Id;
            if (callAttributes.CallDateTime != null) {
                this.callDateTime = callAttributes.CallDateTime.date();
            }
            this.plannedAttendees = callAttributes.MealPlannedAttendeeCount;
            this.actualAttendees = callAttributes.MealActualAttendeeCount;
            this.employeeConsumed = callAttributes.AttendeesInService;
            this.nonHcpsConsumed = callAttributes.OtherAttendeesCount;
            this.city = callAttributes.MealLocationCity;
            this.state = callAttributes.MealLocationState;
            this.businessSponsor = callAttributes.BusinessSponsor;
            this.spendUserId = callAttributes.SpendUser;
            this.interactionType = callAttributes.InteractionType;
            this.employeeName = getEmployeeName(callAttributes.CreatedById);
        }
    }

    public class Attendee {
        @AuraEnabled
        public String id { get; set; }
        @AuraEnabled
        public String attendeeId { get; set; }
        @AuraEnabled
        public String addressId { get; set; }
        @AuraEnabled
        public String attendeeName { get; set; }
        @AuraEnabled
        public String attendeeType { get; set; }
        @AuraEnabled
        public String primaryAddress { get; set; }
        @AuraEnabled
        public Boolean IsPayer { get; set; }
        @AuraEnabled
        public String iAttendeeType;
        @AuraEnabled
        public Boolean cannotBeDeleted;
        @AuraEnabled
        public Boolean checked;

        public Attendee() {
            cannotBeDeleted = false;
            checked = false;
        }

        public Attendee(iPhoneApex_2.CallAttendee ca) {
            this();
            this.id = ca.Id;
            this.attendeeId = ca.Attendee;
            this.attendeeType = String.valueOf(ca.CallAttendeeType);
            this.checked = true;
        }

        public Attendee(Account account, Address_vod__c address) {
            this.attendeeId = account.Id;
            this.IsPayer = false;
            this.iAttendeeType = String.valueOf(iPhoneApex_2.AttendeeType.PERSONACCOUNT);
            this.attendeeName = getName(account);
            this.attendeeType = 'Attendee';
            this.primaryAddress = getAddress(address);
            this.addressId = address.Id;
        }
    }

    public class Product {
        @AuraEnabled
        public String id { get; set; }
        @AuraEnabled
        public String productId { get; set; }
        @AuraEnabled
        public String name { get; set; }
        @AuraEnabled
        public String therapeuticArea { get; set; }
        @AuraEnabled
        public String indication { get; set; }

        public Product(Product_vod__c p) {
            name = p.Name;
            productId = p.Id;
            therapeuticArea = p.Therapeutic_Area_vod__c;
            indication = p.Disease_Indication_gne__c;
        }

        public Product(iPhoneApex_2.CallDetail cd) {
            id = cd.Id;
            productId = cd.Product;
            therapeuticArea = cd.TherapeuticArea;
            indication = cd.DiseaseIndication;
        }
    }
    class InitParams {
        @AuraEnabled
        public List<ValueLabelPair> states;
        @AuraEnabled
        public List<DateLabelPair> interactionDateOptions;
        @AuraEnabled
        public Product nonCommercialMolecule;
        @AuraEnabled
        public Interaction interaction;
        @AuraEnabled
        public List<Attendee> possibleAttendees;
        @AuraEnabled
        public Boolean sbcEnabled;

        public InitParams() {

        }
    }
    class InteractionSaveException extends Exception {

    }

    private static List<Attendee> getPossibleAttendees(Interaction interaction) {
        List<Attendee> possibleAttendees = new List<Attendee>();
        List<String> accountMdmIds = getVeevaAccountMdmIds(interaction.spendUserId);
        Map<String, Account> mdmIdToAccount = new Map<String, Account>();
        for (Account account : [
                SELECT Id, FirstName, LastName, Middle_vod__c, RecordType.Name, MDMID_gne__c, (SELECT Id, Name, City_vod__c, State_vod__c, Zip_vod__c, Address_line_2_vod__c, Primary_vod__c FROM Address_vod__r ORDER BY Primary_vod__c DESC, CreatedDate DESC)
                FROM Account
                WHERE MDMID_gne__c IN :accountMdmIds
        ]) {
            if (!account.Address_vod__r.isEmpty()) {
                mdmIdToAccount.put(account.MDMID_gne__c, account);
            }
        }


        Set<Id> existingAttendees = new Set<Id>();
        if (interaction.attendees != null) {
            for (Attendee attendee : interaction.attendees) {
                existingAttendees.add(attendee.attendeeId);
            }
        }
        for (String mdmId : accountMdmIds) {
            if (mdmIdToAccount.containsKey(mdmId)) {
                Account account = mdmIdToAccount.get(mdmId);
                Attendee attendee = new Attendee(account, account.Address_vod__r[0]);
                attendee.checked = existingAttendees.contains(account.Id);
                possibleAttendees.add(attendee);
            }
        }
        return possibleAttendees;
    }

    public static List<String> getVeevaAccountMdmIds(String spendUserId) {
        User spendUsr = [SELECT External_ID_gne__c FROM User WHERE Id = :spendUserId];
        List<String>mdmIds = new List<String>();
        List<Call2_vod_c__x> veevaCalls = [
                SELECT Account_vod_c__r.Id
                FROM Call2_vod_c__x
                WHERE Account_vod_c__c != NULL
                AND Owner__r.FederationIdentifier__c = :spendUsr.External_ID_gne__c
                AND CreatedDate__c = LAST_90_DAYS
                ORDER BY CreatedDate__c DESC
                LIMIT 1000
        ];
        List<Id> orderedAccountIds = new List<Id>();
        Set<Id> accountIds = new Set<Id>();
        for (Call2_vod_c__x call : veevaCalls) {
            if (accountIds.add(call.Account_vod_c__r.Id)) {
                orderedAccountIds.add(call.Account_vod_c__r.Id);
            }
        }
        Map<Id, Account__x> idToVeevaAccount = new Map<Id, Account__x>();
        for (Account__x acc : [
                SELECT Id, External_ID_vod_c__c, GT_Account_Record_Type_c__c
                FROM Account__x
                WHERE Id IN :accountIds
                AND External_ID_vod_c__c != NULL
                AND GT_Account_Record_Type_c__c IN ('Professional_vod', 'Pharmacist', 'Unverified Professional')
        ]) {
            idToVeevaAccount.put(acc.Id, acc);
        }
        Integer rLimit = 10;
        for (Id accId : orderedAccountIds) {
            if (idToVeevaAccount.containsKey(accId) && mdmIds.size() < rLimit) {
                mdmIds.add(idToVeevaAccount.get(accId).External_ID_vod_c__c);
            }
        }
        return mdmIds;
    }

    @Future(Callout=true)
    public static void subscribeVeevaAccounts(String spendUserId) {
        Set<String> mdmIds = new Set<String>(getVeevaAccountMdmIds(spendUserId));
        for (Account account : [SELECT MDMID_gne__c FROM Account WHERE MDMID_gne__c IN :mdmIds]) {
            mdmIds.remove(account.MDMID_gne__c);
        }
        List<Account> accounts;
        if (!mdmIds.isEmpty()) {
            accounts = new GNE_Subscribe_Util().searchAndSubscribeAccounts(mdmIds);
        }
    }

    with sharing class ProductLocator {
        /**
         * Filter products based on records visibility
         * @param products all available products
         *
         * @return filtered product list
         */
        public List<Product_vod__c> filterProducts(List<Product_vod__c> products) {
            Map<String, Product_vod__c> nameToProduct = new Map<String, Product_vod__c>();
            for (Product_vod__c prod : [
                    SELECT Id, Name, Disease_Indication_gne__c, Product_Type_vod__c, Therapeutic_Area_vod__c, Therapeutic_Class_vod__c
                    FROM Product_vod__c
                    WHERE (Name = 'No Product discussed') OR (Product_Type_vod__c = 'Detail' AND Detail_Product_Subtype_Code_gne__c = 'Brand')
            ]) {
                nameToProduct.put(prod.Name, prod);
            }
            Set<String> uniqueNames = new Set<String>();
            List<Product_vod__c> result = new List<Product_vod__c>();
            for (Product_vod__c prod : products) {
                Product_vod__c visibleProduct = nameToProduct.get(prod.Name);
                if (visibleProduct == null || visibleProduct == prod) {
                    if (uniqueNames.add(prod.Name)) {
                        result.add(prod);
                    }
                }
            }
            return result;
        }
    }
}