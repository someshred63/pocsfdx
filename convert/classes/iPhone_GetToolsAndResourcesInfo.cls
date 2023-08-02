@RestResource(urlMapping='/iPhoneGetToolsAndResourcesInfo/*')
global with sharing class iPhone_GetToolsAndResourcesInfo {


    @HttpPost
    global static iPhone_Commons_gne.RestResponse processRequest() {
        return iPhone_Commons_gne.buildResponse(
                new GetConfigurationResponseBuilder(),
                null
        );
    }

    private class GetConfigurationResponseBuilder implements iPhone_Commons_gne.ResponseBuilder {
        public GetConfigurationResponseBuilder() {

        }

        public iPhone_Commons_gne.RestResponse build(Object arg) {
            List<ToolsAndResourcesInfo> infos = getInfos();
            return new ToolsAndResourcesInfoResponse(infos);
        }

        private List<ToolsAndResourcesInfo> getInfos() {
            List<ToolsAndResourcesInfo> result = new List<ToolsAndResourcesInfo>();
            List<GNE_MCCO_CRM_Link__c> links = GNE_MCCO_CRM_Tools_And_Resources_Ctrl.getLinkList(false);
            for (GNE_MCCO_CRM_Link__c link : links) {
                result.add(new ToolsAndResourcesInfo(link));
            }
            return result;
        }
    }

    @testVisible
    private class ToolsAndResourcesInfoResponse extends iPhone_Commons_gne.RestResponse {
        List<ToolsAndResourcesInfo> infos;
        public ToolsAndResourcesInfoResponse(List<ToolsAndResourcesInfo> infos) {
            this.infos = infos;
        }
    }

    private class ToolsAndResourcesInfo extends iPhone_Commons_gne.RestRecord {
        private Boolean gcr;
        private String name;
        private String url;

        public ToolsAndResourcesInfo(GNE_MCCO_CRM_Link__c link) {
            this.name = link.Link_Name_gne__c;
            this.gcr = link.gConnect_Required_gne__c;
            this.url = link.Link_Url_gne__c;
            this.id = link.Id;
        }
    }
}