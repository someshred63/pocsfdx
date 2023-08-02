public with sharing class GNE_SFA2_PFG_QtyLmt_AccSection_Ctrl extends GNE_SFA2_PFG_PaginationBase{
		
	private String accountId {get;set;}
	
	//map productId -> SFA2_PFG_Product_Limit_gne__c
	private Map<Id, SFA2_PFG_Product_Limit_gne__c> pfgProductsLimitsPerYear {get;set;}
	
	//map productId -> SFA2_PFG_to_Account_Detail_gne__c
	private Map<Id, SFA2_PFG_to_Account_Detail_gne__c> pfgToAccountDetails {get;set;}
	
	//map productId -> PFG_Staging_Account_Limit_Exception_gne__c
	private Map<Id, PFG_Staging_Account_Limit_Exception_gne__c> pfgToAccountLimits {get;set;}
	
	private String LIMIT_YEAR; 
	private List<WrapResult> wResults {get;set;}
	public String sortField  {get;set;}
    public String sortDirection {get;set;}
	public List<WrapResult> wrappedResults{
		get{
		    List<WrapResult> pagedList = new List<WrapResult>();
		    for(object obj : getRecords())
		    {
		        pagedList.add((WrapResult)obj);
		    }
		    return pagedList;
		}
		private set;
	}
	
	public GNE_SFA2_PFG_QtyLmt_AccSection_Ctrl(){  		
  		List<Product_vod__c> pfgAvailableProducts = getAvailableUserProducts();  		
  		LIMIT_YEAR = GNE_SFA2_PFG_Util.currentYear();
  		this.accountId = ApexPages.currentPage().getParameters().get('id');		
		this.pfgProductsLimitsPerYear = getAllPFGProductsLimitsPerYear(LIMIT_YEAR, pfgAvailableProducts);
		this.pfgToAccountDetails = getPfgToAccountDetailsPerAccountAndLimitYear(accountId, LIMIT_YEAR, pfgAvailableProducts);
		this.pfgToAccountLimits = getAccountProductsLimitsPerYear(accountId, LIMIT_YEAR, pfgAvailableProducts);
		this.wResults = getResults();
		initSetController(this.wResults, 10);
		this.sortField ='qDisbursed';
		this.sortDirection ='DESC';
		SuperSort.sortList(this.wResults, this.sortField, this.sortDirection);
  	}
  	
  	private List<Product_vod__c> getAvailableUserProducts(){
  		List<Product_vod__c> availableProducts = new List<Product_vod__c>();
  		Id userId = UserInfo.getUserId();
  		Set<String> userBrands;
  		if (GNE_SFA2_PFG_Util.checkIsUserManager(userId)){
  			userBrands = GNE_SFA2_PFG_Util.getBrandNames();
  		} else {
  			userBrands = GNE_SFA2_PFG_Util.getBrandNamesByUserTerritory(userId);
  		}		
		for (String brandName : userBrands){
		 	availableProducts.addAll(GNE_SFA2_PFG_Util.getProductsForBrand(brandName));
		}
		return availableProducts;
  	}
  	
	private Map<Id, PFG_Staging_Account_Limit_Exception_gne__c> getAccountProductsLimitsPerYear(String accountId, String limitYear, List<Product_vod__c> pfgAvailableProducts){				
		Map<Id, PFG_Staging_Account_Limit_Exception_gne__c> result = new Map<Id, PFG_Staging_Account_Limit_Exception_gne__c>();
		for(PFG_Staging_Account_Limit_Exception_gne__c pLimit : GNE_SFA2_PFG_DAO.getAccountProductsLimitsPerYear(accountId, limitYear, pfgAvailableProducts)){
			result.put(pLimit.Product_gne__c, pLimit); 
		}
		return result;
	}
	
	private Map<Id, SFA2_PFG_Product_Limit_gne__c> getAllPFGProductsLimitsPerYear(String limitYear, List<Product_vod__c> pfgAvailableProducts){
		Map<Id, SFA2_PFG_Product_Limit_gne__c> result = new Map<Id, SFA2_PFG_Product_Limit_gne__c>();
		for(SFA2_PFG_Product_Limit_gne__c pLimit : GNE_SFA2_PFG_DAO.getAllPFGProductsLimitsPerYearAndProducts(limitYear, pfgAvailableProducts)) {
			result.put(pLimit.Product_gne__c, pLimit); 
		}
		return result;
	}
	
	private Map<Id, SFA2_PFG_to_Account_Detail_gne__c> getPfgToAccountDetailsPerAccountAndLimitYear(String accountId, String limitYear, List<Product_vod__c> pfgAvailableProducts){
		Map<Id, SFA2_PFG_to_Account_Detail_gne__c> result = new Map<Id, SFA2_PFG_to_Account_Detail_gne__c>();
		for(SFA2_PFG_to_Account_Detail_gne__c aDetail : GNE_SFA2_PFG_DAO.getPfgToAccountDetailsPerAccountAndLimitYearAndProducts(accountId, limitYear, pfgAvailableProducts)) {
			result.put(aDetail.Product_gne__c, aDetail);
		}
		return result;
	}
	
	
	private List<WrapResult> getResults(){
		List<WrapResult> result = new List<WrapResult>();
		for(Id prodId : this.pfgProductsLimitsPerYear.keySet()){
			WrapResult wRes = new WrapResult();
			wRes.ndc = this.pfgProductsLimitsPerYear.get(prodId).Product_gne__r.NDC_Number_gne__c;
			wRes.productName = this.pfgProductsLimitsPerYear.get(prodId).Product_gne__r.Name;
			wRes.qLimit = Integer.valueOf(this.pfgProductsLimitsPerYear.get(prodId).Limit_Quantity_gne__c);
			if(this.pfgToAccountLimits.containsKey(prodId)){
				wRes.qLimit = Integer.valueOf(this.pfgToAccountLimits.get(prodId).Exception_Quantity_gne__c);
			}
			
			if(this.pfgToAccountDetails.containsKey(prodId)){
				wRes.qDisbursed = Integer.valueOf(this.pfgToAccountDetails.get(prodId).Qty_Disbursed_gne__c);
			}
			else{
				wRes.qDisbursed = 0;
			}
			result.add(wRes);
		}
		system.debug('this.wResults= '+this.wResults);
		return result;
	}
	
    public void sortResults(){         
    	SuperSort.sortList(this.wResults, sortField, sortDirection);
    }
    
    public String sortExpression{
        get{
            return sortField;
        }
        set{
            //if the column is clicked on then switch between Ascending and Descending modes
	       if (value == sortField){
				sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
	       } else {
	                sortDirection = 'ASC';
	       }
	       sortField = value;
        }
    }
    
    public String getSortDirection(){
        //if no column is selected 
	        if (sortExpression == null || sortExpression == '') {
	            return 'ASC';
	        } else {
	            return sortDirection;
	        }
    }
    
    public void setSortDirection(String value){  
        sortDirection = value;
    }
    public Boolean hasNextPage { get { return this.hasNext; } }
    public Boolean hasPreviousPAge { get { return this.hasPrevious; } }
    public void firstPage()
    {
    	this.first();
    }
    public void nextPage()
    {
    	this.next();
    }
    public void previousPage()
    {
    	this.previous();
    }
    public void lastPage()
    {
    	this.last();
    }
	public class WrapResult implements IReflection{
		public String ndc {get;set;}
		public String productName {get;set;}
		public Integer qLimit {get;set;}
		public Integer qDisbursed {get;set;}
		
		public object getValue (String field){
            object result = null;
            if (field == 'ndc')
            {
                result = this.ndc;
            }
            else if (field == 'productName')
            {
                result = this.productName;
            }
            else if (field == 'qLimit')
            {
                result = this.qLimit;
            }
            else if (field == 'qDisbursed')
            {
                result = this.qDisbursed;
            }
            return result;
        }
	}
}