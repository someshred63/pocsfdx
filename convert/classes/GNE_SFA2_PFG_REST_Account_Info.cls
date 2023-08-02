@RestResource(urlMapping='/sfa2_account_info_outbound_R1/*')
global with sharing class GNE_SFA2_PFG_REST_Account_Info extends GNE_SFA2_PFG_REST_Base {
    
    global class ResultSet extends GNE_SFA2_PFG_REST_Base.ResultSet {
        public List<AccountInfo> records = new List<AccountInfo>();
        public Boolean hasMore = false;
        public String paramsIfQueryMore = null;
        
        public ResultSet(String paramsIfQueryMore){
            this.paramsIfQueryMore = paramsIfQueryMore;                     
        }
    }
    
    global class AccountInfo {
        public String HCP_ID;
        public String MDM_ID;
        public String Fst_Name;
        public String Middle_Init;
        public String Lst_Name;
        public String HCP_Type;
        public String Addr_ID;
        public String Addr_1;
        public String Addr_2;
        public String City;
        public String State;
        public String Zip;
        public String Zip_Ext;
        public String Phone;
        public String Fax;
        public String Email;
        public Integer Primary;
        public String DEA_Num;
        public String DEA_Stat;
        public String DEA_Exp_Date;
        public String SLN;
        public String SLN_Exp_Date;
        public String SLN_Stat;
        public String Design;
        
        public AccountInfo(Address_vod__c record) {
            HCP_ID          = record.Account_vod__c;
            MDM_ID          = record.Account_vod__r.MDMID_gne__c;
            Fst_Name        = record.Account_vod__r.FirstName;
            Middle_Init     = String.isNotBlank(record.Account_vod__r.Middle_vod__c) ? record.Account_vod__r.Middle_vod__c.substring(0, 1) : null;
            Lst_Name        = record.Account_vod__r.LastName;
            HCP_Type        = record.Account_vod__r.Account_Type_gne__c;
            Addr_ID         = record.Id;
            Addr_1          = record.Name;
            Addr_2          = record.Address_line_2_vod__c;
            City            = record.City_vod__c;
            State           = record.State_vod__c;
            Zip             = record.Zip_vod__c;
            Zip_Ext         = record.Zip_4_vod__c;
            Phone           = record.Phone_vod__c;
            Fax             = record.Fax_vod__c;
            Email           = record.Email_gne__c;
            Primary         = record.Primary_vod__c ? 1 : 0;
            DEA_Num         = record.DEA_vod__c;
            DEA_Stat        = record.DEA_Status_vod__c == 'Valid_vod' ? 'V' : 'RI';
            DEA_Exp_Date    = GNE_SFA2_PFG_REST_Utils.formatDate(record.DEA_Expiration_Date_vod__c, 'MM/dd/yyyy');
            SLN             = record.License_vod__c;
            SLN_Exp_Date    = GNE_SFA2_PFG_REST_Utils.formatDate(record.License_Expiration_Date_vod__c, 'MM/dd/yyyy');
            SLN_Stat        = record.License_Status_vod__c == 'Valid_vod' ? 'V' : 'RI';
            Design          = record.Designation_gne__c;
        }
    }
                
    @HttpPost
    global static ResultSet getAccounts(String lastSyncDateTime, List<String> hcpIds, String paramsIfQueryMore) {
        ResultSet result = null;
        GNE_SFA2_PFG_REST_Account_Info service = new GNE_SFA2_PFG_REST_Account_Info();
        
        if(hcpIds!=null && !hcpIds.isEmpty()) {
            result = (ResultSet)service.prepareOutputObjects(hcpIds, new ResultSet(paramsIfQueryMore));
        } else {
            result = (ResultSet)service.prepareOutputObjects(lastSyncDateTime, new ResultSet(paramsIfQueryMore));
        }
        
        return result;
    }
    
    protected override void intPrepareOutputObjects(Object inputData, GNE_SFA2_PFG_REST_Base.ResultSet a_result) {
        if(inputData instanceof DateTime) {
            intPrepareOutputObjects((DateTime)inputData, a_result);
        } else {
            ResultSet result = (ResultSet)a_result;
            for (Address_vod__c address : GNE_SFA2_PFG_REST_DAO.getAccountInfo((List<String>)inputData)) {
                result.records.add(new AccountInfo(address));
            }
        }
    }
    
    protected override void intPrepareOutputObjects(DateTime lastSyncDateTime, GNE_SFA2_PFG_REST_Base.ResultSet a_result) {
        ResultSet result = (ResultSet)a_result;
        Integer recordsLimit = 500;            
        List<AccountInfo> accInfoCache = new List<AccountInfo>();       
        String additionalWhereCondition = null;
        String lastCreatedDateOnAddressGMT = null;
        String lastCreatedDateOnAccountGMT = null;
        Set<Id> visitedAccIds = new Set<Id>();      
        Set<Id> accRecTypeIds = GNE_SFA2_PFG_REST_DAO.getAccountInfoRecTypeIds();                       
        ParamReader params = new ParamReader(result.paramsIfQueryMore);
        
        if (params.isInQueryMore == true && ((params.lastCreatedDateTimeOnAddress != null && params.lastCreatedDateTimeOnAccount == null)
            || (params.lastCreatedDateTimeOnAddress == null && params.lastCreatedDateTimeOnAccount != null))){
                recordsLimit *= 2;
        }
        
        Map<DateTime, List<Address_vod__c>> latestRecords = new Map<DateTime, List<Address_vod__c>>(); 
        Integer idx = 0;
        if (!params.isInQueryMore || (params.isInQueryMore && params.lastCreatedDateTimeOnAddress != null)){
            if (params.lastCreatedDateTimeOnAddress != null){
                additionalWhereCondition = ' AND CreatedDate >= ' + GNE_SFA2_PFG_REST_Utils.formatDateTimeSOQL(params.lastCreatedDateTimeOnAddress);
            }
            for (Address_vod__c address : GNE_SFA2_PFG_REST_DAO.getAccountInfo(accRecTypeIds, lastSyncDateTime, (recordsLimit + 1), false, additionalWhereCondition)){
                if (idx == recordsLimit){
                    lastCreatedDateOnAddressGMT = GNE_SFA2_PFG_REST_Utils.formatDateTimeGmt(address.CreatedDate);
                    if (!latestRecords.containsKey(address.CreatedDate)){
                        writeResults(latestRecords, accInfoCache);
                    } 
                    break;
                }
                if (address.CreatedDate >= lastSyncDateTime || address.Rest_AccInfo_Fields_LastModDate_gne__c >= lastSyncDateTime){
                    cacheLatestRecords(address, latestRecords, accInfoCache);                   
                    visitedAccIds.add(address.Account_vod__c);
                }
                idx++;
            }
            if (latestRecords.size() > 0 && String.isBlank(lastCreatedDateOnAddressGMT)){
                writeResults(latestRecords, accInfoCache);
            }            
        }
        
        if (!params.isInQueryMore || (params.isInQueryMore && params.lastCreatedDateTimeOnAccount != null)){
            latestRecords.clear();
            idx = 0;
            if (params.lastCreatedDateTimeOnAccount != null){
                additionalWhereCondition = ' AND CreatedDate >= ' + GNE_SFA2_PFG_REST_Utils.formatDateTimeSOQL(params.lastCreatedDateTimeOnAccount);
            }                       
            for (Address_vod__c primaryAddress : GNE_SFA2_PFG_REST_DAO.getAccountInfo(accRecTypeIds, lastSyncDateTime, (recordsLimit + 1), true, additionalWhereCondition)){
                if (idx == recordsLimit){                               
                    lastCreatedDateOnAccountGMT = GNE_SFA2_PFG_REST_Utils.formatDateTimeGmt(primaryAddress.CreatedDate);
                    if (!latestRecords.containsKey(primaryAddress.CreatedDate)){
                        writeResults(latestRecords, accInfoCache);
                    }
                    break;
                }
                if (primaryAddress.CreatedDate >= lastSyncDateTime || primaryAddress.Rest_AccInfo_Fields_LastModDate_gne__c >= lastSyncDateTime){
                    cacheLatestRecords(primaryAddress, latestRecords, accInfoCache);
                } else if (!visitedAccIds.contains(primaryAddress.Account_vod__c) 
                    && (primaryAddress.Account_vod__r.CreatedDate >= lastSyncDateTime 
                    || primaryAddress.Account_vod__r.REST_AccInfo_Fields_LastModDate_gne__c >= lastSyncDateTime)){
                    cacheLatestRecords(primaryAddress, latestRecords, accInfoCache);
                }
                idx++;
            }
            if (latestRecords.size() > 0 && String.isBlank(lastCreatedDateOnAccountGMT)){
                writeResults(latestRecords, accInfoCache);
            }
        }
        
        result.records = accInfoCache;
        result.hasMore = String.isNotBlank(lastCreatedDateOnAddressGMT) || String.isNotBlank(lastCreatedDateOnAccountGMT);
        result.paramsIfQueryMore = params.formatStringGMT(lastCreatedDateOnAddressGMT, lastCreatedDateOnAccountGMT);
        
        result.debugInfo.put('recordsCount: ', String.valueOf(result.records.size()));
    }
    
    private void cacheLatestRecords(Address_vod__c address, Map<DateTime, List<Address_vod__c>> latestRecords, List<AccountInfo> accInfoCache){
        if (latestRecords.containsKey(address.CreatedDate)){                        
            latestRecords.get(address.CreatedDate).add(address);
        } else {
            writeResults(latestRecords, accInfoCache);                                  
            latestRecords.put(address.CreatedDate, new List<Address_vod__c>{address});
        }
    }
    
    private void writeResults(Map<DateTime, List<Address_vod__c>> latestRecords, List<AccountInfo> accInfoCache){
        for (List<Address_vod__c> lAddress: latestRecords.values()){
            for (Address_vod__c cAddress : lAddress){
                accInfoCache.add(new AccountInfo(cAddress));
            }
        }
        latestRecords.clear();
    }
    
    private class ParamReader{
        private String delimeter = ';';     
        public DateTime lastCreatedDateTimeOnAddress { get; private set; }
        public DateTime lastCreatedDateTimeOnAccount { get; private set; }
        
        public Boolean isInQueryMore {
            get {
                return lastCreatedDateTimeOnAddress != null || lastCreatedDateTimeOnAccount != null;
            }
        }
        
        public ParamReader(String paramString){
            if (String.isNotBlank(paramString)){
                try{
                    List<String> params = paramString.split(delimeter);
                    if (String.isNotBlank(params.get(0)) && params.get(0) != 'null'){
                        this.lastCreatedDateTimeOnAddress = GNE_SFA2_PFG_REST_Utils.parseDateTimeGmt(params.get(0));                     
                    }
                    if (String.isNotBlank(params.get(1)) && params.get(1) != 'null'){
                        this.lastCreatedDateTimeOnAccount = GNE_SFA2_PFG_REST_Utils.parseDateTimeGmt(params.get(1));                     
                    }
                } catch (Exception ex){
                    ex.setMessage('An error occured while parsing request query more parameters: ' + ex.getMessage());
                    throw ex;
                }               
            } 
        }
        
        public String formatStringGMT(String nextDateOnAdress, String nextDateOnAccount) { 
            if (String.isBlank(nextDateOnAdress) && String.isBlank(nextDateOnAccount)){
                return '';
            } else {
                return String.format('{0}{1}{2}',
                    new String[]{
                        nextDateOnAdress,
                        delimeter,
                        nextDateOnAccount
                    }               
                );
            }           
        }
    }    
}