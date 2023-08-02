/************************************************************
*  @author: Grzegorz Skaruz
*  Date: 2016-11-02
*  This is a test for GNE_SFA2_SBC_MDM_DAO class
*    
*  Modification History
*  Date        Name        Description
*  2017-06-23  LANIECKJ    make this class works ;)
*************************************************************/
@isTest

private class GNE_SFA2_SBC_MDM_DAO_Test {
    static String hpcResponse = '{'+
        '"tns:searchHCPResponse": {'+
            '"tns:prescriberDetails": {'+
                '"tns:prescriber": [{'+
                    '"tns:mdmId": "23128",'+
                    '"tns:partyId": "",'+
                    '"tns:firstName": "FIRSTNAME",'+
                    '"tns:middleName": "J",'+
                    '"tns:LastName": "LASTNAME",'+
                    '"tns:altrenateName": {'+
                        '"tns:value": ["FIRSTNAME  LASTNAME"]'+
                    '},'+
                    '"tns:externalID": {'+
                        '"tns:externalIDData": [{'+
                            '"tns:Type": "NPI",'+
                            '"tns:Value": "0001234566"'+
                        '}]'+
                    '},'+
                    '"tns:professionalType": {'+
                        '"tns:value": ["MD"]'+
                    '},'+
                    '"tns:partyCredential": {'+
                        '"tns:value": ["MD"]'+
                    '},'+
                    '"tns:partySpecialty": {'+
                        '"tns:value": ["ON",'+
                        '"IM"]'+
                    '},'+
    '				"tns:license": {'+
                        '"tns:licenseData": [{'+
                            '"tns:licenseNumber": "MD00001",'+
                            '"tns:issuedState": "DC",'+
                            '"tns:designation": "MD",'+
                            '"tns:adjExpirationDate": "2099-04-30",'+
                            '"tns:sampleability": "N"'+
                        '}]'+
                    '},'+
                    '"tns:status": "A",'+
                    '"tns:hcpAddress": {'+
                        '"tns:address": [{'+
                            '"tns:mdmAddressId": "10100000",'+
                            '"tns:partyLocId": "",'+
                            '"tns:streetAddress": "3001 SOMESTREET RD NW",'+
                            '"tns:unitType": "",'+
                            '"tns:unitValue": "",'+
                            '"tns:cityName": "WASHINGTON",'+
                            '"tns:stateCode": "DC",'+
                            '"tns:zipCode": "20007",'+
                            '"tns:isDefault": "Y",'+
                            '"tns:status": "A",'+
                            '"tns:latitude": "38.91",'+
                            '"tns:longitude": "-77.08"'+
                        '}]'+
                    '}'+
                '}],'+
                '"tns:message": "",'+
                '"tns:paginationResponse": {'+
                    '"tns:hasMoreRecords": "false",'+
                    '"tns:searchTokenID": "SVR1.2Z6N1",'+
                    '"tns:totalRecords": "1",'+
                    '"tns:recordStartNumber": "2",'+
                    '"tns:previousStartNumber": "1",'+
                    '"tns:recordsFetched": "1"'+
                '}'+
            '}'+
        '}}'+
    '}';

