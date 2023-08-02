public class C_OPS_LOC_STG_REQ_PDF{
    
    public C_OPS_LOC_REQUEST_Staging__C mainRequest {get; set;}
    public Attachment pdfSummary {get;set;}
    private C_Ops_LOC_Form_Property__c formProperty; 
    
    string theRequestID; //to be passed in constructor
    
    //BEGIN CONSTRUCTOR
    
    public C_OPS_LOC_STG_REQ_PDF(ApexPages.StandardController controller){
        
        theRequestID = controller.getId();
            
        mainRequest = [SELECT Request_Type__c,Participant_s_Name__c, Class_of_Trade__c, DEA__c, HIN__c, X340B_ID__c, Address_Line_1__c, Address_Line_2__c, City__c, State__c, Zip__c, Phone_Number__c, Email__c, Previous_GPO__c, Current_GPO__c, 
                      Current_Affiliation_Start_Date__c, LRP__c, Ophthalmology_ID_1__c, Ophthalmology_ID_2__c, Therapeutic_Area__c, Class_of_Trade_Other__c, LOC_Request_Number__c,
                       Attestation_Signed__C, Signer_First_Name__C, Signer_Last_Name__C, Signer_Title__c, Submission_Date__c FROM C_OPS_LOC_REQUEST_Staging__C where ID =: theRequestID]; 
        
        pdfSummary = [SELECT NAME from Attachment where parentID =: theRequestID and (name like '%.csv' OR name like '%.xlsx' or name like '%.xls') LIMIT 1]; 
        formProperty = [SELECT Attestation_Language__c,ID, NAME, Certification_Language__c, Affiliation_Legal_Language__c, Therapeutic_Area__c, checkbox_language_single_site__c, Checkbox_Language_Multiple_Sites__c from C_Ops_LOC_Form_Property__c 
                                where Therapeutic_Area__C =: mainRequest.Request_Type__c and  Is_Active__c=True LIMIT 1]; 
    }
    
    //END CONSTRUCTOR
    
    //BEGIN VISIBILITY FUNCTIONS
    public C_Ops_LOC_Form_Property__c getFormProperty(){        
        return formProperty; 
    }
        
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
    
    public boolean getRenderCOTOther(){
        
        if(mainRequest.Class_of_Trade__c == 'Other (Please Enter Below)'){
            
            return true;
        }
        
        return false;
    }
    
    //END VISIBILITY FUNCTIONS
}