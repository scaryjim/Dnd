clc
clear
run("Monster_var_def.m")

enemy_AC = 16; %AC of the target

[num_dice, num_sides] = det_dice_pars(hit_dice); %get number of dice and size as vars

avg_roll = ((num_sides+1) / 2) * num_dice;
max_roll = num_sides * num_dice; %maximum possible damage roll

add_dmg = str_mod + item_dmg + rage*rage_dmg + GWM*10; %add'l damage on every attack
add_atk = str_mod + item_atk + prof - (5*GWM); %to-hit bonus

[crit_prob, mini_prob, miss_prob, reg_prob] = probs(enemy_AC, add_atk); %get probabilities

reg_dmg = reg_prob * (avg_roll + add_dmg);
mini_dmg = mini_prob * (max_roll + add_dmg);
crit_dmg = crit_prob * (max_roll + reg_dmg);
avg_dmg = num_attacks*(reg_dmg + mini_dmg + crit_dmg);

%=================================================
%advantage calculations

anti_crit = 1 - crit_prob;
anti_mini = 1 - mini_prob;
anti_reg = 1 - reg_prob;

adv_crit_prob = 1-anti_crit^2;
adv_mini_prob = 1-anti_mini^2;
adv_reg_prob = 1-miss_prob^2;

adv_reg_dmg = adv_reg_prob * (avg_roll + add_dmg);
adv_mini_dmg = adv_mini_prob * (max_roll + add_dmg);
adv_crit_dmg = adv_crit_prob * (max_roll + reg_dmg);
adv_avg_dmg = num_attacks*(adv_reg_dmg + adv_mini_dmg + adv_crit_dmg);



if reckless %if using reckless attack, use advantage
    avg_dmg = adv_avg_dmg;
end 

fprintf('the monster''s Average DPR against an AC of %d is: %f\n', enemy_AC, avg_dmg)


%probability calculation w/o adv
function [crit_prob, mini_prob, miss_prob, reg_prob] = probs(enemy_AC, add_atk)
run("Monster_var_def.m")

crit_min = 20; %lowest dice roll that crits
crit_range = 21-crit_min; %number of dice faces that result in crit

mini_min = enemy_AC + 10 - add_atk; %minimum dice roll that results in mini crit
if mini_min >=20
    mini_range = 0;
else
mini_range = crit_min - mini_min; %number of dice faces that result in mini crit
mini_range = max(0, mini_range);
end

hit_min = enemy_AC - add_atk;
if mini_min <20 %if they can get a mini, set that as upper limit.
hit_range = mini_min - hit_min;
else
    hit_range = 20 - hit_min;
end
miss_max = enemy_AC - (add_atk+1); %maximum dice roll that misses
miss_range = max(fail_max, miss_max); %number of faces that miss

crit_prob = crit_range / 20; %probability of different outcomes
mini_prob = mini_range / 20;
miss_prob = miss_range / 20;
reg_prob = hit_range / 20;
end


%dice determination
function [num_dice, num_sides] = det_dice_pars(hit_dice)
dice_parts = strsplit(hit_dice, 'd'); % split the string into two parts
num_dice = str2double(dice_parts{1}); % convert the first part to a number
num_sides = str2double(dice_parts{2}); % convert the second part to a number
end