import os
for x in os.listdir():
    if os.path.isdir(x):
        os.chdir(x)
        for y in os.listdir():
            if os.path.isfile(y):
                os.rename(y,y.replace('.key.dump','.bin'))
        os.chdir('..')