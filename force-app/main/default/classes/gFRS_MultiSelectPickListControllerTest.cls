@IsTest
private class gFRS_MultiSelectPickListControllerTest {


    @isTest
    private static void selectclickTest() {
        gFRS_MultiselectPickListController controller = new gFRS_MultiselectPickListController();
        List<String> selectedContent = new List<String>{
                'test', 'test1'
        };
        controller.leftOptions = new List<SelectOption>{
                new SelectOption('test', 'test'), new SelectOption('test1', 'test1')
        };
        controller.leftSelectedCont.addAll(selectedContent);

        Test.startTest();
        controller.selectclick();
        Test.stopTest();

        System.assertEquals(2, controller.finalSelectedItems.size());
    }

    @isTest
    private static void unselectclickTest() {
        gFRS_MultiselectPickListController controller = new gFRS_MultiselectPickListController();
        List<String> selectedContent = new List<String>{
                'test', 'test1'
        };
        controller.rightOptions = new List<SelectOption>{
                new SelectOption('test', 'test'), new SelectOption('test1', 'test1')
        };
        controller.rightSelectedCont.addAll(selectedContent);

        Test.startTest();
        controller.unselectclick();
        Test.stopTest();

        System.assertEquals(0, controller.finalSelectedItems.size());
    }

}