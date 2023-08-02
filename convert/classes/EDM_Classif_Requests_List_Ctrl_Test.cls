@isTest(seeAllData=false)
private class EDM_Classif_Requests_List_Ctrl_Test{

    static testMethod void crListControllerTest(){

        Profile p = [select id from profile where name='GNE-MedAffairs-SP'];
        User u = new User(alias = 'spManagr', email='spManager@gene.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p.Id,
            timezonesidkey='America/Los_Angeles', username='spManager@gene.com');
        insert u;

        System.runAs(u){
            EDM_Classif_Requests_List_Controller ext = new EDM_Classif_Requests_List_Controller();

            PageReference pr = ext.init();

            System.assertEquals(GNE_SFA2_Util.redirectToAccessDeniedPage().getURL(),pr.getURL());
        }

        assignPermissionSet(u.Id, 'EDM_Classification_Review');

        System.runAs(u){
            EDM_Classif_Requests_List_Controller ext = new EDM_Classif_Requests_List_Controller();

            PageReference pr = ext.init();

            System.assertEquals(null,pr);
        }
    }

    private static void assignPermissionSet(Id userId, String permissionSetName) {
        System.runAs(new User(Id = Userinfo.getUserId())) {
            PermissionSet ps = [SELECT ID From PermissionSet WHERE Name = :permissionSetName];
            list <PermissionSetAssignment> PSAssignments = new list <PermissionSetAssignment>();
            List<User> users = [SELECT ID, (Select ID FROM PermissionSetAssignments WHERE PermissionSetID = :ps.id) FROM User WHERE Id = :userId];
            
            for (User u : users) {
                if (u.PermissionSetAssignments.size() == 0) 
                    PSAssignments.add( new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.ID ) );
            }

            if (!PSAssignments.isEmpty()) {
                insert PSAssignments;
            }
        }
    }

}