include "globals.mzn";
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

%Soft constraint parameter
array[employees, horizon, shifts] of int: preferences;

%%Decision variables%%
array[employees, horizon] of var shifts: employeeAssigned;

%%FUNCTIONS%%
%Stretch
%Guarantees that the length of any stretch type lies between L and U

predicate stretch(array[int] of var int: I, int: L, int: U) =
        (forall(h in 2..(horizonLength-L)) (
          if I[h-1] = 4 /\ I[h] !=4 then forall(i in 1..(L-1))
            (I[h+i] !=4) endif) %Min
          /\
          forall(h in 1..(L-1))(if I[horizonLength-h-1] = 4 /\ I[horizonLength - h] != 4 then forall(d in (horizonLength-h)..horizonLength)(I[d] != 4)endif) %Min
          /\
          let {
          array[horizon] of var 0..1: employeeHasShift = [if I[s] != 4 then 1 else 0 endif | s in 1..length(I)  ];
          }
          in
          sliding_sum(0,U,U+1,employeeHasShift)); %Max

predicate stretchSameShift(array[int] of var int: I, int: L, int: U, int: shift) = (
forall(h in 2..(horizonLength-L)) (
          if (I[h-1] != I[h] /\ I[h] = shift) then forall(i in 0..(L-1))
            (I[h+i] = shift) endif) %Min
          /\
          forall(h in 1..(L-1))(if I[horizonLength-h] != I[horizonLength-h-1] /\ I[horizonLength-h] = shift then forall(d in (horizonLength-h)..horizonLength)(I[d] = shift)endif) %Min
          /\
          let {
          array[horizon] of var 0..1: employeeHasShift = [if I[s] = shift then 1 else 0 endif | s in 1..length(I)];
          }
          in
          sliding_sum(0,U,U+1,employeeHasShift)
); %Max


%%CONSTRAINTS%%
%1: Minimum coverage requirement
constraint forall(h in horizon)(global_cardinality_low_up(col(employeeAssigned,h),[1,2,3,4],row(shiftsPerDay,h),[amountOfEmployees,amountOfEmployees, amountOfEmployees,amountOfEmployees]));

%2: Minimum and maximum amount of shifts per nurse
constraint forall(e in employees)(global_cardinality_low_up(row(employeeAssigned,e),[4],[horizonLength - maxShifts],[horizonLength-minShifts]));

%3: No early shift after a night shift
array[1..2] of int: illegalPattern = [3,1];
constraint forall(e in employees, h in 1..horizonLength-1) (not(employeeAssigned[e,h] = illegalPattern[1] /\ employeeAssigned[e,h+1] = illegalPattern[2]));
%constraint forall(e in employees, h in 1..horizonLength-1)(if employeeAssigned[e,h] = 3 then employeeAssigned[e,h+1] != 1 endif);

%4: Minimum and maximum amount of consecutive shifts
constraint forall(e in employees)(stretch(row(employeeAssigned,e),minConsecShifts, maxConsecShifts));

%5: Minimum and maximum amount of same consecutive shifts
constraint forall(e in employees, shift in 1..4)(stretchSameShift(row(employeeAssigned,e),minConsecSameShifts[shift], maxConsecSameShifts[shift], shift)); 

%6: minimum and maximum amount of nurses per shift 
constraint forall(e in employees)(global_cardinality_low_up(row(employeeAssigned,e),[1,2,3,4],minPerShifts,maxPerShifts));

var int: objective = sum(e in employees, h in horizon)(preferences[e,h,employeeAssigned[e,h]]); 

solve maximize objective;

%%OUTPUT%%
output ["Day:"]
++ [" d\(h) " | h in horizon]
++ ["\nSh: "]
++ ["ELNF" | h in horizon]  
++ [if h = 1 then "\nE\(e): " endif
++ if fix(employeeAssigned[e,h]) = 1 then "\(fix(employeeAssigned[e,h]))___" elseif fix(employeeAssigned[e,h]) = 2 then "_\(fix(employeeAssigned[e,h]))__" elseif fix(employeeAssigned[e,h]) = 3 then "__\(fix(employeeAssigned[e,h]))_" else "___\(fix(employeeAssigned[e,h]))" endif | e in employees, h in horizon]
++ ["\nobjective=\(objective)"];





