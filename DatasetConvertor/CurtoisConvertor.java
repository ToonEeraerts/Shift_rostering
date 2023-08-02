import java.io.*;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Objects;
import java.util.Scanner;

public class CurtoisConvertor {
    public ArrayList<String> employeeIDs;
    public ArrayList<String>  shiftIDs;
    public int horizonLength;
    int x;
    public CurtoisConvertor() {

    }

    public void convertDataset(int x) throws IOException {

        //Curtois dataset
        this.x = x;
        File file = new File(
                "C:\\Users\\tonie\\Documents\\4de jaar unief\\Masterproef\\Datasets\\DatasetConverter\\" +
                        "DatasetConverter\\dataset Curtois\\instances1_24\\Instance" + x + ".txt");
        //Minizinc dataset
        File fileMZ = new File("/DatasetConvertor/dataset Curtois/minizinc_datafiles/Instance" + x + "Mz.dzn");
        BufferedReader br = new BufferedReader(new FileReader(file));
        BufferedWriter bw = new BufferedWriter(new FileWriter(fileMZ));
        String st;

        //SECTION_HORIZON
        for(int i =0; i <4; i++){
            br.readLine();
        }
        st = br.readLine();
        int horizonLength = Integer.parseInt(st);
        bw.append("horizonLength = " + horizonLength + ";\n\n");
        ////////////////////
        // SECTION_SHIFTS //
        ////////////////////
        for(int i =0; i <3; i++){
            br.readLine();
        }
        ArrayList<String> lines = new ArrayList<>();

        //amountOfShifts
        int amountOfShifts = -1;
        st = br.readLine();
        while(!Objects.equals(st, "SECTION_STAFF")){
            lines.add(st);
            amountOfShifts++;
            st = br.readLine();
        }
        bw.append("amountOfShifts = " + amountOfShifts + ";\n");
        //shiftID
        bw.append("shiftIDs = [");
        shiftIDs = new ArrayList<>();
        for(int i =0;i<amountOfShifts-1; i++){
            String shiftID = lines.get(i).split(",")[0];
            shiftIDs.add(shiftID);
            bw.append(shiftID);
            bw.append(",");
        }
        String shiftID = lines.get(amountOfShifts-1).split(",")[0];
        shiftIDs.add(shiftID);
        bw.append(shiftID);
        bw.append("];\n");

        //shiftLength
        bw.append("shiftLength = [");
        for(int i =0;i<amountOfShifts-1; i++){
            bw.append(lines.get(i).split(",")[1]);
            bw.append(",");
        }
        bw.append(lines.get(amountOfShifts-1).split(",")[1]);
        bw.append("];\n");

        //notNextShift
        String[][] notNextShift = new String[amountOfShifts][amountOfShifts];
        for(int i =0; i < amountOfShifts; i++){
            for(int j =0; j<amountOfShifts; j++){
                notNextShift[i][j] = "0"; //Initializatie
            }
        }

        bw.append("notNextShift = [|");
        for(int i =0; i<amountOfShifts;i++){
            if(lines.get(i).split(",").length==3) {
                int amount = lines.get(i).split(",")[2].split("\\|").length;
                for (int j = 0; j < amount; j++) {
                    String shiftID2 = lines.get(i).split(",")[2].split("\\|")[j];
                    int index = shiftIDs.indexOf(shiftID2);
                    //System.out.println(shiftID2 + "|" + index);
                    notNextShift[i][index] = "1";
                }
            }
        }

        for(int i =0; i < amountOfShifts; i++){
            for(int j =0; j<amountOfShifts-1; j++){
                bw.append(notNextShift[i][j]);
                bw.append(",");
            }
            bw.append(notNextShift[i][amountOfShifts-1]);
            bw.append("\n|");
        }
        bw.append("];\n\n");
        /////////////////
        //SECTION_STAFF//
        /////////////////
        br.readLine();
        lines = new ArrayList<>();

        //amountOfEmployees
        int amountOfEmployees= -1;
        st = br.readLine();
        while(!Objects.equals(st, "SECTION_DAYS_OFF")){
            lines.add(st);
            amountOfEmployees++;
            st = br.readLine();
        }
        bw.append("amountOfEmployees = " + amountOfEmployees + ";\n");

        //employeeID
        bw.append("employeeIDs = [e");
        ArrayList<String> employeeIDs = new ArrayList<>();
        for(int i =0;i<amountOfEmployees-1; i++){
            String employeeID = lines.get(i).split(",")[0];
            employeeIDs.add(employeeID);
            bw.append(employeeID);
            bw.append(",e");
        }
        String employeeID = lines.get(amountOfEmployees-1).split(",")[0];
        employeeIDs.add(employeeID);
        bw.append(employeeID);
        bw.append("];\n");

        //maxShifts
        bw.append("maxShifts = [|");
        for(int i=0; i<amountOfEmployees; i++){
            for(int j=0; j <amountOfShifts-1; j++){
                String amount = lines.get(i).split(",")[1].split("\\|")[j].split("=")[1];
                bw.append(amount);
                bw.append(",");
            }
            bw.append(lines.get(i).split(",")[1].split("\\|")[amountOfShifts-1].split("=")[1]);
            bw.append("\n|");
        }
        bw.append("];\n");

        //maxMin
        bw.append("maxMin = [");
        for(int i =0;i<amountOfEmployees-1; i++){
            bw.append(lines.get(i).split(",")[2]);
            bw.append(",");
        }
        bw.append(lines.get(amountOfEmployees-1).split(",")[2]);
        bw.append("];\n");

        //minMin
        bw.append("minMin = [");
        for(int i =0;i<amountOfEmployees-1; i++){
            bw.append(lines.get(i).split(",")[3]);
            bw.append(",");
        }
        bw.append(lines.get(amountOfEmployees-1).split(",")[3]);
        bw.append("];\n");

        //maxConsecShifts
        bw.append("maxConsecShifts = [");
        for(int i =0;i<amountOfEmployees-1; i++){
            bw.append(lines.get(i).split(",")[4]);
            bw.append(",");
        }
        bw.append(lines.get(amountOfEmployees-1).split(",")[4]);
        bw.append("];\n");

        //minConsecShifts
        bw.append("minConsecShifts = [");
        for(int i =0;i<amountOfEmployees-1; i++){
            bw.append(lines.get(i).split(",")[5]);
            bw.append(",");
        }
        bw.append(lines.get(amountOfEmployees-1).split(",")[5]);
        bw.append("];\n");

        //minConsecDaysOff
        bw.append("minConsecDaysOff = [");
        for(int i =0;i<amountOfEmployees-1; i++){
            bw.append(lines.get(i).split(",")[6]);
            bw.append(",");
        }
        bw.append(lines.get(amountOfEmployees-1).split(",")[6]);
        bw.append("];\n");

        //maxWeekends
        bw.append("maxWeekends = [");
        for(int i =0;i<amountOfEmployees-1; i++){
            bw.append(lines.get(i).split(",")[7]);
            bw.append(",");
        }
        bw.append(lines.get(amountOfEmployees-1).split(",")[7]);
        bw.append("];\n");

        ////////////////////
        //SECTION_DAYS_OFF//
        ////////////////////
        br.readLine();

        //maxDaysOff
        st = br.readLine();
        int maxDaysOff = st.split(",").length-1;
        bw.append("maxDaysOff = " + maxDaysOff + ";\n");

        //daysOff
        bw.append("daysOff = [|");
        for(int i=1; i<maxDaysOff; i++){
            bw.append(st.split(",")[i]);
            bw.append(",");
        }
        bw.append(st.split(",")[maxDaysOff]);
        bw.append("\n|");

        for(int i=1; i<amountOfEmployees;i++){
            st = br.readLine();
            for(int j=1; j<maxDaysOff; j++){
                bw.append(st.split(",")[j]);
                bw.append(",");
            }
            bw.append(st.split(",")[maxDaysOff]);
            bw.append("\n|");
        }
        bw.append("];\n\n");

        /////////////////////////////
        //SECTION_SHIFT_ON_REQUESTS//
        /////////////////////////////
        for(int i = 0; i < 3; i++){
            br.readLine();
        }

        //AmountOfShiftOnRequests
        lines = new ArrayList<>();
        int amountOfShiftOnRequests= -1;
        st = br.readLine();
        while(!Objects.equals(st, "SECTION_SHIFT_OFF_REQUESTS")){
            lines.add(st);
            amountOfShiftOnRequests++;
            st = br.readLine();
        }
        bw.append("amountOfShiftOnRequests = " + amountOfShiftOnRequests + ";\n");

        //ShiftOnRequests
        bw.append("shiftOnRequests = array3d(e" + employeeIDs.get(0) + "..e" + employeeIDs.get(employeeIDs.size()-1) + ",0.." + (horizonLength-1) + "," + shiftIDs.get(0) + ".." + shiftIDs.get(shiftIDs.size()-1) + ",[");
        String[] shiftOnRequest = new String[amountOfEmployees*horizonLength*amountOfShifts];
        Arrays.fill(shiftOnRequest, "0");
        for(int i =0;i<amountOfShiftOnRequests; i++){
            employeeID = lines.get(i).split(",")[0];
            String day = lines.get(i).split(",")[1];
            String shiftId = lines.get(i).split(",")[2];
            String weight = lines.get(i).split(",")[3];
            shiftOnRequest[employeeIDs.indexOf(employeeID)*horizonLength*amountOfShifts + Integer.parseInt(day) * amountOfShifts + shiftIDs.indexOf(shiftId)]= weight;
        }

        for(int i =0;i<shiftOnRequest.length-1; i++){
            bw.append(shiftOnRequest[i]);
            bw.append(",");
        }
        bw.append(shiftOnRequest[shiftOnRequest.length-1]);
        bw.append("]);\n\n");

        //////////////////////////////
        //SECTION_SHIFT_OFF_REQUESTS//
        //////////////////////////////
        br.readLine();

        //AmountOfShiftOffRequests
        lines = new ArrayList<>();
        int amountOfShiftOffRequests= -1;
        st = br.readLine();
        while(!Objects.equals(st, "SECTION_COVER")){
            lines.add(st);
            amountOfShiftOffRequests++;
            st = br.readLine();
        }
        bw.append("amountOfShiftOffRequests = " + amountOfShiftOffRequests + ";\n");

        //ShiftOnRequests
        bw.append("shiftOffRequests = array3d(e" + employeeIDs.get(0) + "..e" + employeeIDs.get(employeeIDs.size()-1) + ",0.." + (horizonLength-1) + "," + shiftIDs.get(0) + ".." + shiftIDs.get(shiftIDs.size()-1) + ",[");
        String[] shiftOffRequest = new String[amountOfEmployees*horizonLength*amountOfShifts];
        Arrays.fill(shiftOffRequest, "0");
        for(int i =0;i<amountOfShiftOffRequests; i++){
            employeeID = lines.get(i).split(",")[0];
            String day = lines.get(i).split(",")[1];
            String shiftId = lines.get(i).split(",")[2];
            String weight = lines.get(i).split(",")[3];
            shiftOffRequest[employeeIDs.indexOf(employeeID)*horizonLength*amountOfShifts + Integer.parseInt(day) * amountOfShifts + shiftIDs.indexOf(shiftId)]= weight;
        }

        for(int i =0;i<shiftOffRequest.length-1; i++){
            bw.append(shiftOffRequest[i]);
            bw.append(",");
        }
        bw.append(shiftOffRequest[shiftOffRequest.length-1]);
        bw.append("]);\n\n");

        /////////////////
        //SECTION_COVER//
        /////////////////
        lines = new ArrayList<>();
        br.readLine();
        st = br.readLine();
        for(int i = 0; i <horizonLength*amountOfShifts; i++){
            lines.add(st);
            st = br.readLine();
        }

        //Requirement
        bw.append("requirements = array2d(0.." + (horizonLength-1) + "," + shiftIDs.get(0) + ".." + shiftIDs.get(shiftIDs.size()-1) +",[");
        for(int i = 0; i < horizonLength-1; i++){
            for(int j = 0; j < amountOfShifts; j++){
                bw.append(lines.get(i*amountOfShifts+j).split(",")[2]).append(",");
            }
        }
        for(int j = 0; j < amountOfShifts-1; j++){
            bw.append(lines.get((horizonLength-1)*amountOfShifts+j).split(",")[2]).append(",");
        }
        bw.append(lines.get((horizonLength-1)*amountOfShifts+amountOfShifts-1).split(",")[2]);
        bw.append("]);\n");

        //Weight for under
        bw.append("weightForUnder = array2d(0.." + (horizonLength-1) + "," + shiftIDs.get(0) + ".." + shiftIDs.get(shiftIDs.size()-1) +",[");
        for(int i = 0; i < horizonLength-1; i++){
            for(int j = 0; j < amountOfShifts; j++){
                bw.append(lines.get(i*amountOfShifts+j).split(",")[3]).append(",");
            }
        }
        for(int j = 0; j <amountOfShifts-1; j++){
            bw.append(lines.get((horizonLength-1)*amountOfShifts+j).split(",")[3]).append(",");
        }
        bw.append(lines.get((horizonLength-1)*amountOfShifts+amountOfShifts-1).split(",")[3]);
        bw.append("]);\n");

        //Weight for over
        bw.append("weightForOver = array2d(0.." + (horizonLength-1) + "," + shiftIDs.get(0) + ".." + shiftIDs.get(shiftIDs.size()-1) +",[");
        for(int i = 0; i < horizonLength-1; i++){
            for(int j = 0; j < amountOfShifts; j++){
                bw.append(lines.get(i*amountOfShifts+j).split(",")[4]).append(",");
            }
        }
        for(int j = 0; j <amountOfShifts-1; j++){
            bw.append(lines.get((horizonLength-1)*amountOfShifts+j).split(",")[4]).append(",");
        }
        bw.append(lines.get((horizonLength-1)*amountOfShifts+amountOfShifts-1).split(",")[4]);
        bw.append("]);\n");
        br.close();
        bw.close();
    }

    public void convertOutput() throws IOException {
        //Feasibility checker
        File file = new File("/DatasetConvertor/to_validate/toValidateInstance" + x + ".txt");

        BufferedWriter bw = new BufferedWriter(new FileWriter(file));
        Scanner sc = new Scanner(System.in);
        System.out.println("Do you have a solution to validate? (y/n)");
        String answer = sc.nextLine();
        if(Objects.equals(answer, "y")){
            System.out.println("Paste solution: ");
            answer = sc.nextLine();
            for(int e = 0; e < employeeIDs.size(); e++){
                for(int h = 0; h < horizonLength; h++){
                    for(int s = 0; s <shiftIDs.size(); s++){
                        //System.out.println((int)answer.charAt(s*3+1+h*e)-48);
                        if((int)answer.charAt((s*3+3*h*shiftIDs.size()+3*shiftIDs.size()*horizonLength*e)+1)-48 == 1) bw.append(shiftIDs.get(s));
                    }
                    bw.append("\t");
                }
                bw.append("\n");
            }
        }
        else{
            System.out.println("File written to solutions" );
        }
        bw.close();
        sc.close();
    }
}
