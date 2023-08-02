public class SCM_MF_TextArea extends SCM_MergeField{
	
    public SCM_MF_TextArea() {      
        key = 'CommentField';
        label='';  
        className = 'SCM_MF_TextArea';        
        fieldValue= '';  
        checked = false;
        displayCheck = false;
        displayLabel=false;
        displayTextBox = false;
        displayTextArea = true;
        isRequired = false;
        setControlStyle('width:95%;height:95%;');
        setFieldStyle('width:95%;height:95%;');        
    }        
}