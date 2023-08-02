//--------------------------------------------------------------------------------
// COMPONENT: SFA Primary Care
//     CLASS: GNE_Stg_Party_Dao  
//   PURPOSE: Dao for Stg_Pty_gne__c  
//      
//   CREATED: 05/2010    
public with sharing class GNE_Stg_Party_Dao  extends GNE_Base_Dao {
 
    public static final String NAME = 'CORE_Pub_Party__c';
    public static final String REC_TYPE_HCP = 'Professional_vod';
    public static final String REC_TYPE_LWO_HCP = 'LWOHealthcareProfessional_gne';
    public static final String REC_TYPE_LWO_HCO = 'LWOHealthCareOrganization_gne';
    public static final String REC_TYPE_ADDR = 'RepMaintained';
     
    public static final String DEFAULT_INDIVIDUAL_ROLE_CODE = 'HCPNPSCR';
    
    private Long subscribeProcessValidationTotalTime;
    
    public GNE_Stg_Party_Dao(boolean testCase)
    {
        IsTestCase = testCase;
        init();
    }  
    
    public void init()
    {
        ObjectName = NAME;
        ClassName = 'GNE_Stg_Party_Dao';
    }
                              
    public String getSFDCAddressId(String ptyLocId) {
        return fetchAddressId('SFDC', ptyLocId);
                 }
                 
    public String getMdmAddressId(String ptyLocId) {
        return fetchAddressId('MDM', ptyLocId);
            }
            
    private String fetchAddressId (String contrSource, String ptyLocId){
        CORE_Pub_External_Id__c [] refList = [
            SELECT Ctrb_Src_Id_gne__c
            FROM CORE_Pub_External_Id__c 
            WHERE Ctrb_Src_gne__c = :contrSource
                AND Cnncl_Enty_Type_gne__c = 'PTYLOC'
                AND Party_Location_Id_gne__c = :ptyLocId
            LIMIT 1
        ];
        return refList.isEmpty() ? null : refList[0].Ctrb_Src_Id_gne__c;
    } 
    
    private String getPartyIdForPartyLocId(String ptyLocId){
        List<CORE_Pub_Location__c> ptyLoc = [
            SELECT Id, Party_Location_Id_gne__c
            FROM CORE_Pub_Location__c 
            WHERE Party_Location_Id_gne__c = :ptyLocId
            LIMIT 1
        ];
        if (ptyLoc.isEmpty()){
            return '';
        }
        return ptyLoc[0].Party_Location_Id_gne__c;
    }
    
    public Account subscribeAddress(String ptyLocId) {
        Account acct; 
        Set<String> locIdSet = new Set<String>{};
        locIdSet.add(ptyLocId);
        
        Map<String, Set<String>> subscribeMap = new Map<String, Set<String>>{};
        String ptyId = getPartyIdForPartyLocId(ptyLocId);
        subscribeMap.put(ptyId, locIdSet);
        
        Id jobId = CORE_Subscribe_Util.prepareSubscribeJobId('SUB_PARTY_LOCATION');
        CORE_Subscribe_Process proc = new CORE_Subscribe_Process();
        CORE_Subscribe_Metrics metrics = proc.executeSubscribe(subscribeMap, jobId);

        for (CORE_Subscribe_Metrics metric : metrics.relatedMetrics) {
            if (metric.upsertedRecords != null && metric.upsertedRecords.size() > 0) {
                if (metric.targetObject == 'Account') {
                    acct = (Account) metric.upsertedRecords[0]; 
                        break;
                    }
                }   
            }
        return acct;
    }
}