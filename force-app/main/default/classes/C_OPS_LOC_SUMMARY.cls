//Controller to be used by the summary page since we're true redirecting on the last page and this only needs a limited subset of data
public class C_OPS_LOC_SUMMARY {

	private Boolean emptyString(String s){
        if(s==null || s.trim().length()<=0) return true;
        else return false;
    }

    public C_OPS_LOC_REQUEST__C mainRequest {get; set;}
    //we can query for the child requests since we have the mainRequest Inserted
    public List<C_OPS_LOC_REQUEST__C> childRequests {get; set;}
    public LIST<Attachment> uploadDocs {get;set;}
    
    string theRequestID; //to be passed in constructor
    id parentID; 
    
    C_Ops_LOC_Form_Property__c formProperty; 
    
    public C_OPS_LOC_SUMMARY (ApexPages.StandardController controller){
        
        theRequestID = controller.getId();
        
        System.debug('My ID parameter is:' + controller.getID() );
            
        mainRequest = [SELECT Participant_s_Name__c, Class_of_Trade__c, DEA__c, HIN__c, X340B_ID__c, Address_Line_1__c, Address_Line_2__c, City__c, State__c, Zip_Postal_Code__c, Phone_Number__c, Email__c, Previous_GPO__c, Current_GPO__c, 
                      Current_Affiliation_Start_Date__c, LRP__c, Ophthalmology_ID_1__c, Ophthalmology_ID_2__c, Therapeutic_Area__c, Class_of_Trade_Other__c, LOC_Request_Number__c  FROM C_OPS_LOC_REQUEST__C where ID =: theRequestID]; 
        
        parentID = mainRequest.ID;
        
        //now get the child requests 
        childRequests = [SELECT Participant_s_Name__c, Class_of_Trade__c, DEA__c, HIN__c, X340B_ID__c, Address_Line_1__c, Address_Line_2__c, City__c, State__c, Zip_Postal_Code__c, Phone_Number__c, Email__c, Previous_GPO__c, Current_GPO__c, 
                      Current_Affiliation_Start_Date__c, LRP__c, Ophthalmology_ID_1__c, Ophthalmology_ID_2__c, Therapeutic_Area__c, Class_of_Trade_Other__c, LOC_Request_Number__c FROM C_OPS_LOC_REQUEST__C where Parent_Request__C =: parentID];
        
        string TheraArea; 
        TheraArea = mainRequest.Therapeutic_Area__c; 
        
        if(emptyString(theraArea)){
            
            //hospitalRequest
            formProperty = [SELECT id, Certification_Language__c from C_Ops_LOC_Form_Property__C where Therapeutic_Area__c = 'Hospital' and  Is_Active__c=True LIMIT 1];
        }
        
        else{
        
                formProperty = [SELECT id, Certification_Language__c from C_Ops_LOC_Form_Property__C where Therapeutic_Area__c =: TheraArea and  Is_Active__c=True LIMIT 1]; 
        }
        
        uploadDocs = [SELECT Id, Name, ParentId from Attachment where parentId =: parentID and NAME like '%.csv']; 
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
    
    public boolean getUploadSites(){
        
        if(uploadDocs.size() == 1){
            
            return TRUE; 
        }
        
        return FALSE; 
    }
    
    public string getAttachmentName(){
        
        if(!emptyString(uploadDocs[0].name)){
            
            return uploadDocs[0].name; 
        }
        
        return '';
    }
    
    public string getRequestNumber(){
        
        return mainRequest.LOC_Request_Number__c; 
    }
    
    public PageReference backToLanding(){
        
        pageReference c_ops_landing_page = new pageReference('/apex/C_OPS_LOC_CUST_LANDING');
        c_ops_landing_page.setRedirect(true);
        return c_ops_landing_page;  
    }
    
    public pageReference moveToPrintSummary(){
        
        pageReference c_ops_loc_summary_pdf = new PageReference('/apex/c_ops_loc_summary_pdf'); 
        c_ops_loc_summary_pdf.getParameters().put('id',mainRequest.id); 
        c_ops_loc_summary_pdf.setRedirect(true); 
        
        return c_ops_loc_summary_pdf; 
    }
        
    public PageReference startNewSubmission(){
        
        pageReference C_OPS_LOC_LANDING_PAGE = Page.C_OPS_LOC_CUST_LANDING; 
        c_ops_loc_landing_page.setRedirect(true);
        return c_ops_loc_landing_page; 
    }
    
    //END VISIBILITY FUNCTIONS
}