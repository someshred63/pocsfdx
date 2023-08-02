/******************************************************************************************
*  @author: Sebastian Karczmarski, Roche (contractor)
*  @email: sebastian.karczmarski@contractors.roche.com
*  Created: 2013-05-24
*  Project: OTR2
*  Description: REST Webservice, returns a description of picklists used in Call2,
*  Call2Discussion and Affiliation tables.
*  Modified By Bartosz Osowiecki on 2015-06-10 (changed main approach on how to get dependent picklist values)
*******************************************************************************************/
@RestResource(urlMapping = '/iPhoneGetUserPicklists/*')
global with sharing class iPhone_Get_User_Picklists_gne {

	@HttpPost
	global static iPhone_Commons_gne.RestResponse processRequest() {
		return iPhone_Commons_gne.buildResponse(
		           new GetUserPicklistsResponseBuilder(),
		           null
		       );
	}

	class GetUserPicklistsResponseBuilder implements iPhone_Commons_gne.ResponseBuilder {

		final Base64BitsUtil base64BitsUtil = new Base64BitsUtil();
		private User currentUser;

		public iPhone_Commons_gne.RestResponse build(Object arg) {
			GetUserPicklistsResponse response = new GetUserPicklistsResponse();
			setCurrentUser();
			if (GNE_SFA2_Util.isBrandUser()) {
				setupAccountResponse(response);
				setupDataChangeRequestResponse(response);
				setupHCPSpecialtyCall2RequestResponse(response);
            } else if(GNE_SFA2_Util.isGneINFUUser()){
                setupCall2Response(response);
                setupDataChangeRequestResponse(response);
            } else {
				setupAccountResponse(response);
				setupAffiliationResponse(response);
				setupCall2Response(response);
				setupCall2DiscussionResponse(response);
				setupDataChangeRequestResponse(response);
				setupTestingInfoRequestResponse(response);
				setupAccountMembershipsRequestResponse(response);
				setupCall2PreCall(response);
				setupContact(response);
				setupCall2InteractionDetailResponse(response);
				setupCall2CategoryResponse(response);
                if (GNE_SFA2_Util.isAMUser()) {
                    setupCall2ThreatResponse(response);
                }
			}
            if(!GNE_SFA2_Util.isCanadaUser() )
            response.ecoSystemCodes	= getEcoSystemCodeItems();

			return response;
		}

		private void setCurrentUser() {
			if (currentUser == null) {
				currentUser = [SELECT Id, Profile.Name FROM User WHERE Id = :UserInfo.getUserID()];
			}
		}

		private User getCurrentUser() {
			return currentUser;
		}

		private List<PicklistItem> getPicklistValues(Schema.SObjectField sObjectField) {
			List<PicklistItem> result = new List<PicklistItem>();
			Schema.DescribeFieldResult fieldDescribe = sObjectField.getDescribe();
			List<Schema.PicklistEntry> picklistValues = fieldDescribe.getPicklistValues();
			Schema.sObjectField controllingField = fieldDescribe.getController();

			if (controllingField == null && picklistValues != null) {
				for (Schema.PicklistEntry ple : picklistValues) {
					if (ple.isActive()) {
						result.add(new PicklistItem(ple.getValue()));
					}
				}
			} else if (controllingField != null && picklistValues != null) {
				Schema.DescribeFieldResult ctrFieldDescribe = controllingField.getDescribe();

				List<String> ctrValues = new List<String>();
				List<String> ctrAllValues = new List<String>();

				if (ctrFieldDescribe.getType() == Schema.DisplayType.Picklist) {
					List<Schema.PicklistEntry> ctrPicklistValues = ctrFieldDescribe.getPicklistValues();

					for (Schema.PicklistEntry ple : ctrPicklistValues) {
						if (ple.isActive()) {
							ctrValues.add(ple.getValue());
						}
						ctrAllValues.add(ple.getValue());
					}
				} else if (ctrFieldDescribe.getType() == Schema.DisplayType.Boolean) {
					ctrValues.addAll(new List<String> {'False', 'True'});
					ctrAllValues.addAll(ctrValues);
				}

				Map<String, List<String>> ctr2depMap = new Map<String, List<String>>();
				for (String ctrValue : ctrValues) {
					ctr2depMap.put(ctrValue, new List<String>());
				}

				List<PicklistEntryWrapper> pleWrappers = (List<PicklistEntryWrapper>)JSON.deserialize(JSON.serialize(picklistValues), List<PicklistEntryWrapper>.class);

				for (PicklistEntryWrapper pleWrapper : pleWrappers) {
					if (pleWrapper.active) {
						List<Integer> ctrIndexes = this.base64BitsUtil.getNonZeroBits(pleWrapper.validFor);
						List<String> ctrMatchingValues = selectControllingValues(ctrIndexes, ctrAllValues);

						for (String ctrValue : ctrMatchingValues) {
							List<String> depValues = ctr2depMap.get(ctrValue);
							depValues.add(pleWrapper.value);
						}
					}
				}

				for (String ctrValue : ctrValues) {
					List<String> depValues = ctr2depMap.get(ctrValue);
					result.add(new DependentPicklistItem(ctrValue, depValues));
				}
			}

			return result;
		}

		private List<String> selectControllingValues(List<Integer> ctrIndexes, List<String> ctrAllValues) {
			List<String> result = new List<String>();

			for (Integer index : ctrIndexes) {
				String val = ctrAllValues[index];
				result.add(val);
			}

			return result;
		}

		private void setupAccountResponse(GetUserPicklistsResponse response) {
			response.suffix = getPicklistValues(Account.Suffix_vod__c);
			response.groupValues = getAccountGroupItems();
			
		}

		private void setupDataChangeRequestResponse(GetUserPicklistsResponse response) {
			response.reasonDcr                  = getPicklistValues(Change_Request_gne__c.Reason_dcr_gne__c);
			response.removeInactivateAddressDcr = getPicklistValues(Change_Request_gne__c.Remove_Inactive_Address_gne__c);
			response.hcpSpecialtiesDcr          = getPicklistValues(Change_Request_gne__c.Specialties_HCP_DCR_gne__c);
			response.credentialsDcr             = getPicklistValues(Change_Request_gne__c.Credentials_DCR_gne__c);
			response.accountTypeDcr             = getOrgTypesDcr();
			response.professionalTypeDcr        = getProfTypesDcr();
			response.statusDcr                  = getPicklistValues(Change_Request_gne__c.Status_gne__c);
			response.licenseDesignationDcr      = getPicklistValues(Change_Request_gne__c.License_Designation_gne__c);
		}

		private List<PicklistItem> getOrgTypesDcr() {
			List<PicklistItem> result = new List<PicklistItem>();
			List<String> orgTypeValues = new List<String>(GNE_SFA2_AccountDCRController.getOrgTypesMap().keyset());
			orgTypeValues.sort();
			for (String iValue : orgTypeValues) {
				result.add(new PicklistItem(iValue));
			}
			return result;
		}

		private List<PicklistItem> getProfTypesDcr() {
			List<PicklistItem> result = new List<PicklistItem>();
			List<String> profTypeValues = new List<String>(GNE_SFA2_AccountDCRController.getProfTypesMap().keyset());
			profTypeValues.sort();
			for (String iValue : profTypeValues) {
				result.add(new PicklistItem(iValue));
			}
			return result;
		}

		private List<PicklistItem> getContactProfTypesFrm() {
			List<PicklistItem> result = new List<PicklistItem>();
			List<Schema.PicklistEntry> pickListValues = Contact.Professional_Type_2_frm_gne__c.getDescribe().getPicklistValues();
			List<String> profTypeValues = new List<String>();
        	for (Schema.PicklistEntry pickListItem : pickListValues){
        		profTypeValues.add(pickListItem.getValue());
        	}
			profTypeValues.sort();
			for (String iValue : profTypeValues) {
				result.add(new PicklistItem(iValue));
			}
			return result;
		}

		private void setupAffiliationResponse(GetUserPicklistsResponse response) {
			response.affiliationTypes = getPicklistValues(Affiliation_vod__c.Affiliation_Type_gne__c);
			response.affiliationRoles = getPicklistValues(Affiliation_vod__c.Role_vod__c);
			response.affiliationInfluences = getPicklistValues(Affiliation_vod__c.Influence_vod__c);
		}

		private void setupCall2PreCall(GetUserPicklistsResponse response) {
			Set<Id>productIds = new Set<Id>();
			List<PicklistItem>segments = new List<PicklistItem>();
			for (Product_vod__c prod : iPhone_DAO.getUserSetupProducts(UserInfo.getUserID())) {
				productIds.add(prod.id);
			}
			response.interactionObjectives = getPreCallObjectiveItems(productIds);
			response.decisionCycle = getPicklistValues(Call_Pre_Call_gne__c.Decision_Cycle_gne__c);
			response.preCallQuestions =  getPreCallQuestionItems();
		}

		private void setupCall2Response(GetUserPicklistsResponse response) {
			response.interactionTypes         = getPicklistValues(Call2_vod__c.Interaction_Type_gne__c);
			response.interactionLocations     = getPicklistValues(Call2_vod__c.Interaction_Location_gne__c);
			response.interactionMethods       = getPicklistValues(Call2_vod__c.Interaction_Method_gne__c);
			response.resolutions              = getPicklistValues(Call2_vod__c.Resolution_gne__c);
			response.speakerPrograms          = getPicklistValues(Call2_vod__c.Speaker_Program_gne__c);
			response.primaryInteractionReason = getPicklistValues(Call2_vod__c.Primary_Interaction_Reason_gne__c);
			response.visitReasons             = getPicklistValues(Call2_vod__c.Visit_Reason_gne__c);
			response.interactionLength        = getPicklistValues(Call2_vod__c.Interaction_Length_gne__c);
			response.interactionColab         = getPicklistValues(Call2_vod__c.Collaboration_gne__c);
			response.interactionAbout         = getPicklistValues(Call2_vod__c.PREP_About_gne__c);
			response.referralSource           = getPicklistValues(Call2_vod__c.Referral_Source_gne__c);
			if (GNE_SFA2_Util.isFrmUser() || GNE_SFA2_Util.isCrmFrmUser()) {
				response.groupCallWith        = getPicklistValues(Call2_vod__c.Group_Call_with_gne__c);
			}
			if (GNE_SFA2_Util.isCanadaRAMA()) {				
				response.accessEchos		  = getPicklistValues(Call2_vod__c.Access_Echo_Alignment_RAMA_gne__c);
				response.groups			      = getPicklistValues(Call2_vod__c.Group_RAMA_gne__c);
			}
            if (GNE_SFA2_Util.isAMUser()) {
                response.probabilityCall          = getPicklistValues(Call2_vod__c.Probability__c);
            }
            if(GNE_SFA2_Util.isGneINFUUser()) {
                response.callBusinessSponsor = IRecordLtng.getBusinessSponsorStatusesApex() ;  
            }
		}

		private void setupCall2DiscussionResponse(GetUserPicklistsResponse response) {
			response.topics                          = getPicklistValues(Call2_Discussion_vod__c.Topic_gne__c);
			response.moleculesInTherapeuticAreas     = getPicklistValues(Call2_Discussion_vod__c.Molecule_gne__c);
			response.currentIssuesInTherapeuticAreas = getPicklistValues(Call2_Discussion_vod__c.Current_Issue_gne__c);
			response.activities                      = getPicklistValues(Call2_Discussion_vod__c.Activity_gne__c);
			response.reaction                        = getPicklistValues(Call2_Discussion_vod__c.Reaction_gne__c);
            response.reason                          = getPicklistValues(Call2_Discussion_vod__c.Reason_gne__c);
			response.nonProviderGroup 				 = getPicklistValues(Call2_Discussion_vod__c.Non_provider_Group__c);
			response.patientJourney 				 = getPicklistValues(Call2_Discussion_vod__c.Patient_Journey_F2F_or_Virtual__c);
			response.patientInteractionNumber 		 = getPicklistValues(Call2_Discussion_vod__c.Patient_Interaction_F2F_or_Virtual__c);
			
            if (GNE_SFA2_Util.isAMUser()) {
                //response.crmMeetingObjectiveCallDisc     = getPredefinedPicklistValues('GNE_MCCO_AM::Call2_Discussion_vod__c::CRM_Meeting_Objective__c::CRM_Tactic__c');
                response.crmWhenCallDisc                 = getPicklistValues(Call2_Discussion_vod__c.CRM_When__c);
                response.crmImpactCallDisc               = getPicklistValues(Call2_Discussion_vod__c.CRM_Impact__c);
                response.crmMarketingMaterialCallDisc    = getPicklistValues(Call2_Discussion_vod__c.CRM_Marketing_Material__c);
                response.crmValue                        = getPicklistValues(Call2_Discussion_vod__c.CRM_Value__c);
            }		
			if (GNE_SFA2_Util.isFrmUser()) {
				response.frmStatus                   = getPicklistValues(Call2_Discussion_vod__c.FRM_Issue_Status__c);
			}
            if(GNE_SFA2_Util.isCrmFrmUser()) {
                response.frmTriagedTo = getPicklistValues(Call2_Discussion_vod__c.FRM_Triaged_To_gne__c);
                response.deckUsed = getPicklistValues(Call2_Discussion_vod__c.FRM_Deck_Used_gne__c);
                for (PicklistItem pi : response.deckUsed) {
                    if (pi.value == 'CRM' && pi instanceof DependentPicklistItem) {
                        DependentPicklistItem dpi = (DependentPicklistItem)pi;
                        response.deckUsed = dpi.childrenList;
                    }
                }
            }

			User user = getCurrentUser();
			String profileName = user.Profile.Name.toUpperCase();
			Pattern frmPattern = Pattern.compile('GNE-MCCO-FRM-(\\w+FRM)-{0,1}\\w*');
			Matcher frmMatcher = frmPattern.matcher(profileName);
			if (frmMatcher.find()) {
				String frmTeam = frmMatcher.group(1);
				response.frmTriagedTo = getPicklistValues(Call2_Discussion_vod__c.FRM_Triaged_To_gne__c);
				response.deckUsed = getPicklistValues(Call2_Discussion_vod__c.FRM_Deck_Used_gne__c);

				if (frmTeam != null) {
					for (PicklistItem pi : response.deckUsed) {
						if (pi.value == frmTeam && pi instanceof DependentPicklistItem) {
							DependentPicklistItem dpi = (DependentPicklistItem)pi;
							response.deckUsed = dpi.childrenList;
						}
					}
				}
			}
		}

        private void setupCall2ThreatResponse(GetUserPicklistsResponse response) {
            response.bookOfBusinessThreat    = getPicklistValues(Call2_Threat_vod__c.Book_of_Business__c);    
            response.requestedPositionThreat = getPicklistValues(Call2_Threat_vod__c.Requested_Position__c); 
            response.rebateThreat            = getPicklistValues(Call2_Threat_vod__c.Rebate__c);           
            response.riskLevelThreat         = getPicklistValues(Call2_Threat_vod__c.Risk_Level__c);       
            response.initialAssessmentThreat = getPicklistValues(Call2_Threat_vod__c.Initial_Assessment__c);             
        }

		private void setupContact(GetUserPicklistsResponse response) {
			response.contactProfessionalTypeFrm = getContactProfTypesFrm();
		}

		private void setupTestingInfoRequestResponse(GetUserPicklistsResponse response) {
			response.tType         = getPicklistValues(SFA2_PREP_Account_Testing_Info_gne__c.Test_Type_gne__c);
			response.tMethod       = getPicklistValues(SFA2_PREP_Account_Testing_Info_gne__c.Test_Method_gne__c);
			response.tComponent    = getPicklistValues(SFA2_PREP_Account_Testing_Info_gne__c.Test_Component_gne__c);
			response.tHierarchy    = getPicklistValues(SFA2_PREP_Account_Testing_Info_gne__c.Test_Hierarchy_gne__c);
			response.tStageTested  = getPicklistValues(SFA2_PREP_Account_Testing_Info_gne__c.Stage_Tested_gne__c);
			response.tInitiator    = getPicklistValues(SFA2_PREP_Account_Testing_Info_gne__c.Test_Initiator_gne__c);
			response.tMdtLeadTitle = getPicklistValues(SFA2_PREP_Account_Testing_Info_gne__c.MDT_Lead_Title_gne__c);
		}

		private void setupAccountMembershipsRequestResponse(GetUserPicklistsResponse response) {
			response.aMembership = getPicklistValues(SFA2_Account_Society_Membership_gne__c.Membership_Name_gne__c);
		}

		private void setupHCPSpecialtyCall2RequestResponse(GetUserPicklistsResponse response) {
			response.hcpSpecialty = new List<PicklistItem>();
			User user = getCurrentUser();
			if (GNE_SFA2_PFG_Util.isHCPSpecActiveForUser(user.Id)) {
				Set<String> brandNames = GNE_SFA2_PFG_Util.getUserInHCPSpecBrands(user.Id);
				for (PicklistItem pi : getPicklistValues(Call2_vod__c.HCP_Specialty_gne__c)) {
					if (brandNames.contains(pi.value)) {
						if (pi instanceof DependentPicklistItem) {
							response.hcpSpecialty.addAll(((DependentPicklistItem)pi).childrenList);
							break;
						}
					}
				}
			}
		}

		private void setupCall2InteractionDetailResponse(GetUserPicklistsResponse response) {
			if (GNE_SFA2_Util.isCanadaSAMUser()) {
				response.callVisitReasons           = getPicklistValues(Call2_Interaction_Detail_vod__c.Visit_Reason_vod__c);
				response.strategyObjectiveTactic    = getPicklistValues(Call2_Interaction_Detail_vod__c.Tactic_vod__c);
				response.conferenceType      		= getPicklistValues(Call2_Interaction_Detail_vod__c.Type_vod__c);
				response.typeName					= getPicklistValues(Call2_Interaction_Detail_vod__c.Name_vod__c);
			}
			if (GNE_SFA2_Util.isCanadaRAMA()) {
				response.strategies			        = getPicklistValues(Call2_Interaction_Detail_vod__c.Strategy_RAMA_vod__c);
				response.tactic  			        = getPicklistValues(Call2_Interaction_Detail_vod__c.Tactic_RAMA_vod__c);
				response.tools 						= getToolItems();
				response.therapeuticAreas 			= getTherapeuticsAreaItems();
				response.brandName					= getBrandNameItems();
			}
		}

		private void setupCall2CategoryResponse(GetUserPicklistsResponse response) {
			if (GNE_SFA2_Util.isCanadaRAMA()) {
				response.nocStatus		        = getPicklistValues(Call2_Category_vod__c.NOC_Status_gne__c);
				response.molecule				= getPicklistValues(Call2_Category_vod__c.Molecule_gne__c);
				response.indication				= getPicklistValues(Call2_Category_vod__c.Indication_gne__c);
			}
		}

		private List<DependentPicklistItem> getPreCallObjectiveItems(Set<Id>productIds) {
			List<Call_Objective_gne__c>callObjectives = [SELECT  Name, Product_gne__c, Product_gne__r.Name FROM Call_Objective_gne__c WHERE Product_gne__c in :productIds ORDER BY Name];
			Map<Id, List<String>>productToPicklistList = new Map<Id, List<String>>();
			List<DependentPicklistItem>result = new List<DependentPicklistItem>();
			for (Call_Objective_gne__c objective : callObjectives) {
				if (!productToPicklistList.containsKey(objective.Product_gne__c)) {
					productToPicklistList.put(objective.Product_gne__c, new List<String>());
				}
				productToPicklistList.get(objective.Product_gne__c).add(objective.Name);
			}
			for (Id productId : productToPicklistList.keySet()) {
				result.add(new DependentPicklistItem((String)productId, productToPicklistList.get(productId)));
			}
			return result;
		}

		private List<PicklistItem> getPreCallQuestionItems() {
			List<Pre_Call_Question_gne__c>questions = [SELECT  Name, Category_gne__c, Question_gne__c FROM Pre_Call_Question_gne__c ORDER BY Category_gne__c, Name];
			List<GroupPicklistItem>result = new List<GroupPicklistItem>();
			for (Pre_Call_Question_gne__c question : questions) {
				result.add(new GroupPicklistItem(question.Question_gne__c, question.Category_gne__c));
			}
			return result;
		}

		private List<PicklistItem> getAccountGroupItems() {
			List<PicklistItem> result = new List<PicklistItem>();
			for(Account_Group_gne__c accGroup : [SELECT Name FROM Account_Group_gne__c ORDER BY Name]) {
				result.add(new PicklistItem(accGroup.Name));
			}

			return result;
		}

		private List<PicklistItem> getToolItems() {
			List<PicklistItem> result = new List<PicklistItem>();			
	        for(Product_vod__c tool : [SELECT Id, Name FROM Product_vod__c WHERE Parent_Product_vod__r.Name = 'Brand/Above Brand - RAMA only' AND Parent_Product_vod__r.Region_Code_gne__c = 2 and active__c = true]) {
	            result.add(new PicklistItem(tool.Name));
	        }		

			return result;
		}

		private List<PicklistItem> getTherapeuticsAreaItems() {
			List<PicklistItem> result = new List<PicklistItem>();			
	        for(Product_vod__c area : [SELECT Id, Name FROM Product_vod__c WHERE Region_Code_gne__c = 2 AND Product_Type_vod__c = 'Detail' AND  Therapeutic_Area_vod__c <> null AND active__c = true ORDER BY Name]) {
	            result.add(new PicklistItem(area.Name));
	        }		

			return result;
		}

		private List<PicklistItem> getBrandNameItems() {
			List<PicklistItem> result = new List<PicklistItem>();			
	        for(Product_vod__c item : [SELECT Id, Name FROM Product_vod__c WHERE Region_Code_gne__c = 2 AND Product_Type_vod__c = 'Detail' AND  Therapeutic_Area_vod__c = null AND active__c = true ORDER BY Name]) {
	            result.add(new PicklistItem(item.Name));
	        }		

			return result;
		}
        
        private List<GroupPicklistItem> getEcoSystemCodeItems() {    
            List<GroupPicklistItem> result = new List<GroupPicklistItem>();
            for(AggregateResult ar : [SELECT ECO_CD_gne__c, ECO_Name_gne__c FROM Ecosystem_Details_gne__c WHERE Is_Valid_gne__c = true GROUP BY ECO_CD_gne__c, ECO_Name_gne__c]) {
                result.add(new GroupPicklistItem(String.valueOf(ar.get('ECO_CD_gne__c')) , String.valueOf(ar.get('ECO_Name_gne__c'))));
            } 

			return  result;
		}
        
	}
    
    private class DependencySerialize {
        private List<String> children;
        private String value;
	}

	public class GetUserPicklistsResponse extends iPhone_Commons_gne.RestResponse {
		public List<PicklistItem> affiliationTypes;           // Affiliation_vod_c.Affiliation_Type_gne__c
		public List<PicklistItem> affiliationRoles;           // Affiliation_vod_c.Role_vod_c
		public List<PicklistItem> affiliationInfluences;           // Affiliation_vod_c.Influence_vod__c
		public List<PicklistItem> interactionTypes;         // Call2_vod_c.Interaction_Type_gne_c
		public List<PicklistItem> interactionLocations;       // Call2_vod_c.Interaction_Location_gne_c
		public List<PicklistItem> interactionMethods;         // Call2_vod_c.Interaction_Method_gne_c
		public List<PicklistItem> resolutions;            // Call2_vod_c.Resolution_gne_c
		public List<PicklistItem> responseTimes;            // Call2_vod_c.FRM_Response_Time_gne_c
		public List<PicklistItem> speakerPrograms;          // Call2_vod_c.Speaker_Program_gne_c
		public List<PicklistItem> primaryInteractionReason;     // Call2_vod_c.Primary_Interaction_Reason_gne_c
		public List<PicklistItem> referralSource;           // Call2_vod_c.Referral_Source_gne__c
		public List<PicklistItem> hcpSpecialty;           // Call2_vod__c.HCP_Specialty_gne__c
        public List<PicklistItem> probabilityCall;//Call2_vod__c.Probability__c
        public List<PicklistItem> callBusinessSponsor;           // Call2_vod__c.Business_Sponsor_gne__c

		public List<PicklistItem> visitReasons;           // Call2_vod_c.Visit_Reason_gnec depndend on Call2_vodc.Primary_Interaction_Reason_gne_c
		public List<PicklistItem> activities;             // Call2_Discussion_vod__c.Activity_gne__c depends on Event_gne__c
		public List<PicklistItem> topics;               // Call2_Discussion_vod__c.Topic_gne__c depends on zvod_Product_Map_vod__c  REPACKED !!!
		public List<PicklistItem> moleculesInTherapeuticAreas;    // Call2_Discussion_vod_c.Molecule_gne_c depends on zvod_Product_Map_vod__c
		public List<PicklistItem> currentIssuesInTherapeuticAreas;  // Call2_Discussion_vod_c.Current_Issue_gne__c depends on zvod_Product_Map_vod__c
		public List<PicklistItem> deckUsed;             // Call2_Discussion_vod__c.FRM_Deck_Used_gne__c
		public List<PicklistItem> frmTriagedTo;           // Call2_Discussion_vod__c.FRM_Triaged_To_gne__c
		public List<PicklistItem> reaction;             // Call2_Discussion_vod__c.Reaction_gne__c
        public List<PicklistItem> reason;               // Call2_Discussion_vod__c.Reason_gne__c depends on Call2_Discussion_vod__c.Reaction_gne__c
		public List<PicklistItem> nonProviderGroup;    // Call2_Discussion_vod__c.Non_provider_Group__c
		public List<PicklistItem> patientJourney; 	// Call2_Discussion_vod__c.Patient_Journey_F2F_or_Virtual__c
		public List<PicklistItem> patientInteractionNumber; 	// Call2_Discussion_vod__c.Patient_Interaction_F2F_or_Virtual__c
        public List<PicklistItem> crmMeetingObjectiveCallDisc;  //Call2_Discussion_vod__c.CRM_Meeting_Objective__c
        public List<PicklistItem> tacticCallDisc;               //Call2_Discussion_vod__c.CRM_Tactic__c
        public List<PicklistItem> crmWhenCallDisc;              //Call2_Discussion_vod__c.CRM_When__c
        public List<PicklistItem> crmImpactCallDisc;            //Call2_Discussion_vod__c.CRM_Impact__c
        public List<PicklistItem> crmMarketingMaterialCallDisc; //Call2_Discussion_vod__c.CRM_Marketing_Material__c
        public List<PicklistItem> crmValue;                     //Call2_Discussion_vod__c.CRM_Value__c

		public List<PicklistItem> suffix;                  // Account.Suffix_vod__c
		public List<PicklistItem> groupValues;                  // Account.Group_gne__c
		
		public List<PicklistItem> reasonDcr;              // Change_Request_gne__c.Reason_dcr_gne__c
		public List<PicklistItem> removeInactivateAddressDcr;     // Change_Request_gne__c.Remove_Inactive_Address_gne__c
		public List<PicklistItem> accountTypeDcr;           // Change_Request_gne__c.Account_Type_DCR_gne__c
		public List<PicklistItem> professionalTypeDcr;        // Change_Request_gne__c.Professional_Type_DCR_gne__c
		public List<PicklistItem> statusDcr;              // Change_Request_gne__c.Status_gne__c
		public List<PicklistItem> licenseDesignationDcr;        // Change_Request_gne__c.License_Designation_gne__c
		public List<PicklistItem> credentialsDcr;           // Change_Request_gne__c.Credentials_DCR_gne__c
		public List<PicklistItem> hcpspecialtiesDcr;          // Change_Request_gne__c.Specialties_HCP_DCR_gne__c

		public List<PicklistItem> tType;                              // SFA2_PREP_Account_Testing_Info_gne__c.Test_Type_gne__c
		public List<PicklistItem> tMethod;                            // SFA2_PREP_Account_Testing_Info_gne__c.Test_Method_gne__c
		public List<PicklistItem> tComponent;                         // SFA2_PREP_Account_Testing_Info_gne__c.Test_Component_gne__c
		public List<PicklistItem> tHierarchy;                         // SFA2_PREP_Account_Testing_Info_gne__c.Test_Hierarchy_gne__c
		public List<PicklistItem> tStageTested;                       // SFA2_PREP_Account_Testing_Info_gne__c.Stage_Tested_gne__c
		public List<PicklistItem> tInitiator;                         // SFA2_PREP_Account_Testing_Info_gne__c.Test_Initiator_gne__c
		public List<PicklistItem> tMdtLeadTitle;                      // SFA2_PREP_Account_Testing_Info_gne__c.MDT_Lead_Title_gne__c
		public List<PicklistItem> aMembership;                        // SFA2_Account_Society_Membership_gne__c.Membership_Name_gne__c
		public List<PicklistItem> interactionLength;                  // Call2_vod__c.Interaction_Length_gne__c
		public List<PicklistItem> interactionColab;                   // Call2_vod__c.Collaboration_gne__c
		public List<PicklistItem> interactionAbout;                   // Call2_vod__c.PREP_About_gne__c

		public List<PicklistItem> interactionObjectives;              // Call_Pre_Call_gne__c.Interaction_Objectives_gne__c
		public List<PicklistItem> decisionCycle;                      // Call_Pre_Call_gne__c.Decision_Cycle_gne__c
		public List<PicklistItem> preCallQuestions;                   // Call_Pre_Call_gne__c.Questions_gne__c

		public List<PicklistItem> groupCallWith;                      // Call2_vod__c.Group_Call_with_gne__c
		public List<PicklistItem> frmStatus;                   // Call2_Discussion_vod__c.FRM_Issue_Status__c
		public List<PicklistItem> contactProfessionalTypeFrm;

		public List<PicklistItem> callVisitReasons;
		public List<PicklistItem> strategyObjectiveTactic;
		public List<PicklistItem> conferenceType;
		public List<PicklistItem> typeName;
		public List<PicklistItem> tools;
		public List<PicklistItem> strategies;	
		public List<PicklistItem> therapeuticAreas;
		public List<PicklistItem> accessEchos;
		public List<PicklistItem> groups;
		public List<PicklistItem> nocStatus;
		public List<PicklistItem> tactic;
		public List<PicklistItem> molecule;
		public List<PicklistItem> indication;
		public List<PicklistItem> brandName;
        
        public List<PicklistItem> bookOfBusinessThreat;    //Call2_Threat_vod__c.Book_of_Business__c
        public List<PicklistItem> requestedPositionThreat; //Call2_Threat_vod__c.Requested_Position__c
        public List<PicklistItem> rebateThreat;            //Call2_Threat_vod__c.Rebate__c
        public List<PicklistItem> riskLevelThreat;         //Call2_Threat_vod__c.Risk_Level__c
        public List<PicklistItem> initialAssessmentThreat; //Call2_Threat_vod__c.Initial_Assessment__c
        public List<GroupPicklistItem> ecoSystemCodes; // Ecosystem_gne__c table
	}

	public class GroupPicklistItem extends PicklistItem {
		private String category;

		private GroupPicklistItem(String value, String category) {
			super(value);
			this.category = category;
		}
	}

	private class DependentPicklistItem extends PicklistItem {
		private List<String> children;
		public List<PicklistItem> childrenList;

		private DependentPicklistItem(String value, List<String> children) {
			super(value);
			this.children = children;
			this.childrenList = getChildren();
		}

		private List<PicklistItem> getChildren() {
			List<PicklistItem> result = new List<PicklistItem>();
			if (this.children != null && !this.children.isEmpty()) {
				for (String childValue : this.children) {
					result.add(new PicklistItem(childValue));
				}
			}
			return result;
		}
	}

	public virtual class PicklistItem {
        @AuraEnabled
		public String value;

		public PicklistItem(String value) {
			this.value = value;
		}
	}

	private class PicklistEntryWrapper {
		private Boolean active;
		private Boolean defaultValue;
		private String value;
		private String label;
		private String validFor;
	}

	private class Base64BitsUtil {
		Map<String, List<Integer>> b64NonZeroBits = new Map<String, List<Integer>>();

		private Base64BitsUtil() {
			b64NonZeroBits.put('A', new List<Integer> {});
			b64NonZeroBits.put('B', new List<Integer> {5});
			b64NonZeroBits.put('C', new List<Integer> {4});
			b64NonZeroBits.put('D', new List<Integer> {4, 5});
			b64NonZeroBits.put('E', new List<Integer> {3});
			b64NonZeroBits.put('F', new List<Integer> {3, 5});
			b64NonZeroBits.put('G', new List<Integer> {3, 4});
			b64NonZeroBits.put('H', new List<Integer> {3, 4, 5});
			b64NonZeroBits.put('I', new List<Integer> {2});
			b64NonZeroBits.put('J', new List<Integer> {2, 5});
			b64NonZeroBits.put('K', new List<Integer> {2, 4});
			b64NonZeroBits.put('L', new List<Integer> {2, 4, 5});
			b64NonZeroBits.put('M', new List<Integer> {2, 3});
			b64NonZeroBits.put('N', new List<Integer> {2, 3, 5});
			b64NonZeroBits.put('O', new List<Integer> {2, 3, 4});
			b64NonZeroBits.put('P', new List<Integer> {2, 3, 4, 5});
			b64NonZeroBits.put('Q', new List<Integer> {1});
			b64NonZeroBits.put('R', new List<Integer> {1, 5});
			b64NonZeroBits.put('S', new List<Integer> {1, 4});
			b64NonZeroBits.put('T', new List<Integer> {1, 4, 5});
			b64NonZeroBits.put('U', new List<Integer> {1, 3});
			b64NonZeroBits.put('V', new List<Integer> {1, 3, 5});
			b64NonZeroBits.put('W', new List<Integer> {1, 3, 4});
			b64NonZeroBits.put('X', new List<Integer> {1, 3, 4, 5});
			b64NonZeroBits.put('Y', new List<Integer> {1, 2});
			b64NonZeroBits.put('Z', new List<Integer> {1, 2, 5});
			b64NonZeroBits.put('a', new List<Integer> {1, 2, 4});
			b64NonZeroBits.put('b', new List<Integer> {1, 2, 4, 5});
			b64NonZeroBits.put('c', new List<Integer> {1, 2, 3});
			b64NonZeroBits.put('d', new List<Integer> {1, 2, 3, 5});
			b64NonZeroBits.put('e', new List<Integer> {1, 2, 3, 4});
			b64NonZeroBits.put('f', new List<Integer> {1, 2, 3, 4, 5});
			b64NonZeroBits.put('g', new List<Integer> {0});
			b64NonZeroBits.put('h', new List<Integer> {0, 5});
			b64NonZeroBits.put('i', new List<Integer> {0, 4});
			b64NonZeroBits.put('j', new List<Integer> {0, 4, 5});
			b64NonZeroBits.put('k', new List<Integer> {0, 3});
			b64NonZeroBits.put('l', new List<Integer> {0, 3, 5});
			b64NonZeroBits.put('m', new List<Integer> {0, 3, 4});
			b64NonZeroBits.put('n', new List<Integer> {0, 3, 4, 5});
			b64NonZeroBits.put('o', new List<Integer> {0, 2});
			b64NonZeroBits.put('p', new List<Integer> {0, 2, 5});
			b64NonZeroBits.put('q', new List<Integer> {0, 2, 4});
			b64NonZeroBits.put('r', new List<Integer> {0, 2, 4, 5});
			b64NonZeroBits.put('s', new List<Integer> {0, 2, 3});
			b64NonZeroBits.put('t', new List<Integer> {0, 2, 3, 5});
			b64NonZeroBits.put('u', new List<Integer> {0, 2, 3, 4});
			b64NonZeroBits.put('v', new List<Integer> {0, 2, 3, 4, 5});
			b64NonZeroBits.put('w', new List<Integer> {0, 1});
			b64NonZeroBits.put('x', new List<Integer> {0, 1, 5});
			b64NonZeroBits.put('y', new List<Integer> {0, 1, 4});
			b64NonZeroBits.put('z', new List<Integer> {0, 1, 4, 5});
			b64NonZeroBits.put('0', new List<Integer> {0, 1, 3});
			b64NonZeroBits.put('1', new List<Integer> {0, 1, 3, 5});
			b64NonZeroBits.put('2', new List<Integer> {0, 1, 3, 4});
			b64NonZeroBits.put('3', new List<Integer> {0, 1, 3, 4, 5});
			b64NonZeroBits.put('4', new List<Integer> {0, 1, 2});
			b64NonZeroBits.put('5', new List<Integer> {0, 1, 2, 5});
			b64NonZeroBits.put('6', new List<Integer> {0, 1, 2, 4});
			b64NonZeroBits.put('7', new List<Integer> {0, 1, 2, 4, 5});
			b64NonZeroBits.put('8', new List<Integer> {0, 1, 2, 3});
			b64NonZeroBits.put('9', new List<Integer> {0, 1, 2, 3, 5});
			b64NonZeroBits.put('+', new List<Integer> {0, 1, 2, 3, 4});
			b64NonZeroBits.put('/', new List<Integer> {0, 1, 2, 3, 4, 5});
		}

		private List<Integer> getNonZeroBits(String str) {
			List<Integer> result = new List<Integer>();

			if (str == null) {
				return result;
			}

			for (Integer charIndex = 0; charIndex < str.length(); charIndex++) {
				String character = str.substring(charIndex, charIndex + 1);
				List<Integer> bits = b64NonZeroBits.get(character);
				Integer shift = charIndex * 6;

				for (Integer bit : bits) {
					result.add(bit + shift);
				}
			}

			return result;
		}
	}
}