/** @date 5/26/2015
* @Author Konrad Malinowski
* @description Class for counting records from VDST tables
*/
public without sharing class VDST_RecordCount_gne {
	public final String[] tableNames = new String[]{
        'VDST_Address_gne__c',
        'VDST_Event_gne__c',
        'VDST_EventBrandTopic_gne__c',
        'VDST_EventDate_gne__c',
        'VDST_EventDateTransaction_gne__c',
        'VDST_EventPrtcpntAccnt_gne__c',
        'VDST_EventPrtcpntAttendance_gne__c',
        'VDST_EventSite_gne__c',
        'VDST_EventTransactionSummary_gne__c',
        'VDST_PrtcpntTransaction_gne__c'
    };
    public List<VDST_RecordCount_gne__c> recordCounts;
    public Map<String, Integer> previousAllRecordsBySObjectNameMap;
    public Datetime yesterdayStart;

    /** @date 5/26/2015
    * @Author Konrad Malinowski
    * @description VDST_RecordCount_gne constructor
    */
    public VDST_RecordCount_gne() {
        recordCounts = new List<VDST_RecordCount_gne__c>();
        previousAllRecordsBySObjectNameMap = new Map<String, Integer>();
        yesterdayStart = System.now().addDays(-1);
        yesterdayStart = Datetime.newInstance(yesterdayStart.year(), yesterdayStart.month(), yesterdayStart.day());
	}

    /** @date 5/26/2015
    * @Author Konrad Malinowski
    * @description Method for executing counting process
    */
    public void execute() {
        getPreviousRecordCounts();
        for (String t : tableNames) {
            countRecordsInTable(t);
        }
        insert recordCounts;
    }

    /** @date 5/26/2015
    * @Author Konrad Malinowski
    * @description Method for getting previous record counts
    */
    public void getPreviousRecordCounts() {
        Date dayBeforeYesterday = System.today().addDays(-2);
        List<VDST_RecordCount_gne__c> prevRecordCounts = [
            SELECT SObject_Name_gne__c, All_Records_gne__c
            FROM VDST_RecordCount_gne__c
            WHERE Date_gne__c = :dayBeforeYesterday
        ];
        for (VDST_RecordCount_gne__c rc : prevRecordCounts) {
            previousAllRecordsBySObjectNameMap.put(rc.SObject_Name_gne__c, rc.All_Records_gne__c.intValue());
        }
    }

    /** @date 5/26/2015
    * @Author Konrad Malinowski
    * @description Method for counting records in table
    * @param String tableName
    */
    public void countRecordsInTable(String tableName) {
        String qry = 'SELECT Id, CreatedDate, LastModifiedDate, IsDeleted ' +
            'FROM ' + tableName + ' ' +
            'WHERE CreatedDate = YESTERDAY OR LastModifiedDate = YESTERDAY ' +
            'ALL ROWS';
        Integer inserted = 0, updated = 0, deleted = 0;
        for (sObject obj : Database.query(qry)) {
            Boolean isDeleted = (Boolean)obj.get('IsDeleted');
            Datetime createdDate = (Datetime)obj.get('CreatedDate');
            Datetime lastModifiedDate = (Datetime)obj.get('LastModifiedDate');
            Boolean isInserted = !isDeleted && yesterdayStart < createdDate;
            Boolean isUpdated = !isDeleted && createdDate < yesterdayStart && createdDate != lastModifiedDate;
            updated += (isUpdated ? 1 : 0);
            inserted += (isInserted ? 1 : 0);
            Boolean isCreatedAndDeletedSameDay = isDeleted && yesterdayStart < createdDate;
            deleted += (isDeleted && !isCreatedAndDeletedSameDay ? 1 : 0);
        }
        Integer allRecordsDiff = inserted - deleted;
        Date yesterday = System.today().addDays(-1);
        recordCounts.add(
            new VDST_RecordCount_gne__c(
                SObject_Name_gne__c = tableName,
                Date_gne__c = yesterday,
                All_Records_gne__c = (previousAllRecordsBySObjectNameMap.get(tableName) + allRecordsDiff),
                Inserted_Records_gne__c = inserted,
                Updated_Records_gne__c = updated,
                Deleted_Records_gne__c = deleted
            )
        );
    }
}