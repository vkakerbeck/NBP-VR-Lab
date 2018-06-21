#Written by Laura Duesberg
#Edited by Viviane Kakerbeck

import scipy.io as spio
import numpy as np
import matplotlib.pyplot as plt

ViewedDirPath = "C:/Users/vivia/Dropbox/VR alignment/bachelor_master_Arbeiten/Laura/scripts/not_viewed_houses/not_viewed_data/"
AlignmentDir = "C:/Users/vivia/Dropbox/VR alignment/bachelor_master_Arbeiten/Laura/scripts/over_all_subjects/trials_mat"

def mat_to_py(AlignmentPath):
    '''
    converts mat struct with task results into (numpy) array

    Aufbau array: nach subject number aufsteigend sortiert.
    Ansonsten fast genauso wie original matlab struct:
    Relative > Trial_3s > Trial_Inf >
    Absolute > Trial_3s > Trial_Inf >
    Pointing > Trial_3s > Trial_Inf

    also adds extra column with information whether trial was correct or wrong
    '''
    # load list of VP numbers
    f = open("VP_numbers.txt","r")
    VP_numbers = []
    for line in f:
        VP_numbers.append(line.split('\n',1)[0])

    vp_array = []

    for number in VP_numbers:
        path = AlignmentPath+"/AlignmentVR_SubjNo_"+number+".mat"
        mat_contents = spio.loadmat(path)
        type_array = []
        for i,cond_1 in enumerate(["Relative", "Absolute", "Pointing"]):
            for j,cond_2 in enumerate(["Trial_3s", "Trial_Inf"]):
                trials_array = []
                for line in range(len(mat_contents['Output'][0][0][cond_1][cond_2][0][0])):
                    value_array = []
                    for column in range(len(mat_contents['Output'][0][0][cond_1][cond_2][0][0][line][0])):
                        value = mat_contents['Output'][0][0][cond_1][cond_2][0][0][line][0][column][0][0]
                        value_array.append(value)
                    # check if trial is correct(true or false
                    value_array.append(value_array[-1] == value_array[-3])
                    trials_array.append(value_array)

                type_array.append(trials_array)

        vp_array.append(type_array)
    return vp_array

def sort_out_unseen():

    f = open("VP_numbers.txt","r")
    VP_numbers = []
    for line in f:
        VP_numbers.append(line.split('\n',1)[0])

    vp_array = mat_to_py(AlignmentDir)
    for i in range(len(vp_array)):
    #for i in range(1):
        f2 = open(ViewedDirPath+VP_numbers[i]+"_not_viewed.txt","r")
        subject_unseen_list = []
        for line in f2:
            subject_unseen_list.append(int(line.split('\n',1)[0]))
        #vp_array[i]     # subjects
        for j in range(6):
            #vp_array[i][j]      # conditions for each subject
            for k in reversed(range(len(vp_array[i][j]))): # reversed in order not to run out of bounds
                if j<2 or j>3: # for rel and poi cond that have two houses
                    if vp_array[i][j][k][0] in subject_unseen_list or vp_array[i][j][k][1] in subject_unseen_list:
                        del(vp_array[i][j][k])
                else: # abs with only one house
                    if vp_array[i][j][k][0] in subject_unseen_list:
                        del(vp_array[i][j][k])
    return vp_array

def performance(data):
    '''
    calculates performance in the six different conditions for data given in form of converted mat struct
    '''
    performance = []
    for cond in range(6):
        count_trials = 0
        count_correct_trials = 0
        for subject in range(len(data)):
            for trial in range(len(data[subject][cond])):
                count_trials += 1
                if data[subject][cond][trial][-1]:
                    count_correct_trials += 1
        percentage = float(count_correct_trials) / count_trials
        performance.append([count_trials, count_correct_trials, percentage])

    return performance

def printPerformances(perf):
    conditions = ["Relative - 3s ","Relative - inf","Absolute - 3s ","Absolute - inf","Pointing 3s   ","Pointing - inf"]
    for i in range(6):
        print(conditions[i]+": Correct: "+str(perf[i][0])+" Wrong: "+str(perf[i][1])+" Performance: "+str(perf[i][2])[:5]+"%")
        

