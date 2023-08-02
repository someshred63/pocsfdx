public class SCM_MFG_Denial_Lucentis_Documentation extends SCM_MergeFieldGroup {
    
    public SCM_MFG_Denial_Lucentis_Documentation()
    {
        super();
        
        // The label property will go into the <legend> tag of the fieldset.
        label = 'Documentation';

        // The headerText property will be displayed in a div for hint text.
        headerText = 'The Payor will continue medical review upon receipt of the following additional document(s):';
        
        key = 'additional_docs3';
        
        // Now, let's add a bunch of fields to the Documentation fieldset.
        // SMNComplete
        SCM_MergeFieldCheckbox chk1 = new SCM_MergeFieldCheckbox('SMNComplete', 'SMN (Complete)');
        chk1.setfieldValue('SMN (Complete) \r\n');
        chk1.totalWidth = '270';
        chk1.isNewLine = true;
        subFields.add(chk1);
        
        // HisPhysTreat
        SCM_MergeFieldCheckbox chk2 = new SCM_MergeFieldCheckbox('HisPhysTreat', 'History/Physical/Treatment Plan');
        chk2.setfieldValue('History/Physical/Treatment Plan \r\n');
        chk2.totalWidth = '270';
        chk2.isNewLine = false;
        subFields.add(chk2);
        
        // CurrentVA
        SCM_MergeFieldCheckbox chk3 = new SCM_MergeFieldCheckbox('CurrentVA', 'Current VA');
        chk3.setfieldValue('Current VA \r\n');
        chk3.totalWidth = '270';
        chk3.isNewLine = true;
        subFields.add(chk3);
        
        // FA
        SCM_MergeFieldCheckbox chk4 = new SCM_MergeFieldCheckbox('FA', 'FA');
        chk4.setfieldValue('FA \r\n');
        chk4.totalWidth = '270';
        chk4.isNewLine = false;
        subFields.add(chk4);
        
        // ProgressNotes
        SCM_MergeFieldCheckbox chk5 = new SCM_MergeFieldCheckbox('ProgresssNotes', 'Progress Notes');
        chk5.setfieldValue('Progress Notes \r\n');
        chk5.totalWidth = '270';
        chk5.isNewLine = true;
        subFields.add(chk5);
        
        // Prescription
        SCM_MergeFieldCheckbox chk6 = new SCM_MergeFieldCheckbox('Prescription', 'Prescription');
        chk6.setfieldValue('Prescription \r\n');
        chk6.totalWidth = '270';
        chk6.isNewLine = false;
        subFields.add(chk6);
        
        // OCT
        SCM_MergeFieldCheckbox chk7 = new SCM_MergeFieldCheckbox('OCT', 'OCT');
        chk7.setfieldValue('OCT \r\n');
        chk7.totalWidth = '270';
        chk7.isNewLine = true;
        subFields.add(chk7);

        // VABeforeTreat
        SCM_MergeFieldCheckbox chk8 = new SCM_MergeFieldCheckbox('VABeforeTreat', 'VA Before Treatment');
        chk8.setfieldValue('VA Before Treatment \r\n');
        chk8.totalWidth = '270';
        chk8.isNewLine = false;
        subFields.add(chk8);
        
        // LesionSize
        SCM_MergeFieldCheckbox chk9 = new SCM_MergeFieldCheckbox('LesionSize', 'Lesion Size');
        chk9.setfieldValue('Lesion Size \r\n');
        chk9.totalWidth = '270';
        chk9.isNewLine = true;
        subFields.add(chk9);
        
        // PioAuthForm
        SCM_MergeFieldCheckbox chk10 = new SCM_MergeFieldCheckbox('PioAuthForm', 'Prior Authorization Form');
        chk10.setfieldValue('Prior Authorization Form \r\n');
        chk10.totalWidth = '270';
        chk10.isNewLine = false;
        subFields.add(chk10);
        
        // PCPReferral
        SCM_MergeFieldCheckbox chk11 = new SCM_MergeFieldCheckbox('PCPReferral', 'PCP Referral');
        chk11.setfieldValue('PCP Referral \r\n');
        chk11.totalWidth = '270';
        chk11.isNewLine = true;
        subFields.add(chk11);       
                        
        // LesionType
        SCM_MergeFieldCheckbox chk12 = new SCM_MergeFieldCheckbox('LesionType', 'Lesion Type');
        chk12.setfieldValue('Lesion Type \r\n');
        chk12.totalWidth = '270';
        chk12.isNewLine = false;
        subFields.add(chk12);   
        
        // LesionPosition
        SCM_MergeFieldCheckbox chk13 = new SCM_MergeFieldCheckbox('LesionPosition', 'Lesion Position');
        chk13.setfieldValue('Lesion Position \r\n');
        chk13.totalWidth = '270';
        chk13.isNewLine = true;
        subFields.add(chk13);   
                
        // EyeAffected
        SCM_MergeFieldCheckbox chk14 = new SCM_MergeFieldCheckbox('EyeAffected', 'Eye Affected (right, left, both)');
        chk14.setfieldValue('Eye Affected (right, left, both) \r\n');
        chk14.totalWidth = '270';
        chk14.isNewLine = false;
        subFields.add(chk14);                   

        // Other1
        SCM_MergeField Other1 = new SCM_MergeField();
        Other1.key = 'OtherDoc1';
        Other1.isRequired = false;
        Other1.displayCheck = false;
        Other1.displayLabel = true;
        Other1.displayTextBox = true;
        Other1.totalWidth = '400';
        Other1.isNewLine = true;
        Other1.label =  'Other Documentation'; 
        subFields.add(Other1);
        
        // Other2
        SCM_MergeField Other2 = new SCM_MergeField();
        Other2.key = 'OtherDoc2';
        Other2.isRequired = false;
        Other2.displayCheck = false;
        Other2.displayLabel = true;
        Other2.displayTextBox = true;
        Other2.totalWidth = '400';
        Other2.label =  ''; 
        subFields.add(Other2);
        
        // Other3
        SCM_MergeField Other3 = new SCM_MergeField();
        Other3.key = 'OtherDoc3';
        Other3.isRequired = false;
        Other3.displayCheck = false;
        Other3.displayLabel = true;
        Other3.displayTextBox = true;
        Other3.totalWidth = '400';
        Other3.label =  ''; 
        subFields.add(Other3);
        
    }
    
    public override Boolean getVisible()
    {
    
        Integer i=0;
        Boolean retVal = false;
    
        // We need to override the fieldValue property to return false if none of the checkboxes are checked.
        for( i = 0; i <  subFields.size(); i++ )
        {
            if( subFields[i].checked )
            {
                // All it takes is one value to be checked for this whole section to be visible.
                retVal = true;
            }
            
            if( subFields[i].displayTextBox == false && subFields[i].fieldValue.length() > 0 )
            {
                // All it takes is one value to be checked for this whole section to be visible.
                retVal = true;
            }
        }
        
        // None were checked.
        this.setVisible(retVal);
        return retVal;
     }
}