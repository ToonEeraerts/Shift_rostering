%%DATA%%
%Days
int: horizonLength;

%Shifts
int: amountOfShifts;
enum shiftIDs;
array[shiftIDs] of int: shiftLength; %in minutes
array[shiftIDs,shiftIDs] of 0..1: notNextShift;
%Most left column = original shift
%Columns with 1 can't take place after the original shift

%Employees
int: amountOfEmployees;
enum employeeIDs;
array[employeeIDs,shiftIDs] of int: maxShifts;
array[employeeIDs] of int: maxMin; %max minutes
array[employeeIDs] of int: minMin; %min minutes
array[employeeIDs] of int: maxConsecShifts; %max consecutive shifts
array[employeeIDs] of int: minConsecShifts; %min consecutive shifts
array[employeeIDs] of int: minConsecDaysOff; %min consecutive free days
array[employeeIDs] of int: maxWeekends;
int: maxDaysOff; %replaces horizonLength, lowers search time
array[employeeIDs,1..maxDaysOff] of int: daysOff;

%ShiftRequests 
int: amountOfShiftOnRequests;
array[employeeIDs, 0..(horizonLength-1), shiftIDs] of int: shiftOnRequests;

int: amountOfShiftOffRequests;
array[employeeIDs, 0..(horizonLength-1), shiftIDs] of int: shiftOffRequests;

%SectionCover
array[0..horizonLength-1,shiftIDs] of int: requirements;
array[0..horizonLength-1,shiftIDs] of int: weightForUnder;
array[0..horizonLength-1,shiftIDs] of int: weightForOver;

%%Decision variables%%
array[employeeIDs,0..horizonLength-1,shiftIDs] of var 0..1: employeeAssigned;
array[employeeIDs,1..round(horizonLength/7)] of var 0..1: employeeWorksOnWeekend;
array[0..horizonLength-1,shiftIDs] of var int:belowPrefCover;
array[0..horizonLength-1,shiftIDs] of var int:abovePrefCover;

%%Constraints%%
%1: An employee cannot be assigned more than one shift on a single day
constraint 
  forall(e in employeeIDs,d in 0..horizonLength-1) 
    (sum(s in shiftIDs)(employeeAssigned[e,d,s]) <= 1);
    
%2: Shift rotation: certain shifts cannot follow up on eachother for each employee
constraint 
  forall(e in employeeIDs, d in 0..horizonLength-2, s in shiftIDs, s2 in shiftIDs)
    (if notNextShift[s,s2] = 1 then employeeAssigned[e,d,s] + employeeAssigned[e,d+1,s2] <= 1 endif);

%3: Maximum number of shifts of each type for each employee
constraint 
  forall(e in employeeIDs, s in shiftIDs)
    (sum(d in 0..(horizonLength-1))(employeeAssigned[e,d,s]) <= maxShifts[e,s]);

%4: Minimum and maximum work time
constraint
  forall(e in employeeIDs)
    (sum(d in 0..(horizonLength-1), s in shiftIDs)(employeeAssigned[e,d,s]*shiftLength[s]) <= maxMin[e] /\ sum(d in 0..horizonLength-1, s in shiftIDs)(employeeAssigned[e,d,s]*shiftLength[s]) >= minMin[e]);

%5: Maximum consecutive shifts
constraint
  forall(e in employeeIDs, d in 0..(horizonLength-1 - maxConsecShifts[e]))
    (sum(c in 0..maxConsecShifts[e], s in shiftIDs)(employeeAssigned[e,d+c,s]) <= maxConsecShifts[e]);
    
%6: Minimum consecutive shifts
constraint
  forall(e in employeeIDs,c in 1..(minConsecShifts[e]-1), d in 0..(horizonLength-1 - (c+1)))
    (sum(s in shiftIDs)(employeeAssigned[e,d,s]) + c-sum(j in (d+1)..(d+c), s in shiftIDs)(employeeAssigned[e,j,s]) + sum(s in shiftIDs)(employeeAssigned[e,d+c+1,s]) > 0);

%7: Minimum consecutive days off
constraint
  forall(e in employeeIDs, c in 1..(minConsecDaysOff[e]-1), d in 0..(horizonLength-1 - (c+1)))
    (1 - sum(s in shiftIDs)(employeeAssigned[e,d,s]) + sum(j in (d+1)..(d+c), s in shiftIDs)(employeeAssigned[e,j,s]) + 1 - sum(s in shiftIDs)(employeeAssigned[e,d+c+1,s]) >0);
    
%8: Maximum number of weekends
constraint
  forall(e in employeeIDs, w in 1..round(horizonLength/7))
    (employeeWorksOnWeekend[e,w] <= sum(s in shiftIDs)(employeeAssigned[e,7*w-2,s]) + sum(s in shiftIDs) (employeeAssigned[e,7*w-1,s]) /\ 2*employeeWorksOnWeekend[e,w] >= sum(s in shiftIDs)(employeeAssigned[e,7*w-2,s]) + sum(s in shiftIDs) (employeeAssigned[e,7*w-1,s]));

constraint
  forall(e in employeeIDs)
    (sum(w in 1..round(horizonLength/7))(employeeWorksOnWeekend[e,w]) <= maxWeekends[e]);

%9: Days off
constraint 
  forall(e in employeeIDs, d in 1..maxDaysOff, s in shiftIDs)
    (employeeAssigned[e,daysOff[e,d],s]=0);
    
%10: Cover requirements
constraint 
  forall(d in 0..(horizonLength-1), s in shiftIDs)
    (abovePrefCover[d,s]>=0 /\ belowPrefCover[d,s] >= 0);

constraint
  forall(d in 0..(horizonLength-1), s in shiftIDs)((sum(e in employeeIDs)(employeeAssigned[e,d,s]) - abovePrefCover[d,s] + belowPrefCover[d,s] = requirements[d,s]));
    
%%OBJECTIVE FUNCTION%%
var int: objective = sum(e in employeeIDs, d in 0..(horizonLength-1), s in shiftIDs)(shiftOnRequests[e,d,s]*(1-employeeAssigned[e,d,s])) + sum(e in employeeIDs, d in 0..(horizonLength-1), s in shiftIDs)(shiftOffRequests[e,d,s]*employeeAssigned[e,d,s]) + sum(d in 0..(horizonLength-1), s in shiftIDs)(belowPrefCover[d,s]*weightForUnder[d,s])+ sum(d in 0..(horizonLength-1), s in shiftIDs)(abovePrefCover[d,s]*weightForOver[d,s]);

%%Output%%

output ["objective=\(objective)\n",
"EmployeeAssigned=\(employeeAssigned))\n",
"EmployeeWorksOnWeekend=\(employeeWorksOnWeekend)\n",
"requirements=\(requirements)\n",
"abovePrefCover=\(abovePrefCover)\n",
"belowPrefCover=\(belowPrefCover)\n"];

solve minimize objective;
