public class GNE_FRM_DST_MatchLoserTriggerHandler {
    private static List<Group> groups = [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND Name = 'Data Change Request FRM Vendors Queue'];
    private static Id defaultOwnerId = groups.isEmpty() ? UserInfo.getUserId() : groups[0].Id;
    private Enum CandidateType {Loser, Winner}
    private static Map<String, Account> id2Account;
    
    public static void populateFields() {
        Set<Id> requestUsers = new Set<Id>();
        id2Account = fetchAccounts(requestUsers);
        Set<Id>usersDST = fetchDSTusers(requestUsers);
        for(DST_Match_Loser__c loser : (DST_Match_Loser__c[])Trigger.new){
            if(isRecordApplicable(loser)){
                populateFieldsOnRecord(loser);               
            }
            if(isWinnerAccountChanged(loser)){
                populateWinnerFields(loser);
            }
            clearWinnerDuringMergeProcess(loser);
            removeSelectedWinnerOnReject(loser);            
            
            if(!runValidation(loser, usersDST)){
                loser.addError('Selected user has no PermissionSet Assignment For Data Stewardship Tool');
            }
        }
    }
    
    private static void clearWinnerDuringMergeProcess(DST_Match_Loser__c loser) {
        if(Trigger.isUpdate){
            DST_Match_Loser__c oldRecord = (DST_Match_Loser__c)Trigger.OldMap.get(loser.Id);

            if(loser.Match_Loser_Account_SfdcId__c == loser.Winner_SfdcId__c){
                if(!isCorrectStatus(oldRecord.Mdm_Bundle_Status__c)){
                    loser.Match_Loser_Account_SfdcId__c = null;       
                }
            }
        }        
    }
    
    private static void removeSelectedWinnerOnReject(DST_Match_Loser__c loser) {
        if(loser.Mdm_Bundle_Status__c == DST_Match_Loser_Helper.MDM_BUNDLE_STATUS_REJECTED ){
            loser.Winner_SfdcId__c = null;
        }
    }
    
    private static Boolean isRecordApplicable(DST_Match_Loser__c newRecord) {
        Boolean result = false;
        if (Trigger.isInsert){
            result =  true;
        } else if (Trigger.isUpdate){
            DST_Match_Loser__c oldRecord = (DST_Match_Loser__c)Trigger.OldMap.get(newRecord.Id);
            Boolean isCorrectStatus = isCorrectStatus(oldRecord.Mdm_Bundle_Status__c); 
            result = isCorrectStatus && checkConditionsForUpdate(oldRecord, newRecord, 'Match_Loser_Account_SfdcId__c');
        }
        
        return result;
    }
    
    private static Boolean isCorrectStatus(String status) {
        return new Set<String>{
            DST_Match_Loser_Helper.MDM_BUNDLE_STATUS_NEW,
            DST_Match_Loser_Helper.MDM_BUNDLE_STATUS_EXCEPTION,
            DST_Match_Loser_Helper.MDM_BUNDLE_STATUS_INPROGRESS
        }.contains(status);
    }
    
    private static Boolean checkConditionsForUpdate(DST_Match_Loser__c oldRecord, DST_Match_Loser__c newRecord, String fieldName) {
        return oldRecord.get(fieldName) != newRecord.get(fieldName);
    }
    
    private static Boolean isWinnerAccountChanged(DST_Match_Loser__c newRecord){
        Boolean result = false;
        if(Trigger.isInsert && newRecord.Winner_SfdcId__c != null){
            result = true;
        } else if (Trigger.isUpdate){
            DST_Match_Loser__c oldRecord = (DST_Match_Loser__c)Trigger.OldMap.get(newRecord.Id);
            result = checkConditionsForUpdate(oldRecord, newRecord, 'Winner_SfdcId__c');
        }
        return result;
    }
    
