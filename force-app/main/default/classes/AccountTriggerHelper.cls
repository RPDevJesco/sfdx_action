/**
 * Created by jglov on 8/14/2023.
 */

public with sharing class AccountTriggerHelper {
    public static void BeforeUpdateDisallowSpecialCharactersDescription(List<Account> newAccounts, Map<Id, Account> oldAccountMap) {
        try {
            for(Account newAccount : newAccounts) {
                Account oldAccount = oldAccountMap.get(newAccount.Id);
                if(oldAccount != null && oldAccount.Description != newAccount.Description) {
                    UTIL_Fields.disallowSpecialCharactersAndSpaces(newAccounts, oldAccountMap, 'Description');
                }
            }
        } catch (Exception ex) {
            // Log the exception for each account
            for(Account newAccount : newAccounts) {
                LogUtility.logException(ex, newAccount);
            }
        }
    }
}