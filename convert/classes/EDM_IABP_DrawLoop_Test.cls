@isTest
private class EDM_IABP_DrawLoop_Test {
    
    @isTest static void shouldFilterIABPAttachments() {
        List<sObject> testData = EDM_ABM_Test_Utils.insertABMStructure();

        List<Attachment> attachments = new List<Attachment> {
            getTestAttachment(testData[0].Id),
            getTestAttachment(testData[1].Id)
        };
        
        List<Attachment> results = EDM_IABP_DrawLoop.filterAttachmentsBy(attachments, EDM_IABP_gne__c.SobjectType);

        System.assertEquals(1, results.size());
        System.assertEquals(testData[1].Id, results[0].ParentId);
    }

    private static Attachment getTestAttachment(Id parentId) {
        return new Attachment(
            Name = 'testAttachment',
            Body = Blob.valueOf('testAttachmentBodyContentsEncodedInBase64'),
            ParentId = parentId);
    }

    @isTest static void shouldUpdateEDMAttachmentsLink() {
        GNE_SFA2_Util.switchAdminMode(true);
        EDM_Attachment_gne__c edmAttachment = new EDM_Attachment_gne__c(EDM_Document_Name_gne__c = 'Test');
        insert edmAttachment;
        List<Attachment> attachments = new List<Attachment> {
            getTestAttachment(edmAttachment.Id)};
        insert attachments;
        GNE_SFA2_Util.switchAdminMode(false);

        EDM_IABP_DrawLoop.updateEDMAttachmentLinks(attachments);

        List<EDM_Attachment_gne__c> edmAttachments = [SELECT Id, EDM_Link_gne__c FROM EDM_Attachment_gne__c WHERE Id = :edmAttachment.Id];
        System.assert(String.isNotBlank(edmAttachments[0].EDM_Link_gne__c));

        
    }

    @isTest static void shouldGenerateInvitationsAndAgreements() {
        List<Loop__DDP__c> ddps = new List<Loop__DDP__c>();
        ddps.add(new Loop__DDP__c(
            Name = 'EDM IABP Invitation by Budget'
        ));
        ddps.add(new Loop__DDP__c(
            Name = 'EDM IABP Advisory Board Consulting Agreement - Patients and Patient Advocates'
        ));
        ddps.add(new Loop__DDP__c(
            Name = 'EDM IABP Agreement by Budget'
        ));
        insert ddps;
        List<Loop__DDP_Integration_Option__c> ddpsOpts = new List<Loop__DDP_Integration_Option__c>();
        ddpsOpts.add(new Loop__DDP_Integration_Option__c(
            Name = 'Test',
            Loop__DDP__c = ddps[0].Id
        ));
        ddpsOpts.add(new Loop__DDP_Integration_Option__c(
            Name = 'Test',
            Loop__DDP__c = ddps[1].Id
        ));
        ddpsOpts.add(new Loop__DDP_Integration_Option__c(
            Name = 'Test',
            Loop__DDP__c = ddps[2].Id
        ));
        insert ddpsOpts;

        List<sObject> testData = EDM_ABM_Test_Utils.insertABMStructure();
        insertDrawLoopConf();
        EDM_IABP_gne__c iabp = (EDM_IABP_gne__c)testData[1];
        List<EDM_Budget_gne__c> budgets = new List<EDM_Budget_gne__c>();
        //amount > 0
        budgets.add(new EDM_Budget_gne__c(
            EDM_Parent_IABP_gne__c = iabp.Id,
            EDM_Amount_gne__c = 1,
            EDM_Type_gne__c = 'Moderator',
            EDM_Drawloop_Duties_gne__c = 'test'
        ));
        budgets.add(new EDM_Budget_gne__c(
            EDM_Parent_IABP_gne__c = iabp.Id,
            EDM_Amount_gne__c = 1,
            EDM_Type_gne__c = 'Clinical Expert',
            EDM_Drawloop_Duties_gne__c = 'test'
        ));
        budgets.add(new EDM_Budget_gne__c(
            EDM_Parent_IABP_gne__c = iabp.Id,
            EDM_Amount_gne__c = 1,
            EDM_Type_gne__c = 'Chair',
            EDM_Drawloop_Duties_gne__c = 'test'
        ));
        budgets.add(new EDM_Budget_gne__c(
            EDM_Parent_IABP_gne__c = iabp.Id,
            EDM_Amount_gne__c = 1,
            EDM_Type_gne__c = 'Advisor',
            EDM_Drawloop_Duties_gne__c = 'test'
        ));
        budgets.add(new EDM_Budget_gne__c(
            EDM_Parent_IABP_gne__c = iabp.Id,
            EDM_Amount_gne__c = 1,
            EDM_Type_gne__c = 'Patient Advisor',
            EDM_Drawloop_Duties_gne__c = 'test'
        ));
        //amount == 0               
        budgets.add(new EDM_Budget_gne__c(
            EDM_Parent_IABP_gne__c = iabp.Id,
            EDM_Amount_gne__c = 0,
            EDM_Type_gne__c = 'Moderator',
            EDM_Drawloop_Duties_gne__c = 'test'
        ));
        budgets.add(new EDM_Budget_gne__c(
            EDM_Parent_IABP_gne__c = iabp.Id,
            EDM_Amount_gne__c = 0,
            EDM_Type_gne__c = 'Clinical Expert',
            EDM_Drawloop_Duties_gne__c = 'test'
        ));
        budgets.add(new EDM_Budget_gne__c(
            EDM_Parent_IABP_gne__c = iabp.Id,
            EDM_Amount_gne__c = 0,
            EDM_Type_gne__c = 'Chair',
            EDM_Drawloop_Duties_gne__c = 'test'
        ));
        budgets.add(new EDM_Budget_gne__c(
            EDM_Parent_IABP_gne__c = iabp.Id,
            EDM_Amount_gne__c = 0,
            EDM_Type_gne__c = 'Advisor',
            EDM_Drawloop_Duties_gne__c = 'test'
        ));
        budgets.add(new EDM_Budget_gne__c(
            EDM_Parent_IABP_gne__c = iabp.Id,
            EDM_Amount_gne__c = 0,
            EDM_Type_gne__c = 'Patient Advisor',
            EDM_Drawloop_Duties_gne__c = 'test'
        ));
        insert budgets;  
        /*Folder f = [Select Id from Folder Where Name = 'EDM Templates'];
        List<Document> docs = new List<Document>();
        docs = new List<Document>([Select Id,Name,DeveloperName,FolderId From Document Where DeveloperName In ('ABS_REQUIRED_EVALUATION_RESULTS_DOC','COVER_LETTER_DOC')]);
        docs.add(new Document(
            Name = 'doc1',
            FolderId = f.Id,
            DeveloperName = 'ABS_REQUIRED_EVALUATION_RESULTS_DOC'
        ));
        docs.add(new Document(
            Name = 'doc2',
            FolderId = f.Id,
            DeveloperName = 'COVER_LETTER_DOC'
        ));
        upsert docs;*/

        iabp.EDM_Status_gne__c = 'IABP Submitted for Approval';
        update iabp;
        
        Test.StartTest();
        iabp.EDM_Status_gne__c = 'IABP Approved';
        update iabp;
        Test.StopTest();

        System.assertEquals(budgets.size(), EDM_IABP_DrawLoop.loopMessageRequestCount);
    }

