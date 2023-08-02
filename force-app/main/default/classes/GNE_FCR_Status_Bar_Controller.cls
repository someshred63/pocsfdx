public class GNE_FCR_Status_Bar_Controller {

    public String fcrDaysPlanId { get; set; }
    public FCR_Days_Plan_gne__c fcr;
    public Boolean isAssessDone { get; set; }

    public PageReference navigateToAssess() {
        PageReference assessPage = Page.GNE_FCR_Days_Plan_Assess;
        assessPage.getParameters().put('fcrId', fcrDaysPlanId);
        assessPage.setRedirect(true);
        return assessPage;
    }

    public PageReference navigateToDaysPlan() {
        PageReference daysPlanPage = Page.GNE_FCR_Days_Plan;
        daysPlanPage.getParameters().put('fcrId', fcrDaysPlanId);
        daysPlanPage.setRedirect(true);
        return daysPlanPage;
    }

    public PageReference navigateToSummary() {
        PageReference summaryPage = Page.GNE_FCR_Days_Plan_Summary;
        summaryPage.getParameters().put('fcrId', fcrDaysPlanId);
        summaryPage.setRedirect(true);
        return summaryPage;
    }

    public Boolean getIsAssessButtonDisabled() {
        Boolean isDisabled = true;
        if (getFCR() != null) {
            if (GNE_FCR_Util.getIsFE()) {
                if (getFCR().Status_gne__c == GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_COMPLETED_STATUS) || getFCR().Status_gne__c == GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_ARCHIVED_STATUS)) {
                    isDisabled = false;
                }
            }
            if (GNE_FCR_Util.getIsFR()) {
                if (getFCR().Status_gne__c == GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_APPROVED_STATUS) ||
                        getFCR().Status_gne__c == GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_COMPLETED_STATUS) ||
                        getFCR().Status_gne__c == GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_ARCHIVED_STATUS)) {
                    isDisabled = false;
                }
            }
        }
        return isDisabled;
    }

    public Boolean getIsSubmitButtonDisabled() {
        Boolean isDisabled = true;
        if (getFCR() != null) {
            if (GNE_FCR_Util.getIsFE()) {
                if (getFCR().Status_gne__c == GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_COMPLETED_STATUS) || getFCR().Status_gne__c == GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_ARCHIVED_STATUS)) {
                    isDisabled = false;
                }
            }
            if (GNE_FCR_Util.getIsFR()) {
                if ((isAssessDone && getFCR().Status_gne__c == GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_APPROVED_STATUS)) ||
                        (getFCR().Status_gne__c == GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_COMPLETED_STATUS) || getFCR().Status_gne__c == GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_ARCHIVED_STATUS))) {
                    isDisabled = false;
                }
            }
        }
        return isDisabled;
    }

    public String getDayPlanButtonCssStyle() {
        if (ApexPages.currentPage().getUrl().toLowerCase().contains(Page.GNE_FCR_CompatibilityView.getUrl().toLowerCase())) {
            return 'tab-link-visited';
        }
        String cssStyle = 'tab-link-active';
        if (getFCR() != null) {
            if (GNE_FCR_Util.getIsFE()) {
                if (getFCR().Status_gne__c != GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_NEW_STATUS) && getFCR().Status_gne__c != GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_AWAITING_UPDATE_STATUS)) {
                    cssStyle = 'tab-link-visited';
                }
            }

            if (GNE_FCR_Util.getIsFR()) {
                if (getFCR().Status_gne__c == GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_APPROVED_STATUS) || getFCR().Status_gne__c == GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_COMPLETED_STATUS) ||
                        getFCR().Status_gne__c == GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_ARCHIVED_STATUS) || getFCR().Status_gne__c == GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_ACKNOWLEDGED_STATUS)) {
                    cssStyle = 'tab-link-visited';
                }
            }
        }
        return cssStyle;
    }

    public String getAssessButtonCssStyle() {
        String cssStyle = '';
        if (getFCR() != null) {
            if (GNE_FCR_Util.getIsFE()) {
                if (getFCR().Status_gne__c == GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_COMPLETED_STATUS) || getFCR().Status_gne__c == GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_ARCHIVED_STATUS) || getFCR().Status_gne__c == GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_ACKNOWLEDGED_STATUS)) {
                    cssStyle = 'tab-link-visited';
                }
            }
            if (GNE_FCR_Util.getIsFR()) {
                if (!isAssessDone && getFCR().Status_gne__c == GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_APPROVED_STATUS)) {
                    cssStyle = 'tab-link-active';
                }if ((isAssessDone && getFCR().Status_gne__c == GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_APPROVED_STATUS)) ||
                        getFCR().Status_gne__c == GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_COMPLETED_STATUS) ||
                        getFCR().Status_gne__c == GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_ARCHIVED_STATUS) || getFCR().Status_gne__c == GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_ACKNOWLEDGED_STATUS)) {
                    cssStyle = 'tab-link-visited';
                }
            }
        }
        return cssStyle;
    }

    public String getSubmitButtonCssStyle() {
        String cssStyle = '';
        if (getFCR() != null) {
            if (GNE_FCR_Util.getIsFE()) {
                if (getFCR().Status_gne__c == GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_COMPLETED_STATUS) || getFCR().Status_gne__c == GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_ARCHIVED_STATUS) || getFCR().Status_gne__c == GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_ACKNOWLEDGED_STATUS)) {
                    cssStyle = 'tab-link-visited';
                }
            }
            if (GNE_FCR_Util.getIsFR()) {
                if (isAssessDone && getFCR().Status_gne__c == GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_APPROVED_STATUS)) {
                    cssStyle = 'tab-link-active';
                } else if (getFCR().Status_gne__c == GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_COMPLETED_STATUS) || getFCR().Status_gne__c == GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_ARCHIVED_STATUS) || getFCR().Status_gne__c == GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_ACKNOWLEDGED_STATUS)) {
                    cssStyle = 'tab-link-visited';
                }
            }
        }
        return cssStyle;
    }

    public FCR_Days_Plan_gne__c getFCR() {
        if (String.isNotEmpty(fcrDaysPlanId)) {
            return GNE_FCR_DAO.getFCR(fcrDaysPlanId);
        }
        return null;
    }
}