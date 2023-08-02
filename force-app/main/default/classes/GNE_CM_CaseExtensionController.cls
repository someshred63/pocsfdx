// GDC - 3/25/2009 - This is the extension controller class for Vendor/Triage page.

public class GNE_CM_CaseExtensionController 
{
    public Case pgCase;
    public String product = '';
    public String Case_Being_Worked_By_Value = '';
    public String Function_Performed_Value = '';
    public Integer Case_Being_Worked_By_Flag = 0;
    public Integer Function_Performed_Flag = 0;
    public Integer PrepareNotClicked = 1;
    
    public List<GNE_CM_Custom_File_Info> SCM_Cases = new List<GNE_CM_Custom_File_Info>();
    
    //The following variables are used in the search of the SpringCM platform to obtain filename
    private String Results;
    private String token;
    private String SearchDocumentType;
    private SCM_WebServices.SpringCMServiceSoap SCM = new SCM_WebServices.SpringCMServiceSoap();
    private List<SCM_FaxSender_WebService.SFSCMDocument> queryResultItems;
    
    // The extension constructor initializes the member
    // variable acct by using the getRecord method from the standard
    // controller.
    public GNE_CM_CaseExtensionController(ApexPages.StandardController stdController) 
    {
       this.pgCase = (Case)stdController.getRecord();            
    }

    // Page refresh function
    public PageReference rfrshwindw() 
    {
        return null;    
    }

    // The function which updates the case fielse (Case Being Worked By, Function Performed, File Name with the three values selected on VF page.
    public PageReference selectfile()
    {
        try
        {
            pgCase.Case_Being_Worked_By_gne__c = Case_Being_Worked_By_Value;
            pgCase.Function_Performed_gne__c = Function_Performed_Value;
            pgCase.File_name_gne__c = System.currentPageReference().getParameters().get('filename');
            pgCase.Sent_to_Vendor_Status_Code_gne__c=null;
            pgCase.Sent_To_Vendor_gne__c=null;
            update pgCase;
        }
        catch(exception e)
        {
            ApexPages.addMessages(e);  
            SCM_Cases.clear();
            setPrepareNotClicked(1);
            return null;
        }
        return new PageReference('/apex/GNE_CM_Triage_Vendor_Update_Case');
    }

    // Return the size of SCM_Cases i.e. the # of file names retreived through SCM search.
    public Integer getSCM_CasesSize()
    {
        return SCM_Cases.size();
    }

    // Get and Set functions for PrepareNotClicked: A flag used to control the display of Prepare button
    public Integer getPrepareNotClicked()
    {
        return PrepareNotClicked;
    }

    public void setPrepareNotClicked(integer k)
    {
        PrepareNotClicked = k;
    }

    // Get and Set functions for Case Being Worked By fields
    public String getCaseBeingWorkedByValue() 
    {    
         if (Case_Being_Worked_By_Flag == 0)
         {
            Case_Being_Worked_By_Flag = 1;
            return pgCase.Case_Being_Worked_By_gne__c; 
         }
        else
            return Case_Being_Worked_By_Value;
    }

    public void setCaseBeingWorkedByValue(String s) 
    { 
        setPrepareNotClicked(1);
        Case_Being_Worked_By_Value = s;
        SCM_Cases.clear();
    }

    // To populate the Get Case Being Worked By Picklist on the VF page from the Picklist Values table          
    public List<SelectOption> getCaseBeingWorkedByvalues() 
    {
       List<SelectOption> optionList = new List<SelectOption>();
       
       product = pgCase.Product_gne__c;  
       try
       {
         optionList.add(new SelectOption('','-- None --'));
         if(product != '')
         {
            for (picklist_values_gne__c p : [select name from picklist_values_gne__c  
                                            where Picklist_Name__c = 'Case Being Worked By' 
                                            and Parent__r.Name = :product order by name asc])
            {
                optionList.add(new SelectOption(p.name,p.name));
            }
            
            if (optionList.size() == 0)
              optionList.add(new SelectOption('','-- None --'));
         }
         //else
            //optionList.add(new SelectOption('','-- None --'));
              
      }catch(exception e)
      {
        optionList.add(new SelectOption('','-- None --'));
      }
      return optionList; 
    }

    // Get and Set functions for Function Performed field
    public String getFunctionPerformedValue() 
    {    
        if (Function_Performed_Flag == 0)
         {
            Function_Performed_Flag = 1;
            return pgCase.Function_Performed_gne__c; 
         }
        else
            return Function_Performed_Value;
    }

    public void setFunctionPerformedValue(String s) 
    { 
         setPrepareNotClicked(1);
         Function_Performed_Value = s;
         SCM_Cases.clear();
    }

