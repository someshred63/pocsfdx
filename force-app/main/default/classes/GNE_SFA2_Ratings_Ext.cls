/************************************************************
*  @author: Michal Hrycenko, Roche
*  Date: 2012-11-12
*  Description: This is a extension controller for GNE_SFA2_Ratings_Layout Page
*
*  Modification History
*  Date        Name        Description
*
*************************************************************/
public with sharing class GNE_SFA2_Ratings_Ext {

	private GNE_SFA2_Ratings_Configuration__c columnsList {get; set;}                                      // columns list FROM config object
	public List<String> viewColumns {get; set;}
	public Map<String, String> columnsHeaders {get; set;}                                                  // columns header FROM config object
	public List<ViewWrapper> viewWrappers {get; set;}
	public Boolean configIsExist {get; set;}                                                               // wrapper list display in dynamic data table
	public Boolean upsertFailureFlag {get; set;}
	public Boolean accountView {get; set;}
	public Boolean showAllRatingsButton {get; set;}
	
	private Account account {get; set;}                                                                    // current account
	private Boolean isInitialized = false;
	private GNE_SFA2_User_App_Context_gne__c userApplicationContext {get; set;}

	public GNE_SFA2_Ratings_Ext(ApexPages.StandardController controller) {
	}

	public PageReference init() {
		upsertFailureFlag = false;
		configIsExist = true;
		isInitialized = true;
		accountView = true;
		showAllRatingsButton = false;
		// Set view mode
		if(!URL.getCurrentRequestUrl().toExternalForm().contains('Account_Layout')) {
			accountView = false;
		}
		// Get User Application Context FROM DB
		userApplicationContext = GNE_SFA2_Util.getUserApplicationContext();
		// Get Account FROM DB
		try {
			account = [SELECT Id, IsPersonAccount, RecordType.DeveloperName FROM Account WHERE Id = : ApexPages.currentPage().getParameters().get('Id') LIMIT 1];
		} catch (System.QueryException ex) {
			PageReference pageref = new PageReference('/apex/GNE_SFA2_Exception_Layout');
			pageref.setredirect(true);
			System.debug('pageref: ' + pageref);
			pageref.getParameters().put('ex', 'Record not found or Id parameter missing!');
			return pageref;
		}
		// Get Columns List FROM Configuration
		try {
			columnsList = [SELECT Columns_List_gne__c 
							FROM GNE_SFA2_Ratings_Configuration__c 
							WHERE Role_gne__c = : userApplicationContext.Role_gne__c
							AND Brand_gne__c = : userApplicationContext.Brand_gne__c
							AND Application_Type_gne__c = : userApplicationContext.App_Name_gne__c
							AND Record_Type_gne__c = : account.RecordType.DeveloperName 
							LIMIT 1];
		} catch (QueryException e) {
			configIsExist = false;
		}
		return null;
	}

	private List<String> prepareColumnsFromConfig() {
		List<String> columns = new List<String>();
		if (columnsList.Columns_List_gne__c != null && columnsList.Columns_List_gne__c != '') {
			columns = columnsList.Columns_List_gne__c.split(',', 0);
		}
		return columns;
	}

	private Map<String, String> getColumnsHeaders(List<String>viewColumns) {
		Map<String, String> result = new Map<String, String>();
		for (String fieldName : viewColumns) {
			String label = Schema.SObjectType.Product_Metrics_vod__c.fields.getMap().get(fieldName).getDescribe().getLabel();
			result.put(fieldName, label);
		}
		return result;
	}

	private Map<String, String> getEditModeMapFromConfig() {
		List<GNE_SFA2_Ratings_Column_Setup__c> editModeList = [SELECT Column_Name_gne__c, Readonly_Products_List_gne__c 
																FROM GNE_SFA2_Ratings_Column_Setup__c
																WHERE Role_gne__c = : userApplicationContext.Role_gne__c
																AND Brand_gne__c = : userApplicationContext.Brand_gne__c
																AND Application_Type_gne__c = : userApplicationContext.App_Name_gne__c
																AND Record_Type_gne__c = : account.RecordType.DeveloperName];
		Map<String, String> editModesMap = new Map<String, String>();
		for (GNE_SFA2_Ratings_Column_Setup__c rcs : editModeList) {
			editModesMap.put(rcs.Column_Name_gne__c, rcs.Readonly_Products_List_gne__c);
		}
		return editModesMap;
	}

	public List<ViewWrapper> getViewAllRatings() {
		if (isInitialized && configIsExist) {
			// Get Columns List FROM Configuration
			System.debug('account: ' + account);
			String accountId;
			if (account == null) {
				accountId = '';
			} else {
				accountId = account.id;
			}

			String query = 'SELECT Products_vod__c, Products_vod__r.Name, ' + columnsList.Columns_List_gne__c + ' FROM Product_Metrics_vod__c WHERE Account_vod__c = \'' + accountId + '\'';
			viewColumns = prepareColumnsFromConfig();
			columnsHeaders = getColumnsHeaders(viewColumns);
			Map<String, String> editModeMapFROMConfig = getEditModeMapFromConfig();

			// Get Brand Affiliations FROM DB
			System.debug(query);
			Map<Id, Product_Metrics_vod__c> accountProductMetricsMap = new Map<Id, Product_Metrics_vod__c>();
			for (Product_Metrics_vod__c pm : Database.query(query)) {
				accountProductMetricsMap.put(pm.Products_vod__c, pm);
			}

			// Get User Setup Products FROM DB
			Map<Id, Product_vod__c> userSetupProductsMap = new Map<Id, Product_vod__c>();

			for (Product_vod__c product : [SELECT Id, Name FROM Product_vod__c WHERE Id IN (SELECT Product_vod__c FROM My_Setup_Products_vod__c WHERE OwnerId = : UserInfo.getUserId())]) {
				userSetupProductsMap.put(product.Id, product);
				if (!accountProductMetricsMap.containsKey(product.Id)) {
					Product_Metrics_vod__c pm = new Product_Metrics_vod__c();
					pm.Products_vod__c = product.Id;
					pm.Account_vod__c = account.Id;
					accountProductMetricsMap.put(pm.Products_vod__c, pm);
				}
			}

			// Sort User Setup Products Map
			List<Product_vod__c> tempList = userSetupProductsMap.values().clone();
			GNE_SFA2_Util.sortList(tempList, 'Name', true);

			List<Product_vod__c> accountViewProductsList = new List<Product_vod__c>(); 
			if(tempList.size() > 10 && accountView) {
				showAllRatingsButton = true;
				for(Integer i = 0; i < 10; i++) {
					accountViewProductsList.add(tempList.get(i));
				}
			}

			if(!accountViewProductsList.isEmpty()) {
				tempList = accountViewProductsList;
			}

			// Get EditMode Matrix Map FROM Configuration
			Map<String, Map<String, Boolean>> editModeMatrixMap = new Map<String, Map<String, Boolean>>();
			for (Product_vod__c product : tempList) {
				Map<String, Boolean> editModeMap = new Map<String, Boolean>();
				for (String columnName : viewColumns) {
					if (editModeMapFROMConfig.containsKey(columnName)) {
						String productList = editModeMapFROMConfig.get(columnName);
						editModeMap.put(columnName, !productList.contains(product.Id));
					} else {
						editModeMap.put(columnName, true);
					}
				}
				editModeMatrixMap.put(product.Id, editModeMap);
			}

			// Get ReadOnly Matrix Map FROM Configuration
			Map<String, Map<String, Boolean>> readOnlyModeMatrixMap = new Map<String, Map<String, Boolean>>();
			for (Product_vod__c product : tempList) {
				Map<String, Boolean> readOnlyModeMap = new Map<String, Boolean>();
				for (String columnName : viewColumns) {
					if (editModeMapFROMConfig.containsKey(columnName)) {
						String productList = editModeMapFROMConfig.get(columnName);
						readOnlyModeMap.put(columnName, productList.contains(product.Id));
					} else {
						readOnlyModeMap.put(columnName, false);
					}
				}
				readOnlyModeMatrixMap.put(product.Id, readOnlyModeMap);
			}

			viewWrappers = new List<ViewWrapper>();
			for (Product_vod__c product : tempList) {
				viewWrappers.add(new viewWrapper(product, accountProductMetricsMap.get(product.Id), editModeMatrixMap.get(product.Id), readOnlyModeMatrixMap.get(product.Id)));
			}

			return viewWrappers;
		} else {
			return new List<ViewWrapper>();
		}
	}

	public PageReference saveRatings() {
		List<Product_Metrics_vod__c> productMetricsList = new List<Product_Metrics_vod__c>();
		for (ViewWrapper wrap : viewWrappers) {
			productMetricsList.add(wrap.productMetrics);
		}
		try {
			upsert productMetricsList;
			upsertFailureFlag = false;
		} catch (Exception ex) {
			system.debug('>>> upsert exception: ' + ex);
			upsertFailureFlag = true;
		}

		if(accountView) {
			return null;
		} else {
			Pagereference pageref = new Pagereference('/apex/GNE_SFA2_Account_Layout?id=' + account.Id);
			pageref.setredirect(true);
			return pageref;
		}
	}

	public PageReference viewAllRatings() {
		Pagereference pageref = new Pagereference('/apex/GNE_SFA2_All_Ratings_Layout');
		pageref.getParameters().put('id', account.Id);
		pageref.setredirect(true);
		return pageref;
	}

	/*** WRAPPER CLASS ***/
	public class ViewWrapper {
		public Product_vod__c product {get; set;}
		public Product_Metrics_vod__c productMetrics {get; set;}
		public Map<String, Boolean> editMode {get; set;}
		public Map<String, Boolean> readOnlyMode {get; set;}

		public viewWrapper(Product_vod__c product, Product_Metrics_vod__c productMetrics, Map<String, Boolean> editMode, Map<String, Boolean> readOnlyMode) {
			this.product = product;
			this.productMetrics = productMetrics;
			this.editMode = editMode;
			this.readOnlyMode = readOnlyMode;
		}
	}
}