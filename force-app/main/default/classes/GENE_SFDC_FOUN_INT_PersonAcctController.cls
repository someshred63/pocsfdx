public class GENE_SFDC_FOUN_INT_PersonAcctController {
    
    GENE_SFDC_FOUN_INT_PersonAccount.RequestAccountFoundationItem requestItem;
    Map<String,List<String>> sourceCodeToIdMap = new Map<String,List<String>>();
    Account[] acctList                         = new List<Account>();
    Account   acct                             = null;
    
    static List<String> accountCreateSystemXREFList   = null; 
    static List<String> accountExternalCreateXREFList = null; 

    // initialize once for esb admin session 
    static List<String> roleListByRank               = null;
    static Map<String,String> roleToProfessionalType = null;
    static Id companyMaintainedRecordTypeId          = null;
    
    static {
	    roleListByRank               = GENE_SFDC_FOUN_INT_UTIL.getCADSRoleListByRank();
	    roleToProfessionalType       = GENE_SFDC_FOUN_INT_UTIL.getRoleToProfessionalTypeMapping();

	    accountCreateSystemXREFList   =  new List<String>();
	    accountExternalCreateXREFList =  new List<String>();

	    // account create xref config 
	        String systemXREFString                    = System.Label.CADSPublish_AccountCreateOnSystemXREFList;
	        if ( systemXREFString != null )
	            accountCreateSystemXREFList.addAll ( systemXREFString.split(',') );
	    
	        systemXREFString                    = System.Label.CADSPublish_AccountExternalCreateForSystemXREFList;
	        if ( systemXREFString != null )
	            accountExternalCreateXREFList.addAll ( systemXREFString.split(',') );
    
        // record type id
        try {
        	RecordType rt = [select id from recordtype 
        	                 where name='Company Maintained' and 
        	                       sobjectType = 'Address_vod__c' and 
        	                       isActive = True ];
            companyMaintainedRecordTypeId = rt.Id;        	                           
        	                 
        } catch (Exception e) {        
        }
    
    }
    
    public GENE_SFDC_FOUN_INT_PersonAcctController (
           GENE_SFDC_FOUN_INT_PersonAccount.RequestAccountFoundationItem requestItem) {    
     
        this.requestItem = requestItem;         
        init();
    }           
    
    void init() {   

        
    // split contributor xref & build sourceCodeToIdMap for acct,address
        sourceCodeToIdMap = new Map<String,List<String>>();    
        List<String> sourceCodeList                = requestItem.Account.ContributorSourceCodeList.split(',');
        List<String> sourceIdList                  = requestItem.Account.SourceEntityIdentifierList.split(',');
        List<String> recordEndDate                 = requestItem.Account.RecordEffectiveEndDateList.split(',');
                 
        for (integer i = 0; i< sourceCodeList.size(); i++) {
            String sourceSystemCode =  sourceCodeList[i].toUpperCase();
            List<String> sourceCodeIdList = sourceCodeToIdMap.get(sourceSystemCode);
            
            if ( sourceSystemCode.equalsIgnoreCase('SFDC') ) {                
                if ( sourceCodeIdList == null ) {
                    sourceCodeIdList = new List<String>();
                    sourceCodeToIdMap.put(sourceSystemCode,sourceCodeIdList);                 
                } 
                sourceCodeIdList.add ( sourceIdList[i] );                
            // only recordeffectiveenddate of null    
            } else if ( recordEndDate[i].equalsIgnoreCase('NULL') ) {                         		            
	            if ( sourceCodeIdList == null ) {
	                sourceCodeIdList = new List<String>();
	                sourceCodeToIdMap.put(sourceSystemCode,sourceCodeIdList);                 
	            } 
	            sourceCodeIdList.add ( sourceIdList[i] );	            
            }	            
        }
    
    // build account list & select account for update
        if ( sourceCodeToIdMap.get('SFDC') != null && 
             sourceCodeToIdMap.get('MDM')  != null) {
            acctList = [select id,ams_id_gne__c, mdmid_gne__c, 
                           mdmId_status_gne__c, 
                           firstname, lastname, middle_vod__c, 
                           gender_vod__c, suffix_vod__c, date_of_birth_gne__c,
                           mdm_update_date_gne__c, credentials_gne__c,
                           specialties_gne__c, phone, fax, salutation,
                           website, cell_phone_gne__c,
			               (select id, Name,city_vod__c,state_vod__c,zip_vod__c,zip_4_vod__c,country_vod__c,                             
			                address_line_2_vod__c ,address_line_3_gne__c,  
			                Active_flag_gne__c,mdm_address_id_gne__c,                      
			                Billing_vod__c,Business_vod__c,Hospital_gne__c,Mailing_vod__c,Office_gne__c,Shipping_vod__c,            
			                license_vod__c,license_status_vod__c,license_expiration_date_vod__c,  
			                Phone_vod__c,Phone_1_Ext_gne__c,Phone_2_vod__c,Phone_2_Ext_gne__c,Fax_vod__c,
			                primary_vod__c, recordTypeId  
			                from address_vod__r),
			                (select id, third_party_gne__c, third_party_id_gne__c, third_party_index_gne__c 
			                from account_external_id_gne__r )                   
                           from account where id in :sourceCodeToIdMap.get('SFDC')
                           order by createdDate asc];
                
            selectUpdateAccount();
        }            
    }

    // select account for update   
    void selectUpdateAccount () {
        String  mdmId           = sourceCodeToIdMap.get('MDM')[0];
        for (Account sfdcAcct : acctList ) {        
            if ( acct  == null )
                acct = sfdcAcct;
            if ( sfdcAcct.mdmid_gne__c == mdmId ) {
                acct = sfdcAcct;
                break;  
            }                                  
        }
    }

    String getProfessionalType (String profTypeList) {    
	    // 6/17/2009 change request by Willi H & CADS TEam
	    String profType =null;
	    if(profTypeList != null) {
	        String highestRole = 'default';                             
	        String tempRoles = profTypeList  + ',';
	        for (String role : GENE_SFDC_FOUN_INT_PersonAcctController.roleListByRank ) {                   
	            if ( tempRoles.contains(role + ',') ){                   
	                highestRole = role;break; // break on first highest role match
	            }
            } 
	        profType = GENE_SFDC_FOUN_INT_PersonAcctController.roleToProfessionalType.get(highestRole);
        }  
        return profType; 
	    // 6/17/2009 end            
    }
    
    // capture cads publish merge record i.e. 
    void insertCADSPublishAccountMergeRecords() {
        
        List<CADS_Merge_gne__c> cadsMerges =new List<CADS_Merge_gne__c>();
        for(Account acctMerge : acctList ){
            CADS_Merge_gne__c cadsMerge            = new CADS_Merge_gne__c();
            cadsMerge.Account_gne__c               = acctMerge.Id;
            cadsMerge.object_type_gne__c           = 'account';
            cadsMerge.cads_party_identifier_gne__c = requestItem.SourceSystemIdentifier;
            cadsMerge.esb_transaction_id_gne__c    = requestItem.Transaction_Id ;
        	cadsMerge.mdmid_gne__c                 = acctMerge.mdmid_gne__c;
        	cadsMerges.add ( cadsMerge);
        }
        
        if ( cadsMerges.size() >0 ){ 
	        Database.UpsertResult[] cadsMergeListSaveResult = Database.upsert( cadsMerges ); 
        }
            	
    }
    
    void createOrUpdateAccount () {
        
        /* Merge Mgmt integration in Foundational Rewrite - guruk
        if ( acctList.size() > 1) {            
            insertCADSPublishAccountMergeRecords();         
        }
        */

        // reset ams Id, mdm id & status 
        for (Account sfdcAcct : acctList ) {            
            sfdcAcct.mdmid_gne__c        = null;
            sfdcAcct.ams_id_gne__c       = null;
            sfdcAcct.mdmid_status_gne__c = 'Inactive';  
        }
                
        acct.AMS_Id_gne__c           = sourceCodeToIdMap.get('AMS') != null ? sourceCodeToIdMap.get('AMS')[0] : null;
        acct.MDMId_gne__c            = sourceCodeToIdMap.get('MDM')[0];
        acct.MDMId_status_gne__c     = requestItem.Account.MDMID_Status_gne; 
        
        acct.FirstName               = requestItem.Account.FirstName;
        acct.LastName                = requestItem.Account.LastName;
        acct.middle_vod__c           = requestItem.Account.Middle_gne;
        acct.gender_vod__c           = requestItem.Account.Gender_vod;
        acct.suffix_vod__c           = requestItem.Account.Suffix_gne;
        acct.date_of_birth_gne__c    = requestItem.Account.Date_of_Birth_gne;
        acct.mdm_update_date_gne__c  = System.now();
        acct.credentials_gne__c      = requestItem.Account.credentials_gne;
        acct.specialties_gne__c      = requestItem.Account.Specialties_gne;
        acct.professional_type_gne__c= getProfessionalType(requestItem.Account.Professional_Type_gne);
        
        // assign type 3 on create
        if ( acct.Id == null ) {
            acct.Phone                  = requestItem.Account.Phone;
            acct.Fax                    = requestItem.Account.Fax;
            acct.salutation             = requestItem.Account.Salutation;
            acct.website                = requestItem.Account.website;
            acct.cell_phone_gne__c      = requestItem.Account.cell_phone_gne;
        } else {
        // assign type 3 if null on update
            if ( acct.Phone == null ) 
                acct.Phone = requestItem.Account.Phone; 
            if ( acct.Fax   == null)  
                acct.Fax   = requestItem.Account.Fax; 
            if ( acct.salutation == null ) 
                acct.salutation = requestItem.Account.Salutation; 
            if ( acct.website    == null ) 
                acct.website    = requestItem.Account.website; 
            if ( acct.cell_phone_gne__c == null )
                acct.cell_phone_gne__c = requestItem.Account.cell_phone_gne;
        }             
             
        Database.UpsertResult[] acctListSaveResult = Database.upsert( acctList ); 
        
        Database.UpsertResult acctSaveResult       = Database.upsert( acct ); 
        if ( acctSaveResult.getId() == null ) {
            Database.Error dbError           = acctSaveResult.getErrors()[0];
            requestItem.Account.ErrorCode    = dbError.getStatusCode().Name(); 
            requestItem.Account.ErrorMessage = dbError.getMessage();        
        } else {
            
            System.debug ('Account created. Account Id ' + acctSaveResult.getId() );
            requestItem.Account.Id = acctSaveResult.getId();
            
            createOrUpdateAccountAddress();
            
            if ( GENE_SFDC_FOUN_INT_PersonAcctController.accountExternalCreateXREFList.size() > 0 ) 
                createOrUpdateAccountExternal();
        }                                       
    }
    
    void createOrUpdateAccountExternal () {
    	        
        List<Account_External_Id_gne__c> acctExternalList = new List<Account_External_Id_gne__c>();

        for (String sourceSystem : GENE_SFDC_FOUN_INT_PersonAcctController.accountExternalCreateXREFList ) {
            List<String> idList = sourceCodeToIdMap.get(sourceSystem);
            if ( idList != null ) {    	
                for (String thirdPartyId : idList) {	
                    Account_external_id_gne__c acctExternal = new Account_External_Id_Gne__c();
                    acctExternal.third_party_id_gne__c      = thirdPartyId;
                    acctExternal.third_party_gne__c         = sourceSystem;
                    acctExternal.third_party_index_gne__c   = sourceSystem + '_' + thirdPartyId; 
                    acctExternal.account_gne__c             = acct.Id;
                    acctExternal.mdmid_gne__c               = Double.valueOf(acct.mdmid_gne__c); 
                    acctExternalList.add ( acctExternal);	
                }
            }
        }

        Database.UpsertResult[] acctExternalListSaveResult 
                    = Database.upsert( acctExternalList, 
                                       Account_External_Id_gne__c.Third_party_index_gne__c );
                                       
        for ( Database.UpsertResult acctExternalResult : acctExternalListSaveResult ) {                                                                               
            if ( acctExternalResult.getId() == null ) {               
                Database.Error dbError           = acctExternalResult.getErrors()[0];
                requestItem.Account.ErrorCode    = dbError.getStatusCode().Name(); 
                requestItem.Account.ErrorMessage = dbError.getMessage();        
            }                                       
        }
    	
    }
    
    void createOrUpdateAccountAddress() {

        Map<id,address_vod__c> acctAddressList = new Map<Id,address_vod__c>
                                                   ( acct.address_vod__r);
                                                           	
        Map<String,Set<String>> mdmAddrId2SFDCAddrId = new Map<String,Set<String>>();

        Map<String,GENE_SFDC_FOUN_INT_PersonAccount.Address_stub> mdmAddrId2AddressStub = 
                       new Map<String, GENE_SFDC_FOUN_INT_PersonAccount.Address_stub>();        
        
        List<GENE_SFDC_FOUN_INT_PersonAccount.Address_stub> ignoreAddressPublishList = 
                     new List<GENE_SFDC_FOUN_INT_PersonAccount.Address_stub> ();
                    
        // mdm address Id - sfdc address Id map structure
        for ( GENE_SFDC_FOUN_INT_PersonAccount.Address_stub address : requestItem.Addresses) {            
            if ( address.mdm_address_id_gne != null) {            
	            
	            List<String> sourceCodeList                = address.ContributorSourceCodeList.split(',');
	            List<String> sourceIdList                  = address.SourceEntityIdentifierList.split(',');
	            
	            Set<String> sfdcAddrIdSet = new Set<String>();                 
	            for (integer i = 0; i< sourceCodeList.size(); i++) {
	                String sourceSystemCode =  sourceCodeList[i].toUpperCase();                  
	                if ( sourceSystemCode.equalsIgnoreCase('SFDC') )   
	                  sfdcAddrIdSet.add ( sourceIdList[i] );
	            }            
                
                // filter out repeating MDM address publish records
                // retain first NULL dated mdm address 
	                if ( mdmAddrId2SFDCAddrId.containsKey ( address.MDM_Address_Id_gne) ){	            	            
	                    
	                    GENE_SFDC_FOUN_INT_PersonAccount.Address_stub previousAddress 
	                        = mdmAddrId2AddressStub.get ( address.MDM_Address_Id_gne );
	
	                    if ( previousAddress.Active_Flag_gne ) { // previous open dated ignore current                        
	                        ignoreAddressPublishList.add(address);     	
	                    } else if ( address.Active_Flag_gne ) { // current is open dated ignore previous 
	                    	ignoreAddressPublishList.add(previousAddress); 
			                mdmAddrId2SFDCAddrId.put ( address.MDM_Address_ID_gne,sfdcAddrIdSet );
	                    } else {  // previous & current are end dated ignore current
	                    }
	                } else {
	                    mdmAddrId2SFDCAddrId.put  ( address.MDM_Address_ID_gne,sfdcAddrIdSet );
	                    mdmAddrId2AddressStub.put ( address.MDM_Address_ID_gne,address );
	                }                
            } 
        }                          

        // ignore - remove mdm address publish records from ignoreAddressPublishMap 
        for ( GENE_SFDC_FOUN_INT_PersonAccount.Address_stub address : ignoreAddressPublishList) {                        
            for (Integer i =0; i < requestItem.Addresses.size(); i++ ) {            	
            	if ( address == requestItem.Addresses[i]) {
            	   requestItem.Addresses.remove(i);
            	   break;	
            	}            	
            }            
        }
        
        List<Address_vod__c> updateAddrList = new List <Address_vod__c>();

        for ( GENE_SFDC_FOUN_INT_PersonAccount.Address_stub address : requestItem.Addresses) {            

            List<Address_vod__c> addrList = new List <Address_vod__c>();                        
            Set<String> sfdcAddrSet     = mdmAddrId2SFDCAddrId.get ( address.mdm_address_id_gne );
            
            // new address record
            if ( sfdcAddrSet.size() == 0 && address.Active_Flag_gne != null && address.Active_Flag_gne){
            	
            	// add new address based on configuration 
            	if ( sourceCodeToIdMap.get('SFDC') != null && 
            	     System.Label.CADSPublish_InsertAddressOnUpdate == 'FALSE') 
            	   continue; 
            	   
            	System.debug ('address record added for ' + address.mdm_address_id_gne);
                Address_vod__c addr = new Address_vod__c();
                addr.account_vod__c = requestItem.Account.Id;                                   
                addrList.add (addr);     
            	   
            } else {            
                Boolean bAcctAddressFound = false;                
                for (String addrId : sfdcAddrSet ) {
                    Address_vod__c addr = 	acctAddressList.get(addrId);
                    if(addr != null ) {
                        addrList.add( addr);
                        bAcctAddressFound = true;
                        System.debug ('update address record added for ' + address.mdm_address_id_gne);
                    }
                }
                
                // shouldn't be the case - check with mdm team on xref verification                
                if ( bAcctAddressFound ==false && address.active_flag_gne != null && address.Active_Flag_gne){
                	
	                // add new address based on configuration 
	                if ( sourceCodeToIdMap.get('SFDC') != null && 
	                     System.Label.CADSPublish_InsertAddressOnUpdate == 'FALSE') 
	                   continue; 
                         
	                Address_vod__c addr = new Address_vod__c();
	                addr.account_vod__c = requestItem.Account.Id;
	                addrList.add (addr);
	                               
                }
            }            
            
            assignAddressAttributes(address, addrList);
            updateAddrList.addAll (addrList);            
        }        
            
        System.debug ('Number of address objects for database upsert call is -> ' + updateAddrList.size() );
        if ( updateAddrList.size() > 0 ) {
	        Database.UpsertResult[] acctAddrListSaveResult = Database.upsert( updateAddrList );
	        for ( Database.UpsertResult addrUpsertResult : acctAddrListSaveResult ) {                                                                            	
		        if ( addrUpsertResult.getId() == null ) {	        	
		            Database.Error dbError           = addrUpsertResult.getErrors()[0];
		            requestItem.Account.ErrorCode    = dbError.getStatusCode().Name(); 
		            requestItem.Account.ErrorMessage = dbError.getMessage();        
		        } else {
		            // pending     
		        }                                       
	        }
        }        
    }
        
    void assignAddressAttributes (GENE_SFDC_FOUN_INT_PersonAccount.Address_stub address,
                                  List<Address_vod__c> addrList) {

        for (Address_vod__c addr : addrList ) {                    

            // type 1 overwrite
            addr.Name                      = address.Name;
            addr.city_vod__c               = address.city_vod;
            addr.state_vod__c              = address.state_vod;            
            addr.zip_vod__c                = address.zip_vod;
            addr.zip_4_vod__c              = address.zip_4_vod;
            addr.country_vod__c            = address.country_gne;                
            addr.Active_flag_gne__c        = address.active_flag_gne;
            addr.mdm_address_id_gne__c     = address.mdm_address_id_gne;
            
            //type 3 fields on create
            if ( addr.id == null ) {
            	if ( address.billing_vod != null )
                    addr.Billing_vod__c        = address.billing_vod;
                if ( address.business_vod != null)
                    addr.Business_vod__c       = address.business_vod;
                if ( address.hospital_gne !=null )                    
                    addr.Hospital_gne__c       = address.hospital_gne;
                if ( address.mailing_vod != null )
                    addr.Mailing_vod__c        = address.mailing_vod;
                if ( address.office_gne != null )                    
                    addr.Office_gne__c         = address.office_gne;
                if ( address.shipping_vod != null)                    
                    addr.Shipping_vod__c       = address.shipping_vod;
    
                addr.address_line_2_vod__c = address.address_line_2_vod;
                addr.address_line_3_gne__c = address.address_line_3_gne;
                        
                addr.license_vod__c        = address.license_vod; 
                addr.license_status_vod__c = address.license_status_vod;
                addr.license_expiration_date_vod__c = address.license_expiration_date_vod;
                
                addr.Phone_vod__c          = address.phone_vod;
                addr.Phone_1_Ext_gne__c    = address.phone_1_ext_gne;
                addr.Phone_2_vod__c        = address.phone_2_vod;
                addr.Phone_2_Ext_gne__c    = address.phone_2_ext_gne;
                addr.Fax_vod__c            = address.fax_vod;       
                addr.Inactive_vod__c       = true;
                
                if ( GENE_SFDC_FOUN_INT_PersonAcctController.companyMaintainedRecordTypeId != null )
                    addr.recordTypeId   = GENE_SFDC_FOUN_INT_PersonAcctController.companyMaintainedRecordTypeId;
                
                if( address.GOLD_RECORD_gne != null && address.GOLD_RECORD_gne == true){  
                    addr.Inactive_vod__c = false;
                } else 
                    addr.inactivate_reason_gne__c = System.Label.CADSPublish_NewAddressAdded; 
                                                        
            }else {                
            
                if (addr.Billing_vod__c == null && address.billing_vod !=null)
                    addr.Billing_vod__c = address.billing_vod;
                if (addr.business_vod__c == null && address.business_vod != null)
                    addr.business_vod__c=address.business_vod;
                if (addr.Hospital_gne__c == null && address.hospital_gne != null) 
                    addr.Hospital_gne__c       = address.hospital_gne;
                if (addr.Mailing_vod__c == null && address.mailing_vod != null)     
                    addr.Mailing_vod__c        = address.mailing_vod;                    
                if (addr.Office_gne__c == null && addr.office_gne__c != null ) 
                    addr.Office_gne__c         = address.office_gne;
                if (addr.Shipping_vod__c == null && address.shipping_vod != null ) 
                    addr.Shipping_vod__c       = address.shipping_vod;
    
                if (addr.address_line_2_vod__c ==null &&  address.address_line_2_vod != null) 
                    addr.address_line_2_vod__c = address.address_line_2_vod;
                if (addr.address_line_3_gne__c ==null&& address.address_line_3_gne != null) 
                    addr.address_line_3_gne__c = address.address_line_3_gne;
                        
                if (addr.license_vod__c == null && address.license_vod != null) {
                    addr.license_expiration_date_vod__c = address.license_expiration_date_vod;
                    addr.license_vod__c        = address.license_vod;
                    addr.license_status_vod__c = address.license_status_vod;
                }
                
                if (addr.Phone_vod__c ==null &&  address.phone_vod !=null ) { 
                    addr.Phone_vod__c          = address.phone_vod;
                    addr.Phone_1_Ext_gne__c    = address.phone_1_ext_gne;
                }                    
                if (addr.Phone_2_vod__c == null &&  address.phone_2_vod != null) {
                    addr.Phone_2_vod__c        = address.phone_2_vod;
                    addr.Phone_2_Ext_gne__c    = address.phone_2_ext_gne;
                }
                
                if (addr.Fax_vod__c == null && address.fax_vod !=null)        
                    addr.Fax_vod__c            = address.fax_vod;
                                    
                // type 1 override rule for type 3 attribute 
                // only for address line 2 & address line 3
                // implemented for change request # 
                if ( address.GOLD_RECORD_gne != null && address.GOLD_RECORD_gne==true ) {
                    addr.address_line_2_vod__c = address.address_line_2_vod;
                    addr.address_line_3_gne__c = address.address_line_3_gne;
                }                                
                
                if ( address.active_flag_gne != null && address.active_flag_gne == false ) {
                    addr.inactive_vod__c          = true;
                    addr.primary_vod__c           = false; // unset primary address flag 
                    addr.inactivate_reason_gne__c = System.Label.CADSPublish_AddressInactiveReason; 
                }
                
                if ( GENE_SFDC_FOUN_INT_PersonAcctController.companyMaintainedRecordTypeId != null )
                    addr.recordTypeId   = GENE_SFDC_FOUN_INT_PersonAcctController.companyMaintainedRecordTypeId;
            }               

            // enhancement to assign address line 2 to
            // address.name field when there is no street address
            // ie no physical address associated in MDM 
            if (  (addr.name == null || addr.name.length() ==0 ) &&  
                  addr.address_line_2_vod__c != null && 
                  addr.address_line_2_vod__c.length() >  0 )  {                
                addr.name                  = addr.address_line_2_vod__c;
                addr.address_line_2_vod__c = null;                     	
            }                 	
        }
                    
    }                                  	 
    
    
    // call create or update account function
    public void process() {

        if ( sourceCodeToIdMap.get('MDM') == null ) {    	
            requestItem.Account.ErrorCode    = 'SFA-I-2_E1'; 
            requestItem.Account.ErrorMessage = 'CADS Party Identifier:  ' + 
                                                requestItem.SourceSystemIdentifier + 
                                                ' - No Active MDM Id present. ' + 
                                                'Record not processed. ';        
            return ; 
        }
        
        if ( requestItem.Addresses == null ){
            requestItem.Account.ErrorCode    = 'SFA-I-2_E2'; 
            requestItem.Account.ErrorMessage = 'CADS Party Identifier:  ' + 
                                                requestItem.SourceSystemIdentifier + 
                                                ' - No Account Address present. ' + 
                                                'Record not processed. ';        
            return ; 
        }
        
    	
        //try {
            if ( (sourceCodeToIdMap.get('SFDC') == null)  || 
                 acctList.size() == 0 ) {            
                for(String systemCode : GENE_SFDC_FOUN_INT_PersonAcctController.accountCreateSystemXREFList ) {            
                    if ( sourceCodeToIdMap.get(SystemCode) != null ) {
                        acct = new Account();
                        System.debug ('account is being created...');
                        acctList.add ( acct );
                        break;  
                    }               
                }
            }            
            
            if ( acct != null && 
                 sourceCodeToIdMap.get('MDM') != null )
                createOrUpdateAccount();
             
        //}catch (Exception ex) {
        //    requestItem.Account.ErrorCode    = ex.getTypeName(); 
        //    requestItem.Account.ErrorMessage = ex.getMessage(); 
        //}
    }
}