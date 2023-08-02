public class AGS_Ack_Stop_Spending_Limit_Medium_Ctrlr {

	AGS_Case_Action_gne__c ca = new AGS_Case_Action_gne__c();
	String input;
	String caid;
	String hasBeenSubmitted = 'false';
	Boolean def = true;
	String thirdOptn = 'I confirm this information is incorrect, and I am unable to correct the data.';
	Boolean thirdselected = false;
	
	
	public AGS_Ack_Stop_Spending_Limit_Medium_Ctrlr (ApexPages.StandardController controller) {
		
		caid=ApexPages.currentPage().getParameters().get('id');
		
		ca = [select Ack_Stop_Spending_Limit_Medium__c from AGS_Case_Action_gne__c where id=:caid];
					 
		if (ca.Ack_Stop_Spending_Limit_Medium__c == true){
		  	hasBeenSubmitted = 'true';
		  	input = 'true';
		}

        caseNameToThresholdMinimumMap = new Map<String, Integer>();

        for(AGS_CCO_Case_Reason__c caseReason :[SELECT Name, Threshold_Minimum__c FROM AGS_CCO_Case_Reason__c]) {
            caseNameToThresholdMinimumMap.put(caseReason.Name, Integer.valueOf(caseReason.Threshold_Minimum__c));
        }
	}
	
	public Boolean getDef() {
	 	return def;
	}
	
	public void setDef() {
		this.def = true;
	}
	public String getInput() {
		return Input;
	}	
	public void setInput (String input) {
		this.input = input;
	}
	
	public String getHasBeenSubmitted() {
		return hasBeenSubmitted;
	}
	
	public pagereference submit() {
		AGS_Case_Action_gne__c ca = new AGS_Case_Action_gne__c(id=caId);
		
		if (input == 'true') {
			ca.Ack_Stop_Spending_Limit_Medium__c = true;		
		}				
		update ca;
		
      	PageReference agsCaseActionpage = ApexPages.currentPage();
      	agsCaseActionpage.setRedirect(true);

		return agsCaseActionpage;
	}
	
 
	public String getThirdOptn() {
		return this.ThirdOptn;
	}
	
	public void displayHelp() {
		thirdselected = true;
	}
	
	public Boolean getThirdselected() {
		return this.Thirdselected;
	}

    public Map<String, Integer> caseNameToThresholdMinimumMap {get;set;}
}