    @testSetup
    static void init() {
		insert new List<GNE_Foun_Misc_Config_Items_gne__c> {
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'Batch_FRM_Rep2TerritoryNotifyEmail', Configuration_Value_gne__c = 'example1@example.com'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'FRMAccountDCRLookup', Configuration_Value_gne__c = '{"obNa":"Account","fs":[{"n":"Name","s":"Y"},{"n":"Account_Type_gne__c"},{"n":"MDMID_gne__c"},{"n":"Name_and_Address_gne__c"}],"wc":"WHERE RecordType.Name=\'FRM_HCO\'","lim":"20"}'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'FRM_HCOOrgTypes', Configuration_Value_gne__c = 'Hospital - General Admin,Hospital - Specialty Group,Infusion/Injection Center,Physician Practice'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'AddrLocScheduleTime', Configuration_Value_gne__c = '*'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'AddrLocBatchSize', Configuration_Value_gne__c = '1000'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'SyncMdmEnabled', Configuration_Value_gne__c = 'Enabled'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'SBCMdmSiperianError:601', Configuration_Value_gne__c = 'SearchTimeout'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'DocLocationTypes', Configuration_Value_gne__c = 'Prison,Jail,Private,Transfer Facility,Pre-release,Psychiatric,SAFPF,Parole Confinement,Treatment Center'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'SubscribeNotfyEmail', Configuration_Value_gne__c = 'example2@example.com'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'SearchAccountLocalOnly', Configuration_Value_gne__c = 'Canada'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'SearchAccountShowNew', Configuration_Value_gne__c = 'ALL'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'SearchAccountMaxResults', Configuration_Value_gne__c = '500'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'RoleHierarchyNotfyEmail', Configuration_Value_gne__c = 'example3@example.com'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'CreateAccountExternalXREFList', Configuration_Value_gne__c = 'BOT,PW,TSG,CDNT,CREATIVE,RVWT,BISHOPMC,GNEEMGT,CC,[IND]CRO,[IND]SAPBW,MEDFORCE,HCOS,DDD_HCOS'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'CreateAccountXREFList', Configuration_Value_gne__c = 'BOT,TSG,PW,CC'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'CreateAddressExternalXREFList', Configuration_Value_gne__c = 'PW,TSG,CC,[IND]CRO,[IND]SAPBW,MEDFORCE'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'CreateAddressXREFList', Configuration_Value_gne__c = 'BOT'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'DefaultIndividualRoleCode', Configuration_Value_gne__c = 'HCPNPSCR'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'EnableUpdateOnMDMId', Configuration_Value_gne__c = 'TRUE'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'LicenseChangeRequestRecordTypeName', Configuration_Value_gne__c = 'License/Sampleability Info'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'LoggingLevel', Configuration_Value_gne__c = 'DEBUG'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'ValidSourcesXREFList', Configuration_Value_gne__c = 'BOT,TSG,PW,SFDC,AMS,MDM,CDNT,CREATIVE,RVWT,BISHOPMC,GNEEMGT,CC,CRO,SAPBW,NPI,MEDFORCE,HCOS'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'SearchShowMDMId', Configuration_Value_gne__c = 'MedAffairs,SFA,HCV,LWO,Sys,SYS,INFREQUENT'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'DefaultRecordOwner', Configuration_Value_gne__c = 'etladmin'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'FilterRulesINResults', Configuration_Value_gne__c = 'FALSE'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'SubscribeStagingAlignmentNotfyEmail', Configuration_Value_gne__c = 'example4@example.com'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'SBCHcpNoMDMIdType', Configuration_Value_gne__c = 'HCP US - No MDM ID'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'SBCHcoNoMDMIdType', Configuration_Value_gne__c = 'HCO US - No MDM ID'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'SBCDeltaModeEnabled', Configuration_Value_gne__c = 'TRUE'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'AccountAlignmentETLLastSynchDateTime', Configuration_Value_gne__c = ''),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'SBCMdmSiperianEndPoint', Configuration_Value_gne__c = 'http://commesb99-dev.gene.com/rest/GneCOMM_MDMLookup/MDM_Lookup/RestServices/'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'SBCMdmSiperianServiceNS', Configuration_Value_gne__c = 'tns'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'SBCGoogleMapURL', Configuration_Value_gne__c = 'http://maps.google.com/maps?f=q&hl=en&q={1}{0}{2}{0}{3}{0}{4}'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'SBCMdmSiperianPageSize', Configuration_Value_gne__c = '25'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'SBCMdmSiperianError:500', Configuration_Value_gne__c = 'ServiceNotAvailable'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'SBCMdmSiperianError:600', Configuration_Value_gne__c = 'ServiceNotAvailable'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'SBCMdmSiperianError:301', Configuration_Value_gne__c = 'Input values are empty'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'SBCMdmSiperianError:311', Configuration_Value_gne__c = 'MdmIdisMandatory'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'SBCMdmSiperianError:312', Configuration_Value_gne__c = 'MdmIdShouldBeNumber'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'SBCMdmSiperianError:313', Configuration_Value_gne__c = 'NoRecords'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'SBCMdmSiperianError:321', Configuration_Value_gne__c = 'LicenseAndStateareMandatory'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'SBCMdmSiperianError:322', Configuration_Value_gne__c = 'LicenseIsMandatory'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'SBCMdmSiperianError:323', Configuration_Value_gne__c = 'StateIsMandatory'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'SBCMdmSiperianError:324', Configuration_Value_gne__c = 'StateShouldBeTwoLetterWord'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'SBCMdmSiperianError:325', Configuration_Value_gne__c = 'StateIsInvalid'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'SBCMdmSiperianError:326', Configuration_Value_gne__c = 'NoRecords'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'SBCMdmSiperianError:331', Configuration_Value_gne__c = 'NameAndStateOrStreetAndStateCombinationIsMandatory'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'SBCMdmSiperianError:332', Configuration_Value_gne__c = 'ZipShouldBeInLength5'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'SBCMdmSiperianError:333', Configuration_Value_gne__c = 'ZipShouldBeNumber'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'SBCMdmSiperianError:334', Configuration_Value_gne__c = 'NoRecords'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'SBCMdmSiperianError:335', Configuration_Value_gne__c = 'ZipShouldBeInLength4Or5'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'SBCMdmSiperianError:336', Configuration_Value_gne__c = 'ZipShouldBeInLength3Or4Or5'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'SBCMdmSiperianError:337', Configuration_Value_gne__c = 'HcpProfileDetailsOrPaginationRequestIsMandatory'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'SBCMdmSiperianError:341', Configuration_Value_gne__c = 'OrganizationAndStateOrStreetAndStateCombinationIsMandatory'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'SBCMdmSiperianError:342', Configuration_Value_gne__c = 'HcoProfileDetailsOrPaginationRequestIsMandatory'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'SBCMdmSiperianError:400', Configuration_Value_gne__c = 'PaginationTokenIsExpired'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'SBCGeoCodeClientId', Configuration_Value_gne__c = '"QJHGgIv/aWVL55+JCpWzgpoSRKJR6iPTGP3ck9HXjNEtQIJxyfm7MrzHkY+a3N4A"'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'SBCGeoCodeKey', Configuration_Value_gne__c = '"PNA+g5SwYLeegMF4KjFl6+utsqsxQVG/EMzdy7spq9ivpqDA5j2YDuKUmBrp+A05"'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'SBCMdmSiperianError:502', Configuration_Value_gne__c = 'ServiceNotAvailable'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'MceLastProcessExecutionDateTime', Configuration_Value_gne__c = '42280,5394560185'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'MceDeltaLastScheduleJobId', Configuration_Value_gne__c = ''),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'MceDeltaScheduleTime', Configuration_Value_gne__c = '6'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'SBCMdmSiperianError:404', Configuration_Value_gne__c = 'ServiceNotAvailable'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'SBCMdmSiperianOtrPageSize', Configuration_Value_gne__c = '25'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'SubscribeMceNotfyEmail', Configuration_Value_gne__c = 'example5@example.com'),
			new GNE_Foun_Misc_Config_Items_gne__c(Name = 'SBCMdmSiperianIDetailPageSize', Configuration_Value_gne__c = '60')
		};    	

		insert new List<GNE_Foun_Role_Ranking_gne__c> {
			new GNE_Foun_Role_Ranking_gne__c(Name = 'MD', Account_Professional_Type_gne__c = 'Medical Doctor', Role_Rank_gne__c = 1),
			new GNE_Foun_Role_Ranking_gne__c(Name = 'NRSPSCR', Account_Professional_Type_gne__c = 'Nurse Practitioner', Role_Rank_gne__c = 2),
			new GNE_Foun_Role_Ranking_gne__c(Name = 'PA', Account_Professional_Type_gne__c = 'Physicians Assistant', Role_Rank_gne__c = 3),
			new GNE_Foun_Role_Ranking_gne__c(Name = 'PAPSCR', Account_Professional_Type_gne__c = 'Physicians Assistant', Role_Rank_gne__c = 4),
			new GNE_Foun_Role_Ranking_gne__c(Name = 'PSCR', Account_Professional_Type_gne__c = 'Health Care Professional - Prescribing', Role_Rank_gne__c = 5),
			new GNE_Foun_Role_Ranking_gne__c(Name = 'PHARM', Account_Professional_Type_gne__c = 'Pharmacist', Role_Rank_gne__c = 6),
			new GNE_Foun_Role_Ranking_gne__c(Name = 'OPTMT', Account_Professional_Type_gne__c = 'Optometrist', Role_Rank_gne__c = 7),
			new GNE_Foun_Role_Ranking_gne__c(Name = 'NRSNPSCR', Account_Professional_Type_gne__c = 'Nurse - Non-Prescribing', Role_Rank_gne__c = 8),
			new GNE_Foun_Role_Ranking_gne__c(Name = 'RSPRTRTHER', Account_Professional_Type_gne__c = 'Respiratory Therapist', Role_Rank_gne__c = 9),
			new GNE_Foun_Role_Ranking_gne__c(Name = 'THERA', Account_Professional_Type_gne__c = 'Physical Therapist', Role_Rank_gne__c = 10),
			new GNE_Foun_Role_Ranking_gne__c(Name = 'MEDASSTT', Account_Professional_Type_gne__c = 'Medical Assistant', Role_Rank_gne__c = 11),
			new GNE_Foun_Role_Ranking_gne__c(Name = 'HCPNPSCR', Account_Professional_Type_gne__c = 'Health Care Professional - Non-Prescribing', Role_Rank_gne__c = 12),
			new GNE_Foun_Role_Ranking_gne__c(Name = 'SOCWK', Account_Professional_Type_gne__c = 'Social Worker', Role_Rank_gne__c = 13),
			new GNE_Foun_Role_Ranking_gne__c(Name = 'MISC', Account_Professional_Type_gne__c = 'Miscellaneous', Role_Rank_gne__c = 14),
			new GNE_Foun_Role_Ranking_gne__c(Name = 'CLNCL', Account_Professional_Type_gne__c = 'Health Care Professional - Non-Prescribing', Role_Rank_gne__c = 15),
			new GNE_Foun_Role_Ranking_gne__c(Name = 'CTCT', Account_Professional_Type_gne__c = 'Health Care Professional - Non-Prescribing', Role_Rank_gne__c = 16),
			new GNE_Foun_Role_Ranking_gne__c(Name = 'CLNCTECH', Account_Professional_Type_gne__c = 'Clinical Technician', Role_Rank_gne__c = 98),
			new GNE_Foun_Role_Ranking_gne__c(Name = 'OTH', Account_Professional_Type_gne__c = 'Health Care Professional - Non-Prescribing', Role_Rank_gne__c = 99),
			new GNE_Foun_Role_Ranking_gne__c(Name = 'OFMGR', Account_Professional_Type_gne__c = 'Office/Billing Manager', Role_Rank_gne__c = 101),
			new GNE_Foun_Role_Ranking_gne__c(Name = 'PRCMGR', Account_Professional_Type_gne__c = 'Practice Manager', Role_Rank_gne__c = 102),
			new GNE_Foun_Role_Ranking_gne__c(Name = 'RMBRSMGR', Account_Professional_Type_gne__c = 'Reimbursement Manager', Role_Rank_gne__c = 103)
		};    	
    } 

    @isTest
    static void searchAccounts3params() {
        GNE_FRM_TestUtilities.CalloutMock mockImp = new GNE_FRM_TestUtilities.CalloutMock();
        mockImp.response = hpcResponse;
        Test.setMock(HttpCalloutMock.class.class, mockImp);

        GNE_SFA2_SBC_MDM_DAO mdmDAO = new GNE_SFA2_SBC_MDM_DAO();
        
        Test.startTest();
        	GNE_SFA2_SBC_DAO.DataWrapper responseData = mdmDAO.searchAccounts('accType', 'searchMode', new Map<String, String>{''=>''});
        Test.stopTest();

        System.assertEquals(1, responseData.rows.size());
        GNE_SFA2_SBC_DAO.AccountWrapper accWrapper = responseData.rows[0];
        System.assertEquals(1, accWrapper.addresses.size());
        GNE_SFA2_SBC_DAO.AddressWrapper addrWrapper = accWrapper.addresses[0];
        System.assertEquals('WASHINGTON', addrWrapper.cityName);
        System.assertEquals('10100000', addrWrapper.mdmAddressId);
    }
    
    @isTest
    static void searchAccounts4params() {
        GNE_FRM_TestUtilities.CalloutMock mockImp = new GNE_FRM_TestUtilities.CalloutMock();
        mockImp.response = hpcResponse;
        Test.setMock(HttpCalloutMock.class.class, mockImp);
        
        GNE_SFA2_SBC_MDM_DAO mdmDAO = new GNE_SFA2_SBC_MDM_DAO();
        
        Test.startTest();
        	GNE_SFA2_SBC_DAO.DataWrapper responseData = mdmDAO.searchAccounts('accType', 'searchMode', new Map<String, String>{''=>''}, new Set<String>{'testOnly'});
        Test.stopTest();
        
        System.assertEquals(1, responseData.rows.size());
        GNE_SFA2_SBC_DAO.AccountWrapper accWrapper = responseData.rows[0];
        System.assertEquals(1, accWrapper.addresses.size());
        GNE_SFA2_SBC_DAO.AddressWrapper addrWrapper = accWrapper.addresses[0];
        System.assertEquals('WASHINGTON', addrWrapper.cityName);
        System.assertEquals('10100000', addrWrapper.mdmAddressId);
    }
    
    @isTest
    static void searchAccountsPaginateReq() {
        GNE_FRM_TestUtilities.CalloutMock mockImp = new GNE_FRM_TestUtilities.CalloutMock();
        mockImp.response = hpcResponse;
        Test.setMock(HttpCalloutMock.class.class, mockImp);
        
        GNE_SFA2_SBC_MDM_DAO mdmDAO = new GNE_SFA2_SBC_MDM_DAO();
        
        Test.startTest();
        	GNE_SFA2_SBC_DAO.DataWrapper responseData = mdmDAO.searchAccounts('accType', 'searchMode', new GNE_SFA2_SBC_DAO.PaginationDataWrapper());
        Test.stopTest();

        System.assertEquals(1, responseData.rows.size());
        GNE_SFA2_SBC_DAO.AccountWrapper accWrapper = responseData.rows[0];
        System.assertEquals(1, accWrapper.addresses.size());
        GNE_SFA2_SBC_DAO.AddressWrapper addrWrapper = accWrapper.addresses[0];
        System.assertEquals('WASHINGTON', addrWrapper.cityName);
        System.assertEquals('10100000', addrWrapper.mdmAddressId);
    } 

    @isTest
    static void searchAccountsTeamCodes() {
        GNE_FRM_TestUtilities.CalloutMock mockImp = new GNE_FRM_TestUtilities.CalloutMock();
        mockImp.response = hpcResponse;
        Test.setMock(HttpCalloutMock.class.class, mockImp);
        
        GNE_SFA2_SBC_MDM_DAO mdmDAO = new GNE_SFA2_SBC_MDM_DAO();
        String adrressAsString = '';
        Test.startTest();
        	GNE_SFA2_SBC_DAO.DataWrapper responseData = mdmDAO.searchAccounts('accType', 'searchMode', new GNE_SFA2_SBC_DAO.PaginationDataWrapper(), new Set<String>{'teamCodes'});
        	GNE_SFA2_SBC_DAO.AccountWrapper accWrapper = responseData.rows[0];
        	GNE_SFA2_SBC_DAO.AddressWrapper addrWrapper = accWrapper.addresses[0];
        	adrressAsString = addrWrapper.getFullAddressName();
        Test.stopTest();
        
        System.assertEquals(1, responseData.rows.size());
        System.assertEquals(1, accWrapper.addresses.size());
        System.assertEquals('WASHINGTON', addrWrapper.cityName);
        System.assertEquals('10100000', addrWrapper.mdmAddressId);
        System.assertEquals('3001 SOMESTREET RD NW WASHINGTON DC 20007', adrressAsString);
    }
    
    @isTest
    static void searchAccountsSiperianServiceException() {
        GNE_FRM_TestUtilities.CalloutMock mockImp = new GNE_FRM_TestUtilities.CalloutMock();
        mockImp.response = '{"Error":{"code":"601","message":"Search is taking too long. Please refine your search criteria."}}';
        Test.setMock(HttpCalloutMock.class.class, mockImp);
        
        GNE_SFA2_SBC_MDM_DAO mdmDAO = new GNE_SFA2_SBC_MDM_DAO();
        Boolean isExceptionThrow = false;
        
        Test.startTest();
        try { 
            GNE_SFA2_SBC_DAO.DataWrapper responseData = mdmDAO.searchAccounts('accType', 'searchMode', new GNE_SFA2_SBC_DAO.PaginationDataWrapper(), new Set<String>{'teamCodes'});
        } catch ( GNE_SFA2_SBC_DAO.ServiceException ex){
            isExceptionThrow = true;
            System.AssertEquals('Search is taking too long. Please refine your search criteria.', ex.status);
            System.AssertEquals(601, ex.statusCode);
            System.AssertEquals('FindACCTYPEByMDMID', ex.restMethod);
        }
        Test.stopTest();
        System.assertEquals(true, isExceptionThrow);
    }
}