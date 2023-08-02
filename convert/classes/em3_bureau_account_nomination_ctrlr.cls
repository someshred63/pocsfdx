public class em3_bureau_account_nomination_ctrlr {  

private Speaker_Bureau_gne__c bureauO;
    public boolean yearCheck = false;
    public Account acc{set; get;}  
    public pagereference pRef; 
    //001Q0000003uL53
    private List<Survey_gne__c> Surveys = new List<Survey_gne__c>();        
    
    public em3_bureau_account_nomination_ctrlr(ApexPages.StandardController controller){        
        //this.acc = new Account();        
        //this.acc = (Account)Controller.getRecord();
        //per SFDC Premium support
        this.acc = [select ParentId,Classification_gne__c,AccountPerson__c from account limit 1];
        
        
        this.bureauO = [select ID, Name, Speaker_Bureau_Year_gne__c, Speaker_Category_gne__c from Speaker_Bureau_gne__c where ID = :ApexPages.currentPage().getParameters().get('id')];
        system.debug('Success Speaker_Bureau_gne__c');
        yearCheck();                
    }                   
    
    public boolean getYearCheck(){
        return this.yearCheck;
    }
    
    public pageReference yearCheck(){
        //Puts current and previous year in a set
        set<String> Years = new set<String>();
        Years.add(''+Date.Today().Year());
        Integer prevYear = Date.Today().Year();
        prevYear++;
        Years.add(''+prevYear);
        system.debug('==>'+Years+'SB==>'+this.bureauO.Speaker_bureau_year_gne__c);
        if(Years.contains(this.bureauO.Speaker_bureau_year_gne__c)){                
            this.yearCheck = true;
        }else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You can only Nominate into a Bureau for This year or the Next.  Press Cancel to go back and select an Appropriate Bureau.'));
            return null;
        }
        system.debug('Success yearCheck');
        return null;
    }
    
    public boolean existing_survey(){       
        /*// Speaker Content
        this.surveys = [select Speaker_Bureau_Membership_gne__r.Speaker_Category_gne__c, Questionnaire_gne__r.Category_gne__c, Account__c from Survey_gne__c where Questionnaire_gne__r.Category_gne__c = 'Speaker Nomination Survey'AND Account__c = :ApexPages.currentPage().getParameters().get('id')];
        
        if(!this.surveys.isEmpty()){
            proceed = true;
        }       
                
        return proceed;
        */
        return null;                    
    }
    
    public PageReference next(){                            
        if(this.acc.AccountPerson__c == null){                              
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please Select an Account'));
            return null;
        }
        else{
            this.acc = [select ID, ParentId,Classification_gne__c,AccountPerson__c from Account where id = :this.acc.AccountPerson__c limit 1];
             system.debug('Success Account');
             
            if(this.acc.Classification_gne__c == null){
                system.debug('XXXXX this.acc.Classification_gne__c:' + this.acc.Classification_gne__c);
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please submit a classification request with the person\'s CV to Medical Affairs at speakerclassification-d@gene.com. Medical Affairs will classify the person, update the required field, and notify you. Once this is completed you may nominate the person to the bureau.'));
                return null;
            }
        
            boolean existing_survey = false;            
            
            this.surveys = [select Speaker_Nomination_Category_gne__c, Speaker_Bureau_Membership_gne__r.Speaker_Category_gne__c, Questionnaire_gne__r.Category_gne__c, Account__c from Survey_gne__c where Speaker_Nomination_Category_gne__c = :this.bureauO.Speaker_Category_gne__c and Account__c=:acc.Id];          
            system.debug(surveys);
            system.debug('Success Survey');
            List<Speaker_Bureau_Membership_gne__c> sbm = new List<Speaker_Bureau_Membership_gne__c>([select name from Speaker_Bureau_Membership_gne__c where Bureau_Member_gne__c=:acc.Id and Speaker_Bureau_ID_gne__c=:bureauO.Id]);
            system.debug('Success Speaker_Bureau_Membership_gne__c');
            //No Surveys in and not current Member of Bureau
            //Claudia M: 9/28: Require new Survey even if already a member  of another Bureau
            //if(this.surveys.isEmpty() && sbm.size() == 0){
            if(sbm.size() == 0){
                system.debug('No Surveys in and not current Member of Bureau');
                //Kishore Feb/5/13: force.com team modified
                if (GNE_SFA2_Util.isSFA2User())
                    pRef = new PageReference('/apex/GNE_SFA2_SBMembership_Nominate_Layout?act_id='+this.acc.id+'&spb_id='+ApexPages.currentPage().getParameters().get('id')+'&create_flag=1&retURL=/'+ApexPages.currentPage().getParameters().get('id'));
                else
                    pRef = new PageReference('/apex/GNE_EM3_CreateSurvey_2?act_id='+this.acc.id+'&spb_id='+ApexPages.currentPage().getParameters().get('id')+'&create_flag=1&retURL=/'+ApexPages.currentPage().getParameters().get('id'));
                return pRef.setRedirect(true);              
            //}
            ////Survey in, but not a member of Bureau (no Survey needed)
            // else if (!this.surveys.isEmpty() && sbm.size() == 0){
            //     system.debug('!Survey in, but not a member of Bureau (no Survey needed)');
            //    PageReference pRef = new PageReference('/apex/GNE_EM3_CreateSurvey_2?act_id='+this.acc.id+'&spb_id='+ApexPages.currentPage().getParameters().get('id')+'&create_flag=0&retURL=/'+ApexPages.currentPage().getParameters().get('id'));
            //    return pRef.setRedirect(true);              
            }
            //Already a member 
            else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'The HCP is already a member of this Bureau.'));
                return null;                
            }
            
/*          
            //changes
            this.surveys = [select Speaker_Bureau_Membership_gne__r.Speaker_Category_gne__c, Questionnaire_gne__r.Category_gne__c, Account__c from Survey_gne__c where Questionnaire_gne__r.Category_gne__c = 'Speaker Nomination Survey' AND Account__c = :this.acc.id];
            
            for(Survey_gne__c survey : this.surveys){
                if(survey.Speaker_Bureau_Membership_gne__r.Speaker_Category_gne__c == this.bureauO.Speaker_Category_gne__c){
                    existing_survey = true;
                    break;
                }                       
            }                       
            if(!existing_survey){                                               
                PageReference pRef = new PageReference('/apex/GNE_EM3_CreateSurvey_2?act_id='+this.acc.id+'&spb_id='+ApexPages.currentPage().getParameters().get('id')+'&retURL=/'+ApexPages.currentPage().getParameters().get('id'));
                return pRef.setRedirect(true);
            }else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'The HCP does not need to take another Survey'));
                return null;                
            }           
*/          
        }       
        return null;        
    }       
    
    public PageReference cancel(){
        PageReference pRef = new PageReference('/'+ApexPages.currentPage().getParameters().get('id'));
        return pRef.setRedirect(true);              
    }

}