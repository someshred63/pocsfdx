public with sharing class GNE_SFA2_PFG_VE_SignatureChecker_Batch implements Database.Batchable<sObject>, Database.Stateful, 
		GNE_Batch_Runner.BatchableBase, GNE_SFA2_PFG_Scheduler.SchedulerProcess, GNE_SFA2_PFG_Report_Engine.ReportEngine {
	
	private List<GNE_SFA2_PFG_Report_Engine.ReportRow> reportRows = new List<GNE_SFA2_PFG_Report_Engine.ReportRow>();
	
	private static final String[] REPORT_COLUMNS = new String[] {
			'#', 'ID', 'Type', 'From', 'Account', 'Address', 'Interaction', 'Product', 'Requested / Shipped / Received', 'Status', 'Shipped Status', 'Signature Status', 
			'Signature?', 'AOC Signature?', 'Created By', 'Last Modified By'
		};
	private static final String DATE_FORMAT = 'MM/dd/yyyy';
	
	public void executeSchedulerProcess() {
		GNE_Batch_Runner.setScheduleAfterMinutes(30);
		GNE_Batch_Runner.executeBatch(this, false, true, false, true);
	}
	
	public String getPfgReportName() {
		return getBatchName();
	}
	
	public System.Type getBatchClass() {
		return GNE_SFA2_PFG_VE_SignatureChecker_Batch.class;
	}
	
	public String getBatchName() {
		return 'PFG VE Signature Checker';
	}
	
	
	public String getKeyForRecord(SObject sObj) {return null;}
	public String getRecordDescription(SObject sObj) {return null;}
	
	public Database.QueryLocator start(Database.BatchableContext BC) {
    	return GNE_Batch_Runner.doStart(this,BC);
    }
    
	public Database.QueryLocator intStart(Database.BatchableContext BC) {
		Set<String> validRecordTypes = new Set<String>{GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_DISBURSEMENT, GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RFF};
		String dtpType = GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP;
		String hcType = GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC;
		String signatureStatusFieldName = String.valueOf(SFA2_PFG_Transaction_gne__c.Signature_Status_gne__c);
		String sigCompleteStatus = GNE_SFA2_PFG_Util.TRANSACTION_SIGNATURE_COMPLETE;
		
		return Database.getQueryLocator([
				SELECT
					Name,
					Distribution_Method_gne__c,
					Account_gne__c,
					Account_gne__r.Name,
					Address_ID_gne__c,
					Address_ID_gne__r.Name,
					Address_ID_gne__r.Address_Line_2_vod__c,
					Address_ID_gne__r.City_vod__c,
					Address_ID_gne__r.State_vod__c,
					Address_ID_gne__r.Zip_vod__c,
					Address_ID_gne__r.Zip_4_vod__c,
					Address_ID_gne__r.Province_can_gne__c,
					Address_ID_gne__r.Postal_Code_can_gne__c,
					Call_PFG_Detail_ID_gne__r.Call_gne__c,
					Call_PFG_Detail_ID_gne__r.Call_gne__r.Name,
					Product_gne__r.Name, 
					Requested_Quantity_gne__c,
					Shipped_Quantity_gne__c,
					Received_Quantity_gne__c,
					Status_gne__c,
					Shipment_Status_gne__c,
					Signature_Status_gne__c,
					Request_Signature_gne__c,
					Signature_gne__c,
					From_Territory_Name_gne__c, 
					From_User_Territory_gne__c,
					From_User_gne__c,
					From_User_gne__r.Name, 
					RecordType.Name,
					CreatedBy.Id, 
					CreatedBy.Name,
					CreatedDate,
					LastModifiedBy.Id, 
					LastModifiedBy.Name,
					LastModifiedDate,
					(SELECT CreatedDate, CreatedBy.Id, CreatedBy.Name, Field, NewValue FROM Histories
					 WHERE Field = :signatureStatusFieldName
					 ORDER BY CreatedDate desc
					 LIMIT 1)
				FROM SFA2_PFG_Transaction_gne__c
				WHERE 
					RecordType.Name IN :validRecordTypes
					AND Call_PFG_Detail_ID_gne__r.iPhone_Request_Id_gne__c <> null
					AND (
						   Request_Signature_Date_gne__c = null
		 				OR (Distribution_Method_gne__c = :dtpType AND Signature_Date_gne__c = null AND Signature_Status_gne__c = :sigCompleteStatus)
		 				)
				ORDER BY Distribution_Method_gne__c, From_Territory_Name_gne__c, Account_gne__r.Name, Call_PFG_Detail_ID_gne__r.Call_gne__r.Name, Product_gne__r.Name
			]);
	}
	
	public void execute(Database.BatchableContext BC, List<sObject> scope) {
    	GNE_Batch_Runner.doExecute(this,BC, scope);
    }
    
    public void intExecute(Database.BatchableContext BC, List<sObject> scope) {
		String sigCompleteStatus = GNE_SFA2_PFG_Util.TRANSACTION_SIGNATURE_COMPLETE;
		
		for(SFA2_PFG_Transaction_gne__c trx : (List<SFA2_PFG_Transaction_gne__c>)scope) {
			// HC - signature isn't set or DTP - first singature isn't set
			if(trx.RecordType.Name == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_DISBURSEMENT || String.isBlank(trx.Request_Signature_gne__c)) {
				reportRows.add(createReportRowFromTransaction(trx, trx.LastModifiedBy.Id, trx.LastModifiedBy.Name, trx.LastModifiedDate));
			} else { // DTP - AOC Signature isn't set
				Boolean isSigStatusCompletedByVendor = true;
				Id lastModifiedById = trx.LastModifiedBy.Id;
				String lastModifiedByName = trx.LastModifiedBy.Name;
				DateTime lastModifedDate = trx.LastModifiedDate;
				
				for(SFA2_PFG_Transaction_gne__History hRec : trx.Histories) {
					if(hRec.NewValue == sigCompleteStatus) {
						isSigStatusCompletedByVendor = GNE_SFA2_PFG_Util.getSalesRosterForUser(hRec.CreatedBy.Id) == null;
						lastModifiedById = hRec.CreatedBy.Id;
						lastModifiedByName = hRec.CreatedBy.Name;
						lastModifedDate = hRec.CreatedDate;
					}
				}
				
				// It means that transaction was AOC Completed in OTR, so it must have AOC Signature
				if(!isSigStatusCompletedByVendor) {
					reportRows.add(createReportRowFromTransaction(trx, lastModifiedById, lastModifiedByName, lastModifedDate));	
				}
			}
		}
	}
	
	private GNE_SFA2_PFG_Report_Engine.ReportRow createReportRowFromTransaction(SFA2_PFG_Transaction_gne__c trx,
			Id lastModifiedById, String lastModifiedByName, DateTime lastModifedDate) {
		String trxName = GNE_SFA2_PFG_Report_Engine.createPseudoLink(trx.Id, trx.Name);
		String dMethod = trx.Distribution_Method_gne__c;
		String terrOrUserName;
		
		Boolean isHc;
		if((isHc = trx.RecordType.Name == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_DISBURSEMENT)) {
			terrOrUserName = trx.From_User_gne__r!=null ? GNE_SFA2_PFG_Report_Engine.createPseudoLink(trx.From_User_gne__c, trx.From_User_gne__r.Name) : '';
		} else {
			terrOrUserName = trx.From_User_Territory_gne__c!=null ? GNE_SFA2_PFG_Report_Engine.createPseudoLink(trx.From_User_Territory_gne__c, trx.From_Territory_Name_gne__c) : '';
		}
		
		String accName = trx.Account_gne__r!=null ? GNE_SFA2_PFG_Report_Engine.createPseudoLink(trx.Account_gne__c, trx.Account_gne__r.Name) : '';
		String addName = trx.Address_ID_gne__r!=null ? GNE_SFA2_PFG_Report_Engine.createPseudoLink(trx.Address_ID_gne__c, GNE_SFA2_Util.getAddressAsString(trx.Address_ID_gne__r)) : '';
		String callName = GNE_SFA2_PFG_Report_Engine.createPseudoLink(trx.Call_PFG_Detail_ID_gne__r.Call_gne__c, trx.Call_PFG_Detail_ID_gne__r.Call_gne__r.Name);
		String prodName = trx.Product_gne__r.Name;
		String qtys = trx.Requested_Quantity_gne__c.intValue() + '/' + trx.Shipped_Quantity_gne__c.intValue() + '/' + trx.Received_Quantity_gne__c.intValue();
		String status = trx.Status_gne__c;
		string shipStatus = trx.Shipment_Status_gne__c;
		String sigStatus = trx.Signature_Status_gne__c;
		String hasRequestSignature = String.valueOf(String.isNotBlank(trx.Request_Signature_gne__c));
		String hasSignature = isHc ? '-' : String.valueOf(String.isNotBlank(trx.Signature_gne__c));
		String createdByAndDate = GNE_SFA2_PFG_Report_Engine.createPseudoLink(trx.CreatedBy.Id, trx.CreatedBy.Name + ', ' + trx.CreatedDate.format(DATE_FORMAT));
		String lastModifiedByAndDate = GNE_SFA2_PFG_Report_Engine.createPseudoLink(lastModifiedById, lastModifiedByName + ', ' + lastModifedDate.format(DATE_FORMAT));
		
		return new GNE_SFA2_PFG_Report_Engine.ReportRow(new List<Object>{
			reportRows.size()+1, trxName, dMethod, terrOrUserName, accName, addName, callName, prodName, qtys, 
			status, shipStatus, sigStatus, hasRequestSignature, hasSignature, createdByAndDate, lastModifiedByAndDate
		});
	}
	
	public void finish(Database.BatchableContext BC) {
        GNE_Batch_Runner.doFinish(this,BC);
    }
	
	public void intFinish(Database.BatchableContext BC) {
		GNE_SFA2_PFG_Util.addSessionLabel(getBatchName());
		
		if(!reportRows.isEmpty()) {
			reportRows.add(0,new GNE_SFA2_PFG_Report_Engine.ReportRow(REPORT_COLUMNS));
			String reportExtId = GNE_SFA2_PFG_Report_Engine.getReportId(getBatchName(),System.now());
			Id reportId = GNE_SFA2_PFG_Report_Engine.saveReport(reportExtId, BC.getJobId(), reportRows);
			sendEmailReport(reportId, reportExtId, reportRows);
		}
	}
	
	private void sendEmailReport(Id reportId, String reportExtId, List<GNE_SFA2_PFG_Report_Engine.ReportRow> reportRows) {
		String subject = String.format('[{0}] Missing Signatures detected ({1})', new String[]{getBatchName(), String.valueOf(reportRows.size()-1)});
		String htmlBody = 'Report Id: ' + GNE_SFA2_PFG_Util.getSalesforceLink(reportId, reportExtId) + '<br/>';
		htmlBody += GNE_SFA2_PFG_Report_Engine.createHtmlTable(reportRows);
		GNE_SFA2_PFG_Util.sendEmailNotification(subject, htmlBody, true);
	}
}