clc
% Set up parameters
AC = 17; % Monster armor class
num_attacks = 3; % Number of attacks
advantage = true; % Boolean flag for advantage on first attack
to_hit = 9; % Monk's to-hit bonus
dmg_bonus = 6.6; % Monk's damage bonus
dmg_die = '1d6'; % Monk's martial arts die
elven_accuracy = true; % Boolean flag for Elven Accuracy feat
Total_DMG = 0;
verify = 0;

% Set up counters and totals
crit_counter = 0;
hit_counter = 0;
miss_counter = 0;
damage_total = 0;

dataset = 100000;

for p = 1:dataset
% Loop through each attack
for i = 1:num_attacks
    % Determine if attack is made at advantage

    if advantage
        if elven_accuracy % Use Elven Accuracy if available
            rolls = [randi(20), randi(20), randi(20)];
            attack_roll = max(rolls);
        else
            rolls = [randi(20), randi(20)];
            attack_roll = max(rolls);
        end
    else
        rolls = randi(20);
        attack_roll = max(rolls);
    end
    
    % Check for mini-crit
    if attack_roll >= AC + 10
        mini_crit = true;
    else
        mini_crit = false;
    end
    
    % Calculate attack result
    if attack_roll == 20 % Critical hit
        crit_counter = crit_counter + 1;
        damage_roll = roll_dice(dmg_die) + str2double(dmg_die(end)) + dmg_bonus;
        advantage = true; % Subsequent attacks made at advantage

    elseif attack_roll == 1 % Critical miss
        miss_counter = miss_counter + 1;
        damage_roll = 0;

    elseif attack_roll + to_hit >= AC % Hit
        hit_counter = hit_counter + 1;

        if mini_crit % Apply mini-crit damage
            damage_roll = str2double(dmg_die(end)) + dmg_bonus;

        else
            damage_roll = roll_dice(dmg_die) + dmg_bonus;
        end
    else % Miss
        miss_counter = miss_counter + 1;
        damage_roll = 0;
    end
    
    % Add damage to total
    damage_total = damage_total + damage_roll;
end

% Calculate DPR
advantage = false;
Total_DMG = damage_total + Total_DMG;
damage_total = 0;
end

DPR = Total_DMG/dataset;
verify = hit_counter + miss_counter + crit_counter;

% Display results
fprintf('Number of hits: %d\n', hit_counter + crit_counter)
fprintf('Number of misses: %d\n', miss_counter)
fprintf('Number of critical hits: %d\n', crit_counter)
fprintf('Total damage dealt: %d\n', Total_DMG)
fprintf('Average Damage Per Round: %d\n', DPR)
fprintf('\nDouble Check: %d\n', verify)


% Function to roll dice
function roll = roll_dice(die)
    rolls = str2num(die(1));
    sides = str2num(die(3:end));
    roll = sum(randi(sides, [1, rolls]));
end
