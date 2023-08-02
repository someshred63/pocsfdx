public without sharing class GNE_CreateReferral 
{
  
  /* 
    This class is used for creating a Referral.
    Referral is a Medical Communication request to an MSL. The Referral is identified as a Medical communication  request with a recordType Referral.
    
    Author : Sweta Khalasi
    Created : 01 Jul 2011
    Last Modified : 24 Aug 2011
    Project : gMARS Phase 2  
  */
  
  Account account;
  User currentUser = null;
  string strMolecule='Molecule';
  string strDetail='Detail';
  string strTheraDisease='TheraDisease';
  string strBrand='Brand';
  string strApprovedProductIndications='Approved Product Indications';
  String strAssigned = 'Assigned';
  Boolean blnIsValid = true;
  String strErrorMsg=null;
  Boolean isCreateAllowed = true;
  Boolean disableInput = false;
  //String AssignmentType= '';
  public String AssignmentType { get; set; }
  public String SearchFld { get; set; }
  public Id SearchId { get; set; }
  
  public String SearchFld1 { get; set; }
  public Id SearchId1 { get; set; }
  
  public void disableCloseDateInput(){
    System.debug('Inside disableCloseDateInput --> ');
    //objReferralAssignmentProxy.Assigned_To_gne__c = null;
    objReferralAssignmentProxy = new Referral_Assignment_gne__c();
    SearchFld='';
    SearchId=null;
    disableInput = true;
  }
  public void enableCloseDateInput(){
    System.debug('Inside enableCloseDateInput --> ');
    //objReferralAssignmentProxy.Assigned_To_gne__c = null;
    objReferralAssignmentProxy = new Referral_Assignment_gne__c();
    SearchFld='';
    SearchId=null;
    disableInput = false;
  }
  
  public boolean getdisableInput(){
    System.debug('Inside getdisableInput --> ');
      return disableInput;
    }
    
    
  public List<SelectOption> getMyAssType() {
    
    //AssignmentType = 'Manual Assignment';
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('Manual Assignment','Manual Assignment'));
    options.add(new SelectOption('Auto Assignment','Auto Assignment')); 
    
    return options;
  }
  //action functions
  public void assType()
    {
      System.debug('Inside assType --> ');
      System.debug('AssignmentType: ' + AssignmentType);
      if(AssignmentType == 'Manual Assignment'){
        enableCloseDateInput();
      }
      if(AssignmentType == 'Auto Assignment'){
        disableCloseDateInput();
      }     
      
    }
    /*
    public String getAssignmentType() {
        return AssignmentType;
    }
    */
    
  List<Address_vod__c> lstAddress;
  Map<Id,Address_vod__c> mapAddressId = new Map<Id,Address_vod__c> ();
  List<Product_vod__c> lstAllProducts;
  List<String> lstMedAffairsMoleculeNames = new List<String> ();
  List<Product_vod__c> lstProducts = new List<Product_vod__c> ();
  Map<Id,Product_vod__c> mapTA_SubTAId = new Map<Id,Product_vod__c> ();
  Map<Id,Product_vod__c> mapMoleculeId = new Map<Id,Product_vod__c> ();
  Map<Id,Id> mapProductToTASubTA = new Map<Id,Id> ();
  List<string> lstFollowupMethod = new List<string> ();
  List<string> lstPriority = new List<string> ();
  List<Schema.SObjectField> fTokens = new List<Schema.SObjectField>();
  List<Id> ProductOwnerQueueId = new List<Id> ();
  Schema.SObjectType schemaSObject=null;
  Map<String, Schema.SObjectField> fMap = new Map<String, Schema.SObjectField>();
  RecordType referralRecordType;
  Address_vod__c selectedAddress;
  List<Id> lstdefautTASubTAs=new List<Id>();
  List<Id> lstdefautMolecules=new List<Id>();
  public Id selectedAddressId{get; set;}  
  public Id selectedProductId{get; set;}  
  public Id selectedMoleculeId{get; set;}
  public Id selectedTA_SubTA{get; set;}
  public String question{get; set;}
  
  Medical_Communication_gne__c objReferralProxy;
  Referral_Assignment_gne__c objReferralAssignmentProxy;
  
  public Medical_Communication_gne__c getReferralProxyObject()
  {
    return objReferralProxy;
  }
  public boolean isMedComm   { get; set; }
  public boolean disable    { get; set; }
  public void doDisable() {
    System.debug('Inside doDisable:');
    System.debug('isMedComm :' + isMedComm);
    //disable =objReferralProxy.Is_MedComm_gne__c;
    /*if(objReferralProxy.Is_MedComm_gne__c)
        disable = true;  
    if(!objReferralProxy.Is_MedComm_gne__c)
        disable = false;
    */
    objReferralProxy.Requested_By_gne__c = null;
    SearchFld1='';
    SearchId1=null;
    if(isMedComm == true) disable = true;  
    if(isMedComm == false) disable = false; 
  } 
  public Referral_Assignment_gne__c getReferralAssignmentProxyObject()
  {
    return objReferralAssignmentProxy;
  }
  
  public String errMessage{get; set;}
  public GNE_CreateReferral()
  {
    
  }
  //Requested By field is editable by MedAffair profile user only as they can raise referra on behalf of MCCO users.
  public boolean getIsMCLUser(){
      if (currentUser !=null && currentUser.Profile_Name_gne__c.contains(GNE_Referral_Utils.MedAffairProfile) && (!currentUser.Profile_Name_gne__c.contains(GNE_Referral_Utils.TISLProfile)))
        return true;
      else
        return false;
    }
    public boolean getIsCreateAllowed(){
      return isCreateAllowed;
    }
  
  public GNE_CreateReferral(ApexPages.StandardController controller)
  {
    //disableInput = false;
    AssignmentType = 'Manual Assignment';
    enableCloseDateInput();
    currentUser=[select Profile_Name_gne__c from User where Id = :UserInfo.getUserId() limit 1];
    System.debug('UserInfo.getUserId(): --> ' + UserInfo.getUserId());
    System.debug('currentUser.Profile_Name_gne__c: --> ' + currentUser.Profile_Name_gne__c);
    isCreateAllowed = GNE_Referral_Utils.isCreateReferralAllowed(currentUser);
    
    List<String> ProductOwnerQueueName = new List<String> ();
    ProductOwnerQueueName.add(System.Label.GNE_SFA_Canada_Queue);
    ProductOwnerQueueName.add('GNE-INACTIVE-PROD-QUEUE');
    //GneSFACanadaQueueId = GNE_Referral_Utils.getMSLQueueId(System.Label.GNE_SFA_Canada_Queue);
    ProductOwnerQueueId = GNE_Referral_Utils.getProductOwnerQueueId(ProductOwnerQueueName);
    System.debug('ProductOwnerQueueId: --> ' + ProductOwnerQueueId);
    //Referral will be created by SFA, MedAffair, ATLS and system admin profile only.
    if(isCreateAllowed){    
        //get Referral recordTypeId
        referralRecordType = GNE_Referral_Utils.getReferralRecordType();
        
        //intantiate proxy object
        objReferralProxy = new Medical_Communication_gne__c(RecordTypeId = referralRecordType.id);
        objReferralAssignmentProxy = new Referral_Assignment_gne__c();
        
        System.debug('System.URL.getSalesforceBaseUrl().toExternalForm(): ' + System.URL.getSalesforceBaseUrl().toExternalForm());
        System.debug('getUrl: ' + ApexPages.currentPage().getUrl());
        System.debug('serverURL: ' + GNE_Referral_Utils.serverURL);
        
        account = [Select Id, Name, FirstName, LastName, MDMID_gne__c,  PersonEmail, (Select Account_vod__c, Active_Flag_gne__c, Address_1_gne__c, Address_line_2_vod__c, Address_Line_3_gne__c, Address_Line_4_gne__c, Address_Type_gne__c, City_vod__c, Country_gen__c, Email_gne__c, Fax_2_vod__c, Fax_vod__c, Id, Inactive_vod__c, License_Status_vod__c, License_vod__c, Name, Phone_1_Ext_gne__c, Phone_2_Ext_gne__c, Phone_2_vod__c, Phone_vod__c, State_vod__c, Zip_4_vod__c, Zip_vod__c From Address_vod__r where Inactive_vod__c=false), IsPersonAccount,Secondary_Email_gne__c from Account where id = :ApexPages.currentPage().getParameters().get('AccId')];    
        if(account!=null)
        {
          //asssign address
          lstAddress = account.address_vod__r;
          if(lstAddress != null && lstAddress.size()>0)
            {
              for(Address_vod__c ad: lstAddress)
              {
                if(account.PersonEmail != null)
                    {ad.Email_gne__c = account.PersonEmail;}
                else if(account.Secondary_Email_gne__c != null)
                    {ad.Email_gne__c = account.Secondary_Email_gne__c;}
                else{}
                
                if((String)ad.Fax_vod__c != null)
                {
                    //do nothing
                }else{
                    if((String)ad.Fax_2_vod__c != null)
                    {
                        ad.Fax_vod__c=ad.Fax_2_vod__c;
                    }
                }
                mapAddressId.put(ad.Id,ad);         
              }
            }
        }
        lstMedAffairsMoleculeNames = GNE_Referral_Utils.getRestrictedProductName();
        System.debug('ProductOwnerQueueId: ' +ProductOwnerQueueId);
        if(ProductOwnerQueueId != null && ProductOwnerQueueId.size() >0){
            lstAllProducts = [Select Id, Name,Detail_Product_Subtype_Code_gne__c,TheraDisease_Reference_gne__c,OwnerId,Product_Type_vod__c, Therapeutic_Area_vod__c from Product_vod__c where Name not IN :lstMedAffairsMoleculeNames and OwnerId not In : ProductOwnerQueueId order by name];
        }else{
            lstAllProducts = [Select Id, Name,Detail_Product_Subtype_Code_gne__c,TheraDisease_Reference_gne__c,OwnerId,Product_Type_vod__c, Therapeutic_Area_vod__c from Product_vod__c where Name not IN :lstMedAffairsMoleculeNames order by name];     
        }
        if(lstAllProducts!=null && lstAllProducts.size()>0)
            {
            System.debug('%%%%%%%%lstAllProducts.size(): ' + lstAllProducts.size());
              for(Product_vod__c prod: lstAllProducts  )
              {
                if(prod.Product_Type_vod__c!=null && prod.Detail_Product_Subtype_Code_gne__c!= null && prod.Product_Type_vod__c==strDetail && prod.Detail_Product_Subtype_Code_gne__c!= strTheraDisease && (prod.Detail_Product_Subtype_Code_gne__c == strBrand || prod.Detail_Product_Subtype_Code_gne__c == strApprovedProductIndications) ){
                //if(prod.Product_Type_vod__c!=null && prod.Detail_Product_Subtype_Code_gne__c!= null && prod.Product_Type_vod__c==strDetail && prod.Detail_Product_Subtype_Code_gne__c!= strTheraDisease){
                    lstProducts.add(prod);
                    if(prod.TheraDisease_Reference_gne__c != null)
                        mapProductToTASubTA.put(prod.Id,prod.TheraDisease_Reference_gne__c);                    
                }
                if(prod.Product_Type_vod__c!=null && prod.Detail_Product_Subtype_Code_gne__c!= null && prod.Product_Type_vod__c==strDetail && prod.Detail_Product_Subtype_Code_gne__c== strTheraDisease){
                    mapTA_SubTAId.put(prod.Id,prod);
                }
                if(prod.Detail_Product_Subtype_Code_gne__c!= null && prod.Detail_Product_Subtype_Code_gne__c==strMolecule){
                    mapMoleculeId.put(prod.Id,prod);                    
                }           
              }
            }
        
         System.debug('mapProductToTASubTA.size(): --> ' + mapProductToTASubTA.size());   
        errMessage='hello';
    }
    else{
        System.debug('Create Referral not allowed.');
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You do not have the level of access necessary to perform the operation you requested. Please contact the owner of the record or your administrator if access is necessary.'));
    }
  }
  
  public Account getAccountInfo()
  {
    return account;
  }
  
  public List<SelectOption> getAddressList() 
    {               
        List<SelectOption> options=new List<SelectOption>();
            options.add(new SelectOption('', '--None--'));
                
            if(lstAddress!=null && lstAddress.size()>0)
        {
          for(Address_vod__c ad: lstAddress  )
          {
            options.add(new SelectOption(ad.Id, ad.Name));    
          }
        }
        return options;
    }
    public List<Product_vod__c> getSortedList(Map<Id,Product_vod__c> mapProdId)
    {   
        System.debug('inside getSortedList: ');
        System.debug('mapProdId.size(): --> ' + mapProdId.size());
        Map<String,Product_vod__c> map3TA_SubTAId = new Map<String,Product_vod__c> ();
        Map<String,Product_vod__c> map4TA_SubTAId = new Map<String,Product_vod__c> ();
        List<String> lst1TA_SubTA = new List<String> ();
        List<Product_vod__c> lstTA_SubTA = new List<Product_vod__c> ();
        List<Product_vod__c> lstTA_SubTAFinal = new List<Product_vod__c> ();
        
        lstTA_SubTA = mapProdId.values();
        String tempId=null;
        if(lstTA_SubTA!=null && lstTA_SubTA.size()>0)
        {
          for(Product_vod__c prod: lstTA_SubTA)
          {
            lst1TA_SubTA.add(prod.Name + '-' + (String)prod.Id);
            map4TA_SubTAId.put((String)prod.Id,prod);
          }
          System.debug('map4TA_SubTAId.size(): --> ' + map4TA_SubTAId.size());
          lst1TA_SubTA.sort();
          for(String strProd: lst1TA_SubTA)
          {
            if(strProd.lastIndexOf('-') !=-1)
                tempId=strProd.substring(strProd.lastIndexOf('-')+1).trim();
            System.debug('tempId: --> ' + tempId);
            if(map4TA_SubTAId != null && map4TA_SubTAId.size() >0 && map4TA_SubTAId.containsKey(tempId)){
                lstTA_SubTAFinal.add(map4TA_SubTAId.get(tempId));
            }
            tempId = null;
          }
        }
        System.debug('lstTA_SubTAFinal.size(): --> ' + lstTA_SubTAFinal.size());
        return lstTA_SubTAFinal;
    }
    /*
    public void loadDefautTA_SubTA()
    {
      System.debug('inside loadDefautTA_SubTA: ');
      System.debug('selectedProductId: --> ' + selectedProductId);
      List<Product_To_TASubTA_gne__c> lstProdToTASubTAs=new List<Product_To_TASubTA_gne__c>();
      Product_To_TASubTA_gne__c objProdToTASubTa = null;
      
      If (lstdefautTASubTAs != null && lstdefautTASubTAs.size() >0)
        lstdefautTASubTAs.clear();
    
      if(selectedProductId!=null){
        lstProdToTASubTAs=[Select Id, Name,Default_gne__c,Product_gne__c,Product_gne__r.Name,Product_TA_SubTA_gne__c,Product_TA_SubTA_gne__r.Name from Product_To_TASubTA_gne__c where Product_gne__c= : selectedProductId];   
        if(lstProdToTASubTAs!=null && lstProdToTASubTAs.size() >0)
        {   
            for( Integer i = 0 ; i < lstProdToTASubTAs.size() ; i++ ){
                objProdToTASubTa = lstProdToTASubTAs.get(i);
                if(objProdToTASubTa!=null && objProdToTASubTa.Product_TA_SubTA_gne__c != null)
                {
                    lstdefautTASubTAs.add(objProdToTASubTa.Product_TA_SubTA_gne__c);
                    System.debug('objProdToTASubTa.Product_TA_SubTA_gne__c: --> ' + objProdToTASubTa.Product_TA_SubTA_gne__c);
                    if(i==0)
                        selectedTA_SubTA = objProdToTASubTa.Product_TA_SubTA_gne__c;
                }
                
            }           
        }
        
      }
      else{
        selectedTA_SubTA = null;
        selectedMoleculeId = null;
        If (lstdefautTASubTAs != null && lstdefautTASubTAs.size() >0)
            lstdefautTASubTAs.clear();
        if(lstdefautMolecules != null && lstdefautMolecules.size()>0)
            lstdefautMolecules.clear();
      }
      System.debug('lstdefautTASubTAs.size(): --> ' + lstdefautTASubTAs.size());
      System.debug('lstdefautTASubTAs: --> ' + lstdefautTASubTAs);
      loadDefautMolecule();
      
    }
*/

