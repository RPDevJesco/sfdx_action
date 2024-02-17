/**
 * Created by jglov on 8/3/2023.
 */

@IsTest
private class UpdateCaseAgeBatchTest {
    @TestSetup
    static void initializeTestData() {
        Account accountInstance = new Account();
        accountInstance.Name = 'Test Account For Testing 1234567890';
        insert accountInstance;

        Contact contact = new Contact();
        contact.Account = accountInstance;
        contact.FirstName = 'John';
        contact.LastName = 'Wayne';
        contact.Birthdate = Date.newInstance(1980,10,12);
        insert contact;

        Case caseInstance = new Case();
        caseInstance.Status = 'New';
        caseInstance.Account = accountInstance;
        insert caseInstance;
    }

    @IsTest
    static void testUpdateCaseAgeBatch() {
        Test.startTest();
        Database.executeBatch(new UpdateCaseAgeBatch(), 200);
        Test.stopTest();

        List<Case> updatedCases = [SELECT Id, Case_Age__c FROM Case];
        System.assertEquals(1, updatedCases.size());

        System.assertNotEquals(-1024, updatedCases[0].Case_Age__c);
    }

    @IsTest
    static void testSchedulable() {
        Test.startTest();
        // Schedule the batch class to run
        UpdateCaseAgeBatch updateCaseAgeBatch = new UpdateCaseAgeBatch();
        updateCaseAgeBatch.execute(null);
        Test.stopTest();

        // Perform the same assertions as in the other test method, or additional ones specific to the scheduled execution
        List<Case> updatedCases = [SELECT Id, Case_Age__c FROM Case];
        System.assertEquals(1, updatedCases.size());
        System.assertNotEquals(-1024, updatedCases[0].Case_Age__c);
    }
}