public class Test_InteractionsWithExpenses {
    public static testMethod void testRunAs() {
      // Setup test data
      // This code runs as the system user
            system.debug('Test Start for Report Interactions with spends for unresolved HCPs');
            InteractionsWithExpenses a =  new InteractionsWithExpenses();
            a.process ();
            System.Debug('Test End for Report Interactions with spends for unresolved HCPs');
        }

}