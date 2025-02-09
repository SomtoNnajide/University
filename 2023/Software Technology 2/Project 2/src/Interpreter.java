import java.util.ArrayList;
import java.util.Hashtable;
import java.util.Objects;

public class Interpreter {
    private String dir, filename;

    private Hashtable<String, Integer> hashtable = new Hashtable<>();

    public Interpreter(String dir, String filename){
        this.dir = dir;
        this.filename = filename;
    }

    public void interpretLines() {
        int index = 0;
        String file = dir + filename;
        ArrayList<String> lines = Utils.readFile(file);

        printFileInfo(file, lines);

        System.out.println("---------- Running code ----------");

        interpreter(index, lines);
    }

    private void interpreter(int index, ArrayList<String> lines) {
        boolean IFWasFalse = false;
        int endWhileIndex = 0;

        for(int i = index; i < lines.size(); i++){
            boolean isExecutable = true;

            String[] tokens = lines.get(i).split(" "); //tokenize at whitespace

            switch (tokens[0]){
                case "end":
                    break;

                case "println":
                    String printlntoken = rebuildLiteral(tokens); //rebuild token

                    println(printlntoken);
                    break;

                case "print":
                    String printtoken = rebuildLiteral(tokens);

                    print(printtoken);
                    break;

                case "set":
                    if(tokens.length == 4){
                        if(Objects.equals(tokens[2], "to")){
                            set(tokens[1], tokens[3]);
                        }
                        else{
                            System.out.println("Incorrect keyword on line " + i + "\nCode execution will stop");
                            isExecutable = false;
                        }
                    }
                    else{
                        System.out.println("Incomplete statement on line " + i + "\nCode execution will stop");
                        isExecutable = false;
                    }

                    break;

                case "add":
                    if(tokens.length == 4){
                        if(Objects.equals(tokens[2], "to")){
                            boolean canBeAdded = add(tokens[1], tokens[3]);

                            if(!canBeAdded) isExecutable = false;   //exception caught
                        }
                        else{
                            System.out.println("Incorrect keyword on line " + i + "\nCode execution will stop");
                            isExecutable = false;
                        }
                    }
                    else{
                        System.out.println("Incomplete statement on line " + i + "\nCode execution will stop");
                        isExecutable = false;
                    }

                    break;

                case "subtract":
                    if(tokens.length == 4){
                        if(Objects.equals(tokens[2], "from")){
                            boolean canBeSubtracted = subtract(tokens[1], tokens[3]);

                            if(!canBeSubtracted) isExecutable = false;
                        }
                        else{
                            System.out.println("Incorrect keyword on line " + i + "\nCode execution will stop");
                            isExecutable = false;
                        }
                    }
                    else{
                        System.out.println("Incomplete statement on line " + i + "\nCode execution will stop");
                        isExecutable = false;
                    }

                    break;

                case "multiply":
                    if(tokens.length == 4){
                        if(Objects.equals(tokens[2], "by")){
                            boolean canBeMultiplied = multiply(tokens[1], tokens[3]);

                            if(!canBeMultiplied) isExecutable = false;
                        }
                        else{
                            System.out.println("Incorrect keyword on line " + i + "\nCode execution will stop");
                            isExecutable = false;
                        }
                    }
                    else{
                        System.out.println("Incomplete statement on line " + i + "\nCode execution will stop");
                        isExecutable = false;
                    }

                    break;

                case "divide":
                    if(tokens.length == 4){
                        if(Objects.equals(tokens[2], "by")){
                            boolean canBeDivided = divide(tokens[1], tokens[3]);

                            if(!canBeDivided) isExecutable = false;
                        }
                        else{
                            System.out.println("Incorrect keyword on line " + i + "\nCode execution will stop");
                            isExecutable = false;
                        }
                    }
                    else{
                        System.out.println("Incomplete statement on line " + i + "\nCode execution will stop");
                        isExecutable = false;
                    }

                    break;

                case "if":
                    if(tokens.length == 5){
                        if(Objects.equals(tokens[4], "then")){
                            boolean predicate = sailConditional(tokens);

                            if(!predicate){
                                IFWasFalse = true;

                                //find index of immediate line after "endif"
                                for(int j = 0; j < lines.size(); j++){
                                    if(Objects.equals(lines.get(j), "endif")){
                                        index = j + 1;  //global index var
                                    }
                                }
                            }
                        }
                        else{
                            System.out.println("Incorrect keyword on line " + i + "\nCode execution will stop");
                            isExecutable = false;
                        }
                    }
                    else{
                        System.out.println("Incomplete statement on line " + i + "\nCode execution will stop");
                        isExecutable = false;
                    }

                    break;

                case "while":
                    if(tokens.length == 5){
                        if(Objects.equals(tokens[4], "do")){
                            boolean whilePredicate = sailConditional(tokens);
                            ArrayList<String> whileLines = new ArrayList<>();  //arraylist of lines within while loop

                            //find index of "endwhile"
                            //start loop from "while" line (current i)
                            for(int j = i; j < lines.size(); j++){
                                if(Objects.equals(lines.get(j), "endwhile")){
                                    endWhileIndex = j;
                                    break;   //logic control
                                }
                            }

                            //add lines between "while" and "endwhile" to arraylist
                            //start loop from immediate line after while (current i + 1)
                            for(int k = i + 1; k < endWhileIndex; k++){
                                whileLines.add(lines.get(k).strip());  //strip lines to remove tabs/extra whitespace
                            }

                            while(whilePredicate){
                                interpreter(index, whileLines);   //run interpreter on lines within "while"

                                whilePredicate = sailConditional(tokens);  //check predicate

                                if(!whilePredicate){
                                    break;
                                }
                            }
                        }
                        else{
                            System.out.println("Incorrect keyword on line " + i + "\nCode execution will stop");
                            isExecutable = false;
                        }
                    }
                    else{
                        System.out.println("Incomplete statement on line " + i + "\nCode execution will stop");
                        isExecutable = false;
                    }

                    break;
            }

            //outside switch
            if(!isExecutable || IFWasFalse){   //break loop if evaluation is true
                break;
            }
        }
        //outside loop
        if(IFWasFalse){  //loop was broken because of false conditional
            interpreter(index, lines); //re-run interpreter from line after "endif"
        }
    }

