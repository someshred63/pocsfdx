@isTest
private class GNE_Test_Account_Search_Create {
  
    public static testMethod void test()
    {
        setupTestData();  
        
        Test.StartTest();
        Test_GNE_Account_Search_Create_Controller();
        Test.StopTest();
        
        Test_GNE_Account_Dao();
        Test_GNE_Account_Search_Dao();
        Test_GNE_Alternate_Name_Dao();
        
        Test_GNE_MDM_Siperian_Dao();
        Test_GNE_Territory_Dao();
        Test_GNE_MDM_Siperian_Service();
    }

    public static testMethod void testMDM()
    {
        String returnVal = '';
        GNE_MDM_Siperian_v6_ProxyService.MdmProxyPortType mdmSvc = new GNE_MDM_Siperian_v6_ProxyService.MdmProxyPortType(); 
        mdmSvc.Timeout_x = 120000;
        Integer maxResults = 1999;
        String sortOrder = 'RULE_NUMBER';
        String ruleSetName = 'Fuzzy_Match_Search_Addr_Org';
  
        GNE_Account_Pager pager = new GNE_Account_Pager();
        pager.currSearch.AccountType_gne__c = 'HCO';
        pager.currSearch.OrgName_gne__C = '';
        pager.currSearch.Street_gne__c = '';
        pager.currSearch.City_gne__c = 'San Francisco';
        pager.currSearch.State_gne__c = 'CA';
            
        if (pager.currSearch.AccountType_gne__c == 'HCP')
        {
            GNE_MDM_Siperian_v6_IndivAcctResponse.IndividualAccountItemType[] mdmAccts= mdmSvc.searchIndividualAccount(null,Pager.currSearch.OrgName_gne__c,null,Pager.currSearch.OrgName_gne__c,
                        Pager.currSearch.Street_gne__c,Pager.currSearch.State_gne__c,Pager.currSearch.City_gne__c,
                        Pager.currSearch.Zip_gne__c,Pager.currSearch.License_Number_gne__c,Pager.currSearch.License_State_gne__c,
                        maxResults,sortOrder,ruleSetName);
                        
            if (mdmAccts != null)
            {   
                System.debug(Logginglevel.INFO, 'mdmAccts.size()='+ mdmAccts.size());
            
                for(GNE_MDM_Siperian_v6_IndivAcctResponse.IndividualAccountItemType mdmAcct : mdmAccts)
                {
                    System.debug(LoggingLevel.INFO, 'rule='+ mdmAcct.ruleNumber+',' + mdmAcct.mdmId.trim());
                    if (returnVal > '') returnVal += ',';
                    if (mdmAcct.mdmId != null)  returnVal += '\'' + mdmAcct.mdmId.trim() + '\'';
                    
                }
            } else
            {
                System.debug(Logginglevel.INFO, 'mdmAccts is null');
            }                                                                                       
        } else
        {   
            
            GNE_MDM_Siperian_v6_OrgAcctResponse.OrganizationAccountItemType[] mdmAccts = mdmSvc.searchOrganizationAccount(Pager.currSearch.OrgName_gne__c,
                        Pager.currSearch.OrgName_gne__c,Pager.currSearch.Street_gne__c,
                        Pager.currSearch.City_gne__c,Pager.currSearch.State_gne__c,
                        Pager.currSearch.Zip_gne__c, maxResults,sortOrder,ruleSetName);
                
            if (mdmAccts != null)
            {
                System.debug(Logginglevel.INFO, 'mdmAccts.size()='+ mdmAccts.size());
                
                for(GNE_MDM_Siperian_v6_OrgAcctResponse.OrganizationAccountItemType mdmAcct : mdmAccts)
                {
                    System.debug(LoggingLevel.INFO, 'rule='+ mdmAcct.ruleNumber+',' + mdmAcct.mdmId.trim());
                    if (returnVal > '') returnVal += ',';
                    if (mdmAcct.mdmId != null)  returnVal += '\'' + mdmAcct.mdmId.trim() + '\'';
                }
            } else
            {
                System.debug(Logginglevel.INFO, 'mdmAccts is null');
            }
        }
    }       

