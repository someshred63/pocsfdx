public class GNE_MSL_TA_Molecules_Lists_Controller{

	private Account account;
	private String pretUrl = null;
	public List<Product_Metrics_vod__c> products { get; set;}
	public List<Product_Metrics_vod__c> therapeutic_areas{ get; set;}
	public Map<String, String> environment_var_val = new Map<String, String>();
	public Boolean DelEditVisible = false;
	
	private final static Set<String> variable = new Set<String>{'AccountIdNewBrandAffiliation','AccountNameLabelNewBrandAffiliation'};
	private final static String product_metrics_obj_var=Schema.SObjectType.Product_Metrics_vod__c.getKeyPrefix(); 
	
	public GNE_MSL_TA_Molecules_Lists_Controller(ApexPages.StandardController stdController){        
		GenerateEnvVar();
		this.account = (Account)stdController.getRecord();
		pretUrl = ApexPages.currentPage().getParameters().get('retURL');
	}
	
	public void init() {
		products = [Select p.Account_vod__c, p.CreatedById, p.CreatedDate, p.Name,
					p.Owner_gne__c, p.Products_vod__c, p.id,p.Products_vod__r.Name,p.Contracted_Speaker__c,
					p.Brand_Affiliation_Status_gne__c 
					from Product_Metrics_vod__c p  where
					p.Account_vod__c =:account.id and
					p.Products_vod__r.ownerId=:Molecule_Queue_ID
					and p.Products_vod__r.Detail_Product_Subtype_Code_gne__c ='Molecule'];
					therapeutic_areas = [Select p.Account_vod__c, p.CreatedById, p.CreatedDate, p.Name,
					p.Owner_gne__c, p.Products_vod__c, p.id,p.Products_vod__r.Name,p.Contracted_Speaker__c,
					p.Brand_Affiliation_Status_gne__c 
					from Product_Metrics_vod__c p  where
					p.Account_vod__c =:account.id and
					p.Products_vod__r.ownerId=:Therapeutic_Area_Queue_ID 
					and p.Products_vod__r.Detail_Product_Subtype_Code_gne__c ='TheraDisease'];
					
		System.debug('therapeutic_areas'+therapeutic_areas);
	}
	
	public PageReference CloneCase(){
		String URL;                     
		URL = '/' + product_metrics_obj_var + '/e?retURL=%2F' + product_metrics_obj_var;
		return GetProductMetricsPage(URL);
	}  
	
	private PageReference GetProductMetricsPage(String URL){
		PageReference productMetricsPage = new PageReference(URL);
		productMetricsPage.setRedirect(true);
		return productMetricsPage ;
	}
	
	public void GenerateEnvVar(){
		List<Environment_Variables__c> env_var = GNE_CM_Environment_variable.get_env_variable(variable);
		for (Integer i = 0; i < env_var.size(); i++){
			environment_var_val.put(env_var[i].Key__c, env_var[i].Value__c); 
		}
	}
	
	public PageReference DeleteBrandFromAcc(){
		Id id = System.currentPageReference().getParameters().get('brand_id');
		Product_Metrics_vod__c pm = [Select p.Name from Product_Metrics_vod__c p where p.id= :id ];
		PageReference productMetricsPage = new PageReference('/' + account.id);
		productMetricsPage.setRedirect(true);
		Delete pm;
		return productMetricsPage;
	}
	
	public PageReference EditBrand(){
		Id id = System.currentPageReference().getParameters().get('brand_id');
		PageReference productMetricsPage = new PageReference('/' + id + '/e?retURL=%2F' + Account.Id);
		productMetricsPage.setRedirect(true);
		return productMetricsPage;
	}

	public PageReference EditBrandSFA2(){
		Id brandid = System.currentPageReference().getParameters().get('brand_id');
		PageReference productMetricsPage = new PageReference('/apex/GNE_SFA2_Brand_Aff_Edit_Create_Layout?id=' + brandid + '&retURL=%2F' + Account.Id);
		productMetricsPage.setRedirect(true);
		return productMetricsPage;
	}
	
	public PageReference ViewBrand(){
		Id id = System.currentPageReference().getParameters().get('brand_id');
		PageReference productMetricsPage = new PageReference('/' + id);
		productMetricsPage.setRedirect(true);
		return productMetricsPage;
	}
	
	public PageReference NewBrand(){
		PageReference productMetricsPage = new PageReference('/' + product_metrics_obj_var + '/e?'+AccountNameLabelNewBrandAffiliation+'='+Account.Name+'&'+AccountIdNewBrandAffiliation+'='+Account.Id+'&retURL=%2F'+Account.Id+'&saveURL=%2F'+Account.Id+'');
		productMetricsPage.setRedirect(true);
		return productMetricsPage;
	}
	
	public PageReference NewBrandSFA2(){
		PageReference productMetricsPage = new PageReference('/apex/GNE_SFA2_Brand_Aff_Edit_Create_Layout?objectId='+Account.Id+'&retURL=%2F'+Account.Id+'&saveURL=%2F'+Account.Id+'');
		productMetricsPage.setRedirect(true);
		return productMetricsPage;
	}
	
	public PageReference getProducts(){
		return null;
	}
	
	public String getAccountId() {
		return account.Id;
	}
	
	public String getRetUrl() {
		return pretUrl;
	}
	
	public String Molecule_Queue_ID{ 
		get{
			List<QueueSobject> sobjectList = [Select q.Queue.id from QueueSobject q where q.Queue.Name = 'GNE-MedAffairs-Molecule'];
			if(sobjectList == null || sobjectList.size() == 0){
				return null;
			}
			return sobjectList[0].Queue.id;
		} 
		set; 
	}

	public String Therapeutic_Area_Queue_ID{ 
		get{
			List<QueueSobject> sobjectList = [Select q.Queue.id from QueueSobject q where q.Queue.Name = 'GNE-MedAffairs-Queue'];
			return sobjectList[0].Queue.id;
		}
		set; 
	}
	
	public String AccountIdNewBrandAffiliation{ 
		get{
			return environment_var_val.get('AccountIdNewBrandAffiliation');
		} 
		set; 
	}

	public String AccountNameLabelNewBrandAffiliation{ 
		get{
			String result = environment_var_val.get('AccountNameLabelNewBrandAffiliation');
			return result;
		}
		set; 
	}

	public Boolean isEditDelVisible{ 
		get{
			Profile ProfileName = [Select p.Name from Profile p where p.id =:UserInfo.getProfileID()];
			if(ProfileName.Name == 'GNE-MedAffairs-MSL-Manager' || ProfileName.Name == 'GNE-MedAffairs-MCL-Manager' || ProfileName.Name == 'GNE-MedAffairs-SP'|| ProfileName.Name == 'GNE-MedAffairs-SP-Manager')
			return true;
			return false;
		}
		set; 
	}
	
}