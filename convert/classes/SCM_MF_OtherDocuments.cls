public class SCM_MF_OtherDocuments extends SCM_Mergefield{

	public SCM_MF_OtherDocuments(String Key,String Label) {              
        this.Key = Key;
        this.Label = Label;  
        this.className = 'SCM_MF_OtherDocuments';        
        this.fieldValue= '';  
        this.checked = false;
        this.displayCheck = false;
        this.displayTextArea = false;
        this.displayTextBox = true;
        this.displayLabel = true;
        this.isRequired = false;
        this.totalWidth='400';
        this.requireNewLineInTemplate = true;                
    }    
}