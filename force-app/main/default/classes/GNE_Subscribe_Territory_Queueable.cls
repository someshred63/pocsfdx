public with sharing class GNE_Subscribe_Territory_Queueable implements Queueable{
    private Boolean prevMode;

    public GNE_Subscribe_Territory_Queueable(Boolean prevMode) {
        this.prevMode = prevMode;
    }

    public void execute(QueueableContext context) {
        new GNE_Subscribe_Territory(prevMode);
    }
}