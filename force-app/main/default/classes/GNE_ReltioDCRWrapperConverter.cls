public class GNE_ReltioDCRWrapperConverter {

    public static Map<Id, String> id2RecordTypeDevName;
    public static Map<String, String> mappingImplementationType;

    static {
        mappingImplementationType = new Map<String, String> {
                'Change_Request_gne__c'     => 'GNE_ReltioDCRWrapperConverter.DCRWrapperImpl',
                'Affiliation_vod__c'        => 'GNE_ReltioDCRWrapperConverter.AffiliationWrapperImpl'
        };
        id2RecordTypeDevName = getRecordTypes();
    }

    private static Map<Id, String> getRecordTypes() {
        if(id2RecordTypeDevName == null) {
            id2RecordTypeDevName = new Map<Id, String>();
            for(RecordType rt:[SELECT Id, DeveloperName FROM RecordType WHERE SObjectType ='Change_Request_gne__c']) {
                id2RecordTypeDevName.put(rt.Id, rt.DeveloperName);
            }
        }

        return id2RecordTypeDevName;
    }

    public static String createRequestBody(SObject sourceObj) {
        String result;
        String objTypeName = sourceObj.getSObjectType().getDescribe().getName();
        String implType = mappingImplementationType.get(objTypeName);
        IDCRWRapper instance = (IDCRWRapper)Type.forName(implType).newInstance();
        Object wrapper = instance.buildWrapper(sourceObj);
        result = JSON.serializePretty(wrapper, true);
        return result;
    }
    
    public class StatusesResponse {
        public SingleStatusWrapper[] dcrResponseDetails;
    }
    
    public class SingleStatusWrapper {
        public String name;
        public String result;
    }
    
    public class StatusesRequestObject {
        public SingleRequestWrapper [] dcrRequestDetails;
    }
    
    public class SingleRequestWrapper {
        public String name;
    }
    
    public class ResponseTopLevel {
        public ResponseWrapper dcrResponseDetails;
    }
    
    public class ResponseWrapper {
        public String entityId;
        public String dcrName;
        public String sourceName;
        public List <ResponseErrorDetail> errorDetails;
    }    
    
    public class ResponseErrorDetail {
        public String code;
        public String description;
    } 
    
    public class ResponseError {
        public Integer errorCode;
        public String errorDescription;
    } 
    
    public class ResponseErrorDesc {
        public Integer errorCode;
        public String description;
    }
    
    public class ResponceErrorsColl {
        public List<ResponseErrorDesc> errorDetails;
    }
    
    public class WrapperDCR {
        public String dcrName;
        public Owner owner;
        public String createdById;
        public String lastModifiedById;
        public String notes;
        public String status;
        public String sourceName; //SFDC
        public String account;
        public String dcrType;
        public String firstName;
        public String middleName;
        public String lastName;
        public String suffix;
        public String professionalType;
        public List<String> credentials;
        public List<String> specialties;
        public String addressid;
        public String reason;
        public DateTime createdDate;
        public DateTime lastModifiedDate;
        public String newOrganizationName;
        public String accountType;
        public String currentAddress;
        public List<Address> address;
        public License license;
        public String dcrState;
        public String resolutionNote;
    }

    public class AffiliationWrapper {
        public String dcrName;
        public Owner owner;
        public String createdById;
        public String lastModifiedById;
        public String notes;
        public String status;
        public String sourceName; //SFDC
        public String account;
        public String dcrType;
        public Affiliation affiliation;
        public DateTime createdDate;
        public DateTime lastModifiedDate;
    }
    
    public class Owner {
        public String name;
        public Owner(String name) {
            this.name = name;
        }
    }
    
    public static String getOwnerName (Id userOrGroupId) {
        String SObjectName = userOrGroupId.getSObjectType().getDescribe().getName();
        String query = 'SELECT Name FROM '+SObjectName+ ' WHERE Id = \''+ userOrGroupId +'\'';
        SObject sobj = DataBase.query(query)[0];
        System.debug(sobj.get('Name'));
        return String.valueOf(sobj.get('Name'));
    }
    
    @TestVisible
    interface IDCRWRapper {
        Object buildWrapper(SObject dataChangeRequest);
    }
    
    public class DCRWrapperImpl implements IDCRWRapper {
        public WrapperDCR buildWrapper(SObject dataChangeRequestObj) {
            WrapperDCR result = new  WrapperDCR();
            Change_Request_gne__c dataChangeRequest = (Change_Request_gne__c)dataChangeRequestObj;
            
            // HCP CHANGE INFO
            result.firstName = dataChangeRequest.First_Name_DCR_gne__c;
            result.lastName = dataChangeRequest.Last_Name_DCR_gne__c;
            result.suffix = dataChangeRequest.Suffix_DCR_gne__c;
            result.professionalType = dataChangeRequest.Professional_Type_DCR_gne__c;
            result.credentials = dataChangeRequest.Credentials_DCR_gne__c?.split(';');
            result.specialties = dataChangeRequest.Specialties_HCP_DCR_gne__c?.split(';');

            // COMMON
            result.dcrName = dataChangeRequest.Name;
            result.dcrType = dataChangeRequest.Type_gne__c;
            result.status = dataChangeRequest.Status_gne__c;
            result.account = dataChangeRequest.Account_gne__c;
            result.owner = new Owner(getOwnerName(dataChangeRequest.OwnerId));
            result.createdById = dataChangeRequest.CreatedById;
            result.createdDate = dataChangeRequest.CreatedDate;
            result.lastModifiedDate = dataChangeRequest.LastModifiedDate;
            result.lastModifiedById = dataChangeRequest.LastModifiedById;
            result.sourceName = 'SFDC';
            result.notes = dataChangeRequest.Notes_gne__c != null ? dataChangeRequest.Notes_gne__c : '';
            result.reason = dataChangeRequest.Reason_dcr_gne__c != null ? dataChangeRequest.Reason_dcr_gne__c : '';

            // HCO CHANGE INFO
            result.accountType = dataChangeRequest.Account_Type_DCR_gne__c;
            result.newOrganizationName = dataChangeRequest.New_Organization_Name_gne__c;

            // Change HCP Address
            result.addressid = dataChangeRequest.Current_Address_gne__c;
            Address addr = new Address();
            addr.street = dataChangeRequest.Address_Line_1_gne__c;
            addr.addressLine2 = dataChangeRequest.Address_Line_2_gne__c;
            addr.city = dataChangeRequest.City_gne__c;
            addr.state = dataChangeRequest.State_gne__c;
            addr.zip = dataChangeRequest.Zip_gne__c;

            result.address = new List<Address> {addr};

            // License
            result.license = new License();
            result.license.licenseState = dataChangeRequest.License_State_gne__c;
            result.license.licenseNumber = dataChangeRequest.License_Number_gne__c;
            result.license.status = dataChangeRequest.Status_gne__c;
            result.license.licenseExpirationDate = dataChangeRequest.License_Expiration_Date_gne__c;
            result.license.adjustedLicenseExpirationDate = dataChangeRequest.Adjusted_License_Expiration_Date_gne__c;
            result.license.licenseOverwriteExpirationDate = dataChangeRequest.License_Overwrite_Expiration_Date_gne__c;
            result.license.licenseSampleAbility = dataChangeRequest.License_Sample_ability_gne__c ? 'true' : 'false';
            
            return result;
        }
    }

    @TestVisible
    interface IAffiliationWrapper {
        AffiliationWrapper buildWrapper(Affiliation_vod__c affiliation);
    }

    public class AffiliationWrapperImpl implements IDCRWRapper {
        public AffiliationWrapper buildWrapper(SObject affiliationObj) {
            AffiliationWrapper result = new  AffiliationWrapper();
            Affiliation_vod__c affiliation = (Affiliation_vod__c)affiliationObj;


            // COMMON
            result.dcrName = affiliation.Name;
            result.dcrType = 'CreateAffiliation';
            try {
                result.dcrType = Trigger.isDelete ? 'DeleteAffiliation' : 'CreateAffiliation';
            } catch (Exception ex) {
                System.debug(ex.getMessage());
            }

            result.status = affiliation.Record_Status_gne__c;
            result.account = affiliation.From_Account_vod__c;
            result.owner = new Owner(getOwnerName(affiliation.OwnerId));
            result.createdById = affiliation.CreatedById;
            result.createdDate = affiliation.CreatedDate;
            result.lastModifiedDate = affiliation.LastModifiedDate;
            result.lastModifiedById = affiliation.LastModifiedById;
            result.sourceName = 'SFDC';
            result.notes = affiliation.Note_gne__c != null ? affiliation.Note_gne__c : '';

            // New Affiliation, Inactivate Affiliation
            result.affiliation = new Affiliation();
            result.affiliation.parentAccount = affiliation.To_Account_vod__c;
            result.affiliation.childAccount = affiliation.From_Account_vod__c;
            result.affiliation.createdDate = affiliation.CreatedDate;
            result.affiliation.account = new RelationType();
            result.affiliation.account.gtAccountRecordTypeC = 'HcoRelation:' + affiliation.From_Account_vod__c + ':' + affiliation.To_Account_vod__c;

            return result;
        }
    }

    private class Address {
        public String street;
        public String addressLine2;
        public String city;
        public String state;
        public String zip;
    }

    private class Affiliation {
        public String parentAccount;
        public String childAccount;
        public RelationType account;
        public DateTime createdDate;
    }

    private class RelationType {
        public String gtAccountRecordTypeC;
    }

    private class License {
        public String status;
        public String licenseState;
        public String licenseNumber;
        public Date licenseExpirationDate;
        public Date adjustedLicenseExpirationDate;
        public Date licenseOverwriteExpirationDate;
        public String licenseSampleAbility;
    }

    private class ResolutionStatus {
        public String dcrState;
        public String resolutionNote;

        ResolutionStatus(String dcrState, String resolutionNote) {
            this.dcrState = dcrState;
            this.resolutionNote = resolutionNote;
        }
    }
}