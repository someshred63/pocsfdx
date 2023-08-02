public class AGS_AcknowledgeStopSpending_Controller {
AGS_Case_Action_gne__c ca = new AGS_Case_Action_gne__c();
    String input;
    String caid;
    String caseid;
    String hasBeenSubmitted = 'false';
    Boolean def = true;
    String thirdOptn = 'I acknowledge';
    Boolean thirdselected = false;
    String hasnotBeenSubmitted='false';
    AGS_case_gne__c curr_case=new AGS_case_gne__c();
    String closeflag='false';
    String closemessage;
    
    public AGS_AcknowledgeStopSpending_Controller (ApexPages.StandardController controller) {
        
        caid=ApexPages.currentPage().getParameters().get('id');
        
        ca = [select Action_Status_internal_gne__c,AGS_Case_gne__c,Ack_Stop_Spending_Limit_High_gne__c 
                     from AGS_Case_Action_gne__c where id=:caid];
         curr_case=[Select Id,Case_Status_gne__c from AGS_case_gne__c where id=:ca.AGS_Case_gne__c];              
        if (ca.Ack_Stop_Spending_Limit_High_gne__c == true){
          hasBeenSubmitted = 'true';
          input = 'true';         
        } 
        else
        if (ca.Action_Status_internal_gne__c=='Closed') 
            { closemessage='The User has not responded to the action .The action is closed for response.';  
            closeflag= 'true';
            }   
        else
            hasnotBeenSubmitted='true';      
    }
    
    public Boolean getDef () {
        return def;
    }
    
    public void setDef () {
        this.def = true;
    }
    public String getInput () {                     
        return Input;
    }   
    public void setInput (String input) {
        this.input = input;
        
    }
    
    public String getHasBeenSubmitted () {
            
        return hasBeenSubmitted;
    }
    
    public pagereference submit () {
        AGS_Case_Action_gne__c ca = new AGS_Case_Action_gne__c(id=caId);
        
        if (input == 'true'){
            ca.Ack_Stop_Spending_Limit_High_gne__c = true;      
        }               
        update ca;
        
      PageReference agsCaseActionpage = ApexPages.currentPage();
      agsCaseActionpage.setRedirect(true);

        return agsCaseActionpage;
    
    }
    
 
    public String getThirdOptn () {
        
        return this.ThirdOptn;
    }

 public AGSSpendCCOCase_gne__c[] getExpenses() {
        caseid=ApexPages.currentPage().getParameters().get('AGS_Case_gne__c');
        return  [select a.AGS_Spend_Recipient_gne__c
                        from AGSSpendCCOCase_gne__c a where AGS_Case_gne__r.id =: caseid limit 1];  

   }

public string agsCaseId;

    public void setagsCaseId(string s){
        agsCaseId = s;
        System.debug('GID VALUE:'+agsCaseId);        
    }
    
    public string getagsCaseId(){
         return agsCaseId;   
    }

    
    public void displayHelp () {
        
        thirdselected = true;
        
    }
    
    public Boolean getThirdselected () {
        
        return this.Thirdselected;
    }   
    public String gethasnotBeenSubmitted  ()
    {
     return this.hasnotBeenSubmitted;
    }    
    public String getcloseflag  ()
    {
     return this.closeflag;
    }
    public String getclosemessage  ()
    {
     return this.closemessage;
    }         
}