@isTest
public class EDM_Interaction_Ext_Test {
	@isTest
    public static void shouldCoverClass() {
        (new EDM_Interaction_Ext(new GNE_SFA2_Interaction_Controller())).getIsSBMUser();
    }
}