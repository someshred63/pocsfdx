/******************************************************************************************
*  @author: Piotr Przesmycki, Roche
*  @email: piotr.przesmycki@contractors.roche.com   
*  Created: 2015-01-10
*  Project: EDM
*  Description: REST Webservice, returns a list of Event Curriculums with related Speker Bureaus.             
*******************************************************************************************/
@RestResource(urlMapping='/getEventCurriculums/*')
global with sharing class EDM_Get_EventCurriculums_gne {

	@HttpPost 
	global static iPhone_Commons_gne.RestResponse processRequest(String lastSyncDate) {
		//lastSyncDate will come always as PST, but iPhone_Commons_gne expects GMT
		if(String.isNotBlank(lastSyncDate)){
			lastSyncDate = convertToGMT(lastSyncDate);
		}
		return iPhone_Commons_gne.buildResponse(
			new GetAccountEventCurriculumsResponseBuilder(),
			new iPhone_Commons_gne.DefaultDeltaArgs(lastSyncDate, null, null)
		);                        
	} 
	  
	class GetAccountEventCurriculumsResponseBuilder extends iPhone_Commons_gne.DeltaRecordsResponseBuilder { 
		  
		protected override List<SObject> selectSObjects(iPhone_Commons_gne.DeltaArgs args) {
			return [SELECT Id, Name, CreatedDate, Description_gne__c, LastmodifiedDate, Aprimo_ID_gne__c, 
						Approval_Date_gne__c, Deactivation_Date_gne__c, Brands_gne__c, Previous_Regulatory_Code_gne__c,
						Curriculum_Status_gne__c, Target_Audience_gne__c, Speaker_Retraining_Required_gne__c,
						Material_Presentation_Type__c,
						(SELECT Speaker_Bureau_gne__r.Aprimo_Bureau_ID_gne__c FROM Curriculum_Speaker_Bureau_s__r),
						(SELECT Id, EDM_Brand__c, EDM_Brand_Indications__c FROM Event_Curriculum_Brands__r)
					FROM 
						Event_Curriculum_gne__c
					ORDER BY Name
					];
		}   
						
		protected override iPhone_Commons_gne.DeltaRecord getAsRecord(SObject sObj) {
			return new GetAccountEventCurriculumsRecord((Event_Curriculum_gne__c)sObj);                
		}
				 
	} 
		  
	class GetAccountEventCurriculumsRecord extends iPhone_Commons_gne.DeltaRecord {
		  
		public String id;          // Id
		public String nm;               //Description
		public String prc;                  // Aprimo_ID_gne__c
		public String ad;                   // Approval_Date_gne__c
		public String dd;                   // Deactivation_Date_gne__c
		public String pvrc;                 // Previous_Regulatory_Code_gne__c
		public String di;                   // Curriculum_Status_gne__c
		public String ta;                   // Target_Audience_gne__c
		public String sr;                   // Speaker_Retraining_Required_gne__c
		public List<String> sb;             // related Speaker Bureaus
		public String mpt;                  //Material_Presentation_Type__c
		public List<BrandWithIndications> brands; 
		
		public GetAccountEventCurriculumsRecord(Event_Curriculum_gne__c eventCurriculum) {
			this.id  = eventCurriculum.Id;
			this.nm = eventCurriculum.Description_gne__c;
			this.prc  = eventCurriculum.Aprimo_ID_gne__c;
			this.ad  = iPhone_StringUtil.getString(eventCurriculum.Approval_Date_gne__c);
			this.dd  = iPhone_StringUtil.getString(eventCurriculum.Deactivation_Date_gne__c);
			this.pvrc  = eventCurriculum.Previous_Regulatory_Code_gne__c;
			this.di  = eventCurriculum.Curriculum_Status_gne__c;
			this.ta  = eventCurriculum.Target_Audience_gne__c;
			this.sr  = eventCurriculum.Speaker_Retraining_Required_gne__c;
			this.sb  = getBureauAprimoIDList(eventCurriculum.Curriculum_Speaker_Bureau_s__r);			
			this.mpt = eventCurriculum.Material_Presentation_Type__c;
			this.brands = wrapBrandsWithIndications(eventCurriculum.Event_Curriculum_Brands__r);
		}

		private List<String> getBureauAprimoIDList(List<Curriculum_Speaker_Bureau_gne__c> bureaus) {
			List<String> result = new List<String>();
			if (bureaus != null) {
				for (Curriculum_Speaker_Bureau_gne__c speakerBureau : bureaus) {
					result.add(speakerBureau.Speaker_Bureau_gne__r.Aprimo_Bureau_ID_gne__c);
				}
			}
			return result;
		}

		private List<BrandWithIndications> wrapBrandsWithIndications(List<EDM_Event_Curriculum_Brand__c> brandList) {
			List<BrandWithIndications> result = new List<BrandWithIndications>();

			if (brandList != null) {
				for (EDM_Event_Curriculum_Brand__c bri : brandList) {
					BrandWithIndications wrappedBri = new BrandWithIndications();
					wrappedBri.Id = bri.Id;
					wrappedBri.brandName = bri.EDM_Brand__c;
					wrappedBri.indications = new List<String>();
					if (String.isNotBlank(bri.EDM_Brand_Indications__c)) {
						wrappedBri.indications = bri.EDM_Brand_Indications__c.split(';');
					}
					result.add(wrappedBri);
				}
			}

			return result;
		}
	}

	private static String convertToGMT(String pstDateTime){
		DateTime dt = DateTime.valueOf(pstDateTime);
		system.debug(pstDateTime + '->' + String.valueOfGmt(dt));
		return String.valueOfGmt(dt);
	}

	private class BrandWithIndications {
		public String Id;
		public String brandName;
		public List<String> indications;
	}
}