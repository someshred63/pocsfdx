/*************************************************************************************************
*  @author: Sebastian Karczmarski, Roche (contractor)
*  @email: sebastian.karczmarski@contractors.roche.com   
*  Created: 2013-05-24
*  Project: OTR2
*  Description: REST Webservice, returns force.com configuration (with details) information  
*  for specified user and object. The returned data comes from the rows (tables SFA2 Configuration 
*  Object and SFA2 Configuration Object Detail) marked as 'for OTR2' (flag 'OTR' equal 'true').            
**************************************************************************************************/
@RestResource(urlMapping='/iPhoneGetUserSFA2Config/*')
global with sharing class iPhone_Get_User_SFA2_Config_gne {
	
	@HttpPost 
    global static iPhone_Commons_gne.RestResponse processRequest(String unixId, String objectApiName) {      	    	    
    	
    	return iPhone_Commons_gne.buildResponse(
    		new GetUserSFA2ConfigResponseBuilder(), 
    		new GetUserSFA2ConfigResponseBuilderArg(unixId, objectApiName)
    	);       	    
    } 
    
    class GetUserSFA2ConfigResponseBuilder implements iPhone_Commons_gne.ResponseBuilder {
    	    	
    	public iPhone_Commons_gne.RestResponse build(Object arg) {
    		GetUserSFA2ConfigResponseBuilderArg builderArg = (GetUserSFA2ConfigResponseBuilderArg)arg;
    		
    		User user = iPhone_DAO.getUserByExternalId(builderArg.unixId);
			if(user == null)
				throw new iPhone_Commons_gne.IPhoneException('User not found: ' + builderArg.unixId); 
				 
			GNE_SFA2_User_App_Context_gne__c appCtx = new iPhone_Commons_gne.UserAppContextUtil().getAppCtx(user.id);    
			if(appCtx == null) {			
				return new GetUserSFA2ConfigResponse();		
			}  																		    			
			List<SFA2_Configuration_Object_gne__c> cfgObjects = iPhone_DAO.getUIConfigurationObjects(
																	builderArg.objectApiName, 
																	appCtx.App_Name_gne__c, 
																	appCtx.Brand_gne__c, 
																	appCtx.Role_gne__c
																);																
			List<SFA2_Configuration_Object_Detail_gne__c> cfgObjectsDetails = iPhone_DAO.getUIConfigurationObjectsDetails(cfgObjects);
			
			Map<Id, List<SFA2_Configuration_Object_Detail_gne__c>> cfgObjectId2cfgObjectDetailsMap = buildCfgObjectId2CfgObjectDetailsMap(
																											cfgObjects, 
																											cfgObjectsDetails
																									  );
    		return buildResponse(cfgObjects, cfgObjectId2cfgObjectDetailsMap);		    			
    	}
    	    	    	    
    	//	Builds a helper map to associate ConfigObjects and its ConfigObjectDetails: 
    	//	Map: [ConfigObjectId => List of Config Object Details>].    
    	private Map<Id, List<SFA2_Configuration_Object_Detail_gne__c>> buildCfgObjectId2CfgObjectDetailsMap(
    																		List<SFA2_Configuration_Object_gne__c> cfgObjects, 
    																		List<SFA2_Configuration_Object_Detail_gne__c> cfgObjectsDetails) {
    	 	//Initialize:
			Map<Id, List<SFA2_Configuration_Object_Detail_gne__c>> resultMap = new Map<Id, List<SFA2_Configuration_Object_Detail_gne__c>>();   					    		
			for(SFA2_Configuration_Object_gne__c cfgObject: cfgObjects) {
				resultMap.put(cfgObject.Id, new List<SFA2_Configuration_Object_Detail_gne__c>());
			}    		
    		//Fill up with a proper values:    	
    		for(SFA2_Configuration_Object_Detail_gne__c cfgObjectDetail: cfgObjectsDetails) {
    			Id cfgObjectId = cfgObjectDetail.Configuration_Object_ref_gne__c;    			
    			List<SFA2_Configuration_Object_Detail_gne__c> details = resultMap.get(cfgObjectId);
    			details.add(cfgObjectDetail);    			
    		}    		
    		return resultMap;
    	}
    	    
    	private iPhone_Commons_gne.RestResponse buildResponse(	
    												List<SFA2_Configuration_Object_gne__c> cfgObjects, 
    												Map<Id, List<SFA2_Configuration_Object_Detail_gne__c>> cfgObjectId2cfgObjectDetailsMap) {
    		//Build response structure:	
    		GetUserSFA2ConfigResponse response = new GetUserSFA2ConfigResponse();      					
			for(SFA2_Configuration_Object_gne__c cfgObject: cfgObjects) {				
				List<SFA2_Configuration_Object_Detail_gne__c> cfgObjectsDetails = cfgObjectId2cfgObjectDetailsMap.get(cfgObject.Id);
				//if(cfgObjectsDetails.size() > 0) {
					GetUserSFA2ConfigRecord cfgRecord = new GetUserSFA2ConfigRecord(cfgObject);
					for(SFA2_Configuration_Object_Detail_gne__c cfgObjectDetail: cfgObjectsDetails) {					 
						 cfgRecord.details.add(new GetUserSFA2ConfigDetailRecord(cfgObjectDetail));
					} 
					response.records.add(cfgRecord);
				//}
			}		
			return response; 		    		
    	} 
    }
    
    class GetUserSFA2ConfigResponseBuilderArg {
    	
    	final String unixId;
    	final String objectApiName;      
    
    	public GetUserSFA2ConfigResponseBuilderArg(String unixId, String objectApiName) {
    		this.unixId = unixId;     		
    		this.objectApiName = objectApiName;
    	}    	
    }
               
    class GetUserSFA2ConfigResponse extends iPhone_Commons_gne.RestResponse {
    	    	
    	public List<GetUserSFA2ConfigRecord> records = new List<GetUserSFA2ConfigRecord>();        	    	
    }
       
    class GetUserSFA2ConfigRecord {
    	    	    	
    	public String id;    
    	public String externalId;
    	public String sectionHeader; 
    	public String recordType;
    	public List<GetUserSFA2ConfigDetailRecord> details = new List<GetUserSFA2ConfigDetailRecord>();
    	 
    	public GetUserSFA2ConfigRecord(SFA2_Configuration_Object_gne__c cfgObject) {
    		this.id = cfgObject.Id;
    		this.externalId = cfgObject.External_ID_gne__c;
    		this.recordType = iPhone_StringUtil.getString(cfgObject.Record_Type_gne__c); 
    		this.sectionHeader = iPhone_StringUtil.getString(cfgObject.Section_Header_gne__c);    		
    	}    	      	    	    
    }
    
    class GetUserSFA2ConfigDetailRecord {
    
    	public String id;
    	public String apiName;
    	public String label;
    	public String isReadOnly;
    	public String isRequired;
    	public String type;
    	public String availabilityMode;
    	public String attributes;

    	public GetUserSFA2ConfigDetailRecord(SFA2_Configuration_Object_Detail_gne__c cfgObjectDetail) {    		    	
    		this.id = iPhone_StringUtil.getString(cfgObjectDetail.Id);
    		this.apiName = iPhone_StringUtil.getString(cfgObjectDetail.API_Name_gne__c); 
			this.label = iPhone_StringUtil.getString(cfgObjectDetail.Label_gne__c);
			this.isReadOnly = iPhone_StringUtil.getString(cfgObjectDetail.Is_Read_Only_gne__c); 
			this.isRequired = iPhone_StringUtil.getString(cfgObjectDetail.Is_Required_gne__c); 
			this.type = iPhone_StringUtil.getString(cfgObjectDetail.Type_gne__c);
			this.availabilityMode = iPhone_StringUtil.getString(cfgObjectDetail.Availability_Mode_gne__c);
			this.attributes = iPhone_StringUtil.getString(cfgObjectDetail.Attributes_gne__c);
    	}    	    	        	    	
    }        
}