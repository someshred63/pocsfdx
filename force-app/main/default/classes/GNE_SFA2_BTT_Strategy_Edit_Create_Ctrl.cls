public without sharing class GNE_SFA2_BTT_Strategy_Edit_Create_Ctrl {

    public SFA2_PREP_Testing_Strategy_gne__c Strategy { get; set; }
    public List<SFA2_PREP_MBO_gne__c> MBOs { get; private set; }
    public String retURL { get; private set; }
    public Boolean isEditable { get; private set; }
    public static final String PREP_SALESFORCE_CODE ='PREP';
    public static final String PREP_SALESFORCE_SUBTEAM_CODE ='BPREP';

    public GNE_SFA2_BTT_Strategy_Edit_Create_Ctrl() {
        Id id = ApexPages.currentPage().getParameters().get('id');
        if (String.isNotBlank(id))
            Strategy = [SELECT Id, 
                        Name, 
                        Owner.Name, 
                        Active_for_Account_gne__c, 
                        Active_for_Call_gne__c,
                        Order_gne__c, 
                        External_Id_calc_gne__c, Product_gne__c, Region_Code_gne__c FROM SFA2_PREP_Testing_Strategy_gne__c WHERE Id = :id];
        else
            Strategy = new SFA2_PREP_Testing_Strategy_gne__c();

        setMode();

        if (isEditable == false) {
            if (Strategy.Id != null)
                fetchMBOs(Strategy.id);
            else
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Strategy record is null.'));
        }

        retURL = ApexPages.currentPage().getParameters().get('retURL');
    }

    private void setMode() {
        if (!'1'.equals(ApexPages.currentPage().getParameters().get('readonly')))
            isEditable = true;
        else
            isEditable = false;
    }

    public PageReference createNewMBO() {
        return new PageReference('/apex/GNE_SFA2_BTT_MBO_Edit_Create?retURL=/apex/GNE_SFA2_BTT_Admin_Panel');
    }

    private void fetchMBOs(Id id) {
        if (MBOs == null)
            MBOs = new List<SFA2_PREP_MBO_gne__c>();
        MBOs = [SELECT 
                    Id, 
                    Name,
                    Active_gne__c, 
                    Active_for_Account_gne__c, 
                    Active_for_Call_gne__c, 
                    Short_Description_gne__c,
                    Testing_Strategy_ref_gne__r.Id,
                    Testing_Strategy_ref_gne__r.Name
                FROM SFA2_PREP_MBO_gne__c
                WHERE Testing_Strategy_ref_gne__c = :id];
    }

    public PageReference goBack() {
        String route;

        if (String.isNotBlank(retURL))
            route = retURL;
        else
            route = '/';

        return new PageReference(route);
    }

    public PageReference enterEditMode() {
        PageReference ref = new PageReference('/apex/GNE_SFA2_BTT_Strategy_Edit_Create?id=' + Strategy.Id + '&retURL=' + retURL);
        ref.setRedirect(true);
        return  ref;
    }

    public PageReference submit() {
        Savepoint sp = Database.setSavepoint();
        try {
            if (String.isBlank(String.valueOf(Strategy.Region_Code_gne__c))) {
                Strategy.Region_Code_gne__c = 1;
            }

            upsertStrategy();

            String route = '/apex/GNE_SFA2_BTT_Strategy_Edit_Create?id=' + Strategy.Id + '&retURL=' + retURL + '&readonly=1';
            PageReference ref = new PageReference(route);
            ref.setRedirect(true);

            return  ref;
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
            System.debug('ERROR! > ' + e.getMessage());
            Database.rollback(sp);
            return null;
        }
    }

    private Id createCorrespondingProduct() {
        QueueSObject queue = [SELECT 
                                Queue.Id, 
                                Queue.Name, 
                                Queue.Type 
                            FROM
                                QueueSObject 
                            WHERE 
                                Queue.Type ='Queue' AND 
                                Queue.Name = 'GNE-SFA-PREP-QUEUE' 
                            LIMIT 1];

        Product_vod__c product = new Product_vod__c(
            Name = Strategy.Name,
            Product_Type_vod__c = 'Detail',
            Detail_Product_Subtype_Code_gne__c = 'Approved Product Indications',
            Active__c = true
        );

        if (queue != null && queue.Queue != null)
            product.OwnerId = queue.Queue.Id;

        insert product;

        return product.Id;
    }

    private void upsertStrategy() {
        Boolean isCreate = String.isBlank(Strategy.Id) ? true : false;
        if (isCreate) {
            Strategy.Product_gne__c = createCorrespondingProduct();
        }
        this.manageTeamMapping(Strategy.Product_gne__c, Strategy.Active_for_Call_gne__c);
        upsert Strategy;
    }

    public PageReference quickSubmit() {
        Savepoint sp = Database.setSavepoint();
        try {
            upsertStrategy();

            PageReference ref = new PageReference('/apex/GNE_SFA2_BTT_Strategy_Edit_Create?retURL=/apex/GNE_SFA2_BTT_Admin_Panel');
            ref.setRedirect(true);

            return  ref;
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, e.getMessage()));
            System.debug('ERROR! > ' + e.getMessage());
            Database.rollback(sp);
            return null;
        }
    }

    private void manageTeamMapping(String productId, Boolean visibleInInteractionPage) {
        if(String.isNotBlank(productId)) {
            List<Team_Mapping_gne__c> teamMappingList = this.getTeamMapping(productId);
            if(visibleInInteractionPage) {
                if(teamMappingList.isEmpty()) {
                    this.addTeamMapping(productId);
                }
            } else {
                if(!teamMappingList.isEmpty()) {
                    delete teamMappingList;
                }
            }
        }
    }

    private List<Team_Mapping_gne__c> getTeamMapping(String productId) {
        return [Select Id, Product_gne__c, Salesforce_Code_gne__c, Salesforce_SubTeam_Code_gne__c
                From Team_Mapping_gne__c
                Where Salesforce_Code_gne__c=: PREP_SALESFORCE_CODE
                And Salesforce_SubTeam_Code_gne__c=: PREP_SALESFORCE_SUBTEAM_CODE
                And Product_gne__c =: productId Limit 1];
    }

    private void addTeamMapping(String productId) {
        if(String.isNotBlank(productId)) {
            Team_Mapping_gne__c tm = new Team_Mapping_gne__c();
            tm.Product_gne__c = productId;
            tm.Salesforce_Code_gne__c = PREP_SALESFORCE_CODE;
            tm.Salesforce_SubTeam_Code_gne__c = PREP_SALESFORCE_SUBTEAM_CODE;
            insert tm;
        }
    }
}