/**
 * Created by jglov on 8/14/2023.
 */

public class AccountTriggerState {
    public class BeforeInsertState implements TriggerState {
        public void handleState(TriggerContext context) {

        }
    }

    public class AfterInsertState implements TriggerState {
        public void handleState(TriggerContext context) {
            // Logic for after insert
        }
    }

    public class BeforeUpdateState implements TriggerState {
        public void handleState(TriggerContext context) {
            AccountTriggerHelper.BeforeUpdateDisallowSpecialCharactersDescription(Trigger.new, (Map<Id, Account>) Trigger.oldMap);
        }
    }

    public class AfterUpdateState implements TriggerState {
        public void handleState(TriggerContext context) {
            // Logic for after update
        }
    }

    public class BeforeDeleteState implements TriggerState {
        public void handleState(TriggerContext context) {
            // Logic for before delete
        }
    }

    public class AfterDeleteState implements TriggerState {
        public void handleState(TriggerContext context) {
            // Logic for after delete
        }
    }
}