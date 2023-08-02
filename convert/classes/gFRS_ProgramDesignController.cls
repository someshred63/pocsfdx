public with sharing class gFRS_ProgramDesignController{

    public static final String PATH_THIRDPARTY     = '/apex/gFRS_ThirdParty';
    public static final String PATH_PROGRAM     = '/apex/gFRS_Program';
    public static final String PATH_APPLICATION     = '/apex/gFRS_Application';
    public static final String PATH_DEMOGRAPHIC = '/apex/GFRS_DemographicGroups';
    public GFRS_Funding_Request__c fundReq {get; set;}
    public gFRS_Program_Design_and_Implementation__c pDesign {get; set;} 

    public Boolean pageEditable {get; set;}
    public Boolean isPDesignRecordNew {get; set;}

    /**
    * @author ADMD Dev Team 
    * @date 17/03/2016
    * @description gFRS_ProgramDesignController method - controller of the class
    */
    public gFRS_ProgramDesignController(ApexPages.StandardController std) {

        // add custom fields to funding requests and get it
        std.addFields(new List<String> {'Record_Type_Name__c','Will_You_be_Working_With_a_3rd_Party__c','Information_Needed__c'});
        this.fundReq = (GFRS_Funding_Request__c)std.getRecord();

        // technical variable to determine if we should update existing or insert new record
        this.isPDesignRecordNew = false;

        try{
            this.pDesign = [SELECT Id,
            Learner_inform_about_problem_to_the_ga_1__c,
            Learner_inform_about_evidence_based_ca_1__c,
            Not_applicable_for_this_education_1__c,
            Learners_demonstrate_improvements_2__c,
            Learners_help_system_adopt_information_2__c,
            Demonstrate_improvements_can_reproduce_2__c,
            Not_applicable_for_this_education_2__c,
            Pair_barriers_with_future_intervention_3__c,
            Demonstrate_practice_improvements_3__c,
            Example_certification_change_in_proces_3__c,
            Not_applicable_for_this_education_3__c,
            Improve_communication_about_care_plans_4__c,
            Increase_satisfaction_of_care_4__c,
            Better_health_living_decisions_adheren_4__c,
            Tools_integrated_to_sustain_change_4__c,
            Not_applicable_for_this_education_4__c
            FROM gFRS_Program_Design_and_Implementation__c WHERE gFRS_Funding_Request__c =: fundReq.Id];
            system.debug('pDesign value in controller: '+ this.pDesign);
        } catch(Exception e) {
            // We are not adding this page messages to not mess-up the intake process screen.
            // If record is not found we will insert a new one in Save method

            //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Program Design Record not found!'));
            //ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }

        // if above query didn't return results, initialize new record
        if(this.pDesign == null){
            this.pDesign = new gFRS_Program_Design_and_Implementation__c();
            this.pDesign.gFRS_Funding_Request__c = fundReq.Id;
            this.isPDesignRecordNew = true;
        }

        // set page in editable mode if inforation needed
        this.pageEditable = gFRS_Util.multiSelectHasItem( fundReq.Information_Needed__c, 'Program Design' );
        if(this.pageEditable == null){
             this.pageEditable=false;
        }       
        
    }

    /**
    * @author ADMD Dev Team 
    * @date 17/03/2016
    * @description save method - saves values of gFRS Program Design and Implementation record and goes to next page in path
    */
    public PageReference save(){

        try{
            system.debug('pDesign being saved: '+this.pDesign);
            if(validateAnswers()){
                gFRS_Util_NoShare.saveLockedProgramDesign(this.pDesign);
            } else {
                return null;
            }

            return( new ApexPages.PageReference( gFRS_Util.initializeLink( PATH_PROGRAM, this.fundReq, '' ) ));

        } catch(Exception e) {
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(e)));
        }

        return null;
    }

    /**
    * @author ADMD Dev Team 
    * @date 17/03/2016
    * @description validateAnswers method - checks if all questions are answered (at least 1 answer for each question is needed)
    */
    public Boolean validateAnswers(){
        Boolean result = true;

        // validate 1st question
        if(!this.pDesign.Learner_inform_about_evidence_based_ca_1__c && 
            !this.pDesign.Learner_inform_about_problem_to_the_ga_1__c &&
            !this.pDesign.Not_applicable_for_this_education_1__c){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.gFRS_ProgramDesign1stQuestion + ': you must specify a value.' ));
            result = false;
        }
        // validate 2nd question
        if(!this.pDesign.Demonstrate_improvements_can_reproduce_2__c && 
            !this.pDesign.Learners_demonstrate_improvements_2__c &&
            !this.pDesign.Learners_help_system_adopt_information_2__c &&
            !this.pDesign.Not_applicable_for_this_education_2__c){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.gFRS_ProgramDesign2ndQuestion + ': you must specify a value.' ));
            result = false;
        }
        // validate 3rd question
        if(!this.pDesign.Demonstrate_practice_improvements_3__c && 
            !this.pDesign.Example_certification_change_in_proces_3__c &&
            !this.pDesign.Not_applicable_for_this_education_3__c &&
            !this.pDesign.Pair_barriers_with_future_intervention_3__c){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.gFRS_ProgramDesign3rdQuestion + ': you must specify a value.' ));
            result = false;
        }
        // validate 4th question
        if(!this.pDesign.Better_health_living_decisions_adheren_4__c && 
            !this.pDesign.Improve_communication_about_care_plans_4__c &&
            !this.pDesign.Increase_satisfaction_of_care_4__c &&
            !this.pDesign.Not_applicable_for_this_education_4__c &&
            !this.pDesign.Tools_integrated_to_sustain_change_4__c){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.gFRS_ProgramDesign4thQuestion + ': you must specify a value.' ));
            result = false;
        }
        return result;
    }

    /**
    * @author ADMD Dev Team 
    * @date 17/03/2016
    * @description createThirdPartyIfNotExists method - creates Third Party record if not exists
    */
    public void createThirdPartyIfNotExists(){
        List<gFRS_Third_Party__c> requestThirdParties = 
            new List<gFRS_Third_Party__c>([SELECT id
                                            FROM  gFRS_Third_Party__c
                                            WHERE Funding_Request__c =: this.fundReq.id                     
                                     ]);
            if(requestThirdParties.size() == 0){
                gFRS_Third_Party__c thirdPartyItem = new gFRS_Third_Party__c(Funding_Request__c=fundReq.id);
                insert thirdPartyItem;
            }
    }

    /**
    * @author ADMD Dev Team 
    * @date 17/03/2016
    * @description showThirdParty method - checks if third party should be displayed
    */
    public Boolean showThirdParty {
        get {
            return(gFRS_Util.YES.equals( this.fundReq.Will_You_be_Working_With_a_3rd_Party__c ) );
        }
    }

    /**
    * @author ADMD Dev Team 
    * @date 17/03/2016
    * @description back method - goes back to application page
    */
    public PageReference back(){

        if(showThirdParty){
            createThirdPartyIfNotExists();
            return( new ApexPages.PageReference( gFRS_Util.initializeLink( PATH_THIRDPARTY, this.fundReq, '' ) ));
        } else {
            return( new ApexPages.PageReference( gFRS_Util.initializeLink( PATH_APPLICATION, this.fundReq, '' ) ));
        }
    }

    /**
    * @author ADMD Dev Team 
    * @date 18/03/2016
    * @description back method - goes back to application page
    */
    public PageReference next(){
        return( new ApexPages.PageReference( gFRS_Util.initializeLink( PATH_PROGRAM, this.fundReq, '' ) ));
        
    }

}