    private static String rebuildLiteral(String[] tokens) {
        //takes in a tokens array and rebuilds literal if applicable => token = quoted string
        //else token = whatever has been tokenized => can be either a variable or integer

        String token;

        if(tokens[1].startsWith("'")){
            StringBuilder literal = new StringBuilder();

            for(int i = 1; i < tokens.length; i++ ){
                literal.append(tokens[i]).append(" "); //rebuild string with whitespace
            }

            token = literal.toString();
        }
        else{
            token = tokens[1]; //either variable or integer
        }

        return token;
    }

    private void printFileInfo(String file, ArrayList<String> lines){
        //counts the number of lines in a file
        //counts the number of commented/blank lines

        int commentCounter = 0;

        for(String line: lines){
            if(line.startsWith("//") || line.equals("")){  //if line is a comment or line is blank
                commentCounter++;
            }
        }

        System.out.println("Reading code file: " + file);
        System.out.println("Number of Lines Read in is: " + lines.size());
        System.out.println("Number of Non Comment Lines read in is: " + (lines.size() - commentCounter));
    }

    private void set(String var, String value){
        //if the value to be set is a hashtable key
        //get key-value
        if(hashtable.containsKey(value)){
            hashtable.put(var, hashtable.get(value));
        }
        //if the key to be set already exists
        //avoid creating duplicates, jst replace value
        else if(hashtable.containsKey(var)){
            hashtable.replace(var, Integer.parseInt(value));
        }
        //the value to be set is an integer
        else{
            hashtable.put(var, Integer.parseInt(value));
        }
    }

    private boolean add(String varToBeAdded, String key){
        //try-catch checks if key exists in hashtable (has been set)
        //else variable is undefined

        try{
            //if variable to be added is a key
            if(hashtable.containsKey(varToBeAdded)){
                //var.value + key.value
                hashtable.replace(key, hashtable.get(varToBeAdded) + hashtable.get(key));
            }
            else{
                //integer + key.value
                hashtable.replace(key, Integer.parseInt(varToBeAdded) + hashtable.get(key));
            }
        }
        catch(NullPointerException e){
            System.out.println("Error variable " + "(" + key +")" + " is undefined.\nCode execution will stop.");
            return false;
        }
        return true;
    }

    private boolean subtract(String varToBeSubtracted, String key){
        //try-catch checks if key exists in hashtable (has been set)
        //else variable is undefined

        try{
            //if variable to be subtracted is a key
            if(hashtable.containsKey(varToBeSubtracted)){
                //key.value - var.value
                hashtable.replace(key, hashtable.get(key) - hashtable.get(varToBeSubtracted));
            }
            else{
                //key.value - integer
                hashtable.replace(key, hashtable.get(key) - Integer.parseInt(varToBeSubtracted));
            }
        }
        catch(NullPointerException e){
            System.out.println("Error variable " + "(" + key +")" + " is undefined.\nCode execution will stop.");
            return false;
        }
        return true;
    }