public void loadDefautTA_SubTA()
    {
      System.debug('inside loadDefautTA_SubTA: ');
      
      System.debug('selectedProductId: --> ' + selectedProductId);
      System.debug('mapProductToTASubTA: --> ' + mapProductToTASubTA);
      //List<Product_To_TASubTA_gne__c> lstProdToTASubTAs=new List<Product_To_TASubTA_gne__c>();
      //Product_To_TASubTA_gne__c objProdToTASubTa = null;
      If (lstdefautTASubTAs != null && lstdefautTASubTAs.size() >0)
        lstdefautTASubTAs.clear();
    
      if(selectedProductId!=null && mapProductToTASubTA != null && mapProductToTASubTA.size() >0 && mapProductToTASubTA.containsKey(selectedProductId)){
        lstdefautTASubTAs.add(mapProductToTASubTA.get(selectedProductId));
        System.debug('mapProductToTASubTA.get(selectedProductId): --> ' + mapProductToTASubTA.get(selectedProductId));
        selectedTA_SubTA = mapProductToTASubTA.get(selectedProductId);              
      }
      else{
        selectedTA_SubTA = null;
        selectedMoleculeId = null;
        If (lstdefautTASubTAs != null && lstdefautTASubTAs.size() >0)
            lstdefautTASubTAs.clear();
        if(lstdefautMolecules != null && lstdefautMolecules.size()>0)
            lstdefautMolecules.clear();
      }
      System.debug('lstdefautTASubTAs.size(): --> ' + lstdefautTASubTAs.size());
      System.debug('lstdefautTASubTAs: --> ' + lstdefautTASubTAs);
      loadDefautMolecule();
      
    }
