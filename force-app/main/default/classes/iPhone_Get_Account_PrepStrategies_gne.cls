@RestResource(urlMapping='/iPhoneGetAccountPrepStrategies/*')
global with sharing class iPhone_Get_Account_PrepStrategies_gne {
	@HttpPost 
     global static iPhone_Commons_gne.RestResponse processRequest(String lastSyncDate, String unixId, List<String> accountIds, Boolean enhDelta, String otrVersion) {       
        return iPhone_Commons_gne.buildResponse(
                new GetAccountPrepStrategiesResponseBuilder(), 
                new iPhone_Commons_gne.DefaultDeltaArgs(lastSyncDate, unixId, accountIds, enhDelta, otrVersion)           
        );        
    } 

    class GetAccountPrepStrategiesResponseBuilder extends iPhone_Commons_gne.DeltaRecordsResponseBuilder { 
                                                        
        protected override List<SObject> selectSObjects(iPhone_Commons_gne.DeltaArgs args) {
            List<SFA2_PREP_Account_Testing_Strategy_gne__c> resultList = args.isEnhancedDelta() ? iPhone_DeltaDAO.getPrepStrategiesByAccountIds(args.accountIds, args.getLastSyncDate()) : iPhone_DAO.getPrepStrategiesByAccountIds(args.accountIds);
            
            if(!args.isEnhancedDelta()) {
	            for(SFA2_PREP_Account_Testing_Strategy_gne__c accStrategy : resultList) {
	            	xids.add(accStrategy.Id);
	            	
	            	for(SFA2_PREP_Account_MBO_gne__c mbo : accStrategy.Account_MBOs_gne__r) {
	            		xids.add(mbo.Id);
	            	}
	            }
            }
                     
            return resultList;
        }   
                            
        protected override iPhone_Commons_gne.DeltaRecord getAsRecord(SObject sObj) {
            return new GetAccountPrepStrategyRecord((SFA2_PREP_Account_Testing_Strategy_gne__c)sObj, (DeltaCalculator)deltaCalculator);                      
        }
        
        protected override iPhone_Commons_gne.DeltaCalculator getDeltaCalculator(String lastSyncDate){
        	return new DeltaCalculator(lastSyncDate);
        }               
    }
    
    class DeltaCalculator extends iPhone_Commons_gne.DeltaCalculator {
    	private Set<String> xids;
    	public DeltaCalculator(String lastSyncDate) {
    		super(lastSyncDate);
    		xids = new Set<String>();
    	}
    	
    	protected override String getDeltaStatus(SObject sObj) {
    		String result = super.getDeltaStatus(sObj);
    		
    		if(result == STAT_SYNC && sObj.getSObjectType() == SFA2_PREP_Account_Testing_Strategy_gne__c.sObjectType) {
    			SFA2_PREP_Account_Testing_Strategy_gne__c accStrategy = (SFA2_PREP_Account_Testing_Strategy_gne__c)sObj;
    		
    			for(SFA2_PREP_Account_MBO_gne__c mbo : accStrategy.Account_MBOs_gne__r) {
    				if(super.getDeltaStatus(mbo)!=STAT_SYNC) {
    					result = STAT_UPDATE;
    				}
    			}
    		}
    		
    		return result;
    	}
    }
    
    public virtual class GetAccountPrepStrategyRecord extends iPhone_Commons_gne.DeltaRecord {          
        public String at;  // Account_gne__c
        public String tsi; // Testing_Strategy_gne__c
        public String nm; // Testing_Strategy_gne__r.Name
        public String st; // Status_gne__c
        public List<MboWrapper> mbos; // Account_MBOs_gne__r
        
        public GetAccountPrepStrategyRecord() {}
        
        public GetAccountPrepStrategyRecord(SFA2_PREP_Account_Testing_Strategy_gne__c accStrategy, DeltaCalculator deltaCalculator) {
            this.id  = accStrategy.Id;
            this.tsi = iPhone_StringUtil.getString(accStrategy.Testing_Strategy_gne__c);            
            this.at  = iPhone_StringUtil.getString(accStrategy.Account_gne__c);
            this.nm  = accStrategy.Testing_Strategy_gne__r!=null ? iPhone_StringUtil.getString(accStrategy.Testing_Strategy_gne__r.Name) : null;
            this.st  = iPhone_StringUtil.getString(accStrategy.Status_gne__c);
            
            this.mbos = new List<MboWrapper>();
            
            for(SFA2_PREP_Account_MBO_gne__c mbo : accStrategy.Account_MBOs_gne__r) {
            	String mboDeltaStatus;
            		
            	if((mboDeltaStatus=deltaCalculator.getDeltaStatus(mbo))!=deltaCalculator.STAT_SYNC) {
            		MboWrapper mboWrap = new MboWrapper(mbo);
            		mboWrap.ax = mboDeltaStatus;
            		mbos.add(mboWrap);
            	}
            }
        }
    }
    
    public virtual class MboWrapper extends iPhone_Commons_gne.DeltaRecord {
    	public String atsi;
    	public String id;
    	public String mboi;
    	public String nm;
    	public String st;
    	
    	public MboWrapper() {}
    	
    	public MboWrapper(SFA2_PREP_Account_MBO_gne__c mbo) {
    		this.id = mbo.Id;
    		this.atsi = iPhone_StringUtil.getString(mbo.Account_Testing_Strategy_gne__c);
    		this.mboi = iPhone_StringUtil.getString(mbo.MBO_gne__c);
    		this.nm = mbo.MBO_gne__r!=null ? iPhone_StringUtil.getString(mbo.MBO_gne__r.Name) : null;
    		this.st = iPhone_StringUtil.getString(mbo.Status_gne__c); 
    	}
    }
}