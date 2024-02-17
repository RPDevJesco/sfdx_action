public class BoardColumn {
    public String key;
    public String text;
    public Boolean isGroup;
    public String color;
    public String loc;

    public BoardColumn(String name, String loc) {
        this.key = name;
        this.text = name;
        this.isGroup = true;
        this.color = '0'; // Adjust as needed
        this.loc = loc;
    }
}