    // To populate the Function Performed Picklist on the VF page from the Picklist Values table          
    public List<SelectOption> getFunctionPerformedvalues() 
    {
        List<SelectOption> optionList = new List<SelectOption>();
        try
        {
            if (Case_Being_Worked_By_Value =='')
                Case_Being_Worked_By_Value = pgCase.Case_Being_Worked_By_gne__c;
            optionList.add(new SelectOption('','-- None --'));  
            if(Case_Being_Worked_By_Value != '' && Case_Being_Worked_By_Value != null)
            {
                for (picklist_values_gne__c p : [select name from picklist_values_gne__c  
                                            where Picklist_Name__c = 'Function Performed' 
                                            and Parent__r.Name = :Case_Being_Worked_By_Value])
                {
                    optionList.add(new SelectOption(p.name,p.name));
                }
            } // end of if      
        }
        catch(exception e)
        {
            optionList.add(new SelectOption('','-- None --'));
        }
        return optionList; 
    }

    // Function called on the click of Prepared button
    public pageReference doNext()
    {   
        List<String> Res = new List<String>();
        List<ApexPages.Message> myerrorMsg = new List<ApexPages.Message>();
        String Msg = '';
        GNE_CM_Case_Vendor_Validations_Check VendorValidation = new GNE_CM_Case_Vendor_Validations_Check();
        // Call to function performimg Validations for Case Being Worked By and Function performed
        pgCase.Case_Being_Worked_By_gne__c = Case_Being_Worked_By_Value;
        pgCase.Function_Performed_gne__c = Function_Performed_Value;
        try
        {
            if (pgCase.Product_gne__c == 'Nutropin' && pgCase.Case_Being_Worked_By_gne__c == 'EXTERNAL - MCKESSON' && (pgCase.Function_Performed_gne__c == 'Benefits Investigation' || pgCase.Function_Performed_gne__c == 'Appeals Follow-up'))
            {
                Res = VendorValidation.validate_External_Mckesson(pgCase);
                if( Res.size() > 0)
                {
                    for(integer r = 0; r<Res.Size(); r++)
                    {
                        myerrorMsg.add(new ApexPages.Message(ApexPages.severity.ERROR, Res[r]));
                        ApexPages.addMessage(myerrorMsg[r]);                    
                    } // End of for
                } // end of if Res.size()
            } // end of if product
            if (!(Res.size() > 0))
            {
                setPrepareNotClicked(0);
                doSCMLogin();
                doSCMSearch();
            }
        } // end of try
        catch(exception e)
        {
            ApexPages.addMessages(e); 
            SCM_Cases.clear();
            setPrepareNotClicked(1); 
        } // end of catch

        return null;
    }

    public String getLoginResults()
    {
        return Results;
    }
                            
    public void setLoginResults(String r)
    {
        Results = r;
    }

    public List<GNE_CM_Custom_File_Info> getSCMCases()
    {
        return SCM_Cases;
    }
            
    public void doSCMLogin() 
    {
        token = SCM_Security.SCM_AuthenticateNonDefault();
        System.debug('Token: ' + token);   
        setLoginResults(token);
    }
                                
    public void doSCMSearch() 
    {            
        //Modified the code to call new web service
        // Create a new SFSCMDocument object.
        SCM_FaxSender_WebService.SFSCMDocument sdoc = new SCM_FaxSender_WebService.SFSCMDocument();
        
        //Populate attributes of the Search document
		sdoc.CaseNumber = pgCase.CaseNumber;	//	'0010003689'; // 
		sdoc.DocumentType='Complete Fax';
		
		SCM_FaxSender_WebService.FaxSenderSoap fs = new SCM_FaxSender_WebService.FaxSenderSoap();
		
		//Create a Array of Documents to hold search results
		SCM_FaxSender_WebService.ArrayOfSFSCMDocument ArrayObject = new SCM_FaxSender_WebService.ArrayOfSFSCMDocument();
		
		ArrayObject=fs.SearchSpringCM(token,sdoc,false);
		
		List<SCM_FaxSender_WebService.SFSCMDocument> queryResultItems;
		
		//Load Results into a salesforce.com List
		if(ArrayObject!=null)
		queryResultItems = ArrayObject.SFSCMDocument;
				            
                              
        SCM_Cases.clear();
        
          if (queryResultItems != null && queryResultItems.isEmpty()!=true) 
          {
            for (SCM_FaxSender_WebService.SFSCMDocument scmDoc :queryResultItems) 
            {   
                GNE_CM_Custom_File_Info c = new GNE_CM_Custom_File_Info();                                             
                c.setFileName(scmDoc.Title);
                c.setDocumentType(scmDoc.DocumentType);
                c.setCaseNumber(pgCase.CaseNumber);
                
                SCM_Cases.add(c);
            }                    
                           
        } // end of else if
    }// end of DoScmsearch  
}// End of class