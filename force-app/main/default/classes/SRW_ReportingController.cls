global without sharing class SRW_ReportingController {
    
    public String pageContent {get; set;}
    public String activeReportName {get; set;}

    public SRW_ReportingController() {
    }

    @RemoteAction
    global static String getReport1JSON(String tpStatus) {
        List<SRW_ReportWrappers.SRW_ReportTable> report1Data = new List<SRW_ReportWrappers.SRW_ReportTable>();
        report1Data.add(new SRW_ReportWrappers.SRW_ReportTable('table1' , getReport1Table1(tpStatus)));
        return JSON.serialize(report1Data);
    }

    @RemoteAction
    global static String getReport2JSON(List<String> years, List<String> months, List<String> statuses) {
        List<SRW_ReportWrappers.SRW_ReportTable> report2Data = new List<SRW_ReportWrappers.SRW_ReportTable>();
        report2Data.add(new SRW_ReportWrappers.SRW_ReportTable('table1' , getReport2Table1(years, months, statuses)));
        report2Data.add(new SRW_ReportWrappers.SRW_ReportTable('table2' , getReport2Table2(years, months, statuses)));
        return JSON.serialize(report2Data); 
    }

    @RemoteAction
    global static String getReport3JSON(String status) {
        List<SRW_ReportWrappers.SRW_ReportTable> report3Data = new List<SRW_ReportWrappers.SRW_ReportTable>();
        report3Data.add(new SRW_ReportWrappers.SRW_ReportTable('table1' , getReport3Table1(status)));
        return JSON.serialize(report3Data);
    }

    @RemoteAction
    global static String getReport4JSON(List<String> brands) {
        List<SRW_ReportWrappers.SRW_ReportTable> report4Data = new List<SRW_ReportWrappers.SRW_ReportTable>();
        report4Data.add(new SRW_ReportWrappers.SRW_ReportTable('table1' , getReport4Table1(brands)));
        return JSON.serialize(report4Data);
    }

    @RemoteAction
    global static String getReport5JSON(String status, List<String> tps) {
        List<SRW_ReportWrappers.SRW_ReportTable> report5Data = new List<SRW_ReportWrappers.SRW_ReportTable>();
        report5Data.add(new SRW_ReportWrappers.SRW_ReportTable('table1' , getReport5Table1(status, tps)));
        return JSON.serialize(report5Data);
    }

    @RemoteAction
    global static String getReport6JSON(List<String> years, List<String> months, List<String> tps, String submissionStatus, String quantityFilter) {
        List<SRW_ReportWrappers.SRW_ReportTable> report6Data = new List<SRW_ReportWrappers.SRW_ReportTable>();
        report6Data.add(new SRW_ReportWrappers.SRW_ReportTable('table1' , getReport6Table1(years, months, tps, submissionStatus, quantityFilter)));
        report6Data.add(new SRW_ReportWrappers.SRW_ReportTable('table2' , getReport6Table2(years, months, tps, submissionStatus, quantityFilter)));
        return JSON.serialize(report6Data); 
    }

    @RemoteAction
    global static String getReport7JSON(List<String> tps) {
        List<SRW_ReportWrappers.SRW_ReportTable> report7Data = new List<SRW_ReportWrappers.SRW_ReportTable>();
        report7Data.add(new SRW_ReportWrappers.SRW_ReportTable('table1' , getReport7Table1(tps)));
        return JSON.serialize(report7Data);
    }

    @RemoteAction
    global static String getReport8JSON(List<String> presOrgs, List<String> tps) {
        List<SRW_ReportWrappers.SRW_ReportTable> report8Data = new List<SRW_ReportWrappers.SRW_ReportTable>();
        report8Data.add(new SRW_ReportWrappers.SRW_ReportTable('table1' , getReport8Table1(presOrgs, tps)));
        return JSON.serialize(report8Data);
    }
    @RemoteAction
    global static String getReport9JSON(String dateFrom, String dateTo) {
        Date dateFromDate = Date.parse(dateFrom);
        Date dateToDate = Date.parse(dateTo);
        List<SRW_ReportWrappers.SRW_ReportTable> report9Data = new List<SRW_ReportWrappers.SRW_ReportTable>();
        report9Data.add(new SRW_ReportWrappers.SRW_ReportTable('table1' , getReport9Table1(dateFromDate, dateToDate)));
        report9Data.add(new SRW_ReportWrappers.SRW_ReportTable('table2' , getReport9Table2(dateFromDate, dateToDate)));
        return JSON.serialize(report9Data); 
    }

    @RemoteAction
    global static String getReport10JSON(List<String> months) {
        List<SRW_ReportWrappers.SRW_ReportTable> report10Data = new List<SRW_ReportWrappers.SRW_ReportTable>();
        report10Data.add(new SRW_ReportWrappers.SRW_ReportTable('table1' , getReport10Table1(months)));
        report10Data.add(new SRW_ReportWrappers.SRW_ReportTable('table2' , getReport10Table2(months)));
        return JSON.serialize(report10Data);    
    }

    @RemoteAction
    global static String getReport11JSON(List<String> months) {
        List<SRW_ReportWrappers.SRW_ReportTable> report11Data = new List<SRW_ReportWrappers.SRW_ReportTable>();
        report11Data.add(new SRW_ReportWrappers.SRW_ReportTable('table1' , getReport11Table1(months)));
        return JSON.serialize(report11Data);    
    }

    @RemoteAction
    global static String getReport12JSON(List<String> months, List<String> tps) {
        List<SRW_ReportWrappers.SRW_ReportTable> report12Data = new List<SRW_ReportWrappers.SRW_ReportTable>();
        report12Data.add(new SRW_ReportWrappers.SRW_ReportTable('table1' , getReport12Table1(months, tps)));
        report12Data.add(new SRW_ReportWrappers.SRW_ReportTable('table2' , getReport12Table2(months, tps)));
        return JSON.serialize(report12Data);    
    }

    @RemoteAction
    global static String getReport13JSON(String dateFrom, String dateTo, List<String> tps, String status) {
        Date dateFromDate = Date.parse(dateFrom);
        Date dateToDate = Date.parse(dateTo);
        List<SRW_ReportWrappers.SRW_ReportTable> report13Data = new List<SRW_ReportWrappers.SRW_ReportTable>();
        report13Data.add(new SRW_ReportWrappers.SRW_ReportTable('table1' , getReport13Table1(dateFromDate, dateToDate, tps, status)));
        return JSON.serialize(report13Data);    
    }

    @RemoteAction
    global static String getReport15JSON(List<String> years, List<String> months, List<String> tps) {
        List<SRW_ReportWrappers.SRW_ReportTable> report15Data = new List<SRW_ReportWrappers.SRW_ReportTable>();
        report15Data.add(new SRW_ReportWrappers.SRW_ReportTable('table1' , getReport15Table1(years, months, tps)));
        return JSON.serialize(report15Data);    
    }
    // ###################################################################################
    // ########################### REPORT 1 ##############################################
    // ################# Trading Partner List by Status ##################################
    // ###################################################################################

    public static List<SRW_ReportWrappers.SRW_Report1Table1> getReport1Table1(String tpStatus) {
        
        List<SRW_Trading_Partner_Profile__c> tpList = new List<SRW_Trading_Partner_Profile__c>();       
        List<SRW_ReportWrappers.SRW_Report1Table1> tpValues = new List<SRW_ReportWrappers.SRW_Report1Table1>();
        Boolean filterStatus = false;
        
        if(String.isBlank(tpStatus))
            return tpValues;
        
        if('All'.equals(tpStatus)) {
            tpList = [select id,MCCO_Account_Manger_gne__c,Trading_Partner_Name_gne__c,Trading_Partner_Address_1_gne__c,Trading_Partner_Address_2_gne__c,State_gne__c,City_gne__c,Zip_Code_gne__c,Contract_Effective_Date_gne__c,Contract_Termination_Date_gne__c,(Select Status_gne__c from SRW_Security_Community_Data__r limit 1) from SRW_Trading_Partner_Profile__c];      
        } else {
            tpList = [select id,MCCO_Account_Manger_gne__c,Trading_Partner_Name_gne__c,Trading_Partner_Address_1_gne__c,Trading_Partner_Address_2_gne__c,State_gne__c,City_gne__c,Zip_Code_gne__c,Contract_Effective_Date_gne__c,Contract_Termination_Date_gne__c,(Select Status_gne__c from SRW_Security_Community_Data__r limit 1) from SRW_Trading_Partner_Profile__c];
            filterStatus = true;
        }


        for(SRW_Trading_Partner_Profile__c tp : tpList) {
            if(filterStatus) {

                if(tp.SRW_Security_Community_Data__r.size() != 0 && tp.SRW_Security_Community_Data__r[0].Status_gne__c.equals(tpStatus)) {
                    tpValues.add(new SRW_ReportWrappers.SRW_Report1Table1(
                        tp.Trading_Partner_Name_gne__c, 
                        tp.MCCO_Account_Manger_gne__c,
                        tp.Trading_Partner_Address_1_gne__c,
                        tp.Trading_Partner_Address_2_gne__c,
                        tp.City_gne__c,
                        tp.State_gne__c,
                        tp.Zip_Code_gne__c,
                        tp.SRW_Security_Community_Data__r != null ? tp.SRW_Security_Community_Data__r[0].Status_gne__c : '',
                        tp.Contract_Effective_Date_gne__c,
                        tp.Contract_Termination_Date_gne__c));
                }
            }
            else {
                tpValues.add(new SRW_ReportWrappers.SRW_Report1Table1(
                    tp.Trading_Partner_Name_gne__c, 
                    tp.MCCO_Account_Manger_gne__c,
                    tp.Trading_Partner_Address_1_gne__c,
                    tp.Trading_Partner_Address_2_gne__c,
                    tp.City_gne__c,
                    tp.State_gne__c,
                    tp.Zip_Code_gne__c,
                    tp.SRW_Security_Community_Data__r.size() != 0 ? tp.SRW_Security_Community_Data__r[0].Status_gne__c : '',
                    tp.Contract_Effective_Date_gne__c,
                    tp.Contract_Termination_Date_gne__c));
            }
        }
        return tpValues;
    }

    // ###################################################################################
    // ########################### REPORT 2 ##############################################
    // ################# Trading Partner List by By Data Submission Status ###############
    // ###################################################################################
    public static List<SRW_ReportWrappers.SRW_Report2Table1> getReport2Table1(List<String> years, List<String> months, List<String> statuses) {
        List<SRW_ReportWrappers.SRW_Report2Table1> tpDMValues = new List<SRW_ReportWrappers.SRW_Report2Table1>();
        if(years == null || years.isEmpty() || months == null || months.isEmpty() || statuses == null || statuses.isEmpty())
            return tpDMValues;

        Map<Id,String> tpIdTOStatus = new Map<Id,String>();
        for(SRW_Security_Community_Data__c tmp : [Select Trading_Partner_gne__c,Status_gne__c from SRW_Security_Community_Data__c]) {
            tpIdTOStatus.put(tmp.Trading_Partner_gne__c,tmp.Status_gne__c);
        }
        Set<String> selectedStatusesSet = new Set<String>();
        Set<String> selectedDataSubmissionStatuses = new Set<String>();
        selectedDataSubmissionStatuses.addAll(statuses);
        if(selectedDataSubmissionStatuses.contains('all')){
            selectedStatusesSet.add('all');
        }
        if(selectedDataSubmissionStatuses.contains('Not Submitted')){
            selectedStatusesSet.add('Open');
        }
        if(selectedDataSubmissionStatuses.contains('Submitted - Sales')){
            selectedStatusesSet.add('Reopen');
            selectedStatusesSet.add('Resubmitted');
            selectedStatusesSet.add('Sweep');
            selectedStatusesSet.add('Resweep');
            selectedStatusesSet.add('Submitted - Sales');
        }
        if(selectedDataSubmissionStatuses.contains('Submitted - No Sales Reported')){
            selectedStatusesSet.add('Submitted - No Sales Reported');
        }
        System.debug('MICK_LOKO : selectedStatusesSet ' + selectedStatusesSet);
        Set<String> selectedYearsSet = new Set<String>();
        selectedYearsSet.addAll(years);
        System.debug('MICK_LOKO : selectedYearsSet ' + selectedYearsSet);
        Set<String> selectedMonthsSet = new Set<String>();
        selectedMonthsSet.addAll(months);
        System.debug('MICK_LOKO : selectedMonthsSet ' + selectedMonthsSet);
        List<SRW_TP_Data_Months__c> tpDMList = new List<SRW_TP_Data_Months__c>();

        List<SRW_DataMonths__c> dmScope = new List<SRW_DataMonths__c>();
        
        if(selectedMonthsSet.contains('all') && selectedYearsSet.contains('all') ) {
            dmScope = [Select Id,Data_Month_Cal_gne__c from SRW_DataMonths__c ORDER BY Data_Year_gne__c,Data_Month_Number_gne__c];

        }   else if (selectedMonthsSet.contains('all') || selectedMonthsSet.isEmpty()) {

            dmScope = [Select Id,Data_Month_Cal_gne__c from SRW_DataMonths__c where Data_Year_gne__c IN :selectedYearsSet ORDER BY Data_Year_gne__c,Data_Month_Number_gne__c];

        }   else if(selectedYearsSet.contains('all') || selectedYearsSet.isEmpty()){

            dmScope = [Select Id,Data_Month_Cal_gne__c from SRW_DataMonths__c where Data_Month_gne__c IN :selectedMonthsSet ORDER BY Data_Year_gne__c,Data_Month_Number_gne__c];

        }  else {

            dmScope = [Select Id,Data_Month_Cal_gne__c from SRW_DataMonths__c where Data_Month_gne__c IN :selectedMonthsSet AND Data_Year_gne__c IN :selectedYearsSet ORDER BY Data_Year_gne__c,Data_Month_Number_gne__c];

        }

        if(selectedStatusesSet.contains('all') || selectedStatusesSet.isEmpty()) {
            tpDMList = [Select Id,Trading_Partner_gne__c,Trading_Partner_gne__r.Trading_Partner_Name_gne__c,Trading_Partner_gne__r.MCCO_Account_Manger_gne__c,Trading_Partner_gne__r.Trading_Partner_Address_1_gne__c,SRW_Data_Month_gne__r.Data_Month_Cal_gne__c ,LastModifiedDate, Data_Month_Status_gne__c  from SRW_TP_Data_Months__c where SRW_Data_Month_gne__c IN :dmScope ORDER BY SRW_Data_Month_gne__r.Data_Year_gne__c,SRW_Data_Month_gne__r.Data_Month_Number_gne__c,Trading_Partner_gne__r.Trading_Partner_Name_gne__c];
        } else {

            tpDMList = [Select Id,Trading_Partner_gne__c,Trading_Partner_gne__r.Trading_Partner_Name_gne__c,Trading_Partner_gne__r.MCCO_Account_Manger_gne__c,Trading_Partner_gne__r.Trading_Partner_Address_1_gne__c,SRW_Data_Month_gne__r.Data_Month_Cal_gne__c,LastModifiedDate, Data_Month_Status_gne__c  from SRW_TP_Data_Months__c where Data_Month_Status_gne__c IN :selectedStatusesSet AND  SRW_Data_Month_gne__c IN :dmScope ORDER BY SRW_Data_Month_gne__r.Data_Year_gne__c,SRW_Data_Month_gne__r.Data_Month_Number_gne__c,Trading_Partner_gne__r.Trading_Partner_Name_gne__c] ;
        }
        
        Map<Id,Map<Id,SRW_TP_Data_Months__c>> tpToDataMonthsMap = new Map<Id,Map<Id,SRW_TP_Data_Months__c>>();
        Map<Id,SRW_Trading_Partner_Profile__c> allTPinScope = new Map<Id,SRW_Trading_Partner_Profile__c> ([Select Id,Trading_Partner_Name_gne__c,Trading_Partner_Address_1_gne__c,MCCO_Account_Manger_gne__c from SRW_Trading_Partner_Profile__c]);
        

        for(SRW_TP_Data_Months__c tmp :tpDMList) {
            if(!tpToDataMonthsMap.containsKey(tmp.Trading_Partner_gne__c)) {
                    Map<Id,SRW_TP_Data_Months__c> dmIDToDM = new Map<Id,SRW_TP_Data_Months__c>();
                    tmp.Data_Month_Status_gne__c = 'Open'.equals(tmp.Data_Month_Status_gne__c) ? 'Not Submitted' : ('Reopen'.equals(tmp.Data_Month_Status_gne__c) || 'Resubmitted'.equals(tmp.Data_Month_Status_gne__c) || 'Sweep'.equals(tmp.Data_Month_Status_gne__c) || 'Resweep'.equals(tmp.Data_Month_Status_gne__c) ? 'Submitted - Sales' : tmp.Data_Month_Status_gne__c);
                    dmIDToDM.put(tmp.SRW_Data_Month_gne__c,tmp);
                    tpToDataMonthsMap.put(tmp.Trading_Partner_gne__c,dmIDToDM);
            } else {

                    Map<Id,SRW_TP_Data_Months__c> tmpMAp =  tpToDataMonthsMap.get(tmp.Trading_Partner_gne__c);
                    tmp.Data_Month_Status_gne__c = 'Open'.equals(tmp.Data_Month_Status_gne__c) ? 'Not Submitted' : ('Reopen'.equals(tmp.Data_Month_Status_gne__c) || 'Resubmitted'.equals(tmp.Data_Month_Status_gne__c) || 'Sweep'.equals(tmp.Data_Month_Status_gne__c) || 'Resweep'.equals(tmp.Data_Month_Status_gne__c) ? 'Submitted - Sales' : tmp.Data_Month_Status_gne__c);
                    tmpMAp.put(tmp.SRW_Data_Month_gne__c,tmp);
            }
        }

        system.debug('LOOP scope size :' + dmScope.size());
        system.debug('LOOP scope :' + dmScope);
        system.debug('LOOP tpToDataMonthsMap.size() :' + tpToDataMonthsMap.size());
        
        map<Id,SRW_ReportWrappers.SRW_Report2Table1> tpToDataMonths = new map<Id,SRW_ReportWrappers.SRW_Report2Table1>();

        for(SRW_DataMonths__c scopeDM : dmScope) {
            system.debug('LOOP DM scope :' + scopeDM.Data_Month_Cal_gne__c);


            for(Id tpdm : tpToDataMonthsMap.keySet()) {
                system.debug('LOOP TP Name :' + allTPinScope.get(tpdm));
                system.debug('LOOP TPScope dataMonths :' + tpToDataMonthsMap.get(tpdm));
                system.debug('LOOP check contains  :' + tpToDataMonths.containsKey(tpdm));
                if(!tpToDataMonths.containsKey(tpdm)) {

                    List<SRW_TP_Data_Months__c> tmpDM = new List<SRW_TP_Data_Months__c>();
                    
                    SRW_ReportWrappers.SRW_Report2Table1 newTPD;

                    if(tpToDataMonthsMap.get(tpdm).containsKey(scopeDM.Id)) {
                        SRW_TP_Data_Months__c currentDM = tpToDataMonthsMap.get(tpdm).get(scopeDM.Id);
                        system.debug('LOOP DM currentDM :' + currentDM);
                        system.debug('Change currentDM status.');
                        tmpDM.add(currentDM);
                            newTPD = new SRW_ReportWrappers.SRW_Report2Table1(
                        currentDM.Trading_Partner_gne__r.Trading_Partner_Name_gne__c, 
                        currentDM.Trading_Partner_gne__r.Trading_Partner_Address_1_gne__c,
                        currentDM.Trading_Partner_gne__r.MCCO_Account_Manger_gne__c,
                        tpIdTOStatus.get(currentDM.Trading_Partner_gne__c),
                        tmpDM);
                            tpToDataMonths.put(currentDM.Trading_Partner_gne__c,newTPD);
                    }   else {

                            tmpDM.add(new SRW_TP_Data_Months__c());
                            SRW_Trading_Partner_Profile__c currTP = allTPinScope.get(tpdm);
                            system.debug('LOOP DM currTP :' + currTP);
                             newTPD = new SRW_ReportWrappers.SRW_Report2Table1(
                        currTP.Trading_Partner_Name_gne__c, 
                        currTP.Trading_Partner_Address_1_gne__c,
                        currTP.MCCO_Account_Manger_gne__c,
                        tpIdTOStatus.get(currTP.Id),
                        tmpDM);
                        tpToDataMonths.put(currTP.Id,newTPD);
                    }
                        
                        
                }
                else {

                    if(tpToDataMonthsMap.get(tpdm).containsKey(scopeDM.Id)) {
                        system.debug('LOOP DM curr :' + tpToDataMonthsMap.get(tpdm).get(scopeDM.Id));
                        tpToDataMonths.get(tpdm).dataMonths.add(new SRW_ReportWrappers.SRW_Report2Table1Helper(tpToDataMonthsMap.get(tpdm).get(scopeDM.Id)));

                    } else {
                        system.debug('LOOP DM curr add blank to existing');
                        tpToDataMonths.get(tpdm).dataMonths.add((new SRW_ReportWrappers.SRW_Report2Table1Helper(new SRW_TP_Data_Months__c())));

                    }

                }

            }
         }
        tpDMValues = tpToDataMonths.values();
        return tpDMValues;
    }

    public static List<SRW_ReportWrappers.SRW_Report2Table2> getReport2Table2(List<String> years, List<String> months, List<String> statuses) {
        List<SRW_ReportWrappers.SRW_Report2Table2> headers = new List<SRW_ReportWrappers.SRW_Report2Table2>();
        if(years == null || years.isEmpty() || months == null || months.isEmpty() || statuses == null || statuses.isEmpty())
            return headers;

        
        Set<String> selectedStatusesSet = new Set<String>();
        selectedStatusesSet.addAll(statuses);
        System.debug('MICK_LOKO : selectedStatusesSet ' + selectedStatusesSet);
        Set<String> selectedYearsSet = new Set<String>();
        selectedYearsSet.addAll(years);
        System.debug('MICK_LOKO : selectedYearsSet ' + selectedYearsSet);
        Set<String> selectedMonthsSet = new Set<String>();
        selectedMonthsSet.addAll(months);
        System.debug('MICK_LOKO : selectedMonthsSet ' + selectedMonthsSet);
        List<SRW_TP_Data_Months__c> tpDMList = new List<SRW_TP_Data_Months__c>();

        List<SRW_DataMonths__c> dmScope = new List<SRW_DataMonths__c>();
        
        if(selectedMonthsSet.contains('all') && selectedYearsSet.contains('all') ) {
            dmScope = [Select Id,Data_Month_Cal_gne__c from SRW_DataMonths__c ORDER BY Data_Year_gne__c,Data_Month_Number_gne__c];

        }   else if (selectedMonthsSet.contains('all') || selectedMonthsSet.isEmpty()) {

            dmScope = [Select Id,Data_Month_Cal_gne__c from SRW_DataMonths__c where Data_Year_gne__c IN :selectedYearsSet ORDER BY Data_Year_gne__c,Data_Month_Number_gne__c];

        }   else if(selectedYearsSet.contains('all') || selectedYearsSet.isEmpty()){

            dmScope = [Select Id,Data_Month_Cal_gne__c from SRW_DataMonths__c where Data_Month_gne__c IN :selectedMonthsSet ORDER BY Data_Year_gne__c,Data_Month_Number_gne__c];

        }  else {

            dmScope = [Select Id,Data_Month_Cal_gne__c from SRW_DataMonths__c where Data_Month_gne__c IN :selectedMonthsSet AND Data_Year_gne__c IN :selectedYearsSet ORDER BY Data_Year_gne__c,Data_Month_Number_gne__c];

        }

        for(SRW_DataMonths__c tmpSc : dmScope){

            headers.add(new SRW_ReportWrappers.SRW_Report2Table2(tmpSC.Data_Month_Cal_gne__c));
            headers.add(new SRW_ReportWrappers.SRW_Report2Table2('Last Updated'));
        }
        return headers;
        //headersJson = JSON.serialize(headers);
        //System.debug('------TOTALS JSON ' + headersJson );
        //return headersJson;

    }

    // ###################################################################################
    // ########################### REPORT 3 ##############################################
    // ################# Product List by Status ##########################################
    // ###################################################################################
    public static List<SRW_ReportWrappers.SRW_Report34Table1> getReport3Table1(String status) {
        List<SRW_ReportWrappers.SRW_Report34Table1> prodValues = new List<SRW_ReportWrappers.SRW_Report34Table1>();
        if(String.isBlank(status))
            return prodValues;

        
        List<Product_vod__c> prodlist = new List<Product_vod__c>();

        if('All'.equals(status)) {
            prodlist = [Select Id,active__c,SRW_Product_De_activation_Date_gne__c,SRW_Product_Effective_Date_gne__c,Product_Type_vod__c,Name,NDC_Number_gne__c,SRW_Comments_gne__c,Brand_Code_gne__c,SRW_Data_Type_gne__c  From Product_vod__c  where Product_Type_vod__c = 'SRW'];     
        } else if ('Active'.equals(status)) {
            prodlist = [Select Id,active__c,SRW_Product_De_activation_Date_gne__c,SRW_Product_Effective_Date_gne__c,Product_Type_vod__c,Name,NDC_Number_gne__c,SRW_Comments_gne__c,Brand_Code_gne__c,SRW_Data_Type_gne__c  From Product_vod__c  where Product_Type_vod__c = 'SRW' AND active__c = true];        
        } else if ('Inactive'.equals(status)) {
            prodlist = [Select Id,active__c,SRW_Product_De_activation_Date_gne__c,SRW_Product_Effective_Date_gne__c,Product_Type_vod__c,Name,NDC_Number_gne__c,SRW_Comments_gne__c,Brand_Code_gne__c,SRW_Data_Type_gne__c  From Product_vod__c  where Product_Type_vod__c = 'SRW' AND active__c = false];       
        }

        for(Product_vod__c prod : prodlist) {
            prodValues.add(new SRW_ReportWrappers.SRW_Report34Table1(
                    prod.Brand_Code_gne__c, 
                    prod.Name,
                    prod.NDC_Number_gne__c,
                    prod.SRW_Product_Effective_Date_gne__c,
                    prod.SRW_Product_De_activation_Date_gne__c,
                    prod.SRW_Comments_gne__c,
                    String.valueOf(prod.active__c)));
        }
        return prodValues;
    }

    // ###################################################################################
    // ########################### REPORT 4 ##############################################
    // ################# Product List by Brand ###########################################
    // ###################################################################################

    public static List<SRW_ReportWrappers.SRW_Report34Table1> getReport4Table1(List<String> brands) {


        List<SRW_ReportWrappers.SRW_Report34Table1> prodValues = new List<SRW_ReportWrappers.SRW_Report34Table1>();
        if(brands == null || brands.isEmpty())
            return prodValues;

        Set<String> selectedBrandListSet = new Set<String>();
        selectedBrandListSet.addAll(brands);

        List<Product_vod__c> prodlist = new List<Product_vod__c>();

        if( selectedBrandListSet.contains('all')) {
            prodlist = [Select Id,active__c,SRW_Product_De_activation_Date_gne__c,SRW_Product_Effective_Date_gne__c,Product_Type_vod__c,Name,NDC_Number_gne__c,SRW_Comments_gne__c,Brand_Code_gne__c,SRW_Data_Type_gne__c  From Product_vod__c  where Product_Type_vod__c = 'SRW'];     
        } else {
            prodlist = [Select Id,active__c,SRW_Product_De_activation_Date_gne__c,SRW_Product_Effective_Date_gne__c,Product_Type_vod__c,Name,NDC_Number_gne__c,SRW_Comments_gne__c,Brand_Code_gne__c,SRW_Data_Type_gne__c  From Product_vod__c  where Product_Type_vod__c = 'SRW' and Brand_Code_gne__c in: selectedBrandListSet];      
        }


        for(Product_vod__c prod : prodlist) {
            prodValues.add(new SRW_ReportWrappers.SRW_Report34Table1(
                    prod.Brand_Code_gne__c, 
                    prod.Name,
                    prod.NDC_Number_gne__c,
                    prod.SRW_Product_Effective_Date_gne__c,
                    prod.SRW_Product_De_activation_Date_gne__c,
                    prod.SRW_Comments_gne__c,
                    String.valueOf(prod.active__c)));
        }
        return prodValues;

        
    }

    // ###################################################################################
    // ########################### REPORT 5 ##############################################
    // ################# Prescriber List by Trading Partner ##############################
    // ###################################################################################
    public static List<SRW_ReportWrappers.SRW_Report5Table1> getReport5Table1(String status, List<String> tps) {


        List<SRW_ReportWrappers.SRW_Report5Table1> poValues = new List<SRW_ReportWrappers.SRW_Report5Table1>();
        if(String.isBlank(status) || tps == null || tps.isEmpty())
            return poValues;

        Set<String> selectedTPsListSet = new Set<String>();
        selectedTPsListSet.addAll(tps);

        List<SRW_Prscr_or_Org_Location__c> polist = new List<SRW_Prscr_or_Org_Location__c>();

        if('All'.equals(status) && selectedTPsListSet.contains('all')) {
            polist = [SELECT id, Prescriber_or_Organization_gne__r.Type_gne__c, Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Active_gne__c, Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Trading_Partner_Address_1_gne__c, Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Trading_Partner_Name_gne__c, Prescriber_or_Organization_gne__r.Prescriber_First_Name_gne__c,  Prescriber_or_Organization_gne__r.Prescriber_Last_Name_gne__c,  Prescriber_or_Organization_gne__r.Organization_Name_gne__c, Unique_Identifier_gne__c, Type_of_Identifier_gne__c, Identifier_gne__c, Street_Address_1_gne__c, Street_Address_2_gne__c, City_gne__c, State_gne__c, Zip_Code_gne__c, Location_Identifier_gne__c FROM SRW_Prscr_or_Org_Location__c WHERE Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Contact_gne__c != null ORDER BY Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Trading_Partner_Name_gne__c, Prescriber_or_Organization_gne__r.Organization_Name_gne__c];      
        } else if('All'.equals(status)) {
            polist = [SELECT id, Prescriber_or_Organization_gne__r.Type_gne__c, Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Active_gne__c, Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Trading_Partner_Address_1_gne__c, Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Trading_Partner_Name_gne__c, Prescriber_or_Organization_gne__r.Prescriber_First_Name_gne__c,  Prescriber_or_Organization_gne__r.Prescriber_Last_Name_gne__c,  Prescriber_or_Organization_gne__r.Organization_Name_gne__c, Unique_Identifier_gne__c, Type_of_Identifier_gne__c, Identifier_gne__c, Street_Address_1_gne__c, Street_Address_2_gne__c, City_gne__c, State_gne__c, Zip_Code_gne__c, Location_Identifier_gne__c FROM SRW_Prscr_or_Org_Location__c WHERE Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Contact_gne__c != null and Prescriber_or_Organization_gne__r.Trading_Partner_gne__c in: selectedTPsListSet ORDER BY Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Trading_Partner_Name_gne__c, Prescriber_or_Organization_gne__r.Organization_Name_gne__c];      
        } else if(selectedTPsListSet.contains('all')) {
            List<SRW_Security_Community_Data__c> securCommList = [Select Id,Trading_Partner_gne__c, Trading_Partner_gne__r.Contact_gne__c, Status_gne__c from SRW_Security_Community_Data__c
                                                            WHERE Trading_Partner_gne__r.Contact_gne__c != null and Status_gne__c =: status];
            List<String> tpIds = new List<String>();
            for(SRW_Security_Community_Data__c scd :securCommList){
                tpIds.add(scd.Trading_Partner_gne__c);
            }

            polist = [SELECT id, Prescriber_or_Organization_gne__r.Type_gne__c, Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Active_gne__c, Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Trading_Partner_Address_1_gne__c, Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Trading_Partner_Name_gne__c, Prescriber_or_Organization_gne__r.Prescriber_First_Name_gne__c,  Prescriber_or_Organization_gne__r.Prescriber_Last_Name_gne__c,  Prescriber_or_Organization_gne__r.Organization_Name_gne__c, Unique_Identifier_gne__c, Type_of_Identifier_gne__c, Identifier_gne__c, Street_Address_1_gne__c, Street_Address_2_gne__c, City_gne__c, State_gne__c, Zip_Code_gne__c, Location_Identifier_gne__c FROM SRW_Prscr_or_Org_Location__c WHERE Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Contact_gne__c != null and Prescriber_or_Organization_gne__r.Trading_Partner_gne__c in: tpIds  ORDER BY Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Trading_Partner_Name_gne__c, Prescriber_or_Organization_gne__r.Organization_Name_gne__c];      
        } else {
            List<SRW_Security_Community_Data__c> securCommList = [Select Id,Trading_Partner_gne__c, Trading_Partner_gne__r.Contact_gne__c, Status_gne__c from SRW_Security_Community_Data__c
                                                            WHERE Trading_Partner_gne__r.Contact_gne__c != null and Status_gne__c =: status];
            List<String> tpIds = new List<String>();
            for(SRW_Security_Community_Data__c scd :securCommList){
                if(selectedTPsListSet.contains(scd.Trading_Partner_gne__c))
                    tpIds.add(scd.Trading_Partner_gne__c);
            }

            polist = [SELECT id, Prescriber_or_Organization_gne__r.Type_gne__c, Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Active_gne__c, Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Trading_Partner_Address_1_gne__c, Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Trading_Partner_Name_gne__c, Prescriber_or_Organization_gne__r.Prescriber_First_Name_gne__c,  Prescriber_or_Organization_gne__r.Prescriber_Last_Name_gne__c,  Prescriber_or_Organization_gne__r.Organization_Name_gne__c, Unique_Identifier_gne__c, Type_of_Identifier_gne__c, Identifier_gne__c, Street_Address_1_gne__c, Street_Address_2_gne__c, City_gne__c, State_gne__c, Zip_Code_gne__c, Location_Identifier_gne__c FROM SRW_Prscr_or_Org_Location__c WHERE Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Contact_gne__c != null and Prescriber_or_Organization_gne__r.Trading_Partner_gne__c in: tpIds  ORDER BY Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Trading_Partner_Name_gne__c, Prescriber_or_Organization_gne__r.Organization_Name_gne__c];      
        }
        List<String> ids = new List<String>();
        for(SRW_Prscr_or_Org_Location__c po : polist) {
            ids.add(po.Prescriber_or_Organization_gne__r.Trading_Partner_gne__c);
        }

        List<SRW_Security_Community_Data__c> statusCommList = [Select Id,Trading_Partner_gne__c, Status_gne__c from SRW_Security_Community_Data__c
                                                            WHERE Trading_Partner_gne__r.Contact_gne__c != null and Trading_Partner_gne__c in: ids];
        
        Map<String, String> statusMap = new Map<String, String>();  
        for(SRW_Security_Community_Data__c cds : statusCommList) {
            statusMap.put(cds.Trading_Partner_gne__c, cds.Status_gne__c);
        }

        for(SRW_Prscr_or_Org_Location__c po : polist) {
                        
            poValues.add(new SRW_ReportWrappers.SRW_Report5Table1(
                    po.Prescriber_or_Organization_gne__r.Trading_Partner_gne__c,
                    po.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Trading_Partner_Name_gne__c, 
                    po.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Trading_Partner_Address_1_gne__c,
                    statusMap.get(po.Prescriber_or_Organization_gne__r.Trading_Partner_gne__c),
                    'Prescriber'.equals(po.Prescriber_or_Organization_gne__r.Type_gne__c) ? po.Prescriber_or_Organization_gne__r.Prescriber_First_Name_gne__c + ' ' + po.Prescriber_or_Organization_gne__r.Prescriber_Last_Name_gne__c : po.Prescriber_or_Organization_gne__r.Organization_Name_gne__c,
                    po.Type_of_Identifier_gne__c,
                    po.Identifier_gne__c,
                    po.Street_Address_1_gne__c,
                    po.Street_Address_2_gne__c,
                    po.City_gne__c,
                    po.State_gne__c,
                    po.Zip_Code_gne__c,
                    po.Location_Identifier_gne__c));
        }
        return poValues;
    }
    // ###################################################################################
    // ########################### REPORT 6 ##############################################
    // ################# Trading Partner Sales Activity ##################################
    // ###################################################################################
    
    public static List<SRW_ReportWrappers.SRW_Report6Table1> getReport6Table1(List<String> years, List<String> months, List<String> tps, String submissionStatus, String quantityFilter) {

        //showPresSummaryTable = false;
        system.debug('submission status: ' + submissionStatus + ' || quntityFilter: ' + quantityFilter);
        if('no sales'.equals(submissionStatus)){
            if(years == null || years.isEmpty() || months == null || months.isEmpty() || tps == null || tps.isEmpty())
                return new List<SRW_ReportWrappers.SRW_Report6Table1>();
            String query = 'Select id, Trading_Partner_gne__c, Trading_Partner_gne__r.Active_gne__c, Trading_Partner_gne__r.Trading_Partner_Address_1_gne__c, Trading_Partner_gne__r.Trading_Partner_Name_gne__c,';
            query += 'SRW_Data_Month_gne__r.Data_Year_gne__c, SRW_Data_Month_gne__r.Data_Month_Cal_gne__c, SRW_Data_Month_gne__r.Data_Month_Number_gne__c, SRW_Data_Month_gne__r.Data_Month_gne__c';
            query += ' FROM SRW_TP_Data_Months__c WHERE id not in (select TP_Data_Month_gne__c FROM SRW_Sales_Data_gne__c) AND Data_Month_Status_gne__c = \'Sweep\'';
            List<String> qString = new List<String>();
            String whereString = '';
            
            Set<String> yrsSet = new Set<String>();
            Set<String> mthsSet = new Set<String>();
            Set<String> tpsSet = new Set<String>();

            //if(parameters.yrs != null)
                yrsSet.addAll(years);
            //if(parameters.mths != null)
                mthsSet.addAll(months);
            //if(parameters.tps != null)
                tpsSet.addAll(tps);

            if(!tpsSet.contains('all') && !tpsSet.isEmpty()) {
                String q = ' Trading_Partner_gne__c in (';
                for(String tp :tpsSet) {
                    q += '\'' + tp + '\',';
                }
                if(q.endsWith(','))
                    q = q.removeEndIgnoreCase(',');
                q += ') ';
                qString.add(q);
            } 

            if(!yrsSet.contains('all') && !yrsSet.isEmpty()) {
                String q = ' SRW_Data_Month_gne__r.Data_Year_gne__c in (';
                for(String yr :yrsSet) {
                    q += '\'' + yr + '\',';
                }
                if(q.endsWith(','))
                    q = q.removeEndIgnoreCase(',');
                q += ') ';
                qString.add(q);
            } 

            if(!mthsSet.contains('all') && !mthsSet.isEmpty()) {
                String q = ' SRW_Data_Month_gne__r.Data_Month_Number_gne__c in (';
                for(String mth :mthsSet) {
                    q +=  Integer.valueOf(mth) + ',';
                }
                if(q.endsWith(','))
                    q = q.removeEndIgnoreCase(',');
                q += ') ';
                qString.add(q);
            }
            qString.add(' Trading_Partner_gne__r.Contact_gne__c != null '); 

            if(!qString.isEmpty()) {
                for(String q : qString) {
                    whereString += ' AND ';
                    whereString += q;
                }
            }
            query += whereString;
            query += ' order by SRW_Data_Month_gne__r.Data_Year_gne__c desc, SRW_Data_Month_gne__r.Data_Month_Number_gne__c';
            System.debug(' ----- query string ' + query);

            List<SRW_TP_Data_Months__c> tpdmWithNoSales = Database.query(query);

            List<SRW_ReportWrappers.SRW_Report6Table1> prods = clearReport6Table1(tpdmWithNoSales);
            return prods;
        }else{
            if(years == null || years.isEmpty() || months == null || months.isEmpty() || tps == null || tps.isEmpty())
                return new List<SRW_ReportWrappers.SRW_Report6Table1>();

            String query = 'Select id, Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Type_gne__c, Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_First_Name_gne__c, Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_Last_Name_gne__c, Set_Sequence_Number_gne__c, Prescriber_Organization_Location_gne__c, Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__c, Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Organization_Name_gne__c ,Quantity_gne__c, Product_gne__c, Product_gne__r.Name ,Trading_Partner_gne__c, Trading_Partner_gne__r.Active_gne__c, Trading_Partner_gne__r.Trading_Partner_Address_1_gne__c, Trading_Partner_gne__r.Trading_Partner_Name_gne__c,TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Year_gne__c,TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c,TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Number_gne__c,TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_gne__c from SRW_Sales_Data_gne__c ';
            List<String> qString = new List<String>();
            String whereString = '';
            
            Set<String> yrsSet = new Set<String>();
            Set<String> mthsSet = new Set<String>();
            Set<String> tpsSet = new Set<String>();
            //if(parameters.yrs != null)
                yrsSet.addAll(years);
            //if(parameters.mths != null)
                mthsSet.addAll(months);
            //if(parameters.tps != null)
                tpsSet.addAll(tps);
            
            if(!tpsSet.contains('all') && !tpsSet.isEmpty()) {
                String q = ' Trading_Partner_gne__c in (';
                for(String tp :tpsSet) {
                    q += '\'' + tp + '\',';
                }
                if(q.endsWith(','))
                    q = q.removeEndIgnoreCase(',');
                q += ') ';
                qString.add(q);
            } 

            if(!yrsSet.contains('all') && !yrsSet.isEmpty()) {
                String q = ' TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Year_gne__c in (';
                for(String yr :yrsSet) {
                    q += '\'' + yr + '\',';
                }
                if(q.endsWith(','))
                    q = q.removeEndIgnoreCase(',');
                q += ') ';
                qString.add(q);
            } 

            if(!mthsSet.contains('all') && !mthsSet.isEmpty()) {
                String q = ' TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Number_gne__c in (';
                for(String mth :mthsSet) {
                    q +=  Integer.valueOf(mth) + ',';
                }
                if(q.endsWith(','))
                    q = q.removeEndIgnoreCase(',');
                q += ') ';
                qString.add(q);
            }
            qString.add(' Trading_Partner_gne__r.Contact_gne__c != null '); 
            qString.add(' Prescriber_Organization_Location_gne__c != null '); 
            if('yes'.equals(quantityFilter))
                qString.add(' Quantity_gne__c > 0 '); 

            if(!qString.isEmpty()) {
                whereString += ' WHERE ';
                for(String q : qString) {
                    if(!' WHERE '.equals(whereString)) {
                        whereString += ' AND ';
                    }
                    whereString += q;
                }
            }
            query += whereString;
            query += ' order by TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Year_gne__c desc, TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Number_gne__c';
            System.debug(' ----- query string ' + query);
            List<SRW_Sales_Data_gne__c> sdata = Database.query(query);
            
            List<SRW_ReportWrappers.SRW_Report6Table1> prods = clearReport6Table1(sdata);
            //if(prods != null && !prods.isEmpty())
            //    showPresSummaryTable = true;
            
            return prods;
        }
    }

    public static List<SRW_ReportWrappers.SRW_Report6Table1> clearReport6Table1(List<SRW_Sales_Data_gne__c> sdata) {
        
        List<SRW_ReportWrappers.SRW_Report6Table1> prodList = new List<SRW_ReportWrappers.SRW_Report6Table1>();
        if(sdata == null || sdata.isEmpty())
            return new List<SRW_ReportWrappers.SRW_Report6Table1>();

        // create status map
        List<String> ids = new List<String>();
        for(SRW_Sales_Data_gne__c sd : sdata) {
            ids.add(sd.Trading_Partner_gne__c);
        }
        List<SRW_Security_Community_Data__c> statusCommList = [Select Id,Trading_Partner_gne__c, Status_gne__c from SRW_Security_Community_Data__c
                                                            WHERE Trading_Partner_gne__r.Contact_gne__c != null and Trading_Partner_gne__c in: ids];
        Map<String, String> statusMap = new Map<String, String>();  
        for(SRW_Security_Community_Data__c cds : statusCommList) {
            statusMap.put(cds.Trading_Partner_gne__c, cds.Status_gne__c);
        }

        // generate maps
        Map<String, Map<String, Map<String, SRW_Sales_Data_gne__c>>> mainMapSD = new Map<String, Map<String, Map<String, SRW_Sales_Data_gne__c>>>();
        for(SRW_Sales_Data_gne__c sd : sdata) {
            String orgkey = '' + sd.Trading_Partner_gne__c + sd.Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__c + sd.TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c;
            String prodkey = '' + sd.Product_gne__c;
            String lockey = '' + sd.Prescriber_Organization_Location_gne__c;
            
            if(!mainMapSD.containsKey(orgkey)) {
                mainMapSD.put(orgkey, new Map<String, Map<String, SRW_Sales_Data_gne__c>>());
            }
            Map<String, Map<String, SRW_Sales_Data_gne__c>> prodMap = mainMapSD.get(orgkey);
            if(!prodMap.containsKey(sd.Product_gne__c)) {
                prodMap.put(prodKey, new Map<String, SRW_Sales_Data_gne__c>());
            }
            Map<String, SRW_Sales_Data_gne__c> locMap = prodMap.get(prodKey);
            if(!locMap.containsKey(sd.Prescriber_Organization_Location_gne__c) 
                    || locMap.get(sd.Prescriber_Organization_Location_gne__c).Set_Sequence_Number_gne__c < sd.Set_Sequence_Number_gne__c) {
                locMap.put(lockey, sd);
            }
        }

        // clear sweep data + sum quantity
        String presName;
        for(String okey : mainMapSD.keySet()) {
            for(String pkey : mainMapSD.get(okey).keySet()) {
                Decimal sumQuantity = 0;
                SRW_Sales_Data_gne__c sd = null;
                for(String lkey : mainMapSD.get(okey).get(pkey).keySet()) {
                    sd = mainMapSD.get(okey).get(pkey).get(lkey);
                    sumQuantity += sd.Quantity_gne__c;
                }
                presName = 'Prescriber'.equals(sd.Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Type_gne__c) ? sd.Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_First_Name_gne__c + ' ' + sd.Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_Last_Name_gne__c : sd.Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Organization_Name_gne__c;              
                    
                prodList.add(new SRW_ReportWrappers.SRW_Report6Table1((String)sd.Trading_Partner_gne__c,
                    sd.TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c,
                    sd.Trading_Partner_gne__r.Trading_Partner_Name_gne__c,
                    sd.Trading_Partner_gne__r.Trading_Partner_Address_1_gne__c,
                    statusMap.get(sd.Trading_Partner_gne__c),
                    sd.Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__c,
                    presName,
                    sd.Product_gne__r.Name,
                    String.valueOf(sd.Quantity_gne__c),
                    sd.TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Year_gne__c,
                    sd.TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Number_gne__c));
            }

        }
        prodList.sort();
        return prodList;
    }

    public static List<SRW_ReportWrappers.SRW_Report6Table1> clearReport6Table1(List<SRW_TP_Data_Months__c> tpdmData) {
        List<SRW_ReportWrappers.SRW_Report6Table1> prodList = new List<SRW_ReportWrappers.SRW_Report6Table1>();

        List<String> ids = new List<String>();
        for(SRW_TP_Data_Months__c tpdm : tpdmData) {
            ids.add(tpdm.Trading_Partner_gne__c);
        }
        List<SRW_Security_Community_Data__c> statusCommList = [Select Id,Trading_Partner_gne__c, Status_gne__c from SRW_Security_Community_Data__c
                                                            WHERE Trading_Partner_gne__r.Contact_gne__c != null and Trading_Partner_gne__c in: ids];
        Map<String, String> statusMap = new Map<String, String>();  
        for(SRW_Security_Community_Data__c cds : statusCommList) {
            statusMap.put(cds.Trading_Partner_gne__c, cds.Status_gne__c);
        }

        String noSales = 'No sales reported this month';

        for(SRW_TP_Data_Months__c temp : tpdmData){
            prodList.add(new SRW_ReportWrappers.SRW_Report6Table1((String)temp.Trading_Partner_gne__c,
                    temp.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c,
                    temp.Trading_Partner_gne__r.Trading_Partner_Name_gne__c,
                    temp.Trading_Partner_gne__r.Trading_Partner_Address_1_gne__c,
                    statusMap.get(temp.Trading_Partner_gne__c),
                    null,
                    noSales,
                    '',
                    '',
                    temp.SRW_Data_Month_gne__r.Data_Year_gne__c,
                    temp.SRW_Data_Month_gne__r.Data_Month_Number_gne__c));
        }
        prodList.sort();
        return prodList;
    }

    public static List<SRW_ReportWrappers.SRW_Report6Table2> getReport6Table2(List<String> years, List<String> months, List<String> tps, String submissionStatus, String quantityFilter) {
       
        //showTotalsTable = false;
        String query = 'Select id, Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Type_gne__c, Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_First_Name_gne__c, Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_Last_Name_gne__c, Set_Sequence_Number_gne__c, Prescriber_Organization_Location_gne__c, Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__c, Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Organization_Name_gne__c ,Quantity_gne__c, Product_gne__c, Product_gne__r.Name ,Trading_Partner_gne__c, Trading_Partner_gne__r.Active_gne__c, Trading_Partner_gne__r.Trading_Partner_Address_1_gne__c, Trading_Partner_gne__r.Trading_Partner_Name_gne__c,TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Year_gne__c,TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c,TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Number_gne__c,TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_gne__c from SRW_Sales_Data_gne__c ';
        List<String> qString = new List<String>();
        String whereString = '';
        
        Set<String> yrsSet = new Set<String>();
        Set<String> tpsSet = new Set<String>();
        //if(parameters.yrs != null)
            yrsSet.addAll(years);
        //if(parameters.tps != null)
            tpsSet.addAll(tps);

        if(yrsSet.contains('all') || yrsSet.isEmpty() || yrsSet.size() > 1) {
            //showPresSummaryTable = true;
            return new List<SRW_ReportWrappers.SRW_Report6Table2>();
        }

        if(!tpsSet.contains('all') && !tpsSet.isEmpty()) {
            String q = ' Trading_Partner_gne__c in (';
            for(String tp :tpsSet) {
                q += '\'' + tp + '\',';
            }
            if(q.endsWith(','))
                q = q.removeEndIgnoreCase(',');
            q += ') ';
            qString.add(q);
        } 

        if(!yrsSet.contains('all') && !yrsSet.isEmpty()) {
            String q = ' TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Year_gne__c in (';
            for(String yr :yrsSet) {
                q += '\'' + yr + '\',';
            }
            if(q.endsWith(','))
                q = q.removeEndIgnoreCase(',');
            q += ') ';
            qString.add(q);
        } 

        
        qString.add(' Trading_Partner_gne__r.Contact_gne__c != null '); 
        if('yes'.equals(quantityFilter))
            qString.add(' Quantity_gne__c > 0 '); 

        if(!qString.isEmpty()) {
            whereString += ' WHERE ';
            for(String q : qString) {
                if(!' WHERE '.equals(whereString)) {
                    whereString += ' AND ';
                }
                whereString += q;
            }
        }
        query += whereString;
        query += ' order by TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Year_gne__c desc, TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Number_gne__c';
        System.debug(' ----- query string ' + query);
        List<SRW_Sales_Data_gne__c> sdata = Database.query(query);
        Map<String, Map<String,List<SRW_Sales_Data_gne__c>>> totalsTMP = new Map<String, Map<String, List<SRW_Sales_Data_gne__c>>>();
        List<SRW_ReportWrappers.SRW_Report6Table2> prodTotals = new List<SRW_ReportWrappers.SRW_Report6Table2>();

        for(SRW_Sales_Data_gne__c sd : sdata) {
            if(!totalsTMP.containsKey(sd.Trading_Partner_gne__c)) {
                totalsTMP.put(sd.Trading_Partner_gne__c, new Map<String, List<SRW_Sales_Data_gne__c>>());   
            }
            if(!totalsTMP.get(sd.Trading_Partner_gne__c).containsKey(sd.Product_gne__c))
                totalsTMP.get(sd.Trading_Partner_gne__c).put(sd.Product_gne__c, new List<SRW_Sales_Data_gne__c>());

            totalsTMP.get(sd.Trading_Partner_gne__c).get(sd.Product_gne__c).add(sd);
        }

        for(String tpId : totalsTMP.keySet()) {
            Map<String,List<SRW_Sales_Data_gne__c>> sdMap = totalsTMP.get(tpId);
            List<SRW_ReportWrappers.SRW_Report6ProductTotals> pTotals = new List<SRW_ReportWrappers.SRW_Report6ProductTotals>();
            String tpName = ''; 
            for(String prodId : sdMap.keySet()) {
                List<SRW_Sales_Data_gne__c> prodSD = sdMap.get(prodId);
                tpName = prodSD.get(0).Trading_Partner_gne__r.Trading_Partner_Name_gne__c;
                Map<String, List<SRW_Sales_Data_gne__c>> yData = new Map<String, List<SRW_Sales_Data_gne__c>>(); 
                for(SRW_Sales_Data_gne__c sd : prodSD) {
                    if(!yData.containsKey(sd.TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Year_gne__c)) 
                        yData.put(sd.TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Year_gne__c,new List<SRW_Sales_Data_gne__c>());
                    yData.get(sd.TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Year_gne__c).add(sd);
                }
                List<SRW_ReportWrappers.SRW_Report6YearData> yearsData = new List<SRW_ReportWrappers.SRW_Report6YearData>();
                for(String year : yData.keySet()) {
                    yearsData.add(createReport6Table2YearData(yData.get(year)));
                }
                pTotals.add(new SRW_ReportWrappers.SRW_Report6ProductTotals(prodSD.get(0).Product_gne__r.Name, yearsData));
                
            }
            prodTotals.add(new SRW_ReportWrappers.SRW_Report6Table2(tpId, tpName, pTotals));
        }
        return prodTotals;
        //totalsJson = JSON.serialize(prodTotals);
        //System.debug('------TOTALS JSON ' + totalsJson );
        //if(String.isNotBlank(totalsJson))
        //    showTotalsTable = true;
        //return totalsJson;
    }

    public static SRW_ReportWrappers.SRW_Report6YearData createReport6Table2YearData(List<SRW_Sales_Data_gne__c> sdList) {
        
        if(sdList==null || sdList.isEmpty()) 
            return null;

        SRW_ReportWrappers.SRW_Report6YearData yd = new SRW_ReportWrappers.SRW_Report6YearData(sdList.get(0).TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Year_gne__c);
        Map<String, Map<String, SRW_Sales_Data_gne__c>> mapSD = new Map<String, Map<String, SRW_Sales_Data_gne__c>>(); 
        for(SRW_Sales_Data_gne__c sd : sdList) {
            if(!mapSD.containsKey(sd.TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_gne__c)) 
                mapSD.put(sd.TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_gne__c, new Map<String, SRW_Sales_Data_gne__c>());   
            if(!mapSD.get(sd.TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_gne__c).containsKey(sd.Prescriber_Organization_Location_gne__c))
                mapSD.get(sd.TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_gne__c).put(sd.Prescriber_Organization_Location_gne__c, sd);
            else {
                if(mapSD.get(sd.TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_gne__c).get(sd.Prescriber_Organization_Location_gne__c).Set_Sequence_Number_gne__c < sd.Set_Sequence_Number_gne__c) {
                    mapSD.get(sd.TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_gne__c).put(sd.Prescriber_Organization_Location_gne__c, sd);     
                }
            }
        }

        for(String month : mapSD.keySet()) {
            Map<String, SRW_Sales_Data_gne__c> salesInMonth = mapSD.get(month);
            Decimal quantity = 0;
            Decimal monthNum;
            for(String cust : salesInMonth.keySet()) {
                if(monthNum == null) 
                    monthNum = salesInMonth.get(cust).TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Number_gne__c;
                quantity += salesInMonth.get(cust).Quantity_gne__c;
            }
            SRW_ReportWrappers.SRW_Report6MonthData dm = new SRW_ReportWrappers.SRW_Report6MonthData(month, quantity);
            if(monthNum  < 4) {
                if(yd.quater1 == null) 
                    yd.quater1 = new SRW_ReportWrappers.SRW_Report6QuaterData();
                yd.quater1.months.add(dm);
            } else if(monthNum  < 7) {
                if(yd.quater2 == null) 
                    yd.quater2 = new SRW_ReportWrappers.SRW_Report6QuaterData();
                yd.quater2.months.add(dm);
            } else if(monthNum  < 10) {
                if(yd.quater3 == null) 
                    yd.quater3 = new SRW_ReportWrappers.SRW_Report6QuaterData();
                yd.quater3.months.add(dm);
            } else if(monthNum  < 13) {
                if(yd.quater4 == null) 
                    yd.quater4 = new SRW_ReportWrappers.SRW_Report6QuaterData();
                yd.quater4.months.add(dm);
            }

            yd.quater1.countTotal();
            yd.quater2.countTotal();
            yd.quater3.countTotal();
            yd.quater4.countTotal();

            yd.countYearTotal();
        }

        return yd;
    }

    // ###################################################################################
    // ########################### REPORT 7 ##############################################
    // ################# Trading Partners Identifier Match Not found #####################
    // ###################################################################################
    public static List<SRW_ReportWrappers.SRW_Report7Table1> getReport7Table1(List<String> tps) {
        List<SRW_ReportWrappers.SRW_Report7Table1> poValues = new List<SRW_ReportWrappers.SRW_Report7Table1>();
        if(tps == null || tps.isEmpty())
            return poValues;

        Set<String> selectedTPsListSet = new Set<String>();
        selectedTPsListSet.addAll(tps);

        List<SRW_TP_Exception__c> polist = new List<SRW_TP_Exception__c>();

        if(selectedTPsListSet.isEmpty() || selectedTPsListSet.contains('all')) {
            polist = [SELECT Trading_Partner_gne__r.Trading_Partner_Name_gne__c, Trading_Partner_gne__r.Trading_Partner_Address_1_gne__c, Trading_Partner_gne__r.Type_of_Identifier_gne__c, Trading_Partner_gne__r.Identifier_gne__c, Trading_Partner_gne__r.Contact_First_Name_gne__c, Trading_Partner_gne__r.Contact_Last_Name_gne__c, Trading_Partner_gne__r.Contact_Phone_gne__c, Trading_Partner_gne__r.Identifier_Not_Found_gne__c, CreatedDate
                FROM SRW_TP_Exception__c
                WHERE Trading_Partner_gne__c != null
                  AND Trading_Partner_gne__r.Identifier_Not_Found_gne__c = 'YES'];      
        } else {
            for (SRW_TP_Exception__c ex : [SELECT Trading_Partner_gne__r.Trading_Partner_Name_gne__c, Trading_Partner_gne__r.Trading_Partner_Address_1_gne__c, Trading_Partner_gne__r.Type_of_Identifier_gne__c, Trading_Partner_gne__r.Identifier_gne__c, Trading_Partner_gne__r.Contact_First_Name_gne__c, Trading_Partner_gne__r.Contact_Last_Name_gne__c, Trading_Partner_gne__r.Contact_Phone_gne__c, Trading_Partner_gne__r.Identifier_Not_Found_gne__c, CreatedDate
                FROM SRW_TP_Exception__c
                WHERE Trading_Partner_gne__c != null
                  AND Trading_Partner_gne__r.Identifier_Not_Found_gne__c = 'YES']) {
                if (selectedTPsListSet.contains(ex.Trading_Partner_gne__c)) {
                    polist.add(ex);
                }
            }
        }

        for(SRW_TP_Exception__c po : polist) {
            poValues.add(new SRW_ReportWrappers.SRW_Report7Table1(
                    po.Trading_Partner_gne__c,
                    po.Trading_Partner_gne__r.Trading_Partner_Name_gne__c,
                    po.Trading_Partner_gne__r.Trading_Partner_Address_1_gne__c,
                    po.Trading_Partner_gne__r.Type_of_Identifier_gne__c,
                    po.Trading_Partner_gne__r.Identifier_gne__c,
                    po.Trading_Partner_gne__r.Contact_First_Name_gne__c + ' ' + po.Trading_Partner_gne__r.Contact_Last_Name_gne__c,
                    po.Trading_Partner_gne__r.Contact_Phone_gne__c,
                    po.CreatedDate.format('MM/dd/YYYY')));
        }
        return poValues;
    }

    // ###################################################################################
    // ########################### REPORT 8 ##############################################
    // ################# Prescriber/Organization Identifier Match Not found ##############
    // ###################################################################################
    public static List<SRW_ReportWrappers.SRW_Report8Table1> getReport8Table1(List<String> presOrgs, List<String> tps) {
        
        List<SRW_ReportWrappers.SRW_Report8Table1> poValues = new List<SRW_ReportWrappers.SRW_Report8Table1>();
        if(presOrgs == null || presOrgs.isEmpty())
            return poValues;

        Set<String> selectedPresOrgsListSet = new Set<String>();
        selectedPresOrgsListSet.addAll(presOrgs);
        Set<String> selectedTPs = new Set<String>();
        selectedTPs.addAll(tps);

        List<SRW_PO_Exception__c> polist = new List<SRW_PO_Exception__c>();

        if((selectedPresOrgsListSet.isEmpty() || selectedPresOrgsListSet.contains('all')) && (selectedTPs.isEmpty() || selectedTPs.contains('all'))) {
            polist = [Select Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Trading_Partner_Name_gne__c,
                    Prscr_Or_Org_Location_gne__r.Prescriber_Identifier_Not_Found_gne__c,
                    Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Type_gne__c,
                    Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Organization_Name_gne__c,
                    Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_First_Name_gne__c,
                    Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_Last_Name_gne__c,
                    Prscr_Or_Org_Location_gne__r.Street_Address_1_gne__c,
                    Prscr_Or_Org_Location_gne__r.Street_Address_2_gne__c,
                    Prscr_Or_Org_Location_gne__r.City_gne__c,
                    Prscr_Or_Org_Location_gne__r.Zip_Code_gne__c,
                    Prscr_Or_Org_Location_gne__r.Type_of_Identifier_gne__c,
                    Prscr_Or_Org_Location_gne__r.Identifier_gne__c,
                    Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Contact_First_Name_gne__c,
                    Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Contact_Last_Name_gne__c,
                    Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Contact_Phone_gne__c,
                    CreatedDate
                    FROM SRW_PO_Exception__c
                    WHERE Prscr_Or_Org_Location_gne__r.Prescriber_Identifier_Not_Found_gne__c = 'YES'];
        } else if(selectedPresOrgsListSet.isEmpty() || selectedPresOrgsListSet.contains('all')){
            polist = [Select Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Trading_Partner_Name_gne__c,
                    Prscr_Or_Org_Location_gne__r.Prescriber_Identifier_Not_Found_gne__c,
                    Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Type_gne__c,
                    Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Organization_Name_gne__c,
                    Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_First_Name_gne__c,
                    Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_Last_Name_gne__c,
                    Prscr_Or_Org_Location_gne__r.Street_Address_1_gne__c,
                    Prscr_Or_Org_Location_gne__r.Street_Address_2_gne__c,
                    Prscr_Or_Org_Location_gne__r.City_gne__c,
                    Prscr_Or_Org_Location_gne__r.Zip_Code_gne__c,
                    Prscr_Or_Org_Location_gne__r.Type_of_Identifier_gne__c,
                    Prscr_Or_Org_Location_gne__r.Identifier_gne__c,
                    Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Contact_First_Name_gne__c,
                    Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Contact_Last_Name_gne__c,
                    Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Contact_Phone_gne__c,
                    CreatedDate
                    FROM SRW_PO_Exception__c
                    WHERE Prscr_Or_Org_Location_gne__r.Prescriber_Identifier_Not_Found_gne__c = 'YES'
                     AND Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__c IN :selectedTPs];
        } else if(selectedTPs.isEmpty() || selectedTPs.contains('all')){
            polist = [Select Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Trading_Partner_Name_gne__c,
                    Prscr_Or_Org_Location_gne__r.Prescriber_Identifier_Not_Found_gne__c,
                    Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Type_gne__c,
                    Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Organization_Name_gne__c,
                    Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_First_Name_gne__c,
                    Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_Last_Name_gne__c,
                    Prscr_Or_Org_Location_gne__r.Street_Address_1_gne__c,
                    Prscr_Or_Org_Location_gne__r.Street_Address_2_gne__c,
                    Prscr_Or_Org_Location_gne__r.City_gne__c,
                    Prscr_Or_Org_Location_gne__r.Zip_Code_gne__c,
                    Prscr_Or_Org_Location_gne__r.Type_of_Identifier_gne__c,
                    Prscr_Or_Org_Location_gne__r.Identifier_gne__c,
                    Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Contact_First_Name_gne__c,
                    Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Contact_Last_Name_gne__c,
                    Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Contact_Phone_gne__c,
                    CreatedDate
                    FROM SRW_PO_Exception__c
                    WHERE Prscr_Or_Org_Location_gne__r.Prescriber_Identifier_Not_Found_gne__c = 'YES'
                     AND Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__c IN :selectedPresOrgsListSet];
        } else {
            polist = [Select Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Trading_Partner_Name_gne__c,
                    Prscr_Or_Org_Location_gne__r.Prescriber_Identifier_Not_Found_gne__c,
                    Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Type_gne__c,
                    Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Organization_Name_gne__c,
                    Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_First_Name_gne__c,
                    Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_Last_Name_gne__c,
                    Prscr_Or_Org_Location_gne__r.Street_Address_1_gne__c,
                    Prscr_Or_Org_Location_gne__r.Street_Address_2_gne__c,
                    Prscr_Or_Org_Location_gne__r.City_gne__c,
                    Prscr_Or_Org_Location_gne__r.Zip_Code_gne__c,
                    Prscr_Or_Org_Location_gne__r.Type_of_Identifier_gne__c,
                    Prscr_Or_Org_Location_gne__r.Identifier_gne__c,
                    Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Contact_First_Name_gne__c,
                    Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Contact_Last_Name_gne__c,
                    Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Contact_Phone_gne__c,
                    CreatedDate
                    FROM SRW_PO_Exception__c
                    WHERE Prscr_Or_Org_Location_gne__r.Prescriber_Identifier_Not_Found_gne__c = 'YES'
                     AND Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__c IN :selectedTPs
                     AND Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__c IN :selectedPresOrgsListSet];
        }

        for(SRW_PO_Exception__c po : polist) {
            String poAddr = po.Prscr_Or_Org_Location_gne__r.Street_Address_1_gne__c + ', ';
                    poaddr += po.Prscr_Or_Org_Location_gne__r.Street_Address_2_gne__c != null ? po.Prscr_Or_Org_Location_gne__r.Street_Address_2_gne__c + ', ' : '';
                    poaddr += po.Prscr_Or_Org_Location_gne__r.City_gne__c + ', ' +
                    po.Prscr_Or_Org_Location_gne__r.Zip_Code_gne__c;
            String tempCustomerName = 'Prescriber'.equals(po.Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Type_gne__c) ? po.Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_First_Name_gne__c + ' ' + po.Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_Last_Name_gne__c : po.Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Organization_Name_gne__c;
            poValues.add(new SRW_ReportWrappers.SRW_Report8Table1(
                    po.Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__c,
                    po.Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Trading_Partner_Name_gne__c, 
                    tempCustomerName,
                    poAddr,
                    po.Prscr_Or_Org_Location_gne__r.Type_of_Identifier_gne__c,
                    po.Prscr_Or_Org_Location_gne__r.Identifier_gne__c,
                    po.Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Contact_First_Name_gne__c + ' ' + po.Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Contact_Last_Name_gne__c,
                    po.Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Contact_Phone_gne__c,
                    po.CreatedDate.format('MM/dd/YYYY')));
        }
        return poValues;
    }
    /*
    public static List<SRW_ReportWrappers.SRW_Report8Table1> getReport8Table1(List<String> presOrgs , List<String> tps) {
         system.debug('-------- presOrgs '+presOrgs );
         system.debug('-------- tps '+tps);
        List<SRW_ReportWrappers.SRW_Report8Table1> poValues = new List<SRW_ReportWrappers.SRW_Report8Table1>();
        if( tps == null || tps.isEmpty())
            return poValues;

        Set<String> selectedTPsListSet = new Set<String>();
        selectedTPsListSet.addAll(tps);
        
        
        if(presOrgs == null || presOrgs.isEmpty())
            return poValues;

        Set<String> selectedPresOrgsListSet = new Set<String>();
        selectedPresOrgsListSet.addAll(presOrgs);

        List<SRW_PO_Exception__c> polist = new List<SRW_PO_Exception__c>();

        if((selectedPresOrgsListSet.isEmpty() || selectedPresOrgsListSet.contains('all')) && (selectedTPsListSet.isEmpty() || selectedTPsListSet.contains('all'))) {
            system.debug('-------- presc all , tps all');
            polist = [Select Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Trading_Partner_Name_gne__c,
                    Prscr_Or_Org_Location_gne__r.Prescriber_Identifier_Not_Found_gne__c,
                    Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Type_gne__c,
                    Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Organization_Name_gne__c,
                    Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_First_Name_gne__c,
                    Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_Last_Name_gne__c,
                    Prscr_Or_Org_Location_gne__r.Street_Address_1_gne__c,
                    Prscr_Or_Org_Location_gne__r.Street_Address_2_gne__c,
                    Prscr_Or_Org_Location_gne__r.City_gne__c,
                    Prscr_Or_Org_Location_gne__r.Zip_Code_gne__c,
                    Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Type_of_Identifier_gne__c,
                    Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Identifier_gne__c,
                    Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Contact_First_Name_gne__c,
                    Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Contact_Last_Name_gne__c,
                    Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Contact_Phone_gne__c,
                    CreatedDate
                    FROM SRW_PO_Exception__c
                    WHERE Prscr_Or_Org_Location_gne__r.Prescriber_Identifier_Not_Found_gne__c = 'YES'];
        } else if((selectedPresOrgsListSet.isEmpty() || selectedPresOrgsListSet.contains('all')) && !selectedTPsListSet.contains('all')) {
                system.debug('-------- presc all , tps pick');
                polist = [Select Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Trading_Partner_Name_gne__c,
                        Prscr_Or_Org_Location_gne__r.Prescriber_Identifier_Not_Found_gne__c,
                        Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Type_gne__c,
                        Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Organization_Name_gne__c,
                        Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_First_Name_gne__c,
                        Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_Last_Name_gne__c,
                        Prscr_Or_Org_Location_gne__r.Street_Address_1_gne__c,
                        Prscr_Or_Org_Location_gne__r.Street_Address_2_gne__c,
                        Prscr_Or_Org_Location_gne__r.City_gne__c,
                        Prscr_Or_Org_Location_gne__r.Zip_Code_gne__c,
                        Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Type_of_Identifier_gne__c,
                        Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Identifier_gne__c,
                        Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Contact_First_Name_gne__c,
                        Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Contact_Last_Name_gne__c,
                        Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Contact_Phone_gne__c,
                        CreatedDate
                        FROM SRW_PO_Exception__c
                        WHERE Prscr_Or_Org_Location_gne__r.Prescriber_Identifier_Not_Found_gne__c = 'YES'
                        AND (Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__c IN : selectedPresOrgsListSet
                         OR Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__c IN : selectedTPsListSet)];
                system.debug('polist.size() '+polist.size());  
        }else if ((selectedTPsListSet.isEmpty() || selectedTPsListSet.contains('all')) && !selectedPresOrgsListSet.contains('all')){
                system.debug('-------- presc pick , tps all');
                polist = [Select Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Trading_Partner_Name_gne__c,
                        Prscr_Or_Org_Location_gne__r.Prescriber_Identifier_Not_Found_gne__c,
                        Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Type_gne__c,
                        Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Organization_Name_gne__c,
                        Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_First_Name_gne__c,
                        Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_Last_Name_gne__c,
                        Prscr_Or_Org_Location_gne__r.Street_Address_1_gne__c,
                        Prscr_Or_Org_Location_gne__r.Street_Address_2_gne__c,
                        Prscr_Or_Org_Location_gne__r.City_gne__c,
                        Prscr_Or_Org_Location_gne__r.Zip_Code_gne__c,
                        Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Type_of_Identifier_gne__c,
                        Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Identifier_gne__c,
                        Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Contact_First_Name_gne__c,
                        Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Contact_Last_Name_gne__c,
                        Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Contact_Phone_gne__c,
                        CreatedDate
                        FROM SRW_PO_Exception__c
                        WHERE Prscr_Or_Org_Location_gne__r.Prescriber_Identifier_Not_Found_gne__c = 'YES'
                         AND (Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__c IN : selectedPresOrgsListSet
                         OR Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__c IN : selectedTPsListSet)];
                    system.debug('polist.size() '+polist.size());  
        }else{
                system.debug('--------else presc pick , tps pick');
                polist = [Select Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Trading_Partner_Name_gne__c,
                        Prscr_Or_Org_Location_gne__r.Prescriber_Identifier_Not_Found_gne__c,
                        Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Type_gne__c,
                        Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Organization_Name_gne__c,
                        Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_First_Name_gne__c,
                        Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_Last_Name_gne__c,
                        Prscr_Or_Org_Location_gne__r.Street_Address_1_gne__c,
                        Prscr_Or_Org_Location_gne__r.Street_Address_2_gne__c,
                        Prscr_Or_Org_Location_gne__r.City_gne__c,
                        Prscr_Or_Org_Location_gne__r.Zip_Code_gne__c,
                        Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Type_of_Identifier_gne__c,
                        Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Identifier_gne__c,
                        Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Contact_First_Name_gne__c,
                        Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Contact_Last_Name_gne__c,
                        Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Contact_Phone_gne__c,
                        CreatedDate
                        FROM SRW_PO_Exception__c
                        WHERE Prscr_Or_Org_Location_gne__r.Prescriber_Identifier_Not_Found_gne__c = 'YES'
                         AND (Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__c IN : selectedPresOrgsListSet
                         OR Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__c IN : selectedTPsListSet)];
                    system.debug('polist.size() '+polist.size());  
        }

        for(SRW_PO_Exception__c po : polist) {
            String poAddr = po.Prscr_Or_Org_Location_gne__r.Street_Address_1_gne__c + ', ' +
                    po.Prscr_Or_Org_Location_gne__r.Street_Address_2_gne__c + ', ' +
                    po.Prscr_Or_Org_Location_gne__r.City_gne__c + ', ' +
                    po.Prscr_Or_Org_Location_gne__r.Zip_Code_gne__c;
            String tempCustomerName = 'Prescriber'.equals(po.Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Type_gne__c) ? po.Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_First_Name_gne__c + ' ' + po.Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_Last_Name_gne__c : po.Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Organization_Name_gne__c;
            poValues.add(new SRW_ReportWrappers.SRW_Report8Table1(
                    po.Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__c,
                    po.Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Trading_Partner_Name_gne__c, 
                    tempCustomerName,
                    poAddr,
                    po.Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Type_of_Identifier_gne__c,
                    po.Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Identifier_gne__c,
                    po.Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Contact_First_Name_gne__c + ' ' + po.Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Contact_Last_Name_gne__c,
                    po.Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__r.Trading_Partner_gne__r.Contact_Phone_gne__c,
                    po.CreatedDate.format('MM/dd/YYYY')));
        }
        return poValues;
    }*/
    // ###################################################################################
    // ########################### REPORT 9 ##############################################
    // ################# Historical Data Month Backfill ##################################
    // ###################################################################################
    public static List<SRW_ReportWrappers.SRW_Report9Table1> getReport9Table1(Date dateFrom, Date dateTo){
        List<SRW_ReportWrappers.SRW_Report9Table1> historicalDataMonthBackfillValues = new List<SRW_ReportWrappers.SRW_Report9Table1>();

        Datetime dateTimeFrom = dateFrom == null ? Datetime.now() : (Datetime) dateFrom; 
        Datetime dateTimeTo= dateTo == null ? Datetime.now() : (Datetime) dateTo;
        dateTimeTo = dateTimeTo.addDays(1);

        List<SRW_Sales_Data_gne__c> salesData = [SELECT id, TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c,
                                                    Trading_Partner_gne__r.Trading_Partner_Name_gne__c, Trading_Partner_gne__r.Trading_Partner_Address_1_gne__c,
                                                    Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_First_Name_gne__c, Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Type_gne__c,
                                                    Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_Last_Name_gne__c, Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Organization_Name_gne__c,
                                                    Prescriber_Organization_Location_gne__r.Street_Address_1_gne__c,
                                                    Product_gne__r.Name,
                                                    Quantity_gne__c,
                                                    LastModifiedDate 
                                                FROM SRW_Sales_Data_gne__c
                                                WHERE id in (SELECT SRW_Sales_Data_gne__c FROM SRW_Sales_Data_Exception__c WHERE Historical_Sales_Data_Update_gne__c =  'No' AND CreatedDate >  :dateTimeFrom  AND CreatedDate <= :dateTimeTo)
                                                AND Quantity_gne__c > 0];
        String tempCustomerName;                                            
        for(SRW_Sales_Data_gne__c e : salesData){
            tempCustomerName = 'Prescriber'.equals(e.Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Type_gne__c) ? e.Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_First_Name_gne__c + ' ' + e.Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_Last_Name_gne__c : e.Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Organization_Name_gne__c;
            tempCustomerName += ' ' + e.Prescriber_Organization_Location_gne__r.Street_Address_1_gne__c;
            historicalDataMonthBackfillValues.add(new SRW_ReportWrappers.SRW_Report9Table1(e.TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c, e.Trading_Partner_gne__r.Trading_Partner_Name_gne__c, e.Trading_Partner_gne__r.Trading_Partner_Address_1_gne__c, tempCustomerName, e.Product_gne__r.Name, e.Quantity_gne__c, e.LastModifiedDate));
        }
        historicalDataMonthBackfillValues.sort();

        return historicalDataMonthBackfillValues;
    }

    /*public static List<SRW_ReportWrappers.SRW_Report9Table2> getReport9Table2old(Date dateFrom, Date dateTo){
        List<SRW_ReportWrappers.SRW_Report9Table2> prodTotals = new List<SRW_ReportWrappers.SRW_Report9Table2>();

        List<SRW_Sales_Data_gne__c> sdl;
        List<AggregateResult> r = [SELECT Max(Last_Sweep_Occurrence_Date_gne__c) lastSweepDate FROM SRW_DataMonths__c];
        Datetime dateTimeFrom = dateFrom == null ? Datetime.now() : (Datetime) dateFrom; 
        Datetime dateTimeTo= dateTo == null ? Datetime.now() : (Datetime) dateTo;

        sdl = [SELECT Product_gne__r.Name, Product_gne__r.id, Product_gne__r.NDC_Number_gne__c, Quantity_gne__c, Prescriber_Organization_Location_gne__r.id, Set_Sequence_Number_gne__c, TP_Data_Month_gne__r.id
               FROM SRW_Sales_Data_gne__c 
               WHERE Sweep_Data_Month_gne__r.Real_Sweep_Date_gne__c  >  :dateTimeFrom  AND Sweep_Data_Month_gne__r.Real_Sweep_Date_gne__c <= :dateTimeTo
               ORDER BY Product_gne__r.Name Desc];
               //WHERE CreatedDate  >  :dateTimeFrom  AND CreatedDate <= :dateTimeTo

        system.debug('previous sales Data: ' + sdl);                                      
        Map<SRW_ReportWrappers.SRW_Report9SalesDataKey, SRW_ReportWrappers.SRW_Report9SalesDataValue> salesMap = new Map<SRW_ReportWrappers.SRW_Report9SalesDataKey, SRW_ReportWrappers.SRW_Report9SalesDataValue>();

        for(SRW_Sales_Data_gne__c sd : sdl){
            Boolean add = true;
            for(SRW_ReportWrappers.SRW_Report9SalesDataKey sdk : salesMap.keySet()){
                add = sdk.equals(new SRW_ReportWrappers.SRW_Report9SalesDataKey(sd.Product_gne__r.NDC_Number_gne__c, sd.Prescriber_Organization_Location_gne__c, sd.TP_Data_Month_gne__r.id)) ? false : true;
                if (!add) 
                    break; 
            }
            if (add){
                salesMap.put(new SRW_ReportWrappers.SRW_Report9SalesDataKey(sd.Product_gne__r.NDC_Number_gne__c, sd.Prescriber_Organization_Location_gne__c, sd.TP_Data_Month_gne__r.id), new SRW_ReportWrappers.SRW_Report9SalesDataValue(sd.Quantity_gne__c, sd.Set_Sequence_Number_gne__c, sd.Product_gne__r.NDC_Number_gne__c, sd.Product_gne__r.Name, sd.id));
            } else if(salesMap.get(new SRW_ReportWrappers.SRW_Report9SalesDataKey(sd.Product_gne__r.NDC_Number_gne__c, sd.Prescriber_Organization_Location_gne__c, sd.TP_Data_Month_gne__r.id)).sequenceNumber < sd.Set_Sequence_Number_gne__c){
                salesMap.put(new SRW_ReportWrappers.SRW_Report9SalesDataKey(sd.Product_gne__r.NDC_Number_gne__c, sd.Prescriber_Organization_Location_gne__c, sd.TP_Data_Month_gne__r.id), new SRW_ReportWrappers.SRW_Report9SalesDataValue(sd.Quantity_gne__c, sd.Set_Sequence_Number_gne__c, sd.Product_gne__r.NDC_Number_gne__c, sd.Product_gne__r.Name, sd.id));
            }
        }
        List<id> productIds = new List<id>();
        for(SRW_ReportWrappers.SRW_Report9SalesDataKey sdk : salesMap.keySet()){
            productIds.add(salesMap.get(sdk).salesId);
        }
        for(AggregateResult ar : [SELECT TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Year_gne__c datayear, TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_gne__c datamonth, Trading_Partner_gne__r.Trading_Partner_Name_gne__c tradingPartnerName, Product_gne__r.Name productName, Product_gne__r.NDC_Number_gne__c ndc, SUM(Quantity_gne__c) quantitySum 
                FROM SRW_Sales_Data_gne__c
                WHERE id IN :productIds 
                GROUP BY TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Year_gne__c, TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_gne__c, Trading_Partner_gne__r.Trading_Partner_Name_gne__c, Product_gne__r.Name, Product_gne__r.NDC_Number_gne__c 
                ORDER BY TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Year_gne__c, TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_gne__c, Trading_Partner_gne__r.Trading_Partner_Name_gne__c, Product_gne__r.Name ASC]) {

            prodTotals.add(new SRW_ReportWrappers.SRW_Report9Table2((String)ar.get('datayear'), (String)ar.get('datamonth'), (String)ar.get('tradingPartnerName'), (String)ar.get('productName'), (String)ar.get('ndc'), (Decimal)ar.get('quantitySum'))); 

        }
        return prodTotals;
    }*/

    public static List<SRW_ReportWrappers.SRW_Report9Table2> getReport9Table2(Date dateFrom, Date dateTo){
        List<SRW_ReportWrappers.SRW_Report9Table2> prodTotals = new List<SRW_ReportWrappers.SRW_Report9Table2>();
        Datetime dateTimeFrom = dateFrom == null ? Datetime.now() : (Datetime) dateFrom; 
        Datetime dateTimeTo= dateTo == null ? Datetime.now() : (Datetime) dateTo;
        dateTimeTo = dateTimeTo.addDays(1);

        for(AggregateResult ar : [SELECT TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Year_gne__c datayear, TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_gne__c datamonth, Trading_Partner_gne__r.Trading_Partner_Name_gne__c tradingPartnerName, Product_gne__r.Name productName, Product_gne__r.NDC_Number_gne__c ndc, SUM(Quantity_gne__c) quantitySum 
                FROM SRW_Sales_Data_gne__c
                WHERE id in (SELECT SRW_Sales_Data_gne__c FROM SRW_Sales_Data_Exception__c WHERE Historical_Sales_Data_Update_gne__c =  'No' AND CreatedDate >  :dateTimeFrom  AND CreatedDate <= :dateTimeTo) and Is_Actual_gne__c = true
                GROUP BY TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Year_gne__c, TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_gne__c, Trading_Partner_gne__r.Trading_Partner_Name_gne__c, Product_gne__r.Name, Product_gne__r.NDC_Number_gne__c 
                ORDER BY TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Year_gne__c, TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_gne__c, Trading_Partner_gne__r.Trading_Partner_Name_gne__c, Product_gne__r.Name ASC]) {
            System.debug('------ ar ' + ar);
            prodTotals.add(new SRW_ReportWrappers.SRW_Report9Table2((String)ar.get('datayear'), (String)ar.get('datamonth'), (String)ar.get('tradingPartnerName'), (String)ar.get('productName'), (String)ar.get('ndc'), (Decimal)ar.get('quantitySum'))); 
            System.debug('------ prodTotals ' + prodTotals);
        }
        return prodTotals;
    }
    // ###################################################################################
    // ########################### REPORT 10 #############################################
    // ################# Historical Sales Data Update ####################################
    // ###################################################################################
    public static List<SRW_ReportWrappers.SRW_Report10Table1> getReport10Table1(List<String> months) {

        List<SRW_ReportWrappers.SRW_Report10Table1> hsdList = new List<SRW_ReportWrappers.SRW_Report10Table1>();
        List<SRW_Sales_Data_gne__c> sdList = new List<SRW_Sales_Data_gne__c>();
        if(months == null || months.isEmpty())
            return hsdList;
        Set<String> dmSet = new Set<String>();
        dmSet.addAll(months);
        List<String> openedDataMonthsStatus = new List<String>();
        openedDataMonthsStatus.add('Resweep');
        openedDataMonthsStatus.add('Resubmitted');

        if(!dmSet.contains('all')) {
            sdList = [SELECT TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c,
                        Trading_Partner_gne__c, Trading_Partner_gne__r.Trading_Partner_Name_gne__c, Trading_Partner_gne__r.Trading_Partner_Address_1_gne__c,
                            Prescriber_Organization_Location_gne__r.Street_Address_1_gne__c,
                            Prescriber_Organization_Location_gne__r.City_gne__c,
                            Prescriber_Organization_Location_gne__r.State_gne__c,
                            Prescriber_Organization_Location_gne__r.Zip_Code_gne__c,
                            Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Type_gne__c,
                            Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_First_Name_gne__c, 
                            Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_Last_Name_gne__c, 
                            Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Organization_Name_gne__c,
                        Product_gne__r.Name,
                        Quantity_gne__c,
                        CreatedDate,
                        LastModifiedDate,
                        Sweep_Data_Month_gne__r.Real_Sweep_Date_gne__c,
                        Set_Sequence_Number_gne__c
                      FROM SRW_Sales_Data_gne__c 
                      WHERE TP_Data_Month_gne__r.SRW_Data_Month_gne__c IN :dmSet AND TP_Data_Month_gne__r.Data_Month_Status_gne__c IN : openedDataMonthsStatus
                      ORDER BY TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Year_gne__c desc, TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Number_gne__c desc, Trading_Partner_gne__r.Trading_Partner_Name_gne__c Asc, Set_Sequence_Number_gne__c Asc];
        } else {
            sdList = [SELECT TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c,
                        Trading_Partner_gne__c, Trading_Partner_gne__r.Trading_Partner_Name_gne__c, Trading_Partner_gne__r.Trading_Partner_Address_1_gne__c,
                            Prescriber_Organization_Location_gne__r.Street_Address_1_gne__c,
                            Prescriber_Organization_Location_gne__r.City_gne__c,
                            Prescriber_Organization_Location_gne__r.State_gne__c,
                            Prescriber_Organization_Location_gne__r.Zip_Code_gne__c,
                            Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Type_gne__c,
                            Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_First_Name_gne__c, 
                            Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_Last_Name_gne__c, 
                            Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Organization_Name_gne__c,
                        Product_gne__r.Name,
                        Quantity_gne__c,
                        CreatedDate,
                        LastModifiedDate,
                        Sweep_Data_Month_gne__r.Real_Sweep_Date_gne__c,
                        Set_Sequence_Number_gne__c
                      FROM SRW_Sales_Data_gne__c
                      WHERE TP_Data_Month_gne__r.Data_Month_Status_gne__c IN : openedDataMonthsStatus
                      ORDER BY TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Year_gne__c desc, TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Number_gne__c desc, Trading_Partner_gne__r.Trading_Partner_Name_gne__c Asc, Set_Sequence_Number_gne__c Asc]; 
        }
        system.debug('sales data: ' + sdList);
        hsdList = report10OrganizeSaleUpdates(sdList);
        return hsdList;
    }

    public static List<SRW_ReportWrappers.SRW_Report10Table1> report10OrganizeSaleUpdates(List<SRW_Sales_Data_gne__c> sdata) {
        List<SRW_ReportWrappers.SRW_Report10Table1> sUpdates = new List<SRW_ReportWrappers.SRW_Report10Table1>();

        if(sdata == null || sdata.isEmpty())
            return sUpdates;

        // generate maps
        Map<String, Map<String, Map<String, List<SRW_Sales_Data_gne__c>>>> mainMapSD = new Map<String, Map<String, Map<String, List<SRW_Sales_Data_gne__c>>>>();
        for(SRW_Sales_Data_gne__c sd : sdata) {
            String orgkey = '' + sd.Trading_Partner_gne__c + sd.Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__c + sd.TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c;
            String prodkey = '' + sd.Product_gne__c;
            String lockey = '' + sd.Prescriber_Organization_Location_gne__c;
            
            if(!mainMapSD.containsKey(orgkey)) {
                mainMapSD.put(orgkey, new Map<String, Map<String, List<SRW_Sales_Data_gne__c>>>());
            }
            Map<String, Map<String, List<SRW_Sales_Data_gne__c>>> prodMap = mainMapSD.get(orgkey);
            if(!prodMap.containsKey(sd.Product_gne__c)) {
                prodMap.put(prodKey, new Map<String, List<SRW_Sales_Data_gne__c>>());
            }
            Map<String, List<SRW_Sales_Data_gne__c>> locMap = prodMap.get(prodKey);
            if(!locMap.containsKey(sd.Prescriber_Organization_Location_gne__c)) {
                locMap.put(sd.Prescriber_Organization_Location_gne__c, new List<SRW_Sales_Data_gne__c>());
            } 
            locMap.get(sd.Prescriber_Organization_Location_gne__c).add(sd);
        }
        String tempCustomerName;
        for(String okey : mainMapSD.keySet()) {
            for(String pkey : mainMapSD.get(okey).keySet()) {
                for(String lkey : mainMapSD.get(okey).get(pkey).keySet()) {
                    List<SRW_Sales_Data_gne__c> sdListMini = mainMapSD.get(okey).get(pkey).get(lkey);
                    if(sdListMini.size() > 1) {
                        SRW_Sales_Data_gne__c sd = sdListMini.get(sdListMini.size()-1);
                        tempCustomerName = 'Prescriber'.equals(sd.Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Type_gne__c) ? sd.Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_First_Name_gne__c + ' ' + sd.Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_Last_Name_gne__c : sd.Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Organization_Name_gne__c;
                        tempCustomerName += report10CreateAddressString(sd);
                        if(sd.Quantity_gne__c != sdListMini.get(sdListMini.size()-2).Quantity_gne__c)
                            sUpdates.add(new SRW_ReportWrappers.SRW_Report10Table1(sd.TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c,
                                sd.Trading_Partner_gne__r.Trading_Partner_Name_gne__c,
                                sd.Trading_Partner_gne__r.Trading_Partner_Address_1_gne__c,
                                tempCustomerName,
                                sd.Product_gne__r.Name,
                                String.valueOf(sdListMini.get(sdListMini.size()-2).Quantity_gne__c),
                                String.valueOf(sdListMini.get(sdListMini.size()-2).LastModifiedDate),
                                String.valueOf(sd.Quantity_gne__c),
                                String.valueOf(sd.LastModifiedDate)));                                              }
                }
            }

        }   

        return sUpdates;
    }

    public static List<SRW_ReportWrappers.SRW_Report10Table2> getReport10Table2(List<String> months) {

        List<SRW_ReportWrappers.SRW_Report10Table2> hsdList = new List<SRW_ReportWrappers.SRW_Report10Table2>();
        List<SRW_Sales_Data_gne__c> sdList = new List<SRW_Sales_Data_gne__c>();
        if(months == null || months.isEmpty())
            return hsdList;
        Set<String> dmSet = new Set<String>();
        dmSet.addAll(months);
        List<String> openedDataMonthsStatus = new List<String>();
        openedDataMonthsStatus.add('Resweep');
        openedDataMonthsStatus.add('Resubmitted');

        if(!dmSet.contains('all')) {
            sdList = [SELECT TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c,
                        Trading_Partner_gne__c, Trading_Partner_gne__r.Trading_Partner_Name_gne__c, Trading_Partner_gne__r.Trading_Partner_Address_1_gne__c,
                            Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Type_gne__c,
                            Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_First_Name_gne__c, 
                            Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_Last_Name_gne__c, 
                            Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Organization_Name_gne__c,
                            Prescriber_Organization_Location_gne__r.Street_Address_1_gne__c,
                        Product_gne__r.Name,
                        Product_gne__r.NDC_Number_gne__c,
                        Quantity_gne__c,
                        CreatedDate,
                        LastModifiedDate,
                        Sweep_Data_Month_gne__r.Real_Sweep_Date_gne__c,
                        Set_Sequence_Number_gne__c
                      FROM SRW_Sales_Data_gne__c 
                      WHERE TP_Data_Month_gne__r.SRW_Data_Month_gne__c IN :dmSet AND TP_Data_Month_gne__r.Data_Month_Status_gne__c IN : openedDataMonthsStatus
                      ORDER BY TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Year_gne__c desc, TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Number_gne__c desc, Trading_Partner_gne__r.Trading_Partner_Name_gne__c Asc, Prescriber_Organization_Location_gne__c, Set_Sequence_Number_gne__c Asc];
        } else {
            sdList = [SELECT TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c,
                        Trading_Partner_gne__c, Trading_Partner_gne__r.Trading_Partner_Name_gne__c, Trading_Partner_gne__r.Trading_Partner_Address_1_gne__c,
                            Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Type_gne__c,
                            Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_First_Name_gne__c, 
                            Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_Last_Name_gne__c, 
                            Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Organization_Name_gne__c,
                            Prescriber_Organization_Location_gne__r.Street_Address_1_gne__c,
                        Product_gne__r.Name,
                        Product_gne__r.NDC_Number_gne__c,
                        Quantity_gne__c,
                        CreatedDate,
                        LastModifiedDate,
                        Sweep_Data_Month_gne__r.Real_Sweep_Date_gne__c,
                        Set_Sequence_Number_gne__c
                      FROM SRW_Sales_Data_gne__c 
                      WHERE TP_Data_Month_gne__r.Data_Month_Status_gne__c IN : openedDataMonthsStatus
                      ORDER BY TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Year_gne__c desc, TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Number_gne__c desc, Trading_Partner_gne__r.Trading_Partner_Name_gne__c Asc, Prescriber_Organization_Location_gne__c, Set_Sequence_Number_gne__c Asc]; 
        }

        hsdList = report10OrganizeSaleUpdatesPerPres(sdList);
        return hsdList;
    }

   
    public static List<SRW_ReportWrappers.SRW_Report10Table2> report10OrganizeSaleUpdatesPerPres(List<SRW_Sales_Data_gne__c> sdata) {
        List<SRW_ReportWrappers.SRW_Report10Table2> sUpdates = new List<SRW_ReportWrappers.SRW_Report10Table2>();

        if(sdata == null || sdata.isEmpty())
            return sUpdates;

        // generate maps
        Map<String, Map<String, Map<String, List<SRW_Sales_Data_gne__c>>>> mainMapSD = new Map<String, Map<String, Map<String, List<SRW_Sales_Data_gne__c>>>>();
        for(SRW_Sales_Data_gne__c sd : sdata) {
            String orgkey = '' + sd.Trading_Partner_gne__c + sd.TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c;
            String prodkey = '' + sd.Product_gne__c;
            String lockey = '' + sd.Prescriber_Organization_Location_gne__c;
            
            if(!mainMapSD.containsKey(orgkey)) {
                mainMapSD.put(orgkey, new Map<String, Map<String, List<SRW_Sales_Data_gne__c>>>());
            }
            Map<String, Map<String, List<SRW_Sales_Data_gne__c>>> prodMap = mainMapSD.get(orgkey);
            if(!prodMap.containsKey(sd.Product_gne__c)) {
                prodMap.put(prodKey, new Map<String, List<SRW_Sales_Data_gne__c>>());
            }
            Map<String, List<SRW_Sales_Data_gne__c>> locMap = prodMap.get(prodKey);
            if(!locMap.containsKey(sd.Prescriber_Organization_Location_gne__c)) {
                locMap.put(sd.Prescriber_Organization_Location_gne__c, new List<SRW_Sales_Data_gne__c>());
            } 
            locMap.get(sd.Prescriber_Organization_Location_gne__c).add(sd);
        }
        Boolean changed;
        Decimal q1;
        Decimal q2;
        String tempCustomerName;
        for(String okey : mainMapSD.keySet()) {
            for(String pkey : mainMapSD.get(okey).keySet()) {
                q1 = 0;
                q2 = 0;
                changed = false;
                SRW_Sales_Data_gne__c sd;
                for(String lkey : mainMapSD.get(okey).get(pkey).keySet()) {
                    List<SRW_Sales_Data_gne__c> sdListMini = mainMapSD.get(okey).get(pkey).get(lkey);
                    sd = sdListMini.get(0);

                    if(sdListMini.size() == 1) {
                        q1 += sdListMini.get(sdListMini.size()-1).Quantity_gne__c;
                        q2 += sdListMini.get(sdListMini.size()-1).Quantity_gne__c;
                    } else if(sdListMini.size() > 1) {
                        changed = true;                     
                        q1 += sdListMini.get(sdListMini.size()-2).Quantity_gne__c;
                        q2 += sdListMini.get(sdListMini.size()-1).Quantity_gne__c;
                    }
                }

                if(changed) {
                    if(q1 != q2)
                        sUpdates.add(new SRW_ReportWrappers.SRW_Report10Table2(sd.TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c,
                                    sd.Trading_Partner_gne__r.Trading_Partner_Name_gne__c,
                                    sd.Product_gne__r.Name,
                                    sd.Product_gne__r.NDC_Number_gne__c,
                                    String.valueof(q1),
                                    String.valueof(q2)));
                }
            }
        }

        return sUpdates;
    }

    private static String report10CreateAddressString(SRW_Sales_Data_gne__c sd) {
        String addrs = '';
        if(sd.Prescriber_Organization_Location_gne__r.Street_Address_1_gne__c != null)
            addrs += sd.Prescriber_Organization_Location_gne__r.Street_Address_1_gne__c + ', ';
        if(sd.Prescriber_Organization_Location_gne__r.City_gne__c != null)
            addrs += sd.Prescriber_Organization_Location_gne__r.City_gne__c + ', ';
        if(sd.Prescriber_Organization_Location_gne__r.State_gne__c != null)
            addrs += sd.Prescriber_Organization_Location_gne__r.State_gne__c + ' ';
        if(sd.Prescriber_Organization_Location_gne__r.Street_Address_1_gne__c != null)
            addrs += sd.Prescriber_Organization_Location_gne__r.Zip_Code_gne__c;

        if(addrs.endsWith(','))
            addrs.removeEnd(',');
        return addrs;
    }

    // ###################################################################################
    // ########################### REPORT 11 #############################################
    // ################# Opened Data Month Request #######################################
    // ###################################################################################
    public static List<SRW_ReportWrappers.SRW_Report11Table1> getReport11Table1(List<String> months) {
        List<SRW_ReportWrappers.SRW_Report11Table1> dmoList = new List<SRW_ReportWrappers.SRW_Report11Table1>();
        List<SRW_TP_Data_Month_Exception__c> dmeList = new List<SRW_TP_Data_Month_Exception__c>();
        if(months == null || months.isEmpty())
            return dmoList;
        Set<String> dmSet = new Set<String>();
        dmSet.addAll(months);
        if(dmSet.contains('all')) {
            dmeList = [Select id, CreatedDate, LastModifiedDate, SRW_Trading_Partner_Profile_gne__c, SRW_Trading_Partner_Profile_gne__r.Trading_Partner_Name_gne__c, CreatedBy.Username ,SRW_TP_Data_Month_gne__c, SRW_TP_Data_Month_gne__r.Data_Month_Status_gne__c,SRW_TP_Data_Month_gne__r.SRW_Data_Month_gne__c, SRW_TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c from SRW_TP_Data_Month_Exception__c]; 
        } else {
            dmeList = [Select id, CreatedDate, LastModifiedDate, SRW_Trading_Partner_Profile_gne__c, SRW_Trading_Partner_Profile_gne__r.Trading_Partner_Name_gne__c, CreatedBy.Username, SRW_TP_Data_Month_gne__c,  SRW_TP_Data_Month_gne__r.Data_Month_Status_gne__c, SRW_TP_Data_Month_gne__r.SRW_Data_Month_gne__c, SRW_TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c from SRW_TP_Data_Month_Exception__c where SRW_TP_Data_Month_gne__r.SRW_Data_Month_gne__c in :dmSet];
        }
        Map<String, String> flagMap = new Map<String,String>();
        Map<String, String> reSweepDateMap = new Map<String,String>();

        List<String> tpDMIds = new List<String>();
        List<String> dmIds = new List<String>();
        for(SRW_TP_Data_Month_Exception__c dme: dmeList) {
            tpDMIds.add(dme.SRW_TP_Data_Month_gne__c);
            dmIds.add(dme.SRW_TP_Data_Month_gne__r.SRW_Data_Month_gne__c);
        }

        for(SRW_ReSweep_File__c rsf : [select Data_Month_gne__c, ReSweep_Date_gne__c from SRW_ReSweep_File__c where Data_Month_gne__c in :dmIds order by createddate desc]) {
            if(!reSweepDateMap.containsKey(rsf.Data_Month_gne__c))
                reSweepDateMap.put(rsf.Data_Month_gne__c, String.valueOf(rsf.ReSweep_Date_gne__c));
        }

        List<SRW_Sales_Data_Exception__c> sdeList = [Select Historical_Sales_Data_Update_gne__c, SRW_TP_Data_Month_gne__c, SRW_Trading_Partner_Profile_gne__c  from SRW_Sales_Data_Exception__c where SRW_TP_Data_Month_gne__c in: tpDMIds order by SRW_TP_Data_Month_gne__c];
        for(SRW_Sales_Data_Exception__c sde : sdeList) {
            if(!flagMap.containsKey(sde.SRW_TP_Data_Month_gne__c)) {
                flagMap.put(sde.SRW_TP_Data_Month_gne__c, 'NO');
            }
            if('Yes'.equals(sde.Historical_Sales_Data_Update_gne__c))
                flagMap.put(sde.SRW_TP_Data_Month_gne__c, 'YES');   
        }   

        for(SRW_TP_Data_Month_Exception__c dme: dmeList) {
            dmoList.add(new SRW_ReportWrappers.SRW_Report11Table1(dme.SRW_TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c,
                dme.SRW_Trading_Partner_Profile_gne__r.Trading_Partner_Name_gne__c,
                dme.CreatedBy.Username, 
                String.valueOf(dme.CreatedDate),
                flagMap.get(dme.SRW_TP_Data_Month_gne__c),
                reSweepDateMap.containsKey(dme.SRW_TP_Data_Month_gne__r.SRW_Data_Month_gne__c) ? reSweepDateMap.get(dme.SRW_TP_Data_Month_gne__r.SRW_Data_Month_gne__c) : ''));
        }
        return dmoList;
    }

    // ###################################################################################
    // ########################### REPORT 12 #############################################
    // ################# Variance ########################################################
    // ###################################################################################
    public static List<SRW_ReportWrappers.SRW_Report12Table1> getReport12Table1(List<String> months, List<String> tps){

        List<SRW_ReportWrappers.SRW_Report12Table1> varianceValues = new List<SRW_ReportWrappers.SRW_Report12Table1>();
        if(months == null || months.isEmpty() || tps == null || tps.isEmpty())
            return varianceValues;

        List<String> openedDataMonthsStatus = new List<String>();
        openedDataMonthsStatus.add('Resweep');
        openedDataMonthsStatus.add('Resubmitted');
        Set<String> uniqueDataMonthIds = new Set<String>(months);
        Set<String> uniqueTradingPartnerIds = new Set<String>(tps);
        List<SRW_Sales_Data_gne__c> salesEntry = new List<SRW_Sales_Data_gne__c>();

        if(uniqueDataMonthIds.contains('all')){
            if(uniqueTradingPartnerIds.contains('all')){
                salesEntry = [SELECT TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c,
                                Trading_Partner_gne__r.Trading_Partner_Name_gne__c, Trading_Partner_gne__r.Trading_Partner_Address_1_gne__c,
                                    Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_First_Name_gne__c,
                                    Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Type_gne__c, 
                                    Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_Last_Name_gne__c, 
                                    Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Organization_Name_gne__c,
                                    Prescriber_Organization_Location_gne__r.Street_Address_1_gne__c,
                                Product_gne__r.Name,
                                Quantity_gne__c,
                                CreatedDate,
                                Sweep_Data_Month_gne__r.Real_Sweep_Date_gne__c,
                                Set_Sequence_Number_gne__c
                              FROM SRW_Sales_Data_gne__c
                              WHERE Sweep_Data_Month_gne__c != null AND TP_Data_Month_gne__r.Data_Month_Status_gne__c IN : openedDataMonthsStatus
                              ORDER BY TP_Data_Month_gne__r.Name Desc, Trading_Partner_gne__r.Trading_Partner_Name_gne__c Asc, Set_Sequence_Number_gne__c Asc]; 
            } else {
                salesEntry = [SELECT TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c,
                                Trading_Partner_gne__r.Trading_Partner_Name_gne__c, Trading_Partner_gne__r.Trading_Partner_Address_1_gne__c,
                                    Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_First_Name_gne__c,
                                    Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Type_gne__c, 
                                    Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_Last_Name_gne__c, 
                                    Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Organization_Name_gne__c,
                                    Prescriber_Organization_Location_gne__r.Street_Address_1_gne__c,
                                Product_gne__r.Name,
                                Quantity_gne__c,
                                CreatedDate,
                                Sweep_Data_Month_gne__r.Real_Sweep_Date_gne__c,
                                Set_Sequence_Number_gne__c
                              FROM SRW_Sales_Data_gne__c 
                              WHERE Trading_Partner_gne__c IN :uniqueTradingPartnerIds AND Sweep_Data_Month_gne__c != null AND TP_Data_Month_gne__r.Data_Month_Status_gne__c IN : openedDataMonthsStatus
                              ORDER BY TP_Data_Month_gne__r.Name Desc, Trading_Partner_gne__r.Trading_Partner_Name_gne__c Asc, Set_Sequence_Number_gne__c Asc]; 
            }
        } else {
            if(uniqueTradingPartnerIds.contains('all')){
                salesEntry = [SELECT TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c,
                                Trading_Partner_gne__r.Trading_Partner_Name_gne__c, Trading_Partner_gne__r.Trading_Partner_Address_1_gne__c,
                                    Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_First_Name_gne__c,
                                    Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Type_gne__c, 
                                    Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_Last_Name_gne__c, 
                                    Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Organization_Name_gne__c,
                                    Prescriber_Organization_Location_gne__r.Street_Address_1_gne__c,
                                Product_gne__r.Name,
                                Quantity_gne__c,
                                CreatedDate,
                                Sweep_Data_Month_gne__r.Real_Sweep_Date_gne__c,
                                Set_Sequence_Number_gne__c
                              FROM SRW_Sales_Data_gne__c 
                              WHERE TP_Data_Month_gne__r.SRW_Data_Month_gne__c IN :uniqueDataMonthIds AND Sweep_Data_Month_gne__c != null AND TP_Data_Month_gne__r.Data_Month_Status_gne__c IN : openedDataMonthsStatus
                              ORDER BY TP_Data_Month_gne__r.Name Desc, Trading_Partner_gne__r.Trading_Partner_Name_gne__c Asc, Set_Sequence_Number_gne__c Asc]; 
            } else{
                salesEntry = [SELECT TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c,
                                Trading_Partner_gne__r.Trading_Partner_Name_gne__c, Trading_Partner_gne__r.Trading_Partner_Address_1_gne__c,
                                    Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Type_gne__c,
                                    Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_First_Name_gne__c, 
                                    Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_Last_Name_gne__c, 
                                    Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Organization_Name_gne__c,
                                    Prescriber_Organization_Location_gne__r.Street_Address_1_gne__c,
                                Product_gne__r.Name,
                                Quantity_gne__c,
                                CreatedDate,
                                Sweep_Data_Month_gne__r.Real_Sweep_Date_gne__c,
                                Set_Sequence_Number_gne__c
                              FROM SRW_Sales_Data_gne__c 
                              WHERE TP_Data_Month_gne__r.SRW_Data_Month_gne__c IN :uniqueDataMonthIds AND Sweep_Data_Month_gne__c != null
                              AND Trading_Partner_gne__c IN :uniqueTradingPartnerIds AND TP_Data_Month_gne__r.Data_Month_Status_gne__c IN : openedDataMonthsStatus
                              ORDER BY TP_Data_Month_gne__r.Name Desc, Trading_Partner_gne__r.Trading_Partner_Name_gne__c Asc, Set_Sequence_Number_gne__c Asc]; 
            }
        }
        String tempCustomerName;
        for(SRW_Sales_Data_gne__c sd : salesEntry){
            tempCustomerName = 'Prescriber'.equals(sd.Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Type_gne__c) ? sd.Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_First_Name_gne__c + ' ' + sd.Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_Last_Name_gne__c : sd.Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Organization_Name_gne__c;
            tempCustomerName += sd.Prescriber_Organization_Location_gne__r.Street_Address_1_gne__c;
            varianceValues.add(new SRW_ReportWrappers.SRW_Report12Table1(sd.TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c, sd.Trading_Partner_gne__r.Trading_Partner_Name_gne__c, sd.Trading_Partner_gne__r.Trading_Partner_Address_1_gne__c, tempCustomerName, sd.Product_gne__r.Name, String.valueOf(sd.Quantity_gne__c), sd.CreatedDate, sd.Sweep_Data_Month_gne__r.Real_Sweep_Date_gne__c)); 
        }
        varianceValues.sort();
        if(!varianceValues.isEmpty()){
            Integer looper = varianceValues.size() -1;
            for (Integer i = 1; i < looper ; i++){
                if(!varianceValues[i].isTheSameToProduct(varianceValues[i+1])){
                    if(varianceValues[i].isTheSameToProduct(varianceValues[i-1])){
                        Decimal var = Decimal.valueOf(varianceValues[i].quantity) - Decimal.valueOf(varianceValues[i-1].quantity);
                        SRW_ReportWrappers.SRW_Report12Table1 temp = new SRW_ReportWrappers.SRW_Report12Table1(varianceValues[i].dataMonth, varianceValues[i].tradingPartnerName, varianceValues[i].tradingPartnerAddress, varianceValues[i].customerName, 'variance', String.valueOf(var), system.now(), system.now());
                        varianceValues.add(++i, temp);
                        looper++;
                    }else{
                        SRW_ReportWrappers.SRW_Report12Table1 temp = new SRW_ReportWrappers.SRW_Report12Table1(varianceValues[i].dataMonth, varianceValues[i].tradingPartnerName, varianceValues[i].tradingPartnerAddress, varianceValues[i].customerName, varianceValues[i].productName, '-', '', '');
                        varianceValues.add(i++, temp);
                        looper++;
                        temp = new SRW_ReportWrappers.SRW_Report12Table1(varianceValues[i].dataMonth, varianceValues[i].tradingPartnerName, varianceValues[i].tradingPartnerAddress, varianceValues[i].customerName, 'variance', varianceValues[i].quantity, varianceValues[i].submissionTimeStamp, varianceValues[i].sweepResweepDate);
                        varianceValues.add(++i, temp);
                        looper++;
                    }
                }
            }
            if(varianceValues[looper-1].isTheSameToProduct(varianceValues[looper])){
                Decimal var = Decimal.valueOf(varianceValues[looper].quantity) - Decimal.valueOf(varianceValues[looper-1].quantity);
                SRW_ReportWrappers.SRW_Report12Table1 temp = new SRW_ReportWrappers.SRW_Report12Table1(varianceValues[looper].dataMonth, varianceValues[looper].tradingPartnerName, varianceValues[looper].tradingPartnerAddress, varianceValues[looper].customerName, 'variance', String.valueOf(var), system.now(), system.now());
                varianceValues.add(temp);
            }else{
                SRW_ReportWrappers.SRW_Report12Table1 temp = new SRW_ReportWrappers.SRW_Report12Table1(varianceValues[looper].dataMonth, varianceValues[looper].tradingPartnerName, varianceValues[looper].tradingPartnerAddress, varianceValues[looper].customerName, varianceValues[looper].productName, '-', '', '');
                varianceValues.add(looper, temp);
                looper++;
                temp = new SRW_ReportWrappers.SRW_Report12Table1(varianceValues[looper].dataMonth, varianceValues[looper].tradingPartnerName, varianceValues[looper].tradingPartnerAddress, varianceValues[looper].customerName, 'variance', varianceValues[looper].quantity, varianceValues[looper].submissionTimeStamp, varianceValues[looper].sweepResweepDate);
                varianceValues.add(looper, temp);
            }
        }

        return varianceValues;
    }

    //count totals + last but one totals - max seq number + max seq number -1
    public static List<SRW_ReportWrappers.SRW_Report12Table2> getReport12Table2(List<String> months, List<String> tps){

        List<SRW_ReportWrappers.SRW_Report12Table2> totalsVariance = new List<SRW_ReportWrappers.SRW_Report12Table2>();
        if(months == null || months.isEmpty() || tps == null || tps.isEmpty())
            return totalsVariance;

        List<String> openedDataMonthsStatus = new List<String>();
        openedDataMonthsStatus.add('Resweep');
        openedDataMonthsStatus.add('Resubmitted');
        List<SRW_Sales_Data_gne__c> sdl;
        Set<String> uniqueDataMonthIds = new Set<String>(months);
        Set<String> uniqueTradingPartnerIds = new Set<String>(tps);
               //WHERE Sweep_Data_Month_gne__r.Real_Sweep_Date_gne__c  >  :dateTimeFrom  AND Sweep_Data_Month_gne__r.Real_Sweep_Date_gne__c <= :dateTimeTo
        if(uniqueDataMonthIds.contains('all')){
            if(uniqueTradingPartnerIds.contains('all')){
                sdl = [SELECT Product_gne__r.Name, Product_gne__r.id, Product_gne__r.NDC_Number_gne__c, Quantity_gne__c, Prescriber_Organization_Location_gne__r.id, Set_Sequence_Number_gne__c, TP_Data_Month_gne__r.id
                       FROM SRW_Sales_Data_gne__c WHERE TP_Data_Month_gne__r.Data_Month_Status_gne__c IN : openedDataMonthsStatus
                       ORDER BY Product_gne__r.Name Desc];
            } else {
                sdl = [SELECT Product_gne__r.Name, Product_gne__r.id, Product_gne__r.NDC_Number_gne__c, Quantity_gne__c, Prescriber_Organization_Location_gne__r.id, Set_Sequence_Number_gne__c, TP_Data_Month_gne__r.id
                       FROM SRW_Sales_Data_gne__c 
                       WHERE Trading_Partner_gne__c IN :uniqueTradingPartnerIds AND TP_Data_Month_gne__r.Data_Month_Status_gne__c IN : openedDataMonthsStatus
                       ORDER BY Product_gne__r.Name Desc];
            }
        } else {
            if(uniqueTradingPartnerIds.contains('all')){
                sdl = [SELECT Product_gne__r.Name, Product_gne__r.id, Product_gne__r.NDC_Number_gne__c, Quantity_gne__c, Prescriber_Organization_Location_gne__r.id, Set_Sequence_Number_gne__c, TP_Data_Month_gne__r.id
                       FROM SRW_Sales_Data_gne__c 
                       WHERE TP_Data_Month_gne__r.SRW_Data_Month_gne__c IN :uniqueDataMonthIds AND TP_Data_Month_gne__r.Data_Month_Status_gne__c IN : openedDataMonthsStatus
                       ORDER BY Product_gne__r.Name Desc];
            } else{
                sdl = [SELECT Product_gne__r.Name, Product_gne__r.id, Product_gne__r.NDC_Number_gne__c, Quantity_gne__c, Prescriber_Organization_Location_gne__r.id, Set_Sequence_Number_gne__c, TP_Data_Month_gne__r.id
                       FROM SRW_Sales_Data_gne__c 
                       WHERE TP_Data_Month_gne__r.SRW_Data_Month_gne__c IN :uniqueDataMonthIds
                       AND Trading_Partner_gne__c IN :uniqueTradingPartnerIds AND TP_Data_Month_gne__r.Data_Month_Status_gne__c IN : openedDataMonthsStatus
                       ORDER BY Product_gne__r.Name Desc];
            }
        }

        system.debug('previous sales Data: ' + sdl);                                      
        Map<SRW_ReportWrappers.SRW_Report12SalesDataKey, SRW_ReportWrappers.SRW_Report12SalesDataValue> salesMap = new Map<SRW_ReportWrappers.SRW_Report12SalesDataKey, SRW_ReportWrappers.SRW_Report12SalesDataValue>();
        Map<SRW_ReportWrappers.SRW_Report12SalesDataKey, SRW_ReportWrappers.SRW_Report12SalesDataValue> salesMapLastButOne = new Map<SRW_ReportWrappers.SRW_Report12SalesDataKey, SRW_ReportWrappers.SRW_Report12SalesDataValue>();

        for (SRW_Sales_Data_gne__c sd : sdl){
            if (salesMap.containsKey(new SRW_ReportWrappers.SRW_Report12SalesDataKey(sd.Product_gne__r.NDC_Number_gne__c, sd.Prescriber_Organization_Location_gne__c, sd.TP_Data_Month_gne__r.id))){
                if(salesMap.get(new SRW_ReportWrappers.SRW_Report12SalesDataKey(sd.Product_gne__r.NDC_Number_gne__c, sd.Prescriber_Organization_Location_gne__r.id, sd.TP_Data_Month_gne__r.id)).sequenceNumber < sd.Set_Sequence_Number_gne__c){
                    salesMap.put(new SRW_ReportWrappers.SRW_Report12SalesDataKey(sd.Product_gne__r.NDC_Number_gne__c, sd.Prescriber_Organization_Location_gne__r.id, sd.TP_Data_Month_gne__r.id), new SRW_ReportWrappers.SRW_Report12SalesDataValue(sd.Quantity_gne__c, sd.Set_Sequence_Number_gne__c, sd.Product_gne__r.NDC_Number_gne__c, sd.Product_gne__r.Name, sd.id));
                }
            }else {
                salesMap.put(new SRW_ReportWrappers.SRW_Report12SalesDataKey(sd.Product_gne__r.NDC_Number_gne__c, sd.Prescriber_Organization_Location_gne__r.id, sd.TP_Data_Month_gne__r.id), new SRW_ReportWrappers.SRW_Report12SalesDataValue(sd.Quantity_gne__c, sd.Set_Sequence_Number_gne__c, sd.Product_gne__r.NDC_Number_gne__c, sd.Product_gne__r.Name, sd.id));
            }
        }

        for (SRW_Sales_Data_gne__c sd : sdl){
            if (salesMapLastButOne.containsKey(new SRW_ReportWrappers.SRW_Report12SalesDataKey(sd.Product_gne__r.NDC_Number_gne__c, sd.Prescriber_Organization_Location_gne__c, sd.TP_Data_Month_gne__r.id))){
                if(salesMap.get(new SRW_ReportWrappers.SRW_Report12SalesDataKey(sd.Product_gne__r.NDC_Number_gne__c, sd.Prescriber_Organization_Location_gne__c, sd.TP_Data_Month_gne__r.id)).sequenceNumber != sd.Set_Sequence_Number_gne__c && salesMapLastButOne.get(new SRW_ReportWrappers.SRW_Report12SalesDataKey(sd.Product_gne__r.NDC_Number_gne__c, sd.Prescriber_Organization_Location_gne__c, sd.TP_Data_Month_gne__r.id)).sequenceNumber < sd.Set_Sequence_Number_gne__c){
                    salesMapLastButOne.put(new SRW_ReportWrappers.SRW_Report12SalesDataKey(sd.Product_gne__r.NDC_Number_gne__c, sd.Prescriber_Organization_Location_gne__c, sd.TP_Data_Month_gne__r.id), new SRW_ReportWrappers.SRW_Report12SalesDataValue(sd.Quantity_gne__c, sd.Set_Sequence_Number_gne__c, sd.Product_gne__r.NDC_Number_gne__c, sd.Product_gne__r.Name, sd.id));
                }
            }else if(salesMap.get(new SRW_ReportWrappers.SRW_Report12SalesDataKey(sd.Product_gne__r.NDC_Number_gne__c, sd.Prescriber_Organization_Location_gne__c, sd.TP_Data_Month_gne__r.id)).sequenceNumber != sd.Set_Sequence_Number_gne__c){
                salesMapLastButOne.put(new SRW_ReportWrappers.SRW_Report12SalesDataKey(sd.Product_gne__r.NDC_Number_gne__c, sd.Prescriber_Organization_Location_gne__c, sd.TP_Data_Month_gne__r.id), new SRW_ReportWrappers.SRW_Report12SalesDataValue(sd.Quantity_gne__c, sd.Set_Sequence_Number_gne__c, sd.Product_gne__r.NDC_Number_gne__c, sd.Product_gne__r.Name, sd.id));
            }
        }

        List<id> productIds = new List<id>();
        for(SRW_ReportWrappers.SRW_Report12SalesDataKey sdk : salesMap.keySet()){
            productIds.add(salesMap.get(sdk).salesId);
        }
        List<AggregateResult> lastSalesData = [SELECT TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Year_gne__c datayear, TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_gne__c datamonth, Trading_Partner_gne__r.Trading_Partner_Name_gne__c tradingPartnerName, Product_gne__r.Name productName, Product_gne__r.NDC_Number_gne__c ndc, SUM(Quantity_gne__c) quantitySum 
                                                FROM SRW_Sales_Data_gne__c
                                                WHERE id IN :productIds 
                                                GROUP BY TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Year_gne__c, TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_gne__c, Trading_Partner_gne__r.Trading_Partner_Name_gne__c, Product_gne__r.Name, Product_gne__r.NDC_Number_gne__c 
                                                ORDER BY TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Year_gne__c, TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_gne__c, Trading_Partner_gne__r.Trading_Partner_Name_gne__c, Product_gne__r.Name ASC];
        productIds.clear();                                     
        for(SRW_ReportWrappers.SRW_Report12SalesDataKey sdk : salesMapLastButOne.keySet()){
            productIds.add(salesMapLastButOne.get(sdk).salesId);
        }
        List<AggregateResult> lastButOneSalesData = [SELECT TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Year_gne__c datayear, TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_gne__c datamonth, Trading_Partner_gne__r.Trading_Partner_Name_gne__c tradingPartnerName, Product_gne__r.Name productName, Product_gne__r.NDC_Number_gne__c ndc, SUM(Quantity_gne__c) quantitySum 
                                                    FROM SRW_Sales_Data_gne__c
                                                    WHERE id IN :productIds 
                                                    GROUP BY TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Year_gne__c, TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_gne__c, Trading_Partner_gne__r.Trading_Partner_Name_gne__c, Product_gne__r.Name, Product_gne__r.NDC_Number_gne__c 
                                                    ORDER BY TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Year_gne__c, TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_gne__c, Trading_Partner_gne__r.Trading_Partner_Name_gne__c, Product_gne__r.Name ASC];                                       
        Map<SRW_ReportWrappers.SRW_Report12LastButOneKey, Decimal> lastButOneQuantityMap = new Map<SRW_ReportWrappers.SRW_Report12LastButOneKey, Decimal>();                                          
        for(AggregateResult ar : lastButOneSalesData){
            lastButOneQuantityMap.put(new SRW_ReportWrappers.SRW_Report12LastButOneKey((String) ar.get('datayear'), (String) ar.get('datamonth'), (String) ar.get('tradingPartnerName'), (String) ar.get('ndc')), (Decimal) ar.get('quantitySum'));
        }   
        for(AggregateResult ar : lastSalesData){
            Boolean contains = false;
            for(SRW_ReportWrappers.SRW_Report12LastButOneKey sdk : lastButOneQuantityMap.keySet()){
                contains = sdk.equals(new SRW_ReportWrappers.SRW_Report12LastButOneKey((String) ar.get('datayear'), (String) ar.get('datamonth'), (String) ar.get('tradingPartnerName'), (String) ar.get('ndc'))) ? true : false;
                if (contains) 
                    break; 
            }
            totalsVariance.add(new SRW_ReportWrappers.SRW_Report12Table2((String) ar.get('datayear') + ' ' +  (String) ar.get('datamonth'), (String) ar.get('tradingPartnerName'), (String) ar.get('productName'), (String) ar.get('ndc'), contains ? String.valueOf(lastButOneQuantityMap.get(new SRW_ReportWrappers.SRW_Report12LastButOneKey((String) ar.get('datayear'), (String) ar.get('datamonth'), (String) ar.get('tradingPartnerName'), (String) ar.get('ndc')))) : '-' , (Decimal) ar.get('quantitySum')));
        }                              
        return totalsVariance;
    }

    // ###################################################################################
    // ########################### REPORT 13 #############################################
    // ################# Login History ###################################################
    // ###################################################################################
    
    public static List<SRW_ReportWrappers.SRW_Report13Table1> getReport13Table1(Date dateFrom, Date dateTo, List<String> tps, String status) {
        List<SRW_ReportWrappers.SRW_Report13Table1> poValues = new List<SRW_ReportWrappers.SRW_Report13Table1>();

        Set<String> alltps = new Set<String>();
        allTps.addall(tps);
         // all, active, inactive, locked

        Datetime dateTimeFrom = dateFrom == null ? Datetime.now() : (Datetime) dateFrom; 
        Datetime dateTimeTo= dateTo == null ? Datetime.now() : (Datetime) dateTo;
        dateTimeTo = dateTimeTo.addDays(1);

        system.debug('datetime to: ' + dateTimeTo + '  |  date to: ' + dateTo);

        List<SRW_Trading_Partner_Profile__c> tpList = allTps.contains('all') ? ('All'.equals(status) ?
                                                      [SELECT Trading_Partner_Name_gne__c, Contact_gne__c, Contact_gne__r.Owner.Username FROM SRW_Trading_Partner_Profile__c] : 
                                                      [SELECT Trading_Partner_Name_gne__c, Contact_gne__c, Contact_gne__r.Owner.Username FROM SRW_Trading_Partner_Profile__c WHERE id IN (SELECT Trading_Partner_gne__c FROM SRW_Security_Community_Data__c WHERE Status_gne__c = :status)] ) :
                                                      ('All'.equals(status) ?
                                                      [SELECT Trading_Partner_Name_gne__c, Contact_gne__c, Contact_gne__r.Owner.Username FROM SRW_Trading_Partner_Profile__c WHERE id IN :allTps] :
                                                      [SELECT Trading_Partner_Name_gne__c, Contact_gne__c, Contact_gne__r.Owner.Username FROM SRW_Trading_Partner_Profile__c WHERE id IN :allTps AND id IN (SELECT Trading_Partner_gne__c FROM SRW_Security_Community_Data__c WHERE Status_gne__c = :status)] );
        Set<String> contactIds = new Set<String>();
        String usernameSuffix = SRW_Utils.getSettingByName('UsernameSufix');
        for (SRW_Trading_Partner_Profile__c tp : tpList) {
            contactIds.add(tp.Contact_gne__c);
        }
        Set<String> userIds = new Set<String>();
        Map<String, User> contactIdToUsernameMap = new Map<String, User>();
        Map<String, User> userMap = new Map<String, User>([select Id, ContactId, Username from User where ContactId IN : contactIds]);
        for (User u : userMap.values()) {
            contactIdToUsernameMap.put(u.ContactId, u);
        }
        Map<String, LoginHistory> userIdToUserMap = new Map<String, LoginHistory>();
        for (LoginHistory lh : [select id, userid, LoginType, LoginTime, Status from LoginHistory where userid IN : userMap.keySet() AND LoginTime >= :dateTimeFrom AND LoginTime < :dateTimeTo]) {
            userIdToUserMap.put(lh.userid, lh);
        }

        for(SRW_Trading_Partner_Profile__c po : tpList) {
            if(contactIdToUsernameMap.containsKey(po.Contact_gne__c)) {
                User u = contactIdToUsernameMap.get(po.Contact_gne__c);
                LoginHistory lh = userIdToUserMap.get(u.Id);
                String username = u.Username.replace(usernameSuffix, '');
                if (null != lh) {
                    poValues.add(new SRW_ReportWrappers.SRW_Report13Table1(
                            username,
                            po.Trading_Partner_Name_gne__c, 
                            lh.LoginTime.format(),
                            lh.Status));
                }
            }
        }
        return poValues;
    }
    // ###################################################################################
    // ########################### REPORT 15 #############################################
    // ################# Prescriber List by Trading Partner bz data month#################
    // ###################################################################################
    public static List<SRW_ReportWrappers.SRW_Report15Table1> getReport15Table1(List<String> years, List<String> months, List<String> tps) {

        List<SRW_ReportWrappers.SRW_Report15Table1> poValues = new List<SRW_ReportWrappers.SRW_Report15Table1>();
        if(years == null || years.isEmpty() || months == null || months.isEmpty() || tps == null || tps.isEmpty())
            return poValues;
        
        Set<String> selectedTPsListSet = new Set<String>();
        selectedTPsListSet.addAll(tps);
        Set<String> selectedYearsSet = new Set<String>();
        selectedYearsSet.addAll(years);
        System.debug('MICK_LOKO : selectedYearsSet ' + selectedYearsSet);
        Set<String> selectedMonthsSet = new Set<String>();
        selectedMonthsSet.addAll(months);
        System.debug('MICK_LOKO : selectedMonthsSet ' + selectedMonthsSet);
        List<SRW_Sales_Data_gne__c> tpDMList = new List<SRW_Sales_Data_gne__c>();

        List<SRW_DataMonths__c> dmScope = new List<SRW_DataMonths__c>();
        
        if(selectedMonthsSet.contains('all') && selectedYearsSet.contains('all') ) {
            dmScope = [Select Id,Data_Month_Cal_gne__c from SRW_DataMonths__c ORDER BY Data_Year_gne__c,Data_Month_Number_gne__c];
            System.debug('MICK_LOKO : 1 ');

        }   else if (selectedMonthsSet.contains('all') || selectedMonthsSet.isEmpty()) {
            System.debug('MICK_LOKO : 2 ');
            dmScope = [Select Id,Data_Month_Cal_gne__c from SRW_DataMonths__c where Data_Year_gne__c IN :selectedYearsSet ORDER BY Data_Year_gne__c,Data_Month_Number_gne__c];

        }   else if(selectedYearsSet.contains('all') || selectedYearsSet.isEmpty()){
            System.debug('MICK_LOKO : 3 ');
            dmScope = [Select Id,Data_Month_Cal_gne__c from SRW_DataMonths__c where Data_Month_gne__c IN :selectedMonthsSet ORDER BY Data_Year_gne__c,Data_Month_Number_gne__c];

        }  else {
            System.debug('MICK_LOKO : 4 ');
            dmScope = [Select Id,Data_Month_Cal_gne__c from SRW_DataMonths__c where Data_Month_gne__c IN :selectedMonthsSet AND Data_Year_gne__c IN :selectedYearsSet ORDER BY Data_Year_gne__c,Data_Month_Number_gne__c];

        }
        System.debug('MICK_LOKO: dmScope -> ' + dmScope);

        if(selectedTPsListSet.contains('all') || selectedTPsListSet.isEmpty()) {
            tpDMList = [Select Id,
                                Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Organization_Name_gne__c,
                                Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_First_Name_gne__c,
                                Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_Last_Name_gne__c,
                                Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Type_gne__c,
                                TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c,
                                TP_Data_Month_gne__r.SRW_Data_Month_gne__c,
                                TP_Data_Month_gne__r.Data_Month_Status_gne__c,
                                Trading_Partner_gne__r.Trading_Partner_Name_gne__c,
                                Trading_Partner_gne__c
                            from SRW_Sales_Data_gne__c 
                            where TP_Data_Month_gne__r.SRW_Data_Month_gne__c IN :dmScope 
                            AND  Is_Actual_gne__c = true
                            ORDER BY TP_Data_Month_gne__r.SRW_Data_Month_gne__c,Trading_Partner_gne__c];
        } else {

                        tpDMList = [Select Id,
                                Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Organization_Name_gne__c,
                                Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_First_Name_gne__c,
                                Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_Last_Name_gne__c,
                                Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Type_gne__c,
                                TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c,
                                TP_Data_Month_gne__r.SRW_Data_Month_gne__c,
                                TP_Data_Month_gne__r.Data_Month_Status_gne__c,
                                Trading_Partner_gne__r.Trading_Partner_Name_gne__c,
                                Trading_Partner_gne__c
                            from SRW_Sales_Data_gne__c 
                            where TP_Data_Month_gne__r.SRW_Data_Month_gne__c IN :dmScope 
                            AND   Trading_Partner_gne__c IN :selectedTPsListSet
                            AND  Is_Actual_gne__c = true
                            ORDER BY TP_Data_Month_gne__r.SRW_Data_Month_gne__c,Trading_Partner_gne__c];
        }
        System.debug('MICK_LOKO: tpDMList -> ' + tpDMList);
        Map<String,List<SRW_Sales_Data_gne__c>> uniqueRecs = new Map<String,List<SRW_Sales_Data_gne__c>>();
        Set<String> presUnique = new Set<String>();
        for(SRW_Sales_Data_gne__c tmp :tpDMList) {
            
            if(!uniqueRecs.containsKey(''  + tmp.Trading_Partner_gne__c +tmp.TP_Data_Month_gne__r.SRW_Data_Month_gne__c)) {
                List<SRW_Sales_Data_gne__c> newSD = new List<SRW_Sales_Data_gne__c>();
                newSD.add(tmp);
                uniqueRecs.put('' + tmp.Trading_Partner_gne__c + tmp.TP_Data_Month_gne__r.SRW_Data_Month_gne__c,newSD);
                presUnique.add('' + tmp.TP_Data_Month_gne__r.SRW_Data_Month_gne__c + tmp.Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__c);
            } 
            else {

                    if(!presUnique.contains(''+ tmp.TP_Data_Month_gne__r.SRW_Data_Month_gne__c + tmp.Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__c)) {
                        uniqueRecs.get('' + tmp.Trading_Partner_gne__c +tmp.TP_Data_Month_gne__r.SRW_Data_Month_gne__c).add(tmp);
                        presUnique.add('' + tmp.TP_Data_Month_gne__r.SRW_Data_Month_gne__c + tmp.Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__c);
                    }
            }
 
        }

        for(List<SRW_Sales_Data_gne__c> tmp : uniqueRecs.values()) {

            String countP = '' + tmp.size();

            for(SRW_Sales_Data_gne__c tmpR : tmp){

                poValues.add(new SRW_ReportWrappers.SRW_Report15Table1(
                    tmpR.TP_Data_Month_gne__r.SRW_Data_Month_gne__r.Data_Month_Cal_gne__c,
                    tmpR.Trading_Partner_gne__r.Trading_Partner_Name_gne__c,
                    tmpR.Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Type_gne__c == 'Organization' ? tmpR.Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Organization_Name_gne__c : tmpR.Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_First_Name_gne__c +' '+ tmpR.Prescriber_Organization_Location_gne__r.Prescriber_or_Organization_gne__r.Prescriber_Last_Name_gne__c,
                    countP,
                    tmpR.TP_Data_Month_gne__r.SRW_Data_Month_gne__c,
                    tmpR.Trading_Partner_gne__c));
            }

        }
        System.debug('MICK_LOKO poValues.size() :' + poValues.size());
        return poValues;
    }
    // ###################################################################################
    // ########################### select options ########################################
    // ###################################################################################

    @RemoteAction
    global static String getTPs() {
        List<SRW_Trading_Partner_Profile__c> tps = [Select Id, Name, Contact_Email_Address_gne__c, Active_gne__c, Trading_Partner_Name_gne__c, Trading_Partner_User_Name_gne__c, Contact_First_Name_gne__c, Contact_Last_Name_gne__c from SRW_Trading_Partner_Profile__c order by Contact_Last_Name_gne__c, Contact_First_Name_gne__c];
        List<SRW_ReportWrappers.SRW_PicklistSelectOptions> options = new List<SRW_ReportWrappers.SRW_PicklistSelectOptions>();
        options.add(new SRW_ReportWrappers.SRW_PicklistSelectOptions('all', 'All'));
        for(SRW_Trading_Partner_Profile__c tp : tps) {
            if(tp.Trading_Partner_Name_gne__c!=null)
                options.add(new SRW_ReportWrappers.SRW_PicklistSelectOptions(tp.Id, tp.Trading_Partner_Name_gne__c));   
        }
        return JSON.serialize(options);
    }

    @RemoteAction
    global static String getPrescriberToTradingPartner(){
        List<SRW_Trading_Partner_Profile__c> tps = [Select Id from SRW_Trading_Partner_Profile__c];
        Set<String> customersId = new Set<String>();
        Map<Id, Set<String>> TPCustomers = new Map<Id, Set<String>>();
        for(SRW_Prescriber_or_Organization__c customer : [SELECT id, Trading_Partner_gne__c FROM SRW_Prescriber_or_Organization__c WHERE Trading_Partner_gne__c != null ORDER BY Trading_Partner_gne__c]){
            if(TPCustomers.containsKey(customer.Trading_Partner_gne__c)){
                customersId = TPCustomers.get(customer.Trading_Partner_gne__c);
                customersId.add(customer.id);
                TPCustomers.put(customer.Trading_Partner_gne__c, customersId);
            } else {
                customersId = new Set<String>();
                customersId.add(customer.id);
                TPCustomers.put(customer.Trading_Partner_gne__c, customersId);
            }
        }
        return JSON.serialize(TPCustomers);
    }
    
    @RemoteAction
    global static String getTPExceptions() {
        List<SRW_Trading_Partner_Profile__c> tps = [Select Id, Name, Contact_Email_Address_gne__c, Active_gne__c, Trading_Partner_Name_gne__c, Trading_Partner_User_Name_gne__c, Contact_First_Name_gne__c, Contact_Last_Name_gne__c from SRW_Trading_Partner_Profile__c where id in (SELECT Trading_Partner_gne__c 
                FROM SRW_TP_Exception__c
                WHERE Trading_Partner_gne__c != null) and Identifier_Not_Found_gne__c = 'YES' order by Contact_Last_Name_gne__c, Contact_First_Name_gne__c];
        List<SRW_ReportWrappers.SRW_PicklistSelectOptions> options = new List<SRW_ReportWrappers.SRW_PicklistSelectOptions>();
        options.add(new SRW_ReportWrappers.SRW_PicklistSelectOptions('all', 'All'));
        for(SRW_Trading_Partner_Profile__c tp : tps) {
            if(tp.Trading_Partner_Name_gne__c!=null)
                options.add(new SRW_ReportWrappers.SRW_PicklistSelectOptions(tp.Id, tp.Trading_Partner_Name_gne__c));   
        }
        return JSON.serialize(options);
    }

    @RemoteAction
    global static String getYears(){

        List<SRW_ReportWrappers.SRW_PicklistSelectOptions> options = new List<SRW_ReportWrappers.SRW_PicklistSelectOptions>();
        Set<String> uniqueVal = new Set<String>();
        
        options.add(new SRW_ReportWrappers.SRW_PicklistSelectOptions('all','All'));
        for(SRW_DataMonths__c tmp : [Select Id,Data_Month_gne__c,Data_Year_gne__c from SRW_DataMonths__c ORDER BY Data_Month_Number_gne__c,Data_Year_gne__c]) {
            if(!uniqueVal.contains(tmp.Data_Year_gne__c)) {
                options.add(new SRW_ReportWrappers.SRW_PicklistSelectOptions(tmp.Data_Year_gne__c, tmp.Data_Year_gne__c)); 
                uniqueVal.add(tmp.Data_Year_gne__c);
            }
        }

        return JSON.serialize(options);
   }

    @RemoteAction
    global static String getMonths(){
        List<SRW_ReportWrappers.SRW_PicklistSelectOptions> options = new List<SRW_ReportWrappers.SRW_PicklistSelectOptions>();
        
        options.add(new SRW_ReportWrappers.SRW_PicklistSelectOptions('all','All'));
        options.add(new SRW_ReportWrappers.SRW_PicklistSelectOptions('1','January'));
        options.add(new SRW_ReportWrappers.SRW_PicklistSelectOptions('2','February'));
        options.add(new SRW_ReportWrappers.SRW_PicklistSelectOptions('3','March'));
        options.add(new SRW_ReportWrappers.SRW_PicklistSelectOptions('4','April'));
        options.add(new SRW_ReportWrappers.SRW_PicklistSelectOptions('5','May'));
        options.add(new SRW_ReportWrappers.SRW_PicklistSelectOptions('6','June'));
        options.add(new SRW_ReportWrappers.SRW_PicklistSelectOptions('7','July'));
        options.add(new SRW_ReportWrappers.SRW_PicklistSelectOptions('8','August'));
        options.add(new SRW_ReportWrappers.SRW_PicklistSelectOptions('9','September'));
        options.add(new SRW_ReportWrappers.SRW_PicklistSelectOptions('10','October'));
        options.add(new SRW_ReportWrappers.SRW_PicklistSelectOptions('11','November'));
        options.add(new SRW_ReportWrappers.SRW_PicklistSelectOptions('12','December'));

        return JSON.serialize(options);
    }

    @RemoteAction
    global static String getMonths2(){
        List<SRW_ReportWrappers.SRW_PicklistSelectOptions> options = new List<SRW_ReportWrappers.SRW_PicklistSelectOptions>();

        options.add(new SRW_ReportWrappers.SRW_PicklistSelectOptions('all','All'));
        Set<String> uniqueVal = new Set<String>();
        for(SRW_DataMonths__c tmp : [Select Id,Data_Month_gne__c,Data_Year_gne__c from SRW_DataMonths__c ORDER BY Data_Month_Number_gne__c,Data_Year_gne__c ]) {
            if(!uniqueVal.contains(tmp.Data_Month_gne__c)) {
                options.add(new SRW_ReportWrappers.SRW_PicklistSelectOptions(tmp.Data_Month_gne__c,tmp.Data_Month_gne__c));
                uniqueVal.add(tmp.Data_Month_gne__c);
            }
        }
            
        return JSON.serialize(options);
     }

    @RemoteAction
    global static String getTPStatuses(){
        List<SRW_ReportWrappers.SRW_PicklistSelectOptions> options = new List<SRW_ReportWrappers.SRW_PicklistSelectOptions>();
        
        options.add(new SRW_ReportWrappers.SRW_PicklistSelectOptions('All','All'));
        options.add(new SRW_ReportWrappers.SRW_PicklistSelectOptions('Active','Active'));
        options.add(new SRW_ReportWrappers.SRW_PicklistSelectOptions('Inactive','Inactive'));
        options.add(new SRW_ReportWrappers.SRW_PicklistSelectOptions('Locked','Locked'));
            
        return JSON.serialize(options);
     }

    @RemoteAction
    global static String getSubmissionStatuses(){
        List<SRW_ReportWrappers.SRW_PicklistSelectOptions> options = new List<SRW_ReportWrappers.SRW_PicklistSelectOptions>();
        
        options.add(new SRW_ReportWrappers.SRW_PicklistSelectOptions('all','All'));
        options.add(new SRW_ReportWrappers.SRW_PicklistSelectOptions('Not Submitted','Not Submitted'));
        options.add(new SRW_ReportWrappers.SRW_PicklistSelectOptions('Submitted - Sales','Submitted - Sales'));
        options.add(new SRW_ReportWrappers.SRW_PicklistSelectOptions('Submitted - No Sales Reported','Submitted - No Sales Reported')); 
        
        return JSON.serialize(options);
    }
    
    @RemoteAction
    global static String getProdStatuses(){
        List<SRW_ReportWrappers.SRW_PicklistSelectOptions> options = new List<SRW_ReportWrappers.SRW_PicklistSelectOptions>();
        options.add(new SRW_ReportWrappers.SRW_PicklistSelectOptions('All','All'));
        options.add(new SRW_ReportWrappers.SRW_PicklistSelectOptions('Active','Active'));
        options.add(new SRW_ReportWrappers.SRW_PicklistSelectOptions('Inactive','Inactive'));
        
        return JSON.serialize(options);
    }

    @RemoteAction
    global static String getBrands() {
        List<Product_vod__c> prods = [Select Id,Brand_Code_gne__c From Product_vod__c  where Product_Type_vod__c = 'SRW'];
        Set<String> uniqueBrandName = new Set<String>();
        List<SRW_ReportWrappers.SRW_PicklistSelectOptions> options = new List<SRW_ReportWrappers.SRW_PicklistSelectOptions>();
        options.add(new SRW_ReportWrappers.SRW_PicklistSelectOptions('all', 'All'));
        for(Product_vod__c prod : prods) {
            if(!uniqueBrandName.contains(prod.Brand_Code_gne__c)) {
                options.add(new SRW_ReportWrappers.SRW_PicklistSelectOptions(prod.Brand_Code_gne__c,prod.Brand_Code_gne__c));
                uniqueBrandName.add(prod.Brand_Code_gne__c);
            }
        }
        return JSON.serialize(options);
    }

    @RemoteAction
    global static String getPrescribersOrganizations() {
        list<id> prescwithExcepIds = new list<id>();
        for(SRW_PO_Exception__c prescwithExceptemp :[Select Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__c
                            FROM SRW_PO_Exception__c 
                            where Prscr_Or_Org_Location_gne__r.Prescriber_Identifier_Not_Found_gne__c = 'YES']){
            prescwithExcepIds.add(prescwithExceptemp.Prscr_Or_Org_Location_gne__r.Prescriber_or_Organization_gne__c);
        }
        
        List<SRW_Prescriber_or_Organization__c> tps = [Select Id, Name, Prescriber_First_Name_gne__c, Prescriber_Last_Name_gne__c, Organization_Name_gne__c FROM SRW_Prescriber_or_Organization__c where id in :prescwithExcepIds ];
        List<SRW_ReportWrappers.SRW_PicklistSelectOptions> options = new List<SRW_ReportWrappers.SRW_PicklistSelectOptions>();
        options.add(new SRW_ReportWrappers.SRW_PicklistSelectOptions('all', 'All'));
        for(SRW_Prescriber_or_Organization__c tp : tps) {
            if((tp.Prescriber_First_Name_gne__c != null && tp.Prescriber_First_Name_gne__c != '')||(tp.Prescriber_Last_Name_gne__c != null && tp.Prescriber_Last_Name_gne__c != '')){
                options.add(new SRW_ReportWrappers.SRW_PicklistSelectOptions(tp.Id, tp.Prescriber_First_Name_gne__c + ' ' +tp.Prescriber_Last_Name_gne__c));
            }else if(tp.Organization_Name_gne__c != null && tp.Organization_Name_gne__c !='') {
                options.add(new SRW_ReportWrappers.SRW_PicklistSelectOptions(tp.Id, tp.Organization_Name_gne__c));
            }
           
        }
        return JSON.serialize(options);
    }

    @RemoteAction
    global static String getVarianceMonths() {
        List<String> openedDataMonthsStatus = new List<String>();
        openedDataMonthsStatus.add('Resubmitted');
        openedDataMonthsStatus.add('Resweep');
        Set<Id> dmsIds = new Set<Id>();
        for (SRW_TP_Data_Months__c temp : [SELECT id, SRW_Data_Month_gne__c FROM SRW_TP_Data_Months__c WHERE Data_Month_Status_gne__c IN :openedDataMonthsStatus]){
            dmsIds.add(temp.SRW_Data_Month_gne__c);
        }
        List<SRW_DataMonths__c> dms = [Select Id, Data_Month_Cal_gne__c from SRW_DataMonths__c where id IN :dmsIds order by Name desc];
        System.debug('--- getallDMs ' + dms);
        List<SRW_ReportWrappers.SRW_PicklistSelectOptions> options = new List<SRW_ReportWrappers.SRW_PicklistSelectOptions>();
        options.add(new SRW_ReportWrappers.SRW_PicklistSelectOptions('all', 'All'));
        for(SRW_DataMonths__c dm : dms) {
            if(dm.Data_Month_Cal_gne__c!=null)
                options.add(new SRW_ReportWrappers.SRW_PicklistSelectOptions(dm.Id, dm.Data_Month_Cal_gne__c)); 
        }
        return JSON.serialize(options);
    }

    @RemoteAction
    global static String getDataSubmissionStatus(){
        List<SRW_ReportWrappers.SRW_PicklistSelectOptions> options = new List<SRW_ReportWrappers.SRW_PicklistSelectOptions>();
        options.add(new SRW_ReportWrappers.SRW_PicklistSelectOptions('sales', 'Submitted –Sales'));
        options.add(new SRW_ReportWrappers.SRW_PicklistSelectOptions('no sales', 'Submitted – No Sales'));
        return JSON.serialize(options);
    }

    @RemoteAction
    global static String getQuantityGreaterThanZero(){
        List<SRW_ReportWrappers.SRW_PicklistSelectOptions> options = new List<SRW_ReportWrappers.SRW_PicklistSelectOptions>();
        options.add(new SRW_ReportWrappers.SRW_PicklistSelectOptions('yes', 'Non Zero'));
        options.add(new SRW_ReportWrappers.SRW_PicklistSelectOptions('no', 'With Zeroes included'));
        return JSON.serialize(options);
    }

    @RemoteAction
    global static Date getReport9DateFrom() {
        Date dateFrom;
        List<AggregateResult> r = [SELECT Max(Last_Sweep_Occurrence_Date_gne__c) lastSweepDate FROM SRW_DataMonths__c];
        if(!r.isEmpty()){
            Datetime dt = (Datetime) r[0].get('lastSweepDate');
            dateFrom = dt == null ? system.today() : dt.date();
        } else {
            dateFrom = System.today();
        }
        return dateFrom;
    }

    // ###################################################################################
    // ########################### excel export  #########################################
    // ###################################################################################

    public PageReference redirectToExport() {
        String filename = 'Report1'.equals(activeReportName) ? 'Trading_Partner_List_By_Status' :
                   'Report2'.equals(activeReportName) ? 'Trading_Partner_List_By_Data_Submission_Status' : 
                   'Report3'.equals(activeReportName) ? 'Product_List_By_Status' : 
                   'Report4'.equals(activeReportName) ? 'Product_List_By_Brand' : 
                   'Report5'.equals(activeReportName) ? 'Prescriber_List_By_Trading_Partner' : 
                   'Report15'.equals(activeReportName) ? 'Prescriber_List_By_Trading_Partner_By_Data_Month' :
                   'Report6'.equals(activeReportName) ? 'Trading_Partner_Sales_Activity_By_Data_Month' : 
                   'Report7'.equals(activeReportName) ? 'Exception_Reports_Trading_Partners_Identifier_Match_Not_found' : 
                   'Report8'.equals(activeReportName) ? 'Exception_Reports_Prescriber_Organization_Identifier_Match_Not_found' : 
                   'Report9'.equals(activeReportName) ? 'Historical_Sales_Data_Backfill' : 
                   'Report10'.equals(activeReportName) ? 'Historical_Sales_Data_Update' : 
                   'Report11'.equals(activeReportName) ? 'Opened_Data_Month_Request':
                   'Report12'.equals(activeReportName) ? 'Variance': 'Login_History';

        Document d = new Document();
        d.AuthorId = UserInfo.getUserId();
        d.folderid = UserInfo.getUserId();
        d.Name = filename + '.xls';
        d.body = Blob.valueof(pageContent);
        insert d;

        PageReference printRef = Page.SRW_Report_Export_Excel;
        //printRef.getParameters().put('activeComponent',activeReportName);
        printRef.getParameters().put('filename', filename);
        //if(String.isNotBlank(parameters))
        //  printRef.getParameters().put('params',parameters);
        printRef.getParameters().put('docId',d.id);
        

        //sendEmail();

        return printRef;
    }

}