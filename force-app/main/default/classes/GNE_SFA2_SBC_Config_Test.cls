/************************************************************
*  @author: Grzegorz Skaruz
*  Date: 2016-11-02
*  This is a test for GNE_SFA2_SBC_Config class
*    
*  Modification History
*  Date        Name        Description
*************************************************************/
@isTest

private class GNE_SFA2_SBC_Config_Test {

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
    
    static testMethod void testGetConfigItemByString() {
    	System.AssertEquals(GNE_SFA2_SBC_Config.getConfigItem('SBCMdmSiperianEndPoint'), 'http://commesb99-dev.gene.com/rest/GneCOMM_MDMLookup/MDM_Lookup/RestServices/');
    	System.AssertEquals(GNE_SFA2_SBC_Config.getConfigItem('DefaultRecordOwner'), 'etladmin');
    	System.AssertEquals(GNE_SFA2_SBC_Config.getConfigItem('DefaultIndividualRoleCode'), 'HCPNPSCR');
    	System.AssertEquals(GNE_SFA2_SBC_Config.getConfigItem('SBCMdmSiperianServiceNS'), 'tns');
    	System.AssertEquals(GNE_SFA2_SBC_Config.getConfigItem('SBCGoogleMapURL'), 'http://maps.google.com/maps?f=q&hl=en&q={1}{0}{2}{0}{3}{0}{4}');
    	System.AssertEquals(GNE_SFA2_SBC_Config.getConfigItem('SBCMdmSiperianPageSize'), '25');
    	System.AssertEquals(GNE_SFA2_SBC_Config.getConfigItem('SBCMdmSiperianOtrPageSize'), '25');
    	System.AssertEquals(GNE_SFA2_SBC_Config.getConfigItem('SBCMdmSiperianIDetailPageSize'), '60');
    	System.AssertEquals(GNE_SFA2_SBC_Config.getConfigItem('SBCGeoCodeClientId'), '"QJHGgIv/aWVL55+JCpWzgpoSRKJR6iPTGP3ck9HXjNEtQIJxyfm7MrzHkY+a3N4A"');
    	System.AssertEquals(GNE_SFA2_SBC_Config.getConfigItem('SBCGeoCodeKey'), '"PNA+g5SwYLeegMF4KjFl6+utsqsxQVG/EMzdy7spq9ivpqDA5j2YDuKUmBrp+A05"');
    	System.AssertEquals(GNE_SFA2_SBC_Config.getConfigItem('FRM_HCOOrgTypes'), 'Hospital - General Admin,Hospital - Specialty Group,Infusion/Injection Center,Physician Practice');
    }

    static testMethod void testGetConfigItemByEnum() {
    	GNE_SFA2_SBC_Config.ConfigItems SBCMdmSiperianEndPoint = GNE_SFA2_SBC_Config.ConfigItems.SBCMdmSiperianEndPoint;
    	System.AssertEquals(GNE_SFA2_SBC_Config.getConfigItem(GNE_SFA2_SBC_Config.ConfigItems.SBCMdmSiperianEndPoint), 'http://commesb99-dev.gene.com/rest/GneCOMM_MDMLookup/MDM_Lookup/RestServices/');
    	System.AssertEquals(GNE_SFA2_SBC_Config.getConfigItem(GNE_SFA2_SBC_Config.ConfigItems.DefaultRecordOwner), 'etladmin');
    	System.AssertEquals(GNE_SFA2_SBC_Config.getConfigItem(GNE_SFA2_SBC_Config.ConfigItems.DefaultIndividualRoleCode), 'HCPNPSCR');
    	System.AssertEquals(GNE_SFA2_SBC_Config.getConfigItem(GNE_SFA2_SBC_Config.ConfigItems.SBCMdmSiperianServiceNS), 'tns');
    	System.AssertEquals(GNE_SFA2_SBC_Config.getConfigItem(GNE_SFA2_SBC_Config.ConfigItems.SBCGoogleMapURL), 'http://maps.google.com/maps?f=q&hl=en&q={1}{0}{2}{0}{3}{0}{4}');
    	System.AssertEquals(GNE_SFA2_SBC_Config.getConfigItem(GNE_SFA2_SBC_Config.ConfigItems.SBCMdmSiperianPageSize), '25');
    	System.AssertEquals(GNE_SFA2_SBC_Config.getConfigItem(GNE_SFA2_SBC_Config.ConfigItems.SBCMdmSiperianOtrPageSize), '25');
    	System.AssertEquals(GNE_SFA2_SBC_Config.getConfigItem(GNE_SFA2_SBC_Config.ConfigItems.SBCMdmSiperianIDetailPageSize), '60');
    	System.AssertEquals(GNE_SFA2_SBC_Config.getConfigItem(GNE_SFA2_SBC_Config.ConfigItems.SBCGeoCodeClientId), '"QJHGgIv/aWVL55+JCpWzgpoSRKJR6iPTGP3ck9HXjNEtQIJxyfm7MrzHkY+a3N4A"');
    	System.AssertEquals(GNE_SFA2_SBC_Config.getConfigItem(GNE_SFA2_SBC_Config.ConfigItems.SBCGeoCodeKey), '"PNA+g5SwYLeegMF4KjFl6+utsqsxQVG/EMzdy7spq9ivpqDA5j2YDuKUmBrp+A05"');
    	System.AssertEquals(GNE_SFA2_SBC_Config.getConfigItem(GNE_SFA2_SBC_Config.ConfigItems.FRM_HCOOrgTypes), 'Hospital - General Admin,Hospital - Specialty Group,Infusion/Injection Center,Physician Practice');
    }
    
