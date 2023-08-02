/** @date 3/11/2013
* @Author Pawel Sprysak
* @description Utility class for pagination and sorting
*/
public without sharing class VDST_PagingAndSortingUtils {
    private transient               ApexPages.StandardSetController sscObject { get; set; }
    private List<EventWrapper>      eventList       { get; set; }
    private String listType                         { get; set; }
    public VDST_EventDetailCommon   commonUtils     { get; set; }
    // Paging values
    public Integer perPage {
        get;
        set {
            perPage = value;
            if(totalElements > 0) {
                setParameters(totalElements);
            }
        }
    }
    public Integer                  actualPage      { get; set; }
    public Integer                  totalPages      { get; set; }
    public Integer                  totalElements   { get; set; }
    private Integer                 maxOnPage       { get; set; }
    // Sorting values
    public String                   sortField       { get; set; }
    public String                   sortOrder       { get; set; }
    public String                   previousSortField { get; set; }
    public String                   previousSortOrder { get; set; }
    // Holder list
    private List<EventWrapper>      listToSort      { get; set; }
    // List param
    private Id                      listProvierId   { get; set; }

    /** @date 3/11/2013
    * @Author Pawel Sprysak
    * @description Parameterized constructor with "number elements per page" argument
    * @param Integer perPageVal (number of elements per page), String listTypeVal (List Type)
    */
    public VDST_PagingAndSortingUtils(Integer perPageVal, String listTypeVal) {
    	sortField = 'stDate';
    	sortOrder = 'asc';
        perPage = perPageVal;
        listType = listTypeVal;
        actualPage = 1;
        commonUtils = new VDST_EventDetailCommon();
    }

    /** @date 3/11/2013
    * @Author Pawel Sprysak
    * @description Parameterized constructor for Event List
    * @param Integer perPageVal (number of elements per page), String listTypeVal (List Type), Id providerId (Provider Id)
    */
    public VDST_PagingAndSortingUtils(Integer perPageVal, String listTypeVal, Id providerId) {
    	this(perPageVal, listTypeVal);
    	listProvierId = providerId;
    	createList();
    }

    /** @date 4/23/2013
    * @Author Pawel Sprysak
    * @description Method for handling no param creating list invokes
    */
    public void createList() {
    	createList(false);
    }

    /** @date 3/11/2013
    * @Author Pawel Sprysak
    * @description Create List method
    */
    public void createList(Boolean doReload) {
    	if(!sortOrder.equals(previousSortOrder) || !sortField.equals(previousSortField) || doReload) {
    		actualPage = 1;
	    	listToSort = new List<EventWrapper>();
	    	for(VDST_Event_gne__c disputeMan : VDST_Utils.getEventList(listProvierId)) {
	    		listToSort.add(new EventWrapper(disputeMan, commonUtils));
	    	}
	    	SuperSort.sortList(listToSort, sortField, sortOrder);
	    	setParameters(listToSort.size());
	        previousSortField = sortField;
	        previousSortOrder = sortOrder;
    	}
    	eventList = new List<EventWrapper>();
    	Integer startIndx = (actualPage-1)*perPage;
    	for(Integer i=startIndx; i<startIndx+perPage; i++) {
    		if(i < listToSort.size()) {
    		    eventList.add(listToSort.get(i));
    		}
    	}
    }

    /** @date 3/11/2013
    * @Author Pawel Sprysak
    * @description Get Event List
    * @return List<VDST_Event_gne__c>
    */
    public List<EventWrapper> getVFEventList() {
        if(eventList == null) {
            return new List<EventWrapper>();
        } else {
            return eventList;
        }
    }

    /** @date 3/11/2013
    * @Author Pawel Sprysak
    * @description Sorting method for Database sorting
    */
    public void doSort() {
        if(sortField == previousSortField && sortOrder == 'asc') {
            sortOrder = 'desc';
        } else {
            sortOrder = 'asc';
        }
        createList();
    }

    /** @date 3/11/2013
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

    /** @date 3/11/2013
    * @Author Pawel Sprysak
    * @description Go to first page method
    * @return PageReference
    */
    public PageReference firstPage() {
        actualPage = 1;
        createList();
        return null;
    }

    /** @date 3/11/2013
    * @Author Pawel Sprysak
    * @description Go to previous page method
    * @return PageReference
    */
    public PageReference prevPage() {
        if(actualPage > 1) actualPage--;
        createList();
        return null;
    }

    /** @date 3/11/2013
    * @Author Pawel Sprysak
    * @description Go to next page method
    * @return PageReference
    */
    public PageReference nextPage() {
        if(actualPage < totalPages) actualPage++;
        createList();
        return null;
    }

    /** @date 3/11/2013
    * @Author Pawel Sprysak
    * @description Go to last page method
    * @return PageReference
    */
    public PageReference lastPage() {
        actualPage = totalPages;
        createList();
        return null;
    }

    /** @date 3/11/2013
    * @Author Pawel Sprysak
    * @description Change per page value (after changing perPage value on Page, this method is invoking to change actual page to first)
    * @return PageReference
    */
    public PageReference changePerPageValue() {
        actualPage = 1;
        createList();
        return null;
    }

    /** @date 3/11/2013
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
            totalElements = listSize;
            if(actualPage > totalPages) {
                actualPage = totalPages;
            }
        } else {
            totalElements = 0;
            totalPages = 0;
        }
    }

    /** @date 3/12/2013
    * @Author Pawel Sprysak
    * @description Event Wrapper Class
    */
    public class EventWrapper implements IReflection {
        public Boolean                     selected        { get; set; }
        public Date                        masterDate      { get; set; }
        public Date                        transactionDate { get; set; }
        public VDST_Event_gne__c           event           { get; set; }
        private VDST_EventDetailCommon     commonUtils     { get; set; }
        
        public EventWrapper(VDST_Event_gne__c ev, VDST_EventDetailCommon commonUtilsRef) {
        	commonUtils = commonUtilsRef;
            this.event = ev;
            selected = false;
            masterDate = ev.EventStartDate_gne__c.addDays(7);
            transactionDate = ev.EventStartDate_gne__c.addDays(45);
        }

	    public String getCurrentStatusLabel() {
	        return commonUtils.getLabel(event.CurrentStatus_gne__c);
	    }

        public String getMasterDateString() {
            if(masterDate > Date.today() || !'PENDING'.equals(event.CurrentStatus_gne__c) ) {
                return masterDate.format();
        	} else {
        		return '<span class="error-color font-bold">' + masterDate.format() + '</span>';
        	}
        }

        public String getTransactionDateString() {
            if(transactionDate > Date.today() || !'OCCURRED'.equals(event.CurrentStatus_gne__c) ) {
                return transactionDate.format();
            } else {
                return '<span class="error-color font-bold">' + transactionDate.format() + '</span>';
            }
        }

        public String getVenueName() {
        	if(event.VDST_Event_Sites__r.size() > 0 && event.VDST_Event_Sites__r.get(0).EventSiteName_gne__c != null) {
        	    return event.VDST_Event_Sites__r.get(0).EventSiteName_gne__c;
        	} else {
        		return '';
        	}
        }

        public object getValue(String name) {
            if('Site'.equals(name) && event.VDST_Event_Sites__r.size() > 0 && event.VDST_Event_Sites__r.get(0).EventSiteName_gne__c != null) {
                return event.VDST_Event_Sites__r.get(0).EventSiteName_gne__c.toLowerCase();
            } else if('evName'.equals(name) && event.EventMeetingName_gne__c != null) {
                return event.EventMeetingName_gne__c.toLowerCase();
            } else if('venName'.equals(name) && event.LogisticVendorName_gne__c != null) {
                return event.LogisticVendorName_gne__c.toLowerCase();
            } else if('status'.equals(name) && event.CurrentStatus_gne__c != null) {
                return event.CurrentStatus_gne__c;
            } else if('create'.equals(name)) {
                return event.CreatedDate.format('yyyy-MM-dd HH:mm:ss');
            } else if('stDate'.equals(name) && event.EventStartDate_gne__c != null) {
            	Datetime temp = event.EventStartDate_gne__c;
                return temp.format('yyyy-MM-dd');
            }
            return '';
        }
    }
}