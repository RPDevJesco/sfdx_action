public class TriggerContext {
    private TriggerState state;

    public TriggerContext(TriggerState state) {
        this.state = state;
    }

//    public void setState(TriggerState state) {
//        this.state = state;
//    }

    public void execute() {
        state.handleState(this);
    }

    // Add additional properties and methods as needed to store the context information
}