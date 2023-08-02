public class GNE_ReltioCreateRequestDefaultImplQueue implements Queueable, Database.AllowsCallouts{
    private String resource;
    private String method;
    private String body;
    private String objId;
    
    public GNE_ReltioCreateRequestDefaultImplQueue(String resource, String method, String body, String objId) {
        this.resource = resource;
        this.method = method;
        this.body = body;
        this.objId = objId;
    }

    public void execute(QueueableContext context) {
        HttpResponse res = GNE_ReltioCalloutHandler.callReltioEndpoint(resource, method, body, '', new Map<string, string>());
        String respBody = res.getBody();
        if([SELECT Count() FROM Affiliation_vod__c WHERE Id = :objId] == 0) return; //if record is deleted
        Affiliation_vod__c forUpdate = new Affiliation_vod__c(Id = objId, MDM_Response_Code_gen__c = String.valueOf(res.getStatusCode()));
        
        
        try {
            GNE_ReltioDCRWrapperConverter.ResponseTopLevel response = (GNE_ReltioDCRWrapperConverter.ResponseTopLevel) JSON.deserialize(respBody, GNE_ReltioDCRWrapperConverter.ResponseTopLevel.class);
            if (res.getStatusCode() == 200) {
                forUpdate.MDM_Status_gne__c = 'AWAITING_REVIEW';
                if(response.dcrResponseDetails != null) {
                    forUpdate.MDM_Reltio_Id_gne__c = response.dcrResponseDetails.entityId != null ? response.dcrResponseDetails.entityId : '';
                    if (response.dcrResponseDetails.errorDetails != null) {
                        forUpdate.MDM_Error_Details_gne__c = '';
                        for (GNE_ReltioDCRWrapperConverter.ResponseErrorDetail error : response.dcrResponseDetails.errorDetails) {
                            forUpdate.MDM_Error_Details_gne__c += '>>>' + error;
                        }
                    }                    
                } else {                    
                    GNE_ReltioDCRWrapperConverter.ResponceErrorsColl responseError = (GNE_ReltioDCRWrapperConverter.ResponceErrorsColl) JSON.deserialize(respBody, GNE_ReltioDCRWrapperConverter.ResponceErrorsColl.class);                
                    if(responseError.errorDetails != null ) {
                        forUpdate.MDM_Error_Details_gne__c = '';
                        for (GNE_ReltioDCRWrapperConverter.ResponseErrorDesc error : responseError.errorDetails) {
                            forUpdate.MDM_Error_Details_gne__c += '>>>' + error;
                        }
                    }                
                }
                
                update forUpdate;
            } else {
                forUpdate.MDM_Status_gne__c = 'SUBMISSION FAILURE';
                if(response.dcrResponseDetails == null) {                    
                    GNE_ReltioDCRWrapperConverter.ResponseError responseError = (GNE_ReltioDCRWrapperConverter.ResponseError) JSON.deserialize(respBody, GNE_ReltioDCRWrapperConverter.ResponseError.class);
                    GNE_ReltioDCRWrapperConverter.ResponseErrorDetail errorDetail = (GNE_ReltioDCRWrapperConverter.ResponseErrorDetail) JSON.deserialize(respBody, GNE_ReltioDCRWrapperConverter.ResponseErrorDetail.class);
                    if(responseError.errorCode != null ) forUpdate.MDM_Error_Details_gne__c = '' + responseError;
                    if(errorDetail.code != null ) forUpdate.MDM_Error_Details_gne__c= '' + errorDetail;
                } else if (response.dcrResponseDetails != null && response.dcrResponseDetails.errorDetails != null) {
                    forUpdate.MDM_Error_Details_gne__c = '';
                    for (GNE_ReltioDCRWrapperConverter.ResponseErrorDetail error : response.dcrResponseDetails.errorDetails) {
                        forUpdate.MDM_Error_Details_gne__c += '\n' + error;
                    }
                }
                update forUpdate;
                GNE_ReltioCalloutErrorNotification.sendAlertEmail(forUpdate);
            }            
            
        } catch (Exception ex) {
            forUpdate.MDM_Error_Details_gne__c = ex.getStackTraceString();
            forUpdate.MDM_Status_gne__c = 'SUBMISSION FAILURE';
            
            update forUpdate;
        }
    }
}