    static testMethod void testGetMdmKnowErrorName() {
    	System.AssertEquals(GNE_SFA2_SBC_Config.getMdmKnowErrorName(301), 'Input values are empty');
    	System.AssertEquals(GNE_SFA2_SBC_Config.getMdmKnowErrorName(311), 'MdmIdisMandatory');
    	System.AssertEquals(GNE_SFA2_SBC_Config.getMdmKnowErrorName(312), 'MdmIdShouldBeNumber');
    	System.AssertEquals(GNE_SFA2_SBC_Config.getMdmKnowErrorName(313), 'NoRecords');
    	System.AssertEquals(GNE_SFA2_SBC_Config.getMdmKnowErrorName(321), 'LicenseAndStateareMandatory');
    	System.AssertEquals(GNE_SFA2_SBC_Config.getMdmKnowErrorName(322), 'LicenseIsMandatory');
    	System.AssertEquals(GNE_SFA2_SBC_Config.getMdmKnowErrorName(323), 'StateIsMandatory');
    	System.AssertEquals(GNE_SFA2_SBC_Config.getMdmKnowErrorName(324), 'StateShouldBeTwoLetterWord');
    	System.AssertEquals(GNE_SFA2_SBC_Config.getMdmKnowErrorName(325), 'StateIsInvalid');
    	System.AssertEquals(GNE_SFA2_SBC_Config.getMdmKnowErrorName(326), 'NoRecords');
    	System.AssertEquals(GNE_SFA2_SBC_Config.getMdmKnowErrorName(331), 'NameAndStateOrStreetAndStateCombinationIsMandatory');
    	System.AssertEquals(GNE_SFA2_SBC_Config.getMdmKnowErrorName(332), 'ZipShouldBeInLength5');
    	System.AssertEquals(GNE_SFA2_SBC_Config.getMdmKnowErrorName(333), 'ZipShouldBeNumber');
    	System.AssertEquals(GNE_SFA2_SBC_Config.getMdmKnowErrorName(334), 'NoRecords');
    	System.AssertEquals(GNE_SFA2_SBC_Config.getMdmKnowErrorName(335), 'ZipShouldBeInLength4Or5');
    	System.AssertEquals(GNE_SFA2_SBC_Config.getMdmKnowErrorName(336), 'ZipShouldBeInLength3Or4Or5');
    	System.AssertEquals(GNE_SFA2_SBC_Config.getMdmKnowErrorName(337), 'HcpProfileDetailsOrPaginationRequestIsMandatory');
    	System.AssertEquals(GNE_SFA2_SBC_Config.getMdmKnowErrorName(341), 'OrganizationAndStateOrStreetAndStateCombinationIsMandatory');
    	System.AssertEquals(GNE_SFA2_SBC_Config.getMdmKnowErrorName(342), 'HcoProfileDetailsOrPaginationRequestIsMandatory');
    	System.AssertEquals(GNE_SFA2_SBC_Config.getMdmKnowErrorName(400), 'PaginationTokenIsExpired');
    	System.AssertEquals(GNE_SFA2_SBC_Config.getMdmKnowErrorName(404), 'ServiceNotAvailable');
    	System.AssertEquals(GNE_SFA2_SBC_Config.getMdmKnowErrorName(500), 'ServiceNotAvailable');
    	System.AssertEquals(GNE_SFA2_SBC_Config.getMdmKnowErrorName(502), 'ServiceNotAvailable');
    	System.AssertEquals(GNE_SFA2_SBC_Config.getMdmKnowErrorName(600), 'ServiceNotAvailable');
    	System.AssertEquals(GNE_SFA2_SBC_Config.getMdmKnowErrorName(601), 'SearchTimeout');
    }    

