public with sharing class GNE_TimeOffTerritory_Controller extends GNE_Base_Controller {
//------------------------------
// Author:      Liz Ichihashi
// Date:        10/07/2010  
// Description: 
//    This controller is used by the GNE_TimeOffTerritory page 
//    Which is the New button override for Time_Off_Territory_gne__c.
//    This page/controller combination is a re-factored version of TimeOffTerritory scontrol
//    With new logic for Primary care users.
//
// Change History:
//
//------------------------------
    public Time_Off_Territory_gne__c tot {get; set;}
    public Time_off_Territory_Day_gne__c from_totd {get; set;}
    public Time_off_Territory_Day_gne__c to_totd {get; set;}
    public String profileName {get; set;} 
    public String retUrl;
    public String AssignedReferralSearchFld { get; set; }
	public String AssignedReferralSearchId { get; set; }
	public String AssignedReferralSearchFldHidden { get; set; }
  
    
    public GNE_TimeOffTerritory_Controller(ApexPages.StandardController controller) 
    {
        this.tot = (Time_Off_Territory_gne__c)controller.getRecord();
        IsTestCase = false;
    init();      
    }  

    public GNE_TimeOffTerritory_Controller(boolean isTest) 
    {
      IsTestCase = isTest;
    init();      
    }  
  
  public void init()
  {
        from_totd = new Time_off_Territory_Day_gne__c();
        from_totd.Hours_Off_Territory__c = '8';
        to_totd = new Time_off_Territory_Day_gne__c();
        from_totd.Hours_Off_Territory__c = '8';

        // Get user data for profile name
        List <User> userList = [Select id, Profile_Name_gne__c From User where id = :UserInfo.getUserId()];
        if (userList.size() > 0)
        {
            profileName = userList[0].Profile_Name_gne__c;
        }
  }  

    public PageReference cancel()
    {
        // Return to Time off Territoty list page      
        if (!IsTestCase) retUrl = ApexPages.currentPage().getParameters().get('retURL');
        if (retUrl == null) retUrl = '/a1S/o';
        PageReference totListPage = new PageReference(retUrl);
        totListPage.setRedirect(true);
        return totListPage;
    }
    
    public PageReference CreateTOT()
    {
      try 
      {
          // Validate input
          if (!validate()) return null;
          
          if(getIsMSLProfile()) {
          	tot.Assigned_Referral_Activity_gne__c = AssignedReferralSearchId;
          }
          
          // Save Time of Territory record
          tot.Approval_Status_gne__c = 'Pending';
          if (profileName.contains('MCCO'))
          {
              tot.Description_gne__c = from_totd.Reason_MCCO_gne__c;
          } else if (profileName.contains('Primary-Care'))
          {
              tot.Description_gne__c = from_totd.Reason_PC_gne__c;
          }else if (profileName.contains('MedAffairs'))
          {
              tot.Description_gne__c = from_totd.Reason_MedAffair_gne__c;
          }else
          {
              tot.Description_gne__c = from_totd.Reason_SFA_gne__c;
          }
          insert tot;
          
          // Save Time of Territory Days record (or records, if date range)       
          List<Actual_Working_Days_gne__c> awdList =
                                [SELECT Date_gne__c, Id 
                                 FROM Actual_Working_Days_gne__c 
                                 WHERE Date_gne__c >= :from_totd.Date_gne__c
                                 AND Date_gne__c <= :to_totd.Date_gne__c];
                                 
          List<Time_Off_Territory_Day_gne__c> totdList = new List<Time_Off_Territory_Day_gne__c>();        
          
          for(Actual_Working_Days_gne__c awd :awdList)
          {
              Time_Off_Territory_Day_gne__c t = new Time_Off_Territory_Day_gne__c();
              t.Date_gne__c = awd.Date_gne__c;
              t.Time_Off_Territory_gne__c = tot.id;
              t.Hours_Off_Territory__c = from_totd.Hours_Off_Territory__c;
              t.Reason_PC_gne__c = from_totd.Reason_PC_gne__c;
              t.Reason_SFA_gne__c = from_totd.Reason_SFA_gne__c;
              t.Reason_MCCO_gne__c = from_totd.Reason_MCCO_gne__c;
              totdList.add(t);
          }
          
          insert totdList;
          
          // Return to Time of Territoty detail page        
          PageReference totPage = new ApexPages.StandardController(tot).view();
          totPage.setRedirect(true);
          return totPage;
      } catch (Exception e)
      {
        handleError('GNE_TimeOffTerritory_Controller', 'createTOT', e);
      }
      return null;        
    }
    
    public boolean validate()
    {
      boolean retVal = true;

        if (from_totd.Date_gne__c == null)
        {
            from_totd.Date_gne__c.addError('From Date is required');
            retVal = false;
        }
        if (to_totd.Date_gne__c == null)
        {
            to_totd.Date_gne__c.addError('To Date is required');
            retVal = false;
        }
        
        if (retVal)
        {
          if (from_totd.Date_gne__c > to_totd.Date_gne__c)
          {
              to_totd.Date_gne__c.addError('Invalid date range.  To Date cannot be prior to From Date');
              retVal = false;
          }
      
      		if (retVal)
      		{	    
            	Integer from_year = from_totd.Date_gne__c.year();
            	Integer to_year = to_totd.Date_gne__c.year();
            	if (from_year != to_year)
            	{
                	to_totd.Date_gne__c.addError('Invalid date range.  You must create separate entries for a time period covering multiple years.');
                	retVal = false;
            	}
      		}    
        }
        
        if (retVal && profileName.contains('GNE-MedAffairs-MSL'))
        {
        	if(AssignedReferralSearchFld==null || AssignedReferralSearchFld=='') {
        		tot.addError('Assign Referral Activity is required');
        		retVal = false;
        	} else if (!AssignedReferralSearchFld.equals(AssignedReferralSearchFldHidden)) {
        		String searchText = AssignedReferralSearchFld;
        		searchText.Replace('*','%');
        		searchText='%'+searchText+'%';
        		List<User> users = [Select Id from User 
        							where Id <> :UserInfo.getUserId() and 
        							Profile_name_gne__c LIKE 'GNE-MedAffairs-MSL%' and 
        							isActive= true and 
        							Name like :searchText];
        		if(users.size()==1) {
        			AssignedReferralSearchId=users[0].Id;
        		} else if (users.size()>1) {
        			tot.addError('Multiple User found. Click Lookup icon at \'Assign Referral Activity to\' Field to refine the search.');
        			retVal=false;	
        		} else {
        			tot.addError('No User found. Click Lookup icon at at \'Assign Referral Activity to\' Field to select appropriate user.');
        			retVal=false;
        		}
        		//calculate AssignedReferralSearchId
        		
        	} else if(AssignedReferralSearchId==null || AssignedReferralSearchId=='') {
        		tot.addError('Assign Referral Activity is required');
        		retVal = false;
        	}
        }    
      
      return retVal;  
    }
    
    public Boolean getIsMSLProfile() {
    	return profileName.contains('GNE-MedAffairs-MSL');
    }
    
    public Static testMethod void test_GNE_TimeOffTerritory_Controller()
  {
    GNE_TimeOffTerritory_Controller cont = new GNE_TimeOffTerritory_Controller(true);
    cont.cancel();
    cont = new GNE_TimeOffTerritory_Controller(true);  
    
    Time_Off_Territory_gne__c tot = new Time_Off_Territory_gne__c();
    cont.tot = tot;
    cont.from_totd.Reason_MCCO_gne__c = 'MyReas';
    cont.from_totd.Reason_SFA_gne__c = 'MyReas';
    cont.from_totd.Reason_PC_gne__c = 'MyReas';
    cont.CreateTot();
    cont.from_totd.Date_gne__c = System.today();
    cont.CreateTot();
    cont.to_totd.Date_gne__c = System.Today() - 2;
    cont.CreateTot();
    cont.to_totd.Date_gne__c = System.Today() + 500;
    cont.CreateTOT();
    cont.to_totd.Date_gne__c = System.Today();
    cont.CreateTOT();
    System.assert(cont.tot.Id != null);
    cont.profileName = 'MCCO';
    cont.CreateTot();
  }
}