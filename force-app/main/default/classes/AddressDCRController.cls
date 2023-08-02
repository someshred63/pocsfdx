public with sharing class AddressDCRController {

	public Address_vod__c address {get; private set;}
	private Account acct;
	public  Change_Request_gne__c changeRequest {get; private set;}    
	public String RequestObjectType { get; set; } 
	public String requestRecordType { get; set; }
	public List<SelectOption>accountAddresses {get; private set;} 
	public String addressLongName {get; private set;} 
	
	private RequestType DCRRequestType = RequestType.None;

	public enum RequestType {None, DCRRequestTypes, 
		HCPChangeAddress, HCPRemoveAddress,HCPDuplicateAddress,HCPReactivateAddress, 
		AMSHCOChangeAddress, AMSHCORemoveAddress,
		NonAMSHCOChangeAddress, NonAMSHCORemoveAddress
	}

	private Map<String,String> mapRecordType = new Map<String,String>{
		RequestType.HCPChangeAddress.Name()       => 'HCP_Existing_Address_Typo_Missing_Info',
		RequestType.HCPRemoveAddress.Name()       => 'HCP_Remove_Inactivate_Address',
		RequestType.HCPDuplicateAddress.Name()    => 'Duplicate_Address',
		RequestType.HCPReactivateAddress.Name()   => 'HCP_Reactivate_Address',

		RequestType.AMSHCOChangeAddress.Name()    => 'HCO_Change_Address',
		RequestType.AMSHCORemoveAddress.Name()    => 'HCO_Remove_Inactivate_Address',
		
		RequestType.NonAMSHCOChangeAddress.Name() => 'HCO_Change_Address',
		RequestType.NonAMSHCORemoveAddress.Name() => 'HCO_Remove_Inactivate_Address'
	};
	

	private Id getRecordTypeId (String recordTypeName) {
		return [SELECT id FROM recordType WHERE isactive=true AND DeveloperName =: recordTypeName AND sobjectType ='Change_Request_gne__c'].id ;    
	}

	public String getRequestLabelDisplayText() {
		system.debug(DCRRequestType.Name());
		String labelText = '';
		try {
			if(getHasCanadaProfile() && (getHCPRemoveAddress() || getHCPChangeAddress())){
				labelText = [select id, value from externalstring where masterlabel =: DCRRequestType.Name() + '_Pre_can_gne'].value; 
			}else{
				labelText = [select id, value from externalstring  where masterlabel =: DCRRequestType.Name() + '_Pre_gne'].value; 
			}
			
		} catch (Exception e) {
			// no exception handled.            
		}
		return labelText;
	} 

	public Boolean getDCRRequestTypes() {
		return (DCRRequestType == RequestType.DCRRequestTypes);   
	}

	// HCP DCR Request Address Types
	public Boolean getHCPDCRRequestTypes() {
		return ((DCRRequestType == RequestType.DCRRequestTypes) && (acct.IsPersonAccount == true));                  
	}

	// AMS HCO DCR Request Types
	public Boolean getAMSHCODCRRequestTypes() {
		return ((DCRRequestType == RequestType.DCRRequestTypes) && 
		(acct.IsPersonAccount == false) && 
		(acct.stewardship_system_name_gne__c != null) && 
		(acct.stewardship_system_name_gne__c.equalsIgnoreCase('ams') == true)
		);                  
	}

	// non-AMS, gap HCO DCR Request Types 
	public Boolean getNonAMSHCODCRRequestTypes() {
		return ((DCRRequestType == RequestType.DCRRequestTypes) && 
		(acct.IsPersonAccount == false) && 
		((acct.stewardship_system_name_gne__c == null) || 
		(acct.stewardship_system_name_gne__c.equalsIgnoreCase('ams') == false)));                  
	}

	// HCP Address
	public Boolean getHCPChangeAddress() {
		return (DCRRequestType == RequestType.HCPChangeAddress);   
	}
	
	public Boolean getHCPRemoveAddress() {
		return (DCRRequestType == RequestType.HCPRemoveAddress);   
	}
	
	// AMS Address
	public Boolean getAMSHCOChangeAddress() {
		return (DCRRequestType == RequestType.AMSHCOChangeAddress);   
	}

	public Boolean getAMSHCORemoveAddress() {
		return (DCRRequestType == RequestType.AMSHCORemoveAddress);   
	}

	// Non-AMS Address
	public Boolean getNonAMSHCOChangeAddress() {
		return (DCRRequestType == RequestType.NonAMSHCOChangeAddress);   
	}
	public Boolean getNonAMSHCORemoveAddress() {
		return (DCRRequestType == RequestType.NonAMSHCORemoveAddress);   
	}
	
	public Boolean getHCPRemoveDuplicateAddress(){
		return DCRRequestType == RequestType.HCPDuplicateAddress;
	}
	
	public Boolean getHCPReactivateAddress(){
		return DCRRequestType == RequestType.HCPReactivateAddress;
	}
	
	// navigation - selection of recordTypes
	public PageReference selectRecordType() {
		system.debug(requestRecordType);
		if ( requestRecordType.equalsIgnoreCase ('OtherFAQ')){
			if(!getHasCanadaProfile()){
				return Page.DCR_FAQ;
			}else{
				return Page.DCR_FAQ_Canada;
			}
		} 

		// HCP             
		else if ( requestRecordType.equalsIgnoreCase ('HCPChangeAddress')){
			DCRRequestType = RequestType.HCPChangeAddress;                                                 
		}else if ( requestRecordType.equalsIgnoreCase ('HCPRemoveAddress')){
			DCRRequestType = RequestType.HCPRemoveAddress;
		}else if ( requestRecordType.equalsIgnoreCase ('HCPRemoveDuplicateAddress')){
			DCRRequestType = RequestType.HCPDuplicateAddress;
		}else if ( requestRecordType.equalsIgnoreCase ('HCPReactivateAddress')){
			DCRRequestType = RequestType.HCPReactivateAddress;
		}
		
		// AMS HCO                                                                
		else if ( requestRecordType.equalsIgnoreCase ('AMSHCOChangeAddress')){
			DCRRequestType = RequestType.AMSHCOChangeAddress;                                                 
		}else if ( requestRecordType.equalsIgnoreCase ('AMSHCORemoveAddress')){
			DCRRequestType = RequestType.AMSHCORemoveAddress;

		// Non AMS, Gap
		}else if ( requestRecordType.equalsIgnoreCase ('NonAMSHCOChangeAddress')){
			DCRRequestType = RequestType.NonAMSHCOChangeAddress;                                                 
		}else if ( requestRecordType.equalsIgnoreCase ('NonAMSHCORemoveAddress')){
			DCRRequestType = RequestType.NonAMSHCORemoveAddress;
		}                                                 
		system.debug(DCRRequestType.Name());
		// initialize change request
		changeRequest = new Change_Request_gne__c();                        
		changeRequest.RecordTypeId = getRecordTypeId(mapRecordType.get(DCRRequestType.Name()));
		changeRequest.Reason_dcr_gne__c = '';
		
		changeRequest.account_gne__c         = acct.Id;
		changeRequest.current_address_gne__c = address.Id;
		
		changeRequest.address_line_1_gne__c  = address.name;
		changeRequest.city_gne__c            = address.city_vod__c;
		changeRequest.state_gne__c           = address.state_vod__c;
		changeRequest.zip_gne__c             = address.zip_vod__c;
		
		changeRequest.Province_can_gne__c  = address.Province_can_gne__c;
		changeRequest.Postal_Code_can_gne__c  = address.Postal_Code_can_gne__c;
		
		changeRequest.address_line_2_gne__c  = address.address_line_2_vod__c;
		changeRequest.address_line_3_gne__c  = address.address_line_3_gne__c;
		changeRequest.address_line_4_gne__c  = address.address_line_4_gne__c;
		return null;
	}

	public AddressDCRController(ApexPages.StandardController stdController) {       
				DCRRequestType       = RequestType.DCRRequestTypes;
		// initialize address, account with stewardship system flag
		Id addrId = stdController.getRecord().Id;
		List<Account> accs = [
            SELECT Id, Name, isPersonAccount, stewardship_system_name_gne__c,
                (SELECT id, account_vod__c, name, city_vod__c, state_vod__c, zip_vod__c, Postal_Code_can_gne__c, Province_can_gne__c, 
                    address_line_2_vod__c, address_line_3_gne__c, address_Line_4_gne__c
                 FROM Address_vod__r)
            FROM Account
            WHERE Id IN (SELECT Account_vod__c FROM Address_vod__c WHERE Id = :addrId)
        ];
        
        accountAddresses = new List<SelectOption>{new SelectOption('', '--None--')};

        for(Account acc : accs) {
            acct = acc;
            
            for(Address_vod__c ad : acc.Address_vod__r) {
                if(ad.Id==addrId) {
                    address = ad;
                    addressLongName = getAddressLongName(ad);
                }else{
                    accountAddresses.add(new SelectOption(ad.Id, getAddressLongName(ad)));
                }
            }
        }
        
        String dcrReqType = ApexPages.currentPage().getParameters().get('DCRRequestType');
        
        if(String.isNotBlank(dcrReqType) && acct!=null) {
            String accType = acct.isPersonAccount ? 'HCP' : 'HCO';
            String amsType = acct.isPersonAccount ? '' : getAMSHCODCRRequestTypes() ? 'AMS' : 'NonAMS';
            requestRecordType = amsType + accType + dcrReqType;
            selectRecordType();
        }
	}

	private String getAddressLongName(Address_vod__c ad) {
        return GNE_SFA2_Util.getAddressAsString(ad);
    }
	
	public Account getAccount() {
		return acct;    
	}

	public Boolean getIsAccountAMSStewarded() {
		Boolean bRet = false;  
		if ((acct.stewardship_system_name_gne__c != null) && acct.stewardship_system_name_gne__c.equalsIgnoreCase('ams')){ 
			bRet = true;
		}
		return bRet;
	}
	
	public PageReference confirm() {
		try {
            insert changeRequest;
        } catch (DMLException ex) {
            ApexPages.addMessages(ex);
            return null;              
        }           
        String status = [SELECT Status_gne__c FROM Change_Request_gne__c where id = :changeRequest.Id].Status_gne__c;
        PageReference acctPage = new PageReference ('/apex/AccountDCRConfirmation?id=' + acct.Id + 
                                                    '&status=' + status);
        acctPage.setRedirect(true);
        return acctPage;
	}

	public PageReference cancel() {
		return (new ApexPages.StandardController(address)).view();
	}
	
	//method to indicate whether the logged on user is a Canada user
	public Boolean getHasCanadaProfile() {
		return GNE_SFA2_Util.isCanadaUser();
	}
	
	public String getActiveMenuItem() {
		return 'DCR';
	}
	
    private String getAddressDuplicateInfo (String id) {        
        String acctInfo = '';        
        try {
            if (String.isNotEmpty(id)) {          
                Address_vod__c address = [SELECT id, CreatedBy.FirstName, CreatedBy.LastName, Name, CreatedDate FROM Address_vod__c WHERE id =: id ];            
                acctInfo = '<b>Created By:</b> '            +   
                           address.CreatedBy.FirstName    + ' ' + 
                           address.CreatedBy.LastName     + '. ' +
                           '<b>Created Date:</b> '          +
                           address.createdDate         + ' (<b>SFDC Id:</b> '+ 
                           address.Id                  + ')' ;                             
            }
                
        } catch (Exception e) {
            System.debug ( e.getMessage());
        }
		system.debug(acctInfo);
        return acctInfo;            
    }
    
    public String getAddress1Info() {
        return getAddressDuplicateInfo(address.Id); 
    }

    public String getAddress2Info() {
        return getAddressDuplicateInfo(changeRequest.Duplicate_Address_2_gne__c);              
    }

    public String getAddress3Info() {
        return getAddressDuplicateInfo(changeRequest.Duplicate_Address_3_gne__c);              
    }

    // USPS Address Validation Logic 

    @RemoteAction
    public static String addressValidate(Map<String, String> params) {
        return GNE_SFA2_USPSEngine.addressValidate(params);
    }

    @RemoteAction
    public static String cityStateLookup(Map<String, String> params) {
        return GNE_SFA2_USPSEngine.cityStateLookup(params);
    }

    @RemoteAction
    public static String zipCodeLookup(Map<String, String> params) {
        return GNE_SFA2_USPSEngine.zipCodeLookup(params);
    }
}