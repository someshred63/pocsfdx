public class GNE_My_Territory_Team_Clean_MedAffairs implements Database.Batchable<sObject>, Database.Stateful{
    private Map<Id, My_Territory_Team_gne__c> toDelete = new Map<Id, My_Territory_Team_gne__c>();
    private Map<String, TerritoryHolder> territoriesHolder = new Map<String, TerritoryHolder> ();
    private static final String CLASS_NAME = 'GNE_My_Territory_Team_Clean_MedAffairs';
    private GNE_My_Territory_Team_Batch_Helper.BatchStatistic batchStatistic;
    private GNE_My_Territory_Team_Batch_Helper.BatchStatistic[] statistics;

    public GNE_My_Territory_Team_Clean_MedAffairs() {
        this.statistics = new GNE_My_Territory_Team_Batch_Helper.BatchStatistic[]{};
        this.batchStatistic = new GNE_My_Territory_Team_Batch_Helper.BatchStatistic(CLASS_NAME);
    }
    public GNE_My_Territory_Team_Clean_MedAffairs(GNE_My_Territory_Team_Batch_Helper.BatchStatistic[] statistics, Integer prevBatchOrder) {
        this.statistics = statistics;
        this.batchStatistic = new GNE_My_Territory_Team_Batch_Helper.BatchStatistic(CLASS_NAME, prevBatchOrder);
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Territory_Number_gne__c, UserId_gne__c, isManualAdded_gne__c, Unix_User_Id_gne__c '+
            'FROM My_Territory_Team_gne__c '+
            'WHERE is_Med_Affair_gne__c = true '+
            'ORDER BY Territory_Number_gne__c ';

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<My_Territory_Team_gne__c> scope) {
        batchStatistic.mode = 'ALL RECORDS MODE';
        Set<String> terrNumbers = new Set<String>();
        Map<String, List<My_Territory_Team_gne__c>> terNumber2TTWrapper = new Map<String, List<My_Territory_Team_gne__c>>();
        for(My_Territory_Team_gne__c mt : scope){
            terrNumbers.add(mt.Territory_Number_gne__c);
            if(!terNumber2TTWrapper.containsKey(mt.Territory_Number_gne__c)){
                terNumber2TTWrapper.put(mt.Territory_Number_gne__c, new List<My_Territory_Team_gne__c>());
            }
            terNumber2TTWrapper.get(mt.Territory_Number_gne__c).add(mt);
        }

        Territory2 [] processingTerritories = [
            SELECT Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c, Territory_Number_gne__c
            FROM Territory2
            WHERE Territory_Number_gne__c IN :terrNumbers
                AND (NOT external_id_gne__c LIKE 'INACTIVE TERRITORIES%' ) AND External_id_gne__c LIKE 'GNE-US%'
                AND Salesforce_Code_gne__c != null AND Salesforce_SubTeam_Code_gne__c != null
        ];

        for(Territory2 processingTerritory : processingTerritories){
            String terrNumber = processingTerritory.Territory_Number_gne__c;
            Map<Id,String> prodId2TA = GNE_My_Territory_Team_Batch_Helper.findProducts(new List<Territory2>{processingTerritory});
            TerritoryWrapper tw = createTerritoryWrapper(terrNumber, prodId2TA.values());
            TerritoryHolder terrHolder = fetchTerrHolder(tw);
            Set<Id> medAffairUsersIds = fetchMedAffairsUsers(terrHolder, tw);
            findMedAffairsToRemove(medAffairUsersIds, terNumber2TTWrapper.get(terrNumber), terrNumber, terrHolder);
        }
        batchStatistic.updateStatistic();

    }

    public void finish(Database.BatchableContext BC){
        batchStatistic.deletedRecords = toDelete.size();
        delete toDelete.values();
        batchStatistic.markFinised();
        statistics.add(batchStatistic);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{GNE_My_Territory_Team_Batch_Helper.prepareEmail(statistics)}, false);
    }

    private Set<Id> fetchMedAffairsUsers(TerritoryHolder terrHolder, TerritoryWrapper tw) {
        Set<Id> userMedAffInTa = new Set<Id>();
        Set<String> tas = tw.TA;

        for(MA_Referral_Roster__c rr: DataBase.query(prepareQueryForMAReferral(terrHolder))){
            userMedAffInTa.add(rr.User__c);
        }
        terrHolder.updateUsers(userMedAffInTa);

        return userMedAffInTa;
    }

    private String prepareQueryForMAReferral(TerritoryHolder terrHolder) {
        return 'SELECT State__c, TA__c, User__c '+
            'FROM MA_Referral_Roster__c  '+
            'WHERE  Is_Active__c = true  AND Is_Active_User__c = true AND User__c != null '+
            'AND TA__c IN : tas ';
    }


    private TerritoryWrapper createTerritoryWrapper(String terrNumber, List<String> tas){
        TerritoryWrapper tw = new TerritoryWrapper();
        tw.territoryNumber = terrNumber;
        tw.TA = new Set<String>(tas);
        if(tw.TA.contains(null)) tw.TA.remove(null);
        return tw;
    }

    private void findMedAffairsToRemove(
        Set<Id> medAffairUsersIds,
        List<My_Territory_Team_gne__c> mtts,
        String terrNumber,
        TerritoryHolder terrHolder
    ) {
        for(My_Territory_Team_gne__c mtt : mtts){
            String userId = mtt.UserId_gne__c;
            Boolean isRecordToRemove = !terrHolder.medAffairsUserTAs.contains(userId);
            if(isRecordToRemove){
                toDelete.put(mtt.Id, mtt);
            } else {
                if(toDelete.containsKey(mtt.Id)) {
                    toDelete.remove(mtt.Id);
                }
            }
        }
    }

    private TerritoryHolder fetchTerrHolder(TerritoryWrapper tw) {
        TerritoryHolder terrHolder = territoriesHolder.get(tw.territoryNumber) == null ? new TerritoryHolder(tw) : territoriesHolder.get(tw.territoryNumber);
        territoriesHolder.put(tw.territoryNumber, terrHolder);
        return terrHolder;
    }

    class TerritoryWrapper{
        String territoryNumber;
        Set<String> TA;
    }

    class TerritoryHolder{
        String territoryNumber;

        Set<Id> medAffairsUserTAs;

        public TerritoryHolder(TerritoryWrapper tw){
            this.territoryNumber = tw.territoryNumber;
            medAffairsUserTAs = new Set<Id>();
        }

        public void updateUsers(Set<Id> usersId){
            medAffairsUserTAs.addAll(usersId);
        }
    }
}