    private boolean multiply(String varToBeMultiplied, String multiplicator){
        //try-catch checks if key exists in hashtable (has been set)
        //else variable is undefined

        try{
            //if multiplicator is a key
            if(hashtable.containsKey(multiplicator)){
                //multiplicator.value * key.value
                hashtable.replace(varToBeMultiplied, hashtable.get(multiplicator) * hashtable.get(varToBeMultiplied));
            }
            else{
                //integer * key.value
                hashtable.replace(varToBeMultiplied, Integer.parseInt(multiplicator) * hashtable.get(varToBeMultiplied));
            }
        }
        catch(NullPointerException e){
            System.out.println("Error variable " + "(" + varToBeMultiplied +")" + " is undefined.\nCode execution will stop.");
            return false;
        }
        return true;
    }

    private boolean divide(String varToBeDivided, String divisor){
        //try-catch checks if key exists in hashtable (has been set)
        //else variable is undefined

        try{
            //if divisor is a key
            if(hashtable.containsKey(divisor)){
                //key.value / divisor.value
                hashtable.replace(varToBeDivided, hashtable.get(varToBeDivided) / hashtable.get(divisor));
            }
            else{
                //key.value / integer
                hashtable.replace(varToBeDivided, hashtable.get(varToBeDivided) / Integer.parseInt(divisor));
            }
        }
        catch(NullPointerException e){
            System.out.println("Error variable " + "(" + varToBeDivided +")" + " is undefined.\nCode execution will stop.");
            return false;
        }
        return true;
    }

    private boolean sailConditional(String[] tokens){
        if(hashtable.containsKey(tokens[1])){
            if(hashtable.containsKey(tokens[3])){
                //var conditional var
                switch (tokens[2]) {
                    case "<" -> {
                        return hashtable.get(tokens[1]) < hashtable.get(tokens[3]);
                    }
                    case ">" -> {
                        return hashtable.get(tokens[1]) > hashtable.get(tokens[3]);
                    }
                    case "==" -> {
                        return Objects.equals(hashtable.get(tokens[1]), hashtable.get(tokens[3]));
                    }
                }
            }
            else{
                switch (tokens[2]) {
                    //var conditional int
                    case "<" -> {
                        return hashtable.get(tokens[1]) < Integer.parseInt(tokens[3]);
                    }
                    case ">" -> {
                        return hashtable.get(tokens[1]) > Integer.parseInt(tokens[3]);
                    }
                    case "==" -> {
                        return hashtable.get(tokens[1]) == Integer.parseInt(tokens[3]);
                    }
                }
            }
        }
        else{
            if(hashtable.containsKey(tokens[3])){
                switch (tokens[2]) {
                    //int conditional var
                    case "<" -> {
                        return Integer.parseInt(tokens[1]) < hashtable.get(tokens[3]);
                    }
                    case ">" -> {
                        return Integer.parseInt(tokens[1]) > hashtable.get(tokens[3]);
                    }
                    case "==" -> {
                        return Integer.parseInt(tokens[1]) == hashtable.get(tokens[3]);
                    }
                }
            }
            else{
                switch (tokens[2]) {
                    //int conditional int
                    case "<" -> {
                        return Integer.parseInt(tokens[1]) < Integer.parseInt(tokens[3]);
                    }
                    case ">" -> {
                        return Integer.parseInt(tokens[1]) > Integer.parseInt(tokens[3]);
                    }
                    case "==" -> {
                        return Integer.parseInt(tokens[1]) == Integer.parseInt(tokens[3]);
                    }
                }
            }
        }
        return true;
    }

    private void println(String token){
        //if token is a key
        if(hashtable.containsKey(token)){
            //print value of key
            System.out.println(hashtable.get(token));
        }
        //if token == "cls"
        else if(Objects.equals(token, "cls")){
            //clear screen
            System.out.println("\f");
        }
        else{
            //if token is an integer
            try{
                //print integer
                System.out.println(Integer.parseInt(token));
            }
            //if token is a string literal
            catch (NumberFormatException e){
                //print literal
                System.out.println(token.substring(1, token.length() - 2));
            }
        }
    }

    private void print(String token){
        //if token is a key
        if(hashtable.containsKey(token)){
            //print value of key
            System.out.print(hashtable.get(token));
        }
        //if token == "cls"
        else if(Objects.equals(token, "cls")){
            //clear screen
            System.out.print("\f");
        }
        else{
            //if token is an integer
            try{
                //print integer
                System.out.print(Integer.parseInt(token));
            }
            //if token is a string literal
            catch (NumberFormatException e){
                //print literal
                System.out.print(token.substring(1, token.length() - 2));
            }
        }
    }
}