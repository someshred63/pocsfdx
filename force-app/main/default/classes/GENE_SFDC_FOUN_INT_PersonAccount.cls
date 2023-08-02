global class GENE_SFDC_FOUN_INT_PersonAccount {

    global enum OperationType {updated,deleted,created,none}

    //  Request Classes    
    global class Account_stub{    

        // type 1
        WebService string AMS_ID_gne;
        WebService string MDMID_gne;
        WebService string MDMID_Status_gne;

        WebService string Firstname;
        WebService string Lastname;
        WebService string Middle_gne;
        WebService string Gender_vod;
        WebService string Suffix_gne;
        WebService string Name;
        WebService string Date_of_Birth_gne;
        WebService DateTime MDM_Update_Date_gne;
        WebService string Professional_Type_gne;
        WebService string Account_Type_gne;
        WebService string RecordTypeId;
        WebService string Credentials_gne;
        WebService string Specialties_gne;

        
        // type 3
        WebService string Phone;
        WebService string Cell_Phone_gne;
        WebService string Fax;
        WebService string Salutation;
        WebService string Website;
        
         // to support create account - payer, Event Mgmt account
        WebService String ContributorSourceCodeList;
        WebService String ContributorSourceDescriptionList;
        WebService String SourceEntityIdentifierList;
        WebService String RecordEffectiveStartDateList;
        WebService String RecordEffectiveEndDateList;
        WebService String DatewarehouseLastUpdateTimeStampList;
        
        // return message
        WebService String ErrorCode;
        WebService String ErrorMessage;
        WebService OperationType OperationPerformed;
        WebService String Id; // id updated or created. 

    }

    global class Address_stub{
        // type 1
	        WebService string Name;
	        WebService string City_vod;
	        WebService string Country_gne;
	        WebService string State_vod;
	        WebService string Zip_4_vod;
	        WebService string Zip_vod;
	        WebService boolean GOLD_RECORD_gne;
	        WebService boolean Active_Flag_gne;        
	        WebService string MDM_Address_ID_gne;        

        // usage flags 
	        WebService boolean Billing_vod;
	        WebService boolean Business_vod;
	        WebService boolean Hospital_gne;
	        WebService boolean Mailing_vod;
	        WebService boolean Office_gne;
	        WebService boolean Shipping_vod;

        // type 3
	        WebService string Address_line_2_vod;
	        WebService string Address_Line_3_gne;
	        WebService string Address_Line_4_gne;
	
	        WebService string License_vod;
	        WebService Date   License_Expiration_Date_vod;
	        WebService string License_Status_vod;
	
	        WebService string Phone_vod;
	        WebService string Phone_1_Ext_gne;
	        WebService string Phone_2_vod;
	        WebService string Phone_2_Ext_gne;
	        WebService string Fax_vod;

        // to support account create
	        WebService String ContributorSourceCodeList;
	        WebService String ContributorSourceDescriptionList;
	        WebService String SourceEntityIdentifierList;
	        WebService String RecordEffectiveStartDateList;
	        WebService String RecordEffectiveEndDateList;
	        WebService String DatewarehouseLastUpdateTimeStampList;        

        // return message
	        WebService String ErrorCode;
	        WebService String ErrorMessage;
	        WebService OperationType OperationPerformed;
	        WebService List<String> AddressIdList; // id updated or created. 

    }
    
    global class RequestAccountFoundationItem {
        WebService Account_stub Account;
        WebService List<Address_stub> Addresses;

        WebService String SourceSystemIdentifier;
        WebService String Transaction_Id;
        WebService String SourceSystem;
        WebService String PartyType;
        
    }
    
    global class RequestAccountFoundation {
        WebService List<RequestAccountFoundationItem> RequestItems;
    }    
        
    global class ResponseAccountFoundation{
        WebService List<RequestAccountFoundationItem> RequestItems;
        
        // partial functionality released 
        // for 10/22/2009             
        WebService String UpdatedObjectList; 
        WebService String UpdatedObjectIdList;        
        WebService String CreatedObjectList;
        WebService String CreatedObjectIdList;        
        WebService String DeletedObjectList;
        WebService String DeletedObjectIdList;
    }
    
    //  Interface 
    WebService static ResponseAccountFoundation  AccountFoundation(RequestAccountFoundation Request){

        ResponseAccountFoundation response = new ResponseAccountFoundation();
        response.requestItems              = Request.RequestItems;        
        
        GENE_SFDC_FOUN_INT_PersonAcctController personAcctController = 
                new GENE_SFDC_FOUN_INT_PersonAcctController(response.RequestItems[0] );
                
        personAcctController.process();
        
        return response;
   }
    
}