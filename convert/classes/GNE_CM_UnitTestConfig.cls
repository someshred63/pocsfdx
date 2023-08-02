/**
 * This class contains configuration for running unit tests.
 * 
 * If we want a certain trigger to be skipped in a certain test:
 * 1. Mark this trigger as skipped at the beginning of the test method: GNE_CM_UnitTestConfig.skipTriggerForTests('trigger-name')
 * 2. At the beginning of the trigger, place a check: 
 *      if (GNE_CM_UnitTestConfig.isSkipped('trigger-name'))
 *      {
 *          return;
 *      }
 *
 * @Created by Radek Krawiec (radoslaw.krawiec@roche.com)
 * @CreatedOn 05-09-2012
 */
public with sharing class GNE_CM_UnitTestConfig
{
    private static Set<String> triggerNames;
    
    // If set to true, triggers are set only when code is run as a test.
    // If false, triggers are always skipped.
    private static Boolean skipTriggersOnlyInTests = true;
    
    public static void setSkipTriggersOnlyInTests (Boolean value)
    {
    	skipTriggersOnlyInTests = value != null ? value : false;
    }
    
    public static Boolean getSkipTriggersOnlyInTests()
    {
    	return skipTriggersOnlyInTests;
    }
    
    /**
     * Mark the trigger as skipped so that it is not executed in tests
     */
    public static void skipTriggerForTests (String triggerName)
    {
        if (triggerNames == null)
        {
            triggerNames = new Set<String>();
        }
        
        triggerNames.add(triggerName);
    }
    
    /**
     * Unmark the trigger as skipped so that it if it was previously skipped in tests, it will now be normally executed.
     */
    public static void unskipTriggerForTests (String triggerName)
    {
        if (triggerNames != null)
        {
            triggerNames.remove(triggerName);
        }
    }
    
    /**
     * Checks if a trigger with the given name should be skipped in tests. Returns true only if the test is marked as skipped
     * AND Test.isRunningTest returns true.
     */
    public static boolean isSkipped (String triggerName)
    {
        return triggerNames != null && triggerNames.contains(triggerName) && (Test.isRunningTest() || skipTriggersOnlyInTests == false);
    }
}