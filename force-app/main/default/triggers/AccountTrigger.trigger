/**
 * Created by jglov on 8/14/2023.
 */

trigger AccountTrigger on Account (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if (AutomationBypassHelper.shouldBypassTriggers()) {
        return;
    }

    TriggerOperation operation = Trigger.operationType;
    TriggerState state = TriggerStateFactory.getState(Account.SObjectType, operation);

    if (state != null) {
        TriggerContext context = new TriggerContext(state);
        context.execute();
    }
}