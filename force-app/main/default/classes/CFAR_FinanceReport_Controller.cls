public with sharing class CFAR_FinanceReport_Controller {
    private transient Map<String, String> parametersMap;
    private static final String ORGINAL_CONTRACT = 'Original Contract';
    
    public CFAR_FinanceReport_Controller() {
        parametersMap = ApexPages.currentPage().getParameters();
    }

    public CFAR_FinanceReport_Controller(CFAR_TrialReport_Controller controller) {
        parametersMap = ApexPages.currentPage().getParameters();
    }    
    
    public String getFileName() {
        String fileName = 'Finance_Report_' + String.valueOf(Date.today());
        return fileName;
    }
    
    public String getWorkbookProperties() {
        String workbook = '<x:ExcelWorkbook><x:ExcelWorksheets><x:ExcelWorksheet><x:Name>' + 
            'Finance Report' + '</x:Name><x:WorksheetOptions><x:DisplayGridlines/>' + 
            '</x:WorksheetOptions></x:ExcelWorksheet></x:ExcelWorksheets></x:ExcelWorkbook>';
        return workbook;
    }
    
    public Integer getCurrentYear() {
        return System.today().year();
    }
    
    public Integer getYear1Fwd() {
        return System.today().year()+1;
    }
    
    public Integer getYear2Fwd() {
        return System.today().year()+2;
    }
    
    public Integer getYear3Fwd() {
        return System.today().year()+3;
    }

    @RemoteAction
    public static CFAR_FinanceReport_DataModel.ReportDataWrapper getFinanceData(String studyNr, String ctms, String wbsCode, List<String> products, List<String> therapeuticAreas, List<String> indications, List<String> trialTypes, List<String> studyStatuses, List<String> subjectTypes, List<String> pediatricStudies,
            List<String> specIndications, List<String> impacts, List<String> SRTs, List<String> teamMember, List<String> GNEs, List<String> inclusiveResearch) {
                CFAR_FinanceReport_DataModel.ReportDataWrapper reportDataToShow = new CFAR_FinanceReport_DataModel.ReportDataWrapper();
                try {
                    reportDataToShow = prepareFinanceData(studyNr, ctms, wbsCode, products, therapeuticAreas, indications, trialTypes, studyStatuses, subjectTypes, pediatricStudies, specIndications, impacts, SRTs, teamMember, GNEs, inclusiveResearch);
                } catch(Exception e) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Error, use some filters'));
                }

                if (reportDataToShow.allRows.size() >= 999) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The amount of data is too large, apply filters, otherwise the generated report may not contain all the necessary information.'));
                return reportDataToShow;
    }

    public static CFAR_FinanceReport_DataModel.ReportDataWrapper prepareFinanceData(String studyNr, String ctms, String wbsCode, List<String> products, List<String> therapeuticAreas, List<String> indications, List<String> trialTypes, List<String> studyStatuses, List<String> subjectTypes, List<String> pediatricStudies,
            List<String> specIndications, List<String> impacts, List<String> SRTs, List<String> teamMember, List<String> GNEs, List<String> inclusiveResearch) {
    CFAR_FinanceReport_DataModel.ReportDataWrapper reportDataToShow = new CFAR_FinanceReport_DataModel.ReportDataWrapper();
        reportDataToShow.allRows = new List<CFAR_FinanceReport_DataModel.SingleRowWrapper>();
        for (CFAR_FinanceReport_DataModel.CFAR_Trial trial : fillTrialList(
                String.join(indications, ';'),
                String.join(products, ';'),
                studyNr,
                String.join(studyStatuses, ';'),
                String.join(therapeuticAreas, ';'),
                String.join(trialTypes, ';'),
                String.join(subjectTypes, ';'),
                String.join(pediatricStudies, ';'),
                String.join(specIndications, ';'),
                String.join(impacts, ';'),
                String.join(SRTs, ';'),
                String.join(teamMember, ';'),
                String.join(GNEs, ';'),
                String.join(inclusiveResearch, ';'),
                ctms,
                wbsCode
                )) {
            for(CFAR_Budget_Contract_gne__c contract : trial.contracts){
                CFAR_FinanceReport_DataModel.SingleRowWrapper srw = createSingleRowWrapper(trial, contract);
                reportDataToShow.allRows.add(srw);
            }
        }
        reportDataToShow.allRows.sort();
        return reportDataToShow;
    }
    public CFAR_FinanceReport_DataModel.ReportDataWrapper getReportData() {
        CFAR_FinanceReport_DataModel.ReportDataWrapper reportDataToShow = new CFAR_FinanceReport_DataModel.ReportDataWrapper();
        reportDataToShow.allRows = new List<CFAR_FinanceReport_DataModel.SingleRowWrapper>();
        for (CFAR_FinanceReport_DataModel.CFAR_Trial trial : fillTrialList(
                parametersMap.get('indication'), 
                parametersMap.get('product'), 
                parametersMap.get('studyNo'), 
                parametersMap.get('studyStatus'), 
                parametersMap.get('therapeuticArea'), 
                parametersMap.get('trialType'), 
                parametersMap.get('subjectType'), 
                parametersMap.get('pediatricStudies'),
                parametersMap.get('specificIndication'),
                parametersMap.get('impact'),
                parametersMap.get('SRT'),
                parametersMap.get('teamMember'),
                parametersMap.get('gneSupport'),
                parametersMap.get('inclusive'),
                parametersMap.get('ctms'), 
                parametersMap.get('wbs')

        )) {
            for(CFAR_Budget_Contract_gne__c contract : trial.contracts){
                CFAR_FinanceReport_DataModel.SingleRowWrapper srw = createSingleRowWrapper(trial, contract);
                reportDataToShow.allRows.add(srw);
            }
        }
        reportDataToShow.allRows.sort();
        return reportDataToShow;
    }

    private static List<CFAR_FinanceReport_DataModel.CFAR_Trial> fillTrialList(
            String indication, 
            String product, 
            String studyNo, 
            String studyStatus, 
            String therapeuticArea, 
            String trialType, 
            String subjectType, 
            String pediatricStudies,
            String specIndications,
            String impacts,
            String SRTs,
            String teamMember,
            String GNEs,
            String inclusiveResearch,
            String ctms, 
            String wbs
            ) {
        List<CFAR_FinanceReport_DataModel.CFAR_Trial> trialsList = CFAR_DAO.getTrialWrappersForFinanceReport(
            setSearchParams(
                indication, 
                product, 
                studyNo, 
                studyStatus, 
                therapeuticArea, 
                trialType, 
                subjectType, 
                pediatricStudies,
                specIndications,
                impacts,
                SRTs,
                teamMember,
                GNEs,
                inclusiveResearch,
                ctms, 
                wbs
            )
        );
        return trialsList;
    }
    
    private static CFAR_FinanceReport_DataModel.SingleRowWrapper createSingleRowWrapper(
        CFAR_FinanceReport_DataModel.CFAR_Trial trialWrapper,
        CFAR_Budget_Contract_gne__c contract
    ) {
        CFAR_FinanceReport_DataModel.SingleRowWrapper srw = 
            new CFAR_FinanceReport_DataModel.SingleRowWrapper();
        Date tempDate;
        srw.trialCreatedDate = trialWrapper.trial.CreatedDate;
        srw.productName = CFAR_Utils.customEscape(trialWrapper.trial.frm_Product_ref_gne__c);
        srw.primaryGeneralIndication = CFAR_Utils.customEscape(trialWrapper.trial.frm_General_Indication_ref_gne__c);
        srw.protocolNo = (trialWrapper.trial.Other_Trial_gne_Id__c!=null)?CFAR_Utils.customEscape(trialWrapper.trial.Other_Trial_gne_Id__c):(trialWrapper.trial.CTMS_gne__c!=null)?CFAR_Utils.customEscape(trialWrapper.trial.CTMS_gne__c):CFAR_Utils.customEscape(trialWrapper.trial.Name);
        srw.CTMSNo = CFAR_Utils.customEscape(trialWrapper.trial.CTMS_gne__c);
        srw.gstarsTrialNo = CFAR_Utils.customEscape(trialWrapper.trial.Name);
        srw.WBSCode = CFAR_Utils.customEscape(trialWrapper.trial.frm_CFAR_WBS_ref_gne__c);
        srw.investigatorSponsorName = CFAR_Utils.customEscape(contract.frm_Investigator_Vendor_gne__c);
        srw.role = contract.Team_Member_ref_gne__r.frm_Function_Role_gne__c;
        srw.institutionName = 
            CFAR_Utils.customEscape(contract.Team_Member_ref_gne__r.Contact_Address_ref_gne__r.Contact_Address_ref_gne__r.Institution_gne__r.Name);
        srw.trialStatus = CFAR_Utils.customEscape(trialWrapper.trial.frm_Trial_Status_ref_gne__c);
        srw.therapeuticArea = CFAR_Utils.customEscape(trialWrapper.trial.Therapeutic_Area_ref_gne__r.Name);  
        tempDate = setContractFullyExecutedDate(contract.Budget_Contract_Trackings__r);       
        srw.contractFullyExecutedDate = tempDate != null ? tempDate.format() : '';
        tempDate = setContractExpiryDate(contract.Budget_Contract_Trackings__r);
        srw.contractExpiryDate = tempDate != null ? tempDate.format() : '';
        if (trialWrapper.trial.Enrolled_Sum_rollup_gne__c != null) {
            srw.totalEnrolled = Integer.valueOf(trialWrapper.trial.Enrolled_Sum_rollup_gne__c);
        }

        srw.currentContractAmount = (contract.frm_Current_Amount_gne__c != null) ? contract.frm_Current_Amount_gne__c.setScale(2) : 0;
        fillProjectionsFields(srw, trialWrapper.trial.CFAR_Budget_Projections__r);
        srw.theme = CFAR_Utils.customEscape(trialWrapper.trial.Product_ref_gne__r.Theme_ref_gne__r.Name);
        //srw.theme = '<font color="white">\'</font>'+srw.theme+'<font color="white">\'</font>';
        srw.gneSupport = CFAR_Utils.customEscape(trialWrapper.trial.Dollar_and_drug_ref_gne__r.Name);
        srw.poNumber = CFAR_Utils.customEscape(contract.PO_Number_gne__c);
        srw.balanceLeftToProject = contract.Amount_Left_to_Project_gne__c;
        srw.balanceAmount = contract.frm_Balance_gne__c;
        srw.msl = CFAR_Utils.customEscape(trialWrapper.trial.frm_MSL_ref_gne__c);
        srw.trialType = CFAR_Utils.customEscape(trialWrapper.trial.frm_Trial_Type_ref_gne__c);
        srw.specificIndication = CFAR_Utils.customEscape(fetchSpecificIndication(trialWrapper.trial));
        srw.protocolTitle = CFAR_Utils.customEscape(trialWrapper.trial.Title_gne__c);
        srw.gneAgents = CFAR_Utils.customEscape(fetchGNEAgents(trialWrapper.trial));
        srw.otherAgents = CFAR_Utils.customEscape(trialWrapper.trial.Other_Agents_gne__c);
        srw.regimen = CFAR_Utils.customEscape(trialWrapper.trial.Regimen_gne__c);
        srw.sampleSize = trialWrapper.trial.Planned_enrollment_gne__c;
        srw.proposalApprovedPlanned = trialWrapper.planned2Date.get('Proposal Approval');
        srw.proposalApprovedActual = trialWrapper.actual2Date.get('Proposal Approval');
        srw.draftProtocolApprovedPlanned = trialWrapper.planned2Date.get('Initial Protocol Received');
        srw.draftProtocolApprovedActual = trialWrapper.actual2Date.get('Initial Protocol Received');
        srw.imlApprovedPlanned = trialWrapper.planned2Date.get('IMD Approval');
        srw.imlApprovedActual = trialWrapper.actual2Date.get('IMD Approval');
        srw.srrtProtocolApprovedPlanned = trialWrapper.planned2Date.get('SRT Protocol Approval');
        srw.srrtProtocolApprovedActual = trialWrapper.actual2Date.get('SRT Protocol Approval');
        srw.tracProtocolApprovedPlanned = trialWrapper.planned2Date.get('TRAC Protocol Approval');
        srw.tracProtocolApprovedActual = trialWrapper.actual2Date.get('TRAC Protocol Approval');
        srw.activationPlanned = trialWrapper.planned2Date.get('Activation');
        srw.activationActual = trialWrapper.actual2Date.get('Activation');
        srw.fpiPlanned = trialWrapper.planned2Date.get('FPI');
        srw.fpiActual = trialWrapper.actual2Date.get('FPI');
        srw.lpiPlanned = trialWrapper.planned2Date.get('LPI');
        srw.lpiActual = trialWrapper.actual2Date.get('LPI');
        srw.lpoPlanned = trialWrapper.planned2Date.get('LPO');
        srw.lpoActual = trialWrapper.actual2Date.get('LPO');
        srw.StudyClosurePlanned = trialWrapper.planned2Date.get('Study Closure');
        srw.StudyClosureActual = trialWrapper.actual2Date.get('Study Closure');
        srw.lastComment = trialWrapper.trial.CFAR_Comments__r.isEmpty() ? '' : trialWrapper.trial.CFAR_Comments__r[0].Comments_gne__c;
        srw.lastComment = CFAR_Utils.customEscape(srw.lastComment);
        srw.interventional = CFAR_Utils.customEscape(trialWrapper.trial.Non_Interventional_gne__c);
        srw.totalPaid = contract.Total_payments_gne__c;
        srw.csm = trialWrapper.trial.frm_Genentech_Primary_Contact_ref_gne__c;
        for (CFAR_Team_Member_gne__c tm : trialWrapper.trial.CFAR_Team_Members__r) {
            if (tm.frm_Function_Role_gne__c == 'CSA = Clinical Study Associate') {
                srw.csa += (String.isBlank(srw.csa)) ? tm.frm_Name_gne__c : '; ' + tm.frm_Name_gne__c;
            }
        }
        String payload = '';
        for (Cost_Center_for_Trial__c cc : trialWrapper.trial.Cost_Centers_for_Trial__r) {
            payload += String.valueOf(cc.Cost_Center_Name__c + ' ' + '(' + cc.Value__c + '%' + ')' + ' ' + ((srw.currentContractAmount*(cc.Value__c)/100).setScale(2, System.RoundingMode.HALF_UP) + ' \r\n \r \t'));
        }
        srw.costCenter = String.valueOf(payload);   
        return srw;
    }
    
    private static String fetchSpecificIndication(CFAR_Trial_gne__c trial){
        String specificIndication = '';
        for(CFAR_Specific_Indication_for_Trial_gne__c si : trial.gstars_Specific_Indications_for_Trial__r){
            specificIndication += si.CFAR_Specific_Indication_ref_gne__r.Name + ', ';
        }
        return specificIndication.removeEnd(', ');
    }
    
    private static String fetchGNEAgents(CFAR_Trial_gne__c trial){
        String gneAgents = '';
        for(CFAR_Trial_Other_GNE_Agent_gne__c agent : trial.gSTARS_Trial_Other_GNE_Agents__r){
            gneAgents += agent.frm_Other_GNE_Agent_Generic_gne__c + ', ';
        }
        if(gneAgents == '' && trial.Other_GNE_Agents_Multi_gne__c == 'N/A') {
            gneAgents = 'N/A';
            return gneAgents;
        } else {
            return gneAgents;
        }
        return gneAgents.removeEnd(', ');
    }
    
    private static Date setContractFullyExecutedDate(List<CFAR_Budget_Contract_Tracking_gne__c> trackings) {
        Date retVal;
        if (trackings.isEmpty()) {
            return retVal;
        }
        retVal = trackings[0].Fully_Executed_Date_gne__c;
        for (CFAR_Budget_Contract_Tracking_gne__c tracking : trackings) {   
            if (retVal > tracking.Fully_Executed_Date_gne__c) {
                retVal = tracking.Fully_Executed_Date_gne__c;               
            }
        }
        return retVal;
    }
    
    private static Date setContractExpiryDate(List<CFAR_Budget_Contract_Tracking_gne__c> trackings) {
        Date retVal;
        if (trackings.isEmpty()) {
            return retVal;
        }
        retVal = trackings[0].Contract_Expiry_Date_gne__c;
        for (CFAR_Budget_Contract_Tracking_gne__c tracking : trackings) {   
            if (retVal < tracking.Contract_Expiry_Date_gne__c) {
                retVal = tracking.Contract_Expiry_Date_gne__c;               
            }
        }
        return retVal;
    }
    
    private static void fillProjectionsFields(
        CFAR_FinanceReport_DataModel.SingleRowWrapper srw, 
        List<CFAR_Budget_CPS_Projection_gne__c> projections
    ) {
        if(projections.isEmpty()){
            return;
        }
        for (CFAR_Budget_CPS_Projection_gne__c projection : projections) {
            if (Integer.valueOf(projection.Year_gne__c) == System.today().year()) {
                srw.q1 = (projection.Quarter_1_gne__c != null) ? projection.Quarter_1_gne__c.setScale(2) : 0;
                srw.q2 = (projection.Quarter_2_gne__c != null) ? projection.Quarter_2_gne__c.setScale(2) : 0;
                srw.q3 = (projection.Quarter_3_gne__c != null) ? projection.Quarter_3_gne__c.setScale(2) : 0;
                srw.q4 = (projection.Quarter_4_gne__c != null ) ? projection.Quarter_4_gne__c.setScale(2) : 0;
            } else if (Integer.valueOf(projection.Year_gne__c) == System.today().year()+1) {
                srw.year1FwdProjectionsTotal = (projection.frm_Total_Amount_gne__c != null) ? projection.frm_Total_Amount_gne__c.setScale(2) : 0;
            } else if (Integer.valueOf(projection.Year_gne__c) == System.today().year()+2) {
                srw.year2FwdProjectionsTotal = (projection.frm_Total_Amount_gne__c != null) ? projection.frm_Total_Amount_gne__c.setScale(2) : 0;
            } else if (Integer.valueOf(projection.Year_gne__c) == System.today().year()+3) {
                srw.year3FwdProjectionsTotal = (projection.frm_Total_Amount_gne__c != null) ? projection.frm_Total_Amount_gne__c.setScale(2) : 0;
            }
        }
    }
    
    private static CFAR_SearchParameters setSearchParams(
        String indication, 
        String product, 
        String studyNo, 
        String studyStatus, 
        String therapeuticArea, 
        String trialType, 
        String subjectType, 
        String pediatricStudies,
        String specIndications,
        String impacts,
        String SRTs,
        String teamMember,
        String GNEs,
        String inclusiveResearch,
        String ctms, 
        String wbs
    ) {
        CFAR_SearchParameters searchParams = new CFAR_SearchParameters();
        if (String.isNotBlank(indication)) {
            List<String> giIds = indication.split(';', -1);           
            List<CFAR_General_Indication_for_Trial_gne__c> gis = [
                SELECT CFAR_Trial_ref_gne__c, CFAR_General_Indication_ref_gne__c 
                FROM CFAR_General_Indication_for_Trial_gne__c 
                WHERE CFAR_General_Indication_ref_gne__c in :giIds
            ];
            Set<String> trialIdsForGI = new Set<String>();
            Map<String, Set<String>> trialsMapForGI = new Map<String, Set<String>>();
            for(CFAR_General_Indication_for_Trial_gne__c gi : gis) {
                if(!trialsMapForGI.containsKey(gi.CFAR_Trial_ref_gne__c)){
                    trialsMapForGI.put(gi.CFAR_Trial_ref_gne__c, new Set<String>());
                }
                trialsMapForGI.get(gi.CFAR_Trial_ref_gne__c).add(gi.CFAR_General_Indication_ref_gne__c);                        
            }
            for(String trialId : trialsMapForGI.keySet()) {
                if(trialsMapForGI.get(trialId).size() == giIds.size()){
                    trialIdsForGI.add(trialId); 
                }
            }
            searchParams.andInParameters.put('Id', new List<String>(trialIdsForGI));
        }
        if (String.isNotBlank(product)) {
            searchParams.andInParameters.put('Product_ref_gne__c', product.split(';', -1));
        }
        if (String.isNotBlank(studyNo)) {
            searchParams.andLikeParameters.put('Name', studyNo);
        }
        if (String.isNotBlank(studyStatus)) {
            searchParams.andInParameters.put('Trial_Status_ref_gne__c', studyStatus.split(';', -1));
        }
        if (String.isNotBlank(therapeuticArea)) {
            searchParams.andInParameters.put('Therapeutic_Area_ref_gne__c', therapeuticArea.split(';', -1));
        }
        if (String.isNotBlank(trialType)) {
            searchParams.andInParameters.put('Trial_Type_ref_gne__c', trialType.split(';', -1));
        }
        if (String.isNotBlank(subjectType)) {
            searchParams.orEqualsParameters.put('Subject_Type__c', subjectType.split(';', -1));
        }
        if (String.isNotBlank(pediatricStudies)) {
            searchParams.orEqualsParameters.put('Pediatric_Study_gne__c', pediatricStudies.split(';', -1));
        }
        if (String.isNotBlank(specIndications)) {
            List<CFAR_Specific_Indication_for_Trial_gne__c> sis = [SELECT CFAR_Trial_ref_gne__c, CFAR_Specific_Indication_ref_gne__c FROM CFAR_Specific_Indication_for_Trial_gne__c WHERE CFAR_Specific_Indication_ref_gne__c IN : specIndications.split(';', -1)];
            Set<String> trialIdsForSI = new Set<String>();
            for (CFAR_Specific_Indication_for_Trial_gne__c si : sis) {
                trialIdsForSi.add((String)si.CFAR_Trial_ref_gne__c);
            }
            if (searchParams.andInParameters.containsKey('Id') && !searchParams.andInParameters.get('Id').isEmpty()) {
                trialIdsForSI.retainAll(searchParams.andInParameters.get('Id'));
                searchParams.andInParameters.put('Id', new List<String>(trialIdsForSI));
            } else {
                searchParams.andInParameters.put('Id', new List<String>(trialIdsForSI));
            }
        }
        if (String.isNotBlank(impacts)) {
            searchParams.includesAny.put('Impacts_gne__c', impacts.split(';', -1));
        }
        if (String.isNotBlank(SRTs)) {
            searchParams.andInParameters.put('SRT_Team_ref_gne__c', SRTs.split(';', -1));
        }
        if (String.isNotBlank(teamMember)) {
            Set<String> tmTrialIds = CFAR_Utils.getTrialsForContacts(teamMember.split(';', -1));
            if (searchParams.andInParameters.containsKey('Id') && !searchParams.andInParameters.get('Id').isEmpty()) {
                tmTrialIds.retainAll(searchParams.andInParameters.get('Id'));
            }
            searchParams.andInParameters.put('Id', new List<String>(tmTrialIds));
        }
        if (String.isNotBlank(GNEs)) {
            searchParams.andInParameters.put('Dollar_and_Drug_ref_gne__c', GNEs.split(';', -1));
        }
        if (String.isNotBlank(inclusiveResearch)) {
            searchParams.andInParameters.put('Inclusive_Research_gne__c', inclusiveResearch.split(';', -1));
        }
        if(String.isNotBlank(ctms)){
            searchParams.andLikeParameters.put('CTMS_gne__c', ctms);
        }
        if(String.isNotBlank(wbs)) {        
            Map<String,String> WBSesMap = new Map<String,String>();
            WBSesMap.put('CFAR_WBS_ref_gne__r.GSR_WBS_gne__c', wbs);
            WBSesMap.put('CFAR_WBS_ref_gne__r.Old_WBS_Code_gne__c', wbs);
            searchParams.orLikeParameters.put('WBS', WBSesMap);  
        }
        return searchParams;
    }
}