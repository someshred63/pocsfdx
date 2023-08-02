public class C_OPS_LOC_REQ_PDF{
    
    public C_OPS_LOC_REQUEST__C mainRequest {get; set;}
    //we can query for the child requests since we have the mainRequest Inserted
    public List<C_OPS_LOC_REQUEST__C> childRequests {get; set;}
    private C_Ops_LOC_Form_Property__c formProperty; 
    
    string theRequestID; //to be passed in constructor
    id parentID; 
    
    //BEGIN CONSTRUCTOR
    
    public C_OPS_LOC_REQ_PDF(ApexPages.StandardController controller){
        PageReference curPage=ApexPages.currentPage();       
           if(curPage.getParameters()!=null) {

               //adding in handling for test class since below code doesn't work in unit tests
               if(test.isRunningTest()){
                   
                   theRequestID = controller.getID();
               } else{
                   
                   theRequestID =curPage.getParameters().get('id');
               }
           }
           else theRequestID = controller.getID();  
        
        mainRequest = [SELECT Request_Type__c, Participant_s_Name__c, Class_of_Trade__c, DEA__c, HIN__c, X340B_ID__c, Address_Line_1__c, Address_Line_2__c, City__c, State__c, Zip_Postal_Code__c, Phone_Number__c, Email__c, Previous_GPO__c, Current_GPO__c, 
                      Current_Affiliation_Start_Date__c, LRP__c, Ophthalmology_ID_1__c, Ophthalmology_ID_2__c, Therapeutic_Area__c, Class_of_Trade_Other__c, LOC_Request_Number__C, Attestation_Signed__C, 
                       Signer_First_Name__c, Signer_Last_Name__c, Submission_Date__c, Signer_Title__c FROM C_OPS_LOC_REQUEST__C where ID =: theRequestID]; 
        
        parentID = mainRequest.ID;
        
        //now get the child requests 
        childRequests = [SELECT Participant_s_Name__c, Class_of_Trade__c, DEA__c, HIN__c, X340B_ID__c, Address_Line_1__c, Address_Line_2__c, City__c, State__c, Zip_Postal_Code__c, Phone_Number__c, Email__c, Previous_GPO__c, Current_GPO__c, 
                      Current_Affiliation_Start_Date__c, LRP__c, Ophthalmology_ID_1__c, Ophthalmology_ID_2__c, Therapeutic_Area__c, Class_of_Trade_Other__c, LOC_Request_Number__c  FROM C_OPS_LOC_REQUEST__C where Parent_Request__C =: parentID];
        formProperty = [SELECT Attestation_Language__c,ID, NAME, Certification_Language__c, Affiliation_Legal_Language__c, Therapeutic_Area__c, checkbox_language_single_site__c, Checkbox_Language_Multiple_Sites__c from C_Ops_LOC_Form_Property__c 
                                where Therapeutic_Area__C =: mainRequest.Request_Type__c and  Is_Active__c=True LIMIT 1]; 
    }
    //END CONSTRUCTOR
    
    public C_Ops_LOC_Form_Property__c getFormProperty(){        
        return formProperty; 
    }
    
    //BEGIN VISIBILITY FUNCTIONS
    
    public boolean getRenderHospitalEntry(){
        
        if(mainRequest.Therapeutic_Area__c == NULL){
            
            //guaranteed to be Hospital
            return TRUE;
        }
        
        return FALSE;
    }
    
    public boolean getRenderONCRheEntry(){
        
        if(mainRequest.Therapeutic_Area__c == 'Oncology' || mainRequest.Therapeutic_Area__c == 'Rheumatology'){
            
            return TRUE; 
        }
        
        return FALSE; 
    }
    
    public boolean getRenderOpth(){
        
        if(mainRequest.Therapeutic_Area__c == 'Ophthalmology'){
            
            return TRUE;
        }
        
        return FALSE; 
    }
    
    public boolean getrenderWhollyOwnedSites(){
        
        if(childRequests.size() > 0){
            
            return true; 
        }
        
        return false;
    }
    
    public boolean getRenderCOTOther(){
        
        if(mainRequest.Class_of_Trade__c == 'Other (Please Enter Below)'){
            
            return true;
        }
        
        return false;
    }
    
    public void checkLinkStatus(){
        
        return; 
    }
    
    //END VISIBILITY FUNCTIONS
}