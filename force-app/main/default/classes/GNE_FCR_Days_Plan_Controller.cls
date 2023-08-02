public with sharing class GNE_FCR_Days_Plan_Controller {
    public FCR_Days_Plan_gne__c daysPlan { get; set; }
    public User feUser { get; private set; }
    public String territory { get; set; }
    public String fcrId { get; set; }
    public String fcrDate { get; set; }
    public List<DayObjectiveWrapper>daysObjectivesUI { get; set; }
    public List<AccountWrapper>accounts { get; set; }
    public AccountWrapper newAccount { get; set; }
    public FCR_Days_Plan_gne__c previousDaysPlan { get; set; }

    private List<Territory2>userTerritories;
    private List<FCR_Days_Objective_gne__c>daysObjectives;
    private List<FCR_Days_Plan_Account_gne__c> daysPlanAccounts;

    public Integer objectiveIndexToRemove { get; set; }

    public GNE_FCR_Days_Plan_Controller() {
        if (ApexPages.currentPage().getParameters().containsKey('fcrId')) {
            fcrId = ApexPages.currentPage().getParameters().get('fcrId');
        } else if (this.daysPlan != null) {
            fcrId = this.daysPlan.Id;
        }
        userTerritories = GNE_FCR_DAO.getTerritories(UserInfo.getUserId());
        accounts = getAvailableAccounts();
        newAccount = new AccountWrapper('', '', '');
    }

    public PageReference init() {
        try {
            if (String.isEmpty(fcrId) && !GNE_FCR_Util.getIsFE()) {
                PageReference pr = Page.GNE_FCR_Error;
                pr.getParameters().put('exMessage', 'Only FE user can create FCR.');
                return pr;
            }
            if (String.isEmpty(fcrId)) {
                feUser = getUser(UserInfo.getUserId());
                this.daysPlan = getNewPlanAndSetupVariables();
            } else {
                this.daysPlan = GNE_FCR_DAO.getFCR(fcrId);
                feUser = getUser(this.daysPlan.CS_User_gne__c);
                daysObjectives = GNE_FCR_DAO.getFcrDaysObjectives(fcrId);
                daysPlanAccounts = GNE_FCR_DAO.getFcrAccounts(fcrId);
                daysObjectivesUI = getDaysObjectivesForUI(daysObjectives);
                setAccountsProperty(daysPlanAccounts, accounts);
            }
            fcrDate = Datetime.newInstance(this.daysPlan.Date_Field_Visit_gne__c.year(), this.daysPlan.Date_Field_Visit_gne__c.month(), this.daysPlan.Date_Field_Visit_gne__c.day()).format('MM/dd/yyyy');
        } catch (Exception e) {
            PageReference pr = Page.GNE_FCR_Error;
            pr.getParameters().put('exMessage', e.getMessage());
            pr.getParameters().put('developerMessage', e.getStackTraceString());
            System.debug(e);
            return pr;
        }
        return null;
    }

    private FCR_Days_Plan_gne__c getNewPlanAndSetupVariables() {
        FCR_Days_Plan_gne__c daysPlan = new FCR_Days_Plan_gne__c(Date_Field_Visit_gne__c = Date.today(), Version_gne__c = GNE_FCR_Util.getFCRWorkingVersion(UserInfo.getUserId()));
        GNE_FCR_Util.setDaysPlanActionAndStatus(daysPlan, GNE_FCR_Util.FCR_NEW_STATUS);
        daysPlan.CS_User_gne__c = feUser.Id;
        previousDaysPlan = GNE_FCR_DAO.getPreviousActionPlan(UserInfo.getUserId());
        if (previousDaysPlan != null) {
            daysPlan.Previous_Action_Plan_gne__c = previousDaysPlan.Id;
            daysPlan.CheckInComment_gne__c = previousDaysPlan.CheckInComment_gne__c;
            daysPlan.Development_gne__c = previousDaysPlan.Development_gne__c;
        }
        if (feUser.ManagerId != null) {
            daysPlan.FR_User_gne__c = feUser.ManagerId;
        }
        if (!userTerritories.isEmpty()) {
            daysPlan.Territory_gne__c = userTerritories.get(0).Id;
            Franchise_Objective_gne__c franchiseObjective = GNE_FCR_DAO.getFranchiseObjective(userTerritories.get(0).Salesforce_Code_gne__c, userTerritories.get(0).Salesforce_SubTeam_Code_gne__c);
            if (franchiseObjective != null) {
                daysPlan.Franchise_Objective_gne__c = franchiseObjective.Id;
                daysPlan.Franchise_Obj_fcr__c = franchiseObjective.Objective_gne__c;
            }
        } else {
            daysPlan.Territory_gne__c = '';
        }
        daysObjectives = new List<FCR_Days_Objective_gne__c>();
        daysObjectivesUI = new List<DayObjectiveWrapper>();
        daysObjectivesUI.add(new DayObjectiveWrapper(Date.today(), '', daysObjectivesUI.size()));
        daysPlanAccounts = new List<FCR_Days_Plan_Account_gne__c>();
        return daysPlan;
    }

    private List<AccountWrapper>getAvailableAccounts() {
        List<AccountWrapper>accounts = new List<AccountWrapper>();
        for (AP_Account_User_gne__c apUserAccount : GNE_FCR_DAO.getAvailableAccounts(UserInfo.getUserId())) {
            accounts.add(new AccountWrapper(apUserAccount, false));
        }
        return accounts;
    }

    public void addDayObjective() {
        if (daysObjectivesUI.isEmpty()) {
            daysObjectivesUI.add(new DayObjectiveWrapper(Date.today(), '', daysObjectivesUI.size()));
        } else {
            DayObjectiveWrapper wrapper = daysObjectivesUI.get(daysObjectivesUI.size() - 1);
            daysObjectivesUI.add(new DayObjectiveWrapper(Date.parse(wrapper.objectiveDate).addDays(1), '', daysObjectivesUI.size()));
        }
    }

    public void removeObjective() {
        if (daysObjectivesUI.size() > 1) {
            daysObjectivesUI.remove(objectiveIndexToRemove);
            for (Integer i = 0; i < daysObjectivesUI.size(); i++) {
                daysObjectivesUI.get(i).index = i;
            }
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.GNE_FCR_Days_Objective_Delete_Exception));
        }
    }

    public void addNewAccount() {
        if (!String.isEmpty(newAccount.apAccount.Name)) {
            newAccount.isSelected = true;
            if (!accounts.isEmpty()) {
                accounts.add(0, newAccount);
            } else {
                accounts.add(newAccount);
            }
            newAccount = new AccountWrapper('', '', '');
        }
    }

    private void setAccountsProperty(List<FCR_Days_Plan_Account_gne__c> daysPlanAccounts, List<AccountWrapper>accounts) {
        Map<Id, AccountWrapper>apAccountToWrapper = new Map<Id, AccountWrapper>();
        for (AccountWrapper wrapper : accounts) {
            apAccountToWrapper.put(wrapper.apAccount.Id, wrapper);
        }

        for (FCR_Days_Plan_Account_gne__c account : daysPlanAccounts) {
            AccountWrapper wrapper = apAccountToWrapper.get(account.AP_Account_gne__c);
            if (wrapper != null) {
                wrapper.isSelected = true;
                wrapper.notes = account.Notes_gne__c;
            }
        }
    }

    private List<DayObjectiveWrapper>getDaysObjectivesForUI(List<FCR_Days_Objective_gne__c>daysObjectives) {
        List<DayObjectiveWrapper>result = new List<DayObjectiveWrapper>();
        for (FCR_Days_Objective_gne__c dayObjective : daysObjectives) {
            result.add(new DayObjectiveWrapper(dayObjective, result.size()));
        }
        return result;
    }

    /*Validate days plan, is validation failed add error message to result */
    private List<String> validate() {
        List<String>result = new List<String>();
        if (String.isBlank(fcrDate) || !GNE_FCR_Util.isDateStringValid(fcrDate)) {
            result.add(System.Label.GNE_FCR_Date_Format_Validation);
        } else {
            daysPlan.Date_Field_Visit_gne__c = Date.parse(fcrDate);
        }
        if (getSelectedAccounts().isEmpty()) {
            result.add(System.Label.GNE_FCR_Account_Validation);
        }
        if (String.isBlank(daysPlan.Territory_gne__c)) {
            result.add(System.Label.GNE_FCR_Territory_Validation);
        }
        if (daysObjectivesUI.isEmpty()) {
            result.add(System.Label.GNE_FCR_Days_Objective_Required_Validation);
        }
        Boolean errorAdded = false;
        for (DayObjectiveWrapper wrapper : daysObjectivesUI) {
            if (String.isEmpty(wrapper.objective)) {
                result.add(System.Label.GNE_FCR_Days_Objective_Content_Validation);
                break;
            }
            if (Date.parse(wrapper.objectiveDate) < Date.today()) {
                result.add(System.Label.GNE_FCR_Days_Objective_Date_Validation);
                errorAdded = true;
                break;
            }
        }
        for (Integer i = 0; i < daysObjectivesUI.size(); i++) {
            DayObjectiveWrapper wrapper = daysObjectivesUI.get(i);
            if (!errorAdded && i < daysObjectivesUI.size() - 1) {
                for (Integer j = i + 1; j < daysObjectivesUI.size(); j++) {
                    if (wrapper.objectiveDate == daysObjectivesUI.get(j).objectiveDate) {
                        result.add(System.Label.GNE_FCR_Days_Objective_Date_Validation);
                        errorAdded = true;
                        break;
                    }
                }
            }
        }
        return result;
    }

    private User getUser(Id userId) {
        return [SELECT Id, Name, ManagerId FROM User WHERE Id = :userId];
    }

    public List<SelectOption> getAvailableTerritories() {
        List<SelectOption> result = new List<SelectOption>();
        for (Territory2 territory : userTerritories) {
            result.add(new SelectOption(territory.Id, territory.Name));
        }
        return result;
    }

    public PageReference deleteFCR() {
        if (String.isNotBlank(daysPlan.Id)) {
            Blob pdf = GNE_FCR_Util.generatePDF(Page.GNE_FCR_PDF, daysPlan.Id);
            Messaging.EmailFileAttachment attachment = GNE_FCR_Util.createAttachment('application/pdf', GNE_FCR_Util.getReportName(daysPlan.Id), pdf);
            if (getIsFE()) {
                GNE_FCR_Util.sendEmail('FCR_Deleted_gne', daysPlan, daysPlan.FR_User_gne__c, new List<Messaging.EmailFileAttachment>{
                        attachment
                });
            } else if (getIsFR()) {
                GNE_FCR_Util.sendEmail('FCR_Deleted_gne', daysPlan, daysPlan.CS_User_gne__c, new List<Messaging.EmailFileAttachment>{
                        attachment
                });
            }
            //need to invoke external method in class withoud sharing, because of record sharing issue
            GNE_FCR_Util.deleteFCR(daysPlan);
        }
        return Page.GNE_FCR_My_Open_FCRs;
    }

    public PageReference cancel() {
        PageReference pr = Page.GNE_FCR_My_Open_FCRs;
        pr.setRedirect(true);
        return pr;
    }

    public PageReference archive() {
        GNE_FCR_Util.setDaysPlanActionAndStatus(daysPlan, GNE_FCR_Util.FCR_ARCHIVED_STATUS);
        update daysPlan;
        return null;
    }

    public Boolean getIsArchiveButtonEnabled() {
        //for GIO (vedr 7) FCR have to be acknowledged
        return GNE_FCR_Util.getIsFR() && !GNE_FCR_Util.isNsdRsdUser(UserInfo.getUserId())
                && ((daysPlan.Version_gne__c != 7 && daysPlan.Status_gne__c.equals(GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_COMPLETED_STATUS)))
                || (daysPlan.Version_gne__c == 7 && daysPlan.Status_gne__c.equals(GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_ACKNOWLEDGED_STATUS))));
    }

    public Boolean getIsAcknowledgeButtonEnabled() {
        return GNE_FCR_Util.getIsFE() && daysPlan.Version_gne__c == 7 && daysPlan.Status_gne__c.equals(GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_COMPLETED_STATUS));
    }

    public void saveFCRIfNeeded() {
        if (getIsFcrEditableForFR()) {
            update daysPlan;
        } else if (!isFCRNotUpdatable()) {
            save();
        }
    }

    public PageReference editAssessment() {
        GNE_FCR_Util.setDaysPlanActionAndStatus(daysPlan, GNE_FCR_Util.FCR_APPROVED_STATUS);
        update daysPlan;
        PageReference assessPage = Page.GNE_FCR_Days_Plan_Assess;
        assessPage.getParameters().put('fcrId', daysPlan.Id);
        assessPage.setRedirect(true);
        return assessPage;
    }

    public PageReference save() {
        try {
            saveFCR();
        } catch (Exception e) {
            PageReference pr = Page.GNE_FCR_Error;
            pr.getParameters().put('exMessage', e.getMessage());
            pr.getParameters().put('developerMessage', e.getStackTraceString());
            System.debug(e);
            return pr;
        }
        PageReference detailPage = Page.GNE_FCR_Days_Plan;
        detailPage.getParameters().put('fcrId', daysPlan.Id);
        detailPage.setRedirect(true);
        return detailPage;
    }

    private void saveFCR() {
        Savepoint sp = Database.setSavepoint();
        try {
            if (!String.isBlank(fcrDate) && GNE_FCR_Util.isDateStringValid(fcrDate)) {
                daysPlan.Date_Field_Visit_gne__c = Date.parse(fcrDate);
            }
            try {
                daysPlan.Territory_Name_gne__c = [SELECT Name FROM Territory2 WHERE Id = :daysPlan.Territory_gne__c].Name;
            } catch (Exception e) {
                daysPlan.Territory_Name_gne__c = daysPlan.Territory_gne__c;
            }
            upsert daysPlan;

            //insert/update/delete fcr accounts
            List<AP_Account_gne__c>accountsToInsert = new List<AP_Account_gne__c>();
            for (AccountWrapper wrapper : accounts) {
                if (String.isEmpty(wrapper.apAccount.Id)) {
                    wrapper.apAccount.OrgId_gne__c = GNE_FCR_Util.FCR_INTERNAL_ACCOUNT_PREFIX + daysPlan.Id + GNE_FCR_Util.generateRandomString(50);
                    accountsToInsert.add(wrapper.apAccount);
                }
            }
            if (!accountsToInsert.isEmpty()) {
                insert accountsToInsert;
                List<AP_Account_User_gne__c>userAccountsToInsert = new List<AP_Account_User_gne__c>();
                for (AP_Account_gne__c apAccount : accountsToInsert) {
                    userAccountsToInsert.add(new AP_Account_User_gne__c(AP_Account_gne__c = apAccount.Id, CS_User_gne__c = UserInfo.getUserId(), Account_CSUser_gne__c = apAccount.Id + '-' + UserInfo.getUserId()));
                }
                insert userAccountsToInsert;
            }

            Map<Id, FCR_Days_Plan_Account_gne__c>accountToFcrAccountMap = new Map<Id, FCR_Days_Plan_Account_gne__c>();
            for (FCR_Days_Plan_Account_gne__c fcrAccount : daysPlanAccounts) {
                if (fcrAccount.Account_gne__c != null) {
                    accountToFcrAccountMap.put(fcrAccount.Account_gne__c, fcrAccount);
                } else {
                    accountToFcrAccountMap.put(fcrAccount.AP_Account_gne__c, fcrAccount);
                }
            }
            List<FCR_Days_Plan_Account_gne__c>fcrAccountsToUpsert = new List<FCR_Days_Plan_Account_gne__c>();
            for (AccountWrapper accountWrapper : getSelectedAccounts()) {
                if (accountToFcrAccountMap.containsKey(accountWrapper.apAccount.Id)) {
                    FCR_Days_Plan_Account_gne__c fcrAccount = accountToFcrAccountMap.remove(accountWrapper.apAccount.Id);
                    if ((fcrAccount.Territory_gne__c != null && !fcrAccount.Territory_gne__c.equals(daysPlan.Territory_gne__c)) || fcrAccount.Notes_gne__c != accountWrapper.notes) {
                        fcrAccount.Territory_gne__c = daysPlan.Territory_gne__c;
                        fcrAccount.Notes_gne__c = accountWrapper.notes;
                        fcrAccountsToUpsert.add(fcrAccount);
                    }
                } else {
                    fcrAccountsToUpsert.add(new FCR_Days_Plan_Account_gne__c(AP_Account_gne__c = accountWrapper.apAccount.Id, Territory_gne__c = daysPlan.Territory_gne__c, FCR_Days_Plan_gne__c = daysPlan.Id, Notes_gne__c = accountWrapper.notes));
                }
            }
            if (!fcrAccountsToUpsert.isEmpty()) {
                upsert fcrAccountsToUpsert;
            }
            if (!accountToFcrAccountMap.isEmpty()) {
                delete accountToFcrAccountMap.values();
            }

            //days objective
            Map<Id, FCR_Days_Objective_gne__c>idToDaysObjective = new Map<Id, FCR_Days_Objective_gne__c>();
            for (FCR_Days_Objective_gne__c dayOjective : daysObjectives) {
                idToDaysObjective.put(dayOjective.Id, dayOjective);
            }

            List<FCR_Days_Objective_gne__c>daysObjectivesToUpsert = new List<FCR_Days_Objective_gne__c>();

            for (DayObjectiveWrapper wrapper : daysObjectivesUI) {
                if (idToDaysObjective.containsKey(wrapper.id)) {
                    FCR_Days_Objective_gne__c dayObjective = idToDaysObjective.remove(wrapper.id);
                    if ((String.isEmpty(dayObjective.Objective_gne__c) && String.isNotEmpty(wrapper.objective)) || (String.isNotEmpty(dayObjective.Objective_gne__c) && !dayObjective.Objective_gne__c.equals(wrapper.objective)) || !dayObjective.Objective_Date_gne__c.format().equals(wrapper.objectiveDate)) {
                        dayObjective.Objective_gne__c = wrapper.objective;
                        dayObjective.Objective_Date_gne__c = Date.parse(wrapper.objectiveDate);
                        daysObjectivesToUpsert.add(dayObjective);
                    }
                } else {
                    daysObjectivesToUpsert.add(new FCR_Days_Objective_gne__c(Objective_Date_gne__c = Date.parse(wrapper.objectiveDate), Objective_gne__c = wrapper.objective, FCR_Days_Plan_gne__c = daysPlan.Id));
                }
            }
            if (!daysObjectivesToUpsert.isEmpty()) {
                upsert daysObjectivesToUpsert;
            }
            if (!idToDaysObjective.isEmpty()) {
                delete idToDaysObjective.values();
            }
        } catch (Exception e) {
            Database.rollback(sp);
            throw e;
        }
    }

    public PageReference submitToReviewer() {
        Savepoint sp = Database.setSavepoint();
        try {
            List<String>errors = validate();
            if (errors.isEmpty()) {
                GNE_FCR_Util.setDaysPlanActionAndStatus(daysPlan, GNE_FCR_Util.FCR_UNDER_REVIEW_STATUS);
                saveFCR();
                //share record with reviewer
                GNE_FCR_Util.removeFcrSharing(daysPlan.Id);
                FCR_Days_Plan_gne__Share daysPlanShr = new FCR_Days_Plan_gne__Share();
                daysPlanShr.ParentId = daysPlan.Id;
                daysPlanShr.AccessLevel = 'Edit';
                daysPlanShr.RowCause = Schema.FCR_Days_Plan_gne__Share.RowCause.Manual;
                daysPlanShr.UserOrGroupId = daysPlan.FR_User_gne__c;
                insert daysPlanShr;

                GNE_FCR_Util.sendEmail('FCR_Send_To_Review_gne', daysPlan, daysPlan.FR_User_gne__c);
                return Page.GNE_FCR_My_Open_FCRs;
            } else {
                for (String errorMessage : errors) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
                }
                return null;
            }
        } catch (Exception e) {
            Database.rollback(sp);
            System.debug(LoggingLevel.ERROR, e.getMessage());
            PageReference pr = Page.GNE_FCR_Error;
            pr.getParameters().put('exMessage', e.getMessage());
            return pr;
        }
    }

    public PageReference returnToFE() {
        if (String.isBlank(daysPlan.DM_Comments_gne__c)) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Comment is required.'));
        } else {
            GNE_FCR_Util.setDaysPlanActionAndStatus(daysPlan, GNE_FCR_Util.FCR_AWAITING_UPDATE_STATUS);
            update daysPlan;
            GNE_FCR_Util.sendEmail('FCR_Send_To_Update_gne', daysPlan, daysPlan.CS_User_gne__c);
            GNE_FCR_Util.removeFcrSharing(daysPlan.Id);
        }
        return Page.GNE_FCR_My_Open_FCRs;
    }

    public PageReference approve() {
        //get PTP data
        if (GNE_FCR_Util.isSupportedBySLDx(daysPlan.CS_User_gne__c)) {
            try {
                Territory2 terr;
                if (String.isNotEmpty(daysPlan.Territory_gne__c)) {
                    terr = [SELECT Id, Name, Territory_Number_gne__c FROM Territory2 WHERE Id = :daysPlan.Territory_gne__c];
                } else {
                    terr = [SELECT Id, Name, Territory_Number_gne__c FROM Territory2 WHERE Territory_Number_gne__c = :daysPlan.Territory_Name_gne__c];
                }
                if (terr != null) {
                    List<FCR_PTP_gne__c>ptpList = getPTPData(terr.Territory_Number_gne__c);
                    insert ptpList;
                }
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, e.getMessage());
            }
        } else {
            List<FCR_PTP_Summary_gne__c>summaries = [SELECT Notes_gne__c FROM FCR_PTP_Summary_gne__c WHERE CreatedById = :daysPlan.CS_User_gne__c];
            if (summaries.isEmpty()) {
                daysPlan.Performance_gne__c = '';
            } else {
                daysPlan.Performance_gne__c = summaries.get(0).Notes_gne__c;
            }
        }

        GNE_FCR_Util.setDaysPlanActionAndStatus(daysPlan, GNE_FCR_Util.FCR_APPROVED_STATUS);
        update daysPlan;
        Blob pdf = GNE_FCR_Util.generatePDF(Page.GNE_FCR_PDF, daysPlan.Id);
        Messaging.EmailFileAttachment attachment = GNE_FCR_Util.createAttachment('application/pdf', GNE_FCR_Util.getReportName(daysPlan.Id), pdf);
        GNE_FCR_Util.sendEmail('FCR_Approved_gne', daysPlan, daysPlan.CS_User_gne__c, new List<Messaging.EmailFileAttachment>{
                attachment
        });
        PageReference assessPage = Page.GNE_FCR_Days_Plan_Assess;
        assessPage.getParameters().put('fcrId', daysPlan.Id);
        assessPage.setRedirect(true);
        return assessPage;
    }

    public PageReference acknowledge() {
        GNE_FCR_Util.setDaysPlanActionAndStatus(daysPlan, GNE_FCR_Util.FCR_ACKNOWLEDGED_STATUS);
        update daysPlan;
        Blob pdf = GNE_FCR_Util.generatePDF(Page.GNE_FCR_PDF, daysPlan.Id, true, true);
        Messaging.EmailFileAttachment attachment = GNE_FCR_Util.createAttachment('application/pdf', GNE_FCR_Util.getReportName(daysPlan.Id), pdf);
        GNE_FCR_Util.sendEmail('FCR_Acknowledged_gne', daysPlan, daysPlan.FR_User_gne__c, new List<Messaging.EmailFileAttachment>{
                attachment
        });
        return null;
    }

    public void updateFranchise() {
        List<Territory2> territories = GNE_FCR_DAO.getTerritories(new List<Id>{
                daysPlan.Territory_gne__c
        });
        if (!territories.isEmpty()) {
            Franchise_Objective_gne__c franchiseObjective = GNE_FCR_DAO.getFranchiseObjective(territories.get(0).Salesforce_Code_gne__c, territories.get(0).Salesforce_SubTeam_Code_gne__c);
            if (franchiseObjective != null) {
                daysPlan.Franchise_Objective_gne__c = franchiseObjective.Id;
                daysPlan.Franchise_Obj_fcr__c = franchiseObjective.Objective_gne__c;
            }
        }
    }

    private List<FCR_PTP_gne__c>getPTPData(String territoryNumber) {
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setHeader('content-type', 'application/xml');

        String endpoint = Utilities.getGlobalVariable('GNE_FCR_PerformanceMetricsApiUrl') + territoryNumber;
        req.setEndpoint(endpoint);
        req.setClientCertificateName('GNE_FCR_Commercial');
        String authorizationHeader = Utilities.getGlobalVariable('GNE_FCR_PerformanceMetricsApiAuthHeader');
        req.setHeader('Authorization', authorizationHeader);
        req.setTimeout(120000);
        System.debug(LoggingLevel.INFO, 'Request: ' + req.toString());
        List<FCR_PTP_gne__c>result;
        Http http = new Http();
        HttpResponse res = http.send(req);
        if (res.getStatusCode() == 200) {
            System.debug(LoggingLevel.INFO, 'Response: ' + res.toString());
            System.debug(LoggingLevel.INFO, 'Respons body: ' + res.getBody());
            result = parseJson(res.getBody());
        } else {
            System.debug(LoggingLevel.ERROR, 'Respons body: ' + res.getBody());
            System.debug(LoggingLevel.ERROR, 'Respons to string: ' + res.toString());
            System.debug(LoggingLevel.ERROR, 'Respons status: ' + res.getStatus());
            System.debug(LoggingLevel.ERROR, 'Respons status code: ' + res.getStatusCode());
            result = new List<FCR_PTP_gne__c>();
        }
        return result;
    }

    private List<FCR_PTP_gne__c> parseJson(String jsonString) {
        List<FCR_PTP_gne__c>result = new List<FCR_PTP_gne__c>();
        JSONParser parser = JSON.createParser(jsonString);
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)) {
                String repType = parser.getText();
                while (parser.nextToken() != JSONToken.END_ARRAY) {
                    if (parser.getCurrentToken() == JSONToken.FIELD_NAME && parser.getText() == 'brand') {
                        FCR_PTP_gne__c performance = new FCR_PTP_gne__c();
                        performance.Type_gne__c = repType;
                        performance.FCR_Days_Plan_gne__c = daysPlan.Id;
                        result.add(performance);
                        parser.nextToken();
                        performance.Brand_gne__c = parser.getText();
                        parser.nextToken();
                        parser.nextToken();
                        performance.Territory_Month_gne__c = String.isEmpty(parser.getText()) ? 0 : Decimal.valueOf(parser.getText());
                        parser.nextToken();
                        parser.nextToken();
                        performance.Territory_Quarter_gne__c = String.isEmpty(parser.getText()) ? 0 : Decimal.valueOf(parser.getText());
                        parser.nextToken();
                        parser.nextToken();
                        performance.Territory_Year_gne__c = String.isEmpty(parser.getText()) ? 0 : Decimal.valueOf(parser.getText());
                        parser.nextToken();
                        parser.nextToken();
                        performance.Division_Month_gne__c = String.isEmpty(parser.getText()) ? 0 : Decimal.valueOf(parser.getText());
                        parser.nextToken();
                        parser.nextToken();
                        performance.Division_Quarter_gne__c = String.isEmpty(parser.getText()) ? 0 : Decimal.valueOf(parser.getText());
                        parser.nextToken();
                        parser.nextToken();
                        performance.Division_Year_gne__c = String.isEmpty(parser.getText()) ? 0 : Decimal.valueOf(parser.getText());
                        parser.nextToken();
                        parser.nextToken();
                        performance.Region_Month_gne__c = String.isEmpty(parser.getText()) ? 0 : Decimal.valueOf(parser.getText());
                        parser.nextToken();
                        parser.nextToken();
                        performance.Region_Quarter_gne__c = String.isEmpty(parser.getText()) ? 0 : Decimal.valueOf(parser.getText());
                        parser.nextToken();
                        parser.nextToken();
                        performance.Region_Year_gne__c = String.isEmpty(parser.getText()) ? 0 : Decimal.valueOf(parser.getText());
                        parser.nextToken();
                        parser.nextToken();
                        performance.Franchise_Month_gne__c = String.isEmpty(parser.getText()) ? 0 : Decimal.valueOf(parser.getText());
                        parser.nextToken();
                        parser.nextToken();
                        performance.Franchise_Quarter_gne__c = String.isEmpty(parser.getText()) ? 0 : Decimal.valueOf(parser.getText());
                        parser.nextToken();
                        parser.nextToken();
                        performance.Franchise_Year_gne__c = String.isEmpty(parser.getText()) ? 0 : Decimal.valueOf(parser.getText());
                    }
                }
            }
        }
        return result;
    }

    public PageReference createNewFcr() {
        return Page.GNE_FCR_Days_Plan;
    }

    @RemoteAction
    public static List<User>getFRs() {
        return GNE_FCR_DAO.getAvailableFRs(UserInfo.getUserId());
    }

    public class DayObjectiveWrapper {
        public Id id;
        public Integer index { get; set; }
        public String objectiveDate { get; set; }
        public String objective { get; set; }

        public DayObjectiveWrapper(Date objectiveDate, String objective, Integer index) {
            this.objectiveDate = Datetime.newInstance(objectiveDate.year(), objectiveDate.month(), objectiveDate.day()).format('MM/dd/yyyy');
            this.objective = objective;
            this.index = index;
        }

        public DayObjectiveWrapper(FCR_Days_Objective_gne__c daysObjective, Integer index) {
            this.id = daysObjective.Id;
            this.objectiveDate = Datetime.newInstance(daysObjective.Objective_Date_gne__c.year(), daysObjective.Objective_Date_gne__c.month(), daysObjective.Objective_Date_gne__c.day()).format('MM/dd/yyyy');
            this.objective = daysObjective.Objective_gne__c;
            this.index = index;
        }
    }

    public class AccountWrapper {
        public AP_Account_gne__c apAccount { get; set; }
        public Boolean isSelected { get; set; }
        public String notes { get; set; }

        public AccountWrapper(String name, String address, String notes) {
            this.apAccount = new AP_Account_gne__c(Name = name, Address_gne__c = address);
            this.notes = notes;
        }

        public AccountWrapper(AP_Account_User_gne__c apUserAccount, Boolean isSelected) {
            this.apAccount = new AP_Account_gne__c(Id = apUserAccount.AP_Account_gne__c, Name = apUserAccount.AP_Account_gne__r.Name, Address_gne__c = apUserAccount.AP_Account_gne__r.Address_gne__c);
            this.isSelected = isSelected;
            this.notes = '';
        }
    }

    /*Methods to resolve button and field visibility base on user and fcr status*/
    public Boolean isFCRNotUpdatable() {
        return daysPlan.Status_gne__c.equals(GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_COMPLETED_STATUS)) ||
                daysPlan.Status_gne__c.equals(GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_ARCHIVED_STATUS)) ||
                daysPlan.Status_gne__c.equals(GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_ACKNOWLEDGED_STATUS));
    }

    public Boolean getIsButtonsVisible() {
        return getIsFcrEditable() || getIsEditAssessmentButtonEnabled() || getIsAcknowledgeButtonEnabled();
    }

    public Boolean getIsFcrEditable() {
        return getIsFcrEditableForFE() || getIsFcrEditableForFR();
    }

    public Boolean getIsFcrEditableForFE() {
        if (getIsFE()) {
            if (daysPlan.Status_gne__c.equals(GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_NEW_STATUS)) || daysPlan.Status_gne__c.equals(GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_AWAITING_UPDATE_STATUS))) {
                return true;
            }
        }
        return false;
    }

    public Boolean getIsFcrEditableForFR() {
        if (getIsFR()) {
            if (daysPlan.Status_gne__c.equals(GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_UNDER_REVIEW_STATUS))) {
                return true;
            }
        }
        return false;
    }

    public Boolean getIsFE() {
        return GNE_FCR_Util.getIsFE();
    }

    public Boolean getIsFR() {
        return GNE_FCR_Util.getIsFR();
    }

    public Boolean getIsDeleteButtonEnabled() {
        return String.isNotBlank(daysPlan.Id) && ((getIsFR() && !daysPlan.Status_gne__c.equals(GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_ARCHIVED_STATUS))) ||
                (getIsFE() && (daysPlan.Status_gne__c.equals(GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_NEW_STATUS)) ||
                        daysPlan.Status_gne__c.equals(GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_UNDER_REVIEW_STATUS)) ||
                        daysPlan.Status_gne__c.equals(GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_AWAITING_UPDATE_STATUS)))));
    }

    public Boolean getIsEditAssessmentButtonEnabled() {
        return String.isNotBlank(daysPlan.Id) && getIsFR() && !GNE_FCR_Util.isNsdRsdUser(UserInfo.getUserId()) &&
                (daysPlan.Status_gne__c.equals(GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_COMPLETED_STATUS)) || daysPlan.Status_gne__c.equals(GNE_FCR_Util.getDaysPlanStatus(GNE_FCR_Util.FCR_ACKNOWLEDGED_STATUS)));
    }

    private Set<AccountWrapper>getSelectedAccounts() {
        Set<AccountWrapper>result = new Set<AccountWrapper>();
        for (AccountWrapper wrapper : accounts) {
            if (wrapper.isSelected) {
                result.add(wrapper);
            }
        }
        return result;
    }
}