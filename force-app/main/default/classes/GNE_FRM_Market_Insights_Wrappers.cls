/**
 * 
 * @author Michal Zaganczyk (michal.zaganczyk@contractors.roche.com)
 */
public class GNE_FRM_Market_Insights_Wrappers {
	
	/**
	 * Record wrapper adding a functionality of storing the information about its index in the containing list.
	 * The index in list is sometimes needed from the element level and therefore it is stored here. 
	 * It will be used also to preserve the order of records and to avoid exhaustive search (in some cases).
	 */
	public abstract class RecordWrapper {
		
		/**
		 * Stores the reference to the wrapped record.
		 * 
		 * The specific descendant classes can implement a public getter of type corresponding to the wrapped record 
		 * (for accessing the specific, non-abstract SObject type) by typecasting.
		 */
		public final SObject record {get; private set;}
		
		/**
		 * Stores an index of this element in the parent list.
		 */
		public Integer index {get; set;}
		
		/**
		 * Constructor. Initializes the index to a negative value to mark that the element is not in a list yet.
		 * @param aRecord A record to be wrapped.
		 */
		protected RecordWrapper(SObject aRecord) {
			this.index = -1;
			this.record = aRecord;
		}
	}
	
	/********************************************* RecordWrapperList **************************************************/
	
	/**
	 * Custom list of RecordWrapper elements.
	 */
	public abstract class RecordWrapperList {
		
		/**
		 * Stores the wrapped records.
		 */
		protected final List<RecordWrapper> elementsList;
		
		/**
		 * Creates a list to store the wrapped records. To be implemented in specific non-abstract descendant classes. 
		 * The implementation should create the typed list for wrapper class specific for the record.
		 */
		protected abstract List<RecordWrapper> createElementsList();
		
		/**
		 * Wraps a record with the specific RecordWrapper class. To be implemented in specific non-abstract 
		 * descendant classes. The implementation should wrap the record with the wrapper specific for the record.
		 */
		protected abstract RecordWrapper wrapRecord(SObject record);
		
		/**
		 * Constructor.
		 */
		public RecordWrapperList() {
			this.elementsList = this.createElementsList();
		}
		
		/**
		 * Iterates over all the elements in this list and updates the index field on each element.
		 */
		protected void reindexElements() {
			for (Integer i = 0, j = this.elementsList.size(); i < j; i++) {
				this.elementsList[i].index = i;
			}
		}
		
		/**
		 * Wraps and adds a record to this list.
		 * @param record Record to add.
		 * @return New, wrapped record, which has been added (with updated index).
		 */
		public RecordWrapper add(SObject record) {
			return this.add(null, record);
		}
		
		/**
		 * Adds an element to this list.
		 * @param rw Element to add.
		 * @return Wrapped record, which has been added (with updated index).
		 */
		public RecordWrapper add(RecordWrapper rw) {
			return this.add(null, rw);
		}
		
		/**
		 * Adds an element to this list.
		 * @param index Index in this list which the added element should have.
		 * @param record Record to add.
		 * @return New, wrapped record, which has been added (with updated index).
		 */
		public RecordWrapper add(Integer atIndex, SObject record) {
			RecordWrapper result = this.wrapRecord(record);
			if (null == atIndex) {
				this.elementsList.add(result);
				result.index = this.elementsList.size() - 1;
			} else {
				this.elementsList.add(atIndex, result);
				this.reindexElements();
			}
			return result;
		}
		
		/**
		 * Adds an element to this list.
		 * @param index Index in this list which the added element should have.
		 * @param element Element to add.
		 * @return Wrapped record, which has been added (with updated index).
		 */
		public RecordWrapper add(Integer atIndex, RecordWrapper rw) {
			if (null == atIndex) {
				this.elementsList.add(rw);
				rw.index = this.elementsList.size() - 1;
			} else {
				this.elementsList.add(atIndex, rw);
				this.reindexElements();
			}
			return rw;
		}
		
		/**
		 * Adds all of the elements from the given list to this list.
		 * @param records List of records to add to this list.
		 */
		public void addAll(List<SObject> records) {
			Integer size = this.elementsList.size();
			for (SObject record : records) {
				this.elementsList.add(this.wrapRecord(record));
				this.elementsList[size - 1].index = size++;
			}
		}
		
		/**
		 * Removes the element stored in this list under the given index.
		 * @param index Index of an element to remove from this list.
		 * @return Removed element.
		 */
		public RecordWrapper remove(Integer atIndex) {
			Boolean notLastElement = (this.elementsList.size() != atIndex + 1);
			RecordWrapper result = this.elementsList.remove(atIndex);
			result.index = -1;
			if (notLastElement)
				this.reindexElements();
			return result;
		}
		
		/**
		 * Removes all the elements from this list.
		 */
		public void clear() {
			List<RecordWrapper> tmp = new List<RecordWrapper>(this.elementsList);
			this.elementsList.clear();
			for (RecordWrapper rw : tmp)
				rw.index = -1;
		}
		
		/**
		 * Gets the Ids of wrapped records as a List.
		 */
		public List<Id> getRecordIds() {
			List<Id> result = new List<Id>();
			for (RecordWrapper rw : this.elementsList)
				result.add(rw.record.Id);
			return result;
		}
	}
}