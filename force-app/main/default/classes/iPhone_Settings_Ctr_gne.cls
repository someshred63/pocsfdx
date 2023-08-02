/******************************************************************************************
*  @author: Sebastian Karczmarski, Roche (contractor)
*  @email: sebastian.karczmarski@contractors.roche.com   
*  Created: 2013-05-24
*  Project: OTR2
*  Description: Controller class for global OTR2 settings page.    
*
*  Modification History
*  Date            Name               Description
*  2014.01.21	   Lukasz Bieniawski  The Read/write setting logic managed by IPhoneSettingsRecord class.        
*******************************************************************************************/
public with sharing class iPhone_Settings_Ctr_gne {

	public String settingsText { 
		get { return IPhoneSettingsRecord.getInstance().getText(); }
		set { IPhoneSettingsRecord.getInstance().setText(value); }
	}
	
	public PageReference onPageLoad(){
		IPhoneSettingsRecord.refresh();		
		return null;
	}
	   
    public PageReference saveAction()
    {
   		IPhoneSettingsRecord.getInstance().save();
    	return null;
    }   
      
    public PageReference cancelAction()
    {
   		IPhoneSettingsRecord.refresh();
    	return null;
    }
}