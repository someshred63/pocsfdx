public with sharing class GNE_DCR_Util {
    
    public static final String MA_SYSTEM_NAME = 'MA';
    public static final String MA_FEATURE_DCR_GET_LIST = 'DcrMAGetList';
    public static final String MA_FEATURE_DCR_GET_DETAIL = 'DcrMAGetDetail';
    public static final String MA_FEATURE_DCR_UPDATE = 'DcrMAUpdate';
    public static final String MA_FEATURE_DCR_CREATE = 'DcrMACreate';

    public static final String PACT_SYSTEM_NAME = 'PACT';
    public static final String PACT_FEATURE_DCR_GET_LIST = 'DcrPACTGetList';
    public static final String PACT_FEATURE_DCR_GET_DETAIL = 'DcrPACTGetDetails';
    public static final String PACT_FEATURE_DCR_UPDATE = 'DcrPACTUpdate';
    public static final String PACT_FEATURE_DCR_CREATE = 'DcrPACTCreate';
    
    public static final String S2S_CONFIG_ITEM_MA_SYSTEM_BASE_URL = 'MABaseUrl';
    public static final String S2S_CONFIG_ITEM_PACT_SYSTEM_BASE_URL = 'PACTBaseUrl';

    public static final String BASE_QUERY = 'SELECT Id, Name, Account_gne__r.Name, Account_gne__r.MDMID_gne__c, Type_gne__c, CreatedDate, CreatedBy.Name, LastModifiedDate, Status_gne__c, Assigned_Analyst_gne__r.Name, RecordType.Name FROM Change_Request_gne__c';

    public virtual class DCRListWrapper extends GNE_SFA2_S2S_Util.Record {
        protected String name;
        protected String accountName;
        protected String requestType;
        protected String recordType;
        protected Datetime createdDate;
        protected String makerName;
        protected String status;
        protected String requestAnalyst;
        protected Datetime lastModifiedDate;
        protected String mdmId;
        protected String source;

        public DCRListWrapper() {}
        
        public DCRListWrapper(String localId, String extId, String name, String accountName, String requestType, String recordType, Datetime createdDate, String makerName, String status, String requestAnalyst, Datetime lastModifiedDate, String mdmId, String source) {
            super(localId, extId);
            this.name = name;
            this.accountName = accountName;
            this.requestType = requestType;
            this.recordType = recordType;
            this.createdDate = createdDate;
            this.makerName = makerName;
            this.status = status;
            this.requestAnalyst = requestAnalyst;
            this.lastModifiedDate = lastModifiedDate;
            this.mdmId = mdmId;
            this.source = source;
        }

        public DCRListWrapper(Change_Request_gne__c dcr, String source) {
            super(dcr.Id, null);
            this.name = dcr.Name;
            this.accountName = dcr.Account_gne__r.Name;
            this.requestType = dcr.Type_gne__c;
            this.recordType = dcr.RecordType.Name;
            this.createdDate = dcr.CreatedDate;
            this.makerName = dcr.CreatedBy.Name;
            this.status = dcr.Status_gne__c;
            this.requestAnalyst = dcr.Assigned_Analyst_gne__r.Name;
            this.lastModifiedDate = dcr.LastModifiedDate;
            this.mdmId = dcr.Account_gne__r.MDMID_gne__c;
            this.source = source;
        }
    }

    public virtual class DCRWrapper extends GNE_SFA2_S2S_Util.Record {
        public String name;
        public String recordType;
        public DCRInformation information;
        public DCROrgChangeInfo orgChangeInfo;
        public DCRProfChangeInfo profChangeInfo;
        public DCRAddressInfo addressInfo;
        public DCRRemoveDuplicateAcct removeDuplicateAcct;
        public DCRRemoveDuplicateAddress removeDuplicateAddress;
        public DCRDataVendorArea dataVendorArea;

        public DCRWrapper() {}

        public DCRWrapper(String localId, String extId, String name, String recordType, DCRInformation information, DCROrgChangeInfo orgChangeInfo, DCRProfChangeInfo profChangeInfo, DCRAddressInfo addressInfo, DCRRemoveDuplicateAcct removeDuplicateAcct, DCRRemoveDuplicateAddress removeDuplicateAddress, DCRDataVendorArea dataVendorArea) {
            super(localId, extId);
            this.name = name;
            this.recordType = recordType;
            this.information = information;
            this.orgChangeInfo = orgChangeInfo;
            this.profChangeInfo = profChangeInfo;
            this.addressInfo = addressInfo;
            this.removeDuplicateAcct = removeDuplicateAcct;
            this.removeDuplicateAddress = removeDuplicateAddress;
            this.dataVendorArea = dataVendorArea;
        }

    }

    public class DCRInformation {
        public String status;
        public String accountName;
        public String approvalState;
        public String accountId;
        public String requestType;
        public String requestAnalyst;
        public String reasonForDCR;
        public String amsId;
    }

    public class DCROrgChangeInfo {
        public String orgName;
        public String orgType;
        public String orgSpecialties;
        public String orgValidateSpecialties;
    }

    public class DCRProfChangeInfo {
        public String hcpFirstName;
        public String hcpMiddleName;
        public String hcpLastName;
        public String hcpSuffix;
        public String hcpProfessionalType;
        public String hcpValidateCredentials;
        public String hcpCredentials;
        public String hcpValidateSpecialties;
        public String hcpSpecialties;
    }

    public class DCRAddressInfo {
        public String streetName;
        public String city;
        public String suiteFloor;
        public String state;
        public String departmentName;
        public String zip;
        public String attnCareOf;
        public String addressId;
    }

    public class DCRRemoveDuplicateAcct {
        public String acct1;
        public String acct2;
        public String acct3;
        public String acct4;
        public String acct5;
        public String amsId1;
        public String amsId2;
        public String amsId3;
        public String amsId4;
        public String amsId5;
    }

    public class DCRRemoveDuplicateAddress {
        public String addr1;
        public String addr2;
        public String addr3;
        public String sfdcId1;
        public String sfdcId2;
        public String sfdcId3;
    }

    public class DCRDataVendorArea {
        public String newVendorNote;
        public String vendorNotes;
        public String descriptionOfExceptions;
        public String createdBy;
        public String lastModifiedBy;
        public Datetime createdDate;
        public Datetime lastModifiedDate;
    }

    public virtual class DCRListRequest extends GNE_SFA2_S2S_Util.Request {
        protected List<DCRListWrapper> records;
        
        public DCRListRequest() {
            super();
        }
        
        public DCRListRequest(List<GNE_SFA2_S2S_Interface.RecordInterface> records, Actor actor, Boolean allOrOne) {
            super(records, actor, allOrOne);
        }
        
        public virtual override System.Type getSelfClass() {
            return DCRListRequest.class;
        }
        
        public virtual override List<GNE_SFA2_S2S_Interface.RecordInterface> getRecords() {
            if(this.records==null) {
                this.records = new List<DCRListWrapper>();
            }
            
            return this.records;
        }
    }

    public virtual class DCRRequest extends GNE_SFA2_S2S_Util.Request {
        protected List<DCRWrapper> records;
        
        public DCRRequest() {
            super();
        }
        
        public DCRRequest(List<GNE_SFA2_S2S_Interface.RecordInterface> records, Actor actor, Boolean allOrOne) {
            super(records, actor, allOrOne);
        }
        
        public virtual override System.Type getSelfClass() {
            return DCRRequest.class;
        }
        
        public virtual override List<GNE_SFA2_S2S_Interface.RecordInterface> getRecords() {
            if(this.records==null) {
                this.records = new List<DCRWrapper>();
            }
            
            return this.records;
        }
    }

    public virtual class ResultDCRListWrapper extends GNE_SFA2_S2S_Util.Response {
        protected List<DCRListWrapper> records;
        
        public ResultDCRListWrapper() {}
        
        public ResultDCRListWrapper(Boolean success, List<DCRListWrapper> records, List<GNE_SFA2_S2S_Util.Error> errors) {
            this.success = false;
            this.records = records;
            this.errors = errors;
        }
        
        public virtual override System.Type getSelfClass() {
            return ResultDCRListWrapper.class;
        }
        
        public virtual override List<GNE_SFA2_S2S_Interface.RecordInterface> getRecords() {
            if(this.records==null) {
                this.records = new List<DCRListWrapper>();
            }
            
            return this.records;
        }
    }

    public virtual class ResultDCRWrapper extends GNE_SFA2_S2S_Util.Response {
        protected List<DCRWrapper> records;
        
        public ResultDCRWrapper() {}
        
        public ResultDCRWrapper(Boolean success, List<DCRWrapper> records, List<GNE_SFA2_S2S_Util.Error> errors) {
            this.success = false;
            this.records = records;
            this.errors = errors;
        }
        
        public virtual override System.Type getSelfClass() {
            return ResultDCRWrapper.class;
        }
        
        public virtual override List<GNE_SFA2_S2S_Interface.RecordInterface> getRecords() {
            if(this.records==null) {
                this.records = new List<DCRWrapper>();
            }
            
            return this.records;
        }
    }

}