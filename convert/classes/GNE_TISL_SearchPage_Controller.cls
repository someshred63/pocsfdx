/*
Class Name = GNE_TISL_SearchPage_Controller
Designed By - MSat Team
Date - 15Dec 2012
*/ 


public with sharing class GNE_TISL_SearchPage_Controller extends GNE_Base_Controller {
        
    public String sInputValue {get;set;}    
    public String sNctNumber {get;set;}
    public String sTrialId {get;set;}
    public String sIsPopup {get;set;}
    public Boolean ShowResults {get;set;}
    public Boolean SearchSwitch {get;set;}
    public String sFilteredInput {get;set;}
    public List<SelectOption> stateList;
    public static final String NONE_SELECTED = '--None--';  
    private GNE_TISL_Trial_Dao dao;
    public GNE_TISL_Trial_Pager pager {get;set;}
    public String msgPageT {get;set;}
    public Boolean bShowAlert {get;set;}
    public TISL_Site_gne__c objSite;
    public List<String> InputStringAfterProcess;
    public Static String BTN_MESSAGE1 = 'Show Recruiting Only';
    public Static String BTN_MESSAGE2 = 'Show All Found';
    public Static String BTN_MESSAGE3 = 'Search';
    public Static String BTN_MESSAGE4 = 'Refine';
    public Static String TITLE_BASIC = 'Internal Trial Search';
    public Static String TITLE_ADVANCED = 'Internal Trial Advanced Search';
    private String sBtnMessage;
    private String sTitle;
    private String sBtn1Message;
    public String inputNCTNumber {set;get;}
    public String inputDiagnosis {set;get;}
    public String inputStatus {set;get;}
    public String inputProduct {set;get;}
    public String inputContact {set;get;}
    public String inputPhase {set;get;}
    public String inputState {set;get;}
    public String nct{get;set;}
    public String feed{get;set;}
    public String iFrameSrc{get;set;}   
    public Boolean msg{get;set;} 
      public String getTitle()
    {
        return sTitle;
    }
    public String getBtnMessage()
    {
        return sBtnMessage;
    }
    public String getBtn1Message()
    {
        return sBtn1Message;
    }
    
   public GNE_TISL_SearchPage_Controller()
    {
        init();    
        nct='';
        frameSourceMethod();
    }
    
    public void init()
    {
        ShowResults = false;
        IsTestCase = false;
        SearchSwitch = false;
      //  sInputValue = 'Search Text...';
        msgPageT = '';
        sTitle = TITLE_BASIC;
        bShowAlert = false;
        sBtnMessage = BTN_MESSAGE1;
        sBtn1Message = BTN_MESSAGE3;
        Pager = new GNE_TISL_Trial_Pager(IsTestCase);
        Pager.bFilteredSet = false;
        objSite = new TISL_Site_gne__c ();
    }
   
    public List<SelectOption> getAllState() 
    {
        
        String allstates = 'AK#AL#AR#AZ#CA#CO#CT#DC#DE#FL#GA#HI#IA#ID#IL#IN#KS#KY#LA#MA#MD#ME#MI#MN#MO#MS#MT#NC#ND#NE#NH#NJ#NM#NV#NY#OH#OK#OR#PA#PR#RI#SC#SD#TN#TX#UT#VA#VT#WA#WI#WV#WY';
        List<SelectOption> options;
        options = new List<SelectOption>();
        options.add(new SelectOption(NONE_SELECTED, NONE_SELECTED));
        List<String> States = allstates.split('#',0);
        for (String row : States)
        {
            options.add(new SelectOption(row,row));                    
        }
        sortSelectOptions(options, 1, options.size() - 1);
        
        return options;
    }
    public List<SelectOption> getFilters() 
    {
        List<SelectOption> options;
        
        options = new List<SelectOption>();
        options.add(new SelectOption(NONE_SELECTED, NONE_SELECTED));
        List<String> tmo = pager.getStates();
        for (String row : tmo)
        {
            System.debug('XXXXXXXXX Adding to States in Controller:' + row);
            options.add(new SelectOption(row, row));                    
        }
        sortSelectOptions(options, 1, options.size() - 1);
        stateList = removeDups(options);

        return stateList;
    }
     public List<SelectOption> getPhase() 
    {
       List<SelectOption> options;
        
        options = new List<SelectOption>();
        options.add(new SelectOption(NONE_SELECTED, NONE_SELECTED));
        
        GNE_TISL_Config_Items_gne__c phase = GNE_TISL_Config_Items_gne__c.getValues('StudyPhaseList');
        String allPhaseValues = phase.Configuration_Value_gne__c;
        List<String> strArray = allPhaseValues.split(';'); 
        for (String row : strArray)
        {
            options.add(new SelectOption(row, row));                    
        }
        sortSelectOptions(options, 1, options.size() - 1);
        
        return options;
        
    }
    public List<SelectOption> getStatusTrial() 
    {
        List<SelectOption> options;
        
        options = new List<SelectOption>();
        options.add(new SelectOption(NONE_SELECTED, NONE_SELECTED));
        
        GNE_TISL_Config_Items_gne__c status = GNE_TISL_Config_Items_gne__c.getValues('StudyStatusList');
        String allStatusValues = status.Configuration_Value_gne__c;
        List<String> strArray = allStatusValues.split(';'); 

        for (String row : strArray)
        {
            options.add(new SelectOption(row, row));                    
        }
        sortSelectOptions(options, 1, options.size() - 1);
        
        return options;
    }

    private List<SelectOption> removeDups(List<SelectOption> inList)
    {
        List<SelectOption> newList = new List<SelectOption>{};
        String currVal;
        for (SelectOption row : inList)
        {
            if (currVal != row.getLabel())
            {
                newList.add(row);   
            }
            currVal = row.getLabel();
        }   
        return newList; 
    }

    public PageReference changeFilter()
    {
        if(sFilteredInput != NONE_SELECTED)
        {
            Pager.FilteredBy = sFilteredInput;
            Pager.bFilteredSet = true;      
            Pager.changeDispData();   
        }
        else
        {
                Pager.bFilteredSet = false;
                Pager.changeDispData();
        }
        
        return null;
    }
    
     public PageReference executeShowRecruiting()
     {
        if(Pager.ShowRecBtnWasClicked == false)
        {
                Pager.ShowRecBtnWasClicked = true;
                sBtnMessage = BTN_MESSAGE2;
        }
        else
        {
                Pager.ShowRecBtnWasClicked = false;
                sBtnMessage = BTN_MESSAGE1;
        } 
                
        Pager.changeDispData();
        return null;
     }
    
    public PageReference executeSimpleSearch()
    {
        System.Debug('XXXXXXXXXX Execute executeSimpleSearch and string search is :' + sInputValue);
        InputStringAfterProcess = Pager.formatQueryString(sInputValue);
        Pager.PerformAdvancedSerach = false;
        Pager.bFilteredSet = false;
        Pager.ShowRecBtnWasClicked = false;
        sBtnMessage = BTN_MESSAGE1;
        sFilteredInput = NONE_SELECTED;
        msgPageT = InputStringAfterProcess[0];   
        
        System.Debug('XXXXXXXXXX |msgPageT :' + msgPageT);
        if (msgPageT == '' )
        {
            Pager.sSearchString = InputStringAfterProcess[1];
        
            System.Debug('XXXXXXXXXX |Strig after proccesing is :' + pager.sSearchString);
            Pager.currSort = 'Sites_Without_State_Count_gne__c';
            Pager.currSortOrder = 'asc';  
            Pager.loadData();
                this.sortWithOutState();
            ShowResults = true;
        }
        else
        {
            bShowAlert = true;
            ShowResults = false;
        }
        
        
        return null;
    }
    public PageReference executeAdvancedSearch()
    {
        System.Debug('XXXXXXXXX Site_Country_gne__c : ' + objSite.Site_Country_gne__c);
        System.Debug('XXXXXXXXXXXXXXXXXXX  Execute executeAdvancedSearch ');
        InputStringAfterProcess = Pager.formatQueryStringAdvanced(inputNCTNumber,inputDiagnosis ,inputProduct,inputStatus,inputPhase,inputState, inputContact);
        Pager.PerformAdvancedSerach = true;
        Pager.bFilteredSet = false;
        Pager.ShowRecBtnWasClicked = false;
        msgPageT = InputStringAfterProcess[0];
        System.Debug('XXXXXXXXXXXXXXXXXXX  msgPageT : ' + msgPageT);
        if (msgPageT == '' )
        {
            Pager.sSearchString = InputStringAfterProcess[1];
            Pager.sSiteContact = inputContact;
            Pager.currSort = 'Sites_Without_State_Count_gne__c';
            Pager.currSortOrder = 'asc';  
            Pager.loadData();
                this.sortWithOutState();
            ShowResults = true;
            sBtn1Message = BTN_MESSAGE4;
        }
        else
        {
            sBtn1Message = BTN_MESSAGE3;
            bShowAlert = true;
            ShowResults = false;
        }
        
        System.Debug('XXXXXXXXXXXXXXXXXXX  InputQuery: ' + InputStringAfterProcess[1]);
        return null; 
        
    }
    
    public PageReference switchToAdvancedSearchView()
    {
        sTitle =TITLE_ADVANCED;
        sInputValue = 'Search Text...';
        SearchSwitch = true;
        ShowResults = false;
        bShowAlert = false;
        return null;
    }
    public PageReference switchToBasicSearchView()
    {
        sTitle =TITLE_BASIC;
        inputNCTNumber = '';
        inputDiagnosis = '';
        inputStatus = '';
        inputProduct = '';
        inputPhase = '';
        inputState = '';
        sBtn1Message = BTN_MESSAGE3;
        objSite.Site_Country_gne__c = 'UNITED STATES';
        objSite.Site_State_gne__c = NONE_SELECTED; 
        SearchSwitch = false;
        ShowResults = false;
        bShowAlert = false;
        
        return null;
    }
    public PageReference sortTile()
    {
        Pager.sortList('Trial_Full_Title_gne__c');
        return null;
    }
    
    public PageReference sortPhase()
    {
        Pager.sortList('Phase_gne__c');
        return null;
    }
    
    public PageReference sortDiagnosis()
    {
        Pager.sortList('Diagnosis_gne__c');
        return null;
    }
    
    public PageReference sortProduct()
    {
        Pager.sortList('Product_Name_Calc_gne__c');
        return null;
    }
    
    public PageReference sortStatus()
    {
        Pager.sortList('Trial_Status_gne__c');
        return null;
    }
    public PageReference sortWithOutState()
    {
        Pager.sortList('Sites_With_no_State_Count_gne__c');
        return null;
    }   
    public PageReference sortLastModifiedDate()
    {
        Pager.sortList('LastModifiedDate');
        return null;
    }
     public PageReference searchDetails()
    {
        try
        {   
            msg=false;
            if(sInputValue=='' || sInputValue=='Search Text...')
            {
                nct='NCT';
                 msg=true;
             //   Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_NCTNumber));                
            }            
            else
            {
                List<TISL_Clinical_Trial_gne__c> objNCT = [Select NCT_Number_gne__c from TISL_Clinical_Trial_gne__c where GNE_TRIAL_NUMBER_GNE__C=:sInputValue OR NCT_Number_gne__c =:sInputValue OR Trial_Number_gne__c=:sInputValue OR GNE_TRIAL_NUMBER_GNE__C=:sInputValue.toUpperCase() OR NCT_Number_gne__c =:sInputValue.toUpperCase() OR Trial_Number_gne__c=:sInputValue.toUpperCase()];
                if(objNCT.size() > 0)
                {
                    executeSimpleSearch();                  
                    nct=Pager.getdispList()[0].id;    
                }
                else
                {
                    nct='NCT';
                     msg=true;
                  //  Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_NCTNumber));    
                }    
            }    
        }
        catch(Exception ex)
        {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_ErrorMsg));
        }     
        return null;
    }
    
    public void frameSourceMethod()
    {  
        try
        {
            feed=ApexPages.currentPage().getParameters().get('feed');
            String startDate,endDate;
            Integer s_mon,e_mon;
            Integer s_day,e_day;
            Integer s_year,e_year;            

            e_mon=(system.Today()).month();
            e_day=(system.Today()).day();
            e_year=(system.Today()).year();
            if(e_mon==1) { s_mon=12; } else { s_mon=e_mon-1; }
            if(e_mon==1) { s_year=e_year-1; } else { s_year=e_year; }
            s_day = e_day;
            startDate = s_mon + '/' + s_day + '/' + s_year;
            endDate = e_mon + '/' + e_day + '/' + e_year;            
            
            if(feed=='Genentech')
            {
                iFrameSrc='https://www.ClinicalTrials.gov/ct2/results?spons=' + feed + '&rcv_s=' + startDate + '&rcv_e=' + endDate;    
            }
            else if(feed=='Roche')
            {
                iFrameSrc='https://www.ClinicalTrials.gov/ct2/results?spons=' + feed + '&rcv_s=' + startDate + '&rcv_e=' + endDate;    
            }
            else if(feed=='ClinicalTrails')                        
            {
                iFrameSrc='https://www.ClinicalTrials.gov';  
            }
            else
            {
                iFrameSrc='https://www.ClinicalTrials.gov';
            }
           
        }
        catch(Exception ex)
        {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,System.Label.GNE_TISL_ErrorMsg));
        }
    }   
        //www.clinicaltrials.gov/ct2/results?spons=Genentech&rcv_s=11/14/2012&rcv_e=12/14/2012
        
    public Boolean getIsMSLForTISL() {
    	return GNE_TISL_Utils.isCurrentUserMSLForTISL();
    }
    
}