/******************************************************************************************
*  @author: Michal Hrycenko
*  @email:  michal.hrycenko@contactors.roche.com  
*  Created: 2016-10-25
*  LastModified: 2017-02-06 by lukasz.kozminski@contractors.roche.com
*  Project: mcco
*  Description: REST Webservice, Create or Update Contact.             
*******************************************************************************************/

@RestResource(urlMapping='/iPhoneManageContact/*')
global with sharing class iPhone_ManageContact implements iPhone_Commons_gne.Runnable{

	@HttpPost 
	global static iPhone_Commons_gne.RestResponse processRequest(Map<String, iPhone_Get_Account_Contacts_gne.GetAccountContactsDetailsRecord> request) {		
		return iPhone_Commons_gne.executeAlterData(
			new iPhone_ManageContact(), 
			new ManageContactRequest(request.get('contact'))
		);						 																					
	}

	class ManageContactRequest implements iPhone_Commons_gne.BaseArgs {
		public iPhone_Get_Account_Contacts_gne.GetAccountContactsDetailsRecord recordWrapper; 
		
		public ManageContactRequest(iPhone_Get_Account_Contacts_gne.GetAccountContactsDetailsRecord recordWrapper) {
			this.recordWrapper = recordWrapper;
			
		}
		
		public String getIPhoneRequestId(){
            return recordWrapper != null ? recordWrapper.rId : null;
        }
	}
	
	
	
	public Object run(Object arg) {
        ManageContactRequest request = (ManageContactRequest)arg;

        Contact contactToUpsert = new Contact();
        if(String.isEmpty(request.recordWrapper.id)) { 
            Contact existingContact = iPhone_DAO.getContactByiPhoneRequestId(request.recordWrapper.rId);
            if(existingContact.Id != null) {
            	contactToUpsert.Id = existingContact.Id;
            }
            if(existingContact == null && GNE_SFA2_Util.isCrmUser()){
            	existingContact = iPhone_DAO.getContactByFirstAndLastName(request.recordWrapper.fn, request.recordWrapper.ln, request.recordWrapper.aid);
            	if(existingContact.Id != null) {
            		contactToUpsert.Id = existingContact.Id;
            	}
            }
        } else {
            contactToUpsert.Id = request.recordWrapper.id;
        }
    	contactToUpsert.FirstName = request.recordWrapper.fn;
    	contactToUpsert.LastName = request.recordWrapper.ln;
        contactToUpsert.AccountId = request.recordWrapper.aid;
        contactToUpsert.Title_gne__c = request.recordWrapper.tl;
        contactToUpsert.Title = request.recordWrapper.otl;
    	contactToUpsert.Email = request.recordWrapper.em;
    	contactToUpsert.Phone = request.recordWrapper.ph;
    	contactToUpsert.Cell_Phone_frm_gne__c = request.recordWrapper.cph;
    	
    	if(request.recordWrapper.ac != null) {
    		contactToUpsert.Active_gne__c = Boolean.valueOf(request.recordWrapper.ac);     
    	}

    	contactToUpsert.Inactive_Reason__c = request.recordWrapper.ir;
        contactToUpsert.Salutation = request.recordWrapper.sa;
        contactToUpsert.Middle_frm_gne__c = request.recordWrapper.mnf;
        contactToUpsert.Professional_Type_2_frm_gne__c = request.recordWrapper.ptf;
        contactToUpsert.Preferred_Name_gne__c = request.recordWrapper.pn;
        
        if(request.recordWrapper.re != null) {
        	contactToUpsert.Reimbursement_KOL_frm_gne__c = request.recordWrapper.re;
        }

        if(request.recordWrapper.pmcf != null) {
        	contactToUpsert.Primary_Main_Contact_frm_gne__c = request.recordWrapper.pmcf;
        }
        
        if(request.recordWrapper.dnc != null) {
        	contactToUpsert.DO_NOT_CONTACT_gne__c = request.recordWrapper.dnc;
        }

        if(request.recordWrapper.emoo != null) {
        	contactToUpsert.Has_Opted_Out_gne__c = request.recordWrapper.emoo;
        }
        
        contactToUpsert.Website_gne__c = request.recordWrapper.ws;

        if(request.recordWrapper.afrmat != null) {
        	contactToUpsert.AFRM_Additional_Target_frm_gne__c = request.recordWrapper.afrmat;
        }

        if(request.recordWrapper.bfrmat != null) {
        	contactToUpsert.BFRM_Additional_Target_frm_gne__c = request.recordWrapper.bfrmat;
        }

        if(request.recordWrapper.efrmat != null) {
        	contactToUpsert.EFRM_Additional_Target_frm_gne__c = request.recordWrapper.efrmat;
        }

        if(request.recordWrapper.gfrmat != null) {
        	contactToUpsert.GFRM_Additional_Target_frm_gne__c = request.recordWrapper.gfrmat;
        }

		if(request.recordWrapper.ifrmat != null) {
        	contactToUpsert.IFRM_Additional_Target_frm_gne__c = request.recordWrapper.ifrmat;
		}  

		if(request.recordWrapper.nfrmat != null) {
        	contactToUpsert.PFRM_Additional_Target_frm_gne__c = request.recordWrapper.nfrmat;
		} 

		if(request.recordWrapper.pfrmat != null) {
        	contactToUpsert.PFRM_Additional_Target_frm_gne__c = request.recordWrapper.pfrmat;
		}     

		if(request.recordWrapper.rfrmat != null) {
        	contactToUpsert.RFRM_Additional_Target_frm_gne__c = request.recordWrapper.rfrmat;
		}

        if(request.recordWrapper.respfrmat != null) {
            contactToUpsert.RESPFRM_Additional_Target_frm_gne__c = request.recordWrapper.respfrmat;
        }

        if(request.recordWrapper.photo != null){
            contactToUpsert.Photo_gne__c = request.recordWrapper.photo;
        }

        contactToUpsert.AFRM_Survey_Contact_frm_gne__c = request.recordWrapper.afrmsc;
        contactToUpsert.BFRM_Survey_Contact_frm_gne__c = request.recordWrapper.bfrmsc;
        contactToUpsert.EFRM_Survey_Contact_frm_gne__c = request.recordWrapper.efrmsc;
        contactToUpsert.GFRM_Survey_Contact_frm_gne__c = request.recordWrapper.gfrmsc;
        contactToUpsert.IFRM_Survey_Contact_frm_gne__c = request.recordWrapper.ifrmsc;
        contactToUpsert.NFRM_Survey_Contact_frm_gne__c = request.recordWrapper.nfrmsc;
        contactToUpsert.PFRM_Survey_Contact_frm_gne__c = request.recordWrapper.pfrmsc;
        contactToUpsert.RFRM_Survey_Contact_frm_gne__c = request.recordWrapper.rfrmsc;
        contactToUpsert.RESPFRM_Survey_Contact_frm_gne__c = request.recordWrapper.respfrmsc;
        if(request.recordWrapper.cred != null){
        contactToUpsert.Credentials_gne__c = request.recordWrapper.cred;
        }
        if(request.recordWrapper.ex != null){
        contactToUpsert.Ext_gne__c = request.recordWrapper.ex;
        }
        if(request.recordWrapper.func != null){
        contactToUpsert.Function_gne__c = request.recordWrapper.func;
        }
        if(request.recordWrapper.rto != null){
        contactToUpsert.ReportsToId = request.recordWrapper.rto;
        }
        if(request.recordWrapper.fax != null){
        contactToUpsert.Fax = request.recordWrapper.fax;
        }
        if(request.recordWrapper.x340Bc != null){
        contactToUpsert.X340B_Contact__c = request.recordWrapper.x340Bc;
        }
        if(request.recordWrapper.owid != null){
        contactToUpsert.OwnerId = request.recordWrapper.owid;
        }        
        
        contactToUpsert.Primary_Contact_gne__c  = request.recordWrapper.prcon;
        contactToUpsert.Communication_Type_gne__c  = request.recordWrapper.comtyp;
        contactToUpsert.MailingStreet = request.recordWrapper.mstr;
		contactToUpsert.State_Province_gne__c = request.recordWrapper.mstat;
		contactToUpsert.MailingCity = request.recordWrapper.mcity;
		contactToUpsert.MailingPostalCode = request.recordWrapper.mzip;
		contactToUpsert.MailingCountry = request.recordWrapper.mcoun;
        contactToUpsert.Comments_frm_gne__c = request.recordWrapper.comment;
        contactToUpsert.Function_Other_gne__c = request.recordWrapper.ofunc;

        contactToUpsert.iPhone_Request_Id_gne__c = request.recordWrapper.rid;
        
        upsert contactToUpsert;
        
        return new iPhone_Commons_gne.AlterDataResponse(contactToUpsert.Id);
    }

}