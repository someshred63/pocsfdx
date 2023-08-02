public with sharing class CFAR_FinanceReport_DataModel {

    public class ReportDataWrapper {
        public List<SingleRowWrapper> allRows {get; set;}
    }
    
    public class SingleRowWrapper  implements Comparable{
        public String productName {get; set;} 
        public String therapeuticArea {get; set;} 
        public String primaryGeneralIndication {get; set;} 
        public String theme {get;set;}
        public String investigatorSponsorName {get; set;}
        public String role {get; set;}
        public String institutionName {get; set;}
        public String trialStatus {get; set;}
        public String trialType {get;set;}
        public String gneSupport {get;set;}
        public String WBSCode {get; set;}
        public String protocolNo {get; set;}
        public String CTMSNo {get; set;}
        public String gStarsTrialNo {get; set;}
        public String poNumber {get;set;}
        public String contractFullyExecutedDate {get; set;}
        public String contractExpiryDate {get; set;}
        public Decimal currentContractAmount {get; set;}
        public Decimal totalPaid {get;set;}
        public Decimal balanceAmount {get;set;}
        public Decimal balanceLeftToProject {get;set;}
        public String msl {get;set;}
        public String specificIndication {get;set;}
        public String protocolTitle {get;set;}
        public String gneAgents {get;set;}
        public String otherAgents {get;set;}
        public String regimen {get;set;}
        public Decimal sampleSize {get;set;}
        public Integer totalEnrolled {get; set;}
        public String proposalApprovedPlanned {get;set;}
        public String proposalApprovedActual {get;set;}
        public String draftProtocolApprovedPlanned {get;set;}
        public String draftProtocolApprovedActual {get;set;}
        public String srrtProtocolApprovedPlanned {get;set;}
        public String srrtProtocolApprovedActual {get;set;}
        public String tracProtocolApprovedPlanned {get;set;}
        public String tracProtocolApprovedActual {get;set;}
        public String activationPlanned {get;set;}
        public String activationActual {get;set;}
        public String fpiPlanned {get;set;}
        public String fpiActual {get;set;}
        public String lpiPlanned {get;set;}
        public String lpiActual {get;set;}
        public String lpoPlanned {get;set;}
        public String lpoActual {get;set;}
        public String studyClosurePlanned {get; set;}
        public String studyClosureActual {get;set;}
        public String lastComment {get;set;}
        public String interventional {get;set;}
        public Decimal q1 {get; set;}
        public Decimal q2 {get; set;}
        public Decimal q3 {get; set;}
        public Decimal q4 {get; set;} 
        public Decimal year1FwdProjectionsTotal {get; set;}
        public Decimal year2FwdProjectionsTotal {get; set;}
        public Decimal year3FwdProjectionsTotal {get; set;}
        public String csm {get;set;}
        public String csa {get;set;}
        public String css {get;set;}
        public DateTime trialCreatedDate {get; set;}
        public String imlApprovedPlanned {get;set;}
        public String imlApprovedActual {get;set;}
        public String costCenter {get;set;}
        
        public SingleRowWrapper() {
            q1 = 0;
            q2 = 0;
            q3 = 0;
            q4 = 0;
            year1FwdProjectionsTotal = 0;
            year2FwdProjectionsTotal = 0;
            year3FwdProjectionsTotal = 0;
            totalEnrolled = 0;
            csa = '';
        }

        public Integer compareTo(Object compareTo) {
            SingleRowWrapper compareToSRW = (SingleRowWrapper)compareTo;
            Integer ret = CFAR_Utils.compare(this.therapeuticArea, compareToSRW.therapeuticArea, true);
            if (ret != 0) {
                return ret;
            }
            ret = CFAR_Utils.compare(this.productName, compareToSRW.productName, true);
            if (ret != 0) {
                return ret;
            }
            ret = CFAR_Utils.compare(this.WBSCode, compareToSRW.WBSCode, true);
            if (ret != 0) {
                return ret;
            }
            return CFAR_Utils.compare(this.investigatorSponsorName, compareToSRW.investigatorSponsorName, true);
        }
    }

    public class CFAR_Trial{
        public CFAR_Trial_gne__c trial {get; set;}
        public List<CFAR_Budget_Contract_gne__c> contracts {get;set;}
        public Map<String, String> planned2Date {get;set;}
        public Map<String, String> actual2Date {get;set;}
        public Map <String, String> role2TeamMember {get;set;}
        
        public CFAR_Trial(CFAR_Trial_gne__c trial){
            this.trial = trial;
            contracts = new List<CFAR_Budget_Contract_gne__c> ();
            fillActivities();
            role2TeamMember = fillRoleMap();
        } 
        
        private void fillActivities(){
            planned2Date = new Map<String, String>();
            actual2Date = new Map<String, String>();
            for(CFAR_Milestone_Activity_gne__c ma : trial.CFAR_Milestone_Activities__r){
                if(ma.Planned_Date_gne__c != null){
                    planned2Date.put(ma.Name, ma.Planned_Date_gne__c.format());
                }
                if(ma.Actual_Date_gne__c != null){
                    actual2Date.put(ma.Name, ma.Actual_Date_gne__c.format());
                }               
            }
        }
        
        private Map <String, String> fillRoleMap(){
            Map <String, String> role2TeamMember = new Map <String, String> ();
            if(trial.CFAR_Team_Members__r.isEmpty()){
                return role2TeamMember;
            }
            for(CFAR_Team_Member_gne__c tm : trial.CFAR_Team_Members__r){
                role2TeamMember.put(tm.frm_function_role_gne__c, tm.frm_Name_gne__c);
            }
            return role2TeamMember;
        }
    }
}