//Added By: Paras Sharma
//Updated by Orhan Karzan 12/16/2008 bacause it was using 
// mergeFields at SCM_MergeFieldGroup which was replaced by subFields at SCM_MergeField
 

public class SCM_MFG_AdditionalInfoReq_Luc extends SCM_MergeFieldGroup{

	public SCM_MFG_AdditionalInfoReq_Luc()
	{
		super();
		
    	// The label property will go into the <legend> tag of the fieldset.
    	// Venkatesh -- The label for a merge field group is actually the headerText.
		//label = 'Additional Information Required';
		headerText = 'Additional Information Required'; 
		
				
		// The headerText property will be displayed in a div for hint text.
		//headerText = '';
		
		key = 'additional_info';
		// Code Review -- Venkatesh
		// I have set the totalWidth property for checkbox since they control the styles. 
		
		SCM_MergeFieldCheckbox chk1 = 
			new SCM_MergeFieldCheckbox('completed_GATCFform', 'A completed Genentech® Access To' 
			+ 'Care Foundation Application Form');
		//chk1.fieldValue = chk1.checked ? '• A completed Genentech Access To Care Foundation Application Form \r\n': '';
		chk1.setfieldValue('• A completed Genentech® Access To Care Foundation Application' 
		+ 'Form \r\n');
		chk1.totalWidth = '900';
		 
		SCM_MergeFieldCheckbox chk2 = new SCM_MergeFieldCheckbox('pat_AuthNotRelform', ''
		+ 'Genentech® Patient Authorization Notification & Release of Information form');
		//chk2.fieldValue = chk2.checked ? '• Genentech Patient Authorization Notification & Release of Information form \r\n': '';
		chk2.setfieldValue('• Genentech® Patient Authorization Notification And Release of' 
		+ 'Information form \r\n');
		chk2.totalWidth = '900';
		
		SCM_MergeFieldCheckbox chk3 = new SCM_MergeFieldCheckbox('flow_sheets', ''
		+ 'Flow sheets/Infusion records that reflect administration of product');
		//chk3.fieldValue = chk3.checked ? '• The infusion record should provide the following details:\r\n	• Product name\r\n  • Dosage administered\r\n	• Date of administration \r\n': '';
		chk3.setfieldValue('• The infusion record should provide the following details:\r\n	• '
		+ 'Product name\r\n	• Dosage administered\r\n	• Date of administration \r\n');
		chk3.totalWidth = '900';
		
		SCM_MergeFieldCheckbox chk4 = new SCM_MergeFieldCheckbox('ins_denial', 'Insurance '
		+ 'denial letter/EOB or a statement on your office letterhead confirming patient\'s '
		+ 'lack of insurance');
		//chk4.fieldValue = chk4.checked ? '• Insurance denial letter/EOB or a statement on your office letterhead confirming patient\'s lack of insurance \r\n': '';
		chk4.setfieldValue('• Insurance denial letter/EOB or a statement on your office '
		+ 'letterhead confirming patient\'s lack of insurance \r\n');
		chk4.displayLabel=false;
		chk4.displayExtraHTML = true;
		chk4.extraHTML='Insurance denial letter/EOB or a statement on your office <br> '
		+ 'letterhead confirming patient\'s lack of insurance \r\n';
		chk4.totalWidth = '900';
		
		SCM_MergeFieldCheckbox chk5 = new SCM_MergeFieldCheckbox('icd9_code', 'Patient\'s '
		+ 'ICD-9 code / Diagnosis');
		//chk5.fieldValue = chk5.checked ? '• Patient\'s ICD-9 code/Diagnosis \r\n': '';
		chk5.setfieldValue('• Patient\'s ICD-9 code/Diagnosis \r\n');
		chk5.totalWidth = '900';
		
		SCM_MergeFieldCheckbox chk6 = new SCM_MergeFieldCheckbox('pat_income_less', ''
		+ 'Patient\'s Household Adjusted Gross Income is less than $100,000');
		//chk6.fieldValue = chk6.checked ? '• Patient\'s Household Adjusted Gross Income is less than $100,000 \r\n': '';
		chk6.setfieldValue('• Patient\'s Household Adjusted Gross Income is less than '
		+ '$100,000 \r\n');
		chk6.totalWidth = '900';
		
		SCM_MergeFieldCheckbox chk7 = new SCM_MergeFieldCheckbox('ship_instruct', 'Shipping '
		+ 'Instructions');
		//chk7.fieldValue = chk7.checked ? '• Shipping Instructions \r\n': '';
		chk7.setfieldValue('• Shipping Instructions \r\n');
		chk7.totalWidth = '900';
		
		SCM_MergeFieldCheckbox chk8 = new SCM_MergeFieldCheckbox('date_phy_sign', 'Date and/or '
		+ 'Physician Signature');
		//chk8.fieldValue = chk8.checked ? '• Date and/or Physician Signature \r\n': '';
		chk8.setfieldValue('• Date and/or Physician Signature \r\n');
		chk8.totalWidth = '900';
		
		
		subFields.add(chk1);
    	subFields.add(chk2);
    	subFields.add(chk3);
    	subFields.add(chk4);
    	subFields.add(chk5);
    	subFields.add(chk6);
    	subFields.add(chk7);
    	subFields.add(chk8);
    	
	}
	
	// Venkateh -- even though the logic is right, it does not work. I have raised an issue in the Issue tracker.
	public override Boolean getVisible()
	{
		// We need to override the fieldValue property to return false if none of the checkboxes are checked.
		for( Integer i = 0; i < subFields.size(); i++ )
		{
			if( subFields[i].checked )
			{
				// All it takes is one value to be checked for this whole section to be visible.
				return true;
			}
		}
		// None were checked.
		return false;
	}
	
}