    static testMethod void testGetMdmKnowErrorMessage() {
    	System.AssertEquals(GNE_SFA2_SBC_Config.getMdmKnowErrorMessage(404), 'The account search is currently not available. You can use the Create New Account button to add an account to your list.');
    	System.AssertEquals(GNE_SFA2_SBC_Config.getMdmKnowErrorMessage(500), 'The account search is currently not available. You can use the Create New Account button to add an account to your list.');
    	System.AssertEquals(GNE_SFA2_SBC_Config.getMdmKnowErrorMessage(502), 'The account search is currently not available. You can use the Create New Account button to add an account to your list.');
    	System.AssertEquals(GNE_SFA2_SBC_Config.getMdmKnowErrorMessage(600), 'The account search is currently not available. You can use the Create New Account button to add an account to your list.');
    	System.AssertEquals(GNE_SFA2_SBC_Config.getMdmKnowErrorMessage(400), 'Unable to load more records. Please search again.');
    }

    static testMethod void testGetHcpProfTypes() {
    	List<String> HcpProfTypes = GNE_SFA2_SBC_Config.getHcpProfTypes();
    	System.AssertEquals(HcpProfTypes.size(), 17);
    	System.AssertEquals(HcpProfTypes.get(0), 'Clinical Technician');
    	System.AssertEquals(HcpProfTypes.get(1), 'Health Care Professional - Non-Prescribing');
    	System.AssertEquals(HcpProfTypes.get(2), 'Health Care Professional - Prescribing');
    	System.AssertEquals(HcpProfTypes.get(3), 'Medical Assistant');
    	System.AssertEquals(HcpProfTypes.get(4), 'Medical Doctor');
    	System.AssertEquals(HcpProfTypes.get(5), 'Miscellaneous');
    	System.AssertEquals(HcpProfTypes.get(6), 'Nurse - Non-Prescribing');
    	System.AssertEquals(HcpProfTypes.get(7), 'Nurse Practitioner');
    	System.AssertEquals(HcpProfTypes.get(8), 'Office/Billing Manager');
    	System.AssertEquals(HcpProfTypes.get(9), 'Optometrist');
    	System.AssertEquals(HcpProfTypes.get(10), 'Pharmacist');
    	System.AssertEquals(HcpProfTypes.get(11), 'Physical Therapist');
    	System.AssertEquals(HcpProfTypes.get(12), 'Physicians Assistant');
    	System.AssertEquals(HcpProfTypes.get(13), 'Practice Manager');
    	System.AssertEquals(HcpProfTypes.get(14), 'Reimbursement Manager');
    	System.AssertEquals(HcpProfTypes.get(15), 'Respiratory Therapist');
    	System.AssertEquals(HcpProfTypes.get(16), 'Social Worker'); 	
    }

    static testMethod void testGetHcpProfTypesSortedByRank() {
		Test.startTest();
	    	Set<String> roles = new set<String>{'MD', 'PA', 'OPTMT'};
	    	List<String> HcpProfTypesSortedByRank = GNE_SFA2_SBC_Config.getHcpProfTypesSortedByRank(roles);
		Test.stopTest();
    	System.AssertEquals(HcpProfTypesSortedByRank.size(), 3);
    	System.AssertEquals(HcpProfTypesSortedByRank.get(0), 'Medical Doctor');
    	System.AssertEquals(HcpProfTypesSortedByRank.get(1), 'Physicians Assistant');
    	System.AssertEquals(HcpProfTypesSortedByRank.get(2), 'Optometrist');
    }    
    
    static testMethod void testGetHcpProfTypesSortedByRankEmpty() {
		Test.startTest();
	    	List<String> HcpProfTypesSortedByRank = GNE_SFA2_SBC_Config.getHcpProfTypesSortedByRank(new set<String>{});
		Test.stopTest();
    	System.AssertEquals(HcpProfTypesSortedByRank.size(), 1);
    	System.AssertEquals(HcpProfTypesSortedByRank.get(0), 'Health Care Professional - Non-Prescribing');
    }    
}