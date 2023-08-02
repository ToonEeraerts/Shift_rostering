% Changes by MiniZinc Challenge Organisers
% - Changed var where clause in first no overlapping assignments constraint to a par where clause
% - Made second overlapping assignments redundant constraint a hard constraint
include "globals.mzn";

% Parameters
par int: n_shifts;
par int: n_employees;
par int: n_expertises;
array[EMPLOYEE] of par int: contract;
array[EMPLOYEE] of par set of EXPERTISE: employee_expertises;
array[SHIFT] of par EXPERTISE: req_expertise;
array[SHIFT] of par int: start_time;
array[SHIFT] of par int: stop_time;
array[SHIFT] of int: durations = [stop_time[s] - start_time[s] | s in SHIFT];
par int: time_units_per_hour;
par set of int: SHIFT     = 1..n_shifts;
par set of int: EMPLOYEE  = 1..n_employees;
par set of int: EXPERTISE = 1..n_expertises;
array[EMPLOYEE, SHIFT] of par bool: is_assigned;

% Validations
include "sort.mzn";
constraint assert(start_time=sort(start_time), "Start times should be sorted");

% Variables
array[EMPLOYEE] of var set of SHIFT: assigned :: output;
array[EMPLOYEE] of var int: contract_diff = [ sum (s in assigned[e]) (stop_time[s]-start_time[s]) - contract[e] | e in EMPLOYEE ];

% Functions
function bool: overlapping(SHIFT: s1, SHIFT: s2) = start_time[s1] < stop_time[s2] /\ start_time[s2] < stop_time[s1];

%%CONSTRAINTS%%
%Constraint 1: Assignments are kept 
constraint forall (e in EMPLOYEE, s in SHIFT where is_assigned[e,s]) (member(assigned[e],s));

constraint forall (e in EMPLOYEE, s in SHIFT where exists (e2 in EMPLOYEE where e != e2) (is_assigned[e2, s])) (not member(assigned[e],s)); %(redundant but improves speed)

%Constraint 2: No double assignments
constraint all_disjoint(assigned); 

%Constraint 3: No overlapping assignments except for the input assignements.
constraint forall(s1, s2 in SHIFT, e in EMPLOYEE where s1 != s2 /\ overlapping(s1, s2) /\ not is_assigned[e,s1] /\ not is_assigned[e, s2]) (not (member(assigned[e],s1) /\ member(assigned[e],s2)));

%constraint forall (e in EMPLOYEE)(
%let {
%    array[SHIFT] of var opt int: start = [if member(assigned[e],s) /\ not is_assigned[e,s] then start_time[s] else 0 endif | s in SHIFT];
%    array[SHIFT] of var int: duration = [if start[s] = 0 then 0 else durations[s] endif | s in SHIFT];
% } in
%      (disjunctive(start , duration))
%); 



%Constraint 4: Appropriate expertise required
constraint forall(e in EMPLOYEE, s in SHIFT) (if not (is_assigned[e,s] \/ member(employee_expertises[e], req_expertise[s])) then (not member(assigned[e], s)) endif);

%%OBJECTIVE%%
var int: number_assigned_shifts = sum (e in EMPLOYEE) (card(assigned[e]));
var int: summed_abs_contract_diff = sum (e in EMPLOYEE) (abs(contract_diff[e]));
par int: W = 1 + max(max (e in EMPLOYEE) (contract[e]), max (s in SHIFT) (stop_time[s] - start_time[s])); % Weight factor for objective to be lexicographical
var int: objective = W*number_assigned_shifts - summed_abs_contract_diff;
solve maximize objective;


%%OUTPUT%%
output [
  "All shifts: \(assigned)",
  "number_assigned_shifts = \(number_assigned_shifts);\n",
  "summed_abs_contract_diff = \(summed_abs_contract_diff);\n",
  "objective = \(objective);",
];