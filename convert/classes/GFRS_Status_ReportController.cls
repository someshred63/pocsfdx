public with sharing class GFRS_Status_ReportController {
    
    public static final String CONTENT_TYPE = 'Status Report';
    public static final String PATH_HOME    = '/apex/gFRS_Home';
    
    public Map<String,String> contentItems     { get; set; }
    public GFRS_Funding_Request__c fundReq     { get; set; }
    public Id currentProgramId                 { get; set; }
    public Boolean isLastProgramSelected       { get; set; }
    public Id selectedProgramId                { get; set; }
    public GFRS_Program__c[] programs          { get; set; }
    public Boolean isEditable                  { get; set; }
    public Boolean isVenueRequired             { get; set; }
    public Boolean showprograms                { get; set; }
    public Boolean showStatusReport            { get; set; }
    public String pathHome                     { get; set; }
    public String changedField                 { get; set; }
    public Boolean isTotalBugetAmountReq       { get; set; }
    public Boolean isTotalSupportReq           { get; set; }
    public Boolean isEducationalReq            { get; set; }
    public Boolean isRedirectFromReconcilation { get; set; }
    public Boolean didntExhibitAtEvent         { get; set; }
    public Boolean didntExhibitAtEventOther    { get; set; }
    
    
    public GFRS_Status_ReportController( ApexPages.StandardController std ){
        
        this.contentItems          = gFRS_ContentTranslationUtil.fetchContentTranslationsByFilter(CONTENT_TYPE, UserInfo.getLanguage());         
        this.isLastProgramSelected = false;
        this.didntExhibitAtEvent   = false;
        this.didntExhibitAtEventOther   = false;
        this.fundReq               = (GFRS_Funding_Request__c)std.getRecord();
        
        if(Apexpages.currentPage().getParameters().containsKey('showSecondSection')){
            
            showprograms                 = true;
            showStatusReport             = false;
            isRedirectFromReconcilation  = true;
            
        }else{
            
            showprograms                 = false;
            showStatusReport             = true;
            isRedirectFromReconcilation  = false;
        }    
        pathHome = gFRS_Util.initializeLink( PATH_HOME, null, null );
        this.isEditable = true; 
        
        if( this.fundReq == null || this.fundReq.id == null ){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Funding request was not sent' ));
            return;
        }
        
        try {
            this.fundReq = [ SELECT Id, Name, Record_Type_Name__c, Program_Status_Task_Override_By__c, Status_Updates_Submitted__c,
                            Event_Program_Title__c, Sub_Status__c, 
                            Program_Specifications__c, Audience_Generation_Program_Dist__c, 
                            Attendence_Distrib__c, Project_Status__c, 
                            Did_Total_Budget_Amount_for_this_Program__c, If_Yes_How_Many_Commercial__c, 
                            If_Yes_New_Total_Budget_for_Program__c, If_Yes_New_Educational_Objectives__c, 
                            Did_Educational_Objectives_Change__c, Change_in_Number_of_Commercial__c, Program_End_Date_max__c 
                            FROM GFRS_Funding_Request__c 
                            WHERE Id = :this.fundReq.id];
            
        } catch( Exception err ){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Error occurred while loading the funding request' ));
            return;
        }
        
        if (this.fundReq.Record_Type_Name__c == 'Exhibits & Other Promos' || this.fundReq.Record_Type_Name__c == 'Sci/Pipeline Exhibits & Other Non-Promo' ){
            showprograms                 = true;
            showStatusReport             = false;               
        }
        
        this.isVenueRequired = ( !gFRS_Util.TYPE_FELLOWSHIPS_NAME.equals( this.fundReq.Record_Type_Name__c ) );
        
        programs = [SELECT  Id, Name, Type__c, Program_Subtype__c, Did_you_exhibit_sponsor_at_the_event__c,
                    Start_Date__c, End_Date__c, Program_status__c, Why_didnt_you_exhibit_at_the_event__c, Unable_to_Exhibit_Event_Other__c,
                    Venue_Country__c, Venue_State__c, Venue_Province_Region__c, 
                    Venue_City__c, Venue_Name__c, Venue_Type__c, Venue_Zip_Code__c, 
                    Web_URL__c, Launch_Date__c, Expiration_Date__c, Targeted_Visits__c, 
                    Total_Visits__c, Average_Minutes_Per_Visit__c, Number_of_Certificates_Issued__c, 
                    Number_of_Completions__c, Unique_Visits__c, Program_URL__c  
                    FROM GFRS_Program__c 
                    WHERE Funding_Request__c = :this.fundReq.id];
        
        this.selectedProgramId=programs[0].id;
        
        /** For Requirement SFDC-1686 field no longer needed on Status report page

if(this.fundReq.No_Updates_Changes_to_Status_Reports__c != null){
if(this.fundReq.No_Updates_Changes_to_Status_Reports__c= = false){
this.updateStatus = 'Yes';
}else if(this.fundReq.No_Updates_Changes_to_Status_Reports__c= = true){
this.updateStatus = 'No';
}   
}
*/
        
        if(this.fundReq.Did_Total_Budget_Amount_for_this_Program__c != null && this.fundReq.Did_Total_Budget_Amount_for_this_Program__c == 'Yes'){
            this.isTotalBugetAmountReq = true;
        }else if(this.fundReq.Did_Total_Budget_Amount_for_this_Program__c == null || (this.fundReq.Did_Total_Budget_Amount_for_this_Program__c != null && this.fundReq.Did_Total_Budget_Amount_for_this_Program__c == 'No')){   
            this.isTotalBugetAmountReq = false;
        }
        
        
        if(this.fundReq.Change_in_Number_of_Commercial__c != null && this.fundReq.Change_in_Number_of_Commercial__c == 'Yes'){
            this.isTotalSupportReq = true;
        }else if(this.fundReq.Change_in_Number_of_Commercial__c == null || (this.fundReq.Change_in_Number_of_Commercial__c != null && this.fundReq.Change_in_Number_of_Commercial__c == 'No')){
            this.isTotalSupportReq = false;
        }
        
        if(this.fundReq.Did_Educational_Objectives_Change__c != null && this.fundReq.Did_Educational_Objectives_Change__c == 'Yes'){
            this.isEducationalReq = true;
        }else if(this.fundReq.Did_Educational_Objectives_Change__c == null || (this.fundReq.Did_Educational_Objectives_Change__c != null && this.fundReq.Did_Educational_Objectives_Change__c == 'No')){
            this.isEducationalReq = false;
        }
        
        
        
        
    }
    public ApexPages.Pagereference back()
    {
        showprograms = false;
        showStatusReport = true;
        return null;
    }
    public ApexPages.Pagereference saveReport(){
        try{
            
            if(!isEditable)
            {
                if(!validateReportScope()){
                    return null;
                }
                showprograms = true;
                showStatusReport = false;
                return null;
            }
            /** For Requirement SFDC-2686 field no longer needed on Status report page
if(this.updateStatus == null || this.updateStatus == '' ){
ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'"Update To status report?" field must be set.'));
return (null);
} */else {
    if(!validateReportScope()){
        return null;
    }
    showprograms     = true;
    showStatusReport = false;
    /** For Requirement SFDC-2686 field no longer needed on Status report page
this.fundReq.No_Updates_Changes_to_Status_Reports__c = this.updateStatus.equals('No') ? true : false;
*/
    fundReq.Last_Status_Report_Completion_Date__c = DateTime.now();
    fundReq.IsValidationExternalOnly__c='Yes';
    update this.fundReq;
}
            
        } catch (DMLException e) { 
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, gFRS_Util.getPrettyMessage(e)));
        }
        //return new ApexPages.PageReference( gFRS_Util.initializeLink( PATH_HOME, null, null ) );
        return null;
    }
    /*
public ApexPages.Pagereference closeReport(){
return( new ApexPages.PageReference( gFRS_Util.initializeLink( PATH_HOME, null, null ) ));
}       
*/
    public Boolean validateReportScope(){
        Boolean isValid = true;
        
        if(this.isTotalBugetAmountReq && this.fundReq.If_Yes_New_Total_Budget_for_Program__c == null){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, ' '+Schema.sObjectType.GFRS_Funding_Request__c.fields.If_Yes_New_Total_Budget_for_Program__c.getInlineHelpText()+': You must enter a value' ));
            isValid = false;
        }
        if(this.isTotalSupportReq && this.fundReq.If_Yes_How_Many_Commercial__c == null){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, ' '+Schema.sObjectType.GFRS_Funding_Request__c.fields.If_Yes_How_Many_Commercial__c.getInlineHelpText()+': You must enter a value' ));
            isValid = false;
        }
        if(this.isEducationalReq && this.fundReq.If_Yes_New_Educational_Objectives__c == null){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, ' '+Schema.sObjectType.GFRS_Funding_Request__c.fields.If_Yes_New_Educational_Objectives__c.getInlineHelpText()+': You must enter a value' ));
            isValid = false;
        }
        return  isValid;
    }
    public String statusUpdateMessage { get { return( this.contentItems.get('StatusUpdateLabel')); }}
    
    public Boolean hasMessages {
        get { return( ApexPages.hasMessages() ); }
    }
    
    public ApexPages.Pagereference goToProgram(){
        return null;
    }
    public ApexPages.PageReference saveProgramInternal(){
        try{
            for(GFRS_Program__c prg : programs){
                
                if(prg.Did_you_exhibit_sponsor_at_the_event__c == '' || prg.Did_you_exhibit_sponsor_at_the_event__c == null){
                    ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, System.Label.gFRS_ExhibitOrNot ));
                    return null;
                }

                if(prg.Did_you_exhibit_sponsor_at_the_event__c == 'Yes' && (prg.Why_didnt_you_exhibit_at_the_event__c != null && prg.Why_didnt_you_exhibit_at_the_event__c != '')){
                    ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, System.Label.gFRS_WhyDidntNotRequired ));
                    return null;
                }   

                if((prg.Did_you_exhibit_sponsor_at_the_event__c == 'Yes' && (prg.Why_didnt_you_exhibit_at_the_event__c == null || prg.Why_didnt_you_exhibit_at_the_event__c == '')) && (prg.Unable_to_Exhibit_Event_Other__c != null && prg.Unable_to_Exhibit_Event_Other__c != '')){
                    ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, System.Label.gFRS_IfOtherNotRequired ));
                    return null;
                }               
                
                if(prg.Did_you_exhibit_sponsor_at_the_event__c == 'No' && (prg.Why_didnt_you_exhibit_at_the_event__c == null) || prg.Why_didnt_you_exhibit_at_the_event__c == ''){
                    ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, System.Label.gFRS_WhyDidntYouExhibit ));
                    return null;
                }

                if(prg.Why_didnt_you_exhibit_at_the_event__c == 'Other' && (prg.Unable_to_Exhibit_Event_Other__c == null || prg.Unable_to_Exhibit_Event_Other__c == '')){
                    ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, System.Label.gFRS_IfOtherPlzSpecify ));
                    return null;
                }   
               
            }  
            update programs;    
            statusReportTaskUpdate();           
        } catch( Exception err ){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(err) ));
            
            return(null);
        }
        return (new PageReference(gFRS_Util.initializeLink( PATH_HOME, null, null )));
    }   
    public ApexPages.PageReference saveProgram(){   
        Id idSelectedProgram = null;  
        idSelectedProgram=Id.valueOf( selectedProgramId );
        Map<id,GFRS_Program__c> programMap = new Map<id,GFRS_Program__c>( this.programs );
        GFRS_Program__c program = programMap.get( idSelectedProgram );
        if( !programMap.containsKey( idSelectedProgram )){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'System Error: unable to find program to update' ));
            
            return(null);
        }
        
        
        try {
            
            if(!globalProgramValidation(program)){
                return null;
            }
            
            if(program.Type__c=='Live' && !validateLiveProgram(program)){
                return null;
            }else if(program.Type__c=='Enduring' && !validateEnduringProgram(program)){
                return null;
            }else if(program.Type__c=='Web' && !validateWebProgram(program)){
                return null;
            }else if(program.Type__c=='Grand Rounds' && !validateGrandRoundsProgram(program)){
                return null;
            }
            program.IsValidationExternalOnly__c='Yes'; 
            
            update program;
            
            statusReportTaskUpdate();
            
        } catch( Exception err ){
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(err) ));
            
            return(null);
        }
        return( null );
    }
    
    public ApexPages.PageReference updateTaskStatus(){ 
        List<gFRS_Tasks__c> tasks = [SELECT Id, Name, Action_Type__c, Status__c, gFRS_Funding_Request__c FROM gFRS_Tasks__c WHERE gFRS_Funding_Request__c=:fundReq.Id AND Action_Type__c='Status Report' AND Status__c=:gFRS_Util.TASK_NOT_SUBMITTED];
        for(gFRS_Tasks__c task:tasks){
            task.Status__c =  gFRS_Util.TASK_SUBMITTED;
            
        }
        update tasks;
        
        statusReportTaskUpdate();
        
        return null;   
    }
    
    private void statusReportTaskUpdate(){
        gFRS_Tasks__c task = [SELECT Id, Name, Status__c FROM gFRS_Tasks__c WHERE gFRS_Funding_Request__c=:fundReq.Id AND Action_Type__c='Status Report' LIMIT 1];
        if(task!=null){
            Boolean programOngoing = ([SELECT count() FROM GFRS_Program__c 
                                       WHERE Funding_Request__c=:fundReq.Id 
                                       AND Program_Status__c 
                                       NOT IN ('Completed','Canceled','Entered in Error')] > 0);
            
            if(!programOngoing && fundReq.Program_End_Date_max__c < System.today()){
                task.Status__c = gFRS_Util.TASK_COMPLETED;
            }
            else{
                task.Status__c = gFRS_Util.TASK_SUBMITTED;          
            }
            update task;  
            
            if (this.fundReq.Record_Type_Name__c == 'Exhibits & Other Promos' || this.fundReq.Record_Type_Name__c == 'Sci/Pipeline Exhibits & Other Non-Promo' ){
                gFRS_Util_NoShare.removeTask(task);
                this.fundReq.Status_Updates_Submitted__c          =   'Yes';
                this.fundReq.Program_Status_Task_Override_By__c   =   userinfo.getname();
                gFRS_Util_NoShare.saveLockedFundingRequestInternalPage(this.fundReq);               
            }                
        }
    }
    
    public Boolean globalProgramValidation(GFRS_Program__c p){
        Boolean isValid = true;
        if((gFRS_Util.TYPE_IMED_NAME.equals( this.fundReq.Record_Type_Name__c ) 
            && (p.Program_Status__c =='Confirmed' || p.Program_Status__c =='Completed')) 
           || gFRS_Util.TYPE_FELLOWSHIPS_NAME.equals( this.fundReq.Record_Type_Name__c )){
               
               if(p.Venue_Country__c != null && p.Venue_Country__c !='United States' && 
                  (p.Venue_Province_Region__c == null || p.Venue_Province_Region__c.trim() == '')
                  && p.Start_Date__c != null){
                      
                      ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_ERROR_SpecifyProvinceRegion ));
                      
                      isValid = false;
                  }
               
               //US_State
               if(p.Venue_Country__c != null && p.Venue_Country__c =='United States' && 
                  (p.Venue_State__c == null || p.Venue_State__c =='')
                  && p.Start_Date__c != null){
                      
                      ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.gFRS_ERROR_SpecifyVenueState ));
                      
                      isValid = false;
                  }
           }
        return isValid;
    }
    
    public Boolean validateLiveProgram(GFRS_Program__c currentProgram){
        Boolean isValid = true;
        if(currentProgram.Start_Date__c == null){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, ' '+Schema.sObjectType.GFRS_Program__c.fields.Start_Date__c.getLabel()+': You must enter a value' ));
            isValid = false;
        }
        if(currentProgram.End_Date__c == null){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, ' '+Schema.sObjectType.GFRS_Program__c.fields.End_Date__c.getLabel()+': You must enter a value' ));
            isValid = false;
        }
        
        if(!isVenueRequired){
            if(currentProgram.Program_Status__c == null){
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, ' '+Schema.sObjectType.GFRS_Program__c.fields.Program_Status__c.getLabel()+': You must enter a value' ));
                isValid = false;
            }
        }else{
            
            if(currentProgram.Program_Status__c == null){
                ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, ' '+Schema.sObjectType.GFRS_Program__c.fields.Program_Status__c.getLabel()+': You must enter a value' ));
                isValid = false;
            }
            
            if(((currentProgram.Program_Status__c =='Confirmed' || currentProgram.Program_Status__c =='Completed') && gFRS_Util.TYPE_IMED_NAME.equals( this.fundReq.Record_Type_Name__c )) || 
               gFRS_Util.TYPE_FELLOWSHIPS_NAME.equals( this.fundReq.Record_Type_Name__c )){  
                   
                   if(currentProgram.Venue_Name__c == null){
                       ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, ' '+Schema.sObjectType.GFRS_Program__c.fields.Venue_Name__c.getLabel()+': You must enter a value' ));
                       isValid = false;
                   }
                   if(currentProgram.Venue_City__c == null){
                       ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, ' '+Schema.sObjectType.GFRS_Program__c.fields.Venue_City__c.getLabel()+': You must enter a value' ));
                       isValid = false;
                   }
                   if(currentProgram.Venue_Country__c == null){
                       ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, ' '+Schema.sObjectType.GFRS_Program__c.fields.Venue_Country__c.getLabel()+': You must enter a value' ));
                       isValid = false;
                   }
                   if((currentProgram.Program_Subtype__c=='Grand Rounds: Live' || currentProgram.Program_Subtype__c=='Meeting Series: Live') && currentProgram.Venue_Type__c == null){
                       ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, ' '+Schema.sObjectType.GFRS_Program__c.fields.Venue_Type__c.getLabel()+': You must enter a value' ));
                       isValid = false;            
                   }
               }else{
                   //Validation for IMED live program only where Status is not Confirmed and Completed
                   
                   if(currentProgram.Venue_Country__c == null){
                       ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, ' '+Schema.sObjectType.GFRS_Program__c.fields.Venue_Country__c.getLabel()+': You must enter a value' ));
                       isValid = false;
                   }
                   if((currentProgram.Program_Subtype__c=='Grand Rounds: Live' 
                       || currentProgram.Program_Subtype__c=='Meeting Series: Live') 
                      && currentProgram.Venue_Type__c == null){
                          ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, ' '+Schema.sObjectType.GFRS_Program__c.fields.Venue_Type__c.getLabel()+': You must enter a value' ));
                          isValid = false;            
                      }
               }
        }
        return isValid;
    }
    public Boolean validateEnduringProgram(GFRS_Program__c currentProgram){
        Boolean isValid = true;
        if(currentProgram.Start_Date__c == null){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, ' '+Schema.sObjectType.GFRS_Program__c.fields.Start_Date__c.getLabel()+': You must enter a value' ));
            isValid = false;
        }
        
        if(currentProgram.End_Date__c == null){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, ' '+Schema.sObjectType.GFRS_Program__c.fields.End_Date__c.getLabel()+': You must enter a value' ));
            isValid = false;
        }
        if(currentProgram.Program_Status__c == null){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, ' '+Schema.sObjectType.GFRS_Program__c.fields.Program_Status__c.getLabel()+': You must enter a value' ));
            isValid = false;
        }
        return isValid;     
    }
    public Boolean validateWebProgram(GFRS_Program__c currentProgram){
        Boolean isValid = true;
        if(currentProgram.Start_Date__c == null){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, ' '+Schema.sObjectType.GFRS_Program__c.fields.Start_Date__c.getLabel()+': You must enter a value' ));
            isValid = false;
        }
        if(currentProgram.End_Date__c == null){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, ' '+Schema.sObjectType.GFRS_Program__c.fields.End_Date__c.getLabel()+': You must enter a value' ));
            isValid = false;
        }
        if(currentProgram.Program_Status__c == null){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, ' '+Schema.sObjectType.GFRS_Program__c.fields.Program_Status__c.getLabel()+': You must enter a value' ));
            isValid = false;
        }
        return isValid;     
    }
    public Boolean validateGrandRoundsProgram(GFRS_Program__c currentProgram){
        Boolean isValid = true;
        if(currentProgram.Start_Date__c == null){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, ' '+Schema.sObjectType.GFRS_Program__c.fields.Start_Date__c.getLabel()+': You must enter a value' ));
            isValid = false;
        }
        if(currentProgram.End_Date__c == null){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, ' '+Schema.sObjectType.GFRS_Program__c.fields.End_Date__c.getLabel()+': You must enter a value' ));
            isValid = false;
        }
        return isValid;     
    }
    
    public void changeValue(){
        if(this.changedField != null){
            if(this.changedField == 'Did_Total_Budget_Amount_for_this_Program__c'){
                if(this.fundReq.Did_Total_Budget_Amount_for_this_Program__c != null && this.fundReq.Did_Total_Budget_Amount_for_this_Program__c == 'Yes'){
                    this.isTotalBugetAmountReq = true;
                }else if(this.fundReq.Did_Total_Budget_Amount_for_this_Program__c == null ||  (this.fundReq.Did_Total_Budget_Amount_for_this_Program__c != null && this.fundReq.Did_Total_Budget_Amount_for_this_Program__c == 'No')){
                    this.fundReq.If_Yes_New_Total_Budget_for_Program__c=null;
                    this.isTotalBugetAmountReq = false;
                }
            }
            if(this.changedField == 'Change_in_Number_of_Commercial__c'){
                if(this.fundReq.Change_in_Number_of_Commercial__c != null && this.fundReq.Change_in_Number_of_Commercial__c == 'Yes'){
                    this.isTotalSupportReq = true;
                }else if(this.fundReq.Change_in_Number_of_Commercial__c == null || (this.fundReq.Change_in_Number_of_Commercial__c != null && this.fundReq.Change_in_Number_of_Commercial__c == 'No')){
                    this.fundReq.If_Yes_How_Many_Commercial__c=null;
                    this.isTotalSupportReq = false;
                }
                
            }
            if(this.changedField == 'Did_Educational_Objectives_Change__c'){
                if(this.fundReq.Did_Educational_Objectives_Change__c != null && this.fundReq.Did_Educational_Objectives_Change__c == 'Yes'){
                    this.isEducationalReq = true;
                }else if(this.fundReq.Did_Educational_Objectives_Change__c == null || (this.fundReq.Did_Educational_Objectives_Change__c != null && this.fundReq.Did_Educational_Objectives_Change__c == 'No')){
                    this.fundReq.If_Yes_New_Educational_Objectives__c=null;
                    this.isEducationalReq = false;
                }
                
            }               
        }
    }
    /**
* @author GFRS Dev Team 
* @date 22/08/2013
* @description  getShowProgramsToUpdateMessage method - check if any of program need update
*/
    
    public Boolean getShowProgramsToUpdateMessage(){
        List<GFRS_Program__c> programsToUpdate=new List<GFRS_Program__c>();
        for(GFRS_Program__c program: this.programs){
            
            if(program.Program_Status__c != null 
               && (program.Program_Status__c =='Planned' || program.Program_Status__c == 'Confirmed' ) 
               && program.End_Date__c<Date.today() ){
                   
                   return true;
               }
        }
        return false;
        
    }
    
    /**
* @author GFRS Dev Team 
* @date 22/08/2013
* @description  getProgramsToUpdate method - specify list of programs which should be updated
*/
    public List<GFRS_Program__c> getProgramsToUpdate(){
        List<GFRS_Program__c> programsToUpdate=new List<GFRS_Program__c>();
        for(GFRS_Program__c program: this.programs){
            if(program.Program_Status__c != null 
               && (program.Program_Status__c =='Planned' || program.Program_Status__c == 'Confirmed' ) 
               && program.End_Date__c<Date.today() ){
                   
                   programsToUpdate.add(program);
               }
        }
        return programsToUpdate;
    }
    
}