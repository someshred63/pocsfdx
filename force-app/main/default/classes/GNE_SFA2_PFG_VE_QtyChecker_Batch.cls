public with sharing virtual class GNE_SFA2_PFG_VE_QtyChecker_Batch implements Database.Batchable<sObject>, Database.Stateful,
		GNE_Batch_Runner.Batchable, GNE_SFA2_PFG_Scheduler.SchedulerProcess, GNE_SFA2_PFG_Report_Engine.ReportEngine {

	protected final String QTY_TYPE_ALLOCATED = 'ALLOCATED';
	protected final String QTY_TYPE_SHIPPED = 'SHIPPED';
	protected final String QTY_TYPE_PENDING = 'PENDING';
	protected final String QTY_TYPE_REMAINING = 'REMAINING';
	protected final String[] REPORT_COLUMNS = new String[]{'Territory', 'User(s)', 'Product', 'Year', 'Quantity Type', 'Quantity based on Transactions', 'Quantity based on My PFG', 'Diff'};

	protected Map<String,Map<String, Integer>> terrQtys = new Map<String,Map<String, Integer>>();
	@TestVisible protected Set<String> terrNames = new Set<String>();
	protected Map<String,Id> terrNameToIdMap = new Map<String,Id>();
	protected Map<Id,String> prodIdToNameMap = new Map<Id,String>();
	protected Map<String,SFA2_PFG_to_Territory_Detail_gne__c> tDetailsCache = new Map<String,SFA2_PFG_to_Territory_Detail_gne__c>();
	@TestVisible protected List<ReportRowWrapper> reportRowsWrappers = new List<ReportRowWrapper>();
	protected Integer terrProductCount = 0;
	protected Integer wrongTerrProductCount = 0;

	public void executeSchedulerProcess() {
		GNE_Batch_Runner.setScheduleAfterMinutes(30);
		GNE_Batch_Runner.executeBatch(this, false, true, false, true);
	}

	public String getPfgReportName() {
		return getBatchName();
	}

	public virtual System.Type getBatchClass() {
		return GNE_SFA2_PFG_VE_QtyChecker_Batch.class;
	}

	public virtual String getBatchName() {
		return 'PFG VE Quantity Checker';
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

	public Database.QueryLocator intStart(Database.BatchableContext BC) {
		Set<String> validRecordTypes = new Set<String>{
			GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ALLOCATION,
			GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ALLOCATION_TRANSFER,
			GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RFF,
			GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_DTP_PAPER_ORDER};
		String distributionType = GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP;
		Set<String> excludedDeliveryStatuses = GNE_SFA2_PFG_Util.TRANSACTION_DELIVERY_ABORT_STATUSES;

		return Database.getQueryLocator([
				SELECT
					From_Territory_Name_gne__c, To_Territory_Name_gne__c, From_User_Territory_gne__c, To_User_Territory_gne__c,
					From_Territory_Number_gne__c, To_Territory_Number_gne__c,
					Requested_Quantity_gne__c, Shipped_Quantity_gne__c, Received_Quantity_gne__c,
					Status_gne__c, Shipment_Status_gne__c, Signature_Status_gne__c, Delivery_Status_gne__c, Distribution_Method_gne__c,
					RecordType.Name, Product_gne__c, Product_gne__r.Name, Transaction_Date_gne__c
				FROM SFA2_PFG_Transaction_gne__c
				WHERE RecordType.Name IN :validRecordTypes
					AND Distribution_Method_gne__c = :distributionType
					AND Delivery_Status_gne__c NOT IN :excludedDeliveryStatuses
				ORDER BY From_Territory_Name_gne__c, To_Territory_Name_gne__c, Product_gne__r.Name
			]);
	}

	public void execute(Database.BatchableContext BC, List<sObject> scope) {
    	GNE_Batch_Runner.doExecute(this,BC, scope);
    }

    public void intExecute(Database.BatchableContext BC, List<sObject> scope) {
		getQuantitiesFromTransactions((List<SFA2_PFG_Transaction_gne__c>)scope);
	}

	public void finish(Database.BatchableContext BC) {
        GNE_Batch_Runner.doFinish(this,BC);
    }

	public virtual void intFinish(Database.BatchableContext BC) {
		GNE_SFA2_PFG_Util.addSessionLabel(getBatchName());
		compareDtpQuantities();
		createReport(BC);
	}

	private void getQuantitiesFromTransactions(List<SFA2_PFG_Transaction_gne__c> trxs) {
		String hoTerrName = GNE_SFA2_PFG_Util.getHoTerritoryId();

		for(SFA2_PFG_Transaction_gne__c trx : trxs) {
			prodIdToNameMap.put(trx.Product_gne__c, trx.Product_gne__r.Name);

			String fromTerrName = trx.From_Territory_Name_gne__c;
			String toTerrName = trx.To_Territory_Name_gne__c;

			if(fromTerrName!=null) {
				terrNames.add(fromTerrName);
				terrNameToIdMap.put(fromTerrName,  hoTerrName==fromTerrName ? null : trx.From_User_Territory_gne__c);
			}

			if(toTerrName!=null) {
				terrNames.add(toTerrName);
				terrNameToIdMap.put(toTerrName,  hoTerrName==toTerrName ? null : trx.To_User_Territory_gne__c);
			}

			if(trx.RecordType.Name.equals(GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ALLOCATION) && toTerrName!=null) {
				Map<String, Integer> prdQtys = getProductQtyData(toTerrName, trx.Product_gne__c, GNE_SFA2_PFG_Util.getYear(trx), terrQtys);
				prdQtys.put(QTY_TYPE_ALLOCATED, prdQtys.get(QTY_TYPE_ALLOCATED) + trx.Requested_Quantity_gne__c.intValue());
				prdQtys.put(QTY_TYPE_REMAINING, prdQtys.get(QTY_TYPE_REMAINING) + trx.Requested_Quantity_gne__c.intValue());
			} else if(trx.RecordType.Name.equals(GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_ALLOCATION_TRANSFER)) {
				if(fromTerrName!=null && toTerrName!=null) {
					Territory2 fromTerr = GNE_SFA2_PFG_Util.getTerritoryByName(fromTerrName);
                	Territory2 toTerr = GNE_SFA2_PFG_Util.getTerritoryByName(toTerrName);
                	Integer fromLevel, toLevel;

                	if(fromTerr!=null && toTerr!=null) {
                		fromLevel = GNE_SFA2_PFG_Util.getTerritoryLevel(fromTerr.Id);
                		toLevel = GNE_SFA2_PFG_Util.getTerritoryLevel(toTerr.Id);
                	} else {
                		fromLevel = fromTerrName == hoTerrName ? 0 : trx.From_Territory_Number_gne__c.length();
                		toLevel = toTerrName == hoTerrName ? 0 : trx.To_Territory_Number_gne__c.length();
                	}

                	Map<String, Integer> prdQtys = getProductQtyData(fromTerrName, trx.Product_gne__c, GNE_SFA2_PFG_Util.getYear(trx), terrQtys);
					prdQtys.put(QTY_TYPE_REMAINING, prdQtys.get(QTY_TYPE_REMAINING) - trx.Requested_Quantity_gne__c.intValue());

                	if(fromLevel>=toLevel) {
                		prdQtys.put(QTY_TYPE_ALLOCATED, prdQtys.get(QTY_TYPE_ALLOCATED) - trx.Requested_Quantity_gne__c.intValue());
                	}

                	prdQtys = getProductQtyData(toTerrName, trx.Product_gne__c, GNE_SFA2_PFG_Util.getYear(trx), terrQtys);
                	prdQtys.put(QTY_TYPE_REMAINING, prdQtys.get(QTY_TYPE_REMAINING) + trx.Requested_Quantity_gne__c.intValue());

                	if(fromLevel<=toLevel) {
                		prdQtys.put(QTY_TYPE_ALLOCATED, prdQtys.get(QTY_TYPE_ALLOCATED) + trx.Requested_Quantity_gne__c.intValue());
                	}
                }
			} else if((trx.RecordType.Name.equals(GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RFF) ||
					   trx.RecordType.Name.equals(GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_DTP_PAPER_ORDER)) && fromTerrName!=null) {
				Map<String, Integer> prdQtys = getProductQtyData(fromTerrName, trx.Product_gne__c, GNE_SFA2_PFG_Util.getYear(trx), terrQtys);
				Integer shippedQty = null, pendingQty = null;

				if(trx.Shipment_Status_gne__c == 'Shipped' || trx.Status_gne__c == GNE_SFA2_PFG_Util.TRANSACTION_STATUS_COMPLETED || trx.Shipped_Quantity_gne__c!=0) {
					shippedQty = trx.Shipped_Quantity_gne__c.intValue();
				} else {
					pendingQty = trx.Requested_Quantity_gne__c.intValue();
				}

				prdQtys.put(QTY_TYPE_REMAINING, prdQtys.get(QTY_TYPE_REMAINING) - (shippedQty!=null ? shippedQty : pendingQty));
				prdQtys.put(QTY_TYPE_SHIPPED, prdQtys.get(QTY_TYPE_SHIPPED) + (shippedQty!=null ? shippedQty : 0));
				prdQtys.put(QTY_TYPE_PENDING, prdQtys.get(QTY_TYPE_PENDING) + (pendingQty!=null ? pendingQty : 0));
			}
		}
	}

	protected void compareDtpQuantities() {
		Map<String,Map<String, Integer>> tDetailsQtys = getQuantitiesFromTerritoryDetails();

		Set<String> tDetailOtherKeys = new Set<String>(tDetailsQtys.keySet());
		tDetailOtherKeys.removeAll(terrQtys.keySet());

		for(String extKey : tDetailOtherKeys) {
			// Fill missing keys with zeros.
			getProductQtyData(extKey, terrQtys);
		}

		List<String> keySortedList = new List<String>(terrQtys.keySet());
		keySortedList.sort();

		for(String extKey : keySortedList) {
			String[] extKeyData = extKey.split('_');
			Integer year = Integer.valueOf(extKeyData[0]);
			String terrName = extKeyData[1];
			Id prodId = (Id)extKeyData[2];

			terrProductCount++;
			Boolean somethingWrong = false;
			for(String qtyType : terrQtys.get(extKey).keySet()) {
				Integer terrQty = terrQtys.get(extKey).get(qtyType);
				Integer tDetailQty = null;

				try {
					tDetailQty = tDetailsQtys.get(extKey).get(qtyType);
				} catch(NullPointerException ex) {}

				if(terrQty!=tDetailQty) {
					somethingWrong = true;
					List<User> users = new List<User>();
					for(Id uId : GNE_SFA2_PFG_Util.getUsersForTeritory(terrNameToIdMap.get(terrName))) {
						SFA2_User_Sales_Roster_gne__c usr = GNE_SFA2_PFG_Util.getSalesRosterForUser(uId);
						if(usr!=null) {
							User u = usr.User_gne__r;
							users.add(u);
						}
					}
					String prodName = prodIdToNameMap.get(prodId);
					reportRowsWrappers.add(new ReportRowWrapper(terrName, terrNameToIdMap.get(terrName), users, prodId, prodName, year,
							qtyType, terrQty, tDetailQty, getTerritoryDetail(terrName, prodId, year)));
				}
			}

			if(somethingWrong) {
				wrongTerrProductCount++;
			}
		}
	}

	protected virtual void createReport(Database.BatchableContext BC) {
		if(!reportRowsWrappers.isEmpty()) {
			List<GNE_SFA2_PFG_Report_Engine.ReportRow> reportRows = new List<GNE_SFA2_PFG_Report_Engine.ReportRow>{new GNE_SFA2_PFG_Report_Engine.ReportRow(REPORT_COLUMNS)};

			for(ReportRowWrapper row : reportRowsWrappers) {
				reportRows.add(row.getReportRow());
			}

			String reportExtId = GNE_SFA2_PFG_Report_Engine.getReportId(getBatchName(),System.now());
			Id reportId = GNE_SFA2_PFG_Report_Engine.saveReport(reportExtId, BC.getJobId(), reportRows);
			sendEmailReport(reportId, reportExtId, reportRows, wrongTerrProductCount, terrProductCount);
		}
	}

	protected Map<String,Map<String, Integer>> getQuantitiesFromTerritoryDetails() {
		Map<String,Map<String, Integer>> terrsQtys = new Map<String,Map<String, Integer>>();

		for(SFA2_PFG_to_Territory_Detail_gne__c tDetail : [SELECT YTD_Allocated_gne__c, Qty_Total_Allocated_gne__c,
					Qty_Shipped_to_Physician_gne__c, Qty_Reserved_gne__c, Qty_Total_Available_gne__c,
					Territory_Name_gne__c, Product_gne__c, Product_gne__r.Name, Year_gne__c
				FROM SFA2_PFG_to_Territory_Detail_gne__c]) {
			cacheTerritoryDetail(tDetail);
			Integer totalAvailable = getTotalAvailable(tDetail);
			Map<String, Integer> prdQtys = getProductQtyData(tDetail.Territory_Name_gne__c, tDetail.Product_gne__c, tDetail.Year_gne__c.intValue(), terrsQtys);
			prdQtys.put(QTY_TYPE_ALLOCATED, tDetail.YTD_Allocated_gne__c.intValue());
			prdQtys.put(QTY_TYPE_REMAINING, totalAvailable);
			prdQtys.put(QTY_TYPE_SHIPPED, tDetail.Qty_Shipped_to_Physician_gne__c.intValue());
			prdQtys.put(QTY_TYPE_PENDING, tDetail.Qty_Reserved_gne__c.intValue());
		}

		return terrsQtys;
	}

	protected Integer getTotalAvailable(SFA2_PFG_to_Territory_Detail_gne__c tDetail) {
		return tDetail.Qty_Total_Allocated_gne__c.intValue() - tDetail.Qty_Shipped_to_Physician_gne__c.intValue() - tDetail.Qty_Reserved_gne__c.intValue();
	}

	protected void cacheTerritoryDetail(SFA2_PFG_to_Territory_Detail_gne__c tDetail) {
		tDetailsCache.put(GNE_SFA2_PFG_Util.getRecordKey(tDetail), tDetail);
	}

	protected SFA2_PFG_to_Territory_Detail_gne__c getTerritoryDetail(String terrName, Id prodId, Integer year) {
		return tDetailsCache.get(terrName + '_' + prodId + '_' + year);
	}

	protected Map<String,Integer> getProductQtyData(String terrName, Id prodId, Integer year, Map<String,Map<String, Integer>> terrsQtys) {
		String extKey = year + '_' + terrName + '_' + prodId;
		return getProductQtyData(extKey, terrsQtys);
	}

	protected Map<String,Integer> getProductQtyData(String extKey, Map<String,Map<String, Integer>> terrsQtys) {
		if(!terrsQtys.containsKey(extKey)) {
			terrsQtys.put(extKey, new Map<String, Integer>{
				QTY_TYPE_ALLOCATED => 0, QTY_TYPE_SHIPPED => 0, QTY_TYPE_PENDING => 0, QTY_TYPE_REMAINING => 0
			});
		}

		return terrsQtys.get(extKey);
	}

	protected void sendEmailReport(Id reportId, String reportExtId, List<GNE_SFA2_PFG_Report_Engine.ReportRow> reportRows, Integer wrongTerrProductCount, Integer terrProductCount) {
		String subject = String.format('[{0}] Quantity Differences detected ({1})', new String[]{getBatchName(), String.valueOf(reportRows.size()-1)});

		String htmlBody = String.format('Report ID: {0}<br/>Number of Territory/Products: {1}<br/>Number of broken Territory/Products: {2}<br/>',
				new String[]{GNE_SFA2_PFG_Util.getSalesforceLink(reportId, reportExtId), String.valueOf(terrProductCount), String.valueOf(wrongTerrProductCount)});
		String htmlTable = GNE_SFA2_PFG_Report_Engine.createHtmlTable(reportRows);
		htmlBody += htmlTable;

		GNE_SFA2_PFG_Util.sendEmailNotification(subject, htmlBody, true);
	}

	public class ReportRowWrapper {
		public String terrName;
		public Id terrId;
		public GNE_SFA2_PFG_Report_Engine.ReportCell usersCell;
		public String productId;
		public String productName;
		public Integer year;
		public String qtyType;
		public Integer trxsQty;
		public Integer tDetailsQty;
		public Integer diff;
		public SFA2_PFG_to_Territory_Detail_gne__c tDetail;

		public ReportRowWrapper(String a_terrName, Id a_terrId, List<User> users, Id a_productId, String a_productName, Integer a_year, String a_qtyType,
				Integer a_trxsQty, Integer a_tDetailsQty, SFA2_PFG_to_Territory_Detail_gne__c a_tDetail) {
			terrName = a_terrName;
			terrId = a_terrId;
			List<String> upts = new List<String>(), ugwbs = new List<String>(), uhtmls = new List<String>();

			for(User u : users) {
				String extId = u.External_Id_gne__c;
				upts.add(extId);
				ugwbs.add(GNE_SFA2_PFG_Report_Engine.getGoogleWorkbookLink(u.Id,extId));
				uhtmls.add(GNE_SFA2_PFG_Util.getSalesforceLink(u.Id,extId));
			}

			usersCell = new GNE_SFA2_PFG_Report_Engine.ReportCell(String.join(upts,', '), String.join(ugwbs, ' & ", "  & '), String.join(uhtmls,', '));

			productId = a_productId;
			productName = a_productName;
			year = a_year;
			qtyType = a_qtyType;
			trxsQty = a_trxsQty;
			tDetailsQty = a_tDetailsQty;
			diff = trxsQty - (tDetailsQty!=null ? tDetailsQty : 0);
			tDetail = a_tDetail;
		}

		public List<Object> getReportRowAsList() {
			return new List<Object> {
				(terrId!=null ? GNE_SFA2_PFG_Report_Engine.createPseudoLink(terrId, terrName) : terrName),
				usersCell,
				productName,
				year,
				qtyType,
				trxsQty,
				(tDetailsQty!=null ? (Object)tDetailsQty : (Object)('N/A')),
				diff
			};
		}

		public GNE_SFA2_PFG_Report_Engine.ReportRow getReportRow() {
			return new GNE_SFA2_PFG_Report_Engine.ReportRow(getReportRowAsList());
		}
	}
}