public with sharing class C_OPS_LOC_ERROR_HANDLER_EXTENSION{

    public PageReference updateCOT(){
        //not need to do anything, just refersh page to reflect change on COT correction field
        return null;
    }

    private C_Ops_LOC_Request__c myRequest;
    private String copy_of_status; //why is this necessary?
    
    public C_OPS_LOC_ERROR_HANDLER_EXTENSION(ApexPages.StandardController stdController) {
        
        this.myRequest = (C_Ops_LOC_Request__c)stdController.getRecord(); 
        copy_of_status = myRequest.Request_Status__c;
    }
    
    public pageReference getValidationStatus(){
        
        if(myRequest.Assign_To__c <> UserInfo.getUserId()){
               
             PageReference newPage = New PageReference('/apex/C_OPS_LOC_PERMISSION_DENIED');
             newPage.getParameters().Put('id', myRequest.ID); 
             newPage.setRedirect(true);
             return newPage;
        }

        else{
            
            return null; 
        }   
    }
    
    public boolean getRenderHIN(){
        
        boolean val = false;
        
        if(myRequest.Request_Type__C == 'Hospital' || myRequest.Request_Type__C == 'Oncology' || myRequest.Request_Type__c == 'Rheumatology'){
            
            val = true;
        }
        
        return val; 
    }
    
    public boolean getRenderDEA(){
        
        boolean val = false;
        
        if(myRequest.Request_Type__C == 'Hospital'){
            
            val = true; 
        }
        
        return val; 
    }
    
    public boolean getRenderLRP(){
        
        boolean val = false;
        
        if(myRequest.Request_Type__C == 'Ophthalmology'){
            
            val = true;
        }
        
        return val; 
    }
    
    public boolean getRender340B(){
        
        boolean val = false; 
        
        if(myRequest.Request_Type__C == 'Hospital'){
            
            val = true;
        }
        
        return val; 
    }
    
    public boolean getRenderClassOfTrade(){
        
        boolean val = false;
        
        if(myRequest.Request_Type__C == 'Hospital'){
            
            val = TRUE; 
        }
        
        return val;
    }
    
    public boolean getRenderClassOfTradeOther(){
        
        if((myRequest.Class_of_Trade__c !=null && myRequest.Class_of_Trade__c.containsIgnoreCase('other')) || 
          (myRequest.Class_of_Trade_Correction__c !=null && myRequest.Class_of_Trade_Correction__c.containsIgnoreCase('other')))
          
          return true;
          
        else return false;  
        
       
    }
    
    public boolean getRenderOpt(){
        
        boolean val = false; 
        
        if(myRequest.Request_Type__C == 'Ophthalmology'){
            
            val = TRUE;
        }
        
        return val; 
    }
    
    
    public PageReference save() {
        
        Boolean errorEncountered = FALSE;
        string  errorText='';
        
        

        //check to make sure the user who's updating the record owns it
        id userid = UserInfo.getUserId(); 
        
        Pattern alphaNumericOnly = Pattern.compile('^[a-zA-Z0-9]*$');
        Pattern addressesOnly = Pattern.compile('^[a-zA-Z0-9 .#]*$');
        Pattern numericOnly = Pattern.compile('^[0-9]*$');
        Pattern zipCodeChecker = Pattern.compile('^(\\d{5}(\\-\\d{4})?)?$');
        
        Matcher x340BID;
        Matcher deaMatcher;
        Matcher hinMatcher;
        Matcher zipMatcher; 
        
        if(myRequest.Zip_Correction__c != NULL){
            
            zipMatcher = ZipCodeChecker.matcher(myRequest.Zip_Correction__c);
        } else{
            
            zipMatcher = ZipCodeChecker.matcher(myRequest.Zip_Postal_Code__c);
        }
        
        Matcher lrpMatcher;
        
        if(myRequest.X340B_ID_Correction__c != NULL){
            
            x340BID = AlphaNumericOnly.matcher(myRequest.X340B_ID_Correction__c);
        }
        
        if(myRequest.DEA_Correction__c != NULL){
            
            deaMatcher = AlphaNumericOnly.matcher(myRequest.DEA_Correction__c);
        }
        
        if(myRequest.HIN_Correction__c != NULL){
            
            hinMatcher = AlphaNumericOnly.matcher(myRequest.HIN_Correction__c); 
        }
        
        if(myRequest.LRP_Correction__c != NULL){
            
            lrpMatcher = AlphaNumericOnly.matcher(myRequest.LRP_Correction__c);
        }
        
        if(!zipMatcher.matches()){
            
            errorEncountered = TRUE;
            errorText = 'Zip Codes must be numeric only and in either xxxxx or xxxxx-xxxx format, review the zip code.';
            myRequest.Zip_Correction__c.AddError(errorText);
        }
        
        if(myRequest.X340B_ID_Correction__c != NULL){
            if(!x340BID.matches()){              
                errorEncountered = TRUE;
                errorText = '340 B ID # must contain only AlphaNumeric characters. Remove any special characters'; 
                myRequest.X340B_ID_Correction__c.AddError(errorText); 
            }
        }
        
        if(myRequest.DEA_Correction__c != NULL){
            if(!deaMatcher.matches() || myRequest.DEA_Correction__c.Length() > 9){
                
                errorEncountered = TRUE; 
                errorText = 'DEA #s must contain only AlphaNumeric characters and have a maximum length of 9. Please review the DEA #.'; 
                myRequest.DEA_Correction__c.AddError(errorText);
            }
        }
        
        if(myRequest.HIN_Correction__c != NULL){
            if(!hinMatcher.matches()){
                
                errorEncountered = TRUE;
                errorText = 'HIN #s must contain only AlphaNumeric characters. Please Review the HIN #.';
                myRequest.HIN_Correction__c.AddError(errorText);
            }
        }
        
        if(myRequest.LRP_Correction__c != NULL){
        
            if(!lrpMatcher.matches()){
                
                errorEncountered = TRUE;
                errorText = 'LRP #s must contain only AlphaNumeric characters. Please review the LRP #.';
                myrequest.LRP_Correction__c.AddError(errorText);
            }
        }
        
        if(errorEncountered){
            
            return ApexPages.currentPage(); 
        }
        
        else{
            if((myRequest.Class_of_Trade_Correction__c==null)||(myRequest.Class_of_Trade_Correction__c!=null && (myRequest.Class_of_Trade_Correction__c.containsIgnoreCase('Other')==false))) {
            
                myRequest.Class_of_Trade_Other_Correction__c='';
            }
            update myRequest; 
            PageReference newPage = New PageReference('/' + myRequest.Id);
            newPage.setRedirect(true);
            return newPage;
        }
    }
}