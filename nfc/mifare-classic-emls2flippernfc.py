import os
if not os.path.isdir('flipperexport'):
    os.mkdir('flipperexport')
os.chdir('flipperexport')
export=os.getcwd()
os.chdir('..')

for x in os.listdir():
    if os.path.isdir(x):
        if not os.path.isdir(f'{export}/{x}'):
            os.mkdir(f'{export}/{x}')
        os.chdir(x)
        for y in os.listdir():
            if os.path.isfile(y) and y.endswith('.eml'):
                print(y)
                data=open(y,'r').read()
                blocks=data.split('\n')
                filename=y.replace('.eml','.nfc')
                with open(f'{export}/{x}/{filename}','w') as f:
                    f.write('Filetype: Flipper NFC device\nVersion: 3\nDevice type: Mifare Classic\n')
                    uid=blocks[0][:8]
                    uid=[uid[i:i+2] for i in range(0, len(uid), 2)]
                    uid=" ".join(uid)
                    f.write(f'UID: {uid}\n')
                    f.write(f'ATQA: 00 04\nSAK: 08\nMifare Classic type: 1K\nData format version: 2\n')
                    count=0
                    for block in blocks:
                        block=block[:32]
                        if not block:
                            break
                        block=[block[i:i+2] for i in range(0, len(block), 2)]
                        block=" ".join(block)
                        f.write(f'Block {count}: {block}\n')
                        count+=1
        os.chdir('..')