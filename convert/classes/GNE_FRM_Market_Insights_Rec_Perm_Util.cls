/**
 * Utility class to check the permission of the given user to access the group of records.
 * Note that this class is and should be running in system mode (without sharing).
 * 
 * @author Michal Zaganczyk (michal.zaganczyk@contractors.roche.com)
 */
public without sharing class GNE_FRM_Market_Insights_Rec_Perm_Util {
	
	/**
	 * Maximum nuber of records which can be queried at once from UserRecordAccess. 
	 * The value corresponds to the specific SFDC limit.
	 */
	private final Integer USER_RECORD_ACCESS_CHUNK_SIZE = 200;
	
	/**
	 * Loads UserRecordAccess for the given UserId and list of record Ids.
	 * Note that the list of Ids is externally limited by the caller, thus this method is and should stay private.
	 * To be called by the "loadUserRecordAccess" method only.
	 */
	private List<UserRecordAccess> loadUserRecordAccessChunk(Id userId, List<Id> recordIds) {
		return [
			SELECT
				RecordId,
				HasAllAccess,
				HasDeleteAccess,
				HasEditAccess,
				HasTransferAccess,
				HasReadAccess,
				MaxAccessLevel
			FROM
				UserRecordAccess 
			WHERE 
				UserId = :userId AND 
				RecordId IN :recordIds
		];
	}
	
	/**
	 * Loads UserRecordAccess for the given UserId and list of record Ids. Due to SFDC limit (allows querying 
	 * up to 200 records at once only), the list of Ids is divided into chunks with size of 200 and querying is 
	 * called as many times as needed. This allows to check at once much more records (even up to the maximum 
	 * record-read limit) instead of 200 only.
	 */
	public List<UserRecordAccess> loadUserRecordAccess(Id userId, List<Id> recordIds) {
		List<UserRecordAccess> result = new List<UserRecordAccess>();
		if ((null != userId) && (null != recordIds) && (!recordIds.isEmpty())) {
			Integer numRecordsToCheck = recordIds.size();
			Integer numRecordsChecked = 0;
			while (numRecordsToCheck > numRecordsChecked) {
				List<Id> recordIdsChunk = new List<Id>();
				Integer i = 0;
				while ((numRecordsToCheck > numRecordsChecked + i) && (i < USER_RECORD_ACCESS_CHUNK_SIZE)) {
					recordIdsChunk.add(recordIds[numRecordsChecked + i]);
					i++;
				}
				numRecordsChecked += i;
				result.addAll(this.loadUserRecordAccessChunk(userId, recordIdsChunk));
			}
		}
		return result;
	}
	
	/**
	 * Loads UserRecordAccess for the given UserId and list of record Ids and wraps the results into a Map.
	 * Most of the time we will need to check record access for individual records, so the map key is the RecordId.
	 * This allows for fast search of UserRecordAccess for record.
	 */
	public Map<Id, UserRecordAccess> loadUserRecordAccessAsMapWithRecordIdAsKey(Id userId, List<Id> recordIds) {
		Map<Id, UserRecordAccess> result = new Map<Id, UserRecordAccess>();
		List<UserRecordAccess> userRecordAccList = this.loadUserRecordAccess(userId, recordIds);
		for (UserRecordAccess userRecordAcc : userRecordAccList)
			result.put(userRecordAcc.RecordId, userRecordAcc);
		return result;
	}
}