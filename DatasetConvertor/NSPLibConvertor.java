import java.io.*;

public class NSPLibConvertor {
    public NSPLibConvertor() {
    }
    public void convertCoreDatasets() throws IOException {
        // Core dataset
        int[] sets = {25, 30, 50, 60, 75, 100};
        for (int set : sets) {
            for (int r = 1; r <= 10; r++) {
                File file = new File(
                        "C:\\Users\\tonie\\Documents\\4de jaar unief\\Masterproef\\Datasets\\DatasetConverter\\DatasetConverter\\dataset NSPLib\\instances\\N" + set + "\\" + r + ".nsp");
                //Minizinc dataset
                File fileMZ = new File("DatasetConverter/dataset NSPLib/minizinc_datafiles/core_datafiles/N" + set + "_" + r + "nsp.dzn");
                BufferedReader br = new BufferedReader(new FileReader(file));
                BufferedWriter bw = new BufferedWriter(new FileWriter(fileMZ));

                // Size parameters
                String[] st = br.readLine().split("\t");
                int amountOfEmployees = Integer.parseInt(st[0]);
                int horizon = Integer.parseInt(st[1]);
                int amountOfShifts = Integer.parseInt(st[2]);
                bw.append("amountOfEmployees = " + amountOfEmployees + ";\n");
                bw.append("horizonLength = " + horizon + ";\n");
                bw.append("amountOfShifts = " + amountOfShifts + ";\n\n");
                br.readLine();

                // Shifts per day
                bw.append("shiftsPerDay = [|");
                for(int i = 0; i < horizon; i++){
                    st = br.readLine().split("\t");
                    for(int j = 0; j < amountOfShifts; j++){
                        bw.append(st[j]);
                        bw.append(",");
                    }
                    bw.append("\n|");
                }
                bw.append("];\n\n");
                br.readLine();

                // Employee preferences
                bw.append("preferences = array3d(" + "1.." + amountOfEmployees + ",1.." + horizon + ",1.." + amountOfShifts + ",[");
                for(int i = 0; i < amountOfEmployees; i++){
                    st = br.readLine().split("\t");
                    for(int j = 0; j < horizon; j++){
                        for(int k = 0; k < amountOfShifts; k++){
                            bw.append(st[j*amountOfShifts + k]);
                            bw.append(",");
                        }
                    }
                }
                bw.append("]);");

                br.close();
                bw.close();
            }
        }
    }
    public void convertExtendedDataset(int set, int instance, int casenr) throws IOException {

        File core_file = new File("C:\\Users\\tonie\\Documents\\4de jaar unief\\Masterproef\\Datasets\\DatasetConverter\\DatasetConverter\\dataset NSPLib\\instances\\N" + set + "\\" + instance + ".nsp");
        File case_file = new File("C:\\Users\\tonie\\Documents\\4de jaar unief\\Masterproef\\Datasets\\DatasetConverter\\DatasetConverter\\dataset NSPLib\\instances\\cases\\" + casenr + ".gen");
        //Minizinc dataset
        File fileMZ = new File("DatasetConverter/dataset NSPLib/minizinc_datafiles/extended_datafiles/N" + set + "_" + instance + "nsp_case" + casenr + ".dzn");
        BufferedReader br = new BufferedReader(new FileReader(core_file));
        BufferedReader br2 = new BufferedReader(new FileReader(case_file));
        BufferedWriter bw = new BufferedWriter(new FileWriter(fileMZ));

        // Size parameters
        String[] st = br.readLine().split("\t");
        int amountOfEmployees = Integer.parseInt(st[0]);
        int horizon = Integer.parseInt(st[1]);
        int amountOfShifts = Integer.parseInt(st[2]);
        bw.append("amountOfEmployees = " + amountOfEmployees + ";\n");
        bw.append("horizonLength = " + horizon + ";\n");
        bw.append("amountOfShifts = " + amountOfShifts + ";\n\n");
        br.readLine();

        // Shifts per day
        bw.append("shiftsPerDay = [|");
        for(int i = 0; i < horizon; i++){
            st = br.readLine().split("\t");
            for(int j = 0; j < amountOfShifts; j++){
                bw.append(st[j]);
                bw.append(",");
            }
            bw.append("\n|");
        }
        bw.append("];\n\n");
        br.readLine();

        // Employee preferences
        bw.append("preferences = array3d(" + "1.." + amountOfEmployees + ",1.." + horizon + ",1.." + amountOfShifts + ",[");
        for(int i = 0; i < amountOfEmployees; i++){
            st = br.readLine().split("\t");
            for(int j = 0; j < horizon; j++){
                for(int k = 0; k < amountOfShifts; k++){
                    bw.append(st[j*amountOfShifts + k]);
                    bw.append(",");
                }
            }
        }
        bw.append("]);");

        // Asserts
        st = br2.readLine().split("\t");
        assert(Integer.parseInt(st[0]) == horizon && Integer.parseInt(st[1]) == amountOfShifts) : "Case cannot be combined with core set";
        br2.readLine();

        // Min and Max shifts per employee
        st = br2.readLine().split("\t");
        bw.append("\n\nminShifts = " + st[0] + ";\n");
        bw.append("maxShifts = " + st[1] + ";\n");
        br2.readLine();

        // Min and Max consec shifts
        st = br2.readLine().split("\t");
        bw.append("minConsecShifts = " + st[0] + ";\n");
        bw.append("maxConsecShifts = " + st[1] + ";\n\n");
        br2.readLine();
        br2.readLine();

        // Min and Max consec shifts per shift & min/max assignments per shift
        int[] minConsecSameShift = new int[amountOfShifts];
        int[] maxConsecSameShift = new int[amountOfShifts];
        int[] minSameShift = new int[amountOfShifts];
        int[] maxSameShift = new int[amountOfShifts];

        for(int i = 0; i < amountOfShifts; i++){
            st = br2.readLine().split("\t");
            minConsecSameShift[i] = Integer.parseInt(st[0]);
            maxConsecSameShift[i] =  Integer.parseInt(st[1]);
            minSameShift[i] =  Integer.parseInt(st[2]);
            maxSameShift[i] =  Integer.parseInt(st[3]);
        }

        bw.append("minConsecSameShifts = [" + minConsecSameShift[0]);
        for(int i = 1; i < amountOfShifts; i++){
            bw.append("," + minConsecSameShift[i]);
        }
        bw.append("];\n");

        bw.append("maxConsecSameShifts = [" + maxConsecSameShift[0]);
        for(int i = 1; i < amountOfShifts; i++){
            bw.append("," + maxConsecSameShift[i]);
        }
        bw.append("];\n\n");

        bw.append("minPerShifts = [" + minSameShift[0]);
        for(int i = 1; i < amountOfShifts; i++){
            bw.append("," + minSameShift[i]);
        }
        bw.append("];\n");

        bw.append("maxPerShifts = [" + maxSameShift[0]);
        for(int i = 1; i < amountOfShifts; i++){
            bw.append("," + maxSameShift[i]);
        }
        bw.append("];");

        br.close();
        bw.close();
    }
}
