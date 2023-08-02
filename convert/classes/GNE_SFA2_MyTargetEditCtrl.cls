public without sharing class GNE_SFA2_MyTargetEditCtrl extends GNE_SFA2_DynamicVFLoader{
    public Id selectedHCOId {get;set;}
    public String selectedRating {get;set;}
    
    private String province;
    private Id territoryId;
    private Account targetAccount;    
    private Map<Id, Targets_and_Tiers_can_gne__c> cachedTargetsAndTiers = new Map<Id, Targets_and_Tiers_can_gne__c>();
    private List<TargetsAndTiers> tats;
    
    private static final String ACCOUNT_TYPE_HOSPITAL = 'Hospital';
    
    public GNE_SFA2_MyTargetEditCtrl(ApexPages.StandardController controller) {  
        super(controller,'/apex/GNE_SFA2_MyTargetEdit');

        targetAccount = (Account) controller.getRecord();
        initData();
    }
    
    public PageReference saveMyTargets() {
        List<ApexPages.message> errors = collectErrors();
        if(!errors.isEmpty()){
            for(ApexPages.message m: errors){
                ApexPages.addMessage(m);
            }
            return null;
        }
        List<Targets_and_Tiers_can_gne__c> toUpdate = new List<Targets_and_Tiers_can_gne__c>();
        for(TargetsAndTiers tat : tats){
            tat.accessRating = selectedRating;
            tat.hcoAccountId = selectedHCOId;
            Targets_and_Tiers_can_gne__c sObj = cachedTargetsAndTiers.get(tat.targetAndTier.Id);
            if(isObjectChanged(sObj, tat)){
                Targets_and_Tiers_can_gne__c newSObj = setNewValues(sObj, tat);
                toUpdate.add(newSObj);
            }
        }
        try{
            update toUpdate;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Record saved.'));
        } catch (Exception ex) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, ex.getMessage()));
        }
        
        return null;
    }
    
    private List<ApexPages.message> collectErrors() {
        List<ApexPages.message> errors = new List<ApexPages.message>();
        if(selectedRating == null){
            errors.add(new ApexPages.message(ApexPages.severity.ERROR, 'Access Rating is a required field'));
        }

        return errors;
    }
    
    public PageReference returnToMyTargetPage() {
        PageReference pr = new PageReference('/apex/GNE_SFA2_MyTargets');
        pr.setRedirect(true);
        return pr;
    }
    
    public PageReference saveAndReturn() {
        List<ApexPages.message> errors = collectErrors();
        if(!errors.isEmpty()){
            for(ApexPages.message m: errors){
                ApexPages.addMessage(m);
            }
            return null;
        }
        saveMyTargets();
        
        PageReference pr = new PageReference('/apex/GNE_SFA2_MyTargets');
        pr.setRedirect(true);
        return pr;
    }
    
    private Targets_and_Tiers_can_gne__c setNewValues(Targets_and_Tiers_can_gne__c sObj, TargetsAndTiers obj){
        sObj.Access_Rating__c = obj.accessRating;
        sObj.HCO_Account__c = obj.hcoAccountId;
        sObj.My_Target_gne__c = obj.myTarget;
        sObj.Target_gne__c = obj.myTarget;
        return sObj;
    }
    
    private Boolean isObjectChanged(Targets_and_Tiers_can_gne__c sObj, TargetsAndTiers obj) {
        return sObj.Access_Rating__c != obj.accessRating || sObj.HCO_Account__c != obj.hcoAccountId || sObj.My_Target_gne__c != obj.myTarget;
    }
    
    private void initData() {        
        territoryId = ApexPages.currentPage().getParameters().get('territoryId');
        if(territoryId == null ){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Territory Id has not been defined'));
            return;
        }
        
        assingProvince();
    }
    
    public List<TargetsAndTiers> getTats() {
        tats = new List<TargetsAndTiers>();
        Territory2[] terrs = [SELECT Name FROM Territory2 WHERE Id =:territoryId];
        if(terrs.isEmpty()){
            return tats;
        }
        Set <Id> accountsWithInterractionInCurrentYear = new Set<Id>();
        for(Call2_vod__c cv :[
            SELECT Account_vod__c 
            FROM Call2_vod__c
            WHERE Account_vod__c = :targetAccount.Id 
            	AND Date_of_Interaction_gne__c = THIS_YEAR
        ]){
            accountsWithInterractionInCurrentYear.add(cv.Account_vod__c);            
        }
        List<Id> productIdsStr = getUserMySetupProductsIds(UserInfo.getUserId());
        for(Targets_and_Tiers_can_gne__c tat:[            
            SELECT Id,Account_can_gne__c, Territory_gne__c,My_Target_gne__c, Product_Catalog_gne__c, Product_Catalog_gne__r.Name,
                Segment_gne__c,Target_gne__c,Tier_can_gne__c, Access_Rating__c, HCO_Account__c, HCO_Account__r.Name
           	FROM Targets_and_Tiers_can_gne__c
           	WHERE Account_can_gne__c = :targetAccount.Id 
            	AND Territory_gne__c = :terrs[0].Name
            	AND Product_Catalog_gne__c IN : productIdsStr
            	AND (
                    (Target_gne__c = null AND My_Target_gne__c != 'Non-Target'  AND My_Target_gne__c != null) 
                     OR Target_gne__c != null 
                     OR (Target_gne__c = null AND My_Target_gne__c = null AND Account_can_gne__c IN :accountsWithInterractionInCurrentYear)
                )
        ]){
            tats.add(new TargetsAndTiers(tat));
            cachedTargetsAndTiers.put(tat.Id, tat);
        }
        return tats;
    }
    
    private static List<Id> getUserMySetupProductsIds(Id userId){
        List<Id> productIds = new List<Id>();
        Integer userRegionCode = GNE_SFA2_Util.isCanadaUser() ? 2 : 1;
        for (Product_vod__c userProduct : [
            SELECT Id 
            FROM Product_vod__c 
            WHERE Product_Type_vod__c = 'Detail' 
            AND (Detail_Product_Subtype_Code_gne__c != 'Molecule' AND Detail_Product_Subtype_Code_gne__c != 'TheraDisease')                 
            AND Region_Code_gne__c = :userRegionCode 
            AND Id IN (SELECT Product_vod__c 
                       FROM My_Setup_Products_vod__c WHERE OwnerId = :userId)
        ]){
        	productIds.add(userProduct.Id);
        }

		return productIds;
	}
    
    
    private void assingProvince() {
        Address_vod__c[] adds = [SELECT Province_can_gne__c FROM Address_vod__c WHERE Account_vod__c =:targetAccount.Id AND Primary_vod__c = true];
        if(!adds.isEmpty()){
            province = adds[0].Province_can_gne__c;
        }
    }
    
    public List<SelectOption> getHCPAccounts() { 
        TargetsAndTiers tat = tats.isEmpty() ? null : tats.get(0);
        List<SelectOption> options = new List<SelectOption>();
        if(tat != null && tat.hcoAccountName != null && tat.hcoAccountId != null){
            options.add(new SelectOption(tat.hcoAccountId , tat.hcoAccountName ));
        } else {
            options.add(new SelectOption('', '-none-'));
        }
        if(province==null) return options;
        for(Account acc :[
            SELECT Id, Name
            FROM Account
            WHERE Account_Type_gne__c = :ACCOUNT_TYPE_HOSPITAL
            	AND Prim_IMS_Id_can__c != null
            	AND Id IN (SELECT Account_vod__c FROM Address_vod__c WHERE Primary_vod__c = true AND Province_can_gne__c=:province AND Account_vod__r.Account_Type_gne__c = :ACCOUNT_TYPE_HOSPITAL AND Region_Code_gne__c =2.0)
            ORDER BY Name 
        ]){
            options.add(new SelectOption(acc.Id, acc.Name));
        }
        return options;
    }
    
    public List<SelectOption> getAccessRatings() { 
        TargetsAndTiers tat = tats.isEmpty() ? null : tats.get(0);
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Targets_and_Tiers_can_gne__c.Access_Rating__c.getDescribe();
        if(tat != null && tat.accessRating != null ){
            options.add(new SelectOption(tat.accessRating , tat.accessRating ));
        } else {
            options.add(new SelectOption('', '-none-'));
        }

        for(Schema.PicklistEntry ple : fieldResult.getPickListValues() ){
            options.add(new SelectOption(ple.getLabel(), ple.getValue()));
        }
        return options;        
    }
    
    public class TargetsAndTiers {
        public String tier { get; set;}
        public String myTarget { get; set;}
        public String productIndication { get; set;}
        public String segment { get; set;}
        public String target { get; set;}
        public String accessRating { get; set;}
        public String hcoAccountName { get; set;}
        public List<SelectOption> myTargets { get; set;}
        private String hcoAccountId; 
        
        public Targets_and_Tiers_can_gne__c targetAndTier { get; set;}
        public TargetsAndTiers(Targets_and_Tiers_can_gne__c tnt){
            targetAndTier = tnt;
            productIndication = tnt.Product_Catalog_gne__r.Name;
            tier = tnt.Tier_can_gne__c;
            myTarget = tnt.My_Target_gne__c;
            segment = tnt.Segment_gne__c;
            target = tnt.Target_gne__c;     
            hcoAccountName = tnt.HCO_Account__r.Name;
            hcoAccountId = tnt.HCO_Account__c;
            accessRating = tnt.Access_Rating__c;
            myTargets = setMyTargets();
        }
        
        private List<SelectOption> setMyTargets() {
            List<SelectOption> options = new List<SelectOption>();
        	Schema.DescribeFieldResult fieldResult = Targets_and_Tiers_can_gne__c.My_Target_gne__c.getDescribe();

            if(myTarget != null){
                options.add(new SelectOption(myTarget, myTarget));
                options.add(new SelectOption('', '-none-'));
            } else {
                options.add(new SelectOption('', '-none-'));
            }
            for(Schema.PicklistEntry ple : fieldResult.getPickListValues() ){
                if(ple.getValue() == myTarget) continue;
                options.add(new SelectOption(ple.getLabel(), ple.getValue()));
            }
            return options;
        }
    }
}