/*  _____ ___ ___ _      ___ ___  ___     _ ___ ___ _____    */ 
/* |_   _|_ _/ __| |    | _ \ _ \/ _ \ _ | | __/ __|_   _|   */
/*   | |  | |\__ \ |__  |  _/   / (_) | || | _| (__  | |     */
/*   |_| |___|___/____| |_| |_|_\\___/ \__/|___\___| |_|     */


public with sharing class GNE_TISL_Site_Pager extends GNE_Base_Pager{

    private GNE_TISL_Site_Dao dao;  
    transient private Set<String> tmpSiteStates;
    private String tmpAddresses;
    
    public Integer MaxVisibleSets{get;set;}
    public Id TrialId ;
    public String FilteredBy;
    public String CurrentSet{get;set;}
    public String FilteredByLev2;
    public Boolean showInfoAboutEmptyStates;
    public Boolean showDefaultActive;
    public Boolean bFilteredSet;
    public static Integer resultSetSize{get;set;} 
    private static  Integer SET_SIZE ;
        static
         {
            GNE_TISL_Config_Items_gne__c configItem = GNE_TISL_Config_Items_gne__c.getValues('SetSize');
            SET_SIZE = Integer.ValueOf(configItem.Configuration_Value_gne__c);
         }
    public GNE_TISL_Site_Pager()
    {
        IsTestCase = false;
        setup();
    }
    //--- Test Constructor
    public GNE_TISL_Site_Pager(Boolean testVal)
    {       
        IsTestCase = testVal;
        setup();
    }
    
    public List<SelectOption> getSets() {
        List<SelectOption> options = new List<SelectOption>(); 
        for(Integer i=1; i<=MaxVisibleSets; i++) {
           if(dao.dataSetList != null && dao.dataSetList.size() > 0){
           	 options.add(new SelectOption(String.valueOf(i),ordinalNumber(i) + ' ' + dao.dataSetList[i-1]));
           }else{
           	 options.add(new SelectOption(String.valueOf(i),ordinalNumber(i)));
           }
           
        }
        return options; 
    }
    
    public static String ordinalNumber(Integer num){
        String result = '';
        Decimal tmp = math.mod(num, 10);
        if(num >= 10 && num <= 13){
            result = 'th';
        } else if (tmp.format().endsWith('1')) {
            result = 'st';
        } else if (tmp.format().endsWith('2')) {
            result = 'nd';
        } else if (tmp.format().endsWith('3')) {
            result = 'rd';
        } else {
            result = 'th';
        }
        
        return String.valueOf(num)+result;
    }
    
    private void setup()
    {
        dao = new GNE_TISL_Site_Dao(IsTestCase);
        currSort = 'SiteName__c';
        currSortOrder = 'asc';
        MaxVisibleSets = 2;
        CurrentSet = '1';  
        showInfoAboutEmptyStates = false;
        showDefaultActive = false;
    } 
    
    public override List<SObject> getByPager(GNE_Base_Pager pager)
    {
        fullList = dao.getByPager(this);
        if(fullList!=null) 
        resultSetSize = fullList.size();
        
        organizeContactsInSites();
        return fullList;
    }
    
    public Set<String> getStatesOrCountries()
    {
        tmpSiteStates = dao.getStatesOrCountries(this);
        return tmpSiteStates;
        
    }
    public String getAddresses()
    {
        tmpAddresses = dao.getAddresses(this);
        System.Debug('XXXXXXXXXXXX PAGER :' + tmpAddresses); 
        return tmpAddresses;
    }
    
    //---Build the display list
    private List<WrapperTISLSite> dispList;
    transient private List<TISL_Site_gne__c> tmplist;
    transient private List<TISL_Site_gne__c> filteredlist;
    public List<WrapperTISLSite> getDispList()
    {
        return dispList;
    }
    
    public List<String> RecaltulateDistance(String address)
    {
        List<String> tmpArry = new List<String>();
        GNE_TISL_GeoCode.GeocodeResponse gr = GNE_TISL_GeoCode.getCoords(address);
        if (gr.Reqstatus == 'OK')
        {
            tmpArry.add(string.valueof(gr.location_Lat));
            tmpArry.add(string.valueof(gr.location_Lng));
            for (SObject row : fullList)
            {
                TISL_Site_gne__c tmpRow = (TISL_Site_gne__c)row;
                if (tmpRow.Site_Longitude_gne__c != null && tmpRow.Site_Latitude_gne__c != null)
                {
                    Double d1 = tmpRow.Site_Latitude_gne__c;
                    Double d2 = tmpRow.Site_Longitude_gne__c;
                    Double dTmp = GlobalUtils.twoPointsDistance(gr.location_Lat, gr.location_Lng, d1, d2, false); 
                    tmpRow.Site_Distance_gne__c = String.valueof(decimal.valueof(dTmp).setscale(1));
                }
                else
                {
                    tmpRow.Site_Distance_gne__c = 'Location unavailable';
                }
            }
            tmpArry.add(gr.Reqstatus);  
            return tmpArry;
        }
        else
            tmpArry.add(gr.Reqstatus);
        return tmpArry;
    }
    
    public void updatelSites(List<GNE_TISL_Site_Information_Controller.tempSite> tmp) {
        dao.updatelSitesDAO(tmp);
    }
    
    public void sortListByDistance(String sortField) {
        if (fullList != null && fullList.size() > 0)
        {
            String prevSort = CurrSort;
            List<SObject> tmpfullList = new List<SObject>();
            
            //if previous sort was on same field, switch to do opposite sort
            if (prevSort != null && prevSort.equals(sortField))
            {  
                if (currSortOrder == 'asc')
                {
                    currSortOrder = 'desc';
                } else
                {
                    currSortOrder = 'asc';
                }
            }
            else
            {
                currSortOrder = 'asc';
            }
            
            if (!IsTestCase) 
            {
               Map<double ,List<SObject>> mapToSort = new Map<double ,List<SObject>>();
               
               for(sObject tmp :fullList)
               {
                   TISL_Site_gne__c tmp1 = (TISL_Site_gne__c)tmp;
                 if(tmp1.Site_Distance_gne__c != null)
                 {
                       if (pattern.matches('[0-9.]+',tmp1.Site_Distance_gne__c))
                       {
                           if(mapToSort.containsKey(double.valueof(tmp1.Site_Distance_gne__c)))
                           {
                                mapToSort.get(double.valueof(tmp1.Site_Distance_gne__c)).add(tmp1); 
                           }
                           else
                           {
                                List<SObject> sitelist = new List<SObject>();
                                sitelist.add(tmp1);
                                mapToSort.put(double.valueof(tmp1.Site_Distance_gne__c),sitelist);
                           }
                       }
                       else
                       {
                           tmpfullList.add(tmp1);
                       }
                 }  
                 else
                 {
                           tmpfullList.add(tmp1);
                 }
               }
               List<double> keys = new List<double>(mapToSort.keySet());
               keys.sort();
               
               fullList.clear();
                       
                if(currSortOrder.toLowerCase() == 'asc'){
                    for(double t1 : keys)
                    {
                        fullList.addAll(mapToSort.get(t1));
                    }
                    }else if(currSortOrder.toLowerCase() == 'desc'){
                        for(integer i = keys.size()-1; i >= 0; i--){
                            fullList.addAll(mapToSort.get(keys[i]));
                    }
                }
            }
            
            fullList.addAll(tmpfullList);
            CurrSort = sortField;
            setCurrentPage(1);
            changeDispData();
        }
    }
    
    public Boolean isFilterMode() {
        return bFilteredSet && 
        FilteredBy != null && FilteredByLev2 != null && FilteredBy != '' && FilteredByLev2 != ''&& FilteredByLev2 != '--None--';
    }
    
    public override void changeDispData()
    {   
        dispList = new List<WrapperTISLSite>{};
        showInfoAboutEmptyStates = false;

        preparePagination();  
    }

    Map<String, WrapperTISLSite> primaryToWrapperMap = new Map<String, WrapperTISLSite>();

    public void organizeContactsInSites() {
        primaryToWrapperMap = new Map<String, WrapperTISLSite>();
        showInfoAboutEmptyStates = false;
        
        for (sObject sobj : fullList) {
            TISL_Site_gne__c tislSite = (TISL_Site_gne__c) sobj;
            // if map contains similar tislSite, then return wrapper mapped by this tislSite
            WrapperTISLSite wrap = getWrapperFromMapOrNew(primaryToWrapperMap, tislSite);
            wrap.addNewTislSite(tislSite);
        }
        
        // key in map should as primary site mapped by this key
        // primary site contact should be the first according to roles order
        for (WrapperTISLSite wrap : primaryToWrapperMap.values()) {
            // set first site as primary
            wrap.setPrimary();
            // remove first site from otherSites list as it's stored in primarySite
            wrap.otherSites.remove(0);
        }
        
        dispList = new List<WrapperTISLSite>{};
        fullList = collectPrimarySites(primaryToWrapperMap);
        preparePagination();
    }

    private void preparePagination() {
        tmplist = fullList;
        
        setRecordCount(tmplist.size());
        if (tmplist != null && tmplist.size() > 0) {  
            resultSetSize = tmplist.size();
            if (tmplist.size() < pageEndPos) {
                pageEndPos = tmplist.size();
            }
            for (Integer i = pageStartPos; i < pageEndPos + 1; i++) {
                TISL_Site_gne__c tmpSite = (TISL_Site_gne__c) tmplist[i-1];
                WrapperTISLSite tmpWrap = primaryToWrapperMap.get(createKeyFromTislSite(tmpSite));
                dispList.add(tmpWrap);
            }
        }
    }

    private WrapperTISLSite getWrapperFromMapOrNew(Map<String, WrapperTISLSite> primaryToWrapperMap, TISL_Site_gne__c tislSite) {
        String newKey = createKeyFromTislSite(tislSite);
        if (primaryToWrapperMap.containsKey(newKey)) {
            return primaryToWrapperMap.get(newKey);
        } else {
            WrapperTISLSite wrap = new WrapperTISLSite();
            wrap.primarySite = tislSite;
            primaryToWrapperMap.put(newKey, wrap);
            return wrap;
        }
    }

    private String createKeyFromTislSite(TISL_Site_gne__c site1) {
        String key = site1.Site_Name_gne__c;
        key += '_' + site1.Site_Number_gne__c;
        key += '_' + site1.Site_Status_gne__c;
        key += '_' + site1.Site_Address_gne__c;
        key += '_' + site1.Site_City_gne__c; 
        key += '_' + site1.Site_State_gne__c;
        key += '_' + site1.Site_Zip_Code_gne__c;
        key += '_' + site1.Site_Country_gne__c;
        return key;
    }

    private List<TISL_Site_gne__c> collectPrimarySites(Map<String, WrapperTISLSite> primaryToWrapperMap) {
        List<TISL_Site_gne__c> wrapperList = new List<TISL_Site_gne__c>();
        for (WrapperTISLSite wrap : primaryToWrapperMap.values()) {
            wrapperList.add(wrap.primarySite);
        }
        return wrapperList;
    }

    private boolean sitesAreEqual(TISL_Site_gne__c site1, TISL_Site_gne__c site2) {
        return (site1.Site_Name_gne__c == site2.Site_Name_gne__c
                && site1.Site_Number_gne__c == site2.Site_Number_gne__c
                && site1.Site_Status_gne__c == site2.Site_Status_gne__c
                && site1.Site_Address_gne__c == site2.Site_Address_gne__c
                && site1.Site_City_gne__c == site2.Site_City_gne__c
                && site1.Site_State_gne__c == site2.Site_State_gne__c
                && site1.Site_Zip_Code_gne__c == site2.Site_Zip_Code_gne__c
                && site1.Site_Country_gne__c == site2.Site_Country_gne__c);
    }

    private static Map<String, Integer> orderOfContactRoles = new Map<String, Integer>();

    static {
        orderOfContactRoles.put('Screening/Recruitment Contact', 1);
        orderOfContactRoles.put('Study Coordinator', 2);
        orderOfContactRoles.put('Principal Investigator', 3);
        orderOfContactRoles.put('Sub-investigator', 4);
    }

    public class WrapperTISLSite {
        public TISL_Site_gne__c primarySite {get;set;}
        public List<TISL_Site_gne__c> otherSites {get;set;}

        public boolean isPriorThanPrimary(TISL_Site_gne__c one) {
            return isOnePriorThanOther(one, otherSites[0]);
        }

        public boolean isOnePriorThanOther(TISL_Site_gne__c one, TISL_Site_gne__c other) {
            return orderOfContactRoles.get(one.Site_Contact_Role_gne__c) < 
                    orderOfContactRoles.get(other.Site_Contact_Role_gne__c);
        }

        public void setPrimary() {
            primarySite = otherSites[0];
        }

        public WrapperTISLSite() {
            otherSites = new List<TISL_Site_gne__c>();
        }

        public void addNewTislSite(TISL_Site_gne__c newSite) {
            if (otherSites.isEmpty()) {
                otherSites.add(newSite);
            } else {
                boolean added = false;
                for (integer i=0; i<otherSites.size() && !added; ++i) {
                    TISL_Site_gne__c site = otherSites[i];
                    if (isOnePriorThanOther(newSite, site)) {
                        otherSites.add(i, newSite);
                        added = true;
                    }
                }
                if (!added) {
                    otherSites.add(newSite);
                }
            }
        }

        public String getSite_Name_gne() {
            return primarySite.Site_Name_gne__c;
        }
    }
}