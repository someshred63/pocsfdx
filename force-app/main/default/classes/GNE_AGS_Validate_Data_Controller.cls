public class GNE_AGS_Validate_Data_Controller {
    
    AGS_Case_Action_gne__c ca = new AGS_Case_Action_gne__c();
    AGS_case_gne__c curr_case=new AGS_case_gne__c();
    String Errmsg;
    String input;
    String caid;
    String hasBeenSubmitted = 'false';
    Boolean def = true;
    String thirdOptn = 'I confirm this information is incorrect, and I am unable to correct the data.';
    Boolean thirdselected = false;
    
    
    public GNE_AGS_Validate_Data_Controller (ApexPages.StandardController controller) {
        
        caid=ApexPages.currentPage().getParameters().get('id');
        Errmsg='';
        
        ca = [select Action_Status_internal_gne__c,AGS_Case_gne__c,AGS_Validate_Data_1_box_gne__c,
                     AGS_Validate_Data_2_box_gne__c,
                     AGS_Validate_Data_3_box_gne__c 
                     from AGS_Case_Action_gne__c where id=:caid];
        curr_case=[Select Id,Case_Status_gne__c from AGS_case_gne__c where id=:ca.AGS_Case_gne__c]; 
                   
        if (ca.AGS_Validate_Data_1_box_gne__c == true || ca.AGS_Validate_Data_2_box_gne__c == true || ca.AGS_Validate_Data_3_box_gne__c == true)
        {
          hasBeenSubmitted = 'true';
          
          if (ca.AGS_Validate_Data_1_box_gne__c == true)
          input = 'I confirm that this information is correct.';
          else if (ca.AGS_Validate_Data_2_box_gne__c == true)
          input = 'I confirm that this information is incorrect and I have corrected it.';
          else if(ca.AGS_Validate_Data_3_box_gne__c == true)
          input = 'I confirm that this information is incorrect and I am unable to correct it.';
        }
        else
        if (ca.Action_Status_internal_gne__c=='Closed') 
       // if (curr_case.Case_Status_gne__c=='Closed') 
            { input='The User has NOT RESPONDED to the action.The action is closed for response.';  
            hasBeenSubmitted = 'true';
            }         
        
        
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
    
    public PageReference submit () {
    AGS_Case_Action_gne__c caseaction=[select AGS_Validate_Data_1_box_gne__c,
                     AGS_Validate_Data_2_box_gne__c,
                     AGS_Validate_Data_3_box_gne__c 
                     from AGS_Case_Action_gne__c where id=:caid];
        if (caseaction.AGS_Validate_Data_1_box_gne__c==true||
        caseaction.AGS_Validate_Data_2_box_gne__c==true ||
        caseaction.AGS_Validate_Data_3_box_gne__c==true        
        )     
        {Errmsg='The Case Action response was already submitted,Please Navigate to the Case';
        //ApexPages.Message ex= new ApexPages.Message(ApexPages.Severity.FATAL,Errmsg);
        GeneralException ex=new GeneralException(Errmsg);
        ApexPages.addMessages(ex);
        return null;
       }
        else
        {
                
        AGS_Case_Action_gne__c ca = new AGS_Case_Action_gne__c(id=caId);
        
        if (input == '1stOptn'){
        ca.AGS_Validate_Data_1_box_gne__c = true;
        ca.AGS_Validate_Data_2_box_gne__c = false;
        ca.AGS_Validate_Data_3_box_gne__c = false;
        }
        else if (input == '2ndOptn'){
        ca.AGS_Validate_Data_2_box_gne__c = true;
        ca.AGS_Validate_Data_1_box_gne__c = false;
        ca.AGS_Validate_Data_3_box_gne__c = false;
        }
        else if (input == '3rdOptn'){
        ca.AGS_Validate_Data_3_box_gne__c = true;
        ca.AGS_Validate_Data_1_box_gne__c = false;
        ca.AGS_Validate_Data_2_box_gne__c = false;
        }
                
        update ca;
        }
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
    
    public List<SelectOption> getItems() {
        
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('1stOptn','I confirm that this information is correct.'));
        options.add(new SelectOption('2ndOptn','I confirm that this information is incorrect and I have corrected it.'));
        options.add(new SelectOption('3rdOptn','I confirm that this information is incorrect and I am unable to correct it.<dd>For technical issues, please contact the on-campus CIT service desk at 650-225-3700 (ext. 53700), or the Field Service Desk at 1-877-225-8111.</dd><dd>For compliance requirement questions, please contact <u><a href="MailTo:hcpspend-d@gene.com">hcpspend-d@gene.com</u></a></p>'));

        for (SelectOption opt : options) {
            opt.setEscapeItem(false);
        }

        return options;
    }
    
    public string getErrmsg()
    {return Errmsg;}
    
    
    public class GeneralException extends Exception
    {}
    
    
}