public with sharing class CFAR_BudgetReport_Controller {
    
    public transient String fileName {get; private set;}
    public transient String xmlheader {get;set;}
    public transient String endfile {get;set;} 
    
    public List<String> piSubIs {get; set;}
    public String tId {get; set;}
    
    public List<ReportData> rd {get; set;}
    
    public Boolean includeSummary {get; set;}
    

    public CFAR_BudgetReport_Controller() {
        rd = new List<ReportData>();
        filename = 'Payment_Report_' + String.valueOf(Date.today());
        xmlheader ='<?xml version="1.0" encoding="UTF-8"?><?mso-application progid="Excel.Sheet"?>';
        endfile = '</Workbook>';
        init();
        rd = getReportData();
    }
    
    private void init() {
        initSearchParamsFromUlr();
        
    }
    
    private void initSearchParamsFromUlr() {
        String piIds = Apexpages.currentpage().getparameters().get('piIds');
        String includeSummaryString = Apexpages.currentpage().getparameters().get('includeSummary');
        piSubIs = new List<String>();
        tId = Apexpages.currentpage().getparameters().get('tId').substring(0, 15);
        if(String.isNotBlank(piIds)){
            piSubIs.addAll(piIds.split(';', -2));
        }
        
        if(includeSummaryString != null && includeSummaryString=='true') {
            includeSummary = true;
        } else{
            includeSummary = false;
        }
    }
    
    public String getWorkbookProperties() {
        String workbook = '<x:ExcelWorkbook><x:ExcelWorksheets>';
        return workbook;
    }

    private static final String KEY_DELIM = '_';
    public String createInvoiceKey(CFAR_Budget_CPS_Payments_gne__c bcp) {
        return String.valueOf(bcp.Paid_On_gne__c) + CFAR_BudgetReport_Controller.KEY_DELIM + 
                bcp.Invoice_gne__c + CFAR_BudgetReport_Controller.KEY_DELIM + bcp.Check_Num_gne__c;
    }

    public List<ReportData> getReportData() {
        rd = new List<ReportData>();
        Map<String, List<BudgetGeneralInfo>> duplicatedTeamMembersMap = new Map<String, List<BudgetGeneralInfo>>();
        
        CFAR_Trial_gne__c trial = [SELECT Id, Other_Trial_gne_Id__c, name, CTMS_gne__c FROM CFAR_Trial_gne__c WHERE Id =: tId];
        Map<Id, CFAR_Team_Member_gne__c> teamMembers = fetchTeamMembers();
        Map<Id, CFAR_Rate_Table_gne__c> rateTablesMap = fetchRateTables(teamMembers.keySet());
        Map<Id, List<CFAR_Rate_Table_gne__c>> tm2RateTable = fillMemberId2RateTables(rateTablesMap.values());
        Map<Id, List<CFAR_Budget_CPS_Payments_gne__c>> tmId2Payments = fillMemberId2PaymentsMap(rateTablesMap.values());
        Map<Id, CFAR_Contact_Address_gne__c> contactAddressesMap = fetchContactAddressesMap();
              
        for(CFAR_Team_Member_gne__c tm : teamMembers.values()) {
            CFAR_Budget_CPS_Payments_gne__c newestBcp = null;
            Map<String, Invoice> invoiceMap = new Map<String, Invoice>();
            if (tmId2Payments.containsKey(tm.Id)) {
                for(CFAR_Budget_CPS_Payments_gne__c bcp : tmId2Payments.get(tm.Id)) {
                    if((newestBcp == null) ||
                            (bcp.Invoice_Submitted_Date_gne__c != null &&
                                (newestBcp.Invoice_Submitted_Date_gne__c == null || newestBcp.Invoice_Submitted_Date_gne__c < bcp.Invoice_Submitted_Date_gne__c)
                            )) {
                        newestBcp = bcp; //get pament with the latest invoice submitted date
                    }

                    String key = createInvoiceKey(bcp);
                    if (invoiceMap.containsKey(key)) {
                        if (bcp.Invoice_Amount_gne__c != null) {
                            invoiceMap.get(key).amount += bcp.Invoice_Amount_gne__c;
                        }
                    } else {
                        invoiceMap.put(key, new Invoice(CFAR_Utils.toStringNullBlank(bcp.Paid_On_gne__c), bcp.Invoice_Amount_gne__c, bcp.Invoice_gne__c, bcp.Check_Num_gne__c));
                    }
                }
            }
            List<Invoice> invoices = invoiceMap.values();

            Invoice totalI = new Invoice('Payment Total', 0, '', '');                
            List<ContractInfo> contracts = new List<ContractInfo>();            
            ContractInfo totalCI = new ContractInfo('Payment Total', null, null, 0, 0);
            if (newestBcp != null && newestBcp.Invoice_Submitted_Date_gne__c != null) {
                for(CFAR_Budget_CPS_Payments_gne__c bcp : tmId2Payments.get(tm.Id)) {
					totalI.amount += bcp.Invoice_Amount_gne__c == null ? 0 : bcp.Invoice_Amount_gne__c;
                    if (newestBcp.Invoice_Submitted_Date_gne__c == bcp.Invoice_Submitted_Date_gne__c) {
                        ContractInfo contractInfo = new ContractInfo(bcp, rateTablesMap.get(bcp.Rate_Table_ref_gne__c));
                        contracts.add(contractInfo);
                        totalCI.totalAmount +=  CFAR_Utils.nullSafeGet(contractInfo.totalAmount);
                        totalCI.withholding +=  CFAR_Utils.nullSafeGet(contractInfo.withholding);
                    }
                }
            }
            if(!contracts.isEmpty()) {
                contracts.sort();
                contracts.add(totalCI);
            }
            if(!invoices.isEmpty()){
                invoices.add(totalI);
            }
            
            List<ContractSummary> cs =  new List<ContractSummary>();  
            if (includeSummary) {
                Decimal totalCSApprovedAmount = 0;
                Decimal totalCSAmountPaidToDate = 0;
                Decimal totalCSRemainingBalance = 0; 

                if(tm2RateTable.containsKey(tm.Id)) {
                    for(CFAR_Rate_Table_gne__c rt : tm2RateTable.get(tm.Id)) {
                        if(rt.Budget_Contract_ref_gne__r.Team_Member_ref_gne__c != tm.id || rt.Payment_Type_gne__c == 'Total'){
                            continue;    
                        }
                        if(rt.Status_gne__c == 'Active' && includeSummary) {
                            Decimal totalPaidAmount = rt.Total_Paid_Amount_gne__c == null ? 0.00 : rt.Total_Paid_Amount_gne__c;
                            ContractSummary csRecord = new ContractSummary(
                                rt.Contract_Term_gne__c, 
                                rt.Total_Amount_gne__c, 
                                totalPaidAmount, 
                                rt.Remaining_Balance_gne__c,
                                rt.Payment_Type_gne__c
                            );
                            totalCSApprovedAmount += rt.Total_Amount_gne__c;
                            totalCSAmountPaidToDate += totalPaidAmount;
                            totalCSRemainingBalance += rt.Remaining_Balance_gne__c;
                            cs.add(csRecord);
                        }
                    }
                }
                if(!cs.isEmpty() && includeSummary) {
                    ContractSummary totalCS = new ContractSummary('Total Summary', totalCSApprovedAmount, totalCSAmountPaidToDate, totalCSRemainingBalance, null);
                    cs.add(totalCS);
                }
            }
            String poNumber = '';
            if(tm.Budget_Contracts__r.size()> 0){
                poNumber = tm.Budget_Contracts__r[0].PO_Number_gne__c;
            }
            String currentInvoiceDate = newestBcp != null && newestBcp.Invoice_Submitted_Date_gne__c != null ? String.valueOf(newestBcp.Invoice_Submitted_Date_gne__c) : '';
            
            String contactName = tm.contact_address_ref_gne__r.CFAR_Contact_ref_gne__r.Search_Name__c != null ? 
                tm.contact_address_ref_gne__r.CFAR_Contact_ref_gne__r.Search_Name__c : tm.Id;
            BudgetGeneralInfo bi = new BudgetGeneralInfo(
                (trial.Other_Trial_gne_Id__c!=null)?trial.Other_Trial_gne_Id__c:(trial.CTMS_gne__c!=null)?trial.CTMS_gne__c:trial.Name, 
                poNumber, 
                String.valueOf(Date.today()), 
                contactName,
                tm.frm_Function_Role_gne__c != null ? tm.frm_Function_Role_gne__c.split(' ').get(0) : '',
                currentInvoiceDate
            );
            CFAR_Contact_Address_gne__c contractAddress = contactAddressesMap.get(String.valueOf(tm.Contact_address_ref_gne__r.Contact_Address_ref_gne__c));
            bi.fillContactInfo(contractAddress, tm);

            ReportData repData = new ReportData(bi, cs, invoices, contracts);
            rd.add(repData);

            correctIfTeamMemberDuplicated(duplicatedTeamMembersMap, bi);
        }  
        return rd;
    }

    private void correctIfTeamMemberDuplicated(Map<String, List<BudgetGeneralInfo>> duplicatedTeamMembersMap, BudgetGeneralInfo budgetInfoToAdd) {
        if (duplicatedTeamMembersMap.containsKey(budgetInfoToAdd.pi)) {
            List<BudgetGeneralInfo> budgetInfoList = duplicatedTeamMembersMap.get(budgetInfoToAdd.pi);
            if (budgetInfoList.size() == 1) {
                budgetInfoList[0].pi = budgetInfoList[0].pi + ' (1)';
            }
            budgetInfoList.add(budgetInfoToAdd);
            budgetInfoToAdd.pi = budgetInfoToAdd.pi + ' (' + budgetInfoList.size() + ')';
        } else {
            duplicatedTeamMembersMap.put(budgetInfoToAdd.pi, new List<BudgetGeneralInfo> {budgetInfoToAdd});
        }
    }
    
    private Map<Id, CFAR_Contact_Address_gne__c> fetchContactAddressesMap(){
        return new Map<Id, CFAR_Contact_Address_gne__c>([
            SELECT Id, Institution_gne__r.Name, Frm_State_and_Province_gne__c, Frm_Zip_and_Postal_gne__c, 
                Institution_Company_gne__c, City_gne__c, Country_gne__c, Address_gne__c 
            FROM CFAR_Contact_Address_gne__c
        ]);
    }
    
    private Map<Id, List<CFAR_Rate_Table_gne__c>> fillMemberId2RateTables(List<CFAR_Rate_Table_gne__c> rateTables){
        Map<Id, List<CFAR_Rate_Table_gne__c>> memberId2RateTables = new Map<Id, List<CFAR_Rate_Table_gne__c>>();
        for(CFAR_Rate_Table_gne__c rt : rateTables) {
            if(!memberId2RateTables.containsKey(rt.Budget_Contract_ref_gne__r.Team_Member_ref_gne__c)) {
                memberId2RateTables.put(rt.Budget_Contract_ref_gne__r.Team_Member_ref_gne__c, new List<CFAR_Rate_Table_gne__c>());
            }
            memberId2RateTables.get(rt.Budget_Contract_ref_gne__r.Team_Member_ref_gne__c).add(rt);
        }
        return memberId2RateTables;        
    }
    
    private Map<Id, List<CFAR_Budget_CPS_Payments_gne__c>> fillMemberId2PaymentsMap(List<CFAR_Rate_Table_gne__c> rateTables) {
        Map<Id, List<CFAR_Budget_CPS_Payments_gne__c>> tmId2Payments = new Map<Id, List<CFAR_Budget_CPS_Payments_gne__c>>();
        for (CFAR_Rate_Table_gne__c rateTable : rateTables) {
            if (tmId2Payments.containsKey(rateTable.Budget_Contract_ref_gne__r.Team_Member_ref_gne__c)) {
                tmId2Payments.get(rateTable.Budget_Contract_ref_gne__r.Team_Member_ref_gne__c).addAll(rateTable.gSTARS_Budget_CPS_Payments__r);
            } else {
                tmId2Payments.put(rateTable.Budget_Contract_ref_gne__r.Team_Member_ref_gne__c, rateTable.gSTARS_Budget_CPS_Payments__r);
            }
        }
        return tmId2Payments;
    }
    
    private Map<Id,CFAR_Team_Member_gne__c> fetchTeamMembers(){
        return new Map<Id, CFAR_Team_Member_gne__c>([
            SELECT Id, (SELECT PO_Number_gne__c FROM Budget_Contracts__r), 
                Contact_address_ref_gne__r.CFAR_Contact_ref_gne__r.Search_Name__c, Contact_address_ref_gne__c, 
                Contact_address_ref_gne__r.Contact_Address_ref_gne__c,
                Contact_address_ref_gne__r.Department_Division_gne__c, Contact_address_ref_gne__r.CFAR_Contact_ref_gne__r.Phone_gne__c, 
                Contact_address_ref_gne__r.CFAR_Contact_ref_gne__r.Fax_gne__c, Contact_address_ref_gne__r.CFAR_Contact_ref_gne__r.Email_gne__c,
                frm_Function_Role_gne__c
            FROM CFAR_Team_Member_gne__c 
            WHERE Id IN : piSubIs
            AND CFAR_Trial_ref_gne__c = :tId
        ]);
    }

    private Map<Id, CFAR_Rate_Table_gne__c> fetchRateTables(Set<Id> tmIds){
        return new Map<Id, CFAR_Rate_Table_gne__c> ([
            SELECT Net_Unit_Cost_gne__c, Remaining_Balance_gne__c, Contract_Term_gne__c, Cost_gne__c, Budget_Contract_ref_gne__r.Team_Member_ref_gne__c, Payment_Type_gne__c,
                    Name, Id, Total_Amount_gne__c, Unit_gne__c, WithHold_Type_gne__c, WithHold_Value_gne__c, Status_gne__c, Total_Paid_Amount_gne__c, Withhold_Amount_gne__c,
                (SELECT Id, Budget_Contract_ref_gne__r.Team_Member_ref_gne__c, Payment_Explanation_Text_gne__c, Paid_On_gne__c, Invoice_gne__c, Invoice_Amount_gne__c,
                        Check_Num_gne__c, Invoice_Submitted_Date_gne__c, Withhold_Indicator_gne__c, Rate_Table_ref_gne__c
                FROM gSTARS_Budget_CPS_Payments__r
                WHERE Payment_Status_ref_gne__r.Name IN ('Payment Due No Invoice Submitted', 'Invoice Submitted', 'Invoice Paid', 'Refund')
                ORDER BY Invoice_Submitted_Date_gne__c DESC NULLS LAST, Invoice_gne__c DESC NULLS LAST)
            FROM CFAR_Rate_Table_gne__c
            WHERE Budget_Contract_ref_gne__r.Team_Member_ref_gne__c IN :tmIds
              AND Status_gne__c = 'Active'
        ]);
    }
    
    public class BudgetGeneralInfo {
        public String protocolNumber {get; set;}
        public String po {get; set;}
        public String reportDate {get; set;}
        public String pi {get; set;}
        public String functionRole {get; set;}
        public String currentInvoice {get; set;}
        //public String siteInvoiceDate {get; set;}
        //public String siteInvoiceNumber {get; set;}
        public String institutionName {get; private set;}
        public String department {get; private set;}
        public String address {get; private set;}
        public String phone {get; private set;}
        public String fax {get; private set;}
        public String email {get; private set;}
        
        public BudgetGeneralInfo(
            String protocolNumber, 
            String po, 
            String reportDate, 
            String pi,
            String functionRole,
            String currentInvoice//,
            //String siteInvoiceDate,
            //String siteInvoiceNumber
        ) {
            this.protocolNumber    = CFAR_Utils.customEscape(protocolNumber);
            this.po                = CFAR_Utils.customEscape(po);
            this.reportDate        = CFAR_Utils.customEscape(reportDate);  
            this.functionRole	   = CFAR_Utils.customEscape(functionRole);  
            this.pi                = CFAR_Utils.customEscape(pi);
            this.currentInvoice    = CFAR_Utils.customEscape(currentInvoice);
            //this.siteInvoiceDate   = CFAR_Utils.customEscape(siteInvoiceDate);
            //this.siteInvoiceNumber = CFAR_Utils.customEscape(siteInvoiceNumber);
        }     
        
        private void fillContactInfo(CFAR_Contact_Address_gne__c contractAddress, CFAR_Team_Member_gne__c tm){
            if (contractAddress == null) {
                return;
            }
            String strAddress = '';
            institutionName = CFAR_Utils.customEscape(contractAddress.Institution_gne__r.Name);
            department = CFAR_Utils.customEscape(tm.contact_address_ref_gne__r.Department_Division_gne__c);
            strAddress = String.isNotBlank(contractAddress.Address_gne__c) ? contractAddress.Address_gne__c + ', '  : ' ';
            strAddress += String.isNotBlank(contractAddress.City_gne__c) ? contractAddress.City_gne__c + ', '  : ' ';
            strAddress += String.isNotBlank(contractAddress.Frm_State_and_Province_gne__c) ? contractAddress.Frm_State_and_Province_gne__c + ', ' : ' ';
            strAddress += String.isNotBlank(contractAddress.Frm_Zip_and_Postal_gne__c) ? contractAddress.Frm_Zip_and_Postal_gne__c : ' ';
            address = CFAR_Utils.customEscape(strAddress);
            phone = CFAR_Utils.customEscape(tm.Contact_address_ref_gne__r.CFAR_Contact_ref_gne__r.Phone_gne__c);
            fax = CFAR_Utils.customEscape(tm.Contact_address_ref_gne__r.CFAR_Contact_ref_gne__r.Fax_gne__c);
            email = CFAR_Utils.customEscape(tm.Contact_address_ref_gne__r.CFAR_Contact_ref_gne__r.Email_gne__c);
        }
    }
    
    public class ContractSummary {
        public String contractTerm {get; set;}
        public String paymentType {get; set;}
        public Decimal approvedValue {get; set;}
        public Decimal paidValue {get; set;}
        public Decimal remainingValue {get; set;}
        
        public ContractSummary(
            String contractTerm, 
            Decimal approvedValue, 
            Decimal paidValue, 
            Decimal remainingValue,
            String paymentType
        ) {
            this.contractTerm = CFAR_Utils.customEscape(contractTerm);
            this.approvedValue = approvedValue;
            this.paidValue = paidValue;
            this.remainingValue = remainingValue; 
            this.paymentType = CFAR_Utils.customEscape(paymentType);
        }
    }
    
    public class Invoice {
        public String datePaid {get; set;}
        public Decimal amount {get; set;}    
        public String invoiceNumber {get; set;}    
        public String referenceNumber {get; set;}
        
        public Invoice(String datePaid, Decimal amount, String invoiceNumber, String referenceNumber) {
            this.datePaid = CFAR_Utils.customEscape(datePaid);
            this.amount = amount;
            this.invoiceNumber = CFAR_Utils.customEscape(invoiceNumber);
            this.referenceNumber = CFAR_Utils.customEscape(referenceNumber);        
        }
    }
    
    public class ContractInfo implements Comparable{
        public String description {get; set;}
        public Decimal cost {get; set;}    
        public Decimal units {get; set;}    
        public Decimal totalAmount {get; set;}    
        public Decimal withholding {get; set;}
        
        public ContractInfo(String description, Decimal cost, Decimal units, Decimal totalAmount, Decimal withholding) {
            this.description = CFAR_Utils.customEscape(description);
            this.cost = cost;
            this.units = units;
            this.totalAmount = totalAmount;        
            this.withholding = withholding;    
        }

        public ContractInfo(CFAR_Budget_CPS_Payments_gne__c newestBcp, CFAR_Rate_Table_gne__c rTable) {
            boolean payWithholdings = newestBcp.Withhold_Indicator_gne__c.toLowerCase() == 'yes';
            Decimal units = 0;
            Decimal withholding = 0;
            Decimal invoiceAmount = CFAR_Utils.nullSafeGet(newestBcp.Invoice_Amount_gne__c);
            if (payWithholdings) {
                if (rTable.Withhold_Type_gne__c == 'Percent') {
                    if (rTable.Withhold_Amount_gne__c != null) {
                        units = CFAR_Utils.nullSafeGet(rTable.Unit_gne__c) * invoiceAmount / rTable.Withhold_Amount_gne__c;
                    }
                } else if (rTable.Withhold_Type_gne__c == 'Unit') {
                    if (rTable.Cost_gne__c != null && rTable.Cost_gne__c != 0) {
                        units = invoiceAmount / rTable.Cost_gne__c;
                    }
                }
                withholding = -1 * invoiceAmount;
            } else {
                if (rTable.Net_Unit_Cost_gne__c != null && rTable.Net_Unit_Cost_gne__c != 0) {
                    units = invoiceAmount / rTable.Net_Unit_Cost_gne__c;
                }
                units = Math.abs(units);
                if ('Percent' == rTable.Withhold_Type_gne__c) {
                    withholding = CFAR_Utils.nullSafeGet(rTable.Cost_gne__c) * units - invoiceAmount;
                } else if ('Unit' == rTable.Withhold_Type_gne__c) {
                    Decimal units_withhold = CFAR_Utils.nullSafeGet(rTable.Unit_gne__c) - CFAR_Utils.nullSafeGet(rTable.Withhold_Value_gne__c);
                    if (units_withhold != 0) {
                        withholding = CFAR_Utils.nullSafeGet(rTable.Withhold_Value_gne__c) * CFAR_Utils.nullSafeGet(rTable.Cost_gne__c)
                            * units / units_withhold;
                    }
                }
            }
            this.description = CFAR_Utils.customEscape(newestBcp.Payment_Explanation_Text_gne__c);
            this.cost = rTable.Cost_gne__c;
            this.units = Math.round(Math.abs(units));
            this.totalAmount = newestBcp.Invoice_Amount_gne__c;
            this.withholding = withholding.setScale(2);
        }

        public Integer compareTo(Object compareTo) {
            ContractInfo contractInfo = (ContractInfo)compareTo;
            return CFAR_Utils.compare(description, contractInfo.description);
        }    
    }
    
    public class ReportData {
        public BudgetGeneralInfo bi {get; set;}    
        public List<ContractSummary> contactSummarys {get; set;}
        public List<Invoice> invoices {get; set;}
        public List<ContractInfo> contracts {get; set;}
        
        public ReportData(BudgetGeneralInfo bi, List<ContractSummary> contactSummarys, List<Invoice> invoices, List<ContractInfo> contracts) {            
            this.bi = bi;
            this.contactSummarys = contactSummarys;
            this.invoices = invoices;
            this.contracts = contracts;        
        }
    }   
}