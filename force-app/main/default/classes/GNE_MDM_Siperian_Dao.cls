//--------------------------------------------------------------------------------
// COMPONENT: SFA Primary Care
//     CLASS: GNE_MDM_Siperian_Dao
//   PURPOSE: Dao for SFASearchStrings_gne__c and searching Accounts
// 
//   CREATED: 05/2010  
//--------------------------------------------------------------------------------
public class GNE_MDM_Siperian_Dao extends GNE_Base_Dao {
  
    private boolean IsTestCase;  
    private boolean filterByRule;
    public Integer lowestvalue ;
  
    public GNE_MDM_Siperian_Dao()
    {
    	IsTestCase = false;
    	
    }
     
    public GNE_MDM_Siperian_Dao(boolean testCase)
    {
    	IsTestCase = testCase;
    	setFilterRules();
    }
  
	public Exception getSiperianMatches(GNE_Account_Pager pager) 
	{
		try  
		{
			callMdmSiperianSearch(pager);
		} catch(Exception ex)
		{    
			System.debug('Exception caught calling MDM/Siperian WS. Message='+ ex);
			return ex;
		} 	
		return null;
	}  
	
	private string SetLowestRuleNumberIndv(GNE_MDM_Siperian_v6_IndivAcctResponse.IndividualAccountItemType[] mdmAcctsList)
	{
		  
		  Integer i =0;
		  for(GNE_MDM_Siperian_v6_IndivAcctResponse.IndividualAccountItemType mdmAcct : mdmAcctsList)
          {
            if(i ==0) lowestvalue = Integer.valueOf(mdmAcct.ruleNumber);
            
            if( lowestvalue > Integer.valueOf(mdmAcct.ruleNumber))
            	lowestvalue =   Integer.valueOf(mdmAcct.ruleNumber);
            	
            i++;
          }
          return String.valueOf((Decimal)lowestvalue);
	}

