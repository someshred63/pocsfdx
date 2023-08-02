public class CHV_ViewBrand
{

    public List<SelectOption> business_unit_options {get; set;}
    public String selected_business_unit {get; set;}

    Map <String, CHV_Brand__c> id_brand_map = new Map <String, CHV_Brand__c>();
    public List<SelectOption> brand_options {get; set;}
    public String selected_brand {get; set;}
    public String distribution_model_url {get; private set;}

    Map <String, CHV_Customer_Access__c> id_customer_access_type_map = new Map <String, CHV_Customer_Access__c>();
    public List<SelectOption> customer_access_type_options {get; set;}
    public String selected_customer_access_type {get; set;}
    public Boolean customer_access_type_disabled {get; private set;}
    public String customer_access_name {get; private set;}
    public String customer_access_header {get; private set;}
    
    // Brand customer access
    public CHV_Brand_Customer_Access__c brand_customer_access {get; private set;}
    
    // Authorized_Distributor_Note__c
    Map <String, List <CHV_Brand_Customer_Access_Distributor__c>> adId_bcadList_map = new Map <String, List <CHV_Brand_Customer_Access_Distributor__c>>();
    public List <CHV_Brand_Customer_Access_Distributor__c> distributor_notes_list {get; private set;}
    public Boolean distributor_notes_rendered {get; private set;}

    // wrapper class for taking points
    public class TalkingPoint
    {
        public String revision {get; set;}
        public String content {get; set;}
    }
    public List <TalkingPoint> talking_point_list {get; set;}
    
    public List <CHV_Authorized_Distributor__c> authorized_distributor_list {get; set;}
    Map <String, CHV_Authorized_Distributor__c> id_authorized_distributor_map = new Map <String, CHV_Authorized_Distributor__c>();
    public CHV_Authorized_Distributor__c authorized_distributor {get; private set;} 
    public String selected_authorized_distributor {get; set;}
    public Boolean authorized_distributor_rendered {get; private set;}
    
    public CHV_Account_Manager__c account_manager {get; private set;}
    
    public DateTime last_login_date {get; private set;}
    
    // distribution model tab
    public CHV_Generic_Data__c generic_data {get; private set;}
    
    // security
    public set <String> user_type_set = new set <String>();
    public Boolean account_manager_rendered {get; private set;}
    public Boolean notes_header_rendered {get; private set;}
    
    
    // constructor
    public CHV_ViewBrand()
    {
        // init
        customer_access_type_disabled = true;
        authorized_distributor_rendered = false;
        account_manager_rendered = false;
        distributor_notes_rendered = false;
        notes_header_rendered = true;
        
        // load initial picklists
        loadUserDetail();
        loadBusinessUnit();
        loadBrand();
        loadCustomerAccessType();
        loadGenericData();
        
        
    }

    void loadUserDetail()
    {
        List <User> uList = [select Id, Name, LastLoginDate from User where Id = :UserInfo.getUserId()];
        if (uList.size() > 0)
        {
            last_login_date = uList[0].LastLoginDate;
        }
        
        // Implement User Security (ViewAll, ViewLimited)
        // get groups where user is directly member. 
        // currently indirect group members, roles, subordinates are not supported
        
        //new logic (compliant with webservice and iOS logic)
        String userAccessLevel = null;
        
        try {
                userAccessLevel = CHV_Utils.getUserAccessLevel();
        }
        catch (Exception e) {
                user_type_set.add('VIEW_LIMITED');
        }
        
        if (!String.isBlank(userAccessLevel)) {
                if (userAccessLevel.equals('viewAllContent')) {
                        user_type_set.add('VIEW_ALL');
                }
                else {
                        user_type_set.add('VIEW_LIMITED');
                }
        }
        else {
                user_type_set.add('VIEW_LIMITED');
        }
        
        //old logic
        /**
        List <Group> grpList = [select Id, Name from Group where Id in
            (select GroupId from GroupMember where UserOrGroupId = :UserInfo.getUserId())];
        for (Group grp : grpList)
        {
            if (grp.Name == 'CHV_View_All_Group' || grp.Name == 'CHV_Super_User_Group')
            {
                user_type_set.add('VIEW_ALL');
            }
            else if (grp.Name == 'CHV_View_Limited_Group')
            {
                user_type_set.add('VIEW_LIMITED');
            }
        }            
        */
        
        account_manager_rendered = false;
        if (user_type_set.contains('VIEW_ALL') == true)
        {
            account_manager_rendered = true;
        }    
    }

    void loadBusinessUnit()
    {
        business_unit_options = new List<SelectOption>();
        business_unit_options.add(new SelectOption('0', 'All Business Units'));
        List <CHV_Business_Unit__c> buList = [select Id, Name from CHV_Business_Unit__c];
        
        // sort business unit
        Map <String, LIst <CHV_Business_Unit__c>> buName_buList_map = new Map <String, List <CHV_Business_Unit__c>>();
        
        for (CHV_Business_Unit__c bu : buList)
        {
            String buName = bu.Name.toUpperCase();
            List <CHV_Business_Unit__c> bul;
            if (buName_buList_map.containsKey(buName))
            {
                bul = buName_buList_map.get(buName);
            }
            else
            {
                bul = new List <CHV_Business_Unit__c>();
            }
            bul.add(bu);
            buName_buList_map.put(buName, bul);
        }    
        List <String> buName_list = new List <String>(buName_buList_map.keySet());
        buName_list.sort();
        
        for (String buName : buName_list)
        {
            if (buName_buList_map.containsKey(buName))
            {
                List <CHV_Business_Unit__c> bul = buName_buList_map.get(buName);
                for (CHV_Business_Unit__c bu : bul)
                {
                    business_unit_options.add(new SelectOption(bu.Id, bu.Name));
                }
            }
        }    
    }
    void loadBrand()
    {
        brand_options = new List<SelectOption>();
        brand_options.add(new SelectOption('0', '-- Select --'));
        List <CHV_Brand__c> brandList;
        if (selected_business_unit == '0' || selected_business_unit == null)
        {
            brandList = [select Id, Name,
                Business_Unit__c,
                Business_Unit__r.Name, 
                Distribution_Model_Diagram_URL__c 
                from CHV_Brand__c
                order by Business_Unit__r.Name, Name
                ];    // load all
                
            Map <Id, List <CHV_Brand__c>> buId_brList_map = new Map <Id, List <CHV_Brand__c>>();
            Map <Id, String> buId_buName_map = new Map <Id, String>();
            Map <String, Set <Id>> buName_buIdSet_map = new Map <String, Set <Id>>();

            for (CHV_Brand__c brand : brandList)
            {
                String buName = brand.Business_Unit__r.Name.toUpperCase();
                Set <Id> buIdSet;
                List <CHV_Brand__c> brList;
                if (buName_buIdSet_map.containsKey(buName))
                {
                    buIdSet = buName_buIdSet_map.get(buName);
                }
                else
                {
                    buIdSet = new Set <Id>();
                }
                buIdSet.add(brand.Business_Unit__c);
                buName_buIdSet_map.put(buName, buIdSet);
                buId_buName_map.put(brand.Business_Unit__c, brand.Business_Unit__r.Name);
                
                if (buId_brList_map.containsKey(brand.Business_Unit__c))
                {
                    brList = buId_brList_map.get(brand.Business_Unit__c);
                }
                else
                {
                    brList = new List <CHV_Brand__c>();
                }
                brList.add(brand);
                buId_brList_map.put(brand.Business_Unit__c, brList);
            }
            
            // sort business unit and then inside it brand
            List <String> buNameList = new List <String>(buName_buIdSet_map.keySet());
            buNameList.sort();
            for (String buName : buNameList)
            {
                Set <Id> buIdSet = buName_buIdSet_map.get(buName);
                for (Id buId : buIdSet)
                {
                    brand_options.add(new SelectOption(buId, buId_buName_map.get(buId), true));    // disabled
                    List <CHV_Brand__c> brList = buId_brList_map.get(buId);
                    
                    // sort brand
                    Map <String, List <CHV_Brand__c>> brName_brList_map = new Map <String, List <CHV_Brand__c>>();
                    
                    for (CHV_Brand__c br : brList)
                    {
                        String brName = br.Name.toUpperCase();
                        List <CHV_Brand__c> brl;
                        if (brName_brList_map.containsKey(brName))
                        {
                            brl = brName_brList_map.get(brName);    
                        }
                        else
                        {
                            brl = new List <CHV_Brand__c>();
                        }
                        brl.add(br);
                        brName_brList_map.put(brName, brl);
                    }
                    
                    // sort brand
                    List <String> brnList = new List <String>(brName_brList_map.keySet());
                    brnList.sort();
                    for (String brn : brnList)
                    {
                        List <CHV_Brand__c> brl = brName_brList_map.get(brn);
                        for (CHV_Brand__c br : brl)
                        {
                            brand_options.add(new SelectOption(br.Id, '--' + br.Name));
                            id_brand_map.put(br.Id, br);                            
                        }
                    }
                }
            }
                           
        }
        else
        {
            brandList = [select Id, Name,
                Distribution_Model_Diagram_URL__c 
                from CHV_Brand__c where Business_Unit__c = :selected_business_unit];

            // sort brand
            Map <String, List <CHV_Brand__c>> brandName_brandList_map = new Map <String, List <CHV_Brand__c>>();
            List <String> brandName_list = new List <String>();
            
            for (CHV_Brand__c brand : brandList)
            {
                String brandName = brand.Name.toUpperCase();
                List <CHV_Brand__c> brList;
                if (brandName_brandList_map.containsKey(brandName))
                {
                    brList = brandName_brandList_map.get(brandName);
                }
                else
                {
                    brList = new List <CHV_Brand__c>();
                }
                brList.add(brand);
                brandName_brandList_map.put(brandName, brList);
                
                brandName_list.add(brandName);    
            }    
            brandName_list.sort();
    
            for (String brandName : brandName_list)
            {
                if (brandName_brandList_map.containsKey(brandName))
                {
                    List <CHV_Brand__c> brList = brandName_brandList_map.get(brandName);
                    for (CHV_Brand__c brand : brList)
                    {
                        brand_options.add(new SelectOption(brand.Id, brand.Name));
                        id_brand_map.put(brand.Id, brand);
                    }
                }
            } 
    
        }

        
        loadCustomerAccessType();
    }
    void loadCustomerAccessType()
    {
        customer_access_type_options = new List<SelectOption>();
        List <CHV_Customer_Access__c> catList = [select Id, Name, Notes__c 
            from CHV_Customer_Access__c
            where Id in (select Customer_Access__c from CHV_Brand_Customer_Access__c 
                where Brand__c = :selected_brand) 
            ];

        // New Enhancement. 9/19/2012
        // If there are no CAT for a Brand, keep the CAT dropdown disabled and donot display 
        // anything in the CAT's sesction below
        if (catList.size() > 0)
        {
            customer_access_type_options.add(new SelectOption('0', '-- Select --'));
            // reset selection
            selected_customer_access_type = '0';
            customer_access_type_disabled = false;
        }
        else
        {
            customer_access_type_options.add(new SelectOption('-1', '-- No Values --'));
            // reset selection
            selected_customer_access_type = '-1';
            customer_access_type_disabled = true;
        }    
        // sort customer access type
        Map <String, CHV_Customer_Access__c> catName_cat_map = new Map <String, CHV_Customer_Access__c>();
        List <String> catName_list = new List <String>();
        
        for (CHV_Customer_Access__c cat : catList)
        {
            String key = cat.Name.toUpperCase() + '_' + cat.Id;    // make it unique by adding id.
            catName_list.add(key);    
            catName_cat_map.put(key, cat);
        }    
        catName_list.sort();

        for (String key : catName_list)
        {
            if (catName_cat_map.containsKey(key))
            {
                CHV_Customer_Access__c cat = catName_cat_map.get(key);
                customer_access_type_options.add(new SelectOption(cat.Id, cat.Name));
                id_customer_access_type_map.put(cat.Id, cat);
            }
        }
        
        loadAuthorizedDistributor();
        loadBrandCustomerAccessNotes();
    }

    void loadAuthorizedDistributor()
    {
    
        List <CHV_Authorized_Distributor__c> adList = new List <CHV_Authorized_Distributor__c>();
        
        if (selected_brand != '0' &&
            selected_customer_access_type != '0')
        {    
            adList = [select Id, Name,
                Account_Manager__c,
                Corporate_Fax__c,
                Corporate_Phone__c,
                Corporate_URL__c,
                LastModifiedDate,
                (select Id, Name, 
                    Brand_Customer_Access__r.Customer_Access__c,
                    Brand_Customer_Access__r.Brand__c,
                    Authorized_Distributor__c,
                    Authorized_Distributor_Note__c 
                    from Brand_Customer_Access_Distributors__r
                    where
                    Brand_Customer_Access__r.Brand__c = :selected_brand and
                    Brand_Customer_Access__r.Customer_Access__c = :selected_customer_access_type
                    )
            
                from CHV_Authorized_Distributor__c
                where
                Id in (select Authorized_Distributor__c from CHV_Brand_Customer_Access_Distributor__c
                    where 
                    Brand_Customer_Access__r.Brand__c = :selected_brand and
                    Brand_Customer_Access__r.Customer_Access__c = :selected_customer_access_type)];    
        
        }
        
        // sort
        Map <String, List <CHV_Authorized_Distributor__c>> name_adList_map = new Map <String, List <CHV_Authorized_Distributor__c>>();
        for (CHV_Authorized_Distributor__c ad : adList)
        {
            String adName = ad.Name.toUpperCase();
            List <CHV_Authorized_Distributor__c> adl;
            if (name_adList_map.containsKey(adName))
            {
                adl = name_adList_map.get(adName);
            }
            else
            {
                adl = new List <CHV_Authorized_Distributor__c>();
            }
            adl.add(ad);
            name_adList_map.put(adName, adl);
        }           
        
        List <String> adNameList = new List <String>(name_adList_map.keySet());
        adNameList.sort();
        
        authorized_distributor_list = new List <CHV_Authorized_Distributor__c>();
        
        for (String adName : adNameList)
        {
            if (name_adList_map.containsKey(adName))
            {
                List <CHV_Authorized_Distributor__c> adl = name_adList_map.get(adName);
                for (CHV_Authorized_Distributor__c ad : adl)
                {
                    authorized_distributor_list.add(ad);
                    id_authorized_distributor_map.put(ad.Id, ad);
                    
                    // Authorized_Distributor_Note__c
                    List <CHV_Brand_Customer_Access_Distributor__c> bcadList = ad.Brand_Customer_Access_Distributors__r;
                    adId_bcadList_map.put(ad.Id, bcadList);
                }
            }
        }
        
        // set first record selected
        if (authorized_distributor_list.size() > 0)
        {
            authorized_distributor_rendered = true;
            selected_authorized_distributor = authorized_distributor_list[0].Id;
        }
        else
        {
            selected_authorized_distributor = '0';
        }
        
        notes_header_rendered = true;
        if (selected_customer_access_type == '0' || selected_customer_access_type == '-1'  || selected_customer_access_type == null)
        {
            customer_access_header = ' Can Purchase From';
        }
        else if (authorized_distributor_list.size() > 0)
        {
            customer_access_header = customer_access_name + ' Can Purchase From';
        }
        else
        {
            customer_access_header = 'Notes for ' + customer_access_name;
            notes_header_rendered = false;
        }
        
        // refresh detail
        onSelectAuthorizedDistributor();
    }
    
    void loadBrandCustomerAccessNotes()
    {
        brand_customer_access = new CHV_Brand_Customer_Access__c();
        List<CHV_Brand_Customer_Access__c> bcaList = [select Id, Name, Notes__c
                from CHV_Brand_Customer_Access__c
                where Brand__c = :selected_brand
                and Customer_Access__c = :selected_customer_access_type];
        System.debug('Selected brand: '+selected_brand);
        System.debug('Selected customer access type: '+selected_customer_access_type);
        if(!bcaList.isEmpty())
        {
            brand_customer_access = bcaList[0];
            System.debug('Notes: '+brand_customer_access.Notes__c);
        }
    }
    
    void loadAccountManager()
    {
        account_manager = new CHV_Account_Manager__c();
        if (authorized_distributor != null && authorized_distributor.Account_Manager__c != null)
        {
            List <CHV_Account_Manager__c> amList = [select Id, Name,
                Cell_Phone__c,
                Desk_Phone__c,
                Email_ID__c,
                Photo__c,
                Photo_URL__c
            
                from CHV_Account_Manager__c
                where Id = :authorized_distributor.Account_Manager__c]; 
            
            if (amList.size() > 0)
            {
                account_manager = amList[0];
            }
        }
    }
    
    void loadDistributorNotes()
    {
        if (distributor_notes_list == null)
        {
            distributor_notes_list = new List <CHV_Brand_Customer_Access_Distributor__c>();
        }
        else
        {
            distributor_notes_list.clear();
        }
        
        if (adId_bcadList_map.containsKey(selected_authorized_distributor))
        {
        
            List <CHV_Brand_Customer_Access_Distributor__c> bcadList = adId_bcadList_map.get(selected_authorized_distributor);
            for (CHV_Brand_Customer_Access_Distributor__c bcad : bcadList)
            {
                if (bcad.Brand_Customer_Access__r.Customer_Access__c == selected_customer_access_type &&
                    bcad.Brand_Customer_Access__r.Brand__c == selected_brand &&
                    bcad.Authorized_Distributor__c == selected_authorized_distributor &&
                    bcad.Authorized_Distributor_Note__c != null)
                {
                    distributor_notes_list.add(bcad);
                }
            }

        }                
                
        // If there are no distributors then display it from customer access type Notes
        if (distributor_notes_list.size() == 0)
        {
            if (id_customer_access_type_map.containsKey(selected_customer_access_type))
            {
                CHV_Customer_Access__c cvt = id_customer_access_type_map.get(selected_customer_access_type);
                if (cvt.Notes__c != null)
                {
                    CHV_Brand_Customer_Access_Distributor__c bcad = new CHV_Brand_Customer_Access_Distributor__c();
                    bcad.Authorized_Distributor_Note__c = cvt.Notes__c;
                    distributor_notes_list.add(bcad);
                }
            }
        }
        
        // remove Note box if empty
        distributor_notes_rendered = false;
        if (distributor_notes_list.size() > 0)
        {
            distributor_notes_rendered = true;
        }
    }
    
    public PageReference onSelectBrand()
    {
        trackDesktopUsage();
        loadCustomerAccessType();
        if (selected_brand == '0' || selected_brand == null)
        {
            customer_access_type_disabled = true;
            authorized_distributor_rendered = false;
            selected_customer_access_type = '0';
            customer_access_name = null;
            distribution_model_url = null;
            talking_point_list.clear();
        }
        else
        { 
            // get distribution model url
            if (id_brand_map.containsKey(selected_brand))
            {
                distribution_model_url = id_brand_map.get(selected_brand).Distribution_Model_Diagram_URL__c;
            }
            
            // get talking points
            talking_point_list = new List <TalkingPoint>();
            
            List <CHV_Talking_Point__c> tpList = [select Id, Name,
                LastModifiedDate,
                Content__c
                from CHV_Talking_Point__c
                where Brand__c = :selected_brand
                order by LastModifiedDate desc];
            for (CHV_Talking_Point__c tp : tpList)
            {
                TalkingPoint tpc = new TalkingPoint();
                tpc.revision = tp.LastModifiedDate.format('dd MMM yyyy');
                tpc.content = tp.Content__c;
                talking_point_list.add(tpc);
            }    
    
        } 
        
        // clear authorized distributor section
        if (authorized_distributor_list != null)
        {
            authorized_distributor_list.clear();
        }
        selected_authorized_distributor = '0';
        authorized_distributor = new CHV_Authorized_Distributor__c();
        account_manager = new CHV_Account_Manager__c();
        
        if (distributor_notes_list != null)
        {
            distributor_notes_list.clear();
        }
          
        // finally hide
        authorized_distributor_rendered = false;
        customer_access_name = null;
               
        return null;
    }
    public PageReference onSelectBusinessUnit()
    {
        trackDesktopUsage();
    
        loadBrand(); 
        
        selected_brand = '0';
        
        loadCustomerAccessType();
          
        customer_access_type_disabled = true;
        customer_access_name = null;
        distribution_model_url = null;
        if (talking_point_list != null)
        {
            talking_point_list.clear();
        }
        
        if (authorized_distributor_list != null)
        {
            authorized_distributor_list.clear();
        }
        selected_authorized_distributor = '0';
        authorized_distributor = new CHV_Authorized_Distributor__c();
        account_manager = new CHV_Account_Manager__c();
        
        loadDistributorNotes();
                      
        // finally hide
        authorized_distributor_rendered = false;
          
        return null;    
    }    
    public PageReference onSelectCustomerAccessType()
    {
        trackDesktopUsage();
        authorized_distributor_rendered = false;

        if (selected_customer_access_type == '0' || selected_customer_access_type == null)
        {
            customer_access_name = null; 
        }
        else if (id_customer_access_type_map.containsKey(selected_customer_access_type))
        {
            customer_access_name = id_customer_access_type_map.get(selected_customer_access_type).Name;
        }
          
        loadAuthorizedDistributor();
        loadBrandCustomerAccessNotes();
          
        return null;    
    }    

    public PageReference onSelectAuthorizedDistributor()
    {
        
        // get selected distributer record
        authorized_distributor = new CHV_Authorized_Distributor__c();
        if (id_authorized_distributor_map.containsKey(selected_authorized_distributor))
        {
            authorized_distributor = id_authorized_distributor_map.get(selected_authorized_distributor);
        }    
        
        // load account manager
        loadAccountManager();
        
        // load notes
        loadDistributorNotes();
        
        return null;    
    }

    public void loadGenericData()
    {
        generic_data = new CHV_Generic_Data__c();    
        List <CHV_Generic_Data__c> gdList = [select Id, Name, 
            Generic_Distribution_Model_Description__c,
            Generic_Distribution_Model_Diagram_URL__c
            from CHV_Generic_Data__c limit 1];
        if (gdList.size() > 0)
        {
            generic_data = gdList[0];
        }    
    }
    
    //Jie add on 4/4/2023 for tracking desktop usage
    public void trackDesktopUsage(){
        Log_App_Usage logUsage=new Log_App_Usage('CHV',UserInfo.getUserId());
        logUsage.logUserUsage();
    
    }
        
}