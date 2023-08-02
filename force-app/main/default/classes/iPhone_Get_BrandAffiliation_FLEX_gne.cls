/********************************************************************************************
*  @author: Sebastian Karczmarski, Roche (contractor)
*  @email: sebastian.karczmarski@contractors.roche.com   
*  Created: 2013-05-24
*  Project: OTR2
*  Description: REST Webservice, returns a list of ProductsMetrics for the specified accounts.  
*  The columns returned in the respone are dynamically configured (outside the service).               
*********************************************************************************************/
@RestResource(urlMapping='/iPhoneGetBrandAffiliationFlex/*')
global with sharing class iPhone_Get_BrandAffiliation_FLEX_gne {
	
	@HttpPost 
    global static iPhone_Commons_gne.RestResponse processRequest(String lastSyncDate, String unixId, List<String> accountIds) {
    	return iPhone_Commons_gne.buildResponse(
    		new GetBrandAffiliationFlexResponseBuilder(), 
    		new iPhone_Commons_gne.DefaultDeltaArgs(lastSyncDate, unixId, accountIds)
    	);     		
    }
      
    class GetBrandAffiliationFlexResponseBuilder extends iPhone_Commons_gne.DeltaRowSetResponseBuilder {
    	    	
    	private User user;
    	private Set<String> colsFromConfig;
    	private List<iPhone_Commons_gne.DataColumn> dataColumns;
    	private Map<Id, My_Setup_Products_vod__c> userSetupProducts { get; set; }
    	
    	protected override void onInit(User currentUser, DeltaArgs deltaArgs){
    		this.user = currentUser;
    		this.colsFromConfig = getColumnsFromConfig();
    		this.userSetupProducts = getUserSetupProductsMap(this.user.Id);
    		alwaysIncludeXids = true;
    	}
    	
    	private Set<String> getColumnsFromConfig(){
    		GNE_SFA2_User_App_Context_gne__c appCtx = new iPhone_Commons_gne.UserAppContextUtil().getAppCtx(this.user.Id);    		    	
    		List<GNE_SFA2_Ratings_Configuration__c> ratingsCfgs = iPhone_DAO.getRatingsConfiguration(appCtx.Role_gne__c, appCtx.Brand_gne__c, appCtx.App_Name_gne__c);    		    		    		    		
    		if(ratingsCfgs == null) {
    			throw new iPhone_Commons_gne.IPhoneException('No ratings configuration found for user: ' + this.user.Id);
    		}
    		Set<String> configCols = new Set<String>();
    		for(GNE_SFA2_Ratings_Configuration__c ratingsCfg: ratingsCfgs) {
    			configCols.addAll(ratingsCfg.Columns_List_gne__c.split(',', 0));
    		}
    		return configCols;
    	}
    	
    	private Map<Id, My_Setup_Products_vod__c> getUserSetupProductsMap(Id userId){
    		Map<Id, My_Setup_Products_vod__c> productIdToMySetup = new Map<Id, My_Setup_Products_vod__c>();
    		for (My_Setup_Products_vod__c userProduct : [Select Id, Product_vod__r.id, CreatedDate, LastModifiedDate From My_Setup_Products_vod__c where OwnerId = :userId AND Product_vod__r.id != null]){
    			productIdToMySetup.put(userProduct.Product_vod__r.id, userProduct);
    		}
    		return productIdToMySetup;
    	}
    	
    	protected override List<DataColumn> getDataColumns(DeltaArgs args) {    			
    		this.dataColumns = getProductMetricsColumns();
    		return dataColumns;
    	}
    	
    	protected override List<SObject> getSObjects(List<String> columnNames, DeltaArgs args) {
    		return getProductMetricsByAccountIds(columnNames, args.accountIds);	
    	}    
    	
    	protected override DeltaCalculator getDeltaCalculator(String lastSyncDate){
    		return new BrandAffiliationFlexDeltaCalculator(lastSyncDate, this.userSetupProducts);
    	}	
    	    	    	
    	private List<iPhone_Commons_gne.DataColumn> getProductMetricsColumns() {    		    		
    		List<iPhone_Commons_gne.DataColumn> columns = new List<iPhone_Commons_gne.DataColumn>();
    		Map<String, String> relationsPathMap = buildRealtionsPathMap();    		    											
			iPhone_Commons_gne.DataColumnFactory columnsFactory = new iPhone_Commons_gne.DataColumnFactory(relationsPathMap);		
    		for(String columnName: getColumnListForUser()) {
    			columns.add(columnsFactory.newInstance(columnName));
    		}
    		return columns;
    	}
    	
    	private List<Product_Metrics_vod__c> getProductMetricsByAccountIds(List<String> columnNames, List<String> accountIds) {
    		List<Id> userSetupProductIds = new List<Id>();
        	for (Product_vod__c userProduct : iPhone_DAO.getUserSetupProducts(user.Id)){
		    	userSetupProductIds.add(userProduct.Id);
		    }
		    if (userSetupProductIds.isEmpty()){
		    	return new List<Product_Metrics_vod__c>();
		    }
		    String query = 'SELECT';
		    query += buildColumnString(columnNames);
		    query += 'FROM Product_Metrics_vod__c ';
		    query += 'WHERE Account_vod__c in' + buildInClause(accountIds);		 
		    query += ' AND Products_vod__c In ' + GNE_SFA2_Util.createInListForQuery(userSetupProductIds);
		    String ratingFieldsCondition = buildConditionByConfigColumns();
	    	if (String.isNotBlank(ratingFieldsCondition)){
	    		query += ' AND ' + ratingFieldsCondition;
		    }
        	return Database.query(query);
    	}
    	
    	private String buildConditionByConfigColumns(){
        	String result = '';
        	if (this.dataColumns == null && this.colsFromConfig.size() == 0){
        		return result;
        	}
        	String colsFromConfigStr = String.join(new List<String>(this.colsFromConfig), ',').toUpperCase();
        	for (iPhone_Commons_gne.DataColumn dataColumn : this.dataColumns){        		
        		if (String.isNotBlank(dataColumn.srcColumn) && colsFromConfigStr.containsIgnoreCase(dataColumn.srcColumn)){
        			if (result != ''){
        				result += ' OR ';
        			}
        			result += String.format(dataColumn.fieldType != Schema.DisplayType.Boolean.name() ? '{0} != null' : '{0} != false',
        				new String[]{
        					dataColumn.srcColumn 
        				}
        			);
        		}
        	}
        	if (String.isNotBlank(result)){
        		result = '(' + result + ')';
        	}
        	return result;
        }
    	
    	private List<String> getColumnListForUser() {
    		List<String> columns = new List<String>();
    		columns.add('Id');
    		columns.add('CreatedDate');
    		columns.add('LastModifiedDate');
    		columns.add('Products_vod__c');
    		columns.add('Products_vod__r.Name');
    		columns.add('Account_vod__c');
			columns.addAll(this.colsFromConfig);			
    		return columns;    		
    	}
    	
    	private Map<String, String> buildRealtionsPathMap() {
    		Map<String, String> relationsPathMap = new Map<String, String>();
			relationsPathMap.put('', 'Product_Metrics_vod__c');
			relationsPathMap.put('Account_vod__r', 'Account');
			relationsPathMap.put('CreatedBy', 'User');
			relationsPathMap.put('Detail_Group_vod__r', 'Product_vod__c');
			relationsPathMap.put('LastModifiedBy', 'User');
			relationsPathMap.put('Owner_gne__r', 'User');
			relationsPathMap.put('Products_vod__r', 'Product_vod__c');
			relationsPathMap.put('Speaker_Contract__r', 'Speaker_Contract_gne__c');
			return relationsPathMap;    		
    	}    	    	    	
    	
    	private String buildInClause(List<String> inElements) {
    		return ' (\'' + String.join(inElements, '\',\'') + '\') ';
    	}
    	 
    	private String buildColumnString(List<String> columnNames) {
    		return + ' ' + String.join(columnNames, ',') + ' ';
    	}
    }
    
    class BrandAffiliationFlexDeltaCalculator extends iPhone_Commons_gne.DeltaCalculator{
    	
    	private Map<Id, My_Setup_Products_vod__c> userSetupProducts { get; set; }
    	
	    public BrandAffiliationFlexDeltaCalculator(String lastSyncDate, Map<Id, My_Setup_Products_vod__c> userSetupProducts){
    		super(lastSyncDate);
    		this.userSetupProducts = userSetupProducts;
    	}
    	
		protected override String getDeltaStatus(SObject sObj) {
            if(lastSynchronized == null) { // delta is OFF.
            	return null;
            }
            Datetime created = (Datetime)sObj.get('CreatedDate');
            Datetime lastModified = (Datetime)sObj.get('LastModifiedDate');            
            Id productId = (Id)sObj.get('Products_vod__c');
            
            if(created >= lastSynchronized || (userSetupProducts.containsKey(productId) && userSetupProducts.get(productId).CreatedDate >= lastSynchronized)) {
                return STAT_INSERT;     // created AFTER last synchronization.
            } else {
                if(lastModified >= lastSynchronized) {
                    return STAT_UPDATE; // created BEFORE last synchonization but updated AFTER last synchronization.
                } else {
                    return STAT_SYNC; // created and updated BEFORE last synchronization (is eXisting = already synchronized).
                }
            }                           
        }
	}
}