/**
 * 
 * @author Michal Zaganczyk (michal.zaganczyk@contractors.roche.com)
 */
public class GNE_FRM_Market_Insights_Case_Assoc_Util {
	
	/**
	 * 
	 */
	public class CaseWrapper extends GNE_FRM_Market_Insights_Wrappers.RecordWrapper {
		
		/**
		 * Constructor. Wraps given record. Sets the "hasReadAccess" to the default value of "true".
		 * 
		 * @param aCase A Case record to be wrapped.
		 */
		public CaseWrapper(Case aCase) {
			super(aCase);
			this.hasReadAccess = true;
		}
		
		/**
		 * Provides the strongly-typed reference to the wrapped record.
		 */
		public Case caseRecord {
			get {
				return (Case) this.record;
			}
		}
		
		/**
		 * Stores the user access flag for current user.
		 */
		public Boolean hasReadAccess {get; set;}
	}
	
	/**
	 * Custom list of CaseWrapper elements. Can load and save the Case records associated with a Market Insight.
	 * 
	 * Note that this class need to run in system mode, thus the "without sharing" modifier.
	 */
	public without sharing class MarketInsightCaseAssociations extends GNE_FRM_Market_Insights_Wrappers.RecordWrapperList{
		
		/**
		 * Creates the list of elements (called by the base class but implemented here to provide strong-typed access 
		 * to the list).
		 */
		protected override List<RecordWrapper> createElementsList() {
			return new List<CaseWrapper>();
		}
		
		/**
		 * Wraps a record with the specific CaseWrapper class.
		 */
		protected override GNE_FRM_Market_Insights_Wrappers.RecordWrapper wrapRecord(SObject record) {
			return new CaseWrapper((Case) record);
		}
		
		/**
		 * Typecasted list of elements to have easy access without too much typecasting on the elements.
		 */
		public List<CaseWrapper> elements {
			get {
				return (List<CaseWrapper>) this.elementsList;
			}
		}
		
		/**
		 * Loads associated Case records by reading the Insight_Case_Association_gn__c junction object records having 
		 * the Market_Insight_gne__c field set to the ID equal to the Id of current MarketInsight (if not null).
		 * We use the SOQL with subquery (instead of grabbing the cases from Insight_Case_Associations_gne__c by 
		 * relation field), because we need to fetch and operate later on the Case records, not the 
		 * Insight_Case_Associations_gne__c records.
		 * @param marketInsightId Id of a Market Insight record to load cases associated with this record.
		 */
		private List<Case> loadAssociatedCaseRecords(Id marketInsightId) {
			if (null == marketInsightId) {
				return new List<Case>();
			} else {
				return [
					SELECT
						Id,
						CaseNumber,
						RecordType.Name,
						Product_gne__c,
						Practice_Id_gne__c,
						Practice_gne__r.Name
					FROM
						Case
					WHERE
						Id IN (
							SELECT
								Case_gne__c
							FROM
								Insight_Case_Association_gne__c
							WHERE
								Market_Insight_gne__c = :marketInsightId
						)
					ORDER BY
						Id ASC
				];
			}
		}
		
		/**
		 * Gets the Ids of the records from the given list.
		 * @param objList List of SObject to get their Ids.
		 */
		private Set<Id> getIds(List<SObject> objList) {
			Set<Id> result = new Set<Id>();
			for (SObject o : objList) {
				result.add(o.Id);
			}
			return result;
		}
		
		/**
		 * Loads the records of Cases associated with the Market Insight having the given Id and populates the list.
		 * @param marketInsightId Id of the Market Insight record to get the associated Cases.
		 */
		public void load(Id marketInsightId) {
			this.clear();
			this.addAll(this.loadAssociatedCaseRecords(marketInsightId));
			this.checkRecordAccessLevel();
		}
		
		/**
		 * Saves the associations between the Market Insight and linked Cases.
		 * Because we are using the "last-wins" scenario, then to avoid the situation when some other user saved 
		 * Market Insight record with different cases linked, we cannot rely on the state persisted in the class 
		 * (initialized when we were loading the data). Instead of that we need to reload cases linked to the 
		 * Market Insight just before save, and then analyze which records we need to delete and which we need to 
		 * insert to persist current state.
		 */
		public void save(Id marketInsightId) {
			Set<Id> caseIdsToUnLink = this.getIds(this.loadAssociatedCaseRecords(marketInsightId));
			Set<Id> caseIdsToLink = new Set<Id>(this.getRecordIds());
			Set<Id> commonIds = new Set<Id>(caseIdsToUnLink);
			commonIds.retainAll(caseIdsToLink);
			caseIdsToUnlink.removeAll(commonIds);
			caseIdsToLink.removeAll(commonIds);
			List<Insight_Case_Association_gne__c> caseAssociationsToInsert = new List<Insight_Case_Association_gne__c>();
			for (Id id : caseIdsToLink)
				caseAssociationsToInsert.add(new Insight_Case_Association_gne__c(Market_Insight_gne__c = marketInsightId, Case_gne__c = id));
			insert caseAssociationsToInsert;
			List<Insight_Case_Association_gne__c> caseAssociationsToDelete = [
				SELECT Id FROM Insight_Case_Association_gne__c WHERE Market_Insight_gne__c = :marketInsightId AND Case_gne__c IN :caseIdsToUnlink];
			delete caseAssociationsToDelete;
		}
		
		/**
		 * Checks the read access to the records with given Ids for current user. 
		 * Note that the default value of hasReadAccess in the wrapper class is "true".
		 */
		private void checkRecordAccessLevel() {
			GNE_FRM_Market_Insights_Rec_Perm_Util rpu = new GNE_FRM_Market_Insights_Rec_Perm_Util();
			Map<Id, UserRecordAccess> m = rpu.loadUserRecordAccessAsMapWithRecordIdAsKey(UserInfo.getUserId(), this.getRecordIds());
			for (CaseWrapper cw : this.elements) {
				UserRecordAccess userRecAcc = m.get(cw.caseRecord.Id);
				cw.hasReadAccess = ((userRecAcc != null) && (userRecAcc.HasReadAccess));
			}
		}
	}
}