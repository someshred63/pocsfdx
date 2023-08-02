public without sharing class gFRS_Ltng_FundingAllocationSnapCtrlr {
    
    public gFRS_CAF_Funding_Allocation__c fundalloc {get; set;}
    public gFRS_Ltng_CAF_Application__c fundreq {get; set;}
    
    public gFRS_Ltng_FundingAllocationSnapCtrlr(apexPages.StandardController std){
        
        this.fundalloc = (gFRS_CAF_Funding_Allocation__c)std.getRecord();
        try{
            this.fundalloc = [ SELECT Id, Name, gFRS_CAF_Application__r.Name,gFRS_CAF_Application__r.Donation_Requested_for_Quarter__c, gFRS_CAF_Application__r.Estimated_Donation_Limit__c, gFRS_CAF_Application__r.YTD_Total_Approved_Donations__c, gFRS_CAF_Application__r.Estimated_Remaining_Donation_Limit__c, gFRS_CAF_Application__r.Total_Requested_Amount__c, gFRS_CAF_Application__r.Total_Apprv_Amount__c, gFRS_CAF_Application__r.Total_Payment_Amount_Rollup__c, gFRS_CAF_Application__r.Total_Paid_Amount_Rollup__c, gFRS_CAF_Application__r.Decision_Date__c,gFRS_CAF_Application__r.Estimated_Current_Revenue__c,gFRS_CAF_Application__r.Acknowledge_Current_Revenue_33__c, gFRS_CAF_Application__r.Manual_Automated_Payment__c,gFRS_CAF_Application__c, RecordType.name, Organization_Name__c, Fiscal_Year__c, GL_Account__c, Approved_Amount__c, Payment_Amount__c, Funding_Total__c, Paid_Amount__c, Percent_Covered__c, Baseline_Date__c, gFRS_CAF_Application__r.Vendor_Detail__r.Vendor_ID__c, gFRS_CAF_Application__r.Vendor_Detail__r.Payment_Method__c, gFRS_CAF_Application__r.Vendor_Detail__r.Partner_Bank_Type__c, gFRS_CAF_Application__r.Vendor_Detail__r.Vendor_Name__c, gFRS_CAF_Application__r.Vendor_Detail__r.Vendor_Name_1__c, gFRS_CAF_Application__r.Vendor_Detail__r.Vendor_Name_2__c, gFRS_CAF_Application__r.Vendor_Detail__r.Vendor_Name_3__c, gFRS_CAF_Application__r.Vendor_Detail__r.Vendor_Name_4__c, gFRS_CAF_Application__r.Vendor_Detail__r.Address_1__c, gFRS_CAF_Application__r.Vendor_Detail__r.Street_4__c, gFRS_CAF_Application__r.Vendor_Detail__r.City1__c, gFRS_CAF_Application__r.Vendor_Detail__r.State_1__c, gFRS_CAF_Application__r.Vendor_Detail__r.Zip_Code_1__c, gFRS_CAF_Application__r.Vendor_Detail__r.Country__c, gFRS_CAF_Application__r.Vendor_Detail__r.PO_Box__c, gFRS_CAF_Application__r.Vendor_Detail__r.PO_Box_Postal_Code__c, gFRS_CAF_Application__r.Vendor_Detail__r.Payment_Block_Indicator__c, gFRS_CAF_Application__r.Vendor_Detail__r.Payment_Block_Description__c, gFRS_CAF_Application__r.Vendor_Detail__r.Deletion_Flag_for_all_company_codes__c,
                                      (SELECT Id, Cost_Center__c, Cost_Center_Description__c, WBS_Code__c, WBS_Description__c,
                                              Amount__c, Percent__c FROM gFRS_CAF_Allocation_Line_Items__r)
                            FROM gFRS_CAF_Funding_Allocation__c
                            WHERE Id= :this.fundalloc.Id LIMIT 1];
            
            this.fundreq = [SELECT Id, Name, gfrs_Organization__r.Name, Total_Approved_Amount__c, (SELECT Id, Name, Disease_Fund_Name__c, Requested_Donation_Amount__c, Approved__c,Payment_Amount__c FROM gFRS_CAF_Disease_State__r)
                            FROM gFRS_Ltng_CAF_Application__c WHERE Id = :this.fundalloc.gFRS_CAF_Application__c LIMIT 1];
                          
           }
           catch (Exception err) {
                System.debug( 'unable to load funding allocation info:' + err.getMessage() );
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Error occurred while loading the funding allocation' ));
                return;
            }
        
    }
    
}