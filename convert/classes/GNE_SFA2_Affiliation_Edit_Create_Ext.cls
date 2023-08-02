//--------------------------------------------------------------------------------
// COMPONENT: Genentech SFA
//     CLASS: GNE_SFA2_Affiliation_Edit_Create_Ext
//   PURPOSE: Controller for Account Affiiations
//    AUTHOR: Liz Ichihashi  
//   CREATED: 09/2010 
//
//   MODIFIED: SFA2 copy created for Force.com project purposes (22/02/2013)
//--------------------------------------------------------------------------------
public without sharing class GNE_SFA2_Affiliation_Edit_Create_Ext extends GNE_Base_Controller {

    //stdCont holds reference to standard controller passed into constructor
    public ApexPages.StandardController stdCont { get; set;}
    //obj holds reference to Affiliation_vod__c object being added or edited
    public Affiliation_vod__c obj { get; set;}
    //3 data access objects 
    private transient GNE_Account_Dao acctDao;
    private transient GNE_Stg_Party_Dao ptyDao;
    private transient GNE_Account_Affiliation_Dao affilDao;
    //mode is either Add or Edit.  Used in page title and hiding/showing fields on page.
    public String mode { get; set;}
    //retUrl is passed in on URL from calling page, sometimes used as return page 
    public String retUrl { get; set;}
    public String profileName;
    public String addrId {get; set;}
    
    //standard constructor
    public GNE_SFA2_Affiliation_Edit_Create_Ext(ApexPages.StandardController cont) {
        IsTestCase = false;
        stdCont = cont;
    }
    
    //SFA Canada
    private Set<String> rolesCanadaSet = new Set<String>{'Approver','Attending','Business Relations Manager','CEO','CFO','CHE Coordinator','CME Coordinator','COO','Cardiac Care Nurse','Cardiac Rehab','Nurse','Charge Nurse','Chief Purchasing Officer','Chief Resident','Chief of Division','Chief of Staff','Clinical Clerk','Clinical Coordinator','Clinical Nurse Coordinator','Clinical Pharmacist','Consulting Physician','Contract Coordinator','Contract Manager','DUR Pharmacist','Decision Maker','Department Head','Dialysis Nurse','Dietician','Director','Director of Nursing','Director of Pharmacy','Drug Info. Pharmacist','Drug Access Coordinator','EMS Medical Director','Fellow','Fund Raiser Coordinator','Head Nurse','Infection Control Nurse','Is Affiliated With','Lab Technician','MAC Chairperson','MAC Member','Medical Director','Medical Information Officer','Nurse','Nurse Clinician','Nurse Educator','Nurse Manager','Nurse Practitioner','Nutritionist','Occupational Health Nurse','Office Manager','P&T Antibiotic Subcommittee','P&T Chairperson','P&T Member','P&T Secretary','P&T Thrombolytic Subcommittee','Paramedic','Pharmacist','Pharmacy Technician','Physician','Principal Investigator','Purchase Officer','Purchasing Officer','Quality Assurance','Renal Pharmacist','Research Coordinator','Research Nurse','PGY','Site Coordinator','Staff Physician','Stroke Fellow','Sub-Investigator','VP','Vascular Access Coordinator','Wellness Coordinator','Works At'};
	private Set<String> ramaRolesCanada = new Set<String>{'Approver','Committee Chair','Committee Member','Decision Maker','Gate Keeper','Influencer','Works At'};

	public List<SelectOption> getRoleList() {
    	List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Affiliation_vod__c.Role_vod__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        options.add(new SelectOption('', '--None--'));
        if(profileName.toUpperCase().contains('CANADA-SFA-RAMA')) {
            for(Schema.PicklistEntry f : ple) {
                if(ramaRolesCanada.contains(f.getLabel())){
                    options.add(new SelectOption(f.getLabel(), f.getValue()));
                }
            } 
        } else if(profileName.toUpperCase().contains('CANADA')){
        	for(Schema.PicklistEntry f : ple) {
            	if(rolesCanadaSet.contains(f.getLabel())){
                	options.add(new SelectOption(f.getLabel(), f.getValue()));
              	}
          	} 
        } else {
          	for(Schema.PicklistEntry f : ple) {
              	if(!rolesCanadaSet.contains(f.getLabel())){
            	    options.add(new SelectOption(f.getLabel(), f.getValue()));
              	}
          	} 
        }
         
        return options;
    }
          
    // [LB] Condition to show role for the opposite affiliation 
    // Currently only for account to account for Canada profiles
    public boolean getDisplayRoleOpposite() {
    	if(getHasCanadaProfile() && !getHasContactIn()){
            return true;
        } else {
        	return false;
        }
    }    
            
    public boolean viewRoleOpposite { get; private set; }
    
    public void setViewRoleOpposite(){
      	boolean isVisible = Boolean.valueOf(System.currentPageReference().getParameters().get('isVisible'));      
      	viewRoleOpposite = isVisible;
    }
    
    public boolean getHasLWOorCanadaProfile(){
        if(profileName != null && (profileName.contains('LWO') || profileName.toUpperCase().contains('CANADA'))){
            return true;
         } else {
            return false;
        }
    }

    public boolean getHasSysAdminProfile() {
        return (profileName != null && (profileName.toUpperCase().contains('SYS') || profileName.startsWithIgnoreCase('GNE-SFA-OPS') )) ? true : false; 
    }
    
    //method to indicate whether the logged on user is a Case Management user
    public boolean getHasCMProfile() {
        return (profileName != null && profileName.contains('GNE-CM')) ? true : false; 
    }
    
    //method to indicate whether the logged on user is a Lucentis Web Order user (LWO) or Canada profile
    public boolean getHasLWOProfile() {
        return (profileName != null && profileName.contains('LWO')) ? true : false; 
    }
    
    public Boolean getHasAtlsProfile(){
    	return (profileName != null && profileName.startsWithIgnoreCase('GNE-TLS')) ? true : false;
    }

    public Boolean getHasFPMProfile(){
        return (profileName != null && profileName.startsWithIgnoreCase('GNE-SFA') && profileName.contains('FPM')) ? true : false;
    }

    public Boolean getHasRAMAProfile() {
        return (profileName != null && profileName.equals('RCanada-SFA-RAMA')) ? true : false;
    }
    
    //no arg constructor used for tests only       
    public GNE_SFA2_Affiliation_Edit_Create_Ext() {
        IsTestCase = true;
    }

    //this method is called upon invocation of GNE_Account_Affiliation.page.
    public PageReference setup() {
        retUrl = ApexPages.currentPage().getParameters().get('retUrl');
        String inId = ApexPages.currentPage().getParameters().get('id');
        if (stdCont != null) {
            SObject sobjectInstance = stdCont.getRecord();
            if (sobjectInstance != null) { 
            	obj = (Affiliation_vod__c) sobjectInstance;
            }
            if (!Utility.isNull(obj.Id)) {
                mode = 'Edit';
                affilDao = new GNE_Account_Affiliation_Dao();
                obj = affilDao.getById(obj.Id);
            } else {
                mode = 'Add';
                //the standard controller will handle creating new obj and
                //setting the From_Account_vod__c to point to the Account
            }
            
            profileName = GNE_SFA2_Util.getCurrentUserProfileName();            
            
            String objId = inId;
          	if (String.isBlank(objId)) {
            	objId = stdCont.getId();
          	}        
          	
          	viewRoleOpposite = !String.isBlank(objId) ? getDisplayRoleOpposite() : false;
        }   
      
        return null;
    }   
    
    public PageReference save() {
        if (!validate()) return null;
        if (saveObject() == null) {
            obj = affilDao.getById(obj.Id);
            if (obj != null) {
                if (obj.Applies_to_My_Brand_gne__c != null && obj.Applies_to_My_Brand_gne__c.equalsIgnoreCase('True')) {
                    return new PageReference('/'+obj.Id);
                } else {
                  	if(obj.From_Account_vod__c != null) {
                    	// when adding affiliation from account
                    	return new PageReference('/'+obj.From_Account_vod__c);  
                  	} else {
                    	// when adding affiliation from contact
                    	return new PageReference('/'+obj.From_Contact_vod__c);
                  	}
                }
            } else {
                return new PageReference(retUrl);
            }       
        } 
        
        return null;
    }
    
    public PageReference saveNew() {
        if (!validate()) return null;
        if (saveObject() == null) {
            String fromAccountId = obj.From_Account_vod__c;
            String fromContactId = obj.From_Contact_vod__c;
            obj = new Affiliation_vod__c();
            if(fromAccountId != null) {
                obj.From_Account_vod__c = fromAccountId;
            } else {
              obj.From_Contact_vod__c = fromContactId;
            }
        }
        
        return null;
    }
    
    public PageReference cancel() {
        if (obj != null && obj.From_Account_vod__c != null) {
            return new PageReference('/'+obj.From_Account_vod__c);
        }else if (obj != null && obj.From_Contact_vod__c != null) {
            return new PageReference('/'+obj.From_Contact_vod__c);
        }else if (retUrl != null) {
            return new PageReference(retUrl);
        }
           
        return null; 
    }
    
    public void setToAccount() {
        String addrId = System.currentPageReference().getParameters().get('addrId');
        acctDao = new GNE_Account_Dao(IsTestCase);
        ptyDao = new GNE_Stg_Party_Dao(IsTestCase);
        if (!Utility.isNull(addrId)) {
            //check to see what type of id was passed in
            if (addrId.startsWith(Schema.SObjectType.Address_vod__c.getKeyPrefix())) {
                obj.To_Account_vod__c = acctDao.getAccountIdForAddressId(addrId);
            } else if (addrId.startsWith(Schema.SObjectType.Account.getKeyPrefix())) {
                obj.To_Account_vod__c = addrId;
            } else {   
                Account acct = ptyDao.subscribeAddress(addrId);
                if (acct != null && acct.Id != null) {
                    obj.To_Account_vod__c = acct.Id;
                } else {    
                    showError('There was an error processing the request to subscribe to this Account. Please submit a Remedy ticket to support.');                         
                }
            }             
        } 
    }
    
    public void setToAccountFromSbc() {
        String accId = System.currentPageReference().getParameters().get('sbcAccId');
        if(String.isNotBlank(accId)) {
            obj.To_Account_vod__c = accId;
        }
    }
    
    public boolean getHasCanadaProfile() {
        if(profileName != null && profileName.toUpperCase().contains('CANADA')){
            return true;
        } else {
            return false;
        }
    }
    
    // Check if existed affiliation has a contact
    private boolean getHasContactIn(){
        if(obj.To_Contact_vod__c != null || obj.From_Contact_vod__c != null){
            return true;
        } else {
            return false;
        }
    }
    
    private Exception saveObject() {
        affilDao = new GNE_Account_Affiliation_Dao();
        obj.Record_Status_gne__c = 'Active';        
        
        // [LB] Make sure that the opposite role field will be filled when was not dispayed
        if (!viewRoleOpposite){
          	obj.Role_opposite_vod__c = obj.Role_vod__c;
        }
        Exception ex = affilDao.saveSObjectEx(obj);
        System.debug('ID: ' + obj.ID + ' ExternalID: ' + obj.External_Id_vod__c);
        if (ex != null) {  
            debug('Exception received from saveSObjectEx. Message='+ex);
            showError(ex.getMessage());
            return ex;
        }
        
        return null;
    }  
    
    private boolean validate() {
        if (isNullOrEmpty(obj.To_Account_vod__c) && isNullOrEmpty(obj.To_Contact_vod__c)) {
            showError('You must specify a To Account or To Contact.');
            return false;       
        }
        
        if (!isNullOrEmpty(obj.To_Account_vod__c) && !isNullOrEmpty(obj.To_Contact_vod__c)) {
            showError('Only one To Account or To Contact is allowed, not both.');
            return false;       
        }
        
        if (!isNullOrEmpty(obj.To_Account_vod__c) && obj.To_Account_vod__c == obj.From_Account_vod__c) {
            showError('To Account may not be the same as the From Account.  Please choose a different To Account before saving this Affiliation.');
            return false;       
        }
        
        return true;
    }
    
    public Boolean getCommentFieldAccess() {
    	Schema.DescribeFieldResult field = Affiliation_vod__c.Comments_vod__c.getDescribe();
		return field.isAccessible();
    }
}