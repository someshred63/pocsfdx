/*  _____ ___ ___ _      ___ ___  ___     _ ___ ___ _____    */ 
/* |_   _|_ _/ __| |    | _ \ _ \/ _ \ _ | | __/ __|_   _|   */
/*   | |  | |\__ \ |__  |  _/   / (_) | || | _| (__  | |     */
/*   |_| |___|___/____| |_| |_|_\\___/ \__/|___\___| |_|     */


public with sharing class GNE_TISL_Search_Page_Controller extends GNE_Base_Controller {
    
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
    public private Static String BTN_MESSAGE1 = 'Show Recruiting Only';
    public private Static String BTN_MESSAGE2 = 'Show All Found';
    public private Static String BTN_MESSAGE3 = 'Search';
    public private Static String BTN_MESSAGE4 = 'Refine';
    public private Static String TITLE_BASIC = 'Internal Trial Search';
    public private Static String TITLE_ADVANCED = 'Internal Trial Advanced Search';
    private String sBtnMessage;
    private String sTitle;
    private String sBtn1Message;
    public String inputNCTNumber {set;get;}
    public String inputDiagnosis {set;get;}
    public String inputStatus {set;get;}
    public String inputProduct {set;get;}
    public String inputPhase {set;get;}
    public String inputState {set;get;}
    public String inputContact {set;get;}
    
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
    
    public GNE_TISL_Search_Page_Controller()
    {
        init();
    }
    
    public void init()
    {
        ShowResults = false;
        IsTestCase = false;
        SearchSwitch = false;
        sInputValue = 'Search Text...';
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
        
        List<GNE_TISL_Config_Items_gne__c> tmo = GNE_TISL_Config_Items_gne__c.getall().values();
        String PhaseAllValue = tmo[2].Configuration_Value_gne__c;
        List<String > strArry = PhaseAllValue.split(';');
        for (String row : strArry)
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
        
        List<GNE_TISL_Config_Items_gne__c> tmo = GNE_TISL_Config_Items_gne__c.getall().values();
        String PhaseAllValue = tmo[0].Configuration_Value_gne__c;
        List<String > strArry = PhaseAllValue.split(';');
        for (String row : strArry)
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
    
}