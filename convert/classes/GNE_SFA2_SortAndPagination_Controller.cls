public with sharing class GNE_SFA2_SortAndPagination_Controller {
    public Integer pageSize {get; set;}
    public List<sObject> records {get; set;}
    private List<sObject> currentRecordSet;
    public Integer pageNumber {get; set;}
    public Integer ResultSize {get; set;}
    public void first() {
        pageNumber = 1;
    }
    public Boolean getHasPrevious() {
        return pageNumber != 1;
    }
    public void previous() {
        pageNumber--;
    }
    public void next() {
        pageNumber++;
    }
    public Integer getLastPageNumber(){
        Integer totalPages = (Integer)((Decimal)getResultSize()/(Decimal)pageSize).round(System.RoundingMode.CEILING);
        return totalPages;
    }
    public void last() {
        if(getPageSize() != 0) {
            pageNumber = getLastPageNumber();
        }
    }
    public Boolean getHasNext() {
        return pageNumber < getLastPageNumber();
    }
    public GNE_SFA2_SortAndPagination_Controller(List<sObject> objects) {
        currentRecordSet = new List<sObject>();
        pageNumber = 1;
        if(objects != null) {
            records = objects;
        }
        else { 
            records = new List<sObject>();
        }
        ResultSize = pageSize = records.size();
        
    }
    public List<sObject> getRecords() {
        currentRecordSet.clear();
        for(Integer i = (pageNumber-1)*pageSize; i < records.size() && i < pageNumber*pageSize; i++ ) {
            currentRecordSet.add(records.get(i));    
        }
        return currentRecordSet;
    }
    public Boolean getCompleteResult() {
        return true;
    }
    public void setPageSize(Integer pageSize) {
        this.pageSize = pageSize;
    }
    public void setPageName(String pageName) {
       setPageNumber(Integer.valueOf(pageName));
    }
    public String getPageName() {
        return '' + pageNumber;
    }
    public void setPageNumber(Integer pageNumber) {
        if(pageNumber < 1){
            this.pageNumber = 1;
        }
        else {
            this.pageNumber = pageNumber;
        }
    }
    public Integer getPageNumber() {
        return pageNumber;
    }
    public Integer getPageSize() {
        return pageSize;
    }
    public Integer getResultSize() {
        return records.size();
    }
    
}