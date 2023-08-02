include "globals.mzn";
%%DATA%%
%Days
int: horizonLength;

%Shifts
int: amountOfShifts;
enum shiftIDs;
array[shiftIDs] of int: shiftLength; %in minutes
array[shiftIDs,shiftIDs] of 0..1: notNextShift;

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
array[employeeIDs,day, shiftIDs] of int: shiftOnRequests;

int: amountOfShiftOffRequests;
array[employeeIDs,day, shiftIDs] of int: shiftOffRequests;

%SectionCover
array[day,shiftIDs] of int: requirements;
array[day,shiftIDs] of int: weightForUnder;
array[day,shiftIDs] of int: weightForOver;

%ExtraParameters
set of int: day = 0..horizonLength-1;
enum shiftOrNothing = S(shiftIDs) ++ { Nothing };


%%Decision variables%%
array[employeeIDs, day] of var shiftOrNothing: employeeAssigned;
array[day, shiftIDs] of var int: belowPrefCover;
array[day, shiftIDs] of var int: abovePrefCover;


%%CONSTRAINTS%%
%1: Shift rotation: certain shifts cannot follow up on eachother for each employee
constraint forall(e in employeeIDs, d in 0..horizonLength-2)(if employeeAssigned[e,d]!=Nothing /\ employeeAssigned[e,d+1]!=Nothing then                 notNextShift[S^-1(employeeAssigned[e,d]),S^-1(employeeAssigned[e,d+1])] != 1 endif);

%2: Maximum number of shifts of each type for each employee
array[int] of int:lower_bound = [0 | _ in shiftIDs];

constraint forall(e in employeeIDs)(global_cardinality_low_up(row(employeeAssigned, e), shiftIDs, lower_bound, row(maxShifts, e)));

%3: Minimum and maximum work time
constraint forall(e in employeeIDs)(member(minMin[e]..maxMin[e], sum( s in shiftIDs) (count(row(employeeAssigned,e), S(s))*shiftLength[s])));

%4: Maximum consecutive shifts
constraint forall(e in employeeIDs)(sliding_sum(1,maxConsecShifts[e]+1,maxConsecShifts[e]+1, [s = Nothing | s in row(employeeAssigned, e)]));

%5: Minimum consecutive shifts
constraint forall(e in employeeIDs, d in 1..(horizonLength - (minConsecShifts[e])))(if employeeAssigned[e,d-1] = Nothing /\ employeeAssigned[e,d] != Nothing then (count(employeeAssigned[e,d..d+minConsecShifts[e]-1], Nothing) = 0) endif);

constraint forall(e in employeeIDs, d in 1..minConsecShifts[e]-1)(if employeeAssigned[e,horizonLength-1-d] = Nothing /\ employeeAssigned[e,horizonLength-d] != Nothing then (count(employeeAssigned[e,(horizonLength - d)..horizonLength-1], Nothing) = 0) endif);

%6: Minimum consecutive days off
constraint forall(e in employeeIDs, d in 1..(horizonLength - minConsecDaysOff[e]))(if employeeAssigned[e,d-1] != Nothing /\ employeeAssigned[e,d] = Nothing then (count(employeeAssigned[e,d..d+minConsecDaysOff[e]-1], Nothing) = minConsecDaysOff[e]) endif);

constraint forall(e in employeeIDs, d in 1..minConsecDaysOff[e]-1)(if employeeAssigned[e,horizonLength-1-d] != Nothing /\ employeeAssigned[e,horizonLength-d] = Nothing then (count(employeeAssigned[e,(horizonLength - d)..horizonLength-1], Nothing) = d) endif);

%7: Maximum number of weekends
constraint forall(e in employeeIDs)(sum(d in 1..round(horizonLength/7))((employeeAssigned[e,(d*7)-2] != Nothing) \/ (employeeAssigned[e,(d*7)-1] != Nothing)) <= maxWeekends[e]);

%8: Days off
constraint forall(e in employeeIDs, d in 1..maxDaysOff)(element(daysOff[e, d], employeeAssigned[e, 0..horizonLength-1], Nothing));

%9: Cover requirements
constraint forall(d in day, s in shiftIDs)(abovePrefCover[d,s]>=0 /\ belowPrefCover[d,s] >= 0 /\ (count(col(employeeAssigned, d), S(s)) - abovePrefCover[d,s] + belowPrefCover[d,s] = requirements[d,s])); 

%%OBJECTIVE FUNCTION%%
var int: objective = sum(e in employeeIDs, d in day, s in shiftIDs)(shiftOnRequests[e,d,s]*(1-(employeeAssigned[e,d] = S(s)))) + sum(e in employeeIDs, d in day, s in shiftIDs)(shiftOffRequests[e,d,s]*(employeeAssigned[e,d] = S(s)))+ sum(d in 0..(horizonLength-1), s in shiftIDs)(belowPrefCover[d,s]*weightForUnder[d,s])+ sum(d in 0..(horizonLength-1), s in shiftIDs)(abovePrefCover[d,s]*weightForOver[d,s]);
solve minimize objective;

%%OUTPUT%%

output ["Objective:\(objective)"]
++ [if d = 0 then "\n" endif
++ if (fix(employeeAssigned[e,d]) = Nothing) then "\t" else "\(S^-1(employeeAssigned[e,d]))\t" endif | e in employeeIDs , d in day];