    public static testMethod void updateOwner()
    {
        try 
        {
            Date launchDate = Date.newInstance(2011,2,4);
            
            System.debug('launchDate='+launchDate);
            
            User etlUser = [SELECT Id, Name FROM USER WHERE Name = 'ETL Admin'];
    
            if (etlUser != null)        
            {
                System.debug('etlUser.Id='+etlUser.Id);
                List <Account> acctList = [SELECT Id, Name, MdmId_gne__c, CreatedBy.Name, Owner.Name, CreatedDate
                                  FROM Account 
                                  WHERE Owner.Id <> :etlUser.Id
                                  AND Mdmid_gne__c <> null
                                  AND CreatedDate >= :launchDate
                                  order by Name, CreatedDate];
                
                if (acctList != null && acctList.size() > 0)
                {
                    System.debug('acctList.size() = '+ acctList.size());
                    for (Account row : acctList)
                    {
                        System.debug('acct='+ row.Name + ',' + row.Id + ',' + row.mdmid_gne__c + ',' + row.CreatedBy.Name + ',' + row.Owner.Name);
                        row.OwnerId = etlUser.Id;
                    }
                    //update acctList;
                } else
                {
                    System.debug('No Accounts found to update.');
                }
            } else
            {
                    System.debug('No ETL Admin user found.');
            }
        } catch (Exception e)   
        {
            System.debug('Exception caught. Message='+e);
        }
    }

    public static void Test_Stg_Queries()
    {
        String mdmIDs ='\'1027361\',\'1027802\',\'1033343\',\'1034931\',\'1151247\',\'1154810\',\'1158361\',\'116120\',\'116140\',\'116145\',\'116146\',\'116147\',\'1162036\',\'116828\',\'116893\',\'116894\',\'117377\',\'117390\',\'1174315\',\'117454\',\'117937\',\'117998\',\'118179\',\'118226\',\'11834153\',\'118491\',\'118492\',\'118501\',\'118505\',\'118512\',\'119018\',\'119020\',\'119784\',\'120139\',\'120315\',\'120403\',\'120498\',\'120593\',\'120727\',\'120831\',\'120853\',\'121290\',\'121375\',\'121412\',\'121418\',\'121498\',\'121643\',\'121683\',\'121692\',\'121703\',\'121715\',\'121725\',\'121779\',\'121972\',\'122000\',\'122165\',\'122230\',\'122265\',\'122466\',\'122676\',\'122754\',\'122883\',\'122948\',\'12294966\',\'123026\',\'123163\',\'123265\',\'123567\',\'123568\',\'124053\',\'124192\',\'124199\',\'124215\',\'124241\',\'124274\',\'124304\',\'124327\',\'124329\',\'124330\',\'124446\',\'124457\',\'124507\',\'124735\',\'124758\',\'124780\',\'124908\',\'138857\',\'139348\',\'139538\',\'141495\',\'141653\',\'141988\',\'142226\',\'142321\',\'142787\',\'142808\',\'142951\',\'143062\',\'143449\',\'143453\',\'143463\',\'143639\',\'143832\',\'143968\',\'144088\',\'144097\',\'144133\',\'144318\',\'144373\',\'1505564\',\'1541074\',\'161085\',\'164685\',\'170793\',\'1717701\',\'1717723\',\'172908\',\'1738398\',\'1738410\',\'174022\',\'174027\',\'174556\',\'1757479\',\'1757542\',\'175835\',\'176241\',\'1765240\',\'1769046\',\'1786482\',\'1798522\',\'1804180\',\'180885\',\'1818132\',\'1820057\',\'182548\',\'182553\',\'182558\',\'182563\',\'182731\',\'183537\',\'186430\',\'186629\',\'186638\',\'186649\',\'186863\',\'186864\',\'187122\',\'187126\',\'187128\',\'187314\',\'188175\',\'188404\',\'188624\',\'188625\',\'188628\',\'188641\',\'188653\',\'188666\',\'188847\',\'189086\',\'1894126\',\'1898749\',\'1899301\',\'1901193\',\'19349301\',\'19352032\',\'196998\',\'197305\',\'197316\',\'197704\',\'197712\',\'197768\',\'197993\',\'197994\',\'198005\',\'198388\',\'198541\',\'198857\',\'199277\',\'199299\',\'199327\',\'199936\',\'199973\',\'200094\',\'200150\',\'200161\',\'2113426\',\'2430568\',\'2439490\',\'2440514\',\'2449229\',\'2449392\',\'2449452\',\'2449457\',\'2485155\',\'2485170\',\'2485172\',\'2485186\',\'2486725\',\'2486830\',\'2490502\',\'2490973\',\'2491133\',\'2496656\',\'2496693\',\'2496695\',\'2499027\',\'2499504\',\'2499528\',\'2529162\',\'2530748\',\'2562479\',\'300518\',\'5593340\',\'5594753\',\'5595249\',\'5599006\',\'5631583\',\'5677469\',\'5703441\',\'5705046\',\'5720690\',\'5720804\',\'5721382\',\'5762017\',\'652176\',\'850897\',\'852319\',\'855706\',\'861022\',\'866055\',\'866265\',\'878605\',\'882893\',\'894422\',\'907040\',\'916521\',\'917702\',\'925292\',\'925661\',\'926652\',\'927341\',\'927467\',\'928093\',\'933182\',\'935054\',\'936131\',\'936874\',\'937413\',\'938086\',\'939556\',\'939614\',\'939790\',\'939969\',\'940224\',\'940226\'';
    }

