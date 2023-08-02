public without sharing class iPhoneApex_PFG_Util {
	private static Call2_vod__c cRecOld;
	private static Boolean wasCompleted;
	private static Boolean isCompleted;
	private static Boolean isSomethingToChange;
	private static Boolean isCompletedDtpWithNewSignature;
	private static String distMethod;
	@TestVisible private static Map<String,iPhoneApex_2.CallPfgDetail> proposedCallPfgDetailMap;
	private static Map<String, Call_PFG_Detail_gne__c> existingCallPfgDetailMap;
	private static Map<String, Call_PFG_Detail_gne__c> callPfgDetailIToDelete;
	private static Map<String,String> mergedAccountIds;
	
	public static void cacheOldCallRecord(Call2_vod__c cRec, Map<String,String> mergedAccIds) {
		cRecOld = cRec.clone(true,true,true,true);
		mergedAccountIds = mergedAccIds;
	}
	
	private static void init(Call2_vod__c cRec, iPhoneApex_2.CallAttributes callAttributes) {
		GNE_SFA2_PFG_Util.addSessionLabel(iPhoneApex_2.class.getName());
		
		if(proposedCallPfgDetailMap == null) {
			wasCompleted = cRecOld.Completed_gne__c == true;
			isCompleted = cRec.Completed_gne__c == true;
			
			proposedCallPfgDetailMap = new Map<String,iPhoneApex_2.CallPfgDetail>();
			existingCallPfgDetailMap = new Map<String,Call_PFG_Detail_gne__c>();
			callPfgDetailIToDelete = new Map<String,Call_PFG_Detail_gne__c>(); 
			
			if(callAttributes.callPfgDetailList!=null) {
				for(iPhoneApex_2.CallPfgDetail callPfgDetail : callAttributes.callPfgDetailList) {
					proposedCallPfgDetailMap.put(getKeyForCallPfgDetail(callPfgDetail),callPfgDetail);
				}
			}
			
			Set<Id> cDetailIds = new Set<Id>();
			
			if(cRec.Call_PFG_Details__r!=null && !cRec.Call_PFG_Details__r.isEmpty()) {
				for(Call_PFG_Detail_gne__c cDetail : cRec.Call_PFG_Details__r) {
					cDetailIds.add(cDetail.Id);
				}
				
				GNE_SFA2_PFG_Util.cacheCallDetails(cDetailIds);
				
				for(Call_PFG_Detail_gne__c cDetail : cRec.Call_PFG_Details__r) {
					Call_PFG_Detail_gne__c cachedCallDetail = GNE_SFA2_PFG_Util.getCallDetailById(cDetail.Id);
					String key = getKeyForCallPfgDetail(cachedCallDetail);
					existingCallPfgDetailMap.put(key, cachedCallDetail);
					// At the beginning all existing PFGs are candidates to remove
					callPfgDetailIToDelete.put(key,cachedCallDetail);
				}
			}
			
			distMethod = validateProposedCallPfgDetails(callAttributes);
			
			Boolean isPfg = !proposedCallPfgDetailMap.isEmpty() || 
				String.isNotBlank(callAttributes.RequestSignature) || 
				String.isNotBlank(callAttributes.Signature);
			
			isCompletedDtpWithNewSignature = 
		    	distMethod == GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP &&
				wasCompleted && String.isBlank(cRecOld.Signature_vod__c) && String.isNotBlank(callAttributes.Signature);
			
			isSomethingToChange = isPfg && (!wasCompleted  || isCompletedDtpWithNewSignature);
		}
	}
	
	private static String validateProposedCallPfgDetails(iPhoneApex_2.CallAttributes callAttributes) {
		String dMethod = null;
		List<String> errorMsgs = new List<String>();
		Set<String> distMethods = new Set<String>();
		
		for(String key : proposedCallPfgDetailMap.keySet()) {
			iPhoneApex_2.CallPfgDetail proposedCallPfgDetail = proposedCallPfgDetailMap.get(key);
			dMethod = null;
			
			if(String.isNotBlank(proposedCallPfgDetail.Product)) {
				for(String method : GNE_SFA2_PFG_Util.getDistMethodsForProduct((Id)proposedCallPfgDetail.Product)) {
					dMethod = method;
					distMethods.add(dMethod);
					break;
				}
			}
			
			if(String.isBlank(proposedCallPfgDetail.Account)) {
				errorMsgs.add('Account cannot be blank');
			}
			
			if(String.isBlank(proposedCallPfgDetail.Product)) {
				errorMsgs.add('Product cannot be blank');
			}
			
			if(dMethod == GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC && String.isBlank(proposedCallPfgDetail.LotNo)) {
				errorMsgs.add('Lot # cannot be blank for Hand Carry');
			}
			
			if(proposedCallPfgDetail.Quantity==null || proposedCallPfgDetail.Quantity <= 0) {
				errorMsgs.add('Quantity cannot be blank or less than 1');
			}
		}
		
		if(distMethods.size()>1) {
			errorMsgs.add('Only one Type of Distribution Method can be used on Single Interaction (Hand Carry or DTP)');
		}
		
		if(dMethod == GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC && isCompleted && !wasCompleted) {
		   	if(String.isBlank(cRecOld.Signature_vod__c) && String.isBlank(callAttributes.Signature)) {
				errorMsgs.add('Signature cannot be blank for completed Hand Carry Interaction');
		   	}
		   	if(cRecOld.Signature_Date_vod__c == null && callAttributes.SignatureDate == null) {
				errorMsgs.add('Signature Date cannot be blank for completed Hand Carry Interaction');
			}
		}
		
		if(dMethod == GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_DTP && isCompleted && !wasCompleted) {
		   	if(String.isBlank(cRecOld.Request_Signature_gne__c) && String.isBlank(callAttributes.RequestSignature)) {
				errorMsgs.add('Request Signature cannot be blank for completed DTP Interaction');
		   	}
		   	if(cRecOld.Request_Signature_Date_gne__c == null && callAttributes.RequestSignatureDate == null) {
				errorMsgs.add('Request Signature Date cannot be blank for completed DTP Interaction');
			}
		}
		
		if(!errorMsgs.isEmpty()) {
			throw new PfgException(errorMsgs);
		}
		
		return dMethod;
	}
	
	public static void managePfgDetails(Call2_vod__c cRec, iPhoneApex_2.CallAttributes callAttributes) {
		init(cRec, callAttributes);
		
		if(isSomethingToChange) {
			
			List<Call_PFG_Detail_gne__c> cDetailsToUpsert = new List<Call_PFG_Detail_gne__c>();
			
			for(String key : proposedCallPfgDetailMap.keySet()) {
				iPhoneApex_2.CallPfgDetail proposedCallPfgDetail = proposedCallPfgDetailMap.get(key);
			
				Call_PFG_Detail_gne__c cDetail;
				
				if(isCompletedDtpWithNewSignature) {
					if(existingCallPfgDetailMap.containsKey(key)) {
						cDetail = existingCallPfgDetailMap.get(key);
						callPfgDetailIToDelete.remove(key);
						cDetail.DTP_AOC_Status_gne__c = GNE_SFA2_PFG_Util.TRANSACTION_SIGNATURE_COMPLETE;
					}
				} else {
					if(existingCallPfgDetailMap.containsKey(key)) { // update mode
						cDetail = existingCallPfgDetailMap.get(key);
						callPfgDetailIToDelete.remove(key);
					} else { // insert mode
						cDetail = new Call_PFG_Detail_gne__c(
							Call_gne__c = cRec.Id,
							Account_gne__c = iPhoneApex_2.getWinnerAccountId(mergedAccountIds, proposedCallPfgDetail.Account),
							Product_gne__c = proposedCallPfgDetail.Product,
							Lot_No_gne__c = proposedCallPfgDetail.LotNo); 
					}
					
					cDetail.Distribution_Method_gne__c = distMethod;
					cDetail.Quantity_gne__c = proposedCallPfgDetail.Quantity;
					cDetail.Is_Completed_gne__c = isCompleted;
					cDetail.Date_gne__c = proposedCallPfgDetail.cDate!=null 
						? proposedCallPfgDetail.cDate 
						: (cRec.Call_Datetime_vod__c!=null ? cRec.Call_Datetime_vod__c.date() : null); 
				}
			
				if(cDetail!=null) {
					cDetail.iPhone_Request_Id_gne__c = proposedCallPfgDetail.RequestId;
					cDetailsToUpsert.add(cDetail);
				}
			}
			
			if(!isCompletedDtpWithNewSignature && !callPfgDetailIToDelete.isEmpty()) {
				delete callPfgDetailIToDelete.values();
			}
			
			if(!cDetailsToUpsert.isEmpty()) {
				GNE_SFA2_PFG_CPD_Trigger_Helper.setIsOtrRequest(true);
				GNE_SFA2_PFG_CPD_Trigger_Helper.setOtrRequestInfo(
					new GNE_SFA2_PFG_CPD_Trigger_Helper.OtrRequestInfo(cRec));
				upsert cDetailsToUpsert;
				GNE_SFA2_PFG_CPD_Trigger_Helper.setIsOtrRequest(false);
			}	
		}
	}
	
	public static void updateCallSignature(Call2_vod__c cRec, iPhoneApex_2.CallAttributes callAttributes) {
		init(cRec, callAttributes);
		if(isSomethingToChange) {
			if(distMethod == GNE_SFA2_PFG_Util.TRANSACTION_DISCTRIBUTION_METHOD_HC) {
				if(String.isNotBlank(callAttributes.Signature)) {
					cRec.Signature_vod__c = callAttributes.Signature;
					cRec.Signature_Date_vod__c = callAttributes.SignatureDate;
				}
			} else { // DTP
				if(String.isNotBlank(callAttributes.RequestSignature)) {
					cRec.Request_Signature_gne__c = callAttributes.RequestSignature;
					cRec.Request_Signature_Date_gne__c = callAttributes.RequestSignatureDate;
				}
			
				if(wasCompleted && String.isNotBlank(callAttributes.Signature) && String.isBlank(cRecOld.Signature_vod__c)) {
					cRec.Signature_vod__c = callAttributes.Signature;
					cRec.Signature_Date_vod__c = callAttributes.SignatureDate;
				}
			}
			
			if(String.isNotBlank(callAttributes.LicenseNumber)) {
				cRec.License_vod__c = callAttributes.LicenseNumber;
			}
			
			if(String.isNotBlank(callAttributes.Disclaimer)) {
				cRec.Disclaimer_vod__c = callAttributes.Disclaimer;
			}
		}
	}
	
	private static String getKeyForCallPfgDetail(iPhoneApex_2.CallPfgDetail callPfgDetail) {
		String accId = iPhoneApex_2.getWinnerAccountId(mergedAccountIds, callPfgDetail.Account);
		
		return String.join(new List<String>{
			callPfgDetail.Product!=null ? callPfgDetail.Product : '',
            accId!=null ? accId : '',
            callPfgDetail.LotNo!=null ? callPfgDetail.LotNo : ''
		},'::');
	}
	
	private static String getKeyForCallPfgDetail(Call_PFG_Detail_gne__c cDetail) {
		return String.join(new List<String>{
			cDetail.Product_gne__c!=null ? cDetail.Product_gne__c : '',
            cDetail.Account_gne__c!=null ? cDetail.Account_gne__c : '',
            cDetail.Lot_No_gne__c!=null ? cDetail.Lot_No_gne__c : ''
		},'::');
	}
	
	public class PfgException extends Exception {
        public List<String> errorMessages;
        public PfgException(List<String> errorMsgs) {
        	errorMessages = errorMsgs;
        	setMessage('PFG Errors:[' + String.join(errorMsgs,'],[') + ']');
        }
    } 
}