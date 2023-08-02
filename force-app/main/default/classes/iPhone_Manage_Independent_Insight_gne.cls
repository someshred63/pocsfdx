@RestResource(urlMapping='/iPhoneManageIndependentInsights/*')
global with sharing class iPhone_Manage_Independent_Insight_gne {

    @HttpPost
    global static iPhone_Commons_gne.RestResponse processRequest(String unixId, IndInsWrapper record) {
        return iPhone_Commons_gne.executeAlterData(
                new ManageIndependentInsightExecutor(),
                new ManageIndependentInsightArg(unixId, record)
        );
    }

    class ManageIndependentInsightArg implements iPhone_Commons_gne.BaseArgs {
        public String unixId;
        public IndInsWrapper recordWrapper;

        public ManageIndependentInsightArg(String unixId, IndInsWrapper recordWrapper) {
            this.unixId = unixId;
            this.recordWrapper = recordWrapper;

        }

        public String getIPhoneRequestId(){
            return (recordWrapper!=null) ? recordWrapper.rid : null;
        }
    }

    public without sharing class ManageIndependentInsightExecutor implements iPhone_Commons_gne.Runnable {

        public Object run(Object obj) {
            ManageIndependentInsightArg arg = (ManageIndependentInsightArg)obj;
            List<Independent_Insight_vod__c> recstoDelete = new List<Independent_Insight_vod__c>();
            List<Independent_Insight_vod__c> recstoUpsert = new List<Independent_Insight_vod__c>();

            if(arg.recordWrapper!=null) {
                Map<String,Id> requestIdToSfdcIdMap = getSfdcIdForRequestId(arg.recordWrapper);
                Id ridId = arg.recordWrapper.rid!=null ? requestIdToSfdcIdMap.get(arg.recordWrapper.rid.toUpperCase()) : null;
                arg.recordWrapper.manageRecord(ridId, recstoDelete, recstoUpsert);
            }

            if(!recstoDelete.isEmpty()) {
                delete recstoDelete;
            }

            if(!recstoUpsert.isEmpty()) {
                upsert recstoUpsert;
            }

            String result = fillRequestSfdcId(recstoUpsert, false);
            return result;
        }

        private Map<String,Id> getSfdcIdForRequestId(IndInsWrapper recordWrapper) {
            Map<String,Id> requestIdToSfdcIdMap = new Map<String,Id>();
            if(recordWrapper != null && String.isNotBlank(recordWrapper.rid)) {
                fillRequestIdSfdcIdMap(
                        requestIdToSfdcIdMap,
                        iPhone_DAO.getRecordsWithRequestIds(new Set<String> {recordWrapper.rid.toUpperCase()}, Independent_Insight_vod__c.sObjectType.getDescribe().getName()),
                        true
                );
            }
            return requestIdToSfdcIdMap;
        }

        private void fillRequestIdSfdcIdMap(Map<String,Id> requestIdToSfdcIdMap, List<SObject> recs, Boolean upperCaseMode) {
            if(!recs.isEmpty() && recs.size() == 1) {
                String reqId = (String)recs.get(0).get('iPhone_Request_Id_gne__c');
                reqId = upperCaseMode ? reqId.toUpperCase() : reqId;
                requestIdToSfdcIdMap.put(reqId, recs.get(0).Id);
            }
        }

        private String fillRequestSfdcId(List<SObject> recs, Boolean upperCaseMode) {
            String sfdcId = '';
            if(!recs.isEmpty() && recs.size() == 1) {
                sfdcId = recs.get(0).Id;
            }
            return sfdcId;
        }

    }

    global class IndInsWrapper extends iPhone_Get_User_Independent_Insight_gne.IndependentInsight {
        private String rid;

        private void manageRecord(Id sfdcId, List<SObject> recstoDelete, List<SObject> recstoUpsert) {

            Independent_Insight_vod__c rec = ax == 'd'
                    ? new Independent_Insight_vod__c()
                    : new Independent_Insight_vod__c(
                            Title_gne__c = this.ti,
                            Therapeutic_Area_gne__c = this.tar,
                            Product_and_Indication_gne__c = this.pai != null ? convertListToString(this.pai) : '',
                            Insight_Description_gne__c = this.ide,
                            Account_gne__c = this.ac != null ? convertListToString(this.ac) : '',
                            Insight_Status_gne__c = this.is,
                            Territory_gne__c = this.tr,
                            iPhone_Request_Id_gne__c = this.rid);

            if(String.isNotBlank(this.id)) {
                rec.Id = this.Id;
            } else if(sfdcId!=null) {
                rec.Id = sfdcId;
            }

            if(this.ax == 'd') {
                if(String.isNotBlank(rec.Id)) {
                    recstoDelete.add(rec);
                }
            } else {
                recstoUpsert.add(rec);
            }

        }

        private String convertListToString(List<String> listToConvert) {
            String listAsString = '';
            for(String stc : listToConvert) {
                listAsString += stc+';';
            }
            return listAsString;
        }

    }

}