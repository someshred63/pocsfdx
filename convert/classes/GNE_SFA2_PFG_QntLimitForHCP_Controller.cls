public with sharing class GNE_SFA2_PFG_QntLimitForHCP_Controller extends GNE_SFA2_PFG_PaginationBase{
    //public properties
    public SFA2_PFG_Product_Limit_gne__c pfgProductLimit {get; set;}
    
    public String productId {get; set;}
    public String limitYear {get; set;}
    public String ndcNumber {get;set;}
    public String qntLimit {get;set;}
    public Integer rowId {get;set;}
    
    public Boolean renderExceptionList {get; set;}
    public Boolean renderNDC {get;set;}
    public List<SelectOption> productsItems {get;set;}
    public Boolean productYearSelected {get;set;}
    public Boolean addButtonDisabled {get;set;}
    public Integer exceptionRow {get;set;}
    
    //private properties
    private List<ExceptionsWrapper> exList;
    private String productName {get;set;}
    private List<Product_vod__c> pfgProducts;
    private Integer currentYear;
    private String sortField = 'accountName';
    private String sortDirection = 'ASC';
    private Map<Id,PFG_Staging_Account_Limit_Exception_gne__c> accLimitsToDelete;
    
    public Boolean exceptionListValid {get; set;}
    
    public List<ExceptionsWrapper> exceptionsToDisplay    {
        get{
            List<ExceptionsWrapper> pagedList = new List<ExceptionsWrapper>();
            for(Object obj : getRecords()){
                pagedList.add((ExceptionsWrapper)obj);
            }
            return pagedList;
        }
        private set;
    }
    
    public GNE_SFA2_PFG_QntLimitForHCP_Controller(){
        pfgProductLimit = new SFA2_PFG_Product_Limit_gne__c();
        this.pfgProducts = getPfgProducts();
        this.productsItems = getProductsItems(pfgProducts);
        this.currentYear = Date.today().year();
        this.renderExceptionList = false;
        this.renderNDC = false;
        this.productYearSelected = false;
        this.addButtonDisabled = true;
        this.rowId = 0;
        this.qntLimit='';
        this.exceptionListValid = true;
        this.accLimitsToDelete = new Map<Id,PFG_Staging_Account_Limit_Exception_gne__c>();
        this.exList = new List<ExceptionsWrapper>();
    }
    
    private PageReference setErrorPageReference(String actionName, Exception ex) {
    	return GNE_SFA2_PFG_Base_Controller.setErrorPageReference(GNE_SFA2_PFG_Base_Controller.SAVE_ERROR_MESSAGE_PREFIX, ex);
    }
    
    private List<SelectOption> getProductsItems( List<Product_vod__c> pfgProducts){
        List<SelectOption> productOptions = new List<SelectOption>();
        productOptions.add(new SelectOption('','Select'));
        for(Product_vod__c pfgProduct : pfgProducts){
            productOptions.add(new SelectOption(pfgProduct.Id, pfgProduct.Name));
        }
        return productOptions;
    }

    public List<SelectOption> getYearsItems(){
        List<SelectOption> yearOptions = new List<SelectOption>();
        yearOptions.add(new SelectOption('', 'Select'));
        yearOptions.add(new SelectOption(String.valueOf(this.currentYear-1),String.valueOf(this.currentYear-1)));
        for(Integer i=0; i<=10; i++){
            yearOptions.add(new SelectOption(String.valueOf(this.currentYear+i),String.valueOf(this.currentYear+i)));
        }
        return yearOptions; 
    }
    
    //method returning NDC number per selected product ID
    private void returnNDCnumberBasedOnSelectedProduct(){
        Map<Id, String> ndcPerProductId = new Map<Id, String>();
        Map<Id, String> namePerProductId = new Map<Id, String>();
        for(Product_vod__c pfgProduct : this.pfgProducts){
            ndcPerProductId.put(pfgProduct.Id, pfgProduct.NDC_Number_gne__c);
            namePerProductId.put(pfgProduct.Id, pfgProduct.Name);
        }
        
        this.productName = namePerProductId.get(this.productId);
        this.ndcNumber = ndcPerProductId.get(this.productId);
    }
    
    public PageReference saveLimit() {
    	PageReference result = null;
    
	    try {
	      savePFGproductLimit();
	      this.pfgProductLimit = new SFA2_PFG_Product_Limit_gne__c();
	    } catch(Exception ex) {
	      result = setErrorPageReference(GNE_SFA2_PFG_Base_Controller.SAVE_ERROR_MESSAGE_PREFIX, ex);
	    } 
	    
	    return result;
    }
    
    public PageReference cancel(){
        PageReference pageRef = Page.GNE_SFA2_PFG_MyPFG;
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference getNDCNumber() {
    	PageReference result = null;
    
	    try {
	      result = intGetNDCNumber();
	    } catch(Exception ex) {
	      result = setErrorPageReference('getNDCNumber', ex);
	    } 
	    
	    return result;
    }
    
    private PageReference intGetNDCNumber() {
	    if(String.isNotEmpty(this.productId)){
            returnNDCnumberBasedOnSelectedProduct();
            this.renderNDC = true;
            this.limitYear = '';
            this.pfgProductLimit = new SFA2_PFG_Product_Limit_gne__c();
            this.qntLimit='';
            this.exList = new List<ExceptionsWrapper>();
            this.renderExceptionList = false;
            this.productYearSelected = false;
            this.addButtonDisabled = true;
        }else{
            this.renderNDC = false;
        }
        return null;
    }
    
    public PageReference getExceptionLimits() {
    	PageReference result = null;
    
	    try {
	      result = intGetExceptionLimits();
	    } catch(Exception ex) {
	      result = setErrorPageReference('getExceptionLimits', ex);
	    } 
	    
	    return result;
    }
    
    private PageReference intGetExceptionLimits() {
    	exceptionListValid = true;
    	this.qntLimit='';
        this.addButtonDisabled = true;
        this.productYearSelected = false;
        this.renderExceptionList = false;
            
        if(String.isNotEmpty(this.productId) && String.isNotEmpty(this.limitYear)){
        	this.productYearSelected = true;
        	this.addButtonDisabled = false;
        	Integer currentLimit = getCurrentLimitForProductYear(this.limitYear, this.productId);
            
            if(currentLimit == null){
                this.qntLimit ='';
                this.pfgProductLimit = new SFA2_PFG_Product_Limit_gne__c();
                this.exList = getExistingExceptions(new List<PFG_Staging_Account_Limit_Exception_gne__c>());
            }else{
                this.qntLimit = String.valueOf(currentLimit);
                this.pfgProductLimit.Limit_Quantity_gne__c = currentLimit;
                this.exList = getExistingExceptions(getAccountsLimitExceptions(this.productId, this.limitYear));
            }
            
            this.renderExceptionList = !this.exList.isEmpty();
            initSetController(exList, 5);
        }
        
        return null;
    }
    
    private Boolean isDeleteProductLimitMode() {
    	return String.isBlank(this.qntLimit) || (this.qntLimit.isNumeric() && Integer.valueOf(this.qntLimit)==0);
    }
    
    private Boolean isNewExceptionsMode() {
    	Boolean result = false;
    	
    	for(ExceptionsWrapper exWrp : this.exList) {
    		if(exWrp.getIsNewRow()) {
    			result = true;
    			break;
    		}
    	}
    	
    	return result;
    }
    
    private Boolean validateExceptionLimits(){
        Set<Id>accountIds = new Set<Id>();
        Boolean isValid = true;
        for(ExceptionsWrapper exWrp : this.exList){
            exWrp.errorMsgs = new List<String>();
            if(String.isEmpty(exWrp.accLimitExc.Account_gne__c)){
                isValid= false;             
                exWrp.errorMsgs.add(String.format(System.Label.GNE_SFA2_PFG_PROVIDE_VALUE, new String[]{'HCP'}));
            }
            if(String.isBlank(exWrp.quantityLimit)){
                isValid= false;
                exWrp.errorMsgs.add(String.format(System.Label.GNE_SFA2_PFG_PROVIDE_VALUE, new String[]{'Quantity Limit'}));
            }
            if(isValid){
                try{
                    Integer val = Integer.valueOf(exWrp.quantityLimit);
                    //kozminsl: maximum value checked according to fields length
                    if(val<=0 || val > 999999){
                        isValid= false;                     
                        exWrp.errorMsgs.add(System.Label.PFG_QUANTITY_LIMIT);
                    }
                }catch(Exception e){
                    isValid= false;
                    exWrp.errorMsgs.add(System.Label.PFG_QUANTITY_LIMIT);
                }
            }
            if(isValid && accountIds.contains(exWrp.accLimitExc.Account_gne__c)){
                exWrp.errorMsgs.add(String.format(System.Label.GNE_SFA2_PFG_PRODUCT_LIMIT_DUPLICATE_HCP, new String[]{exWrp.accountName}));
                isValid= false;
            }else if(isValid){
                accountIds.add(exWrp.accLimitExc.Account_gne__c);
            }
        }
        return isValid;
    }
    
    public PageReference cancelEdit(){
    	PageReference result = null;
    
	    try {
	      result = intCancelEdit();
	    } catch(Exception ex) {
	      result = setErrorPageReference('cancelEdit', ex);
	    } 
	    
	    return result;
    }
    
    private PageReference intCancelEdit() {
        ExceptionsWrapper exWrpToEdit = this.exList[this.exceptionRow];
        exWrpToEdit.quantityLimit = String.valueOf(exWrpToEdit.accLimitExc.Exception_Quantity_gne__c.intValue());
        exWrpToEdit.errorMsgs = new List<String>();
        exWrpToEdit.isEditable = false;
        exceptionListValid = validateExceptionLimits();
        return null;
    }
    
    public PageReference editHCP(){
    	PageReference result = null;
    
	    try {
	      result = intEditHCP();
	    } catch(Exception ex) {
	      result = setErrorPageReference('editHCP', ex);
	    } 
	    
	    return result;
    }
    
    private PageReference intEditHCP() {
        ExceptionsWrapper exWrpToEdit = this.exList[this.exceptionRow];
        exWrpToEdit.isEditable = true;
        return null;
    }
    
    public PageReference deleteHCP(){
        PageReference result = null;
    
	    try {
	      result = intDeleteHCP();
	    } catch(Exception ex) {
	      result = setErrorPageReference('deleteHCP', ex);
	    } 
	    
	    return result;
    }
    
    private PageReference intDeleteHCP() {
    	ExceptionsWrapper exWrpToRemove = this.exList.remove(this.exceptionRow);
        
        
        Integer i = 0;
        	
        for(ExceptionsWrapper exWrp : this.exList){
        	exWrp.rowNumber = i++;
        }
        	
        rowId--;
        
        if(!exWrpToRemove.getIsNewRow()) {
            PFG_Staging_Account_Limit_Exception_gne__c accLmtEx = exWrpToRemove.accLimitExc;
            accLmtEx.Logical_Delete_Flag_gne__c = true;
            accLimitsToDelete.put(accLmtEx.Id,accLmtEx);
        }
        
        return null;
    }
    
    public PageReference addHCP(){
        PageReference result = null;
    
	    try {
	      result = intAddHCP();
	    } catch(Exception ex) {
	      result = setErrorPageReference('addHCP', ex);
	    } 
	    
	    return result;
    }
    
    private PageReference intAddHCP() {
        this.exList.add(new ExceptionsWrapper(rowId++));
        this.renderExceptionList = true;
        if(hasNextPage){
            lastPage();
        }
        return null;
    }
    
    /*Validate user input. If values are valid return empty string otherwise return error message */
    private List<String> paramsValidation(){
        List<String> errorMsgs = new List<String>();
        if(String.isEmpty(this.productId)){
            errorMsgs.add(String.format(System.Label.GNE_SFA2_PFG_SELECT_VALUE, new String[]{'Product'}));
        }
        if(String.isEmpty(this.limitYear)){
            errorMsgs.add(String.format(System.Label.GNE_SFA2_PFG_SELECT_VALUE, new String[]{'Year'}));
        }
        if(String.isNotEmpty(this.qntLimit)){
            try{
                Integer val = Integer.valueOf(this.qntLimit);
                //kozminsl: maximum value checked according to fields length
                if(val<0 || val > 999999){
                    errorMsgs.add(System.Label.PFG_QUANTITY_LIMIT);
                }
            } catch(Exception e){
                errorMsgs.add(System.Label.PFG_QUANTITY_LIMIT);
            }
        }
        
        if(isDeleteProductLimitMode() && isNewExceptionsMode()) {
        	errorMsgs.add(String.format(System.Label.GNE_SFA2_PFG_PRODUCT_LIMIT_REQUIRED, new String[]{this.limitYear}));
        }
        
        return errorMsgs;
    }
    
    private void savePFGproductLimit(){
    	GNE_SFA2_PFG_Util.addSessionLabel('HCP Quantity Limit Page');
            
        List<String> errorMsgs = paramsValidation();
        if(!errorMsgs.isEmpty()){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, String.join(errorMsgs, '<br/>')));
        }else if(!(exceptionListValid = validateExceptionLimits())){
        	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.PFG_LIMIT_EXCEPTION_LIST_VALIDATION_ERROR));
        } else {
            Boolean deleteProductLimitMode = isDeleteProductLimitMode();
            List<SFA2_PFG_Product_Limit_gne__c> existingProductLimits = [
            	SELECT Id, Limit_Quantity_gne__c, Limit_Year_gne__c, Product_gne__c, Inactive_gne__c 
            	FROM SFA2_PFG_Product_Limit_gne__c 
            	WHERE Limit_Year_gne__c =:this.limitYear AND Product_gne__c =: productId
            ];
            Boolean mergeWithExistingExceptionsMode = false;
            
            //kozminsl: I assume that this list could be empty or has only one element. It never should contains more elements.
            if(existingProductLimits.size()==1) {
            	mergeWithExistingExceptionsMode = existingProductLimits[0].Inactive_gne__c && !deleteProductLimitMode;
            	existingProductLimits[0].Inactive_gne__c = deleteProductLimitMode;
            	existingProductLimits[0].Limit_Quantity_gne__c = deleteProductLimitMode ? 0.0 : Double.valueOf(this.qntLimit);
            	update existingProductLimits;
            }else if(!deleteProductLimitMode) {
                this.pfgProductLimit.Limit_Quantity_gne__c = Double.valueOf(this.qntLimit);
                this.pfgProductLimit.Limit_Year_gne__c = this.limitYear;
                this.pfgProductLimit.Product_gne__c = this.productId;
                insert this.pfgProductLimit;
            }
            
            Map<Id,PFG_Staging_Account_Limit_Exception_gne__c> existingExMap = new Map<Id,PFG_Staging_Account_Limit_Exception_gne__c>();
            
            if(mergeWithExistingExceptionsMode) {
            	for(PFG_Staging_Account_Limit_Exception_gne__c ex : getAccountsLimitExceptions(this.productId, this.limitYear)) {
            		existingExMap.put(ex.Account_gne__c, ex);
            	}		
            }
            
            List<PFG_Staging_Account_Limit_Exception_gne__c> accLimitExcList = new List<PFG_Staging_Account_Limit_Exception_gne__c>();
            for(ExceptionsWrapper exWrp : this.exList){
            	if(mergeWithExistingExceptionsMode && existingExMap.containsKey(exWrp.accLimitExc.Account_gne__c)) {
            		exWrp.accLimitExc.Id = existingExMap.get(exWrp.accLimitExc.Account_gne__c).Id;
            	} else {
	            	exWrp.accLimitExc.Limit_Year_gne__c = limitYear;
		            exWrp.accLimitExc.Product_gne__c = productId;
            	}
            	
		        exWrp.accLimitExc.Exception_Quantity_gne__c = Decimal.valueOf(exWrp.quantityLimit);
	            exWrp.isEditable = false;
	            
            	accLimitExcList.add(exWrp.accLimitExc);
            }
            
            if(!accLimitsToDelete.isEmpty()) {
            	accLimitExcList.addAll(accLimitsToDelete.values());
            }
            
            upsert accLimitExcList;
            
            // Activate HCP Quantity Fixer
            GNE_SFA2_PFG_Scheduler.activateJob(GNE_SFA2_PFG_VE_HcpQtyFixer_Batch.class,
            	new GNE_SFA2_PFG_VE_HcpQtyChecker_Batch.JobArguments(
            		new Set<Integer>{Integer.valueOf(limitYear)},
            		new Set<Id>{productId}
            ));
            
            // Deactivate Quantity Limit Checker. It will be activated back again just after HCP Quantity Fixer process ends.          
            GNE_SFA2_PFG_Scheduler.deactivateJob(GNE_SFA2_PFG_VE_HcpQtyChecker_Batch.class);
            
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, String.format(
            		deleteProductLimitMode ? System.Label.GNE_SFA2_PFG_PRODUCT_LIMIT_DELETED : System.Label.GNE_SFA2_PFG_PRODUCT_LIMIT_MODIFIED, 
            		new String[]{this.productName, this.qntLimit, this.limitYear})));
            
            intGetExceptionLimits();
        }
    }
    
    private List<Product_vod__c> getPfgProducts(){
        List<Product_vod__c> tmpProducts = [Select Id, Name, NDC_Number_gne__c from Product_vod__c where Product_Type_vod__c = 'PFG'];
        return tmpProducts;
    }
    
    private List<PFG_Staging_Account_Limit_Exception_gne__c> getAccountsLimitExceptions(String productId, String limitYear){
        return [Select Id, Account_gne__r.Id, Account_gne__r.Name, Exception_Quantity_gne__c, Logical_Delete_Flag_gne__c, Limit_Year_gne__c
                from PFG_Staging_Account_Limit_Exception_gne__c
                where Product_gne__c =: productId AND Limit_Year_gne__c =: limitYear AND Logical_Delete_Flag_gne__c = false
                Order By Account_gne__r.Name ASC];
    }
    
    private Integer getCurrentLimitForProductYear(String selectedYear, String selectedProduct) {
        List<SFA2_PFG_Product_Limit_gne__c> prodLimits = [Select Inactive_gne__c, Limit_Quantity_gne__c from SFA2_PFG_Product_Limit_gne__c where Limit_Year_gne__c =: selectedYear AND Product_gne__c =: selectedProduct];
        if(!prodLimits.isEmpty() && prodLimits[0].Inactive_gne__c != true) {
            return Integer.valueOf(prodLimits[0].Limit_Quantity_gne__c);
        } else {
            return null;
        }
    }
    
    public void sortResults(){     
        //SuperSort.sortList(this.exList, sortField, sortDirection);
    }
    
    public String sortExpression{
        get{
            return sortField;
        }
        set{
            //if the column is clicked on then switch between Ascending and Descending modes
            if (value == sortField) {
                sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
            } else {
                sortDirection = 'ASC';
            }
            sortField = value;
        }
    }
    
    public String getSortDirection(){
        //if no column is selected 
        if (String.isEmpty(sortExpression)) {
            return 'ASC';
        } else {
            return sortDirection;
        }
    }
    
    public void setSortDirection(String value){  
        sortDirection = value;
    }
    
    //Exception wrapper and wrapper methods
    private List<ExceptionsWrapper> getExistingExceptions(List<PFG_Staging_Account_Limit_Exception_gne__c> accountLimitExceptions){
        List<ExceptionsWrapper> result = new List<ExceptionsWrapper>();
        rowId = 0;
        
        for(PFG_Staging_Account_Limit_Exception_gne__c hcpException : accountLimitExceptions){
            result.add(new ExceptionsWrapper(hcpException, rowId++));
        }
        
        return result;
    }
    
    public class ExceptionsWrapper implements IReflection{
        public Boolean isEditable {get;set;}
        public PFG_Staging_Account_Limit_Exception_gne__c accLimitExc {get;set;}
        //helper field for displaying name after save
        public String accountName {get;set;}
        public String quantityLimit {get;set;}
        
        public Integer rowNumber {get; set;}
        public String errorMsg {get { return String.join(errorMsgs, ' '); }}
        private List<String> errorMsgs;
        
        public ExceptionsWrapper(Integer rowNumber){
            this(new PFG_Staging_Account_Limit_Exception_gne__c(), rowNumber);
        }
        
        public ExceptionsWrapper(PFG_Staging_Account_Limit_Exception_gne__c hcpException, Integer rowNumber){
            this.accLimitExc = hcpException;
            this.accountName = (hcpException.Account_gne__c!=null)?hcpException.Account_gne__r.Name : '';
            this.isEditable = false;
            this.rowNumber = rowNumber;
            this.errorMsgs = new List<String>();
            if(hcpException.Exception_Quantity_gne__c!=null){
            	this.quantityLimit = String.valueOf(hcpException.Exception_Quantity_gne__c.intValue());
            }else{
            	this.quantityLimit = '';
            }
            
        }
        
        public object getValue (String field){
            object result = null;
            if (field == 'accountId'){
                result = this.accLimitExc.Account_gne__c;
            }
            else if (field == 'accountName'){
                result = this.accLimitExc.Account_gne__r.Name;
            }
            else if (field == 'exceptionQuantity'){
                result = this.accLimitExc.Exception_Quantity_gne__c;
            }
            return result;
        }
        
        public Boolean getIsNewRow(){
            return accLimitExc.id == null;
        }
    }
    
    //helper methods for navigation
    public Boolean hasNextPage { get { return this.hasNext; } }
    public Boolean hasPreviousPage { get { return this.hasPrevious; } }
    public void firstPage(){
        this.first();
    }
    
    public void nextPage(){
        this.next();
    }
    
    public void previousPage(){
        this.previous();
    }
    
    public void lastPage(){
        this.last();
    }
}