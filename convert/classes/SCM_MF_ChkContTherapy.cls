//Created By: Paras Sharma
/**
If Case.Product_gne__c = Tarceva, then Merge
Join Case.Medical_History_gne__c to Medical History.ID and select Medical History.Therapy_Type_gne__c
If Medical History.Therapy_Type_gne__c = “Continued” then merge (checked), else (unchecked)
*/
/** 
Constructor with 2 parameters works for all products and Medical History.Therapy_Type_gne__c = “C”
*/
/**
Constructor with 3 parameters works for all products and Medical History.Therapy_Type_gne__c = “Continued”
*/
public class SCM_MF_ChkContTherapy extends SCM_MF_MedicalHistoryCollection{

	private Case selectCase;
	boolean allProducts;
	
	public SCM_MF_ChkContTherapy(Case selCase) {    
    	
    	super(selCase.Medical_History_gne__r.Id);
    	selectCase = selCase;
    	checked = false;
    	displayCheck = false;
    	displayTextBox = false;
    	displayLabel = false;
    	key = 'ContinuedTherapy';
    	ClassName = 'SCM_MF_ChkContTherapy';
    	fieldValue = GetTherapyTypeValue();    	
  	}
  	
  	public SCM_MF_ChkContTherapy(Case selCase, boolean allProducts) {    
    	
    	super(selCase.Medical_History_gne__r.Id);
    	selectCase = selCase;
    	checked = false;
    	displayCheck = false;
    	displayTextBox = false;
    	displayLabel = false;
    	key = 'ContinuedTherapy';
    	ClassName = 'SCM_MF_ChkContTherapy';
    	if(allProducts == true){
    		fieldValue = GetTherapyTypeValueAll();
    	}
    	else {
    		fieldValue = SCM_CheckBox_Values.Unchecked;
    	}      	
  	}
  	
  	public SCM_MF_ChkContTherapy(Case selCase, boolean allProducts, boolean oldConvention) {    
    	
    	super(selCase.Medical_History_gne__r.Id);
    	selectCase = selCase;
    	checked = false;
    	displayCheck = false;
    	displayTextBox = false;
    	displayLabel = false;
    	key = 'ContinuedTherapy';
    	ClassName = 'SCM_MF_ChkContTherapy';
    	if(allProducts == true && oldConvention == true){
    		fieldValue = GetTherapyTypeValueAllOldConv();
    	}
    	else {
    		fieldValue = SCM_CheckBox_Values.Unchecked;
    	}     	
  	}
  	private string GetTherapyTypeValue() {
  		string returnValue = '' ;
  		try {
  		if(selectCase.Product_gne__c == 'Tarceva')
  		{
	  		if(medicalHistory != null){
	  			if(medicalHistory.Therapy_Type_gne__c != null)
	  				returnValue = medicalHistory.Therapy_Type_gne__c;
	  		}
  		}
  		
  		if (returnValue.equalsIgnoreCase('Continued')) {
            returnValue = SCM_CheckBox_Values.Checked;
  		}
        else {
            returnValue = SCM_CheckBox_Values.Unchecked;
        }
        }catch (exception ex){
    		returnvalue = SCM_CheckBox_Values.Unchecked;	
    	}
        return returnValue;
  	}
  	
  	private string GetTherapyTypeValueAll() {
  		string returnValue = '' ;
  		try {
  		if(medicalHistory != null){
  			if(medicalHistory.Therapy_Type_gne__c != null)
  				returnValue = medicalHistory.Therapy_Type_gne__c;
	  	}
  		
  		if (returnValue.equalsIgnoreCase('Continued')) {
            returnValue = SCM_CheckBox_Values.Checked;
  		}
        else {
            returnValue = SCM_CheckBox_Values.Unchecked;
        }
        }catch (exception ex){
    		returnvalue = SCM_CheckBox_Values.Unchecked;	
    	}
        return returnValue;
  	}
  	
  	private string GetTherapyTypeValueAllOldConv() {
  		string returnValue = '' ;
  		try {
  		if(medicalHistory != null){
  			if(medicalHistory.Therapy_Type_gne__c != null)
  				returnValue = medicalHistory.Therapy_Type_gne__c;
	  	}
  		
  		if (returnValue.equalsIgnoreCase('Continued')) {
            returnValue = SCM_CheckBox_Values.Checked;
  		}
        else {
            returnValue = SCM_CheckBox_Values.Unchecked;
        }
        }catch (exception ex){
    		returnvalue = SCM_CheckBox_Values.Unchecked;	
    	}
        return returnValue;
  	}
  	
  	public override String getFieldValue() { 
         return fieldValue;    
  	}
}