    Public static void Test_GNE_Account_Search_Create_Controller()
    {
        GNE_Account_Search_Create_Controller cont = new GNE_Account_Search_Create_Controller();
        
        cont.setup();
        cont.Pager.clearCriteria();
        cont.acctType = 'HCP';
        cont.Pager.currSearch.LastName_gne__c = 'Jon';
        cont.Pager.currSearch.City_gne__c = 'Chicago';
        cont.Pager.currSearch.License_Number_gne__c = '123';
        cont.Pager.currSearch.License_State_gne__c = 'CA';
        cont.search();
        
        
        cont.Pager.getCurrCount();
        cont.pager.getRenderPager();
        cont.pager.getRenderNext();
        cont.pager.getDispRows();
        cont.pager.getFirstRow();
        cont.pager.getCurrentPage();
        cont.pager.getRenderPager();
        cont.pager.getRenderNext();
        cont.pager.getRenderPrevious();
        cont.pager.getRenderShowAll();
        cont.pager.getRenderShowPages();
        cont.pager.getRenderShowTot();
        cont.pager.getMaxPages();     
        cont.pager.setFirstRow(0);     
        cont.pager.setMaxPages(1000);     
        cont.pager.getLimit();
        cont.pager.shouldAddRow();
        
       
        cont.setup();
        cont.Pager.clearCriteria();
        cont.Pager.currSearch.AccountType_gne__c = 'HCP';
        cont.Pager.currSearch.LastName_gne__c = 'Johnson';
        cont.Pager.currSearch.State_gne__c = 'CA';
        cont.getProfTypes();
        cont.search();
        cont.cancel();
        cont.sortCity();
        cont.sortFirstName();
        cont.sortState();
        cont.sortZip();
        cont.createNew();
        cont.newAcct = new Account();
        cont.Pager.currSearch.FirstName_gne__c = 'Joe';
        cont.Pager.currSearch.LastName_gne__c = 'Fool';
        cont.acctType = 'HCP';
        cont.createNew();
        cont.acctType = 'HCO';
        cont.createNew();
        cont.Pager.currSearch.OrgName_gne__c = 'Fool';
        cont.createNew();
        
        cont.newAcct.Professional_Type_gne__c = 'Medical Doctor';
        cont.newAddr = new SFASearchStrings_gne__c();
        cont.newAddr.State_gne__c = 'CA';
        cont.saveNew();
        cont.getItems();
        cont.getTerritories();
        cont.getHasTerritories();
        cont.getHasSearched();
        cont.getShowResults();
        cont.hasSearchedForHCO = true;
        cont.getHasSearched();
        cont.hasSearchedForHCO = false;
        cont.hasSearchedForHCP = true;
        cont.getHasSearched();
        cont.pageTitle = 'SEARCH';
        cont.setup();
        cont.acctType = 'HCO';
        cont.hasSearchedForHCO = false;
        cont.search();
        cont.acctType = 'HCP';
        cont.hasSearchedForHCP = false;
        cont.search();
        
        cont.Pager.CurrSearch.FirstName_gne__c = '';
        cont.Pager.CurrSearch.LastName_gne__c = '';
        
        cont.getShowBothTypes();
        cont.getOrgTypes();
        
        cont.sIsPopup = 'true';
        cont.setup();
        
        cont.sAllowedType = 'HCO';
        cont.setup();
        cont.sAllowedType = 'HCP';
        cont.setup();
        cont.changeType();
    
        cont.sortType();
        cont.sortLicense();
        cont.hasSearchedForHCO = true;
        cont.getShowResults();
        
        cont.hasSearchedForHCO = true;
        cont.acctType = 'HCO';
        cont.getHasSearched();
        
       cont.Pager.clearCriteria();
        cont.search();
        
        cont.pageTitle = 'SEARCH';
        cont.setup();
        
        cont.Pager.clearCriteria();
        cont.acctType = 'HCP';
        cont.search();
        
        cont.pager.clearCriteria();

        cont.pager.currSearch.AccountType_gne__c = 'HCP';
        cont.search();
        
        cont.sAddrId = '1';
        cont.subscribeAcct();
        cont.sortStreet();
        cont.sortAka();
        cont.sortMdmId();
        cont.clear();
        
        //test subscribe
        List<SFASearchStrings_gne__c> resultList = new List<SFASearchStrings_gne__c>();
        SFASearchStrings_gne__c result = new SFASearchStrings_gne__c();
        
        //test with Account that doesn't exist in SFDC
        
        result.LastName_gne__c = 'Jones';
        result.FirstName_gne__c = 'John';
        result.MDMId_gne__c = '12345';
        result.Address_MDM_Id_gne__c = '12345';
        resultList.add(result);
        cont.pager.fullList = resultList;
        cont.sAddrId = result.Address_MDM_Id_gne__c;
        cont.acctType = 'HCP';
        cont.subscribeAcct();
        
        //test with Account that does exist in SFDC, but address doesn't
        result = new SFASearchStrings_gne__c();
        result.LastName_gne__c = 'Janeson';
        result.FirstName_gne__c = 'Jan';
        result.MDMId_gne__c = '12346';
        result.Address_MDM_Id_gne__c = '12346';
        result.Account_gne__c = [select id from account limit 1].Id;
        resultList.add(result);
        cont.pager.fullList = resultList;
        cont.sAddrId = result.Address_MDM_Id_gne__c;
        cont.subscribeAcct();
        
        //test with Account that does exist in SFDC and address does too
        result = new SFASearchStrings_gne__c();
        result.OrgName_gne__c = 'Memorial Hospital';
        result.MDMId_gne__c = '12348';
        result.Address_MDM_Id_gne__c = '12348';
        cont.acctType = 'HCO';
        resultList.add(result);
        cont.pager.fullList = resultList;
        cont.sAddrId = result.Address_MDM_Id_gne__c;
        cont.subscribeAcct();
        cont.allowedType = 'HCO'; 
        cont.getShowBothTypes();
        cont.profileName = 'LWO';
        cont.getHasLWOProfile();
        cont.profileName = 'Administrator';
        cont.getHasSysAdminProfile();
        
        
        SFASearchStrings_gne__c addr = new SFASearchStrings_gne__c();
        addr.FirstName_gne__c = 'Joe';
        addr.LastName_gne__c = 'Moop';  
        addr.Address_MDM_Id_gne__c = '12345';
        addr.City_gne__c = 'Chicago';
        addr.State_gne__c = 'IL';
        addr.Zip_gne__C = '60611';
        addr.Account_gne__c = [SELECT Id from Account limit 1].Id;
        cont.createNewAddress(addr); 
        
        cont.newAddr = new SFASearchStrings_gne__c();
        cont.newAddr.Account_gne__c = [SELECT Id from Account limit 1].Id;
        cont.acctType = 'HCP';
        cont.newAddr.LastName_gne__c = 'Joe';
        cont.newAddr.FirstName_gne__c = 'Moop';  
        cont.newAddr.Street_gne__c = '1 Main';
        cont.newAddr.State_gne__c = 'CA';
        cont.saveNewAddress();
        cont.setupHelp();
        cont.setupAddress();
        cont.redirectToAddressLayout();
        cont.acctType = 'HCP';
        cont.newAddr.LastName_gne__c = 'Joe';
        cont.newAddr.FirstName_gne__c = 'Moop';  
        cont.newAddr.Street_gne__c = '1 Main';
        cont.newAddr.State_gne__c = 'CA';
        cont.saveNew();
        cont.selectedProfType = 'Health Care Professional';
        cont.newAddr.Zip_gne__c = '9411';
        cont.saveNew();
        cont.newAddr.Zip_gne__c = '94110';
        cont.newAddr.Account_gne__c = [SELECT Id from Account limit 1].Id;
        cont.saveNew();
        cont.cancelAddress();
        cont.profiles = '';
        cont.profileName = 'SFA';
        cont.checkForRedirect();
        cont.profiles = 'ALL';
        cont.profileName = 'SFA';
        cont.checkForRedirect();
        cont.profiles = 'MedAffairs, SFA';
        cont.profileName = 'JOE';
        cont.checkForRedirect();
        cont.profileName = 'MedAffairs-SDFD-BLAH';
        cont.checkForRedirect();
        cont.setAccountType();
        
        GNE_Territory_Dao terrDao = new GNE_Territory_Dao();
        UserTerritory2Association ut = terrDao.setupTestData();
        cont.getTerritories();
        cont.selectedTerritory = ut.Id;
        cont.acctType = 'HCO';
        cont.newAddr.OrgName_gne__c = 'Joes Hospital';
        cont.newAddr.Street_gne__c = '1 Main';
        cont.newAddr.State_gne__c = 'CA';
        cont.selectedOrgType = 'Hospital';
        cont.newAddr.Zip_gne__c = '94110';
        cont.saveNew();
        cont.setAccountType();  
        
        cont.selectedOrgType = GNE_Account_Search_Create_Controller.NONE_SELECTED;
        cont.saveNew();
        cont.acctType = 'HCP';
        cont.selectedProfType = GNE_Account_Search_Create_Controller.NONE_SELECTED;
        cont.saveNew();
        
        cont.Pager.clearCriteria();
        cont.acctType = 'HCP';
        cont.Pager.currSearch.LastName_gne__c = 'J';
        cont.search();

        cont.Pager.clearCriteria();
        cont.acctType = 'HCO';
        cont.Pager.currSearch.OrgName_gne__c = 'J';
        cont.search();
        
        cont.hasSearchedForHCP = true;
        cont.acctType = 'HCP';
        cont.gethasSearched();
          
        
        cont.Pager.GetIsNameAddressSearch();
        cont.Pager.GetIsNameLicenseSearch();
        cont.Pager.GetIsNameLicenseAddressSearch();
        cont.Pager.getDispList();
        cont.Pager.CurrSearch = null;
        cont.Pager.setup();
        
        Exception ex = new GNE_Account_DAO.TooManyResultsException('DOH');
        cont.handleError('testError', 'testmethod', ex);       
        cont.handleError('testmethod', ex);
        cont.logMethod('methodname');
        GNE_Base_Controller.writeErrorLog('test','test','test', ex);
    }   
        
    
    public static void setupTestData()
    { 
        setupAccountTestData();
    
    }
    
