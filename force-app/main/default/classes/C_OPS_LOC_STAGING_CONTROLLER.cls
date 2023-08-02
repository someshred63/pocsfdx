public class C_OPS_LOC_STAGING_CONTROLLER  {
    private List<Attachment> attachments;
    private List<String> headerRow;
    private String fileErrorDetail;
    
    public boolean atLeastOneError { get; set; }
    public boolean atLeastOneWarning { get; set; }
    public boolean headerNotFound { get;set; }
    public boolean incorrectHeader { get;set; }
    public boolean filePasringError { get;set; }
    public boolean dupFileError {get; set;}
    
    // To prevent string misspellings.
    private final static string HOSPITAL = 'Hospital';
    private final static string ONCOLOGY = 'Oncology';
    private final static string OPHTHALMOLOGY = 'Ophthalmology';
    private final static string RHEUMATOLOGY = 'Rheumatology';

    // For parsing CSV
    public List<List<String>> parsedCSV { get; set; }
    public List<csvRow> csv { get; set; }
    public integer parsedCSVRowCount { get; set; }
    public integer parsedCSVColumnCount { get; set; }
    
    public C_Ops_LOC_Request__c newRequest { get; set; }
    public Id newRequestId { get; set; }
    public string errorMessage { get; set; }
    
    public map<string,string> stateCodes {get; set;}
    
    @testVisible private C_Ops_LOC_Request_Staging__c staging;
    
    public C_Ops_LOC_Request_Staging__c getStaging() {
        return this.staging;
    }
    
    private Boolean emptyString(String s){
        if(s==null || s.trim().length()<=0) return true;
        else return false;
    }
    
    private void commonConstructorCode(string theId, string errCode) {
        headerNotFound = FALSE;
        incorrectHeader = false;
        filePasringError = false;
        fileErrorDetail='';
        
        this.staging =
            [SELECT
                Id,
                OwnerId,
                X340B_ID__c,
                Address_Line_1__c,
                Address_Line_2__c,
                Address_Not_Match__c,
                Assigned_To__c,
                Attestation_signed__c,
                City__c,
                Class_of_Trade__c,
                Class_of_Trade_Other__c,
                Confirmation_Email_Sent__c,
                Confirmation_Email_Sent_On__c,
                Current_GPO__c,
                Current_Affiliation_Start_Date__c,
                DEA__c,
                DEA_Not_Found__c,
                Email__c,
                HIN__c,
                HIN_Not_Found__c,
                LOC_Request_Number__c,
                Request_Status_Comments__c,
                Request_Type__c,
                LRP_Not_Found__c,
                LRP__c,
                Signer_First_Name__c,
                Signer_Last_Name__c,
                Participant_s_Name__c,
                Participant_Name_Not_Match__c,
                Phone_Number__c,
                Previous_GPO__c,
                Request_IP__c,
                Signer_Title__c,
                Ophthalmology_ID_1__c,
                Ophthalmology_ID_2__c,
                State__c,
                Submission_Date__c,
                Request_Status__c,
                Therapeutic_Area__c,
                Zip__c
             FROM C_Ops_LOC_Request_Staging__c
             WHERE Id = :theId
             LIMIT 1];        
        
        stateCodes = new map<string,string>();
        this.loadStateCodes();
        this.loadAttachment();         

        if(!emptyString(errCode)) {
            if(errCode == '1') {
               this.errorMessage = 'Please assign this request to yourself before you process the file.';            
            } else if(errCode == '2') {
                this.errorMessage = 'The status of the staging request must be \'Pending\'.';
            } else if(errCode == '3') {
                this.errorMessage = 'This staging request has already been converted. <br/>The LOC submission # is '+this.staging.LOC_Request_Number__c;
            } else if(errCode == '4') {
                this.errorMessage = 'This staging request does not contain an attached CSV.';
            } else if(errCode == '5') {
                this.errorMessage = 'This uploaded attachment does not contain any data. <br/>Attachment file name - '+attachments[0].name;
            } else if(errCode == '6') {
                this.errorMessage = 'Error: Column headings are missing from this file. <br/>Attachement file name - '+attachments[0].name;
            } else if(errCode == '7') {
                this.errorMessage = 'Error: Data file contains incorrect Column headings.<br/>'+fileErrorDetail;
            } else if(errCode == '8') {
                this.errorMessage = 'This LOC submission\'s data file has been successfully processed and LOC submission records are created. No need to reprocess this file.';
            }
        }
    }
    
    public C_OPS_LOC_STAGING_CONTROLLER() {        
        string theId = ApexPages.currentPage().getParameters().get('id');
        string errCode = ApexPages.currentPage().getParameters().get('err');
        commonConstructorCode(theId, errCode);        
    }
        
    public C_OPS_LOC_STAGING_CONTROLLER(ApexPages.StandardController sc) {
        Id theId = sc.getId();
        string errCode = ApexPages.currentPage().getParameters().get('err');
        commonConstructorCode(string.valueOf(theId), errCode);        
    }
    
    public C_OPS_LOC_STAGING_CONTROLLER(ApexPages.StandardController sc, string errCode) {
        Id theId = sc.getId();
        commonConstructorCode(string.valueOf(theId), errCode);        
    }

    //Jie - check file header row to make sure header has exactally columns number and column name as the tempalte file
    private void checkFileHeader() {
        string header = '\"Participant Wholly Owned Site Name\",\"Address 1\",\"Address 2\",\"City\",\"State\",\"Zip\",\"DEA #\",\"HIN #\",\"340B ID#\"';
        if(this.staging.Therapeutic_Area__c == Null || this.staging.Therapeutic_Area__c.trim()=='') {
            header += ',\"Class of Trade\"';
        }
        
        List<String> expectedHeader = header.split(',');
        if(this.headerRow == null || this.headerRow.size()<=0) {
            headerNotFound = TRUE;
            return;
        } else if(this.headerRow.size() != expectedHeader.size()) {
            fileErrorDetail += '<br/> Error Detail: Expect '+expectedHeader.size()+' columns while found '+headerRow.size()+' columns on header of the data file';
            incorrectHeader = true;
            return;
        } else {
            Integer index = 0;
            Integer errorCount = 0;
            for (String colName: headerRow){                
                String tempHeader=expectedHeader.get(index++);   
                Integer endIndex= tempHeader.length();                                       
                if(!tempHeader.containsIgnoreCase(colName)) {
                    if(tempHeader.startsWith('"')) tempHeader=tempHeader.substring(1, tempHeader.length()-1);
                    fileErrorDetail += '<br/> Error Detail: Expect column name <b>'+tempHeader+'</b> while found column name <b>'+colName+'</b>';
                     incorrectHeader = true;
                     errorCount++;
                }
            }
        }
    }
    
    private void loadAttachment() {
        this.attachments = [SELECT Id, Name, Body FROM Attachment WHERE ParentId = :this.staging.Id AND Name LIKE '%.csv' ORDER BY CreatedDate DESC];        
        if(this.attachments != null && this.attachments.size() > 0 && this.attachments[0] != null) {
            Blob contents = this.attachments[0].Body;
            string contentsAsString;
            if(contents != null) {
                contentsAsString = contents.toString();
            }
            
            if(contents ==null || contentsAsString==null || contentsAsString.trim().length()<=0) {
                return;
            }
            
            //check the whole first row for Site Name to decided whether hearder is missing
            if(
                ((this.staging.Therapeutic_Area__c == Null || this.staging.Therapeutic_Area__c.trim()=='') && (!contentsAsString.left(126).containsIgnoreCase('Site Name'))) 
                ||
                (this.staging.Therapeutic_Area__c != Null && this.staging.Therapeutic_Area__c.trim().length()>0 && (!contentsAsString.left(109).containsIgnoreCase('Site Name'))))  {               
                    //header row isn't present, throw out error
                    headerNotFound = TRUE;                
                    //break out here so we don't hit a list index out of bounds error
                    return;
            }
            
            
           /* if(contentsAsString!=null && (!contentsAsString.left(125).containsIgnoreCase('Site Name'))){               
                //header row isn't present, throw out error
                headerNotFound = TRUE;                
                //break out here so we don't hit a list index out of bounds error
                return;
            }*/
            
            //Jie - Keep header for validation
            List<List<String>> parsedCSV_withHeader = C_Ops_LOC_CSV_Parser.parseCSV(contentsAsString,false);
            system.debug(parsedCSV_withHeader);
            this.headerRow = parsedCSV_withHeader.get(0);
            checkFileHeader(); //check file header
            //Jie - now remove header from the parsed_CSV
            parsedCSV_withHeader.remove(0);
            this.parsedCSV = parsedCSV_withHeader;
            this.csv = convertParsedCSV();
            this.parsedCSVRowCount = this.csv.size();
            
                 
        }
    }
    
    public PageReference gotoStagingRequest() {
        PageReference pr = new PageReference('/' + this.staging.Id);
        return pr;
    }
    
    public PageReference doConvert() {
        // Error checking
        List<C_Ops_LOC_Request__c> reqs = [SELECT Id FROM C_Ops_LOC_Request__c WHERE Staging_Source__c = :this.staging.Id LIMIT 1];
        
        Id stagingOwnerId = this.staging.Assigned_To__c;
        Id currentUserId = UserInfo.getUserId();
        if(stagingOwnerId != currentUserId) {
            PageReference pr = Page.C_OPS_LOC_CONVERT_ERROR;
            pr.getParameters().put('id', this.staging.Id);
            pr.getParameters().put('err', '1');
            pr.setRedirect(false);
            return pr;
        }
        
        else if(this.staging.Request_Status__c == 'LOC Requests Created') {
            PageReference pr = Page.C_OPS_LOC_CONVERT_ERROR;
            pr.getParameters().put('id', this.staging.Id);
            pr.getParameters().put('err', '8');
            pr.setRedirect(false);
            return pr;
        }
        
        else if(this.staging.Request_Status__c != 'Pending') {
            PageReference pr = Page.C_OPS_LOC_CONVERT_ERROR;
            pr.getParameters().put('id', this.staging.Id);
            pr.getParameters().put('err', '2');
            pr.setRedirect(false);
            return pr;
        }
        
        else if(reqs != null && reqs.size() > 0) {
            PageReference pr = Page.C_OPS_LOC_CONVERT_ERROR;
            pr.getParameters().put('id', this.staging.Id);
            pr.getParameters().put('err', '3');
            pr.setRedirect(false);
            return pr;
        }
        
        else if(this.attachments == null || this.attachments.size() == 0 || this.attachments[0] == null) {
            PageReference pr = Page.C_OPS_LOC_CONVERT_ERROR;
            pr.getParameters().put('id', this.staging.Id);
            pr.getParameters().put('err', '4');
            pr.setRedirect(false);
            return pr;            
        }
        
       else if(headerNotFound) {            
            PageReference pr = Page.C_OPS_LOC_CONVERT_ERROR; 
            pr.getParameters().put('id', this.staging.id); 
            pr.getParameters().put('err', '6'); 
            pr.setRedirect(false); 
            return pr;
        }
        
        else if(this.parsedCSV == null || this.parsedCSV.size() <= 0) {
            PageReference pr = Page.C_OPS_LOC_CONVERT_ERROR;
            pr.getParameters().put('id', this.staging.Id);
            pr.getParameters().put('err', '5');
            //pr.getParameters().put('err', ''+parsedCSV.size() );
            pr.setRedirect(false);
            return pr;            
        } 
        
        else if(incorrectHeader) {            
            PageReference pr = Page.C_OPS_LOC_CONVERT_ERROR; 
            pr.getParameters().put('id', this.staging.id); 
            pr.getParameters().put('err', '7'); 
            pr.setRedirect(false); 
            return pr;
        }
        
        PageReference pr = Page.C_OPS_LOC_REVIEW_UPLOAD;
        pr.getParameters().put('id', this.staging.Id);
        return pr;
    }
    
    private boolean noDuplicateLOCSubmission(){
        List<C_Ops_LOC_Request__c> locSubmissions=[select LOC_Request_Number__c from C_Ops_LOC_Request__c where LOC_Request_Number__c=:this.staging.LOC_Request_Number__c];
        if(locSubmissions!=null && locSubmissions.size()>0) return false;
        else return true;
    }
    
    public PageReference continueUpload() { 
    
      if(noDuplicateLOCSubmission()){
        // =======================================        
        // Create the new request
        // =======================================        
            
        this.newRequest = new C_Ops_LOC_Request__c();
        newRequest.X340B_ID__c = this.staging.X340B_ID__c;
        newRequest.Address_Line_1__c = this.staging.Address_Line_1__c;
        newRequest.Address_Line_2__c = this.staging.Address_Line_2__c;
        newRequest.Address_Not_Match__c = this.staging.Address_Not_Match__c;
        newRequest.Assign_To__c = this.staging.Assigned_To__c;
        newRequest.Attestation_signed__c = this.staging.Attestation_signed__c;
        newRequest.City__c = this.staging.City__c;
        newRequest.Class_of_Trade__c = this.staging.Class_of_Trade__c;
        newRequest.Class_of_Trade_Other__c = this.staging.Class_of_Trade_Other__c;
        newRequest.Confirmation_Email_Sent__c = this.staging.Confirmation_Email_Sent__c;
        newRequest.Confirmation_Email_Sent_On__c = this.staging.Confirmation_Email_Sent_On__c;
        newRequest.Current_GPO__c = this.staging.Current_GPO__c;
        newRequest.Current_Affiliation_Start_Date__c = this.staging.Current_Affiliation_Start_Date__c;
        newRequest.DEA__c = this.staging.DEA__c;
        newRequest.DEA_Not_Found__c = this.staging.DEA_Not_Found__c;
        newRequest.Email__c = this.staging.Email__c;
        newRequest.HIN__c = this.staging.HIN__c;
        newRequest.HIN_Not_Found__c = this.staging.HIN_Not_Found__c;
        newRequest.Is_Parent_Location__c = TRUE;
        newRequest.LOC_Request_Number__c = this.staging.LOC_Request_Number__c;
        newRequest.Request_Status_Comments__c = this.staging.Request_Status_Comments__c;
        newRequest.Request_Type__c = this.staging.Request_Type__c;
        newRequest.LRP_Not_Found__c = this.staging.LRP_Not_Found__c;
        newRequest.LRP__c = this.staging.LRP__c;
        newRequest.OwnerId = this.staging.OwnerId;
        newRequest.Participant_s_Name__c = this.staging.Participant_s_Name__c;
        newRequest.Participant_Name_Not_Match__c = this.staging.Participant_Name_Not_Match__c;
        newRequest.Phone_Number__c = this.staging.Phone_Number__c;
        newRequest.Previous_GPO__c = this.staging.Previous_GPO__c;
        newRequest.Request_IP__c = this.staging.Request_IP__c;
        newRequest.Signer_Title__c = this.staging.Signer_Title__c;
        newRequest.Signer_First_Name__c = this.staging.Signer_First_Name__c;
        newRequest.Signer_Last_Name__c = this.staging.Signer_Last_Name__c;
        newRequest.Staging_Source__c = this.staging.Id;
        newRequest.Ophthalmology_ID_1__c = this.staging.Ophthalmology_ID_1__c;
        newRequest.Ophthalmology_ID_2__c = this.staging.Ophthalmology_ID_2__c;
        newRequest.State__c = this.staging.State__c;
        newRequest.Submission_Date__c = this.staging.Submission_Date__c;
        newRequest.Request_Status__c = 'New';
        newRequest.Therapeutic_Area__c = this.staging.Therapeutic_Area__c;
        newRequest.Zip_Postal_Code__c = this.staging.Zip__c;        
        

        system.debug('inserting newrequest: ' + newRequest.Participant_s_Name__c);
        insert newRequest;
        this.newRequestId = newRequest.Id;
        
        // Clone attachments
        List<Attachment> atts = [SELECT Id, Name, Body FROM Attachment WHERE ParentId = :this.staging.Id];
        if(atts != null && atts.size() > 0) {
            List<Attachment> clones = new List<Attachment>();
            for(Attachment att : atts) {
                Attachment attClone = new Attachment(Name = att.Name, Body = att.Body, ParentId = newRequest.Id);
                clones.add(attClone);
            }
            insert clones;
        }

        // =======================================        
        // Process the CSV attachment
        // =======================================        

        // Pre-load picklist vals for picklist validation
        Schema.DescribeFieldResult stateField = C_OPS_LOC_REQUEST__c.State__c.getDescribe();
        List<Schema.PicklistEntry> stateEntries = stateField.getPicklistValues();
        List<string> stateValues = new List<string>();
        for(Schema.PicklistEntry stateEntry : stateEntries) {
            if(stateEntry.isActive()) {
                stateValues.add(stateEntry.getValue());
            }
        }
        
        Schema.DescribeFieldResult classOfTradeField = C_OPS_LOC_REQUEST__c.Class_of_Trade__c.getDescribe();
        List<Schema.PicklistEntry> classOfTradeEntries = classOfTradeField.getPicklistValues();
        List<string> classOfTradeValues = new List<string>();
        for(Schema.PicklistEntry classOfTradeEntry : classOfTradeEntries) {
            if(classOfTradeEntry.isActive()) {
                classOfTradeValues.add(classOfTradeEntry.getValue());
            }
        }
        
        // Keep track of all DEA, HIN, LRP numbers being uploaded,
        // so the validation query against the objects is narrowed down
        // against these specific numbers.
        Set<string> deaIds = new Set<string>();
        Set<string> hinIds = new Set<string>();
        Set<string> lrpIds = new Set<string>();

        // First pass:
        // Go through CSV rows and parse based on request type.
        List<C_OPS_LOC_REQUEST__c> childrenToInsert = new List<C_OPS_LOC_REQUEST__c>();
        for(csvRow cr : this.csv) {
            List<String> row = cr.rowData;
            
            C_OPS_LOC_REQUEST__c currentRequest = new C_OPS_LOC_REQUEST__c();
            
            // Copy certain values from the main request to this child request.
            currentRequest.Parent_Request__c = newRequest.Id;
            currentRequest.LOC_Request_Number__c = newRequest.LOC_Request_Number__c;
            currentRequest.Request_Type__c = newRequest.Request_Type__c;
            currentRequest.Therapeutic_Area__c = newRequest.Therapeutic_Area__c;
            currentRequest.Is_Parent_Location__c = FALSE;
            currentRequest.Submission_Date__c = Date.today(); //TODO:  check with G-tech
            currentRequest.CSV_Upload_Errors__c = '';
            currentRequest.OwnerId = newRequest.OwnerId;
            currentRequest.Request_Status__c='New';
            currentRequest.LOC_Request_Number__c = newRequest.LOC_Request_Number__c; 
            currentRequest.Signer_First_Name__c = newRequest.Signer_First_Name__c; 
            currentRequest.Signer_Last_Name__c = newRequest.Signer_Last_Name__c; 
            currentRequest.Signer_Title__c = newRequest.Signer_Title__c; 
            currentRequest.Request_Type__c = newRequest.Request_Type__c; 
            currentRequest.Therapeutic_Area__c= newRequest.Therapeutic_Area__c;
            currentRequest.OwnerId = newRequest.OwnerId; 
            currentRequest.Current_Affiliation_Start_Date__c = newRequest.Current_Affiliation_Start_Date__c; 
            currentRequest.Current_GPO__c = newRequest.Current_GPO__c;
            currentRequest.Previous_GPO__c = newRequest.Previous_GPO__c; 
            currentRequest.Submission_Date__c = newRequest.Submission_Date__c; 
            currentRequest.Attestation_signed__c = newRequest.Attestation_signed__c;
            currentRequest.email__c = newRequest.Email__c;                       
            currentRequest.Phone_Number__c= newRequest.Phone_Number__c;             
            
            integer index = 0;
            system.debug('row: ' + row);
            for(String token : row) {                
                token = token.trim();
                
                // Common fields
                if(index == 0) {
                    system.debug('token for 0: ' + token);
                    if(emptyString(token)) {
                        cr.nameError = true;
                    }
                    currentRequest.Participant_s_Name__c = token;
                }
                else if(index == 1) {
                    if(emptyString(token)) {
                        cr.addrError = true;
                    }
                    currentRequest.Address_Line_1__c = token;
                }
                else if(index == 2) {
                    currentRequest.Address_Line_2__c = token;
                }
                else if(index == 3) {
                    if(emptyString(token)) {
                        cr.cityError = true;
                    }
                    currentRequest.City__c = token;
                }
                else if(index == 4) {                    
                   
                     if(emptyString(token)) {
                        cr.stateError = true;
                    }else {
                        String s = validState(token, stateValues);
                        if(s.trim().length()>0) {
                        currentRequest.State_from_CSV__c = s;
                        currentRequest.State__c = s;
                        }
                        else{
                            currentRequest.State_from_CSV__c = token;
                            currentRequest.CSV_Upload_Errors__c += 'State is invalid;';
                        }
                    }
                }
                else if(index == 5) {
                    if(emptyString(token)) {
                        cr.zipError = true;
                    }else {
                    
                        Pattern zipCodeChecker = Pattern.compile('^(\\d{5}(\\-\\d{4})?)?$');
                        Matcher myMatcher = zipCodeChecker.matcher(token);
                    
                        if(myMatcher.matches()){
                        
                            currentRequest.Zip_Postal_Code__c = token; 
                        } else{
                        
                            currentRequest.Zip_Postal_Code__c = ''; 
                        }
                    }
                }
                else if(index == 6) {
                    // Store original value for display
                    currentRequest.DEA__c = token;

                    // Truncate, if necessary, for lookup
                    if(token == null) token = '';
                    if(token.length() > 9) {
                        token = token.substring(0, 9);
                    }
                    deaIds.add(token);
                }
                else if(index == 7) {
                    // Store original value for display
                    currentRequest.HIN__c = token;

                    // Truncate, if necessary, for lookup
                    if(token == null) token = '';
                    if(token.length() > 9) {
                        token = token.substring(0, 9);
                    }
                    hinIds.add(token);
                }
                else if(index == 8) {
                    // Store original value for display
                    currentRequest.X340B_ID__c = token;

                    if(token == null) token = '';
                    if(token.length() > 20) {
                        cr.x340bWarning = true;
                    }
                }
                
                // Hospital
                if(newRequest.Request_Type__c == HOSPITAL) {
                    if(index == 9) {                        
                        if(!classOfTradeValues.contains(token)) {
                            currentRequest.CSV_Upload_Errors__c += 'Class of Trade is invalid;';
                            currentRequest.Class_of_Trade_Not_Found__c = TRUE;
                            currentRequest.Class_of_Trade__c = token;
                            currentRequest.Class_of_Trade_from_CSV__C = 'None Provided'; 
                        }
                        else {                           
                            currentRequest.Class_of_Trade__c = token;
                            currentRequest.Class_of_Trade_from_CSV__c = token;
                        }                        
                    }
                }
                else if(newRequest.Request_Type__c == ONCOLOGY || newRequest.Request_Type__c == RHEUMATOLOGY) {
                    // No new fields
                }
                else if(newRequest.Request_Type__c == OPHTHALMOLOGY) {
                    // Just inherit
                    string lrp = this.staging.LRP__c;
                    currentRequest.LRP__c = lrp;
                    lrpIds.add(lrp);
                    currentRequest.Ophthalmology_ID_1__c = this.staging.Ophthalmology_ID_1__c;
                    currentRequest.Ophthalmology_ID_2__c = this.staging.Ophthalmology_ID_2__c;
                }

                index++;
            }

            childrenToInsert.add(currentRequest);
        }
                
        // Second pass:
        // Hospital:  check for DEA# and address + HIN#
        // Oncology/Rheumatology :  check for HIN#, name, and address + DEA#
        // Ophthalmology:  check for LRP# + DEA# + HIN#
        List<Customer_ID_DEA_Registry_DEA__c> deas = [SELECT DEA__c, Full_Name__c, Address_1__c FROM Customer_ID_DEA_Registry_DEA__c WHERE DEA__c IN :deaIds and Expiration_Date__c>=:System.today()];             
        Map<string, string> deaNames = new Map<string, string>();
        Map<string, string> deaAddresses = new Map<string, string>();
        Set<string> foundDeaIds = new Set<string>();
        for(Customer_ID_DEA_Registry_DEA__c dea : deas) {
            foundDeaIds.add(dea.DEA__c);
            deaNames.put(dea.DEA__c, this.removeSpecialCharacters(dea.Full_Name__c));
            deaAddresses.put(dea.DEA__c, this.removeSpecialCharacters(dea.Address_1__c));
        }
        
        List<Customer_ID_HIBCC_HIN__c> hins = [SELECT HIN__c, Name__c, Address1__c FROM Customer_ID_HIBCC_HIN__c WHERE HIN__c IN: hinIds];   
        Map<string, string> hinNames = new Map<string, string>();
        Map<string, string> hinAddresses = new Map<string, string>();
        Set<string> foundHinIds = new Set<string>();
        for(Customer_ID_HIBCC_HIN__c hin : hins) {
            foundHinIds.add(hin.HIN__c);
            hinNames.put(hin.HIN__c, this.removeSpecialCharacters(hin.Name__c));
            hinAddresses.put(hin.HIN__c, this.removeSpecialCharacters(hin.Address1__c));
        }
            
        List<Customer_ID_Genentech_LRP__c> lrps = [SELECT LRP_Id__c, Name__c, Address1__c FROM Customer_ID_Genentech_LRP__c WHERE LRP_Id__c IN: lrpIds];   
        Map<string, string> lrpNames = new Map<string, string>();
        Map<string, string> lrpAddresses = new Map<string, string>();
        Set<string> foundLrpIds = new Set<string>();
        for(Customer_ID_Genentech_LRP__c lrp : lrps) {
            foundLrpIds.add(lrp.LRP_Id__c);
            lrpNames.put(lrp.LRP_Id__c, this.removeSpecialCharacters(lrp.Name__c));
            lrpAddresses.put(lrp.LRP_Id__c, this.removeSpecialCharacters(lrp.Address1__c));
        }

        for(C_OPS_LOC_REQUEST__c child : childrenToInsert) {
            string participantName = this.removeSpecialCharacters(child.Participant_s_Name__c);
            string address1 = this.removeSpecialCharacters(child.Address_Line_1__c);
            string dea = child.DEA__c;
            string hin = child.HIN__c;
            string lrp = newRequest.LRP__c;
            string x340b = child.X340B_ID__c;
            
            // truncate values if they are too long
            if(dea == null) dea = '';
            if(hin == null) hin = '';
            if(lrp == null) lrp = '';
            if(x340b == null) x340b = '';
            
            if(dea.length() > 9) {
                dea = dea.substring(0, 9);
                child.DEA__C = dea;
            }
            if(hin.length() > 9) {
                hin = hin.substring(0, 9);
                child.HIN__C = hin;
            }
            if(lrp.length() > 7) {
                lrp = lrp.substring(0, 7);
                child.LRP__C = lrp;
            }
            if(x340b.length() > 20) {
                x340b = x340b.substring(0, 20);
                child.X340B_ID__c = x340b;
            }

            if(child.Request_Type__c == HOSPITAL) {
                // DEA # and address check
                if(!foundDeaIds.contains(dea)) {
                    child.DEA_Not_Found__c = TRUE;
                   // child.Address_Not_Match__c = TRUE; 
                    child.CSV_Upload_Errors__c += 'DEA not found;';
                }
                else if(deaAddresses.get(dea) != address1) {
                    child.Address_Not_Match__c = TRUE;
                    child.CSV_Upload_Errors__c += 'DEA address does not match;';                    
                } 
                 
                // HIN # check
                if(!emptyString(hin) && !foundHinIds.contains(hin)) {
                    child.HIN_Not_Found__c = TRUE;
                    child.CSV_Upload_Errors__c += 'HIN not found;';
                }
             }
            
            else if(child.Request_Type__c == ONCOLOGY || child.Request_Type__c == RHEUMATOLOGY) {
                // DEA #
                if(!emptyString(dea) && !foundDeaIds.contains(dea)) {
                    child.DEA_Not_Found__c = TRUE;
                    child.CSV_Upload_Errors__c += 'DEA not found;';
                }

                // HIN #, name, and address check
                if(!foundHinIds.contains(hin)) {
                    child.HIN_Not_Found__c = TRUE;
                    //child.Participant_Name_Not_Match__c = TRUE;
                    //child.Address_Not_Match__c = TRUE; 
                    child.CSV_Upload_Errors__c += 'HIN not found;';
                }
                else {
                    if(hinNames.get(hin) != participantName) {
                    child.Participant_Name_Not_Match__c = TRUE;
                    child.CSV_Upload_Errors__c += 'HIN participant name does not match;';                    
                    }
                    if(hinAddresses.get(hin) != address1) {
                    child.Address_Not_Match__c = TRUE;
                    child.CSV_Upload_Errors__c += 'HIN address does not match;';                    
                    }
                }
            }
            
            else if(child.Request_Type__c == OPHTHALMOLOGY) {
                // LRP #, name, and address check
                if(!foundLrpIds.contains(lrp)) {
                    child.LRP_Not_Found__c = TRUE;
                    child.CSV_Upload_Errors__c += 'LRP not found;';                    
                }

                // DEA #
                if(!emptyString(dea) &&!foundDeaIds.contains(dea)) {
                    child.DEA_Not_Found__c = TRUE;
                    child.CSV_Upload_Errors__c += 'DEA not found;';
                }
                
                // HIN # check
                if(!emptyString(hin) && !foundHinIds.contains(hin)) {
                    child.HIN_Not_Found__c = TRUE;
                    child.CSV_Upload_Errors__c += 'HIN not found;';
                }           
            }
        }            
        
        system.debug('inserting ' + childrenToInsert.size());
        system.debug(childrenToInsert[0].Participant_s_Name__c);
        if(childrenToInsert.size() > 0) {
            List<Database.SaveResult> results = Database.insert(childrenToInsert);
            for(Database.SaveResult sr : results) {
                if(!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        system.debug(err.getmessage());
                    }
                }
            }
        }

        // Update staging status
        this.staging.Request_Status__c = 'LOC Requests Created';
        update this.staging;
        
        // End: go to new upload overview.
        PageReference pr = Page.C_OPS_LOC_FINALIZE_UPLOAD;
        pr.getParameters().put('id', this.staging.Id);
        pr.setRedirect(false);
        return pr;
      }else{
          this.dupFileError =true; 
          return null;
      }
    }
    
    public PageReference doFinalize() {
        List<C_Ops_LOC_Request__c> reqs =
            [SELECT Id, Therapeutic_Area__c, DEA__c, HIN__c, LRP__c, Participant_s_Name__c, LOC_Request_Number__c
             FROM C_Ops_LOC_Request__c
             WHERE Staging_Source__c = :this.staging.Id
             LIMIT 1];
        Id requestId = reqs[0].Id;
        system.debug('requestid ' + requestId);
        system.debug('pn ' + reqs[0].Participant_s_Name__c);

        List<C_Ops_LOC_Request__c> childReqs = [SELECT Id FROM C_Ops_LOC_Request__c WHERE Parent_Request__c = :requestId];

        // Attachments to insert
        List<Attachment> attachments = new List<Attachment>(); 
        
        // ============================================================
        // Copy the .csv from the parent to each child
        // ============================================================
        List<Attachment> csv = [SELECT Id, Name, Body FROM Attachment WHERE ParentId = :requestId AND Name LIKE '%.csv' LIMIT 1];
        for(C_Ops_LOC_Request__c childReq : childReqs) {
            Attachment att = new Attachment();         
            att.Body = csv[0].Body; 
            att.Name = csv[0].Name; 
            att.ParentId = childReq.Id;
            attachments.add(att);
        }
        
        // ============================================================
        // Generate new PDF and attach to parent+children        
        // ============================================================
        PageReference pdfSummary = new PageReference('/apex/C_OPS_LOC_SUMMARY_PDF');         
        pdfSummary.getParameters().put('id', requestId);                
        blob reportBody;
        if(Test.isRunningTest()) {
            reportBody = blob.valueOf('test');
        } else {
            reportBody = pdfSummary.getContentAsPDF();         
        }
        
        // Construct attachment file name
        string idValue = '';
        if(reqs[0].Therapeutic_Area__c == NULL){                        
            idValue = reqs[0].DEA__c; 
        } else if(reqs[0].Therapeutic_Area__c == OPHTHALMOLOGY){                        
            idValue = reqs[0].LRP__c;
        } else if(reqs[0].Therapeutic_Area__c == ONCOLOGY || reqs[0].Therapeutic_Area__c == RHEUMATOLOGY){                        
            idValue = reqs[0].HIN__c; 
        }
        system.debug(reqs[0].Participant_s_Name__c);
        system.debug(idvalue);
        string attachmentName = reqs[0].Participant_s_Name__c.left(15) + '_' + idValue + '_' + reqs[0].LOC_Request_Number__c + '.pdf';
                
        // Parent request:  first check to see if the request has 
        // an attachment with the same name.  If so, it was copied
        // from the staging object and is therefore unnecessary.
        List<Attachment> attsToDelete = [SELECT Id FROM Attachment WHERE ParentId = :requestId AND Name = :attachmentName];
        delete attsToDelete;
        
        Attachment att = new Attachment();         
        att.Body = reportBody; 
        att.Name = attachmentName; 
        att.ParentId = requestId;               
        attachments.add(att);        
        
        // Child requests
        for(C_Ops_LOC_Request__c childReq : childReqs) {
            att = new Attachment();             
            att.Body = reportBody; 
            att.Name = attachmentName; 
            att.ParentId = childReq.Id;             
            attachments.Add(att); 
        }
        
        insert attachments; 

        PageReference pr = new PageReference('/' + requestId);
        return pr;
    }    
    
    private string removeSpecialCharacters(string target) { 
        Pattern alpha = Pattern.compile('[^a-zA-Z]'); 
        Matcher alphaMatcher = alpha.matcher(target); 
        
        //returns only letters from the name (to satisfy specs to be a little more receptive than full match)
        return alphaMatcher.replaceAll(''); 
    }
    
    private string removeAddressSpecialCharacters(string target) {        
        Pattern alphaNumeric = Pattern.compile('[^a-zA-z0-9]'); 
        Matcher alphaNumericMatcher = alphaNumeric.matcher(target); 
        
        //returns only letters + numbers from the address 
        return alphaNumericMatcher.replaceAll(''); 
    }    
    
    private Boolean stringInList(String s, List<String> stringList){
        Boolean result=false;
        for(string listS: stringList){
            
            if(listS.trim().equalsIgnoreCase(s.trim()) ){
                return true;
            }
        }
        return result;
    }
    
    private String validState(String s, List<String> stateValues){
        String correctSate='';
        for(string listS: stateValues){
            
            if(listS.trim().equalsIgnoreCase(s.trim()) ){
                return listS;
            }
            else if(stateCodes.get(s.toUpperCase()) != null){
                return stateCodes.get(s.toUpperCase());
            }
        }
        return correctSate;
    }
    
    private String replaceNull(String s){
        if(s==null) return '';
        else return s;
    }
 
    private List<csvRow> convertParsedCSV() {
        Schema.DescribeFieldResult stateField = C_OPS_LOC_REQUEST__c.State__c.getDescribe();
        List<Schema.PicklistEntry> stateEntries = stateField.getPicklistValues();
        List<string> stateValues = new List<string>();
        for(Schema.PicklistEntry stateEntry : stateEntries) {
            if(stateEntry.isActive()) {
                stateValues.add(stateEntry.getValue());
            }
        }
        List<csvRow> csv = new List<csvRow>();
        integer id = 0;
        for(List<string> rowData : this.parsedCSV) {
            csvRow cr = new csvRow();
            cr.id = string.valueOf(id++);
            cr.deaWarning = false;
            cr.hinWarning = false;
            cr.x340bWarning  = false;
            cr.gpoWarning = false;
            cr.gpoDateWarning = false;
            cr.nameError = false;
            cr.addrError = false;
            cr.cityError = false;
            cr.stateError = false;
            cr.zipError = false;
            cr.zipInvalid = false; 
            cr.deaError = false;
            cr.hinError = false;
            cr.classOfTradeError = false;
            
            rowData[0]=replaceNull(rowData[0]);
            string name = rowData[0];
            
            string addr;
            try {
                rowData[1]=replaceNull(rowData[1]);
                addr = rowData[1];
            } catch(Exception e) {
                addr = '';
                rowData.add('');
            }
            
            string addr2;
            try {
                rowData[2]=replaceNull(rowData[2]);
                addr2 = rowData[2];
            } catch(Exception e) {
                addr2 = '';
                rowData.add('');
            }

            string city;
            try {
                rowData[3]= replaceNull(rowData[3]);
                city =rowData[3];
            } catch(Exception e) {
                city = '';
                rowData.add('');
            }
            
            string state;
            try {
                rowData[4]=replaceNull(rowData[4]) ;             
                state = validState(rowData[4], stateValues);
                
                
            } catch(Exception e) {
                state = '';
                rowData.add('');
            }

            string zip;
            try {
                rowData[5]=replaceNull(rowData[5]);
                zip =rowData[5];
            } catch(Exception e) {
                zip = '';
                rowData.add('');
            }

            string dea;
            try {
                rowData[6]=replaceNull(rowData[6]);
                dea = rowData[6];
            } catch(Exception e) {
                dea = '';
                rowData.add('');
            }

            string hin;
            try {
                rowData[7]=replaceNull(rowData[7]);
                hin = rowData[7];
            } catch(Exception e) {
                hin = '';
                rowData.add('');
            }

            string x340b ;
            try {
                rowData[8]=replaceNull(rowData[8]);
                x340b = rowData[8];
            } catch(Exception e) {
                x340b = '';
                rowData.add('');
            }

            string previousGpo;
            try {
                rowData[9]=replaceNull(rowData[9]);
                previousGpo = rowData[9];
            } catch(Exception e){
                previousGpo = '';
                rowData.add('');
            }

            string currentGpo;
            try {
                rowData[10]=replaceNull(rowData[10]);
                currentGpo = rowData[10];
            } catch(Exception e) {
                currentGpo ='';
                rowData.add('');
            }

            string gpoDate;
            try {
                rowData[11]=replaceNull(rowData[11]);
                gpoDate = rowData[11];
            } catch(Exception e) {
                gpoDate = '';
                rowData.add('');
            }
            
            
            if(emptyString(name)) {
                cr.nameError = true;
                this.atLeastOneError = true;
            }
            
            if(emptyString(addr)) {
                cr.addrError = true;
                this.atLeastOneError = true;
            }

            if(emptyString(city)) {
                cr.cityError = true;
                this.atLeastOneError = true;
            }

           
            if(emptyString(state) ){
                cr.stateError = true;
                this.atLeastOneError = true;
            }
                    
            Pattern zipCodeChecker = Pattern.compile('^(\\d{5}(\\-\\d{4})?)?$');
            Matcher myMatcher = zipCodeChecker.matcher(zip);

            if(emptyString(zip)) {
                cr.zipError = true;
                this.atLeastOneError = true;
            } else if(!myMatcher.matches()){
                
                cr.zipInvalid = true;
                this.atLeastOneError = true;
            }
            
            if(this.staging.Request_Type__c == HOSPITAL) {
                string classOfTrade = null;
                
                // Corner-case:  The COT on the last line is blank.
                // This causes an out of bounds error, so account for that, too.
                try {
                    classOfTrade = rowData[9];
                    if(emptyString(classOfTrade)) {
                        cr.classOfTradeError = true;
                        this.atLeastOneError = true;
                    }
                } catch(Exception e) {
                    cr.classOfTradeError = true;
                    this.atLeastOneError = true;
                    rowData.add('');
                }
                
                if(emptyString(dea)) {
                    cr.deaError = true;
                    this.atLeastOneError= true;
                }
            } else if(this.staging.Therapeutic_Area__c == ONCOLOGY || this.staging.Therapeutic_Area__c == RHEUMATOLOGY) {
                if(emptyString(hin)) {
                    cr.hinError = true;
                    this.atLeastOneError= true;
                }
            }
            
            // Gather warnings
            if(!emptyString(dea) && dea.length() > 9) {
                cr.deaWarning = true;
                this.atLeastOneWarning = true;
            }
            if(!emptyString(hin) && hin.length() > 9) {
                cr.hinWarning = true;
                this.atLeastOneWarning = true;
            }
            if(!emptyString(x340b) && x340b.length() > 20) {
                cr.x340bWarning = true;
                this.atLeastOneWarning = true;
            }
            
            cr.rowData = rowData;
            csv.add(cr);
        }
        
        return csv;
    }
    
    public class csvRow {
        public string id { get; set; }
        public boolean deaWarning { get; set; }
        public boolean hinWarning { get; set; }
        public boolean x340bWarning { get; set; }
        public boolean gpoWarning { get; set; }
        public boolean gpoDateWarning { get; set; }
        
        public boolean nameError { get; set; }
        public boolean addrError { get; set; }
        public boolean cityError { get; set; }
        public boolean stateError { get; set; }
        public boolean zipError { get; set; }
        public boolean zipInvalid { get; set; }
        public boolean deaError { get; set; }
        public boolean hinError { get; set; }
        public boolean classOfTradeError { get; set; }
        public List<string> rowData { get; set; }
    }
 
    public PageReference cancelUpload() {
        PageReference pr = new PageReference('/' + this.staging.Id);
        return pr;
    }
    
    public PageReference deleteRow() {
        return deleteRow(ApexPages.currentPage().getParameters().get('rowid'));
    }
    
    public PageReference deleteRow(string rowId) {
        List<csvRow> newCsv = new List<csvRow>();
        this.atLeastOneWarning = false;
        this.atLeastOneError = false;
        for(csvRow cr : csv) {
            if(cr.id != rowId) {
                newCsv.add(cr);
                if(cr.nameError || cr.addrError || cr.cityError || cr.stateError || cr.zipError || cr.deaError || cr.hinError || cr.classOfTradeError) {
                    this.atLeastOneError = true;
                }
                if(cr.deaWarning || cr.hinWarning || cr.x340bWarning) {
                    this.atLeastOneWarning = true;
                }
            }
        }
        
        this.csv = newCsv;
        return null;
    }
    
    public void loadStateCodes(){
        if(stateCodes!=null && stateCodes.size()>0) return;
        stateCodes.put('AL', 'Alabama');
        stateCodes.put('AK', 'Alaska');
        stateCodes.put('AZ', 'Arizona');
        stateCodes.put('AR', 'Arkansas');
        stateCodes.put('CA', 'California');
        stateCodes.put('CO', 'Colorado');
        stateCodes.put('CT', 'Connecticut');
        stateCodes.put('DE', 'Delaware');
        stateCodes.put('DC', 'District of Columbia');
        stateCodes.put('FL', 'Florida');
        stateCodes.put('GA', 'Georgia');
        stateCodes.put('HI', 'Hawaii');
        stateCodes.put('ID', 'Idaho');
        stateCodes.put('IL', 'Illinois');
        stateCodes.put('IN', 'Indiana');
        stateCodes.put('IA', 'Iowa');
        stateCodes.put('KS', 'Kansas');
        stateCodes.put('KY', 'Kentucky');
        stateCodes.put('LA', 'Louisiana');
        stateCodes.put('MA', 'Massachusetts');
        stateCodes.put('ME', 'Maine');
        stateCodes.put('MD', 'Maryland');
        stateCodes.put('ME', 'Massachusetts');
        stateCodes.put('MI', 'Michigan');
        stateCodes.put('MN', 'Minnesota');
        stateCodes.put('MS', 'Mississippi');
        stateCodes.put('MO', 'Missouri');
        stateCodes.put('MT', 'Montana');
        stateCodes.put('NE', 'Nebraska');
        stateCodes.put('NV', 'Nevada');
        stateCodes.put('NH', 'New Hampshire');
        stateCodes.put('NJ', 'New Jersey');
        stateCodes.put('NM', 'New Mexico');
        stateCodes.put('NY', 'New York');
        stateCodes.put('NC', 'North Carolina');
        stateCodes.put('ND', 'North Dakota');
        stateCodes.put('OH', 'Ohio');
        stateCodes.put('OK', 'Oklahoma');
        stateCodes.put('OR', 'Oregon');
        stateCodes.put('PA', 'Pennsylvania');
        stateCodes.put('RI', 'Rhode Island');
        stateCodes.put('SC', 'South Carolina');
        stateCodes.put('SD', 'South Dakota');
        stateCodes.put('TN', 'Tennessee');
        stateCodes.put('TX', 'Texas');
        stateCodes.put('UT', 'Utah');
        stateCodes.put('VT', 'Vermont');
        stateCodes.put('VA', 'Virginia');
        stateCodes.put('WA', 'Washington');
        stateCodes.put('WV', 'West Virginia');
        stateCodes.put('WI', 'Wisconsin');
        stateCodes.put('WY', 'Wyoming');
    }
}