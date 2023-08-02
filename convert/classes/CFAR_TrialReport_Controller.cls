global with sharing class CFAR_TrialReport_Controller extends CFAR_TrialReport_Model {

    public CFAR_TrialReport_Controller() {
        super();
    }

    @RemoteAction
    global static OperationStatus saveFilter(String filterId, String filterName, String studyNr, String ctms, String wbsCode, List<String> products, List<String> therapeuticAreas, List<String> indications, List<String> trialTypes, List<String> studyStatuses, List<String> subjectTypes, List<String> pediatricStudies,
            List<String> specIndications, List<String> impacts, List<String> SRTs, List<String> teamMembers, List<String> GNEs, List<String> inclusiveResearch) {
        Savepoint sp = Database.setSavepoint();
        String msg;
        try {
            CFAR_Filter_gne__c filter = (filterId == null) ? new CFAR_Filter_gne__c(Name = filterName) : new CFAR_Filter_gne__c(id = filterId, Name = filterName);
            upsert filter;
            if (!String.isBlank(filterId)) {
                List<CFAR_Filter_Option_gne__c> options = [Select id, Field_Name_gne__c, Value_gne__c from CFAR_Filter_Option_gne__c where CFAR_Filter_ref_gne__c = :filterId];
                if (options != null && !options.isEmpty())
                    delete options;
            }
            filterId = filter.id;
            List<CFAR_Filter_Option_gne__c> newFilterOptions = convertFilterOptions(filterId, studyNr, ctms, wbsCode, products, therapeuticAreas, indications, trialTypes, studyStatuses, subjectTypes, pediatricStudies, specIndications, impacts, SRTs, teamMembers, GNEs, inclusiveResearch);
            insert newFilterOptions;
        } catch (Exception e) {
            Database.rollback(sp);
            CFAR_Utils.logError(e, filterId);
            msg = e.getMessage();
        }
        return new OperationStatus(filterId, filterName, (msg == null) ? 'success' : 'failure', msg);
    }

    @RemoteAction
    global static OperationStatus deleteFilter(String filterId) {
        String msg;
        Savepoint sp = Database.setSavepoint();
        try {
            delete [Select id from CFAR_Filter_gne__c where id = :filterId];
        } catch (Exception e) {
            Database.rollback(sp);
            CFAR_Utils.logError(e, filterId);
            msg = e.getMessage();
        }
        return new OperationStatus(filterId, null, (msg == null) ? 'success' : 'failure', msg);
    }


    @RemoteAction
    global static List<IdNameWrapper> getFilterNames() {
        List<IdNameWrapper> fWrapper = new List<IdNameWrapper>();

        List<CFAR_Filter_gne__c> filters = [
                SELECT Id, Name
                FROM CFAR_Filter_gne__c
                WHERE RecordTypeId NOT IN (:CFAR_FilterHelper.RT_CLINICAL, :CFAR_FilterHelper.RT_TEAMCONTACTS)
        ];
        for (CFAR_Filter_gne__c filter : filters) {
            fWrapper.add(new IdNameWrapper(filter.Id, filter.Name));
        }
        return fWrapper;
    }

    @RemoteAction
    global static SingleFilter getFilter(String filterId) {
        SingleFilter sf = new SingleFilter();
        CFAR_Filter_gne__c filter = [Select Id, Name from CFAR_Filter_gne__c where id = :filterId];
        if (filter == null)
            return sf;
        sf.id = filter.id;
        sf.name = filter.name;
        List<CFAR_Filter_Option_gne__c> fOptions = [Select id, Field_Name_gne__c, Value_gne__c, CFAR_Filter_ref_gne__c from CFAR_Filter_Option_gne__c where CFAR_Filter_ref_gne__c = :filterId];

        for (CFAR_Filter_Option_gne__c fOption : fOptions) {
            if ('Product_ref_gne__c'.equals(fOption.Field_Name_gne__c))
                sf.products.add(fOption.Value_gne__c);
            if ('Therapeutic_Area_ref_gne__c'.equals(fOption.Field_Name_gne__c))
                sf.therapeuticAreas.add(fOption.Value_gne__c);
            if ('CFAR_General_Indication_ref_gne__c'.equals(fOption.Field_Name_gne__c))
                sf.indications.add(fOption.Value_gne__c);
            if ('Trial_Type_ref_gne__c'.equals(fOption.Field_Name_gne__c))
                sf.trialTypes.add(fOption.Value_gne__c);
            if ('Trial_Status_ref_gne__c'.equals(fOption.Field_Name_gne__c))
                sf.trialStatuses.add(fOption.Value_gne__c);
            if ('Subject_Type__c'.equals(fOption.Field_Name_gne__c))
                sf.subjectTypes.add(fOption.Value_gne__c);
            if ('Pediatric_Study_gne__c'.equals(fOption.Field_Name_gne__c))
                sf.pediatricStudies.add(fOption.Value_gne__c);
            if ('Name'.equals(fOption.Field_Name_gne__c))
                sf.studyNr = fOption.Value_gne__c;
            if ('CTMS_gne__c'.equals(fOption.Field_Name_gne__c))
                sf.ctms = fOption.Value_gne__c;
            if ('WBS'.equals(fOption.Field_Name_gne__c))
                sf.wbs = fOption.Value_gne__c;
            if ('SRT_Team_ref_gne__c'.equals(fOption.Field_Name_gne__c))
                sf.SRTs.add(fOption.Value_gne__c);
            if ('CFAR_Specific_Indication_ref_gne__c'.equals(fOption.Field_Name_gne__c))
                sf.specificIndications.add(fOption.Value_gne__c);
            if ('Impacts_gne__c'.equals(fOption.Field_Name_gne__c))
                sf.impacts.add(fOption.Value_gne__c);
            if ('teamMember'.equals(fOption.Field_Name_gne__c))
                sf.teamMembers.add(fOption.Value_gne__c);
            if ('GNE'.equals(fOption.Field_Name_gne__c))
                sf.GNESupports.add(fOption.Value_gne__c);
            if ('Inclusive_Research_gne__c'.equals(fOption.Field_Name_gne__c))
                sf.inclusiveResearch.add(fOption.Value_gne__c);
        }
        return sf;
    }

    @RemoteAction
    global static FilterData getFilterData() {
        FilterData fd = new FilterData();
        CFAR_SearchParameters searchParms = new CFAR_SearchParameters();
        searchParms.sortExpression = 'Name';
        searchParms.sortDirection = 'asc';

        for (CFAR_Therapeutic_Area_gne__c ta : CFAR_DAO.getTherapeuticAreas(searchParms)) {
            fd.therapeuticAreas.add(new IdNameWrapper(ta.Id, ta.Name));
        }
        for (CFAR_General_Indication_gne__c gi : CFAR_DAO.getGeneralIndications(searchParms)) {
            fd.indications.add(new IdNameWrapper(gi.Id, gi.Name));
        }
        for (CFAR_Product_gne__c pr : CFAR_DAO.getProducts(searchParms)) {
            fd.products.add(new IdNameWrapper(pr.Id, pr.Name));
        }
        for (CFAR_Trial_Status_gne__c ts : CFAR_DAO.getTrialStatuses(searchParms)) {
            if (ts.Name != Label.CFAR_GSTARS_TRIAL_STATUS_ADMIN_FIX)
                fd.trialStatuses.add(new IdNameWrapper(ts.Id, ts.Name));
        }
        for (CFAR_Trial_Type_gne__c tt : CFAR_DAO.getTrialTypes(searchParms)) {
            fd.trialTypes.add(new IdNameWrapper(tt.Id, tt.Name));
        }
        for (CFAR_Picklist_Value_gne__c srt : CFAR_DAO.getSRTTeams()) {
            fd.SRTs.add(new IdNameWrapper(srt.Id, srt.Name));
        }
        for (CFAR_Specific_Indication_gne__c si : CFAR_DAO.getSpecificIndications(searchParms)) {
            fd.specificIndications.add(new IdNameWrapper(si.Id, si.Name));
        }
        for (CFAR_Picklist_Value_gne__c im : CFAR_DAO.getCFARPicklistValues(Schema.SObjectType.CFAR_Picklist_Value_gne__c.getRecordTypeInfosByName().get('Impact').getRecordTypeId())) {
            fd.impacts.add(im.Name);
        }
        for (CFAR_Dollar_and_Drug_gne__c gne : CFAR_DAO.getGNESupportForSelectOptions(searchParms)) {
            fd.GNESupports.add(new IdNameWrapper(gne.Id, gne.Name));
        }
        for (Schema.PicklistEntry inc : CFAR_Trial_gne__c.Inclusive_Research_gne__c.getDescribe().getPicklistValues()) {
            fd.inclusiveResearch.add(inc.getValue());
        }
        for (CFAR_Contact_gne__c ct : CFAR_DAO.getContactsForSelectOptions(searchParms)) {
            fd.teamMembers.add(new IdNameWrapper(ct.Id, ct.Search_Name__c));
        }
        for (Schema.PicklistEntry f : CFAR_Trial_gne__c.Subject_Type__c.getDescribe().getPicklistValues()) {
            fd.subjectTypes.add(f.getValue());
        }
        for (Schema.PicklistEntry f : CFAR_Trial_gne__c.Pediatric_Study_gne__c.getDescribe().getPicklistValues()) {
            fd.pediatricStudies.add(f.getValue());
        }
        return fd;
    }

    @RemoteAction
    global static TableTabData getTableTabData() {
        TableTabData tData = new TableTabData();
        tData.msls = getMSLs();
        CFAR_SearchParameters searchParms = new CFAR_SearchParameters();
        searchParms.sortExpression = 'Name';
        searchParms.sortDirection = 'asc';
        for (CFAR_General_Indication_gne__c gi : CFAR_DAO.getGeneralIndications(searchParms)) {
            tData.indications.add(gi.Name);
        }
        for (CFAR_Trial_Status_gne__c ts : CFAR_DAO.getTrialStatuses(searchParms)) {
            tData.statuses.add(ts.Name);
        }
        return tData;
    }

    @RemoteAction
    global static ProgramSummaryTabData getProgramSummaryTabData(String studyNr, String ctms, String wbsCode, List<String> products, List<String> therapeuticAreas, List<String> indications, List<String> trialTypes, List<String> studyStatuses, List<String> subjectTypes, List<String> pediatricStudies,
            List<String> specIndications, List<String> impacts, List<String> SRTs, List<String> teamMember, List<String> GNEs, List<String> inclusiveResearch) {
        System.debug('----- PS Start ' + Datetime.now());
        CFAR_SearchParameters searchParams = getSearchParams(studyNr, ctms, wbsCode, products, therapeuticAreas, indications, trialTypes, studyStatuses, subjectTypes, pediatricStudies,
                specIndications, impacts, SRTs, teamMember, GNEs, inclusiveResearch);
        List<CFAR_Trial_gne__c> trials = searchForTrialsProgramSummary(searchParams);
        System.debug('----- PS search end ' + Datetime.now());
        ProgramSummaryTabData rd = new ProgramSummaryTabData();
        rd.statusData = getStatusData(trials);
        rd.statusTotalCount = countTotalSize(rd.statusData);
        System.debug('----- PS status data end ' + Datetime.now());
        rd.indicationData = getIndicationData(trials);
        rd.indicationTotalCount = countTotalSize(rd.indicationData);
        System.debug('----- PS indication end ' + Datetime.now());
        rd.trials = convertTrialsForPS(trials);
        System.debug('----- PS convertion end ' + Datetime.now());
        return rd;
    }

    @RemoteAction
    global static InfrepTabData getInfrepTabData(String studyNr, String ctms, String wbsCode, List<String> products, List<String> therapeuticAreas, List<String> indications, List<String> trialTypes, List<String> studyStatuses, List<String> subjectTypes, List<String> pediatricStudies,
            List<String> specIndications, List<String> impacts, List<String> SRTs, List<String> teamMember, List<String> GNEs, List<String> inclusiveResearch) {
        System.debug('----- INFREP Start ' + Datetime.now());
        CFAR_SearchParameters searchParams = getSearchParams(studyNr, ctms, wbsCode, products, therapeuticAreas, indications, trialTypes, studyStatuses, subjectTypes, pediatricStudies,
                specIndications, impacts, SRTs, teamMember, GNEs, inclusiveResearch);
        List<CFAR_Trial_gne__c> trials = searchForTrialsInfrep(searchParams);
        System.debug('----- INFREP search end ' + Datetime.now());
        InfrepTabData infrep = new InfrepTabData();
        infrep.infreps = convertTrialsForInfrep(trials);
        System.debug('----- INFREP conversion end ' + Datetime.now());
        return infrep;
    }

    @RemoteAction
    global static BOMTabData getBOMTabData(String studyNr, String ctms, String wbsCode, List<String> products, List<String> therapeuticAreas, List<String> indications, List<String> trialTypes, List<String> studyStatuses, List<String> subjectTypes, List<String> pediatricStudies,
            List<String> specIndications, List<String> impacts, List<String> SRTs, List<String> teamMember, List<String> GNEs, List<String> inclusiveResearch) {
        CFAR_SearchParameters searchParams = getSearchParams(studyNr, ctms, wbsCode, products, therapeuticAreas, indications, trialTypes, studyStatuses, subjectTypes, pediatricStudies,
                specIndications, impacts, SRTs, teamMember, GNEs, inclusiveResearch);
        List<CFAR_Trial_gne__c> trials = searchForTrialsBOM(searchParams);
        BOMTabData bom = new BOMTabData();
        bom.boms = convertTrialsForBOM(trials);
        return bom;
    }

    @RemoteAction
    global static BudgetSummaryTabData getBudgetSummaryTabData(String studyNr, String ctms, String wbsCode, List<String> products, List<String> therapeuticAreas, List<String> indications, List<String> trialTypes, List<String> studyStatuses, List<String> subjectTypes, List<String> pediatricStudies,
            List<String> specIndications, List<String> impacts, List<String> SRTs, List<String> teamMember, List<String> GNEs, List<String> inclusiveResearch) {
        System.debug('----- BS start ' + Datetime.now());
        CFAR_SearchParameters searchParams = getSearchParams(studyNr, ctms, wbsCode, products, therapeuticAreas, indications, trialTypes, studyStatuses, subjectTypes, pediatricStudies,
                specIndications, impacts, SRTs, teamMember, GNEs, inclusiveResearch);
        List<CFAR_Trial_gne__c> trials = searchForTrialsBudgetSummary(searchParams);
        System.debug('----- BS search end ' + Datetime.now());
        BudgetSummaryTabData bs = convertTrialsForBS(trials);
        System.debug('----- BS convertion end ' + Datetime.now());
        //bs.projectionsTotal = countTotalProjections(bs);
        System.debug('----- BS total proj end ' + Datetime.now());
        return bs;
    }

    @RemoteAction
    global static AccrualSummaryTabData getAccrualSummaryTabData(String studyNr, String ctms, String wbsCode, List<String> products, List<String> therapeuticAreas, List<String> indications, List<String> trialTypes, List<String> studyStatuses, List<String> subjectTypes, List<String> pediatricStudies,
            List<String> specIndications, List<String> impacts, List<String> SRTs, List<String> teamMember, List<String> GNEs, List<String> inclusiveResearch) {
        System.debug('----- ACCRUAL start ' + Datetime.now());
        CFAR_SearchParameters searchParams = getSearchParams(studyNr, ctms, wbsCode, products, therapeuticAreas, indications, trialTypes, studyStatuses, subjectTypes, pediatricStudies,
                specIndications, impacts, SRTs, teamMember, GNEs, inclusiveResearch);
        List<CFAR_Trial_gne__c> trials = searchForTrialsAccruals(searchParams);
        System.debug('----- ACCRUAL search end ' + Datetime.now());
        AccrualSummaryTabData accs = new AccrualSummaryTabData();
        accs.accruals = convertTrialsForAccrual(trials);
        System.debug('----- ACCRUAL convertion end ' + Datetime.now());
        return accs;
    }

    @RemoteAction
    global static PaymentsTabData getPaymentTabData(String studyNr, String ctms, String wbsCode, List<String> products, List<String> therapeuticAreas, List<String> indications, List<String> trialTypes, List<String> studyStatuses, List<String> subjectTypes, List<String> pediatricStudies,
            List<String> specIndications, List<String> impacts, List<String> SRTs, List<String> teamMember, List<String> GNEs, List<String> inclusiveResearch) {
        System.debug('----- PAYMENT start ' + Datetime.now());
        CFAR_SearchParameters searchParams = getSearchParams(studyNr, ctms, wbsCode, products, therapeuticAreas, indications, trialTypes, studyStatuses, subjectTypes, pediatricStudies,
                specIndications, impacts, SRTs, teamMember, GNEs, inclusiveResearch);
        List<CFAR_Trial_gne__c> trials = searchForTrialsPayments(searchParams);
        System.debug('----- PAYMENT search end' + Datetime.now());
        PaymentsTabData paym = new PaymentsTabData();
        paym.payments = convertTrialsForPayments(trials);
        System.debug('----- PAYMENT cnvertion end ' + Datetime.now());
        paym.totals = countTotalPayments(paym);
        System.debug('----- PAYMENT coount total end ' + Datetime.now());
        return paym;
    }

    @RemoteAction
    global static PublicationTabData getPublicationTabData(String studyNr, String ctms, String wbsCode, List<String> products, List<String> therapeuticAreas, List<String> indications, List<String> trialTypes, List<String> studyStatuses, List<String> subjectTypes, List<String> pediatricStudies,
            List<String> specIndications, List<String> impacts, List<String> SRTs, List<String> teamMember, List<String> GNEs, List<String> inclusiveResearch) {
        System.debug('----- PUBLICATION start ' + Datetime.now());
        CFAR_SearchParameters searchParams = getSearchParams(studyNr, ctms, wbsCode, products, therapeuticAreas, indications, trialTypes, studyStatuses, subjectTypes, pediatricStudies,
                specIndications, impacts, SRTs, teamMember, GNEs, inclusiveResearch);
        List<CFAR_Trial_gne__c> trials = searchForTrialsPublication(searchParams);
        System.debug('----- PUBLICATION search end' + Datetime.now());
        PublicationTabData pub = new PublicationTabData();
        pub.publications = convertTrialsForPublication(trials);
        System.debug('----- PUBLICATION convertion end ' + Datetime.now());
        return pub;
    }

    @RemoteAction
    global static CommentTabData getCommentsTabData(String studyNr, String ctms, String wbsCode, List<String> products, List<String> therapeuticAreas, List<String> indications, List<String> trialTypes, List<String> studyStatuses, List<String> subjectTypes, List<String> pediatricStudies,
            List<String> specIndications, List<String> impacts, List<String> SRTs, List<String> teamMember, List<String> GNEs, List<String> inclusiveResearch) {
        System.debug('----- COMMENTS start ' + Datetime.now());
        CFAR_SearchParameters searchParams = getSearchParams(studyNr, ctms, wbsCode, products, therapeuticAreas, indications, trialTypes, studyStatuses, subjectTypes, pediatricStudies,
                specIndications, impacts, SRTs, teamMember, GNEs, inclusiveResearch);
        List<CFAR_Trial_gne__c> trials = searchForTrialsComments(searchParams);
        System.debug('----- COMMENTS search end' + Datetime.now());
        CommentTabData comm = new CommentTabData();
        comm.comments = convertTrialsForComments(trials);
        System.debug('----- COMMENTS convertion end ' + Datetime.now());
        return comm;
    }

    public static List<CFAR_Filter_Option_gne__c> convertFilterOptions(String filterId, String studyNr, String ctms, String wbsCode, List<String> products, List<String> therapeuticAreas, List<String> indications, List<String> trialTypes, List<String> studyStatuses, List<String> subjectTypes, List<String> pediatricStudies,
            List<String> specIndications, List<String> impacts, List<String> SRTs, List<String> teamMembers, List<String> GNEs, List<String> inclusiveResearch) {
        List<CFAR_Filter_Option_gne__c> fOptions = new List<CFAR_Filter_Option_gne__c>();
        if (String.isNotBlank(studyNr))
            fOptions.add(new CFAR_Filter_Option_gne__c(CFAR_Filter_ref_gne__c = filterId, Field_Name_gne__c = 'Name', Value_gne__c = studyNr));
        if (String.isNotBlank(ctms))
            fOptions.add(new CFAR_Filter_Option_gne__c(CFAR_Filter_ref_gne__c = filterId, Field_Name_gne__c = 'CTMS_gne__c', Value_gne__c = ctms));
        if (String.isNotBlank(wbsCode))
            fOptions.add(new CFAR_Filter_Option_gne__c(CFAR_Filter_ref_gne__c = filterId, Field_Name_gne__c = 'WBS', Value_gne__c = wbsCode));
        if (products != null && !products.isEmpty()) {
            for (String product : products) {
                fOptions.add(new CFAR_Filter_Option_gne__c(CFAR_Filter_ref_gne__c = filterId, Field_Name_gne__c = 'Product_ref_gne__c', Value_gne__c = product));
            }
        }
        if (therapeuticAreas != null && !therapeuticAreas.isEmpty()) {
            for (String tArea : therapeuticAreas) {
                fOptions.add(new CFAR_Filter_Option_gne__c(CFAR_Filter_ref_gne__c = filterId, Field_Name_gne__c = 'Therapeutic_Area_ref_gne__c', Value_gne__c = tArea));
            }
        }
        if (indications != null && !indications.isEmpty()) {
            for (String indication : indications) {
                fOptions.add(new CFAR_Filter_Option_gne__c(CFAR_Filter_ref_gne__c = filterId, Field_Name_gne__c = 'CFAR_General_Indication_ref_gne__c', Value_gne__c = indication));
            }
        }
        if (trialTypes != null && !trialTypes.isEmpty()) {
            for (String tt : trialTypes) {
                fOptions.add(new CFAR_Filter_Option_gne__c(CFAR_Filter_ref_gne__c = filterId, Field_Name_gne__c = 'Trial_Type_ref_gne__c', Value_gne__c = tt));
            }
        }
        if (studyStatuses != null && !studyStatuses.isEmpty()) {
            for (String status : studyStatuses) {
                fOptions.add(new CFAR_Filter_Option_gne__c(CFAR_Filter_ref_gne__c = filterId, Field_Name_gne__c = 'Trial_Status_ref_gne__c', Value_gne__c = status));
            }
        }
        if (subjectTypes != null && !subjectTypes.isEmpty()) {
            for (String sType : subjectTypes) {
                fOptions.add(new CFAR_Filter_Option_gne__c(CFAR_Filter_ref_gne__c = filterId, Field_Name_gne__c = 'Subject_Type__c', Value_gne__c = sType));
            }
        }
        if (pediatricStudies != null && !pediatricStudies.isEmpty()) {
            for (String pStudy : pediatricStudies) {
                fOptions.add(new CFAR_Filter_Option_gne__c(CFAR_Filter_ref_gne__c = filterId, Field_Name_gne__c = 'Pediatric_Study_gne__c', Value_gne__c = pStudy));
            }
        }
        if (specIndications != null && !specIndications.isEmpty()) {
            for (String specIndication : specIndications) {
                fOptions.add(new CFAR_Filter_Option_gne__c(CFAR_Filter_ref_gne__c = filterId, Field_Name_gne__c = 'CFAR_Specific_Indication_ref_gne__c', Value_gne__c = specIndication));
            }
        }
        if (impacts != null && !impacts.isEmpty()) {
            for (String impact : impacts) {
                fOptions.add(new CFAR_Filter_Option_gne__c(CFAR_Filter_ref_gne__c = filterId, Field_Name_gne__c = 'Impacts_gne__c', Value_gne__c = impact));
            }
        }
        if (SRTs != null && !SRTs.isEmpty()) {
            for (String SRT : SRTs) {
                fOptions.add(new CFAR_Filter_Option_gne__c(CFAR_Filter_ref_gne__c = filterId, Field_Name_gne__c = 'SRT_Team_ref_gne__c', Value_gne__c = SRT));
            }
        }
        if (teamMembers != null && !teamMembers.isEmpty()) {
            for (String tm : teamMembers) {
                fOptions.add(new CFAR_Filter_Option_gne__c(CFAR_Filter_ref_gne__c = filterId, Field_Name_gne__c = 'teamMember', Value_gne__c = tm));
            }
        }
        if (GNEs != null && !GNEs.isEmpty()) {
            for (String GNE : GNEs) {
                fOptions.add(new CFAR_Filter_Option_gne__c(CFAR_Filter_ref_gne__c = filterId, Field_Name_gne__c = 'GNE', Value_gne__c = gne));
            }
        }
        if (inclusiveResearch != null && !inclusiveResearch.isEmpty()) {
            for (String ir : inclusiveResearch) {
                fOptions.add(new CFAR_Filter_Option_gne__c(CFAR_Filter_ref_gne__c = filterId, Field_Name_gne__c = 'Inclusive_Research_gne__c', Value_gne__c = ir));
            }
        }
        return fOptions;
    }

    public static CFAR_SearchParameters getSearchParams(String studyNr, String ctms, String wbsCode, List<String> products, List<String> therapeuticAreas, List<String> indications, List<String> trialTypes, List<String> studyStatuses, List<String> subjectTypes, List<String> pediatricStudies,
            List<String> specIndications, List<String> impacts, List<String> SRTs, List<String> teamMembers, List<String> GNEs, List<String> inclusiveResearch) {
        CFAR_SearchParameters searchParms = new CFAR_SearchParameters();
        searchParms.sortExpression = 'Name';
        searchParms.sortDirection = 'asc';
        if (products != null && !products.isEmpty())
            searchParms.andInParameters.put('Product_ref_gne__c', products);
        if (therapeuticAreas != null && !therapeuticAreas.isEmpty())
            searchParms.andInParameters.put('Therapeutic_Area_ref_gne__c', therapeuticAreas);
        if (indications != null && !indications.isEmpty()) {
            List<CFAR_General_Indication_for_Trial_gne__c> gis = [Select CFAR_Trial_ref_gne__c, CFAR_General_Indication_ref_gne__c from CFAR_General_Indication_for_Trial_gne__c where CFAR_General_Indication_ref_gne__c in :indications];
            Set<String> trialIdsForGI = new Set<String>();
            for (CFAR_General_Indication_for_Trial_gne__c gi : gis) {
                trialIdsForGI.add(gi.CFAR_Trial_ref_gne__c);
            }
            searchParms.andInParameters.put('Id', new List<String>(trialIdsForGI));
        }
        if (trialTypes != null && !trialTypes.isEmpty())
            searchParms.andInParameters.put('Trial_Type_ref_gne__c', trialTypes);
        if (studyStatuses != null && !studyStatuses.isEmpty())
            searchParms.andInParameters.put('Trial_Status_ref_gne__c', studyStatuses);
        if (subjectTypes != null && !subjectTypes.isEmpty())
            searchParms.orEqualsParameters.put('Subject_Type__c', subjectTypes);
        if (String.isNotBlank(studyNr))
            searchParms.andLikeParameters.put('Name', studyNr);
        if (String.isNotBlank(ctms))
            searchParms.andLikeParameters.put('CTMS_gne__c', ctms);
        if (pediatricStudies != null && !pediatricStudies.isEmpty()) {
            searchParms.orEqualsParameters.put('Pediatric_Study_gne__c', pediatricStudies);
        }
        if (String.isNotBlank(wbsCode)) {
            Map<String, String> WBSesMap = new Map<String, String>();
            WBSesMap.put('CFAR_WBS_ref_gne__r.GSR_WBS_gne__c', wbsCode);
            WBSesMap.put('CFAR_WBS_ref_gne__r.Old_WBS_Code_gne__c', wbsCode);
            searchParms.orLikeParameters.put('WBS', WBSesMap);
        }
        if (specIndications != null && !specIndications.isEmpty()) {
            List<CFAR_Specific_Indication_for_Trial_gne__c> sis = [SELECT CFAR_Trial_ref_gne__c, CFAR_Specific_Indication_ref_gne__c FROM CFAR_Specific_Indication_for_Trial_gne__c WHERE CFAR_Specific_Indication_ref_gne__c IN :specIndications];
            Set<String> trialIdsForSI = new Set<String>();
            for (CFAR_Specific_Indication_for_Trial_gne__c si : sis) {
                trialIdsForSi.add((String) si.CFAR_Trial_ref_gne__c);
            }
            if (searchParms.andInParameters.containsKey('Id') && !searchParms.andInParameters.get('Id').isEmpty()) {
                trialIdsForSI.retainAll(searchParms.andInParameters.get('Id'));
                searchParms.andInParameters.put('Id', new List<String>(trialIdsForSI));
            } else {
                searchParms.andInParameters.put('Id', new List<String>(trialIdsForSI));
            }
        }
        if (impacts != null && !impacts.isEmpty()) {
            searchParms.includesAny.put('Impacts_gne__c', impacts);
        }
        if (SRTs != null && !SRTs.isEmpty()) {
            searchParms.andInParameters.put('SRT_Team_ref_gne__c', SRTs);
        }
        if (teamMembers != null && !teamMembers.isEmpty()) {
            Set<String> tmTrialIds = CFAR_Utils.getTrialsForContacts(teamMembers);
            if (searchParms.andInParameters.containsKey('Id') && !searchParms.andInParameters.get('Id').isEmpty()) {
                tmTrialIds.retainAll(searchParms.andInParameters.get('Id'));
            }
            searchParms.andInParameters.put('Id', new List<String>(tmTrialIds));
        }
        if (GNEs != null && !GNEs.isEmpty()) {
            searchParms.andInParameters.put('Dollar_and_Drug_ref_gne__c', GNEs);
        }
        if (inclusiveResearch != null && !inclusiveResearch.isEmpty()) {
            searchParms.andInParameters.put('Inclusive_Research_gne__c', inclusiveResearch);
        }
        CFAR_DAO.addNullToNonPediatricStudyParam(searchParms);
        return searchParms;
    }

    public static List<CFAR_Trial_gne__c> searchForTrialsInfrep(CFAR_SearchParameters searchParms) {
        return CFAR_DAO.getInfrepTrialForReportsControler(searchParms);
    }

    public static List<CFAR_Trial_gne__c> searchForTrialsBOM(CFAR_SearchParameters searchParms) {
        return CFAR_DAO.getBOMTrialForReportsControler(searchParms);
    }

    public static List<CFAR_Trial_gne__c> searchForTrialsAccruals(CFAR_SearchParameters searchParms) {
        return CFAR_DAO.getAccrualsTrialForReportsControler(searchParms);
    }

    public static List<CFAR_Trial_gne__c> searchForTrialsBudgetSummary(CFAR_SearchParameters searchParms) {
        return CFAR_DAO.getBudgetSummaryTrialForReportsControler(searchParms);
    }

    public static List<CFAR_Trial_gne__c> searchForTrialsPayments(CFAR_SearchParameters searchParms) {
        return CFAR_DAO.getPaymentsTrialForReportsControler(searchParms);
    }

    public static List<CFAR_Trial_gne__c> searchForTrialsProgramSummary(CFAR_SearchParameters searchParms) {
        return CFAR_DAO.getProgramSummaryTrialForReportsControler(searchParms);
    }

    public static List<CFAR_Trial_gne__c> searchForTrialsPublication(CFAR_SearchParameters searchParms) {
        return CFAR_DAO.getPublicationTrialForReportsControler(searchParms);
    }

    public static List<CFAR_Trial_gne__c> searchForTrialsComments(CFAR_SearchParameters searchParms) {
        return CFAR_DAO.getCommentsTrialForReportsControler(searchParms);
    }

    public static List<Payment> convertTrialsForPayments(List<CFAR_Trial_gne__c> trials) {
        List<Payment> payments = new List<Payment>();
        if (trials == null || trials.isEmpty())
            return payments;
        CFAR_Budget_CPS_Payments_gne__c[] relatedBudgetPayments = [
                SELECT id, Budget_Contract_ref_gne__r.Team_Member_ref_gne__r.frm_Function_Role_gne__c, Budget_Contract_ref_gne__r.Team_Member_ref_gne__r.frm_Name_gne__c,
                        frm_sfdc_Completed_gne__c, Budget_Contract_ref_gne__r.Team_Member_ref_gne__r.CFAR_Trial_ref_gne__c, Budget_Contract_ref_gne__r.PO_Number_gne__c, Check_Num_gne__c, Invoice_Amount_gne__c, Invoice_gne__c,
                        Invoice_Submitted_Date_gne__c, Paid_On_gne__c, frm_Trial_Id_gne__c, Payment_Explanation_Text_gne__c
                FROM CFAR_Budget_CPS_Payments_gne__c
                WHERE (Budget_Contract_ref_gne__r.Team_Member_ref_gne__r.CFAR_Trial_ref_gne__c IN :trials AND Invoice_Amount_gne__c != NULL)
                ORDER BY Planned_Date_gne__c asc
        ];
        Map<String, Double> amountPerInvoice = new Map<String, Double> ();
        for (CFAR_Budget_CPS_Payments_gne__c q : relatedBudgetPayments) {
            if (q.Invoice_gne__c != null) {
                Decimal suma = amountPerInvoice.get(String.valueOf(q.Invoice_gne__c) + String.valueOf(q.frm_Trial_Id_gne__c)) != null ? Decimal.valueOf(amountPerInvoice.get(String.valueOf(q.Invoice_gne__c) + String.valueOf(q.frm_Trial_Id_gne__c))) : 0;
                suma += q.Invoice_Amount_gne__c;
                amountPerInvoice.put(String.valueOf(q.Invoice_gne__c) + String.valueOf(q.frm_Trial_Id_gne__c), suma);
            }
        }

        Map<Id, List<CFAR_Budget_CPS_Payments_gne__c>> budgetPayments = new Map<Id, List<CFAR_Budget_CPS_Payments_gne__c>>();
        for (CFAR_Budget_CPS_Payments_gne__c paymnt : relatedBudgetPayments) {
            Id trialId = paymnt.Budget_Contract_ref_gne__r.Team_Member_ref_gne__r.CFAR_Trial_ref_gne__c;
            if (budgetPayments.containsKey(trialId)) {
                budgetPayments.get(trialId).add(paymnt);
            } else {
                budgetPayments.put(trialId, new List<CFAR_Budget_CPS_Payments_gne__c>());
                budgetPayments.get(trialId).add(paymnt);
            }
        }

        for (CFAR_Trial_gne__c trial : trials) {
            String csmMember = CFAR_Utils.customEscape(trial.frm_Genentech_Primary_Contact_ref_gne__c);
            String csaMember = '';
            for (CFAR_Team_Member_gne__c tm : trial.CFAR_Team_Members__r) {
                if (tm.frm_Function_Role_gne__c == CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_ASSOCIATE) {
                    csaMember += (String.isBlank(csaMember)) ? tm.frm_Name_gne__c : '; ' + tm.frm_Name_gne__c;
                }
            }
            if (budgetPayments.containsKey(trial.Id)) {
                for (CFAR_Budget_CPS_Payments_gne__c p : budgetPayments.get(trial.Id)) {
                    Payment payment = new Payment();
                    payment.amountPaid = p.Invoice_Amount_gne__c;
                    payment.datePaid = p.Paid_On_gne__c == null ? '' : String.valueOf(((Datetime) p.Paid_On_gne__c).formatGMT('MM/dd/yyyy')); // ???
                    payment.studyNo = getProtocolNumber(trial);
                    payment.gStarsNo = trial.Name;
                    payment.trialType = trial.frm_Trial_Type_ref_gne__c;
                    payment.CSM = csmMember;
                    payment.CSA = csaMember;
                    payment.studyStatus = trial.frm_Trial_Status_ref_gne__c;
                    payment.investigator = p.Budget_Contract_ref_gne__r.Team_Member_ref_gne__r.frm_Name_gne__c;
                    payment.memberRole = p.Budget_Contract_ref_gne__r.Team_Member_ref_gne__r.frm_Function_Role_gne__c.split(' ').get(0);
                    payment.paymentPurpose = p.Payment_Explanation_Text_gne__c;
                    payment.poNumber = p.Budget_Contract_ref_gne__r.PO_Number_gne__c;
                    payment.wbs = trial.CFAR_WBS_ref_gne__r.Old_WBS_Code_gne__c;
                    payment.newWbs = trial.CFAR_WBS_ref_gne__r.GSR_WBS_gne__c;
                    payment.referenceNumber = String.isBlank(p.Check_Num_gne__c) ? '' : p.Check_Num_gne__c; // ???
                    payment.yearQuarter = p.Invoice_Submitted_Date_gne__c == null ? '' : '' + p.Invoice_Submitted_Date_gne__c.year() + ' Q' + determineQuarter(p.Invoice_Submitted_Date_gne__c);
                    payment.ctmsNumber = trial.CTMS_gne__c;
                    payment.invoiceNumber = p.Invoice_gne__c;
                    payment.invoiceSum = amountPerInvoice.get(p.Invoice_gne__c + p.frm_Trial_Id_gne__c);
                    payments.add(payment);
                }
            }
        }
        return payments;
    }

    public static Integer determineQuarter(Date dateToCheck) {
        if (dateToCheck.month() <= 3) return 1;
        if (dateToCheck.month() > 3 && dateToCheck.month() <= 6) return 2;
        if (dateToCheck.month() > 6 && dateToCheck.month() <= 9) return 3;
        return 4;
    }

    public static List<TrialData> convertTrialsForPS(List<CFAR_Trial_gne__c> trials) {
        if (trials == null || trials.isEmpty())
            return new List<TrialData>();
        List<TrialData> tData = new List<TrialData>();
        for (CFAR_Trial_gne__c trial : trials) {
            TrialData t = new TrialData();
            Boolean activeInvestigator = false;
            Boolean activeMSL = false;
            Boolean activeMSD = false;
            String medicalScienceDirectorName;
            if (!trial.CFAR_Team_Members__r.isEmpty()) {
                for (CFAR_Team_Member_gne__c tm : trial.CFAR_Team_Members__r) {
                    if (trial.frm_Investigator_ref_gne__c != null && tm.frm_Function_Role_gne__c == 'PI = Primary (or Principal) Investigator' && (tm.Contact_address_ref_gne__r.CFAR_Contact_ref_gne__c == trial.Investigator_ref_gne__c)) {
                        activeInvestigator = true;
                    }
                    if (trial.frm_MSL_ref_gne__c != null && tm.frm_Function_Role_gne__c == 'MSL = Medical Science Liaison' && (tm.Contact_address_ref_gne__r.CFAR_Contact_ref_gne__c == trial.MSL_ref_gne__c)) {
                        activeMSL = true;
                    }
                    if (tm.frm_Function_Role_gne__c == 'MSD = Medical Science Director') {
                        activeMSD = true;
                        medicalScienceDirectorName = tm.frm_Name_gne__c;
                    }
                }
            }
            t.protocolNumber = getProtocolNumber(trial);
            t.investigatorSponsor = activeInvestigator ? trial.frm_Investigator_ref_gne__c : null;
            t.trialStatus = trial.Trial_Status_ref_gne__r.Name;
            t.msl = activeMSL ? trial.frm_MSL_ref_gne__c : null;
            t.msd = activeMSD ? medicalScienceDirectorName : null;
            t.ctmsMLNumber = trial.CTMS_gne__c;
            t.primaryIndication = trial.CFAR_General_Indication_ref_gne__r.Name;
            t.sampleSize = trial.Planned_Enrollment_gne__c;
            t.totalEnrolled = trial.Enrolled_Sum_rollup_gne__c;
            t.gneSupport = trial.Dollar_and_Drug_ref_gne__r.Name;
            tData.add(t);
        }
        return tData;
    }

    private static Set<String> getSetOfIds(List<SObject> objects) {
        Set<String> idSet = new Set<String>();
        for (sObject obj : objects) {
            idSet.add(String.valueOf(obj.Id).substring(0, 15));
        }
        return idSet;
    }

    private static List<Map<Id, Map<Id, Decimal>>> getTrialsList2RateTableTotalAmountMap(Set<String> trials) {
        List<Map<Id, Map<Id, Decimal>>> trialsList2tmAmount = new List<Map<Id, Map<Id, Decimal>>> ();
        Map<Id, Map<Id, Decimal>> trial2tmAmountMapForSubject = new Map<Id, Map<Id, Decimal>>();
        Map<Id, Map<Id, Decimal>> trial2tmAmountMapForInvoiceable = new Map<Id, Map<Id, Decimal>>();
        for (CFAR_Rate_Table_gne__c rateTable : [
                SELECT Id, Total_Amount_gne__c, frm_Trial_Id_gne__c, Payment_Type_gne__c, Budget_Contract_ref_gne__r.Team_Member_ref_gne__c
                FROM CFAR_Rate_Table_gne__c
                WHERE frm_Trial_Id_gne__c IN :trials
                AND Payment_Type_gne__c IN ('Invoiceable', 'Subject') AND Status_gne__c = 'Active' AND Total_Amount_gne__c != NULL AND Total_Amount_gne__c != 0
        ]) {
            if (rateTable.Payment_Type_gne__c == 'Subject') {
                if (!trial2tmAmountMapForSubject.containsKey(rateTable.frm_Trial_Id_gne__c)) {
                    Map<Id, Decimal> tm2AmountMap = new Map<Id, Decimal>();
                    tm2AmountMap.put(rateTable.Budget_Contract_ref_gne__r.Team_Member_ref_gne__c, rateTable.Total_Amount_gne__c);
                    trial2tmAmountMapForSubject.put(rateTable.frm_Trial_Id_gne__c, tm2AmountMap);
                } else {
                    Map<Id, Decimal> tm2AmountMap = trial2tmAmountMapForSubject.get(rateTable.frm_Trial_Id_gne__c);
                    Decimal currentSum = tm2AmountMap.containsKey(rateTable.Budget_Contract_ref_gne__r.Team_Member_ref_gne__c) ? tm2AmountMap.get(rateTable.Budget_Contract_ref_gne__r.Team_Member_ref_gne__c) : 0;
                    currentSum += rateTable.Total_Amount_gne__c;
                    tm2AmountMap.put(rateTable.Budget_Contract_ref_gne__r.Team_Member_ref_gne__c, currentSum);
                    trial2tmAmountMapForSubject.put(rateTable.frm_Trial_Id_gne__c, tm2AmountMap);
                }
            } else {
                if (!trial2tmAmountMapForInvoiceable.containsKey(rateTable.frm_Trial_Id_gne__c)) {
                    Map<Id, Decimal> tm2AmountMap = new Map<Id, Decimal>();
                    tm2AmountMap.put(rateTable.Budget_Contract_ref_gne__r.Team_Member_ref_gne__c, rateTable.Total_Amount_gne__c);
                    trial2tmAmountMapForInvoiceable.put(rateTable.frm_Trial_Id_gne__c, tm2AmountMap);
                } else {
                    Map<Id, Decimal> tm2AmountMap = trial2tmAmountMapForInvoiceable.get(rateTable.frm_Trial_Id_gne__c);
                    Decimal currentSum = tm2AmountMap.containsKey(rateTable.Budget_Contract_ref_gne__r.Team_Member_ref_gne__c) ? tm2AmountMap.get(rateTable.Budget_Contract_ref_gne__r.Team_Member_ref_gne__c) : 0;
                    currentSum += rateTable.Total_Amount_gne__c;
                    tm2AmountMap.put(rateTable.Budget_Contract_ref_gne__r.Team_Member_ref_gne__c, currentSum);
                    trial2tmAmountMapForInvoiceable.put(rateTable.frm_Trial_Id_gne__c, tm2AmountMap);
                }
            }
        }
        trialsList2tmAmount.add(trial2tmAmountMapForSubject);
        trialsList2tmAmount.add(trial2tmAmountMapForInvoiceable);
        return trialsList2tmAmount;
    }

    private static Map<Id, Decimal> getTeamMember2LastContractAmount(Set<String> trialIds) {
        Map<Id, Decimal> tm2Amount = new Map<Id, Decimal>();
        for (CFAR_Budget_Contract_Tracking_gne__c con : [
                SELECT Amount_gne__c, Budget_Contract_ref_gne__r.Team_Member_ref_gne__c
                FROM CFAR_Budget_Contract_Tracking_gne__c
                WHERE frm_Trial_Id_gne__c IN :trialIds
                AND Type_ref_gne__r.Name != :CFAR_BudgetContractTrackingHelper.TYPE_CONTRACT_CANCELED
                ORDER BY Budget_Contract_ref_gne__r.Team_Member_ref_gne__c, CreatedDate desc
        ]) {
            if (!tm2Amount.containsKey(con.Budget_Contract_ref_gne__r.Team_Member_ref_gne__c)) {
                tm2Amount.put(con.Budget_Contract_ref_gne__r.Team_Member_ref_gne__c, con.Amount_gne__c);
            }
        }
        return tm2Amount;
    }

    private static Map<Id, List<CFAR_Team_Member_gne__c>> getTrial2TeamMembers(List<CFAR_Trial_gne__c> trials, Set<Id> teamMembersId) {
        Map<Id, List<CFAR_Team_Member_gne__c>> tm2Amount = new Map<Id, List<CFAR_Team_Member_gne__c>>();
        for (CFAR_Team_Member_gne__c tm : [
                SELECT Id, contact_address_ref_gne__r.CFAR_Contact_ref_gne__r.Search_Name__c, Current_Amount_gne__c, frm_Function_Role_gne__c,
                        frm_Name_gne__c, CFAR_Trial_ref_gne__c, Dollar_and_Drug_ref_gne__r.Name, Dollar_and_Drug_ref_gne__c, Total_Paid_gne__c, Balance_gne__c
                FROM CFAR_Team_Member_gne__c
                WHERE CFAR_Trial_ref_gne__c IN :trials AND (
                        (frm_Function_Role_gne__c = :CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_ASSOCIATE and frm_Is_Inactive_gne__c = false)
                        OR (frm_Function_Role_gne__c = :CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_MANAGER and Is_Trial_Primary_Contact_gne__c = true)
                        OR (Id IN :teamMembersId))
        ]) {
            if (tm2Amount.containsKey(tm.CFAR_Trial_ref_gne__c)) {
                tm2Amount.get(tm.CFAR_Trial_ref_gne__c).add(tm);
            } else {
                tm2Amount.put(tm.CFAR_Trial_ref_gne__c, new List<CFAR_Team_Member_gne__c>{tm});
            }
        }
        return tm2Amount;
    }

    public static Accrual fillAccrualData(CFAR_Trial_gne__c trial, Map<Id, Map<Id, Decimal>> trial2RateTableTotalAmountMapForSubject, Map<Id, Map<Id, Decimal>> trial2RateTableTotalAmountMapForInvoicable) {
        Accrual acc = new Accrual();
        Integer year = Date.today().year();
        acc.trialType = trial.frm_Trial_Type_ref_gne__c;
        acc.sfdcName = trial.Name;
        acc.studyNo = getProtocolNumber(trial);
        acc.wbs = trial.CFAR_WBS_ref_gne__r.Old_WBS_Code_gne__c;
        acc.newWbs = trial.CFAR_WBS_ref_gne__r.GSR_WBS_gne__c;
        acc.indication = trial.frm_General_Indication_ref_gne__c;
        acc.studyStatus = trial.frm_Trial_Status_ref_gne__c;
        acc.activationDate = (!trial.CFAR_Milestone_Activities__r.isEmpty() && trial.CFAR_Milestone_Activities__r[0].Actual_Date_gne__c != null) ?
                String.valueOf(Datetime.newInstance(trial.CFAR_Milestone_Activities__r[0].Actual_Date_gne__c.year(),
                        trial.CFAR_Milestone_Activities__r[0].Actual_Date_gne__c.month(),
                        trial.CFAR_Milestone_Activities__r[0].Actual_Date_gne__c.day()).formatGMT('MM/dd/yyyy')) : null;
        acc.sampleSize = trial.Planned_Enrollment_gne__c;
        acc.totalEnrolled = trial.Enrolled_Sum_rollup_gne__c;
        acc.ctmsNumber = trial.CTMS_gne__c;
        Map<Integer, Decimal> projectedSpends = new Map<Integer, Decimal>();
        for (CFAR_Budget_CPS_Projection_gne__c p : trial.CFAR_Budget_Projections__r) {
            if (Integer.valueOf(p.Year_gne__c) == year) {
                acc.q1ProjectedSpend = p.Quarter_1_gne__c;
                acc.q2ProjectedSpend = p.Quarter_2_gne__c;
                acc.q3ProjectedSpend = p.Quarter_3_gne__c;
                acc.q4ProjectedSpend = p.Quarter_4_gne__c;
                acc.comments = p.Comments_gne__c;
            }
            projectedSpends.put(Integer.valueOf(p.Year_gne__c), p.frm_Total_Amount_gne__c);
        }
        Set<Integer> accrualFollowingYears = new Set<Integer>();
        for (CFAR_Projected_Subject_Accrual_gne_ref__c accrual : trial.CFAR_Projected_Subject_Accrual__r) {
            Integer y = Integer.valueOf(accrual.CFAR_Year_gne__c);
            if (year == y) {
                acc.patientAccrual = accrual.Projected_Accrual_gne__c;
            } else {
                Decimal projSpend = projectedSpends.containsKey(y) ? projectedSpends.get(y) : null;
                acc.projections.add(new AccrualProjection(y, accrual.Projected_Accrual_gne__c == null ? 0 : accrual.Projected_Accrual_gne__c, null, projSpend));
                accrualFollowingYears.add(Integer.valueOf(accrual.CFAR_Year_gne__c));
            }
        }

        for (Integer i : projectedSpends.keySet()) {
            if (!accrualFollowingYears.contains(i) && i > year) {
                acc.projections.add(new AccrualProjection(i, 0, null, projectedSpends.get(i)));
            }
        }
        for (Integer i = acc.projections.size(); i < CFAR_TrialReport_Model.BUDGET_YEARS_LIMIT; i++) {
            acc.projections.add(new AccrualProjection(year + i + 1, 0, null, null));
        }
        acc.costPerSubject = 0;
        acc.enrollmentGoal = null;
        if (!trial.CFAR_Milestone_Activities__r.isEmpty()) {
            Date actDate = trial.CFAR_Milestone_Activities__r[0].Actual_Date_gne__c;
            if (actDate != null && actDate <= Date.today()) {
                Integer mb = actDate.monthsBetween(Date.Today());
                Date tmpDate = actDate.addMonths(mb);
                Integer db = tmpDate.daysBetween(Date.Today());
                acc.monthsActive = mb + (db > 15 ? 1 : 0);
            }
        } else {
            acc.monthsActive = 0;
        }

        acc.monthlyAccrualRate = (acc.monthsActive != null && acc.monthsActive != 0
                && trial.Enrolled_Sum_rollup_gne__c != null && trial.Enrolled_Sum_rollup_gne__c != 0)
                ? Decimal.valueOf(Double.valueOf(trial.Enrolled_Sum_rollup_gne__c / acc.monthsActive)).setScale(2) : null;
        acc.otherStudyName = trial.Brief_Title_gne__c;
        acc.year = year;
        acc.projectedEnrolled = null;
        acc.totalAmountPaidAsOfOctober2012 = null;
        acc.totalProjectedSpend = projectedSpends.containsKey(year) ? projectedSpends.get(year) : 0;
        return acc;
    }

    public static List<Accrual> convertTrialsForAccrual(List<CFAR_Trial_gne__c> trials) {
        if (trials == null || trials.isEmpty())
            return new List<Accrual>();
        List<Accrual> accruals = new List<Accrual>();
        Integer year = Date.today().year();
        Set<String> trialIds = getSetOfIds(trials);
        Map<Id, Decimal> tm2Amount = getTeamMember2LastContractAmount(trialIds);
        Map<Id, List<CFAR_Team_Member_gne__c>> trial2TeamMembers = getTrial2TeamMembers(trials, tm2Amount.keySet());
        List<Map<Id, Map<Id, Decimal>>> trials2RateTableTotalAmountMap = getTrialsList2RateTableTotalAmountMap(trialIds);
        Map<Id, Map<Id, Decimal>> trial2RateTableTotalAmountMapForSubject = trials2RateTableTotalAmountMap.get(0);
        Map<Id, Map<Id, Decimal>> trial2RateTableTotalAmountMapForInvoicable = trials2RateTableTotalAmountMap.get(1);
        List<CFAR_Budget_Contract_gne__c> budgetContracts = [SELECT PO_Number_gne__c, Team_Member_ref_gne__c FROM CFAR_Budget_Contract_gne__c WHERE Team_Member_ref_gne__c != null];
        Map<Id, String> teamMembersIdsForBudgetContractPoNumber = new Map<Id, String> ();
        for (CFAR_Budget_Contract_gne__c bc : budgetContracts) {
            teamMembersIdsForBudgetContractPoNumber.put(bc.Team_Member_ref_gne__c, bc.PO_Number_gne__c);
        }
        for (CFAR_Trial_gne__c trial : trials) {
            String csmMember = CFAR_Utils.customEscape(trial.frm_Genentech_Primary_Contact_ref_gne__c);
            String csaMember = '';
            String poData = '';
            List<CFAR_Team_Member_gne__c> teamMembers = trial2TeamMembers.get(trial.Id);
            if ((teamMembers != null) && !teamMembers.isEmpty()) {
                for (CFAR_Team_Member_gne__c tm : teamMembers) {
                    if (tm.frm_Function_Role_gne__c == CFAR_TeamMemberHelper.ROLE_CLINICAL_STUDY_ASSOCIATE) {
                        csaMember += (String.isBlank(csaMember)) ? tm.frm_Name_gne__c : '; ' + tm.frm_Name_gne__c;
                    }
                    if (teamMembersIdsForBudgetContractPoNumber.get(tm.Id) != null) {
                        poData = teamMembersIdsForBudgetContractPoNumber.get(tm.Id);
                    }
                }
                Boolean activeInvestigator = false;
                Accrual accForTrial = fillAccrualData(trial, trial2RateTableTotalAmountMapForSubject, trial2RateTableTotalAmountMapForInvoicable);
                for (CFAR_Team_Member_gne__c tm : trial2TeamMembers.get(trial.Id)) {
                    if (tm2Amount.containsKey(tm.Id)) {
                        Accrual acc = accForTrial.clone();
                        if (CFAR_TeamMemberHelper.isContractRole(tm.frm_Function_Role_gne__c)) {
                            activeInvestigator = true;
                            acc.totalStudyBudget = tm2Amount.containsKey(tm.Id) ? tm2Amount.get(tm.Id) : 0;// tm.Current_Amount_gne__c;
                            acc.totalAmountPaid = tm.Total_Paid_gne__c;
                            acc.investigator = tm.contact_address_ref_gne__r.CFAR_Contact_ref_gne__r.Search_Name__c;
                            acc.contractBalance = tm.Balance_gne__c;
                            acc.memberRole = tm.frm_Function_Role_gne__c.split(' ').get(0);
                            acc.CSM = csmMember;
                            acc.CSA = csaMember;
                            acc.po = poData;
                            acc.fundingDrugSupport = tm.Dollar_and_Drug_ref_gne__r.Name != null ? tm.Dollar_and_Drug_ref_gne__r.Name : '';
                            if (trial2RateTableTotalAmountMapForSubject.containsKey(trial.Id)) {
                                Map<Id, Decimal> tm2AmountForSubject = trial2RateTableTotalAmountMapForSubject.get(trial.Id);
                                if (tm2AmountForSubject.containsKey(tm.Id)) {
                                    acc.costPerSubject = Decimal.valueOf(Double.valueOf(tm2AmountForSubject.get(tm.Id))).setScale(2);
                                }
                            }
                            if (trial2RateTableTotalAmountMapForInvoicable.containsKey(trial.Id)) {
                                Map<Id, Decimal> tm2AmountForInvoice = trial2RateTableTotalAmountMapForInvoicable.get(trial.Id);
                                if (tm2AmountForInvoice.containsKey(tm.Id)) {
                                    acc.invoiceables = Decimal.valueOf(Double.valueOf(tm2AmountForInvoice.get(tm.Id))).setScale(2);
                                }
                            }
                            accruals.add(acc);
                        }
                        if (!activeInvestigator) {
                            acc.memberRole = tm.frm_Function_Role_gne__c;
                            acc.CSM = csmMember;
                            acc.CSA = csaMember;
                            acc.po = poData;
                            accruals.add(acc);
                        }
                    }
                }
            } else {
                Accrual acc = fillAccrualData(trial, trial2RateTableTotalAmountMapForSubject, trial2RateTableTotalAmountMapForInvoicable);
                acc.CSM = csmMember;
                acc.CSA = csaMember;
                acc.po = poData;
                accruals.add(acc);
            }
        }
        return accruals;
    }

    public static BudgetSummaryTabData convertTrialsForBS(List<CFAR_Trial_gne__c> trials) {
        Integer currentYear = System.today().year();
        BudgetSummaryTabData bs = new BudgetSummaryTabData(currentYear);
        bs.budgets = new List<Budget>();
        bs.projectionsTotal = new List<Projection>();
        if (trials == null || trials.isEmpty())
            return bs;
        List<Budget> budgetsWithGeneralWBS = new List<Budget>();
        List<Budget> otherBudgets = new List<Budget>();
        List<Budget> budgets = new List<Budget>();
        Map<Integer, Projection> projections = new Map<Integer, Projection>();
        for (Integer i = currentYear + 1; i <= currentYear + CFAR_TrialReport_Model.BUDGET_YEARS_LIMIT; i++) {
            projections.put(i, new Projection(i, 0, 0));
        }
        Map<String, Budget> rollupBudgetByGeneralWBS = new Map<String, Budget> ();
        for (CFAR_Trial_gne__c trial : trials) {
            Boolean hasGeneralWBS = false;
            Budget budget = new Budget();
            budget.studyNumber = getProtocolNumber(trial);
            budget.ctmsNumber = trial.CTMS_gne__c;
            budget.gStarsNo = trial.Name;
            budget.wbs = trial.CFAR_WBS_ref_gne__r.Old_WBS_Code_gne__c;
            budget.newWbs = trial.CFAR_WBS_ref_gne__r.GSR_WBS_gne__c;
            budget.CSM = CFAR_Utils.customEscape(trial.frm_Genentech_Primary_Contact_ref_gne__c);
            Boolean activeInvestigator = false;
            if (!trial.CFAR_Team_Members__r.isEmpty()) {
                for (CFAR_Team_Member_gne__c tm : trial.CFAR_Team_Members__r) {
                    if (trial.frm_Investigator_ref_gne__c != null && tm.frm_Function_Role_gne__c == 'PI = Primary (or Principal) Investigator' && (tm.Contact_address_ref_gne__r.CFAR_Contact_ref_gne__c == trial.Investigator_ref_gne__c)) {
                        activeInvestigator = true;
                    }
                    if (tm.frm_Function_Role_gne__c == 'CSA = Clinical Study Associate') {
                        budget.CSA = tm.frm_Name_gne__c;
                    }
                }
            }
            budget.trialType = trial.frm_Trial_Type_ref_gne__c;
            budget.investigatorSponsorName = activeInvestigator ? trial.frm_Investigator_ref_gne__c : null;
            Map<Integer, Decimal> projectedPatientAccruals = new Map<Integer, Decimal>();
            for (CFAR_Projected_Subject_Accrual_gne_ref__c accrual : trial.CFAR_Projected_Subject_Accrual__r) {
                projectedPatientAccruals.put(Integer.valueOf(accrual.CFAR_Year_gne__c), accrual.Projected_Accrual_gne__c);
            }
            if (budget.newWbs != null && budget.newWbs.length() >= 8) {
                if (budget.newWbs.substring(7, 8) == 's') {
                    hasGeneralWBS = true;
                    budget.studyNumber = 'ISTs';
                    budget.ctmsNumber = 'N/A';
                    budget.gStarsNo = 'N/A';
                    budget.CSM = 'N/A';
                    budget.investigatorSponsorName = 'N/A';
                    if (!rollupBudgetByGeneralWBS.containsKey(budget.newWbs)) {
                        rollupBudgetByGeneralWBS.put(budget.newWbs, budget);
                    }
                }
            }
            Integer i = 0;
            for (CFAR_Budget_CPS_Projection_gne__c p : trial.CFAR_Budget_Projections__r) {
                if (i == CFAR_TrialReport_Model.BUDGET_YEARS_LIMIT) break;
                if (Integer.valueOf(p.Year_gne__c) == currentYear) {
                    budget.year = currentYear;
                    if (hasGeneralWBS) {
                        Budget tempBudget = rollupBudgetByGeneralWBS.get(budget.newWbs);
                        tempBudget.year = currentYear;
                        tempBudget.q1 += CFAR_Utils.nullSafeGet(p.Quarter_1_gne__c);
                        tempBudget.q2 += CFAR_Utils.nullSafeGet(p.Quarter_2_gne__c);
                        tempBudget.q3 += CFAR_Utils.nullSafeGet(p.Quarter_3_gne__c);
                        tempBudget.q4 += CFAR_Utils.nullSafeGet(p.Quarter_4_gne__c);
                        tempBudget.projectedSpend += CFAR_Utils.nullSafeGet(p.frm_Total_Amount_gne__c);
                        tempBudget.projectedPatientAccrual += p.Year_gne__c != null ? (projectedPatientAccruals.containsKey(Integer.valueOf(p.Year_gne__c)) ? (CFAR_Utils.nullSafeGet(projectedPatientAccruals.get(Integer.valueOf(p.Year_gne__c)))) : 0) : 0;
                        rollupBudgetByGeneralWBS.put(budget.newWbs, tempBudget);
                    } else {
                        budget.q1 = p.Quarter_1_gne__c;
                        budget.q2 = p.Quarter_2_gne__c;
                        budget.q3 = p.Quarter_3_gne__c;
                        budget.q4 = p.Quarter_4_gne__c;
                        budget.projectedSpend = p.frm_Total_Amount_gne__c;
                        budget.projectedPatientAccrual = p.Year_gne__c != null ? (projectedPatientAccruals.containsKey(Integer.valueOf(p.Year_gne__c)) ? projectedPatientAccruals.get(Integer.valueOf(p.Year_gne__c)) : 0) : 0;
                    }
                    bs.totalQ1 += CFAR_Utils.nullSafeGet(p.Quarter_1_gne__c);
                    bs.totalQ2 += CFAR_Utils.nullSafeGet(p.Quarter_2_gne__c);
                    bs.totalQ3 += CFAR_Utils.nullSafeGet(p.Quarter_3_gne__c);
                    bs.totalQ4 += CFAR_Utils.nullSafeGet(p.Quarter_4_gne__c);
                    bs.totalProjectedSpend += CFAR_Utils.nullSafeGet(p.frm_Total_Amount_gne__c);
                    bs.totalProjectedPatientAccrual += p.Year_gne__c != null ? (projectedPatientAccruals.containsKey(Integer.valueOf(p.Year_gne__c)) ? (CFAR_Utils.nullSafeGet(projectedPatientAccruals.get(Integer.valueOf(p.Year_gne__c)))) : 0) : 0;
                } else {
                    Budget tmpBudget = getBudgetForProjection(rollupBudgetByGeneralWBS, budget, hasGeneralWBS, currentYear);
                    Projection pr = getProjectionFromSObj(p, projectedPatientAccruals);
                    // search budget for same year projection and update it with current projection
                    updateProjection(tmpBudget.projections, pr);
                    // update projectionTotal list with current projection
                    updateProjection(projections.get(pr.year), pr);
                }
            }
            if (trial.CFAR_Budget_Projections__r.isEmpty()) {
                budget.year = currentYear;
                budget.q1 = 0;
                budget.q2 = 0;
                budget.q3 = 0;
                budget.q4 = 0;
                budget.projectedSpend = 0;
                budget.projectedPatientAccrual = 0;
            }
            for (Integer g = budget.projections.size(); g < CFAR_TrialReport_Model.BUDGET_YEARS_LIMIT; g++) {
                budget.projections.add(new Projection(currentYear + g + 1, 0, 0));
            }
            if (!hasGeneralWBS) {
                otherBudgets.add(budget);
            }
        }
        for (String generalBdg : rollupBudgetByGeneralWBS.keySet()) {
            budgetsWithGeneralWBS.add(rollupBudgetByGeneralWBS.get(generalBdg));
        }
        budgets.addAll(budgetsWithGeneralWBS);
        budgets.addAll(otherBudgets);
        bs.budgets = budgets;
        bs.projectionsTotal = projections.values();
        return bs;
    }

    private static void updateProjection(List<Projection> projections, Projection pr) {
        for (Projection basePr : projections) {
            if (pr.year == basePr.year) {
                updateProjection(basePr, pr);
                return;
            }
        }
        projections.add(pr);
    }

    private static void updateProjection(Projection basePr, Projection pr) {
        basePr.projectedSpend = basePr.projectedSpend + pr.projectedSpend;
        basePr.projectedPatientAccrual = basePr.projectedPatientAccrual + pr.projectedPatientAccrual;
    }

    private static Projection getProjectionFromSObj(CFAR_Budget_CPS_Projection_gne__c p, Map<Integer, Decimal> projectedPatientAccruals) {
        Decimal projectedPatientAccrual = 0;
        if (p.Year_gne__c != null && (projectedPatientAccruals.containsKey(Integer.valueOf(p.Year_gne__c)))) {
            projectedPatientAccrual = projectedPatientAccruals.get(Integer.valueOf(p.Year_gne__c));
        }
        Projection pr = new Projection(Integer.valueOf(p.Year_gne__c), p.frm_Total_Amount_gne__c, projectedPatientAccrual);
        return pr;
    }

    private static Budget getBudgetForProjection(Map<String, Budget> rollupBudgetByGeneralWBS,
            Budget budget, boolean hasGeneralWBS, Integer currentYear) {
        Budget tempBudget = budget;
        if (hasGeneralWBS) {
            // if it's generalWBS then current year's data should be collected already, because projections are sorted by year ASC in DAO
            if (rollupBudgetByGeneralWBS.containsKey(budget.newWbs)) {
                // get already collected current year's data
                tempBudget = rollupBudgetByGeneralWBS.get(budget.newWbs);
            } else {
                // this situation should not happen, but code covers it to on the safe side
                // projections are not sorted or current year's projections are missing, so app receives future projections from the start
                // current year doesn't exist
                tempBudget = new Budget();
                tempBudget.year = currentYear;
                tempBudget.studyNumber = budget.studyNumber;
                tempBudget.wbs = budget.wbs;
                tempBudget.newWbs = budget.newWbs;
                tempBudget.gStarsNo = budget.gStarsNo;
                tempBudget.trialType = budget.trialType;
                tempBudget.CSM = budget.CSM;
                tempBudget.CSA = budget.CSA;
                tempBudget.ctmsNumber = budget.ctmsNumber;
                rollupBudgetByGeneralWBS.put(budget.newWbs, tempBudget);
            }
        }
        return tempBudget;
    }

    public static List<PaymentTotal> countTotalPayments(PaymentsTabData ptd) {
        List<PaymentTotal> totals = new List<PaymentTotal>();
        map<Integer, Decimal> mapYearAmount = new map<Integer, Decimal>();
        for (Payment p : ptd.payments) {
            if (String.isNotBlank(p.datePaid)) {
                Integer year = Integer.valueof(p.datePaid.split('/').get(p.datePaid.split('/').size() - 1));
                if (mapYearAmount.containsKey(year)) {
                    mapYearAmount.put(year, mapYearAmount.get(year) + p.amountPaid);
                } else {
                    mapYearAmount.put(year, p.amountPaid);
                }
            }
        }
        for (Integer i : mapYearAmount.keySet()) {
            totals.add(new PaymentTotal(i, mapYearAmount.get(i)));
        }
        return totals;
    }

    public static List<Publication> convertTrialsForPublication(List<CFAR_Trial_gne__c> trials) {
        if (trials == null || trials.isEmpty())
            return new List<Publication>();
        List<Publication> tData = new List<Publication>();
        for (CFAR_Trial_gne__c trial : trials) {
            String CSM = CFAR_Utils.customEscape(trial.frm_Genentech_Primary_Contact_ref_gne__c);
            String CSA = '';
            if (!trial.CFAR_Team_Members__r.isEmpty()) {
                for (CFAR_Team_Member_gne__c tm : trial.CFAR_Team_Members__r) {
                    if (tm.frm_Function_Role_gne__c == 'CSA = Clinical Study Associate') {
                        CSA += (String.isBlank(CSA)) ? tm.frm_Name_gne__c : '; ' + tm.frm_Name_gne__c;
                    }
                }
            }
            for (CFAR_Publication_gne__c p : trial.CFAR_Publications__r) {
                tData.add(new Publication(trial.Name, p.Author_gne__c, p.Date_Planned_gne__c, p.Date_Received_gne__c, p.Date_Published_gne__c, p.Source_gne__c, p.Status_gne__c, p.Reviewed_By_GNE_Prior_to_Submission_gne__c, getProtocolNumber(trial), trial.frm_Trial_Type_ref_gne__c, CSM, CSA, trial.CTMS_gne__c));
            }
        }
        return tData;
    }

    public static List<Comment> convertTrialsForComments(List<CFAR_Trial_gne__c> trials) {
        if (trials == null || trials.isEmpty()) {
            return new List<Comment>();
        }
        List<Comment> commentsData = new List<Comment> ();
        Map<Id, String> trialToInvestigatorInstitution = new Map<Id, String> ();
        Map<Id, String> trialToInvestigatorAddress = new Map<Id, String> ();
        for (CFAR_Team_Member_gne__c tm : [
                SELECT Id, frm_Name_gne__c, CFAR_Trial_ref_gne__r.Id,
                        contact_address_ref_gne__r.CFAR_Contact_ref_gne__c,
                        contact_address_ref_gne__r.Contact_Address_ref_gne__r.Institution_gne__r.Name,
                        contact_address_ref_gne__r.Contact_Address_ref_gne__r.Department_Division_gne__c,
                        contact_address_ref_gne__r.Contact_Address_ref_gne__r.Address_gne__c,
                        contact_address_ref_gne__r.Contact_Address_ref_gne__r.City_gne__c,
                        contact_address_ref_gne__r.Contact_Address_ref_gne__r.State_gne__c,
                        contact_address_ref_gne__r.Contact_Address_ref_gne__r.Province_gne__c,
                        contact_address_ref_gne__r.Contact_Address_ref_gne__r.Zip_gne__c,
                        contact_address_ref_gne__r.Contact_Address_ref_gne__r.Postal_Code_gne__c,
                        contact_address_ref_gne__r.Contact_Address_ref_gne__r.Country_gne__c
                FROM CFAR_Team_Member_gne__c
                WHERE frm_Function_Role_gne__c = 'PI = Primary (or Principal) Investigator'
                AND CFAR_Trial_ref_gne__c in :trials
                AND frm_Is_Inactive_gne__c = false
        ]) {
            trialToInvestigatorInstitution.put(
                    tm.CFAR_Trial_ref_gne__r.Id,
                    tm.contact_address_ref_gne__r.Contact_Address_ref_gne__r.Institution_gne__r.Name
            );
            trialToInvestigatorAddress.put(
                    tm.CFAR_Trial_ref_gne__r.Id,
                    assembleAddress(tm.contact_address_ref_gne__r.Contact_Address_ref_gne__r)
            );
        }
        for (CFAR_Trial_gne__c trial : trials) {
            for (CFAR_Comment_gne__c c : trial.CFAR_Comments__r) {
                Comment cm = new Comment();
                cm.protocolNumber = getProtocolNumber(trial);
                cm.ctmsNumber = trial.CTMS_gne__c;
                cm.trialNumber = trial.Name;
                cm.product = trial.frm_Product_ref_gne__c;
                cm.trialType = trial.frm_Trial_Type_ref_gne__c;
                cm.trialStatus = trial.frm_Trial_Status_ref_gne__c;
                cm.investigator = trial.frm_Investigator_ref_gne__c;
                cm.activityDate = c.Activity_Date_gne__c == null ? '' : String.valueOf(((Datetime) c.Activity_Date_gne__c).formatGMT('MM/dd/yyyy'));
                cm.createdBy = c.Created_By_CFAR_Contact_ref_gne__r.Search_Name__c;
                cm.commentText = c.Comments_gne__c;
                cm.institution = trialToInvestigatorInstitution.containsKey(trial.Id) ? trialToInvestigatorInstitution.get(trial.Id) : '';
                cm.sponsorContactInformation = trialToInvestigatorAddress.containsKey(trial.Id) ? trialToInvestigatorAddress.get(trial.Id) : '';
                commentsData.add(cm);
            }
        }
        return commentsData;
    }

    public static List<BOMData> convertTrialsForBOM(List<CFAR_Trial_gne__c> trials) {
        if (trials == null || trials.isEmpty()) {
            return new List<BOMData>();
        }
        List<BOMData> tData = new List<BOMData>();
        List<String> trialIds = new List<String>();
        for (CFAR_Trial_gne__c trial : trials) {
            trialIds.add(String.valueOf(trial.Id));
        }
        Map<Id, String> trialToTos = CFAR_DAO.getTypeOfSampleRecordsByTrial(trialIds);
        Map<Id, List<String>> trialToBomUsers = CFAR_DAO.getTrialToRoleForTrials('BOM', trials);
        for (CFAR_Trial_gne__c trial : trials) {
            BOMData b = new BOMData();
            b.themeNumber = trial.Product_ref_gne__r.Theme_ref_gne__r.Name;
            b.studyTitle = trial.Title_gne__c;
            b.BiomarkerSamplesCollected = trial.Biomarker_Questions_gne__c;
            b.BOMDescription = trial.Biomarker_Description_gne__c;
            b.patSubPop = trial.Sub_Patient_Population_gne__c;
            b.typeOfSample = trialToTos.get(trial.Id);
            b.CSM = CFAR_Utils.customEscape(trial.frm_Genentech_Primary_Contact_ref_gne__c);
            b.ctmsNumber = trial.CTMS_gne__c;
            b.BOM = (trialToBomUsers.containsKey(trial.Id) && trialToBomUsers.get(trial.Id) != null) ? String.join(trialToBomUsers.get(trial.Id), '; ') : '';
            tData.add(b);
        }
        return tData;
    }

    public static List<InfrepData> convertTrialsForInfrep(List<CFAR_Trial_gne__c> trials) {
        if (trials == null || trials.isEmpty())
            return new List<InfrepData>();
        List<InfrepData> tData = new List<InfrepData>();
        for (CFAR_Trial_gne__c trial : trials) {
            InfrepData t = convertMilestoneAct(trial);
            t.protocolNumber = getProtocolNumber(trial);
            t.trialNumber = trial.Name;
            t.ctmsNumber = trial.CTMS_gne__c;
            Boolean activeInvestigator = false;
            Boolean MSDasMSL = false;
            t.trialType = trial.frm_Trial_Type_ref_gne__c;
            t.institutionName = null;
            t.sponsorContactInformation = null;
            t.impact = trial.Impacts_gne__c;
            t.tiering = trial.Tiering_gne__c;
            t.themeNumber = trial.Product_ref_gne__r.Theme_ref_gne__r.Name;
            t.medicalUnit = trial.Therapeutic_Area_ref_gne__r.Name;
            t.srtTeam = trial.SRT_Team_ref_gne__r.Name;
            t.css = null;
            t.CSM = CFAR_Utils.customEscape(trial.frm_Genentech_Primary_Contact_ref_gne__c);
            if (!trial.CFAR_Team_Members__r.isEmpty()) {
                for (CFAR_Team_Member_gne__c tm : trial.CFAR_Team_Members__r) {
                    if (trial.frm_Investigator_ref_gne__c != null && tm.frm_Function_Role_gne__c == 'PI = Primary (or Principal) Investigator' && (tm.Contact_address_ref_gne__r.CFAR_Contact_ref_gne__c == trial.Investigator_ref_gne__c)) {
                        activeInvestigator = true;
                        t.institutionName = tm.contact_address_ref_gne__r.Contact_Address_ref_gne__r.Institution_gne__r.Name;
                        t.sponsorContactInformation = assembleAddress(tm);
                    }
                    if (trial.frm_MSL_ref_gne__c != null && tm.Contact_address_ref_gne__r.CFAR_Contact_ref_gne__c == trial.MSL_ref_gne__c) {
                        if (tm.frm_Function_Role_gne__c == 'MSL = Medical Science Liaison') {
                            t.msl = trial.frm_MSL_ref_gne__c;
                        } else if (tm.frm_Function_Role_gne__c == 'MSD = Medical Science Director') {
                            t.msd = trial.frm_MSL_ref_gne__c;
                            MSDasMSL = true;
                        }
                    }
                    if (tm.frm_Function_Role_gne__c == 'CSA = Clinical Study Associate') {
                        t.CSA += (String.isBlank(t.CSA)) ? tm.frm_Name_gne__c : '; ' + tm.frm_Name_gne__c;
                    }
                    if (tm.frm_Function_Role_gne__c == 'SRT = Study Review Team Chair') {
                        t.srt = tm.frm_Name_gne__c;
                    }
                    if (tm.frm_Function_Role_gne__c == 'MSD = Medical Science Director' && !MSDasMSL) {
                        t.msd = (String.isBlank(t.msd)) ? tm.frm_Name_gne__c : t.msd + '; ' + tm.frm_Name_gne__c;
                    }
                    if (tm.frm_Function_Role_gne__c == 'CSS = Clinical Study Specialist') {
                        t.css = tm.frm_Name_gne__c;
                    }
                }
            }
            t.interventional = trial.Non_Interventional_gne__c;
            String impShipped = '';
            if (!trial.gSTARS_Trial_IMP_Shipped__r.isEmpty()){ 
                for (CFAR_Trial_IMP_Shipped__c imp : trial.gSTARS_Trial_IMP_Shipped__r) {
                    impShipped += (imp.frm_IMP_Shipped_Generic__c + ', ');
                }
            } 
            impShipped = impShipped.removeEnd(', ');
            t.impShipped = impShipped;
            t.productName = trial.frm_Product_ref_gne__c;
            t.investigatorSponsorName = activeInvestigator ? trial.frm_Investigator_ref_gne__c : null;
            t.otherStudyName = trial.Other_Trial_gne_Id__c;
            t.trialStatus = trial.frm_Trial_Status_ref_gne__c;
            t.primaryIndication = trial.frm_General_Indication_ref_gne__c;
            t.specificIndication = (!trial.gstars_Specific_Indications_for_Trial__r.isEmpty()) ? CFAR_Utils.getSIForInfrepReport(trial.gstars_Specific_Indications_for_Trial__r) : '';
            t.protocolTitle = trial.Title_gne__c;
            t.gneSupport = trial.Dollar_and_Drug_ref_gne__r.Name;

            String gneAgentsNames = '';
            if (!trial.gSTARS_Trial_Other_GNE_Agents__r.isEmpty()) {
                for (CFAR_Trial_Other_GNE_Agent_gne__c OGA : trial.gSTARS_Trial_Other_GNE_Agents__r) {
                    gneAgentsNames += (OGA.frm_Other_GNE_Agent_Generic_gne__c + ', ');
                }
                gneAgentsNames = gneAgentsNames.removeEnd(', ');
            } else if (gneAgentsNames == '' && trial.Other_GNE_Agents_Multi_gne__c == 'N/A') {
                gneAgentsNames = 'N/A';
            }
            t.gneAgents = gneAgentsNames;
            t.otherAgents = trial.Other_Agents_gne__c;
            t.regimen = trial.Regimen_gne__c;
            t.sampleSize = trial.Planned_Enrollment_gne__c;
            t.totalEnrolled = trial.Enrolled_Sum_rollup_gne__c;
            t.publicationsSymposia = '';
            t.comments = (trial.CFAR_Comments__r.size() > 0) ? trial.CFAR_Comments__r[0].Comments_gne__c : null; //getComment(trial);
            t.labSupport = trial.Lab_Support_gne__c;
            t.dose = null;
            t.briefTitle = trial.Brief_Title_gne__c;
            tData.add(t);
        }
        return tData;
    }

    public static String assembleAddress(CFAR_Team_Member_gne__c tm) {
        return (String.isBlank(tm.contact_address_ref_gne__r.Contact_Address_ref_gne__r.Department_Division_gne__c) ? '' : tm.contact_address_ref_gne__r.Contact_Address_ref_gne__r.Department_Division_gne__c + ' ') +
                (String.isBlank(tm.contact_address_ref_gne__r.Contact_Address_ref_gne__r.Address_gne__c) ? '' : tm.contact_address_ref_gne__r.Contact_Address_ref_gne__r.Address_gne__c + ' ') +
                (String.isBlank(tm.contact_address_ref_gne__r.Contact_Address_ref_gne__r.City_gne__c) ? '' : tm.contact_address_ref_gne__r.Contact_Address_ref_gne__r.City_gne__c + ', ') +
                (String.isBlank(tm.contact_address_ref_gne__r.Contact_Address_ref_gne__r.State_gne__c) ? (String.isBlank(tm.contact_address_ref_gne__r.Contact_Address_ref_gne__r.Province_gne__c) ? '' : tm.contact_address_ref_gne__r.Contact_Address_ref_gne__r.Province_gne__c + ' ') : tm.contact_address_ref_gne__r.Contact_Address_ref_gne__r.State_gne__c + ' ') +
                (String.isBlank(tm.contact_address_ref_gne__r.Contact_Address_ref_gne__r.Zip_gne__c) ? (String.isBlank(tm.contact_address_ref_gne__r.Contact_Address_ref_gne__r.Postal_Code_gne__c) ? '' : tm.contact_address_ref_gne__r.Contact_Address_ref_gne__r.Postal_Code_gne__c + ' ') : tm.contact_address_ref_gne__r.Contact_Address_ref_gne__r.Zip_gne__c + ' ') +
                (String.isBlank(tm.contact_address_ref_gne__r.Contact_Address_ref_gne__r.Country_gne__c) ? '' : tm.contact_address_ref_gne__r.Contact_Address_ref_gne__r.Country_gne__c);
    }

    public static String assembleAddress(CFAR_Contact_Address_gne__c ca) {
        return (ca != null) ? (String.isBlank(ca.Department_Division_gne__c) ? '' : ca.Department_Division_gne__c + ' ') +
                (String.isBlank(ca.Address_gne__c) ? '' : ca.Address_gne__c + ' ') +
                (String.isBlank(ca.City_gne__c) ? '' : ca.City_gne__c + ', ') +
                (String.isBlank(ca.State_gne__c) ? (String.isBlank(ca.Province_gne__c) ? '' : ca.Province_gne__c + ' ') : ca.State_gne__c + ' ') +
                (String.isBlank(ca.Zip_gne__c) ? (String.isBlank(ca.Postal_Code_gne__c) ? '' : ca.Postal_Code_gne__c + ' ') : ca.Zip_gne__c + ' ') +
                (String.isBlank(ca.Country_gne__c) ? '' : ca.Country_gne__c) : null;
    }

    public static Decimal parseQuarter(Date d) {
        return (Decimal.valueOf(d.month()) / 3).round(System.RoundingMode.CEILING);
    }

    public static InfrepData convertMilestoneAct(CFAR_Trial_gne__c trial) {
        InfrepData inf = new InfrepData();
        for (CFAR_Milestone_Activity_gne__c ma : trial.CFAR_Milestone_Activities__r) {
            if ('Activation'.equals(ma.Name)) {
                inf.activationPlanned = ma.Planned_Date_gne__c != null ? String.valueOf(((Datetime) ma.Planned_Date_gne__c).formatGMT('MM/dd/yyyy')) : null;
                inf.activationActual = ma.Actual_Date_gne__c != null ? String.valueOf(((Datetime) ma.Actual_Date_gne__c).formatGMT('MM/dd/yyyy')) : null;
                if (ma.Actual_Date_Last_Change_gne__c != null) {
                    inf.quartersOfActualDateChange.put('Activation', parseQuarter(ma.Actual_Date_Last_Change_gne__c));
                }
            } else if ('Draft Protocol Approval'.equals(ma.Name)) {
                inf.draftProtocolApproved = ma.Actual_Date_gne__c != null ? String.valueOf(((Datetime) ma.Actual_Date_gne__c).formatGMT('MM/dd/yyyy')) : null;
            } else if ('FPI'.equals(ma.Name)) {
                inf.fpiPlanned = ma.Planned_Date_gne__c != null ? String.valueOf(((Datetime) ma.Planned_Date_gne__c).formatGMT('MM/dd/yyyy')) : null;
                inf.fpiActual = ma.Actual_Date_gne__c != null ? String.valueOf(((Datetime) ma.Actual_Date_gne__c).formatGMT('MM/dd/yyyy')) : null;
                if (ma.Actual_Date_Last_Change_gne__c != null) {
                    inf.quartersOfActualDateChange.put('FPI', parseQuarter(ma.Actual_Date_Last_Change_gne__c));
                }
            } else if ('LPI'.equals(ma.Name)) {
                inf.lpiPlanned = ma.Planned_Date_gne__c != null ? String.valueOf(((Datetime) ma.Planned_Date_gne__c).formatGMT('MM/dd/yyyy')) : null;
                inf.lpiActual = ma.Actual_Date_gne__c != null ? String.valueOf(((Datetime) ma.Actual_Date_gne__c).formatGMT('MM/dd/yyyy')) : null;
                if (ma.Actual_Date_Last_Change_gne__c != null) {
                    inf.quartersOfActualDateChange.put('LPI', parseQuarter(ma.Actual_Date_Last_Change_gne__c));
                }
            } else if ('LPO'.equals(ma.Name)) {
                inf.lpoPlanned = ma.Planned_Date_gne__c != null ? String.valueOf(((Datetime) ma.Planned_Date_gne__c).formatGMT('MM/dd/yyyy')) : null;
                inf.lpoActual = ma.Actual_Date_gne__c != null ? String.valueOf(((Datetime) ma.Actual_Date_gne__c).formatGMT('MM/dd/yyyy')) : null;
                if (ma.Actual_Date_Last_Change_gne__c != null) {
                    inf.quartersOfActualDateChange.put('LPO', parseQuarter(ma.Actual_Date_Last_Change_gne__c));
                }
            } else if ('FSR' == ma.Name) {
                inf.fsrPlanned = ma.Planned_Date_gne__c != null ? String.valueOf(((DateTime) ma.Planned_Date_gne__c).formatGmt('MM/dd/yyyy')) : null;
                inf.fsrActual = ma.Actual_Date_gne__c != null ? String.valueOf(((DateTime) ma.Actual_Date_gne__c).formatGMT('MM/dd/yyyy')) : null;
                if (ma.Actual_Date_Last_Change_gne__c != null) {
                    inf.quartersOfActualDateChange.put('FSR', parseQuarter(ma.Actual_Date_Last_Change_gne__c));
                }
            } else if ('Proposal Approval'.equals(ma.Name)) {
                inf.proposalApproved = ma.Actual_Date_gne__c != null ? String.valueOf(((Datetime) ma.Actual_Date_gne__c).formatGMT('MM/dd/yyyy')) : null;
            } else if ('SRT Protocol Approval'.equals(ma.Name)) {
                inf.srrtProtocolApproved = ma.Actual_Date_gne__c != null ? String.valueOf(((Datetime) ma.Actual_Date_gne__c).formatGMT('MM/dd/yyyy')) : null;
                if (ma.Actual_Date_Last_Change_gne__c != null) {
                    inf.quartersOfActualDateChange.put('SRT', parseQuarter(ma.Actual_Date_Last_Change_gne__c));
                }
            } else if ('Study Closure'.equals(ma.Name)) {
                inf.studyClosure = ma.Planned_Date_gne__c != null ? String.valueOf(((Datetime) ma.Planned_Date_gne__c).formatGMT('MM/dd/yyyy')) : null;
                inf.studyClosureActual = ma.Actual_Date_gne__c != null ? String.valueOf(((Datetime) ma.Actual_Date_gne__c).formatGMT('MM/dd/yyyy')) : null;
                if (ma.Actual_Date_Last_Change_gne__c != null) {
                    inf.quartersOfActualDateChange.put('Study Closure', parseQuarter(ma.Actual_Date_Last_Change_gne__c));
                }
            } else if ('TRAC Protocol Approval'.equals(ma.Name)) {
                inf.tracProtocolApproved = ma.Actual_Date_gne__c != null ? String.valueOf(((Datetime) ma.Actual_Date_gne__c).formatGMT('MM/dd/yyyy')) : null;
            }
        }
        return inf;
    }

    public static Integer countTotalSize(List<CountData> cData) {
        Integer totalSize = 0;
        if (cData == null || cData.isEmpty())
            return totalSize;
        for (CountData c : cData) {
            totalSize = totalSize + c.size;
        }
        return totalSize;
    }

    public static List<CountData> getStatusData(List<CFAR_Trial_gne__c> trials) {
        if (trials == null || trials.isEmpty())
            return new List<CountData>();
        List<CountData> cData = new List<CountData>();
        Map<String, Integer> countData = new Map<String, Integer>();

        Map<String, String> indicationMap = new Map<String, String>{
                label.CFAR_GSTARS_TRIAL_STATUS_ACTIVE_ENROLLMENT => 'Actively Accruing Studies',
                label.CFAR_GSTARS_TRIAL_STATUS_ACTIVE_PUBLICATION => 'Active Publication',
                label.CFAR_GSTARS_TRIAL_STATUS_COMPLETED_ENROLLMENT => 'Completed Enrollment',
                label.CFAR_GSTARS_TRIAL_STATUS_PROPOSAL_APPROVED => 'Proposal Approved Studies',
                label.CFAR_GSTARS_TRIAL_STATUS_PROTOCOL_APPROVED => 'Protocol Approved Studies',
                label.CFAR_GSTARS_TRIAL_STATUS_CLOSURE_PENDING => 'Closure Pending',
                label.CFAR_GSTARS_TRIAL_STATUS_HOLD => 'Hold',
                label.CFAR_GSTARS_TRIAL_STATUS_FOLLOWUP => 'Follow-up'
        };
        List<String> values = new List<String>();
        values.add('Actively Accruing Studies');
        values.add('Completed Enrollment');
        values.add('Active Publication');
        values.add('Proposal Approved Studies');
        values.add('Protocol Approved Studies');
        values.add('Closure Pending');
        values.add('Hold');
        values.add('Follow-up');

        for (String status : values) {
            countData.put(status, 0);
        }
        for (CFAR_Trial_gne__c trial : trials) {
            if (trial.Trial_Status_ref_gne__r.Name != null && indicationMap.containsKey(trial.Trial_Status_ref_gne__r.Name)) {
                String status = indicationMap.get(trial.Trial_Status_ref_gne__r.Name);
                countData.put(status, countData.get(status) + 1);
            }
        }
        for (String fName : values) {
            cData.add(new CountData(fName, countData.get(fName)));
        }
        System.debug('---- StatusData ' + cData);
        return cData;
    }

    public static List<CountData> getIndicationData(List<CFAR_Trial_gne__c> trials) {
        if (trials == null || trials.isEmpty())
            return new List<CountData>();
        String na = 'N/A';
        boolean isNa = false;
        List<CountData> cData = new List<CountData>();
        Map<String, Integer> countData = new Map<String, Integer>();
        Set<String> valuesSet = new Set<String>();
        for (CFAR_Trial_gne__c trial : trials) {
            String status = na;
            if (trial.CFAR_General_Indication_ref_gne__r.Name != null)
                status = trial.CFAR_General_Indication_ref_gne__r.Name;
            if (!countData.containsKey(status))
                countData.put(status, 0);
            countData.put(status, countData.get(status) + 1);
            valuesSet.add(status);
        }
        if (valuesSet.contains(na)) {
            valuesSet.remove(na);
            isNa = true;
        }
        List<String> values = new List<String>(valuesSet);//.sort();
        values.sort();
        if (isNa) {
            values.add(0, na);
        }
        for (String fName : values) {
            cData.add(new CountData(fname, countData.get(fName)));
        }
        System.debug('---- IndicationData ' + cData);
        return cData;
    }

    public static List<String> getMSLs() {
        List<String> msls = new List<String>();
        CFAR_SearchParameters searchParms = new CFAR_SearchParameters();
        searchParms.andEqualsParameters.put('Active_gne__c', 'true');
        searchParms.sortExpression = 'Search_Name__c';
        searchParms.sortDirection = 'asc';
        searchParms.orEqualsParameters.put('Primary_Role_Function_gne__c', CFAR_Utils.getAvailableRolesForMSL());
        List<CFAR_Contact_gne__c> contacts = CFAR_DAO.getContacts(searchParms);
        if (contacts == null || contacts.isEmpty())
            return msls;
        for (CFAR_Contact_gne__c cont : contacts) {
            msls.add(cont.Search_Name__c);
        }
        return msls;
    }

    public static String getProtocolNumber(CFAR_Trial_gne__c trial) {
        if (!String.isBlank(trial.Other_Trial_gne_Id__c)) {
            return trial.Other_Trial_gne_Id__c;
        } else if (!String.isBlank(trial.CTMS_gne__c))
            return trial.CTMS_gne__c; else {
            return trial.Name;
        }
    }
}