    Public static void Test_GNE_Account_Dao()
    {       
        GNE_Account_Dao obj = new GNE_Account_Dao(true);
        GNE_Account_Pager pager = new GNE_Account_Pager(true);
            
        //test HCO Name only search
        pager.CurrSearch.OrgName_gne__c = 'TestName';
        pager.CurrSearch.AccountType_gne__c = 'HCO';
        obj.getByPager(pager);
        
        //test HCO Name plus address search
        pager.CurrSearch.State_gne__c = 'CA';
        obj.getByPager(pager);
        
        //test HCO Address only search
        pager.CurrSearch.OrgName_gne__c = null;
        pager.CurrSearch.City_gne__c = 'San Francisco';
        obj.getByPager(pager);
        
        
        pager.clearCriteria();
        pager.clearQueryFields();
        //test HCP license number search
        pager.CurrSearch.AccountType_gne__c = 'HCP';
        pager.CurrSearch.License_State_gne__c = 'CA';
        pager.CurrSearch.License_Number_gne__c = 'C12345';
        obj.getByPager(pager);
        
        //test HCP license number plus address search
        pager.CurrSearch.City_gne__c = 'San Fracisco';
        obj.getByPager(pager);
        
        //test HCP license number plus name search
        pager.CurrSearch.City_gne__c = null;
        pager.CurrSearch.LastName_gne__c = 'Jon';
        pager.CurrSearch.FirstName_gne__c = 'J';
        obj.getByPager(pager);
        
        //test HCP Name only search
        pager.clearCriteria();
        pager.clearQueryFields();
        pager.CurrSearch.AccountType_gne__c = 'HCP';
        pager.CurrSearch.LastName_gne__c = 'Jonaser';
        obj.getByPager(pager);
        
        //test HCP Address only search
        pager.clearCriteria();
        pager.clearQueryFields();
        pager.CurrSearch.LastName_gne__c = null;
        pager.CurrSearch.State_gne__c = 'CA';
        pager.CurrSearch.City_gne__c = 'Santa Carita';
        obj.getByPager(pager);
        
        //test HCP Name and Address search
        pager.CurrSearch.LastName_gne__c = 'Jonaser';
        pager.CurrSearch.Street_gne__c = 'Main';
        pager.currSearch.Zip_gne__c = '43212';
        obj.getByPager(pager);
        
        //test HCP Name with alternate name
        pager.clearCriteria();
        pager.clearQueryFields();
        pager.CurrSearch.LastName_gne__c = 'TestName';
        List <SFASearchStrings_gne__c> resultList = obj.getByPager(pager);
        
        Account newestAcct = obj.getByMDMId('DOH');
        System.assert(newestAcct == null);
        
        newestAcct = obj.getByMDMId('12346666666');
        //System.assert(newestAcct != null);
        
        Address_vod__c addr = obj.getByMDMAddressId('DOH');
        System.assert(addr == null);
        
        addr = obj.getByMDMAddressId('4321234');
        //System.assert(addr != null);
        
        pager.currSearch.AccountType_gne__c = 'HCP';
        obj.getAltNameWhere(pager);
        
        addr = [Select Id from Address_vod__c limit 1];
        String acctId = obj.getAccountIdForAddressId(addr.Id);
 
        Map <String, Address_vod__c> addrList = obj.getAddressesForAccountId(acctId);
    }
    
