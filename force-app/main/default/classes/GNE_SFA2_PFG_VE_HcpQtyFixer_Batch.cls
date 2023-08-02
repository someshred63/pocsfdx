public with sharing class GNE_SFA2_PFG_VE_HcpQtyFixer_Batch extends GNE_SFA2_PFG_VE_HcpQtyChecker_Batch {
	public override System.Type getBatchClass() {
		return GNE_SFA2_PFG_VE_HcpQtyFixer_Batch.class;
	}
	
	public override String getBatchName() {
		return 'PFG VE HCP Quantity Fixer';
	}
	
	public override Database.QueryLocator intStart(Database.BatchableContext BC) {
		Database.QueryLocator result = super.intStart(BC);
		
		// Activate checker so it will be executed next time
		if(restrictedScopeMode) {
			GNE_SFA2_PFG_Scheduler.activateJob(GNE_SFA2_PFG_VE_HcpQtyChecker_Batch.class);
		}
	
		return result;
	}
	
	protected override void createReport(Database.BatchableContext BC) {
		Map<String,SFA2_PFG_to_Account_Detail_gne__c> aDatailsToUpdate = new Map<String,SFA2_PFG_to_Account_Detail_gne__c>();
		
		for(GNE_SFA2_PFG_VE_HcpQtyChecker_Batch.ReportRowWrapper rowWrapper : reportRowsWrappers) {
			SFA2_PFG_to_Account_Detail_gne__c aDetail = rowWrapper.aDetail!=null ? rowWrapper.aDetail : aDatailsToUpdate.get(rowWrapper.accId + '_' + rowWrapper.prodId + '_' + rowWrapper.year);
			rowWrapper.aDetail = aDetail;
			
			if(aDetail==null) {
				aDetail = rowWrapper.aDetail = createAccountDetail(rowWrapper.accId, rowWrapper.prodId, rowWrapper.year);
			}
			
			Integer trxQty = rowWrapper.trxQty;
			if(rowWrapper.qtyType == QTY_TYPE_PRODUCT_LIMIT) {
				aDetail.Max_Quantity_gne__c = trxQty!=null ? trxQty : -1;
			} else if(rowWrapper.qtyType == QTY_TYPE_HCP_LIMIT) {
				aDetail.Exception_Quantity_gne__c = trxQty!=null ? trxQty : 0;
				aDetail.Exception_Limit_gne__c = trxQty!=null;
			} else if(rowWrapper.qtyType == QTY_TYPE_DISBURSED) {
				aDetail.Qty_Disbursed_gne__c = trxQty;
			} else if(rowWrapper.qtyType == QTY_TYPE_TO_FULFILL) {
				aDetail.Qty_to_Fulfill_gne__c = trxQty;
			} 
			
			aDatailsToUpdate.put(getAccountDetailsKey(aDetail),aDetail);
		}
		
		for(GNE_SFA2_PFG_VE_HcpQtyChecker_Batch.ReportRowWrapper rowWrapper : reportRowsWrappers) {
			SFA2_PFG_to_Account_Detail_gne__c aDetail = rowWrapper.aDetail;
			Integer trxQty = rowWrapper.trxQty;
			
			if(trxQty!=null && rowWrapper.qtyType == QTY_TYPE_REMAINING) {
				Integer aDetailAvailable = Math.max(0,(aDetail.Exception_Limit_gne__c ? aDetail.Exception_Quantity_gne__c.intValue() : aDetail.Max_Quantity_gne__c.intValue()) - 
						(aDetail.Qty_Disbursed_gne__c.intValue() +  aDetail.Qty_to_Fulfill_gne__c.intValue()));
				
				if(aDetail.Exception_Limit_gne__c) {
					aDetail.Exception_Quantity_gne__c += trxQty-aDetailAvailable;	
				} else {
					aDetail.Max_Quantity_gne__c += trxQty-aDetailAvailable;
				}
			}
		}
		
		if(!aDatailsToUpdate.isEmpty()) {
			GNE_Batch_Runner.executeDML(this, aDatailsToUpdate.values(), GNE_Batch_Runner.DMLType.UPSERT_DML, null, 'Upsert PFG HCP Details');
			
			List<String> columns = new List<String>(REPORT_COLUMNS);
			columns.add('Status');
			List<GNE_SFA2_PFG_Report_Engine.ReportRow> reportRows = new List<GNE_SFA2_PFG_Report_Engine.ReportRow>{new GNE_SFA2_PFG_Report_Engine.ReportRow(columns)};
		
			for(GNE_SFA2_PFG_VE_HcpQtyChecker_Batch.ReportRowWrapper row : reportRowsWrappers) {
				List<Object> rowAsList = row.getReportRowAsList();
				rowAsList.add('Fixed');
				reportRows.add(new GNE_SFA2_PFG_Report_Engine.ReportRow(rowAsList));
			}
			
			String reportExtId = GNE_SFA2_PFG_Report_Engine.getReportId(getBatchName(), System.now());
			Id reportId = GNE_SFA2_PFG_Report_Engine.saveReport(reportExtId, BC.getJobId(), reportRows);
			
			
			// Email is sent only if process was executed in Full Mode	
			if(!restrictedScopeMode) {
				sendEmailReport(reportId, reportExtId, reportRows, wrongAccDetailCount, accDetailCount);
			}
		}
	}
	
	private SFA2_PFG_to_Account_Detail_gne__c createAccountDetail(Id accId, Id prodId, String year) {
		SFA2_PFG_to_Account_Detail_gne__c aDetail = new SFA2_PFG_to_Account_Detail_gne__c(
			Account_gne__c = accId,
			Product_gne__c = prodId,
			Limit_Year_gne__c = year,
			Distribution_Method_gne__c = GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP,
			Freeze_for_Pending_AOC_gne__c = 'No',
			Exception_Limit_gne__c = false,
			Max_Quantity_gne__c = -1,
			Exception_Quantity_gne__c = 0,
			Qty_Disbursed_gne__c = 0,
			Qty_to_Fulfill_gne__c = 0);
			
		return aDetail;
	}
}