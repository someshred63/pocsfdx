public with sharing class GNE_SFA2_PFG_Reports_DAO {
	public static List<SFA2_PFG_Transaction_gne__c> getAdjustemntsByDatesAndCsAndProductsAndLotsHC(String startDate, String endDate, Set<Id> csIds, Set<Id> prodIds, Set<String> lotNOs){
		system.debug('inside Dao adjustemnts');
		Id ajdRecType = GNE_SFA2_PFG_Util.getTransactionRecordTypeId(GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ADJUSTMENT);	 
		Date sDate = GNE_SFA2_PFG_Reports_Helper.dateNewInstance(startDate);
		Date eDate = GNE_SFA2_PFG_Reports_Helper.dateNewInstance(endDate);
		Set<Id> repIds = csIds;
		Set<Id> productIds = prodIds;
		Set<String> lotNumbers = lotNOs;
		List<SFA2_PFG_Transaction_gne__c> transactions = new List<SFA2_PFG_Transaction_gne__c>();
		String headOfQuery = 'Select Id, Name, Product_gne__c, Product_gne__r.Name, NDC_Number__c, Inventory_Count_Flag_gne__c, From_Territory_Number_gne__c, To_Territory_Number_gne__c, To_User_gne__r.Username, To_User_gne__r.Name, To_User_gne__c, From_User_gne__c, From_User_gne__r.Name, From_User_gne__r.Username, Lot_No_gne__c, Shipped_Quantity_gne__c,Transaction_Date_gne__c, Transaction_Reason_gne__c, Iteraction_Calculation_gne__c, Iteraction_Name_Calculation_gne__c, Adjustment_DM_Name_Calc_gne__c From SFA2_PFG_Transaction_gne__c where';
		String dateCondition = ' Transaction_Date_gne__c >=: sDate AND Transaction_Date_gne__c <=: eDate';
		String csNameCondition = ' AND (From_User_gne__c IN: csIds OR To_User_gne__c IN: csIds)';
		String productsCondition = ' AND Product_gne__c IN: productIds';
		String lotNOsCondition = ' AND Lot_No_gne__c IN: lotNumbers';
		String querryString = headOfQuery + dateCondition;
		if(!csIds.isEmpty()){
			querryString += csNameCondition;
		}
		if(!prodIds.isEmpty()){
			querryString += productsCondition;
		}
		if(!lotNOs.isEmpty()){
			querryString += lotNOsCondition;
		}
		String queryTail = ' AND RecordTypeId = :ajdRecType AND Distribution_Method_gne__c = \'Hand Carry\' Limit 10000';
		querryString += queryTail;
		transactions = Database.query(querryString);
		return transactions;
	}
	public static List<SFA2_PFG_Transaction_gne__c> getReturnsByDatesAndCsAndProductsAndLotsHC(String startDate, String endDate, Set<Id> csIds, Set<Id> prodIds, Set<String> lotNOs){
		Id returnRecType = GNE_SFA2_PFG_Util.getTransactionRecordTypeId(GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RETURN);
		Date sDate = GNE_SFA2_PFG_Reports_Helper.dateNewInstance(startDate);
		Date eDate = GNE_SFA2_PFG_Reports_Helper.dateNewInstance(endDate);
		Set<Id> repIds = csIds;
		Set<Id> productIds = prodIds;
		Set<String> lotNumbers = lotNOs;
		List<SFA2_PFG_Transaction_gne__c> transactions = new List<SFA2_PFG_Transaction_gne__c>();
		String headOfQuery = 'Select Id, Name, Product_gne__c, Product_gne__r.Name, NDC_Number__c, From_Territory_Number_gne__c, From_User_gne__c, From_User_gne__r.Name, From_User_gne__r.Username, From_User_gne__r.ManagerId, From_User_gne__r.Manager.Name, Lot_No_gne__c, Shipped_Quantity_gne__c,Transaction_Date_gne__c, Iteraction_Calculation_gne__c, Iteraction_Name_Calculation_gne__c, Transaction_Reason_gne__c From SFA2_PFG_Transaction_gne__c where';
		String dateCondition = ' Transaction_Date_gne__c >=: sDate AND Transaction_Date_gne__c <=: eDate';
		String csNameCondition = ' AND From_User_gne__c IN: repIds';
		String productsCondition = ' AND Product_gne__c IN: productIds';
		String lotNOsCondition = ' AND Lot_No_gne__c IN: lotNumbers';
		String querryString = headOfQuery + dateCondition;
		if(!csIds.isEmpty()){
			querryString += csNameCondition;
		}
		if(!prodIds.isEmpty()){
			querryString += productsCondition;
		}
		if(!lotNOs.isEmpty()){
			querryString += lotNOsCondition;
		}
		String queryTail = ' AND RecordTypeId = :returnRecType AND Distribution_Method_gne__c = \'Hand Carry\' Limit 10000';
		querryString += queryTail;
		transactions = Database.query(querryString);
		return transactions;
	}
	public static List<SFA2_PFG_Inventory_Count_gne__c> getInventoryCountsByLotExpAndProductsAndLots(Date lotExp, Set<Id> prodIds, Set<String> lotNOs){
		Date lotEmpiration = lotExp;
		Set<Id> productIds = prodIds;
		Set<String> lotNumbers = lotNOs;
		List<SFA2_PFG_Inventory_Count_gne__c> inventoryCounts = new List<SFA2_PFG_Inventory_Count_gne__c>();
		String headOfQuery = 'Select Id, Name, Inventory_For_gne__r.Name, Inventory_For_gne__r.Username, Inventory_For_gne__r.ManagerId, Product_gne__r.NDC_Number_gne__c, Product_gne__r.Name, Lot_gne__c, Expiration_Date_gne__c, Count_gne__c from SFA2_PFG_Inventory_Count_gne__c Where';
		String lotExpiringCondition = ' Expiration_Date_gne__c <= :lotEmpiration';
		String productsCondition = ' AND Product_gne__c IN: productIds';
		String lotNOsCondition = ' AND Lot_gne__c IN: lotNumbers';
		String querryString = headOfQuery + lotExpiringCondition;
		if(!prodIds.isEmpty()){
			querryString += productsCondition;
		}
		if(!lotNOs.isEmpty()){
			querryString += lotNOsCondition;
		}
		String queryTail = ' Limit 10000';
		querryString += queryTail;
		inventoryCounts = Database.query(querryString);
		return inventoryCounts;
	}
	public static List<SFA2_PFG_Transaction_gne__c> getDisbursementsByDatesAndProductsAndLotsAndHCPsHC(String startDate, String endDate, Set<Id> prodIds, Set<String> lotNOs, Set<Id> hcpIds){
		Id disbRecType = GNE_SFA2_PFG_Util.getTransactionRecordTypeId(GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_DISBURSEMENT);
		Date sDate = GNE_SFA2_PFG_Reports_Helper.dateNewInstance(startDate);
		Date eDate = GNE_SFA2_PFG_Reports_Helper.dateNewInstance(endDate);
		Set<Id> productIds = prodIds;
		Set<Id> accountsIds = hcpIds;
		Set<String> lotNumbers = lotNOs;
		List<SFA2_PFG_Transaction_gne__c> transactions = new List<SFA2_PFG_Transaction_gne__c>();
		String headOfQuery = 'Select Id, Name, From_Territory_Number_gne__c, From_User_gne__r.UserName, From_User_gne__r.Name, From_User_gne__r.ManagerId, NDC_Number__c, Product_gne__r.Name, Lot_No_gne__c, Received_Quantity_gne__c, Transaction_Date_gne__c, Account_gne__c, Account_gne__r.MDMID_gne__c, Account_gne__r.Name,Address_Line_1_gne__c,Address_Line_2_gne__c,City_gne__c,State_gne__c, Zip_gne__c, Account_gne__r.Phone From SFA2_PFG_Transaction_gne__c Where';
		String dateCondition = ' Transaction_Date_gne__c >=: sDate AND Transaction_Date_gne__c <=: eDate';
		String prodCondition = ' AND Product_gne__c IN: productIds';
		String lotNOsCondition = ' AND Lot_No_gne__c IN: lotNumbers';
		String hcpCondition = ' AND Account_gne__c IN: accountsIds';
		String queryString = headOfQuery + dateCondition + prodCondition;
		if(!lotNOs.isEmpty()){
			queryString += lotNOsCondition;
		}
		if(!hcpIds.isEmpty()){
			queryString += hcpCondition;
		}
		String queryTail = ' AND RecordTypeId = :disbRecType AND Distribution_Method_gne__c = \'Hand Carry\' Limit 10000';
		queryString += queryTail;
		transactions = Database.query(queryString);
		return transactions;
	}
	public static List<SFA2_PFG_Transaction_gne__c> getOrdersByDateAndCSNameAndProductNameAndOrderIdHC(String dateVar, Set<Id> csIds, Set<Id> prodIds, String transName){
		Id orderRecType = GNE_SFA2_PFG_Util.getTransactionRecordTypeId(GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ORDER);
		Date promptedDate =  GNE_SFA2_PFG_Reports_Helper.dateNewInstance(dateVar);
		Date unacknDate = GNE_SFA2_PFG_Util.addBusinessDays(promptedDate, -2);
		Date unshptDate = GNE_SFA2_PFG_Util.addBusinessDays(promptedDate, -5);
		
		Set<Id> repsIds = csIds;
		Set<Id> productsIds = prodIds;
		String transactionName = transName;
		List<SFA2_PFG_Transaction_gne__c> transactions = new List<SFA2_PFG_Transaction_gne__c>();
		String headOfQuery = 'Select Id, Name, Delivery_Status_gne__c, To_User_gne__r.UserName, To_Territory_Number_gne__c, To_User_gne__r.Name, To_User_gne__r.ManagerId, NDC_Number__c, Received_Quantity_gne__c, Product_gne__r.Name, Lot_No_gne__c, Transaction_Date_gne__c from SFA2_PFG_Transaction_gne__c Where';
		String dateCondition = ' ((Delivery_Status_gne__c = \'\' AND Transaction_Date_gne__c >= :unacknDate AND Transaction_Date_gne__c <= :promptedDate ) OR (Shipped_Date_gne__c = null AND Transaction_Date_gne__c >= :unshptDate AND Transaction_Date_gne__c <= :promptedDate))';
		String queryString = headOfQuery+dateCondition;
		if(!csIds.isEmpty()){
			String csCondition = ' And To_User_gne__c IN: repsIds';
			queryString += csCondition;
		}
		if(!prodIds.isEmpty()){
			String prodCondition = ' And Product_gne__c IN: productsIds';
			queryString += prodCondition;
		}
		if(transactionName != ''){
			String orderCondition = ' And Name =: transactionName';
			queryString += orderCondition;
		}
		String queryTail = ' AND RecordTypeId = :orderRecType AND Distribution_Method_gne__c = \'Hand Carry\' Limit 10000';
		queryString += queryTail;
		system.debug('promptedDate: '+promptedDate);
		system.debug('unacknDate: '+unacknDate);
		system.debug('unshptDate: '+unshptDate);
		system.debug('queryString: '+queryString);
		transactions = Database.query(queryString);
		return transactions;
	}
	public static List<SFA2_PFG_Transaction_gne__c> getOrdersByDateCSNameOrdersAndShipmentsHC(String dateVar, Set<Id> csIds, Set<Id> ordrsIds, Set<String> shptIds){
		Id orderRecType = GNE_SFA2_PFG_Util.getTransactionRecordTypeId(GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ORDER);
		Date startDate = GNE_SFA2_PFG_Reports_Helper.dateNewInstance(dateVar);
		Date endDate = GNE_SFA2_PFG_Reports_Helper.dateNewInstance(dateVar).addDays(5);
		Set<Id> repsIds = csIds;
		Set<Id> ordersIds = ordrsIds;
		Set<String> shipmentsIds = shptIds;
		List<SFA2_PFG_Transaction_gne__c> transactions = new List<SFA2_PFG_Transaction_gne__c>();
		String headOfQuery = 'Select Id, Name, To_Territory_Number_gne__c, To_User_gne__r.UserName, To_User_gne__r.Name, To_User_gne__r.ManagerId, NDC_Number__c, Product_gne__r.Name, Lot_No_gne__c, Transaction_Date_gne__c, Requested_Quantity_gne__c, Shipped_Date_gne__c, Shipment_Id_gne__c from SFA2_PFG_Transaction_gne__c Where';
		String dateCondition = ' Shipped_Date_gne__c >=: startDate And Shipped_Date_gne__c <: endDate';
		String quantityCondition = ' And Received_Quantity_gne__c = null';
		
		String queryString = headOfQuery+dateCondition+quantityCondition;
		if(!csIds.isEmpty()){
			String csCondition = ' And To_User_gne__c IN: repsIds';
			queryString += csCondition;
		}
		if(!ordrsIds.isEmpty()){
			String ordersCondition = ' And Id IN: ordersIds';
			queryString += ordersCondition;
		}
		if(!shptIds.isEmpty()){
			String shipmentCondition = ' And Shipment_Id_gne__c IN: shipmentsIds';
			queryString += shipmentCondition;
		}
		String queryTail = ' And RecordTypeId = :orderRecType AND Distribution_Method_gne__c = \'Hand Carry\' Limit 10000';
		queryString += queryTail;
		transactions = Database.query(queryString);
		return transactions;
	}
	public static List<PFG_Staging_Account_Limit_Exception_gne__c> getExceptionsByProductsAndYearsAndHCPs(Set<Id> prodIds, Set<String> years, Set<Id> hcpIds){
		Set<Id> productsIds = prodIds;
		Set<String> yearsSet = years;
		List<PFG_Staging_Account_Limit_Exception_gne__c> accLimitExp = new List<PFG_Staging_Account_Limit_Exception_gne__c>();
		String headOfQuery = 'Select Id, Account_gne__r.Name, Exception_Quantity_gne__c, Limit_Year_gne__c from PFG_Staging_Account_Limit_Exception_gne__c Where';
		String productsCondition = ' Product_gne__c IN: productsIds';
		String yearsCondition = ' And Limit_Year_gne__c IN: yearsSet';
		String queryString = headOfQuery + productsCondition + yearsCondition;
		if(!hcpIds.isEmpty()){
			Set<Id> accIds = hcpIds;
			String hcpcondition = ' And Account_gne__c IN: accIds';
			queryString += hcpcondition;
		}
		accLimitExp = Database.query(queryString);
		return accLimitExp;
	}
	public static List<PFG_Staging_Account_Limit_Exception_gne__History> getExceptionsHistoryByParentId(Set<Id> parentIds){
		return	[Select	CreatedById, CreatedDate, Field, NewValue, OldValue, ParentId 
				From PFG_Staging_Account_Limit_Exception_gne__History
				Where ParentId IN: parentIds];
	}
	public static List<SFA2_PFG_Product_Limit_gne__c> getLimitsByProductsAndYears(Set<Id> prodIds, Set<String> years){
		Set<Id> productsIds = prodIds;
		Set<String> yearsSet = years;
		List<SFA2_PFG_Product_Limit_gne__c> prodLimits = new List<SFA2_PFG_Product_Limit_gne__c>();
		String headOfQuery = 'Select Id, Limit_Quantity_gne__c from SFA2_PFG_Product_Limit_gne__c where ';
		String productsCondition = ' Product_gne__c IN: productsIds';
		String yearsCondition = ' And Limit_Year_gne__c IN: yearsSet';
		String queryString = headOfQuery+productsCondition+yearsCondition;
		prodLimits = Database.query(queryString);
		return prodLimits;
	}
	
	public static List<SFA2_PFG_Product_Limit_gne__History> getLimitHistoryByParentIds(Set<Id> parentIds){
		return	[Select CreatedById, CreatedDate, Field, NewValue, OldValue, ParentId
				From SFA2_PFG_Product_Limit_gne__History
				Where ParentId IN: parentIds
		];
	}
	
	public static List<SFA2_PFG_Transaction_gne__c> getOrdersByOrderDateHCPsProductsAndOrderIdDTP(String dateVar, Set<Id> hcpIds, Set<Id> prodIds, String ordId){
		Id rffRecType = GNE_SFA2_PFG_Util.getTransactionRecordTypeId(GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RFF);
		//report should retrieve unacknowledged orders placed 2 business days prior to prompt date or unshipped orders placed 5 business days prior to prompt date
		Date promptedDate =  GNE_SFA2_PFG_Reports_Helper.dateNewInstance(dateVar);
		Date unacknDate = GNE_SFA2_PFG_Util.addBusinessDays(promptedDate, -2);
		Date unshptDate = GNE_SFA2_PFG_Util.addBusinessDays(promptedDate, -5);
		
		Set<Id> accountIds = hcpIds;
		Set<Id> productIds = prodIds;
		String orderId = ordId;
		List<SFA2_PFG_Transaction_gne__c> transactions = new List<SFA2_PFG_Transaction_gne__c>();
		String headOfQuery = 'Select Address_Line_1_gne__c,Address_Line_2_gne__c,City_gne__c,State_gne__c, Zip_gne__c, Id, Name, Account_gne__r.Id, Account_gne__r.MDMID_gne__c,Account_gne__r.Name, NDC_Number__c, Product_gne__r.Name, Requested_Quantity_gne__c, Transaction_Date_gne__c, Delivery_Status_gne__c, From_User_gne__r.UserName, From_Territory_Number_gne__c, From_User_gne__r.Name, From_User_gne__r.ManagerId  from SFA2_PFG_Transaction_gne__c Where';
		String dateCondition = ' ((Delivery_Status_gne__c = \'\' AND Transaction_Date_gne__c >= :unacknDate AND Transaction_Date_gne__c <= :promptedDate) OR (Shipped_Date_gne__c = null AND Transaction_Date_gne__c >= :unshptDate AND Transaction_Date_gne__c <= :promptedDate))';
		String queryString = headOfQuery+dateCondition;
		if(!accountIds.isEmpty()){
			String accCondition = ' And Account_gne__c IN: accountIds';
			queryString += accCondition;
		}
		if(!productIds.isEmpty()){
			String prodCondition = ' And Product_gne__c IN: productIds';
			queryString += prodCondition;
		}
		if(orderId != ''){
			String orderCondition = ' And Name =: orderId';
			queryString += orderCondition;
		}
		String queryTail = ' AND RecordTypeId = :rffRecType AND Distribution_Method_gne__c = \'DTP\' Limit 10000';
		queryString += queryTail;
		system.debug('getOrdersByOrderDateHCPsProductsAndOrderIdDTP: '+queryString);
		transactions = Database.query(queryString);
		return transactions;
	}
	public static List<SFA2_PFG_Transaction_gne__c> getOutstandingAOCtransactionsDTP(Set<Id> hcpIds, Set<Id> csIds, Set<Id> prodIds, Set<String> lotNos){
		Id rffRecType = GNE_SFA2_PFG_Util.getTransactionRecordTypeId(GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RFF);
		Set<Id> accountIds = hcpIds;
		Set<Id> userIds = csIds;
		Set<Id> productIds = prodIds;
		Set<String> lotNumbers = lotNos;
		Set<String> signatures = new Set<String>();
		signatures.add('Complete');
		signatures.add('Not applicable');
		List<SFA2_PFG_Transaction_gne__c> transactions = new List<SFA2_PFG_Transaction_gne__c>();
		String headOfQuery = 'Select Name, Id, Account_gne__r.Id, Account_gne__r.MDMID_gne__c, Account_gne__r.Name,  Address_Line_1_gne__c, Address_Line_2_gne__c, City_gne__c, State_gne__c, Zip_gne__c, NDC_Number__c, Product_gne__r.Name, Lot_No_gne__c, Received_Quantity_gne__c, Shipment_Id_gne__c, Shipped_Date_gne__c, From_User_gne__r.Username, From_User_gne__r.Name, From_User_gne__r.Phone, Transaction_Date_gne__c, Iteraction_Calculation_gne__c, Iteraction_Name_Calculation_gne__c FROM SFA2_PFG_Transaction_gne__c';
		String firstWhere = ' Where Signature_Status_gne__c NOT IN: signatures';
		String queryString = headOfQuery+firstWhere;
		if(!accountIds.isEmpty()){
			String accountCondition = ' And Account_gne__c IN: accountIds';
			queryString += accountCondition;
		}
		if(!userIds.isEmpty()){
			String userCondition = ' And From_User_gne__c IN: userIds';
			queryString += userCondition;
		}
		if(!productIds.isEmpty()){
			String productCondition = ' And Product_gne__c IN: productIds';
			queryString += productCondition;
		}
		if(!lotNumbers.isEmpty()){
			String lotCondition = ' And Lot_No_gne__c IN: lotNumbers';
			queryString += lotCondition;
		}
		String queryTail = ' And RecordTypeId = :rffRecType AND Distribution_Method_gne__c = \'DTP\' Limit 10000';
		queryString += queryTail;
		system.debug(queryString);
		transactions = Database.query(queryString);
		return transactions;
	}
}