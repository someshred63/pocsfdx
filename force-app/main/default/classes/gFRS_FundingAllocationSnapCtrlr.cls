public without sharing class gFRS_FundingAllocationSnapCtrlr {
    
    public gFRS_Copay_Funding_Allocation__c fundalloc {get; set;}
    public gFRS_Copay_Funding_Request__c fundreq {get; set;}
    
    public gFRS_FundingAllocationSnapCtrlr(apexPages.StandardController std){
        
        this.fundalloc = (gFRS_Copay_Funding_Allocation__c)std.getRecord();
        try{
            this.fundalloc = [ SELECT Id, Name, Grant_Request__r.Name, Grant_Request__r.Total_Approved_Amount__c, Grant_Request__r.Donation_Requested_for_YY_quarter1__c, Grant_Request__r.Estimated_Donation_Limit__c, Grant_Request__r.YTD_Total_Approved_Donations__c, Grant_Request__r.Estimated_Remaining_Donation_Limit__c, Grant_Request__r.Requested_Amount1__c, Grant_Request__r.Total_Approved_Amt__c, Grant_Request__r.Total_Payment_Amount__c, Grant_Request__r.Total_Paid_Amount__c, Grant_Request__r.Decision_Date__c, Grant_Request__r.Decision_Date_Temp__c, Grant_Request__r.Estimated_Current_Revenue_Percent__c, Grant_Request__r.Estimated_Current_Revenue_Exceeded_33__c, Grant_Request__r.Revenue_Exceeded_33_Temp__c, Grant_Request__r.Payment_Type__c, Grant_Request__r.Payment_Type_Temp__c, Grant_Request__r.Payment_Automation__c, Grant_Request__r.Payment_Automation_Temp__c, Grant_Request__c, RecordType.name, Organization_Name__c, Fiscal_Year__c, GL_Account_ref__c, Approved_Amount__c,
                                      Refundable_Amount__c, Payment_Amount__c, Funding_Total__c, Paid_Amount__c, Pct_Covered__c, Baseline_Date__c, Grant_Request__r.Locationcopay__r.Vendor_ID__c, Grant_Request__r.Locationcopay__r.Payment_Method__c, Grant_Request__r.Locationcopay__r.Payment_Delivery_Translation__c, Grant_Request__r.Locationcopay__r.Partner_Bank_Type__c, Grant_Request__r.Locationcopay__r.Vendor_Name__c, Grant_Request__r.Locationcopay__r.Vendor_Name_1__c, Grant_Request__r.Locationcopay__r.Vendor_Name_2__c, Grant_Request__r.Locationcopay__r.Vendor_Name_3__c, Grant_Request__r.Locationcopay__r.Vendor_Name_4__c, Grant_Request__r.Locationcopay__r.Address_Line_1__c, Grant_Request__r.Locationcopay__r.Street_4__c, Grant_Request__r.Locationcopay__r.Street__c, Grant_Request__r.Locationcopay__r.City_1__c, Grant_Request__r.Locationcopay__r.State_1__c, Grant_Request__r.Locationcopay__r.Zip_Code_1__c, Grant_Request__r.Locationcopay__r.Country_1__c, Grant_Request__r.Locationcopay__r.PO_Box__c, Grant_Request__r.Locationcopay__r.PO_Box_Postal_Code__c, Grant_Request__r.Locationcopay__r.Posting_block_for_all_company_codes__c, Grant_Request__r.Locationcopay__r.Payment_Block_Indicator__c, Grant_Request__r.Locationcopay__r.Payment_Block_Description__c, Grant_Request__r.Locationcopay__r.Deletion_Flag_for_all_company_codes__c,
                                      (SELECT Id, Accountable_Employee__r.name, Cost_Center__c, Cost_Center_Description__c, WBS__c, WBS_Description__c,
                                              Amount__c, Percent__c FROM gFRS_Copay_Funding_Allocation_Line_Items__r)
                            FROM gFRS_Copay_Funding_Allocation__c
                            WHERE Id = :this.fundalloc.Id
                            LIMIT 1];
            
            this.fundreq = [SELECT Id, Name, Organization__r.Name, Organization_Name__c, Total_Approved_Amt__c, (SELECT Id, Name, Disease_State_Fund_Name__c, Requested_Donation_Amount__c, Approved_Amount__c,
                                        Payment_Amount__c, PmtAmtTemp__c FROM gFRS_CoPay_Disease_State__r)
                            FROM gFRS_Copay_Funding_Request__c WHERE Id = :this.fundalloc.Grant_Request__c LIMIT 1];
                          
           }
           catch (Exception err) {
                System.debug( 'unable to load funding allocation info:' + err.getMessage() );
                ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Error occurred while loading the funding allocation' ));
                return;
            }
        
    }
    
}