global without sharing class GNE_CM_MPS_EnrollEsignConfirm_Ctrl 
{
    private Patient_Enrollment_Request_gne__c patenrol; 
    public Boolean read_aggrement {get; set;} 

    //PS: 4/3/2012 Added for MPS - Product
    public Boolean ProductCheck {get; set;}   
    public String ProductName{get ; set ;}   
    //PS: 4/3/2012 Condition EndsHere 
	
    public String logoURL {get; set;} 
    public String altLogo {get; set;}
    public String per_name {get; set;}
    public String theId {get; private set;}
    public String useLightBox {get; set;}
    
    /**
     * Tells if the patient that is being reenrolled has a valid PAN on file.
     * It is used by the confirmation screen (GNE_CM_MPS_EnrollPSFConfirmation.page) to decide what sections/messages should be displayed.
     */
    public Boolean patientHasValidPan { get; private set; }
    
    private String DocId;
    private String documentAuthenticationToken;
    private Map<String, List<Environment_Variables__c>> environmentVariables;
    
    public GNE_CM_MPS_EnrollEsignConfirm_Ctrl(ApexPages.StandardController controller) 
    {        
        theId = ApexPages.currentPage().getParameters().get('id');
        DocId = ApexPages.currentPage().getParameters().get('DiD');
        read_aggrement = false;
        List<Patient_Enrollment_Request_gne__c> enrollments = [SELECT Id, Name, First_Name_gne__c, Last_Name_gne__c, Product_gne__c, Patient_gne__r.PAN_gne__c FROM Patient_Enrollment_Request_gne__c WHERE id = :theId];
        
        if (enrollments != null && enrollments.size() > 0)
        {   
            patenrol = enrollments[0];      
            per_name = patenrol.Name;	
            ProductName = patenrol.product_gne__c;
            this.patientHasValidPan = patenrol.Patient_gne__r.PAN_gne__c == 'Yes';       		
        }
        else
        {
            patenrol = new Patient_Enrollment_Request_gne__c();
            this.patientHasValidPan = false;
        }
        
        Set<String> envVariables = new Set<String>();  
        envVariables.add('GNE_CM_MPS_EPANFLAG');
        envVariables.add('SCM_URL');
        envVariables.add('GNE-CM-SpringCM-Partner-Webservice-URL');
        envVariables.add('GNE-CM-SpringCM-Partner-Webservice-URL');
        envVariables.add('SCM_WebserviceURL'); 
        envVariables.add('SCM_AccountID');
        envVariables.add('GNE_CM_MPS_LIGHTBOX');
        environmentVariables = GNE_CM_MPS_Utils.populateEnvVariables(envVariables); 
        List<Environment_Variables__c> envVar = environmentVariables.get('GNE_CM_MPS_LIGHTBOX');   
        if(envVar != null && envVar.size() > 0) 
        {
            useLightBox=envVar[0].value__c;
            system.debug('useLightBox---->'+useLightBox);
        }   
		//PS: 4/3/2012 Added Rendered condition for MPS - Product   
         EpanVisibility();      
        //PS: 4/3/2012 Condition EndsHere 
    }
        
	 //PS: 4/3/2012 Added Rendered condition for MPS - Product
    //This Method for Rendering 'Submit Pan Now' and 'Email Pan Form to Patient' button
    public void EpanVisibility()
    {
          String EPanFlag = '';           
          List<Environment_Variables__c> envVarResultsEpan = environmentVariables.get('GNE_CM_MPS_EPANFLAG');
          Map<string,string> mapstrEpan = new Map<string,string>();
	        for(integer i= 0;i < envVarResultsEpan.size();i++)
	        {
	              mapstrEpan.put(envVarResultsEpan[i].Value__c, envVarResultsEpan[i].Value__c); 
	        }
	        if(mapstrEpan.size() > 0)
	        {
	            for(string strEPanFlag : mapstrEpan.keySet())
	            {
	                  EPanFlag = mapstrEpan.get(strEPanFlag);
	                  string[] oPanEsignEV = EPanFlag.split('/');
	                  if(oPanEsignEV[0].toUpperCase() == ProductName.toUpperCase())
	                  {
	                        String oPanEsignProduct = oPanEsignEV[0];
					        String oPanEsignProductFlag = oPanEsignEV[1];
					        if (oPanEsignProduct.toUpperCase()  == ProductName.toUpperCase()  && oPanEsignProductFlag.toUpperCase() == 'FALSE') 
					        ProductCheck = false;
					        else if (oPanEsignProduct.toUpperCase()  == ProductName.toUpperCase()  && oPanEsignProductFlag.toUpperCase() == 'TRUE')  
					        ProductCheck = true;
					        else
					        ProductCheck = true;
	                  }
	            }
	        }
	  
     }
    //PS: 4/3/2012 Condition EndsHere
    
    public PageReference printSMN()
    {
        PageReference printPage = Page.SCM_MPS_EPanRedirect;
        printPage.getParameters().put('id', theId);
        printPage.getParameters().put('DiD', DocId);        
        return printPage;
    }
    
    public String SCM_mergedSMNURL{
        get{
            String getusersessionid = Userinfo.getSessionId();
            String SCM_URL = '';            
            List<Environment_Variables__c> envVarResults = environmentVariables.get('GNE-CM-SpringCM-Partner-Webservice-URL'); 
            if(envVarResults !=null && envVarResults.size() > 0)
            {
                SCM_URL = envVarResults[0].value__c;
                //   String SCM_URL = SCM_Security.getEnvironmentVariable('GNE-CM-SpringCM-Partner-Webservice-URL');  
                return SCM_URL  + '&sessionid=' + getusersessionid + '&objectid=' + theId + '&documenttype=SMN';              
            }
            else 
            {
                return SCM_URL;
            }        
        }
    }
    
    public String SCM_mergedPANURL{
        get{
            String getusersessionid = Userinfo.getSessionId();
            String SCM_URL = '';            
            List<Environment_Variables__c> envVarResults = environmentVariables.get('GNE-CM-SpringCM-Partner-Webservice-URL'); 
            if(envVarResults !=null && envVarResults.size() > 0)
            {
                SCM_URL = envVarResults[0].value__c;
                //   String SCM_URL = SCM_Security.getEnvironmentVariable('GNE-CM-SpringCM-Partner-Webservice-URL');  
                return SCM_URL  + '&sessionid=' + getusersessionid + '&objectid=' + theId + '&documenttype=PAN';              
            }
            else 
            {
                return SCM_URL;
            }        
        }
    }

    private String getDocumentAuthenticationToken()
    {   
        try{
            SCM_Authentication.AuthenitcationServiceSoap auth = new SCM_Authentication.AuthenitcationServiceSoap();
            auth.timeout_x = 60000;          
            List<Environment_Variables__c> envVarURL = environmentVariables.get('SCM_WebserviceURL');
            List<Environment_Variables__c> envVarAccID = environmentVariables.get('SCM_AccountID');
            String envVarURLStr = '';
            String envVarAccIdStr = '';
            if(envVarURL != null || envVarURL.size() > 0)
            {
                envVarURLStr = envVarURL[0].value__c;
            }
            if(envVarAccID != null || envVarAccID.size() > 0)
            {
                envVarAccIdStr  = envVarAccID[0].value__c;
            }
            
            String orgId = System.UserInfo.getOrganizationId();
            String id = auth.CreateRequest(UserInfo.getSessionId(),System.UserInfo.getOrganizationId(),[select email from user where id = :UserInfo.getUserId()][0].email,'Enrollment','Enrollment',patenrol.Id,patenrol.Name,'Enrollment',GNE_CM_MPS_Utils.getApiHostURL() + '/services/Soap/u/18.0/' + orgId ,'',envVarURLStr,envVarAccIdStr);
            if(envVarURLStr =='' || envVarAccIdStr =='')
                return '';
            else
                return id;
        }
        catch(Exception e)
        {
            GNE_CM_MPS_Utils.insertError('GNE_CM_MPS_EnrollEsignConfirm_Ctrl', 
                                        'High',
                                        'getDocumentAuthenticationToken',
                                        'VF Page',
                                        GlobalUtils.getExceptionDescription(e));            
            return '';
        }       
    }
    
    @RemoteAction
    global static String submitEPAN(String perId)
    {       
        String ePANSubmitURL = GNE_CM_ARX_Utility.ePANSubmitNow(perId, 'PER');
        return ePANSubmitURL;               
    }
    
    @RemoteAction
    global static String inviteEPAN(String perId)
    {               
        String ePANInviteURL = GNE_CM_ARX_Utility.ePANInvite(perId, 'PER');
        return ePANInviteURL;       
    }
    
    //wilczekk: try/catch to add here
    public PageReference submitRecord()
    {
        updatePERStatus();      
	    PageReference p2 = new PageReference('/apex/GNE_CM_MPS_EnrollEsign_Confirmation');
	    p2.setRedirect(true);
	    return p2;
       
    }
    
    // This Function take user to the SMN PAN Option confimation Page
    //wilczekk: try/catch to add here
    public PageReference submitRecord2()
    {   
        updatePERStatus();      
        PageReference p2 = new PageReference('/apex/GNE_CM_MPS_SMN_PAN_Options');
        p2.setRedirect(false);
        return p2;
       
    }
    
    private void updatePERStatus()
    {
        Patient_Enrollment_Request_gne__c patenrol = [select id, name ,Status__c , Date_Submitted_gne__c from Patient_Enrollment_Request_gne__c where ID =: theId];
        patenrol.Status__c = 'Submitted - Processing Enrollment Request';
        patenrol.Date_Submitted_gne__c = system.now();
        update patenrol;
    }   
    
    public pagereference cancel()
    {
        try 
        {           
            if(theId != null)
            {
                PageReference p = new PageReference('/apex/GNE_CM_Portal_Patient_Enrollment_Cancel?Id='+theId );
                p.setRedirect(true);
                return p;
            }
            else
            {
                return null;
            }
        } 
        catch(Exception e) 
        {
            Error_Log_gne__c error = GNE_CM_MPS_Utils.createError('GNE_CM_MPS_EnrollEsignConfirm_Ctrl', 'High', 'cancel', 'VF Page', e);
            insert error;  
            return null;
        }
    }
    
    /**
     * Maps the name of the section on the confirmation screen ('SMN', 'PAN' and 'FAX') to its number.
     */
    public Map<String, String> getSectionNumbers()
    { 
    	Map<String, String> sectionNumbers = new Map<String, String>();
    		
		if (patientHasValidPan)
		{
			// all section numbers are empty
			sectionNumbers.put('SMN', '1. ');
			sectionNumbers.put('PAN', '');
			sectionNumbers.put('FAX', '2. ');	
		}
		else
		{
			sectionNumbers.put('SMN', '1. ');
			sectionNumbers.put('PAN', '2. ');
			sectionNumbers.put('FAX', '3. ');
		}
		
		return sectionNumbers;
    }
}