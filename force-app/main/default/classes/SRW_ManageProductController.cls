public  class SRW_ManageProductController {
	
  public List<Product_vod__c> products {get;set;}
	public String selectedStatus {get;set;}
	public String selectedBrand {get;set;}
  public String selectedProduct {get;set;}
	public String selectedFileFormat {get;set;}
	public String selectedProductName {get;set;}
  public String selectedTPIds { get; set; }
  public Boolean selectAllPartners {get;set;}	
  public Boolean updateMode {get;set;}
  public String oldNDC{get;set;}
	public NewProduct product {get;set;}
	public List<AssignmentWrapper> assignmentList {get;set;}


	private Map<Id,Product_vod__c> productMap = new Map<Id,Product_vod__c>();
	private Map<Id,SRW_Trading_Partner_Profile__c> allActiveTPProfilesMap;
	private Set<String> uniqueBrand = new Set<String>();
  private List<AssignmentWrapper> initialAssignmentList = new List<AssignmentWrapper>();
  private static List<String> assignmentRemote = new List<String>();

	public SRW_ManageProductController() {

			products = [Select Id,
							   active__c,
							   SRW_Product_De_activation_Date_gne__c,
                 SRW_Product_Effective_Date_gne__c,
							   Product_Type_vod__c,
							   Name,
							   NDC_Number_gne__c,
							   SRW_Comments_gne__c,
							   Brand_Code_gne__c,
                 SRW_Data_Type_gne__c 
					    From Product_vod__c 
					    where Product_Type_vod__c = 'SRW'
              ORDER BY Brand_Code_gne__c, Name ASC];

			for(Product_vod__c tmp : products){

				productMap.put(tmp.Id,tmp);
			}

			allActiveTPProfilesMap =  new Map<Id,SRW_Trading_Partner_Profile__c>();
      for(SRW_Trading_Partner_Profile__c tempTP : [Select Id, Trading_Partner_Name_gne__c,(select id from SRW_Security_Community_Data__r where Status_gne__c IN('Active','Locked')) From SRW_Trading_Partner_Profile__c ]){
          if(tempTP.SRW_Security_Community_Data__r.size()>0) {

              allActiveTPProfilesMap.put(tempTP.Id, tempTP);

          }
      }
						         //Where Active_gne__c = true]);

			assignmentList = new List<AssignmentWrapper>();
			for(SRW_Trading_Partner_Profile__c tmp :allActiveTPProfilesMap.values()) {
				assignmentList.add(new AssignmentWrapper(false,tmp));
        initialAssignmentList.add(new AssignmentWrapper(false,tmp));
			}

      selectedStatus = 'All';
      updateMode = false;
      String msg = 'phba'.equals(ApexPages.CurrentPage().getParameters().get('msg')) ? 'Product has been added' : 'phbc'.equals(ApexPages.CurrentPage().getParameters().get('msg')) ? 'Product has been changed' : '';
      String pageHeaderReferer = ApexPages.currentPage().getHeaders().get('Referer'); 
      system.debug('msg: ' + msg);
      system.debug('page header referer: ' + pageHeaderReferer);
      if(pageHeaderReferer != null && pageHeaderReferer.containsIgnoreCase('SRW_ManageProducts') && !String.isBlank(msg)){
        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, msg));
      }
	}

	public List<SelectOption> getProdStatusOptions() {
      
      List<SelectOption> status = new List<SelectOption>();
	      status.add(new Selectoption('all','All'));
	      status.add(new Selectoption('Active','Active'));
		    status.add(new Selectoption('Inactive','Inactive'));	
      return status;
  }

  	public List<SelectOption> getBrandOptions() {
      
      List<SelectOption> brands = new List<SelectOption>();
      brands.add(new Selectoption('all','All'));
      	uniqueBrand.clear();
      	for(Product_vod__c tmp : products) {

      		if(!uniqueBrand.contains(tmp.Brand_Code_gne__c)){
      				 brands.add(new Selectoption(tmp.Brand_Code_gne__c,tmp.Brand_Code_gne__c));
      				 uniqueBrand.add(tmp.Brand_Code_gne__c);
      		}
      	}

      return brands;
  }
  public List<SelectOption> getFileFormatOptions() {
      
      List<SelectOption> fileFormats = new List<SelectOption>();
      fileFormats.add(new Selectoption('pdf','pdf'));
      fileFormats.add(new Selectoption('csv','csv'));
      fileFormats.add(new Selectoption('xls','xls'));

      return fileFormats;
  }

  public PageReference addNewProduct(){

  	product = new NewProduct();
    product.DatabaseProduct = new Product_vod__c();
    assignmentList = initialAssignmentList.clone();
  	updateMode = false;
    
    PageReference target = Page.SRW_AddNewProduct;
  	target.setRedirect(false);
   
  	return target;
  } 

    private Boolean duplicateRecord (Product_vod__c rec) {

        List<Product_vod__c> existingProd = [Select Id From Product_vod__c where Product_Type_vod__c = 'SRW' AND NDC_Number_gne__c =:product.DatabaseProduct.NDC_Number_gne__c AND Brand_Code_gne__c =: product.DatabaseProduct.Brand_Code_gne__c AND Name =: product.DatabaseProduct.Name limit 1];
        if(existingProd.isEmpty())
            return false;
        else if (rec.Id == existingProd[0].Id)  
            return false;
        else 
            return true;
    }

    public PageReference updateProduct(){

    product = new NewProduct();
    PageReference target = Page.SRW_AddNewProduct;
    setProductId();
    product.DatabaseProduct = productMap.get(selectedProduct);
    oldNDC = product.DatabaseProduct.NDC_Number_gne__c;
    updateMode = true;
    target.setRedirect(false);
    assignmentList = initialAssignmentList.clone();
    return target;
  }

  public PageReference clear(){

    assignmentList.clear();
    assignmentList = initialAssignmentList.clone();
    product.DatabaseProduct.Brand_Code_gne__c = '';
    product.DatabaseProduct.Name = '';
    product.DatabaseProduct.SRW_Comments_gne__c = '';
    product.DatabaseProduct.SRW_Data_Type_gne__c = '';
    product.DatabaseProduct.NDC_Number_gne__c = '';


    product.productAssignment.clear();
    return null;
  }

  public PageReference calcualteAssignProduct(){

  	assignmentList.clear();
  	Set<Id> tpIds = new Set<Id>();
  	List<SRW_Trd_Prt_Product_gne__c> assignProdToPartner = [Select Id,Name,Trading_Partner_gne__c,Product_gne__c from SRW_Trd_Prt_Product_gne__c where Product_gne__c =:selectedProduct];

  	for(SRW_Trd_Prt_Product_gne__c tmp :assignProdToPartner) {

  			tpIds.add(tmp.Trading_Partner_gne__c);
  	}

  	for(SRW_Trading_Partner_Profile__c tmp : allActiveTPProfilesMap.values()){

  		if(!tpIds.contains(tmp.Id)) {

  			assignmentList.add(new AssignmentWrapper(false,tmp));
  		}
  	}

  	return null;
  }

  public PageReference calcualteUnassignProduct(){

  	assignmentList.clear();

  	List<SRW_Trd_Prt_Product_gne__c> assignProdToPartner = [Select Id,Name,Trading_Partner_gne__c,Product_gne__c from SRW_Trd_Prt_Product_gne__c where Product_gne__c =:selectedProduct];

  	for(SRW_Trd_Prt_Product_gne__c tmp : assignProdToPartner) {

      if(allActiveTPProfilesMap.containsKey(tmp.Trading_Partner_gne__c)){
  			assignmentList.add(new AssignmentWrapper(false,allActiveTPProfilesMap.get(tmp.Trading_Partner_gne__c)));
      }

  	}

  	return null;
  }
  @RemoteAction
  public static String unassignProductToTradingPartners(List<String> assignmentList,String selectedProduct){

  		Set<Id> tpIds = new Set<Id>();
  		for(String tmp :assignmentList){
  				tpIds.add(tmp);
  		}

  		List<SRW_Trd_Prt_Product_gne__c> delProdToPartner = [Select Id,Name,Trading_Partner_gne__c,Product_gne__c from SRW_Trd_Prt_Product_gne__c where Product_gne__c =:selectedProduct and Trading_Partner_gne__c IN :tpIds];
  		if(!delProdToPartner.isEmpty()) {
        try {
    				delete delProdToPartner;
    			} catch (Exception e) {

              return 'Error' + e;
    			}
       }

    	 	return 'Success';
  }

  public void setupNewProdAssignment(){
      product.productAssignment.clear();
      system.debug('MICK_LOKO selectedTPIds:' + selectedTPIds);
      if(selectedTPIds != '') {
        List<String> assignedTP = selectedTPIds.split(',');
        for(String tmp : assignedTP){
            product.productAssignment.add(new SRW_Trd_Prt_Product_gne__c(Trading_Partner_gne__c=tmp));
        }
      }
  }
  
  @RemoteAction
  public static String assignProductToTradingPartners(List<String> assignmentList,String selectedProduct){
  	 	
  	 	List<SRW_Trd_Prt_Product_gne__c> insertPrdAssign = new List<SRW_Trd_Prt_Product_gne__c>();
  		for(String tmp :assignmentList){

  				SRW_Trd_Prt_Product_gne__c newAssignment = new SRW_Trd_Prt_Product_gne__c();
  					newAssignment.Product_gne__c = selectedProduct;
  					newAssignment.Trading_Partner_gne__c = tmp;
            newAssignment.Is_Visible_gne__c = true;
  				insertPrdAssign.add(newAssignment);

  		}
      if(!insertPrdAssign.isEmpty()) {
  		try {
  				insert  insertPrdAssign;
  			} catch (Exception e) {

            return 'Error:' + e;

  			}
      }
  	 	return 'Success';

  }

  public PageReference deactivateProduct(){

  	Product_vod__c toUpdate = productMap.get(selectedProduct);
    List<SRW_Trd_Prt_Product_gne__c> delProdToPartner = [Select Id,Name,Trading_Partner_gne__c,Product_gne__c from SRW_Trd_Prt_Product_gne__c where Product_gne__c =:selectedProduct];
  	toUpdate.SRW_Product_De_activation_Date_gne__c = system.now();
    toUpdate.active__c = false;

	  	try {
	  			update toUpdate;
          delete delProdToPartner;
	  		} catch (Exception e) {


	  		}

	return null;
  }

  public PageReference exportDataToFile(){

    PageReference newPageRef ;

    if(selectedFileFormat == 'xls') {

        newPageRef = Page.SRW_Export_Excel;
        newPageRef.getParameters().put('mode', 'Products');
        newPageRef.getParameters().put('csv', 'no');
        newPageRef.getParameters().put('filter', selectedStatus);
        newPageRef.getParameters().put('brand', selectedBrand);
        newPageRef.setRedirect(false);

      } else if (selectedFileFormat == 'pdf') {

        newPageRef = Page.SRW_Export_Pdf;
        newPageRef.getParameters().put('mode', 'Products');
        newPageRef.getParameters().put('csv', 'no');
        newPageRef.getParameters().put('filter', selectedStatus);
        newPageRef.getParameters().put('brand', selectedBrand);
        newPageRef.setRedirect(true);
      } else {

        newPageRef = Page.SRW_Export_CSV;
        newPageRef.getParameters().put('mode', 'Products');
        newPageRef.getParameters().put('csv', 'yes');
        newPageRef.getParameters().put('filter', selectedStatus);
        newPageRef.getParameters().put('brand', selectedBrand);
        newPageRef.setRedirect(true);
      }


    return newPageRef;
  }

  public PageReference setProductId(){

  	selectedProductName = productMap.get(selectedProduct).Name;

  	return null;
  }

    public PageReference activateProduct(){
  	
  	Product_vod__c toUpdate = productMap.get(selectedProduct);

  	toUpdate.active__c = true;
    toUpdate.SRW_Product_De_activation_Date_gne__c = null;
    toUpdate.SRW_Product_Effective_Date_gne__c = system.now();
	  	try {
	  			update toUpdate;
	  		} catch (Exception e) {


	  		}

	return null;
  }

  private Boolean saveProductWithAssignment(){
      Boolean statusOK = false;

      if(String.isBlank(product.DatabaseProduct.Brand_Code_gne__c)){
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Product Brand is required');
        ApexPages.addMessage(myMsg);
        statusOK = false;
      }
      else if(String.isBlank(product.DatabaseProduct.SRW_Data_Type_gne__c)){
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Product Data Type is required');
        ApexPages.addMessage(myMsg);
        statusOK = false;
      }
      else if(String.isBlank(product.DatabaseProduct.NDC_Number_gne__c)){
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Product NDC number is required');
        ApexPages.addMessage(myMsg);
        statusOK = false;
      }
      else if(String.isBlank(product.DatabaseProduct.Name)){
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Product Name is required');
        ApexPages.addMessage(myMsg);
        statusOK = false;
      }
      else if(!checkNDCFormat(product.DatabaseProduct.NDC_Number_gne__c)) {

        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Product NDC is incorrect');
        ApexPages.addMessage(myMsg);
        statusOK = false;
      }
      else if(updateMode && !oldNDC.equals(product.DatabaseProduct.NDC_Number_gne__c) && !checkNDCInDB(product.DatabaseProduct.NDC_Number_gne__c)) {
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Product NDC already exists');
        ApexPages.addMessage(myMsg);
        statusOK = false;
      } else if(!updateMode && !checkNDCInDB(product.DatabaseProduct.NDC_Number_gne__c)){
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Product NDC already exists');
        ApexPages.addMessage(myMsg);
        statusOK = false;
      }
      else if(!duplicateRecord(product.DatabaseProduct)) {

          Boolean isInsert = false;
          // Insert new product
          if(product.DatabaseProduct.id == null) {
            product.DatabaseProduct.Product_Type_vod__c = 'SRW';
            product.DatabaseProduct.SRW_Product_Effective_Date_gne__c = system.now();
            product.DatabaseProduct.active__c = true;
            isInsert = true;

          }

         try{
            system.debug('MICK_LOKO : before upsert');
            upsert product.DatabaseProduct;
            if(isInsert) {
              //insert product assignment
              List<SRW_Trd_Prt_Product_gne__c> newAssignmentsProd = new List<SRW_Trd_Prt_Product_gne__c>();
              for(SRW_Trd_Prt_Product_gne__c tmp : product.productAssignment){

                  tmp.Is_Visible_gne__c = true;
                  tmp.Product_gne__c = product.DatabaseProduct.Id;
                  newAssignmentsProd.add(tmp);
              }

              insert newAssignmentsProd;
            }
            statusOK = true;
          } catch (Exception e) {
              system.debug('upsert exception: ' + e.getMessage());
              statusOK = false;
          }
      } else {
              System.debug('MICK_LOKO : Product exist');
              ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'Product already exist');
              ApexPages.addMessage(myMsg);
              statusOK = false;
    }
        return statusOK;
  }
  
  public PageReference submit(){
    system.debug('MICK_LOKO : in submit');
    if(saveProductWithAssignment()) {
      PageReference ref = Page.SRW_ManageProducts;
      ref.setRedirect(true);
      String msg = updateMode ? 'phbc' : 'phba';
      ref.getParameters().put('msg', msg);
      system.debug('MICK_LOKO : saveProductWithAssignment : true');
      return ref;
    } else {

      return null;
    }
  }

  public PageReference cancel(){

    PageReference ref = Page.SRW_ManageProducts;
    ref.setRedirect(true);
    
    return ref;
  }
  
  
  @RemoteAction
  public static String assignToProduct(List<String> assignment){

    for(String tmp : assignment) {

        assignmentRemote.add(tmp);
    }

    system.debug('MICK_LOKO assignmentRemote.size() :' +assignmentRemote.size());
    system.debug('MICK_LOKO assignmentRemote :' + assignmentRemote);
    return 'success';
  }

  public PageReference submitAndNew(){

  	 if(saveProductWithAssignment()) {
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Product has been added');
        ApexPages.addMessage(myMsg);
        product = new NewProduct();
        product.DatabaseProduct = new Product_vod__c();
        assignmentList = initialAssignmentList.clone();
        updateMode = false;
     }
	  return null;
  }

  public List<Selectoption> getDataTypeforProduct(){

  		 List<SelectOption> dataType = new List<SelectOption>();

  		 dataType.add(new SelectOption('Integer','Whole Number'));
  		 dataType.add(new SelectOption('Decimal','Decimal'));
  		 return dataType;
  }


  public class NewProduct {

  	public String Brand {get;set;}
  	public String ProductName {get;set;}
  	public String Ndc {get;set;}
  	public String DataType {get;set;}
  	public String Comments {get;set;}
    public Product_vod__c DatabaseProduct {get;set;}

  	List<SRW_Trd_Prt_Product_gne__c> productAssignment;

  		public NewProduct() {

  			productAssignment = new List<SRW_Trd_Prt_Product_gne__c>();
  		}

  }
  //"if numbers XXXXX-XXXX-XX else allow the text null-null-null"

  public static Boolean checkNDCFormat(String ndcString) {

        if(ndcString == 'null-null-null') {
          return true;
        }
        else {
          String ndcRegEx = '[0-9]{11}';
          Pattern MyPattern = Pattern.compile(ndcRegEx);
          Matcher MyMatcher = MyPattern.matcher(ndcString);
          Boolean result = MyMatcher.matches();
          return result;
        }
    }

    public static Boolean checkNDCInDB(String ndcString){
      List<Product_vod__c> temp = [SELECT id FROM Product_vod__c WHERE Product_Type_vod__c = 'SRW' AND NDC_Number_gne__c = :ndcString];
      return temp.isEmpty();
    }

  public class AssignmentWrapper{

  	public Boolean assign {get;set;}
  	public SRW_Trading_Partner_Profile__c traidingPartner {get;set;}

  	public assignmentWrapper(Boolean parm1 , SRW_Trading_Partner_Profile__c parm2) {

  		this.assign = parm1;
  		this.traidingPartner = parm2;

  	}

  }
}