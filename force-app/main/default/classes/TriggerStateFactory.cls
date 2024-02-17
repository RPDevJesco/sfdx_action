/**
 * Created by jglov on 8/14/2023.
 */

public class TriggerStateFactory {
    public static TriggerState getState(SObjectType sObjType, TriggerOperation operation) {
        if (sObjType == Account.SObjectType) {
            return getAccountState(operation);
        }
        // Additional conditions for other objects
        return null;
    }

    private static TriggerState getAccountState(TriggerOperation operation) {
        if (operation == TriggerOperation.BEFORE_INSERT) {
            return new AccountTriggerState.BeforeInsertState();
        }
        if (operation == TriggerOperation.AFTER_INSERT) {
            return new AccountTriggerState.AfterUpdateState();
        }
        if (operation == TriggerOperation.BEFORE_UPDATE) {
            return new AccountTriggerState.BeforeUpdateState();
        }
        if (operation == TriggerOperation.AFTER_UPDATE) {
            return new AccountTriggerState.AfterUpdateState();
        }
        if (operation == TriggerOperation.BEFORE_DELETE) {
            return new AccountTriggerState.BeforeDeleteState();
        }
        if (operation == TriggerOperation.AFTER_DELETE) {
            return new AccountTriggerState.AfterDeleteState();
        }
        return null;
    }
}