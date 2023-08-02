public with sharing class GNE_SFA2_Independent_Insight_Ctrl extends GNE_SFA2_DynamicVFLoader {
    public List<Product_vod__c> productAndIndication {get; set;}
    public Independent_Insight_vod__c currentInsight {get; set;}
    public List<Account> accounts {get; set;}

    public GNE_SFA2_Independent_Insight_Ctrl(ApexPages.StandardController controller){
        super(controller,'/apex/GNE_SFA2_Independent_Insight_Layout');
    }

    public override PageReference init() {
        super.init();
        currentInsight = (Independent_Insight_vod__c)myObject;
        productAndIndication = new List<Product_vod__c>();
        accounts = new List<Account>();
        productAndIndication = fetchProductAndIndication();
        accounts = fetchRelatedAccounts();

        return null;
    }

    private List<Account> fetchRelatedAccounts() {
        if ((String.IsNotBlank(currentInsight.Account_gne__c))) {
            List<String> accountStrings = currentInsight.Account_gne__c.split(';');
            return [
                    SELECT Id, Name, IsPersonAccount, HCP_Stakeholder_Type_gne__c, Tier_Level_gne__c, Account_Type_gne__c, Territory_vod__c
                    FROM Account
                    WHERE Id IN :accountStrings
            ];
        }
        return null;
    }

    private List<Product_vod__c> fetchProductAndIndication() {
        if(String.IsNotBlank(currentInsight.Product_and_Indication_gne__c)) {
            List<String> productStrings = currentInsight.Product_and_Indication_gne__c.split(';');
            return [
                    SELECT Id, Name
                    FROM Product_vod__c
                    WHERE Id IN :productStrings
            ];
        }
        return null;
    }

    public PageReference edit() {
        pagereference pageref = new pagereference('/apex/GNE_SFA2_Independent_Insight_Edit_Create?id='+myObject.Id);
        pageref.setredirect(true);
        return pageref;
    }

    public PageReference deleteRecord() {
        Independent_Insight_vod__c independentInsightToDelete = new Independent_Insight_vod__c (Id=myObject.Id);
        try{
            delete independentInsightToDelete;
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Independent Insight can not be deleted: ' + e));
        }
        PageReference pageref = new PageReference('/apex/GNE_SFA2_My_Insights');
        pageref.setredirect(true);
        return pageref;
    }

}