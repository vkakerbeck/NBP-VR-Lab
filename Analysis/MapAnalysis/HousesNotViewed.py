DirPath = "C:/Users/vivia/Dropbox/VR alignment/bachelor_master_Arbeiten/Laura/scripts/not_viewed_houses/not_viewed_data/"

e = open("VP_numbers.txt","r")
VP_numbers = []
for line in e:
    VP_numbers.append(line.split('\n',1)[0])

for number in VP_numbers:
    f = open(DirPath+number+".txt","r")
    g = open("./complete_list_houses.txt","r")
    subjectList = []    # list of houses viewed by subject
    completeList = []   # complete list of houses
    not_viewedList = []

    # walk through lines in list, i is a str, use split(str, no of splits)[location],
    # get only house names, ignore everything after _
    for i in f:
        subjectList.append(i.split('_',1)[0])
    print('subject list count:',len(subjectList))
    # same for the other list
    for j in g:
        completeList.append(j.split('_',1)[0])
    print('complete count:',len(completeList))
    # walk through items in subjectList
    for element in subjectList:
        # find same item(=house number) in complete list of houses and remove
        if element in completeList:
            completeList.remove(element)
        else:
            print(element)

    #print 'not viewed count:',len(completeList)
    #not_viewedList.extend('subject list count:',len(subjectList))
    # reintroduce newline characters
    not_viewedList = "\n".join(completeList)
    #print(not_viewedList)
    h = open(DirPath+number+"_not_viewed.txt","w")
    for item in not_viewedList:
        h.write(item)
    #h.writelines(not_viewedList)
