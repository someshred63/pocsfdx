@isTest
private class GNE_SFA2_Event_Curclm_CtrlTest {
    @isTest
    static void testNewClick() {
        GNE_SFA2_Event_Curclm_Ctrl ctrl = new GNE_SFA2_Event_Curclm_Ctrl();
        PageReference ref = ctrl.newClick();
        System.assert( ref.getUrl().containsIgnoreCase('GNE_SFA2_ECurclmBureau_EdCr_Layout') );
        System.assert( ref.getParameters().containsKey('retURL') );
        System.assert( ref.getParameters().get('retURL').containsIgnoreCase('GNE_SFA2_ECurriculum') );
    }
}