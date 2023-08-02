@RestResource(urlMapping='/sfa2_dtp_aocstatus_inbound_R1/*')
global with sharing class GNE_SFA2_PFG_REST_DTP_AOC_Status extends GNE_SFA2_PFG_REST_Base{
    global class ResultSet extends GNE_SFA2_PFG_REST_Base.ResultSet {
        public transient List<SFA2_PFG_Transaction_gne__c> trxsToUpdate;
        public transient Map<Id,Call_PFG_Detail_gne__c> cDetailsToUpdate;
    }
    
    global class DtpAocStatus {
        public String Ship_Id;
        public String Txn_ID;
        public String Call_Id;
        public String Prod_Ln_ID;
        public String Sig_Sts;
        public Integer Txn_Qty;
        
        public void updateTransaction(SFA2_PFG_Transaction_gne__c trx) {
            trx.Shipment_Id_gne__c      = Ship_Id;
            trx.Signature_Status_gne__c = convertSigStsToStatus(trx.Signature_Status_gne__c, false);
            trx.Status_gne__c           = convertSigStsToStatus(trx.Status_gne__c, true);
            
            if(trx.Signature_Status_gne__c == GNE_SFA2_PFG_Util.TRANSACTION_SIGNATURE_COMPLETE) {
            	trx.Received_Quantity_gne__c = Txn_Qty;
            }
        }
        
        public Call_PFG_Detail_gne__c updateCallDetail(Id callDetailId) {
            Call_PFG_Detail_gne__c cDetail = new Call_PFG_Detail_gne__c(Id = callDetailId,
                Shipment_Id_gne__c = Ship_Id);
            
            String aocStatus = convertSigStsToStatus(null,false);
            if(aocStatus!=null) {
                cDetail.DTP_AOC_Status_gne__c = aocStatus;
                
                if(aocStatus == GNE_SFA2_PFG_Util.TRANSACTION_SIGNATURE_COMPLETE) {
                	cDetail.Quantity_gne__c = Txn_Qty;	
                }
            }
            
            return cDetail;
        }
        
        private String convertSigStsToStatus(String prevValue, Boolean isStatusField) {
            String status = prevValue;
            
            if(isStatusField) {
            	if(Sig_Sts == 'C') {
                	status = GNE_SFA2_PFG_Util.TRANSACTION_STATUS_COMPLETED;
            	}
            } else {
            	if(Sig_Sts == 'C') {
                	status = GNE_SFA2_PFG_Util.TRANSACTION_SIGNATURE_COMPLETE;
            	} else if(Sig_Sts == 'P') {
                	status = GNE_SFA2_PFG_Util.TRANSACTION_SIGNATURE_PENDING;
            	} else {
                	status = GNE_SFA2_PFG_Util.TRANSACTION_SIGNATURE_INCOMPLETE;
            	}		
            }
            
            return status;
        }
    }
    
    @HttpPost
    global static ResultSet setAocStatus(List<DtpAocStatus> records) {
        return (ResultSet)(new GNE_SFA2_PFG_REST_DTP_AOC_Status()).processInputObjects(records, new ResultSet());
    }
    
    protected override void intProcessInputObjects(List<Object> a_inputObjects, GNE_SFA2_PFG_REST_Base.ResultSet a_result) {
        List<DtpAocStatus> aocStatuses = (List<DtpAocStatus>)a_inputObjects;
        ResultSet result = (ResultSet)a_result;
        //Map<String,DtpAocStatus> refNoToAocStatus = new Map<String,DtpAocStatus>();
        
        Map<String,DtpAocStatus> aocStatusMap = new Map<String,DtpAocStatus>();
        Set<String> rffNames = new Set<String>();
		Set<String> paperOrderRefNos = new Set<String>();
		Set<String> paperOrderLineItemIds = new Set<String>();
		
        for(DtpAocStatus aocStatusWrapper : aocStatuses) {
            //refNoToAocStatus.put(aocStatusWrapper.Txn_ID,aocStatusWrapper);
            
            aocStatusMap.put(getKeyForOrder(aocStatusWrapper), aocStatusWrapper);
			
			String lineItemId = aocStatusWrapper.Prod_Ln_ID!=null ? aocStatusWrapper.Prod_Ln_ID.toUpperCase(): null;
			if(String.isNotBlank(aocStatusWrapper.Call_ID)) {
				rffNames.add(lineItemId);
			} else {
				paperOrderRefNos.add(aocStatusWrapper.Txn_ID);
				paperOrderLineItemIds.add(lineItemId);
			}
        }
        
        List<SFA2_PFG_Transaction_gne__c> trxs = GNE_SFA2_PFG_REST_DAO.getDtpAocStatus(rffNames, paperOrderRefNos, paperOrderLineItemIds);
        result.trxsToUpdate = new List<SFA2_PFG_Transaction_gne__c>();
        Map<Id,Call_PFG_Detail_gne__c> cDetailsToUpdate = result.cDetailsToUpdate = new Map<Id,Call_PFG_Detail_gne__c>();
        
        for(SFA2_PFG_Transaction_gne__c trx : trxs) {
            DtpAocStatus aocStatusWrapper = aocStatusMap.get(getKeyForOrder(trx));
            
            if(aocStatusWrapper!=null) {
	            aocStatusWrapper.updateTransaction(trx);
	            result.trxsToUpdate.add(trx);
	            
	            if(trx.Call_PFG_Detail_ID_gne__c!=null && !cDetailsToUpdate.containsKey(trx.Call_PFG_Detail_ID_gne__c)) {
	                Call_PFG_Detail_gne__c cDetail = aocStatusWrapper.updateCallDetail(trx.Call_PFG_Detail_ID_gne__c);
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
    
    private String getKeyForOrder(DtpAocStatus aocStatusWrapper) {
    	return (String.isNotBlank(aocStatusWrapper.Txn_ID) ? aocStatusWrapper.Txn_ID.toUpperCase() : null) + '_' + 
    			(String.isNotBlank(aocStatusWrapper.Prod_Ln_ID) ? aocStatusWrapper.Prod_Ln_ID.toUpperCase() : null);
    }
}