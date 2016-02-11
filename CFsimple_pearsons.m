function CFsimple_pearsons(filename)
fprintf('Loading %s...\n', filename)
Y = load(filename);
p = randperm(length(Y));

% Reorders the matrix according to randomly generated vector p and
% assigns it to respective columns of Y.
Y(:,1) = Y(p, 1);
Y(:,2) = Y(p, 2);
Y(:,3) = Y(p, 3);

% split into 5 sets
numTrans = length(Y);

first = 1;
last = floor(numTrans/5);
printf('Going into evaluation mode now...\n');
fflush(stdout);

%for i =1:2
    recall = 0.0;
    precision = 0.0;
    
    % Selects the test set & training set for each iteration.
    % e.g. for iteration = 1: testY = Y(1:200041), trainY = Y(200042:1000209)
    testY = Y(first:last, :);
    trainY = [Y(1:(first-1), :); Y((last+1):end, :)];
    
    first = first + last;
    last = last + last;

    % Converts it into tuples like (user-id, movie-id) --> actual rating
    % which is nothing but a 2-D matrix.
    testSet = sparse(testY(:, 1), testY(:, 2), testY(:, 3));
    trainSet = sparse(trainY(:, 1), trainY(:, 2), trainY(:, 3));
    
    item_set = unique(Y(:, 2));
    training_set_users = unique(trainY(:, 1));
    
    fprintf('starting to compute sim matrix now...\n');
    fflush(stdout);
    
    sim = computeSimilarities(training_set_users, trainSet);
    fprintf('Computed sim matrix\n');
    fflush(stdout);

    length_training_set_users = length(training_set_users);
    length_training_set_users = 100;
    for i=1:length_training_set_users
        m = 1;
        k = 30;     % Number of Neighbors
        N = 10;     % Number of items to be recommended
        temp_list = [];
        test_user_list = [];
        recommended_list = [];
        recommended_ratings = [];

        activeUser = training_set_users(i);
        sim_vector = sim(activeUser, :);
        [s, indx] = sort(sim_vector, 'descend');
        neighbours = indx(1:k);
        % disp(neighbours);
     


        % Iterate over all the neighbours.
        for j=1:k
            count = 0;
            ratings_vector = trainSet(neighbours(j), :);
            [v, item_ids] = sort(ratings_vector, 'descend');
            for x=1:length(item_ids)
                if (ismember(item_ids(x), temp_list) == 0)
                    if count == 2
                        break;
                    else
                        temp_list(end + 1) = item_ids(x); 
                        count = count + 1;
                    end
                end
            end
        end 

        recommended_list = temp_list(1:N);


        % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        % This piece of code calculates precision and recall values for each user.
        test_user_list = find(testSet(activeUser, :));
        precision = precision + (length(intersect(test_user_list, recommended_list)) / length(recommended_list));
        if length(test_user_list) != 0
            recall = recall + (length(intersect(test_user_list, recommended_list)) / length(test_user_list));
        end
        % ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        
        fprintf('Processed %d user, Precision: %f, Recall: %f\n', i, precision, recall);
        fflush(stdout);
    end

    avg_precision = precision / length_training_set_users;
    avg_recall = recall / length_training_set_users;
   
    fprintf('avg_precision_value: %f\n', avg_precision); 
    fprintf('avg_recall_value: %f\n', avg_recall);
    fflush(stdout);

%end

% trainSet is really a 2-D array represented using tuple.
% In trainSet, user-ids are rows and movie-ids are columns.
% function sim=computeSimilarities(user, trainSet, trustSet)
function sim=computeSimilarities(training_set_users ,trainSet)

length_training_set_users = length(training_set_users);
length_training_set_users = 100;
for x=1:length_training_set_users
    a = training_set_users(x);
    a_movie_list = find(trainSet(a, :));
    a_avg_rating = mean(trainSet(a, :));

    for y=1:length_training_set_users
        num = 0.0;
        denom = 0.0;
        temp_num1 = 0.0;
        temp_num2 = 0.0;
        u = training_set_users(y);
        
        if a == u
            sim(a, u) = -1;
        else
            u_movie_list = find(trainSet(u, :)); 
            u_avg_rating = mean(trainSet(u, :));
            common_movie_list = intersect(a_movie_list, u_movie_list);
            m = length(common_movie_list);
            if m > 0
                % Calculating numerator of the pearson coefficient
                for i=1:m
                    num = num + ((trainSet(a, common_movie_list(i)) - a_avg_rating) * (trainSet(u, common_movie_list(i)) - u_avg_rating));
                end

                %Calculating denominator of the pearson coefficient
                for i=1:m
                    temp_num1 = temp_num1 + ((trainSet(a, common_movie_list(i)) - a_avg_rating).^2);
                end
                for i=1:m
                    temp_num2 = temp_num2 + ((trainSet(u, common_movie_list(i)) - u_avg_rating).^2);
                end
            
                denom = sqrt(temp_num1 * temp_num2);
                sim(a, u) = num / denom;
            else
                sim(a, u) = -1.0;
            end
        end
        % fprintf('%f\n', sim(a, u));
        % fflush(stdout);
    end
    fprintf('Calculated sim vector for user: %d\n', a);
    fflush(stdout);
end