    private static void insertDrawLoopConf() {
        List<Loop__DDP__c> ddps = new List<Loop__DDP__c> {
            new Loop__DDP__c(Name = 'EDM IABP Invitation & Agreement'),
            new Loop__DDP__c(Name = 'EDM IABP Advisory Board Consulting Agreement - Patients and Patient Advocates')
        };

        insert ddps;

        List<Loop__DDP_Integration_Option__c> ddpDeliveries = new List<Loop__DDP_Integration_Option__c>();
        Set<String> types = new Set<String> {'Moderator', 'Clinical Expert', 'Chair', 'Advisor', 'Patient'};
        
        for (Loop__DDP__c ddp : ddps) {
            for (String type : types) {
                ddpDeliveries.add(new Loop__DDP_Integration_Option__c(Name = type, Loop__DDP__c = ddp.id));
            }
        }

        insert ddpDeliveries;
    }

    private static List<EDM_Budget_gne__c> insertBudgetsFor(Id iabpId) {
        List<EDM_Budget_gne__c> budgets = new List<EDM_Budget_gne__c> {
            new EDM_Budget_gne__c(EDM_Parent_IABP_gne__c = iabpId, EDM_Type_gne__c = 'Moderator', EDM_Amount_gne__c = 100),
            new EDM_Budget_gne__c(EDM_Parent_IABP_gne__c = iabpId, EDM_Type_gne__c = 'Advisor', EDM_Amount_gne__c = 100)
        };
        insert budgets;

        return budgets;
    }


    @isTest static void shouldReparentAttachmentsToEDMAttachments() {

        List<EDM_Attachment_gne__c> edmAttachments = [SELECT Id, (SELECT Id from Attachments) FROM EDM_Attachment_gne__c];
        Integer attSize = edmAttachments.size();
        system.debug(attSize);
        List<sObject> testData = EDM_ABM_Test_Utils.insertABMStructure();

        List<EDM_Budget_gne__c> budgets = insertBudgetsFor(testData[1].Id);

        List<Attachment> attachments = new List<Attachment> {
            getTestAttachment(budgets[0].Id),
            getTestAttachment(budgets[1].Id)
        };

        attachments[0].Name = 'Dummy Clinical Expert Standard Invite.docx';

        insert attachments;

        system.debug(attachments.size());

        edmAttachments = [SELECT Id, (SELECT Id from Attachments) FROM EDM_Attachment_gne__c];
        system.debug(edmAttachments.size());
        System.assertEquals(attSize+2, edmAttachments.size());

        edmAttachments = [SELECT Id, (SELECT Id from Attachments) FROM EDM_Attachment_gne__c Where Name = 'testAttachment'];
        for (EDM_Attachment_gne__c edmAttachment : edmAttachments) {
            System.assertEquals(1, edmAttachment.Attachments.size());
        }
    }
}