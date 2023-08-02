public with sharing virtual class GNE_SFA2_PFG_VE_HcpQtyChecker_Batch implements Database.Batchable<sObject>, Database.Stateful, 
		GNE_Batch_Runner.Batchable, GNE_SFA2_PFG_Scheduler.SchedulerProcessWithArguments, GNE_SFA2_PFG_Report_Engine.ReportEngine {
	
	protected final String QTY_TYPE_PRODUCT_LIMIT = 'PRODUCT LIMIT';
	protected final String QTY_TYPE_HCP_LIMIT = 'HCP EXCEPTION LIMIT';
	protected final String QTY_TYPE_DISBURSED = 'DISBURSED';
	protected final String QTY_TYPE_TO_FULFILL = 'TO FULFILL';
	protected final String QTY_TYPE_REMAINING = 'REMAINING';
	protected final String[] REPORT_COLUMNS = new String[]{'HCP', 'Product', 'Year', 'Quantity Type', 'Quantity based on Transactions & Limits', 'Quantity based on HCP Details', 'Diff'};
	
	protected Map<String,Map<String, Integer>> trxsQtys = new Map<String,Map<String, Integer>>();
	protected Map<String,Map<String, Integer>> accDetailsQtys = new Map<String,Map<String, Integer>>();
	protected Map<String,SFA2_PFG_to_Account_Detail_gne__c> aDetailsCache = new Map<String,SFA2_PFG_to_Account_Detail_gne__c>();
	@TestVisible protected List<ReportRowWrapper> reportRowsWrappers = new List<ReportRowWrapper>();
	protected Map<Id,String> accountNamesCache = new Map<Id,String>();
	protected Map<Id,String> prodNamesCache = new Map<Id,String>();
	protected Integer accDetailCount = 0;
	protected Integer wrongAccDetailCount = 0;
	protected Set<Integer> limitYears = new Set<Integer>();
	protected Set<String> limitYearsString = new Set<String>();
	protected Set<Id> productIds = new Set<Id>();
	protected Boolean restrictedScopeMode = false;
	
	public void executeSchedulerProcess() {
		GNE_Batch_Runner.setScheduleAfterMinutes(30);
		GNE_Batch_Runner.executeBatch(this, false, true, false, true);
	}
	
	public class JobArguments {
		private Set<Integer> lys;
		private Set<Id> pids;
		private Boolean smode;
		
		public JobArguments(Set<Integer> a_limitYears, Set<Id> a_productIds) {
			lys = a_limitYears;
			pids = a_productIds;
			smode = true;
		}
	}
	
	public void setArguments(String argsJSON) {
		if(argsJSON!=null) {
			JobArguments args = (JobArguments)JSON.deserializeStrict(argsJSON, JobArguments.class);
			
			
			if(args.lys!=null && (!restrictedScopeMode || !limitYears.isEmpty())) {
				limitYears.addAll(args.lys);
			}
			
			if(args.pids!=null && (!restrictedScopeMode || !productIds.isEmpty())) {
				productIds.addAll(args.pids);
			}
			
			restrictedScopeMode = args.smode;
		}
	}
	
	public String getArguments() {
		String argsJSON = (!limitYears.isEmpty() && !productIds.isEmpty()) ? JSON.serialize(new JobArguments(limitYears, productIds)) : null;
		
		if(argsJSON!=null && argsJSON.length() > 255) {
			argsJSON = JSON.serialize(new JobArguments(null, null));
		}
		
		return argsJSON;
	}
	
	public String getPfgReportName() {
		return getBatchName();
	}
	
	public virtual System.Type getBatchClass() {
		return GNE_SFA2_PFG_VE_HcpQtyChecker_Batch.class;
	}
	
	public virtual String getBatchName() {
		return 'PFG VE HCP Quantity Checker';
	}
	
	
	public String getKeyForRecord(SObject sObj) {return sObj.Id;}
	public String getRecordDescription(SObject sObj) {return sObj.Id;}
	
	public void processDatabaseErrors(List<SObject> sObjs, Map<String,List<Database.Error>> recToErrorsMap, String actionId, String actionDescription) {}
	
	public String getErrorEmailDescription(String actionId, SObject sObj, Database.Error err) {
		return String.format('{0} [{1}]: {2}', new String[]{getRecordDescription(sObj), sObj.Id, err.getMessage()});
	}
	
	public Database.QueryLocator start(Database.BatchableContext BC) {
    	return GNE_Batch_Runner.doStart(this,BC);
    }
    
	public virtual Database.QueryLocator intStart(Database.BatchableContext BC) {
		GNE_SFA2_PFG_Util.addSessionLabel(getBatchName());
		Set<String> validRecordTypes = new Set<String>{GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RFF, GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_DTP_PAPER_ORDER};
		String distributionType = GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP;
		Set<String> excludedDeliveryStatuses = GNE_SFA2_PFG_Util.TRANSACTION_DELIVERY_ABORT_STATUSES;
		
		Database.QueryLocator result;
		
		if(!limitYears.isEmpty() && !productIds.isEmpty()) {
			for(Integer limitYear : limitYears) {
				limitYearsString.add(String.valueOf(limitYear));
			}
			
			List<Integer> sortedLimitYears = new List<Integer>(limitYears);
			sortedLimitYears.sort();
			Date startDate = Date.newInstance(sortedLimitYears[0],1,1);
			Date endDate = Date.newInstance(sortedLimitYears[sortedLimitYears.size()-1]+1,1,1);
			
			result = Database.getQueryLocator([
				SELECT 
					Account_gne__c, Account_gne__r.Name,
					Product_gne__c, Product_gne__r.Name, 
					Requested_Quantity_gne__c, Shipped_Quantity_gne__c, Received_Quantity_gne__c,
					Status_gne__c, Shipment_Status_gne__c, Signature_Status_gne__c, Delivery_Status_gne__c, Distribution_Method_gne__c,
					RecordType.Name, Transaction_Date_gne__c
				FROM SFA2_PFG_Transaction_gne__c
				WHERE RecordType.Name IN :validRecordTypes
					AND Distribution_Method_gne__c = :distributionType
					AND Delivery_Status_gne__c NOT IN :excludedDeliveryStatuses
					AND Product_gne__c IN :productIds
					AND Transaction_Date_gne__c >= :startDate AND Transaction_Date_gne__c < :endDate
				ORDER BY Account_gne__r.Name, Product_gne__r.Name, Transaction_Date_gne__c
			]);
		} else {
			result = Database.getQueryLocator([
				SELECT 
					Account_gne__c, Account_gne__r.Name,
					Product_gne__c, Product_gne__r.Name, 
					Requested_Quantity_gne__c, Shipped_Quantity_gne__c, Received_Quantity_gne__c,
					Status_gne__c, Shipment_Status_gne__c, Signature_Status_gne__c, Delivery_Status_gne__c, Distribution_Method_gne__c,
					RecordType.Name, Transaction_Date_gne__c
				FROM SFA2_PFG_Transaction_gne__c
				WHERE RecordType.Name IN :validRecordTypes
					AND Distribution_Method_gne__c = :distributionType
					AND Delivery_Status_gne__c NOT IN :excludedDeliveryStatuses
				ORDER BY Account_gne__r.Name, Product_gne__r.Name, Transaction_Date_gne__c
			]);
		}
		
		if(restrictedScopeMode) {
			GNE_SFA2_PFG_Scheduler.deactivateJob(getBatchClass());
		}
		
		return result;
	}
	
	public void execute(Database.BatchableContext BC, List<sObject> scope) {
    	GNE_Batch_Runner.doExecute(this,BC, scope);
    }
    
    public void intExecute(Database.BatchableContext BC, List<sObject> scope) {
    	Set<Id> accIds = new Set<Id>();
    	getQuantitiesFromTransactions((List<SFA2_PFG_Transaction_gne__c>)scope, accIds);
    	getQuantitiesFromAccountDetails(accIds);
	}
	
	public void finish(Database.BatchableContext BC) {
        GNE_Batch_Runner.doFinish(this,BC);
    }
	
	public virtual void intFinish(Database.BatchableContext BC) {
		GNE_SFA2_PFG_Util.addSessionLabel(getBatchName());
		compareDtpQuantities();
		createReport(BC);
	}
	
	private void getQuantitiesFromTransactions(List<SFA2_PFG_Transaction_gne__c> trxs, Set<Id> accIds) {
		GNE_SFA2_PFG_Util.cacheAccLimitExceptions(trxs);
        GNE_SFA2_PFG_Util.cacheProductLimits(trxs);
		
		for(SFA2_PFG_Transaction_gne__c trx : trxs) {
			accountNamesCache.put(trx.Account_gne__c, trx.Account_gne__r.Name);
			accIds.add(trx.Account_gne__c);
			prodNamesCache.put(trx.Product_gne__c, trx.Product_gne__r.Name);
			
			Map<String, Integer> prdQtys = getAccountProductYearQtyData(getAccountDetailsKey(trx), trxsQtys);
			Integer disbursedQty = null, toFulfillQty = null;
			
			if(trx.Shipment_Status_gne__c == 'Shipped' || trx.Status_gne__c == GNE_SFA2_PFG_Util.TRANSACTION_STATUS_COMPLETED || trx.Shipped_Quantity_gne__c!=0 || trx.Received_Quantity_gne__c!=0) {
				if(trx.Received_Quantity_gne__c!=0) {
					disbursedQty = trx.Received_Quantity_gne__c.intValue();
				} else {
					disbursedQty = trx.Shipped_Quantity_gne__c.intValue();
				}
			} else {
				toFulfillQty = trx.Requested_Quantity_gne__c.intValue();
			}
				
			SFA2_PFG_Product_Limit_gne__c prodLimit = GNE_SFA2_PFG_Util.getProductLimit(trx);
			PFG_Staging_Account_Limit_Exception_gne__c accLimitEx = GNE_SFA2_PFG_Util.getAccLimitException(trx);
			Boolean noProductLimit = prodLimit==null || prodLimit.Inactive_gne__c == true;
			
			prdQtys.put(QTY_TYPE_PRODUCT_LIMIT, noProductLimit ? -1 : prodLimit.Limit_Quantity_gne__c.intValue());
			prdQtys.put(QTY_TYPE_HCP_LIMIT, accLimitEx!=null ? accLimitEx.Exception_Quantity_gne__c.intValue() : null);
			prdQtys.put(QTY_TYPE_DISBURSED, prdQtys.get(QTY_TYPE_DISBURSED) + (disbursedQty!=null ? disbursedQty : 0));
			prdQtys.put(QTY_TYPE_TO_FULFILL, prdQtys.get(QTY_TYPE_TO_FULFILL) + (toFulfillQty!=null ? toFulfillQty : 0));
			
			Integer remaining = (prdQtys.get(QTY_TYPE_HCP_LIMIT)!=null 
						? prdQtys.get(QTY_TYPE_HCP_LIMIT) 
						: (prdQtys.get(QTY_TYPE_PRODUCT_LIMIT)!=null ? prdQtys.get(QTY_TYPE_PRODUCT_LIMIT) : 0))
			 		- (prdQtys.get(QTY_TYPE_DISBURSED) + prdQtys.get(QTY_TYPE_TO_FULFILL));
			 
			prdQtys.put(QTY_TYPE_REMAINING, noProductLimit ? null : Math.max(remaining, 0));
		}
	}
	
	protected void getQuantitiesFromAccountDetails(Set<Id> accIds) {
		List<SFA2_PFG_to_Account_Detail_gne__c> aDetails;
		
		if(!limitYears.isEmpty() && !productIds.isEmpty()) {
			aDetails = [
				SELECT Account_gne__c, Account_gne__r.Name, Product_gne__c, Product_gne__r.Name, 
					Limit_Year_gne__c, Max_Quantity_gne__c, 
					Exception_Limit_gne__c, Exception_Quantity_gne__c, 
					Qty_Disbursed_gne__c, Qty_to_Fulfill_gne__c, Remaining_Quantity_gne__c
				FROM SFA2_PFG_to_Account_Detail_gne__c
				WHERE Account_gne__c IN :accIds
					AND Product_gne__c IN :productIds
					AND Limit_Year_gne__c IN :limitYearsString];
		} else {
			aDetails = [
				SELECT Account_gne__c, Account_gne__r.Name, Product_gne__c, Product_gne__r.Name, 
					Limit_Year_gne__c, Max_Quantity_gne__c, 
					Exception_Limit_gne__c, Exception_Quantity_gne__c, 
					Qty_Disbursed_gne__c, Qty_to_Fulfill_gne__c, Remaining_Quantity_gne__c
				FROM SFA2_PFG_to_Account_Detail_gne__c
				WHERE Account_gne__c IN :accIds];
		}
		
		for(SFA2_PFG_to_Account_Detail_gne__c aDetail : aDetails) {
			cacheAccountDetail(aDetail);
			accDetailCount++;
			Boolean noProductLimit = aDetail.Max_Quantity_gne__c == -1;
			Map<String, Integer> prdQtys = getAccountProductYearQtyData(getAccountDetailsKey(aDetail), accDetailsQtys);
			prdQtys.put(QTY_TYPE_PRODUCT_LIMIT, aDetail.Max_Quantity_gne__c.intValue());
			prdQtys.put(QTY_TYPE_HCP_LIMIT, aDetail.Exception_Limit_gne__c ? aDetail.Exception_Quantity_gne__c.intValue() : null);
			prdQtys.put(QTY_TYPE_DISBURSED, aDetail.Qty_Disbursed_gne__c.intValue());
			prdQtys.put(QTY_TYPE_TO_FULFILL, aDetail.Qty_to_Fulfill_gne__c.intValue());
			prdQtys.put(QTY_TYPE_REMAINING, noProductLimit ? null : aDetail.Remaining_Quantity_gne__c.intValue());
		}
	}
	
	protected String getAccountDetailsKey(SFA2_PFG_to_Account_Detail_gne__c aDetail) {
		return aDetail.Limit_Year_gne__c + '_' + aDetail.Account_gne__c + '_' + aDetail.Product_gne__c;
	}
	
	protected String getAccountDetailsKey(SFA2_PFG_Transaction_gne__c trx) {
		return GNE_SFA2_PFG_Util.getYear(trx) + '_' + trx.Account_gne__c + '_' + trx.Product_gne__c;
	}
	
	protected void cacheAccountDetail(SFA2_PFG_to_Account_Detail_gne__c aDetail) {
		aDetailsCache.put(getAccountDetailsKey(aDetail), aDetail);
	}
	
	protected SFA2_PFG_to_Account_Detail_gne__c getAccountDetail(String key) {
		return aDetailsCache.get(key);
	}
	
	protected Map<String,Integer> getAccountProductYearQtyData(String key, Map<String,Map<String, Integer>> hcpsQtys) {
		if(!hcpsQtys.containsKey(key)) {
			hcpsQtys.put(key, new Map<String,Integer>{
				QTY_TYPE_PRODUCT_LIMIT => 0, QTY_TYPE_HCP_LIMIT => 0, QTY_TYPE_DISBURSED => 0, QTY_TYPE_TO_FULFILL => 0, QTY_TYPE_REMAINING => 0
			});
		}
		
		return hcpsQtys.get(key);
	}
	
	protected void compareDtpQuantities() {
		Set<String> wrongAccDetailKeys = new Set<String>();
		
		List<String> keySortedList = new List<String>(trxsQtys.keySet());
		keySortedList.sort();
		 
		for(String key : keySortedList) {
			String[] keyParts = key.split('_');
			String year = keyParts[0];
			Id accId = (Id)keyParts[1];
			Id prodId = (Id)keyParts[2];
			
			
			String accName = accountNamesCache.get(accId);
			String prodName = prodNamesCache.get(prodId);
			
			for(String qtyType : trxsQtys.get(key).keySet()) {
				Integer trxQty = trxsQtys.get(key).get(qtyType);
				Integer aDetailQty = null;
				
				try {
					aDetailQty = accDetailsQtys.get(key).get(qtyType);
				} catch(NullPointerException ex) {}
				
				if(trxQty!=aDetailQty) {
					wrongAccDetailKeys.add(key);
					reportRowsWrappers.add(new ReportRowWrapper(accId, accName, prodId, prodName, year,
							qtyType, trxQty, aDetailQty, getAccountDetail(key)));
				}
			}
		}
		
		wrongAccDetailCount = wrongAccDetailKeys.size();
	}
	
	protected virtual void createReport(Database.BatchableContext BC) {
		if(!reportRowsWrappers.isEmpty()) {
			List<GNE_SFA2_PFG_Report_Engine.ReportRow> reportRows = new List<GNE_SFA2_PFG_Report_Engine.ReportRow>{new GNE_SFA2_PFG_Report_Engine.ReportRow(REPORT_COLUMNS)};
		
			for(ReportRowWrapper row : reportRowsWrappers) {
				reportRows.add(row.getReportRow());
			}
			
			String reportExtId = GNE_SFA2_PFG_Report_Engine.getReportId(getBatchName(),System.now());
			Id reportId = GNE_SFA2_PFG_Report_Engine.saveReport(reportExtId, BC.getJobId(), reportRows);
			sendEmailReport(reportId, reportExtId, reportRows, wrongAccDetailCount, accDetailCount);
		}
	}
	
	protected void sendEmailReport(Id reportId, String reportExtId, List<GNE_SFA2_PFG_Report_Engine.ReportRow> reportRows, Integer wrongAccDetailCount, Integer accDetailCount) {
		String subject = String.format('[{0}] Quantity Differences detected ({1})', new String[]{getBatchName(), String.valueOf(reportRows.size()-1)});
		
		String htmlBody = String.format('Report ID: {0}<br/>Number of HCP Details: {1}<br/>Number of broken HCP Details: {2}<br/>', 
				new String[]{GNE_SFA2_PFG_Util.getSalesforceLink(reportId, reportExtId), String.valueOf(accDetailCount), String.valueOf(wrongAccDetailCount)});
		String htmlTable = GNE_SFA2_PFG_Report_Engine.createHtmlTable(reportRows);
		htmlBody += htmlTable;
		
		GNE_SFA2_PFG_Util.sendEmailNotification(subject, htmlBody, true);
	}
	
	public class ReportRowWrapper {
		public String terrName;
		public Id accId;
		public Id prodId;
		public String year;
		public String accName;
		public String prodName;
		public String qtyType;
		public Integer trxQty;
		public Integer aDetailQty;
		public Integer diff;
		public SFA2_PFG_to_Account_Detail_gne__c aDetail;
		
		public ReportRowWrapper(Id a_accId, String a_accName, Id a_prodId, String a_prodName, String a_year,
				String a_qtyType, Integer a_trxQty, Integer a_aDetailQty, SFA2_PFG_to_Account_Detail_gne__c a_aDetail) {
			accId = a_accId;
			accName = a_accName;
			prodId = a_prodId;
			prodName = a_prodName;
			year = a_year;
			qtyType = a_qtyType;
			trxQty = a_trxQty;
			aDetailQty = a_aDetailQty;
			diff = (trxQty!=null ? trxQty : 0) - (aDetailQty!=null ? aDetailQty : 0);
			aDetail = a_aDetail;
		}
		
		public List<Object> getReportRowAsList() {
			return new List<Object> {
				GNE_SFA2_PFG_Report_Engine.createPseudoLink(accId, accName),
				prodName,
				year,
				qtyType,
				(trxQty!=null ? (Object)trxQty : (Object)('N/A')),
				(aDetailQty!=null ? (Object)aDetailQty : (Object)('N/A')),
				diff
			};
		}
		
		public GNE_SFA2_PFG_Report_Engine.ReportRow getReportRow() {
			return new GNE_SFA2_PFG_Report_Engine.ReportRow(getReportRowAsList());
		}
	}
}