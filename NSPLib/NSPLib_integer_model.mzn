%%DATA%%
%Size parameters%
int: amountOfEmployees;
set of int: employees = 1..amountOfEmployees;
int: horizonLength;
set of int: horizon = 1..horizonLength;
int: amountOfShifts;
set of int: shifts = 1..amountOfShifts;

%Hard constraint parameters
array[horizon, shifts] of int: shiftsPerDay;
int: minShifts;
int: maxShifts;
int: minConsecShifts;
int: maxConsecShifts;

array[shifts] of int: minConsecSameShifts;
array[shifts] of int: maxConsecSameShifts;

array[shifts] of int: minPerShifts;
array[shifts] of int: maxPerShifts;

%Soft constraint parameters
array[employees, horizon, shifts] of int: preferences;

%%Decision variables%%
array[employees, horizon, shifts] of var 0..1: employeeAssigned;

%%CONSTRAINTS%%
%1: Minimum coverage requirement
constraint forall(h in horizon, s in shifts)(sum(e in employees)(employeeAssigned[e,h,s]) >= shiftsPerDay[h,s]);

%2: Minimum and maximum amount of shifts per nurse
constraint forall(e in employees)(sum(h in horizon)( employeeAssigned[e,h,4] != 1) >= minShifts);

constraint forall(e in employees)(sum(h in horizon)( employeeAssigned[e,h,4] != 1) <= maxShifts);

%3: One shift a day
constraint forall(e in employees, h in horizon)(sum(s in shifts)(employeeAssigned[e,h,s]) = 1);

%4: No early shift after a night shift
constraint forall(e in employees, h in 1..horizonLength-1)(employeeAssigned[e,h,3] + employeeAssigned[e,h+1,1] <= 1);

%5: Minimum and maximum amount of consecutive shifts
constraint forall(e in employees,c in 1..(minConsecShifts-1), h in 1..(horizonLength - (c+1)))(((employeeAssigned[e,h,4] != 1) + c - sum(j in (h+1)..(h+c))(employeeAssigned[e,j,4] != 1) + (employeeAssigned[e,h+c+1,4] != 1)) > 0);

constraint  forall(e in employees, h in 1..(horizonLength - maxConsecShifts))    (sum(c in 0..maxConsecShifts)(employeeAssigned[e,h+c,4] != 1) <= maxConsecShifts);

%6: Minimum and maximum amount of same consecutive shifts
constraint forall(e in employees, s in shifts, c in 1..(minConsecSameShifts[s]-1), h in 1..(horizonLength - (c+1)))(((employeeAssigned[e,h,s] = 1) + c - sum(j in (h+1)..(h+c))(employeeAssigned[e,j,s] = 1) + (employeeAssigned[e,h+c+1,s] = 1)) > 0);

constraint forall(e in employees, s in shifts, h in 1..(horizonLength - maxConsecSameShifts[s]))(sum(c in 0..maxConsecSameShifts[s])(employeeAssigned[e,h+c,s] = 1) <= maxConsecSameShifts[s]);

%7: minimum and maximum amount of specific shifts per nurse
constraint forall(e in employees, s in shifts)(sum(h in horizon)(employeeAssigned[e,h,s]) >= minPerShifts[s]);

constraint forall(e in employees, s in shifts)(sum(h in horizon)(employeeAssigned[e,h,s]) <= maxPerShifts[s]);

%%OBJECTIVE FUNCTION%%
var int: objective = sum(e in employees, h in horizon, s in shifts)(if employeeAssigned[e,h,s] = 1 then preferences[e,h,s] else 0 endif); 

solve maximize objective;

%%OUTPUT%%
output ["Day:"]
++ [" d\(h) " | h in horizon]
++ ["\nSh: "]
++ ["ELNF" | h in horizon]  
++ [if h = 1 /\ s = 1 then "\nE\(e): " endif
++ if (fix(employeeAssigned[e,h,s]) = 0) then "_" else "\(s)" endif | e in employees, h in horizon, s in shifts]
++ ["\nobjective=\(objective)"];