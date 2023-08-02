%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

int: days = 7;
enum DaysInput = {Mon, Tue, Wed, Thu, Fri, Sat, Sun};
set of int: Days = 1..7;
set of DaysInput: WeekendInput = {Sat, Sun};

enum ShiftsInput = {Day, Evening, Night};
enum ShiftsAndOff = {Off} ++ S(Shifts);
int: shifts = card(ShiftsInput);
set of int: Shifts = 1..shifts;

int: employees;
set of int: Employees = 1..employees;
% Alternate view of schedule
int: weeks = employees;
set of int: Weeks = Employees; 

array[DaysInput, ShiftsInput] of int: requirements;
array[Days, Shifts] of int: requirement = requirements;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The actual schedule
array[Weeks, Days] of var 0..shifts: schedule;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Constraints
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Requirements met for each day
constraint forall(d in Days, s in Shifts)(sum(w in Weeks)(schedule[w,d] = s) = requirement[d,s]);

% At least 2 consecutive days off each week
constraint forall(w in Weeks)(sum(d in 1..days-1)(schedule[w,d] + schedule[w,d+1] = 0) >= 1);

% At most five days without rest
constraint forall(w in Weeks, d in 1..(2*days)-7)(sum(c in d..d+5)(if c > days then schedule[(w mod employees) + 1 ,(c mod 8) + 1] = 0 else schedule[w,c] = 0 endif) >= 1);

% At least 1 out of 3 weekends off.
constraint forall(w in Weeks)(sum(c in w..w+2)(schedule[(c mod employees)+1,6] + schedule[(c mod employees)+1,7] = 0)>= 1); 

% At most 2??? -> 3 night-shifts in a row, and then rest
% Can't allow any of the following patterns: ND | NE | NND | NNE | NNND | NNNE | NNNN | DN | EN (overconstrains but is equal to constraint model)
constraint let {
  array[Weeks, Days] of var 0..shifts+1: scheduleN = array2d(Weeks, Days, [if schedule[w, d] = 3 then 4 else schedule[w, d] endif | w in Weeks, d in Days]);
} in
forall(w in Weeks)(scheduleN[w,7] + scheduleN[(w mod employees)+ 1, 1] != 5 /\ scheduleN[w,7] + scheduleN[(w mod employees)+ 1, 1] != 6 )
/\
forall(w in Weeks, d in 1..6) (scheduleN[w,d] + scheduleN[w,d+1] != 5 /\ scheduleN[w,d] + scheduleN[w ,d+1] != 6)  ;  %ND, NE, DN, EN

constraint forall(w in Weeks, d in Days)(sum(c in d..d+3)(if c > days then schedule[(w mod employees) + 1 ,(c mod 8) + 1] else schedule[w,c] endif) <= 12);%NNNN

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
solve satisfy;


function string: display(0..shifts: shift) = 
    if shift = 1 then "D"
    elseif shift = 2 then "E"
    elseif shift = 3 then "N"
    else "-" endif;
output [
    concat([ display(fix(schedule[w, d])) ++ " " | d in Days]) ++ "\n"
  | w in Weeks
];

