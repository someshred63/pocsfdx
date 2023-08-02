/*  _____ ___ ___ _      ___ ___  ___     _ ___ ___ _____    */ 
/* |_   _|_ _/ __| |    | _ \ _ \/ _ \ _ | | __/ __|_   _|   */
/*   | |  | |\__ \ |__  |  _/   / (_) | || | _| (__  | |     */
/*   |_| |___|___/____| |_| |_|_\\___/ \__/|___\___| |_|     */

public with sharing class GNE_TISL_Site_Information_Controller extends GNE_Base_Controller
{
    
//---Reference to standard controller
    public ApexPages.StandardController StdCont { get; set;}    
    private String TrialID;
    private boolean bShowInfoAboutState;
    private GNE_TISL_Site_Dao dao;
    public String sFilteredOpt{ get; set;}
    public String sFilterInput{ get; set;}        
    public String sPatAddressInput{ get; set;}
    public String sPatLng{ get; set;}
    public String sPatLat{ get; set;}
    public String sIsPopup{ get; set;}
    public boolean RenderResults {get;set;} 
    public GNE_TISL_Site_Pager pager {get;set;}  
    public String pageTitle {get; set;}
    public List<SelectOption> stateList;
    public static final String NONE_SELECTED = '--None--';
    public boolean bFilteredSet {get;set;}
    public String msgPageT  {get; set;}
    public List<String> msgPage;
    public boolean bActiveMapBtn {get; set;}
    public boolean bShowAlert {get; set;}
    public boolean isPopup {get; set;}
    public String addressForGoogle;
    public boolean isWrongNCT {get;set;}
    private static String MESSAGE1 = 'There are sites with missing state or country and are not shown in this list';
    private static String MESSAGE2 = 'Provided NCT Number is not assigned to any study in the internal system.';
    private static String MESSAGE3 = 'Please enter the patient\'s address and try again.';
    private static String googleMapsJSURL = 'https://maps.google.com/maps/api/js?' + GNE_TISL_GeoCode.API_KEY;

    public String getMessage1()
    {
        return MESSAGE1;
    } 
    
    public boolean getshowInfoAboutStates()
    {
        return bShowInfoAboutState;
    }
    
    public String inputData { get; set; }
    
    public String googleMapsJSLibURLConvert { 
      get {
       TISL_GenerateKey gen_key= new  TISL_GenerateKey();
       String url = gen_key.getSig(googleMapsJSURL);
       return url; 
      }
      set; 
    }
    
    
    public String getsTID()
    {
        return TrialID;
    } 
    public GNE_TISL_Site_Information_Controller()
    {
        IsTestCase = true;
        init();
    }
    public GNE_TISL_Site_Information_Controller(ApexPages.StandardController cont)
    {
        IsTestCase = false;
        StdCont = cont; 
        RenderResults = true;
        init();     
    }
 public void init()
    {

        SObject sobjectInstance = StdCont.getRecord(); 
    
        if ( apexpages.currentpage().getparameters().containsKey('nctid'))
        {
            String nctId = ApexPages.currentPage().getParameters().get('nctid');
            String Query = 'Select Id  from TISL_Clinical_Trial_gne__c where NCT_Number_gne__c like \'%'+ nctId +'%\' order by LastModifiedDate DESC limit 1';
            List<TISL_Clinical_Trial_gne__c> tmp = Database.query(Query);
            if(tmp.size() > 0)
            {
                TrialID = tmp[tmp.size()-1].Id;
                isWrongNCT = false;
            }
            else
            {               
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,MESSAGE2);
                ApexPages.addMessage(myMsg);
                isWrongNCT = true;
            }
                    
        }
        else
        {
             
             if ( sobjectInstance.getsObjectType() ==  TISL_Clinical_Trial_gne__c.sObjectType  )
             {
                TrialID = (String) sobjectInstance.get('Id');system.debug('Vaibhav33-->' + TrialID);
             }
             isWrongNCT = false;    
             
        }
        
        System.Debug('XXXXXXXXXXXXXXXXX isWrongNCT :' + isWrongNCT);
        Pager = new GNE_TISL_Site_Pager(IsTestCase);
        
        if ( apexpages.currentpage().getparameters().containsKey('isPopup'))
        {
            sIsPopup = System.currentPageReference().getParameters().get('isPopup');
            if (sIsPopup == 'Y') isPopup = true;
            else  isPopup = false;
        }
        else  isPopup = false;
        bShowInfoAboutState = Pager.showInfoAboutEmptyStates;
        Pager.TrialId = TrialID;
        Pager.FilteredBy = 'Status';
        Pager.setDispRows(5);
        Pager.bFilteredSet = false;
        //bActiveMapBtn = true;
        bShowAlert = false;
        Pager.loadData();
      
    }
    
    public String getAddresses()
    {
        addressForGoogle = pager.getAddresses();
        System.Debug('XXXXXXXXXXXXXXXXXXXXXXXX String Add'+ addressForGoogle);
        return addressForGoogle;
    }
    
    public List<SelectOption> getFilters() 
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Status','Status'));
        options.add(new SelectOption('State','State'));
        options.add(new SelectOption('Country','Country'));
        return options;
    }
    public List<SelectOption> getStatesOrCountries() 
    {
        List<SelectOption> options;
        
            options = new List<SelectOption>();
            options.add(new SelectOption(NONE_SELECTED, NONE_SELECTED));
            Set<String> tmo = pager.getStatesOrCountries();
            for (String row : tmo)
            {
                options.add(new SelectOption(row, row));                    
            }
            sortSelectOptions(options, 1, options.size() - 1);
            // Not necessary when set are used
            //stateList = removeDups(options);

          if(pager.showDefaultActive && !pager.bFilteredSet )
             sFilterInput = 'Active Recruiting';    
           
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
    public PageReference changeSets()
    {
         
         Pager.loadData();
         return null;
    }
    
    public PageReference changeFilter()
    {
        Pager.FilteredBy = sFilteredOpt;
        // Removed because of some error 
        //getStatesOrCountries();
        if(Pager.showDefaultActive){
            sFilterInput = 'Active Recruiting'; 
        }
        else{
            sFilterInput = NONE_SELECTED;   
        }
        
        
        return null;
    }

    public PageReference filter()     
    {
        if(sFilterInput != NONE_SELECTED)
        {
            Pager.FilteredBy = sFilteredOpt;
            Pager.FilteredByLev2 = sFilterInput;
            Pager.bFilteredSet = true;
            Pager.setDispRows(5);
            Pager.CurrentSet = '1';
            Pager.loadData();
            bShowInfoAboutState = Pager.showInfoAboutEmptyStates;
            System.Debug('XXXXXXXXXXXX bShowInfoAboutState : ' + bShowInfoAboutState);   
            bFilteredSet = true;
        }
        return null;
    }
    public PageReference clrfilter()     
    {
        Pager.FilteredBy = 'Status';
        Pager.FilteredByLev2 = NONE_SELECTED;
        Pager.bFilteredSet = false;
        if(Pager.showDefaultActive){
            sFilterInput = 'Active Recruiting'; 
        }
        else{
            sFilterInput = NONE_SELECTED;   
        }
        sFilteredOpt = 'Status';
        Pager.setDispRows(5);
        Pager.CurrentSet = '1';
        Pager.loadData();
            
        bFilteredSet = false;
        bShowInfoAboutState = false;       
        return null;
    }
    public boolean getShowResults()
    {
        if (RenderResults) return true;
        return false;   
    } 
    public PageReference sortByDistance()     
    {

            msgPage = Pager.RecaltulateDistance(sPatAddressInput);
            if (msgPage.size() == 1)
            {
                msgPageT = msgPage[0];
                System.Debug('XXXXXXXXXXX masgPageT :'+ msgPageT);
            }
            else
            {
                sPatLat = msgPage[0];
                sPatLng = msgPage[1];
                msgPageT = msgPage[2];
            }
            Pager.currSortOrder = 'desc';
                if (msgPageT == 'OK') bShowAlert = false;
                else if (msgPageT == 'ZERO_RESULTS'){ msgPageT = MESSAGE3; bShowAlert = true ;return null;}
                else    {bShowAlert = true; return null;}
            Pager.sortListByDistance('Site_Distance_gne__c');
            Pager.changeDispData();
        return null;
    }
    public PageReference showOnMap()     
    {
         PageReference popPage = new Pagereference('/apex/GNE_TISL_GoogleMapPage');
         popPage.setRedirect(false);
         
         return popPage;
    }  
     public PageReference goBackToSiteInfo()     
    {
         String addTMP = '/apex/GNE_TISL_Site_Information';
         PageReference retAddress = new PageReference(addTMP);
         retAddress.getParameters().put('id',TrialID);
         retAddress.setRedirect(false);
         return retAddress;
    }  
    
    public PageReference sortSiteName() 
    {
        Pager.sortList('Site_Name_gne__c');
        return null;
    }
    
    public PageReference sortSiteStatus() 
    {
        Pager.sortList('Site_Status_gne__c');
        return null;
    }

    public PageReference sortSiteZipCode() 
    {
        Pager.sortList('Site_Zip_Code_gne__c');
        return null;
    }
      
    public PageReference sortSiteCity() 
    {
        Pager.sortList('Site_City_gne__c');
        return null;
    }

    public PageReference sortSiteState() 
    {   
        Pager.sortList('Site_State_gne__c');
        return null;
    }
     
    public PageReference sortSiteCountry() 
    {
        Pager.sortList('Site_Country_gne__c');
        return null;
    } 
    
    public PageReference sortContactName() 
    {   
        Pager.sortList('Site_Contact_Name_gne__c');
        return null;
    }
 
   public PageReference sortContactRole() 
    {
        Pager.sortList('Site_Contact_Role_gne__c');
        return null;
    } 
    public PageReference sortPhone() 
    {   
        Pager.sortList('Site_Contact_Phone_gne__c');
        return null;
    }
    public PageReference sortEmail() 
    {   
        Pager.sortList('Site_Contact_Email_gne__c');
        return null;
    }
    public PageReference sortDistance() 
    {   
        Pager.sortListByDistance('Site_Distance_gne__c');
        return null;
    }
        public PageReference sortSiteAddress() 
    {   
        Pager.sortList('Site_Address_gne__c');
        return null;
    }
    
    public class tempSite
    {
        public double lat;
        public double lng;
        public id Id;
    } 
    
    public PageReference insertToDB() 
    {
        inputData = Apexpages.currentPage().getParameters().get('results');
        List<String> points = inputData.split(';');
        List<string> temp;
        List<tempSite> inputList = new List<tempSite>();
        List<string> idList = new List<string>(); 
        for(string s :points)
        {
            temp = s.split('#',0);
            tempSite t = new tempSite();
            t.lat = double.valueOf(temp[0]);
            t.lng = double.valueOf(temp[1]);
            t.Id = temp[2];
            inputList.add(t);
            idList.add(t.Id);
        }
        List<TISL_Site_gne__c> siteList = [select id, Name, Site_Latitude_gne__c, Site_Longitude_gne__c
                                           from TISL_Site_gne__c 
                                           where id in :idList];
        
        for(tempSite obj :inputList)
        {
            for(TISL_Site_gne__c objSite :siteList)
            {
                if(obj.Id == objSite.Id)
                {
                    objSite.Site_Latitude_gne__c = obj.lat;
                    objSite.Site_Longitude_gne__c = obj.lng;
                }
            }
        }
    
          
        SavePoint savePoint = Database.setSavePoint();
        try
        {
            Database.SaveResult[] res = Database.update(siteList, false);
            for(Database.SaveResult r :res)
            {
                if(!r.isSuccess())
                    Database.rollback(savePoint);
            }
            
            pager.updatelSites(inputList);
        }
        catch(Exception e)
        {
            Database.rollback(savePoint);
        }
        //Database.rollback(savePoint);
        return null;
    }  
}