@IsTest
public class AutomationBypassHelperTest {

    // Due to not being able to insert data into the DB for MetaData, we are hard coding values.
    static void mockMetadata() {
        AutomationBypassHelper.isTestContext = true;

        // Mock the Custom Metadata Records
        Automation_Bypass_Settings__mdt triggerBypass = new Automation_Bypass_Settings__mdt(
                DeveloperName = 'AllowTriggerBypass',
                Bypass_Triggers__c = true
        );

        Automation_Bypass_Settings__mdt assignmentRuleBypass = new Automation_Bypass_Settings__mdt(
                DeveloperName = 'AllowAssignmentRuleBypass',
                Bypass_Assignment_Rules__c = true
        );

        // Assign mock data to the settings map
        AutomationBypassHelper.settings = new Map<String, Automation_Bypass_Settings__mdt> {
                'AllowTriggerBypass' => triggerBypass,
                'AllowAssignmentRuleBypass' => assignmentRuleBypass
        };
    }

    @IsTest
    static void testShouldBypassTriggers() {
        mockMetadata();

        // Call the method to test
        Boolean result = AutomationBypassHelper.shouldBypassTriggers();

        // Assert the expected outcome
        System.assertEquals(true, result, 'Triggers should be bypassed based on mock metadata settings');
    }

    @IsTest
    static void testShouldBypassAssignmentRules() {
        mockMetadata();

        // Call the method to test
        Boolean result = AutomationBypassHelper.shouldBypassAssignmentRules();

        System.assertEquals(true, result, 'Assignment Rules should be bypassed based on mock metadata settings');
        // Assert the expected outcome
        System.assertEquals(true, AutomationBypassHelper.isTestContext, 'isTestContext should be true here');
    }

    @IsTest
    static void testGetSettingsWithActualData() {
        // This test method is solely to cover the actual logic of getSettings() method
        // and improve code coverage.

        // Since we can't insert metadata, just call the method.
        // If you have some predefined metadata records in your org,
        // this will test the method using those records.
        Map<String, Automation_Bypass_Settings__mdt> fetchedSettings;
        if (AutomationBypassHelper.isTestContext == false) {
            fetchedSettings = AutomationBypassHelper.getSettings();
        }

        // If you're certain you have some records in your org, you can further assert here.
        // For example:
        System.assertNotEquals(null, fetchedSettings.get('AllowTriggerBypass'), 'Should fetch known metadata record');
        System.assertEquals(false, AutomationBypassHelper.isTestContext, 'isTestContext should be false here');
    }

}