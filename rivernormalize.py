rivercoords = [
    [540, 100],
    [540, 110],
    [505, 110],
    [490, 130],
    [490, 130],
    [470, 150],
    [450, 170],
    [450, 200],
    [460, 210],
    [450, 230],
    [460, 250],
    [460, 270],
    [460, 300],
    [490, 310],
    [490, 330],
    [510, 350],
    [510, 360],
    [540, 377],
    [540, 400],
    [540, 420],
    [510, 430],
    [530, 440],
    [505, 450],
    [490, 470],
    [480, 450],
    [470, 485],
    [460, 510],
    [466, 530],
    [460, 550],
    [460, 580],
]

## 460 is center


## image is 610x595, so middle of image horzontally is 305
# adjusted = [[(x[0] + 400), x[1]] for x in rivercoords];
# print(adjusted); 
def scale(number):
    return round((number - 0) * (760 - 40) / (560 - 0) + 40)
newvals = [(x[1] + 40) for x in rivercoords]
for x in newvals:
    print(x)