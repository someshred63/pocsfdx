/******************************************************************************************
*  @author: Jaroslaw Laniecki, Roche (contractor)
*  @email: jaroslaw.laniecki@contractors.roche.com
*  Created: 2017-06-12
*  Project: OTR2
*  Description: Returns a Territory for the specified user id (unixId).
*  to avoid extend limit 50000 rows per operations the service will be call until count of
*  territoriesIds will equals to numbers (territoriesNumbers - 1) from request params
*  for example user has 3 territories
*  1st  call has empty list of territoriesNumbers in params and as response get list of users territories and zips of 1s territory
*  2nd  call has one number in territoriesNumbers in params (first of territoriesIds) and as response get list of users territories and zips of 2nd territory
*  3rd  call has two numners in params (1st and 2nd terr) and as response get list of users territories and zips of 3nd territory
*******************************************************************************************/
@RestResource(urlMapping='/iPhoneGetUserTerritory/*')
global with sharing class iPhone_Get_User_Territory_gne {

    @HttpPost
     global static iPhone_Commons_gne.RestResponse processRequest(String lastSyncDate, String unixId, String[] terrNumbers, String lastZip) {
        return iPhone_Commons_gne.buildResponse(
                new UserTerritoriesResponseBuilder(),
                new RequestArgs(lastSyncDate, terrNumbers, unixId, lastZip)
        );
    }

    class UserTerritoriesResponseBuilder implements iPhone_Commons_gne.ResponseBuilder {

        public iPhone_Commons_gne.RestResponse build(Object args){
            RequestArgs deltaArgs = (RequestArgs)args;
            User user = iPhone_DAO.getUserByExternalId(deltaArgs.unixId);
            Boolean isBrandUser = GNE_SFA2_Util.isBrandUser(user.Profile_Name_gne__c.toUpperCase());
            List<Territory2> userTerritories = GNE_SFA2_Util.getUserTerritories(user.id);
            Map<Id, Territory2> allUserTerritories = new Map<Id, Territory2>();
            Map<String, Territory2> allUserTerritoriyNumbers = new Map<String, Territory2>();
            String lastZip = deltaArgs.lastZip == null ? '' : deltaArgs.lastZip;
            Set<String> processedTerrNumbers = deltaArgs.terrNumbers == null ? new Set<String>() : new Set<String>(deltaArgs.terrNumbers); //processed territory and sended to OTR
            Set<String> territoriesIds = new Set<String>(); //we need this collection as response to OTR. Based on this info OTR knows how many times has to call this service

            for(Territory2 terr : userTerritories) {                
                territoriesIds.add(terr.Id);
                allUserTerritories.put(terr.Id, terr);
                if(String.isNotBlank(terr.Territory_Number_gne__c))allUserTerritoriyNumbers.put(terr.Territory_Number_gne__c, terr );
            }

            String currentProcessingTerritoryId;
            if(String.isNotBlank(lastZip)){
                Integer index = processedTerrNumbers.size() - 1;
                String currTerrIdOrNumber = deltaArgs.terrNumbers[index];
                if(currTerrIdOrNumber instanceof Id){
                    currentProcessingTerritoryId = deltaArgs.terrNumbers[index];
                } else {
                    Territory2 temTerr = allUserTerritoriyNumbers.get(deltaArgs.terrNumbers[index]) != null ? allUserTerritoriyNumbers.get(deltaArgs.terrNumbers[index]) : null;
                    currentProcessingTerritoryId = temTerr.Id;
                }
                
            } else {
                if(!processedTerrNumbers.isEmpty()){
                    Integer index = 0;
                    List<String> tempList = new List<String>(processedTerrNumbers);
                    for(String str :tempList){
                        if(!(str instanceof Id)) {
                            Territory2 temTerr = allUserTerritoriyNumbers.get(str) != null ? allUserTerritoriyNumbers.get(str) : null;
                            if(temTerr != null) {
                                tempList.set(index, temTerr.Id);
                            }
                        }
                        index++;
                    }   
                    processedTerrNumbers = new Set<String>(tempList);
                }

                for(String terrNum : allUserTerritories.keySet()){
                    if(!processedTerrNumbers.contains(terrNum) ){
                        currentProcessingTerritoryId = terrNum;
                        break;
                    }
                }
            }

            List<UserTerritoryRecord> records = new List<UserTerritoryRecord>();
            if(currentProcessingTerritoryId == null){
                return new DeltaRecordsResponse(records);
            }

            List<String> changedZips = new List<String>{'NOCHANGES'};
            iPhone_Get_ZipCodesByTerritoryNumber.ZipCodesByTerritoryNumberBuilder respBuilder = new iPhone_Get_ZipCodesByTerritoryNumber.ZipCodesByTerritoryNumberBuilder();
            iPhone_Commons_gne.RestResponse resp = iPhone_Get_ZipCodesByTerritoryNumber.buildResponse(null, currentProcessingTerritoryId, lastZip);
            iPhone_Get_ZipCodesByTerritoryNumber.DeltaRecordsResponse recordsResponse = (iPhone_Get_ZipCodesByTerritoryNumber.DeltaRecordsResponse)resp;
            List<String> zips = recordsResponse.zc;
            lastZip = recordsResponse.lastZip;
            Territory2 currentTerritory = allUserTerritories.get(currentProcessingTerritoryId);
			String currentProcessingTerritoryNumber = currentTerritory.Territory_Number_gne__c != null? currentTerritory.Territory_Number_gne__c : null;
            if(currentProcessingTerritoryNumber != null && checkChangesOnTerritory(deltaArgs.lastSyncDate, currentProcessingTerritoryNumber)){
                changedZips = zips;
            }
            records.add(new UserTerritoryRecord(currentTerritory, changedZips, zips, territoriesIds, deltaArgs.lastSyncDate, lastZip, isBrandUser));

            return new DeltaRecordsResponse(records);
        }

        private Boolean checkChangesOnTerritory(String lastSyncDate, String currentProcessingTerritory) {
            Boolean result = String.isBlank(lastSyncDate) ? true : false;
            if(!result) {
                String likeTerr = currentProcessingTerritory+'%';
                Datetime timeStampOfLastSyncDate = Datetime.valueOfGmt(lastSyncDate);

                result |= ![SELECT Id FROM OTR_Deleted_Record_gne__c WHERE Deleted_Record_Id__c LIKE :likeTerr AND CreatedDate > :timeStampOfLastSyncDate AND Object_name__c ='ZipToTerritory_gne' LIMIT 1].isEmpty();
                result |= ![SELECT Id FROM Zip_to_Territory_gne__c WHERE CreatedDate > :timeStampOfLastSyncDate AND Territory_Number_gne__c = :currentProcessingTerritory LIMIT 1].isEmpty();
            }

            return result;
        }
    }

    class RequestArgs extends iPhone_Commons_gne.DefaultDeltaArgs {
        String lastZip;
        String[] terrNumbers;

        public RequestArgs(String lastSyncDate, String[] terrNumbers, String unixId, String lastZip){
            this(lastSyncDate, unixId, null, false, null);
            this.terrNumbers = terrNumbers;
            this.lastZip = lastZip;
        }

        public RequestArgs(String lastSyncDate, String unixId, List<String> accountIds, Boolean enhDelta, String otrVersion){
            super(lastSyncDate, unixId, accountIds, enhDelta, otrVersion);
        }
    }

    @testVisible
    class UserTerritoryRecord extends iPhone_Commons_gne.DeltaRecord {
        public String nm; //(name)
        public List<String> zc; //(zip codes)
        public String territoryNumber; // territory number (Territory.)
        public String territoryId; // territory number (Territory.)
        public List<MyTerritoryTeamModel> mtt; //list of users handling given territory
        public Set<String> territoriesIds; //collection of ids of user territories
        public String lastZip;
        public String pid; //parent territory Id
        public Integer ac; // count of related mtt

        public UserTerritoryRecord(Territory2 territory, List<String> changedZipCodes, List<String> zipCodes, Set<String> territoriesIds, String lastSyncDate, String lastZip, Boolean isBrandUser) {
            this.id = territory.Id;
            this.nm = territory.Name;
            this.zc = changedZipCodes;
            this.territoryNumber = territory.Territory_Number_gne__c == null ? null : territory.Territory_Number_gne__c;
            this.territoryId = territory.Id;
            this.pid = territory.ParentTerritory2Id;
            this.mtt = isBrandUser ? parseCollection(GNE_My_Territory_Team_DAO.getVisibleTerritoryTeamByTerritory(territoryNumber), lastSyncDate) : new List<MyTerritoryTeamModel>();
            this.territoriesIds = territoriesIds;
            this.lastZip = lastZip;
            this.ac = [SELECT Count() FROM TSF_vod__c where Territory_vod__c = : territory.Name];
        }

        private List<MyTerritoryTeamModel> parseCollection(My_Territory_Team_gne__c [] territoryTeamColl, String lastSyncDate) {
            List<MyTerritoryTeamModel> mtt = new List<MyTerritoryTeamModel>();
            Set<String> numbers = new Set<String>();
            for(My_Territory_Team_gne__c tt : territoryTeamColl){
                Set<String> ternums  = tt.Common_Terriotires_gne__c != null ? new Set<String> (tt.Common_Terriotires_gne__c.split(';')) : new Set<String>();
                numbers.addAll(ternums);
            }
            if(String.isBlank(lastSyncDate)){
                for(My_Territory_Team_gne__c tt : territoryTeamColl){
                    Map<String, Boolean> terrsDelta = new Map<String, Boolean>();
                    Set<String> ternums  = tt.Common_Terriotires_gne__c != null ? new Set<String> (tt.Common_Terriotires_gne__c.split(';')) : new Set<String>();
                    for(String ter : ternums){
                         terrsDelta.put(ter, true);
                    }
                    mtt.add(new MyTerritoryTeamModel(tt, terrsDelta));
                }
            } else {
                Set<Id> territoriesOutOfDate = prepareDeltaForTerritories(numbers, lastSyncDate);
                for(My_Territory_Team_gne__c tt : territoryTeamColl){
                    Map<String, Boolean> terrsDelta = new Map<String, Boolean>();
                    Set<String> ternums  = tt.Common_Terriotires_gne__c != null ? new Set<String> (tt.Common_Terriotires_gne__c.split(';')) : new Set<String>();
                    for(String ter : ternums){
                        if(territoriesOutOfDate.contains(ter)){
                            terrsDelta.put(ter, true);
                        } else {
                            terrsDelta.put(ter, false);
                        }
                    }
                    mtt.add(new MyTerritoryTeamModel(tt, terrsDelta));
                }
            }

            return mtt;
        }

        private Set<Id> prepareDeltaForTerritories(Set<String> terrNumbers, String lastSyncDate) {
            Datetime timeStampOfLastSyncDate = Datetime.valueOfGmt(lastSyncDate);
            Set<String> delta = new Set<String>();

            if(!terrNumbers.isEmpty()){
                String query = prepareQuery(terrNumbers);
                String zipQuery = prepareZipQuery(terrNumbers);
                for(AggregateResult ar :Database.query(zipQuery)) {
                    delta.add(String.valueOf(ar.get('Territory_Number_gne__c')));
                }
                for(OTR_Deleted_Record_gne__c dr :Database.query(query)) {
                    String terNum = dr.Deleted_Record_Id__c.split('_')[0];
                    delta.add(terNum);
                }
            }            

            Map<Id, Territory2> id2Territory = new Map<Id, Territory2>([
                SELECT Id
                FROM Territory2
                WHERE (NOT external_id_gne__c LIKE 'INACTIVE TERRITORIES-%')
                    AND Territory_Number_gne__c IN : delta
             ]);

            return id2Territory.keySet();
        }

        private String prepareZipQuery(Set<String> terrIds){
            Set<String> terrNumbers = new Set<String>();
            for(Territory2 t2 : [
                SELECT Territory_Number_gne__c 
                FROM Territory2
                WHERE Id IN : terrIds
                    AND Territory_Number_gne__c != null
            ]){
                terrNumbers.add(t2.Territory_Number_gne__c);
            }
            String query = 'SELECT Territory_Number_gne__c FROM Zip_to_Territory_gne__c WHERE CreatedDate > :timeStampOfLastSyncDate ';
            if(!terrNumbers.isEmpty()){
                String[] numbers = new String[] {};
                query += ' AND Territory_Number_gne__c IN (';
                for(String ter : terrNumbers){
                    numbers.add('\''+ter+'\'');
                }
                String clauseIn = String.join(numbers, ',');
                query += clauseIn + ')';
            }
            query += ' GROUP BY Territory_Number_gne__c LIMIT 2000';
            System.debug('query '+query);

            return query;
        }

        private String prepareQuery(Set<String> terrNumbers) {
            String query = 'SELECT Deleted_Record_Id__c FROM OTR_Deleted_Record_gne__c WHERE Object_name__c =\'ZipToTerritory_gne\' AND CreatedDate > :timeStampOfLastSyncDate ';
            if(!terrNumbers.isEmpty()){
                query += ' AND  (';
                String[] likeTerritories = new String[]{};
                for(String ter : terrNumbers){
                    String likeTerr = ' Deleted_Record_Id__c LIKE \''+ter+'%\'';
                    likeTerritories.add(likeTerr);
                }
                String clauseOr = String.join(likeTerritories, ' OR ');
                query +=clauseOr + ')';
            }
            System.debug('query '+query);
            return query;
        }
    }

    public class MyTerritoryTeamModel{
        public String firstName;
        public String lastName;
        public String unixId;
        public Map<String, Boolean> territoryNumbers;
        public String businessRole;
        public String profile;
        public Boolean isActive;

        public MyTerritoryTeamModel(My_Territory_Team_gne__c record, Map<String, Boolean> territoryNumbers) {
            this.firstName = record.User_First_Name_calc_gne__c;
            this.lastName = record.User_Last_Name_calc_gne__c;
            this.unixId = record.User_Unix_ID_calc_gne__c != null ? record.User_Unix_ID_calc_gne__c : record.Unix_User_Id_gne__c;
            this.territoryNumbers = territoryNumbers;
            this.businessRole = record.User_Business_Role_calc_gne__c;
            this.profile = record.User_Profile_calc_gne__c;
            this.isActive = record.Is_User_Active_calc_gne__c;
        }
    }

    public class DeltaRecordsResponse extends iPhone_Commons_gne.RestResponse{
        public final List<DeltaRecord> records;

        public DeltaRecordsResponse(List<iPhone_Commons_gne.DeltaRecord> records) {
            this.records = records;
        }
    }
}