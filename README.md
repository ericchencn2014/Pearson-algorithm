# Pearson-algorithm
This matlab code is responsible for recommending items to users by considering only the user-to-items ratings database. During the evaluation phase, it was observed that the code runs very slowly (due to the nature of huge ratings database). Hence while evaluating, only a fraction of users were considered. In order to re-run this code for different number of users, change value of ‘length_training_set_users’ to the desired number (there are 2 occurrences of this variable in the entire script).
This matlab code should be executed as follows:

octave> CFsimple_pearsons(‘filename’)
where filename is path to user-to-item ratings dataset.

CFsimple_pearsons_trust.m:
This matlab code is responsible for recommending items to users by considering the user-to-items ratings database as well as user-to-user trust database. As mentioned above, while taking readings only a fraction of users were considered. In order to re-run this code for different number of users, change value of ‘length_training_set_users’ to the desired number (there are 2 occurrences of this variable in the entire script).
This matlab code should be executed as follows:

octave> CFsimple_pearsons_trust(‘filename1’, ‘filename2’)
where filename1 is the path to user-to-item ratings dataset and
filename2 is the path to user-to-user trust dataset.