def sec_per_click():
    '''
    calculates how many seconds were needed per click on average, also lowest and highest amount of clicks and mean
    '''
    overall_mean_clicks = 0
    mean_click_count = 0
    min_click_count = 10000
    max_click_count = 0
    f = open("VP_numbers.txt","r")
    VP_numbers = []
    for line in f:
        VP_numbers.append(line.split('\n',1)[0])
    for i in range(len(VP_numbers)):
        f2 = open(ViewedDirPath+VP_numbers[i]+".txt","r")
        click_list = []
        click_count = 0
        for line in f2:
            click_list.append(line.split('\t',1)[1].split('\n',1)[0])
        for element in click_list:
            click_count += int(element)
        if click_count < min_click_count:
            min_click_count = click_count
        if click_count > max_click_count:
            max_click_count = click_count
        mean_click_count += 1800/float(click_count)
        overall_mean_clicks += click_count
    overall_mean_clicks /= len(VP_numbers)
    mean_click_count /= len(VP_numbers)
    all_values = [min_click_count, max_click_count, overall_mean_clicks, mean_click_count]
    return all_values

def printSecPerClick(data):
    print("Minimum number of houses clicked on in one session: "+str(data[0]))
    print("Maximum number of houses clicked on in one session: "+str(data[1]))
    print("Average number of houses clicked on in one session: "+str(data[2]))
    print("Average time looked at one house: "+str(data[3]))

def mean_views():
    '''
    calculates average number of views per house, also lowest and highest amount of views in all subjects
    '''
    mean_views = 0
    min_views = 1000
    max_views = 0
    f = open("VP_numbers.txt","r")
    VP_numbers = []
    for line in f:
        VP_numbers.append(line.split('\n',1)[0])
    for i in range(len(VP_numbers)):
        f2 = open(ViewedDirPath+VP_numbers[i]+".txt","r")
        view_count = 0
        for line in f2:
            view_count += 1
        mean_views += view_count
        if view_count < min_views:
            min_views = view_count
        if view_count > max_views:
            max_views = view_count
    mean_views /= len(VP_numbers)
    all_values = [min_views, max_views, mean_views]
    return all_values

def printMeanViews(data):
    print("Minimum number of clicks on one house: "+str(data[0]))
    print("Maximum number of clicks on one house: "+str(data[1]))
    print("Average number of clicks on one house: "+str(data[2]))

def performance_familiarity(k):
    '''
    sorts single performances of subjects relative to the familiarity to a house measured in # clicks (specified by k) into bins

    to calculate performance per bin put return value into performance() or overall_performance()
    '''
    data = sort_out_unseen()
    f = open("VP_numbers.txt","r")
    VP_numbers = []
    for line in f:
        VP_numbers.append(line.split('\n',1)[0])
    for subject in range(len(VP_numbers)):
        f2 = open(ViewedDirPath+VP_numbers[subject]+".txt","r")
        how_often_seen = {} # create dict
        for line in f2:
            house = int(line.split('_',1)[0].split('\n',1)[0]) # int because in data house name is also int
            number = int(line.split('\t',1)[1].split('\n',1)[0])
            how_often_seen[house] = number
        for cond in range(6):
            for trial in reversed(range(len(data[subject][cond]))):
                house_name = data[subject][cond][trial][0]
                house_name_2 = data[subject][cond][trial][1]
                if cond >= 2 and cond <= 3: # abs task
                    # if house name is not in trial delete
                    if how_often_seen[house_name] != k:
                        del(data[subject][cond][trial])
                else: # rel and poi
                    # if house name not in trial delete
                    if how_often_seen[house_name] != k and how_often_seen[house_name_2] != k:
                        del(data[subject][cond][trial])
                    # house name must be in trial, but if there is a house that has been seen less often delete anyways from this bin
                    elif how_often_seen[house_name] < k or how_often_seen[house_name_2] < k:
                        del(data[subject][cond][trial])
    return data

def overall_performance(data):
    '''
    gives back performance over all tasks, use especially for performance_familiarity
    '''
    count_trials = 0
    count_correct_trials = 0
    performance = []
    for cond in range(6):
        for subject in range(len(data)):
            for trial in range(len(data[subject][cond])):
                count_trials += 1
                if data[subject][cond][trial][-1]:
                    count_correct_trials += 1
    percentage = float(count_correct_trials) / count_trials

    return [count_trials, count_correct_trials, percentage]

