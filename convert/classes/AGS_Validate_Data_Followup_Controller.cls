public class AGS_Validate_Data_Followup_Controller {
    AGS_Case_Action_gne__c ca = new AGS_Case_Action_gne__c();
    String input;
    String caid;
    AGS_case_gne__c curr_case=new AGS_case_gne__c();
    String hasBeenSubmitted = 'false';
    String hasnotBeenSubmitted = 'false';
    Boolean def = true;
    String thirdOptn = 'I confirm this information is incorrect, and I am unable to correct the data.';
    Boolean thirdselected = false;
    String closemessage;
    String closeflag='false';
    
    
    public AGS_Validate_Data_Followup_Controller (ApexPages.StandardController controller) {
        
        caid=ApexPages.currentPage().getParameters().get('id');
        
        ca = [select Action_Status_internal_gne__c,AGS_Case_gne__c,AGS_Validate_Data_FollowUp_box_gne__c 
                     from AGS_Case_Action_gne__c where id=:caid];
         curr_case=[Select Id,Case_Status_gne__c from AGS_case_gne__c where id=:ca.AGS_Case_gne__c];             
        if (ca.AGS_Validate_Data_FollowUp_box_gne__c == true){
          hasBeenSubmitted = 'true';
          input = 'true';         
        } 
        else
        
        if (ca.Action_Status_internal_gne__c=='Closed') 
            { closemessage='The User has not responded to the action .The action is closed for response.';  
             closeflag='true';
            }  
        else
          hasnotBeenSubmitted ='true';
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
            ca.AGS_Validate_Data_FollowUp_box_gne__c = true;        
        }               
        update ca;
        
      PageReference agsCaseActionpage = ApexPages.currentPage();
      agsCaseActionpage.setRedirect(true);

        return agsCaseActionpage;
    
    }
    
 
    public String getThirdOptn () {
        
        return this.ThirdOptn;
    }
    
    public void displayHelp () {
        
        thirdselected = true;
        
    }
    
    public Boolean getThirdselected () {
        
        return this.Thirdselected;
    }   
    public String getcloseflag () {
        
        return this.closeflag;
    }  
        public String getclosemessage () {
        
        return this.closemessage;         
      }
       public String gethasnotBeenSubmitted ()
       {
       return this.hasnotBeenSubmitted;
       }
}