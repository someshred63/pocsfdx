public class SCM_MF_MedHistoryFactory {
 
 private static List<Medical_History_gne__c> MH;
 
 private static SCM_MergeField createMergeField(String key)
    {
        SCM_MergeField mf = new SCM_MergeField();
        mf.key = key;
        mf.checked = false;
        mf.displayCheck = false;
        mf.displayTextBox = false;
        mf.displayLabel = false;
        mf.fieldValue =''; 
        return mf;
    }
    private static List<Medical_History_gne__c> getMedicalHistory(Case SelectedCase)
    {
        if( MH == null )
        {
            MH = [Select m.Drug_gne__c From Medical_History_gne__c m where id =:SelectedCase.Medical_History_gne__c];
       
                      
        }
        
        return MH;
    }
    
     public static SCM_MergeField NutropinDrug(Case SelectedCase)
    {
        
        SCM_MergeField mf = createMergeField('NutropinDrug');
      	mf.fieldvalue = '';
       try {
       	
       	getMedicalHistory(SelectedCase);
       	
       	if (MH.size() ==1){
       		if (MH[0].Drug_gne__c == 'Nutropin 1x10 mg' || MH[0].Drug_gne__c == 'Nutropin 1x5 mg')
       			mf.fieldValue = 'Nutropin';
       		if (MH[0].Drug_gne__c == 'Nutropin AQ 1x10 mg' || MH[0].Drug_gne__c == 'Nutropin AQ Cartridge 1x10 mg' || MH[0].Drug_gne__c == 'Nutropin AQ Cartridge 1x20 mg')	
       			mf.fieldValue = 'Nutropin AQ®';
       		if (MH[0].Drug_gne__c == 'Nutropin AQ NuSpin 1x5 mg' || MH[0].Drug_gne__c == 'Nutropin AQ NuSpin 1x10 mg' || MH[0].Drug_gne__c == 'Nutropin AQ NuSpin 1x20 mg')	
       			mf.fieldValue = 'Nutropin AQ® NuSpin™';
       	}
       	else {
       		
       		mf.fieldvalue = '';
       	}
       	      	
       }
       catch(exception ex) {
       	mf.fieldvalue = '';
       }
        
        return mf;
    }

     public static SCM_MergeField NutropinVial(Case SelectedCase)
    {
        
        SCM_MergeField mf = createMergeField('NutropinVial');
      	mf.fieldvalue = '';
       try {
       	
       	getMedicalHistory(SelectedCase);
       	
       	if (MH.size() ==1){
       		if (MH[0].Drug_gne__c == 'Nutropin 1x10 mg')
       			mf.fieldValue = '10 mg Vial';
       		else if (MH[0].Drug_gne__c == 'Nutropin 1x5 mg')
       			mf.fieldValue = '5 mg Vial';
       		else if (MH[0].Drug_gne__c == 'Nutropin AQ 1x10 mg')
       			mf.fieldValue = '10 mg Vial';
       		else if (MH[0].Drug_gne__c == 'Nutropin AQ Cartridge 1x10 mg')
       			mf.fieldValue = '10 mg Cartridge';
       		else if (MH[0].Drug_gne__c == 'Nutropin AQ Cartridge 1x20 mg')
       			mf.fieldValue = '20 mg Cartridge';
       		else if (MH[0].Drug_gne__c == 'Nutropin AQ NuSpin 1x5 mg')
       			mf.fieldValue = '5mg Injection Device and Prefilled Cartridge';
       		else if (MH[0].Drug_gne__c == 'Nutropin AQ NuSpin 1x10 mg')
       			mf.fieldValue = '10mg Injection Device and Prefilled Cartridge';
       		else if (MH[0].Drug_gne__c == 'Nutropin AQ NuSpin 1x20 mg')
       			mf.fieldValue = '20mg Injection Device and Prefilled Cartridge';
       	
       	}else {
       		
       		mf.fieldvalue = '';
       	}
       	      	
       }
       catch(exception ex) {
       	mf.fieldvalue = '';
       }
        
        return mf;
    }
    
    
    

    
         public static SCM_MergeField NutropinGive(Case SelectedCase)
    {
        
        SCM_MergeField mf = createMergeField('NutropinGive');
      	mf.fieldvalue = '';
       try {
       	
       	getMedicalHistory(SelectedCase);
       	
       	if (MH.size() ==1){
       		if (MH[0].Drug_gne__c == 'Nutropin 1x10 mg' || MH[0].Drug_gne__c == 'Nutropin 1x5 mg')
       		{
       			mf.fieldValue = 'Add ___________ cc diluent and give ___________ cc';
       		}
       		else {
       			mf.fieldValue = 'Give ___________ cc';
       			
       		}
       	}
       	else {
       		
       		mf.fieldvalue = '';
       	}
       	      	
       }
       catch(exception ex) {
       	mf.fieldvalue = '';
       }
        
        return mf;
    }




      public static SCM_MergeField NutropinDispenseRecon(Case SelectedCase)
    {
        
        SCM_MergeField mf = createMergeField('NutropinDispenseRecon');
      	mf.fieldvalue = '';
       try {
       	
       	getMedicalHistory(SelectedCase);
       	
       	if (MH.size() ==1){
       		if (MH[0].Drug_gne__c == 'Nutropin 1x10 mg' || MH[0].Drug_gne__c == 'Nutropin 1x5 mg')
       		{
       			mf.fieldValue = 'Dispense: Reconstitution Syringes as Needed_____1cc_____3cc\r\n\r\n';
       		}
       		else {
       			mf.fieldValue = '';
       			
       		}
       	}
       	else {
       		
       		mf.fieldvalue = '';
       	}
       	      	
       }
       catch(exception ex) {
       	mf.fieldvalue = '';
       }
        
        return mf;
    }
    
        public static SCM_MergeField NutropinDispense(Case SelectedCase)
    {
        
        SCM_MergeField mf = createMergeField('NutropinDispense');
      	mf.fieldvalue = '';
       try {
       	
       	getMedicalHistory(SelectedCase);
       	
       	if (MH.size() ==1){
       		if (MH[0].Drug_gne__c == 'Nutropin 1x10 mg' || MH[0].Drug_gne__c == 'Nutropin 1x5 mg' || MH[0].Drug_gne__c == 'Nutropin AQ 1x10 mg')
       		{
       			mf.fieldValue = 'Dispense: _____ Syringes for Inj._____ .3cc_____.5cc_____1.0cc Other Insulin Syringe_____\r\n\r\n';
       		}
       		else {
       			mf.fieldValue = '';
       			
       		}
       	}
       	else {
       		
       		mf.fieldvalue = '';
       	}
       	      	
       }
       catch(exception ex) {
       	mf.fieldvalue = '';
       }
        
        return mf;
    }
    
}