//--------------------------------------------------------------------------------
// COMPONENT: SFA Primary Care
//     CLASS: GNE_Base_Pager
// 
//     OWNER: 
//   CREATED: 05/2010
//   Modification history:
//   09/27/2010 by Michał Szewczyk : add method showPagesActionWithParam 
//--------------------------------------------------------------------------------
public abstract Class GNE_Base_Pager{
 	public Boolean IsTestCase { get; set;}
    public String currSortOrder { get; set;}     
    public static final Integer DEFAULT_MAX_RESULTS = 1000;
    public Integer MaxResults = DEFAULT_MAX_RESULTS;
    
    public Integer getMaxResults(){
        return MaxResults;
    }
    
    public void setMaxResults(Integer value){
        MaxResults = value;
    }
        
    public static Integer ALL_RESULTS = 1000;
    
    private Integer currCount = 0;
    public Integer getCurrCount(){
        return currCount;
    }

    public Integer pageStartPos {get; set;}
    public Integer pageEndPos {get; set;}
    
	public List<SObject> fullList;
	
	public Integer getFullListSize(){
		if (fullList != null) return fullList.size(); 	
		return 0;
	}
 
 	public void clearFullList(){
 		fullList = new List<SObject>{};
 	}
 	
    //---Used for tracking the total record count
    private Integer recordCount;
    public Integer getRecordCount(){
        return recordCount;
    }
    public void setRecordCount(Integer value){
        recordCount = value;
        calcPages();
    }

    //---The number of display rows, should be fixed
    public static final Integer DEFAULT_DISP_ROWS = 15;
    private Integer dispRows = DEFAULT_DISP_ROWS;
    public Integer getDispRows(){
        return dispRows;
    }
    public void setDispRows(Integer value){
        dispRows = value;
    }

    //---The first row in the list to be displayed, this may become fixed at 0
    private Integer firstRow = 0;
    public Integer getFirstRow(){
        return firstRow;
    }
    public void setFirstRow(Integer value){
        firstRow = value;
    }

    //---The current page viewed
    private Integer currentPage = 1;
    public Integer getCurrentPage(){
        return currentPage;
    }
    public void setCurrentPage(Integer value){
        currentPage = value;
    }

    //---The max pages in the data set
    private Integer maxPages = 0;
    public Integer getMaxPages(){
        return maxPages;
    }
    public void setMaxPages(Integer value){
        maxPages = value;
    }

    //---The page limit, max pages of data
    private Integer pageLimit = 1000;

    //------------- Dynamic Attribute Methods ---------------------------
    public Boolean getRenderPager(){
        return currentPage > 1 || currentPage < maxPages; 
    }
    
    public Boolean getRenderPrevious(){
        return currentPage > 1;
    }

    public Boolean getRenderNext(){
        return currentPage < maxPages;
    }
    
    public Boolean getRenderShowAll(){
        return getDispRows() != getMaxResults() && recordCount > 0 && maxPages > 1;
    }
    
    public Boolean getRenderShowPages(){
    	System.debug('getFullListSize()='+getFullListSize());
    	System.debug('getDispRows()='+getDispRows());
    	if ((getDispRows() == getMaxResults() && recordCount > 0) && getFullListSize() > DEFAULT_DISP_ROWS){
	        return true;
    	}    
        return false;
    }
    
    public Boolean getRenderShowTot(){
    	System.debug('getFullListSize()='+getFullListSize());
    	System.debug('getDispRows()='+getDispRows());
    	if (getFullListSize() <= getDispRows()){
	        return true;
    	}    
        return false;
    }

    public Integer getLimit(){
        return pageEndPos;
    }

    //------------- Public Methods ---------------------------

    //---Should a row be added to the display list
    public Boolean shouldAddRow(){
        //---increment the current coutner
        currCount++;

        //---Determine if in the Current page of data to display
        return currCount >= pageStartPos && currCount <= pageEndPos;
    }

    //---Next
    public void nextAction(){
        if (currentPage < maxPages) currentPage++;

		if (currentPage > 1){
 			pageStartPos = (currentPage - 1) * dispRows + 1;
 		}	
        pageEndPos = pageStartPos + dispRows - 1;
        changeDispData();
    }

    //---Previous
    public void previousAction(){
        if (currentPage > 1){
             currentPage--;
        }
        else{
            currentPage = 1;
        }
        
 		if (currentPage > 1){
 			pageStartPos = (currentPage - 1) * dispRows + 1;
 		} else{
 			pageStartPos = 1;	
 		}
        pageEndPos = pageStartPos + dispRows - 1;
        changeDispData();
    }

    public void loadData(){
    	fullList = getByPager(this);
    	setCurrentPage(1);
    	changeDispData(); 
    }
    
    public abstract List<SObject> getByPager(GNE_Base_Pager pager);
    public abstract void changeDispData();

    public String CurrSort { get; set; }

    public void sortListDb(String sortField){
        String prevSort = CurrSort;

        if (prevSort != null && prevSort.startsWith(sortField)){
            if (prevSort.toUpperCase().endsWith('DESC')){
                sortField = sortField + ' ASC';
            }
            else{
                sortField = sortField + ' DESC';
            }
        }
        CurrSort = sortField;
        currentPage = 1;
        loadData();
    }

 	//---ShowAll Action
    public void showAllAction(){
    	currentPage = 1;
        setDispRows(getMaxResults());
        calcPages();
        changeDispData();
    }
    
    //---ShowPages Action
    public void showPagesAction(){
    	currentPage = 1;
        setDispRows(15);
        calcPages();
        changeDispData();
    }
	//---ShowPages Action with param how many records should be visible on one page ( to work commandlink or button required <apex:param id=”Rows”> on page)
    public void showPagesActionWithParam(){
    	Integer iDispRows;
    	if ( apexpages.currentpage().getparameters().containsKey('Rows'))
    		iDispRows = Integer.valueof( apexpages.currentpage().getparameters().get('Rows'));
    	else
    		iDispRows = 10;
    	currentPage = 1;
        setDispRows(iDispRows);
        calcPages();
        changeDispData();
    }

    //------------- Private Methods ---------------------------

    //---Calculate the number of pages and set the limit
    private void calcPages(){
        //---Reset the record counter
        currCount = 0;

        //---Set the max pages
        Integer modVal = Math.mod( recordCount, dispRows);

        maxPages = recordCount / dispRows;

        //---Have an overall ceiling of pages
        if (maxPages > pageLimit) maxPages = pageLimit;

        //---If there are any records left, add the extra page
        if (modVal > 0) maxPages++;

        //---Always have at least 1 page
        if (maxPages == 0) maxPages++;

        //---If over the bounds, then set to the end
        if (currentPage > maxPages) currentPage = maxPages;

        //---Set the Page start and end positions
        pageStartPos = 1;
        if (currentPage > 1) pageStartPos = (currentPage - 1) * dispRows + 1;
        pageEndPos = pageStartPos + dispRows - 1;
    }

  /**  
	 * Sorts a list of SObjects
	 * @param List<SObject> the SObject list to sort 
	 * @param Integer the row to start with
	 * @param Integer the row to end with
	 * @return void
	 */
    public void sortList(String sortField) {
    	if (fullList != null && fullList.size() > 0){
	    	String prevSort = CurrSort;
	    	
			//if previous sort was on same field, switch to do opposite sort
			if (prevSort != null && prevSort.equals(sortField)){  
	        	if (currSortOrder == 'asc'){
	        		currSortOrder = 'desc';
	        	} else{
	        		currSortOrder = 'asc';
	        	}
	        } else{
	        	currSortOrder = 'asc';
	        }
	        if (!IsTestCase) sortList(fullList, sortField, currSortOrder);
	     	CurrSort = sortField;
	        setCurrentPage(1);
	        changeDispData();
	    }
	}   

    public static void sortList(List<sObject> items, String sortField, String order){
    	System.debug('sortField='+sortField);
        /*I must give credit where it is due as the sorting algorithm I am using is the 
        one supplied by Andrew Waite here: http://blog.sforce.com/sforce/2008/09/sorting-collect.html */
        
        Boolean isSortFieldReference = false;
        Map<Id,String> referenceName;
         
        /*Determine the type of the field that needs to be sorted, if it is a 
        reference we will want sort by the name of the related object, not the 
        ID itself*/
        if(items[0].getSObjectType().getDescribe().fields.getMap().get(sortField).getDescribe().getType().Name() == 'REFERENCE'){
            isSortFieldReference = true;
            referenceName = new Map<Id,String>();
            
            /*Determine the type of this object and populate the Id to Name map*/
            Set<Id> referenceIds = new Set<Id>();
            for(sObject s : items){
               referenceIds.add((Id)s.get(sortField));
            }
            
            String objectID = (String)items[0].get(sortField);
            String prefix = objectID.substring(0,3);
            String objectType;
            Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
            for(Schema.SObjectType s : gd.values()){
                if(prefix == s.getDescribe().getKeyPrefix()){
                    objectType = s.getDescribe().Name;
                }
            }
            
            //Query the related objects for the name and populate the Id -> Name map
            String queryString = 'select Id, Name from ' + objectType + ' where ID IN :referenceIDs';
            for(sObject s : Database.query(queryString )){
                referenceName.put((Id)s.get('Id'),(String)s.get('Name'));
            }
        }
                
        /*Declare a list that will contain the sorted results. I think this is one of the 
        coolest parts of this method as the system will not let you declare a list of 
        sObjects (List<sObject> objects = new List<sObjects>();) but using a 
        wrapper class you can bypass this system limitation to create this type of list */
        List<cObject> resultList = new List<cObject>();
    
        //Create a map that can be used for sorting 
        Map<object, List<cObject>> objectMap = new Map<object, List<cObject>>();
        
        for(sObject ob : items){
            if(isSortFieldReference == false){
                if(objectMap.get(ob.get(sortField)) == null){ 
                    objectMap.put(ob.get(sortField), new List<cObject>()); 
                }
                cObject o = new cObject(ob);
                String strVal = (String) ob.get(sortField);
               	objectMap.get(strVal).add(o);
                System.debug('strVal='+strVal);
            }else{
                if(objectMap.get(referenceName.get((Id)ob.get(sortField))) == null){ 
                    objectMap.put(referenceName.get((Id)ob.get(sortField)), new List<cObject>()); 
                }
                cObject o = new cObject(ob);
                objectMap.get(referenceName.get((Id)ob.get(sortField))).add(o);
            }
        }
        
        //Sort the keys
        List<object> keys = new List<object>(objectMap.keySet());
        keys.sort();
        
        for(object key : keys){ 
            resultList.addAll(objectMap.get(key)); 
        }
        
        //Apply the sorted values to the source list
        items.clear();
        if(order.toLowerCase() == 'asc'){
            for(cObject ob : resultList){
                items.add(ob.obj);  
            }
        }else if(order.toLowerCase() == 'desc'){
            for(integer i = resultList.size()-1; i >= 0; i--){
                items.add(resultList[i].obj);   
            }
        }
    }
    
    public class cObject{
        sObject obj {get; set;}
        public cObject(sObject obj){
            this.obj = obj; 
        }
    }
    
    /*Some test methods that provide 100% coverage */
    public static testMethod void sortAscendingTest(){
        List<Opportunity> opps = new List<Opportunity>();
        for(integer i = 0; i<1000; i++){
            opps.add(new Opportunity(Name = 'test' + i, Amount = 1000 * Math.random()));
        }
        
        Test.startTest();
        Long start = system.currentTimeMillis();
        sortList(opps,'Amount','asc');
        system.debug(system.currentTimeMillis() - start);
        Test.stopTest();
        
        //Assert the list was sorted correctly
        Decimal assertValue = -1;
        for(Opportunity o : opps) {
            System.debug('Opp value: ' + o.amount);
            System.assert(assertValue <= o.amount);
            assertValue = o.amount;
        }  
    }
    
    public static testMethod void sortDescendingTest(){
        List<Opportunity> opps = new List<Opportunity>();
        for(integer i = 0; i<1000; i++){
            opps.add(new Opportunity(Name = 'test' + i, Amount = 1000 * Math.random()));
        }
        
        Test.startTest();
        sortList(opps,'Amount','desc');
        Test.stopTest();
        
        //Assert the list was sorted correctly
        Decimal assertValue = 1001;
        for(Opportunity o : opps) {
            System.debug('Opp value: ' + o.amount);
            System.assert(assertValue >= o.amount);
            assertValue = o.amount;
        }  
    }
	//----------------------------------------- ATTRIBUTES ---------------------------
	public String pagerType {get; set; }
    
    private String className;
    
    public String getClassName(){
        return className;
    } 
      
    public void setClassName(String value){
        className = value;
    }

    //----------------------------------------- LOG METHODS ---------------------------
    public void debug(String message){
       System.debug( className + ':' + pagerType + ':' + message);
    }

    public void logMethod(String methodName){
        System.debug( className + ':' + pagerType + ':' + methodName);
    }
    
    public Boolean isNullOrEmpty(String value){
        return value == null || value == '';
    }	
}