    public static String setupAccountTestData()
    {   
        Account newAcct = new Account();
        newAcct.Name = 'TestName';
        newAcct.MDMID_gne__c = '12346666666';
        newAcct.RecordTypeId = getRecordTypeId('Account', 'Hospital_vod');
        insert newAcct;
        
        Alternate_Name_gne__c newAltName = new Alternate_Name_gne__c();
        newAltName.Account_Name_gne__c = newAcct.Id;
        newAltName.Alternate_Name_gne__c = 'Test';
        newAltName.Status_gne__c = 'Active';
        insert newAltName;
        System.assert(newAltName.Id != null);
        return newAcct.Id;
        
        
        newAcct = new Account();
        newAcct.LastName = 'LastName';
        newAcct.FirstName = 'FirstName';
        newAcct.MDMID_gne__c = '12346666666';
        newAcct.RecordTypeId = getRecordTypeId('Account', 'Professisonal_vod');
        insert newAcct;
    
        Address_vod__c newAddr = new Address_vod__c();
        newAddr.Account_vod__c = newAcct.Id;
        newAddr.Name = '1234 Main St';
        newAddr.Address_line_2_vod__c = '1234 Main St';
        newAddr.MDM_Address_ID_gne__c = '4321234';  
        insert newAddr;
        System.assert(newAddr.Id !=  null);

        newAcct.Main_Address_gne__c = newAddr.Id;
        update newAcct;
        

        newAddr = new Address_vod__c();
        newAddr.Account_vod__c = newAcct.Id;
        newAddr.Name = '1234 Main St';
        newAddr.Address_line_2_vod__c = '222 Main St';
        newAddr.Zip_vod__c = '43212';
        newAddr.MDM_Address_ID_gne__c = '4321234';
        insert newAddr;
        System.assert(newAddr.Id !=  null);
        
        newAddr = new Address_vod__c();
        newAddr.Account_vod__c = newAcct.Id;
        newAddr.Name = '123 Market St';
        newAddr.Address_line_2_vod__c = '123 Market St';
        newAddr.Zip_vod__c = '43212';
        insert newAddr;
        System.assert(newAddr.Id !=  null);
        
        newAltName = new Alternate_Name_gne__c();
        newAltName.Account_Name_gne__c = newAcct.Id;
        newAltName.Alternate_Name_gne__c = 'TestName';
        newAltName.Status_gne__c = 'Active';
        insert newAltName;
        System.assert(newAltName.Id != null);
        return newAcct.Id;
        
        newAltName = new Alternate_Name_gne__c();
        newAltName.Account_Name_gne__c = newAcct.Id;
        newAltName.Alternate_Name_gne__c = 'Test';
        newAltName.Status_gne__c = 'Active';
        insert newAltName;
        System.assert(newAltName.Id != null);
        return newAcct.Id;
        
        
    }    
    
