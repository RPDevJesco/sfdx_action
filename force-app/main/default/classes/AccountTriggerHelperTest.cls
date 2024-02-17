/**
 * Created by jglov on 8/15/2023.
 */

@IsTest
private class AccountTriggerHelperTest {
    @TestSetup
    static void initializeTestData() {
        Account accountInstance = new Account();
        accountInstance.Name = 'Test Account For Testing 1234567890';
        insert accountInstance;
    }

    @IsTest
    static void BeforeUpdateDisallowSpecialCharactersDescriptionTest() {
        List<Account> newAccounts = [SELECT Id, Name, Description FROM Account LIMIT 1];
        newAccounts[0].Description = 'Descriptive Verbiage@123';

        Test.startTest();
        try {
            update newAccounts;
        } catch (DmlException e) {
            System.assert(e.getDmlType(0) == StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION);
        }
        Test.stopTest();
    }
}