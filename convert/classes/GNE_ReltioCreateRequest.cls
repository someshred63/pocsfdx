public class GNE_ReltioCreateRequest {
    public static Map<String, String> resourceResolverType;
    public static Map<String, String> createRequestType;
    public enum OperationType {
        INS, UPD, DEL
    }

    static {
        resourceResolverType = new Map<String, String>{
                'Change_Request_gne__c' => 'GNE_ReltioCreateRequest.DCRResourceResolver',
                'Affiliation_vod__c' => 'GNE_ReltioCreateRequest.AffiliationResourceResolver'
        };
    }

    public static void sendRequest(SObject sourceObj, OperationType opType) {
        String body = GNE_ReltioDCRWrapperConverter.createRequestBody(sourceObj);
        System.debug(body);
        String objTypeName = sourceObj.getSObjectType().getDescribe().getName();
        String resourceResolverTypeName = resourceResolverType.get(objTypeName);
        IResourceResolver resourceResolver = (IResourceResolver) Type.forName(resourceResolverTypeName).newInstance();

        if(objTypeName == 'Change_Request_gne__c')
            GNE_ReltioCreateRequestDCR.sendToReltio(resourceResolver.getResource(sourceObj, opType), 'POST', body, sourceObj.Id);
        else if(objTypeName == 'Affiliation_vod__c')
            GNE_ReltioCreateRequestDefaultImpl.sendToReltio(resourceResolver.getResource(sourceObj, opType), 'POST', body, sourceObj.Id);
    }

    interface IResourceResolver {
        String getResource(SObject sourceObj, OperationType opType);
    }

    public class DCRResourceResolver implements IResourceResolver {
        public String getResource(SObject sourceObj, OperationType opType) {
            Change_Request_gne__c changeReq = (Change_Request_gne__c) sourceObj;
            return GNE_ReltioDCRWrapperConverter.id2RecordTypeDevName.get(changeReq.RecordTypeId);
        }
    }

    public class AffiliationResourceResolver implements IResourceResolver {
        public String getResource(SObject sourceObj, OperationType opType) {
            return opType == OperationType.INS ? 'Create_Affiliation' : (opType == OperationType.DEL ? 'Delete_Affiliation' : '');
        }
    }
}