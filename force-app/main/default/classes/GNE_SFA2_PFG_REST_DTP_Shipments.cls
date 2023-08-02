@RestResource(urlMapping='/sfa2_dtp_shipments_inbound_R1/*')
global with sharing class GNE_SFA2_PFG_REST_DTP_Shipments extends GNE_SFA2_PFG_REST_Base {
	global class ResultSet extends GNE_SFA2_PFG_REST_Base.ResultSet {
		public transient List<SFA2_PFG_Transaction_gne__c> trxsToUpdate;
		public transient Map<Id,Call_PFG_Detail_gne__c> cDetailsToUpdate;
	}
	
	global class DtpShipment {
		public String Ship_Id;
		public String Txn_ID;
		public String Call_ID;
		public String Pick_Num;
		public String Ship_Date;
		public String HCP_Id;
		public String HCP_Add_Ln_1;
		public String HCP_Add_Ln_2;
		public String HCP_City;
		public String HCP_State;
		public String HCP_Zip;
		public String Zip_Ext;
		public String Prod_Ln_ID;
		public String NDC;
		public String Prod_Nm;
		public String Lot_No;
		public Integer Txn_Qty;
		public String Carrier;
		public String Track_Id;
		public String Track_URL;
		public String Sig_Sts;
		
		public void updateTransaction(SFA2_PFG_Transaction_gne__c trx) {
			trx.Shipment_Id_gne__c = Ship_Id;
			trx.Pick_Slip_Number_gne__c = Pick_Num;
			trx.Shipped_Date_gne__c = GNE_SFA2_PFG_REST_Utils.parseDateTimeGmt(Ship_Date).dateGmt();
			trx.Shipped_To_Address_By_Third_Party_gne__c = getAddressDescription();
			trx.Lot_No_gne__c = Lot_No;
			trx.Shipped_Quantity_gne__c = Txn_Qty;
			trx.Carrier_gne__c = Carrier;
			
			if(String.isBlank(trx.Tracking_Id_gne__c) || !trx.Tracking_Id_gne__c.endsWith(Track_Id)) {
				trx.Tracking_Id_gne__c = (String.isBlank(trx.Tracking_Id_gne__c) ? Track_Id : (trx.Tracking_Id_gne__c + '\n' + Track_Id));
			}
			
			if(String.isBlank(trx.Tracking_URL_gne__c) || !trx.Tracking_URL_gne__c.endsWith(Track_URL)) {
				trx.Tracking_URL_gne__c = (String.isBlank(trx.Tracking_URL_gne__c) ? Track_URL : (trx.Tracking_URL_gne__c + '\n' + Track_URL));
			}
			
			trx.Signature_Status_gne__c = convertSigStsToStatus();
		}
		
		private String getAddressDescription() {
			return String.join(new List<String>{HCP_Add_Ln_1,HCP_Add_Ln_2,HCP_City,HCP_State,HCP_Zip},'||');
		}
		
		public Call_PFG_Detail_gne__c updateCallDetail(Id callDetailId) {
			return new Call_PFG_Detail_gne__c(
				Id = callDetailId,
				Quantity_gne__c = Txn_Qty,
				Shipment_Id_gne__c = Ship_Id, 
				Lot_No_gne__c = Lot_No, 
				DTP_AOC_Status_gne__c = convertSigStsToStatus());
		}
		
		private String convertSigStsToStatus() {
            String status = null;
            
            if(Sig_Sts == 'C') {
                status = GNE_SFA2_PFG_Util.TRANSACTION_SIGNATURE_COMPLETE;
            } else if(Sig_Sts == 'P') {
                status = GNE_SFA2_PFG_Util.TRANSACTION_SIGNATURE_PENDING;
            } else {
                status = GNE_SFA2_PFG_Util.TRANSACTION_SIGNATURE_INCOMPLETE;
            }
            
            return status;
        }
	}
	
	@HttpPost
	global static ResultSet setShipments(List<DtpShipment> records) {
		return (ResultSet)(new GNE_SFA2_PFG_REST_DTP_Shipments()).processInputObjects(records, new ResultSet());
	}
	
	protected override void intProcessInputObjects(List<Object> a_inputObjects, GNE_SFA2_PFG_REST_Base.ResultSet a_result) {
		List<DtpShipment> shipments = (List<DtpShipment>)a_inputObjects;
		ResultSet result = (ResultSet)a_result;
		
		
		Map<String,DtpShipment> shipmentsMap = new Map<String,DtpShipment>();
		Set<String> rffNames = new Set<String>();
		Set<String> paperOrderRefNos = new Set<String>();
		Set<String> paperOrderLineItemIds = new Set<String>();
		
		for(DtpShipment shipmentsWrapper : shipments) {
			shipmentsMap.put(getKeyForOrder(shipmentsWrapper), shipmentsWrapper);
			
			String lineItemId = shipmentsWrapper.Prod_Ln_ID!=null ? shipmentsWrapper.Prod_Ln_ID.toUpperCase(): null;
			if(String.isNotBlank(shipmentsWrapper.Call_ID)) {
				rffNames.add(lineItemId);
			} else {
				paperOrderRefNos.add(shipmentsWrapper.Txn_ID);
				paperOrderLineItemIds.add(lineItemId);
			}
			
		}
		
		List<SFA2_PFG_Transaction_gne__c> trxs = GNE_SFA2_PFG_REST_DAO.getDtpShipments(rffNames, paperOrderRefNos, paperOrderLineItemIds);
		result.trxsToUpdate = new List<SFA2_PFG_Transaction_gne__c>();
		Map<Id,Call_PFG_Detail_gne__c> cDetailsToUpdate = result.cDetailsToUpdate = new Map<Id,Call_PFG_Detail_gne__c>();
		
		for(SFA2_PFG_Transaction_gne__c trx : trxs) {
			DtpShipment shipmentsWrapper = shipmentsMap.get(getKeyForOrder(trx));
			
			if(shipmentsWrapper!=null) {
				shipmentsWrapper.updateTransaction(trx);
				result.trxsToUpdate.add(trx);
				
				if(trx.Call_PFG_Detail_ID_gne__c!=null && !cDetailsToUpdate.containsKey(trx.Call_PFG_Detail_ID_gne__c)) {
					Call_PFG_Detail_gne__c cDetail = shipmentsWrapper.updateCallDetail(trx.Call_PFG_Detail_ID_gne__c);
					cDetailsToUpdate.put(trx.Call_PFG_Detail_ID_gne__c, cDetail);
				}
			}
		}
	}
	
	protected override void executeDmls(GNE_SFA2_PFG_REST_Base.ResultSet a_result) {
		ResultSet result = (ResultSet)a_result;
		
		if(!result.trxsToUpdate.isEmpty()) {
			update result.trxsToUpdate;
		}
		
		if(!result.cDetailsToUpdate.isEmpty()) {
			update result.cDetailsToUpdate.values();
		}
	}
	
	private String getKeyForOrder(SFA2_PFG_Transaction_gne__c trx) {
		Boolean isRffOrPaperOrder = GNE_SFA2_PFG_Util.getTransactionRecordTypeName(trx.RecordTypeId) == GNE_SFA2_PFG_Util.TRANSACTION_RECORD_TYPE_RFF;
    	return trx.Transaction_Ref_Number_gne__c.toUpperCase() + '_' + (isRffOrPaperOrder ? trx.Name.toUpperCase() : trx.Line_Item_ID_gne__c.toUpperCase());
    }
    
    private String getKeyForOrder(DtpShipment shipmentsWrapper) {
    	return (String.isNotBlank(shipmentsWrapper.Txn_ID) ? shipmentsWrapper.Txn_ID.toUpperCase() : null) + '_' + 
    			(String.isNotBlank(shipmentsWrapper.Prod_Ln_ID) ? shipmentsWrapper.Prod_Ln_ID.toUpperCase() : null);
    }
}