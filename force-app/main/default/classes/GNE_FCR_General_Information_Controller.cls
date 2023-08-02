public without sharing class GNE_FCR_General_Information_Controller {

    public String fcrDaysPlanId { get; set; }
    private FCR_Days_Plan_gne__c daysPlan;
    private PDFDaysPlanWrapper PdfDaysPlan;

    public GNE_FCR_General_Information_Controller() {
    }

    public FCR_DaysPlan_Job_Competency_gne__c getJobCompetency() {
        try {
            List<FCR_DaysPlan_Job_Competency_gne__c> planComments = GNE_FCR_DAO.getDaysPlanJobCompetency(fcrDaysPlanId);
            if (planComments.size() > 0) {
                return planComments[0];
            } else {
                return new FCR_DaysPlan_Job_Competency_gne__c();
            }
        } catch (Exception e) {
            System.debug('An error occured while ' + e.getMessage());
            return null;
        }
    }

    public DaysPlanWrapper getDaysPlanInfo() {
        FCR_Days_Plan_gne__c previousPlan = null;
        if (String.isNotEmpty(getDaysPlan().Previous_Action_Plan_gne__c)) {
            previousPlan = GNE_FCR_DAO.getPreviousDaysPlan(getDaysPlan().Previous_Action_Plan_gne__c);
        }
        return new DaysPlanWrapper(getDaysPlan(), previousPlan);
    }

    public PDFDaysPlanWrapper getPdfDaysPlanInfo() {
        if (PdfDaysPlan == null) {
            FCR_Days_Plan_gne__c previousPlan = null;
            if (String.isNotEmpty(getDaysPlan().Previous_Action_Plan_gne__c)) {
                previousPlan = GNE_FCR_DAO.getPreviousDaysPlan(getDaysPlan().Previous_Action_Plan_gne__c);
            }
            PdfDaysPlan = new PDFDaysPlanWrapper(getDaysPlan(), previousPlan);
        }
        return PdfDaysPlan;
    }

    public Boolean getIsCompleted() {
        return getDaysPlan().Status_gne__c == GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_COMPLETED_STATUS) || getDaysPlan().Status_gne__c == GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_ARCHIVED_STATUS)
                || (getDaysPlan().Version_gne__c == 1 && getDaysPlan().Status_gne__c == 'Form Complete') || getDaysPlan().Status_gne__c == GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_ACKNOWLEDGED_STATUS);
    }

    public Boolean getIsAlreadyApproved() {
        return getDaysPlan().Status_gne__c == GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_APPROVED_STATUS) || getIsCompleted();
    }

    public Boolean getIsUserSupportedBySLDx() {
        return GNE_FCR_Util.isSupportedBySLDx(getDaysPlan().CS_User_gne__c);
    }

    public Boolean getIsArchived() {
        return getDaysPlan().Status_gne__c == GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_ARCHIVED_STATUS);
    }

    public Boolean getIsFE() {
        return GNE_FCR_Util.getIsFE();
    }

    public Boolean getIsFR() {
        return GNE_FCR_Util.getIsFR();
    }

    public Boolean getIsFcrEditableForFR() {
        if (getIsFR()) {
            if (getDaysPlan().Status_gne__c.equals(GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_UNDER_REVIEW_STATUS))) {
                return true;
            }
        }
        return false;
    }

    private FCR_Days_Plan_gne__c getDaysPlan() {
        if (daysPlan == null) {
            daysPlan = [
                    SELECT Version_gne__c, Date_Field_Visit_gne__c, Field_Objectives_gne__c, Franchise_Obj_fcr__c, Previous_Action_Plan_gne__c, Previous_Action_Plan_CS_Comments__c, CheckInComment_gne__c, Development_gne__c,
                            Job_Competency_gne__c, Job_Competency_Comments_gne__c, GPM_Objective_gne__c, GPM_Objective_Comments_gne__c, Status_gne__c, Other_Accounts_gne__c, Territory_gne__c, DM_Comments_gne__c,
                            Territory_Name_gne__c, Summary_Comments_gne__c, Performance_gne__c, CS_User_gne__c, CS_User_gne__r.Name, Franchise_Objective_gne__r.Name, Franchise_Objective_gne__r.Franchise_gne__r.Name, (SELECT Account_gne__c, Account_gne__r.Name, AP_Account_gne__r.Name, AP_Account_gne__r.Address_gne__c, Territory_gne__c, Notes_gne__c FROM GNE_FCR_Junction__r), (SELECT Objective_gne__c, Objective_Date_gne__c, Id, SystemModstamp FROM FCR_Days_Objectives__r), (SELECT Description_gne__c, Name, Order_gne__c, Status_gne__c, Title_gne__c FROM GNE_FCR_Action_Item__r ORDER BY Order_gne__c), (
                            SELECT Id, Name, Division_Month_gne__c, Division_Quarter_gne__c, Division_Year_gne__c, Franchise_Month_gne__c, Franchise_Quarter_gne__c,
                                    Franchise_Year_gne__c, Product_gne__c, Product_gne__r.Name, Region_Month_gne__c, Region_Quarter_gne__c, Region_Year_gne__c, Territory_Month_gne__c,
                                    Territory_Quarter_gne__c, Territory_Year_gne__c, Type_gne__c, Brand_gne__c
                            FROM FCR_PTP_gne__r
                    )
                    FROM FCR_Days_Plan_gne__c
                    WHERE Id = :fcrDaysPlanId
            ];
        }
        return daysPlan;
    }

    /*
    / Wrapper Class
    */
    public class DaysPlanWrapper {
        public FCR_Days_Plan_gne__c daysPlan { get; private set; }
        public FCR_Days_Plan_gne__c previousPlan { get; private set; }

        public DaysPlanWrapper(FCR_Days_Plan_gne__c daysPlan, FCR_Days_Plan_gne__c previousDaysPlan) {
            this.daysPlan = daysPlan;
            this.previousPlan = previousDaysPlan;
        }
    }

    public class PDFDaysPlanWrapper {
        public FCRDaysPlanWrapper daysPlan { get; private set; }
        public FCR_Days_Plan_gne__c previousPlan { get; private set; }

        public PDFDaysPlanWrapper(FCR_Days_Plan_gne__c daysPlan, FCR_Days_Plan_gne__c previousDaysPlan) {
            this.daysPlan = new FCRDaysPlanWrapper(daysPlan);
            this.previousPlan = previousDaysPlan;
        }
    }

    public class FCRDaysPlanWrapper {
        public String Territory_Name { get; private set; }
        public Datetime Date_Field_Visit { get; private set; }
        public List<FCR_Account> Accounts { get; private set; }
        public String Franchise_Obj { get; private set; }
        public String GPM_Objective { get; private set; }
        public List<FCR_Days_Objective_gne__c> FCR_Days_Objectives { get; private set; }
        public String Previous_Action_Plan_CS_Comments { get; private set; }
        public String DM_Comments { get; private set; }
        public String Job_Competency { get; private set; }
        public String Job_Competency_Comments { get; private set; }
        public String Summary_Comments { get; private set; }
        public String GPM_Objective_Comments { get; private set; }
        public List<FCR_Action_Plan_gne__c> GNE_FCR_Action_Item { get; private set; }
        public String Performance { get; private set; }
        public List<FCR_PTP_gne__c> FCR_PTP { get; private set; }
        public Integer version { get; private set; }
        public String CheckInComment { get; private set; }
        public String Development { get; private set; }

        public FCRDaysPlanWrapper(FCR_Days_Plan_gne__c daysPlan) {
            if (daysPlan.Version_gne__c == 1) {
                setFieldsForVer1(daysPlan);
            } else if (daysPlan.Version_gne__c == 2 || daysPlan.Version_gne__c == 3 || daysPlan.Version_gne__c == 4 || daysPlan.Version_gne__c == 5 || daysPlan.Version_gne__c == 6) {
                setFieldsForVer2and3and4and5and6(daysPlan);
            } else if (daysPlan.Version_gne__c == 7) {
                setFieldsForVer2and3and4and5and6(daysPlan);
                setFieldsForVer7(daysPlan);
            }
        }

        private void setFieldsForVer1(FCR_Days_Plan_gne__c daysPlan) {
            this.version = 1;
            this.Territory_Name = daysPlan.GNE_FCR_Junction__r.size() > 0 ? [SELECT Name FROM Territory2 WHERE Id = :daysPlan.GNE_FCR_Junction__r[0].Territory_gne__c].Name : '';
            this.Date_Field_Visit = daysPlan.Date_Field_Visit_gne__c;
            this.Franchise_Obj = daysPlan.Franchise_Objective_gne__r.Franchise_gne__r.Name;
            this.GPM_Objective = daysPlan.GPM_Objective_gne__c;
            this.FCR_Days_Objectives = new List<FCR_Days_Objective_gne__c>{
                    new FCR_Days_Objective_gne__c(
                            Objective_gne__c = daysPlan.Field_Objectives_gne__c,
                            Objective_Date_gne__c = null
                    )
            };
            this.Previous_Action_Plan_CS_Comments = daysPlan.Previous_Action_Plan_CS_Comments__c;
            this.DM_Comments = daysPlan.DM_Comments_gne__c;
            this.Job_Competency = daysPlan.Job_Competency_gne__c;
            this.Summary_Comments = daysPlan.Summary_Comments_gne__c;
            this.GPM_Objective_Comments = daysPlan.GPM_Objective_Comments_gne__c;
            this.Performance = daysPlan.Performance_gne__c;

            this.Accounts = new List<FCR_Account>();
            for (FCR_Days_Plan_Account_gne__c account : daysPlan.GNE_FCR_Junction__r) {
                this.Accounts.add(new FCR_Account(account));
            }
            this.GNE_FCR_Action_Item = new List<FCR_Action_Plan_gne__c>();
            for (FCR_Action_Plan_gne__c action : daysPlan.GNE_FCR_Action_Item__r) {
                this.GNE_FCR_Action_Item.add(new FCR_Action_Plan_gne__c(Description_gne__c = action.Description_gne__c));
            }
            this.FCR_PTP = new List<FCR_PTP_gne__c>();
        }

        private void setFieldsForVer2and3and4and5and6(FCR_Days_Plan_gne__c daysPlan) {
            this.version = Integer.valueOf(daysPlan.Version_gne__c);
            this.Territory_Name = daysPlan.Territory_Name_gne__c;
            this.Date_Field_Visit = daysPlan.Date_Field_Visit_gne__c;
            this.Franchise_Obj = daysPlan.Franchise_Obj_fcr__c;
            this.GPM_Objective = daysPlan.GPM_Objective_gne__c;
            this.Previous_Action_Plan_CS_Comments = daysPlan.Previous_Action_Plan_CS_Comments__c;
            this.DM_Comments = daysPlan.DM_Comments_gne__c;
            this.Job_Competency = daysPlan.Job_Competency_gne__c;
            this.Job_Competency_Comments = daysPlan.Job_Competency_Comments_gne__c;
            this.Summary_Comments = daysPlan.Summary_Comments_gne__c;
            this.GPM_Objective_Comments = daysPlan.GPM_Objective_Comments_gne__c;
            this.Performance = daysPlan.Performance_gne__c;

            this.Accounts = new List<FCR_Account>();
            for (FCR_Days_Plan_Account_gne__c account : daysPlan.GNE_FCR_Junction__r) {
                this.Accounts.add(new FCR_Account(account));
            }
            this.FCR_Days_Objectives = new List<FCR_Days_Objective_gne__c>();
            for (FCR_Days_Objective_gne__c daysObj : daysPlan.FCR_Days_Objectives__r) {
                this.FCR_Days_Objectives.add(
                        new FCR_Days_Objective_gne__c(
                                Objective_gne__c = daysObj.Objective_gne__c,
                                Objective_Date_gne__c = daysObj.Objective_Date_gne__c
                        )
                );
            }
            this.GNE_FCR_Action_Item = new List<FCR_Action_Plan_gne__c>();
            if (this.version != 3 && this.version != 4 && this.version != 5) {
                for (FCR_Action_Plan_gne__c action : daysPlan.GNE_FCR_Action_Item__r) {
                    this.GNE_FCR_Action_Item.add(new FCR_Action_Plan_gne__c(Description_gne__c = action.Description_gne__c));
                }
            }
            this.FCR_PTP = new List<FCR_PTP_gne__c>();
            for (FCR_PTP_gne__c ptp : daysPlan.FCR_PTP_gne__r) {
                this.FCR_PTP.add(
                        new FCR_PTP_gne__c(
                                Type_gne__c = ptp.Type_gne__c,
                                Brand_gne__c = ptp.Brand_gne__c,
                                Franchise_Month_gne__c = ptp.Franchise_Month_gne__c,
                                Franchise_Quarter_gne__c = ptp.Franchise_Quarter_gne__c,
                                Franchise_Year_gne__c = ptp.Franchise_Year_gne__c,
                                Region_Month_gne__c = ptp.Region_Month_gne__c,
                                Region_Quarter_gne__c = ptp.Region_Quarter_gne__c,
                                Region_Year_gne__c = ptp.Region_Year_gne__c,
                                Division_Month_gne__c = ptp.Division_Month_gne__c,
                                Division_Quarter_gne__c = ptp.Division_Quarter_gne__c,
                                Division_Year_gne__c = ptp.Division_Year_gne__c,
                                Territory_Month_gne__c = ptp.Territory_Month_gne__c,
                                Territory_Quarter_gne__c = ptp.Territory_Quarter_gne__c,
                                Territory_Year_gne__c = ptp.Territory_Year_gne__c
                        )
                );
            }
        }

        private void setFieldsForVer7(FCR_Days_Plan_gne__c daysPlan) {
            this.CheckInComment = daysPlan.CheckInComment_gne__c;
            this.Development = daysPlan.Development_gne__c;
        }
    }

    public class FCR_Account {
        public String Name { get; private set; }
        public String Address { get; private set; }
        public String Notes { get; private set; }

        public FCR_Account(FCR_Days_Plan_Account_gne__c acc) {
            this.Name = acc.AP_Account_gne__r.Name;
            this.Address = acc.AP_Account_gne__r.Address_gne__c;
            this.Notes = acc.Notes_gne__c;
        }
    }

    public List<FCR_Daysplan_Job_Accountability_gne__c> getDaysplanJobAccountabilities() {
        try {
            return GNE_FCR_DAO.getFcrJobAccountabilities(fcrDaysPlanId);
        } catch (Exception e) {
            return new List<FCR_Daysplan_Job_Accountability_gne__c>();
        }
    }

    public List<SelectOption> getGatherInsightsTypes() {
        return GNE_FCR_Util.getPicklistGatherInsightsTypes(getDaysPlan().Version_gne__c, false);
    }

    public List<SelectOption> getIdentifyingShiftsTypes() {
        return GNE_FCR_Util.getPicklistIdentifyingShiftsTypes(getDaysPlan().Version_gne__c, false);
    }

    public List<SelectOption> getStrategicAccountPlanningTypes() {
        return GNE_FCR_Util.getPicklistStrategicAccountPlanningTypes(getDaysPlan().Version_gne__c, false);
    }

    public List<SelectOption> getCheckAssumptionsTypes() {
        return GNE_FCR_Util.getPicklistCheckAssumptionsTypes(getDaysPlan().Version_gne__c, false);
    }

    public List<SelectOption> getEffectiveProbingTypes() {
        return GNE_FCR_Util.getPicklistEffectiveProbingTypes(getDaysPlan().Version_gne__c, false);
    }

    public List<SelectOption> getReflectiveListeningTypes() {
        return GNE_FCR_Util.getPicklistReflectiveListeningTypes(getDaysPlan().Version_gne__c, false);
    }

    public List<SelectOption> getAligningInformationTypes() {
        return GNE_FCR_Util.getPicklistAligningInformationTypes(getDaysPlan().Version_gne__c, false);
    }

    public List<SelectOption> getObjectionHandlingTypes() {
        return GNE_FCR_Util.getPicklistObjectionHandlingTypes(getDaysPlan().Version_gne__c, false);
    }

    public List<SelectOption> getExecuteClosingTypes() {
        return GNE_FCR_Util.getPicklistExecuteClosingTypes(getDaysPlan().Version_gne__c, false);
    }

    public List<SelectOption> getJobAccountabilitiesTypes() {
        return GNE_FCR_Util.getPicklistJobAccountabilitiesTypes(getDaysPlan().Version_gne__c, false);
    }

    public List<Attachment> getAttachments() {
        return [SELECT Id, Name, CreatedDate FROM Attachment WHERE ParentId = :daysPlan.Id];
    }

}