	private string SetLowestRuleNumberOrg(GNE_MDM_Siperian_v6_OrgAcctResponse.OrganizationAccountItemType[] mdmAcctsList)
	{
		  Integer i =0;
		  for(GNE_MDM_Siperian_v6_OrgAcctResponse.OrganizationAccountItemType mdmAcct : mdmAcctsList)
          {
            if(i ==0) lowestvalue = Integer.valueOf(mdmAcct.ruleNumber);
            
            if( lowestvalue > Integer.valueOf(mdmAcct.ruleNumber))
            	lowestvalue =   Integer.valueOf(mdmAcct.ruleNumber);
            	
            i++;
          }
          return String.valueOf((Decimal)lowestvalue);
	}
	//begin new for version 2.2
	private String callMdmSiperianSearch(GNE_Account_Pager pager)
	{	         
    	System.debug(Logginglevel.INFO, 'pager.currSearch.AccountType_gne__c='+pager.currSearch.AccountType_gne__c);
    	System.debug(Logginglevel.INFO, 'Pager.currSearch.Street_gne__c='+Pager.currSearch.Street_gne__c);
    	System.debug(Logginglevel.INFO, 'Pager.currSearch.City_gne__c='+Pager.currSearch.City_gne__c);
    	System.debug(Logginglevel.INFO, 'Pager.currSearch.State_gne__c='+Pager.currSearch.State_gne__c);
    	System.debug(Logginglevel.INFO, 'Pager.currSearch.Zip_gne__c='+Pager.currSearch.Zip_gne__c);
      	System.debug(Logginglevel.INFO, 'Pager.currSearch.OrgName_gne__c='+Pager.currSearch.OrgName_gne__c);
        System.debug(Logginglevel.INFO, 'Pager.currSearch.License_Number_gne__c='+Pager.currSearch.License_Number_gne__c);
        System.debug(Logginglevel.INFO, 'Pager.currSearch.License_State_gne__c='+Pager.currSearch.License_State_gne__c);
        
        String RuleNum ='';
        String returnVal = '';
		GNE_MDM_Siperian_v6_ProxyService.MdmProxyPortType mdmSvc = new GNE_MDM_Siperian_v6_ProxyService.MdmProxyPortType(); 
        mdmSvc.Timeout_x = 120000;
		Integer maxResults = 1999;
       	Pager.mdmAddrIdToRuleMap = new Map <String, String>();        	
       	Pager.mdmIdToRuleNumMap = new Map <String, String>();  
        Integer rowCount = 0;
        String sortOrder = 'RULE_NUMBER';
        String ruleSetName = getRuleSet(pager);
        System.debug(Logginglevel.INFO, 'rulSetName='+ruleSetName);
        	
        if (pager.currSearch.AccountType_gne__c == 'HCP')
        {
        	
        	String[] splitFields;
        	integer i = 0;
    		if (!isNullOrEmpty(pager.CurrSearch.OrgName_gne__c)) splitFields = pager.CurrSearch.OrgName_gne__c.split(' ');
    		if (splitFields != null && splitFields.size() > 0)
    		{
    			if(splitFields.size() == 1)
				{
	     			Pager.currSearch.LastName_gne__c = splitFields[0];
				}
				if(splitFields.size() == 2)
				{
				   Pager.currSearch.FirstName_gne__c = splitFields[0];
				   Pager.currSearch.LastName_gne__c = splitFields[1];
				}
    			if(splitFields.size() > 2)
    			{
    				 Pager.currSearch.FirstName_gne__c = splitFields[0];
				     Pager.currSearch.LastName_gne__c = splitFields[2];
    			}
    		}
    		else
   			{
   			   	Pager.currSearch.FirstName_gne__c = null;
   			   	Pager.currSearch.LastName_gne__c = null;
   			}
        	System.debug('XXXXXXXXXXXXXXX FirstName_gne__c and LastName_gne__c for ESB call :' +Pager.currSearch.FirstName_gne__c + ' ' + Pager.currSearch.LastName_gne__c);
        	/* this old request where license was pass to esb - now liceans serach is perform only within stg records no mdm call should be done
        	GNE_MDM_Siperian_v6_IndivAcctResponse.IndividualAccountItemType[] mdmAccts= mdmSvc.searchIndividualAccount(null,Pager.currSearch.OrgName_gne__c,null,Pager.currSearch.OrgName_gne__c,
                        Pager.currSearch.Street_gne__c,Pager.currSearch.State_gne__c,Pager.currSearch.City_gne__c,
                        Pager.currSearch.Zip_gne__c,Pager.currSearch.License_Number_gne__c,Pager.currSearch.License_State_gne__c,
                     	maxResults,sortOrder,ruleSetName);*/
         	GNE_MDM_Siperian_v6_IndivAcctResponse.IndividualAccountItemType[] mdmAccts= mdmSvc.searchIndividualAccount(Pager.currSearch.FirstName_gne__c,Pager.currSearch.LastName_gne__c,Pager.currSearch.FirstName_gne__c,Pager.currSearch.LastName_gne__c,
            Pager.currSearch.Street_gne__c,Pager.currSearch.State_gne__c,Pager.currSearch.City_gne__c,
            Pager.currSearch.Zip_gne__c,null,null,maxResults,sortOrder,ruleSetName);
                     	
			if (mdmAccts != null)
			{	
				RuleNum = SetLowestRuleNumberIndv(mdmAccts);
				System.debug('XXXXXXXXXXXXXXX LOWEST RULE NUMBER :' + RuleNum);
				System.debug('XXXXXXXXXXXXXXX FILTER BY RULE IS SET TO :' + filterByRule);
				System.debug(Logginglevel.INFO, 'mdmAccts.size()='+ mdmAccts.size());
                System.debug('mdmAccts :'+ mdmAccts);
	    	    for(GNE_MDM_Siperian_v6_IndivAcctResponse.IndividualAccountItemType mdmAcct : mdmAccts)
            	{  
            		System.debug(LoggingLevel.INFO, 'rule='+ mdmAcct.ruleNumber+',' + mdmAcct.mdmId.trim());
            		System.debug(LoggingLevel.INFO, 'ruleAdd='+ mdmAcct.ruleNumber+',' + mdmAcct.mdmAddressId.trim());
            		rowCount ++;
            		if (returnVal > '') returnVal += ',';
    	        	if (mdmAcct.mdmId != null)	returnVal += '\'' + mdmAcct.mdmId.trim() + '\'';
    	        	//added as a resolve defect 17396
	    	        if(filterByRule)
	    	        {
		    	         	if(RuleNum == mdmAcct.ruleNumber)
		    	        	Pager.mdmAddrIdToRuleMap.put(mdmAcct.mdmAddressId.trim(), mdmAcct.ruleNumber);
	    	        }
	    	        else
	    	        	Pager.mdmAddrIdToRuleMap.put(mdmAcct.mdmAddressId.trim(), mdmAcct.ruleNumber);
            		
            		if(filterByRule)
	    	        {

	            		if(RuleNum == mdmAcct.ruleNumber)
	            		{
	            			Pager.mdmIdToRuleNumMap.put(mdmAcct.mdmId, mdmAcct.ruleNumber);
	            		}
	    	        }
	    	        else
	    	        	Pager.mdmIdToRuleNumMap.put(mdmAcct.mdmId, mdmAcct.ruleNumber);
        		}
        							System.Debug('XXX mdmAddrIdToRuleMap' + Pager.mdmAddrIdToRuleMap);
        		            		System.Debug('XXX mdmIdToRuleNumMap' +  Pager.mdmIdToRuleNumMap);
    		} else
			{
				System.debug(Logginglevel.INFO, 'mdmAccts is null');
			}                                                                                     	
        } else
        {   
        	GNE_MDM_Siperian_v6_OrgAcctResponse.OrganizationAccountItemType[] mdmAccts = mdmSvc.searchOrganizationAccount(Pager.currSearch.OrgName_gne__c,
                        Pager.currSearch.OrgName_gne__c,Pager.currSearch.Street_gne__c,
                        Pager.currSearch.City_gne__c,Pager.currSearch.State_gne__c,
                        Pager.currSearch.Zip_gne__c, maxResults,sortOrder,ruleSetName);
        		
   			if (mdmAccts != null)
			{
				RuleNum = SetLowestRuleNumberOrg(mdmAccts);
				System.debug('XXXXXXXXXXXXXXX LOWEST RULE NUMBER :' + RuleNum);
				System.debug(Logginglevel.INFO, 'mdmAccts.size()='+ mdmAccts.size());
				System.debug('mdmAccts :'+ mdmAccts);
			    for(GNE_MDM_Siperian_v6_OrgAcctResponse.OrganizationAccountItemType mdmAcct : mdmAccts)
            	{
            		System.debug(LoggingLevel.INFO, 'rule='+ mdmAcct.ruleNumber+',' + mdmAcct.mdmId.trim());
            		System.debug(LoggingLevel.INFO, 'ruleAdd='+ mdmAcct.ruleNumber+',' + mdmAcct.mdmAddressId.trim());
            		rowCount ++;
            		if (returnVal > '') returnVal += ',';
    	        	if (mdmAcct.mdmId != null)	returnVal += '\'' + mdmAcct.mdmId.trim() + '\'';

	    	        if(filterByRule)
	    	        {
		    	       	if(RuleNum == mdmAcct.ruleNumber)
		    	       	Pager.mdmAddrIdToRuleMap.put(mdmAcct.mdmAddressId.trim(), mdmAcct.ruleNumber);
	    	        }
	    	        else
	    	        	Pager.mdmAddrIdToRuleMap.put(mdmAcct.mdmAddressId.trim(), mdmAcct.ruleNumber);
            		 
            		
            	    if(filterByRule)
	    	        {

	            		if(RuleNum == mdmAcct.ruleNumber)
	            		{
	            			Pager.mdmIdToRuleNumMap.put(mdmAcct.mdmId, mdmAcct.ruleNumber);
	            		}
	    	        }
	    	        else
	    	        	Pager.mdmIdToRuleNumMap.put(mdmAcct.mdmId, mdmAcct.ruleNumber);
        		}
        		            		System.Debug('XXX mdmAddrIdToRuleMap' + Pager.mdmAddrIdToRuleMap);
        		            		System.Debug('XXX mdmIdToRuleNumMap' +  Pager.mdmIdToRuleNumMap);
			} else
			{
				System.debug(Logginglevel.INFO, 'mdmAccts is null');
			}
        }
        
		if (rowCount >= pager.getMaxResults())
	    {
	    	
	    	if(pager.SearchOnlyFirstMax == false)
	    	{
	    		pager.ShowTooManyResults = true;
	    		throw new GNE_Account_Dao.TooManyResultsException();
	    	}
	    	else if(pager.SearchOnlyFirstMax == true)
	    	{
	    		system.debug('error TooManyResultsException should be trow but SearchOnlyFirstMax is set to :' +pager.SearchOnlyFirstMax);
	    		rowCount = 0;
	    		string[] tmp = returnVal.split(',',0);
	    		for(String t : tmp)
	    		{
	    			if(rowCount > pager.getMaxResults()) break;
	    			if (returnVal > '') returnVal += ',';
	    			returnVal += t;
	    			rowCount ++;
	    		}
	    		
	    	}
	    }
	    system.debug('returnVal :' + returnVal);
   		return returnVal;	
	}
	
