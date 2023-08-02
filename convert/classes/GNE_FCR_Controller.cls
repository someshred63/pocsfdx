public with sharing class GNE_FCR_Controller {

    transient List<DaysPlanWrapper> fcrList = null;
    private static final Integer MAX_OPEN_FCR_COUNT = Integer.valueOf(Utilities.getGlobalVariable('GNE_FCR_Open_Days_Plan_Limit'));

    public GNE_FCR_Controller() {
        fcrList = new List<DaysPlanWrapper>();
        for (FCR_Days_Plan_gne__c daysPlan : GNE_FCR_DAO.getUserFCRs(UserInfo.getUserId())) {
            Boolean isActionRequired = false;
            if (daysPlan.CS_User_gne__c == UserInfo.getUserId() && (daysPlan.Status_gne__c == GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_NEW_STATUS) || daysPlan.Status_gne__c == GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_AWAITING_UPDATE_STATUS))) {
                isActionRequired = true;
            }
            if (daysPlan.Version_gne__c == 7 && daysPlan.CS_User_gne__c == UserInfo.getUserId() && daysPlan.Status_gne__c == GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_COMPLETED_STATUS)) {
                isActionRequired = true;
            }
            if (daysPlan.FR_User_gne__c == UserInfo.getUserId() &&
                    (daysPlan.Status_gne__c == GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_UNDER_REVIEW_STATUS) ||
                     daysPlan.Status_gne__c == GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_APPROVED_STATUS) ||
                     daysPlan.Status_gne__c == GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_ACKNOWLEDGED_STATUS) ||
                     (daysPlan.Status_gne__c == GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_COMPLETED_STATUS) && daysPlan.Version_gne__c != 7))) {
                isActionRequired = true;
            }
            fcrList.add(new DaysPlanWrapper(daysPlan, isActionRequired));
        }
    }

    public void setLastVisitedPage() {
        GNE_FCR_Navigation_Controller.setLastVisitedPage();
    }

    public String getUserName() {
        return [SELECT Name FROM User WHERE Id = :UserInfo.getUserId()].Name;
    }

    public Boolean getIsFE() {
        return GNE_FCR_Util.getIsFE();
    }

    public Boolean getIsFR() {
        return GNE_FCR_Util.getIsFR();
    }

    public List<DaysPlanWrapper> getFcrList() {
        return fcrList;
    }

    public PageReference createNewFcr() {
        //An FE may have up to MAX_OPEN_FCR_COUNT active (not archived) FCRs at any time
        Integer fcrCount = [SELECT COUNT() FROM FCR_Days_Plan_gne__c WHERE CS_User_gne__c = :UserInfo.getUserId() AND Status_gne__c != :GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_ARCHIVED_STATUS) AND Version_gne__c IN :GNE_FCR_Util.getSupportedFCRVersions(UserInfo.getUserId())];
        if (fcrCount >= MAX_OPEN_FCR_COUNT) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, String.format(System.Label.GNE_FCR_Open_Days_Plan_Limit_Message, new String[]{
                    String.valueOf(MAX_OPEN_FCR_COUNT)
            })));
            return null;
        }
        return Page.GNE_FCR_Days_Plan;
        return null;
    }

    public class DaysPlanWrapper {
        public FCR_Days_Plan_gne__c daysPlan { get; set; }
        public Boolean isActionRequired { get; set; }

        public DaysPlanWrapper(FCR_Days_Plan_gne__c daysPlan, Boolean isActionRequired) {
            this.daysPlan = daysPlan;
            this.isActionRequired = isActionRequired;
        }
    }
}