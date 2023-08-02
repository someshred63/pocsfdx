public class GNE_ReltioCreateRequestDCR {
    private static Map<String, List<String>> statusMapping = new Map<String, List<String>> {
        'APPLIED'  => new List<String>{'Ready to Load', 'Approved'},
        'REJECTED' => new List<String>{'Closed','Invalid'}
    };

    public static void sendToReltio(String resource, String method, String body, String objId) {
        if(System.isBatch() || System.isFuture() || System.isScheduled() || System.isQueueable()) {
            sendToReltioSync(resource, method, body, objId);
        } else {
            sendToReltioAsync(resource, method, body, objId);
        }
    }
    
    public static void updateStatusFromReltio(String body) {
        HttpResponse res = GNE_ReltioCalloutHandler.callReltioEndpoint('Resolution_Status' , 'POST', body, '', new Map<String, String>());
        if(res.getStatusCode() == 200) {
            String respBody = res.getBody();
            List<Change_Request_gne__c> collection = new List<Change_Request_gne__c> ();
            GNE_ReltioDCRWrapperConverter.StatusesResponse response = (GNE_ReltioDCRWrapperConverter.StatusesResponse) JSON.deserialize(respBody, GNE_ReltioDCRWrapperConverter.StatusesResponse.class);
            for(GNE_ReltioDCRWrapperConverter.SingleStatusWrapper ssw : response.dcrResponseDetails)  {
                if(ssw.result != null) {
                    Change_Request_gne__c dcrForUpdate = new Change_Request_gne__c(MDM_DCR_Id_gne__c = ssw.name, MDM_DCR_Status_gne__c = ssw.result);
                    String mdmStatus = ssw.result.toUpperCase();
                    dcrForUpdate.Status_gne__c = statusMapping.get(mdmStatus) != null ? statusMapping.get(mdmStatus)[0] : dcrForUpdate.Status_gne__c;
                    dcrForUpdate.Approval_State__c = statusMapping.get(mdmStatus) != null ? statusMapping.get(mdmStatus)[1] : dcrForUpdate.Approval_State__c;
                    collection.add(dcrForUpdate);
                }                
            }
            Database.upsert(collection, Change_Request_gne__c.MDM_DCR_Id_gne__c, false);      
        }
    }

    public static void sendToReltioSync(String resource, String method, String body, String objId) {
        HttpResponse res = GNE_ReltioCalloutHandler.callReltioEndpoint(resource, method, body, '', new Map<String, String>());
        String respBody = res.getBody();
        Change_Request_gne__c dcrForUpdate = new Change_Request_gne__c(Id = objId, MDM_DCR_Response_Code_gen__c = String.valueOf(res.getStatusCode()));
        try {
            GNE_ReltioDCRWrapperConverter.ResponseTopLevel response = (GNE_ReltioDCRWrapperConverter.ResponseTopLevel) JSON.deserialize(respBody, GNE_ReltioDCRWrapperConverter.ResponseTopLevel.class);
            if (res.getStatusCode() == 200) {                
                dcrForUpdate.MDM_DCR_Status_gne__c = 'AWAITING_REVIEW';
                dcrForUpdate.Status_gne__c = 'Submitted';
                dcrForUpdate.MDM_DCR_Id_gne__c = response.dcrResponseDetails.entityId;
                if (response.dcrResponseDetails.errorDetails != null) {
                    dcrForUpdate.MDM_DCR_Error_Details_gne__c = '';
                    for (GNE_ReltioDCRWrapperConverter.ResponseErrorDetail error : response.dcrResponseDetails.errorDetails) {
                        if(String.isNotBlank(error.description) || error.description=='null') dcrForUpdate.MDM_DCR_Error_Details_gne__c += '\n-------\n' + error;
                    }
                }
                update dcrForUpdate; 
            } else {
                dcrForUpdate.MDM_DCR_Status_gne__c = 'SUBMISSION FAILURE';
                if(response.dcrResponseDetails == null) {
                    GNE_ReltioDCRWrapperConverter.ResponseError responseError = (GNE_ReltioDCRWrapperConverter.ResponseError) JSON.deserialize(respBody, GNE_ReltioDCRWrapperConverter.ResponseError.class);
                    GNE_ReltioDCRWrapperConverter.ResponseErrorDetail errorDetail = (GNE_ReltioDCRWrapperConverter.ResponseErrorDetail) JSON.deserialize(respBody, GNE_ReltioDCRWrapperConverter.ResponseErrorDetail.class);
                    if(responseError.errorCode != null ) dcrForUpdate.MDM_DCR_Error_Details_gne__c = '' + responseError;
                    if(errorDetail.code != null ) dcrForUpdate.MDM_DCR_Error_Details_gne__c = '' + errorDetail;
                } else if (response.dcrResponseDetails != null && response.dcrResponseDetails.errorDetails != null) {
                    dcrForUpdate.MDM_DCR_Error_Details_gne__c = '';
                    for (GNE_ReltioDCRWrapperConverter.ResponseErrorDetail error : response.dcrResponseDetails.errorDetails) {
                        dcrForUpdate.MDM_DCR_Error_Details_gne__c += '\n' + error;
                    }
                }
                update dcrForUpdate; 
                GNE_ReltioCalloutErrorNotification.sendAlertEmail(dcrForUpdate);
            }
        } catch (Exception ex) {
            dcrForUpdate.MDM_DCR_Error_Details_gne__c = ex.getStackTraceString();
            dcrForUpdate.MDM_DCR_Status_gne__c = 'SUBMISSION FAILURE';
			System.debug(ex);
            update dcrForUpdate;
            GNE_ReltioCalloutErrorNotification.sendAlertEmail(dcrForUpdate);
        }        
    }
    
    @Future(Callout=true)
    public static void sendToReltioAsync(String resource, String method, String body, String objId) {
        sendToReltioSync(resource, method, body, objId);
    }
}