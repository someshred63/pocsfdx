public class SCM_MD_PanNonPatient extends SCM_MergeDocument {
    public SCM_MD_PanNonPatient(String caseId, String argLookupId) {
        super(caseId, argLookupId);
        setrequireSystemDocUI(true); 
    }
    private scm_mergefield chknameofpers = new scm_mergefield();
    private scm_mergefield chkContact = new scm_mergefield();
    private scm_mergefield chkRelationofsign = new scm_mergefield();
    private scm_mergefield chkPowattYes = new scm_mergefield();
    private scm_mergefield chkPowattNo = new scm_mergefield();
    private scm_mergefield chkdeshca = new scm_mergefield();
    private scm_mergefield chkAuthYN = new scm_mergefield();
    private scm_mergefield chkSpecAuthYN = new scm_mergefield();
    private scm_mergefield chkRemindYN = new scm_mergefield();
    public override void createMergeFields() {
        
        // Case_Number        
        this.mergeRecipientInfo.add(new SCM_MF_CaseNumber(selectedCase));
        
        SCM_MergeFieldGroup Area1 = new SCM_MergeFieldGroup();
        //section 1
        Area1.label = '';
        
	    SCM_MergeField mfdate = new SCM_MergeField();
	    mfdate.key = 'DateofCall';
	    mfdate.className = 'SCM_MergeField';
	    mfdate.checked = false;
	    mfdate.displayCheck = false;
	    mfdate.displayTextBox = true; 
	    mfdate.label = 'Date of Call';
	    mfdate.displayLabel = true;
	    mfdate.fieldStyle='text-align: left;';
	    mfdate.totalWidth='600'; 
	    mfdate.isrequired = false;
	    mfdate.fieldvalue = ''; 
	    mfdate.fieldType = SCM_MergeField.Fieldtypes.dateField;
	 
        //Area1.subFields.add(NewMergefield('','DateofCall','Date of Call'));
        //Area1.subFields.add(NewMergefield('','GNESpecialist','Which GNE Specialist initiated the call?'));
        Area1.subFields.add(mfdate);
        //Area1.subFields.add(MergeFieldTextBoxNoLabel('','DateofCall'));
        Area1.subFields.add(MergefieldLabelNoTextBox('Which GNE Specialist initiated the call?','GNESpecialistLabel'));
        Area1.subFields.add(MF_GNE_Specialist());
        this.mergeFields.add(Area1);
        //section 2
        SCM_MergeFieldGroup Area2 = new SCM_MergeFieldGroup();
        chknameofpers = NewMergefield('','ChkNamPers','Name of the person who signed the Patient Authorization and Notification form on behalf of the patient(\"signee\")');
        chknameofpers.displayLabel= false;
        chknameofpers.displayExtraHTML = true;
        chknameofpers.extraHTML = 'Name of the person who signed the Patient Authorization and Notification form on behalf of the patient(\"signee\")';
        chknameofpers.displayCheck = true;
        chknameofpers.displayTextBox = false;
        chknameofpers.totalWidth='600';
        chknameofpers.fieldStyle='text-align: left;';
        Area2.subFields.add(chknameofpers);
        //Area2.subFields.add(NewMergefield('','Nameofsigned','Notification form on behalf of the patient(\"signee\")'));
        //Area2.subFields.add(MergefieldLabelNoTextBox('Notification form on behalf of the patient(\"signee\")','NameofsignedLabel'));
        Area2.subFields.add(MergeFieldTextBoxNoLabel('','Nameofsigned'));
        this.mergeFields.add(Area2);
        //section 3
        SCM_MergeFieldGroup Area3 = new SCM_MergeFieldGroup();
        chkContact = NewMergefield('','chkContact','Contact information of the signee:');
        chkContact.displayCheck = true;
        chkContact.displayTextBox = false;
        Area3.subFields.add(chkContact);
        //Area3.subFields.add(NewMergefield('','Address','Address:'));
        //Area3.subFields.add(NewMergefield('','DLofSignees','Drivers\'s License No./Social Security No.:'));
        //Area3.subFields.add(NewMergefield('','PhoneNum','Telephone Number:'));
        //Area3.subFields.add(NewMergefield('','Email','Email:'));
        
        Area3.subFields.add(MergefieldLabelNoTextBox('Address:','AddressLabel'));
        Area3.subFields.add(MergeFieldTextBoxNoLabel('','Address'));
         
        Area3.subFields.add(MergefieldLabelNoTextBox('Drivers\'s License No./Social Security No.:','DLofSigneesLabel'));
        Area3.subFields.add(MergeFieldTextBoxNoLabel('','DLofSignees'));
        
        Area3.subFields.add(MergefieldLabelNoTextBox('Telephone Number:','PhoneNumLabel'));
        SCM_MergeField phone = MergeFieldTextBoxNoLabel('','PhoneNum');
        phone.fieldType=SCM_MergeField.fieldTypes.phoneNumberField;
        Area3.subFields.add(phone);
        
        
        Area3.subFields.add(MergefieldLabelNoTextBox('Email:','EmailLabel'));
        SCM_MergeField email=MergeFieldTextBoxNoLabel('','Email');
        email.fieldType=SCM_MergeField.fieldTypes.emailField;
        Area3.subFields.add(email);
        
        this.mergeFields.add(Area3);
            //section 4
        SCM_MergeFieldGroup Area4 = new SCM_MergeFieldGroup();
        chkRelationofsign = NewMergefield('','ChkreltoPat','Relationship of the Signee to the patient.');
        chkRelationofsign.displayCheck = true;
        chkRelationofsign.displayTextBox = false;
        Area4.subFields.add(chkRelationofsign);
        //Area4.subFields.add(NewMergefield('','RelationshipFam','If the signee is family, please have them explain the relationship, eg spouse  children, or other kin.:'));
        //Area4.subFields.add(NewMergefield('','RelationshipNonFam','If the signee is not family, please have them explain the relationship, eg friend,  attorney, or guardian.:'));
        Area4.subFields.add(MergefieldLabelNoTextBox('If the signee is family, please have them explain the relationship, eg spouse  children, or other kin.:','RelationshipFamLabel'));
        Area4.subFields.add(MergeFieldTextBoxNoLabel('','RelationshipFam'));
        
        Area4.subFields.add(MergefieldLabelNoTextBox('If the signee is not family, please have them explain the relationship, eg friend,  attorney, or guardian.:','RelationshipNonFamLabel'));
        Area4.subFields.add(MergeFieldTextBoxNoLabel('','RelationshipNonFam'));
        
        this.mergeFields.add(Area4);
            //section 5
        SCM_MergeFieldGroup Area5 = new SCM_MergeFieldGroup();
        Area5.subFields.add(MergefieldLabelNoTextBox('Do you have a power of attorney or related document that authorizes you to sign documents, such as the Patient Authorization and Notification form, on behalf of the patient?','TextLabel'));
    
        chkPowattYes = NewMergefield('','chkPowattYes','If Yes, please provide a copy of such document to us. Ask the to fax it to the  GNE Specialist, and then, the conversation can end.');
        chkPowattYes.displayLabel= false;
        chkPowattYes.displayExtraHTML = true;
        chkPowattYes.extraHTML = 'If Yes, please provide a copy of such document to us. Ask the to fax it to the  GNE Specialist, and then, the conversation can end.';
        chkPowattYes.displayCheck = true;
        chkPowattYes.displayTextBox = false;
        chkPowattYes.fieldStyle='text-align: left;'; 
        chkPowattYes.totalWidth='600';
        Area5.subFields.add(chkPowattYes);
        chkPowattNo = NewMergefield('','chkPowattno','If No, continue with the question below.');
        chkPowattNo.displayCheck = true;
        chkPowattNo.displayTextBox = false;
        Area5.subFields.add(chkPowattNo);
        this.mergeFields.add(Area5);
           //section 6
        SCM_MergeFieldGroup Area6 = new SCM_MergeFieldGroup();
        chkdeshca = NewMergefield('','chkdeshca','Has the patient designated you as his/her health care agent, e.g., the person responsible for making decisions related to the care of the patient, such as signing consent forms, on behalf of the patient (check the box on the left if "YES")?');
        chkdeshca.displayLabel= false;
        chkdeshca.displayExtraHTML = true;
        chkdeshca.extraHTML = 'Has the patient designated you as his/her health care agent, e.g., the person responsible for making decisions related to the care of the patient, such as signing consent forms, on behalf of the patient (check the box on the left if "YES")? \r\n';
      	chkdeshca.fieldStyle='text-align: left;'; 
        chkdeshca.totalWidth='600';
        chkdeshca.displayCheck = true;
        chkdeshca.displayTextBox = false;
        Area6.subFields.add(chkdeshca);
        //Area6.subFields.add(NewMergefield('','DesignatedWhen','When did the patient designate you as his/her health care agent?'));
        //Area6.subFields.add(NewMergefield('','DesignatedWhy','Why did the patient have to designate you as his/her care agent?'));
        //Area6.subFields.add(NewMergefield('','DesignatedRevoke','Has the patient revoked the designation? Are you still his/her healt care agent?'));
        
        Area6.subFields.add(MergefieldLabelNoTextBox('When did the patient designate you as his/her health care agent?','DesignatedWhenLabel'));
        Area6.subFields.add(MergeFieldTextBoxNoLabel('','DesignatedWhen'));
        
        Area6.subFields.add(MergefieldLabelNoTextBox('Why did the patient have to designate you as his/her care agent?','DesignatedWhyLabel'));
        Area6.subFields.add(MergeFieldTextBoxNoLabel('','DesignatedWhy'));
        
        Area6.subFields.add(MergefieldLabelNoTextBox('Has the patient revoked the designation? Are you still his/her healt care agent?','DesignatedRevokeLabel'));
        Area6.subFields.add(MergeFieldTextBoxNoLabel('','DesignatedRevoke'));
        
        this.mergeFields.add(Area6);
            //section 7
        SCM_MergeFieldGroup Area7 = new SCM_MergeFieldGroup();
        chkAuthYN = NewMergefield('','chkAuthYN','As the patient\'s health care agent, are you authorized to release information about the patient to  third parties, including medical and financial information (check the box on the left if "YES")?');
        chkAuthYN.displayLabel= false;
        chkAuthYN.displayExtraHTML = true;
        chkAuthYN.extraHTML = 'As the patient\'s health care agent, are you authorized to release information about the patient to  third parties, including medical and financial information (check the box on the left if "YES")?';
        chkAuthYN.displayCheck = true;
        chkAuthYN.displayTextBox = false;
        chkAuthYN.totalWidth='600';
        chkAuthYN.fieldStyle='text-align: left;';
        Area7.subFields.add(chkAuthYN); 
        this.mergeFields.add(Area7);
                //section 8
        SCM_MergeFieldGroup Area8 = new SCM_MergeFieldGroup();
        chkSpecAuthYN  = NewMergefield('','chkSpecAuthYN','Specifically, are you authorized to provide information about the patient and his/her medical and financial information to third parties who will assist the patient in obtaining health care, such as Genentech\'s Patient Reimbursement Assistance Program as was described in the Patient Authorization and Notification form (check the box on the left if "YES")?');
        chkSpecAuthYN.displayLabel= false;
        chkSpecAuthYN.displayExtraHTML = true;
        chkSpecAuthYN.extraHTML = 'Specifically, are you authorized to provide information about the patient and his/her medical and financial information to third parties who will assist the patient in obtaining health care, such as Genentech\'s Patient Reimbursement Assistance Program as was described in the Patient Authorization and Notification form (check the box on the left if "YES")?';
        chkSpecAuthYN.displayCheck = true;
        chkSpecAuthYN.displayTextBox = false;
        chkSpecAuthYN.totalWidth='600';
        chkSpecAuthYN.fieldStyle='text-align: left;'; 
        Area8.subFields.add(chkSpecAuthYN );
        this.mergeFields.add(Area8);
                //section 9
        SCM_MergeFieldGroup Area9 = new SCM_MergeFieldGroup();
        chkRemindYN  = NewMergefield('','chkRemindYN','Please remind the Signee that the information that we receive will be used solely to assist the patient in receiving reimbursement for Genentech\'s products, and the Signee, on behalf of the patient, may revoke the authorization.  However, if the authorization is revoked, we can no longer assist the patient in receiving reimbursement.');
        chkRemindYN.displayLabel= false;
        chkRemindYN.displayExtraHTML = true;
        chkRemindYN.extraHTML = 'Please remind the Signee that the information that we receive will be used solely to assist the patient in receiving reimbursement for Genentech\'s products, and the Signee, on behalf of the patient, may revoke the authorization.  However, if the authorization is revoked, we can no longer assist the patient in receiving reimbursement.';
        chkRemindYN.displayCheck = true;
        chkRemindYN.displayTextBox = false;
        chkRemindYN.totalWidth='600';
        chkRemindYN.fieldStyle='text-align: left;'; 
        Area9.subFields.add(chkRemindYN );
        this.mergeFields.add(Area9);
        
    }



private string setchecked(boolean tst) {
    if (tst) {
        return scm_checkbox_values.checked; 
    }
    else{
        return scm_checkbox_values.Unchecked;
        
    }
}

public override void getLatestValues()
    {
        
    chknameofpers.mergevalue = setchecked(chknameofpers.checked);
     chkContact.mergevalue = setchecked(chkContact.checked);
     chkRelationofsign.mergevalue = setchecked(chkRelationofsign.checked);
     chkPowattYes.mergevalue = setchecked(chkPowattYes.checked);
     chkPowattNo.mergevalue = setchecked(chkPowattNo.checked);
     
     chkdeshca.mergevalue = setchecked(chkdeshca.checked);
     chkAuthYN.mergevalue = setchecked(chkAuthYN.checked);
     chkSpecAuthYN.mergevalue = setchecked(chkSpecAuthYN.checked);
     chkRemindYN.setmergevalue(setchecked(chkRemindYN.checked));
        
        
    }


private SCM_MergeField MergeFieldTextBoxNoLabel(string mfvalue,string mfkey)
{
    return MergeFieldTextBoxNoLabel(mfvalue, mfkey, SCM_MergeField.FieldTypes.textboxField);
}

private SCM_MergeField MergeFieldTextBoxNoLabel(string mfvalue,string mfkey, SCM_MergeField.FieldTypes fType)
{
    SCM_MergeField mf = new SCM_MergeField();
    mf.key = mfkey;
    mf.className = 'SCM_MergeField';
    mf.checked = false;
    mf.displayCheck = false;
    mf.displayTextBox = true; 
    mf.displayLabel = false;
    mf.fieldValue = mfvalue;
    mf.isrequired = false;
    mf.fieldStyle='text-align: left;';
    mf.fieldType = fType;
    
    if (mfvalue == null)
        mf.fieldvalue = ''; 
    return mf;
}

private SCM_MergeField MergefieldLabelNoTextBox(string label,string mfkey) {
    SCM_MergeField mf = new SCM_MergeField();
    mf.key = mfkey;
    mf.className = 'SCM_MergeField';
    mf.checked = false;
    mf.displayCheck = false;
    mf.displayTextBox = false; 
    mf.label = label;
    mf.displayLabel = true;
    mf.fieldStyle='text-align: left;';
    mf.totalWidth='600'; 
    mf.isrequired = false;
    mf.fieldvalue = ''; 
    return mf;
} 

private SCM_MergeField NewMergefield(string mfvalue,string mfkey,string label) {
    SCM_MergeField mf = new SCM_MergeField();
    mf.key = mfkey;
    mf.className = 'SCM_MergeField';
    mf.checked = false;
    mf.displayCheck = false;
    mf.displayTextBox = true; 
    mf.label = label;
    mf.displayLabel = true;
    mf.fieldValue = mfvalue;
    mf.isrequired = false;
    if (mfvalue == null) {
    mf.fieldvalue = ''; 
    }
    return mf;
}

    private SCM_MergeField MF_GNE_Specialist()
    {
        SCM_MergeField mf = new SCM_MergeField();
        mf.key='GNESpecialist';
        mf.className = 'SCM_MergeField';
        mf.checked = false;
        mf.displayCheck = false;
        mf.displayTextBox = false;
        mf.displayDropdown=true; 
        //mf.label = label;
        mf.displayLabel = false;
        //mf.fieldValue = mfvalue;
        mf.fieldStyle='text-align: left;';
        mf.isrequired = false;
        List<User> userList = [Select u.FirstName, u.LastName, 
                                      u.Name, u.ProfileId, u.Profile.Name 
                               from User u 
                               where u.Profile.Name like 'GNE-CM%' order by u.Name];
        List<SelectOption> options = new List<SelectOption>();
        for(User usr:userList)
        {
            options.add(new SelectOption(usr.Name,usr.Name));
        }
        mf.selectionItems=options;  
        return mf;                         
    }
}