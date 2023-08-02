public without sharing class GNE_SFA2_S2S_Util {
    
    public static final String DATETIME_GMT_FORMAT = 'yyyy-MM-dd HH:mm:ss'; 
    public static final String DATE_FORMAT = 'yyyy-MM-dd';
    public static final String PER_USER_TAG = 'Per_User';
    
    public static final String MESSAGE_CODE_SUCCESS = 'SUCCESS';
    public static final String MESSAGE_CODE_FAIL = 'FAIL';
    
    public static final String SCHEDULER_JOB_SUPPORT_EMAIL_NOTIFICATION = 'S2SSupportEmailNotification';
    public static final String SCHEDULER_JOB_EXT_SHARING_CLEANUP = 'S2SExternalSharingCleanup';
    
    public static final Set<String> EXT_SHARING_INACTIVE_STATUSES = new Set<String>{'Deleted', 'Inactive'};
    
    private static String currentExternalSystemName;
    
    public static String formatDateTime(DateTime dt) {
        return dt!=null ? dt.formatGmt(DATETIME_GMT_FORMAT) : null;
    }
    
    public static String formatDate(Date d) {
        return d!=null ? DateTime.newInstanceGmt(d, Time.newInstance(0,0,0,0)).formatGmt(DATE_FORMAT) : null;
    } 
    
    public static Date parseDateString(String dateAsString) {
        return String.isNotBlank(dateAsString) ? Date.valueOf(dateAsString) : null;
    }
    
    public static DateTime parseDateTimeString(String dateTimeAsString) {
        return String.isNotBlank(dateTimeAsString) ? DateTime.valueOfGmt(dateTimeAsString) : null;
    }
    
    public static Boolean isFeatureEnabled(String feature) {
        return GNE_SFA2_S2S_Config.isFeatureEnabled(feature);
    }
    
    public static Boolean isS2SEnabled() {
        return GNE_SFA2_S2S_Config.isS2SEnabled();
    }
    
    public static Exception createException(String errorCode) {
        return createException(errorCode, null, null);
    }
    
    public static Exception createException(String errorCode, List<String> messageValues) {
        return createException(errorCode, null, messageValues);
    }
    
    public static Exception createException(String errorCode, String errorMessage, List<String> messageValues) {
        errorMessage = errorMessage!=null ? errorMessage : GNE_SFA2_S2S_Config.getErrorMessage(errorCode);
        return new S2SException(errorCode, messageValues!=null && !messageValues.isEmpty() ? String.format(errorMessage, messageValues) : errorMessage);
    }
    
    public static String getCurrentExternalSystemName() {
        return GNE_SFA2_S2S_ServiceEngine.getServiceEngine().getExternalSystemName();
    }
    
    public static void addDebugMessage(String message) {
        System.debug(message);
        
        if(GNE_SFA2_S2S_Config.isDebugEnabled()) {
            GNE_SFA2_S2S_ServiceEngine.getServiceEngine().getDebugInfo().addMessage(message);
        }
    }
    
    public static void startDebugAction(String actionName) {
        startDebugAction(actionName, null);
    }
        
    public static void startDebugAction(String actionName, String additionalMessage) {
        if(GNE_SFA2_S2S_Config.isDebugEnabled()) {
	        DebugAction dAction = new DebugAction(actionName);
	        GNE_SFA2_S2S_ServiceEngine.getServiceEngine().getDebugActions().put(dAction.getName(), dAction.start(additionalMessage));
        }
    }
    
    public static void endDebugAction(String actionName) {
        endDebugAction(actionName, null);
    }
    
    public static void endDebugAction(String actionName, String additionalMessage) {
        if(GNE_SFA2_S2S_Config.isDebugEnabled()) {
	        DateTime now = System.now();
	        GNE_SFA2_S2S_Interface.DebugActionInterface dAction = GNE_SFA2_S2S_ServiceEngine.getServiceEngine().getDebugActions().remove(actionName);
	        dAction = dAction!=null ? dAction : (GNE_SFA2_S2S_Interface.DebugActionInterface)new DebugAction(actionName);
	        dAction.end(additionalMessage);
        }
    }
    
    public static Account searchOrCreateAccount(GNE_SFA2_S2S_Interface.PersonAccountInterface acc, GNE_SFA2_S2S_Interface.AddressInterface addr) {
        return searchOrCreateAccount(acc, addr, getCurrentExternalSystemName());
    }
    
    public static Account searchOrCreateAccount(GNE_SFA2_S2S_Interface.PersonAccountInterface acc, GNE_SFA2_S2S_Interface.AddressInterface addr, String extSystemName) {
        startDebugAction('searchOrCreateAccount');
        String accLocalId = acc.isLocalRecord() ? acc.getLocalId() : acc.getExtId();
        String accExtId = acc.isLocalRecord() ? acc.getExtId() : acc.getLocalId();
        String accMdmId = acc.getMdmId();
        
        String addrLocalId = addr.isLocalRecord() ? addr.getLocalId() : addr.getExtId();
        String addrExtId = addr.isLocalRecord() ? addr.getExtId() : addr.getLocalId();
        String addrMdmId = acc.getMdmId();
        
        Set<String> allIds = new Set<String>();
        Set<Id> sfdcIds = new Set<Id>();
        
        for(String rid : new Set<String>{accLocalId, accExtId, accMdmId, addrLocalId, addrExtId, addrMdmId}) {
            if(String.isNotBlank(rid)) {
                allIds.add(rid);
                
                if(rid instanceof Id) {
                    sfdcIds.add(rid);
                }
            }
        }
        
        startDebugAction('searchOrCreateAccount.fetchMergeWinnerIds');
        Map<Id,Id> winnerIdsMap = CORE_Merge_Util.getWinnerIdsMap(sfdcIds);
        endDebugAction('searchOrCreateAccount.fetchMergeWinnerIds');
        sfdcIds.addAll(winnerIdsMap.values());
        startDebugAction('searchOrCreateAccount.search');
        Account accRec = getAccountRecord(sfdcIds, allIds);
        Address_vod__c addrRec = accRec!=null && !accRec.Address_vod__r.isEmpty() ? accRec.Address_vod__r[0] : null;
        endDebugAction('searchOrCreateAccount.search', 'Account = ' + (accRec!=null ? accRec.Id : null) + ', Address = ' + (addrRec!=null ? addrRec.Id : null));
        Account accountToUpsert = new Account();
        Address_vod__c addressToUpsert = new Address_vod__c();
        
        Boolean accountChanged = false, addressChanged = false;
        Boolean accountExists = accRec!=null;
        Boolean addressExists = addrRec!=null;
        String extIdFieldName = extSystemName + '_Id__c';
        
        if(accountExists) {
            accountToUpsert.Id = accRec.Id;
        } else {
            accRec = accountToUpsert = acc.getAccountRecord();
            accountToUpsert.OwnerId = GNE_SFA2_S2S_Config.getAccountOwnerId();
            accountToUpsert.RecordTypeId = GNE_SFA2_S2S_Config.getAccountRecordTypeId();
            accountChanged = true;
        }
        
        if(addressExists) {
            addressToUpsert.Id = addrRec.Id;
        } else {
            addrRec = addressToUpsert = addr.getAddressRecord();
            
            if(!accountExists) {
                addressToUpsert.GOLD_RECORD_gne__c = addressToUpsert.AMS_gold_record_gne__c = addr.isGold();
                addressToUpsert.Primary_vod__c = true;
            }
            
            Map<String,Id> recordTypeIdsMap = GNE_SFA2_SBC_DAO.getRecordTypeIdMap('Address_vod__c', new Set<String>{GNE_SFA2_S2S_Config.RECORD_TYPE_ADDR_REP, GNE_SFA2_S2S_Config.RECORD_TYPE_ADDR_COMPANY});
            addressToUpsert.RecordTypeId = String.isNotBlank(addr.getMdmId()) ? recordTypeIdsMap.get(GNE_SFA2_S2S_Config.RECORD_TYPE_ADDR_COMPANY.toUpperCase()) : recordTypeIdsMap.get(GNE_SFA2_S2S_Config.RECORD_TYPE_ADDR_REP.toUpperCase());
            addressChanged = true;
        }
        
        if(accRec.get(extIdFieldName)!=accExtId) {
            accountToUpsert.put(extIdFieldName, accExtId);
            accRec.put(extIdFieldName, accExtId);
            accountChanged = true;
        }
        
        if(addrRec.get(extIdFieldName)!=addrExtId) {
            addressToUpsert.put(extIdFieldName, addrExtId);
            addrRec.put(extIdFieldName, addrExtId);
            addressChanged = true;
        }
        
        Boolean isFutureCallDisabled = System.isFuture() || System.isBatch() || System.isScheduled() || System.isQueueable();
        Account futureCallAccount = null;
        Address_vod__c futureCallAddress = null;
        
        if(accountChanged) {
            if(!accountExists || isFutureCallDisabled) {
                upsertAccount(accountToUpsert);
            } else {
                futureCallAccount = accountToUpsert;
            }
        }
        
        if(addressChanged) {
            if(!addressExists || isFutureCallDisabled) {
                if(!addressExists) {
                    addressToUpsert.Account_vod__c = accRec.Id;
                }
                
                upsertAddress(addressToUpsert);
            } else {
                futureCallAddress = addressToUpsert;
            }
        }
        
        if(futureCallAccount!=null || futureCallAddress!=null) {
            futureUpsertAccountAndAddress(JSON.serialize(futureCallAccount), JSON.serialize(futureCallAddress));
        }
        
        if(!accountExists || !addressExists) {
            startDebugAction('searchOrCreateAccount.searchAfterUpsert');
            accRec = getAccountRecord(new Set<Id>{accountToUpsert.Id, addressToUpsert.Id}, null);
            endDebugAction('searchOrCreateAccount.searchAfterUpsert');
            accRec.put(extIdFieldName, accExtId);
        }
        
        endDebugAction('searchOrCreateAccount');
        return accRec;
    }
    
    private static void upsertAccount(Account accountToUpsert) {
        if(accountToUpsert.Id!=null) {
            GNE_SFA2_Account_Trigger_Helper.setAccountTrig(true);
        }
                
        startDebugAction('searchOrCreateAccount.upsertAccount', 'Trigger On: ' + !GNE_SFA2_Account_Trigger_Helper.inAccountTrig());
        upsert accountToUpsert;
        endDebugAction('searchOrCreateAccount.upsertAccount');
        GNE_SFA2_Account_Trigger_Helper.setAccountTrig(false);
    }
    
    private static void upsertAddress(Address_vod__c addressToUpsert) {
        if(addressToUpsert.Id!=null) {
            GNE_SFA2_Address_Trigger_Helper.setAddressTrig(true);
        }
        
        startDebugAction('searchOrCreateAccount.upsertAddress', 'Trigger On: ' + !GNE_SFA2_Address_Trigger_Helper.inAddressTrig());
        upsert addressToUpsert;
        endDebugAction('searchOrCreateAccount.upsertAddress');
        GNE_SFA2_Address_Trigger_Helper.setAddressTrig(false);
    }
    
    @future 
    private static void futureUpsertAccountAndAddress(String accountAsJSON, String addressAsJSON) {
        Account accoutToUpsert = String.isNotBlank(accountAsJSON) ? (Account)JSON.deserialize(accountAsJSON, Account.class) : null;
        Address_vod__c addressToUpsert = String.isNotBlank(addressAsJSON) ? (Address_vod__c)JSON.deserialize(addressAsJSON, Address_vod__c.class) : null;
        
        if(accoutToUpsert!=null) {
            upsertAccount(accoutToUpsert);
        }
        
        if(addressToUpsert!=null) {
            upsertAddress(addressToUpsert);
        }
    }
    
    private static Account getAccountRecord(Set<Id> sfdcIds, Set<String> extIds) {
        List<Account> accRecs = getAccountRecords(sfdcIds, extIds, sfdcIds, extIds, null, null, true, null);
        return !accRecs.isEmpty() ? accRecs[0] : null;
    }
    
    public static List<Account> getAccountRecords(Set<Id> accSfdcIds) {
        return getAccountRecords(accSfdcIds, null, null, null, null, null, null, null);
    }
    
    public static List<Account> getAccountRecords(Set<Id> accSfdcIds, Set<Id> addrSfdcIds) {
        return getAccountRecords(accSfdcIds, null, addrSfdcIds, null, null, null, null, null);
    }
    
    public static List<Account> getAccountRecords(Set<Id> accSfdcIds, Set<String> accExtIds, Set<Id> addrSfdcIds, Set<String> addrExtIds) {
        return getAccountRecords(accSfdcIds, accExtIds, addrSfdcIds, addrExtIds, null, null, null, null);
    }
    
    public static List<Account> getAccountRecords(Set<Id> accSfdcIds, Set<Id> addrSfdcIds, Set<String> accfieldNames, Set<String> addrFieldNames) {
        return getAccountRecords(accSfdcIds, null, addrSfdcIds, null, accfieldNames, addrFieldNames, null, null);
    }
    
    public static List<Account> getAccountRecords(Set<Id> accSfdcIds, Set<String> accExtIds, Set<Id> addrSfdcIds, Set<String> addrExtIds, Set<String> accfieldNames, Set<String> addrFieldNames, Boolean isAccSingleMode, Boolean isAddrSingleMode) {
        Set<String> accFields = new Set<String>{
            String.valueOf(Account.Id).toUpperCase(),
            String.valueOf(Account.MDMID_gne__c).toUpperCase(),
            String.valueOf(Account.Roche_Id_can_gne__c).toUpperCase(),
            String.valueOf(Account.MA_Id__c).toUpperCase(),
            String.valueOf(Account.PACT_Id__c).toUpperCase(),
            String.valueOf(Account.Name).toUpperCase(),
            String.valueOf(Account.FirstName).toUpperCase(),
            String.valueOf(Account.LastName).toUpperCase(),
            String.valueOf(Account.Middle_vod__c).toUpperCase(),
            String.valueOf(Account.MDMID_Status_gne__c).toUpperCase(),
            String.valueOf(Account.Status_gne__c).toUpperCase(),
            String.valueOf(Account.Professional_Type_gne__c).toUpperCase(),
            String.valueOf(Account.Credentials_gne__c).toUpperCase(),
            String.valueOf(Account.Specialties_gne__c).toUpperCase(),
            String.valueOf(Account.Cell_Phone_gne__c).toUpperCase(),
            String.valueOf(Account.PersonEmail).toUpperCase(),
            String.valueOf(Account.Secondary_Email_gne__c).toUpperCase()
        };
        
        for(String fldName : (accfieldNames!=null ? accfieldNames : new Set<String>())) {
            accFields.add(fldName.toUpperCase());
        }
        
        Set<String> addrFields = new Set<String>{
            String.valueOf(Address_vod__c.Id).toUpperCase(),
            String.valueOf(Address_vod__c.MDM_Address_Id_gne__c).toUpperCase(),
            String.valueOf(Address_vod__c.MA_Id__c).toUpperCase(),
            String.valueOf(Address_vod__c.PACT_Id__c).toUpperCase(),
            String.valueOf(Address_vod__c.Name).toUpperCase(),
            String.valueOf(Address_vod__c.Address_Line_2_vod__c).toUpperCase(),
            String.valueOf(Address_vod__c.City_vod__c).toUpperCase(),
            String.valueOf(Address_vod__c.State_vod__c).toUpperCase(),
            String.valueOf(Address_vod__c.Zip_vod__c).toUpperCase(),
            String.valueOf(Address_vod__c.Zip_4_vod__c).toUpperCase(),
            String.valueOf(Address_vod__c.Country_gen__c).toUpperCase(),
            String.valueOf(Address_vod__c.Phone_vod__c).toUpperCase(),
            String.valueOf(Address_vod__c.Phone_2_vod__c).toUpperCase(),
            String.valueOf(Address_vod__c.Email_gne__c).toUpperCase(),
            String.valueOf(Address_vod__c.Fax_vod__c).toUpperCase(),
            String.valueOf(Address_vod__c.Fax_2_vod__c).toUpperCase(),
            String.valueOf(Address_vod__c.MDM_Status_gne__c).toUpperCase(),
            String.valueOf(Address_vod__c.GOLD_RECORD_gne__c).toUpperCase(),
            String.valueOf(Address_vod__c.Primary_vod__c).toUpperCase(),
            String.valueOf(Address_vod__c.Inactive_vod__c),
            String.valueOf(Address_vod__c.Location_gne__Latitude__s).toUpperCase(),
            String.valueOf(Address_vod__c.Location_gne__Longitude__s).toUpperCase(),
            String.valueOf(Address_vod__c.Province_can_gne__c).toUpperCase(),
            String.valueOf(Address_vod__c.Postal_Code_can_gne__c).toUpperCase(),
            String.valueOf(Address_vod__c.Region_Code_gne__c).toUpperCase()
            
        };
        
        for(String fldName : (addrFieldNames!=null ? addrFieldNames : new Set<String>())) {
            addrFields.add(fldName.toUpperCase());
        }
        
        List<String> accWhereStatements = new List<String>();
        List<String> addrWhereStatements = new List<String>();
        
        if(accSfdcIds!=null && !accSfdcIds.isEmpty()) {
            accWhereStatements.add('ID IN :accSfdcIds');
        }
        
        if(accExtIds!=null && !accExtIds.isEmpty()) {
            accWhereStatements.add('MDMID_gne__c IN :accExtIds');
            accWhereStatements.add('MA_Id__c IN :accExtIds');
            accWhereStatements.add('PACT_Id__c IN :accExtIds');
        }
        
        if(addrSfdcIds!=null && !addrSfdcIds.isEmpty()) {
            addrWhereStatements.add('ID IN :addrSfdcIds');
        }
        
        if(addrExtIds!=null && !addrExtIds.isEmpty()) {
            addrWhereStatements.add('MDM_Address_Id_gne__c IN :addrExtIds');
            addrWhereStatements.add('MA_Id__c IN :addrExtIds');
            addrWhereStatements.add('PACT_Id__c IN :addrExtIds');
        }
        
        isAccSingleMode = isAccSingleMode!=null ? isAccSingleMode : ((accSfdcIds!=null && accSfdcIds.size()==1) || (accExtIds!=null && accExtIds.size()==1));
        
        return !accWhereStatements.isEmpty() ? Database.query(String.format(
            'SELECT {0}, (SELECT {1} FROM Address_vod__r{4} ORDER BY {5}{6}) FROM Account WHERE {2} ORDER BY LastName, FirstName{3}', new String[]{
                String.join(new List<String>(accFields), ','),
                String.join(new List<String>(addrFields), ','),
                String.join(accWhereStatements, ' OR '),
                isAccSingleMode ? ' LIMIT 1' : '', 
                !addrWhereStatements.isEmpty() ? (' WHERE ' + String.join(addrWhereStatements, ' OR ')) : '',
                'Primary_vod__c DESC, GOLD_RECORD_gne__c DESC, LastModifiedDate DESC',
                isAddrSingleMode!=false ? ' LIMIT 1' : ''
        })) : new List<Account>();
    }
    
    public static String getSalesforceBaseUrl() {
        return URL.getSalesforceBaseUrl().toExternalForm();
    }
    
    public static String getSalesforceURL(String internalUrl) {
        return getSalesforceBaseUrl() + (internalUrl.startsWith('/') ? '' : '/') + internalUrl;
    }
        
    public static String getHtmlLink(String internalUrl, String text, String title) {
        return String.format('<a href="{0}" title="{1}">{2}</a>', new String[]{getSalesforceURL(internalUrl), title, text});
    }
    
    public static void sendSupportEmailNotification(DateTime startDateTime) {
        Set<String> exludedMessageCodes = (Set<String>)GNE_SFA2_S2S_Config.getConfigItemJSONValue(SCHEDULER_JOB_SUPPORT_EMAIL_NOTIFICATION + 'ExcludedCodes', Set<String>.class);
        exludedMessageCodes = exludedMessageCodes!=null ? exludedMessageCodes : new Set<String>();
        exludedMessageCodes.add(GNE_SFA2_S2S_UTIL.MESSAGE_CODE_SUCCESS);
        
        List<AggregateResult> ars = [
            SELECT Feature_gne__c, Message_Code_gne__c, count(Id) size
            FROM SFA2_S2S_Log_gne__c
            WHERE Message_Code_gne__c NOT IN :exludedMessageCodes
                AND LastModifiedDate >= :startDateTime.addMinutes(-1)
            GROUP BY Feature_gne__c, Message_Code_gne__c
            ORDER BY Feature_gne__c, Message_Code_gne__c
            LIMIT :Limits.getLimitQueryRows()
        ];
        
        List<SupportEmailRow> reportRows = new List<SupportEmailRow>();
        SupportEmailRow lastRow = null;
        List<String> emailsList = new List<String>();
        Set<String> emailsSet = new Set<String>();
        
        for(AggregateResult ar : ars) {
            String feature = (String)ar.get(String.valueOf(SFA2_S2S_Log_gne__c.Feature_gne__c));
            String code = (String)ar.get(String.valueOf(SFA2_S2S_Log_gne__c.Message_Code_gne__c));
            Integer size = (Integer)ar.get('size');
            
            if(lastRow==null || lastRow.getFeature()!=feature) {
                lastRow = new SupportEmailRow(feature);
                reportRows.add(lastRow);
                List<String> featureEmails = GNE_SFA2_S2S_Config.getSupportEmails(feature);
                
                for(String fEmail : featureEmails) {
                    if(emailsSet.add(fEmail.toUpperCase())) {
                        emailsList.add(fEmail);
                    }
                }
            }
            
            lastRow.addCode(code);
            lastRow.increaseSize(size);
        }
        
        if(!reportRows.isEmpty() && !emailsList.isEmpty()) {
            intSendSupportEmailNotification(startDateTime, emailsList, reportRows);
        }
    }
    
    private static void intSendSupportEmailNotification(DateTime startDateTime, List<String> emailsList, List<SupportEmailRow> reportRows) {
        List<String> htmlRows = new List<String>();
        Integer totalSize = 0;
        
        for(SupportEmailRow row : reportRows) {
            htmlRows.add(row.asHtmlRow());
            totalSize += row.getSize();
        }
        
        Schema.DescribeSObjectResult logDescribe = SFA2_S2S_Log_gne__c.sObjectType.getDescribe();
        
        String htmlBody = String.format('{0}<br/>{1}<br/><br/><table align="center" style="[[table-style]]"><thead><tr><th style="[[cell-style]]">{2}</th></tr></thead><tbody>{3}</tbody></table><br/><br/>{4}', new String[]{
            'Dear S2S Support,\n\n' + totalSize + ' new error' + (totalSize>1 ? 's' : '') + ' were logged since ' + GNE_SFA2_S2S_Util.formatDateTime(startDateTime) + ' (GMT).',
            'List of all errors can be found ' + GNE_SFA2_S2s_Util.getHtmlLink(logDescribe.getKeyPrefix(), 'here', logDescribe.getLabelPlural()) + '.',
            String.join(new String[]{'FEATURE', 'ERROR CODE', 'SIZE'}, '</th><th style="[[cell-style]]">'),
            String.join(htmlRows, ''),
            'Regards,\nS2S Logger'
        });
        
        htmlBody = htmlBody
            .replaceAll('\\n','<br/>')
            .replaceAll('\\[\\[table-style\\]\\]', 'border:1px solid black;border-collapse:collapse;text-align:center;')
            .replaceAll('\\[\\[cell-style\\]\\]', 'border:1px solid black;border-collapse:collapse;text-align:center;')
            .replaceAll('\\[\\[text-cell-style\\]\\]', 'border:1px solid black;border-collapse:collapse;text-align:left;');
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        Id orgWideAddressId = GNE_SFA2_S2S_Config.getOrgWideEmailAddressId();
        
        if(orgWideAddressId!=null) {
            mail.setOrgWideEmailAddressId(orgWideAddressId);
        }
        
        mail.setToAddresses(emailsList);
        mail.setSubject('[S2S] Salesforce 2 Salesforce Error' + (totalSize>1 ? 's' : '') +' Detected (' + totalSize + '), env: ' + getSalesforceBaseUrl());
        mail.setHtmlBody(htmlBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail}, true);
    }
    
    public static void scheduleExternalSharingCleanupJob() {
        String executionTimeExpression  = GNE_SFA2_S2S_Config.getConfigItemValue(SCHEDULER_JOB_EXT_SHARING_CLEANUP + 'Time');
        GNE_SFA2_S2S_ExtSharingCleanupBatch batch = new GNE_SFA2_S2S_ExtSharingCleanupBatch();
        
        if(executionTimeExpression!=null && !batch.getConnectionIds().isEmpty()) {
            GNE_SFA2_Scheduler.scheduleJob(batch, SCHEDULER_JOB_EXT_SHARING_CLEANUP, executionTimeExpression);
        }
    }
    
    public virtual class Request implements GNE_SFA2_S2S_Interface.RequestInterface {
        protected transient List<Record> records;
        protected Actor actor;
        protected Boolean allOrNone;
        
        public Request() {}
        
        public Request(List<GNE_SFA2_S2S_Interface.RecordInterface> records, Actor actor, Boolean allOrNone) {
            getRecords().addAll(records);
            this.actor = actor;
            this.allOrNone = allOrNone;
        }
        
        public virtual System.Type getSelfClass() {
            return Request.class;
        }
        
        public virtual List<GNE_SFA2_S2S_Interface.RecordInterface> getRecords() {
            if(this.records==null) {
                this.records = new List<Record>();
            }
            
            return this.records;
        }
        
        public virtual void addRecord(GNE_SFA2_S2S_Interface.RecordInterface rec) {
            getRecords().add(rec);
        }
        
        public virtual GNE_SFA2_S2S_Interface.ActorInterface getActor() {
            return this.actor;
        }
        
        public virtual void setActor(GNE_SFA2_S2S_Interface.ActorInterface actor) {
            this.actor = (Actor)actor;
        }
        
        public virtual Boolean isAllOrNone() {
            return this.allOrNone!=false;
        }
    }
    
    public virtual class Actor extends Record implements GNE_SFA2_S2S_Interface.ActorInterface {
        protected String alias;
        protected String unixId;
        protected String fedId;
        protected String userName;
        protected String name;
        protected String firstName;
        protected String lastName;
        protected String email;
        protected String phone;
        protected String mobilePhone;
        protected String profileName;
        private transient Boolean isFetched;
        
        public Actor() {
            super();
        }
        
        public Actor(Id uId) {
            super(uId, null);
        }
        
        public Actor(User u) {
            super(u.Id, null);
            init(u);
        }
        
        public Actor(GNE_SFA2_S2S_Interface.ActorInterface other) {
            super(other.getLocalId(), other.getExtId());
            this.alias = other.getAlias();
            this.unixId = other.getUnixId();
            this.fedId = other.getFedId();
            this.userName = other.getUserName();
            this.firstName = other.getFirstName();
            this.lastName = other.getLastName();
            this.name = other.getName();
            this.email = other.getEmail();
            this.phone = other.getPhone();
            this.mobilePhone = other.getMobilePhone();
            this.profileName = other.getProfileName();
        }
        
        private void init(User u) {
            this.alias = u.Alias;
            this.unixId = u.External_Id_gne__c;
            this.fedId = u.FederationIdentifier;
            this.userName = u.UserName;
            this.firstName = u.FirstName;
            this.lastName = u.LastName;
            this.name = u.Name;
            this.email = u.Email;
            this.phone = u.Phone;
            this.mobilePhone = u.MobilePhone;
            this.profileName = u.Profile.Name;
        }
        
        public virtual String getAlias() {
            return this.alias;
        }
        
        public virtual String getUnixId() {
            return this.unixId;
        }
        
        public virtual String getFedId() {
            return this.fedId;
        }
        
        public virtual String getUserName() {
            return this.userName;
        }
        
        public virtual String getName() {
            return this.name;
        }
        
        public virtual String getFirstName() {
            return this.firstName;
        }
        
        public virtual String getLastName() {
            return this.lastName;
        }
        
        public virtual String getEmail() {
            return this.email;
        }
        
        public virtual String getPhone() {
            return this.phone;
        }
        
        public virtual String getMobilePhone() {
            return this.mobilePhone;
        }
        
        public virtual String getProfileName() {
            return this.profileName;
        }
        
        public virtual Boolean fetchWithLocalUser() {
            if(isFetched==null) {
                isFetched = false;
                
	            List<User> users = String.isNotBlank(getUnixId()) ? [
	                SELECT Id, Alias, External_Id_gne__c, FederationIdentifier,
	                    FirstName, LastName, UserName, Name, Email, Phone, MobilePhone, Profile.Name 
	                FROM User WHERE IsActive = true AND External_Id_gne__c = :getUnixId() LIMIT 1
	            ] : String.isNotBlank(getLocalId()) ? [
	                SELECT Id, Alias, External_Id_gne__c, FederationIdentifier, 
	                    FirstName, LastName, UserName, Name, Email, Phone, MobilePhone, Profile.Name 
	                FROM User WHERE IsActive = true AND Id = :getLocalId() LIMIT 1
	            ] : new List<User>();
	            
	            for(User u : users) {
	                isFetched = true;
	                if(u.Id!=getLocalId()) {
	                    setExtId(getLocalId());
	                    setLocalId(u.Id);    
	                }
	                
	                init(u);
	            }
            }
            
            return isFetched;
        }
    }
    
    public virtual class PersonAccount extends Record implements GNE_SFA2_S2S_Interface.PersonAccountInterface {
        protected String mdmId;
        protected String mrmId;
        protected String name;
        protected String firstName;
        protected String lastName;
        protected String middleName;
        protected String status;
        protected String profType;
        protected String credentials;
        protected String specialties;
        protected String phone;
        protected String mobilePhone;
        protected String email;
        protected String fax;
        protected Address address;
        
        public PersonAccount() {
            super();
        }
        
        public PersonAccount(Id localId, Id addrId) {
            super(localId, null);
            this.address = String.isNotBlank(addrId) ? new Address(addrId) : null;
        }
        
        public PersonAccount(Account acc, Address_vod__c addr) {
            super(acc.Id, null);
            init(acc, addr);
            
        }
        
        private void init(Account acc, Address_vod__c addr) {
            this.mdmId = acc.MDMID_gne__c;
            this.mrmId = acc.Roche_Id_can_gne__c;
            this.name = acc.Name;
            this.firstName = acc.FirstName;
            this.lastName = acc.LastName;
            this.middleName = acc.Middle_vod__c;
            this.status = acc.Status_gne__c;
            this.profType = acc.Professional_Type_gne__c;
            this.credentials = acc.Credentials_gne__c;
            this.specialties = acc.Specialties_gne__c;
            this.address = addr!=null ? new Address(addr) : null;
            
            addr = addr!=null ? addr : new Address_vod__c();
            this.phone = addr.Phone_vod__c;
            this.mobilePhone = String.isNotBlank(acc.Cell_Phone_gne__c) ? acc.Cell_Phone_gne__c : addr.Phone_2_vod__c; 
            this.email = String.isNotBlank(acc.PersonEmail) ? acc.PersonEmail : String.isNotBlank(acc.Secondary_Email_gne__c) ? acc.Secondary_Email_gne__c : addr.Email_gne__c;
            this.fax = String.isNotBlank(addr.Fax_vod__c) ? addr.Fax_vod__c : String.isNotBlank(addr.Fax_2_vod__c) ? addr.Fax_2_vod__c : null;
        }
        
        public virtual String getMdmId() {
            return this.mdmId;
        }
        
        public virtual String getMrmId() {
            return this.mrmId;
        }
        
        public virtual String getName() {
            return this.name;
        }
        
        public virtual String getFirstName() {
            return this.firstName;
        }
        
        public virtual String getLastName() {
            return this.lastName;
        }
        
        public virtual String getMiddleName() {
            return this.middleName;
        }
        
        public virtual String getStatus() {
            return this.status;
        }
        
        public virtual String getProfType() {
            return this.profType;
        }
        
        public virtual String getCredentials() {
            return this.credentials;
        }
        
        public virtual String getSpecialties() {
            return this.specialties;
        }
        
        public virtual String getEmail() {
            return this.email;
        }
        
        public virtual String getPhone() {
            return this.phone;
        }
        
        public virtual String getMobilePhone() {
            return this.mobilePhone;
        }
        
        public virtual String getFax() {
            return this.fax;
        }
        
        public virtual GNE_SFA2_S2S_Interface.AddressInterface getAddress() {
            return this.address;
        }
        
        public virtual Account searchOrCreate() {
            return searchOrCreate(getAddress());
        }
        
        public virtual Account searchOrCreate(GNE_SFA2_S2S_Interface.AddressInterface address) {
            return searchOrCreateAccount(this, address);
        }
        
        public virtual Account getAccountRecord() {
            return new Account(
                MDMID_gne__c = getMdmId(),
                Roche_Id_can_gne__c = getMrmId(),
                FirstName = getFirstName(),
                LastName = getLastName(),
                Middle_vod__c = getMiddleName(),
                Middle_gne__c = getMiddleName(),
                Status_gne__c = getStatus(),
                MDMID_Status_gne__c = getStatus()=='Active' || getStatus()=='Indeterminate' ? 'Active' : 'Inactive',
                Professional_Type_gne__c = getProfType(),
                Credentials_gne__c = getCredentials(),
                Credentials_gne__pc = getCredentials(),
                Credentials_vod__c = getCredentials(),
                Specialties_gne__c = getSpecialties(),
                PersonEmail = getEmail(),
                Cell_Phone_gne__c = getMobilePhone()
            );
        }
    }
    
    public virtual class Address extends Record implements GNE_SFA2_S2S_Interface.AddressInterface {
        protected String mdmId;
        protected String name;
        protected String suite;
        protected String city;
        protected String state;
        protected String zip;
        protected String zip4;
        protected String country;
        protected String status;
        protected Boolean primary;
        protected Boolean gold;
        protected Double latitude;
        protected Double longitude;
        
        public Address() {
            super();
        }
        
        public Address(Id localId) {
            super(localId, null);
        }
        
        public Address(Address_vod__c addr) {
            super(addr.Id, null);
            init(addr);
        }
        
        private void init(Address_vod__c addr) {
            this.mdmId = addr.MDM_Address_Id_gne__c;
            this.name = addr.Name;
            this.suite = addr.Address_Line_2_vod__c;
            this.city = addr.City_vod__c;
            this.state = (addr.Region_Code_gne__c == 2) ? addr.Province_can_gne__c : addr.State_vod__c;
            this.zip = String.isNotBlank(addr.Zip_vod__c) ? addr.Zip_vod__c.left(5) : null;
            this.zip4 = String.isNotBlank(addr.Zip_4_vod__c) ? addr.Zip_4_vod__c : (String.isNotBlank(addr.Zip_vod__c) && addr.Zip_vod__c.contains('-')) ? addr.Zip_vod__c.substringAfter('-') : null;
            this.country = addr.Country_gen__c;
            this.status = addr.MDM_Status_gne__c;
            this.gold = addr.GOLD_RECORD_gne__c;
            this.primary = addr.Primary_vod__c;
            this.latitude = addr.Location_gne__Latitude__s;
            this.longitude = addr.Location_gne__Longitude__s;
        }
        
        public virtual String getMdmId() {
            return this.mdmId;
        }
        
        public virtual String getName() {
            return this.name;
        }
        
        public virtual String getSuite() {
            return this.suite;
        }
        
        public virtual String getCity() {
            return this.city;
        }
        
        public virtual String getState() {
            return this.state;
        }
        
        public virtual String getZip() {
            return this.zip;
        }
        
        public virtual String getZip4() {
            return this.zip4;
        }
        
        public virtual String getCountry() {
            return this.country;
        }
        
        public virtual String getStatus() {
            return this.status;
        }
        
        public virtual Boolean isGold() {
            return this.gold==true;
        }
        
        public virtual Boolean isPrimary() {
            return this.primary==true;
        }
        
        public virtual Double getLatitude() {
            return this.latitude;
        }
        
        public virtual Double getLongitude() {
            return this.longitude;
        }
        
        public virtual Address_vod__c getAddressRecord() {
            Address_vod__c addrRec = new Address_vod__c(
                MDM_Address_Id_gne__c = getMdmId(),
                Name = getName(),
                Address_Line_2_vod__c = getSuite(),
                City_vod__c = getCity(),
                State_vod__c = getState(),
                Zip_vod__c = getZip(),
                Zip_4_vod__c = getZip4(),
                MDM_Status_gne__c = String.isNotBlank(getStatus()) ? getStatus() : 'Active',
                Active_Flag_gne__c = true,
                Inactive_vod__c = false
            );
            
            if(getLatitude()!=null && getLongitude()!=null) {
                addrRec.Latitude_vod__c = addrRec.Location_gne__Latitude__s = getLatitude();
                addrRec.Longitude_vod__c = addrRec.Location_gne__Longitude__s = getLongitude();
                addrRec.Force_Location_Update_gne__c = false;
            } else {
                addrRec.Force_Location_Update_gne__c = true;
            }
            
            if(String.isNotBlank(getCountry())) {
                addrRec.Country_gen__c = getCountry();
            }
                        
            return addrRec;
        }
    }
    
    public virtual class Record implements GNE_SFA2_S2S_Interface.RecordInterface {
        protected String localId;
        protected String extId;
        protected transient Boolean isLocalRecord;
        
        public Record() {
            this.isLocalRecord = true;
        }
        
        public Record(String localId, String extId) {
            this();
            this.localId = localId;
            this.extId = extId;
        }
        
        public virtual String getLocalId() {
            return this.localId;
        }
        
        public virtual String getExtId() {
            return this.extId;
        }
        
        public virtual void setLocalId(String localId) {
            this.localId = localId;
        }
        
        public virtual void setExtId(String extId) {
            this.extId = extId;
        }
        
        public virtual Boolean isLocalRecord() {
            return this.isLocalRecord==true;
        }
    }
    
    public virtual class Response implements GNE_SFA2_S2S_Interface.ResponseInterface {
        protected Boolean success;
        protected transient List<Record> records;
        protected List<Error> errors;
        
        public Response() {}
        
        public virtual System.Type getSelfClass() {
            return Response.class;
        }
        
        public virtual List<GNE_SFA2_S2S_Interface.RecordInterface> getRecords() {
            if(this.records==null) {
                this.records = new List<Record>();
            }
            
            return this.records;
        }
        
        public virtual void addRecord(GNE_SFA2_S2S_Interface.RecordInterface rec) {
            getRecords().add(rec);
        }
        
        public virtual List<GNE_SFA2_S2S_Interface.ErrorInterface> getErrors() {
            if(this.errors==null) {
                this.errors = new List<Error>();
            }
            
            return this.errors;
        }
        
        public virtual Boolean isSuccess() {
            return this.success==true;
        }
        
        public virtual void setSuccess(Boolean success) {
            this.success = success;
        }
        
        public virtual void onStart() {
            
        }
        
        public virtual void onFinish() {
            if(this.success!=false) {
                setSuccess(true);
            }
        }
        
        public virtual void addError(String errorCode, String errorMessage) {
            addError(null, null, errorCode, errorMessage, null, true);
        }
        
        public virtual void addError(String errorCode, String errorMessage, Boolean failTransaction) {
            addError(null, null, errorCode, errorMessage, null, failTransaction);
        }
        
        public virtual void addError(String localId, String extId, String errorCode, String errorMessage) {
            addError(localId, extId, errorCode, errorMessage, null, true);
        }
        
        public virtual void addError(String localId, String extId, String errorCode, String errorMessage, String stackTrace) {
            addError(localId, extId, errorCode, errorMessage, stackTrace, true);
        }
        
        public virtual void addError(String localId, String extId, String errorCode, String errorMessage, String stackTrace, Boolean failTransaction) {
            getErrors().add(new Error(localId, extId, errorCode, errorMessage, stackTrace));
            
            if(failTransaction!=false) {
                setSuccess(false);
            }
        }
    }
    
    public virtual class Error implements GNE_SFA2_S2S_Interface.ErrorInterface {
        protected String localId;
        protected String extId;
        protected String errorCode;
        protected String errorMessage;
        protected transient String stackTrace;
        
        public Error() {
            this(null, null, null, null);
        }
        
        public Error(String errorCode, String errorMessage) {
            this(null, null, errorCode, errorMessage, null);
        }
        
        public Error(String localId, String extId, String errorCode, String errorMessage) {
            this(localId, extId, errorCode, errorMessage, null);
        }
        
        public Error(String localId, String extId, String errorCode, String errorMessage, String stackTrace) {
            this.localId = localId;
            this.extId = extId;
            this.errorCode = errorCode;
            this.errorMessage = errorMessage;
            this.stackTrace = stackTrace;
        }
        
        public virtual String getLocalId() {
            return this.localId;
        }
        
        public virtual String getExtId() {
            return this.extId;
        }
        
        public virtual String getErrorCode() {
            return this.errorCode;
        }
        
        public virtual String getErrorMessage() {
            return this.errorMessage;
        }
        
        public virtual String getShortMessage() {
            return getErrorMessage()!=null ? getErrorMessage().substringBefore('\n').left(255) : null;
        }
        
        public virtual String getStackTrace() {
            return this.stackTrace;
        }
    }
    
    private class SupportEmailRow {
        private String feature;
        private List<String> codes;
        private Integer size;
        
        private SupportEmailRow(String feature) {
            this.feature = feature;
            this.codes = new List<String>();
            this.size = 0;
        }
        
        private String getFeature() {
            return this.feature;
        }
        
        private List<String> getCodes() {
            return this.codes;
        }
        
        private Integer getSize() {
            return this.size;
        }
        
        private void addCode(String code) {
            Set<String> codesSet = new Set<String>(getCodes());
            
            if(codesSet.add(code)) {
                getCodes().add(code);
            }
        }
        
        private void increaseSize(Integer size) {
            this.size+=size;
        }
        
        private String asHtmlRow() {
            return '<tr>' + String.join(new List<String>{
                '<td style="[[text-cell-style]]">' + (String.isNotBlank(getFeature()) ? getFeature() : 'N/A') + '</td>',
                '<td style="[[text-cell-style]]">' + String.join(getCodes(), '<br/>') + '</td>',
                '<td style="[[cell-style]]">' + getSize() + '</td>'
            }, '') + '</tr>';
        }
    }
    
    public virtual class DebugAction implements GNE_SFA2_S2S_Interface.DebugActionInterface {
        protected transient String name;
        protected transient DateTime startTime;
        
        public DebugAction(String name) {
            this.name = name;
        }
        
        public virtual String getName() {
            return this.name;
        }
        
        public virtual DateTime getStartTime() {
            return this.startTime;
        }
        
        public virtual GNE_SFA2_S2S_Interface.DebugActionInterface start() {
            return start(null);
        }
        
        public virtual GNE_SFA2_S2S_Interface.DebugActionInterface start(String additionalMessage) {
            DateTime now = System.now();
            this.startTime = now;
            GNE_SFA2_S2S_Util.addDebugMessage('START ' + getName() + ', Time = ' + now.formatGmt('yyyy-MM-dd HH:mm:ss.SSS') + (String.isNotBlank(additionalMessage) ? ', ' + additionalMessage : ''));
            return this;
        }
        
        public virtual GNE_SFA2_S2S_Interface.DebugActionInterface end() {
            return end(null);
        }

        public virtual GNE_SFA2_S2S_Interface.DebugActionInterface end(String additionalMessage) {
            DateTime now = System.now();
            Long diff = this.getStartTime()!=null ? now.getTime() - this.getStartTime().getTime() : null;
            GNE_SFA2_S2S_Util.addDebugMessage('END ' + getName() + ', Time = ' + now.formatGmt('yyyy-MM-dd HH:mm:ss.SSS') + ', Duration: ' + (diff!=null ? String.valueOf(diff) : 'N/A') + (String.isNotBlank(additionalMessage) ? ', ' + additionalMessage : ''));
            return this;
        }
    }
    
    public class HttpException extends Exception implements GNE_SFA2_S2S_Interface.S2SExceptionInterface {
        private String statusCode;
        
        public String getStatusCode() {
            return this.statusCode;
        }
        
        public HttpException(String statusCode, String status) {
            this(status);
            this.statusCode = statusCode;
        }
    }
    
    public class S2SException extends Exception implements GNE_SFA2_S2S_Interface.S2SExceptionInterface {
        private String statusCode;
        
        public String getStatusCode() {
            return this.statusCode;
        }
        
        public S2SException(String statusCode, String message) {
            this(message);
            this.statusCode = statusCode;
        }
    }
}