@RestResource(urlMapping='/S2S/ClassificationRequests/*')
global with sharing class EDM_Classification_Request_Rest extends EDM_Classification_Request_RestEngine {

    @HttpGet
    global static EDM_Classification_Request_RestUtil.ClassificationRequestResults getClassificationRequests() {
        return (EDM_Classification_Request_RestUtil.ClassificationRequestResults)GNE_SFA2_S2S_ServiceEngine.executeRestGetMethod(
                EDM_Classification_Request_RestUtil.EXTERNAL_SYSTEM_NAME, EDM_Classification_Request_RestUtil.Feature.ClassifReqGet.name(),
                new EDM_Classification_Request_Rest(), EDM_Classification_Request_RestUtil.ClassificationRequestResults.class);
    }

    @HttpPost
    global static EDM_Classification_Request_RestUtil.ClassificationRequestResults processClassificationRequestData(EDM_Classification_Request_RestUtil.ClassificationRequestWrapper classificationRequestData) {
        EDM_Classification_Request_RestUtil.Feature currentFeature = classificationRequestData.getLocalId() == null ?
                EDM_Classification_Request_RestUtil.Feature.ClassifReqCreate
                 : EDM_Classification_Request_RestUtil.Feature.ClassifReqReview;
        return (EDM_Classification_Request_RestUtil.ClassificationRequestResults)GNE_SFA2_S2S_ServiceEngine.executeRestPostMethod(
                        EDM_Classification_Request_RestUtil.EXTERNAL_SYSTEM_NAME, 
                        currentFeature.name(),
                        new EDM_Classification_Request_Rest(), 
                        classificationRequestData,
                        EDM_Classification_Request_RestUtil.ClassificationRequestResults.class
                    );
    }

    public virtual override System.Type getSelfClass() {
        return EDM_Classification_Request_Rest.class;
    }
}