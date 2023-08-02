public class SRW_SetSecurityQAController  {

    public String securityQuestion {get; set;}
    public String securityAnswer {get; set;}
    public SRW_Security_Community_Data__c securityData;
    public List<SelectOption> securityQuestionsForPickList;
    
    public SRW_SetSecurityQAController (){
        securityData = new SRW_Security_Community_Data__c();
        securityQuestionsForPickList = new List<SelectOption>();
    }
    
    public List<SelectOption> getSecurityQuestionsForPickList(){
        Schema.DescribeFieldResult fieldResult = SRW_Security_Community_Data__c.SecurityQuestion__c.getDescribe();
        List<Schema.PicklistEntry> pickListEntry = fieldResult.getPicklistValues();
        List<SelectOption> options = new List<SelectOption>();
        for (Schema.PicklistEntry ple : pickListEntry) {
            options.add(new SelectOption(ple.getLabel(), ple.getValue()));
        }
        return options;
    }

    public PageReference logOut() {
        PageReference pr = new PageReference('/secur/logout.jsp');
        return pr.setRedirect(true);
    }
    
    public PageReference assignSecurityQuestionForUser(){
    	SRW_UserOperationUtils currentUser = new SRW_UserOperationUtils();
    	return currentUser.assignSecurityQAForCurrentUser(securityQuestion, securityAnswer, true);
    }
}