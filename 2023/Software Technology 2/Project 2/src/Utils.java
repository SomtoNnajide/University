import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.util.ArrayList;
import java.util.Scanner;

public class Utils {
    static Scanner in = new Scanner(System.in);

    public static ArrayList<String> listAllFiles(String dir){
        ArrayList<String> fileNames = new ArrayList<>();

        File folder = new File(dir);

        if(folder.exists() && folder.isDirectory()){
            File[] files = folder.listFiles();

            for (File file: files){
                fileNames.add(file.getName());
            }
        }

        return fileNames;
    }

    public static String selectFile(String dir){
        ArrayList<String> files = Utils.listAllFiles(dir);

        for(int i = 0; i< files.size(); i++){
            System.out.println(i + " - " + files.get(i));
        }

        System.out.println("\nPlease select a file.");
        int index = Integer.parseInt(in.nextLine());

        return files.get(index);
    }

    public static ArrayList<String> readFile(String filename){
        ArrayList<String> lines = new ArrayList<>();

        try{
            Scanner infile = new Scanner(new FileReader(filename));

            while(infile.hasNextLine()){
                lines.add(infile.nextLine());
            }
        }
        catch (FileNotFoundException e){
            System.out.println("File " + filename + " not found.");
            return null;
        }

        return lines;
    }
}
