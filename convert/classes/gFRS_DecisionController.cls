/**
* @author GFRS Dev Team
* @date 26/08/2013
* @description gFRS_DecisionController class - Class that assists with determining questions for the Decision Tree.
* <p>FOR TESTING PURPOSES ONLY - older decision page that does not filter based on internal/external users</p>
*/
public with sharing class gFRS_DecisionController {

    //-- lookup constants
    public static final String FILTER_QUESTION = 'Question';
    public static final String FILTER_ANSWER = 'Answer';
    public static final String CONTENT_TYPE = 'Funding Request';
    public static final String CONTENT_TYPE_ORGANIZATION = 'Organization';
    public static final String FILTER_ERROR = 'Errors';
    public static final String FILTER_INTERNAL = 'Internal Funding Request';
    public static final String FILTER_EXTERNAL = 'RequestType';

    public static final String TRANSLATION_INTERNAL_ONLY = 'FundingRequestInternalOnly';

    public static final String TYPE_EXHIBITS_OTHER_PROMO = 'Exhibits_Other_Promos';
    public static final String TYPE_EXHIBITS_PROMO_SPONSOR = 'Exhibits_Promo_Sponsorship';
    public static final String TYPE_SCI_PIPELINE_EXHIBITS_BOOTH = 'Sci_Pipeline_Exhibits_booth';
    public static final String TYPE_SCI_PIPELINE_EXHIBITS_SPONSOR = 'Sci_Pipeline_Exhibits_sponsorship';

    /** List of translations **/
    public Map<String,String> contentItems { get; set; }

    public static final String SAMPLE_RESULT = '[Description about the Request Type chosen and its implications]';

    /** Location of the next page **/
    public static final String PATH_COMPLETE = '/apex/GFRS_Application';

    /** Location to go back a page **/
    public static final String PATH_BACK = '/apex/GFRS_Org_Info';

    /** Error Page **/
    public static final String ERROR_INVALID_LOC = '/apex/GFRS_Error?code=' + gFRS_ErrorController.CODE_INV_FUND;
    public static final String ERROR_BLACKLIST_LOC = '/apex/gFRS_Error?' + gFRS_ErrorController.PARAM_ERROR_CODE + '=' + gFRS_ErrorController.CODE_BLACKLIST;
    public static final String ERROR_RECONCILIATON_DUE = '/apex/GFRS_Error?code=' + gFRS_ErrorController.CODE_RECONCILIATION_DUE;
    public static final String ERROR_REFUND_DUE = '/apex/GFRS_Error?code=' + gFRS_ErrorController.CODE_REFUND_DUE;
    public static final String ERROR_W9W8_MISSING ='/apex/GFRS_Error?code=' + gFRS_ErrorController.CODE_W9W8_MISSING;
    public static final String ERROR_SUNSHINE_DUE = '/apex/GFRS_Error?code=' + gFRS_ErrorController.CODE_SUNSHINE_DUE;
    public static final String ERROR_EVALUATIONS_DUE = '/apex/GFRS_Error?code=' + gFRS_ErrorController.CODE_EVALUATIONS_DUE;
    public static final String ERROR_ANNUAL_EVALUATION_DUE = '/apex/GFRS_Error?code=' + gFRS_ErrorController.CODE_ANNUAL_EVALUATION_DUE;

    /** GET orgId parameter **/
    public static final String PARAM_ORG_ID = 'org';

    /** GET Location parameter **/
    public static final String PARAM_LOC_ID = 'loc';

    /** DEFAULT funding request statuses **/
    public static final String DEFAULT_STATUS = 'Intake';
    public static final String DEFAULT_SUB_STATUS = 'Not Submitted';

    //-- local variables
    /** Organization id **/
    public String organizationId;

    /** Location id **/
    public String locationId;

    /** Whether the user is internal or external **/
    public Boolean isInternal { get; set; }

    /** Whether decision tree should be internal **/
    public Boolean isInternalDecisionTree { get; set; }

    /** Organizationthe user belongs to **/
    public GFRS_Organization__c userOrganization { get; set; }

    /** Funding request context **/
    public GFRS_Funding_Request__c fundReq { get; set; }

    /** The first Question **/
    public gFRS_DecisionQuestion q1 { get; set; }

    /** The LITERAL error message - that includes html code **/
    public String literalError { get; set; }

    /** The error message to provide if the funding request is internally accessible only **/
    public String internalOnlyErrorMessage;

    public id q1AnswerId { get; set; }

    /** The selected answer from the first question **/
    public GFRS_Content_Translation__c q1Answer { get; set; }

    /** The second question **/
    public gFRS_DecisionQuestion q2 { get; set; }

    /** The selected answer for the second question **/
    public GFRS_Content_Translation__c q2Answer { get; set; }

    /** the content translation for the final result **/
    public GFRS_Content_Translation__c response { get; set; }

    public Boolean isShutdown { get; private set; }
    public String shutdownMessage { get; private set; }

    /** The result description **/
    public String responseBlock {
        get {
            System.debug( 'isInternal:' + this.isInternal + ', isResponseInternalOnly:' + isResponseInternalOnly );
            if( this.response == null ){
                return( null );
            } else if( isResponseInternalOnly && !this.isInternal ){
                return( this.response.TextBlock__c + this.internalOnlyErrorMessage );
            } else {
                return( this.response.TextBlock__c );
            }
        }
    }

    /** Whether the result is internal only **/
    public Boolean isResponseInternalOnly {
        get {
            if( this.response == null ){
                return( false );
            } else {
                System.debug( 'content.Filter__c:[' + this.response.GFRS_Content__r.Filter__c + '] internalTYpe[' + FILTER_INTERNAL + ']' );
                return( this.response != null && this.response.GFRS_Content__r.Filter__c == FILTER_INTERNAL );
            }
        }
    }

    /**
     *  Whether the second question should be shown
     **/
    public Boolean shouldShowQ2 {
        get {
            System.debug( 'q2:' + (this.q2 != null?'Is not null':'isNull' ));
            return( this.q2 != null && this.q2.contentQuestion != null );
        }
    }

    /**
     *  Whether the third question should be shown
     **/
    public Boolean shouldShowResult {
        get {
            //System.debug( 'response:' + (this.response != null?'Is not null':'isNull' ));
            return( this.response != null );
        }
    }

    //-- getters / setters

    public gFRS_DecisionController( ApexPages.StandardController std ){
        this.contentItems = gFRS_ContentTranslationUtil.fetchContentTranslationsByFilter( CONTENT_TYPE, UserInfo.getLanguage() );

        //-- determine if the user is internal or external
        Contact userContact = gFRS_Util_NoShare.getUserContact(UserInfo.getUserId());
        this.isInternal = userContact == null; //= false; //-- may need to be set to always true or false until the profiles are fixed.

        //this.isInternalDecisionTree = this.isInternal && !gFRS_Util.isFieldSalesUser(UserInfo.getUserId());
        this.isInternalDecisionTree = (this.isInternal && !gFRS_Util.isFieldSalesUser(UserInfo.getUserId()) && !gFRS_Util.isSystemAdministrator(UserInfo.getUserId())) ? true : false;
        //-- get both the question and the answers
        this.q1 = new gFRS_DecisionQuestion( null, this.isInternalDecisionTree);

        this.q2 = null;
        this.response = null;
        /* GFRS-743 - set a FIE as default answer for users with profile ending with -CS or -DM and hide other options */
        /* GFRS-1032 FIE Decision Tree for CC Field Roles */
        /* GFRS-915 : GNE-SFA-%-CS and GNE-SFA-%-DM Profiles for Ocrevus*/
        final User currentUser = gFRS_Util_NoShare.getUserById(UserInfo.getUserId());
        for (GFRS_Content_Translation__c answer : currentUser.ProfileId == null || [
                SELECT Id FROM Profile WHERE Id = :currentUser.ProfileId AND (
                        Name LIKE 'GNE-SFA%CS' OR Name LIKE 'GNE-SFA%DM' OR Name LIKE 'GNE-SFA-CC%' OR Name LIKE 'GNE-SFA-%-Manager'
                ) LIMIT 1
        ].isEmpty() ? new GFRS_Content_Translation__c[]{ } : this.q1.contentAnswers.clone()) {
            if (answer.GFRS_Content__r.Name == 'InternalDecisionTreeQA4') {
                this.q1.contentAnswers = new GFRS_Content_Translation__c[]{ this.q1.selectedAnswer = answer };
                question1Answered();
                break;
            }
        }

        this.fundReq = (GFRS_Funding_Request__c)std.getRecord();
        Map<String,String> params = ApexPages.currentPage().getParameters();
        if( params != null ){
            if( params.containsKey( PARAM_ORG_ID )) organizationId = String.valueOf( params.get( PARAM_ORG_ID ));
            if( params.containsKey( PARAM_LOC_ID )) locationId = String.valueOf( params.get( PARAM_LOC_ID ));
        }

        this.userOrganization = gFRS_Util.getContactOrganization( userContact );

        System.debug( 'userContact:' + userContact + ', organization:' + userOrganization );

        //-- fetch the Internal Only error message
        this.internalOnlyErrorMessage = null;
        try {
            gFRS_Content_Translation__c translation = [ select TextBlock__c from GFRS_Content_Translation__c where GFRS_Content__r.Filter__c = :FILTER_ERROR and GFRS_Content__r.Name = :TRANSLATION_INTERNAL_ONLY limit 1];
            this.internalOnlyErrorMessage = translation.TextBlock__c;
        } catch( Exception err ){
            //-- do nothing
        }

        this.isShutdown = false;
        if(this.response != null) {
            checkShutdownRules(this.response.GFRS_Content__r.Name);
        }
    }

    public gFRS_DecisionController(){
        this.contentItems = gFRS_ContentTranslationUtil.fetchContentTranslationsByFilter( CONTENT_TYPE_ORGANIZATION, UserInfo.getLanguage() );
    }

    public void question1Answered(){
        try{
            if( this.q1.selectedAnswer != null ){

                //-- determine if there is a description (and we have a funding request type);
                this.response = getFundingDescription( this.q1.selectedAnswer.GFRS_Content__c );

                //-- reset
                this.q2 = null;
                this.literalError = null;

                if( this.response != null ){
                    //-- there is a description, and therefore at the end of the line
                } else {
                    this.q2 = new gFRS_DecisionQuestion( this.q1.selectedAnswer.GFRS_Content__c, this.isInternalDecisionTree );
                }

                System.debug('###### Q1 response.GFRS_Content__r.Name === ' + response.GFRS_Content__r.Name);
                checkShutdownRules(response.GFRS_Content__r.Name);
            }
        } catch( Exception err ){
            ApexPages.addMessages(err);
        }

        //System.debug( 'shouldShowQ2:' + this.shouldShowQ2 );
    }

    public void question2Answered(){
        try{
            this.literalError = null;
            if( this.q2.selectedAnswer != null ){
                this.response = getFundingDescription( this.q2.selectedAnswer.GFRS_Content__c );
                System.debug('###### Q2 response.GFRS_Content__r.Name === ' + response.GFRS_Content__r.Name);
                checkShutdownRules(response.GFRS_Content__r.Name);
            } else {
                this.response = null;
            }
        } catch( Exception err ){
            ApexPages.addMessages(err);
        }
    }

    private void checkShutdownRules(String requestRecordType) {
        isShutdown = false;
        shutdownMessage = '';
        if( TYPE_EXHIBITS_PROMO_SPONSOR.equals(requestRecordType) ){
            requestRecordType = TYPE_EXHIBITS_OTHER_PROMO;
        }else if(TYPE_SCI_PIPELINE_EXHIBITS_SPONSOR.equals(requestRecordType)){
            requestRecordType=gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO;
        }else if(TYPE_SCI_PIPELINE_EXHIBITS_BOOTH.equals(requestRecordType)){
            requestRecordType=gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO;
        }
        List<RecordType> recordType = [SELECT Name FROM RecordType WHERE DeveloperName =: requestRecordType AND SobjectType = 'GFRS_Funding_Request__c'];
        if(!recordType.isEmpty()) {
            gFRS_Shutdown_Rule__c shutdownRule = gFRS_Util_NoShare.checkShutdownRule(recordType.get(0).Name);
            if(shutdownRule != null) {
                isShutdown = true;
                shutdownMessage = shutdownRule.Message__c;
            }
        }
    }

    public static GFRS_Content_Translation__c getFundingDescription( id answerId ){
        try{
            GFRS_Content_Translation__c[] trans = [ select id, TextBlock__c, GFRS_Content__r.Filter__c, GFRS_Content__c, GFRS_Content__r.Name
            from GFRS_Content_Translation__c
            where GFRS_Content__c in
            ( select Type_Description__c from GFRS_Decision_Link__c where Decision_Answer__c = :answerId )
            ];
            //System.debug( 'trans:' + trans );
            if( trans.size() > 0 ){
                return( trans[0] );
            } else {
                return( null );
            }
        } catch( Exception err ){
            ApexPages.addMessages(err);
            return( null );
        }
    }

    /**
     *  Goes back a page
     **/
    public ApexPages.PageReference back(){
        return new ApexPages.PageReference( gFRS_Util.initializeLink( PATH_BACK, this.fundReq, 'org=' + this.organizationId + '&loc=' + this.locationId ) );
    }


    /**
    * @author GFRS Dev Team 
    * @date 26/08/2013
    * @description Save method - Saves the decision.
    */
    public ApexPages.Pagereference Save(){
        if( !this.validatePage() ){
            return( null );
        }
        /*
        if((this.response.GFRS_Content__r.Name == 'HC_CHAR' ||
                this.response.GFRS_Content__r.Name == 'Philanthropic' ||
                this.response.GFRS_Content__r.Name == 'Scientific_Projects' ||
                this.response.GFRS_Content__r.Name == 'Fellowships') && gFRS_Annual_EvaluationTriggerUtil.isFinalOrgAnnualEvaluationOverdue(organizationId)){
            return(new ApexPages.PageReference(ERROR_ANNUAL_EVALUATION_DUE));
        }
        */
        //-- block user if the funding requests are outstanding either on reconciliations or refunds
        System.debug( 'isInternal:' + this.isInternal );
        if(!this.isInternal && this.response.GFRS_Content__r.Name == 'IMED' && GFRS_OrgSettings__c.getOrgDefaults().Overdue_Reconciliation_Lock_Out_IMED__c){

            gFRS_Funding_Request__c[] overdueRequests = gFRS_Util_NoShare.findOverdueReconciliations();
            System.debug( 'overdueRequests:' + overdueRequests );
            if( overdueRequests != null && overdueRequests.size() > 0 ){
                System.debug( 'Overdue reconciliations:' + overdueRequests );
                return( new ApexPages.PageReference( ERROR_RECONCILIATON_DUE ));
            }

            overdueRequests = gFRS_Util_NoShare.findOverdueRefunds();
            System.debug( 'overdueRequests2:' + overdueRequests );
            if( overdueRequests != null && overdueRequests.size() > 0 ){
                System.debug( 'Overdue refunds:' + overdueRequests );
                for(gFRS_Funding_Request__c tmpFr:overdueRequests){
                    if(tmpFr.Refund_Request_Date__c!=null && tmpFr.Refund_Request_Date__c.addDays(31) <= Date.today()){
                        return( new ApexPages.PageReference( ERROR_REFUND_DUE ));
                    }
                }
            }
            /*GFRS-900 DISABLE BLOCKADE ON OVERDUE SUNSHINE
            overdueRequests = gFRS_Util_NoShare.findOverdueSunshineActDisclosures();
            System.debug( 'overdueRequests:' + overdueRequests );
            if( overdueRequests != null && overdueRequests.size() > 0 ){
                System.debug( 'Overdue Sunshine:' + overdueRequests );
                return( new ApexPages.PageReference( ERROR_SUNSHINE_DUE ));
            }*/
            //TODO add annual evaluations

        }


        //GFRS-301 
        Boolean blockOverdueEvaluatuionsRequest = false;
        gFRS_Funding_Request__c[] overdueRequests = gFRS_Util_NoShare.findOverdueEvaluations();

        for(gFRS_Funding_Request__c tempRequest : overdueRequests){

            if(this.response.GFRS_Content__r.Name == gFRS_Util.TYPE_HC_CHAR && tempRequest.Record_Type_Name__c == gFRS_Util.TYPE_HC_CHAR_NAME && GFRS_OrgSettings__c.getOrgDefaults().Overdue_Evaluation_Lock_Out_HC_Char__c ){
                blockOverdueEvaluatuionsRequest = true;
                break;
            }else if(this.response.GFRS_Content__r.Name == gFRS_Util.TYPE_FELLOWSHIPS && tempRequest.Record_Type_Name__c == gFRS_Util.TYPE_FELLOWSHIPS_NAME && GFRS_OrgSettings__c.getOrgDefaults().Overdue_Evaluation_Lock_Out_Fellowship__c){
                blockOverdueEvaluatuionsRequest = true;
                break;
            }else if(this.response.GFRS_Content__r.Name == gFRS_Util.TYPE_PHILANTHROPIC && tempRequest.Record_Type_Name__c == gFRS_Util.TYPE_PHILANTHROPIC_NAME && GFRS_OrgSettings__c.getOrgDefaults().Overdue_Evaluation_Lock_Out_PhilChar__c){
                blockOverdueEvaluatuionsRequest = true;
                break;
            }else if(this.response.GFRS_Content__r.Name == gFRS_Util.TYPE_SCIENTIFIC_PROJECTS && tempRequest.Record_Type_Name__c == gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME && GFRS_OrgSettings__c.getOrgDefaults().Overdue_Evaluation_Lock_Out_Scient_Prj__c){
                blockOverdueEvaluatuionsRequest = true;
                break;
            }

        }

        if(blockOverdueEvaluatuionsRequest){
            System.debug( 'Overdue Sunshine:' + overdueRequests );
            return( new ApexPages.PageReference( ERROR_EVALUATIONS_DUE ));
        }

        try{

            //-- check for blacklist
            GFRS_Organization__c objOrg =  [select Tax_id__c,Non_US_Organization_ID__c, W9_Form_W_8BEN_Form__c, Tax_Status__c,W8BEN_Status__c from GFRS_Organization__c where Id =: this.organizationId];
            String taxId = objOrg.Tax_id__c;
            String w9w8 = objOrg.W9_Form_W_8BEN_Form__c;
            String taxIdNonUS=objOrg.Non_US_Organization_ID__c;

            //Check if organization has W9/W8 uploaded
            if(objOrg.Tax_id__c ==null && objOrg.W8BEN_Status__c=='Yes')
            {
                if(objOrg.W9_Form_W_8BEN_Form__c==null){
                    return( new ApexPages.PageReference(ERROR_W9W8_MISSING));
                }
            }
            else if(objOrg.Tax_id__c !=null)
            {
                if(objOrg.W9_Form_W_8BEN_Form__c==null){
                    return( new ApexPages.PageReference(ERROR_W9W8_MISSING));
                }
            }
            System.debug('PN$$: taxId: ' + taxId);
            String requestRecordType = this.response.GFRS_Content__r.Name;
            //System.debug('PN$$: gFRS_Util.isBlacklistedOrganization: ' + gFRS_Util.isBlacklistedOrganization(taxId,requestRecordType));

            if( this.response.GFRS_Content__r.Filter__c == FILTER_ERROR ){
                //this.literalError = this.response.TextBlock__c;
                //ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, this.response.TextBlock__c ));
                //return(null);
                return( new ApexPages.PageReference( ERROR_INVALID_LOC ));
            } else if( isResponseInternalOnly && !this.isInternal ){
                return( new ApexPages.PageReference( ERROR_INVALID_LOC ));
            }else if( gFRS_Util.isBlacklistedOrganization(taxId,taxIdNonUS,requestRecordType) == true ){
                return( new ApexPages.PageReference( ERROR_BLACKLIST_LOC ));
            }




            /*--
            we normally simply provide the record type based on the content from the decision link
            however, now we require that two answers must use the same type but differ in other ways
            For this reason, we now will translate one type that is known to be different to another
            so it still creates the request of the appropriate 
            --*/
            String fSubType = gFRS_Util.Sub_Type_Exhibit_Booth;
            if( TYPE_EXHIBITS_PROMO_SPONSOR.equals( requestRecordType ) ){
                fSubType = gFRS_Util.Sub_Type_Sponsorship;
                requestRecordType = TYPE_EXHIBITS_OTHER_PROMO;
            }else if(TYPE_SCI_PIPELINE_EXHIBITS_SPONSOR.equals(requestRecordType)){
                fSubType = gFRS_Util.Sub_Type_Sponsorship;
                requestRecordType=gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO;
            }else if(TYPE_SCI_PIPELINE_EXHIBITS_BOOTH.equals(requestRecordType)){
                requestRecordType=gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO;
            }

            RecordType rt = [ SELECT id from RecordType
            where DeveloperName = :requestRecordType and SobjectType = 'GFRS_Funding_Request__c' ];

            //-- Information needed is generated based on record type
            //-- (may need to move to trigger at some point...)
            String infoNeeded = gFRS_Util.INFO_NEEDED_ORGANIZATION + ';' + gFRS_Util.INFO_NEEDED_LOCATION + ';' + gFRS_Util.INFO_NEEDED_APPLICATION + ';' + gFRS_Util.INFO_NEEDED_FILE_ATTACHMENTS;
            if( requestRecordType == gFRS_Util.TYPE_IMED || requestRecordType == gFRS_Util.TYPE_HC_CHAR ){
                infoNeeded += ';' + gFRS_Util.INFO_NEEDED_THIRD_PARTY;
            }
            if( requestRecordType == gFRS_Util.TYPE_IMED ){
                infoNeeded += ';' + gFRS_Util.INFO_NEEDED_PROGRAM_DESIGN;
            }
            if( true ){
                infoNeeded += ';' + gFRS_Util.INFO_NEEDED_PROGRAM;
            }
            if( RequestRecordType != gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS ||
                    RequestRecordType != gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS ||
                    RequestRecordType != gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS ||
                    RequestRecordType != gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO
                    ){
                infoNeeded += ';' + gFRS_Util.INFO_NEEDED_BUDGET;
            }
            if( RequestRecordType == gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS ||
                    RequestRecordType == gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS ||
                    RequestRecordType == gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS ||
                    RequestRecordType == gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO
                    ){
                //no action required
            }
            else {
                infoNeeded += ';' + gFRS_Util.INFO_NEEDED_PAYMENT_METHOD;
            }
            
            //JIRA -159
          
            Profile userProfile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId()];
            String boUserchk=null;

            GFRS_Funding_Request__c fundingRequest=null;
            if(RequestRecordType == gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS || RequestRecordType == gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO){
                fundingRequest = new GFRS_Funding_Request__c( recordTypeId = rt.id,
                        //Name = 'Request ' + DateTime.now().format( 'MM/dd/yyyy' ),
                        Status__c = DEFAULT_STATUS,
                        Sub_Status__c = DEFAULT_SUB_STATUS,
                        External_Sub_status__c = DEFAULT_SUB_STATUS,
                        Organization__c = this.organizationId,
                        Location__c = this.locationId,
                        Information_Needed__c = infoNeeded,              
                        Funding_Sub_Type__c = fSubType
                );
                insert fundingRequest;
            }else{
                fundingRequest = new GFRS_Funding_Request__c( recordTypeId = rt.id,
                        //Name = 'Request ' + DateTime.now().format( 'MM/dd/yyyy' ),
                        Status__c = DEFAULT_STATUS,
                        Sub_Status__c = DEFAULT_SUB_STATUS,
                        External_Sub_status__c = DEFAULT_SUB_STATUS,
                        Organization__c = this.organizationId,
                        Location__c = this.locationId,
                        Information_Needed__c = infoNeeded
                );
                
                insert fundingRequest;
                
              /*  if(userProfile.Name=='GNE-GFRS-Backoffice'){
                    GFRS_Funding_Request__c updatefundingRequest = new GFRS_Funding_Request__c();
                    updatefundingRequest.id=fundingRequest.id;
                    updatefundingRequest.Entering_on_Behalf_of_Another__c='Yes';
                    update updatefundingRequest;
                } */
            }
            
                
          

            //-- TODO: create funding request
            //throw( new CustomException( 'Error Occurred so please show this error message:' + fundingRequest.id ));

            //-- handle error conditions if the user is brought to an invalid Request State
            //TODO -- last parameter should be removed after the development analysis (now it disables the standard page validation - record type is required)
            return( new ApexPages.PageReference( gFRS_Util.initializeLink( PATH_COMPLETE, fundingRequest, 'immediate=true&loc=' + this.locationId + '&org='+this.organizationId ) ));
        } catch( Exception err ){
            ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(err) ) );
            return (null);
        }
    }

    /**
     *  Validates the page for errors.
     *  @return Boolean - whether errors occured during validation
     **/
    public Boolean validatePage(){

        if( this.response == null || this.response.GFRS_Content__r.Name == null ){
            ApexPages.addMessages( new CustomException( 'Unknown Request Type' ));
            return( false );
        }
        //-- perform validation
        return( true );
    }

    /**
    * Checks if user is related to 'Field Initiated Exhibits' profile. If yes if creates Funding Request and redirects to Application page.
    * @return ApexPages.PageReference
    **/
    public ApexPages.PageReference checkValidPage(){
        if( gFRS_Util.isFieldSalesUser(UserInfo.getUserId()))
        {
            RecordType rt = [ SELECT id from RecordType
            where DeveloperName =: gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS and SobjectType = 'GFRS_Funding_Request__c' ];

            //-- Information needed is generated based on record type
            String infoNeeded = gFRS_Util.INFO_NEEDED_ORGANIZATION + ';' + gFRS_Util.INFO_NEEDED_LOCATION + ';' + + gFRS_Util.INFO_NEEDED_APPLICATION + ';' + gFRS_Util.INFO_NEEDED_FILE_ATTACHMENTS + ';' + gFRS_Util.INFO_NEEDED_PROGRAM;

            system.debug('this.userOrganization.Tax_ID__c=>'+ this.userOrganization.Tax_ID__c);
            GFRS_Organization__c objOrg =  [select Tax_id__c,Non_US_Organization_ID__c, W9_Form_W_8BEN_Form__c, Tax_Status__c,W8BEN_Status__c from GFRS_Organization__c where Id =: this.organizationId];
            String taxId = objOrg.Tax_id__c;
            String nonUSTaxId = objOrg.Non_US_Organization_ID__c;

            if( gFRS_Util.isBlacklistedOrganization( taxId,nonUSTaxId, gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS ))
            {
                return( new ApexPages.PageReference( ERROR_BLACKLIST_LOC ));
            }
            else
            {

                GFRS_Funding_Request__c fundingRequest = new GFRS_Funding_Request__c( recordTypeId = rt.id,
                        //Name = 'Request ' + DateTime.now().format( 'MM/dd/yyyy' ),
                        Status__c = DEFAULT_STATUS,
                        Sub_Status__c = DEFAULT_SUB_STATUS,
                        External_Sub_status__c = DEFAULT_SUB_STATUS,
                        Organization__c = this.organizationId,
                        Location__c = this.locationId,
                        Information_Needed__c = infoNeeded
                );

                insert fundingRequest;
                return(new ApexPages.PageReference( gFRS_Util.initializeLink( PATH_COMPLETE, fundingRequest, null )));
            }

        }
        else
        {
            return (null);
        }

    }
    public String documentationInstruction { get { return( this.contentItems.get('Documentation_Instruction')); }}
    public String reviewTimeInstruction { get { return( this.contentItems.get('Review_Time_Instruction')); }}
    public String expeditedRequestInstruction { get { return( this.contentItems.get('Expedited_Request_Instruction')); }}
    public String bundledRequestInstruction { get { return( this.contentItems.get('Bundled_Request_Instruction')); }}
    public String submitMessage { get { return( this.contentItems.get('ConfirmSubmit')); }}

    class CustomException extends Exception {}
}