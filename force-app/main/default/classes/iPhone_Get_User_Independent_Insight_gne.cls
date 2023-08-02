@RestResource(urlMapping='/iPhoneGetUserIndependentInsight/*')
global with sharing class iPhone_Get_User_Independent_Insight_gne {
    
    @HttpPost
    global static iPhone_Commons_gne.RestResponse processRequest(String lastSyncDate, String unixId) {       
        return iPhone_Commons_gne.buildResponse(
                new GetUserIndependentInsightResponseBuilder(),
                new iPhone_Commons_gne.DefaultDeltaArgs(lastSyncDate, unixId)
        );        
    }

    class GetUserIndependentInsightResponseBuilder extends iPhone_Commons_gne.DeltaRecordsResponseBuilder {

        protected override List<SObject> selectSObjects(iPhone_Commons_gne.DeltaArgs args) {
            User user = iPhone_DAO.getUserByExternalId(args.unixId);
            return iPhone_DAO.getUserIndependentInsight();
        }

        protected override iPhone_Commons_gne.DeltaRecord getAsRecord(SObject sObj) {
            return new IndependentInsight((Independent_Insight_vod__c)sObj);
        }

    }

    global virtual class IndependentInsight extends iPhone_Commons_gne.DeltaRecord {
        public String na;   // Independent_Insight_vod__c.Name
        public List<String> ac;   // Independent_Insight_vod__c.Account_gne__c
        public String cd;   // Independent_Insight_vod__c.CreatedDate
        public String cb;   //Independent_Insight_vod__c.CreatedBy.Name
        public String cbid;   //Independent_Insight_vod__c.CreatedById
        public String tr;   //Independent_Insight_vod__c.Territory_gne__c
        public String is;   // Independent_Insight_vod__c.Insight_Status_gne__c
        public String ti;   // Independent_Insight_vod__c.Title_gne__c
        public String tar;   // Independent_Insight_vod__c.Therapeutic_Area_gne__c
        public List<String> pai;   // Independent_Insight_vod__c.Product_and_Indication_gne__c
        public String ide;   // Independent_Insight_vod__c.Insight_Description_gne__c

        public IndependentInsight() {}

        public IndependentInsight(Independent_Insight_vod__c independentInsight) {
            id  = independentInsight.Id;
            na  = independentInsight.Name;
            ac = String.isNotBlank(independentInsight.Account_gne__c) ? independentInsight.Account_gne__c.split(';') : new List<String>();
            cd  = iPhone_StringUtil.getString(independentInsight.CreatedDate);
            cb  = iPhone_StringUtil.getString(independentInsight.CreatedBy.Name);
            cbid = independentInsight.CreatedById;
            tr = independentInsight.Territory_gne__c;
            is = independentInsight.Insight_Status_gne__c;
            ti  = independentInsight.Title_gne__c;
            tar = independentInsight.Therapeutic_Area_gne__c;
            pai = String.isNotBlank(independentInsight.Product_and_Indication_gne__c) ? independentInsight.Product_and_Indication_gne__c.split(';') : new List<String>();
            ide  = independentInsight.Insight_Description_gne__c;
        }
    }
    
}