    public static void Test_GNE_Account_Search_Dao()
    {
        GNE_Account_Search_Dao obj = new GNE_Account_Search_Dao(true);
        obj.getByCurrentUser();
        
        GNE_Account_Pager pager = new GNE_Account_Pager(true);
        pager.currSearch.AccountType_gne__c = 'HCO';
        obj.getByPager(pager);
        
        obj.searchLocalOnly = false;
        obj.getByPager(pager);
    }
    
    public static String getRecordTypeId(String objNm, String nm)
    {
        return [select Id from RecordType where SobjectType = :objNm and Name = :nm].Id;
    }
    
    public static void Test_GNE_Alternate_Name_Dao()
    {
        GNE_Alternate_Name_Dao obj = new GNE_Alternate_Name_Dao(true);
        obj.getAccountsByAlternateName('Org test');     
    }
    
    public static void Test_GNE_MDM_Siperian_Dao()
    {
        GNE_MDM_Siperian_Dao obj = new GNE_MDM_Siperian_Dao(true);
        GNE_Account_Pager pager = new GNE_Account_Pager(true);
        pager.currSearch.AccountType_gne__c = 'HCO';
        pager.currSearch.OrgName_gne__c = 'org';
        obj.getSiperianMatches(pager);
        pager.currSearch.AccountType_gne__c = 'HCP';
        pager.currSearch.LastName_gne__c = 'Joe';
        obj.getSiperianMatches(pager);
    }
    
