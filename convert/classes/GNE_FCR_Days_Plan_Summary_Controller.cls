public with sharing class GNE_FCR_Days_Plan_Summary_Controller {

    public FCR_Days_Plan_gne__c daysPlan { get; private set; }
    public List<FCR_Action_Plan_gne__c> actionPlans { get; set; }
    public Boolean isReadOnly { get; set; }
    private static final Integer ACTION_PLAN_COUNT = 3;
    public String attachmentIdToDelete { get; set; }

    public GNE_FCR_Days_Plan_Summary_Controller() {
        isReadOnly = false;
        String fcrId = ApexPages.currentPage().getParameters().get('fcrId');
        daysPlan = GNE_FCR_DAO.getFCR(fcrId);
        if (daysPlan.Version_gne__c == 3 || daysPlan.Version_gne__c == 4) {
            actionPlans = new List<FCR_Action_Plan_gne__c>();
        } else {
            actionPlans = [SELECT Id, Description_gne__c FROM FCR_Action_Plan_gne__c WHERE FCR_Days_Plan_gne__c = :fcrId ORDER BY Order_gne__c];
            Integer newActionPlanCount = ACTION_PLAN_COUNT - actionPlans.size();
            for (Integer i = 0; i < newActionPlanCount; i++) {
                actionPlans.add(new FCR_Action_Plan_gne__c(FCR_Days_Plan_gne__c = fcrId, Order_gne__c = i + actionPlans.size()));
            }
        }
    }

    public void savePlanBeforeSendingMail() {
        save();
    }

    public void save() {
        update daysPlan;
        //upsertActionPlans
        List<FCR_Action_Plan_gne__c> actionPlansToUpsert = new List<FCR_Action_Plan_gne__c>();
        Integer myOrder = 0;
        for (FCR_Action_Plan_gne__c ap : actionPlans) {
            if (String.isNotEmpty(ap.Description_gne__c)) {
                ap.Order_gne__c = myOrder++;
                actionPlansToUpsert.add(ap);
            }
        }
        if (!actionPlansToUpsert.isEmpty()) {
            upsert actionPlansToUpsert;
        }
    }

    public PageReference complete() {
        GNE_FCR_Util.setDaysPlanActionAndStatus(daysPlan, GNE_FCR_Util.FCR_COMPLETED_STATUS);
        save();
        Blob pdf = GNE_FCR_Util.generatePDF(Page.GNE_FCR_PDF, daysPlan.Id, true, true);
        Messaging.EmailFileAttachment attachment = GNE_FCR_Util.createAttachment('application/pdf', GNE_FCR_Util.getReportName(daysPlan.Id), pdf);
        GNE_FCR_Util.sendEmail('FCR_Completed_gne', daysPlan, daysPlan.CS_User_gne__c, new List<Messaging.EmailFileAttachment>{
                attachment
        });
        PageReference detailPage = Page.GNE_FCR_Days_Plan;
        detailPage.getParameters().put('fcrId', daysPlan.Id);
        detailPage.setRedirect(true);
        return detailPage;
    }

    public PageReference navigateToAssess() {
        save();
        PageReference assessPage = Page.GNE_FCR_Days_Plan_Assess;
        assessPage.getParameters().put('fcrId', daysPlan.Id);
        assessPage.getParameters().put('activeTab', 'tab2');
        assessPage.setRedirect(true);
        return assessPage;
    }

    public Boolean getIsFE() {
        return GNE_FCR_Util.getIsFE();
    }

    public Boolean getIsFR() {
        return GNE_FCR_Util.getIsFR();
    }

    public Boolean getIsCompleteButtonEnabled() {
        return getIsFR() && daysPlan.Status_gne__c.equals(GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_APPROVED_STATUS));
    }

    public List<Attachment> getAttachments() {
        return [SELECT Id, Name, CreatedDate FROM Attachment WHERE ParentId = :daysPlan.Id];
    }

    public void deleteAttachment() {
        delete new Attachment(Id = attachmentIdToDelete);
    }

    public void refreshAttachments() {
    }
}