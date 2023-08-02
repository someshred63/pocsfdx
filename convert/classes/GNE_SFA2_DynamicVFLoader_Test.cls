/************************************************************
*  @author: Piotr Przesmycki
*  Date: 2014-03-11
*  Description: This is a test class for GNE_SFA2_DynamicVFLoader class
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
@isTest
private class GNE_SFA2_DynamicVFLoader_Test {

	@testSetup
	static void initData() {
		List<User> usersToInsertList = new List<User>{
			new User(
					ProfileId = [SELECT Id FROM Profile WHERE Name = :'GNE-Field' LIMIT 1].Id,
					TimeZoneSidKey = 'America/Los_Angeles',
					Email = 'us@gene.com',
					FirstName = 'usUser',
					External_ID_gne__c = 'ustest',
					Alias = 'ustest',
					Username = 'UsTest@gene.com',
					EmailEncodingKey = 'UTF-8',
					LanguageLocaleKey = 'en_US',
					LocaleSidKey = 'en_US',
					LastName = 'User',
					IsActive = true
			)
		};

		insert usersToInsertList;

	}

	public static testMethod void testInit(){
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('testName');
		insert acc;
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController(acc);
		GNE_SFA2_Account_Ext controller = new GNE_SFA2_Account_Ext(stdCtrl);
		system.assertNotEquals(null, controller.myObject);
		system.assertEquals(acc.Id, controller.myObject.Id);
		system.assertEquals('', controller.recordTypeName);

		Test.setCurrentPageReference(Page.GNE_SFA2_Account_Layout);

		PageReference pr = controller.init();
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_Exception_Layout'), 'Wrong URL');
		system.assertEquals(true, pr.getRedirect());
		system.assertEquals('Layout configuration records not found.', pr.getParameters().get('exMessage'));
        system.assertEquals(Apexpages.currentPage().getUrl(), pr.getParameters().get('exUrl'));
        system.assertEquals('', controller.getActiveMenuItem());

        createConfiguration('SFA-US', 'CS');

        pr = controller.init();
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_Exception_Layout'), 'Wrong URL');
		system.assertEquals(true, pr.getRedirect());
		system.assertEquals('Layout configuration records not found.', pr.getParameters().get('exMessage'));
        system.assertEquals(Apexpages.currentPage().getUrl(), pr.getParameters().get('exUrl'));
        system.assertEquals('', controller.getActiveMenuItem());

        insert new GNE_SFA2_User_App_Context_gne__c(SFA2_Mode_gne__c = true, App_Name_gne__c = 'SFA-US', Role_gne__c = 'CS');
        pr = controller.init();
		system.assertEquals(null, pr);
        system.assertEquals('My Accounts', controller.getActiveMenuItem());
        system.assertEquals(4, controller.fieldSetHeadings.keySet().size());
        Set<String> sectionHeaders = new Set<String>();
        sectionHeaders.addAll(controller.fieldSetHeadings.values());
        system.assert(sectionHeaders.contains('Account Information'));
        system.assert(sectionHeaders.contains('System Information'));
        system.assert(sectionHeaders.contains(null));
        Id relatedLists;

        List<SFA2_Configuration_Object_gne__c> configs = GNE_SFA2_DynamicVFLoader.getUIConfigurationObjects(GNE_SFA2_Util.getUserApplicationContext(), 'Account', null);
        Map<String, Id> sectionHeadersToId = new Map<String,Id>();
        for(SFA2_Configuration_Object_gne__c config : configs){
        	if(config.Section_Header_gne__c!=null){
        		sectionHeadersToId.put(config.Section_Header_gne__c, config.Id);
        	} else {
        		if(config.Name == 'Account_rl'){
        			relatedLists = config.Id;
        		}
        	}
        }
        List<SFA2_Configuration_Object_Detail_gne__c> detailsList = controller.fieldSetMap.get(sectionHeadersToId.get('Account Information'));
        Set<String> validLabels = new Set<String>{'Account Name','Account Owner','Parent Account','Account Record Type','Account Type','Website'};
        system.assertEquals(validLabels.size(), detailsList.size());
        for(SFA2_Configuration_Object_Detail_gne__c detail : detailsList){
        	system.assert(validLabels.contains(detail.Label_gne__c), 'invalid label: '+detail.Label_gne__c);
        }
       

        detailsList = controller.fieldSetMap.get(sectionHeadersToId.get('System Information'));
        validLabels = new Set<String>{'Created By','Last Modified By'};
        system.assertEquals(validLabels.size(), detailsList.size());
        for(SFA2_Configuration_Object_Detail_gne__c detail : detailsList){
        	system.assert(validLabels.contains(detail.Label_gne__c), 'invalid label: '+detail.Label_gne__c);
        }

        List<String> fieldsWithRelationApiNames = new List<String>{'OwnerId', 'CreatedById', 'LastModifiedById'};
        for(String fieldName : fieldsWithRelationApiNames){
        	system.assertNotEquals(null, controller.fieldOfUserReferenceMap.get(fieldName));
        	system.assertEquals(true, controller.userReferenceHasExist.get(fieldName));
        	system.assertEquals(false, controller.groupReferenceHasExist.get(fieldName));
        }

        system.assertEquals(null, controller.fieldOfUserReferenceMap.get('RecordType.Name'));
        system.assertEquals(false, controller.userReferenceHasExist.get('RecordType.Name'));
        system.assertEquals(null, controller.groupReferenceHasExist.get('RecordType.Name'));

        List<String> fieldsWithoutRelationApiNames = new List<String>{'Name', 'Account_Type_gne__c', 'Website', 'ParentId'};
        for(String fieldName : fieldsWithoutRelationApiNames){
        	system.assertEquals(null, controller.fieldOfUserReferenceMap.get(fieldName));
        	system.assertEquals(false, controller.userReferenceHasExist.get(fieldName));
        	system.assertEquals(false, controller.groupReferenceHasExist.get(fieldName));
        }

        system.assertEquals(1, controller.relatedFieldSetList.size());
        system.assertEquals(1, controller.relatedFieldSetMap.keySet().size());
        detailsList = controller.relatedFieldSetMap.get(relatedLists);
        system.assertEquals(5, detailsList.size());
        Set<String> relatedListsApiNames = new Set<String>{'Call2_vod__c', 'Address_vod__c', 'Contact', 'AccountTeamMember', 'Affiliation_vod__c'};
        for(SFA2_Configuration_Object_Detail_gne__c detail : detailsList){
        	system.assert(relatedListsApiNames.contains(detail.API_Name_gne__c));
        	GNE_SFA2_RL_Component_AttributesWrapper wraper = new GNE_SFA2_RL_Component_AttributesWrapper(detail.Attributes_gne__c);
        	wraper.urlForNewRecord+='?objectId=' + acc.Id + '&';
        	system.assertEquals(wraper.fieldsCSV, controller.relatedListAttributes.get(detail.API_Name_gne__c).fieldsCSV);
			system.assertEquals(wraper.filter, controller.relatedListAttributes.get(detail.API_Name_gne__c).filter);
			system.assertEquals(wraper.orderByFieldName, controller.relatedListAttributes.get(detail.API_Name_gne__c).orderByFieldName);
			system.assertEquals(wraper.hideEditLink, controller.relatedListAttributes.get(detail.API_Name_gne__c).hideEditLink);
			system.assertEquals(wraper.hideDeleteLink, controller.relatedListAttributes.get(detail.API_Name_gne__c).hideDeleteLink);
			system.assertEquals(wraper.urlForNewRecord, controller.relatedListAttributes.get(detail.API_Name_gne__c).urlForNewRecord);
			system.assertEquals(wraper.urlForViewRecord, controller.relatedListAttributes.get(detail.API_Name_gne__c).urlForViewRecord);
			system.assertEquals(wraper.pageSize, controller.relatedListAttributes.get(detail.API_Name_gne__c).pageSize);
			system.assertEquals(wraper.recordsLimit, controller.relatedListAttributes.get(detail.API_Name_gne__c).recordsLimit);
			system.assertEquals(wraper.parentFieldName, controller.relatedListAttributes.get(detail.API_Name_gne__c).parentFieldName);
			system.assertEquals(wraper.hideButtons, controller.relatedListAttributes.get(detail.API_Name_gne__c).hideButtons);
			system.assertEquals(wraper.sortDirection, controller.relatedListAttributes.get(detail.API_Name_gne__c).sortDirection);
			system.assertEquals(wraper.onClickButtonsMap, controller.relatedListAttributes.get(detail.API_Name_gne__c).onClickButtonsMap);
			system.assertEquals(wraper.immediateButtonsMap, controller.relatedListAttributes.get(detail.API_Name_gne__c).immediateButtonsMap);
			system.assertEquals(wraper.rerenderButtonsMap, controller.relatedListAttributes.get(detail.API_Name_gne__c).rerenderButtonsMap);
			system.assertEquals(wraper.actionButtonsMap, controller.relatedListAttributes.get(detail.API_Name_gne__c).actionButtonsMap);
			system.assertEquals(wraper.customButtonsList, controller.relatedListAttributes.get(detail.API_Name_gne__c).customButtonsList);
			system.assertEquals(wraper.urlParametersMap, controller.relatedListAttributes.get(detail.API_Name_gne__c).urlParametersMap);
        }   

        system.assertEquals(null, controller.listRendered);
        system.assertEquals(null, controller.showRelatedList());
        system.assertEquals(true, controller.listRendered);

        system.assertEquals(null, controller.userIdToViewLink);
        controller.userIdToViewLink = UserInfo.getUserId();
        pr = controller.overrideUserViewLink();
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_User_Layout'), 'Wrong URL');
		system.assertEquals(true, pr.getRedirect());
        system.assertEquals(UserInfo.getUserId(), pr.getParameters().get('Id'));
	}

	public static testMethod void testCustomButtons(){
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('testName');
		insert acc;
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController(acc);
		GNE_SFA2_Account_Ext controller = new GNE_SFA2_Account_Ext(stdCtrl);
	
		insert new GNE_SFA2_User_App_Context_gne__c(SFA2_Mode_gne__c = true, App_Name_gne__c = 'SFA-US', Role_gne__c = 'CS');
        createConfiguration('SFA-US', 'CS');

		Component.Apex.PageBlockButtons buttons = controller.getCustomButtons();
        system.assertEquals('top', buttons.location);
        List<ApexPages.Component> buttonsList = buttons.childComponents;
        system.assertEquals(3, buttonsList.size());
        Map<String, Component.Apex.CommandButton> buttonLabelToButton = new Map<String, Component.Apex.CommandButton>();
        for(ApexPages.Component cb :buttonsList){
        	Component.Apex.CommandButton commandButton = (Component.Apex.CommandButton) cb;
        	buttonLabelToButton.put(String.valueOf(commandButton.value),  commandButton);
        	system.assertEquals(false, commandButton.disabled);
        	system.assertEquals(null, commandButton.style);
        }

        String profileName = GNE_SFA2_Util.getCurrentUserProfileName();

        Component.Apex.CommandButton buttonBeingTested = buttonLabelToButton.get('View Attachments');
        system.assertEquals('view-Attachments', buttonBeingTested.id);
        system.assertEquals('#{viewAttachmentsClick}', buttonBeingTested.action.getExpression());
        system.assertEquals('image-button sfa-plh sfa-plh-action-bar button', buttonBeingTested.styleClass);
        system.assertEquals(null, buttonBeingTested.dir);
        system.assertEquals('test' + profileName, buttonBeingTested.onclick);
        system.assertEquals(new Set<String>{null}, buttonBeingTested.rerender);
        system.assertEquals(true, buttonBeingTested.immediate);

        buttonBeingTested = buttonLabelToButton.get('Plan/ Record an Interaction');
        system.assertEquals(null, buttonBeingTested.id);
        system.assertEquals('#{recordACallClick}', buttonBeingTested.action.getExpression());
        system.assertEquals('image-button sfa-plh sfa-plh-action-bar', buttonBeingTested.styleClass);
        system.assertEquals('img/icon-interact.png', buttonBeingTested.dir);
        system.assertEquals(null, buttonBeingTested.onclick);
        system.assertEquals(new Set<String>{null}, buttonBeingTested.rerender);
        system.assertEquals(false, buttonBeingTested.immediate);

        buttonBeingTested = buttonLabelToButton.get('Edit');
        system.assertEquals(null, buttonBeingTested.id);
        system.assertEquals('#{edit}', buttonBeingTested.action.getExpression());
        system.assertEquals('button sfa-plh sfa-plh-title-bar', buttonBeingTested.styleClass);
        system.assertEquals(null, buttonBeingTested.dir);
        system.assertEquals('doNothing', buttonBeingTested.onclick);
        system.assertEquals(new Set<String>{'main-content','test'}, buttonBeingTested.rerender);
        system.assertEquals(false, buttonBeingTested.immediate);

        system.assertEquals(null, controller.refreshCustomButtons());
	}

	public static testMethod void testShareEditDelete(){
		Account acc = GNE_SFA2_Triggers_Test_Util.prepareAccountHCO('testName');
		insert acc;
		ApexPages.StandardController stdCtrl = new ApexPages.StandardController(acc);
		GNE_SFA2_Account_Ext controller = new GNE_SFA2_Account_Ext(stdCtrl);
	
		insert new GNE_SFA2_User_App_Context_gne__c(SFA2_Mode_gne__c = true, App_Name_gne__c = 'SFA-US', Role_gne__c = 'CS');
        createConfiguration('SFA-US', 'CS');

        PageReference pr = controller.shareClick();
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_Record_Sharing'), 'Wrong URL');
		system.assertEquals(true, pr.getRedirect());
		system.assertEquals(acc.Id, pr.getParameters().get('parentId'));

		pr = controller.editClick(acc.Id, '/apex/GNE_SFA2_Account_Edit_Create_Layout');
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_Account_Edit_Create_Layout'), 'Wrong URL');
		system.assertEquals(true, pr.getRedirect());
		system.assertEquals(acc.Id, pr.getParameters().get('id'));

		User u = selectSFA2User();
		system.runAs(u){
			pr = controller.editClick(acc.Id, '/apex/GNE_SFA2_Account_Edit_Create_Layout');
			PageReference accessDenied = Page.GNE_SFA2_Access_Denied;
			system.assert(pr.getUrl().contains(accessDenied.getUrl()), 'expected: '+accessDenied.getUrl()+', actual: '+pr.getUrl());
			system.assertEquals(true, pr.getRedirect());
		
			pr = controller.deleteClick();
			system.assert(pr.getUrl().contains(accessDenied.getUrl()));
		}

		
		pr = controller.deleteClick();
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_MyAccounts'), 'Wrong URL');
		system.assertEquals(true, pr.getRedirect());

		system.assertEquals(null, controller.deleteClick());

		Time_Off_Territory_gne__c tot = GNE_SFA2_Triggers_Test_Util.prepareTime_Off_Territory_gne();
		insert tot;
		stdCtrl = new ApexPages.StandardController(tot);
		GNE_SFA2_ToT_Ext controllerToT = new GNE_SFA2_ToT_Ext(stdCtrl);

		pr = controllerToT.deleteClick();
		system.assert(pr.getUrl().contains('/apex/GNE_SFA2_Time_Off_Territory'), 'Wrong URL');
		system.assertEquals(true, pr.getRedirect());
	}

	private static void createConfiguration(String appType, String role){

		List<SFA2_Configuration_Object_gne__c> configurationObjects = new List<SFA2_Configuration_Object_gne__c>();
		
		List<SFA2_Configuration_Object_gne__c> accountInformationList 	= new List<SFA2_Configuration_Object_gne__c>();
		List<SFA2_Configuration_Object_gne__c> systemInformationList 	= new List<SFA2_Configuration_Object_gne__c>();
		List<SFA2_Configuration_Object_gne__c> relatedListList 			= new List<SFA2_Configuration_Object_gne__c>();
		List<SFA2_Configuration_Object_gne__c> buttonsList 				= new List<SFA2_Configuration_Object_gne__c>();
		
		SFA2_Configuration_Object_gne__c accountInformation;
		SFA2_Configuration_Object_gne__c systemInformation;
		SFA2_Configuration_Object_gne__c relatedList;
		SFA2_Configuration_Object_gne__c buttons;
		
		Integer ord = 0;
		
		ord = 0;
		accountInformation = new SFA2_Configuration_Object_gne__c(
			Name = 'Account_detail',
			Order_gne__c = ord++,
			Section_Header_gne__c = 'Account Information'
		);
		accountInformationList.add(accountInformation);
		configurationObjects.add(accountInformation);
			
		systemInformation = new SFA2_Configuration_Object_gne__c(
			Name = 'Account_detail',
			Order_gne__c = ord++,
			Section_Header_gne__c = 'System Information'
		);
		systemInformationList.add(systemInformation);
		configurationObjects.add(systemInformation);
			
		relatedList = new SFA2_Configuration_Object_gne__c(
			Name = 'Account_rl',
			Order_gne__c = 0.0,
			Section_Header_gne__c = null
		);
		relatedListList.add(relatedList);
		configurationObjects.add(relatedList);
			
		buttons = new SFA2_Configuration_Object_gne__c(
			Name = 'Account_buttons',
			Order_gne__c = 0.0,
			Section_Header_gne__c = null
		);
		buttonsList.add(buttons);
		configurationObjects.add(buttons);
		
		for(SFA2_Configuration_Object_gne__c confObj : configurationObjects) {
			confObj.Application_Type__c 			= appType;
			confObj.Role_gne__c  					= role;
			confObj.Object_Name_gne__c  			= 'Account';
			confObj.Configuration_Type_gne__c 		= 'Page';
			confObj.Is_Active_gne__c  				= true;
		}
		
		insert configurationObjects;
		
		List<SFA2_Configuration_Object_Detail_gne__c> configurationObjectDetails = new List<SFA2_Configuration_Object_Detail_gne__c>();
		SFA2_Configuration_Object_Detail_gne__c detail;
		
		for(SFA2_Configuration_Object_gne__c accInf : accountInformationList) {
			ord = 0;
			configurationObjectDetails.add(
				new SFA2_Configuration_Object_Detail_gne__c(
					Configuration_Object_ref_gne__c = accInf.Id,
					Order_gne__c 				= ord++,
					Label_gne__c 				= 'Account Name',
					API_Name_gne__c 			= 'Name',
					Name 						= 'Name',
					Availability_Mode_gne__c 	= 'New;Edit;View',
					Type_gne__c 				= 'Field',
					Is_Required_gne__c 			= true,
					Is_Read_Only_gne__c 		= false
				)
			);
			configurationObjectDetails.add(
				new SFA2_Configuration_Object_Detail_gne__c(
					Configuration_Object_ref_gne__c = accInf.Id,
					Order_gne__c 				= ord++,
					Label_gne__c 				= 'Account Owner',
					API_Name_gne__c 			= 'OwnerId',
					Name 						= 'OwnerId',
					Availability_Mode_gne__c 	= 'New;Edit;View',
					Type_gne__c 				= 'Field',
					Is_Required_gne__c 			= false,
					Is_Read_Only_gne__c 		= false
				)
			);
			configurationObjectDetails.add(
				new SFA2_Configuration_Object_Detail_gne__c(
					Configuration_Object_ref_gne__c = accInf.Id,
					Order_gne__c 				= ord++,
					Label_gne__c 				= 'Parent Account',
					API_Name_gne__c 			= 'ParentId',
					Name 						= 'ParentId',
					Availability_Mode_gne__c 	= 'New;Edit;View',
					Type_gne__c 				= 'Field',
					Is_Required_gne__c 			= false,
					Is_Read_Only_gne__c 		= true
				)
			);
			configurationObjectDetails.add(
				new SFA2_Configuration_Object_Detail_gne__c(
					Configuration_Object_ref_gne__c = accInf.Id,
					Order_gne__c 				= ord++,
					Label_gne__c 				= 'Account Record Type',
					API_Name_gne__c 			= 'RecordType.Name',
					Name 						= 'RecordType.Name',
					Availability_Mode_gne__c 	= 'Edit;View',
					Type_gne__c 				= 'Field',
					Is_Required_gne__c 			= false,
					Is_Read_Only_gne__c 		= true
				)
			);
			configurationObjectDetails.add(
				new SFA2_Configuration_Object_Detail_gne__c(
					Configuration_Object_ref_gne__c = accInf.Id,
					Order_gne__c 				= ord++,
					Label_gne__c 				= 'Account Type',
					API_Name_gne__c 			= 'Account_Type_gne__c',
					Name 						= 'Account_Type_gne__c',
					Availability_Mode_gne__c 	= 'New;Edit;View',
					Type_gne__c 				= 'Field',
					Is_Required_gne__c 			= false,
					Is_Read_Only_gne__c 		= true
				)
			);
			configurationObjectDetails.add(
				new SFA2_Configuration_Object_Detail_gne__c(
					Configuration_Object_ref_gne__c = accInf.Id,
					Order_gne__c 				= ord++,
					Label_gne__c 				= 'Website',
					API_Name_gne__c 			= 'Website',
					Name 						= 'Website',
					Availability_Mode_gne__c 	= 'New;Edit;View',
					Type_gne__c 				= 'Field',
					Is_Required_gne__c 			= false,
					Is_Read_Only_gne__c 		= true
				)
			);
		}	
			
		for(SFA2_Configuration_Object_gne__c sysInf : systemInformationList) {
			ord = 0;
			configurationObjectDetails.add(
				new SFA2_Configuration_Object_Detail_gne__c(
					Configuration_Object_ref_gne__c = sysInf.Id,
					Order_gne__c 				= ord++,
					Label_gne__c 				= 'Created By',
					API_Name_gne__c 			= 'CreatedById',
					Name 						= 'CreatedById',
					Availability_Mode_gne__c 	= 'View',
					Type_gne__c 				= 'Field',
					Is_Required_gne__c 			= false,
					Is_Read_Only_gne__c 		= true
				)
			);
			configurationObjectDetails.add(
				new SFA2_Configuration_Object_Detail_gne__c(
					Configuration_Object_ref_gne__c = sysInf.Id,
					Order_gne__c 				= ord++,
					Label_gne__c 				= 'Last Modified By',
					API_Name_gne__c 			= 'LastModifiedById',
					Name 						= 'LastModifiedById',
					Availability_Mode_gne__c 	= 'View',
					Type_gne__c 				= 'Field',
					Is_Required_gne__c 			= false,
					Is_Read_Only_gne__c 		= true
				)
			);
		}
		
		for(SFA2_Configuration_Object_gne__c relList : relatedListList) {
			ord = 0;
			configurationObjectDetails.add(
				new SFA2_Configuration_Object_Detail_gne__c(
					Configuration_Object_ref_gne__c = relList.Id,
					Order_gne__c 				= ord++,
					Label_gne__c 				= 'Interactions',
					API_Name_gne__c 			= 'Call2_vod__c',
					Name 						= 'Call2_vod__c',
					Availability_Mode_gne__c 	= 'View',
					Type_gne__c 				= 'Related List',
					Is_Required_gne__c 			= false,
					Is_Read_Only_gne__c 		= false,
					Attributes_gne__c			= 'fieldsCSV=Name#/,Interaction_Status_gne__c,Date_of_Interaction_gne__c,CreatedById,CreatedDate;orderByFieldName=Date_of_Interaction_gne__c;'
						+ 'parentFieldName=Account_vod__c;pageSize=5;urlForNewRecord=/apex/GNE_SFA2_Interaction_Edit_Create;sortDirection=Desc;'
						+ 'hideButtons=true;hideEditLink=false;hideDeleteLink=true;'
				)
			);
			
			configurationObjectDetails.add(
				new SFA2_Configuration_Object_Detail_gne__c(
					Configuration_Object_ref_gne__c = relList.Id,
					Order_gne__c 				= ord++,
					Label_gne__c 				= 'Addresses',
					API_Name_gne__c 			= 'Address_vod__c',
					Name 						= 'Address_vod__c',
					Availability_Mode_gne__c 	= 'View',
					Type_gne__c 				= 'Related List',
					Is_Required_gne__c 			= false,
					Is_Read_Only_gne__c 		= false,
					Attributes_gne__c			= 'fieldsCSV=Name#/,Address_line_2_vod__c,City_vod__c,State_vod__c,Map_vod__c,Phone_vod__c,License_vod__c,Primary_vod__c,Inactive_vod__c;' 
						+ 'orderByFieldName=NAME;sortDirection=DESC;'
						+ 'parentFieldName=Account_vod__c;pageSize=5;urlForNewRecord=/apex/GNE_SFA2_Address_Edit_Create_Layout;'
						+ 'hideButtons=true;hideEditLink=true;hideDeleteLink=true;'
				)
			);
			configurationObjectDetails.add(
				new SFA2_Configuration_Object_Detail_gne__c(
					Configuration_Object_ref_gne__c = relList.Id,
					Order_gne__c 				= ord++,
					Label_gne__c 				= 'Contacts',
					API_Name_gne__c 			= 'Contact',
					Name 						= 'Contact',
					Availability_Mode_gne__c 	= 'View',
					Type_gne__c 				= 'Related List',
					Is_Required_gne__c 			= false,
					Is_Read_Only_gne__c 		= false,
					Attributes_gne__c			= 'fieldsCSV=Name#/,Contact_Type_gne__c,Is_Primary_for_gne__c,Department_gne__c,Phone,Fax,Email,LastModifiedDate;' 
						+ 'orderByFieldName=Name;sortDirection=desc;'
						+ 'parentFieldName=accountId;pageSize=5;urlForNewRecord=/apex/GNE_SFA2_Contact_Edit_Create_Layout;'
						+ 'hideButtons=false;hideEditLink=false;hideDeleteLink=true;'
				)
			);
			configurationObjectDetails.add(
				new SFA2_Configuration_Object_Detail_gne__c(
					Configuration_Object_ref_gne__c = relList.Id,
					Order_gne__c 				= ord++,
					Label_gne__c 				= 'Account Team',
					API_Name_gne__c 			= 'AccountTeamMember',
					Name 						= 'AccountTeamMember_rl',
					Availability_Mode_gne__c 	= 'View',
					Type_gne__c 				= 'Related List',
					Is_Required_gne__c 			= false,
					Is_Read_Only_gne__c 		= false,
					Attributes_gne__c			= 'fieldsCSV=UserId,AccountAccessLevel,TeamMemberRole;' 
						+ 'orderByFieldName=UserId;sortDirection=Asc;'
						+ 'parentFieldName=AccountId;pageSize=5;urlForNewRecord=/apex/GNE_SFA2_Std_AccTeam_Create_Layout;'
						+ 'hideButtons=true;hideEditLink=true;hideDeleteLink=true;customButtons=Add#action>addAccountTeam;'
				)
			);
			configurationObjectDetails.add(
				new SFA2_Configuration_Object_Detail_gne__c(
					Configuration_Object_ref_gne__c = relList.Id,
					Order_gne__c 				= ord++,
					Label_gne__c 				= 'Affiliations',
					API_Name_gne__c 			= 'Affiliation_vod__c',
					Name 						= 'Affiliation_vod__c',
					Availability_Mode_gne__c 	= 'View',
					Type_gne__c 				= 'Related List',
					Is_Required_gne__c 			= false,
					Is_Read_Only_gne__c 		= false,
					Attributes_gne__c			= 'fieldsCSV=Name#/,To_Account_vod__c,To_Contact_vod__c,Role_vod__c,LastModifiedById,LastModifiedDate;' 
						+ 'orderByFieldName=NAME;sortDirection=DESC;'
						+ 'pageSize=5;urlForNewRecord=/apex/GNE_SFA2_Affiliation_Edit_Create_Layout;parentFieldName=From_Contact_vod__c;'
						+ 'hideButtons=true;hideEditLink=false;hideDeleteLink=false;customButtons=New Affiliation#action>addAffiliationClick;'
				)
			);
		}
		for(SFA2_Configuration_Object_gne__c button : buttonsList) {
			configurationObjectDetails.add(
				new SFA2_Configuration_Object_Detail_gne__c(
					Configuration_Object_ref_gne__c = button.Id,
					Order_gne__c 				= 0.0,
					Label_gne__c 				= 'Edit',
					API_Name_gne__c 			= 'Edit',
					Name 						= 'Account_Button',
					Availability_Mode_gne__c 	= null,
					Type_gne__c 				= 'Button',
					Is_Required_gne__c 			= false,
					Is_Read_Only_gne__c 		= false,
					Attributes_gne__c			= 'action=edit;rerender=main-content,test;styleClass=button sfa-plh sfa-plh-title-bar;onclick=doNothing;immediate=somethingElse;'
				)
			);
			configurationObjectDetails.add(
				new SFA2_Configuration_Object_Detail_gne__c(
					Configuration_Object_ref_gne__c = button.Id,
					Order_gne__c 				= 0.0,
					Label_gne__c 				= 'Plan/ Record an Interaction',
					API_Name_gne__c 			= 'Record_a_Call',
					Name 						= 'Account_Button',
					Availability_Mode_gne__c 	= null,
					Type_gne__c 				= 'Button',
					Is_Required_gne__c 			= false,
					Is_Read_Only_gne__c 		= false,
					Attributes_gne__c			= 'action=recordACallClick;styleClass=image-button sfa-plh sfa-plh-action-bar;dir=img/icon-interact.png;immediate=false;'
				)
			);
			configurationObjectDetails.add(
				new SFA2_Configuration_Object_Detail_gne__c(
					Configuration_Object_ref_gne__c = button.Id,
					Order_gne__c 				= 1.0,
					Label_gne__c 				= 'View Attachments',
					API_Name_gne__c 			= 'View Attachments',
					Name 						= 'Account_Button',
					Availability_Mode_gne__c 	= null,
					Type_gne__c 				= 'Button',
					Is_Required_gne__c 			= false,
					Is_Read_Only_gne__c 		= false,
					Attributes_gne__c			= 'action=viewAttachmentsClick;styleClass=image-button sfa-plh sfa-plh-action-bar button;onclick=test{!$Profile.Name};immediate=true;'
				)
			);
		}
		for(SFA2_Configuration_Object_Detail_gne__c det : configurationObjectDetails) {
			det.OTR2_gne__c = false;
			det.Is_Active_gne__c = true;
		}
		
		insert configurationObjectDetails;

		SFA2_Configuration_Object_gne__c myAccountsLP = new SFA2_Configuration_Object_gne__c(
			Configuration_Type_gne__c 		= 'List Page',
			Object_Name_gne__c  			= 'Account',
			Name 							= 'My Accounts List Page',
			Section_Header_gne__c 			= 'My Accounts',
			Attributes_gne__c 				= 'activeMenuItem=My Accounts;',
			Application_Type__c 			= appType,
			Role_gne__c  					= role,
			Is_Active_gne__c  				= true
		);
	
		insert myAccountsLP;
	}

	public static User selectSFA2User() {
        List<Profile> sfa2Profiles = [ SELECT Id FROM Profile WHERE Name = 'GNE-Field' ];
        if(sfa2Profiles != null && sfa2Profiles.size() > 0) {
            List<User> sfa2Users = [ SELECT Id FROM USER WHERE ProfileId in :sfa2Profiles AND isActive = true ];
            if(sfa2Users != null && sfa2Users.size() > 0) {
                return sfa2Users[0];
            }
        }
        return null;
    }
}