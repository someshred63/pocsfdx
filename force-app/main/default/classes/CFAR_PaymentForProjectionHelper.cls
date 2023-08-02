public with sharing class CFAR_PaymentForProjectionHelper {
    public static final String cancelledStatus = Label.CFAR_GSTARS_PAYMENT_SCHEDULE_CANCELLED_STATUS;
	private Set<String> trialIds;
	private List<CFAR_Budget_CPS_Payments_gne__c> completedList;
	public Map<Id, Map<Integer, Decimal>> trialPaidIds {get; set;}
    public Map<Id, Map<integer, Map<integer, decimal>>> trialRefundedIds {get; set;}

	public CFAR_PaymentForProjectionHelper(Set<String> trialIds) {
		this.trialIds = trialIds;
		trialPaidIds = new map<Id, map<Integer, Decimal>>();
		trialRefundedIds = new map<Id, map<integer, map<integer, decimal>>>();
		completedList = [select Id, frm_sfdc_Completed_gne__c,
            Invoice_Amount_gne__c, Paid_On_gne__c, Payment_Status_ref_gne__c, Payment_Status_ref_gne__r.Name,
            Frm_Trial_Id_gne__c, Invoice_Submitted_Date_gne__c, Planned_Amount_gne__c
            from CFAR_Budget_CPS_Payments_gne__c where Frm_Trial_Id_gne__c in :trialIds
            and Payment_Status_ref_gne__r.Name != :cancelledStatus];
        computePaymentsForPaidAndRefunded();
	}

	public void computePaymentsForPaidAndRefunded() {
		for (CFAR_Budget_CPS_Payments_gne__c c : completedList) {

		    Boolean notInStatus =  c.Payment_Status_ref_gne__r.Name != Label.CFAR_GSTARS_PAYMENT_SCHEDULE_PLANNED_STATUS
		            && c.Payment_Status_ref_gne__r.Name != Label.CFAR_GSTARS_PAYMENT_SCHEDULE_UNPAID_STATUS;

		    if (notInStatus && c.Invoice_Submitted_Date_gne__c != null && c.Invoice_Amount_gne__c != null) {
		        Integer year = c.Invoice_Submitted_Date_gne__c.year();
		        Decimal currentAmount = c.Invoice_Amount_gne__c;
		        if (trialPaidIds.containsKey(c.Frm_Trial_Id_gne__c)) {
		            Map<Integer, Decimal> year2Amount = trialPaidIds.get(c.Frm_Trial_Id_gne__c);
		            if (year2Amount.containsKey(year)) {
		                currentAmount += year2Amount.get(year);
		            }
		            year2Amount.put(year, currentAmount);
		        } else {
		            trialPaidIds.put(c.Frm_Trial_Id_gne__c, new map<Integer, Decimal> {year => currentAmount});
		        }
		    }
		}
	}
}