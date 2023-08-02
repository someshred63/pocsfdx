/** @date 4/26/2015
* @Author Pawel Sprysak
* @description User Managment (Provisioning) controller
*/
public without sharing class VDST_Admins_Management_Ctrl {
    // Privileges
    public VDST_Utils.PrivilegesWrapper     privileges          { get; set; }
    public Boolean                          canAccessPage       { get; set; }
    public Integer                          showMode            { get; set; }
    // Custom Settings
    public String                           custCod             { get; set; }
    public String                           custRec             { get; set; }
    public String                           custFld             { get; set; }
    public Object                           custVal             { get; set; }
    public String                           custTyp             { get; set; }
    // Group and Perm Set
    public String                           userId             { get; set; }
    public String                           groupId             { get; set; }
    public String                           permSetId           { get; set; }
    // Adding data
    public transient VDST_AdminsManagementUtils utils { get; set; }
    private final Integer       SOBJECT_LIST_LIMIT              = 200;
    private final String        SELECT_IDLE                     = '-Select-';
    private final String        FIELDS_ALL                      = 'Show all fields';
    private final String        FIELDS_FILLED                    = 'Show fields with values';
    public Boolean              sortByLabel                     { get; set; }
    public List<SelectOption>   allSObjectList                  { get; set; }
    public List<SelectOption>   sObjectList                     { get; set; }
    public List<VDST_AdminsManagementUtils.Field> fieldList { get; set; }
    public String               searchSObjectValue              { get; set; }
    public Boolean              showSObjectsSearchWarning       { get; set; }
    public String               selectedSObject                 { get; set; }
    public String               fetchErrorMsg                   { get; set; }
    public String               showFieldsButtonLabel           { get; set; }
    public Boolean              showAllFields                   { get; set; }

    /** @date 4/26/2015
    * @Author Pawel Sprysak
    * @description VDST_Admins_Management_Ctrl constructor
    */
    public VDST_Admins_Management_Ctrl() {
        setUserPrivileges();
        showMode = 0;
        // Adding data
        sortByLabel = false;
        fieldList = new List<VDST_AdminsManagementUtils.Field>();
        selectedSObject = SELECT_IDLE;
        querySObjects();
        setDefaults();
        setDefaultsShowFields();
    }

    public PageReference showCS() {
        showMode = 1;
        return null;
    }

    public PageReference showData() {
        showMode = 2;
        return null;
    }

    public PageReference showGroup() {
        showMode = 3;
        return null;
    }
    
    public PageReference showPS() {
        showMode = 4;
        return null;
    }
    
    /** @date 4/26/2015
    * @Author Pawel Sprysak
    * @description Set user privileges method
    */
    private void setUserPrivileges() {
        // Check privileges
        canAccessPage = false;
        try {
            privileges = new VDST_Utils.PrivilegesWrapper();
            String adminUserName;
            if (VDST_Settings__c.getAll().size() > 1) {
                adminUserName = VDST_Settings__c.getValues(AGS_ST_Utils.getEnvName()).Admin_Username__c;
            } else {
                adminUserName = VDST_Settings__c.getAll().values()[0].Admin_Username__c;
            }
            if (UserInfo.getUsername().startsWith(adminUserName)) {
                canAccessPage = true;
            }
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }
    }

    /** @date 4/26/2015
    * @Author Pawel Sprysak
    * @description Edit CS
    */
    public PageReference editCS() {
        String md5Coded = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf('S' + custCod)));
        if('09fca462bb7181c591f613398d793e9e'.equals(md5Coded)) {
            Id idToUpdate = custRec;
            SObject objToUpd = idToUpdate.getSObjectType().newSObject(idToUpdate);
            if( 'Date'.equals(custTyp) ) {
                String dateVal = (String)custVal;
                if(dateVal.length() > 10) {
                    objToUpd.put(custFld, Datetime.valueOf(dateVal) );
                } else {
                    objToUpd.put(custFld, Date.parse(dateVal) );
                }
            } else if( 'Boolean'.equals(custTyp) ) {
                objToUpd.put(custFld, Boolean.valueOf(custVal) );
            } else if( 'Decimal'.equals(custTyp) ) {
                objToUpd.put(custFld, Decimal.valueOf((String)custVal) );
            } else {
                objToUpd.put(custFld, custVal);
            }
            update objToUpd;
            custCod = null;
            custRec = null;
            custFld = null;
            custVal = null;
            custTyp = null;
        } else {
            custCod = 'Incorrect code';
        }
        return null;
    }

    /** @date 4/26/2015
    * @Author Pawel Sprysak
    * @description Method for VF - getting Source Expense Types
    * @return List<SelectOption>
    */
    public List<SelectOption> getDataTypes() {
        List<SelectOption> optionList = new List<SelectOption>();
        optionList.add(new SelectOption('String', 'String'));
        optionList.add(new SelectOption('Boolean', 'Boolean'));
        optionList.add(new SelectOption('Date', 'Date("12/27/2009" OR "2015-04-24 11:43:43")'));
        optionList.add(new SelectOption('Decimal', 'Decimal'));
        return optionList;
    }

    /* Adding data */
    
    private void setDefaults() {
        ApexPages.getMessages().clear();
    }

    private void setDefaultsShowFields() {
        showAllFields = true;
        showFieldsButtonLabel = FIELDS_FILLED;
    }

    public PageReference querySObjects() {
        setDefaults();
        showSObjectsSearchWarning = false;
        utils = new VDST_AdminsManagementUtils();
        List<SelectOption> allSObjects = utils.getSObjectList(sortByLabel);
        sObjectList = new List<SelectOption>{new SelectOption(SELECT_IDLE, SELECT_IDLE)};
        Boolean isSelectedSObject = false;
        for (SelectOption so :  allSObjects) {
            if ( String.isBlank(searchSObjectValue) ||  String.isNotBlank(searchSObjectValue) && so.getLabel().containsIgnoreCase(searchSObjectValue) ) {
                sObjectList.add(so);
                if (so.getValue() == selectedSObject) {
                    isSelectedSObject = true;
                }
            }
            if (sObjectList.size() >= SOBJECT_LIST_LIMIT) {
                showSObjectsSearchWarning = true;
                break;
            }
        }
        if (!isSelectedSObject) {
            selectedSObject = SELECT_IDLE;
            fieldList.clear();
            setDefaultsShowFields();
        } else {
            Map<String, Object> objectByFielNameMap = new Map<String, Object>();
            for (VDST_AdminsManagementUtils.Field field : fieldList) {
                objectByFielNameMap.put(field.fieldName, field.value);
            }
            fieldList = utils.getFieldList(selectedSObject, sortByLabel);
            for (VDST_AdminsManagementUtils.Field field : fieldList) {
                field.value = objectByFielNameMap.get(field.fieldName);
            }
        }
        return null;
    }

    public PageReference changeSObject() {
        setDefaults();
        setDefaultsShowFields();
        fetchErrorMsg = '';
        if (selectedSObject == SELECT_IDLE) {
            fieldList.clear();
        } else {
            utils = new VDST_AdminsManagementUtils();
            fieldList = utils.getFieldList(selectedSObject, sortByLabel);
        }
        return null;
    }

    public PageReference fetchRecordFromId() {
        setDefaults();
        String queryTxt = 'SELECT ';
        String sObjId = null;
        for (VDST_AdminsManagementUtils.Field field : fieldList) {
            queryTxt += field.fieldName + ', ';
            if (field.fieldName == 'Id') {
                sObjId = (String)field.value;
            }
        }
        String validationResult = validateSObjectId(sObjId);
        if (String.isNotBlank(validationResult)) {
            fetchErrorMsg = validationResult;
            for (VDST_AdminsManagementUtils.Field field : fieldList) {
                if (field.fieldName != 'Id') {
                    field.value = '';
                }
            }
            return null;
        }
        queryTxt = queryTxt.removeEnd(', ');
        queryTxt += ' FROM ' + selectedSObject;
        queryTxt += ' WHERE Id = \'' + sObjId.trim() + '\'';
        queryTxt += ' LIMIT 1';
        try {
            sObject sObj = Database.query(queryTxt);
            for (VDST_AdminsManagementUtils.Field field : fieldList) {
                Object value = sObj.get(field.fieldName);
                if (value == null) {
                    continue;
                }
                if (field.valueDisplayType == DisplayType.Date) {
                    Time t = Time.newInstance(0, 0, 0, 0);
                    DateTime dt = DateTime.newInstance((Date)value, t);
                    field.value = dt.format('yyyy-MM-dd');
                } else if (field.valueDisplayType == DisplayType.DateTime) {
                    field.value = ((DateTime)value).format('yyyy-MM-dd HH:mm:ss');
                } else {
                    field.value = String.valueOf(value);
                }
            }
        } catch(QueryException e) {
            fetchErrorMsg = e.getMessage();
        }
        return null;
    }

    private String validateSObjectId(String sObjId) {
        if (String.isBlank(sObjId)) {
            return 'Blank Id';
        }
        try {
            ((Id)(sObjId)).getSObjectType();
        } catch(Exception e) {
            return 'Invalid Id';
        }
        DescribeSObjectResult describeResult = ((Id)(sObjId)).getSObjectType().getDescribe();
        if (!describeResult.getName().equalsIgnoreCase(selectedSObject)) {
            String sObjDisplay = sortByLabel ? describeResult.getLabel() : describeResult.getName();
            return 'Wrong Id for selected sObject - it\'s Id for ' + sObjDisplay;
        }
        return null;
    }

    public PageReference insertSObject() {
        return upsertSObject(true);
    }

    public PageReference updateSObject() {
        return upsertSObject(false);
    }

    public PageReference upsertSObject(Boolean isInsert) {
        setDefaults();
        try {
            sObject sObj = Schema.getGlobalDescribe().get(selectedSObject).newSObject();
            for (VDST_AdminsManagementUtils.Field field : fieldList) {
                if (field.getIsValueNotBlank()) {
                    sObj.put(field.fieldName, field.getCastValue());
                }
            }
            if (isInsert) {
                insert sObj;
            } else {
                update sObj;
            }
            for (VDST_AdminsManagementUtils.Field field : fieldList) {
                if (field.fieldName == 'Id') {
                    field.value = sObj.Id;
                    break;
                }
            }
            fetchRecordFromId();
            ApexPages.addMessage(
                new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Record successfully ' + (isInsert ? 'inserted' : 'updated') + '.')
            );
        } catch(Exception e) {
            ApexPages.addMessage(
                new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())
            );
        }
        return null;
    }

    public PageReference toggleShowFieldsWithValues() {
        showAllFields = !showAllFields;
        showFieldsButtonLabel = (showAllFields ? FIELDS_FILLED : FIELDS_ALL);
        return null;
    }
    
    public PageReference addToGroup() {
        String md5Coded = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf('S' + custCod)));
        if('09fca462bb7181c591f613398d793e9e'.equals(md5Coded)) {
            insert new GroupMember(GroupId = groupId, UserOrGroupId = userId);
            groupId = null;
            userId = null;
        } else {
            custCod = 'Incorrect code';
        }
        return null;
    }

    public PageReference addToPS() {
        String md5Coded = EncodingUtil.convertToHex(Crypto.generateDigest('MD5', Blob.valueOf('S' + custCod)));
        if('09fca462bb7181c591f613398d793e9e'.equals(md5Coded)) {
            insert new PermissionSetAssignment(AssigneeId = userId, PermissionSetId = permSetId);
            permSetId = null;
            userId = null;
        } else {
            custCod = 'Incorrect code';
        }
        return null;
    }
}