global class New_Event_Curriculum_WS {

	global class Messages {
		webservice String Status;
		webservice String Message;
	}

	global class New_Curriculum {
		webservice String PRC_Code;
		webservice String name;
		webservice String version_number;
		webservice String Speaker_bureau_IDs;// am receiving several ids
		webservice Date start_date;
		webservice Date Approval_date;
		webservice Date Deactivation_Date;
		webservice String prc_number;
		webservice String brands;
		webservice String Previous_Version_Regulatory_Code;
		webservice String Replaced_Asset_Regulatory_Code;
		webservice String Existing_T2E_Regulatory_Code;
		webservice String Target_Audience;
		webservice String Speaker_Retraining_Required;
		webservice String Disposition;
		webservice String SpeakerBureauCurriculum;
		webservice String brandsWithIndications;
	}

	webservice static Messages create_new_curriculum(New_Curriculum nc){
		/*Description of new logic:
		 *   Disposition    |   SpeakerBureauCurriculum    |    Speaker Bureau Id  |    Action on Curriculum
		 *      NEW  -> Y -> Yes -> insert/update + create training records if applicable /fill replacing/replaced by fields
		 *      NEW  -> N -> No action
		 *   UPDATE  -> Y -> Yes -> insert/update + create training records if applicable /fill replacing/replaced by fields
		 *   UPDATE  -> N -> Don't check -> set curriculum status to deleted + set training records if applicable status to deleted / remove replacing/replaced by fields / deleted curriculums should be hidden in UI
		 * WITHDRAW  -> Y -> Yes -> update + create training records 
		 * WITHDRAW  -> N -> No action
		 *    other  -> Y -> Yes -> insert/update + don't create training records /fill replacing/replaced by fields
		 *    other  -> N -> No action
		*/

		Boolean isInsert = true;
		Messages msg = new Messages();
		if(nc != null && nc.name != null){
			nc.name = em3_utils_2.getLocation(nc.name);
		}
		Event_Curriculum_gne__c curriculum = new Event_Curriculum_gne__c();
		if(nc.SpeakerBureauCurriculum == 'N' || nc.SpeakerBureauCurriculum == 'No'){
			if(nc.Disposition != 'Update'){
				msg.Status = 'SUCCESS';
				msg.Message = '';
				return msg;
			} else {
				return em3_utils.setCurriculumToDeletedStatus(nc, msg);
			}
		} else {
			Savepoint sp = Database.setSavepoint();
			try{
				if(nc.PRC_Code == null){
					msg.status='FAILURE';
					msg.message='ERROR: PRC CODE IS NULL'; //if the parent event has problems return e2 instead of e3
					Database.rollback( sp );
					return msg;
				}
				curriculum = em3_utils.ins_upd_Curriculum(nc, curriculum);
				if(curriculum.Id != null){
					isInsert = false;
				}
			} catch(Exception e){
				msg.status='FAILURE';
				msg.message='MODULES ERROR:'+e.getMessage(); //if the parent event has problems return e2 instead of e3
				Database.rollback( sp );
				return msg;
			}

			if(curriculum.Disposition_gne__c == 'WITHDRAW' && isInsert){
				msg.status='FAILURE';
				msg.message='WITHDRAW Disposition doesn\'t support insert operation';
				Database.rollback( sp );
				return msg;
			}
			//may not want to update this now - maybe after everything is successful
			try {
				upsert curriculum;
				remediateCurriculumBrands(curriculum, nc.brands, nc.brandsWithIndications);


			} catch(System.DmlException e){
				system.debug(e.getMessage());
				msg.status='FAILURE';
				msg.message='CURRICULUM ERROR:'+e.getMessage();
				Database.rollback( sp );
				return msg;
			}


			if(nc.Speaker_bureau_IDs != null){
				if(em3_utils.bureau_Check(nc)){
					System.debug('PASS');

					try{
						List<Curriculum_Speaker_Bureau_gne__c> curr_spk_bur = em3_utils.create_bur_relationships(nc,curriculum);

						if(curr_spk_bur.size() > 0){
							try{
								insert(curr_spk_bur);
							} catch(System.DmlException e){
								msg.status='FAILURE';
								msg.message='CURR SPK BUR ERROR:'+e.getMessage();
								Database.rollback( sp );
								return msg;
							}
						}

					} catch(Exception e){
						msg.status='FAILURE';
						msg.message='CREATE BUREAU ERROR:'+e.getMessage();
						Database.rollback( sp );
						return msg;
					}

				} else{
					System.debug('FAILED');
					msg.status='FAILURE';
					msg.message='BUREAU ERROR: CHECK FOR EXISTING BUREAU\'S FAILED'; //if the parent event has problems return e2 instead of e3
					Database.rollback( sp );
					return msg;
				}
			} else{
				System.debug('FAILED');
				msg.status='FAILURE';
				msg.message='ERROR: NO SPEAKER BUREAU ID'; //if the parent event has problems return e2 instead of e3
				Database.rollback( sp );
				return msg;
			}

			
			String previousPRC = em3_utils.getPreviousPRCCode(nc);
			if(previousPRC != ''){
				if(!em3_utils.checkIfPreviousPRCExists(previousPRC)){
					if (isInsert && (String.isBlank(curriculum.Description_gne__c) || '<Title Needed>'.equals(curriculum.Description_gne__c))) {
						em3_utils.sendCurriculumCreateEmail(curriculum.Id, nc.Speaker_bureau_IDs);
					}
					msg.status='FAILURE';
					msg.message='Previous curriculum PRC code not found';
					return msg;
				}
				try{
					if(curriculum.User_Defined_Predecessor_gne__c == false) {
						update em3_utils.upd_replacing_curr(previousPRC, curriculum.Aprimo_ID_gne__c);
					}
				} catch(Exception ex){
					msg.status='FAILURE';
					msg.message='UPDATE REPLACING/REPLACED BY ERROR:'+ex.getMessage();
					Database.rollback( sp );
					return msg;
				}

				if(curriculum.Speaker_Retraining_Required_gne__c == 'No' 
					&& (curriculum.Disposition_gne__c == 'New' || curriculum.Disposition_gne__c == 'Update' || curriculum.Disposition_gne__c == 'Withdraw')
					&& (curriculum.User_Defined_Predecessor_gne__c == false || curriculum.Previous_Version_Regulatory_Code_gne__c == previousPRC)) {
					try {
						List<Speaker_Training_gne__c> trainings = em3_utils.ins_trainings(curriculum, nc.Approval_date, previousPRC);
						if (trainings.size() > 0) {
							upsert trainings;							
						}
						System.enqueueJob(new EDM_CurriculumSuccessorCrawler(curriculum.Id));

					} catch(Exception e){
						msg.status='FAILURE';
						msg.message='SPEAKER TRAINING ERROR:'+e.getMessage();
						Database.rollback( sp );
						return msg;
					}
				} else if(curriculum.Disposition_gne__c == 'Withdraw'){
					try{
						em3_utils.updateTrainingRecords(curriculum);
					}catch(Exception e){
						msg.status='FAILURE';
						msg.message='SPEAKER TRAINING ERROR:'+e.getMessage();
						Database.rollback( sp );
						return msg;
					}
				}
			}
			
			if (isInsert && (String.isBlank(curriculum.Description_gne__c) || '<Title Needed>'.equals(curriculum.Description_gne__c))) {
				em3_utils.sendCurriculumCreateEmail(curriculum.Id, nc.Speaker_bureau_IDs);
			}
			
		}
		msg.Status = 'SUCCESS';
		msg.Message = '';
		return msg;
	}

	public static void remediateCurriculumBrands(Event_Curriculum_gne__c curriculum, String incomingBrandList, String brandsWithIndicationsJSON) {
		List<String> incomingBrands = new List<String>();
		if (String.isNotBlank(incomingBrandList)) {

			if(incomingBrandList.contains(';')) { 
				incomingBrands = incomingBrandList.split(';');
			}
			else if(incomingBrandList.contains(',')) {
				incomingBrands = incomingBrandList.split(',');
			}
			else {
				incomingBrands = new List<String>{incomingBrandList};
			}


			delete [SELECT Id FROM EDM_Event_Curriculum_Brand__c WHERE EDM_Parent_Curriculum__c = :curriculum.Id AND EDM_Brand__c NOT IN :incomingBrands];
			List<EDM_Event_Curriculum_Brand__c> curriculumBrands =  [SELECT Id, EDM_Brand__c, EDM_Brand_Indications__c FROM EDM_Event_Curriculum_Brand__c WHERE EDM_Parent_Curriculum__c = :curriculum.Id];
			Set<String> existingBrandsNames;

			if(brandsWithIndicationsJSON != null && brandsWithIndicationsJSON != '') {
				existingBrandsNames = getExistingBrandsSet(curriculumBrands);
				List<String> indicationsList;
				Map<String, List<String>> brandsWithIndications = (Map<String, List<String>>) JSON.deserialize(brandsWithIndicationsJSON,Map<String,List<String>>.class);
				for(EDM_Event_Curriculum_Brand__c curriculumBrand : curriculumBrands) {
					indicationsList = brandsWithIndications.get(curriculumBrand.EDM_Brand__c);
					String indications = String.join(indicationsList, ';');
					if(curriculumBrand.EDM_Brand_Indications__c == '' || curriculumBrand.EDM_Brand_Indications__c == null){
						curriculumBrand.EDM_Brand_Indications__c = indications;
					}
				}
				for(String brandName : incomingBrands) {
					if (!existingBrandsNames.contains(brandName)) {
						indicationsList = brandsWithIndications.get(brandName);
						String indications = String.join(indicationsList,';');
						curriculumBrands.add(new EDM_Event_Curriculum_Brand__c(EDM_Brand_Indications__c = indications, EDM_Parent_Curriculum__c = curriculum.Id, EDM_Brand__c = brandName));
					}
				}
			}
			else {
				existingBrandsNames = getExistingBrandsSet(curriculumBrands);
				for(String brandName : incomingBrands) {
					if(!existingBrandsNames.contains(brandName) ) {
						curriculumBrands.add(new EDM_Event_Curriculum_Brand__c(EDM_Parent_Curriculum__c = curriculum.Id, EDM_Brand__c = brandName));
					}
				}
			}
			upsert curriculumBrands;
		}
		else {
			delete [SELECT Id FROM EDM_Event_Curriculum_Brand__c WHERE EDM_Parent_Curriculum__c = :curriculum.Id];
		}

		if(isUnknownBrand(incomingBrands)) {
			sendUnknownBrandEmail(curriculum);
		}
	}

	private static Boolean isUnknownBrand(List<String> brands) {
		Integer existingBrandCount = [SELECT COUNT() FROM EDM_SBM_Brand_To_Indications_gne__c WHERE Name IN :brands];
		if(existingBrandCount == brands.size())
			return false;

		return true;
	}

	private static void sendUnknownBrandEmail(Event_Curriculum_gne__c curriculum) {
		List<String> toAddresses = new List<String>();
		List<String> ccAddresses = new List<String>();

		for(EDM_Unknown_Brand_Email_gne__c emailAddr : EDM_Unknown_Brand_Email_gne__c.getAll().values()) {
			toAddresses.add(emailAddr.ToAddress_gne__c);
			if(String.IsNotBlank(emailAddr.CcAddress_gne__c)) {
				for(String addr : emailAddr.CcAddress_gne__c.split(';'))
				ccAddresses.add(addr);
			}
		}

		EmailTemplate template = [SELECT Id, Name, Developername FROM EmailTemplate WHERE developername = 'EDM_Unknown_Curriculum_Brand' LIMIT 1];
		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

		email.setTargetObjectId(Userinfo.getUserId());
		email.setToAddresses(toAddresses);
		email.setWhatId(curriculum.Id);
		email.setTemplateId(template.Id);
		email.setSaveAsActivity(false);
		if(ccAddresses.size() > 0) {
			email.setCcAddresses(ccAddresses);
		}
		email.setSenderDisplayName('Salesforce');
		Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{
				email
		});
	}

	private static Set<String> getExistingBrandsSet(List<EDM_Event_Curriculum_Brand__c> brands) {
		Set<String> result = new Set<String>();
		for (EDM_Event_Curriculum_Brand__c brand : brands) {
			result.add(brand.EDM_Brand__c);
		}
		return result;
	}
}