    private void setFilterRules()
	{
		Map<String, GNE_Foun_Misc_Config_Items_gne__c> mapConfigItems = GNE_Foun_Misc_Config_Items_gne__c.getAll();	
		if (mapConfigItems != null && mapConfigItems.size() > 0)
		{
			String filter = (String) mapConfigItems.get('FilterRulesINResults').Configuration_Value_gne__c;
			if (filter != null) 
			{
			    if(filter == 'true')filterByRule = true;
			    else filterByRule = false;
	    	}
		}
	}
	
	//may or may not need to filter based on Rule... this logic was needed for version 2.1, but it is 
	//not clear at this point whether this will be needed for version 2.2.  need to assess after looking at results.
	private boolean filterRule(GNE_Account_Pager pager, String rule)
	{
		if (pager.currSearch.AccountType_gne__c == 'HCP')
		{
			if ((pager.currSearch.Street_gne__c != null || pager.currSearch.City_gne__c != null) && rule == '7')
		    {
				return true;
			}			
		} else
		{
			if ((pager.currSearch.Street_gne__c != null || pager.currSearch.City_gne__c != null) && rule == '5')
    		{
				return true;
    		}
		}	
		return false;
	}

		private String getRuleSet(GNE_Account_Pager pager)
	{
		String ruleSet = '';
		Map<String, GNE_FOUN_RuleSet_Matrix_gne__c> mapRuleSetItems = GNE_FOUN_RuleSet_Matrix_gne__c.getAll();	
		/*
		Individual Name only : Fuzzy_Match_Search_Indv
		Individual Name & Address:  Fuzzy_Match_Search_Addr_Indv
		Org Name only: Fuzzy_Match_Search_Org
		Org Name & Address: Fuzzy_Match_Search_Addr_Org
		Address Only: Fuzzy_Match_Search_Addr_Org
		*/
		system.debug('xxx sip pager.RuleSetName :' + pager.RuleSetName);
		if(pager.RuleSetName == GNE_Account_Search_Create_Controller.NONE_SELECTED)
		{
			if (pager.currSearch.AccountType_gne__c == 'HCP')    
			{
				if(pager.GetIs_1N_BothSearch())
				{
					if (mapRuleSetItems != null && mapRuleSetItems.get('1N_Indv') != null)
						ruleSet = (String) mapRuleSetItems.get('1N_Indv').ESB_RuleSetName__c;
				}
				else if(pager.GetIs_1XXL_BothSearch())
				{
				  	if (mapRuleSetItems != null && mapRuleSetItems.get('1XX_Indv') != null)
						ruleSet = (String) mapRuleSetItems.get('1XX_Indv').ESB_RuleSetName__c;
				}
				else if (pager.GetIs_1XL_BothSearch())
			    {
			    	if (mapRuleSetItems != null && mapRuleSetItems.get('1XL_Indv') != null)
						ruleSet = (String) mapRuleSetItems.get('1XL_Indv').ESB_RuleSetName__c;
			    } 
			    else if (pager.GetIs_1L_IndvSearch())
			    {
			    	if (mapRuleSetItems != null && mapRuleSetItems.get('1L_Indv') != null)
						ruleSet = (String) mapRuleSetItems.get('1L_Indv').ESB_RuleSetName__c;
			    }
			     else if (pager.GetIs_1T_BothSearch())
			    {
			    	if (mapRuleSetItems != null && mapRuleSetItems.get('1T_Indv') != null)
						ruleSet = (String) mapRuleSetItems.get('1T_Indv').ESB_RuleSetName__c;
			    }
			    else if (pager.GetIs_1L_ADR_Search())
			    {
			    	if (mapRuleSetItems != null && mapRuleSetItems.get('1L_ADR') != null)
						ruleSet = (String) mapRuleSetItems.get('1L_ADR').ESB_RuleSetName__c;
			    }
			     else if (pager.GetIs_1XL_ADR_Search())
			    {
			    	if (mapRuleSetItems != null && mapRuleSetItems.get('1XL_ADR') != null)
						ruleSet = (String) mapRuleSetItems.get('1XL_ADR').ESB_RuleSetName__c;
			    }
			    else if (pager.GetIs_1XXX_ADR_Search())
			    {
			    	if (mapRuleSetItems != null && mapRuleSetItems.get('1XXX_ADR') != null)
						ruleSet = (String) mapRuleSetItems.get('1XXX_ADR').ESB_RuleSetName__c;
			    }
			    
			    if(ruleSet == '')
					ruleSet = 'C_B_PTY_ADDR|Fuzzy_Match_Party_Addr_Indv_Loose';
			} else 
			{
				if(pager.GetIs_1N_BothSearch())
				{
					if (mapRuleSetItems != null && mapRuleSetItems.get('1N_Org') != null)
						ruleSet = (String) mapRuleSetItems.get('1N_Org').ESB_RuleSetName__c;
				}
				else if(pager.GetIs_1XXL_BothSearch())
				{
				  	if (mapRuleSetItems != null && mapRuleSetItems.get('1XX_Org') != null)
						ruleSet = (String) mapRuleSetItems.get('1XX_Org').ESB_RuleSetName__c;
				}
				else if (pager.GetIs_1XL_BothSearch())
			    {
			    	if (mapRuleSetItems != null && mapRuleSetItems.get('1XL_Org') != null)
						ruleSet = (String) mapRuleSetItems.get('1XL_Org').ESB_RuleSetName__c;
			    } 
			    else if (pager.GetIs_1L_IndvSearch())
			    {
			    	if (mapRuleSetItems != null && mapRuleSetItems.get('1L_Org') != null)
						ruleSet = (String) mapRuleSetItems.get('1L_Org').ESB_RuleSetName__c;
			    }
			     else if (pager.GetIs_1T_BothSearch())
			    {
			    	if (mapRuleSetItems != null && mapRuleSetItems.get('1T_Org') != null)
						ruleSet = (String) mapRuleSetItems.get('1T_Org').ESB_RuleSetName__c;
			    }
			     else if (pager.GetIs_1L_ADR_Search())
			    {
			    	if (mapRuleSetItems != null && mapRuleSetItems.get('1L_ADR') != null)
						ruleSet = (String) mapRuleSetItems.get('1L_ADR').ESB_RuleSetName__c;
			    }
			     else if (pager.GetIs_1XL_ADR_Search())
			    {
			    	if (mapRuleSetItems != null && mapRuleSetItems.get('1XL_ADR') != null)
						ruleSet = (String) mapRuleSetItems.get('1XL_ADR').ESB_RuleSetName__c;
			    }
			    else if (pager.GetIs_1XXX_ADR_Search())
			    {
			    	if (mapRuleSetItems != null && mapRuleSetItems.get('1XXX_ADR') != null)
						ruleSet = (String) mapRuleSetItems.get('1XXX_ADR').ESB_RuleSetName__c;
			    }
			}
			if(ruleSet == '')
			  ruleSet = 'C_B_PHYS_ADDR|Fuzzy_Match_Search_PHA_XLoose';
		}
		else
		{
			if (mapRuleSetItems != null && mapRuleSetItems.get(pager.RuleSetName) != null)
				ruleSet = (String) mapRuleSetItems.get(pager.RuleSetName).ESB_RuleSetName__c;
				system.debug('xxx from none set to  :' + ruleSet);
		}
		pager.RuleNameToDisp = ruleSet;
	    return ruleSet;
	}	
	//end new for version 2.2

