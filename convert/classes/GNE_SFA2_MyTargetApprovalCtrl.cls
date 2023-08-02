public without sharing class GNE_SFA2_MyTargetApprovalCtrl {
    public Integer pageNumber {get; set;}
	public Integer recordsCount{get; set;}
	public Integer offset {get; set;}
    public static final Integer PAGE_SIZE = 50;
    public List<ViewWrapper> viewWrappers {get; set;}
    public String keyFromVfp {get;set;}
    
    private List<ViewWrapper> allViewWrappers {get; set;}
    private Map<String, ViewWrapper> key2Wrapper = new Map<String, ViewWrapper>();
    
    
	private Integer remainingOffset {get; set;}
    
    private SFA2_Configuration_Object_gne__c pageConfiguration;
    
    private static Map<String, Integer> order = new Map<String, Integer> {
        'SPR' => 1,
        'HI' => 2,
        'MED' => 3,
        'LOW' => 4,
        'PRS' => 5,
        'HCP' => 6
    };
    private static Map<String, Integer> accountTypeMultiplier = new Map<String, Integer> {
    	'Physician' => 10,
        'Pharmacist' => 20,
        'Nurse' => 30,
        'Nurse General' => 40,
        'Nurse Specialized' => 50
    };
            
    public GNE_SFA2_MyTargetApprovalCtrl() {
        pageConfiguration = GNE_SFA2_Util.getListPageConfiguration('Account_MyTarget');
        allViewWrappers = getAllRecordsOnInit();
        recordsCount = allViewWrappers.size();
        offset = 0;
		pageNumber = 1;
		remainingOffset = 0;
        
    }
    
    public String getActiveMenuItem() {
		String result = '';
		if(pageConfiguration != null && pageConfiguration.Attributes_gne__c!=null && pageConfiguration.Attributes_gne__c.contains('activeMenuItem')){
			result = pageConfiguration.Attributes_gne__c.substringBetween('activeMenuItem=',';');
		}
		return result;
	}
    
    public PageReference loadRecords() {
        allViewWrappers = getAllRecordsOnInit();
        recordsCount = allViewWrappers.size();
		offset = 0;
		pageNumber = 1;
		remainingOffset = 0;
		viewWrappers = getViewWrappers();

		return null;
	}
    
    private List<ViewWrapper> getAllRecordsOnInit() {
        List<ViewWrapper> result = new List<ViewWrapper>();
        Map<String, List<Targets_and_Tiers_can_gne__c>> key2Tat = new Map<String, List<Targets_and_Tiers_can_gne__c>>();
        Set<Id> accountIds = new Set<Id>();
        String managerId = UserInfo.getUserId();
        String shortManagerId = managerId.substring(0, 15);
        for(Targets_and_Tiers_can_gne__c tat :[
            SELECT Id,Account_can_gne__c, Account_can_gne__r.Specialties_can_gne__c, Account_can_gne__r.FirstName, Account_can_gne__r.LastName, Account_can_gne__r.Account_Type_gne__c,
                    Account_can_gne__r.Sub_Type_can_gne__c, Territory_gne__c, My_Target_gne__c, Product_Catalog_gne__c, Product_Catalog_gne__r.Name, Submitted_By_gne__c, Submitted_By_gne__r.Name,
                Segment_gne__c, Target_gne__c, Tier_can_gne__c, Access_Rating__c, HCO_Account__c, HCO_Account__r.Name
           	FROM Targets_and_Tiers_can_gne__c
           	WHERE Submiters_Manager_calc_gne__c = : managerId
                OR Submiters_Manager_calc_gne__c = : shortManagerId
            ORDER BY Submitted_By_gne__r.Name, Account_can_gne__r.LastName
        ]){
            String userTerrKey = tat.Submitted_By_gne__c + '_' + tat.Account_can_gne__c + '_' + tat.Territory_gne__c;
            List<Targets_and_Tiers_can_gne__c> tats = key2Tat.get(userTerrKey) == null ? new List<Targets_and_Tiers_can_gne__c>() : key2Tat.get(userTerrKey);
            tats.add(tat);
            key2Tat.put(userTerrKey, tats);
            accountIds.add(tat.Account_can_gne__c );
        }
        Map<Id, Integer> accountId2NumberOfInteraction = new Map<Id, Integer>();
        for(Call2_vod__c cv :[
            SELECT Account_vod__c 
            FROM Call2_vod__c
            WHERE Account_vod__c IN : accountIds
            	AND Date_of_Interaction_gne__c = THIS_YEAR
        ]){
            
            Integer numOfInter = accountId2NumberOfInteraction.get(cv.Account_vod__c) == null ? 1 : accountId2NumberOfInteraction.get(cv.Account_vod__c) + 1;
            accountId2NumberOfInteraction.put(cv.Account_vod__c, numOfInter);
            
        }
        for(String key :key2Tat.keySet()){
            String accountId = key.substringBetween('_');
            Integer ytdInteractions = accountId2NumberOfInteraction.get(accountId) == null ? 0 : accountId2NumberOfInteraction.get(accountId);
            ViewWrapper vw = new ViewWrapper(key, key2Tat.get(key), ytdInteractions);
            result.add(vw);
            key2Wrapper.put(key,vw);
        }
        result.sort();
        return result;
        
    }
    
    private List<ViewWrapper> getViewWrappers() {
        List<ViewWrapper> result = new List<ViewWrapper>();
        Integer maxIndex = offset + PAGE_SIZE > recordsCount ? recordsCount : offset + PAGE_SIZE;
        for(Integer x = offset; x < maxIndex; x++){
            result.add(allViewWrappers.get(x));
        }
        return result;
    }
    
    public Integer getPageNumbers(){
		if(recordsCount != null) {
			Integer pageNumber = Math.ceil(recordsCount / (PAGE_SIZE * 1.0)).intValue();
			return pageNumber < 1 ? 1 : pageNumber;
		}  else {
			return 1;
		}
	}

    public PageReference nextPage(){
		if(pageNumber == getPageNumbers()){
			return null;
		}
		pageNumber++;
		offset += PAGE_SIZE;
		viewWrappers = getViewWrappers();
		return null;
	}

	public PageReference previousPage(){
		if(pageNumber == 1){
			return null;
		}
		pageNumber--;
		offset -= PAGE_SIZE;
		viewWrappers = getViewWrappers();
		return null;
	}

	public Boolean getDisablePrevious(){
		return offset<=0;
	}

	public Boolean getDisableNext(){
		return pageNumber>=getPageNumbers();
	}
    
    public void approveRecord() {
        ViewWrapper vw = key2Wrapper.get(keyFromVfp);
        vw.processed = true;
        vw.approved = true;
    }
    
    public void rejectRecord() {
        ViewWrapper vw = key2Wrapper.get(keyFromVfp);
        vw.processed = true;
        vw.rejected = true;
    }
    
    public void submitRecords() {
        List<Targets_and_Tiers_can_gne__c> toUpdate = new List<Targets_and_Tiers_can_gne__c>();
        processApprovedRecord(toUpdate);
        processRejectedRecord(toUpdate);
        runDML(toUpdate);
    }
    
    private void processApprovedRecord(List<Targets_and_Tiers_can_gne__c> toUpdate) {
        for(ViewWrapper vw :key2Wrapper.values()){
            if(vw.approved){                
                for(Targets_and_Tiers_can_gne__c tat:vw.tats) {
                    tat.Target_gne__c = tat.My_Target_gne__c;
                    tat.Submitted_By_gne__c = null;
                    tat.Submitted_To_gne__c = null;
                    tat.Submitted_DataTime_gne__c = null;
                    toUpdate.add(tat);
                }          
            }            
        }        
    }
    
    private void processRejectedRecord(List<Targets_and_Tiers_can_gne__c> toUpdate) {
        for(ViewWrapper vw :key2Wrapper.values()){
            if(vw.rejected){                
                for(Targets_and_Tiers_can_gne__c tat:vw.tats) {
                    tat.My_Target_gne__c = tat.Target_gne__c;
                    tat.Submitted_By_gne__c = null;
                    tat.Submitted_To_gne__c = null;
                    tat.Submitted_DataTime_gne__c = null;
                    toUpdate.add(tat);
                }          
            }            
        } 
    }
    
    private void runDML(List<Targets_and_Tiers_can_gne__c> toUpdate) {
        update toUpdate;
    }

    
    public class ViewWrapper implements Comparable {
        public String key {get;set;}
        public String accountId {get;set;}
        public List<Targets_and_Tiers_can_gne__c> tats;
        public String firstName {get;set;}
        public String lastName {get;set;}
        public String hcoAccount {get;set;}
        public String product {get;set;}
        public String rocheTarget {get;set;}
        public String myTarget {get;set;}
        public String accessRating {get;set;}
        public String accountType {get;set;}
        public String accountSubType {get;set;}
        public String specialities {get;set;}
        public String submitedBy {get;set;}
        public Integer ytdInteractions {get; set;}
        public Boolean processed {get; set;}
        public Boolean approved {get; set;}
        public Boolean rejected {get; set;}
        private String firstRocheTarget;
        
        
        public ViewWrapper(String key, List<Targets_and_Tiers_can_gne__c> tats, Integer ytdInteractions){
            this.key = key;
            this.tats = tats;
            this.firstName = tats[0].Account_can_gne__r.FirstName;
            this.lastName = tats[0].Account_can_gne__r.LastName;   
            this.hcoAccount = tats[0].HCO_Account__r.Name;
            this.accessRating = tats[0].Access_Rating__c;
            this.submitedBy = tats[0].Submitted_By_gne__r.Name;
            this.ytdInteractions = ytdInteractions;
            this.accountType = tats[0].Account_can_gne__r.Account_Type_gne__c;
            this.accountSubType = tats[0].Account_can_gne__r.Sub_Type_can_gne__c;
            this.approved = false;
            this.rejected = false;
            
            this.firstRocheTarget  = tats[0].Target_gne__c != null ? tats[0].Target_gne__c : '';
            this.accountId = tats[0].Account_can_gne__c;
            this.processed = false;
            assignProductsAndTargets();      
            setSpecialities();
            
        }
        
        private void setSpecialities() {
            if(tats[0].Account_can_gne__r.Specialties_can_gne__c != null){
                String [] specs = tats[0].Account_can_gne__r.Specialties_can_gne__c.split(';');
                this.specialities = String.join(specs, '<BR/>');
            }
        }
        
        private void assignProductsAndTargets(){
            product = '';
            rocheTarget = '';
            myTarget = '';
            for(Targets_and_Tiers_can_gne__c tat: this.tats){
                if(String.isNotBlank(tat.Product_Catalog_gne__r.Name))this.product += tat.Product_Catalog_gne__r.Name + '<BR/>';
                if(String.isNotBlank(tat.Target_gne__c ))this.rocheTarget += tat.Target_gne__c + '<BR/>';
                if(String.isNotBlank(tat.My_Target_gne__c))this.myTarget += tat.My_Target_gne__c + '<BR/>';
            }
		}
        
        public Integer compareTo(Object obj) {
			ViewWrapper objToCompare = (ViewWrapper)obj;
			Integer objToCompareMultiplier = 60, currentObjMultiplier = 60;

			if(accountTypeMultiplier.containsKey(objToCompare.accountType)) 
				objToCompareMultiplier = accountTypeMultiplier.get(objToCompare.accountType);
			if(accountTypeMultiplier.containsKey(this.accountType))
				currentObjMultiplier = accountTypeMultiplier.get(this.accountType);	
			
			Integer rocheTargetPriority = getPriority(objToCompare.firstRocheTarget) == null? 0 : getPriority(objToCompare.firstRocheTarget) + objToCompareMultiplier;
            if(currentObjMultiplier == null)currentObjMultiplier = 50;
			Integer currentRocheTargetPriority = this.firstRocheTarget == null? 50: getPriority(this.firstRocheTarget) + currentObjMultiplier;      

			if(currentRocheTargetPriority < rocheTargetPriority) {
				return -1;
			} else if(currentRocheTargetPriority == rocheTargetPriority) {
				if(this.lastName > objToCompare.lastName) {
					return 1;
				} else {
					return 0;
				}
			}
			return 1;
		}
        
        private Integer getPriority(String rocheTarget) {
			if(order.containsKey(rocheTarget)) {
				return order.get(rocheTarget);
			} else {
				return 0;
			}
		}
    }
}