global without sharing class GNE_DCR_Ctrl extends GNE_SFA2_Base_Ctrl implements GNE_SFA2_S2S_Interface.RestServiceCallInterface {
    private static final String ATTRIBUTE_SOURCE = 'source';
    private static GNE_DCR_Util.DCRWrapper externalRecord;
    private static Map<String, String> recordTypeDeveloperNamesMap;

    public GNE_DCR_Ctrl(ApexPages.StandardController sctrl) {
        this();
    }

    public GNE_DCR_Ctrl() {
        super();
    }

    global class DataWrapper extends GNE_SFA2_Base_Ctrl.DataWrapper {
        private GNE_DCR_Util.DCRWrapper dcrWrapper;
    }

    public virtual System.Type getSelfClass() {
        return GNE_DCR_Portal_Ctrl.class;
    }

    public Map<String, String> getRecordTypeDeveloperNamesMap() {
        if(recordTypeDeveloperNamesMap != null) {
            return recordTypeDeveloperNamesMap;
        } else {

            recordTypeDeveloperNamesMap = new Map<String, String>();
            for(RecordType r : [SELECT Name, DeveloperName FROM RecordType WHERE SobjectType = 'Change_Request_gne__c']) {
                recordTypeDeveloperNamesMap.put(r.Name, r.DeveloperName);
            }

            return recordTypeDeveloperNamesMap;
        }
    }
    
    protected override GNE_SFA2_Base_Ctrl.DataWrapper intInit(Map<String, String> params) {
        this.params = params.clone();

        if(params.containsKey(ATTRIBUTE_SOURCE)) {
            String source = params.get('source');
            Map<String, String> tempParams = new Map<String, String>();
            if(source == 'MA') {
                tempParams.put('dcrId', params.get('extId'));
                tempParams.put('object', 'DCR');
                tempParams.put('method', 'getDCRDetails');
                externalRecord = getDCRFromExternalSource(GNE_DCR_Util.MA_SYSTEM_NAME, GNE_DCR_Util.MA_FEATURE_DCR_GET_DETAIL, tempParams);
            } else if(source == 'PACT') {
                tempParams.put('localId', params.get('extId'));
                externalRecord = getDCRFromExternalSource(GNE_DCR_Util.PACT_SYSTEM_NAME, GNE_DCR_Util.PACT_FEATURE_DCR_GET_DETAIL, tempParams);
            }
        }
        
        this.params.put('sObjectType', 'Change_Request_gne__c');
        this.pageExtId = 'dcr';
        return super.intInit(this.params);
    }
    
    protected override Boolean pageDispatcher() {
        return uiType=='standard';
    }
    
    protected override virtual GNE_SFA2_Base_Ctrl.DataWrapper getDataWrapperInstance() {
        return new DataWrapper();
    }
    
    protected override GNE_SFA2_Base_Ctrl.DataWrapper getDataWrapper(GNE_SFA2_Base_Ctrl.DataWrapper dataWrapper) {
        sObjectType = 'Change_Request_gne__c';
        DataWrapper result = (DataWrapper)dataWrapper;
        result = (DataWrapper)super.getDataWrapper(result);
        result.dcrWrapper = externalRecord;
        return result;
    }
    
    protected override Set<String> getQueryFields(List<SFA2_Configuration_Object_gne__c> configObjects) {
        return new Set<String>{
            'Name',
            'Status_gne__c',
            'Account_gne__r.Name',
            'Approval_State__c',
            'RecordType.Name',
            'Reason_dcr_gne__c',
            'Assigned_Analyst_gne__c',
            'AMS_ID_gne__c',
            'New_Organization_Name_gne__c',
            'Account_Type_DCR_gne__c',
            'Specialties_HCO_DCR_gne__c',
            'Verify_HCO_Specialties_gne__c',
            'First_Name_DCR_gne__c',
            'New_Value_2_gne__c',
            'Last_Name_DCR_gne__c',
            'Suffix_DCR_gne__c',
            'Professional_Type_DCR_gne__c',
            'Verify_HCP_credentials_gne__c',
            'Credentials_DCR_gne__c',
            'Verify_HCP_Specialties_gne__c',
            'Specialties_HCP_DCR_gne__c',
            'New_Vendor_Note_gne__c',
            'Vendor_Notes_gne__c',
            'Data_Vendor_Changes_gne__c',
            'CreatedBy.Name',
            'LastModifiedBy.Name',
            'CreatedDate',
            'LastModifiedDate',
            'Address_Line_1_gne__c',
            'City_gne__c',
            'Address_Line_2_gne__c',
            'State_gne__c',
            'Address_Line_3_gne__c',
            'Zip_gne__c',
            'Address_Line_4_gne__c',
            'Current_Address_gne__c',
            'Account_gne__r.Name',
            'Duplicate_Account_2_gne__r.Name',
            'Duplicate_Account_3_gne__r.Name',
            'Duplicate_Account_4_gne__r.Name',
            'Duplicate_Account_5_gne__r.Name',
            'AMS_ID_1_gne__c',
            'AMS_ID_2_gne__c',
            'AMS_ID_3_gne__c',
            'AMS_ID_4_gne__c',
            'AMS_ID_5_gne__c',
            'Current_Address_gne__r.Name',
            'Duplicate_Address_2_gne__r.Name',
            'Duplicate_Address_3_gne__r.Name',
            'Current_Address_gne__c',
            'Duplicate_Address_2_gne__c',
            'Duplicate_Address_3_gne__c'
        };
    }

    protected override String getMode() {
        if(this.mode==null) {
            this.mode = (String.isNotBlank(this.params.get('id')) || String.isNotBlank(this.params.get('extId'))) ? (String.isNotBlank(this.params.get('sfdc.override')) ? VIEW_MODE : EDIT_MODE) : NEW_MODE;
        }
        
        return this.mode;
    }

    protected override GNE_SFA2_Base_Ctrl.RecordDescribe getRecordDescribe() {
        sObjectDescribe = getSObjectDescribe();
        if(!params.containsKey(ATTRIBUTE_SOURCE)) {
            return new RecordDescribe(recordId, (String)record.get('Name'), sObjectType, sObjectDescribe.getLabel(), recordType, getRecordAccess(getCurrentUser().id));
        } else {
            return new RecordDescribe(params.get('extId'), externalRecord.name, sObjectType, sObjectDescribe.getLabel(), recordType, getRecordAccess(getCurrentUser().id));
        }
    }

    protected override GNE_SFA2_Base_Ctrl.DataWrapper initEditMode() {
        if(!params.containsKey(ATTRIBUTE_SOURCE)) {
            this.recordId = checkInputParam('id');
            this.sObjectType = String.valueOf(recordId.getSObjectType());
        } else {
            this.sObjectType = 'Change_Request_gne__c';
        }
        
        this.recordType = getRecordType(false);
        return getDataWrapper(dataWrapper);
    }

    protected override GNE_SFA2_Base_Ctrl.DataWrapper initViewMode() {
        if(!params.containsKey(ATTRIBUTE_SOURCE)) {
            this.recordId = checkInputParam('id');
            this.sObjectType = String.valueOf(recordId.getSObjectType());
        } else {
            this.sObjectType = 'Change_Request_gne__c';
        }

        this.recordType = getRecordType(false);
        return getDataWrapper(dataWrapper);
    }

    protected override RecordType getRecordType(Boolean isNewMode) {
        RecordType result = null;
        Boolean hasRecordType = getSObjectFieldsDescribe().containsKey('recordtypeid');

        if(!params.containsKey(ATTRIBUTE_SOURCE)) {
            if (hasRecordType) {
                if (isNewMode) {
                    String rtDeveloperName = null;

                    for (SFA2_Configuration_Object_gne__c conf : [
                                SELECT Record_Type_gne__c
                                FROM SFA2_Configuration_Object_gne__c
                                WHERE Is_Default_Record_Type_gne__c = true AND Object_Name_gne__c = :sObjectType
                                        AND Role_gne__c = :appContext.role AND Brand_gne__c = :appContext.brand AND Application_Type__c = :appContext.appName
                                                          AND Is_Active_gne__c = true AND Configuration_Type_gne__c = 'Page'
                                                                  LIMIT 1]) {
                        rtDeveloperName = conf.Record_Type_gne__c;
                    }

                    if (String.isNotBlank(rtDeveloperName)) {
                        for (RecordType rt : [SELECT Id, Name, DeveloperName FROM RecordType WHERE sOBjectType = : sObjectType AND DeveloperName = : rtDeveloperName LIMIT 1]) {
                            result = rt;
                        }
                    }
                } else {
                    for (SObject rec : Database.query('SELECT RecordType.Id, RecordType.Name, RecordType.DeveloperName FROM ' + sObjectType + ' WHERE Id =: recordId LIMIT 1')) {
                        result = (RecordType)rec.getSObject('RecordType');
                    }
                }
            }
        } else {
            String rtDeveloperName = getRecordTypeDeveloperNamesMap().containsKey(externalRecord.recordType) ? getRecordTypeDeveloperNamesMap().get(externalRecord.recordType) : null;
            for (SObject rec : Database.query('SELECT RecordType.Id, RecordType.Name, RecordType.DeveloperName FROM ' + sObjectType + ' WHERE RecordType.DeveloperName =: rtDeveloperName LIMIT 1')) {
                result = (RecordType)rec.getSObject('RecordType');
            }
        }

        return result;
    }

    protected override GNE_SFA2_Base_Ctrl.RecordAccess getRecordAccess(String userId) {
        if(params.containsKey(ATTRIBUTE_SOURCE)) {
            return new RecordAccess(true, true, true);
        } else {
            RecordAccess result = null;

            if (String.isNotBlank(recordId)) {
                for (UserRecordAccess urAccess : [SELECT RecordId, HasReadAccess, HasEditAccess, HasDeleteAccess FROM UserRecordAccess WHERE UserId = :userId AND RecordId = :recordId LIMIT 1]) {
                    result = new RecordAccess(urAccess.HasReadAccess, urAccess.HasEditAccess, urAccess.HasDeleteAccess);
                }

                if (result == null) {
                    result = new RecordAccess(false, false, false);
                }
            } else {
                sObjectDescribe = getSObjectDescribe();
                result = new RecordAccess(sObjectDescribe.isAccessible(), sObjectDescribe.isCreateable(), sObjectDescribe.isDeletable());
            }

            checkRecordAccess(result);
            return result;
        }
    }
    
    protected override GNE_SFA2_Base_Ctrl.Config getConfiguration(String recordTypeDeveloperName) {
        record = getRecord(null);
        DataWrapper resultData = (DataWrapper)dataWrapper;
        fieldsMap = new Map<String,GNE_SFA2_Base_Ctrl.Field> {
            'status' => new GNE_SFA2_Base_Ctrl.Field('Status', null, false, false),
            'accountName' => new GNE_SFA2_Base_Ctrl.Field('Account Name', null, true, false),
            'approvalState' => new GNE_SFA2_Base_Ctrl.Field('Approval State', null, false, false),
            'accountId' => new GNE_SFA2_Base_Ctrl.Field('SFDC Account Id', null, true, false),
            'requestType' => new GNE_SFA2_Base_Ctrl.Field('Request Type (Record Type)', null, true, false),
            'requestAnalyst' => new GNE_SFA2_Base_Ctrl.Field('Request Analyst', null, true, false),
            'reasonForDCR' => new GNE_SFA2_Base_Ctrl.Field('Reason for DCR', null, true, false),
            'amsId' => new GNE_SFA2_Base_Ctrl.Field('AMS Id', null, true, false),
            
            'orgName' => new GNE_SFA2_Base_Ctrl.Field('Organization Name', null, true, false),
            'orgType' => new GNE_SFA2_Base_Ctrl.Field('Organization Type', null, true, false),
            'orgSpecialties' => new GNE_SFA2_Base_Ctrl.Field('Specialties', null, true, false),
            'orgValidateSpecialties' => new GNE_SFA2_Base_Ctrl.Field('Validate Specialties', null, true, false),
            
            'hcpFirstName' => new GNE_SFA2_Base_Ctrl.Field('First Name', null, true, false),
            'hcpMiddleName' => new GNE_SFA2_Base_Ctrl.Field('Middle Name', null, true, false),
            'hcpLastName' => new GNE_SFA2_Base_Ctrl.Field('Last Name', null, true, false),
            'hcpSuffix' => new GNE_SFA2_Base_Ctrl.Field('Suffix', null, true, false),
            'hcpProfessionalType' => new GNE_SFA2_Base_Ctrl.Field('Professional Type', null, true, false),
            'hcpValidateCredentials' => new GNE_SFA2_Base_Ctrl.Field('Validate Credentials', null, true, false),
            'hcpCredentials' => new GNE_SFA2_Base_Ctrl.Field('Credentials', null, true, false),
            'hcpValidateSpecialties' => new GNE_SFA2_Base_Ctrl.Field('Validate Specialties', null, true, false),
            'hcpSpecialties' => new GNE_SFA2_Base_Ctrl.Field('Specialties', null, true, false),
            
            'newVendorNote' => new GNE_SFA2_Base_Ctrl.Field('New Vendor Note', null, false, false),
            'vendorNotes' => new GNE_SFA2_Base_Ctrl.Field('Vendor Notes', null, true, false),
            'descriptionOfExceptions' => new GNE_SFA2_Base_Ctrl.Field('Description of Exceptions', null, false, false),
            'createdBy' => new GNE_SFA2_Base_Ctrl.Field('Created By', null, true, false),
            'lastModifiedBy' => new GNE_SFA2_Base_Ctrl.Field('Last Modified By', null, true, false),
            'createdDate' => new GNE_SFA2_Base_Ctrl.Field('Created Date', null, true, false),
            'lastModifiedDate' => new GNE_SFA2_Base_Ctrl.Field('Last Modified Date', null, true, false),

            'streetName' => new GNE_SFA2_Base_Ctrl.Field('Street Name', null, true, false),
            'city' => new GNE_SFA2_Base_Ctrl.Field('City', null, true, false),
            'suiteFloor' => new GNE_SFA2_Base_Ctrl.Field('Suite / Floor', null, true, false),
            'state' => new GNE_SFA2_Base_Ctrl.Field('State', null, true, false),
            'departmentName' => new GNE_SFA2_Base_Ctrl.Field('Department Name', null, true, false),
            'zip' => new GNE_SFA2_Base_Ctrl.Field('Zip', null, true, false),
            'attnCareOf' => new GNE_SFA2_Base_Ctrl.Field('Attn/Care of', null, true, false),
            'addressId' => new GNE_SFA2_Base_Ctrl.Field('SFDC Address Id', null, true, false),
            
            'acct1' => new GNE_SFA2_Base_Ctrl.Field('Account-1', null, true, false),
            'acct2' => new GNE_SFA2_Base_Ctrl.Field('Account-2', null, true, false),
            'acct3' => new GNE_SFA2_Base_Ctrl.Field('Account-3', null, true, false),
            'acct4' => new GNE_SFA2_Base_Ctrl.Field('Account-4', null, true, false),
            'acct5' => new GNE_SFA2_Base_Ctrl.Field('Account-5', null, true, false),
            'amsId1' => new GNE_SFA2_Base_Ctrl.Field('AMS Id', null, true, false),
            'amsId2' => new GNE_SFA2_Base_Ctrl.Field('AMS Id', null, true, false),
            'amsId3' => new GNE_SFA2_Base_Ctrl.Field('AMS Id', null, true, false),
            'amsId4' => new GNE_SFA2_Base_Ctrl.Field('AMS Id', null, true, false),
            'amsId5' => new GNE_SFA2_Base_Ctrl.Field('AMS Id', null, true, false),

            'addr1' => new GNE_SFA2_Base_Ctrl.Field('Address-1', null, true, false),
            'addr2' => new GNE_SFA2_Base_Ctrl.Field('Address-2', null, true, false),
            'addr3' => new GNE_SFA2_Base_Ctrl.Field('Address-3', null, true, false),
            'sfdcId1' => new GNE_SFA2_Base_Ctrl.Field('SFCD Id', null, true, false),
            'sfdcId2' => new GNE_SFA2_Base_Ctrl.Field('SFCD Id', null, true, false),
            'sfdcId3' => new GNE_SFA2_Base_Ctrl.Field('SFCD Id', null, true, false),

            'blankSpace' => new GNE_SFA2_Base_Ctrl.Field(null, null, true, false),
            'blankSpaceOnlyEditMode' => new GNE_SFA2_Base_Ctrl.Field(null, null, true, false)
        };
        
        for(String fieldKey : fieldsMap.keySet()) {
            GNE_SFA2_Base_Ctrl.Field fld = fieldsMap.get(fieldKey);
            setFieldProperties(fieldKey, fld);
        }
        
        Integer sectionOrder = 0;
        List<GNE_SFA2_Base_Ctrl.Section> sections = new List<GNE_SFA2_Base_Ctrl.Section>();

        List<GNE_SFA2_Base_Ctrl.Field> fields = new List<GNE_SFA2_Base_Ctrl.Field>();
        fields.add(fieldsMap.get('status'));
        fields.add(fieldsMap.get('accountName'));
        fields.add(fieldsMap.get('approvalState'));
        fields.add(fieldsMap.get('accountId'));
        fields.add(fieldsMap.get('requestType'));
        fields.add(fieldsMap.get('requestAnalyst'));
        if(recordTypeDeveloperName.contains('Remove_Inactivate') || recordTypeDeveloperName.contains('Reactivate')) {
            fields.add(fieldsMap.get('reasonForDCR'));
            fields.add(fieldsMap.get('blankSpace'));
        }
        fields.add(fieldsMap.get('amsId'));

        sections.add(new GNE_SFA2_Base_Ctrl.Section('information', 'Information', sectionOrder++, null, fields));

        if(recordTypeDeveloperName == 'HCO_Change_Organization_Info') {
            sections.add(new GNE_SFA2_Base_Ctrl.Section('organizationChangeInfo', 'Organization Change Info', sectionOrder++, null, new List<GNE_SFA2_Base_Ctrl.Field>{
                    fieldsMap.get('orgName'),
                    fieldsMap.get('blankSpace'),
                    fieldsMap.get('orgType'),
                    fieldsMap.get('blankSpace'),
                    fieldsMap.get('orgSpecialties'),
                    fieldsMap.get('blankSpace'),
                    fieldsMap.get('orgValidateSpecialties'),
                    fieldsMap.get('blankSpace')
                })
            );
        }

        if(recordTypeDeveloperName == 'HCP_Change_HCP_Info') {
            sections.add(new GNE_SFA2_Base_Ctrl.Section('healthcareProfessionalChangeInfo', 'Healthcare Professional Change Info', sectionOrder++, null, new List<GNE_SFA2_Base_Ctrl.Field>{
                    fieldsMap.get('hcpFirstName'),
                    fieldsMap.get('hcpMiddleName'),
                    fieldsMap.get('hcpLastName'),
                    fieldsMap.get('hcpSuffix'),
                    fieldsMap.get('hcpProfessionalType'),
                    fieldsMap.get('blankSpace'),
                    fieldsMap.get('hcpValidateCredentials'),
                    fieldsMap.get('hcpCredentials'),
                    fieldsMap.get('hcpValidateSpecialties'),
                    fieldsMap.get('hcpSpecialties')
                })
            );
        }

        if(recordTypeDeveloperName == 'HCO_Change_Address' 
            || recordTypeDeveloperName == 'HCO_Remove_Inactivate_Address' 
            || recordTypeDeveloperName == 'HCP_Existing_Address_Typo_Missing_Info'
            || recordTypeDeveloperName == 'HCP_Remove_Inactivate_Address'
            || recordTypeDeveloperName == 'Duplicate_Address'
            || recordTypeDeveloperName == 'HCP_Reactivate_Address') {
            sections.add(new GNE_SFA2_Base_Ctrl.Section('addressInfo', 'Address Info', sectionOrder++, null, new List<GNE_SFA2_Base_Ctrl.Field>{
                    fieldsMap.get('streetName'),
                    fieldsMap.get('city'),
                    fieldsMap.get('suiteFloor'),
                    fieldsMap.get('state'),
                    fieldsMap.get('departmentName'),
                    fieldsMap.get('zip'),
                    fieldsMap.get('attnCareOf'),
                    fieldsMap.get('blankSpace'),
                    fieldsMap.get('addressId')
                }) 
            );
        }

        if(recordTypeDeveloperName == 'HCO_Remove_Duplicate_Organization'
            || recordTypeDeveloperName == 'HCP_Remove_Duplicate') {
            sections.add(new GNE_SFA2_Base_Ctrl.Section('removeDuplicateAccounts', 'Remove Duplicate Accounts', sectionOrder++, null, new List<GNE_SFA2_Base_Ctrl.Field>{
                    fieldsMap.get('acct1'),
                    fieldsMap.get('amsId1'),
                    fieldsMap.get('acct2'),
                    fieldsMap.get('amsId2'),
                    fieldsMap.get('acct3'),
                    fieldsMap.get('amsId3'),
                    fieldsMap.get('acct4'),
                    fieldsMap.get('amsId4'),
                    fieldsMap.get('acct5'),
                    fieldsMap.get('amsId5')
                })
            );
        }

        if(recordTypeDeveloperName == 'Duplicate_Address') {
            sections.add(new GNE_SFA2_Base_Ctrl.Section('removeDuplicateAddress', 'Remove Duplicate Address', sectionOrder++, null, new List<GNE_SFA2_Base_Ctrl.Field>{
                    fieldsMap.get('addr1'),
                    fieldsMap.get('sfdcId1'),
                    fieldsMap.get('addr2'),
                    fieldsMap.get('sfdcId2'),
                    fieldsMap.get('addr3'),
                    fieldsMap.get('sfdcId3')
                })
            );
        }

            
        sections.add(new GNE_SFA2_Base_Ctrl.Section('dataVendorArea', 'Data Vendor Area', sectionOrder++, null, new List<GNE_SFA2_Base_Ctrl.Field>{
                fieldsMap.get('newVendorNote'),
                fieldsMap.get('blankSpaceOnlyEditMode'),
                fieldsMap.get('vendorNotes'),
                fieldsMap.get('blankSpace'),
                fieldsMap.get('descriptionOfExceptions'),
                fieldsMap.get('blankSpaceOnlyEditMode'),
                fieldsMap.get('blankSpace'),
                fieldsMap.get('blankSpace'),
                fieldsMap.get('createdBy'),
                fieldsMap.get('lastModifiedBy'),
                fieldsMap.get('createdDate'),
                fieldsMap.get('lastModifiedDate')
            })
        );

        return new GNE_SFA2_Base_Ctrl.Config(mode, new List<GNE_SFA2_Base_Ctrl.Button>(), sections, new List<GNE_SFA2_Base_Ctrl.RelatedList>());
    }
  
    private void setFieldProperties(String fieldKey, GNE_SFA2_Base_Ctrl.Field fld) {
        DataWrapper resultData = (DataWrapper)dataWrapper;
        Change_Request_gne__c dcr = (Change_Request_gne__c)record;
        GNE_SFA2_Base_Ctrl.FieldDescribe describe = new GNE_SFA2_Base_Ctrl.FieldDescribe();
        describe.name = fieldKey;

        if(!params.containsKey(ATTRIBUTE_SOURCE)) {

            if(fieldKey=='status') {
                fld.value = dcr.Status_gne__c;
                if(dcr.Status_gne__c != 'Ready for Data Vendor') {
                    describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Status_gne__c.getDescribe(), sObjectType);
                } else {
                    describe.name = 'Status_gne__c';
                    describe.type = 'picklist';
                    describe.picklistValues = new List<GNE_SFA2_Base_Ctrl.PicklistValue>();
                    describe.picklistValues.add(new GNE_SFA2_Base_Ctrl.PicklistValue('Ready for Data Vendor', 'Ready for Data Vendor'));
                    describe.picklistValues.add(new GNE_SFA2_Base_Ctrl.PicklistValue('Issue Identified by Vendor', 'Ready for Genentech')); 
                }      
            } else if(fieldKey=='accountName') {
                fld.value = dcr.Account_gne__r.Name;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Account_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='approvalState') {
                fld.value = dcr.Approval_State__c;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Approval_State__c.getDescribe(), sObjectType);
            } else if(fieldKey=='accountId') {
                fld.value = dcr.Account_gne__c;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Account_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='requestType') {
                fld.value = dcr.RecordType.Name;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.RecordType.Name.getDescribe(), sObjectType);
            } else if(fieldKey=='requestAnalyst') {
                fld.value = dcr.Assigned_Analyst_gne__c;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Assigned_Analyst_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='reasonForDCR') {
                fld.value = dcr.Reason_dcr_gne__c;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Reason_dcr_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='amsId') {
                fld.value = dcr.AMS_ID_gne__c;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.AMS_ID_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='orgName') {
                fld.value = dcr.New_Organization_Name_gne__c;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.New_Organization_Name_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='orgType') {
                fld.value = dcr.Account_Type_DCR_gne__c;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Account_Type_DCR_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='orgSpecialties') {
                fld.value = dcr.Specialties_HCO_DCR_gne__c;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Specialties_HCO_DCR_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='orgValidateSpecialties') {
                fld.value = String.valueOf(dcr.Verify_HCO_Specialties_gne__c);
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Verify_HCO_Specialties_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='hcpFirstName') {
                fld.value = dcr.First_Name_DCR_gne__c;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.First_Name_DCR_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='hcpMiddleName') {
                fld.value = dcr.New_Value_2_gne__c;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.New_Value_2_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='hcpLastName') {
                fld.value = dcr.Last_Name_DCR_gne__c;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Last_Name_DCR_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='hcpSuffix') {
                fld.value = dcr.Suffix_DCR_gne__c;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Suffix_DCR_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='hcpProfessionalType') {
                fld.value = dcr.Professional_Type_DCR_gne__c;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Professional_Type_DCR_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='hcpValidateCredentials') {
                fld.value = String.valueOf(dcr.Verify_HCP_credentials_gne__c);
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Verify_HCP_credentials_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='hcpCredentials') {
                fld.value = dcr.Credentials_DCR_gne__c;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Credentials_DCR_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='hcpValidateSpecialties') {
                fld.value = String.valueOf(dcr.Verify_HCP_Specialties_gne__c);
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Verify_HCP_Specialties_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='hcpSpecialties') {
                fld.value = dcr.Specialties_HCP_DCR_gne__c;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Specialties_HCP_DCR_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='newVendorNote') {
                fld.value = dcr.New_Vendor_Note_gne__c;
                fld.mode = new List<String>{'Edit'};
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.New_Vendor_Note_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='vendorNotes') {
                fld.value = dcr.Vendor_Notes_gne__c;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Vendor_Notes_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='descriptionOfExceptions') {
                fld.value = dcr.Data_Vendor_Changes_gne__c;
                fld.mode = new List<String>{'Edit'};
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Data_Vendor_Changes_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='createdBy') {
                fld.value = dcr.CreatedBy.Name;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.CreatedById.getDescribe(), sObjectType);
            } else if(fieldKey=='lastModifiedBy') {
                fld.value = dcr.LastModifiedBy.Name;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.LastModifiedById.getDescribe(), sObjectType);
            } else if(fieldKey=='createdDate') {
                fld.value = String.valueOf(dcr.CreatedDate);
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.CreatedDate.getDescribe(), sObjectType);
            } else if(fieldKey=='lastModifiedDate') {
                fld.value = String.valueOf(dcr.LastModifiedDate);
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.LastModifiedDate.getDescribe(), sObjectType);
            } else if(fieldKey=='streetName') {
                fld.value = dcr.Address_Line_1_gne__c;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Address_Line_1_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='city') {
                fld.value = dcr.City_gne__c;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.City_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='suiteFloor') {
                fld.value = dcr.Address_Line_2_gne__c;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Address_Line_2_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='state') {
                fld.value = dcr.State_gne__c;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.State_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='departmentName') {
                fld.value = dcr.Address_Line_3_gne__c;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Address_Line_3_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='zip') {
                fld.value = dcr.Zip_gne__c;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Zip_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='attnCareOf') {
                fld.value = dcr.Address_Line_4_gne__c;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Address_Line_4_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='addressId') {
                fld.value = dcr.Current_Address_gne__c;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Current_Address_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='acct1') {
                fld.value = dcr.Account_gne__r.Name;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Account.Name.getDescribe(), 'Account');
            } else if(fieldKey=='acct2') {
                fld.value = dcr.Duplicate_Account_2_gne__r.Name;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Account.Name.getDescribe(), 'Account');
            } else if(fieldKey=='acct3') {
                fld.value = dcr.Duplicate_Account_3_gne__r.Name;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Account.Name.getDescribe(), 'Account');
            } else if(fieldKey=='acct4') {
                fld.value = dcr.Duplicate_Account_4_gne__r.Name;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Account.Name.getDescribe(), 'Account');
            } else if(fieldKey=='acct5') {
                fld.value = dcr.Duplicate_Account_5_gne__r.Name;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Account.Name.getDescribe(), 'Account');
            } else if(fieldKey=='amsId1') {
                fld.value = dcr.AMS_ID_1_gne__c;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.AMS_ID_1_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='amsId2') {
                fld.value = dcr.AMS_ID_2_gne__c;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.AMS_ID_2_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='amsId3') {
                fld.value = dcr.AMS_ID_3_gne__c;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.AMS_ID_3_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='amsId4') {
                fld.value = dcr.AMS_ID_4_gne__c;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.AMS_ID_4_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='amsId5') {
                fld.value = dcr.AMS_ID_5_gne__c;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.AMS_ID_5_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='addr1') {
                fld.value = dcr.Current_Address_gne__r.Name;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Address_vod__c.Name.getDescribe(), 'Address_vod__c');
            } else if(fieldKey=='addr2') {
                fld.value = dcr.Duplicate_Address_2_gne__r.Name;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Address_vod__c.Name.getDescribe(), 'Address_vod__c');
            } else if(fieldKey=='addr3') {
                fld.value = dcr.Duplicate_Address_3_gne__r.Name;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Address_vod__c.Name.getDescribe(), 'Address_vod__c');
            } else if(fieldKey=='sfdcId1') {
                fld.value = dcr.Current_Address_gne__c;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Current_Address_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='sfdcId2') {
                fld.value = dcr.Duplicate_Address_2_gne__c;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Duplicate_Address_2_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='sfdcId3') {
                fld.value = dcr.Duplicate_Address_3_gne__c;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Duplicate_Address_3_gne__c.getDescribe(), sObjectType);
            }

        } else {

            if(fieldKey=='status') {
                fld.value = externalRecord.information.status;
                if(dcr.Status_gne__c == 'Ready for Data Vendor' || externalRecord.information.status == 'Ready for Data Vendor') {
                    describe.name = 'Status_gne__c';
                    describe.type = 'picklist';
                    describe.picklistValues = new List<GNE_SFA2_Base_Ctrl.PicklistValue>();
                    describe.picklistValues.add(new GNE_SFA2_Base_Ctrl.PicklistValue('Ready for Data Vendor', 'Ready for Data Vendor'));
                    describe.picklistValues.add(new GNE_SFA2_Base_Ctrl.PicklistValue('Issue Identified by Vendor', 'Ready for Genentech')); 
                } else {
                    describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Status_gne__c.getDescribe(), sObjectType);
                }      
            } else if(fieldKey=='accountName') {
                fld.value = externalRecord.information.accountName;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Account_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='approvalState') {
                fld.value = externalRecord.information.approvalState;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Approval_State__c.getDescribe(), sObjectType);
            } else if(fieldKey=='accountId') {
                fld.value = externalRecord.information.accountId;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Account_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='requestType') {
                fld.value = externalRecord.information.requestType;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.RecordType.Name.getDescribe(), sObjectType);
            } else if(fieldKey=='requestAnalyst') {
                fld.value = externalRecord.information.requestAnalyst;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Assigned_Analyst_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='reasonForDCR') {
                fld.value = externalRecord.information.reasonForDCR;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Reason_dcr_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='amsId') {
                fld.value = externalRecord.information.amsId;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.AMS_ID_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='orgName') {
                fld.value = externalRecord.orgChangeInfo != null ? externalRecord.orgChangeInfo.orgName : '';
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.New_Organization_Name_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='orgType') {
                fld.value = externalRecord.orgChangeInfo != null ? externalRecord.orgChangeInfo.orgType : '';
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Account_Type_DCR_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='orgSpecialties') {
                fld.value = externalRecord.orgChangeInfo != null ? externalRecord.orgChangeInfo.orgSpecialties : '';
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Specialties_HCO_DCR_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='orgValidateSpecialties') {
                fld.value = String.valueOf(externalRecord.orgChangeInfo != null ? externalRecord.orgChangeInfo.orgName : '');
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Verify_HCO_Specialties_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='hcpFirstName') {
                fld.value = externalRecord.profChangeInfo != null ? externalRecord.profChangeInfo.hcpFirstName : '';
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.First_Name_DCR_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='hcpMiddleName') {
                fld.value = externalRecord.profChangeInfo != null ? externalRecord.profChangeInfo.hcpMiddleName : '';
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.New_Value_2_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='hcpLastName') {
                fld.value = externalRecord.profChangeInfo != null ? externalRecord.profChangeInfo.hcpLastName : '';
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Last_Name_DCR_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='hcpSuffix') {
                fld.value = externalRecord.profChangeInfo != null ? externalRecord.profChangeInfo.hcpSuffix : '';
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Suffix_DCR_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='hcpProfessionalType') {
                fld.value = externalRecord.profChangeInfo != null ? externalRecord.profChangeInfo.hcpProfessionalType : '';
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Professional_Type_DCR_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='hcpValidateCredentials') {
                fld.value = String.valueOf(externalRecord.profChangeInfo != null ? externalRecord.profChangeInfo.hcpValidateCredentials : '');
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Verify_HCP_credentials_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='hcpCredentials') {
                fld.value = externalRecord.profChangeInfo != null ? externalRecord.profChangeInfo.hcpCredentials : '';
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Credentials_DCR_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='hcpValidateSpecialties') {
                fld.value = String.valueOf(externalRecord.profChangeInfo != null ? externalRecord.profChangeInfo.hcpValidateCredentials : '');
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Verify_HCP_Specialties_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='hcpSpecialties') {
                fld.value = externalRecord.profChangeInfo != null ? externalRecord.profChangeInfo.hcpSpecialties : '';
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Specialties_HCP_DCR_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='newVendorNote') {
                fld.value = externalRecord.dataVendorArea.newVendorNote;
                fld.mode = new List<String>{'Edit'};
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.New_Vendor_Note_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='vendorNotes') {
                fld.value = externalRecord.dataVendorArea.vendorNotes;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Vendor_Notes_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='descriptionOfExceptions') {
                fld.value = externalRecord.dataVendorArea.descriptionOfExceptions;
                fld.mode = new List<String>{'Edit'};
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Data_Vendor_Changes_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='createdBy') {
                fld.value = externalRecord.dataVendorArea.createdBy;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.CreatedById.getDescribe(), sObjectType);
            } else if(fieldKey=='lastModifiedBy') {
                fld.value = externalRecord.dataVendorArea.lastModifiedBy;
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.LastModifiedById.getDescribe(), sObjectType);
            } else if(fieldKey=='createdDate') {
                fld.value = String.valueOf(externalRecord.dataVendorArea.createdDate);
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.CreatedDate.getDescribe(), sObjectType);
            } else if(fieldKey=='lastModifiedDate') {
                fld.value = String.valueOf(externalRecord.dataVendorArea.lastModifiedDate);
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.LastModifiedDate.getDescribe(), sObjectType);
            } else if(fieldKey=='streetName') {
                fld.value = externalRecord.addressInfo != null ? externalRecord.addressInfo.streetName : '';
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Address_Line_1_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='city') {
                fld.value = externalRecord.addressInfo != null ? externalRecord.addressInfo.city : '';
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.City_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='suiteFloor') {
                fld.value = externalRecord.addressInfo != null ? externalRecord.addressInfo.suiteFloor : '';
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Address_Line_2_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='state') {
                fld.value = externalRecord.addressInfo != null ? externalRecord.addressInfo.state : '';
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.State_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='departmentName') {
                fld.value = externalRecord.addressInfo != null ? externalRecord.addressInfo.departmentName : '';
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Address_Line_3_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='zip') {
                fld.value = externalRecord.addressInfo != null ? externalRecord.addressInfo.zip : '';
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Zip_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='attnCareOf') {
                fld.value = externalRecord.addressInfo != null ? externalRecord.addressInfo.attnCareOf : '';
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Address_Line_4_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='addressId') {
                fld.value = externalRecord.addressInfo != null ? externalRecord.addressInfo.addressId : '';
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Current_Address_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='acct1') {
                fld.value = externalRecord.removeDuplicateAcct != null ? externalRecord.removeDuplicateAcct.acct1 : '';
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Account.Name.getDescribe(), 'Account');
            } else if(fieldKey=='acct2') {
                fld.value = externalRecord.removeDuplicateAcct != null ? externalRecord.removeDuplicateAcct.acct2 : '';
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Account.Name.getDescribe(), 'Account');
            } else if(fieldKey=='acct3') {
                fld.value = externalRecord.removeDuplicateAcct != null ? externalRecord.removeDuplicateAcct.acct3 : '';
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Account.Name.getDescribe(), 'Account');
            } else if(fieldKey=='acct4') {
                fld.value = externalRecord.removeDuplicateAcct != null ? externalRecord.removeDuplicateAcct.acct4 : '';
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Account.Name.getDescribe(), 'Account');
            } else if(fieldKey=='acct5') {
                fld.value = externalRecord.removeDuplicateAcct != null ? externalRecord.removeDuplicateAcct.acct5 : '';
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Account.Name.getDescribe(), 'Account');
            } else if(fieldKey=='amsId1') {
                fld.value = externalRecord.removeDuplicateAcct != null ? externalRecord.removeDuplicateAcct.amsId1 : '';
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.AMS_ID_1_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='amsId2') {
                fld.value = externalRecord.removeDuplicateAcct != null ? externalRecord.removeDuplicateAcct.amsId2 : '';
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.AMS_ID_2_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='amsId3') {
                fld.value = externalRecord.removeDuplicateAcct != null ? externalRecord.removeDuplicateAcct.amsId3 : '';
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.AMS_ID_3_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='amsId4') {
                fld.value = externalRecord.removeDuplicateAcct != null ? externalRecord.removeDuplicateAcct.amsId4 : '';
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.AMS_ID_4_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='amsId5') {
                fld.value = externalRecord.removeDuplicateAcct != null ? externalRecord.removeDuplicateAcct.amsId5 : '';
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.AMS_ID_5_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='addr1') {
                fld.value = externalRecord.removeDuplicateAddress != null ? externalRecord.removeDuplicateAddress.addr1 : '';
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Address_vod__c.Name.getDescribe(), 'Address_vod__c');
            } else if(fieldKey=='addr2') {
                fld.value = externalRecord.removeDuplicateAddress != null ? externalRecord.removeDuplicateAddress.addr2 : '';
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Address_vod__c.Name.getDescribe(), 'Address_vod__c');
            } else if(fieldKey=='addr3') {
                fld.value = externalRecord.removeDuplicateAddress != null ? externalRecord.removeDuplicateAddress.addr3 : '';
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Address_vod__c.Name.getDescribe(), 'Address_vod__c');
            } else if(fieldKey=='sfdcId1') {
                fld.value = externalRecord.removeDuplicateAddress != null ? externalRecord.removeDuplicateAddress.sfdcId1 : '';
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Current_Address_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='sfdcId2') {
                fld.value = externalRecord.removeDuplicateAddress != null ? externalRecord.removeDuplicateAddress.sfdcId2 : '';
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Duplicate_Address_2_gne__c.getDescribe(), sObjectType);
            } else if(fieldKey=='sfdcId3') {
                fld.value = externalRecord.removeDuplicateAddress != null ? externalRecord.removeDuplicateAddress.sfdcId3 : '';
                describe = new GNE_SFA2_Base_Ctrl.FieldDescribe(Change_Request_gne__c.Duplicate_Address_3_gne__c.getDescribe(), sObjectType);
            }

        }

        if(fieldKey != 'blankSpace' && fieldKey != 'blankSpaceOnlyEditMode') {
            describe.type = String.isNotBlank(describe.type) && describe.type != 'reference' ? describe.type : 'string';
            describe.sObjectType = 'Change_Request_gne__c';
            fld.describe = describe;
            fld.name = fld.describe.name;
            fld.helpText = fld.describe.inlineHelpText;
        } else if(fieldKey == 'blankSpaceOnlyEditMode') {
            fld.name = GNE_SFA2_Base_Ctrl.BLANK_SPACE;
            fld.mode = new List<String>{'Edit'};
            describe = null;
        } else {
            fld.name = GNE_SFA2_Base_Ctrl.BLANK_SPACE;
            describe = null;
        }
        
    }

    protected override void updateRecordFields() {
        if (String.isNotBlank(inputDataWrapper.recordDescribe.recordId)) {
            record.Id = inputDataWrapper.recordDescribe.recordId;
        }

        if (inputDataWrapper.recordDescribe.recordType != null) {
            record.put('RecordTypeId', inputDataWrapper.recordDescribe.recordType.Id);
            record.putSObject('RecordType', inputDataWrapper.recordDescribe.recordType);
        }

        if (inputDataWrapper.appContext.currentUser.id != UserInfo.getUserId()) {
            Id userId = inputDataWrapper.appContext.currentUser.id;

            try {
                record.put('OwnerId', userId);
            } catch (System.SObjectException soe) {}
        }

        if (inputDataWrapper.inputFields != null) {
            for (Field siField : inputDataWrapper.inputFields) {
                record.put(siField.name, siField.getValue());
            }
        }
    }

    protected override GNE_SFA2_Base_Ctrl.DataWrapper intSaveRecord() {
        sObjectType = inputDataWrapper.recordDescribe.sObjectType;
        record = (SObject)Type.forName(sObjectType).newInstance();
        
        updateRecordFields();

        if (validateRecord()) {
            upsertRecord();
            recordId = record.Id;
            dataWrapper.recordDescribe = inputDataWrapper.recordDescribe;
            dataWrapper.recordDescribe.recordId = recordId;
            dataWrapper.config = inputDataWrapper.config;
            dataWrapper.config.mode = VIEW_MODE;
            dataWrapper.config.fieldsToRefresh = refreshFieldValues();
            dataWrapper.recordDescribe.recordName = (String)recordAfterSave.get('Name');
            
            Id userId = UserInfo.getUserId();
            Boolean recordAccess= [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE UserId = :userId AND RecordId = :recordId LIMIT 1].HasReadAccess;

            if(!recordAccess) {
                dataWrapper.retUrl = '/apex/GNE_DCR_Portal';
            }
        }

        return dataWrapper;
    }

    public GNE_DCR_Util.DCRWrapper getDCRFromExternalSource(String systemName, String featureName, Map<String,String> params) {
        GNE_DCR_Util.DCRWrapper result = null;
        
        if(GNE_SFA2_S2S_Util.isFeatureEnabled(featureName)) {
            try {
                
               GNE_SFA2_S2S_Interface.ResponseInterface response = GNE_SFA2_S2S_ServiceEngine.callRestGetMethod(
                    systemName,
                    featureName,
                    this,
                    params,
                    GNE_DCR_Util.ResultDCRWrapper.class);
                
                result = (GNE_DCR_Util.DCRWrapper)response.getRecords()[0];
            } catch(Exception ex) {
                throw ex;
            }
        }
        
        return result;
    }

    public static GNE_SFA2_S2S_Interface.ResponseInterface updateDCRFromExternalSource(String systemName, String featureName, GNE_DCR_Util.DCRWrapper dcrWrapper, Map<String, String> params) {
        GNE_SFA2_S2S_Interface.ResponseInterface result = null;
        
        if(GNE_SFA2_S2S_Util.isFeatureEnabled(featureName)) {
            try {

                HttpRequest req = new HttpRequest();
                String endPoint = String.format('callout:{0}/services/apexrest/{1}', new String[]{
                    getNamedCredentialKey(systemName, featureName),
                    getServiceName(featureName) 
                });

                List<String> paramKeysAndValues = new List<String>();
            
                if(params!=null) {
                    for(String key : params.keySet()) {
                        String val = params.get(key);
                        paramKeysAndValues.add(key + '=' + (val!=null ? EncodingUtil.urlEncode(val, 'UTF-8') : ''));
                    }
                }

                endPoint += !paramKeysAndValues.isEmpty() ? ('?' + String.join(paramKeysAndValues, '&')) : '';

                System.debug(endPoint);
                req.setEndpoint(endPoint);
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/json');
                req.setTimeout(120000);
                
                if(dcrWrapper!=null) {
                    Map<String,Object> requestUntyped = new Map<String,Object>{
                        'dcrWrapper' => dcrWrapper
                    };
                    System.debug(JSON.serialize(requestUntyped));
                    req.setBody(JSON.serialize(requestUntyped));
                } else {
                    req.setHeader('Content-Length', '0');
                }
                
                HTTPResponse res = (new Http()).send(req);
                System.debug('res.getStatus()=' + res.getStatus());
                System.debug('res.getStatusCode()=' + res.getStatusCode());
                System.debug('res.getBody()=' + res.getBody());
                
                if(res.getStatus()=='OK' && res.getStatusCode()==200) {
                    Map<String,Object> responseUntyped = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
                    if(responseUntyped.containsKey('responseStatusCode')) {
                        if(responseUntyped.get('responseStatusCode')!='200') {
                            throw new GNE_SFA2_S2S_Util.HttpException((String)responseUntyped.get('responseStatusCode'), (String)responseUntyped.get('responseMessage'));
                        } else if(responseUntyped.get('resultData')!=null) {
                            result = (GNE_SFA2_S2S_Interface.ResponseInterface)JSON.deserialize(JSON.serialize(responseUntyped.get('resultData')), GNE_DCR_Util.ResultDCRWrapper.class);
                        }
                    } else {
                        result = (GNE_SFA2_S2S_Interface.ResponseInterface)JSON.deserialize(res.getBody(), GNE_DCR_Util.ResultDCRWrapper.class);
                    }   
                } else {
                    throw new GNE_SFA2_S2S_Util.HttpException(res.getStatusCode()!=null ? String.valueOf(res.getStatusCode()) : null, res.getStatus());
                }
                
            } catch(Exception ex) {
                throw ex;
            }
        }
        
        return result;
    }

    private static String getNamedCredentialKey(String systemName, String featureName) {
        String namedCredentialBase = GNE_SFA2_S2S_Config.getNamedCredential(systemName, featureName);
        String perUserNC = String.format('{0}_{1}', new String[]{namedCredentialBase, GNE_SFA2_S2S_Util.PER_USER_TAG});
        Boolean usePerUserCredential = ![SELECT Id FROM ExternalDataUserAuth WHERE UserId = :UserInfo.getUserId() AND ExternalDataSource.Name = :perUserNC LIMIT 1].isEmpty();
        return usePerUserCredential && testConnection(perUserNC) ? perUserNC : namedCredentialBase;
    }

    private static String getServiceName(String featureName) {
        return GNE_SFA2_S2S_Config.getServiceName(featureName);
    }

    private static Boolean testConnection(String namedCredential) {
        Boolean isOK = false;
        
        try {
            HttpRequest testReq = new HttpRequest();
            testReq.setEndpoint(String.format('callout:{0}/services/data/v33.0', new String[]{namedCredential}));
            testReq.setMethod('GET');
            Http http = new Http();
            HTTPResponse testRes = http.send(testReq);
            isOK = testRes.getStatus()!='Unauthorized' && testRes.getStatusCode()!=401; 
        } catch(Exception ex) {}
        
        return isOk;
    }
    
    @RemoteAction
    public static DataWrapper saveRecord(String inputDataInJSON) {
        return (DataWrapper)(new GNE_DCR_Ctrl()).saveRecord(inputDataInJSON, GNE_DCR_Ctrl.DataWrapper.class);
    }

    @RemoteAction
    public static GNE_SFA2_S2S_Interface.ResponseInterface saveExternalRecord(Map<String, String> params) {
        GNE_SFA2_S2S_Interface.ResponseInterface result = null;
        String source = params.get('source');
        String dcr = params.get('dcrWrapper');
        GNE_DCR_Util.DCRWrapper dcrWrapper = (GNE_DCR_Util.DCRWrapper)JSON.deserialize(dcr, GNE_DCR_Util.DCRWrapper.class);
        if(source == 'MA') {
            Map<String, String> maParams = new Map<String, String>{'object' => 'DCR', 'method' => 'updateDCR'};
            result = updateDCRFromExternalSource(GNE_DCR_Util.MA_SYSTEM_NAME, GNE_DCR_Util.MA_FEATURE_DCR_UPDATE, dcrWrapper, maParams);
        } else if(source == 'PACT') {
            result = updateDCRFromExternalSource(GNE_DCR_Util.PACT_SYSTEM_NAME, GNE_DCR_Util.PACT_FEATURE_DCR_UPDATE, dcrWrapper, null);
        }
            
        return result;
    }
}