    private static Map<String, Account> fetchAccounts(Set<Id> requestUser) {
        Set<Id> accIds = new Set<Id>();
        for(DST_Match_Loser__c loser : (DST_Match_Loser__c[])Trigger.new){
            if(loser.Match_Loser_Account_SfdcId__c != null ){
                accIds.add(loser.Match_Loser_Account_SfdcId__c);
            }
            if(loser.Winner_SfdcId__c != null){
                accIds.add(loser.Winner_SfdcId__c);
            }
            if(loser.Request_Analyst_gne__c != null){
                requestUser.add(loser.Request_Analyst_gne__c);
            }
        }
        
        String query = 'SELECT Id, MDMID_gne__c, CreatedBy.Name, LastModifiedBy.Name, Account_Type_gne__c, '+
            'RecordType.Name, Name, Group_Name_gne__c, '+
            '(SELECT Name, City_vod__c, State_vod__c, Zip_vod__c, Address_line_2_vod__c FROM Address_vod__r ) '+
            'FROM Account '+
            'WHERE Id IN : accIds ';
        
        Map<String, Account> result =  new Map<String, Account>();

        try{
            for(Account acc :Database.query(query)){
                result.put(acc.Id, acc);
            }
        } catch(Exception ex){
            System.debug(ex.getMessage());
            Trigger.new[0].addError('Database error: '+ex.getTypeName() + '. Please, report this issue to administrator.');
        }

        return result;
    }
    
    private static Set<Id> fetchDSTusers(Set<Id> requestUser){
        Set<Id>usersDST = new Set<Id>();
        for(PermissionSetAssignment psa:[
            SELECT AssigneeId FROM PermissionSetAssignment WHERE AssigneeId = :requestUser AND PermissionSet.Name = 'Data_Stewardship_Tool'
        ]){
            usersDST.add(psa.AssigneeId);
        }
        
        return usersDST;        
    }
    
    private static Boolean runValidation(DST_Match_Loser__c loser, Set<Id> usersDST) {
        Boolean result = true;
        if(Trigger.isUpdate){
            DST_Match_Loser__c oldRecord = (DST_Match_Loser__c)Trigger.OldMap.get(loser.Id);
            if(loser.Request_Analyst_gne__c != null && oldRecord.Request_Analyst_gne__c != loser.Request_Analyst_gne__c){
                if(!usersDST.contains(loser.Request_Analyst_gne__c) ){
                    result = false;
                }
            }
        } else if(Trigger.isInsert){
            if(loser.Request_Analyst_gne__c != null && !usersDST.contains(loser.Request_Analyst_gne__c)){
                result = false;
            }
        }
        return result;
    }
    
    private static void populateWinnerFields(DST_Match_Loser__c loser){
        Account acc = id2Account.get(loser.Winner_SfdcId__c) != null ? id2Account.get(loser.Winner_SfdcId__c) : null;
        loser.Winner_Account_Name_gne__c  = acc == null ? null : acc.Name;
        loser.Winner_MdmId__c             = acc == null ? null :acc.MDMID_gne__c;
        loser.Winner_Text_SfdcId__c       = acc == null ? null :acc.Id;
        loser.Winer_Address_Id_txt_gne__c = acc == null ? null :acc.Address_vod__r.isEmpty() ? null : acc.Address_vod__r[0].Id;
    }
    
    private static void populateFieldsOnRecord(DST_Match_Loser__c loser) {
        Account acc = id2Account.get(loser.Match_Loser_Account_SfdcId__c) != null ? id2Account.get(loser.Match_Loser_Account_SfdcId__c) : null;
        if(acc == null) return;
        Address_vod__c address                = acc.Address_vod__r.isEmpty() ? new Address_vod__c() : acc.Address_vod__r[0];
        loser.OwnerId                         = Trigger.isInsert ? defaultOwnerId : loser.OwnerId;
        loser.Match_Loser_Account_MdmId__c    = acc.MDMID_gne__c;
        loser.Match_Loser_Text_SFDC_ID__c     = acc.Id;
        loser.Loser_Accnt_Created_By__c       = acc.CreatedBy.Name;
        loser.Loser_Accnt_Last_Modified_By__c = acc.LastModifiedBy.Name;
        loser.Match_Loser_Name__c             = acc.Name;
        loser.Match_Loser_Accnt_Rec_Type__c   = acc.RecordType.Name;
        loser.Match_Loser_Accnt_Type__c       = acc.Account_Type_gne__c;
        loser.Account_Group_gne__c            = acc.Group_Name_gne__c;
        loser.Match_Loser_Address1__c         = address.Name;
        loser.Match_Loser_Address2__c         = address.Address_line_2_vod__c;
        loser.Match_Loser_City__c             = address.City_vod__c;   
        loser.Match_Loser_State__c            = address.State_vod__c;
        loser.Match_Loser_Zip_Code__c         = address.Zip_vod__c;
    }
    