    public static void Test_GNE_Territory_Dao()
    {
        GNE_Territory_Dao obj = new GNE_Territory_Dao();
        obj.getByUser(UserInfo.getUserId());
        
        UserTerritory2Association ut = obj.setupTestData();
        Account acct = [select Id from Account limit 1];        
        Address_vod__c addr = [select Id from Address_vod__c limit 1];
        
        obj.alignAccountToTerritory(acct.Id, addr.Id, ut.Territory2Id);
    }
    
    public static void Test_GNE_MDM_Siperian_Service()
    {
        GNE_MDM_Siperian_Dao dao = new GNE_MDM_Siperian_Dao();
        GNE_Account_Pager pager = new GNE_Account_Pager();
        pager.currSearch.AccountType_gne__c = 'HCO';
        pager.currSearch.OrgName_gne__c = 'Test';
        dao.getSiperianMatches(pager);    
        pager.currSearch.AccountType_gne__c = 'HCP';
        pager.currSearch.LastName_gne__c = 'Test';
        dao.getSiperianMatches(pager);    
        GNE_MDM_Siperian_Service.MdmProxyPortType mdmSvc = new GNE_MDM_Siperian_Service.MdmProxyPortType(); 
        mdmSvc.Timeout_x = 60000;
        mdmSvc.getVersion('1');
    }
    
    public static void Test_Base_Classes()  
    {
        GNE_Alternate_Name_Dao dao = new GNE_Alternate_Name_Dao(true);
        GNE_Base_Pager pager = new GNE_Account_Pager(true);
        GNE_Account_Dao.AccountException ex = new GNE_Account_Dao.AccountException();
        dao.handleError('test', ex);
        dao.log('test');
        Account acct = new Account();
        dao.logSaved(acct);      

    }
   
    public static final String PARTY_EXTERNAL_ID = 'someid';
    public static final String XREF_ID_BOT = 'botid';
    public static final String XREF_ID_PW = 'pwid';
    public static final String XREF_ID_SFDC = 'sfdcid';
    public static final String XREF_ID_MDM = 'mdmid';
    public static final String XREF_ID_AMS = 'amsid';
    public static final String XREF_ID_LOCATION = 'locationid';
    public static final String XREF_ID_LOCATION_PW = 'locationidpw';
    public static final String PARTY_TYPE_INDIVIDUAL = 'IND';
    public static final String PARTY_TYPE_ORGANIZATION = 'ORG';
    public static final String GENERATIONAL_SUFIX = 'gsufix';
    public static final String PROFESSIONAL_SUFIX = 'psufix';
    public static final String GENDER_VALUE = 'Testgender';
    public static final String INDIVIDUAL_SALUTATION = 'Mr.';
    public static final String INDIVIDUAL_FIRST_NAME = 'Obi';
    public static final String INDIVIDUAL_MIDDLE_NAME = 'One';
    public static final String INDIVIDUAL_LAST_NAME = 'Kenobi';
    public static final DateTime INDIVIDUAL_BIRTH_DATE = DateTime.newInstance(1975, 2, 3);
    public static final String INDIVIDUAL_BIRTH_DATE_STR = '1975-2-3';
    public static final String LOCATION_EXTERNAL_ID = 'externalptylocid';
    public static final String LOCATION_PHYSICAL_ADDR_ID = 'phyaddrid';
    public static final String PHYSICAL_ADDR_PRIAMRY = 'PRIM ADDRESS';
    public static final String PHYSICAL_ADDR_CITY = 'Poznan';
    public static final String PHYSICAL_ADDR_NAME = 'physicaladdr';
    public static final String CANNONICAL_TYPE_PARTY = 'PTY';
    public static final String CANNONICAL_TYPE_LOCATION = 'PTYLOC';
    public static final String CONTRIBUTOR_SOURCE_BOT = 'BOT';
    public static final String CONTRIBUTOR_SOURCE_PW = 'PW';
    public static final String CONTRIBUTOR_SOURCE_SFDC = 'SFDC';
    public static final String CONTRIBUTOR_SOURCE_MDM = 'MDM';
    public static final String CONTRIBUTOR_SOURCE_AMS = 'AMS';
    public static final String POSTAL_AREA_NAME = 'postalarea';
    public static final String POSTAL_AREA_CODE = 'pstl';
    public static final String PROFESSIONAL_SUFIX_TYPE_DO = 'DO';
    public static final String PROFESSIONAL_SUFIX_TYPE_MD = 'MD';
    public static final String ACCOUNT_CREDENTIALS = 'DO;MD';
    public static final String ROLE_NURSE_PRACTITIONER = 'NRSPSCR';
    public static final String ROLE_PHARMACIST = 'PHARM';
    public static final String ROLE_SOCIAL_WORKER = 'SOCWK';
    public static final String ROLE_MEDICAL_DOCTOR = 'MD';
    public static final String SPECIALITY_1 = 'SPEC_1';
    public static final String SPECIALITY_2 = 'SPEC_2';
    public static final String COMM_CHANNEL_TYPE_CELL = 'CELL_PHN';
    public static final String COMM_CHANNEL_TYPE_URL = 'URL';
    public static final String COMM_CHANNEL_TYPE_PHONE = 'BUS_PHN';
    public static final String COMM_CHANNEL_TYPE_FAX = 'FAX';
    public static final String CELL_PHONE = '+48 345 432 111';
    public static final String PHONE = '+48 14 728 42 91';
    public static final String PHONE2 = '1234567890';
    public static final String PHONE3 = '12345';
    public static final String FAX_NUM = '+48 11 123 45 67';
    public static final String STATE_PROVINCE = 'state/province';
    public static final String COUNTRY = 'POLAND';
    public static final String COUNTRY_DEFAULT = 'UNITED STATES';
    public static final String COUNTRY_CODE = 'PL';
    public static final String USAGE_TYPE_GOLD = 'AMS_GOLD';
    public static final String USAGE_TYPE_SHIP = 'SHIP';
    public static final String USAGE_TYPE_MAIL = 'MAIL';
    public static final String USAGE_TYPE_BILL = 'BILL';
    public static final String USAGE_TYPE_BUS = 'BUS';
    public static final String USAGE_TYPE_OFC = 'OFC';
    public static final String USAGE_TYPE_HOSP = 'HOSP';
    public static final String SECONDARY_ADDRESS_UNIT_TYPE_CODE = 'sautc';
    public static final String SECONDARY_ADDRESS_VALUE = 'sav';
    public static final String BLDG_DESC = 'BldgDesc';
    public static final String BLDG_FL_DESC = 'BldgFlDesc';
    public static final String ORGANIZATION_NAME = 'orgname';
    public static final String ORGANIZATION_ROLE_TYPE_HBO = 'HBO';
    public static final String ORGANIZATION_ROLE_TYPE_HOSP = 'HOSP';
    public static final String ORGANIZATION_WEBSITE = 'http://website.com';
    public static final String LICENSE_NUMBER = 'sdjkfhlk513l452345';
    public static final String LICENSE_NUMBER2 = 'sdjkfhlk513l4523452';
    public static final String LICENSE_NUMBER3 = 'sdjkfhlk513l4523453';
    public static final String DESIGNATION_DESCR = 'designation descr';
    public static final String DESIGNATION_CODE = 'designation code'; 
    
