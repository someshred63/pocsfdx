public with sharing class C_OPS_LOC_EXTERNAL_CONTROLLER {

    public Boolean getHasError(){
        return ApexPages.hasMessages();
    }
    private CommitChanges cc=new CommitChanges();
    // To prevent string misspellings.
    private final static String ONCOLOGY = 'Oncology';
    private final static String OPHTHALMOLOGY = 'Ophthalmology';
    private final static String RHEUMATOLOGY = 'Rheumatology';
    private final static String HospitalTYPE = 'Hospital';
    
    public integer fileSize { get; set; }
    
    // For parsing CSV
    public List<List<String>> parsedCSV { get; set; }
    public integer parsedCSVRowCount { get; set; }
    public integer parsedCSVColumnCount { get; set; }
    
    // reCaptcha 2 - added by Jie on March 31, 2019
    // to make it easy to turn on/off captcha during development
    public Boolean captchaOff { get; set; }
    public String response{get;set;}
    private String baseUrl;
    @testVisible private boolean verifyCaptcha()
    {
        
        if (this.recaptchaVerified) return true;
        
        if ( response == null | response.trim().length()==0)
        {
            //errorMsg = 'Response is null';
            return false;
        }
        
        String urlbody='secret=' + recaptchaPrivateSecret + '&response='  +  response;
        HttpResponse r = makeRequest(baseUrl, urlbody);
        
        if ( r!= null )
        {
            
            // Parse JSON response to get all the totalPrice field values.

           JSONParser parser = JSON.createParser(r.getBody());
           
           while (parser.nextToken() != null) {

            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
                (parser.getText() == 'success')) {
                // Get the value.
                parser.nextToken();
                if(parser.getText()=='true') this.recaptchaVerified = true;
            }
          }
        }else {
           // errorMsg += ' - Response 2 is null';
            return false;
        }
        
        if(this.recaptchaVerified)
        {
            // Pass verification, not robot
            
            return true;
        }
        else
        {
            // stay on page to re-try reCAPTCHA
            //errorMsg += ' - not verified';
            return false;
        }
    }
    
    @testVisible private HttpResponse makeRequest(string url, string body) 
    {
       // String tempurl='https://www.google.com/recaptcha/api/siteverify?secret=6LcPp20UAAAAAMowSOP8dB842maumm9JPNXcTMl2&response=03AHqfIOmyWq5nnqEyR5ZDjY9-fpRYOIf0j-MQg8Nk2L7KLOckbsKKfbWeeUFqTZxHGiFHpw6jRFINZ4ZDHkbTzqo6NmJays1KWvZGtjv9LA1EfM70YxLCgkpAH3bXmV5YGO9XaI8cJR_vsnoKO7Peoxe4NvbmDEz7lQfKWBEfthGO_e_xiwg-H76EszjV8Jk7Wva8zvTtsc-ikYqUPLiG5js0QzVU28IjUMWgLOWEe2uFchSLLakVqnffS_MN-IubSPV1ubbQBxEhnx8nP7muIoxN7YDoBVpZWETucsOAwv-T146qoWT6Ikc';
        HttpResponse response = null;
        HttpRequest req = new HttpRequest();  
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setBody (body);
        try
        {
            Http http = new Http();
            response = http.send(req);
           
            System.debug('reCAPTCHA response: ' + response);
            System.debug('reCAPTCHA body: ' + response.getBody());
        }
        catch(System.Exception e)
        {
            System.debug('ERROR: ' + e);
        }
        return response;
    }
    
    @testVisible private String remoteHost {
        get {
            String ret = '127.0.0.1';
            // also could use x-original-remote-host
            Map<String, String> hdrs = ApexPages.currentPage().getHeaders();
            if (hdrs.get('x-original-remote-addr')!= null)
                ret =  hdrs.get('x-original-remote-addr');
            else if (hdrs.get('X-Salesforce-SIP')!= null)
                ret =  hdrs.get('X-Salesforce-SIP');
            return ret;
        }
    } 
    //End of reCaptcha2

    // This is for the date picker.  It can only store its value in a
    // string instance variable, and not in an sObject field.  The
    // format of this is yyyy-mm-dd, which is the Salesforce standard.
    // There is also a formatted version of this string, so users can
    // see it as mm/dd/yyyy.
    public string startDate { get; set; }
    public string startDateFormatted { get; set; }
    public string startDateBlank { get; set; }
    public boolean numgenGenerated { get; set; }
    
    
    @testVisible private List<C_OPS_LOC_REQUEST__C> newRequests; 
    @testVisible private C_OPS_LOC_REQUEST__C mainRequest;
    @testVisible private C_OPS_LOC_REQUEST__C currentRequest; 
    @testVisible private C_Ops_LOC_Form_Property__c formProperty; //to be set after we determine what form the user is interacting with
    public C_Ops_LOC_Request_Number_Generator__c numGen; //we'll retrieve this during submit
    public C_OPS_LOC_REQUEST__C mainRequestResults {get;set;} 
    public List<C_OPS_LOC_REQUEST__C> newRequestsResults {get;set;}
    public list<string> childRequestIds {get;set;} //to hold the id's of the old child requests
    public boolean renderAddSites {public get; public set;} 
    public boolean isNotHospitalGPO {public get; public set;}
    public boolean recaptchaVerified {public get; public set;}
    public string  insertedID {public get; public set;} //for use by the pdf after we cycle to a new main request
    public boolean isStagingRequest {public get; public set;}
    public id queueId;
    @testVisible private C_OPS_LOC_REQUEST__C previousVersion; // for use by the edit page
    public string oldAttachmentID {get;set;} 
    public boolean isEditRequest {get;set;}
    
    //Be aware that Hospital value is falese for hospital GPO form and none hosptial form Hospital value is true
    public string hospital {        
        get; 
        
        set {            
            hospital = value; 
            formChanged = TRUE; //now we know to dump data beyond the first page 
        }
            
    }
    
    public string nonhospital {     
        get; 
                               
        set {             
            nonHospital = value;
            formChanged = TRUE; //now we know to dump data from this point on                          
         }
    }
    public string previousValue {get;set;}
    public string previousValueHospital {get;set;}
    public string addSites {get;set;}
    public boolean uploadSites{get; set;}
    public boolean formChanged {get;set;}
    
    public string uploadName {get;set;}

        // TODO: rename    
    public string jefftest {
        get {
            return ((uploadSites == null || !uploadSites) && (NewRequests == null || NewRequests.size() == 0)) ? 'true' : 'false';
        }
        set;
    }
    public string displayValues {        
        get{            
            if(addSites == 'TRUE') {                
                return 'INLINE';
            }
            
            return 'NONE';
        }
        
        set;
    }
    
    public string displayCOTOther {        
        get {
            if(mainRequest.Class_of_Trade__c == 'Other (Please Enter Below)'){                
                return 'INLINE'; 
            }
            
            return 'NONE'; 
        }
        
        set;
    }
    
    public string displayTheraArea {        
        get {            
            if(emptyString(hospital)==false && hospital=='TRUE'){                
                return 'INLINE'; 
            }
            
            return 'NONE';
        }
        
        set;
    }
    
    public string currCOTDisplay {        
        get {            
            if(currentRequest.Class_of_Trade__c == 'Other (Please Enter Below)'){                
                return 'INLINE'; 
            }
            
            return 'NONE'; 
        }
        
        set; 
    }
    
    public boolean getRenderLRPPDF() {        
        return (formProperty.Therapeutic_Area__c == OPHTHALMOLOGY);
    }
    
    public boolean getRenderHospPDF() {        
        return (hospital == 'FALSE');
    }
    
    public boolean getRenderONCPDF(){        
        return (formProperty.Therapeutic_Area__c == ONCOLOGY);
    }
    
    public boolean getRenderCOTOther(){
        
        return mainRequest.Class_of_Trade__c == 'Other (Please Enter Below)';
    }
    
    // variables for PDF file here
    public string mainID {get;set;} 
    public string participantName{get;set;}
    public string mainRequestNumber {get;set;}
    public list<string> cRequestIds {get;set;}
    public string pdfFilename {get;set;}

    // ===============================================================
    // BEGIN file upload code
    // ===============================================================    
    public Attachment wosUpload {
        get; 
                                     
        set{                                         
            Try{wosUpload = value;}
            catch(exception e)
            {
                handleError(e.getMessage());             
            }
        }
    }
    
    string previousUploadName; // for checking when canceling a file upload
    
    public string AttachmentName { get; set; }

    public PageReference initiateUpload() {
        return null;
    }
    
    public PageReference attachWos() {
        if(mainRequest == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'blah'));
            return null;
        }

        return null;
    }
    
    //JIe - for removing unused attachment from system
    @testVisible 
    public void removeUnusedAttachment(){
        Attachment att;
        if(oldAttachmentID!=null) {       
            List<Attachment> atts=[SELECT ID from Attachment where id =: oldAttachmentId];
            if (atts!=null && atts.size()>0)
               cc.deleteAttachment(atts);
            // delete atts;
            oldAttachmentID=null;
        }
        
    }
    
    public PageReference uploadWos() {
        
        if(wosUpload.Name == NULL){            
            string error = 'You must choose a file before uploading'; 
            handleError(error); 
            return ApexPages.currentPage();
        }
        
        if(wosUpload.Name.right(4) == '.csv' || wosUpload.Name.right(5) == '.xlsx' || wosUpload.Name.right(4) == '.xls'){            
            isStagingRequest = TRUE;             
            previousUploadName = wosUpload.Name;             
            this.currentRequest = new C_OPS_LOC_REQUEST__C();
            this.newRequests = new LIST<C_OPS_LOC_REQUEST__C>(); //requirement to dump manually added sites when you upload a sheet
            
            
            uploadSites = TRUE; 
            uploadName = wosUpload.Name;
            
            //load the attachment 
            if(numGen.id==null) 
                //insert numGen;
                numGen=cc.insertNumGen(numGen);
            wosUpload.ParentId = numGen.id; 
            //insert wosUpload; 
            cc.InsertAttachment(wosUpload);
            //Jie - need to clean up unused attachment before change oldAttachmentID 
            removeUnusedAttachment();
            oldAttachmentID = wosUpload.id; 
            
            wosUpload = new Attachment(); 
            
            return this.backToWhollyOwnedSites();
        }
        
        else{            
            string error = 'File Uploads are restricted to files of type .csv. Please upload a valid file type.';            
            handleError(error);             
            return ApexPages.currentPage(); 
        }
    }  
    
       
    
    // ===============================================================
    // END file upload code
    // ===============================================================

    // ===============================================================
    // BEGIN reCAPTCHA code
    // ===============================================================
    public string recaptchaToken { get; set; }
    public string recaptchaScore { get; set; }
    public string recaptchaErrorCodes { get; set; }
    
    // Load these from the other object.
    @testVisible private string recaptchaPublicSecret; //= '6Lf24JMUAAAAAGvpOszDuY1eiQRujaDzMcZeLP0-'; 
    @testVisible private string recaptchaPrivateSecret; //= '6Lf24JMUAAAAAN3C1j3Ut_CDzt2twLbHXotf9Exj';
    
    // The human/bot threshold, on a scale of 0 (bot) to 1 (human).
    // Any score lower than this will issue an error.
    decimal recaptchaThreshold = 0.80;
    
    // Needed by the visualforce page to pass to the visualforce Javascript code.
    public string getRecaptchaPublicSecret() {
        return this.recaptchaPublicSecret;
    }
    
    // The command issued by the button.
    public boolean isRecaptchaOk() {
        recaptchaVerified = true;
        return true;
        /*
        string url = 'https://www.google.com/recaptcha/api/siteverify?secret=' + this.recaptchaPrivateSecret + '&response=' + this.recaptchaToken;
        system.debug(url);
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        
        integer statusCode = response.getStatusCode();
        
        // If the request is successful, parse the JSON response.
        if (statusCode == 200) {

            // Deserialize the JSON string into collections of primitive data types.
            Map<string, object> results = (Map<string, object>)JSON.deserializeUntyped(response.getBody());
            system.debug(results);
            string success = string.valueOf(results.get('success'));
            
            // If reCAPTCHA comes back with success=false, or the score is below the threshold,
            // then process to the error page.
            if(success == 'false') {
                this.recaptchaErrorCodes = '';
                if(results.containsKey('error-codes')) {
                    object[] error_codes = (object[])results.get('error-codes');
                    for(object ec : error_codes) {

                    }
                }
                
                recaptchaVerified = false;

                return false;
            }
            
            // If reCAPTCHA comes back with success=true, and the score is above the threshold,
            // then proceed to the next page.
            else {
                this.recaptchaScore = string.valueOf(results.get('score'));
                decimal scoreNum = decimal.valueOf(this.recaptchaScore);
                
                if(scoreNum >= this.recaptchaThreshold) {
                    
                    recaptchaVerified = TRUE; 
                        
                        return true;
                } else {
                    
                    recaptchaVerified = FALSE;
                    
                    return false;
                }
            }            
        }     
        
        // Server error:  show error page.
        else {      
            //PageReference pr = Page.recaptcha_error;
            //pr.getParameters().put('error', 'Bad server response: ' + statusCode);
                //return pr;
                return false;
        }
        */
    }
    // ===============================================================
    // END reCAPTCHA code
    // ===============================================================
    
    public C_OPS_LOC_EXTERNAL_CONTROLLER() {
        
        //child requests (not staging requests which are excel bound)
        newRequests = new List<C_OPS_LOC_REQUEST__C>(); 
        
        //the parent site request
        mainRequest = new C_OPS_LOC_REQUEST__C(); 
        //additional site requests being added manually
        currentRequest = new C_OPS_LOC_REQUEST__C(); 
        
        numGen = new C_Ops_LOC_Request_Number_Generator__c();
        
        
        //set our initial boolean values
        renderAddSites = FALSE; 
        isNotHospitalGPO =  FALSE; 
        isEditRequest = FALSE; 
        isStagingRequest = FALSE;
        
        previousVersion = new C_OPS_LOC_REQUEST__C();
        
        Group g = [select id, name from group where name = 'LOC Request Queue' LIMIT 1];
        queueId = g.id; 
        
        C_OPS_LOC_APP_PROPERTIES__C prop = [SELECT ID, GClient__c, GSecurityKey__c, GSite__c FROM C_Ops_LOC_App_Properties__c where active__c=true LIMIT 1];
        if(prop !=null ){
        recaptchaPublicSecret = prop.GClient__c; 
        recaptchaPrivateSecret = prop.GSecurityKey__c; 
        baseUrl=prop.GSite__c;
        }
        this.wosUpload = new Attachment();
        
        //Temperary tuen off reCaptcha verification
        //captchaOff =true;
        
        //turn in reCaptcha verification
        captchaOff =false;
        
        //captchaOff =flase;
        if (captchaOff ) this.recaptchaVerified=true;
        else this.recaptchaVerified=false;

    }
    
    public C_OPS_LOC_EXTERNAL_CONTROLLER(ApexPages.StandardController sc) {
        Id reqId = sc.getId();
        this.mainRequest =
            [SELECT Id, Request_Type__c, LOC_Request_Number__c, Therapeutic_Area__c, Class_of_Trade__c, OwnerId
             FROM C_OPS_LOC_REQUEST__c
             WHERE Id = :reqId
             LIMIT 1];
    }

    public boolean getNotReadyToContinue(){        
        if(addSites == 'TRUE' || addSites == 'FALSE'){            
            return FALSE; 
        } else{            
            return TRUE;
        }
    }
    
    public List<C_OPS_LOC_REQUEST__C> getNewRequests(){        
        return newRequests; 
    }
    
    public C_OPS_LOC_REQUEST__C getCurrentRequest(){        
        return currentRequest; 
    }
    
    public C_OPS_LOC_REQUEST__C getMainRequest(){        
        return mainRequest;
    }
    
    public string getRequestNumber(){     
       
        return numgen.Name; 
    }
    
    public C_Ops_LOC_Form_Property__c getFormProperty(){        
        return formProperty; 
    }
    
    public boolean getSiteAddVisibility(){        
        if(AddSites == 'TRUE'){            
            return true;
        }
        
        return false;
    }
    
    public boolean getTheraArea(){        
        return isNotHospitalGPO; 
    }
    
    //from the landing page
    public pageReference startSubmission(){    
        if(!this.recaptchaVerified) {
            verifyCaptcha();
        }
        
        if(recaptchaVerified) { 
            
            /* Jie - no need to do this at this time
            List<C_Ops_LOC_Request_Number_Generator__c> numGenCheck = [SELECT id, name from C_Ops_LOC_Request_Number_Generator__c where id =: numgen.Id]; 

            if(numGenCheck.size()==1){
                
                system.debug('No creation necessary'); 
            } else{
                
               insert numGen; 
            }
            
            numGenCheck = new List<C_Ops_LOC_Request_Number_Generator__c>(); 
            */
            PageReference participantInformationEntry = New PageReference('/apex/C_OPS_LOC_PARTICIPANT_ENTRY');
            participantInformationEntry.setRedirect(false);
            return participantInformationEntry; 
            
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please verifiy reCAPTCHA before start LOC submission.'));
            return null;
        }
    }
    
    //warning regarding uploading excel dumping all current requests, no action option
    public pageReference Cancel(){        
        return null;
    }
    
    //warning regarding excel dumping all current request, acknowledge and continue
    public pageReference dumpAndUpload(){
        
        //toss out all our requests we just agreed to dump
        newRequests = new List<C_OPS_LOC_REQUEST__C>(); 
        
        //to be returned later, page where we upload
        return null;
    }
    
    public void cachePreviousVersion(){                
        if( isEditRequest ){            
            //cacheing this for our edit request
            previousVersion.Participant_s_Name__c = currentRequest.Participant_s_Name__c; 
            previousversion.Class_of_Trade__c = currentRequest.Class_of_Trade__c; 
            previousversion.Class_of_Trade_Other__c = currentrequest.Class_of_Trade_Correction__c; 
            
            previousVersion.DEA__c = currentRequest.DEA__c; 
            previousVersion.HIN__c = currentRequest.HIN__c; 
            previousVersion.X340B_ID__c = currentRequest.X340B_ID__c; 
            
            previousVersion.Address_Line_1__c = currentRequest.Address_Line_1__c; 
            previousVersion.Address_Line_2__c = currentRequest.Address_Line_2__c; 
            previousVersion.City__c = currentRequest.City__c;
            previousVersion.State__c = currentRequest.State__c; 
            previousVersion.Zip_Postal_Code__c = currentrequest.Zip_Postal_Code__c;
            
            previousVersion.Ophthalmology_ID_1__c = currentrequest.Ophthalmology_ID_1__c;
            previousversion.Ophthalmology_ID_2__c = currentRequest.Ophthalmology_ID_2__c; 
            previousVersion.LRP__c = currentRequest.LRP__c; 
        }
        
        return; 
    }
    
    private boolean emptyString(String s){
        if(s==null || s.trim().length()<=0) return true;
        else return false;
    
    }
    
    public pageReference setMainParticipant(){
        
        boolean participantError = FALSE;
        string  errorText; 
       
        
        if(recaptchaVerified){
        
            if(emptyString(mainRequest.Participant_s_Name__c)){   
                         
                participantError=TRUE; 
                errorText = 'Error: Particpants Name is required';
                handleError(errorText); 
                
            } else if(!isAlphaOnly(mainRequest.Participant_s_Name__c)){                
                participantError=TRUE; 
                errorText = 'Error: Participant Name may only contain letters';
                handleError(errorText);  
            }
            
            if(emptyString(mainRequest.Address_Line_1__c)){                
                participantError=TRUE; 
                errorText = 'Error: Address Line 1 is required';
                handleError(errorText); 
            }  else if(!isAlphaNumericOnly(mainRequest.Address_Line_1__c)){                
                participantError=TRUE; 
                errorText = 'Error: Address Line 1 may only contain Alpha-Numeric characters'; 
                handleError(errorText); 
            }
            
            if(emptyString(mainRequest.Address_Line_2__c)==false){//only check if it has a valid value if not blank since its optional            
                if(!isAlphaNumericOnly(mainRequest.Address_Line_2__c)){                
                    participantError=TRUE; 
                    errorText = 'Error: Address Line 2 may only contain Alpha-Numeric characters'; 
                    handleError(errorText);
                }
            }
            
            if(emptyString(mainRequest.City__c)){                
                participantError=TRUE;
                errorText = 'Error: City is required';
                handleError(errorText); 
            } else if(!isAlphaOnly(mainRequest.Participant_s_Name__c)){                
                participantError = TRUE; 
                errorText = 'Error: City may only contain letters';
                handleError(errorText);
            }
            
            if(emptyString(mainRequest.State__c)){                
                participantError=TRUE; 
                errorText = 'Error: State is required';
                handleError(errorText);
            }
            
            if(emptyString(mainRequest.Email__c)){                    
                participantError = TRUE;
                errorText = 'Error: E-mail is required';
                handleError(errorText); 
            } else if (!isValidEmail(mainRequest.Email__c)){                
                participantError = TRUE;
                errorText = 'Error: Invalid E-mail';
                handleError(errorText); 
            }
                
            if(emptyString(mainRequest.Phone_Number__c)){                    
                participantError = TRUE;
                errorText = 'Error: Phone is required'; 
                handleError(errorText); 
            } else if(!isValidPhone(mainRequest.Phone_Number__c)){                
                participantError = TRUE; 
                errorText = 'Error: Invalid Phone';
                handleError(errorText); 
            }
            
            if(emptyString(mainRequest.Zip_Postal_Code__c)){                
                participantError=TRUE;
                errorText = 'Error: Zip Code is required';
                handleError(errorText); 
            } else if(!(isValidZip(mainRequest.Zip_Postal_Code__c))){
                participantError=TRUE;
                errorText = 'Error: Invalid Zip Code';
                handleError(errorText);
            }
            
            if(emptyString(Hospital)){                
                participantError = TRUE; 
                errorText = 'Error: Please select GPO Affiliation Type';                
                handleError(errorText);
            }else if(Hospital == 'TRUE'){                
                if(emptyString(nonHospital)){                    
                    participantError = TRUE; 
                    errorText = 'Error: A Therapeutic area must be selected to proceed'; 
                    handleError(errorText); 
                }
                
                //now we know we have a value, update the main request with our nonhospital thera area
                mainRequest.Therapeutic_Area__c = nonHospital; 
            }
          
            if(participantError){                
                return null; //don't go forward                 
            } else{                
                if(emptyString(previousValue)==false && previousValue != nonHospital){                    
                    if( (previousValue == ONCOLOGY && nonHospital == RHEUMATOLOGY) || (previousValue == RHEUMATOLOGY && nonHospital == ONCOLOGY) ){
                        //no change necessary here since the forms are the same                        
                        //do nothing
                    }                    
                    else{                        
                        //we know the previous value isn't blank AND that the therapeutic area has changed, therefore get rid of our data
                        dumpDataPastFirstPage();
                    }                    
                } 
                
                if(emptyString(previousValueHospital)==false && previousValueHospital != hospital){                    
                    //we changed form types, 
                    //dump the data
                    dumpDataPastFirstPage(); 
                }
                
                formChanged = FALSE;
                
                if(hospital == 'TRUE'){                    
                    isNotHospitalGPO = TRUE;
                }                
                else{                    
                    isNotHospitalGPO = FALSE; 
                }
                
                setFormType(); 
                
                //set our previous value string here so when we come back we can reference it
                previousValue = nonHospital; 
                previousValueHospital = hospital;
                
                //set our date as today, random but date default is today and isn't editable later
                mainRequest.Submission_Date__c = Date.Today(); 
                
                pageReference c_ops_hospital_gpo_entry = new pageReference('/apex/C_OPS_HOSPITAL_GPO_ENTRY'); 
                c_ops_hospital_gpo_entry.setRedirect(false); 
                return c_ops_hospital_gpo_entry; 
            }
            
        }
       
        return null;
    }
    
    public pageReference setAdditionalDetails(){        
        boolean additionalDetailsError = FALSE; 
        string  errorText; 
        system.debug(recaptchaVerified);
        if(recaptchaVerified == TRUE){
            
            //if this is a hospital form
            if(formProperty.Therapeutic_Area__c == 'Hospital'){
                if(emptyString(mainRequest.Class_of_Trade__c)){                    
                    additionalDetailsError = TRUE; 
                    errorText = 'Error: Please select Class of Trade';
                    handleError(errorText);
                }
                
                if(emptyString(mainRequest.Class_of_Trade_Other__c) && mainRequest.Class_of_Trade__c == 'Other (Please Enter Below)'){                    
                    additionalDetailsError = TRUE;
                    errorText = 'Error: If Class of Trade is Other, this field requires a value.'; 
                    handleError(errorText); 
                }
                
                if(mainRequest.Class_of_Trade__c != 'Other (Please Enter Below)'){
                        
                   //clear out class of trade other when the selection is no longer other 
                   mainRequest.Class_of_Trade_Other__c = '';
                }
                
                if(emptyString(mainRequest.DEA__c)){                    
                    additionalDetailsError = TRUE; 
                    errorText = 'Error: DEA # is required'; 
                    handleError(errorText); 
                }
                
                if(emptyString(mainRequest.Current_GPO__c)){                    
                    additionalDetailsError = TRUE; 
                    errorText = 'Error: Current GPO Affiliation is required';
                    handleError(errorText);
                }
                
                //string s = string.valueOf(mainRequest.Current_Affiliation_Start_Date__c); 
                if(this.startDateBlank == 'TRUE') {
                    this.startDate = null;
                    this.startDateFormatted = null;
                }
                
                system.debug(this.startDate);
                date checker;                 
                try {
                    checker = date.valueOf(this.startDate);
                    mainRequest.Current_Affiliation_Start_Date__c = checker;
                    this.startDateFormatted = checker.month() + '/' + checker.day() + '/' + checker.year();
                }  catch(Exception e) {                    
                    additionalDetailsError = TRUE; 
                    errorText = 'Error: Current GPO Affiliation Date is required'; 
                    handleError(errorText); 
                }                
                
                /*if(emptyString(this.startDateFormatted)){                   
                    additionalDetailsError = TRUE;                     
                    if(mainRequest.Current_Affiliation_Start_Date__c == NULL){                        
                        errorText = 'Error: Current GPO Affiliation Date is required'; 
                    } 
                    
                    handleError(errorText); 
                }*/
                
                if(additionalDetailsError){                    
                    return null;                     
                } else{                    
                    pageReference c_ops_wholly_owned_sites = new PageReference('/apex/C_OPS_WHOLLY_OWNED_SITES');
                    c_ops_wholly_owned_sites.setRedirect(false); 
                    return c_ops_wholly_owned_sites; 
                }
            } else if ( formProperty.Therapeutic_Area__c == ONCOLOGY || formProperty.Therapeutic_Area__c == RHEUMATOLOGY){                
                if(emptyString(mainRequest.HIN__c)){                    
                    additionalDetailsError = TRUE; 
                    errorText = 'Error: HIN # is required'; 
                    handleError(errorText);
                }
                
                
                if(emptyString(mainRequest.Current_GPO__c)){                    
                    additionalDetailsError = TRUE; 
                    errorText = 'Error: Current GPO Affiliation is required';
                    handleError(errorText);
                }
                
                if(this.startDateBlank == 'TRUE') {
                    this.startDate = null;
                    this.startDateFormatted = null;
                }
                
                date checker;                 
                try {
                    checker = date.valueOf(this.startDate);
                    mainRequest.Current_Affiliation_Start_Date__c = checker;
                        this.startDateFormatted = checker.month() + '/' + checker.day() + '/' + checker.year();
                }  catch(Exception e) {
                    additionalDetailsError = TRUE; 
                    errorText = 'Error: Current GPO Affiliation Date is required'; 
                    handleError(errorText); 
                }  

               /* if(emptyString(this.startDate)){                   
                    additionalDetailsError = TRUE;                     
                    if(mainRequest.Current_Affiliation_Start_Date__c == NULL){                        
                        errorText = 'Error: Current GPO Affiliation Date is required'; 
                    } 
                    
                    handleError(errorText); 
                }*/
                
                if(additionalDetailsError){                    
                    return null;                    
                } else {                    
                    pageReference c_ops_wholly_owned_sites = new PageReference('/apex/C_OPS_WHOLLY_OWNED_SITES'); 
                    c_ops_wholly_owned_sites.setRedirect(false); 
                    return c_ops_wholly_owned_sites; 
                }
                
            } else if(formProperty.Therapeutic_Area__c == OPHTHALMOLOGY){  
                //Palani Jayachandran | 11/23/2022 | ROBOCOPS-1517 - Make LRP ID field as optional
                /*              
                if(emptyString(mainRequest.LRP__c)){                    
                    additionalDetailsError = TRUE; 
                    errorText = 'Error: LUCENTIS Rebate Program ID (LRP ID#) is required'; 
                    handleError(errorText);
                }
                */

                
                if(emptyString(mainRequest.Current_GPO__c)){                    
                    additionalDetailsError = TRUE; 
                    errorText = 'Error: Current GPO Affiliation is required';
                    handleError(errorText);
                }
                
                if(this.startDateBlank == 'TRUE') {
                    this.startDate = null;
                    this.startDateFormatted = null;
                }

                date checker;                 
                try {
                    checker = date.valueOf(this.startDate);
                    mainRequest.Current_Affiliation_Start_Date__c = checker;
                        this.startDateFormatted = checker.month() + '/' + checker.day() + '/' + checker.year();
                }  catch(Exception e) {
                    additionalDetailsError = TRUE; 
                    errorText = 'Current GPO Affiliation Date is required'; 
                    handleError(errorText); 
                }  

               /* if(emptyString(this.startDate) ){                   
                    additionalDetailsError = TRUE;                     
                    if(mainRequest.Current_Affiliation_Start_Date__c == NULL){                        
                        errorText = 'Current GPO Affiliation Date is required'; 
                    } 
                    
                    handleError(errorText); 
                }*/
                
                if(additionalDetailsError){                    
                    return null;                    
                } else {                   
                    
                    if(formProperty.Therapeutic_Area__c == OPHTHALMOLOGY){
                        removeDocument();
                        this.newRequests = new LIST<C_OPS_LOC_REQUEST__C>();
                        pageReference c_ops_loc_sub_summary = new PageReference('/apex/C_OPS_LOC_SUB_SUMMARY'); 
                        return c_ops_loc_sub_summary; 
                    }
                    
                    pageReference c_ops_wholly_owned_sites = new PageReference('/apex/C_OPS_WHOLLY_OWNED_SITES'); 
                    c_ops_wholly_owned_sites.setRedirect(false); 
                    return c_ops_wholly_owned_sites; 
                }
            }
        }
        
        return null; 
    }
    
    public PageReference uploadAdditionalSites() {
        return Page.C_OPS_LOC_WOS_UPLOAD;
    }
    
    public pageReference backToLanding(){
        
        pageReference c_ops_landing_page = new pageReference('/apex/C_OPS_LOC_CUST_LANDING');
        //c_ops_landing_page.setRedirect(true); //if we're going back to the first page delete our data that we've entered
        //if user navigate among pages and back to landing page, should not delete user entered data. 
        //Only when one submission is completed should remove all user entered data and back to landing page.
        c_ops_landing_page.setRedirect(false); 
        return c_ops_landing_page; 
    }
    
    public pageReference startNewSubmission(){
        
        pageReference c_ops_landing_page = new pageReference('/apex/C_OPS_LOC_CUST_LANDING');
        c_ops_landing_page.setRedirect(true); 
        return c_ops_landing_page; 
    }
    
    public pageReference backToMainParticipant(){
        
        pageReference c_ops_main_participant_page = new PageReference('/apex/C_OPS_LOC_PARTICIPANT_ENTRY');
        c_ops_main_participant_page.setRedirect(false); 
        return c_ops_main_participant_page; 
    }
    
    public pageReference backToGPOEntry(){
        this.startDate = string.valueOf(mainRequest.Current_Affiliation_Start_Date__c);
        pageReference c_ops_hospital_gpo_entry = new PageReference('/apex/C_OPS_HOSPITAL_GPO_ENTRY?d=' + startDate);
        c_ops_hospital_gpo_entry.setRedirect(false);
        return c_ops_hospital_gpo_entry;
    }
    
    public pageReference cancelUpload(){     

        if(previousUploadName != null){
            
            //we had a file previously, nothing to do here
            wosUpload = new Attachment(); 
            
        } else{
            
            //we didn't have a file previously, dump the attachment
            wosUpload = new Attachment(); 
            uploadName = NULL; 
        }
        
        pageReference c_ops_wholly_owned_sites = new PageReference('/apex/C_OPS_WHOLLY_OWNED_SITES');
        c_ops_wholly_owned_sites.setRedirect(false); 
        return c_ops_wholly_owned_sites; 
    }
    
    public pageReference backToWhollyOwnedSites(){        
        
        if(formProperty.Therapeutic_Area__c == OPHTHALMOLOGY){
            
            return backToGPOEntry(); 
        }
        
        pageReference c_ops_wholly_owned_sites = new PageReference('/apex/C_OPS_WHOLLY_OWNED_SITES');
        c_ops_wholly_owned_sites.setRedirect(false); 
        return c_ops_wholly_owned_sites; 
    }

    public pageReference backToWhollyOwnedSitesAndClearRadio(){       
        addSites = null;
        pageReference c_ops_wholly_owned_sites = new PageReference('/apex/C_OPS_WHOLLY_OWNED_SITES');
        c_ops_wholly_owned_sites.setRedirect(false); 
        return c_ops_wholly_owned_sites; 
    }
    
    public pageReference manuallyAddSite(){
        string param = ApexPages.currentPage().getParameters().get('id');
        system.debug('param: ' + param);
        
        //fixing issue raised by Avinash
        currentRequest = new C_OPS_LOC_REQUEST__C();
        
        //new request - ophthalmology requests now default to id's of the parent
        if(formProperty.Therapeutic_Area__c == OPHTHALMOLOGY){
            currentRequest.LRP__c = mainRequest.LRP__c; 
            currentRequest.Ophthalmology_ID_1__c = mainRequest.Ophthalmology_ID_1__c; 
            currentRequest.Ophthalmology_ID_2__c = mainRequest.Ophthalmology_ID_2__c;
        }
        //JIe - remove unused attachment file from system if there is any before switch to manual enter wholly own sites
        removeUnusedAttachment();
        pageReference c_ops_loc_wos_manual = new PageReference('/apex/C_OPS_LOC_WOS_MANUAL');
        c_ops_loc_wos_manual.setRedirect(false); 
        return c_ops_loc_wos_manual; 
    }
    
    public pageReference cancelManualAdd(){
        
        if(isEditRequest){
            
            //cacheing this for our edit request
            currentRequest.Participant_s_Name__c = previousVersion.Participant_s_Name__c; 
            currentRequest.Class_of_Trade__c = previousVersion.Class_of_Trade__c; 
            currentRequest.Class_of_Trade_Other__c = previousVersion.Class_of_Trade_Correction__c; 
            
            currentRequest.DEA__c = previousVersion.DEA__c; 
            currentRequest.HIN__c = previousVersion.HIN__c; 
            currentRequest.X340B_ID__c = previousVersion.X340B_ID__c; 
            
            currentRequest.Address_Line_1__c = previousVersion.Address_Line_1__c; 
            currentRequest.Address_Line_2__c = previousVersion.Address_Line_2__c; 
            currentRequest.City__c = previousVersion.City__c;
            currentRequest.State__c = previousVersion.State__c; 
            currentRequest.Zip_Postal_Code__c = previousVersion.Zip_Postal_Code__c;
            
            currentRequest.Ophthalmology_ID_1__c = previousVersion.Ophthalmology_ID_1__c;
            currentRequest.Ophthalmology_ID_2__c = previousVersion.Ophthalmology_ID_2__c; 
            currentRequest.LRP__c = previousVersion.LRP__c;
            
            PreviousVersion = new C_OPS_LOC_REQUEST__C(); 
        }
        
        isEditRequest = FALSE; 
        
        pageReference c_ops_wholly_owned_sites = new PageReference('/apex/C_OPS_WHOLLY_OWNED_SITES');
        c_ops_wholly_owned_sites.setRedirect(false); 
        return c_ops_wholly_owned_sites; 
    }
    
    public pageReference popUpContinue(){
        // this is coming from the 'no sites' confirmation popup dialog
        newRequests = new List<C_OPS_LOC_REQUEST__C>();
        wosUpload = new Attachment();         
        uploadSites = FALSE; 
        addSites = 'FALSE';

        PageReference c_ops_loc_sub_confirm = new PageReference('/apex/C_OPS_LOC_SUB_SUMMARY');
        return c_ops_loc_sub_confirm; 
    }
    
    public pageReference continueToConfirmation(){        
        boolean errorEncountered = FALSE;
        string errorText; 
        
        errorText = verifyChildRequests(); 
        
        //clean up the opthalmology child requests if they exist
        if(formProperty.Therapeutic_Area__c == OPHTHALMOLOGY){
            
            for(C_OPS_LOC_REQUEST__C r: newRequests){
                
                r.OPHTHALMOLOGY_ID_1__c = mainRequest.Ophthalmology_ID_1__c; 
                r.OPHTHALMOLOGY_ID_2__c = mainRequest.Ophthalmology_ID_2__c; 
                r.LRP__C = mainRequest.LRP__c; 
            }
        }
        
        if(errorText != ''){
            
            handleError(errorText); 
            return null;
        }
        
        if(recaptchaVerified){        
            if(emptyString(addSites)){                
                errorEncountered = TRUE; 
                errorText = 'Error: You must choose whether or not to add wholly owned sites to continue';                    
                handleError(errorText);                
                return null; 
            }
            
            pageReference c_ops_loc_sub_summary = new PageReference('/apex/C_OPS_LOC_SUB_SUMMARY');
            c_ops_loc_sub_summary.setRedirect(false); 
            return c_ops_loc_sub_summary;
        }
        
        return null;
    }
    
    public boolean getRenderWhollyOwnedSitesLink(){
        
        if(formProperty.Therapeutic_Area__c == OPHTHALMOLOGY){
            
            return false; 
        }
        
        return true; 
    }
    
    public pageReference commitManualSite(){
        uploadSites = FALSE; 
        wosUpload = new Attachment();        
        boolean manualSiteError = FALSE;
        string errorText; 
        
        if(recaptchaVerified){
        
            if(formProperty.Therapeutic_Area__c == 'Hospital'){
                
                if(emptyString(currentRequest.DEA__C)){                    
                    manualSiteError = TRUE;
                    errorText = 'Error: DEA # is required'; 
                    handleError(errorText);
                }
                
                if(emptyString(currentRequest.Class_of_Trade__c)){                    
                    manualSiteError = TRUE; 
                    errorText ='Error: Please select Class of Trade';
                    handleError(errorText); 
                } else if(currentRequest.Class_of_Trade__c == 'Other (Please Enter Below)' && emptyString(currentRequest.Class_of_Trade_Other__c)){                    
                    manualSiteError = TRUE; 
                    errorText ='Error: Please provide an explanation';
                    handleError(errorText);
                }
                
                if(currentRequest.Participant_s_Name__c == NULL){                    
                    manualSiteError = TRUE; 
                    errorText = 'Error: Participants Name is required'; 
                    handleError(errorText); 
                }
                
                if(currentRequest.Address_Line_1__c == NULL ){                    
                    manualSiteError = TRUE; 
                    errorText = 'Error: Address Line 1 is required'; 
                    handleError(errorText); 
                }
                
                if(currentRequest.City__c == NULL){                    
                    manualSiteError = TRUE; 
                    errorText = 'Error: City is required'; 
                    handleError(errorText);
                }
                
                if(currentRequest.State__c == NULL){                    
                    manualSiteError = TRUE; 
                    errorText = 'Error: State is required'; 
                    handleError(errorText);
                }
                
                if(currentRequest.Zip_Postal_Code__c != NULL){                    
                    if(!isValidZip(currentRequest.Zip_Postal_Code__c)){                    
                        manualSiteError = true;
                        errorText = 'Error: Invalid Zip Code';
                        handleError(errorText); 
                    }
                } else{                    
                    manualSiteError = true;
                    errorText = 'Error: Invalid Zip Code';
                    handleError(errorText);
                }
                 
               if(currentRequest.Class_of_Trade__c != 'Other (Please Enter Below)'){                        
                   //clear out class of trade other when the selection is no longer other 
                   currentRequest.Class_of_Trade_Other__c = '';
                }
                
                if(manualSiteError){                    
                    return null;
                }
                
                else{                    
                    isStagingRequest = FALSE; 
                    
                    //getting rid of our upload if we have one
                    uploadName = '';
                    
                    //first pass on required fields are met
                    if(newRequests.contains(currentRequest)){ //if this is an edit not a save, don't add to the list
                        //do nothing since our changes are already in place
                    } else{
                        newRequests.Add(currentRequest);
                    }
                    
                    currentRequest = new C_OPS_LOC_REQUEST__C(); //since we're now on to a different one                    
                    renderAddSites = TRUE;                     
                    pageReference c_ops_wholly_owned_sites = new PageReference('/apex/C_OPS_WHOLLY_OWNED_SITES'); 
                    c_ops_wholly_owned_sites.setRedirect(false);
                    return c_ops_wholly_owned_sites;
                }
            }
            
            if(formProperty.Therapeutic_Area__c == ONCOLOGY || formProperty.Therapeutic_Area__c == RHEUMATOLOGY){                
                currentRequest.Therapeutic_Area__c = formProperty.Therapeutic_Area__c; 
                
                if(emptyString(currentRequest.Participant_s_Name__c)){                    
                    manualSiteError = TRUE; 
                    errorText = 'Error: Participant Name is required'; 
                    handleError(errorText); 
                }
                
                if(emptyString(currentRequest.Address_Line_1__c)){                    
                    manualSiteError = TRUE; 
                    errorText = 'Error: Address Line 1 is required'; 
                    handleError(errorText); 
                }
                
                if(emptyString(currentRequest.City__c)){                    
                    manualSiteError = TRUE; 
                    errorText = 'Error: City is required'; 
                    handleError(errorText); 
                }
                
                if(emptyString(currentRequest.State__c)){                    
                    manualSiteError = TRUE; 
                    errorText = 'Error: State is required'; 
                    handleError(errorText);
                }
                
                if(currentRequest.Zip_Postal_Code__c != NULL){                    
                    if(!isValidZip(currentRequest.Zip_Postal_Code__c)){                    
                        manualSiteError = true;
                        errorText = 'Error: Invalid Zip Code';
                        handleError(errorText); 
                    }
                } else{                    
                    manualSiteError = true;
                    errorText = 'Error: Invalid Zip Code';
                    handleError(errorText); 
                }
                
                if(emptyString(currentRequest.HIN__c)){                    
                    manualSiteError = true; 
                    errorText = 'Error: HIN # is required'; 
                    handleError(errorText);
                }
                
                if(manualSiteError){                    
                    return null;
                }
                
                else{                    
                    isStagingRequest = FALSE; 
                    
                    //first pass on required fields are met
                    if(newRequests.contains(currentRequest)){ //if this is an edit not a save, don't add to the list
                        //do nothing since our changes are already in place
                    } else{
                        newRequests.Add(currentRequest);
                    }
                    
                    currentRequest = new C_OPS_LOC_REQUEST__C(); //since we're now on to a different one                    
                    renderAddSites = TRUE;                     
                    pageReference c_ops_wholly_owned_sites = new PageReference('/apex/C_OPS_WHOLLY_OWNED_SITES'); 
                    c_ops_wholly_owned_sites.setRedirect(false);
                    return c_ops_wholly_owned_sites;
                }
            }
            
            if(formProperty.Therapeutic_Area__c == OPHTHALMOLOGY){                
                currentRequest.Therapeutic_Area__c = formProperty.Therapeutic_Area__c;
                
                if(emptyString(currentRequest.Participant_s_Name__c)){                    
                    manualSiteError = TRUE; 
                    errorText = 'Error: Participants Name is required'; 
                    handleError(errorText);
                }
                
                if(emptyString(currentRequest.Address_Line_1__c)){                    
                    manualSiteError = TRUE; 
                    errorText = 'Error: Address Line 1 is required'; 
                    handleError(errorText);
                }
                
                if(emptyString(currentRequest.City__c)){                    
                    manualSiteError = TRUE; 
                    errorText = 'Error: City is required'; 
                    handleError(errorText); 
                }
                
                if(emptyString(currentRequest.State__c)){                    
                    manualSiteError = TRUE; 
                    errorText = 'Error: State is required'; 
                    handleError(errorText); 
                }
                
                if(currentRequest.Zip_Postal_Code__c != NULL){                    
                    if(!isValidZip(currentRequest.Zip_Postal_Code__c)){                    
                        manualSiteError = true;
                        errorText = 'Error: Invalid Zip Code';
                        handleError(errorText);
                    }
                } else{                    
                    manualSiteError = true;
                    errorText = 'Error: Invalid Zip Code';
                    handleError(errorText);
                }

                //Palani Jayachandran | 11/23/2022 | ROBOCOPS-1517 - Make LRP ID field as optional
                /*
                if(emptyString(currentRequest.LRP__C)){                    
                    manualSiteError = true; 
                    errorText = 'Error: Lucentis Rebate Program ID (LRP ID#) is required'; 
                    handleError(errorText);
                }
                */
                
                if(emptyString(currentRequest.Ophthalmology_ID_1__c)){                    
                    manualSiteError = true; 
                    errorText = 'Error: Specialty Distributor Name(s) is required'; 
                    handleError(errorText);
                }
                
                if(emptyString(currentRequest.Ophthalmology_ID_2__c)){                    
                    manualSiteError = true; 
                    errorText = 'Error: Specialty Distributor Account(s) is required';
                    handleError(errorText); 
                }
                
                if(manualSiteError){                    
                    return null;
                }
                
                else{
                    
                    isStagingRequest = FALSE; 
                    
                    //first pass on required fields are met
                    if(newRequests.contains(currentRequest)){ //if this is an edit not a save, don't add to the list
                        //do nothing since our changes are already in place
                    } else{
                        newRequests.Add(currentRequest);
                    }
                    
                    currentRequest = new C_OPS_LOC_REQUEST__C(); //since we're now on to a different one                    
                    renderAddSites = TRUE;                     
                    pageReference c_ops_wholly_owned_sites = new PageReference('/apex/C_OPS_WHOLLY_OWNED_SITES'); 
                    c_ops_wholly_owned_sites.setRedirect(false);
                    return c_ops_wholly_owned_sites;
                }
            }            
        }    
        
        return null; //if you aren't one of the 4 options we have issues
    }
    
    public pageReference setFormType(){        
        //to do, set property based on previous page 
        if(isNotHospitalGPO == FALSE){            
            //means we're dealing with a hospital GPO
            formProperty = [SELECT Attestation_Language__c, ID, NAME, Certification_Language__c, Affiliation_Legal_Language__c,  Therapeutic_Area__c, checkbox_language_single_site__c, Checkbox_Language_Multiple_Sites__c from C_Ops_LOC_Form_Property__c 
                                where Therapeutic_Area__C = 'Hospital' and  Is_Active__c=True LIMIT 1]; 
        }
        
        else{            
            formProperty = [SELECT Attestation_Language__c,ID, NAME, Certification_Language__c, Affiliation_Legal_Language__c, Therapeutic_Area__c, checkbox_language_single_site__c, Checkbox_Language_Multiple_Sites__c from C_Ops_LOC_Form_Property__c 
                                where Therapeutic_Area__C =: nonHospital and Is_Active__c=True LIMIT 1];
        }
        
        return null; 
    }
    
    public pageReference editWhollyOwnedSite(){        
        isEditRequest = true;                 
        string requestToEdit = ApexPages.currentPage().getParameters().get('editName'); 
        
        //now we need to assign the current request to one of the elements in the list
        for(C_OPS_LOC_REQUEST__C r: newRequests){            
            if(r.Participant_s_Name__c == requestToEdit){
                currentRequest = r; 
            }
        }
        
        pageReference c_ops_loc_wos_manual = new PageReference('/apex/c_ops_loc_wos_manual'); 
        c_ops_loc_wos_manual.setRedirect(false);
        return c_ops_loc_wos_manual;
    }
    
    public pageReference removeWhollyOwnedSite(){
        string requestToRemove = ApexPages.currentPage().getParameters().get('removeName');
        
        List<C_OPS_LOC_REQUEST__C> replacementList = new List<C_OPS_LOC_REQUEST__C>();         
        for(C_OPS_LOC_REQUEST__C r: newRequests){            
            if(r.Participant_s_Name__c != requestToRemove){ //not our request, therefore safe to add                
                replacementList.add(r); 
            }
        }
        
        //all elements outside of the one to be removed now exist in the replacement list
        //make that the main list and all is well
        
        newRequests = replacementList;
        
        if(replacementList.size() == 0) {
            addSites = null;
        }
        
        return null;
    }
    
    public pageReference moveToPrintSummary(){

        pageReference c_ops_loc_summary_pdf = new PageReference('/apex/c_ops_loc_summary_pdf'); 
        c_ops_loc_summary_pdf.getParameters().put('id',mainRequestResults.id); 
        c_ops_loc_summary_pdf.setRedirect(true); 
        
        return c_ops_loc_summary_pdf; 
       
        //pageReference C_OPS_LOC_PRINT_SUMMARY = new PageReference('/apex/C_OPS_LOC_SUMMARY_PRINT_VIEW'); 
        //return C_OPS_LOC_PRINT_SUMMARY; 
    }
    
    public pageReference moveToStgPrintSummary(){

        pageReference c_ops_loc_stg_summary_pdf = new PageReference('/apex/c_ops_loc_stg_summary_pdf'); 
        c_ops_loc_stg_summary_pdf.getParameters().put('id',insertedid); 
        c_ops_loc_stg_summary_pdf.setRedirect(true); 
        
        return c_ops_loc_stg_summary_pdf; 
        
        //pageReference C_OPS_LOC_PRINT_SUMMARY = new PageReference('/apex/C_OPS_LOC_SUMMARY_PRINT_VIEW'); 
        //return C_OPS_LOC_PRINT_SUMMARY; 
    }
    
    
    public pageReference saveAndSubmit(){        
        boolean submitError = FALSE; 
        string errorText; 
        
        if(recaptchaVerified){        
            if(emptyString(mainRequest.Signer_First_Name__c)){                
                submitError = TRUE; 
                errorText = 'Error: First Name in the Participants Certification section is required';
                handleError(errorText);
            }
            
            if(emptyString(mainRequest.Signer_Last_Name__c)){                
                submitError = TRUE; 
                errorText = 'Error: Last Name in the Participants Certification section is required'; 
                handleError(errorText);
            }
            
            if(emptyString(mainRequest.Signer_Title__c)){                
                submitError = TRUE; 
                errorText = 'Error: Title in the Participants Certification section is required';
                handleError(errorText);
            }
            
            if(mainRequest.Attestation_signed__c != TRUE){
                
                submitError = TRUE; 
                errorText = 'Error: You must acknowledge signing authority by checking the box'; 
                handleError(errorText);
            }
            
            if(!submitError){   
                //create request reference number and get it now 
                if (numGen.id==null) //insert numGen;
                   
                numGen=cc.insertNumGen(numGen);
                 
                
                            
                //sanity check if I missed a control path
               if(newRequests.size() > 0){
                    //any child requests means that this isn't going into the staging object
                    isStagingRequest = FALSE; 
                }
               
                if(!isStagingRequest){                    
                    
                    /*      What needs to happen for each newRequest
                     * 1. Set the request Number
                     * 2. Set the parent request
                     * 3. Set the Request Type. For hospital form properties it's hospital. 
                     * 4. Align Singer Information on child requests
                     * */
                    
                    mainRequest.Is_Parent_Location__c = TRUE; 
                    mainRequest.LOC_Request_Number__c = numGen.Name;
                    mainRequest.Request_Status__c = 'New'; 
                    //assign this to the queue
                    mainRequest.Ownerid = queueID; 
                    
                    if(!isNotHospitalGPO){
                        
                        mainRequest.Request_Type__c = HospitalTYPE ; 
                        mainRequest.Therapeutic_Area__c=null;
                    }
                    
                    else{ //grab our therapeutic area from earlier
                        
                        mainRequest.Therapeutic_Area__c = nonHospital;
                        mainRequest.Request_Type__c = mainRequest.Therapeutic_Area__c;
                    }
                    

                    runValidations();

                    //parent request in first, so the look-up fields on the children resolve correctly
                    //insert mainRequest; 
                    cc.insertMainRequest(mainRequest);
                    //aligning child requests to parent request
                    //for fields where child request doesn't have an input option
                    for(C_OPS_LOC_REQUEST__C r : newRequests){
                        
                        r.Parent_Request__c = mainRequest.id; 
                        r.LOC_Request_Number__c = mainRequest.LOC_Request_Number__c; 
                        r.Signer_First_Name__c = mainRequest.Signer_First_Name__c; 
                        r.Signer_Last_Name__c = mainRequest.Signer_Last_Name__c; 
                        r.Signer_Title__c = mainRequest.Signer_Title__c; 
                        r.Request_Type__c = mainRequest.Request_Type__c; 
                        r.Therapeutic_Area__c= mainRequest.Therapeutic_Area__c;
                        r.OwnerId = mainRequest.OwnerId; 
                        r.Current_Affiliation_Start_Date__c = mainRequest.Current_Affiliation_Start_Date__c; 
                        r.Current_GPO__c = mainRequest.Current_GPO__c;
                        r.Previous_GPO__c = mainRequest.Previous_GPO__c; 
                        r.Submission_Date__c = mainRequest.Submission_Date__c; 
                        r.Attestation_signed__c = mainRequest.Attestation_signed__c;
                        r.Email__c = mainRequest.Email__c;
                        r.request_status__C = mainRequest.Request_Status__c; 
                        //child location checkbox is just inverse of parent checkbox so no need to set
                        
                        //Jie 4-22-2019 - copy over all participant information from parent request
                        r.Phone_Number__c= mainRequest.Phone_Number__c; 
                        
                    }
                    
                    //insert newRequests; 
                    cc.insertNewRequests(newRequests);
                    C_OPS_LOC_EMAIL_CONFIRM emailConfirmation = new C_OPS_LOC_EMAIL_CONFIRM(mainRequest); 
                    emailConfirmation.sendEmailConfirmation(); 
                    
                    insertedID = mainRequest.ID; //so we can reference this for our pdf later
                    
                    childRequestIds = new List<String>(); 
                    
                    for(C_OPS_LOC_REQUEST__C r: newRequests){
                        
                        childRequestIDs.Add(r.id); 
                    }
                    
                    /*
                     * prepare PDF file NAme
                     * */
                    string requiredIDType; 
                    
                    if(mainRequest.Therapeutic_Area__c == NULL){                        
                        requiredIDType = 'DEA';
                    } else if(mainRequest.Therapeutic_Area__c == OPHTHALMOLOGY){                        
                        requiredIDType = 'LRP'; 
                    } else if(mainRequest.Therapeutic_Area__c == ONCOLOGY || mainRequest.Therapeutic_Area__c == RHEUMATOLOGY){                        
                        requiredIDType = 'HIN'; 
                    }
                    
                    string idValue;
                    
                    if(requiredIDType == 'DEA'){                        
                        idValue = mainRequest.DEA__c; 
                    } else if(requiredIDType =='LRP'){                        
                        idValue = mainRequest.LRP__c;
                    } else if(requiredIDType == 'HIN'){                        
                        idValue = mainRequest.HIN__c; 
                    }
                    
                    string fileName = mainRequest.Participant_s_Name__c.left(15) + '_' + idValue + '_' + mainRequest.LOC_Request_Number__c; 
                    
                    mainid = insertedID; 
                    participantName = mainRequest.Participant_s_Name__c; 
                    mainRequestNumber = mainRequest.LOC_Request_Number__c; 
                    cRequestIDs = childRequestIDs; 
                    pdfFileName = fileName; 
                    
                    //now that all our loose ends are tied up, lets shift to the results set and dump our old data so we can't resubmit
                    mainRequestResults = mainRequest;
                    mainRequest = new C_OPS_LOC_REQUEST__C(); 
                    
                    newRequestsResults = newRequests;
                    newRequests = new List<C_OPS_LOC_REQUEST__C>(); 
                    
                    pageReference c_ops_loc_pdf_generator = new pageReference('/apex/c_ops_loc_pdf_generator'); 
                    c_ops_loc_pdf_generator.getParameters().put('id', insertedID);
                    return c_ops_loc_pdf_generator;
                }
                
                else{
                    
                    mainRequest.LOC_Request_Number__c = numGen.Name; 
                    //assign this to the queue
                    mainRequest.Ownerid = queueID; 
                    
                    if(!isNotHospitalGPO){
                        
                        mainRequest.Request_Type__c = HospitalTYPE ; 
                        mainRequest.Therapeutic_Area__c=null;
                    }
                    
                    else{ //grab our therapeutic area from earlier
                        
                        mainRequest.Therapeutic_Area__c = nonHospital;
                        mainRequest.Request_Type__c = mainRequest.Therapeutic_Area__c;
                    }
                    
                    runValidations();
                    
                    C_Ops_LOC_Request_Staging__C stage; 
                    
                    stage = convertToStagingRequest(mainRequest); 
                    
                    stage.Request_Status__c = 'New'; 
                    
                    //parent request in first, so the look-up fields on the children resolve correctly
                    //insert mainRequest; 
                   // insert stage;  
                    cc.insertStage(stage);
                    //if(oldAttachmentID!=null) wosUpload = [SELECT NAME, body from Attachment where id =: oldAttachmentID]; 
                     if(oldAttachmentID!=null) wosUpload =cc.getUploadedAttachment(oldAttachmentID); 
                    else return null;
                    
                    Attachment clonedAtt = new Attachment(); 
                    
                    clonedAtt.Name = wosUpload.Name; 
                    clonedAtt.Body = wosUpload.Body; 
                    
                    //delete wosUpload; 
                    cc.deleteAttachment(wosUpload);
                    clonedAtt.ParentId = stage.id; 
                    
                    //insert clonedAtt; 
                    cc.clonedAttachments(clonedAtt);
                    
                    C_OPS_LOC_EMAIL_CONFIRM emailConfirmation = new C_OPS_LOC_EMAIL_CONFIRM(stage); 
                    emailConfirmation.sendEmailConfirmation(); 
                    
                    insertedID = stage.ID; //so we can reference this for our pdf later 
                    
                    string requiredIDType; 
                    
                    if(stage.Therapeutic_Area__c == NULL){
                        
                        requiredIDType = 'DEA';
                    } else if(stage.Therapeutic_Area__c == OPHTHALMOLOGY){
                        
                        requiredIDType = 'LRP'; 
                    } else if(stage.Therapeutic_Area__c == ONCOLOGY || stage.Therapeutic_Area__c == RHEUMATOLOGY){
                        
                        requiredIDType = 'HIN'; 
                    }
                    
                    string idValue;                    
                    if(requiredIDType == 'DEA'){                        
                        idValue = stage.DEA__c; 
                    } else if(requiredIDType =='LRP'){                        
                        idValue = stage.LRP__c;
                    } else if(requiredIDType == 'HIN'){                        
                        idValue = stage.HIN__c; 
                    }
                    
                    string fileName = stage.Participant_s_Name__c.left(15) + '_' + idValue + '_' + stage.LOC_Request_Number__c; 
                    
                    mainid = insertedID; 
                    participantName = stage.Participant_s_Name__c; 
                    mainRequestNumber = stage.LOC_Request_Number__c;
                    pdfFileName = fileName; 
                    
                    //attachStagingPDFSummary(insertedID, stage.Participant_s_Name__c, stage.LOC_Request_Number__c, fileName); 
                    
                    pageReference c_ops_loc_stg_pdf_generator = new pageReference('/apex/c_ops_loc_stg_pdf_generator'); 
                    c_ops_loc_stg_pdf_generator.getParameters().put('id', insertedID);
                    return c_ops_loc_stg_pdf_generator;
                }
            }
        }
        
        return null;         
    }
    
    public pageReference loadTemplate(){
        pageReference C_OPS_LOC_EXCEL_TEMPLATE = new pageReference('/apex/C_OPS_LOC_EXCEL_TEMPLATE'); 
        C_OPS_LOC_EXCEL_TEMPLATE.setRedirect(false);
        return C_OPS_LOC_EXCEL_TEMPLATE; 
    }
    
    public pageReference removeDocument(){        
        isStagingRequest = FALSE;        
        previousUploadName = null;
        removeUnusedAttachment();
        wosUpload = new Attachment(); 
        uploadName = NULL;        
        uploadSites = FALSE; 
        addSites = null;       
        return null;
    }
    
    public boolean isValidZip(string z){        
        if(z.length() == 0){            
            return false;
        }
        
        Pattern zipCodeChecker = Pattern.compile('^(\\d{5}(\\-\\d{4})?)?$');
        Matcher zipMatcher = ZipCodeChecker.matcher(z);
        
        return (zipMatcher.matches());            
    }
    
    // PageRender gets here
    public boolean getRenderHospitalEntry(){
        return (formProperty.Therapeutic_Area__c == 'Hospital');
    }
    
    public boolean getRenderOncRheEntry(){        
        return (formProperty.Therapeutic_Area__c == ONCOLOGY || formProperty.Therapeutic_Area__c == RHEUMATOLOGY);
    }
    
    public boolean getRenderOpth(){ 
        //dump children request list because Ophthalmology request has no child
        if (formProperty.Therapeutic_Area__c == OPHTHALMOLOGY) newRequests = new List<C_OPS_LOC_REQUEST__C>();      
        return (formProperty.Therapeutic_Area__c == OPHTHALMOLOGY);
    }
                  
    public boolean isValidPhone(string checker){        
        String phoneRegex ='^\\(?([0-9]{3})\\)?[-.\\s]?([0-9]{3})[-.\\s]?([0-9]{4})$';
        Pattern phonePattern = Pattern.Compile(phoneRegex); 
        Matcher phoneMatcher = phonePattern.Matcher(checker);         
        return phoneMatcher.Matches();                  
    }
    
    public boolean isAlphaOnly(string checker){
        
        //String alphaRegex = '^[a-zA-z ]*'; 
        
        //Pattern alphaPattern = Pattern.compile(alphaRegex); 
        //Matcher alphaMatcher = alphaPattern.Matcher(checker); 
        
        //return alphaMatcher.Matches();
        return true;
    }
    
    public boolean isValidEmail(string checker){
        
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,10}$';
        
        Pattern emailPattern = Pattern.compile(emailRegex); 
        Matcher emailMatcher = emailPattern.Matcher(checker); 
                      
        return emailMatcher.matches();              
    }
    
    public boolean isAlphaNumericOnly(string checker){
        
        //String alphaNumericRegex = '^[a-zA-z0-9 ]*'; 
        
        //Pattern alphaNumericPattern = Pattern.compile(alphaNumericRegex);
        //Matcher alphaNumericMatcher = alphaNumericPattern.Matcher(checker); 
        
        //return alphaNumericMatcher.matches(); 
        return true;
    }
    
    public void handleError(string errorText){
        
        ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR, errorText); 
        ApexPages.addMessage(errorMsg);
        
        return;
    }
    
    public void dumpDataPastFirstPage(){
        
        currentRequest = new C_OPS_LOC_REQUEST__C(); //get rid of current request
        
        C_OPS_LOC_REQUEST__C newMainRequest = new C_OPS_LOC_REQUEST__C();
        List<C_OPS_LOC_REQUEST__C> newChildRequests = new List<C_OPS_LOC_REQUEST__C>(); 
        
        newMainRequest.Participant_s_Name__C = mainRequest.Participant_s_Name__c; 
        newMainRequest.Address_Line_1__c = mainRequest.Address_Line_1__c; 
        newMainRequest.Address_Line_2__C = mainRequest.Address_Line_2__c; 
        
        newMainRequest.City__c = mainRequest.City__c; 
        newMainRequest.State__C = mainRequest.State__c; 
        newMainRequest.Zip_Postal_Code__C = mainRequest.Zip_Postal_Code__c; 
        
        newMainRequest.Phone_Number__C = mainRequest.Phone_Number__c; 
        newMainRequest.Email__c = mainRequest.Email__c;
        
        newMainRequest.Current_GPO__c = mainRequest.Current_GPO__c; 
        newMainRequest.Previous_GPO__c = mainRequest.Previous_GPO__c; 
        newMainRequest.Current_Affiliation_Start_Date__c = mainRequest.Current_Affiliation_Start_Date__c; 
        
        newMainRequest.Attestation_signed__c = mainRequest.Attestation_signed__c; 
        newMainRequest.Signer_First_Name__c = mainRequest.Signer_First_Name__c; 
        newMainRequest.Signer_Last_Name__c = mainRequest.Signer_Last_Name__c;
        newMainRequest.Signer_Title__c = mainRequest.Signer_Title__c; 
        
        
        if(Hospital == 'FALSE'){ //dealing with a hospital gpo type            
            newMainRequest.DEA__c = mainRequest.DEA__c; 
            newMainRequest.HIN__c = mainRequest.HIN__c; 
            newMainRequest.X340B_ID__c = mainRequest.X340B_ID__c; 
            newMainRequest.Class_of_Trade__c = mainRequest.Class_of_Trade__c;
            newMainRequest.Class_of_Trade_Other__c = mainRequest.Class_of_Trade_Other__c;
            
        } else if(nonHospital == ONCOLOGY || nonHospital == RHEUMATOLOGY){            
            newMainRequest.HIN__c = mainRequest.HIN__c; 
            newMainRequest.DEA__c = mainRequest.DEA__c; 
            newMainRequest.X340B_ID__c = mainRequest.X340B_ID__c;
        } else{            
            newMainRequest.DEA__c = mainRequest.DEA__C; 
            newMainRequest.HIN__c = mainRequest.HIN__c; 
            newMainRequest.X340B_ID__c = mainRequest.X340B_ID__c; 
            newMainRequest.LRP__c = mainRequest.LRP__c;
            newMainRequest.Ophthalmology_ID_1__c = mainRequest.Ophthalmology_ID_1__c;
            newMainRequest.Ophthalmology_ID_2__c = mainRequest.Ophthalmology_ID_2__c;
        }
        
        //now do the same process with our child requests
        C_OPS_LOC_REQUEST__C holder; 
        
        for(C_OPS_LOC_REQUEST__C r : newRequests){
            
            holder = new C_OPS_LOC_REQUEST__C(); 
            
            holder.Participant_s_Name__C = r.Participant_s_Name__c; 
            holder.Address_Line_1__c = r.Address_Line_1__c; 
            holder.Address_Line_2__C = r.Address_Line_2__c; 
            
            holder.City__c = r.City__c; 
            holder.State__C = r.State__c; 
            holder.Zip_Postal_Code__C = r.Zip_Postal_Code__c; 
            
            holder.Phone_Number__C = r.Phone_Number__c; 
            holder.Email__c = r.Email__c;
            
            holder.Current_GPO__c = r.Current_GPO__c; 
            holder.Previous_GPO__c = r.Previous_GPO__c; 
            holder.Current_Affiliation_Start_Date__c = r.Current_Affiliation_Start_Date__c; 
            
            holder.Attestation_signed__c = r.Attestation_signed__c; 
            holder.Signer_First_Name__c = r.Signer_First_Name__c; 
            holder.Signer_Last_Name__c = r.Signer_Last_Name__c; 
            holder.Attestation_signed__c = r.Attestation_signed__c;
            holder.Signer_Title__c = r.Signer_Title__c;
            
            if(Hospital == 'FALSE'){ //dealing with a hospital gpo type            
                holder.DEA__c = r.DEA__c; 
                holder.HIN__c = r.HIN__c; 
                holder.X340B_ID__c = r.X340B_ID__c; 
                holder.Class_of_Trade__c = r.Class_of_Trade__c;
                holder.Class_of_Trade_Other__c = r.Class_of_Trade_Other__c;
                
            } else if(nonHospital == ONCOLOGY || nonHospital == RHEUMATOLOGY){            
                holder.HIN__c = r.HIN__c; 
                holder.DEA__c = r.DEA__c; 
                holder.X340B_ID__c = r.X340B_ID__c;
            }
            
            newChildRequests.Add(holder); 
        }
        
        newRequests = new List<C_OPS_LOC_REQUEST__C>(); // dump our data just in case to clear view state
        newRequests = newChildRequests; 
        
        mainRequest = newMainRequest; //gets rid of our main request 
        
        wosUpload = new Attachment(); 
    }
    
    public void runValidations(){
        
        //for use in soql later
        Set<string> deaIDs = new Set<string>(); 
        Set<string> hinIDs = new Set<string>(); 
        Set<string> lrpIDs = new Set<string>(); 

        List<Customer_ID_DEA_Registry_DEA__c> dea; 
        List<Customer_ID_HIBCC_HIN__c> hin; 
        List<Customer_ID_Genentech_LRP__c> lrp;
        
        Map<String,String> hinAddresses = new Map<String,String>(); 
        Map<String,String> hinNames = new Map<String,String>(); 
        
        Map<String,String> lrpAddresses = new Map<String,String>(); 
        Map<String,String> lrpNames = new Map<String,String>(); 
        
        Map<String,String> deaAddresses = new Map<String,String>(); 
        
        List<String> hins = new List<String>();
        List<String> deas = new List<String>();
        List<String> lrps = new List<String>(); 
        
        if(formProperty.Therapeutic_Area__c == ONCOLOGY || formProperty.Therapeutic_Area__c == RHEUMATOLOGY){            
            //running vals against HIN for these two (no other id fields)
            hinIDs.Add(mainRequest.HIN__c); 
            
            for(C_OPS_LOC_REQUEST__C r: newRequests){                
                hinIDs.Add(r.HIN__c); 
            }
            
            hin = [SELECT HIN__C, name__C, ADDRESS1__C from Customer_ID_HIBCC_HIN__c where hin__C in: hinIDs];             
            for(Customer_ID_HIBCC_HIN__c h : hin){                
                hins.add(h.HIN__c); 
                hinAddresses.put(h.HIN__c, h.ADDRESS1__c); 
                hinNames.put(h.HIN__c, h.Name__c); 
            }
            
            if(!hins.contains(mainRequest.HIN__c)){                
                mainRequest.HIN_Not_Found__c = TRUE;
            } else{                
                if(removeSpecialCharacters(hinNames.get(mainRequest.HIN__c)) != removeSpecialCharacters(mainRequest.Participant_s_Name__c)){                    
                    mainRequest.Participant_Name_Not_Match__c = TRUE; 
                }
                
                if(removeAddressSpecialCharacters(hinAddresses.get(mainRequest.HIN__c)) != removeAddressSpecialCharacters(mainRequest.Address_Line_1__c)){                    
                    mainRequest.Address_Not_Match__c = TRUE; 
                }
            }
            
            for(C_OPS_LOC_REQUEST__C r: newRequests){                
                if(!hins.contains(r.HIN__c)){                
                    r.HIN_Not_Found__c = TRUE;
                } else{                
                    if(removeSpecialCharacters(hinNames.get(r.HIN__c)) != removeSpecialCharacters(r.Participant_s_Name__c)){                    
                        r.Participant_Name_Not_Match__c = TRUE; 
                    }
                    
                    if(removeAddressSpecialCharacters(hinAddresses.get(r.HIN__c)) != removeAddressSpecialCharacters(r.Address_Line_1__c)){                    
                        r.Address_Not_Match__c = TRUE; 
                    }
                }
            }
            
            if(!emptyString(mainRequest.dea__c)){                
                deaIds.Add(mainRequest.dea__c); 
            }

            for(C_OPS_LOC_REQUEST__C r: newRequests){                
                if(emptyString(r.dea__c)==false){                    
                    deaIDs.Add(r.dea__c); 
                }
            }
            
            if(deaIds.size()>0){                
                dea = [SELECT dea__C from Customer_ID_DEA_Registry_DEA__c where dea__C in: deaIDs and Expiration_Date__c >=: System.today()];             
                for(Customer_ID_DEA_Registry_DEA__c d : dea){                
                    deas.add(d.dea__C); 
                }
            
                if(!deas.contains(mainRequest.DEA__c)){                
                    mainRequest.DEA_Not_Found__c = TRUE;
                }
            
                for(C_OPS_LOC_REQUEST__C r: newRequests){                
                    if(!deas.contains(r.DEA__c)){                
                        r.DEA_Not_Found__c = TRUE;
                    }
                }    
            }
        }
        
        if(formProperty.Therapeutic_Area__c == OPHTHALMOLOGY){            
            //running vals against LRP ID for this one
            lrpIDs.Add(mainRequest.LRP__C);             
            for(C_OPS_LOC_REQUEST__C r: newRequests){                
                lrpIDs.Add(r.LRP__C); 
            }
            
            lrp = [SELECT LRP_ID__C, name__C, ADDRESS1__C from Customer_ID_Genentech_LRP__c where LRP_ID__C in: lrpIDs];             
            for(Customer_ID_Genentech_LRP__c l : lrp){                
                lrps.add(l.lrp_ID__C); 
                lrpAddresses.put(l.LRP_ID__C, l.ADDRESS1__c); 
                lrpNames.put(l.LRP_ID__C, l.Name__c); 
            }
            
            if(!lrps.contains(mainRequest.LRP__C)){                
                mainRequest.LRP_Not_Found__c = TRUE;
            } else{                
                if(removeSpecialCharacters(lrpNames.get(mainRequest.LRP__C)) != removeSpecialCharacters(mainRequest.Participant_s_Name__c)){                    
                    mainRequest.Participant_Name_Not_Match__c = TRUE; 
                }
                
                if(removeAddressSpecialCharacters(lrpAddresses.get(mainRequest.LRP__C)) != removeAddressSpecialCharacters(mainRequest.Address_Line_1__c)){                    
                    mainRequest.Address_Not_Match__c = TRUE; 
                }
            }
            
            for(C_OPS_LOC_REQUEST__C r: newRequests){                
                if(!lrps.contains(r.lrp__C)){                
                    r.LRP_Not_Found__c = TRUE;
                } else{                
                    if(removeSpecialCharacters(lrpNames.get(r.lrp__C)) != removeSpecialCharacters(r.Participant_s_Name__c)){                        
                        r.Participant_Name_Not_Match__c = TRUE; 
                    }
                    
                    if(removeAddressSpecialCharacters(lrpAddresses.get(r.lrp__C)) != removeAddressSpecialCharacters(r.Address_Line_1__c)){                        
                        r.Address_Not_Match__c = TRUE; 
                    }
                }
            }
            
            if(emptyString(mainRequest.dea__c)==false){                
                deaIds.Add(mainRequest.dea__c); 
            }

            for(C_OPS_LOC_REQUEST__C r: newRequests){                
                if(emptyString(r.dea__c)==false){                    
                    deaIDs.Add(r.dea__c); 
                }
            }
            
            if(deaIds.size()>0){                
                dea = [SELECT dea__C from Customer_ID_DEA_Registry_DEA__c where dea__C in: deaIDs and Expiration_Date__c >=: System.today()];             
                for(Customer_ID_DEA_Registry_DEA__c d : dea){                
                    deas.add(d.dea__C); 
                }
            
                if(!deas.contains(mainRequest.DEA__c)){                
                    mainRequest.DEA_Not_Found__c = TRUE;
                }
            
                for(C_OPS_LOC_REQUEST__C r: newRequests){                
                    if(!deas.contains(r.DEA__c)){                        
                        r.DEA_Not_Found__c = TRUE;
                    }
                }    
            }
            
            if(emptyString(mainRequest.HIN__C)==false){                
                hinIDs.Add(mainRequest.HIN__c); 
            }

            for(C_OPS_LOC_REQUEST__C r: newRequests){                
                if(emptyString(r.HIN__c)==false){                    
                    hinIDs.Add(r.HIN__c); 
                }
            }
            
            if(hinIDs.size()>0){                
                hin = [SELECT HIN__C from Customer_ID_HIBCC_HIN__c where hin__C in: hinIDs];             
                for(Customer_ID_HIBCC_HIN__c h : hin){                
                    hins.add(h.HIN__c); 
                }
            
                if(!hins.contains(mainRequest.HIN__c)){                
                    mainRequest.HIN_Not_Found__c = TRUE;
                }
            
                for(C_OPS_LOC_REQUEST__C r: newRequests){                
                    if(!hins.contains(r.HIN__c)){                
                        r.HIN_Not_Found__c = TRUE;
                    }
                }    
            }
        }
        
        if(formProperty.Therapeutic_Area__c == 'Hospital'){            
            //dea is primary driver of this validation, HIN is optional so only checking against that ID
            deaIds.Add(mainRequest.DEA__c); 
            
            for(C_OPS_LOC_REQUEST__C r: newRequests){                
                deaIds.Add(r.DEA__c); 
            }
            
            dea = [SELECT DEA__C, FULL_NAME__C, ADDRESS_1__C from Customer_ID_DEA_Registry_DEA__c where dea__C in: deaIds and Expiration_Date__c >=: System.today()];            
            for(Customer_ID_DEA_Registry_DEA__c d : dea){                
                deas.add(d.DEA__C); 
                deaAddresses.put(d.DEA__C, d.ADDRESS_1__c); 
            }
            
            if(!deas.contains(mainRequest.dea__c)){                
                mainRequest.DEA_NOT_FOUND__C = TRUE;
            } else{                
                
                if(removeAddressSpecialCharacters(deaAddresses.get(mainRequest.DEA__C)) != removeAddressSpecialCharacters(mainRequest.Address_Line_1__c)){                    
                    mainRequest.Address_Not_Match__c = TRUE; 
                }
            }
            
            for(C_OPS_LOC_REQUEST__C r: newRequests){                
                if(!deas.contains(r.DEA__C)){                
                    r.DEA_Not_Found__c = TRUE;
                } else{                
                    
                    if(removeAddressSpecialCharacters(deaAddresses.get(r.DEA__C)) != removeAddressSpecialCharacters(r.Address_Line_1__c)){                    
                        r.Address_Not_Match__c = TRUE; 
                    }
                }
            }
            
            if(emptyString(mainRequest.HIN__C)==false){                
                hinIDs.Add(mainRequest.HIN__c); 
            }

            for(C_OPS_LOC_REQUEST__C r: newRequests){                
                if(emptyString(r.HIN__c)==false){                    
                    hinIDs.Add(r.HIN__c); 
                }
            }
            
            if(hinIDs.size()>0){                
                hin = [SELECT HIN__C from Customer_ID_HIBCC_HIN__c where hin__C in: hinIDs];             
                for(Customer_ID_HIBCC_HIN__c h : hin){                
                    hins.add(h.HIN__c); 
                }
            
                if(!hins.contains(mainRequest.HIN__c)){                
                    mainRequest.HIN_Not_Found__c = TRUE;
                }
            
                for(C_OPS_LOC_REQUEST__C r: newRequests){                
                    if(!hins.contains(r.HIN__c)){                        
                        r.HIN_Not_Found__c = TRUE;
                    }
                }    
            }
        }
        
    }
    
    public string removeSpecialCharacters(string target){        
        Pattern alpha = Pattern.compile('[^a-zA-Z]'); 
        Matcher alphaMatcher = alpha.matcher(target); 
        
        //returns only letters from the name (to satisfy specs to be a little more receptive than full match)
        return alphaMatcher.replaceAll(''); 
    }
    
    public string removeAddressSpecialCharacters(string target){
        
        Pattern alphaNumeric = Pattern.compile('[^a-zA-z0-9]'); 
        Matcher alphaNumericMatcher = alphaNumeric.matcher(target); 
        
        //returns only letters + numbers from the address 
        return alphaNumericMatcher.replaceAll(''); 
    }

    public PageReference attachPDFSummary(){

        id insertedID = mainID;
        string participantName = participantName; 
        string requestNumber = mainRequestNumber; 
        List<string> childRequestIds = cRequestIDs;  
        string fName = pdfFileName; 
        
        //PDF being generated in a seperate transaction         
        PageReference pdfSummary = new PageReference('/apex/C_OPS_LOC_SUMMARY_PDF');         
        pdfSummary.getParameters().put('id', insertedID);
        blob reportBody;
        
        if(Test.isRunningTest()){
            
                        
            string blank = ' '; 
            
            reportBody = blob.valueOf(blank); 
            
        } else{
            
            reportBody = pdfSummary.getContentAsPDF(); 
        }
   
        string attachmentName = fName + '.pdf';          
        list<Attachment> pdfAttachments = new List<Attachment>(); 
                
        Attachment att = new Attachment();         
        att.Body = reportBody; 
        att.Name = attachmentName; 
        att.ParentId = insertedid;         
        pdfAttachments.add(att);
        
        for(string s: childRequestIDs){            
            att = new Attachment();             
            att.Body = reportBody; 
            att.Name = attachmentName; 
            att.ParentId = s;             
            pdfAttachments.Add(att); 
        }
        
       // insert pdfAttachments; 
        cc.insertAttachments(pdfAttachments);
        pageReference c_ops_loc_sub_confirm = new pageReference('/apex/C_OPS_LOC_SUB_CONFIRM'); 
        c_ops_loc_sub_confirm.getParameters().put('id', insertedID);
        c_ops_loc_sub_confirm.setRedirect(true);
        if(numGen.id!=null) numGen=new C_Ops_LOC_Request_Number_Generator__c();
        return c_ops_loc_sub_confirm;
    }
    
    public pageReference attachStagingPDFSummary(){        
        
        PageReference pdfSummary = new PageReference('/apex/C_OPS_LOC_STG_SUMMARY_PDF');         
        pdfSummary.getParameters().put('id', insertedID);     
        
        blob reportBody; 
        
        if(Test.isRunningTest()){
            
            string blank = ' '; 
            
            reportBody = blob.valueOf(blank); 
            
        } else{
            
            reportBody = pdfSummary.getContentAsPDF(); 
        }        
        
        string attachmentName = pdfFileName + '.pdf';          
        list<Attachment> pdfAttachments = new List<Attachment>();                 
        
        Attachment att = new Attachment();         
        att.Body = reportBody; 
        att.Name = attachmentName; 
        att.ParentId = insertedid;         
        pdfAttachments.add(att);        
        //insert pdfAttachments; 
        cc.insertAttachments(pdfAttachments);
        pageReference c_ops_loc_sub_confirm = new pageReference('/apex/C_OPS_LOC_STG_SUB_CONFIRM'); 
        c_ops_loc_sub_confirm.getParameters().put('id', insertedID);
        c_ops_loc_sub_confirm.setRedirect(true);
        if(numGen.id!=null) numGen=new C_Ops_LOC_Request_Number_Generator__c();
        return c_ops_loc_sub_confirm;
    }
        
        // calling this to verify all our child requests have all the necessary fields     
    public string verifyChildRequests(){
        
        string errorText = 'At Least One Child Request is Missing a value for the following fields: ';
        
        if(formProperty.Therapeutic_Area__c == 'Hospital'){
            
            //Hospital request
            // DEA required, class of trade required, other required if class of trade is other
            for(C_OPS_LOC_REQUEST__C req : newRequests){
            
                boolean comma=false;
                
                if(emptyString(req.DEA__C)){
                    
                    errorText = errorText +  'DEA #'; 
                    comma=true;
                }
                
                if(emptyString(req.CLASS_OF_TRADE__C)){
                    if(comma) errorText +=', ';
                    else comma=true;
                    errorText += 'Class Of Trade'; 
                } else if(req.CLASS_OF_TRADE__C == 'Other (Please Enter Below)'){
                    
                    if(emptyString(req.CLASS_OF_TRADE_OTHER__C)){
                        if(comma) errorText +=', ';
                        else comma=true;
                        errorText += 'Class of Trade (Other)'; 
                    }
                }
            }
            
        } else{
            
            if(formProperty.Therapeutic_Area__c == ONCOLOGY || formProperty.Therapeutic_Area__c == RHEUMATOLOGY){
                
                // oncology / rheumatology
                // HIN required
                for(C_OPS_LOC_REQUEST__C req: newRequests){
                    
                    if(emptyString(req.HIN__C)){
                        
                        errorText = errorText +  'Health Identification Number'; 
                    }
                }
            }
        }
        
        if(errorText != 'At Least One Child Request is Missing a value for the following fields: '){ //we encountered at least one error
            
            return errorText; 
        } else{
            
            return ''; 
        } 
    }
    
    public void dropOldRequest(){
        
        currentRequest = new C_OPS_LOC_REQUEST__C(); //drop our old request that may have edited data on it  
        
        return;
    }
    
    //Purpose: Take the fed in Main Request and Set All its pertinent Field values for a Staging Object
    //called to prep a staging request for insert by the saveAndSubmit function. 
    public C_OPS_LOC_REQUEST_STAGING__C convertToStagingRequest(C_OPS_LOC_REQUEST__C mainReq){
        
        C_OPS_LOC_REQUEST_STAGING__C stagingReq = new C_OPS_LOC_REQUEST_STAGING__C(); 
        
        //feed over all pertinent fields
        stagingReq.X340B_ID__c = mainReq.X340B_ID__c; 
        stagingReq.Address_Line_1__c = mainReq.Address_Line_1__c; 
        stagingreq.Address_Line_2__c = mainReq.Address_Line_2__c; 
        stagingReq.Address_Not_Match__c = mainReq.Address_Not_Match__c; 
        stagingReq.Assigned_To__c = mainReq.Assign_To__c; 
        stagingReq.Attestation_signed__c = mainReq.Attestation_signed__c; 
        stagingReq.City__c = mainReq.City__c; 
        stagingReq.Class_of_Trade__c = mainReq.Class_of_Trade__c; 
        stagingReq.Class_of_Trade_Other__c = mainReq.Class_of_Trade_Other__c; 
        stagingReq.Confirmation_Email_Sent__c = mainReq.Confirmation_Email_Sent__c; 
        stagingReq.Confirmation_Email_Sent_On__c = mainReq.Confirmation_Email_Sent_On__c;
        stagingReq.Current_GPO__c = mainReq.Current_GPO__c; 
        stagingReq.Current_Affiliation_Start_Date__c = mainReq.Current_Affiliation_Start_Date__c; 
        stagingReq.DEA__c = mainReq.DEA__c; 
        stagingReq.DEA_Not_Found__c = mainReq.DEA_Not_Found__c; 
        stagingReq.Email__c = mainReq.Email__c;
        stagingReq.HIN__c = mainReq.HIN__c; 
        stagingReq.HIN_Not_Found__c = mainReq.HIN_Not_Found__c; 
        //stagingReq.LOC_Form_Type__c = 
        stagingReq.LOC_Request_Number__c = mainReq.LOC_Request_Number__c; 
        stagingReq.Request_Status_Comments__c = mainReq.Request_Status_Comments__c;
        stagingReq.Request_Type__c = mainReq.Request_Type__c; 
        stagingReq.LRP_Not_Found__c = mainReq.LRP_Not_Found__c; 
        stagingReq.LRP__c = mainReq.LRP__c; 
        stagingReq.Signer_First_Name__c = mainReq.Signer_First_Name__c; 
        stagingReq.Signer_Last_Name__c = mainReq.Signer_Last_Name__c; 
        stagingReq.Participant_s_Name__c = mainReq.Participant_s_Name__c; 
        stagingReq.Participant_Name_Not_Match__c = mainReq.Participant_Name_Not_Match__c; 
        stagingReq.Phone_Number__c = mainReq.Phone_Number__c; 
        stagingReq.Previous_GPO__c = mainReq.Previous_GPO__c; 
        stagingReq.Signer_Title__c = mainReq.Signer_Title__c; 
        stagingReq.Request_IP__c = mainReq.Request_IP__c; 
        stagingReq.Signer_Title__c = mainReq.Signer_Title__c; 
        stagingReq.Ophthalmology_ID_1__c = mainReq.Ophthalmology_ID_1__c; 
        stagingReq.Ophthalmology_ID_2__c = mainReq.Ophthalmology_ID_2__c; 
        stagingReq.State__c = mainReq.State__c; 
        stagingReq.Submission_Date__c = mainReq.Submission_Date__c; 
        stagingReq.Request_Status__c = mainReq.Request_Status__c; 
        stagingReq.Therapeutic_Area__c = mainReq.Therapeutic_Area__c; 
        stagingReq.Zip__c = mainReq.Zip_Postal_Code__c;
        stagingReq.OwnerID = mainReq.OwnerID; 
        
        return stagingReq; 
    }    

    public string getTemplateHeader() {
        string reqType = formProperty.Therapeutic_Area__c;
        string csvHeader = '\"Participant Wholly Owned Site Name\",\"Address 1\",\"Address 2\",\"City\",\"State\",\"Zip\",\"DEA #\",\"HIN #\",\"340B ID#\"';
        if(reqType == 'Hospital') {
                csvHeader += ',\"Class of Trade\"';
        } else if(reqType == ONCOLOGY || reqType == RHEUMATOLOGY) {
            // No additional fields
        } else  if(reqType == OPHTHALMOLOGY) {
            // No additional fields
                //csvHeader += ',\"LRP ID#\",\"Specialty Distributor Name(s)\",\"Specialty Distributor Account #(s)';
        }
        
        return csvHeader;
    }
    
    public boolean getRenderSingleSite(){
        
        return ((newRequests.size() == 0) && (uploadName == NULL||uploadName.trim().length()==0));  
    }
    
    public boolean getRenderMultipleSite(){
        
        return ((newRequests.size() > 0) || (uploadName != NULL && uploadName.trim().length()>0)); 
    }
  private without sharing class CommitChanges{
        public CommitChanges(){}
        
        public C_Ops_LOC_Request_Number_Generator__c insertNumGen(C_Ops_LOC_Request_Number_Generator__c numGen){
            insert numGen;
            numGen=[SELECT id, name from C_Ops_LOC_Request_Number_Generator__c where id =: numgen.Id]; 
            return numGen;
        }
       
        public Attachment insertAttachment(Attachment wosUpload){
            insert wosUpload;
            return wosUpload;
        }
        
        public C_OPS_LOC_REQUEST__C insertMainRequest(C_OPS_LOC_REQUEST__C mainRequest){
            insert mainRequest;
            return mainRequest;
        }
        
        public List<C_OPS_LOC_REQUEST__C> insertNewRequests(List<C_OPS_LOC_REQUEST__C> newRequests){
            insert newRequests;
            return newRequests;
        }
        
        public C_Ops_LOC_Request_Staging__C insertStage(C_Ops_LOC_Request_Staging__C stage){
            insert stage;
            return stage;
        }
        public Attachment clonedAttachments(Attachment att){
            insert att;
            return att;
     }
        
        public list<Attachment> insertAttachments( list<Attachment> pdfAttachments){
            insert pdfAttachments;
            return pdfAttachments;
        }
        
        public Attachment deleteAttachment(Attachment att){
            delete att;
           return null;
        }
      public void deleteAttachment(List<Attachment> atts){
          delete atts;
      }
      public Attachment getUploadedAttachment(ID oldAttachmentID){
          Attachment att=[SELECT NAME, body from Attachment where id =: oldAttachmentID]; 
          return att;
      }
    }
}