	//remove as was replaced in version 2.2
	/*
	private String callMdmSiperianSearch(GNE_Account_Pager pager)
	{	         
    	System.debug(Logginglevel.INFO, 'pager.currSearch.AccountType_gne__c='+pager.currSearch.AccountType_gne__c);
    	System.debug(Logginglevel.INFO, 'Pager.currSearch.Street_gne__c='+Pager.currSearch.Street_gne__c);
    	System.debug(Logginglevel.INFO, 'Pager.currSearch.City_gne__c='+Pager.currSearch.City_gne__c);
    	System.debug(Logginglevel.INFO, 'Pager.currSearch.State_gne__c='+Pager.currSearch.State_gne__c);
    	System.debug(Logginglevel.INFO, 'Pager.currSearch.Zip_gne__c='+Pager.currSearch.Zip_gne__c);
    	System.debug(Logginglevel.INFO, 'Pager.currSearch.License_Number_gne__c='+Pager.currSearch.License_Number_gne__c);
    	System.debug(Logginglevel.INFO, 'Pager.currSearch.License_State_gne__c='+Pager.currSearch.License_State_gne__c);
    	System.debug(Logginglevel.INFO, 'Pager.currSearch.OrgName_gne__c='+Pager.currSearch.OrgName_gne__c);
        
        String returnVal = '';
		GNE_MDM_Siperian_Service.MdmProxyPortType mdmSvc = new GNE_MDM_Siperian_Service.MdmProxyPortType(); 
        mdmSvc.Timeout_x = 60000;
        
        Pager.mdmIdToRuleNumMap = new Map <String, String>();        
        Integer rowCount = 0;
        	
        if (pager.currSearch.AccountType_gne__c == 'HCP')
        {
        	GNE_MDM_Siperian_IndvAcctRes.IndividualAccountItemType[] mdmAccts;
        	if (!IsTestCase)
        	{
                mdmAccts= mdmSvc.searchIndividualAccount(
                        null,
                        Pager.currSearch.OrgName_gne__c,
                        null,
                        Pager.currSearch.OrgName_gne__c,
                        Pager.currSearch.Street_gne__c,
                        Pager.currSearch.State_gne__c,
                        Pager.currSearch.City_gne__c,
                        Pager.currSearch.Zip_gne__c,
                        Pager.currSearch.License_Number_gne__c,
                        Pager.currSearch.License_State_gne__c,
                     	1999);
				if(mdmAccts!=null)
				{				
					System.debug(Logginglevel.INFO, 'before filter  mdmAccts.size()='+ mdmAccts.size());
					
		    	    for(GNE_MDM_Siperian_IndvAcctRes.IndividualAccountItemType mdmAcct : mdmAccts)
	            	{
	            		System.debug(LoggingLevel.INFO, 'rule='+ mdmAcct.ruleNumber+',' + mdmAcct.mdmId.trim());
	            		rowCount ++;
	            		if (returnVal > '') returnVal += ',';
	    	        	if (mdmAcct.mdmId != null)	returnVal += '\'' + mdmAcct.mdmId.trim() + '\'';
	    	        	Pager.mdmIdToRuleNumMap.put(mdmAcct.mdmId, mdmAcct.ruleNumber);
	        		}
	        		System.debug(Logginglevel.INFO, 'after filter rowCount='+ rowCount);
	        		if (rowCount >= pager.getMaxResults())
				    {
				    	throw new GNE_Account_Dao.TooManyResultsException();
				    }
	        		  
	    		} else
				{
					System.debug(Logginglevel.INFO, 'mdmAccts is null');
				}
        	} else
        	{
				returnVal ='\'1150692\',\'1187332\',\'1261341\',\'1319140\',\'13404\',\'1341800\',\'1360503\',\'1412216\',\'1414129\',\'1516199\',\'1570982\',\'1618792\',\'1638730\',\'1675778\',\'1679722\',\'1682636\',\'1687812\',\'1691913\',\'1702260\',\'1903520\',\'1929612\',\'1930263\',\'1954394\',\'206187\',\'2076919\',\'2093627\',\'2176495\',\'2200933\',\'2255018\',\'2275557\',\'2287576\',\'383262\',\'394671\',\'407400\',\'470314\',\'475837\',\'510611\',\'519931\',\'548564\',\'638347\',\'648590\',\'660600\'';        		
        	}		                                                                                     	
        } else
        {   
        	
        	GNE_MDM_Siperian_OrgAcctRes.OrganizationAccountItemType[] mdmAccts; 
        	if (!IsTestCase) 
        	{                                                                            	
	        	mdmAccts = mdmSvc.searchOrganizationAccount(
                        Pager.currSearch.OrgName_gne__c,
                        Pager.currSearch.OrgName_gne__c,
                        Pager.currSearch.Street_gne__c,
                        Pager.currSearch.City_gne__c,
                        Pager.currSearch.State_gne__c,
                        Pager.currSearch.Zip_gne__c,
                     	1999);
        		
	   			if (mdmAccts != null)
				{
					System.debug(Logginglevel.INFO, 'mdmAccts.size()='+ mdmAccts.size());
					
				    for(GNE_MDM_Siperian_OrgAcctRes.OrganizationAccountItemType mdmAcct : mdmAccts)
	            	{
	            		System.debug(LoggingLevel.INFO, 'rule='+ mdmAcct.ruleNumber+',' + mdmAcct.mdmId.trim());
	            		rowCount ++;
	            		if (returnVal > '') returnVal += ',';
	    	        	if (mdmAcct.mdmId != null)	returnVal += '\'' + mdmAcct.mdmId.trim() + '\'';
	    	        	Pager.mdmIdToRuleNumMap.put(mdmAcct.mdmId, mdmAcct.ruleNumber);
	        		}
	        		System.debug(Logginglevel.INFO, 'after filter rowCount='+ rowCount);
	        		if (rowCount >= pager.getMaxResults())
				    {
				    	throw new GNE_Account_Dao.TooManyResultsException();
				    }
				} else
				{
					System.debug(Logginglevel.INFO, 'mdmAccts is null');
				}
        	} else
        	{
        		returnVal ='\'1027361\',\'1027802\',\'1033343\',\'1034931\',\'1151247\',\'1154810\',\'1158361\',\'116120\',\'116140\',\'116145\',\'116146\',\'116147\',\'1162036\',\'116828\',\'116893\',\'116894\',\'117377\',\'117390\',\'1174315\',\'117454\',\'117937\',\'117998\',\'118179\',\'118226\',\'11834153\',\'118491\',\'118492\',\'118501\',\'118505\',\'118512\',\'119018\',\'119020\',\'119784\',\'120139\',\'120315\',\'120403\',\'120498\',\'120593\',\'120727\',\'120831\',\'120853\',\'121290\',\'121375\',\'121412\',\'121418\',\'121498\',\'121643\',\'121683\',\'121692\',\'121703\',\'121715\',\'121725\',\'121779\',\'121972\',\'122000\',\'122165\',\'122230\',\'122265\',\'122466\',\'122676\',\'122754\',\'122883\',\'122948\',\'12294966\',\'123026\',\'123163\',\'123265\',\'123567\',\'123568\',\'124053\',\'124192\',\'124199\',\'124215\',\'124241\',\'124274\',\'124304\',\'124327\',\'124329\',\'124330\',\'124446\',\'124457\',\'124507\',\'124735\',\'124758\',\'124780\',\'124908\',\'138857\',\'139348\',\'139538\',\'141495\',\'141653\',\'141988\',\'142226\',\'142321\',\'142787\',\'142808\',\'142951\',\'143062\',\'143449\',\'143453\',\'143463\',\'143639\',\'143832\',\'143968\',\'144088\',\'144097\',\'144133\',\'144318\',\'144373\',\'1505564\',\'1541074\',\'161085\',\'164685\',\'170793\',\'1717701\',\'1717723\',\'172908\',\'1738398\',\'1738410\',\'174022\',\'174027\',\'174556\',\'1757479\',\'1757542\',\'175835\',\'176241\',\'1765240\',\'1769046\',\'1786482\',\'1798522\',\'1804180\',\'180885\',\'1818132\',\'1820057\',\'182548\',\'182553\',\'182558\',\'182563\',\'182731\',\'183537\',\'186430\',\'186629\',\'186638\',\'186649\',\'186863\',\'186864\',\'187122\',\'187126\',\'187128\',\'187314\',\'188175\',\'188404\',\'188624\',\'188625\',\'188628\',\'188641\',\'188653\',\'188666\',\'188847\',\'189086\',\'1894126\',\'1898749\',\'1899301\',\'1901193\',\'19349301\',\'19352032\',\'196998\',\'197305\',\'197316\',\'197704\',\'197712\',\'197768\',\'197993\',\'197994\',\'198005\',\'198388\',\'198541\',\'198857\',\'199277\',\'199299\',\'199327\',\'199936\',\'199973\',\'200094\',\'200150\',\'200161\',\'2113426\',\'2430568\',\'2439490\',\'2440514\',\'2449229\',\'2449392\',\'2449452\',\'2449457\',\'2485155\',\'2485170\',\'2485172\',\'2485186\',\'2486725\',\'2486830\',\'2490502\',\'2490973\',\'2491133\',\'2496656\',\'2496693\',\'2496695\',\'2499027\',\'2499504\',\'2499528\',\'2529162\',\'2530748\',\'2562479\',\'300518\',\'5593340\',\'5594753\',\'5595249\',\'5599006\',\'5631583\',\'5677469\',\'5703441\',\'5705046\',\'5720690\',\'5720804\',\'5721382\',\'5762017\',\'652176\',\'850897\',\'852319\',\'855706\',\'861022\',\'866055\',\'866265\',\'878605\',\'882893\',\'894422\',\'907040\',\'916521\',\'917702\',\'925292\',\'925661\',\'926652\',\'927341\',\'927467\',\'928093\',\'933182\',\'935054\',\'936131\',\'936874\',\'937413\',\'938086\',\'939556\',\'939614\',\'939790\',\'939969\',\'940224\',\'940226\'';
        	}		                                                                                            	
        }
        
		return returnVal;	
	}*/