    public static void createMergeCandidates() {
        List<CORE_Merge_Candidate__c> candidates = new List<CORE_Merge_Candidate__c>();
        Map<String,CORE_Merge_Object__c> nameToMergeObject = fetchMergeObjectsMap();
        id2Account = fetchAccounts(new Set<Id>());
        Map<Id, CORE_Merge_Candidate__c> loserId2Candidate = new Map<Id, CORE_Merge_Candidate__c>();

        for(DST_Match_Loser__c loser : (DST_Match_Loser__c[])Trigger.new){
            if(isCriteriaAreMet(loser)){
                /* create Account LOSER */
                CORE_Merge_Candidate__c loserCandidate = createCandidate(nameToMergeObject.get('Account-US'), loser.Winner_SfdcId__c, loser.Match_Loser_Account_SfdcId__c, CandidateType.Loser );
                candidates.add(loserCandidate);
                loser.Core_Merge_Candidate_gne__r = loserCandidate;
                loserId2Candidate.put(loser.Id, loserCandidate);
                /* create Account WINNER */
                candidates.add(createCandidate(nameToMergeObject.get('Account-US'), loser.Winner_SfdcId__c, loser.Winner_SfdcId__c, CandidateType.Winner ));
                
                if(String.isNotBlank(loser.Winer_Address_Id_txt_gne__c)){
                    Account acc = id2Account.get(loser.Match_Loser_Account_SfdcId__c) != null ? id2Account.get(loser.Match_Loser_Account_SfdcId__c) : null;
        			if(acc == null) continue;
                    if(acc.Address_vod__r.isEmpty()){
                        continue;
                    }
                    /* create Address WINNER */
                    CORE_Merge_Candidate__c winAddress = createCandidate(nameToMergeObject.get('Address-US'), loser.Winer_Address_Id_txt_gne__c, loser.Winer_Address_Id_txt_gne__c, CandidateType.Winner);
                    for(Address_vod__c add:  acc.Address_vod__r){
                        /* create Address LOSER */
                        candidates.add(createCandidate(nameToMergeObject.get('Address-US'), loser.Winer_Address_Id_txt_gne__c, add.Id, CandidateType.Loser ));
                    }  
                    if(!acc.Address_vod__r.isEmpty()){
                        candidates.add(winAddress);
                    }
                }                
            }               
        }
        Database.insert(candidates, false);
        
        for(DST_Match_Loser__c loser : (DST_Match_Loser__c[])Trigger.new){
            if(loserId2Candidate.get(loser.Id) != null){
                loser.Core_Merge_Candidate_gne__c =  loserId2Candidate.get(loser.Id).Id;
            }
        }
    }
        
    public static Map<String,CORE_Merge_Object__c> fetchMergeObjectsMap() {
        Map<String, CORE_Merge_Object__c> nameToMergeObject = new Map<String, CORE_Merge_Object__c>();
        for(CORE_Merge_Object__c obj :[
            SELECT Id, Name FROM CORE_Merge_Object__c WHERE Name IN ('Account-US', 'Address-US')
        ]){
            nameToMergeObject.put(obj.Name, obj);
        }
        return nameToMergeObject;
    }
    
    private static Boolean isCriteriaAreMet(DST_Match_Loser__c loser){
        DST_Match_Loser__c oldRecord = (DST_Match_Loser__c)Trigger.OldMap.get(loser.Id);
        return loser.Mdm_Bundle_Status__c == DST_Match_Loser_Helper.MDM_BUNDLE_STATUS_APPROVED && 
            oldRecord.Mdm_Bundle_Status__c != loser.Mdm_Bundle_Status__c && 
            loser.Winners_Counter__c > 0 && 
            loser.Winner_SfdcId__c != null;       
    }
    
    private static CORE_Merge_Candidate__c createCandidate(CORE_Merge_Object__c mergeObj, String winnerId, String loserId, CandidateType candType) {
        return new CORE_Merge_Candidate__c(
            Merge_Object_gne__c = mergeObj.Id,
            Type_gne__c         = 'Merge',
            Source_gne__c       = 'Manual', 
            Id_gne__c           = candType == CandidateType.Winner ? winnerId :loserId,
            Master_Id_gne__c    = winnerId,
            External_Id_gne__c = candType == CandidateType.Winner ? winnerId + '_' + winnerId : loserId + '_' + winnerId
        );
    }
}