def printOverallPerf(perf):
    print("Number of Trials: "+str(perf[0])+" Number of Correct Trials: "+str(perf[1])+" Performance: "+str(perf[2])[:5]+"%")

def angular_differences():
    degree_30 = [0,0] # first entry is counter of trials, second is counter of correct trials
    degree_60 = [0,0]
    degree_90 = [0,0]
    degree_120 = [0,0]
    degree_150 = [0,0]
    degree_180 = [0,0]
    data = sort_out_unseen()
    f = open("VP_numbers.txt","r")
    VP_numbers = []
    for line in f:
        VP_numbers.append(line.split('\n',1)[0])
    f2 = open(".\complete_list_houses.txt","r")
    angles = {}
    for line in f2:
        house = int(line.split('_',1)[0].split('n',1)[0])
        angle = int(line.split('_',1)[1].split('n',1)[0])
        angles[house] = angle
    for subject in range(len(VP_numbers)):
        for cond in range(6):
            for trial in range(len(data[subject][cond])):
                degree = 0
                if cond >= 2: # abs und poi
                    degree = abs(int(data[subject][cond][trial][-5])-int(data[subject][cond][trial][-6])) # save angular diff in var
                else: # rel
                    degree = abs(angles[data[subject][cond][trial][-5]]-angles[data[subject][cond][trial][-6]])
                if degree < 30 or degree > 330:
                    degree_30[0] += 1 # increment counter for overall trial with 30 degree diff
                    if data[subject][cond][trial][-1]:
                        degree_30[1] += 1 # increment counter for correct trial with 30 degree diff
                elif degree < 60 or degree > 300:
                    degree_60[0] += 1
                    if data[subject][cond][trial][-1]:
                        degree_60[1] += 1
                elif degree < 90 or degree > 270:
                    degree_90[0] += 1
                    if data[subject][cond][trial][-1]:
                        degree_90[1] += 1
                elif degree < 120 or degree > 240:
                    degree_120[0] += 1
                    if data[subject][cond][trial][-1]:
                        degree_120[1] += 1
                elif degree < 150 or degree > 210:
                    degree_150[0] += 1
                    if data[subject][cond][trial][-1]:
                        degree_150[1] += 1
                else:
                    degree_180[0] += 1
                    if data[subject][cond][trial][-1]:
                        degree_180[1] += 1
    performance = []
    performance.append(float(degree_30[1])/degree_30[0])
    performance.append(float(degree_60[1])/degree_60[0])
    performance.append(float(degree_90[1])/degree_90[0])
    performance.append(float(degree_120[1])/degree_120[0])
    performance.append(float(degree_150[1])/degree_150[0])
    performance.append(float(degree_180[1])/degree_180[0])

    return performance

def printAngPerformances(perf):
    conditions = ["30 Degree: ","60 Degree: ","90 Degree: ","120 Degree: ","150 Degree: ","180 Degree: "]
    for i in range(6):
        print(conditions[i]+str(perf[i]))
        
#Run Analysis:
allData = mat_to_py(AlignmentDir)# Extracts data from matrix and aranges it in array with info about [Housenumbers, logged answer, reaction time, correct answer, AnswerCorrect?]
only_seen = sort_out_unseen()# get performances for all houses that were clicked on (for relative and pointing trails where two houses were clicked on)
original_performance = performance(allData)#Calculate Overall Performancea
only_seen_performance = performance(only_seen)

def printOverallStats():
    print("Performances Overall:")
    printPerformances(original_performance)
    print("Performances on Clicked Houses:")
    printPerformances(only_seen_performance)
    print("Click Statistics in One Session")
    printSecPerClick(sec_per_click())
    print("Clicks on Houses Over all Subjects:")
    printMeanViews(mean_views())
    printAngPerformances(angular_differences())
##Just run this command to print all overall statistics
printOverallStats()

##With this command you can analyze the performance dependent on how often houses were clicked on:
##The number in performance_familiarity(x) defines a threshold of clicks. All task performances with houses clicked more than x times
##are going to be used for the calculation of the statistics.
##You can calculate and display the overall performance of examples with clicks>x with this command:

#printOverallPerf(overall_performance(performance_familiarity(5)))

##The task specific performances for houses with clicks>x can be displayed with this command:

#printPerformances(performance(performance_familiarity(5)))

##This can then of course be put into a loop and performance can be plottet in relation to "familiarity".
