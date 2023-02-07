import os,collections
if not os.path.isdir('input'):
    os.mkdir('input')
if not os.path.isdir('output'):
    os.mkdir('output')

keys=[]

os.chdir('input')
for x in os.listdir():
    if os.path.isfile(x) and x.endswith('.nfc'):
        with open(x,'r') as f:
            data=f.read().split('\n')
            count=0
            for x in data:
                if x.startswith('Block'):
                    count+=1
                    num=count/4
                    if float(num%1) == 0.0:
                        block=x.split(': ')
                        print(block)
                        keys.append(str(block[1])[:18])

os.chdir('../output')
with open('keys.txt','w') as f:
    counts=collections.Counter(keys)
    finalkeys=sorted(keys,key=counts.get,reverse=True)
    finalkeys=list(dict.fromkeys(finalkeys))
    
    for x in finalkeys:
        f.write(x.replace(' ','').upper()+"\n")