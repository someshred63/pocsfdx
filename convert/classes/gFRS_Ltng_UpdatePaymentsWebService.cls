/**
* @author GFRS Dev Team
* @date 24/11/2021
* @description gFRS_Ltng_UpdatePaymentsWebService class - webservice class dedicated for updating Payments by ESB team.
*/

global class gFRS_Ltng_UpdatePaymentsWebService {
    
    global static String firstError = '';
    
/**
* @author GFRS Dev Team
* @date 24/11/2021
* @description gFRS_UpdatePaymentResult class - wrapper class for update results.
*/
    global class gFRS_UpdatePaymentResult {
        webservice String resultStatus;
        webservice String message;
        webservice String firstErrorResult;
        
        public gFRS_UpdatePaymentResult(String resultStatus, String message, String firstErrorResult) {
            this.resultStatus     = resultStatus;
            this.message          = message;
            this.firstErrorResult = firstErrorResult;
        }
    }
    
    /**
* @author GFRS Dev Team
* @date 24/11/2021
* @description updatePaymentFromESB method - method dedicated for updating Payments by ESB team.
*/
    webservice static gFRS_UpdatePaymentResult updatePaymentFromESB(gFRSPaymentWrapper[] listOfPaymentWrappersToUpdate){    
        
        String failedPaymentUpdates                              = '';
        String updateStatus                                      = '';
        List<gFRS_Ltng_Payment_History__c> listOfPaymentsToUpdate     = new List<gFRS_Ltng_Payment_History__c>();

        Map<String, gFRSPaymentWrapper> sapRequestIdToWrapperMap = new Map<String, gFRSPaymentWrapper>();
        Map<Id, String> paymentIdToSapRequestIdMap               = new Map<Id, String>();
        Set<String> setOfPaymentSapRequestId                     = new Set<String>();
        
        for(gFRSPaymentWrapper item : listOfPaymentWrappersToUpdate){
            setOfPaymentSapRequestId.add(item.sapRequestId);
            sapRequestIdToWrapperMap.put(item.sapRequestId, item);
        }
        
        if(setOfPaymentSapRequestId.size() <= 0){
            return new gFRS_UpdatePaymentResult(null, 'Could not find matching Payments', null);
        }
        
        List<gFRS_Ltng_Payment_History__c> paymentsFromSFDC = [SELECT Id, Status__c, SAP_Doc_ID__c, 
                                                               gFRS_Application__r.LOA_Signed__c, SAP_Request_ID__c 
                                                               FROM gFRS_Ltng_Payment_History__c 
                                                               WHERE SAP_Request_ID__c IN :setOfPaymentSapRequestId ];                                
        
        try{
            if(paymentsFromSFDC.size() < 1){
                return new gFRS_UpdatePaymentResult('Success', '', 'Could not find any Payments to update.');
            }
            
            if(paymentsFromSFDC.size() > 0){
                for(gFRS_Ltng_Payment_History__c item : paymentsFromSFDC){
                    
                    paymentIdToSapRequestIdMap.put(item.Id, item.SAP_Request_ID__c);  
                    
                    gFRSPaymentWrapper tmpWrapper = sapRequestIdToWrapperMap.get(item.SAP_Request_ID__c);
                    
                    item.SAP_Payment_Document_ID__c = tmpWrapper.sapPaymentDocumentId;
                    item.SAP_Payment_Sent_Date__c   = (tmpWrapper.sapPaymentSentDate == null || tmpWrapper.sapPaymentSentDate == '') ? null : Date.valueOf(tmpWrapper.sapPaymentSentDate);
                    item.Check_Number__c            = tmpWrapper.checkNumber;
                    item.Encashment_Date__c         = (tmpWrapper.encashmentDateFromESB == null || tmpWrapper.encashmentDateFromESB == '') ? null : Date.valueOf(tmpWrapper.encashmentDateFromESB);
                    item.Payment_Method__c          = tmpWrapper.paymentMethod;
                    item.Payment_Block__c           = tmpWrapper.paymentBlock;
                    
                    listOfPaymentsToUpdate.add(item);
                }   
            }
            
            if(paymentsFromSFDC.size()>0){
                Database.SaveResult[] result = Database.update(listOfPaymentsToUpdate, false);
                failedPaymentUpdates = manageResult(result, paymentIdToSapRequestIdMap);
            }
            
            if(failedPaymentUpdates == ''){
                updateStatus = 'Success';
            }else{
                updateStatus = 'Errors occured';
            }
            return new gFRS_UpdatePaymentResult(updateStatus, failedPaymentUpdates, firstError);
        }catch(Exception ex){
            System.debug('ERROR OCCURED DURING ESB UPDATE OF PAYMENT' + ex.getMessage());
            return new gFRS_UpdatePaymentResult('Fail', null, ex.getMessage());
        }
    }
    
    private static String manageResult(Database.SaveResult[] result, Map<Id, String> paymentIdToSapRequestIdMap){
        
        String failedPayments = '';
        
        for (Database.SaveResult saveResult : result) {
            if (saveResult.isSuccess()) {
                paymentIdToSapRequestIdMap.remove(saveResult.getId());
            }else{
                for(Database.Error err : saveResult.getErrors()) {
                    firstError = err.getStatusCode() + ' :: ' + err.getFields() + ' ::' + err.getMessage();
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Account fields that affected this error: ' + err.getFields());
                } 
            }
        }
        
        for(String failedSapRequestId : paymentIdToSapRequestIdMap.values()){
            failedPayments += failedSapRequestId + '; ';
        }
        
        return failedPayments;
    }
    
    
    /**
* @author GFRS Dev Team
* @date 24/11/2021
* @description gFRSPaymentWrapper class - wrapper class for data from ESB.
*/
    global class gFRSPaymentWrapper{
        webservice String sapRequestId; 
        webservice String sapPaymentDocumentId; 
        webservice String sapPaymentSentDate; 
        webservice String checkNumber; 
        webservice String encashmentDateFromESB; 
        webservice String paymentMethod; 
        webservice String paymentBlock; 
        //webservice String paymentStatus;
        
        public gFRSPaymentWrapper(String sapRequestId, String sapPaymentDocumentId, String sapPaymentSentDate, String checkNumber, String encashmentDateFromESB, String paymentMethod, String paymentBlock){
            this.sapRequestId          = sapRequestId; 
            this.sapPaymentDocumentId  = sapPaymentDocumentId; 
            this.sapPaymentSentDate    = sapPaymentSentDate; 
            this.checkNumber           = checkNumber; 
            this.encashmentDateFromESB = encashmentDateFromESB; 
            this.paymentMethod         = paymentMethod; 
            this.paymentBlock          = paymentBlock; 
        }
    }
    
}