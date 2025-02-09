import java.util.*;

public class Menu
{
    public static String filename = "Select file";
    static String dir = "TestFiles/";
    Scanner in = null;
    String author = "";

    public void menu()
    {
        System.out.print("\f");

        String menuOpt;
        in = new Scanner(System.in);

        do
        {
            System.out.print(author);
            System.out.print("ST2-2023 Assignment 2\n");
            System.out.print("("+filename+")\n");
            System.out.print("Q -  Exit/Quit\n");           
            System.out.print("W -  Who Am I (Task1)\n");
            System.out.print("E -  Execute SAIL2023File (Task 1)\n");
            System.out.print("E2 - Execute SAIL2023File (Task 2)\n");
            System.out.print("E3 - Execute SAIL2023File (Task 3)\n");
            System.out.print("E4 - Execute SAIL2023File (Task 4)\n");
            System.out.print("E5 - Execute SAIL2023File (Task 5)\n");
            System.out.print("S  - Set File name\n");

            System.out.print("Select Option:\n");
            menuOpt = in.nextLine().trim().toUpperCase();

            if (menuOpt.compareToIgnoreCase("W") == 0) {
                setAuthor();
            }
            if (menuOpt.compareToIgnoreCase("E") == 0 ) {
            Interpreter interpreter = new Interpreter(dir, filename);
            interpreter.interpretLines();
            }
            if (menuOpt.compareToIgnoreCase("E2") == 0 ) {
                Interpreter interpreter = new Interpreter(dir, filename);
                interpreter.interpretLines();
            }
            if (menuOpt.compareToIgnoreCase("E3") == 0 ) {
                Interpreter interpreter = new Interpreter(dir, filename);
                interpreter.interpretLines();
            }
            if (menuOpt.compareToIgnoreCase("E4") == 0 ) {
                Interpreter interpreter = new Interpreter(dir, filename);
                interpreter.interpretLines();
            }
            if (menuOpt.compareToIgnoreCase("E5") == 0 ) {
                Interpreter interpreter = new Interpreter(dir, filename);
                interpreter.interpretLines();
            }
            if (menuOpt.compareToIgnoreCase("S") == 0 ){
                setFileName();
            }

        }
        while (menuOpt.compareToIgnoreCase("Q") != 0);
        System.out.print("\nEnding Now\n");
    }

    public void setAuthor()
    {
        author = "\nAuthor: Somtochukwu Nnajide u3224942\n";
    }

    public void setFileName() {filename = Utils.selectFile(dir);}
}