import math
import random
import datetime

print(math.pow(2,3))

#pythagoras
a = 3
b = 4
h = math.sqrt(a**2 + b**2)
a = math.sqrt(h**2 - b**2)

# divison, ingeter divison & modula, exponent
print(5/2)
print(5//2)
print(5%2)
print(5**2)
print(5**3)

# gerade ungerade (gerade ohne 0)
l =[25,34,193,2,81,26,44]
def is_even(n):
    return(n%2) == 0
for i in l:
    print(is_even(i))

# runden
print(math.ceil(31.8)) #aufrunden
print(math.trunc(31.8)) # abschneiden
print(math.floor(31.8)) #abrunden

#zufall
print(random.randint(1,10))
print(random.randrange(1,11,2))

#Zufall aus einer Liste nicht integer
def RPS():
    options = ['Rock', 'Paper', 'Scissors']
    return (random.choice(options))
print (RPS())

#shuffle elements
x = ['Anna', 'John', 'Mike', 'Sally']
random.shuffle(x)

print(x)
##zufällige karte
def pick_card():
    card_type = ['Cubs', 'Diamonds', 'Hearts', 'Spades']
    card_number = ['Ace', 2, 3, 4, 5, 6, 7, 8, 9, 10, 'Jack', 'Queen', 'King']

    t = random.choice(card_type)
    n = random.choice(card_number)
    return[n,t]

print(pick_card())

#Zeit
t = datetime.time(minute=10, hour=1)
print(t)
t = datetime.time(20,55,20,500)
print(t)
h = t.hour
m = t.minute
s = t.second
ms = t.microsecond
print("The time is: ", t.hour,"hours ", m, " minutes", s, " seconds")

#Datum
SpecialDate = datetime.date(day=23, month=4, year=2017)
SpecialDate = datetime.date(2013,5,16)
print(SpecialDate)
print(SpecialDate)
d = datetime.date.today()
print(d)
d = d + datetime.timedelta(days=4)
print(d)

#Zeit & Datum gemeinsam

dt = datetime.datetime.today()
print(dt)
print("The H is", dt.hour)
t = dt.time()
print(t)
d = dt.date()
print(d)
dt = datetime.datetime.combine(date = d, time = t)
print(dt)

#Formatierung Zeit/Datum objekte

t = datetime.time(hour=20, minute = 10)
formatted_string = t.strftime("%I:%M %p")
print(t, formatted_string)
d = datetime.date(year=1997, month=1, day=6)
formatted_string = d.strftime("%A %d %B %y")
print(d, formatted_string)
#################################################################################################################
#Break to improve efficency


# Find the index (with break)
def find_index():
    lst = [976, 618, 812, 898, 804, 689, 611, 630, 467, 411, 648, 931, 618]
    index = 0
    iteration_count = 0
    for num in lst:
        print(num)
        if (num == 611):
            found_at = index
            break # adding a break to improve efficiency
        index = index + 1
        iteration_count = iteration_count + 1
    print("Using a break, 611 was found at index:", found_at, "using", iteration_count, "iterations")

find_index()

#break infinite loop
def infinite_loop():
    while True:
        x = int(input("Enter number between 1-5: "))
        if(x>0):
            break
#infinite_loop()

def char_art(steps):
    for row in range(steps):
        for col in range(steps):
            if(col <= row):
                print("[]", end ="")
        print()
#char_art(6)

def sum_of_rows():
    table = [[5, 2, 6], [4, 6, 0], [9, 1, 8], [7, 3, 8]]
    for row in table:
        sum = 0
        for col in row:
            sum = sum + col
        print(sum)     
#sum_of_rows()
        
#check if somethings in list
def in_list(x):
    lst_container = [4,5,6,7,8]
    if(x in lst_container):
        print("it is in it")
    else:
        print("its not")
    lst_container = [4, [7, 3], 'string element']

    # 4 is an element in lst_container
    x = 4
    print(x, "contained in lst_container:", x in lst_container)

    # 7 is an element of a list inside lst_container, but it is NOT an element of the lst_container
    x = 7
    print(x, "contained in lst_container:", x in lst_container)

    # [7, 3] is an element of lst_container
    x = [7, 3]
    print(x, "contained in lst_container:", x in lst_container)
    in_list(10)

#equal and identical
def eq():
    # x, y: equal, identical 
    x = 5
    y = 5
    print("x equal y ? ", x == y)
    print("x is identical to y ?", x is y)
    x = 5.6
    y = 5.6
    print("x equal y ? ", x == y)
    print("x is identical to y ?", x is y)

    # Different lists containing the same data
    x = [4, 9, 8]
    y = [4, 9, 8]

    # x and y are equal, because they contain the same data
    # x and y are NOT identical, because they are saved in different memory locations
    print()
    print("x equal y ? ", x == y)
    print("x is identical to y ?", x is y)

    # Because they are not identical, changing x does not affect y
    x[1] = 5

    print()
    print("After changing x[1]")
    print("x =", x)
    print("y =", y)
    print("x equal y ? ", x == y)
    print("x is identical to y ?", x is y)

    # s1, s2: equal, not identical
    s1 = 'whole milk'
    s2 = 'whole milk'
    print("s1 equal s2 ? ", s1 == s2)
    print("s1 is identical to s2 ?", s1 is s2)
    print("s1 is not identical to s2 ?", s1 is not s2)
#eq()

#string formattierung

def strformating():
    l=40
    km=450
    print('The fuel efficiency of a car consuming {} liter of gas for every {} km = {} km/l'.format(l, km, km/l))
    print('The fuel efficiency of a car consuming {0:d} liter of gas for every {1:4.2f} km = {2:4.1f} km/l'.format(l, km, km/l))
    print('The fuel efficiency of a car consuming {a:d} liter of gas for every {b:4.2f} km = {c:4.2f} km/l'.format(a = l, b = km, c = km/l))
    first_name = input("Enter your first name: ")
    last_name = input("Enter your last name: ")
    print('The first name starts with: {:s}'.format(first_name[0]))
    print('The last name ends with the 2 chars: {:s}'.format(last_name[-2:]))
    from math import pi

    print('Right adjusted : {:<20.2f}'.format(pi))
    print('Center adjusted: {:^20.2f}'.format(pi))
    print('Left adjusted  : {:>20.2f}'.format(pi))
    print('Right adjusted : {:_<20.2f}'.format(pi))
    print('Center adjusted: {:_^20.2f}'.format(pi))
    print('Left adjusted  : {:_>20.2f}'.format(pi))

strformating()
