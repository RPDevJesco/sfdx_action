/**
 * Created by jglov on 9/6/2023.
 */

public class AutomationBypassHelper {
    @TestVisible
    private static Map<String, Automation_Bypass_Settings__mdt> settings;
    // flag to identify test context due to Salesforce not allowing DML statements with MetaData.
    @TestVisible
    private static Boolean isTestContext = false;

    @TestVisible
    private static Map<String, Automation_Bypass_Settings__mdt> getSettings() {
        if (settings == null) {
            if (isTestContext) return settings;

            settings = new Map<String, Automation_Bypass_Settings__mdt>();
            for (Automation_Bypass_Settings__mdt s : [SELECT DeveloperName, Bypass_Assignment_Rules__c, Bypass_Flows__c, Bypass_Process_Builders__c, Bypass_Triggers__c, Bypass_Validation_Rules__c, Bypass_Workflow_Rules__c FROM Automation_Bypass_Settings__mdt]) {
                settings.put(s.DeveloperName, s);
            }
        }
        return settings;
    }

    public static Boolean shouldBypassTriggers() {
        return getSettings().get('AllowTriggerBypass').Bypass_Triggers__c;
    }

    public static Boolean shouldBypassAssignmentRules() {
        return getSettings().get('AllowAssignmentRuleBypass').Bypass_Assignment_Rules__c;
    }
}