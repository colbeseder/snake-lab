% Helper functions

function [new_snake] = move_snake(old_snake, direction, grow)
    remove = 0 ;
    if grow < 1
        remove = 1;
    end
    new_head = old_snake(1,:) + direction;
    new_snake = [new_head; old_snake(1:end-remove, :)];
end

function [result] = is_collided(old_snake, new_head, grow)
    result = 0;
    for i = 1:2
        n = new_head(i);
        if n < 1 || n > 30 % head is at edge of board
            result = 1;
        end
    end
    stop = size(old_snake, 1) -1; % as last segment will be removed
    if grow
        stop = stop + 1;
    end
    % Check if new head is same location as part of the body
    for i = 1:stop % skip head
        if old_snake(i,:) == new_head
            result = 1;
        end
    end
end

function [food] = get_new_food_location(snake)
    while true
        % Pick a random location
        food = randi([1,30],1,2);
        if ~is_collided(snake, food, 1) % re-pick if food is inside the snake
            break
        end
    end
end

function [snake, food, ate_food, isLost] = step(snake, food, direction, score)
    isLost = 0;
    ate_food = 0;

    if snake(1,:) == food
        ate_food = 1;
    end
    [new_snake] = move_snake(snake, direction, ate_food);
    if ate_food
        food = get_new_food_location(new_snake);
        score = score +1;
    end
    [collision] = is_collided(snake, new_snake(1,:), ate_food);
    if collision
        isLost = 1;
        board = ones(30, 30);
    else
            snake = new_snake ;
            board = zeros(30, 30);
            for i = 1:size(snake, 1)
                board(snake(i, 1), snake(i,2)) = 4;
            end
            board(food(1), food(2)) = 10;
    end
    paint(board, score)
end

function [current_direction] = choose_direction(current_direction)
    
    directions = [
        -1,  0; % up
         0, -1; % left
         1,  0; % down
         0,  1  % right
    ] ;
    
    direction_keys = ['w', 'a', 's', 'd'];

    key = get(gcf,'CurrentCharacter');
    if ~isempty(key)
        direction_idx = find(direction_keys==key);
        if ~isempty(direction_idx) && direction_idx > 0 && direction_idx < 5
            new_direction = directions(direction_idx,:);
            % don't allow 180 turns
            if not( new_direction + current_direction == [0, 0])
                current_direction = new_direction;
            end
        end
    end
end

function paint(board, score)
    hm = heatmap(board);
    hm.ColorbarVisible = 'off';
    hm.GridVisible = 'off';
    hm.Colormap = parula;
    hm.Title = sprintf('Score: %d', score);
    empty_labels = cell(1, 30);
    empty_labels(:) = {""};

    hm.XDisplayLabels = empty_labels;
    hm.YDisplayLabels = empty_labels;
end

function game(init_snake, init_food, speed)
    
    % initialize game
    score = 0;
    snake = init_snake;
    food = init_food;
    current_direction = [0, 1]; % right

    while true
        current_direction = choose_direction(current_direction);
        [snake, food, ate_food, lost] = step(snake, food, current_direction, score);
        if ate_food
            score = score + 1;
        end
        if lost
            disp(["Game Over. Score: ", score])
            break
        end
        pause(1/speed)
    end
end

% Entry Point

% Clean environment
clearvars
clc

% Initialize
snake = [15, 10; 15, 9; 15, 8; 15, 7; 15, 6; 15, 5];
food = [15, 19];
speed = 10;

game(snake, food, speed)