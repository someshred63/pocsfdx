public with sharing class GNE_SFA2_Team2ProductMapping_Ctrl {

    public List<SelectOption> availableProducts { get; set; }
    public String product { get; set; }
    public Map<String, Product_vod__c> productsMap;
    public String salesforceCode { get; set; }
    public String salesforceSubTeamCode { get; set; }
    public String salesforceCodeForSearch { get; set; }
    public String salesforceSubTeamCodeForSearch { get; set; }
    public ApexPages.StandardSetController standardController {get; set;}
    public List<Team_Mapping_gne__c> mappings { get {
            if(standardController != null) {
                return (List<Team_Mapping_gne__c>) standardController.getRecords();
            }
            else {
                return null;
            }
        }}
    public Set<Id> allQueriedMappingsIds = new Set<Id>();
    public String sortField { get; set; }
    public String sortOrder { get; set; }
    public String PRODUCT_TYPE = 'Detail';

    public GNE_SFA2_Team2ProductMapping_Ctrl (ApexPages.StandardController standardController) {
        this.availableProducts = getAvailableProducts();
        this.standardController = new ApexPages.StandardSetController(getTeamMappings());
    }

    @TestVisible
    private List<SelectOption> getAvailableProducts() {
        List<Product_vod__c> availableProducts = [SELECT Id, Name FROM Product_vod__c WHERE Region_Code_gne__c = 2 AND active__c = true AND Product_Type_vod__c =: PRODUCT_TYPE ORDER BY Name];
        this.productsMap = new Map<String, Product_vod__c>();
        List<SelectOption> productsNames = new List<SelectOption>();
        for(Product_vod__c product : availableProducts) {
            productsNames.add(new SelectOption(product.Name, product.Name));
            this.productsMap.put(product.Name, product);
        }
        return productsNames;
    }

    private List<Team_Mapping_gne__c> getTeamMappings() {
        String query = 'SELECT Id, Name, Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c, Product_gne__r.Name FROM Team_Mapping_gne__c WHERE Region_Code_gne__c = 2';
        List<Team_Mapping_gne__c> queriedMappings = Database.query(query);
        fillMappingsIds(queriedMappings);
        return queriedMappings;
    }

    private List<Team_Mapping_gne__c> queryExistingSet() {
        String query = 'SELECT Id, Name, Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c, Product_gne__r.Name FROM Team_Mapping_gne__c WHERE Region_Code_gne__c = 2 and Id IN : allQueriedMappingsIds' ;
        if(this.sortField != null) {
            query += ' ORDER BY '+this.sortField + ' ' + this.sortOrder;
        }

        return Database.query(query);
    }

    public PageReference sort() {
        if(allQueriedMappingsIds.isEmpty()) {
            this.standardController = new ApexPages.StandardSetController(getTeamMappings());
        }
        else {
            this.standardController = new ApexPages.StandardSetController(queryExistingSet());
        }

        return null;
    }

    public void saveTeamMapping() {
        if(isValid()) {
            try {
                Product_vod__c chosenProduct = this.productsMap.get(product);
                Team_Mapping_gne__c mapping = new Team_Mapping_gne__c(Salesforce_Code_gne__c = salesforceCode, Salesforce_SubTeam_Code_gne__c = salesforceSubTeamCode,
                Product_gne__c = chosenProduct.Id, Product_gne__r = chosenProduct);
                insert mapping;

                String successMessage = 'Mapping for product: {0}, Salesforce Code: {1}, Sub Team Code: {2} saved successfully.';
                createPageInfoMessage(String.format(successMessage, new List<String> {product, salesforceCode, salesforceSubTeamCode}));
            } 
            catch(Exception ex) {
                System.debug(ex.getMessage());
            }
        }
    }

    public Boolean checkIfMappingExists(String salesforceCode, String salesforceSubTeamCode, String productName) {
        List<Team_Mapping_gne__c> existingMapping = [SELECT Id FROM Team_Mapping_gne__c WHERE Salesforce_Code_gne__c = :salesforceCode AND
                                                Salesforce_SubTeam_Code_gne__c = :salesforceSubTeamCode AND Product_gne__r.Name = :productName];
        if(existingMapping.isEmpty()) {
            return false;
        }
        return true;
    }

    private void fillMappingsIds(List<Team_Mapping_gne__c> queriedMappings) {
        this.allQueriedMappingsIds.clear();
        for(Team_Mapping_gne__c mapping : queriedMappings) {
            this.allQueriedMappingsIds.add(mapping.Id);
        }
    }

    public Boolean isValid() {
        Boolean isValid = true;
        if(String.isEmpty(this.product)) {
            isValid = false;
            createPageErrorMessage('Choose product');
        }
        if(this.availableProducts == null) {
            isValid = false;
            createPageErrorMessage('Problem with available products');
        }
        if(String.isEmpty(salesforceCode)) {
            isValid = false;
            createPageErrorMessage('Enter Salesforce Code');
        }
        if(String.isEmpty(salesforceSubTeamCode)) {
            isValid = false;
            createPageErrorMessage('Enter Salesforce Sub Team Code');
        }
        if(isValid) {
            if(checkIfMappingExists(this.salesforceCode, this.salesforceSubTeamCode, this.product)) {
                createPageErrorMessage('Mapping exists');
                return false;
            }
        }
        return isValid;
    }

    public PageReference search() {
        Boolean addedToQuery = false;
        String query = 'SELECT Id, Name, Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c, Product_gne__r.Name FROM Team_Mapping_gne__c WHERE ';
        if(String.isNotEmpty(this.salesforceCodeForSearch)) {
            addedToQuery = true;
            query += 'Salesforce_Code_gne__c = \'' + this.salesforceCodeForSearch + '\'';
        }
        if(String.isNotEmpty(this.salesforceSubTeamCodeForSearch)) {
            if(addedToQuery)
                query += ' AND Salesforce_SubTeam_Code_gne__c = \'' + this.salesforceSubTeamCodeForSearch + '\'';
            else {
                addedToQuery = true;
                query += 'Salesforce_SubTeam_Code_gne__c = \'' + this.salesforceSubTeamCodeForSearch + '\'';
            }
        } 
        if(!addedToQuery) {
            createPageErrorMessage('Enter search keywords');
            this.standardController = new ApexPages.StandardSetController(getTeamMappings());
        } else {
            List<Team_Mapping_gne__c> queriedMappings = Database.query(query);
            fillMappingsIds(queriedMappings);
            this.standardController = new ApexPages.StandardSetController(queriedMappings);
        }
        return null;
    }
 
    private void createPageErrorMessage(String message) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));
    }

    private void createPageInfoMessage(String message) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, message));
    }

    public Boolean hasNext  
    {  
        get  
        {  
            return this.standardController.getHasNext();  
        }  
        set;  
    }  

    public Boolean hasPrevious  
    {  
        get  
        {  
            return this.standardController.getHasPrevious();  
        }  
        set;  
    }  
    public Integer pageNumber  
    {  
        get  
        {  
            return this.standardController.getPageNumber();  
        }  
        set;  
    }  

    public void previous()  
    {  
        this.standardController.previous();  
    } 

    public void next()  
    {  
        this.standardController.next();  
    } 
}