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
