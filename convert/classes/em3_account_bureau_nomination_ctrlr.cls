public class em3_account_bureau_nomination_ctrlr {

//set of id's for which this account is already a member
    private list<ID> excluded_bureaus = new list<ID>();
    private List<ID> bureau_selections = new List<ID>();
    private List<SelectOption> bureauOptions;
    public Account acct;   
    public string a_bureau{set; get;}
    //public string a_bureau{get;set;}  
    public boolean yearSelected{set; get;}  
    public string year{set; get;}       
    private List<SelectOption> yearOptions;     
    private List<Survey_gne__c> surveys = new List<Survey_gne__c>();
    private set<ID> memberOf = new set<ID>();                   


    public PageReference verification()
    {
    	
    	if(acct.Classification_gne__c == null)
    	{
    		PageReference acctPage = new ApexPages.StandardController(acct).view();
      		acctPage.setRedirect(true);
      		 return acctPage; 
    	}
    	return null;	
    }
    
    public em3_account_bureau_nomination_ctrlr(ApexPages.StandardController controller){
        
        this.acct = (Account)controller.getRecord();
        this.yearSelected = false;       
        getMembership();                                               
    }
        
    public void getMembership(){
        List<Speaker_Bureau_Membership_gne__c> memberships = [select Speaker_Bureau_ID_gne__c from Speaker_Bureau_Membership_gne__c 
        where Bureau_Member_gne__c = :ApexPages.currentPage().getParameters().get('id')];
        if(!memberships.isEmpty()){
            for(Speaker_Bureau_Membership_gne__c bm : memberships){
                this.memberOf.add(bm.Speaker_Bureau_ID_gne__c);
            }
        }
        
    }   

    public void genericPostbackFunction(){}
    
    public PageReference next(){
        if(this.a_bureau == null || this.a_bureau == ''){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Select a Bureau'));
            return null;
        }else{          
            Speaker_Bureau_gne__c selected_bureau = [select id, Speaker_Category_gne__c from Speaker_Bureau_gne__c where id = :this.a_bureau];
            
            //Claudia M: 9/28: Removing this.surveys check. Create New survey even if HCP has been nominated before...
            // this.surveys Looks for a survey for the HCP with the same Category as the new Nomination
            //this.surveys = [select Speaker_Bureau_Membership_gne__r.Speaker_Category_gne__c, Questionnaire_gne__r.Category_gne__c, Account__c from Survey_gne__c where Questionnaire_gne__r.Category_gne__c = 'Speaker Nomination Survey'AND Account__c = :ApexPages.currentPage().getParameters().get('id')];
            //this.surveys = [select Speaker_Bureau_gne__c, Speaker_Nomination_Category_gne__c, Speaker_Bureau_Membership_gne__r.Speaker_Category_gne__c, Questionnaire_gne__r.Category_gne__c, Account__c from Survey_gne__c where Speaker_Nomination_Category_gne__c = :selected_bureau.Speaker_Category_gne__c AND Account__c = :ApexPages.currentPage().getParameters().get('id')];           
            
            //Boolean found;
            //for (survey_gne__c s_x : surveys){
                //found = false;
                //if (selected_bureau.Id == s_x.Speaker_Bureau_gne__c)
               // found = true;
            //}
            
            
            
           // if(this.surveys.isEmpty()){
                PageReference pRef = new PageReference('/apex/GNE_EM3_CreateSurvey_2?act_id='+ApexPages.currentPage().getParameters().get('id')+'&spb_id='+a_bureau+'&create_flag=1&retURL=/'+ApexPages.currentPage().getParameters().get('id'));
                return pRef.setRedirect(true);              
            //}else if (!this.surveys.isEmpty() && !found ) {
            //    PageReference pRef = new PageReference('/apex/GNE_EM3_CreateSurvey_2?act_id='+ApexPages.currentPage().getParameters().get('id')+'&spb_id='+a_bureau+'&create_flag=0&retURL=/'+ApexPages.currentPage().getParameters().get('id'));
            //    return pRef.setRedirect(true);              
            //}
            //else {
            //    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'An Error has occurred - Membership found with same category. Can't find Survey'));
            //    return null;                
            //}
        }
    }       
    
    public PageReference cancel(){
        PageReference pRef = new PageReference('/'+ApexPages.currentPage().getParameters().get('id'));
        return pRef.setRedirect(true);  
    }
    
    public void setSpeaker_Bureau_Options(){
    }
    
    //Creates and returns a list of selectOptions with bureaus in which the user is not already a member
    public List<SelectOption> getYear_Options() {   
        if(yearOptions==null){
            yearOptions = new List<SelectOption>();
            yearOptions.add(new SelectOption('','--Select a Year--'));
            //List<Speaker_Bureau_gne__c> myBureaus=[select Id, Name from Speaker_Bureau_gne__c where ID not IN :this.excluded_bureaus order by Name];
            
            //Puts current and previous year in a set
            set<String> Years = new set<String>();
            Years.add(''+Date.Today().Year());
            Integer prevYear = Date.Today().Year();
            prevYear++;
            Years.add(''+prevYear);
            
            //Query for all speaker bureaus residing in this year or the next                                   
            for(String year : Years ) {
                yearOptions.add(new SelectOption(year,year));                
            }            
        }        
        return yearOptions;   
    }
    
    //Creates and returns a list of selectOptions with bureaus in which the user is not already a member
    public List<SelectOption> getSpeaker_Bureau_Options() { 
        if(this.Year==null){
            bureauOptions = new List<SelectOption>();
            bureauOptions.add(new SelectOption('','--Select a Bureau--'));
            //List<Speaker_Bureau_gne__c> myBureaus=[select Id, Name from Speaker_Bureau_gne__c where ID not IN :this.excluded_bureaus order by Name];                        
        }
        if(this.Year != null){
            bureauOptions.clear();
            system.debug('222:'+this.year);
            bureauOptions.add(new SelectOption('','--Select a Bureau--'));
            //Query for all speaker bureaus residing in this year or the next            
            List<Speaker_Bureau_gne__c> myBureaus=[select Id, Name from Speaker_Bureau_gne__c where Speaker_bureau_year_gne__c = :this.Year 
            AND ID NOT IN :this.memberOf order by Name];
            system.debug('111:'+myBureaus);                     
            for(Speaker_Bureau_gne__c sb : myBureaus ) {
                bureauOptions.add(new SelectOption(sb.Id,sb.Name));                
            }            
        }                
        return bureauOptions;          
    }




}