	public List <SFASearchStrings_gne__c> callOldMdmSiperianSearch(GNE_Account_Pager pager)
	{
		List <SFASearchStrings_gne__c> returnList;
		
		Map <String, List <Map <String, String>>> resultMap = new Map<String, List <Map <String, String>>>();
		
		try { 
			mdm0620MDMProxyService.MdmProxyPortType mdmSvc=new mdm0620MDMProxyService.MdmProxyPortType(); 
	        mdmSvc.Timeout_x = 60000;
	        mdm0620SearchIndividualAcctRS.IndividualAccountItemType[] mdmAcctList;
	        
	        if (Pager.acct.IsPersonAccount)
	        {
	        	System.debug('Calling old Siperian Search with Pager.acct.FirstName='+Pager.acct.FirstName);
	        	System.debug('Pager.acct.LastName='+Pager.acct.LastName);
		        mdmAcctList= mdmSvc.searchIndividualAccount(
	                                                    Pager.acct.FirstName,
	                                                    Pager.acct.LastName,
	                                                    null,
	                                                    null,
	                                                    null,
	                                                    null,
	                                                 	pager.getMaxResults());
				if(mdmAcctList != null && mdmAcctList.size() > 0)
				{
					System.debug('mdmAcctList.size()='+mdmAcctList.size());
					SFASearchStrings_gne__c result; 
		            for(mdm0620SearchIndividualAcctRS.IndividualAccountItemType row : mdmAcctList)
		            {
		            	if (row.mdmId == Pager.acct.MDMID_gne__c)
		            	{
			            	result = new SFASearchStrings_gne__c();
			            	result.MDMId_gne__c = row.mdmId;
			                result.FirstName_gne__c = row.individualFirstName;
			                result.LastName_gne__c = row.individualFamilyName;
			                result.Street_gne__c = row.primaryStreetAddress;
			                result.City_gne__c = row.city;
			                result.State_gne__c = row.state;
			                result.Zip_gne__c = row.postalCode;
			                result.Address_MDM_ID_gne__c = row.partyAddressId.trim();
			                returnList.add(result);
		            	}    
		        	}
				} else
				{
					System.debug('mdmAcctList has no items');
				}
	        } else
	        {
	        	//get orgs
	        }
		} catch (Exception e)
		{
			System.debug('Exception caught calling OLD MDM/Siperian WS. Message='+ e);
			throw e;	
		}                                                                                
		
		return returnList;
	}	
}