    public void testMDMHCP()
    {
        String returnVal = '';
        GNE_MDM_Siperian_Service.MdmProxyPortType mdmSvc = new GNE_MDM_Siperian_Service.MdmProxyPortType(); 
        mdmSvc.Timeout_x = 60000;

        GNE_Account_Pager Pager = new GNE_Account_Pager();
        Pager.currSearch.AccountType_gne__c = 'HCP';
        Pager.currSearch.LastName_gne__c = 'Jackson';
        //Pager.currSearch.FirstName_gne__c = 'Joe';
        //Pager.currSearch.OrgName_gne__c = 'Mercy';
        Pager.currSearch.State_gne__c = 'WI';
        //Pager.currSearch.License_Number_gne__c = '1234';
        GNE_MDM_Siperian_IndvAcctRes.IndividualAccountItemType[] mdmAccts;
        mdmAccts= mdmSvc.searchIndividualAccount(
            Pager.currSearch.FirstName_gne__c,
            Pager.currSearch.LastName_gne__c,
            Pager.currSearch.FirstName_gne__c,
            Pager.currSearch.LastName_gne__c,
            Pager.currSearch.Street_gne__c,
            Pager.currSearch.City_gne__c,
            Pager.currSearch.State_gne__c,
            Pager.currSearch.Zip_gne__c,
            Pager.currSearch.License_Number_gne__c,
            Pager.currSearch.License_State_gne__c,
            pager.getMaxResults());

        //System.debug('mdmAccts='+mdmAccts);               

        if(mdmAccts!=null)
        {               
            System.debug(Logginglevel.INFO, 'mdmAccts.size()='+ mdmAccts.size());
        
            for(GNE_MDM_Siperian_IndvAcctRes.IndividualAccountItemType mdmAcct : mdmAccts)
            {
                if (returnVal > '') returnVal += ',';
                if (mdmAcct.mdmId != null)  returnVal += '\'' + mdmAcct.mdmId.trim() + '\'';
            }
        } else
        {
            System.debug(Logginglevel.INFO, 'mdmAccts is null');
        }
        System.debug('returnVal='+returnVal);                                                           
    }
}