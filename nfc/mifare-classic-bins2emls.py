import sys, collections
import binascii
import os
keys=[]
for x in os.listdir():
    if os.path.isdir(x):
        os.chdir(x)
        for y in os.listdir():
            if os.path.isfile(y) and y.endswith('.bin'):
                print(f"{x}/{y}")
                with open(y, 'rb') as file_inp:
                    with open(y.replace('.bin','.eml'),'w') as file_out:
                        count=0
                        while True:
                            count+=1
                            bytes=file_inp.read(16)
                            if not bytes:
                                break
                            hexchar=binascii.hexlify(bytes)
                            print(hexchar)
                            file_out.write(str(hexchar).replace('b\'','').replace("'","").upper())
                            num=count/4
                            if float(num%1) == 0.0:
                                keys.append(str(hexchar).replace('b\'','').replace("'",""))
                            file_out.write("\n")
                            
        os.chdir('..')
with open('keys.txt','w') as f:
    counts=collections.Counter(keys)
    finalkeys=sorted(keys,key=counts.get,reverse=True)
    finalkeys=list(dict.fromkeys(finalkeys))
    
    for x in finalkeys:
        key=x[:12]
        f.write(key.upper()+"\n")