public List<SelectOption> getTA_SubTAList() 
    {   
        Integer i=0;
        System.debug('inside getTA_SubTAList: ');
        System.debug('lstdefautTASubTAs.size(): --> ' + lstdefautTASubTAs.size());
        System.debug('lstdefautTASubTAs: --> ' + lstdefautTASubTAs);
        System.debug('mapTA_SubTAId.size(): --> ' + mapTA_SubTAId.size());
        
        Map<Id,Product_vod__c> map2TA_SubTAId = mapTA_SubTAId.clone();
        List<Product_vod__c> lstTA_SubTA = new List<Product_vod__c> ();
        List<SelectOption> options=new List<SelectOption>();
        
        if(map2TA_SubTAId != null && map2TA_SubTAId.size() >0)
        {
            if(lstdefautTASubTAs !=null && lstdefautTASubTAs.size() >0){
                for(Id defautTA_SubTA: lstdefautTASubTAs)
                {
                    if(defautTA_SubTA != null && map2TA_SubTAId.containsKey(defautTA_SubTA))
                        map2TA_SubTAId.remove(defautTA_SubTA);                  
                }
            }
            else{
                options.add(new SelectOption('', '--None--'));
                selectedTA_SubTA = null;                
            }
            lstTA_SubTA = getSortedList(map2TA_SubTAId);
            if(lstTA_SubTA!=null && lstTA_SubTA.size()>0)
            {
              for(Product_vod__c prod: lstTA_SubTA)
              {
                options.add(new SelectOption(prod.Id, prod.Name));    
              }
            }
        }
        System.debug('options.size(): --> ' + options.size());
        
        if(mapTA_SubTAId != null && mapTA_SubTAId.size() >0){
            if (options.size() > 0 && lstdefautTASubTAs !=null && lstdefautTASubTAs.size() >0) {
                for(Id defautTA_SubTA: lstdefautTASubTAs)
                {
                    if(mapTA_SubTAId != null && mapTA_SubTAId.size() >0 && mapTA_SubTAId.containsKey(defautTA_SubTA)){
                        if(i==0)
                            selectedTA_SubTA = defautTA_SubTA;
                        System.debug('defautTA_SubTA: --> ' + defautTA_SubTA);
                        System.debug('mapTA_SubTAId.get(defautTA_SubTA).Name): --> ' + mapTA_SubTAId.get(defautTA_SubTA).Name);
                        options.add(0,new SelectOption(defautTA_SubTA, mapTA_SubTAId.get(defautTA_SubTA).Name));
                        i = i+1;
                    }
                }
                options.add(new SelectOption('', '--None--'));
            }
        }
        
        System.debug('options.size(): --> ' + options.size());      
        System.debug('mapTA_SubTAId.size(): --> ' + mapTA_SubTAId.size());
        System.debug('map2TA_SubTAId.size(): --> ' + map2TA_SubTAId.size());
        System.debug('options: --> ' + options);
        return options;
    }
    
    public List<SelectOption> getProductList() 
    {               
        List<SelectOption> options=new List<SelectOption>();
        options.add(new SelectOption('', '--None--'));
            
        if(lstProducts!=null && lstProducts.size()>0)
        {
          for(Product_vod__c prod: lstProducts  )
          {
            options.add(new SelectOption(prod.Id, prod.Name));    
          }
        }
        return options;
    }
    public void loadDefautMolecule()
    {
      System.debug('inside loadDefautMolecule: ');
      System.debug('selectedTA_SubTA: --> ' + selectedTA_SubTA);
      List<TASubTA_To_Molecule_gne__c> lstTASubTAToMolecules=new List<TASubTA_To_Molecule_gne__c>();
      If (lstdefautMolecules != null && lstdefautMolecules.size() >0)
        lstdefautMolecules.clear();
    
      if(selectedTA_SubTA!=null){
        lstTASubTAToMolecules=[Select Id, Name,Default_gne__c,Product_TA_SubTA_gne__c,Product_TA_SubTA_gne__r.Name,Product_Molecule_gne__c, Product_Molecule_gne__r.Name from TASubTA_To_Molecule_gne__c where Product_TA_SubTA_gne__c= : selectedTA_SubTA];   
        if(lstTASubTAToMolecules!=null && lstTASubTAToMolecules.size() >0)
        {
            for(TASubTA_To_Molecule_gne__c objTAToMol: lstTASubTAToMolecules  )
            {
                if(objTAToMol != null && objTAToMol.Product_Molecule_gne__c != null){
                    lstdefautMolecules.add(objTAToMol.Product_Molecule_gne__c);
                    System.debug('objTAToMol.Product_Molecule_gne__c: --> ' + objTAToMol.Product_Molecule_gne__c);
                }
            }
        }
      }
      else{
        selectedMoleculeId = null;
        if(lstdefautMolecules != null && lstdefautMolecules.size()>0)
            lstdefautMolecules.clear();
      }
      System.debug('lstdefautMolecules.size(): --> ' + lstdefautMolecules.size());
      System.debug('lstdefautMolecules: --> ' + lstdefautMolecules);
    }
    
    public List<SelectOption> getMoleculeList() 
    {   
        Integer i=1;
        System.debug('inside getMoleculeList: ');
        System.debug('lstdefautMolecules.size(): --> ' + lstdefautMolecules.size());
        System.debug('lstdefautMolecules: --> ' + lstdefautMolecules);
        System.debug('mapMoleculeId.size(): --> ' + mapMoleculeId.size());
        
        Map<Id,Product_vod__c> map2Molecule = mapMoleculeId.clone();
        List<Product_vod__c> lstMolecule = new List<Product_vod__c> ();
        List<SelectOption> options=new List<SelectOption>();
        System.debug('options.size(): --> ' + options.size());
        
        options.add(new SelectOption('', '--None--'));
        System.debug('options.size(): --> ' + options.size());
        if(map2Molecule != null && map2Molecule.size() >0)
        {
            if(lstdefautMolecules !=null && lstdefautMolecules.size() >0){
                for(Id defautMolecule: lstdefautMolecules)
                {
                    if(defautMolecule != null && map2Molecule.containsKey(defautMolecule)){
                        map2Molecule.remove(defautMolecule);        
                    }
                }
            }
            else{
                lstMolecule = getSortedList(map2Molecule);
                if(lstMolecule!=null && lstMolecule.size()>0)
                {
                  for(Product_vod__c prod: lstMolecule)
                  {
                    options.add(new SelectOption(prod.Id, prod.Name));    
                  }
                }
            }
            
        }
        System.debug('options.size(): --> ' + options.size());
        if(mapMoleculeId != null && mapMoleculeId.size() >0){
            if (options.size() > 0 && lstdefautMolecules !=null && lstdefautMolecules.size() >0) {
                for(Id defautMolecule: lstdefautMolecules)
                {
                    if(mapMoleculeId != null && mapMoleculeId.size() >0 && mapMoleculeId.containsKey(defautMolecule)){
                        System.debug('defautMolecule: --> ' + defautMolecule);
                        System.debug('mapMoleculeId.get(defautMolecule).Name): --> ' + mapMoleculeId.get(defautMolecule).Name);
                        options.add(new SelectOption(defautMolecule, mapMoleculeId.get(defautMolecule).Name));                      
                    }
                }               
            }
        }
        
        System.debug('options.size(): --> ' + options.size());  
        
        System.debug('mapMoleculeId.size(): --> ' + mapMoleculeId.size());
        System.debug('map2Molecule.size(): --> ' + map2Molecule.size());
        System.debug('options: --> ' + options);
        return options;
    }
   
    public String getcurrentDate() 
    {
        
        return System.today().format();
    }
    
    public Address_vod__c getSelectedAddress()
    {
      /*
      for(Address_vod__c ad: lstAddress  )
      {
        if(selectedAddressId!=null && selectedAddressId==ad.Id)
          selectedAddress=ad;
      }
      */
      System.debug('Inside getSelectedAddress --> ');
      if(mapAddressId != null && selectedAddressId!=null && mapAddressId.containsKey(selectedAddressId)){
        selectedAddress=mapAddressId.get(selectedAddressId);
      }
      else{
        selectedAddress=new Address_vod__c();
      }
      System.debug('selectedAddress --> :' + selectedAddress);
      return selectedAddress;
    }
     
  //action functions
  public void hcpAddress()
    {
      System.debug('Inside hcpAddress --> ');
      getSelectedAddress();
      errMessage=selectedAddress.Name;
      
    }
    public PageReference cancel() {
        PageReference p = null;
        //forward to account page
        p = new PageReference('/'+ account.Id);
        return p;
    }
  public PageReference save() {
  
    PageReference p = null;
    List<User> lstUserIds = new List<User> ();
    List<User> lstReqByUserIds = new List<User> ();
    blnIsValid = True;
    GNE_Referral_Utils.isMedicalReferral = true;
    Medical_Communication_gne__c newReferral = new Medical_Communication_gne__c();
    Referral_Assignment_gne__c newReferralAssignment = new Referral_Assignment_gne__c();
    GNE_Med_iPhone_CreateReferral.Response callResponse = new GNE_Med_iPhone_CreateReferral.Response();
    GNE_Med_iPhone_CreateReferral.ReferralInfo RefInfo = new GNE_Med_iPhone_CreateReferral.ReferralInfo();
    System.debug('disableInput: ' + disableInput);
    System.debug('SearchFld: ' + SearchFld);
    String[] lstCallResponseErrors = new List<String> ();
    if((!disableInput) && SearchFld == ''){
        System.debug('Please enter the value for Assigned To.');
        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please enter the value for Assigned To Or do the Auto Assignment.'));
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please specify the "Assigned To" person, or select "Auto Assignment".'));
        GNE_Referral_Utils.isMedicalReferral = false;
        return null;
    }   
    System.debug('objReferralProxy.Requested_Completion_Date_gne__c: ' + objReferralProxy.Requested_Completion_Date_gne__c);
    System.debug('String.valueOf(objReferralProxy.Requested_Completion_Date_gne__c): ' + String.valueOf(objReferralProxy.Requested_Completion_Date_gne__c));
    //Requested Completion Date Should be greater than today.
    if(String.valueOf(objReferralProxy.Requested_Completion_Date_gne__c) != null && objReferralProxy.Requested_Completion_Date_gne__c < Date.today()){
        System.debug('Requested Completion Date Should be greater than today.');
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Requested Completion Date Should be greater than today.'));
        GNE_Referral_Utils.isMedicalReferral = false;
        return null;
    }
    else{
        //Requested By field is editable by MedAffair profile user only as they can raise referra on behalf of MCCO users.
        if(getIsMCLUser()){
            System.debug('(String)objReferralProxy.Requested_By_gne__c: ' + (String)objReferralProxy.Requested_By_gne__c);
            System.debug('isMedComm: ' + isMedComm);
            System.debug('SearchFld1: ' + SearchFld1);
            System.debug('SearchId1: ' + SearchId1);
            if(!isMedComm){
                if(SearchFld1 != null && SearchFld1 != ''){
                    lstReqByUserIds = GNE_Referral_Utils.getRequestedByUser(SearchFld1);
                    System.debug('lstReqByUserIds: ' + lstReqByUserIds);
                    if (lstReqByUserIds != null && lstReqByUserIds.size() >0)
                    {
                        if(lstReqByUserIds.size() ==1){
                            objReferralProxy.Requested_By_gne__c = lstReqByUserIds[0].Id;
                        }else
                        {
                            System.debug('Multiple User found. Click Lookup icon at Requested By Field to refine the search.:');
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Multiple User found. Click Lookup icon at Requested By Field to refine the search.'));
                            GNE_Referral_Utils.isMedicalReferral = false;
                            return null;
                        }
                    }else
                    {
                        System.debug('No User found. Click Lookup icon at Assigned To Field to select appropriate user.:');
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No User found. Click Lookup icon at Assigned To Field to select appropriate user.'));
                        GNE_Referral_Utils.isMedicalReferral = false;
                        return null;
                    }
                }else{
                    objReferralProxy.Requested_By_gne__c = UserInfo.getUserId();
                }
                    
            }
            /*
            if(isMedComm && (String)objReferralProxy.Requested_By_gne__c !=null){
                System.debug('Please uncheck the Is MedComm checkbox if you wanted to enter Requested By user value Or Clear the Requested By user value.');
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please uncheck the Is MedComm checkbox if you wanted to enter Requested By user value Or Clear the Requested By user value.'));
                GNE_Referral_Utils.isMedicalReferral = false;
                return null;
            }
            */
            if((String)objReferralProxy.Requested_By_gne__c==null || (String)objReferralProxy.Requested_By_gne__c==''){
                if(!isMedComm){
                    objReferralProxy.Requested_By_gne__c = UserInfo.getUserId();
                }           
            }
        }
        else{
            objReferralProxy.Requested_By_gne__c = UserInfo.getUserId();
        }
        if(isValid()){  
            try{
                GNE_Med_iPhone_CreateReferral.getDemo();
                Datetime dt = System.today();
                System.debug('(String)objReferralProxy.Priority_gne__c: ' + (String)objReferralProxy.Priority_gne__c);
                /*
                if((String)objReferralProxy.Priority_gne__c==null || (String)objReferralProxy.Priority_gne__c==''){
                    objReferralProxy.Priority_gne__c = GNE_Referral_Utils.strNormal;
                }
                */
                System.debug('selectedTA_SubTA: ' + selectedTA_SubTA);
                System.debug('User:@@@@@@@@: ' + UserInfo.getName());
                
                RefInfo.AccountId = account.Id;
                RefInfo.AddressId = selectedAddressId;
                RefInfo.MedicalQuestion = question;
                RefInfo.FollowupMethod = objReferralProxy.Follow_up_Method_gne__c;
                RefInfo.ProductId = selectedProductId;
                RefInfo.MoleculeId = selectedMoleculeId;
                RefInfo.TA_SubTAId = selectedTA_SubTA;
                System.debug('objReferralProxy.Requested_Completion_Date_gne__c: ' + objReferralProxy.Requested_Completion_Date_gne__c);
                System.debug('String.valueOf(objReferralProxy.Requested_Completion_Date_gne__c): ' + String.valueOf(objReferralProxy.Requested_Completion_Date_gne__c));
                if(String.valueOf(objReferralProxy.Requested_Completion_Date_gne__c) != null)
                    RefInfo.RequestedCompletionDate = objReferralProxy.Requested_Completion_Date_gne__c;
                RefInfo.Priority = objReferralProxy.Priority_gne__c;
                if((String)objReferralProxy.Requested_By_gne__c!=null && (String)objReferralProxy.Requested_By_gne__c!=''){
                    RefInfo.RequestedById = objReferralProxy.Requested_By_gne__c;
                    RefInfo.isMedComm = false;
                }else{
                    RefInfo.isMedComm = isMedComm;
                }
                RefInfo.UserId = UserInfo.getUserId();
                
                System.debug('SearchFld: ' + SearchFld);
                if(SearchFld != null && SearchFld != ''){
                    lstUserIds = GNE_Referral_Utils.getAssignedUser(SearchFld,'Create');
                    System.debug('lstUserIds: ' + lstUserIds);
                    if (lstUserIds != null && lstUserIds.size() >0)
                    {
                        if(lstUserIds.size() ==1){
                            RefInfo.AssignedToId = lstUserIds[0].Id;
                        }else
                        {
                            System.debug('Multiple User found. Click Lookup icon at Assigned To Field to refine the search.:');
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Multiple User found. Click Lookup icon at Assigned To Field to refine the search.'));
                            GNE_Referral_Utils.isMedicalReferral = false;
                            return null;
                        }
                    }else
                    {
                        System.debug('No User found. Click Lookup icon at Assigned To Field to select appropriate user.:');
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No User found. Click Lookup icon at Assigned To Field to select appropriate user.'));
                        GNE_Referral_Utils.isMedicalReferral = false;
                        return null;
                    }
                }else{
                    RefInfo.AssignedToId = null;
                }
                
                callResponse = GNE_Med_iPhone_CreateReferral.createReferral(RefInfo);
                System.debug('callResponse: ' + callResponse);
                if(callResponse != null){
                    if(callResponse.ErrorMessage != null && callResponse.ErrorMessage != '')
                    {
                        //System.debug('Validation Error on the page:' + callResponse.ErrorMessage);
                        lstCallResponseErrors = callResponse.ErrorMessage.split(',');
                        System.debug('lstCallResponseErrors: ' + lstCallResponseErrors);
                        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Validation Error on the page: '));
                        for (String strErrMsg : lstCallResponseErrors) {
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,strErrMsg));                        }                       
                        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Validation Error on the page: ' + callResponse.ErrorMessage));
                        GNE_Referral_Utils.isMedicalReferral = false;
                        return null;
                    }
                    else{
                        if(callResponse.getResponseReferral() != null){
                            newReferral = callResponse.getResponseReferral();
                        }
                        if(callResponse.getResponseReferralAssignment() != null){
                            newReferralAssignment = callResponse.getResponseReferralAssignment();
                        }
                        if(newReferral != null && newReferralAssignment != null)
                        {
                            p = new PageReference('/'+ newReferral.Referral_Assignment_gne__c);
                        }
                        else{
                            //System.debug('Validation Error on the page:' + callResponse.ErrorMessage);
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,callResponse.ErrorMessage));
                            GNE_Referral_Utils.isMedicalReferral = false;
                            return null;
                        }
                    }                   
                }
                else{
                        //System.debug('Validation Error on the page:' + callResponse);
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error on the page' + callResponse));
                        GNE_Referral_Utils.isMedicalReferral = false;
                        return null;
                    }
                //p = new PageReference('/'+ newReferral.Referral_Assignment_gne__c);            
            }
            catch (Exception e) {
                System.debug('Error on the page:' + e);
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Error on the page' + e));
                GNE_Referral_Utils.isMedicalReferral = false;
                return null;
            }
        }
        else
        {
            System.debug('Input Required for below fields:' + strErrorMsg);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Input Required for below fields:' + strErrorMsg));
            GNE_Referral_Utils.isMedicalReferral = false;
            return null;
        }
    }
    GNE_Referral_Utils.isMedicalReferral = false;
    return p;
    
  }
  
  private Boolean isValid()
    {   
        /*
        strErrorMsg='';
        if (selectedAddress==null)
        {
            strErrorMsg = 'Address';
            blnIsValid=False;
        }
        
        if((String)question==null || (String)question==''){
            if(strErrorMsg==''){
                strErrorMsg = 'Medical Question';               
            }
            else{
                strErrorMsg = strErrorMsg + ', Medical Question';
            }
            blnIsValid=False;           
        }
        
        if((String)selectedProductId=='' || (String)selectedProductId==null){
            if(strErrorMsg==''){
                strErrorMsg = 'Product';                
            }
            else{
                strErrorMsg = strErrorMsg + ', Product';
            }
            blnIsValid=False;
        }
        
        if((String)selectedMoleculeId==null || (String)selectedMoleculeId==''){
            if(strErrorMsg==''){
                strErrorMsg = 'Molecule';               
            }
            else{
                strErrorMsg = strErrorMsg + ', Molecule';
            }
            blnIsValid=False;
        }
        
        if((String)selectedTA_SubTA==null || (String)selectedTA_SubTA==''){
            if(strErrorMsg==''){
                strErrorMsg = 'TA_SubTA';               
            }
            else{
                strErrorMsg = strErrorMsg + ', TA_SubTA';
            }
            blnIsValid=False;
        }
        
        */
        
        return blnIsValid;
    }
    
 }