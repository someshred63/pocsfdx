public class gFRS_Ltng_Copay_PrintAllRequest {
    public gFRS_Ltng_Application__c fundReq { get; set; }
    public gFRS_Ltng_CAF_Application__c CAFReq { get; set; }
    public gFRS_Ltng_Program__c[] programs { get; set; }
    public gFRS_Ltng_Third_Party__c[] thirdPartyRecords { get; set; }
    public gFRS_Ltng_Request_Budget__c[] budgets { get; set; }
    public gFRS_Ltng_Demographic_Data__c[] demographics { get; set; }
    public String recordTypeName { get; set; }  
   // public List<gFRS_Program_Design_and_Implementation__c> lprogramDesignImplementationRecords { get; set; }

    public Boolean isInternalRequest {
        get {
            return gFRS_Util.isInternalRequest(this.fundReq.Record_Type_Name__c);
        }
    }
    public gFRS_Ltng_Copay_PrintAllRequest(ApexPages.StandardController std) {
   
        this.CAFReq = (gFRS_Ltng_CAF_Application__c) std.getRecord();
        try {
           
            
            this.CAFReq     =   
                            [select (select id,name,Disease_Fund_Name__c,Fund_Type__c,Requested_Donation_Amount__c,Time_Frame_for_Requested_Donation__c from gFRS_CAF_Disease_State__r),id,Send_Payment_Attention_To__c,Payment_Contact_Email_Address__c,Confirm_Payment_Contact_Email_Address__c,DS_Other_Please_specify__c,gFRS_Organization__r.Country__c,name,gFRS_Organization__r.Org_Fiscal_Year__c,gFRS_Organization__r.Act_YTD_Annual_Revenue__c,gFRS_Organization__r.Proj_Ann_Rev_CrntYear__c,gFRS_Organization__r.Proj_Annual_Revenue_Next_Fiscal_Year__c,gFRS_Organization__r.Actual_Revenue_for_Prior_Fiscal_Y__c,Donation_Requested_for_Quarter_CreatedDt__c,gFRS_Organization__r.Tax_Id__c,gFRS_Organization__r.Organization_Name__c,gFRS_Organization__r.Tax_Status__c,gFRS_Organization__r.Street__c,gFRS_Organization__r.City__c,gFRS_Organization__r.State__c,gFRS_Organization__r.Zip_Code__c,gFRS_Organization__r.Operational_Budget__c,gFRS_Organization__r.Website_Address__c,gFRS_Organization__r.Number_of_Employees__c,gFRS_Organization__r.Mission_Statement__c,gFRS_Organization__r.Type__c,gFRS_Organization__r.Parent_Org_Name__c,gFRS_Organization__r.Parent_Organization_Tax_ID__c,gFRS_Organization__r.gFRS_Organization_Purchase__c,gFRS_Organization__r.gFRS_Organization_Prescribe__c,gFRS_Organization__r.gFRS_Organization_Develop__c,gFRS_Organization__r.gFRS_Organization_Owned__c,gFRS_Organization__r.Org_Medicare_guideline_development__c,gFRS_Organization__r.Commitments_or_provide_a_web_link__c,gFRS_Organization__r.gFRS_Do_you_have_W_8BEN_Status__c,gFRS_Organization__r.Accreditations_received__c,gFRS_Organization__r.If_other_please_specify__c,gFRS_Organization__r.Org_Diversity1__c,gFRS_Organization__r.Org_Diversity2__c,gFRS_Organization__r.Org_Diversity3__c,gFRS_Organization__r.Org_Diversity4__c,gFRS_Organization__r.Org_Diversity5__c,gFRS_Organization__r.Org_Diversity6__c,gFRS_Organization__r.Org_Diversity7__c,gFRS_Organization__r.OrgRadio15__c,gFRS_Organization__r.OrgRadio17__c,gFRS_Organization__r.OrgRadio18__c,gFRS_Organization__r.OrgRadio19__c,gFRS_Organization__r.OrgRadio20__c,gFRS_Organization__r.OrgRadio21__c,gFRS_Organization__r.OrgRadio22__c,gFRS_Organization__r.OrgRadio23__c,gFRS_Organization__r.OrgRadio24__c,gFRS_Organization__r.OrgRadio25__c,gFRS_Organization__r.OrgRadio26__c,gFRS_Organization__r.OrgRadio27__c,gFRS_Organization__r.OrgRadio28__c,gFRS_Organization__r.OrgRadio41__c,gFRS_Organization__r.OrgRadio43__c,gFRS_Organization__r.OrgRadio44__c,gFRS_Organization__r.OrgRadio45__c,gFRS_Organization__r.OrgRadio29__c,gFRS_Organization__r.OrgRadio30__c,gFRS_Organization__r.OrgRadio31__c,gFRS_Organization__r.OrgRadio32__c,gFRS_Organization__r.OrgRadio33__c,gFRS_Organization__r.OrgRadio34__c,gFRS_Organization__r.OrgRadio35__c,gFRS_Organization__r.OrgRadio36__c,gFRS_Organization__r.OrgRadio37__c from gFRS_Ltng_CAF_Application__c where id=:THIS.CAFReq.Id];
            
        } catch (Exception err) {
            System.debug('unable to load funding request:' + this.fundReq.Id);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to load funding request'));
            return;
        }
    }
}