/** @date 8/31/2012
* @Author Pawel Sprysak
* @description Utility class for pagination and sorting
*/
public without sharing class AGS_ST_DMPagingAndSortingUtils {
	// Lists
	private ApexPages.StandardSetController sscObject { get; set; }
    public transient List<Dispute> disputeTransientList { get; set; }
    private List<Dispute> disputeList { get; set; }
	// Paging values
    public Integer perPage {
    	get;
		set {
			perPage = value;
			if(totalDisputes > 0) {
				setParameters(totalDisputes);
			}
		}
	}
    public Integer actualPage { get; set; }
    public Integer totalPages { get; set; }
    public Integer totalDisputes { get; set; }
    private Integer maxOnPage { get; set; }
	// Sorting values
    public String sortField { get; set; }
    public String sortOrder { get; set; }
    public String previousSortField { get; set; }
    // Values for comparation
    public Integer prevActualPage { get; set; }
    public Integer prevPerPage { get; set; }
    public String prevSortField { get; set; }
    public String prevSortOrder { get; set; }

	/** @date 8/31/2012
	* @Author Pawel Sprysak
	* @description Default constructor
	*/
	public AGS_ST_DMPagingAndSortingUtils() {
		this(10);
	}

	/** @date 8/31/2012
	* @Author Pawel Sprysak
	* @description Parameterized constructor with "number elements per page" argument
	* @param Integer perPageVal (number of elements per page)
	*/
	public AGS_ST_DMPagingAndSortingUtils(Integer perPageVal) {
	    disputeList = new List<Dispute>();
	    perPage = perPageVal;
	    actualPage = 1;
	}

	/** @date 8/31/2012
	* @Author Pawel Sprysak
	* @description Parameterized constructor with "number elements per page", "default sorting field name", "default sorting field order" arguments
	* @param Integer perPageVal (number of elements per page)
	* @param String sortingFieldVal (sorting field name)
	* @param String sortingOrderVal (sorting order)
	*/
	public AGS_ST_DMPagingAndSortingUtils(Integer perPageVal, String sortingFieldVal, String sortingOrderVal) {
		this(perPageVal);
	    sortField = sortingFieldVal;
	    sortOrder = sortingOrderVal;
	}

	/** @date 8/31/2012
	* @Author Pawel Sprysak
	* @description Method which creates list of wrapped disputes and initialize variables
	* @param List<AGS_ST_DisputeManagement_gne__c> disputeManList
	* @param Boolean isRecipientNeeded
	*/
    public void createDisputeList(List<AGS_ST_DisputeManagement_gne__c> disputeManList, Boolean isRecipientNeeded) {
    	// Filling dispute list
        disputeList.clear();
        List<Id> recipientListId = new List<Id>();
        for(AGS_ST_DisputeManagement_gne__c disputeMan : disputeManList) {
            if(isRecipientNeeded) {
            	recipientListId.add(disputeMan.AGS_Spend_Expense_Transaction_gne__r.Primary_Recipient_gne__c);
            }
            disputeList.add(new Dispute(disputeMan));
        }
	    // Initializing variables
        if(sortOrder==null){
			sortOrder='asc';
			sortField='Dispute_Case';
		}
        previousSortField = '';
        doSort();
        actualPage = 1;
        totalDisputes = disputeManList.size();
    }

	/** @date 8/31/2012
	* @Author Pawel Sprysak
	* @description Method which creates list of wrapped disputes, set part of them to Transient List and initialize variables
	* @param ApexPages.StandardSetController sscObject (StandardSetController from which dispute list is created)
	*/
    public void createDMList(ApexPages.StandardSetController sscObject) {
    	// Filling dispute list
        setParameters(sscObject.getResultSize());
        // Setting variables
        sscObject.setPageSize(perPage);
        // Get partial disputes
        sscObject.first();
        for(Integer i=1; i<actualPage; i++) {
            sscObject.next();
        }
        disputeTransientList = new List<Dispute>();
        for(AGS_ST_DisputeManagement_gne__c disputeMan : (List<AGS_ST_DisputeManagement_gne__c>)sscObject.getRecords()) {
            disputeTransientList.add(new Dispute(disputeMan));
        }
    }

	/** @date 1/15/2013
	* @Author Pawel Sprysak
	* @description Get list of Id's from Dispute List
	* @return List<Id>
	*/
	public List<Id> getDisputeIdList() {
        List<Id> idList = new List<Id>();
        for(Dispute dsp : disputeTransientList) {
        	idList.add(dsp.disputeBase.Id);
		}
		return idList;
	}

	/** @date 8/31/2012
	* @Author Pawel Sprysak
	* @description Method for creating duplicates of util values
	*/
	public void duplicateValues() {
		prevPerPage = perPage;
		prevActualPage = actualPage;
		prevSortField = sortField;
		prevSortOrder = sortOrder;
	}

	/** @date 8/31/2012
	* @Author Pawel Sprysak
	* @description Method for comparation new & old util values
	* @return Boolean
	*/
	public Boolean compareValues() {
		if(prevPerPage == perPage && prevActualPage == actualPage && prevSortField == sortField && prevSortOrder == sortOrder) {
			return true;
		} else {
			return false;
		}
	}

	/** @date 8/31/2012
	* @Author Pawel Sprysak
	* @description Sorting method
	*/
    public void doSort(){
        doDBSort();
        SuperSort.sortList(disputeList, sortField, sortOrder);
    }

	/** @date 8/31/2012
	* @Author Pawel Sprysak
	* @description Sorting method for Database sorting
	*/
    public void doDBSort(){
        if(sortField == previousSortField && sortOrder == 'asc') {
        	sortOrder = 'desc';
        } else {
        	sortOrder = 'asc';
        }
        previousSortField = sortField;
    }

	/** @date 8/31/2012
	* @Author Pawel Sprysak
	* @description Getter for per page possibility options
	* @return List<SelectOption>
	*/
    public List<SelectOption> getPerPageOptions() {
        List<SelectOption> optionList = new List<SelectOption>();
        optionList.add(new SelectOption('5', '5'));
        optionList.add(new SelectOption('10', '10'));
        optionList.add(new SelectOption('25', '25'));
        optionList.add(new SelectOption('50', '50'));
        optionList.add(new SelectOption('100', '100'));
        optionList.add(new SelectOption('500', '500'));
        return optionList;
    }

	/** @date 8/31/2012
	* @Author Pawel Sprysak
	* @description Go to first page method
	* @return PageReference
	*/
    public PageReference firstPage() {
        actualPage = 1;
        return null;
    }

	/** @date 8/31/2012
	* @Author Pawel Sprysak
	* @description Go to previous page method
	* @return PageReference
	*/
    public PageReference prevPage() {
        if(actualPage > 1) actualPage--;
        return null;
    }

	/** @date 8/31/2012
	* @Author Pawel Sprysak
	* @description Go to next page method
	* @return PageReference
	*/
    public PageReference nextPage() {
        if(actualPage < totalPages) actualPage++;
        return null;
    }

	/** @date 8/31/2012
	* @Author Pawel Sprysak
	* @description Go to last page method
	* @return PageReference
	*/
    public PageReference lastPage() {
        actualPage = totalPages;
        return null;
    }

	/** @date 8/31/2012
	* @Author Pawel Sprysak
	* @description Change per page value (after changing perPage value on Page, this method is invoking to change actual page to first)
	* @return PageReference
	*/
    public PageReference changePerPageValue() {
        actualPage = 1;
        return null;
    }

	/** @date 8/31/2012
	* @Author Pawel Sprysak
	* @description Getter for dispute wrapper list
	* @return List<Dispute>
	*/
    public List<Dispute> getDisputeForPage() {
    	setParameters(disputeList.size());
        if(disputeList.size()>0) {
            List<Dispute> newList = new List<Dispute>();
            for(Integer i=(actualPage-1)*perPage; i<maxOnPage; i++) {
                newList.add(disputeList.get(i));
            }
            return newList;
        } else {
            return new List<Dispute>();
        }
    }

	/** @date 8/31/2012
	* @Author Pawel Sprysak
	* @description Method for setting new parameters for Util
	* @param Integer listSize
	*/
    public void setParameters(Integer listSize) {
        if(listSize>0) {
            if(actualPage <= 0) {
            	actualPage=1;
            }
            if(perPage == null) {
            	perPage = 5;
            }
            maxOnPage = actualPage*perPage;
            if(listSize < actualPage*perPage) {
            	maxOnPage = listSize;
            }
            Decimal totalPagesDec = (Decimal)listSize / (Decimal)perPage;
            totalPages = (totalPagesDec.round(RoundingMode.UP)).intValue();
            totalDisputes = listSize;
            if(actualPage > totalPages) {
            	actualPage = totalPages;
            }
        } else {
            totalDisputes = 0;
            totalPages = 0;
        }
    }

	/** @date 8/31/2012
	* @Author Pawel Sprysak
	* @description Inner class: Wrapper for AGS_ST_DisputeManagement_gne__c
	*/
    public class Dispute implements IReflection {
    	// Getters and setters
        public AGS_ST_DisputeManagement_gne__c disputeBase { get; private set; }
        /*
        public String getAddress() {
            String address = disputeBase.AGS_Spend_Expense_Transaction_gne__r.Primary_Recipient_gne__r.Address_Line_1_gne__c;
            if(disputeBase.AGS_Spend_Expense_Transaction_gne__r.Primary_Recipient_gne__r.Address_line_2_gne__c != null && disputeBase.AGS_Spend_Expense_Transaction_gne__r.Primary_Recipient_gne__r.Address_line_2_gne__c != '') {
            	address += ', ' + disputeBase.AGS_Spend_Expense_Transaction_gne__r.Primary_Recipient_gne__r.Address_Line_2_gne__c;
            }
            address += ', ' + disputeBase.AGS_Spend_Expense_Transaction_gne__r.Primary_Recipient_gne__r.City_gne__c + ', ' + disputeBase.AGS_Spend_Expense_Transaction_gne__r.Primary_Recipient_gne__r.State_gne__c + ' - ' + disputeBase.AGS_Spend_Expense_Transaction_gne__r.Primary_Recipient_gne__r.Zip_gne__c;
            return address;
        }
        */
        public Boolean isFromDM() {
        	return (disputeBase.Internal_Status_gne__c == 'Corrected Pending SSR' || disputeBase.Internal_Status_gne__c == 'Resolved With Correction');
        }
        public Decimal getAmount() {
        	return disputeBase.Amount_frm_gne__c;
        }
        public String getDrugName() {

        	return disputeBase.Drug_Name_frm_gne__c;
        }
        public String getNatureOfPayment() {
        	return disputeBase.Nature_Of_Payment_frm_gne__c;
        }
        public String getFormOfPayment() {
        	return disputeBase.Form_Of_Payment_frm_gne__c;
        }
        public String getDisputeDate() {
            return disputeBase.CreatedDate.format('M/d/yyyy h:mm a');
        }
        public String getSpendActivityDate() {
        	return disputeBase.LastModifiedDate.format('M/d/yyyy h:mm a');
        }
        public String getPaymentDate() {
        	if(disputeBase.AGS_Spend_Expense_Transaction_gne__r.Event_Date_gne__c != null) {
        		return disputeBase.AGS_Spend_Expense_Transaction_gne__r.Event_Date_gne__c.format();
        	} else {
        		return '';
        	}
        }

        // Constructor
        public Dispute(AGS_ST_DisputeManagement_gne__c dispute) {
            disputeBase = dispute;
        }

        // Method needed to sort elements
        public object getValue(String name) {
            if(name.equals('Amount_frm_gne__c') || name.equals('Amount_gne__c')) {
                return getAmount();
            }else if(name.equals('Internal_Status_gne__c')) {
                return disputeBase.Internal_Status_gne__c;
            } else if(name.equals('Form_Of_Payment_gne__c') || name.equals('Form_Of_Payment_frm_gne__c')) {
                return getFormOfPayment();
            } else if(name.equals('Nature_Of_Payment_gne__c') || name.equals('Nature_Of_Payment_frm_gne__c')) {
                return getNatureOfPayment();
            } else if(name.equals('Drug_Name_gne__c') || name.equals('Drug_Name_frm_gne__c')) {
                return getDrugName();
            } else if(name.equals('AGS_Spend_Expense_Transaction_gne__r.Party1_Specialty_gne__c') && disputeBase.AGS_Spend_Expense_Transaction_gne__r!=null) {
                return disputeBase.AGS_Spend_Expense_Transaction_gne__r.Party1_Specialty_gne__c;
            } else if(name.equals('AGS_Spend_Expense_Transaction_gne__r.Party1_NPI_gne__c') && disputeBase.AGS_Spend_Expense_Transaction_gne__r!=null) {
                return disputeBase.AGS_Spend_Expense_Transaction_gne__r.Party1_NPI_gne__c;
            } else if(name.equals('AGS_Spend_Expense_Transaction_gne__r.Party1_Name_gne__c') && disputeBase.AGS_Spend_Expense_Transaction_gne__r!=null) {
                return disputeBase.AGS_Spend_Expense_Transaction_gne__r.Party1_Name_gne__c;
            } else if(name.equals('AGS_Spend_Expense_Transaction_gne__r.Party2_Name_gne__c') && disputeBase.AGS_Spend_Expense_Transaction_gne__r!=null) {
                return disputeBase.AGS_Spend_Expense_Transaction_gne__r.Party2_Name_gne__c;
            } else if(name.equals('Name')) {
                return disputeBase.Name;
            } else if(name.equals('Dispute_Resolver_gne__r.Owner.Name') && disputeBase.Dispute_Resolver_gne__c!=null && !disputeBase.Internal_Status_gne__c.equals('Submitted')) {
                return disputeBase.Dispute_Resolver_gne__r.Owner.Name;
            } else if(name.equals('Dispute_List_gne__r.IsCmsDispute_gne__c')) {
                return disputeBase.Dispute_List_gne__r.IsCmsDispute_gne__c;
            } else if(name.equals('Dispute_List_gne__r.CmsDisputeId_gne__c')) {
                return disputeBase.Dispute_List_gne__r.CmsDisputeId_gne__c;
            } else if(name.equals('AGS_Spend_Expense_Transaction_gne__r.Event_Date_gne__c') && disputeBase.AGS_Spend_Expense_Transaction_gne__c!=null) {
                return Datetime.newInstance(disputeBase.AGS_Spend_Expense_Transaction_gne__r.Event_Date_gne__c, Time.newInstance(12, 0, 0, 0)).format('yyyy-MM-dd');
            } else if(name.equals('CreatedDate')) {
                return disputeBase.CreatedDate.format('yyyy-MM-dd HH:mm');
            } else if(name.equals('LastModifiedDate')) {
                return disputeBase.LastModifiedDate.format('yyyy-MM-dd HH:mm');
            } else if(name.equals('Owner.Name')){
            	return disputeBase.Owner.Name;
            } else {
            	return '';
            }
        }
    }
}