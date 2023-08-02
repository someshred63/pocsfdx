@RestResource(urlMapping='/iPhoneSendFeedback/*')
global with sharing class iPhone_Send_Feedback_gne {

@HttpPost
  global static iPhone_Commons_gne.RestResponse processRequest(String appName, Boolean facingProblems, String problemDesc, String emotionalState,
    Integer usefulness, Integer efficiency, Integer easeOfUse, String proposedChange, String iPhoneRequestId) {            
    return iPhone_Commons_gne.executeAlterData(
      new ReportFailedRequestExecutor(), 
      new SendFeedbackArgs(appName, facingProblems, problemDesc, emotionalState, usefulness, efficiency, easeOfUse, proposedChange, iPhoneRequestId)
    );
  }
  
  class SendFeedbackArgs implements iPhone_Commons_gne.BaseArgs {
    final String appName;       
    final Boolean facingProblems;
    final String problemDesc;
    final String emotionalState;
    final Integer usefulness;
    final Integer efficiency;
    final Integer easeOfUse;
    final String proposedChange;
    final String iPhoneRequestId;
    
    public SendFeedbackArgs(String appName, Boolean facingProblems, String problemDesc, String emotionalState,
      Integer usefulness, Integer efficiency, Integer easeOfUse, String proposedChange, String iPhoneRequestId) {
      this.appName = appName;
      this.facingProblems = facingProblems;
      this.problemDesc = problemDesc;
      this.emotionalState = emotionalState;
      this.usefulness = usefulness;
      this.efficiency = efficiency;
      this.easeOfUse = easeOfUse;
      this.proposedChange = proposedChange;
      this.iPhoneRequestId = iPhoneRequestId;
    }

    public String getIPhoneRequestId(){
        return this.iPhoneRequestId;
    }
  }
  
  class ReportFailedRequestExecutor implements iPhone_Commons_gne.Runnable {
  
  public Object run(Object args) {
      SendFeedbackArgs rfrArgs = (SendFeedbackArgs)args;
      
      return this.saveData(rfrArgs);
    }
    
    private String saveData(SendFeedbackArgs feedbackArgs) {
      GNE_iPhone_Feedback__c newObj = new GNE_iPhone_Feedback__c();
      
      newObj.Application_Name_gne__c = feedbackArgs.appName;
      newObj.Ease_Of_Use_gne__c = feedbackArgs.easeOfUse;
      newObj.Efficiency_gne__c = feedbackArgs.efficiency;
      newObj.Emotional_State_gne__c = feedbackArgs.emotionalState;
      newObj.Facing_Problems_gne__c = feedbackArgs.facingProblems;
      newObj.Problem_Description_gne__c = feedbackArgs.problemDesc;
      newObj.Proposed_Change_gne__c = feedbackArgs.proposedChange;
      newObj.Usefulness_gne__c = feedbackArgs.usefulness;
      newObj.iPhone_Request_Id__c = feedbackArgs.iPhoneRequestId;
      
      insert newObj;
      return newObj.id;
    }
  
  }

}